# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

source(paste(MFA ,"mfa_contrib-4dim.R"        , sep=sep))

# Function to create, from table dsAgg, an input-table for MFACT for multiple contingency tables (1 per year) 
#for 1 country, 1 variable, a vector of industry-levels and a vector of years.

dfInput.C <- function(inputdata, countryVector, varHere, yearVector, industryVector, productVector, share)
{
  temp2 <- inputdata %>% filter(country %in% countryVector, var==varHere, industry %in% industryVector, product %in% productVector) #%>% spread(product,value)
  temp2.country <- temp2  %>% filter(country==countryVector[1])
  temp.mfact <- temp2.country %>% filter(year==yearVector[1]) %>% spread(product,value) %>% select(c(-var, -year, -country))
  Rnames <- temp.mfact$industry
  temp.mfact <- temp.mfact %>% select(c(-industry)) 
  
  if(share)
  {
    temp.mfact <- data.frame(prop.table(as.matrix(temp.mfact),1))
  }
  
  for (yearHere in yearVector[-1])
  {
    temp.year <- temp2.country %>% filter(year==yearHere) %>% spread(product,value) %>% select(c(-var, -year, -country, -industry)) 
    if(share)
    {
      temp.year <- data.frame(prop.table(as.matrix(temp.year),1))
    }
    temp.mfact <- bind_cols(temp.mfact,temp.year)
  }
  
  for(countryHere in countryVector[-1])
  {
    temp2.country <- temp2  %>% filter(country==countryHere)
    
    for (yearHere in yearVector)
    {
      temp.year <- temp2.country %>% filter(year==yearHere) %>% spread(product,value) %>% select(c(-var, -year, -country, -industry)) 
      if(share)
      {
        temp.year <- data.frame(prop.table(as.matrix(temp.year),1))
      }
      temp.mfact <- bind_cols(temp.mfact,temp.year)
    }
  }
  
  rownames(temp.mfact)    <- Rnames
  temp.mfact <- temp.mfact[match(industryVector,rownames(temp.mfact)),]
  nYears = length(yearVector) 
  nProd = length(productVector)
  nInd = length(industryVector)
  nCountries = length(countryVector)
  times = rep(nProd,nYears)
  newrow.years = rep(rep(yearVector,times),nCountries)
  temp.mfact <- rbind(temp.mfact,newrow.years)
  Rnames <- rownames(temp.mfact)
  temp.mfact <- as.data.frame(sapply(temp.mfact,as.numeric))
  rownames(temp.mfact)    <- Rnames
  return(temp.mfact)
}

########-------------Definition of some output plots for MFACT
########-------------All the plot functions take as input the results of MFACT, i.e. dat <- MFA(something)

