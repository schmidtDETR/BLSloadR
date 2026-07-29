#' Read Plain Text Files from BLS Website
#'
#' Downloads and reads plain text files from the Bureau of Labor Statistics (BLS)
#' website. This is a companion function to \code{fread_bls()} that handles text
#' files rather than structured data tables. The function uses custom headers to
#' ensure reliable access to BLS resources.
#'
#' @param url A character string specifying the full URL to a text file on the
#'   BLS website (e.g., \url{https://download.bls.gov/pub/time.series/}).
#' @param user_agent An optional character string supplying a USER_AGENT header for the HTML request from the BLS.   
#'
#' @return A character vector where each element is one line from the text file.
#'   Lines are split on newline characters (\code{\\n}). Returns \code{NULL} if 
#'   the HTTP request fails.
#'
#' @details
#' This function is designed to read descriptive text files from BLS, such as
#' README files or database overview documents. It sends an HTTP GET request
#' with browser-like headers to ensure compatibility with BLS server requirements.
#'
#' If the HTTP request fails (e.g., if the URL is invalid, the server is unavailable, 
#' or a 403 Forbidden error is encountered during automated testing), the function 
#' will issue a warning and gracefully return \code{NULL} rather than stopping execution.
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
read_bls_text <- function(url, user_agent = NULL) {
  headers <- get_bls_headers(user_agent = user_agent)
  
  response <- httr::GET(url, httr::add_headers(.headers = headers))
  
  # Check for HTTP errors (like 403, 404, 500) and fail gracefully
  if (httr::http_error(response)) {
    warning(
      sprintf("Failed to retrieve text file from BLS. HTTP status code: %s. Returning NULL.", httr::status_code(response)),
      call. = FALSE
    )
    return(NULL)
  }
  
  content_text <- httr::content(response, as = "text", encoding = "UTF-8")
  return(strsplit(content_text, "\n", fixed = TRUE)[[1]])
}