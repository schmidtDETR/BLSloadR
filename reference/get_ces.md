# Download Current Employment Statistics (CES) Data

This function downloads Current Employment Statistics data from the
Bureau of Labor Statistics. The data includes national, regional, state,
and substate employment statistics. By default, all available areas,
data types, and periods are included.

## Usage

``` r
get_ces(
  transform = TRUE,
  monthly_only = TRUE,
  simplify_table = TRUE,
  suppress_warnings = FALSE,
  return_diagnostics = FALSE
)
```

## Arguments

- transform:

  Logical. If TRUE (default), converts employment values from thousands
  to actual counts by multiplying by 1000 for specific data types (codes
  1, 6, 26) and removes ", In Thousands" from data type labels.

- monthly_only:

  Logical. If TRUE (default), filters out annual data (period M13).

- simplify_table:

  Logical. If TRUE (default), removes excess columns and creates a date
  column from Year and Period in the original data.

- suppress_warnings:

  Logical. If FALSE (default), prints warnings for any BLS download
  issues. If TRUE, warnings are suppressed but still returned invisibly.

- return_diagnostics:

  Logical. If FALSE (default), returns only the data. If TRUE, returns
  the full bls_data_collection object with diagnostics.

## Value

By default, returns a data.table with CES data. If return_diagnostics =
TRUE, returns a bls_data_collection object containing data and
comprehensive diagnostics.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download CES data (streamlined approach)
ces_data <- get_ces()

# Download with full diagnostics if needed
ces_result <- get_ces(return_diagnostics = TRUE)
ces_data <- get_bls_data(ces_result)

# Check for download issues
if (has_bls_issues(ces_result)) {
  print_bls_warnings(ces_result)
}
} # }
```
