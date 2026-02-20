#' Create a BLS data object with diagnostics
#'
#' This is a helper function to create a list with the additional class 'bls_data_collection' containing data downloaded form the U.S. Bureau of Labor Statistics as well as diagnostic details about the download. It is used invisibly in the package to bundle information about file downloads.
#'
#' @param data The processed data (data.table/data.frame)
#' @param downloads List of download results from fread_bls()
#' @param data_type Character string describing the type of BLS data (e.g., "CES", "JOLTS", "CPS")
#' @param processing_steps Character vector describing processing steps applied
#' @return A bls_data_collection object
#' @export
create_bls_object <- function(data, downloads, data_type = "BLS", processing_steps = character(0)) {

  # Extract diagnostics from downloads
  download_diagnostics <- lapply(downloads, function(x) {
    if (inherits(x, "bls_data")) {
      return(get_bls_diagnostics(x))
    } else {
      return(NULL)
    }
  })

  # Collect all warnings
  all_warnings <- character(0)
  for (name in names(download_diagnostics)) {
    diag <- download_diagnostics[[name]]
    if (!is.null(diag) && length(diag$warnings) > 0) {
      prefixed_warnings <- paste(name, ":", diag$warnings)
      all_warnings <- c(all_warnings, prefixed_warnings)
    }
  }

  # Create summary
  summary_info <- list(
    data_type = data_type,
    files_downloaded = length(downloads),
    files_with_issues = sum(sapply(download_diagnostics, function(x) !is.null(x) && length(x$warnings) > 0)),
    total_warnings = length(all_warnings),
    processing_steps = processing_steps,
    final_dimensions = dim(data),
    download_timestamp = Sys.time()
  )

  # Create result object
  result <- list(
    data = data,
    download_diagnostics = download_diagnostics,
    warnings = all_warnings,
    summary = summary_info
  )

  class(result) <- c("bls_data_collection", "list")

  return(result)
}

#' Extract data from BLS data object
#'
#' This is a helper function to extract the data element of a 'bls_data_collection' object.
#'
#' @param bls_obj A bls_data_collection object or raw data
#' @return The data component of a 'bls_data_collection' object as a data frame.
#' @export

get_bls_data <- function(bls_obj) {
  if (inherits(bls_obj, "bls_data_collection")) {
    return(bls_obj$data)
  } else if (inherits(bls_obj, "bls_data")) {
    return(bls_obj$data)
  } else {
    # For backward compatibility
    return(bls_obj)
  }
}

