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
    write.infile(summary(res.ca,file=paste0(name,"-summary.txt")))

    dev.copy2pdf(file=paste0(name,"-1.pdf"))
    dev.off()
    #dev.copy2pdf(file=paste0(name,"-2.pdf"))
    #dev.off()

    return(res.ca)

}

#!country %in% c("AUT","CZE","GER")
#This is not ok, I is in different units overs countries (euro, dollar)

for (yearHere  in years) #1970, 1980, 1990, 2001, 2007   
{
  for(industryHere in industries[industries=="TOT"])
  {
    
    dgAgg %>%
      filter(year==yearHere, industry==industryHere, var=="I",!product %in% c("GFCF","ICT","NonICT")) -> dt #%>%
      
      for (countryHere in countries)
      {
        if(NA %in% dt[dt$country==countryHere,]$value)
          dt %>% filter(!country==countryHere) -> dt
      }
    
      dt %>% spread(product,value) -> ds
      ds$country <- factor(ds$country)
      rownames(ds)<-ds$country
      ds <- ds[,!(names(ds) %in% c("year","industry","var"))]
      runCa(ds[,-1],paste(industryHere,yearHere,"ProdCountry"))
  }
  
}