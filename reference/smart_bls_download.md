# Check and Download BLS File with Local Caching

This function manages the downloading of files from the BLS server with
a local caching layer. It uses HTTP HEAD requests to compare the
server's \`Content-Length\` and \`Last-Modified\` headers with local
file attributes. The file is only downloaded if it does not exist
locally, or if the remote version is newer or a different size.

## Usage

``` r
smart_bls_download(url, cache_dir = NULL, verbose = FALSE)
```

## Arguments

- url:

  A character string representing the URL of the BLS file (e.g., a
  \`.txt\` or \`.gz\` file from download.bls.gov).

- cache_dir:

  A character string specifying the local directory to store cached
  files. May also be set with the enviroment variable \`BLS_CACHE_DIR\`
  Defaults to a persistent user data directory managed by
  [`tools::R_user_dir`](https://rdrr.io/r/tools/userdir.html).

- verbose:

  Logical. Defaults to FALSE. If TRUE, returns status messages for
  download.

## Value

A character string containing the local path to the downloaded (or
cached) file.

## Details

The function uses a specific set of browser-like headers to ensure
compatibility with BLS server security policies. Upon a successful
download, the local file's modification time is synchronized with the
server's \`Last-Modified\` header using `Sys.setFileTime` to ensure
accurate future comparisons.

## Examples

``` r
if (FALSE) { # \dontrun{
url <- "https://download.bls.gov/pub/time.series/ce/ce.data.0.AllCESSeries"
local_path <- smart_bls_download(url)
data <- data.table::fread(local_path)
} # }
```
