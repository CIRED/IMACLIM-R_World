#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


set -e

year_cumulative=2014

for year_cumulative in 2014
  do
  for year_cumulative_start in 1990 2007
    do
    $python3data_imaclim_env ./aggregate_data.py $shift_project_cumulaitve_FF_resource $year_cumulative $year_cumulative_start $ISO_GTAP_IMACLIM_rules > main.log
    done
  done
