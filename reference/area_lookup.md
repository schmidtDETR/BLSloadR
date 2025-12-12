# Area Lookup Tables (QCEW)

A data frame containing area codes, titles, and additional geographic
information about valid areas for the Quarterly Census of Employment and
Wages (QCEW).

This table is primarily used internally by \`BLSloadR\` functions to add
human-readable area titles or define valid area lookups.

## Usage

``` r
data(area_lookup)
```

## Format

A data frame with 4649 rows and 5 columns:

- area_fips - Character. The area FIPS code. When all numeric
  characters, it represents either a state or a county definition.

- area_title - Character. The descripion of the area code provided by
  the Bureau of Labor Statistics.

- area_type - Character. A desription ot the type of area defined.
  Values are National, State, County, County Unknown or Undefined,
  National Subgroup, Combined Statistical Area, Metropolitan Statistical
  Area, or Micropolitan Statistical Area.

- stfips - Character. For state or counties, the two-digit FIPS code of
  the associated state. For national areas, or those areas which may
  span multiple states the value is "00".

- specified_region - Either the two-character US Postal abbreviation for
  a state or group of states, or "No region" for other areas.

## Source

<https://www.bls.gov/cew/classifications/areas/qcew-area-titles.htm>

## Details

Area codes are five characters long. When all numeric characters, this
is a state-county FIPS, with statewide data using a "000" as the county
FIPS. Other aggregations include various alphabetic characters to aid in
the classification of different regions.

## Examples

``` r
# Load the lookup table
data(area_lookup)

# Find the area codes for all Statewide areas
state_codes <- area_lookup[area_lookup$area_type == "State", ]

# Get all Metropolitan Statistical Area codes including Arkansas.
ar_codes <- area_lookup |> 
dplyr::filter(grepl("AR", specified_region) &
 area_type == "Metropolitan Statistical Area")
```
