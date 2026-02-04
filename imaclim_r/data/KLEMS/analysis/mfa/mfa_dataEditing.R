// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

# Input for 1970-2007 for 9 countries for which data are available over this period. For JPN only data upto 2006, 
# input for 10 countries below, including JPN, for 1970-2006.

temp.mfact.AUS <- dfInput.C(dsAgg, countryVector="AUS", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
#temp.mfact.AUT<- dfInput.C(dsAgg, countryVector="AUT", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.DNK.0 <- dfInput.C(dsAgg, countryVector="DNK", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.DNK <- temp.mfact.DNK.0
temp.mfact.DNK[temp.mfact.DNK<0] <- NA
temp.mfact.ESP <- dfInput.C(dsAgg, countryVector="ESP", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.FIN <- dfInput.C(dsAgg, countryVector="FIN", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.FRA <- dfInput.C(dsAgg, countryVector="FRA", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.ITA.0 <- dfInput.C(dsAgg, countryVector="ITA", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.ITA <- temp.mfact.ITA.0
for(colHere in 0:(as.integer(dim(temp.mfact.ITA)[2]/8)-1))
{
  temp.mfact.ITA["70",6+colHere*8] <- temp.mfact.ITA["71t74",6+colHere*8] + temp.mfact.ITA["70",6+colHere*8]
  temp.mfact.ITA["71t74",6+colHere*8] <- 0
}
#temp.mfact.JPN <- dfInput.C(dsAgg, countryVector="JPN", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.NLD <- dfInput.C(dsAgg, countryVector="NLD", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.UK <- dfInput.C(dsAgg, countryVector="UK", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.USA <- dfInput.C(dsAgg, countryVector="USA", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)

countryVector <- c("AUS","DNK","ESP","FIN","FRA","ITA","NLD","UK","USA")
temp.mfact <- bind_cols(temp.mfact.AUS,temp.mfact.DNK,temp.mfact.ESP,temp.mfact.FIN,temp.mfact.FRA,temp.mfact.ITA,
                        temp.mfact.NLD,temp.mfact.UK,temp.mfact.USA)

rownames(temp.mfact) <- rownames(temp.mfact.AUS)

outputMFACT.C.edited <- function(temp.mfact, countryVector, varHere, yearVector, industryVector, productVector, share=FALSE, quality, colour_industries, colour_products)
{
  #temp.mfact <- dfInput.C(inputdata, countryVector, varHere, yearVector, industryVector, productVector, share)
  #fileName   <- paste("MFACT",varHere, countryHere ,sep="_")
  nCountries = length(countryVector)
  fileName   <- paste0(nCountries,"countries_", varHere)
  res.mfact <- runMFACT.C(temp.mfact, fileName, countryVector, yearVector, industryVector, productVector, colour_industries, colour_products)
  return(res.mfact)
}

#-------- input for 10 countries, including Japan, for 1970-2006
temp.mfact.AUS <- dfInput.C(dsAgg, countryVector="AUS", varHere="I", yearVector37, industryVector12, productVector8, share=FALSE)
#temp.mfact.AUT<- dfInput.C(dsAgg, countryVector="AUT", varHere="I", yearVector37, industryVector12, productVector8, share=FALSE)
temp.mfact.DNK.0 <- dfInput.C(dsAgg, countryVector="DNK", varHere="I", yearVector37, industryVector12, productVector8, share=FALSE)
temp.mfact.DNK <- temp.mfact.DNK.0
temp.mfact.DNK[temp.mfact.DNK<0] <- NA
temp.mfact.ESP <- dfInput.C(dsAgg, countryVector="ESP", varHere="I", yearVector37, industryVector12, productVector8, share=FALSE)
temp.mfact.FIN <- dfInput.C(dsAgg, countryVector="FIN", varHere="I", yearVector37, industryVector12, productVector8, share=FALSE)
temp.mfact.FRA <- dfInput.C(dsAgg, countryVector="FRA", varHere="I", yearVector37, industryVector12, productVector8, share=FALSE)
temp.mfact.ITA.0 <- dfInput.C(dsAgg, countryVector="ITA", varHere="I", yearVector37, industryVector12, productVector8, share=FALSE)
temp.mfact.ITA <- temp.mfact.ITA.0
for(colHere in 0:(as.integer(dim(temp.mfact.ITA)[2]/8)-1))
{
  temp.mfact.ITA["70",6+colHere*8] <- temp.mfact.ITA["71t74",6+colHere*8] + temp.mfact.ITA["70",6+colHere*8]
  temp.mfact.ITA["71t74",6+colHere*8] <- 0
}
temp.mfact.JPN <- dfInput.C(dsAgg, countryVector="JPN", varHere="I", yearVector37, industryVector12, productVector8, share=FALSE)
temp.mfact.NLD <- dfInput.C(dsAgg, countryVector="NLD", varHere="I", yearVector37, industryVector12, productVector8, share=FALSE)
temp.mfact.UK <- dfInput.C(dsAgg, countryVector="UK", varHere="I", yearVector37, industryVector12, productVector8, share=FALSE)
temp.mfact.USA <- dfInput.C(dsAgg, countryVector="USA", varHere="I", yearVector37, industryVector12, productVector8, share=FALSE)

countryVector <- c("AUS","DNK","ESP","FIN","FRA","ITA","JPN","NLD","UK","USA")
temp.mfact <- bind_cols(temp.mfact.AUS,temp.mfact.DNK,temp.mfact.ESP,temp.mfact.FIN,temp.mfact.FRA,temp.mfact.ITA,
                        temp.mfact.JPN,temp.mfact.NLD,temp.mfact.UK,temp.mfact.USA)

rownames(temp.mfact) <- rownames(temp.mfact.AUS)

#---------- From temp/mfact, set all negative values to zero.

temp.mfact[temp.mfact<0] <- 0
# Verify : sum(is.na(temp.mfact))
# Verify : sum(temp.mfact[temp.mfact<0])
# fileName <- "10countries_negTo0_I"
# name <- fileName

#-----------------------------------------------------------------------------------------
#-------- input for 10 countries, including Japan, for 1970-2006, for 7 products
temp.mfact.AUS7 <- dfInput.C(dsAgg, countryVector="AUS", varHere="I", yearVector37, industryVector12, productVector7, share=FALSE)
#temp.mfact.AUT<- dfInput.C(dsAgg, countryVector="AUT", varHere="I", yearVector37, industryVector12, productVector7, share=FALSE)
temp.mfact.DNK7.0 <- dfInput.C(dsAgg, countryVector="DNK", varHere="I", yearVector37, industryVector12, productVector7, share=FALSE)
temp.mfact.DNK7 <- temp.mfact.DNK7.0
#temp.mfact.DNK7[temp.mfact.DNK7<0] <- NA
temp.mfact.ESP7 <- dfInput.C(dsAgg, countryVector="ESP", varHere="I", yearVector37, industryVector12, productVector7, share=FALSE)
temp.mfact.FIN7 <- dfInput.C(dsAgg, countryVector="FIN", varHere="I", yearVector37, industryVector12, productVector7, share=FALSE)
temp.mfact.FRA7 <- dfInput.C(dsAgg, countryVector="FRA", varHere="I", yearVector37, industryVector12, productVector7, share=FALSE)
temp.mfact.ITA7.0 <- dfInput.C(dsAgg, countryVector="ITA", varHere="I", yearVector37, industryVector12, productVector7, share=FALSE)
temp.mfact.ITA7 <- temp.mfact.ITA7.0
for(colHere in 0:(as.integer(dim(temp.mfact.ITA7)[2]/7)-1))
{
  temp.mfact.ITA7["70",5+colHere*7] <- temp.mfact.ITA7["71t74",5+colHere*7] + temp.mfact.ITA7["70",5+colHere*7]
  temp.mfact.ITA7["71t74",5+colHere*7] <- 0
}
temp.mfact.JPN7 <- dfInput.C(dsAgg, countryVector="JPN", varHere="I", yearVector37, industryVector12, productVector7, share=FALSE)
temp.mfact.NLD7 <- dfInput.C(dsAgg, countryVector="NLD", varHere="I", yearVector37, industryVector12, productVector7, share=FALSE)
temp.mfact.UK7 <- dfInput.C(dsAgg, countryVector="UK", varHere="I", yearVector37, industryVector12, productVector7, share=FALSE)
temp.mfact.USA7 <- dfInput.C(dsAgg, countryVector="USA", varHere="I", yearVector37, industryVector12, productVector7, share=FALSE)

countryVector <- c("AUS","DNK","ESP","FIN","FRA","ITA","JPN","NLD","UK","USA")
temp.mfact7 <- bind_cols(temp.mfact.AUS7,temp.mfact.DNK7,temp.mfact.ESP7,temp.mfact.FIN7,temp.mfact.FRA7,temp.mfact.ITA7,
                        temp.mfact.JPN7,temp.mfact.NLD7,temp.mfact.UK7,temp.mfact.USA7)
rownames(temp.mfact7) <- rownames(temp.mfact.AUS7)





#-------------------------------
# Input for 1970-2007 for n countries for which data are available over this period. Other countries smaller datarange :
# JPN data 1970 - 2006, 
# AUT data 1976 - 2007,

temp.mfact.AUS <- dfInput.C(dsAgg, countryVector="AUS", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
#temp.mfact.AUT<- dfInput.C(dsAgg, countryVector="AUT", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.DNK.0 <- dfInput.C(dsAgg, countryVector="DNK", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.DNK <- temp.mfact.DNK.0
temp.mfact.DNK[temp.mfact.DNK<0] <- NA
temp.mfact.ESP <- dfInput.C(dsAgg, countryVector="ESP", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.FIN <- dfInput.C(dsAgg, countryVector="FIN", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.FRA <- dfInput.C(dsAgg, countryVector="FRA", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.ITA.0 <- dfInput.C(dsAgg, countryVector="ITA", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.ITA <- temp.mfact.ITA.0
for(colHere in 0:(as.integer(dim(temp.mfact.ITA)[2]/8)-1))
{
  temp.mfact.ITA["70",6+colHere*8] <- temp.mfact.ITA["71t74",6+colHere*8] + temp.mfact.ITA["70",6+colHere*8]
  temp.mfact.ITA["71t74",6+colHere*8] <- 0
}
#temp.mfact.JPN <- dfInput.C(dsAgg, countryVector="JPN", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.NLD <- dfInput.C(dsAgg, countryVector="NLD", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.UK <- dfInput.C(dsAgg, countryVector="UK", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)
temp.mfact.USA <- dfInput.C(dsAgg, countryVector="USA", varHere="I", yearVector, industryVector12, productVector8, share=FALSE)

countryVector <- c("AUS","DNK","ESP","FIN","FRA","ITA","NLD","UK","USA")
temp.mfact <- bind_cols(temp.mfact.AUS,temp.mfact.DNK,temp.mfact.ESP,temp.mfact.FIN,temp.mfact.FRA,temp.mfact.ITA,
                        temp.mfact.NLD,temp.mfact.UK,temp.mfact.USA)

rownames(temp.mfact) <- rownames(temp.mfact.AUS)
