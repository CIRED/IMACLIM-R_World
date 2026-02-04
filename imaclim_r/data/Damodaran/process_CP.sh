# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

input_data=$Damodaran_data/ctryprem19-ERPs_by_country.csv

GTAP_agg_rule='../GTAP/aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv'

WB_data=$WB_data_WDI/WDIData.csv

ISO_to_GTAP=$ISO3GTAP_path/ISO3166_GTAP.csv

output_data='./'

year=2019

R -f "./CP_agreg.R" --args $input_data $year $GTAP_agg_rule $ISO_to_GTAP $WB_data $output_data
