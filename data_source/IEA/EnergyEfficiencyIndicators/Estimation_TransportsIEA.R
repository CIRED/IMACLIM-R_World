// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

#OBJET      - Script de traitement des donnes IEA (Efficicency Indicators) / World Bank pour l'estimation d'indicateurs du niveau d'activit, de l'efficacit nergtiques et de la demande d'nergie pour les diffrents modes et sources d'nergie
#OUTPUT     - 1 ffichier csv agrgeant les indicateurs estims  l'chelle des 12 rgions Imaclim-R world ; et les 3 fichiers csv individuels utiliss pour calibrer Imaclim-R monde
#INPUT (1)  - Fichier xlxs "Energy Efficiency Indicators" de l'IEA (ATTENTION, ncessaire de le convertir en xlsx, la version initiale en xlsm ne peut tre importe)
#INPUT (2)  - Fichier WDIData.csv de la banque mondiale, disponible ici /data/public_data/World_Bank_Data_Catalog_05252021/extracted/WDIData.csv au 18/02/2022
#INPUT (3)  - Fichiers produits  partir de sources de donnes complmentaires (p. ex. yearbook pour la Chine, donnes d'aviation)

#Notes de version : 
#les commentaires n'ont pas t tous mis  jour pour tenir compte des dernires corrections et choix mthodo (tenir compte des deux roues, aviation, Chine)
#le fichier agrg n'a finalement pas t utilis,  part  titre informatif pour montrer la cohrence entre les variables
#nouvelle version partant des fichiers natifs disponibles sur le serveur, cre par Thomas le 18/02/2022
#aprs l'application de plusieurs techniques d'imputation, la base WB comporte encore des donnes manquantes (pour toute la priode) pour British Virgin Islands, Cayman Islands, French Polynesia, Gibraltar, Korea, Dem. People???Ts Rep., New Caledonia, Somalia, Syrian Arab Republic ; ces pays sont retirs de la base utilise ensuite

#Reste  faire : 
## recorriger les donnes Chine (cf. ci-dessous) - OK
## vrifier qu'on a bien toutes les bonnes variables - OK
## clarifier les units - PJ
## corriger les valeurs ngatives air - OK
## vrifier les ordres de grandeurs - OK
## crer le fichier de sortie
## implmenter dans le code l'usage de ce nouveau fichier de sortie
## identifier et mettre en commentaire initial les problmes possibles  la mise  jour



library(tidyr)
library(dplyr)
library(openxlsx)
library(ggplot2)
library(forcats)
library(broom)
library(zoo)
library(stringr)
library(Hmisc)
library(skimr)

### 0 - Paramtres de l'excution du code
Display_RegressionGraphs <- "no" #changer en "yes" pour afficher les graphiques de rgression
WB_endyear<-2018 #dernire anne de donnes  peu prs compltes pour WB dans le jeu de donnes utilis
#NB : il serait ncessaire de convertir en variable la constante qui fixe le nombre de valeurs par pays par variable, en cas de mise  jour des fichiers d'origine et de l'anne de fin
ToDelete_IncomePC <- c("Indonesia") #on remarque que dans la base, les valeurs de revenus pc de l'Indonsie sont aberrantes (ngatives notamment), on les supprimera puis elles seront estimes  partir du PIB
Year_Calibration <- 2014 #anne  laquelle on veut les donnes dans la base agrge  l'chelle rgionale (la base "pays" comporte des donnes sur toutes les annes)
Convert_EnergyUnit <- 0.0238845896627 #Facteur de conversion des units nergtiques pour la base rgionale. Ici on passe de PJ (unit de la base de l'IEA)  Mtoe (unit de la calibration transport dans Imaclim  la date de cration du fichier)
LoadGTAP_forAirCorrection <- "no"

### 1 - Chargement des fichiers de donnes et prtaitements

## 1.1 - Chargement et prtraitement de la base de la banque mondiale et du fichier d'agrgation en rgions Imaclim-R world  partir des codes pays ISO3
setwd("~/")
CountryRegion<-read.csv2("~/imaclim_ISO3_aggregates.csv",sep="|")
WB_DataBase<-read.csv2("~/WDIData.csv",sep=",") # l'usage de la fonction "check.names = FALSE" pose problme avec filter ensuite, tout comme le fait de renommer les annes (X1960 => 1960), je ne renomme donc pas. #colnames(WB_DataBase)<-c("Country_Name","Country_Code","Indicator_Name","Indicator_Code",1960:2019)
colnames(WB_DataBase)[1:4]<-c("Country_Name","Country_Code","Indicator_Name","Indicator_Code")
WB_DataBase<-WB_DataBase %>%
  filter(Indicator_Code %in% c("NY.ADJ.NNTY.PC.KD","NY.GDP.MKTP.KD","NY.GDP.MKTP.KN","SP.POP.TOTL","IS.RRS.TOTL.KM", "EN.POP.DNST", "AG.LND.TOTL.K2", "SP.URB.TOTL.IN.ZS", "AG.LND.TOTL.UR.K2", "AG.LND.TOTL.RU.K2","IS.AIR.PSGR","IS.RRS.PASG.KM")) # %>%
# On slectionne les variables suivantes, utilises pour les rgressions et autres oprations :
# NY.ADJ.NNTY.PC.KD :	Adjusted net national income per capita (constant 2015 US$)
# NY.GDP.MKTP.KD    : GDP (constant 2010 US$)
# NY.GDP.MKTP.KN    : GDP (constant LCU)
# SP.POP.TOTL       : Population, total
# IS.RRS.TOTL.KM    : Longueur de routes ferres
# EN.POP.DNST       : Densit
# AG.LND.TOTL.K2    : Superficie du pays
# SP.URB.TOTL.IN.ZS : Population urbaine %
# AG.LND.TOTL.UR.K2 : Superficie urbaine
# AG.LND.TOTL.RU.K2 : Superficie rurale
# IS.RRS.PASG.KM    : Passagers transports par train
# IS.AIR.PSGR       : Passagers transports par air


WB_DataBase_copy<-WB_DataBase #On le fait en deux temps et on fait une copie de la base  ce stade car un peu long de charger la base
WB_DataBase_copy[which(WB_DataBase_copy$Country_Name %in% ToDelete_IncomePC&WB_DataBase_copy$Indicator_Code=="NY.ADJ.NNTY.PC.KD"),5:ncol(WB_DataBase_copy)] <- "" #Effacement de certaines donnes originales pour l'Indonsie (valeurs ngatives)

