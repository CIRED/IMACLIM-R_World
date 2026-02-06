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

dataPath = sys.argv[1]
year_database_version = sys.argv[2]
active_pop_range = sys.argv[3]
#dataPath = '/data/public_data/UNO_world_population_prospect/normalized/'
#year_database_version = '2022' # '2019'

# script parameters
UN_scenario = 'Medium'
list_years=[2004,2007,2011,2014]

#Import order_regions 
order_regions = pd.Index(genfromtxt('../order_regions.csv',dtype='str'))

#All projections are for the medium UN scenario

os.makedirs('results/', exist_ok=True)

#minimum and maximum working age
min_wa = int(active_pop_range.split('-')[0])
max_wa = int(active_pop_range.split('-')[1])

##########################################
## Load data and dictionnaries
##########################################

#Processing total population data
#Extracting total population data
total_pop = pd.read_csv(dataPath + 'WPP'+year_database_version+'_TotalPopulationBySex.csv', delimiter='|', encoding="utf-8") 

# load complete UN dictionnary: name to iso
UN_name2iso = pd.read_csv( "/data/public_data/UNO_world_population_prospect/UNO_world_population_region_codes.csv", delimiter='|', encoding="utf-8")
UN_name2iso.set_index("Location", inplace=True)
dic_UN2iso = UN_name2iso.to_dict()['ISO3_Code']

# UN to Imaclim aggregation dataframe
# locID and ISO3 from UN data
UN_countries2Imaclim = UN_name2iso[UN_name2iso['LocTypeName'] == 'Country/Area'].reset_index()[ ['LocID', 'ISO3_Code']]

Imaclim2ISO3_path = '/data/public_data/regional_aggregations/imaclim/'
ISO2Imaclim = pd.read_csv(Imaclim2ISO3_path + './imaclim_ISO3_aggregates.csv', sep='|')
ISO2Imaclim_dict = ISO2Imaclim.set_index('ISO3')['Im_region'].to_dict()

# check if there is missing element in this dictionnary
missing_iso3_indiect = [elt for elt in UN_countries2Imaclim['ISO3_Code'] if elt not in ISO2Imaclim_dict.keys()]
for elt in missing_iso3_indiect:
    print( elt, list(dic_UN2iso.keys())[list(dic_UN2iso.values()).index(elt)], "is missing. Adding it manually.")
#['SSD', 'XKX', 'BES', 'CUW', 'BLM', 'MAF', 'SXM']
ISO2Imaclim_dict['SSD'] = 'AFR'
ISO2Imaclim_dict['CUW'] = 'RAL'
ISO2Imaclim_dict['MAF'] = 'EUR'
ISO2Imaclim_dict['SXM'] = 'EUR'
ISO2Imaclim_dict['BLM'] = 'EUR'
ISO2Imaclim_dict['BES'] = 'EUR'
ISO2Imaclim_dict['XKX'] = 'EUR'

UN_countries2Imaclim['Imaclim_region'] = UN_countries2Imaclim['ISO3_Code'].map(ISO2Imaclim_dict)

##########################################
## Check data and dictionnaries
##########################################

# checking with year 2014
total_pop_2014=total_pop.loc[total_pop['Time'] == 2014]
tot_pop=total_pop_2014.loc[total_pop_2014['Location']=='World'].PopTotal # 7295290.759

#checking total population based on the initial dictionnary
sum_tot=0
for elt in dic_UN2iso.keys():
    sum_tot += total_pop_2014.loc[total_pop_2014['Location']==elt].PopTotal.values.sum()

# checking by big regions (result: equal to totals)
"""
tot_by_region = 0
for elt in ['Africa', 'Asia', 'Europe', 'Latin America and the Caribbean', 'Northern America', 'Oceania']:
    print( elt, total_pop_2014.loc[total_pop_2014['Location']==elt])
    tot_by_region += total_pop_2014.loc[total_pop_2014['Location']==elt].PopTotal.values.sum() 
print(tot_by_region-tot_pop)
tot_by_region = 0
for elt in [903, 935, 908, 904, 905, 909]:
    tot_by_region += total_pop_2014.loc[total_pop_2014['LocID']==elt].PopTotal.values.sum() 
"""

dic_parentID = UN_name2iso.to_dict()['ParentID']

