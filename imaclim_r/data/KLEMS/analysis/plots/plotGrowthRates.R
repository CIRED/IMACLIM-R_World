// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


folder <- paste0(PLOT,"/plottedGrowthRates/")
cat("Results will be located in",folder,"\n")
dir.create(folder, recursive=TRUE)
setwd(folder)


#------------------------------------------------------------------------------------

growthRate <- function(x)
{
  (x-lag(x))/lag(x)
}

#------------------------------------------------------------------------------------

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
  colnames(temp)[which(names(temp) == "g")] <- paste("g", varHere,sep="_")
  return(temp)
}
#------------------------------------------------------------------------------------

add.growthRates <- function(df, countriesList, varH, industryH, productH)
{
    gr.init <- add.growthRates.1Country(df, varH, countriesList[1], industryH, productH)
    gr.newData  <- gr.init
    
    for( countryHere in countriesList[-1] )
    {
      gr.addl <- add.growthRates.1Country(df, varH, countryHere, industryH, productH)
      gr.newData <- bind_rows(gr.newData,gr.addl)
    }
    return(gr.newData)
}
#------------------------------------------------------------------------------------

gr1 <- add.growthRates(ds, as.vector(countries), "K",  "TOT", "GFCF")
gr2 <- add.growthRates(ds, as.vector(countries), "VA_QI",  "TOT", NULL)
gr0 <- left_join(gr1,gr2,by=c("country","year","industry"))

graph <- qplot(g_K, g_VA_QI, data=gr0, color = country, xlim=c(0,0.2), ylim=c(0,0.2) )
plot(graph) 
ggsave("K_VA_Countries_GFCF_TOT.pdf")


gr1 <- add.growthRates(ds, as.vector(countries), "K",  "TOT", "NonICT")
gr2 <- add.growthRates(ds, as.vector(countries), "VA_QI",  "TOT", NULL)
gr0 <- left_join(gr1,gr2,by=c("country","year","industry"))

graph <- qplot(g_K, g_VA_QI, data=gr0, color = country, xlim=c(0,0.2), ylim=c(0,0.2) )
plot(graph) 
ggsave("K_VA_Countries_NonICT_TOT.pdf")


gr1 <- add.growthRates(ds, as.vector(countries), "K",  "TOT", "ICT")
gr2 <- add.growthRates(ds, as.vector(countries), "VA_QI",  "TOT", NULL)
gr0 <- left_join(gr1,gr2,by=c("country","year","industry"))

graph <- qplot(g_K, g_VA_QI, data=gr0, color = country, xlim=c(0,0.2), ylim=c(0,0.2) )
plot(graph) 
ggsave("K_VA_Countries_ICT_TOT.pdf")


countriesD <- unique(ds$country)
gr1 <- add.growthRates(ds, as.vector(countries), "H_EMP",  "TOT", NULL)
gr2 <- add.growthRates(ds, as.vector(countries), "VA_QI",  "TOT", NULL)
gr0 <- left_join(gr1,gr2,by=c("country","year","industry"))

graph <- qplot(g_H_EMP, g_VA_QI, data=gr0, color = country,xlim=c(0,0.2), ylim=c(0,0.2))
plot(graph) 
ggsave("H_EMP_VA_Countries_TOT.pdf")
