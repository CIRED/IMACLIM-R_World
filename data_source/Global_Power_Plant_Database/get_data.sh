#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


#Get Global Power Plant Database zip file in download
mkdir -p download

(
cd download

wget -N 'https://wri-dataportal-prod.s3.amazonaws.com/manual/global_power_plant_database_v_1_3.zip'
)
