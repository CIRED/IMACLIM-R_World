#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


set -e

# FIXME path should be relative in the default case
gtap_data_path=/data/shared/GTAP/
output_path=./

mkdir -p $output_path/results $output_path/logs

# normalize file names
for dir in $gtap_data_path/GTAP_raw/*/ss/ ; do
  for filename_normalization in 'CO2:gsdemiss' 'BaseData:gsddat' 'BaseView:gsdview' ; do
    orig_file=`echo $filename_normalization | cut -d':' -f1`
    norm_file=`echo $filename_normalization | cut -d':' -f2`
    #echo $dir $orig_file $norm_file
    if test -f "$dir"/${orig_file}.ss ; then
      if test -f "$dir"/${norm_file}.ss ; then
        :
      else
        #echo ln -s "$dir"/${orig_file}.ss "$dir"/${norm_file}.ss
        ln -s "$dir"/${orig_file}.ss "$dir"/${norm_file}.ss
      fi
    fi
  done
done

./extract_GTAP.py $gtap_data_path/GTAP_raw/GTAP6/ss/ $output_path/results/extracted_GTAP6/ > $output_path/logs/extract_GTAP6.log

# errors due to different names used in different places,
# NatlRes or NatRes and UnskLab or UnSkLab in GTAP7
./extract_GTAP.py $gtap_data_path/GTAP_raw/GTAP7/ss/ $output_path/results/extracted_GTAP7/ > $output_path/logs/extract_GTAP7.log 2>&1
./extract_GTAP.py $gtap_data_path/GTAP_raw/GTAP8-2007/ss/ $output_path/results/extracted_GTAP8/ > $output_path/logs/extract_GTAP8.log

for gtap_version in 9 10
do
  for year in 2004 2007 2011
  do
    ./extract_GTAP.py $gtap_data_path/GTAP_raw/GTAP${gtap_version}/ss/${year}/ $output_path/results/extracted_GTAP${gtap_version}_${year}/ > $output_path/logs/extract_GTAP${gtap_version}_${year}.log
  done
done

gtap_version=10
year=2014
./extract_GTAP.py $gtap_data_path/GTAP_raw/GTAP${gtap_version}/ss/${year}/ $output_path/results/extracted_GTAP${gtap_version}_${year}/ > $output_path/logs/extract_GTAP${gtap_version}_${year}.log

# GTAP-E
for gtap_version in 10
do
  for year in 2004 2007 2011 2014
  do
    ./extract_GTAP.py $gtap_data_path/GTAP_raw/GTAP${gtap_version}-E/ss/${year}/ $output_path/results/extracted_GTAP${gtap_version}-E_${year}/ > $output_path/logs/extract_GTAP${gtap_version}-E_${year}.log
  done
done


./process_balances.sh
