# Download Job Openings and Labor Turnover Survey (JOLTS) Data

This function downloads Job Openings and Labor Turnover data from the
U.S. Bureau of Labor Statistics. JOLTS data provides insights into job
market dynamics including job openings, hires, separations, quits, and
layoffs. Data is available at national, regional, and state levels with
various industry and size class breakdowns.

## Usage

``` r
get_jolts(
  monthly_only = TRUE,
  remove_regions = TRUE,
  remove_national = TRUE,
  suppress_warnings = TRUE,
  return_diagnostics = FALSE
)
```

## Arguments

- monthly_only:

  Logical. If TRUE (default), excludes annual data (period M13) and
  includes only monthly observations.

- remove_regions:

  Logical. If TRUE (default), excludes regional aggregates (Midwest,
  Northeast, South, West) identified by state codes MW, NE, SO, WE.

- remove_national:

  Logical. If TRUE (default), excludes national-level data (state code
  00). Set to FALSE to include national data with industry and size
  class breakdowns.

- suppress_warnings:

  Logical. If TRUE (default), suppress individual download warnings and
  diagnostic messages for cleaner output during batch processing. If
  FALSE, returns the data and prints warnings and messages to the
  console.

- return_diagnostics:

  Logical. If TRUE, returns a bls_data_collection object with full
  diagnostics. If FALSE (default), returns just the data table.

## Value

By default, returns a data.table with JOLTS data. If return_diagnostics
= TRUE, returns a bls_data_collection object containing JOLTS data with
the following key columns:

- series_id:

  BLS series identifier

- year:

  Year of observation

- period:

  Time period (M01-M12 for months)

- value:

  JOLTS statistic value (transformed based on data type)

- date:

  Date of observation

- state_text:

  State name

- dataelement_text:

  Type of JOLTS measure (job openings, hires, separations, etc.)

- area_text:

  Geographic area description

- sizeclass_text:

  Establishment size class

- industry_text:

  Industry classification

- ratelevel_code:

  Whether the value is a "Level" (count) or "Rate" (percentage)

- periodname:

  Month name

## Details

The function performs several data transformations:

- Converts rate values to proportions (divides by 100) except for
  Unemployed to Job Opening ratio.

- Converts level values to actual counts (multiplies by 1000)

- Creates a proper date column from year and period

- Adds readable month names

## Examples

``` r
# \donttest{
# Download state-level JOLTS data (default - returns data directly)
jolts_data <- get_jolts()

# Include national data with industry breakdowns
jolts_national <- get_jolts(remove_national = FALSE)
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> ℹ In argument: `value = as.numeric(value)`.
#> Caused by warning:
#> ! NAs introduced by coercion

# Get full diagnostic object if needed
jolts_with_diagnostics <- get_jolts(return_diagnostics = TRUE)
print_bls_warnings(jolts_with_diagnostics)
#> JOLTSData Download Warnings:
#> ==============================
#> Total files downloaded:7
#> Files with issues:1
#> Total warnings:2
#> Final data dimensions:318087 x 22
#> 
#> Summary of warnings:
#>   1. series : Phantom columns detected and cleaned: 1
#>   2. series : Empty columns removed: 1
#> 
#> Run with return_diagnostics=TRUE and print_bls_warnings(data, detailed = TRUE) for file-by-file details

# View job openings by state for latest period
job_openings <- jolts_data[dataelement_text == "Job openings" & 
                          date == max(date)]
# }
```
