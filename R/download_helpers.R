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
#' 
#' @return Named list of bls_data objects
#' 
#' @export
download_bls_files <- function(urls, suppress_warnings = TRUE) {
  
  results <- list()
  
  for (name in names(urls)) {
    if (!suppress_warnings) message("Downloading", name, "...\n")
    
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