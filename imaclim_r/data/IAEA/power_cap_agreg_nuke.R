# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

################################################################################
######################Agregating Nuclear 2014 installed capacities##############
################################################################################

############Loading packages
library(tidyverse)

#Nuclear data from the International Atomic Energy Agency https://www-pub.iaea.org/MTCD/Publications/PDF/rds2-35web-85937611.pdf

#=============================================#
#==============Data import====================#
#=============================================#

args = commandArgs(trailingOnly = TRUE)

path_data <- args[1]
path_export <- args[2]

Nuke <- data.frame((read.csv(path_data,header = TRUE, dec = ".",sep = ";")))

# exact string in path_data after 'Nuclear_Power'
Nuke_file <- gsub('.*Nuclear_Power_(.*)\\.csv', '\\1', path_data)

#=============================================#
#==============Data processing================#
#=============================================#

colnames(Nuke)[3] <- "Power_MW"

list_reg <- c("USA","CAN","EUR","JAN","CIS","CHN","IND","BRA","MDE","AFR","RAS","RAL")

Nuke <- Nuke %>% group_by(IMC_Reg) %>% summarise(Nuke = sum(Power_MW))

# Add a value of 0 for the regions that are not in the data
Nuke <- Nuke %>% complete(IMC_Reg = list_reg) %>% replace_na(list(Nuke = 0))

Nuke$IMC_Reg <- factor(Nuke$IMC_Reg,
                       levels = list_reg)

#=============================================#
#==============Data export====================#
#=============================================#

Nuke <- arrange(Nuke,IMC_Reg) %>% select(Nuke)


if (Nuke_file == "2024") {
    colnames(Nuke) <- c("//2024 installed cap of Nuke (conventionnal) from the International Atomic Energy Agency")
  write.csv2(Nuke,paste0(path_export,"/Nuke2024.csv"),row.names = FALSE)
}

if (Nuke_file == "Reactor") {
        colnames(Nuke) <- c("//2024 installed cap of Nuke (conventionnal) from the International Atomic Energy Agency")
    write.csv2(Nuke,paste0(path_export,"/Nuke2014.csv"),row.names = FALSE)
    }

if (Nuke_file == "planned_2024") {
        colnames(Nuke) <- c("//Planned Nuke installations as of 2024, International Atomic Energy Agency")
    write.csv2(Nuke,paste0(path_export,"/Nukeplanned_2024.csv"),row.names = FALSE)
    }


