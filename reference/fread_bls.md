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

A data.table containing the downloaded data

## Examples

``` r
if (FALSE) { # \dontrun{
data <- fread_bls("https://download.bls.gov/pub/time.series/ec/ec.series")
} # }
```
