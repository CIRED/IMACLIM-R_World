# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

################################################################################
###################Computing polymial regression coef to fit RDLC data##########
################################################################################

#Comes from the VRE integration module recommandations (ADVANCE)
#https://fp7-advance.eu/?q=content/variable-renewable-energy-integration-module
#doi:10.1016/j.eneco.2016.05.012 for method
############Loading packages

library(tidyverse)
library(readxl)
library(kableExtra)
library(latex2exp)
#=============================================#
#==============Data import====================#
#=============================================#
args = commandArgs(trailingOnly = TRUE)


path_data <- args[[1]]
path_export <- args[[2]]

RLDC <- read_excel(path_data)


#=============================================#
#============Data processing==================#
#=============================================#

names(RLDC) <- RLDC[3,]

#removing the first 4 rows
RLDC <- RLDC[-c(1:4),]
#selecting the variables

RLDC <- RLDC %>% select(Scenario,Region,'gross VRE Share','gross wind share','gross PV share','Storage allowed in this scenario?','Storage Capacity','Storage Output') 

#Renaming columns so they are more tractable

RLDC <- RLDC  %>% rename("VRE_share" ='gross VRE Share' ,
                 "Wind_share" = 'gross wind share' ,
                  "PV_share" = 'gross PV share' ,
                  "Storage" = 'Storage allowed in this scenario?',
                  "Storage_Capacity" = 'Storage Capacity' ,
                 "Storage_Output"= 'Storage Output' 
                  )  

#filter with storage only
RLDC <- RLDC[RLDC$Storage == "On",]  %>% select(-c(Storage))

#Removing NA col, Scenario name and Storage col after setting Storage = allowed

RLDC[3:ncol(RLDC)] <- apply(RLDC[,3:ncol(RLDC)],2,as.numeric) #as numeric for num col

RLDC <- RLDC %>% mutate(PV_share_sq = PV_share*PV_share,
                        PV_share_cb = PV_share*PV_share*PV_share,
                        Wind_share_sq = Wind_share* Wind_share,
                        Wind_share_cb = Wind_share*Wind_share*Wind_share)

fitted_mod <- RLDC %>% group_by(Region) %>% do(model = lm(Storage_Capacity ~ 0  + Wind_share + PV_share 
                                                          + PV_share*Wind_share + Wind_share_sq + PV_share_sq 
                                                          + Wind_share_sq*PV_share + PV_share_sq*Wind_share
                                                          + Wind_share_cb + PV_share_cb,
                                                          data = .))



Reg <- fitted_mod[[1]]

#R2
fitted_mod %>% summarise(R2 = summary(model)$r.squared)

coefRLDC <- list()

#Lets handle extraction mannualy, so we can give coef to non existing Reg

coefAFR <- fitted_mod[1,2][[1]][[1]]$coefficients
coefCHN <- fitted_mod[2,2][[1]][[1]]$coefficients
coefEUR <- fitted_mod[3,2][[1]][[1]]$coefficients
coefIND <- fitted_mod[4,2][[1]][[1]]$coefficients
coefJAN <- fitted_mod[5,2][[1]][[1]]$coefficients
coefRAL <- fitted_mod[6,2][[1]][[1]]$coefficients
coefMDE <- fitted_mod[7,2][[1]][[1]]$coefficients
coefUSA <- fitted_mod[8,2][[1]][[1]]$coefficients
#Following hyp : 
coefCAN <- coefEUR
coefCIS <- coefEUR
coefBRA <- coefRAL
coefRAS <- coefCHN

# get R² in the same order
R2AFR <- summary(fitted_mod[1,2][[1]][[1]])$r.squared
R2CHN <- summary(fitted_mod[2,2][[1]][[1]])$r.squared
R2EUR <- summary(fitted_mod[3,2][[1]][[1]])$r.squared
R2IND <- summary(fitted_mod[4,2][[1]][[1]])$r.squared
R2JAN <- summary(fitted_mod[5,2][[1]][[1]])$r.squared
R2RAL <- summary(fitted_mod[6,2][[1]][[1]])$r.squared
R2MDE <- summary(fitted_mod[7,2][[1]][[1]])$r.squared
R2USA <- summary(fitted_mod[8,2][[1]][[1]])$r.squared

#Following hyp :
R2CAN <- R2EUR
R2CIS <- R2EUR
R2BRA <- R2RAL
R2RAS <- R2CHN

# create a R² vector
R2 <- c(R2USA,R2CAN,R2EUR,R2JAN,R2CIS,R2CHN,R2IND,R2BRA,R2MDE,R2AFR,R2RAS,R2RAL)

#Creating the final dataframe to export in csv

coef_export <- as.data.frame(t(tibble(
  coefUSA,
  coefCAN,
  coefEUR,
  coefJAN,
  coefCIS,
  coefCHN,
  coefIND,
  coefBRA,
  coefMDE,
  coefAFR,
  coefRAS,
  coefRAL
)))
names(coef_export) <- names(coefAFR)

coef_export  <- tibble(rep(0,nrow(coef_export)),coef_export)
names(coef_export) <- c("Intercept",names(coefAFR))


#=============================================#
#============Data export======================#
#=============================================#

write.table(coef_export,paste0(path_export,"/coef_Storage",".csv"),row.names = FALSE,col.names = FALSE, dec = ".", sep = "|")

#=============================================#
#============Latex export======================#
#=============================================#

# generate a latex table

coef_export <- coef_export %>% mutate(Region = c("USA","CAN","EUR","JAN","CIS","CHN","IND","BRA","MDE","AFR","RAS","RAL"))

#kbl(dt, caption = "Demo table", booktabs = T) %>%
#kable_styling(latex_options = c("striped", "hold_position"))

# colnames to Latex 
colnames(coef_export) <- c("$a_{0,0}$","$a_{1,0}$","$a_{0,1}$","$a_{1,1}$","$a_{2,0}$","$a_{0,2}$","$a_{2,1}$","$a_{1,2}$","$a_{3,0}$","$a_{0,3}$","Region")

# placing Region as first column
coef_export <- coef_export %>% select(Region,everything())

# add R² for each region

coef_export <- coef_export %>% mutate(R2 = R2)


# round to 2 decimals
coef_export <- coef_export %>% mutate_if(is.numeric, round, 3)

#kbl(coef_export, "latex",caption = "Coefficients of regression for the twelve IMACLIM-R regions - Storage capacity (in % of peak load)", booktabs = T) %>% kable_styling(latex_options = c("striped", "scale_down"))
