# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
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
import argparse

###################
# default if no argument - useful for development
year_default = 2014
gtap_path_default = '../GTAP/GTAP_Imaclim_before_hybridation/outputs_GTAP10_'+str(year_default)+'/'

iea_agg_filepath_default = '../IEA/iea_aggregation_for_hybridation/results_'+str(year_default)+'/'
non_specified_default = None
wb_datapath_default = '/data/public_data/World_Bank_Data_Catalog_21052022/extracted/'


###################
# Loading argument
parser = argparse.ArgumentParser('aggregate GTAP data')

parser.add_argument('--year', nargs='?', const=year_default, type=int, default=year_default)
parser.add_argument('--iea-data-path', nargs='?',const=iea_agg_filepath_default, type=str, default=iea_agg_filepath_default)
parser.add_argument('--gtap-data-path', nargs='?',const=gtap_path_default, type=str, default=gtap_path_default)
parser.add_argument('--non-specified', nargs='?',const=non_specified_default, type=str, default=non_specified_default)
parser.add_argument('--wb-datapath', nargs='?',const=wb_datapath_default, type=str, default=wb_datapath_default)
parser.add_argument('--output-file')

args = parser.parse_args()

year = args.year
gtap_agg_file_path = args.gtap_data_path
iea_agg_file_path = args.iea_data_path

# the IEA flow category "non-specified" need to be atributed to an ISIC sector.
non_specified_arg = args.non_specified

wb_datapath = args.wb_datapath

###################
###global variables

ktoe2Mtoe = 1e-3
PJ2Mtoe = 23884.6 * 1e-6

transpoe_international_fuel_correction = False
import_export_international_fuel_correction = True

if "do_verbose" not in globals():
    do_verbose = True

#----------------------------------------------------------------------------------
# loading GTAP

if do_verbose:
    print('\n//////////////////////////////////////')
    print('Load input data:')
    print('//////////////////////////////////////\n')
    print('\n//////////////////////////////////////')
    print('     ---> Loading GTAP data:')

if "data_gtap_loaded" not in globals():
    data_gtap_loaded = False
if not data_gtap_loaded:
    input_data_sam, input_dimensions_values_sam, input_data_dimensions_sam = aggregation_GTAP.read_dimensions_tables_file( args.gtap_data_path + 'GTAP_SAM__EDS_N_gas_agg__GTAP10_'+str(year)+'.csv')
    input_data, input_dimensions_values, input_data_dimensions = aggregation_GTAP.read_dimensions_tables_file( args.gtap_data_path + 'GTAP_tables__EDS_N_gas_agg__GTAP10_'+str(year)+'.csv')

    #gtap_datafull_path='/data/shared/GTAP/results/extracted_GTAP10_2014/'
    #input_data_sam_full, input_dimensions_values_sam_full, input_data_dimensions_sam_full = aggregation_GTAP.read_dimensions_tables_file( gtap_datafull_path + 'SAMs.csv')

    data_gtap_loaded = True


# auto-importations are corrected within the previous round of GTAP agregation /extraction
# here we copy and use the _cor variables
# we do so, so that in the future it is easier to swap to a use of GTAP without correction 
# (in this case the _cor variables won't exists and won't have to be copied
for elt in input_data_sam.keys():
    if '_cor' in elt:
        input_data_sam[elt.replace('_cor','')] = input_data_sam[elt]
input_data_sam['Auto_TMX'] *=0

list_energy_sec = input_dimensions_values['ERG_COMM']
list_regions_order_ref = input_dimensions_values_sam['REG']
list_gtap_eds_sectors_order_ref = input_dimensions_values_sam['SEC']
nb_sectors = len(list_gtap_eds_sectors_order_ref)

list_energy_sec_order_ref = [ elt for elt in list_gtap_eds_sectors_order_ref if elt in list_energy_sec]
index_ener_sam_ref = [ input_dimensions_values_sam[ input_data_dimensions_sam['Prod'][0]].index( elt) for elt in list_energy_sec_order_ref]
index_nonener_sam_ref = [ input_dimensions_values_sam[ input_data_dimensions_sam['Prod'][0]].index( elt) for elt in list_gtap_eds_sectors_order_ref if elt not in list_energy_sec_order_ref]
index_ener_gtapE_ref = [ input_dimensions_values['ERG_COMM'].index( elt) for elt in list_energy_sec_order_ref]

index_region_gtapE_ref = [ input_dimensions_values['REG'].index( elt) for elt in list_regions_order_ref]

# indexes
ind_otp = input_dimensions_values_sam['SEC'].index('otp')
ind_atp = input_dimensions_values_sam['SEC'].index('atp')
ind_wtp = input_dimensions_values_sam['SEC'].index('wtp')
ind_twl = input_dimensions_values_sam['SEC'].index('twl')

sec_Trans = ['otp','atp','wtp']
sec_Trans_ref = [elt for elt in list_gtap_eds_sectors_order_ref if elt in sec_Trans]
ind_sec_Trans = [ list_gtap_eds_sectors_order_ref.index(elt) for elt in sec_Trans_ref]

sec_nonTrans = [elt for elt in list_gtap_eds_sectors_order_ref if not elt in sec_Trans_ref]
ind_sec_nonTrans = [ list_gtap_eds_sectors_order_ref.index(elt) for elt in sec_nonTrans]
nb_sec_nonTrans = len(sec_nonTrans)


#----------------------------------------------------------------------------------
# loading IEA energy balances

if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> Load IEA energy balances for Imaclim:')

# loading
iea_imaclim_web = pd.read_csv( iea_agg_file_path + 'Imaclim__EDS_Gtap_Aggregation.csv', sep='|', header=3)
iea_imaclim_web = iea_imaclim_web.round(decimals = 15)

iea_imaclim_web_autocons = pd.read_csv( iea_agg_file_path + 'Imaclim__EDS_Gtap_Aggregation__auto_consumption.csv', sep='|', header=4)

iea_imaclim_web_world_flows = pd.read_csv( iea_agg_file_path + 'Imaclim__World_Flows.csv', sep='|', header=3)

iea_imaclim_web[ iea_imaclim_web.select_dtypes(np.number).columns] = iea_imaclim_web[ iea_imaclim_web.select_dtypes(np.number).columns].mul( ktoe2Mtoe)
iea_imaclim_web_world_flows[ iea_imaclim_web_world_flows.select_dtypes(np.number).columns] = iea_imaclim_web_world_flows[ iea_imaclim_web_world_flows.select_dtypes(np.number).columns].mul( ktoe2Mtoe)
iea_imaclim_web_autocons[ iea_imaclim_web_autocons.select_dtypes(np.number).columns] = iea_imaclim_web_autocons[ iea_imaclim_web_autocons.select_dtypes(np.number).columns].mul( ktoe2Mtoe)

# reindexing energy product in order
iea_imaclim_web_world_flows = iea_imaclim_web_world_flows[ ['Flow'] + list_energy_sec_order_ref].set_index(['Flow']) #removing Year and WLD region

if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> Checking consistency about regions:')

list_region_gtap = input_dimensions_values['REG']
list_region_iea = list( set(iea_imaclim_web.Region_Gtap.to_list()))

for elt in list_region_iea:
    if elt not in list_region_gtap:
        if do_verbose:
            print( elt, " iea region not in gtap")

#pri and xtw are either not present or aggregated somewhere else in IEA:
#economic values of energy flow are set to zero in 
for elt in list_region_gtap:
    if elt not in list_region_iea:
        if do_verbose:
            print( elt, " gtap region not in iea")
        iea_imaclim_web_elt = iea_imaclim_web.loc[lambda df: df['Region_Gtap']=='usa',:].copy()
        iea_imaclim_web_elt[ list_energy_sec] *= 0
        iea_imaclim_web_elt.loc[ :,lambda df: ['Region_Gtap']] = elt
        iea_imaclim_web = pd.concat( [iea_imaclim_web, iea_imaclim_web_elt])
        # autocons
        iea_imaclim_web_elt = iea_imaclim_web_autocons.loc[lambda df: df['Region_Gtap']=='usa',:].copy()
        iea_imaclim_web_elt[ list_energy_sec] *= 0
        iea_imaclim_web_elt.loc[ :,lambda df: ['Region_Gtap']] = elt
        iea_imaclim_web_autocons = pd.concat( [iea_imaclim_web_autocons, iea_imaclim_web_elt])

iea_imaclim_web_copy = iea_imaclim_web.copy()
# re_indexing energy products
iea_imaclim_web = iea_imaclim_web[ ['Region_Gtap','Flow'] + list_energy_sec_order_ref]  #removing Year
order_flows_gtap_consistent = sec_nonTrans + [elt for elt in list(set(iea_imaclim_web['Flow'])) if elt not in sec_nonTrans]
iea_imaclim_web = iea_imaclim_web.set_index(['Flow','Region_Gtap']).reindex( order_flows_gtap_consistent, level='Flow').reindex( list_regions_order_ref, level='Region_Gtap')

iea_imaclim_web_autocons = iea_imaclim_web_autocons[ ['Region_Gtap','Flow'] + list_energy_sec_order_ref]  #removing Year
order_flows_gtap_consistent = sec_nonTrans + [elt for elt in list(set(iea_imaclim_web_autocons['Flow'])) if elt not in sec_nonTrans]
iea_imaclim_web_autocons = iea_imaclim_web_autocons.set_index(['Flow','Region_Gtap']).reindex( order_flows_gtap_consistent, level='Flow').reindex( list_regions_order_ref, level='Region_Gtap')

if do_verbose:
    print("Check re-indexing (!=0): ", ( np.abs(iea_imaclim_web_copy['coa'].to_numpy() - iea_imaclim_web['coa'].to_numpy())).sum() )

# zero-ing values we don't need
for elt in ['Statistical differences', 'Transformation processes', 'Transfers']:
    iea_imaclim_web.loc[(elt, list_regions_order_ref),:] *= 0

# attributing International aviation and marin bunkers
#iea_imaclim_web.loc[('Domestic aviation', list_regions_order_ref),:] += iea_imaclim_web.loc[('International aviation bunkers', list_regions_order_ref),:].to_numpy()
#iea_imaclim_web.loc[('Domestic navigation', list_regions_order_ref),:] += iea_imaclim_web.loc[('International marine bunkers', list_regions_order_ref),:].to_numpy()
#iea_imaclim_web.loc[('International aviation bunkers', list_regions_order_ref),:] *= 0
#iea_imaclim_web.loc[('International marine bunkers', list_regions_order_ref),:] *= 0

# re_indexing productive sectors
gtap_eds_sectors = input_dimensions_values_sam['SEC']

#TODO : remove this and code the non-specified exception
non_specified_arg = 'ser'
ind_ser = input_dimensions_values_sam['SEC'].index('ser')

# if non_specified_arg is specified as a sector (string), merging it; otherwise it will be put in the xxx accounting error composite sector
if non_specified_arg is not None:
    if not type(non_specified_arg) == str:
        if do_verbose:
            print("Need to sepecify non_specified_arg as a string corresponding to an ISIC sector, in consistency with script inputs")
    elif not non_specified_arg in list_gtap_eds_sectors_order_ref:
        if do_verbose:
            print(non_specified_arg + " not in the EDS list of Gtap aggregation input data. Please choose among: ", list_gtap_eds_sectors_order_ref) 
    else:
        checksum = iea_imaclim_web.loc[( [non_specified_arg, 'non-specified'], list_regions_order_ref),:].to_numpy().sum()
        iea_imaclim_web.loc[( non_specified_arg, list_regions_order_ref),:] += iea_imaclim_web.loc[( 'non-specified', list_regions_order_ref),:].to_numpy()
        iea_imaclim_web.loc[( 'non-specified', list_regions_order_ref),:] *= 0
        if do_verbose:
            print("Checksum for non-specified repartition: ", checksum - iea_imaclim_web.loc[( [non_specified_arg, 'non-specified'], list_regions_order_ref),:].to_numpy().sum())
else:
    if do_verbose:
        print("Need to sepecify non_specified_arg as a string corresponding to an ISIC sector, in consistency with script inputs")

#----------------------------------------------------------------------------------
# loading IEA energy efficiency data (on households road energy consumption)
# actual job
# path

path_iea_energy_efficiency_data = '/data/shared/IEA/EnergyEfficiencyIndicators/results/EstimationTransport_MainlyFromIEA_ByCountry_PJ_'+str(year)+'.csv'
country_tag='Country_Name'


# loading dict to match gtap with iso
GTAPpath = '/data/shared/GTAP/'
ISO2GTAP = pd.read_csv(GTAPpath+'./ISO3166_GTAP.csv')[['ISO','REG_V10']]
ISO2GTAP['ISO3'] = ISO2GTAP['ISO'].apply(lambda x: x.upper())
ISO2GTAP_dict = ISO2GTAP.set_index('ISO3')['REG_V10'].to_dict()

