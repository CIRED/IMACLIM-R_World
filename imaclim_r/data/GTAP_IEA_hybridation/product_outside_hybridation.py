# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

# This file is designed to support the diagnosis of GTAP treatment of IEA data.
# Results and corresponding paragraphs are compiled in the file of the same name on the Google Drive folder ImaclimV2.
# A large part of the file is just a copy of the file comparaison_GTAP_AIE_Enerdata.py, which targets were broader originally.

############
###libraries
############
import pandas as pd
import numpy as np
import csv
import sys
import os
import copy
import common_cired
import aggregation_GTAP
import argparse

###################
# default if no argument - useful for development
year_default = 2014
#gtap_path_default = '../GTAP/GTAP_Imaclim_before_hybridation/outputs_GTAP10_'+str(year_default)+'/'

iea_agg_filepath_default = '../IEA/iea_aggregation_for_hybridation/results_'+str(year_default)+'/'
path_products_aggregations = "/data/public_data/products_aggregations/iea_aggregation/web_aggregation__general_rules_for_imaclim.d/"
output_path_default = "product_outsite_hybridation/"
#non_specified_default = None
#wb_datapath_default = '/data/public_data/World_Bank_Data_Catalog_21052022/extracted/'

##################
# load IEA fonctions
exec(open("../IEA/iea_aggregation_for_hybridation/code/aggregation_functions.py").read())


###################
# Loading argument
parser = argparse.ArgumentParser('aggregate GTAP data')

parser.add_argument('--year', nargs='?', const=year_default, type=int, default=year_default)
parser.add_argument('--iea-data-path', nargs='?',const=iea_agg_filepath_default, type=str, default=iea_agg_filepath_default)
#parser.add_argument('--gtap-data-path', nargs='?',const=gtap_path_default, type=str, default=gtap_path_default)
parser.add_argument('--output-path', nargs='?',const=output_path_default, type=str, default=output_path_default)

args = parser.parse_args()

year = args.year
iea_agg_file_path = args.iea_data_path
output_folder = args.output_path


# the IEA flow category "non-specified" need to be atributed to an ISIC sector.
#non_specified_arg = args.non_specified

#wb_datapath = args.wb_datapath

###################
###global variables

ktoe2Mtoe = 1e-3
PJ2Mtoe = 23884.6 * 1e-6

transpoe_international_fuel_correction = False
import_export_international_fuel_correction = True

print('\n//////////////////////////////////////')
print('     ---> Load IEA energy balances for Imaclim:')

# loading
iea_imaclim_web = pd.read_csv( iea_agg_file_path + 'Imaclim_final_saved.csv', sep='|', header=3)
iea_imaclim_web_w_excluded = pd.read_csv( iea_agg_file_path + 'Imaclim_final_+_outside_hybridation.csv', sep='|', header=3)
iea_imaclim_web_w_excluded = iea_imaclim_web_w_excluded.round(decimals = 15)

dict_aggregate_excluded = read_aggregation_rules(path_products_aggregations + "iea_EEB2Imaclim__discarded.csv")

print('\n//////////////////////////////////////')
print('     ---> Compute:')

elt_excluded_from_hybridation = [elt for elt in iea_imaclim_web_w_excluded.columns if not elt in iea_imaclim_web.columns]

# check everything is in the dict
print("Missing in dict: ", [elt for elt in elt_excluded_from_hybridation if not elt in sum(dict_aggregate_excluded.values(), [])] )
index_not_in_dataframe = [elt for elt in sum(dict_aggregate_excluded.values(), []) if not elt in elt_excluded_from_hybridation]
print("Index not in dataframe: ", index_not_in_dataframe)

# remove missing index
dict_aggregate_excluded = {k:[elt for elt in v if not elt in index_not_in_dataframe] for (k,v) in dict_aggregate_excluded.items()}

# Aggregate values
for key in dict_aggregate_excluded.keys():
    iea_imaclim_web_w_excluded[key] = iea_imaclim_web_w_excluded[ dict_aggregate_excluded[key]].sum(axis=1)

iea_imaclim_web_w_excluded = iea_imaclim_web_w_excluded[['Region_Im','Year','Flow'] + list(dict_aggregate_excluded.keys())]


print('\n//////////////////////////////////////')
print('     ---> Export results:')

if not os.path.isdir(output_folder):
    os.mkdir(output_folder)

# Define a lambda function to multiply numeric values by scalar
multiply_numeric_ktoe2Mtoe = lambda col: col * ktoe2Mtoe if pd.api.types.is_numeric_dtype(col) else col

for flow in list(set(iea_imaclim_web_w_excluded['Flow'])):
    df2export = iea_imaclim_web_w_excluded[ iea_imaclim_web_w_excluded['Flow']==flow][ ['Region_Im'] + list(dict_aggregate_excluded.keys())].apply(multiply_numeric_ktoe2Mtoe)
    df2export.to_csv(output_folder + flow.replace(' ','_')+'.csv', index=False, sep='|')
