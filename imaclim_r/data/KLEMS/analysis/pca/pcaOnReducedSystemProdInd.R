// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

folder <- paste0(PCA,"/reducedSystemProdInd/") #aka WhoInvests
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

`%not in%` <- function (x, table) is.na(match(x, table, nomatch=NA_integer_))

runPca <- function(dat, name , scale.unit=TRUE, ncp=5, graph=T ){

    res.pca = PCA(dat, scale.unit=TRUE, ncp=5, graph=T)#,quanti.sup=c(1)) 

    write.infile(res.pca,file=paste0(name,".txt"))
    write.infile(summary(res.pca),file=paste0(name,"-summary.txt"))

    dev.copy2pdf(file=paste0(name,"-1.pdf"))
    dev.off()
    dev.copy2pdf(file=paste0(name,"-2.pdf"))
    dev.off()

    return(res.pca)

}


for (yearHere  in years[c(1,11,21,32,38)]) #1970, 1980, 1990, 2001, 2007   
{
for(countryHere in countries)
  {

dgAgg %>%
  filter(year==yearHere, country==countryHere,var=="I",!product %in% c("GFCF","ICT","NonICT"), industry %in% c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ")) -> dt #%>%

  if(NA %not in% dt$value)  
    {
  dt %>% spread(product,value) -> ds
  ds$industry <- factor(ds$industry, c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ"), labels=c("Agri","Mining","Manufacturing","Elec Gas Wtr","Construction","Sale","Transport Communication","Finance","Real estate","Real Estate Business","Community"))
rownames(ds)<-ds$industry
ds <- ds[,!(names(ds) %in% c("year","country","var"))]
runPca(ds[,-1],paste(countryHere,yearHere,"ProdInd"))
    }
  }

}