# new country code WB
country_codes_raw = pd.read_csv( wb_datapath + "WDICountry.csv")

# loading Energy Efficiency data
iea_EEI_hsld = pd.read_csv( path_iea_energy_efficiency_data, sep='|', header=0)
iea_EEI_hsld = iea_EEI_hsld.fillna(0)
iea_EEI_hsld = iea_EEI_hsld[ iea_EEI_hsld[country_tag]!=0]

iea_EEI_hsld = iea_EEI_hsld[iea_EEI_hsld['Year']==year]

# computing usefull values
for ener in ['gas','elec','ET']:
    iea_EEI_hsld['Hsld_Transport_'+ener] = (iea_EEI_hsld['pkm_cars_pc_new'] / iea_EEI_hsld["OccupancyRate_cars_new"] * iea_EEI_hsld['eff_cars_'+ener+'_vkm_new'] + iea_EEI_hsld['pkm_moto_pc_new'] / iea_EEI_hsld["OccupancyRate_moto_new"] * iea_EEI_hsld['eff_moto_'+ener+'_vkm_new']) * iea_EEI_hsld['Population_WB'] * PJ2Mtoe

# Convert to GTAP regions

# test if reg exists
list_reg = list(set(iea_EEI_hsld[country_tag]))
print("missing",  [reg for reg in list_reg if reg not in list(set(country_codes_raw['Short Name']))])
print("missing",  [reg for reg in list_reg if reg not in list(set(country_codes_raw['Table Name']))])

IEA_EFF_2_ISO = {}
for reg in list_reg:
    if reg in list(set(country_codes_raw['Table Name'])):
        IEA_EFF_2_ISO[reg] = country_codes_raw[country_codes_raw['Table Name']==reg]['Country Code'].values[0]

#manual completion:
print("missing", [reg for reg in list_reg if reg not in IEA_EFF_2_ISO.keys()])
IEA_EFF_2_ISO["Cote d'Ivoire"] = country_codes_raw[country_codes_raw['Table Name']=="Côte d'Ivoire"]['Country Code'].values[0]
IEA_EFF_2_ISO['Sao Tome and Principe'] = 'STP'
IEA_EFF_2_ISO['Curacao'] = 'CUW'
IEA_EFF_2_ISO['Kyrgyzstan'] = 'KGZ'
IEA_EFF_2_ISO['Republic of Moldova'] = 'MDA'
IEA_EFF_2_ISO['Korea'] = 'KOR'
IEA_EFF_2_ISO['Korea, Dem. People’s Rep.'] = 'PKR'


IEA_EFF_2_GTAP = {}
for key, value in IEA_EFF_2_ISO.items():
    if value in ISO2GTAP_dict.keys():
        IEA_EFF_2_GTAP[key] = ISO2GTAP_dict[value]
    else:
        print("missing", key, value)

# manual update
IEA_EFF_2_GTAP.update( {'Sint Maarten (Dutch part)': 'nld', 'St. Martin (French part)': 'fra', 'Channel Islands': 'xer', 'South Sudan': 'xec', 'Kosovo': 'xer', 'Curacao': 'nld', 'Korea, Dem. People’s Rep.':'xea'})

iea_EEI_hsld['Region_Gtap'] = list(map(lambda x: IEA_EFF_2_GTAP[x], iea_EEI_hsld[country_tag]))
iea_EEI_hsld = iea_EEI_hsld.groupby(['Region_Gtap' ]).sum()
#example iea_EEI_hsld.loc['alb', 'Hsld_Transport_ET']

list_regions_order_ref_IEA_EFF = [reg for reg in list_regions_order_ref if reg in list(set([val for key, val in IEA_EFF_2_GTAP.items()]))]
ind_reg_IEA_EFF = [list_regions_order_ref.index(reg) for reg in list_regions_order_ref_IEA_EFF]

# loading dict of Imaclim regions agregation rules
path='../GTAP/aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv'
reader = csv.reader(open(path, 'r'))
dict_Im_region = {}
for row in reader:
    dict_Im_region[row[0].split('|')[0]] = row[0].split('|')[1:]

#Used for debugging: file does not exist anymore. Note that several sectoral aggregation rules exists now
#path='../GTAP/aggregations/aggregation_Imaclim_GTAP10_sector12__after_hybridation.csv'
#reader = csv.reader(open(path, 'r'))
#dict_Im_sector = {}
#for row in reader:
#    dict_Im_sector[row[0].split('|')[0]] = [elt for elt in row[0].split('|')[1:] if elt!='']

#----------------------------------------------------------------------------------

# Memo GTAP Sam
#    Uses = CI_imp.sum(axis=1) + CI_dom.sum(axis=1) + C_hsld_dom + C_hsld_imp + C_AP_dom + C_AP_imp + FBCF_dom + FBCF_imp + Exp + Exp_trans_sect
#    Resources = CI_imp.sum(axis=0) + CI_dom.sum(axis=0) + AddedValue.sum(axis=0) + Imp + Imp_trans + T_prod + T_AddedValue.sum(axis=0) + T_CI_dom.sum(axis=0) + T_CI_imp.sum(axis=0) + T_Hsld_dom + T_Hsld_imp + T_AP_dom + T_AP_imp + T_FBCF_imp + T_FBCF_dom + T_Exp + T_Imp + Auto_TMX
#    Balance = Resources - Uses

# Memo Gtap energy data:
#EDF(ERG_COMM,PROD_COMM,REG)     RE  6x66x141             usage of domestic product by firms, Mtoe  
#EDG(ERG_COMM,REG)     RE  6x141                government consumption of domestic product, Mtoe
#EDP(ERG_COMM,REG)     RE  6x141                private consumption of domestic product, Mtoe
#EIF(ERG_COMM,PROD_COMM,REG)     RE  6x66x141             usage of imports by firms, Mtoe
#EIG(ERG_COMM,REG)     RE  6x141                government consumption of imports, Mtoe
#EIP(ERG_COMM,REG)     RE  6x141                private consumption of imports, Mtoe
#EXI(ERG_COMM,REG,REG)     RE  6x141x141            volume of trade, Mtoe


if do_verbose:
    print('\n//////////////////////////////////////')
    print('Hybridation procedure:')
    print('//////////////////////////////////////\n')

output_data_sam_hybrid = copy.deepcopy(input_data_sam)
output_data_dimensions_sam_hybrid = copy.deepcopy( input_data_dimensions_sam)
output_dimensions_values_sam_hybrid = copy.deepcopy(input_dimensions_values_sam)

nb_regions = len(input_dimensions_values_sam['REG'])

if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 4.1: computing transport volumes: air and marine')

# aviation
atp_Exp_services_world_share = (input_data_sam['Exp_trans'])[ ind_atp, :] / input_data_sam['Exp_trans'][ ind_atp, :].sum()
world_pool_energy_atp = iea_imaclim_web.loc[('International aviation bunkers', list_regions_order_ref),:].to_numpy().transpose().sum(axis=1)
atp_energy = np.repeat( world_pool_energy_atp, nb_regions).reshape( (len( index_ener_sam_ref), nb_regions)) * np.repeat(atp_Exp_services_world_share, len( index_ener_sam_ref)).reshape( (nb_regions,len( index_ener_sam_ref))).transpose()
atp_energy += iea_imaclim_web.loc[('Domestic aviation', list_regions_order_ref),:].transpose().to_numpy()


# navigation
wtp_Exp_services_world_share = (input_data_sam['Exp_trans'])[ ind_wtp, :] / input_data_sam['Exp_trans'][ind_wtp, :].sum()
world_pool_energy_wtp = iea_imaclim_web.loc[('International marine bunkers', list_regions_order_ref),:].to_numpy().transpose().sum(axis=1)
wtp_energy = np.repeat( world_pool_energy_wtp, nb_regions).reshape( (len( index_ener_sam_ref), nb_regions)) * np.repeat( wtp_Exp_services_world_share, len( index_ener_sam_ref)).reshape( (nb_regions,len( index_ener_sam_ref))).transpose()
wtp_energy += iea_imaclim_web.loc[('Domestic navigation', list_regions_order_ref),:].transpose().to_numpy()

# adjusting imports exports depending on the attribution of the international flows
if import_export_international_fuel_correction:
    diff_atp_fuel = iea_imaclim_web.loc[('International aviation bunkers', list_regions_order_ref),:].transpose().to_numpy() - (atp_energy-iea_imaclim_web.loc[('Domestic aviation', list_regions_order_ref),:].transpose().to_numpy())
    iea_imaclim_web.loc[('Imports', list_regions_order_ref),:] += np.where(  diff_atp_fuel>0, diff_atp_fuel, 0).transpose()
    iea_imaclim_web.loc[('Exports', list_regions_order_ref),:] -= np.where(  diff_atp_fuel<0, diff_atp_fuel, 0).transpose()
    iea_imaclim_web.loc[('Domestic aviation', list_regions_order_ref),:] = atp_energy.transpose()

    diff_wtp_fuel = iea_imaclim_web.loc[('International marine bunkers', list_regions_order_ref),:].transpose().to_numpy() - (wtp_energy-iea_imaclim_web.loc[('Domestic navigation', list_regions_order_ref),:].transpose().to_numpy())
    iea_imaclim_web.loc[('Imports', list_regions_order_ref),:] += np.where(  diff_atp_fuel>0, diff_atp_fuel, 0).transpose()
    iea_imaclim_web.loc[('Exports', list_regions_order_ref),:] -= np.where(  diff_atp_fuel<0, diff_atp_fuel, 0).transpose()
    iea_imaclim_web.loc[('Domestic navigation', list_regions_order_ref),:] = wtp_energy.transpose()

    iea_imaclim_web.loc[('International aviation bunkers', list_regions_order_ref),:] *= 0
    iea_imaclim_web.loc[('International marine bunkers', list_regions_order_ref),:] *= 0


if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 1: computing energy production prices:')

Export_energy_Gtap = input_data['EXI'].sum(axis=2)[ index_ener_gtapE_ref, :][:,index_region_gtapE_ref] # axis 2 for exports
Prod_energy_GTAP = (input_data['EDF'].sum(axis=1) + input_data['EDG'] + input_data['EDP'])[ index_ener_gtapE_ref, :][:,index_region_gtapE_ref] + Export_energy_Gtap # consistent permutation of energy and region indices


Prod_value_energy_GTAP = input_data_sam['Prod'][ index_ener_sam_ref, :] + input_data_sam['T_prod'][ index_ener_sam_ref, :]
Prod_ener_IEA_origin = (iea_imaclim_web.groupby('Region_Gtap').sum().values.transpose() - 2*iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose() )
for elt in ['Statistical differences', 'International aviation bunkers', 'Transformation processes', 'Transfers', 'International marine bunkers']:
    Prod_ener_IEA_origin -= iea_imaclim_web.loc[(elt, list_regions_order_ref),:].values.transpose() 

Prod_ener_IEA_origin = np.around(Prod_ener_IEA_origin, decimals=15)

#Assumptions about oil inputs to refined oil sector: constant ratio
ratio_oil_pc_origin = (input_data['EDF']+input_data['EIF'])[2,21,:] / Prod_energy_GTAP[3,:]
iea_imaclim_web.loc[('p_c', slice(None)),'oil'] = ratio_oil_pc_origin * Prod_ener_IEA_origin[3,:]
# decrease by the same ratio the ci the oil sector
#for i in range(5):
#    ratio_oil_pc_origin = (input_data['EDF']+input_data['EIF'])[i,20,:] / Prod_energy_GTAP[2,20]
#    iea_imaclim_web.loc[('p_c', slice(None)),'oil'] = ratio_oil_pc_origin * Prod_ener_IEA_origin[2,21]

# recompute oil production
Prod_ener_IEA_origin = (iea_imaclim_web.groupby('Region_Gtap').sum().values.transpose() - 2*iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose() )
for elt in ['Statistical differences', 'International aviation bunkers', 'Transformation processes', 'Transfers', 'International marine bunkers']:
    Prod_ener_IEA_origin -= iea_imaclim_web.loc[(elt, list_regions_order_ref),:].values.transpose()



Prod_for_price_computation = Prod_energy_GTAP.copy()
#Prod_for_price_computation[3,:][ Prod_ener_IEA_origin[3,:] >0] = Prod_ener_IEA_origin[3,:][ Prod_ener_IEA_origin[3,:] >0]
#price_Prod_energy_GTAP = Prod_value_energy_GTAP / Prod_for_price_computation

