# Download Local Area Unemployment Statistics (LAUS) Data

This function downloads Local Area Unemployment Statistics data from the
U.S. Bureau of Labor Statistics. Due to the large size of some LAUS
datasets (county and city files are \>300MB), users must specify which
geographic level to download. The function provides access to both
seasonally adjusted and unadjusted data at various geographic levels.
Additional datasets provide comprehensive non-seasonally-adjusted data
for all areas broken out in 5-year increments

## Usage

``` r
get_laus(
  geography = "state_adjusted",
  monthly_only = TRUE,
  transform = TRUE,
  suppress_warnings = FALSE,
  return_diagnostics = FALSE
)
```

## Arguments

- geography:

  Character string specifying the geographic level and adjustment type.
  Default is "state_adjusted". Valid options are:

  - "state_current_adjusted" - Current seasonally adjusted state data

  - "state_unadjusted" - All historical unadjusted state data

  - "state_adjusted" - All historical seasonally adjusted state data
    (default)

  - "region_unadjusted" - Unadjusted regional and division data

  - "region_adjusted" - Seasonally adjusted regional and division data

  - "metro" - Metropolitan statistical area data

  - "division" - Division-level data

  - "micro" - Micropolitan statistical area data

  - "combined" - Combined statistical area data

  - "county" - County-level data (large file \>300MB)

  - "city" - City and town data (large file \>300MB)

  - "1990-1994" - Comprehensive unadjusted data for 1990-1994

  - "1995-1999" - Comprehensive unadjusted data for 1995-1999

  - "2000-2004" - Comprehensive unadjusted data for 2000-2004

  - "2005-2009" - Comprehensive unadjusted data for 2005-2009

  - "2010-2014" - Comprehensive unadjusted data for 2010-2014

  - "2015-2019" - Comprehensive unadjusted data for 2015-2019

  - "2020-2024" - Comprehensive unadjusted data for 2020-2024

  - "2025-2029" - Comprehensive unadjusted data for 2025-2029

  - "ST" - Any state two-character USPS abbreviation, plus DC and PR

- monthly_only:

  Logical. If TRUE (default), excludes annual data (period M13) and
  creates a date column from year and period.

- transform:

  Logical. If TRUE (default), converts rate and ratio measures from
  percentages to proportions by dividing by 100. Unemployment rates will
  be expressed as decimals (e.g., 0.05 for 5% unemployment) rather than
  as whole numbers (e.g. 5).

- suppress_warnings:

  Logical. If TRUE, suppress individual download warnings for cleaner
  output during batch processing.

- return_diagnostics:

  Logical. If TRUE, returns a bls_data_collection object with full
  diagnostics. If FALSE (default), returns just the data table.

## Value

By default, returns a data.table with LAUS data. If return_diagnostics =
TRUE, returns a bls_data_collection object containing LAUS data with the
following key columns:

- series_id:

  BLS series identifier

- year:

  Year of observation

- period:

  Time period (M01-M12 for months, M13 for annual)

- value:

  Employment statistic value (transformed if transform = TRUE)

- date:

  Date of observation (if monthly_only = TRUE)

- area_text:

  Geographic area name

- area_type_code:

  Code indicating area type

- measure_text:

  Type of measure (unemployment rate, labor force, employment, etc.)

- seasonal:

  Seasonal adjustment status

## Details

The function joins data from multiple BLS files:

- Main data file (varies by geography selection)

- Series definitions (la.series)

- Area codes and names (la.area)

- Measure definitions (la.measure)

## Examples

``` r
if (FALSE) { # \dontrun{
# Download state-level seasonally adjusted data (default operation)
laus_states <- get_laus()

# Download unadjusted state data
laus_states_raw <- get_laus("state_unadjusted")

# Download metro area data with rates as whole number percentages (64.3 instead of 0.643)
laus_metro <- get_laus("metro", transform = FALSE)

# Get full diagnostic object if needed
laus_with_diagnostics <- get_laus(return_diagnostics = TRUE)
print_bls_warnings(laus_with_diagnostics)

# Warning: Large files - county and city data
# laus_counties <- get_laus("county")
# laus_cities <- get_laus("city")

# View unemployment rates by state for latest period
unemployment <- laus_states[grepl("rate", measure_text) & date == max(date)]
} # }
```
