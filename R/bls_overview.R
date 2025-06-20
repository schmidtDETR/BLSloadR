#' Display BLS Dataset Overview
#'
#' Fetches and displays the overview text file for a BLS dataset using proper
#' headers to avoid 403 errors from the BLS server.
#'
#' @param series_id Character string. The BLS series identifier (e.g., "ln", "cu", "ap")
#' @param display_method Character string. How to display the overview: 
#'   "viewer" (default), "console", "help", or "popup"
#' @param base_url Character string. Base URL for BLS data (default uses official BLS site)
#'
#' @return Invisibly returns the text content
#' @export
#' @importFrom httr GET add_headers stop_for_status content
#' @importFrom htmltools HTML
#' @importFrom htmltools htmlEscape
#' @importFrom rstudioapi isAvailable
#'
#' @examples
#' \dontrun{
#' # Display labor force statistics overview
#' bls_overview("ln")
#' 
#' # Display consumer price index overview  
#' bls_overview("cu")
#' 
#' # Display in console instead of viewer
#' bls_overview("ln", display_method = "console")
#' }
bls_overview <- function(series_id, 
                         display_method = "viewer",
                         base_url = "https://download.bls.gov/pub/time.series") {
  
  # Validate inputs
  if (!is.character(series_id) || length(series_id) != 1) {
    stop("series_id must be a single character string")
  }
  
  display_method <- match.arg(display_method, c("viewer", "console", "help", "popup"))
  
  # Construct URL
  url <- file.path(base_url, series_id, paste0(series_id, ".txt"))
  
  # Fetch content with proper headers (similar to fread_bls)
  tryCatch({
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
    
    content_text <- httr::content(response, as = "text", encoding = "UTF-8")
    
    # Display based on method
    switch(display_method,
           "viewer" = display_in_viewer(content_text, series_id),
           "console" = display_in_console(content_text, series_id),
           "help" = display_as_help(content_text, series_id),
           "popup" = display_in_popup(content_text, series_id)
    )
    
    invisible(content_text)
    
  }, error = function(e) {
    stop(sprintf("Could not fetch overview for series '%s'. URL: %s\nError: %s", 
                 series_id, url, e$message))
  })
}

# Helper function to display in RStudio viewer
display_in_viewer <- function(content, series_id) {
  if (!requireNamespace("htmltools", quietly = TRUE)) {
    stop("Package 'htmltools' is required for viewer display. Install with: install.packages('htmltools')")
  }
  
  # Create HTML content
  html_content <- htmltools::HTML(sprintf("
    <html>
    <head>
      <title>BLS Overview: %s</title>
      <style>
        body { 
          font-family: 'Courier New', monospace; 
          margin: 20px; 
          line-height: 1.4;
          background-color: #f8f9fa;
        }
        .header { 
          background-color: #007bff; 
          color: white; 
          padding: 15px; 
          margin: -20px -20px 20px -20px;
          border-radius: 0;
        }
        .content { 
          white-space: pre-wrap; 
          background-color: white;
          padding: 20px;
          border: 1px solid #dee2e6;
          border-radius: 5px;
        }
      </style>
    </head>
    <body>
      <div class='header'>
        <h1>BLS Dataset Overview: %s</h1>
        <p>Source: https://download.bls.gov/pub/time.series/%s/%s.txt</p>
      </div>
      <div class='content'>%s</div>
    </body>
    </html>
  ", toupper(series_id), toupper(series_id), series_id, series_id, 
                                          htmltools::htmlEscape(content)))
  
  # Create temporary file and display
  temp_file <- tempfile(fileext = ".html")
  writeLines(as.character(html_content), temp_file)
  
  if (rstudioapi::isAvailable()) {
    rstudioapi::viewer(temp_file)
  } else {
    utils::browseURL(temp_file)
  }
}

# Helper function to display in console
display_in_console <- function(content, series_id) {
  cat(sprintf("\n=== BLS Dataset Overview: %s ===\n", toupper(series_id)))
  cat(sprintf("Source: https://download.bls.gov/pub/time.series/%s/%s.txt\n", series_id, series_id))
  cat(paste(rep("=", 50), collapse = ""), "\n\n")
  cat(content, "\n\n")
}

# Helper function to display as help-style page
display_as_help <- function(content, series_id) {
  if (!requireNamespace("htmltools", quietly = TRUE)) {
    message("htmltools not available, displaying in console instead")
    display_in_console(content, series_id)
    return()
  }
  
  # Create help-style HTML
  help_html <- htmltools::HTML(sprintf("
    <html>
    <head>
      <title>BLS Overview: %s</title>
      <style>
        body { 
          font-family: Arial, sans-serif; 
          margin: 40px; 
          line-height: 1.6;
          max-width: 800px;
        }
        h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        .source { color: #7f8c8d; font-style: italic; margin-bottom: 20px; }
        .content { 
          font-family: 'Courier New', monospace; 
          white-space: pre-wrap; 
          background-color: #f8f9fa;
          padding: 20px;
          border-left: 4px solid #3498db;
          margin: 20px 0;
        }
      </style>
    </head>
    <body>
      <h1>BLS Dataset: %s</h1>
      <div class='source'>Source: https://download.bls.gov/pub/time.series/%s/%s.txt</div>
      <div class='content'>%s</div>
    </body>
    </html>
  ", toupper(series_id), toupper(series_id), series_id, series_id, 
                                       htmltools::htmlEscape(content)))
  
  temp_file <- tempfile(fileext = ".html")
  writeLines(as.character(help_html), temp_file)
  
  if (rstudioapi::isAvailable()) {
    rstudioapi::viewer(temp_file)
  } else {
    utils::browseURL(temp_file)
  }
}

# Helper function to display in popup dialog (if available)
display_in_popup <- function(content, series_id) {
  if (rstudioapi::isAvailable() && rstudioapi::hasFun("showDialog")) {
    # Truncate content if too long for dialog
    display_content <- content
    if (nchar(content) > 2000) {
      display_content <- paste(substr(content, 1, 2000), "\n\n[Content truncated - use viewer method for full text]")
    }
    
    rstudioapi::showDialog(
      title = paste("BLS Overview:", toupper(series_id)),
      message = display_content
    )
  } else {
    message("Popup not available, displaying in console instead")
    display_in_console(content, series_id)
  }
}