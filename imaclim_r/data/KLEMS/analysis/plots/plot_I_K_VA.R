// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

library(xtable)
library(ggplot2)
library(gridGraphics)
library(grid)
library(gridExtra)
library(psych)

folder <- paste0(PLOT,"/plotted_I_K_VA/")
cat("Results will be located in",folder,"\n")
dir.create(folder, recursive=TRUE)
setwd(folder)

colorscheme_countries <- c("#CC33CC","#FFFF00","#CCFF33", "#00CCFF" , "#E69F00","#0099CC","#D55E00", "#FFCC00","#FF6600","#990099","#FF66CC","#009E73","#3300CC","#000000","#336666")
colorscheme_countries_dg <- c("#CC33CC","#FFFF00","#CCFF33", "#00CCFF" , "#E69F00","#0099CC", "#FFCC00","#FF6600","#990099","#FF66CC","#009E73","#3300CC","#000000","#336666","#D55E00")

productsL <- factor(c(as.character(products),"Con"), levels=c(levels(products),"Con"))
########## I_prod/VA
temp0 <- ds %>% dplyr::filter(var=="I", industry=="TOT") %>% 
                spread(product,value) %>%
                mutate(Con = RStruc + OCon) %>% 
                gather(product, value, -year, -country, -var, -industry,factor_key = TRUE)

for(productHere in productsL) 
{
temp1 <- ds %>% filter(var=="VA", industry=="TOT", country %in% as.vector(countries)) %>% spread(var,value)
temp2 <- temp0 %>% filter(product==productHere) %>% spread(var,value)
temp  <- left_join(temp1,temp2, by=c("country","industry","year")) %>% mutate(I_VA=I/VA)

p <- ggplot(temp, aes( x=year, y=I_VA, color=country)) + 
      geom_line(size=1.1) + 
      scale_y_continuous(labels=percent) +
      ggtitle(paste(productHere, "capital formation as percent of value added", sep=" ")) +
      labs(y = "I / VA") +
      scale_color_manual(values=colorscheme_countries)
ggsave(filename=paste(paste("I_ShareVA",productHere,sep="-"),"pdf",sep="."))
}

#------------------------------------------------------------The same plots as above on one page
########## I_prod/VA

  temp1 <- ds %>% filter(var=="VA", industry=="TOT", country %in% as.vector(countries)) %>% spread(var,value) %>% select(-c(product))
  temp2 <- ds %>% filter(var=="I", industry=="TOT") %>% spread(product,value) 
  temp  <- left_join(temp1,temp2, by=c("country","industry","year")) %>% 
           mutate_each(funs(./VA), -country, -industry, -year, -VA, -var) %>%
           gather(product, value, -country, -industry, -year, -VA, -var) 
  
  levels(temp$var)[levels(temp$var)=="I"] <- "I/VA"
  
  temp$product <- factor(temp$product, levels=c("GFCF","NonICT","ICT","CT","IT","Soft","RStruc","OCon","OMach","TraEq","Other"))
  temp         <- temp[order(temp$product),]

  print(head(temp))
  
  #temp <- temp %>% mutate( productClass = product )
  #levels(temp$productClass)[levels(temp$productClass)==c("GFCF"  , "NonICT" ,"ICT"  ,  "CT"     ,"IT"   ,  "Soft"  , "RStruc" ,"OCon"   ,"OMach", "TraEq" , "Other")] <- c("GFCF","GFCF","GFCF", "ICT", "ICT", "ICT","Construction","Construction", "Equipement", "Equipment", "Equipment")


  p <- ggplot(temp, aes( x=year, y=value, color=country)) + 
    geom_line(size=1.1) + 
    ggtitle("Capital formation as percent of value added") +
    facet_wrap( ~ product, ncol=3)  +
    theme(legend.position="bottom") +
    scale_y_continuous(labels=percent) +
    labs(y = "I / VA") +
    scale_color_manual(values=colorscheme_countries)
  plot(p)
  ggsave("I_ShareVA-Prod.pdf")

