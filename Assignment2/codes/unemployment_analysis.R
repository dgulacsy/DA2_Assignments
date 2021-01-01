# Initialize environment ----------------------------------------------------------------

library(WDI)
library(ggthemes)
library(dplyr)
library(ggplot2)
require(scales)
library(tidyverse)


rm(list = ls())
path <- "/Users/Dominik/OneDrive - Central European University/1st_trimester/DA2/DA2_Assignments/Assignment2/"


# Import data -------------------------------------------------------------

df <- read_csv(paste0(path,"data/clean/unemp_infl_clean.csv"))
df$year <- as.factor(df$year)

# EDA

df %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~key, scales = "free") +
  geom_histogram()+
  theme_wsj() + 
  scale_fill_wsj()

# 


