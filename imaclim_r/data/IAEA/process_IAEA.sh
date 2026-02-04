# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

path_data_nuke=$IAEA_data/Nuclear_Power_Reactor.csv
path_output="./"


R -f "./power_cap_agreg_nuke.R" --args $path_data_nuke $path_output
