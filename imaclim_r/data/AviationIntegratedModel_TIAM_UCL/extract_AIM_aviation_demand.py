# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Nicolas Graves
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

# date creation: 05-08-2022
# contributors: Florian Leblanc (first)
# description: extract and compile the aviation demand scenario from the AIM model (TIAM UCL)

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
import collections
import argparse
from common_pandas_utils import df_set_column_values_as_columns_indexes 
from common_pandas_utils import df_set_columns_indexes_as_column_values 


###################
# default if no argument - useful for development
data_path_default = '/data/shared/AviationIntegratedModel_TIAM_UCL/data/'
im_final_agg_rule_default = '../GTAP/aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv'

data_path = sys.argv[1] 
im_final_agg_rule = sys.argv[2] 
#data_path = data_path_default 
#im_final_agg_rule = im_final_agg_rule_default 
GTAPpath = '/data/shared/GTAP/'


###################
# functions
#---------------------------------------------------------------------------------------------------
def interpolate_years(df, time_col='Years'):
    df['datetime'] = pd.to_datetime(df[time_col], format="%Y")
    df.index = df['datetime']
    del df['datetime']
    df = df.groupby('Region_Imaclim').resample('Y').mean()
    df_interp = df.interpolate(method='linear').reset_index()
    del df_interp['datetime']
    return df_interp
#---------------------------------------------------------------------------------------------------
def output_scenario(df,var):
    # set year as column
    df = df_set_column_values_as_columns_indexes( sc_data_interp.reset_index()[['Region_Imaclim','Years',var]], column_name_as_index='Years', column_name_for_value= var)
    # set region as index, and in right order
    df = df.set_index('Region_Imaclim')
    df = df.reindex(im_region_orderdata)
    # rename column as integer, and sort it gradually
    df = df.rename( {n: int(n) for n in df.keys()}, axis=1) # years in int
    df = df[ sorted(list(df.keys()))]

    with open( var+'__imaclim_aggregated__'+scenario_name,'w') as file:
        file.write('//Demand for Aviation from the AIM (Aviation Model Internationnal - TIAM-UCL)- runs from the NAVIAGTE meta-model; unit is '+units+' \n')
        df.to_csv(file,sep= '|')
    return 0
#---------------------------------------------------------------------------------------------------

###################
# regional dict
iso3_codes_path = '/data/public_data/country-codes/data/country-codes.csv'
Imaclim2ISO3_path = '/data/public_data/regional_aggregations/imaclim/'

country_codes_raw = pd.read_csv(iso3_codes_path)[['ISO3166-1-Alpha-3','name','official_name_en']]
country_codes = country_codes_raw[['ISO3166-1-Alpha-3','official_name_en']]
no_official_country_name = country_codes.loc[country_codes['official_name_en'].isna()]['ISO3166-1-Alpha-3'].to_list()
country_codes = pd.concat([country_codes,country_codes_raw[country_codes_raw['ISO3166-1-Alpha-3'].isin(no_official_country_name)][['ISO3166-1-Alpha-3','name']].rename(columns={'name': 'official_name_en'})])
country_codes.set_index("official_name_en", inplace=True)
country_codes = country_codes.to_dict()['ISO3166-1-Alpha-3']

# loading dict to match gtap with iso3
ISO2GTAP = pd.read_csv(GTAPpath+'./ISO3166_GTAP.csv')[['ISO','REG_V10']]
ISO2GTAP['ISO3'] = ISO2GTAP['ISO'].apply(lambda x: x.upper())
ISO2GTAP_dict = ISO2GTAP.set_index('ISO3')['REG_V10'].to_dict()

ISO2Imaclim = pd.read_csv(Imaclim2ISO3_path + './imaclim_ISO3_aggregates.csv', sep='|')
ISO2Imaclim_dict = ISO2Imaclim.set_index('ISO3')['Im_region'].to_dict()

with open(im_final_agg_rule, newline='') as f:
    reader = csv.reader(f, delimiter='|')
    im_region_orderdata = [tuple(row)[0] for row in reader]

###################
# Regional aggregation

aim_scenarios =  [f for f in os.listdir(data_path) if os.path.isfile( os.path.join(data_path, f)) and f.split('.')[-1]=='csv' and 'RPK' in f]

for nb_sc, scenario_name in enumerate(aim_scenarios):
    sc_data = pd.read_csv( data_path + scenario_name, sep=',', header=0, skiprows=[1])
    # removed unamed col
    for col in [col for col in sc_data.keys() if 'Unnamed' in col]:
        del sc_data[col]
    if nb_sc == 0:
        units = pd.read_csv( data_path + scenario_name, sep=',', header=0, skiprows=range(2,3000)).values[0,-1]

    # checking geographical coverage
    if nb_sc == 0:
        print("Checking geographical coverage and consistency\n")
        list_reg = list(set(sc_data['Country'].to_list()))
        missing_in_ISO = [elt for elt in list_reg if not elt in ISO2GTAP_dict.keys()]
        missing_in_data = [elt for elt in ISO2GTAP_dict.keys() if not elt in list_reg]
        print("Missing in Iso: ", missing_in_ISO)
        print("Missing in data: ", missing_in_data)
        list_gtap_missing = list()
        for elt in missing_in_data:
            list_gtap_missing.append( ISO2GTAP_dict[elt])
            if not ISO2GTAP_dict[elt][0] == 'x':
                print( "Missing elemnt of GTAP in data, not in a 'Rest of ..' region: " + elt, ISO2GTAP_dict[elt])
        print("all Missing GTAP regions in data: ", set(list_gtap_missing), "\n")

    # data treatement
    # total RPK
    sc_data['Total_RPK'] = sc_data['Domestic_RPK'] + sc_data['International_RPK']
    list_var = [elt for elt in sc_data.keys() if 'RPK' in elt]
    # regional mapping
    sc_data['Region_Imaclim'] = list(map(lambda x: ISO2Imaclim_dict[x], sc_data['Country']))
    sc_data = sc_data.groupby(['Region_Imaclim', 'Years']).sum()[ list_var]

    # interplotation
    sc_data_interp = interpolate_years( sc_data.reset_index(), time_col='Years')
   
    # output
    sc_data_interp = sc_data_interp.set_index('Region_Imaclim')
    for var in list_var:
        output_scenario( sc_data_interp, var)
