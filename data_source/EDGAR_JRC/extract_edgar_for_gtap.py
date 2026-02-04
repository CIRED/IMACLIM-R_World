#! /usr/bin/env python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
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
year_default = '2004'
gtap_version_default='10'
input_file_default = 'csv/'

###################
# Loading argument
parser = argparse.ArgumentParser('sort EDGAR at GTAP format')

parser.add_argument('--year', nargs='?', const=year_default, type=str, default=year_default)
parser.add_argument('--gtap-version', nargs='?',const=gtap_version_default, type=str, default=gtap_version_default)
parser.add_argument('--verbose', nargs='?',const=False, type=bool, default=False)
parser.add_argument('--input-file', nargs='?',const=input_file_default, type=str, default=input_file_default)
parser.add_argument('--output-file')

args = parser.parse_args()

year_selected = args.year
gtap_version = args.gtap_version
do_verbose = args.verbose

print(year_selected)
print(args.input_file)
print(gtap_version)
print(args.verbose)
print(args.output_file)

input_folder = args.input_file

outputfile='results/edgar_formated_for_gtap'+gtap_version+'_' + year_selected+'.csv'

# units of outputs is in Mt, as in the original GTAP database for CO2 from fosil fuel and combustion
Mt_2_Gg = 1000 # Mega Tons to GigaGramme (kt)

#v60, v50 : look for IPCC2006 in file names
v60_gas_list = ['CO2_excl_short-cycle_org_C', 'CH4', 'N2O']
v50_gas_list = ['BC', 'CO', 'NH3', 'NMVOC', 'NOx', 'OC', 'PM10', 'PM25', 'SO2']
v50_gas_list = ['BC', 'CO', 'NH3', 'NOx', 'OC', 'PM10', 'PM25', 'SO2']

#v4.2
# ex: v4.2_HCFC-142b_2002-normalized.csv
v42_gas_list = ['C2F6', 'C3F8', 'C4F10', 'C5F12', 'C6F14', 'C7F16', 'c-C4F8', 'CF4', 'CH4', 'CO', 'CO2_excl_scc', 'CO2_scc_only', 'EM_NOx', 'HCFC-141b', 'HCFC-142b', 'HFC-125', 'HFC-134a', 'HFC-143a', 'HFC-152a', 'HFC-227ea', 'HFC-23', 'HFC-236fa', 'HFC-32', 'HFC-43-10-mee', 'N2O', 'NF3', 'NH3', 'NMVOC', 'PM10', 'SF6', 'SO2']

# excluding gas already present in recent version
v42_gas_list = [elt for elt in v42_gas_list if (not elt in v50_gas_list) and (not elt in v60_gas_list) and not 'CO2' in elt]

ipcc_name_code = 'IPCC_code_2006'

##################################################################################
# functions
##################################################################################
#-------------------------------------------
def load_edgar_as_dataframe_v42( list_files, sep, skiprows=0, na_values='NULL'):
    pd_concat_list=list()
    for fil in list_files:
        csv_as_string = StringIO()
        stry = open( fil, 'r').read()
        for r, row in  enumerate([x for x in stry.split('\n')]):
            if "Year" in row:
                year = int(row.split(sep)[1].replace('"',''))
            if "Compound" in row:
                compound = row.split(sep)[1].replace('"','')
            if r<skiprows or "TOTALS" in row or row=='':
                continue
            if r==skiprows:
                nb_sep = row.count(sep)
            csv_as_string.write( [row, row[:-1]][ row.count(sep) > nb_sep] + "\n")
        pd_concat_list.append( pd.read_csv( StringIO( csv_as_string.getvalue()), sep=sep, na_values=na_values))
    df_out = pd.concat( pd_concat_list)
    df_out['year'] = year
    df_out['compound'] = compound
    return df_out
#-------------------------------------------
def load_edgar_as_dataframe_v50_v60( list_files, sep='|', skiprows=0, na_values='NULL'):
    pd_concat_list=list()
    for fil in list_files:
        df = pd.read_csv( fil, skiprows=skiprows, sep=sep, na_values=na_values)
        # get compound
        stry = open( fil, 'r').read()
        for r, row in  enumerate([x for x in stry.split('\n')]):
            if "Compound" in row:
                compound = row.split(sep)[1].replace('"','')
                break
        df['compound'] = compound
        pd_concat_list.append( df)
    df_out = pd.concat( pd_concat_list)
    return df_out
#-------------------------------------------
def load_IPCC_gwp_dict( path, gwp_serie):
    df = pd.read_csv( path, skiprows=9, sep=',', na_values='NULL')
    return dict(zip(df.Species, df[gwp_serie]))
#-----------------------------------------------------------------------------------------------------------

##################################################################################
# global dictionnaries
##################################################################################

# regional dict
GTAPpath = '/data/shared/GTAP/'
Imaclim2ISO3_path = '/data/public_data/regional_aggregations/imaclim/'

# loading dict to match gtap with iso3
ISO2GTAP = pd.read_csv(GTAPpath+'./ISO3166_GTAP.csv')[['ISO','REG_V10']]
ISO2GTAP['ISO3'] = ISO2GTAP['ISO'].apply(lambda x: x.upper())
ISO2GTAP_dict = ISO2GTAP.set_index('ISO3')['REG_V10'].to_dict()

# missing
ISO2GTAP_dict['CUW'] = 'nld'
ISO2GTAP_dict['SCG'] = 'xer'

ISO2Imaclim = pd.read_csv(Imaclim2ISO3_path + './imaclim_ISO3_aggregates.csv', sep='|')
ISO2Imaclim_dict = ISO2Imaclim.set_index('ISO3')['Im_region'].to_dict()

ISO2Imaclim_dict['CUW'] = 'EUR'
ISO2Imaclim_dict['SCG'] = 'EUR'

# gtap Imaclim rule
Gtap2Imaclim_dict={}
path='externals/ImaclimR_aggregation_rules/aggregation_Imaclim_GTAP10_region__after_hybridation.csv'
with open(path) as fp:
    for line in fp.readlines():
        reg_im=line.split('|')[0]
        for reg_gtap in line.strip().split('|')[1:]:
            Gtap2Imaclim_dict[reg_gtap]=reg_im

##################################################################################
# Loading datas
##################################################################################

#-----------------------------------------------------------------------------------------------------------
print('Loading GTAP data')
# Importing GTAP data. Not optimal.
input_file = GTAPpath+'./results/extracted_GTAP10_'+year_selected+'/GTAP_tables.csv'
input_data, input_dimensions_values, input_data_dimensions = aggregation_GTAP.read_dimensions_tables_file(input_file)
input_file = GTAPpath+'./results/extracted_GTAP10_'+year_selected+'/SAMs.csv'
input_data_sam, input_dimensions_values_sam, input_data_dimensions_sam = aggregation_GTAP.read_dimensions_tables_file(input_file)


#-------------------------------------------
# load separate dataset for edgar versions
list_all_csv = [input_folder+fil for fil in os.listdir(input_folder) if ('normalized.csv' in fil and not 'v4.2' in fil) or ('v4.2' in fil and not 'normalized.csv' in fil)]

# load v60
#df_v60 = pd.concat( [ pd.read_csv( fil, skiprows=9, sep='|', na_values='NULL') for fil in list_all_csv if 'IPCC2006' in fil and 'v60' in fil and sum([elt in fil for elt in v60_gas_list]) >0 ])
df_v60 = load_edgar_as_dataframe_v50_v60( [fil for fil in list_all_csv if 'IPCC2006' in fil and 'v60' in fil and sum([elt in fil for elt in v60_gas_list]) >0 ], sep='|', skiprows=9, na_values='NULL')

# load v50
#df_v50 = pd.concat( [ pd.read_csv( fil, skiprows=9, sep='|', na_values='NULL') for fil in list_all_csv if 'IPCC2006' in fil and 'v50' in fil and sum([elt in fil for elt in v50_gas_list]) >0 ])
df_v50 = load_edgar_as_dataframe_v50_v60( [fil for fil in list_all_csv if 'IPCC2006' in fil and 'v50' in fil and sum([elt in fil for elt in v50_gas_list]) >0 ], sep='|', skiprows=9, na_values='NULL')

# load v42
df_v42 = pd.concat( [load_edgar_as_dataframe_v42( ['csv/v4.2_'+elt+'_'+str(year)+'.csv'], skiprows=10, sep=',', na_values='NULL') for elt in v42_gas_list for year in range(1990,2009) if os.path.isfile('csv/v4.2_'+elt+'_'+str(year)+'.csv')])

# format v42
df_v42 = df_v42.drop('TOTAL ', axis=1)

