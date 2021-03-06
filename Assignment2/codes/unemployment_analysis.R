# Initialize environment ----------------------------------------------------------------

library(ggthemes)
library(dplyr)
library(ggplot2)
library(tidyverse)
require(scales)
library(Hmisc)
source("sum_stat.R")

rm(list = ls())
path <- "/Users/Dominik/OneDrive - Central European University/1st_trimester/DA2/DA2_Assignments/Assignment2/"

# Data Prep -------------------------------------------------------------

# Import data
df_all <- read_csv("https://raw.githubusercontent.com/dgulacsy/DA2_Assignments/main/Assignment2/data/clean/unemp_infl_clean.csv")
df_all$year <- as.factor(df_all$year)

# Change unit of measurement for population
df_all$population <- df_all$population/10^5

# Filter for year 2017
df <- filter(df_all, df_all$year==2017)

# EDA ---------------------------------------------------------------------

# Histograms
df %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~key, scales = "free") +
  geom_histogram()+
  theme_bw() + 
  scale_fill_wsj()

# Summary statistics
desc_stat <- sum_stat(df,
         c('population','govexp','gdpgrowth','money','savings','inflation','unemployment'), 
         c('mean','median','min','max','1st_qu.','3rd_qu','sd','range'),num_obs = F)

# Handling Extreme Values ------------------------------------------------
# There no extreme values that are likely to be errors
# Other extreme value dropping options are investigated as robustness checks

# Drop observations with an inflation rate below or equal to zero to take reciprocal properly
df <- filter(df, df$inflation > 0)

# Investigation of association patterns, plot loess for pairs of variables --------

# Inflation - Unemployment | Expected an inverse relationship based on the Philips Curve theory but rather it is rather flat and looks uncorrelated
ggplot(df , aes(x = inflation, y = unemployment)) +
  geom_point() +
  theme_bw() +
  geom_smooth(method="loess" , formula = y ~ x )+
  labs( title = "Pattern of Association between Unemployment and Inflation",
    y = "Unemployment (%)",
    x = "Inflation (%)")

# When taking reciprocal of inflation the pattern looks even more non-linear 
ggplot(df , aes(x = 1/inflation, y = unemployment)) +
  geom_point() +
  theme_bw() +
  geom_smooth(method="loess" , formula = y ~ x )+
  labs( title = "Pattern of Association between Unemployment and 1/Inflation",
        y = "Unemployment (%)",
        x = "1/Inflation (%)")

# Government Expenditure - Unemployment | Can see breaks at around 13%, 17% and 22% -> P.L.S
ggplot( df , aes(x = govexp, y = unemployment)) +
  geom_point() +
  theme_bw() +
  geom_smooth(method="loess" , formula = y ~ x )+
  labs(  title = "Pattern of Association between Unemployment and Government Expenditure",
    y = "Unemployment (%)",
    x = "Government Expenditure (% of GDP)") 

# Broad Money - Unemployment | Breaks at 37% and 75% -> P.L.S
ggplot( df , aes(x = money, y = unemployment)) +
  geom_point() +
  theme_bw() +
  geom_smooth(method="loess" , formula = y ~ x )+
  labs( title = "Pattern of Association between Unemployment and Broad Money",
    y = "Unemployment (%)",
    x = "Broad Money (% of GDP)")

# Savings - Unemployment | Breaks at 15% and 25% -> P.L.S
ggplot( df , aes(x = savings, y = unemployment)) +
  geom_point() +
  theme_bw() +
  geom_smooth(method="loess" , formula = y ~ x )+
  labs( title = "Pattern of Association between Unemployment and Savings",
    y = "Unemployment (%)",
    x = "Savings (% of GDP)")

# GDP Growth - Unemployment | Breaks at 0% -> P.L.S
ggplot( df , aes(x = gdpgrowth, y = unemployment)) +
  geom_point() +
  theme_bw() +
  geom_smooth(method="loess" , formula = y ~ x )+
  labs( title = "Pattern of Association between Unemployment and GDP Growth",
    y = "Unemployment (%)",
    x = "GDP Growth (%)")

