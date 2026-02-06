# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Gabriele Dabbaghian
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

#Loading libraries (are there some useless?)
library(tidyr)
library(dplyr)
library(openxlsx)
library(ggplot2)
library(tibble)
library(collapse)
library(lfe)

# To change to point to data in server or directly api

df_xsi <- read.csv2("OECD/OECD_consumption_expenditure_2.csv",sep = ",")%>%
  filter(PRICE_BASE=="V")%>%
  select(REF_AREA,TRANSACTION,EXPENDITURE,Dépense,TIME_PERIOD,OBS_VALUE,CURRENCY)%>%
  filter(EXPENDITURE %in% c("_T","CP01","CP02","CP03","CP04","CP05","CP06","CP07","CP08","CP09","CP10","CP11","CP12","CP095","CP091","CP092","CP061","CP071","CP082"))
  
df_ppp <- read.csv2("OECD/OECD_ppp.csv",sep = ",")%>%
  select(REF_AREA,TIME_PERIOD,OBS_VALUE,CURRENCY)%>%
  rename(ppp=OBS_VALUE)

df_pop <- read.csv2("OECD/OECD_pop.csv",sep = ",")%>%
  filter(AGE=="_T")%>%
  select(REF_AREA,TIME_PERIOD,OBS_VALUE)%>%
  rename(pop=OBS_VALUE)

df <- left_join(df_xsi,df_ppp, by=c("REF_AREA","TIME_PERIOD","CURRENCY"))%>%
  left_join(df_pop,by=c("REF_AREA","TIME_PERIOD"))%>%
  mutate(ppp_value=as.numeric(OBS_VALUE)/as.numeric(ppp))%>%
  select(REF_AREA,TIME_PERIOD,TRANSACTION,EXPENDITURE,ppp_value,pop)%>%
  pivot_wider(id_cols = c("REF_AREA","TIME_PERIOD","pop"),  names_from = c("TRANSACTION","EXPENDITURE") , values_from = ppp_value)%>%
  mutate(food=P31DC_CP01+P31DC_CP02,industry=P31DC_CP03+P31DC_CP05,miscellaneous=P31DC_CP07+P31DC_CP08+P31DC_CP12,
         industry2 = P311__T+P312__T+P313__T-food,
         industry3 = industry+P31DC_CP095+P31DC_CP091+P31DC_CP092+P31DC_CP061+P31DC_CP071+P31DC_CP082,
         income=food+industry+miscellaneous+P31DC_CP04+P31DC_CP06+P31DC_CP09+P31DC_CP10+P31DC_CP11,
         income_cap=income/as.numeric(pop)*1e6)%>%
  mutate(across(starts_with("P31DC"), ~ .x /income, .names = "shares_{col}"))%>%
  mutate(shares_food=shares_P31DC_CP01+shares_P31DC_CP02,shares_industry=shares_P31DC_CP03+shares_P31DC_CP05,shares_miscellaneous=shares_P31DC_CP07+shares_P31DC_CP08+shares_P31DC_CP12,
         shares_industry2=industry2/income, shares_industry3=industry3/income)


# regressions with different variables

reg_industry_log_fe_2 = lm(shares_industry ~ poly(log(income_cap),2, raw=T)+ factor(REF_AREA), data=df)
summary(reg_industry_log_fe_2)

reg_industry2_fe_2 = lm(shares_industry2 ~ poly(log(income_cap),2, raw=T)+ factor(REF_AREA), data=df)
summary(reg_industry2_fe_2)

# for now this one is the selected
reg_industry3_log_fe_2 = lm(shares_industry3 ~ poly(log(income_cap),2, raw=T)+ factor(REF_AREA), data=df)
summary(reg_industry3_log_fe_2)

# Create a data frame with the desired values
df_res <- data.frame(Value = c('// Regression coefficients for budget share of industrial consumption', 
'// From OECD data, reconstruction of industrial variable to match GTAP definition and fixed effect regression. See .R for code.', 
reg_industry3_log_fe_2$coefficients[1:3]))

# Write the data frame to a CSV file
write.csv(df_res, file = "results/industry3.csv", row.names = FALSE)
 
 
