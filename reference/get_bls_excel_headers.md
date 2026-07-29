# Generate headers for BLS requests to download Excel files

Returns a named character vector of HTTP headers required for BLS API
requests. These headers mimic a standard browser to ensure compatibility
with BLS servers. This function returns a more limited set of headers
used to download an Ecel file.

## Usage

``` r
get_bls_excel_headers(
  refer = "https://www.bls.gov/lau/stalt-archived.htm",
  user_agent = NULL
)
```

## Arguments

- refer:

  The URL to use in the Referer header (default:
  "https://www.bls.gov/lau/stalt-archived.htm")

- user_agent:

  An optional character string to pass to the USER_AGENT header.

## Value

A named character vector of HTTP headers
