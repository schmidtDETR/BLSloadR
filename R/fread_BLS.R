#' Download BLS Time Series Data
#'
#' This function downloads a tab-delimited BLS flat file, incorporating 
#' diagnostic information about the file and returning an object with the
#' bls_data class that can be used in the BLSloadR package.
#'
#' @param url Character string. URL to the BLS flat file
#' @param verbose Logical. If TRUE, prints additional messages during file read and processing.  If FALSE (default), suppresses these messages.
#' @return A data.table containing the downloaded data
#' @export
#' @importFrom httr GET
#' @importFrom httr stop_for_status
#' @importFrom httr content
#' @importFrom httr add_headers
#' @importFrom data.table fread
#' @examples
#' \dontrun{
#' data <- fread_bls("https://download.bls.gov/pub/time.series/ec/ec.series")
#' }

fread_bls <- function(url, verbose = FALSE){
  
  headers <- c(
    "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    "Accept-Encoding" = "gzip, deflate, br",
    "Accept-Language" = "en-US,en;q=0.9",
    "Connection" = "keep-alive",
    "Host" = "download.bls.gov",
    "Referer" = "https://download.bls.gov/pub/time.series/",
    "Sec-Ch-Ua" = 'Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
    "Sec-Ch-Ua-Mobile" = "?0",
    "Sec-Ch-Ua-Platform" = '"Windows"',
    "Sec-Fetch-Dest" = "document",
    "Sec-Fetch-Mode" = "navigate",
    "Sec-Fetch-Site" = "same-origin",
    "Sec-Fetch-User" = "?1",
    "Upgrade-Insecure-Requests" = "1",
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  )
  
  response <- GET(url, add_headers(.headers = headers))
  
  # Check for successful response
  stop_for_status(response)
  
  # Use binary mode to avoid building a giant character object
  raw_data <- content(response, as = "raw")
  
  # Write raw data to temporary file first for analysis
  temp_file <- tempfile(fileext = ".txt")
  writeBin(raw_data, temp_file)
  
  # First pass: Read data as-is to identify phantom columns
  initial_data <- fread(temp_file, 
                        sep = "\t", 
                        colClasses = "character",
                        header = TRUE,
                        fill = TRUE)
  
  # Identify columns that are completely empty (phantom columns)
  phantom_cols <- sapply(initial_data, function(col) {
    all(is.na(col) | col == "" | grepl("^\\s*$", col))
  })
  
  if(verbose == TRUE) {
  cat("Initial data dimensions:", nrow(initial_data), "x", ncol(initial_data), "\n")
  cat("Phantom columns detected:", sum(phantom_cols), "\n")
  if (sum(phantom_cols) > 0) {
    cat("Phantom column names:", paste(names(initial_data)[phantom_cols], collapse = ", "), "\n")
  }
  }
  
  # If phantom columns exist, apply selective cleaning
  if (sum(phantom_cols) > 0) {
    # Convert to character for cleaning
    text_data <- rawToChar(raw_data)
    
    # Split into lines for processing
    lines <- strsplit(text_data, "\n", fixed = TRUE)[[1]]
    
    # Process each line to remove phantom tabs
    cleaned_lines <- sapply(lines, function(line) {
      # Only clean lines that have the phantom tab pattern
      if (grepl("\t\\s+\t", line)) {
        # Replace tab + whitespace + tab with single tab
        gsub("\t\\s+\t", "\t", line, perl = TRUE)
      } else {
        line
      }
    }, USE.NAMES = FALSE)
    
    # Reconstruct the cleaned data
    cleaned_data <- paste(cleaned_lines, collapse = "\n")
    
    # Write cleaned data back to temp file
    writeLines(cleaned_data, temp_file, sep = "")
    
    if(verbose == TRUE){
    cat("Applied selective tab cleaning to remove phantom columns\n")
  } else {
    cat("No phantom columns detected, using original data\n")
  }
  }
  
  
  # Read the header row separately
  header_line <- readLines(temp_file, n = 1)
  
  # Split header by tabs and clean whitespace
  header_names <- strsplit(header_line, "\t", fixed = TRUE)[[1]]
  header_names <- trimws(header_names)
  
  if(verbose == TRUE){
  # Print diagnostic info
  cat("Header parsing debug:\n")
  cat("Raw header line length:", nchar(header_line), "\n")
  cat("Number of tab-separated fields:", length(header_names), "\n")
  cat("Header names:", paste(sprintf("'%s'", header_names), collapse = ", "), "\n")
  }
  
  # Read the final data without headers using fread
  return_data <- fread(temp_file, 
                       sep = "\t", 
                       colClasses = "character",
                       header = FALSE,
                       skip = 1,
                       fill = TRUE)
  
  cat("Final data dimensions:", nrow(return_data), "x", ncol(return_data), " in ", url, "\n")
  
  # Handle column count mismatch
  n_header_cols <- length(header_names)
  n_data_cols <- ncol(return_data)
  
  if (n_header_cols != n_data_cols) {
    cat("Column count mismatch! Headers:", n_header_cols, "Data:", n_data_cols, "\n")
    
    if (n_data_cols > n_header_cols) {
      # Add extra column names
      extra_names <- paste0("EXTRA_COL_", 1:(n_data_cols - n_header_cols))
      header_names <- c(header_names, extra_names)
    } else if (n_header_cols > n_data_cols) {
      # Truncate header names
      header_names <- header_names[1:n_data_cols]
    }
  }
  
  # Only remove columns that are STILL completely empty after cleaning
  empty_cols <- sapply(return_data, function(col) {
    all(is.na(col) | col == "" | grepl("^\\s*$", col))
  })
  
  if (any(empty_cols)) {
    cat("Removing", sum(empty_cols), "remaining empty columns\n")
    return_data <- return_data[, !empty_cols, with = FALSE]
    header_names <- header_names[!empty_cols[1:length(header_names)]]
  }
  
  # Final column name assignment
  if (length(header_names) == ncol(return_data)) {
    names(return_data) <- header_names
  } else {
    warning(paste("Final header count (", length(header_names), 
                  ") doesn't match final column count (", ncol(return_data), 
                  "), using generic names"))
    names(return_data) <- paste0("V", 1:ncol(return_data))
  }
  
  # Clean up temp file
  unlink(temp_file)
  
  cat("Final column names:", paste(names(return_data), collapse = ", "), "\n")
  
  # Create diagnostic information
  diagnostics <- list(
    url = url,
    original_dimensions = c(nrow(initial_data), ncol(initial_data)),
    final_dimensions = c(nrow(return_data), ncol(return_data)),
    phantom_columns_detected = sum(phantom_cols),
    phantom_column_names = if(sum(phantom_cols) > 0) names(initial_data)[phantom_cols] else character(0),
    cleaning_applied = sum(phantom_cols) > 0,
    header_data_mismatch = n_header_cols != n_data_cols,
    original_header_count = n_header_cols,
    final_data_count = n_data_cols,
    empty_columns_removed = sum(empty_cols),
    final_column_names = names(return_data),
    warnings = character(0)
  )
  
  # Add specific warnings
  if (diagnostics$header_data_mismatch) {
    diagnostics$warnings <- c(diagnostics$warnings, 
                              paste("Header/data column count mismatch: Headers =", 
                                    n_header_cols, ", Data =", n_data_cols))
  }
  
  if (diagnostics$phantom_columns_detected > 0) {
    diagnostics$warnings <- c(diagnostics$warnings,
                              paste("Phantom columns detected and cleaned:", 
                                    diagnostics$phantom_columns_detected))
  }
  
  if (diagnostics$empty_columns_removed > 0) {
    diagnostics$warnings <- c(diagnostics$warnings,
                              paste("Empty columns removed:", 
                                    diagnostics$empty_columns_removed))
  }
  
  # Return both data and diagnostics
  result <- list(
    data = return_data,
    diagnostics = diagnostics
  )
  
  class(result) <- c("bls_data", "list")
  
  return(result)
}