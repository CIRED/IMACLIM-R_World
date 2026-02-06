# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

folder <- paste0(CA,"/reducedSystemProdInd/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

`%not in%` <- function (x, table) is.na(match(x, table, nomatch=NA_integer_))

runCa <- function(dat, name , ncp=5, graph=T ){

    res.ca = CA(dat, ncp=5, graph=T)#,quanti.sup=c(1)) 

    write.infile(res.ca,file=paste0(name,".txt"))
    summary(res.ca,file=paste0(name,"-summary.txt"))

    dev.copy2pdf(file=paste0(name,".pdf"))
    dev.off()
    #dev.copy2pdf(file=paste0(name,"-2.pdf"))
    #dev.off()

    return(res.ca)
}
#-----------------------------------------------------------------------

for (yearHere  in years[c(1,11,21,32,38)]) #c(1,11,21,32,38) 1970, 1980, 1990, 2001, 2007   
{
for(countryHere in c("USA","FRA"))
  {

dgAgg %>%
  filter(year==yearHere, country==countryHere,var=="I",!product %in% c("GFCF","ICT","NonICT"), industry %in% c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ")) -> dt #%>%

  if(NA %not in% dt$value)  
    {
  dt %>% spread(product,value) -> dt
    dt$industry <- factor(dt$industry, c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ"), labels=c("Agri","Mining","Manufacturing","Elec Gas Wtr","Construction","Sale","Transport Communication","Finance","Real estate","Real Estate Business","Community"))
rownames(dt)<-dt$industry
dt <- dt[,!(names(dt) %in% c("year","country","var"))]
result.ca <- runCa(dt[,-1],paste(countryHere,yearHere,"ProdInd", sep="_"))
pdf(paste(paste(countryHere,yearHere,"ProdInd", "dim2-3",sep="_"),"pdf",sep="."))
plot(result.ca, axes=c(2,3))
dev.off()
    }


#------------------------------------------------------contributions to the dimensions, rows

row.names(result.ca$row$contrib) <- c("Real\\ estate", "RE\\ Business", "Agri", "Mining", "Manufact", "Elec Gas", "Construc","TransComm", "Finance", "Community", "Sale" )

eigenvalue.random <- max(1/(dim(dt[,-1])[1]-1),1/(dim(dt[,-1])[2]-1))
dimensions.row <- "\\begin{alignat}{4}"
d = 1
while (d < dim(result.ca$eig)[1]) 
{ 
  if (result.ca$eig[d, "eigenvalue"] > eigenvalue.random) #determine the number of dimensions to be included
  {
    contrib.row.random <- 100/dim(dt[,-1])[1]
    d.ordered <- sort(result.ca$row$contrib[,d], decreasing=TRUE)
    d.ordered.contrib <- round(d.ordered[d.ordered>contrib.row.random],digits=1)
    
    text <- paste(paste(paste("&","\\mathrm{","dim","}",sep=""),d,sep=""),paste(paste(d.ordered.contrib,paste("\\mathrm{",names(d.ordered.contrib),"}", sep=""), sep=" * ")," " ,sep=" &&+\\ ",collapse=""), sep=" = ")
    text <- substr(text, 1, nchar(text)-6)
    
    dimensions.row <- paste(dimensions.row, "\\nonumber \\\\ \n", text)
     
  }
  d <- d+1
}
dimensions.row <- paste(dimensions.row, "\n", "\\end{alignat}")

#-----------------------------------------------------contributions to the dimensions, columns
dimensions.col <- "\\begin{alignat}{4}"
d = 1
while (d < dim(result.ca$eig)[1]) 
{ 
  if (result.ca$eig[d, "eigenvalue"] > eigenvalue.random) #determine the number of dimensions to be included
  {
    contrib.col.random <- 100/dim(dt[,-1])[1]
    d.ordered <- sort(result.ca$col$contrib[,d], decreasing=TRUE)
    d.ordered.contrib <- round(d.ordered[d.ordered>contrib.col.random],digits=1)
    
    text <- paste(paste(paste("&","\\mathrm{","dim","}",sep=""),d,sep=""),paste(paste(d.ordered.contrib,paste("\\mathrm{",names(d.ordered.contrib),"}", sep=""), sep=" * ")," " ,sep=" &&+\\ ",collapse=""), sep=" = ")
    text <- substr(text, 1, nchar(text)-6)
    
    dimensions.col <- paste(dimensions.col, "\\nonumber \\\\ \n", text)
    
  }
  d <- d+1
}
dimensions.col <- paste(dimensions.col, "\n", "\\end{alignat}")

title <- paste("Contributions to the dimensions",countryHere,yearHere,sep=", ")

dimensions <- paste(title, "\n",dimensions.row, "\n", dimensions.col)

write(dimensions,file=paste(paste("I-dimensions",countryHere, yearHere, sep="_"),"tex", sep=".")) 

  }
}





#--------------------------------------------------------------------same analysis but on data - RStruc, -Real estate

#for (yearHere  in years[c(38)]) # c(1,11,21,32,38) 1970, 1980, 1990, 2001, 2007   
#{
#  for(countryHere in "USA")
#  {
#    dgAgg %>%
#      filter(year==yearHere, country==countryHere,var=="I",!product %in% c("GFCF","ICT","NonICT","RStruc"), industry %in% c("AtB","C","D","E","F","GtH","I","J","71t74","LtQ")) -> dt #%>%
    
#    if(NA %not in% dt$value)  
#    {
#      dt %>% spread(product,value) -> dt
#      dt$industry <- factor(dt$industry, c("AtB","C","D","E","F","GtH","I","J","71t74","LtQ"), labels=c("Agri","Mining","Manufacturing","Elec Gas Wtr","Construction","Sale","Transport Communication","Finance","Real Estate Business","Community"))
#      rownames(dt)<-dt$industry
#      dt <- dt[,!(names(dt) %in% c("year","country","var"))]
#      runCa(dt[,-1],paste(countryHere,yearHere,"ProdInd_noResCon", sep="_"))
#    }
#  }
#}

