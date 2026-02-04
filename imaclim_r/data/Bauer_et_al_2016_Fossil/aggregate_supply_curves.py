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
import csv
import copy
import matplotlib.pyplot as plt
from common_pandas_utils import *

##################################################################################
# Parameters of the script
##################################################################################

# default if no argument - useful for development
ssp_default=1
fossil_default='coal'
input_file_default = '/data/public_data/Bauer_Fossil_Fuel_availability_SSP/extracted/'

###################
# Loading argument
parser = argparse.ArgumentParser('Aggregate supply curves from Bauer et al. 2016')
#https://doi.org/10.1016/j.energy.2016.05.088
#https://doi.org/10.1016/j.dib.2016.11.043

parser.add_argument('--ssp', nargs='?', const=ssp_default, type=int, default=ssp_default)
parser.add_argument('--fossil', nargs='?', const=fossil_default, type=str, default=fossil_default)
parser.add_argument('--verbose', nargs='?',const='False', type=str, default='False')
parser.add_argument('--input-folder', nargs='?',const=input_file_default, type=str, default=input_file_default)

args = parser.parse_args()

ssp = 'ssp'+str(args.ssp)

do_verbose = (args.verbose=='True')

input_folder = args.input_folder

outputfolder = 'aggregated_supply_curve_'+ssp+'/'

if not os.path.isdir(outputfolder):
    os.mkdir(outputfolder)

####################################
# Global parameters - convertion factors

#-------------------------------------------
# ratio of brazil to all latin america

# sources

#https://publications.iadb.org/publications/english/document/High-and-Dry-Stranded-Natural-Gas-Reserves-and-Fiscal-Revenues-in-Latin-America-and-the-Caribbean.pdf
#Natural gas	                Brazil	LAC     ratio		
#reserves 2017 3P (EJ)	        25.5	425.2	0.05997	

#https://doi.org/10.1016/j.enpol.2013.09.042
#Oil	                        Brazil	LAC     ratio		
#P, 2P and rem. URR (Gb)	181	1201	0.15071

#https://www.theglobaleconomy.com/rankings/coal_reserves/South-America/
#Coal	                        Brazil	LAC     ratio		
#coal reserves 2017 (Mt)	7271	15448	0.47068	

ratio_brazil_LAC = {'oil':0.15071, 'coal':0.47068, 'gas':0.05997}

#-------------------------------------------
if args.fossil == 'oil':
    dict_renaming = {'COO':'Conventional', 'EHO':'Extra_Heavy', 'SHO':'Shale', 'TAO':'Tar_sands'} 
if args.fossil == 'gas':
    dict_renaming = {'SHG':'Shale', 'DEG':'Deep', 'CMG':'Coal_bed', 'TIG':'Tight', 'COG':'Conventional', 'HYG':'Hydrates'} 

dic_gas = {'Shale': 'UnConv', 'Deep': 'Conv', 'Coal_bed': 'UnConv','Tight': 'UnConv', 'Conventional':'Conv', 'Hydrates':'Conv'}

##################################################################################
# functions
##################################################################################
#-------------------------------------------
def add_resource_2_reserve_reg( df, reg, reg_header, list_category):
    df_reg = df[ df[ reg_header]==reg]
    df_reg = pd.concat( [ add_resource_2_reserve_cat( df_reg, cat) for cat in list(set( [elt.replace('-rv','').replace('-rs','') for elt in list_category]))])
    return df_reg
#-------------------------------------------
def add_resource_2_reserve_cat( df_reg, cat):
    df_cat = df_reg[ (df_reg['Category']==cat+'-rv') | (df_reg['Category']==cat+'-rs')].copy()
    for val_cost in list(set(df_cat[ df_cat['Category']==cat+'-rv']['Cost'])):
        if val_cost in list(df_cat[ df_cat['Category']==cat+'-rs']['Cost'].values):
            df_cat.loc[ ((df_cat['Category']==cat+'-rs') & (df_cat['Cost']==val_cost)), 'Quantity'] += df_cat[ (df_cat['Category']==cat+'-rv') & (df_cat['Cost']==val_cost)]['Quantity'].values
            df_cat = df_cat[ ( ~(df_cat['Category']==cat+'-rv') | ~(df_cat['Cost']==val_cost))]
    return df_cat
