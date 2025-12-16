# BLSloadR 0.3.1 patch notes

## Function Enhancements
* `load_bls_dataset()`:
  - Added the `which_data` argument to this function, which allows use of this function in a pipeline without needing manual entry in the console for any BLS datasets which have exactly 1 series file and at most 1 aspect file.
  
## Documentation Enhancements
* Corrected typos for `get_salt()`



# BLSloadR 0.3.0

## Major Enhancements

### Enhanced CES Functions with Performance Filtering

* **`get_ces()`** - Major performance improvements with new filtering options:
  - `states` parameter: Download data for specific states only (90%+ faster than full download)
  - `industry_filter` parameter: Focus on specific industries (retail_trade, manufacturing, etc.)
  - `current_year_only` parameter: Get only recent data (2006-present) instead of complete history
  - Mutually exclusive filtering prevents conflicting options

* **`get_national_ces()`** - New specialized dataset options for optimal performance:
  - `dataset_filter` parameter with 4 options: all_data, current_seasonally_adjusted, real_earnings_all_employees, real_earnings_production
  - Up to 95% faster downloads with specialized datasets
  - Enhanced documentation with performance notes

* **`get_qcew()`** - New function designed to access the Quarterly Census of Employment and Wages(QCEW):
  - Get quarterly or annual data for one year or multiple years.
  - Append area and industry definitions to the data.
  - QCEW represents highly detailed data across counties, combined areas, states and national regions.
  - Includes detailed employment and wage data.

### New Helper Functions

* **CES Discovery Functions**:
  - `list_ces_states()` - List available states for filtering
  - `list_ces_industries()` - List available industry filters with descriptions
  - `show_ces_options()` - Comprehensive usage guide for CES options

* **National CES Discovery Functions**:
  - `list_national_ces_options()` - List national dataset filter options
  - `show_national_ces_options()` - Usage guide for national CES datasets

* **QCEW Lookup Tables included**:
  - `area_lookup` data table has details on QCEW area codes to pre-filter data requests.
  - `ind_lookup` data table has details on NAICS codes used in QCEW files.

### Infrastructure Improvements

* Fixed URL parameter passing in `download_bls_files()` (downloads[['key']] vs downloads$key)
* Consistent parameter naming across functions (`suppress_warnings` instead of mixed naming)
* Enhanced error handling and validation throughout
* Improved diagnostic messaging and user feedback

### Documentation and Vignettes

* New comprehensive vignette: "Working with CES Data: Enhanced Features and Performance"
* New article on working with OEWS data.
* Updated main package vignette with enhanced CES capabilities
* Complete function documentation regeneration
* Performance comparison tables and best practices

## Breaking Changes

* Parameter `show_warnings` changed to `suppress_warnings` in `get_national_ces()` for consistency
* Enhanced parameter validation may catch previously ignored invalid inputs

# BLSloadR 0.2

* Initial CRAN release.
