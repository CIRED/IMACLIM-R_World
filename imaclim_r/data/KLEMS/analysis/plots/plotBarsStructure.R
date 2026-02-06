# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

colorscheme_products=c("#191970", "#203D8B", "#8B4513", "#D55E00", "#A52A2A","#009E73","#ADFF2F","#228B22")
colorscheme_products3=c("#009E73","#ADFF2F","#228B22")


folder <- paste0(PLOT,"/plotted_bars_structure/")
cat("Results will be located in",folder,"\n")
dir.create(folder, recursive=TRUE)
setwd(folder)

#------------------------bargraphs all countries on 1 page, page per industry, 
#each graph details asset detail as shares of total investment for that industry
#industryVector <- industryVector12
industryVector <- "TOT"
for (varHere in "I")
  {
  temp0 <- dsAgg %>% filter(var=="I")
  
  for(industryHere in industryVector)
    {
      temp0 <- temp0 %>% filter(industry==industryHere)
      temp0$industry <- factor(temp0$industry, industryVector, labels=industryLabels)

      temp.wrap <- temp0 %>% spread(product,value)
      temp.wrap.shares  <- temp.wrap %>%  mutate_each(funs(./GFCF), -country, -var, -year, -industry, -GFCF) %>% 
                                    select(-c(GFCF, NonICT, ICT)) %>%
                                    gather(product, value, -country, -var, -industry, -year) %>%
                                    spread(year, value)
      temp.wrap.shares4 <- temp.wrap %>%  mutate_each(funs(./(GFCF-ICT-Other)), -country, -var, -year, -industry, -GFCF, -ICT, -Other) %>% 
                                    select(-c(GFCF, NonICT, ICT, Soft, IT, CT, Other)) %>%
                                    gather(product, value, -country, -var, -industry, -year) %>%
                                    spread(year, value)
      temp.wrap.shares5 <- temp.wrap %>%  mutate_each(funs(./(GFCF-ICT)), -country, -var, -year, -industry, -GFCF, -ICT) %>% 
                                    select(-c(GFCF, NonICT, ICT, Soft, IT, CT)) %>%
                                    gather(product, value, -country, -var, -industry, -year) %>%
                                    spread(year, value)
      temp.wrap.shares3 <- temp.wrap %>%  mutate_each(funs(./(GFCF-NonICT)), -country, -var, -year, -industry, -GFCF, -NonICT) %>% 
                                    select(-c(GFCF, NonICT, ICT, RStruc, OCon, OMach, TraEq, Other)) %>%
                                    gather(product, value, -country, -var, -industry, -year) %>%
                                    spread(year, value)

      temp.wrap.shares$product <- factor(temp.wrap.shares$product, levels=productVector8)
  temp.wrap.shares         <- temp.wrap.shares[order(temp.wrap.shares$product),] %>% gather(year, value, -country, -var, -industry, -product)
  temp.wrap.shares$year    <- as.numeric(temp.wrap.shares$year)

  temp.wrap.shares4$product <- factor(temp.wrap.shares4$product, levels=productVector4)
  temp.wrap.shares4         <- temp.wrap.shares4[order(temp.wrap.shares4$product),] %>% gather(year, value, -country, -var, -industry, -product)
  temp.wrap.shares4$year    <- as.numeric(temp.wrap.shares4$year)
  
  temp.wrap.shares5$product <- factor(temp.wrap.shares5$product, levels=productVector5)
  temp.wrap.shares5         <- temp.wrap.shares5[order(temp.wrap.shares5$product),] %>% gather(year, value, -country, -var, -industry, -product)
  temp.wrap.shares5$year    <- as.numeric(temp.wrap.shares5$year)

  temp.wrap.shares3$product <- factor(temp.wrap.shares3$product, levels=productVector3)
  temp.wrap.shares3         <- temp.wrap.shares3[order(temp.wrap.shares3$product),] %>% gather(year, value, -country, -var, -industry, -product)
  temp.wrap.shares3$year    <- as.numeric(temp.wrap.shares3$year)

  p.wrap <- temp.wrap.shares %>%  ggplot(aes(x=year, y=value)) +
                                  geom_bar(stat="identity", aes(fill=product)) +
                                  scale_y_continuous(labels=percent) +
                                  ggtitle(paste(industryHere)) +
                                  labs(y =paste0(varHere, ", shares")) +
                                  scale_color_manual(values=colorscheme_products) +
                                  scale_fill_manual(values=colorscheme_products) +
                                  facet_wrap(~ country, ncol=4)
  #print(p.wrap)
  ggsave(filename=paste(paste(varHere,"ShareGFCF-bar8x",industryHere,sep="_"),"pdf",sep="."), width = 21, height = 18, units = c("cm"), dpi = 300)

  p.wrap4 <- temp.wrap.shares4 %>%  ggplot(aes(x=year, y=value)) +
                                    geom_bar(stat="identity", aes(fill=product)) +
                                    scale_y_continuous(labels=percent) +
                                    ggtitle(paste(industryHere)) +
                                    labs(y =paste0(varHere, ", shares")) +
                                    scale_color_manual(values=colorscheme_products) +
                                    scale_fill_manual(values=colorscheme_products) +
                                    facet_wrap(~ country, ncol=4)
  #print(p.wrap4)
  ggsave(filename=paste(paste(varHere,"ShareGFCF-bar4x",industryHere,sep="_"),"pdf",sep="."), width = 21, height = 18, units = c("cm"), dpi = 300)
  
  
  p.wrap5 <- temp.wrap.shares5 %>%  ggplot(aes(x=year, y=value)) +
                                    geom_bar(stat="identity", aes(fill=product)) +
                                    scale_y_continuous(labels=percent) +
                                    ggtitle(paste(industryHere)) +
                                    labs(y =paste0(varHere, ", shares")) +
                                    scale_color_manual(values=colorscheme_products) +
                                    scale_fill_manual(values=colorscheme_products) +
                                    facet_wrap(~ country, ncol=4)
  #print(p.wrap5)
  ggsave(filename=paste(paste(varHere,"ShareGFCF-bar5x",industryHere,sep="_"),"pdf",sep="."), width = 21, height = 18, units = c("cm"), dpi = 300)

  p.wrap3 <- temp.wrap.shares3 %>%  ggplot(aes(x=year, y=value)) +
                                    geom_bar(stat="identity", aes(fill=product)) +
                                    scale_y_continuous(labels=percent) +
                                    ggtitle(paste(industryHere)) +
                                    labs(y =paste0(varHere, ", shares")) +
                                    scale_color_manual(values=colorscheme_products3) +
                                    scale_fill_manual(values=colorscheme_products3) +
                                    facet_wrap(~ country, ncol=4)
  #print(p.wrap3)
  ggsave(filename=paste(paste(varHere,"ShareGFCF-bar3x", industryHere,sep="_"),"pdf",sep="."), width = 21, height = 18, units = c("cm"), dpi = 300)
} 
}

