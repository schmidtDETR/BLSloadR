#' Generic BLS Dataset Download
#' 
#' This function generalizes a method to download all BLS data for a given time series database.
#' These files are accessed from https://download.bls.gov/pub/time.series/ and several datasets
#' are available. A summary of an identified database can be generated using the `bls_overiew()`
#' function. When multiple potential data files exist (common in large data sets), the function
#' will prompt for an input of which file to use.
#' 
#' @param database_code This is the two digit character identifier for the desired database.
#'   Some Valid options are:
#'   \itemize{
#'     \item "ce" - National Current Employment Statistics Data
#'     \item "sm" - State and Metro area Current Employment Statistics Data
#'     \item "mp" - Major Sector Total Factor Productivity
#'     \item "ci" - Employment Cost Index
#'     \item "eb" - Employee Benefits Survey
#'   }
#'   
#' @param return_full This argument defaults to FALSE. If set to TRUE it will return
#'   a list of the elements of data retrieved from the BLS separating the data, series, and
#'   mapping values downloaded.
#'  
#' @param simplify_table This parameter defaults to TRUE. When TRUE it will remove all
#'  columns from the date with "_code" in the column name, as well as a series of internal
#'  identifiers which provide general information about the series but which are not needed for
#'  performing time series analysis. This parameter also converts the column "value" to numeric
#'  and generates a date column from the year and period columns in the data.
#'  
#' @param suppress_warnings Logical. If TRUE, suppress individual download warnings during processing.
#'  
#' @returns This function will return either a bls_data_collection object (if return_full is FALSE or not provided)
#'  or a named list of the returned data including the bls_data_collection object.
#'  
#' @export
#' @importFrom data.table data.table
#' @importFrom data.table fcase
#' @importFrom data.table rbindlist
#' @importFrom data.table :=
#' @importFrom rvest read_html html_elements html_attr
#' @importFrom httr GET add_headers stop_for_status content
#' @importFrom dplyr left_join
#' 
#' @examples
#' \dontrun{
#' # Download Employer Cost Index Data
#' cost_index <- load_bls_dataset("ci")
#'
#' # Download separated data, series, and mapping columns
#' benefits <- load_bls_dataset("eb", return_full = TRUE)
#'
#' # Download data without removing excess columns and value conversions
#' productivity <- load_bls_dataset("mp", simplify_table = FALSE)
#' 
#' # Check for download issues
#' if (has_bls_issues(cost_index)) {
#'   print_bls_warnings(cost_index, detailed = TRUE)
#' }
#' }

