# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import pandas as pd
import sys
import csv

# to be removed in later pandas version
pd.set_option('future.no_silent_downcasting', True)

iso_file, iso2gtap_file, gtap2imaclim_file = sys.argv[1], sys.argv[2], sys.argv[3]
outpute_file = sys.argv[4]
#iso_file='/data/public_data/ISO_wikipedia/results/List_of_ISO_3166_country_codes_1_cleaned.csv'
#iso2gtap_file='/data/shared/GTAP/ISO3166_GTAP.csv'
#gtap2imaclim_file='../GTAP/aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv'
#outpute_file = 'ISO_GTAP_IMACLIM_rules.csv'

df_iso = pd.read_csv(iso_file)
df_iso2gtap = pd.read_csv(iso2gtap_file)

df_iso2gtap['ISO'] = df_iso2gtap['ISO'].str.upper()

# check that all ISO code are present in df_iso2gtap
[elt for elt in set(df_iso['Alpha-3 code']) if not elt in set(df_iso2gtap['ISO'])]
#['BES', 'MAF', 'BLM', 'CUW', 'SXM', 'SSD']
dict_manual_complete = {'BES':'xcb', 'MAF':'xcb','BLM':'xcb','CUW':'xcb','SXM':'xcb', 'SSD':'xec', 'SCG':'xer'}

# manally complete df_iso2gtap
for key, val in dict_manual_complete.items():
    new_line = {}
    new_line['ISO'] = key
    for elt in ['REG_V6', 'REG_V8', 'REG_V81', 'REG_V10']:
        new_line[elt] = val
    new_line['CountryName'] = ''
    # Add the new line to the DataFrame
    df_iso2gtap.loc[len(df_iso2gtap)] = new_line

#remove elt not in iso:
[elt for elt in set(df_iso2gtap['ISO'])  if not elt in set(df_iso['Alpha-3 code'])] 

# Manually add ANT & SCG to df_iso
list_ISO_as_country_groups = ['SCG','ANT'] # to be removed in the list considering only countries which are not group of countries
df_iso = pd.concat( [df_iso, pd.Series({'Alpha-3 code':'SCG', 'Country name':'Serbia and Montenegro'})], ignore_index=True)
df_iso = pd.concat( [df_iso, pd.Series({'Alpha-3 code':'ANT', 'Country name':'Netherlands Antilles'})], ignore_index=True)

# renaming
df_iso2gtap = df_iso2gtap.rename( {'REG_V10':'GTAP_V10', 'ISO':'Alpha-3 code'}, axis=1)

# load gtap2imaclim_file
# Open the CSV file
with open(gtap2imaclim_file, 'r') as csvfile:
    # Create a CSV reader object
    reader = csv.reader(csvfile, delimiter='\t')
    dict_imaclim2gtap = dict()
    # Iterate over the rows
    for i, row in enumerate(reader):
        dict_imaclim2gtap[row[0].split('|')[0]] = row[0].split('|')[1:]

revered_dict_imaclim2gtap = dict()
for key, value in dict_imaclim2gtap.items():
    for elt in value:
        revered_dict_imaclim2gtap[elt] = key

################################
# final csv

col2keep = list(df_iso.columns) + ['GTAP_V10'] + ['IMACLIM']

df_iso = pd.merge(df_iso, df_iso2gtap, on='Alpha-3 code')
df_iso['IMACLIM'] = df_iso['GTAP_V10'].map(revered_dict_imaclim2gtap)

# avoid \n in file
#df_iso['Country name'] = df_iso['Country name'].replace('\n','')
df_iso = df_iso.replace(r'\n',' ', regex=True)


df_iso_nogroups = df_iso[ ~df_iso['Alpha-3 code'].isin(list_ISO_as_country_groups)]

df_iso_nogroups[ col2keep].to_csv(outpute_file, sep='|', index=False)

df_iso_groups = df_iso #[ df_iso['Alpha-3 code'].isin(list_ISO_as_country_groups)]
list_output_file = outpute_file.split('.')
outpute_file_with_groups = '.'.join(list_output_file[0:-1]) + "__with_groups" + '.' + list_output_file[-1]

df_iso_groups[ col2keep].to_csv(outpute_file_with_groups, sep='|', index=False)
