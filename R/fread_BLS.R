#' Download BLS Time Series Data
#'
#' This function downloads a tab-delimited BLS flat file, incorporating 
#' diagnostic information about the file and returning an object with the
#' bls_data class that can be used in the BLSloadR package.
#'
#' @param url Character string. URL to the BLS flat file
#' @param verbose Logical. If TRUE, prints additional messages during file read and processing.
#' @param cache Logical. If TRUE, uses local persistent caching.
#' @return A named list with the data and diagnostics.
#' @export
#' @importFrom httr GET stop_for_status content add_headers
#' @importFrom data.table fread
fread_bls <- function(url, verbose = FALSE, cache = check_bls_cache_env()) {
  
  # --- 1. DATA ACQUISITION ---
  if (cache) {
    # Uses the smart download logic to check headers/mtime
    temp_file <- smart_bls_download(url, verbose = verbose)
  } else {
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
    
    response <- httr::GET(url, httr::add_headers(.headers = headers))
    httr::stop_for_status(response)
    
    raw_data <- httr::content(response, as = "raw")
    temp_file <- tempfile(fileext = ".txt")
    writeBin(raw_data, temp_file)
  }
  
  # --- 2. INITIAL DIAGNOSTIC PASS ---
  # Read as-is to check for phantom columns
  initial_data <- data.table::fread(
    temp_file, 
    sep = "\t", 
    colClasses = "character", 
    header = TRUE, 
    fill = TRUE, 
    showProgress = FALSE
  )
  
  phantom_cols <- sapply(initial_data, function(col) {
    all(is.na(col) | col == "" | grepl("^\\s*$", col))
  })
  
  has_phantoms <- sum(phantom_cols) > 0
  
  if (verbose) {
    message("Initial data dimensions: ", nrow(initial_data), " x ", ncol(initial_data))
    message("Phantom columns detected: ", sum(phantom_cols))
  }
  
  # --- 3. VECTORIZED CLEANING (Only if needed) ---
  if (has_phantoms) {
    # Read file back as raw to perform vectorized string replacement
    raw_bytes <- readBin(temp_file, "raw", n = file.info(temp_file)$size)
    text_data <- rawToChar(raw_bytes)
    
    # VECTORIZED REPLACEMENT: Faster than row-by-row sapply
    # Replaces tab + whitespace + tab with single tab across the entire file at once
    cleaned_data <- gsub("\t\\s+\t", "\t", text_data, perl = TRUE)
    
    # Overwrite the file with cleaned data
    writeLines(cleaned_data, temp_file, sep = "")
    
    if (verbose) message("Applied vectorized tab cleaning.")
    
    # Re-read the cleaned data (Necessary because the structure changed)
    return_data <- data.table::fread(
      temp_file, 
      sep = "\t", 
      colClasses = "character", 
      header = TRUE, 
      fill = TRUE,
      showProgress = FALSE
    )
  } else {
    # If no cleaning was needed, return_data is just initial_data
    return_data <- initial_data
  }
  
  # --- 4. HEADER & COLUMN MANAGEMENT ---
  # Extract and clean header names from the file
  header_line <- readLines(temp_file, n = 1)
  header_names <- trimws(strsplit(header_line, "\t", fixed = TRUE)[[1]])
  
  n_header_cols <- length(header_names)
  n_data_cols <- ncol(return_data)
  
  if (n_header_cols != n_data_cols) {
    if (verbose) warning("Column count mismatch! Headers: ", n_header_cols, " Data: ", n_data_cols)
    if (n_data_cols > n_header_cols) {
      header_names <- c(header_names, paste0("EXTRA_COL_", 1:(n_data_cols - n_header_cols)))
    } else {
      header_names <- header_names[1:n_data_cols]
    }
  }
  
  # Assign names
  if (length(header_names) == ncol(return_data)) {
    names(return_data) <- header_names
  }
  
  # Final Empty Column Removal (Post-cleaning check)
  empty_cols <- sapply(return_data, function(col) {
    all(is.na(col) | col == "" | grepl("^\\s*$", col))
  })
  
  if (any(empty_cols)) {
    if (verbose) message("Removing ", sum(empty_cols), " remaining empty columns.")
    return_data <- return_data[, !empty_cols, with = FALSE]
  }
  
  # --- 5. CLEANUP & DIAGNOSTICS ---
  if (!cache) {
    unlink(temp_file)
  }
  
  diagnostics <- list(
    url = url,
    original_dimensions = c(nrow(initial_data), ncol(initial_data)),
    final_dimensions = c(nrow(return_data), ncol(return_data)),
    phantom_columns_detected = sum(phantom_cols),
    cleaning_applied = has_phantoms,
    header_data_mismatch = n_header_cols != n_data_cols,
    empty_columns_removed = sum(empty_cols),
    final_column_names = names(return_data),
    warnings = character(0)
  )
  
  result <- list(data = return_data, diagnostics = diagnostics)
  class(result) <- c("bls_data", "list")
  
  return(result)
}