#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


path_output='.'
# selection of the NDC/NPi emi pathways: 1 take the mean of the models, 2 the median, 3 the min and 4 the max
 # this is applied on the variables 'delta 2025-2020' and 'delta 2030-2020' independently, meaning that the model providing the median can be different for the two periods
crit_emi=4
# available models: GCAM-PR 5.3; GEMINI-E3 7.0; MUSE
#add the variable model in the R arguments to select the model
#model='GCAM-PR 5.3'


mkdir -p $path_output

path_data_ndc=$public_data/VandeVenetal_NDC

# loop on ag_rule, # of aggregated regions, see the aggregate_ar6 function in the R script
for ag_rule in 1 2 3 4
do
    $Rdata_imaclim_env -f "./process_NPi_NDC.R" --args $path_data_ndc $path_output $crit_emi $ag_rule # add $model if needed
done
