# Get summary information from BLS data object

This is a helper function to extract the summary element of a
'bls_data_collection' object. This containes the number of files
downloaded, the number of files with potential warnings, and the total
number of warnings.

## Usage

``` r
get_bls_summary(bls_obj)
```

## Arguments

- bls_obj:

  A bls_data_collection object

## Value

List of summary information
