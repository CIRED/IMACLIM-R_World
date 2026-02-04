// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


# Function to create, from table dsAgg, an input-table for MFACT for multiple contingency tables (1 per year) 
#for 1 country, 1 variable, a vector of industry-levels and a vector of years.

dfInput.permutation1 <- function(inputdata, countryHere, varHere, yearVector, industryVector, productVector, share)
{
  temp2 <- inputdata %>% filter(country==countryHere, var==varHere, industry %in% industryVector, product %in% productVector) %>% spread(product,value)
  temp.mfact <- temp2 %>% filter(year==yearVector[1]) %>% select(c(-var, -year, -country))
  Rnames <- temp.mfact$industry
  temp.mfact <- temp.mfact %>% select(c(-industry)) 
  
  if(share)
  {
    temp.mfact <- data.frame(prop.table(as.matrix(temp.mfact),1))
  }
  
  for (yearHere in yearVector[-1])
  {
    temp.year <- temp2 %>% filter(year==yearHere) %>% select(c(-var, -year, -country, -industry)) 
    if(share)
    {
      temp.year <- data.frame(prop.table(as.matrix(temp.year),1))
    }
    temp.mfact <- bind_cols(temp.mfact,temp.year)
  }
  
  rownames(temp.mfact)    <- Rnames
  temp.mfact <- temp.mfact[match(industryVector,rownames(temp.mfact)),]
  nYears = length(yearVector) 
  nProd = length(productVector) 
  times = rep(nProd,nYears)
  newrow.years = rep(yearVector,times)
  temp.mfact <- rbind(temp.mfact,newrow.years)
  return(temp.mfact)
}

########-------------Definition of some output plots for MFACT
########-------------All the plot functions take as input the results of MFACT, i.e. dat <- MFA(something)
# The plot below works only if 2 years (2 contingency tables) are used (yearVector of length 1)
#plotMFACT <- function(dat,name, dimA, dimB, nProd){
#  labelA = paste(colnames(dat$freq$coord)[dimA],"(", round(dat$eig$per[dimA],2), "%)")
#  labelB = paste(colnames(dat$freq$coord)[dimB],"(", round(dat$eig$per[dimB],2), "%)")
  
# plot(dat$ind$coord[,dimA],dat$ind$coord[,dimB], pch=20,col="black", xlab=labelA, ylab=labelB)
#  text(  dat$ind$coord[, dimA], dat$ind$coord[,dimB], rownames(dat$ind$coord), pos= 4 ,col="black")
#  points(dat$freq$coord[1:nProd, dimA], dat$freq$coord[1:nProd,dimB], pch=18, col="red")
#  text(  dat$freq$coord[1:nProd, dimA], dat$freq$coord[1:nProd,dimB], rownames(dat$freq$coord), pos= 2 ,col="red")
#  points(dat$freq$coord[nProd+1:2*nProd, dimA], dat$freq$coord[nProd+1:2*nProd,dimB], pch=18, col="blue")
#  text(  dat$freq$coord[nProd+1:2*nProd, dimA], dat$freq$coord[nProd+1:2*nProd,dimB], rownames(dat$freq$coord), pos= 4 ,col="blue")
#  abline(h=0,lty=2)
#  abline(v=0,lty=2)
#  legend(x="topleft",pch=18, col=c("red","blue") ,legend=c("1970","2007"), text.col=c("red","blue"))
#  dev.copy2pdf(file=paste0(name,"_factorMap-dim",dimA,"-",dimB,".pdf"), width = 7, height = 7)
#  dev.off()
#}

