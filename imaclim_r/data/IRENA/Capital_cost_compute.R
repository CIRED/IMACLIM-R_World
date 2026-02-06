# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

###########################################################################
#################Learning curve & CINV base################################
###########################################################################


##########################################################################
##########################################################################
################WARNING WARNING WARNING WARNING WARNING WARNING : 
#agregation_Cap_IRENA_2014 & 2018 must be executed before this script#####
##########################################################################
##########################################################################


##Sources:

#Base year CAPEX are given by IRENA (2020) Renewable Power Generation Costs in 2019 when
#data is available or raisonable assumption is possible. when not, we compute base year (base) inv costs 
#from more recent estimates (2019) using
#learning curves. Installed cap from base & 2019 come from IRENA (2020) tool
#Formula: CINV_Q = CINV_Qref*(Q/Qref)^(-b) and b = - ln(1-PR)/ln(2) with PR = Progress Ratio

library(tidyverse)

#########################Data import#############################

args = commandArgs(trailingOnly = TRUE)

anneeQ <- args[2]
anneeQref <- args[1]

#csv from aggregated installed VRE capacity.
#insert here path to imported csv (/data/IRENA/installed_cap)
path_ <- args[3]
#insert here path to exported csv (/data/IRENA/CINV)
path_export <- args[4]

path_Q <- paste0(path_,"Cap_",anneeQ,"_ag.csv")
path_Qref <- paste0(path_,"Cap_",anneeQref,"_ag.csv")


###########################################################################
###########################################################################
###########################################################################
###########################################################################


data_Q <- read.csv(path_Q, sep = ";", header = TRUE)
names(data_Q)[3] <- "Q"
data_Qref <- read.csv(path_Qref, sep = ";", header = TRUE)
names(data_Qref)[3] <- "Qref"


#Imaclim Regions
Reg_IMC <- c("USA","Canada","Europe","OECD Pacific","CEI","China","India","Brazil",
             "Middle East","Africa","Rest of Asia","Rest of Latin America")
#Renewable energy source technologies
techno <- c("WND","WNO","CSP","CPV","RPV")

#Hardcoding base inv costs from IRENA (2020),Renewable Power Generation Costs in 2019

#WND - Figure 2.5 - Hyp: EUR = mean(Germany, Sweden, Italy, UK, Spain, France), 
# CEI= EUR, Rest of Asia = CHI,Rest of Latin = mean(BRAZ, MEX). No Africa nor Middle East
costs_WND_base <- c(1904,2443,mean(2011,2146,1983,2265,1753,1795),2919,mean(2011,2146,1983,2265,1753,1795),1350,1419,2222,0,0,1350,mean(2222,2533))
#WNO and CSP: no IRENA data
costs_WNO_base <- rep(0,length(Reg_IMC))
costs_CSP_base <- rep(0,length(Reg_IMC))
#CPV - Figure 3.4 - Hyp: CAN = USA, EUR = mean(France, Germany, Italy, Spain, UK), OECD = mean(Japan, Aus), CEI = EUR, Rest of Asia = CHIN
#No Africa, Middle East, Brazil, Rest of Latin America
costs_CPV_base <- c(2885,2885,mean(2369,1600,1972,2316,1943),mean(3007,3069),mean(2369,1600,1972,2316,1943),1763,1907,0,0,0,1763,0)
#RPV (Commercial in IRENA) - Table 3.1 - Hyp : USA = mean(4 US States), CEI = EUR = mean(France, Germany, Italy, Spain), OECD Pacific = mean(Jap,Aus), #
#IND = Rest of Asia = CHI. No Brasil, Middle East, Africa, Rest of Latin America
costs_RPV_base <- c(mean(3574,3668,4004,3786),mean(3574,3668,4004,3786),mean(2880,1691,2016,3168),mean(2846,3122),mean(2880,1691,2016,3168),1661,1661,0,0,0,1661,0)


#Hardcoding 2019 inv costs - Source: IEA (2020) "Power generation assumptions in the Stated Policies and SDS Scenarios in the World Energy Outlook 2020"
#hyp : CAN = USA, !!!OECD PAC = JAP !!!!!, REST ASIA = CHI, REST LAT = BRAZ, CEI = RUS
costs_WND <- c(1560,1560,1560,2260,1630,1220,1060,1560,1800,1950,1220,1560)
costs_WNO <- c(4260,4260,3800,4100,4800,3000,3140,4620,4580,4440,3000,4620)
costs_CPV <- c(1220,1220,840,2070,2120,790,610,1250,1000,1600,790,1250)
costs_RPV <- c(3480,3480,1240,2030,2740,900,820,1260,1640,2200,900,1260)
#hyp supp: OECD PAC = USA, CEI = EUR
costs_CSP <- c(6500,6500,5650,6500,5650,4900,5700,5350,5250,5050,4900,5350) 



