# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

GTAP_agg_rule='../GTAP/aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv'

ISO_data=$ISO3GTAP_path/ISO3166_GTAP.csv

data_WACC_ETH=$WACC_data/WACC_data.csv

ISO_to_IMC='../../externals/common_code_head/R/ISO_to_IMC.R'

output_data='./'

R -f "./Global_WACC_process.R" --args $data_WACC_ETH $GTAP_agg_rule $ISO_data $output_data $ISO_to_IMC

