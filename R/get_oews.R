#' Download Occupational Employment and Wage Statistics (OEWS) Data
#'
#' This function downloads and joins together occupational employment and wage data
#' from the Bureau of Labor Statistics OEWS program. The data includes employment
#' and wage estimates by occupation and geographic area. Note that OEWS is a large data set (over 6 million rows), so it will require longer to download.
#'
#' @param simplify_table Logical.  If TRUE (default), remove columns from the result that are internal BLS references or can be derived from other elements in the table.
#' @param suppress_warnings Logical. If TRUE (default), suppress individual download warnings and diagnostic messages
#'   for cleaner output during batch processing. If FALSE, returns the data and prints warnings and messages to the console.
#' @param return_diagnostics Logical. If TRUE, returns a bls_data_collection object
#'   with full diagnostics. If FALSE (default), returns just the data table.
#' @param fast_read Logical.  If TRUE (default), derives lookup values directly from series_id to avoid reading the series file, to speed download process. With fast_read, the data can download in 17 seconds (depending on bandwidth).  Without fast_read, the same download takes 57 seconds.
#' @param cache Logical.  Uses USE_BLS_CACHE environment variable, or defaults to FALSE. If TRUE, will download a cached file from BLS server and update cache if BLS server indicates an updated file.
#'
#' @return By default, returns a data.table with OEWS data. If return_diagnostics = TRUE,
#'   returns a bls_data_collection object containing data and comprehensive diagnostics. The columns in the returned data frame when `simplify_table = TRUE` are listed below.  Unless otherwise specified, all data is returned as a character string to preserve the value of leading and trailing zeroes.
#'  \itemize{
#'     \item series_id - The unique OEWS series identifier.
#'     \item year - The year to which the estimate refers.  Because OEWS is not time series data, this is always the most recent year.
#'     \item value - Numeric. The value of the given data type, for the given area, in the given industry and occupation.
#'     \item seasonal - Whether or not the data is seasonally adjusted.
#'     \item areatype_code - Code representing the type of area (National ("N"), Statewide ("S"), or Local ("M")).
#'     \item industry_code - NAICS code of the industry.
#'     \item occupation_code - SOC code of the occupation. Description given by occupation_name.
#'     \item datatype_code - Lookup code for the data type of a given row.  Description given by datatype_name.
#'     \item state_code - Two-digit FIPS code for the state.
#'     \item area_code - The unique OEWS code for a substate area. Description given by area_name.
#'     \item series_title - Descriptive title of the full series ID.
#'     \item occupation_name - The text description of the occupation.
#'     \item occupation_description - More detailed description of the tasks associated with the occupation.
#'     \item area_name - The text description of the area.
#'     \item datatype_name - The text description of the type of data represented by `value`.
#'
#'   }
#' @export
#'
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr left_join
#' @importFrom dplyr select
#' @examples
#' \donttest{
#' # Download current OEWS data
#' oews_data <- get_oews()
#'
#' # View available occupations
#' unique(oews_data$occupation_name)
#'
#' # Filter for specific occupation
#' software_devs <- oews_data[grepl("Software", occupation_name)]
#'
#' # Get full diagnostic object if needed
#' oews_with_diagnostics <- get_oews(return_diagnostics = TRUE)
#' print_bls_warnings(oews_with_diagnostics)
#'}
#'

