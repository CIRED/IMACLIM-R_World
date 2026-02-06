# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

######################################################################
###########. NPi & NDC - Post Glasgow ..##############################
######################################################################

############################
## Thibault Briera
## September 2023
## briera.cired@gmail
############################

# https://zenodo.org/record/7767193

#################################
####.. Arguments ..############
#################################

args <- commandArgs(trailingOnly = TRUE)

path_data_ndc <- args[1]
path_output <- args[2]
crit_emi  <- args[3]
ag_rule <- args[4]
# model is optionnal, either given or NA
if (length(args > 4)) {
  model <- args[5]
} else {
  model <- NA
}

path_data_ndc_df  <-  paste0(path_data_ndc, "/data/global_ite2_allmodels.csv")
path_region_ndc_df  <- paste0(path_data_ndc, "/manual/regions_table.csv")

#################################
####.. Environment ..############
#################################

# Want to force install packages?
force_install_packages <- FALSE

source("scripts/functions_NDC.R")
source("scripts/packages_NDC.R")

#--------------------------------------------------------------#

#################################
####.. Choosing reg agg ..#######
#################################


#################################
#######.. Loading data ..########
#################################

## Full data

df_global <- read.csv(path_data_ndc_df)


## Regional table: 4 models in the paper, with different region names and aggregation

regions_table <- read.csv(path_region_ndc_df, sep = ";")

#################################
###. Processing data: CO2 emi .###
#################################

#CO2 emissions

df_co2 <- tidy_ar6(df_global, "Emissions|CO2")

df_co2 <- aggregate_ar6(df_co2, ag_rule)  %>% reag_ar6()  %>% pivot_ar6()


# computing 2030 and 2025 delta from 2020
df_co2 <- df_co2 %>% mutate(Delta_30_20 = `X2030` / `X2020`) %>% mutate(Delta_25_20 = `X2025` / `X2020`) %>% select(c("Model", "Scenario", "Region_IMC", "Delta_25_20", "Delta_30_20"))  %>% group_by(Scenario, Region_IMC)  %>% filter(Scenario %in% c("CP_EI", "NDC_EI", "NDC_LTT"))
# the remaining NAs are for ODA or OE regions which are unknown
df_co2 <- df_co2 %>% filter(Region_IMC != "World") %>% ungroup()


#################################
###. Ojective selection .########
#################################

df_co2 <- select_obj(df_co2,crit_emi,model)


#################################
###. Exporting data: CO2 emi .###
#################################
# selecting only the values to get a tidy csv file

df_co2 <- df_co2 %>% ungroup() %>%  select(c("Scenario", "Region_IMC", "Delta_25_20", "Delta_30_20"))


# create two separate datasets for CP_EI and NDC_EI

NPi <- df_co2 %>% filter(Scenario == "CP_EI") %>% select(-c(Scenario))

NDC <- df_co2 %>% filter(Scenario == "NDC_EI") %>% select(-c(Scenario))

write.csv(NPi, paste0(path_output,"/emi_control_NPi_",ag_rule,".csv"), row.names = FALSE)
write.csv(NDC, paste0(path_output,"/emi_control_NDC_",ag_rule,".csv"), row.names = FALSE)