#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


for dir in IHS_going_global_tightOilProduction mcglade_uncertainties.globalOilResources_2012-E tight_oil_weo2014
do
	mkdir -p $dir
	scp $oil_resource_data/$dir/*.csv $dir/
done

mkdir -p Frack_lab_oil
scp $tight_oil_projection/*.csv Frack_lab_oil/

mkdir -p AEO2015
scp $tight_oil_projection_2015/*.csv AEO2015/