WB_DataBase<-left_join(WB_DataBase_copy,CountryRegion, by=c("Country_Code"="ISO3")) %>%
  mutate(Country_Name = fct_recode(Country_Name,
                'Korea'               ="Korea, Rep.",
                "Kyrgyzstan"          ="Kyrgyz Republic",
                "Republic of Moldova" = "Moldova"
  )) %>%
  filter(is.na(Im_region)==FALSE) %>%
  mutate(Indicator_Name = fct_recode(Indicator_Name,
              'Income_pc'             = "Adjusted net national income per capita (constant 2010 US$)",
              'GDP_ConstantPrice'     = "GDP (constant 2010 US$)",
              'GDP_LCU'               = "GDP (constant LCU)",
              'Population_WB'         = "Population, total",
              'LandArea_Total'        = "Land area (sq. km)",
              'Population_Density'    = "Population density (people per sq. km of land area)",
              'Rail_Length'           = "Rail lines (total route-km)",
              'LandArea_Rural'        = "Rural land area (sq. km)",
              'LandArea_Urban'        = "Urban land area (sq. km)",
              'Population_Urban'      = "Urban population (% of total population)",
              'Air_Passengers'        = "Air transport, passengers carried",
              'Train_Passengers'      = "Railways, passengers carried (million passenger-km)"
  )) %>%
  pivot_longer(-c(Country_Name,Country_Code,Indicator_Name,Indicator_Code), names_to = "Year", values_to = "Value" ) %>%
  select(-c(Indicator_Code)) %>%
  mutate(Year=str_sub(Year,2,5)) %>%
  pivot_wider(id_cols = c(Country_Name,Country_Code,Year), names_from = "Indicator_Name", values_from = "Value" ) %>%
  filter(Year %in% c(2000:WB_endyear)) %>% #On s'arrte  la dernire anne  peu prs complte
  #On s'assure que les variables sont numriques
  mutate(GDP_ConstantPrice=as.numeric(GDP_ConstantPrice)) %>%
  mutate(Population_WB=as.numeric(Population_WB)) %>%
  mutate(Income_pc=as.numeric(Income_pc)) %>%
  mutate(Year=as.numeric(Year)) %>%
  mutate(GDP_LCU=as.numeric(GDP_LCU)) %>%
  mutate(Air_Passengers=as.numeric(Air_Passengers)) %>%
  mutate(Train_Passengers=as.numeric(Train_Passengers)*10^6) %>%
  #On impute les donnes 2000-2006 de Nauru en amont diffremment car le procd qui suit gnrait des valeurs ngatives ; ici on affecte aux annes 2000-2006 la valeur 2007
  mutate(GDP_ConstantPrice=ifelse(Year %in% c(2000:2006)&Country_Name=='Nauru',GDP_ConstantPrice[Country_Name=='Nauru'&Year==2007],GDP_ConstantPrice))  %>%
  #On va commencer par imputer les donnes dmograpiques par interpolation puis extrapolation (trs peu de donnes manquantes)
  group_by(Country_Name) %>%
  mutate(Population_WB=na.approx(Population_WB,x=Year,na.rm=FALSE))  %>% #Pas utile avec les donnes utilises en 2022, mais possiblement  l'avenir - premire imputation par interpolation
  mutate(Population_WB=approxExtrap(x=Year[which(!is.na(Population_WB))],y=Population_WB[which(!is.na(Population_WB))],xout=c(Year))$y)  %>% #Imputation par extrapolation, pour 7 annes pour l'Erythre dans la base utilise initialement
  #On cre les donnes per capita qui serviront aux imputations des revenus/capita
  mutate(GDP_ConstantPrice_pc=GDP_ConstantPrice/Population_WB) %>% 
  mutate(GDP_LCU_pc=GDP_LCU/Population_WB) %>% #Finalement non utilise
  #On cre des variables pour classer les pays * variables en fonction du nombre de donnes manquantes, qui dterminera la mthode d'imputation
  mutate(check_NA_GDP=ifelse(sum(is.na(GDP_ConstantPrice))==19,0,ifelse(sum(is.na(GDP_ConstantPrice))==18,1,ifelse(sum(is.na(GDP_ConstantPrice))>=1,2,3))))  %>% #On diagnostique le nombre de NA ; 0 si que des NA ; 1 si une valeur existante ; 2 si au moins deux valeurs existantes (mais au moins une donne manquante) ; 3 si aucune valeur manquante.
  mutate(check_NA_INC=ifelse(sum(is.na(Income_pc))==19,0,ifelse(sum(is.na(Income_pc))==18,1,ifelse(sum(is.na(Income_pc))>=1,2,3)))) %>% #idem avec la variable population
  mutate(check_NA_GDP_LCU=ifelse(sum(is.na(GDP_LCU))==19,0,ifelse(sum(is.na(GDP_LCU))==18,1,ifelse(sum(is.na(GDP_LCU))>=1,2,3))))  %>% #idem avec GDP_LCU
  mutate(check_NA_Train_Passengers=ifelse(sum(is.na(Train_Passengers))==19,0,ifelse(sum(is.na(Train_Passengers))==18,1,ifelse(sum(is.na(Train_Passengers))>=1,2,3))))  %>% #idem avec Train_Passenger
  mutate(check_NA_Air_Passengers=ifelse(sum(is.na(Air_Passengers))==19,0,ifelse(sum(is.na(Air_Passengers))==18,1,ifelse(sum(is.na(Air_Passengers))>=1,2,3))))  %>% #idem avec Air_Passenger
  #On applique les diffrentes mthodes d'imputation au PIB/capita (ainsi on exclut la composante dmographique de la variation du PIB)
  mutate(GDP_ConstantPrice_pc_new=ifelse( #Ici on interpole le PIB/capita dans le cas o il existe suffisamment de valeurs, sur la priode o il existe des donnes (en dehors, c'est trait ci-dessous par extrapolation)
    check_NA_GDP==2, na.approx(GDP_ConstantPrice_pc,x=Year,na.rm=FALSE), ifelse(
      check_NA_GDP==1, mean(GDP_ConstantPrice_pc, na.rm=TRUE), GDP_ConstantPrice_pc # Cas o on dispose d'une seule valeur : on utilise cette valeur pour les autres annes
    )
  )) %>%
  mutate(GDP_ConstantPrice_pc_new=ifelse( # on extrapole le taux de croissance du PIB/capita pour les pays o suffisamment de donnes sont disponibles (avant la premire valeur disponible, aprs la dernire)
    check_NA_GDP==2, approxExtrap(x=Year[which(!is.na(GDP_ConstantPrice_pc_new))],y=GDP_ConstantPrice_pc_new[which(!is.na(GDP_ConstantPrice_pc_new))],xout=c(Year))$y, GDP_ConstantPrice_pc_new
  )) 

#On impute les donnes d'income/capita, dont les donnes manquantes taient bien plus nombreuses que le PIB ( prix constant), en commenant par crer un modle de rgression non paramtrique, qui servira de base pour les pays o aucune donnes n'tait disponible
loess.income.pc<-loess(Income_pc~GDP_ConstantPrice_pc_new, WB_DataBase, span = 2, control = loess.control(surface = "direct"))
WB_DataBase_2 <- WB_DataBase %>%
  mutate(Income_pc_loess=predict(loess.income.pc,GDP_ConstantPrice_pc_new, se = FALSE)) %>% #On cre une nouvelle variable base uniquement sur le modle de rgression
  mutate(Income_pc_new=ifelse( #Ici on interpole le revenu/capita pour les valeurs manquantes sur la priode o il y a des donnes
    check_NA_INC==2, na.approx(Income_pc,x=GDP_ConstantPrice_pc_new,na.rm=FALSE), 
    Income_pc )
  ) %>%
  mutate(Income_pc_new=ifelse( # on extrapole  partir des variations du PIB/capita pour les pays o suffisamment de donnes sont disponibles (avant la premire valeur disponible, aprs la dernire)
    check_NA_INC==2, approxExtrap(x=GDP_ConstantPrice_pc_new[which(!is.na(Income_pc_new))],y=Income_pc_new[which(!is.na(Income_pc_new))],xout=c(GDP_ConstantPrice_pc_new))$y, 
    Income_pc_new)) %>%
  mutate(Income_pc_new = ifelse(
    check_NA_INC<=1, predict(loess.income.pc,GDP_ConstantPrice_pc_new, se = FALSE), #On utilise le modle quand il existe une valeur ou moins sur la priode
    Income_pc_new)) %>%
  ungroup() %>%
  mutate(Income_pc_new=ifelse(Income_pc_new<=0,Income_pc_loess,Income_pc_new)) %>% #On corrige pour les donnes infrieures  0 qui peuvent tre lies aux extrapolations - dans ce cas on essaie le  modle de rgression ...
  mutate(Income_pc_new=ifelse(Income_pc_new<=0,GDP_ConstantPrice_pc_new*mean(Income_pc/GDP_ConstantPrice_pc,na.rm=TRUE),Income_pc_new)) %>% #... et pour ce qui reste, on utilise une autre approximation : une fraction constante du PIB (calcue sur toutes la valeurs)
  mutate(Income_pc_new=ifelse(Country_Name=='Kuwait'&Year%in%c(2000:2008),GDP_ConstantPrice_pc_new*mean(Income_pc/GDP_ConstantPrice_pc,na.rm=TRUE),Income_pc_new)) %>% #On corrige galement des extrapolations trs optimistes pour deux pays
  mutate(Income_pc_new=ifelse(Country_Name=='United Arab Emirates'&Year%in%c(2000),GDP_ConstantPrice_pc_new*mean(Income_pc/GDP_ConstantPrice_pc,na.rm=TRUE),Income_pc_new)) %>%
  # On impute les autres donnes : Rail_Length
  group_by(Country_Name) %>%
  mutate(Rail_Length=as.numeric(Rail_Length)) %>%
  mutate(LandArea_Total=as.numeric(LandArea_Total)) %>%
  mutate(Population_Density=as.numeric(Population_Density)) %>%
  mutate(LandArea_Rural=as.numeric(LandArea_Rural)) %>%
  mutate(LandArea_Urban=as.numeric(LandArea_Urban)) %>%
  mutate(Population_Urban=as.numeric(Population_Urban)) %>%
  mutate(Rail_Length = ifelse(sum(is.na(Rail_Length))<18,na.approx(Rail_Length,x=Year,na.rm=FALSE),Rail_Length)) %>% #D'abord une interpolation simple entre valeurs existantes
  mutate(Rail_Length = ifelse(is.na(Rail_Length)==TRUE, mean(Rail_Length,na.rm=TRUE),Rail_Length)) %>% #Puis complment par la moyenne des donnes existantes sur les donnes manquantes (p. ex. considre la valeur comme stable sur la priode si une seule valeur)
  mutate(Rail_Density = Rail_Length/LandArea_Total) %>% #Puis complment par la moyenne des donnes existantes sur les donnes manquantes (p. ex. considre la valeur comme stable sur la priode si une seule valeur)
  #Et Air et Train passengers, inter et extra polation  partir de la population
  mutate(Air_Passengers_new=ifelse(check_NA_Air_Passengers==2, na.approx(Air_Passengers,x=Population_WB,na.rm=FALSE), Air_Passengers) ) %>%
  mutate(Air_Passengers_new=ifelse(check_NA_Air_Passengers==2, approxExtrap(x=Population_WB[which(!is.na(Air_Passengers))],y=Air_Passengers[which(!is.na(Air_Passengers))],xout=c(Population_WB))$y,Air_Passengers)) %>%
  mutate(Train_Passengers_new=ifelse(check_NA_Train_Passengers==2, na.approx(Train_Passengers,x=Population_WB,na.rm=FALSE), Train_Passengers) ) %>%
  mutate(Train_Passengers_new=ifelse(check_NA_Train_Passengers==2, approxExtrap(x=Population_WB[which(!is.na(Train_Passengers))],y=Train_Passengers[which(!is.na(Train_Passengers))],xout=c(Population_WB))$y,Train_Passengers))

#View(WB_DataBase_2[which(WB_DataBase_2$Country_Name=="Japan"),]  )
WB_DataBase_2[which(WB_DataBase_2$Country_Name=="Japan"&WB_DataBase_2$Year=="2018"),"Train_Passengers_new"]<-WB_DataBase_2[which(WB_DataBase_2$Country_Name=="Japan"&WB_DataBase_2$Year=="2017"),"Train_Passengers"] #Correction  la marge


