# Download State Alternative Labor Market Measures (SALT) Data

This function downloads detailed alternative unemployment measures data
from BLS, including U-1 through U-6 measures. The data provides a more
comprehensive view of labor market conditions beyond the standard
unemployment rate (U-3).

## Usage

``` r
get_salt(
  only_states = TRUE,
  geometry = FALSE,
  suppress_warnings = TRUE,
  return_diagnostics = FALSE
)
```

## Arguments

- only_states:

  Logical. If TRUE (default), includes only state-level data. If FALSE,
  includes sub-state areas like New York City where available.

- geometry:

  Logical. If TRUE, uses tigris::states() to download shapefiles for the
  states to include in the data. If FALSE (default), only returns data
  table.

- suppress_warnings:

  Logical. If TRUE (default), suppress individual download warnings and
  diagnostic messages for cleaner output during batch processing. If
  FALSE, returns the data and prints warnings and messages to the
  console.

- return_diagnostics:

  Logical. If TRUE, returns a bls_data_collection object with full
  diagnostics. If FALSE (default), returns just the data table.

## Value

By default, returns a data.table with Alternative Measures of Labor
Underutilization data. If return_diagnostics = TRUE, returns a
bls_data_collection object containing data and comprehensive
diagnostics. The function also adds derived measures and quartile
comparisons across states.

## Examples

``` r
# \donttest{
# Download state-level SALT data
salt_data <- get_salt()
#> Downloading SALT data from BLS...
#> Processing SALT Excel file...

# View top 10 highest U-6 rates by state in current data
latest <- salt_data |> 
  dplyr::filter(date == max(date)) |> 
  dplyr::select(state, u6) |> 
  dplyr::arrange(-u6)
head(latest)
#> # A tibble: 6 × 2
#>   state                   u6
#>   <chr>                <dbl>
#> 1 California           0.1  
#> 2 Nevada               0.096
#> 3 Michigan             0.093
#> 4 District of Columbia 0.092
#> 5 Oregon               0.091
#> 6 Washington           0.089

# Include sub-state areas
salt_all <- get_salt(only_states = FALSE)
#> Downloading SALT data from BLS...
#> Processing SALT Excel file...
 
# Download SALT with geometry included
get_salt(geometry = TRUE)
#> Downloading SALT data from BLS...
#> Processing SALT Excel file...
#> Retrieving data for the year 2024
#>   |                                                                              |                                                                      |   0%  |                                                                              |                                                                      |   1%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |===                                                                   |   4%  |                                                                              |===                                                                   |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=======                                                               |   9%  |                                                                              |==================                                                    |  26%  |                                                                              |==============================                                        |  42%  |                                                                              |=========================================                             |  59%  |                                                                              |=====================================================                 |  76%  |                                                                              |=================================================================     |  92%  |                                                                              |======================================================================| 100%
#> Simple feature collection with 4488 features and 100 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -3115585 ymin: -1702303 xmax: 2263786 ymax: 1570639
#> Projected CRS: USA_Contiguous_Albers_Equal_Area_Conic
#> # A tibble: 4,488 × 101
#>    fips  state   `unemployed_15+_weeks` job_losers discouraged_workers
#>    <chr> <chr>                    <dbl>      <dbl>               <dbl>
#>  1 01    Alabama                  49300      63200                7200
#>  2 01    Alabama                  52200      61400                7300
#>  3 01    Alabama                  54900      61900                7600
#>  4 01    Alabama                  54400      63700                7500
#>  5 01    Alabama                  52000      57400                7600
#>  6 01    Alabama                  46500      52500                7600
#>  7 01    Alabama                  41300      48300                6700
#>  8 01    Alabama                  37300      39900                4500
#>  9 01    Alabama                  36200      36800                3000
#> 10 01    Alabama                  36800      39300                2900
#> # ℹ 4,478 more rows
#> # ℹ 96 more variables: all_marginally_attached <dbl>,
#> #   involuntary_part_time_employed <dbl>, civilian_labor_force <dbl>,
#> #   employed <dbl>, unemployed <dbl>, u1 <dbl>, u2 <dbl>, u3 <dbl>, u4 <dbl>,
#> #   u5 <dbl>, u6 <dbl>, date <date>, not_job_losers <dbl>,
#> #   unemployed_under_14_weeks <dbl>, losers_notlosers_ratio <dbl>, u1b <dbl>,
#> #   u2b <dbl>, u4b <dbl>, u4c <dbl>, …

# Get full diagnostic object if needed
data_with_diagnostics <- get_salt(return_diagnostics = TRUE)
#> Downloading SALT data from BLS...
#> Processing SALT Excel file...
print_bls_warnings(data_with_diagnostics)
#> No warnings forSALTdata download
# }
```
