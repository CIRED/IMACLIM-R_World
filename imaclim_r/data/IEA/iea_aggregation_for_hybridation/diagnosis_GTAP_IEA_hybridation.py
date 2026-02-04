# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Nicolas Graves
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

# This file is designed to support the diagnosis of GTAP treatment of IEA data. 
# Results and corresponding paragraphs are compiled in the file of the same name on the Google Drive folder ImaclimV2. 
# A large part of the file is just a copy of the file comparaison_GTAP_AIE_Enerdata.py, which targets were broader originally. 


#Importing IEA data. 
#libraries
import pandas as pd
import numpy as np
import csv
import sys
import os
import copy
import common_cired
import aggregation_GTAP
import collections
from IPython.display import display

#global variables 
#list_years=['2007','2011','2014']
list_years = ['2014']
target_year = '2007'
energies_list = ['coa', 'oil', 'gas', 'p_c', 'ely', 'gdt']

ieaPath = '/data/shared/iea-energyBalancesAndPrices/'
codePath = './code/'
correspondencesPath = '/data/public_data/products_aggregations/iea_hybridization/'

#functions
#Defines functions :
#read_aggregation_rules
#aggregate_products
#aggregate_flows
exec(open(codePath+"hybridation_functions.py").read())

def set_pandas_display_options() -> None:
    """Set pandas display options."""
    # Ref: https://stackoverflow.com/a/52432757/
    display = pd.options.display
    display.max_columns = 1000
    display.max_rows = 1000
    display.max_colwidth = 199
    display.width = None
    display.precision = 3  # set as needed
    display.float_format = '{:,.3f}'.format

set_pandas_display_options()


#loading data
print('Loading data')
exec(open(ieaPath+"import_IEA_energy_balances_to_DataFrame.py").read())

#Agregating data for GTAP
web_GTAP = pd.DataFrame()
for region in set_regions:
    GTAP_temp = web.xs(region,level='Region').copy()
    GTAP_temp = aggregate_flows(correspondencesPath+'iea_EEB2GTAP_EDS__flows.csv', GTAP_temp)
    #
    #Special treatment : Oil and gas extraction
    flow_oilgas = web.xs(region,level='Region').xs('Oil and gas extraction (energy)',level='Flow')
    #
    flow_oil = (flow_oilgas['Crude oil']/(flow_oilgas['Crude oil']+flow_oilgas['Natural gas'])).to_numpy().reshape((len(list_years),1))*flow_oilgas
    flow_oil['Crude oil'] = flow_oilgas['Crude oil']
    flow_oil['Natural gas'] = np.zeros(len(list_years))
    flow_oil['Flow'] = len(list_years)*['oil']
    flow_oil.set_index('Flow',append=True,inplace=True)
    flow_oil = flow_oil.swaplevel()
    GTAP_temp = GTAP_temp.append(flow_oil)
    #
    flow_gas = (flow_oilgas['Natural gas']/(flow_oilgas['Crude oil']+flow_oilgas['Natural gas'])).to_numpy().reshape((len(list_years),1))*flow_oilgas
    flow_gas['Crude oil'] = np.zeros(len(list_years))
    flow_gas['Natural gas'] = flow_oilgas['Natural gas']
    flow_gas['Flow'] = len(list_years)*['gas']
    flow_gas.set_index('Flow',append=True,inplace=True)
    flow_gas = flow_gas.swaplevel()
    GTAP_temp = GTAP_temp.append(flow_gas)
    #
    GTAP_temp = aggregate_products(correspondencesPath+'./iea_EEB2GTAP_EDS__products.csv', GTAP_temp, pd.DataFrame(columns=energies_list[:-1]).columns)
    #
    GTAP_temp['Region']=region
    GTAP_temp.set_index('Region',append=True, inplace=True)
    GTAP_temp = GTAP_temp.swaplevel(0,2)
    #
    web_GTAP = web_GTAP.append(GTAP_temp)

print('Data loaded, beginning diagnosis')
print()

print('ZZ')
print('not implemented yet')


print('A')
flow_oilgas = web.xs('Oil and gas extraction (energy)', level='Flow').loc[(['WLD','QAT','SAU','FRA'],slice(None)),:]
print('Share of inflows for oil & gas extraction other than Crude oil or Natural gas')
print(display((flow_oilgas['Total']-flow_oilgas['Crude oil']-flow_oilgas['Natural gas'])/flow_oilgas['Total']))
print('\n')


print('Share of contributing inflows for oil & gas extraction in 2014')
all_inflows = (flow_oilgas/np.reshape(np.repeat(flow_oilgas['Total'].to_numpy(),68),(len(list_years)*4,68))).xs('2014',level='Year').transpose()
print(display(all_inflows.loc[(all_inflows.abs()>0.003).any(1)]))
print('\n')


