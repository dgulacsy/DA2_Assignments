## Describe Objective of R Scripts
These codes are for analysis pattern of association between COVID-19 deaths and the confirmed cases.

1. get_covid_data.R
This script downloads and saves the data into csv files from two sources (JHU & WB) for 21 Nov 2020 and 2019 respectively.

2. clean_covid_data.R
This script cleans the data  the following way:
    1. Get rid of variables that are unnecessary for the analysis such as FIPS, Admin2, Last_Update, Lat, Long, Combined_Key, Incidence Rate, Case.Fatality Ratio.
    These are mainly administrative and calculated fields.
    2. Aggregate to have country-level data using summation.
    3. In the population data remove regional observations.
    4. Merge the two data table (Population and COVID-19 data).
    5. Resolve country name conflicts.
    6. Remove rows that have missing values in any field.

3. analyze_covid_data.R
This script contains the general analisys of COVID-19 data.
Loads the cleaned input data and runs simple linear regression, quadratic (linear) regression, Piecewise linear spline regression and weighted linear regression, using population as weights. Carries out visual inspections and quantitative analysis then chooses a model and analyse residuals.