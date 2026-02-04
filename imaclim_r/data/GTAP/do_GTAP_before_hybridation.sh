#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Nicolas Graves, Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


do_GTAP6=no
#do_GTAP6=yes

do_GTAP8=no
#do_GTAP8=yes

#do_GTAP10=no
do_GTAP10=yes

#basedata=/data/shared/
#public_data=/data/public_data/
#SAM_GTAP6_data_file=${basedata}/GTAP/results/extracted_GTAP6/SAMs.csv

set -e
set -x

mkdir -p logs GTAP_Imaclim_before_hybridation GTAP_land-use GTAP_Emissions

if test $do_GTAP6 = yes ; then
  SAM_GTAP6_data_file=/data/shared/GTAP/results/extracted_GTAP6/SAMs.csv

  rm -rf GTAP_Imaclim/outputs_GTAP
  aggregate_GTAP_table_file.py --region-aggregation=aggregations/aggregation_Imaclim_GTAP6_region.csv --sector-aggregation=aggregations/aggregation_Imaclim_GTAP6_sector.csv --separate-tables-dir=GTAP_Imaclim/outputs_GTAP/ "$SAM_GTAP6_data_file" > logs/aggregation_GTAP6_SAM_Imaclim.log

  rm -rf GTAP_land-use/outputs_GTAP
  aggregate_GTAP_table_file.py --region-aggregation=aggregations/aggregation_Imaclim_GTAP6_region.csv --sector-aggregation=aggregations/aggregation_land-use_GTAP6_sector.csv --separate-tables-dir=GTAP_land-use/outputs_GTAP/ "$SAM_GTAP6_data_file" > logs/aggregation_GTAP6_SAM_land-use.log
fi


if test $do_GTAP8 = yes ; then
  SAM_GTAP8_data_file=/data/shared/GTAP/results/extracted_GTAP8/SAMs.csv
  Emissions_GTAP8_data_file=/data/shared/GTAP/results/extracted_GTAP8/Emissions.csv
  aggregation_Imaclim_GTAP8_region=/data/public_data/regional_aggregations/results/GTAP_mappings/GTAP81_regions_current_imaclim.csv

  mkdir -p tmpdir
  # must lower case codes as lowercase codes are used in the data, while
  # codes are in uppercase in regions descriptions, for instance in
  # https://www.gtap.agecon.purdue.edu/databases/regions.aspx?version=8.211
  remove_csv_columns.py --keep 'RegionCode' < "${aggregation_Imaclim_GTAP8_region}" > tmpdir/imaclim_GTAP8_regions_current_region_column.csv
  remove_csv_columns.py --keep 'GTAP_RegionCode' < "${aggregation_Imaclim_GTAP8_region}" | tr A-Z a-z > tmpdir/imaclim_GTAP8_regions_current_GTAP_RegionCode_column.csv
  (
    echo 'RegionCode|GTAP_RegionCode'
    paste -d '|' tmpdir/imaclim_GTAP8_regions_current_region_column.csv tmpdir/imaclim_GTAP8_regions_current_GTAP_RegionCode_column.csv | sed 1d | sort | uniq
  ) > tmpdir/imaclim_GTAP8_regions_current_lowercase.csv
  table_to_aggregation.py tmpdir/imaclim_GTAP8_regions_current_lowercase.csv 'RegionCode' 'GTAP_RegionCode' > tmpdir/aggregation_GTAP8_region.csv

  rm -rf GTAP_Imaclim/outputs_GTAP8
  aggregate_GTAP_table_file.py --region-aggregation=tmpdir/aggregation_GTAP8_region.csv --sector-aggregation=aggregations/aggregation_Imaclim_GTAP6_sector.csv --separate-tables-dir=GTAP_Imaclim/outputs_GTAP8/ "$SAM_GTAP8_data_file" > logs/aggregation_GTAP8_SAM_Imaclim.log

  rm -rf GTAP_Emissions/outputs_GTAP8
  aggregate_GTAP_table_file.py --region-aggregation=tmpdir/aggregation_GTAP8_region.csv --sector-aggregation=aggregations/aggregation_Imaclim_GTAP6_sector.csv --separate-tables-dir=GTAP_Emissions/outputs_GTAP8/ "$Emissions_GTAP8_data_file" > logs/aggregation_GTAP8_Emissions_Imaclim.log

fi 


if test $do_GTAP10 = yes ; then
  for year in 2004 2007 2011 2014
  do

	# SAM agregation for hybridation
        SAM_GTAP10_data_file=/data/shared/GTAP/results/extracted_GTAP10_$year/SAMs.csv
        Emissions_GTAP10_data_file=/data/shared/GTAP/results/extracted_GTAP10_$year/Emissions.csv

        outputfolder=GTAP_Imaclim_before_hybridation/outputs_GTAP10_${year}/
        rm -rf $outputfolder
        mkdir -p $outputfolder
	aggregate_GTAP_table_file.py --region-aggregation=aggregations/aggregation_Imaclim_GTAP10_region__before_hybridation.csv --sector-aggregation=aggregations/aggregation_Imaclim_GTAP10_sector__before_hybridation.csv --energy-aggregation=aggregations/aggregation_Imaclim_GTAP10_fuel__before_hybridation.csv --fuels-aggregation=aggregations/aggregation_Imaclim_GTAP10_fuel__before_hybridation.csv --output-file=$outputfolder/GTAP_SAM__EDS_N_gas_agg__GTAP10_${year}.csv --complete-rules --correct-self-import  "$SAM_GTAP10_data_file" > logs/aggregation_GTAP10_SAM_before_hybridation_${year}.log

	# Full economic table agregation
        Table_GTAP10_data_file=/data/shared/GTAP/results/extracted_GTAP10_$year/GTAP_tables.csv
        aggregate_GTAP_table_file.py --region-aggregation=aggregations/aggregation_Imaclim_GTAP10_region__before_hybridation.csv --sector-aggregation=aggregations/aggregation_Imaclim_GTAP10_sector__before_hybridation.csv --energy-aggregation=aggregations/aggregation_Imaclim_GTAP10_fuel__before_hybridation.csv --fuels-aggregation=aggregations/aggregation_Imaclim_GTAP10_fuel__before_hybridation.csv --output-file=$outputfolder/GTAP_tables__EDS_N_gas_agg__GTAP10_${year}.csv --complete-rules "$Table_GTAP10_data_file" > logs/aggregation_GTAP10_GTAP_tables_before_hybridation_${year}.log

  done
fi

