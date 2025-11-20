## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

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

## Changes made since last submission

- Added acronym definitions and broadly replaced BLS in DESCRIPTION with full agency title.
- Added URLs in angle brackets for individual programs (CES, LAUS, OEWS, SALT).
- Removed print.bls_data_collection function and associated Rd, as this was not used elsewhere in package.
- Changed dontrun to donttest in examples.  All package functionality is centered on downloading data from the BLS, so all examples are still wrapped in donttest because they download data.  However, users should not need any resources beyond this package to download data.
- Reviewed examples to ensure none include unexported functions.
- Removed comments from get_laus.Rd example code.  Removed examples due to size of download.
- Changed all print() or cat() calls to message() or warning().
- Changed default behavior to not dump as many messages to the console.
- Added Nevada Department of Employment, Training, and Rehabilitation to Authors in DESCRIPTION with role = 'cph'.  Package author (David Schmidt) developed code as an employee of the Department, so the Department properly owns the copyright.

