#' Download State Alternative Labor Market Measures (SALT) Data
#'
#' This function downloads detailed alternative unemployment measures data from BLS,
#' including U-1 through U-6 measures. The data provides a more comprehensive view
#' of labor market conditions beyond the standard unemployment rate (U-3).
#'
#' @param only_states Logical. If TRUE (default), includes only state-level data.
#'   If FALSE, includes sub-state areas like New York City where available.
#'
#' @return A data.table containing SALT data with the following key measures:
#'   \describe{
#'     \item{date}{Date of observation (quarterly)}
#'     \item{state}{State name}
#'     \item{fips}{FIPS code}
#'     \item{u1}{U-1: Persons unemployed 15+ weeks as percent of civilian labor force}
#'     \item{u2}{U-2: Job losers as percent of civilian labor force}
#'     \item{u3}{U-3: Standard unemployment rate}
#'     \item{u4}{U-4: U-3 + discouraged workers}
#'     \item{u5}{U-5: U-4 + marginally attached workers}
#'     \item{u6}{U-6: U-5 + involuntary part-time workers}
#'     \item{civilian_labor_force}{Size of civilian labor force}
#'     \item{unemployed}{Number of unemployed persons}
#'     \item{job_losers}{Number of job losers}
#'     \item{discouraged_workers}{Number of discouraged workers}
#'   }
#'
#'   The function also adds derived measures and quartile comparisons across states.
#'
#' @export
#' @importFrom httr GET
#' @importFrom httr write_disk
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr left_join
#' @importFrom dplyr select
#' @importFrom dplyr across
#' @importFrom dplyr case_when
#' @importFrom dplyr rename_with
#' @importFrom dplyr lag
#' @importFrom stringr str_remove
#' @importFrom stringr str_length
#' @importFrom stringr str_to_lower
#' @importFrom lubridate ym
#' @importFrom tidyselect matches
#' @importFrom tidyselect starts_with
#' @importFrom tidyselect everything
#' @importFrom zoo as.yearqtr
#' @examples
#' \dontrun{
#' # Download state-level SALT data
#' salt_data <- get_salt()
#'
#' # Include sub-state areas
#' salt_all <- get_salt(only_states = FALSE)
#'
#' # View latest U-6 rates by state
#' latest <- salt_data[date == max(date), .(state, u6)]
#' latest[order(-u6)]
#' }

get_salt <- function(only_states = TRUE){

  salt_url <- "https://www.bls.gov/lau/stalt-moave.xlsx"

  headers <- c(
    "Sec-Ch-Ua" =
      'Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
    "Sec-Ch-Ua-Mobile" =
      "?0",
    "Sec-Ch-Ua-Platform" =
      '"Windows"',
    "Sec-Fetch-Dest" =
      "document",
    "Sec-Fetch-Mode" =
      "navigate",
    "Sec-Fetch-Site" =
      "same-origin",
    "Sec-Fetch-User" =
      "?1",
    "Upgrade-Insecure-Requests" =
      "1",
    "User-Agent" =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  )

  response <- GET(salt_url, write_disk(tf <- tempfile(fileext = ".xlsx")), add_headers(headers))

  salt_data <- readxl::read_excel(tf, skip = 1) |>
    dplyr::rename_with(.fn = str_to_lower) |>
    dplyr::mutate(date = lubridate::yq(paste0(`end year`, `end quarter`))) |>
    dplyr::select(-c(record, `start year`, `start quarter`, `end year`, `end quarter`, `unique period`)) |>
    dplyr::mutate(across(starts_with("u-"), function(x){x = x/100})) |>
    dplyr::rename_with(.cols = tidyselect::starts_with("u-"), .fn = stringr::str_remove, pattern = "-") |>
    dplyr::rename_with(.cols = everything(), .fn = stringr::str_replace_all, pattern = " ", replacement = "_") |>
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
           #is_NV = if_else(st == "NV", "A - Is NV", "B - Not NV"),
           period_name = zoo::as.yearqtr(date))

  if(only_states){
    salt_data <- salt_data |>
      dplyr::mutate(fips_len = stringr::str_length(fips)) |>
      dplyr::filter(fips_len == 2) |>
      dplyr::select(-fips_len)
  }

  salt_data <- salt_data |>
    dplyr::group_by(date) |>
    dplyr::mutate(u1_25 = quantile(u1, probs = c(0.25), na.rm = TRUE),
           u1_50 = median(u1),
           u1_75 = quantile(u1, probs = c(0.75), na.rm = TRUE),
           u2_25 = quantile(u2, probs = c(0.25), na.rm = TRUE),
           u2_50 = median(u2),
           u2_75 = quantile(u2, probs = c(0.75), na.rm = TRUE),
           u3_25 = quantile(u3, probs = c(0.25), na.rm = TRUE),
           u3_50 = median(u3),
           u3_75 = quantile(u3, probs = c(0.75), na.rm = TRUE),
           u4b_25 = quantile(u4b, probs = c(0.25), na.rm = TRUE),
           u4b_50 = median(u4b),
           u4b_75 = quantile(u4b, probs = c(0.75), na.rm = TRUE),
           u5b_25 = quantile(u5b, probs = c(0.25), na.rm = TRUE),
           u5b_50 = median(u5b),
           u5b_75 = quantile(u5b, probs = c(0.75), na.rm = TRUE)
    ) |>
    dplyr::ungroup() |>
    dplyr::group_by(state) |>
    dplyr::mutate(
      dplyr::across(tidyselect::matches("^u[0-9]"),
             .fns = function(x){lag(x, 4)},
             .names = "py_{.col}")
    ) |>
    mutate(
      dplyr::across(tidyselect::matches("^u[0-9]"),
             .fns = function(x){lag(x, 1)},
             .names = "pq_{.col}")
    ) |>
    dplyr::ungroup()

  return(salt_data)

}
