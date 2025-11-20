#' Download State Alternative Labor Market Measures (SALT) Data
#'
#' This function downloads detailed alternative unemployment measures data from BLS,
#' including U-1 through U-6 measures. The data provides a more comprehensive view
#' of labor market conditions beyond the standard unemployment rate (U-3).
#'
#' @param only_states Logical. If TRUE (default), includes only state-level data.
#'   If FALSE, includes sub-state areas like New York City where available.
#' @param geometry Logical. If TRUE, uses tigris::states() to download shapefiles for the states 
#'   to include in the data. If FALSE (default), only returns data table.
#' @param suppress_warnings Logical. If TRUE (default), suppress individual download warnings and diagnostic messages
#'   for cleaner output during batch processing. If FALSE, returns the data and prints warnings and messages to the console.
#' @param return_diagnostics Logical. If TRUE, returns a bls_data_collection object
#'   with full diagnostics. If FALSE (default), returns just the data table.
#'
#' @return By default, returns a data.table with Alternative Measures of Labor Underutilization data. If return_diagnostics = TRUE,
#'   returns a bls_data_collection object containing data and comprehensive diagnostics.
#'   The function also adds derived measures and quartile comparisons across states.
#'
#' @export
#' @importFrom httr GET
#' @importFrom httr write_disk
#' @importFrom httr add_headers
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr left_join
#' @importFrom dplyr select
#' @importFrom dplyr across
#' @importFrom dplyr case_when
#' @importFrom dplyr rename_with
#' @importFrom dplyr lag
#' @importFrom dplyr group_by
#' @importFrom dplyr ungroup
#' @importFrom sf st_as_sf
#' @importFrom stringr str_remove
#' @importFrom stringr str_length
#' @importFrom stringr str_to_lower
#' @importFrom stringr str_replace_all
#' @importFrom lubridate yq
#' @importFrom tidyselect matches
#' @importFrom tidyselect starts_with
#' @importFrom tidyselect everything
#' @importFrom tigris states
#' @importFrom tigris shift_geometry
#' @importFrom zoo as.yearqtr
#' @importFrom readxl read_excel
#' @examples
#' \donttest{
#' # Download state-level SALT data
#' salt_data <- get_salt()
#'
#' # Include sub-state areas
#' salt_all <- get_salt(only_states = FALSE)
#'
#' # View latest U-6 rates by state
#' latest <- salt_df[date == max(date), .(state, u6)]
#' latest[order(-u6)]
#' 
#' # Download and display ratio of job losers to not job losers by state
#' get_salt(geometry = TRUE) |>
#'  dplyr::filter(date == max(date)) |> # To use only most current date
#'   ggplot2::ggplot() +
#'    ggplot2::geom_sf(ggplot2::aes(fill = losers_notlosers_ratio))
#' 
#' # Get full diagnostic object if needed
#' data_with_diagnostics <- get_salt(return_diagnostics = TRUE)
#' print_bls_warnings(data_with_diagnostics)
#' }
#' 

