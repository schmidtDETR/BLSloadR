#' Read Plain Text Files from BLS Website
#'
#' Downloads and reads plain text files from the Bureau of Labor Statistics (BLS)
#' website. This is a companion function to \code{fread_bls()} that handles text
#' files rather than structured data tables. The function uses custom headers to
#' ensure reliable access to BLS resources.
#'
#' @param url A character string specifying the full URL to a text file on the
#'   BLS website (e.g., \url{https://download.bls.gov/pub/time.series/}).
#'
#' @return A character vector where each element is one line from the text file.
#'   Lines are split on newline characters (\code{\\n}).
#'
#' @details
#' This function is designed to read descriptive text files from BLS, such as
#' README files or database overview documents. It sends an HTTP GET request
#' with browser-like headers to ensure compatibility with BLS server requirements.
#'
#' The function will stop with an error if the HTTP request fails (e.g., if the
#' URL is invalid or the server is unavailable).
#'
#' @examples
#' \dontrun{
#' # Read the overview file for Current Employment Statistics
#' ces_overview <- read_bls_text(
#'   "https://download.bls.gov/pub/time.series/ce/ce.txt"
#' )
#'
#' # Display the first few lines
#' head(ces_overview)
#' }
#'
#' @seealso
#' \code{\link{bls_overview}} for formatted database overviews,
#' \code{\link{load_bls_dataset}} for loading complete datasets
#'
#' @keywords internal
read_bls_text <- function(url) {
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
  return(strsplit(content_text, "\n", fixed = TRUE)[[1]])
}