#------------------------------------------------------------The same plots as above on one page, varying scales
########## I_prod/VA

g_legend<-function(a.gplot){
    tmp <- ggplot_gtable(ggplot_build(a.gplot))
    leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend <- tmp$grobs[[leg]]
    legend
}


temp1 <- ds %>% filter(var=="VA", industry=="TOT", country %in% as.vector(countries)) %>% spread(var,value) %>% select(-c(product))
temp2 <- ds %>% filter(var=="I", industry=="TOT") %>% spread(product,value) 
temp  <- left_join(temp1,temp2, by=c("country","industry","year")) %>% 
mutate_each(funs(./VA), -country, -industry, -year, -VA, -var) %>%
gather(product, value, -country, -industry, -year, -VA, -var) 
         
levels(temp$var)[levels(temp$var)=="I"] <- "I/VA"
         
temp$product <- factor(temp$product, levels=c("GFCF","NonICT","ICT","CT","IT","Soft","RStruc","OCon","OMach","TraEq","Other"))
temp         <- temp[order(temp$product),]
         
print(head(temp))
         
#temp <- temp %>% mutate( productClass = product )
#levels(temp$productClass)[levels(temp$productClass)==c("GFCF","NonICT","ICT","CT","IT","Soft","RStruc","OCon","OMach","TraEq","Other")] <- c("GFCF","GFCF","GFCF", "ICT", "ICT", "ICT","Construction","Construction", "Equipement", "Equipment", "Equipment")

p1 <- ggplot(temp[temp$product=="GFCF"|temp$product=="NonICT"|temp$product=="ICT",], aes( x=year, y=value, color=country)) + 
      geom_line(size=1.1) + 
      #ggtitle("Capital formation as percent of value added") +
      facet_wrap( ~ product, ncol=3)  +
      theme(legend.position="right") +
      theme(axis.title.x=element_blank(),axis.title.y=element_blank()) +
      scale_y_continuous(labels=percent) +
      #labs(y = "I / VA") +
      scale_color_manual(values=colorscheme_countries)

p2 <- ggplot(temp[temp$product=="RStruc"|temp$product=="OCon",], aes( x=year, y=value, color=country)) + 
      geom_line(size=1.1) + 
      #ggtitle("Capital formation as percent of value added") +
      facet_wrap( ~ product, ncol=3)  +
      theme(legend.position="none", plot.margin=unit(c(0,0,1,1),"mm")) +
      theme(axis.title.x=element_blank(),axis.title.y=element_blank()) +
      scale_y_continuous(labels=percent) +
      #labs(y = "I / VA") +
      scale_color_manual(values=colorscheme_countries)

p3 <- ggplot(temp[temp$product=="OMach"|temp$product=="TraEq"|temp$product=="Other",], aes( x=year, y=value, color=country)) + 
      geom_line(size=1.1) + 
      #ggtitle("Capital formation as percent of value added") +
      facet_wrap( ~ product, ncol=3)  +
      theme(legend.position="none") +
      theme(axis.title.x=element_blank(),axis.title.y=element_blank()) +
      scale_y_continuous(labels=percent, breaks=c(0,0.05,0.1),minor_breaks =NULL) +
      #labs(y = "I / VA") +
      scale_color_manual(values=colorscheme_countries)

p4 <- ggplot(temp[temp$product=="CT"|temp$product=="IT"|temp$product=="Soft",], aes( x=year, y=value, color=country)) + 
      geom_line(size=1.1) + 
      #ggtitle("Capital formation as percent of value added") +
      facet_wrap( ~ product, ncol=3)  +
      theme(legend.position="none") +
      theme(axis.title.y=element_blank()) +
      scale_y_continuous(labels=percent, breaks=c(0,0.03),minor_breaks =NULL) +
      #labs(y = " ") +
      scale_color_manual(values=colorscheme_countries)

