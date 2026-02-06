#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


set -e
set -x


outputfolder=results
mkdir -p $outputfolder

# Commenting code computing the 2015 database version, as the source file has been deleted and lost 

#iea_data=/data/shared/iea-energyBalancesAndPrices/IEA_2017/rawData/wbig/

#for year in 2014 
#do
#	$python3data_imaclim ./GTAP_IEA-aggregation.py --year $year --input-file=$iea_data  --output-file=$outputfolder > main_log_$year.log
#done


for year in `seq 2001 1 2020`
do
	iea_data=/data/shared/IEA/IEA_2022_Balances_Prices/results/EnergyBalancesDatabases/wbig_old_iea_code/$year/
	outputfolder=results_$year/
        $python3data_imaclim_env ./GTAP_IEA-aggregation.py --year $year --input-file=$iea_data  --output-file=$outputfolder > main_log_$year.log
done

$python3data_imaclim_env ./compute_txCaptemp_ener.py

