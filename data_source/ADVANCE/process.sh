# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

path_data='./extracted/1-s2.0-S014098831630130X-mmc2.xlsx'
path_export='./coef/coef_RLDC.csv'

mkdir ./coef

R -f "process_coef.R" --args $path_data $path_export