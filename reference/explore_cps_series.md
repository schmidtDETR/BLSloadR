# Search and Explore CPS (LN) Series IDs

This helper function allows users to search for specific CPS series by
keywords in the series title or by filtering on characteristics. It
returns matching series IDs along with their descriptions, making it
easier to identify the exact series needed for analysis.

## Usage

``` r
explore_cps_series(
  search = NULL,
  characteristics = NULL,
  seasonal = NULL,
  max_results = 50,
  cache_dir = NULL,
  verbose = TRUE
)
```

## Arguments

- search:

  Optional character string or vector to search for in series titles.
  Case-insensitive partial matching is used. Can search for terms like
  "unemployment", "labor force", "participation", etc.

- characteristics:

  Optional named list of characteristics to filter by (e.g.,
  \`list(ages_code = "00", sexs_code = "1")\`). Use
  [`explore_cps_characteristics`](https://schmidtdetr.github.io/BLSloadR/reference/explore_cps_characteristics.md)
  to discover valid codes.

- seasonal:

  Optional character string to filter by seasonal adjustment: "S" for
  seasonally adjusted, "U" for not seasonally adjusted.

- max_results:

  Maximum number of results to return. Default is 50.

- cache_dir:

  Optional character string specifying the directory for cached files.
  If NULL, uses R's temporary directory via \`tempdir()\`.

- verbose:

  Logical. If TRUE, print informative messages. Default is TRUE.

## Value

A data.frame with columns:

- series_id: The BLS series identifier

- series_title: Human-readable description of the series

- seasonal: "S" (seasonally adjusted) or "U" (not adjusted)

- begin_year/begin_period: When the series starts

- end_year/end_period: When the series ends (or latest available)

- Additional characteristic codes (ages_code, sexs_code, etc.)

## Details

This function downloads the ln.series metadata file and filters it based
on your search criteria. It's particularly useful when you want to:

- Find series by topic (e.g., "unemployment rate for women")

- Discover what series exist for specific demographic groups

- Identify the correct series ID before calling
  [`get_cps_subset`](https://schmidtdetr.github.io/BLSloadR/reference/get_cps_subset.md)

## See also

[`explore_cps_characteristics`](https://schmidtdetr.github.io/BLSloadR/reference/explore_cps_characteristics.md)
to discover valid characteristic codes,
[`get_cps_subset`](https://schmidtdetr.github.io/BLSloadR/reference/get_cps_subset.md)
to retrieve data for discovered series.

## Examples

``` r
if (FALSE) { # \dontrun{
# Search for unemployment-related series
explore_cps_series(search = "unemployment rate")

# Find all series for men aged 16+
explore_cps_series(
  characteristics = list(sexs_code = "1", ages_code = "00")
)

# Search for labor force participation, seasonally adjusted
explore_cps_series(
  search = "labor force participation",
  seasonal = "S"
)

# Combine search terms and characteristics
explore_cps_series(
  search = "unemployment",
  characteristics = list(sexs_code = "2", ages_code = "00"),
  seasonal = "S",
  max_results = 10
)
} # }
```
