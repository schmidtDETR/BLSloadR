# List Available Industry Filters for CES Data

Lists all available industry categories that can be used with the
\`industry_filter\` parameter in \`get_ces()\` function. These filters
allow you to download specific industry data instead of the complete
dataset.

## Usage

``` r
list_ces_industries(show_descriptions = FALSE)
```

## Arguments

- show_descriptions:

  Logical. If TRUE, returns a data frame with filter names and
  descriptions. If FALSE, returns just the filter names.

## Value

A character vector of industry filter names, or a data frame with names
and descriptions if show_descriptions = TRUE

## Examples

``` r
# See all available industry filters
list_ces_industries()
#>  [1] "current_year"                "total_nonfarm"              
#>  [3] "total_nonfarm_statewide"     "total_private"              
#>  [5] "goods_producing"             "service_providing"          
#>  [7] "private_service_providing"   "mining_logging"             
#>  [9] "mining_logging_construction" "construction"               
#> [11] "manufacturing"               "durable_goods"              
#> [13] "nondurable_goods"            "trade_trans_utilities"      
#> [15] "wholesale_trade"             "retail_trade"               
#> [17] "trans_utilities"             "information"                
#> [19] "financial_activities"        "prof_business_services"     
#> [21] "edu_health_services"         "leisure_hospitality"        
#> [23] "other_services"              "government"                 

# See filters with descriptions
list_ces_industries(show_descriptions = TRUE)
#>                         filter
#> 1                 current_year
#> 2                total_nonfarm
#> 3      total_nonfarm_statewide
#> 4                total_private
#> 5              goods_producing
#> 6            service_providing
#> 7    private_service_providing
#> 8               mining_logging
#> 9  mining_logging_construction
#> 10                construction
#> 11               manufacturing
#> 12               durable_goods
#> 13            nondurable_goods
#> 14       trade_trans_utilities
#> 15             wholesale_trade
#> 16                retail_trade
#> 17             trans_utilities
#> 18                 information
#> 19        financial_activities
#> 20      prof_business_services
#> 21         edu_health_services
#> 22         leisure_hospitality
#> 23              other_services
#> 24                  government
#>                                              description
#> 1       Recent data across all industries (2006-present)
#> 2  Total non-farm employment (all industries, all years)
#> 3            Total non-farm employment (statewide level)
#> 4                        Total private sector employment
#> 5                             Goods-producing industries
#> 6                           Service-providing industries
#> 7                   Private service-providing industries
#> 8                                     Mining and logging
#> 9                      Mining, logging, and construction
#> 10                                          Construction
#> 11                                         Manufacturing
#> 12                           Durable goods manufacturing
#> 13                       Non-durable goods manufacturing
#> 14                  Trade, transportation, and utilities
#> 15                                       Wholesale trade
#> 16                                          Retail trade
#> 17                          Transportation and utilities
#> 18                                  Information services
#> 19                                  Financial activities
#> 20                    Professional and business services
#> 21                         Education and health services
#> 22                               Leisure and hospitality
#> 23                                        Other services
#> 24                                            Government

# Use with get_ces
# manufacturing_data <- get_ces(industry_filter = "manufacturing")  # All states
```
