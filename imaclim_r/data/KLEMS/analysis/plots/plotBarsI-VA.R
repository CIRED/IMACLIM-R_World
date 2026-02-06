# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

colorscheme_products=c("#191970", "#3b54af", "#8B4513", "#D55E00", "#A52A2A","#009E73","#ADFF2F","#228B22")

folder <- paste0(PLOT,"/plotted_bars_I-VA/industries/")
cat("Results will be located in",folder,"\n")
dir.create(folder, recursive=TRUE)
setwd(folder)

#------------------------bargraphs all countries on 1 page, page per industry, 
#each graph details asset as shares of total value added, for the whole economy.
for (varHere in "I")
{
  temp1 <- dsAgg %>% dplyr::filter(var=="VA", industry=="TOT", country %in% as.vector(countries13)) %>% select(-product,-industry) %>% spread(var,value)
  temp00 <- dsAgg %>% dplyr::filter(var=="I", country %in% as.vector(countries13))
  
  for(industryHere in "TOT")
  {
    temp0 <- temp00 %>% filter(industry==industryHere) %>% spread(product,value) 
    temp0$industry <- factor(temp0$industry, industryVector, labels=industryLabels)
    temp  <- left_join(temp1,temp0, by=c("country","year")) %>% 
              select(-c(GFCF, NonICT, ICT)) %>%
              mutate_each(funs(./VA), -country, -industry, -year, -VA, -var) %>%
              gather(product, value, -country, -industry, -year, -VA, -var) 
    temp$product <- factor(temp$product, levels=c("RStruc","OCon","OMach","TraEq","Other","CT","IT","Soft"))
    temp         <- temp[order(temp$product),]
    temp$var     <- "I_VA"
 
    p.wrap <- temp %>%  ggplot(aes(x=year, y=value)) +
                        geom_bar(stat="identity", aes(fill=product)) +
                        scale_y_continuous(labels=percent) +
                        ggtitle(paste(industryHere)) +
                        labs(y =paste0(varHere, ", shares")) +
                        scale_color_manual(values=c) +
                        scale_fill_manual(values=colorscheme_products) +
                        facet_wrap(~ country, ncol=5)
    print(p.wrap)
    ggsave(filename=paste(paste(varHere,"I-VA_bar8x",industryHere,sep="_"),"pdf",sep="."), width = 26, height = 21, units = c("cm"), dpi = 300)
  }

  folder <- paste0(PLOT,"/plotted_bars_I-VA/industries/countries13/evol/")
  cat("Results will be located in",folder,"\n")
  dir.create(folder, recursive=TRUE)
  setwd(folder)
    
  for(industryHere in c(industryVector12,"TOT"))
  {
    temp0 <- temp00 %>% filter(industry==industryHere) %>% spread(product,value) 
    temp0$industry <- factor(temp0$industry, c(industryVector,"TOT"), labels=c(industryLabels,"Total"))
    temp  <- left_join(temp1,temp0, by=c("country","year")) %>% 
              select(-c(GFCF, NonICT, ICT)) %>%
              mutate_each(funs(./VA), -country, -industry, -year, -VA, -var) %>%
              gather(product, value, -country, -industry, -year, -VA, -var) 
    temp$product <- factor(temp$product, levels=c("RStruc","OCon","OMach","TraEq","Other","CT","IT","Soft"))
    temp         <- temp[order(temp$product),]
    temp$var     <- "I_VA"
    
    
    temp.rel <- temp %>% select(-VA) %>% spread(year, value)
    #temp.rel$base <- temp.rel[colnames(temp.rel)=="1970"]
    #temp.rel <- temp.rel %>% select(-base.1970)
    #colnames(temp.rel)[length(colnames(temp.rel))] <- "base"
    temp.rel$base <- 1
    
    for(countryHere in c("AUS","DNK","ESP","FIN","ITA","NLD","UK","FRA"))
    {
      temp.rel$base[temp.rel$country==countryHere] <- temp.rel[temp.rel$country==countryHere,colnames(temp.rel)=="1970"]
    }
    temp.rel$base[temp.rel$country=="AUT"] <- temp.rel[temp.rel$country=="AUT",colnames(temp.rel)=="1976"]
    #temp.rel$base[temp.rel$country=="CZE"] <- temp.rel[temp.rel$country=="CZE",colnames(temp.rel)=="1976"]
    temp.rel$base[temp.rel$country=="GER"] <- temp.rel[temp.rel$country=="GER",colnames(temp.rel)=="1991"]
    temp.rel$base[temp.rel$country=="JPN"] <- temp.rel[temp.rel$country=="JPN",colnames(temp.rel)=="1973"]
    temp.rel$base[temp.rel$country=="SWE"] <- temp.rel[temp.rel$country=="SWE",colnames(temp.rel)=="1993"]
    temp.rel$base[temp.rel$country=="USA"] <- temp.rel[temp.rel$country=="USA",colnames(temp.rel)=="1977"]    
    
    temp.rel <- temp.rel %>% mutate_each(funs(./base), -country,-var, -industry, -product, -base) %>% select(-base) %>%
                             gather(year, value, -country, -var, -industry, -product)
    temp.rel$year <- as.integer(temp.rel$year)
    
     
    p.wrap.line <- temp.rel %>% filter(product %in% c("RStruc","OCon","OMach","TraEq")) %>% ggplot(aes(x=year, y=value, colour=product)) +
                            geom_line(size=1) +
                           ylim(0,2) +
                            labs(y ="evolution I/VA") +
                            ggtitle(paste(industryHere)) +
                            scale_color_manual(values=colorscheme_products) +
                            facet_wrap(~ country, ncol=4)
#    print(p.wrap.line)
    ggsave(filename=paste(paste(varHere,"I-VA_evol4x_zoom2",industryHere,sep="_"),"pdf",sep="."), width = 26, height = 30, units = c("cm"), dpi = 300)
  } 
}