# Population - Unemployment | Analysis does
ggplot( df , aes(x = population, y = unemployment)) +
  geom_point() +
  theme_bw() +
  geom_smooth(method="loess" , formula = y ~ x )+
  labs(title = "Pattern of Association between Population and GDP Growth",
       y = "Unemployment (%)",
       x = "Population (100K)")

# Inflation - Broad Money
ggplot( df , aes(x = govexp, y = inflation)) +
  geom_point() +
  theme_bw() +
  geom_smooth(method="loess", formula = y ~ x )+
  labs(title = "Pattern of Association between Inflation and Broad Money",
       y = "Inflation (%)",
       x = "Broad Money (% of GDP)")

# Linear Correlation Coefficient Heatmap ----------------------------------

corrmatrix <- function(df) {
  cors <- function(df) {
    M <- rcorr(as.matrix(df)) 
    Mdf <- map(M, ~data.frame(.x)) 
    return(Mdf) }
  
  formatted_cors <- function(df){
    cors(df) %>%
      map(~rownames_to_column(.x, var="measure1")) %>%
      map(~pivot_longer(.x, -measure1, "measure2")) %>% 
      bind_rows(.id = "id") %>%
      pivot_wider(names_from = id, values_from = value) %>%
      mutate(sig_p = ifelse(P < .05, T, F), p_if_sig = ifelse(P <.05, P, NA), r_if_sig = ifelse(P <.05, r, NA)) }
  
  numeric_df <- keep( df , is.numeric)
  
  result <- formatted_cors(numeric_df) %>% 
    ggplot(aes(measure1, measure2, fill=r, label=round(r_if_sig,2))) +
    geom_tile() + 
    labs(x = NULL, y = NULL, fill = "Pearson's\nCorrelation", title="Linear Correlation Coefficients", subtitle="Only significant coefficients shown") + 
    scale_fill_gradient2(mid="#FBFEF9",low="#0C6291",high="#A63446", limits=c(-1,1)) +
    geom_text() +
    theme_bw() +
    scale_x_discrete(expand=c(0,0)) + 
    scale_y_discrete(expand=c(0,0)) +
    theme(text=element_text(family="Roboto"))

  rm(numeric_df)
  return(result)
}

corrmatrix(df)

#  Thinking about interactions --------------------------------------------
# The variables of focus does not include an interaction
# There is no strong reason to include an interaction to control for

# Model Specification ------------------------------------------------------------------

# Avoiding overfitting: ca. 120 observations, 4-6 variables

# Main regression: score4 = b0 + b1*stratio
#   reg1: No controls, simple linear regression
#   reg2: No controls, simple linear regression, taking reciprocal of inflation to check inverse relationship
# Use better reg and control for:
#   reg3: GDP Growth (P.L.S with knot at 0%)
#   reg4: reg3 + Government Expenditure (P.L.S with knot at 22%)
#   reg5: reg4 + Broad Money (P.L.S with knot at 37%)
#   reg6: reg5 + Savings (P.L.S with knot at 15%)

# Note: Weighted regression using population does not make sense variables can only be interpreted on aggregate (country) level

# reg1: No controls, simple linear regression
reg1 <- lm_robust(unemployment ~ inflation, data = df )
summary( reg1 )
ggplot( data = df, aes( x = inflation, y = unemployment) ) + 
  geom_point( color='black') +
  geom_smooth( formula = y ~ x , method = lm , color = 'red' ) +
  theme_bw() +
  labs(title = "Reg1: Simple Linear Regression between Unemployment and Inflation",
       y = "Unemployment (%)",
       x = "Inflation (%)")

