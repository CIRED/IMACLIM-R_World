#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Nicolas Graves
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


infile=download/1-s2.0-S0959652619335280-mmc2.xlsx
file=buildings_area_and_resource_cons.xlsx

rm -rf extracted
mkdir -p extracted
(
  cd extracted || exit 1
  cp -a ../$infile $file
  spreadsheet_to_csv_files.pl $file
  for file in *.csv; do
    base=`basename $file .csv`
    echo 1>&2
    echo "normalize $file" 1>&2
    normalize_csv.pl $file > $base-normalized.csv
  done
)
