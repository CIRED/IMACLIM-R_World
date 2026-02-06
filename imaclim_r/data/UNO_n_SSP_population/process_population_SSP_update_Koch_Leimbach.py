#! /usr/bin/env python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Nicolas Graves
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
else: # defautl parameters for debugging
    last_historical_year = 2021
    nb_year_interpolation = 5
    dataPath='/data/public_data/SSP_update_NAVIGATE/extracted/'

##########################################
## Load data and dictionnaries
##########################################

ssp_pop = pd.read_csv(dataPath + 'scenarios_for_navigate_63-country_level-normalized.csv', delimiter='|', encoding="utf-8")
ssp_pop = ssp_pop[ ssp_pop['variable']=='pop']

# convert to thousands of people
numeric_cols = ssp_pop.select_dtypes(include='number').columns 
ssp_pop[numeric_cols] = ssp_pop[numeric_cols] * 1e3 

Imaclim2ISO3_path = '/data/public_data/regional_aggregations/imaclim/'
ISO2Imaclim = pd.read_csv(Imaclim2ISO3_path + './imaclim_ISO3_aggregates.csv', sep='|')
ISO2Imaclim_dict = ISO2Imaclim.set_index('ISO3')['Im_region'].to_dict()

# Loading UN historcal data
UN_historical = pd.read_csv('results/total_population_trajectory_UNO_historical.csv', delimiter='|', encoding="utf-8", index_col='Imaclim_region')

##########################################
## Check data and dictionnaries
##########################################

#scenario WDI: 1998-2020
#scenario SSP1, SSP2, SSPx: 2021-2100
list_country = list(set(ssp_pop['countryCode']))
print( [elt for elt in list_country if not elt in ISO2Imaclim_dict.keys()])
#['CUW', 'SXM', 'SSD']

# manually complete dictionnaries
ISO2Imaclim_dict['SSD'] = 'AFR'
ISO2Imaclim_dict['CUW'] = 'RAL'
ISO2Imaclim_dict['SXM'] = 'EUR'

##########################################
## Compute and aggregate datas
##########################################

os.makedirs('./results/', exist_ok=True)

#Aggregating total population data
ssp_pop['Imaclim_region'] = ssp_pop['countryCode'].map(ISO2Imaclim_dict)

for ssp_sc in ['SSP'+str(i+1) for i in range(5)]:
    ssp_pop_agg = ssp_pop[ssp_pop['scenario']==ssp_sc][['Imaclim_region','variable'] + [str(i) for i in range(last_historical_year,2101) if str(i) in ssp_pop.columns]].groupby(['Imaclim_region']).sum()
    ssp_pop_agg = ssp_pop_agg.drop(columns=[str(i) for i in range(last_historical_year,last_historical_year+nb_year_interpolation)]) 

    # merge historical UN data
    ssp_pop_agg = ssp_pop_agg.merge(UN_historical,on='Imaclim_region')

    # Generate a list of years to interpolate
    missing_years = [i for i in range(last_historical_year,2101) if not str(i) in ssp_pop_agg.columns]

    # Interpolate the missing years using linear interpolation
    ssp_pop_agg = ssp_pop_agg.drop('variable', axis=1)
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

    with open('./results/total_population_trajectory_'+ssp_sc+'.csv','w') as file:
        file.write('//Total population (by geographic region)\n//SSP update of Koch and Leimbach et al 2023\n//Modified with a linear extrapolation from historical UNO values\n//thousands of people\n')
        ssp_pop_agg.reindex(order_regions).to_csv(file, sep='|',header=True,index=True)

