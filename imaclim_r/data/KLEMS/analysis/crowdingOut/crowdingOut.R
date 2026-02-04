// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

#Graphs that show both evolution in RStruc and OCon, coming from all industries.

growthRate <- function(x)
{
  (x-lag(x))/lag(x)
}
#--------------------------------------------------------------------------------------------------------------
add.growthRates.1Country <- function(df, varHere, countryHere, industryHere, productHere)
{
  if(is.null(productHere)) 
  {
    df %>% filter(var==varHere, country==countryHere, industry==industryHere )  -> temp
  }
  else
  {
    df %>% filter(var==varHere, country==countryHere, industry==industryHere, product==productHere)  -> temp 
  }
  temp %>% spread(var,value)  -> temp
  
  temp <- mutate_each(temp, funs(g=growthRate(.)), -country, -product, -industry, -year)
  colnames(temp)[which(names(temp) == "g")] <- paste("g", varHere, sep="_")
  return(temp)
}
#--------------------------------------------------------------------------------------------------------------
add.growthRates.1Country.detrend <- function(df, varHere, countryHere, industryHere, productHere=NULL)
{
  if(is.null(productHere)) 
  {
    df %>% filter(var==varHere, country==countryHere, industry==industryHere )  -> temp
  }
  else
  {
    df %>% filter(var==varHere, country==countryHere, industry==industryHere)  -> temp 
  }
  temp %>% spread(var,value)  -> temp
  lm.res <- lm(I_VA ~ year, data=temp)
  if(length(lm.res$residuals)<42)
  { temp$res <- c(rep(NA,length(years)-length(lm.res$residuals)-3),lm.res$residuals) } else { temp$res <- lm.res$residuals }
  temp <- temp %>% select(-I_VA)
  temp <- mutate_each(temp, funs(g=growthRate(.)), -country, -industry, -year)
  colnames(temp)[which(names(temp) == "g")] <- paste("g", varHere, "res",sep="_")
  return(temp)
}

#--------------------------------------------------------------------------------------------------------------
add.growthRates.prod <- function(df, varH, countryH, industryH, productList)
{
  gr.init <- add.growthRates.1Country(df, varH, countryH ,industryH, productList[1])
  gr.newData  <- gr.init
  
  for( productHere in productList[-1] )
  {
    gr.addl <- add.growthRates.1Country(df, varH, countryH, industryH, productHere)
    gr.newData <- bind_rows(gr.newData,gr.addl)
  }
  return(gr.newData)
}

#--------------------------------------------------------------------------------------------------------------
add.growthRates.ind <- function(df, varH, countryH, industryList, productH)
{
  gr.init <- add.growthRates.1Country(df, varH, countryH ,industryList[1], productH)
  gr.newData  <- gr.init
  
  for( industryHere in industryList[-1] )
  {
    gr.addl <- add.growthRates.1Country(df, varH, countryH, industryHere, productH)
    gr.newData <- bind_rows(gr.newData,gr.addl)
  }
  return(gr.newData)
}

#--------------------------------------------------------------------------------------------------------------
add.growthRates.ind.detrend <- function(df, varH, countryH, industryList, productH=NULL)
{
  gr.init <- add.growthRates.1Country.detrend(df, varH, countryH ,industryList[1], productH)
  gr.newData  <- gr.init
  
  for( industryHere in industryList[-1] )
  {
    gr.addl <- add.growthRates.1Country.detrend(df, varH, countryH, industryHere, productH)
    gr.newData <- bind_rows(gr.newData,gr.addl)
  }
  return(gr.newData)
}

#------------------------------------------------------------
industryVector12  <- c("AtB","C","D","E","F","GtH","60t63","64","J","70","71t74","LtQ") # K = "70" + "71t74"
industryLabels12  <- c("Agr","Mining","Manufact","Elec Gas","Construc","Sales","Transport","Post Telecomm","Finance","Real estate","Rental","Community")

testLies <- add.growthRates.ind(dgAgg, "I", countries[1], industryVector12, c("GFCF"))

temp.init <- add.growthRates(dgAgg, "I", countries[1], industryVector12, c("GFCF")) %>% select (-c(I))
temp.final <- temp.init
for(countryHere in countries[-1])
{
  temp        <- add.growthRates(dgAgg, "I", countryHere, "TOT", c("RStruc", "OCon")) %>% select (-c(I))
  temp.final  <- bind_rows(temp.final,temp)
}

temp.final <- temp.final %>% spread(product, g_I)

