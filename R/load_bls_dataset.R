# This function generalizes a method to download all BLS data for a given time series database.
# It currently merges all .data files (not ideal)
# It should prompt when multiple data files exist which one to load.
# It needs a simplify_table function to:
#   * remove _code columns
#   * convert value to numeric (and maybe multiply/divide to appropriate level)
#   * create a date column from year/period

load_bls_dataset <- function(database_code, return_full = FALSE, simplify_table = TRUE) {
  
  # Validate inputs
  if (!is.character(database_code) || length(database_code) != 1) {
    stop("database_code must be a single character string")
  }
  
  base_url <- sprintf("https://download.bls.gov/pub/time.series/%s/", database_code)
  overview_url <- paste0(base_url, database_code, ".txt")
  
  # Read overview file
  overview_lines <- read_bls_text(overview_url)
  
  # Extract Section 2
  start_idx <- grep("Section 2", overview_lines)
  end_idx <- grep("Section 3", overview_lines)
  # Extract Section 2 lines and clean them
  section2_lines <- overview_lines[(start_idx + 3):(end_idx - 2)]
  section2_lines <- section2_lines[grepl(paste0("^\\s*", database_code, "\\."), section2_lines)]
  
  # Extract filenames from the cleaned section
  file_names <- section2_lines |>
    str_extract("^\\s*\\S+") |>
    str_trim()
  
  # Create file table and classify by pattern
  file_table <- data.table(file_name = file_names)
  file_table[, file_type := fcase(
    grepl("\\.data", file_name), "data",
    grepl("\\.series$", file_name), "series",
    grepl("\\.txt$", file_name), "overview",
    default = "mapping"
  )]
  
  # Identify files
  mapping_files <- file_table[file_type == "mapping", file_name]
  data_files <- file_table[file_type == "data", file_name]
  series_file <- file_table[file_type == "series", file_name]
  
  if (is.na(series_file)) {
    stop("Could not find a series file in the BLS database directory.")
  }
  
  # --- New logic for data file selection ---
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
    cat("Loading:", selected_data_file, "\n") # Indicate which file is being loaded
    
    # Read the selected data file (CORRECTED LINE)
    data_list <- read_bls_text(paste0(base_url, selected_data_file))
    
  } else if (length(data_files) == 1) {
    # If there is only one data file, use it directly
    selected_data_file <- data_files[1]
    cat("Loading:", selected_data_file, "\n") # Indicate which file is being loaded
    data_list <- read_bls_text(paste0(base_url, selected_data_file))
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
  
  # Join mapping files
  for (map_file in mapping_files) {
    try({
      map_url <- paste0(base_url, map_file)
      message("Reading mapping file: ", map_url)
      map_dt <- fread_bls(map_url)
      join_col <- names(map_dt)[1]
      
      if (join_col %in% names(series_dt)) {
        series_dt <- left_join(series_dt, map_dt)
      }
      if (join_col %in% names(data_dt)) {
        data_dt <- left_join(data_dt, map_dt)
      }
      
    })
  }
  
  full_dt <- left_join(data_dt, series_dt, by = "series_id")
  
  if (simplify_table) {
    
    full_dt <- full_dt |>
      dplyr::select(-tidyselect::contains("_code"),
                    -tidyselect::matches(c("begin_year", "begin_period", "end_year", "end_period", "selectable", "sort_sequence", "display_level"))) |>
      dplyr::mutate(value = as.numeric(value),
                    date = lubridate::ym(paste0(year,period)))
    
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

