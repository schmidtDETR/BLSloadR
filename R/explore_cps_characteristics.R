#' Explore Available CPS (LN) Characteristics and Codes
#'
#' This helper function allows users to discover available characteristics
#' and their valid codes in the BLS Current Population Survey (LN) dataset.
#' It can list all available characteristics or show the valid codes for
#' specific characteristics.
#'
#' @param characteristic Optional character string specifying which characteristic
#'   to explore (e.g., "ages", "sexs", "race", "education"). If NULL, returns a
#'   list of all available characteristics. Do not include "_code" suffix.
#' @param cache_dir Optional character string specifying the directory for cached files.
#'   If NULL, uses R's temporary directory via `tempdir()`.
#' @param verbose Logical. If TRUE, print informative messages. Default is TRUE.
#'
#' @return If `characteristic` is NULL, returns a data.frame with columns:
#'   \itemize{
#'     \item characteristic: Name of the characteristic (without _code suffix)
#'     \item code_column: The column name used in filtering (with _code suffix)
#'     \item description: Brief description of the characteristic
#'   }
#'
#'   If `characteristic` is specified, returns a data.frame showing all valid
#'   codes and their text descriptions for that characteristic.
#'
#' @details
#' This function downloads the ln.series file and associated mapping files
#' from the BLS server to identify available characteristics. The results
#' are cached locally to avoid repeated downloads.
#'
#' Common characteristics include:
#' \itemize{
#'   \item ages: Age groups (e.g., 16+ years, 20-24 years)
#'   \item sexs: Sex/gender categories
#'   \item race: Racial categories
#'   \item education: Educational attainment levels
#'   \item periodicity: Data frequency (monthly, quarterly, annual)
#'   \item seasonal: Seasonal adjustment status
#'   \item occupation: Occupation categories
#'   \item indy: Industry categories
#' }
#'
#' @examples
#' \dontrun{
#' # List all available characteristics
#' all_chars <- explore_cps_characteristics()
#'
#' # Explore specific characteristics
#' age_codes <- explore_cps_characteristics("ages")
#' sex_codes <- explore_cps_characteristics("sexs")
#' education_codes <- explore_cps_characteristics("education")
#'
#' # Use the codes in get_cps_subset
#' data <- get_cps_subset(
#'   characteristics = list(
#'     ages_code = "00",      # 16 years and over
#'     sexs_code = "1"        # Men
#'   )
#' )
#' }
#'
#' @export
#' @importFrom data.table fread
#' @importFrom dplyr select filter arrange distinct
#' @importFrom tidyselect any_of
explore_cps_characteristics <- function(
  characteristic = NULL,
  cache_dir = NULL,
  verbose = TRUE
) {
  # Set up cache directory
  if (is.null(cache_dir)) {
    cache_dir <- tempdir()
  } else if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }

  base_url <- "https://download.bls.gov/pub/time.series/ln/"
  series_url <- paste0(base_url, "ln.series")

  # Download series file to identify characteristics
  if (verbose) {
    message("Loading CPS series metadata...")
  }
  series_result <- fread_bls(series_url, verbose = FALSE)
  series_dt <- series_result$data

  # Identify all code columns
  code_cols <- names(series_dt)[grep("_code$", names(series_dt))]

  # If no characteristic specified, return list of all characteristics
  if (is.null(characteristic)) {
    # Create descriptions for common characteristics
    char_descriptions <- data.frame(
      characteristic = sub("_code$", "", code_cols),
      code_column = code_cols,
      description = c(
        "Labor force status (employed, unemployed, not in labor force)",
        "Data periodicity (monthly, quarterly, annual)",
        "Absence from work categories",
        "Activity status categories",
        "Age groups",
        "Certification status",
        "Class of worker",
        "Duration of unemployment",
        "Educational attainment levels",
        "Job entry categories",
        "Work experience",
        "Household header status",
        "Hours of work categories",
        "Industry classifications",
        "Job description categories",
        "Job search activities",
        "Marital status",
        "Major job search categories",
        "Occupation classifications",
        "Origin/ethnicity",
        "Percent of poverty categories",
        "Race categories",
        "Reason for job search",
        "Reason not in labor force",
        "Reason for working part-time",
        "Job seeking status",
        "Sex/gender",
        "Type of data (levels, rates, etc.)",
        "Veteran status",
        "Work status categories",
        "Nativity/birthplace",
        "Children presence",
        "Disability status",
        "Time lost from work"
      )[1:length(code_cols)],
      stringsAsFactors = FALSE
    )

    if (verbose) {
      message("\nAvailable characteristics in CPS (LN) dataset:")
      message("Use explore_cps_characteristics('name') to see valid codes\n")
    }

    return(char_descriptions)
  }

  # Normalize characteristic name (remove _code if present)
  char_clean <- sub("_code$", "", characteristic)
  code_col <- paste0(char_clean, "_code")

  # Check if characteristic exists
  if (!code_col %in% code_cols) {
    stop(sprintf(
      "Characteristic '%s' not found. Available characteristics:\n%s",
      characteristic,
      paste("  -", sub("_code$", "", code_cols), collapse = "\n")
    ))
  }

  # Try to load the mapping file for this characteristic
  map_url <- paste0(base_url, "ln.", char_clean)

  tryCatch(
    {
      if (verbose) {
        message(sprintf("Loading mapping file for '%s'...", char_clean))
      }
      map_result <- fread_bls(map_url, verbose = FALSE)
      map_dt <- map_result$data

      # Clean up columns
      map_dt <- map_dt |>
        dplyr::select(
          -tidyselect::any_of(c("display_level", "sort_sequence", "selectable"))
        )

      # The first column is typically the code, second is the text description
      # Get unique combinations
      result <- map_dt |>
        dplyr::distinct() |>
        dplyr::arrange(dplyr::across(1))

      if (verbose) {
        message(sprintf(
          "\nFound %d unique codes for '%s':",
          nrow(result),
          char_clean
        ))
      }

      return(as.data.frame(result))
    },
    error = function(e) {
      # If mapping file doesn't exist, extract unique codes from series file
      if (verbose) {
        message(sprintf(
          "No mapping file found for '%s'. Showing unique codes from series file...",
          char_clean
        ))
      }

      unique_codes <- series_dt |>
        dplyr::select(tidyselect::any_of(code_col)) |>
        dplyr::filter(!is.na(.data[[code_col]]) & .data[[code_col]] != "") |>
        dplyr::distinct() |>
        dplyr::arrange(.data[[code_col]])

      colnames(unique_codes) <- char_clean

      if (verbose) {
        message(sprintf(
          "\nFound %d unique codes for '%s':",
          nrow(unique_codes),
          char_clean
        ))
        message("Note: Text descriptions not available without mapping file.")
      }

      return(as.data.frame(unique_codes))
    }
  )
}
