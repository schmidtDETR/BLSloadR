# Read Plain Text Files from BLS Website

Downloads and reads plain text files from the Bureau of Labor Statistics
(BLS) website. This is a companion function to
[`fread_bls()`](https://schmidtdetr.github.io/BLSloadR/reference/fread_bls.md)
that handles text files rather than structured data tables. The function
uses custom headers to ensure reliable access to BLS resources.

## Usage

``` r
read_bls_text(url, user_agent = NULL)
```

## Arguments

- url:

  A character string specifying the full URL to a text file on the BLS
  website (e.g., <https://download.bls.gov/pub/time.series/>).

- user_agent:

  An optional character string supplying a USER_AGENT header for the
  HTML request from the BLS.

## Value

A character vector where each element is one line from the text file.
Lines are split on newline characters (`\n`). Returns `NULL` if the HTTP
request fails.

## Details

This function is designed to read descriptive text files from BLS, such
as README files or database overview documents. It sends an HTTP GET
request with browser-like headers to ensure compatibility with BLS
server requirements.

If the HTTP request fails (e.g., if the URL is invalid, the server is
unavailable, or a 403 Forbidden error is encountered during automated
testing), the function will issue a warning and gracefully return `NULL`
rather than stopping execution.

## See also

[`bls_overview`](https://schmidtdetr.github.io/BLSloadR/reference/bls_overview.md)
for formatted database overviews,
[`load_bls_dataset`](https://schmidtdetr.github.io/BLSloadR/reference/load_bls_dataset.md)
for loading complete datasets

## Examples

``` r
# \donttest{
# Read the overview file for Current Employment Statistics
ces_overview <- read_bls_text(
  "https://download.bls.gov/pub/time.series/ce/ce.txt"
)

# Display the first few lines
head(ces_overview)
#> [1] "Current Employment Statistics: Employment, Hours, and Earnings--National (CE)          \r"
#> [2] "     ce.txt  \r"                                                                          
#> [3] "\r"                                                                                       
#> [4] "Section Listing                                                                        \r"
#> [5] "                                                                                       \r"
#> [6] "1. Survey Definition                                                                   \r"
# }
```
