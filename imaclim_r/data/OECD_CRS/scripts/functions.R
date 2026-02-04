// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

##########################
##~~ Loading functions ~##
##########################

#' function to merge multiple datasets
#' @param list_of_loaded_data list of dataframes to be merged
#' @param join_func function to be used for merging
multi_join <- function(list_of_loaded_data, join_func, ...){
  require("dplyr")
  output <- Reduce(function(x, y) {join_func(x, y, ...)}, list_of_loaded_data)
  return(output)
}

`%nin%`  <-  Negate(`%in%`)