#! /usr/bin/env python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Nicolas Graves
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


# original author: Florian Leblanc
# desagregate ILOSTAT empliyment datas based on GTAP total wages
# now only consider the EMP_TEMP_SEX_ECO_NB_A annual variable and total population (SEX_T)

import argparse
import os
import sys
import copy
import numpy as np
import common_cired
import pandas as pd
from scipy import interpolate
from scipy import optimize
import aggregation_GTAP
import csv

###################
# default if no argument - useful for development
year_default = 2014
ilostat_path_data_default = '/data/public_data/ILOSTAT/csv/'
gtap_data_path_default = '/data/shared/GTAP/results/extracted_GTAP10_'+str(year_default)+'/'
ilostat_filename_default = 'EMP_TEMP_SEX_ECO_NB_A.csv'
ilostat_var_default = 'EMP_TEMP_SEX_ECO_NB'
select_worth_anyway_default=False

###################
# Loading argument
parser = argparse.ArgumentParser('disagregation of ILOSTAT')

parser.add_argument('--year', nargs='?', const=year_default, type=int, default = year_default)
parser.add_argument('--ilostat-data-path', nargs='?',const=ilostat_path_data_default, type=str, default = ilostat_path_data_default)
parser.add_argument('--gtap-data-path', nargs='?',const=gtap_data_path_default, type=str, default = gtap_data_path_default)
#parser.add_argument('--isic2gtap-rules', nargs='?',const=isic2gtap_default, type=str, default = isic2gtap_default)
parser.add_argument('--ilostat-var', nargs='?',const=ilostat_var_default, type=str, default = ilostat_var_default)
parser.add_argument('--ilostat-file', nargs='?',const= ilostat_filename_default, type=str, default = ilostat_filename_default)
parser.add_argument('--select-worth', nargs='?',const= select_worth_anyway_default, type=bool, default = select_worth_anyway_default)
parser.add_argument('--output-file')

args = parser.parse_args()

year = args.year
gtap_data_path = args.gtap_data_path
ilostat_path_data = args.ilostat_data_path
ilostat_var = args.ilostat_var
ilostat_file = args.ilostat_file
#isic2gtap_rules = args.isic2gtap_rules
select_worth_anyway = args.select_worth

# create a results folder in ILOSTAT source file path
ilostat_results_path = '/'.join(ilostat_path_data.split('/')[0:-2]) + '/results/'
isic2gtap_rules = '/'.join(ilostat_path_data.split('/')[0:-2]) + '/aggregation_rules/ILO__Sector_n_ISIC__2_GTAP10.csv'

if not os.path.exists( ilostat_results_path):
    os.mkdir( ilostat_results_path)

###################
###global variables

GTAPpath = gtap_data_path.split('/GTAP/')[0] + '/GTAP/'
iso3_codes_path = '/data/public_data/country-codes/data/country-codes.csv'
Imaclim2ISO3_path = '/data/public_data/regional_aggregations/imaclim/'

country_codes_raw = pd.read_csv(iso3_codes_path)[['ISO3166-1-Alpha-3','name','official_name_en']]
country_codes = country_codes_raw[['ISO3166-1-Alpha-3','official_name_en']]
no_official_country_name = country_codes.loc[country_codes['official_name_en'].isna()]['ISO3166-1-Alpha-3'].to_list()
country_codes = pd.concat([country_codes,country_codes_raw[country_codes_raw['ISO3166-1-Alpha-3'].isin(no_official_country_name)][['ISO3166-1-Alpha-3','name']].rename(columns={'name': 'official_name_en'})])
country_codes.set_index("official_name_en", inplace=True)
country_codes = country_codes.to_dict()['ISO3166-1-Alpha-3']

# loading dict to match gtap with iso3
ISO2GTAP = pd.read_csv(GTAPpath+'./ISO3166_GTAP.csv')[['ISO','REG_V10']]
ISO2GTAP['ISO3'] = ISO2GTAP['ISO'].apply(lambda x: x.upper())
ISO2GTAP_dict = ISO2GTAP.set_index('ISO3')['REG_V10'].to_dict()


