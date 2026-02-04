// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

library(fBasics)

folder.means <- paste0(SUMMARIZE,"/summarizeData/shareGFCF/8products/means/")
folder.SLR <- paste0(SUMMARIZE,"/summarizeData/shareGFCF/8products/SLR/")
cat("Results will be located in",folder.means,"\n\n")
cat("Results will be located in",folder.SLR,"\n\n")
dir.create(folder.means, recursive = TRUE)
dir.create(folder.SLR, recursive = TRUE)
setwd(folder.means)

#---------------------------------------------------------------------------------
#create variable "trend" which is the slope of the regression per country, per industry of investment in asset over time
productsVector <- c("NonICT","ICT","Con","Mach","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")
industryVector <- c("TOT",industryVector12)
#productsL <- factor(c(productsVector,"Con","Mach"), levels=c(productsVector,"Con","Mach"))

createTables.Means.Trends.GFCF <- function(productsL, industryVectorHere){

init3.mean <- data.frame(matrix(rep(0,length(countries)*length(productsL)),nrow=length(countries),ncol=length(productsL), byrow=TRUE))
colnames(init3.mean) <- productsL
rownames(init3.mean) <- countries
end3.mean            <- init3.mean
all.mean             <- init3.mean
trends               <- init3.mean
pvalues              <- init3.mean
intercept            <- init3.mean

for (industryHere in industryVectorHere)
#for (industryHere in c("TOT"))
{
  temp00 <- dsAgg %>% dplyr::filter(var=="I", industry==industryHere)
  
  for (countryHere in countries)
    {
    temp0 <- temp00 %>% dplyr::filter(country==countryHere) %>% 
                        spread(product,value) %>%
                        mutate(Con = RStruc + OCon, Mach = OMach + TraEq) %>% 
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
        temp$time <- temp$year-1970
        
        a=1
        b=dim(temp)[1]
        while(is.na(temp[a,"share"])) { a <- a+1 }

        while(is.na(temp[b,"share"])) { b <- b-1 }
        
        init3.mean[countryHere,productHere] <- mean(temp[a:(a+2),5])*100
        end3.mean[countryHere,productHere]  <- mean(temp[(b-2):b,5])*100
        all.mean[countryHere,productHere]   <- data.frame(t(basicStats(temp[5]))) %>% select(c(Mean))*100
        
        temp.lm <- lm(share ~ time, data=temp)
        trends[countryHere,productHere] <- coefficients(temp.lm)[2]*100
        intercept[countryHere,productHere] <- temp.lm$coefficients[1]*100
        pvalues[countryHere,productHere] <- summary(temp.lm)$coefficients[8]
      } 
      else
        { 
          init3.mean[countryHere,productHere] <- NA
          end3.mean[countryHere,productHere]  <- NA
          all.mean[countryHere,productHere]   <- NA
          
          trends[countryHere,productHere] <- NA
          intercept[countryHere,productHere] <- NA
          pvalues[countryHere,productHere] <- NA
        }
    }
  }
  trends      <- round(trends, digits=2)
  init3.mean  <- init3.mean[,productsL]
  end3.mean   <- end3.mean[,productsL]
  all.mean    <- all.mean[,productsL]
  trends      <- trends[,productsL]
  intercept   <- intercept[,productsL]
  pvalues     <- pvalues[,productsL]
  
  init3.mean <- init3.mean[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
  end3.mean <- end3.mean[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
  all.mean <- all.mean[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
  trends <- trends[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
  intercept <- intercept[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
  pvalues <- pvalues[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
  
  setwd(folder.means)
  print(xtable(all.mean, caption=paste("Shares per product in industries' GFCF, per country, average 1970 - 2010, ", industryHere,".",sep=""), label=paste("means","shareGFCF","percountry",industryHere,sep="_") ,type="latex", digits=2,  align="r|rr|rr|rrrrrrrr"), size="\\scriptsize", hline.after = c(-1,0,11,15), file=paste(paste("means","shareGFCF","percountry",industryHere,sep="_"),".tex",sep=""))
  print(xtable(init3.mean, caption=paste("Shares per product in industries' GFCF, per country, average first 3 years, ", industryHere,".", sep=""), label=paste("initmeans","shareGFCF","percountry",industryHere,sep="_"),type="latex",digits=2, align="r|rr|rr|rrrrrrrr"), size="\\scriptsize",hline.after = c(-1,0,11,15), file=paste(paste("initmeans","shareGFCF","percountry",industryHere,sep="_"),".tex",sep=""))
  print(xtable(end3.mean, caption=paste("Shares per product in industries' GFCF, per country, average last 3 years, ", industryHere,".", sep=""), label=paste("endmeans","shareGFCF","percountry",industryHere,sep="_"),type="latex",digits=2, align="r|rr|rr|rrrrrrrr"), size="\\scriptsize", hline.after = c(-1,0,11,15), file=paste(paste("endmeans","shareGFCF","percountry",industryHere,sep="_"),".tex",sep=""))
  setwd(folder.SLR)
  #print(xtable(trends, caption=paste("Shares per product in industries' GFCF, per country, average last 3 years, ", industryHere,".", sep=""), label=paste("trends","shareGFCF","percountry",industryHere,sep="_"),type="latex",digits=2, align="r|rr|rr|rrrrrrrr"), size="\\scriptsize", hline.after = c(-1,0,11,15), file=paste(paste("trends","shareGFCF","percountry",industryHere,sep="_"),".tex",sep=""))
  print(xtable(intercept, caption=paste("Shares per product in industries' GFCF, per country, intercept SLR, ", industryHere,".", sep=""), label=paste("SLR","intercept","shareGFCF","percountry",industryHere,sep="_"),type="latex",digits=1, align="r|rr|rr|rrrrrrrr"), size="\\scriptsize", hline.after = c(-1,0,11,15), file=paste(paste("SLR", "intercept","shareGFCF","percountry",industryHere,sep="_"),".tex",sep=""))
  
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
  pvalues.cat <- pvalues.cat[,productsL]

  trends.final1 <- trends
  trends.final2 <- trends
  trends.final3 <- trends

  trends.final1 <- "$^{"
  trends.final2[trends< 0] <- "$\\downarrow^{"
  trends.final2[trends > 0] <- "$\\uparrow^{"
  trends.final3 <- "}$"

  trends.final <- as.data.frame(matrix(paste0(as.matrix(trends),as.matrix(trends.final1),as.matrix(pvalues.cat),as.matrix(trends.final3)),nrow=nrow(as.matrix(trends.final2)), dimnames=dimnames(as.matrix(trends.final2))))
  trends.final.cat <- as.data.frame(matrix(paste0(as.matrix(trends.final2),as.matrix(pvalues.cat),as.matrix(trends.final3)),nrow=nrow(as.matrix(trends.final2)), dimnames=dimnames(as.matrix(trends.final2))))

  print(xtable(trends.final, caption=paste("Trend share GFCF per country, 1970 - 2010, total industry", sep=""), label=paste("SLR","shareGFCF","percountry",industryHere,sep="_"), type=latex, align="r|rr|rr|rrrrrrrr"), hline.after = c(-1,0,11,15), size="\\scriptsize", file=paste(paste("SLR","trend","shareGFCF","percountry", industryHere,sep="_"),".tex", sep=""))
  print(xtable(trends.final.cat, caption=paste("Trend share GFCF per country, 1970 - 2010, total industry", sep=""), label=paste("SLR","shareGFCF","cat","percountry",industryHere,sep="_"), type=latex, align="r|rr|rr|rrrrrrrr"), hline.after = c(-1,0,11,15), size="\\scriptsize", file=paste(paste("SLR","trendCat","shareGFCF","percountry", industryHere,sep="_"),".tex", sep=""))
} # Here ends the for loop over industries
} # Here ends the definition of the function
#---------------------------------------------------------------------------------
productsVector <- c("NonICT","ICT","Con","Mach","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")
industryVector <- c("TOT")
nProd <- 8

folder.means <- paste0(SUMMARIZE,"/summarizeData/shareGFCF/",nProd,"products/means/")
folder.SLR <- paste0(SUMMARIZE,"/summarizeData/shareGFCF/",nProd,"products/SLR/")
cat("Results will be located in",folder.means,"\n\n")
cat("Results will be located in",folder.SLR,"\n\n")
dir.create(folder.means, recursive = TRUE)
dir.create(folder.SLR, recursive = TRUE)
setwd(folder.means)

createTables.Means.Trends(productsVector, industryVector)

#---------------------------------------------------------------------------------

createTables.Means.Trends.subselection4GFCF <- function(productsL, industryVectorHere){
  
  for (industryHere in industryVectorHere)
    #for (industryHere in c("TOT"))
  {
    temp00 <- dsAgg %>% dplyr::filter(var=="I", industry==industryHere)
    
    init3.mean <- data.frame(matrix(rep(0,length(countries)*length(productsL)),nrow=length(countries),ncol=length(productsL), byrow=TRUE))
    colnames(init3.mean) <- productsL
    rownames(init3.mean) <- countries
    end3.mean            <- init3.mean
    all.mean             <- init3.mean
    trends               <- init3.mean
    pvalues              <- init3.mean
    intercept            <- init3.mean
    
    for (countryHere in countries)
    {
      temp0 <- temp00 %>% dplyr::filter(country==countryHere) %>% 
        spread(product,value) %>%
        mutate(Con = RStruc + OCon, Mach = OMach + TraEq) %>% 
        gather(product, value, -year, -country, -var, -industry,factor_key = TRUE) 
      
      for(productHere in productsL) 
      {  
        temp <- temp0 %>% dplyr::filter(product %in% c(productHere,"GFCF", "ICT", "Other")) %>% 
                          spread(product,value) %>% 
                          mutate_each(funs(./(GFCF-ICT-Other)), -country, -var, -year, -industry, -GFCF, -ICT, -Other) %>%
                          select(-c(GFCF, ICT, Other))
        
        if (sum(is.na(temp[,colnames(temp)==productHere])) < dim(temp)[1]-2)
        {
          colnames(temp)[ncol(temp)] <- "share"
          temp$time <- temp$year-1970
          
          a=1
          b=dim(temp)[1]
          while(is.na(temp[a,"share"])) { a <- a+1 }
          
          while(is.na(temp[b,"share"])) { b <- b-1 }
          
          init3.mean[countryHere,productHere] <- mean(temp[a:(a+2),5])*100
          end3.mean[countryHere,productHere]  <- mean(temp[(b-2):b,5])*100
          all.mean[countryHere,productHere]   <- data.frame(t(basicStats(temp[5]))) %>% select(c(Mean))*100
          
          temp.lm <- lm(share ~ time, data=temp)
          trends[countryHere,productHere] <- coefficients(temp.lm)[2]*100
          intercept[countryHere,productHere] <- temp.lm$coefficients[1]*100
          pvalues[countryHere,productHere] <- summary(temp.lm)$coefficients[2,4]
        } 
        else
        { 
          init3.mean[countryHere,productHere] <- NA
          end3.mean[countryHere,productHere]  <- NA
          all.mean[countryHere,productHere]   <- NA
          
          trends[countryHere,productHere] <- NA
          intercept[countryHere,productHere] <- NA
          pvalues[countryHere,productHere] <- NA
        }
      }
    }
    trends <- round(trends, digits=2)
    init3.mean <- init3.mean[,productsL]
    end3.mean  <- end3.mean[,productsL]
    all.mean  <- all.mean[,productsL]
    trends <- trends[,productsL]
    intercept <- intercept[,productsL]
    pvalues <- pvalues[,productsL]
    
    init3.mean <- init3.mean[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
    end3.mean <- end3.mean[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
    all.mean <- all.mean[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
    trends <- trends[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
    intercept <- intercept[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
    pvalues <- pvalues[c("AUS", "AUT", "DNK", "ESP", "FIN", "FRA", "ITA", "JPN", "NLD",  "UK", "USA", "CZE", "GER", "SVN", "SWE"), ]
    
    setwd(folder.means)
    print(xtable(all.mean, caption=paste("Shares per product in industries' GFCF, per country, average 1970 - 2010, ", industryHere,".",sep=""), label=paste("means","shareGFCF4","percountry",industryHere,sep="_") ,type="latex", digits=1,  align="r|rr|rrrr"), size="\\scriptsize", hline.after = c(-1,0,11,15), file=paste(paste("means","shareGFCF","percountry",industryHere,sep="_"),".tex",sep=""))
    print(xtable(init3.mean, caption=paste("Shares per product in industries' GFCF, per country, average first 3 years, ", industryHere,".", sep=""), label=paste("initmeans","shareGFCF4","percountry",industryHere,sep="_"),type="latex",digits=1, align="r|rr|rrrr"), size="\\scriptsize",hline.after = c(-1,0,11,15), file=paste(paste("initmeans","shareGFCF","percountry",industryHere,sep="_"),".tex",sep=""))
    print(xtable(end3.mean, caption=paste("Shares per product in industries' GFCF, per country, average last 3 years, ", industryHere,".", sep=""), label=paste("endmeans","shareGFCF4","percountry",industryHere,sep="_"),type="latex",digits=1, align="r|rr|rrrr"), size="\\scriptsize", hline.after = c(-1,0,11,15), file=paste(paste("endmeans","shareGFCF","percountry",industryHere,sep="_"),".tex",sep=""))
    setwd(folder.SLR)
    #print(xtable(trends, caption=paste("Shares per product in industries' GFCF, per country, average last 3 years, ", industryHere,".", sep=""), label=paste("trends","shareGFCF","percountry",industryHere,sep="_"),type="latex",digits=2, align="r|rr|rrrr"), size="\\scriptsize", hline.after = c(-1,0,11,15), file=paste(paste("trends","shareGFCF","percountry",industryHere,sep="_"),".tex",sep=""))
    print(xtable(intercept, caption=paste("Intercept SLR of respective shares RStruc, OCon, TraEq, OMach in industries' GFCF, ", industryHere,".", sep=""), label=paste("SLR","intercept","shareGFCF4","percountry",industryHere,sep="_"),type="latex",digits=1, align="r|rr|rrrr"), size="\\scriptsize", hline.after = c(-1,0,11,15), file=paste(paste("SLR", "intercept","shareGFCF","percountry",industryHere,sep="_"),".tex",sep=""))
    
    pvalues.cat <- pvalues
    pvalues.cat$country=rownames(pvalues)
    pvalues.cat <- pvalues.cat %>% gather(product, value, -country)
    
    pvalues.cat$value[pvalues.cat$value > 0 & pvalues.cat$value <= 0.001] <- "***"
    pvalues.cat$value[pvalues.cat$value > 0.001 & pvalues.cat$value <= 0.01] <- "**"
    pvalues.cat$value[pvalues.cat$value > 0.01 & pvalues.cat$value <= 0.05] <- "*"
    pvalues.cat$value[pvalues.cat$value > 0.05 & pvalues.cat$value <= 0.1] <- "."
    pvalues.cat$value[pvalues.cat$value > 0.1 & pvalues.cat$value <= 1] <- "_"
    
    pvalues.cat <- pvalues.cat %>% spread(product,value) 
    rownames(pvalues.cat) <- pvalues.cat$country
    pvalues.cat <- pvalues.cat %>% select(-country)
    pvalues.cat <- pvalues.cat[,productsL]
    
    trends.final1 <- trends
    trends.final2 <- trends
    trends.final3 <- trends
    
    trends.final1 <- "$^{"
    trends.final2[trends< 0] <- "$\\downarrow^{"
    trends.final2[trends > 0] <- "$\\uparrow^{"
    trends.final3 <- "}$"
    
    trends.final <- as.data.frame(matrix(paste0(as.matrix(trends),as.matrix(trends.final1),as.matrix(pvalues.cat),as.matrix(trends.final3)),nrow=nrow(as.matrix(trends.final2)), dimnames=dimnames(as.matrix(trends.final2))))
    trends.final.cat <- as.data.frame(matrix(paste0(as.matrix(trends.final2),as.matrix(pvalues.cat),as.matrix(trends.final3)),nrow=nrow(as.matrix(trends.final2)), dimnames=dimnames(as.matrix(trends.final2))))
    
    print(xtable(trends.final, caption=paste("Trend of respective shares RStruc, OCon, TraEq, OMach in industries' GFCF, 1970 - 2010, ",industryHere,".", sep=""), label=paste("SLR","shareGFCF4","percountry",industryHere,sep="_"), type=latex, align="r|ll|llll"), hline.after = c(-1,0,11,15), size="\\scriptsize", file=paste(paste("SLR","trend","shareGFCF","percountry", industryHere,sep="_"),".tex", sep=""))
    print(xtable(trends.final.cat, caption=paste("Trend of respective shares RStruc, OCon, TraEq, OMach in industries' GFCF, 1970 - 2010, ",industryHere ,".",sep=""), label=paste("SLR","shareGFCF4","cat","percountry",industryHere,sep="_"), type=latex, align="r|ll|llll"), hline.after = c(-1,0,11,15), size="\\scriptsize", file=paste(paste("SLR","trendCat","shareGFCF","percountry", industryHere,sep="_"),".tex", sep=""))
  } # Here ends the for loop over industries
} # Here ends the definition of the function


productsVector <- c("Con","Mach","RStruc","OCon","TraEq","OMach")
industryVector <- c("TOT",industryVector12)
#industryVector <- c("D")
nProd <- 4

folder.means <- paste0(SUMMARIZE,"/summarizeData/shareGFCF/",nProd,"products/means/")
folder.SLR <- paste0(SUMMARIZE,"/summarizeData/shareGFCF/",nProd,"products/SLR/")
cat("Results will be located in",folder.means,"\n\n")
cat("Results will be located in",folder.SLR,"\n\n")
dir.create(folder.means, recursive = TRUE)
dir.create(folder.SLR, recursive = TRUE)
setwd(folder.means)

createTables.Means.Trends.subselection4GFCF(productsVector, industryVector)



detach("package:fBasics", unload=TRUE)
detach("package:timeSeries", unload=TRUE)