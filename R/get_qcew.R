#' Get QCEW Data Slices
#'
#' This function pulls data from the BLS QCEW Open Data Access CSV Data Slices.
#' It iterates over specified years and quarters (or annual data) to retrieve
#' industry-specific or area-specific data tables and merges them into a single data.table.
#' Optionally, it joins internal package lookup tables for industry and area descriptions.
#'
#' @param period_type Character. Either "quarter" or "year". Defaults to "quarter".
#' @param year_start Numeric. The first year to retrieve data for. Defaults to the year
#'   of the date 6 months prior to the current system date.
#' @param year_end Numeric. The last year to retrieve data for. Defaults to the year
#'   of the date 6 months prior to the current system date.
#' @param industry_code Character. The NAICS industry code (e.g., "10", "31-33").
#'   Constructs a URL for an Industry Data Slice. Mutually exclusive with `area_code`.
#' @param area_code Character. The QCEW area code (e.g., "US000", "32000", "C2982").
#'   Constructs a URL for an Area Data Slice. Mutually exclusive with `industry_code`.
#' @param add_lookups Logical. If \code{TRUE}, joins the package's \code{ind_lookup} and
#'   \code{area_lookup} tables to the results to provide descriptive labels. Defaults to \code{TRUE}.
#' @param silently Logical. If \code{TRUE}, suppresses status messages about the URLs being accessed.
#'   Defaults to \code{FALSE}.
#'
#' @return A combined data.table containing the requested QCEW data, optionally merged with lookup columns
#'   and a calculated \code{date} column.
#' @importFrom data.table rbindlist fread :=
#' @importFrom stringr str_replace_all
#' @export
#'
#' @examples
#' \donttest{
#' # Get quarterly data for "Total, all industries" (Code 10)
#' # Includes industry/area descriptions and a date column by default
#' dt_default <- get_qcew(industry_code = "10")
#'
#' # Get annual data for Nevada (Code 32000) for 2023 without lookups or messages
#' dt_year <- get_qcew(period_type = "year",
#'                     year_start = 2023,
#'                     year_end = 2023,
#'                     area_code = "32000",
#'                     add_lookups = FALSE,
#'                     silently = TRUE)
#' }
get_qcew <- function(period_type = "quarter",
                     year_start = NULL,
                     year_end = NULL,
                     industry_code = NULL,
                     area_code = NULL,
                     add_lookups = TRUE,
                     silently = FALSE) {
  
  # --- Input Validation & Defaults ---
  
  # Calculate default year (System Date - 6 Months) if not provided
  if (is.null(year_start) || is.null(year_end)) {
    # safe base R method to subtract 6 months
    default_date <- seq(Sys.Date(), by = "-6 months", length.out = 2)[2]
    default_year <- as.numeric(format(default_date, "%Y"))
    
    if (is.null(year_start)) year_start <- default_year
    if (is.null(year_end)) year_end <- default_year
  }
  
  # Check for pre-2014 data availability
  if (year_start < 2014) {
    warning("Data prior to 2014 is not available via these data slices. URLs may fail.")
  }
  
  if (!period_type %in% c("quarter", "year")) {
    stop("period_type must be either 'quarter' or 'year'.")
  }
  
  if (is.null(industry_code) && is.null(area_code)) {
    stop("You must provide either an industry_code or an area_code.")
  }
  
  if (!is.null(industry_code) && !is.null(area_code)) {
    stop("Please provide only one: industry_code OR area_code, not both.")
  }
  
  # --- Setup Iteration Parameters ---
  years <- seq(from = year_start, to = year_end)
  
  # Define quarter codes: 1-4 for quarterly, 'a' for annual
  if (period_type == "quarter") {
    quarters <- as.character(1:4)
  } else {
    quarters <- "a"
  }
  
  # Initialize list to store data tables
  data_list <- list()
  
  # Base URL for BLS QCEW Data Slices
  base_url <- "https://data.bls.gov/cew/data/api"
  
  # --- Iteration Loop ---
  for (yr in years) {
    for (qtr in quarters) {
      
      # Construct the dynamic part of the URL based on input
      if (!is.null(industry_code)) {
        # BLS uses underscores instead of hyphens in URLs (e.g., 31-33 becomes 31_33)
        clean_code <- stringr::str_replace_all(industry_code, "-", "_")
        url_path <- paste(yr, qtr, "industry", paste0(clean_code, ".csv"), sep = "/")
      } else {
        url_path <- paste(yr, qtr, "area", paste0(area_code, ".csv"), sep = "/")
      }
      
      full_url <- paste(base_url, url_path, sep = "/")
      
      # Display status message if not silent
      if (!silently) {
        message(paste("Accessing:", full_url))
      }
      
      # Attempt to fetch data
      tryCatch({
        # fread is efficient for direct URL CSV reading
        # colClasses ensures industry_code is character to preserve formatting
        temp_dt <- data.table::fread(full_url, 
                                     showProgress = FALSE, 
                                     colClasses = c("industry_code" = "character"))
        
        data_list[[length(data_list) + 1]] <- temp_dt
        
      }, error = function(e) {
        # Handle 404s (e.g., future quarters not yet released) silently or with a warning
        warning(paste("Could not fetch data for:", full_url, "-", e$message))
      })
    }
  }
  
  # --- Aggregation ---
  if (length(data_list) == 0) {
    warning("No data was retrieved. Please check your parameters and internet connection.")
    return(NULL)
  }
  
  # Fast bind of all fetched tables
  final_dt <- data.table::rbindlist(data_list, use.names = TRUE, fill = TRUE)
  
  # --- Add Date Column ---
  # We use the 'year' and 'qtr' columns that come directly from the BLS CSVs
  if (period_type == "quarter") {
    # Calculate month: Q1->1, Q2->4, Q3->7, Q4->10 using math: (qtr*3) - 2
    final_dt[, temp_month := (as.numeric(qtr) * 3) - 2]
    final_dt[, date := as.Date(paste(year, temp_month, "01", sep = "-"))]
    final_dt[, temp_month := NULL] # Clean up helper column
  } else {
    # For annual, default to January 1st
    final_dt[, date := as.Date(paste(year, "01", "01", sep = "-"))]
  }
  
  # --- Lookups Merge ---
  if (add_lookups) {
    # Check if lookups are available in the package namespace
    if (exists("ind_lookup") && exists("area_lookup")) {
      
      # Left join industry lookup
      if ("industry_code" %in% names(final_dt)) {
        final_dt <- merge(final_dt, ind_lookup, by = "industry_code", all.x = TRUE)
      }
      
      # Left join area lookup
      if ("area_fips" %in% names(final_dt)) {
        final_dt <- merge(final_dt, area_lookup, by = "area_fips", all.x = TRUE)
      }
      
    } else {
      warning("add_lookups = TRUE, but 'ind_lookup' or 'area_lookup' were not found in the environment. Returning data without lookups.")
    }
  }
  
  return(final_dt)
}