p <-  ggplot(temp.final, aes( x=RStruc, y=OCon)) + 
      geom_point(size=1.1) + 
      stat_summary(fun.data=mean_cl_normal) + 
      geom_smooth(method='lm') +
      scale_y_continuous(labels=percent) +
      scale_x_continuous(labels=percent) +
      facet_wrap(~ country, ncol=2,scales = "free") +
      ggtitle(paste("I growth rates",industryHere,sep=", ")) +
      scale_color_manual(values=c("#333333", "#191970", "#2f4ea3" ))
print(p)
ggsave(filename=paste(paste("I_growthrates_Constr",industryHere,sep="-"),"pdf",sep="."), width = 18, height = 36, units = c("cm"), dpi = 300)

#------------------------------------------------------------------------------------------------
#Same as above but on shares of VA

  temp.I <- dgAgg %>% filter(var==varHere, industry %in% industryVector12, product=="GFCF", country %in% countries) %>% spread(industry,value)
  temp.VA <- dsAgg %>% filter(var=="VA", industry %in% "TOT", country %in% countries) %>% select(-product)  %>% spread(var,value)
  temp <- left_join(temp.I, temp.VA, by=c("year", "country")) %>% select(-c(industry, product))
  temp.I_VA <- temp %>%  mutate_each(funs(./VA), -year, -country,-var,-VA) %>% select(-c(VA,var)) %>% gather(industry, value, -year,-country)
  temp.I_VA$industry  <- as.factor(temp.I_VA$industry)
  temp.I_VA$country   <- as.factor(temp.I_VA$country)
  temp.I_VA$var       <- "I_VA"
  
  temp.init <- add.growthRates.ind.detrend(temp.I_VA, "I_VA", countries[1], industryList=industryVector12)
  temp.final <- temp.init
  for(countryHere in countries[-1])
  {
    temp        <- add.growthRates.ind.detrend(temp.I_VA, "I_VA", countryHere, industryList=industryVector12) #%>% select (-c(I))
    temp.final  <- bind_rows(temp.final,temp)
  }
 
  df.ind.detrend.I_VA <- temp.final %>% select(-res) %>% spread(industry, g_I_VA_res) 
#  temp.final <- temp.final %>% spread(product, g_I)
  
  for (industryHere in industryVector12)
  {
    temp1 <- temp1 %>% filter(industry==industryHere)
    temp.shares <- temp1 %>% spread(product, value) %>% 
                     # mutate(Con = OCon + RStruc) %>% 
                      mutate_each(funs(./GFCF),-GFCF, -country, -var, -industry, -year) %>% 
                      gather(product, value, -country, -var, -industry, -year) %>% 
                      filter(product %in% c("RStruc", "OCon", "Con"))
  }


temp.shares.init <- add.growthRates(temp.shares, "I", countries[1], "TOT", c("RStruc", "OCon")) %>% select (-c(I))
temp.shares.final <- temp.shares.init
for(countryHere in countries[-1])
{
  temp        <- add.growthRates(temp.shares, "I", countryHere, "TOT", c("RStruc", "OCon")) %>% select (-c(I))
  temp.shares.final  <- bind_rows(temp.shares.final,temp)
}

temp.shares.final <- temp.shares.final %>% spread(product, g_I)

p <-  ggplot(temp.shares.final, aes( x=RStruc, y=OCon, colour=year)) + 
      geom_point(size=1.1) + 
      #stat_summary(fun.data=mean_cl_normal) + 
      geom_smooth(method='lm') +
      scale_y_continuous(labels=percent) +
      scale_x_continuous(labels=percent) +
      facet_wrap(~ country, ncol=2,scales = "free") +
      scale_colour_continuous() +
      ggtitle(paste("I share growth rates",industryHere,sep=", "))
    
print(p)
ggsave(filename=paste(paste("I_share_growthrates_Constr",industryHere,sep="-"),"pdf",sep="."), width = 18, height = 36, units = c("cm"), dpi = 300)

for(countryHere in countries)
{
  filename <- paste(paste("lm","I_share_growthrates_Constr",countryHere,sep="-"),"txt",sep=".")
  sink(filename)
  print(summary(lm(OCon ~ RStruc, data = subset(temp.shares.final, country==countryHere))))
  sink()
}


#-------------------------------------------------------------------------------------------------------------
#First do linear regresssions on the variables and work with the residuals, to get out overall trend.

#temp.lm <- dgAgg %>% filter(var %in% "I", industry=="TOT", product %in% c("RStruc", "OCon"), country %in% c("USA","AUS"))
temp.lm <- temp
temp.lm.residuals <- temp.lm %>% subset(!country %in% c("USA","AUS") & !product==c("RStruc","OCon"))
temp.lm.residuals$residuals <- rep(0,dim(temp.lm.residuals)[1])

