
### Data Analysis 2 | Assignment 1
This repository contains our work to complete the team assignment for the ECBS5140 - Data Analysis 1 course at CEU.

## Data Source and Variable Description

The data for this project comes from two major sources:

1. COVID-19 related country-level metrics | [The official GitHub account of Center for Systems Science and Engineering at Johns Hopkins University link] (https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data)
2. 2019 Population data for countries | [World Bank's World Development Indicators in DataBank link] (https://databank.worldbank.org/reports.aspx?source=2&series=SP.POP.TOTL&country=)

Data was accessed using R via URL and R's WDI package.

# Data Cleaning

1. Get rid of variables that are unnecessary for the analysis such as FIPS, Admin2, Last_Update, Lat, Long, Combined_Key, Incidence Rate, Case.Fatality Ratio.
These are mainly administrative and calculated fields.
2. Aggregate to have country-level data using summation.
3. In the population data remove regional observations.
4. Merge the two data table (Population and COVID-19 data).
5. Resolve country name conflicts.
6. Remove rows that have missing values in any field.







# Variable Description of Cleaned Data

| variable   | unit_of_measurement | type                 | data_type | description                                                                                                                                                                                                                                           | example |
|------------|---------------------|----------------------|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|
| country    | NA                  | qualitative, nominal | string    | the specific country to which   COVID metrics and population data belongs                                                                                                                                                                             | Austria |
| confirmed  | case                | quantitative, ratio  | integer   | the number of   COVID-19 infection cases confirmed and probable  (where reported)                                                                                                                                                                     | 31827   |
| death      | person              | quantitative, ratio  | integer   | the number of   persons confirmed and probable to be deceased at least partly due to COVID-19   (where reported)                                                                                                                                      | 750     |
| recovered  | case                | quantitative, ratio  | integer   | the number of   COVID-19 infection cases that ended with recovery, these are estimates based   on local media reports, and state and local reporting when available, and   therefore may be substantially lower than the true number (where reported) | 26257   |
| active     | case                | quantitative, ratio  | integer   | the number of   COVID-19 infection cases that are still active, calculated as (total cases -   total recovered - total deaths)                                                                                                                        | 4820    |
| population | person              | quantitative, ratio  | integer   | the population   data of the country for 2019                                                                                                                                                                                                         | 8877067 |