#Possibilit de tracer les graphiques pour contrler les imputations d'income/capita
if (Display_RegressionGraphs == "yes"){
  #On cre une variable pour distinguer les valeurs estimes des valeurs originales (pour income_pc)  
    WB_DataBase_2 <- WB_DataBase_2 %>%
    mutate(Original=ifelse(is.na(Income_pc)==TRUE,'Estimated', 'Original'))
  #On trace un graphe des valeurs estimes et originales par pays, en faisant apparaitre la rgression non paramtrique utilise pour une partie des imputations
    ggplot(WB_DataBase_2, aes(x=GDP_ConstantPrice_pc_new, y=Income_pc_new))+ 
    geom_point(aes(colour = Country_Name))+geom_smooth(method = "loess", span = 2)+ 
    theme_classic() + theme(legend.position='none') + ggtitle("Graphique par pays avec les valeurs estimes")
  #On trace le mme graphe en visualisant les valeurs estimes
    ggplot(WB_DataBase_2, aes(x=GDP_ConstantPrice_pc_new, y=Income_pc_new))+ 
    geom_point(aes(colour = Original))+geom_smooth(method = "loess", span = 2)+  
    theme_classic()  + ggtitle("Visualisation des valeurs estimes")
}



## 1.2 - Chargement et prtraitement des donnes d'activit de l'IEA

# Chargement des onglets utiles du fichier de l'IEA (ATTENTION, comme mentionn en haut : conversion en xlsx ncessaire au pralable)
setwd("~/EnergyEfficiencyIndicators/data")
IEA_Activity<-read.xlsx("IEA_EEI_database_Full_Rev.xlsx",sheet="Activity data") #Corrig dans le fichier excel : espaces dans la colonne Product
IEA_Activity[which(IEA_Activity$Country=="Romania"&IEA_Activity$Product=="Population (10^6)"),"2000"] <- 22.44 #Correction d'une valeur aberrante  partir de la donne de la banque mondiales
IEA_Activity[which(IEA_Activity$Country=="Serbia"&IEA_Activity$Product=="Population (10^6)"),"2000"] <- 7.52 #idem
IEA_Activity[which(IEA_Activity$Country=="Latvia"&IEA_Activity$Product=="Population (10^6)"),"2000"] <- 2.37 #idem
IEA_Activity[which(IEA_Activity$Country=="Republic of North Macedonia"&IEA_Activity$Product=="Population (10^6)"),"2000"] <- 2.03 #idem
IEA_Activity[which(IEA_Activity$Country=="Kosovo"&IEA_Activity$Product=="Population (10^6)"),"2000"] <- 1.70 #idem
IEA_Activity[which(IEA_Activity$Country=="Malta"&IEA_Activity$Product=="Population (10^6)"),"2000"] <- 0.39 #idem
IEA_EnergyDemandTransport<-read.xlsx("IEA_EEI_database_Full_Rev.xlsx",sheet="Transport - Energy")


# Prtraitement des donnes de pkm IEA : slection des variables, interpolations pour les donnes manquantes entre donnes existantes
PKM_AllModes<-IEA_Activity %>%
  filter(Product %in% c("Population (10^6)", "Passenger-kilometres (10^9 pkm)")) %>%
  filter(Activity %in% c("Cars/light trucks","Motorcycles","Buses","Passenger trains","Domestic passenger airplanes","General Activity")) %>%
  mutate(Activity = fct_recode(Activity,
                               'Cars'="Cars/light trucks",
                               'Trains'="Passenger trains",
                               'pkm_air' = "Domestic passenger airplanes",
                               'Population_IEA' = "General Activity"
  )) %>%
  pivot_longer(-c(Country,Activity,Product), names_to = "Year", values_to = "Value" ) %>%
  pivot_wider(id_cols = c(Country,Year), names_from = "Activity", values_from = "Value" ) %>%
  rename(pkm_cars='Cars',pkm_moto='Motorcycles',pkm_train='Trains',pkm_buses='Buses',) %>%  
  mutate(Population_IEA=as.numeric(Population_IEA)*10^6) %>%
  mutate(pkm_cars=as.numeric(pkm_cars)*10^9)  %>%
  mutate(pkm_moto=as.numeric(pkm_moto)*10^9)  %>%
  mutate(pkm_train=as.numeric(pkm_train)*10^9)  %>%
  mutate(pkm_buses=as.numeric(pkm_buses)*10^9)  %>%
  mutate(pkm_air=as.numeric(pkm_air)*10^9)  %>%
  mutate(Year=as.numeric(Year))  %>%
  group_by(Country) %>%
  mutate(Population_IEA=na.approx(Population_IEA,na.rm=FALSE))  %>% #On interpole (au cas o) les donnes de population (base : anne)
  mutate(pkm_cars=na.approx(pkm_cars,x=Population_IEA,na.rm=FALSE))  %>% #On complte les donnes manquantes par interpolations en fonction de la taille de la population pour les 5 modes
  mutate(pkm_moto=na.approx(pkm_moto,x=Population_IEA,na.rm=FALSE))  %>% #NB : cette interpolation prime donc sur l'estimation des valeurs manquantes par rgression (lorsqu'elles sont comprises entre deux donnes existantes)
  mutate(pkm_train=na.approx(pkm_train,x=Population_IEA,na.rm=FALSE))  %>%
  mutate(pkm_buses=na.approx(pkm_buses,x=Population_IEA,na.rm=FALSE))  %>%
  mutate(pkm_air=na.approx(pkm_air,x=Population_IEA,na.rm=FALSE))  %>%
  ungroup() %>%
  mutate(pkm_cars_pc=as.numeric(pkm_cars/Population_IEA))  %>%
  mutate(pkm_moto_pc=as.numeric(pkm_moto/Population_IEA))  %>%
  mutate(pkm_train_pc=as.numeric(pkm_train/Population_IEA))  %>%
  mutate(pkm_buses_pc=as.numeric(pkm_buses/Population_IEA))  %>%
  mutate(pkm_air_pc=as.numeric(pkm_air/Population_IEA))  %>%
  filter(Year!=2019)# %>% #On enlve l'anne 2019 pour laquelle il y a beaucoup de donnes manquantes PIB
  

#On complte d'abord les sries incompltes pour les pays IEA, pour n'avoir qu'un seul type d'imputation une fois qu'on reprend la base WB
PKM_AllModes_aug <- left_join (PKM_AllModes,WB_DataBase_2, by = c("Country" = "Country_Name", "Year"))  %>%
  group_by(Country) %>% #Ci-dessous, on complte les donnes manquantes aux extrmits de sries temporelles (relativement peu nombreuses)
  mutate(check_NA_cars=ifelse(sum(is.na(pkm_cars_pc))==19,0,ifelse(sum(is.na(pkm_cars_pc))==18,1,ifelse(sum(is.na(pkm_cars_pc))>=1,2,3))))  %>% #On diagnostique le nombre de NA ; 0 si que des NA ; 1 si une valeur existante ; 2 si au moins deux valeurs existantes (mais au moins une donne manquante) ; 3 si aucune valeur manquante.
  mutate(check_NA_moto=ifelse(sum(is.na(pkm_moto_pc))==19,0,ifelse(sum(is.na(pkm_moto_pc))==18,1,ifelse(sum(is.na(pkm_moto_pc))>=1,2,3))))  %>%
  mutate(check_NA_buses=ifelse(sum(is.na(pkm_buses_pc))==19,0,ifelse(sum(is.na(pkm_buses_pc))==18,1,ifelse(sum(is.na(pkm_buses_pc))>=1,2,3))))  %>%
  mutate(check_NA_train=ifelse(sum(is.na(pkm_train_pc))==19,0,ifelse(sum(is.na(pkm_train_pc))==18,1,ifelse(sum(is.na(pkm_train_pc))>=1,2,3))))  %>%
  mutate(check_NA_air=ifelse(sum(is.na(pkm_air_pc))==19,0,ifelse(sum(is.na(pkm_air_pc))==18,1,ifelse(sum(is.na(pkm_air_pc))>=1,2,3))))  %>%
  mutate(pkm_cars_pc=ifelse(check_NA_cars==2, approxExtrap(x=Income_pc_new[which(!is.na(pkm_cars_pc))],y=pkm_cars_pc[which(!is.na(pkm_cars_pc))],xout=c(Income_pc_new))$y, pkm_cars_pc)) %>%
  mutate(pkm_moto_pc=ifelse(check_NA_moto==2, approxExtrap(x=Income_pc_new[which(!is.na(pkm_moto_pc))],y=pkm_moto_pc[which(!is.na(pkm_moto_pc))],xout=c(Income_pc_new))$y, pkm_moto_pc)) %>%
  mutate(pkm_buses_pc=ifelse(check_NA_buses==2, approxExtrap(x=Income_pc_new[which(!is.na(pkm_buses_pc))],y=pkm_buses_pc[which(!is.na(pkm_buses_pc))],xout=c(Income_pc_new))$y, pkm_buses_pc)) %>%
  mutate(pkm_train_pc=ifelse(check_NA_train==2, approxExtrap(x=Income_pc_new[which(!is.na(pkm_train_pc))],y=pkm_train_pc[which(!is.na(pkm_train_pc))],xout=c(Income_pc_new))$y, pkm_train_pc)) %>%
  mutate(pkm_air_pc=ifelse(check_NA_air==2, approxExtrap(x=Income_pc_new[which(!is.na(pkm_air_pc))],y=pkm_air_pc[which(!is.na(pkm_air_pc))],xout=c(Income_pc_new))$y, pkm_air_pc))
  
  