price_Prod_energy_GTAP_IEA = Prod_value_energy_GTAP / Prod_ener_IEA_origin
price_Prod_energy_GTAP = Prod_value_energy_GTAP / Prod_energy_GTAP

price_Prod_energy_GTAP_cp = price_Prod_energy_GTAP.copy()

# avoid huge gap in Liquid Fuels prices between the computed price and the orignal GTAP price.
# overrice by the GTAP price under some conditions
coeff_range_price=0.1

#price_Prod_energy_GTAP[3,:][ (Prod_ener_IEA_origin[3,:] > (1+coeff_range_price)*Prod_energy_GTAP[3,:]) | (Prod_ener_IEA_origin[3,:] < (1-coeff_range_price)*Prod_energy_GTAP[3,:])] = price_Prod_energy_GTAP_IEA[3,:][ (Prod_ener_IEA_origin[3,:] > (1+coeff_range_price)*Prod_energy_GTAP[3,:]) | (Prod_ener_IEA_origin[3,:] < (1-coeff_range_price)*Prod_energy_GTAP[3,:])]

#price_Prod_energy_GTAP[3,input_dimensions_values_sam['REG'].index('chn')] = price_Prod_energy_GTAP_cp[3,input_dimensions_values_sam['REG'].index('chn')] 
#price_Prod_energy_GTAP[3,input_dimensions_values_sam['REG'].index('ind')] = price_Prod_energy_GTAP_cp[3,input_dimensions_values_sam['REG'].index('ind')] 

####################
# RUSTINE X - begin

price_Prod_energy_GTAP[ list_energy_sec_order_ref.index('ely'), input_dimensions_values_sam['REG'].index('rus')] = price_Prod_energy_GTAP_IEA[ list_energy_sec_order_ref.index('ely'), input_dimensions_values_sam['REG'].index('rus')].copy()

for reg_Im, val_cor in {'AFR':1.02}.items():
    for reg in dict_Im_region[reg_Im]:
        price_Prod_energy_GTAP[ list_energy_sec_order_ref.index('ely'), input_dimensions_values_sam['REG'].index(reg)] *= val_cor 

for reg_Im, val_cor in {'USA':0.95}.items():
    for reg in dict_Im_region[reg_Im]:
        price_Prod_energy_GTAP[ list_energy_sec_order_ref.index('p_c'), input_dimensions_values_sam['REG'].index(reg)] *= val_cor

for reg_Im, val_cor in {'EUR':0.955}.items():
    for reg in dict_Im_region[reg_Im]:
        price_Prod_energy_GTAP[ list_energy_sec_order_ref.index('p_c'), input_dimensions_values_sam['REG'].index(reg)] *= val_cor

# RUSTINE X - end
####################

price_Prod_energy_GTAP[ np.isinf(price_Prod_energy_GTAP)] = (Prod_value_energy_GTAP / Prod_energy_GTAP)[ np.isinf(price_Prod_energy_GTAP)]

if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 2: computing import prices:')

# world prices as a mean of exportation prices, in the sens of Imaclim-R
T_Exp_rate = (input_data_sam['T_Exp'] / (input_data_sam['Exp']-input_data_sam['T_Exp'])) [ index_ener_sam_ref, :]
T_Imp_rate = (input_data_sam['T_Imp'] / input_data_sam['Imp']) [ index_ener_sam_ref, :]

T_Exp_rate = np.where( np.isnan(T_Exp_rate), 0, T_Exp_rate)
T_Imp_rate = np.where( np.isnan(T_Imp_rate), 0, T_Exp_rate)

Imp_transp_services_rate = (input_data_sam['Imp_trans'] / (input_data_sam['Imp'])) [ index_ener_sam_ref, :]

Export_energy_iea = iea_imaclim_web.loc[('Exports', list_regions_order_ref),:].transpose().to_numpy()
Import_energy_iea = -iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].transpose().to_numpy()
price_world_energy_ImaclimR = ((1+T_Exp_rate) * price_Prod_energy_GTAP * Export_energy_iea).sum(axis=1) / (Export_energy_iea).sum(axis=1)

price_import_energy_ImaclimR_noTrans = np.repeat( price_world_energy_ImaclimR, price_Prod_energy_GTAP.shape[1]).reshape( price_Prod_energy_GTAP.shape) 
price_import_energy_ImaclimR = price_import_energy_ImaclimR_noTrans * (1+T_Imp_rate + Imp_transp_services_rate)

if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 4.1: computing transport volumes: air and marine')

# indexes
ind_otp = input_dimensions_values_sam['SEC'].index('otp')
ind_atp = input_dimensions_values_sam['SEC'].index('atp')
ind_wtp = input_dimensions_values_sam['SEC'].index('wtp')
#------------------------------------- aviation and navigation

# energy balances reports the fuel for domestic versus international travels
# while IO economic table report expences of local versus foreign companies..

#iea_imaclim_web.loc[('Domestic aviation', list_regions_order_ref),:] += iea_imaclim_web.loc[('International aviation bunkers', list_regions_order_ref),:].to_numpy()
#iea_imaclim_web.loc[('Domestic navigation', list_regions_order_ref),:] += iea_imaclim_web.loc[('International marine bunkers', list_regions_order_ref),:].to_numpy()

otp_N_road_energy = iea_imaclim_web.loc[('Rail', list_regions_order_ref),:].transpose().to_numpy() + iea_imaclim_web.loc[('Road', list_regions_order_ref),:].transpose().to_numpy()

if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 3: Share of imports in energy consumption flows:')

# Simple way to compute share_dom: homogenous hyp. for every sector / consumption flows
share_dom_cons = 1 - iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose() / ( iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy() + (np.transpose( iea_imaclim_web.loc[ (sec_nonTrans, list_regions_order_ref),:].values.reshape( (nb_sec_nonTrans, nb_regions, 5)), (0,2,1) )).sum(axis=0) + wtp_energy + atp_energy + otp_N_road_energy)
share_dom_cons = np.where( np.isnan(share_dom_cons), 1, share_dom_cons)
share_dom_cons = np.where( share_dom_cons == -np.inf, 1, share_dom_cons)

share_imp_cons = 1-share_dom_cons

share_dom_ci = np.zeros( output_data_sam_hybrid['CI_dom'].shape)
share_dom_ci[index_ener_sam_ref, :, :] = np.repeat( share_dom_cons, nb_sectors).reshape( ( len( index_ener_sam_ref), nb_regions, nb_sectors)).transpose( (0, 2, 1))
share_imp_ci = 1 - share_dom_ci


if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 4.2: computing transport volumes: Raod and OTP')


#-------------------------------------  road energy consumption

"""
# computing onroad energy bill for households (excluding cars) and industries
otp_energy_expences_Gtap = (input_data_sam['CI_dom']+input_data_sam['CI_imp'])[ ind_otp, index_ener_sam_ref, :]
share_dom_otp_energy_expences = input_data_sam['CI_dom'][ ind_otp, index_ener_sam_ref, :] / otp_energy_expences_Gtap
rail_otp_bill_fromIEA = (price_import_energy_ImaclimR * (1-share_dom_otp_energy_expences) + price_Prod_energy_GTAP * share_dom_otp_energy_expences) * iea_imaclim_web.loc[('Rail', list_regions_order_ref),:].transpose().to_numpy()

road_otp_bill_Gtap = otp_energy_expences_Gtap - rail_otp_bill_fromIEA

# computing housholds cars energy bill
Hsld_energy_expences = (input_data_sam['C_hsld_dom']+input_data_sam['C_hsld_imp'])[ index_ener_sam_ref, :]
share_dom_Hsld_energy_expences = input_data_sam['C_hsld_dom'][ index_ener_sam_ref, :] / Hsld_energy_expences
Hsld_energy_expences_housing = (price_import_energy_ImaclimR * (1-share_dom_Hsld_energy_expences) + price_Prod_energy_GTAP * share_dom_Hsld_energy_expences) * iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy()
Hsld_expences_cars_Gtap = Hsld_energy_expences - Hsld_energy_expences_housing

# splitting road energy consumption between cars for households and road transport for industries and households (excl. cars)
#Cons_energy_road_carHsld = iea_imaclim_web.loc[('Road', list_regions_order_ref),:].transpose().to_numpy() * 1.5*Hsld_expences_cars_Gtap / (1.5*Hsld_expences_cars_Gtap + road_otp_bill_Gtap)
#otp_energy_road = iea_imaclim_web.loc[('Road', list_regions_order_ref),:].transpose().to_numpy() * road_otp_bill_Gtap / (1.5*Hsld_expences_cars_Gtap + road_otp_bill_Gtap)
Cons_energy_road_carHsld = iea_imaclim_web.loc[('Road', list_regions_order_ref),:].transpose().to_numpy() * Hsld_expences_cars_Gtap / (Hsld_expences_cars_Gtap + road_otp_bill_Gtap)
otp_energy_road = iea_imaclim_web.loc[('Road', list_regions_order_ref),:].transpose().to_numpy() * road_otp_bill_Gtap / (Hsld_expences_cars_Gtap + road_otp_bill_Gtap)
otp_energy = otp_energy_road + iea_imaclim_web.loc[('Rail', list_regions_order_ref),:].transpose().to_numpy()

if do_verbose:
    print("Quick check for road (==0?): ", (Cons_energy_road_carHsld + otp_energy_road  - iea_imaclim_web.loc[('Road', list_regions_order_ref),:].transpose().to_numpy()).sum(), ", ", (Cons_energy_road_carHsld + otp_energy_road  - iea_imaclim_web.loc[('Road', list_regions_order_ref),:].transpose().to_numpy()).sum() / (Cons_energy_road_carHsld + otp_energy_road).sum()*100 , "%")
"""


#ener_IEA_EFF_gtap = {'Hsld_Transport_gas':'gas_gdt','Hsld_Transport_ET':'p_c','Hsld_Transport_elec':'ely'}
# No gas yet in Imaclim transport
ener_IEA_EFF_gtap = {'Hsld_Transport_ET':'p_c','Hsld_Transport_elec':'ely'}
ener_IEA_EFF_gtap = {'Hsld_Transport_ET':'p_c'}

"""
ind_trd=input_dimensions_values_sam_full['SEC'].index('trd')
hsld_road_vehicles_expenditures = (input_data_sam_full['C_hsld_dom']+input_data_sam_full['C_hsld_imp'])[ind_trd,:]
company_road_vehicles_expenditures = (input_data_sam_full['CI_dom']+input_data_sam_full['CI_imp']-input_data_sam_full['T_CI_dom']-input_data_sam_full['T_CI_imp'])[:,ind_trd,:].sum(axis=0)

# compute ratio, save absolute expenditure data
data_road_vehicles_expenditures = dict()
data_road_vehicles_expenditures['hsld_road_vehicles_expenditures'] = hsld_road_vehicles_expenditures
data_road_vehicles_expenditures['company_road_vehicles_expenditures'] = company_road_vehicles_expenditures
dimensions_values_road_vehicles_expenditures = dict()
dimensions_values_road_vehicles_expenditures['REG'] = input_dimensions_values_sam_full['REG']
data_dimensions_road_vehicles_expenditures = {'hsld_road_vehicles_expenditures':['REG'], 'company_road_vehicles_expenditures':['REG']}

data_road_vehicles_dimensions_info = {}
for variable_name in data_dimensions_road_vehicles_expenditures:
    data_road_vehicles_dimensions_info[variable_name] = '*'.join(data_dimensions_road_vehicles_expenditures[variable_name])

if args.output_file is not None:
    output_path = '/'.join(args.output_file.split('/')[0:-1]) + '/gtap_road_vehicles_expenditures_'+year+'.csv'
    print(output_path)
    aggregation_GTAP.filter_dimensions_and_export_dimensions_tables( output_path, dimensions_values_road_vehicles_expenditures, data_road_vehicles_expenditures, data_road_vehicles_dimensions_info, var_list= list(data_road_vehicles_expenditures.keys()) ) 

ratio_hsld_company_road = hsld_road_vehicles_expenditures / (hsld_road_vehicles_expenditures+company_road_vehicles_expenditures)
"""

