#' Download Occupational Employment and Wage Statistics (OEWS) Data
#'
#' This function downloads and joins together occupational employment and wage data
#' from the Bureau of Labor Statistics OEWS program. The data includes employment
#' and wage estimates by occupation and geographic area. Note that OEWS is a large data set (over 6 million rows), so it will require longer to download.
#'
#' @param simplify_table Logical.  If TRUE (default), remove columns from the result that are internal BLS references or can be derived from other elements in the table.
#' @param suppress_warnings Logical. If TRUE (default), suppress individual download warnings and diagnostic messages
#'   for cleaner output during batch processing. If FALSE, returns the data and prints warnings and messages to the console.
#' @param return_diagnostics Logical. If TRUE, returns a bls_data_collection object
#'   with full diagnostics. If FALSE (default), returns just the data table.
#'
#' @return By default, returns a data.table with OEWS data. If return_diagnostics = TRUE,
#'   returns a bls_data_collection object containing data and comprehensive diagnostics. The columns in the returned data frame when `simplify_table = TRUE` are listed below.  Unless otherwise specified, all data is returned as a character string to preserve the value of leading and trailing zeroes.
#'  \itemize{
#'     \item series_id - The unique OEWS series identifier.
#'     \item year - The year to which the estimate refers.  Because OEWS is not time series data, this is always the most recent year.
#'     \item value - Numeric. The value of the given data type, for the given area, in the given industry and occupation.
#'     \item seasonal - Whether or not the data is seasonally adjusted.
#'     \item areatype_code - Code representing the type of area (National ("N"), Statewide ("S"), or Local ("M")).
#'     \item industry_code - NAICS code of the industry.
#'     \item occupation_code - SOC code of the occupation. Description given by occupation_name.
#'     \item datatype_code - Lookup code for the data type of a given row.  Description given by datatype_name.
#'     \item state_code - Two-digit FIPS code for the state.
#'     \item area_code - The unique OEWS code for a substate area. Description given by area_name.
#'     \item series_title - Descriptive title of the full series ID.
#'     \item occupation_name - The text description of the occupation.
#'     \item occupation_description - More detailed description of the tasks associated with the occupation.
#'     \item area_name - The text description of the area.
#'     \item datatype_name - The text description of the type of data represented by `value`.
#'     
#'   }
#' @export
#'   
#' @export
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr left_join
#' @importFrom dplyr select
#' @examples
#' \donttest{
#' # Download current OEWS data
#' oews_data <- get_oews()
#'
#' # View available occupations
#' unique(oews_data$occupation_name)
#'
#' # Filter for specific occupation
#' software_devs <- oews_data[grepl("Software", occupation_name)]
#' 
#' # Get full diagnostic object if needed
#' oews_with_diagnostics <- get_oews(return_diagnostics = TRUE)
#' print_bls_warnings(oews_with_diagnostics)
#'}
#'

get_oews <- function(simplify_table = TRUE, suppress_warnings = TRUE, return_diagnostics = FALSE) {
  
  # Define all URLs we need to download
  download_urls <- c(
    "data" = "https://download.bls.gov/pub/time.series/oe/oe.data.0.Current",
    "series" = "https://download.bls.gov/pub/time.series/oe/oe.series",
    "occupation" = "https://download.bls.gov/pub/time.series/oe/oe.occupation",
    "area" = "https://download.bls.gov/pub/time.series/oe/oe.area",
    "datatype" = "https://download.bls.gov/pub/time.series/oe/oe.datatype"
  )
  
  # Download all files
  downloads <- download_bls_files(download_urls, suppress_warnings = suppress_warnings)
  
  # Extract data from downloads
  oews_current <- get_bls_data(downloads$data)
  oews_series <- get_bls_data(downloads$series)
  oews_occupation <- get_bls_data(downloads$occupation)
  oews_area <- get_bls_data(downloads$area)
  oews_datatype <- get_bls_data(downloads$datatype)
  
  # Join all the data together
  oews <- oews_current |> 
    dplyr::select(-footnote_codes) |>
    dplyr::left_join(oews_series, by = "series_id") |>
    dplyr::left_join(oews_occupation, by = "occupation_code") |>
    dplyr::left_join(oews_area, by = c("areatype_code", "state_code", "area_code")) |>
    dplyr::left_join(oews_datatype, by = "datatype_code") |>
    dplyr::mutate(value = as.numeric(value))
  
  # Track processing steps
  processing_steps <- c(
    "Joined series, occupation, area, and datatype metadata",
    "Converted values to numeric"
  )
  
  if(simplify_table){
    oews <- oews |> 
      dplyr::select(-c(period, sector_code, footnote_codes, begin_year, begin_period, end_year, end_period, selectable, sort_sequence, display_level))
    
    processing_steps <- c(processing_steps, "Removed columns per simplify_table.")
  }
  
  # Create the BLS data collection object
  bls_collection <- create_bls_object(
    data = oews,
    downloads = downloads,
    data_type = "OEWS",
    processing_steps = processing_steps
  )

  # Return either the collection object or just the data
  if (return_diagnostics) {
    return(bls_collection)
  } else {
    return(oews)
  }
  
  return(result)
}