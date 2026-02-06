# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


path_GTAP_agg_rule='../GTAP/aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv'

for year in 2014 2019 
do
	path_data_temp=$IRENA_data/Cap_$year'.csv'
	path_output='./installed_cap/'
	mkdir -p $path_output
	R -f "./agregation_Cap_IRENA.R" --args $year $path_data_temp $path_GTAP_agg_rule $path_output
done

year_ref=2014
year_obj=2019
path_results_IRENA='./installed_cap/'
path_output='./capital_costs/'
mkdir -p $path_output
R -f "./Capital_cost_compute.R" --args $year_ref $year_obj $path_results_IRENA $path_output

for year in 2015 2018
do
        path_data_temp=$IRENA_data/Prod_$year'.csv'
        path_output='./prod/'
	mkdir -p $path_output
        R -f "./agregation_Prod_tot.R" --args $year $path_data_temp $path_GTAP_agg_rule $path_output
        R -f "./agregation_Prod_ENR_IRENA.R" --args $year $path_data_temp $path_GTAP_agg_rule $path_output
done