# ratio of households road energy consumption to the total (including company)
# source: energy balances of FRANCE 2019 (janvier 2021)
# https://www.statistiques.developpement-durable.gouv.fr/edition-numerique/bilan-energetique-2019/28-55-transports--stabilite-de
# https://www.statistiques.developpement-durable.gouv.fr/edition-numerique/bilan-energetique-2019/25-52-stabilite-de-la-depense
# Comment Thomas : Il n'y a pas directement la donnée de la part de consommation de carburant par les ménages, et ce n'est pas si facile de la reconstruire à partir des textes (d'ailleurs en le refaisant j'ai une estimation légèrement différente). D'après le texte ci-dessous, on a une première approximation à 57%, mais qui a priori n'intègre pas seulement le carburant. Par contre, les 25,9 Mtep sont a priori seulement du carburant (cf. le deuxième lien). Et l'ensemble du carburant est a priori à ~92% des 45,2 (41,8Mtep), d'où une estimation à 62% (et pas 63). Mais je pense qu'il faut retenir la fourchette l'ordre de grandeur de 60% pour la France. "En 2019, l’usage des transports représente 32 % de la consommation énergétique finale, soit 45,2 Mtep, dont 25,9 Mtep sont imputables aux ménages (cf. 5.2) et 19,4 Mtep aux entreprises et administrations. Par convention statistique internationale, cette consommation exclut les soutes internationales aériennes (6,1 Mtep) et maritimes (1,7 Mtep)."
ratio_hsld_company_road = 0.6

Cons_energy_road_carHsld = np.zeros(price_import_energy_ImaclimR.shape)
for key, value in ener_IEA_EFF_gtap.items():
    #Cons_energy_road_carHsld[ input_dimensions_values['ERG_COMM'].index( value), ind_reg_IEA_EFF] = iea_EEI_hsld.loc[(list_regions_order_ref_IEA_EFF), key].values.transpose() * ratio_hsld_company_road[ind_reg_IEA_EFF]
    Cons_energy_road_carHsld[ input_dimensions_values['ERG_COMM'].index( value), ind_reg_IEA_EFF] = iea_EEI_hsld.loc[(list_regions_order_ref_IEA_EFF), key].values.transpose() * ratio_hsld_company_road
otp_energy_road = iea_imaclim_web.loc[('Road', list_regions_order_ref),:].transpose().to_numpy() - Cons_energy_road_carHsld
otp_energy = otp_energy_road + iea_imaclim_web.loc[('Rail', list_regions_order_ref),:].transpose().to_numpy()

# test where it is larger that total Et
a=Cons_energy_road_carHsld/iea_imaclim_web.loc[('Road', list_regions_order_ref),:].transpose().to_numpy()
test_bigger = np.where( a[input_dimensions_values['ERG_COMM'].index('p_c'),:] >1)[0]

reg_with_excess_Et = [ list_regions_order_ref[i] for i in test_bigger]

if do_verbose:
    for key, value in IEA_EFF_2_GTAP.items():
        if value in reg_with_excess_Et:
            print( key, value)

# use bills when IEA EEI extrapolation are bigger than total road consumption of IEA tables
# The ratio of the value of other transport expenses on the value of private households expenses (road + residentiel), with GTAP
# should be equal to the recompted value based on prices and IEA quantities
# assuming alpha the quantities of road energy that goes into 'other transport' (non households)
Hsld_energy_expences = (input_data_sam['C_hsld_dom']+input_data_sam['C_hsld_imp'])[ index_ener_sam_ref, :]
otp_energy_expences_Gtap = (input_data_sam['CI_dom']+input_data_sam['CI_imp'])[ ind_otp, index_ener_sam_ref, :]

energy_rail = iea_imaclim_web.loc[('Rail', list_regions_order_ref),:].transpose().to_numpy()
energy_residential = iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy()
energy_road = iea_imaclim_web.loc[('Road', list_regions_order_ref),:].transpose().to_numpy()

alpha_numerator = (otp_energy_expences_Gtap/Hsld_energy_expences * (energy_road+energy_residential) - energy_rail)
alpha_denominator = ( energy_road * (1+otp_energy_expences_Gtap/Hsld_energy_expences))
alpha = alpha_numerator / alpha_denominator
alpha = np.where( (alpha_denominator==0) | (alpha<0) | (alpha>1), 0.5, alpha)
otp_energy_road_fromBills = energy_rail + alpha * energy_road
hsld_energy_road_fromBills = (1-alpha) * energy_road


# Correction from energy bill computation
Cons_energy_road_carHsld = np.where( a>1, hsld_energy_road_fromBills, Cons_energy_road_carHsld)
otp_energy = np.where( a>1, otp_energy_road_fromBills, otp_energy)
otp_energy_road = np.where( a>1, alpha * energy_road, otp_energy_road)


transport_energy = np.zeros( ( len(sec_Trans_ref),) + atp_energy.shape )
for count, elt in enumerate( sec_Trans_ref):
    exec( "transport_energy[ count, :, :] = " + elt + "_energy" )

if do_verbose:
    print("Quick check for transport services (==0?): ", transport_energy.sum() - otp_energy_road.sum() - iea_imaclim_web.loc[('Rail', list_regions_order_ref),:].transpose().to_numpy().sum() - iea_imaclim_web.loc[('Domestic navigation', list_regions_order_ref),:].to_numpy().sum() - iea_imaclim_web.loc[('Domestic aviation', list_regions_order_ref),:].to_numpy().sum(), ", ", (transport_energy.sum() - otp_energy_road.sum() - iea_imaclim_web.loc[('Rail', list_regions_order_ref),:].transpose().to_numpy().sum() - iea_imaclim_web.loc[('Domestic navigation', list_regions_order_ref),:].to_numpy().sum() - iea_imaclim_web.loc[('Domestic aviation', list_regions_order_ref),:].to_numpy().sum()) / transport_energy.sum(), "%"  )
    print("Quick check for transport services (terrestrial excluded) (==0?): ", transport_energy[0:2,...].sum() - iea_imaclim_web.loc[('Domestic navigation', list_regions_order_ref),:].to_numpy().sum() - iea_imaclim_web.loc[('Domestic aviation', list_regions_order_ref),:].to_numpy().sum(), ", ", (transport_energy[0:2,...].sum() - iea_imaclim_web.loc[('Domestic navigation', list_regions_order_ref),:].to_numpy().sum() - iea_imaclim_web.loc[('Domestic aviation', list_regions_order_ref),:].to_numpy().sum()) / transport_energy[0:2,...].sum(), "%"  )

# TODO fixed point for export and local prices

"""
if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 4: Share of imports in energy consumption flows:')

# OLD way to compute share_dom; computing a rescale factor of import share in consumption flow, in order to retrieve total energy Imports at the end
share_dom_cons =  (input_data['EDP'] / (input_data['EDP'] + input_data['EIP']))[ index_ener_gtapE_ref, :][:,index_region_gtapE_ref]
share_dom_ci = output_data_sam_hybrid['CI_dom'] / (output_data_sam_hybrid['CI_imp']+output_data_sam_hybrid['CI_dom'])
share_dom_ci = np.where( np.isnan( share_dom_ci), share_dom_cons.mean(), share_dom_ci)

rescale_factor_denominator = 0
rescale_factor_denominator +=  (Cons_energy_road_carHsld + iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy()) * (1-share_dom_cons) 
rescale_factor_denominator += (np.transpose( iea_imaclim_web.loc[ (sec_nonTrans, list_regions_order_ref),:].values.reshape( (nb_sec_nonTrans, nb_regions, 5)), (0,2,1) ) * (1-share_dom_ci[ ind_sec_nonTrans,...][:,index_ener_sam_ref, :])).sum(axis=0)
rescale_factor_denominator += (transport_energy * (1-share_dom_ci[ ind_sec_Trans,...][:,index_ener_sam_ref, :])).sum(axis=0)

rescale_factor_share_imp = iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose() / rescale_factor_denominator
rescale_factor_share_imp = np.where( np.isnan( rescale_factor_share_imp), 1, rescale_factor_share_imp) # TODO may be some non zero in Imports
rescale_factor_share_imp = np.where( rescale_factor_share_imp==np.inf, 1, rescale_factor_share_imp) # TODO may be some non zero in Imports

share_imp_cons = (1-share_dom_cons)* rescale_factor_share_imp
share_dom_cons = 1 - share_imp_cons

share_imp_ci = 1-share_dom_ci
share_imp_ci[:,index_ener_sam_ref, :] *= np.repeat( rescale_factor_share_imp, nb_sectors).reshape( ( len( index_ener_sam_ref), nb_regions, nb_sectors)).transpose( (2, 0, 1))
share_dom_ci = 1 - share_imp_ci

# Second way to compute share_dom - deprecated
share_dom_cons =  (input_data['EDP'] / (input_data['EDP'] + input_data['EIP']))[ index_ener_gtapE_ref, :][:,index_region_gtapE_ref]
share_dom_ci = output_data_sam_hybrid['CI_dom'] / (output_data_sam_hybrid['CI_imp']+output_data_sam_hybrid['CI_dom'])
share_dom_ci = np.where( np.isnan( share_dom_ci), share_dom_cons.mean(), share_dom_ci)
share_imp_cons = 1-share_dom_cons
share_imp_ci = 1-share_dom_ci

rescale_param_1 =0
rescale_param_1 += (Cons_energy_road_carHsld + iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy()) 
rescale_param_1 += (np.transpose( iea_imaclim_web.loc[ (sec_nonTrans, list_regions_order_ref),:].values.reshape( (nb_sec_nonTrans, nb_regions, 5)), (0,2,1) ) ).sum(axis=0)
rescale_param_1 += (transport_energy ).sum(axis=0) 

rescale_param_2 =0
rescale_param_2 += (Cons_energy_road_carHsld + iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy()) * (share_dom_cons)
rescale_param_2 += (np.transpose( iea_imaclim_web.loc[ (sec_nonTrans, list_regions_order_ref),:].values.reshape( (nb_sec_nonTrans, nb_regions, 5)), (0,2,1) ) * (share_dom_ci[ ind_sec_nonTrans,...][:,index_ener_sam_ref, :])).sum(axis=0)
rescale_param_2 += (transport_energy * (share_dom_ci[ ind_sec_Trans,...][:,index_ener_sam_ref, :])).sum(axis=0) 

rescale_factor_share_imp = rescale_param_2 / rescale_param_1 / iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose()
rescale_factor_share_imp = np.where( rescale_factor_share_imp==np.inf, 1, rescale_factor_share_imp)
rescale_factor_share_imp = np.where( np.isnan( rescale_factor_share_imp), 1, rescale_factor_share_imp)

share_imp_cons = share_imp_cons * rescale_factor_share_imp
share_dom_cons = 1 - share_imp_cons
share_imp_ci[:,index_ener_sam_ref, :] *= np.repeat( rescale_factor_share_imp, nb_sectors).reshape( ( len( index_ener_sam_ref), nb_regions, nb_sectors)).transpose( (2, 0, 1))
share_dom_ci = 1 - share_imp_ci
"""

# we check in which country/product imports are higher than total consumption
# and whether this correspond to small values of imports before correcting this in IEA treatment
ind_sec, ind_reg = np.where( np.abs(share_dom_cons) > 1.)
ii=0
for i in range(len(ind_sec)):
    demand = ( Cons_energy_road_carHsld + iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy() + (np.transpose( iea_imaclim_web.loc[ (sec_nonTrans, list_regions_order_ref),:].values.reshape( (nb_sec_nonTrans, nb_regions, 5)), (0,2,1) )).sum(axis=0) + transport_energy.sum(axis=0) )[ ind_sec[i], ind_reg[i]]
    imports = iea_imaclim_web.loc[ ( 'Imports', list_regions_order_ref[ind_reg[i]]), list_energy_sec_order_ref[ ind_sec[i]] ]
    exports = iea_imaclim_web.loc[ ( 'Exports', list_regions_order_ref[ind_reg[i]]), list_energy_sec_order_ref[ ind_sec[i]] ]
    #print( imports / demand, list_regions_order_ref[ind_reg[i]], list_energy_sec_order_ref[ ind_sec[i]])
 


if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 5: Add energy balance to the hybrid SAM:\n')

for impdom in ['imp', 'dom']:
    output_data_sam_hybrid[ 'Ener_CI_' + impdom] = 0*output_data_sam_hybrid['CI_dom']
    output_data_dimensions_sam_hybrid[ 'Ener_CI_' + impdom] = input_data_dimensions_sam[ 'CI_dom']
    for ener_elt in ['Ener_C_hsld_road_', 'Ener_C_hsld_resi_']:
        output_data_sam_hybrid[ ener_elt + impdom] = 0*output_data_sam_hybrid['C_hsld_dom']
        output_data_dimensions_sam_hybrid[ ener_elt + impdom] = input_data_dimensions_sam[ 'C_hsld_dom']
for ener_elt in ['Ener_Imp', 'Ener_Exp', 'Ener_Prod']:
        output_data_sam_hybrid[ ener_elt ] = 0*output_data_sam_hybrid['C_hsld_dom']
        output_data_dimensions_sam_hybrid[ ener_elt ] = input_data_dimensions_sam[ 'C_hsld_dom']