get_oews <- function(
  simplify_table = TRUE,
  suppress_warnings = TRUE,
  return_diagnostics = FALSE,
  fast_read = TRUE,
  cache = check_bls_cache_env()
) {
  if (fast_read) {
    download_urls <- c(
      "data" = "https://download.bls.gov/pub/time.series/oe/oe.data.0.Current",
      "occupation" = "https://download.bls.gov/pub/time.series/oe/oe.occupation",
      "area" = "https://download.bls.gov/pub/time.series/oe/oe.area",
      "datatype" = "https://download.bls.gov/pub/time.series/oe/oe.datatype"
    )
  } else {
    # Define all URLs we need to download
    download_urls <- c(
      "data" = "https://download.bls.gov/pub/time.series/oe/oe.data.0.Current",
      "series" = "https://download.bls.gov/pub/time.series/oe/oe.series",
      "occupation" = "https://download.bls.gov/pub/time.series/oe/oe.occupation",
      "area" = "https://download.bls.gov/pub/time.series/oe/oe.area",
      "datatype" = "https://download.bls.gov/pub/time.series/oe/oe.datatype"
    )
  }

  # Download all files
  downloads <- download_bls_files(
    download_urls,
    suppress_warnings = suppress_warnings,
    cache = cache
  )

  # Extract data from downloads
  oews_current <- get_bls_data(downloads$data)
  if (!fast_read) {
    oews_series <- get_bls_data(downloads$series)
  }
  oews_occupation <- get_bls_data(downloads$occupation)
  oews_area <- get_bls_data(downloads$area)
  oews_datatype <- get_bls_data(downloads$datatype)

  if (fast_read) {
    oews <- oews_current |>
      dplyr::select(-footnote_codes) |>
      dplyr::mutate(
        seasonal = substr(series_id, 3, 3),
        areatype_code = substr(series_id, 4, 4),
        area_code = substr(series_id, 5, 11),
        industry_code = substr(series_id, 12, 17),
        occupation_code = substr(series_id, 18, 23),
        datatype_code = substr(series_id, 24, 25)
      ) |>
      dplyr::left_join(oews_occupation, by = "occupation_code") |>
      dplyr::left_join(oews_area, by = c("areatype_code", "area_code")) |>
      dplyr::left_join(oews_datatype, by = "datatype_code") |>
      dplyr::mutate(value = as.numeric(value))
  } else {
    # Join all the data together -- No fast_read
    oews <- oews_current |>
      dplyr::select(-footnote_codes) |>
      dplyr::left_join(oews_series, by = "series_id") |>
      dplyr::left_join(oews_occupation, by = "occupation_code") |>
      dplyr::left_join(
        oews_area,
        by = c("areatype_code", "state_code", "area_code")
      ) |>
      dplyr::left_join(oews_datatype, by = "datatype_code") |>
      dplyr::mutate(value = as.numeric(value))
  }

  # Track processing steps
  if (fast_read) {
    processing_steps <- c(
      "Derived join columns from series_id.",
      "Joined occupation, area, and datatype metadata",
      "Converted values to numeric"
    )
  } else {
    processing_steps <- c(
      "Joined series, occupation, area, and datatype metadata",
      "Converted values to numeric"
    )
  }

  if (simplify_table) {
    if (fast_read) {
      oews <- oews |>
        dplyr::select(-c(period, selectable, sort_sequence, display_level))

      processing_steps <- c(
        processing_steps,
        "Removed columns per simplify_table."
      )
    } else {
      oews <- oews |>
        dplyr::select(
          -c(
            period,
            sector_code,
            footnote_codes,
            begin_year,
            begin_period,
            end_year,
            end_period,
            selectable,
            sort_sequence,
            display_level
          )
        )

      processing_steps <- c(
        processing_steps,
        "Removed columns per simplify_table."
      )
    }
  }

  # Create the BLS data collection object
  bls_collection <- create_bls_object(
    data = oews,
    downloads = downloads,
    data_type = "OEWS",
    processing_steps = processing_steps
  )

  # Return either the collection object or just the data
  if (return_diagnostics) {
    return(bls_collection)
  } else {
    return(oews)
  }

  return(result)
}

