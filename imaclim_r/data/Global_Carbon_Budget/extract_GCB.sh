#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


set -e
set -x

mkdir -p logs

for model in OSCAR BLUE HN2017
do
      filename=National_LandUseChange_Carbon_Emissions_2022v10-${model}-normalized.csv
      echo $Global_Carbon_Budget/${filename} ${ISO_GTAP_IMACLIM_rules}
      $python3data_imaclim extract_GCB.py $Global_Carbon_Budget/${filename} ${ISO_GTAP_IMACLIM_rules} >  logs/GCB_${filename%.*}_${fossil}.log
done
