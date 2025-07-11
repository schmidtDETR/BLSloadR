#' Create a BLS data object with diagnostics
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
#' @param bls_obj A bls_data_collection object or raw data
#' @return The data component
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
#' @param bls_obj A bls_data_collection object
#' @return List of download diagnostics
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

#' Get summary information from BLS data object
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
#' @return Character vector of warnings (invisibly)
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
    if (!silent) cat("No diagnostic information available\n")
    return(invisible(character(0)))
  }
  
  if (length(warnings) == 0) {
    if (!silent) cat("No warnings for", summary$data_type, "data download\n")
    return(invisible(character(0)))
  }
  
  if (!silent) {
    cat(summary$data_type, "Data Download Warnings:\n")
    cat(paste(rep("=", nchar(summary$data_type) + 25), collapse = ""), "\n")
    cat("Total files downloaded:", summary$files_downloaded, "\n")
    cat("Files with issues:", summary$files_with_issues, "\n")
    cat("Total warnings:", summary$total_warnings, "\n")
    if (!is.null(summary$final_dimensions)) {
      cat("Final data dimensions:", paste(summary$final_dimensions, collapse = " x "), "\n")
    }
    cat("\n")
    
    if (detailed && length(diagnostics) > 0) {
      cat("Detailed Diagnostics:\n")
      for (file_name in names(diagnostics)) {
        diag <- diagnostics[[file_name]]
        if (!is.null(diag) && length(diag$warnings) > 0) {
          cat("\n", file_name, ":\n")
          cat("  URL:", diag$url, "\n")
          cat("  Original dimensions:", paste(diag$original_dimensions, collapse = " x "), "\n")
          cat("  Final dimensions:", paste(diag$final_dimensions, collapse = " x "), "\n")
          cat("  Issues:\n")
          for (warning in diag$warnings) {
            cat("    -", warning, "\n")
          }
        }
      }
    } else {
      cat("Summary of warnings:\n")
      for (i in seq_along(warnings)) {
        cat("  ", i, ". ", warnings[i], "\n")
      }
    }
    
    if (!detailed && length(diagnostics) > 1) {
      cat("\nRun with return_diagnostics=TRUE and print_bls_warnings(data, detailed = TRUE) for file-by-file details\n")
    }
  }
  
  return(invisible(warnings))
}

#' Check if BLS data object has issues
#'
#' @param bls_obj A BLS data object
#' @return Logical indicating if there were any issues
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

#' Print method for bls_data_collection objects
#'
#' @param x A bls_data_collection object
#' @param ... Additional arguments passed to print
#' @export
print.bls_data_collection <- function(x, ...) {
  cat(x$summary$data_type, "Data Collection\n")
  cat(paste(rep("=", nchar(x$summary$data_type) + 16), collapse = ""), "\n")
  cat("Dimensions:", paste(x$summary$final_dimensions, collapse = " x "), "\n")
  cat("Columns:", paste(names(x$data), collapse = ", "), "\n")
  cat("Files downloaded:", x$summary$files_downloaded, "\n")
  cat("Downloaded:", format(x$summary$download_timestamp, "%Y-%m-%d %H:%M:%S"), "\n")
  
  if (length(x$summary$processing_steps) > 0) {
    cat("Processing applied:", paste(x$summary$processing_steps, collapse = ", "), "\n")
  }
  
  if (has_bls_issues(x)) {
    cat("Issues detected:", x$summary$total_warnings, "warnings\n")
    cat("Use print_bls_warnings() for details\n")
  } else {
    cat("No download issues detected\n")
  }
  
  cat("\nData preview:\n")
  print(head(x$data), ...)
  
  invisible(x)
}

#' Helper function for downloading and tracking BLS files
#'
#' @param urls Named character vector of URLs to download
#' @param suppress_warnings Logical. If TRUE, suppress individual download warnings
#' @return Named list of bls_data objects
#' @export
download_bls_files <- function(urls, suppress_warnings = FALSE) {
  
  results <- list()
  
  for (name in names(urls)) {
    if (!suppress_warnings) cat("Downloading", name, "...\n")
    
    result <- fread_bls(urls[name])
    
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