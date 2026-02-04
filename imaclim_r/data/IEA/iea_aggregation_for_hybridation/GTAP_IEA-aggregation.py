#! /usr/bin/env python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Nicolas Graves, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


# This file is designed to support the diagnosis of GTAP treatment of IEA data.
# Results and corresponding paragraphs are compiled in the file of the same name on the Google Drive folder ImaclimV2.
# A large part of the file is just a copy of the file comparaison_GTAP_AIE_Enerdata.py, which targets were broader originally.

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
from IPython.display import display
import argparse


###################
###Boolean for test
###################
# Those should be true for the standart procedure
do_remove_auto_consumption = True
do_rebalance_import_export = True
all_CHP_in_electricity = True

# Other
correct_re_exportations = False
correct_stock_changes = False


#########
# parse argument
#########

# default argument - usefull for debugging in interractive mode
output_file_default="results/"
year_default=2011
input_file_default="/data/shared/IEA/IEA_2022_Balances_Prices/results/EnergyBalancesDatabases/wbig_old_iea_code/"+str(year_default)+"/"

parser = argparse.ArgumentParser('Aggregate IEA energy balances')

parser.add_argument('--input-file',  nargs='?', const=input_file_default, type=str, default=input_file_default)
parser.add_argument('--output-file', nargs='?', const=output_file_default, type=str, default=output_file_default)
parser.add_argument('--year', nargs='?', const=year_default, type=int, default=year_default )

args = parser.parse_args()

input_file = args.input_file
output_file = args.output_file
year = str(args.year)


###################
###global variables
###################

#list_years=['2007','2011','2014']

# share of energy assumed to correspond to private consumption (hosueholds)
transport_share_private = 0.75
transport_share_private = 0.5
# assumption share to rebalance imports and exports - this only be 1/2 with the formula below
alpha_imports = 1/2

# data locations
ieaPath = '/data/shared/iea-energyBalancesAndPrices/'
WBPath = '/data/public_data/World_Bank_Data_Catalog/'
GTAPpath = '/data/shared/GTAP/'

savePath = output_file
os.system("mkdir -p "+savePath)

# codes and lists locations
codePath = './code/'

iso3_codes_path = '/data/public_data/country-codes/data/country-codes.csv'
Imaclim2GTAP10_path = '../../GTAP/aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv'
correspondencesPath = '/data/public_data/products_aggregations/iea_aggregation/'
Imaclim2ISO3_path = '/data/public_data/regional_aggregations/imaclim/'

########################
###hybridation_functions
########################

#Defines functions :
#read_aggregation_rules
#aggregate_products
#aggregate_flows
#defines set_pandas_display_options
exec(open(codePath+"aggregation_functions.py").read())

set_pandas_display_options()

#######################################
###setting the saved flows and products
###also loading part of aggregation rules
#######################################
# for flows, all saved flows must be added in the corresponding .csv
iea_EEB2GTAP_EDS_consumption_flows_aggregation_rules = read_aggregation_rules(correspondencesPath+'web_aggregation__general_rules_for_imaclim.d/iea_EEB2GTAP_EDS__consumption_flows.csv')
flows_to_save_EDS = list( iea_EEB2GTAP_EDS_consumption_flows_aggregation_rules.keys())

GTAP_EDS2Imaclim_flows_aggregation_rules = read_aggregation_rules(correspondencesPath+'web_aggregation__general_rules_for_imaclim.d/GTAP_EDS2Imaclim__flows.csv')
flows_to_save_Imaclim = list(GTAP_EDS2Imaclim_flows_aggregation_rules.keys())

flows_to_save_outside_hybridation = ["Non-energy use",
                                     "Non-energy use industry/transformation/energy",
                                     "Non-energy use in transport", "Non-energy use in other",
                                     "Gasification plants for biogases (energy)", "Blast furnaces (transf.)",
                                     "Blast furnaces (energy)",
                                     'Aviation services - exports within region',
                                     'Aviation services - exports between regions',
                                     'Navigation services - exports within region',
                                     'Navigation services - exports between regions',

]

products_aggregation_rules = read_aggregation_rules(correspondencesPath+'./web_aggregation__general_rules_for_imaclim.d/iea_EEB2Imaclim__products.csv')
products_to_save = list(products_aggregation_rules.keys())

energy_own_use_flows_aggregation_rules = read_aggregation_rules(correspondencesPath+'./web_aggregation__general_rules_for_imaclim.d/iea_EEB2GTAP_EDS__energy_own_use_flows.csv')

#Precise justification about these products outside hybridation can be found
#commented in the file read for products_to_save.
products_to_save_outside_hybridation = ["Gas coke","Coal tar","Coke oven gas","Blast furnace gas","Other recovered gases","Elec/heat output from non-specified manufactured gases","Petroleum coke","Refinery gas","Industrial waste","Municipal waste (renewable)","Municipal waste (non-renewable)","Primary solid biofuels","Charcoal","Nuclear","Hydro","Solar photovoltaics","Tide, wave and ocean","Wind","Other sources","Geothermal","Solar thermal","Ethane","Naphtha","White spirit & SBP","Lubricants","Bitumen","Paraffin waxes"]



# checking rules
final_flows_aggregated = list()
print("CHECKINK RULES")
for key_gtap in GTAP_EDS2Imaclim_flows_aggregation_rules.keys():
    for elt_gtap in GTAP_EDS2Imaclim_flows_aggregation_rules[key_gtap]:
        if elt_gtap not in iea_EEB2GTAP_EDS_consumption_flows_aggregation_rules.keys():
            print("missing gtap " + elt_gtap)
        else:
            for elt_cons in iea_EEB2GTAP_EDS_consumption_flows_aggregation_rules[elt_gtap]:
                if elt_cons not in energy_own_use_flows_aggregation_rules.keys():
                    print("missing cons " + elt_cons)
                else:
                    for elt in energy_own_use_flows_aggregation_rules[ elt_cons]:
                        final_flows_aggregated.append( elt)
#print(len(final_flows_aggregated))
#for elt in final_flows_aggregated:
#    print(elt)

###############
###loading data
###############

print('Loading IEA data')
# The following script imports all IEA energy balances for "+str(year)+" into a pandas
# DataFrame named web. It also defines the variable iea_dataPath.
exec(open(ieaPath+"import_IEA_energy_balances_to_DataFrame.py").read())
print('Data IEA loaded')

print('Loading WB GDP data')
# The following script imports all available GDP data in current US$ for "+str(year)+".
# The data variable to be used is GDP_WB.
# exec(open(WBPath+'import_WB_GDP_to_DataFrame.py').read())
os.system("mkdir -p ./tmpdir")
os.system(WBPath+"extract_variable.sh "+WBPath+"regularized/WDI_Data.csv 'GDP (current US$)' | grep '|"+str(year)+"|' | awk --field-separator='|' '{ print $2 "+'"|"'+" $6}' > ./tmpdir/WB_GDP_current_USD_"+str(year)+".csv")
GDP_WB = pd.read_csv("./tmpdir/WB_GDP_current_USD_"+str(year)+".csv",delimiter='|',header=None).set_index(0)
os.system("rm -r ./tmpdir")
print('WB GDP data loaded')

# Code snippet to load IMF GDP data 
# Not used because there's a data quality issue and some incoherences 
# For instance Senegal had 1000* its normal GDP in downloaded data when calculated. 
# Using IMF data
#os.system("mkdir -p ../tmpdir")
##including header
#os.system("head -n1 "+IMF_dataPath+"IFS_2020.csv > ../tmpdir/IFS_NGDP_XDC.csv")
#os.system("head -n1 "+IMF_dataPath+"IFS_2020.csv > ../tmpdir/IFS_ENDA_XDC_USD_RATE.csv")
##extracting useful data
#os.system("grep '|NGDP_XDC|' "+IMF_dataPath+"IFS_2020.csv | grep '|"+str(year)+"|' >> ../tmpdir/IFS_NGDP_XDC.csv")
#os.system("grep '|ENDA_XDC_USD_RATE|' "+IMF_dataPath+"IFS_2020.csv | grep '|"+str(year)+"|' >> ../tmpdir/IFS_ENDA_XDC_USD_RATE.csv")
#
#nominal_GDP_domestic_currency = pd.read_csv('../tmpdir/IFS_NGDP_XDC.csv',delimiter='|')
#national_currency_to_US_dollars = pd.read_csv('../tmpdir/IFS_ENDA_XDC_USD_RATE.csv',delimiter='|')
#IMF_GDP = nominal_GDP_domestic_currency[['Country Code','Value']].merge(national_currency_to_US_dollars[['Country Code','Value']],left_on='Country Code', right_on='Country Code',how='inner',suffixes=('_NGDP','_ENDA'))
#IMF_GDP['Value_USD_GDP'] = IMF_GDP['Value_NGDP']/IMF_GDP['Value_ENDA']
#
#IMF_country_codes_path = '/data/public_data/IMF_web/documentation/results/'
#country_codes_IMF = pd.read_csv(IMF_country_codes_path+'country_codes_IMF_ISO3.csv',delimiter='|').set_index('IMF Code').to_dict()['ISO Code']
#
#IMF_GDP['ISO3'] = list(map(lambda x: country_codes_IMF[x],IMF_GDP['Country Code']))
#IMF_GDP.set_index('ISO3',inplace=True)

"""
print('Loading GTAP data')
# Importing GTAP data. Not optimal.
input_file = GTAPpath+'./results/extracted_GTAP10_'+str(year)+'/GTAP_tables.csv'
input_data, input_dimensions_values, input_data_dimensions_2014 = aggregation_GTAP.read_dimensions_tables_file(input_file)
# Not used anymore because we use WB data for GDP shares. 
# GDP_GTAP = input_data['AG01'].sum(axis=1)
# total_GDP_GTAP = sum(GDP_GTAP)
# GDP_GTAP_shares = GDP_GTAP/total_GDP_GTAP
print('GTAP data loaded')
"""
# importing GTAP 214 for the region list
input_file = GTAPpath+'./results/extracted_GTAP10_2014/GTAP_tables.csv'
input_data, input_dimensions_values, input_data_dimensions_2014 = aggregation_GTAP.read_dimensions_tables_file(input_file)

##############################################
###loading country codes and aggregation_rules
##############################################

# country codes for ISO3 matching
# if country has no official_name_en, take the variable name instead
country_codes_raw = pd.read_csv(iso3_codes_path)[['ISO3166-1-Alpha-3','name','official_name_en']]
country_codes = country_codes_raw[['ISO3166-1-Alpha-3','official_name_en']]
no_official_country_name = country_codes.loc[country_codes['official_name_en'].isna()]['ISO3166-1-Alpha-3'].to_list()
country_codes = pd.concat([country_codes,country_codes_raw[country_codes_raw['ISO3166-1-Alpha-3'].isin(no_official_country_name)][['ISO3166-1-Alpha-3','name']].rename(columns={'name': 'official_name_en'})])
country_codes.set_index("official_name_en", inplace=True)
country_codes = country_codes.to_dict()['ISO3166-1-Alpha-3']

# loading IEA filenames
_,_,filenames = next(os.walk(ieaPath+iea_dataPath), (None, None, []))
#There are also region sets, here we only extract world and iso3 countries
#only keeps regions with 3 digits i.e. iso3 alpha3 codes
list_countries_IEA = list(set(map(lambda x:x.split('_')[2].strip('.csv'),filenames)).intersection(set(country_codes.values())))
# list_countries_IEA = pd.read_csv('/data/shared/iea-energyBalancesAndPrices/IEA_2017/rawData/wbig/list_countries_ISO3.csv', header=None)

# loading dict to match imaclim and gtap
Imaclim2GTAP10 = collections.defaultdict(list)
with open(Imaclim2GTAP10_path,newline='') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        hd,*tl = list(filter(None,row[0].split('|')))
        for elt in tl:
            Imaclim2GTAP10[hd].append(elt)


# GTAP10_2_Imaclim = {GTAP10reg : k for k, v in Imaclim2GTAP10.items() for GTAP10reg in v}

GTAP_countries_list = input_dimensions_values['REG']


# loading dict to match gtap with iso3
ISO2GTAP = pd.read_csv(GTAPpath+'./ISO3166_GTAP.csv')[['ISO','REG_V10']]
ISO2GTAP['ISO3'] = ISO2GTAP['ISO'].apply(lambda x: x.upper())
ISO2GTAP_dict = ISO2GTAP.set_index('ISO3')['REG_V10'].to_dict()

