#' Download BLS Time Series Data
#'
#' This function downloads a tab-delimited BLS flat file, incorporating
#' diagnostic information about the file and returning an object with the
#' bls_data class that can be used in the BLSloadR package.
#'
#' @param url Character string. URL to the BLS flat file
#' @param verbose Logical. If TRUE, prints additional messages during file read and processing. If FALSE (default), suppresses these messages.
#' @param use_fallback Logical. If TRUE and httr download fails, fallback to download.file(). Default TRUE.
#' @return A named list with two elements:
#'    \describe{
#'     \item{data}{A data.table with the results of passing the url contents to 'data.table::fread()' as a tab-delimited text file.}
#'     \item{diagnostics}{A named list of diagnostics run when reading the file including column names, empty columns, cleaning applied to the file, the url, the column names and original and final dimensions of the data.}
#'   }
#' @export
#' @importFrom httr GET stop_for_status content add_headers
#' @importFrom data.table fread
#' @importFrom utils download.file
#' @examples
#' \donttest{
#' data <- fread_bls("https://download.bls.gov/pub/time.series/ec/ec.series")
#' }

fread_bls <- function(url, verbose = FALSE, use_fallback = TRUE) {
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

  # Create temporary file for download
  temp_file <- tempfile(fileext = ".txt")

  # Try httr::GET first, fallback to download.file for large files
  download_successful <- FALSE
  download_method <- "httr"

  tryCatch(
    {
      response <- GET(url, add_headers(.headers = headers))

      # Check for successful response
      stop_for_status(response)

      # Use binary mode to avoid building a giant character object
      raw_data <- content(response, as = "raw")

      # Check if we got an HTML error page (Access Denied, etc.)
      # HTML pages are typically much smaller than actual data files
      if (length(raw_data) < 10000) {
        # Check if it's HTML
        raw_text <- rawToChar(raw_data[1:min(500, length(raw_data))])
        if (grepl("<!DOCTYPE|<html", raw_text, ignore.case = TRUE)) {
          if (use_fallback) {
            if (verbose) {
              message(
                "Received HTML response, trying download.file() fallback..."
              )
            }
            stop("HTML response detected")
          } else {
            stop("Received HTML error page instead of data file")
          }
        }
      }

      # Write raw data to temporary file first for analysis
      writeBin(raw_data, temp_file)
      download_successful <- TRUE
    },
    error = function(e) {
      if (use_fallback) {
        if (verbose) {
          message("httr::GET failed, using download.file() fallback...")
        }
        download_method <<- "download.file"

        tryCatch(
          {
            # Use download.file as fallback - more reliable for large files
            download.file(
              url = url,
              destfile = temp_file,
              mode = "wb",
              quiet = !verbose,
              headers = headers
            )
            download_successful <<- TRUE
          },
          error = function(e2) {
            stop("Both httr::GET and download.file failed: ", e2$message)
          }
        )
      } else {
        stop("Download failed: ", e$message)
      }
    }
  )

  if (!download_successful) {
    stop("Failed to download file from: ", url)
  }

  # First pass: Read data as-is to identify phantom columns
  initial_data <- data.table::fread(
    temp_file,
    sep = "\t",
    colClasses = "character",
    header = TRUE,
    fill = TRUE
  )

  # Identify columns that are completely empty (phantom columns)
  phantom_cols <- sapply(initial_data, function(col) {
    all(is.na(col) | col == "" | grepl("^\\s*$", col))
  })

  if (verbose == TRUE) {
    message(
      "Initial data dimensions:",
      nrow(initial_data),
      "x",
      ncol(initial_data),
      "\n"
    )
    message("Phantom columns detected:", sum(phantom_cols), "\n")
    if (sum(phantom_cols) > 0) {
      message(
        "Phantom column names:",
        paste(names(initial_data)[phantom_cols], collapse = ", "),
        "\n"
      )
    }
  }

  # If phantom columns exist, apply selective cleaning
  if (sum(phantom_cols) > 0) {
    # Read the raw file content
    text_data <- paste(readLines(temp_file, warn = FALSE), collapse = "\n")

    # Process each line to remove phantom tabs
    lines <- strsplit(text_data, "\n", fixed = TRUE)[[1]]
    cleaned_lines <- sapply(
      lines,
      function(line) {
        # Only clean lines that have the phantom tab pattern
        if (grepl("\t\\s+\t", line)) {
          # Replace tab + whitespace + tab with single tab
          gsub("\t\\s+\t", "\t", line, perl = TRUE)
        } else {
          line
        }
      },
      USE.NAMES = FALSE
    )

    # Reconstruct the cleaned data
    cleaned_data <- paste(cleaned_lines, collapse = "\n")

    # Write cleaned data back to temp file
    writeLines(cleaned_data, temp_file, sep = "")

    if (verbose == TRUE) {
      message("Applied selective tab cleaning to remove phantom columns\n")
    }
  } else {
    if (verbose == TRUE) {
      message("No phantom columns detected, using original data\n")
    }
  }

  # Read the header row separately
  header_line <- readLines(temp_file, n = 1)

  # Split header by tabs and clean whitespace
  header_names <- strsplit(header_line, "\t", fixed = TRUE)[[1]]
  header_names <- trimws(header_names)

  if (verbose == TRUE) {
    # Print diagnostic info
    message("Header parsing debug:\n")
    message("Raw header line length:", nchar(header_line), "\n")
    message("Number of tab-separated fields:", length(header_names), "\n")
    message(
      "Header names:",
      paste(sprintf("'%s'", header_names), collapse = ", "),
      "\n"
    )
  }

  # Read the final data without headers using fread
  return_data <- data.table::fread(
    temp_file,
    sep = "\t",
    colClasses = "character",
    header = FALSE,
    skip = 1,
    fill = TRUE
  )

  if (verbose == TRUE) {
    message(
      "Final data dimensions:",
      nrow(return_data),
      "x",
      ncol(return_data),
      " in ",
      url,
      "\n"
    )
  }

  # Handle column count mismatch
  n_header_cols <- length(header_names)
  n_data_cols <- ncol(return_data)

  if (n_header_cols != n_data_cols) {
    warning(
      "Column count mismatch! Headers:",
      n_header_cols,
      "Data:",
      n_data_cols,
      "\n"
    )

    if (n_data_cols > n_header_cols) {
      header_names <- c(
        header_names,
        paste0("EXTRA_COL_", 1:(n_data_cols - n_header_cols))
      )
    } else {
      header_names <- header_names[1:n_data_cols]
    }
  }

  # Only remove columns that are STILL completely empty after cleaning
  empty_cols <- sapply(return_data, function(col) {
    all(is.na(col) | col == "" | grepl("^\\s*$", col))
  })

  if (any(empty_cols)) {
    if (verbose == TRUE) {
      message("Removing", sum(empty_cols), "remaining empty columns\n")
    }
    return_data <- return_data[, !empty_cols, with = FALSE]
  }

  # Final column name assignment
  if (length(header_names) == ncol(return_data)) {
    names(return_data) <- header_names
  } else {
    warning(paste(
      "Final header count (",
      length(header_names),
      ") doesn't match final column count (",
      ncol(return_data),
      "), using generic names"
    ))
    names(return_data) <- paste0("V", 1:ncol(return_data))
  }

  # Clean up temp file
  unlink(temp_file)

  if (verbose == TRUE) {
    message(
      "Final column names:",
      paste(names(return_data), collapse = ", "),
      "\n"
    )
  }

  # Create diagnostic information
  diagnostics <- list(
    url = url,
    original_dimensions = c(nrow(initial_data), ncol(initial_data)),
    final_dimensions = c(nrow(return_data), ncol(return_data)),
    phantom_columns_detected = sum(phantom_cols),
    phantom_column_names = if (sum(phantom_cols) > 0) {
      names(initial_data)[phantom_cols]
    } else {
      character(0)
    },
    cleaning_applied = sum(phantom_cols) > 0,
    header_data_mismatch = n_header_cols != n_data_cols,
    empty_columns_removed = sum(empty_cols),
    final_column_names = names(return_data),
    warnings = character(0)
  )

  # Add specific warnings
  if (diagnostics$header_data_mismatch) {
    diagnostics$warnings <- c(
      diagnostics$warnings,
      paste(
        "Header/data column count mismatch: Headers =",
        n_header_cols,
        ", Data =",
        n_data_cols
      )
    )
  }

  if (diagnostics$phantom_columns_detected > 0) {
    diagnostics$warnings <- c(
      diagnostics$warnings,
      paste(
        "Phantom columns detected and cleaned:",
        diagnostics$phantom_columns_detected
      )
    )
  }

  if (diagnostics$empty_columns_removed > 0) {
    diagnostics$warnings <- c(
      diagnostics$warnings,
      paste("Empty columns removed:", diagnostics$empty_columns_removed)
    )
  }

  # Return both data and diagnostics
  result <- list(
    data = return_data,
    diagnostics = diagnostics
  )

  class(result) <- c("bls_data", "list")

  return(result)
}
