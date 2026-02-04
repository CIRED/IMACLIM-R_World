// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

library(fBasics)

folder <- paste0(SUMMARIZE,"/summarizeData/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

#---------------------------------------------------------------------------------
#create variable "trend" which is the slope of the regression per country, per industry of investment in asset over time
productsL <- factor(c(as.character(products),"Con"), levels=c(levels(products),"Con"))

trends <- data.frame(matrix(rep(0,length(countries)*length(productsL)),nrow=length(countries),ncol=length(productsL), byrow=TRUE))
colnames(trends) <- productsL
rownames(trends) <- countries
pvalues          <- trends

trends.all       <- data.frame(matrix(rep(0,length(productsL)),1,ncol=length(productsL), byrow=TRUE))
colnames(trends.all) <- productsL
pvalues.all      <- trends.all

for (countryHere in countries)
{
  for (industryHere in c("TOT"))
  {
    temp0 <- ds %>% dplyr::filter(var=="I", industry=="TOT", country==countryHere) %>% 
                    spread(product,value) %>%
                    mutate(Con = RStruc + OCon) %>% 
                    gather(product, value, -year, -country, -var, -industry,factor_key = TRUE) 
    
    for(productHere in productsL) 
    {  
      temp1 <- ds %>% dplyr::filter(var=="VA", industry=="TOT" , country %in% as.vector(countries), country==countryHere) %>% spread(var,value) %>% select(-c(product))
      temp2 <- temp0 %>% dplyr::filter(product==productHere) %>% spread(var,value)
      temp  <- left_join(temp1,temp2, by=c("country","industry","year")) %>% mutate(I_VA=I/VA)
      
      if (sum(is.na(temp$I_VA)) < dim(temp)[1]-2)
      {
        temp.lm <- lm(I_VA ~ years, data=temp)
        trends[countryHere,productHere] <- coefficients(temp.lm)[2]
        pvalues[countryHere,productHere] <- summary(temp.lm)$coefficients[8]
      }
    }
  }  
} 
pvalues.cat <- pvalues
pvalues.cat$country=rownames(pvalues)
pvalues.cat <- pvalues.cat %>% gather(product, value, -country)

pvalues.cat$value[pvalues.cat$value >= 0 & pvalues.cat$value <= 0.001] <- "***"
pvalues.cat$value[pvalues.cat$value > 0.001 & pvalues.cat$value <= 0.01] <- "**"
pvalues.cat$value[pvalues.cat$value > 0.01 & pvalues.cat$value <= 0.05] <- "*"
pvalues.cat$value[pvalues.cat$value > 0.05 & pvalues.cat$value <= 0.1] <- "."
pvalues.cat$value[pvalues.cat$value > 0.1 & pvalues.cat$value <= 1] <- "_"

pvalues.cat <- pvalues.cat %>% spread(product,value) 
rownames(pvalues.cat) <- pvalues.cat$country

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
    
    print(xtable(temp.stats1,caption=paste(productHere, ", I / VA, 1970 - 2010, all industries", sep=""),label=paste("table:Summary",productHere,industryHere,sep="_"),digits=temp.stats1.digits),type="latex",size="\\scriptsize",file=paste(paste("Summary",productHere,industryHere,sep="_"),".tex",sep=""))
    print(xtable(temp.stats2,caption=paste(productHere, ", I / VA, 1970 - 2010, all industries,", sep=""),label=paste("table:SummaryT",productHere,industryHere,sep="_"),digits=temp.stats2.digits),type="latex",size="\\scriptsize",file=paste(paste("SummaryT",productHere,industryHere,sep="_"),".tex",sep=""))
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