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

CWD=`pwd`

selectworth=True

for year in 2014 2011 2007 2004
do
        outputfolder=results

        ILOSTAT_desaggregation_withGTAP.py --year $year --ilostat-data-path=$ilostat_data/csv/ --gtap-data-path=/data/shared/GTAP/results/extracted_GTAP10_$year/ --ilostat-var= --ilostat-file=EMP_TEMP_SEX_ECO_NB_A.csv --select-worth=$selectworth --output-file=$outputfolder/ilostat_employement_per_sector_$year.csv > main_log_$year.log
done

outputfolder=results_sector${nb_sector}/
rm -rf $outputfolder
mkdir -p $outputfolder
for year in 2014 2011 2007 2004
do
        ilostat_file=$ilostat_data/results/EMP_TEMP_SEX_ECO_NB_A__selectworth_${selectworth}__interpolated_extrapolated__gtap__$year.csv
        aggregate_GTAP_table_file.py --region-aggregation=../GTAP/aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv --sector-aggregation=../GTAP/aggregations/aggregation_Imaclim_GTAP10_sector${nb_sector}__no_hybridation.csv --separate-variable-dir=$outputfolder/ --separate-variable-list="'ALL'" --output-file=$outputfolder/aggregation_ILOSTAT_employement_GTAP_format_${year}.csv --complete-rules "$ilostat_file" > main_log_aggregation_sector${nb_sector}_$year.log
done

#mkdir -p ./results
#./process_income_share.py $income_share_data/LAC_4HRL_ECO_CUR_NB_A.csv