# reg2: No controls, simple linear regression, taking reciprocal of inflation
reg2 <- lm_robust(unemployment ~ I(1/inflation), data = df )
summary( reg2 )
ggplot( data = df, aes( x = 1/inflation, y = unemployment) ) + 
  geom_point( color='black') +
  geom_smooth( formula = y ~ I(1/x) , method = lm , color = 'red' ) +
  theme_bw() +
  labs(title = "Reg2: Simple Linear Regression between Unemployment and reciprocal of Inflation",
       y = "Unemployment (%)",
       x = "1 / Inflation (%)")

# Models with control variables
# reg3: control for GDP Growth (P.L.S with knot at 0%)
reg3 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 0), data = df )
summary( reg3 )

# reg4: reg3 + Government Expenditure (P.L.S with knot at 22%)
reg4 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 0) + lspline(govexp, 22), data = df )
summary( reg4 )

# reg5: reg4 + Broad Money (P.L.S with knot at 37%)
# Note: This is already 7 variables so additional explanatory variables would not really help
reg5 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 0) + lspline(govexp, 22) + lspline(money, 37), data = df )
summary( reg5 )

# reg6: reg3 + Broad Money (P.L.S with knot at 37%) + Savings (P.L.S with knot at 15%)
# Note: This is already 7 variables so additional explanatory variables would not really help
reg6 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 0) + lspline(money, 37) + lspline(savings, 15), data = df )
summary( reg6 )

# reg7: Final model 
# Note: This is already 7 variables so additional explanatory variables would not really help
reg7 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 0) + lspline(money, 37), data = df )
summary( reg7 )

# reg8: Final model with inflation reciprocal
reg8 <- lm_robust(unemployment ~ I(1/inflation) + lspline(gdpgrowth , 0) + lspline(money, 37), data = df )
summary( reg8 )


# Model Comparison --------------------------------------------------------

# HTML
htmlreg(list(reg1 , reg2 , reg3 , reg4 , reg5, reg6, reg7, reg8),
        type = 'html',
        custom.header = list("Unemployment rate"=1:8),
        custom.model.names = c("(1)","(2)","(3)","(4)","(5)","(6)","(7)F","(8)F"),
        custom.coef.names = c("intercept","inflation","1/inflation","GDP Growth (<0%)","GDP Growth (>=0%)",
                              "Gov. Exp. (<22%)","Gov. Exp. (>=22%)", "Broad Money (<37%)", "Broad Money (>=37%)",
                              "Savings (<15%)", "Savings (>=15%)"),
        file = paste0( path ,'out/model_comp.html'), 
        include.ci = FALSE,
        single.row = FALSE, 
        siunitx = TRUE,
        caption = "Analysis of the relatioship between unemployment and inflation. Data is for 2017 only."
        )


# Compare only final models -----------------------------------------------
# HTML
htmlreg(list(reg7, reg8),
        type = 'html',
        custom.header = list("Unemployment rate"=1:2),
        custom.model.names = c("(7)F","(8)F"),
        custom.coef.names = c("intercept","inflation","1/inflation","GDP Growth (<0%)","GDP Growth (>=0%)",
                              "Broad Money (<37%)", "Broad Money (>=37%)"),
        file = paste0( path ,'out/model_comp_finals.html'), 
        include.ci = FALSE,
        single.row = FALSE, 
        siunitx = TRUE,
        caption = "Analysis of the relationship between unemployment and inflation. Data is for 2017 only."
)
         
# PDF
# texreg(list(reg1 , reg2 , reg3 , reg4 , reg5, reg6, reg7, reg8),
#         type = 'pdf',
#         custom.header = list("Unemployment rate"=1:8),
#         custom.model.names = c("(1)","(2)","(3)","(4)","(5)","(6)","(7)F","(8)F"),
#         custom.coef.names = c("intercept","inflation","1/inflation","GDP Growth (<0%)","GDP Growth (>=0%)",
#                               "Gov. Exp. (<22%)","Gov. Exp. (>=22%)", "Broad Money (<37%)", "Broad Money (>=37%)",
#                               "Savings (<15%)", "Savings (>=15%)"),
#         include.ci = FALSE,
#         single.row = FALSE, 
#         siunitx = TRUE,
#         caption = "Analysis of the relatioship between unemployment and inflation. Data is for 2017 only."
# )

