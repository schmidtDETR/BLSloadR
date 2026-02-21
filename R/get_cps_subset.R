#' Efficiently Extract and Cache Subsets of CPS (LN) Data
#'
#' This function extracts specific series from the BLS Current Population Survey (LN) dataset
#' using intelligent caching to avoid redundant downloads and processing. It supports filtering
#' by exact series IDs or by demographic/economic characteristics.
#'
#' @param series_ids Optional character vector of specific series IDs to extract.
#'   If NULL, must provide characteristics. Can be combined with characteristics
#'   to expand the query. Use \code{\link{explore_cps_series}} to discover
#'   relevant series IDs.
#' @param characteristics Optional named list of characteristics to filter by
#'   (e.g., `list(ages_code = "00", sexs_code = "1")`). Available characteristics
#'   depend on the LN series structure and may include ages_code, sexs_code,
#'   periodicity_code, and others found in the ln.series file. Use
#'   \code{\link{explore_cps_characteristics}} to discover valid codes.
#' @param simplify_table Logical. If TRUE (default), removes internal code columns,
#'   converts values to numeric, and creates a date column from year and period.
#'   Also removes display_level, sort_sequence, selectable, and footnote_codes columns.
#' @param cache Logical. If TRUE (default), uses persistent local caching for both
#'   the master data file and the extracted subsets. Cache validity is checked against
#'   BLS server modification times to ensure data freshness.
#' @param cache_dir Optional character string specifying the directory for cached files.
#'   If NULL, uses R's temporary directory via `tempdir()`. For persistent caching across
#'   sessions, provide a permanent directory path.
#' @param suppress_warnings Logical. If TRUE, suppress individual download warnings.
#'   Default is FALSE.
#'
#' @return A `bls_data_collection` object containing:
#'   \itemize{
#'     \item data: The requested subset with series metadata and mapping files joined
#'     \item download_diagnostics: Information about files accessed during extraction
#'     \item warnings: Any warnings generated during processing
#'     \item summary: Summary statistics about the data collection
#'   }
#'
#' @details
#' The function uses a two-tier caching strategy:
#' \enumerate{
#'   \item Master file caching: The full ln.data.1.AllData file is downloaded once
#'         per session (or permanently if cache_dir is specified) and only
#'         re-downloaded when the BLS server indicates updates.
#'   \item Subset caching: Each unique combination of series_ids is cached separately
#'         using an MD5 hash. Subsets are invalidated if the master file is updated.
#' }
#'
#' The function automatically joins relevant mapping files (e.g., ln.ages, ln.sexs)
#' based on the characteristics present in the requested series.
#'
#' @seealso \code{\link{explore_cps_characteristics}} to discover available
#'   characteristics and their valid codes,
#'   \code{\link{explore_cps_series}} to search for specific series by keywords
#'   or characteristics.
#'
#' @examples
#' \dontrun{
#' # Discover available characteristics and their codes
#' explore_cps_characteristics()           # List all characteristics
#' explore_cps_characteristics("sexs")     # See valid sex codes
#' explore_cps_characteristics("ages")     # See valid age codes
#'
#' # Search for specific series
#' explore_cps_series(search = "unemployment rate")
#' explore_cps_series(
#'   search = "unemployment",
#'   characteristics = list(sexs_code = "2"),
#'   seasonal = "S"
#' )
#'
#' # Extract specific series by ID
#' unemployment <- get_cps_subset(
#'   series_ids = c("LNS13000000", "LNS12000000"),
#'   simplify_table = TRUE,
#'   cache = TRUE
#' )
#'
#' # Filter by characteristics
#' male_series <- get_cps_subset(
#'   characteristics = list(ages_code = "00", sexs_code = "1"),
#'   simplify_table = TRUE,
#'   cache = TRUE
#' )
#'
#' # Combine series IDs with characteristics
#' combined <- get_cps_subset(
#'   series_ids = "LNS13000000",
#'   characteristics = list(sexs_code = "1"),
#'   simplify_table = TRUE,
#'   cache = TRUE
#' )
#'
#' # Use persistent cache directory
#' unemployment <- get_cps_subset(
#'   series_ids = c("LNS13000000"),
#'   cache_dir = "C:/BLS_cache",
#'   cache = TRUE
#' )
#' }
#'
#' @export
#' @importFrom data.table fread
#' @importFrom dplyr filter left_join select mutate case_when
#' @importFrom tidyselect any_of contains
#' @importFrom rlang .data
#' @importFrom digest digest
#' @importFrom httr HEAD add_headers status_code headers
#' @importFrom lubridate ym yq
get_cps_subset <- function(
  series_ids = NULL,
  characteristics = NULL,
  simplify_table = TRUE,
  cache = TRUE,
  cache_dir = NULL,
  suppress_warnings = FALSE
) {
  if (is.null(series_ids) && is.null(characteristics)) {
    stop(
      "You must provide either a vector of series_ids or a named list of characteristics."
    )
  }

  # Set up cache directory
  if (is.null(cache_dir)) {
    cache_dir <- tempdir()
  } else if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }

  # 1. Base URL setup
  base_url <- "https://download.bls.gov/pub/time.series/ln/"
  data_url <- paste0(base_url, "ln.data.1.AllData")
  series_url <- paste0(base_url, "ln.series")

  # 2. Download series file using fread_bls
  if (suppress_warnings) {
    series_result <- suppressWarnings(fread_bls(series_url, verbose = FALSE))
  } else {
    series_result <- fread_bls(series_url, verbose = TRUE)
  }
  series_dt <- series_result$data

  # 3. Resolve characteristics into exact series IDs
  if (!is.null(characteristics)) {
    filtered_series <- series_dt
    for (char_name in names(characteristics)) {
      if (!char_name %in% names(filtered_series)) {
        stop(sprintf(
          "Characteristic '%s' not found in ln.series file.",
          char_name
        ))
      }
      filtered_series <- filtered_series |>
        dplyr::filter(.data[[char_name]] %in% characteristics[[char_name]])
    }

    char_ids <- filtered_series$series_id
    series_ids <- unique(c(series_ids, char_ids))

    if (length(series_ids) == 0) {
      stop(
        "The provided characteristics did not match any series in the LN database."
      )
    }
  }

  # 4. Create a unique hash for this specific data cut
  query_hash <- digest::digest(sort(series_ids), algo = "md5")
  subset_cache_path <- file.path(
    cache_dir,
    paste0("ln_subset_", query_hash, ".rds")
  )

  # 5. Get remote modification time for master file
  bls_headers <- httr::add_headers(
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  )

  remote_mtime <- NULL
  tryCatch(
    {
      remote_head <- httr::HEAD(data_url, bls_headers)
      if (httr::status_code(remote_head) == 200) {
        remote_mtime_raw <- httr::headers(remote_head)[["last-modified"]]
        remote_mtime <- as.POSIXct(
          remote_mtime_raw,
          format = "%a, %d %b %Y %H:%M:%S GMT",
          tz = "GMT"
        )
      }
    },
    error = function(e) {
      if (!suppress_warnings) {
        warning(
          "Could not reach BLS server to verify update status: ",
          e$message
        )
      }
    }
  )

  if (is.null(remote_mtime)) {
    remote_mtime <- Sys.time()
  }

  # 6. Evaluate Subset Cache Validity FIRST to avoid downloading large master file
  needs_extraction <- TRUE
  if (cache && file.exists(subset_cache_path)) {
    subset_info <- file.info(subset_cache_path)
    if (subset_info$mtime >= (remote_mtime - 1)) {
      needs_extraction <- FALSE
      if (!suppress_warnings) {
        message("Using cached subset (avoiding master file download)...")
      }
    }
  }

  # 7. Extract data (either from master file or from subset cache)
  processing_steps <- character(0)

  if (needs_extraction) {
    if (!suppress_warnings) {
      message("Extracting data subset from master file...")
    }

    # Download master file using fread_bls with fallback enabled
    if (suppress_warnings) {
      master_result <- suppressWarnings(
        fread_bls(
          data_url,
          use_fallback = TRUE,
          verbose = FALSE
        )
      )
    } else {
      master_result <- fread_bls(
        data_url,
        use_fallback = TRUE,
        verbose = TRUE
      )
    }
    master_dt <- master_result$data

    # Filter to requested series
    raw_subset <- master_dt |> dplyr::filter(series_id %in% series_ids)

    # Explicit memory cleanup: remove large master dataset and trigger garbage collection
    rm(master_dt, master_result)
    gc(verbose = FALSE)

    # Save the subset to cache and sync its modified time to the server's update time
    if (cache) {
      saveRDS(raw_subset, subset_cache_path)
      Sys.setFileTime(subset_cache_path, remote_mtime)
    }
    data_dt <- raw_subset
    processing_steps <- c(processing_steps, "fread_bls_extraction_and_filter")
  } else {
    if (!suppress_warnings) {
      message("Loading data subset from local cache...")
    }
    data_dt <- readRDS(subset_cache_path)
    processing_steps <- c(processing_steps, "loaded_subset_cache")
  }

  # 8. Join Mapping and Series Information
  columns_to_remove <- c(
    "display_level",
    "sort_sequence",
    "selectable",
    "footnote_codes"
  )
  data_dt <- data_dt |> dplyr::select(-tidyselect::any_of(columns_to_remove))
  series_dt <- series_dt |>
    dplyr::select(-tidyselect::any_of(columns_to_remove))

  # Limit series metadata to only the requested IDs to keep the final object lightweight
  series_dt <- series_dt |> dplyr::filter(series_id %in% series_ids)

  full_dt <- dplyr::left_join(data_dt, series_dt, by = "series_id")
  processing_steps <- c(processing_steps, "joined_series_metadata")

  # 9. Download and join mapping files dynamically based on series characteristics
  mapping_cols <- names(series_dt)[grep("_code$", names(series_dt))]

  for (m_col in mapping_cols) {
    map_prefix <- sub("_code$", "", m_col)
    map_filename <- paste0("ln.", map_prefix)
    map_url <- paste0(base_url, map_filename)

    # Attempt to fetch mapping file if it exists on the BLS server
    tryCatch(
      {
        if (suppress_warnings) {
          map_result <- suppressWarnings(fread_bls(map_url, verbose = FALSE))
        } else {
          map_result <- fread_bls(map_url, verbose = FALSE)
        }
        map_dt <- map_result$data |>
          dplyr::select(-tidyselect::any_of(columns_to_remove))

        join_col <- names(map_dt)[1]
        if (join_col %in% names(full_dt)) {
          full_dt <- dplyr::left_join(full_dt, map_dt, by = join_col)
          processing_steps <- c(
            processing_steps,
            paste0("joined_mapping_", map_prefix)
          )
        }
      },
      error = function(e) {
        # Fails silently if a specific mapping file doesn't exist on the server
        NULL
      }
    )
  }

  # 10. Format output
  if (simplify_table) {
    if (suppress_warnings) {
      full_dt <- suppressWarnings(
        full_dt |>
          dplyr::mutate(
            value = as.numeric(value),
            period_type_code = substr(period, 1, 1),
            date = dplyr::case_when(
              period %in% c("M13", "Q05", "A01") ~ lubridate::ym(paste0(
                year,
                "-01"
              )),
              period_type_code == "Q" ~ lubridate::yq(paste(
                year,
                "Q",
                substr(period, 3, 3)
              )),
              TRUE ~ lubridate::ym(paste0(year, period))
            )
          ) |>
          dplyr::select(-tidyselect::contains("_code"))
      )
    } else {
      full_dt <- full_dt |>
        dplyr::mutate(
          value = as.numeric(value),
          period_type_code = substr(period, 1, 1),
          date = dplyr::case_when(
            period %in% c("M13", "Q05", "A01") ~ lubridate::ym(paste0(
              year,
              "-01"
            )),
            period_type_code == "Q" ~ lubridate::yq(paste(
              year,
              "Q",
              substr(period, 3, 3)
            )),
            TRUE ~ lubridate::ym(paste0(year, period))
          )
        ) |>
        dplyr::select(-tidyselect::contains("_code"))
    }

    processing_steps <- c(processing_steps, "simplified_table")
  }

  # 11. Package into the standard BLSloadR object
  downloads_list <- list()
  downloads_list[["ln.series"]] <- series_result

  result <- create_bls_object(
    data = full_dt,
    downloads = downloads_list,
    data_type = "BLS-LN-SUBSET",
    processing_steps = processing_steps
  )

  return(result)
}