output_data_sam_hybrid[ 'Ener_C_hsld_road_dom'][index_ener_sam_ref, :] = Cons_energy_road_carHsld * share_dom_cons
output_data_sam_hybrid[ 'Ener_C_hsld_road_imp'][index_ener_sam_ref, :] = Cons_energy_road_carHsld * (1-share_dom_cons)

output_data_sam_hybrid[ 'Ener_C_hsld_resi_dom'][index_ener_sam_ref, :] = iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy() * share_dom_cons
output_data_sam_hybrid[ 'Ener_C_hsld_resi_imp'][index_ener_sam_ref, :] = iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy() * (1-share_dom_cons)

for ind_web, ind_gtap in enumerate(index_ener_sam_ref):
    output_data_sam_hybrid['Ener_CI_dom'][ ind_gtap, ind_sec_nonTrans, :] = iea_imaclim_web.loc[ ( sec_nonTrans, list_regions_order_ref), :].values[:,ind_web].reshape( (nb_sec_nonTrans, nb_regions)) * share_dom_ci[ ind_gtap, ind_sec_nonTrans, :]
    output_data_sam_hybrid['Ener_CI_imp'][ ind_gtap, ind_sec_nonTrans, :] = iea_imaclim_web.loc[ ( sec_nonTrans, list_regions_order_ref), :].values[:,ind_web].reshape( (nb_sec_nonTrans, nb_regions)) * (1 - share_dom_ci[ ind_gtap, ind_sec_nonTrans, :])
    output_data_sam_hybrid['Ener_CI_dom'][ ind_gtap, ind_sec_Trans, :] = transport_energy[:, ind_web, : ] * share_dom_ci[ ind_gtap, ind_sec_Trans, :]
    output_data_sam_hybrid['Ener_CI_imp'][ ind_gtap, ind_sec_Trans, :] = transport_energy[:, ind_web, : ] * (1-share_dom_ci[ ind_gtap, ind_sec_Trans, :] )

output_data_sam_hybrid['Ener_Imp'][index_ener_sam_ref, :] = iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose() 
output_data_sam_hybrid['Ener_Exp'][index_ener_sam_ref, :] = iea_imaclim_web.loc[('Exports', list_regions_order_ref),:].values.transpose() 
 
output_data_sam_hybrid['Ener_Prod'][index_ener_sam_ref, :] =(iea_imaclim_web.groupby('Region_Gtap').sum().values.transpose() - 2*iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose() ) 

# add auto-consumption, not considerered in the energy balanced:
output_data_sam_hybrid[ 'Ener_CI_autocons'] = 0*output_data_sam_hybrid['CI_dom']
output_data_dimensions_sam_hybrid[ 'Ener_CI_autocons'] = input_data_dimensions_sam[ 'CI_dom']

for ind_web, ener in enumerate(list_energy_sec_order_ref):
    ind_gtap = input_dimensions_values_sam[ input_data_dimensions_sam['Prod'][0]].index( ener)
    output_data_sam_hybrid['Ener_CI_autocons'][ ind_gtap, ind_gtap, :] = iea_imaclim_web_autocons.loc[ ( ener, list_regions_order_ref), ener].values

if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 6: computing new energy bill and statistical differences:')

# new energy expences
# TODO use output_data_sam_hybrid['Ener*  to compute expenses to avoid copy paste

# Import part of consumption may be slightly different from total imports
Imp_consumption = 0 * iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose() 
check_value_prod_dom = 0 * iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose()
check_value_import = 0 * iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose()

output_data_sam_hybrid['C_hsld_dom'][index_ener_sam_ref, :] = (Cons_energy_road_carHsld + iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy()) * share_dom_cons * price_Prod_energy_GTAP * ( 1 + input_data_sam['T_Hsld_dom'][index_ener_sam_ref, :] / ( input_data_sam['C_hsld_dom'] - input_data_sam['T_Hsld_dom'])[index_ener_sam_ref, :])
output_data_sam_hybrid['C_hsld_imp'][index_ener_sam_ref, :] = (Cons_energy_road_carHsld + iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy()) * (1-share_dom_cons) * price_import_energy_ImaclimR * ( 1 + input_data_sam['T_Hsld_imp'][index_ener_sam_ref, :] / ( input_data_sam['C_hsld_imp'] - input_data_sam['T_Hsld_imp'])[index_ener_sam_ref, :]) 
Imp_consumption += (Cons_energy_road_carHsld + iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy()) * (1-share_dom_cons)

output_data_sam_hybrid['C_hsld_imp'][index_ener_sam_ref, :] = np.where( np.isnan( output_data_sam_hybrid['C_hsld_imp'][index_ener_sam_ref, :]), 0, output_data_sam_hybrid['C_hsld_imp'][index_ener_sam_ref, :])
output_data_sam_hybrid['C_hsld_dom'][index_ener_sam_ref, :] = np.where( np.isnan( output_data_sam_hybrid['C_hsld_dom'][index_ener_sam_ref, :]), 0, output_data_sam_hybrid['C_hsld_dom'][index_ener_sam_ref, :])

output_data_sam_hybrid['T_Hsld_dom'][index_ener_sam_ref, :] = (Cons_energy_road_carHsld + iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy()) * share_dom_cons * price_Prod_energy_GTAP * ( input_data_sam['T_Hsld_dom'])[index_ener_sam_ref, :] / ( input_data_sam['C_hsld_dom'] - input_data_sam['T_Hsld_dom'])[index_ener_sam_ref, :]
output_data_sam_hybrid['T_Hsld_imp'][index_ener_sam_ref, :] = (Cons_energy_road_carHsld + iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy()) * (1-share_dom_cons) * price_import_energy_ImaclimR * ( input_data_sam['T_Hsld_imp'])[index_ener_sam_ref, :] / ( input_data_sam['C_hsld_imp'] - input_data_sam['T_Hsld_imp'])[index_ener_sam_ref, :] 

check_value_prod_dom += output_data_sam_hybrid['C_hsld_dom'][index_ener_sam_ref, :] - output_data_sam_hybrid['T_Hsld_dom'][index_ener_sam_ref, :]
check_value_import += output_data_sam_hybrid['C_hsld_imp'][index_ener_sam_ref, :] - output_data_sam_hybrid['T_Hsld_imp'][index_ener_sam_ref, :]

for uses in ['FBCF_', 'C_AP_', 'T_FBCF_', 'T_AP_']:
    for imp_dom in ['imp', 'dom']:
        output_data_sam_hybrid[ uses+imp_dom][index_ener_sam_ref, :] = 0 

if do_verbose:
    print("Check CI dom before:", ( output_data_sam_hybrid['CI_dom'][ index_ener_sam_ref,...][:, ind_sec_nonTrans, :].sum()/ input_data_sam['CI_dom'][ index_ener_sam_ref,...][:, ind_sec_nonTrans, :].sum() ))
    print("Check CI dom before:", ( output_data_sam_hybrid['CI_dom'].sum()/ input_data_sam['CI_dom'].sum() ))


for ind_web, ind_gtap in enumerate(index_ener_sam_ref):
    output_data_sam_hybrid['CI_dom'][ ind_gtap, ind_sec_nonTrans, :] = iea_imaclim_web.loc[ ( sec_nonTrans, list_regions_order_ref), :].values[:,ind_web].reshape( (nb_sec_nonTrans, nb_regions)) * share_dom_ci[ ind_gtap, ind_sec_nonTrans, :] * np.repeat( price_Prod_energy_GTAP[ ind_web,:], len(ind_sec_nonTrans)).reshape( ( nb_regions, len(ind_sec_nonTrans)) ).transpose()
    output_data_sam_hybrid['CI_imp'][ ind_gtap, ind_sec_nonTrans, :] = iea_imaclim_web.loc[ ( sec_nonTrans, list_regions_order_ref), :].values[:,ind_web].reshape( (nb_sec_nonTrans, nb_regions)) * (1-share_dom_ci[ ind_gtap, ind_sec_nonTrans, :]) * np.repeat( price_import_energy_ImaclimR[ ind_web,:], len(ind_sec_nonTrans)).reshape( ( nb_regions, len(ind_sec_nonTrans)) ).transpose()
    Imp_consumption[ ind_web,:] += (iea_imaclim_web.loc[ ( sec_nonTrans, list_regions_order_ref), :].values[:,ind_web].reshape( (nb_sec_nonTrans, nb_regions)) * (1-share_dom_ci[ ind_gtap, ind_sec_nonTrans, :])).sum(axis=0)
    check_value_prod_dom[ind_web, :] += output_data_sam_hybrid['CI_dom'][ ind_gtap, ind_sec_nonTrans, :].sum(axis=0)
    check_value_import[ind_web, :] += output_data_sam_hybrid['CI_imp'][ ind_gtap, ind_sec_nonTrans, :].sum(axis=0)
    

output_data_sam_hybrid['CI_dom'] = np.where( np.isnan(output_data_sam_hybrid['CI_dom']),0,output_data_sam_hybrid['CI_dom'])
if do_verbose:
    print("Check CI dom after:", ( output_data_sam_hybrid['CI_dom'][ index_ener_sam_ref,...][:, ind_sec_nonTrans, :].sum()/ input_data_sam['CI_dom'][ index_ener_sam_ref,...][:, ind_sec_nonTrans, :].sum() ))
    print("Check CI dom after:", ( output_data_sam_hybrid['CI_dom'].sum()/ input_data_sam['CI_dom'].sum() ))

for ind_web, ind_gtap in enumerate(index_ener_sam_ref):
    output_data_sam_hybrid['CI_dom'][ ind_gtap, ind_sec_Trans, :] = transport_energy[:, ind_web, : ] * share_dom_ci[ ind_gtap, ind_sec_Trans, :] * np.repeat( price_Prod_energy_GTAP[ ind_web,:], len(ind_sec_Trans)).reshape( ( nb_regions, len(ind_sec_Trans)) ).transpose()
    output_data_sam_hybrid['CI_imp'][ ind_gtap, ind_sec_Trans, :] = transport_energy [:, ind_web, : ]* (1-share_dom_ci[ ind_gtap, ind_sec_Trans, :]) * np.repeat( price_import_energy_ImaclimR[ ind_web,:], len(ind_sec_Trans)).reshape( ( nb_regions, len(ind_sec_Trans)) ).transpose()
    Imp_consumption[ ind_web,:] += (transport_energy [:, ind_web, : ]* (1-share_dom_ci[ ind_gtap, ind_sec_Trans, :]) ).sum(axis=0)
    check_value_prod_dom[ind_web, :] += output_data_sam_hybrid['CI_dom'][ ind_gtap, ind_sec_Trans, :].sum(axis=0)
    check_value_import[ind_web, :] += output_data_sam_hybrid['CI_imp'][ ind_gtap, ind_sec_Trans, :].sum(axis=0)

# Fixed CI tax rates
output_data_sam_hybrid['T_CI_dom'] = input_data_sam['T_CI_dom'] / input_data_sam['CI_dom'] * output_data_sam_hybrid['CI_dom']
output_data_sam_hybrid['T_CI_imp'] = input_data_sam['T_CI_imp'] / input_data_sam['CI_imp'] * output_data_sam_hybrid['CI_imp']

output_data_sam_hybrid['Imp'][index_ener_sam_ref, :] = iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose() * price_import_energy_ImaclimR_noTrans
output_data_sam_hybrid['Exp'][index_ener_sam_ref, :] = iea_imaclim_web.loc[('Exports', list_regions_order_ref),:].values.transpose() * price_Prod_energy_GTAP * ( 1 + T_Exp_rate)

output_data_sam_hybrid['Exp'][index_ener_sam_ref, :] = np.where( output_data_sam_hybrid['Exp'][index_ener_sam_ref, :] == np.inf, 0, output_data_sam_hybrid['Exp'][index_ener_sam_ref, :])
output_data_sam_hybrid['Exp'][index_ener_sam_ref, :] = np.where( np.isnan( output_data_sam_hybrid['Exp'][index_ener_sam_ref, :]), 0, output_data_sam_hybrid['Exp'][index_ener_sam_ref, :])

output_data_sam_hybrid['T_Exp'][index_ener_sam_ref, :] = output_data_sam_hybrid['Exp'][index_ener_sam_ref, :] * T_Exp_rate / (1+T_Exp_rate)
output_data_sam_hybrid['T_Imp'][index_ener_sam_ref, :] = output_data_sam_hybrid['Imp'][index_ener_sam_ref, :] * T_Imp_rate

output_data_sam_hybrid['T_Exp'][index_ener_sam_ref, :] = np.where( np.isnan( output_data_sam_hybrid['T_Exp'][index_ener_sam_ref, :]), 0, output_data_sam_hybrid['T_Exp'][index_ener_sam_ref, :])
output_data_sam_hybrid['T_Imp'][index_ener_sam_ref, :] = np.where( np.isnan( output_data_sam_hybrid['T_Imp'][index_ener_sam_ref, :]), 0, output_data_sam_hybrid['T_Imp'][index_ener_sam_ref, :])

