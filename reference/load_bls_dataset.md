# Generic BLS Dataset Download

This function generalizes a method to download all BLS data for a given
time series database. These files are accessed from
https://download.bls.gov/pub/time.series/ and several datasets are
available. A summary of an identified database can be generated using
the \`bls_overiew()\` function. When multiple potential data files exist
(common in large data sets), the function will prompt for an input of
which file to use.

## Usage

``` r
load_bls_dataset(
  database_code,
  return_full = FALSE,
  simplify_table = TRUE,
  suppress_warnings = FALSE,
  which_data = NULL,
  cache = check_bls_cache_env()
)
```

## Arguments

- database_code:

  This is the two digit character identifier for the desired database.
  Some Valid options are:

  - "ce" - National Current Employment Statistics Data

  - "sm" - State and Metro area Current Employment Statistics Data

  - "mp" - Major Sector Total Factor Productivity

  - "ci" - Employment Cost Index

  - "eb" - Employee Benefits Survey

- return_full:

  This argument defaults to FALSE. If set to TRUE it will return a list
  of the elements of data retrieved from the BLS separating the data,
  series, and mapping values downloaded.

- simplify_table:

  This parameter defaults to TRUE. When TRUE it will remove all columns
  from the date with "\_code" in the column name, as well as a series of
  internal identifiers which provide general information about the
  series but which are not needed for performing time series analysis.
  This parameter also converts the column "value" to numeric and
  generates a date column from the year and period columns in the data.

- suppress_warnings:

  Logical. If TRUE, suppress individual download warnings during
  processing.

- which_data:

  Character string or NULL. Defaults to NULL.

  - "all" - Automatically selects the data file containing ".1.All"
    (e.g., "bd.data.1.AllItems" or "le.data.1.AllData").

  - "current" - Automatically selects the data file containing "Current"
    (e.g., "ce.data.0.Current").

  - NULL - Default behavior. Prompts the user to select a file if
    multiple exist, or selects the single available file.

  If the requested pattern is not found, the function falls back to the
  default behavior, prompting the user to select a file.

- cache:

  Logical. Uses USE_BLS_CACHE environment variable, or defaults to
  FALSE. If TRUE, will download a cached file from BLS server and update
  cache if BLS server indicates an updated file.

## Value

This function will return either a bls_data_collection object (if
return_full is FALSE or not provided) or a named list of the returned
data including the bls_data_collection object.

## Examples

``` r
if (FALSE) { # \dontrun{
# Import All Data
fm_import <- load_bls_dataset("fm", which_data = "all")

# Get $data element
fm_data <- fm_import$data

# Filter to a Series
# Families with Children Under 6 and No Employed Parent

u6_no_emp <- fm_data |>
  dplyr::filter(series_title == "Total families with children under 6 - with no parent employed") |>
  dplyr:: select(year, value, fchld_text, fhlf_text, tdat_text)


head(u6_no_emp)
} # }

if (FALSE) { # \dontrun{
# Examples requiring manual intervention in the console
# Download Employer Cost Index Data
cost_index <- load_bls_dataset("ci")

# Download separated data, series, and mapping columns
benefits <- load_bls_dataset("eb", return_full = TRUE)

# Download data without removing excess columns and value conversions
productivity <- load_bls_dataset("mp", simplify_table = FALSE)

# Check for download issues
if (has_bls_issues(cost_index)) {
  print_bls_warnings(cost_index, detailed = TRUE)
}

} # }
```
