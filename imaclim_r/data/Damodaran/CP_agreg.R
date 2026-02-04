// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera, Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

################################################################################
###################### DAMODARAN COUNTRY PREMIUMS ##############################
################################################################################

#http://pages.stern.nyu.edu/~adamodar/New_Home_Page/datafile/ctryprem.html

###########################
####### LIBRAIRIES ########
###########################

library(countrycode)
library(tidyverse)

###########################
####### DATA PATHES #######
###########################

args = commandArgs(trailingOnly = TRUE)

path_data <- args[1]
year <- args[2]
path_GTAP <- args[3]
path_ISO_to_GTAP <- args[4]
path_WB <- args[5]
path_export <- args[6]
###########################
##### DATA PROCESSING #####
###########################


data_agreg <- read.csv(path_data, dec = ".", sep = ",",skip = 6, header = TRUE) %>% 
  select(Country,Africa,Country.Risk.Premium) #In the xls file the Region column is a filter that starts with Africa
names(data_agreg)[3] <- "CP"
names(data_agreg)[2] <- "Region"
names(data_agreg)[1] <- "Country"
#convert in num rather than %
data_agreg$CP <- gsub("%","",data_agreg$CP)
data_agreg$CP <- gsub(",",".",data_agreg$CP) %>% as.numeric()
data_agreg$CP <- data_agreg$CP/100

#World Bank GDP PPP data
WB_data <- read.csv(path_WB, dec = ".",sep = ",", header = TRUE) %>% filter(Indicator.Code == "NY.GDP.MKTP.PP.KD") %>% select(Country.Code,paste0("X",year))
names(WB_data) <- c("ISO","GDPPPP")

#ISO to GTAP agregation rule

ISO_to_GTAP <- read.csv(path_ISO_to_GTAP,sep = ",")

#GTAP to IMC agregation rule
matrix_GTAP <- t(read.csv(path_GTAP,sep = "|",header = FALSE,row.names = 1)) %>%
  as.data.frame()

matrix_GTAP <- pivot_longer(matrix_GTAP,colnames(matrix_GTAP),names_to = "IMACLIM_Region",values_to = "GTAP_Region")
#Removign empty rows
matrix_GTAP <- matrix_GTAP[!matrix_GTAP$GTAP_Region=="",]
matrix_GTAP$GTAP_Region <- toupper(matrix_GTAP$GTAP_Region)



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
  filter(!is.na(GDPPPP)) %>% select(ISO,IMACLIM_region,CP,GDPPPP)

data_export <- data_final %>% group_by(IMACLIM_region)%>% summarise(weighted.mean(CP,GDPPPP,na.rm = TRUE))
names(data_export)[2] <- "CP"

data_export$IMACLIM_region <- factor(data_export$IMACLIM_region,
                                        levels = c("USA","CAN","EUR","JAN","CIS","CHN","IND","BRA","MDE","AFR","RAS","RAL")) 
data_export$IMACLIM_region <- factor(data_export$IMACLIM_region,)

data_export <- arrange(data_export,IMACLIM_region) %>% select(CP)

###########################
##### EXPORTING DATA ######
###########################

colnames(data_export) <- paste0("//",colnames(data_export))
write.csv(data_export,paste0(path_export,"/CP_export.csv"),row.names = FALSE)