load_bls_dataset <- function(database_code, return_full = FALSE, simplify_table = TRUE, suppress_warnings = FALSE) {
  
  # Validate inputs
  if (!is.character(database_code) || length(database_code) != 1) {
    stop("database_code must be a single character string")
  }
  
  base_url <- sprintf("https://download.bls.gov/pub/time.series/%s/", database_code)
  
  # Function to scrape directory contents with proper headers
  get_directory_files <- function(url, prefix) {
    tryCatch({
      # Set up headers to avoid 403 errors
      headers <- c(
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
      )
      
      # Make request with headers
      response <- httr::GET(url, httr::add_headers(.headers = headers))
      httr::stop_for_status(response)
      
      # Parse HTML content
      page <- rvest::read_html(httr::content(response, as = "text"))
      links <- rvest::html_elements(page, "a")
      hrefs <- rvest::html_attr(links, "href")
      
      # Extract just the filename from the full path
      # hrefs will be like "/pub/time.series/ce/ce.data.0.AllCESSeries"
      filenames <- basename(hrefs)
      
      # Filter for files that start with the prefix and exclude unwanted extensions
      valid_files <- filenames[
        grepl(paste0("^", prefix, "\\."), filenames) & 
          !grepl("\\.(contacts|txt|footnote)$", filenames) &
          !is.na(filenames) &
          filenames != ""
      ]
      
      return(valid_files)
    }, error = function(e) {
      stop("Could not access BLS directory: ", url, "\nError: ", e$message)
    })
  }
  
  # Get all valid files from the directory
  file_names <- get_directory_files(base_url, database_code)
  
  if (length(file_names) == 0) {
    stop("No valid files found in the BLS database directory for code: ", database_code)
  }
  
  # Create file table and classify by pattern
  file_table <- data.table(file_name = file_names)
  file_table[, file_type := fcase(
    grepl("\\.data\\.", file_name), "data",
    grepl("\\.series($|\\.)", file_name), "series",
    grepl("\\.aspect($|\\.)", file_name), "aspect",
    default = "mapping"
  )]
  
  # Identify files
  mapping_files <- file_table[file_type == "mapping", file_name]
  data_files <- file_table[file_type == "data", file_name]
  series_file <- file_table[file_type == "series", file_name]
  aspect_files <- file_table[file_type == "aspect", file_name]
  
  if (length(series_file) == 0) {
    stop("Could not find a series file in the BLS database directory.")
  }
  
  # Handle multiple series files (prompt user to choose)
  if (length(series_file) > 1) {
    cat("Multiple series files found. Please select a file to load:\n")
    for (i in seq_along(series_file)) {
      cat(i, ": ", series_file[i], "\n")
    }
    
    # Get user input for series file selection
    selected_series_index <- as.integer(readline(prompt = "Enter the number of the series file you want to load: "))
    
    # Validate the input
    if (is.na(selected_series_index) || selected_series_index < 1 || selected_series_index > length(series_file)) {
      stop("Invalid selection. Please run the function again and enter a valid number.")
    }
    
    # Get the selected series file name
    series_file <- series_file[selected_series_index]
    cat("Loading series file:", series_file, "\n")
    
  } else if (length(series_file) == 1) {
    cat("Loading series file:", series_file, "\n")
  }
  
  # --- Logic for data file selection ---
  if (length(data_files) > 1) {
    # If there are multiple data files, prompt the user to choose
    cat("Multiple data files found. Please select a file to load:\n")
    for (i in seq_along(data_files)) {
      cat(i, ": ", data_files[i], "\n")
    }
    
    # Get user input for file selection
    selected_index <- as.integer(readline(prompt = "Enter the number of the file you want to load: "))
    
    # Validate the input
    if (is.na(selected_index) || selected_index < 1 || selected_index > length(data_files)) {
      stop("Invalid selection. Please run the function again and enter a valid number.")
    }
    
    # Get the selected file name
    selected_data_file <- data_files[selected_index]
    cat("Loading:", selected_data_file, "\n")
    
  } else if (length(data_files) == 1) {
    # If there is only one data file, use it directly
    selected_data_file <- data_files[1]
    cat("Loading:", selected_data_file, "\n")
  } else {
    stop("No data files found in the BLS database directory.")
  }
  
  # --- Logic for aspect file selection ---
  selected_aspect_file <- NULL
  if (length(aspect_files) > 1) {
    cat("Multiple aspect files found. Please select a file to load:\n")
    for (i in seq_along(aspect_files)) {
      cat(i, ": ", aspect_files[i], "\n")
    }
    
    # Get user input for aspect file selection
    selected_aspect_index <- as.integer(readline(prompt = "Enter the number of the aspect file you want to load: "))
    
    # Validate the input
    if (is.na(selected_aspect_index) || selected_aspect_index < 1 || selected_aspect_index > length(aspect_files)) {
      stop("Invalid selection. Please run the function again and enter a valid number.")
    }
    
    # Get the selected aspect file name
    selected_aspect_file <- aspect_files[selected_aspect_index]
    cat("Loading aspect file:", selected_aspect_file, "\n")
    
  } else if (length(aspect_files) == 1) {
    # If there is only one aspect file, use it directly
    selected_aspect_file <- aspect_files[1]
    cat("Loading aspect file:", selected_aspect_file, "\n")
  } else if (length(aspect_files) == 0) {
    if (!suppress_warnings) message("No aspect files found in the BLS database directory.")
  }
  
  # Create URLs for downloading
  urls <- c(
    setNames(paste0(base_url, selected_data_file), selected_data_file),
    setNames(paste0(base_url, series_file), series_file)
  )
  
  # Add aspect file URL if it exists
  if (!is.null(selected_aspect_file)) {
    aspect_url <- setNames(paste0(base_url, selected_aspect_file), selected_aspect_file)
    urls <- c(urls, aspect_url)
  }
  
  # Add mapping file URLs
  if (length(mapping_files) > 0) {
    mapping_urls <- setNames(paste0(base_url, mapping_files), mapping_files)
    urls <- c(urls, mapping_urls)
  }
  
  # Download all files using the new system
  downloads <- download_bls_files(urls, suppress_warnings = suppress_warnings)
  
  # Extract data from downloads
  data_dt <- get_bls_data(downloads[[selected_data_file]])
  series_dt <- get_bls_data(downloads[[series_file]])
  
  # Remove unwanted columns from all files
  columns_to_remove <- c("display_level", "sort_sequence", "selectable", "footnote_codes")
  data_dt <- data_dt |> dplyr::select(-tidyselect::any_of(columns_to_remove))
  series_dt <- series_dt |> dplyr::select(-tidyselect::any_of(columns_to_remove))
  
  # Track processing steps
  processing_steps <- character(0)
  
  # STEP 1: Join data to series first to get lookup codes
  if (!suppress_warnings) message("Joining data to series file...")
  full_dt <- left_join(data_dt, series_dt, by = "series_id")
  processing_steps <- c(processing_steps, "joined_data_to_series")
  
  # STEP 2: Join aspect file if it exists (after series, before mapping files)
  if (!is.null(selected_aspect_file) && selected_aspect_file %in% names(downloads)) {
    tryCatch({
      if (!suppress_warnings) message("Joining aspect file...")
      aspect_dt <- get_bls_data(downloads[[selected_aspect_file]])
      
      # Remove unwanted columns from aspect file
      aspect_dt <- aspect_dt |> dplyr::select(-tidyselect::any_of(columns_to_remove))
      
      # Rename the value column in aspect file to aspect_value to avoid conflicts
      if ("value" %in% names(aspect_dt)) {
        aspect_dt <- aspect_dt |>
          dplyr::rename(aspect_value = value)
      }
      
      # Join aspect file on series_id, year, and period
      join_cols <- c("series_id", "year", "period")
      available_join_cols <- intersect(join_cols, names(aspect_dt))
      
      if (length(available_join_cols) > 0) {
        full_dt <- left_join(full_dt, aspect_dt, by = available_join_cols)
        processing_steps <- c(processing_steps, "joined_aspect_file")
        if (!suppress_warnings) message("Aspect file joined successfully on: ", paste(available_join_cols, collapse = ", "))
      } else {
        if (!suppress_warnings) message("Warning: Could not join aspect file - no matching columns found")
      }
      
    }, error = function(e) {
      if (!suppress_warnings) message("Error processing aspect file ", selected_aspect_file, ": ", e$message)
    })
  }
  
  # STEP 3: Now join mapping files to the combined table
  for (map_file in mapping_files) {
    if (map_file %in% names(downloads)) {
      tryCatch({
        map_dt <- get_bls_data(downloads[[map_file]])
        
        # Remove unwanted columns from mapping file
        map_dt <- map_dt |> dplyr::select(-tidyselect::any_of(columns_to_remove))
        
        if (ncol(map_dt) == 2) {
          
          # For mapping files with exactly 2 columns, assume first is join column
          join_col <- names(map_dt)[1]
          
          if (join_col %in% names(full_dt)) {
            if (!suppress_warnings) message("Joining mapping file ", map_file, " on column: ", join_col)
            full_dt <- left_join(full_dt, map_dt, by = join_col)
            processing_steps <- c(processing_steps, paste0("joined_mapping_", gsub("\\.", "_", map_file)))
          } else {
            if (!suppress_warnings) message("Skipping mapping file ", map_file, " - join column '", join_col, "' not found in data")
          }
          
        } else {
          
          # For mapping files with >2 columns, use all except last as potential join columns
          potential_join_cols <- names(map_dt)[1:(ncol(map_dt) - 1)]
          join_cols <- intersect(potential_join_cols, names(full_dt))
          
          if (length(join_cols) > 0) {
            if (!suppress_warnings) message("Joining mapping file ", map_file, " on column(s): ", paste(join_cols, collapse = ", "))
            full_dt <- left_join(full_dt, map_dt, by = join_cols)
            processing_steps <- c(processing_steps, paste0("joined_mapping_", gsub("\\.", "_", map_file)))
          } else {
            if (!suppress_warnings) message("Skipping mapping file ", map_file, " - no join columns found in data")
          }
          
        }
        
      }, error = function(e) {
        if (!suppress_warnings) message("Error processing mapping file ", map_file, ": ", e$message)
      })
    }
  }
  
  # STEP 4: Apply table simplification if requested
  if (simplify_table) {
    if (!suppress_warnings) message("Simplifying table structure...")
    
    full_dt <- full_dt |>
      dplyr::mutate(value = as.numeric(value),
                    period_type_code = substr(period,1,1),
                    date = case_when(
                      period %in% c("M13", "Q05") ~ lubridate::ym(paste0(year,"-01")),
                      period_type_code == "Q" ~ lubridate::yq(paste(year, "Q", substr(period,3,3))),
                      TRUE ~ lubridate::ym(paste0(year,period))
                    )
      ) |>
      dplyr::select(-tidyselect::contains("_code"))
    
    processing_steps <- c(processing_steps, "simplified_table")
  }
  
  # Create the BLS data collection object
  bls_collection <- create_bls_object(
    data = full_dt,
    downloads = downloads,
    data_type = paste0("BLS-", toupper(database_code)),
    processing_steps = processing_steps
  )
  
  # Print summary unless suppressed
  if (!suppress_warnings) {
    if (has_bls_issues(bls_collection)) {
      cat("\n")
      print_bls_warnings(bls_collection, detailed = FALSE)
      cat("\nUse print_bls_warnings(result, detailed = TRUE) for detailed diagnostics\n")
    } else {
      cat("\nDownload completed successfully with no issues detected.\n")
    }
  }
  
  # Return based on return_full parameter
  if (return_full) {
    return(list(
      bls_collection = bls_collection,
      full_file = get_bls_data(bls_collection),
      data = data_dt,
      series = series_dt,
      aspect = if (!is.null(selected_aspect_file)) get_bls_data(downloads[[selected_aspect_file]]) else NULL,
      mapping_files = mapping_files,
      file_table = file_table,
      downloads = downloads
    ))
  } else {
    return(bls_collection)
  }
}