# The plot below works for any number of years (contingency tables) (yearVector of any length)
plotMFACT.C.Group <- function(dat,name, dimA, dimB){
  labelA = paste(colnames(dat$group$coord)[dimA],"(", round(dat$eig$per[dimA],2), "%)")
  labelB = paste(colnames(dat$group$coord)[dimB],"(", round(dat$eig$per[dimB],2), "%)")
  
  dfHere <- data.frame(dat$group$coord)
  dfHere$year <- as.integer(t(as.matrix(as.data.frame(strsplit(rownames(dfHere),"_"))))[,2])
  dfHere$country <- t(as.matrix(as.data.frame(strsplit(rownames(dfHere),"_"))))[,1]
  colNameA <- colnames(dfHere[dimA])
  colNameB <- colnames(dfHere[dimB])
  
  p <-  ggplot(dfHere, aes_string(x=colNameA,y=colNameB)) +
        geom_point(size=1.1, aes(colour=year)) +
        geom_text(data=subset(dfHere,year %in% c(yearVector[1],yearVector[length(yearVector)])), aes(label=country),hjust=1, vjust=-1, size = 3) +
        xlim(0,1) +
        ylim(0,1) +
        labs(x = labelA, y = labelB) +
        ggtitle("Groups representation") +
        theme(plot.title = element_text(size = 12)) +
        facet_wrap(~ country, ncol=3, scales="free") +
        scale_colour_gradient()
  #print(p)
  ggsave(paste0(name,"_Groups-dim",dimA,"-",dimB,".pdf"))
}
###############################################################################################
# The plot below works for any number of years (contingency tables) (yearVector of any length)
plotMFACT.C.Freq <- function(dat, name, dimA, dimB, nProd, colour_products,productVector,countryVector){
  labelA = paste(colnames(dat$group$coord)[dimA],"(", round(dat$eig$per[dimA],2), "%)")
  labelB = paste(colnames(dat$group$coord)[dimB],"(", round(dat$eig$per[dimB],2), "%)")
  nCountries <- length(countryVector)
  nYears = length(yearVector) 
  dfHere <- dat$freq$coord[,c(dimA,dimB)]
  dfHere <- cbind(dfHere, rep(rep(yearVector,each=nProd),nCountries), rownames(dat$freq$coord),rep(countryVector,each=nProd*nYears))
  colnames(dfHere)[3] <- "year"
  colnames(dfHere)[4] <- "product"
  colnames(dfHere)[5] <- "country"
  dfHere <- data.frame(dfHere)
  colNameA <- colnames(dfHere[1])
  colNameB <- colnames(dfHere[2])
  
  dfHere$year <- as.numeric(as.character(dfHere$year))
  dfHere[,colnames(dfHere)==colNameA] <- as.numeric(as.character(dfHere[,colnames(dfHere)==colNameA]))
  dfHere[,colnames(dfHere)==colNameB] <- as.numeric(as.character(dfHere[,colnames(dfHere)==colNameB]))
  
  dfHere$product <- factor(dfHere$product, levels=productVector)
  dfHere <- dfHere[order(dfHere$product),]
  #dfHere$countryProd <- paste(dfHere$country,dfHere$product,sep="_")
  
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
        facet_wrap(~ country, ncol=3, scales="free") +
        scale_colour_manual(values=colour_products)
  #print(p)
  ggsave(paste0(name,"_freq-coord_dim",dimA,"-",dimB,".pdf"), width = 50, height = 50, units = c("cm"), dpi = 300)
}
###############################################################################################
# The plot below works for any number of years (contingency tables) (yearVector of any length)
plotMFACT.C.Ind <- function(dat,name, dimA, dimB, colour_industries,industryVector){
  #print(dimA)
  labelA = paste(colnames(dat$group$coord)[dimA],"(", round(dat$eig$per[dimA],2), "%)")
  labelB = paste(colnames(dat$group$coord)[dimB],"(", round(dat$eig$per[dimB],2), "%)")
  
  nYears = length(yearVector) 
  dfHere <- dat$ind$coord.partiel[,c(dimA,dimB)]
  dfHere$industry <- as.factor(t(as.matrix(as.data.frame(strsplit(rownames(dfHere[1:dim(dfHere)[1],]),"[.]"))))[,1])
  dfHere$country_year <- t(as.matrix(as.data.frame(strsplit(rownames(dfHere[1:dim(dfHere)[1],]),"[.]"))))[,2]
  dfHere$year <- as.integer(t(as.matrix(as.data.frame(strsplit(dfHere$country_year,"_"))))[,2])
  dfHere$country <- t(as.matrix(as.data.frame(strsplit(dfHere$country_year,"_"))))[,1]

  dfHere$industry <- factor(dfHere$industry, levels=industryVector) 
  dfHere <- dfHere[order(dfHere$industry),] 
  
  colNameA <- colnames(dfHere[1])
  colNameB <- colnames(dfHere[2])
  
  #dfHere <- subset(dfHere, !industry %in% c("C")) For use if we want to only represent a subset of industries
  
  
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
  
#  p <-  ggplot(subset(dfHere, !industry %in% c("C")), aes_string(x=colNameA,y=colNameB)) +
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
        facet_wrap(~ country, ncol=3, scales="free") +
        scale_colour_manual(values=colour_industries)
  #print(p)
  ggsave(paste0(name,"_coord-partiel_dim",dimA,"-",dimB,".pdf"), width = 50, height = 50, units = c("cm"), dpi = 300)
}
#############################################################################################


# The function runMFACT takes as argument a dataframe issued from dfInput
runMFACT.C <- function(dat, name, countryVector, yearVector, industryVector, productVector, colour_industries, colour_products)
  {
  nYears = length(yearVector)
  nProd  = length(productVector)
  nInd   = length(industryVector)
  nCountries = length(countryVector)
  countryrep <- rep(countryVector,each=nYears)
  yearrep <- rep(yearVector,nCountries)
  yearcountryVector <- paste(countryrep,yearrep,sep="_")
  
  if(sum(is.na(temp.mfact[-dim(temp.mfact)[1],]))>0)
  {
    temp.mfact.addedMV <- imputeMFA(temp.mfact[-dim(temp.mfact)[1],], group=rep(nProd,nYears*nCountries), ncp = 8, type=rep("s",nYears*nCountries), method = "Regularized",
                                    row.w = NULL, coeff.ridge = 0, threshold = 1e-06, seed = NULL, maxiter = 500)
    
    res.mfact <- MFA(temp.mfact.addedMV$completeObs, group=rep(nProd,nYears*nCountries), type=rep("f",nYears*nCountries), name.group=yearcountryVector, ncp=12)
  }
  else
  {
    res.mfact <- MFA(temp.mfact[-dim(temp.mfact)[1],], group=rep(nProd,nYears*nCountries), type=rep("f",nYears*nCountries), name.group=yearcountryVector, ncp=12)
  }
  
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

  
  for (dim in 1:10)
  {
   # plotMFACT.C.Group(res.mfact,name,dim,dim+1)
   #plotMFACT.C.Freq(res.mfact,name,dim,dim+1,nProd,colour_products,productVector,countryVector)
    plotMFACT.C.Ind(res.mfact,name,dim,dim+1,colour_industries,industryVector)
  }
  
  contributions.4dim(res.mfact,name) #function defined in mfa_contrib-4dim.R
  
  return(res.mfact)
}

outputMFACT.C <- function(inputdata, countryVector, varHere, yearVector, industryVector, productVector, share=FALSE, quality, colour_industries, colour_products)
{
  temp.mfact <- dfInput.C(inputdata, countryVector, varHere, yearVector, industryVector, productVector, share)
  #fileName   <- paste("MFACT",varHere, countryHere ,sep="_")
  nCountries = length(countryVector)
  fileName   <- paste0(nCountries,"countries_", varHere)
  res.mfact <- runMFACT.C(temp.mfact, fileName, countryVector, yearVector, industryVector, productVector, colour_industries, colour_products)
  return(res.mfact)
}