re_2_match = re.compile('[0-9]+')
list_IPCC_code_v42 = [elt for elt in df_v42.keys() if re_2_match.match(elt) is not None]
df_v42 = df_set_columns_indexes_as_column_values( df_v42, columns_index=list_IPCC_code_v42, new_col_index=ipcc_name_code, value_index='value')
df_v42 = df_set_column_values_as_columns_indexes( df_v42, 'year', 'value')

# convert years to string in v42
new_column_dict={n: str(n) for n in df_v42.keys() if type(n) == int}
df_v42 = df_v42.rename(columns=new_column_dict)

#-------------------------------------------
# dictionary of IPCC codes
dic_ipcc_codes_des = {key.replace('.',''): val for (key, val) in df_v60.loc[:,('ipcc_code_2006_for_standard_report', 'ipcc_code_2006_for_standard_report_name')].values.tolist() }
dic_ipcc_codes_des.update( {key.replace('.',''): val for (key, val) in df_v50.loc[:,('IPCC', 'IPCC_description')].values.tolist() } )
dic_ipcc_codes_des.update( {key: val for (key, val) in zip( linecache.getline('csv/v4.2_HCFC-142b_2001.csv', 11).replace('"','').split(',')[3:-1], linecache.getline('csv/v4.2_HCFC-142b_2001.csv', 9).replace('"','').split(',')[3:-1])} )

#-------------------------------------------
# harmonization of dataframe index
new_column_dict = {n: n.replace('Y_', '') for n in df_v60.keys()}
new_column_dict['Country_code_A3'] = 'ISO_A3'
new_column_dict['ipcc_code_2006_for_standard_report'] = ipcc_name_code
df_v60 = df_v60.rename(columns=new_column_dict)

df_v50 = df_v50.rename(columns={'IPCC': ipcc_name_code})

keys_final_merge_dataset = ['ISO_A3', 'compound', ipcc_name_code]
for df in [df_v42, df_v60, df_v50]:
    for elt in df.keys():
        if type(elt) == str:
            test = elt
        elif type(elt) == int:
            test = str(elt)
        if re_2_match.match(test) is not None:
            keys_final_merge_dataset.append( elt)
keys_final_merge_dataset = list(set(keys_final_merge_dataset))

df_v42 = df_v42.drop( [elt for elt in df_v42.keys() if not elt in keys_final_merge_dataset], axis=1)
df_v60 = df_v60.drop( [elt for elt in df_v60.keys() if not elt in keys_final_merge_dataset], axis=1)
df_v50 = df_v50.drop( [elt for elt in df_v50.keys() if not elt in keys_final_merge_dataset], axis=1)

#-------------------------------------------
# harmonization of IPCC category code name

# harmonization of IPCC codes, removing '.'
for val in list(set(df_v50[ipcc_name_code])):
    df_v50.loc[ df_v50[ipcc_name_code]==val,ipcc_name_code] = val.replace('.','')
for val in list(set(df_v60[ipcc_name_code])):
    df_v60.loc[ df_v60[ipcc_name_code]==val,ipcc_name_code] = val.replace('.','')

# compare list
code_42=list(set(df_v42[ipcc_name_code]))
code_60=list(set(df_v60[ipcc_name_code]))
code_50=list(set(df_v50[ipcc_name_code]))

code_all = list(set( code_42+code_60+code_50))

print("in 50 not in 60:",  [elt for elt in code_50 if not elt in code_60])
print("in 60 not in 50:",  [elt for elt in code_60 if not elt in code_50])
print("in 42 not in 50:",  [elt for elt in code_42 if not elt in code_50])
print("in 42 not in 60:",  [elt for elt in code_42 if not elt in code_50])

#-------------------------------------------
# merging dataframes

list_elt_42 = list(set(df_v42['compound']))
list_elt_50 = list(set(df_v50['compound']))
list_elt_60 = list(set(df_v60['compound']))

list_42notin60 = [elt for elt in list_elt_42 if not elt in list_elt_60]
list_50notin60 = [elt for elt in list_elt_50 if not elt in list_elt_60]

df_edgar = pd.concat( [ df_v60, df_v42.loc[df_v42['compound'].isin( list_42notin60)], df_v50.loc[df_v50['compound'].isin( list_50notin60)]] )

df_edgar = df_edgar.fillna(0)
df_edgar = df_edgar[df_edgar['ISO_A3'] !=0]
df_edgar_year_selected = df_edgar[ ['ISO_A3', ipcc_name_code, year_selected, 'compound']]

list_compound = list(set(df_edgar['compound']))
list_region = list(set(df_edgar['ISO_A3']))

##################################################################################
# Database diagnostic and analysis
##################################################################################

#-------------------------------------------
# load gtap rules - and complete manually
df_ipccggtap = pd.read_csv('ipcc_2_gtap_dict.csv', sep='|', skiprows=3, header=0)
list_ipcc_code_in_ipccgtap = [elt for elt in df_ipccggtap['IPCC 2006 category code'] if not elt != elt]

code_in_edgar = list(set(df_edgar[ipcc_name_code]))
code_in_edgar.sort()

file1 = open("code_edgar_N_description.txt", "w") 
for elt in code_in_edgar:
    #if not elt in list_ipcc_code_in_ipccgtap and elt in dic_ipcc_codes_des.keys():
    #    print("not in ipccgtap:", elt, dic_ipcc_codes_des[elt])
    #elif not elt in list_ipcc_code_in_ipccgtap:
    #    print("not in ipccgtap:", elt)
    if elt in dic_ipcc_codes_des:
        print(elt, dic_ipcc_codes_des[elt])
        file1.write(elt + " "+ dic_ipcc_codes_des[elt] + "\n")
    else:
        print(elt)
        file1.write(elt+ "\n")
file1.close()

# NOTES on categories to condisered
# 1a*: combustion activities: we already have it in GTAP, from IEA
# 1b: we want fugitive emissions
# We are interrested in all process emissions 2*
# We are not interrested in 3* : Land-use
# We are not interested in 5*: all natural biomass burning and "Forest Land: net carbon stock change" (5FL)
# We are not interested in 4*: Land-use emissions (most of it is antrhopogenic); check what is accounted in the NLU (from FAO I suppose)
#   except may be for
#       4D Wastewater Treatment and Discharge
#       4D3 Indirect N2O from agriculture
#       4E Savanna burning
#       4F Agricultural waste burning
# 6A -> 6D are emissions from waste: we want that, may be aggregated in one, then function of GDP/cap
#   6A Solid waste disposal on land
#   6B Wastewater handling
#   6C Waste incineration
#   6D Other waste handling
# 7 I don't know
#   7A Fossil fuel fires
#   7B Indirect N2O from non-agricultural NOx
#   7C Indirect N2O from non-agricultural NH3
#   7D Other sources

#-------------------------------------------
# check which elements are concerned by IPCC categories

df_2014 = df_edgar[ ['ISO_A3', ipcc_name_code, year_selected, 'compound']]

file1 = open("compound_in_ipcc_cat.txt", "w")
for ippc_cat in code_in_edgar:
    compound_in_ipcc_cat = list()
    for compound in list_compound:
        df = df_2014[ df_2014[ ipcc_name_code] == ippc_cat]
        df = df[ df['compound'] == compound]
        val = df[ year_selected].values.sum()
        if val > 0:
            compound_in_ipcc_cat.append(compound)
    print(ippc_cat, compound_in_ipcc_cat)
    file1.write( ippc_cat +'|' + '|'.join(compound_in_ipcc_cat) + '\n')
file1.close()

### GWPs

# check if we have every GWP
gwp_dict = load_IPCC_gwp_dict('globalwarmingpotentials-main/globalwarmingpotentials.csv', 'AR6GWP100')
gwp_dict[ 'CO2_excl_short-cycle_org_C'] = 1.0
for hfc in [elt for elt in list_compound if ('HFC' in elt or 'HCFC' in elt)] + ['c-C4F8']:
    if hfc.replace('-', '') in gwp_dict.keys():
        gwp_dict[hfc] = gwp_dict[hfc.replace('-', '')]
# completing with Fuglestvedt et al. (2010) - GWP100
gwp_dict['BC'] = 460.0
gwp_dict['OC'] = -69.0
gwp_dict['NMVOC'] = 4.5
gwp_dict['CO'] = 2.65
gwp_dict['NOX'] = -11
gwp_dict['NOx'] = -11

# remaining are aerosols
missing = [elt for elt in list_compound if elt not in gwp_dict.keys()]
print('Not in the GWP dictionary: \n', missing)
for elt in missing:
    gwp_dict[elt] = 0.0

