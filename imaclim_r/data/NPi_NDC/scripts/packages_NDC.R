// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

######################################################################
###########. NPi & NDC - Post Glasgow ..##############################
######################################################################

############################
## Thibault Briera
## September 2023
## briera.cired@gmail
############################

# loading packages and functions
packages_list <- c("tidyverse", "roxygen2")


for (i in packages_list){
  if (!require(i, character.only = TRUE)){
    if (force_install_packages) {
        install.packages(i, dependencies = TRUE)
    } else {
        stop("Please install the package ", i, " before running this script")
        }
    library(i, character.only = TRUE)
  }
}