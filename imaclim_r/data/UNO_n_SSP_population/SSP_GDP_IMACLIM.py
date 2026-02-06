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
import pyam
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

#last_historical_year = 2021
#nb_year_interpolation = 5
#dataPath='/data/public_data/SSP_update_NAVIGATE/extracted/'
if len(sys.argv)>1:
    last_historical_year = int(sys.argv[2])-1
    dataPath = sys.argv[1] 
    iso_rules_path = sys.argv[3]
    growth_model = sys.argv[4]
    ssp_sc = sys.argv[5]
else: # defautl parameters for debugging
    last_historical_year = 2021
    dataPath='/data/public_data/IIASA_scenario_explorer_public/download/'
    iso_rules_path = '../ISO_rules/ISO_GTAP_IMACLIM_rules.csv'
    growth_model = "IIASA GDP 2023"
    ssp_sc = "SSP2"

##########################################
## Load data and dictionnaries
##########################################

#Import order_regions 
order_regions = pd.Index(genfromtxt('../order_regions.csv',dtype='str'))

#Model IIASA GDP 2023
#Scenario SSP2

ssp_gdp = pd.read_csv(dataPath + 'ssp__all.csv', delimiter=',', encoding="utf-8")
var_list = [var for var in list(set(ssp_gdp.Variable)) if var=='GDP|PPP'] 
ssp_gdp = ssp_gdp[ ssp_gdp['Variable'].isin(var_list)]
ssp_gdp = ssp_gdp[ ssp_gdp['Model']==growth_model]
ssp_gdp = ssp_gdp[ ssp_gdp['Scenario']==ssp_sc]

ssp_gdp_world = ssp_gdp[ (ssp_gdp['Region']=='World') & (ssp_gdp['Variable']=='GDP|PPP')]

# convert to thousands of people
numeric_cols = ssp_gdp.select_dtypes(include='number').columns 
ssp_gdp[numeric_cols] = ssp_gdp[numeric_cols] * 1e3
ssp_gdp['Units'] = 'thousand'

Imaclim2ISO3_path = '/data/public_data/regional_aggregations/imaclim/'
ISO2Imaclim = pd.read_csv(Imaclim2ISO3_path + './imaclim_ISO3_aggregates.csv', sep='|')
ISO2Imaclim_dict = ISO2Imaclim.set_index('ISO3')['Im_region'].to_dict()

# load ISO dict
iso_rules = pd.read_csv(iso_rules_path,sep='|')
new_iso = pd.DataFrame([["World","WLD","World","World"]],columns=['Country name','Alpha-3 code','Official state name','IMACLIM'])
iso_rules = pd.concat( [iso_rules, new_iso])

##########################################
## Check data and dictionnaries
##########################################

# check for missing country name and merge ISO/Imaclim disctionnary
missing_reg = [elt for elt in list(set(ssp_gdp['Region'])) if not elt in iso_rules['Country name'].values and not elt=='World' and not '(R' in elt ] 
print( [elt for elt in list(set(ssp_gdp['Region'])) if not elt in iso_rules['Country name'] ])

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

# rename region in ssp_gdp
ssp_gdp['Region'] = ssp_gdp['Region'].map(dict_missing_reg).fillna(ssp_gdp['Region'])

# check all is complete :
#missing_reg = [elt for elt in list(set(ssp_gdp['Region'])) if not elt in iso_rules['Country name'].values and not elt=='World' and not '(R' in elt ]
missing_reg = [elt for elt in list(set(ssp_gdp['Region'])) if not elt in iso_rules['Country name'].values and not '(R' in elt ]
print(missing_reg)

ssp_gdp = ssp_gdp.rename( {'Region':'Country name'}, axis=1)
ssp_gdp = pd.merge( ssp_gdp, iso_rules[ ['Country name','Alpha-3 code','IMACLIM']], on='Country name')

list_country = list(set(ssp_gdp['Alpha-3 code']))
print( [elt for elt in list_country if not elt in ISO2Imaclim_dict.keys()])
#['CUW', 'SXM', 'SSD']

# manually complete dictionnaries
ISO2Imaclim_dict['SSD'] = 'AFR'
ISO2Imaclim_dict['CUW'] = 'RAL'
#ISO2Imaclim_dict['SXM'] = 'EUR'
ISO2Imaclim_dict['WLD'] = 'World'
ssp_gdp['Imaclim_region'] = ssp_gdp['Alpha-3 code'].map(ISO2Imaclim_dict)

##########################################
## Compute and aggregate datas
##########################################


# Add a column base on age group and sex
#ssp_gdp[['Variable', 'Sex', 'AgeGrp']] = ssp_gdp['Variable'].str.split('|', expand=True)

# Select only the numerical columns
numerical_columns = ssp_gdp.select_dtypes(include='number').columns
# Group by 'Sex' and sum the numerical columns
#ssp_gdp = ssp_gdp.groupby([col for col in ssp_gdp.columns if col not in numerical_columns and not col =="Imaclim_rgion"])[numerical_columns].sum().reset_index()
#a = ssp_gdp.groupby([col for col in ssp_gdp.columns if col not in numerical_columns and not col =="IMACLIM"])[numerical_columns].sum().reset_index()

ssp_gdp = ssp_gdp.groupby('Imaclim_region').sum()[ numerical_columns].reset_index()

ssp_gdp['scenario'] = ssp_sc
ssp_gdp['model'] = 'IMACLIM 2.0'
ssp_gdp['unit'] = 'billion USD_2017/yr'
ssp_gdp['variable'] = 'GDP|PPP'
ssp_gdp = ssp_gdp.rename( {'Imaclim_region':'region'}, axis=1)
ssp_gdp = pyam.IamDataFrame(ssp_gdp)

ssp_gdp = ssp_gdp.filter( year = [i for i in ssp_gdp.year if i >=2015])

os.makedirs('./results/', exist_ok=True)

ssp_gdp.timeseries().reset_index().set_index('region').reindex(['World'] + [e for e in order_regions]).to_csv("./results/GDP_ssp_IMACLIM_region_"+growth_model.replace(" ","_")+"_"+ssp_sc+".csv")


