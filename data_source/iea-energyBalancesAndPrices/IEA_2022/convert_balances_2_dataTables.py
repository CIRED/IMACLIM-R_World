#! /usr/bin/env python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


import argparse
import os
import pandas as pd
import numpy as np
from io import StringIO
import csv
import re
from common_pandas_utils import df_set_column_values_as_columns_indexes
from common_pandas_utils import df_set_columns_indexes_as_column_values
from collections import Counter
from functools import partial, reduce
import linecache
import aggregation_GTAP
import copy

##################################################################################
# Parameters of the script
##################################################################################

# default if no argument - useful for development
input_file_default = 'EnergyBalancesDatabases/WBIG.TXT'

###################
# Loading argument

parser = argparse.ArgumentParser('Convert IEA .txt files to energy balances tables')

parser.add_argument('--input-file', nargs='?',const=input_file_default, type=str, default=input_file_default)

args = parser.parse_args()

input_file = args.input_file


##################################################################################
# functions
##################################################################################
#-------------------------------------------
#-------------------------------------------
#-------------------------------------------
#-----------------------------------------------------------------------------------------------------------

##################################################################################
# global dictionnaries
##################################################################################

##################################################################################
# Loading datas
##################################################################################
#-----------------------------------------------------------------------------------------------------------
print('Loading IEA extended energy balances')
df = pd.read_csv( input_file, names=['Region', 'Product', 'Year', 'Flow', 'Unit', 'Value'], skiprows=0, sep=r"\s+", na_values='NULL')

# set missing values or zero value to actual zeros
value_2_zero=['..','x','c']
for value_zero in value_2_zero:
    df.loc[df['Value']==value_zero,'Value']=0
df['Value'] = df['Value'].astype(float)

# loading dictionnaries
dict_flows_oldversion={}
dict_flows_newversion={}
with open('dico_flows.csv', mode='r') as infile:
    for row in csv.reader(infile,delimiter=','):
        val_new, val_old, key_short = row
        dict_flows_oldversion[key_short] = val_old
        dict_flows_newversion[key_short] = val_new

with open('dico_products.csv', mode='r') as infile:
    row_full, row_short = csv.reader(infile,delimiter=',')

dict_products = {key:value for (key,value) in zip(row_short,row_full)}

dict_region={}
with open('dico_region.csv', mode='r') as infile:
    for row in csv.reader(infile,delimiter=';'):
        short_n, long_n  = row
        dict_region[short_n] = long_n

# iso code for countries
iso3_codes_path = '/data/public_data/country-codes/data/country-codes.csv'
name, iso = pd.read_csv(iso3_codes_path)['name'].to_list(), pd.read_csv(iso3_codes_path)['ISO3166-1-Alpha-3'].to_list()
name, iso = pd.read_csv(iso3_codes_path)['official_name_en'].to_list(), pd.read_csv(iso3_codes_path)['ISO3166-1-Alpha-3'].to_list()
country_codes = {key:value for (key,value) in zip(name, iso)}
del country_codes[np.nan]

##################################################################################
# Data analysis
##################################################################################
#-----------------------------------------------------------------------------------------------------------
# list columns element to build dictionnaries

list_region=list(set(df['Region'].values))
list_year=list(set(df['Year'].values))
list_product=list(set(df['Product'].values))
list_flow=list(set(df['Flow'].values))

# element not yet in IEA dictionnaries
print( [elt for elt in list_flow if not elt in dict_flows_oldversion.keys()])
print( [elt for elt in list_product if not elt in dict_products.keys()])
print( [elt for elt in list_region if not elt in dict_region.keys()])

# element in IEA region name not in country_codes dict
list_long_name = [dict_region[elt].replace('Memo: ','') for elt in list_region]
print( [elt for elt in list_long_name if not elt in country_codes.keys()])

list_region_ok = [elt for elt in list_long_name if elt in country_codes.keys()]