#' Get download diagnostics from BLS data object
#'
#' This is a helper function to extract the download diagnostics element of a 'bls_data_collection' object.
#'
#' @param bls_obj A bls_data_collection object
#' @return List of download diagnostics from a bls_data_collection object.
#' @export
get_bls_diagnostics <- function(bls_obj) {
  if (inherits(bls_obj, "bls_data_collection")) {
    return(bls_obj$download_diagnostics)
  } else if (inherits(bls_obj, "bls_data")) {
    return(bls_obj$diagnostics)
  } else {
    return(NULL)
  }
}
#' Check and Download BLS File with Local Caching
#'
#' This function manages the downloading of files from the BLS server with a 
#' local caching layer. It uses HTTP HEAD requests to compare the server's 
#' `Content-Length` and `Last-Modified` headers with local file attributes. 
#' The file is only downloaded if it does not exist locally, or if the remote 
#' version is newer or a different size.
#'
#' @param url A character string representing the URL of the BLS file (e.g., a `.txt` or `.gz` file from download.bls.gov).
#' @param cache_dir A character string specifying the local directory to store cached files. May also be set with the  enviroment variable `BLS_CACHE_DIR`
#'   Defaults to a persistent user data directory managed by \code{tools::R_user_dir}.
#' @param verbose Logical. Defaults to FALSE.  If TRUE, returns status messages for download.
#'
#' @return A character string containing the local path to the downloaded (or cached) file.
#'
#' @details 
#' The function uses a specific set of browser-like headers to ensure compatibility 
#' with BLS server security policies. Upon a successful download, the local file's 
#' modification time is synchronized with the server's `Last-Modified` header using 
#' \code{Sys.setFileTime} to ensure accurate future comparisons.
#'
#' @importFrom httr HEAD GET add_headers headers status_code write_disk progress
#' @importFrom tools R_user_dir
#' @export
#'
#' @examples
#' \dontrun{
#' url <- "https://download.bls.gov/pub/time.series/ce/ce.data.0.AllCESSeries"
#' local_path <- smart_bls_download(url)
#' data <- data.table::fread(local_path)
#' }
smart_bls_download <- function(url, cache_dir = NULL, verbose = FALSE) {
  
  # 1. Define specific headers required by BLS servers
  bls_headers <- httr::add_headers(.headers = c(
    "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    "Accept-Encoding" = "gzip, deflate, br",
    "Accept-Language" = "en-US,en;q=0.9",
    "Connection" = "keep-alive",
    "Host" = "download.bls.gov",
    "Referer" = "https://download.bls.gov/pub/time.series/",
    "Sec-Ch-Ua" = 'Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
    "Sec-Ch-Ua-Mobile" = "?0",
    "Sec-Ch-Ua-Platform" = '"Windows"',
    "Sec-Fetch-Dest" = "document",
    "Sec-Fetch-Mode" = "navigate",
    "Sec-Fetch-Site" = "same-origin",
    "Sec-Fetch-User" = "?1",
    "Upgrade-Insecure-Requests" = "1",
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  ))
  
  # 2. Establish cache directory
  if (is.null(cache_dir)) {
    cache_dir <- bls_get_cache_dir()
  }
  
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }
  
  local_path <- file.path(cache_dir, basename(url))
  
  # 3. Fetch Remote Metadata
  response_head <- httr::HEAD(url, bls_headers)
  
  if (httr::status_code(response_head) != 200) {
    if (file.exists(local_path)) {
      warning("Could not reach BLS server; using existing cached file.")
      return(local_path)
    } else {
      stop("Could not connect to BLS server and no local cache exists. Status: ", 
           httr::status_code(response_head))
    }
  }
  
  res_headers <- httr::headers(response_head)
  
  # Correctly parse the remote modification time
  # BLS uses RFC 1123 format: "Thu, 18 Dec 2025 13:30:00 GMT"
  remote_mtime_raw <- res_headers[["last-modified"]]
  remote_mtime <- as.POSIXct(remote_mtime_raw, 
                             format = "%a, %d %b %Y %H:%M:%S GMT", 
                             tz = "GMT")
  
  remote_size <- as.numeric(res_headers[["content-length"]])
  
  # 4. Caching Logic
  needs_download <- TRUE
  
  if (file.exists(local_path)) {
    local_info <- file.info(local_path)
    
    # Check if size matches and if local file is NOT older than remote
    size_matches <- is.na(remote_size) || (local_info$size == remote_size)
    
    # Use a small tolerance (1s) to avoid floating point issues with POSIXct
    is_current <- (local_info$mtime >= (remote_mtime - 1))
    
    if (size_matches && is_current) {
      if(verbose){
      message(paste0("For ", url,": Cached local file is up to date."))
      }
      needs_download <- FALSE
    }
  }
  
  # 5. Perform download if necessary
  if (needs_download) {
    if(verbose){
    message(paste0("For ", url, ": Cached file missing or outdated: Downloading new file."))
      
    res <- httr::GET(
      url, 
      bls_headers,
      httr::write_disk(local_path, overwrite = TRUE),
      httr::progress()
    ) } else {
      res <- httr::GET(
        url, 
        bls_headers,
        httr::write_disk(local_path, overwrite = TRUE)
      )
    }
    
    # Sync file time to the server's Last-Modified time exactly
    Sys.setFileTime(local_path, remote_mtime)
  }
  
  return(local_path)
}

#' Get summary information from BLS data object
#'
#' This is a helper function to extract the summary element of a 'bls_data_collection' object. This containes the number of files downloaded, the number of files with potential warnings, and the total number of warnings.
#'
#' @param bls_obj A bls_data_collection object
#' @return List of summary information
#' @export
get_bls_summary <- function(bls_obj) {
  if (inherits(bls_obj, "bls_data_collection")) {
    return(bls_obj$summary)
  } else {
    return(NULL)
  }
}