# compute GWP for the year 2014
list_code_2exclude=['1C1','1C2', '1A3b_RES', '1A3b_noRES']
gwp_CO2N2OCH4 = 0
df_gwp=df_edgar.copy()
for elt in list_code_2exclude:
    df_gwp=df_gwp[df_gwp['IPCC_code_2006']!=elt]
# compute global GWP and per category
GWP_ref_dict={}
GWP_ref_dict['Total']=0
for cat in [str(i+1) for i in range(7)]:
    GWP_cat_temp=0
    for code in [elt for elt in code_in_edgar if elt[0] == cat]:
        df_code = df_gwp[ df_gwp['IPCC_code_2006']==code]
        for elt in list_compound:
            df = df_code[ df_code['compound'] == elt][year_selected]
            gwp_temp = (df.values * gwp_dict[ elt]).sum()
            GWP_cat_temp += (df_code[ df_code['compound'] == elt][year_selected].values * gwp_dict[ elt]).sum()
        if elt in ['CH4', 'N20', 'CO2_excl_short-cycle_org_C']:
            gwp_CO2N2OCH4 += gwp_temp
    GWP_ref_dict[cat]=GWP_cat_temp
    GWP_ref_dict['Total'] += GWP_cat_temp

if do_verbose:
    print('GWP CO2 CH4 N2O relatively to all: ', gwp_CO2N2OCH4 / GWP_ref_dict['Total'] *100)

## what is accounted in GTAP Emissions for CO2?
## combustion and process CO2 of EDGAR - 2014
compound = 'CO2_excl_short-cycle_org_C'
emi_combustion = 0
emi_process = 0
for elt in [elt for elt in code_in_edgar if elt[0:2]=='1A']:
    df = df_edgar[ ['ISO_A3', ipcc_name_code, year_selected, 'compound']]
    #df = df[ df['ISO_A3'] != 0] to be removed
    df = df[ df['compound'] == compound]
    df = df[ df[ipcc_name_code]==elt][year_selected]
    emi_combustion += df.values.sum()
for elt in [elt for elt in code_in_edgar if elt[0]=='2']:
    df = df_edgar[ ['ISO_A3', ipcc_name_code, year_selected, 'compound']]
    df = df[ df['compound'] == compound]
    df = df[ df[ipcc_name_code]==elt][year_selected]
    emi_process += df.values.sum()

# from IEA https://www.iea.org/data-and-statistics/data-browser?country=WORLD&fuel=CO2%20emissions&indicator=CO2BySector
# 32463 MtCO2

# import GTAP
gtap_path_emi = '/data/shared/GTAP/results/extracted_GTAP10_'+year_selected+'/Emissions.csv'
input_data_emi, input_dimensions_values_emi, input_data_dimensions_emi = aggregation_GTAP.read_dimensions_tables_file( gtap_path_emi)
# changing dim in MIF
ind_select=[i for i, sec in enumerate(input_dimensions_values_emi['PROD_COMM']) if sec in input_dimensions_values_emi['SEC']]
input_data_emi['MIF'] = input_data_emi['MIF'][:,ind_select,:]
input_data_dimensions_emi['MIF']=input_data_dimensions_emi['Emiss_DomProd']


gtap_co2_emi = 0
for elt in input_data_emi.keys():
    gtap_co2_emi += input_data_emi[elt].sum()

# check region and Iso 2 gtap compatibility
print( 'missing in dict ISO2GTAP_dict', [elt for elt in list_region if not elt in ISO2GTAP_dict.keys()])

# test for C1 and C2
sea_region=df_edgar_year_selected[df_edgar_year_selected['ISO_A3'] == 'SEA'][year_selected].values.sum()
air_region=df_edgar_year_selected[df_edgar_year_selected['ISO_A3'] == 'AIR'][year_selected].values.sum()
sea_sector=df_edgar_year_selected[df_edgar_year_selected['IPCC_code_2006']=='1C2'][year_selected].values.sum()
air_sector=df_edgar_year_selected[df_edgar_year_selected['IPCC_code_2006']=='1C1'][year_selected].values.sum()
# 1C1 and 1C2 are empty
if do_verbose:
    print( sea_region/sea_sector, air_region/air_sector)


##################################################################################
# Database treatment
##################################################################################


#----------------------------------------------------------------------------------------------------------
# track for emissions treeated and exported, in terms of GWP
GWP_ready_for_export_gtap_format=GWP_ref_dict.copy()
GWP_remaining=GWP_ref_dict.copy()
for key in GWP_ready_for_export_gtap_format.keys():
    GWP_ready_for_export_gtap_format[key] *= 0
    GWP_remaining[key] *= 0

#----------------------------------------------------------------------------------------------------------
# We add land-use related emissions, as they accounted for in the Nexus Land-Use from otehr data source
for code in code_in_edgar:
    if code[0] in ['3', '4', '5']:
        df_code=df_edgar_year_selected[df_edgar_year_selected['IPCC_code_2006']==code]
        for elt in list_compound: 
            df_elt=df_code[df_code['compound']==elt][year_selected]
            GWP_ready_for_export_gtap_format[code[0]]+=(df_elt.values * gwp_dict[ elt]).sum()

for key in ['3', '4', '5']:
    GWP_ready_for_export_gtap_format['Total'] += GWP_ready_for_export_gtap_format[key]

if do_verbose:
    print('We did ', GWP_ready_for_export_gtap_format['Total']/GWP_ref_dict['Total'], '% of emissions')

#----------------------------------------------------------------------------------------------------------
# attribute global sea and air emissions to local sector
#----------------------------------------------------------------------------------------------------------

# first we change the sea and air sector of edgar, adding international transports

df_yr_cor = df_edgar_year_selected.copy()
df_yr_cor.reset_index(inplace=True)
df_yr_cor['Region_Gtap'] = df_yr_cor['ISO_A3'].map( {**ISO2GTAP_dict, **{'SEA':'SEA', 'AIR':'AIR'}})
df_yr_cor = df_yr_cor.groupby(['Region_Gtap', year_selected, 'IPCC_code_2006', 'compound']).sum()
df_yr_cor.reset_index(inplace=True)
df_yr_cor = df_yr_cor.drop('index', axis=1)

list_region_gtap = list(set( df_yr_cor['Region_Gtap']))


ind_otp = input_dimensions_values_sam['SEC'].index('otp')
ind_atp = input_dimensions_values_sam['SEC'].index('atp')
ind_wtp = input_dimensions_values_sam['SEC'].index('wtp')

share_exp = (input_data_sam['Exp_trans']+input_data_sam['Exp'])[ ind_atp, :].sum() / input_data_sam['Prod'][ ind_atp, :].sum()                                                         
emi_air_co2 = df_yr_cor[ df_yr_cor['IPCC_code_2006'] == '1A3a']
emi_air_co2 = emi_air_co2[ emi_air_co2['compound'] == 'CO2_excl_short-cycle_org_C']
share_world_emissions = emi_air_co2[ emi_air_co2['Region_Gtap'] == 'AIR'][year_selected].values.sum() / emi_air_co2[year_selected].values.sum()
print("We have ", share_exp, " % of air services for international, which accounts for ", share_world_emissions, "% of emissions")

# can we use CO2 intensity?
energy_local = ((input_data['EDF']+input_data['EIF']).sum(axis=0) * (1-share_exp))[ ind_atp, :]
co2_intensity = 0*energy_local

for country in [elt for elt in list(set(emi_air_co2['Region_Gtap'])) if elt not in ['SEA', 'AIR']]:
    co2_intensity[ input_dimensions_values_sam['REG'].index( country)] = emi_air_co2[ emi_air_co2['Region_Gtap'] == country][year_selected].values.sum() / energy_local[ input_dimensions_values_sam['REG'].index( country)]
print("Mean and Standart Deviation", co2_intensity[ co2_intensity!=0].mean(), co2_intensity[ co2_intensity!=0].std())

# better compute a share in international transport
dic_Ipcccode={'atp':'1A3a', 'wtp':'1A3d'}
dic_edgarSec={'atp':'AIR', 'wtp':'SEA'}

list_compound_temp = list(set(df_yr_cor['compound']))
#list_compound_temp = ['CO2_excl_short-cycle_org_C']

# first construct a global pool:
#for trans in dic_Ipcccode.keys():
#    for compound in list_compound_temp:
#        df_yr_cor.loc[ (df_yr_cor['compound'] == compound) &  (df_yr_cor['Region_Gtap'] == dic_edgarSec[trans]) & (df_yr_cor['IPCC_code_2006'] == dic_Ipcccode[trans]), year_selected ] += df_yr_cor.loc[ (df_yr_cor['compound'] == compound) & (df_yr_cor['IPCC_code_2006'] == dic_Ipcccode[trans]), year_selected].values.sum()
#        df_yr_cor.loc[ (df_yr_cor['compound'] == compound) & (df_yr_cor['IPCC_code_2006'] == dic_Ipcccode[trans]), year_selected] *= 0

