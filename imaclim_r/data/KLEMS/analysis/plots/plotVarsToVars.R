# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


folder <- paste0(PLOT,"/plottedVarstoVars/")
cat("Results will be located in",folder,"\n")
dir.create(folder, recursive=TRUE)
setwd(folder)

temp <- subset(dgVar, product=="GFCF" & industry=="TOT")
graph <- qplot(K, Iq, data=temp, color = country, xlab="Real fixed capital stock, 1995 prices", ylab="Real fixed capital formation, 1995 prices", main="Capital formation versus stock, per country")

ggsave("K_Iq_AllCountries_GFCF_TOT.pdf") 


temp <- subset(dgVar, product=="GFCF" & industry=="TOT")
graph <- qplot(D, Iq, data=temp, color = country, xlab="Capital consumption, 1995 prices", ylab="Real fixed capital formation, 1995 prices", main="Capital formation versus consumption, per country")

ggsave("D_Iq_AllCountries_GFCF_TOT.pdf") 


temp <- subset(dgVar, industry=="TOT"& product!="GFCF" & product!="ICT" & product!="NonICT")
graph <- qplot(K, Iq, data=temp, color = product, geom="line", xlab="Real fixed capital stock, 1995 prices", ylab="Real fixed capital formation, 1995 prices", main="Capital formation versus stock, all countries")

ggsave("K_Iq_AllCountries_AllProducts_TOT.pdf") 


print(graph)

