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
from numpy import genfromtxt
import csv

##################################################################################
# Parameters of the script
##################################################################################

# default if no argument - useful for development
input_file_default = './raw_data/'

###################
# Loading argument
parser = argparse.ArgumentParser('Compute coal supply curves from RoSE project')
parser.add_argument('--input-folder', nargs='?',const=input_file_default, type=str, default=input_file_default)

args = parser.parse_args()

input_folder = args.input_folder

outputfolder = 'results/'

if not os.path.isdir(outputfolder):
    os.mkdir(outputfolder)

############################
# load tables & dict
#table_13_coal_resource_base.csv  table_16_coal_extraction_cost_curve.csv  table_19_regional_distribution.csv

df_ress = pd.read_csv(input_file_default+'table_16_coal_extraction_cost_curve.csv',skiprows=2, delimiter='|')
df_reg_share = pd.read_csv(input_file_default+'table_19_regional_distribution.csv',skiprows=2, delimiter='|')

#Import order_regions 
order_regions_IMACLIM = pd.Index(genfromtxt('../order_regions.csv',dtype='str'))

# The details on REMIND regional abbreviations and defitnitions are as follows: CHN - China, IND - India, JPN - Japan, USA - United States of America, RUS - Russia, EUR - members of the European Union, LAM - Latin America, AFR - Sub-Saharan Africa excluding Republic of South Arica, MEA - including countries from the Middle East, North Africa and Central Asia, OAS - other Asian countries mainly located in South East Asia, ROW - the rest of the World including Australia, Canada, New Zealand, Norway, and the Republic of South Africa.

# Brazil need to be taken out of LAM
# ROW need to be splited 
# we Use coal production in 2014 from the IEA
# source: 
#https://www.theglobaleconomy.com/rankings/coal_reserves/South-America/
# 2022
reserve_brazil = 7271
reserve_LAC = 15448
reserve_australia = 164764.48 
reserve_newzealand = 7440.59
reserve_canada =  	7255.4 
reserve_norway =  	2.2  
reserve_soutafrica =  	10905.15 
reserve_ROW = reserve_australia+reserve_newzealand+reserve_canada+reserve_norway + reserve_soutafrica

ratio_brazil_LAC = reserve_brazil / reserve_LAC
ratio_AUS_ROW = reserve_australia / reserve_ROW
ratio_NZ_ROW = reserve_newzealand / reserve_ROW
ratio_CAN_ROW = reserve_canada / reserve_ROW
ratio_NOR_ROW = reserve_norway / reserve_ROW
ratio_SA_ROW = reserve_soutafrica / reserve_ROW

#################
# parameters 

grade_list = ['a','b','c','d','e'] 
reg_list = df_reg_share.columns[1:]

#

# create dict of share
dict_share_reg_one_assumption = {}

dict_REMIND_2_IM_region = {'RUS':'CIS', 'MEA':'MDE', 'USA':'USA', 'CHN':'CHN', 'OAS':'RAS', 'AFR':'AFR', 'EUR':'EUR', 'IND':'IND','JPN':'JAN'}

for g in grade_list:
    row = np.where( df_reg_share.iloc[:,0].str.contains(g))[0]
    dict_reg_grade = {r:0 for r in order_regions_IMACLIM}
    for i, r in enumerate(reg_list):
        val = float(df_reg_share.iloc[row,i+1].values[0].split('%')[0]) / 100
        if r=='ROW':
            dict_reg_grade['CAN'] = ratio_CAN_ROW * val
            dict_reg_grade['JAN'] += (ratio_NZ_ROW+ratio_AUS_ROW) * val
            dict_reg_grade['EUR'] += ratio_NOR_ROW * val
            dict_reg_grade['AFR'] += ratio_SA_ROW * val
        elif r=='LAM':
            dict_reg_grade['BRA'] = ratio_brazil_LAC * val
            dict_reg_grade['RAL'] = (1- ratio_brazil_LAC) * val
        else:
            dict_reg_grade[dict_REMIND_2_IM_region[r]] += float(df_reg_share.iloc[row,i+1].values[0].split('%')[0]) / 100
    dict_share_reg_one_assumption[g] = {k:v for k,v in dict_reg_grade.items()}

