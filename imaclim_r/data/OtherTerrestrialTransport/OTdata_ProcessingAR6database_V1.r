# Rail, bus and trucks final energy and energy services ---------------------------------------

# This code aims to prepare the data used to disaggregate the OT transport in Imaclim-R World from the AR6 scenarios database. 
# Version 11/2023


# Loading libraries (there seem to be too many, as this code is a longer extract)
library(openxlsx)
library(tidyr)
library(dplyr)
library(stringr)
library(zoo)
library(officer)
library(ggplot2)
library(hrbrthemes)
library(ggExtra)
library(plotly)
library(htmlwidgets)
library(fmsb)
library(forcats)
library(viridis)

# Loading of the AR6 files
setwd("C:/Users/Thomas/Documents/Task1.2/AR6")
AR6_meta <- read.xlsx("AR6_Scenarios_Database_metadata_indicators_v1.0.xlsx", sheet = "meta")
AR6_data<-read.csv2("AR6_Scenarios_Database_R10_regions_v1.0.csv",sep=",",header = TRUE, check.names = FALSE, colClasses = c(rep("character", 20), rep("NULL", ncol(read.csv2("AR6_Scenarios_Database_R10_regions_v1.0.csv", sep = ",", nrows = 1)) - 20)))

#colnames(AR6_data)[1:5]<-c("model","scenario","region","variable","unit")

# We use the "meta" file to select vetting scenarios
AR6_exclude<-AR6_meta %>%
  select(Model,Scenario,Category_Vetting_historical) %>%
  mutate(exclude = ifelse(str_detect(Category_Vetting_historical,'failed')==TRUE,'TRUE','FALSE')) %>%
  rename(model='Model',scenario='Scenario')

# Pre-processing
data_ini_R1<-left_join(AR6_data,AR6_exclude, by=c("scenario", "model")) %>%
  filter(exclude=="FALSE") %>%
  select(-c(unit, exclude)) %>%
  mutate(variable=str_replace_all(variable,"[|/ ]", "_")) %>%
  mutate(variable=str_to_lower(variable, locale = "en")) %>%
  select(model,scenario,region,variable,`2010`,`2015`,`2020`) %>%
  filter(grepl("final_energy|energy_service|gdp_mer", variable)) %>%
  pivot_longer(-c(model,scenario,region,variable),names_to = 'year',values_to = "value") %>%
  mutate(value = as.numeric(value))


remove(AR6_data) # We remove it to free up disk space

# We loade a correspondence file for regions (Imaclim, ISO, etc.)
setwd("C:/Users/Thomas/OneDrive/post-these_Air/CIRED/Task3.5")
region_iso <- read.xlsx('cor_region_im_iso.xlsx',sheet = "Feuil1") 

# Extraction des données d'énergie finale et de servie énergétique
data_OT_AR6 <- data_ini_R1 %>%
  filter(year == 2015) %>%
  filter(grepl("gdp_mer|rail|bus|road_freight|freight_road", variable)) %>%  
  filter(!is.na(value)) %>%
  separate(variable, into = c("type", "category"), sep = "_transportation_") %>%
  mutate(category = case_when(
    category == "freight_railways" ~ "rail_freight",
    category == "passenger_railways" ~ "rail_passenger",
    category == "passenger_road_bus" ~ "road_passenger_bus",
    category == "freight_road" ~ "road_freight",
    TRUE ~ category)) %>%
  filter(!grepl("road_freight_", category)) %>%  
  filter(grepl("freight|passenger", category)|type == "gdp_mer") %>%
  #pivot_wider(id_cols = c(model, scenario, region, year,category), names_from = type,values_from = value)
  group_by(region, type, category) %>%
  summarize(value = mean(value, na.rm = TRUE)) %>%
  group_by(type, region) %>%
  mutate(share = value / sum(value)) %>%
  pivot_wider(names_from = c(type, category), values_from = c(share, value)) %>%
  rename(region_iso = "region") %>%
  left_join(region_iso %>% select(-macro_region), by = 'region_iso') %>%
  rename(gdp_mer = "value_gdp_mer_NA",share_gdp_mer = "share_gdp_mer_NA") %>%
  select(region, gdp_mer, share_gdp_mer, everything()) %>%
  ungroup() %>%
  select(-region_iso,-region_iso_long) %>%
  mutate(share_gdp_mer = case_when(region == "CAN" ~ 0.0789, region == "USA" ~ 0.9211, region == "BRA" ~ 0.2721, region == "RAL" ~ 0.7279, TRUE ~ share_gdp_mer)) %>%
  mutate(across(starts_with("value"), ~ . * share_gdp_mer)) %>%
  arrange(factor(region, levels = imaclim_order)) %>%
  filter(!is.na(region)) %>%
  select(-gdp_mer,-share_gdp_mer)
  
# Write the CSV file used in Imaclim-R World
setwd("C:/Users/Thomas/OneDrive/post-these_Air/CIRED/modelling")  
write.table(data_OT_AR6, "data_OT_varioussources.csv", row.names=FALSE, sep="|",dec=".", na="NA", col.names = TRUE)
