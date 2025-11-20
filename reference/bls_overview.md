# Display BLS Dataset Overview

Fetches and displays the overview text file for a BLS dataset. This
provides a convenient reference within the R environment without needing
to manually find and review the text file on the BLS website.

## Usage

``` r
bls_overview(
  series_id,
  display_method = "viewer",
  base_url = "https://download.bls.gov/pub/time.series"
)
```

## Arguments

- series_id:

  Character string. The BLS series identifier (e.g., "ln", "cu", "ap")

- display_method:

  Character string. How to display the overview: "viewer" (default),
  "console", or "popup"

- base_url:

  Character string. Base URL for BLS data (default uses official BLS
  site)

## Value

Invisibly returns the text content. Function is called to use the
viewer, console, or as a popup, depending on the 'display_method'
argument.

## Examples

``` r
# \donttest{
# Display labor force statistics overview
bls_overview("ln")

# Display consumer price index overview  
bls_overview("cu")

# Display in console instead of viewer
bls_overview("ln", display_method = "console")
#> 
#> === BLS Dataset Overview: LN ===
#> Source: https://download.bls.gov/pub/time.series/ln/ln.txt
#> ================================================== 
#> 
#> LABOR FORCE STATISTICS FROM THE CURRENT POPULATION SURVEY (LN database)
#>              ln.txt
#> 
#> Section Listing
#> 
#> 1. Survey Definition
#> 2. Flat files listed in the survey directory.
#> 3. Time series, series file, data file, & mapping file definitions and relationships
#> 4. Series file format and field definitions
#> 5. Data file format and field definitions
#> 6. Mapping file formats and field definitions
#> 
#> 
#> ================================================================================
#> Section 1 - Survey Definition
#> ================================================================================
#> 
#> The following is a definition of: LABOR FORCE STATISTICS FROM THE CURRENT POPULATION SURVEY (LN)
#> 
#> Survey Description:   
#> 
#> The Current Population Survey (CPS) is a sample survey of the population 16 years of age and over.  
#> The survey is conducted each month by the U.S. Census Bureau for the Bureau of Labor Statistics and provides 
#> comprehensive data on the labor force, the employed, and the unemployed, classified by such characteristics 
#> as age, sex, race, family relationship, marital status, occupation, and industry attachment.  The information 
#> is collected by trained interviewers from a sample of about 60,000 households. Sample areas are chosen to 
#> represent all counties and independent cities in the United States, with coverage in 50 States and the District of 
#> Columbia.  The data collected are based on the activity or status reported for the calendar week including the 
#> 12th of the month.  
#> 
#> Summary Data Available: CPS data are available for the civilian, noninstitutional population age 16 
#> and older and various detailed groups, with estimates available by age, race, sex, Hispanic or Latino
#> ethnicity, employment status, occupation, industry, class of worker, educational attainment, telework status,
#> and other characteristics.
#> 
#> Frequency of observations: CPS data are collected each month, and monthly estimates are presented in the Employment 
#> Situation News Release. Some data series are available as quarterly or annual averages.
#> 
#> Data characteristics: Data include counts (presented in thousands) and rates such as the unemploment
#> rate, labor force participation rate, and employment-population ratio.
#> 
#> Updating schedule: Updates are available with the issuance of the monthly
#> Employment Situation news release.
#> 
#> 
#> ================================================================================
#> Section 2 - Flat files listed in the survey directory.
#> ================================================================================
#> 
#> The following CPS labor force files are on the BLS internet in the 
#> sub-directory pub/time.series/ln:
#> 
#>        ln.absn           - Absence codes             mapping file
#>        ln.activity       - Activity codes                mapping file
#>        ln.ages           - Age group codes               mapping file
#>        ln.born           - Nativity/Citizenship codes        mapping file
#>        ln.cert           - Certification codes           mapping file
#>        ln.chld           - Presence of children codes        mapping file
#>        ln.class          - Class of worker codes         mapping file
#>        ln.data.1.AllData - All data              data file
#>        ln.disa           - Disability codes              mapping file
#>        ln.duration       - Duration codes                mapping file
#>        ln.education      - Education codes           mapping file
#>        ln.entr           - Entrance to labor force codes     mapping file
#>        ln.expr           - Work experience codes         mapping file
#>        ln.footnote       - Footnote codes            mapping file
#>        ln.hheader        - Head of household codes       mapping file
#>        ln.hour           - Hours worked codes            mapping file
#>        ln.indy           - Industry codes            mapping file
#>        ln.jdes           - Want a job codes          mapping file
#>        ln.lfst           - Labor force status codes      mapping file
#>        ln.look           - Job seeker codes          mapping file
#>        ln.mari           - Marital status codes          mapping file
#>        ln.mjhs           - Multiple jobholder codes      mapping file
#>        ln.occupation         - Occupation codes          mapping file
#>        ln.orig           - Hispanic or Latino origin codes   mapping file
#>        ln.pcts           - Percentage codes          mapping file
#>        ln.periodicity        - Periodicity codes         mapping file
#>        ln.race           - Race codes                mapping file
#>        ln.rjnw           - Absence reason codes          mapping file
#>        ln.rnlf           - Job search codes          mapping file
#>        ln.rwns           - Part time reason codes        mapping file
#>        ln.seasonal       - Seasonal adjustment codes     mapping file
#>        ln.seek           - Job seeker codes          mapping file
#>        ln.series     - All series with beginning and end dates
#>        ln.sexs           - Sex codes             mapping file
#>        ln.tdat           - Data type codes           mapping file
#>        ln.tlwk           - Telework codes            mapping file
#>        ln.txt            - General information
#>        ln.vets           - Veteran status codes          mapping file
#>        ln.wkst           - Work status codes         mapping file
#>  
#> ================================================================================
#> Section 3 - Time series, series file, data file, & mapping file definitions and relationships
#> ================================================================================
#> The definition of a time series, its relationship to and the interrelationship
#> among series, data and mapping files is detailed below:
#> 
#> A time series refers to a set of data observed over an extended period of time
#> over consistent time intervals (i.e. monthly, quarterly, semi-annually, annually).
#> CPS time series data are available as monthly estimates, or as quarterly or annual averages.
#> Not seasonally adjusted data are considered final when published. At the end of each calendar
#> year, the Bureau of Labor Statistics (BLS) reestimates the seasonal factors for the CPS series 
#> by including another full year of data in the estimation process. Following this annual reestimation, 
#> BLS revises the historical seasonally adjusted data for the previous 5 years.
#> 
#> The flat files are organized such that data users are provided with the following
#> set of files to use in their efforts to interpret data files:
#> 
#> a)  a series file (only one series file per database)
#> b)  mapping files
#> c)  data files
#> 
#> The series file contains series identification codes that serve to uniquely identify 
#> time series within the database, along with their titles and attributes (age, sex, race, 
#> occupation, industry, etc.). Additionally, the series file also contains the following 
#> series-level information:
#> 
#> a) the period and year corresponding to the first data observation 
#> b) the period and year corresponding to the most recent data observation 
#> c) characteristics of the series corresponding to values in the mapping files
#> 
#> The mapping files are definition files that contain explanatory text 
#> descriptions that correspond to information contained within the series file.
#> 
#> The data file contains one line of data for each observation period pertaining 
#> to a specific time series.  Each line contains a reference to the following:
#> 
#> a) a series identification code
#> b) year in which data is observed
#> c) period for which data is observed (M01 to M12 indicate monthly data, 
#> A01 and M13 indicate annual averages, and Q01, Q01, Q03, Q04 indicate quarterly averages)
#> d) value
#> e) footnote code (if available)
#> 
#> For series that have monthly data, M13 indicates annual averages. For series that do
#> not have monthly data, A01 indicates annual averages.
#> 
#> ================================================================================
#> Section 4 - Series file format and field definitions
#> ================================================================================
#> File Structure and Format: The following represents the file format used to 
#> define ln.series. Note that the Field Numbers are for reference only; they do 
#> not exist in the database. Data files are in ASCII text format. Data elements 
#> are separated by tabs; the first record of each file contains the column headers 
#> for the data elements stored in each field. Each record ends with a new line 
#> character. 
#> 
#> Field #/Data Element Length      Value(Example)      
#> 
#> 1.  series_id          varies    LNU04000000
#> 
#>  Description of the components in the series ID 
#> 
#> 2.  prefix         2             LN
#> 
#> 3.  seasonal code      1     U
#> 
#> 4.  series code        8     04000000
#> 
#>      
#> In the LN database, series ID codes cannot be decoded to refer to specific data types by looking at 
#> the value of different components of the series code. Series in the LN database have many characteristics 
#> and representing them all within the series code would result in extremely long ID codes. The only meaningful 
#> values are the initial positions where LNS identifies a seasonally adjusted series and LNU identifies a not 
#> seasonally adjusted series. The other values in the series ID code cannot be broken down into meaningful 
#> components. You must use the ln.series file to identify series.
#> 
#> Additional fields in the Series file correspond to each of the mapping files and 
#> information about the period for which the data series are defined.
#> 
#> begin_year         4     1947
#> 
#> begin_period       3     M13
#> 
#> end_year       4     2023
#> 
#> end_period         3     M10
#> 
#> 
#> 
#> 
#> 
#> ================================================================================
#> Section 5 - Data file format and field definitions
#> ================================================================================
#> Data File Structure and Format: The following represents the file format used to 
#> define each data file. Note that the field numbers are for reference only; they 
#> do not exist in the database. Data files are in ASCII text format. Data 
#> elements are separated by tabs; the first record of each file contains the 
#> column headers for the data elements stored in each field. Each record ends 
#> with a new line character. 
#> 
#> The ln.data file is stored in one file:  
#> 
#>  1.  ln.data.1.AllData   - All data
#> 
#> The above data file has the following format:
#> 
#> Field #/Data Element Length      Value(Example)  
#> 
#> 1. series_id       varies    LNU04000000
#> 
#> 2. year             4        2023    
#> 
#> 3. period           3        M10 
#> 
#> 4. value       12        3.6 
#> 
#> 5. footnote_codes      10        It varies
#> 
#> 
#> =================================================================================
#> Section 6 - Mapping file formats and field definitions
#> =================================================================================
#> Mapping File Structure and Format: The following represents the file format used to 
#> define each mapping file. Note that the field numbers are for reference only; they 
#> do not exist in the database. Mapping files are in ASCII text format. Data elements 
#> are separated by tabs. The first record of each file contains the column headers 
#> for the data elements stored in each field. Each record ends with a new line character. 
#> 
#> Each mapping file follows a similar format:
#> 
#> Field #/Data Element     Length      Value (Example)
#> 
#> 1. characteristic code       varies      varies
#> 
#> 2. characteristic text       varies      varies
#> 
#> 
#> For example, the ln.ages mapping file contains
#> 
#> 1. ages_code         2       00
#> 
#> 2. ages_text         17      16 years and over
#> 
#> 
#>  
#> 
# }
```
