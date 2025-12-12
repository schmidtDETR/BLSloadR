# Download OEWS Area Definitions

Download OEWS Area Definitions

## Usage

``` r
get_oews_areas(ref_year, silent = TRUE, geometry = TRUE)
```

## Arguments

- ref_year:

  Four-digit year (converted to integer). The year for which to retrieve
  OEWS area definitions. Valid values are 2024 through current release
  year. Prior years included Township codes, which change the structure
  of the file.

- silent:

  Logical. If TRUE (default), suppress console output

- geometry:

  Logical. If TRUE (default), downloads shapefiles for OEWS area
  definitions using \`tigris::counties()\` and
  \`tigris::shift_geometry()\` to render Alaska, Hawaii, and Puerto Rico
  with a focus on the area of the continental United States.

## Value

Data table which maps individual counties to OEWS area definitions.

- fips_code - The State FIPS code

- state_name - The state name

- state_abb - The state two-character postal abbreviation

- oews_area_code - The OEWS area code defining the metropolitan area or
  nonmetropolitan area the county belongs to.

- oews_area_name - The OEWS area name

- county_code - The FIPS code for the county

- county_name - The county name

## Examples

``` r
# \donttest{
 # Get OEWS area definitions without shapefiles and with processing messages.
 test <- get_oews_areas(ref_year = 2024, geometry = FALSE, silent = FALSE)
#> Downloading OEWS area definitions from BLS.
#> Processing OEWS area definition Excel file for 2024.
 
# }
```
