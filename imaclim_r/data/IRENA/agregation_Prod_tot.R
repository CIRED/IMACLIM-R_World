# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

#####################################################################################
#################Aggregating IRENA's installed VRE capacities####################
#####################################################################################

#WARNING: in order to generate the aggregated installed VRE capacities, use the IRENA_Stats_Tools
#choose the right year in the menu without geographical filter and copy the data tab in csv format

##########################Packages###############################
library(tidyverse)
###############################################################################
##########################Data import##########################################
################################################################################

args = commandArgs(trailingOnly = TRUE)

annee <- args[1]

#insert here path to imported csv (/data/IRENA/prod)
path_IRENA <- args[2]
#insert here path to GTAP aggregation rule
path_GTAP <- args[3]
#insert here path to exported csv (/data/IRENA/prod)
path_export <-  args[4]

#Imaclim Regions
Reg_IMC <- c("USA","Canada","Europe","OECD Pacific","CEI","China","India","Brazil",
             "Middle East","Africa","Rest of Asia","Rest of Latin America")

#installed capacity
data_agreg <- read.csv(path_IRENA, sep = ";", header = FALSE)

names(data_agreg) <- c("Region","Country","ISO","RE_or_NRE","Technology_type","Technology","Grid","Year","Prod_in_GWh)")


matrix_GTAP <- t(read.csv(path_GTAP,sep = "|",header = FALSE,row.names = 1)) %>%
  as.data.frame()
#Getting GTAP aggregation matrix in long format
matrix_GTAP <- pivot_longer(matrix_GTAP,colnames(matrix_GTAP),names_to = "IMACLIM_Region",values_to = "GTAP_Region")
#Removign empty rows
matrix_GTAP <- matrix_GTAP[!matrix_GTAP$GTAP_Region=="",]
matrix_GTAP$GTAP_Region <- toupper(matrix_GTAP$GTAP_Region)

matrix_GTAP$IMACLIM_Region <- as.factor(matrix_GTAP$IMACLIM_Region) %>% 
  fct_recode("Rest of Latin America" = "RAL", "Rest of Asia"= "RAS" ,"Africa"= "AFR","Europe" = "EUR" , "Middle East" = "MDE","CEI" = "CIS","OECD Pacific" = "JAN","Brazil" ="BRA","Canada" = "CAN","China" = "CHN" ,"India" = "IND" ,"USA" = "USA")
matrix_GTAP$IMACLIM_Region <- as.character(matrix_GTAP$IMACLIM_Region) #maybe useless



################################################################################
#########################Data cleaning and tidying##############################
################################################################################

#data from IRENA tool must be cleaned if not done manually before
#Remark: a bit messy but allows to get raw csv copies of the IRENA tool as inputs

#Set white spaces to NA and get numeric variable on Prod_in_GWh col
data_agreg$Prod_in_GWh <- gsub(" ","",data_agreg$Prod_in_GWh) %>% as.numeric()

#Adds NA to empty rows
data_agreg <- data_agreg[!apply(data_agreg == "", 1, all),]

#Removes rows and cols with NA only
data_agreg <- data_agreg[rowSums(is.na(data_agreg)) != ncol(data_agreg),]
data_agreg <- data_agreg[,colSums(is.na(data_agreg)) !=nrow(data_agreg)]

#Finally removing eventual remaining rows with NAs in Installed Cap to get our dataset almost cleaned
#don't know why filter(data_agreg, !is.na(Prod_in_GWh)) does not work
data_agreg <- data_agreg[rowSums(is.na(data_agreg)) == 0,]

#Get the wanted dataset
data_agreg <- data_agreg %>% select(Region, Country, ISO, Technology, Prod_in_GWh,Year)

#Variables as factor

data_agreg$Country <- as.factor(data_agreg$Country)
levels(data_agreg$Country)

data_agreg$Technology <- as.factor(data_agreg$Technology)
levels(data_agreg$Technology)

#########################Production aggregation##########################################

n <- nrow(data_agreg)
m <- nrow(matrix_GTAP)

data_agreg$IMACLIM_region <- rep(0,n)

#Set IMACLIM_region based on ISO/GTAP region correspondance

for (i in 1:n){
  for (j in 1:m){
    if(data_agreg$ISO[i] == matrix_GTAP$GTAP_Region[j]){
      data_agreg$IMACLIM_region[i]  <-  matrix_GTAP$IMACLIM_Region[j]
    } else {}
  }
}

#To get an idea of missing countries in GTAP regions: 92 countries, 
#for less that 1 000 MW of installed cap in 2014
filter(data_agreg,IMACLIM_region == 0) %>% group_by(Country) %>% summarize()

filter(data_agreg,IMACLIM_region == 0) %>% select(Prod_in_GWh) %>% sum()

#check if there is any big mistake (>100MW)
filter(data_agreg,IMACLIM_region == 0 & Prod_in_GWh > 100) %>% group_by(Country) %>% summarize()

################################################################################
#############REMARK: any way to display a message when substantial##############
#############installed cap is missed?###########################################
################################################################################

###For remaining countries, set the IMACLIM Region to the IRENA region

for (i in 1:n){
  if(data_agreg$IMACLIM_region[i] == 0 | data_agreg$IMACLIM_region[i] == "" ){
    data_agreg$IMACLIM_region[i] <- data_agreg$Region[i]
  }
}

#Get all in factor

data_agreg$IMACLIM_region <- as.factor(data_agreg$IMACLIM_region)
levels(data_agreg$IMACLIM_region)

#and harmonize IRENA region names with IMACLIM's. This way, only small countries which does not appear in GTAP shall be concerned

#Asia => Rest of Asia
#Central America and the Caribbean => Rest of Latin America
#Oceania => Rest of Asia
#South America => Rest of Latin America


#In recent year (>2015) Groenland appears which creates a North America region, shall be checked
#North America => Rest of Latin America
if(sum(levels(data_agreg$IMACLIM_region)=="North America")==0){
  levels(data_agreg$IMACLIM_region) <- c("Africa","Rest of Asia","Brazil","Canada","CEI","Rest of Latin America","China","Europe","India",
                                         "Middle East","Rest of Asia","OECD Pacific","Rest of Asia","Rest of Latin America","Rest of Latin America","USA")} else{
                                           levels(data_agreg$IMACLIM_region) <- c("Africa","Rest of Asia","Brazil","Canada","CEI","Rest of Latin America","China","Europe","India",
                                                                                  "Middle East","Rest of Latin America", "Rest of Asia","OECD Pacific","Rest of Asia","Rest of Latin America","Rest of Latin America","USA")
                                         }
###############################Final step : aggregating and filling regions with
###############################no installed cap in 2014#########################
year <- data_agreg$Year[30] #any row to get the year back and verify that everything is good before exporting the file


#Drop unused levels
data_agreg$IMACLIM_region <- droplevels(data_agreg$IMACLIM_region)
#We get our 12 regions
levels(data_agreg$IMACLIM_region)


if(year == annee){
  Cap<- aggregate(data_agreg$Prod_in_GWh, by = list(data_agreg$IMACLIM_region), FUN = sum)
  names(Cap) <- c("Region","Prod_in_GWh")}

Cap$Region <- factor(Cap$Region, levels = Reg_IMC)
Cap <- arrange(Cap,Region)

data <- Cap  %>%select(Prod_in_GWh)
names(data) <- paste0('//Total electricity production. Data from IRENA')
write.csv2(data,paste0(path_export,"Prod_tot_",annee,"_",".csv"),row.names = FALSE)