# Robustness Check --------------------------------------------------------

reg_analysis <- function(df,rule,case) {
  # reg1: No controls, simple linear regression
  reg1 <- lm_robust(unemployment ~ inflation, data = df )
  summary( reg1 )
  
  # reg2: No controls, simple linear regression, taking reciprocal of inflation
  reg2 <- lm_robust(unemployment ~ I(1/inflation), data = df )
  summary( reg2 )
  
  # Models with control variables
  # reg3: control for GDP Growth (P.L.S with knot at 0%)
  reg3 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 0), data = df )
  summary( reg3 )
  
  # reg4: reg3 + Government Expenditure (P.L.S with knot at 22%)
  reg4 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 0) + lspline(govexp, 22), data = df )
  summary( reg4 )
  
  # reg5: reg4 + Broad Money (P.L.S with knot at 37%)
  # Note: This is already 7 variables so additional explanatory variables would not really help
  reg5 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 0) + lspline(govexp, 22) + lspline(money, 37), data = df )
  summary( reg5 )
  
  # reg6: reg3 + Broad Money (P.L.S with knot at 37%) + Savings (P.L.S with knot at 15%)
  # Note: This is already 7 variables so additional explanatory variables would not really help
  reg6 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 0) + lspline(money, 37) + lspline(savings, 15), data = df )
  summary( reg6 )
  
  # reg7: Final model 
  # Note: This is already 7 variables so additional explanatory variables would not really help
  reg7 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 0) + lspline(money, 37), data = df )
  summary( reg7 )
  
  # reg8: Final model with inflation reciprocal
  reg8 <- lm_robust(unemployment ~ I(1/inflation) + lspline(gdpgrowth , 0) + lspline(money, 37), data = df )
  summary( reg8 )
  
  
  # Model Comparison --------------------------------------------------------
  
  # HTML
  htmlreg(list(reg1 , reg2 , reg3 , reg4 , reg5, reg6, reg7, reg8),
          type = 'html',
          custom.header = list("Unemployment rate"=1:8),
          custom.model.names = c("(1)","(2)","(3)","(4)","(5)","(6)","(7)F","(8)F"),
          custom.coef.names = c("intercept","inflation","1/inflation","GDP Growth (<0%)","GDP Growth (>=0%)",
                                "Gov. Exp. (<22%)","Gov. Exp. (>=22%)", "Broad Money (<37%)", "Broad Money (>=37%)",
                                "Savings (<15%)", "Savings (>=15%)"),
          file = paste0( path ,paste0('out/model_comp_case',case,'.html')),
          include.ci = FALSE,
          single.row = FALSE, 
          siunitx = TRUE,
          caption = paste0("Analysis of the relatioship between unemployment and inflation. Data is for 2017 only. Dropped extreme values (",rule,").")
  )  
}



# Case 1: Drop observations that have government expenditure above 30%
df1 <- filter(df, df$govexp < 30)
reg_analysis(df1,"observations that have government expenditure above 30%",1)

# Case 2: Drop observations that have inflation above 30%
df2 <- filter(df, df$inflation < 30)
reg_analysis(df2,"observations that have inflation above 30%",2)

##### External Validity
# Run analysis for 2016 ---------------------------------------------------
# Filter for year 2016
df <- filter(df_all, df_all$year==2016)

# Drop observations with an inflation rate below or equal to zero to take reciprocal properly
df <- filter(df, df$inflation > 0)

# Drop influential observations regarding government exp
df <- filter(df, df$govexp < 30)

# Investigation of association patterns, plot loess for pairs of variables

# Inflation - Unemployment | Expected an inverse relationship based on the Philips Curve theory but rather it is rather flat and looks uncorrelated
ggplot(df , aes(x = inflation, y = unemployment)) +
  geom_point() +
  geom_smooth(method="loess" , formula = y ~ x )+
  theme_bw() +
  labs( title = "Pattern of Association between Unemployment and Inflation",
        y = "Unemployment (%)",
        x = "Inflation (%)")