# if the converstion from Imaclim to ISO does not exist, create it
# TODO : should be dependent of aggregation rules, add a suffix to the file
if not os.path.isfile( Imaclim2ISO3_path + './imaclim_ISO3_aggregates.csv'):
    # small snippet of code, have been used to define actual ImaclimR regional agregation
    ISO2GTAP['Im_region'] = list(map(lambda x : GTAP10_2_Imaclim[x] if x !='xtw' else np.nan, ISO2GTAP['REG_V10']))
    ISO2GTAP[['ISO3','Im_region']].to_csv('/data/public_data/regional_aggregations/imaclim/imaclim_ISO3_aggregates.csv', sep='|', index=None)
# loading dict to match imaclim with iso3 (originally generated by the previous snippet)
ISO2Imaclim = pd.read_csv(Imaclim2ISO3_path + './imaclim_ISO3_aggregates.csv', sep='|')
ISO2Imaclim_dict = ISO2Imaclim.set_index('ISO3')['Im_region'].to_dict()


#Import order_regions for last save
# TODO reindex sort indexes (and NA) we don't need that if the importation script is ok
order_regions = np.genfromtxt('../../order_regions.csv',dtype='str')

####################################################
### Energy Balances treatment : Algorithm definition
####################################################
# HERE
# 1 - Disaggregating IEA aggregated other countries
#       Since the IEA data tables are not present for all countries, the first
#       step is to disaggregate "other data balances".
#
# 2 - Applying products changes.
#
# 3 - Applying flows changes.
#   3.1 - Oil & gas extraction treatment.
#   3.2 - Distributing autoproducer flows according to electricity and heat consumption.
#   3.3 - Distributing all non-specified flows between flows of the same category.
#   3.4 - Distributing losses between flows from the "Energy industry own use" block.
#   3.5 - Transformation processes sign changes.
#   3.6 - Adjusting International marine and aviation bunkers to IOT format 
#        -> obsolete
#   3.7 - Transports treatment.
#        -> obsolete
#   3.8 - Exception: adding non-energy use of non-energy product from refinery
#            Done by adding it to the energy use flow (Chemical and Petrochemical)
#
# 4 - Aggregating flows towards an EDS format (see GTAP doc).
#   4.1 - Aggregating energy flows.
#   4.2 - Cancelling auto-consumption.
#   4.3 - Aggregating consumption flows.
#
# 5 - Aggregating products towards an EDS format and correcting imports/exports.
#
# 6 - Saving the matrix in EDS format.
#
# 5bis - Aggregating flows towards an Imaclim format.
#
# 6bis - Saving all annex products (not for Imaclim but for comparison.)
#
# 7bis - Aggregating products towards an Imaclim format and correcting
# imports/exports.
#
# 8bis - Aggregating regions and saving Imaclim matrix.

################################################
### 1- Disaggregating IEA aggregated other countries
################################################
# Disaggregating IEA aggregated "other" tables :
# - wbig_"+str(year)+"_OTHER_AFRICA.csv
# - wbig_"+str(year)+"_OTHER_NON_OECD_AMERICAS.csv
# - wbig_"+str(year)+"_OTHER_NON_OECD_ASIA.csv

# Importing countries disaggregation
# TODO: should be moved to /data
IEA_missing_countries_path = './disaggregation_IEA_OTHER_2014.csv'
IEA_missing_by_region = collections.defaultdict(list)
with open(IEA_missing_countries_path,newline='') as csvfile:
    reader = csv.reader(csvfile, delimiter='|')
    for row in reader:
        if row[0][0] != '#':
            hd,*tl = row
            for elt in tl:
                IEA_missing_by_region[hd].append(elt)

# removing assumed missing regions from the list if it is present in the 'web' database
for group_region in IEA_missing_by_region.keys():
    reg2remove=list()
    for reg in IEA_missing_by_region[group_region]:
        if country_codes[reg] in set_regions:        
            reg2remove.append(reg)
    for reg in reg2remove:
        IEA_missing_by_region[group_region].remove(reg)
#for group_region in IEA_missing_by_region.keys():
#    for reg in IEA_missing_by_region[group_region]:
#        if country_codes[reg] in set_regions:
#            IEA_missing_by_region[group_region].remove(reg)


IEA_missing_by_country = {country : region for region, countries in IEA_missing_by_region.items() for country in countries}

# Special case: oil and coal of Puerto Rico are in US statistics; 
# natural gas and electricity and heat are in Other non-OECD Americas
# we neglect natural gas and move eletricity and heat part towards US
# TODO using gtap data would be better, but those are really small numbers
iea_other_region_lower = "Other non-OECD Americas"
iea_other_region = iea_other_region_lower.upper().replace(" ", "_").replace("-", "_")
list_iso3_country = list(set(map(lambda x : country_codes[x], IEA_missing_by_region[ iea_other_region_lower])))
sum0 = web.sum(axis=0).values.sum()
GDP_WB_pri_share = GDP_WB.loc['PRI'].to_numpy()[0] / (GDP_WB.reindex( list_iso3_country).sum().to_numpy()[0] + GDP_WB.loc['PRI'].to_numpy()[0])
for flow in ["Main activity producer electricity plants (transf.)", "Autoproducer electricity plants (transf.)", "Main activity producer CHP plants (transf.)", "Autoproducer CHP plants (transf.)", "Autoproducer heat plants (transf.)", "Main activity producer heat plants (transf.)", "Own use in electricity, CHP and heat plants (energy)"]:
    web.loc[("USA",slice(None),slice(None)),:] += web.loc[(iea_other_region,slice(None),slice(None)),:].values * GDP_WB_pri_share
    web.loc[(iea_other_region,slice(None),slice(None)),:] *= (1-GDP_WB_pri_share)
print("Check sum after correction for Perto Rico: ", sum0- web.sum(axis=0).values.sum())

# dealing with special regions
for iea_other_region_lower in ["Other Africa", "Other non-OECD Asia", "Other non-OECD Americas", "Wld"]:
    iea_other_region = iea_other_region_lower.upper().replace(" ", "_").replace("-", "_")
    list_iso3_country = list(set(map(lambda x : country_codes[x], IEA_missing_by_region[ iea_other_region_lower])))
    web_ref = web.loc[(iea_other_region,slice(None),slice(None)),:].copy()
    web_ref_index = web_ref.index
    web_ref_cols = web_ref.columns
    web_ref_np = web_ref.fillna(0).to_numpy()
    if iea_other_region_lower == "Wld": # exception for the world, as we add those country, not represented in World Energy Balances
        GDP_WB_pool2share = GDP_WB.sum()
    else:
        GDP_WB_pool2share = GDP_WB.reindex( list_iso3_country).sum()
    for iso3_country in [reg for reg in list_iso3_country if reg in GDP_WB.index]:
        country_coeff = (GDP_WB.loc[iso3_country]/ GDP_WB_pool2share).to_numpy()[0]
        web = web.append(country_coeff*(pd.DataFrame(web_ref_np,index = web_ref_index,columns = web_ref_cols).rename(index={iea_other_region: iso3_country})))
    # check total sum
    # print(np.linalg.norm(web.loc[( iea_other_region,slice(None),slice(None)),:].fillna(0) - web.loc[( list_iso3_country,slice(None),slice(None)),:].sum(level='Flow')))
    # Clearing DataFrame
    if iea_other_region_lower != "Wld": 
        web.drop( iea_other_region,level='Region',inplace=True)

# Special case : Liechtenstein is missing, we add it with a specific treatment different from coutnry in "Wrl"
country_coeff = (GDP_WB.loc["LIE"]/GDP_WB.sum() ).to_numpy()[0]
web = web.append(country_coeff*(pd.DataFrame(web_ref_np,index = web_ref_index,columns = web_ref_cols).rename(index={iea_other_region: "LIE"})))
web.loc[("LIE", slice(None), slice(None)),products_aggregation_rules['oil']+products_aggregation_rules['p_c']] = 0
web.loc[("LIE", slice(None), ['Oil and gas extraction (energy)','Oil refineries (energy)','Oil refineries (transf.)','Petrochemical plants (transf.)']),:] = 0


# identifying missing regions, or subset from IEA to remove
list_reg=[]
for elt in web.index.tolist():
    if not elt[0] in list_reg:
        list_reg.append( elt[0])
for elt in list_reg:
    if elt not in ISO2Imaclim_dict.keys():
       print("Remove from web, or add to ISO2Imaclim this regional element " + elt)

ISO2Imaclim_dict['SSD'] = 'AFR'
ISO2Imaclim_dict['CUW'] = 'RAL'


##################################
### 2 - Applying products changes.
##################################
# Creating primary equivalent products for final energy products.
# In short, we count final products (but non by-products) at the value of their primary product origin's value, encompassing losses.
# This garantees that we cancel auto-consumption when the final products is aggregated in the same final category as the original product.
# We do not count by-products, because they are considered free. Emission coefficients will be properly adapted.

# To avoid double accountring, the 5 transformation processes (trans.) coresponding to those products (BKB, Patent fuel, gas work gas, coke oven coke, blast furnaces)
# are not acocunted for when aggregating flows 

number_flows = web.loc[('USA',str(year),slice(None))].index.size

##Treatment of coal products.
primary_coal = ['Hard coal (if no detail)','Brown coal (if no detail)', 'Anthracite','Coking coal','Other bituminous coal','Sub-bituminous coal','Lignite']

#Treatment of Peat products.
flow_temp = web.xs('BKB/peat briquette plants (transf.)',level='Flow')[['Peat', 'Peat products']]
web.loc[(slice(None),slice(None),'BKB/peat briquette plants (transf.)'), ['Peat', 'Peat products']] = 0 
#web.xs('BKB/peat briquette plants (transf.)',level='Flow')[['Peat', 'Peat products']] = 0 # set to zero converted transformation processes
conversion_coeff = flow_temp['Peat']/flow_temp['Peat products']
conversion_col = np.repeat(common_cired.my_nan_to_num(conversion_coeff.abs().to_numpy(), nan=0.0, posinf=0.0, neginf=0.0) ,number_flows)
web['Peat products (Peat eq.)'] = web['Peat products']*conversion_col
# 'Peat products (Peat eq.)' goes to 'Peat' for the first product aggregation

#Treatment of BKB.
# Niger, which in "+str(year)+" consumes Lignite
# but does not produce BKB briquettes. Niger doesn't show a usage of BKB briquettes at all

flow_temp = web.xs('BKB/peat briquette plants (transf.)',level='Flow')[primary_coal+['BKB']]
conversion_coeff = flow_temp[primary_coal].sum(axis='columns')/flow_temp['BKB']
conversion_col = np.repeat(common_cired.my_nan_to_num(conversion_coeff.abs().to_numpy(), nan=0.0, posinf=0.0, neginf=0.0) ,number_flows)
web['BKB (Lignite eq.)'] = web['BKB']*conversion_col


#Treatment of Patent fuel.
# Ukraine, which in "+str(year)+" consumes Other bituminous coal
# but does not produce Patent fuel. Ukraine doesn't show a usage of Patent fuel at all

flow_temp = web.xs('Patent fuel plants (transf.)',level='Flow')[primary_coal+['Patent fuel']]
conversion_coeff = flow_temp[primary_coal].sum(axis='columns')/flow_temp['Patent fuel']
conversion_col = np.repeat(common_cired.my_nan_to_num(conversion_coeff.abs().to_numpy(), nan=0.0, posinf=0.0, neginf=0.0) ,number_flows)
web['Patent fuel (Other bituminous coal eq.)'] = web['Patent fuel']*conversion_col
# 'Patent fuel (Other bituminous coal eq.)' goes to 'Other bituminous coal' for the first product aggregation



#Treatment of Gas works gas and its by-product Gas coke.
#We discard Gas coke, which is created in Gas works as a by-product of Gas works gas.
#Treatment of Coke oven coke, and its by-products coke oven gas and coal tar.
flow_temp = web.xs('Gas works (transf.)',level='Flow')[primary_coal+['Gas works gas']]
conversion_coeff = flow_temp[primary_coal].sum(axis='columns')/flow_temp['Gas works gas']
conversion_col = np.repeat(common_cired.my_nan_to_num(conversion_coeff.abs().to_numpy(), nan=0.0, posinf=0.0, neginf=0.0) ,number_flows)
web['Gas works gas (Other bituminous coal eq.)'] = web['Gas works gas']*conversion_col

