#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


# create a directory download to store data 
mkdir download
cd download

# loop on year to get all data
# and rename each file in DAC_year.xslx 
for year in {2017..2020}
do
    wget -O DAC_$year.xlsx https://webfs.oecd.org/climate/RecipientPerspective/CRDF-RP-$year.xlsx
done

