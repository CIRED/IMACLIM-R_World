# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


#lies <- lies12.IndProd
#lies.perm2 <- lies12.ProdInd

contributions.dim <- function(dat,fileName)
  {
  freq.list <- unique(rownames(dat$freq$contrib))
  nfreq <- length(freq.list)

  freq.contrib <- t(colSums(dat$freq$contrib[rownames(dat$freq$contrib)==freq.list[1],]))
  row.names(freq.contrib) <- freq.list[1]


  for(rowHere in freq.list[2:nfreq])
    {
    tempRow <- t(colSums(dat$freq$contrib[rownames(dat$freq$contrib)==rowHere,]))
    row.names(tempRow) <- rowHere
    freq.contrib <-  rbind(freq.contrib, tempRow)
    }


#------------------------------------------------------Ind-Prod contributions to the dimensions, individuals
#countryHere="USA"

#row.names(dat$ind$contrib) <- c("Real\\ estate", "RE\\ Business", "Agri", "Mining", "Manufact", "Elec Gas", "Construc","Trans","Comm", "Finance", "Community", "Sales" )
  row.names(dat$ind$contrib) <-industryLabels12

  eigenvalue.random <- max(1/(dim(dat$ind$coord)[1]),1/(dim(dat$freq$coord)[1])) #what ?
  dimensions.row <- "\\begin{alignat}{4}"
  d = 1 
#while (d < dim(dat$eig)[1])
  while (d < 11)
  { 
    if (dat$eig[d, "eigenvalue"] > eigenvalue.random/2) #determine the number of dimensions to be included
    {
      contrib.row.random <- 100/dim(dat$ind$coord)[1]
      d.ordered <- sort(dat$ind$contrib[,d], decreasing=TRUE)
      d.ordered.contrib <- round(d.ordered[d.ordered>contrib.row.random/4],digits=1)
    
      if(!length(d.ordered.contrib) > 2)
      {
        d.ordered.contrib <- round(d.ordered[1:3],digits=1)
      }
    
      text <- paste(paste(paste("&","\\mathrm{","dim","}",sep=""),d,sep=""),paste(paste(d.ordered.contrib,paste("\\mathrm{",names(d.ordered.contrib),"}", sep=""), sep=" * ")," " ,sep=" &&+\\ ",collapse=""), sep=" = ")
      text <- substr(text, 1, nchar(text)-6)
    
      dimensions.row <- paste(dimensions.row, "\\nonumber \\\\ \n", text)
      
    }
    d <- d+1
  }
  dimensions.row <- paste(dimensions.row, "\n", "\\end{alignat}")
#------------------------------------------------------Ind-Prod contributions to the dimensions, groups (=years)
  dimensions.group <- "\\begin{alignat}{4}"
  d = 1 
  while (d < 11)
  {
    contrib.group.random <- 100/dim(dat$group$contrib)[1]
    d.ordered <- sort(dat$group$contrib[,d], decreasing=TRUE)
    d.ordered.contrib <- round(d.ordered[d.ordered>contrib.group.random],digits=2)
  
    if(!length(d.ordered.contrib) > 2)
    {
      d.ordered.contrib <- round(d.ordered[1:3],digits=2)
    }
  
    text <- paste(paste(paste("&","\\mathrm{","dim","}",sep=""),d,sep=""),paste(paste(d.ordered.contrib,paste("\\mathrm{",names(d.ordered.contrib),"}", sep=""), sep=" * ")," " ,sep=" &&+\\ ",collapse=""), sep=" = ")
    text <- substr(text, 1, nchar(text)-6)
  
    dimensions.group <- paste(dimensions.group, "\\nonumber \\\\ \n", text)
  
    d <- d+1
  }

  dimensions.group <- paste(dimensions.group, "\n", "\\end{alignat}")
#------------------------------------------------------Ind-Prod contributions to the dimensions, frequencies

  dimensions.row.freq <- "\\begin{alignat}{4}"
  d = 1 #look at 5 dimensions
  #while (d < dim(dat$eig)[1])
  while (d < 11)
  { 
    if (dat$eig[d, "eigenvalue"] > eigenvalue.random/2) #determine the number of dimensions to be included
    {
      contrib.row.random <- 100/nfreq
      d.ordered <- sort(freq.contrib[,d], decreasing=TRUE)
      d.ordered.contrib <- round(d.ordered[d.ordered>contrib.row.random/4],digits=1)
    
      if(!length(d.ordered.contrib) > 2)
      {
        d.ordered.contrib <- round(d.ordered[1:3],digits=1)
      }
    
      text <- paste(paste(paste("&","\\mathrm{","dim","}",sep=""),d,sep=""),paste(paste(d.ordered.contrib,paste("\\mathrm{",names(d.ordered.contrib),"}", sep=""), sep=" * ")," " ,sep=" &&+\\ ",collapse=""), sep=" = ")
      text <- substr(text, 1, nchar(text)-6)
    
      dimensions.row.freq <- paste(dimensions.row.freq, "\\nonumber \\\\ \n", text)
    
    }
    d <- d+1
  }
  dimensions.row.freq <- paste(dimensions.row.freq, "\n", "\\end{alignat}")

#-----------------------------------------------------------------------------------
  title  <- paste("Contributions to the dimensions, Ind-Prod", fileName, sep=", ")
  dimensions  <- paste(title,  "\n", dimensions.row, "\n", dimensions.row.freq, "\n", dimensions.group)
  write(dimensions,file=paste(paste(fileName,"dimensions", sep="_"),"tex", sep="."))
}