#Treatment of Blast furnace gas
#Blast furnace comes from coke oven coke, so we first translate it into coke oven coke, 
#and then into Other bituminous coal eq.
flow_temp = web.xs('Blast furnaces (transf.)',level='Flow')[ ['Coke oven coke']+['Blast furnace gas']]
conversion_coeff = flow_temp['Coke oven coke']/flow_temp['Blast furnace gas']
conversion_col = np.repeat(common_cired.my_nan_to_num(conversion_coeff.abs().to_numpy(), nan=0.0, posinf=0.0, neginf=0.0) ,number_flows)
web['Blast furnaces (Coke oven coke eq.)'] = web['Blast furnace gas']*conversion_col

# Treatment of Coke ovens.
# We discard coke oven gas and coal tar, as they are by-products of the production of coke oven coke.
flow_temp = web.xs('Coke ovens (transf.)',level='Flow')[primary_coal+['Coke oven coke']]
conversion_coeff = flow_temp[primary_coal].sum(axis='columns')/flow_temp['Coke oven coke']

# Algeria, which in "+str(year)+" consumes Coking coal
# but does not produce Coke oven coke. aIt creates a np.inf in the process.
# Algeria shows a usage of Coke oven coke, all imported. We create the transformation process
# for Algeria with the world yield and substract imports accordingly.
web.loc[('DZA',slice(None),'Coke ovens (transf.)'),'Coke oven coke'] = web.loc[('DZA',slice(None),'Coke ovens (transf.)'),'Coking coal']/conversion_coeff['WLD'].to_numpy()[0]
web.loc[('DZA',slice(None),'Imports'),'Coke oven coke'] -= web.loc[('DZA',slice(None),'Coke ovens (transf.)'),'Coke oven coke']
conversion_coeff['DZA'] = conversion_coeff['WLD']
conversion_col = np.repeat(common_cired.my_nan_to_num(conversion_coeff.abs().to_numpy(), nan=0.0, posinf=0.0, neginf=0.0) ,number_flows)

web['Coke oven coke (Other bituminous coal eq.)'] = web['Coke oven coke']*conversion_col

web['Blast furnaces (Other bituminous coal eq.)'] = web['Blast furnaces (Coke oven coke eq.)']*conversion_col

#Treatment of Other recovered gases.
#We discard other recovered gases for the same reasons.

#############################
# 3 - Applying flows changes.
#############################
# After creating primary equivalent products for final energy products, we aggregate flows
# in a ~GTAP_EDS form, so that we can save a ~EDS matrix, before final aggregation for Imaclim.
# This is done through different steps (all steps might not be permutable because of drops):
#   3.1 - Oil & gas extraction treatment.
#   3.2 - Distributing autoproducer flows according to electricity and heat consumption.
#   3.3 - Distributing all non-specified flows between flows of the same category.
#   3.4 - Distributing losses between flows from the "Energy industry own use" block.
#   3.5 - Transformation processes sign changes.
#   3.6 - Adjusting International marine and aviation bunkers to IOT format
#   3.7 - Transports treatment.

## 3.0 - Creating list

#TODO: parse this list from file
transformation_flows_names =[
"Main activity producer electricity plants (transf.)",
"Main activity producer CHP plants (transf.)",
"Main activity producer heat plants (transf.)",
"Autoproducer electricity plants (transf.)",
"Autoproducer CHP plants (transf.)",
"Autoproducer heat plants (transf.)",
"Heat pumps (transf.)",
"Electric boilers (transf.)",
"Chemical heat for electricity production (transf.)",
"Blast furnaces (transf.)",
"Gas works (transf.)",
"Coke ovens (transf.)",
"Patent fuel plants (transf.)",
"BKB/peat briquette plants (transf.)",
"Oil refineries (transf.)",
"Petrochemical plants (transf.)",
"Coal liquefaction plants (transf.)",
"Gas-to-liquids (GTL) plants (transf.)",
"For blended natural gas (transf.)",
"Charcoal production plants (transf.)"]

# TODO redondant
energy_flows_names =[
"Coal mines (energy)",
"Oil and gas extraction (energy)",
"Blast furnaces (energy)",
"Gas works (energy)",
"Gasification plants for biogases (energy)",
"Coke ovens (energy)",
"Patent fuel plants (energy)",
"BKB/peat briquette plants (energy)",
"Oil refineries (energy)",
"Coal liquefaction plants (energy)",
"Liquefaction (LNG) / regasification plants  (energy)",
"Gas-to-liquids (GTL) plants  (energy)",
"Own use in electricity, CHP and heat plants (energy)",
"Pumped storage plants (energy)",
"Nuclear industry  (energy)",
"Charcoal production plants (energy)"]

# TODO redondant
industry_flows_names =[
"Iron and steel",
"Chemical and petrochemical",
"Non-ferrous metals",
"Non-metallic minerals",
"Transport equipment",
"Machinery",
"Mining and quarrying",
"Food and tobacco",
"Paper, pulp and print",
"Wood and wood products",
"Construction",
"Textile and leather"]

# This list, for one time, is easier to hardcode than parse from file
transport_flows_names =[
"World aviation bunkers",
"Domestic aviation",
"Road",
"Rail",
"Pipeline transport",
"World marine bunkers",
"Domestic navigation"]


##  3.1 - Oil & gas extraction treatment.

# We split "Oil and gas extraction" between oil and gas at pro rata of 'Crude oil' and 'Natural gas' (NG) flows, 
# except for Crude oil which goes to Crude oil, and NG which goes to NG only

flow_oilgas = web.xs('Oil and gas extraction (energy)',level='Flow').fillna(0)
prod = web.xs('Production',level='Flow').fillna(0)

denominator = (prod['Crude oil']+prod['Natural gas']).to_numpy().repeat((flow_oilgas.shape[-1])).reshape(flow_oilgas.shape)
numerator = (prod['Crude oil']).to_numpy().repeat((flow_oilgas.shape[-1])).reshape(flow_oilgas.shape)
share_oil = np.where( denominator==0, 0.5, numerator/denominator)

flow_oil = flow_oilgas * share_oil
flow_oil['Crude oil'] = flow_oilgas['Crude oil']
flow_oil['Natural gas'] = 0
flow_oil['Flow'] = 'oil extraction (energy)'
flow_oil.set_index('Flow',append=True,inplace=True)
web = web.append(flow_oil)

flow_gas = flow_oilgas * (1-share_oil)
flow_gas['Crude oil'] = 0
flow_gas['Natural gas'] = flow_oilgas['Natural gas']
flow_gas['Flow'] = 'gas extraction (energy)'
flow_gas.set_index('Flow',append=True,inplace=True)
web = web.append(flow_gas)

print("Check sum for Oil and Gas: ", flow_oilgas.fillna(0).values.sum() - web.xs('gas extraction (energy)',level='Flow').fillna(0).values.sum() - web.xs('oil extraction (energy)',level='Flow').fillna(0).values.sum() ) 

energy_flows_names.remove('Oil and gas extraction (energy)')
energy_flows_names.append('oil extraction (energy)')
energy_flows_names.append('gas extraction (energy)')

## 3.2 - Distributing autoproducer flows according to electricity and heat consumption.

#TODO parse one iea file, WLD, to get those list
energy_industries_list = ["Coal mines (energy)","oil extraction (energy)","gas extraction (energy)","Blast furnaces (energy)","Gas works (energy)","Gasification plants for biogases (energy)","Coke ovens (energy)","Patent fuel plants (energy)","BKB/peat briquette plants (energy)","Oil refineries (energy)","Coal liquefaction plants (energy)","Liquefaction (LNG) / regasification plants  (energy)","Gas-to-liquids (GTL) plants  (energy)"]

industries_list = ["Iron and steel", "Chemical and petrochemical","Non-ferrous metals","Non-metallic minerals","Transport equipment","Machinery","Mining and quarrying","Food and tobacco","Paper, pulp and print","Wood and wood products","Construction","Textile and leather"]

# 3.2.y Splitting "Own use in electricity, CHP and heat plants (energy)" in three: CHP, Heat and Electricity
#NOTE:  data on efficiency should be use for better accuracy. Not the split is only done base on Heat/Elc. output
list__chp_heat_elec__trans = ["CHP plants (transf.)", "electricity plants (transf.)", "heat plants (transf.)"]

web_own_use_chpheatelec = web.xs( "Own use in electricity, CHP and heat plants (energy)",level='Flow').fillna(0)
web_CHE_splitted = web.loc[(slice(None),slice(None), ["Main activity producer " + elt for elt in list__chp_heat_elec__trans]),:].copy()
web_CHE_splitted *= 0
for elt in list__chp_heat_elec__trans:
    web_CHE_splitted.rename(index = { "Main activity producer "+elt: "Own use - Main activity producer " + elt}, level = 'Flow', inplace = True)

ratio_main_den = 0
ratio_heat_den = 0
ratio_elec_den = 0
for elt in list__chp_heat_elec__trans:
    ratio_main_den += web.loc[(slice(None),slice(None),"Main activity producer "+elt),:]['Heat'].fillna(0).to_numpy() + web.loc[(slice(None),slice(None),"Main activity producer "+elt),:]['Electricity'].fillna(0).to_numpy()
    ratio_heat_den += web.loc[(slice(None),slice(None),"Main activity producer "+elt),:]['Heat'].fillna(0).to_numpy()
    ratio_elec_den += web.loc[(slice(None),slice(None),"Main activity producer "+elt),:]['Electricity'].fillna(0).to_numpy()

for elt in list__chp_heat_elec__trans:
    ratio_own_use = (web.loc[(slice(None),slice(None),"Main activity producer "+elt),:]['Heat'].fillna(0) + web.loc[(slice(None),slice(None),"Main activity producer "+elt),:]['Electricity'].fillna(0)) /  ratio_main_den
    ratio_own_use = ratio_own_use.fillna(0).to_numpy()
    ratio_own_use = np.where( ratio_main_den==0, 1/3, ratio_own_use)
    ratio_elec = (web.loc[(slice(None),slice(None),"Main activity producer "+elt),:]['Electricity'] / ratio_elec_den).fillna(0).to_numpy()
    ratio_heat = (web.loc[(slice(None),slice(None),"Main activity producer "+elt),:]['Heat'] / ratio_heat_den).fillna(0).to_numpy()
    ratio_elec = np.where( ratio_elec_den==0, 1/3, ratio_elec)
    ratio_heat = np.where( ratio_heat_den==0, 1/3, ratio_heat)
    for product in web.columns:
        if product not in ['Electricity', 'Heat']:
            web_CHE_splitted.loc[(slice(None),slice(None), "Own use - Main activity producer " + elt), product] = web_own_use_chpheatelec.loc[(slice(None),slice(None)), product].values * ratio_own_use
    web_CHE_splitted.loc[(slice(None),slice(None), "Own use - Main activity producer " + elt), 'Electricity'] = web_own_use_chpheatelec.loc[(slice(None),slice(None)), 'Electricity'].values * ratio_elec
    web_CHE_splitted.loc[(slice(None),slice(None), "Own use - Main activity producer " + elt), 'Heat'] = web_own_use_chpheatelec.loc[(slice(None),slice(None)), 'Heat'].values * ratio_heat

web = pd.concat( [web, web_CHE_splitted.fillna(0)])

sum1=0
for elt in list__chp_heat_elec__trans:
    sum1+= web.xs("Own use - Main activity producer " + elt,level='Flow').fillna(0).values.sum()
print("Check sum for Own use in electricity, CHP and heat plants (energy): ", web_own_use_chpheatelec.fillna(0).values.sum() - sum1)

energy_flows_names.remove("Own use in electricity, CHP and heat plants (energy)")
for elt in list__chp_heat_elec__trans:
    energy_flows_names.append( "Own use - Main activity producer " + elt)

# 3.2.z Splitting CHP flows between Heat and electricity, at pro_rata of CHP production
#NOTE:  data on efficiency should be use for better accuracy. Not the split is only done base on Heat/Elc. output

