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
  suppress_warnings = TRUE,
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

  Logical. If TRUE (default), suppress individual download warnings and
  diagnostic messages for cleaner output during batch processing. If
  FALSE, returns the data and prints warnings and messages to the
  console.

- return_diagnostics:

  Logical. If FALSE (default), returns only the data. If TRUE, returns
  the full bls_data_collection object with diagnostics.

## Value

By default, returns a data.table with CES data. If return_diagnostics =
TRUE, returns a bls_data_collection object containing data and
comprehensive diagnostics.

## Examples

``` r
# \donttest{
# Download CES data (streamlined approach)
ces_data <- get_ces()
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> ℹ In argument: `value = as.numeric(value)`.
#> Caused by warning:
#> ! NAs introduced by coercion

# Download with full diagnostics if needed
ces_result <- get_ces(return_diagnostics = TRUE)
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> ℹ In argument: `value = as.numeric(value)`.
#> Caused by warning:
#> ! NAs introduced by coercion
ces_data <- get_bls_data(ces_result)

# Check for download issues
if (has_bls_issues(ces_result)) {
  print_bls_warnings(ces_result)
}
#> CESData Download Warnings:
#> ============================
#> Total files downloaded:7
#> Files with issues:1
#> Total warnings:2
#> Final data dimensions:9354820 x 14
#> 
#> Summary of warnings:
#>   1. Series Metadata : Phantom columns detected and cleaned: 1
#>   2. Series Metadata : Empty columns removed: 1
#> 
#> Run with return_diagnostics=TRUE and print_bls_warnings(data, detailed = TRUE) for file-by-file details
# }
```