# The plot below works for any number of years (contingency tables) (yearVector of any length)
plotMFACT.Group <- function(dat,name, dimA, dimB){
  labelA = paste(colnames(dat$group$coord)[dimA],"(", round(dat$eig$per[dimA],2), "%)")
  labelB = paste(colnames(dat$group$coord)[dimB],"(", round(dat$eig$per[dimB],2), "%)")
  
  dfHere <- data.frame(dat$group$coord)
  dfHere$year <- as.integer(rownames(dfHere))
  colNameA <- colnames(dfHere[dimA])
  colNameB <- colnames(dfHere[dimB])
  
  p <-  ggplot(dfHere, aes_string(x=colNameA,y=colNameB)) +
        geom_point(size=1.1, aes(colour=year)) +
        xlim(0,1) +
        ylim(0,1) +
        labs(x = labelA, y = labelB) +
        ggtitle("Groups representation") +
        theme(plot.title = element_text(size = 12)) +
        scale_colour_gradient()
  #print(p)
  ggsave(paste0(name,"_Groups-dim",dimA,"-",dimB,".pdf"))
}
###############################################################################################
# The plot below works for any number of years (contingency tables) (yearVector of any length)
# Plots temporal trajectories of frequencies in dimA dimA+1 plane
plotMFACT.Freq <- function(dat, name, dimA, dimB, nProd, colour_products, productVector){
  labelA = paste(colnames(dat$group$coord)[dimA],"(", round(dat$eig$per[dimA],2), "%)")
  labelB = paste(colnames(dat$group$coord)[dimB],"(", round(dat$eig$per[dimB],2), "%)")
  
  dfHere <- dat$freq$coord[,c(dimA,dimB)]
  dfHere <- cbind(dfHere, rep(yearVector,each=nProd), rownames(dat$freq$coord))
  colnames(dfHere)[3] <- "year"
  colnames(dfHere)[4] <- "product"
  dfHere <- data.frame(dfHere)
  colNameA <- colnames(dfHere[1])
  colNameB <- colnames(dfHere[2])
  
  dfHere$year <- as.numeric(as.character(dfHere$year))
  dfHere[,colnames(dfHere)==colNameA] <- as.numeric(as.character(dfHere[,colnames(dfHere)==colNameA]))
  dfHere[,colnames(dfHere)==colNameB] <- as.numeric(as.character(dfHere[,colnames(dfHere)==colNameB]))
  nYears = length(yearVector) 
  dfHere$product <- factor(dfHere$product, levels=productVector)
  dfHere <- dfHere[order(dfHere$product),]
  
  #plot below makes graph of temporal trajectory per product
  #for (productHere in unique(dfHere$product)) {
  #  p <-  ggplot(data=subset(dfHere, product==productHere), aes_string(x=colNameA,y=colNameB)) +
  #    geom_point(size=2,aes(colour=year)) +
  #    geom_point(shape=17, data=subset(dfHere,product==productHere & year %in% c(yearVector[1],yearVector[nYears])), size=4, aes(colour=year)) +
  #    geom_text(data=subset(dfHere,product==productHere & year %in% c(seq(yearVector[1],yearVector[nYears],10),yearVector[nYears])), aes(label=year),hjust=0, vjust=0, size = 3) +
  #    geom_path(data=subset(dfHere, product==productHere), aes(colour=year)) +
  #    labs(x = labelA, y = labelB) +
  #    ggtitle(paste(productHere, "$freq$coord",sep=", ")) +
  #    theme(plot.title = element_text(size = 12)) +
  #    scale_colour_gradient()
  #print(p)
  #  ggsave(paste0(name,"_freq-coord_",productHere,"_dim",dimA,"-",dimB,".pdf"),width = 16, height = 12, units = c("cm"), dpi = 300)
  #}
  
  #dfHere <- subset(dfHere, product %in% c("OCon", "TraEq", "OMach")) #partial graphs
  #colour_products <- colour_products[-1]
  
  p <-  ggplot(dfHere, aes_string(x=colNameA,y=colNameB)) +
        geom_hline(yintercept= 0, colour="#AAAAAA", size=0.5, linetype = "longdash") +
        geom_vline(xintercept=0, colour="#AAAAAA", size=0.5, linetype = "longdash") +
        geom_path(size=0.5, aes(colour=product)) +
        geom_point(size=3, data=subset(dfHere,year %in% c(yearVector[1],yearVector[nYears])), aes(colour=product, shape=factor(year))) +
        geom_text(data=subset(dfHere,year %in% c(yearVector[1])), aes(label=year),hjust=1, vjust=-1, size = 3) +
        geom_text(data=subset(dfHere,year %in% c(yearVector[nYears])), aes(label=year),hjust=-0.2, vjust=1.1, size = 3) +
        #geom_point(data=data.frame(dat$global.pca$ind$coord[,c(dimA,dimB)])) +
        #geom_text(data=data.frame(dat$global.pca$ind$coord[,c(dimA,dimB)]), aes(label = rownames(dat$global.pca$ind$coord[,c(dimA,dimB)])),hjust=-0.2, vjust=1.1, size = 3) +
        #xlim(-2.5,2.5) +
        #ylim(-2.5,2.5) +
        ggtitle(paste("All products", "$freq$coord",sep=", ")) +
        theme(plot.title = element_text(size = 12)) +
        scale_colour_manual(values=colour_products)
  #print(p)
  ggsave(paste0(name,"_freq-coord_dim",dimA,"-",dimB,".pdf"), width = 20, height = 16, units = c("cm"), dpi = 300)
}
###############################################################################################
# The plot below works for any number of years (contingency tables) (yearVector of any length)
# Plots temporal trajectories of individuals in dimA dimA+1 plane
plotMFACT.Ind <- function(dat,name, dimA, dimB, colour_industries,industryVector){
  #print(dimA)
  labelA = paste(colnames(dat$group$coord)[dimA],"(", round(dat$eig$per[dimA],2), "%)")
  labelB = paste(colnames(dat$group$coord)[dimB],"(", round(dat$eig$per[dimB],2), "%)")
  
  dfHere <- dat$ind$coord.partiel[,c(dimA,dimB)]
  dfHere$year <- as.integer(t(as.matrix(as.data.frame(strsplit(rownames(dfHere[1:dim(dfHere)[1],]),"[.]"))))[,2])
  dfHere$industry <- as.factor(t(as.matrix(as.data.frame(strsplit(rownames(dfHere[1:dim(dfHere)[1],]),"[.]"))))[,1])
  #dfHere <- cbind(dfHere, rep(yearsD,each=nProduct), rownames(dat$freq$coord))
  
  dfHere$industry <- factor(dfHere$industry, levels=industryVector) 
  dfHere <- dfHere[order(dfHere$industry),] 
  
  colNameA <- colnames(dfHere[1])
  colNameB <- colnames(dfHere[2])
  nYears = length(yearVector) 
  
  #plot below makes graph of temporal trajectory per industry, not very useful 
  # for (industryHere in unique(dfHere$industry)) {
  #  p <-  ggplot(data=subset(dfHere, industry==industryHere), aes_string(x=colNameA,y=colNameB)) +
  #    geom_point(size=2,aes(colour=year)) +
  #     geom_point(shape=17, data=subset(dfHere,industry==industryHere & year %in% c(yearVector[1],yearVector[nYears])), size=4, aes(colour=year)) +
  #     geom_text(data=subset(dfHere,industry==industryHere & year %in% c(seq(yearVector[1],yearVector[nYears],10),yearVector[nYears])), aes(label=year),hjust=0, vjust=0, size = 3) +
  #     geom_path(data=subset(dfHere,industry==industryHere), aes(colour=year)) +
  #     geom_point(data=data.frame(dat$global.pca$ind$coord[,c(dimA,dimB)])) +
  #     xlim(-2.5,2.5) +
  #     ylim(-2.5,2.5) +
  #     labs(x = labelA, y = labelB) +
  #    ggtitle(paste(industryHere, "$coord.partiel",sep=", ")) +
  #    theme(plot.title = element_text(size = 12)) +
  #    scale_colour_gradient()
  #  print(p)
  #  ggsave(paste0(name,"_coord-partiel_",industryHere,"_dim",dimA,"-",dimB,".pdf"),width = 16, height = 12, units = c("cm"), dpi = 300)
  #}
  
  #dfHere <- subset(dfHere, industry %in% c("C", "D", "E", "F")) #partial graphs
  #colour_industries <- colour_industries[-1] #partial graphs
  
  p <-  ggplot(dfHere, aes_string(x=colNameA,y=colNameB)) +
        geom_hline(yintercept= 0, colour="#AAAAAA", size=0.5,linetype = "longdash") +
        geom_vline(xintercept=0, colour="#AAAAAA", size=0.5, linetype = "longdash") +
        geom_path(size=0.5, aes(colour=industry)) +
        geom_point(size=3, data=subset(dfHere,year %in% c(yearVector[1],yearVector[nYears])), aes(colour=industry, shape=factor(year))) +
        geom_text(data=subset(dfHere,year %in% c(yearVector[1])), aes(label=year),hjust=1, vjust=-1, size = 3) +
        geom_text(data=subset(dfHere,year %in% c(yearVector[nYears])), aes(label=year),hjust=-0.2, vjust=1.1, size = 3) +
        #geom_point(data=data.frame(dat$global.pca$ind$coord[,c(dimA,dimB)])) +
        #geom_text(data=data.frame(dat$global.pca$ind$coord[,c(dimA,dimB)]), aes(label = rownames(dat$global.pca$ind$coord[,c(dimA,dimB)])),hjust=-0.2, vjust=1.1, size = 3) +
        #xlim(-2.5,2.5) +
        #ylim(-2.5,2.5) +
        ggtitle(paste("All industries", "$coord.partiel",sep=", ")) +
        theme(plot.title = element_text(size = 12)) +
        scale_colour_manual(values=colour_industries)
  #print(p)
  ggsave(paste0(name,"_coord-partiel_dim",dimA,"-",dimB,".pdf"), width = 20, height = 16, units = c("cm"), dpi = 300)
}
#############################################################################################