check_value_prod_dom += output_data_sam_hybrid['Exp'][index_ener_sam_ref, :] - output_data_sam_hybrid['T_Exp'][index_ener_sam_ref, :]

output_data_sam_hybrid['Imp_trans'][index_ener_sam_ref, :] = ( output_data_sam_hybrid['Imp'])[index_ener_sam_ref, :] * Imp_transp_services_rate

# Rescaling transport services to import services
output_data_sam_hybrid['Exp_trans'] *= output_data_sam_hybrid['Imp_trans'].sum() / output_data_sam_hybrid['Exp_trans'].sum()

Prod_ener_IEA = iea_imaclim_web.groupby('Region_Gtap').sum().loc[ (list_regions_order_ref),:].values.transpose() - 2*iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose() 
for elt in ['Statistical differences', 'International aviation bunkers', 'Transformation processes', 'Transfers', 'International marine bunkers']:
    Prod_ener_IEA-= iea_imaclim_web.loc[(elt, list_regions_order_ref),:].values.transpose() 

output_data_sam_hybrid['Prod'][index_ener_sam_ref, :] = Prod_ener_IEA * price_Prod_energy_GTAP - output_data_sam_hybrid[ 'T_prod'][index_ener_sam_ref, :]

# Check energy balance usage for hybridation:
if do_verbose:
    print("Quick check for energy balance usage (==0?): ", (iea_imaclim_web.groupby('Region_Gtap').sum().values.transpose() - 2*iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose() ).sum() - (Cons_energy_road_carHsld + iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy() + iea_imaclim_web.loc[ ( sec_nonTrans, list_regions_order_ref),:].transpose().to_numpy().reshape( (nb_sec_nonTrans, nb_regions, 5)).sum(axis=0).transpose()  + transport_energy.sum(axis=0) + iea_imaclim_web.loc[('Exports', list_regions_order_ref),:].values.transpose() -iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose() ).sum() )

if do_verbose:
    print("Quick check for energy imports conservation (==0?): ", iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose().sum() - ((Cons_energy_road_carHsld + iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy()) * (1-share_dom_cons) ).sum() - (np.transpose( iea_imaclim_web.loc[ ( sec_nonTrans, list_regions_order_ref),:].values.reshape( (nb_sec_nonTrans, nb_regions, 5)), (2,0,1) ) * (1-share_dom_ci[ :,ind_sec_nonTrans,...][index_ener_sam_ref,...])).sum() - ( np.transpose(transport_energy, (1,0,2)) * (1-share_dom_ci[ :,ind_sec_Trans,...][index_ener_sam_ref,...])).sum() )
    print("Quick check for energy imports conservation NAN(==0?): ", iea_imaclim_web.loc[('Imports', list_regions_order_ref),:].values.transpose().sum(), ((Cons_energy_road_carHsld + iea_imaclim_web.loc[('Residential', list_regions_order_ref),:].transpose().to_numpy()) * (1-share_dom_cons) ).sum(), (np.transpose( iea_imaclim_web.loc[ ( sec_nonTrans, list_regions_order_ref),:].values.reshape( (nb_sec_nonTrans, nb_regions, 5)), (2,0,1) ) * (1-share_dom_ci[ :,ind_sec_nonTrans,...][index_ener_sam_ref,...])).sum(), ( np.transpose(transport_energy, (1,0,2)) * (1-share_dom_ci[ :,ind_sec_Trans,...][index_ener_sam_ref,...])).sum())

if do_verbose:
    print("Quick check on total value prod: ", output_data_sam_hybrid['Prod'][index_ener_sam_ref, :].sum(axis=1) / check_value_prod_dom.sum(axis=1))
    print("Quick check on total value imp: ", ( output_data_sam_hybrid['Imp'][index_ener_sam_ref, :]+output_data_sam_hybrid['T_Imp'][index_ener_sam_ref, :]+output_data_sam_hybrid['Imp_trans'][index_ener_sam_ref, :]).sum(axis=1)  / check_value_import.sum(axis=1))

# zeroing taxes for nul values
for var in ['C_hsld', 'FBCF', 'C_AP', 'CI']:
    taxvar = 'T_' + var.replace('C_AP','AP').replace('C_hsld', 'Hsld')
    for imp_dom in ['imp', 'dom']:
        output_data_sam_hybrid[taxvar+'_'+imp_dom] = np.where( output_data_sam_hybrid[var+'_'+imp_dom]==0,0,output_data_sam_hybrid[taxvar+'_'+imp_dom])

if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 7: creating an empty \'xxx\' error composite sector for rebalancing:\n')

for elt in output_data_sam_hybrid.keys():
    for count, dim in enumerate( output_data_dimensions_sam_hybrid[elt]):
        if dim == 'SEC':
            tuple_for_pad = tuple([ (0, [0,1][i==count])  for i in range(len(output_data_sam_hybrid[ elt].shape))])
            output_data_sam_hybrid[ elt] = np.pad( output_data_sam_hybrid[ elt], tuple_for_pad, mode='constant', constant_values=0)
            if elt in input_data_sam.keys():
                input_data_sam[ elt] = np.pad( input_data_sam[ elt], tuple_for_pad, mode='constant', constant_values=0)
 
input_dimensions_values_sam['SEC'].append( 'xxx')
output_dimensions_values_sam_hybrid['SEC'].append( 'xxx')

ind_xxx = output_dimensions_values_sam_hybrid['SEC'].index('xxx')
if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 8.0: Rustine to avoid negative values for some regions/sectors:')

if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 8: rebalancing Uses:')

for elt in output_data_sam_hybrid.keys():
        exec( elt+'=output_data_sam_hybrid[ elt]')

# 8.1 - Differences in energy inputs moved to CI xxx-> SEC (keep production accounting), consumption and exports difference in energy moved to xxx
# as there is just a few imports in services sectros (those whoa re supposed to be agregated with xxx later on), we move all
# statistical differences into the domestic production

# Correct CI_dom only for region with a sufficiently big services sector (for electricity and p_c sectors)
# This allow to avoid negativ values for AFR and MDE IMACLIM regions

####################
# RUSTINE X - begin
# zeroing auto-CI twl for MDE
for reg_Im in ['MDE']:
    for reg in dict_Im_region[reg_Im]:
        output_data_sam_hybrid['CI_dom'][ output_dimensions_values_sam_hybrid['SEC'].index('twl'), output_dimensions_values_sam_hybrid['SEC'].index('twl'), output_dimensions_values_sam_hybrid['REG'].index(reg)] *=0
        output_data_sam_hybrid['CI_imp'][ output_dimensions_values_sam_hybrid['SEC'].index('twl'), output_dimensions_values_sam_hybrid['SEC'].index('twl'), output_dimensions_values_sam_hybrid['REG'].index(reg)] *=0
# RUSTINE X - end
####################

quantity_CI_to_correct = input_data_sam['CI_dom'].sum(axis=0) - output_data_sam_hybrid['CI_dom'].sum(axis=0) + input_data_sam['CI_imp'].sum(axis=0) - output_data_sam_hybrid['CI_imp'].sum(axis=0)
quantity_CI_to_correct += input_data_sam['T_CI_dom'].sum(axis=0) - output_data_sam_hybrid['T_CI_dom'].sum(axis=0) + input_data_sam['T_CI_imp'].sum(axis=0) - output_data_sam_hybrid['T_CI_imp'].sum(axis=0)

####################
# RUSTINE X - begin

bool_exclude_country_sector_max = ~ ((output_data_sam_hybrid[ 'CI_dom'][ ind_ser, :, : ] - 2*output_data_sam_hybrid[ 'T_CI_dom'][ ind_ser, :, : ]> np.abs(quantity_CI_to_correct)) | (quantity_CI_to_correct>0))

bool_exclude_country_sector = bool_exclude_country_sector_max.copy()
bool_exclude_country_sector[:,:] = False
# for AFR
#bool_exclude_country_sector[ output_dimensions_values_sam_hybrid['SEC'].index('ely')] = bool_exclude_country_sector_cp[ output_dimensions_values_sam_hybrid['SEC'].index('ely')]
# for MDE
#bool_exclude_country_sector[ output_dimensions_values_sam_hybrid['SEC'].index('p_c')] = bool_exclude_country_sector_cp[ output_dimensions_values_sam_hybrid['SEC'].index('p_c')]

for reg_Im in ['BRA']:
    for reg in dict_Im_region[reg_Im]:
        bool_exclude_country_sector[ output_dimensions_values_sam_hybrid['SEC'].index('coa'), output_dimensions_values_sam_hybrid['REG'].index(reg)] = bool_exclude_country_sector_max[ output_dimensions_values_sam_hybrid['SEC'].index('coa'), output_dimensions_values_sam_hybrid['REG'].index(reg)]

for reg_Im in ['IND', 'JAN']:
    for reg in dict_Im_region[reg_Im]:
        bool_exclude_country_sector[ output_dimensions_values_sam_hybrid['SEC'].index('wtp'), output_dimensions_values_sam_hybrid['REG'].index(reg)] = bool_exclude_country_sector_max[ output_dimensions_values_sam_hybrid['SEC'].index('wtp'), output_dimensions_values_sam_hybrid['REG'].index(reg)]

for reg_Im in ['AFR','MDE','BRA','USA']:
    for reg in dict_Im_region[reg_Im]:
        bool_exclude_country_sector[ output_dimensions_values_sam_hybrid['SEC'].index('otp'), output_dimensions_values_sam_hybrid['REG'].index(reg)] = bool_exclude_country_sector_max[ output_dimensions_values_sam_hybrid['SEC'].index('otp'), output_dimensions_values_sam_hybrid['REG'].index(reg)]

for reg_Im in ['IND']:
    for reg in dict_Im_region[reg_Im]:
        bool_exclude_country_sector[ output_dimensions_values_sam_hybrid['SEC'].index('atp'), output_dimensions_values_sam_hybrid['REG'].index(reg)] = bool_exclude_country_sector_max[ output_dimensions_values_sam_hybrid['SEC'].index('atp'), output_dimensions_values_sam_hybrid['REG'].index(reg)]

# New 13-06-2022
for reg_Im in ['CAN']:
    for reg in dict_Im_region[reg_Im]:
        bool_exclude_country_sector[ output_dimensions_values_sam_hybrid['SEC'].index('otp'), output_dimensions_values_sam_hybrid['REG'].index(reg)] = bool_exclude_country_sector_max[ output_dimensions_values_sam_hybrid['SEC'].index('otp'), output_dimensions_values_sam_hybrid['REG'].index(reg)]

for reg_Im in ['EUR']:
    for reg in dict_Im_region[reg_Im]:
        bool_exclude_country_sector[ output_dimensions_values_sam_hybrid['SEC'].index('wtp'), output_dimensions_values_sam_hybrid['REG'].index(reg)] = bool_exclude_country_sector_max[ output_dimensions_values_sam_hybrid['SEC'].index('wtp'), output_dimensions_values_sam_hybrid['REG'].index(reg)]

# RUSTINE X - end
####################

####################
# RUSTINE X - begin

# removing part of 'quantity_CI_to_correct' with auto_consumption for transport sector for sectors with not enough CI
# dividing by 2 the auto-CI otp for CAN
for ind_sec in [ind_otp,ind_wtp,ind_atp]:
    quantity_CI_to_correct__auto_ci = - np.minimum( 0.9*output_data_sam_hybrid['CI_dom'][ind_sec,ind_sec,:], np.where( bool_exclude_country_sector[ind_sec,:], -quantity_CI_to_correct[ind_sec,:], 0))
    quantity_CI_to_correct__auto_ci = np.where(  quantity_CI_to_correct[ind_sec,:]<0, - np.minimum( 0.9*output_data_sam_hybrid['CI_dom'][ind_sec,ind_sec,:], -quantity_CI_to_correct[ind_sec,:]), 0) #+ np.where(  quantity_CI_to_correct[ind_sec,:]>0, quantity_CI_to_correct[ind_sec,:], 0)
    #quantity_CI_to_correct__auto_ci = - np.minimum( 0.9*output_data_sam_hybrid['CI_dom'][ind_sec,ind_sec,:], np.where( quantity_CI_to_correct[ind_sec,:]<0, -quantity_CI_to_correct[ind_sec,:], 0))
    output_data_sam_hybrid['CI_dom'][ind_sec,ind_sec,:] += quantity_CI_to_correct__auto_ci
    quantity_CI_to_correct[ind_sec,:] -= quantity_CI_to_correct__auto_ci

