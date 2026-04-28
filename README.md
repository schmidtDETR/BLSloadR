# BLSloadR
Functions for downloading BLS flat files into R

# Overview
BLSloadR is a packages designed to streamline access to the time series database downloads from the U.S. Bureau of Labor Statistics, made available at https://download.bls.gov/pub/time.series/. It is focused on accessing series that are frequently used by states to get state-level estimates, but includes the `load_bls_dataset()` and `bls_overview()` functions to provide generalized access to the other databases at this website within an R environment.

# Basic Usage
BLSloadR can be installed from CRAN by running `install.packages("BLSloadR")`. The development version can be found on Github at https://github.com/schmidtDETR/BLSloadR. 

The primary functions in this package all begin with get_ and are listed below:

-`get_ces()` - This accesses data from the Current Employment Statistics (CES) program at the state and metropolitan area levels. This provides employer-based estimates of employment, wages, and hours worked. This is the "SM" database. **Includes enhanced filtering options** for specific `states`, `industry_filter`, or `current_year_only` data that dramatically improve download speed and reduce memory usage.

-`get_national_ces()` - This accesses national data from the CES program at the national level, which does not include state-level breakouts. This is the "CE" database. **Includes `dataset_filter` option** for seasonally adjusted series, real earnings data, and current year data.

-`get_laus()` - This accesses data from the Local Area Unemployment Statistics (LAUS) program at a regional, state, and several sub-state levels. This is a localized version of the Current Population Survey (CPS) which is used to drive household-based estiamtes of employment and unemployment. This is the "LA" database. Note that because of the volume of data here, there are several different geographies that may be specified to pull the appropriate data file from BLS.

-`get_oews()` - This access the Occupational Employment and Wage Statistics (OEWS) data. This data provides survey-based estimates of employmen and wages by occupation at state and sub-state levels. This is the "OE" database. Note that only current-year data is available for OEWS in this database, as it is not built as a time series.

-`get_salt()` - This data is not actually located within the time.series folder, but instead is sourced from https://www.bls.gov/lau/stalt.htm. These Alternative Measures of Labor Underutilization for States are 12-month averages built from CPS data which provide more expansive or restrictive definitions of unemployment to measure the labor force, known as U1 through U6. This function also includes the optional geometry argument. If set to TRUE, this will use `tigris::states()` and `tigris::shift_geometry()` to provide state polygons for convenient mapping of the output.

-`get_jolts()` - This accesses data from the Job Openings and Labor Turnover Survey (JOLTS) which has both national and state data.  NOTE: Beginning in 2026, the BLS will discontinue publishing state JOLTS data on a monthly basis, moving to an annual release of data. This function will still pull data, but the frequency of state data will change. This is the "JT" database.

-`get_qcew()` - This accesses data from the Quarterly Census of Employment and Wages (QCEW).  This is a very large data set, so access is filtered by area or industry.  This function iterates requesting single-quarter files via the BLS QCEW Data Slices tool at https://www.bls.gov/cew/additional-resources/open-data/csv-data-slices.htm.  This function was included beginning in version 0.3.1.

-`get_cps_subset()` - This accesses data from the National Current Population Survey (CPS) which determines the national unemployment rate.  Several demographic details are available here which are not available at the state or local levels.  This is the "LN" database. This function was introduced in BLSloadR version 0.5.

# Configuring Your User Profile
BLSloadR will typically work by default without any cusomization.  However, there are some options you can use that may improve your experience.  These options are managed with *environment variables* in your R session that enable the following:

-`BLS_USER_AGENT` - setting this environment variable to your e-mail address will use your e-mail address when downloading data from the BLS. In case of errors with your downloads, this may help the BLS to identify you as an individual user. Setting this environment variable to a character string passes that character string to the BLS as the User-Agent HTML header.

-`USE_BLS_CACHE` - Setting this environment variable to "TRUE" will enable a local file cache of your BLS downloads which will download new files for supported functions only when the underlying data has changed.

-`BLS_CACHE_DIR` - If you want to use the file cache, you may wish to specify a location.  Setting this environment variable will specify a different path for the file cache than the default.

To permanently set these environment variables, you can edit your .Renviron file (such as with `usethis::edit_r_environ()`). To do so for a single session, you can set your environment variables with `Sys.setenv(USE_BLS_CACHE="TRUE")`.

# Enhanced CES Filtering for Performance

The `get_ces()` and `get_national_ces()` functions now include powerful filtering options that significantly improve performance:

## CES State and Industry Filtering
`get_ces()` supports three filtering parameters that can be used individually or in combination:
- `states = c("MA", "CT", "RI")` - Download only specific states, reducing download time by up to 90%
- `industry_filter = "manufacturing"` - Focus on specific industries
- `current_year_only = TRUE` - Download only recent data (2006-present) instead of the complete historical archive

**Performance Impact:**
- Complete CES download: 60+ seconds (~5.6M rows)
- Single state download: ~3.5 seconds (~200K rows)
- With current_year_only: Significantly faster for combined filters

## National CES Dataset Options
`get_national_ces()` includes the `dataset_filter` parameter for selecting specialized datasets:
- `"all_data"` - Complete dataset with all series
- `"current_seasonally_adjusted"` - Seasonally adjusted series only (~392K rows, ~3.7 seconds)
- `"real_earnings_all_employees"` - Real earnings data for all employees
- `"real_earnings_production"` - Real earnings data for production employees

## Helper Functions for CES Data
Discovery functions help identify available filtering options:
- `list_ces_states()` - Lists available states and territories
- `list_ces_industries()` - Lists available industry filters
- `show_ces_options()` - Shows comprehensive CES filtering options
- `list_national_ces_options()` - Lists national CES dataset options
- `show_national_ces_options()` - Shows detailed national CES options

# General BLS Time Series Functions
These optional helper functions can aid the user of this package by providing ways to summarize and explore all the time.series databases. These functions are a bit different than the specific functions above, as they implement a general way to merge and import BLS time.series databases, but do not manually specify the data, series, and lookup files to be joined.  As such, they return a bls_data_collection object which includes the joined data as well as diagnostic results including dropped columns, unexpected join results, and other tools to help review the data before use.  Further, when multiple data or series files are present, the user is prompted to choose one, so these tools are not suitable for a typical piped script.

`bls_overview()` - this function utilizes the standard structure of the time.series databases, which has a simple text file explaining the database structure that always follows the structure id.txt where id is the two-character database identification code.

`load_bls_dataset()` - this function attempts to read and join all the relevant files in a BLS database, and will sometimes prompt the user for additional input. For example, many databases have multiple data files available (such as “AllItems” and “Current”) and may have old series files as well (to manage historical coding changes). Because these joins are performed automatically, the object returned by this function is a more robust diagnostic object included the joined data table as well as information about the joins. Use Caution! BLS data structures are not always consistent. There may be anomalies in the structure of individual databases, such as missing column headers, that will degrade the ability of this function to read the data.

<!-- badges: start -->
  [![R-CMD-check](https://github.com/schmidtDETR/BLSloadR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/schmidtDETR/BLSloadR/actions/workflows/R-CMD-check.yaml)
  <!-- badges: end -->
