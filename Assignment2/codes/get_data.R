library(WDI)
library(ggthemes)
library(dplyr)
library(ggplot2)
require(scales)
library(tidyverse)
library(texreg)
library(car)
rm(list = ls())

path <- "/Users/Dominik/OneDrive - Central European University/1st_trimester/DA2/Assignments/Assignment2/"
non_countries <- read_csv(paste0(path,"data/raw/non-countries.csv"))

df<-WDI(
  country = "all",
  indicator = c("NY.GDP.DEFL.KD.ZG","SL.UEM.TOTL.ZS","NY.GNS.ICTR.ZS","FM.LBL.BMNY.GD.ZS","NY.GDP.MKTP.KD.ZG","NE.CON.GOVT.ZS"),
  start = 2017,
  end = 2017,
  extra = FALSE,
  cache = NULL
)


colnames(df) <- c("iso2c", "country", "year", "inflation", "unemployment", "savings", "money", "gdpgrowth","govexp")

df <- df[! df$iso2c %in% as.vector(non_countries$`non-countries`),]
df<-df[complete.cases(df), ]
df$year <- as.character(df$year)

write_csv(df,paste0(path,"/data/clean/unemp_infl.csv"))

# EDA

df %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~key, scales = "free") +
  geom_histogram()+
  theme_wsj() + 
  scale_fill_wsj()