#------------------------bargraphs all countries on 1 page, page per industry, 
#each graph details asset detail as shares of total investment by that industry.

for (varHere in "I")
{
  #temp1 <- dsAgg %>% dplyr::filter(var=="I", product=="GFCF", country %in% as.vector(countries13), industry %in% industryVector) %>% spread(var,value)
  temp00 <- dsAgg %>% dplyr::filter(var=="I", country %in% as.vector(countries13))
  
  for(industryHere in "TOT")
  {
    temp0 <- temp00 %>% filter(industry==industryHere) %>% spread(product,value)
    #temp0$industry <- factor(temp0$industry, industryVector, labels=industryLabels)
    #temp  <- left_join(temp1,temp0, by=c("country","year")) %>% 
    #         select(-c(GFCF, NonICT, ICT)) %>%
    temp <- temp0 %>% mutate_each(funs(./GFCF), -country, -industry, -year, -GFCF, -var) %>% select(-c(GFCF,NonICT,ICT)) %>%
             gather(product, value, -country, -var, -year, -industry) 
    temp$product <- factor(temp$product, levels=c("RStruc","OCon","OMach","TraEq","Other","CT","IT","Soft"))
    temp         <- temp[order(temp$product),]
    
    p.wrap <- temp %>%  ggplot(aes(x=year, y=value)) +
                        geom_bar(stat="identity", aes(fill=product)) +
                        scale_y_continuous(labels=percent) +
                        ggtitle(paste(industryHere)) +
                        labs(y =paste0(varHere, ", shares")) +
                        scale_color_manual(values=c) +
                        scale_fill_manual(values=colorscheme_products) +
                        facet_wrap(~ country, ncol=5)
    print(p.wrap)
    ggsave(filename=paste(paste(varHere,"I-Iind_bar8x",industryHere,sep="_"),"pdf",sep="."), width = 26, height = 21, units = c("cm"), dpi = 300)
  } 
}

#------------------------bargraphs all countries on 1 page, page per product (which industries invest in the product), 
#each graph details asset detail as shares of total value added, for the whole economy.

