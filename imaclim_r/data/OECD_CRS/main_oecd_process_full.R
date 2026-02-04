// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

########################################
######~~     OECD DAC-CRS data     ~~########
#########################################

############################
## Thibault Briera
## July 2023
## briera.cired@gmail
############################

# This script processes the OECD DAC data on climate finance to extract the regional distribution of renewable energy finance + the share of renewable energy finance in total energy finance over the period 2017-2020.
# https://www.oecd.org/dac/financing-sustainable-development/development-finance-topics/climate-change.htm

##########################
######~~ Init  ~##########
##########################

source("scripts/packages.R")
source("scripts/functions.R")
dir <- getwd()

#args from shell script
args = commandArgs(trailingOnly = TRUE)

data_OECD <- args[[1]]

############################################
######~~ OECD data treatment: regional ~~###
######~~ distribution of international ~~###
######~~  public climate finance       ~~###
############################################


## parameters

# want to export results?
export <- TRUE

# extended definition of wind and solar finance?
extended_def_ren <- FALSE

# years to be considered
year_dac <- c("2017", "2018", "2019", "2020")

##########################
##~~ Non-VRE techno  ~~###
##########################
fossil <- c("Coal-fired electric power plants", "Energy generation, non-renewable sources, unspecified", "Natural gas-fired electric power plants", "Non-renewable waste-fired electric power plants", "Retail gas distribution", "Oil-fired electric power plants")

energy_other_techno <- c("Biofuel-fired power plants", "District heating and cooling", "Electric mobility infrastructures", "Energy conservation and demand-side efficiency", "Energy education/training", "Geothermal energy", "Heat plants", "Hydro-electric power plants", "Nuclear energy electric power plants and nuclear safety", "Electric power transmission and distribution (isolated mini-grids)", "Marine energy")

if (!extended_def_ren) {
energy_other_techno  <- c(energy_other_techno, "Energy policy and administrative management", "Electric power transmission and distribution (centralised grids)", "Energy research")
}

##########################
####~~ Processing  ~~#####
##########################
## Initialisation

# regional shares of renewable energy finance over years
share_ren_reg <- list()
# total renewable energy finance over years
total_ren_list <- list()
# total energy finance over years
total_ener_list <- list()

## main loop over years: extracting data, tidying, and computing shares
for (year in year_dac){

## import data

oecd <- read_xlsx(paste0(data_OECD,"/DAC_", year, ".xlsx"), sheet = 2)

### tidy data
names(oecd)[names(oecd) == "Sector (detailed)"] <- "Sector_detailed" # removing space in column name
names(oecd)[names(oecd) == "Recipient Region"] <- "Recipient_Region"
names(oecd)[names(oecd) == "Climate-related development finance - Commitment - Current USD thousand"] <- "Climfin_curr"
oecd_energy <- oecd %>% filter(Sector_detailed == "II.3. Energy")

#excluding China
oecd_energy <- oecd_energy %>% filter(Recipient != "China (People's Republic of)")

# we introduce India before passing into factors
oecd_energy$Recipient_Region <- ifelse(oecd_energy$Recipient == "India", "IND", oecd_energy$Recipient_Region)
oecd_energy$Recipient_Region <- ifelse(oecd_energy$Recipient == "Brazil", "BRA", oecd_energy$Recipient_Region)

#recoding factors to IMACLIM-R coverage
oecd_energy$Recipient_Region <- recode_factor(oecd_energy$Recipient_Region, "America" = "RAL", "Caribbean & Central America" = "RAL", "South America" = "RAL", "Far East Asia" = "RAS", "South & Central Asia" = "RAS", "Africa" = "AFR", "Europe" = "CIS", "Middle East" = "MDE", "North of Sahara" = "AFR", "Oceania" = "RAS", "South of Sahara" = "AFR", "Asia" = "RAS")

#renaming subsector
oecd_energy$Sub_sector <- oecd_energy$`Sub-sector`

oecd_energy %>% group_by(Sub_sector) %>% summarise(sum = sum(Climfin_curr)) %>% arrange(desc(sum)) %>% print(.,n=30)

## removing fossil fuel and other non-VRE %>% filter(Sub_sector %nin% fossil)
oecd_ren <- oecd_energy %>% filter(Sub_sector %nin% fossil)  %>% filter(Sub_sector %nin% energy_other_techno)

## total energy finance and renewable energy finance
total_ener <-  sum(oecd_energy$Climfin_curr)
total_ren <- oecd_ren %>% summarise(sum = sum(Climfin_curr)) %>% pull(sum)

# regional shares of renewable energy finance in % of total renewable energy finance
share_fin <- oecd_ren %>% group_by(Recipient_Region) %>% summarise(Share_total_fin = sum(Climfin_curr) * 100 / total_ren)

#storing results
i <- as.double(year) - 2016

share_ren_reg[[i]] <- share_fin
share_ren_reg[[i]]$Year <- as.double(year)

total_ren_list[[i]] <- total_ren
total_ener_list[[i]] <- total_ener
}

## First input: share of renewable energy finance in total energy finance 

unlist(total_ren_list)/unlist(total_ener_list)
# between 38 to 29% of total energy finance

##########################
#~~ Merging datasets  ~~##
##########################

# regional shares of renewable finance
share_fin_df <- multi_join(share_ren_reg, full_join)

# share of renewable energy finance in total energy finance: used as inputs for IMACLIM-R
share_ren_ener <- tibble(Year = year_dac, Value = unlist(total_ren_list) / unlist(total_ener_list))


#all year dataset, reshaped for table
share_fin_df_all <- spread(share_fin_df, value = "Share_total_fin",  key = "Year")

# keeking BRA and Unspecified regions for table export
share_fin_df_raw <- share_fin_df  %>% group_by(Recipient_Region) %>% summarise(Av_share = mean(Share_total_fin))

# removing Unspecified regions to get the average share used as input for IMACLIM-R and distributing Unspecified share to other regions
share_fin_df_res  <- share_fin_df_raw %>% filter(Recipient_Region != c("Unspecified"))
resize <- sum(share_fin_df_res$Av_share)

share_fin_df_res$Av_share <- round(share_fin_df_res$Av_share * 100 / resize, 1)

# rounding
share_fin_df_res$Av_share <- round(share_fin_df_res$Av_share, 1)

# remvoving Brazil, reordering
share_fin_df_res <- share_fin_df_res %>% filter(Recipient_Region != c("BRA"))
share_fin_df_res$Recipient_Region <- factor(share_fin_df_res$Recipient_Region, levels = c("CIS", "IND", "MDE", "AFR", "RAS", "RAL"))

share_fin_df_res <- share_fin_df_res %>% arrange(Recipient_Region)


#rounding for table export: displayed in a table including Unspecifed and Brazil
share_fin_df_all[-1]  <-  share_fin_df_all[-1] %>% apply(2, function(x) round(x, 0))


##########################
#####~~ Exporting  ~~#####
##########################

if (export) {
  write.csv(share_fin_df_res, paste0(dir, "/Share_fin.csv"), row.names = FALSE)
}