###################
### Function

#----------------------------------------------------------------------------------
def interpolate_extrapolate_missing_year_for_ilostat( df, year, interp_methods="quadratic", extrapolate=False):
    #available_years = list(set(Ilostat_data.loc[ (slice(None), 'ABW', slice(None)), :].reset_index()['time']))
    df = df.reset_index()
    df['time'] = pd.to_datetime(df['time'], format="%Y")
    df.index = df['time']
    del df['time']

    df_interpol = df.groupby( ['ref_area', 'classif1']).resample('Y').mean()
    df_interpol = df_interpol.groupby( ['ref_area', 'classif1'])

    concat_list = list()
    list_country_noQuadraInterp_Isic4 = list()
    dic_nearest_year = {}

    for row_index, row in df_interpol:
        year_vect = row.reset_index().set_index('time').index.year
        if row_index[0] in dic_nearest_year.keys() and 'ECO_ISIC4_' in row_index[1]:
            dic_nearest_year[ row_index[0]] = [ find_nearest( year_vect, year), dic_nearest_year[ row_index[0]]][ abs(find_nearest( year_vect, year) - year) < abs(dic_nearest_year[ row_index[0]] - year) ] 
        elif 'ECO_ISIC4_' in row_index[1]:
            dic_nearest_year[ row_index[0]] = find_nearest( year_vect, year)
        if not row.empty and (not row.values.shape==(1,1) and not np.isnan( row.values)[0,0]):
            row = expand_df_year( row, year, freq='Y')
            try:
                #a = row.droplevel( ['ref_area', 'classif1']).interpolate(method= interp_methods)
                a = row.interpolate(method= interp_methods)
            except:
                print( "No", interp_methods, "interpolation possible for (we go linear):", row_index)
                if 'ECO_ISIC4_' in row_index[1]:
                    list_country_noQuadraInterp_Isic4.append( row_index[0])
                a = row.interpolate(method='linear')
            # now extrapolate:
            if extrapolate:
                a = extrapolate_time_dataframe( a)
            a[ 'ref_area'] = row_index[0]
            a[ 'classif1'] = row_index[1]
            print(a)
            concat_list.append( a)
    return pd.concat(concat_list), list_country_noQuadraInterp_Isic4, dic_nearest_year
#----------------------------------------------------------------------------------
def polynome_third_degree(x, a, b, c, d):
    return a * (x ** 3) + b * (x ** 2) + c * x + d
#----------------------------------------------------------------------------------
def polynome_second_degree(x, b, c, d):
    return b * (x ** 2) + c * x + d
#----------------------------------------------------------------------------------
def extrapolate_time_dataframe( df):
    di = df.index
    df = df.reset_index().drop('index', 1)
    if np.isnan(df.values).sum() >=1 and not df.empty:
        index_first_nan = np.where( np.isnan( df) )[0][0]
        x = np.arange(0, index_first_nan)
        y = df[0:(index_first_nan)].values[:,0]
        # trunced
        #x = x[-3:]
        #y = y[-3:]
        xnew = np.arange(0, len(df) )
        if y.shape[0] >3:
            params = optimize.curve_fit( polynome_third_degree, x, y, (0.5, 0.5, 0.5, 0.5))
            ynew = polynome_third_degree( xnew, *params[0])   # use interpolation function returned by `interp1d`
        else:
            params = optimize.curve_fit( polynome_second_degree, x, y, ( 0.5, 0.5, 0.5))
            ynew = polynome_second_degree( xnew, *params[0])   # use interpolation function returned by `interp1d`
        df.values[ index_first_nan:,0] = ynew[ index_first_nan:]
    df.index = di
    return df
#----------------------------------------------------------------------------------
def expand_df_year( df, year_until_which_2expand, freq):
    # Extrapolate the index first based on original index
    df = df.reset_index().set_index('time').resample( freq).mean() 
    time2add = max( 0, year_until_which_2expand - np.max(df.index.year) )
    df = pd.DataFrame(
    data=df,
    index=pd.date_range(
        start=df.index[0],
        periods=len(df.index) + time2add,
        freq=df.index.freq
    )
    )
    return df