# TODO 5A||Indirect N2O emissions from the atmospheric deposition of nitrogen in NOx and NH3|NA|NA not null for AIR

for trans in dic_Ipcccode.keys():    
    ind_trans = input_dimensions_values_sam['SEC'].index(trans)
    trans_share = (input_data_sam['Exp_trans']+input_data_sam['Exp'])[ ind_trans, :] / (input_data_sam['Exp_trans']+input_data_sam['Exp'])[ ind_trans, :].sum()
    # TODO: the share needs to be ameliorated
    #trans_share = (input_data['EDF']+input_data['EIF']).sum(axis=0)[ ind_atp, :] / (input_data['EDF']+input_data['EIF']).sum()
    for compound in list_compound_temp:
        nb_elt=df_yr_cor.loc[ (df_yr_cor['compound'] == compound) &  (df_yr_cor['Region_Gtap'] == dic_edgarSec[trans]) & (df_yr_cor['IPCC_code_2006'] == dic_Ipcccode[trans]), year_selected].shape[0]
        if nb_elt>1:
            print("Got several occurences for", dic_edgarSec[trans], dic_Ipcccode[trans], compound)
        for country in [elt for elt in list_region_gtap if elt not in ['SEA', 'AIR']]:
            df_yr_cor.loc[ (df_yr_cor['compound'] == compound) &  (df_yr_cor['Region_Gtap'] == country) & (df_yr_cor['IPCC_code_2006'] == dic_Ipcccode[trans]), year_selected] += df_yr_cor.loc[ (df_yr_cor['compound'] == compound) &  (df_yr_cor['Region_Gtap'] == dic_edgarSec[trans]) & (df_yr_cor['IPCC_code_2006'] == dic_Ipcccode[trans]), year_selected].values.sum() * trans_share[input_dimensions_values_sam['REG'].index( country)]

# remove Air and Sea from dataframe
df_yr_cor = df_yr_cor[ df_yr_cor['Region_Gtap'] != 'SEA']
df_yr_cor = df_yr_cor[ df_yr_cor['Region_Gtap'] != 'AIR']

#----------------------------------------------------------------------------------------------------------
# Test if we can use the GTAP structure rescaled by EDGAR, by regions
# then filling the same matrixes with (CO2 process, CH4, N20)
#----------------------------------------------------------------------------------------------------------

# Test at the Gtap Region scale
# edgar in GTAP region format:


index_fuel_in_sec = [input_dimensions_values_emi['SEC'].index(elt) for elt in input_dimensions_values_emi['FUEL']]
index_industries_cons = [input_dimensions_values_emi['SEC'].index(elt) for elt in ['oxt','cmt','omt','vol','mil','pcr','sgr','ofd','b_t','tex','wap','lea','lum','ppp','chm','bph','rpp','nmm','i_s','nfm','fmp','ele','eeq','ome','mvh','otn','omf','cns']]
index_sec_1a4 = [input_dimensions_values_emi['SEC'].index(elt) for elt in ['pdr','wht','gro','v_f','osd','c_b','pfb','ocr','ctl','oap','rmk','wol','frs','fsh','wtr','trd','afs','whs','cmn','ofi','ins','rsa','obs','ros','osg','edu','hht','dwe']]

rules = [ ('1A1a', input_dimensions_values_emi['SEC'].index('ely')), ('1A1bc', index_fuel_in_sec), ('1A2', index_industries_cons), ('1A3a', input_dimensions_values_emi['SEC'].index('atp')), ('1A3d', input_dimensions_values_emi['SEC'].index('wtp')) ]

for country in [elt for elt in list_region_gtap if elt not in ['SEA', 'AIR']]:
    df_country = df_yr_cor[ df_yr_cor['Region_Gtap'] == country]
    df_country = df_country[ df_country['compound'] == 'CO2_excl_short-cycle_org_C']
    for ipcc_code, sector_output_gtap in rules:
        rescale_factor = 1.0/Mt_2_Gg* df_country[ df_country['IPCC_code_2006'] == ipcc_code][ year_selected].values.sum() / (input_data_emi['Emiss_DomProd'][:, sector_output_gtap, input_dimensions_values_emi['REG'].index( country)].sum() + input_data_emi['MIF'][:, sector_output_gtap, input_dimensions_values_emi['REG'].index( country)].sum() )
        if do_verbose:
            print(rescale_factor)
    if do_verbose:
        print('\n')

# Test at the Imaclim Region scale
# import GTAP
gtap_path_emi = 'GTAP_Emissions/outputs_GTAP10_'+year_selected+'/GTAP_Emisions__EdgarSector_ImaclimRegion_agg__GTAP10_'+year_selected+'.csv'
input_data_emi_Im, input_dimensions_values_emi_Im, input_data_dimensions_emi_Im = aggregation_GTAP.read_dimensions_tables_file( gtap_path_emi)
# changing dim in MIF
ind_select=[i for i, sec in enumerate(input_dimensions_values_emi_Im['PROD_COMM']) if sec in input_dimensions_values_emi_Im['SEC']]
input_data_emi_Im['MIF'] = input_data_emi_Im['MIF'][:,ind_select,:]
input_data_dimensions_emi_Im['MIF']=input_data_dimensions_emi_Im['Emiss_DomProd']

# edgar in Imaclim region format:
df_yr_cor_Im = df_yr_cor.copy()
df_yr_cor_Im.reset_index(inplace=True)
df_yr_cor_Im['Region_Im'] = list(map(lambda x: Gtap2Imaclim_dict[x], df_yr_cor_Im['Region_Gtap']))
df_yr_cor_Im = df_yr_cor_Im.groupby(['Region_Im', year_selected, 'IPCC_code_2006', 'compound']).sum()
df_yr_cor_Im.reset_index(inplace=True)

list_regions_Im = list(set(df_yr_cor_Im['Region_Im']))

for country in [elt for elt in list_regions_Im if elt not in ['SEA', 'AIR']]:
    df_country = df_yr_cor_Im[ df_yr_cor_Im['Region_Im'] == country]
    df_country = df_country[ df_country['compound'] == 'CO2_excl_short-cycle_org_C']
    for ipcc_code, sector_output_gtap in rules:
        rescale_factor = 1.0/Mt_2_Gg* df_country[ df_country['IPCC_code_2006'] == ipcc_code][ year_selected].values.sum() / (input_data_emi_Im['Emiss_DomProd'][:, sector_output_gtap, input_dimensions_values_emi_Im['REG'].index( country)].sum() + input_data_emi_Im['MIF'][:, sector_output_gtap, input_dimensions_values_emi_Im['REG'].index( country)].sum() )
        if do_verbose:
            print(rescale_factor)
# is it a pb of scale ? first agg edgar towards GTAP
    if do_verbose:
        print('\n')
# ->> This is ok for the 3 first rules (not Air and Sea) for the 12 region Imaclim


#----------------------------------------------------------------------------------------------------------
# Rescaling CO2 from combustion
#----------------------------------------------------------------------------------------------------------
# If we recale every variable at prorata of sum: It wil be ok with aggregation (large differences between regions but ok when doing the sum)


input_data_emi_rescaled = copy.deepcopy(input_data_emi)
input_data_dimensions_emi_rescaled = copy.deepcopy(input_data_dimensions_emi)
input_dimensions_values_emi_rescaled = copy.deepcopy(input_dimensions_values_emi)

# rules above include:
#1A1A||Fuel Combustion Activities: Main Activity Electricity and Heat Production|coa,oil,gas,p_c,gdt|ely
#1A1BC||Fuel Combustion Activities: Petroleum Refining; Manufacture of Solid Fuels and Other Energy Industries|coa,oil,gas,p_c,gdt|coa,oil,gas,p_c,gdt
#1A2||Fuel Combustion Activities: Manufacturing Industries and Construction|coa,oil,gas,p_c,gdt|oxt,cmt,omt,vol,mil,pcr,sgr,ofd,b_t,tex,wap,lea,lum,ppp,chm,bph,rpp,nmm,i_s,nfm,fmp,ele,eeq,ome,mvh,otn,omf,cns
#1A3A||Fuel Combustion Activities: Civil Aviation|coa,oil,gas,p_c,gdt|atp
#1A3D||Fuel Combustion Activities: Waterborne Navigation|coa,oil,gas,p_c,gdt|wtp