# When taking reciprocal of inflation the pattern looks even more non-linear 
ggplot(df , aes(x = 1/inflation, y = unemployment)) +
  geom_point() +
  geom_smooth(method="loess" , formula = y ~ x )+
  theme_bw() +
  labs( title = "Pattern of Association between Unemployment and 1/Inflation",
        y = "Unemployment (%)",
        x = "1/Inflation (%)")

# Government Expenditure - Unemployment | Looks linear
ggplot( df , aes(x = govexp, y = unemployment)) +
  geom_point() +
  geom_smooth(method="loess" , formula = y ~ x )+
  theme_bw() +
  labs(  title = "Pattern of Association between Unemployment and Government Expenditure",
         y = "Unemployment (%)",
         x = "Government Expenditure (% of GDP)") 

# Broad Money - Unemployment | Breaks at 65% -> P.L.S
ggplot( df , aes(x = money, y = unemployment)) +
  geom_point() +
  geom_smooth(method="loess" , formula = y ~ x )+
  theme_bw() +
  labs( title = "Pattern of Association between Unemployment and Broad Money",
        y = "Unemployment (%)",
        x = "Broad Money (% of GDP)")

# Savings - Unemployment | Breaks at 12% -> P.L.S
ggplot( df , aes(x = savings, y = unemployment)) +
  geom_point() +
  geom_smooth(method="loess" , formula = y ~ x )+
  theme_bw() +
  labs( title = "Pattern of Association between Unemployment and Savings",
        y = "Unemployment (%)",
        x = "Savings (% of GDP)")

# GDP Growth - Unemployment | Breaks at 1% -> P.L.S
ggplot( df , aes(x = gdpgrowth, y = unemployment)) +
  geom_point() +
  geom_smooth(method="loess" , formula = y ~ x )+
  theme_bw() +
  labs( title = "Pattern of Association between Unemployment and GDP Growth",
        y = "Unemployment (%)",
        x = "GDP Growth (%)")

corrmatrix(df)

# reg1: No controls, simple linear regression
reg1 <- lm_robust(unemployment ~ inflation, data = df )
summary( reg1 )
ggplot( data = df, aes( x = inflation, y = unemployment) ) + 
  geom_point( color='black') +
  geom_smooth( formula = y ~ x , method = lm , color = 'red' ) +
  theme_bw() +
  labs(title = "Reg1: Simple Linear Regression between Unemployment and Inflation (2016)",
       y = "Unemployment (%)",
       x = "Inflation (%)")

# reg2: No controls, simple linear regression, taking reciprocal of inflation
reg2 <- lm_robust(unemployment ~ I(1/inflation), data = df )
summary( reg2 )
ggplot( data = df, aes( x =inflation, y = unemployment) ) + 
  geom_point( color='black') +
  geom_smooth( formula = y ~ I(1/x) , method = lm , color = 'red' ) +
  theme_bw() +
  labs(title = "Reg2: Simple Linear Regression between Unemployment and reciprocal of Inflation (2016)",
       y = "Unemployment (%)",
       x = "1 / Inflation (%)")

# Models with control variables
# reg3: control for GDP Growth (P.L.S with knot at 1%)
reg3 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 1), data = df )
summary( reg3 )

# reg4: reg3 + Government Expenditure
reg4 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 1) + govexp, data = df )
summary( reg4 )

# reg5: reg4 + Broad Money (P.L.S with knot at 65%)
# Note: This is already 7 variables so additional explanatory variables would not really help
reg5 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 1) + govexp + lspline(money, 65), data = df )
summary( reg5 )

# reg6: reg3 + Broad Money (P.L.S with knot at 65%) + Savings (P.L.S with knot at 12%)
# Note: This is already 7 variables so additional explanatory variables would not really help
reg6 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 1) + lspline(money, 65) + lspline(savings, 12), data = df )
summary( reg6 )

