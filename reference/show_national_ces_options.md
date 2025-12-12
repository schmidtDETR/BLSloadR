# Show National CES Dataset Options and Usage Examples

This function provides a comprehensive overview of the national CES
dataset filtering options available in get_national_ces(), including
examples of how to use each option.

## Usage

``` r
show_national_ces_options()
```

## Value

Prints formatted information to the console.

## Examples

``` r
show_national_ces_options()
#> === BLS National Current Employment Statistics (CES) Dataset Options ===
#> 
#> AVAILABLE DATASETS (4 options):
#>    all_data :  Complete national CES dataset - all series and full history 
#>    current_seasonally_adjusted :  Seasonally adjusted all-employee series only (faster download) 
#>    real_earnings_all_employees :  Real earnings data (1982-84 dollars) for all employees 
#>    real_earnings_production :  Real earnings data (1982-84 dollars) for production employees 
#> 
#> USAGE EXAMPLES:
#>   # Complete dataset (largest file, ~340MB)
#>   ces_complete <- get_national_ces(dataset_filter = 'all_data')
#> 
#>   # Seasonally adjusted data only (faster download)
#>   ces_seasonal <- get_national_ces(dataset_filter = 'current_seasonally_adjusted')
#> 
#>   # Real earnings for all employees
#>   ces_earnings_all <- get_national_ces(dataset_filter = 'real_earnings_all_employees')
#> 
#>   # Real earnings for production employees
#>   ces_earnings_prod <- get_national_ces(dataset_filter = 'real_earnings_production')
#> 
#> Performance: Specialized datasets reduce download time significantly!
#> Note: All options include metadata files for context and labels.
```
