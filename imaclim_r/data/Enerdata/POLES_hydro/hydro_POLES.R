# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

#################################################################
#################################################################
###########Agregating new POLES data on hydropower###############
#################################################################
#################################################################

###########################
####### LIBRAIRIES ########
###########################

library(countrycode)
library(tidyverse)

###########################
####### DATA PATHS ########
###########################

args = commandArgs(trailingOnly = TRUE)

scenario <- args[[1]]
path_hydro <- args[[2]] #Path to the hydro folder. Path to the file is given by the scenario variable
path_hydro <- paste0(path_hydro,"/",scenario,"_hydro.csv")
 

path_GTAP <- args[[3]]
path_ISO_to_GTAP <- args[[4]]

path_export <- args[[5]]

###########################
####### IMPORTING #########
###########################

df_hydro <- read.csv(path_hydro, sep = ";") %>% as_tibble()


###########################*
####### TIDY DATA #########
###########################

names(df_hydro)[1] <- "Time" #don't know why the name of the first column is messing up

varname <- sub("*\\[.*","",df_hydro$Time)##Getting the variable name, don't ask me how
unique_varname <- unique(varname)

Countries <- df_hydro$Time

for (i in c(unique_varname,"\\[","\\]")){
  Countries <- str_replace_all(Countries,i,"") #removing all unnecessary characters
}
Technos <- sub(".*,","",Countries) #separating technos from Countries

hydro_tech <-  c("SHY","HPS","HRR","HLK")
for (i in 1:length(Technos)){
  Technos[i] <-  ifelse(Technos[i] %in% hydro_tech,Technos[i],"CAP")
}

Countries <- sub(",.*","",Countries) #keeping only before comma if existing

#process dataset:
df_pro <- cbind(tibble(
  Variable = varname,
  Country = Countries,
  Techno = Technos
),df_hydro) %>% select(-Time)#Merging the three new colums with the initial dataframe and removing the Time Column


df_pro <- df_pro %>%  select(-("X1990":"X2013"))#selecting columns

df_pro <- pivot_longer(df_pro, cols = "X2014":"X2050", names_to = "Year",
                         values_to = "Values") #reshaping data in long format

df_pro$Year <- sub("X","",df_pro$Year) %>% as.numeric() #removing the X for year
df_pro$Values <-sub(",",".",df_pro$Values) %>% as.numeric()#Values in numeric format

###########################
##### DATA PROCESSING #####
###########################

######### Step 1: find small hydro available capacity

#multiply the ACIPD (small hyd cap) ties the ACAFLF (load factor) to get the ACPM (available power)
#we first merge by country, year and techno to get sure to multiply correctly
df_shy <- merge(df_pro %>% filter(Variable == "ACIPD") ,df_pro %>% filter(Variable == "ACAFLF"),
      by = c("Country","Techno","Year")) %>% mutate(Values = Values.x*Values.y) %>% mutate(Variable = "ACPW") %>% select(Variable,Country,Techno,Year,Values)

df_pro <- rbind(df_pro,df_shy) #small hydro included

######### Step 2: find the average load factor per year and country using the formula:
######### (HLK+HRR+HPS + SmallHydro)/Cap

#compute cumulated values
df_cumul <-  df_pro %>% filter(Variable == "ACPW") %>% group_by(Country,Year) %>% summarise_at(vars(Values), list(Values = sum))
df_cumul$Variable <- "ACPW_C"
df_cumul$Techno <- "CML"
df_cumul <- df_cumul %>% select(Variable,Country,Techno,Year,Values) #put everything in the right order


df_pro <- rbind(df_pro,df_cumul) #cumulated avail cap included

df_AF <- merge(df_pro %>% filter(Variable == "ACPW_C") ,df_pro %>% filter(Variable == "ACIPHYT"),by = c("Country","Year")) %>% mutate(Values = Values.x/Values.y)%>%
  mutate(Variable = "mean_AF") %>% select(Variable,Country,Year,Values)
df_AF$Techno <- "CML"
df_AF<- df_AF %>% select(Variable,Country,Techno,Year,Values)

df_pro <- rbind(df_pro,df_AF)

#########Step 3: assign an IMC region to the data

#For the Cap 

ISO_to_IMC <- function(df,path_GTAP,path_ISO_to_GTAP){
  
  data_agreg <- df
  p_GTAP <- path_GTAP
  p_ISO <- path_ISO_to_GTAP
  #ISO to GTAP agregation rule
  
  ISO_to_GTAP <- read.csv(p_ISO,sep = ",")
  
  #GTAP to IMC agregation rule
  matrix_GTAP <- t(read.csv(p_GTAP,sep = "|",header = FALSE,row.names = 1)) %>%
    as.data.frame()
  
  
  matrix_GTAP <- pivot_longer(matrix_GTAP,colnames(matrix_GTAP),names_to = "IMACLIM_Region",values_to = "GTAP_Region")
  #Removign empty rows
  matrix_GTAP <- matrix_GTAP[!matrix_GTAP$GTAP_Region=="",]
  matrix_GTAP$GTAP_Region <- toupper(matrix_GTAP$GTAP_Region)
  
  
  n <- nrow(data_agreg)
  m <- nrow(ISO_to_GTAP)
  o <- nrow(matrix_GTAP)
  
  
  
  #Find ISO correspondance
  data_agreg$GTAP_reg <- rep(0,n)
  data_agreg$IMACLIM_region<- rep(0,n)
  
  for (i in 1:n){
    for (j in 1:m){
      if(data_agreg$Country[i] == toupper(ISO_to_GTAP$ISO[j])){
        data_agreg$GTAP_reg[i]  <-  toupper(ISO_to_GTAP$REG_V10[j])
      } else {}
    }
  }
  
  
  for (i in 1:n){
    for (j in 1:o){
      if(data_agreg$GTAP_reg[i] == matrix_GTAP$GTAP_Region[j]){
        data_agreg$IMACLIM_region[i]  <-  matrix_GTAP$IMACLIM_Region[j]
      } else {}
    }
  }
  data_agreg
}

