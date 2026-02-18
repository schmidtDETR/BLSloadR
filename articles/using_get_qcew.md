# Working with QCEW Data

``` r
library(dplyr)
library(tidyr)
library(gt)
library(sf)
library(ggplot2)
library(BLSloadR)
```

## General Concepts

`BLSloadR` streamlines access to data from the U.S. Bureau of Labor
Statistics. Its primary benefit is in providing data in a handy form so
that it can be manipulated and used to compare data across areas,
periods, and data types. One simple example includes using the data
across areas to calculate percentiles for a particular data element to
compare a single state to the range of experiences across other states.

### General Usage of `get_qcew()`

The Quarterly Census of Employment and Wages is the largest and most
granular dataset accessible with `BLSloadR`. It is created from the
unemployment insurance reports submitted each quarter by employers
covered by the unemployment insurance program, and provides
nearly-complete data about employment and wages in detailed industries
within detailed geographic areas including states, counties, and
metropolitan statistical areas. While programs like Current Employment
Statistics (CES) and Local Area Unemployment Statistics (LAUS) rely on
surveys, the underlying data for the QCEW is administrative records,
making it more complete, but also slower to be produced.

Data retrieved from the QCEW is pulled in a different manner than other
data sources in `BLSloadR` because it streamlines accessing specific
slices of data. The QCEW is a very large data product, so downloading
the entire database would be prohibitively large. The BLS provides a
method to access the data for a single quarter for a single area **or**
a single industry. The
[`get_qcew()`](https://schmidtdetr.github.io/BLSloadR/reference/get_qcew.md)
function maintains the area **or** industry specification while
requesting the sequence of all years between `year_start` and
`year_end`. If not specified, both of these arguments will default to
the year of the date 6 months prior to the system date.

If an `industry_code` is provided, the function will return data for all
available areas for that industry. If an `area_code` is provided, then
the function will return data for all industries in that area.

#### Available Industries

QCEW data includes aggregations based on the North American Industrial
Classification System (NAICS). NAICS codes are structured in a fixed
structure, beginning with 2 digits and up to 6 digits, with each
additional digit providing additional detail. For example, NAICS 72 is
broad enough to include casino hotels, fast food restaurants, RV parks
and more. But as we add digits, we can narrow the categories such that
NAICS 721191 is Bed-and-Breakfast Inns, a much more detailed subset of
businesses.

- NAICS 72 - Accommodation & Food Services

  - NAICS 721 - Accommodation

    - NAICS 7211 - Traveler Accommodation

      - NAICS 72119 - Other Traveler Accommodation

        - NAICS 721191 - Bed-and-Breakfast Inns

A full list of industries from the most recent NAICS is included in the
data provided with BLSloadR in the `ind_lookup` table. Note that NAICS
codes change over time, and prior quarters are **not** revised to match
current codes. The NAICS code for businesses is reviewed periodically
and may change when the primary work activity of a business changes, or
when the NAICS structure changes.

``` r
ind_lookup |> 
  filter(grepl("^72", industry_code)) |> 
  head(10) |> 
  knitr::kable()
```

| industry_code | industry_title                                        | ind_level     | naics_2d | sector | vintage_start | vintage_end |
|:--------------|:------------------------------------------------------|:--------------|:---------|:-------|--------------:|------------:|
| 72            | NAICS 72 Accommodation and food services              | NAICS 2-digit | 72       | 72     |          2022 |        3000 |
| 721           | NAICS 721 Accommodation                               | NAICS 3-digit | 72       | 72     |          2022 |        3000 |
| 7211          | NAICS 7211 Traveler accommodation                     | NAICS 4-digit | 72       | 72     |          2022 |        3000 |
| 72111         | NAICS 72111 Hotels (except casino hotels) and motels  | NAICS 5-digit | 72       | 72     |          2022 |        3000 |
| 721110        | NAICS 721110 Hotels (except casino hotels) and motels | NAICS 6-digit | 72       | 72     |          2022 |        3000 |
| 72112         | NAICS 72112 Casino hotels                             | NAICS 5-digit | 72       | 72     |          2022 |        3000 |
| 721120        | NAICS 721120 Casino hotels                            | NAICS 6-digit | 72       | 72     |          2022 |        3000 |
| 72119         | NAICS 72119 Other traveler accommodation              | NAICS 5-digit | 72       | 72     |          2022 |        3000 |
| 721191        | NAICS 721191 Bed-and-breakfast inns                   | NAICS 6-digit | 72       | 72     |          2022 |        3000 |
| 721199        | NAICS 721199 All other traveler accommodation         | NAICS 6-digit | 72       | 72     |          2022 |        3000 |

#### Available Areas

The areas available in
[`get_qcew()`](https://schmidtdetr.github.io/BLSloadR/reference/get_qcew.md)
range from small and detailed to national data

``` r
unique_areas <- data.frame(area_type = unique(area_lookup$area_type))
knitr::kable(unique_areas, caption = "Unique Area Types in QCEW Data")
```

| area_type                     |
|:------------------------------|
| National                      |
| State                         |
| County                        |
| County Unknown or Undefined   |
| National Subgroup             |
| Micropolitan Statistical Area |
| Metropolitan Statistical Area |
| Combined Statistical Area     |

Unique Area Types in QCEW Data

The `area_lookup` table can be used to identify the code or which you
want to pull data from the QCEW. It is possible to filter the table to
narrower definitions, but caution should be used. For example, the
Abilene-Sweetwater, TX Combined Statistical Area indicates that it is in
Texas, but the `stfips` provided by the BLS is 00. This is because
combined areas may span multiple states. The `specified_region` column
was added to the BLS lookup to help provide a reference to these
multi-state regions for filtering purposes. The `stfips` will only
populate for state or county areas, as these are by definition entirely
within one state.

Comapre the following:

``` r
area_lookup |> 
  filter(stfips == "32") |> 
  knitr::kable()
```

| area_fips | area_title                   | area_type                   | stfips | specified_region |
|:----------|:-----------------------------|:----------------------------|:-------|:-----------------|
| 32000     | Nevada – Statewide           | State                       | 32     | NV               |
| 32001     | Churchill County, Nevada     | County                      | 32     | NV               |
| 32003     | Clark County, Nevada         | County                      | 32     | NV               |
| 32005     | Douglas County, Nevada       | County                      | 32     | NV               |
| 32007     | Elko County, Nevada          | County                      | 32     | NV               |
| 32009     | Esmeralda County, Nevada     | County                      | 32     | NV               |
| 32011     | Eureka County, Nevada        | County                      | 32     | NV               |
| 32013     | Humboldt County, Nevada      | County                      | 32     | NV               |
| 32015     | Lander County, Nevada        | County                      | 32     | NV               |
| 32017     | Lincoln County, Nevada       | County                      | 32     | NV               |
| 32019     | Lyon County, Nevada          | County                      | 32     | NV               |
| 32021     | Mineral County, Nevada       | County                      | 32     | NV               |
| 32023     | Nye County, Nevada           | County                      | 32     | NV               |
| 32027     | Pershing County, Nevada      | County                      | 32     | NV               |
| 32029     | Storey County, Nevada        | County                      | 32     | NV               |
| 32031     | Washoe County, Nevada        | County                      | 32     | NV               |
| 32033     | White Pine County, Nevada    | County                      | 32     | NV               |
| 32510     | Carson City, Nevada          | County                      | 32     | NV               |
| 32999     | Unknown Or Undefined, Nevada | County Unknown or Undefined | 32     | NV               |

``` r
area_lookup |> 
  filter(grepl("NV", specified_region)) |>  
  knitr::kable()
```

| area_fips | area_title                                       | area_type                     | stfips | specified_region |
|:----------|:-------------------------------------------------|:------------------------------|:-------|:-----------------|
| 32000     | Nevada – Statewide                               | State                         | 32     | NV               |
| 32001     | Churchill County, Nevada                         | County                        | 32     | NV               |
| 32003     | Clark County, Nevada                             | County                        | 32     | NV               |
| 32005     | Douglas County, Nevada                           | County                        | 32     | NV               |
| 32007     | Elko County, Nevada                              | County                        | 32     | NV               |
| 32009     | Esmeralda County, Nevada                         | County                        | 32     | NV               |
| 32011     | Eureka County, Nevada                            | County                        | 32     | NV               |
| 32013     | Humboldt County, Nevada                          | County                        | 32     | NV               |
| 32015     | Lander County, Nevada                            | County                        | 32     | NV               |
| 32017     | Lincoln County, Nevada                           | County                        | 32     | NV               |
| 32019     | Lyon County, Nevada                              | County                        | 32     | NV               |
| 32021     | Mineral County, Nevada                           | County                        | 32     | NV               |
| 32023     | Nye County, Nevada                               | County                        | 32     | NV               |
| 32027     | Pershing County, Nevada                          | County                        | 32     | NV               |
| 32029     | Storey County, Nevada                            | County                        | 32     | NV               |
| 32031     | Washoe County, Nevada                            | County                        | 32     | NV               |
| 32033     | White Pine County, Nevada                        | County                        | 32     | NV               |
| 32510     | Carson City, Nevada                              | County                        | 32     | NV               |
| 32999     | Unknown Or Undefined, Nevada                     | County Unknown or Undefined   | 32     | NV               |
| C1618     | Carson City, NV MSA                              | Metropolitan Statistical Area | 00     | NV               |
| C2122     | Elko, NV MicroSA                                 | Micropolitan Statistical Area | 00     | NV               |
| C2198     | Fallon, NV MicroSA                               | Micropolitan Statistical Area | 00     | NV               |
| C2228     | Fernley, NV MicroSA                              | Micropolitan Statistical Area | 00     | NV               |
| C2382     | Gardnerville Ranchos, NV-CA MicroSA              | Micropolitan Statistical Area | 00     | NV-CA            |
| C2982     | Las Vegas-Henderson-North Las Vegas, NV MSA      | Metropolitan Statistical Area | 00     | NV               |
| C3722     | Pahrump, NV MicroSA                              | Micropolitan Statistical Area | 00     | NV               |
| C3990     | Reno, NV MSA                                     | Metropolitan Statistical Area | 00     | NV               |
| C4908     | Winnemucca, NV MicroSA                           | Micropolitan Statistical Area | 00     | NV               |
| CS332     | Las Vegas-Henderson, NV CSA                      | Combined Statistical Area     | 00     | NV               |
| CS456     | Reno-Carson City-Gardnerville Ranchos, NV-CA CSA | Combined Statistical Area     | 00     | NV-CA            |

#### Using the `add_lookups` Argument

The
[`get_qcew()`](https://schmidtdetr.github.io/BLSloadR/reference/get_qcew.md)
function includes the `add_lookups` argument to join the `ind_lookup`
and `area_lookup` tables to the results of the QCEW data retrieved from
the BLS. This can make subsequent filtering and comparisons more
convenient. For example, this lets us quickly look at the aggregates for
Metal Ore Mining in Nevada.

``` r
metal_ore_mining <- get_qcew(industry_code = "2122", year_start = 2024, year_end = 2024, add_lookups = TRUE)

metal_ore_mining |>
  filter(specified_region == "NV") |> 
  head(20) |> 
  knitr::kable()
```

| area_fips | industry_code | own_code | agglvl_code | size_code | year | qtr | disclosure_code | qtrly_estabs | month1_emplvl | month2_emplvl | month3_emplvl | total_qtrly_wages | taxable_qtrly_wages | qtrly_contributions | avg_wkly_wage | lq_disclosure_code | lq_qtrly_estabs | lq_month1_emplvl | lq_month2_emplvl | lq_month3_emplvl | lq_total_qtrly_wages | lq_taxable_qtrly_wages | lq_qtrly_contributions | lq_avg_wkly_wage | oty_disclosure_code | oty_qtrly_estabs_chg | oty_qtrly_estabs_pct_chg | oty_month1_emplvl_chg | oty_month1_emplvl_pct_chg | oty_month2_emplvl_chg | oty_month2_emplvl_pct_chg | oty_month3_emplvl_chg | oty_month3_emplvl_pct_chg | oty_total_qtrly_wages_chg | oty_total_qtrly_wages_pct_chg | oty_taxable_qtrly_wages_chg | oty_taxable_qtrly_wages_pct_chg | oty_qtrly_contributions_chg | oty_qtrly_contributions_pct_chg | oty_avg_wkly_wage_chg | oty_avg_wkly_wage_pct_chg | date       | industry_title              | ind_level     | naics_2d | sector | vintage_start | vintage_end | area_title               | area_type | stfips | specified_region |
|:----------|:--------------|---------:|------------:|----------:|-----:|----:|:----------------|-------------:|--------------:|--------------:|--------------:|------------------:|--------------------:|--------------------:|--------------:|:-------------------|----------------:|-----------------:|-----------------:|-----------------:|---------------------:|-----------------------:|-----------------------:|-----------------:|:--------------------|---------------------:|-------------------------:|----------------------:|--------------------------:|----------------------:|--------------------------:|----------------------:|--------------------------:|--------------------------:|------------------------------:|----------------------------:|--------------------------------:|----------------------------:|--------------------------------:|----------------------:|--------------------------:|:-----------|:----------------------------|:--------------|:---------|:-------|--------------:|------------:|:-------------------------|:----------|:-------|:-----------------|
| 32000     | 2122          |        5 |          56 |         0 | 2024 |   1 |                 |           45 |         10607 |         10734 |         10649 |         372813062 |           329698565 |             3420686 |          2689 |                    |            9.39 |            23.90 |            24.17 |            24.07 |                29.98 |                  21.49 |                  24.06 |             1.25 |                     |                   -6 |                    -11.8 |                   -83 |                      -0.8 |                   -43 |                      -0.4 |                  -132 |                      -1.2 |                   4973350 |                           1.4 |                     3205498 |                             1.0 |                     -581918 |                           -14.5 |                    57 |                       2.2 | 2024-01-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Nevada – Statewide       | State     | 32     | NV               |
| 32000     | 2122          |        5 |          56 |         0 | 2024 |   2 |                 |           43 |         10631 |         10676 |         10732 |         303940238 |            96436988 |             1062253 |          2189 |                    |            8.90 |            23.77 |            23.77 |            23.70 |                27.78 |                   9.28 |                   9.98 |             1.17 |                     |                   -8 |                    -15.7 |                  -165 |                      -1.5 |                  -105 |                      -1.0 |                   -31 |                      -0.3 |                  12848357 |                           4.4 |                    -6330548 |                            -6.2 |                     -234596 |                           -18.1 |                   112 |                       5.4 | 2024-04-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Nevada – Statewide       | State     | 32     | NV               |
| 32000     | 2122          |        5 |          56 |         0 | 2024 |   3 |                 |           45 |         10794 |         10726 |         10630 |         337766012 |            27749622 |              320069 |          2424 |                    |            9.45 |            23.53 |            23.44 |            23.39 |                29.54 |                   9.00 |                   8.64 |             1.26 |                     |                   -4 |                     -8.2 |                   194 |                       1.8 |                   196 |                       1.9 |                    60 |                       0.6 |                  31504295 |                          10.3 |                    -1460354 |                            -5.0 |                      -68955 |                           -17.7 |                   194 |                       8.7 | 2024-07-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Nevada – Statewide       | State     | 32     | NV               |
| 32000     | 2122          |        5 |          56 |         0 | 2024 |   4 |                 |           46 |         10686 |         10630 |         10649 |         308559477 |            21302193 |              269313 |          2228 |                    |            9.70 |            23.34 |            23.44 |            23.53 |                27.24 |                  10.91 |                  10.18 |             1.16 |                     |                    1 |                      2.2 |                    88 |                       0.8 |                    62 |                       0.6 |                    91 |                       0.9 |                  24325439 |                           8.6 |                      708642 |                             3.4 |                       -5044 |                            -1.8 |                   160 |                       7.7 | 2024-10-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Nevada – Statewide       | State     | 32     | NV               |
| 32007     | 2122          |        5 |          76 |         0 | 2024 |   1 |                 |            7 |           197 |           196 |           193 |           6092327 |             5657244 |               90068 |          2399 |                    |          112.08 |            31.15 |            31.14 |            30.57 |                35.69 |                  25.64 |                  48.38 |             1.15 |                     |                   -5 |                    -41.7 |                  -540 |                     -73.3 |                  -538 |                     -73.3 |                  -537 |                     -73.6 |                 -17287489 |                         -73.9 |                   -14692281 |                           -72.2 |                     -179297 |                           -66.6 |                   -52 |                      -2.1 | 2024-01-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Elko County, Nevada      | County    | 32     | NV               |
| 32007     | 2122          |        5 |          76 |         0 | 2024 |   2 |                 |            6 |           195 |           186 |           182 |           7276397 |             2530474 |               42172 |          2983 |                    |           95.37 |            30.69 |            29.02 |            27.75 |                48.82 |                  17.86 |                  30.71 |             1.68 |                     |                   -6 |                    -50.0 |                  -453 |                     -69.9 |                  -437 |                     -70.1 |                  -276 |                     -60.3 |                 -10386309 |                         -58.8 |                    -4063600 |                           -61.6 |                      -48404 |                           -53.4 |                   626 |                      26.6 | 2024-04-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Elko County, Nevada      | County    | 32     | NV               |
| 32007     | 2122          |        5 |          76 |         0 | 2024 |   3 |                 |            5 |           184 |           185 |           181 |           5894032 |              701630 |               11693 |          2473 |                    |           80.37 |            27.50 |            27.64 |            27.70 |                36.35 |                  16.41 |                  24.45 |             1.32 |                     |                   -5 |                    -50.0 |                  -117 |                     -38.9 |                  -123 |                     -39.9 |                  -120 |                     -39.9 |                  -3273140 |                         -35.7 |                     -405892 |                           -36.6 |                       -6325 |                           -35.1 |                   148 |                       6.4 | 2024-07-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Elko County, Nevada      | County    | 32     | NV               |
| 32007     | 2122          |        5 |          76 |         0 | 2024 |   4 |                 |            5 |           175 |           174 |           180 |           4981136 |              377239 |                6488 |          2173 |                    |           79.50 |            26.83 |            27.11 |            28.19 |                33.15 |                  14.32 |                  19.97 |             1.21 |                     |                   -3 |                    -37.5 |                  -126 |                     -41.9 |                  -113 |                     -39.4 |                  -111 |                     -38.1 |                  -3304469 |                         -39.9 |                     -364039 |                           -49.1 |                       -6124 |                           -48.6 |                    -2 |                      -0.1 | 2024-10-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Elko County, Nevada      | County    | 32     | NV               |
| 32009     | 2122          |        5 |          76 |         0 | 2024 |   1 | N               |            3 |             0 |             0 |             0 |                 0 |                   0 |                   0 |             0 | N                  |         2846.05 |             0.00 |             0.00 |             0.00 |                 0.00 |                   0.00 |                   0.00 |             0.00 | N                   |                    0 |                      0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                         0 |                           0.0 |                           0 |                             0.0 |                           0 |                             0.0 |                     0 |                       0.0 | 2024-01-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Esmeralda County, Nevada | County    | 32     | NV               |
| 32009     | 2122          |        5 |          76 |         0 | 2024 |   2 | N               |            3 |             0 |             0 |             0 |                 0 |                   0 |                   0 |             0 | N                  |         2925.47 |             0.00 |             0.00 |             0.00 |                 0.00 |                   0.00 |                   0.00 |             0.00 | N                   |                    0 |                      0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                         0 |                           0.0 |                           0 |                             0.0 |                           0 |                             0.0 |                     0 |                       0.0 | 2024-04-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Esmeralda County, Nevada | County    | 32     | NV               |
| 32009     | 2122          |        5 |          76 |         0 | 2024 |   3 | N               |            3 |             0 |             0 |             0 |                 0 |                   0 |                   0 |             0 | N                  |         2939.57 |             0.00 |             0.00 |             0.00 |                 0.00 |                   0.00 |                   0.00 |             0.00 | N                   |                    0 |                      0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                         0 |                           0.0 |                           0 |                             0.0 |                           0 |                             0.0 |                     0 |                       0.0 | 2024-07-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Esmeralda County, Nevada | County    | 32     | NV               |
| 32009     | 2122          |        5 |          76 |         0 | 2024 |   4 |                 |            3 |            21 |            26 |            25 |            473900 |              122134 |                5162 |          1519 |                    |         2940.86 |           255.19 |           318.19 |           313.39 |               267.19 |                 797.00 |                2216.43 |             0.90 | N                   |                    1 |                     50.0 |                     0 |                       0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                         0 |                           0.0 |                           0 |                             0.0 |                           0 |                             0.0 |                     0 |                       0.0 | 2024-10-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Esmeralda County, Nevada | County    | 32     | NV               |
| 32011     | 2122          |        5 |          76 |         0 | 2024 |   1 | N               |            2 |             0 |             0 |             0 |                 0 |                   0 |                   0 |             0 | N                  |          813.16 |             0.00 |             0.00 |             0.00 |                 0.00 |                   0.00 |                   0.00 |             0.00 | N                   |                    0 |                      0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                         0 |                           0.0 |                           0 |                             0.0 |                           0 |                             0.0 |                     0 |                       0.0 | 2024-01-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Eureka County, Nevada    | County    | 32     | NV               |
| 32011     | 2122          |        5 |          76 |         0 | 2024 |   2 | N               |            2 |             0 |             0 |             0 |                 0 |                   0 |                   0 |             0 | N                  |          846.36 |             0.00 |             0.00 |             0.00 |                 0.00 |                   0.00 |                   0.00 |             0.00 | N                   |                    0 |                      0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                         0 |                           0.0 |                           0 |                             0.0 |                           0 |                             0.0 |                     0 |                       0.0 | 2024-04-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Eureka County, Nevada    | County    | 32     | NV               |
| 32011     | 2122          |        5 |          76 |         0 | 2024 |   3 | N               |            3 |             0 |             0 |             0 |                 0 |                   0 |                   0 |             0 | N                  |         1300.19 |             0.00 |             0.00 |             0.00 |                 0.00 |                   0.00 |                   0.00 |             0.00 | N                   |                    1 |                     50.0 |                     0 |                       0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                         0 |                           0.0 |                           0 |                             0.0 |                           0 |                             0.0 |                     0 |                       0.0 | 2024-07-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Eureka County, Nevada    | County    | 32     | NV               |
| 32011     | 2122          |        5 |          76 |         0 | 2024 |   4 | N               |            3 |             0 |             0 |             0 |                 0 |                   0 |                   0 |             0 | N                  |         1252.59 |             0.00 |             0.00 |             0.00 |                 0.00 |                   0.00 |                   0.00 |             0.00 | N                   |                    1 |                     50.0 |                     0 |                       0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                         0 |                           0.0 |                           0 |                             0.0 |                           0 |                             0.0 |                     0 |                       0.0 | 2024-10-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Eureka County, Nevada    | County    | 32     | NV               |
| 32013     | 2122          |        5 |          76 |         0 | 2024 |   1 | N               |            6 |             0 |             0 |             0 |                 0 |                   0 |                   0 |             0 | N                  |          280.51 |             0.00 |             0.00 |             0.00 |                 0.00 |                   0.00 |                   0.00 |             0.00 | N                   |                    2 |                     50.0 |                     0 |                       0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                         0 |                           0.0 |                           0 |                             0.0 |                           0 |                             0.0 |                     0 |                       0.0 | 2024-01-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Humboldt County, Nevada  | County    | 32     | NV               |
| 32013     | 2122          |        5 |          76 |         0 | 2024 |   2 | N               |            6 |             0 |             0 |             0 |                 0 |                   0 |                   0 |             0 | N                  |          282.12 |             0.00 |             0.00 |             0.00 |                 0.00 |                   0.00 |                   0.00 |             0.00 | N                   |                    2 |                     50.0 |                     0 |                       0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                         0 |                           0.0 |                           0 |                             0.0 |                           0 |                             0.0 |                     0 |                       0.0 | 2024-04-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Humboldt County, Nevada  | County    | 32     | NV               |
| 32013     | 2122          |        5 |          76 |         0 | 2024 |   3 | N               |            7 |             0 |             0 |             0 |                 0 |                   0 |                   0 |             0 | N                  |          329.35 |             0.00 |             0.00 |             0.00 |                 0.00 |                   0.00 |                   0.00 |             0.00 | N                   |                    3 |                     75.0 |                     0 |                       0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                         0 |                           0.0 |                           0 |                             0.0 |                           0 |                             0.0 |                     0 |                       0.0 | 2024-07-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Humboldt County, Nevada  | County    | 32     | NV               |
| 32013     | 2122          |        5 |          76 |         0 | 2024 |   4 | N               |            7 |             0 |             0 |             0 |                 0 |                   0 |                   0 |             0 | N                  |          327.44 |             0.00 |             0.00 |             0.00 |                 0.00 |                   0.00 |                   0.00 |             0.00 | N                   |                    2 |                     40.0 |                     0 |                       0.0 |                     0 |                       0.0 |                     0 |                       0.0 |                         0 |                           0.0 |                           0 |                             0.0 |                           0 |                             0.0 |                     0 |                       0.0 | 2024-10-01 | NAICS 2122 Metal ore mining | NAICS 4-digit | 21       | 21     |          2022 |        3000 | Humboldt County, Nevada  | County    | 32     | NV               |

### Working with QCEW Data

#### Disclosed vs. Suppressed Data

As we look at Metal Ore Mining in Nevada, it’s apparent there is not a
lot of data. The BLS suppresses data which is too specific and might
reveal the details of individual businesses. In using the QCEW, we must
remember that no data may not be the absence of data, but the absence of
**releasable** data. We can use the `disclosure_code` columns in the
returned data to help weed out these suppressed values, but they will
tell us when there **is** data but it is not **released.**

Let’s look at Metal Ore Mining in Esmeralda County, Nevada:

``` r
metal_ore_mining |> 
  filter(area_fips == "32009") |> 
  select(area_title, year, qtr, disclosure_code:avg_wkly_wage) |> 
  knitr::kable()
```

| area_title               | year | qtr | disclosure_code | qtrly_estabs | month1_emplvl | month2_emplvl | month3_emplvl | total_qtrly_wages | taxable_qtrly_wages | qtrly_contributions | avg_wkly_wage |
|:-------------------------|-----:|----:|:----------------|-------------:|--------------:|--------------:|--------------:|------------------:|--------------------:|--------------------:|--------------:|
| Esmeralda County, Nevada | 2024 |   1 | N               |            3 |             0 |             0 |             0 |                 0 |                   0 |                   0 |             0 |
| Esmeralda County, Nevada | 2024 |   2 | N               |            3 |             0 |             0 |             0 |                 0 |                   0 |                   0 |             0 |
| Esmeralda County, Nevada | 2024 |   3 | N               |            3 |             0 |             0 |             0 |                 0 |                   0 |                   0 |             0 |
| Esmeralda County, Nevada | 2024 |   4 |                 |            3 |            21 |            26 |            25 |            473900 |              122134 |                5162 |          1519 |

Here we can see that in 2024, quarters 1-3 were suppressed, as the
`disclosure_code` is “N” but quarter 4 is available. If we were to
simply average the employment or wage data while ignoring this, we would
get an average of 5-6 employees. Note that this can be true even for
larger areas and businesses - if a large business represents too-large a
share of an area, significant employment and wages may end up
suppressed.

#### Quarterly vs. Annual Data

The QCEW is built from quarterly data, so the default type of data
provided by
[`get_qcew()`](https://schmidtdetr.github.io/BLSloadR/reference/get_qcew.md)
is quarterly data. However, annual data is also available from the BLS -
in some cases, this may simplify the analysis by removing seasonality
and the need to look across multiple months within a quarter. To
retrieve annual data, set `period_type = "year"` in your function call.
Here, let’s pull the annual data and then use it to see where the
highest concentrations of businesses engaged in Metal Ore Mining are
located:

``` r
metal_ore_mining_annual <- get_qcew(industry_code = "2122", year_start = 2024, year_end = 2024, add_lookups = TRUE, period_type = "year")

metal_ore_mining_annual |>
  arrange(-lq_annual_avg_estabs) |>
  head(5) |>
  select(area_title, lq_annual_avg_estabs, annual_avg_estabs)
#> Key: <area_fips>
#>                           area_title lq_annual_avg_estabs annual_avg_estabs
#>                               <char>                <num>             <int>
#> 1:          Esmeralda County, Nevada              2945.13                 3
#> 2:             Eureka County, Nevada               836.27                 2
#> 3: Yukon-Koyukuk Census Area, Alaska               762.17                 8
#> 4:            Mineral County, Nevada               752.64                 3
#> 5:           Pershing County, Nevada               599.45                 3
```

## Specific Applications of QCEW

### Mapping QCEW

Because QCEW data is built from a very deep administrative data set, it
may be able to provide granular data which is unavailable from other
surveys. The data within QCEW includes state, county, and metropolitan
area aggregations, and can be combined with shapefiles available from
the U.S. Census Bureau to map and explore data across the country. The
example below uses the `tigris` package to access metropolitan area
shapefiles using the `core_based_statistical_areas()` function,
manipulates the unique identifiers provided in the QCEW data to match
those in the Census data, and then maps the results using
[`mapgl::maplibre_view()`](https://walker-data.com/mapgl/reference/maplibre_view.html).

``` r
library(mapgl)

msa_shapes <- tigris::core_based_statistical_areas()
#>   |                                                                              |                                                                      |   0%  |                                                                              |                                                                      |   1%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |==                                                                    |   4%  |                                                                              |===                                                                   |   4%  |                                                                              |===                                                                   |   5%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |============                                                          |  16%  |                                                                              |============                                                          |  17%  |                                                                              |============                                                          |  18%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |==============                                                        |  21%  |                                                                              |===============                                                       |  21%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |=================                                                     |  24%  |                                                                              |==================                                                    |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |=====================                                                 |  31%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |========================                                              |  34%  |                                                                              |========================                                              |  35%  |                                                                              |=========================                                             |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  39%  |                                                                              |============================                                          |  40%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |===============================                                       |  44%  |                                                                              |===============================                                       |  45%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |=====================================                                 |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |=======================================                               |  55%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |==========================================                            |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |=============================================                         |  64%  |                                                                              |=============================================                         |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |===================================================                   |  74%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  76%  |                                                                              |======================================================                |  78%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  79%  |                                                                              |========================================================              |  80%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |==============================================================        |  88%  |                                                                              |===============================================================       |  90%  |                                                                              |===============================================================       |  91%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |==================================================================    |  94%  |                                                                              |==================================================================    |  95%  |                                                                              |===================================================================   |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================|  99%  |                                                                              |======================================================================| 100%

ambulatory_services <- get_qcew(period_type = "year",
                                year_start = 2024, year_end = 2024,
                                industry_code = "621") |> 
  filter(area_type %in% c("Metropolitan Statistical Area", "Micropolitan Statistical Area"),
         disclosure_code != "N") |> 
  mutate(GEOID = substr(area_fips,2,5),
         GEOID = paste0(GEOID,"0")) |> 
  left_join(msa_shapes, by = "GEOID") |> 
  st_as_sf() |> 
  select(area_title, annual_avg_wkly_wage, annual_avg_estabs, annual_avg_emplvl)

maplibre_view(ambulatory_services, column = "annual_avg_wkly_wage")
```
