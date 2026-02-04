// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


source(paste(MFA ,"mfa_Ind-Prod-Year.R"        , sep=sep))
source(paste(MFA ,"mfa_Prod-Ind-Year.R"        , sep=sep))
#source(paste(MFA ,"mfa-plots-Ind_dist_joint.R" , sep=sep))
source(paste(MFA ,"mfa_contrib-dim.R"          , sep=sep))

yearVector        <- years[-c(39,40,41)]
yearVector37      <- years[-c(38,39,40,41)]
industryVector11  <- c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ") # K = "70" + "71t74"
industryLabels11  <- c("Agr","Mining","Manufact","Elec Gas","Construc","Sales","Trans Comm","Finance","Real estate","Rental","Community")

industryVector12  <- c("AtB","C","D","E","F","GtH","60t63","64","J","70","71t74","LtQ") # K = "70" + "71t74"
industryLabels12  <- c("Agr","Mining","Manufact","Elec Gas","Construc","Sales","Transport","Post Telecomm","Finance","Real estate","Rental","Community")

industryVector30  <- c("AtB","C","15t16","17t19","20","21t22","23","24","25","26","27t28","29","30t33","34t35","36t37","E","F","50","51","52","H","60t63","64","J","70","71t74","L","M","N","O")
industryLabels30  <- c("Agri","Mining","Manu-Food","Manu-Text","Manu-Wood","Manu-PPP","Manu-Refined","Manu-Chem","Manu-Rubber","Manu-Mineral","Manu-Metal","Manu-Mach","Manu-ElecEquip","Manu-TranspEq","Manu-NEC","Elec Gas","Construc","Sale-veh","Sale-wholesale","Sale-nonveh","Hotels","Transport","Comm","Finance","Real estate","RE Business","Public services","Edu","Health","Other services")

#industryVector32  <- c("AtB","C","15t16","17t19","20","21t22","23","24","25","26","27t28","29","30t33","34t35","36t37","E","F","50","51","52","H","60t63","64","J","70","71t74","L","M","N","O","P","Q")
#Données manquantes pour 2 des 32 niveaux.

industryVectorManu  <- c("15t16","17t19","20","21t22","23","24","25","26","27t28","29","30t33","34t35","36t37")
industryLabelsManu  <- c("Manu-Food","Manu-Text","Manu-Wood","Manu-PPP","Manu-Refined","Manu-Chem","Manu-Rubber","Manu-Mineral","Manu-Metal","Manu-Mach","Manu-ElecEquip","Manu-TranspEq","Manu-NEC")

industryVectorGHIJK <- c("50", "51", "52", "H", "60t63", "64", "J","70","71t74")
industryLabelsGHIJK <- c("50", "51", "52", "H", "60t63", "64", "J","70","71t74")

productVector8    <- c("RStruc","OCon","OMach","TraEq","Other","CT","Soft","IT")   
productVector5    <- c("RStruc","OCon","OMach","TraEq","Other")
productVector4    <- c("RStruc","OCon","OMach","TraEq")
productVector3    <- c("CT","Soft","IT")

colour_products7    <- c("#191970", "#2f4ea3", "#8B4513", "#D55E00", "#009E73", "#ADFF2F", "#228B22")
colour_products8    <- c("#191970", "#2f4ea3", "#8B4513", "#D55E00", "#A52A2A", "#009E73", "#ADFF2F", "#228B22")
colour_industries11 <- c("#A6CEE3", "#1F78B4", "#01665E", "#33A02C", "#FB9A99", "#E31A1C", "#FDBF6F", "#FF7F00", "#191970", "#6A3D9A", "#FFD700")
colour_industries12 <- c("#A6CEE3", "#1F78B4", "#01665E", "#33A02C", "#FB9A99", "#E31A1C", "#FDBF6F", "#444444","#FF7F00", "#191970", "#6A3D9A", "#FFD700")

industryVector <- industryVector12
industryLabels <- industryLabels12 

#fileName.industry <- "Manu"
#fileName.industry <- "GHIJK"
#fileName.industry <- "30"
#fileName.industry <- "5"
#fileName.industry <- "12"


