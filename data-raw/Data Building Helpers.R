# Saved in: data-raw/process_lookups.R
library(readxl)
library(tidyverse)
library(usethis)

# --- Process Industry Lookup ---

# Point to the file inside data-raw
ind_lookup <- read_excel("data-raw/industry-titles.xlsx") |> 
  mutate(
    ind_level = case_when(
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

# --- Save Data to Package ---
# This automatically saves to data/ and creates the .rda files
usethis::use_data(ind_lookup, area_lookup, overwrite = TRUE)