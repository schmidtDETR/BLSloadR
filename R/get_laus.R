#' Download Local Area Unemployment Statistics (LAUS) Data
#'
#' @description This function downloads Local Area Unemployment Statistics data from the U.S. Bureau
#'  of Labor Statistics. Due to the large size of some LAUS datasets (county and city
#'  files are >300MB), users must specify which geographic level to download. The function
#'  provides access to both seasonally adjusted and unadjusted data at various geographic levels.
#'
#' @param geography Character string specifying the geographic level and adjustment type.
#'   Default is "state_adjusted". Valid options are:
#'   \itemize{
#'     \item "state_current_adjusted" - Current seasonally adjusted state data
#'     \item "state_unadjusted" - All historical unadjusted state data
#'     \item "state_adjusted" - All historical seasonally adjusted state data (default)
#'     \item "region_unadjusted" - Unadjusted regional and division data
#'     \item "region_adjusted" - Seasonally adjusted regional and division data
#'     \item "metro" - Metropolitan statistical area data
#'     \item "division" - Division-level data
#'     \item "micro" - Micropolitan statistical area data
#'     \item "combined" - Combined statistical area data
#'     \item "county" - County-level data (large file >300MB)
#'     \item "city" - City and town data (large file >300MB)
#'   }
#' @param monthly_only Logical. If TRUE (default), excludes annual data (period M13)
#'   and creates a date column from year and period.
#' @param transform Logical. If TRUE (default), converts rate and ratio measures from
#'   percentages to proportions by dividing by 100. Unemployment rates will be expressed
#'   as decimals (e.g., 0.05 for 5\% unemployment) rather than percentages.
#' @param suppress_warnings Logical. If TRUE, suppress individual download warnings
#'   for cleaner output during batch processing.
#'
#' @return A bls_data_collection object containing LAUS data with the following key columns:
#'   \describe{
#'     \item{series_id}{BLS series identifier}
#'     \item{year}{Year of observation}
#'     \item{period}{Time period (M01-M12 for months, M13 for annual)}
#'     \item{value}{Employment statistic value (transformed if transform = TRUE)}
#'     \item{date}{Date of observation (if monthly_only = TRUE)}
#'     \item{area_text}{Geographic area name}
#'     \item{area_type_code}{Code indicating area type}
#'     \item{measure_text}{Type of measure (unemployment rate, labor force, employment, etc.)}
#'     \item{seasonal}{Seasonal adjustment status}
#'   }
#'
#' @details The function joins data from multiple BLS files:
#'   \itemize{
#'     \item Main data file (varies by geography selection)
#'     \item Series definitions (la.series)
#'     \item Area codes and names (la.area)
#'     \item Measure definitions (la.measure)
#'   }
#' @export
#' 
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr left_join
#' @importFrom dplyr select
#' @importFrom dplyr if_else
#' @importFrom stringr str_detect
#' @importFrom lubridate ym
#' 
#' @examples
#' \dontrun{
#' # Download state-level seasonally adjusted data (default)
#' laus_states <- get_laus()
#'
#' # Download unadjusted state data
#' laus_states_raw <- get_laus("state_unadjusted")
#'
#' # Download metro area data with rates as percentages
#' laus_metro <- get_laus("metro", transform = FALSE)
#'
#' # Download current state data only
#' laus_current <- get_laus("state_current_adjusted")
#'
#' # Warning: Large files - county and city data
#' # laus_counties <- get_laus("county")
#' # laus_cities <- get_laus("city")
#'
#' # Include annual data
#' laus_annual <- get_laus("state_adjusted", monthly_only = FALSE)
#'
#' # View unemployment rates by state for latest period
#' unemployment <- get_bls_data(laus_states)[grepl("rate", measure_text) & date == max(date)]
#' 
#' # Check for download issues
#' print_bls_warnings(laus_states)
#' }

