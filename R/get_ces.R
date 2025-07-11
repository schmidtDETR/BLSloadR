#' Download Current Employment Statistics (CES) Data
#'
#' This function downloads Current Employment Statistics data from the Bureau of Labor Statistics.
#' The data includes national, regional, state, and substate employment statistics.
#' By default, all available areas, data types, and periods are included.
#'
#' @param transform Logical. If TRUE (default), converts employment values from thousands
#'   to actual counts by multiplying by 1000 for specific data types (codes 1, 6, 26)
#'   and removes ", In Thousands" from data type labels.
#' @param monthly_only Logical. If TRUE (default), filters out annual data (period M13).
#' @param simplify_table Logical. If TRUE (default), removes excess columns and creates 
#'   a date column from Year and Period in the original data.
#' @param suppress_warnings Logical. If FALSE (default), prints warnings for any BLS 
#'   download issues. If TRUE, warnings are suppressed but still returned invisibly.
#' @param return_diagnostics Logical. If FALSE (default), returns only the data. If TRUE,
#'   returns the full bls_data_collection object with diagnostics.
#'
#' @return By default, returns a data.table with CES data. If return_diagnostics = TRUE,
#'   returns a bls_data_collection object containing data and comprehensive diagnostics.
#'
#' @export
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr left_join
#' @importFrom dplyr select
#' @importFrom stringr str_remove
#' @examples
#' \dontrun{
#' # Download CES data (streamlined approach)
#' ces_data <- get_ces()
#'
#' # Download with full diagnostics if needed
#' ces_result <- get_ces(return_diagnostics = TRUE)
#' ces_data <- get_bls_data(ces_result)
#' 
#' # Check for download issues
#' if (has_bls_issues(ces_result)) {
#'   print_bls_warnings(ces_result)
#' }
#' }
get_ces <- function(transform = TRUE, monthly_only = TRUE, simplify_table = TRUE, 
                    suppress_warnings = FALSE, return_diagnostics = FALSE) {
  
  # Define URLs for CES data files
  ces_urls <- c(
    "Main Data" = "https://download.bls.gov/pub/time.series/sm/sm.data.1.AllData",
    "Series Metadata" = "https://download.bls.gov/pub/time.series/sm/sm.series",
    "Industry Codes" = "https://download.bls.gov/pub/time.series/sm/sm.industry",
    "State Codes" = "https://download.bls.gov/pub/time.series/sm/sm.state",
    "Area Codes" = "https://download.bls.gov/pub/time.series/sm/sm.area",
    "Data Types" = "https://download.bls.gov/pub/time.series/sm/sm.data_type",
    "Supersector Codes" = "https://download.bls.gov/pub/time.series/sm/sm.supersector"
  )
  
  # Download all files
  cat("Starting CES data download...\n")
  downloads <- download_bls_files(ces_urls, suppress_warnings = suppress_warnings)
  
  # Extract data from downloads
  data_main <- get_bls_data(downloads$`Main Data`)
  data_series <- get_bls_data(downloads$`Series Metadata`)
  data_industry <- get_bls_data(downloads$`Industry Codes`)
  data_state <- get_bls_data(downloads$`State Codes`)
  data_area <- get_bls_data(downloads$`Area Codes`)
  data_types <- get_bls_data(downloads$`Data Types`)
  data_supersector <- get_bls_data(downloads$`Supersector Codes`)
  
  # Track processing steps
  processing_steps <- character(0)
  
  # Combine all data
  cat("Combining datasets...\n")
  ces_data <- data_main |> 
    dplyr::select(-footnote_codes) |>
    dplyr::left_join(data_series, by = "series_id") |>  
    #dplyr::select(-footnote_codes) |>
    dplyr::left_join(data_industry, by = "industry_code") |>
    dplyr::left_join(data_state, by = "state_code") |>
    dplyr::left_join(data_area, by = "area_code") |>
    dplyr::left_join(data_types, by = "data_type_code") |>
    dplyr::left_join(data_supersector, by = "supersector_code") |>
    dplyr::mutate(value = as.numeric(value),
                  industry_code = substr(series_id,11,18)) |>
    dplyr::filter(!is.na(value))
  
  processing_steps <- c(processing_steps, "joined_metadata", "converted_values", "removed_na")
  
  if(transform){
    cat("Applying value transformations...\n")
    ces_data <- ces_data |>
      dplyr::mutate(
        value = if_else(
          data_type_code %in% c("01","06","26"),
          value * 1000,
          value
        ),
        data_type_text = stringr::str_remove(data_type_text, ", In Thousands")
      )
    processing_steps <- c(processing_steps, "transformed_values")
  }
  
  if(monthly_only){
    cat("Filtering to monthly data only...\n")
    ces_data <- ces_data |>
      dplyr::filter(period != "M13")
    processing_steps <- c(processing_steps, "monthly_only")
  }
  
  if(simplify_table){
    cat("Simplifying table structure...\n")
    ces_data <- ces_data |>
      dplyr::mutate(date = lubridate::ym(paste0(year,period))) |>
      dplyr::select(-c(benchmark_year:end_period,year,period)) |>
      dplyr::filter(state_code != "00")
    processing_steps <- c(processing_steps, "simplified_table", "added_date_column")
  }
  
  # Create BLS data object with diagnostics
  result <- create_bls_object(
    data = ces_data,
    downloads = downloads,
    data_type = "CES",
    processing_steps = processing_steps
  )
  
  # Print summary
  cat("CES data download complete!\n")
  cat("Final dataset dimensions:", paste(dim(ces_data), collapse = " x "), "\n")
  
  if (has_bls_issues(result)) {
    if (!suppress_warnings) {
      cat("\nDownload Issues Summary:\n")
      cat("Total warnings:", result$summary$total_warnings, "\n")
      cat("Files with issues:", result$summary$files_with_issues, "of", result$summary$files_downloaded, "\n")
      cat("Run with return_diagnostics = TRUE and use print_bls_warnings() for details\n")
    }
  } else {
    cat("No download issues detected.\n")
  }
  
  # Return based on user preference
  if (return_diagnostics) {
    return(result)
  } else {
    # Store diagnostics as attributes for later access if needed
    attr(ces_data, "bls_diagnostics") <- result
    return(ces_data)
  }
}