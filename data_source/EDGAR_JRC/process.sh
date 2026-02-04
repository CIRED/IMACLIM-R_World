#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


set -e

# FIXME path should be relative in the default case
edgar_data_path=/data/public_data/EDGAR_JRC/
output_path=./

mkdir -p $output_path/results $output_path/logs

for gtap_version in 10
do
  for year in 2004 2007 2011 2014
  do
    python3 extract_edgar_for_gtap.py --year=$year --gtap-version=$gtap_version --input-file=csv/ --output-file=$output_path/results/edgar_formated_for_gtap${gtap_version}_${year}.csv  > $output_path/logs/edgar_formated_for_gtap${gtap_version}_${year}.log
  done
done

