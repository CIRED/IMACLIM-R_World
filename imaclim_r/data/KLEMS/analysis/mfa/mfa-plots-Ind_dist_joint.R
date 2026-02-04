// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

# Plot the coordinates if the normalized distance is smaller then 1.
colour_industries <- c("#A6CEE3", "#1F78B4", "#01665E", "#33A02C", "#FB9A99", "#E31A1C", "#FDBF6F", "#FF7F00", "#191970", "#6A3D9A", "#FFD700")
colour_products <- c("000000", "000000", "000000", "000000", "000000", "000000", "000000", "000000")
# The plot below works for any number of years (contingency tables) (yearVector of any length)
yearVector <- years[-c(39,40,41)]
nYears <- length(yearVector)


plotMFACT.Ind.joint <- function(dat1, dat2, name, dimA, dimB, quality)
{
  #################### Create dataframes input to the graphs for dat1 #####(industries)######################################## 
  ## Filter dataframe immediately on dimA, dimB and create column with distances of every individual to the 
  ## plane defined by dimA dimB.
  labelA = paste(colnames(dat1$group$coord)[dimA],"(", round(dat1$eig$per[dimA],2), "%)")
  labelB = paste(colnames(dat1$group$coord)[dimB],"(", round(dat1$eig$per[dimB],2), "%)")
  
  plot.partiel.dimAB <- dat1$ind$coord.partiel[,c(dimA,dimB)]
  colnames(plot.partiel.dimAB) <- c("Dim.A", "Dim.B")
  plot.partiel.dimAB$distance <- sqrt(rowSums(dat1$ind$coord.partiel[,-c(1:dimB)]^2))
  
  # the distance needs to be compared to the remaining variance in the cloud, measured by the inertia that has not 
  # been explianed yet after projecting on dim1 to dimB. It is measured by the sum of the eigenvalues of the 
  # dimensions on which has not been projected yet.
  
  unexplained.inertia <- sqrt(sum(dat1$eig$eigenvalue[-c(1:dimB)]))
  plot.partiel.dimAB$distance.norm <- plot.partiel.dimAB$distance/unexplained.inertia
  
  plot.partiel.dimAB$temp <- as.factor(rownames(plot.partiel.dimAB))
  plot.partiel.dimAB <- plot.partiel.dimAB %>% separate(temp, c("industry", "year"))
  plot.partiel.dimAB$industry <- as.factor(plot.partiel.dimAB$industry)
  plot.partiel.dimAB$year <- as.factor(plot.partiel.dimAB$year)
  
#---------------------------------------------------------------------  
  
  plot.dimAB <- data.frame(dat1$global.pca$ind$coord[,c(dimA,dimB)])
  colnames(plot.dimAB) <- c("Dim.A", "Dim.B")
  plot.dimAB$distance <- sqrt(rowSums(dat1$global.pca$ind$coord[,-c(1:dimB)]^2))
  
  nInd <- dim(dat1$global.pca$ind$coord)[1]
  # the distance needs to be compared to the remaining variance in the cloud, measured by the inertia that has not 
  # been explianed yet after projecting on dim1 to dimB. It is measured by the sum of the eigenvalues of the 
  # dimensions on which has not been projected yet.
  
  unexplained.inertia <- sqrt(sum(dat1$eig$eigenvalue[-c(1:dimB)]))
  plot.dimAB$distance.norm <- plot.dimAB$distance/unexplained.inertia
 
  plot.dimAB$industry <- as.factor(rownames(plot.dimAB))
  plot.dimAB$year <- as.factor(rep("centroid",nInd))
  
  plot.dimAB <- dplyr::bind_rows(plot.dimAB, plot.partiel.dimAB)
  plot.dimAB$year <- as.factor(plot.dimAB$year)
  
  #---------- only plot points with good quality of representation / if distance to plane > .. convert to NA  
  plot.dimAB$Dim.A <- with(plot.dimAB, ifelse(distance.norm  > quality, type.convert(as.character(Dim.A),na.strings = as.character(Dim.A)), Dim.A))
  plot.dimAB$Dim.B <- with(plot.dimAB, ifelse(distance.norm  > quality, type.convert(as.character(Dim.B),na.strings = as.character(Dim.B)), Dim.B))  
  
  dfHere1 <- plot.dimAB
  
  #################### Create dataframes input to the graphs for dat2 #####(products)######################################## 
  ## Filter dataframe immediately on dimA, dimB and create column with distances of every individual to the 
  ## plane defined by dimA dimB.
  labelA = paste(colnames(dat2$group$coord)[dimA],"(", round(dat2$eig$per[dimA],2), "%)")
  labelB = paste(colnames(dat2$group$coord)[dimB],"(", round(dat2$eig$per[dimB],2), "%)")
  
  plot.partiel.dimAB <- dat2$ind$coord.partiel[,c(dimA,dimB)]
  colnames(plot.partiel.dimAB) <- c("Dim.A", "Dim.B")
  plot.partiel.dimAB$distance <- sqrt(rowSums(dat2$ind$coord.partiel[,-c(1:dimB)]^2))
  
  # the distance needs to be compared to the remaining variance in the cloud, measured by the inertia that has not 
  # been explianed yet after projecting on dim1 to dimB. It is measured by the sum of the eigenvalues of the 
  # dimensions on which has not been projected yet.
  
  unexplained.inertia <- sqrt(sum(dat2$eig$eigenvalue[-c(1:dimB)]))
  plot.partiel.dimAB$distance.norm <- plot.partiel.dimAB$distance/unexplained.inertia
  
  plot.partiel.dimAB$temp <- as.factor(rownames(plot.partiel.dimAB))
  plot.partiel.dimAB <- plot.partiel.dimAB %>% separate(temp, c("product", "year"))
  plot.partiel.dimAB$product <- as.factor(plot.partiel.dimAB$product)
  plot.partiel.dimAB$year <- as.factor(plot.partiel.dimAB$year)
  
  #---------------------------------------------------------------------  
  
  plot.dimAB <- data.frame(dat2$global.pca$ind$coord[,c(dimA,dimB)])
  colnames(plot.dimAB) <- c("Dim.A", "Dim.B")
  plot.dimAB$distance <- sqrt(rowSums(dat2$global.pca$ind$coord[,-c(1:dimB)]^2))
  
  nProd <- dim(dat2$global.pca$ind$coord)[1]
  # the distance needs to be compared to the remaining variance in the cloud, measured by the inertia that has not 
  # been explianed yet after projecting on dim1 to dimB. It is measured by the sum of the eigenvalues of the 
  # dimensions on which has not been projected yet.
  
  unexplained.inertia <- sqrt(sum(dat2$eig$eigenvalue[-c(1:dimB)]))
  plot.dimAB$distance.norm <- plot.dimAB$distance/unexplained.inertia
  
  plot.dimAB$product <- as.factor(rownames(plot.dimAB))
  plot.dimAB$year <- as.factor(rep("centroid",nProd))
  
  plot.dimAB <- dplyr::bind_rows(plot.dimAB, plot.partiel.dimAB)
  plot.dimAB$year <- as.factor(plot.dimAB$year)
  
  #---------- only plot points with good quality of representation / if distance to plane > .. convert to NA  
  plot.dimAB$Dim.A <- with(plot.dimAB, ifelse(distance.norm  > quality, type.convert(as.character(Dim.A),na.strings = as.character(Dim.A)), Dim.A))
  plot.dimAB$Dim.B <- with(plot.dimAB, ifelse(distance.norm  > quality, type.convert(as.character(Dim.B),na.strings = as.character(Dim.B)), Dim.B))  
  
  dfHere2 <- plot.dimAB
  
  ############################## end defining input dataframes to plots #######################################################
  
  colNameA <- colnames(dfHere1[1])
  colNameB <- colnames(dfHere1[2])
  #--------------------------------------------------------------------------- the separate plots

    p <-  ggplot(dfHere1, aes_string(x=colNameA,y=colNameB)) +
      geom_path(size=0.5, data=subset(dfHere1,!year %in% c("centroid")),aes(colour=industry)) +
      geom_point(size=3, data=subset(dfHere1,year %in% c(yearVector[1],yearVector[nYears])), aes(colour=industry, shape=factor(year))) +
      geom_text(data=subset(dfHere1,year %in% c(yearVector[1])), aes(label=year, colour=industry),hjust=1, vjust=-1, size = 3) +
      geom_text(data=subset(dfHere1,year %in% c(yearVector[nYears])), aes(label=year, colour=industry),hjust=-0.2, vjust=1.1, size = 3) +
      geom_point(shape=8, size=2, data=subset(dfHere1,year %in% c("centroid")), aes(colour=industry)) +
      #xlim(-2.5,2.5) +
      #ylim(-2.5,2.5) +
      geom_point(shape=8, size=2, data=subset(dfHere2,year %in% c("centroid"))) +
      geom_text(data=subset(dfHere2,year %in% c("centroid")), aes(label=product),hjust=1, vjust=1.8, size = 3) +
      ggtitle(paste("All industries", "$ind$coord",sep=", ")) +
      theme(plot.title = element_text(size = 12)) +
      labs(x=labelA, y=labelB) +
      scale_colour_manual(values=colour_industries)
    #scale_colour_brewer(palette = "BrBG")
    print(p)
    ggsave(paste0(name,"_ind_dim",dimA,"-",dimB,".pdf"), width = 20, height = 16, units = c("cm"), dpi = 300)
    
    p <-  ggplot(dfHere2, aes_string(x=colNameA,y=colNameB)) +
      geom_path(size=0.5, data=subset(dfHere2,!year %in% c("centroid")),aes(colour=product)) +
      geom_point(size=3, data=subset(dfHere2,year %in% c(yearVector[1],yearVector[nYears])), aes(colour=product, shape=factor(year))) +
      geom_text(data=subset(dfHere2,year %in% c(yearVector[1])), aes(label=year, colour=product),hjust=1, vjust=-1, size = 3) +
      geom_text(data=subset(dfHere2,year %in% c(yearVector[nYears])), aes(label=year, colour=product),hjust=-0.2, vjust=1.1, size = 3) +
      geom_point(shape=8, size=2, data=subset(dfHere2,year %in% c("centroid")), aes(colour=product)) +
      #xlim(-2.5,2.5) +
      #ylim(-2.5,2.5) +
      geom_point(shape=8, size=2, data=subset(dfHere1,year %in% c("centroid"))) +
      geom_text(data=subset(dfHere1,year %in% c("centroid")), aes(label=industry),hjust=1, vjust=1.8, size = 3) +
      ggtitle(paste("All products", "$ind$coord",sep=", ")) +
      theme(plot.title = element_text(size = 12)) +
      labs(x=labelA, y=labelB) +
      #scale_colour_manual(values=colour_products)
      scale_colour_brewer(palette = "YlOrBr")
    print(p)
    ggsave(paste0(name,"_prod_dim",dimA,"-",dimB,".pdf"), width = 20, height = 16, units = c("cm"), dpi = 300)
    
    dfHere1$year <- as.numeric(as.character(dfHere1$year))
    dfHere2$year <- as.numeric(as.character(dfHere2$year))
    #dfHere[,colnames(dfHere)==colNameA] <- as.numeric(as.character(dfHere[,colnames(dfHere)==colNameA]))
    #dfHere[,colnames(dfHere)==colNameB] <- as.numeric(as.character(dfHere[,colnames(dfHere)==colNameB]))
    
    for (industryHere in unique(dfHere1$industry))
    {
      temp1 <- subset(dfHere1, industry==industryHere)
      if(!all(is.na(temp1$Dim.A)))
      {
        p <-  ggplot(temp1, aes_string(x=colNameA,y=colNameB)) +
          geom_point(size=2, data=subset(temp1, !is.na(year)), aes(colour=year)) +
          geom_point(shape=17, data=subset(dfHere1,industry==industryHere & year %in% c(yearVector[1],yearVector[nYears])), size=4, aes(colour=year)) +
          geom_text(data=subset(dfHere1, industry==industryHere & year %in% c(yearVector[1],yearVector[nYears])), aes(label=year),hjust=0, vjust=0, size = 3) +
          geom_path(data=subset(temp1, !is.na(year)), aes(colour=year)) +
          geom_point(shape=8, size=2, data=subset(temp1,is.na(year))) +
          #xlim(-2.5,2.5) +
          #ylim(-2.5,2.5) +
          labs(x = paste("Dim",dimA,sep="."), y = paste("Dim",dimB,sep=".")) +
          ggtitle(paste(industryHere, "$ind$coord",sep=", ")) +
          theme(plot.title = element_text(size = 12)) +
          scale_colour_gradient()
        print(p)
        ggsave(paste0(name,"_ind_",industryHere,"_dim",dimA,"-",dimB,".pdf"),width = 16, height = 12, units = c("cm"), dpi = 300)
      }
    }
    
    for (productHere in unique(dfHere2$product))
    {
      temp1 <- subset(dfHere2, product==productHere)
      if(!all(is.na(temp1$Dim.A)))
      {
        p <-  ggplot(temp1, aes_string(x=colNameA,y=colNameB)) +
          geom_point(size=2, data=subset(temp1, !is.na(year)), aes(colour=year)) +
          geom_point(shape=17, data=subset(dfHere2,product==productHere & year %in% c(yearVector[1],yearVector[nYears])), size=4, aes(colour=year)) +
          geom_text(data=subset(dfHere2, product==productHere & year %in% c(yearVector[1],yearVector[nYears])), aes(label=year),hjust=0, vjust=0, size = 3) +
          geom_path(data=subset(temp1, !is.na(year)), aes(colour=year)) +
          geom_point(shape=8, size=2, data=subset(temp1,is.na(year))) +
          #xlim(-2.5,2.5) +
          #ylim(-2.5,2.5) +
          labs(x = paste("Dim",dimA,sep="."), y = paste("Dim",dimB,sep=".")) +
          ggtitle(paste(productHere, "$ind$coord",sep=", ")) +
          theme(plot.title = element_text(size = 12)) +
          scale_colour_gradient()
        print(p)
        ggsave(paste0(name,"_prod_",productHere,"_dim",dimA,"-",dimB,".pdf"),width = 16, height = 12, units = c("cm"), dpi = 300)
      }
    }
  
  
  #--------------------------------------------------------------------------- the joint plots
    p <-  ggplot(dfHere1, aes_string(x=colNameA,y=colNameB)) +
      geom_point(size=3, data=subset(dfHere1,is.na(year)), colour="darkblue") +
      geom_text(size=4, data=subset(dfHere1,is.na(year)), aes(label=industry), hjust=1.5, vjust=2, colour="darkblue") +
      #xlim(-2.5,2.5) +
      #ylim(-2.5,2.5) +
      geom_point(size=3, data=subset(dfHere2,is.na(year)), colour="black") +
      geom_text(size=4, data=subset(dfHere2,is.na(year)), aes(label=product), hjust=1.5, vjust=2, colour="black") +
      ggtitle(paste(name, " industries and products, compromise", sep=",")) +
      theme(plot.title = element_text(size = 12)) +
      labs(x=labelA, y=labelB) 
    print(p)
    ggsave(paste0(name,"_joint_compromise_dim",dimA,"-",dimB,".pdf"), width = 20, height = 16, units = c("cm"), dpi = 300)
    
    
    
    p <-  ggplot(dfHere1, aes_string(x=colNameA,y=colNameB)) +
      geom_path(size=0.5, data=subset(dfHere1,!year %in% c("centroid")),aes(colour=industry)) +
      geom_point(size=3, data=subset(dfHere1,year %in% c(yearVector[1],yearVector[nYears])), aes(colour=industry, shape=factor(year))) +
      geom_text(data=subset(dfHere1,year %in% c(yearVector[1])), aes(label=year),hjust=1, vjust=-1, size = 3) +
      geom_text(data=subset(dfHere1,year %in% c(yearVector[nYears])), aes(label=year),hjust=-0.2, vjust=1.1, size = 3) +
      geom_point(shape=8, size=2, data=subset(dfHere1,year %in% c("centroid")), aes(colour=industry)) +
      #xlim(-2.5,2.5) +
      #ylim(-2.5,2.5) +
      #geom_path(size=0.5, data=subset(dfHere2[,colnames(dfHere2) %in% c(colNameA, colNameB)])) + #,aes(colour=product)) +
      geom_point(size=0.5, data=subset(dfHere2,!year %in% c("centroid")), aes_string(x=colNameA,y=colNameB), colour="grey") + #,aes(colour=product)) +
      geom_point(shape=8, size=2, data=subset(dfHere2,is.na(year)), color="darkgrey") +
      geom_text(data=subset(dfHere2,is.na(year)), aes(label=product), hjust=1, vjust=1.8, size = 3, colour="darkblue") +
      ggtitle(paste("All industries", "$ind$coord",sep=", ")) +
      theme(plot.title = element_text(size = 12)) +
      labs(x=labelA, y=labelB) +
      scale_colour_manual(values=colour_industries)
    #scale_colour_brewer(palette = "BrBG")
    print(p)
    ggsave(paste0(name,"_joint_dim",dimA,"-",dimB,".pdf"), width = 20, height = 16, units = c("cm"), dpi = 300)
    
    
    p <-  ggplot(dfHere2, aes_string(x=colNameA,y=colNameB)) +
      geom_path(size=0.5, data=subset(dfHere2,!year %in% c("centroid")),aes(colour=product)) +
      geom_point(size=3, data=subset(dfHere2,year %in% c(yearVector[1],yearVector[nYears])), aes(colour=product, shape=factor(year))) +
      geom_text(data=subset(dfHere2,year %in% c(yearVector[1])), aes(label=year),hjust=1, vjust=-1, size = 3) +
      geom_text(data=subset(dfHere2,year %in% c(yearVector[nYears])), aes(label=year),hjust=-0.2, vjust=1.1, size = 3) +
      geom_point(shape=8, size=2, data=subset(dfHere2,year %in% c("centroid")), aes(colour=product)) +
      #xlim(-2.5,2.5) +
      #ylim(-2.5,2.5) +
      #geom_path(size=0.5, data=subset(dfHere2[,colnames(dfHere2) %in% c(colNameA, colNameB)])) + #,aes(colour=product)) +
      geom_point(size=0.5, data=subset(dfHere1,!year %in% c("centroid")), aes_string(x=colNameA,y=colNameB), colour="grey") + #,aes(colour=product)) +
      geom_point(shape=8, size=2, data=subset(dfHere1,is.na(year)), color="darkgrey") +
      geom_text(data=subset(dfHere1,is.na(year)), aes(label=industry), hjust=1, vjust=1.8, size = 3, colour="darkblue") +
      ggtitle(paste("All industries", "$ind$coord",sep=", ")) +
      theme(plot.title = element_text(size = 12)) +
      labs(x=labelA, y=labelB) +
      #scale_colour_manual(values=colour_industries)
      scale_colour_brewer(palette = "YlOrBr")
    print(p)
    ggsave(paste0(name,"_joint_v2_dim",dimA,"-",dimB,".pdf"), width = 20, height = 16, units = c("cm"), dpi = 300)
    
    
  }

#----------------------------

folder <- paste0(MFA,"/plots_Prod-Ind-Joint-share")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)


plotMFACT.Ind.joint(lies, lies.perm2,"USA-1970-2007", 1, 2, quality = 10)
plotMFACT.Ind.joint(lies, lies.perm2,"USA-1970-2007", 2, 3, quality = 10)
plotMFACT.Ind.joint(lies, lies.perm2,"USA-1970-2007", 3, 4, quality = 10)
plotMFACT.Ind.joint(lies, lies.perm2,"USA-1970-2007", 4, 5, quality = 10)

