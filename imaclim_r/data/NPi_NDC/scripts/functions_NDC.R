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


#################################
####.. Functions ..############
#################################

#' function to aggregate over IMACLIM regions: from 12 to X regions
#' @param data_tidy a tidy dataframe = passed by the tidy_ar6 function
#' @return a tidy dataframe with aggregated regions
aggregate_ar6  <- function(data_tidy, ag_rule){
    # error messages
  if (sum(colnames(data_tidy) == "Region_IMC") == 0) {
    stop("Please call tidy_ar6 first")
  }
  # function
  # aggregating over Region_IMC: 
    if (ag_rule == 4) { #9 reg aggregation
        df <- data_tidy %>% mutate(Region_IMC = case_when(
        Region_IMC == "USA" ~ "USA",
        Region_IMC == "CAN" ~ "OECD",
        Region_IMC == "EUR" ~ "EUR",
        Region_IMC == "OECD" ~ "OECD",
        Region_IMC == "REF" ~ "REF",
        Region_IMC == "CHN" ~ "CHN",
        Region_IMC == "IND" ~ "IND",
        Region_IMC == "BRA" ~ "LAM",
        Region_IMC == "MDE" ~ "MAF",
        Region_IMC == "AFR" ~ "MAF",
        Region_IMC == "LAM" ~ "LAM",
        Region_IMC == "RASIA" ~ "ASIA",
    ))
    }
    if (ag_rule == 3) { #7 reg aggregation
        df <- data_tidy %>% mutate(Region_IMC = case_when(
        Region_IMC == "USA" ~ "OECD",
        Region_IMC == "CAN" ~ "OECD",
        Region_IMC == "EUR" ~ "OECD",
        Region_IMC == "OECD" ~ "OECD",
        Region_IMC == "REF" ~ "REF",
        Region_IMC == "CHN" ~ "CHN",
        Region_IMC == "IND" ~ "IND",
        Region_IMC == "BRA" ~ "LAM",
        Region_IMC == "MDE" ~ "MAF",
        Region_IMC == "AFR" ~ "MAF",
        Region_IMC == "LAM" ~ "LAM",
        Region_IMC == "RASIA" ~ "ASIA",
    ))
    }
    if (ag_rule == 2) { #4 reg aggregation
                df <- data_tidy %>% mutate(Region_IMC = case_when(
        Region_IMC == "USA" ~ "OECD",
        Region_IMC == "CAN" ~ "OECD",
        Region_IMC == "EUR" ~ "OECD",
        Region_IMC == "OECD" ~ "OECD",
        Region_IMC == "REF" ~ "ROW",
        Region_IMC == "CHN" ~ "ASIA",
        Region_IMC == "IND" ~ "ASIA",
        Region_IMC == "BRA" ~ "LAM",
        Region_IMC == "MDE" ~ "ROW",
        Region_IMC == "AFR" ~ "ROW",
        Region_IMC == "LAM" ~ "LAM",
        Region_IMC == "RASIA" ~ "ASIA"
    ))
    }
    if (ag_rule == 1) { #world aggregation
                df <- data_tidy %>% mutate(Region_IMC = case_when(
        Region_IMC == "USA" ~ "WORLD",
        Region_IMC == "CAN" ~ "WORLD",
        Region_IMC == "EUR" ~ "WORLD",
        Region_IMC == "OECD" ~ "WORLD",
        Region_IMC == "REF" ~ "WORLD",
        Region_IMC == "CHN" ~ "WORLD",
        Region_IMC == "IND" ~ "WORLD",
        Region_IMC == "BRA" ~ "WORLD",
        Region_IMC == "MDE" ~ "WORLD",
        Region_IMC == "AFR" ~ "WORLD",
        Region_IMC == "LAM" ~ "WORLD",
        Region_IMC == "RASIA" ~ "WORLD"
    ))
  }
  return(df)

}

#' functions to 1) extract variable from the global dataset 2) match the different regions to the IMACLIM-R regions 3) pivot in long format to prepare for regional aggregation 4) filter NA's
#' @param data_ar6 a ar6 standard dataframe
#' @param var a string of characters to filter the dataframe, corresponding to existing variables in the dataframe
tidy_ar6  <- function(data_ar6, var) {
  if (sum(unique(data_ar6$Variable) == var) == 0) {
    stop("Incorrect variable name, please verify the variable name in the dataframe")
    }
  #filtering
  df <- data_ar6 %>% filter(Variable %in% var)

  # adding IMACLIM regions for aggregation
  df$Region_IMC <- unlist(lapply(df$Region, function(x) regions_table$IMACLIM_Reg[which(x == regions_table$Region)])) #this unlist apply is strange but apply wont work


  # to aggregate over Region_IMC, we need to transform the dataset into a long format
  df <- df %>% pivot_longer(cols = "X2020":"X2050", names_to = "Year", values_to = "Value")  %>% select(Model, Scenario, Region, Region_IMC, Year, Value)

  #and filter for Na's
  df <- df %>% filter(!is.na(Value))
}


