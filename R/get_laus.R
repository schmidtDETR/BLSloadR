#' Download Local Area Unemployment Statistics (LAUS) Data
#'
#' @description This function downloads Local Area Unemployment Statistics data from the U.S. Bureau
#'  of Labor Statistics. Due to the large size of some LAUS datasets (county and city
#'  files are >300MB), users must specify which geographic level to download. The function
#'  provides access to both seasonally adjusted and unadjusted data at various geographic levels. 
#'  Additional datasets provide comprehensive non-seasonally-adjusted data for all areas broken out 
#'  in 5-year increments
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
#'     \item "1990-1994" - Comprehensive unadjusted data for 1990-1994
#'     \item "1995-1999" - Comprehensive unadjusted data for 1995-1999
#'     \item "2000-2004" - Comprehensive unadjusted data for 2000-2004
#'     \item "2005-2009" - Comprehensive unadjusted data for 2005-2009
#'     \item "2010-2014" - Comprehensive unadjusted data for 2010-2014
#'     \item "2015-2019" - Comprehensive unadjusted data for 2015-2019
#'     \item "2020-2024" - Comprehensive unadjusted data for 2020-2024
#'     \item "2025-2029" - Comprehensive unadjusted data for 2025-2029
#'     \item "ST" - Any state two-character USPS abbreviation, plus DC and PR
#'   }
#' @param monthly_only Logical. If TRUE (default), excludes annual data (period M13)
#'   and creates a date column from year and period.
#' @param transform Logical. If TRUE (default), converts rate and ratio measures from
#'   percentages to proportions by dividing by 100. Unemployment rates will be expressed
#'   as decimals (e.g., 0.05 for 5\% unemployment) rather than as whole numbers (e.g. 5).
#' @param suppress_warnings Logical. If TRUE, suppress individual download warnings
#'   for cleaner output during batch processing.
#' @param return_diagnostics Logical. If TRUE, returns a bls_data_collection object
#'   with full diagnostics. If FALSE (default), returns just the data table.
#'
#' @return By default, returns a data.table with LAUS data. If return_diagnostics = TRUE,
#'   returns a bls_data_collection object containing LAUS data with the following key columns:
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
#' # Download state-level seasonally adjusted data (default operation)
#' laus_states <- get_laus()
#'
#' # Download unadjusted state data
#' laus_states_raw <- get_laus("state_unadjusted")
#'
#' # Download metro area data with rates as whole number percentages (64.3 instead of 0.643)
#' laus_metro <- get_laus("metro", transform = FALSE)
#'
#' # Get full diagnostic object if needed
#' laus_with_diagnostics <- get_laus(return_diagnostics = TRUE)
#' print_bls_warnings(laus_with_diagnostics)
#'
#' # Warning: Large files - county and city data
#' # laus_counties <- get_laus("county")
#' # laus_cities <- get_laus("city")
#'
#' # View unemployment rates by state for latest period
#' unemployment <- laus_states[grepl("rate", measure_text) & date == max(date)]
#' }

