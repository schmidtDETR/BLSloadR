#' Search and Explore CPS (LN) Series IDs
#'
#' This helper function allows users to search for specific CPS series by
#' keywords in the series title or by filtering on characteristics. It returns
#' matching series IDs along with their descriptions, making it easier to
#' identify the exact series needed for analysis.
#'
#' @param search Optional character string or vector to search for in series titles.
#'   Case-insensitive partial matching is used. Can search for terms like
#'   "unemployment", "labor force", "participation", etc.
#' @param characteristics Optional named list of characteristics to filter by
#'   (e.g., `list(ages_code = "00", sexs_code = "1")`). Use
#'   \code{\link{explore_cps_characteristics}} to discover valid codes.
#' @param seasonal Optional character string to filter by seasonal adjustment:
#'   "S" for seasonally adjusted, "U" for not seasonally adjusted.
#' @param max_results Maximum number of results to return. Default is 50.
#' @param cache_dir Optional character string specifying the directory for cached files.
#'   If NULL, uses R's temporary directory via `tempdir()`.
#' @param verbose Logical. If TRUE, print informative messages. Default is TRUE.
#'
#' @return A data.frame with columns:
#'   \itemize{
#'     \item series_id: The BLS series identifier
#'     \item series_title: Human-readable description of the series
#'     \item seasonal: "S" (seasonally adjusted) or "U" (not adjusted)
#'     \item begin_year/begin_period: When the series starts
#'     \item end_year/end_period: When the series ends (or latest available)
#'     \item Additional characteristic codes (ages_code, sexs_code, etc.)
#'   }
#'
#' @details
#' This function downloads the ln.series metadata file and filters it based
#' on your search criteria. It's particularly useful when you want to:
#' \itemize{
#'   \item Find series by topic (e.g., "unemployment rate for women")
#'   \item Discover what series exist for specific demographic groups
#'   \item Identify the correct series ID before calling \code{\link{get_cps_subset}}
#' }
#'
#' @examples
#' \dontrun{
#' # Search for unemployment-related series
#' explore_cps_series(search = "unemployment rate")
#'
#' # Find all series for men aged 16+
#' explore_cps_series(
#'   characteristics = list(sexs_code = "1", ages_code = "00")
#' )
#'
#' # Search for labor force participation, seasonally adjusted
#' explore_cps_series(
#'   search = "labor force participation",
#'   seasonal = "S"
#' )
#'
#' # Combine search terms and characteristics
#' explore_cps_series(
#'   search = "unemployment",
#'   characteristics = list(sexs_code = "2", ages_code = "00"),
#'   seasonal = "S",
#'   max_results = 10
#' )
#' }
#'
#' @seealso
#' \code{\link{explore_cps_characteristics}} to discover valid characteristic codes,
#' \code{\link{get_cps_subset}} to retrieve data for discovered series.
#'
#' @export
#' @importFrom dplyr filter select arrange slice_head
#' @importFrom rlang .data
explore_cps_series <- function(search = NULL,
                               characteristics = NULL,
                               seasonal = NULL,
                               max_results = 50,
                               cache_dir = NULL,
                               verbose = TRUE) {
  
  # Set up cache directory
  if (is.null(cache_dir)) {
    cache_dir <- tempdir()
  } else if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }
  
  base_url <- "https://download.bls.gov/pub/time.series/ln/"
  series_url <- paste0(base_url, "ln.series")
  
  # Download series file
  if (verbose) message("Loading CPS series metadata...")
  series_result <- fread_bls(series_url, verbose = FALSE)
  series_dt <- series_result$data
  
  # Start with all series
  filtered <- series_dt
  
  # Apply characteristic filters
  if (!is.null(characteristics)) {
    for (char_name in names(characteristics)) {
      if (!char_name %in% names(filtered)) {
        stop(sprintf("Characteristic '%s' not found in series metadata.", char_name))
      }
      filtered <- filtered |>
        dplyr::filter(.data[[char_name]] %in% characteristics[[char_name]])
    }
    if (verbose) {
      message(sprintf(
        "Filtered to %d series matching characteristics: %s",
        nrow(filtered),
        paste(names(characteristics), "=", characteristics, collapse = ", ")
      ))
    }
  }
  
  # Apply seasonal filter
  if (!is.null(seasonal)) {
    if (!seasonal %in% c("S", "U")) {
      stop("seasonal must be 'S' (seasonally adjusted) or 'U' (not adjusted)")
    }
    filtered <- filtered |>
      dplyr::filter(seasonal == !!seasonal)
    if (verbose) {
      adj_text <- ifelse(seasonal == "S", "seasonally adjusted", "not seasonally adjusted")
      message(sprintf("Filtered to %d %s series", nrow(filtered), adj_text))
    }
  }
  
  # Apply text search on series_title
  if (!is.null(search)) {
    search_pattern <- paste(search, collapse = "|")
    filtered <- filtered |>
      dplyr::filter(grepl(search_pattern, series_title, ignore.case = TRUE))
    if (verbose) {
      message(sprintf(
        "Found %d series matching search: '%s'",
        nrow(filtered),
        paste(search, collapse = "', '")
      ))
    }
  }
  
  # Check if any results found
  if (nrow(filtered) == 0) {
    message("No series found matching your criteria.")
    return(data.frame())
  }
  
  # Select key columns and limit results
  result <- filtered |>
    dplyr::select(
      series_id,
      series_title,
      seasonal,
      begin_year,
      begin_period,
      end_year,
      end_period,
      tidyselect::ends_with("_code")
    ) |>
    dplyr::arrange(series_id) |>
    dplyr::slice_head(n = max_results)
  
  if (verbose && nrow(filtered) > max_results) {
    message(sprintf(
      "Showing first %d of %d results. Increase max_results to see more.",
      max_results,
      nrow(filtered)
    ))
  }
  
  return(as.data.frame(result))
}
