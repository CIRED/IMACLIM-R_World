#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


# ./prepare_input_data.sh /data/results/nexus_land-use/input_data/

destination=$1

who=`whoami`
date=`date '+%Y-%m-%d'`

result="input_data-$who-$date"

#zip -r $result `find data/ -type f \( -iname \*.csv -o -iname \*.sav \)'` externals/land-use/input_data-dumas-2018-09-27-r27182.zip
zip -r $result `find data/ -type f \( -iname \*.csv -o -iname \*.sav -o -iname \*.tsv \)` outputs/{001,009,019}_* outputs/*.xlsx 

if [ "z$destination" != 'z' ]; then
  mv $result.zip $destination || exit 1
fi
