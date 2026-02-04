# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

GTAP_agg_rule='../GTAP/aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv'

ISO_data=$ISO3GTAP_path/ISO3166_GTAP.csv

data_GPPD=$GPPD_data/global_power_plant_database.csv

data_retired=$GEM_data/Retired.xlsx

output_data='./'
target_year=2020

for FF in Coal Gas Oil
do
R -f "./power_cap_agreg_FF.R" --args $data_GPPD $data_retired $target_year $FF $GTAP_agg_rule $ISO_data $output_data
done
