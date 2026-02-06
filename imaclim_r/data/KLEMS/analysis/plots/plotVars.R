# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

years <- unique(dg$year)
folder <- paste0(PLOT,"/plottedData/")
cat("Results will be located in",folder,"\n\n")
dir.create(folder)
setwd(folder)

#ruben <- dg %>% filter( var == "Iq",industry=="TOT") %>% ddply(~year~country,summarize,total=sum(value))
#ruben <- dg %>% filter( var == "Iq",industry=="TOT") # %>% ddply(~year~country,summarize,total=sum(value))

dg %>%
    filter(product!="GFCF"&product!="ICT"&product!="NonICT") %>%
    filter(var == "Ip",industry=="TOT") %>% 
    ggplot(aes(x=year,y=value,color=product)) +
    geom_line(size=1.1) +
    ggtitle("GFCF goods price index for all industries") +
    scale_y_continuous(labels=percent)  +
    facet_wrap( ~ country, ncol=4)  +
    theme(legend.position="bottom") +
    scale_color_manual(values=c("red", "black","green","blue","yellow", "grey","orange","purple")) -> p
ggsave("gfcfPriceIndexes.pdf")
p+coord_cartesian(ylim = c(0, 2))
ggsave("gfcfPriceIndexes-zoom.pdf")

dg %>%
    filter(product!="GFCF"&product!="ICT"&product!="NonICT") %>%
    filter(var == "CAP",industry=="TOT") %>% 
    ggplot(aes(x=year,y=value,color=product)) +
    geom_line(size=1.1) +
    ggtitle("Capital compensation") +
    facet_wrap( ~ country, ncol=4)  +
    theme(legend.position="bottom") +
    scale_color_manual(values=c("red", "black","green","blue","yellow", "grey","orange","purple")) -> p
ggsave("capitalCompensation.pdf")
p+coord_cartesian(ylim = c(0, 200000))
ggsave("capitalCompensation-zoom.pdf")

dg %>%
    filter(product!="GFCF"&product!="ICT"&product!="NonICT") %>%
    filter(var == "D",industry=="TOT") %>% 
    ggplot(aes(x=year,y=value,color=product)) +
    geom_line(size=1.1) +
    ggtitle("Fixed capital consumption") +
    facet_wrap( ~ country, ncol=4)  +
    theme(legend.position="bottom") +
    scale_color_manual(values=c("red", "black","green","blue","yellow", "grey","orange","purple")) -> p
ggsave("fixedCapitalConsumption.pdf")
p+coord_cartesian(ylim = c(0, 200000))
ggsave("fixedCapitalConsumption-zoom.pdf")


dg %>%
    filter(product!="GFCF"&product!="ICT"&product!="NonICT") %>%
    filter(var == "I",industry=="TOT") %>% 
    ddply(.(year,country), mutate, share = value / sum(value) ) %>% 
    ggplot(aes(x=year,y=share,color=product)) +
    geom_line(size=1.1) +
    ggtitle("Product shares in nominal GFCF") +
    scale_y_continuous(labels=percent)  +
    facet_wrap( ~ country, ncol=4)  +
    theme(legend.position="bottom") +
    scale_color_manual(values=c("red", "black","green","blue","yellow", "grey","orange","purple"))
ggsave("sharesNominalGFCF.pdf")

dg %>%
    filter(product!="GFCF"&product!="ICT"&product!="NonICT") %>%
    filter(var == "I",industry=="TOT") %>% 
    #ddply(.(year,country), mutate, share = value / sum(value) ) %>% 
    ggplot(aes(x=year,y=value,color=product)) +
    geom_line(size=1.1) +
    ggtitle("nominal GFCF") +
    facet_wrap( ~ country, ncol=4)  +
    theme(legend.position="bottom") +
    scale_color_manual(values=c("red", "black","green","blue","yellow", "grey","orange","purple"))
ggsave("nominalGFCF.pdf")

dg %>%
    filter(product!="GFCF"&product!="ICT"&product!="NonICT") %>%
    filter(var == "Iq",industry=="TOT") %>% 
    ddply(.(year,country), mutate, share = value / sum(value) ) %>% 
    ggplot(aes(x=year,y=share,color=product)) +
    geom_line(size=1.1) +
    ggtitle("Product shares in real GFCF") +
    scale_y_continuous(labels=percent)  +
    facet_wrap( ~ country, ncol=4)  +
    theme(legend.position="bottom") +
    scale_color_manual(values=c("red", "black","green","blue","yellow", "grey","orange","purple"))
ggsave("sharesRealGFCF.pdf")

dg %>%
    filter(product!="GFCF"&product!="ICT"&product!="NonICT") %>%
    filter(var=="I"|var == "Iq",industry=="TOT") %>% 
    ddply(.(year,country,var), mutate, share = value / sum(value) ) %>%
    filter(product=="RStruc"|product=="OCon") %>%
    ddply(.(year,country,var), summarize, consShare = sum(share) ) %>%
    ggplot(aes(x=year,y=consShare,color=var)) +
    geom_line(size=1.1) +
    ggtitle("Share of GFCF dedicated to construction") +
    scale_y_continuous(labels=percent)  +
    facet_wrap( ~ country, ncol=4)  +
    theme(legend.position="bottom") +
    scale_color_manual(values=c("red", "black")) +
    ggsave("shareConstInGFCF.pdf")

