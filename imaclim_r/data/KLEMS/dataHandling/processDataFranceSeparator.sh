#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


franceKFile=DataFranceISIC4_11prod.csv

franceDir=`pwd`/transformed/france/merged

#franceFileT=DataFranceISIC4.csv

cd $franceDir

#cp $franceKFile $franceFileT

#sed -i .bk 's/_/|/g' $franceFileT  #for OSX

sed -i 's/_/|/g' $franceKFile

#rm *.bk          #for OSX

#cd ..