#------------------------------------------------------------------------------

for (countryHere in countries)
{
  folder <- paste0(PLOT,"/plotted_bars_structure/",countryHere)
  cat("Results will be located in",folder,"\n")
  dir.create(folder, recursive=TRUE)
  setwd(folder)
  
  for (varHere in c("I"))
  {
    temp0 <- dsAgg %>% filter(country==countryHere, var==varHere, industry %in%  industryVector )
    temp0$industry <- factor(temp0$industry, industryVector, labels=industryLabels)
    
    temp.wrap <- temp0 %>% spread(product,value)
    temp.wrap.shares  <- temp.wrap %>%  mutate_each(funs(./GFCF), -country, -var, -year, -industry, -GFCF) %>% 
                                        select(-c(GFCF, NonICT, ICT)) %>%
                                        gather(product, value, -country, -var, -industry, -year) %>%
                                        spread(year, value)
    temp.wrap.shares5 <- temp.wrap %>%  mutate_each(funs(./(GFCF-ICT)), -country, -var, -year, -industry, -GFCF, -ICT) %>% 
                                        select(-c(GFCF, NonICT, ICT, Soft, IT, CT)) %>%
                                        gather(product, value, -country, -var, -industry, -year) %>%
                                        spread(year, value)
    temp.wrap.shares3 <- temp.wrap %>%  mutate_each(funs(./(GFCF-NonICT)), -country, -var, -year, -industry, -GFCF, -NonICT) %>% 
                                        select(-c(GFCF, NonICT, ICT, RStruc, OCon, OMach, TraEq, Other)) %>%
                                        gather(product, value, -country, -var, -industry, -year) %>%
                                        spread(year, value)
    
    temp.wrap.shares$product <- factor(temp.wrap.shares$product, levels=productVector8)
    temp.wrap.shares         <- temp.wrap.shares[order(temp.wrap.shares$product),] %>% gather(year, value, -country, -var, -industry, -product)
    temp.wrap.shares$year    <- as.numeric(temp.wrap.shares$year)
    
    temp.wrap.shares5$product <- factor(temp.wrap.shares5$product, levels=productVector5)
    temp.wrap.shares5         <- temp.wrap.shares5[order(temp.wrap.shares5$product),] %>% gather(year, value, -country, -var, -industry, -product)
    temp.wrap.shares5$year    <- as.numeric(temp.wrap.shares5$year)
    
    temp.wrap.shares3$product <- factor(temp.wrap.shares3$product, levels=productVector3)
    temp.wrap.shares3         <- temp.wrap.shares3[order(temp.wrap.shares3$product),] %>% gather(year, value, -country, -var, -industry, -product)
    temp.wrap.shares3$year    <- as.numeric(temp.wrap.shares3$year)
    
    p.wrap <- temp.wrap.shares %>%  ggplot(aes(x=year, y=value)) +
                                    geom_bar(stat="identity", aes(fill=product)) +
                                    scale_y_continuous(labels=percent) +
                                    ggtitle(paste(countryHere)) +
                                    labs(y =paste0(varHere, ", shares")) +
                                    scale_color_manual(values=colorscheme_products) +
                                    scale_fill_manual(values=colorscheme_products) +
                                    facet_wrap(~ industry, ncol=4)
    #print(p.wrap)
    ggsave(filename=paste(paste(countryHere,varHere,"ShareGFCF-bar8x",fileName.industry,sep="_"),"pdf",sep="."), width = 21, height = 18, units = c("cm"), dpi = 300)
    
    p.wrap5 <- temp.wrap.shares5 %>%  ggplot(aes(x=year, y=value)) +
                                      geom_bar(stat="identity", aes(fill=product)) +
                                      scale_y_continuous(labels=percent) +
                                      ggtitle(paste(countryHere)) +
                                      labs(y =paste0(varHere, ", shares")) +
                                      scale_color_manual(values=colorscheme_products) +
                                      scale_fill_manual(values=colorscheme_products) +
                                      facet_wrap(~ industry, ncol=4)
    #print(p.wrap5)
    ggsave(filename=paste(paste(countryHere,varHere,"ShareGFCF-bar5x",fileName.industry,sep="_"),"pdf",sep="."), width = 21, height = 18, units = c("cm"), dpi = 300)
    
    p.wrap3 <- temp.wrap.shares3 %>%  ggplot(aes(x=year, y=value)) +
                                      geom_bar(stat="identity", aes(fill=product)) +
                                      scale_y_continuous(labels=percent) +
                                      ggtitle(paste(countryHere)) +
                                      labs(y =paste0(varHere, ", shares")) +
                                      scale_color_manual(values=colorscheme_products3) +
                                      scale_fill_manual(values=colorscheme_products3) +
                                      facet_wrap(~ industry, ncol=4)
    #print(p.wrap3)
    ggsave(filename=paste(paste(countryHere,varHere,"ShareGFCF-bar3x",fileName.industry,sep="_"),"pdf",sep="."), width = 21, height = 18, units = c("cm"), dpi = 300)
  }   
} 