df_pro <- ISO_to_IMC(df_pro %>% filter(Variable == "ACIPHYT"|Variable == "mean_AF"),path_GTAP,path_ISO_to_GTAP)

##Handling manually regions for which the country code isn't ISO code
filter(df_pro,IMACLIM_region == 0) %>% group_by(Country) %>% summarize()


#Agregated region of POLES are found in the model documentation page
#https://publications.jrc.ec.europa.eu/repository/bitstream/JRC107387/kjna28728enn.pdf
df_pro <- df_pro %>% mutate(IMACLIM_region = case_when(
  Country == "cyp" ~ "EUR",
  Country == "MEME" ~ "MDE", #Mediter. Middle east
  Country == "mlt" ~ "EUR",
  Country == "NOAN" ~ "AFR", 
  Country == "NOAP" ~ "AFR",
  Country == "RCAM" ~ "RAL",
  Country == "RCEU" ~ "EUR", #guess its is EUR
  Country == "RCIS" ~ "CIS",
  Country == "RGLF" ~ "MDE",
  Country == "RPAC" ~ "RAS", #guess its pacific
  Country == "RSAF" ~ "AFR", #guess its south africa
  Country == "RSAM" ~ "RAL", 
  Country == "RSAS" ~ "RAS", #guess again
  Country == "RSEA" ~ "RAS",#south east asia
  TRUE ~ IMACLIM_region
  #Note: the last three to be guessed are NOAN, NOAP and RGLF. Looks like RGLF refers to rest of Persian Gulf (MDE)
  #the other two to nothern Africa countries (NAO) => Africa
))


###Still to be done: aggregate cap, then use it to aggregate the load factor
##

#########Step 4: aggregate the mean load factor weighted by capacities


keep_var <- c("Country","Year","IMACLIM_region")#variables to keep

#the mean AF becomes the Values and Cpa becomes the weights
df_AF_wgh <- merge(df_pro %>% filter(Techno == "CML"),df_pro %>% filter(Techno == "CAP"), by = keep_var ) %>% mutate(Values = Values.x, Weights = Values.y) %>% select(all_of(keep_var), Values, Weights)

df_AF_wgh <- df_AF_wgh %>% group_by(IMACLIM_region,Year) %>%  summarise(weighted.mean(Values,Weights,na.rm = TRUE))              
names(df_AF_wgh)[3] <- "Values"

##The orders of magnitude look very good. One can check using IRENA's data, by comparing the hydro production (GWh) with nameplate capacity (GW).


#Agregate capacities 

df_Cap <- df_pro %>% filter(Techno == "CAP") %>% group_by(IMACLIM_region,Year) %>%  summarise(sum(Values))              
names(df_Cap)[3] <- "Values"


#########Step 5: linear approximation of missing values

lin_inter_IMC <- function(Year,Values,IMC,df){
  #linearly interpolates the missing values between two refs.
  # inputs format:
  # Year, Values and IMC : vectors of length n
  # df : initial 3xn dataset with IMACLIM_Reg, Year and Values columns
for (i in 1:(length(Year)-1)){

  if((Year[i+1]-Year[i]>1) &(IMC[i+1]==IMC[i])){
  lin_approx <- approx   (c(Year[i],Year[i+1]), c(Values[i],Values[i+1]),  method="linear",n = Year[i+1]-Year[i]+1) 
  n <- length(lin_approx$x)
 df <- rbind(df,tibble(
    IMACLIM_region = IMC[i],
    Year = lin_approx$x[2:(n-1)],
    Values = lin_approx$y[2:(n-1)]
  ))
  
  } 
}
  df <- df %>% arrange(IMACLIM_region,Year) #rearrange to check everything is ok
  df}


#Interpolation for load factor values
AF <- df_AF_wgh %>% select(IMACLIM_region,Year,Values)
Year <- AF$Year
Values <- AF$Values
IMC <- AF$IMACLIM_region

AF <- lin_inter_IMC(Year,Values,IMC,AF)

#Interpolation for capacities
Year <- df_Cap$Year
Values <- df_Cap$Values
IMC <- df_Cap$IMACLIM_region

Cap <- lin_inter_IMC(Year,Values,IMC,df_Cap)
Cap <- ungroup(Cap)
rearrange_for_export <- function(df){
  #arranging df for export. Sets the region in the right order. applies to ungrouped 
 df <-  ungroup(df)
  
  df$IMACLIM_region <- factor(df$IMACLIM_region,
                              levels = c("USA","CAN","EUR","JAN","CIS","CHN","IND","BRA","MDE","AFR","RAS","RAL")) 
  
  df$IMACLIM_region <- factor(df$IMACLIM_region,)
  
  df <- df %>% arrange(IMACLIM_region) %>% select(Values)
  df
}


Cap <- rearrange_for_export(Cap)
AF <- rearrange_for_export(AF)

###########################
####### EXPORTING #########
###########################


colnames(Cap) <- paste0("//","Capacities for ", scenario, " scenario") 
write.csv(Cap,paste0(path_export,"/Cap_",scenario,".csv"),row.names = FALSE)

colnames(AF) <- paste0("//","Availability factor for ", scenario, " scenario") 
write.csv(AF,paste0(path_export,"/AF_",scenario,".csv"),row.names = FALSE)




