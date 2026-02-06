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

# definition of 15-63 as the working age population can be found here:
# OECD (2024), Working age population (indicator). doi: 10.1787/d339918b-en (Accessed on 29 May 2024)
# https://webapps.ilo.org/ilostat-files/Documents/Understanding%20labour%20statistics_FR.pdf
for active_pop_range in '15-63' '20-59'
    do
    $python3data_imaclim_env ./process_population_UNO.py $UNO_population_data $year_UNO_database $active_pop_range >> main.log
    $python3data_imaclim_env ./process_population_SSP.py $IIASA_scenario_explorer_public $year_UNO_database $nb_year_interpolation $ISO_GTAP_IMACLIM_rules $active_pop_range >> main.log
    done

$python3data_imaclim_env ./process_population_SSP_update_Koch_Leimbach.py $SSP_Koch_Leimbach_data $year_UNO_database $nb_year_interpolation > main.log

# SSP - GDP with IMACLIM regions process
models=("IIASA GDP 2023" "OECD ENV-Growth 2023")
for model in "${models[@]}"
    do
    for ssp in 1 2 3 4 5
    do 
        $python3data_imaclim_env ./SSP_GDP_IMACLIM.py $IIASA_scenario_explorer_public $year_UNO_database $ISO_GTAP_IMACLIM_rules "$model" "SSP$ssp" > main.log
    done
done