#---------------------------------------------------------------------------------------------------
folder <- paste0(PLOT,"/plotted_bars_structure/TraEq")
cat("Results will be located in",folder,"\n")
dir.create(folder, recursive=TRUE)
setwd(folder)

countries.short <- c("AUS","AUT","DNK","ESP","FIN","ITA","JPN","NLD" ,"UK","USA","FRA")

colour_industries12_TraEq <- c("#A6CEE3","#1F78B4","#01665E","#33A02C","#FB9A99","#E31A1C","#FDBF6F","#444444","#191970","#FFD700","#FF7F00","#6A3D9A")

for(countryHere in countries.short)
{
  for(varHere in c("I"))
  {
    for(productVector in c("TraEq"))
    {
      temp0             <- dsAgg %>% filter(country==countryHere, var==varHere, product %in% c(productVector,"GFCF"), industry %in% c(industryVector,"TOT"))
#      temp0             <- dsAgg %>% filter(var==varHere, product %in% productVector, industry %in% industryVector)
     
      temp.totGFCF      <- temp0 %>% filter(product=="GFCF", industry=="TOT")
      temp.totTraEq     <- temp0 %>% filter(product=="TraEq", industry=="TOT")
      temp              <- temp0 %>% filter(product %in% productVector, industry %in% industryVector)
      
      temp$product_Ind <- paste(temp$product, temp$industry, sep="_")
      temp             <- temp %>% select(-c(industry, product)) %>% 
                                   spread(product_Ind,value)
      temp.shares.GFCF  <-  dplyr::left_join(temp, temp.totGFCF, by = c("year","var","country")) %>% 
                            select(-c(product,industry)) %>%
                            mutate_each(funs(./value), -country, -var, -year, -value) %>% 
                            select(-c(value)) %>%
                            gather(product_Ind, value, -country, -var, -year)
      
      temp.shares.product <-  dplyr::left_join(temp, temp.totTraEq, by = c("year","var","country")) %>% 
                              select(-c(product,industry)) %>%
                              mutate_each(funs(./value), -country, -var, -year, -value) %>% 
                              select(-c(value)) %>%
                              gather(product_Ind, value, -country, -var, -year)
      
      product_IndVector <- c("TraEq_AtB","TraEq_C","TraEq_D","TraEq_E","TraEq_F","TraEq_GtH","TraEq_60t63","TraEq_64","TraEq_70","TraEq_LtQ","TraEq_J","TraEq_71t74") # K = "70" + "71t74"
      
      temp.shares.GFCF$product_Ind <- factor(temp.shares.GFCF$product_Ind, levels=product_IndVector)
      temp.shares.GFCF         <- temp.shares.GFCF[order(temp.shares.GFCF$product_Ind),]
      
      temp.shares.product$product_Ind <- factor(temp.shares.product$product_Ind, levels=product_IndVector)
      temp.shares.product         <- temp.shares.product[order(temp.shares.product$product_Ind),]
      
      p.GFCF <- temp.shares.GFCF %>%  ggplot(aes(x=year, y=value)) +
                geom_bar(stat="identity", aes(fill=product_Ind)) +
                scale_y_continuous(labels=percent) +
                ggtitle(paste(countryHere)) +
                labs(y =paste0(varHere, ", shares of total GFCF")) +
                scale_color_manual(values=colour_industries12_TraEq) +
                scale_fill_manual(values=colour_industries12_TraEq) 
                #facet_wrap(~ industry, ncol=4)
      print(p.GFCF)
      ggsave(filename=paste(paste(varHere,"ShareTraEq-bar",fileName.industry,countryHere,sep="_"),"pdf",sep="."), width = 21, height = 18, units = c("cm"), dpi = 300)
      
      p.TraEq <-  temp.shares.product %>%  ggplot(aes(x=year, y=value)) +
                  geom_bar(stat="identity", aes(fill=product_Ind)) +
                  scale_y_continuous(labels=percent) +
                  ggtitle(paste(countryHere)) +
                  labs(y =paste0(varHere,", shares of total TraEq")) +
                  scale_color_manual(values=colour_industries12_TraEq) +
                  scale_fill_manual(values=colour_industries12_TraEq) 
      #facet_wrap(~ industry, ncol=4)
      print(p.TraEq)
      ggsave(filename=paste(paste(varHere,"ShareGFCF-bar",fileName.industry,countryHere,sep="_"),"pdf",sep="."), width = 21, height = 18, units = c("cm"), dpi = 300)
      
    }
  }
}