#special cases for 
#1A4||Fuel Combustion Activities: Other Sectors|coa,oil,gas,p_c,gdt|pdr,wht,gro,v_f,osd,c_b,pfb,ocr,ctl,oap,rmk,wol,frs,fsh,wtr,trd,afs,whs,cmn,ofi,ins,rsa,obs,ros,osg,edu,hht,dwe,HHs
#1A3B||Fuel Combustion Activities: Road|coa,oil,gas,p_c,gdt|otp,HHs
#1A3C||Fuel Combustion Activities: Railways|coa,oil,gas,p_c,gdt|otp
#1A3E||Fuel Combustion Activities: Other Transportation|coa,oil,gas,p_c,gdt|otp
#1A5||Fuel Combustion Activities: Non-Specified|coa,oil,gas,p_c,gdt|wtr,trd,afs,whs,cmn,ofi,ins,rsa,obs,ros,osg,edu,hht,dwe

list_pdr_fsh = ['pdr','wht','gro','v_f','osd','c_b','pfb','ocr','ctl','oap','rmk','wol','frs','fsh']
list_wtr_dwe = ['wtr','trd','afs','whs','cmn','ofi','ins','rsa','obs','ros','osg','edu','hht','dwe']

sector_output_gtap__pdr_fsh=[input_dimensions_values_emi['SEC'].index(sec) for sec in list_pdr_fsh]
sector_output_gtap__wtr_dwe=[input_dimensions_values_emi['SEC'].index(sec) for sec in list_wtr_dwe]
sector_output_gtap__pdr_fsh_wtr_dwe=sector_output_gtap__pdr_fsh+sector_output_gtap__wtr_dwe
sector_output_gtap__pdr_fsh_wtr_dwe_otp=sector_output_gtap__pdr_fsh_wtr_dwe+[ind_otp]

#check sector if some are missing
list_ind = index_industries_cons + index_fuel_in_sec + sector_output_gtap__pdr_fsh + sector_output_gtap__wtr_dwe + [ind_otp, ind_atp, ind_wtp, input_dimensions_values_emi['SEC'].index('ely')]
list_ind=list(set(list_ind))
missing_ind=[ii for ii in range(len(input_dimensions_values_emi['SEC'])) if ii not in list_ind]
# nothing is missing

# check before rescale:
edgar_comb_1=0
gtap_comb_1=0
for ipcc_code, sector_output_gtap in rules:
    df_compound=df_yr_cor[df_yr_cor['compound'] == 'CO2_excl_short-cycle_org_C']
    edgar_comb_1+=1.0/Mt_2_Gg* df_compound[ df_compound['IPCC_code_2006'] == ipcc_code][ year_selected].values.sum()
    gtap_comb_1+=(input_data_emi_rescaled['Emiss_DomProd']+input_data_emi_rescaled['MIF'])[:,sector_output_gtap,:].sum()
gtap_comb_2=(input_data_emi_rescaled['Emiss_DomProd']+input_data_emi_rescaled['MIF'])[:,sector_output_gtap__pdr_fsh_wtr_dwe_otp,:].sum()+(input_data_emi_rescaled['MDP']+input_data_emi_rescaled['MIP']).sum()
edgar_comb_2=0
for sec in ['1A5', '1A3e', '1A3c', '1A3b', '1A4']:
    df_compound=df_yr_cor[df_yr_cor['compound'] == 'CO2_excl_short-cycle_org_C']
    edgar_comb_2+=1.0/Mt_2_Gg* df_compound[ df_compound['IPCC_code_2006'] == sec][ year_selected].values.sum()

if do_verbose:
    print('C1', edgar_comb_1/ gtap_comb_1)
    print('C2', edgar_comb_2/ gtap_comb_2)
    print('C1+C2', (edgar_comb_2+edgar_comb_1)/(gtap_comb_1+gtap_comb_2))
    print('C1/C2', edgar_comb_1/edgar_comb_2, gtap_comb_1/gtap_comb_2)

for country in [elt for elt in list_region_gtap if elt not in ['SEA', 'AIR']]:
    df_country = df_yr_cor[ df_yr_cor['Region_Gtap'] == country]
    df_country = df_country[ df_country['compound'] == 'CO2_excl_short-cycle_org_C']
    #rules
    for ipcc_code, sector_output_gtap in rules:
        rescale_factor = 1.0/Mt_2_Gg* df_country[ df_country['IPCC_code_2006'] == ipcc_code][ year_selected].values.sum() / (input_data_emi['Emiss_DomProd'][:, sector_output_gtap, input_dimensions_values_emi['REG'].index( country)].sum() + input_data_emi['MIF'][:, sector_output_gtap, input_dimensions_values_emi['REG'].index( country)].sum() )
        if rescale_factor.shape !=0:
            input_data_emi_rescaled['Emiss_DomProd'][:,:,input_dimensions_values_emi['REG'].index( country)][:,sector_output_gtap] *= rescale_factor
            input_data_emi_rescaled['MIF'][:,:,input_dimensions_values_emi['REG'].index( country)][:,sector_output_gtap] *= rescale_factor
    #special cases
    # Methods: first compute the sectoral attribution based on market share comaprison (Edgar and GTAP), then rescale.
    tot_edgar_special_cases = 0
    for sec in ['1A5', '1A3e', '1A3c', '1A3b', '1A4']:
        tot_edgar_special_cases += 1.0/Mt_2_Gg* df_country[ df_country['IPCC_code_2006'] == sec][ year_selected].values.sum()
    tot_gtap_special = ((input_data_emi['Emiss_DomProd']+input_data_emi['MIF'])[:,sector_output_gtap__pdr_fsh_wtr_dwe_otp,:].sum(axis=1) + (input_data_emi['MDP']+input_data_emi['MIP']) )[:,input_dimensions_values_emi['REG'].index( country)].sum()
    # OTP (1A3c, 1A3e, 1A3b)
    otp_in_1A3e_1A3c =  1.0/Mt_2_Gg*( df_country[ df_country['IPCC_code_2006'] == '1A3c'][ year_selected].values.sum() + df_country[ df_country['IPCC_code_2006'] == '1A3e'][ year_selected].values.sum())
    share_otp_gtap = ((input_data_emi['Emiss_DomProd']+input_data_emi['MIF'])[:,ind_otp,:] )[:,input_dimensions_values_emi['REG'].index( country)].sum() / tot_gtap_special
    otp_in_1A3b = share_otp_gtap * tot_edgar_special_cases - otp_in_1A3e_1A3c
    # HHs in 1A3b
    HHs_in_1A3b = 1.0/Mt_2_Gg* df_country[ df_country['IPCC_code_2006'] == '1A3b'][ year_selected].values.sum() - otp_in_1A3b
    # wtr_dwe (1A5, 1A4)
    wtr_dwe_in_1A5 = 1.0/Mt_2_Gg*df_country[ df_country['IPCC_code_2006'] == '1A5'][ year_selected].values.sum()
    share_wtr_dwe_gtap = (input_data_emi['Emiss_DomProd']+input_data_emi['MIF'])[:,sector_output_gtap__wtr_dwe,input_dimensions_values_emi['REG'].index( country)].sum() / tot_gtap_special
    wtr_dwe_in_1A4 = share_wtr_dwe_gtap * tot_edgar_special_cases - wtr_dwe_in_1A5
    # pdr_fsh in 1A4
    share_pdr_fsh_gtap = (input_data_emi['Emiss_DomProd']+input_data_emi['MIF'])[:,sector_output_gtap__pdr_fsh,input_dimensions_values_emi['REG'].index( country)].sum() / tot_gtap_special
    pdr_fsh_in_1A4 = share_pdr_fsh_gtap * tot_edgar_special_cases
    HHs_in_1A4 = 1.0/Mt_2_Gg* df_country[ df_country['IPCC_code_2006'] == '1A4'][ year_selected].values.sum() - wtr_dwe_in_1A4 - pdr_fsh_in_1A4
    for ind_list, val_edgar in [ ([ind_otp], otp_in_1A3e_1A3c+otp_in_1A3b), (sector_output_gtap__wtr_dwe, wtr_dwe_in_1A5+wtr_dwe_in_1A4), (sector_output_gtap__pdr_fsh, pdr_fsh_in_1A4)]:
        rescale_factor = val_edgar / ((input_data_emi['Emiss_DomProd']+input_data_emi['MIF'])[:,ind_list,:].sum(axis=1)[:,input_dimensions_values_emi['REG'].index( country)].sum())
        if rescale_factor==np.nan: rescale_factor=1
        if rescale_factor==0: rescale_factor=1
        input_data_emi_rescaled['Emiss_DomProd'][:,ind_list,input_dimensions_values_emi['REG'].index( country)] *= rescale_factor
        input_data_emi_rescaled['MIF'][:,ind_list,input_dimensions_values_emi['REG'].index( country)] *= rescale_factor
    if rescale_factor==np.nan: rescale_factor=1
    if rescale_factor==0: rescale_factor=1
    rescale_factor = (HHs_in_1A3b+HHs_in_1A4) / (input_data_emi['MDP']+input_data_emi['MIP'])[:,input_dimensions_values_emi['REG'].index( country)].sum()
    input_data_emi_rescaled['MDP'][:,input_dimensions_values_emi['REG'].index( country)] *= rescale_factor
    input_data_emi_rescaled['MIP'][:,input_dimensions_values_emi['REG'].index( country)] *= rescale_factor

