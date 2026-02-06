# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

######################################################################
#########. IMACLIM - endogenous profile costs calibration .############
######################################################################

############################
## Thibault Briera
## June 2024
## briera.cired@gmail
############################
library(stringr)
library(tidyverse)
library(kableExtra)
library(latex2exp)
#env 
path_data <- args[[1]]
path_export <- args[[2]]



#locate all the csv files in the fold
#list all the files in the folder
files_IMC <- list.files(path = path_data,pattern = "*.csv", recursive = TRUE)

# loading all the csv files in files_IMC
files_list <- list()

for (i in seq_along(files_IMC )){
    files_list[[i]] <- read.csv(paste0(path_data,"/",files_IMC[i]),header = FALSE)
}

files_list <- lapply(files_list, tibble)

profile_costs <- purrr::reduce(files_list, dplyr::full_join)
names(profile_costs) <- c("RLDC","Region","Wd_sh","Solar_sh","TASC","TASC_D","Net_VRE_sh","Gross_Wd_sh","Gross_Solar_sh")

#create a variable delta VRE share that tracks if there is an unexplained drop in the total elec demand
profile_costs_process <- profile_costs %>%
  group_by(Wd_sh, Solar_sh, Region) %>%
  summarise(profile_costs = TASC_D[RLDC == 0] - TASC_D[RLDC == 1],delta_share_VRE = Net_VRE_sh[RLDC == 0] - Net_VRE_sh[RLDC == 1], Net_VRE_sh = Net_VRE_sh[RLDC == 1], Gross_Wd_sh = Gross_Wd_sh[RLDC == 1], Gross_Solar_sh = Gross_Solar_sh[RLDC ==1], .groups = 'drop')

profile_costs_process <-  profile_costs_process %>% mutate(Gross_VRE = Gross_Solar_sh + Gross_Wd_sh)

profile_costs_process <-  profile_costs_process %>% mutate(profile_costs_VRE = profile_costs / Net_VRE_sh)  

profile_costs_process <-  profile_costs_process %>% mutate(profile_costs_Gross = profile_costs / Gross_VRE)  

# keeping minimum values otherwise results are not very very significant
profile_costs_process  <- profile_costs_process %>% filter(Gross_VRE<1.21)

profile_costs_process <- profile_costs_process %>% mutate(Wind_share = Gross_Wd_sh, PV_share = Gross_Solar_sh) %>% select(-c(Wd_sh,Solar_sh,Gross_Wd_sh,Gross_Solar_sh))


df <- profile_costs_process  %>% mutate(PV_share_sq = PV_share*PV_share,
                        PV_share_cb = PV_share*PV_share*PV_share,
                        Wind_share_sq = Wind_share* Wind_share,
                        Wind_share_cb = Wind_share*Wind_share*Wind_share,
                        Wind_share_4 = Wind_share*Wind_share*Wind_share*Wind_share,
                        PV_share_4 = PV_share*PV_share*PV_share*PV_share)

# get profile_costs_Gross in $ per kWh
df <- df %>% mutate(profile_costs_Gross = profile_costs_Gross/1000)

fitted_mod <- df %>% group_by(Region) %>% do(model = lm(profile_costs_Gross  ~  Wind_share + PV_share + PV_share*Wind_share + Wind_share_sq + PV_share_sq + Wind_share_sq*PV_share + PV_share_sq*Wind_share + Wind_share_cb + PV_share_cb + Wind_share_cb*PV_share + PV_share_cb*Wind_share + Wind_share_sq*PV_share_sq + Wind_share_4 + PV_share_4,                                                      data = .))

Reg <- fitted_mod[[1]]

