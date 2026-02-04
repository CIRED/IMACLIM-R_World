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

mkdir -p logs EDGAR_emissions_GTAP_agg

  for year in 2014 2004 2007 2011
  do
	edgar_emissions_file=$EDGAR_data/edgar_formated_for_gtap10_$year.csv
        outputfolder=EDGAR_emissions_GTAP_agg/edgar_emissions_GTAP_format_sector${nb_sector}_${year}/
        rm -rf $outputfolder
        mkdir -p $outputfolder
        aggregate_GTAP_table_file.py --region-aggregation=../GTAP/aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv --sector-aggregation=../GTAP/aggregations/aggregation_Imaclim_GTAP10_sector${nb_sector}__no_hybridation.csv --separate-variable-dir=$outputfolder/ --separate-variable-list="'ALL'" --output-file=$outputfolder/aggregation_EDGAR_Emissions_GTAP_format_${year}.csv --complete-rules "$edgar_emissions_file" > logs/aggregation_EDGAR_Emissions_GTAP_format_sector${nb_sector}_${year}.log
  done
