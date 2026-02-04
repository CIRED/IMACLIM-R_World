#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Nicolas Graves
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


# ./get_data.sh > logs/get_data.out 2>&1

#% run ./get_data.sh $version

mkdir -p download

(
cd download
#wget -r -N -l2 -I '/databases,/resources' https://www.gtap.agecon.purdue.edu/databases/v7/v7_doco.asp
#wget -r -N -l2 -I '/databases,/resources' https://www.gtap.agecon.purdue.edu/databases/v6/v6_doco.asp
#for version in 3 4 5 6 7 8 9; do
#  wget -r -N -l2 -I '/databases,/resources' https://www.gtap.agecon.purdue.edu/databases/v${version}/v${version}_doco.asp
#done

wget -r -N -l2 -I '/databases,/resources' https://www.gtap.agecon.purdue.edu/databases/v$1/v$1_doco.asp

)


#Here are the files identified for specific documentation purposes. 

#GTAP detailed energy database construction from IEA extended balance sheets
#https://www.gtap.agecon.purdue.edu/resources/download/2934.pdf

#GTAP old (GTAP 6 to 9) detailed sector classification
#https://www.gtap.agecon.purdue.edu/databases/contribute/detailedsector57.asp 

#GTAP 10 detailed sector classification
#https://www.gtap.agecon.purdue.edu/databases/contribute/detailedsector.asp

#GTAP 10 summary sector classification
#https://www.gtap.agecon.purdue.edu/databases/v10/v10_sectors.aspx#Sector65

#GTAP energy database construction : first paper (old)
#https://www.gtap.agecon.purdue.edu/resources/download/93.pdf