#' Download OEWS Area Definitions
#'
#' @param ref_year Four-digit year (converted to integer). The year for which to retrieve OEWS area definitions. Valid values are 2024 through current release year. Prior years included Township codes, which change the structure of the file.
#' @param silent Logical. If TRUE (default), suppress console output
#' @param geometry Logical.  If TRUE (default), downloads shapefiles for OEWS area definitions using `tigris::counties()` and `tigris::shift_geometry()` to render Alaska, Hawaii, and Puerto Rico with a focus on the area of the continental United States.
#'
#' @return Data table which maps individual counties to OEWS area definitions.
#'   \itemize{
#'     \item fips_code - The State FIPS code
#'     \item state_name - The state name
#'     \item state_abb - The state two-character postal abbreviation
#'     \item oews_area_code - The OEWS area code defining the metropolitan area or nonmetropolitan area the county belongs to.
#'     \item oews_area_name - The OEWS area name
#'     \item county_code - The FIPS code for the county
#'     \item county_name - The county name
#'     }
#'
#' @export
#'
#' @importFrom httr GET
#' @importFrom httr write_disk
#' @importFrom httr add_headers
#' @importFrom readxl read_excel
#' @importFrom tigris counties
#' @importFrom sf st_union
#' @importFrom dplyr select
#' @importFrom dplyr left_join
#' @importFrom dplyr group_by
#' @importFrom dplyr summarize
#'
#' @examples
#' \donttest{
#'  # Get OEWS area definitions without shapefiles and with processing messages.
#'  test <- get_oews_areas(ref_year = 2024, geometry = FALSE, silent = FALSE)
#'
#' }
#'
get_oews_areas <- function(ref_year, silent = TRUE, geometry = TRUE) {
  # Validate ref_year input
  current_year <- as.integer(format(Sys.Date(), "%Y"))
  min_year <- 2024
  max_year <- current_year - 1

  if (is.na(as.integer(ref_year)) || length(ref_year) != 1) {
    stop("`ref_year` must be coercable to a single integer value.")
  }

  dl_year <- as.integer(ref_year)

  if (dl_year < min_year || dl_year > max_year) {
    stop(sprintf(
      "`ref_year` must be between %d and %d. Estimates are generally released in April for the prior year.",
      min_year,
      max_year
    ))
  }

  # Create download URL
  oews_url <- paste0(
    "https://www.bls.gov/oes/",
    dl_year,
    "/may/area_definitions_m",
    dl_year,
    ".xlsx"
  )

  headers <- c(
    "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    "Accept-Encoding" = "gzip, deflate, br",
    "Accept-Language" = "en-US,en;q=0.9",
    "Connection" = "keep-alive",
    "Host" = "www.bls.gov",
    "Referer" = "https://www.bls.gov/oes/",
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
  if (!silent) {
    message("Downloading OEWS area definitions from BLS.")
  }
  response <- httr::GET(
    oews_url,
    httr::write_disk(tf <- tempfile(fileext = ".xlsx")),
    httr::add_headers(.headers = headers)
  )

  # Check for successful response
  httr::stop_for_status(response)

  # Track processing steps
  processing_steps <- character(0)

  # Read and process Excel file
  if (!silent) {
    message(paste0(
      "Processing OEWS area definition Excel file for ",
      dl_year,
      "."
    ))
  }
  oews_areas <- readxl::read_excel(
    tf,
    skip = 1,
    col_types = c("text", "text", "text", "text", "text", "text", "text"),
    col_names = c(
      "fips_code",
      "state_name",
      "state_abb",
      "oews_area_code",
      "oews_area_name",
      "county_code",
      "county_name"
    )
  ) |>
    dplyr::mutate(
      oews_area_code = stringr::str_pad(
        oews_area_code,
        width = 7,
        side = "left",
        pad = "0"
      )
    )

  # Clean up temporary file
  unlink(tf)

  if (geometry == TRUE) {
    if (!silent) {
      message("Creating OEWS shapefiles")
    }

    oews_area <- oews_areas |>
      dplyr::mutate(GEOID = paste0(fips_code, county_code)) |>
      dplyr::select(GEOID, oews_area_code, oews_area_name)

    area_shapes <- tigris::counties(year = dl_year, progress_bar = FALSE) |>
      tigris::shift_geometry() |>
      dplyr::select(GEOID, geometry)

    oews_areas <- area_shapes |>
      dplyr::left_join(oews_area, by = "GEOID") |>
      dplyr::group_by(oews_area_name, oews_area_code) |>
      dplyr::summarize(geometry = sf::st_union(geometry), .groups = "drop")
  }

  return(oews_areas)
}
