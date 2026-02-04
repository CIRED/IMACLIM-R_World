# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

for year in 2014 
do
        path_output='./results/'
        mkdir -p $path_output
        nohup nice R -f "./Estimation_TransportsIEA.R" --args $year $path_output
done
