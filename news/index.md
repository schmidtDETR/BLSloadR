# Changelog

## BLSloadR 0.3.0

### Major Enhancements

#### Enhanced CES Functions with Performance Filtering

- **[`get_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_ces.md)** -
  Major performance improvements with new filtering options:
  - `states` parameter: Download data for specific states only (90%+
    faster than full download)
  - `industry_filter` parameter: Focus on specific industries
    (retail_trade, manufacturing, etc.)
  - `current_year_only` parameter: Get only recent data (2006-present)
    instead of complete history
  - Mutually exclusive filtering prevents conflicting options
- **[`get_national_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_national_ces.md)** -
  New specialized dataset options for optimal performance:
  - `dataset_filter` parameter with 4 options: all_data,
    current_seasonally_adjusted, real_earnings_all_employees,
    real_earnings_production
  - Up to 95% faster downloads with specialized datasets
  - Enhanced documentation with performance notes
- **[`get_qcew()`](https://schmidtdetr.github.io/BLSloadR/reference/get_qcew.md)** -
  New function designed to access the Quarterly Census of Employment and
  Wages(QCEW):
  - Get quarterly or annual data for one year or multiple years.
  - Append area and industry definitions to the data.
  - QCEW represents highly detailed data across counties, combined
    areas, states and national regions.
  - Includes detailed employment and wage data.

#### New Helper Functions

- **CES Discovery Functions**:
  - [`list_ces_states()`](https://schmidtdetr.github.io/BLSloadR/reference/list_ces_states.md) -
    List available states for filtering
  - [`list_ces_industries()`](https://schmidtdetr.github.io/BLSloadR/reference/list_ces_industries.md) -
    List available industry filters with descriptions
  - [`show_ces_options()`](https://schmidtdetr.github.io/BLSloadR/reference/show_ces_options.md) -
    Comprehensive usage guide for CES options
- **National CES Discovery Functions**:
  - [`list_national_ces_options()`](https://schmidtdetr.github.io/BLSloadR/reference/list_national_ces_options.md) -
    List national dataset filter options
  - [`show_national_ces_options()`](https://schmidtdetr.github.io/BLSloadR/reference/show_national_ces_options.md) -
    Usage guide for national CES datasets
- **QCEW Lookup Tables included**:
  - `area_lookup` data table has details on QCEW area codes to
    pre-filter data requests.
  - `ind_lookup` data table has details on NAICS codes used in QCEW
    files.

#### Infrastructure Improvements

- Fixed URL parameter passing in
  [`download_bls_files()`](https://schmidtdetr.github.io/BLSloadR/reference/download_bls_files.md)
  (downloads\[\[‘key’\]\] vs downloads\$key)
- Consistent parameter naming across functions (`suppress_warnings`
  instead of mixed naming)
- Enhanced error handling and validation throughout
- Improved diagnostic messaging and user feedback

#### Documentation and Vignettes

- New comprehensive vignette: “Working with CES Data: Enhanced Features
  and Performance”
- New article on working with OEWS data.
- Updated main package vignette with enhanced CES capabilities
- Complete function documentation regeneration
- Performance comparison tables and best practices

### Breaking Changes

- Parameter `show_warnings` changed to `suppress_warnings` in
  [`get_national_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_national_ces.md)
  for consistency
- Enhanced parameter validation may catch previously ignored invalid
  inputs

## BLSloadR 0.2

CRAN release: 2025-11-25

- Initial CRAN release.
