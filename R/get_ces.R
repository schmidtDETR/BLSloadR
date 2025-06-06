#' Download Current Employment Statistics (CES) Data
#'
#' This function downloads Current Employment Statistics data from the Bureau of Labor Statistics.
#' The data includes national, regional, state, and substate employment statistics.
#' By default, all available areas, data types, and periods are included.
#'
#' @param transform Logical. If TRUE (default), converts employment values from thousands
#'   to actual counts by multiplying by 1000 for specific data types (codes 1, 6, 26)
#'   and removes ", In Thousands" from data type labels.
#' @param monthly_only Logical. If TRUE (default), filters out annual data (period M13)
#'   and creates a date column from year and period.
#'
#' @return A data.table containing CES data with the following key columns:
#'   \describe{
#'     \item{series_id}{BLS series identifier}
#'     \item{year}{Year of observation}
#'     \item{period}{Time period (M01-M12 for months, M13 for annual)}
#'     \item{value}{Employment statistic value}
#'     \item{date}{Date column (if monthly_only = TRUE)}
#'     \item{industry_text}{Industry description}
#'     \item{state_text}{State name}
#'     \item{area_text}{Area description}
#'     \item{data_type_text}{Type of employment statistic}
#'   }
#'
#' @export
#' @examples
#' \dontrun{
#' # Download all CES data with default settings
#' ces_data <- get_ces()
#'
#' # Download without transformation
#' ces_raw <- get_ces(transform = FALSE)
#'
#' # Include annual data
#' ces_all <- get_ces(monthly_only = FALSE)
#' }
get_ces <- function(transform = TRUE, monthly_only = TRUE) {

  ces_import <- fread_bls("https://download.bls.gov/pub/time.series/sm/sm.data.1.AllData") %>% select(-footnote_codes) %>%
    left_join(fread_bls("https://download.bls.gov/pub/time.series/sm/sm.series"), by = "series_id") %>%  select(-footnote_codes) %>%
    left_join(fread_bls("https://download.bls.gov/pub/time.series/sm/sm.industry"), by = "industry_code") %>%
    left_join(fread_bls("https://download.bls.gov/pub/time.series/sm/sm.state"), by = "state_code") %>%
    left_join(fread_bls("https://download.bls.gov/pub/time.series/sm/sm.area"), by = "area_code") %>%
    left_join(fread_bls("https://download.bls.gov/pub/time.series/sm/sm.data_type"), by = "data_type_code") %>%
    left_join(fread_bls("https://download.bls.gov/pub/time.series/sm/sm.supersector"), by = "supersector_code") %>%
    mutate(value = as.numeric(value),
           industry_code = substr(series_id,11,18)) %>%
    filter(!is.na(value))

  if(transform){

    ces_import <- ces_import %>%
      mutate(
        value = if_else(
          data_type_code %in% c(1,6,26),
          value * 1000,
          value
        ),
        data_type_text = str_remove(data_type_text, ", In Thousands")
        )

  }

  if(monthly_only){

    ces_import <- ces_import %>%
      filter(period != "M13") %>%
      mutate(date = lubridate::ym(paste(as.character(year),substr(period,2,3),sep = "-")))

  }

  return(ces_import)

}