#----------------------------------------------------------------------------------
def find_nearest(array, value):
    array = np.asarray(array)
    idx = (np.abs(array - value)).argmin()
    return array[idx]
#----------------------------------------------------------------------------------
def select_best_class(Ilostat_data_interp, reg_col, select_worth_anyway=True):
    dict_class_reg = {}
    list_reg = list(set(Ilostat_data_interp.reset_index()[reg_col].values))
    # detect best class
    for reg in list_reg:
        list_class = list(set( Ilostat_data_interp[ Ilostat_data_interp[reg_col] == reg]['classif1']))
        if 'ECO_ISIC4_TOTAL' in list_class:
            dict_class_reg[reg]='ISIC4'
        elif 'ECO_ISIC3_TOTAL' in list_class:
            dict_class_reg[reg]='ISIC3'
        elif 'ECO_SECTOR_TOTAL' in list_class:
            dict_class_reg[reg]='SECTOR'
    if select_worth_anyway:
        for reg in list_reg:    
            dict_class_reg[reg]='SECTOR'
    # select data
    dict_class = {}
    for classs in list_class_type:
        dict_class[classs] = [elt for elt in Ilostat_data_interp['classif1'].values if classs in elt]
    Ilostat_data_interp = pd.concat( [ Ilostat_data_interp[ (Ilostat_data_interp[ reg_col] == reg) & (Ilostat_data_interp['classif1'].isin( dict_class[ dict_class_reg[reg]])) ] for reg in list_reg])
    return Ilostat_data_interp, dict_class_reg
#----------------------------------------------------------------------------------



###################
### Main job

#----------------------------------------------------------------------------------
# Loading data file
Ilostat_data = pd.read_csv( ilostat_path_data + ilostat_file, delimiter=',', index_col=[5,3,0,4])

# filtering information columns, only total sex and selected year
Ilostat_data = Ilostat_data.drop( [elt for elt in Ilostat_data.columns if elt != 'obs_value'], axis=1 )
Ilostat_data = Ilostat_data.loc[ (slice(None), 'SEX_T', slice(None), slice(None) ),:].droplevel( 'sex')
Ilostat_data_yr = Ilostat_data.loc[ ( year_default),:]

#----------------------------------------------------------------------------------
# Regional coverage analysis and interpolation

reg_ilostat_full =  list(set( Ilostat_data.reset_index()['ref_area']))
reg_ilostat_yr =  list(set( Ilostat_data_yr.reset_index()['ref_area']))

#checking the dictionnary for gtap-10 sectoral coverage
gtap_in_dict = list(set([val for key, val in ISO2GTAP_dict.items()] ))
print( "Is the dict complete? ", len(gtap_in_dict) == 141)

# regions in ILOSTAT not present in dict, need to correct the dict
for elt in reg_ilostat_full:
    if elt not in ISO2GTAP_dict.keys():
        print( elt, ' not in dict')
# Adding Kosovo as it is missing (assumed to be merged with Serbia in GTAP)
ISO2GTAP_dict['KOS'] = 'xer'
ISO2GTAP_dict['CUW'] = 'nld'

# 
not_in_ilostat = list()
in_ilostat = list()
for elt in ISO2GTAP_dict.keys():
    if elt not in reg_ilostat_full:
        not_in_ilostat.append( elt)
        print(elt, ISO2GTAP_dict[elt], [key for key, val in country_codes.items() if val == elt], ' not in Ilostat')
    else:
        in_ilostat.append( elt)

# adding the fellowing country, assuming the labor force is proportional to GDP
# regarding other country represented for the GTAP region
# we ignore Islands, 'Western Sahara', 'Monaco', 'Holy See'
# other belonging to the past: Democratic People's Republic of Korea; French Guinea
list_data_tobeadded_inPorportion_ofGDP = ['Central African Republic', 'Eritrea', 'Guinea-Bissau', 'Iraq', 'Libya', 'Somalia', 'Turkmenistan']

