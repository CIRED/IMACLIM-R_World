#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


set -e

year_UNO_database=2022
nb_year_interpolation=5

$python3data_imaclim ./process_population_UNO.py $UNO_population_data $year_UNO_database  > main.log
$python3data_imaclim ./process_population_SSP.py $SSP_Koch_Leimbach_data $year_UNO_database $nb_year_interpolation >> main.log