# complete dic parent
df_UN_code = pd.read_excel( '/data/public_data/UNO_world_population_prospect/download/WPP2022_F01_LOCATIONS.XLSX', 'DB')
for key, val in dic_parentID.items():
    if df_UN_code[df_UN_code['LocID'] == val]['LocTypeName'].values[0] == 'Subregion':
        # change the parent code of one of the subregion the subregion
        dic_parentID[key] = df_UN_code[df_UN_code['LocID'] == val]['ParentID'].values[0]

tot1=0
tot2=0
# checking region by region
for elt in [903, 935, 908, 904, 905, 909]:
    val_region = total_pop_2014.loc[total_pop_2014['LocID']==elt].PopTotal.values.sum()
    list_child = [reg for reg in dic_parentID.keys() if dic_parentID[reg]==elt]
    tot_region = total_pop_2014.loc[total_pop_2014['Location'].isin(list_child)].PopTotal.values.sum()
    tot1+=val_region
    tot2+=tot_region
    #print(elt, val_region, tot_region, val_region-tot_region)
    if elt==908:
        missing_in_Europe = val_region-tot_region
print("The PROBLEM is: a 77229.26200000104 error in Asia, a 164.10700000007637 in Europe (2014)")

# specific case of Asia:
for elt in [935]:
    val_region = total_pop_2014.loc[total_pop_2014['LocID']==elt].PopTotal.values.sum()
    list_child = [reg for reg in dic_parentID.keys() if dic_parentID[reg]==elt]
    #for reg in list_child:
    #    print( total_pop_2014.loc[total_pop_2014['Location'] == reg])
print("There is a problem with Türkiye, which seems to be a problem of encoding.\nWe fixed this by using the LocID identification number of the database instead of the region name")
#print( total_pop_2014.loc[total_pop_2014['Location'] == 'Türkiye'])
turkey_id = df_UN_code[ df_UN_code['Location'] == 'Türkiye'].LocID.values[0]
#print( total_pop_2014.loc[total_pop_2014['LocID'] == turkey_id])

print("The SOLUTION if for Asia: 77229.262, from Turkey, which is exactly the error for Asia")

# Checking subregions for Asia and Europe:
# 77229.26200000104 error in Asia, 164.10700000007637 in Europe
dic_subreg = {}
for ind_geo_reg in [908, 935]:
    # corresponding subregions
    dic_subreg[ind_geo_reg] = df_UN_code[df_UN_code['ParentID']==ind_geo_reg]['LocID'].values
# print the sum over sbregion compare to geographical region
for key, val in dic_subreg.items():
    val_region = total_pop_2014.loc[total_pop_2014['LocID']==key].PopTotal.values.sum()
    tot_region = total_pop_2014.loc[total_pop_2014['LocID'].isin( val)].PopTotal.values.sum()
    #print(key, val_region, tot_region, val_region-tot_region)
# print the sum over region consituting a subregion
list_asia = []
val_asia=[] # val_asia computed bellow has the right value
list_all_country_code_data = []
for key, val in dic_subreg.items():
    for subregion in val:
        countries = df_UN_code[df_UN_code['ParentID']==subregion]['LocID'].values
        val_region = total_pop_2014.loc[total_pop_2014['LocID']==subregion].PopTotal.values.sum()
        tot_region = total_pop_2014.loc[total_pop_2014['LocID'].isin( countries)].PopTotal.values.sum()
        for elt in countries:
            list_all_country_code_data.append(elt)
        if key==935:
            for elt in countries:
                list_asia.append(elt)
                val_asia.append( total_pop_2014.loc[total_pop_2014['LocID']==elt].PopTotal.values.sum())
        print(key, subregion, total_pop_2014.loc[total_pop_2014['LocID'].isin( countries)].PopTotal.values.shape, val_region, tot_region, val_region-tot_region)

# Check based on ID which countries are missing in the database
list_all_country_code_data = []
for elt in list(total_pop_2014['LocID']):
            if not total_pop_2014.loc[total_pop_2014['LocID']==elt].PopTotal.empty:
                list_all_country_code_data.append(elt)

list_all_country_code_dict = list(df_UN_code[df_UN_code['LocTypeName'] == 'Country/Area']['LocID'])
missing_in_data = [i for i in list_all_country_code_dict if i not in list_all_country_code_data]

for i in missing_in_data:
    country_name = df_UN_code[df_UN_code['LocID']==i]['Location']
    print('Missing in data this coutnry: ', country_name)

