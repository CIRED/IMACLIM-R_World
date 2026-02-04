# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Nicolas Graves, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

# date creation: 23-04-2021
# contributors: Florian Leblanc (first)
# description: extract and compile macroeconommic data from EconMap scenarios database, for Imaclim-R

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


###################
# default if no argument - useful for development
data_path_default = '/data/public_data/CEPII/EconMap/download/'

GTAPpath = '/data/shared/GTAP/'


###################
# Loading argument
parser = argparse.ArgumentParser('aggregate GTAP data')

parser.add_argument('--data-path', nargs='?',const=data_path_default, type=str, default=data_path_default)

args = parser.parse_args()

data_path = args.data_path

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

dict_NordSud = { 'Nord': ['USA', 'CAN', 'EUR', 'JAN', 'CIS'], 'Sud': ['RAL', 'RAS', 'IND', 'CHN', 'BRA', 'MDE', 'AFR']}

###################
# Regional aggregation

EconMap_scenarios = [f for f in os.listdir(data_path) if os.path.isfile( os.path.join(data_path, f)) and f.split('.')[-1]=='csv']

# investmeent and saving rate in GDP percentage

for nb_sc, scenario_name in enumerate(EconMap_scenarios):
    sc_data = pd.read_csv( data_path + scenario_name, sep=',', header=0)

    # checking geographical coverage
    if nb_sc == 0:
        print("Checking geographical coverage and consistency\n")
        list_reg_econmap = list(set(sc_data['code_wb'].to_list()))
        missing_in_ISO = [elt for elt in list_reg_econmap if not elt in ISO2GTAP_dict.keys()]
        missing_in_EconMap = [elt for elt in ISO2GTAP_dict.keys() if not elt in list_reg_econmap]
        print("Missing in Iso: ", missing_in_ISO)
        print("Missing in EconMap: ", missing_in_EconMap)
        list_gtap_missing = list()
        for elt in missing_in_EconMap:
            list_gtap_missing.append( ISO2GTAP_dict[elt])
            if not ISO2GTAP_dict[elt][0] == 'x':
                print( "Missing elemnt of GTAP in EconMap, not in a 'Rest of ..' region: " + elt, ISO2GTAP_dict[elt])
        print("all Missing GTAP regions in EconMap: ", set(list_gtap_missing), "\n")
    # 2 changes requiredd   ['ROM', 'ZAR']  <---   ROU     COD; because of old ISO code
    for old_code, new_code in [ ('ROM', 'ROU'), ('ZAR', 'COD')]:
        sc_data['code_wb'] = np.where( sc_data['code_wb'] == old_code, new_code, sc_data['code_wb'])
    # 'Rest of ..' gtap regions ('x??') are missing
    # Other are Islands and Taiwan
    # ALA fin, Åland Islands; CCK aus, Cocos (Keeling) Islands; CXR aus, Christmas Island; GLP fra, Guadeloupe
    # HMD aus, Heard Island and McDonald Islands; MTQ fra, Martinique; NFK aus, Norfolk Island; REU fra, Réunion; SJM nor, Svalbard and Jan Mayen
    # TWN twn, Taiwan, Province of China

    # actuel aggregation
    gdp_var = 'gdp_05' # 'gdp_crt'
    sc_data['savings'] = sc_data['savings_rate'] * sc_data[ gdp_var] /100
    sc_data['investments'] = sc_data['investment_rate'] * sc_data[ gdp_var] /100

    sc_data['Region_Imaclim'] = list(map(lambda x: ISO2Imaclim_dict[x], sc_data['code_wb']))
    sc_data = sc_data.groupby(['Region_Imaclim', 'year']).sum()[ ['savings', 'investments', gdp_var]]
    
    sc_data['savings_rate'] = sc_data['savings'] / sc_data[ gdp_var]
    sc_data['investment_rate'] = sc_data['investments'] / sc_data[ gdp_var]

    with open( scenario_name+'.csv','w') as file:
        file.write('//CEPII data from EconMAP / MAGE simulation; rates are in % of gdp\n//Unit: million constant 2005 USD\n')
        #sc_data.loc[(slice(None),slice(None),flows_to_save_Imaclim),products_to_save].to_csv(file,sep= '|')
        sc_data.to_csv(file,sep= '|')

