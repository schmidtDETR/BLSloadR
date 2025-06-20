#' Download Occupational Employment and Wage Statistics (OEWS) Data
#'
#' This function downloads and joins together occupational employment and wage data
#' from the Bureau of Labor Statistics OEWS program. The data includes employment
#' and wage estimates by occupation and geographic area.
#'
#' @return A data.table containing OEWS data with the following key columns:
#'   \describe{
#'     \item{series_id}{BLS series identifier}
#'     \item{year}{Year of observation}
#'     \item{period}{Time period}
#'     \item{value}{Employment or wage statistic value}
#'     \item{occupation_title}{Occupation name/title}
#'     \item{area_title}{Geographic area name}
#'     \item{datatype_text}{Type of statistic (employment, wages, etc.)}
#'   }
#'
#' @export
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr left_join
#' @importFrom dplyr select
#' @examples
#' \dontrun{
#' # Download current OEWS data
#' oews_data <- get_oews()
#'
#' # View available occupations
#' unique(oews_data$occupation_title)
#'
#' # Filter for specific occupation
#' software_devs <- oews_data[grepl("Software", occupation_title)]
#' }

# This downloads and joins together selected data for the OEWS program using fread_bls

get_oews <- function(){

  oews_current <- fread_bls("https://download.bls.gov/pub/time.series/oe/oe.data.0.Current")
  oews_series <- fread_bls("https://download.bls.gov/pub/time.series/oe/oe.series")
  oews_occupation <- fread_bls("https://download.bls.gov/pub/time.series/oe/oe.occupation")
  oews_area <- fread_bls("https://download.bls.gov/pub/time.series/oe/oe.area")
  oews_datatype <- fread_bls("https://download.bls.gov/pub/time.series/oe/oe.datatype")

  oews_import <- oews_current |> dplyr::select(-footnote_codes) |>
    dplyr::left_join(oews_series) |> dplyr::select(-footnote_codes) |>
    dplyr::left_join(oews_occupation) |>
    dplyr::left_join(oews_area) |>
    dplyr::left_join(oews_datatype) |>
    dplyr::mutate(value = as.numeric(value))

  return(oews_import)

}