# re-evaluate bool_exclude_country_sector after the auto_consumption correction
bool_exclude_country_sector = bool_exclude_country_sector &  (~ ((output_data_sam_hybrid[ 'CI_dom'][ ind_ser, :, : ] - 2*output_data_sam_hybrid[ 'T_CI_dom'][ ind_ser, :, : ] > np.abs(quantity_CI_to_correct)) | (quantity_CI_to_correct>0)))
#bool_exclude_country_sector = (~ ((output_data_sam_hybrid[ 'CI_dom'][ ind_ser, :, : ] - 2*output_data_sam_hybrid[ 'T_CI_dom'][ ind_ser, :, : ] > np.abs(quantity_CI_to_correct)) | (quantity_CI_to_correct>0)))

# RUSTINE X - end
####################


output_data_sam_hybrid[ 'CI_dom'][ ind_xxx, :, : ] += np.where( bool_exclude_country_sector, 0, quantity_CI_to_correct)

# Correct taxes and imports consistently
output_data_sam_hybrid[ 'T_CI_dom'][ ind_xxx, :, : ] += np.where( bool_exclude_country_sector, 0, input_data_sam['T_CI_imp'].sum(axis=0) - output_data_sam_hybrid['T_CI_imp'].sum(axis=0))
output_data_sam_hybrid[ 'T_CI_dom'][ ind_xxx, :, : ] += np.where( bool_exclude_country_sector, 0, input_data_sam['T_CI_dom'].sum(axis=0) - output_data_sam_hybrid['T_CI_dom'].sum(axis=0))

output_data_sam_hybrid[ 'Imp'][ ind_xxx, :] -= np.where( bool_exclude_country_sector, 0, input_data_sam['CI_imp'].sum(axis=0) - output_data_sam_hybrid['CI_imp'].sum(axis=0)).sum(axis=0)

for elt in ['C_hsld_', 'C_AP_', 'FBCF_']:
    output_data_sam_hybrid[ elt+'dom'][ ind_xxx, :] += input_data_sam[ elt+'dom'].sum(axis=0) - output_data_sam_hybrid[elt+'dom'].sum(axis=0)
    output_data_sam_hybrid[ elt+'dom'][ ind_xxx, :] += input_data_sam[ elt+'imp'].sum(axis=0) - output_data_sam_hybrid[elt+'imp'].sum(axis=0)
    output_data_sam_hybrid[ 'T_'+elt.replace('C_','').replace('hsld','Hsld')+'dom'][ ind_xxx, :] += input_data_sam[ 'T_'+elt.replace('C_','').replace('hsld','Hsld')+'dom'].sum(axis=0) - output_data_sam_hybrid['T_'+elt.replace('C_','').replace('hsld','Hsld')+'dom'].sum(axis=0)
    output_data_sam_hybrid[ 'T_'+elt.replace('C_','').replace('hsld','Hsld')+'dom'][ ind_xxx, :] += input_data_sam[ 'T_'+elt.replace('C_','').replace('hsld','Hsld')+'imp'].sum(axis=0) - output_data_sam_hybrid['T_'+elt.replace('C_','').replace('hsld','Hsld')+'imp'].sum(axis=0)
    output_data_sam_hybrid[ 'Imp'][ ind_xxx, :] -= (input_data_sam[ elt+'imp'].sum(axis=0) - output_data_sam_hybrid[elt+'imp'].sum(axis=0)) * (1-output_data_sam_hybrid['T_'+elt.replace('C_','').replace('hsld','Hsld')+'imp'].sum(axis=0)/output_data_sam_hybrid[elt+'imp'].sum(axis=0))

# removing statistical differences of import from imprts

output_data_sam_hybrid['Exp'][ ind_xxx, :] += input_data_sam['Exp'].sum(axis=0) - output_data_sam_hybrid['Exp'].sum(axis=0)
output_data_sam_hybrid['Exp'][ ind_xxx, :] += input_data_sam['Exp_trans'].sum(axis=0) - output_data_sam_hybrid['Exp_trans'].sum(axis=0)

# 8.2 & 8.3

# 8.2 - Differences in energy production moved to CI xxx-> ener (consistent production accounting for energy sectors)
# at prorata of original repartition of production for CI element

# 8.3 - differences in energy production (added in Uses) moved into CI(xxx->xxx) (keep total usage)

Prod_computed = output_data_sam_hybrid['CI_imp'].sum(axis=0) + output_data_sam_hybrid['CI_dom'].sum(axis=0) + output_data_sam_hybrid['AddedValue'].sum(axis=0) + output_data_sam_hybrid['T_CI_dom'].sum(axis=0) + output_data_sam_hybrid['T_CI_imp'].sum(axis=0) + output_data_sam_hybrid['T_AddedValue'].sum(axis=0)
Prod_computed_origin = input_data_sam['CI_imp'].sum(axis=0) + input_data_sam['CI_dom'].sum(axis=0) + input_data_sam['AddedValue'].sum(axis=0) + input_data_sam['T_CI_dom'].sum(axis=0) + input_data_sam['T_CI_imp'].sum(axis=0) + input_data_sam['T_AddedValue'].sum(axis=0) 

mising_ci_xxx_In_enerProd_and_RegSec_with_bool_exclude = (output_data_sam_hybrid['Prod'][index_ener_sam_ref+[ind_otp,ind_wtp,ind_atp], :] -  Prod_computed[index_ener_sam_ref+[ind_otp,ind_wtp,ind_atp], :])

denominator_ratio_CI_xxx_ener = np.maximum(output_data_sam_hybrid['CI_imp'][[ind_ser,ind_xxx],:,:].sum(axis=0),0) + np.maximum(output_data_sam_hybrid['CI_dom'][[ind_ser,ind_xxx],:,:].sum(axis=0),0) + np.maximum(output_data_sam_hybrid['T_CI_dom'][[ind_ser,ind_xxx],:,:].sum(axis=0),0) + np.maximum(output_data_sam_hybrid['T_CI_imp'][[ind_ser,ind_xxx],:,:].sum(axis=0),0) + output_data_sam_hybrid['T_AddedValue'].sum(axis=0) + output_data_sam_hybrid['AddedValue'].sum(axis=0)


for elt in ['CI_dom', 'CI_imp', 'T_CI_imp', 'T_CI_dom']:
    value_2_add = mising_ci_xxx_In_enerProd_and_RegSec_with_bool_exclude * (output_data_sam_hybrid[elt].sum(axis=0) / denominator_ratio_CI_xxx_ener)[index_ener_sam_ref+[ind_otp,ind_wtp,ind_atp], :]
    if do_verbose:
        print( output_data_sam_hybrid[  elt][ ind_xxx, index_ener_sam_ref+[ind_otp,ind_wtp,ind_atp], :][3,0], value_2_add[3,0], output_data_sam_hybrid[  elt][ ind_xxx, index_ener_sam_ref+[ind_otp,ind_wtp,ind_atp], :][3,0] + value_2_add[3,0])

for elt in ['CI_dom', 'CI_imp', 'T_CI_imp', 'T_CI_dom']:    
    value_2_add = mising_ci_xxx_In_enerProd_and_RegSec_with_bool_exclude * (output_data_sam_hybrid[elt][ind_ser,:,:] / denominator_ratio_CI_xxx_ener)[index_ener_sam_ref+[ind_otp,ind_wtp,ind_atp], :]
    value_2_add = mising_ci_xxx_In_enerProd_and_RegSec_with_bool_exclude * ( np.maximum(output_data_sam_hybrid[elt][[ind_ser,ind_xxx],:,:].sum(axis=0),0) / denominator_ratio_CI_xxx_ener)[index_ener_sam_ref+[ind_otp,ind_wtp,ind_atp], :]
    output_data_sam_hybrid[  elt][ ind_xxx, index_ener_sam_ref+[ind_otp,ind_wtp,ind_atp], :] += value_2_add
    output_data_sam_hybrid[ elt][ ind_xxx, ind_xxx, :] -= value_2_add.sum(axis=0)
    if do_verbose:
        print( elt, output_data_sam_hybrid[  elt][ ind_xxx, index_ener_sam_ref+[ind_otp,ind_wtp,ind_atp], :][:,0], value_2_add[:,0], value_2_add[:,0].sum())
for elt in ['T_AddedValue', 'AddedValue']:
    for i_endo in range(len(input_dimensions_values_sam['ENDO'])):
        value_2_add = mising_ci_xxx_In_enerProd_and_RegSec_with_bool_exclude * (output_data_sam_hybrid[elt][i_endo,:,:] / denominator_ratio_CI_xxx_ener)[index_ener_sam_ref+[ind_otp,ind_wtp,ind_atp], :]
        output_data_sam_hybrid[ elt][ i_endo, index_ener_sam_ref+[ind_otp,ind_wtp,ind_atp], :] += value_2_add
        output_data_sam_hybrid[ elt][ i_endo, ind_xxx, :] -= value_2_add.sum(axis=0)
        if do_verbose:
            #print( elt, i_endo, output_data_sam_hybrid[ elt][ i_endo, index_ener_sam_ref, :][:,0], value_2_add[:,0], value_2_add[:,0].sum())
            print( elt, i_endo, output_data_sam_hybrid[ elt][ i_endo, index_ener_sam_ref+[ind_otp,ind_wtp,ind_atp], :][:,0], value_2_add[:,0], value_2_add[:,0].sum())

if do_verbose:
    for elt in ['CI_dom', 'CI_imp', 'T_CI_imp', 'T_CI_dom','T_AddedValue', 'AddedValue']:
        print( output_data_sam_hybrid[  elt][:,21,0] / denominator_ratio_CI_xxx_ener[21,0]*100)

# 8.4 - computing new production of xxx

output_data_sam_hybrid[ 'Prod'][ind_xxx, :] = (output_data_sam_hybrid['CI_imp'].sum(axis=0) + output_data_sam_hybrid['CI_dom'].sum(axis=0) + output_data_sam_hybrid['AddedValue'].sum(axis=0) + output_data_sam_hybrid['T_CI_dom'].sum(axis=0) + output_data_sam_hybrid['T_CI_imp'].sum(axis=0) + output_data_sam_hybrid['T_AddedValue'].sum(axis=0) ) [ind_xxx, :]

# 8.5 - differences in energy imports moved into imports of xxx

output_data_sam_hybrid[ 'Imp'][ ind_xxx, :] += (input_data_sam[ 'Imp'][ index_ener_sam_ref, :] - output_data_sam_hybrid[ 'Imp'][ index_ener_sam_ref, :]).sum(axis=0)
output_data_sam_hybrid[ 'Imp'][ ind_xxx, :] += (input_data_sam[ 'Imp_trans'][ index_ener_sam_ref, :] - output_data_sam_hybrid[ 'Imp_trans'][ index_ener_sam_ref, :]).sum(axis=0)
 
# 8.6 balancing imports - trade balance

output_data_sam_hybrid['T_Imp'][ind_xxx,:] += (input_data_sam['T_Imp'].sum(axis=0) - output_data_sam_hybrid['T_Imp'].sum(axis=0))

output_data_sam_hybrid[ 'Prod'] = (output_data_sam_hybrid['CI_imp'].sum(axis=0) + output_data_sam_hybrid['CI_dom'].sum(axis=0) + output_data_sam_hybrid['AddedValue'].sum(axis=0) + output_data_sam_hybrid['T_CI_dom'].sum(axis=0) + output_data_sam_hybrid['T_CI_imp'].sum(axis=0) + output_data_sam_hybrid['T_AddedValue'].sum(axis=0) )

for i_sec in [input_dimensions_values_sam['SEC'].index(sec) for sec in input_dimensions_values_sam['SEC'] if sec not in ['xxx','gas_gdt','oil','coa','ely','p_c']]:
    output_data_sam_hybrid['Imp'][i_sec,:] = output_data_sam_hybrid['C_hsld_imp'][i_sec,:] + (output_data_sam_hybrid['CI_imp'].sum(axis=1)[i_sec,:] + output_data_sam_hybrid['C_AP_imp'][i_sec,:] + output_data_sam_hybrid['FBCF_imp'][i_sec,:]) - output_data_sam_hybrid['T_Imp'][i_sec,:] - output_data_sam_hybrid['Imp_trans'][i_sec,:] - (output_data_sam_hybrid['T_AP_imp'][i_sec,:] + output_data_sam_hybrid['T_FBCF_imp'][i_sec,:] + output_data_sam_hybrid['T_Hsld_imp'][i_sec,:])

