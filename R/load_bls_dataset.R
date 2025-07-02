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
#' @returns This function will return either a data table (if return_full is FALSE or not provided)
#'  or a named list of the returned data.
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
#' }


load_bls_dataset <- function(database_code, return_full = FALSE, simplify_table = TRUE) {
  
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
    grepl("\\.series$", file_name), "series",
    default = "mapping"
  )]
  
  # Identify files
  mapping_files <- file_table[file_type == "mapping", file_name]
  data_files <- file_table[file_type == "data", file_name]
  series_file <- file_table[file_type == "series", file_name]
  
  if (length(series_file) == 0) {
    stop("Could not find a series file in the BLS database directory.")
  }
  
  # Handle multiple series files (take the first one if multiple exist)
  if (length(series_file) > 1) {
    series_file <- series_file[1]
    message("Multiple series files found. Using: ", series_file)
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
  
  # Download and combine data files
  data_list <- lapply(selected_data_file, function(fname) {
    full_url <- paste0(base_url, fname)
    message("Reading data file: ", full_url)
    fread_bls(full_url)
  })
  
  data_dt <- rbindlist(data_list, use.names = TRUE, fill = TRUE)
  
  # Download series file
  series_url <- paste0(base_url, series_file)
  message("Reading series file: ", series_url)
  series_dt <- fread_bls(series_url)
  
  # STEP 1: Join data to series first to get lookup codes
  message("Joining data to series file...")
  full_dt <- left_join(data_dt, series_dt, by = "series_id")
  
  # STEP 2: Now join mapping files to the combined data+series table
  # This ensures that all lookup codes from the series are available for mapping joins
  for (map_file in mapping_files) {
    tryCatch({
      map_url <- paste0(base_url, map_file)
      message("Reading mapping file: ", map_url)
      map_dt <- fread_bls(map_url)
      join_col <- names(map_dt)[1]
      
      # Only join to the combined full_dt table, not separately to data_dt and series_dt
      if (join_col %in% names(full_dt)) {
        message("Joining mapping file on column: ", join_col)
        full_dt <- left_join(full_dt, map_dt, by = join_col)
      } else {
        message("Skipping mapping file - join column '", join_col, "' not found in data")
      }
      
    }, error = function(e) {
      message("Error processing mapping file ", map_file, ": ", e$message)
    })
  }
  
  if (simplify_table) {
    
    full_dt <- full_dt |>
      dplyr::mutate(value = as.numeric(value),
                    period_type_code = substr(period,1,1),
                    date = case_when(
                      period %in% c("M13", "Q05") ~ lubridate::ym(paste0(year,period)),
                      period_type_code == "Q" ~ lubridate::yq(paste(year, "Q", substr(period,3,3))),
                      TRUE ~ lubridate::ym(paste0(year,period))
                    )
      ) |>
      dplyr::select(-tidyselect::contains("_code"),
                    -tidyselect::matches(c("begin_year", "begin_period", "end_year", "end_period", "selectable", "sort_sequence", "display_level")))
    
  }
  
  if(return_full){
    return(list(
      full_file = full_dt,
      data = data_dt,
      series = series_dt,
      mapping_files = mapping_files,
      file_table = file_table
    ))
  } else {
    return(full_dt)
  }
  
}