for(countryHere in c("USA","AUS"))
{
  for(productHere in c("RStruc", "OCon"))
  {
    tempLies <- temp.lm %>% subset(country==countryHere & product==productHere)
    tempLies$year2 <- tempLies$year^2
    #res.lm.Lies <- lm(value ~ year, data=tempLies)
    res.lm.Lies2 <- lm(value ~ year + year2, data=tempLies)
    summary(res.lm.Lies2)
    tempLies$residuals <- residuals(res.lm.Lies2)
    temp.lm.residuals <- dplyr::bind_rows(temp.lm.residuals, tempLies)
  }
}

p <-  ggplot(temp.lm.residuals, aes( x=year, y=residuals, colour=product)) + 
      geom_line(size=1.1) + 
      #stat_summary(fun.data=mean_cl_normal) + 
      #geom_smooth(method='lm') +
      #scale_y_continuous(labels=percent) +
      #scale_x_continuous(labels=percent) +
      facet_wrap(~ country, ncol=2,scales = "free") +
      #ggtitle(paste("I growth rates",industryHere,sep=", ")) +
      scale_color_manual(values=c("#191970", "#2f4ea3"))
print(p)

#now plot growth rates of the detrended data





#tempLies <- temp.lm %>% spread(product,value) %>% subset(country=="USA")

# plot GFCF shares of construction related investment
for(varHere in "I")
{
  temp1 <- dgAgg %>% filter(var==varHere)
  for (industryHere in "TOT")
  {
    temp1 <- temp1 %>% filter(industry==industryHere)
    #for(countryHere in "USA")
    #{
    #temp <- temp1 %>% filter(country==countryHere) %>% 
    temp <- temp1 %>% spread(product, value) %>% 
            mutate(Con = OCon + RStruc) %>% 
            mutate_each(funs(g=growthRate(.)),-GFCF, -country, -var, -industry, -year) %>% 
            gather(product, value, -country, -var, -industry, -year) %>% 
            filter(product %in% c("RStruc", "OCon", "Con"))
    
    p <-  ggplot(temp, aes( x=year, y=value, color=product)) + 
          geom_line(size=1.1) + 
          scale_y_continuous(labels=percent) +
          facet_wrap(~ country, ncol=2,scales = "free") +
          ggtitle(paste("I share",industryHere, sep=", ")) +
          labs(y = "I / I_GFCF") +
          scale_color_manual(values=c("#333333", "#191970", "#2f4ea3" ))
    print(p)
    ggsave(filename=paste(paste("I_growthrates_Constr",industryHere,sep="-"),"pdf",sep="."), width = 18, height = 36, units = c("cm"), dpi = 300)
    #}
  }
}


# plot GFCF shares of construction related investment
for(varHere in "I")
{
  temp1 <- dgAgg %>% filter(var==varHere)
  for (industryHere in "TOT")
  {
    temp1 <- temp1 %>% filter(industry==industryHere)
    #for(countryHere in "USA")
    #{
    #temp <- temp1 %>% filter(country==countryHere) %>% 
    temp <- temp1 %>% spread(product, value) %>% 
            mutate(Con = OCon + RStruc) %>% 
            mutate_each(funs(./GFCF),-GFCF, -country, -var, -industry, -year) %>% 
            gather(product, value, -country, -var, -industry, -year) %>% 
            filter(product %in% c("RStruc", "OCon", "Con"))
    
    p <-  ggplot(temp, aes( x=year, y=value, color=product)) + 
          geom_line(size=1.1) + 
          scale_y_continuous(labels=percent) +
          facet_wrap(~ country, ncol=2,scales = "free") +
          ggtitle(paste("I share",industryHere, sep=", ")) +
          labs(y = "I / I_GFCF") +
          scale_color_manual(values=c("#333333", "#191970", "#2f4ea3" ))
    print(p)
    ggsave(filename=paste(paste("I_Share_Constr",industryHere,sep="-"),"pdf",sep="."), width = 18, height = 36, units = c("cm"), dpi = 300)
    #}
  }
}













# linegraphs with investment in either on it

temp.con <- dsAgg %>%  filter(product %in% c("RStruc","OCon"), var %in% c("I","VA"))

countryHere <- "USA"
temp.con1Country <- temp.con %>%  filter(country==countryHere)

p <- ggplot(temp.con, aes(x=year, y=product,aes=industry))




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
    #ggsave(filename=paste(paste("I-VA-Industry",countryHere,sep="-") ,"pdf",sep=".")) 
  }
}