dict_share_reg = {}
# same regional shares for all assumptions, except grade 'f'
assumption_list = [c for c in df_ress.columns if 'Recoverable' in c]
type_list = ['Hard_coal','Lignite','All_cat']

for i, ass in enumerate(assumption_list):
    dict_shares = {}
    ass_short = ass.split(' ')[0]
    dict_share_reg[ass_short] = dict_share_reg_one_assumption.copy()
    # special case for 'f'
    f_reg_value = {r:0 for r in order_regions_IMACLIM}
    if ass_short != 'High':
        for grade in grade_list:
            f_reg_value = {r:0 for r in order_regions_IMACLIM}
            for r in order_regions_IMACLIM:
                val_diff = (df_ress.loc[ df_ress['Grade']==grade,'High Recoverable amount (EJ)'] - df_ress.loc[ df_ress['Grade']==grade,ass]).values[0]
                f_reg_value[r] += dict_share_reg_one_assumption[g][r] * val_diff
                
            tot_value =  sum( [f_reg_value[r] for r in f_reg_value.keys()])
        dict_share_reg[ass_short]['f'] = {r:float(f_reg_value[r]/tot_value) for r in f_reg_value.keys()}
    else:
        dict_share_reg[ass_short]['f'] = {r:0 for r in f_reg_value.keys()}

# compute mean

df_ress['Share Hard_coal'] = df_ress['Hard coal (EJ)'] / df_ress['Total (EJ)']
df_ress['Share Lignite'] = df_ress['Lignite (EJ)'] / df_ress['Total (EJ)']
df_ress['Share All_cat'] = df_ress['Total (EJ)'] / df_ress['Total (EJ)']

# introduce a 'f' category of fast increasing cost curves
df_ress.loc[ df_ress['Grade'] == 'Ext. 1','Grade'] = 'f'
# compute average Hard Coal and Lignite shares, and assign it to 'f'
mean_HC_share = df_ress.loc[ df_ress['Grade'].isin(['a','b','c','d','e']),'Hard coal (EJ)'].sum() / df_ress.loc[ df_ress['Grade'].isin(['a','b','c','d','e']),'Total (EJ)'].sum()
#df_ress.loc[ df_ress['Grade'] == 'f', 'Share Hard_coal'] = mean_HC_share
#df_ress.loc[ df_ress['Grade'] == 'f', 'Share Lignite'] = 1-mean_HC_share
#df_ress.loc[ df_ress['Grade'] == 'f', 'Share All_cat'] = 1
df_ress.loc[ df_ress['Grade'] == 'f', 'High Recoverable amount (EJ)'] = 0

# for the category 'f', average share depends on scenario assumption
dict_grade_cost_cat = {}
dict_shares_type = {}
for i, ass in enumerate(assumption_list):
    dict_shares = {}
    ass_short = ass.split(' ')[0]
    for grade in ['a','b','c','d','e','f']:
        # get cost range
        row = np.where( df_ress.loc[:,'Grade'].str.contains(grade))[0]
        low_cost = df_ress.loc[:,'Cost low ($)'].iloc[row].values
        high_cost = df_ress.loc[:,'Cost high ($)'].iloc[row].values
        nb_category = np.around((high_cost-low_cost) / 0.1) + 1
        cost_range = np.linspace(low_cost,high_cost,int(nb_category))
        if i==1:
            dict_grade_cost_cat[grade] = {'nb_cat':nb_category, 'cost_range':cost_range}
        if grade != 'f':
            dict_shares[grade] = {typ:df_ress.loc[:,'Share '+typ].iloc[row].values for typ in type_list}
    # special case for category 'f'
    grade = 'f'
    dict_shares[grade] = {typ:0 for typ in type_list}    
    if ass_short=='High':
        dict_shares[grade] = {typ:0 for typ in type_list}    
    else:
        mean_HC_share = (( df_ress.loc[ df_ress['Grade'].isin(['a','b','c','d','e']),ass] - df_ress.loc[ df_ress['Grade'].isin(['a','b','c','d','e']),'High Recoverable amount (EJ)']) *  df_ress.loc[ df_ress['Grade'].isin(['a','b','c','d','e']),'Share Hard_coal']).sum() / ( df_ress.loc[ df_ress['Grade'].isin(['a','b','c','d','e']),ass] - df_ress.loc[ df_ress['Grade'].isin(['a','b','c','d','e']),'High Recoverable amount (EJ)']).sum()
        dict_shares[grade]['Hard_coal'] = mean_HC_share
        dict_shares[grade]['Lignite'] = 1-mean_HC_share
        dict_shares[grade]['All_cat'] = 1
    # shares for grade f depends on assumption
    dict_shares_type[ass_short] = dict_shares.copy()