get_laus <- function(geography = "state_adjusted", monthly_only = TRUE, transform = TRUE, suppress_warnings = FALSE) {
  
  # Define the URL mapping
  laus_urls <- list(
    "state_current_adjusted" = "https://download.bls.gov/pub/time.series/la/la.data.1.CurrentS",
    "state_unadjusted" = "https://download.bls.gov/pub/time.series/la/la.data.2.AllStatesU",
    "state_adjusted" = "https://download.bls.gov/pub/time.series/la/la.data.3.AllStatesS",
    "region_unadjusted" = "https://download.bls.gov/pub/time.series/la/la.data.4.RegionDivisionU",
    "region_adjusted" = "https://download.bls.gov/pub/time.series/la/la.data.5.RegionDivisionS",
    "metro" = "https://download.bls.gov/pub/time.series/la/la.data.60.Metro",
    "division" = "https://download.bls.gov/pub/time.series/la/la.data.61.Division",
    "micro" = "https://download.bls.gov/pub/time.series/la/la.data.62.Micro",
    "combined" = "https://download.bls.gov/pub/time.series/la/la.data.63.Combined",
    "county" = "https://download.bls.gov/pub/time.series/la/la.data.64.County",
    "city" = "https://download.bls.gov/pub/time.series/la/la.data.65.City"
  )
  
  # Validate geography argument
  if (!geography %in% names(laus_urls)) {
    stop("Invalid geography. Valid options are: ",
         paste(names(laus_urls), collapse = ", "))
  }
  
  # Warn about large files
  if (geography %in% c("city", "county")) {
    message("Warning: ", geography, " data file is very large (>300MB). Download may take several minutes.")
  }
  
  # Define all URLs we need to download
  download_urls <- c(
    "data" = laus_urls[[geography]],
    "series" = "https://download.bls.gov/pub/time.series/la/la.series",
    "area" = "https://download.bls.gov/pub/time.series/la/la.area",
    "measure" = "https://download.bls.gov/pub/time.series/la/la.measure"
  )
  
  # Download all files
  downloads <- download_bls_files(download_urls, suppress_warnings = suppress_warnings)
  
  # Extract data from downloads
  laus_import <- get_bls_data(downloads$data)
  laus_series <- get_bls_data(downloads$series)
  laus_area <- get_bls_data(downloads$area)
  laus_measure <- get_bls_data(downloads$measure)
  
  # Join all the data together
  laus <- laus_import |>
    dplyr::select(-footnote_codes) |>
    dplyr::left_join(laus_series |> dplyr::select(-footnote_codes), by = c("series_id")) |>
    dplyr::left_join(laus_area, by = c("area_code", "area_type_code")) |>
    dplyr::left_join(laus_measure, by = "measure_code") |>
    dplyr::mutate(value = as.numeric(value)) |>
    dplyr::filter(!is.na(value)) |>
    dplyr::select(-c(display_level:sort_sequence)) |>
    dplyr::select(-c(series_title:end_period))
  
  # Track processing steps
  processing_steps <- c(
    "Joined series, area, and measure metadata",
    "Converted values to numeric",
    "Removed rows with missing values"
  )
  
  # Handle monthly filtering and date creation
  if (monthly_only) {
    laus <- laus |>
      dplyr::filter(period != "M13") |>
      dplyr::mutate(date = lubridate::ym(paste(as.character(year), substr(period, 2, 3), sep = "-")))
    
    processing_steps <- c(processing_steps, "Filtered to monthly data only", "Created date column")
  }
  
  # Handle transformation
  if (transform) {
    laus <- laus |>
      dplyr::mutate(value = if_else(str_detect(measure_text, "rate")|str_detect(measure_text, "ratio"), value/100, value))
    
    processing_steps <- c(processing_steps, "Converted rates and ratios to proportions")
  }
  
  # Create the BLS data collection object
  result <- create_bls_object(
    data = laus,
    downloads = downloads,
    data_type = "LAUS",
    processing_steps = processing_steps
  )
  
  return(result)
}