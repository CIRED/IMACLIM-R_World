# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse, Ruben Bibas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


folder <- paste0(PCA,"/reducedSystem/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

runPca <- function(dat, name , supQuanti = NULL , supQuali = NULL ){

    cat(name,"\n\n=========================\n\n")
    if (!is.null(supQuali)) {supQuali=which(colnames(dat)==supQuali)}
    res.pca = PCA(dat, scale.unit=TRUE, ncp=5, graph=T,quali.sup=supQuali,quanti.sup=supQuanti)

    write.infile(res.pca,file=paste0(name,".txt"))
    summary(res.pca,file=paste0(name,"-summary.txt"))

    dev.copy2pdf(file=paste0(name,"-1.pdf"))
    dev.off()
    dev.copy2pdf(file=paste0(name,"-2.pdf"))
    dev.off()

    return(res.pca)

}

dg %>%
    filter(country=="USA",industry=="TOT",var=="I",!product %in% c("GFCF","ICT","NonICT")) %>%
    spread(product,value)  -> ds
rownames(ds)<-ds$year
ds <- ds[,!(names(ds) %in% c("country","var","industry"))] 

runPca(ds,"usaTotAbsolute",supQuanti=c(1))

dg %>%
    filter(country=="USA",industry=="TOT",var=="I",!product %in% c("GFCF","ICT","NonICT")) %>%
    ddply(.(year), mutate, share = value / sum(value) ) -> ds
ds <- ds[,!(names(ds) %in% c("country","var","industry","value"))] 
spread(ds,product,share)  -> ds
rownames(ds)<-ds$year
runPca(ds,"usaTotRelative",supQuanti=c(1))

dg %>%
    filter(country=="USA",industry=="TOT",var=="I",!product %in% c("GFCF","ICT","NonICT")) %>%
    spread(product,value)  -> ds
rownames(ds)<-ds$year
ds <- ds[,!(names(ds) %in% c("country","var","industry","year"))] 
ds %>% t %>% as.data.frame -> dt
#names(dt) <- paste0("v",names(dt))
dt$type <- as.factor(rownames(dt))
ictType    = c("CT","IT","Soft")
nonIctType = c("OCon","OMach","Other","RStruc","TraEq")
temp <- levels(dt$type) 
temp[temp %in% ictType] <- "ICT"
temp[temp %in% nonIctType] <- "NonICT"
temp -> levels(dt$type) 
runPca(dt,"usaYearsAbsolute",supQuali="type")

dg %>%
    filter(country=="USA",industry=="TOT",var=="I",!product %in% c("GFCF","ICT","NonICT")) %>%
    ddply(.(product), mutate, share = value / sum(value) ) -> ds
ds[,!(names(ds) %in% c("value"))] %>%
    spread(product,share)  -> ds
rownames(ds)<-ds$year
ds <- ds[,!(names(ds) %in% c("country","var","industry","year"))] 
ds %>% t %>% as.data.frame -> dt
dt$type <- as.factor(rownames(dt))
ictType    = c("CT","IT","Soft")
nonIctType = c("OCon","OMach","Other","RStruc","TraEq")
temp <- levels(dt$type) 
temp[temp %in% ictType] <- "ICT"
temp[temp %in% nonIctType] <- "NonICT"
temp -> levels(dt$type) 
runPca(dt,"usaYearsRelative",supQuali="type")

