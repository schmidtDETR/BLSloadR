# Helper function for downloading and tracking BLS files

This function is used to pass multiple URLs at the Bureau of Labor
Statistics into 'fread_bls()'

## Usage

``` r
download_bls_files(
  urls,
  suppress_warnings = TRUE,
  user_agent = NULL,
  cache = check_bls_cache_env()
)
```

## Arguments

- urls:

  Named or unnamed character vector of URLs to download. If unnamed,
  names will be auto-generated from basenames.

- suppress_warnings:

  Logical. If TRUE, suppress individual download warnings

- user_agent:

  An optional character string to pass to the USER_AGENT HTML header

- cache:

  Logical. If TRUE, uses local persistent caching.

## Value

Named list of bls_data objects
