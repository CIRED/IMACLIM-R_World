# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

input_data=$ADVANCE_data/extracted/1-s2.0-S014098831630130X-mmc2.xlsx

output_data="./"

for var_ADVANCE in Res_peak Curtailment
do
R -f "process_coef.R" --args $input_data $var_ADVANCE $output_data
done

input_data=$ADVANCE_data/extracted/1-s2.0-S014098831630130X-mmc3.xlsx

R -f "process_coef_storage.R" --args $input_data $output_data

R -f "process_coef_profile.R" --args $input_data $output_data

R -f "process_coef_gross_VRE.R" --args $input_data $output_data