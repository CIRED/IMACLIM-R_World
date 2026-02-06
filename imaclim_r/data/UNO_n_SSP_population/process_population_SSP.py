#! /usr/bin/env python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


import pandas as pd
import csv
import collections
from numpy import genfromtxt
import numpy as np
import os
import sys

#Import order_regions 
order_regions = pd.Index(genfromtxt('../order_regions.csv',dtype='str'))

#last_historical_year = 2021
#nb_year_interpolation = 5
#dataPath='/data/public_data/SSP_update_NAVIGATE/extracted/'
if len(sys.argv)>1:
    last_historical_year = int(sys.argv[2])-1
    nb_year_interpolation = int(sys.argv[3])
    dataPath = sys.argv[1] 
    iso_rules_path = sys.argv[4]
    active_pop_range = sys.argv[5]
else: # defautl parameters for debugging
    last_historical_year = 2021
    nb_year_interpolation = 5
    dataPath='/data/public_data/IIASA_scenario_explorer_public/download/'
    iso_rules_path = '../ISO_rules/ISO_GTAP_IMACLIM_rules.csv'
    active_pop_range = '20-59'

#minimum and maximum working age
min_wa = int(active_pop_range.split('-')[0])
max_wa = int(active_pop_range.split('-')[1])

##########################################
## Load data and dictionnaries
##########################################

ssp_pop = pd.read_csv(dataPath + 'ssp__all.csv', delimiter=',', encoding="utf-8")
var_list = [var for var in list(set(ssp_pop.Variable)) if 'Population' in var and var.count('|') ==2] 
var_list = [var for var in var_list if var.count('|') <=2] # discard population variable with qualifications
ssp_pop = ssp_pop[ ssp_pop['Variable'].isin(var_list)]

ssp_pop_world = ssp_pop[ (ssp_pop['Region']=='World') & (ssp_pop['Variable']=='Population')]

# convert to thousands of people
numeric_cols = ssp_pop.select_dtypes(include='number').columns 
ssp_pop[numeric_cols] = ssp_pop[numeric_cols] * 1e3
ssp_pop['Units'] = 'thousand'

Imaclim2ISO3_path = '/data/public_data/regional_aggregations/imaclim/'
ISO2Imaclim = pd.read_csv(Imaclim2ISO3_path + './imaclim_ISO3_aggregates.csv', sep='|')
ISO2Imaclim_dict = ISO2Imaclim.set_index('ISO3')['Im_region'].to_dict()

# load ISO dict
iso_rules = pd.read_csv(iso_rules_path,sep='|')

# Loading UN historcal data
UN_historical = pd.read_csv('results/total_population_trajectory_UNO_historical.csv', delimiter='|', encoding="utf-8", index_col='Imaclim_region')

##########################################
## Check data and dictionnaries
##########################################

# check for missing country name and merge ISO/Imaclim disctionnary
missing_reg = [elt for elt in list(set(ssp_pop['Region'])) if not elt in iso_rules['Country name'].values and not elt=='World' and not '(R' in elt ] 
print( [elt for elt in list(set(ssp_pop['Region'])) if not elt in iso_rules['Country name'] ])

# dictionnary of missing reg in dict:
dict_missing_reg = {}
# automatic completion
list_remove = list()
for reg in missing_reg:
    find = [var for var in iso_rules['Country name'].values if reg in var]
    if len(find) == 1:
        dict_missing_reg[reg] = find[0]
        list_remove.append(reg)
for elt in list_remove:
    missing_reg.remove(elt)

for reg in missing_reg:
    find = [var for var in iso_rules['Official state name'].values if reg in var]
    print(reg, [iso_rules[ iso_rules['Official state name']==var]['Country name'].values for var in find], find)

"""
Laos [] []
Niger [array(['Niger (the)'], dtype=object), array(['Nigeria'], dtype=object)] ['The Republic of the Niger', 'The Federal Republic of Nigeria']
Sudan [array(['South Sudan'], dtype=object), array(['Sudan (the)'], dtype=object)] ['The Republic of South Sudan', 'The Republic of the Sudan']
Congo [array(['Congo (the Democratic Republic of the)'], dtype=object), array(['Congo (the)'], dtype=object)] ['The Democratic Republic of the Congo', 'The Republic of the Congo']
North Korea [] []
Turkey [] []
United States Virgin Islands [] []
South Korea [] []
United States [array(['United States of America (the)'], dtype=object), array(['Virgin Islands (U.S.)'], dtype=object)] ['The United States of America', 'The Virgin Islands of the United States']
Democratic Republic of the Congo [array(['Congo (the Democratic Republic of the)'], dtype=object)] ['The Democratic Republic of the Congo']
"""