get_laus <- function(geography = "state_adjusted", monthly_only = TRUE, transform = TRUE, 
                     suppress_warnings = FALSE, return_diagnostics = FALSE) {
  
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
    "city" = "https://download.bls.gov/pub/time.series/la/la.data.65.City",
    "2025-2029" = "https://download.bls.gov/pub/time.series/la/la.data.0.CurrentU25-29",
    "2020-2024" = "https://download.bls.gov/pub/time.series/la/la.data.0.CurrentU20-24",
    "2015-2019" = "https://download.bls.gov/pub/time.series/la/la.data.0.CurrentU15-19",
    "2010-2014" = "https://download.bls.gov/pub/time.series/la/la.data.0.CurrentU10-14",
    "2005-2009" = "https://download.bls.gov/pub/time.series/la/la.data.0.CurrentU05-09",
    "2000-2004" = "https://download.bls.gov/pub/time.series/la/la.data.0.CurrentU00-04",
    "1995-1999" = "https://download.bls.gov/pub/time.series/la/la.data.0.CurrentU95-99",
    "1990-1994" = "https://download.bls.gov/pub/time.series/la/la.data.0.CurrentU90-94",
    'AR' = 'https://download.bls.gov/pub/time.series/la/la.data.10.Arkansas',
    'CA' = 'https://download.bls.gov/pub/time.series/la/la.data.11.California',
    'CO' = 'https://download.bls.gov/pub/time.series/la/la.data.12.Colorado',
    'CT' = 'https://download.bls.gov/pub/time.series/la/la.data.13.Connecticut',
    'DE' = 'https://download.bls.gov/pub/time.series/la/la.data.14.Delaware',
    'DC' = 'https://download.bls.gov/pub/time.series/la/la.data.15.DC',
    'FL' = 'https://download.bls.gov/pub/time.series/la/la.data.16.Florida',
    'GA' = 'https://download.bls.gov/pub/time.series/la/la.data.17.Georgia',
    'HI' = 'https://download.bls.gov/pub/time.series/la/la.data.18.Hawaii',
    'ID' = 'https://download.bls.gov/pub/time.series/la/la.data.19.Idaho',
    'IL' = 'https://download.bls.gov/pub/time.series/la/la.data.20.Illinois',
    'IN' = 'https://download.bls.gov/pub/time.series/la/la.data.21.Indiana',
    'IA' = 'https://download.bls.gov/pub/time.series/la/la.data.22.Iowa',
    'KS' = 'https://download.bls.gov/pub/time.series/la/la.data.23.Kansas',
    'KY' = 'https://download.bls.gov/pub/time.series/la/la.data.24.Kentucky',
    'LA' = 'https://download.bls.gov/pub/time.series/la/la.data.25.Louisiana',
    'ME' = 'https://download.bls.gov/pub/time.series/la/la.data.26.Maine',
    'MD' = 'https://download.bls.gov/pub/time.series/la/la.data.27.Maryland',
    'MA' = 'https://download.bls.gov/pub/time.series/la/la.data.28.Massachusetts',
    'MI' = 'https://download.bls.gov/pub/time.series/la/la.data.29.Michigan',
    'MN' = 'https://download.bls.gov/pub/time.series/la/la.data.30.Minnesota',
    'MS' = 'https://download.bls.gov/pub/time.series/la/la.data.31.Mississippi',
    'MO' = 'https://download.bls.gov/pub/time.series/la/la.data.32.Missouri',
    'MT' = 'https://download.bls.gov/pub/time.series/la/la.data.33.Montana',
    'NE' = 'https://download.bls.gov/pub/time.series/la/la.data.34.Nebraska',
    'NV' = 'https://download.bls.gov/pub/time.series/la/la.data.35.Nevada',
    'NH' = 'https://download.bls.gov/pub/time.series/la/la.data.36.NewHampshire',
    'NJ' = 'https://download.bls.gov/pub/time.series/la/la.data.37.NewJersey',
    'NM' = 'https://download.bls.gov/pub/time.series/la/la.data.38.NewMexico',
    'NY' = 'https://download.bls.gov/pub/time.series/la/la.data.39.NewYork',
    'NC' = 'https://download.bls.gov/pub/time.series/la/la.data.40.NorthCarolina',
    'ND' = 'https://download.bls.gov/pub/time.series/la/la.data.41.NorthDakota',
    'OH' = 'https://download.bls.gov/pub/time.series/la/la.data.42.Ohio',
    'OK' = 'https://download.bls.gov/pub/time.series/la/la.data.43.Oklahoma',
    'OR' = 'https://download.bls.gov/pub/time.series/la/la.data.44.Oregon',
    'PA' = 'https://download.bls.gov/pub/time.series/la/la.data.45.Pennsylvania',
    'PR' = 'https://download.bls.gov/pub/time.series/la/la.data.46.PuertoRico',
    'RI' = 'https://download.bls.gov/pub/time.series/la/la.data.47.RhodeIsland',
    'SC' = 'https://download.bls.gov/pub/time.series/la/la.data.48.SouthCarolina',
    'SD' = 'https://download.bls.gov/pub/time.series/la/la.data.49.SouthDakota',
    'TN' = 'https://download.bls.gov/pub/time.series/la/la.data.50.Tennessee',
    'TX' = 'https://download.bls.gov/pub/time.series/la/la.data.51.Texas',
    'UT' = 'https://download.bls.gov/pub/time.series/la/la.data.52.Utah',
    'VT' = 'https://download.bls.gov/pub/time.series/la/la.data.53.Vermont',
    'VA' = 'https://download.bls.gov/pub/time.series/la/la.data.54.Virginia',
    'WA' = 'https://download.bls.gov/pub/time.series/la/la.data.56.Washington',
    'WV' = 'https://download.bls.gov/pub/time.series/la/la.data.57.WestVirginia',
    'WI' = 'https://download.bls.gov/pub/time.series/la/la.data.58.Wisconsin',
    'WY' = 'https://download.bls.gov/pub/time.series/la/la.data.59.Wyoming',
    'AL' = 'https://download.bls.gov/pub/time.series/la/la.data.7.Alabama',
    'AK' = 'https://download.bls.gov/pub/time.series/la/la.data.8.Alaska',
    'AZ' = 'https://download.bls.gov/pub/time.series/la/la.data.9.Arizona'
  )
  
  # Validate geography argument
  if (!geography %in% names(laus_urls)) {
    stop("Invalid geography. Valid options are: ",
         paste(names(laus_urls), collapse = ", "))
  }
  
  # Warn about large files
  if (geography %in% c("city", "county")) {
    message("Warning: ", geography, " data file is very large (>300MB).")
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
  bls_collection <- create_bls_object(
    data = laus,
    downloads = downloads,
    data_type = "LAUS",
    processing_steps = processing_steps
  )
  
  # Show warnings if any issues were detected
  if (has_bls_issues(bls_collection) && !suppress_warnings) {
    print_bls_warnings(bls_collection)
  }
  
  # Return either the collection object or just the data
  if (return_diagnostics) {
    return(bls_collection)
  } else {
    return(laus)
  }
}