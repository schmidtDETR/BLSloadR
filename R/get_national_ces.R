#' Get National Current Employment Statistics (CES) Data from BLS
#'
#' This function downloads and processes national Current Employment Statistics (CES) 
#' data from the Bureau of Labor Statistics (BLS). It retrieves multiple related 
#' datasets and joins them together to create a comprehensive employment statistics 
#' dataset with industry classifications, data types, and time period information.
#'
#' @param monthly_only Logical. If TRUE (default), excludes annual averages 
#'   (period "M13") and returns only monthly data. If FALSE, includes all 
#'   periods including annual averages.
#' @param simplify_table Logical. If TRUE (default), removes several metadata 
#'   columns (series_title, begin_year, begin_period, end_year, end_period, 
#'   naics_code, publishing_status, display_level, selectable, sort_sequence) 
#'   and adds a formatted date column. If FALSE, returns the full dataset 
#'   with all available columns.
#' @param show_warnings Logical. If TRUE, displays download warnings 
#'   and diagnostics. If FALSE (default), suppresses warning output.
#' @param return_diagnostics Logical. If TRUE, returns a bls_data_collection object
#'   with full diagnostics. If FALSE (default), returns just the data table.
#'
#' @return By default, returns a data.table with CES data. If return_diagnostics = TRUE,
#'   returns a bls_data_collection object containing data and comprehensive diagnostics.
#'
#' @details 
#' The function downloads the following BLS CES datasets:
#' \itemize{
#'   \item ce.data.0.AllCESSeries - Main employment data
#'   \item ce.series - Series metadata
#'   \item ce.industry - Industry classifications  
#'   \item ce.datatype - Data type definitions
#'   \item ce.period - Time period definitions
#'   \item ce.supersector - Supersector classifications
#' }
#' 
#' These datasets are joined together to provide context and labels for the 
#' employment statistics. The function uses the `fread_bls()` helper function 
#' to download and read the BLS data files with robust error handling and 
#' diagnostic reporting.
#'
#' @note 
#' This function requires the following packages: dplyr, data.table, httr, and 
#' lubridate (for date formatting when simplify_table=TRUE). The `fread_bls()` 
#' and `create_bls_object()` helper functions must be available in your environment.
#'
#' @examples
#' \donttest{
#' # Get monthly CES data with simplified table structure
#' ces_monthly <- get_national_ces()
#' 
#' # Get all data including annual averages with full metadata
#' ces_full <- get_national_ces(monthly_only = FALSE, simplify_table = FALSE)
#' 
#' # Get monthly data but keep all metadata columns
#' ces_detailed <- get_national_ces(monthly_only = TRUE, simplify_table = FALSE)
#' 
#' # Access the data component
#' ces_data <- get_bls_data(ces_monthly)
#' 
#' # Get full diagnostic object if needed
#' data_with_diagnostics <- get_national_ces(return_diagnostics = TRUE)
#' print_bls_warnings(data_with_diagnostics)
#' }
#'
#'
#' @seealso 
#' Please visit the Bureau of Labor Statistics at https://www.bls.gov/ces/ for more information about CES data
#' 
#' @export
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr left_join
#' @importFrom dplyr select
#' @importFrom lubridate ym
get_national_ces <- function(monthly_only = TRUE, simplify_table = TRUE, 
                             show_warnings = FALSE, return_diagnostics = FALSE) {
  
  # Define URLs for all CES datasets
  ces_urls <- c(
    "data" = "https://download.bls.gov/pub/time.series/ce/ce.data.0.AllCESSeries",
    "series" = "https://download.bls.gov/pub/time.series/ce/ce.series",
    "industry" = "https://download.bls.gov/pub/time.series/ce/ce.industry",
    "period" = "https://download.bls.gov/pub/time.series/ce/ce.period",
    "datatype" = "https://download.bls.gov/pub/time.series/ce/ce.datatype",
    "supersector" = "https://download.bls.gov/pub/time.series/ce/ce.supersector"
  )
  
  # Download all files
  message("Downloading CES datasets...\n")
  downloads <- download_bls_files(ces_urls, suppress_warnings = !show_warnings)
  
  # Extract data from each download
  ces_data <- get_bls_data(downloads$data)
  ces_series <- get_bls_data(downloads$series)
  ces_industry <- get_bls_data(downloads$industry)
  ces_period <- get_bls_data(downloads$period)
  ces_datatype <- get_bls_data(downloads$datatype)
  ces_supersector <- get_bls_data(downloads$supersector)
  
  # Track processing steps
  processing_steps <- character(0)
  
  # Join all datasets together
  message("Joining CES datasets...\n")
  ces_full <- ces_data |>
    dplyr::select(-footnote_codes) |>
    dplyr::left_join(ces_series, by = "series_id") |>
    dplyr::select(-footnote_codes) |>
    dplyr::left_join(ces_industry, by = "industry_code") |>
    dplyr::left_join(ces_period, by = "period") |>
    dplyr::left_join(ces_datatype, by = "data_type_code") |>
    dplyr::left_join(ces_supersector, by = "supersector_code")
  
  processing_steps <- c(processing_steps, "joined_all_datasets")
  
  # Filter to monthly data only if requested
  if (monthly_only) {
    ces_full <- ces_full |>
      dplyr::filter(period != "M13")
    processing_steps <- c(processing_steps, "filtered_monthly_only")
  }
  
  # Simplify table structure if requested
  if (simplify_table) {
    ces_full <- ces_full |>
      dplyr::select(-c(series_title, begin_year, begin_period, end_year, end_period, 
                       naics_code, publishing_status, display_level, selectable, sort_sequence)) |>
      dplyr::mutate(date = lubridate::ym(paste0(year, period)))
    processing_steps <- c(processing_steps, "simplified_table", "added_date_column")
  }
  
  # Create the BLS data collection object
  bls_collection <- create_bls_object(
    data = ces_full,
    downloads = downloads,
    data_type = "CES",
    processing_steps = processing_steps
  )

  # Display warnings if requested
  if (show_warnings) {
    print_bls_warnings(bls_collection)
  }
    
  # Return either the collection object or just the data
  if (return_diagnostics) {
    return(bls_collection)
  } else {
    return(ces_full)
  }
  
  message("CES data download and processing complete.\n")
  message("Final dimensions:", paste(dim(ces_full), collapse = " x "), "\n")
  
  return(result)
}