"""
Laos [] []
North Korea [] []
Turkey [] []
United States Virgin Islands [] []
South Korea [] []
"""

# complete manually with the above print:
dict_missing_reg['Niger'] = 'Niger (the)'
dict_missing_reg['Sudan'] = 'South Sudan'
dict_missing_reg['Congo'] = 'Congo (the Democratic Republic of the)'
dict_missing_reg['United States'] = 'United States of America (the)'
dict_missing_reg['Democratic Republic of the Congo'] = 'Congo (the Democratic Republic of the)'
# complete manually with the rest:
dict_missing_reg['Laos'] = "Lao People's Democratic Republic (the)"
dict_missing_reg['North Korea'] = "Korea (the Democratic People's Republic of)"
dict_missing_reg['Turkey'] = "Türkiye"
dict_missing_reg['United States Virgin Islands'] = "Virgin Islands (U.S.)"
dict_missing_reg['South Korea'] = "Korea (the Republic of)"

# rename region in ssp_pop
ssp_pop['Region'] = ssp_pop['Region'].map(dict_missing_reg).fillna(ssp_pop['Region'])

# check all is complete :
missing_reg = [elt for elt in list(set(ssp_pop['Region'])) if not elt in iso_rules['Country name'].values and not elt=='World' and not '(R' in elt ]
print(missing_reg)

ssp_pop = ssp_pop.rename( {'Region':'Country name'}, axis=1)
ssp_pop = pd.merge( ssp_pop, iso_rules[ ['Country name','Alpha-3 code','IMACLIM']], on='Country name')

list_country = list(set(ssp_pop['Alpha-3 code']))
print( [elt for elt in list_country if not elt in ISO2Imaclim_dict.keys()])
#['CUW', 'SXM', 'SSD']

# manually complete dictionnaries
ISO2Imaclim_dict['SSD'] = 'AFR'
ISO2Imaclim_dict['CUW'] = 'RAL'
#ISO2Imaclim_dict['SXM'] = 'EUR'

ssp_pop['Imaclim_region'] = ssp_pop['Alpha-3 code'].map(ISO2Imaclim_dict)

##########################################
## Compute and aggregate datas
##########################################

os.makedirs('./results/', exist_ok=True)

# Add a column base on age group and sex
ssp_pop[['Variable', 'Sex', 'AgeGrp']] = ssp_pop['Variable'].str.split('|', expand=True)

# Select only the numerical columns
numerical_columns = ssp_pop.select_dtypes(include='number').columns
# Group by 'Sex' and sum the numerical columns
ssp_pop = ssp_pop.groupby([col for col in ssp_pop.columns if col not in numerical_columns and col not in ['Sex']])[numerical_columns].sum().reset_index()

model = list(set(ssp_pop['Model']))[0]

#Aggregating total population data

act_pop_category = []
for pop_cat in list(set(ssp_pop['AgeGrp'])):
    first_split = pop_cat.split(' ')[1].split('-')
    if len(first_split) ==2: #esxclude the 100+ group
        min_wa_cat = int(first_split[0])
        max_wa_cat = int(first_split[0])
        if min_wa_cat >= min_wa and max_wa_cat <= max_wa:
            act_pop_category.append(pop_cat)