# check after rescale:
edgar_comb_1=0
gtap_comb_1=0
for ipcc_code, sector_output_gtap in rules:
    df_compound=df_yr_cor[df_yr_cor['compound'] == 'CO2_excl_short-cycle_org_C']
    edgar_comb_1+=1.0/Mt_2_Gg* df_compound[ df_compound['IPCC_code_2006'] == ipcc_code][ year_selected].values.sum()
    gtap_comb_1+=(input_data_emi_rescaled['Emiss_DomProd']+input_data_emi_rescaled['MIF'])[:,sector_output_gtap,:].sum()
gtap_comb_2=(input_data_emi_rescaled['Emiss_DomProd']+input_data_emi_rescaled['MIF'])[:,sector_output_gtap__pdr_fsh_wtr_dwe_otp,:].sum()+(input_data_emi_rescaled['MDP']+input_data_emi_rescaled['MIP']).sum()
edgar_comb_2=0
for sec in ['1A5', '1A3e', '1A3c', '1A3b', '1A4']:
    df_compound=df_yr_cor[df_yr_cor['compound'] == 'CO2_excl_short-cycle_org_C']
    edgar_comb_2+=1.0/Mt_2_Gg* df_compound[ df_compound['IPCC_code_2006'] == sec][ year_selected].values.sum()

if do_verbose:
    print('C1', edgar_comb_1/ gtap_comb_1)
    print('C2', edgar_comb_2/ gtap_comb_2)
    print('C1+C2', (edgar_comb_2+edgar_comb_1)/(gtap_comb_1+gtap_comb_2))
    print('C1/C2', edgar_comb_1/edgar_comb_2, gtap_comb_1/gtap_comb_2)

# add CO2 from FF combustion to the GWP pool
for elt in input_data_emi_rescaled.keys():
    GWP_ready_for_export_gtap_format['1'] += Mt_2_Gg*input_data_emi_rescaled[elt].sum()*gwp_dict[ 'CO2_excl_short-cycle_org_C']
GWP_ready_for_export_gtap_format['Total'] += GWP_ready_for_export_gtap_format['1']
if do_verbose:
    print('We did ', GWP_ready_for_export_gtap_format['Total']/GWP_ref_dict['Total'], '% of emissions')

#-------------------------------------------
# Process emissions (CO2 and Non-CO2)
#----------------------------------------------------------------------------------------------------------

#add process emission to the GTAP structure of input_data_emi_rescaled
list_compound_process=list()
for elt in list_compound:
    df_elt=df_yr_cor[df_yr_cor['compound'] ==elt]
    sum_values=0
    for code in [code for code in code_in_edgar if code[0]=='2']:
        val=df_elt[df_elt['IPCC_code_2006']==code][year_selected].values.sum()
        #CO2 analysis:
        if 'CO2' in elt and do_verbose:
            print('CO2 in ', code, val)
        sum_values += val
    if sum_values!=0:
        list_compound_process.append(elt)
for elt in list_compound_process:
    input_data_emi_rescaled['Emi_Process_'+elt]=np.zeros(input_data_sam['Prod'].shape)
    input_data_dimensions_emi_rescaled['Emi_Process_'+elt]=input_data_dimensions_sam['Prod'].copy()

# IPCC AR5 WG3 p749
#"As shown in Table 10.3, industrial CO 2 emissions were 13.14 GtCO 2 in 2010. These emissions were comprised of 5.27 GtCO 2 direct energy-related emissions, 5.25 GtCO 2 indirect emissions from electricity and heat production, 2.59 GtCO 2 from process CO 2 emissions and 0.03 GtCO 2 from waste / wastewater. Process CO 2 emissions are comprised of process-related emissions of 1.352 GtCO 2 from cement production, 6 0.477 GtCO 2 from production of chemicals, 0.242 GtCO 2 from lime production, 0.134 GtCO 2 from coke ovens, 0.074 GtCO 2 from non-ferrous metals production, 0.072 GtCO 2 from iron and steel production, 0.061 GtCO 2 from ferroalloy production, 0.060 GtCO 2 from lime-stone and dolomite use, 0.049 GtCO 2 from solvent and other product use, 0.042 GtCO 2 from production of other minerals and 0.024 GtCO 2 from non-energy use of lubricants / waxes (JRC / PBL, 2013).

# Coke ovens are included in the 2C category
share_world_CO2_Ferous_TotalMetal = (0.134+0.072+0.061)/(0.134+0.072+0.061+0.074)
share_world_Value_Ferous_TotalMetal = input_data_sam['Prod'][ input_dimensions_values_sam['SEC'].index('i_s'),:].sum() / (input_data_sam['Prod'][ input_dimensions_values_sam['SEC'].index('i_s'),:].sum() + input_data_sam['Prod'][ input_dimensions_values_sam['SEC'].index('nfm'),:].sum())
share_value_CO2_Ferous_TotalMetal = share_world_CO2_Ferous_TotalMetal / share_world_Value_Ferous_TotalMetal

# Emissions associated to processes

#2A1 Cement production
#2A2 Lime production
#2A3 Glass Production
#??2A4 Other Process Uses of Carbonates
#2C Production of metals
#2A7 Production of other minerals
#2B Production of chemicals
#2F7 Semiconductor/Electronics Manufacture
#2F8 Electrical Equipment

process_rules={'2A1':'nmm', '2A2':'nmm', '2B': 'chm', '2F7':'ele', '2F8':'ome', '2A7':'nmm', '2A3':'nmm', '2A4':'nmm', '2C': ['i_s','nfm'],'2D': ['b_t','ppp']}

for elt in list_compound_process:
    df_comp = df_yr_cor[ df_yr_cor['compound']==elt]
    for country in [elt for elt in list_region_gtap if elt not in ['SEA', 'AIR']]:
        df_country = df_comp[ df_comp['Region_Gtap'] == country]
        for code in process_rules.keys():
            # if one sector, simple attribution
            if type(process_rules[code])==str:
                input_data_emi_rescaled['Emi_Process_'+elt][input_dimensions_values_emi['SEC'].index( process_rules[code]),input_dimensions_values_emi['REG'].index( country)] += 1.0/Mt_2_Gg*df_country[ df_country['IPCC_code_2006'] == code][ year_selected].values.sum()
            #if list of sectors, at pro rata of 
            reg=input_dimensions_values_sam['REG'].index(country)
            if code=='2C':
                share_value_Ferous_TotalMetal = input_data_sam['Prod'][ input_dimensions_values_sam['SEC'].index('i_s'),reg].sum() / (input_data_sam['Prod'][ input_dimensions_values_sam['SEC'].index('i_s'),reg].sum() + input_data_sam['Prod'][ input_dimensions_values_sam['SEC'].index('nfm'),reg].sum())
                share_CO2_Ferous = share_value_CO2_Ferous_TotalMetal * share_value_Ferous_TotalMetal
                input_data_emi_rescaled['Emi_Process_'+elt][input_dimensions_values_emi['SEC'].index( 'i_s'),reg] += share_CO2_Ferous*1.0/Mt_2_Gg*df_country[ df_country['IPCC_code_2006'] == code][ year_selected].values.sum()
                input_data_emi_rescaled['Emi_Process_'+elt][input_dimensions_values_emi['SEC'].index( 'nfm'),reg] += (1-share_CO2_Ferous)*1.0/Mt_2_Gg*df_country[ df_country['IPCC_code_2006'] == code][ year_selected].values.sum()
            if code=='2D':
                share_value_ppp = input_data_sam['Prod'][ input_dimensions_values_sam['SEC'].index('ppp'),reg].sum() / (input_data_sam['Prod'][ input_dimensions_values_sam['SEC'].index('b_t'),reg].sum() + input_data_sam['Prod'][ input_dimensions_values_sam['SEC'].index('ppp'),reg].sum())
                input_data_emi_rescaled['Emi_Process_'+elt][input_dimensions_values_emi['SEC'].index( 'b_t'),reg] += (1-share_value_ppp)*1.0/Mt_2_Gg*df_country[ df_country['IPCC_code_2006'] == code][ year_selected].values.sum()
                input_data_emi_rescaled['Emi_Process_'+elt][input_dimensions_values_emi['SEC'].index( 'ppp'),reg] += share_value_ppp*1.0/Mt_2_Gg*df_country[ df_country['IPCC_code_2006'] == code][ year_selected].values.sum()

