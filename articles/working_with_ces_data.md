# Working with CES Data: Enhanced Features and Performance

``` r
library(dplyr)
library(tidyr)
library(ggplot2)
library(BLSloadR)
```

## Enhanced CES Functions Overview

The `BLSloadR` package provides two main functions for accessing Current
Employment Statistics (CES) data from the Bureau of Labor Statistics:

- [`get_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_ces.md) -
  State and metropolitan area CES data
- [`get_national_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_national_ces.md) -
  National CES data

Both functions have been enhanced with powerful filtering options to
significantly improve download performance and provide more targeted
data access.

## Helper Functions for Discovery

Before diving into data downloads, you can explore available options
using helper functions:

``` r
# Explore state-level CES options
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

``` r
# Explore national CES options
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

## State-Level CES Data with `get_ces()`

### Basic Usage

The simplest way to get state CES data is with default settings:

``` r
# Get all available state CES data (this can be quite large!)
ces_all <- get_ces()
```

### Performance-Optimized Options

For much faster downloads, use the filtering options:

``` r
# Get data for specific states only (much faster!)
ces_northeast <- get_ces(
  states = c("MA", "CT", "RI", "NH", "VT", "ME"),
  suppress_warnings = FALSE
)

print(paste("Downloaded", nrow(ces_northeast), "rows"))
#> [1] "Downloaded 647766 rows"
print(paste("Unique states:", length(unique(ces_northeast$area_text))))
#> [1] "Unique states: 0"
```

``` r
# Get data for specific industries only
ces_retail <- get_ces(
  industry_filter = "retail_trade",
  suppress_warnings = FALSE
)

print(paste("Downloaded", nrow(ces_retail), "rows"))
#> [1] "Downloaded 318249 rows"
print("Available industries in this dataset:")
#> [1] "Available industries in this dataset:"
print(head(unique(ces_retail$industry_text), 10))
#> NULL
```

### Current Year Data

For the most recent data only:

``` r
# Get recent data (2006 to present)
ces_current <- get_ces(
  current_year_only = TRUE,
  suppress_warnings = FALSE
)

print(paste("Date range:", min(ces_current$date), "to", max(ces_current$date)))
#> [1] "Date range: 2006-01-01 to 2025-09-01"
print(paste("Dataset size:", nrow(ces_current), "rows"))
#> [1] "Dataset size: 5607093 rows"
```

## National CES Data with `get_national_ces()`

### Specialized Dataset Options

The national CES function offers four specialized datasets for optimal
performance:

``` r
# Get seasonally adjusted data only (fastest download)
ces_seasonal <- get_national_ces(
  dataset_filter = "current_seasonally_adjusted",
  suppress_warnings = FALSE
)

print(paste("Seasonally adjusted data:", nrow(ces_seasonal), "rows"))
#> [1] "Seasonally adjusted data: 393937 rows"
```

``` r
# Get real earnings data for all employees
ces_earnings <- get_national_ces(
  dataset_filter = "real_earnings_all_employees",
  suppress_warnings = FALSE
)

print(paste("Real earnings data:", nrow(ces_earnings), "rows"))
#> [1] "Real earnings data: 518256 rows"
print("Sample of data types included:")
#> [1] "Sample of data types included:"
print(head(unique(ces_earnings$data_type_text), 5))
#> [1] "AVERAGE WEEKLY EARNINGS OF ALL EMPLOYEES, 1982-1984 DOLLARS"
#> [2] "AVERAGE HOURLY EARNINGS OF ALL EMPLOYEES, 1982-1984 DOLLARS"
```

### Working with National Data

Let’s create a simple analysis using the national data:

``` r
# Get recent employment data
recent_employment <- ces_seasonal |>
  filter(
    data_type_text == "All employees, thousands, seasonally adjusted",
    supersector_name %in% c("Total nonfarm", "Manufacturing", "Construction",
                           "Professional and business services", "Government"),
    date >= as.Date("2020-01-01")
  ) |>
  select(date, supersector_name, value)

# Plot employment trends
recent_employment |>
  ggplot(aes(x = date, y = value, color = supersector_name)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Employment Trends by Supersector (2020-Present)",
    subtitle = "Seasonally Adjusted Employment (thousands)",
    x = "Date",
    y = "Employment (thousands)",
    color = "Supersector"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    legend.title = element_text(size = 10),
    plot.title = element_text(size = 14, face = "bold")
  ) +
  guides(color = guide_legend(nrow = 2))
```

