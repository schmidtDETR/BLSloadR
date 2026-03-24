# National CPS Code and Label Mappings with Crosstab of Available Data

A dataset containing the unique code-label pairs extracted from the BLS
CPS data. This includes metadata descriptions and a cross-reference to
other data characteristics to identify valid cross-tabulation paths.

## Usage

``` r
data(national_cps_availability)
```

## Format

A tibble with the following variables:

- master_filter:

  The base column name (e.g., "sexs", "ages") used for filtering.

- master_description:

  The human-readable description of the filter category (e.g.,
  "Sex/gender").

- available_codes:

  A list-column of data frames, each containing:

  - `code`: The specific BLS numeric or alphanumeric code.

  - `label`: The text description of that code.

  - `original_filter`: The master filter name repeated for row-level
    identification.

  - `available_with`: A comma-separated string of other filters that
    have valid data when paired with this specific code. (Marked as
    "Skipped" for columns with many observations like industry and
    occupation).

## Source

Generated from \`BLSloadR::load_bls_dataset("ln", simplify_table =
FALSE)\`.

## Details

The rows in the top-level table contain various data filters available
in the national Current Population Survey and the descriptions of these
data types. The \`available_codes\` column containes a data frame which
includes the codes that are available within this data type. For each
code, the code, description, and other data filters available to further
filter the CPS data are provided.

## Examples

``` r
# Load the lookup table
data(national_cps_availability)

# Find the code details for a specific example
codes<-national_cps_availability[national_cps_availability$master_filter=="jdes","available_codes"]

```
