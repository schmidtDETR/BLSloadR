#' Download BLS Time Series Data
#'
#' This function uses data.table::fread and httr to retrieve data from BLS
#' time series flat files, adding appropriate headers to avoid 403 errors.
#'
#' @param url Character string. URL to the BLS flat file
#' @return A data.table containing the downloaded data
#' @export
#' @importFrom httr GET
#' @importFrom httr stop_for_status
#' @importFrom httr content
#' @importFrom httr add_headers
#' @importFrom data.table fread
#' @examples
#' \dontrun{
#' data <- fread_bls("https://download.bls.gov/pub/time.series/sm/sm.series")
#' }

fread_bls <- function(url){
  
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
  
  # Write to a temporary file to avoid loading it all into memory as a string
  temp_file <- tempfile(fileext = ".txt")
  writeBin(raw_data, temp_file)
  
  # Read the header row separately
  header_line <- readLines(temp_file, n = 1)
  header_names <- strsplit(header_line, "\t")[[1]]
  
  # Read the data without headers
  return_data <- fread(temp_file, 
                       sep = "\t", 
                       colClasses = "character",
                       header = FALSE,
                       skip = 1)
  
  # Remove trailing empty columns (caused by extra tabs at end of rows)
  # Check if last column(s) are entirely empty or NA
  while (ncol(return_data) > 1) {
    last_col <- ncol(return_data)
    last_col_data <- return_data[[last_col]]
    
    # Remove if column is entirely empty, NA, or whitespace
    if (all(is.na(last_col_data) | last_col_data == "" | grepl("^\\s*$", last_col_data))) {
      return_data <- return_data[, -last_col, with = FALSE]
    } else {
      break
    }
  }
  
  # Also remove trailing empty elements from header names
  while (length(header_names) > 1 && 
         (is.na(header_names[length(header_names)]) || 
          header_names[length(header_names)] == "" || 
          grepl("^\\s*$", header_names[length(header_names)]))) {
    header_names <- header_names[-length(header_names)]
  }
  
  # Assign the cleaned header names to the data
  if (length(header_names) == ncol(return_data)) {
    names(return_data) <- header_names
  } else {
    # Fallback if header count doesn't match column count
    warning("Header count doesn't match column count, using generic names")
    names(return_data) <- paste0("V", 1:ncol(return_data))
  }
  
  # Clean up temp file
  unlink(temp_file)
  
  return(return_data)
}