#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


#do_GTAP10=no
do_GTAP10=yes

set -e
set -x

if test $do_GTAP10 = yes ; then
  for year in 2004 2007 2011 2014
  do

	# SAM agregation for hybridation
        SAM_GTAP10_data_file=/data/shared/GTAP/results/extracted_GTAP10_$year/SAMs.csv

        outputfolder=GTAP_Imaclim_aggregation_no_hybridation_sector$nb_sector/outputs_GTAP10_${year}/
        rm -rf $outputfolder
        mkdir -p $outputfolder
        aggregate_GTAP_table_file.py --region-aggregation=aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv --sector-aggregation=aggregations/aggregation_Imaclim_GTAP10_sector${nb_sector}__no_hybridation.csv --energy-aggregation=aggregations/aggregation_Imaclim_GTAP10_fuel__before_hybridation.csv --fuels-aggregation=aggregations/aggregation_Imaclim_GTAP10_fuel__before_hybridation.csv --complete-rules --correct-self-import --separate-tables-dir=$outputfolder "$SAM_GTAP10_data_file" > logs/aggregation_GTAP10__sector${nb_sector}_SAM_${year}.log

  done
fi