#----------------------------------------------------------------------


  for(varHere in c("I"))
  {
    for(productVector in ("TraEq"))
    {
      temp0             <- dsAgg %>% filter(country %in% countries.short, var==varHere, product %in% c(productVector,"GFCF"), industry %in% c(industryVector,"TOT"))
      #      temp0             <- dsAgg %>% filter(var==varHere, product %in% productVector, industry %in% industryVector)
      
      temp.totGFCF      <- temp0 %>% filter(product=="GFCF", industry=="TOT")
      temp.totTraEq     <- temp0 %>% filter(product=="TraEq", industry=="TOT")
      temp              <- temp0 %>% filter(product %in% productVector, industry %in% industryVector)
      
      temp$product_Ind <- paste(temp$product, temp$industry, sep="_")
      temp             <- temp %>% select(-c(industry, product)) %>% 
                                   spread(product_Ind,value)
      temp.shares.GFCF  <-  dplyr::left_join(temp, temp.totGFCF, by = c("year","var","country")) %>% 
                            select(-c(product,industry)) %>%
                            mutate_each(funs(./value), -country, -var, -year, -value) %>% 
                            select(-c(value)) %>%
                            gather(product_Ind, value, -country, -var, -year)
      
      temp.shares.product <-  dplyr::left_join(temp, temp.totTraEq, by = c("year","var","country")) %>% 
        select(-c(product,industry)) %>%
        mutate_each(funs(./value), -country, -var, -year, -value) %>% 
        select(-c(value)) %>%
        gather(product_Ind, value, -country, -var, -year)
      
      product_IndVector <- industryVector12  <- c("TraEq_AtB","TraEq_C","TraEq_D","TraEq_E","TraEq_F","TraEq_GtH","TraEq_60t63","TraEq_64","TraEq_70","TraEq_LtQ","TraEq_J","TraEq_71t74") # K = "70" + "71t74"
      
      temp.shares.GFCF$product_Ind <- factor(temp.shares.GFCF$product_Ind, levels=product_IndVector)
      temp.shares.GFCF         <- temp.shares.GFCF[order(temp.shares.GFCF$product_Ind),]
      
      temp.shares.product$product_Ind <- factor(temp.shares.product$product_Ind, levels=product_IndVector)
      temp.shares.product         <- temp.shares.product[order(temp.shares.product$product_Ind),]
      
      p.wrap <- temp.shares.GFCF %>%  ggplot(aes(x=year, y=value)) +
                                      geom_bar(stat="identity", aes(fill=product_Ind)) +
                                      scale_y_continuous(labels=percent) +
                                      labs(y =paste0(varHere, ", shares of total GFCF")) +
                                      scale_color_manual(values=colour_industries12_TraEq) +
                                      scale_fill_manual(values=colour_industries12_TraEq) +
                                      facet_wrap(~ country, ncol=3)

      ggsave(filename=paste(paste(varHere,"ShareGFCF-bar",fileName.industry,sep="_"),"pdf",sep="."), width = 24, height = 30, units = c("cm"), dpi = 300)
      
      p.wrap.TraEq <- temp.shares.product %>% ggplot(aes(x=year, y=value)) +
                                              geom_bar(stat="identity", aes(fill=product_Ind)) +
                                              scale_y_continuous(labels=percent) +
                                              labs(y =paste0(varHere,", shares of total TraEq")) +
                                              scale_color_manual(values=colour_industries12_TraEq) +
                                              scale_fill_manual(values=colour_industries12_TraEq) +
                                              facet_wrap(~ country, ncol=3)
 
      ggsave(filename=paste(paste(varHere,"ShareTraEq-bar",fileName.industry,sep="_"),"pdf",sep="."), width = 24, height = 30, units = c("cm"), dpi = 300)
      
      p.wrap.1 <- subset(temp.shares.GFCF,country %in% countries.short[1:6] ) %>%  ggplot(aes(x=year, y=value)) +
                                      geom_bar(stat="identity", aes(fill=product_Ind)) +
                                      scale_y_continuous(labels=percent) +
                                      labs(y =paste0(varHere, ", shares of total GFCF")) +
                                      scale_color_manual(values=colour_industries12_TraEq) +
                                      scale_fill_manual(values=colour_industries12_TraEq) +
                                      facet_wrap(~ country, ncol=1)
      #print(p.wrap.1)
      
      p.wrap.2 <- subset(temp.shares.GFCF,country %in% countries.short[7:11] ) %>%  ggplot(aes(x=year, y=value)) +
                                      geom_bar(stat="identity", aes(fill=product_Ind)) +
                                      scale_y_continuous(labels=percent) +
                                      labs(y =paste0(varHere, ", shares of total GFCF")) +
                                      scale_color_manual(values=colour_industries12_TraEq) +
                                      scale_fill_manual(values=colour_industries12_TraEq) +
                                      theme(legend.position="none") +
                                      facet_wrap(~ country, ncol=1)
      #print(p.wrap.2)
      
      #ggsave(filename=paste(paste(varHere,"ShareTraEq-bar",fileName.industry,sep="_"),"pdf",sep="."), width = 10, height = 60, units = c("cm"), dpi = 300)
      
      p.wrap.TraEq.1 <-  subset(temp.shares.product, country %in% countries.short[1:6]) %>% ggplot(aes(x=year, y=value)) +
                                          geom_bar(stat="identity", aes(fill=product_Ind)) +
                                          scale_y_continuous(labels=percent) +
                                          labs(y =paste0(varHere,", shares of total TraEq")) +
                                          scale_color_manual(values=colour_industries12_TraEq) +
                                          scale_fill_manual(values=colour_industries12_TraEq) +
                                          theme(legend.position="none") +
                                          facet_wrap(~ country, ncol=1)
      #print(p.wrap.TraEq.1)
      
      p.wrap.TraEq.2 <-  subset(temp.shares.product, country %in% countries.short[7:11]) %>% ggplot(aes(x=year, y=value)) +
                                          geom_bar(stat="identity", aes(fill=product_Ind)) +
                                          scale_y_continuous(labels=percent) +
                                          labs(y =paste0(varHere,", shares of total TraEq")) +
                                          scale_color_manual(values=colour_industries12_TraEq) +
                                          scale_fill_manual(values=colour_industries12_TraEq) +
                                          theme(legend.position="none") +
                                          facet_wrap(~ country, ncol=1)
      #print(p.wrap.TraEq.2)
      #ggsave(filename=paste(paste(varHere,"ShareGFCF-bar",fileName.industry,sep="_"),"pdf",sep="."), width = 10, height = 60, units = c("cm"), dpi = 300)
      
    }
  }

