// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

################################################################################
########################## KPMG corporate tax data #############################
################################################################################

#https://home.kpmg/xx/en/home/services/tax/tax-tools-and-resources/tax-rates-online/corporate-tax-rates-table.html


##############################################
########## LIBRARIES #####################
##############################################

library(countrycode)
library(tidyverse)

##############################################
########## DATA PATHS ########################
##############################################

args = commandArgs(trailingOnly = TRUE)

path_data <- args[[1]]
year <- args[[2]]
path_GTAP <- args[[3]]
path_ISO_to_GTAP <- args[[4]]
path_WB <- args[[5]]
path_export <- args[[6]]

##############################################
########## DATA PROCESSING ###################
##############################################


data_agreg <- read.csv(paste0(path_data), dec = ".", sep = ";", header = TRUE) %>% 
  select(Country,paste0("X",year))
names(data_agreg) <- c("Country","Corporate_Tax")
data_agreg$Corporate_Tax <- as.numeric(data_agreg$Corporate_Tax)

#World Bank GDP PPP data
WB_data <- read.csv(path_WB, dec = ".",sep = ",", header = TRUE) %>% filter(Indicator.Code == "NY.GDP.MKTP.PP.KD") %>% select(Country.Code,paste0("X",year))
names(WB_data) <- c("ISO","GDPPPP")


#GTAP aggregation rule

matrix_GTAP <- t(read.csv(path_GTAP,sep = "|",header = FALSE,row.names = 1)) %>%
  as.data.frame()

matrix_GTAP <- pivot_longer(matrix_GTAP,colnames(matrix_GTAP),names_to = "IMACLIM_Region",values_to = "GTAP_Region")
#Removign empty rows
matrix_GTAP <- matrix_GTAP[!matrix_GTAP$GTAP_Region=="",]
matrix_GTAP$GTAP_Region <- toupper(matrix_GTAP$GTAP_Region)

#ISO to GTAP
ISO_to_GTAP <- read.csv(path_ISO_to_GTAP,sep = ",")

##Agregating region 
n <- nrow(data_agreg)
m <- nrow(ISO_to_GTAP)
o <- nrow(matrix_GTAP)

#Find ISO correspondance

data_agreg$ISO <- countrycode(data_agreg$Country,"country.name","iso3c")
data_agreg$ISO[is.na(data_agreg$ISO)] <- 0
data_agreg$GTAP_reg <- rep(0,n)
data_agreg$IMACLIM_region<- rep(0,n)

for (i in 1:n){
  for (j in 1:m){
    if(data_agreg$ISO[i] == toupper(ISO_to_GTAP$ISO[j])){
      data_agreg$GTAP_reg[i]  <-  toupper(ISO_to_GTAP$REG_V10[j])
    } else {}
  }
}


for (i in 1:n){
  for (j in 1:o){
    if(data_agreg$GTAP_reg[i] == matrix_GTAP$GTAP_Region[j]){
      data_agreg$IMACLIM_region[i]  <-  matrix_GTAP$IMACLIM_Region[j]
    } else {}
  }
}

#Merging corporate taxes and GDP PPA data by ISO
data_final <- merge(data_agreg,WB_data, by = "ISO") %>% filter(IMACLIM_region != "0") %>% filter(!is.na(IMACLIM_region)) %>% 
  filter(!is.na(GDPPPP)) %>% select(ISO,IMACLIM_region,Corporate_Tax,GDPPPP)

data_final <- data_final %>% group_by(IMACLIM_region)%>% summarise(weighted.mean(Corporate_Tax,GDPPPP,na.rm = TRUE)) 
names(data_final)[2] <- paste0("Corporate_Tax ",year)

data_final$IMACLIM_region <- factor(data_final$IMACLIM_region,
                                     levels = c("USA","CAN","EUR","JAN","CIS","CHN","IND","BRA","MDE","AFR","RAS","RAL")) 
data_final <- arrange(data_final,IMACLIM_region)


##############################################
######### EXPORTING DATA #####################
##############################################
write.csv2(data_final,paste0(path_export,"/CT_export.csv"),row.names = FALSE)

