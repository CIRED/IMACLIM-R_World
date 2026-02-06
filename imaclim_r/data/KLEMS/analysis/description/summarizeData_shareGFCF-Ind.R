# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

library(fBasics)

folder <- paste0(SUMMARIZE,"/summarizeData/Industries/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

#---------------------------------------------------------------------------------
#create variable "trend" which is the slope of the regression per country, per industry of investment in asset over time
industryVector <- industryVector12
industries <- factor(c(industryVector), levels=c(industryVector))

trends <- data.frame(matrix(rep(0,length(countries)*length(industries)),nrow=length(countries),ncol=length(industries), byrow=TRUE))
colnames(trends) <- industries
rownames(trends) <- countries
pvalues          <- trends

trends.all       <- data.frame(matrix(rep(0,length(industries)),1,ncol=length(industries), byrow=TRUE))
colnames(trends.all) <- industries
pvalues.all      <- trends.all

for (countryHere in countries)
#for (countryHere in "USA")
{
  for (productHere in c("GFCF"))
  {
    temp0 <- dsAgg %>%  dplyr::filter(var=="I", product==productHere, country==countryHere)# %>% 
                        #spread(industry,value) %>%
                        #gather(product, value, -year, -country, -var, -industry,factor_key = TRUE) 
    
    for(industryHere in industries) 
    {  
      #temp1 <- ds %>% dplyr::filter(var=="VA", industry=="TOT" , country %in% as.vector(countries), country==countryHere) %>% spread(var,value) %>% select(-c(product))
      temp <- temp0 %>%  dplyr::filter(industry %in% c(industryHere,"TOT")) %>% 
                          spread(industry,value) %>% 
                          mutate_each(funs(./TOT), -country,-var,-year,-product,-TOT) %>%
                          select(-c(TOT))
                                                                   
      
      if (sum(is.na(temp[,colnames(temp)==industryHere])) < dim(temp)[1]-2)
      {
        colnames(temp)[ncol(temp)] <- "share"
        temp.lm <- lm(share ~ years, data=temp)
        trends[countryHere,industryHere] <- coefficients(temp.lm)[2]
        pvalues[countryHere,industryHere] <- summary(temp.lm)$coefficients[8]
      }
    }
  }  
}
trends  <- trends[,c("AtB","C","D","E","F","GtH","60t63","64","J","70","71t74","LtQ")]
pvalues <- pvalues[,c("AtB","C","D","E","F","GtH","60t63","64","J","70","71t74","LtQ")]

pvalues.cat <- pvalues
pvalues.cat$country=rownames(pvalues)
pvalues.cat <- pvalues.cat %>% gather(industry, value, -country)

pvalues.cat$value[pvalues.cat$value >= 0 & pvalues.cat$value <= 0.001] <- "***"
pvalues.cat$value[pvalues.cat$value > 0.001 & pvalues.cat$value <= 0.01] <- "**"
pvalues.cat$value[pvalues.cat$value > 0.01 & pvalues.cat$value <= 0.05] <- "*"
pvalues.cat$value[pvalues.cat$value > 0.05 & pvalues.cat$value <= 0.1] <- "."
pvalues.cat$value[pvalues.cat$value > 0.1 & pvalues.cat$value <= 1] <- "_"

pvalues.cat <- pvalues.cat %>% spread(industry,value) 
rownames(pvalues.cat) <- pvalues.cat$country
pvalues.cat <- pvalues.cat %>% select(-country)

trends.final2 <- trends
trends.final3 <- trends
trends.final2[trends< 0] <- "$\\downarrow^{"
trends.final2[trends > 0] <- "$\\uparrow^{"
trends.final3 <- "}$"

trends.final <- as.data.frame(matrix(paste0(as.matrix(trends.final2),as.matrix(pvalues.cat),as.matrix(trends.final3)),nrow=nrow(as.matrix(trends.final2)), dimnames=dimnames(as.matrix(trends.final2))))

print(xtable(trends.final,caption=paste("Trend industries' investment share of total GFCF per country, 1970 - 2010, all assets", sep="")),type="latex",size="\\scriptsize",file=paste(paste("Summary","SLR","industries-shareGFCF","percountry",productHere,sep="_"),".tex",sep=""))

#---------------------------------------------------------------------------------

for (productHere in c("GFCF"))
  {
  temp0 <- dsAgg %>% dplyr::filter(var=="I", product==productHere) #%>% 
           #spread(industry,value) %>%
           #mutate(Con = RStruc + OCon) %>% 
           #gather(product, value, -year, -country, -var, -industry, factor_key = TRUE) 
  
  for(industryHere in industries) 
    {
    temp.all <- temp0 %>%  dplyr::filter(industry %in% c(industryHere,"TOT")) %>% 
                        spread(industry,value) %>% 
                        mutate_each(funs(./TOT), -country,-var,-year,-industry,-TOT) %>%
                        select(-c(TOT))
    
    countries.ds <- unique(temp.all$country)
    colnames(temp.all)[ncol(temp.all)] <- "share"
    temp.all <- temp.all %>% select(c(country, year, share)) 
    
    temp.country      <- temp.all %>% spread(country, share)
    temp.year         <- temp.all %>% spread(year, share)
    
    if (sum(is.na(temp.all$share)) < dim(temp.all)[1]-2)
    {
      temp.all.lm <- lm(share ~ year, data=temp.all)
      trends.all[1,industryHere] <- coefficients(temp.all.lm)[2]
      pvalues.all[1,industryHere] <- summary(temp.all.lm)$coefficients[8]
    }
    
    temp.all.stats      <- data.frame(t(basicStats(temp.all[-c(1,2)]))) %>% select(c(nobs,NAs,Minimum,Maximum,Mean,Stdev))#,Skewness,Kurtosis))
    temp.country.stats  <- data.frame(t(basicStats(temp.country[-1]))) %>% select(c(nobs,NAs,Minimum,Maximum,Mean,Stdev))#,Skewness,Kurtosis))
    temp.year.stats     <- data.frame(t(basicStats(temp.year[-1]))) %>% select(c(nobs,NAs,Minimum,Maximum,Mean,Stdev))#,Skewness,Kurtosis))
    
    temp.country.stats2 <- temp.country.stats
    
    trends  <- trends[match(countries.ds, rownames(trends)),]
    pvalues.cat <- pvalues.cat[match(countries.ds, rownames(pvalues.cat)),]
    trends0 <- do.call(rbind, unname(list(trends.all, pvalues.all)))
    rownames(trends0) <- c("trend","t.pvalue")

    temp.country.stats2$trend        <- trends[productHere]
    temp.country.stats2$t.pvalue <- pvalues.cat[productHere]
    
    temp.stats1 <- do.call(rbind, unname(list(temp.country.stats, temp.all.stats, temp.year.stats)))
    temp.stats2 <- do.call(rbind, unname(list(temp.country.stats2)))
    
    a1 = c(rep(0,3),rep(3,4))
    a2 = c(rep(0,3),rep(3,4),5,7)
    temp.stats1.digits <- matrix(rep(a1,57),nrow=57,ncol=7, byrow=TRUE) 
    temp.stats2.digits <- matrix(rep(a2,15),nrow=15,ncol=9, byrow=TRUE) 
    
    print(xtable(temp.stats1,caption=paste(industryHere, ", share GFCF, 1970 - 2010, all industries", sep=""),label=paste("table:Summary",productHere,industryHere,sep="_"),digits=temp.stats1.digits),type="latex",size="\\scriptsize",file=paste(paste("Summary","industries-shareGFCF",productHere,industryHere,sep="_"),".tex",sep=""))
    print(xtable(temp.stats2,caption=paste(industryHere, ", share GFCF, 1970 - 2010, all industries,", sep=""),label=paste("table:SummaryT",productHere,industryHere,sep="_"),digits=temp.stats2.digits),type="latex",size="\\scriptsize",file=paste(paste("SummaryT","industries-shareGFCF",productHere,industryHere,sep="_"),".tex",sep=""))
    print(xtable(trends0,caption=paste("Trend share GFCF, over all countries, 1970 - 2010, total industry,", sep=""),label=paste("table:SummaryT",productHere,sep="_"),digits=5),type="latex",size="\\scriptsize",file=paste(paste("SummaryT","industries-shareGFCF",productHere,sep="_"),".tex",sep=""))

  }
  trends0 <- do.call(rbind, unname(list(trends.all, pvalues.all)))
  rownames(trends0) <- c("trend","t.pvalue")
  trends0 <- trends0[,c("AtB","C","D","E","F","GtH","60t63","64","J","70","71t74","LtQ")]
  trends0 <- t(trends0)
  print(xtable(trends0,caption=paste("Trend industries' investment share of total GFCF, over all countries, 1970 - 2010, all assets", sep=""),digits=5),type="latex",size="\\scriptsize",file=paste(paste("Summary","SLR","industries-shareGFCF",industryHere,sep="_"),".tex",sep=""))
  
} 


detach("package:fBasics", unload=TRUE)
detach("package:timeSeries", unload=TRUE)