// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

folder <- paste0(CA,"/reducedSystemProdCountry/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)


`%not in%` <- function (x, table) is.na(match(x, table, nomatch=NA_integer_))

runCa <- function(dat, name , ncp=5, graph=T ){

    res.ca = CA(dat, ncp=5, graph=T)#,quanti.sup=c(1)) 

    write.infile(res.ca,file=paste0(name,".txt"))
    write.infile(summary(res.ca),file=paste0(name,"-summary.txt"))

    dev.copy2pdf(file=paste0(name,"-1.pdf"))
    dev.off()
    #dev.copy2pdf(file=paste0(name,"-2.pdf"))
    #dev.off()

    return(res.ca)

}

#!country %in% c("AUT","CZE","GER")

for (varHere in c("I"))
{
  for (yearHere  in  years[!years %in% c("2008","2009","2010")])
  {
    for(industryHere in c("TOT"))#industries[industries=="TOT"])
    {
      
      dgShareK %>%
        filter(year==yearHere, industry==industryHere, var==varHere,!product %in% c("GFCF","ICT","NonICT")) -> dt #%>%
      
      for (countryHere in countries)
      {
        if(NA %in% dt[dt$country==countryHere,]$value)
          dt %>% filter(!country==countryHere) -> dt
      }
      
      dt %>% spread(product,value) -> ds
      ds$country <- factor(ds$country)
      rownames(ds)<-ds$country
      ds <- ds[,!(names(ds) %in% c("year","industry","var"))]
      runCa(ds[,-1],paste(varHere, industryHere,yearHere,"ProdCountry"))
    }
    
  }
}


for (varHere in c("IqShareK", "InetShareK"))
{
  for (yearHere  in  years[!years %in% c("2008","2009","2010")])
  {
    for(industryHere in c("TOT"))#industries[industries=="TOT"])
    {
      
      dgShareK %>%
        filter(year==yearHere, !country=="FRA", industry==industryHere, var==varHere,!product %in% c("GFCF","ICT","NonICT")) -> dt #%>%
      
      for (countryHere in countries[!countries %in% c("FRA")]) # data FRA volumetric 100 is 2005 for Iq,K
      {
        if(NA %in% dt[dt$country==countryHere,]$value)
          dt %>% filter(!country==countryHere) -> dt
      }
      
      dt %>% spread(product,value) -> ds
      ds$country <- factor(ds$country)
      rownames(ds)<-ds$country
      ds <- ds[,!(names(ds) %in% c("year","industry","var"))]
      runCa(ds[,-1],paste(varHere, industryHere,yearHere,"ProdCountry"))
    }
    
  }
}

