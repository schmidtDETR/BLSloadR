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
#'
#' @return A data.frame containing CES employment data with the following key columns:
#'   \describe{
#'     \item{series_id}{BLS series identifier}
#'     \item{year}{Year of the observation}
#'     \item{period}{Time period (M01-M12 for months, M13 for annual average)}
#'     \item{value}{Employment statistic value}
#'     \item{industry_code}{Industry classification code}
#'     \item{industry_name}{Industry name/description}
#'     \item{datatype_code}{Type of employment statistic code}
#'     \item{datatype_text}{Description of the employment statistic}
#'     \item{supersector_code}{Supersector classification code}
#'     \item{supersector_name}{Supersector name/description}
#'     \item{date}{Date column (lubridate yearmonth format, only if simplify_table=TRUE)}
#'   }
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
#' employment statistics. The function relies on a helper function `fread_bls()` 
#' to download and read the BLS data files.
#'
#' @note 
#' This function requires the following packages: dplyr, data.table, httr, and 
#' lubridate (for date formatting when simplify_table=TRUE). The `fread_bls()` 
#' helper function must be defined elsewhere in your environment.
#'
#' @examples
#' \dontrun{
#' # Get monthly CES data with simplified table structure
#' ces_monthly <- get_national_ces()
#' 
#' # Get all data including annual averages with full metadata
#' ces_full <- get_national_ces(monthly_only = FALSE, simplify_table = FALSE)
#' 
#' # Get monthly data but keep all metadata columns
#' ces_detailed <- get_national_ces(monthly_only = TRUE, simplify_table = FALSE)
#' }
#'
#' @seealso 
#' \url{https://www.bls.gov/ces/} for more information about CES data
#' 
#' @export
get_national_ces <- function(monthly_only = TRUE, simplify_table = TRUE){
  
  ces_data <- fread_bls("https://download.bls.gov/pub/time.series/ce/ce.data.0.AllCESSeries")
  ces_series <- fread_bls("https://download.bls.gov/pub/time.series/ce/ce.series")
  ces_industry <- fread_bls("https://download.bls.gov/pub/time.series/ce/ce.industry")
  ces_period <- fread_bls("https://download.bls.gov/pub/time.series/ce/ce.period")
  ces_datatype <- fread_bls("https://download.bls.gov/pub/time.series/ce/ce.datatype")
  ces_supersector <- fread_bls("https://download.bls.gov/pub/time.series/ce/ce.supersector")
  
  ces_full <- ces_data %>% select(-footnote_codes) %>%
    left_join(ces_series) %>% select(-footnote_codes) %>%
    left_join(ces_industry) %>%
    left_join(ces_period) %>%
    left_join(ces_datatype) %>%
    left_join(ces_supersector)
  
  if(monthly_only){
    ces_full <- ces_full %>%
      filter(period != "M13")
  }
  
  if(simplify_table){
    ces_full <- ces_full %>%
      select(-c(series_title, begin_year, begin_period, end_year, end_period, naics_code, publishing_status, display_level, selectable, sort_sequence)) %>%
      mutate(date = lubridate::ym(paste0(year,period)))
    
  }
  
  
  return(ces_full)
  
}