if (Display_RegressionGraphs == "yes"){ #Visualisation de l'imputation pour pkm.cars et l'Irlande, pour info
  View(PKM_AllModes_aug[which(PKM_AllModes_aug$Country=="Ireland"),])
  View(PKM_AllModes_aug2[which(PKM_AllModes_aug2$Country=="Ireland"),])
  ggplot(PKM_AllModes_aug2[which(PKM_AllModes_aug2$Country=="Ireland"),], aes(x=Year, y=pkm_cars_pc))+
    geom_point(aes(colour = Income_pc_new))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
    theme_classic()
}  
  
  
############ Ralisation des tests pour identifier les variables pertinentes de rgression ############

if (Display_RegressionGraphs == "yes"){

library(rpart)
library(rpart.plot)
#Premier arbre avec les variables relatives au territoire : TYPLOG+TU99+TAU99+TYPVOIS+ZUS+numcom_littoral+numcom_montagne+numcom_zhu (+ la variable du type de logement)
TREE1<-rpart(pkm_train_pc~Income_pc_new+Rail_Length+Rail_Density+Population_Density+LandArea_Total+Year, data=PKM_AllModes_aug, minsplit = 5,cp=0.001)
#DEP & RG
rpart.plot(TREE1,extra=1)
#text(TREE1, use.n=T)
TREE1<-rpart(pkm_air_pc~Income_pc_new+Rail_Density+Population_Urban+Rail_Length+Population_Density+LandArea_Total+Year, data=PKM_AllModes_aug, minsplit = 5,cp=0.001)
rpart.plot(TREE1,extra=1)

#train

ggplot(PKM_AllModes_aug, aes(x=Income_pc_new, y=pkm_train_pc))+
  geom_point(aes(colour = Rail_Density))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic()

ggplot(PKM_AllModes_aug, aes(x=Rail_Density, y=pkm_train_pc))+ 
  geom_point(aes(colour = Country))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic()

ggplot(PKM_AllModes_aug, aes(x=Population_Density, y=pkm_train_pc))+ 
  geom_point(aes(colour = Country))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic() + scale_x_continuous(limits = c(0, 700))

ggplot(PKM_AllModes_aug, aes(x=Year, y=pkm_train_pc))+ 
  geom_point(aes(colour = Country))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic()

#air
ggplot(PKM_AllModes_aug[which(PKM_AllModes_aug$LandArea_Total<5000000),], aes(x=Income_pc_new, y=pkm_air_pc))+ 
  geom_point(aes(colour = LandArea_Total))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic()

ggplot(PKM_AllModes_aug, aes(x=Income_pc_new, y=pkm_air_pc))+ 
  geom_point(aes(colour = LandArea_Total))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic()

ggplot(PKM_AllModes_aug, aes(x=Year, y=pkm_air_pc))+ 
  geom_point(aes(colour = Income_pc_new))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic()

ggplot(PKM_AllModes_aug, aes(x=Income_pc_new, y=pkm_air_pc))+ 
  geom_point(aes(colour = Country))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic()

#bus
ggplot(PKM_AllModes_aug, aes(x=Income_pc_new, y=pkm_buses_pc))+ 
  geom_point(aes(colour = Population_Density))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic()

#bus
ggplot(PKM_AllModes_aug, aes(x=Income_pc_new, y=pkm_moto_pc))+ 
  geom_point(aes(colour = Population_Density))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic()

#cars
ggplot(PKM_AllModes_aug, aes(x=Income_pc_new, y=pkm_cars_pc))+
  geom_point(aes(colour = Country))#+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic()

ggplot(PKM_AllModes_aug, aes(x=GDP_ConstantPrice_pc_new, y=pkm_cars_pc))+ #pkm.moto.2014+
  geom_point(aes(colour = Country))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic()

ggplot(PKM_AllModes_aug[which(PKM_AllModes_aug$pkm_cars<1.5*10^12),], aes(x=Income_pc_new*Population_WB, y=pkm_cars))+ #pkm.moto.2014+
  geom_point(aes(colour = Country))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic()

ggplot(PKM_AllModes_aug[which(PKM_AllModes_aug$pkm_cars<1.5*10^12),], aes(x=GDP_ConstantPrice_pc_new*Population_WB, y=pkm_cars))+ #pkm.moto.2014+
  geom_point(aes(colour = Country))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic()


ggplot(PKM_AllModes_aug[which(PKM_AllModes_aug$LandArea_Total<=5000000),], aes(x=Income_pc_new, y=pkm_air_pc))+ #pkm.moto.2014+
  geom_point(aes(colour = Country_Name))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic() #+ theme(legend.position='none')

ggplot(WB_DataBase_aug, aes(x=Air_Passengers, y=pkm_air_pc))+ #pkm.moto.2014+
  geom_point(aes(colour = Country_Name))+geom_smooth(method = "lm")+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic() + theme(legend.position='none')

ggplot(WB_DataBase_aug, aes(x=Train_Passengers, y=pkm_train_pc))+ #pkm.moto.2014+
  geom_point(aes(colour = Country_Name))+geom_smooth(method = "lm")+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic() + theme(legend.position='none')



#Les modles en question :

loes.pkm.cars1<-loess(pkm_cars_pc~Income_pc_new, PKM_AllModes_aug, span = 2, control = loess.control(surface = "direct"))
loes.pkm.cars2<-loess(pkm_cars_pc~GDP_ConstantPrice_pc_new, PKM_AllModes_aug, span = 2, control = loess.control(surface = "direct"))

loes.pkm.train1<-loess(pkm_train_pc~Income_pc_new, PKM_AllModes_aug, span = 2, control = loess.control(surface = "direct"))
loes.pkm.train2<-loess(pkm_train_pc~Income_pc_new+Rail_Density, PKM_AllModes_aug, span = 2, control = loess.control(surface = "direct"))
loes.pkm.train3<-loess(pkm_train_pc~Income_pc_new+Population_Density, PKM_AllModes_aug, span = 2, control = loess.control(surface = "direct"))
loes.pkm.train4<-loess(pkm_train_pc~Income_pc_new+Rail_Density+Population_Density, PKM_AllModes_aug, span = 2, control = loess.control(surface = "direct"))
lm.pkm.train1<-lm(pkm_train_pc~Income_pc_new, PKM_AllModes_aug)
lm.pkm.train2<-lm(pkm_train_pc~Income_pc_new+Rail_Density, PKM_AllModes_aug)
lm.pkm.train3<-lm(pkm_train_pc~Income_pc_new+Population_Density, PKM_AllModes_aug)
lm.pkm.train4<-lm(pkm_train_pc~Income_pc_new+Rail_Density+Population_Density, PKM_AllModes_aug)

summary(loes.pkm.train1)
summary(loes.pkm.train5)
summary(lm.pkm.train1)
summary(lm.pkm.train2)
summary(lm.pkm.train3) #0.34
summary(lm.pkm.train4) #0.39

} ############ Fin des test ############






# 1.3 - usage des modles de rgression retenus pour  :
loess.pkm.cars1<-loess(pkm_cars_pc~Income_pc_new, PKM_AllModes_aug, span = 2, control = loess.control(surface = "direct"))
loess.pkm.moto1<-loess(pkm_moto_pc~Income_pc_new, PKM_AllModes_aug, span = 2, control = loess.control(surface = "direct"))
loess.pkm.buses1<-loess(pkm_buses_pc~Income_pc_new, PKM_AllModes_aug, span = 2, control = loess.control(surface = "direct"))
lm.pkm.train3<-lm(pkm_train_pc~Income_pc_new+Population_Density, PKM_AllModes_aug)
lm.pkm.air6<-lm(pkm_air_pc~Income_pc_new+Year, PKM_AllModes_aug[which(PKM_AllModes_aug$LandArea_Total>5000000),]) #On utilise deux modles prdictifs, l'un pour les grands pays (performant)
lm.pkm.air7<-lm(pkm_air_pc~Income_pc_new+Year, PKM_AllModes_aug[which(PKM_AllModes_aug$LandArea_Total<=5000000),]) #Et l'autre pour le reste du monde (trs mdiocre, mais qui prend une valeur moyenne), sachant qu'on ne trouve pas de modle performant avec les donnes disponibles

#On cre une base intermdiaire qui permettra d'ajouter les variables issues de l'IEA  la base de tous les pays
PKM_AllModes_aug2 <- PKM_AllModes_aug %>% select(c(Country, Year, pkm_cars_pc, pkm_moto_pc, pkm_buses_pc, pkm_train_pc, pkm_air_pc))

##On joint cette base avec la base issue de la banque mondiale
WB_DataBase_aug <- left_join (WB_DataBase_2, PKM_AllModes_aug2, by = c("Country_Name" = "Country", "Year"))  %>%
  #group_by(Country_Name) %>%
  ungroup() %>%
  mutate(pkm.cars.pc.est = predict(loess.pkm.cars1, Income_pc_new, se = FALSE)) %>% #Pour la voiture, qui est le plus important, l'estimation n'est pas mauvaise
  mutate(pkm.moto.pc.est = predict(loess.pkm.moto1, Income_pc_new, se = FALSE)) %>%
  mutate(pkm.buses.pc.est = predict(loess.pkm.buses1, Income_pc_new, se = FALSE)) #%>%
