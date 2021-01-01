## Describe Objective of R Scripts
These codes are for analysis pattern of association between COVID-19 deaths and the confirmed cases.

1. get_clean_data.R
This script retrieves data from the World Bank Open Data via the WDI API package and cleans the data and  saves it into a csv file.

3. unemployment_analysis.R
This script contains the causal analysis of unemployment rates and inflation using 2017 data.
Loads the cleaned input data and runs simple linear regression, quadratic (linear) regression, Piecewise linear spline regression and weighted linear regression, using population as weights. Carries out visual inspections and quantitative analysis then chooses a model and analyse residuals.