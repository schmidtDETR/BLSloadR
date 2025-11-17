# Get National Current Employment Statistics (CES) Data from BLS

This function downloads and processes national Current Employment
Statistics (CES) data from the Bureau of Labor Statistics (BLS). It
retrieves multiple related datasets and joins them together to create a
comprehensive employment statistics dataset with industry
classifications, data types, and time period information.

## Usage

``` r
get_national_ces(
  monthly_only = TRUE,
  simplify_table = TRUE,
  show_warnings = TRUE,
  return_diagnostics = FALSE
)
```

## Arguments

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

- show_warnings:

  Logical. If TRUE (default), displays download warnings and
  diagnostics. If FALSE, suppresses warning output.

- return_diagnostics:

  Logical. If TRUE, returns a bls_data_collection object with full
  diagnostics. If FALSE (default), returns just the data table.

## Value

By default, returns a data.table with CES data. If return_diagnostics =
TRUE, returns a bls_data_collection object containing data and
comprehensive diagnostics.

## Details

The function downloads the following BLS CES datasets:

- ce.data.0.AllCESSeries - Main employment data

- ce.series - Series metadata

- ce.industry - Industry classifications

- ce.datatype - Data type definitions

- ce.period - Time period definitions

- ce.supersector - Supersector classifications

These datasets are joined together to provide context and labels for the
employment statistics. The function uses the \`fread_bls()\` helper
function to download and read the BLS data files with robust error
handling and diagnostic reporting.

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
# Get monthly CES data with simplified table structure
ces_monthly <- get_national_ces()

# Get all data including annual averages with full metadata
ces_full <- get_national_ces(monthly_only = FALSE, simplify_table = FALSE)

# Get monthly data but keep all metadata columns
ces_detailed <- get_national_ces(monthly_only = TRUE, simplify_table = FALSE)

# Access the data component
ces_data <- get_bls_data(ces_monthly)

# Get full diagnostic object if needed
data_with_diagnostics <- get_national_ces(return_diagnostics = TRUE)
print_bls_warnings(data_with_diagnostics)
} # }

```
