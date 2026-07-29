# Get National Current Employment Statistics (CES) Data from BLS

This function downloads and processes national Current Employment
Statistics (CES) data from the Bureau of Labor Statistics (BLS). It
retrieves multiple related datasets and joins them together to create a
comprehensive employment statistics dataset with industry
classifications, data types, and time period information.

## Usage

``` r
get_national_ces(
  dataset_filter = "all_data",
  monthly_only = TRUE,
  simplify_table = TRUE,
  suppress_warnings = TRUE,
  return_diagnostics = FALSE,
  cache = check_bls_cache_env(),
  user_agent = NULL
)
```

## Arguments

- dataset_filter:

  Character string specifying which dataset to download. Options
  include:

  - "all_data" (default) - Complete dataset with all series

  - "current_seasonally_adjusted" - Only seasonally adjusted
    all-employee series

  - "real_earnings_all_employees" - Real earnings data for all employees

  - "real_earnings_production" - Real earnings data for production
    employees

- monthly_only:

  Logical. If TRUE (default), excludes annual averages (period "M13")
  and returns only monthly data. If FALSE, includes all periods
  including annual averages.

- simplify_table:

  Logical. If TRUE (default), removes several metadata columns
  (series_title, begin_year, begin_period, end_year, end_period,
  naics_code, publishing_status, display_level, selectable,
  sort_sequence) and adds a formatted date column. If FALSE, returns the
  full dataset with all available columns.

- suppress_warnings:

  Logical. If TRUE (default), suppresses download warnings and
  diagnostics. If FALSE, displays warning output and diagnostic
  information.

- return_diagnostics:

  Logical. If TRUE, returns a bls_data_collection object with full
  diagnostics. If FALSE (default), returns just the data table.

- cache:

  Logical. Uses USE_BLS_CACHE environment variable, or defaults to
  FALSE. If TRUE, will download a cached file from BLS server and update
  cache if BLS server indicates an updated file.

- user_agent:

  Optional character string which provides a USER_AGENT value for the
  HTTP request for data form BLS.

## Value

By default, returns a data.table with CES data. If return_diagnostics =
TRUE, returns a bls_data_collection object containing data and
comprehensive diagnostics.

## Details

The function can download one of four specialized national CES datasets
based on the dataset_filter parameter:

- all_data: Complete dataset (ce.data.0.AllCESSeries) - contains entire
  history of all series currently published by the CES program

- current_seasonally_adjusted: (ce.data.01a.CurrentSeasAE) - contains
  every seasonally adjusted all employee series and complete history

- real_earnings_all_employees: (ce.data.02b.AllRealEarningsAE) -
  contains real earnings data (1982-84 dollars) for all employees

- real_earnings_production: (ce.data.03c.AllRealEarningsPE) - contains
  real earnings data (1982-84 dollars) for production/nonsupervisory
  employees

Additional metadata files are always downloaded and joined:

- ce.series - Series metadata

- ce.industry - Industry classifications

- ce.datatype - Data type definitions

- ce.period - Time period definitions

- ce.supersector - Supersector classifications

These datasets are joined together to provide context and labels for the
employment statistics. The function uses the enhanced
\`download_bls_files()\` helper function for robust downloads with
diagnostic reporting.

Performance Note: Using specialized datasets (other than "all_data") can
significantly reduce download time and file size while still providing
comprehensive employment statistics.

## Note

This function requires the following packages: dplyr, data.table, httr,
and lubridate (for date formatting when simplify_table=TRUE). The
\`fread_bls()\` and \`create_bls_object()\` helper functions must be
available in your environment.

## See also

Please visit the Bureau of Labor Statistics at https://www.bls.gov/ces/
for more information about CES data

## Examples

``` r
if (FALSE) { # \dontrun{
# Get complete monthly CES data with simplified table structure (default)
ces_monthly <- get_national_ces()

# Get only seasonally adjusted data (faster download)
ces_seasonal <- get_national_ces(dataset_filter = "current_seasonally_adjusted")

# Get real earnings data for all employees
ces_real_earnings <- get_national_ces(dataset_filter = "real_earnings_all_employees")

# Get all data including annual averages with full metadata
ces_full <- get_national_ces(dataset_filter = "all_data",
                             monthly_only = FALSE, simplify_table = FALSE)

# Get data with warnings and diagnostic information displayed
ces_with_warnings <- get_national_ces(suppress_warnings = FALSE)

# Get full diagnostic object if needed
data_with_diagnostics <- get_national_ces(return_diagnostics = TRUE)
print_bls_warnings(data_with_diagnostics)
} # }

```
