# Download Occupational Employment and Wage Statistics (OEWS) Data

This function downloads and joins together occupational employment and
wage data from the Bureau of Labor Statistics OEWS program. The data
includes employment and wage estimates by occupation and geographic
area.

## Usage

``` r
get_oews(suppress_warnings = FALSE, return_diagnostics = FALSE)
```

## Arguments

- suppress_warnings:

  Logical. If TRUE, suppress individual download warnings for cleaner
  output during batch processing.

- return_diagnostics:

  Logical. If TRUE, returns a bls_data_collection object with full
  diagnostics. If FALSE (default), returns just the data table.

## Value

By default, returns a data.table with OEWS data. If return_diagnostics =
TRUE, returns a bls_data_collection object containing data and
comprehensive diagnostics.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download current OEWS data
oews_data <- get_oews()

# View available occupations
unique(get_bls_data(oews_data)$occupation_title)

# Filter for specific occupation
software_devs <- get_bls_data(oews_data)[grepl("Software", occupation_title)]

# Get full diagnostic object if needed
oews_with_diagnostics <- get_oews(return_diagnostics = TRUE)
print_bls_warnings(oews_with_diagnostics)
} # }
```
