# Initialize environment ----------------------------------------------------------------

library(WDI)
library(ggthemes)
library(dplyr)
library(ggplot2)
library(tidyverse)
require(scales)
source(sum_stats)


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


