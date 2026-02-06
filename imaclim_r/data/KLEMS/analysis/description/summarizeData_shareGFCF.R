# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

library(fBasics)

folder <- paste0(SUMMARIZE,"/summarizeData/means/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

#---------------------------------------------------------------------------------
#create variable "trend" which is the slope of the regression per country, per industry of investment in asset over time
productsVector <- as.character(products)[!products=="GFCF"]
productsL <- factor(c(productsVector,"Con","Mach"), levels=c(productsVector,"Con","Mach"))

init3.mean <- data.frame(matrix(rep(0,length(countries)*length(productsL)),nrow=length(countries),ncol=length(productsL), byrow=TRUE))
colnames(init3.mean) <- productsL
rownames(init3.mean) <- countries
end3.mean            <- init3.mean
all.mean             <- init3.mean

for (industryHere in c(industryVector12,"TOT"))
#for (industryHere in c("D"))
{
  temp00 <- dsAgg %>% dplyr::filter(var=="I", industry==industryHere)
  
  for (countryHere in countries)
    {
    temp0 <- temp00 %>% dplyr::filter(country==countryHere) %>% 
                        spread(product,value) %>%
                        mutate(Con = RStruc + OCon, Mach = OCon + TraEq) %>% 
                        gather(product, value, -year, -country, -var, -industry,factor_key = TRUE) 
    
    for(productHere in productsL) 
    {  
      temp <- temp0 %>%  dplyr::filter(product %in% c(productHere,"GFCF")) %>% 
                          spread(product,value) %>% 
                          mutate_each(funs(./GFCF), -country,-var,-year,-industry,-GFCF) %>%
                          select(-c(GFCF))
                                                                  
      if (sum(is.na(temp[,colnames(temp)==productHere])) < dim(temp)[1]-2)
      {
        colnames(temp)[ncol(temp)] <- "share"
        a=1
        b=dim(temp)[1]
        while(is.na(temp[a,"share"])) { a <- a+1 }

        while(is.na(temp[b,"share"])) { b <- b-1 }
        
        init3.mean[countryHere,productHere] <- mean(temp[a:(a+2),5])*100
        end3.mean[countryHere,productHere]  <- mean(temp[(b-2):b,5])*100
        all.mean[countryHere,productHere]   <- data.frame(t(basicStats(temp[5]))) %>% select(c(Mean))*100
      } 
      else
        { 
          init3.mean[countryHere,productHere] <- NA
          end3.mean[countryHere,productHere]  <- NA
          all.mean[countryHere,productHere]   <- NA
        }
    }
  }
  init3.mean <- init3.mean[,c("NonICT","ICT","Con","Mach","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")]
  end3.mean  <- end3.mean[,c("NonICT","ICT","Con","Mach","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")]
  all.mean  <- all.mean[,c("NonICT","ICT","Con","Mach","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")]
  
  init3.mean <- init3.mean[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
  end3.mean <- end3.mean[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
  all.mean <- all.mean[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
  
  print(xtable(all.mean, caption=paste("Shares per product in industries' GFCF, per country, average 1970 - 2010, ", industryHere,".",sep=""), label=paste("Summary","means","shareGFCF","percountry",industryHere,sep="_") ,type="latex", digits=2,  align="r|rr|rr|rrrrrrrr"), size="\\scriptsize", hline.after = c(-1,0,11,15), file=paste(paste("Summary","means","shareGFCF","percountry",industryHere,sep="_"),".tex",sep=""))
  print(xtable(init3.mean, caption=paste("Shares per product in industries' GFCF, per country, average first 3 years, ", industryHere,".", sep=""), label=paste("Summary","initmeans","shareGFCF","percountry",industryHere,sep="_"),type="latex",digits=2, align="r|rr|rr|rrrrrrrr"), size="\\scriptsize",hline.after = c(-1,0,11,15), file=paste(paste("Summary","initmeans","shareGFCF","percountry",industryHere,sep="_"),".tex",sep=""))
  print(xtable(end3.mean, caption=paste("Shares per product in industries' GFCF, per country, average last 3 years, ", industryHere,".", sep=""), label=paste("Summary","endmeans","shareGFCF","percountry",industryHere,sep="_"),type="latex",digits=2, align="r|rr|rr|rrrrrrrr"), size="\\scriptsize", hline.after = c(-1,0,11,15), file=paste(paste("Summary","endmeans","shareGFCF","percountry",industryHere,sep="_"),".tex",sep=""))
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
pvalues.cat <- pvalues.cat %>% select(-country)

trends.final2 <- trends
trends.final3 <- trends
trends.final2[trends< 0] <- "$\\downarrow^{"
trends.final2[trends > 0] <- "$\\uparrow^{"
trends.final3 <- "}$"

trends.final <- as.data.frame(matrix(paste0(as.matrix(trends.final2),as.matrix(pvalues.cat),as.matrix(trends.final3)),nrow=nrow(as.matrix(trends.final2)), dimnames=dimnames(as.matrix(trends.final2))))

print(xtable(trends.final,caption=paste("Trend share GFCF per country, 1970 - 2010, total industry", sep="")),type="latex",size="\\scriptsize",file=paste(paste("Summary","SLR","shareGFCF","percountry",industryHere,sep="_"),".tex",sep=""))

#---------------------------------------------------------------------------------

for (industryHere in c("TOT"))
  {
  temp0 <- dsAgg %>% dplyr::filter(var=="I", industry==industryHere) %>% 
           spread(product,value) %>%
           mutate(Con = RStruc + OCon, Mach = TraEq + OMach) %>% 
           gather(product, value, -year, -country, -var, -industry, factor_key = TRUE) 
  
  for(productHere in productsL) 
    {
    temp.all <- temp0 %>%  dplyr::filter(product %in% c(productHere,"GFCF")) %>% 
                        spread(product,value) %>% 
                        mutate_each(funs(./GFCF), -country,-var,-year,-industry,-GFCF) %>%
                        select(-c(GFCF))
    
    countries.ds <- unique(temp.all$country)
    colnames(temp.all)[ncol(temp.all)] <- "share"
    temp.all <- temp.all %>% select(c(country, year, share)) 
    
    temp.country      <- temp.all %>% spread(country, share)
    temp.year         <- temp.all %>% spread(year, share)
    
    if (sum(is.na(temp.all$share)) < dim(temp.all)[1]-2)
    {
      temp.all.lm <- lm(share ~ year, data=temp.all)
      trends.all[1,productHere] <- coefficients(temp.all.lm)[2]
      pvalues.all[1,productHere] <- summary(temp.all.lm)$coefficients[8]
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
    
    print(xtable(temp.stats1,caption=paste(productHere, ", share GFCF, 1970 - 2010, all industries", sep=""),label=paste("table:Summary",productHere,industryHere,sep="_"),digits=temp.stats1.digits),type="latex",size="\\scriptsize",file=paste(paste("Summary","shareGFCF",productHere,industryHere,sep="_"),".tex",sep=""))
    print(xtable(temp.stats2,caption=paste(productHere, ", share GFCF, 1970 - 2010, all industries,", sep=""),label=paste("table:SummaryT",productHere,industryHere,sep="_"),digits=temp.stats2.digits),type="latex",size="\\scriptsize",file=paste(paste("SummaryT","shareGFCF",productHere,industryHere,sep="_"),".tex",sep=""))
    print(xtable(trends0,caption=paste("Trend share GFCF, over all countries, 1970 - 2010, total industry,", sep=""),label=paste("table:SummaryT",industryHere,sep="_"),digits=5),type="latex",size="\\scriptsize",file=paste(paste("SummaryT","shareGFCF",industryHere,sep="_"),".tex",sep=""))

  }
  trends0 <- do.call(rbind, unname(list(trends.all, pvalues.all)))
  rownames(trends0) <- c("trend","t.pvalue")
  trends0 <- trends0[,c("GFCF","NonICT","ICT","Con","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")]
  trends0 <- t(trends0)
  print(xtable(trends0,caption=paste("Trend share GFCF, over all countries, 1970 - 2010, total industry", sep=""),digits=5),type="latex",size="\\scriptsize",file=paste(paste("Summary","SLR","shareGFCF",industryHere,sep="_"),".tex",sep=""))
  
} 


detach("package:fBasics", unload=TRUE)
detach("package:timeSeries", unload=TRUE)