## R CMD check results

BLSloadR 0.4 ────
Duration: 5m 0.4s
0 errors ✔ | 0 warnings ✔ | 0 notes ✔

R CMD check succeeded

## Acronyms Used in Package

This package is designed to access data for specific programs at the United States Bureau of Labor Statistics.  Related acronyms appearing in the documentation are outlined below, as well as being defined in the documentation:

- BLS - The U.S. Bureau of Labor Statistics
- CES - Current Employment Statistics, a set of data produced by the BLS
- LAUS - Local Area Unemployment Statistics, a set of data produced by the BLS
- OEWS - Occupational Employment and Wage Statistics, a set of data produced by the BLS
- SALT - State Alternative Measures of Labor Underutilization, a set of data produced by the BLS
- QCEW - Quarterly Census of Employmnt and Wages, a set of data produced by the BLS
- NAICS - North American Industrial Classification System
- IC - Initial Claims for Unemployment Insurance
- SA - Seasonally Adjusted
- NSA - Not Seasonally Adjusted
- FIPS - Federal Information Processing Standards, used to refer to geographic codes for states and sub-state areas. (e.g. "The FIPS code for the state of Nevada is 32".)

## Package Updates

### Major changes made since initial package version

- Implemented changes to `get_ces()` to allow for utilizing subsets of the full data table to improve speed.
- Implemented `get_qcew()` function to access another BLS data source.
- Implemented file caching option to reduce bandwidth usage. Default behavior remains unchanges (always download from BLS).
- Added additional vignette to explain usage of two environment variables that can be used in conjunction with file caching.
- Added two lookup tables in data folder for access to industry and area definition codes.

Full local test took 5 minutes due to file downloads in \donttest examples.
