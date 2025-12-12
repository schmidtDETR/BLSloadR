# List Available National CES Dataset Options

This function displays the available dataset filtering options for the
get_national_ces() function, helping users understand what specialized
datasets are available for download.

## Usage

``` r
list_national_ces_options(show_descriptions = FALSE)
```

## Arguments

- show_descriptions:

  Logical. If TRUE, shows detailed descriptions of each dataset option.
  If FALSE (default), shows only the filter names.

## Value

A data frame with dataset filter options and their descriptions.

## Examples

``` r
# Show available dataset filters
list_national_ces_options()
#> [1] "all_data"                    "current_seasonally_adjusted"
#> [3] "real_earnings_all_employees" "real_earnings_production"   

# Show detailed descriptions
list_national_ces_options(show_descriptions = TRUE)
#>                        filter
#> 1                    all_data
#> 2 current_seasonally_adjusted
#> 3 real_earnings_all_employees
#> 4    real_earnings_production
#>                                                      description
#> 1    Complete national CES dataset - all series and full history
#> 2 Seasonally adjusted all-employee series only (faster download)
#> 3         Real earnings data (1982-84 dollars) for all employees
#> 4  Real earnings data (1982-84 dollars) for production employees
```
