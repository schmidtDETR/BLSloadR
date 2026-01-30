# Get the current BLSloadR Cache Directory

Displays the path currently being used for caching. This will check the
\`BLS_CACHE_DIR\` environment variable, falling back to the default
system cache directory if the variable is not set.

## Usage

``` r
bls_get_cache_dir()
```

## Value

A character string of the cache path.
