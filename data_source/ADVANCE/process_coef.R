// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

################################################################################
###################Computing polymial regression coef to fit RDLC data##########
################################################################################

############Loading packages

library(tidyverse)
library(readxl)


#=============================================#
#==============Data import====================#
#=============================================#
args = commandArgs(trailingOnly = TRUE)


path_data <- args[1]
path_export <- args[2]

RLDC <- read_excel(path_data)


#=============================================#
#============Data processing==================#
#=============================================#

names(RLDC) <- RLDC[3,]
RLDC <- RLDC[-c(1:4),]
#after checking by names(RLDC), we only need the first 12 cols
n <- ncol(RLDC)
RLDC <- RLDC[,-c(13:n)]

#Renaming columns so they are more tractable
names(RLDC)[3] <- "VRE_share"
names(RLDC)[4] <- "Wind_share"
names(RLDC)[5] <- "PV_share"
names(RLDC)[6] <- "Storage"
names(RLDC)[8] <- "Curtailment"
names(RLDC)[9] <- "Curtailment_2"
names(RLDC)[12] <- "Res_peak"

#Removing NA col, Scenario name and Storage col after setting Storage = allowed

#weird but if I start with filter storage it does not work
RLDC <- RLDC %>% select(Region,VRE_share,Wind_share,PV_share,Res_peak,Storage) %>% filter(Storage == "On") %>% select(-c(Storage))
RLDC[,2:5] <- apply(RLDC[,2:5],2,as.numeric) #as numeric for num col

RLDC <- RLDC %>% mutate(PV_share_sq = PV_share*PV_share,
                        PV_share_cb = PV_share*PV_share*PV_share,
                        Wind_share_sq = Wind_share* Wind_share,
                        Wind_share_cb = Wind_share*Wind_share*Wind_share)

fitted_mod <- RLDC %>% group_by(Region) %>% do(model = lm(Res_peak ~ Wind_share + PV_share 
                                                          + PV_share*Wind_share + Wind_share_sq + PV_share_sq 
                                                          + Wind_share_sq*PV_share + PV_share_sq*Wind_share
                                                          + Wind_share_cb + PV_share_cb,
                                                          data = .))



Reg <- fitted_mod[[1]]

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
coefCAN <- coefUSA
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

write.table(coef_export,path_export,row.names = FALSE,col.names = FALSE, dec = ".", sep = "|")
