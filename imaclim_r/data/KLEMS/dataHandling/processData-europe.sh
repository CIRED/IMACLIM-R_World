#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

fileK=all_capital_09I
fileD=all_countries_09I
txt=.txt
csv=.csv

fileK1=all_capital_09I_noIRR_noDeprate.csv
fileK2=all_capital_09I_IRR.csv
fileK3=all_capital_09I_Deprate.csv

fileD1=all_countries_09I.csv

#----------------------------------------------------------


raw=$klems_data_EU/09i/
transformed=`pwd`/transformed/europe

inputK=`pwd`/../aggregation/input/europeK
inputD=`pwd`/../aggregation/input/europeD

mkdir -p $transformed

for fileC in $fileK $fileD
do
    cp $raw/$fileC$txt $transformed/$fileC$csv
done

fileK=$fileK$csv
fileD=$fileD$csv

#----------------------------------------------------------

cd $transformed

for fileC in $fileK $fileD
do
    echo "***" $fileC
    dos2unix $fileC
    sed -i 's/,/|/g' $fileC
    sed -i 's/|"/|NA/g' $fileC
    sed -i 's/||/|NA|/g' $fileC
    sed -i 's/||/|NA|/g' $fileC
    sed -i 's/|_/|/g' $fileC
#sed -i 's/_/|/g' $fileC
    sed -i 's/"//g' $fileC
    sed -i 's/code/industry/g' $fileC
    sed -i 's/USA-NAICS/USA/g' $fileC
    echo "changing USA-NAICS into USA (check if using 2008 db, there will be 2: USA and USA-NAICS)"
done

sed -i 's/var/var|product/g' $fileK
sed -i 's/_/|/g' $fileK
sed -i 's/IRR/IRR|NA/g' $fileK
#sed -i '/JPN/d' $fileK
#echo "CHECK JPN formatting, maybe use fill=true"
#sed -i '/SVN/d' $fileK
#echo "CHECK SVN formatting, maybe use fill=true"

cd ../..

for C in K D 
do
    fileIn="file$C"
    outDir="input$C"
    mkdir -p "${!outDir}"
    python processDataEurope.py $transformed/ "${!fileIn}" "${!outDir}/" 
done

cd $inputK

echo -e "\nFor "$fileK" : Deleting low-level, detailed, industry-levels with all NA's and inconsistent disaggregation with rest of data"
for level in A 1 2 B 10t12 10 11 12 13t14 13 14 15 16 17t18 17 18 19 21 22 221 22x 244 24x 27 28 30 31t32 31 313 31x 32 321 322 323 33 331t3 334t5 34 35 351 353 35x 36 37 40 40x 402 41 60 61 62 63 65 66 67 71 72 73 74 741t4 745t8 90 91 92 921t2 923t7 93
do 
    sed -i "/|$level|NA|NA|NA|NA/d" $fileK
done

cp $fileK $fileK1
cp $fileK $fileK2
cp $fileK $fileK3



sed -i '/IRR/d' $fileK1
sed -i '/Deprate/d' $fileK1
echo -e "\nProcessed files are in folders:" $inputK $inputD
echo -e "\nFor "$fileK" : Deprate and IRR different formatting. Creating 3 files with Deprate and IRR in seperate files."

sed -i '/IRR/!d' $fileK2

sed -i '/Deprate/!d' $fileK3

cd ..