for prefix in ["Main activity producer ", "Autoproducer ", "Own use - Main activity producer "]:
    list_chpEH = [prefix+x for x in list__chp_heat_elec__trans]
    ind_chp, ind_elec, ind_heat = 0, 1, 2

    web_chp = web.xs( list_chpEH[ind_chp],level='Flow').fillna(0)

    web_chp_splitted = web.loc[(slice(None),slice(None), list_chpEH[ ind_elec:ind_heat+1]),:].copy()
    web_chp_splitted *= 0
    web_chp_splitted.rename(index = {
        list_chpEH[ ind_elec]: list_chpEH[ ind_chp]+" - electricity",
        list_chpEH[ ind_heat]: list_chpEH[ ind_chp]+" - heat"}, level = 'Flow', inplace = True)
    ratio_den = (web_chp["Electricity"] + web_chp["Heat"]).to_numpy()
    ratio_elec_heat_inCHP = web_chp["Electricity"].to_numpy() / ratio_den
    ratio_elec_heat_inCHP = np.where( ratio_den==0, 0.5, ratio_elec_heat_inCHP)

    if all_CHP_in_electricity:
        for col in web_chp_splitted:
            web_chp_splitted.loc[(slice(None),slice(None), list_chpEH[ ind_chp]+" - electricity"),col] = web_chp.loc[(slice(None),slice(None)), col].to_numpy()
            web_chp_splitted.loc[(slice(None),slice(None), list_chpEH[ ind_chp]+" - heat"),col] = 0
    else:
        for col in web_chp_splitted:
            if col not in ['Electricity', 'Heat']:
                web_chp_splitted.loc[(slice(None),slice(None), list_chpEH[ ind_chp]+" - electricity"),col] = ratio_elec_heat_inCHP * web_chp.loc[(slice(None),slice(None)), col].to_numpy()
                web_chp_splitted.loc[(slice(None),slice(None), list_chpEH[ ind_chp]+" - heat"),col] =  (1-ratio_elec_heat_inCHP) * web_chp.loc[(slice(None),slice(None)), col].to_numpy()
        web_chp_splitted.loc[(slice(None),slice(None), list_chpEH[ ind_chp]+" - electricity"), 'Electricity'] = web_chp.loc[(slice(None),slice(None)),'Electricity'].to_numpy()
        web_chp_splitted.loc[(slice(None),slice(None), list_chpEH[ ind_chp]+" - heat"), 'Heat'] = web_chp.loc[(slice(None),slice(None)),'Heat'].to_numpy()
        #web_chp_splitted.loc[(slice(None),slice(None), list_chpEH[ ind_chp]+" - electricity"), 'Heat'] = 0
        #web_chp_splitted.loc[(slice(None),slice(None), list_chpEH[ ind_chp]+" - heat"), 'Electricity'] = 0

    web = pd.concat( [web, web_chp_splitted.fillna(0)])

    print( "Check sum for " + list_chpEH[ind_chp] + ": ", web_chp.fillna(0).values.sum() - web.xs( list_chpEH[ind_chp]+" - electricity",level='Flow').fillna(0).values.sum() - web.xs( list_chpEH[ind_chp]+" - heat",level='Flow').fillna(0).values.sum())

transformation_flows_names.remove("Main activity producer CHP plants (transf.)")
transformation_flows_names.append("Main activity producer CHP plants (transf.) - electricity")
transformation_flows_names.append("Main activity producer CHP plants (transf.) - heat")

energy_flows_names.remove("Own use - Main activity producer CHP plants (transf.)")
energy_flows_names.append("Own use - Main activity producer CHP plants (transf.) - electricity")
energy_flows_names.append("Own use - Main activity producer CHP plants (transf.) - heat")


# 3.2.a Treating autoproducer electricity plants

flow_temp = web.loc[(slice(None),slice(None),"Autoproducer electricity plants (transf.)"),'Electricity']
countries_with_autoproducer = flow_temp.loc[flow_temp!=0].reset_index()['Region'].to_list()

flow_temp = -web.loc[(countries_with_autoproducer,slice(None),"Autoproducer electricity plants (transf.)"),:].fillna(0)

distribute_flows_industries = web.loc[(countries_with_autoproducer,slice(None),energy_industries_list+industries_list),'Electricity'].copy().fillna(0)

#For countries without energy industries nor industries identified, we put these in Non-specified flows
test = distribute_flows_industries.sum(level=['Region','Year'])
countries_non_specified = test.loc[test ==0].reset_index()['Region'].to_list()
countries_industries = test.loc[test !=0].reset_index()['Region'].to_list()

distribute_flows_industries.drop(countries_non_specified, level='Region', inplace=True)
distribute_flows_non_specified = web.loc[(countries_non_specified,slice(None),['Non-specified (energy)','Non-specified (industry)']),'Electricity'].copy().fillna(0)

shares_all_industries = (distribute_flows_industries.abs()/distribute_flows_industries.abs().sum(level=['Region','Year'])).sort_index(level='Region').copy()
shares_non_specified = (distribute_flows_non_specified.abs()/distribute_flows_non_specified.abs().sum(level=['Region','Year'])).sort_index(level='Region')

shares_all_industries = shares_all_industries.fillna(0)
shares_non_specified = shares_non_specified.fillna(0)

#For countries without any industries even non-specified but with still autoproducers.
test = shares_non_specified.sum(level=['Region','Year'])
countries_to_correct = test[test ==0].reset_index()['Region'].to_list()
for country in countries_to_correct:
    shares_non_specified[country] = [0,1] # puts a 100% share on 'Non-specified (industry)'

#Only  useful for second alternative in the next loop.
shares_all_industries = shares_all_industries.reset_index()

