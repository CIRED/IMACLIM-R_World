#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


set -e
#set -x

mkdir -p results logs

gtap_data_path=./
output_path=$gtap_data_path
#gtap_data_path=/data/shared/GTAP/
#output_path=./

for gtap_version in 6 7 8
do
   ./export_balances.py $gtap_data_path/results/extracted_GTAP${gtap_version}/GTAP_tables.csv $output_path/results/extracted_GTAP${gtap_version}/ > logs/export_balances${gtap_version}.log
done

for gtap_version in 9 10
do
  for year in 2004 2007 2011
  do
     ./export_balances.py $gtap_data_path/results/extracted_GTAP${gtap_version}_${year}/GTAP_tables.csv $output_path/results/extracted_GTAP${gtap_version}_${year}/ > logs/export_balances${gtap_version}_${year}.log
  done
done  

gtap_version=10
year=2014
./export_balances.py $gtap_data_path/results/extracted_GTAP${gtap_version}_${year}/GTAP_tables.csv $output_path/results/extracted_GTAP${gtap_version}_${year}/ > logs/export_balances${gtap_version}_${year}.log
