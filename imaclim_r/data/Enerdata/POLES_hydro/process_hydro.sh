# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

input_data=$Hydro_data

GTAP_agg_rule='../../GTAP/aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv'

ISO_to_GTAP=$ISO3GTAP_path/ISO3166_GTAP.csv

output_data='./'

for scenario in baseline climat
do
R -f "hydro_POLES.R" --args $scenario $input_data $GTAP_agg_rule $ISO_to_GTAP $output_data
done
