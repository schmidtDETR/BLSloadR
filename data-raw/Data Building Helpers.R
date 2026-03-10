# Saved in: data-raw/process_lookups.R
library(readxl)
library(tidyverse)
library(usethis)

# --- Process Industry Lookup ---

# Point to the file inside data-raw
ind_lookup <- read_excel("data-raw/industry-titles.xlsx") |> 
  mutate(
    ind_level = case_when(
      str_detect(industry_code, "-") ~ "NAICS 2-digit",
      !(substr(industry_code,1,2) == "10") ~ paste0("NAICS ",str_length(industry_code),"-digit"),
      industry_code == "10" ~ "Total",
      industry_code %in% c("101","102") ~ "Cluster",
      .default = "Supersector"
    ),
    naics_2d = substr(industry_code,1,2),
    sector = case_when(
      naics_2d %in% c("31", "32", "33") ~ "31-33",
      naics_2d %in% c("44", "45") ~ "44-45",
      naics_2d %in% c("48", "49") ~ "48-49",
      .default = naics_2d
    ),
    vintage_start = 2022L,
    vintage_end = 3000L
  )

# --- Process Area Lookup ---

state_lookup <- data.frame(
  state_names = c(state.name, "Puerto Rico", "Virgin Islands"),
  state_abbreviations = c(state.abb, "PR", "VI")
)

# Point to the file inside data-raw
area_lookup <- read_excel("data-raw/area-titles-xlsx.xlsx") |> 
  mutate(
    area_type = case_when(
      area_title == "U.S. TOTAL" ~ "National",
      str_detect(area_title, "Statewide") ~ "State",
      substr(area_fips,1,2) == "US" | area_fips == "57000" ~ "National Subgroup",
      str_detect(area_title, " CSA") | str_detect(area_title, " Combined Statistical") ~ "Combined Statistical Area",
      str_detect(area_title, " MSA") ~ "Metropolitan Statistical Area",
      str_detect(area_title, " MicroSA") ~ "Micropolitan Statistical Area",
      substr(area_fips,3,5) == "999" ~ "County Unknown or Undefined",
      .default = "County"
    ),
    stfips = if_else(area_type %in% c("State", "County", "County Unknown or Undefined"),
                     substr(area_fips,1,2),
                     "00"),
    specified_region = ifelse(
      grepl(",", area_title),
      sub("^[^,]*[,]\\s*", "", area_title),
      "No region"),
    specified_region = str_remove_all(specified_region, " CSA"),
    specified_region = str_remove_all(specified_region, " Combined Statistical"),
    specified_region = str_remove_all(specified_region, " MSA"),
    specified_region = str_remove_all(specified_region, " MicroSA"),
    specified_region = ifelse(
      specified_region == "No region" & grepl(" -- ", area_title),
      sub(" -- .*", "", area_title),
      specified_region
    )
  ) |> 
  mutate(
    match_index = match(specified_region, state_lookup$state_names),
    specified_region = ifelse(
      !is.na(match_index),
      state_lookup$state_abbreviations[match_index],
      specified_region
    )
  ) |> 
  select(-match_index)

# --- Process Area Lookup ---

library(BLSloadR)
library(tidyverse)

national_cps_full <- load_bls_dataset("ln", simplify_table = FALSE)$data

national_cps_code_cols <- national_cps_full |> 
  select(contains("_code")) |> 
  colnames()

national_cps_all_colnames <- national_cps_full |> 
  colnames()

national_cps_codes <- data.frame(
  codes = national_cps_code_cols
) |> 
  mutate(
    labels = str_replace_all(codes, "_code", "_text"),
    is_real_label = if_else(labels %in% national_cps_all_colnames, TRUE, FALSE)
  )

# 1. Filter for only the rows where a matching label column actually exists
valid_mappings <- national_cps_codes |> 
  filter(is_real_label == TRUE)

# 2. Recursively (iteratively) extract unique pairs
# We use map2 to iterate over the 'codes' and 'labels' column names
national_cps_characteristics <- valid_mappings |> 
  mutate(unique_pairs = map2(codes, labels, function(code_col, label_col) {
    
    national_cps_full |> 
      select(code = all_of(code_col), label = all_of(label_col)) |> 
      distinct() |> 
      drop_na() # Optional: removes rows with missing mapping data
    
  }))


############
### Cross-tabs of available data (SLOW)

library(tidyverse)
library(data.table)

# Ensure the data.table version is ready
dt_full <- as.data.table(national_cps_full)

# 1. Define the missing variable explicitly
all_code_cols <- colnames(dt_full)[grepl("_code$", colnames(dt_full))]

# 2. Helper to check for "Total" codes (0, 00, 000, etc.)
is_zero_code <- function(x) {
  grepl("^0+$", as.character(x))
}

# 3. Main processing
national_cps_availability <- national_cps_pairs |>
  mutate(unique_pairs = map2(codes, unique_pairs, function(col_name, pairs_df) {
    
    # Filter out "Total" rows and "N/A" labels from the lookup table
    target_pairs <- pairs_df |>
      filter(!is_zero_code(code), 
             label != "N/A")
    
    # Nuance: Sample high-cardinality columns to save hours of processing
    if (col_name %in% c("indy_code", "occupation_code")) {
      target_pairs <- target_pairs |> slice_sample(n = 1)
    }
    
    # Iterate through the valid codes
    target_pairs |>
      mutate(available_with = map_chr(code, function(val) {
        
        # Fast subset: rows where this specific characteristic has data
        subset_dt <- dt_full[get(col_name) == val & !is.na(value)]
        
        if (nrow(subset_dt) == 0) return("")
        
        # VECTORIZED CHECK: 
        # Identify columns that have at least one non-NA and non-Zero entry
        # We exclude the current 'col_name' from the check
        peer_cols <- setdiff(all_code_cols, col_name)
        
        # Check presence across all peers at once
        has_data <- sapply(subset_dt[, ..peer_cols], function(column_vec) {
          any(!is.na(column_vec) & !is_zero_code(column_vec))
        })
        
        # Return the clean names of the available peer variables
        available_peers <- names(has_data)[has_data]
        paste(sub("_code$", "", available_peers), collapse = ", ")
      }))
  }))



# --- Save Data to Package ---
# This automatically saves to data/ and creates the .rda files
usethis::use_data(ind_lookup, area_lookup, overwrite = TRUE)
usethis::use_data(national_cps_characteristics, overwrite = TRUE)
usethis::use_data(national_cps_availability, overwrite = TRUE)