legend <- g_legend(p1)
p <- grid.arrange(p1+ theme(legend.position = "none"), p2, p3, p4, legend ,layout_matrix = rbind(c(1,1,1,NA,5),c(2,2,NA,NA,5),c(3,3,3,NA,NA),c(4,4,4,NA,NA)), widths =c(8,8,8,0.2,3.5))
plot(p)

g <- arrangeGrob(p1+ theme(legend.position = "none"), p2, p3, p4, legend ,layout_matrix = rbind(c(1,1,1,NA,5),c(2,2,NA,NA,5),c(3,3,3,NA,NA),c(4,4,4,NA,NA)), widths =c(8,8,8,0.2,3.5), heights =c(50,50,50,50), top="Capital formation as percent of value added", left="I / VA")
ggsave("I_ShareVA-Prod-yScaleFree.pdf",g)


#-----------------------------------------------------------------------------------------------
########## I_prod/I(GFCF)
for(productHere in productsL[!products=="GFCF"])
{
  temp1 <- dg %>% filter(var=="I", industry=="TOT") %>% 
                  spread(product, value) %>% 
                  mutate(Con = OCon + RStruc) %>% 
                  mutate_each(funs(./GFCF),-GFCF, -country, -var, -industry, -year) %>% 
                  gather(product, value, -country, -var, -industry, -year) %>% 
                  filter(product==productHere)
  p <- ggplot(temp1, aes( x=year, y=value, color=country)) + 
       geom_line(size=1.1) + 
       scale_y_continuous(labels=percent) +
       ggtitle(paste(productHere, "capital formation share of GFCF",  sep=" ")) +
       labs(y = "I / I_GFCF") +
       scale_color_manual(values=colorscheme_countries_dg)
  print(p)
ggsave(filename=paste(paste("I_ShareGFCF",productHere,sep="-"),"pdf",sep="."))
}

########## I_prod/I(GFCF) evolution over time, per country
#temp$industry <- factor(temp$industry, c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ"), labels=c("Agr","Mining","Manufact","Elec Gas","Construc","Sales","Trans Comm","Finance","Real estate","RE Business","Community"))
colorscheme_products=c("#191970", "#203D8B", "#8B4513", "#D55E00", "#A52A2A","#009E73","#ADFF2F","#228B22")
colorscheme_products3=c("#009E73","#ADFF2F","#228B22")

industryVector11  <- c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ") # K = "70" + "71t74"
industryLabels11  <- c("Agr","Mining","Manufact","Elec Gas","Construc","Sales","Trans Comm","Finance","Real estate","RE Business","Community")

industryVector30  <- c("AtB","C","15t16","17t19","20","21t22","23","24","25","26","27t28","29","30t33","34t35","36t37","E","F","50","51","52","H","60t63","64","J","70","71t74","L","M","N","O")
industryLabels30  <- c("Agri","Mining","Manu-Food","Manu-Text","Manu-Wood","Manu-PPP","Manu-Refined","Manu-Chem","Manu-Rubber","Manu-Mineral","Manu-Metal","Manu-Mach","Manu-ElecEquip","Manu-TranspEq","Manu-NEC","Elec Gas","Construc","Sale-veh","Sale-wholesale","Sale-nonveh","Hotels","Transport","Comm","Finance","Real estate","RE Business","Public services","Edu","Health","Other services")

industryVectorManu  <- c("15t16","17t19","20","21t22","23","24","25","26","27t28","29","30t33","34t35","36t37")
industryLabelsManu  <- c("Manu-Food","Manu-Text","Manu-Wood","Manu-PPP","Manu-Refined","Manu-Chem","Manu-Rubber","Manu-Mineral","Manu-Metal","Manu-Mach","Manu-ElecEquip","Manu-TranspEq","Manu-NEC")