# loop on assumption / type of ressource & costs (with saving grades and values)
dict_SC = {}
for ass in assumption_list:
    ass_short = ass.split(' ')[0]
    dict_typ = {}
    for typ in type_list:
        dict_cost = {}
        for grade in ['a','b','c','d','e','f']:
            row = np.where( df_ress.loc[:,'Grade'].str.contains(grade))[0]
            for cost in dict_grade_cost_cat[grade]['cost_range']:
                val = df_ress.loc[:,ass].iloc[row].values/dict_grade_cost_cat[grade]['nb_cat'] * dict_shares_type[ass_short][grade][typ]
                dict_cost[float(cost[0])] = {'grade':grade, 'val': val}
        dict_typ[typ] = dict_cost.copy()
    dict_SC[ass_short] = dict_typ.copy()

####################################
# OUTPUT
####################################

# Imaclim coal trade balance 2014
#-1->[string(Exp(:,coal)' - Imp(:,coal)'); regnames']
#!25.256838  6.2614384  -57.927372  35.636351  37.155069  -84.216477  -74.389417  -8.2502469  -17.672818  20.371582  98.839004  18.936048  !
#!USA        CAN        EUR         JAN        CIS        CHN         IND         BRA         MDE         AFR        RAS        RAL        !
dict_expoters = {"USA":True, "CAN":True, "EUR": False, "JAN":True, "CIS":True, "CHN":False, "IND":False, "BRA": False, "MDE":False, "AFR":True, "RAS":True, "RAL":True}


# Output SSPs
#for ssp in range(1,5+1,1):
for ssp in range(1,5+1,1):
    header="//header"
    if ssp==5:
        ass='High'
    if ssp==2:
        ass='Medium'
    if ssp==1:
        ass='Low'
    if ssp==3:
        dict_ssp3_reg = { r:['High','Low'][dict_expoters[r]] for r in dict_expoters.keys()}
    if ssp==4:
        dict_ssp4_costs = { c:['Medium','Low'][c>2.5] for c in list_costs}
    dict_SC[ass]
    for typ in type_list:
        with open(outputfolder + 'coal_cost_curves_'+typ+'_SSP'+str(ssp)+'.csv','w') as file:
            file.write('// Coal extraction cost curve -RoSE project - SSP' + str(ssp) + ' in EJ (2007 reserves - BGR2009) and $1990/GJ (Rogner1992)\n')
            writer = csv.writer(file, delimiter='|')
            list_costs = [c for c in dict_SC[ass_short][typ].keys()]
            writer.writerow(["Costs"] + list_costs)
            for reg in order_regions_IMACLIM:
                if ssp in [1,2,5]:
                    sc_val = [ dict_SC[ass][typ][c]['val'][0] * dict_share_reg[ass][ dict_SC[ass][typ][c]['grade']][reg]  for c in list_costs]
                if ssp==3:
                    sc_val = [ dict_SC[dict_ssp3_reg[reg]][typ][c]['val'][0] * dict_share_reg[dict_ssp3_reg[reg]][ dict_SC[dict_ssp3_reg[reg]][typ][c]['grade']][reg]  for c in list_costs]
                if ssp==4:
                    sc_val = [ dict_SC[dict_ssp4_costs[c]][typ][c]['val'][0] * dict_share_reg[dict_ssp4_costs[c]][ dict_SC[dict_ssp4_costs[c]][typ][c]['grade']][reg]  for c in list_costs]
                writer.writerow( [reg] + sc_val)

