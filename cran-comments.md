## R CMD check results

BLSloadR 0.2 ────
Duration: 5m 47.6s
0 errors ✔ | 0 warnings ✔ | 0 notes ✔
R CMD check succeeded

* New package (3rd submission attempt)

## Acronyms Used in Package

This package is designed to access data for specific programs at the United States Bureau of Labor Statistics.  Related acronyms appearing in the documentation are outlined below, as well as being defined in the documentation:

- BLS - The U.S. Bureau of Labor Statistics
- CES - Current Employment Statistics, a set of data produced by the BLS
- LAUS - Local Area Unemployment Statistics, a set of data produced by the BLS
- OEWS - Occupational Employment and Wage Statistics, a set of data produced by the BLS
- SALT - State Alternative Measures of Labor Underutilization, a set of data produced by the BLS
- NAICS - North American Industrial Classification System
- IC - Initial Claims for Unemployment Insurance
- SA - Seasonally Adjusted
- NSA - Not Seasonally Adjusted
- FIPS - Federal Information Processing Standards, used to refer to geographic codes for states and sub-state areas. (e.g. "The FIPS code for the state of Nevada is 32".)

## Changes made since last submission attempt

- Added acronym definitions and broadly replaced BLS in DESCRIPTION with full agency title.
- Added URLs in angle brackets for individual programs (CES, LAUS, OEWS, SALT).
- Removed print.bls_data_collection function and associated Rd, as this was not used elsewhere in package.
- Generally changed dontrun to donttest in examples.  All package functionality is centered on downloading data from the BLS, so all examples are still wrapped in donttest because they download data.  However, users should not need any resources beyond this package to download data.
- Put examples for `load_bls_dataset()` back in \dontrun because they require manual input during loading process to select from multiple data files (most BLS series appear to have at a minimum a "Current" and an "All" data file, even when the contents are the same).
- Reviewed examples to ensure none include unexported functions.
- Removed comments from get_laus.Rd example code.  Removed examples due to size of download.
- Changed all print() or cat() calls to message() or warning().
- Changed default behavior to not dump as many messages to the console.
- Added Nevada Department of Employment, Training, and Rehabilitation to Authors in DESCRIPTION with role = 'cph'.  Package author (David Schmidt) developed code as an employee of the Department, so the Department properly owns the copyright.
- Corrected errors in examples and successfully ran code through multiple-OS checks in Github Actions for R CMD CHECK (ubuntu, macos, windows).

Full local test took 5 minutes due to the downloads in \donttest examples.