folder <- paste0(PLOT,"/plotted_bars_structure/")
cat("Results will be located in",folder,"\n")
dir.create(folder, recursive=TRUE)
setwd(folder)

    for (industryHere in industryVector12)
    {
      temp <- temp0 %>% filter(industry==industryHere) %>% spread(product,value)
      temp.shares <- temp %>% mutate_each(funs(./GFCF), -country, -var, -year, -industry, -GFCF) %>% 
                              select(-c(GFCF, NonICT, ICT)) %>%
                              gather(product, value, -country, -var, -industry, -year) %>%
                              spread(year, value)
      temp.shares.5 <- temp %>% mutate_each(funs(./(GFCF-ICT)), -country, -var, -year, -industry, -GFCF, -ICT) %>% 
                                select(-c(GFCF, NonICT, ICT, Soft, IT, CT)) %>%
                                gather(product, value, -country, -var, -industry, -year) %>%
                                spread(year, value)
      temp.shares$product <- factor(temp.shares$product, levels=c("RStruc","OCon","OMach","TraEq","Other","CT","Soft","IT"))
      temp.shares         <- temp.shares[order(temp.shares$product),] %>% gather(year, value, -country, -var, -industry, -product)
      temp.shares$year    <- as.numeric(temp.shares$year)
      
      temp.shares.5$product <- factor(temp.shares.5$product, levels=c("RStruc","OCon","OMach","TraEq","Other"))
      temp.shares.5         <- temp.shares.5[order(temp.shares.5$product),] %>% gather(year, value, -country, -var, -industry, -product)
      temp.shares.5$year    <- as.numeric(temp.shares.5$year)
      
      p <- temp.shares %>% ggplot(aes(x=year, y=value, color=product)) +
                           geom_line(size=1.1) + 
                           scale_y_continuous(labels=percent) +
                           ggtitle(paste(industryHere)) +
                           labs(y = "I / GFCF") +
                           scale_color_manual(values=colorscheme_products)
      print(p)
      ggsave(filename=paste(paste(varHere,"ShareGFCF-line",industryHere,sep="_"),"pdf",sep="."),width = 16, height = 12, units = c("cm"), dpi = 300)
      
      p <- temp.shares %>% ggplot(aes(x=year, y=value)) +
                           geom_bar(stat="identity", aes(fill=product)) +
                           scale_y_continuous(labels=percent) +
                           ggtitle(paste(industryHere)) +
                           labs(y = "I / GFCF") +
                           scale_color_manual(values=colorscheme_products) +
                           scale_fill_manual(values=colorscheme_products)
      print(p)
      ggsave(filename=paste(paste(varHere,"ShareGFCF-bar",industryHere,sep="_"),"pdf",sep="."), width = 16, height = 12, units = c("cm"), dpi = 300)
      
      p <- temp.shares.5 %>% ggplot(aes(x=year, y=value)) +
                           geom_bar(stat="identity", aes(fill=product)) +
                           scale_y_continuous(labels=percent) +
                           ggtitle(paste(industryHere)) +
                           labs(y = "I / GFCF") +
                           scale_color_manual(values=colorscheme_products) +
                           scale_fill_manual(values=colorscheme_products)
      print(p)
      ggsave(filename=paste(paste(varHere,"GFCF5-bar",industryHere,sep="_"),"pdf",sep="."), width = 16, height = 12, units = c("cm"), dpi = 300)
      
  
      temp.shares <- temp.shares %>% spread(product, value)
      
      temp.shares.desript <- data.frame(describe(100*temp.shares[,5:12])) %>% select(n,mean,sd, min, max, range, skew, kurtosis)
      temp.shares.desript <- round(temp.shares.desript,2)
      
      print(xtable(temp.shares.desript,caption=paste("Descriptive stats", varHere ,"shares, 1970 - 2007",countryHere,industryHere, sep=", "),label=paste("table:SummaryShares",countryHere,industryHere,sep="_"),digits=2),type="latex",size="\\scriptsize",file=paste(paste("SummaryShares",countryHere,industryHere,sep="_"),".tex",sep=""))
      
    }
  }
}

