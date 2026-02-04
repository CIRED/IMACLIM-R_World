# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import pandas as pd
import os
import sys
from fuzzywuzzy import fuzz
import re


output_path='results/'
if not os.path.exists(output_path):
    # If it doesn't exist, create it
    os.makedirs(output_path)

# function
#---------------------------------------------
def find_matching_country_name(country_name, dataframe, coutnry_column_name):
    best_match = None
    second_best_match = None
    best_score = 0
    
    for name in dataframe[coutnry_column_name]:
        score = fuzz.ratio(country_name, name)
        if score > best_score:
            best_score = score
            second_best_match = best_match
            best_match = name
    
    return best_match, second_best_match
#---------------------------------------------

#load data
input_file=sys.argv[1]
iso_rules_path=sys.argv[2]

# uncomment for development:
#input_file= '/data/public_data/Global_Carbon_Budget/extracted/National_LandUseChange_Carbon_Emissions_2022v10-OSCAR-normalized.csv'
#iso_rules_path = '/diskdata/cired/leblanc/ImaclimR_version2.0/trunk_v2.0_GENRATE_DATA/data/ISO_rules/ISO_GTAP_IMACLIM_rules.csv'

output_filename = input_file.split('/')[-1].split('.')[0]

#########################
# Load and format data
df = pd.read_csv(input_file, sep='|', skiprows=[i for i in range(7)] + [8])
df=df.rename({'Unnamed: 0':'Year'},axis=1)
df = df.fillna(0)
# Melt the dataframe to combine country columns into a single column
df = df.melt(id_vars='Year', var_name='Country', value_name='Value')
# Pivot the melted dataframe
#df = df.pivot(index='Country', columns='Year', values='Value')

unit = pd.read_csv(input_file, skiprows=2,nrows=1,header=None)
unit = [elt.replace('|','') for elt in unit.values[0][0].split('=')[1:]]
unit_convert = float(re.findall(r'(\d+(?:\.\d+)?)', unit[1])[0])
unit_string = unit[1].replace(str(unit_convert),'').replace(' ','_')

#########################
# load iso dict
iso_rules = pd.read_csv(iso_rules_path,sep='|')

# IMACLIM order region for output and scilab load
imaclim_order_reg = [elt[0] for elt in  pd.read_csv('../order_regions.csv',header=None).values.tolist()]

#########################
# Check region name and match ISO
list_region = set(df['Country'].to_list())
#list_region.remove('Year')

missing=[elt for elt in list_region if not elt in iso_rules['Country name'].to_list()]
missing2=[elt for elt in missing if not elt in iso_rules['Official state name'].to_list()]
#-> there is not perfect match for all countries

# create match
dict_region_match = {}
not_missing = [elt for elt in list_region if elt in iso_rules['Country name'].to_list()]
for elt in not_missing:
    dict_region_match[elt] = elt
for elt in missing:
    best_match, second_best_match = find_matching_country_name(elt,iso_rules,'Country name')
    dict_region_match[elt] = best_match
    print(elt,'|',best_match, '|',second_best_match)

# manual correction
#Netherlands Antilles | Netherlands, Kingdom of the | Faroe Islands (the)
#Congo | Togo | Congo (the)
#Gambia | Zambia | Namibia
#Netherlands | New Zealand | Greenland
dict_region_match['Netherlands'] = 'Netherlands, Kingdom of the'
dict_region_match['Congo'] = 'Congo (the)'
dict_region_match['Gambia']= 'Gambia (the)'

# 'Bonaire, Sint Eustatius and Saba'   and 'Curaçao' already matched, so we dropped the redundant 'Netherlands Antilles'
dict_region_match.pop('Netherlands Antilles')

#########################
# aggregate and output data

df['Country name'] = df['Country'].map(dict_region_match)
df = pd.merge(df,  iso_rules[ ['Alpha-3 code','Country name','IMACLIM']], on='Country name')

df_out = df.groupby(['Year','IMACLIM']).sum().reset_index()
df_out = df_out.set_index('IMACLIM').loc[imaclim_order_reg].reset_index()
df_out = df_out.pivot(index='IMACLIM', columns='Year', values='Value')

# concert to GtCO2
numerical_columns = df_out.select_dtypes(include='number').columns
df_out[numerical_columns] = df_out[numerical_columns] * unit_convert
#output
df_out.to_csv(output_path+output_filename+"_"+unit_string+"_IMACLIM.csv",sep='|')


