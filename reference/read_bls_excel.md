# Download BLS Excel Data

Download BLS Excel Data

## Usage

``` r
read_bls_excel(url, verbose = FALSE, ...)
```

## Arguments

- url:

  Character string. URL to the BLS .xlsx or .xls file.

- verbose:

  Logical. If TRUE, prints diagnostic messages.

- ...:

  Additional arguments passed to readxl::read_excel (e.g., sheet,
  range).

## Value

A data.frame or NULL if the download or read fails.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download BLS Alternative MEasures History
salt_url <- "https://www.bls.gov/lau/stalt-moave.xlsx"
salt_data <- read_bls_excel(salt_url, skip = 1)

} # }
```