#-------------------------------------------
def separate_one_country_from_aggregate(df, ratio, reg_agg, reg_new):
    df_new = df[ df['Region'] == reg_agg].copy()
    df_new['Region'] = reg_new
    df_new['Quantity'] /= (1+1/ratio)
    df.loc[ df['Region'] == reg_agg, 'Quantity'] -= df_new['Quantity'].values
    return pd.concat( [df, df_new])
#-------------------------------------------
def load_concat_coal( fil, dict_parse_coal, key, skiprows, nrows, header, sep='|', na_values='NULL', new_col_index='Cost', value_index='Quantity'):
    usecols = [1]+[i for i in range( dict_parse_coal[key][0], dict_parse_coal[key][1]+1)]
    df_FF = pd.read_csv( fil, skiprows=skiprows, nrows=nrows, header=header, usecols=usecols, sep=sep, na_values=na_values)
    df_FF = df_FF.rename(columns={'Unnamed: 1':'Region code'})
    df_FF = df_set_columns_indexes_as_column_values( df_FF, columns_index=[elt for elt in df_FF.keys() if elt!='Region code'], new_col_index='Cost', value_index='Quantity')
    df_FF['Cost'] = np.array(['.'.join(elt.split('.')[0:2]) for elt in df_FF['Cost'].values])
    df_FF = change_type_N_sort( df_FF, 'Cost', 'float64', ascending=True)
    df_FF['Category'] = key
    return df_FF
#-------------------------------------------


##################################################################################
# Dictionnaries
##################################################################################

# loading dict to match GEA regions used in Bauer et al. gtap with Imaclim
GEA2IM = pd.read_csv('./dico_reg_GEA_2_Imaclim.csv', skiprows=1, sep='|').set_index('GEA')['IMACLIM'].to_dict()

##################################################################################
# Loading datas - analyse, treat and export
##################################################################################

#-----------------------------------------------------------------------------------------------------------
# Loading

print('Loading Cumulative availability curves from Bauer et al. 2016')

if args.fossil in ['oil', 'gas']:
    fil = input_folder + 'oil_gas_'+ssp+'-1_Supply-cost_curves-normalized.csv'
    skiprows_oilNgas = 51
elif args.fossil == 'coal':
    fil = input_folder + 'coal_'+ssp+'-Coal_resource-normalized.csv'

if args.fossil == 'oil':
    usecols = range(1,5+1)
    new_column_dict = {'v_curSpaItm':'Region', 'v_curffTyp':'Category', 'v_curCost':'Cost', 'v_curQty':'Cumulative_Global_Quantity'}
elif args.fossil == 'gas':
    usecols =range(13,17+1)
    new_column_dict = {'v_curSpaItm.1':'Region', 'v_curffTyp.1':'Category', 'v_curCost.1':'Cost', 'v_curQty.1':'Cumulative_Global_Quantity'}

if args.fossil in ['oil', 'gas']:
    df_FF = pd.read_csv( fil, skiprows=skiprows_oilNgas, header=0, usecols=usecols, sep='|', na_values='NULL')
    # rename columns
    df_FF = df_FF.rename(columns=new_column_dict)
    # filter data / columns with all Nan
    df_FF = df_FF.fillna(0)
    df_FF = df_FF.iloc[ np.where( df_FF.sum(axis=1) != 0)]
    # data are weird
    # There is 2 lines for each data point, the first one is where we stand in the global cumulative curve
    # the second one is the ressource increase for this price
    df_FF['Quantity'] = df_FF['Cumulative_Global_Quantity'].copy()
    nb_points = df_FF['Quantity'].values.shape[0] / 2
    if nb_points % 1 !=0:
        print('WARNING: there is an odd number of data rows')
    else:
        nb_points = int(nb_points)
    index_new_cumulative = [i*2+1 for i in range(nb_points)]
    index_cumulative_2_substract = [i*2 for i in range(nb_points)]
    df_FF.loc[index_new_cumulative,'Quantity'] -= df_FF['Quantity'][index_cumulative_2_substract].values
    df_FF.loc[index_cumulative_2_substract,'Quantity'] -= df_FF['Quantity'][index_cumulative_2_substract].values
    # select only odd indexes, meaning with non zero data
    df_FF = df_FF[ df_FF['Quantity'] !=0 ]
    # agregating resource and reserve. It depends if they have an occurence for the same price, per region and per category
    quant_index = list(df_FF.keys()).index('Quantity')
    list_region = list(set(df_FF['Region']))
    list_category = list(set(df_FF['Category']))
    df_FF = pd.concat( [ add_resource_2_reserve_reg( df_FF, reg, reg_header='Region', list_category=list_category) for reg in list_region])