# reg7: Final model 
# Note: This is already 7 variables so additional explanatory variables would not really help
reg7 <- lm_robust(unemployment ~ inflation + lspline(gdpgrowth , 1) + lspline(money, 65), data = df )
summary( reg7 )

# reg8: Final model with inflation reciprocal
reg8 <- lm_robust(unemployment ~ I(1/inflation) + lspline(gdpgrowth , 1) + lspline(money, 65), data = df )
summary( reg8 )

# Results --------------------------------------------------------

# HTML
htmlreg(list(reg1 , reg2 , reg3 , reg4 , reg5, reg6, reg7, reg8),
        type = 'html',
        custom.header = list("Unemployment rate"=1:8),
        custom.model.names = c("(1)","(2)","(3)","(4)","(5)","(6)","(7)F","(8)F"),
        custom.coef.names = c("intercept","inflation","1/inflation","GDP Growth (<1%)","GDP Growth (>=1%)",
                              "Gov. Exp.", "Broad Money (<65%)", "Broad Money (>=65%)",
                              "Savings (<12%)", "Savings (>=12%)"),
        file = paste0( path ,'out/model_comp_2016.html'), 
        include.ci = FALSE,
        single.row = FALSE, 
        siunitx = TRUE,
        caption = "Analysis of the relatioship between unemployment and inflation. Data is for 2016 only. Dropped extreme values (observations that have government expenditure above 30%)."
)


# Run analysis for 2018 ---------------------------------------------------
# Filter for year 2018
df <- filter(df_all, df_all$year==2018)

# Drop observations with an inflation rate below or equal to zero to take reciprocal properly
df <- filter(df, df$inflation > 0)

# Drop influential observations regarding government exp
df <- filter(df, df$govexp < 30)

# Drop influential observations regarding savings
df <- filter(df, df$savings > 0)

# Investigation of association patterns, plot loess for pairs of variables

# Inflation - Unemployment | Expected an inverse relationship based on the Philips Curve theory but rather it is rather flat and looks uncorrelated
ggplot(df , aes(x = inflation, y = unemployment)) +
  geom_point() +
  geom_smooth(method="loess" , formula = y ~ x )+
  theme_bw() +
  labs( title = "Pattern of Association between Unemployment and Inflation",
        y = "Unemployment (%)",
        x = "Inflation (%)")

# When taking reciprocal of inflation the pattern looks more linear 
ggplot(df , aes(x = 1/inflation, y = unemployment)) +
  geom_point() +
  geom_smooth(method="loess" , formula = y ~ x )+
  theme_bw() +
  labs( title = "Pattern of Association between Unemployment and 1/Inflation",
        y = "Unemployment (%)",
        x = "1/Inflation (%)")

# Government Expenditure - Unemployment | Break at 17%
ggplot( df , aes(x = govexp, y = unemployment)) +
  geom_point() +
  geom_smooth(method="loess" , formula = y ~ x )+
  theme_bw() +
  labs(  title = "Pattern of Association between Unemployment and Government Expenditure",
         y = "Unemployment (%)",
         x = "Government Expenditure (% of GDP)") 

# Broad Money - Unemployment | Breaks at 37% -> P.L.S
ggplot( df , aes(x = money, y = unemployment)) +
  geom_point() +
  geom_smooth(method="loess" , formula = y ~ x )+
  theme_bw() +
  labs( title = "Pattern of Association between Unemployment and Broad Money",
        y = "Unemployment (%)",
        x = "Broad Money (% of GDP)")

# Savings - Unemployment | Breaks at 22% -> P.L.S
ggplot( df , aes(x = savings, y = unemployment)) +
  geom_point() +
  geom_smooth(method="loess" , formula = y ~ x )+
  theme_bw() +
  labs( title = "Pattern of Association between Unemployment and Savings",
        y = "Unemployment (%)",
        x = "Savings (% of GDP)")

