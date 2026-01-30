# Download BLS Time Series Data

This function downloads a tab-delimited BLS flat file, incorporating
diagnostic information about the file and returning an object with the
bls_data class that can be used in the BLSloadR package.

## Usage

``` r
fread_bls(url, verbose = FALSE, cache = check_bls_cache_env())
```

## Arguments

- url:

  Character string. URL to the BLS flat file

- verbose:

  Logical. If TRUE, prints additional messages during file read and
  processing.

- cache:

  Logical. If TRUE, uses local persistent caching.

## Value

A named list with the data and diagnostics.
