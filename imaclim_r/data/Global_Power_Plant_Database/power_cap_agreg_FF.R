// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

################################################################################
######################Agregating fossil fuel 2014 installed capacities##########
################################################################################

############Loading packages

library(tidyverse)
library(countrycode)
library(openxlsx)

#Note: the benchmark for total installed cap : https://www.iea.org/data-and-statistics/charts/installed-power-generation-capacity-by-source-in-the-stated-policies-scenario-2000-2040
#A look into the source code of the page give the data from the chart:
#     Coal,Gas,Oil,Nuclear,Wind,Solar PV,Other renewables,Hydro,Battery storage
#2014,1888.46494,1570.281281,440.121206,398.359,348.931031,176.6727639,131.8087405,1174.37252,1.5076802
#2020,2125.790605,1875.598324,413.5270801,419.119,688.2511474,715.4824246,184.1297103,1338.065639,23.66204933

#=============================================#
#==============Data import====================#
#=============================================#


args = commandArgs(trailingOnly = TRUE)
path_data <- args[[1]]
path_retired<- args[[2]]
target_year <- args[[3]]
extract_var <- args[[4]]
path_GTAP <- args[[5]]
path_ISO_to_GTAP<- args[[6]]
path_export <- args[[7]]

######GTAP matrix (correspondance between GTAP and IMC regions)
matrix_GTAP <- t(read.csv(path_GTAP,sep = "|",header = FALSE,row.names = 1)) %>%
  as.data.frame()
#Getting GTAP aggregation matrix in long format
matrix_GTAP <- pivot_longer(matrix_GTAP,colnames(matrix_GTAP),names_to = "IMACLIM_Region",values_to = "GTAP_Region")
#Removign empty rows
matrix_GTAP <- matrix_GTAP[!matrix_GTAP$GTAP_Region=="",]
matrix_GTAP$GTAP_Region <- toupper(matrix_GTAP$GTAP_Region)

######ISO to GTAP matrix
ISO_to_GTAP <- read.csv(path_ISO_to_GTAP,sep = ",")

#####Global Power Plant Database
vars <- c("country","country_long","capacity_mw","primary_fuel")

GPPMW <- data.frame((read.csv(path_data,header = TRUE, dec = ".",sep = ","))) %>% select(all_of(vars)) %>% filter(primary_fuel == extract_var)

#####Retired coal power plants according to Global Coal Plant Tracker
#https://globalenergymonitor.org/projects/global-coal-plant-tracker/summary-data/
#July 2021
if (extract_var == "Coal") {
  
  retiredMW <- read.xlsx(path_retired,startRow = 4)
}


#=============================================#
#==============Data processing for 2020=======#
#=============================================#

#Set IMACLIM_region based on ISO/GTAP region correspondance

n <- nrow(GPPMW)
m <- nrow(ISO_to_GTAP)
o <- nrow(matrix_GTAP)

#Find ISO correspondance

GPPMW$ISO <- countrycode(GPPMW$country_long,"country.name","iso3c")
GPPMW$ISO[is.na(GPPMW$ISO)] <- 0
GPPMW$GTAP_reg <- rep(0,n)
GPPMW$IMACLIM_region<- rep(0,n)

for (i in 1:n){
  for (j in 1:m){
    if(GPPMW$ISO[i] == toupper(ISO_to_GTAP$ISO[j])){
      GPPMW$GTAP_reg[i]  <-  toupper(ISO_to_GTAP$REG_V10[j])
    } else {}
  }
}


for (i in 1:n){
  for (j in 1:o){
    if(GPPMW$GTAP_reg[i] == matrix_GTAP$GTAP_Region[j]){
      GPPMW$IMACLIM_region[i]  <-  matrix_GTAP$IMACLIM_Region[j]
    } else {}
  }
}


#The variable totalMW describes the installed capacity in MW for a given type of fossil fuel.
GPPMW <- GPPMW %>% filter(IMACLIM_region !=0) %>%  group_by(IMACLIM_region) %>% summarise(totalMW = sum(capacity_mw))


