#' Explore Available CPS (LN) Characteristics and Codes
#'
#' This helper function allows users to discover available characteristics
#' and their valid codes in the BLS Current Population Survey (LN) dataset.
#'
#' @param characteristic Optional character string specifying which characteristic
#'   to explore (e.g., "ages", "sexs"). If NULL, returns a list of all available 
#'   characteristics or matches based on the `pattern`.
#' @param pattern Optional character string. If provided, filters the available
#'   characteristics by matching this pattern against names and descriptions. Functions best when `static=TRUE`
#' @param cache_dir Optional character string for cached files.
#' @param cache Logical. Optional parameter determining whether to use the BLSloadR file cache folder.  By default, checks status os USE_BLS_CACHE environment variable, and otherwise is set to FALSE. 
#' @param verbose Logical. If TRUE, print informative messages. Default is TRUE.
#' @param static Logical. If TRUE, use built-in `national_cps_availability` to populate the function output to ensure that only filter values actually present in the data are included..
#'
#' @return A data.frame of characteristics or specific code mappings.
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
#' # Get Static CPS Code lookups
#' # Search for any characteristic related to "work"
#' work_chars <- explore_cps_characteristics(pattern = "work", static = TRUE)
#' 
#' vets_codes <- explore_cps_characteristics("vets", static = TRUE)
#' job_search_codes <- explore_cps_characteristics("look", static = TRUE)
#' # Get codes for the 'wkst' (Work Status) characteristic
#' wkst_codes <- explore_cps_characteristics("wkst", static = TRUE)
#' }
#' @export
#' 
explore_cps_characteristics <- function(
    characteristic = NULL,
    pattern = NULL,
    cache_dir = NULL,
    cache = check_bls_cache_env(),
    verbose = TRUE,
    static = FALSE
) {
  # 1. Setup Cache
  
  if(!cache){
    
    if(verbose){
    message("Local file cache disabled. Using temporary folder only.")  
    }
    cache_dir <- tempdir()
    
  } else if (is.null(cache_dir)) {
    cache_dir <- bls_get_cache_dir()
    
    if(verbose){
      message("Using cache directory: ", cache_dir)
    }
    
  }
  
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }
  
  # --- STATIC MODE ---
  if (static == TRUE) {
    if (!exists("national_cps_availability")) {
      stop("Static data object 'national_cps_availability' not found.")
    }
    
    # If characteristic is provided, ignore pattern and show specific codes
    if (!is.null(characteristic)) {
      char_clean <- sub("_code$", "", characteristic)
      
      if (char_clean %in% national_cps_availability$master_filter) {
        pair_data <- national_cps_availability |> 
          dplyr::filter(master_filter == char_clean) |> 
          dplyr::pull(available_codes) |> 
          _[[1]]
        return(as.data.frame(pair_data))
      } else {
        if (verbose) message(sprintf("Characteristic '%s' not found. Searching for matches...", char_clean))
        pattern <- char_clean # Fallback to search if the exact match fails
      }
    }
    
    # Summary/Search View
    res <- national_cps_availability |> 
      dplyr::select(master_filter, master_description)
    
    if (!is.null(pattern)) {
      res <- res |> 
        dplyr::filter(
          stringr::str_detect(master_filter, stringr::fixed(pattern, ignore_case = TRUE)) | 
            stringr::str_detect(master_description, stringr::fixed(pattern, ignore_case = TRUE))
        )
    }
    
    if (verbose) {
      message(sprintf("Found %d matching characteristics.", nrow(res)))
    }
    return(as.data.frame(res))
    
    # --- LIVE MODE ---
  } else {
    base_url <- "https://download.bls.gov/pub/time.series/ln/"
    series_url <- paste0(base_url, "ln.series")
    
    if (verbose) message("Loading live CPS series metadata from BLS...")
    series_result <- fread_bls(series_url, verbose = FALSE, cache = cache)
    series_dt <- series_result$data
    code_cols <- names(series_dt)[grep("_code$", names(series_dt))]
    
    if (is.null(characteristic)) {
      live_summary <- data.frame(
        available_characteristics = sub("_code$", "", code_cols),
        stringsAsFactors = FALSE
      )
      
      if (!is.null(pattern)) {
        live_summary <- live_summary |> 
          dplyr::filter(stringr::str_detect(available_characteristics, stringr::fixed(pattern, ignore_case = TRUE)))
      }
      return(live_summary)
    }
    
    # (Mapping download logic remains same as previous version...)
    char_clean <- sub("_code$", "", characteristic)
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
}