# Emissions of consumption of industiral goods.. we do not make an association with one sector
# aggregated by compound

#2D Production of pulp/paper/food/drink
#2E Production of halocarbons and SF6
#2F1 Refrigeration and Air Conditioning
#2F2 Foam Blowing
#2F3 Fire Extinguishers
#2F4 Aerosols
#2F5 F-gas as Solvent
#2F9 Other F-gas use
#2G Non-energy use of lubricants/waxes (CO2)
#2H Other


for elt in list_compound_process:
    input_data_emi_rescaled['Emi_Process_Other_'+elt] = np.zeros( (len(input_dimensions_values_sam['REG'])))
    input_data_dimensions_emi_rescaled['Emi_Process_Other_'+elt] = ['REG']
    df_comp = df_yr_cor[ df_yr_cor['compound']==elt]
    for country in [elt for elt in list_region_gtap if elt not in ['SEA', 'AIR']]:
        df_country = df_comp[ df_comp['Region_Gtap'] == country]
        val=0
        for code in [elt for elt in code_in_edgar if ( elt[0]=='2' and not elt in process_rules.keys())]:
            val += 1.0/Mt_2_Gg*df_country[ df_country['IPCC_code_2006'] == code][ year_selected].values.sum()
        input_data_emi_rescaled['Emi_Process_Other_'+elt][input_dimensions_values_sam['REG'].index(country)] += val        
    

# add process emissions to the GWP pool
GWP_process=0
for elt in list_compound_process:
    GWP_process+= Mt_2_Gg*input_data_emi_rescaled['Emi_Process_'+elt].sum() * gwp_dict[ elt]
    GWP_process+= Mt_2_Gg*input_data_emi_rescaled['Emi_Process_Other_'+elt].sum() * gwp_dict[ elt]

GWP_ready_for_export_gtap_format['2']=GWP_process
GWP_ready_for_export_gtap_format['Total']+=GWP_process
if do_verbose:
    print('We did ', GWP_ready_for_export_gtap_format['Total']/GWP_ref_dict['Total'], '% of emissions')

# missing 2
#for elt in list_compound_process:
#    df_comp = df_yr_cor[ df_yr_cor['compound']==elt]
#    for code in [elt for elt in code_in_edgar if ( elt[0]=='2' and not elt in process_rules.keys())]:
#        GWP_remaining['2']+=df_comp[ df_comp['IPCC_code_2006'] == code][ year_selected].values.sum() * gwp_dict[ elt]    


#-------------------------------------------
# Fugitive Non-CO2 treatment:
#----------------------------------------------------------------------------------------------------------

#1B1 Fugitive emissions from solid fuels
#1B2 Fugitive emissions from oil and gas
for elt in list_compound:
    for code in ['1B1','1B2']:
        df_elt=df_edgar_year_selected[df_edgar_year_selected['compound']==elt]
        val=df_elt[df_elt['IPCC_code_2006']==code][year_selected].values.sum()
        if do_verbose:
            print(code, elt, val)
#NH3 for coal but not for oil and gas

# dictionnary of oil share if oil and gas fugitive emissions
default_weight=0.5
dict_weight={}
for elt in ['PM10','BC','PM2.5','CO','OC','N2O','NOx','SO2','NH3']:
    dict_weight[elt]=default_weight

barrel_2_m3=158.987294928*1e-3
barrel_2_EJ=6.1178632*1e9*1e-18
EJ_2_bcm=(41.4+38.2)/2 *1e-3
EJ_2_m3=EJ_2_bcm/1e9

co2_oil_prod_m3 = (9e-3+1e-4+1.9e-6)/1e3 #Gg/m3
co2_gas_prod_m3  = (1.2e-3+4.8e-5)/1e6 #Gg/m3
co2_gas_prod_m3  = (8.8e-7+3.1e-6+1.1e-7)/1e6 #Gg/m3

ch4_oil_prod_m3 = (3.3e-5+5.1e-5+1.1e-4)/1e3 #Gg/m3
ch4_gas_prod_m3  = (1.34e-3+7.6e-7)/1e6 #Gg/m3
ch4_gas_prod_m3  = (2.73e-4+1.82e-4+2.5e-5)/1e6 #Gg/m3

dict_weight['CO2_excl_short-cycle_org_C'] = (co2_oil_prod_m3*barrel_2_m3/barrel_2_EJ) / (co2_oil_prod_m3*barrel_2_m3/barrel_2_EJ + (co2_gas_prod_m3+co2_gas_prod_m3)/EJ_2_m3)
dict_weight['CH4'] = (ch4_oil_prod_m3*barrel_2_m3/barrel_2_EJ) / (ch4_oil_prod_m3*barrel_2_m3/barrel_2_EJ + (ch4_gas_prod_m3+ch4_gas_prod_m3)/EJ_2_m3)

# we assume all flared CH4 is due to oil activity (real figure computed : 0.9991318429152376)
dict_weight['CO2_excl_short-cycle_org_C']=1

input_data['Prod_Ener'] = input_data['EDF'].sum(axis=1) + input_data['EDG']  + input_data['EDP']

ind_oil = input_dimensions_values['ERG_COMM'].index('oil')
ind_gas = input_dimensions_values['ERG_COMM'].index('gas')

# attribution
for elt in list(dict_weight.keys())+['NH3']:
    for fossil in ['oil', 'gas', 'coal']:   
        input_data_emi_rescaled['Emi_fugi_'+elt+'_'+fossil] = np.zeros( (len(input_dimensions_values_sam['REG'])))
        input_data_dimensions_emi_rescaled['Emi_fugi_'+elt+'_'+fossil] = ['REG']
    df_comp = df_yr_cor[ df_yr_cor['compound']==elt]
    # coal
    code='1B1'
    df_code = df_comp[df_comp['IPCC_code_2006'] == code]
    for country in [elt for elt in list_region_gtap if elt not in ['SEA', 'AIR']]:
        ind_country = input_dimensions_values['REG'].index(country)
        input_data_emi_rescaled['Emi_fugi_'+elt+'_coal'][ind_country] += 1/Mt_2_Gg*df_code[ df_code['Region_Gtap'] == country][ year_selected].values.sum()
    # oil and gas
    code='1B2'
    df_code = df_comp[df_comp['IPCC_code_2006'] == code]
    for country in [elt for elt in list_region_gtap if elt not in ['SEA', 'AIR']]:
        ind_country = input_dimensions_values['REG'].index(country)
        share_ener_oil = input_data['Prod_Ener'][ind_oil,ind_country] / (input_data['Prod_Ener'][ind_oil,ind_country] + input_data['Prod_Ener'][ind_gas,ind_country])
        key_ener_oil = dict_weight[elt]*share_ener_oil / ( dict_weight[elt]*share_ener_oil + (1-dict_weight[elt])*(1-share_ener_oil))
        val = df_code[ df_code['Region_Gtap'] == country][ year_selected].values.sum()
        input_data_emi_rescaled['Emi_fugi_'+elt+'_oil'][ind_country] += 1/Mt_2_Gg*key_ener_oil * val 
        input_data_emi_rescaled['Emi_fugi_'+elt+'_gas'][ind_country] += 1/Mt_2_Gg*(1-key_ener_oil)*val


# adding non-CO2 emissions for fossil fuels to GWP
for code in code_in_edgar:
    if code[0:2]=='1B':
        df_code=df_edgar_year_selected[df_edgar_year_selected['IPCC_code_2006']==code]
        for elt in [elt for elt in list_compound if not 'CO2' in elt]:
            df_elt=df_code[df_code['compound']==elt][year_selected]
            GWP_ready_for_export_gtap_format['1']+=(df_elt.values * gwp_dict[ elt]).sum()
            GWP_ready_for_export_gtap_format['Total']+=(df_elt.values * gwp_dict[ elt]).sum()

#-------------------------------------------
# Non-CO2 from combustion:
#----------------------------------------------------------------------------------------------------------

#------------------------------
# analysis

# non-CO2 from combustion
dic_temp_nonCO2={}
for elt in [elt for elt in list_compound if not 'CO2' in elt]:
    dic_temp_nonCO2[elt]=0
for code in code_in_edgar:
    if code[0:2]=='1A':
        df_code=df_edgar_year_selected[df_edgar_year_selected['IPCC_code_2006']==code]
        for elt in [elt for elt in list_compound if not 'CO2' in elt]:
            df_elt=df_code[df_code['compound']==elt][year_selected]
            dic_temp_nonCO2[elt]+=(df_elt.values * gwp_dict[ elt]).sum()
