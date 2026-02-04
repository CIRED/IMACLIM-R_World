// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

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

#=============================================#
#==============Data processing================#
#=============================================#

colnames(Nuke)[3] <- "Power_MW"

print(path_data)
Nuke <- Nuke %>% group_by(IMC_Reg) %>% summarise(Nuke2014 = sum(Power_MW))

Nuke$IMC_Reg <- factor(Nuke$IMC_Reg,
                       levels = c("USA","CAN","EUR","JAN","CIS","CHN","IND","BRA","MDE","AFR","RAS","RAL"))

#=============================================#
#==============Data export====================#
#=============================================#

Nuke <- arrange(Nuke,IMC_Reg) %>% select(Nuke2014)
colnames(Nuke) <- c("//2014 installed cap of Nuke (conventionnal) from the International Atomic Energy Agency")
 
write.csv2(Nuke,paste0(path_export,"/Nuke2014.csv"),row.names = FALSE)