for(productHere in productsL[!products=="GFCF"])
{
  temp1 <- dg %>% filter(var=="I", industry=="TOT") %>% 
    spread(product, value) %>% 
    mutate(Con = OCon + RStruc) %>% 
    mutate_each(funs(./GFCF),-GFCF, -country, -var, -industry, -year) %>% 
    gather(product, value, -country, -var, -industry, -year) %>% 
    filter(product==productHere)
  p <- ggplot(temp1, aes( x=year, y=value, color=country)) + 
    geom_line(size=1.1) + 
    scale_y_continuous(labels=percent) +
    ggtitle(paste(productHere, "capital formation share of GFCF",  sep=" ")) +
    labs(y = "I / I_GFCF") +
    scale_color_manual(values=colorscheme_countries_dg)
  print(p)
  ggsave(filename=paste(paste("I_ShareGFCF",productHere,sep="-"),"pdf",sep="."))
}





# for French data, K is in volume 2005=100 ; other countries K in 1995 prices
########## K_prod/VA
for(productHere in products)
{
  temp1 <- ds %>% filter( var=="VA",   industry=="TOT", country %in% as.vector(countries), !country=="FRA") %>%
    spread(var,value)
  temp2 <- ds %>% filter( var=="VA_P", industry=="TOT", country %in% as.vector(countries), !country=="FRA") %>% 
    spread(var,value)
  temp3 <- ds %>% filter( var=="K", product==productHere, industry=="TOT", !country=="FRA") %>% 
    spread(var,value)
  temp  <- left_join(temp1,temp2, by=c("country","industry","year"))
  temp  <- left_join(temp,temp3, by=c("country","industry","year")) %>% mutate(K_VA= K*VA_P/(100*VA))
  #print(head(temp))
  
  p <- ggplot(temp, aes( x=year, y=K_VA, color=country)) + 
    geom_line(size=1.1) + 
    scale_y_continuous(labels=percent) +
    ggtitle(paste(productHere, "Fixed capital stock/Gross value added", sep=" ")) +
    labs(y = "K / VA * VA_P / 100") +
    scale_color_manual(values=colorscheme_countries)
  ggsave(filename=paste(paste("K_ShareVA",productHere,sep="-"),"pdf",sep="."))
}


########## K_prod/K(GFCF)
for(productHere in products[!products=="GFCF"])
{
  temp1 <- dg %>% filter(var=="K", industry=="TOT", !country=="FRA") %>% 
    spread(product, value) %>% 
    mutate_each(funs(./GFCF),-GFCF, -country, -var, -industry, -year) %>% 
    gather(product, value, -country, -var, -industry, -year) %>% 
    filter(product==productHere)
  p <- ggplot(temp1, aes( x=year, y=value, color=country)) + 
    geom_line(size=1.1) + 
    scale_y_continuous(labels=percent) +
    ggtitle(paste(productHere, "capital stock share of total",  sep=" ")) +
    labs(y = "K / K_GFCF") +
    scale_color_manual(values=colorscheme_countries_dg)
  ggsave(filename=paste(paste("K_Share",productHere,sep="-"),"pdf",sep="."))
}


########## I_Ind/VA
for(industryHere in c("AtB")) 
{
  temp1 <- ds %>% filter(var=="VA", country %in% as.vector(countries), industry==industryHere) %>% spread(var,value)
  temp2 <- ds %>% filter(var=="I", product=="GFCF", industry==industryHere) %>% spread(var,value)
  temp  <- left_join(temp1,temp2, by=c("country","industry","year")) %>% mutate(I_VA=I*100/VA)
 
  p <- ggplot(temp, aes( x=year, y=I_VA, color=country)) + 
    geom_line(size=1.1) + 
    #scale_y_continuous(labels=percent) +
    ggtitle(paste(productHere, "Capital formation percent of value added", sep=" ")) +
    scale_color_manual(values=colorscheme_countries)
  ggsave(filename=paste(industryHere,"pdf",sep="."))
}

rm(temp1,temp2,temp3,temp)



