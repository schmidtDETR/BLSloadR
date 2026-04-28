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
#' @export
#'
#' @examples
#' \donttest{
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
  headers <- get_bls_headers()

  response <- httr::GET(url, httr::add_headers(.headers = headers))
  httr::stop_for_status(response)

  content_text <- httr::content(response, as = "text", encoding = "UTF-8")
  return(strsplit(content_text, "\n", fixed = TRUE)[[1]])
}
