#' List Available States for CES Data
#'
#' @description
#' Lists all available U.S. states and territories that can be used with the
#' `states` parameter in `get_ces()` function.
#'
#' @return A character vector of available state/territory abbreviations
#' @export
#' @examples
#' # See all available states
#' list_ces_states()
#'
#' # Use with get_ces
#' # ces_data <- get_ces(states = c("MA", "NY"))  # All industries for these states
list_ces_states <- function() {
  states <- c(
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
    "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
    "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
    "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "PR",
    "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "VI", "WA",
    "WV", "WI", "WY"
  )
  return(states)
}

#' List Available Industry Filters for CES Data
#'
#' @description
#' Lists all available industry categories that can be used with the
#' `industry_filter` parameter in `get_ces()` function. These filters allow
#' you to download specific industry data instead of the complete dataset.
#'
#' @param show_descriptions Logical. If TRUE, returns a data frame with
#'   filter names and descriptions. If FALSE, returns just the filter names.
#' @return A character vector of industry filter names, or a data frame
#'   with names and descriptions if show_descriptions = TRUE
#' @export
#' @examples
#' # See all available industry filters
#' list_ces_industries()
#'
#' # See filters with descriptions
#' list_ces_industries(show_descriptions = TRUE)
#'
#' # Use with get_ces
#' # manufacturing_data <- get_ces(industry_filter = "manufacturing")  # All states
list_ces_industries <- function(show_descriptions = FALSE) {

  industry_filters <- c(
    "current_year", "total_nonfarm", "total_nonfarm_statewide", "total_private",
    "goods_producing", "service_providing", "private_service_providing",
    "mining_logging", "mining_logging_construction", "construction",
    "manufacturing", "durable_goods", "nondurable_goods", "trade_trans_utilities",
    "wholesale_trade", "retail_trade", "trans_utilities", "information",
    "financial_activities", "prof_business_services", "edu_health_services",
    "leisure_hospitality", "other_services", "government"
  )

  if (!show_descriptions) {
    return(industry_filters)
  }

  # Create descriptions for each filter
  descriptions <- c(
    "Recent data across all industries (2006-present)",
    "Total non-farm employment (all industries, all years)",
    "Total non-farm employment (statewide level)",
    "Total private sector employment",
    "Goods-producing industries",
    "Service-providing industries",
    "Private service-providing industries",
    "Mining and logging",
    "Mining, logging, and construction",
    "Construction",
    "Manufacturing",
    "Durable goods manufacturing",
    "Non-durable goods manufacturing",
    "Trade, transportation, and utilities",
    "Wholesale trade",
    "Retail trade",
    "Transportation and utilities",
    "Information services",
    "Financial activities",
    "Professional and business services",
    "Education and health services",
    "Leisure and hospitality",
    "Other services",
    "Government"
  )

  result <- data.frame(
    filter = industry_filters,
    description = descriptions,
    stringsAsFactors = FALSE
  )

  return(result)
}

#' Show CES Data Filtering Options
#'
#' @description
#' Displays a comprehensive overview of all filtering options available
#' for the `get_ces()` function, including states, industries, and usage examples.
#'
#' @export
#' @examples
#' # See all filtering options
#' show_ces_options()
show_ces_options <- function() {
  cat("=== BLS Current Employment Statistics (CES) Filtering Options ===\n\n")

  cat("AVAILABLE STATES (", length(list_ces_states()), " total):\n", sep = "")
  states <- list_ces_states()
  # Print states in rows of 10
  for (i in seq(1, length(states), 10)) {
    end_idx <- min(i + 9, length(states))
    cat("  ", paste(states[i:end_idx], collapse = ", "), "\n")
  }

  cat("\nAVAILABLE INDUSTRY FILTERS (", length(list_ces_industries()), " total):\n", sep = "")
  industries <- list_ces_industries(show_descriptions = TRUE)
  for (i in 1:nrow(industries)) {
    cat("  ", sprintf("%-25s", industries$filter[i]), ": ", industries$description[i], "\n", sep = "")
  }

  cat("USAGE EXAMPLES:\n")
  cat("  # Specific states (all industries, all years)\n")
  cat("  ces_states <- get_ces(states = c('MA', 'NY', 'CT'))\n\n")

  cat("  # Specific industry (all states, 2007-present)\n")
  cat("  ces_manufacturing <- get_ces(industry_filter = 'manufacturing')\n\n")

  cat("  # Current year data (all states and industries, 2006-present)\n")
  cat("  ces_current <- get_ces(current_year_only = TRUE)\n\n")

  cat("  # Complete dataset (all states, industries, and years - slowest)\n")
  cat("  ces_all <- get_ces()\n\n")

  cat("Performance: Filtering reduces download time by 50-90% vs. full dataset!\n")
  cat("Note: Parameters are mutually exclusive - choose only one filtering option.\n")
}