WB_DataBase_aug$pkm.train.pc.est<-0
WB_DataBase_aug$pkm.train.pc.est<-predict(lm.pkm.train3, newdata=WB_DataBase_aug, se = FALSE)
WB_DataBase_aug$pkm.air.pc.est<-0
WB_DataBase_aug$pkm.air.pc.est<-predict(lm.pkm.air6, newdata=WB_DataBase_aug, se = FALSE)
WB_DataBase_aug$pkm.air.pc.est[which(WB_DataBase_aug$LandArea_Total<=5000000)]<-predict(lm.pkm.air7, newdata=WB_DataBase_aug, se = FALSE)[which(WB_DataBase_aug$LandArea_Total<=5000000)]

#Pour finir, on choisit entre les valeurs estimes par le modle et les valeurs donnes par l'IEA et leurs inter et extrapolations quand elles sont disponibles
WB_DataBase_aug3 <- WB_DataBase_aug %>%
  mutate (pkm_cars_pc_new = ifelse(is.na(pkm_cars_pc)==TRUE, pkm.cars.pc.est, pkm_cars_pc)) %>%  #View(WB_DataBase_aug3[,c('Country_Name',"Year","pkm_cars_pc",'pkm.cars.pc.est','pkm_cars_pc_new')])
  mutate (pkm_moto_pc_new = ifelse(is.na(pkm_moto_pc)==TRUE, pkm.moto.pc.est, pkm_moto_pc)) %>%
  mutate (pkm_buses_pc_new = ifelse(is.na(pkm_buses_pc)==TRUE, pkm.buses.pc.est, pkm_buses_pc)) %>%
  mutate (pkm_train_pc_new = ifelse(is.na(pkm_train_pc)==TRUE, pkm.train.pc.est, pkm_train_pc)) %>%
  mutate (pkm_air_pc_new = ifelse(is.na(pkm_air_pc)==TRUE, pkm.air.pc.est, pkm_air_pc)) %>%
  mutate (pkm_air_pc_new = ifelse(pkm_air_pc_new<=0, 0, pkm_air_pc_new)) # on empche les valeurs ngatives, sachant que la valeur minimale dans les donnes IEA pour cette variable est 0
  
remove('lm.pkm.air7','lm.pkm.air6','lm.pkm.train3','loess.income.pc','loess.pkm.buses1', 'loess.pkm.cars1','loess.pkm.moto1')
remove('PKM_AllModes')







# 2. Occupancy rate

## 2.1 On prpare la base IEA et construit la variable de taux d'occupation  partir de cette base
OccupancyRate_IEA<-IEA_Activity %>%
  filter(Product %in% c("Population (10^6)", "Passenger-kilometres (10^9 pkm)", "Vehicle-kilometres (10^9 vkm)")) %>%
  filter(Activity %in% c("Cars/light trucks","General Activity","Motorcycles")) %>%
  pivot_longer(-c(Country,Activity,Product), names_to = "Year", values_to = "Value" ) %>%
  mutate(Variable = case_when(
    Product == "Population (10^6)"                                                 ~ 'population',
    Product == "Passenger-kilometres (10^9 pkm)" & Activity == "Cars/light trucks" ~ 'pkm.cars',
    Product == "Passenger-kilometres (10^9 pkm)" & Activity == "Motorcycles"       ~ 'pkm.moto',
    Product == "Vehicle-kilometres (10^9 vkm)"   & Activity == "Cars/light trucks" ~ 'vkm.cars',
    Product == "Vehicle-kilometres (10^9 vkm)"   & Activity == "Motorcycles"       ~ 'vkm.moto',
  ))  %>%
  select(-Activity) %>%
  select(-Product)  %>%
  pivot_wider(id_cols = c(Country,Year), names_from = Variable, values_from = Value) %>%
  #rename(population = "Population (10^6)", pkm.cars = "Passenger-kilometres (10^9 pkm)", vkm.cars="Vehicle-kilometres (10^9 vkm)") %>%  
  filter(Country!='Armenia') %>% # (valeurs infrieures  1 pkm/vkm)
  mutate(pkm.cars=as.numeric(pkm.cars)) %>%
  mutate(vkm.cars=as.numeric(vkm.cars)) %>%
  mutate(pkm.moto=as.numeric(pkm.moto)) %>%
  mutate(vkm.moto=as.numeric(vkm.moto)) %>%
  mutate(Year=as.numeric(Year)) %>%
  mutate(population=as.numeric(population)) %>%
  mutate(OccupancyRate_cars = pkm.cars/vkm.cars) %>%
  mutate(OccupancyRate_moto = pkm.moto/vkm.moto) %>%
  mutate(OccupancyRate_moto = ifelse (OccupancyRate_moto <=1, 1, OccupancyRate_moto)) %>%
  filter(Year!=2019)



##2.2 On estime un modle de rgression  partir de cette base, on l'applique et on finit par choisir la variable de l'IEA ou la variable estime (si IEA non disponible)
OccupancyRate_IEA2<-left_join(OccupancyRate_IEA,WB_DataBase_2[,c('Country_Name','Year','Income_pc_new')],by=c('Country'='Country_Name','Year')) 
loess.OccupancyRate_cars<-loess(OccupancyRate_cars~Income_pc_new, OccupancyRate_IEA2, span = 2, control = loess.control(surface = "direct"))

if (Display_RegressionGraphs == "yes"){ #Pour avoir une ide de la rgression utilise (dcroissante jusqu' 60000$/cap, puis presque stable)
ggplot(OccupancyRate_IEA2, aes(x=Income_pc_new, y=OccupancyRate_cars))+ #pkm.moto.2014+
  geom_point(aes(colour = Country))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic() 
ggplot(OccupancyRate_IEA2, aes(x=Income_pc_new, y=OccupancyRate_moto))+ #pour la moto, on utilise la moyenne plutt qu'une rgression... celle-ci aurait pu tre intressante si nous avions eu des valeurs pour des pays  bas revenu, mais ce n'est pas le cas, et nous avons une trs forte variabilit globalement
    geom_point(aes(colour = Country))+geom_smooth(method = "loess", span = 2)+
    theme_classic() 
}

WB_DataBase_aug4 <- left_join(WB_DataBase_aug3, OccupancyRate_IEA2[,c("Country", "Year","OccupancyRate_cars","OccupancyRate_moto")], by = c("Country_Name" = "Country", "Year"))  %>%
  #  rename(Country = 'Country.Name') %>%
  mutate(occupancy.rate.est_cars = predict(loess.OccupancyRate_cars,Income_pc_new, se = FALSE)) %>%
  mutate(occupancy.rate.est_moto = mean(OccupancyRate_moto, na.rm = TRUE,w = pkm_moto_pc_new*Population_WB)) %>%
  mutate(OccupancyRate_cars_new=ifelse(is.na(OccupancyRate_cars)==TRUE, occupancy.rate.est_cars, OccupancyRate_cars)) %>%
  mutate(OccupancyRate_moto_new=ifelse(is.na(OccupancyRate_moto)==TRUE, occupancy.rate.est_moto, OccupancyRate_moto)) %>%
  select(-OccupancyRate_cars) %>% #On nettoie la base pour viter la confusion ou l'emploi d'une mauvaise variable
  select(-OccupancyRate_moto) %>%
  select(-occupancy.rate.est_cars) %>%
  select(-occupancy.rate.est_moto)

#On tablit la moyenne qui sera utile ultrieurement
OccupancyRate_moto_mean <- mean(OccupancyRate_IEA2$OccupancyRate_moto, na.rm = TRUE,w = OccupancyRate_IEA2$pkm_moto_pc_new*OccupancyRate_IEA2$Population)

#OccupationRate_final2 <- left_join(OccupationRate_final,WB_PopulationGrowth[which(WB_PopulationGrowth$Year==2014),], by = 'Country') %>%
#  filter(is.na(Region)!=TRUE) %>%
#  group_by(Region) %>%
#  summarize(Occupation.Rate = mean(occupation.rate, na.rm=TRUE, w=Population))

#setwd("~/Transport")
#write.table(OccupationRate_final2, "TransportDemand_OccupationRate_Estimates_V1.csv", row.names=FALSE, sep="|",dec=".", na="NA", col.names = TRUE)












### 3. Variables d'efficacit nergtique et de consommation d'nergie

EnergyTransport_AllModes <- IEA_EnergyDemandTransport %>%
  rename(Mode='Mode/vehicle.type')%>%
  filter(Mode %in% c("Cars/light trucks","Motorcycles"))  %>% #unit : PJ
  pivot_longer(-c(Country,Mode,Product), names_to = "Year", values_to = "Value" ) %>%
  mutate(Value = as.numeric(Value)) %>%
  mutate(Year = as.numeric(Year)) %>%
  mutate(Product = fct_recode(Product,
    'ET1'='Motor gasoline (PJ)',
    'ET2'='Diesel and light fuel oil (PJ)',
    'gas1' = 'LPG (PJ)',
    'gas2' = 'Gas (PJ)',
    'elec' = 'Electricity (PJ)',
    'ET3' = 'Other sources (PJ)',
    'total' = 'Total final energy use (PJ)'
    )) %>%
  mutate(Mode = fct_recode(Mode,
    'moto'= 'Motorcycles',
    'cars'= "Cars/light trucks"
  )) %>%
  mutate(mode_ener = str_c(Mode,"_",Product)) %>%
  select(Country,Year,mode_ener,Value) %>%
  pivot_wider(id_cols=c('Country','Year'), names_from = 'mode_ener', values_from = 'Value') %>%
  mutate(cars_ET = cars_ET1 + cars_ET2 + cars_ET3) %>%
  mutate(moto_ET = moto_ET1 + moto_ET3) %>%
  mutate(cars_gas = cars_gas1 + cars_gas2) %>%
  mutate(moto_gas = moto_gas1) %>%
  select(-c(cars_ET1, cars_ET2, cars_ET3, moto_ET1, moto_ET3, cars_gas1, cars_gas2, moto_gas1))