cost_red_max <- list()
cost_red_max["CPV"] <- 0.68 #for India
cost_red_max["RPV"] <- 0.66 #for Spain
cost_red_max["WND"] <- 0.38 #for Sweden
#Not relevant for Offshore and CSP since we do not apply the same methodology as other technos
cost_red_max["WNO"] <- 1 
cost_red_max["CSP"] <- 1

#####################################################################
##############Preparing dataset for CINV computation#################
#####################################################################

data_CINV <- merge(data_Q,data_Qref, by = c("Technology","Region"),all.x = TRUE) #all.x = TRUE keeps
is.na(data_CINV$Qref)
#Adding lines for Missing regions for all techno

for (i in techno){
existing_reg <- filter(data_CINV, Technology == i) %>% .$Region
for (j in which(!Reg_IMC %in% existing_reg)){
  data_CINV <- rbind(c(i,Reg_IMC[j],-1,-1),data_CINV)
}
}

data_CINV$Q <- as.numeric(data_CINV$Q)
data_CINV$Qref <- as.numeric(data_CINV$Qref)

data_CINV$PR <- rep(0,nrow(data_CINV)) #progress ratio
data_CINV$CINV_base <- rep(0,nrow(data_CINV))
data_CINV$CINV_base_IRENA<- rep(0,nrow(data_CINV))
data_CINV$CINV_2019 <- rep(0,nrow(data_CINV))

#Learning applies to cumulated installed capacities of CPV+RPV

data_CINV$Technology <- ifelse(data_CINV$Technology == "CPV"|data_CINV$Technology == "RPV", "CPV", data_CINV$Technology)
data_CINV <- data_CINV %>% group_by(Technology,Region) %>% summarise(across(everything(), sum))

#Since RPV and CPV scale together for installed cap, just copy the rows to get rooftop
data_CINV <- data_CINV %>% filter(Technology == "CPV") %>% mutate(Technology = "RPV") %>% rbind(data_CINV)

#Progress ratio - Source : IEA (2020) "Power generation assumptions in the Stated Policies and SDS Scenarios in the World Energy Outlook 2020"

data_CINV$PR <- ifelse(data_CINV$Technology == "CSP", 0.1,
                      ifelse(data_CINV$Technology == "WNO", 0.15,
                             ifelse(data_CINV$Technology == "WND", 0.05,
                                    ifelse(data_CINV$Technology == "CPV",0.2,
                                           ifelse(data_CINV$Technology == "RPV",0.2,0)))))

#function to paste 2019 CINV to the right region
#it creates a new df for each technology so need to bind them
#improve to depend on region number instead of hardcoding 1:12
CINV_paste <- function(data,techno,costs){
data %>% filter(Technology == techno) %>% mutate(CINV_2019 = case_when(
Region == Reg_IMC[1] ~ costs[1],
Region == Reg_IMC[2] ~ costs[2],
Region == Reg_IMC[3] ~ costs[3],
Region == Reg_IMC[4] ~ costs[4],
Region == Reg_IMC[5] ~ costs[5],
Region == Reg_IMC[6] ~ costs[6],
Region == Reg_IMC[7] ~ costs[7],
Region == Reg_IMC[8] ~ costs[8],
Region == Reg_IMC[9] ~ costs[9],
Region == Reg_IMC[10] ~ costs[10],
Region == Reg_IMC[11] ~ costs[11],
Region == Reg_IMC[12] ~ costs[12]
))}
CINV_Compute <- function(data,techno,costs_base){
##First step get the base costs from IRENA in the df

for (i in 1:length(Reg_IMC)){
  for(j in 1:length(Reg_IMC)){
  if (data$Region[i] == Reg_IMC[j]){
    data$CINV_base_IRENA[i] <- costs_base[j]
  } else{}
  }
}
##Next step: Compute CINV_base based on learning curve formula

#We compute CINV_base from the learning curve. If the cost reduction is greater
#than the greatest observed in IRENA data, then we apply the IRENA cost reduction to the IEA 2019 data.
data <- data %>% mutate(CINV_base = round(CINV_2019*(Q/Qref)^(-log(1-PR)/log(2)),0)) %>% 
  mutate(CINV_base = case_when(
    CINV_base*(1-cost_red_max[[techno]]) < CINV_2019 ~ CINV_base,
    CINV_base*(1-cost_red_max[[techno]]) > CINV_2019 ~ CINV_2019/(1-cost_red_max[[techno]])
  )) 
#CINV base is replaced by hardcoded data from IRENA when available
data$CINV_base <- ifelse(data$CINV_base_IRENA > 0, data$CINV_base_IRENA, data$CINV_base)
data #to get the final output of the function
}

