#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


set -e

rm -rf extracted/ && mkdir -p extracted/
(
cd extracted/ || exit 1
for file in ../download/*.xlsx; do
	pwd
	echo $file
	cp -a $file ./
	spreadsheet_to_csv_files.pl $file
done
for file in *.csv;do
	base=`basename $file .csv`
	echo 1>&2
	echo "normalize $file" 1>&2
	normalize_csv.pl $file > $base-normalized.csv
done
rm *.xlsx
)

