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

for ssp in 1 2 3 4 5
do
   for fossil in oil gas coal
   do
       python3 aggregate_supply_curves.py --ssp=$ssp --fossil=$fossil --verbose='False' --input-folder=$bauer_FF_resource/ >  logs/aggregation_supply_curves_${ssp}_${fossil}.log
   done
done
