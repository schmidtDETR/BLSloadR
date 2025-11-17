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
  is the “SM” database. For more information about Current Employment
  Statistics, please visit <https://www.bls.gov/ces/>.

- [`get_national_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_national_ces.md) -
  This accesses national data from the CES program at the national
  level, which does not include state-level breakouts. This is the “CE”
  database.

- [`get_laus()`](https://schmidtdetr.github.io/BLSloadR/reference/get_laus.md) -
  This accesses data from the Local Area Unemployment Statistics (LAUS)
  program at a regional, state, and several sub-state levels. This is a
  localized version of the Current Population Survey (CPS) which is used
  to drive household-based estiamtes of employment and unemployment.
  This is the “LA” database. Note that because of the volume of data
  here, there are several different geographies that may be specified to
  pull the appropriate data file from BLS. For more information about
  Local Area Unemployment Statistics, please visit
  <https://www.bls.gov/lau/>.

- [`get_oews()`](https://schmidtdetr.github.io/BLSloadR/reference/get_oews.md) -
  This access the Occupational Employment and Wage Statistics (OEWS)
  data. This data provides survey-based estimates of employmen and wages
  by occupation at state and sub-state levels. This is the “OE”
  database. Note that only current-year data is available for OEWS in
  this database, as it is not built as a time series. For more
  information about Occupational Employment and Wage Statistics, please
  visit <https://www.bls.gov/oes/>.

- [`get_salt()`](https://schmidtdetr.github.io/BLSloadR/reference/get_salt.md) -
  This data is not actually loated within the time.series folder, but
  instead is sourced from <https://www.bls.gov/lau/stalt.htm>. These
  *Alternative Measures of Labor Underutilization for States* are
  12-month averages built from CPS data which provide more expansive or
  restrictive definitions of unemployment to measure the labor force,
  known as U1 through U6. This function also includes the optional
  geometry argument. If set to TRUE, this will use
  [`tigris::states()`](https://rdrr.io/pkg/tigris/man/states.html) and
  [`tigris::shift_geometry()`](https://rdrr.io/pkg/tigris/man/shift_geometry.html)
  to provide state polygons for convenient mapping of the output. For
  more information about the Alternative MEasures data, please visit
  <https://www.bls.gov/lau/stalt.htm>.

These optional helper functions can aid the user of this package by
providing ways to summarize and explore all the time.series databases.

- [`bls_overview()`](https://schmidtdetr.github.io/BLSloadR/reference/bls_overview.md) -
  this function utilizes the standard structure of the time.series
  databases, which has a simple text file explaining the database
  structure that always follows the structure *id.txt* where *id* is the
  two-character database identification code.

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