#Works well with WND, CPV and RPV because we've got enough data on install cap to fill the holes
data_CINV_WND <- CINV_paste(data_CINV,"WND",costs_WND) %>% CINV_Compute("WND",costs_WND_base)
data_CINV_CPV <- CINV_paste(data_CINV,"CPV",costs_CPV) %>% CINV_Compute("CPV",costs_CPV_base)
data_CINV_RPV <- CINV_paste(data_CINV,"RPV",costs_RPV) %>% CINV_Compute("RPV",costs_RPV_base)


#For CSP, regions with no installed cap in base & 2019 => assumed no learning so base cost = 2019 cost.
data_CINV_CSP <- CINV_paste(data_CINV,"CSP",costs_CSP) %>% CINV_Compute("CSP",costs_CSP_base)
#One missing value : Rest of latin America. Assumed = Brazil
data_CINV_WNO <- CINV_paste(data_CINV,"WNO",costs_WNO) %>% CINV_Compute("WNO",costs_WNO_base)
#In the end the learning curve does not yield very good results for CSP and WNO. According to IRENA tool, CAPEX reduction for CSP is
#very uncertain on base-2019 period, why not keep 2019 costs for base?
#Remark: CSP installed cap in base is somehow coherent with other sources than IRENA 
#(NREL 2019 Analysis of the Cost and Value of Concentrating Solar Power in China P.3)


#For WNO and CSP, better take IEA 2020costs and apply the mean world cost reduction between base and 2019 according to IRENA
#It is even a cost increase for CSP since new installations come with storage
#Source: IRENA (2020) Renewable Power Generation Cost
mean_cost_dec <- list()
mean_cost_dec["CSP"] <- max(0,1 - 5774/5510)
mean_cost_dec["WNO"] <- max(0, 1- 3800/5260)
  
data_CINV_CSP <- data_CINV_CSP %>% mutate(CINV_base = CINV_2019/(1-mean_cost_dec[["CSP"]]))
data_CINV_WNO <- data_CINV_WNO %>% mutate(CINV_base = CINV_2019/(1-mean_cost_dec[["WNO"]]))

data_CINV_final <- rbind(data_CINV_WND,
                         data_CINV_WNO,
                         data_CINV_CSP,
                         data_CINV_CPV,
                         data_CINV_RPV) %>% select(Technology,Region,CINV_base)
data_CINV_final$CINV_base <- round(data_CINV_final$CINV_base,0)
data_CINV_final$Region <- factor(data_CINV_final$Region, levels = Reg_IMC)

#reorder factors in case of a full csv output. Rename factors WND, WNO etc
data_CINV_final$Technology <- factor(data_CINV_final$Technology , levels = c("WND","WNO","CSP","CPV","RPV"))
data_CINV_final <- arrange(data_CINV_final, Technology, Region)

################################################################################
############################EXPORTING###########################################
################################################################################
#base year costs
for (i in techno){
  data <- data_CINV_final %>% ungroup() %>%  filter(Technology == i) %>% select(CINV_base)
  names(data) <- paste0('//CINV_2014 for tech',i,'. Data from IEA and IRENA')
  write.csv2(data,paste0(path_export,"CINV_", anneeQref, "_",i,".csv"),row.names = FALSE)
}

#2019 hardcoded costs

for (i in techno){
  data <- as_tibble(eval(parse(text = paste0("costs_",i)))) #costs_techno are vectors, need to convert to tibble to insert text
  names(data) <- paste0('//CINV_2019 for tech',i,'. Data hardcoded from IEA (2020), World Energy Model Assumption')
  write.csv2(data, paste0(path_export,"CINV_", anneeQ, "_",i,".csv"),row.names = FALSE)
}
