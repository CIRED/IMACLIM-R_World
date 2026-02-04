#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


fileK1=all_capital_09I_noIRR_noDeprate.csv
fileK2=all_capital_09I_IRR.csv
fileK3=all_capital_09I_Deprate.csv

dirAggreg=`pwd`/aggregation
dirInput=`pwd`/aggregation/input/europe
dirTransformed=$dirAggreg/intermediate/europe

mkdir -p $dirTransformed
cp $dirInput/$fileK $dirTransformed

cd $dirAggreg
for fileK in $fileK1 $fileK2 $fileK3
do
    python 1createIndex.py "$dirInput/" "$dirTransformed/" $fileK
done
