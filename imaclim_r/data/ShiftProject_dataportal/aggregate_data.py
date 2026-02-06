#! /data/software/mambaforge/mambaforge/envs/IMACLIM_R/bin/python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


import numpy as np
import pandas as pd
import pycountry
import os
import sys

#-------------------------------------------------------------------------
def import_one_csv(path_data, filename):
    country_name = filename.split(' - ')[1].split(',')[0]
    df = pd.read_csv( path_data+filename, sep=";", decimal=",")
    df =df.rename( {"Unnamed: 0":"time"}, axis=1)
    df['region'] = country_name
    # only extract year from datetime
    df['time'] = df['time'].apply( lambda x: int(x.split('-')[0]))
    # convert
    return df
#-------------------------------------------------------------------------
def pycountry_search_by_x( df_reg_map, c_x_list):
    alpha_3 = [c.alpha_3 for c in pycountry.countries]
    for reg in [r for r,v in df_reg_map.items() if v is None]:
        # exact match
        if reg in c_x_list:
            df_reg_map[reg] = alpha_3[ c_x_list.index(reg)]
        # partly present
        if df_reg_map[reg] is None:
            match = [c for c in c_x_list if reg in c]
            if len(match) == 1:
                df_reg_map[reg] = alpha_3[ c_x_list.index(match[0])]
            if len(match) > 1:
                print("several choices", reg, match)
        # third try: first word
        if df_reg_map[reg] is None:
            match = [c for c in c_x_list if reg.split(' ')[0] in c]
            if len(match) == 1:
                df_reg_map[reg] = alpha_3[ c_x_list.index(match[0])]
            if len(match) > 1:
                print("several choices", reg, match)
        # fourth try: first word
        if df_reg_map[reg] is None:
            match = [c for c in c_x_list if reg.split(' ')[-1].replace('(','').replace(')','') in c]
            if len(match) == 1:
                df_reg_map[reg] = alpha_3[ c_x_list.index(match[0])]
            if len(match) > 1:
                print("several choices", reg, match)
    print(df_reg_map)
    return df_reg_map
#-------------------------------------------------------------------------
def fuzzy_search(df_reg_map):
    for reg in [r for r,v in df_reg_map.items() if v is None]:
        try:
            fuzzy = pycountry.countries.search_fuzzy(reg)
        except LookupError:
            print(f"No fuzzy match for:", reg)
        else:
            if len(fuzzy) == 1:
                df_reg_map[reg] = fuzzy[0].alpha_3
    return df_reg_map
#-------------------------------------------------------------------------
def pycountry_create_map(df, manual_renaming_name=None):
    df_reg_map = {k:None for k in list(set(df['region']))}
    c_name = [c.name for c in pycountry.countries]
    c_official_name = []
    for c in pycountry.countries:
        try:
            c_official_name.append(c.official_name)
        except:
            c_official_name.append(c.name)
    df_reg_map = fuzzy_search(df_reg_map)
    df_reg_map = pycountry_search_by_x( df_reg_map, c_name)
    df_reg_map = pycountry_search_by_x( df_reg_map, c_official_name)
    # finally complete with manual mapping
    if manual_renaming_name is not None:
        for c1, c2 in manual_renaming_name.items():
            df_reg_map[c1] = pycountry.countries.get(name=c2).alpha_3
    not_found = [k for k,v in df_reg_map.items() if v==None]
    return df_reg_map, not_found
#-------------------------------------------------------------------------
def aggregate_and_export( df, species, year_cumulative, year_cumulative_start, output_dir):
    df = df[ (df['time'] <= int(year_cumulative)) & (df['time'] >= int(year_cumulative_start)) ]
    dd = df[ [species,'region_im']]
    dd = dd.groupby( ['region_im']).sum() #.reset_index()
    species_export_name = species.replace(' ','_')
    with open(output_dir + 'cumulative_extraction_'+species_export_name+'_'+str(year_cumulative_start)+'_'+str(year_cumulative)+'.csv','w') as file:
        file.write('// Cumulative extraction of ' + species+ ' from ' + str(year_cumulative_start) + ' until ' + str(year_cumulative) + ' in Mtoe\n')
        dd.reindex(order_regions).to_csv(file, sep='|',header=False,index=True)
    return 0
#-------------------------------------------------------------------------


# load argument and data
if len(sys.argv)>1:
    path_data = sys.argv[1]
    year_cumulative = sys.argv[2]
    year_cumulative_start = sys.argv[3]
    iso_rules_path = sys.argv[4]
else:
    path_data="/data/public_data/ShiftProject_dataportal/download/"
    year_cumulative = 2014
    year_cumulative_start = 2007
    iso_rules_path = '../ISO_rules/ISO_GTAP_IMACLIM_rules.csv'

# list files in folder
list_file = os.listdir(path_data)

# import all files
df = pd.concat( [ import_one_csv(path_data, f) for f in list_file])

#Import order_regions 
order_regions = pd.Index(np.genfromtxt('../order_regions.csv',dtype='str'))

output_dir = './results/'
os.makedirs(output_dir, exist_ok=True)

################################
# convert region to ISO
# a/ find countries ISO with py_country
dict_rename_manually = {'Turkey':'Türkiye', 'Democratic Republic of the Congo': 'Congo, The Democratic Republic of the', 'Czechoslovakia':'Czechia', 'Inde':'India','United States Virgin Islands':'Virgin Islands, U.S.', 'Reunion':'Réunion', 'Swaziland':'Eswatini', 'Faeroe Islands':'Faroe Islands', 'Ivory Coast':"Côte d'Ivoire",'Burma':'Myanmar'}
dict_map, not_found_list = pycountry_create_map(df, manual_renaming_name=dict_rename_manually)

for e in ['Yugoslavia']:
    dict_map[e] = e

# Convert to IMACLIM aggrezgation regions
iso_rules = pd.read_csv(iso_rules_path,sep='|')
iso_imaclim_dict = pd.Series( iso_rules['IMACLIM'].values,index=iso_rules['Alpha-3 code']).to_dict()
# check for missing country name and merge ISO/Imaclim disctionnary
missing_reg = [r for r in dict_map.values() if not r in iso_imaclim_dict.keys()]

iso_imaclim_dict['Yugoslavia'] = 'EUR'

#################################
# aggregate data
df['region_iso'] = df['region'].map(dict_map)
df['region_im'] = df['region_iso'].map(iso_imaclim_dict)

# replace nan by zeros
df = df.fillna(0)

column_species = [e for e in df.columns if not 'time' in e and not 'region' in e]

for c in column_species:
    aggregate_and_export( df, c, year_cumulative, year_cumulative_start, output_dir)
