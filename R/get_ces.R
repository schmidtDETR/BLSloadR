#' Download Current Employment Statistics (CES) Data
#'
#' This function downloads Current Employment Statistics data from the Bureau of Labor Statistics.
#' The data includes national, regional, state, and substate employment statistics.
#' By default, all available areas, data types, and periods are included.
#'
#' @param states Character vector of state abbreviations to download (e.g., c("MA", "NY", "CA")).
#'   If specified, downloads only these states (all industries, all years).
#'   Cannot be combined with industry_filter or current_year_only.
#'   Use `list_ces_states()` to see all available states.
#' @param industry_filter Character string specifying industry category to download.
#'   If specified, downloads this industry for all states (2007-present).
#'   Cannot be combined with states or current_year_only.
#'   Use `list_ces_industries()` to see all available industry filters.
#' @param current_year_only Logical. If TRUE, downloads the current year file
#'   which contains all states and industries for recent years (2006-present).
#'   Cannot be combined with states or industry_filter. If FALSE (default), uses other parameters.
#' @param transform Logical. If TRUE (default), converts employment values from thousands
#'   to actual counts by multiplying by 1000 for specific data types (codes 1, 6, 26)
#'   and removes ", In Thousands" from data type labels.
#' @param monthly_only Logical. If TRUE (default), filters out annual data (period M13).
#' @param simplify_table Logical. If TRUE (default), removes excess columns and creates
#'   a date column from Year and Period in the original data.
#' @param suppress_warnings Logical. If TRUE (default), suppress individual download warnings and diagnostic messages
#'   for cleaner output during batch processing. If FALSE, returns the data and prints warnings and messages to the console.
#' @param return_diagnostics Logical. If FALSE (default), returns only the data. If TRUE,
#'   returns the full bls_data_collection object with diagnostics.
#' @param cache Logical.  Uses USE_BLS_CACHE environment variable, or defaults to FALSE. If TRUE, will download a cached file from BLS server and update cache if BLS server indicates an updated file.
#'
#' @return By default, returns a data.table with CES data. If return_diagnostics = TRUE,
#'   returns a bls_data_collection object containing data and comprehensive diagnostics.
#'
#' @details
#' **Performance Notes:** The default behavior downloads a very large file (~500MB+) containing
#' all states and industries, which can take several minutes. For faster downloads, consider:
#' \itemize{
#'   \item Use \code{states = c("MA", "NY")} to download only specific states
#'   \item Use \code{industry_filter = "total_nonfarm"} for summary employment data only
#'   \item Use \code{current_year_only = TRUE} for recent data only (2006-present)
#' }
#'
#' **State Codes:** Use standard two-letter state abbreviations (e.g., "MA", "CA", "NY").
#' Puerto Rico = "PR", Virgin Islands = "VI", District of Columbia = "DC".
#'
#' **Industry Filters:** Available options include:
#' \itemize{
#'   \item "total_nonfarm" - Total non-farm employment summary
#'   \item "total_private" - Private sector totals (2007-present)
#'   \item "manufacturing" - Manufacturing sector (2007-present)
#'   \item "construction" - Construction sector (2007-present)
#'   \item "retail_trade" - Retail trade sector (2007-present)
#'   \item "government" - Government sector (2007-present)
#'   \item And others - see BLS documentation for full list
#' }
#'
#' @seealso
#' \code{\link{list_ces_states}()} to see available states,
#' \code{\link{list_ces_industries}()} to see available industry filters,
#' \code{\link{show_ces_options}()} for a comprehensive overview of filtering options.
#'
#' @export
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr left_join
#' @importFrom dplyr select
#' @importFrom dplyr if_else
#' @importFrom stringr str_remove
#' @importFrom lubridate ym
#' @examples
#' \donttest{
#' # Fast download: Massachusetts and Connecticut data only (all industries)
#' ces_states <- get_ces(states = c("MA", "CT"))
#'
#' # Fast download: Manufacturing data for all states
#' ces_manufacturing <- get_ces(industry_filter = "manufacturing")
#'
#' # Fast download: Current year data for all states and industries
#' ces_current <- get_ces(current_year_only = TRUE)
#'
#' # Complete dataset (slower - all states, industries, and years)
#' ces_all <- get_ces()
#'
#' # Download with full diagnostics if needed
#' ces_result <- get_ces(states = "MA", return_diagnostics = TRUE)
#' ces_data <- get_bls_data(ces_result)
#'
#' # Check for download issues
#' if (has_bls_issues(ces_result)) {
#'   print_bls_warnings(ces_result)
#' }
#' }
get_ces <- function(states = NULL, industry_filter = NULL, current_year_only = FALSE,
                    transform = TRUE, monthly_only = TRUE, simplify_table = TRUE,
                    suppress_warnings = TRUE, return_diagnostics = FALSE, cache = check_bls_cache_env()) {


  # Define state-specific URLs mapping
  state_urls <- list(
    "AL" = "https://download.bls.gov/pub/time.series/sm/sm.data.1.Alabama",
    "AK" = "https://download.bls.gov/pub/time.series/sm/sm.data.2.Alaska",
    "AZ" = "https://download.bls.gov/pub/time.series/sm/sm.data.3.Arizona",
    "AR" = "https://download.bls.gov/pub/time.series/sm/sm.data.4.Arkansas",
    "CA" = "https://download.bls.gov/pub/time.series/sm/sm.data.5c.California",
    "CO" = "https://download.bls.gov/pub/time.series/sm/sm.data.6.Colorado",
    "CT" = "https://download.bls.gov/pub/time.series/sm/sm.data.7.Connecticut",
    "DE" = "https://download.bls.gov/pub/time.series/sm/sm.data.8.Delaware",
    "DC" = "https://download.bls.gov/pub/time.series/sm/sm.data.9.DC",
    "FL" = "https://download.bls.gov/pub/time.series/sm/sm.data.10b.Florida",
    "GA" = "https://download.bls.gov/pub/time.series/sm/sm.data.11.Georgia",
    "HI" = "https://download.bls.gov/pub/time.series/sm/sm.data.12.Hawaii",
    "ID" = "https://download.bls.gov/pub/time.series/sm/sm.data.13.Idaho",
    "IL" = "https://download.bls.gov/pub/time.series/sm/sm.data.14.Illinois",
    "IN" = "https://download.bls.gov/pub/time.series/sm/sm.data.15.Indiana",
    "IA" = "https://download.bls.gov/pub/time.series/sm/sm.data.16.Iowa",
    "KS" = "https://download.bls.gov/pub/time.series/sm/sm.data.17.Kansas",
    "KY" = "https://download.bls.gov/pub/time.series/sm/sm.data.18.Kentucky",
    "LA" = "https://download.bls.gov/pub/time.series/sm/sm.data.19.Louisiana",
    "ME" = "https://download.bls.gov/pub/time.series/sm/sm.data.20.Maine",
    "MD" = "https://download.bls.gov/pub/time.series/sm/sm.data.21.Maryland",
    "MA" = "https://download.bls.gov/pub/time.series/sm/sm.data.22.Massachusetts",
    "MI" = "https://download.bls.gov/pub/time.series/sm/sm.data.23b.Michigan",
    "MN" = "https://download.bls.gov/pub/time.series/sm/sm.data.24.Minnesota",
    "MS" = "https://download.bls.gov/pub/time.series/sm/sm.data.25.Mississippi",
    "MO" = "https://download.bls.gov/pub/time.series/sm/sm.data.26.Missouri",
    "MT" = "https://download.bls.gov/pub/time.series/sm/sm.data.27.Montana",
    "NE" = "https://download.bls.gov/pub/time.series/sm/sm.data.28.Nebraska",
    "NV" = "https://download.bls.gov/pub/time.series/sm/sm.data.29.Nevada",
    "NH" = "https://download.bls.gov/pub/time.series/sm/sm.data.30.NewHampshire",
    "NJ" = "https://download.bls.gov/pub/time.series/sm/sm.data.31.NewJersey",
    "NM" = "https://download.bls.gov/pub/time.series/sm/sm.data.32.NewMexico",
    "NY" = "https://download.bls.gov/pub/time.series/sm/sm.data.33b.NewYork",
    "NC" = "https://download.bls.gov/pub/time.series/sm/sm.data.34.NorthCarolina",
    "ND" = "https://download.bls.gov/pub/time.series/sm/sm.data.35.NorthDakota",
    "OH" = "https://download.bls.gov/pub/time.series/sm/sm.data.36.Ohio",
    "OK" = "https://download.bls.gov/pub/time.series/sm/sm.data.37.Oklahoma",
    "OR" = "https://download.bls.gov/pub/time.series/sm/sm.data.38.Oregon",
    "PA" = "https://download.bls.gov/pub/time.series/sm/sm.data.39b.Pennsylvania",
    "PR" = "https://download.bls.gov/pub/time.series/sm/sm.data.40.PuertoRico",
    "RI" = "https://download.bls.gov/pub/time.series/sm/sm.data.41.RhodeIsland",
    "SC" = "https://download.bls.gov/pub/time.series/sm/sm.data.42.SouthCarolina",
    "SD" = "https://download.bls.gov/pub/time.series/sm/sm.data.43.SouthDakota",
    "TN" = "https://download.bls.gov/pub/time.series/sm/sm.data.44.Tennessee",
    "TX" = "https://download.bls.gov/pub/time.series/sm/sm.data.45c.Texas",
    "UT" = "https://download.bls.gov/pub/time.series/sm/sm.data.46.Utah",
    "VT" = "https://download.bls.gov/pub/time.series/sm/sm.data.47.Vermont",
    "VA" = "https://download.bls.gov/pub/time.series/sm/sm.data.48.Virginia",
    "VI" = "https://download.bls.gov/pub/time.series/sm/sm.data.49.VirginIslands",
    "WA" = "https://download.bls.gov/pub/time.series/sm/sm.data.50.Washington",
    "WV" = "https://download.bls.gov/pub/time.series/sm/sm.data.51.WestVirginia",
    "WI" = "https://download.bls.gov/pub/time.series/sm/sm.data.52.Wisconsin",
    "WY" = "https://download.bls.gov/pub/time.series/sm/sm.data.53.Wyoming"
  )

  # Define industry-specific URLs mapping (current data, 2007-present)
  industry_urls <- list(
    "current_year" = "https://download.bls.gov/pub/time.series/sm/sm.data.0.Current",
    "total_nonfarm" = "https://download.bls.gov/pub/time.series/sm/sm.data.54.TotalNonFarm.All",
    "total_nonfarm_statewide" = "https://download.bls.gov/pub/time.series/sm/sm.data.55.TotalNonFarmStatewide.All",
    "total_private" = "https://download.bls.gov/pub/time.series/sm/sm.data.56.TotalPrivate.Current",
    "goods_producing" = "https://download.bls.gov/pub/time.series/sm/sm.data.57.GoodsProducing.Current",
    "service_providing" = "https://download.bls.gov/pub/time.series/sm/sm.data.58.ServiceProviding.Current",
    "private_service_providing" = "https://download.bls.gov/pub/time.series/sm/sm.data.59.PrivateServiceProviding.Current",
    "mining_logging" = "https://download.bls.gov/pub/time.series/sm/sm.data.60.MiningandLogging.Current",
    "mining_logging_construction" = "https://download.bls.gov/pub/time.series/sm/sm.data.61.MiningLoggingConstr.Current",
    "construction" = "https://download.bls.gov/pub/time.series/sm/sm.data.62.Construction.Current",
    "manufacturing" = "https://download.bls.gov/pub/time.series/sm/sm.data.63.Manufacturing.Current",
    "durable_goods" = "https://download.bls.gov/pub/time.series/sm/sm.data.64.DurableGoods.Current",
    "nondurable_goods" = "https://download.bls.gov/pub/time.series/sm/sm.data.65.NonDurableGoods.Current",
    "trade_trans_utilities" = "https://download.bls.gov/pub/time.series/sm/sm.data.66.TradeTransUtilities.Current",
    "wholesale_trade" = "https://download.bls.gov/pub/time.series/sm/sm.data.67.WholesaleTrade.Current",
    "retail_trade" = "https://download.bls.gov/pub/time.series/sm/sm.data.68.RetailTrade.Current",
    "trans_utilities" = "https://download.bls.gov/pub/time.series/sm/sm.data.69.TransUtilities.Current",
    "information" = "https://download.bls.gov/pub/time.series/sm/sm.data.70.Information.Current",
    "financial_activities" = "https://download.bls.gov/pub/time.series/sm/sm.data.71.FinancialActivities.Current",
    "prof_business_services" = "https://download.bls.gov/pub/time.series/sm/sm.data.72.ProfBusSrvc.Current",
    "edu_health_services" = "https://download.bls.gov/pub/time.series/sm/sm.data.73.EduHealthSrvc.Current",
    "leisure_hospitality" = "https://download.bls.gov/pub/time.series/sm/sm.data.74.LeisureandHospitality.Current",
    "other_services" = "https://download.bls.gov/pub/time.series/sm/sm.data.75.OtherServices.Current",
    "government" = "https://download.bls.gov/pub/time.series/sm/sm.data.76.Government.Current"
  )

  # Validate inputs
  if (!is.null(states)) {
    states <- toupper(states)
    invalid_states <- states[!states %in% names(state_urls)]
    if (length(invalid_states) > 0) {
      stop("Invalid state codes: ", paste(invalid_states, collapse = ", "),
           ". Use standard two-letter abbreviations like 'MA', 'NY', 'CA'.")
    }
  }

  if (!is.null(industry_filter)) {
    if (!industry_filter %in% names(industry_urls)) {
      stop("Invalid industry_filter: '", industry_filter, "'. ",
           "Valid options: ", paste(names(industry_urls), collapse = ", "))
    }
  }

  # Check for conflicting parameters (mutually exclusive)
  param_count <- sum(!is.null(states), !is.null(industry_filter), current_year_only)
  if (param_count > 1) {
    stop("Parameters 'states', 'industry_filter', and 'current_year_only' are mutually exclusive. ",
         "Choose only one filtering option.")
  }

  # Build data URLs based on filters (mutually exclusive)
  data_urls <- c()

  if (current_year_only) {
    # Current year file contains all states/industries for current year
    data_urls <- c("Main Data" = industry_urls[["current_year"]])
    if(!suppress_warnings){
      message("Using current year data file (2006-present, all states and industries)")
    }
  } else if (!is.null(industry_filter)) {
    # Use industry-specific file (all states for this industry)
    data_urls <- c("Main Data" = industry_urls[[industry_filter]])
    if(!suppress_warnings){
      message("Using industry filter: ", industry_filter, " (2007-present data, all states)")
    }
  } else if (!is.null(states)) {
    # Use state-specific files (all industries for these states)
    state_data_urls <- state_urls[states]
    names(state_data_urls) <- paste("State Data -", names(state_data_urls))
    data_urls <- state_data_urls
    if(!suppress_warnings){
      message("Downloading data for states: ", paste(states, collapse = ", "), " (all industries)")
    }
  } else {
    # Use the large AllData file (original behavior)
    data_urls <- c("Main Data" = "https://download.bls.gov/pub/time.series/sm/sm.data.1.AllData")
    if(!suppress_warnings){
      message("Downloading complete dataset (all states, all industries, all years - this may take several minutes)...")
    }
  }

  # Define URLs for CES metadata files (always needed)
  ces_urls <- c(
    data_urls,  # Add the data URLs we determined above
    "Series Metadata" = "https://download.bls.gov/pub/time.series/sm/sm.series",
    "Industry Codes" = "https://download.bls.gov/pub/time.series/sm/sm.industry",
    "State Codes" = "https://download.bls.gov/pub/time.series/sm/sm.state",
    "Area Codes" = "https://download.bls.gov/pub/time.series/sm/sm.area",
    "Data Types" = "https://download.bls.gov/pub/time.series/sm/sm.data_type",
    "Supersector Codes" = "https://download.bls.gov/pub/time.series/sm/sm.supersector"
  )

  # Download all files
  if(!suppress_warnings){message("Starting CES data download...\n")}
  downloads <- download_bls_files(ces_urls, suppress_warnings = suppress_warnings, cache = cache)

  # Extract data from downloads - handle multiple data files when downloading by states
  if (!is.null(states) && !current_year_only && is.null(industry_filter)) {
    # Multiple state files - combine them
    state_data_list <- list()
    for (state in states) {
      state_file_name <- paste("State Data -", state)
      if (state_file_name %in% names(downloads)) {
        state_data_list[[state]] <- get_bls_data(downloads[[state_file_name]])
      }
    }
    data_main <- do.call(rbind, state_data_list)
  } else {
    # Single data file (industry filter, current year, or all data)
    main_data_name <- names(downloads)[grepl("Data", names(downloads))][1]
    data_main <- get_bls_data(downloads[[main_data_name]])
  }

  # Extract metadata (always needed)
  data_series <- get_bls_data(downloads$`Series Metadata`)
  data_industry <- get_bls_data(downloads$`Industry Codes`)
  data_state <- get_bls_data(downloads$`State Codes`)
  data_area <- get_bls_data(downloads$`Area Codes`)
  data_types <- get_bls_data(downloads$`Data Types`)
  data_supersector <- get_bls_data(downloads$`Supersector Codes`)

  # Track processing steps
  processing_steps <- character(0)

  # Combine all data
  if(!suppress_warnings){message("Combining datasets...\n")}
  ces_data <- data_main |>
    dplyr::select(-footnote_codes) |>
    dplyr::left_join(data_series, by = "series_id") |>
    #dplyr::select(-footnote_codes) |>
    dplyr::left_join(data_industry, by = "industry_code") |>
    dplyr::left_join(data_state, by = "state_code") |>
    dplyr::left_join(data_area, by = "area_code") |>
    dplyr::left_join(data_types, by = "data_type_code") |>
    dplyr::left_join(data_supersector, by = "supersector_code") |>
    dplyr::mutate(value = as.numeric(value),
                  industry_code = substr(series_id,11,18)) |>
    dplyr::filter(!is.na(value))

  processing_steps <- c(processing_steps, "joined_metadata", "converted_values", "removed_na")

  if(transform){
    if(!suppress_warnings){message("Applying value transformations...\n")}
    ces_data <- ces_data |>
      dplyr::mutate(
        value = if_else(
          data_type_code %in% c("01","06","26"),
          value * 1000,
          value
        ),
        data_type_text = stringr::str_remove(data_type_text, ", In Thousands")
      )
    processing_steps <- c(processing_steps, "transformed_values")
  }

  if(monthly_only){
    if(!suppress_warnings){message("Filtering to monthly data only...\n")}
    ces_data <- ces_data |>
      dplyr::filter(period != "M13")
    processing_steps <- c(processing_steps, "monthly_only")
  }

  if(simplify_table){
    if(!suppress_warnings){message("Simplifying table structure...\n")}
    ces_data <- ces_data |>
      dplyr::mutate(date = lubridate::ym(paste0(year,period))) |>
      dplyr::select(-c(benchmark_year:end_period,year,period)) |>
      dplyr::filter(state_code != "00")
    processing_steps <- c(processing_steps, "simplified_table", "added_date_column")
  }

  # Create BLS data object with diagnostics
  result <- create_bls_object(
    data = ces_data,
    downloads = downloads,
    data_type = "CES",
    processing_steps = processing_steps
  )

  # Print summary
  if(!suppress_warnings){
    message("CES data download complete!\n")
    message("Final dataset dimensions: ", paste(dim(ces_data), collapse = " x "), "\n")

    if (!is.null(states)) {
      message("States: ", paste(states, collapse = ", "), "\n")
    }
    if (!is.null(industry_filter)) {
      message("Industry filter: ", industry_filter, "\n")
    }
    if (current_year_only) {
      message("Dataset: Current year data (2006-present, all states and industries)\n")
    }
    if (is.null(states) && is.null(industry_filter) && !current_year_only) {
      message("Dataset: Complete CES data (all states, industries, and years)\n")
    }
  }

  if (has_bls_issues(result)) {
    if (!suppress_warnings) {
      message("\nDownload Issues Summary:\n")
      message("Total warnings:", result$summary$total_warnings, "\n")
      message("Files with issues:", result$summary$files_with_issues, "of", result$summary$files_downloaded, "\n")
      message("Run with return_diagnostics = TRUE and use print_bls_warnings() for details\n")
    }
  } else {
    message("No download issues detected.\n")
  }

  # Return based on user preference
  if (return_diagnostics) {
    return(result)
  } else {
    # Store diagnostics as attributes for later access if needed
    attr(ces_data, "bls_diagnostics") <- result
    return(ces_data)
  }
}
