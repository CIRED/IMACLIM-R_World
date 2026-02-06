# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

library(fBasics)

folder <- paste0(SUMMARIZE,"/summarizeData/products/gr/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

#---------------------------------------------------------------------------------
#create variable "trend" which is the slope of the regression per country, per industry of investment in asset over time
productsL <- factor(c(as.character(products),"Con","Mach"), levels=c(levels(products),"Con","Mach"))

gRates.mean <- data.frame(matrix(rep(0,length(countries)*length(productsL)),nrow=length(countries),ncol=length(productsL), byrow=TRUE))
colnames(gRates.mean) <- productsL
rownames(gRates.mean) <- countries
gRates.sd        <- gRates.mean
gRates.Nobs      <- gRates.mean

#gRates <- perInd_prodGrowthrates(as.vector(productsL))
gRates <- LiesGR2 %>% select(-I_VA)

for (industryHere in c(industryVector12,"TOT"))
{
  temp00 <- gRates %>% dplyr::filter(industry==industryHere)
  
  for (countryHere in countries)
  {
    temp0 <- temp00 %>% dplyr::filter(country==countryHere)
    
    for(productHere in productsL) 
    {  
      temp <- temp0 %>% dplyr::filter(product==productHere)
      
      if (sum(is.na(temp$g_I_VA)) < dim(temp)[1]-2)
      {
        a <- data.frame(t(basicStats(temp[-c(1,2,3,4)]))) %>% select(c(nobs,NAs,Minimum,Maximum,Mean,Stdev,Skewness,Kurtosis))
        gRates.mean[countryHere,productHere]  <- a$Mean *100
        gRates.sd[countryHere,productHere]    <- a$Stdev *100
        gRates.Nobs[countryHere,productHere]  <- a$nobs - a$NAs
      }
    }
  }  

gRates.mean <- gRates.mean[,c("GFCF","NonICT","ICT","Con","Mach","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")]
gRates.sd   <- gRates.sd[,c("GFCF","NonICT","ICT","Con","Mach","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")]
gRates.Nobs <- gRates.Nobs[,c("GFCF","NonICT","ICT","Con","Mach","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")]

gRates.mean <- gRates.mean[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
gRates.sd   <- gRates.sd[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
gRates.Nobs <- gRates.Nobs[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]

print(xtable(gRates.mean, caption=paste("Average growth rate I/VA per country and asset, 1971-2010, ", industryHere, sep=""), label=paste("gR","I-VA","percountry",industryHere,"mean",sep="_"),align="r|r|rr|rr|rrrrrrrr"),type="latex",size="\\scriptsize",file=paste(paste("gR","I-VA","percountry",industryHere,"mean",sep="_"),"tex",sep="."))
print(xtable(gRates.sd, caption=paste("Standard deviation growth rate I/VA per country and asset, 1971-2010, ", industryHere, sep=""), label=paste("gR","I-VA","percountry",industryHere,"sd",sep="_"), align="r|r|rr|rr|rrrrrrrr"),type="latex",size="\\scriptsize",file=paste(paste("gR","I-VA","percountry",industryHere,"sd",sep="_"),"tex",sep="."))
print(xtable(gRates.Nobs, caption=paste("Number of observations growth rate I/VA per country and asset, 1971-2010, ", industryHere, sep=""), label=paste("gR","I-VA","percountry",industryHere,"Nobs",sep="_"), align="r|r|rr|rr|rrrrrrrr"),type="latex",size="\\scriptsize",file=paste(paste("gR","I-VA","percountry",industryHere,"Nobs",sep="_"),"tex",sep="."))
} 

#---------------------------------------------------------------------------------

for (industryHere in c("TOT"))
  {
  temp0 <- ds %>% dplyr::filter(var=="I", industry=="TOT") %>% 
           spread(product,value) %>%
           mutate(Con = RStruc + OCon) %>% 
           gather(product, value, -year, -country, -var, -industry, factor_key = TRUE) 
  
  for(productHere in productsL) 
    {

    temp1 <- ds    %>% dplyr::filter(var=="VA", industry=="TOT" , country %in% as.vector(countries)) %>% spread(var,value) %>% select(-c(product))
    temp2 <- temp0 %>% dplyr::filter(product==productHere) %>% spread(var,value)
    countries.ds <- unique(temp1$country)
    temp.all          <- left_join(temp1,temp2, by=c("country","industry","year")) %>% 
                          mutate(I_VA=I/VA) %>% select(c(country, year, I_VA)) 
    temp.country      <- temp.all %>% spread(country, I_VA)
    temp.year         <- temp.all %>% spread(year, I_VA)
    
    if (sum(is.na(temp.all$I_VA)) < dim(temp.all)[1]-2)
    {
      temp.all.lm <- lm(I_VA ~ year, data=temp.all)
      trends.all[1,productHere] <- coefficients(temp.all.lm)[2]
      pvalues.all[1,productHere] <- summary(temp.all.lm)$coefficients[8]
    }
    
    temp.all.stats      <- data.frame(t(basicStats(temp.all[-c(1,2)]))) %>% select(c(nobs,NAs,Minimum,Maximum,Mean,Stdev,Skewness,Kurtosis))
    temp.country.stats  <- data.frame(t(basicStats(temp.country[-1]))) %>% select(c(nobs,NAs,Minimum,Maximum,Mean,Stdev,Skewness,Kurtosis))
    temp.year.stats     <- data.frame(t(basicStats(temp.year[-1]))) %>% select(c(nobs,NAs,Minimum,Maximum,Mean,Stdev,Skewness,Kurtosis))
    
    temp.country.stats2 <- temp.country.stats
    
    trends  <- trends[match(countries.ds, rownames(trends)),]
    pvalues.cat <- pvalues.cat[match(countries.ds, rownames(pvalues.cat)),]
    trends0 <- do.call(rbind, unname(list(trends.all, pvalues.all)))
    rownames(trends0) <- c("trend","t.pvalue")

    temp.country.stats2$trend        <- trends[productHere]
    temp.country.stats2$t.pvalue <- pvalues.cat[productHere]
    
    temp.stats1 <- do.call(rbind, unname(list(temp.country.stats, temp.all.stats, temp.year.stats)))
    temp.stats2 <- do.call(rbind, unname(list(temp.country.stats2)))
    
    a1 = c(rep(0,3),rep(3,6))
    a2 = c(rep(0,3),rep(3,6),5,7)
    temp.stats1.digits <- matrix(rep(a1,57),nrow=57,ncol=9, byrow=TRUE) 
    temp.stats2.digits <- matrix(rep(a2,15),nrow=15,ncol=11, byrow=TRUE) 
    
    print(xtable(temp.stats1, caption=paste(productHere, ", I / VA, 1970 - 2010, all industries", sep=""),label=paste("table:Summary",productHere,industryHere,sep="_"),digits=temp.stats1.digits),type="latex",size="\\scriptsize",file=paste(paste("Summary",productHere,industryHere,sep="_"),".tex",sep=""))
    print(xtable(temp.stats2, caption=paste(productHere, ", I / VA, 1970 - 2010, all industries,", sep=""),label=paste("table:SummaryT",productHere,industryHere,sep="_"),digits=temp.stats2.digits),type="latex",size="\\scriptsize",file=paste(paste("SummaryT",productHere,industryHere,sep="_"),".tex",sep=""))
    print(xtable(trends0,caption=paste("Trend I / VA, over all countries, 1970 - 2010, total industry,", sep=""),label=paste("table:SummaryT",industryHere,sep="_"),digits=5),type="latex",size="\\scriptsize",file=paste(paste("SummaryT",industryHere,sep="_"),".tex",sep=""))

  }
  trends0 <- do.call(rbind, unname(list(trends.all, pvalues.all)))
  rownames(trends0) <- c("trend","t.pvalue")
  trends0 <- trends0[,c("GFCF","NonICT","ICT","Con","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")]
  trends0 <- t(trends0)
  print(xtable(trends0,caption=paste("Trend I / VA, over all countries, 1970 - 2010, total industry", sep=""),digits=5),type="latex",size="\\scriptsize",file=paste(paste("Summary","SLR",industryHere,sep="_"),".tex",sep=""))
  
} 


detach("package:fBasics", unload=TRUE)
detach("package:timeSeries", unload=TRUE)