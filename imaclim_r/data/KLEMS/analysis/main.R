# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

# Main script for analysis
library(plyr)
library(dplyr)
library(ggplot2)
library(tidyr)
library(scales)
library(FactoMineR)
library(missMDA)
library(lazyeval)
library(xtable)

source("direct.R"    )
source("loadData.R"  )
source("mergeData.R")
source("spreadData.R")

rm(allMissing, dg.europeD, dg.europeK, dg.france, dgYear.europeD, ds1, ds2, test, dsYear,dg,ds) # for MFA

#source(paste(SUMMARIZE , "summarizeData.R" , sep=sep))
#source(paste(SUMMARIZE , "summarizeIndustries.R" , sep=sep))
#source(paste(PLOT      , "mainPlot.R" , sep=sep))
#source(paste(PCA       , "mainPca.R"  , sep=sep))
#source(paste(CA        , "mainCa.R"   , sep=sep))
#source(paste(MFA        , "mainMfa.R"   , sep=sep))

