# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

folder <- paste0(PLOT,"/plottedWhoInvests/")
cat("Results will be located in",folder,"\n")
dir.create(folder, recursive = TRUE)
setwd(folder)


for (countryHere in countries)
{
for (productHere in products) 
{

temp <- subset(dgAgg, var=="I" & country==countryHere & product==productHere & industry %in% c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ"))
temp$industry <- factor(temp$industry, c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ"), labels=c("Agr","Mining","Manufact","Elec Gas","Construc","Sales","Trans Comm","Finance","Real estate","RE Business","Community"))


temp %>%
  #filter(product!="GFCF"&product!="ICT"&product!="NonICT") %>%
  #filter(var == "Ip",industry=="TOT") %>% 
  ggplot(aes(x=year,y=value, color=industry, fill=industry)) +
  geom_bar(stat = "identity") +
  ggtitle(paste(productHere, ", capital formation, nominal,", countryHere)) +
  #scale_y_continuous(labels=percent)  +
  #facet_wrap( ~ country, ncol=4)  +
  theme(legend.position="bottom") +
  scale_color_manual(values=c("grey","grey","grey","grey","grey","grey","grey","grey","grey","grey","grey")) +
  scale_fill_manual(values=c("red", "black","green","blue","yellow", "darkblue", "white","grey","orange","purple", "darkgreen")) -> p

ggsave(filename=paste(paste("I", countryHere, productHere, sep="_"),"pdf", sep=".")

}
}

#------------------------------------------------------------The same plots as above, page per product
for (productHere in products) 
{
  
    temp <- subset(dgAgg, var=="I" & product==productHere & industry %in% c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ"))
    temp$industry <- factor(temp$industry, c("AtB","C","D","E","F","GtH","I","J","70","71t74","LtQ"), labels=c("Agr","Mining","Manufact","Elec Gas","Construc","Sales","Trans Comm","Finance","Real estate","RE Business","Community")) 
    
    temp %>%
      #filter(product!="GFCF"&product!="ICT"&product!="NonICT") %>%
      #filter(var == "Ip",industry=="TOT") %>% 
      ggplot(aes(x=year,y=value, color=industry, fill=industry)) +
      geom_bar(stat = "identity") +
      ggtitle(paste(productHere, ", capital formation, nominal")) +
      #scale_y_continuous(labels=percent)  +
      facet_wrap( ~ country, ncol=4, scales="free_y")  +
      theme(legend.position="bottom") +
      scale_color_manual(values=c("red", "black","green","blue","yellow", "darkblue", "white","grey","orange","purple", "darkgreen")) +
      scale_fill_manual(values=c("red", "black","green","blue","yellow", "darkblue", "white","grey","orange","purple", "darkgreen")) -> p
    
    ggsave(filename=paste(paste("I", productHere, sep="_"),"pdf", sep="."))        

}

