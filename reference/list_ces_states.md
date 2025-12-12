# List Available States for CES Data

Lists all available U.S. states and territories that can be used with
the \`states\` parameter in \`get_ces()\` function.

## Usage

``` r
list_ces_states()
```

## Value

A character vector of available state/territory abbreviations

## Examples

``` r
# See all available states
list_ces_states()
#>  [1] "AL" "AK" "AZ" "AR" "CA" "CO" "CT" "DE" "DC" "FL" "GA" "HI" "ID" "IL" "IN"
#> [16] "IA" "KS" "KY" "LA" "ME" "MD" "MA" "MI" "MN" "MS" "MO" "MT" "NE" "NV" "NH"
#> [31] "NJ" "NM" "NY" "NC" "ND" "OH" "OK" "OR" "PA" "PR" "RI" "SC" "SD" "TN" "TX"
#> [46] "UT" "VT" "VA" "VI" "WA" "WV" "WI" "WY"

# Use with get_ces
# ces_data <- get_ces(states = c("MA", "NY"))  # All industries for these states
```
