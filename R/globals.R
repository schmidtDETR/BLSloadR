# R/globals.R
# Global variables declaration to avoid R CMD check warnings
# These variables are used in non-standard evaluation contexts (dplyr, data.table, etc.)

utils::globalVariables(c(
  # Common BLS series metadata columns
  "series_id",
  "series_title", 
  "begin_year",
  "begin_period",
  "end_year", 
  "end_period",
  "footnote_codes",
  "publishing_status",
  "display_level",
  "selectable",
  "sort_sequence",
  "naics_code",
  "sector_code",
  
  # Time and date related variables
  "year",
  "period", 
  "value",
  "benchmark_year",
  "quarter",
  "start quarter",
  "start year",
  "end quarter", 
  "end year",
  "unique period",
  
  # Geographic identifiers
  "fips",
  "fips_len",
  "state",
  "state_code",
  "record",
  
  # Employment and labor force measures
  "civilian_labor_force",
  "unemployed",
  "involuntary_part_time_employed",
  "marginally_attached_not_discouraged",
  "all_marginally_attached",
  "discouraged_workers",
  "job_losers",
  "not_job_losers",
  "unemployed_15+_weeks",
  "u1",
  "u2", 
  "u3",
  "u4",
  "u4b",
  "u5",
  "u5b",
  
  # Data classification codes and column names
  "data_type_code",
  "data_type_text",
  "dataelement_code",
  "measure_text",
  "ratelevel_code",
  "file_type",
  "file_name",
  "NAME",
  
  # Statistical functions (base R)
  "median",
  "quantile",
  
  # Placeholders within functions
  "result"
  
))

# Note: This file declares global variables used throughout the BLSloadR package
# to suppress R CMD check warnings about "no visible binding for global variable".
# These variables are column names that exist in BLS datasets and are referenced
# using non-standard evaluation in dplyr and data.table operations.