#--------------------------------------------------------------#


#' function to pivot back to wide format
#' @param data_tidy a tidy dataframe = passed by the tidy_reg function
#' @return a tidy dataframe in wide format
pivot_ar6 <- function(data_tidy) {
    # error messages
    if (sum(colnames(data_tidy) == "Region_IMC") == 0) {
    stop("Please call tidy_ar6 first")
  }
  # function
df <- data_tidy %>% pivot_wider(names_from = "Year", values_from = "Value")
}

#' compute a weighted value by aggregated region
#' @param data_tidy_ag a tidy dataframe = passed by the tidy_ar6 function and the aggregate_ar6 function
#' @param data_tidy_weight a tidy dataframe, whose "Value" column is used to weight the data_tidy_ag dataframe
#' @return a tidy dataframe with a weighted value
weighted_ar6 <- function(data_tidy_ag, data_tidy_weight) {
    # error messages
  if (sum(colnames(data_tidy_ag) == "Region_IMC") == 0) {
    stop("Please call tidy_ar6 first")
  }
    if (sum(colnames(data_tidy_ag) == "Region") == 0) {
    stop("The Region column is missing, please don't remove it")
  }
 df  <- merge(data_tidy_ag, data_tidy_weight, by = c("Model", "Scenario", "Region", "Region_IMC", "Year"))
    # function
  #computing weighted value, with groups over Region_IMC, Scenario, Model and Year: compute a weighted value per aggregated reg
  df <- df %>% group_by(Model, Scenario, Region_IMC, Year) %>% summarise(Value = sum(Value.x * Value.y) / sum(Value.y))
}

#--------------------------------------------------------------#


#' function to reaggregate over the Region_IMC factor
#' @param data_tidy a tidy dataframe = passed by the tidy_ar6 function
#' @return a tidy dataframe with aggregated regions
reag_ar6 <- function(data_tidy) {
    # error messages
    if (sum(colnames(data_tidy) == "Region_IMC") == 0) {
    stop("Please call tidy_ar6 first")
  } 
      if (sum(colnames(data_tidy) == "Value") == 0) {
    stop("The function pivot_ar6 should be called after this function")
  } 
  if (sum(is.na(data_tidy$Value)) >  1) {
    warning("The Value column contains NA, please check the data")
  }
    # function
  # make sure that Value is numeric
  df <- data_tidy
  df$Value <- as.numeric(df$Value)
  df <- df  %>% group_by(Model, Scenario, Region_IMC, Year)  %>% summarise(Value = sum(Value))

}

#--------------------------------------------------------------#

#' function to select the final emission constraint
#' @param data_tidy a tidy dataframe = passed by the tidy_ar6 function AND computed Delta_30_20 and Delta_25_20
#' @param select_fun a function to select the objective: mean(1), median(2), min(3), max(4). -1 does no selection and 0 filters the model speficied in select_model
#' @param select_model a string to select a specific model, optionnal argument
select_obj <- function(data_tidy,select_fun,select_model) {
  ## error messages
      if (sum(colnames(data_tidy) == 'Delta_30_20') == 0) {
    stop("Please compute 2030 and 2025 change wrt 2020 before calling this function")
  } 
  ## finding the function corresponding to the select_fun argument
  # passing the select_fun argument to numeric
  select_fun  <- as.numeric(select_fun)

  if (is.na(select_model)) { # case when there is no model selected
    if (select_fun == 0) {
      stop("Please select a model or precise a function (mean, median, min, max) to select the objective")
    }
    if(select_fun == 1){select_obj_fun <- mean}
    if(select_fun == 2){select_obj_fun <- median}
    if(select_fun == 3){select_obj_fun <- min}
    if(select_fun == 4){select_obj_fun <- max}
    }
  if (!is.na(select_model)) { # case when there is a model selected
      if (select_fun > 0) {
      stop("Please select a model or precise a function (mean, median, min, max) to select the objective, but not the two")
    }
  }
  # applying the function
  df <- data_tidy #so even if select_fun == -1 (no filter) the df is returned
  if (select_fun == 0) {
    df <- df %>% filter(Model == select_model)
  }
  if (select_fun > 0) {
    #ungrouping then making sure we grouped by the right variables
    df <- df %>% ungroup()  %>% group_by(Scenario, Region_IMC) 
    df <- df %>% summarise(across(where(is.numeric), select_obj_fun))
  }
  #return the df
return(df)
}