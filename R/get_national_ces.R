#' Get National Current Employment Statistics (CES) Data from BLS
#'
#' This function downloads and processes national Current Employment Statistics (CES)
#' data from the Bureau of Labor Statistics (BLS). It retrieves multiple related
#' datasets and joins them together to create a comprehensive employment statistics
#' dataset with industry classifications, data types, and time period information.
#'
#' @param dataset_filter Character string specifying which dataset to download.
#'   Options include:
#'   \itemize{
#'     \item "all_data" (default) - Complete dataset with all series
#'     \item "current_seasonally_adjusted" - Only seasonally adjusted all-employee series
#'     \item "real_earnings_all_employees" - Real earnings data for all employees
#'     \item "real_earnings_production" - Real earnings data for production employees
#'   }
#' @param monthly_only Logical. If TRUE (default), excludes annual averages
#'   (period "M13") and returns only monthly data. If FALSE, includes all
#'   periods including annual averages.
#' @param simplify_table Logical. If TRUE (default), removes several metadata
#'   columns (series_title, begin_year, begin_period, end_year, end_period,
#'   naics_code, publishing_status, display_level, selectable, sort_sequence)
#'   and adds a formatted date column. If FALSE, returns the full dataset
#'   with all available columns.
#' @param suppress_warnings Logical. If TRUE (default), suppresses download warnings
#'   and diagnostics. If FALSE, displays warning output and diagnostic information.
#' @param return_diagnostics Logical. If TRUE, returns a bls_data_collection object
#'   with full diagnostics. If FALSE (default), returns just the data table.
#' @param cache Logical.  If TRUE, will download a cached file from BLS server and update cache if BLS server indicates an updated file.
#'
#' @return By default, returns a data.table with CES data. If return_diagnostics = TRUE,
#'   returns a bls_data_collection object containing data and comprehensive diagnostics.
#'
#' @details
#' The function can download one of four specialized national CES datasets based on
#' the dataset_filter parameter:
#' \itemize{
#'   \item all_data: Complete dataset (ce.data.0.AllCESSeries) - contains entire
#'     history of all series currently published by the CES program
#'   \item current_seasonally_adjusted: (ce.data.01a.CurrentSeasAE) - contains
#'     every seasonally adjusted all employee series and complete history
#'   \item real_earnings_all_employees: (ce.data.02b.AllRealEarningsAE) - contains
#'     real earnings data (1982-84 dollars) for all employees
#'   \item real_earnings_production: (ce.data.03c.AllRealEarningsPE) - contains
#'     real earnings data (1982-84 dollars) for production/nonsupervisory employees
#' }
#'
#' Additional metadata files are always downloaded and joined:
#' \itemize{
#'   \item ce.series - Series metadata
#'   \item ce.industry - Industry classifications
#'   \item ce.datatype - Data type definitions
#'   \item ce.period - Time period definitions
#'   \item ce.supersector - Supersector classifications
#' }
#'
#' These datasets are joined together to provide context and labels for the
#' employment statistics. The function uses the enhanced `download_bls_files()`
#' helper function for robust downloads with diagnostic reporting.
#'
#' Performance Note: Using specialized datasets (other than "all_data") can
#' significantly reduce download time and file size while still providing
#' comprehensive employment statistics.
#'
#' @note
#' This function requires the following packages: dplyr, data.table, httr, and
#' lubridate (for date formatting when simplify_table=TRUE). The `fread_bls()`
#' and `create_bls_object()` helper functions must be available in your environment.
#'
#' @examples
#' \donttest{
#' # Get complete monthly CES data with simplified table structure (default)
#' ces_monthly <- get_national_ces()
#'
#' # Get only seasonally adjusted data (faster download)
#' ces_seasonal <- get_national_ces(dataset_filter = "current_seasonally_adjusted")
#'
#' # Get real earnings data for all employees
#' ces_real_earnings <- get_national_ces(dataset_filter = "real_earnings_all_employees")
#'
#' # Get all data including annual averages with full metadata
#' ces_full <- get_national_ces(dataset_filter = "all_data",
#'                              monthly_only = FALSE, simplify_table = FALSE)
#'
#' # Get data with warnings and diagnostic information displayed
#' ces_with_warnings <- get_national_ces(suppress_warnings = FALSE)
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
get_national_ces <- function(dataset_filter = "all_data", monthly_only = TRUE,
                             simplify_table = TRUE, suppress_warnings = TRUE,
                             return_diagnostics = FALSE, cache = FALSE) {

  # Validate dataset_filter parameter
  valid_filters <- c("all_data", "current_seasonally_adjusted",
                     "real_earnings_all_employees", "real_earnings_production")
  if (!dataset_filter %in% valid_filters) {
    stop("Invalid dataset_filter. Must be one of: ", paste(valid_filters, collapse = ", "))
  }

  # Define dataset-specific URLs
  if (dataset_filter == "all_data") {
    data_url <- "https://download.bls.gov/pub/time.series/ce/ce.data.0.AllCESSeries"
    dataset_name <- "Complete national CES dataset"
  } else if (dataset_filter == "current_seasonally_adjusted") {
    data_url <- "https://download.bls.gov/pub/time.series/ce/ce.data.01a.CurrentSeasAE"
    dataset_name <- "Seasonally adjusted all-employee series"
  } else if (dataset_filter == "real_earnings_all_employees") {
    data_url <- "https://download.bls.gov/pub/time.series/ce/ce.data.02b.AllRealEarningsAE"
    dataset_name <- "Real earnings for all employees"
  } else if (dataset_filter == "real_earnings_production") {
    data_url <- "https://download.bls.gov/pub/time.series/ce/ce.data.03c.AllRealEarningsPE"
    dataset_name <- "Real earnings for production employees"
  }

  # Define URLs for all CES datasets
  ces_urls <- c(
    "data" = data_url,
    "series" = "https://download.bls.gov/pub/time.series/ce/ce.series",
    "industry" = "https://download.bls.gov/pub/time.series/ce/ce.industry",
    "period" = "https://download.bls.gov/pub/time.series/ce/ce.period",
    "datatype" = "https://download.bls.gov/pub/time.series/ce/ce.datatype",
    "supersector" = "https://download.bls.gov/pub/time.series/ce/ce.supersector"
  )

  # Download all files
  message("Downloading national CES datasets (", dataset_name, ")...")
  downloads <- download_bls_files(ces_urls, suppress_warnings = suppress_warnings, cache = cache)

  # Extract data from each download
  ces_data <- get_bls_data(downloads[["data"]])
  ces_series <- get_bls_data(downloads[["series"]])
  ces_industry <- get_bls_data(downloads[["industry"]])
  ces_period <- get_bls_data(downloads[["period"]])
  ces_datatype <- get_bls_data(downloads[["datatype"]])
  ces_supersector <- get_bls_data(downloads[["supersector"]])

  # Track processing steps
  processing_steps <- character(0)

  # Join all datasets together
  message("Joining CES datasets...")
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
    data_type = paste("National CES:", dataset_name),
    processing_steps = processing_steps
  )

  # Display warnings if requested
  if (!suppress_warnings) {
    print_bls_warnings(bls_collection)
  }

  message("National CES data download complete!")
  message("Dataset: ", dataset_name)
  message("Final dataset dimensions: ", paste(dim(ces_full), collapse = " x "))

  # Return either the collection object or just the data
  if (return_diagnostics) {
    return(bls_collection)
  } else {
    return(ces_full)
  }
}
