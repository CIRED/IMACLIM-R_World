#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


country=france

franceDirT=`pwd`/transformed/$country/preprocessed0
DestFolder=`pwd`/transformed/$country/preprocessed1


outFile=DataFranceISIC3_11prod.csv

mkdir -p $DestFolder

cp -R $franceDirT/. $DestFolder/

for franceKFile in $DestFolder/*
do 
    dos2unix $franceKFile
    sed -i 's/||/|NA|/g' $franceKFile
    sed -i 's/||/|NA|/g' $franceKFile
    sed -i 's/|_/|/g' $franceKFile
    sed -i 's/code/industry/g' $franceKFile
done

python processDataFrance.py "$DestFolder/" "$country" "$outFile"