elif args.fossil == 'coal':
    dict_parse_coal = {'Hard coal- Reserve': (18,26), 'Lignite - Reserve': (28,34), 'Hard coal- Resource': (37,45), 'Lignite - Resource': (48,56)}
    if ssp!='ssp4':
        skiprows = [i for i in range(3)] + [4,5] 
        df_FF = pd.concat( [ load_concat_coal( fil, dict_parse_coal, key, skiprows=skiprows, nrows=18, header=0, sep='|', na_values='NULL', new_col_index='Cost', value_index='Quantity') for key in dict_parse_coal.keys()])
    elif ssp=='ssp4':
        skiprows = [i for i in range(4)] + [5,6,7,8] # wealth countries
        df_FF_wealth = pd.concat( [ load_concat_coal( fil, dict_parse_coal, key, skiprows=skiprows, nrows=4, header=0, sep='|', na_values='NULL', new_col_index='Cost', value_index='Quantity') for key in dict_parse_coal.keys()])
        skiprows = [i for i in range(6)] + [7,8,9,10,11,12] # poorest countries
        df_FF_poor = pd.concat( [ load_concat_coal( fil, dict_parse_coal, key, skiprows=skiprows, nrows=14, header=0, sep='|', na_values='NULL', new_col_index='Cost', value_index='Quantity') for key in dict_parse_coal.keys()])
        df_FF = pd.concat( [df_FF_wealth, df_FF_poor])
    df_FF = df_FF.rename( columns={'Region code':'Region'})
    list_region = list(set(df_FF['Region']))
    list_category = list(set(df_FF['Category']))
    #df_FF = df_FF[ df_FF['Region']!='SOO']
    df_FF = df_FF.fillna(0)

#-----------------------------------------------------------------------------------------------------------
# Analysing

if do_verbose:
    for head in df_FF.keys()[0:3]:
        val = list(set(df_FF[head]))
        print(head, ' column has ', len(val), 'elements, which are:', val)

# number of data point per regions, then per region and per field
print('\n')
if do_verbose:
    for reg in list_region:
        df_reg = df_FF[ df_FF['Region']==reg]
        print('Region', reg, 'has', len(df_reg), 'points')

print('\n')
if do_verbose:
    for reg in list_region:
        df_reg = df_FF[ df_FF['Region']==reg]
        plt.clf()
        plt.cla()
        ax = df_reg.plot.scatter( 'Quantity', 'Cost')
        ax.set_title(reg)
        fig = ax.get_figure()
        fig.savefig('./plot_scatter_SC_'+reg+'.pdf')
        df_reg.to_csv('./csv_SC_'+ssp+'_'+reg+'.csv')
        for cat in list_category:
            df_cat = df_reg[ df_reg['Category']==cat]
            print('Region', reg, 'has', len(df_cat), 'points for the category', cat)

#-----------------------------------------------------------------------------------------------------------
# Treat and aggregate

# special case for brazil
df_FF = separate_one_country_from_aggregate(df_FF, ratio_brazil_LAC[args.fossil], reg_agg='LAC', reg_new='BRA')

# apply dict
df_FF['Region_Im'] = list(map(lambda x: GEA2IM[x], df_FF['Region']))