#---------------------------------------------------------------------------------
folder <- paste0(MFA,"/reducedSystem_Ind-Prod-Year-value-12x6/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)
  
lies12x6 <- outputMFACT.permutation1(dsAgg, "USA", "I", yearVector, industryVector=industryVector12, productVector=c(productVector5,"CT"), share=FALSE, 100, colour_industries12, colour_products8 )


folder <- paste0(MFA,"/reducedSystem_Ind-Prod-Year-share-12x8/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

lies12x8 <- outputMFACT.permutation1(dsAgg, "USA", "I", yearVector, industryVector=industryVector12, productVector=productVector8, share=TRUE, 100, colour_industries12, colour_products8 )

folder <- paste0(MFA,"/reducedSystem_Ind-Prod-Year-value-12x8/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

lies12x8 <- outputMFACT.permutation1(dsAgg, "USA", "I", yearVector, industryVector=industryVector12, productVector=productVector8, share=FALSE, 100, colour_industries12, colour_products8 )


#folder <- paste0(MFA,"/reducedSystem_Prod-Ind-Year-share-8x12/")
#cat("Results will be located in",folder,"\n\n")
#dir.create(folder, recursive = TRUE)
#setwd(folder)
  
#lies12.ProdInd <- outputMFACT.permutation2(dsAgg, "USA", "I", yearVector,industryVector=industryVector12, productVector=productVector8, share=TRUE, quality=100, colour_industries=colour_industries12, colour_products=colour_products8)
#------------------------------------------------
#AUT
#DNK some negative values for Other (skew the analysis) (neg values means sale exceeds )
#ITA RStruc classification
#JPN
#folder <- paste0(MFA,"/reducedSystem_Ind-Prod-Year-xcountries-value-12x5/")
temp.mfact.AUS <- dfInput.C(dsAgg, countryVector="AUS", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.AUT<- dfInput.C(dsAgg, countryVector="AUS", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.DNK <- dfInput.C(dsAgg, countryVector="DNK", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
testDNK<- temp.mfact.DNK
testDNK[testDNK<0] <- NA
temp.mfact.ESP <- dfInput.C(dsAgg, countryVector="ESP", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.FIN <- dfInput.C(dsAgg, countryVector="FIN", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.FRA <- dfInput.C(dsAgg, countryVector="FRA", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.ITA <- dfInput.C(dsAgg, countryVector="ITA", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
testITA<- temp.mfact.ITA
for(colHere in 0:(as.integer(dim(testITA)[2]/8)-1))
{
    testITA["70",6+colHere*8] <- testITA["71t74",6+colHere*8] + testITA["70",6+colHere*8]
    testITA["71t74",6+colHere*8] <- 0
}
temp.mfact.JPN <- dfInput.C(dsAgg, countryVector="JPN", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.NLD <- dfInput.C(dsAgg, countryVector="NLD", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.UK <- dfInput.C(dsAgg, countryVector="UK", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.USA <- dfInput.C(dsAgg, countryVector="USA", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)

productVector5CT <- c("RStruc","OCon","OMach","TraEq","CT")
productVector7 <- c("RStruc","OCon","OMach","TraEq","CT","Soft","IT")
colour_products5CT <- c("#191970","#2f4ea3","#8B4513","#D55E00","#009E73")

folder <- paste0(MFA,"/test/wrappedFree/10Countries-8prod-negTo0")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

lies5 <- outputMFACT.C(dsAgg, c("AUS","DNK","ESP","FIN","FRA","NLD","UK","USA"), "I", yearVector, industryVector=industryVector12, productVector=productVector5CT, share=FALSE, quality=100, colour_industries12, colour_products5CT)

lies <- outputMFACT.C(dsAgg, c("AUS","DNK","ESP","FIN","FRA","ITA","NLD","UK","USA"), "I", yearVector, industryVector=industryVector12, productVector=productVector8, share=FALSE, quality=100, colour_industries12, colour_products8)
lies.11C <- outputMFACT.C(dsAgg, c("AUS","AUT","DNK","ESP","FIN","FRA","ITA","JPN","NLD","UK","USA"), "I", yearVector, industryVector=industryVector12, productVector=productVector8, share=FALSE, quality=100, colour_industries12, colour_products8)


#----------------------------------------------------------
folder <- paste0(MFA,"/test/cpy/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)
countryVector <- c("AUS", "DNK", "ESP", "FIN", "ITA", "JPN", "NLD", "UK", "USA", "FRA")

lies.cpy <- outputMFACT.cpy(dsAgg, industryHere="TOT", varHere="I", countryVector, yearVector, productVector, share=FALSE, quality=100, colour_industries12, colour_products8)

outputMFACT.cpy <- function(inputdata, industryHere, varHere, countryVector, yearVector, productVector, share=ALSE, quality, colour_industries, colour_products)


