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
#'   and a calculated \code{date} column.  The data layout is different for quarterly or annual data files set by the `period_type` argument.
#'   
#'   For Quarterly files:
#'   \itemize{
#'    \item area_fips - Character. Area code of row.  Included `area_lookup` data file contains mapping information.
#'    \item industry_code - Character. NAICS, Supersector, Cluster, or Total All Industries code. Numeric characters as a string to preserve examining the structure heirarchy.
#'    \item own_code - Integer.  Values of 0-5 to designate ownership. See definitions at \url{https://www.bls.gov/cew/classifications/ownerships/ownership-titles.htm}
#'    \item agglvl_code - Integer.   Two digit code identifying the level of aggregation.  See definitons at \url{https://www.bls.gov/cew/classifications/aggregation/agg-level-titles.htm}
#'    \item size_code - Integer. Single-digit code representing the size of establishments. See definitions at \url{https://www.bls.gov/cew/classifications/size/size-titles.htm}
#'    \item year Integer.  Four-digit calendar year for the returned data.
#'    \item qtr Integer. The calendar quarter of the data. 
#'    \item disclosure_code Character.  Values are either a blank string on "N".  Values of N do not disclose employment or wages to maintain confidentiality.
#'    \item qtryly_estabs Integer.  The number of business establishments (worksites) for the industry in the area in the quarter.
#'    \item month1_emplvl Integer. Employment in the first month of the quarter (January, April, July, or October).
#'    \item month2_emplvl Integer. Employment in the second month of the quarter (February, May, August, November).
#'    \item month3_emplvl Integer. Employment in the third month of the quarter (March, June, September, December).
#'    \item total_qtrly_wages Ingeger64. Total wages paid during the quarter.
#'    \item taxable_qtrly_wages Ingeger64. Wages subject to unemployment insurance (UI) taxes during the quarter.  Note - wages subject to UI vary by state and will follow different seasonal patterns as a result.
#'    \item qtrly_contributions Integer. UI taxes (Contributions) paid by employers for this quarter. Note - UI tax policy varies by state.
#'    \item avg_wkly_wage Integer. Average weekly wage during the quarter (Total wages divided by average employment, divided by 13).
#'   
#'    \item lq_disclosure_code Character.  Blank or "N".  Values of "N" will suppress location quotient data for confidentiality.
#'    \item lq_qtrly_estabs Numeric. Location quotient of establishments relative to the U.S.
#'    \item lq_month1_emplvl Numeric. Location quotient of month 1 employment relative to the U.S.
#'    \item lq_month2_emplvl Numeric. Location quotient of month 2 employment relative to the U.S.
#'    \item lq_month3_emplvl Numeric. Location quotient of month 3 employment relative to the U.S.
#'    \item lq_total_qtrly_wages Numeric. Location quotient of total wages relative to the U.S.
#'    \item lq_taxable_qtrly_wages Numeric. Location quotient of taxable quarterly wages relative to the U.S.
#'    \item lq_qtrly_contributions Numeric. Location quotient of quarterly UI taxes paid relative to the U.S.
#'    \item lq_avg_wkly_wage Numeric. Location quotient of average weekly wages relative to the U.S.
#'    
#'    \item oty_disclosure_code Character.  Blank or "N".  Values of "N" will suppress over-the-year data for confidentiality.
#'    \item oty_qtrly_estabs_chg Numeric. Over-the-year change in establishments.
#'    \item oty_qtrly_estabs_pct_chg Numeric. Over-the-year percent change in establishments.
#'    \item oty_month1_emplvl_chg Numeric. Over-the-year change in month 1 employment.
#'    \item oty_month1_emplvl_pct_chg Numeric. Over-the-year percent change in month 1 employment.
#'    \item oty_month2_emplvl_chg Numeric. Over-the-year change in month 2 employment.
#'    \item oty_month2_emplvl_pct_chg Numeric. Over-the-year percent change in month 2 employment.
#'    \item oty_month3_emplvl_chg Numeric. Over-the-year change in month 3 employment.
#'    \item oty_month3_emplvl_pct_chg Numeric. Over-the-year percent change in month 3 employment.
#'    \item oty_total_qtrly_wages_chg Numeric. Over-the-year change in total wages.
#'    \item oty_total_qtrly_wages_pct_chg Numeric. Over-the-year percent change in total wages.
#'    \item oty_taxable_qtrly_wages_chg Numeric. Over-the-year change in taxable quarterly wages.
#'    \item oty_taxable_qtrly_wages_pct_chg Numeric. Over-the-year percent change in taxable quarterly wages.
#'    \item oty_qtrly_contributions_chg Numeric. Over-the-year change in quarterly UI taxes paid.
#'    \item oty_qtrly_contributions_pct_chg Numeric. Over-the-year percent change in quarterly UI taxes paid.
#'    \item oty_avg_wkly_wage_chg Numeric. Over-the-year change in average weekly wages.
#'    \item oty_avg_wkly_wage_pct_chg Numeric. Over-the-year percent change in average weekly wages.
#'    
#'    \item date Date. Calculated calendar date based on year and quarter.  Reflects first day of the quarter.
#'    \item industry_title Character. Added based on industry_code
#'    \item ind_level Character. Description of the level of aggregation based on the industry_code.
#'    \item naics_2d Character. First two characters in the industry_code, useful for identifying industries.
#'    \item sector Character. Similar to naics_2d, but for industries like Manufacturing which have multiple two digit NAICS codes, this will span those groupings, for example "31-33"
#'    \item vintage_start. Integer. Calendar year of the earliest vintage for this industry_code. NAICS codes are updated every 5 years.  When using this industry codes from before this date, these titles may not exist or may be incorrect.
#'    \item vintage_end. Integer. Calendar year of the last year this industry code was used.  Years after this point should not contain this industry code.  Set to 3000 for current data.
#'    \item area_title Character.  Area description based on area_fips as provided by the BLS.
#'    \item area_type Character. Description of the type of area based on the area_title. More consistent naming and grouping than BLS data.
#'    \item stfips Character. The two-digit FIPS code of the state containing a given area. Set to "00" for multi-state regions.
#'    \item specified_region. Either a two-character US Postal Service abbreviation for the state containing an area or a hyphenated list of such codes for multi-state areas.
#'   }
#'   
#'   For Annual files:
#'   \itemize{
#'    \item area_fips - Character. Area code of row.  Included `area_lookup` data file contains mapping information.
#'    \item industry_code - Character. NAICS, Supersector, Cluster, or Total All Industries code. Numeric characters as a string to preserve examining the structure heirarchy.
#'    \item own_code - Integer.  Values of 0-5 to designate ownership. See definitions at \url{https://www.bls.gov/cew/classifications/ownerships/ownership-titles.htm}
#'    \item agglvl_code - Integer.   Two digit code identifying the level of aggregation.  See definitons at \url{https://www.bls.gov/cew/classifications/aggregation/agg-level-titles.htm}
#'    \item size_code - Integer. Single-digit code representing the size of establishments. See definitions at \url{https://www.bls.gov/cew/classifications/size/size-titles.htm}
#'    \item year Integer.  Four-digit calendar year for the returned data.
#'    \item qtr Character. Set to "A" to represent annual data.
#'    \item disclosure_code Character.  Values are either a blank string on "N".  Values of N do not disclose employment or wages to maintain confidentiality.
#'    \item annual_avg_estabs Integer.  The average number of business establishments (worksites) for the industry in the area for the year.
#'    \item annual_avg_emplvl Integer. The average monthly employment level in a given year.
#'    \item total_annual_wages Ingeger64. Total wages paid during the year.
#'    \item taxable_annual_wages Ingeger64. Wages subject to unemployment insurance (UI) taxes during the year.  Note - wages subject to UI vary by state and will follow different seasonal patterns as a result.
#'    \item annual_contributions Integer. UI taxes (Contributions) paid by employers for this year. Note - UI tax policy varies by state.
#'    \item annual_avg_wkly_wage Integer. Average weekly wage during the year (Total wages divided by average employment, divided by 52).
#'    \item avg_annual_pay Integer. Average annual pay during the year.
#'   
#'    \item lq_disclosure_code Character.  Blank or "N".  Values of "N" will suppress location quotient data for confidentiality.
#'    \item lq_annual_avg_estabs Numeric. Location quotient of establishments relative to the U.S.
#'    \item lq_annual_avg_emplvl Numeric. Location quotient of annual employment relative to the U.S.
#'    \item lq_total_annual_wages Numeric. Location quotient of total wages relative to the U.S.
#'    \item lq_taxable_annual_wages Numeric. Location quotient of taxable annual wages relative to the U.S.
#'    \item lq_annual_contributions Numeric. Location quotient of annual UI taxes paid relative to the U.S.
#'    \item lq_annual_avg_wkly_wage Numeric. Location quotient of average weekly wages relative to the U.S.
#'    \item lq_avg_annual_pay Numeric. Location quotient of average annual pay relative to the U.S.
#'    
#'    \item oty_disclosure_code Character.  Blank or "N".  Values of "N" will suppress over-the-year data for confidentiality.
#'    \item oty_annual_avg_estabs_chg Integer. Over-the-year change in establishments.
#'    \item oty_annual_avg_estabs_pct_chg Numeric. Over-the-year percent change in establishments.
#'    \item oty_annual_avg_emplvl_chg Integer. Over-the-year change in average annual employment.
#'    \item oty_annual_avg_emplvl_pct_chg Numeric. Over-the-year percent change in average annual employment.
#'    \item oty_total_annual_wages_chg Integer. Over-the-year change in total wages.
#'    \item oty_total_annual_wages_pct_chg Numeric. Over-the-year percent change in total wages.
#'    \item oty_taxable_annual_wages_chg Integer. Over-the-year change in taxable annual wages.
#'    \item oty_taxable_annual_wages_pct_chg Numeric. Over-the-year percent change in taxable annual wages.
#'    \item oty_annual_contributions_chg Integer. Over-the-year change in annual UI taxes paid.
#'    \item oty_annual_contributions_pct_chg Numeric. Over-the-year percent change in annual UI taxes paid.
#'    \item oty_annual_avg_wkly_wage_chg Integer. Over-the-year change in average weekly wages.
#'    \item oty_annual_avg_wkly_wage_pct_chg Numeric. Over-the-year percent change in average weekly wages.
#'    \item oty_avg_annual_pay_chg Integer. Over-the-year change in average annual pay.
#'    \item oty_avg_annual_pay_pct_chg Numeric. Over-the-year percent change in average annual pay.
#'    
#'    \item date Date. Calculated calendar date based on year and quarter.  Reflects first day of the quarter.
#'    \item industry_title Character. Added based on industry_code
#'    \item ind_level Character. Description of the level of aggregation based on the industry_code.
#'    \item naics_2d Character. First two characters in the industry_code, useful for identifying industries.
#'    \item sector Character. Similar to naics_2d, but for industries like Manufacturing which have multiple two digit NAICS codes, this will span those groupings, for example "31-33"
#'    \item vintage_start. Integer. Calendar year of the earliest vintage for this industry_code. NAICS codes are updated every 5 years.  When using this industry codes from before this date, these titles may not exist or may be incorrect.
#'    \item vintage_end. Integer. Calendar year of the last year this industry code was used.  Years after this point should not contain this industry code.  Set to 3000 for current data.
#'    \item area_title Character.  Area description based on area_fips as provided by the BLS.
#'    \item area_type Character. Description of the type of area based on the area_title. More consistent naming and grouping than BLS data.
#'    \item stfips Character. The two-digit FIPS code of the state containing a given area. Set to "00" for multi-state regions.
#'    \item specified_region. Either a two-character US Postal Service abbreviation for the state containing an area or a hyphenated list of such codes for multi-state areas.
#'   }
#'   
#'   
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