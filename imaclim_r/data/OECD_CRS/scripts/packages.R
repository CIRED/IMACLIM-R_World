// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

##########################
###~~ Loading packages ~##
###~~ and functions ~####
##########################
# Want to force install packages?
force_install_packages <- FALSE

# loading packages and functions
#"Hmisc"
packages_list <- c("tidyverse", "knitr", "readxl")

for (i in packages_list) {
  if (!require(i, character.only = TRUE)) {
    if (force_install_packages) {
      install.packages(i, dependencies = TRUE)
    }
    library(i, character.only = TRUE)
  }
}
