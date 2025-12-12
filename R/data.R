#' @title NAICS Industry Titles Lookup Table (QCEW)
#'
#' @description
#' A data frame containing the structure of the North American Industry Classification System (NAICS) titles and codes used by the U.S. Bureau of Labor Statistics (BLS), including in the Quarterly Census of Employment and Wages (QCEW) program. This data is current as of the 2022 NAICS revision.
#'
#' This table is primarily used internally by `BLSloadR` functions to add human-readable industry titles or define valid industry lookups.
#'
#' @format A data frame with 2678 rows and 7 columns:
#' \itemize{
#'   \item{industry_code - Character.  The NAICS industry code.  Items starting with 10 are aggregated values, not corresponding to a unique 6-digit NAICS.}
#'   \item{industry_title - Character. The descripion of the industry code provided by the BLS.  This title also includes the code value for clarity.}
#'   \item{ind_level - Character. A description of the level of aggregation. Values are "Total", "Cluster", or "Supersector" for the "10" code aggregations, or else the length of the NAICS code, from 2-6 digits.}
#'   \item{naics_2d - Character. The first two digits of `industry_code`, which may be helpful to filter the results.}
#'   \item{sector - Character.  Similar to `naics_2d` except that when the industry sector spans multiple two digit codes, those codes are hyphenated (e.g. Manufacturing is NAICS 31, 32, and 33, so this displays '31-33').}
#'   \item{vintage_start - Integer.  The earliest year reviewed for NAICS code use. NAICS will change every 5 years, so data from before this year will have some missing values.}
#'   \item{vintage_end - Integer. The last year that a particular code is used, if applicable. Set to 3000 for current codes.}
#' }
#'
#' @source \url{https://www.bls.gov/cew/classifications/industry/industry-titles.htm}
#'
#' @usage data(ind_lookup)
#'
#' @details
#' The NAICS structure is hierarchical. Codes are typically longer for more detailed industries.
#'
#' @examples
#' # Load the lookup table
#' data(ind_lookup)
#'
#' # Find the industry title for NAICS 51 (Information)
#' ind_lookup[ind_lookup$industry_code == "51", ]
#'
#' # Get the supersector codes
#' supersectors <- ind_lookup[ind_lookup$ind_level == "Supersector", ]
#' 
#' # Get all 3-digit NAICS codes in the Manufacturing industry
#' mfg_codes <- ind_lookup |> 
#' dplyr::filter(sector == "31-33" & ind_level == "NAICS 3-digit")
"ind_lookup"

#' @title Area Lookup Tables (QCEW)
#'
#' @description
#' A data frame containing area codes, titles, and additional geographic information about valid areas for the Quarterly Census of Employment and Wages (QCEW).
#'
#' This table is primarily used internally by `BLSloadR` functions to add human-readable area titles or define valid area lookups.
#'
#' @format A data frame with 4649 rows and 5 columns:
#' \itemize{
#'   \item{area_fips - Character.  The area FIPS code.  When all numeric characters, it represents either a state or a county definition.}
#'   \item{area_title - Character. The descripion of the area code provided by the Bureau of Labor Statistics.}
#'   \item{area_type - Character. A desription ot the type of area defined.  Values are National, State, County, County Unknown or Undefined, National Subgroup, Combined Statistical Area, Metropolitan Statistical Area, or Micropolitan Statistical Area.}
#'   \item{stfips - Character. For state or counties, the two-digit FIPS code of the associated state.  For national areas, or those areas which may span multiple states the value is "00".}
#'   \item{specified_region - Either the two-character US Postal abbreviation for a state or group of states, or "No region" for other areas.}
#' }
#'
#' @source \url{https://www.bls.gov/cew/classifications/areas/qcew-area-titles.htm}
#'
#' @usage data(area_lookup)
#'
#' @details
#' Area codes are five characters long. When all numeric characters, this is a state-county FIPS, with statewide data using a "000" as the county FIPS.  Other aggregations include various alphabetic characters to aid in the classification of different regions.
#'
#' @examples
#' # Load the lookup table
#' data(area_lookup)
#'
#' # Find the area codes for all Statewide areas
#' state_codes <- area_lookup[area_lookup$area_type == "State", ]
#' 
#' # Get all Metropolitan Statistical Area codes including Arkansas.
#' ar_codes <- area_lookup |> 
#' dplyr::filter(grepl("AR", specified_region) &
#'  area_type == "Metropolitan Statistical Area")
"area_lookup"