# The function runMFACT takes as argument a dataframe issued from dfInput
runMFACT <- function(dat, name, yearVector, industryVector, productVector, colour_industries, colour_products){
  nYears = length(yearVector)
  nProd  = length(productVector)
  nInd   = length(industryVector)
  res.mfact <- MFA(dat[-dim(dat)[1],], group=rep(nProd,nYears), type=rep("f",nYears), name.group=yearVector, ncp=10)
  
  write.infile(res.mfact, file=paste(name,"txt",sep="."))
  summary(res.mfact, file = paste("summary-",name,".txt",sep=""))
  dev.copy(pdf, file=paste0(name,"-1.pdf"))
  dev.off()
  #dev.copy(pdf, file=paste0(name,"-2.pdf"))
  #dev.off()
  #dev.copy(pdf, file=paste0(name,"-3.pdf"))
  #dev.off()
  #dev.copy2pdf(file=paste0(name,"-4.pdf"))
  #dev.off()
  #dev.copy2pdf(file=paste0(name,"-5.pdf"))
  #dev.off()
  
  if (nYears == 2) 
  {
    plotMFACT(res.mfact,name,1,2) # these work only if 2 years are chosen
    plotMFACT(res.mfact,name,2,3) # these work only if 2 years are chosen
    plotMFACT(res.mfact,name,3,4) # these work only if 2 years are chosen
    plotMFACT(res.mfact,name,4,5) # these work only if 2 years are chosen
  }
  
  for (dim in 1 :9)
  {
    plotMFACT.Group(res.mfact,name,dim,dim+1)
    plotMFACT.Freq(res.mfact,name,dim,dim+1,nProd,colour_products,productVector)
    plotMFACT.Ind(res.mfact,name,dim,dim+1,colour_industries,industryVector)
  }
  
  contributions.dim(res.mfact,name)
    
  return(res.mfact)
}

outputMFACT.permutation1 <- function(inputdata, countryHere, varHere, yearVector, industryVector, productVector, share=FALSE, quality, colour_industries, colour_products)
{
  temp.mfact <- dfInput.permutation1(inputdata, countryHere, varHere, yearVector, industryVector, productVector, share)
  #fileName   <- paste("MFACT",varHere, countryHere ,sep="_")
  fileName   <- paste(countryHere,varHere,sep="_")
  res.mfact <- runMFACT(temp.mfact, fileName, yearVector, industryVector, productVector, colour_industries, colour_products)
  return(res.mfact)
}


