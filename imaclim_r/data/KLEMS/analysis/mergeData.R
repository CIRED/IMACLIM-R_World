// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Liesbeth Defosse
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


initData <- eval(parse(text=paste("dg",regionsK[1],sep=".")))  #regionsK  <- c("europeK","france")
newData  <- initData

for (region in regionsK[-1])
{
  addlData = eval(parse(text=paste("dg",region,sep=".")))
  newData <- rbind(newData,addlData)
}  


years      = unique( newData$year     )
countries  = unique( newData$country  )
vars       = unique( newData$var      )
products   = unique( newData$product  )
industries = unique( newData$industry )

dg <- newData

allMissing <- expand.grid(year=years,country=factor(countries),var=factor(vars),product=factor(products),industry=factor(industries))
left_join(allMissing,newData) -> test

rm(region,initData,addlData,newData)

#dg.europeD %>% filter(industry %in% industries) -> dg.europeD.40ind

#------------------------------------------------------------------------------------

ds1 <- dgYear.europeD 
ds2 <- dg %>% spread(year, value, fill = NA, convert = FALSE, drop = TRUE) 

dsYear <- bind_rows(ds2,ds1)
dsYear$country <- as.factor(dsYear$country)
dsYear$var <- as.factor(dsYear$var)
dsYear$industry <- as.factor(dsYear$industry)

#print(head(ds))

ds <- gather(dsYear, year, value, -country, -var, -industry, -product, factor_key = FALSE, convert=FALSE)
ds$year <- as.integer(ds$year)

countriesD = unique( ds$country  )


