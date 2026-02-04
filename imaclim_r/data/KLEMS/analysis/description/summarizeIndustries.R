// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


folder <- paste0(SUMMARIZE,"/summarizeIndustries/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

#---------------------------------------------------------------------------------
#productsL <- factor(c(as.character(products),"Con"), levels=c(levels(products),"Con"))

temp <- dgAgg %>% filter(industry %in% c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ"))
temp$industry <- factor(temp$industry, c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ"), labels=c("Agr","Mining","Manufact","Elec Gas","Construc","Sales","Trans Comm","Finance","Real estate","RE Business","Community"))
industries.short <- unique(temp$industry)
industries.short <- industries.short[match(c("Agr","Mining","Manufact","Elec Gas","Construc","Sales","Trans Comm","Finance","Real estate","RE Business","Community"), industries.short)]

temp0 <- dgAgg %>% filter(industry %in% c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ","TOT"))
temp0$industry <- factor(temp0$industry, c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ","TOT"), labels=c("Agr","Mining","Manufact","Elec Gas","Construc","Sales","Trans Comm","Finance","Real estate","RE Business","Community","Total"))
industries0.short <- unique(temp0$industry)
industries0.short <- industries0.short[match(c("Agr","Mining","Manufact","Elec Gas","Construc","Sales","Trans Comm","Finance","Real estate","RE Business","Community", "Total"), industries0.short)]


for (countryHere in c("FRA"))
{
  for(yearHere in c("2007"))
  {

#----------------------------------------contingency table, row and column profiles, independency, deviations, chi2    
  dH0 <- temp0 %>% filter(var=="I", year==yearHere, country==countryHere) %>% spread(product,value)
  dH0 <- dH0[,c("year","country","var","industry","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft","NonICT","ICT","GFCF")]
  rownames(dH0) <- industries0.short
  dH0[,-c(1,2,3,4)] <- dH0[,-c(1,2,3,4)]/1000
  print(xtable(dH0[,-c(1,2,3,4)],caption=paste("Nominal investment per industry, per asset", countryHere,yearHere," (billion current dollars)",sep=", "), label=paste("table:I",countryHere,yearHere,sep="_"),digits=3, align="l|rrrrrrrr|rr|r"),type="latex",size="\\scriptsize",file=paste(paste("I",countryHere,yearHere,sep="_"),"tex",sep="."),hline.after = getOption("xtable.hline.after", c(-1,0,11,12)),latex.environments = "") 
    
  dH0.rowProfiles <- dH0 %>% mutate_each(funs(./(GFCF/100)), -year, -country, -var, -industry, -GFCF) %>%
                           mutate(GFCF=100)
  rownames(dH0.rowProfiles) <- industries0.short
  print(xtable(dH0.rowProfiles[,-c(1,2,3,4)],caption=paste("Nominal investment per industry and asset, rowprofiles", countryHere,yearHere,sep=", "), label=paste("table:I-rowProfiles",countryHere,yearHere,sep="_"),digits=1, align="l|rrrrrrrr|rr|r"),type="latex",size="\\scriptsize",file=paste(paste("I-rowProfiles",countryHere,yearHere,sep="_"),"tex",sep="."),hline.after = getOption("xtable.hline.after", c(-1,0,11,12)),latex.environments = "") 


  dH0.colProfiles <- dH0 %>% mutate(RStruc=RStruc*100/dH0["Total","RStruc"]) %>%
                             mutate(OCon=OCon*100/dH0["Total","OCon"]) %>%
                             mutate(TraEq=TraEq*100/dH0["Total","TraEq"]) %>%
                             mutate(OMach=OMach*100/dH0["Total","OMach"]) %>%
                             mutate(Other=Other*100/dH0["Total","Other"]) %>%
                             mutate(CT=CT*100/dH0["Total","CT"]) %>%
                             mutate(IT=IT*100/dH0["Total","IT"]) %>%
                             mutate(Soft=Soft*100/dH0["Total","Soft"]) %>%
                             mutate(NonICT=NonICT*100/dH0["Total","NonICT"]) %>%
                             mutate(ICT=ICT*100/dH0["Total","ICT"]) %>%
                             mutate(GFCF=GFCF*100/dH0["Total","GFCF"])
  rownames(dH0.colProfiles) <- industries0.short
  print(xtable(dH0.colProfiles[,-c(1,2,3,4)],caption=paste("Nominal investment per industry and asset, column profiles", countryHere,yearHere,sep=", "), label=paste("table:I-colProfiles",countryHere,yearHere,sep="_"),digits=1, align="l|rrrrrrrr|rr|r"),type="latex",size="\\scriptsize",file=paste(paste("I-colProfiles",countryHere,yearHere,sep="_"),"tex",sep="."),hline.after = getOption("xtable.hline.after", c(-1,0,11,12)),latex.environments = "") 

  dH0.independence <- dH0
  for (colHere in c("RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft","NonICT","ICT","GFCF"))
  {
    for (rowHere in industries0.short)
    { dH0.independence[rowHere,colHere] <- dH0[rowHere,"GFCF"]*dH0["Total",colHere]/dH0["Total","GFCF"] }
  }
    print(xtable(dH0.independence[,-c(1,2,3,4)],caption=paste("Nominal investment per industry and asset, independency hypothesis", countryHere,yearHere," (billion current dollars)",sep=", "), label=paste("table:I-independence",countryHere,yearHere,sep="_"),digits=2, align="l|rrrrrrrr|rr|r"),type="latex",size="\\scriptsize",file=paste(paste("I-independence",countryHere,yearHere,sep="_"),"tex",sep="."),hline.after = getOption("xtable.hline.after", c(-1,0,11,12)),latex.environments = "") 

  dH0.dev <- dH0
  dH0.dev[,-c(1,2,3,4)] <-  dH0[,-c(1,2,3,4)] - dH0.independence[,-c(1,2,3,4)]
  print(xtable(dH0.dev[,-c(1,2,3,4)],caption=paste(paste("Nominal investment per industry and asset, deviations from independency hypothesis", countryHere,yearHere,"(billion current dollars)",sep=", "),"A positive number means actual investment is higher than under the independency hypothesis", sep=". "), label=paste("table:I-deviations",countryHere,yearHere,sep="_"),digits=3, align="l|rrrrrrrr|rr|r"),type="latex",size="\\scriptsize",file=paste(paste("I-deviations",countryHere,yearHere,sep="_"),"tex",sep="."),hline.after = getOption("xtable.hline.after", c(-1,0,11,12)),latex.environments = "") 

  dH0.chi2 <- dH0
  dH0.chi2[,-c(1,2,3,4)] <- (dH0[,-c(1,2,3,4)] - dH0.independence[,-c(1,2,3,4)])^2/(dH0.independence[,-c(1,2,3,4)]) 
  totalChi2 <- sum(dH0.chi2$RStruc) + sum(dH0.chi2$OCon) + sum(dH0.chi2$TraEq) + sum(dH0.chi2$OMach) + sum(dH0.chi2$Other) + sum(dH0.chi2$CT) + sum(dH0.chi2$IT) + sum(dH0.chi2$Soft)
  dH0.chi2[,-c(1,2,3,4)] <- 100*dH0.chi2[,-c(1,2,3,4)] /totalChi2

  print(xtable(dH0.chi2[,-c(1,2,3,4)],caption=paste("Nominal investment per industry and asset, chi2 contributions", countryHere,yearHere,sep=", "), label=paste("table:I-chi2",countryHere,yearHere,sep="_"),digits=2, align="l|rrrrrrrr|rr|r"),type="latex",size="\\scriptsize",file=paste(paste("I-chi2",countryHere,yearHere,sep="_"),"tex",sep="."),hline.after = getOption("xtable.hline.after", c(-1,0,11,12)),latex.environments = "") 


#----------------------------------------without RStruc and Real estate: contingency table, row and column profiles, independency, deviations, chi2  

  dH0.noResCon <- temp0 %>% filter(var=="I", year==yearHere, country==countryHere) %>% spread(product,value)
  dH0.noResCon <- dH0.noResCon[,c("year","country","var","industry","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft","NonICT","ICT","GFCF")]
  dH0.noResCon <- dH0.noResCon[,c("year","country","var","industry","OCon","TraEq","OMach","Other","CT","IT","Soft")]
  dH0.noResCon <- dH0.noResCon %>% mutate(GFCFnoResCon=OCon +TraEq +OMach + Other + CT + IT +Soft)  
  dH0.noResCon <- dH0.noResCon[!dH0.noResCon$industry=="Real estate",]
  for (colHere in c("OCon","TraEq","OMach","Other","CT","IT","Soft","GFCFnoResCon"))
  {
    dH0.noResCon[dH0.noResCon$industry=="Total",colHere] <- sum(dH0.noResCon[!dH0.noResCon$industry=="Total",colHere])
  }
  rownames(dH0.noResCon) <- industries0.short[!industries0.short=="Real estate"]
  dH0.noResCon[,-c(1,2,3,4)] <- dH0.noResCon[,-c(1,2,3,4)]/1000
  print(xtable(dH0.noResCon[,-c(1,2,3,4)],caption=paste("Nominal investment per industry, per asset, excluding investment by the real estate sector in residential structures", countryHere,yearHere," (billion current dollars)",sep=", "), label=paste("table:I",countryHere,yearHere,"noResCon",sep="_"),digits=3, align="l|rrrrrrr|r"),type="latex",size="\\scriptsize",file=paste(paste("I",countryHere,yearHere,"noResCon",sep="_"),"tex",sep="."),hline.after = getOption("xtable.hline.after", c(-1,0,10,11)),latex.environments = "") 

  dH0.noResCon.rowProfiles <- dH0.noResCon %>% 
                              mutate_each(funs(./(GFCFnoResCon/100)), -year, -country, -var, -industry, -GFCFnoResCon) %>%
                              mutate(GFCFnoResCon=100)
  rownames(dH0.noResCon.rowProfiles) <- industries0.short[!industries0.short=="Real estate"]
  print(xtable(dH0.noResCon.rowProfiles[,-c(1,2,3,4)],caption=paste("Nominal investment per industry and asset, rowprofiles, excluding investment by the real estate sector in residential structures", countryHere,yearHere,sep=", "), label=paste("table:I-rowProfiles",countryHere,yearHere,"noResCon",sep="_"),digits=1, align="l|rrrrrrr|r"),type="latex",size="\\scriptsize",file=paste(paste("I-rowProfiles",countryHere,yearHere,"noResCon",sep="_"),"tex",sep="."),hline.after = getOption("xtable.hline.after", c(-1,0,10,11)),latex.environments = "") 


  dH0.noResCon.colProfiles <- dH0.noResCon %>% mutate(OCon=OCon*100/dH0.noResCon["Total","OCon"]) %>%
                              mutate(TraEq=TraEq*100/dH0.noResCon["Total","TraEq"]) %>%
                              mutate(OMach=OMach*100/dH0.noResCon["Total","OMach"]) %>%
                              mutate(Other=Other*100/dH0.noResCon["Total","Other"]) %>%
                              mutate(CT=CT*100/dH0.noResCon["Total","CT"]) %>%
                              mutate(IT=IT*100/dH0.noResCon["Total","IT"]) %>%
                              mutate(Soft=Soft*100/dH0.noResCon["Total","Soft"]) %>%
                              mutate(GFCFnoResCon=GFCFnoResCon*100/dH0.noResCon["Total","GFCFnoResCon"])
  rownames(dH0.noResCon.colProfiles) <- industries0.short[!industries0.short=="Real estate"]
  print(xtable(dH0.noResCon.colProfiles[,-c(1,2,3,4)],caption=paste("Nominal investment per industry and asset, column profiles, excluding investment by the real estate sector in residential structures", countryHere,yearHere,sep=", "), label=paste("table:I-colProfiles",countryHere,yearHere,"noResCon",sep="_"),digits=1, align="l|rrrrrrr|r"),type="latex",size="\\scriptsize",file=paste(paste("I-colProfiles",countryHere,yearHere,"noResCon",sep="_"),"tex",sep="."),hline.after = getOption("xtable.hline.after", c(-1,0,10,11)),latex.environments = "") 

  dH0.noResCon.independence <- dH0.noResCon

  for (colHere in c("OCon","TraEq","OMach","Other","CT","IT","Soft","GFCFnoResCon"))
  {
    for (rowHere in industries0.short[!industries0.short=="Real estate"])
    { 
      dH0.noResCon.independence[rowHere,colHere] <- dH0.noResCon[rowHere,"GFCFnoResCon"]*dH0.noResCon["Total",colHere]/dH0.noResCon["Total","GFCFnoResCon"] 
    }
  }

  print(xtable(dH0.noResCon.independence[,-c(1,2,3,4)],caption=paste("Nominal investment per industry and asset, independency hypothesis", countryHere, yearHere,"(billion current dollars)",sep=", "), label=paste("table:I-independence",countryHere,yearHere,"noResCon",sep="_"),digits=3, align="l|rrrrrrr|r"),type="latex",size="\\scriptsize",file=paste(paste("I-independence",countryHere,yearHere,"noResCon",sep="_"),"tex",sep="."),hline.after = getOption("xtable.hline.after", c(-1,0,10,11)),latex.environments = "") 

  dH0.noResCon.dev <- dH0.noResCon
  dH0.noResCon.dev[,-c(1,2,3,4)] <-  dH0.noResCon[,-c(1,2,3,4)] - dH0.noResCon.independence[,-c(1,2,3,4)]
  print(xtable(dH0.noResCon.dev[,-c(1,2,3,4)],caption=paste(paste("Nominal investment per industry and asset, deviations from independency hypothesis", countryHere,yearHere,"(billion current dollars)",sep=", "),"A positive number means actual investment is higher then under the independency hypothesis","Data excluding investment by the real estate sector in residential structures.", sep=". "), label=paste("table:I-deviations",countryHere,yearHere,"noResCon",sep="_"),digits=3, align="l|rrrrrrr|r"),type="latex",size="\\scriptsize",file=paste(paste("I-deviations",countryHere,yearHere,"noResCon",sep="_"),"tex",sep="."),hline.after = getOption("xtable.hline.after", c(-1,0,10,11)),latex.environments = "") 

  dH0.noResCon.chi2 <- dH0.noResCon
  dH0.noResCon.chi2[,-c(1,2,3,4)] <- (dH0.noResCon[,-c(1,2,3,4)]-dH0.noResCon.independence[,-c(1,2,3,4)])^2/(dH0.noResCon.independence[,-c(1,2,3,4)])
  totalChi2.noResCon <- sum(dH0.noResCon.chi2$OCon) + sum(dH0.noResCon.chi2$TraEq) + sum(dH0.noResCon.chi2$OMach) + sum(dH0.noResCon.chi2$Other) + sum(dH0.noResCon.chi2$CT) + sum(dH0.noResCon.chi2$IT) + sum(dH0.noResCon.chi2$Soft)
  dH0.noResCon.chi2[,-c(1,2,3,4)] <- 100*dH0.noResCon.chi2[,-c(1,2,3,4)]/totalChi2.noResCon
  print(xtable(dH0.noResCon.chi2[,-c(1,2,3,4)],caption=paste("Nominal investment per industry and asset, chi2 contributions,excluding", countryHere,yearHere,sep=", "), label=paste("table:I-chi2",countryHere,yearHere,"noResCon",sep="_"),digits=2, align="l|rrrrrrr|r"),type="latex",size="\\scriptsize",file=paste(paste("I-chi2",countryHere,yearHere,"noResCon",sep="_"),"tex",sep="."),hline.after = getOption("xtable.hline.after", c(-1,0,10,11)),latex.environments = "") 

#-------------------------(--------------------------------------------------------- table with shareI, shareK, shareVA, and levels per industry
  dH1 <- temp0 %>% filter(var=="I", year==yearHere, country==countryHere) %>%
                   spread(product,value)
  sum <- dH1$GFCF[dH1$industry=="Total"]
  dH1 <- dH1 %>%   mutate(shareI=100*GFCF/sum) %>%
                   mutate(I=0.001*GFCF) %>% select(c(year,country, var ,industry, I, shareI))
  #dH1 <- dH1[,c("year","country","var","industry","shareI","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft","NonICT","ICT")]
  #dH1 <- dH1[match(c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ"), dH1$industry),]
  #dH1$industry <- factor(dH1$industry, c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ"), labels=c("Agr","Mining","Manufact","Elec Gas","Construc","Sales","Trans Comm","Finance","Real estate","RE Business","Community"))

  dH2 <- temp0 %>% filter(var=="K", year==yearHere, country==countryHere) %>%
                   spread(product,value)
  sum <- dH2$GFCF[dH2$industry=="Total"]
  dH2 <- dH2 %>% mutate(shareK=100*GFCF/sum) %>%
                 mutate(K=0.001*GFCF) %>% select(c(year,country, var ,industry, K, shareK))
  #dH2 <- dH2[,c("year","country","var","industry","shareK","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft","NonICT","ICT")]


  #dH3 <- temp %>% filter(var=="D", year==yearHere, country==countryHere) %>%
#                spread(product,value) %>%
#                mutate_each(funs(./(GFCF/100)), -year, - country, -var, -industry, -GFCF) %>%
#                mutate(shareD=100*GFCF/sum(GFCF)) %>% select(-c(GFCF))
#dH3 <- dH3[,c("year","country","var","industry","shareD","RStruc","OCon","TraEq","OMach","Other","CT","IT","Soft","NonICT","ICT")]

  dH4 <- dsAgg %>% filter(var=="VA", year==yearHere, country==countryHere, industry %in% c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ","TOT"))
  sum <- dH4$value[dH4$industry=="TOT"]                  
  dH4 <- dH4 %>%  mutate(shareVA=100*value/sum) %>%
                mutate(VA=0.001*value) %>% select(c(year,country, var ,industry, VA, shareVA))
  dH4 <- dH4[match(c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ","TOT"), dH4$industry),]
  dH4$industry <- factor(dH4$industry, c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ","TOT"), labels=c("Agr","Mining","Manufact","Elec Gas","Construc","Sales","Trans Comm","Finance","Real estate","RE Business","Community","Total"))

  dH          <- dH1
  dH$K        <- dH2$K
  dH$VA       <- dH4$VA
  dH$shareK   <- dH2$shareK
  dH$shareVA  <- dH4$shareVA

  dH <- dH[,c("year","country","industry","shareVA","shareI","shareK","VA","I","K")]

  rownames(dH) <- industries0.short

#----------------------------------------Calculate distance between investment profiles different industries.

#dH.use <- dH[,-c(1,2,3,4,5,6,7,8,17,18)]

#dH.distances <- data.frame(matrix(rep(0,length(industries.short)^2),nrow=length(industries.short),ncol=length(industries.short), byrow=TRUE))
#colnames(dH.distances) <- industries.short
#rownames(dH.distances) <- industries.short

#col.sum <- apply(dH.use, 2, sum)
#industries.triang <- industries.short

#for (col.ind in industries.short)
#{ #industries.triang <- industries.triang[!industries.triang==col.ind]  
#  for (row.ind in industries.short)
#  {
#  dH.distances[row.ind,col.ind] <- sum((dH.use[row.ind,] - dH.use[col.ind,])^2/col.sum)
#  }
#}

  a = c(0,rep(1,3),rep(3,3))
  dH.digits <- matrix(rep(a,12),nrow=12,ncol=7, byrow=TRUE)

  print(xtable(dH[,-c(1,2,3)],caption=paste(paste("Per industry VA, I, K, shares (percent) and levels (billion dollars)", countryHere,yearHere,sep=", "),"VA and I in current dollars, K in 1995 constant dollars.",sep=". "), label=paste("table:VA-I-K_indSummary",countryHere,yearHere,sep="_"),digits=dH.digits, align="l|rrr|rrr"),type="latex",size="\\scriptsize",file=paste(paste("VA-I-K_indSummary",countryHere,yearHere,sep="_"),"tex",sep="."), hline.after = getOption("xtable.hline.after", c(-1,0,11,12)),latex.environments = "")
  #print(xtable(t(dH.distances),caption=paste("Distances between industry investment profiles", countryHere,yearHere,sep=", "), label=paste("table:distancesInd",countryHere,yearHere,sep="_"),digits=1, auto = TRUE),type="latex",size="\\scriptsize",file=paste(paste("distancesInd",countryHere,yearHere,sep="_"),"tex",sep="."),latex.environments = "")

  }
}
