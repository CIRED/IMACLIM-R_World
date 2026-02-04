// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


folder <- paste0(CA,"/reducedSystem_Prod-Year/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

runCa <- function(dat, name , ncp=5, graph=T,  colSup = NULL ){
  
  res.ca = CA(dat, ncp=5, graph=T, col.sup=colSup) 
  
  write.infile(res.ca,file=paste0(name,".txt"))
  summary(res.ca,file=paste0(name,"-summary.txt"))
  
  dev.copy2pdf(file=paste0(name,"-1.pdf"))
  dev.off()
  #dev.copy2pdf(file=paste0(name,"-2.pdf"))
  #dev.off()
  
  return(res.ca)
}
#------------------------------------------------------------------------------------------------

########## I_prod/VA
#for (productHere in products)
for (productHere in c("GFCF"))
{
  for(industryHere in c("TOT"))#industries[industries=="TOT"])
  {
    temp1 <- ds %>% filter(country==countryHere, var=="VA", industry==industryHere) %>% spread(var,value)
    temp2 <- ds %>% filter(country==countryHere, var=="I", industry==industryHere, !product %in% c("GFCF")) %>% spread(product,value)
    #temp2 <- ds %>% filter(country==countryHere, var=="I", industry==industryHere, !product %in% c("GFCF","ICT","NonICT")) %>% spread(product,value)
    temp  <- left_join(temp1,temp2, by=c("country","industry","year")) %>% 
      mutate_each(funs(./VA), -country, -product, -industry, -year, -VA, -var) %>% 
      subset(select=-c(product))
    
    checkNA <- temp %>% gather(product, value, -country, -industry, -year, -VA, -var) 
    for (yearHere in years)
    {
      if(NA %in% checkNA[checkNA$year==yearHere,]$value)
        checkNA %>% filter(!year==yearHere) -> checkNA
    }
    
    checkNA %>% spread(product,value) -> temp
    temp$year <- factor(temp$year)
    rownames(temp)<-temp$year
    temp <- temp[,!(names(temp) %in% c("industry","country","VA","var"))]
    runCa(temp[,-c(1)],paste("I_VA", industryHere,countryHere,"I_K_VA"), colSup=c(2,4))
  } # to keep supplementary variables, keep ICT and CT in temp, exclude from runCA but add as suppl. variables
}
#------------------------------------------------------------------------------------------------

########## I_prod/I(GFCF)
#for (countryHere in unique(dg$country))
for (countryHere in countries[countries %in% c("SWE")])
{
  for(industryHere in c("TOT"))#industries[industries=="TOT"])
  {
    temp <- dg %>% filter(country==countryHere,var=="I", industry=="TOT") %>% 
                   spread(product, value) %>% 
                   mutate_each(funs(./GFCF),-GFCF, -country, -var, -industry, -year) %>% 
                   gather(product, value, -country, -var, -industry, -year) %>%
                   filter(!product %in% c("GFCF"))
    
    for (yearHere in years)
    {
      if(NA %in% temp[temp$year==yearHere,]$value)
        temp%>% filter(!year==yearHere) -> temp
    }
    
    temp %>% spread(product,value) -> temp
    temp$year <- factor(temp$year)
    rownames(temp)<-temp$year
    temp <- temp[,!(names(temp) %in% c("industry","country","var"))]
    runCa(temp[,-1],paste("IShare", industryHere,countryHere,"I_K_VA"), colSup=c(2,4))
  }
}

#------------------------------------------------------------------------------
for (country in countries[countries %in% c("USA")])
{

dg %>%
    filter(country=="USA",industry=="TOT",var=="I",!product %in% c("GFCF","ICT","NonICT")) %>%
    spread(product,value)  -> ds
rownames(ds)<-ds$year
ds <- ds[,!(names(ds) %in% c("country","var","industry"))] 

runCa(ds,"usaTotAbsolute",supQuanti=c(1))

}

#------------------------------------------------------------------------------
dg %>%
    filter(country=="USA",industry=="TOT",var=="I",!product %in% c("GFCF","ICT","NonICT")) %>%
    ddply(.(year), mutate, share = value / sum(value) ) -> ds
ds <- ds[,!(names(ds) %in% c("country","var","industry","value"))] 
spread(ds,product,share)  -> ds
rownames(ds)<-ds$year
runCa(ds,paste("I_VA", industryHere,yearHere,"I_K_VA"),supQuanti=c(1))



#------------------------------------------------------------------------------
dg %>%
    filter(country=="USA",industry=="TOT",var=="I",!product %in% c("GFCF","ICT","NonICT")) %>%
    spread(product,value)  -> ds
rownames(ds)<-ds$year
ds <- ds[,!(names(ds) %in% c("country","var","industry","year"))] 
ds %>% t %>% as.data.frame -> dt
#names(dt) <- paste0("v",names(dt))
dt$type <- as.factor(rownames(dt))
ictType    = c("CT","IT","Soft")
nonIctType = c("OCon","OMach","Other","RStruc","TraEq")
temp <- levels(dt$type) 
temp[temp %in% ictType] <- "ICT"
temp[temp %in% nonIctType] <- "NonICT"
temp -> levels(dt$type) 
runPca(dt,"usaYearsAbsolute",supQuali="type")

dg %>%
    filter(country=="USA",industry=="TOT",var=="I",!product %in% c("GFCF","ICT","NonICT")) %>%
    ddply(.(product), mutate, share = value / sum(value) ) -> ds
ds[,!(names(ds) %in% c("value"))] %>%
    spread(product,share)  -> ds
rownames(ds)<-ds$year
ds <- ds[,!(names(ds) %in% c("country","var","industry","year"))] 
ds %>% t %>% as.data.frame -> dt
dt$type <- as.factor(rownames(dt))
ictType    = c("CT","IT","Soft")
nonIctType = c("OCon","OMach","Other","RStruc","TraEq")
temp <- levels(dt$type) 
temp[temp %in% ictType] <- "ICT"
temp[temp %in% nonIctType] <- "NonICT"
temp -> levels(dt$type) 
runPca(dt,"usaYearsRelative",supQuali="type")

