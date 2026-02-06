# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

path_data_nuke=$IAEA_data/Nuclear_Power_Reactor.csv
path_data_nuke2024=$IAEA_data/Nuclear_Power_Reactor.csv
path_data_nukeplanned=$IAEA_data/Nuclear_Power_Reactor.csv
path_output="./"

for pathdata in path_data_nuke path_data_nuke2024 path_data_nukeplanned
do
    R -f "./power_cap_agreg_nuke.R" --args $pathdata $path_output
done
