# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

mkdir -p csv

(
cd download
for f in *.zip; do unzip -o $f ; done

for f in *.xls;do spreadsheet_to_csv_files.pl $f; done
rm *.xls

for file in *.csv; do
    base=`basename $file .csv`
    normalize_csv.pl $file > ../csv/$base-normalized.csv
    cp $file ../csv/$file
  done

#rm *.csv
)