#For retired coal capacities
if (extract_var == "Coal") {

colnames(retiredMW) <- gsub("*\\.0","",colnames(retiredMW))
colnames(retiredMW)[2:length(retiredMW)] <-  paste0("n_",colnames(retiredMW)[2:length(retiredMW)])

retiredcol <- paste0("n_",2014:target_year) #get the needed years to work with
retiredMW <- select(retiredMW,Country,all_of(retiredcol))
gsubfun <- function(x){
  gsub(",","",x)}

#Removing comas and transforming into numeric
retiredMW <- retiredMW %>% apply(2,gsubfun) %>% as.data.frame
retiredMW <- retiredMW %>% select(-c("Country")) %>% apply(2,as.numeric) %>% cbind(select(retiredMW,Country),.)


#Set IMACLIM_region based on ISO/GTAP region correspondance

n <- nrow(retiredMW)
m <- nrow(ISO_to_GTAP)
o <- nrow(matrix_GTAP)

#Find ISO correspondance

retiredMW$ISO <- countrycode(retiredMW$Country,"country.name","iso3c")
retiredMW$ISO[is.na(retiredMW$ISO)] <- 0
retiredMW$GTAP_reg <- rep(0,n)
retiredMW$IMACLIM_region<- rep(0,n)

for (i in 1:n){
  for (j in 1:m){
    if(retiredMW$ISO[i] == toupper(ISO_to_GTAP$ISO[j])){
      retiredMW$GTAP_reg[i]  <-  toupper(ISO_to_GTAP$REG_V10[j])
    } else {}
  }
}


for (i in 1:n){
  for (j in 1:o){
    if(retiredMW$GTAP_reg[i] == matrix_GTAP$GTAP_Region[j]){
      retiredMW$IMACLIM_region[i]  <-  matrix_GTAP$IMACLIM_Region[j]
    } else {}
  }
}

# a check with filter(retiredMW,IMACLIM_region== 0) that country with unmatched IMACLIM_reg either have zero decomissionned
#coal capacity (except Uzbekistan) or correspond to total for world/regions


retiredMW <- filter(retiredMW,IMACLIM_region!=0) #keeping only countries with knowed IMC reg
retiredMW$new_cap_2015 <- retiredMW %>% select((which(colnames(retiredMW) == "Country")+1):paste0("n_",target_year)) %>% apply(1,sum)#relative paths to new capacity additions
retiredMW2014 <- retiredMW %>% group_by(IMACLIM_region) %>% summarise(totalcoal = sum(new_cap_2015))
}

#=============================================#
#======Data processing: get back to 2014======#
#=============================================#

##Getting IEA values https://www.iea.org/data-and-statistics/charts/installed-power-generation-capacity-by-source-in-the-stated-policies-scenario-2000-2040
##See intro for accurate chart values

Coal2020 <- 2125000
Gas2020 <-  1875000
Oil2020 <-  413000

Coal2014 <- 1890000
Gas2014 <-  1570000
Oil2014 <-  440000

var2014 <- get(paste0(extract_var,"2014"))
vartarget <- get(paste0(extract_var,target_year))

GPPMW$MWtarget <- GPPMW$totalMW*(vartarget/sum(GPPMW$totalMW))

GPPMW$MW2014 <- round(GPPMW$MWtarget*(var2014/sum(GPPMW$MWtarget)))
if (extract_var == "Coal") {
GPPMW$MW2014 <- GPPMW$MWtarget - retiredMW2014$totalcoal
}



#=============================================#
#=================Data export=================#
#=============================================#


GPPMW$IMACLIM_region <- factor(GPPMW$IMACLIM_region,
                                   levels = c("USA","CAN","EUR","JAN","CIS","CHN","IND","BRA","MDE","AFR","RAS","RAL"))
GPPMW <- arrange(GPPMW,IMACLIM_region)

GPPMW <- select(GPPMW,MW2014)

colnames(GPPMW) <- paste0("//2014 installed cap from Global Power Plant Database of ",extract_var,".")

write.csv2(GPPMW,paste0(path_export,"/Cap_MW_ref_",extract_var,".csv"),row.names = FALSE)

