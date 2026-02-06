# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


dgAgg <- dg %>% spread(industry,value, fill = NA, convert = FALSE, drop = TRUE) %>% 
  mutate(GtH = G + H) %>% 
  gather(industry, value, -year, -country, -var, -product, factor_key = TRUE) #na.rm = FALSE, convert = FALSE)

print(head(dgAgg))

#------------------------------------------------
dsAgg <- ds %>% spread(industry,value, fill = NA, convert = FALSE, drop = TRUE) %>% 
                   mutate(GtH = G + H) %>% 
                   gather(industry, value, -year, -country, -var, -product, factor_key = TRUE) #na.rm = FALSE, convert = FALSE)

print(head(dsAgg))

#------------------------------------------------
#dgShareK <- dg %>% spread(var,value, fill = NA, convert = FALSE, drop = TRUE) %>%
#                      mutate(dgVar, IqShareK = Iq / K, Inet = (Iq - D)*Ip, InetShareK = (Iq - D)/K ) %>% 
#                      gather(var, value, -year, -country, -industry, -product, factor_key = TRUE)

#vars = unique( dgShareK$var      )

#print(head(dgShareK))
#------------------------------------------------
dsProdAgg <- dsAgg %>% spread(product,value) %>% 
  mutate(Con = RStruc + OCon, Mach = TraEq + OMach) %>% 
  gather(product, value, -year, -country, -var, -industry) #na.rm = FALSE, convert = FALSE)

print(head(dsProdAgg))


