# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

input_data=$ADVANCE_data/extracted/1-s2.0-S014098831630130X-mmc2.xlsx

output_data="./"

for var_ADVANCE in Res_peak Curtailment
do
R -f "process_coef.R" --args $input_data $var_ADVANCE $output_data
done