# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

################################################################################
################################################################################
##~~~~~~~~~~~~~~~~~~~~Global WACC paper data treatment~~~~~~~~~~~~~~~~~~~~~~~~##
################################################################################
################################################################################

###WARNING: missing GDP for Taïwan and venezuela

###########################
####### LIBRAIRIES and ####
#######  FUNCTIONS ########
###########################

library(countrycode)
library(tidyverse)

#args from shell script
args = commandArgs(trailingOnly = TRUE)

ISO_to_IMC_f <- args[[5]]
source(ISO_to_IMC_f)

weighted_mean_global <- function(df,weights){
  summarise(weighted.mean(df,weights,na.rm = TRUE))
}

###########################
####### DATA PATHS ########
###########################

path_data <- args[[1]]
GTAP <- args[[2]]
ISO <- args[[3]]
path_export <- args[[4]]

###########################
####### IMPORTING #########
###########################

df_WACC <- read.csv(path_data, sep = ";") %>% as_tibble()


###########################
####### TIDY DATA #########
###########################


names(df_WACC)[1] <- "Country"
names(df_WACC)[length(df_WACC)] <- "GDP_current"

df_WACC <- df_WACC %>% filter(!is.na(Year)) %>% filter(Country != "EU28 (weighted average by GDP)") #removing empty rows and the EU28 value

# turning % into numeric values

remove_pct <- function(df){sub("%","",df)}
  
df_WACC <- apply(df_WACC,1,remove_pct) %>% t() %>% as_tibble() #removes all % values in the df and turning it into a tibble again

# GDP as numeric
df_WACC$GDP_current <- as.numeric(df_WACC$GDP_current)
# get back the techno list
cols.techno <- c(3:(length(df_WACC)-1))
Technos <- names(df_WACC)[cols.techno]
df_WACC[cols.techno] <- sapply(df_WACC[cols.techno],as.numeric)


###########################
##### DATA PROCESSING #####
###########################

#Mannually adding some missing GDP (Venezuela, Taiwan)
# from https://countryeconomy.com/gdp
# Controlled by several countries in the WACC database to make sure GDP corresponded (they do)
df_WACC[which(df_WACC$Country == "Taiwan"),length(df_WACC)] <- 609198000000
df_WACC[which(df_WACC$Country == "Venezuela"),length(df_WACC)] <- 98400000000

#Get the IMC region

df_WACC$Country <- countrycode(df_WACC$Country,"country.name","iso3c") #as we need an ISO code for the function

df_WACC <- ISO_to_IMC(df_WACC,GTAP,ISO)

              



df_WACC <- df_WACC %>% filter(!is.na(GDP_current))

#Weighted mean by reg

df_final <- df_WACC %>% group_by(IMACLIM_region) %>% summarise_at(vars(all_of(Technos)),funs(weighted.mean(.,GDP_current))) 
#the final dataset is ready, just need to rearrange

df_final$IMACLIM_region <- factor(df_final$IMACLIM_region,
                            levels = c("USA","CAN","EUR","JAN","CIS","CHN","IND","BRA","MDE","AFR","RAS","RAL")) 

df_final <- df_final %>% arrange(IMACLIM_region)

###########################
####### EXPORTING #########
###########################

df_final <- df_final %>% select(-IMACLIM_region)

write.csv(df_final,paste0(path_export,"/WACC_Global.csv"),row.names = FALSE)
