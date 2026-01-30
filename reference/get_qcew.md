# Get QCEW Data Slices

This function pulls data from the BLS QCEW Open Data Access CSV Data
Slices. It iterates over specified years and quarters (or annual data)
to retrieve industry-specific or area-specific data tables and merges
them into a single data.table. Optionally, it joins internal package
lookup tables for industry and area descriptions.

## Usage

``` r
get_qcew(
  period_type = "quarter",
  year_start = NULL,
  year_end = NULL,
  industry_code = NULL,
  area_code = NULL,
  add_lookups = TRUE,
  silently = FALSE
)
```

## Arguments

- period_type:

  Character. Either "quarter" or "year". Defaults to "quarter".

- year_start:

  Numeric. The first year to retrieve data for. Defaults to the year of
  the date 6 months prior to the current system date.

- year_end:

  Numeric. The last year to retrieve data for. Defaults to the year of
  the date 6 months prior to the current system date.

- industry_code:

  Character. The NAICS industry code (e.g., "10", "31-33"). Constructs a
  URL for an Industry Data Slice. Mutually exclusive with \`area_code\`.

- area_code:

  Character. The QCEW area code (e.g., "US000", "32000", "C2982").
  Constructs a URL for an Area Data Slice. Mutually exclusive with
  \`industry_code\`.

- add_lookups:

  Logical. If `TRUE`, joins the package's `ind_lookup` and `area_lookup`
  tables to the results to provide descriptive labels. Defaults to
  `TRUE`.

- silently:

  Logical. If `TRUE`, suppresses status messages about the URLs being
  accessed. Defaults to `FALSE`.

## Value

A combined data.table containing the requested QCEW data, optionally
merged with lookup columns and a calculated `date` column. The data
layout is different for quarterly or annual data files set by the
\`period_type\` argument.

For Quarterly files:

- area_fips - Character. Area code of row. Included \`area_lookup\` data
  file contains mapping information.

- industry_code - Character. NAICS, Supersector, Cluster, or Total All
  Industries code. Numeric characters as a string to preserve examining
  the structure heirarchy.

- own_code - Integer. Values of 0-5 to designate ownership. See
  definitions at
  <https://www.bls.gov/cew/classifications/ownerships/ownership-titles.htm>

- agglvl_code - Integer. Two digit code identifying the level of
  aggregation. See definitons at
  <https://www.bls.gov/cew/classifications/aggregation/agg-level-titles.htm>

- size_code - Integer. Single-digit code representing the size of
  establishments. See definitions at
  <https://www.bls.gov/cew/classifications/size/size-titles.htm>

- year Integer. Four-digit calendar year for the returned data.

- qtr Integer. The calendar quarter of the data.

- disclosure_code Character. Values are either a blank string on "N".
  Values of N do not disclose employment or wages to maintain
  confidentiality.

- qtryly_estabs Integer. The number of business establishments
  (worksites) for the industry in the area in the quarter.

- month1_emplvl Integer. Employment in the first month of the quarter
  (January, April, July, or October).

- month2_emplvl Integer. Employment in the second month of the quarter
  (February, May, August, November).

- month3_emplvl Integer. Employment in the third month of the quarter
  (March, June, September, December).

- total_qtrly_wages Ingeger64. Total wages paid during the quarter.

- taxable_qtrly_wages Ingeger64. Wages subject to unemployment insurance
  (UI) taxes during the quarter. Note - wages subject to UI vary by
  state and will follow different seasonal patterns as a result.

- qtrly_contributions Integer. UI taxes (Contributions) paid by
  employers for this quarter. Note - UI tax policy varies by state.

- avg_wkly_wage Integer. Average weekly wage during the quarter (Total
  wages divided by average employment, divided by 13).

- lq_disclosure_code Character. Blank or "N". Values of "N" will
  suppress location quotient data for confidentiality.

- lq_qtrly_estabs Numeric. Location quotient of establishments relative
  to the U.S.

- lq_month1_emplvl Numeric. Location quotient of month 1 employment
  relative to the U.S.

- lq_month2_emplvl Numeric. Location quotient of month 2 employment
  relative to the U.S.

- lq_month3_emplvl Numeric. Location quotient of month 3 employment
  relative to the U.S.

- lq_total_qtrly_wages Numeric. Location quotient of total wages
  relative to the U.S.

- lq_taxable_qtrly_wages Numeric. Location quotient of taxable quarterly
  wages relative to the U.S.

- lq_qtrly_contributions Numeric. Location quotient of quarterly UI
  taxes paid relative to the U.S.

- lq_avg_wkly_wage Numeric. Location quotient of average weekly wages
  relative to the U.S.

- oty_disclosure_code Character. Blank or "N". Values of "N" will
  suppress over-the-year data for confidentiality.

- oty_qtrly_estabs_chg Numeric. Over-the-year change in establishments.

- oty_qtrly_estabs_pct_chg Numeric. Over-the-year percent change in
  establishments.

- oty_month1_emplvl_chg Numeric. Over-the-year change in month 1
  employment.

- oty_month1_emplvl_pct_chg Numeric. Over-the-year percent change in
  month 1 employment.

- oty_month2_emplvl_chg Numeric. Over-the-year change in month 2
  employment.

- oty_month2_emplvl_pct_chg Numeric. Over-the-year percent change in
  month 2 employment.

- oty_month3_emplvl_chg Numeric. Over-the-year change in month 3
  employment.

- oty_month3_emplvl_pct_chg Numeric. Over-the-year percent change in
  month 3 employment.

- oty_total_qtrly_wages_chg Numeric. Over-the-year change in total
  wages.

- oty_total_qtrly_wages_pct_chg Numeric. Over-the-year percent change in
  total wages.

- oty_taxable_qtrly_wages_chg Numeric. Over-the-year change in taxable
  quarterly wages.

- oty_taxable_qtrly_wages_pct_chg Numeric. Over-the-year percent change
  in taxable quarterly wages.

- oty_qtrly_contributions_chg Numeric. Over-the-year change in quarterly
  UI taxes paid.

- oty_qtrly_contributions_pct_chg Numeric. Over-the-year percent change
  in quarterly UI taxes paid.

- oty_avg_wkly_wage_chg Numeric. Over-the-year change in average weekly
  wages.

- oty_avg_wkly_wage_pct_chg Numeric. Over-the-year percent change in
  average weekly wages.

- date Date. Calculated calendar date based on year and quarter.
  Reflects first day of the quarter.

- industry_title Character. Added based on industry_code

- ind_level Character. Description of the level of aggregation based on
  the industry_code.

- naics_2d Character. First two characters in the industry_code, useful
  for identifying industries.

- sector Character. Similar to naics_2d, but for industries like
  Manufacturing which have multiple two digit NAICS codes, this will
  span those groupings, for example "31-33"

- vintage_start. Integer. Calendar year of the earliest vintage for this
  industry_code. NAICS codes are updated every 5 years. When using this
  industry codes from before this date, these titles may not exist or
  may be incorrect.

- vintage_end. Integer. Calendar year of the last year this industry
  code was used. Years after this point should not contain this industry
  code. Set to 3000 for current data.

- area_title Character. Area description based on area_fips as provided
  by the BLS.

- area_type Character. Description of the type of area based on the
  area_title. More consistent naming and grouping than BLS data.

- stfips Character. The two-digit FIPS code of the state containing a
  given area. Set to "00" for multi-state regions.

- specified_region. Either a two-character US Postal Service
  abbreviation for the state containing an area or a hyphenated list of
  such codes for multi-state areas.

For Annual files:

- area_fips - Character. Area code of row. Included \`area_lookup\` data
  file contains mapping information.

- industry_code - Character. NAICS, Supersector, Cluster, or Total All
  Industries code. Numeric characters as a string to preserve examining
  the structure heirarchy.

- own_code - Integer. Values of 0-5 to designate ownership. See
  definitions at
  <https://www.bls.gov/cew/classifications/ownerships/ownership-titles.htm>

- agglvl_code - Integer. Two digit code identifying the level of
  aggregation. See definitons at
  <https://www.bls.gov/cew/classifications/aggregation/agg-level-titles.htm>

- size_code - Integer. Single-digit code representing the size of
  establishments. See definitions at
  <https://www.bls.gov/cew/classifications/size/size-titles.htm>

- year Integer. Four-digit calendar year for the returned data.

- qtr Character. Set to "A" to represent annual data.

- disclosure_code Character. Values are either a blank string on "N".
  Values of N do not disclose employment or wages to maintain
  confidentiality.

- annual_avg_estabs Integer. The average number of business
  establishments (worksites) for the industry in the area for the year.

- annual_avg_emplvl Integer. The average monthly employment level in a
  given year.

- total_annual_wages Ingeger64. Total wages paid during the year.

- taxable_annual_wages Ingeger64. Wages subject to unemployment
  insurance (UI) taxes during the year. Note - wages subject to UI vary
  by state and will follow different seasonal patterns as a result.

- annual_contributions Integer. UI taxes (Contributions) paid by
  employers for this year. Note - UI tax policy varies by state.

- annual_avg_wkly_wage Integer. Average weekly wage during the year
  (Total wages divided by average employment, divided by 52).

- avg_annual_pay Integer. Average annual pay during the year.

- lq_disclosure_code Character. Blank or "N". Values of "N" will
  suppress location quotient data for confidentiality.

- lq_annual_avg_estabs Numeric. Location quotient of establishments
  relative to the U.S.

- lq_annual_avg_emplvl Numeric. Location quotient of annual employment
  relative to the U.S.

- lq_total_annual_wages Numeric. Location quotient of total wages
  relative to the U.S.

- lq_taxable_annual_wages Numeric. Location quotient of taxable annual
  wages relative to the U.S.

- lq_annual_contributions Numeric. Location quotient of annual UI taxes
  paid relative to the U.S.

- lq_annual_avg_wkly_wage Numeric. Location quotient of average weekly
  wages relative to the U.S.

- lq_avg_annual_pay Numeric. Location quotient of average annual pay
  relative to the U.S.

- oty_disclosure_code Character. Blank or "N". Values of "N" will
  suppress over-the-year data for confidentiality.

- oty_annual_avg_estabs_chg Integer. Over-the-year change in
  establishments.

- oty_annual_avg_estabs_pct_chg Numeric. Over-the-year percent change in
  establishments.

- oty_annual_avg_emplvl_chg Integer. Over-the-year change in average
  annual employment.

- oty_annual_avg_emplvl_pct_chg Numeric. Over-the-year percent change in
  average annual employment.

- oty_total_annual_wages_chg Integer. Over-the-year change in total
  wages.

- oty_total_annual_wages_pct_chg Numeric. Over-the-year percent change
  in total wages.

- oty_taxable_annual_wages_chg Integer. Over-the-year change in taxable
  annual wages.

- oty_taxable_annual_wages_pct_chg Numeric. Over-the-year percent change
  in taxable annual wages.

- oty_annual_contributions_chg Integer. Over-the-year change in annual
  UI taxes paid.

- oty_annual_contributions_pct_chg Numeric. Over-the-year percent change
  in annual UI taxes paid.

- oty_annual_avg_wkly_wage_chg Integer. Over-the-year change in average
  weekly wages.

- oty_annual_avg_wkly_wage_pct_chg Numeric. Over-the-year percent change
  in average weekly wages.

- oty_avg_annual_pay_chg Integer. Over-the-year change in average annual
  pay.

- oty_avg_annual_pay_pct_chg Numeric. Over-the-year percent change in
  average annual pay.

- date Date. Calculated calendar date based on year and quarter.
  Reflects first day of the quarter.

- industry_title Character. Added based on industry_code

- ind_level Character. Description of the level of aggregation based on
  the industry_code.

- naics_2d Character. First two characters in the industry_code, useful
  for identifying industries.

- sector Character. Similar to naics_2d, but for industries like
  Manufacturing which have multiple two digit NAICS codes, this will
  span those groupings, for example "31-33"

- vintage_start. Integer. Calendar year of the earliest vintage for this
  industry_code. NAICS codes are updated every 5 years. When using this
  industry codes from before this date, these titles may not exist or
  may be incorrect.

- vintage_end. Integer. Calendar year of the last year this industry
  code was used. Years after this point should not contain this industry
  code. Set to 3000 for current data.

- area_title Character. Area description based on area_fips as provided
  by the BLS.

- area_type Character. Description of the type of area based on the
  area_title. More consistent naming and grouping than BLS data.

- stfips Character. The two-digit FIPS code of the state containing a
  given area. Set to "00" for multi-state regions.

- specified_region. Either a two-character US Postal Service
  abbreviation for the state containing an area or a hyphenated list of
  such codes for multi-state areas.

## Examples

``` r
# \donttest{
# Get quarterly data for "Total, all industries" (Code 10)
# Includes industry/area descriptions and a date column by default
dt_default <- get_qcew(industry_code = "10")
#> Accessing: https://data.bls.gov/cew/data/api/2025/1/industry/10.csv
#> Accessing: https://data.bls.gov/cew/data/api/2025/2/industry/10.csv
#> Accessing: https://data.bls.gov/cew/data/api/2025/3/industry/10.csv
#> Warning: 2025 Q3 is not found (Status 404)
#> Accessing: https://data.bls.gov/cew/data/api/2025/4/industry/10.csv
#> Warning: 2025 Q4 is not found (Status 404)

# Get annual data for Nevada (Code 32000) for 2023 without lookups or messages
dt_year <- get_qcew(period_type = "year",
                    year_start = 2023,
                    year_end = 2023,
                    area_code = "32000",
                    add_lookups = FALSE,
                    silently = TRUE)
# }
```
