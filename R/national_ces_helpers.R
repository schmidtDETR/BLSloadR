#' List Available National CES Dataset Options
#'
#' This function displays the available dataset filtering options for the
#' get_national_ces() function, helping users understand what specialized
#' datasets are available for download.
#'
#' @param show_descriptions Logical. If TRUE, shows detailed descriptions
#'   of each dataset option. If FALSE (default), shows only the filter names.
#'
#' @return A data frame with dataset filter options and their descriptions.
#'
#' @examples
#' # Show available dataset filters
#' list_national_ces_options()
#' 
#' # Show detailed descriptions
#' list_national_ces_options(show_descriptions = TRUE)
#'
#' @export
list_national_ces_options <- function(show_descriptions = FALSE) {
  
  datasets <- data.frame(
    filter = c(
      "all_data",
      "current_seasonally_adjusted", 
      "real_earnings_all_employees",
      "real_earnings_production"
    ),
    description = c(
      "Complete national CES dataset - all series and full history",
      "Seasonally adjusted all-employee series only (faster download)",
      "Real earnings data (1982-84 dollars) for all employees",
      "Real earnings data (1982-84 dollars) for production employees"
    ),
    stringsAsFactors = FALSE
  )
  
  if (show_descriptions) {
    return(datasets)
  } else {
    return(datasets$filter)
  }
}

#' Show National CES Dataset Options and Usage Examples
#'
#' This function provides a comprehensive overview of the national CES dataset
#' filtering options available in get_national_ces(), including examples
#' of how to use each option.
#'
#' @return Prints formatted information to the console.
#'
#' @examples
#' show_national_ces_options()
#'
#' @export
show_national_ces_options <- function() {
  cat("=== BLS National Current Employment Statistics (CES) Dataset Options ===\n\n")
  
  cat("📊 AVAILABLE DATASETS (4 options):\n")
  datasets <- list_national_ces_options(show_descriptions = TRUE)
  
  for(i in 1:nrow(datasets)) {
    cat("  ", datasets$filter[i], ": ", datasets$description[i], "\n")
  }
  
  cat("\n💡 USAGE EXAMPLES:\n")
  cat("  # Complete dataset (largest file, ~340MB)\n")
  cat("  ces_complete <- get_national_ces(dataset_filter = 'all_data')\n\n")
  
  cat("  # Seasonally adjusted data only (faster download)\n")
  cat("  ces_seasonal <- get_national_ces(dataset_filter = 'current_seasonally_adjusted')\n\n")
  
  cat("  # Real earnings for all employees\n")
  cat("  ces_earnings_all <- get_national_ces(dataset_filter = 'real_earnings_all_employees')\n\n")
  
  cat("  # Real earnings for production employees\n")
  cat("  ces_earnings_prod <- get_national_ces(dataset_filter = 'real_earnings_production')\n\n")
  
  cat("⚡ Performance: Specialized datasets reduce download time significantly!\n")
  cat("📝 Note: All options include metadata files for context and labels.\n")
}