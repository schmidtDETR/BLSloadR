# Download Current Employment Statistics (CES) Data

This function downloads Current Employment Statistics data from the
Bureau of Labor Statistics. The data includes national, regional, state,
and substate employment statistics. By default, all available areas,
data types, and periods are included.

## Usage

``` r
get_ces(
  states = NULL,
  industry_filter = NULL,
  current_year_only = FALSE,
  transform = TRUE,
  monthly_only = TRUE,
  simplify_table = TRUE,
  suppress_warnings = TRUE,
  return_diagnostics = FALSE
)
```

## Arguments

- states:

  Character vector of state abbreviations to download (e.g., c("MA",
  "NY", "CA")). If specified, downloads only these states (all
  industries, all years). Cannot be combined with industry_filter or
  current_year_only. Use \`list_ces_states()\` to see all available
  states.

- industry_filter:

  Character string specifying industry category to download. If
  specified, downloads this industry for all states (2007-present).
  Cannot be combined with states or current_year_only. Use
  \`list_ces_industries()\` to see all available industry filters.

- current_year_only:

  Logical. If TRUE, downloads the current year file which contains all
  states and industries for recent years (2006-present). Cannot be
  combined with states or industry_filter. If FALSE (default), uses
  other parameters.

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

## Details

\*\*Performance Notes:\*\* The default behavior downloads a very large
file (~500MB+) containing all states and industries, which can take
several minutes. For faster downloads, consider:

- Use `states = c("MA", "NY")` to download only specific states

- Use `industry_filter = "total_nonfarm"` for summary employment data
  only

- Use `current_year_only = TRUE` for recent data only (2006-present)

\*\*State Codes:\*\* Use standard two-letter state abbreviations (e.g.,
"MA", "CA", "NY"). Puerto Rico = "PR", Virgin Islands = "VI", District
of Columbia = "DC".

\*\*Industry Filters:\*\* Available options include:

- "total_nonfarm" - Total non-farm employment summary

- "total_private" - Private sector totals (2007-present)

- "manufacturing" - Manufacturing sector (2007-present)

- "construction" - Construction sector (2007-present)

- "retail_trade" - Retail trade sector (2007-present)

- "government" - Government sector (2007-present)

- And others - see BLS documentation for full list

## See also

[`list_ces_states()`](https://schmidtdetr.github.io/BLSloadR/reference/list_ces_states.md)
to see available states,
[`list_ces_industries()`](https://schmidtdetr.github.io/BLSloadR/reference/list_ces_industries.md)
to see available industry filters,
[`show_ces_options()`](https://schmidtdetr.github.io/BLSloadR/reference/show_ces_options.md)
for a comprehensive overview of filtering options.

## Examples

``` r
# \donttest{
# Fast download: Massachusetts and Connecticut data only (all industries)
ces_states <- get_ces(states = c("MA", "CT"))

# Fast download: Manufacturing data for all states
ces_manufacturing <- get_ces(industry_filter = "manufacturing")

# Fast download: Current year data for all states and industries
ces_current <- get_ces(current_year_only = TRUE)

# Complete dataset (slower - all states, industries, and years)
ces_all <- get_ces()
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> ℹ In argument: `value = as.numeric(value)`.
#> Caused by warning:
#> ! NAs introduced by coercion

# Download with full diagnostics if needed
ces_result <- get_ces(states = "MA", return_diagnostics = TRUE)
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
#> Final data dimensions:210438 x 14
#> 
#> Summary of warnings:
#>   1. Series Metadata : Phantom columns detected and cleaned: 1
#>   2. Series Metadata : Empty columns removed: 1
#> 
#> Run with return_diagnostics=TRUE and print_bls_warnings(data, detailed = TRUE) for file-by-file details
# }
```