# add reserve to ressource for same costs
df_FF=df_FF.groupby(['Region_Im', 'Category', 'Cost']).sum()
df_FF.reset_index(inplace=True)

#rename categories
if args.fossil in ['oil', 'gas']:
    for cat in list_category:
        df_FF.loc[ df_FF['Category']==cat, 'Category'] = dict_renaming[cat.replace('-rs','').replace('-rv','')]

# sort_values by regions_cost
df_FF = pd.concat( [ df_FF[df_FF['Region_Im']==reg].sort_values('Cost') for reg in list(set(df_FF['Region_Im']))])

#-----------------------------------------------------------------------------------------------------------

# quick renaming for export
dict_rename_forexport = {'Cost':'//Cost ($2010/GJ)', 'Quantity': 'Quantity (EJ)'}

# Export
for reg in list(set(df_FF['Region_Im'])):
    df_reg = df_FF[ df_FF['Region_Im']==reg]
    for cat in list(set(df_FF['Category'])):
        df_cat = df_reg[ df_reg['Category']==cat]
        df_cat = df_cat.rename(columns=dict_rename_forexport)
        df_cat[ dict_rename_forexport.values()].to_csv( outputfolder + '_'.join( [args.fossil, cat.replace(' ',''), reg ]) +'.csv', sep='|', index=False)

# special case for gas, agregation in 2 categories (conventional and unconventional)
if args.fossil=='gas':
    df_FF=df_FF.copy()
    df_FF['Category_agg'] = list(map(lambda x: dic_gas[x], df_FF['Category']))
    df_FF=df_FF.groupby(['Region_Im','Category_agg', 'Cost']).sum()
    df_FF.reset_index(inplace=True)
    for reg in list(set(df_FF['Region_Im'])):
        df_reg = df_FF[ df_FF['Region_Im']==reg]
        for cat in list(set(dic_gas.values())):
            df_cat = df_reg[ df_reg['Category_agg']==cat]
            df_cat = df_cat.rename(columns=dict_rename_forexport)
            df_cat[ dict_rename_forexport.values()].to_csv( outputfolder + '_'.join( [args.fossil, cat, reg ]) +'.csv', sep='|', index=False)
    # special case for gas, agregation in 1 categories (conventional and unconventional aggregated)
    dic_gas_all = {k:'Gas_agg' for k in list(set(dic_gas.values()))}
    df_FF['Category_agg_all'] = list(map(lambda x: dic_gas_all[x], df_FF['Category_agg']))
    df_FF=df_FF.groupby(['Region_Im','Category_agg_all', 'Cost']).sum()
    df_FF.reset_index(inplace=True)
    for reg in list(set(df_FF['Region_Im'])):
        df_reg = df_FF[ df_FF['Region_Im']==reg]
        for cat in list(set(dic_gas_all.values())):
            df_cat = df_reg[ df_reg['Category_agg_all']==cat]
            df_cat = df_cat.rename(columns=dict_rename_forexport)
            df_cat[ dict_rename_forexport.values()].to_csv( outputfolder + '_'.join( [args.fossil, cat, reg ]) +'.csv', sep='|', index=False)

# special case for coal, agregation in 1 category only
if args.fossil=='coal':
    dic_coal = {k:'Coal_agg' for k in dict_parse_coal.keys()}
    df_FF['Category_agg'] = list(map(lambda x: dic_coal[x], df_FF['Category']))
    df_FF=df_FF.groupby(['Region_Im','Category_agg', 'Cost']).sum()
    df_FF.reset_index(inplace=True)
    for reg in list(set(df_FF['Region_Im'])):
        df_reg = df_FF[ df_FF['Region_Im']==reg]
        for cat in list(set(dic_coal.values())):
            df_cat = df_reg[ df_reg['Category_agg']==cat]
            df_cat = df_cat.rename(columns=dict_rename_forexport)
            #df_cat = change_type_N_sort( df_cat, dict_rename_forexport['Cost'], 'float64', ascending=True)
            df_cat[ dict_rename_forexport.values()].to_csv( outputfolder + '_'.join( [args.fossil, cat.replace(' ',''), reg ]) +'.csv', sep='|', index=False)



