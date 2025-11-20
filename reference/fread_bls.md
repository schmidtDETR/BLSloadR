# Download BLS Time Series Data

This function downloads a tab-delimited BLS flat file, incorporating
diagnostic information about the file and returning an object with the
bls_data class that can be used in the BLSloadR package.

## Usage

``` r
fread_bls(url, verbose = FALSE)
```

## Arguments

- url:

  Character string. URL to the BLS flat file

- verbose:

  Logical. If TRUE, prints additional messages during file read and
  processing. If FALSE (default), suppresses these messages.

## Value

A named list with two elements:

- data:

  A data.table with the results of passing the url contents to
  'data.table::fread()' as a tab-delimited text file.

- diagnostics:

  A named list of diagnostics run when reading the file including column
  names, empty columns, cleaning applied to the file, the url, the
  column names and original and final dimensions of the data.

## Examples

``` r
# \donttest{
data <- fread_bls("https://download.bls.gov/pub/time.series/ec/ec.series")
# }
```
