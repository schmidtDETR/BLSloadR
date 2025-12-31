#' Download Job Openings and Labor Turnover Survey (JOLTS) Data
#'
#' This function downloads Job Openings and Labor Turnover data from the U.S. Bureau
#' of Labor Statistics. JOLTS data provides insights into job market dynamics including
#' job openings, hires, separations, quits, and layoffs. Data is available at national,
#' regional, and state levels with various industry and size class breakdowns.
#'
#' @param monthly_only Logical. If TRUE (default), excludes annual data (period M13)
#'   and includes only monthly observations.
#' @param remove_regions Logical. If TRUE (default), excludes regional aggregates
#'   (Midwest, Northeast, South, West) identified by state codes MW, NE, SO, WE.
#' @param remove_national Logical. If TRUE (default), excludes national-level data
#'   (state code 00). Set to FALSE to include national data with industry and
#'   size class breakdowns.
#' @param suppress_warnings Logical. If TRUE (default), suppress individual download warnings and diagnostic messages
#'   for cleaner output during batch processing. If FALSE, returns the data and prints warnings and messages to the console.
#' @param return_diagnostics Logical. If TRUE, returns a bls_data_collection object
#'   with full diagnostics. If FALSE (default), returns just the data table.
#' @param cache Logical.  If TRUE, will download a cached file from BLS server and update cache if BLS server indicates an updated file.
#'
#' @return By default, returns a data.table with JOLTS data. If return_diagnostics = TRUE,
#'   returns a bls_data_collection object containing JOLTS data with the following key columns:
#'   \describe{
#'     \item{series_id}{BLS series identifier}
#'     \item{year}{Year of observation}
#'     \item{period}{Time period (M01-M12 for months)}
#'     \item{value}{JOLTS statistic value (transformed based on data type)}
#'     \item{date}{Date of observation}
#'     \item{state_text}{State name}
#'     \item{dataelement_text}{Type of JOLTS measure (job openings, hires, separations, etc.)}
#'     \item{area_text}{Geographic area description}
#'     \item{sizeclass_text}{Establishment size class}
#'     \item{industry_text}{Industry classification}
#'     \item{ratelevel_code}{Whether the value is a "Level" (count) or "Rate" (percentage)}
#'     \item{periodname}{Month name}
#'   }
#'
#' @details The function performs several data transformations:
#'   \itemize{
#'     \item Converts rate values to proportions (divides by 100) except for Unemployed to Job Opening ratio.
#'     \item Converts level values to actual counts (multiplies by 1000)
#'     \item Creates a proper date column from year and period
#'     \item Adds readable month names
#'   }
#'
#' @export
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr left_join
#' @importFrom dplyr select
#' @importFrom dplyr case_when
#' @importFrom lubridate ym
#' @examples
#' \donttest{
#' # Download state-level JOLTS data (default - returns data directly)
#' jolts_data <- get_jolts()
#'
#' # Include national data with industry breakdowns
#' jolts_national <- get_jolts(remove_national = FALSE)
#'
#' # Get full diagnostic object if needed
#' jolts_with_diagnostics <- get_jolts(return_diagnostics = TRUE)
#' print_bls_warnings(jolts_with_diagnostics)
#'
#' # View job openings by state for latest period
#' job_openings <- jolts_data[dataelement_text == "Job openings" & 
#'                           date == max(date)]
#' }

get_jolts <- function(monthly_only = TRUE, remove_regions = TRUE, remove_national = TRUE, 
                      suppress_warnings = TRUE, return_diagnostics = FALSE, cache = FALSE) {
  
  # Define all URLs we need to download
  download_urls <- c(
    "data" = "https://download.bls.gov/pub/time.series/jt/jt.data.1.AllItems",
    "series" = "https://download.bls.gov/pub/time.series/jt/jt.series",
    "states" = "https://download.bls.gov/pub/time.series/jt/jt.state",
    "elements" = "https://download.bls.gov/pub/time.series/jt/jt.dataelement",
    "area" = "https://download.bls.gov/pub/time.series/jt/jt.area",
    "sizeclass" = "https://download.bls.gov/pub/time.series/jt/jt.sizeclass",
    "industry" = "https://download.bls.gov/pub/time.series/jt/jt.industry"
  )
  
  # Download all files
  downloads <- download_bls_files(download_urls, suppress_warnings = suppress_warnings, cache = cache)
  
  # Extract data from downloads
  jolts_import <- get_bls_data(downloads$data)
  jolts_series <- get_bls_data(downloads$series)
  jolts_states <- get_bls_data(downloads$states)
  jolts_elements <- get_bls_data(downloads$elements)
  jolts_area <- get_bls_data(downloads$area)
  jolts_sizeclass <- get_bls_data(downloads$sizeclass)
  jolts_industry <- get_bls_data(downloads$industry)
  
  # Join all the data together
  jolts <- jolts_import |>
    dplyr::select(-c(footnote_codes)) |>
    dplyr::left_join(jolts_series, by = "series_id") |>
    dplyr::left_join(jolts_states |> dplyr::select(-c(display_level:sort_sequence)), by = "state_code") |>
    dplyr::left_join(jolts_elements |> dplyr::select(-c(display_level:sort_sequence)), by = "dataelement_code") |>
    dplyr::left_join(jolts_area |> dplyr::select(-c(display_level:sort_sequence)), by = "area_code") |>
    dplyr::left_join(jolts_sizeclass |> dplyr::select(-c(display_level:sort_sequence)), by = "sizeclass_code") |>
    dplyr::left_join(jolts_industry |> dplyr::select(-c(display_level:sort_sequence)), by = "industry_code")
  
  # Track processing steps
  processing_steps <- c(
    "Joined series, states, elements, area, sizeclass, and industry metadata"
  )
  
  # Apply filters
  if (monthly_only) {
    jolts <- jolts |>
      dplyr::filter(period != "M13")
    
    processing_steps <- c(processing_steps, "Filtered to monthly data only")
  }
  
  if (remove_regions) {
    jolts <- jolts |>
      dplyr::filter(!(state_code %in% c("MW", "NE", "SO", "WE")))
    
    processing_steps <- c(processing_steps, "Removed regional aggregates")
  }
  
  if (remove_national) {
    jolts <- jolts |>
      dplyr::filter(!(state_code %in% c("00")))
    
    processing_steps <- c(processing_steps, "Removed national-level data")
  }
  
  # Apply transformations
  jolts <- jolts |>
    dplyr::mutate(date = ym(paste(year, stringr::str_remove(period, "M"), sep = "-"))) |>
    dplyr::mutate(
      value = as.numeric(value),
      ratelevel_code = case_when(
        ratelevel_code == "L" ~ "Level",
        ratelevel_code == "R" ~ "Rate",
        TRUE ~ "Other"
      ),
      periodname = format(date, "%B"),
      value = if_else(dataelement_code == "UO", value * 100, value),
      value = if_else(ratelevel_code == "Rate", value / 100, value * 1000)
    )
  
  processing_steps <- c(processing_steps, 
                        "Created date column",
                        "Converted values to numeric",
                        "Transformed rate/level codes to text",
                        "Added month names",
                        "Applied value transformations (rates to proportions, levels to counts)")
  
  # Create the BLS data collection object
  bls_collection <- create_bls_object(
    data = jolts,
    downloads = downloads,
    data_type = "JOLTS",
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
    return(jolts)
  }
}