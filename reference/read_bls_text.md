# Read Plain Text Files from BLS Website

Downloads and reads plain text files from the Bureau of Labor Statistics
(BLS) website. This is a companion function to
[`fread_bls()`](https://schmidtdetr.github.io/BLSloadR/reference/fread_bls.md)
that handles text files rather than structured data tables. The function
uses custom headers to ensure reliable access to BLS resources.

## Usage

``` r
read_bls_text(url)
```

## Arguments

- url:

  A character string specifying the full URL to a text file on the BLS
  website (e.g., <https://download.bls.gov/pub/time.series/>).

## Value

A character vector where each element is one line from the text file.
Lines are split on newline characters (`\n`).

## Details

This function is designed to read descriptive text files from BLS, such
as README files or database overview documents. It sends an HTTP GET
request with browser-like headers to ensure compatibility with BLS
server requirements.

The function will stop with an error if the HTTP request fails (e.g., if
the URL is invalid or the server is unavailable).

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
#> [1] NA
# }
```
