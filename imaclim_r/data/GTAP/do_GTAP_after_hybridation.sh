#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================



#basedata=/data/shared/
#public_data=/data/public_data/
#SAM_GTAP6_data_file=${basedata}/GTAP/results/extracted_GTAP6/SAMs.csv

set -e
set -x

mkdir -p logs GTAP_Imaclim_after_hybridation_sector$nb_sector/


for year in 2014 #2004 2007 2011 2014
do
        Table_GTAP10_data_file=../GTAP_IEA_hybridation/results/GTAP_IEA_hybrid_table_SecEDS_RegGTAP_$year.csv

        outputfolder=GTAP_Imaclim_after_hybridation_sector$nb_sector/outputs_GTAP10_${year}/
        rm -rf $outputfolder
        mkdir -p $outputfolder
        aggregate_GTAP_table_file.py --region-aggregation=aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv --sector-aggregation=aggregations/aggregation_Imaclim_GTAP10_sector${nb_sector}__after_hybridation.csv --separate-tables-dir=$outputfolder --complete-rules "$Table_GTAP10_data_file" > logs/aggregation_GTAP10_sector${nb_sector}_IEA_hybrid_table_after_hybridation_${year}.log

        Table_GTAP10_data_file=../GTAP/GTAP_Imaclim_before_hybridation/outputs_GTAP10_$year/GTAP_tables__EDS_N_gas_agg__GTAP10_${year}.csv
	outputfile=$outputfolder/GTAP_tables__EDS_N_gas_agg__GTAP10_${year}.csv
        aggregate_GTAP_table_file.py --region-aggregation=aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv --sector-aggregation=aggregations/aggregation_Imaclim_GTAP10_sector${nb_sector}__after_hybridation.csv --separate-variable-dir=$outputfolder/ --separate-variable-list="['SAVE']" --output-file=$outputfile --complete-rules "$Table_GTAP10_data_file" > logs/aggregation_GTAP10_sector${nb_sector}_GTAP_tables_before_hybridation_${year}.log
	rm $outputfile #not needed and space consuming
done
