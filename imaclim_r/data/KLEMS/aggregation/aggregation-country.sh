#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Liesbeth Defosse, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


fileInputeuropeK=all_capital_09I_noIRR_noDeprate.csv
fileInputeuropeD=all_countries_09I.csv
fileInputfrance=DataFranceISIC3_11prod.csv

for country in  france europeK 
do
    echo "*******"
    echo $country
    echo "*******"
    dirInput=`pwd`/input
    dirIntermediate=`pwd`/intermediate
    dirOutput=`pwd`/output
    dirIOTables=/IOTablesCountries

    AllDataNarrow=DataMatrixwithValues.csv

    fileInput="fileInput$country"

    mkdir -p $dirIntermediate/$country

    python 1createIndex.py "$dirInput/$country/" "$dirIntermediate/$country/" "${!fileInput}"

    python 2importKLEMSData.py "$dirInput/$country/" "$dirIntermediate/$country/" "${!fileInput}" "$AllDataNarrow"

    for year in 2001 2004 2007 
    do 
        python 3determineShares.py "$dirInput/" "$dirIntermediate/" "$year"
        python 4aggNarrowFormat_Countries.py  "$dirInput/" "$dirIntermediate/$country/" "$dirOutput/$country/" "$AllDataNarrow" "$year"
	python 5writeOut.py "$dirInput/" "$dirIntermediate/$country/" "$dirOutput/$country/" "$dirIOTables/" "$year"
    done

done

for country in europeD
do
    echo "*******"
    echo $country
    echo "*******"
    dirInput=`pwd`/input
    dirIntermediate=`pwd`/intermediate
    dirOutput=`pwd`/output
    dirIOTables=/IOTablesCountries

    AllDataNarrow=DataMatrixwithValues.csv

    fileInput="fileInput$country"

    mkdir -p $dirIntermediate/$country

    python 1createIndex.py "$dirInput/$country/" "$dirIntermediate/$country/" "${!fileInput}"

    # Narrow format of all_countries_09I.csv not really needed. Imported in wide format to R for aanalysis and narrow format created there.
    #python 2importKLEMSData.py "$dirInput/$country/" "$dirIntermediate/$country/" "${!fileInput}" "$AllDataNarrow"

done
