// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


#lies <- lies12.IndProd
#lies.perm2 <- lies12.ProdInd

contributions.4dim <- function(dat,fileName)
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
  #-------------------------------------------
    dfHere <- data.frame(dat$group$contrib)
    dfHere$year <- as.integer(t(as.matrix(as.data.frame(strsplit(rownames(dfHere),"_"))))[,2])
    dfHere$country <- t(as.matrix(as.data.frame(strsplit(rownames(dfHere),"_"))))[,1]
    
    country.list <- unique(dfHere$country)
    year.list <- unique(dfHere$year)
    ncountry <- length(country.list)
    nyear <- length(year.list)

    temp.contrib <- dfHere[dfHere$country==country.list[1],] %>% select (-c(country,year))
    country.contrib <- t(colSums(temp.contrib))
    rownames(country.contrib) <- country.list[1]
    
    temp.contrib <- dfHere[dfHere$year==year.list[1],] %>% select (-c(country,year))
    year.contrib <- t(colSums(temp.contrib))
    rownames(year.contrib) <- year.list[1]
    
    for(rowHere in country.list[2:ncountry])
    {
      temp.contrib <- dfHere[dfHere$country==rowHere,] %>% select(-c(country,year))
      tempRow <- t(colSums(temp.contrib))
      row.names(tempRow) <- rowHere
      country.contrib <-  rbind(country.contrib, tempRow)
    }
    
    for(rowHere in year.list[2:nyear])
    {
      temp.contrib <- dfHere[dfHere$year==rowHere,] %>% select(-c(country,year))
      tempRow <- t(colSums(temp.contrib))
      row.names(tempRow) <- rowHere
      year.contrib <-  rbind(year.contrib, tempRow)
    }
    
#------------------------------------------------------Ind-Prod contributions to the dimensions, individuals
#countryHere="USA"

#row.names(dat$ind$contrib) <- c("Real\\ estate", "RE\\ Business", "Agri", "Mining", "Manufact", "Elec Gas", "Construc","Trans","Comm", "Finance", "Community", "Sales" )
  row.names(dat$ind$contrib) <-industryLabels12

  eigenvalue.random <- max(1/(dim(dat$ind$coord)[1]),1/(dim(dat$freq$coord)[1])) #what ?
  dimensions.row <- "\\begin{alignat}{4}"
  d = 1 
#while (d < dim(dat$eig)[1])
  while (d < 12)
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
  
  
  dimensions.group1 <- "\\begin{alignat}{4}"
  dimensions.group2 <- "\\begin{alignat}{4}"
  d = 1 
  while (d < 12)
  {
    contrib.group.random <- 100/dim(dat$group$contrib)[1]
    d.ordered1 <- sort(country.contrib[,d], decreasing=TRUE)
    d.ordered2 <- sort(year.contrib[,d], decreasing=TRUE)
    
    d.ordered1.contrib <- round(d.ordered1[d.ordered1>contrib.group.random],digits=2)
    d.ordered2.contrib <- round(d.ordered2[d.ordered2>contrib.group.random],digits=2)
    
    if(!length(d.ordered1.contrib) > 2)
    {
      d.ordered1.contrib <- round(d.ordered1[1:3],digits=2)
    }
    
    if(!length(d.ordered2.contrib) > 2)
    {
      d.ordered2.contrib <- round(d.ordered2[1:3],digits=2)
    }
  
    text1 <- paste(paste(paste("&","\\mathrm{","dim","}",sep=""),d,sep=""),paste(paste(d.ordered1.contrib,paste("\\mathrm{",names(d.ordered1.contrib),"}", sep=""), sep=" * ")," " ,sep=" &&+\\ ",collapse=""), sep=" = ")
    text1 <- substr(text1, 1, nchar(text1)-6)

    text2 <- paste(paste(paste("&","\\mathrm{","dim","}",sep=""),d,sep=""),paste(paste(d.ordered2.contrib,paste("\\mathrm{",names(d.ordered2.contrib),"}", sep=""), sep=" * ")," " ,sep=" &&+\\ ",collapse=""), sep=" = ")
    text2 <- substr(text2, 1, nchar(text2)-6)
    
    dimensions.group1 <- paste(dimensions.group1, "\\nonumber \\\\ \n", text1)
    dimensions.group2 <- paste(dimensions.group2, "\\nonumber \\\\ \n", text2)
    
    d <- d+1
  }

  dimensions.group1 <- paste(dimensions.group1, "\n", "\\end{alignat}")
  dimensions.group2 <- paste(dimensions.group2, "\n", "\\end{alignat}")
  
  #------------------------------------------------------Ind-Prod contributions to the dimensions, frequencies

  dimensions.row.freq <- "\\begin{alignat}{4}"
  d = 1 #look at 5 dimensions
  #while (d < dim(dat$eig)[1])
  while (d < 12)
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
  dimensions  <- paste(title,  "\n", dimensions.row, "\n", dimensions.row.freq, "\n", dimensions.group1, "\n", dimensions.group2)
  write(dimensions,file=paste(paste(fileName,"dimensions", sep="_"),"tex", sep="."))
}

