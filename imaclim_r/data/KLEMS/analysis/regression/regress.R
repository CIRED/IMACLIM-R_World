# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

folder <- paste0(REGRESS,"/regressData/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

#assets

trends <- data.frame(matrix(rep(0,length(countries)*length(products)),nrow=length(countries),ncol=length(products), byrow=TRUE))
colnames(trends) <- products
rownames(trends) <- countries
pvalues <- trends
for (industryHere in c("TOT"))
{
  temp0 <- dsAgg %>% dplyr::filter(var=="VA", industry==industryHere)
  temp00 <- dsAgg %>% dplyr::filter(var=="I", industry==industryHere) 

  #for (countryHere in countries[!countries=="SWE"]) #check what is the problem for UK ?    
  for (countryHere in countries)
    {
    temp1 <- temp0 %>% dplyr::filter(country==countryHere) %>% spread(var,value) %>% select(-c(product))
    temp11 <- temp00 %>% dplyr::filter(country==countryHere) 
    
    fileName <- paste(file=paste("summarySLR","Products",countryHere,sep="_"),"txt",sep=".")
    
    if (countryHere=="SWE")
    { productsHere <- products[!products=="Other"] } else
    { productsHere <- products}

    for(productHere in productsHere) 
    {  
      temp22 <- temp11 %>% dplyr::filter(product==productHere) %>% spread(var,value)
      temp  <- left_join(temp1,temp22, by=c("country","industry","year")) %>% 
                         mutate(I_VA=I/VA)
      
      temp.lm <- lm(I_VA ~ years, data=temp)
      #temp.res = resid(temp.lm) #We now plot the residual against the observed values of the variable waiting.
      #plot(temp[!temp$year=="2008"&!temp$year=="2009"&!temp$year=="2010",]$year, temp.res, ylab="Residuals", xlab="Year", main="Residuals I_VA trend",abline(0, 0)
      
      trends[countryHere,productHere] <- coefficients(temp.lm)[2]
      pvalues[countryHere,productHere] <- summary(temp.lm)$coefficients[8]
      
      #temp.lm.out  <- capture.output(summary(temp.lm))
      #cat(paste(countryHere, productHere, sep=" "), temp.lm.out, file=fileName, sep="\n", type = c("output"),append=TRUE)
    }
  }  
} 
trends <- trends[,c("GFCF","NonICT","ICT","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")]
pvalues <- pvalues[,c("GFCF","NonICT","ICT","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")]
pvalues.cat <- pvalues
#pvalues.cat$country=rownames(pvalues)

pvalues.cat[pvalues.cat >= 0 & pvalues.cat <= 0.001] <- "***"
pvalues.cat[pvalues.cat > 0.001 & pvalues.cat <= 0.01] <- "**"
pvalues.cat[pvalues.cat > 0.01 & pvalues.cat <= 0.05] <- "*"
pvalues.cat[pvalues.cat > 0.05 & pvalues.cat <= 0.1] <- "."
pvalues.cat[pvalues.cat > 0.1 & pvalues.cat <= 1] <- "_"

trends.final2 <- trends
trends.final3 <- trends
trends.final2[trends< 0] <- "$\\downarrow^{"
trends.final2[trends > 0] <- "$\\uparrow^{"
trends.final3 <- "}$"

trends.final <- as.data.frame(matrix(paste0(as.matrix(trends.final2),as.matrix(pvalues.cat),as.matrix(trends.final3)),nrow=nrow(as.matrix(trends.final2)), dimnames=dimnames(as.matrix(trends.final2))))

print(xtable(trends.final,caption=paste("Trend I / VA per country, 1970 - 2010, total industry", sep="")),type="latex",size="\\scriptsize",file=paste(paste("Summary","SLR","percountry",industryHere,sep="_"),".tex",sep=""))


#-------------------------------------------

#industries

trends <- data.frame(matrix(rep(0,length(countries)*length(industries)),nrow=length(countries),ncol=length(industries), byrow=TRUE))
colnames(trends) <- industries
rownames(trends) <- countries
pvalues <- trends
for (productHere in c("GFCF"))
{
  temp0 <- dsAgg %>% dplyr::filter(var=="VA")
  temp00 <- dsAgg %>% dplyr::filter(var=="I", product==productHere) 
  
  #for (countryHere in countries[!countries=="SWE"]) #check what is the problem for UK ?    
  for (countryHere in countries)
  {
    temp1 <- temp0 %>% dplyr::filter(country==countryHere) %>% spread(var,value) %>% select(-c(product))
    temp11 <- temp00 %>% dplyr::filter(country==countryHere) 
    
    fileName <- paste(file=paste("summarySLR","Products",countryHere,sep="_"),"txt",sep=".")
    
    for(industryHere in industries) 
    {  
      temp22 <- temp11 %>% dplyr::filter(industry==industryHere) %>% spread(var,value)
      temp  <- left_join(temp1,temp22, by=c("country","industry","year")) %>% 
        mutate(I_VA=I/VA)
      
      temp.lm <- lm(I_VA ~ years, data=temp)
      #temp.res = resid(temp.lm) #We now plot the residual against the observed values of the variable waiting.
      #plot(temp[!temp$year=="2008"&!temp$year=="2009"&!temp$year=="2010",]$year, temp.res, ylab="Residuals", xlab="Year", main="Residuals I_VA trend",abline(0, 0)
      
      trends[countryHere,industryHere] <- coefficients(temp.lm)[2]
      pvalues[countryHere,industryHere] <- summary(temp.lm)$coefficients[8]
      
      #temp.lm.out  <- capture.output(summary(temp.lm))
      #cat(paste(countryHere, productHere, sep=" "), temp.lm.out, file=fileName, sep="\n", type = c("output"),append=TRUE)
    }
  }  
} 
trends <- trends[,c("GFCF","NonICT","ICT","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")]
pvalues <- pvalues[,c("GFCF","NonICT","ICT","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")]
pvalues.cat <- pvalues
#pvalues.cat$country=rownames(pvalues)

pvalues.cat[pvalues.cat >= 0 & pvalues.cat <= 0.001] <- "***"
pvalues.cat[pvalues.cat > 0.001 & pvalues.cat <= 0.01] <- "**"
pvalues.cat[pvalues.cat > 0.01 & pvalues.cat <= 0.05] <- "*"
pvalues.cat[pvalues.cat > 0.05 & pvalues.cat <= 0.1] <- "."
pvalues.cat[pvalues.cat > 0.1 & pvalues.cat <= 1] <- "_"

trends.final2 <- trends
trends.final3 <- trends
trends.final2[trends< 0] <- "$\\downarrow^{"
trends.final2[trends > 0] <- "$\\uparrow^{"
trends.final3 <- "}$"

trends.final <- as.data.frame(matrix(paste0(as.matrix(trends.final2),as.matrix(pvalues.cat),as.matrix(trends.final3)),nrow=nrow(as.matrix(trends.final2)), dimnames=dimnames(as.matrix(trends.final2))))

print(xtable(trends.final,caption=paste("Trend I / VA per country, 1970 - 2010, total industry", sep="")),type="latex",size="\\scriptsize",file=paste(paste("Summary","SLR","percountry",industryHere,sep="_"),".tex",sep=""))
