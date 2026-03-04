# Efficiently Extract and Cache Subsets of CPS (LN) Data

This function extracts specific series from the BLS Current Population
Survey (LN) dataset using intelligent caching to avoid redundant
downloads and processing. It supports filtering by exact series IDs or
by demographic/economic characteristics.

## Usage

``` r
get_cps_subset(
  series_ids = NULL,
  characteristics = NULL,
  simplify_table = TRUE,
  cache = TRUE,
  cache_dir = NULL,
  suppress_warnings = FALSE
)
```

## Arguments

- series_ids:

  Optional character vector of specific series IDs to extract. If NULL,
  must provide characteristics. Can be combined with characteristics to
  expand the query. Use
  [`explore_cps_series`](https://schmidtdetr.github.io/BLSloadR/reference/explore_cps_series.md)
  to discover relevant series IDs.

- characteristics:

  Optional named list of characteristics to filter by (e.g.,
  \`list(ages_code = "00", sexs_code = "1")\`). Available
  characteristics depend on the LN series structure and may include
  ages_code, sexs_code, periodicity_code, and others found in the
  ln.series file. Use
  [`explore_cps_characteristics`](https://schmidtdetr.github.io/BLSloadR/reference/explore_cps_characteristics.md)
  to discover valid codes.

- simplify_table:

  Logical. If TRUE (default), removes internal code columns, converts
  values to numeric, and creates a date column from year and period.
  Also removes display_level, sort_sequence, selectable, and
  footnote_codes columns.

- cache:

  Logical. If TRUE (default), uses persistent local caching for both the
  master data file and the extracted subsets. Cache validity is checked
  against BLS server modification times to ensure data freshness.

- cache_dir:

  Optional character string specifying the directory for cached files.
  If NULL, uses R's temporary directory via \`tempdir()\`. For
  persistent caching across sessions, provide a permanent directory
  path.

- suppress_warnings:

  Logical. If TRUE, suppress individual download warnings. Default is
  FALSE.

## Value

A \`bls_data_collection\` object containing:

- data: The requested subset with series metadata and mapping files
  joined

- download_diagnostics: Information about files accessed during
  extraction

- warnings: Any warnings generated during processing

- summary: Summary statistics about the data collection

## Details

The function uses a two-tier caching strategy:

1.  Master file caching: The full ln.data.1.AllData file is downloaded
    once per session (or permanently if cache_dir is specified) and only
    re-downloaded when the BLS server indicates updates.

2.  Subset caching: Each unique combination of series_ids is cached
    separately using an MD5 hash. Subsets are invalidated if the master
    file is updated.

The function automatically joins relevant mapping files (e.g., ln.ages,
ln.sexs) based on the characteristics present in the requested series.

## See also

[`explore_cps_characteristics`](https://schmidtdetr.github.io/BLSloadR/reference/explore_cps_characteristics.md)
to discover available characteristics and their valid codes,
[`explore_cps_series`](https://schmidtdetr.github.io/BLSloadR/reference/explore_cps_series.md)
to search for specific series by keywords or characteristics.

## Examples

``` r
if (FALSE) { # \dontrun{
# Discover available characteristics and their codes
explore_cps_characteristics()           # List all characteristics
explore_cps_characteristics("sexs")     # See valid sex codes
explore_cps_characteristics("ages")     # See valid age codes

# Search for specific series
explore_cps_series(search = "unemployment rate")
explore_cps_series(
  search = "unemployment",
  characteristics = list(sexs_code = "2"),
  seasonal = "S"
)

# Extract specific series by ID
unemployment <- get_cps_subset(
  series_ids = c("LNS13000000", "LNS12000000"),
  simplify_table = TRUE,
  cache = TRUE
)

# Filter by characteristics
male_series <- get_cps_subset(
  characteristics = list(ages_code = "00", sexs_code = "1"),
  simplify_table = TRUE,
  cache = TRUE
)

# Combine series IDs with characteristics
combined <- get_cps_subset(
  series_ids = "LNS13000000",
  characteristics = list(sexs_code = "1"),
  simplify_table = TRUE,
  cache = TRUE
)

# Use persistent cache directory
unemployment <- get_cps_subset(
  series_ids = c("LNS13000000"),
  cache_dir = "C:/BLS_cache",
  cache = TRUE
)
} # }
```
