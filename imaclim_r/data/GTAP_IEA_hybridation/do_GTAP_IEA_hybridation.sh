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


for year in 2014 #2004 2007 2011
do
        outputfolder=results
        rm -rf $outputfolder
        mkdir -p $outputfolder

	iea_result_path=../IEA/iea_aggregation_for_hybridation/results_$year/
	gtap_data_path=../GTAP/GTAP_Imaclim_before_hybridation/outputs_GTAP10_$year/
        python3 hybridation_GTAP_IEA.py --year $year --non-specified 'ser' --wb-datapath=$WB_data_WDI --iea-data-path=$iea_result_path --gtap-data-path=$gtap_data_path --output-file=$outputfolder/GTAP_IEA_hybrid_table_SecEDS_RegGTAP_$year.csv > main_log_$year.log

done