output_data_sam_hybrid['C_hsld_imp'][ind_xxx,:] = output_data_sam_hybrid['Imp'][ind_xxx,:] + output_data_sam_hybrid['Imp_trans'][ind_xxx,:] + output_data_sam_hybrid['T_Imp'][ind_xxx,:] - (output_data_sam_hybrid['CI_imp'].sum(axis=1)[ind_xxx,:] + output_data_sam_hybrid['C_AP_imp'][ind_xxx,:] + output_data_sam_hybrid['FBCF_imp'][ind_xxx,:]) + (output_data_sam_hybrid['T_AP_imp'][ind_xxx,:] + output_data_sam_hybrid['T_FBCF_imp'][ind_xxx,:] + output_data_sam_hybrid['T_Hsld_imp'][ind_xxx,:])

# This create some negative values, e.g. Africa for the import of services:
# The following lines has been written after looking at the numerical values, aggregated regions per aggregated regions
####################
# RUSTINE Xa - begin

surplus_imp = 0*output_data_sam_hybrid['C_hsld_imp']
surplus_imp_temp = np.where(output_data_sam_hybrid['C_hsld_imp'] < 0, -output_data_sam_hybrid['C_hsld_imp']+1e-16, 0)
for reg_Im in ['AFR']:
    for reg in dict_Im_region[reg_Im]:
        surplus_imp[:, output_dimensions_values_sam_hybrid['REG'].index(reg)] = surplus_imp_temp[:, output_dimensions_values_sam_hybrid['REG'].index(reg)]

#surplus_imp_temp = np.where(output_data_sam_hybrid['C_hsld_imp'] < output_data_sam_hybrid['T_Hsld_imp'], 1.1 * (output_data_sam_hybrid['T_Hsld_imp']-output_data_sam_hybrid['C_hsld_imp']),0)
surplus_imp_temp = np.where(output_data_sam_hybrid['C_hsld_imp'] < output_data_sam_hybrid['T_Hsld_imp'], 1.9/0.9 * output_data_sam_hybrid['T_Hsld_imp']-output_data_sam_hybrid['C_hsld_imp'],0)
for reg_Im in ['MDE']:
    for reg in dict_Im_region[reg_Im]:
        ind_reg=output_dimensions_values_sam_hybrid['REG'].index(reg)
        for sec in ['ser','xxx']:
            ind_sec=output_dimensions_values_sam_hybrid['SEC'].index(sec)
            surplus_imp[ind_sec,ind_reg] = surplus_imp_temp[ind_sec,ind_reg]

output_data_sam_hybrid['C_hsld_imp'] += surplus_imp
output_data_sam_hybrid['Imp'] += surplus_imp
output_data_sam_hybrid['Exp'] += surplus_imp
output_data_sam_hybrid['T_Exp'] += surplus_imp * output_data_sam_hybrid['T_Exp'] / output_data_sam_hybrid['Exp']
output_data_sam_hybrid['T_Exp'] = np.where( np.isnan( output_data_sam_hybrid['T_Exp']), 0, output_data_sam_hybrid['T_Exp'])

# RUSTINE Xa - end
####################

for i_sec in [input_dimensions_values_sam['SEC'].index(sec) for sec in input_dimensions_values_sam['SEC'] if sec not in ['xxx']]:
    missing_Exp_TB = -(output_data_sam_hybrid['Exp'][i_sec,:] - output_data_sam_hybrid['Imp'][i_sec,:]).sum()
    output_data_sam_hybrid['Exp'][i_sec,:] += missing_Exp_TB * output_data_sam_hybrid['Exp'][i_sec,:] / output_data_sam_hybrid['Exp'][i_sec,:].sum()
missing_Exp_TB = output_data_sam_hybrid['Imp_trans'].sum() + output_data_sam_hybrid['Imp'].sum() - (output_data_sam_hybrid['Exp'].sum() + output_data_sam_hybrid['Exp_trans'].sum())
output_data_sam_hybrid['Exp'][ind_xxx,:] += missing_Exp_TB * output_data_sam_hybrid['Exp'][[ind_ser,ind_xxx],:].sum(axis=0) / output_data_sam_hybrid['Exp'][[ind_ser,ind_xxx],:].sum()

for i_sec in [input_dimensions_values_sam['SEC'].index(sec) for sec in input_dimensions_values_sam['SEC']]:
    output_data_sam_hybrid['C_hsld_dom'][i_sec,:] = output_data_sam_hybrid['Prod'][i_sec,:] + output_data_sam_hybrid['T_prod'][i_sec,:] - (output_data_sam_hybrid['CI_dom'].sum(axis=1)[i_sec,:] + output_data_sam_hybrid['C_AP_dom'][i_sec,:] + output_data_sam_hybrid['FBCF_dom'][i_sec,:] + output_data_sam_hybrid['Exp'][i_sec,:] + output_data_sam_hybrid['Exp_trans'][i_sec,:]) + output_data_sam_hybrid['T_AP_dom'][i_sec,:] + output_data_sam_hybrid['T_FBCF_dom'][i_sec,:] + output_data_sam_hybrid['T_Exp'][i_sec,:] + output_data_sam_hybrid['T_Hsld_dom'][i_sec,:]

# This create negative value for some region with small consumption, e.g., India households consumption of Iron and steel
# The following lines has been written after seeing the numerical values
####################
# RUSTINE Xb - begin

surplus_dom_temp = np.where(output_data_sam_hybrid['C_hsld_dom'] < 0, -output_data_sam_hybrid['C_hsld_dom']+1e-16, 0)
surplus_dom = 0*surplus_dom_temp
for reg_Im in ['IND','CAN']:
    for reg in dict_Im_region[reg_Im]:
        surplus_dom[:, output_dimensions_values_sam_hybrid['REG'].index(reg)] = surplus_dom_temp[:, output_dimensions_values_sam_hybrid['REG'].index(reg)]

output_data_sam_hybrid['C_hsld_dom'] += surplus_dom
output_data_sam_hybrid['Exp'] -= surplus_dom
output_data_sam_hybrid['T_Exp'] -= surplus_imp * output_data_sam_hybrid['T_Exp'] / output_data_sam_hybrid['Exp']
output_data_sam_hybrid['T_Exp'] = np.where( np.isnan( output_data_sam_hybrid['T_Exp']), 0, output_data_sam_hybrid['T_Exp'])

# RUSTINE Xb - end
####################

if do_verbose:
    print("Differences in Uses: ",  aggregation_GTAP.SAM_Uses(  output_data_sam_hybrid).sum()- aggregation_GTAP.SAM_Uses(  input_data_sam).sum(), "(0 means we did a great job)")

if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 9: rebalancing Resources:')

# normally Ressources are already balanced because in the line above we rebalance Imports and Domestique ressources-uses equilibrium

# here we assume an equivalent repartition depending on the econmic added value composition for each region
# it might be biased, for example for countries with high natrual ressources rents
# those computation only concerns sectors (and regions) on which we had to apply a "RUSTINE"

#for rebalancing all other sector: useful for debugging
#for sec in input_dimensions_values_sam['SEC']:
for sec in ['wtp','otp','atp','twl','xxx']:
    ind_sec = input_dimensions_values_sam['SEC'].index(sec)
    excess_ressource_sec =  (aggregation_GTAP.SAM_Resources(  output_data_sam_hybrid) - aggregation_GTAP.SAM_Uses(  output_data_sam_hybrid))[ind_sec, :]
    denominator_ratio = (output_data_sam_hybrid['AddedValue'][ :, ind_sec, :].sum(axis=0) + output_data_sam_hybrid['T_AddedValue'][ :, ind_sec, :].sum(axis=0))
    for i in range( output_data_sam_hybrid['AddedValue'].shape[0]):
        output_data_sam_hybrid['AddedValue'][ i, ind_sec, :] -= output_data_sam_hybrid['AddedValue'][ i, ind_sec, :] / denominator_ratio * excess_ressource_sec
        output_data_sam_hybrid['T_AddedValue'][i, ind_sec, :] -= output_data_sam_hybrid['T_AddedValue'][ i, ind_sec, :] / denominator_ratio * excess_ressource_sec

if do_verbose:
    print("Differences in Resources: ",  aggregation_GTAP.SAM_Resources(  output_data_sam_hybrid).sum()- aggregation_GTAP.SAM_Resources(  input_data_sam).sum(), "(0 means we did a great job); which is ", (aggregation_GTAP.SAM_Resources(  output_data_sam_hybrid).sum()- aggregation_GTAP.SAM_Resources(  input_data_sam).sum())/ aggregation_GTAP.SAM_Resources(  output_data_sam_hybrid).sum()*100, "%" )
if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 10: checking balances:\n')

orginal_SAM_sum = 0
hybrid_SAM_sum = 0

for elt in input_data_sam.keys():
    orginal_SAM_sum += input_data_sam[elt].sum()
    hybrid_SAM_sum += output_data_sam_hybrid[elt].sum()
    if do_verbose:
        print("Differences in SAM element " + elt + ": ", (output_data_sam_hybrid[elt].sum()-input_data_sam[elt].sum()) / input_data_sam[elt].sum()*100)
    #print("Differences in SAM element " + elt + ": ", (output_data_sam_hybrid[elt].sum()-input_data_sam[elt].sum()) )
    if len(output_data_sam_hybrid[elt].shape) == 2:
        #print("Differences in SAM element " + elt + ": ", (output_data_sam_hybrid[elt][index_ener_sam_ref,:].sum(axis=1)-input_data_sam[elt][index_ener_sam_ref,:].sum(axis=1)) / input_data_sam[elt][index_ener_sam_ref,:].sum(axis=1)*100)
        #print("Differences in SAM element " + elt + ": ", (output_data_sam_hybrid[elt][index_ener_sam_ref,:].sum(axis=1)-input_data_sam[elt][index_ener_sam_ref,:].sum(axis=1)) / input_data_sam[elt][index_ener_sam_ref,:].sum(axis=1)*100)
        #print("Differences in SAM element " + elt + ": ", (input_data_sam[elt][0,0] - output_data_sam_hybrid[elt][0,0]) / input_data_sam[elt][0,0]*100) 
        pass



if do_verbose:
    print("\nDifferences in total SAM (%): ", (hybrid_SAM_sum-orginal_SAM_sum)/orginal_SAM_sum*100)

    print("\nRatio Uses / Resources (==1?): ", aggregation_GTAP.SAM_Uses(  output_data_sam_hybrid).sum(axis=1) / aggregation_GTAP.SAM_Resources(  output_data_sam_hybrid).sum(axis=1))

# Checking GDP changes

initial_global_GDP = 0
final_global_GDP = 0
list_elt_GDP = [elt for elt in output_data_sam_hybrid.keys() if ('T_' in elt or 'AddedValue' in elt)]
for elt in list_elt_GDP:
    initial_global_GDP += input_data_sam[ elt].sum()
    final_global_GDP += output_data_sam_hybrid[ elt].sum()

if do_verbose:
    print("\nGlobal GDP variation because of the hybridation procedure: ", (final_global_GDP-initial_global_GDP) / initial_global_GDP *100, "%")

initial_GDP = 0
final_GDP = 0
for elt in list_elt_GDP:
    if len(input_data_sam[ elt].shape)==3:
        initial_GDP += input_data_sam[ elt].sum(axis=0).sum(axis=0)
        final_GDP += output_data_sam_hybrid[ elt].sum(axis=0).sum(axis=0)
    else:
        initial_GDP += input_data_sam[ elt].sum(axis=0) 
        final_GDP += output_data_sam_hybrid[ elt].sum(axis=0)
gdp_variation = (final_GDP-initial_GDP) / initial_GDP *100
print("\nGDP variation: max ", np.max( np.abs(gdp_variation)), "Regions", gdp_variation)

gdp_var_Im = {}
for reg_Im in dict_Im_region.keys():
    ind_reg = [input_dimensions_values_sam['REG'].index(reg) for reg in dict_Im_region[reg_Im]]
    gdp_var_Im[reg_Im] = (final_GDP[ind_reg].sum() - initial_GDP[ind_reg].sum() ) / initial_GDP[ind_reg].sum()*100
print("\nGDP variation at the Imaclim Regional level:", gdp_var_Im)

if do_verbose:
    print('\n//////////////////////////////////////')
    print('     ---> STEP 11: Export results:\n')

if False: # set to True in order to erase hybridation by non hybridation data. # used for debugging
    for var in input_data_sam.keys():
        output_data_sam_hybrid[var] = input_data_sam[var]

output_variables_dimensions_info = {}
for variable_name in output_data_sam_hybrid:
    output_variables_dimensions_info[variable_name] = '*'.join(output_data_dimensions_sam_hybrid[variable_name])

if args.output_file is not None:
    aggregation_GTAP.filter_dimensions_and_export_dimensions_tables( args.output_file, output_dimensions_values_sam_hybrid, output_data_sam_hybrid, output_variables_dimensions_info, var_list= list(output_data_sam_hybrid.keys()) )