# GDP Growth - Unemployment | Looks uncorrelated check for significance
ggplot( df , aes(x = gdpgrowth, y = unemployment)) +
  geom_point() +
  geom_smooth(method="loess" , formula = y ~ x )+
  theme_bw() +
  labs( title = "Pattern of Association between Unemployment and GDP Growth",
        y = "Unemployment (%)",
        x = "GDP Growth (%)")

corrmatrix(df)

# reg1: No controls, simple linear regression
reg1 <- lm_robust(unemployment ~ inflation, data = df )
summary( reg1 )
ggplot( data = df, aes( x = inflation, y = unemployment) ) + 
  geom_point( color='black') +
  geom_smooth( formula = y ~ x , method = lm , color = 'red' ) +
  theme_bw() +
  labs(title = "Reg1: Simple Linear Regression between Unemployment and Inflation (2018)",
       y = "Unemployment (%)",
       x = "Inflation (%)")

# reg2: No controls, simple linear regression, taking reciprocal of inflation
reg2 <- lm_robust(unemployment ~ I(1/inflation), data = df )
summary( reg2 )
ggplot( data = df, aes( x = inflation, y = unemployment) ) + 
  geom_point( color='black') +
  geom_smooth( formula = y ~ I(1/x) , method = lm , color = 'red' ) +
  theme_bw() +
  labs(title = "Reg2: Simple Linear Regression between Unemployment and reciprocal of Inflation (2018)",
       y = "Unemployment (%)",
       x = "Inflation (%)")

# Models with control variables
# reg3: control for GDP Growth
reg3 <- lm_robust(unemployment ~ inflation + gdpgrowth, data = df )
summary( reg3 )

# reg4: reg3 + Government Expenditure (P.L.S with knot at 17%) 
reg4 <- lm_robust(unemployment ~ inflation + gdpgrowth + lspline(govexp, 17), data = df )
summary( reg4 )

# reg5: reg4 + Broad Money (P.L.S with knot at 37%) 
# Note: This is already 7 variables so additional explanatory variables would not really help
reg5 <- lm_robust(unemployment ~ inflation + gdpgrowth + lspline(govexp, 17) + lspline(money, 37), data = df )
summary( reg5 )

# reg6: reg3 + Broad Money (P.L.S with knot at 37%) + Savings (P.L.S with knot at 22%)
# Note: This is already 7 variables so additional explanatory variables would not really help
reg6 <- lm_robust(unemployment ~ inflation + gdpgrowth + lspline(money, 37) + lspline(savings, 22), data = df )
summary( reg6 )

# reg7: Final model 
# Note: This is already 7 variables so additional explanatory variables would not really help
reg7 <- lm_robust(unemployment ~ inflation + gdpgrowth + lspline(money, 37), data = df )
summary( reg7 )

# reg8: Final model with inflation reciprocal
reg8 <- lm_robust(unemployment ~ I(1/inflation) + gdpgrowth + lspline(money, 37), data = df )
summary( reg8 )

# Results --------------------------------------------------------

# HTML
htmlreg(list(reg1 , reg2 , reg3 , reg4 , reg5, reg6, reg7, reg8),
        type = 'html',
        custom.header = list("Unemployment rate"=1:8),
        custom.model.names = c("(1)","(2)","(3)","(4)","(5)","(6)","(7)F","(8)F"),
        custom.coef.names = c("intercept","inflation","1/inflation","GDP Growth", "Gov. Exp. (<17%)",
                              "Gov. Exp. (>=17%)", "Broad Money (<37%)", "Broad Money (>=37%)",
                              "Savings (<22%)", "Savings (>=22%)"),
        file = paste0( path ,'out/model_comp_2018.html'), 
        include.ci = FALSE,
        single.row = FALSE, 
        siunitx = TRUE,
        caption = "Analysis of the relatioship between unemployment and inflation. Data is for 2018 only. Dropped extreme values (observations that have government expenditure above 30% and/or saving below 0%)."
)