coefAFR <- fitted_mod[1,2][[1]][[1]]$coefficients
coefBRA <- fitted_mod[2,2][[1]][[1]]$coefficients
coefCAN<- fitted_mod[3,2][[1]][[1]]$coefficients
coefCHN <- fitted_mod[4,2][[1]][[1]]$coefficients
coefCIS <- fitted_mod[5,2][[1]][[1]]$coefficients
coefEUR <- fitted_mod[6,2][[1]][[1]]$coefficients
coefIND <- fitted_mod[7,2][[1]][[1]]$coefficients
coefJAN <- fitted_mod[8,2][[1]][[1]]$coefficients
coefMDE <- fitted_mod[9,2][[1]][[1]]$coefficients
coefRAL <- fitted_mod[10,2][[1]][[1]]$coefficients
coefRAS <- fitted_mod[11,2][[1]][[1]]$coefficients
coefUSA <- fitted_mod[12,2][[1]][[1]]$coefficients


# show the R2 of each regression 
fitted_mod %>% summarise(R2 = summary(model)$r.squared)

# get R² in the same order
R2AFR <- summary(fitted_mod[1,2][[1]][[1]])$r.squared
R2BRA <- summary(fitted_mod[2,2][[1]][[1]])$r.squared
R2CAN <- summary(fitted_mod[3,2][[1]][[1]])$r.squared
R2CHN <- summary(fitted_mod[4,2][[1]][[1]])$r.squared
R2CIS <- summary(fitted_mod[5,2][[1]][[1]])$r.squared
R2EUR <- summary(fitted_mod[6,2][[1]][[1]])$r.squared
R2IND <- summary(fitted_mod[7,2][[1]][[1]])$r.squared
R2JAN <- summary(fitted_mod[8,2][[1]][[1]])$r.squared
R2MDE <- summary(fitted_mod[9,2][[1]][[1]])$r.squared
R2RAL <- summary(fitted_mod[10,2][[1]][[1]])$r.squared
R2RAS <- summary(fitted_mod[11,2][[1]][[1]])$r.squared
R2USA <- summary(fitted_mod[12,2][[1]][[1]])$r.squared


# create a R² vector
R2 <- c(R2USA,R2CAN,R2EUR,R2JAN,R2CIS,R2CHN,R2IND,R2BRA,R2MDE,R2AFR,R2RAS,R2RAL)


#=============================================#
#============Data export======================#
#=============================================#

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

# adding a column of zeros for intercept
#coef_export  <- tibble(rep(0,nrow(coef_export)),coef_export)
names(coef_export) <- names(coefAFR)


write.table(coef_export,paste0(path_export,"/coef_profile_costs",".csv"),row.names = FALSE,col.names = FALSE, dec = ".", sep = "|")

#=============================================#
#============Latex export======================#
#=============================================#

# generate a latex table

coef_export <- coef_export %>% mutate(Region = c("USA","CAN","EUR","JAN","CIS","CHN","IND","BRA","MDE","AFR","RAS","RAL"))

#kbl(dt, caption = "Demo table", booktabs = T) %>%
#kable_styling(latex_options = c("striped", "hold_position"))

# colnames to Latex 
colnames(coef_export) <- c("$a_{0,0}$","$a_{1,0}$","$a_{0,1}$","$a_{2,0}$","$a_{0,2}$","$a_{3,0}$","$a_{0,3}$","$a_{4,0}$","$a_{0,4}$","$a_{1,1}$","$a_{2,1}$","$a_{1,2}$","$a_{3,1}$","$a_{1,3}$","$a_{2,2}$","Region")
fitted_mod[12,2][[1]][[1]]$coefficients
# placing Region as first column
coef_export <- coef_export %>% select(Region,everything())

# add R² for each region

coef_export <- coef_export %>% mutate(R2 = R2)


# round to 2 decimals
coef_export <- coef_export %>% mutate_if(is.numeric, round, 3)

#kbl(coef_export, "latex",caption = "Coefficients of regression for the twelve IMACLIM-R regions - Utilization integration costs in $ per MWh of gross VRE generation. Hyp: CAN = USA, CIS = EUR, RAS = CHN, RAL = BRA.", booktabs = T) %>% kable_styling(latex_options = c("striped", "scale_down"))
