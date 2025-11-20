#' Download Occupational Employment and Wage Statistics (OEWS) Data
#'
#' This function downloads and joins together occupational employment and wage data
#' from the Bureau of Labor Statistics OEWS program. The data includes employment
#' and wage estimates by occupation and geographic area.
#'
#' @param suppress_warnings Logical. If TRUE (default), suppress individual download warnings and diagnostic messages
#'   for cleaner output during batch processing. If FALSE, returns the data and prints warnings and messages to the console.
#' @param return_diagnostics Logical. If TRUE, returns a bls_data_collection object
#'   with full diagnostics. If FALSE (default), returns just the data table.
#'
#' @return By default, returns a data.table with OEWS data. If return_diagnostics = TRUE,
#'   returns a bls_data_collection object containing data and comprehensive diagnostics.
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
#' unique(oews_data$occupation_title)
#'
#' # Filter for specific occupation
#' software_devs <- oews_data[grepl("Software", occupation_title)]
#' 
#' # Get full diagnostic object if needed
#' oews_with_diagnostics <- get_oews(return_diagnostics = TRUE)
#' print_bls_warnings(oews_with_diagnostics)
#'}
#'

get_oews <- function(suppress_warnings = TRUE, return_diagnostics = FALSE) {
  
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
    dplyr::left_join(oews_series) |>
    dplyr::left_join(oews_occupation) |>
    dplyr::left_join(oews_area) |>
    dplyr::left_join(oews_datatype) |>
    dplyr::mutate(value = as.numeric(value))
  
  # Track processing steps
  processing_steps <- c(
    "Joined series, occupation, area, and datatype metadata",
    "Converted values to numeric"
  )
  
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