EnergyTransport_AllModes_2 <- left_join(EnergyTransport_AllModes,PKM_AllModes_aug[,c('Country','Year','pkm_cars','pkm_moto','Income_pc_new')], by = c('Country','Year')) %>%
  mutate(eff_cars_ET = cars_ET/pkm_cars) %>%
  mutate(eff_cars_gas = cars_gas/pkm_cars) %>%
  mutate(eff_cars_elec = cars_elec/pkm_cars) %>%
  mutate(eff_cars_total = cars_total/pkm_cars) %>%
  mutate(eff_moto_ET = moto_ET/pkm_moto) %>%
  mutate(eff_moto_gas = moto_gas/pkm_moto) %>%
  mutate(eff_moto_elec = moto_elec/pkm_moto) %>%
  mutate(eff_moto_total = moto_total/pkm_moto)

EnergyTransport_AllModes_3 <- left_join(EnergyTransport_AllModes_2,OccupancyRate_IEA2, by = NULL) %>%
  mutate(eff_cars_ET_vkm = eff_cars_ET*OccupancyRate_cars) %>%
  mutate(eff_cars_gas_vkm = eff_cars_gas*OccupancyRate_cars) %>%
  mutate(eff_cars_elec_vkm = eff_cars_elec*OccupancyRate_cars) %>%
  mutate(eff_cars_total_vkm = eff_cars_total*OccupancyRate_cars) %>%
  mutate(OccupancyRate_moto_cor = ifelse(is.na(OccupancyRate_moto)==TRUE,OccupancyRate_moto_mean,ifelse(OccupancyRate_moto<1,OccupancyRate_moto_mean,OccupancyRate_moto))) %>%
  mutate(eff_moto_ET_vkm = eff_moto_ET*OccupancyRate_moto) %>%
  mutate(eff_moto_gas_vkm = eff_moto_gas*OccupancyRate_moto) %>% 
  mutate(eff_moto_elec_vkm = eff_moto_elec*OccupancyRate_moto) %>%
  mutate(eff_moto_total_vkm = eff_moto_total*OccupancyRate_moto)


## Pour info, ci-dessous les fonctions de rgression retenues pour respectivement cars et motorcycles 
###On constate que les consommations d'nergie pour les motos pour le gaz et l'lectricit sont nulles
##Finalement pour le gaz et l'lec auto, on prendra la valeur moyenne
##Pour la moto on prendre plutt la rgression lm
if (Display_RegressionGraphs == "yes"){
ggplot(EnergyTransport_AllModes_3, aes(x=Income_pc_new, y=eff_cars_ET_vkm))+ geom_point(aes(colour = Country))+geom_smooth(method = "lm", span = 2)+  theme_classic()
  ggplot(EnergyTransport_AllModes_3, aes(x=Income_pc_new, y=eff_cars_ET))+ geom_point(aes(colour = Country))+geom_smooth(method = "loess", span = 2)+  theme_classic() 
ggplot(EnergyTransport_AllModes_3, aes(x=Income_pc_new, y=eff_cars_gas_vkm))+ geom_point(aes(colour = Country))+geom_smooth(method = "lm", span = 2)+theme_classic()
ggplot(EnergyTransport_AllModes_3[which(EnergyTransport_AllModes_3$Country!="Slovak Republic"),], aes(x=Income_pc_new, y=eff_cars_elec_vkm))+ geom_point(aes(colour = Country))+geom_smooth(method = "lm", span = 2)+theme_classic()
ggplot(EnergyTransport_AllModes_3, aes(x=Income_pc_new, y=eff_moto_ET_vkm))+ geom_point(aes(colour = Country))+geom_smooth(method = "loess", span = 2)+theme_classic()
ggplot(EnergyTransport_AllModes_3, aes(x=Income_pc_new, y=eff_moto_ET_vkm))+ geom_point(aes(colour = Country))+geom_smooth(method = "lm", span = 2)+theme_classic()
ggplot(EnergyTransport_AllModes_3, aes(x=Income_pc_new, y=eff_moto_gas_vkm))+ geom_point(aes(colour = Country))+geom_smooth(method = "loess", span = 2)+theme_classic()
ggplot(EnergyTransport_AllModes_3, aes(x=Income_pc_new, y=eff_moto_elec_vkm))+ geom_point(aes(colour = Country))+geom_smooth(method = "loess", span = 2)+theme_classic()
}

#View(EnergyTransport_AllModes_3[which(EnergyTransport_AllModes_3$eff_cars_elec_vkm>10^-11),])


#Estimation des efficacits par source et par pays
## Cration des modles de rgression
lm.eff.cars.ET<-lm(eff_cars_ET_vkm~Income_pc_new, EnergyTransport_AllModes_3)
#lm.eff.cars.gas<-lm(eff_cars_gas_vkm~Income_pc_new, EnergyTransport_AllModes_3)
#loess.eff.cars.elec<-loess(eff_cars_elec_vkm~Income_pc_new, EnergyTransport_AllModes_3, span = 2,control = loess.control(surface = "direct"))
lm.eff.moto.ET<-lm(eff_moto_ET_vkm~Income_pc_new, EnergyTransport_AllModes_3) #NB : pour les motos, on considre un taux d'occupation de 1
loess.eff.moto.gas<-loess(eff_moto_gas~Income_pc_new, EnergyTransport_AllModes_3, span = 2,control = loess.control(surface = "direct")) #nul dans le jeu de donnes utilis
loess.eff.moto.elec<-loess(eff_moto_elec~Income_pc_new, EnergyTransport_AllModes_3, span = 2,control = loess.control(surface = "direct")) #nul dans le jeu de donnes utilis
#eff_moto_ET_vkm_min<-min(EnergyTransport_AllModes_3$eff_moto_ET_vkm,na.rm=TRUE) #On remarque que la rgression permet des valeurs ngatives, on utilise la valeur minimale de la base IEA comme valeur seuil (pour les valeurs estimes infrieures) - finalement remplac par la moyenne


#Utilisation des modles puis choix de la valeur IEA quand disponible, plutt que la valeur estime
WB_DataBase_aug5_temp <- left_join(WB_DataBase_aug4,EnergyTransport_AllModes_3[,which(colnames(EnergyTransport_AllModes_3)!='Income_pc_new')],by = c("Country_Name" = "Country", "Year"))
WB_DataBase_aug5 <- WB_DataBase_aug5_temp %>%
  mutate(eff.cars.ET.est = predict(lm.eff.cars.ET, newdata = WB_DataBase_aug5_temp, se = FALSE)) %>%
  mutate(eff.cars.gas.est = mean(eff_cars_gas_vkm, na.rm=TRUE, w=Population_WB*pkm_cars_pc_new)) %>%  # on choisit d'tablir l'estimation  la moyenne pondre des valeurs par pays, la rgression n'tant pas convaincante
  mutate(eff.cars.elec.est = 0) %>% # on choisit d'tablir l'estimation  0 ; les rgressions tant trop dpendantes des cas particuliers sur 2000-2018
  mutate(eff.moto.ET.est = mean(eff_moto_ET_vkm, na.rm=TRUE, w=Population_WB*pkm_moto_pc_new)) %>%
  mutate(eff.moto.gas.est = predict(loess.eff.moto.gas, Income_pc_new, se = FALSE)) %>% # = 0 (avec les donnes 2000-2018)
  mutate(eff.moto.elec.est = predict(loess.eff.moto.elec, Income_pc_new, se = FALSE)) %>%  # = 0  (avec les donnes 2000-2018)
  mutate(eff_cars_ET_vkm_new=ifelse(is.na(eff_cars_ET_vkm)==TRUE, eff.cars.ET.est, eff_cars_ET_vkm)) %>%
  mutate(eff_cars_gas_vkm_new=ifelse(is.na(eff_cars_gas_vkm)==TRUE, eff.cars.gas.est, eff_cars_gas_vkm)) %>%
  mutate(eff_cars_elec_vkm_new=ifelse(is.na(eff_cars_elec_vkm)==TRUE, eff.cars.elec.est, eff_cars_elec_vkm)) %>%
  mutate(eff_moto_ET_vkm_new=ifelse(is.na(eff_moto_ET_vkm)==TRUE, eff.moto.ET.est, eff_moto_ET_vkm)) %>%
  #mutate(eff_moto_ET_vkm_new=ifelse(eff_moto_ET_vkm_new-eff_moto_vkm_min<=0,eff_moto_ET_vkm_min,eff_moto_ET_vkm_new)) %>% #Correction des valeurs estimes trs basses, voire ngatives dues  la rgression - inutile puisqu'on a pris finalement la moyenne
  mutate(eff_moto_gas_vkm_new=ifelse(is.na(eff_moto_gas)==TRUE, eff.moto.gas.est, eff_moto_gas_vkm)) %>%
  mutate(eff_moto_gas_vkm_new=ifelse(eff_moto_gas_vkm_new<0,0,eff_moto_gas_vkm_new)) %>% #Correction des valeurs estimes trs basses, voire ngatives dues  la rgression ; inutile sur les donnes initiales
  mutate(eff_moto_elec_vkm_new=ifelse(is.na(eff_moto_elec)==TRUE, eff.moto.elec.est, eff_moto_elec_vkm)) %>%
  mutate(eff_moto_elec_vkm_new=ifelse(eff_moto_elec_vkm_new<0,0,eff_moto_elec_vkm_new)) %>% #Correction des valeurs estimes trs basses, voire ngatives dues  la rgression ; inutile sur les donnes initiales
  select(c("Country_Name","Country_Code","Year","Population_WB","Income_pc_new","pkm_cars_pc_new","pkm_moto_pc_new","pkm_buses_pc_new","pkm_train_pc_new","pkm_air_pc_new","OccupancyRate_cars_new","OccupancyRate_moto_new","eff_cars_ET_vkm_new","eff_cars_gas_vkm_new","eff_cars_elec_vkm_new","eff_moto_ET_vkm_new", "eff_moto_gas_vkm_new","eff_moto_elec_vkm_new")) %>% #colnames(WB_DataBase_aug5)[c(1,2,3,10,25,39:43,46,71:76)] 
  mutate(Cons_Hsld_PrivateModes = Population_WB*(eff_cars_ET_vkm_new*pkm_cars_pc_new/OccupancyRate_cars_new+eff_moto_ET_vkm_new*pkm_moto_pc_new/OccupancyRate_moto_new))