manual_dict={'Other non-OECD Americas':'OTHER_NON_OECD_AMERICAS', 'Other non-OECD Asia':'OTHER_NON_OECD_ASIA',"Other Africa":"OTHER_AFRICA","Chinese Taipei":"TWN","Kosovo":"XKX"} 

dict_for_completion = {"United States":'United States of America',"Slovak Republic":'Slovakia','United Kingdom':'United Kingdom of Great Britain and Northern Ireland',"Cote d'Ivoire":"Côte d'Ivoire","Czech Republic":"Czechia","Palestinian Authority":"State of Palestine","Hong Kong (China)":"China, Hong Kong Special Administrative Region","People's Republic of China":"China","Curacao/Netherlands Antilles":'Curaçao',"Republic of the Congo":'Democratic Republic of the Congo',"Bolivarian Republic of Venezuela":'Venezuela (Bolivarian Republic of)',"Plurinational State of Bolivia":"Bolivia (Plurinational State of)","Republic of North Macedonia":"The former Yugoslav Republic of Macedonia","Islamic Republic of Iran":'Iran (Islamic Republic of)',"Korea":"Republic of Korea"}

# completion with country name which have a different spelling
for iea_c, code_c in dict_for_completion.items():
    country_codes[iea_c] = country_codes[code_c]

# manual completion in accordance with the nomenclature
for iea_c, iso_c in manual_dict.items():
    country_codes[iea_c] = iso_c

# completion for 'Memo' countries:
for reg in [dict_region[elt] for elt in list_region if 'Memo' in dict_region[elt]]:
    if reg.replace('Memo: ','') in country_codes.keys():
        country_codes[reg] = country_codes[reg.replace('Memo: ','')]

# final manual completion: use iea name
for elt in [elt for elt in list_long_name if not elt in country_codes.keys()]:
    country_codes[elt] = elt.replace(' ','_').replace('/','_').upper()   

# manual change for World
country_codes['World'] = 'WLD'


##################################################################################
# Export tables
##################################################################################
#-----------------------------------------------------------------------------------------------------------

# output folder
output_path='results/EnergyBalancesDatabases/wbig_old_iea_code/'

if not os.path.isdir('results/'):
    os.mkdir('results/')
if not os.path.isdir('results/EnergyBalancesDatabases/'):
    os.mkdir('results/EnergyBalancesDatabases/')
if not os.path.isdir(output_path):
    os.mkdir(output_path)

#loop on countries, loop on year, unit: En ktoe
df_ktoe = df[ df['Unit']=='KTOE']

for year in list_year:
    df_yr = df_ktoe[ df_ktoe['Year']==year]
    output_path_year=output_path+str(year)+'/'
    if not os.path.isdir(output_path_year):
        os.mkdir(output_path_year)
    for region in [reg for reg in list_region if dict_region[reg] in country_codes.keys()]:
        df_reg = df_yr[ df_yr['Region']==region]

        # data selection and formating
        df_2_export = df_reg[ ['Product','Flow','Value']]

        df_i=df_set_column_values_as_columns_indexes(df_2_export, 'Product', 'Value')
        df_i=df_i.fillna(0)
        df_i['Flow'] = df_i['Flow'].map(dict_flows_oldversion)
        # Removing flow which are not in the dict
        df_i = df_i[ df_i['Flow'] != '']

        # data export
        first_line = list(df_i.keys())
        first_line = ['PRODUCT'] + [ dict_products[elt] for elt in first_line[1:]]
        second_line = ['FLOW'] + ['' for elt in first_line[1:]]

        with open(output_path_year+'wbig_'+str(year)+'_'+country_codes[dict_region[region]]+'.csv','w') as csv_file:
            csv_reader = csv.writer(csv_file, delimiter=';')
            csv_reader.writerow(first_line)
            csv_reader.writerow(second_line)
            table = df_i.values
            for i in range(table.shape[0]):
                csv_reader.writerow(table[i])

