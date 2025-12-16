# Introduction to BLSloadR

``` r
library(BLSloadR)
```

## Overview

**BLSloadR** is a packages designed to streamline access to the time
series database downloads from the U.S. Bureau of Labor Statistics
(<https://www.bls.gov/>), made available as flat files
(<https://download.bls.gov/pub/time.series/>). It is focused on
accessing series that are frequently used by states to get state-level
estimates, but includes the
[`load_bls_dataset()`](https://schmidtdetr.github.io/BLSloadR/reference/load_bls_dataset.md)
function to provide generalized access to the other databases at this
website.

## Basic Usage

The primary functions in this package all begin with get\_ and are
listed below:

- [`get_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_ces.md) -
  This accesses data from the Current Employment Statistics (CES)
  program at the state and metropolitan area levels. This provides
  employer-based estimates of employment, wages, and hours worked. This
  is the “SM” database. **Enhanced with filtering options** for specific
  states, industries, or current year data to significantly improve
  download performance. For more information about Current Employment
  Statistics, please visit <https://www.bls.gov/ces/>.

- [`get_national_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_national_ces.md) -
  This accesses national data from the CES program at the national
  level, which does not include state-level breakouts. This is the “CE”
  database. **Enhanced with specialized dataset options** including
  seasonally adjusted series, real earnings data, and complete
  historical data for optimal performance.

- [`get_laus()`](https://schmidtdetr.github.io/BLSloadR/reference/get_laus.md) -
  This accesses data from the Local Area Unemployment Statistics (LAUS)
  program at a regional, state, and several sub-state levels. This is a
  localized version of the Current Population Survey (CPS) which is used
  to drive household-based estimates of employment and unemployment.
  This is the “LA” database. Note that because of the volume of data
  here, there are several different geographies that may be specified to
  pull the appropriate data file from BLS. For more information about
  Local Area Unemployment Statistics, please visit
  <https://www.bls.gov/lau/>.

- [`get_oews()`](https://schmidtdetr.github.io/BLSloadR/reference/get_oews.md) -
  This access the Occupational Employment and Wage Statistics (OEWS)
  data. This data provides survey-based estimates of employment and
  wages by occupation at state and sub-state levels. This is the “OE”
  database. Note that only current-year data is available for OEWS in
  this database, as it is not built as a time series. For more
  information about Occupational Employment and Wage Statistics, please
  visit <https://www.bls.gov/oes/>.

- [`get_salt()`](https://schmidtdetr.github.io/BLSloadR/reference/get_salt.md) -
  This data is not actually located within the time.series folder, but
  instead is sourced from <https://www.bls.gov/lau/stalt.htm>. These
  *Alternative Measures of Labor Underutilization for States* are
  12-month averages built from CPS data which provide more expansive or
  restrictive definitions of unemployment to measure the labor force,
  known as U1 through U6. This function also includes the optional
  geometry argument. If set to TRUE, this will use
  [`tigris::states()`](https://rdrr.io/pkg/tigris/man/states.html) and
  [`tigris::shift_geometry()`](https://rdrr.io/pkg/tigris/man/shift_geometry.html)
  to provide state polygons for convenient mapping of the output. For
  more information about the Alternative Measures data, please visit
  <https://www.bls.gov/lau/stalt.htm>.

These functions download a series of files in the time.series database
from BLS, join those files together, and then perform some simple
filtering and streamlining to prepare the data for time series analysis.
Generally speaking, these functions may be used with only the default
parameters to get a table formatted and ready to be analyzed. To reduce
the filtering and summaries performed by these functions, a series of
arguments may beset to retain the data closer to its original format.

## Common Function Arguments

Within the functions to retrieve specific data sets there are a few
common arguments which exist to simplify the results and minimize
subsequent filtering.

- `transform = TRUE` - This argument is used in
  [`get_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_ces.md)
  and
  [`get_laus()`](https://schmidtdetr.github.io/BLSloadR/reference/get_laus.md).
  It is used to convert the data as provided by BLS to numbers and
  ratios that are easier to work with and manipulate. In particular is
  converts any ratios and rates from a whole-number format to a decimal
  format. For example, a labor for participation rate of 65.3% is
  represented in the BLS data as 65.3. Using `transform = TRUE` will
  convert this to 0.653 so that it may be used as a ratio, or displayed
  as a percent format in R. This argument will also convert numbers that
  are represented as “in thousands” into whole numbers. For example, in
  the CES data, employment of 1,234,500 is represented as 1234.5. While
  this conveys the appropriate significant figures for the estimate, it
  can be inconvenient to work with across programs. Using
  `transform = TRUE` will change this to 1,234,500 and remove “in
  Thousands” from the data description column.
- `monthly_only = TRUE` - This argument is used in
  [`get_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_ces.md),
  [`get_national_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_national_ces.md),
  and
  [`get_laus()`](https://schmidtdetr.github.io/BLSloadR/reference/get_laus.md).
  It removes annual data from the downloaded BLS data, typically
  represented as `period = "M13"` to make the data a more consistent
  time series.
- `simplify_table = TRUE` - This argument is used in
  [`get_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_ces.md)
  and
  [`get_national_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_national_ces.md).
  It is used to remove some columns that are not commonly helpful in
  working with the BLS data. For
  [`get_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_ces.md)
  these columns are `benchmark_year`, `begin_year`, `begin_period`,
  `end_year`, and `end_period` which all describe the vintage of the
  data which was downloaded. For
  [`get_national_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_national_ces.md)
  the columns are `series_title`, `begin_year`, `begin_period`,
  `end_year`, `end_period`, `naics_code`, `publishing_status`,
  `display_level`, `selectable`, and `sort_sequence`. These columns
  either contain codes with no explanation, provide duplicated but
  inconsistently formatted information, or describe the vintage of the
  data. For both functions, this argument also takes the `year` and
  `period` columns, transforms them into a single date column, and
  removes these two columns.
- `suppress_warnings = TRUE` - This argument is used in most functions
  to control the display of download warnings and diagnostic
  information. Setting to `FALSE` provides detailed feedback about the
  download process.

## Enhanced Filtering Arguments (CES Functions)

The CES functions include several powerful filtering options for
improved performance:

### `get_ces()` Filtering Options

- `states` - Vector of state abbreviations (e.g., `c("MA", "CT", "RI")`)
  to download only specific states
- `industry_filter` - Single industry filter option (e.g.,
  `"retail_trade"`, `"manufacturing"`) to focus on specific sectors
- `current_year_only = FALSE` - Set to `TRUE` to download only recent
  data (2006-present) instead of complete history

### `get_national_ces()` Dataset Options

- `dataset_filter` - Choose specialized national datasets:
  - `"all_data"` (default) - Complete dataset with all series
  - `"current_seasonally_adjusted"` - Only seasonally adjusted series
    (faster)
  - `"real_earnings_all_employees"` - Real earnings data for all
    employees
  - `"real_earnings_production"` - Real earnings data for production
    employees

**Note**: These filtering options are mutually exclusive within each
function - you cannot combine multiple filter types in a single function
call.

## Helper Functions for Enhanced CES Access

The package includes several helper functions to assist with the
enhanced CES filtering capabilities:

### CES Helper Functions

- [`list_ces_states()`](https://schmidtdetr.github.io/BLSloadR/reference/list_ces_states.md) -
  Lists all available states and territories for state-level CES data
  filtering
- [`list_ces_industries()`](https://schmidtdetr.github.io/BLSloadR/reference/list_ces_industries.md) -
  Lists available industry filtering options with optional descriptions
- [`show_ces_options()`](https://schmidtdetr.github.io/BLSloadR/reference/show_ces_options.md) -
  Provides a comprehensive overview of all CES filtering options with
  usage examples

### National CES Helper Functions

- [`list_national_ces_options()`](https://schmidtdetr.github.io/BLSloadR/reference/list_national_ces_options.md) -
  Lists available dataset filtering options for national CES data
- [`show_national_ces_options()`](https://schmidtdetr.github.io/BLSloadR/reference/show_national_ces_options.md) -
  Shows detailed information about national CES dataset options with
  performance notes

These helper functions make it easy to discover what filtering options
are available before downloading data, helping you choose the most
efficient approach for your analysis.

## Performance Improvements

The enhanced CES functions provide significant performance improvements:

- **State filtering**: Download only specific states instead of all 50+
  states (up to 90% faster)
- **Industry filtering**: Focus on specific industries like retail,
  manufacturing, or construction
- **Current year option**: Get only recent data (2006-present) instead
  of complete historical series
- **National datasets**: Choose specialized national datasets
  (seasonally adjusted, real earnings) for faster downloads

For example: - Complete CES download: 60+ seconds for ~5.6M rows -
Single state (MA): ~3.5 seconds for ~210K rows - Seasonally adjusted
national: ~3.7 seconds for ~392K rows

## Helper Functions in the Package

This package relies on a custom function,
[`fread_bls()`](https://schmidtdetr.github.io/BLSloadR/reference/fread_bls.md)
which aids in downloading and reading text files from the BLS.
Ordinarily, attempting to read files from the BLS directly from R will
return a 403 error, even though these files may be accessed easily from
a web browser. This package adds HTML headers to the GET requests to the
BLS web page to enable file downloads, checks the format of the files,
and reads in the contents. The functions above pull specific files from
the associated databases. The functions below, in contrast, are designed
to enable the user to

These optional helper functions can aid the user of this package by
providing ways to summarize and explore all the time.series databases.
The full list of databases as of November 2025 is listed at the end of
this document.

- [`bls_overview()`](https://schmidtdetr.github.io/BLSloadR/reference/bls_overview.md) -
  this function utilizes the standard structure of the time.series
  databases, which has a simple text file explaining the database
  structure that always follows the structure *id.txt* where *id* is the
  two-character database identification code. This function will render
  this summary file as a simple HTML file.

- [`load_bls_dataset()`](https://schmidtdetr.github.io/BLSloadR/reference/load_bls_dataset.md) -
  this function attempts to read and join all the relevant files in a
  BLS database, and will sometimes prompt the user for additional input.
  For example, many databases have multiple data files available (such
  as “AllItems” and “Current”) and may have old series files as well (to
  manage historical coding changes). Because these joins are performed
  automatically, the object returned by this function is a more robust
  diagnostic object included the joined data table as well as
  information about the joins. **Use Caution!** BLS data structures are
  not always consistent. There may be anomalies in the structure of
  individual databases, such as missing column headers, that will
  degrade the ability of this function to read the data.

## Additional Diagnostics

Within each of the core functions is an argument that allows you to
receive more robust diagnostic information about the loading process.
setting `return_diagnostics = TRUE` will return a bls_data_collection
object, which can be used to get more information about the loading
process. For
[`load_bls_dataset()`](https://schmidtdetr.github.io/BLSloadR/reference/load_bls_dataset.md)
you should set `return_full = TRUE`.

## Disclaimer

This package was not created,endorsed, or maintained by the U.S. Bureau
of Labor Statistics. It exists to make accessing that data easier and
more streamlined using websites that are already publicly available.

## List of Databases

The current list of databases in the time.series folder as of November
2025 is listed below. Please note, not all series have current data
available. Additional information about a series may be gained by
running the
[`bls_overview()`](https://schmidtdetr.github.io/BLSloadR/reference/bls_overview.md)
function for a selected series, such as `bls_overview("ap")`.

- ap - Average Price Data
- bd - Business Employment Dynamics
- bg - Collective Bargaining-State and Local Government
- bp - Collective Bargaining-Private Sector
- cc - Employer Costs for Employee Compensation (SIC 1986-2003)
- cd - Occupational Injuries and Illness - Characteristics Data (SIC)
- ce - Employment, Hours, and Earnings-National (NAICS)
- cf - Census of Fatal Occupational Injuries (1992-2002)
- ch - Nonfatal cases involving days away from work: selected
  charachteristics
- ci - Employment Cost Index (NAICS)
- cm - Employer Costs for Employee Compensation (NAICS)
- cs - Occupational Injuries and Illnesses - Characteristics Data
- cu - Consumer Price Index-All Urban Consumers (Current Series)
- cw - Consumer Price Index-Urban Wage Earners and Clerical Workers
- cx - Consumer Expenditure Survey
- eb - Employee Benefits Survey (1979 - 2006)
- ec - Employment Cost Index (SIC 1975 - 2005)
- ee - Employment, Hours, and Earnings-National (SIC)
- ei - International Price Index
- fi - Census of Fatal Occupational Injuries
- fm - Marital and Family Labor Force Statistics
- fw - Census of Fatal Occupational Injuries
- gg - Green Goods and Services
- gp - Geographic Profile
- hc - Occupational Injuries and Illness - Characteristics Data (NAICS)
- hs - Occupational Injury and Illness Rates (based on 1972 SIC codes)
- ii - Occupational Injuries and Illnesses Industry Data
- in - International Labor Statistics
- ip - Industry Productivity and Costs
- jl - Job Openings and Labor Turnover Survey (SIC)
- jt - Job Openings and Labor Turnover Survey (NAICS)
- la - Local Area Unemployment Statistics
- le - Weekly and Hourly Earnings Data from the Current Population
- li - Department Store Inventory Price Index
- ln - Labor Force Statistics from the Current Population Survey (NAICS)
- lu - Union Affiliation Data from the Current Population Survey
- ml - Mass Layoff Statistics
- mp - Major Sector Multifactor Productivity Index
- mu - Consumer Price Index-All Urban Consumers (Old Series)
- mw - Consumer Price Index-Urban Wage Earners and Clerical Workers
- nb - National Compensation Survey
- nc - National Compensation Survey (SIC 1997-2006)
- nd - Producer Price Index Revision-Discontinued Series (NAICS)
- nl - National Longitudinal Survey
- nw - National Compensation Survey (NAICS)
- oe - Occupation Employment Statistics
- or - Occupational Requirements Survey
- pc - Producer Price Index Revision-Current Series
- pd - Producer Price Index Revision-Discontinued Series (SIC)
- pr - Major Sector Productivity and Costs Index
- sa - State and Area Employment, Hours, and Earnings (SIC)
- sh - Occupational Injury and Illness Rates (based on 1987 SIC codes)
- si - Occupational Injury and Illness Rates (2002 data)
- sm - State and Area Employment, Hours, and Earnings (NAICS)
- su - Chained CPI-All Urban Consumers
- wd - Producer Price Index Commodity - Discontinued Series
- wm - Modeled Wage Estimates
- wp - Producer Price Index - Commodities
- ws - Work Stoppage Data