OccupancyRate_new

#On corrige plusieurs variables pour la Chine,  partir de plusieurs sources de donnes (en particulier consommation de carburant - sur lequel on se base pour corriger aussi pkm cars et moto - et pkm rail et air)
#WB_DataBase_aug5_copy<-WB_DataBase_aug5 - ligne pour vrifier
setwd("~/Transport")
Correctif_PKM_China<-read.xlsx("Correction_PKM_China_fromOtherSources.xlsx",sheet="China") #sur la priode 2000-2018
#WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("OccupancyRate_new")]<-WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("OccupancyRate_new")]/Correctif_PKM_China[,"China.Gasoline.Demand.PJ"]*WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("Cons_Hsld_PrivateModes")] #On choisit plutt de corriger les pkm que le taux d'occupation
WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("pkm_cars_pc_new")]<-WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("pkm_cars_pc_new")]*Correctif_PKM_China[,"China.Gasoline.Demand.PJ"]/WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("Cons_Hsld_PrivateModes")]
WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("pkm_moto_pc_new")]<-WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("pkm_moto_pc_new")]*Correctif_PKM_China[,"China.Gasoline.Demand.PJ"]/WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("Cons_Hsld_PrivateModes")]
WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("Cons_Hsld_PrivateModes")]<-WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("Cons_Hsld_PrivateModes")]*Correctif_PKM_China[,"China.Gasoline.Demand.PJ"]/WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("Cons_Hsld_PrivateModes")]
WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("pkm_train_pc_new")]<-Correctif_PKM_China[,"Railways_pkm"]/WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("Population_WB")]
WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("pkm_air_pc_new")]<-Correctif_PKM_China[,"Domestic.air_pkm"]/WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),c("Population_WB")]

#View(WB_DataBase_aug5_copy[which(WB_DataBase_aug5$Country_Name=="China"),]) # - ligne pour vrifier
#View(WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),]) # - ligne pour vrifier
#write.table(WB_DataBase_aug5[which(WB_DataBase_aug5$Country_Name=="China"),], "EstimationTransport_MainlyFromIEA_China_PJ.csv", row.names=FALSE, sep="|",dec=".", na="NA", col.names = TRUE)

WB_DataBase_aug5[WB_DataBase_aug5<0] <- 0

WB_DataBase_final<-WB_DataBase_aug5 %>%
  mutate(pkm_PrivateModes = Population_WB*(pkm_cars_pc_new+pkm_moto_pc_new)) %>%
  mutate(pkm_Air = Population_WB*pkm_air_pc_new) %>%
  mutate(pkm_OtherTransport = Population_WB*(pkm_buses_pc_new+pkm_train_pc_new))

setwd("~/Transport")
write.table(WB_DataBase_final, "EstimationTransport_MainlyFromIEA_ByCountry_PJ.csv", row.names=FALSE, sep="|",dec=".", na="NA", col.names = TRUE)


WB_DataBase_final_Reg_temp <- left_join(WB_DataBase_final,CountryRegion,by=c("Country_Code"="ISO3")) %>%
  group_by(Im_region,Year) %>%
  summarise(Income_pc_new = mean(Income_pc_new, na.rm=TRUE, w=Population_WB),
            OccupancyRate_cars = mean(OccupancyRate_cars_new, na.rm=TRUE, w=(Population_WB*pkm_cars_pc_new)), #la pondration pourrait tre faite sur vkm
            OccupancyRate_moto = mean(OccupancyRate_moto_new, na.rm=TRUE, w=(Population_WB*pkm_moto_pc_new)), 
            eff_cars_ET_vkm = mean(eff_cars_ET_vkm_new, na.rm=TRUE, w=(pkm_cars_pc_new*Population_WB))*Convert_EnergyUnit, #pondration sur les pkm
            eff_cars_gas_vkm = mean(eff_cars_gas_vkm_new, na.rm=TRUE, w=(pkm_cars_pc_new*Population_WB))*Convert_EnergyUnit,
            eff_cars_elec_vkm = mean(eff_cars_elec_vkm_new, na.rm=TRUE, w=(pkm_cars_pc_new*Population_WB))*Convert_EnergyUnit,
            eff_moto_ET_vkm = mean(eff_moto_ET_vkm_new, na.rm=TRUE, w=(pkm_moto_pc_new*Population_WB))*Convert_EnergyUnit, #pondration sur les pkm
            eff_moto_gas_vkm = mean(eff_moto_gas_vkm_new, na.rm=TRUE, w=(pkm_moto_pc_new*Population_WB))*Convert_EnergyUnit,
            eff_moto_elec_vkm = mean(eff_moto_elec_vkm_new, na.rm=TRUE, w=(pkm_moto_pc_new*Population_WB))*Convert_EnergyUnit,
            pkm_PrivateModes = sum(pkm_PrivateModes, na.rm=TRUE),
            pkm_Air = sum(pkm_Air, na.rm=TRUE),
            pkm_OtherTransport = sum(pkm_OtherTransport, na.rm=TRUE),
            pkm_cars_pc = mean(pkm_cars_pc_new, na.rm=TRUE, w=Population_WB),
            pkm_moto_pc = mean(pkm_moto_pc_new, na.rm=TRUE, w=Population_WB),
            pkm_buses_pc = mean(pkm_buses_pc_new, na.rm=TRUE, w=Population_WB),
            pkm_train_pc = mean(pkm_train_pc_new, na.rm=TRUE, w=Population_WB),
            pkm_air_pc = mean(pkm_air_pc_new, na.rm=TRUE, w=Population_WB),
            Cons_Hsld_PrivateModes = Convert_EnergyUnit*sum(Cons_Hsld_PrivateModes, na.rm=TRUE),
            Population_WB = sum(Population_WB,na.rm=TRUE))  %>%
  ungroup() %>%
  mutate(OccupancyRate_PrivateModes = (pkm_cars_pc+pkm_moto_pc)/(pkm_cars_pc/OccupancyRate_cars + pkm_moto_pc/OccupancyRate_moto)) %>%
  mutate(eff_ET_PrivateModes_vkm = Cons_Hsld_PrivateModes/(pkm_PrivateModes/OccupancyRate_PrivateModes)) %>%
  mutate(ID_reg_Im=Im_region) %>% #On cre un code pour rordonner les lignes selon l'ordre des rgions Imaclim-R monde
  mutate(ID_reg_Im=fct_recode(ID_reg_Im,
                              '1' = 'USA',
                              '2' = 'CAN',
                              '3' = 'EUR',
                              '4' = 'JAN',
                              '5' = 'CIS',
                              '6' = 'CHN',
                              '7' = 'IND',
                              '8' = 'BRA',
                              '9' = 'MDE',
                              '10'= 'AFR',
                              '11'= 'RAS',
                              '12'= 'RAL')) %>%
  mutate(ID_reg_Im = as.numeric(as.character(ID_reg_Im))) %>%
  arrange(ID_reg_Im) %>%
  filter(Year==Year_Calibration)


Correctif_AirTravel_ICAO<-read.xlsx("~/Transport/AirTransport_ShareDomestic.xlsx",sheet="ICAO") #sur l'anne 2014, on corrige les donnes de demande de passagers.km  l'aide de donnes de l'ICAO. Le problme tait notamment que seuls les vols domestiques (internes  une rgion) sont pris en compte. Par contre, on ne distingue pas les voyages de tourisme des voyages d'affaire (pas de statistiques identifies, il faudra produire une estimation  partir de DF/CI en service de transport ; sachant que les prix pratiqus pour le business sont normalement plus levs - https://www.investopedia.com/ask/answers/041315/how-much-revenue-airline-industry-comes-business-travelers-compared-leisure-travelers.asp)

