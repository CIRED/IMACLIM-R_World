# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


library(xtable)
library(ggplot2)
library(gridGraphics)
library(grid)
library(gridExtra)

folder <- paste0(SUMMARIZE,"/summarizeYears/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

#------------------------------------------------------------- Year x product ------- I

for (countryHere in c("USA"))
{
  for(industryHere in c("TOT"))
  {
    
    dg %>%
      filter(country=="USA",industry=="TOT",var=="I",!product %in% c("GFCF","ICT","NonICT")) %>%
      spread(product,value)  -> dH
    dH <- dH[,!(names(dH) %in% c("country","var","industry"))]
    row.names(dH) <- dH$year
    dH <- dH[,c("year", "RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")]

#Calculate distance between investment profiles different years.

    dH.use <- dH[,-c(1)]

    dH.distances <- data.frame(matrix(rep(0,dim(dH.use)[1]^2),nrow=dim(dH.use)[1],ncol=dim(dH.use)[1], byrow=TRUE))
    dH.years <- row.names(dH.use)
    colnames(dH.distances) <- dH.years
    rownames(dH.distances) <- dH.years

    col.sum <- apply(dH.use, 2, sum)
    years.triang <- dH.years

    for (col.year in dH.years)
    {  
    for (row.year in dH.years)
      {
      dH.distances[row.year,col.year] <- sum((dH.use[row.year,] - dH.use[col.year,])^2/col.sum) #pas une bonne distance
      }
    }
    print(xtable(t( dH.distances[names(dH.distances)<1989,]),caption=paste("Distances between investment profiles per year over products (I)", countryHere,sep=", "), label=paste("table:distancesYears-prod",countryHere,"I_part1",sep="_"), digits=0, auto = TRUE),type="latex",size="\\tiny",file=paste(paste("distancesYears-prod",countryHere,"I_part1",sep="_"),"tex",sep="."),floating = TRUE, floating.environment = "sidewaystable")
    print(xtable(t( dH.distances[names(dH.distances)>1988,]),caption=paste("Distances between investment profiles per year over products (I)", countryHere,sep=", "), label=paste("table:distancesYears-prod",countryHere,"I_part2",sep="_"), digits=0, auto = TRUE),type="latex",size="\\tiny",file=paste(paste("distancesYears-prod",countryHere,"I_part2",sep="_"),"tex",sep="."),floating = TRUE, floating.environment = "sidewaystable")
  }
}
#------------------------------------------------------------- Year x product ------- I/VA

for (countryHere in c("USA"))
{
  for(industryHere in c("TOT"))
  {
    dg %>%
      filter(country=="USA",industry==industryHere, var=="I",!product %in% c("GFCF","ICT","NonICT")) %>%
      spread(product,value)  -> temp1
    temp1 <- temp1[,!(names(temp1) %in% c("country","var","industry"))]
    
    temp1 <- temp1[,c("year", "RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft")]
    
    temp2 <- ds %>% dplyr::filter(var=="VA", industry==industryHere , country %in% as.vector(countries), country=="USA") %>% spread(var,value) %>% select(-c(product))
    dH  <- left_join(temp2,temp1, by=c("year")) %>% mutate_each(funs(./(VA/100)), -industry, -year, -country,-VA)
    rownames(dH)<-dH$year
    
    #Calculate distance between investment profiles different years.
    
    dH.use <- dH[-c(1,2,3,4,5,6,7,39,40,41),-c(1,2,3,4)] #replace with if NA, delete row/column
    
    dH.distances <- data.frame(matrix(rep(0,dim(dH.use)[1]^2),nrow=dim(dH.use)[1],ncol=dim(dH.use)[1], byrow=TRUE))
    dH.years <- row.names(dH.use)
    colnames(dH.distances) <- dH.years
    rownames(dH.distances) <- dH.years
    
    dH.distances2 <- data.frame(matrix(rep(0,dim(dH.use)[2]^2),nrow=dim(dH.use)[2],ncol=dim(dH.use)[2], byrow=TRUE)) #make a loop over the 2 dimensions
    dH.products <- names(dH.use)
    colnames(dH.distances2) <- dH.products
    rownames(dH.distances2) <- dH.products
    
    col.sum         <- apply(dH.use, 2, sum)
    
    for (col.year in dH.years)
    {  
      for (row.year in dH.years)
      {
        dH.distances[row.year,col.year] <- sum((dH.use[row.year,] - dH.use[col.year,])^2/(col.sum/dim(dH.use[1])))
      }
    }
    
    dH.use2         <- dH.use
    for (productHere in dH.products)
    {
      dH.use2[productHere] <- dH.use2[productHere]/col.sum[productHere]
    }
   
    col.sum2        <- apply(t(dH.use2), 2, sum)
    
    for (col.prod in dH.products)
    {  
      for (row.prod in dH.products)
      {
        dH.distances2[row.prod,col.prod] <- sum((dH.use2[,row.prod] - dH.use2[,col.prod])^2/(col.sum2/dim(dH.use[1])))
      }
    }
    print(xtable(t(dH.distances[names(dH.distances)<1989,]),caption=paste("Distances between investment profiles per year over products (I/VA)", countryHere,sep=", "), label=paste("table:distancesYears-prod",countryHere,"I_VA_part1",sep="_"), digits=3, auto = TRUE),type="latex",size="\\tiny",file=paste(paste("distancesYears-prod",countryHere,"I_VA_part1",sep="_"),"tex",sep="."),floating = TRUE, floating.environment = "sidewaystable")
    print(xtable(t(dH.distances[names(dH.distances)>1988,]),caption=paste("Distances between investment profiles per year over products (I/VA)", countryHere,sep=", "), label=paste("table:distancesYears-prod",countryHere,"I_VA_part2",sep="_"), digits=3, auto = TRUE),type="latex",size="\\tiny",file=paste(paste("distancesYears-prod",countryHere,"I_VA_part2",sep="_"),"tex",sep="."),floating = TRUE, floating.environment = "sidewaystable")
    print(xtable(t(dH.distances2),caption=paste("Distances between investment profiles per product, over years (I/VA)", countryHere,sep=", "), label=paste("table:distancesYears",countryHere,"I_prod",sep="_"), digits=2, auto = TRUE),type="latex",size="\\footnotesize",file=paste(paste("distancesYears",countryHere,"I_prod",sep="_"),"tex",sep="."))
    #print(xtable(t(dH.distances3),caption=paste("Distances between investment profiles per product, over years (I/VA)", countryHere,sep=", "), label=paste("table:distancesYears",countryHere,"I_VA_prod",sep="_"), digits=2, auto = TRUE),type="latex",size="\\footnotesize",file=paste(paste("distancesYears",countryHere,"I_VA_prod",sep="_"),"tex",sep="."))
  }
}

#plot of temporal evolution investment in product corrected for VA growth and relative sizes asset classes.

dH.use2$year <- as.integer(rownames(dH.use2))
dH.use2 <- dH.use2 %>% gather(product,value, -year, factor_key=TRUE)

#colorscheme_products=c("#191970", "#203D8B", "#8B4513", "#D55E00", "#A52A2A","#009E73","#ADFF2F","#228B22")
colorscheme_products=c("#FF0000", "#203D8B", "#F6921A", "#D55E00", "#A52A2A","#F61A85","#ADFF2F","#228B22")

p <- ggplot(dH.use2, aes( x=year, y=value, color=product)) + geom_line(size=1.2) +
  #scale_y_continuous(labels=percent, limits=c(0,0.355)) +
  #ggtitle(paste("Evolution of I/VA", "all sectors,", countryHere, sep=" ")) +
  #labs(y = "I / VA") +
  scale_color_manual(values=colorscheme_products) 
print(p)
ggsave(filename=paste(paste("I_ShareVA_evol",countryHere,"TOT",sep="-") ,"pdf",sep="."))


#------------------------------------------------------------- Year x product ------- I/VA without Soft

for (countryHere in c("USA"))
{
  for(industryHere in c("TOT"))
  {
    
    dg %>% filter(country=="USA",industry==industryHere,var=="I",!product %in% c("GFCF","ICT","NonICT","Soft")) %>%
           spread(product,value)  -> temp1
    temp1 <- temp1[,!(names(temp1) %in% c("country","var","industry"))]
    
    temp1 <- temp1[,c("year", "RStruc","OCon","TraEq","OMach","Other", "CT", "IT" )]
    
    temp2 <- ds %>% dplyr::filter(var=="VA", industry==industryHere, country %in% as.vector(countries), country=="USA") %>% spread(var,value) %>% select(-c(product))
    dH  <- left_join(temp2,temp1, by=c("year")) %>% mutate_each(funs(./(VA/100)), -industry, -year, -country,-VA)
    rownames(dH)<-dH$year
    
    #Calculate distance between investment profiles different years.
    
    dH.use <- dH[-c(1,2,3,4,5,6,7,39,40,41),-c(1,2,3,4)]
    
    dH.distances <- data.frame(matrix(rep(0,dim(dH.use)[1]^2),nrow=dim(dH.use)[1],ncol=dim(dH.use)[1], byrow=TRUE))
    dH.years <- row.names(dH.use)
    colnames(dH.distances) <- dH.years
    rownames(dH.distances) <- dH.years
    
    col.sum <- apply(dH.use, 2, sum)
    
    for (col.year in dH.years)
    { 
      for (row.year in dH.years)
      {
        dH.distances[row.year,col.year] <- sum((dH.use[row.year,] - dH.use[col.year,])^2/(col.sum/dim(dH.use[1])))
      }
    }
    
    print(xtable(t( dH.distances[names(dH.distances)<1989,]),caption=paste("Distances between investment profiles per year over products (I/VA), noSoft", countryHere,sep=", "), label=paste("table:distancesYears-prod",countryHere,"nonSoft_I_VA_part1",sep="_"),digits=3, auto = TRUE),type="latex",size="\\tiny",file=paste(paste("distancesYears-prod",countryHere,"noSoft_I_VA_part1",sep="_"),"tex",sep="."),floating = TRUE, floating.environment = "sidewaystable")
    print(xtable(t( dH.distances[names(dH.distances)>1988,]),caption=paste("Distances between investment profiles per year over products (I/VA), no Soft assets", countryHere,sep=", "),  label=paste("table:distancesYears-prod",countryHere,"nonSoft_I_VA_part2",sep="_"), digits=3, auto = TRUE),type="latex",size="\\tiny",file=paste(paste("distancesYears-prod",countryHere,"noSoft_I_VA_part2",sep="_"),"tex",sep="."),floating = TRUE, floating.environment = "sidewaystable")
  }
}

#------------------------------------------------------------- Year x industry ------- I/VA

temp0 <- dsAgg %>%  filter(industry %in% c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ","TOT"))
temp0$industry <- factor(temp0$industry, c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ","TOT"), labels=c("Agri","Mining","Manufacturing","Elec Gas Wtr","Construction","Sale","Transport Communication","Finance","Real estate","Real Estate Business","Community","Total"))
industries11 <- unique(temp0$industry)
temp0$product <- factor(temp0$product, levels=c("RStruc","OCon","OMach","TraEq","Other","CT","Soft","IT","NonICT","ICT","GFCF"))
temp0         <- temp0[order(temp0$product),]
productsL <- unique(temp0$product)

#------------------------------------------------------------- Year x industry ------- I/VA

for (countryHere in c("USA"))
{
  for(productHere in c("GFCF"))
  {
    temp0 %>%
      filter(country==countryHere, product==productHere, var=="I") %>%
      spread(industry,value)  -> temp1
    temp1 <- temp1[,!(names(temp1) %in% c("country","var","product"))]
    
    temp2 <- temp0 %>% dplyr::filter(country==countryHere, var=="VA", industry=="Total") %>% 
             select(-c(product, industry))  %>%
             spread(var,value) 
             
    dH  <- left_join(temp2,temp1, by=c("year")) %>% mutate_each(funs(./(VA/100)), -year, -country,-VA)
    rownames(dH)<-dH$year
    
    #Calculate distance between investment profiles different years.
    
    dH.use <- dH[-c(1,2,3,4,5,6,7,39,40,41),-c(1,2,3,15)] #replace with if NA, delete row/column
    
    dH.distances <- data.frame(matrix(rep(0,dim(dH.use)[1]^2),nrow=dim(dH.use)[1],ncol=dim(dH.use)[1], byrow=TRUE))
    dH.years <- row.names(dH.use)
    colnames(dH.distances) <- dH.years
    rownames(dH.distances) <- dH.years
    
    dH.distances2 <- data.frame(matrix(rep(0,dim(dH.use)[2]^2),nrow=dim(dH.use)[2],ncol=dim(dH.use)[2], byrow=TRUE)) #make a loop over the 2 dimensions
    dH.industries <- names(dH.use)
    colnames(dH.distances2) <- dH.industries
    rownames(dH.distances2) <- dH.industries
    
    col.sum         <- apply(dH.use, 2, sum)
      
    for (col.year in dH.years)
    { 
      for (row.year in dH.years)
      {
        dH.distances[row.year,col.year] <- sum((dH.use[row.year,] - dH.use[col.year,])^2/(col.sum/dim(dH.use[1])))
      }
    }
    
    dH.use2         <- dH.use
    for (industryHere in dH.industries)
    {
      dH.use2[industryHere] <- dH.use2[industryHere]/col.sum[industryHere]
    }
    
    col.sum2        <- apply(t(dH.use2), 2, sum)
    
    for (col.ind in dH.industries)
    {  
      for (row.ind in dH.industries)
      {
        dH.distances2[row.ind,col.ind] <- sum((dH.use2[,row.ind] - dH.use2[,col.ind])^2/(col.sum2/dim(dH.use2[2])))
      }
    }
    print(xtable(t(dH.distances[names(dH.distances)<1989,]),caption=paste("Distances between investment profiles per year over industries (I/VA)", countryHere,sep=", "), label=paste("table:distancesYears-ind",countryHere,"I_VA_part1",sep="_"), digits=3, auto = TRUE),type="latex",size="\\tiny",file=paste(paste("distancesYears-ind",countryHere,"I_VA_part1",sep="_"),"tex",sep="."),floating = TRUE, floating.environment = "sidewaystable")
    print(xtable(t(dH.distances[names(dH.distances)>1988,]),caption=paste("Distances between investment profiles per year over industries (I/VA)", countryHere,sep=", "), label=paste("table:distancesYears-ind",countryHere,"I_VA_part2",sep="_"), digits=3, auto = TRUE),type="latex",size="\\tiny",file=paste(paste("distancesYears-ind",countryHere,"I_VA_part2",sep="_"),"tex",sep="."),floating = TRUE, floating.environment = "sidewaystable")
    print(xtable(t(dH.distances2),caption=paste("Distances between investment evolution,over years, per industry (I)", countryHere,sep=", "), label=paste("table:distancesYears",countryHere,"I_ind",sep="_"), digits=2, auto = TRUE),type="latex",size="\\footnotesize",file=paste(paste("distancesYears",countryHere,"I_ind",sep="_"),"tex",sep="."))
    #print(xtable(t(dH.distances3),caption=paste("Distances between investment profiles per product, over years (I/VA)", countryHere,sep=", "), label=paste("table:distancesYears",countryHere,"I_VA_prod",sep="_"), digits=2, auto = TRUE),type="latex",size="\\footnotesize",file=paste(paste("distancesYears",countryHere,"I_VA_prod",sep="_"),"tex",sep="."))
  }
}

#plot of temporal evolution investment in product corrected for VA growth and relative sizes asset classes.

dH.use2$year <- as.integer(rownames(dH.use2))
dH.use2 <- dH.use2 %>% gather(industry,value, -year, factor_key=TRUE)

colorscheme_industries=c("#191970", "#203D8B", "#8B4513", "#D55E00", "#A52A2A","#009E73","#ADFF2F","#228B22", "#AAAAAA","#666666","#000000")

p <- ggplot(dH.use2, aes( x=year, y=value, color=industry)) + geom_line(size=1.2) +
  #scale_y_continuous(labels=percent, limits=c(0,0.355)) +
  #ggtitle(paste("Evolution of I/VA", "all sectors,", countryHere, sep=" ")) +
  #labs(y = "I / VA") +
  scale_color_manual(values=colorscheme_industries) 
print(p)
ggsave(filename=paste(paste("I_ShareVA_evol-ind",countryHere,"GFCF",sep="-") ,"pdf",sep="."))

