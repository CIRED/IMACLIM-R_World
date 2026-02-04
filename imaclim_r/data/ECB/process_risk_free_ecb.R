// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

library(ecb)
library(ggplot2)
library(dplyr)

args = commandArgs(trailingOnly = TRUE)

stop_date <- args[[1]]

mean_na_round <- function(x){
  round(mean(x,na.rm=T),3)
} #for summarise_at

path_file <- paste0(getwd(),"/ecb_10.csv")

#Key for Germany - long-term interest rates
# 
key <- "IRS.M.DE.L.L40.CI.0000.EUR.N.Z"


hicp <- get_data(key)

hicp$obstime <- convert_dates(hicp$obstime)


hicp <- hicp %>% mutate(Year = substr(obstime,1,4))%>% filter(Year > 2014 & Year < stop_date) #keeping only 2015 - 2022

ecb_10y <- hicp %>% group_by(Year) %>% summarise_at(vars(obsvalue), list(mean_risk_free = mean_na_round)) %>% ungroup()

write.csv(ecb_10y,path_file,row.names = F) 