folder <- paste0(PLOT,"/plotted_bars_I-VA/products/countries13/")
cat("Results will be located in",folder,"\n")
dir.create(folder, recursive=TRUE)
setwd(folder)

productVector  <- c("GFCF", "NonICT", "ICT", productVector8)
industryVector <- industryVector12
industryLabels <- industryLabels12
colour_industries12 <- c("#A6CEE3", "#1F78B4", "#01665E", "#33A02C", "#FB9A99", "#E31A1C", "#FDBF6F", "#444444","#FF7F00", "#191970", "#6A3D9A", "#FFD700")

countries13 <- c("AUS", "AUT" , "DNK" ,"ESP" ,"FIN", "GER" , "ITA", "JPN", "NLD" , "SWE", "UK"  ,"USA", "FRA")

for (varHere in "I")
{
  temp1 <- dsAgg %>% dplyr::filter(var=="VA", industry=="TOT", country %in% as.vector(countries13)) %>% select(-product,-industry) %>% spread(var,value)
  temp00 <- dsAgg %>% dplyr::filter(var=="I", industry %in% industryVector12, country %in% as.vector(countries13))
  
  for(productHere in productVector)
  {
    temp0 <- temp00 %>% filter(product==productHere) %>% spread(industry,value)
    temp  <-  left_join(temp1,temp0, by=c("country","year")) %>%
              mutate_each(funs(./VA), -country, -product, -year, -VA, -var) %>%
              gather(industry, value, -country, -product, -year, -VA, -var) 
    temp$industry <- factor(temp$industry, levels=industryVector, labels=industryLabels)
    temp         <- temp[order(temp$industry),]
    
    p.wrap <- temp %>%  ggplot(aes(x=year, y=value)) +
                        geom_bar(stat="identity", aes(fill=industry)) +
                        scale_y_continuous(labels=percent) +
                        ggtitle(paste(productHere)) +
                        labs(y =paste0(varHere, ", shares")) +
                        scale_color_manual(values=c) +
                        scale_fill_manual(values=colour_industries12) +
                        facet_wrap(~ country, ncol=5)
    #print(p.wrap)
    ggsave(filename=paste(paste(varHere,"I-VA_bar12x",productHere,sep="_"),"pdf",sep="."), width = 26, height = 21, units = c("cm"), dpi = 300)
  } 
}

#------------------------bargraphs all countries on 1 page, page per asset (which industries invest in the product), 
#each graph details asset detail as shares of total investment in that asset, for the whole economy.

for (varHere in "I")
{
  temp1 <- dsAgg %>% dplyr::filter(var=="I", industry=="TOT", country %in% as.vector(countries13)) %>% spread(var,value) %>% select(-industry)
  temp00 <- dsAgg %>% dplyr::filter(var=="I", industry %in% industryVector12, country %in% as.vector(countries13))
  
  for(productHere in productVector)
  {
    temp2 <- temp1 %>% filter(product==productHere)
    temp0 <- temp00 %>% filter(product==productHere) %>% spread(industry,value)
    temp  <-  left_join(temp1,temp0, by=c("country","year","product")) %>%
      mutate_each(funs(./I), -country, -product, -year, -I, -var) %>%
      gather(industry, value, -country, -product, -year, -I, -var) 
    temp$industry <- factor(temp$industry, levels=industryVector, labels=industryLabels)
    temp         <- temp[order(temp$industry),]
    
    p.wrap <- temp %>%  ggplot(aes(x=year, y=value)) +
      geom_bar(stat="identity", aes(fill=industry)) +
      scale_y_continuous(labels=percent) +
      ggtitle(paste(productHere)) +
      labs(y =paste0(varHere, ", shares")) +
      scale_color_manual(values=c) +
      scale_fill_manual(values=colour_industries12) +
      facet_wrap(~ country, ncol=5)
    #print(p.wrap)
    ggsave(filename=paste(paste(varHere,"I-Iprod_bar12x",productHere,sep="_"),"pdf",sep="."), width = 26, height = 21, units = c("cm"), dpi = 300)
  } 
}