print("SOLUTION for Europe:")
print("Metadata says that Kosovo (under UNSC res. 1244) is not included in Serbia,\n but even if Kosovo is Missing in data, the sub-total of the sub-region 'Southern Europe' match. So at the end Kosovo seems to be accounted somewhere (in Serbia?) in the data, or not accounted at all even in the total.")
print("Metadata says that Guernsey and Jersey are not included in United Kingdom,\n Missing data of the sub-total of the sub-region 'Northern Europe' correspond to the known population of these two Island.\¬Wr use another source of data to split the missing population between the two isalnd (year 2014)")

# Complete data

# dictionnary for computing missing in Northen Europe
NorthEurope_subreg = df_UN_code[df_UN_code['ParentID']==924]['LocID'].values

NorthEurope_sum_data = total_pop[ total_pop['LocID'].isin( NorthEurope_subreg)].groupby('Time')[ ['PopMale','PopFemale','PopTotal']].agg('sum')
NorthEurope_sum_data = total_pop[ total_pop['LocID'].isin( NorthEurope_subreg)].groupby(['Time','Variant'])[ ['PopMale','PopFemale','PopTotal']].agg('sum')
NorthEurope_total = total_pop[ total_pop['LocID'] == 924]

def format_dataframe(source_df, target_df):
    common_columns = target_df.reset_index().columns.intersection(source_df.columns)
    missing_columns = target_df.reset_index().columns.difference(source_df.columns)
    
    grouped_by_columns = target_df.index.names
    
    formatted_df = source_df.loc[:, common_columns]
    
    for column in missing_columns:
        formatted_df[column] = None
    return formatted_df.set_index(grouped_by_columns)

NorthEurope_total = format_dataframe(NorthEurope_total,NorthEurope_sum_data)

df1=NorthEurope_total
df2=NorthEurope_sum_data
result = (df1.merge(df2, on=['Time','Variant'], how='left', suffixes=('_df1', '_df2'))
              .assign(PopTotal=lambda x: x['PopTotal_df1'] - x['PopTotal_df2']))

##########################################
## Complete data and dictionnaries
##########################################

# ratio jersey, guernsey, use the 2022 value
# sources:
#https://datareportal.com/reports/digital-2022-jersey
#https://datareportal.com/reports/digital-2022-guernsey
pop_jersey_2022 = 107.8 #thousand
pop_guernsey_2022 = 63.4 #thousand

#Complete data

dic_ratio_missing_reg = {'Jersey':pop_jersey_2022/(pop_jersey_2022+pop_guernsey_2022), 'Guernsey':pop_guernsey_2022/(pop_jersey_2022+pop_guernsey_2022)}

for reg, ratio in dic_ratio_missing_reg.items():
    loc = df_UN_code[df_UN_code['Location']==reg].LocID.values[0]
    new_df = result.reset_index().assign(LocID=loc, Location=reg)
    new_df['PopTotal'] = new_df['PopTotal'] * ratio
    #total_pop = total_pop.append(new_df, ignore_index=True)
    total_pop = pd.concat( [total_pop, new_df], ignore_index=True)

##########################################
## Compute and aggregate datas
##########################################

#Aggregating total population data
total_pop = pd.merge(total_pop,UN_countries2Imaclim,on='LocID')

total_pop = total_pop[['Imaclim_region','Time','Variant','PopTotal']].groupby(['Imaclim_region','Time','Variant']).sum()

#Saving total population data

#for year in list_years:
#    with open('./results/total_population_'+str(year)+'.csv', 'w') as file:
#        file.write('//Total population in '+str(year)+' (by geographic region)\n//UNO World Population Prospect '+year_database_version+'\n//thousands of people\n')
#        total_pop.xs(year,level='Time').reindex(order_regions).to_csv(file, sep='|',header=False,index=False)
historical = total_pop.loc[ (slice(None),  range(1950,2021+1), 'Medium'),:]['PopTotal']
with open('./results/total_population_trajectory_UNO_historical.csv', 'w') as file:
        historical.droplevel('Variant').unstack().to_csv(file, sep='|',header=True,index=True)

