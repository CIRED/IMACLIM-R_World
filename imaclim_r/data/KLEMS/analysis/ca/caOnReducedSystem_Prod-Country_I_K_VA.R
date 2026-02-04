// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

folder <- paste0(CA,"/reducedSystem_Prod-Country_I-K-VA/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

`%not in%` <- function (x, table) is.na(match(x, table, nomatch=NA_integer_))

runCa <- function(dat, name , ncp=5, graph=T ){

    res.ca = CA(dat, ncp=5, graph=T)#,quanti.sup=c(1)) 

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
#for (yearHere  in  years[!years %in% c("2008","2009","2010")])
for (yearHere  in  years[years %in% c("2000")])
{
  for(industryHere in c("TOT"))#industries[industries=="TOT"])
  {
    temp1 <- ds %>% filter(year==yearHere, var=="VA", industry==industryHere, country %in% as.vector(countries)) %>% spread(var,value)
    temp2 <- ds %>% filter(year==yearHere, var=="I", industry==industryHere, !product %in% c("GFCF","ICT","NonICT")) %>% spread(product,value)
    temp  <- left_join(temp1,temp2, by=c("country","industry","year")) %>% 
             mutate_each(funs(./VA), -country, -product, -industry, -year, -VA, -var) %>% 
             subset(select=-c(product))

    checkNA <- temp %>% gather(product, value, -country, -industry, -year, -VA, -var) 
    for (countryHere in countries)
    {
      if(NA %in% checkNA[checkNA$country==countryHere,]$value)
        checkNA %>% filter(!country==countryHere) -> checkNA
    }
      
    checkNA %>% spread(product,value) -> temp
    temp$country <- factor(temp$country)
    rownames(temp)<-temp$country
    temp <- temp[,!(names(temp) %in% c("industry","year","VA","var"))]
    runCa(temp[,-1],paste("I_VA", industryHere,yearHere,"I_K_VA"))
  }
}

#------------------------------------------------------------------------------------------------

########## I_prod/I(GFCF)
#for (yearHere  in  years[!years %in% c("2008","2009","2010")])
for (yearHere  in  years[years %in% c("2000")])
{
  for(industryHere in c("TOT"))#industries[industries=="TOT"])
  {
    temp <- dg %>% filter(year==yearHere,var=="I", industry=="TOT") %>% 
                    spread(product, value) %>% 
                    mutate_each(funs(./GFCF),-GFCF, -country, -var, -industry, -year) %>% 
                    gather(product, value, -country, -var, -industry, -year) %>%
                    filter(!product %in% c("GFCF","ICT","NonICT"))
                   
    for (countryHere in countries)
    {
      if(NA %in% temp[temp$country==countryHere,]$value)
        temp%>% filter(!country==countryHere) -> temp
    }
    
    temp %>% spread(product,value) -> temp
    temp$country <- factor(temp$country)
    rownames(temp)<-temp$country
    temp <- temp[,!(names(temp) %in% c("industry","year","var"))]
    runCa(temp[,-1],paste("IShare", industryHere,yearHere,"I_K_VA"))
  }
}