# Are there some missing GTAP regions ?
gtap_in_ilostat = list(set([ val for key, val in ISO2GTAP_dict.items() if key in in_ilostat] ))
gtap_not_in_ilostat = list(set([ val for key, val in ISO2GTAP_dict.items() if key in not_in_ilostat and val not in gtap_in_ilostat] ))

print( gtap_not_in_ilostat, 'GTAP regions not in ILOSTAT')
#xtw is the rest of the world, we neglect it from the employement and labor force point ov view

#----------------------------------------------------------------------------------
# Fixing missing years with interpolation / extrapolation

# interpolation for regions which have missing years
reg_2interpolate = [reg for reg in reg_ilostat_full if reg not in reg_ilostat_yr]

Ilostat_data_interp, list_country_noQuadraInterp_Isic4, dic_nearest_year = interpolate_extrapolate_missing_year_for_ilostat( Ilostat_data, year, interp_methods="quadratic", extrapolate=False)
Ilostat_data_interp['year'] = Ilostat_data_interp.index.to_period('Y')
Ilostat_data_interp.to_csv( ilostat_results_path + ilostat_file.split('.csv')[0] + '__selectworth_' + str(select_worth_anyway)+ '__interpolated.csv', index=False)

Ilostat_data_interp, fake1, fake2 = interpolate_extrapolate_missing_year_for_ilostat( Ilostat_data, year, interp_methods="quadratic", extrapolate=True)
Ilostat_data_interp['year'] = Ilostat_data_interp.index.to_period('Y')

# export results
Ilostat_data_interp.to_csv( ilostat_results_path + ilostat_file.split('.csv')[0] + '__selectworth_' + str(select_worth_anyway)+'__interpolated_extrapolated__' + str(year) + '.csv', index=False)

print( "\n", "Regions with not quadra. interp for at least one ISAIC4 sector:", list( set( list_country_noQuadraInterp_Isic4)) )
#  Regions with not quadra. interp for at least one ISAIC4 sector: ['GGY', 'IND', 'TGO', 'GUM', 'WSM', 'TLS', 'KHM', 'DOM', 'CMR', 'MDG', 'BWA', 'MMR', 'LAO', 'KWT', 'SEN', 'BTN', 'ANT', 'COK', 'LBR', 'VUT', 'BHR', 'PER', 'VCT', 'SUR', 'GRL', 'NER', 'ZWE', 'DZA', 'GMB', 'MDV', 'KIR', 'GTM', 'OMN', 'BDI', 'TJK', 'AGO', 'FJI']

#dfa = pd.concat(concat_list)
#dfa[dfa[ 'ref_area'] == 'ABW'] 
#aa=dfa[dfa[ 'ref_area'] == 'ABW']
#list(set(aa['classif1']))


#----------------------------------------------------------------------------------
# Analyzing sectoral coverage
Ilostat_data_reset = Ilostat_data.reset_index()

isic3_sec = [elt.replace('ECO_ISIC3_','') for elt in list(set( Ilostat_data.reset_index()['classif1'])) if 'ISIC3' in elt]
isic4_sec = [elt.replace('ECO_ISIC4_','') for elt in list(set( Ilostat_data.reset_index()['classif1'])) if 'ISIC4' in elt]
[elt for elt in isic4_sec if elt not in isic3_sec]
#['T', 'U', 'R', 'S']
[elt for elt in isic3_sec if elt not in isic4_sec]
#[]

# checking everyone not having ISIC 4 has ISIC 3:
for reg in [reg for reg in reg_ilostat_full if not reg in dic_nearest_year.keys()]:
    if not 'ECO_ISIC3_TOTAL' in list(set( Ilostat_data_reset[ Ilostat_data_reset[ 'ref_area'] == reg]['classif1'] )):
        print(reg, [key for key, val in country_codes.items() if val == reg],  "has not ISIC4 and ISIC3")
        if not 'ECO_SECTOR_TOTAL' in list(set( Ilostat_data_reset[ Ilostat_data_reset[ 'ref_area'] == reg]['classif1'] )):
            print("    ", reg, [key for key, val in country_codes.items() if val == reg],  "has neither ECO_SECTOR_TOTAL")