for UN_scenario in list(set(total_pop.reset_index()['Variant'])):
    output_variant_name = UN_scenario.replace(' ','_').lower()
    with open('./results/total_population_trajectory_UNO'+output_variant_name+'.csv', 'w') as file:
        file.write('//Total population (by geographic region)\n//UNO World Population Prospect '+year_database_version+'\n//thousands of people\n')
        #total_pop['PopTotal'].unstack().loc[ slice(None), range(2014,2101)].reindex(order_regions).to_csv(file, sep='|',header=False,index=False)
        projection = total_pop.loc[ (slice(None),  slice(None), UN_scenario),:]['PopTotal']
        pd.concat( [historical.droplevel('Variant'), projection.droplevel('Variant')], copy=None).drop_duplicates().unstack().loc[ slice(None), slice(None)].reindex(order_regions).to_csv(file, sep='|',header=True,index=True)

#Processing active population data
    #Computing active population data 
pop = pd.read_csv(dataPath + 'WPP'+year_database_version+'_PopulationBySingleAgeSex_Medium_1950-'+str(int(year_database_version)-1)+'.csv', delimiter='|') 
pop.loc[ pop['AgeGrp'] == '100+','AgeGrp'] = '100'
pop['AgeGrp'] = pop['AgeGrp'].astype(int)
pop.set_index('Location',inplace=True)
pop.set_index('LocID', inplace=True, append=True)
pop.set_index('Time', inplace=True, append=True)

list_variant = list(set(total_pop.reset_index()['Variant']))
list_existing_scenario_file = [fil for fil in os.listdir(dataPath) if 'PopulationBySingleAgeSex' in fil and '2100' in fil and 'WPP'+year_database_version in fil and any(elt in fil for elt in list_variant)]
for file_UN_scenario in list_existing_scenario_file:
    output_variant_name = file_UN_scenario.split('_')[2].replace(' ','_').lower()
    pop_projection = pd.read_csv(dataPath + file_UN_scenario, delimiter='|', encoding="utf-8") 
    pop_projection.loc[ pop_projection['AgeGrp'] == '100+','AgeGrp'] = '100'
    pop_projection['AgeGrp'] = pop_projection['AgeGrp'].astype(int)
    pop_projection.set_index('Location',inplace=True)
    pop_projection.set_index('LocID', inplace=True, append=True)
    pop_projection.set_index('Time', inplace=True, append=True)

    active_pop = pop.loc[(pop['AgeGrp']>=min_wa)&(pop['AgeGrp']<=max_wa)]['PopTotal'].groupby(level=['Location','Time','LocID']).sum()

    #active_pop = active_pop.append(pop_projection.loc[(pop_projection['AgeGrp']>=20)&(pop_projection['AgeGrp']<=59)]['PopTotal'].groupby(level=['Location','Time','LocID']).sum())
    active_pop = pd.concat( [active_pop, pop_projection.loc[(pop_projection['AgeGrp']>=min_wa)&(pop_projection['AgeGrp']<=max_wa)]['PopTotal'].groupby(level=['Location','Time','LocID']).sum()])

    #Aggregating to Imaclim
    active_pop = active_pop.reset_index()
    active_pop = pd.merge(active_pop,UN_countries2Imaclim,on='LocID')

    active_pop = active_pop[['Imaclim_region','Time','PopTotal']].groupby(['Imaclim_region','Time']).sum()

    if 'Medium' in file_UN_scenario:
        for year in list_years:
            with open('./results/active_population__range'+active_pop_range+'__' + str(year) + '.csv','w') as file:
                file.write('//Active population (i.e. '+str(min_wa)+'-'+str(max_wa)+' year span) in '+str(year)+' (by geographic region)\n//UNO World Population Prospect '+year_database_version+'\n//thousands of people\n')
                active_pop.xs(year,level='Time').reindex(order_regions).to_csv(file, sep='|',header=False,index=False)

    #Calculating UN population growth rates
    active_pop['GrowthRate'] = active_pop.pct_change()
    active_pop = active_pop.loc[(slice(None),slice('2002','2100')),:] 

    print( "min, max, mean, ", np.min(active_pop['GrowthRate'].values), np.max(active_pop['GrowthRate'].values), np.mean(active_pop['GrowthRate'].values))
    with open('./results/active_population_growth_rate__range'+active_pop_range+'__'+output_variant_name+'.csv','w') as file:
        file.write('//Active population (i.e. '+str(min_wa)+'-'+str(max_wa)+') growth rate (by geographic region, 2001-2002 to 2099-2100)\n//calcutated from UNO World Population Prospect '+year_database_version+'\n//\n')
        for ImRegion in order_regions:
            file.write(active_pop.xs(ImRegion,level='Imaclim_region').to_string(columns=['GrowthRate'],index=False,header=False).replace('\n','|')+'\n')


