# Generic BLS Dataset Download

This function generalizes a method to download all BLS data for a given
time series database. These files are accessed from
https://download.bls.gov/pub/time.series/ and several datasets are
available. A summary of an identified database can be generated using
the \`bls_overiew()\` function. When multiple potential data files exist
(common in large data sets), the function will prompt for an input of
which file to use.

## Usage

``` r
load_bls_dataset(
  database_code,
  return_full = FALSE,
  simplify_table = TRUE,
  suppress_warnings = FALSE,
  which_data = NULL,
  cache = check_bls_cache_env()
)
```

## Arguments

- database_code:

  This is the two digit character identifier for the desired database.
  Some Valid options are:

  - "ce" - National Current Employment Statistics Data

  - "sm" - State and Metro area Current Employment Statistics Data

  - "mp" - Major Sector Total Factor Productivity

  - "ci" - Employment Cost Index

  - "eb" - Employee Benefits Survey

- return_full:

  This argument defaults to FALSE. If set to TRUE it will return a list
  of the elements of data retrieved from the BLS separating the data,
  series, and mapping values downloaded.

- simplify_table:

  This parameter defaults to TRUE. When TRUE it will remove all columns
  from the date with "\_code" in the column name, as well as a series of
  internal identifiers which provide general information about the
  series but which are not needed for performing time series analysis.
  This parameter also converts the column "value" to numeric and
  generates a date column from the year and period columns in the data.

- suppress_warnings:

  Logical. If TRUE, suppress individual download warnings during
  processing.

- which_data:

  Character string or NULL. Defaults to NULL.

  - "all" - Automatically selects the data file containing ".1.All"
    (e.g., "bd.data.1.AllItems" or "le.data.1.AllData").

  - "current" - Automatically selects the data file containing "Current"
    (e.g., "ce.data.0.Current").

  - NULL - Default behavior. Prompts the user to select a file if
    multiple exist, or selects the single available file.

  If the requested pattern is not found, the function falls back to the
  default behavior, prompting the user to select a file.

- cache:

  Logical. Uses USE_BLS_CACHE environment variable, or defaults to
  FALSE. If TRUE, will download a cached file from BLS server and update
  cache if BLS server indicates an updated file.

## Value

This function will return either a bls_data_collection object (if
return_full is FALSE or not provided) or a named list of the returned
data including the bls_data_collection object.

## Examples

``` r
# \donttest{
# Import All Data
fm_import <- load_bls_dataset("fm", which_data = "all")
#> Loading series file:fm.series
#> Auto-selected 'all' file: fm.data.1.AllData
#> No aspect files found in the BLS database directory.
#> Downloadingfm.data.1.AllData...
#> Downloadingfm.series...
#> Downloadingfm.chld...
#> Downloadingfm.fchld...
#> Downloadingfm.fdat...
#> Downloadingfm.fhlf...
#> Downloadingfm.fnmatwk...
#> Downloadingfm.fnme...
#> Downloadingfm.fnmlf...
#> Downloadingfm.fnmu...
#> Downloadingfm.fnmws...
#> Downloadingfm.forig...
#> Downloadingfm.frace...
#> Downloadingfm.ftpt...
#> Downloadingfm.ftyp...
#> Downloadingfm.hhlf...
#> Downloadingfm.lfst...
#> Downloadingfm.mari...
#> Downloadingfm.misclf...
#> Downloadingfm.mwlf...
#> Downloadingfm.orig...
#> Downloadingfm.prlf...
#> Downloadingfm.race...
#> Downloadingfm.seasonal...
#> Downloadingfm.sexs...
#> Downloadingfm.tdat...
#> Downloadingfm.wkst...
#> Joining data to series file...
#> Joining mapping file fm.chld on column: chld_code
#> Joining mapping file fm.fchld on column: fchld_code
#> Joining mapping file fm.fdat on column: fdat_code
#> Joining mapping file fm.fhlf on column: fhlf_code
#> Joining mapping file fm.fnmatwk on column: fnmatwk_code
#> Joining mapping file fm.fnme on column: fnme_code
#> Joining mapping file fm.fnmlf on column: fnmlf_code
#> Joining mapping file fm.fnmu on column: fnmu_code
#> Joining mapping file fm.fnmws on column: fnmws_code
#> Joining mapping file fm.forig on column: forig_code
#> Joining mapping file fm.frace on column: frace_code
#> Joining mapping file fm.ftpt on column: ftpt_code
#> Joining mapping file fm.ftyp on column: ftyp_code
#> Joining mapping file fm.hhlf on column: hhlf_code
#> Joining mapping file fm.lfst on column: lfst_code
#> Joining mapping file fm.mari on column: mari_code
#> Joining mapping file fm.misclf on column: misclf_code
#> Joining mapping file fm.mwlf on column: mwlf_code
#> Joining mapping file fm.orig on column: orig_code
#> Joining mapping file fm.prlf on column: prlf_code
#> Joining mapping file fm.race on column: race_code
#> Skipping mapping file fm.seasonal - join column 'seasonal_code' not found in data
#> Joining mapping file fm.sexs on column: sexs_code
#> Joining mapping file fm.tdat on column: tdat_code
#> Joining mapping file fm.wkst on column: wkst_code
#> Simplifying table structure...
#> 
#> Download completed successfully with no issues detected.

# Get $data element
fm_data <- fm_import$data

# Filter to a Series
# Families with Children Under 6 and No Employed Parent

u6_no_emp <- fm_data |> 
  dplyr::filter(series_title == "Total families with children under 6 - with no parent employed") |> 
  dplyr:: select(year, value, fchld_text, fhlf_text, tdat_text)


head(u6_no_emp)
#>      year value                fchld_text          fhlf_text
#>    <char> <num>                    <char>             <char>
#> 1:   2009  2007 With own children under 6 Unemployed or NILF
#> 2:   2010  2103 With own children under 6 Unemployed or NILF
#> 3:   2011  2105 With own children under 6 Unemployed or NILF
#> 4:   2012  1992 With own children under 6 Unemployed or NILF
#> 5:   2013  1880 With own children under 6 Unemployed or NILF
#> 6:   2014  1807 With own children under 6 Unemployed or NILF
#>               tdat_text
#>                  <char>
#> 1: Numbers in thousands
#> 2: Numbers in thousands
#> 3: Numbers in thousands
#> 4: Numbers in thousands
#> 5: Numbers in thousands
#> 6: Numbers in thousands
# }

if (FALSE) { # \dontrun{
# Examples requiring manual intervention in the console
# Download Employer Cost Index Data
cost_index <- load_bls_dataset("ci")

# Download separated data, series, and mapping columns
benefits <- load_bls_dataset("eb", return_full = TRUE)

# Download data without removing excess columns and value conversions
productivity <- load_bls_dataset("mp", simplify_table = FALSE)

# Check for download issues
if (has_bls_issues(cost_index)) {
  print_bls_warnings(cost_index, detailed = TRUE)
}

} # }
```