print('H')
print('Share of flows between (petroleum and coal products) and (other products) over total transfers')
print(display(2*web.xs('Transfers',level='Flow')[['Coke oven coke','Gas coke','Coke oven gas','Refinery feedstocks','Refinery gas','Ethane','Liquefied petroleum gases (LPG)','Motor gasoline excl. biofuels','Aviation gasoline','Gasoline type jet fuel','Kerosene type jet fuel excl. biofuels','Other kerosene','Gas/diesel oil excl. biofuels','Fuel oil','Naphtha','White spirit & SBP','Lubricants','Bitumen','Paraffin waxes','Petroleum coke','Other oil products']].sum(axis=1) /(web.xs('Transfers',level='Flow').abs().sum(axis=1))))
print('\n')

print('K')
print('Share of Patent fuels flows over aggregated coal flows')
print(display(((aggregate_products(correspondencesPath+'./iea_EEB2GTAP_EDS__products.csv',(web.xs('Patent fuel plants (transf.)',level='Flow')+web.xs('Patent fuel plants (energy)',level='Flow')), pd.DataFrame(columns=energies_list[:-1]).columns))/web_GTAP.xs('coa',level='Flow')).loc[(['WLD','CHN','USA'],slice(None)),['coa','p_c']]))
print('\n')

print('F')
print('Share of non-energy use on available energy supply for all products, for the world in 2014')
print(display((web.loc[('WLD','2014','Non-energy use'),:]/(web.loc[('WLD','2014',['Total final consumption']),:].to_numpy()-web.loc[('WLD','2014',['Energy industry own use']),:].to_numpy()-((web.loc[('WLD','2014',web.xs('WLD',level='Region').xs('2014',level='Year').index[11:32]),:]<0)*web.loc[('WLD','2014',web.xs('WLD',level='Region').xs('2014',level='Year').index[11:32]),:]).sum().to_numpy())[0])))
print('\n')

print('M')
print('Share of flow "Petrochemical plants (transf.)" among aggregated flow "Petroleum and coal processing"')
print(display((aggregate_products(correspondencesPath+'./iea_EEB2GTAP_EDS__products.csv',web.xs('Petrochemical plants (transf.)',level='Flow').copy(), pd.DataFrame(columns=energies_list[:-1]).columns)/web_GTAP.xs('p_c',level='Flow')).loc[('WLD',slice(None)),:]))
print('\n')

print('Share of flow "Petrochemical plants (transf.)" among aggregated flow "Chemical, rubber, plastic products"')
print(display((aggregate_products(correspondencesPath+'./iea_EEB2GTAP_EDS__products.csv',web.xs('Petrochemical plants (transf.)',level='Flow').copy(), pd.DataFrame(columns=energies_list[:-1]).columns)/web_GTAP.xs('crp',level='Flow')).loc[('WLD',slice(None)),:]))
print('\n')

print('Share of "Refinery feedstocks" among Petroleum and coal products, World, 2014')
print(display((web.sort_index().loc[(slice(None),slice(None),['Total primary energy supply','Transformation processes','Energy industry own use','Total final consumption']),'Blast furnace gas']/ aggregate_products(correspondencesPath+'./iea_EEB2GTAP_EDS__products.csv', web.copy(), pd.DataFrame(columns=energies_list[:-1]).columns).sort_index().loc[(slice(None),slice(None),['Total primary energy supply','Transformation processes','Energy industry own use','Total final consumption']),'p_c']).xs('WLD',level='Region').xs('2014',level='Year')))
print('\n')

print('O1')
print('Share of flow "Nuclear industry (energy)" on aggregated flow Electricity')
print(display((aggregate_products(correspondencesPath+'./iea_EEB2GTAP_EDS__products.csv',web.xs('Nuclear industry  (energy)',level='Flow').copy(), pd.DataFrame(columns=energies_list[:-1]).columns)/web_GTAP.xs('ely',level='Flow')).loc[(['WLD','USA','FRA'],slice(None)),:]))
print('\n')

print('P')
print('Share of flow "Residential" among "Total final consumption" flow, world')
print(display((aggregate_products(correspondencesPath+'./iea_EEB2GTAP_EDS__products.csv',web.xs('Residential',level='Flow').copy(), pd.DataFrame(columns=energies_list[:-1]).columns)/web_GTAP.xs('Total final consumption',level='Flow')).loc[('WLD',slice(None)),:]))
print('\n')

print('Q')
print('Share of flow "Non-specified (other)" among "Total final consumption" flow, world')
print(display((aggregate_products(correspondencesPath+'./iea_EEB2GTAP_EDS__products.csv',web.xs('Non-specified (other)',level='Flow').copy(), pd.DataFrame(columns=energies_list[:-1]).columns)/web_GTAP.xs('Total final consumption',level='Flow')).loc[('WLD',slice(None)),:]))
print('\n')

