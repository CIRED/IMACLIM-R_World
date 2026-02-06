# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

folder <- paste0(PLOT,"/plotted_perCountry/")
cat("Results will be located in",folder,"\n")
dir.create(folder, recursive = TRUE)
setwd(folder)

#--------------------------------------------------------------------------------

#colorscheme_products=c("#191970", "#203D8B", "#8B4513", "#D55E00", "#A52A2A","#009E73","#ADFF2F","#228B22", "#AAAAAA","#666666","#000000")
colorscheme_products=c("#EC3A01", "#00CCFF","#FC0A74","green","blue","#FBE105", "#D55E00", "#009E73","#FC800A","#203D8B", "black")
colorscheme_industries=c("#191970", "#203D8B", "#8B4513", "#D55E00", "#A52A2A","#009E73","#ADFF2F","#228B22", "#AAAAAA","#666666","#000000")
colour_products8    <- c("#191970", "#203D8B", "#8B4513", "#D55E00", "#A52A2A", "#009E73", "#ADFF2F", "#228B22")
#define here on what selection industries
industryVectorGHIJK <- c("50", "51", "52", "H", "60t63", "64", "J","70","71t74")
industryLabelsGHIJK <- c("50", "51", "52", "H", "60t63", "64", "J","70","71t74")
industryVector <- "TOT" 
industryLabels <- "Total" 
fileName.industry <- "TOT"

temp00 <- dsAgg %>%  filter(industry %in% industryVector, var %in% c("I","VA"))
temp0 <- temp00 %>%  filter(product %in% productVector8, var %in% c("I"))
temp0$industry <- factor(temp0$industry, industryVector, industryLabels)
#industries11.temp <- unique(temp0$industry)
#temp0$product <- factor(temp0$product, levels=c("RStruc","OCon","OMach","TraEq","Other","CT","Soft","IT","NonICT","ICT","GFCF"))
temp0$product <- factor(temp0$product, levels=productVector8)
temp0         <- temp0[order(temp0$product),]
#productsL <- unique(temp0$product)
                   
#--------------------------------------------------------------------------------










for(countryHere in countries)
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