# 'CH4': 403026.74169472675,
# 'NOx': -1297952.623986635,
# 'NMVOC': 304727.49257512594,
# 'OC': -625179.9670819718,
# 'N2O': 264722.50254712935,
# 'CO': 1167820.2550096055,
# 'BC': 2051658.024968674,
# a pb: there is no SO2 emissions

#https://doi.org/10.1016/S1750-5836(07)00019-9
coal_ch4 = 1 #mg/MJ
coal_n2o = 16 #mg/MJ
#http://dx.doi.org/10.1016/j.enpol.2012.11.010
coal_co2 = 25.00 #kg/GJ
gas_co2 = 15.00 #kg/GJ
coal_nox = 0.196
gas_nox = 0.040
coal_so2 = 0.240
coal_bc = 0.040
coal_co = 0.089
gas_co = 0.017

# total CO2 from coal combustion:
tot_emi_co2_coal_comb=0
ind_coal=input_dimensions_values_emi['FUEL'].index('coa')
for elt in ['Emiss_DomProd', 'MIF']:
    tot_emi_co2_coal_comb += input_data_emi_rescaled[elt][ind_coal,:,:].sum()
for elt in ['MDP', 'MDG', 'MIG', 'MIP']:
    tot_emi_co2_coal_comb += input_data_emi_rescaled[elt][ind_coal,:].sum()

# analysis by code
for elt in ['CH4', 'NOx', 'NMVOC', 'OC', 'N2O', 'CO', 'BC']:
    df_elt=df_edgar_year_selected[df_edgar_year_selected['compound']==elt]
    for code in [code for code in code_in_edgar if code[0:2]=='1A']:
        df_code=df_elt[df_elt['IPCC_code_2006']==code][year_selected]
        if do_verbose:
            print(elt, code, (df_code.values * gwp_dict[ elt]).sum()/dic_temp_nonCO2[elt]*100)

#------------------------------
# attribution case by case:
dict_code={'1A4':'Residential', '1A1a':'Electricity', '1A2': 'Manufacturing and construction', '1A3b_noRES': 'Road transporation', '1A3d': 'Shipping', '1A1bc': 'Other energy industries'}
dict_code_key=list(dict_code.keys())
new_dim_sector_nonCO2 = ['Residential']

dict_array={}
size_array = ( len(input_dimensions_values_emi['FUEL']), len(input_dimensions_values_emi['REG']), len(dict_code) )
for elt in dic_temp_nonCO2.keys():
    dict_array[elt] = np.zeros( size_array)

# rule for major activity for non-CO2, coming from coal (based on observed figures)
# could have been produced automatically based on a threshold (for excample, 10%)
major_activities = {'CH4': ['1A4'], 'NOx': ['1A1a', '1A2', '1A3b_noRES', '1A3d'], 'NMVOC': ['1A2', '1A3b_noRES', '1A4'], 'OC': ['1A2', '1A4'], 'N2O': ['1A1a', '1A2', '1A3b_noRES', '1A4'], 'CO': ['1A2', '1A3b_noRES',  '1A4'], 'BC': ['1A1bc', '1A2',  '1A3b_noRES',  '1A3d', '1A4']}

# creating rule with assumption on which activity is coal, oil of liquid fuels
dict_activity_fuel = {'1A4':'coa', '1A1a':'coa', '1A2':'coa', '1A3b_noRES':'p_c', '1A3d':'p_c', '1A1bc':'oil'}

# actual attribution job:
for fuel in ['coa', 'oil', 'p_c']:
    # create en activity dict for GHG
    dict_act_ghg = {}
    for ghg in major_activities.keys():
        list_act=[]
        for elt in major_activities[ghg]:
            if dict_activity_fuel[elt] == fuel:
                list_act.append( elt)
        if len(list_act)>0:
            dict_act_ghg[ghg] = list_act
    # attribution
    ind_fuel = input_dimensions_values_emi['FUEL'].index(fuel)
    for compound in dict_act_ghg.keys():
        df_compound=df_yr_cor[df_yr_cor['compound']==compound]  
        for code in dict_act_ghg[compound]:
            df_code=df_compound[df_compound['IPCC_code_2006']==code]
            for country in [elt for elt in list_region_gtap if elt not in ['SEA', 'AIR']]:
                dict_array[compound][ind_fuel,input_dimensions_values_emi['REG'].index(country), dict_code_key.index(code)] += df_code[ df_code['Region_Gtap'] == country][ year_selected].values.sum()
# --- CH4 ---
# for examplen, the code above does, for CH4:
#elt, code = 'CH4', '1A4'
#df_elt=df_edgar_year_selected[df_edgar_year_selected['compound']==elt]
#df_code=df_elt[df_elt['IPCC_code_2006']==code]
#for country in [elt for elt in list_region_gtap if elt not in ['SEA', 'AIR']]:
#    dict_array[elt][ind_coal,len(input_dimensions_values_emi['REG'], dict_code_key.index(code)] += df_code[ df_code['Region_Gtap'] == country][ year_selected].values.sum() 

# store into main dictionnary and update GWP dictionnaries
input_dimensions_values_emi_rescaled['Activity_nonCO2_combustion'] = [dict_code[elt].replace(' ', '_') for elt in dict_code_key]
main_dim=['FUEL', 'REG', 'Activity_nonCO2_combustion']
for compound in major_activities.keys():
    input_data_emi_rescaled['Combustion_'+compound] = 1/Mt_2_Gg*dict_array[compound]
    input_data_dimensions_emi_rescaled['Combustion_'+compound] = main_dim
    val = dict_array[compound].sum() * gwp_dict[ compound]
    GWP_ready_for_export_gtap_format['1']+= val
    GWP_ready_for_export_gtap_format['Total'] += val
    GWP_remaining['1'] = dic_temp_nonCO2[compound] - val

#-------------------------------------------
# Summary:
#----------------------------------------------------------------------------------------------------------

# remaining from 6 and 7
for code in code_in_edgar:
    if code[0] in ['6', '7']:
        df_code=df_edgar_year_selected[df_edgar_year_selected['IPCC_code_2006']==code]
        for elt in list_compound:
            df_elt=df_code[df_code['compound']==elt][year_selected]
            GWP_remaining[code[0]]+=(df_elt.values * gwp_dict[ elt]).sum()

# suming remaining
for key in [elt for elt in GWP_remaining.keys() if not elt == 'Total']:
    GWP_remaining['Total']+=GWP_remaining[key]
if do_verbose:
    print("There is some losses in the data processing:")
    for key in GWP_remaining.keys():
        print(key,': only' ,(GWP_ready_for_export_gtap_format[key]+GWP_remaining[key])/GWP_ref_dict[key]*100, '% found')
        #print(key,': only' ,(GWP_ready_for_export_gtap_format[key])/GWP_ref_dict[key]*100, '% found')

#TODO: 0.16% imprecision: check the losses when atributing AIR and SEA

#-------------------------------------------
# Other CO2 and Non-CO2 treatment:
#----------------------------------------------------------------------------------------------------------

##################################################################################
# Export the resultsaDatabase treatment
##################################################################################

#-------------------------------------------
# filter the database and ignore some element

# ignored_list: 
#cat4_to_keep = ['4D', '4D3', '4E', '4F']
#ignored_AFOLU = [elt for elt in code_in_edgar if elt[0] in ['5', '4', '3'] and sum([elt2keep in elt for elt2keep in cat4_to_keep])==0 ] # carefull, this also exclude  ['4B', '4D', '4A', '4C', '5A', '5B'
#ignored_fossil = [elt for elt in code_in_edgar if elt[0:2]=='1A']

#ignored_list = ignored_AFOLU + ignored_fossil

# exclude element from edgar dataset
#edgar_code_kept = [elt for elt in code_in_edgar if elt not in ignored_fossil]

#df_edgar_kept = df_edgar.loc[df_edgar[ipcc_name_code].isin( edgar_code_kept)]

edgar_variables_dimensions_info = {}
for variable_name in input_data_dimensions_emi_rescaled:
    edgar_variables_dimensions_info[variable_name] = '*'.join(input_data_dimensions_emi_rescaled[variable_name])

if args.output_file is not None:
    aggregation_GTAP.filter_dimensions_and_export_dimensions_tables( outputfile, input_dimensions_values_emi_rescaled, input_data_emi_rescaled, edgar_variables_dimensions_info, var_list= list(input_data_emi_rescaled.keys()) )



#Notes
# WARNING NOX and Nox
#-------------------------------------------