for ssp_sc in ['SSP'+str(i+1) for i in range(5)]:

    active_pop = ssp_pop.loc[ ssp_pop['AgeGrp'].isin(act_pop_category)]
    active_pop_agg = active_pop[active_pop['Scenario'].isin( [ssp_sc,'Historical Reference'])][['Imaclim_region','Variable'] + [elt for elt in numerical_columns] ].groupby(['Imaclim_region']).sum()

    active_pop_agg_hist = active_pop[active_pop['Scenario'].isin( ['Historical Reference'])][['Imaclim_region','Variable'] + [elt for elt in numerical_columns] ].groupby(['Imaclim_region']).sum()
    active_pop_agg_ssp = active_pop[active_pop['Scenario'].isin( [ssp_sc])][['Imaclim_region','Variable'] + [elt for elt in numerical_columns] ].groupby(['Imaclim_region']).sum()
    non_zero_hist = [ col for col in active_pop_agg_hist.columns if (active_pop_agg_hist[col].sum() != 0)]
    non_zero_hist_ssp = [ col for col in active_pop_agg_ssp.columns if (active_pop_agg_ssp[col].sum() != 0)]

    active_pop_agg = pd.concat( [active_pop_agg_hist[non_zero_hist], active_pop_agg_ssp[  [col for col in non_zero_hist_ssp if not col in non_zero_hist]]], axis=1) 
    active_pop_agg = active_pop_agg.drop('Variable', axis=1)

    #active_pop_agg = active_pop_agg .loc[(slice(None),slice('2002','2100')),:]

    # interpolate active pop
    list_year = [int(yr) for yr in active_pop_agg.columns  if yr.isdigit()] 
    missing_years = [yr for yr in range(min(list_year),max(list_year)+1,1) if not yr in list_year]
    active_pop_agg = active_pop_agg.rename( columns={key:int(key) for key in active_pop_agg.columns if key.isdigit()})
    # Create a DataFrame with the missing years and NaN values
    new_cols = pd.DataFrame({year: np.nan for year in missing_years}, index=active_pop_agg.index)
    # Concatenate in one step
    active_pop_agg = pd.concat([active_pop_agg, new_cols], axis=1)
    active_pop_agg = active_pop_agg.sort_index(axis=1, level=None, ascending=True, inplace=False, kind='quicksort', na_position='last', sort_remaining=True, ignore_index=False)
    active_pop_agg = active_pop_agg.interpolate(method='linear', axis=1, limit_area=None, limit_direction='both', columns = missing_years)
    active_pop_agg_GrowthRate = active_pop_agg.pct_change(axis='columns') 

    # Population
    ssp_pop_agg = ssp_pop[ssp_pop['Scenario']==ssp_sc][['Imaclim_region','Variable'] + [str(i) for i in range(last_historical_year,2101) if str(i) in ssp_pop.columns]].groupby(['Imaclim_region']).sum()
    #ssp_pop_agg = ssp_pop_agg.rename( columns={key:int(key) for key in ssp_pop_agg.columns if key in numerical_columns})
    #ssp_pop_agg = ssp_pop_agg.drop(columns=[i for i in range(last_historical_year,last_historical_year+nb_year_interpolation)]) 

    # merge historical UN data
    ssp_pop_agg = ssp_pop_agg.merge(UN_historical,on='Imaclim_region')
    ssp_pop_agg = ssp_pop_agg.drop('Variable', axis=1)

    # Generate a list of years to interpolate
    missing_years = [i for i in range(last_historical_year,2101) if not str(i) in ssp_pop_agg.columns]

    # Interpolate the missing years using linear interpolation
    ssp_pop_agg.columns = ssp_pop_agg.columns.astype(int)
    # Add missing years as columns with NaN values
    # Create a DataFrame with the missing years and NaN values
    new_cols = pd.DataFrame({year: np.nan for year in missing_years}, index=ssp_pop_agg.index)
    # Concatenate in one step
    ssp_pop_agg = pd.concat([ssp_pop_agg, new_cols], axis=1)

    #ssp_pop_agg = ssp_pop_agg.interpolate(method='linear', axis=1, limit_area='inside', limit_direction='both', columns=missing_years)
    #TODO classer les colonnes
    ssp_pop_agg = ssp_pop_agg.sort_index(axis=1, level=None, ascending=True, inplace=False, kind='quicksort', na_position='last', sort_remaining=True, ignore_index=False)
    ssp_pop_agg = ssp_pop_agg.interpolate(method='linear', axis=1, limit_area=None, limit_direction='both', columns=missing_years)

    with open('./results/total_population_trajectory__ssp_2023__'+ssp_sc+'.csv','w') as file:
        file.write('//Total population (by geographic region)\n//SSP update - '+model+'\n//Modified with a linear extrapolation from historical UNO values\n//thousands of people\n')
        ssp_pop_agg.reindex(order_regions).to_csv(file, sep='|',header=True,index=True)

    with open('./results/total_active_population_trajectory__ssp_2023__'+ssp_sc+'__range'+active_pop_range+'.csv','w') as file:
        file.write('//Total Active population (i.e. '+str(min_wa)+'-'+str(max_wa)+') (by geographic region)\n//SSP update - '+model+'\n//Modified with a linear extrapolation from historical values\n//thousands of people\n')
        active_pop_agg.reindex(order_regions).to_csv(file, sep='|',header=True,index=True)

    with open('./results/active_population_growth_rate__ssp_2023__'+ssp_sc+'__range'+active_pop_range+'.csv','w') as file:
        file.write('//Active population growth rate (i.e. '+str(min_wa)+'-'+str(max_wa)+') (by geographic region)\n//SSP update - '+model+'\n//Modified with a linear extrapolation from historical values\n//thousands of people\n//growth is between previous and current year\n')
        active_pop_agg_GrowthRate.reindex(order_regions).to_csv(file, sep='|',header=True,index=True)
