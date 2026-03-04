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
#> Initial data dimensions:35306x5
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:57
#> Number of tab-separated fields:5
#> Header names:'series_id', 'year', 'period', 'value', 'footnote_codes'
#> Final data dimensions:35306x5 in https://download.bls.gov/pub/time.series/fm/fm.data.1.AllData
#> Final column names:series_id, year, period, value, footnote_codes
#> Downloadingfm.series...
#> Initial data dimensions:3144x32
#> Phantom columns detected:1
#> Phantom column names:footnote_codes
#> Applied selective tab cleaning to remove phantom columns
#> Header parsing debug:
#> Raw header line length:348
#> Number of tab-separated fields:32
#> Header names:'series_id', 'seasonal', 'series_title', 'fchld_code', 'fdat_code', 'fhlf_code', 'fnmatwk_code', 'fnme_code', 'fnmlf_code', 'fnmu_code', 'fnmws_code', 'forig_code', 'frace_code', 'ftpt_code', 'ftyp_code', 'hhlf_code', 'misclf_code', 'mwlf_code', 'prlf_code', 'chld_code', 'lfst_code', 'mari_code', 'orig_code', 'race_code', 'sexs_code', 'tdat_code', 'wkst_code', 'footnote_codes', 'begin_year', 'begin_period', 'end_year', 'end_period'
#> Final data dimensions:3144x32 in https://download.bls.gov/pub/time.series/fm/fm.series
#> Removing1remaining empty columns
#> Final column names:series_id, seasonal, series_title, fchld_code, fdat_code, fhlf_code, fnmatwk_code, fnme_code, fnmlf_code, fnmu_code, fnmws_code, forig_code, frace_code, ftpt_code, ftyp_code, hhlf_code, misclf_code, mwlf_code, prlf_code, chld_code, lfst_code, mari_code, orig_code, race_code, sexs_code, tdat_code, wkst_code, begin_year, begin_period, end_year, end_period
#> Single FileData Download Warnings:
#> ====================================
#> Total files downloaded:1
#> Files with issues:TRUE
#> Total warnings:2
#> 
#> Summary of warnings:
#>   1. Phantom columns detected and cleaned: 1
#>   2. Empty columns removed: 1
#> Downloadingfm.chld...
#> Initial data dimensions:15x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'chld_code', 'chld_text'
#> Final data dimensions:15x2 in https://download.bls.gov/pub/time.series/fm/fm.chld
#> Final column names:chld_code, chld_text
#> Downloadingfm.fchld...
#> Initial data dimensions:4x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:21
#> Number of tab-separated fields:2
#> Header names:'fchld_code', 'fchld_text'
#> Final data dimensions:4x2 in https://download.bls.gov/pub/time.series/fm/fm.fchld
#> Final column names:fchld_code, fchld_text
#> Downloadingfm.fdat...
#> Initial data dimensions:3x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'fdat_code', 'fdat_text'
#> Final data dimensions:3x2 in https://download.bls.gov/pub/time.series/fm/fm.fdat
#> Final column names:fdat_code, fdat_text
#> Downloadingfm.fhlf...
#> Initial data dimensions:7x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'fhlf_code', 'fhlf_text'
#> Final data dimensions:7x2 in https://download.bls.gov/pub/time.series/fm/fm.fhlf
#> Final column names:fhlf_code, fhlf_text
#> Downloadingfm.fnmatwk...
#> Initial data dimensions:8x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:25
#> Number of tab-separated fields:2
#> Header names:'fnmatwk_code', 'fnmatwk_text'
#> Final data dimensions:8x2 in https://download.bls.gov/pub/time.series/fm/fm.fnmatwk
#> Final column names:fnmatwk_code, fnmatwk_text
#> Downloadingfm.fnme...
#> Initial data dimensions:8x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'fnme_code', 'fnme_text'
#> Final data dimensions:8x2 in https://download.bls.gov/pub/time.series/fm/fm.fnme
#> Final column names:fnme_code, fnme_text
#> Downloadingfm.fnmlf...
#> Initial data dimensions:8x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:21
#> Number of tab-separated fields:2
#> Header names:'fnmlf_code', 'fnmlf_text'
#> Final data dimensions:8x2 in https://download.bls.gov/pub/time.series/fm/fm.fnmlf
#> Final column names:fnmlf_code, fnmlf_text
#> Downloadingfm.fnmu...
#> Initial data dimensions:2x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'fnmu_code', 'fnmu_text'
#> Final data dimensions:2x2 in https://download.bls.gov/pub/time.series/fm/fm.fnmu
#> Final column names:fnmu_code, fnmu_text
#> Downloadingfm.fnmws...
#> Initial data dimensions:4x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:21
#> Number of tab-separated fields:2
#> Header names:'fnmws_code', 'fnmws_text'
#> Final data dimensions:4x2 in https://download.bls.gov/pub/time.series/fm/fm.fnmws
#> Final column names:fnmws_code, fnmws_text
#> Downloadingfm.forig...
#> Initial data dimensions:2x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:21
#> Number of tab-separated fields:2
#> Header names:'forig_code', 'forig_text'
#> Final data dimensions:2x2 in https://download.bls.gov/pub/time.series/fm/fm.forig
#> Final column names:forig_code, forig_text
#> Downloadingfm.frace...
#> Initial data dimensions:4x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:21
#> Number of tab-separated fields:2
#> Header names:'frace_code', 'frace_text'
#> Final data dimensions:4x2 in https://download.bls.gov/pub/time.series/fm/fm.frace
#> Final column names:frace_code, frace_text
#> Downloadingfm.ftpt...
#> Initial data dimensions:3x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'ftpt_code', 'ftpt_text'
#> Final data dimensions:3x2 in https://download.bls.gov/pub/time.series/fm/fm.ftpt
#> Final column names:ftpt_code, ftpt_text
#> Downloadingfm.ftyp...
#> Initial data dimensions:6x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'ftyp_code', 'ftyp_text'
#> Final data dimensions:6x2 in https://download.bls.gov/pub/time.series/fm/fm.ftyp
#> Final column names:ftyp_code, ftyp_text
#> Downloadingfm.hhlf...
#> Initial data dimensions:7x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'hhlf_code', 'hhlf_text'
#> Final data dimensions:7x2 in https://download.bls.gov/pub/time.series/fm/fm.hhlf
#> Final column names:hhlf_code, hhlf_text
#> Downloadingfm.lfst...
#> Initial data dimensions:11x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'lfst_code', 'lfst_text'
#> Final data dimensions:11x2 in https://download.bls.gov/pub/time.series/fm/fm.lfst
#> Final column names:lfst_code, lfst_text
#> Downloadingfm.mari...
#> Initial data dimensions:3x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'mari_code', 'mari_text'
#> Final data dimensions:3x2 in https://download.bls.gov/pub/time.series/fm/fm.mari
#> Final column names:mari_code, mari_text
#> Downloadingfm.misclf...
#> Initial data dimensions:2x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:23
#> Number of tab-separated fields:2
#> Header names:'misclf_code', 'misclf_text'
#> Final data dimensions:2x2 in https://download.bls.gov/pub/time.series/fm/fm.misclf
#> Final column names:misclf_code, misclf_text
#> Downloadingfm.mwlf...
#> Initial data dimensions:7x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'mwlf_code', 'mwlf_text'
#> Final data dimensions:7x2 in https://download.bls.gov/pub/time.series/fm/fm.mwlf
#> Final column names:mwlf_code, mwlf_text
#> Downloadingfm.orig...
#> Initial data dimensions:2x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'orig_code', 'orig_text'
#> Final data dimensions:2x2 in https://download.bls.gov/pub/time.series/fm/fm.orig
#> Final column names:orig_code, orig_text
#> Downloadingfm.prlf...
#> Initial data dimensions:5x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'prlf_code', 'prlf_text'
#> Final data dimensions:5x2 in https://download.bls.gov/pub/time.series/fm/fm.prlf
#> Final column names:prlf_code, prlf_text
#> Downloadingfm.race...
#> Initial data dimensions:4x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'race_code', 'race_text'
#> Final data dimensions:4x2 in https://download.bls.gov/pub/time.series/fm/fm.race
#> Final column names:race_code, race_text
#> Downloadingfm.seasonal...
#> Initial data dimensions:2x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:27
#> Number of tab-separated fields:2
#> Header names:'seasonal_code', 'seasonal_text'
#> Final data dimensions:2x2 in https://download.bls.gov/pub/time.series/fm/fm.seasonal
#> Final column names:seasonal_code, seasonal_text
#> Downloadingfm.sexs...
#> Initial data dimensions:3x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'sexs_code', 'sexs_text'
#> Final data dimensions:3x2 in https://download.bls.gov/pub/time.series/fm/fm.sexs
#> Final column names:sexs_code, sexs_text
#> Downloadingfm.tdat...
#> Initial data dimensions:2x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'tdat_code', 'tdat_text'
#> Final data dimensions:2x2 in https://download.bls.gov/pub/time.series/fm/fm.tdat
#> Final column names:tdat_code, tdat_text
#> Downloadingfm.wkst...
#> Initial data dimensions:3x2
#> Phantom columns detected:0
#> No phantom columns detected, using original data
#> Header parsing debug:
#> Raw header line length:19
#> Number of tab-separated fields:2
#> Header names:'wkst_code', 'wkst_text'
#> Final data dimensions:3x2 in https://download.bls.gov/pub/time.series/fm/fm.wkst
#> Final column names:wkst_code, wkst_text
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
#> BLS-FMData Download Warnings:
#> ===============================
#> Total files downloaded:27
#> Files with issues:1
#> Total warnings:2
#> Final data dimensions:35306 x 35
#> 
#> Summary of warnings:
#>   1. fm.series : Phantom columns detected and cleaned: 1
#>   2. fm.series : Empty columns removed: 1
#> 
#> Run with return_diagnostics=TRUE and print_bls_warnings(data, detailed = TRUE) for file-by-file details
#> 
#> Use print_bls_warnings(result, detailed = TRUE) for detailed diagnostics

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
