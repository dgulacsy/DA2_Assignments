## Describe Objective of R Scripts
These codes are for analysis pattern of association between COVID-19 deaths and the confirmed cases.

1. get_clean_data.R
This script retrieves data from the World Bank Open Data via the WDI API package and cleans the data and  saves it into a csv file.

3. unemployment_analysis.R
This script contains the causal analysis of unemployment rates and inflation using 2017 data. The main goal is to get insight whether there is an inverse relationship between unemployment and inflation.
Runs simple and multiple linear regressions by applying piecewise linear splines. Contains robustness checks based on model setup and extreme values. Carries out visual inspections and quantitative analysis then chooses a final model to communicate the results. Provides visualization for better understanding.

3. unemployment_analysis_report.Rmd
Generates report based on the analysis in unemployment_analysis.R