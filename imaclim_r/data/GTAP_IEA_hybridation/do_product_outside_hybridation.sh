#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


set -e
#set -x


for year in 2014 #2004 2007 2011
do
        outputfolder=results_$year/
        rm -rf $outputfolder
        mkdir -p $outputfolder

	iea_result_path=../IEA/iea_aggregation_for_hybridation/results_$year/
        python3 product_outside_hybridation.py --iea-data-path=$iea_result_path --output-path=$outputfolder > main_product_outsite_hbrid_log_$year.log

done



