# Initialize environment ----------------------------------------------------------------

library(tidyverse)
library(texreg)
library(car)

rm(list = ls())

path <- "/Users/Dominik/OneDrive - Central European University/1st_trimester/DA2/DA2_Assignments/Assignment2/"
non_countries <- read_csv(paste0(path,"data/raw/non-countries.csv"))


# Get data -------------------------------------------------------------

df<-WDI(
  country = "all",
  indicator = c("NY.GDP.DEFL.KD.ZG","SL.UEM.TOTL.ZS","NY.GNS.ICTR.ZS","FM.LBL.BMNY.GD.ZS","NY.GDP.MKTP.KD.ZG","NE.CON.GOVT.ZS"),
  start = 2017,
  end = 2017,
  extra = FALSE,
  cache = NULL
)

colnames(df) <- c("iso2c", "country", "year", "inflation", "unemployment", "savings", "money", "gdpgrowth","govexp")

write_csv(df, paste0(path,"data/raw/unemp_inf.csv"))

# Clean data --------------------------------------------------------------

df <- df[! df$iso2c %in% as.vector(non_countries$`non-countries`),]
df<-df[complete.cases(df), ]
df$year <- as.factor(df$year)

write_csv(df,paste0(path,"/data/clean/unemp_infl_clean.csv"))