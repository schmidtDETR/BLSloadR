# BLSloadR

Functions for downloading BLS flat files into R

# Overview

BLSloadR is a packages designed to streamline access to the time series
database downloads from the U.S. Bureau of Labor Statistics, made
available at <https://download.bls.gov/pub/time.series/>. It is focused
on accessing series that are frequently used by states to get
state-level estimates, but includes the
[`load_bls_dataset()`](https://schmidtdetr.github.io/BLSloadR/reference/load_bls_dataset.md)
and
[`bls_overview()`](https://schmidtdetr.github.io/BLSloadR/reference/bls_overview.md)
functions to provide generalized access to the other databases at this
website within an R environment.

# Basic Usage

The primary functions in this package all begin with get\_ and are
listed below:

\-[`get_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_ces.md) -
This accesses data from the Current Employment Statistics (CES) program
at the state and metropolitan area levels. This provides employer-based
estimates of employment, wages, and hours worked. This is the “SM”
database.

\-[`get_national_ces()`](https://schmidtdetr.github.io/BLSloadR/reference/get_national_ces.md) -
This accesses national data from the CES program at the national level,
which does not include state-level breakouts. This is the “CE” database.

\-[`get_laus()`](https://schmidtdetr.github.io/BLSloadR/reference/get_laus.md) -
This accesses data from the Local Area Unemployment Statistics (LAUS)
program at a regional, state, and several sub-state levels. This is a
localized version of the Current Population Survey (CPS) which is used
to drive household-based estiamtes of employment and unemployment. This
is the “LA” database. Note that because of the volume of data here,
there are several different geographies that may be specified to pull
the appropriate data file from BLS.

\-[`get_oews()`](https://schmidtdetr.github.io/BLSloadR/reference/get_oews.md) -
This access the Occupational Employment and Wage Statistics (OEWS) data.
This data provides survey-based estimates of employmen and wages by
occupation at state and sub-state levels. This is the “OE” database.
Note that only current-year data is available for OEWS in this database,
as it is not built as a time series.

\-[`get_salt()`](https://schmidtdetr.github.io/BLSloadR/reference/get_salt.md) -
This data is not actually loated within the time.series folder, but
instead is sourced from <https://www.bls.gov/lau/stalt.htm>. These
Alternative Measures of Labor Underutilization for States are 12-month
averages built from CPS data which provide more expansive or restrictive
definitions of unemployment to measure the labor force, known as U1
through U6. This function also includes the optional geometry argument.
If set to TRUE, this will use
[`tigris::states()`](https://rdrr.io/pkg/tigris/man/states.html) and
[`tigris::shift_geometry()`](https://rdrr.io/pkg/tigris/man/shift_geometry.html)
to provide state polygons for convenient mapping of the output.

# General BLS Time Series Functions

These optional helper functions can aid the user of this package by
providing ways to summarize and explore all the time.series databases.
These functions are a bit different than the specific functions above,
as they implement a general way to merge and import BLS time.series
databases, but do not manually specify the data, series, and lookup
files to be joined. As such, they return a bls_data_collection object
which includes the joined data as well as diagnostic results including
dropped columns, unexpected join results, and other tools to help review
the data before use. Further, when multiple data or series files are
present, the user is prompted to choose one, so these tools are not
suitable for a typical piped script.

[`bls_overview()`](https://schmidtdetr.github.io/BLSloadR/reference/bls_overview.md) -
this function utilizes the standard structure of the time.series
databases, which has a simple text file explaining the database
structure that always follows the structure id.txt where id is the
two-character database identification code.

[`load_bls_dataset()`](https://schmidtdetr.github.io/BLSloadR/reference/load_bls_dataset.md) -
this function attempts to read and join all the relevant files in a BLS
database, and will sometimes prompt the user for additional input. For
example, many databases have multiple data files available (such as
“AllItems” and “Current”) and may have old series files as well (to
manage historical coding changes). Because these joins are performed
automatically, the object returned by this function is a more robust
diagnostic object included the joined data table as well as information
about the joins. Use Caution! BLS data structures are not always
consistent. There may be anomalies in the structure of individual
databases, such as missing column headers, that will degrade the ability
of this function to read the data.
