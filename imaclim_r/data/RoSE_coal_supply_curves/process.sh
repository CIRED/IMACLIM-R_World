#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


set -e
set -x

raw_data_path=raw_data/
mkdir -p logs
mkdir -p $raw_data_path
cp $Rose_coal_resource/*.csv $raw_data_path

$python3data_imaclim_env compute_coal_supply_curves.py --input-folder=$raw_data_path >  logs/log.log
