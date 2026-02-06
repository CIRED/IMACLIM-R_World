# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

regionsK  <- c("europeK","france")

for (region in regionsK) 
{
  file      <- paste(DATA,region,"DataMatrixwithValues.csv", sep=.Platform$file.sep)
  dfName    <- paste("dg",region,sep=".")
  assign(dfName,read.table(file,header=TRUE,sep="|",row.names=NULL))
  a <- eval(parse(text=dfName))
  print(paste("dg",region,sep="."))
  print(summary(a))
  rm(a)
  rm(dfName)
  rm(file)
  rm(region)
}

#------------------------------------------------

file           <- paste(DATAD,"europeD","all_countries_09I.csv", sep=.Platform$file.sep)
dgYear.europeD <- read.table(file,header=TRUE,sep="|",row.names=NULL)

yearsDtemp = unique(dgYear.europeD[0,4:ncol(dgYear.europeD)])

yearsD <- substr(colnames(yearsDtemp),2,nchar(colnames(yearsDtemp)))
yearsD <- as.integer(yearsD)

colnames(dgYear.europeD)[colnames(dgYear.europeD)==names(dgYear.europeD)]    <- c("country","var","industry",yearsD)

dg.europeD <- dgYear.europeD %>% gather(year, value, -var, -country, -industry, factor_key = FALSE)

dg.europeD$year <- as.integer(dg.europeD$year)

print("dg.europeD")
print(summary(dg.europeD))

rm(file)