get_salt <- function(only_states = TRUE, geometry = FALSE, suppress_warnings = TRUE, return_diagnostics = FALSE) {
  
  salt_url <- "https://www.bls.gov/lau/stalt-moave.xlsx"
  
  headers <- c(
    "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    "Accept-Encoding" = "gzip, deflate, br",
    "Accept-Language" = "en-US,en;q=0.9",
    "Connection" = "keep-alive",
    "Host" = "www.bls.gov",
    "Referer" = "https://www.bls.gov/lau/",
    "Sec-Ch-Ua" = 'Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
    "Sec-Ch-Ua-Mobile" = "?0",
    "Sec-Ch-Ua-Platform" = '"Windows"',
    "Sec-Fetch-Dest" = "document",
    "Sec-Fetch-Mode" = "navigate",
    "Sec-Fetch-Site" = "same-origin",
    "Sec-Fetch-User" = "?1",
    "Upgrade-Insecure-Requests" = "1",
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  )
  
  # Download Excel file
  message("Downloading SALT data from BLS...\n")
  response <- httr::GET(salt_url, 
                        httr::write_disk(tf <- tempfile(fileext = ".xlsx")), 
                        httr::add_headers(.headers = headers))
  
  # Check for successful response
  httr::stop_for_status(response)
  
  # Track processing steps
  processing_steps <- character(0)
  
  # Read and process Excel file
  message("Processing SALT Excel file...\n")
  salt_data <- readxl::read_excel(tf, skip = 1) |>
    dplyr::rename_with(.fn = stringr::str_to_lower) |>
    dplyr::mutate(date = lubridate::yq(paste0(`end year`, `end quarter`))) |>
    dplyr::select(-c(record, `start year`, `start quarter`, `end year`, `end quarter`, `unique period`)) |>
    dplyr::mutate(dplyr::across(tidyselect::starts_with("u-"), function(x){x = x/100})) |>
    dplyr::rename_with(.cols = tidyselect::starts_with("u-"), .fn = stringr::str_remove, pattern = "-") |>
    dplyr::rename_with(.cols = tidyselect::everything(), .fn = stringr::str_replace_all, pattern = " ", replacement = "_") |>
    dplyr::mutate(not_job_losers = unemployed - job_losers,
                  unemployed_under_14_weeks = unemployed - `unemployed_15+_weeks`,
                  losers_notlosers_ratio = job_losers / not_job_losers,
                  u1b = u3-u1,
                  u2b = u3-u2,
                  u4b = discouraged_workers / (civilian_labor_force + discouraged_workers),
                  u4c = u4 - u4b,
                  marginally_attached_not_discouraged = all_marginally_attached - discouraged_workers,
                  u5b = marginally_attached_not_discouraged / (civilian_labor_force + marginally_attached_not_discouraged),
                  u5c = u5 - (discouraged_workers / (civilian_labor_force + discouraged_workers + marginally_attached_not_discouraged)) - u5b,
                  u6b = involuntary_part_time_employed / civilian_labor_force,
                  period_name = zoo::as.yearqtr(date))
  
  processing_steps <- c(processing_steps, "read_excel", "standardized_columns", "calculated_derived_measures")
  
  # Filter to states only if requested
  if (only_states | geometry) {
    salt_data <- salt_data |>
      dplyr::mutate(fips_len = stringr::str_length(fips)) |>
      dplyr::filter(fips_len == 2) |>
      dplyr::select(-fips_len)
    processing_steps <- c(processing_steps, "filtered_states_only")
  }
  
  # Add quartile comparisons and lagged values
  salt_data <- salt_data |>
    dplyr::group_by(date) |>
    dplyr::mutate(u1_25 = quantile(u1, probs = c(0.25), na.rm = TRUE),
                  u1_50 = median(u1, na.rm = TRUE),
                  u1_75 = quantile(u1, probs = c(0.75), na.rm = TRUE),
                  u2_25 = quantile(u2, probs = c(0.25), na.rm = TRUE),
                  u2_50 = median(u2, na.rm = TRUE),
                  u2_75 = quantile(u2, probs = c(0.75), na.rm = TRUE),
                  u3_25 = quantile(u3, probs = c(0.25), na.rm = TRUE),
                  u3_50 = median(u3, na.rm = TRUE),
                  u3_75 = quantile(u3, probs = c(0.75), na.rm = TRUE),
                  u4b_25 = quantile(u4b, probs = c(0.25), na.rm = TRUE),
                  u4b_50 = median(u4b, na.rm = TRUE),
                  u4b_75 = quantile(u4b, probs = c(0.75), na.rm = TRUE),
                  u5b_25 = quantile(u5b, probs = c(0.25), na.rm = TRUE),
                  u5b_50 = median(u5b, na.rm = TRUE),
                  u5b_75 = quantile(u5b, probs = c(0.75), na.rm = TRUE)
    ) |>
    dplyr::ungroup() |>
    dplyr::group_by(state) |>
    dplyr::mutate(
      dplyr::across(tidyselect::matches("^u[0-9]"),
                    .fns = function(x){dplyr::lag(x, 4)},
                    .names = "py_{.col}")
    ) |>
    dplyr::mutate(
      dplyr::across(tidyselect::matches("^u[0-9]"),
                    .fns = function(x){dplyr::lag(x, 1)},
                    .names = "pq_{.col}")
    ) |>
    dplyr::ungroup()
  
  processing_steps <- c(processing_steps, "added_quartile_comparisons", "added_lagged_values")
  
  if(geometry){
    shapes <- tigris::states() |>
      tigris::shift_geometry() |>
      select(NAME, geometry)
    
    salt_data <- salt_data |>
      dplyr::left_join(shapes, by = c("state"="NAME")) |>
      sf::st_as_sf()
    
    processing_steps <- c(processing_steps, "added U.S. state geometry")
  }
  
  # Clean up temporary file
  unlink(tf)
  
  # Create simple download info (since this is Excel, not using fread_bls)
  download_info <- list(
    "salt_excel" = list(
      url = salt_url,
      original_dimensions = dim(salt_data),
      final_dimensions = dim(salt_data),
      phantom_columns_detected = 0,
      phantom_column_names = character(0),
      cleaning_applied = FALSE,
      header_data_mismatch = FALSE,
      original_header_count = ncol(salt_data),
      final_data_count = ncol(salt_data),
      empty_columns_removed = 0,
      final_column_names = names(salt_data),
      warnings = character(0)
    )
  )
  
  # # Create BLS data collection object
  # result <- create_bls_object(
  #   data = salt_data,
  #   downloads = list("salt_excel" = list(diagnostics = download_info$salt_excel)),
  #   data_type = "SALT",
  #   processing_steps = processing_steps
  # )
  
  # Create the BLS data collection object
  bls_collection <- create_bls_object(
    data = salt_data,
    downloads = list("salt_excel" = list(diagnostics = download_info$salt_excel)),
    data_type = "SALT",
    processing_steps = processing_steps
  )
  
    # Display warnings if requested
  if (!suppress_warnings) {
    print_bls_warnings(bls_collection, detailed = FALSE)
  }
  
  # Return either the collection object or just the data
  if (return_diagnostics) {
    return(bls_collection)
  } else {
    return(salt_data)
  }
  
  # Print download complete, if warnings not disabled.
  if (!suppress_warnings) {
  message("SALT data download and processing complete.\n")
  message("Final dimensions:", paste(dim(salt_data), collapse = " x "), "\n")
  }
  
  return(result)
}