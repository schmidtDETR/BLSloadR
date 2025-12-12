# Show CES Data Filtering Options

Displays a comprehensive overview of all filtering options available for
the \`get_ces()\` function, including states, industries, and usage
examples.

## Usage

``` r
show_ces_options()
```

## Examples

``` r
# See all filtering options
show_ces_options()
#> === BLS Current Employment Statistics (CES) Filtering Options ===
#> 
#> AVAILABLE STATES (53 total):
#>    AL, AK, AZ, AR, CA, CO, CT, DE, DC, FL 
#>    GA, HI, ID, IL, IN, IA, KS, KY, LA, ME 
#>    MD, MA, MI, MN, MS, MO, MT, NE, NV, NH 
#>    NJ, NM, NY, NC, ND, OH, OK, OR, PA, PR 
#>    RI, SC, SD, TN, TX, UT, VT, VA, VI, WA 
#>    WV, WI, WY 
#> 
#> AVAILABLE INDUSTRY FILTERS (24 total):
#>   current_year             : Recent data across all industries (2006-present)
#>   total_nonfarm            : Total non-farm employment (all industries, all years)
#>   total_nonfarm_statewide  : Total non-farm employment (statewide level)
#>   total_private            : Total private sector employment
#>   goods_producing          : Goods-producing industries
#>   service_providing        : Service-providing industries
#>   private_service_providing: Private service-providing industries
#>   mining_logging           : Mining and logging
#>   mining_logging_construction: Mining, logging, and construction
#>   construction             : Construction
#>   manufacturing            : Manufacturing
#>   durable_goods            : Durable goods manufacturing
#>   nondurable_goods         : Non-durable goods manufacturing
#>   trade_trans_utilities    : Trade, transportation, and utilities
#>   wholesale_trade          : Wholesale trade
#>   retail_trade             : Retail trade
#>   trans_utilities          : Transportation and utilities
#>   information              : Information services
#>   financial_activities     : Financial activities
#>   prof_business_services   : Professional and business services
#>   edu_health_services      : Education and health services
#>   leisure_hospitality      : Leisure and hospitality
#>   other_services           : Other services
#>   government               : Government
#> USAGE EXAMPLES:
#>   # Specific states (all industries, all years)
#>   ces_states <- get_ces(states = c('MA', 'NY', 'CT'))
#> 
#>   # Specific industry (all states, 2007-present)
#>   ces_manufacturing <- get_ces(industry_filter = 'manufacturing')
#> 
#>   # Current year data (all states and industries, 2006-present)
#>   ces_current <- get_ces(current_year_only = TRUE)
#> 
#>   # Complete dataset (all states, industries, and years - slowest)
#>   ces_all <- get_ces()
#> 
#> Performance: Filtering reduces download time by 50-90% vs. full dataset!
#> Note: Parameters are mutually exclusive - choose only one filtering option.
```
