# BLSloadR 0.2.0

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

### New Helper Functions

* **CES Discovery Functions**:
  - `list_ces_states()` - List available states for filtering
  - `list_ces_industries()` - List available industry filters with descriptions
  - `show_ces_options()` - Comprehensive usage guide for CES options

* **National CES Discovery Functions**:
  - `list_national_ces_options()` - List national dataset filter options
  - `show_national_ces_options()` - Usage guide for national CES datasets

### Infrastructure Improvements

* Fixed URL parameter passing in `download_bls_files()` (downloads[['key']] vs downloads$key)
* Consistent parameter naming across functions (`suppress_warnings` instead of mixed naming)
* Enhanced error handling and validation throughout
* Improved diagnostic messaging and user feedback

### Documentation and Vignettes

* New comprehensive vignette: "Working with CES Data: Enhanced Features and Performance"
* Updated main package vignette with enhanced CES capabilities
* Complete function documentation regeneration
* Performance comparison tables and best practices

## Breaking Changes

* Parameter `show_warnings` changed to `suppress_warnings` in `get_national_ces()` for consistency
* Enhanced parameter validation may catch previously ignored invalid inputs

# BLSloadR 0.1.5

* Initial CRAN submission.