for (countryHere in "USA")
{
  # all industries on 1 plot, how does total investment (or in some prod-level) evolve 
    for (productHere in "GFCF")
    {
      temp1 <- temp0 %>% filter(country==countryHere, product==productHere, var=="I", !industry=="Total") %>% spread(var,value) %>% 
                      spread(industry,I)      
      temp2 <- temp0 %>% filter(country==countryHere, var=="VA", industry=="Total") %>% spread(var,value) %>% select(-c(product, industry))
      temp  <- left_join(temp1,temp2, by=c("country","year")) %>% 
               mutate_each(funs(./VA),-country, -product, -year, -VA) %>%
               gather(industry, I_VA, -country, -product, -year, -VA)
              # filter(industry %in% c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ"))#, "TOT"))
      #temp$industry <- factor(temp$industry, c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ"), labels=c("Agri","Mining","Manufacturing","Elec Gas Wtr","Construction","Sale","Transport Communication","Finance","Real estate","Real Estate Business","Community"))
    
      p <- ggplot(temp, aes( x=year, y=I_VA, color=industry)) +
        xlim(1970,2007) +
        geom_line(size=1.1) + 
        scale_y_continuous(labels=percent, limits=c(0,0.068)) +
        ggtitle(paste("I/VA per industry", countryHere, sep=", ")) +
        scale_color_manual(values=colorscheme_industries)
      print(p)
      ggsave(filename=paste(paste("I-VA-Industry",countryHere,sep="-") ,"pdf",sep=".")) 
    }
}
for (countryHere in countries)
  {  
  # per industry, how does investment in products evolve
  for (industryHere in industryLabels)
  {
    temp1 <- temp0 %>% filter(country==countryHere) %>% spread(var,value) %>% 
                    spread(product,I)      
    temp2 <- temp00 %>% filter(country==countryHere, var=="VA") %>% spread(var,value) %>% select(-c(product, industry))
    temp  <- left_join(temp1,temp2, by=c("country","year")) %>%
             mutate_each(funs(./VA),-country, -industry, -year, -VA) %>%
             gather(product, I_VA, -country, -industry, -year, -VA)
#    temp$product <- factor(temp$product, levels=c("RStruc","OCon","OMach","TraEq","Other","CT","Soft","IT","NonICT","ICT","GFCF"))
    temp$product <- factor(temp$product, levels=productVector8)
    temp         <- temp[order(temp$product),]
  
    p <- ggplot(temp, aes( x=year, y=I_VA, color=product)) +
      xlim(1970,2007) +
      geom_line(size=1.1) + 
      scale_y_continuous(labels=percent)+ #, limits=c(0,0.068)) +
      ggtitle(paste("I/VA per product", industryHere, countryHere, sep=", ")) +
      scale_color_manual(values=colour_products8 )
    print(p)
    ggsave(filename=paste(paste("I-VA",industryHere, countryHere,sep="-") ,"pdf",sep="."), width = 16, height = 16, units = c("cm"), dpi = 300) 
  }
}  
  #Wrapped graph
  industryHere=industryLabels[1]
  temp1 <- temp0 %>% filter(country==countryHere, industry==industryHere, var=="I") %>% spread(var,value) %>% 
                     spread(product,I)      
  temp2 <- ds %>% filter(country==countryHere, var=="VA", industry=="TOT") %>% spread(var,value) %>% select(-c(product, industry))
  temp.wrap  <- left_join(temp1,temp2, by=c("country","year")) %>%
                      mutate_each(funs(./VA),-country, -industry, -year, -VA) %>%
                      gather(product, I_VA, -country, -industry, -year, -VA)
  temp.wrap$product <- factor(temp.wrap$product, levels=c("RStruc","OCon","OMach","TraEq","Other","CT","Soft","IT","NonICT","ICT","GFCF"))
  temp.wrap         <- temp.wrap[order(temp.wrap$product),]
  for (industryHere in industryLabels[-1])
  {
    temp1 <- temp0 %>% filter(country==countryHere, industry==industryHere, var=="I") %>% spread(var,value) %>% 
                        spread(product,I)      
    temp2 <- ds %>% filter(country==countryHere, var=="VA", industry=="TOT") %>% spread(var,value) %>% select(-c(product, industry))
    temp  <- left_join(temp1,temp2, by=c("country","year")) %>%
                        mutate_each(funs(./VA),-country, -industry, -year, -VA) %>%
                        gather(product, I_VA, -country, -industry, -year, -VA)
    temp$product <- factor(temp$product, levels=c("RStruc","OCon","OMach","TraEq","Other","CT","Soft","IT","NonICT","ICT","GFCF"))
    temp         <- temp[order(temp$product),]
    temp.wrap     <- dplyr::bind_rows(temp.wrap, temp)
  }
  temp.wrap$product<- factor(temp$product, levels=c("RStruc","OCon","OMach","TraEq","Other","CT","Soft","IT","NonICT","ICT","GFCF"))
  temp.wrap        <- temp.wrap[order(temp.wrap$product),]
  
  p.wrap <- temp.wrap %>% ggplot(aes( x=year, y=I_VA, color=product)) +
                          xlim(1977,2007) +
                          geom_line(size=0.9) + 
                          scale_y_continuous(labels=percent)+ #, limits=c(0,0.068)) +
                          #ggtitle(paste("I/VA per product", industryHere, countryHere, sep=", ")) +
                          scale_color_manual(values=colorscheme_products) +
                          facet_wrap(~ industry, ncol=2,scales = "free") +
                          ggtitle(paste("I/VA", countryHere, sep=", "))
  print(p.wrap)
  ggsave(filename=paste(paste("I-VA", fileName.industry,countryHere,sep="-") ,"pdf",sep="."), width = 20, height = 50, units = c("cm"), dpi = 300) 
}
#--------------------------------------------------------------------------------