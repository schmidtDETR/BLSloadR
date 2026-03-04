# Explore Available CPS (LN) Characteristics and Codes

This helper function allows users to discover available characteristics
and their valid codes in the BLS Current Population Survey (LN) dataset.
It can list all available characteristics or show the valid codes for
specific characteristics.

## Usage

``` r
explore_cps_characteristics(
  characteristic = NULL,
  cache_dir = NULL,
  verbose = TRUE
)
```

## Arguments

- characteristic:

  Optional character string specifying which characteristic to explore
  (e.g., "ages", "sexs", "race", "education"). If NULL, returns a list
  of all available characteristics. Do not include "\_code" suffix.

- cache_dir:

  Optional character string specifying the directory for cached files.
  If NULL, uses R's temporary directory via \`tempdir()\`.

- verbose:

  Logical. If TRUE, print informative messages. Default is TRUE.

## Value

If \`characteristic\` is NULL, returns a data.frame with columns:

- characteristic: Name of the characteristic (without \_code suffix)

- code_column: The column name used in filtering (with \_code suffix)

- description: Brief description of the characteristic

If \`characteristic\` is specified, returns a data.frame showing all
valid codes and their text descriptions for that characteristic.

## Details

This function downloads the ln.series file and associated mapping files
from the BLS server to identify available characteristics. The results
are cached locally to avoid repeated downloads.

Common characteristics include:

- ages: Age groups (e.g., 16+ years, 20-24 years)

- sexs: Sex/gender categories

- race: Racial categories

- education: Educational attainment levels

- periodicity: Data frequency (monthly, quarterly, annual)

- seasonal: Seasonal adjustment status

- occupation: Occupation categories

- indy: Industry categories

## Examples

``` r
if (FALSE) { # \dontrun{
# List all available characteristics
all_chars <- explore_cps_characteristics()

# Explore specific characteristics
age_codes <- explore_cps_characteristics("ages")
sex_codes <- explore_cps_characteristics("sexs")
education_codes <- explore_cps_characteristics("education")

# Use the codes in get_cps_subset
data <- get_cps_subset(
  characteristics = list(
    ages_code = "00",      # 16 years and over
    sexs_code = "1"        # Men
  )
)
} # }
```
