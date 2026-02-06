# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

library(fredr)
library(dplyr)


args = commandArgs(trailingOnly = TRUE)

stop_date <- args[[1]]

mean_na_round <- function(x){
  round(mean(x,na.rm=T),3)
} #for summarise_at

path_file <- paste0(getwd(),"/DGS10.csv")
#need an API key to run https://fredaccount.stlouisfed.org/apikey
fredr_set_key("08375ed0cb899a86943c58a38e7c3e33")

DGS10 <- fredr(series_id = "DGS10") #https://fred.stlouisfed.org/series/DGS10/

DGS10 <- DGS10 %>% select(date,value) %>% filter(date>"2014-12-31" & date<stop_date) %>% mutate(Year = substr(date,1,4))


DGS10 <- DGS10 %>% group_by(Year) %>% summarise_at(vars(value), list(mean_risk_free = mean_na_round))

write.csv(DGS10,path_file,row.names = F)                                     
                                                   