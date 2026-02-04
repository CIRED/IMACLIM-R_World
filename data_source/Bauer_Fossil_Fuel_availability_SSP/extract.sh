#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Nicolas Graves
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
	if echo $file | egrep "oil_gas_ssp.-4_Oil_-_Resources\.csv"
	then
		#Delete useless lines and columns 
		sed -i -e '/^|.*$/d' -e 's/|||.*$//' $base-normalized.csv
	fi
done
rm *.xlsx
)

