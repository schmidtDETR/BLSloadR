# Display BLS Dataset Overview

Fetches and displays the overview text file for a BLS dataset using
proper headers to avoid 403 errors from the BLS server.

## Usage

``` r
bls_overview(
  series_id,
  display_method = "viewer",
  base_url = "https://download.bls.gov/pub/time.series"
)
```

## Arguments

- series_id:

  Character string. The BLS series identifier (e.g., "ln", "cu", "ap")

- display_method:

  Character string. How to display the overview: "viewer" (default),
  "console", "help", or "popup"

- base_url:

  Character string. Base URL for BLS data (default uses official BLS
  site)

## Value

Invisibly returns the text content

## Examples

``` r
if (FALSE) { # \dontrun{
# Display labor force statistics overview
bls_overview("ln")

# Display consumer price index overview  
bls_overview("cu")

# Display in console instead of viewer
bls_overview("ln", display_method = "console")
} # }
```
