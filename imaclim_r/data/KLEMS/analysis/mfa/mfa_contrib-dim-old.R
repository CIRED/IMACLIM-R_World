# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


lies <- lies12.IndProd
lies.perm2 <- lies12.ProdInd

contributions.dim <- function(lies, lies.perm2){
  
  freq.list <- unique(rownames(lies$freq$contrib))
  nfreq <- length(freq.list)
  
  freq.contrib <- t(colSums(lies$freq$contrib[rownames(lies$freq$contrib)==freq.list[1],]))
  row.names(freq.contrib) <- freq.list[1]
  
  
  for(rowHere in freq.list[2:nfreq])
  {
    tempRow <- t(colSums(lies$freq$contrib[rownames(lies$freq$contrib)==rowHere,]))
    row.names(tempRow) <- rowHere
    freq.contrib <-  rbind(freq.contrib, tempRow)
  }
  
  #-----------------------------------------------------------------------------------for perm2
  freq.list.perm2 <- unique(rownames(lies.perm2$freq$contrib))
  nfreq.perm2 <- length(freq.list.perm2)
  
  freq.contrib.perm2 <- t(colSums(lies.perm2$freq$contrib[rownames(lies.perm2$freq$contrib)==freq.list.perm2[1],]))
  row.names(freq.contrib.perm2) <- freq.list.perm2[1]
  
  
  for(rowHere in freq.list.perm2[2:nfreq.perm2])
  {
    tempRow <- t(colSums(lies.perm2$freq$contrib[rownames(lies.perm2$freq$contrib)==rowHere,]))
    row.names(tempRow) <- rowHere
    freq.contrib.perm2 <-  rbind(freq.contrib.perm2, tempRow)
  }
  
  #------------------------------------------------------Ind-Prod contributions to the dimensions, individuals
  #countryHere="USA"
  
  #row.names(lies$ind$contrib) <- c("Real\\ estate", "RE\\ Business", "Agri", "Mining", "Manufact", "Elec Gas", "Construc","Trans","Comm", "Finance", "Community", "Sales" )
  row.names(lies$ind$contrib) <-industryLabels12
  
  eigenvalue.random <- max(1/(dim(lies$ind$coord)[1]),1/(dim(lies.perm2$ind$coord)[1])) #what ?
  dimensions.row <- "\\begin{alignat}{4}"
  d = 1 
  #while (d < dim(lies$eig)[1])
  while (d < 11)
  { 
    if (lies$eig[d, "eigenvalue"] > eigenvalue.random/2) #determine the number of dimensions to be included
    {
      contrib.row.random <- 100/dim(lies$ind$coord)[1]
      d.ordered <- sort(lies$ind$contrib[,d], decreasing=TRUE)
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
    contrib.group.random <- 100/dim(lies$group$contrib)[1]
    d.ordered <- sort(lies$group$contrib[,d], decreasing=TRUE)
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
  #while (d < dim(lies$eig)[1])
  while (d < 11)
  { 
    if (lies$eig[d, "eigenvalue"] > eigenvalue.random/2) #determine the number of dimensions to be included
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
  
  
  #-----------------------------------------------------Prod-Ind contributions to the dimensions, individuals
  dimensions.col <- "\\begin{alignat}{4}"
  d = 1
  #while (d < dim(result.ca$eig)[1]) 
  while (d < 8)
  { 
    if (lies.perm2$eig[d, "eigenvalue"] > eigenvalue.random) #determine the number of dimensions to be included
    {
      contrib.col.random <- 100/dim(lies.perm2$ind$coord)[1]
      d.ordered <- sort(lies.perm2$ind$contrib[,d], decreasing=TRUE)
      d.ordered.contrib <- round(d.ordered[d.ordered>contrib.col.random/4],digits=1)
      
      if(!length(d.ordered.contrib) > 2)
      {
        d.ordered.contrib <- round(d.ordered[1:3],digits=1)
      }
      
      text <- paste(paste(paste("&","\\mathrm{","dim","}",sep=""),d,sep=""),paste(paste(d.ordered.contrib,paste("\\mathrm{",names(d.ordered.contrib),"}", sep=""), sep=" * ")," " ,sep=" &&+\\ ",collapse=""), sep=" = ")
      text <- substr(text, 1, nchar(text)-6)
      
      dimensions.col <- paste(dimensions.col, "\\nonumber \\\\ \n", text)
      
    }
    d <- d+1
  }
  dimensions.col <- paste(dimensions.col, "\n", "\\end{alignat}")
  
  #------------------------------------------------------Prod-Ind contributions to the dimensions, frequencies
  
  #row.names(freq.contrib.perm2) <- c("Real\\ estate", "RE\\ Business", "Agri", "Mining", "Manufact", "Elec Gas", "Construc","Trans","Comm", "Finance", "Community", "Sales" )
  row.names(lies$ind$contrib) <-industryLabels12
  
  dimensions.col.freq <- "\\begin{alignat}{4}"
  d = 1 #look at 5 dimensions
  #while (d < dim(lies$eig)[1])
  while (d < 8)
  { 
    if (lies$eig[d, "eigenvalue"] > eigenvalue.random) #determine the number of dimensions to be included
    {
      contrib.row.random <- 100/nfreq.perm2
      d.ordered <- sort(freq.contrib.perm2[,d], decreasing=TRUE)
      d.ordered.contrib <- round(d.ordered[d.ordered>contrib.row.random/4],digits=1)
      
      if(!length(d.ordered.contrib) > 2)
      {
        d.ordered.contrib <- round(d.ordered[1:3],digits=1)
      }
      
      text <- paste(paste(paste("&","\\mathrm{","dim","}",sep=""),d,sep=""),paste(paste(d.ordered.contrib,paste("\\mathrm{",names(d.ordered.contrib),"}", sep=""), sep=" * ")," " ,sep=" &&+\\ ",collapse=""), sep=" = ")
      text <- substr(text, 1, nchar(text)-6)
      
      dimensions.col.freq <- paste(dimensions.col.freq, "\\nonumber \\\\ \n", text)
      
    }
    d <- d+1
  }
  dimensions.col.freq <- paste(dimensions.col.freq, "\n", "\\end{alignat}")
  #-----------------------------------------------------------------------------------
  
  title  <- paste("Contributions to the dimensions, Ind-Prod", countryHere,sep=", ")
  title2 <- paste("Contributions to the dimensions, Prod-Ind", countryHere,sep=", ")
  dimensions  <- paste(title,  "\n", dimensions.row, "\n", dimensions.row.freq, "\n",dimensions.group)
  dimensions2 <- paste(title2, "\n", dimensions.col, "\n" ,dimensions.col.freq, "\n")
  
  write(dimensions,file=paste(paste("I-dimensions_12x8",countryHere, sep="_"),"tex", sep="."))
}