sum0=0
for region in countries_industries:
    for flow in energy_industries_list:
        web.loc[(region,slice(None),flow),:] -= shares_all_industries[(shares_all_industries['Region']==region)&(shares_all_industries['Flow']==flow)]['Electricity'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy()
        sum0 += shares_all_industries[(shares_all_industries['Region']==region)&(shares_all_industries['Flow']==flow)]['Electricity'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy().sum()
    for flow in industries_list:
        web.loc[(region,slice(None),flow),:] += shares_all_industries[(shares_all_industries['Region']==region)&(shares_all_industries['Flow']==flow)]['Electricity'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy()
        sum0 += shares_all_industries[(shares_all_industries['Region']==region)&(shares_all_industries['Flow']==flow)]['Electricity'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy().sum()

#Only useful for second alternative.
shares_non_specified = shares_non_specified.reset_index()

for region in countries_non_specified:
    web.loc[(region,slice(None),'Non-specified (energy)'),:] -=shares_non_specified[(shares_non_specified['Region']==region)&(shares_non_specified['Flow']=='Non-specified (energy)')]['Electricity'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy()
    sum0 += shares_non_specified[(shares_non_specified['Region']==region)&(shares_non_specified['Flow']=='Non-specified (energy)')]['Electricity'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy().sum()
    web.loc[(region,slice(None),'Non-specified (industry)'),:] +=shares_non_specified[(shares_non_specified['Region']==region)&(shares_non_specified['Flow']=='Non-specified (industry)')]['Electricity'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy()
    sum0 += shares_non_specified[(shares_non_specified['Region']==region)&(shares_non_specified['Flow']=='Non-specified (industry)')]['Electricity'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy().sum()

print( "Check sum for Autoproducer electricity plants (transf.): ", -web.xs("Autoproducer electricity plants (transf.)",level='Flow').fillna(0).values.sum() - sum0)

#web.drop('Autoproducer electricity plants (transf.)',level='Flow')

# 3.2.b Treating autoproducer CHP plants

# TODO split CHP in two
web['CHP'] = web['Electricity']+web['Heat']

flow_temp = web.loc[(slice(None),slice(None),"Autoproducer CHP plants (transf.)"),'CHP']
countries_with_autoproducer = flow_temp.loc[flow_temp!=0].reset_index()['Region'].to_list()

flow_temp = -web.loc[(countries_with_autoproducer,slice(None),"Autoproducer CHP plants (transf.)"),:].fillna(0)

distribute_flows_industries = web.loc[(countries_with_autoproducer,slice(None),energy_industries_list+industries_list),'CHP'].copy().fillna(0)

#For countries without energy industries nor industries identified, we put these in Non-specified flows
test = distribute_flows_industries.sum(level=['Region','Year'])
countries_non_specified = test.loc[test ==0].reset_index()['Region'].to_list()
countries_industries = test.loc[test !=0].reset_index()['Region'].to_list()

distribute_flows_industries.drop(countries_non_specified, level='Region', inplace=True)
distribute_flows_non_specified = web.loc[(countries_non_specified,slice(None),['Non-specified (energy)','Non-specified (industry)']),'CHP']

shares_all_industries = (distribute_flows_industries.abs()/distribute_flows_industries.abs().sum(level=['Region','Year'])).sort_index(level='Region').copy()
shares_non_specified = (distribute_flows_non_specified.abs()/distribute_flows_non_specified.abs().sum(level=['Region','Year'])).sort_index(level='Region')

shares_all_industries = shares_all_industries.fillna(0)
shares_non_specified = shares_non_specified.fillna(0)

#For countries without any industries even non-specified but with still autoproducers.
test = shares_non_specified.sum(level=['Region','Year'])
countries_to_correct = test[test ==0].reset_index()['Region'].to_list()
for country in countries_to_correct:
    shares_non_specified[country] = [0,1] # puts a 100% share on 'Non-specified (industry)'

#Only  useful for second alternative in the next loop.
shares_all_industries = shares_all_industries.reset_index()

sum0=0
for region in countries_industries:
    for flow in energy_industries_list:
        web.loc[(region,slice(None),flow),:] -= shares_all_industries[(shares_all_industries['Region']==region)&(shares_all_industries['Flow']==flow)]['CHP'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy()
        sum0 +=  shares_all_industries[(shares_all_industries['Region']==region)&(shares_all_industries['Flow']==flow)]['CHP'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy().sum()
    for flow in industries_list:
        web.loc[(region,slice(None),flow),:] += shares_all_industries[(shares_all_industries['Region']==region)&(shares_all_industries['Flow']==flow)]['CHP'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy()
        sum0 += shares_all_industries[(shares_all_industries['Region']==region)&(shares_all_industries['Flow']==flow)]['CHP'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy().sum()

#Only useful for second alternative.
shares_non_specified = shares_non_specified.reset_index()

for region in countries_non_specified:
    web.loc[(region,slice(None),'Non-specified (energy)'),:] -=shares_non_specified[(shares_non_specified['Region']==region)&(shares_non_specified['Flow']=='Non-specified (energy)')]['CHP'].to_numpy()[0]*flow_temp.loc[(region,),:].to_numpy()
    sum0 += shares_non_specified[(shares_non_specified['Region']==region)&(shares_non_specified['Flow']=='Non-specified (energy)')]['CHP'].to_numpy()[0]*flow_temp.loc[(region,),:].to_numpy().sum()
    web.loc[(region,slice(None),'Non-specified (industry)'),:] +=shares_non_specified[(shares_non_specified['Region']==region)&(shares_non_specified['Flow']=='Non-specified (industry)')]['CHP'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy()
    sum0 += shares_non_specified[(shares_non_specified['Region']==region)&(shares_non_specified['Flow']=='Non-specified (industry)')]['CHP'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy().sum()

print( "Check sum for Autoproducer CHP plants (transf.): ", -web.xs("Autoproducer CHP plants (transf.)",level='Flow').fillna(0).values.sum() - sum0)

# 3.2.c Treating autoproducer heat plants

flow_temp = web.loc[(slice(None),slice(None),"Autoproducer heat plants (transf.)"),'Heat']
countries_with_autoproducer = flow_temp.loc[flow_temp!=0].reset_index()['Region'].to_list()

flow_temp = -web.loc[(countries_with_autoproducer,slice(None),"Autoproducer heat plants (transf.)"),:].fillna(0)

distribute_flows_industries = web.loc[(countries_with_autoproducer,slice(None),energy_industries_list+industries_list),'Heat'].copy().fillna(0)

#For countries without energy industries nor industries identified, we put these in Non-specified flows
test = distribute_flows_industries.sum(level=['Region','Year'])
countries_non_specified = test.loc[test ==0].reset_index()['Region'].to_list()
countries_industries = test.loc[test !=0].reset_index()['Region'].to_list()

if not countries_non_specified==[]:
    distribute_flows_industries.drop(countries_non_specified, level='Region', inplace=True)
distribute_flows_non_specified = web.loc[(countries_non_specified,slice(None),['Non-specified (energy)','Non-specified (industry)']),'Heat']

shares_all_industries = (distribute_flows_industries.abs()/distribute_flows_industries.abs().sum(level=['Region','Year'])).sort_index(level='Region').copy()
shares_non_specified = (distribute_flows_non_specified.abs()/distribute_flows_non_specified.abs().sum(level=['Region','Year'])).sort_index(level='Region')

shares_all_industries = shares_all_industries.fillna(0)
shares_non_specified = shares_non_specified.fillna(0)

#For countries without any industries even non-specified but with still autoproducers.
test = shares_non_specified.sum(level=['Region','Year'])
countries_to_correct = test[test ==0].reset_index()['Region'].to_list()
for country in countries_to_correct:
    shares_non_specified[country] = [0,1] # puts a 100% share on 'Non-specified (industry)'

#Only  useful for second alternative in the next loop.
shares_all_industries = shares_all_industries.reset_index()

sum0=0
for region in countries_industries:
    for flow in energy_industries_list:
        # here we put a minus, because energy own use flows are negative and we compare them to positive consumption flows
        web.loc[(region,slice(None),flow),:] -= shares_all_industries[(shares_all_industries['Region']==region)&(shares_all_industries['Flow']==flow)]['Heat'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy()
        sum0 += shares_all_industries[(shares_all_industries['Region']==region)&(shares_all_industries['Flow']==flow)]['Heat'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy().sum()
    for flow in industries_list:
        web.loc[(region,slice(None),flow),:] += shares_all_industries[(shares_all_industries['Region']==region)&(shares_all_industries['Flow']==flow)]['Heat'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy()
        sum0 += shares_all_industries[(shares_all_industries['Region']==region)&(shares_all_industries['Flow']==flow)]['Heat'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy().sum()

#Only useful for second alternative.
shares_non_specified = shares_non_specified.reset_index()

for region in countries_non_specified:
    web.loc[(region,slice(None),'Non-specified (energy)'),:] -=shares_non_specified[(shares_non_specified['Region']==region)&(shares_non_specified['Flow']=='Non-specified (energy)')]['Heat'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy()
    sum0 += shares_non_specified[(shares_non_specified['Region']==region)&(shares_non_specified['Flow']=='Non-specified (energy)')]['Heat'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy().sum()
    web.loc[(region,slice(None),'Non-specified (industry)'),:] -=shares_non_specified[(shares_non_specified['Region']==region)&(shares_non_specified['Flow']=='Non-specified (industry)')]['Heat'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy()
    sum0 += shares_non_specified[(shares_non_specified['Region']==region)&(shares_non_specified['Flow']=='Non-specified (industry)')]['Heat'].to_numpy()[0]*flow_temp.loc[(region),:].to_numpy().sum()

print( "Check sum for Autoproducer heat plants (transf.): ", -web.xs("Autoproducer heat plants (transf.)",level='Flow').fillna(0).values.sum() - sum0)

# Dropping now unuseful autoproducer flows
# Should produce the same result if commented
web.drop("Autoproducer electricity plants (transf.)",level='Flow',inplace=True)
web.drop("Autoproducer CHP plants (transf.)",level='Flow',inplace=True)
web.drop("Autoproducer heat plants (transf.)",level='Flow',inplace=True)

transformation_flows_names.remove("Autoproducer CHP plants (transf.)")
transformation_flows_names.remove("Autoproducer electricity plants (transf.)")
transformation_flows_names.remove("Autoproducer heat plants (transf.)")


# 3.3 - Distributing all Non-specified flows between flows of the same category.


# Distributing "Non-specified (transformation)"

all_flows = list(set(web.reset_index()['Flow']))
all_regions = list(set(web.reset_index()['Region']))
nb_prod = len(web.columns)
energy_flows = set(map(lambda x: x if x[-8:]=='(energy)' else (), all_flows))
energy_flows.discard(())
energy_flows.add('Losses')
transformation_flows = set(map(lambda x: x if x[-9:]=='(transf.)' else (), all_flows))
transformation_flows.discard(())
transformation_flows.add('Non-specified (transformation)')

web.loc[(slice(None),slice(None),list(energy_flows)+['Losses']),:] = -web.loc[(slice(None),slice(None),list(energy_flows)+['Losses']),:]
web.loc[(slice(None),slice(None),transformation_flows),:] = -web.loc[(slice(None),slice(None),transformation_flows),:]
web_copy = web.copy()
web.loc[(slice(None),slice(None),transformation_flows),:] = web_copy.mask(web_copy<0,0).loc[(slice(None),slice(None),transformation_flows),:]

flow_temp = web.loc[(slice(None),slice(None),"Non-specified (transformation)"),:].copy().fillna(0)
distribute_flows = web.loc[(slice(None),slice(None),transformation_flows_names),:].copy().fillna(0)
shares_flows = distribute_flows/distribute_flows.sum(level='Region')

#for product in web.columns:
#    for region in all_regions :
#        if (all (shares_flows.loc[(region,slice(None),slice(None)),product].isna())):
#            shares_flows.loc[(region,slice(None),slice(None)),product] = shares_flows.loc[('WLD',slice(None),slice(None)),product].fillna(0)
#shares_flows = shares_flows.fillna(0)

shares_flows = shares_flows.fillna(0)
for product in web.columns:
    for region in all_regions :
        if shares_flows.loc[(region,slice(None),slice(None)),product].to_numpy().sum()==0:
            shares_flows.loc[(region,slice(None),slice(None)),product] = shares_flows.loc[('WLD',slice(None),slice(None)),product].fillna(0)

for product in web.columns:
    for region in all_regions :
        if shares_flows.sum(level='Region').loc[(region),product] == 0:
            shares_flows.loc[(region,slice(None), slice(None)), product] = 1 / len(transformation_flows_names) 

sum0=0

for region in all_regions:
    web.loc[(region,slice(None),transformation_flows_names),:] += (shares_flows.loc[(region,slice(None),slice(None)),:].fillna(0).to_numpy() * flow_temp.loc[(region,slice(None),slice(None)),:].fillna(0).to_numpy().repeat(len(transformation_flows_names)).reshape((nb_prod,len(transformation_flows_names))).transpose())
    sum0 += (shares_flows.loc[(region,slice(None),slice(None)),:].fillna(0).to_numpy() * flow_temp.loc[(region,slice(None),slice(None)),:].fillna(0).to_numpy().repeat(len(transformation_flows_names)).reshape((nb_prod,len(transformation_flows_names))).transpose()).sum()
    web.loc[(region,slice(None),transformation_flows_names),:] = web.loc[(region,slice(None),transformation_flows_names),:].fillna(0)

# Check
# Compare (shares_flows.loc[(region,slice(None),slice(None)),:].to_numpy() * flow_temp.loc[(region,slice(None),slice(None)),:].to_numpy().repeat(len(transformation_flows_names)).reshape((nb_prod,len(transformation_flows_names))).transpose()).sum(axis=0).shape
# and flow_temp.to_numpy()
#

print( "Check sum for Non-specified (transformation): ", web.xs("Non-specified (transformation)",level='Flow').fillna(0).values.sum() - sum0)

web.drop('Non-specified (transformation)', level='Flow', inplace=True)



# Distributing "Non-specified (energy)"

flow_temp = web.loc[(slice(None),slice(None),"Non-specified (energy)"),:].copy().fillna(0)
distribute_flows = web.loc[(slice(None),slice(None),energy_flows_names),:].copy().fillna(0)
shares_flows = distribute_flows/distribute_flows.sum(level='Region')

shares_flows = shares_flows.fillna(0)
for product in web.columns:
    for region in all_regions :
        if shares_flows.loc[(region,slice(None),slice(None)),product].to_numpy().sum()==0:
            shares_flows.loc[(region,slice(None),slice(None)),product] = shares_flows.loc[('WLD',slice(None),slice(None)),product].fillna(0)

for product in web.columns:
    for region in all_regions :
        if shares_flows.sum(level='Region').loc[(region),product] == 0:
            shares_flows.loc[(region,slice(None), slice(None)), product] = 1 / len(energy_flows_names)

sum0=0
for region in all_regions:
    web.loc[(region,slice(None),energy_flows_names),:] += (shares_flows.loc[(region,slice(None),slice(None)),:].to_numpy() * flow_temp.loc[(region),:].to_numpy().repeat(len(energy_flows_names)).reshape((nb_prod,len(energy_flows_names))).transpose())
    sum0 += (shares_flows.loc[(region,slice(None),slice(None)),:].to_numpy() * flow_temp.loc[(region),:].to_numpy().repeat(len(energy_flows_names)).reshape((nb_prod,len(energy_flows_names))).transpose()).sum()
    web.loc[(region,slice(None),energy_flows_names),:] = web.loc[(region,slice(None),energy_flows_names),:].fillna(0)

# Check
# Compare (shares_flows.loc[(region,slice(None),slice(None)),:].to_numpy() * flow_temp.loc[(region,slice(None),slice(None)),:].to_numpy().repeat(len(transformation_flows_names)).reshape((nb_prod,len(transformation_flows_names))).transpose()).sum(axis=0).shape
# and flow_temp.to_numpy()

print( "Check sum for Non-specified (energy): ", web.xs("Non-specified (energy)",level='Flow').fillna(0).values.sum() - sum0)

web.drop('Non-specified (energy)', level='Flow', inplace=True)



# Distributing "Non-specified (industry)"

#flow_temp = web.loc[(slice(None),slice(None),"Non-specified (industry)"),:].fillna(0).copy()
#distribute_flows = web.loc[(slice(None),slice(None),industry_flows_names),:].copy().fillna(0)
#shares_flows = distribute_flows/distribute_flows.sum(level='Region')

#shares_flows = shares_flows.fillna(0)
#for product in web.columns:
#    for region in all_regions :
#        if shares_flows.loc[(region,slice(None),slice(None)),product].to_numpy().sum()==0:
#            shares_flows.loc[(region,slice(None),slice(None)),product] = shares_flows.loc[('WLD',slice(None),slice(None)),product].fillna(0)

#for product in web.columns:
#    for region in all_regions :
#        if shares_flows.sum(level='Region').loc[(region),product] == 0:
#            shares_flows.loc[(region,slice(None), slice(None)), product] = 1 / len(industry_flows_names)

#sum0=0
#for region in all_regions:
#    web.loc[(region,slice(None),industry_flows_names),:] += (shares_flows.loc[(region,slice(None),slice(None)),:].to_numpy() * flow_temp.loc[(region),:].to_numpy().repeat(len(industry_flows_names)).reshape((nb_prod,len(industry_flows_names))).transpose())
#    sum0 += (shares_flows.loc[(region,slice(None),slice(None)),:].to_numpy() * flow_temp.loc[(region),:].to_numpy().repeat(len(industry_flows_names)).reshape((nb_prod,len(industry_flows_names))).transpose()).sum()
#    web.loc[(region,slice(None),industry_flows_names),:] = web.loc[(region,slice(None),industry_flows_names),:].fillna(0)

#print( "Check sum for Non-specified (industry): ", web.xs("Non-specified (industry)",level='Flow').fillna(0).values.sum() - sum0)

#web.drop('Non-specified (industry)', level='Flow', inplace=True)



# Distributing "Non-specified (Transports)"

flow_temp = web.loc[(slice(None),slice(None),"Non-specified (transport)"),:].copy().fillna(0)
distribute_flows = web.loc[(slice(None),slice(None),transport_flows_names),:].copy().fillna(0)
shares_flows = distribute_flows/distribute_flows.sum(level='Region')

shares_flows = shares_flows.fillna(0)
for product in web.columns:
    for region in all_regions :
        if shares_flows.loc[(region,slice(None),slice(None)),product].to_numpy().sum()==0:
            shares_flows.loc[(region,slice(None),slice(None)),product] = shares_flows.loc[('WLD',slice(None),slice(None)),product].fillna(0)

for product in web.columns:
    for region in all_regions :
        if shares_flows.sum(level='Region').loc[(region),product] == 0:
            shares_flows.loc[(region,slice(None), slice(None)), product] = 1 / len( transport_flows_names)

sum0=0
for region in all_regions:
    web.loc[(region,slice(None),transport_flows_names),:] += (shares_flows.loc[(region,slice(None),slice(None)),:].to_numpy() * flow_temp.loc[(region),:].to_numpy().repeat(len(transport_flows_names)).reshape((nb_prod,len(transport_flows_names))).transpose())
    sum0 += (shares_flows.loc[(region,slice(None),slice(None)),:].to_numpy() * flow_temp.loc[(region),:].to_numpy().repeat(len(transport_flows_names)).reshape((nb_prod,len(transport_flows_names))).transpose()).sum()
    web.loc[(region,slice(None),energy_flows_names),:] = web.loc[(region,slice(None),energy_flows_names),:].fillna(0)

# Check
# Compare (shares_flows.loc[(region,slice(None),slice(None)),:].to_numpy() * flow_temp.loc[(region,slice(None),slice(None)),:].to_numpy().repeat(len(transformation_flows_names)).reshape((nb_prod,len(transformation_flows_names))).transpose()).sum(axis=0).shape
# and flow_temp.to_numpy()

print( "Check sum for Non-specified (transport): ", web.xs("Non-specified (transport)",level='Flow').fillna(0).values.sum() - sum0)

web.drop('Non-specified (transport)', level='Flow', inplace=True)


## 3.5 - Distributing losses between flows from the "Energy industry own use" block.

flow_temp = web.loc[(slice(None),slice(None),"Losses"),:].copy().fillna(0)
distribute_flows = web.loc[(slice(None),slice(None),energy_flows_names),:].copy().fillna(0)
shares_flows = distribute_flows/distribute_flows.sum(level='Region')

shares_flows = shares_flows.fillna(0)
for product in web.columns:
    for region in all_regions :
        if shares_flows.loc[(region,slice(None),slice(None)),product].to_numpy().sum()==0:
            shares_flows.loc[(region,slice(None),slice(None)),product] = shares_flows.loc[('WLD',slice(None),slice(None)),product].fillna(0)

for product in web.columns:
    for region in all_regions :
        if shares_flows.sum(level='Region').loc[(region),product] == 0:
            shares_flows.loc[(region,slice(None), slice(None)), product] = 1 / len( energy_flows_names)

sum0 =0
for region in all_regions:
    web.loc[(region,slice(None),energy_flows_names),:] += (shares_flows.loc[(region,slice(None),slice(None)),:].to_numpy() * flow_temp.loc[(region),:].to_numpy().repeat(len(energy_flows_names)).reshape((nb_prod,len(energy_flows_names))).transpose())
    sum0 += (shares_flows.loc[(region,slice(None),slice(None)),:].to_numpy() * flow_temp.loc[(region),:].to_numpy().repeat(len(energy_flows_names)).reshape((nb_prod,len(energy_flows_names))).transpose()).sum()
    web.loc[(region,slice(None),energy_flows_names),:] = web.loc[(region,slice(None),energy_flows_names),:].fillna(0)

# Check
# Compare (shares_flows.loc[(region,slice(None),slice(None)),:].to_numpy() * flow_temp.loc[(region,slice(None),slice(None)),:].to_numpy().repeat(len(transformation_flows_names)).reshape((nb_prod,len(transformation_flows_names))).transpose()).sum(axis=0).shape
# and flow_temp.to_numpy()

print( "Check sum for Losses: ", web.xs("Losses",level='Flow').fillna(0).values.sum() - sum0)

web.drop('Losses', level='Flow', inplace=True)

##  3.6 - Adjusting International marine and aviation bunkers to IOT format

"""
# 1) volumes exportés = [ valeurs exportées / valeurs domestiques ] (GTAP) * volumes domestiques (IEA) par pays
# 2) on normalise pour garder la bonne somme au niveau mondial

sector_list = input_dimensions_values['TRAD_COMM']
transports_list = input_dimensions_values['MARG_COMM']
transports_indices = {transport_sector:sector_list.index(transport_sector) for transport_sector in transports_list}
transports_idx = {transports_list[idx] : idx for idx in range(len(transports_list))}

domCons_PublicAdmi_mPr = input_data['VDGM'] # Government Domestic Purchases at market Prices
domCons_Households_mPr = input_data['VDPM'] # Private Households - Domestic Purchases at market Prices
dom_CI_Firms_mPr = input_data['VDFM'] # Intermediate- Firms' Domestic Purchases at Market Price
# export_Transportation_mPr  = input_data['VST'] # Trade-Exports for International Transportation at Market Prices

domCons_atp_mPr = domCons_PublicAdmi_mPr[transports_indices['atp']] + domCons_Households_mPr[transports_indices['atp']] + dom_CI_Firms_mPr[transports_indices['atp']].sum(axis=0)
domCons_wtp_mPr = domCons_PublicAdmi_mPr[transports_indices['wtp']] + domCons_Households_mPr[transports_indices['wtp']] + dom_CI_Firms_mPr[transports_indices['wtp']].sum(axis=0)

# Exports_BT_wPr = inputdata['VXWD'] #Bilateral Exports at World Prices
# Exp_bil is likely the same thing as Exports_BT_wPr, but we use Exp_bil as in the SAM
tradeExp = input_data['BI01']
transports_indices_list = list(transports_indices.values())
Exp_bil = tradeExp[transports_indices_list,:,:,0] + tradeExp[transports_indices_list,:,:,1]
Exp_bil_within_ImRegions = np.zeros(Exp_bil.shape)

# Removing auto-imports created by future agregation

for ImRegionCountries in Imaclim2GTAP10.values():
    ImRegionCountriesIndex = list(map(lambda x: GTAP_countries_list.index(x), ImRegionCountries))
    for idCountry1 in ImRegionCountriesIndex :
        for idCountry2 in ImRegionCountriesIndex :
            # even for auto-imports within countries
            # reminder : we have deleted the last country from agregation : Antartica
            Exp_bil_within_ImRegions[:,idCountry1,idCountry2] = Exp_bil[:,idCountry1,idCountry2]
            Exp_bil[:,idCountry1,idCountry2] = 0

Exp_trans_between_ImRegions = Exp_bil.sum(axis=2)
Exp_trans_within_ImRegions = Exp_bil_within_ImRegions.sum(axis=2)

# export_atp_mPr = export_Transportation_mPr[[transports_idx['atp']]][0]
# export_wtp_mPr = export_Transportation_mPr[[transports_idx['wtp']]][0]

transport = pd.DataFrame(index=input_dimensions_values['REG'], columns=['domCons_atp', 'domCons_wtp', 'export_atp', 'export_wtp'])

transport['domCons_atp'] = domCons_atp_mPr
transport['domCons_wtp'] = domCons_wtp_mPr
transport['export_atp_btw'] = Exp_trans_between_ImRegions[transports_idx['atp'],:]
transport['export_atp_wtn'] = Exp_trans_within_ImRegions[transports_idx['atp'],:]
transport['export_wtp_btw'] = Exp_trans_between_ImRegions[transports_idx['wtp'],:]
transport['export_wtp_wtn'] = Exp_trans_within_ImRegions[transports_idx['wtp'],:]

# here we match IEA and GTAP through ISO3

transport = transport.reset_index()
transport = transport.merge(ISO2GTAP, left_on=transport['index'], right_on=ISO2GTAP['REG_V10'], how='left').groupby('ISO').sum()

transport = transport.reset_index()
transport['ISO3'] = transport['ISO'].apply(lambda x: x.upper())


list_countries = set(web.reset_index()['Region']).intersection(set(transport['ISO3'].to_list()))
# We take the intersection because there are some territories in IEA that are not encompassed
# with this level of aggregation in GTAP + some tables are not countries.
# For GTAP10 : World Aviation Bunkers, World Marine Bunkers, World, G20, Kosovo, South Sudan, Curaçao
"""

# Special cases : South Sudan, Curaçao
web.drop('CUW',level='Region',inplace=True)
web.loc[('SDN',slice(None),slice(None)),:] += web.loc[('SSD',slice(None),slice(None)),:]
web.drop('SSD',level='Region',inplace=True)

"""
transport.set_index('ISO3', inplace=True)

web_concat = web.loc[(list_countries,slice(None),['World aviation bunkers','Domestic aviation','World marine bunkers', 'Domestic navigation']),:].copy()
web_concat.rename(index = {'World aviation bunkers' :'Aviation services - exports within region' ,'Domestic aviation':'Aviation services - exports between regions' ,'World marine bunkers' : 'Navigation services - exports within region', 'Domestic navigation': 'Navigation services - exports between regions'}, level = 'Flow', inplace = True)

shares_wtp_wtn = (transport['export_wtp_wtn'])/((transport['export_wtp_wtn']+transport['export_wtp_btw']).sum())
shares_atp_wtn = (transport['export_atp_wtn'])/((transport['export_atp_wtn']+transport['export_atp_btw']).sum())

for country in list_countries:
    web_concat.loc[(country,slice(None),'Aviation services - exports within region'    ),:] = (shares_atp_wtn[country]*web.loc[(country,slice(None),'Domestic aviation'),:]).fillna(0).to_numpy()
    web_concat.loc[(country,slice(None),'Aviation services - exports between regions'  ),:] = ( (1-shares_atp_wtn[country])*web.loc[(country,slice(None),'Domestic aviation'),:]).fillna(0).to_numpy()
    web_concat.loc[(country,slice(None),'Navigation services - exports within region'  ),:] = (shares_wtp_wtn[country]*web.loc[(country,slice(None),'Domestic navigation'),:]).fillna(0).to_numpy()
    web_concat.loc[(country,slice(None),'Navigation services - exports between regions'),:] = ( (1-shares_wtp_wtn[country])*web.loc[(country,slice(None),'Domestic navigation'),:]).fillna(0).to_numpy()


web = pd.concat([web,web_concat])
"""

##  3.7 - Transports treatment.

"""
# TODO strange way to do.. erase adn create empty entry instead
web_concat = web.loc[(list_countries,slice(None),transport_flows_names+['Production', 'Imports', 'Exports']),:].copy()
web_concat.rename(index = {
    "World aviation bunkers": 'Aviation services - exports within region - private',
    "Domestic aviation": 'Aviation services - exports within region - industries',
    "Road": 'Aviation services - exports between regions - private',
    "Rail": 'Aviation services - exports between regions - industries',
    "Pipeline transport": 'Road - private',
    "World marine bunkers": 'Road - industries',
    "Domestic navigation" : 'Rail - private',
    "Production": 'Rail - industries',
    "Imports": 'Domestic aviation - private',
    "Exports": 'Domestic aviation - industries'
}, level = 'Flow', inplace = True)

# Arbitrary first treatment, TODO update later with proper data
# TODO arbitrary variable
web_concat.loc[(slice(None),slice(None),'Aviation services - exports within region - private'),:] = web.loc[(slice(None),slice(None),'Aviation services - exports within region'),:].to_numpy() * transport_share_private
web_concat.loc[(slice(None),slice(None),'Aviation services - exports within region - industries'),:] = web.loc[(slice(None),slice(None),'Aviation services - exports within region'),:].to_numpy() * (1-transport_share_private)
web_concat.loc[(slice(None),slice(None),'Aviation services - exports between regions - private'),:] = web.loc[(slice(None),slice(None),'Aviation services - exports between regions'),:].to_numpy() * transport_share_private
web_concat.loc[(slice(None),slice(None),'Aviation services - exports between regions - industries'),:] = web.loc[(slice(None),slice(None),'Aviation services - exports between regions'),:].to_numpy() * (1-transport_share_private)
web_concat.loc[(slice(None),slice(None),'Road - private'),:] = web.loc[(list_countries,slice(None),'Road'),:].to_numpy() * transport_share_private
web_concat.loc[(slice(None),slice(None),'Road - industries'),:] = web.loc[(list_countries,slice(None),'Road'),:].to_numpy() * (1-transport_share_private)
web_concat.loc[(slice(None),slice(None),'Rail - private'),:] = web.loc[(list_countries,slice(None),'Rail'),:].to_numpy() * transport_share_private
web_concat.loc[(slice(None),slice(None),'Rail - industries'),:] = web.loc[(list_countries,slice(None),'Rail'),:].to_numpy() * (1-transport_share_private)
#web_concat.loc[(slice(None),slice(None),'Domestic aviation - private'),:] = web.loc[(list_countries,slice(None),'Domestic aviation'),:].to_numpy() * transport_share_private
#web_concat.loc[(slice(None),slice(None),'Domestic aviation - industries'),:] = web.loc[(list_countries,slice(None),'Domestic aviation'),:].to_numpy() * (1-transport_share_private)

web_concat.loc[(slice(None),slice(None),'Domestic aviation - private'),:] = web_concat.loc[(slice(None),slice(None),'Aviation services - exports within region - private'),:].to_numpy() * transport_share_private
web_concat.loc[(slice(None),slice(None),'Domestic aviation - industries'),:] = web_concat.loc[(slice(None),slice(None),'Aviation services - exports within region - industries'),:].to_numpy() * (1-transport_share_private)


web_concat = web_concat.fillna(0) 
web = pd.concat([web,web_concat])
"""

#   3.8 - Exception: adding non-energy use of non-energy product from refinery
#            Done by adding it to the energy use flow (Chemical and Petrochemical)
list_product__nonenergy_use_refinery = ["Naphtha","White spirit & SBP","Lubricants","Bitumen","Paraffin waxes"]
web.loc[(slice(None),slice(None),'Chemical and petrochemical'),list_product__nonenergy_use_refinery] += web.loc[(slice(None),slice(None),"   Memo: Non-energy use chemical/petrochemical"),list_product__nonenergy_use_refinery].to_numpy()
web.loc[(slice(None),slice(None),"   Memo: Non-energy use chemical/petrochemical"),list_product__nonenergy_use_refinery] *= 0

#   3.9 - International transport acocunted as uses
web.loc[(slice(None),slice(None),'International marine bunkers'),:] *= -1
web.loc[(slice(None),slice(None),'International aviation bunkers'),:] *= -1

##############################################################
# 4 - Aggregating flows towards an ~EDS format (see GTAP doc).
##############################################################
# Warning : This is not EDS as described within the GTAP documentation.
# The idea was to be able to have the same output format, but both are not directly comparable.
# This is our own variant based on it. See hybridation documents.
# We have for instance changed how transport was managed.

# Saving table before aggregation 
web.to_csv(savePath+'web_noaggregation.csv',sep='|')
web = pd.read_csv(savePath+'web_noaggregation.csv',sep='|').set_index(['Region','Year','Flow'])


web_copy = web.copy()
web.loc[( 'WLD',slice(None),'Imports'),:] *= 0 # because we don't want to re-balanc with import and export world data
web.loc[( 'WLD',slice(None),'Exports'),:] *= 0
#web.drop('WLD',level='Region',inplace=True)
web = web.fillna(0)  #Ensures every value is indeed replaced

## 4.1 - Aggregating energy flows.

web_EDS = aggregate_flows( energy_own_use_flows_aggregation_rules, web, complete_rules=True)

## 4.2 - Cancelling auto-consumption. // Removing non-valued intra-industry uses.

# TODO: need to save auto-consumptions aside
if do_remove_auto_consumption:
    for energy_indus_agg in ['coa','ely','p_c', 'oil', 'gas']:
        for energy_industry in iea_EEB2GTAP_EDS_consumption_flows_aggregation_rules[ energy_indus_agg]:
            for energy_product in products_aggregation_rules[ energy_indus_agg]:
                web_EDS.loc[(slice(None),slice(None), energy_industry), energy_product] = 0

# all negative flows come from energy flows
web_EDS = web_EDS.abs()


## 4.3 - Aggregating consumption flows.

#TODO : remove heat from aggregation,
web_EDS = aggregate_flows( iea_EEB2GTAP_EDS_consumption_flows_aggregation_rules, web_EDS, complete_rules=True)


##############################################################
## 5 - Aggregating products towards an EDS format and correcting imports/exports for balance.
##############################################################

web_EDS_copy = web_EDS.copy()

# web_EDS_copy.to_csv(savePath+'./web_EDS.csv',sep='|')

# Products aggregation
# Here it is the same output product categories for both ~EDS and Imaclim, so we directly aggregate to Imaclim format.
aggregate_products( products_aggregation_rules, web_EDS_copy, web_EDS_copy, complete_rules=True)

all_uses = list()
#all_uses = [ key for key in iea_EEB2GTAP_EDS_consumption_flows_aggregation_rules.keys() if ( key not in ["Imports", "Exports", "TPES", "Production", "International marine bunkers","International aviation bunkers", "Stock changes"])]
all_uses = [ key for key in iea_EEB2GTAP_EDS_consumption_flows_aggregation_rules.keys() if ( key not in ["Imports", "Exports", "TPES", "Production", "Transfers", "Statistical differences", "Transformation processes", "Stock changes"])] #International marine bunkers","International aviation bunkers", "Stock changes"])]

##############################################################
# 5.1 Before rebalancing imports / exports, we want to check that there is no imports greater than consumptions

"""
import_consumption_ratio = web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:].fillna(0).to_numpy() / web_EDS_copy.loc[(slice(None),slice(None),all_uses),:].sum(level='Region').to_numpy()
import_consumption_ratio = np.where( np.isnan( import_consumption_ratio), 1, import_consumption_ratio)
where_imports_greater = np.where( import_consumption_ratio >1)
print("There is imports greater than consumptions", np.where( import_consumption_ratio >1)[0].shape)

for ind, x in enumerate(where_imports_greater[0]):
    y = where_imports_greater[1][ind]
    print( web_EDS_copy.loc[(slice(None),slice(None),'Production'),:].iloc[x, y], web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:].iloc[x, y], web_EDS_copy.loc[(slice(None),slice(None),'Exports'),:].iloc[x, y], web_EDS_copy.loc[(slice(None),slice(None),'TPES'),:].iloc[x, y], web_EDS_copy.loc[(slice(None),slice(None),all_uses),:].sum(level='Region').iloc[x, y]) 
    #print( web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:].iloc[x, y] / web_EDS_copy.loc[(slice(None),slice(None),all_uses),:].sum(level='Region').iloc[x, y])

# First: we remove internation marine/aviation from imports (all flux are negative in the original EB)
#web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:] -= web_EDS_copy.loc[(slice(None),slice(None),'International marine bunkers'),:].fillna(0).to_numpy()
#web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:] -= web_EDS_copy.loc[(slice(None),slice(None),'International aviation bunkers'),:].fillna(0).to_numpy()
#web_EDS_copy.loc[(slice(None),slice(None),'International marine bunkers'),:] *= 0
#web_EDS_copy.loc[(slice(None),slice(None),'International aviation bunkers'),:] *= 0
#web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:] = np.abs( web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:])

# Second, remove stock changes from import in regions where imports are greater then TPES
if correct_stock_changes:
    imports = web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:].fillna(0).to_numpy()
    stock_changes = web_EDS_copy.loc[(slice(None),slice(None),'Stock changes'),:].fillna(0).to_numpy()
    stock_changes_neg = np.where( stock_changes<0, stock_changes, 0)
    imports = np.where( import_consumption_ratio > 1, imports + stock_changes_neg, imports)  
    /all_uses
web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:] = imports

# checking again if there is is still imports greater than consumptions
import_consumption_ratio = web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:].fillna(0).to_numpy() / web_EDS_copy.loc[(slice(None),slice(None),all_uses),:].sum(level='Region').to_numpy()
import_consumption_ratio = np.where( np.isnan( import_consumption_ratio), 1, import_consumption_ratio)
where_imports_greater = np.where( import_consumption_ratio >1)
print("There is still imports greater than consumptions", np.where( import_consumption_ratio >1)[0].shape)

# Third rescale imports according to original TPES
tpes = web_EDS_copy.loc[(slice(None),slice(None), ['TPES']),:].sum(level='Region').to_numpy()
ratio_tpes = web_EDS_copy.loc[(slice(None),slice(None),all_uses),:].sum(level='Region').to_numpy() / tpes
ratio_tpes = np.where( np.isnan( ratio_tpes), 1, ratio_tpes)
ratio_tpes = np.where(  ratio_tpes==np.inf, 1, ratio_tpes)
ratio_tpes = np.where(  import_consumption_ratio<1, 1, ratio_tpes)
#web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:] *= ratio_tpes

# Fourth dealing with re-exports
imports = web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:].fillna(0).to_numpy()
tpes = web_EDS_copy.loc[(slice(None),slice(None), ['TPES']),:].to_numpy()
prod = web_EDS_copy.loc[(slice(None),slice(None),'Production'),:].fillna(0).to_numpy()
exports = web_EDS_copy.loc[(slice(None),slice(None),'Exports'),:].fillna(0).to_numpy()
# case Imports > TPES & Q < TPES
exports_new = exports
exports_new = np.where( (imports>tpes) * (prod<tpes) * (import_consumption_ratio>1), exports - (imports - (tpes-prod)), exports)
exports_new = np.where( exports_new<0, 0, exports_new)

exports_new = np.where( exports_new > prod, 0, exports_new)

imports += (exports_new-exports)

# Some countries imports and re-exports fuel (mostly fuel oil).
# This is not clear if it is only commercial (buy and sell) or if the product is transformed (further refining, for example).
# Without correcting for re-exportation, we already have a good balance between imports for most of the countries
# however some countries have more imports than total consumption
# which could cause some problem in Imaclim calibration
# This seems only for small country, so this problem might disappear when aggregating region. This should be checked
# and consumption (Imp < Cons) for the 5 aggregated product
if correct_re_exportations: 
    web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:] = imports
    web_EDS_copy.loc[(slice(None),slice(None),'Exports'),:] = exports_new

# checking again if there is is still imports greater than consumptions
import_consumption_ratio = web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:].fillna(0).to_numpy() / web_EDS_copy.loc[(slice(None),slice(None),all_uses),:].sum(level='Region').to_numpy()
import_consumption_ratio = np.where( np.isnan( import_consumption_ratio), 1, import_consumption_ratio)
import_consumption_ratio = np.where( import_consumption_ratio==np.inf, 1, import_consumption_ratio)
#import_consumption_ratio = import_consumption_ratio.reshape( ( 192, 34, import_consumption_ratio.shape[1]) )
print("There is still imports greater than consumptions", np.where( import_consumption_ratio >1)[0].shape)


# Algorithme import/export
# also works at the disaggregated level
# COM: right computation of the sum of all uses. was not matching in previous computation
"""

# First: We adjust imports and export to the total demand as computed

web_EDS_copy_cons = web_EDS_copy.loc[(slice(None),slice(None),['Production','Exports','Imports']),:].copy()
web_EDS_copy_cons.rename(index = {
    "Imports": 'Cons. Flows original',
    "Exports": 'Cons. Flows recomputed',
    "Production": 'Production recomputed'
}, level = 'Flow', inplace = True)
web_EDS_copy_cons.loc[(slice(None),slice(None),slice(None)),:] *= 0

web_EDS_copy_cons.loc[(slice(None),slice(None),'Cons. Flows recomputed'),:] += web_EDS_copy.loc[(slice(None),slice(None),all_uses),:].sum(level='Region').to_numpy()

web_EDS_copy_cons.loc[(slice(None),slice(None),'Cons. Flows original'),:] += web_EDS_copy.loc[(slice(None),slice(None), ["Imports", "Production", "Transfers", "Statistical differences", "Transformation processes", "Stock changes"]),:].sum(level='Region').to_numpy() - web_EDS_copy.loc[(slice(None),slice(None), "Exports"),:].sum(level='Region').to_numpy()

web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:] *= (web_EDS_copy_cons.loc[(slice(None),slice(None),'Cons. Flows recomputed'),:].to_numpy() / web_EDS_copy_cons.loc[(slice(None),slice(None),'Cons. Flows original'),:].to_numpy())
web_EDS_copy.loc[(slice(None),slice(None),'Exports'),:] *= (web_EDS_copy_cons.loc[(slice(None),slice(None),'Cons. Flows recomputed'),:].to_numpy() / web_EDS_copy_cons.loc[(slice(None),slice(None),'Cons. Flows original'),:].to_numpy())

web_EDS_copy_cons.loc[(slice(None),slice(None),'Production recomputed'),:] += web_EDS_copy_cons.loc[(slice(None),slice(None),'Cons. Flows recomputed'),:].to_numpy() - web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:].to_numpy() + web_EDS_copy.loc[(slice(None),slice(None),'Exports'),:].to_numpy()

web_EDS_copy = pd.concat([web_EDS_copy,web_EDS_copy_cons.loc[(slice(None),slice(None),'Production recomputed'),:]])

# Second: dealing with re-exports, avoiding negative imports

imports = web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:].fillna(0).to_numpy()
prod = web_EDS_copy.loc[(slice(None),slice(None),'Production recomputed'),:].fillna(0).to_numpy()
exports = web_EDS_copy.loc[(slice(None),slice(None),'Exports'),:].fillna(0).to_numpy()

exports_new = exports
exports_new = exports_new - np.where( exports_new> prod , np.minimum( imports, exports_new), 0)
imports += (exports_new-exports)

web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:] = imports
web_EDS_copy.loc[(slice(None),slice(None),'Exports'),:] = exports_new

# Third: check that there is no imports larger than consumption
import_consumption_ratio = web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:].fillna(0).to_numpy() / web_EDS_copy.loc[(slice(None),slice(None),all_uses),:].sum(level='Region').to_numpy()
import_consumption_ratio = np.where( np.isnan( import_consumption_ratio), 1, import_consumption_ratio)
where_imports_greater = np.where( import_consumption_ratio >1)
print("There is imports greater than consumptions", np.where( import_consumption_ratio >1)[0].shape)
for ind, x in enumerate(where_imports_greater[0]):
    y = where_imports_greater[1][ind]
    print( web_EDS_copy.loc[(slice(None),slice(None),'Production'),:].iloc[x, y], web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:].iloc[x, y], web_EDS_copy.loc[(slice(None),slice(None),'Exports'),:].iloc[x, y], web_EDS_copy.loc[(slice(None),slice(None),'TPES'),:].iloc[x, y], web_EDS_copy.loc[(slice(None),slice(None),all_uses),:].sum(level='Region').iloc[x, y]) 
    #print( web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:].iloc[x, y] / web_EDS_copy.loc[(slice(None),slice(None),all_uses),:].sum(level='Region').iloc[x, y])


############################################################
## 5.2 rebalance import and export at the global scale

imports = web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:].copy()
exports = web_EDS_copy.loc[(slice(None),slice(None),'Exports'),:].copy().abs()
sum_imports = imports.sum()
sum_exports = exports.sum()

#TODO import are not balanced with exports

#sum [I_k * 1/2 *(1 + sum E_j / sum I_j) - E_k * 1/2 * (1 + sum I_j / sum E_j)] = 0
#coef_imports = alpha_imports * (1 + (sum_exports/sum_imports).mask((sum_exports/sum_imports).isin([np.inf,np.nan]),0))
#coef_exports = (1 - alpha_imports) * (1 + (sum_imports/sum_exports).mask((sum_imports/sum_exports).isin([np.inf,np.nan]),0))
coef_imports = 1
coef_exports = (sum_imports / sum_exports).mask((sum_imports/sum_exports).isin([np.inf,np.nan]), 1)

if do_rebalance_import_export:
    for product in web_EDS_copy.columns:
        #web_EDS_copy.loc[(slice(None),slice(None),'Imports'),product] *=  coef_imports[product] 
        #web_EDS_copy.loc[(slice(None),slice(None),'Exports'),product] *=  coef_exports[product]
        web_EDS_copy.loc[(slice(None),slice(None),'Imports'),product] *=  coef_imports
        web_EDS_copy.loc[(slice(None),slice(None),'Exports'),product] *=  coef_exports[product]

## re-compute total production based on usage, imports, exports

# Ressources = somme des usages
web_EDS_append_index = web_EDS.loc[(slice(None),slice(None),all_uses[0]),:].index
web_EDS_append_index.set_levels(['Ressources']*web_EDS_append_index.size, level='Flow',inplace=True, verify_integrity=False)
web_EDS_copy = web_EDS_copy.append(pd.DataFrame(web_EDS_copy.loc[(slice(None),slice(None),all_uses),:].sum(level='Region').to_numpy(),index=web_EDS_append_index, columns = web_EDS_copy.columns))

# Q = R -I + E
web_EDS_append_index.set_levels(['Production (recomposed)']*web_EDS_append_index.size, level='Flow',inplace=True, verify_integrity=False)
web_EDS_copy = web_EDS_copy.append(pd.DataFrame(web_EDS_copy.loc[(slice(None),slice(None),'Ressources'),:].fillna(0).to_numpy() - web_EDS_copy.loc[(slice(None),slice(None),'Imports'),:].fillna(0).to_numpy() + web_EDS_copy.loc[(slice(None),slice(None),'Exports'),:].fillna(0).to_numpy() ,index=web_EDS_append_index, columns = web_EDS_copy.columns))


##############################################################
## 6 - Saving the matrix in EDS format.
##############################################################
with open(savePath+'EDS_+_outside_hybridation.csv','w') as file:
    file.write('//Modified Energy Balances computed for ImaclimR hybridization (by geographic region and nature of flow, EDS (GTAP) format)\n//calcutated from IEA Energy Balances for '+str(year)+', including data outside pure hybridization\n//Unit: ktoe\n')
    web_EDS_copy.loc[(slice(None),slice(None),flows_to_save_EDS+flows_to_save_outside_hybridation),products_to_save+products_to_save_outside_hybridation].to_csv(file, sep= '|')

with open(savePath+'EDS_saved.csv','w') as file:
    file.write('//Modified Energy Balances computed for ImaclimR hybridization (by geographic region and nature of flow, EDS (GTAP) format)\n//calcutated from IEA Energy Balances for '+str(year)+'\n//Unit: ktoe\n')
    web_EDS_copy.loc[(slice(None),slice(None),flows_to_save_EDS),products_to_save].to_csv(file, sep= '|')

# Saving EDS flow level at the GTAP regional level
web_gtap_reg = web_EDS_copy.copy()
web_gtap_reg.drop('WLD',level='Region',inplace=True)
web_gtap_reg.reset_index(inplace=True)
web_gtap_reg['Region_Gtap'] = list(map(lambda x: ISO2GTAP_dict[x], web_gtap_reg['Region']))
web_gtap_reg = web_gtap_reg.groupby(['Region_Gtap', 'Year', 'Flow']).sum()
# saving regional aggregation at the GTAP scale - EDS level for flows/products

# exclude flow which served for computation but do not participate to the final energy balance
flow_2_exclude = ["TPES", "International aviation bunkers", "International marine bunkers", "Stock changes", "Production", "World marine bunkers", "World aviation bunkers"]
flow_2_exclude = ["TPES", "Stock changes", "Production", "World marine bunkers", "World aviation bunkers"]
with open(savePath+'Imaclim__EDS_Gtap_Aggregation.csv','w') as file:
    file.write('//Modified Energy Balances computed for ImaclimR hybridization (by GTAP geographic region and EDS nature of flow)\n//calcutated from IEA Energy Balances for '+str(year)+'\n//Unit: ktoe\n')
    web_gtap_reg.loc[(slice(None),slice(None), [elt for elt in flows_to_save_EDS if not elt in flow_2_exclude]),products_to_save].to_csv(file,sep= '|')


# 5bis - Aggregating flows towards an Imaclim format.
web_Im = aggregate_flows( GTAP_EDS2Imaclim_flows_aggregation_rules, web_EDS, complete_rules=True)

# 6bis - Saving all annex products (not for Imaclim but for comparison.)
web_Im.loc[(slice(None),slice(None),flows_to_save_Imaclim+flows_to_save_outside_hybridation),products_to_save_outside_hybridation].to_csv(savePath+'Imaclim_+_outside_hybridation.csv', sep= '|')


##############################################################
# 7bis - Aggregating products towards an Imaclim format and correcting imports/exports.
##############################################################
# Products aggregation
# Here it is the same output product categories for both ~EDS and Imaclim, so we directly aggregate to Imaclim format.
aggregate_products(products_aggregation_rules, web_Im, web_Im, complete_rules=True)

# Algorithme import/export
# also works at the disaggregated level
# TODO missing Private consumption
# TODO define it from dictionnaries

## rebalance import and export at the global scale

imports = web_Im.loc[(slice(None),slice(None),'Imports'),:].copy()
exports = web_Im.loc[(slice(None),slice(None),'Exports'),:].copy().abs()
sum_imports = imports.sum()
sum_exports = exports.sum()

#sum [I_k * 1/2 *(1 + sum E_j / sum I_j) - E_k * 1/2 * (1 + sum I_j / sum E_j)] = 0
#coef_imports = alpha_imports * (1 + (sum_exports/sum_imports).mask((sum_exports/sum_imports).isin([np.inf,np.nan]),0))
#coef_exports = (1 - alpha_imports) * (1 + (sum_imports/sum_exports).mask((sum_imports/sum_exports).isin([np.inf,np.nan]),0))
coef_imports = 1
coef_exports = (sum_imports / sum_exports).mask((sum_imports/sum_exports).isin([np.inf,np.nan]), 1)

if do_rebalance_import_export:
    for product in web_EDS_copy.columns:
        #web_EDS_copy.loc[(slice(None),slice(None),'Imports'),product] *=  coef_imports[product] 
        #web_EDS_copy.loc[(slice(None),slice(None),'Exports'),product] *=  coef_exports[product]
        web_EDS_copy.loc[(slice(None),slice(None),'Imports'),product] *=  coef_imports
        web_EDS_copy.loc[(slice(None),slice(None),'Exports'),product] *=  coef_exports[product]

## re-compute total production based on usage, imports, exports

# also works at the disaggregated level
all_uses = [ key for key in GTAP_EDS2Imaclim_flows_aggregation_rules.keys() if ( key not in ["Imports", "Exports","Production_recomposed", "TPES"])]

# Ressources = somme des usages
web_Im_append_index = web_Im.loc[(slice(None),slice(None),all_uses[0]),:].index
web_Im_append_index.set_levels(['Ressources']*web_Im_append_index.size, level='Flow',inplace=True, verify_integrity=False)
web_Im = web_Im.append(pd.DataFrame(web_Im.loc[(slice(None),slice(None),all_uses),:].sum(level='Region').to_numpy(),index=web_Im_append_index, columns = web_Im.columns))

# Q = R -I + E
web_Im_append_index.set_levels(['Production_recomposed']*web_Im_append_index.size, level='Flow',inplace=True, verify_integrity=False)
web_Im = web_Im.append(pd.DataFrame(web_Im.loc[(slice(None),slice(None),'Ressources'),:].fillna(0).to_numpy() - web_Im.loc[(slice(None),slice(None),'Imports'),:].fillna(0).to_numpy() + web_Im.loc[(slice(None),slice(None),'Exports'),:].fillna(0).to_numpy() ,index=web_Im_append_index, columns = web_Im.columns))


##############################################################
# 8bis - Aggregating regions and saving Imaclim matrix.
##############################################################

# saving WORLD before regional aggregation
with open(savePath+'Imaclim__World_Flows.csv','w') as file:
    file.write('//Modified Energy Balances computed for ImaclimR hybridization (World regions and by nature of flow)\n//calcutated from IEA Energy Balances for '+str(year)+'\n//Unit: ktoe\n')
    web_Im.loc[('WLD',slice(None),flows_to_save_Imaclim),products_to_save].to_csv(file,sep= '|')

# dropping world again
web_Im.drop('WLD',level='Region',inplace=True)

web_gtep_reg = web_Im.copy()
sum0 = web_gtep_reg.sum(axis=0).values[-5:].sum()
web_gtep_reg.reset_index(inplace=True)
web_gtep_reg['Region_Gtap'] = list(map(lambda x: ISO2GTAP_dict[x], web_gtep_reg['Region']))
web_gtep_reg = web_gtep_reg.groupby(['Region_Gtap', 'Year', 'Flow']).sum()
print("Check sum on Aggregation towards Gatp regions: ", web_gtep_reg.sum(axis=0).values[-5:].sum()-sum0)

# saving regional aggregation at the GTAP scale
with open(savePath+'Imaclim__Gtap_Aggregation.csv','w') as file:
    file.write('//Modified Energy Balances computed for ImaclimR hybridization (by GTAP geographic region and nature of flow)\n//calcutated from IEA Energy Balances for '+str(year)+'\n//Unit: ktoe\n')
    web_gtep_reg.loc[(slice(None),slice(None),flows_to_save_Imaclim),products_to_save].to_csv(file,sep= '|')

web_Im.reset_index(inplace=True)
web_Im['Region_Im'] = list(map(lambda x: ISO2Imaclim_dict[x], web_Im['Region']))
web_Im = web_Im.groupby(['Region_Im', 'Year', 'Flow']).sum()

# order flow for the main output, by keeping other output
order_flows = list(GTAP_EDS2Imaclim_flows_aggregation_rules.keys()) + [elt for elt in web_Im.index.get_level_values('Flow').unique().tolist() if not elt in GTAP_EDS2Imaclim_flows_aggregation_rules.keys()]
web_Im = web_Im.reindex(order_regions, level="Region_Im").reindex(order_flows,level='Flow')

# TODO save outside everything ?
with open(savePath+'Imaclim_final_+_outside_hybridation.csv','w') as file:
    file.write('//Modified Energy Balances computed for ImaclimR hybridization (by geographic region and nature of flow)\n//calcutated from IEA Energy Balances for '+str(year)+', including data outside pure hybridization\n//Unit: ktoe\n')
    web_Im.loc[(slice(None),slice(None),flows_to_save_Imaclim+flows_to_save_outside_hybridation),products_to_save+products_to_save_outside_hybridation].to_csv(file,sep= '|')

with open(savePath+'Imaclim_final_saved.csv','w') as file:
    file.write('//Modified Energy Balances computed for ImaclimR hybridization (by geographic region and nature of flow)\n//calcutated from IEA Energy Balances for '+str(year)+'\n//Unit: ktoe\n')
    web_Im.loc[(slice(None),slice(None),flows_to_save_Imaclim),products_to_save].to_csv(file,sep= '|')
