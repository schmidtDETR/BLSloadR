# Generate headers for BLS requests

Returns a named character vector of HTTP headers required for BLS API
requests. These headers mimic a standard browser to ensure compatibility
with BLS servers.

## Usage

``` r
get_bls_headers(host = "download.bls.gov")
```

## Arguments

- host:

  The host to use in the Host header (default: "download.bls.gov")

## Value

A named character vector of HTTP headers
