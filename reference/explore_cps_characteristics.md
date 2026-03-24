# Explore Available CPS (LN) Characteristics and Codes

This helper function allows users to discover available characteristics
and their valid codes in the BLS Current Population Survey (LN) dataset.

## Usage

``` r
explore_cps_characteristics(
  characteristic = NULL,
  pattern = NULL,
  cache_dir = NULL,
  cache = check_bls_cache_env(),
  verbose = TRUE,
  static = FALSE
)
```

## Arguments

- characteristic:

  Optional character string specifying which characteristic to explore
  (e.g., "ages", "sexs"). If NULL, returns a list of all available
  characteristics or matches based on the \`pattern\`.

- pattern:

  Optional character string. If provided, filters the available
  characteristics by matching this pattern against names and
  descriptions. Functions best when \`static=TRUE\`

- cache_dir:

  Optional character string for cached files.

- cache:

  Logical. Optional parameter determining whether to use the BLSloadR
  file cache folder. By default, checks status os USE_BLS_CACHE
  environment variable, and otherwise is set to FALSE.

- verbose:

  Logical. If TRUE, print informative messages. Default is TRUE.

- static:

  Logical. If TRUE, use built-in \`national_cps_availability\` to
  populate the function output to ensure that only filter values
  actually present in the data are included..

## Value

A data.frame of characteristics or specific code mappings.

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
# Get Static CPS Code lookups
# Search for any characteristic related to "work"
work_chars <- explore_cps_characteristics(pattern = "work", static = TRUE)

vets_codes <- explore_cps_characteristics("vets", static = TRUE)
job_search_codes <- explore_cps_characteristics("look", static = TRUE)
# Get codes for the 'wkst' (Work Status) characteristic
wkst_codes <- explore_cps_characteristics("wkst", static = TRUE)
} # }
```
