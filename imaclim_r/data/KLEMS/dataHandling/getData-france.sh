#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Liesbeth Defosse, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

franceDir=/data/shared/klems/raw/france
franceKFile=FRA_capital_11i-1.xlsx

transformed=transformed/france/preprocessed0

mkdir -p $transformed
cd $transformed
$commonCode/bin/spreadsheet_to_csv_files.pl -separator="|" ${klems_data_france}${franceKFile}

