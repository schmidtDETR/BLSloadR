# Create a BLS data object with diagnostics

This is a helper function to create a list with the additional class
'bls_data_collection' containing data downloaded form the U.S. Bureau of
Labor Statistics as well as diagnostic details about the download. It is
used invisibly in the package to bundle information about file
downloads.

## Usage

``` r
create_bls_object(
  data,
  downloads,
  data_type = "BLS",
  processing_steps = character(0)
)
```

## Arguments

- data:

  The processed data (data.table/data.frame)

- downloads:

  List of download results from fread_bls()

- data_type:

  Character string describing the type of BLS data (e.g., "CES",
  "JOLTS", "CPS")

- processing_steps:

  Character vector describing processing steps applied

## Value

A bls_data_collection object
