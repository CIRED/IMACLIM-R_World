# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

folder <- paste0(PLOT,"/plottedProducts-bar/")
cat("Results will be located in",folder,"\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

#--------------------------------------------------------------------------------

colorscheme_products=c("#191970", "#203D8B", "#8B4513", "#D55E00", "#A52A2A","#009E73","#ADFF2F","#228B22")

#--------------------------------------------------------------------------------

for (yearHere in "2000")
{
  for (industryHere in "TOT")
  {
      temp1 <- ds %>% filter(!product %in% c("ICT","NonICT"), year==yearHere, var=="VA", country %in% as.vector(countries), industry==industryHere) %>% spread(var,value) %>% select(-c(product))
      temp2 <- ds %>% filter(!product %in% c("ICT","NonICT"), year==yearHere, var=="I", industry==industryHere) %>% spread(product,value)
      temp  <- left_join(temp1,temp2, by=c("country","industry","year")) %>% 
               mutate_each(funs(./VA), -country, -var, -industry, -year, -VA)
      temp$country <- reorder(temp$country, temp$GFCF)
      temp <- temp[order(temp$GFCF),] %>% select(-c(GFCF)) %>% gather(product, value, - country, -var, -industry, -year, -VA )
      
      temp$product <- factor(temp$product, levels=c("RStruc","OCon","OMach","TraEq","Other","CT","Soft","IT"))
      temp         <- temp[order(temp$product),]
      
      p <- ggplot(temp, aes( x=country, y=value, color=product)) +
           geom_bar(stat="identity", aes(fill=product)) + 
           scale_y_continuous(labels=percent,limits=c(0,0.355)) +
           ggtitle(paste("Composition of GFCF/VA", "all sectors,", yearHere, sep=" ")) +
           labs(y = "I / VA") +
           scale_color_manual(values=colorscheme_products) +
           scale_fill_manual(values=colorscheme_products)
      print(p)
      ggsave(filename=paste(paste("I_ShareVA",yearHere,industryHere,sep="-"),"pdf",sep="."))
  }
}
#--------------------------------------------------------------------------------

for (countryHere in countries)
{
  for (industryHere in "TOT")
  {
    temp1 <- ds %>% filter(!product %in% c("GFCF","ICT","NonICT"), country==countryHere, var=="VA", industry==industryHere) %>% spread(var,value) %>% select(-c(product))
    temp2 <- ds %>% filter(!product %in% c("GFCF","ICT","NonICT"), country==countryHere, var=="I", industry==industryHere) %>% spread(product,value)
    temp  <- left_join(temp1,temp2, by=c("country","industry","year")) %>% 
             mutate_each(funs(./VA), -country, -var, -industry, -year, -VA) %>% 
             gather(product, value, - country, -var, -industry, -year, -VA )
    
    temp$product <- factor(temp$product, levels=c("RStruc","OCon","OMach","TraEq","Other","CT","Soft","IT"))
    temp         <- temp[order(temp$product),]
    
    p <- ggplot(temp, aes( x=year, y=value, color=product)) +
         xlim(1970,2007) +
         geom_bar(stat="identity", aes(fill=product)) + 
         scale_y_continuous(labels=percent, limits=c(0,0.355)) +
         ggtitle(paste("Composition of GFCF/VA", "all sectors,", countryHere, sep=" ")) +
         labs(y = "I / VA") +
         scale_color_manual(values=colorscheme_products) +
         scale_fill_manual(values=colorscheme_products)
    print(p)
    ggsave(filename=paste(paste("I_ShareVA",countryHere,industryHere,sep="-") ,"pdf",sep="."))
  }
}
#--------------------------------------------------------------------------------


for (industryHere in industryVector12)
  {
    temp1 <- ds %>% filter(!product %in% c("GFCF","ICT","NonICT"), country==countryHere, var=="VA", industry==industryHere) %>% spread(var,value) %>% select(-c(product))
    temp2 <- ds %>% filter(!product %in% c("GFCF","ICT","NonICT"), country==countryHere, var=="I", industry==industryHere) %>% spread(product,value)
    temp  <- left_join(temp1,temp2, by=c("country","industry","year")) %>% 
      mutate_each(funs(./VA), -country, -var, -industry, -year, -VA) %>% 
      gather(product, value, - country, -var, -industry, -year, -VA )
    
    temp$product <- factor(temp$product, levels=c("RStruc","OCon","OMach","TraEq","Other","CT","Soft","IT"))
    temp         <- temp[order(temp$product),]
    
    p <- ggplot(temp, aes( x=year, y=value, color=product)) +
      xlim(1970,2007) +
      geom_bar(stat="identity", aes(fill=product)) + 
      scale_y_continuous(labels=percent, limits=c(0,0.355)) +
      ggtitle(paste("Composition of GFCF/VA", "all sectors,", countryHere, sep=" ")) +
      labs(y = "I / VA") +
      scale_color_manual(values=colorscheme_products) +
      scale_fill_manual(values=colorscheme_products) +
      facet_wrap()
    print(p)
    ggsave(filename=paste(paste("I_ShareVA",countryHere,industryHere,sep="-") ,"pdf",sep="."))
  }
#--------------------------------------------------------------------------------



for (countryHere in countries)
{
  for (industryHere in "TOT")
  {
    temp <- ds %>% filter(!product %in% c("GFCF","ICT","NonICT"), country==countryHere, var=="I", industry==industryHere) #%>% spread(product,value)
   
    temp$product <- factor(temp$product, levels=c("RStruc","OCon","OMach","TraEq","Other","CT","Soft","IT"))
    temp         <- temp[order(temp$product),]
    
    p <- ggplot(temp, aes( x=year, y=value, color=product)) +
      xlim(1970,2007) +
      geom_bar(stat="identity", aes(fill=product)) + 
      #scale_y_continuous(labels=percent, limits=c(0,0.355)) +
      ggtitle(paste("Composition of nominal investment in FC", "all sectors,", countryHere, sep=" ")) +
      labs(y = "I") +
      scale_color_manual(values=colorscheme_products) +
      scale_fill_manual(values=colorscheme_products)
    print(p)
    ggsave(filename=paste(paste("I",countryHere,industryHere,sep="-") ,"pdf",sep="."))
  }
}
