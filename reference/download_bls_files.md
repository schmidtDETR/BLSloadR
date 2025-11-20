# Helper function for downloading and tracking BLS files

This function is used to pass multiple URLs at the Bureau of Labor
Statistics into 'fread_bls()'

## Usage

``` r
download_bls_files(urls, suppress_warnings = TRUE)
```

## Arguments

- urls:

  Named character vector of URLs to download

- suppress_warnings:

  Logical. If TRUE, suppress individual download warnings

## Value

Named list of bls_data objects
