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
#'
#' @return A data.table containing JOLTS data with the following key columns:
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
#' \dontrun{
#' # Download state-level JOLTS data (default)
#' jolts_states <- get_jolts()
#'
#' # Include national data with industry breakdowns
#' jolts_national <- get_jolts(remove_national = FALSE)
#'
#' # Include regional aggregates
#' jolts_regions <- get_jolts(remove_regions = FALSE)
#'
#' # Include annual data
#' jolts_annual <- get_jolts(monthly_only = FALSE)
#'
#' # View job openings by state for latest period
#' job_openings <- jolts_states[dataelement_text == "Job openings" &
#'                              date == max(date)]
#' }
get_jolts <- function(monthly_only = TRUE, remove_regions = TRUE, remove_national = TRUE){

  jolts_import <- fread_bls("https://download.bls.gov/pub/time.series/jt/jt.data.1.AllItems")
  jolts_series <- fread_bls("https://download.bls.gov/pub/time.series/jt/jt.series")
  jolts_states <- fread_bls("https://download.bls.gov/pub/time.series/jt/jt.state")
  jolts_elements <- fread_bls("https://download.bls.gov/pub/time.series/jt/jt.dataelement")
  jolts_area <- fread_bls("https://download.bls.gov/pub/time.series/jt/jt.area")
  jolts_sizeclass <- fread_bls("https://download.bls.gov/pub/time.series/jt/jt.sizeclass")
  jolts_industry <- fread_bls("https://download.bls.gov/pub/time.series/jt/jt.industry")

  jolts <- jolts_import |>
    dplyr::select(-c(footnote_codes)) |>
    dplyr::left_join(jolts_series |> dplyr::select(-footnote_codes), by = "series_id") |>
    dplyr::left_join(jolts_states |> dplyr::select(-c(display_level:sort_sequence)), by = "state_code") |>
    dplyr::left_join(jolts_elements |> dplyr::select(-c(display_level:sort_sequence)), by = "dataelement_code") |>
    dplyr::left_join(jolts_area |> dplyr::select(-c(display_level:sort_sequence)), by = "area_code") |>
    dplyr::left_join(jolts_sizeclass |> dplyr::select(-c(display_level:sort_sequence)), by = "sizeclass_code") |>
    dplyr::left_join(jolts_industry |> dplyr::select(-c(display_level:sort_sequence)), by = "industry_code")

  if(monthly_only){
    jolts <- jolts |>
      dplyr::filter(period != "M13")
  }

  if(remove_regions){
    jolts <- jolts |>
      dplyr::filter(!(state_code %in% c("MW", "NE", "SO", "WE")))

  }

  if(remove_national){
    jolts <- jolts |>
      dplyr::filter(!(state_code %in% c("00")))

  }

  jolts <- jolts |>
    dplyr::mutate(date = ym(paste(year, stringr::str_remove(period, "M"), sep="-")))|>
    dplyr::mutate(
      value = as.numeric(value),
      ratelevel_code = case_when(
      ratelevel_code == "L" ~ "Level",
      ratelevel_code == "R" ~ "Rate",
      TRUE ~ "Other"),
      periodname = format(date, "%B"),
      value = if_else(dataelement_code == "UO", value*100, value),
      value = if_else(ratelevel_code == "Rate", value/100, value*1000)
      )

  return(jolts)

}
