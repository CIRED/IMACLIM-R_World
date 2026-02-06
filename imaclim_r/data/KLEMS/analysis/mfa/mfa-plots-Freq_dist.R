# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

# Plot the coordinates if the normalized distance is smaller then 1.
colour_industries <- c("#A6CEE3", "#1F78B4", "#01665E", "#33A02C", "#FB9A99", "#E31A1C", "#FDBF6F", "#FF7F00", "#191970", "#6A3D9A", "#FFD700")
# The plot below works for any number of years (contingency tables) (yearVector of any length)

plotMFACT.Ind <- function(dat, name, dimA, dimB,quality)
{
  ## Filter dataframe immediately on dimA, dimB and create column with distances of every individual to the 
  ## plane defined by dimA dimB.
  labelA = paste(colnames(dat$group$coord)[dimA],"(", round(dat$eig$per[dimA],2), "%)")
  labelB = paste(colnames(dat$group$coord)[dimB],"(", round(dat$eig$per[dimB],2), "%)")
  
  plot.partiel.dimAB <- dat$ind$coord.partiel[,c(dimA,dimB)]
  colnames(plot.partiel.dimAB) <- c("Dim.A", "Dim.B")
  plot.partiel.dimAB$distance <- sqrt(rowSums(dat$ind$coord.partiel[,-c(1:dimB)]^2))
  
  # the distance needs to be compared to the remaining variance in the cloud, measured by the inertia that has not 
  # been explianed yet after projecting on dim1 to dimB. It is measured by the sum of the eigenvalues of the 
  # dimensions on which has not been projected yet.
  
  unexplained.inertia <- sqrt(sum(dat$eig$eigenvalue[-c(1:dimB)]))
  plot.partiel.dimAB$distance.norm <- plot.partiel.dimAB$distance/unexplained.inertia
  
  plot.partiel.dimAB$temp <- as.factor(rownames(plot.partiel.dimAB))
  plot.partiel.dimAB <- plot.partiel.dimAB %>% separate(temp, c("industry", "year"))
  plot.partiel.dimAB$industry <- as.factor(plot.partiel.dimAB$industry)
  plot.partiel.dimAB$year <- as.factor(plot.partiel.dimAB$year)
  
#---------------------------------------------------------------------  
  
  plot.dimAB <- data.frame(dat$global.pca$ind$coord[,c(dimA,dimB)])
  colnames(plot.dimAB) <- c("Dim.A", "Dim.B")
  plot.dimAB$distance <- sqrt(rowSums(dat$global.pca$ind$coord[,-c(1:dimB)]^2))
  
  # the distance needs to be compared to the remaining variance in the cloud, measured by the inertia that has not 
  # been explianed yet after projecting on dim1 to dimB. It is measured by the sum of the eigenvalues of the 
  # dimensions on which has not been projected yet.
  
  unexplained.inertia <- sqrt(sum(dat$eig$eigenvalue[-c(1:dimB)]))
  plot.dimAB$distance.norm <- plot.dimAB$distance/unexplained.inertia
 
  plot.dimAB$industry <- as.factor(rownames(plot.dimAB))
  plot.dimAB$year <- as.factor(rep("centroid",length(industryVector)))
  
  plot.dimAB <- dplyr::bind_rows(plot.dimAB, plot.partiel.dimAB)
  plot.dimAB$year <- as.factor(plot.dimAB$year)
  
  #---------- only plot points with good quality of representation / if distance to plane > .. convert to NA  
  plot.dimAB$Dim.A <- with(plot.dimAB, ifelse(distance.norm  > quality, type.convert(as.character(Dim.A),na.strings = as.character(Dim.A)), Dim.A))
  plot.dimAB$Dim.B <- with(plot.dimAB, ifelse(distance.norm  > quality, type.convert(as.character(Dim.B),na.strings = as.character(Dim.B)), Dim.B))  
  
  dfHere <- plot.dimAB
  colNameA <- colnames(dfHere[1])
  colNameB <- colnames(dfHere[2])
  
  p <-  ggplot(dfHere, aes_string(x=colNameA,y=colNameB)) +
    geom_path(size=0.5, data=subset(dfHere,!year %in% c("centroid")),aes(colour=industry)) +
    geom_point(size=3, data=subset(dfHere,year %in% c(yearVector[1],yearVector[nYears])), aes(colour=industry, shape=factor(year))) +
    geom_text(data=subset(dfHere,year %in% c(yearVector[1])), aes(label=year),hjust=1, vjust=-1, size = 3) +
    geom_text(data=subset(dfHere,year %in% c(yearVector[nYears])), aes(label=year),hjust=-0.2, vjust=1.1, size = 3) +
    geom_point(shape=8, size=2, data=subset(dfHere,year %in% c("centroid")), aes(colour=industry)) +
    #xlim(-2.5,2.5) +
    #ylim(-2.5,2.5) +
    ggtitle(paste("All industries", "$ind$coord",sep=", ")) +
    theme(plot.title = element_text(size = 12)) +
    labs(x=labelA, y=labelB) +
    scale_colour_manual(values=colour_industries)
    #scale_colour_brewer(palette = "BrBG")
  print(p)
  ggsave(paste0(name,"_ind-coord_v2_dim",dimA,"-",dimB,".pdf"), width = 20, height = 16, units = c("cm"), dpi = 300)
  
  
  
  #dfHere <- dat$ind$coord[,c(dimA,dimB)]
  #dfHere <- cbind(dfHere, rep(yearsD,each=8), rownames(dat$freq$coord))
  #colnames(dfHere)[3] <- "year"
  #colnames(dfHere)[4] <- "product"
  #dfHere <- data.frame(dfHere)
  #colNameA <- colnames(dfHere[1])
  #colNameB <- colnames(dfHere[2])
  
  dfHere$year <- as.numeric(as.character(dfHere$year))
  #dfHere[,colnames(dfHere)==colNameA] <- as.numeric(as.character(dfHere[,colnames(dfHere)==colNameA]))
  #dfHere[,colnames(dfHere)==colNameB] <- as.numeric(as.character(dfHere[,colnames(dfHere)==colNameB]))
  
  
  for (industryHere in unique(dfHere$industry))
  {
    temp <- subset(dfHere, industry==industryHere)
    if(!all(is.na(data$Dim.A)))
    {
      p <-  ggplot(data, aes_string(x=colNameA,y=colNameB)) +
        geom_point(size=2, data=subset(temp, !is.na(year)), aes(colour=year)) +
        geom_point(shape=17, data=subset(dfHere,industry==industryHere & year %in% c(yearVector[1],yearVector[nYears])), size=4, aes(colour=year)) +
        geom_text(data=subset(dfHere, industry==industryHere & year %in% c(yearVector[1],yearVector[nYears])), aes(label=year),hjust=0, vjust=0, size = 3) +
        geom_path(data=subset(temp, !is.na(year)), aes(colour=year)) +
        geom_point(shape=8, size=2, data=subset(temp,is.na(year))) +
        #xlim(-2.5,2.5) +
        #ylim(-2.5,2.5) +
        labs(x = paste("Dim",dimA,sep="."), y = paste("Dim",dimB,sep=".")) +
        ggtitle(paste(industryHere, "$ind$coord",sep=", ")) +
        theme(plot.title = element_text(size = 12)) +
        scale_colour_gradient()
      print(p)
      #ggsave(paste0(name,"_ind-coord_",industryHere,"_dim",dimA,"-",dimB,".pdf"),width = 16, height = 12, units = c("cm"), dpi = 300)
    }
  }
}
#----------------------------

#plotMFACT.Ind(lies, "USA-1979-1989", 1, 2)
#plotMFACT.Ind(lies, "USA-1979-1989", 2, 3)
#plotMFACT.Ind(lies, "USA-1979-1989", 3, 4)
#plotMFACT.Ind(lies, "USA-1979-1989", 4, 5)