![](working_with_ces_data_files/figure-html/national-analysis-1.png)

## Performance Comparison

The enhanced filtering options provide significant performance
improvements:

| Download.Option                | Typical.Size   | Download.Time | Use.Case                     |
|:-------------------------------|:---------------|:--------------|:-----------------------------|
| All CES data (50+ states)      | ~5.6M rows     | 60+ seconds   | Comprehensive analysis       |
| Single state (MA)              | ~210K rows     | 3.5 seconds   | State-specific research      |
| Multiple states (6 states)     | ~608K rows     | 9.8 seconds   | Regional analysis            |
| Single industry (Retail)       | ~317K rows     | 5.2 seconds   | Industry focus               |
| Current year only              | ~5.6M rows     | 64+ seconds   | Recent trends only           |
| National - Complete dataset    | Large (~340MB) | 60+ seconds   | Complete historical analysis |
| National - Seasonally adjusted | ~392K rows     | 3.7 seconds   | Quick national overview      |
| National - Real earnings       | ~514K rows     | 4.5 seconds   | Wage/earnings analysis       |

Performance Comparison of CES Download Options

## Best Practices

### 1. Start Small

Always start with filtered data to prototype your analysis:

``` r
# Start with a small subset
test_data <- get_ces(states = "MA")

# Develop your analysis code
my_analysis <- test_data |>
  filter(data_type_text == "All employees, thousands, seasonally adjusted") |>
  # ... your analysis code ...

# Then scale up if needed
full_data <- get_ces(states = c("MA", "CT", "RI", "NH", "VT", "ME"))
```

### 2. Use Helper Functions

Discover available options before downloading:

``` r
# See what states are available
available_states <- list_ces_states()

# See what industries you can filter by
available_industries <- list_ces_industries(show_descriptions = TRUE)
```

### 3. Choose the Right Dataset

Select the most appropriate dataset for your needs:

``` r
# For quick national employment trends
quick_national <- get_national_ces(dataset_filter = "current_seasonally_adjusted")

# For wage analysis
wage_data <- get_national_ces(dataset_filter = "real_earnings_all_employees")

# For state comparisons
state_data <- get_ces(states = c("CA", "TX", "NY", "FL"))
```

### 4. Handle Large Downloads Carefully

If you must download large datasets:

``` r
# Use return_diagnostics to monitor the download
large_data <- get_ces(
  current_year_only = TRUE,
  return_diagnostics = TRUE,
  suppress_warnings = FALSE
)

# Check for any issues
print_bls_warnings(large_data)

# Extract the data
final_data <- get_bls_data(large_data)
```

## Advanced Features

### Maintaining Full Metadata

Keep all BLS metadata columns for detailed analysis:

``` r
detailed_data <- get_ces(
  states = "MA",
  simplify_table = FALSE  # Keeps all metadata columns
)
```

### Including Annual Averages

Include annual average data (M13 period):

``` r
with_annual <- get_national_ces(
  monthly_only = FALSE  # Includes annual averages
)
```

### Raw Data Access

Get data without transformations:

``` r
raw_data <- get_ces(
  states = "MA",
  transform = FALSE  # No ratio/thousands conversions
)
```

## Conclusion

The enhanced
[`get_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_ces.md)
and
[`get_national_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_national_ces.md)
functions provide:

- **90%+ reduction** in download times through smart filtering
- **Flexible options** for states, industries, and time periods
- **Consistent API** design across both functions
- **Helper functions** for easy discovery of available options
- **Comprehensive documentation** and examples

These improvements make BLS employment data more accessible and
practical for routine analysis while maintaining the full power and
flexibility needed for comprehensive research.