g_legend<-function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  legend
}

#legend <- g_legend(p.wrap.1)
#plot(legend)

#p <- grid.arrange(p.wrap.1 + theme(legend.position = "none"), p.wrap.TraEq.1, p.wrap.2, p.wrap.TraEq.2,legend,layout_matrix = rbind(c(1,2,3,4,5),c(1,2,3,4,5),c(1,2,3,4,NA),c(1,2,3,4,NA),c(1,2,3,4,NA),c(1,2,NA,NA,NA)))#, widths =c(50,50,50,50),heights =c(400,400,400,400))
#plot(p)

#g <- arrangeGrob(p.wrap.1 + theme(legend.position = "none"), p.wrap.TraEq.1, p.wrap.2, p.wrap.TraEq.2,legend,layout_matrix = rbind(c(1,2,3,4,5),c(1,2,3,4,5),c(1,2,3,4,NA),c(1,2,3,4,NA),c(1,2,3,4,NA),c(1,2,NA,NA,NA)), widths =c(50,50,50,50,20))#, heights =c(400,400,400,400), top="Composition of investment in Travel equipment")
#ggsave("I_ShareGFCFTraEq-bar_12.pdf",g,width = 40, height = 60, units = c("cm"), dpi = 300)

#--------------------------------------------------------
folder <- paste0(PLOT,"/plotted_bars_structure/Con")
cat("Results will be located in",folder,"\n")
dir.create(folder, recursive=TRUE)
setwd(folder)