# TODO ISIC_4 and ISIC 3 not present in all regions
# adapt aggregation rules consequently
# for example: ISIC 3 is different : for example: Q=U
# China does not have ISIC4 & ISIC3, but only AGR|IND|SER aggregates
# TODO: check if totals are = to totals

# checking the size of _X sector (jobs not applicable to the economic sector classification)
dict_share_x = {}
for series in ['ECO_ISIC4', 'ECO_ISIC3','ECO_SECTOR']:
    for reg in [reg for reg in reg_ilostat_full if not reg in dic_nearest_year.keys()]:
        num = Ilostat_data_interp[ (Ilostat_data_interp[ 'ref_area'] == reg) * (Ilostat_data_interp['classif1'] == series + '_X') * (Ilostat_data_interp['year'] == str(year) )]['obs_value'].values
        den = Ilostat_data_interp[ (Ilostat_data_interp[ 'ref_area'] == reg) * (Ilostat_data_interp['classif1'] == series + '_TOTAL') * (Ilostat_data_interp['year'] == str(year) )]['obs_value'].values
        dict_share_x[ reg] = num/den*100
        if num.shape[0]==0:
            dict_share_x[ reg] = 0
    print( "For data series", series, "Share of X in total: mean is", np.array([ dict_share_x[k] for k in dict_share_x]).mean(), "; max is", np.array([dict_share_x[k] for k in dict_share_x]).max(), "; min is", np.array([dict_share_x[k] for k in dict_share_x]).min() )

# only high for 'Papua New Guinea' (25%) for ISIC3
# A lot of high values for ECO_SECTOR_

print( "Sector with high share of jobs not applicable to the economic sector classification:")
for elt in dict_share_x.keys():
    print( elt, [key for key, val in country_codes.items() if val == elt], dict_share_x[elt])


#----------------------------------------------------------------------------------
# Regional aggregation towards GTAP
Ilostat_data_interp['Region_Gtap'] = list(map(lambda x: ISO2GTAP_dict[x], Ilostat_data_interp['ref_area']))
Ilostat_data_interp = Ilostat_data_interp.groupby(['Region_Gtap', 'classif1', 'year']).sum()

#----------------------------------------------------------------------------------
# Disaggregation with GTAP

# Select just one labor classification
list_class_type = ['ISIC3', 'ISIC4', 'SECTOR']
Ilostat_data_interp, dict_class = select_best_class(Ilostat_data_interp.reset_index(), 'Region_Gtap', select_worth_anyway=True)
Ilostat_data_interp = Ilostat_data_interp.set_index(['Region_Gtap', 'classif1', 'year'])

# load labor agregation, disagregation rules
isic2gtap_path=isic2gtap_rules
rules_isic2gtap = {}
for elt in list_class_type:
    rules_isic2gtap[ elt] = {}
    rules_isic2gtap[ elt]['rule_agg_gtap']={}
    rules_isic2gtap[ elt]['rule_desag_isic']={}
    rules_isic2gtap[ elt]['rule_desag_gtap']={}

with open(isic2gtap_path, 'r') as read_obj:
    csv_reader = csv.reader(read_obj)
    for row in csv_reader:
        if row[0][0]=='#':
            continue
        class_type = [classs for classs in list_class_type if classs in row[0]][0]
        first_elt, second_elt = row[0].split('|')[0], row[0].split('|')[1:]
        if ',' in first_elt:
            rules_isic2gtap[class_type]['rule_agg_gtap'][second_elt] = first_elt.split(',')
        else:
            rules_isic2gtap[class_type]['rule_desag_isic'][first_elt] = second_elt
            for sec in second_elt:
                rules_isic2gtap[class_type]['rule_desag_gtap'][sec] = first_elt

