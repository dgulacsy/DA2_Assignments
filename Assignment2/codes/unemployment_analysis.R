# Initialize environment ----------------------------------------------------------------

library(WDI)
library(ggthemes)
library(dplyr)
library(ggplot2)
library(tidyverse)
require(scales)
source("sum_stat.R")


rm(list = ls())
path <- "/Users/Dominik/OneDrive - Central European University/1st_trimester/DA2/DA2_Assignments/Assignment2/"


# Import data -------------------------------------------------------------

df <- read_csv("https://raw.githubusercontent.com/dgulacsy/DA2_Assignments/main/Assignment2/data/clean/unemp_infl_clean.csv")
df$year <- as.factor(df$year)


# EDA ---------------------------------------------------------------------

# Histograms
df %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~key, scales = "free") +
  geom_histogram()+
  theme_wsj() + 
  scale_fill_wsj()

# Summary statistics
sum_stat(df, 
         colnames(df), 
         c('mean','median','mode','min','max','1st_qu.','3rd_qu',
                             'sd','var','range','iqr'))

