# Create a BLS data object with diagnostics

Create a BLS data object with diagnostics

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
