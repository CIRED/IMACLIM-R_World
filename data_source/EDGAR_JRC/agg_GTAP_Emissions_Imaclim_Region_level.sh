#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


#do_GTAP10=no
do_GTAP10=yes

set -e
set -x

mkdir -p logs GTAP_Emissions

if test $do_GTAP10 = yes ; then
  for year in 2004 2007 2011 2014
  do
        Emissions_GTAP10_data_file=/data/shared/GTAP/results/extracted_GTAP10_$year/Emissions.csv
        outputfolder=GTAP_Emissions/outputs_GTAP10_${year}/
        rm -rf $outputfolder
        mkdir -p $outputfolder
        #aggregate_GTAP_table_file.py --region-aggregation=aggregations/aggregation_Imaclim_GTAP10_region__before_hybridation.csv --sector-aggregation=aggregations/aggregation_Imaclim_GTAP10_sector__before_hybridation.csv --energy-aggregation=aggregations/aggregation_Imaclim_GTAP10_fuel__before_hybridation.csv --fuels-aggregation=aggregations/aggregation_Imaclim_GTAP10_fuel__before_hybridation.csv --output-file=$outputfolder/GTAP_Emisions__EDS_N_gas_agg__GTAP10_${year}.csv --complete-rules "$Emissions_GTAP10_data_file" > logs/aggregation_GTAP10_GTAP_Emissions_before_hybridation_${year}.log
        aggregate_GTAP_table_file.py --region-aggregation=externals/ImaclimR_aggregation_rules/aggregation_Imaclim_GTAP10_region__after_hybridation.csv --output-file=$outputfolder/GTAP_Emisions__EdgarSector_ImaclimRegion_agg__GTAP10_${year}.csv --complete-rules "$Emissions_GTAP10_data_file" > logs/aggregation_GTAP10_GTAP_Emissions__EdgarSector_ImaclimRegion_agg__${year}.log
  done
fi