##################################################
# disaggregation towards GTAP sectors using total wages earnt by sector

# load gtap
print('Loading GTAP data')
# Importing GTAP data. Not optimal.
input_file = GTAPpath+'./results/extracted_GTAP10_'+str(year)+'/SAMs.csv'
input_data, input_dimensions_values, input_data_dimensions = aggregation_GTAP.read_dimensions_tables_file(input_file)
print('GTAP data loaded')

# copy one matrix reg, sec like in edgar
# create fa total wages
list_wage_class=['ag_othlowsk', 'clerks', 'off_mgr_pros', 'service_shop', 'tech_aspros']
input_data['Wages'] = (input_data['AddedValue']+input_data['T_AddedValue'])[ [input_dimensions_values['ENDO'].index(elt) for elt in list_wage_class], :, :].sum(axis=0)

# copy one matrix reg, sec from gtap
output_ilostat_gtap = {}
output_ilostat_gtap['labor'] = input_data['Prod'] * 0
input_data_dimensions['labor'] = [elt for elt in input_data_dimensions['Prod']]

# loop on region (testing which labor classification to use); and loop on sectors (testing what to do in desag and agg rules)
list_reg_represented = list(set(Ilostat_data_interp.reset_index()['Region_Gtap'].values))
for i_reg, reg in enumerate(input_dimensions_values['REG']):
    if reg in list_reg_represented:
        class_type = dict_class[reg] 
        for i_sec, sec in enumerate(input_dimensions_values['SEC']):
            if sec in rules_isic2gtap[class_type]['rule_agg_gtap'].keys():
                for isic_elt in rules_isic2gtap[class_type]['rule_agg_gtap'][sec]:
                    if 'ECO_'+isic_elt in Ilostat_data_interp.loc[reg,slice(None),str(year)].reset_index()['classif1'].values:
                        output_ilostat_gtap['labor'][i_sec,i_reg] += Ilostat_data_interp.loc[reg,'ECO_'+isic_elt,str(year)].values[0] 
            elif sec in rules_isic2gtap[class_type]['rule_desag_gtap'].keys():
                isic_elt = rules_isic2gtap[class_type]['rule_desag_gtap'][sec]
                list_sec_gtap_desag = rules_isic2gtap[class_type]['rule_desag_isic'][isic_elt]
                share_desag = input_data['Wages'][ i_sec, i_reg] / input_data['Wages'][ [input_dimensions_values['SEC'].index(s) for s in list_sec_gtap_desag], i_reg].sum()
                if 'ECO_'+isic_elt in Ilostat_data_interp.loc[reg,slice(None),str(year)].reset_index()['classif1'].values:
                    output_ilostat_gtap['labor'][i_sec,i_reg] += Ilostat_data_interp.loc[reg,'ECO_'+isic_elt,str(year)].values[0] * share_desag

#----------------------------------------------------------------------------------
# GDP analogs for regions
#list_data_tobeadded_inPorportion_ofGDP
# TODO Compute coefficient based on GDP share among groups of region, and use
# it to compensate for missing regions

#----------------------------------------------------------------------------------
# exports

variables_dimensions_info = {}
for variable_name in output_ilostat_gtap:
    variables_dimensions_info[variable_name] = '*'.join( input_data_dimensions[variable_name])

if ilostat_path_data is not None:
    outputfile = ilostat_results_path + ilostat_file.split('.csv')[0] + '__selectworth_' + str(select_worth_anyway)+'__interpolated_extrapolated__gtap__'+ str(year) + '.csv'
    aggregation_GTAP.filter_dimensions_and_export_dimensions_tables( outputfile, input_dimensions_values, output_ilostat_gtap, variables_dimensions_info, var_list= ['labor'] )


#TODO:
#- extrapolation of missing region on a gdp/cap basis
#- dealing with negative values in year extrapolation
#- deal with "X" sector (not applicable to the ISIC classification)
# TODO: how to deal with X values (ISIC4_X, ISIC3_X, SECTOR_X; jobs not applicable to the economic sector classification)


