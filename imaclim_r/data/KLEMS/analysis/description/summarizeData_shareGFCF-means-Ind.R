// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

library(fBasics)

folder <- paste0(SUMMARIZE,"/summarizeData/industries/means/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

#---------------------------------------------------------------------------------
#create variable "trend" which is the slope of the regression per country, per industry of investment in asset over time
industryVector <- industryVector12
industries <- factor(c(industryVector), levels=c(industryVector))

productsVector <- c("NonICT","ICT","Con","Mach","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")
#productsL <- factor(c(productsVector,"Con","Mach"), levels=c(productsVector,"Con","Mach"))

init3.mean <- data.frame(matrix(rep(0,length(countries)*length(industries)),nrow=length(countries),ncol=length(industries), byrow=TRUE))
colnames(init3.mean) <- industries
rownames(init3.mean) <- countries
end3.mean            <- init3.mean
all.mean             <- init3.mean

for (productHere in "GFCF")
{
  temp00 <- dsAgg %>%  dplyr::filter(var=="I", product==productHere, industry %in% c(industryVector,"TOT"))
  
  for (countryHere in countries)
  #for (countryHere in "USA")
  {
    temp0 <- temp00 %>%  dplyr::filter(country==countryHere)# %>% 
                         #spread(industry,value) %>%
                         #gather(product, value, -year, -country, -var, -industry,factor_key = TRUE) 
    for(industryHere in industries) 
    {  
      temp <- temp0 %>% dplyr::filter(industry %in% c(industryHere,"TOT")) %>% 
                        spread(industry,value) %>% 
                        mutate_each(funs(./TOT), -country,-var,-year,-product,-TOT) %>%
                        select(-c(TOT))
      
      if (sum(is.na(temp[,colnames(temp)==industryHere])) < dim(temp)[1]-2)
      {
        colnames(temp)[ncol(temp)] <- "share"
        a=1
        b=dim(temp)[1]
        while(is.na(temp[a,"share"])) { a <- a+1 }
        
        while(is.na(temp[b,"share"])) { b <- b-1 }
        
        init3.mean[countryHere,industryHere] <- mean(temp[a:(a+2),5])*100
        end3.mean[countryHere,industryHere]  <- mean(temp[(b-2):b,5])*100
        all.mean[countryHere,industryHere]   <- data.frame(t(basicStats(temp[5]))) %>% select(c(Mean))*100
      }
      else
      { 
        init3.mean[countryHere,industryHere] <- NA
        end3.mean[countryHere,industryHere]  <- NA
        all.mean[countryHere,industryHere]   <- NA
      }
    }  
  }
  init3.mean <- init3.mean[,c("AtB","C","D","E","F","GtH","60t63","64","J","70","71t74","LtQ")]
  end3.mean  <- end3.mean[,c("AtB","C","D","E","F","GtH","60t63","64","J","70","71t74","LtQ")]
  all.mean  <- all.mean[,c("AtB","C","D","E","F","GtH","60t63","64","J","70","71t74","LtQ")]
  
  init3.mean <- init3.mean[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
  end3.mean <- end3.mean[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
  all.mean <- all.mean[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
  
  print(xtable(all.mean, caption=paste("Shares per industry in total investment in ",productHere, ", per country, average 1970 - 2010.",sep=""), label=paste("Summary","means","shareGFCF","percountry",productHere,sep="_") ,type="latex", digits=2,  align="r|rrrrrrrrrrrr"), size="\\scriptsize", hline.after = c(-1,0,11,15), file=paste(paste("Summary","means","shareTOT","percountry",productHere,sep="_"),".tex",sep=""))
  print(xtable(init3.mean, caption=paste("Shares per industry in total investment in ",productHere, ", per country, average first 3 years.", sep=""), label=paste("Summary","initmeans","shareGFCF","percountry",productHere,sep="_"),type="latex",digits=2, align="r|rrrrrrrrrrrr"), size="\\scriptsize",hline.after = c(-1,0,11,15), file=paste(paste("Summary","initmeans","shareTOT","percountry",productHere,sep="_"),".tex",sep=""))
  print(xtable(end3.mean, caption=paste("Shares per industry in total investment in ", productHere, ", per country, average last 3 years.", sep=""), label=paste("Summary","endmeans","shareGFCF","percountry",productHere,sep="_"),type="latex",digits=2, align="r|rrrrrrrrrrrr"), size="\\scriptsize", hline.after = c(-1,0,11,15), file=paste(paste("Summary","endmeans","shareTOT","percountry",productHere,sep="_"),".tex",sep=""))
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