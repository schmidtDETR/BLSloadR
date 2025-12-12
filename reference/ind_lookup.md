# NAICS Industry Titles Lookup Table (QCEW)

A data frame containing the structure of the North American Industry
Classification System (NAICS) titles and codes used by the U.S. Bureau
of Labor Statistics (BLS), including in the Quarterly Census of
Employment and Wages (QCEW) program. This data is current as of the 2022
NAICS revision.

This table is primarily used internally by \`BLSloadR\` functions to add
human-readable industry titles or define valid industry lookups.

## Usage

``` r
data(ind_lookup)
```

## Format

A data frame with 2678 rows and 7 columns:

- industry_code - Character. The NAICS industry code. Items starting
  with 10 are aggregated values, not corresponding to a unique 6-digit
  NAICS.

- industry_title - Character. The descripion of the industry code
  provided by the BLS. This title also includes the code value for
  clarity.

- ind_level - Character. A description of the level of aggregation.
  Values are "Total", "Cluster", or "Supersector" for the "10" code
  aggregations, or else the length of the NAICS code, from 2-6 digits.

- naics_2d - Character. The first two digits of \`industry_code\`, which
  may be helpful to filter the results.

- sector - Character. Similar to \`naics_2d\` except that when the
  industry sector spans multiple two digit codes, those codes are
  hyphenated (e.g. Manufacturing is NAICS 31, 32, and 33, so this
  displays '31-33').

- vintage_start - Integer. The earliest year reviewed for NAICS code
  use. NAICS will change every 5 years, so data from before this year
  will have some missing values.

- vintage_end - Integer. The last year that a particular code is used,
  if applicable. Set to 3000 for current codes.

## Source

<https://www.bls.gov/cew/classifications/industry/industry-titles.htm>

## Details

The NAICS structure is hierarchical. Codes are typically longer for more
detailed industries.

## Examples

``` r
# Load the lookup table
data(ind_lookup)

# Find the industry title for NAICS 51 (Information)
ind_lookup[ind_lookup$industry_code == "51", ]
#> # A tibble: 1 × 7
#>   industry_code industry_title       ind_level     naics_2d sector vintage_start
#>   <chr>         <chr>                <chr>         <chr>    <chr>          <int>
#> 1 51            NAICS 51 Information NAICS 2-digit 51       51              2022
#> # ℹ 1 more variable: vintage_end <int>

# Get the supersector codes
supersectors <- ind_lookup[ind_lookup$ind_level == "Supersector", ]

# Get all 3-digit NAICS codes in the Manufacturing industry
mfg_codes <- ind_lookup |> 
dplyr::filter(sector == "31-33" & ind_level == "NAICS 3-digit")
```
