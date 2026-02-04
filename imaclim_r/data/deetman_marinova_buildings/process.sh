# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Nicolas Graves
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

#Disaggregates Image data
python3 ./compute_building_stock.py $buildings_data/extracted/buildings_area_and_resource_cons-sqmeters_output-normalized.csv 
#Aggregates to ImaclimR regions
aggregate_csv_lines.pl < ./residential_building_stock.csv ./dico_Image_to_Imaclim.csv '2014' Region > ./aggregated_building_stock.csv
#Sorts lines
for S in $(cat ../order_regions.csv | awk '{print $1}'); do grep $S aggregated_building_stock.csv ; done > building_stock.csv
#Deletes temporary files
rm -f ./residential_building_stock.csv ./aggregated_building_stock.csv

