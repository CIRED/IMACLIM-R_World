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


#=============================================#
#==============Data import====================#
#=============================================#
# args = commandArgs(trailingOnly = TRUE)

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

RLDC <- RLDC %>% select(Scenario,Region,'gross VRE Share','gross wind share','gross PV share','Storage allowed in this scenario?','net VRE share') 

#Renaming columns so they are more tractable

RLDC <- RLDC  %>% rename("VRE_share" ='gross VRE Share' ,
                 "Wind_share" = 'gross wind share' ,
                  "PV_share" = 'gross PV share' ,
                  "Storage" = 'Storage allowed in this scenario?',
                  "net_VRE_share" = 'net VRE share' 
                  )  

#filter with storage only
RLDC <- RLDC[RLDC$Storage == "On",]  %>% select(-c(Storage))

#Removing NA col, Scenario name and Storage col after setting Storage = allowed

RLDC[3:ncol(RLDC)] <- apply(RLDC[,3:ncol(RLDC)],2,as.numeric) #as numeric for num col

RLDC <- RLDC %>% mutate(PV_share_sq = PV_share*PV_share,
                        PV_share_cb = PV_share*PV_share*PV_share,
                        Wind_share_sq = Wind_share* Wind_share,
                        Wind_share_cb = Wind_share*Wind_share*Wind_share)

fitted_mod <- RLDC %>% group_by(Region) %>% do(model = lm(net_VRE_share ~ Wind_share + PV_share 
                                                          + PV_share*Wind_share + Wind_share_sq + PV_share_sq 
                                                          + Wind_share_sq*PV_share + PV_share_sq*Wind_share
                                                          + Wind_share_cb + PV_share_cb + Wind_share_cb*PV_share + PV_share_cb*Wind_share + Wind_share_sq * PV_share_sq,                                                        data = .))



Reg <- fitted_mod[[1]]

# show the R2 of each regression 
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

#=============================================#
#============Data export======================#
#=============================================#

write.table(coef_export,paste0(path_export,"/coef_Net_VRE",".csv"),row.names = FALSE,col.names = FALSE, dec = ".", sep = "|")