for(countryHere in c("USA"))
{
  for(varHere in c("I"))
  {
    for(productVector in c("RStruc","OCon"))
    {
      temp0             <- dsAgg %>% filter(country==countryHere, var==varHere, product %in% c(productVector,"GFCF"), industry %in% c(industryVector,"TOT"))
      #      temp0             <- dsAgg %>% filter(var==varHere, product %in% productVector, industry %in% industryVector)
      temp0             <- temp0 %>% spread(product, value)
      temp0$Con         <- temp0$RStruc + temp0$OCon
      temp0             <- temp0 %>% gather(product, value, -country, -var, -year, -industry)
      
      temp.totGFCF      <- temp0 %>% filter(product=="GFCF", industry=="TOT")
      temp.totCon       <- temp0 %>% filter(product=="Con", industry=="TOT")
      temp              <- temp0 %>% filter(product %in% productVector, industry %in% industryVector)
      
      temp$product_Ind  <- paste(temp$product, temp$industry, sep="_")
      temp              <- temp %>% select(-c(industry, product)) %>% 
                                    spread(product_Ind,value)
      temp.shares.GFCF  <-  dplyr::left_join(temp, temp.totGFCF, by = c("year","var","country")) %>% 
                            select(-c(product,industry)) %>%
                            mutate_each(funs(./value), -country, -var, -year, -value) %>% 
                            select(-c(value)) %>%
                            gather(product_Ind, value, -country, -var, -year) %>%
                            filter(product_Ind %in% c("OCon_AtB","OCon_C","OCon_D","OCon_E","OCon_F","OCon_GtH","OCon_60t63","OCon_64","OCon_J","OCon_70","OCon_71t74","OCon_LtQ","RStruc_AtB","RStruc_70","RStruc_LtQ"))
      
      temp.OConsum.shares.GFCF.OConsum <- temp.shares.GFCF %>%  spread(product_Ind,value) %>%
                                                                mutate(OConSum=OCon_AtB + OCon_D + OCon_E + OCon_F + OCon_60t63 + OCon_64 + OCon_J + OCon_71t74) %>%
                                                                select(-c(OCon_AtB,OCon_D,OCon_E,OCon_F,OCon_60t63,OCon_64,OCon_J,OCon_71t74)) %>%
                                                                gather(product_Ind,value,-country,-var,-year)

      
      temp.shares.GFCF.rel <- temp.shares.GFCF %>%  spread(product_Ind, value) %>% 
                                                    filter(!year %in% c("2008","2009","2010")) %>%
                                                    mutate_each(funs(./mean(.)), -country, -var, -year) %>%
                                                    gather(product_Ind, value, -country, -var, -year)
        
      temp.shares.product <-  dplyr::left_join(temp, temp.totCon, by = c("year","var","country")) %>% 
                              select(-c(product,industry)) %>%
                              mutate_each(funs(./value), -country, -var, -year, -value) %>% 
                              select(-c(value)) %>%
                              gather(product_Ind, value, -country, -var, -year) %>%
                              filter(product_Ind %in% c("OCon_AtB","OCon_C","OCon_D","OCon_E","OCon_F","OCon_GtH","OCon_60t63","OCon_64","OCon_J","OCon_70","OCon_71t74","OCon_LtQ","RStruc_AtB","RStruc_70","RStruc_LtQ"))
      
      product_IndVector <- c("OCon_AtB","OCon_C","OCon_D","OCon_E","OCon_F","OCon_GtH","OCon_60t63","OCon_64","OCon_J","OCon_70","OCon_71t74","OCon_LtQ","RStruc_AtB","RStruc_70","RStruc_LtQ") # K = "70" + "71t74"
      
      temp.shares.GFCF$product_Ind <- factor(temp.shares.GFCF$product_Ind, levels=product_IndVector)
      temp.shares.GFCF         <- temp.shares.GFCF[order(temp.shares.GFCF$product_Ind),]
      
      temp.shares.product$product_Ind <- factor(temp.shares.product$product_Ind, levels=product_IndVector)
      temp.shares.product             <- temp.shares.product[order(temp.shares.product$product_Ind),]
      
      temp.shares.GFCF.rel$product_Ind <- factor(temp.shares.GFCF.rel$product_Ind, levels=product_IndVector)
      temp.shares.GFCF.rel             <- temp.shares.GFCF.rel[order(temp.shares.GFCF.rel$product_Ind),] %>%
                                          filter(product_Ind %in% c("OCon_70","RStruc_70"))  
      
      p.GFCF <- temp.shares.GFCF.rel %>%  ggplot(aes(x=year, y=value, colour=product_Ind)) +
                                      #geom_bar(stat="identity", aes(fill=product_Ind)) +
                                      geom_line() +
                                      scale_y_continuous(labels=percent) +
                                      ggtitle(paste(countryHere)) +
                                      labs(y =paste0(varHere, ", shares of total GFCF")) +
                                      scale_color_manual(values=c(colour_industries12,"#800000","#FF00FF","#CCCCCC")) #+
                                      #scale_fill_manual(values=c(colour_industries12,"#800000","#FF00FF","#CCCCCC"))
      #facet_wrap(~ industry, ncol=4)
      print(p.GFCF)
      ggsave(filename=paste(paste(varHere,"ShareGFCFrel-Con70-line",fileName.industry,countryHere,sep="_"),"pdf",sep="."), width = 16, height = 16, units = c("cm"), dpi = 300)
    
      temp.OConsum.shares.GFCF.OConsum
      
      p.GFCF.Sum <-  temp.OConsum.shares.GFCF.OConsum %>%  ggplot(aes(x=year, y=value, colour=product_Ind)) +
                                          #geom_bar(stat="identity", aes(fill=product_Ind)) +
                                          geom_line() +
                                          scale_y_continuous(labels=percent) +
                                          ggtitle(paste(countryHere)) +
                                          labs(y =paste0(varHere, ", shares of total GFCF")) +
                                          scale_color_manual(values=c(colour_industries12,"#800000","#FF00FF","#CCCCCC")) #+
                                          #scale_fill_manual(values=c(colour_industries12,"#800000","#FF00FF","#CCCCCC"))
      
      print(p.GFCF.Sum)
      ggsave(filename=paste(paste(varHere,"ShareGFCFrel-ConSum-line",fileName.industry,countryHere,sep="_"),"pdf",sep="."), width = 16, height = 16, units = c("cm"), dpi = 300)
      
      
      p.Con <-  temp.shares.product %>% ggplot(aes(x=year, y=value)) +
                                          geom_bar(stat="identity", aes(fill=product_Ind)) +
                                          scale_y_continuous(labels=percent) +
                                          ggtitle(paste(countryHere)) +
                                          labs(y =paste0(varHere,", shares of total TraEq")) +
                                          scale_color_manual(values=c(colour_industries12,colour_industries12)) +
                                          scale_fill_manual(values=c(colour_industries12,colour_industries12)) 
      #facet_wrap(~ industry, ncol=4)
      print(p.Con)
      #ggsave(filename=paste(paste(varHere,"ShareCon-bar",fileName.industry,countryHere,sep="_"),"pdf",sep="."), width = 21, height = 18, units = c("cm"), dpi = 300)
      
    }
  }
}