#' Print warnings for BLS data object
#'
#' @param bls_obj A bls_data_collection object
#' @param detailed Logical. If TRUE, shows detailed diagnostics for each file
#' @param silent Logical. If TRUE, suppress console output
#'
#' @return Character vector of warnings (invisibly)
#'
#' @export
print_bls_warnings <- function(bls_obj, detailed = FALSE, silent = FALSE) {

  # Handle different object types
  if (inherits(bls_obj, "bls_data_collection")) {
    warnings <- bls_obj$warnings
    summary <- bls_obj$summary
    diagnostics <- bls_obj$download_diagnostics
  } else if (inherits(bls_obj, "bls_data")) {
    diag <- bls_obj$diagnostics
    warnings <- if (!is.null(diag)) diag$warnings else character(0)
    summary <- list(data_type = "Single File", files_downloaded = 1,
                    files_with_issues = length(warnings) > 0,
                    total_warnings = length(warnings))
    diagnostics <- list("Single File" = diag)
  } else {
    if (!silent) message("No diagnostic information available\n")
    return(invisible(character(0)))
  }

  if (length(warnings) == 0) {
    if (!silent) message("No warnings for", summary$data_type, "data download\n")
    return(invisible(character(0)))
  }

  if (!silent) {
    message(summary$data_type, "Data Download Warnings:\n")
    message(paste(rep("=", nchar(summary$data_type) + 25), collapse = ""), "\n")
    message("Total files downloaded:", summary$files_downloaded, "\n")
    message("Files with issues:", summary$files_with_issues, "\n")
    message("Total warnings:", summary$total_warnings, "\n")
    if (!is.null(summary$final_dimensions)) {
      message("Final data dimensions:", paste(summary$final_dimensions, collapse = " x "), "\n")
    }
    message("\n")

    if (detailed && length(diagnostics) > 0) {
      message("Detailed Diagnostics:\n")
      for (file_name in names(diagnostics)) {
        diag <- diagnostics[[file_name]]
        if (!is.null(diag) && length(diag$warnings) > 0) {
          message("\n", file_name, ":\n")
          message("  URL:", diag$url, "\n")
          message("  Original dimensions:", paste(diag$original_dimensions, collapse = " x "), "\n")
          message("  Final dimensions:", paste(diag$final_dimensions, collapse = " x "), "\n")
          message("  Issues:\n")
          for (warning in diag$warnings) {
            message("    -", warning, "\n")
          }
        }
      }
    } else {
      message("Summary of warnings:\n")
      for (i in seq_along(warnings)) {
        message("  ", i, ". ", warnings[i], "\n")
      }
    }

    if (!detailed && length(diagnostics) > 1) {
      message("\nRun with return_diagnostics=TRUE and print_bls_warnings(data, detailed = TRUE) for file-by-file details\n")
    }
  }

  return(invisible(warnings))
}

#' Check if BLS data object has potential issues with import.
#'
#' @param bls_obj A BLS data object
#'
#' @return Logical indicating if there were any import issues detected.
#'
#' @export
has_bls_issues <- function(bls_obj) {
  if (inherits(bls_obj, "bls_data_collection")) {
    return(length(bls_obj$warnings) > 0)
  } else if (inherits(bls_obj, "bls_data")) {
    diag <- bls_obj$diagnostics
    return(!is.null(diag) && length(diag$warnings) > 0)
  } else {
    return(FALSE)
  }
}


#' Helper function for downloading and tracking BLS files
#'
#' This function is used to pass multiple URLs at the Bureau of Labor Statistics into 'fread_bls()'
#'
#' @param urls Named character vector of URLs to download
#' @param suppress_warnings Logical. If TRUE, suppress individual download warnings
#' @param cache Logical. If TRUE, download and cache local copy of files.
#'
#' @return Named list of bls_data objects
#'
#' @export
download_bls_files <- function(urls, suppress_warnings = TRUE, cache = FALSE) {

  results <- list()

  for (name in names(urls)) {
    if (!suppress_warnings) message("Downloading", name, "...\n")

    result <- fread_bls(urls[[name]], cache = cache)

    # Check for issues
    if (has_bls_issues(result)) {
      if (!suppress_warnings) {
        print_bls_warnings(result, silent = FALSE)
      }
    }

    results[[name]] <- result
  }

  return(results)
}

#' Get the current BLSloadR Cache Directory
#' 
#' Displays the path currently being used for caching. This will check the
#' `BLS_CACHE_DIR` environment variable, falling back to the default
#' system cache directory if the variable is not set.
#'
#' @return A character string of the cache path.
#' @export
bls_get_cache_dir <- function() {
  env_path <- Sys.getenv("BLS_CACHE_DIR")
  
  if (env_path != "") {
    return(normalizePath(env_path, mustWork = FALSE))
  }
  
  # Fallback to the same logic used in smart_bls_download
  return(normalizePath(tools::R_user_dir("BLSloadR", which = "cache"), mustWork = FALSE))
}
#' Check if Global Caching is Enabled via Environment Variable
#' @keywords internal
#' @return Logical value indicating if the environment variable USE_BLS_CACHE is one of TRUE, YES, or 1
check_bls_cache_env <- function() {
  val <- Sys.getenv("USE_BLS_CACHE", unset = "FALSE")
  # Returns TRUE if user set it to "TRUE", "true", "1", or "yes"
  return(toupper(val) %in% c("TRUE", "1", "YES"))
}