if (LoadGTAP_forAirCorrection == 'yes') { #Ci-dessous, pour complter le correctif, on utilise les donnes GTAP et la demande en air transport DF / (DF + CI) pour approcher la part des pkm AIR ralise par les mnages
setwd("~/")
DF_dom<-read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/C_hsld_dom.csv",sep="|",dec = '.',row.names = 1)  #colClasses = c('character',rep('numeric',26))
DF_imp<-read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/C_hsld_imp.csv",sep="|",dec = '.',row.names = 1)
atp_DF<-as.data.frame(DF_dom[,'atp']+DF_imp[,'atp'])

atp_CI_dom<-as.data.frame(c(sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_dom_USA.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_dom_CAN.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_dom_EUR.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_dom_JAN.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_dom_CIS.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_dom_CHN.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_dom_IND.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_dom_BRA.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_dom_MDE.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_dom_AFR.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_dom_RAS.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_dom_RAL.csv",sep="|",dec = '.',row.names = 1)['atp',])))

atp_CI_imp<-as.data.frame(c(sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_imp_USA.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_imp_CAN.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_imp_EUR.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_imp_JAN.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_imp_CIS.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_imp_CHN.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_imp_IND.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_imp_BRA.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_imp_MDE.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_imp_AFR.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_imp_RAS.csv",sep="|",dec = '.',row.names = 1)['atp',]),
                            sum(read.csv2("~/GTAP_Imaclim_before_hybridation/outputs_GTAP10_2014/CI_imp_RAL.csv",sep="|",dec = '.',row.names = 1)['atp',])))
atp_CI <- atp_CI_imp + atp_CI_dom

#On cre le vecteur final de cette part pour les 12 rgions
atp_shareDF<-as.data.frame(atp_DF/(atp_DF+atp_CI*Correctif_AirTravel_ICAO[1:12,'Im_estimation_sharePassenger_2014']),row.names = rownames(DF_dom)) %>% rename (share_DF_in_atp = everything()) #On introduit galement ici l'estimation de VA du secteur fret vs passagers
atp_shareDF['USA',]<-atp_shareDF['CAN',]  #Il semble y avoir une diffrence de comptabilit entre USA et les autres pays : trs faible DF dans le secteur de l'aviation, par contre trs forte DF de recreational other services, qui a lui mme un input trs lev d'aviation. On utilise donc le ratio du canada (60%, au lieu de 5% avec la mthode prcdente)
atp_shareDF['CHN',]<-atp_shareDF['CIS',]  #De mme, la valeur pour la Chine sort du lot (~11%). Je n'ai rien trouv dans la littrature sur une spcificit Chinoise sur le sujet, j'affecte donc la valeur minimale du reste des rgions (CIS = 37%)
}


WB_DataBase_final_Reg<-left_join(WB_DataBase_final_Reg_temp,Correctif_AirTravel_ICAO[1:12,c("Im_region","Im_estimation_pkm_2014")],by='Im_region')  
WB_DataBase_final_Reg$pkm_Air_corr<-0
WB_DataBase_final_Reg$pkm_Air_corr<-WB_DataBase_final_Reg$Im_estimation_pkm_2014*1000000 * as.matrix(atp_shareDF)
WB_DataBase_final_Reg$pkm_Air_pc_corr<-WB_DataBase_final_Reg$pkm_Air_corr/WB_DataBase_final_Reg$Population_WB

#WB_DataBase_final_Reg$pkm_Air_corr/WB_DataBase_final_Reg$Population_WB
#WB_DataBase_final_Reg$pkm_Air_corr/WB_DataBase_final_Reg$pkm_Air

setwd("~/Transport")
write.table(WB_DataBase_final_Reg, "EstimationTransport_MainlyFromIEA_ByRegion_Mtoe.csv", row.names=FALSE, sep="|",dec=".", na="NA", col.names = TRUE)

####A finaliser
#On va recalculer un Occupancy rate tenant compte de la moto
write.table(WB_DataBase_final_Reg[,c('Im_region','OccupancyRate_PrivateModes')], "tauxderemplissageauto_2014.csv", row.names=FALSE, sep="|",dec=".", na="NA", col.names = TRUE)

#On va recalculer une efficacit en tenant compte de la moto
write.table(WB_DataBase_final_Reg[,c('Im_region','eff_ET_PrivateModes_vkm')], "conso_unitaire_Mtoe_vkm_2014.csv", row.names=FALSE, sep="|",dec=".", na="NA", col.names = TRUE)

#Ok, normalement en prenant les trois colonnes, c'est bon. Ordre : Air, Other, Private mode. Comparer avec les valeurs 2001 pour info.
write.table(WB_DataBase_final_Reg[,c('Im_region','pkm_Air_corr','pkm_OtherTransport','pkm_PrivateModes')], "pkm_ref_calib_2014.csv", row.names=FALSE, sep="|",dec=".", na="NA", col.names = TRUE)





#Ci-dessous quelques graphiques de vrification des ordres de grandeur des valeurs
if (Display_RegressionGraphs == "yes") {
plot(WB_DataBase_final$eff_cars_ET_new~WB_DataBase_final$Income_pc_new)
plot(WB_DataBase_final$eff_moto_ET_new~WB_DataBase_final$Income_pc_new)
plot(WB_DataBase_final$eff_moto_gas_new~WB_DataBase_final$Income_pc_new)
plot(WB_DataBase_final$pkm_buses_pc_new~WB_DataBase_final$Income_pc_new)
plot(WB_DataBase_final$pkm_train_pc_new~WB_DataBase_final$Income_pc_new)
plot(WB_DataBase_final$pkm_air_pc_new~WB_DataBase_final$Income_pc_new)
plot(WB_DataBase_final$Cons_Hsld_PrivateModes~WB_DataBase_final$Population_WB)
plot(WB_DataBase_final$OccupancyRate_new~WB_DataBase_final$Income_pc_new)
plot(WB_DataBase_final$pkm_PrivateModes~WB_DataBase_final$Population_WB)
plot(WB_DataBase_final$pkm_Air~WB_DataBase_final$Population_WB)
plot(WB_DataBase_final$pkm_OtherTransport~WB_DataBase_final$Population_WB)
}




### Annexe / brouillon

annex <- "no"
if (annex == "yes") {

View(WB_DataBase_2[which(WB_DataBase_2$GDP_ConstantPrice_pc_new<0),])
View(WB_DataBase_2[which(is.na(WB_DataBase_2$GDP_ConstantPrice_pc_new)==TRUE),])
unique(WB_DataBase_2[which(is.na(WB_DataBase_2$GDP_ConstantPrice_pc_new)==TRUE),"Country_Name"])
View(WB_DataBase_2[which(WB_DataBase_2$Income_pc_new<0),])

ggplot(WB_DataBase_2, aes(x=GDP_ConstantPrice_pc_new, y=Income_pc_new))+ #which(WB_DataBase$Income_pc<0)
  geom_point(aes(colour = Country_Name))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic() + theme(legend.position='none')

ggplot(WB_DataBase_2, aes(x=GDP_ConstantPrice_pc, y=Income_pc))+ #which(WB_DataBase$Income_pc<0)
  geom_point(aes(colour = Country_Name))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic() + theme(legend.position='none')

ggplot(WB_DataBase[which(WB_DataBase$Income_pc<0),], aes(x=GDP_ConstantPrice_pc_new, y=Population_WB))+
  geom_point(aes(colour = Country_Name))+geom_smooth(method = "loess", span = 2)+  #method = "gam" #formula = y ~ splines::bs(x, 3), se = FALSE
  theme_classic() #+ theme(legend.position='none')

View(WB_DataBase_2[which(WB_DataBase_2$Country_Name%in%c('Afganistan', 'Chad', 'Ethiopia', 'Nauru', 'Myanma', 'Timor-Leste', 'Myanmar')&is.na(WB_DataBase_2$Income_pc)==TRUE),])

View(WB_DataBase[which(is.na(WB_DataBase$Population_WB)==TRUE),])
View(WB_DataBase[which(WB_DataBase$Country_Name=="Eritrea"),])
View(WB_DataBase[which(WB_DataBase$Country_Name=="Afghanistan"),])
View(WB_DataBase_copy[which(WB_DataBase_copy$Country_Name=="Indonesia"),])
View(WB_DataBase_copy[which(WB_DataBase_copy$Country_Name=="Kuwait"),])
View(WB_DataBase_copy[which(WB_DataBase_copy$Country_Name=="Nauru"),])
View(WB_DataBase[which(WB_DataBase$Country_Name=="Nauru"),])
View(WB_DataBase_2[which(WB_DataBase_2$Country_Name=="Kuwait"),])
View(WB_DataBase_2[which(WB_DataBase_2$Country_Name%in%c('Afganistan', 'Chad', 'Ethiopia', 'Nauru', 'Myanma', 'Timor-Leste', 'Myanmar')),])
#Liste de pays  valeurs aberrantes  traiter 
#Kuwait et United Arab Emirates : valeurs trs leves de revenu par capita ; prfrer le calcul  partir du GDP/cap plutt que l'extrapolation (car donnes trs variables)
#Nauru : PIB ngatif
#Income/cap ngatif, du fait de l'imputation : Afganistan, Chad, Ethiopia, Nauru, Myanma, Timor-Leste, Myanmar
#et dans les donnes d'origine Equatorial Guinea (pour l'anne 2005)
}
