#! /usr/bin/env python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Nicolas Graves, Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


# This script import 

import sys
import os
import argparse
import copy
import numpy as np
import common_cired
import aggregation_GTAP

parser = argparse.ArgumentParser('compute balances GTAP')

parser.add_argument('data_path')
parser.add_argument('output_dir')

args = parser.parse_args()

CI_variables_list = ['CI_imp','CI_dom','T_CI_imp','T_CI_dom']
#CI_variables_cor_list = [variable_name+'_cor' for variable_name in CI_variables_list]

SAM_exported_variables_list = CI_variables_list + ['C_hsld_dom','C_AP_dom','FBCF_dom','T_FBCF_dom','T_Hsld_dom','T_AP_dom',
'C_hsld_imp','C_AP_imp','FBCF_imp','T_FBCF_imp','T_Hsld_imp','T_AP_imp','Exp_trans_only','Exp_trans', 'Auto_TMX',
'Exp','T_Exp','Imp','Imp_trans','T_Imp']
bilateral_list = ['Imp_bil','Exp_bil','T_Imp_bil','T_Exp_bil','Imp_trans_bil']

prod_variables_list = ['Prod', 'T_prod']

#bilateral_cor_list = [variable_name+'_cor' for variable_name in bilateral_list]
fuel_sector_variable_list = ['Emiss_DomProd'] # Variable in physical quantities
energy_sector_variable_list = ['Energy_UsagFirm'] # Variable in physical quantities

dataPath = args.data_path
outputdir = args.output_dir

common_cired.mkdir_exists(outputdir)


print('\n//////////////////////////////////////')
print('Load Gtap datas:')
print('//////////////////////////////////////\n')

input_data, input_dimensions_values, input_data_dimensions = aggregation_GTAP.read_dimensions_tables_file(dataPath)

#----------------------------------------------------------------------------------
print('\n//////////////////////////////////////')
print('Check the equilibirum of the SAM:')
print('//////////////////////////////////////\n')

sector_list = input_dimensions_values['TRAD_COMM']
sector_Cgds_list = input_dimensions_values['PROD_COMM']
endowments_list = input_dimensions_values['ENDW_COMM']
transports_list = input_dimensions_values['MARG_COMM']
transports_indices = [sector_list.index(transport_sector) for transport_sector in transports_list]

# input_data
domCons_PublicAdmi_aPr = input_data['VDGA'] # Government Domestic Purchases at Agents' Prices
impCons_PublicAdmi_aPr = input_data['VIGA'] # Governments Imports at Agents' Prices
domCons_Households_aPr = input_data['VDPA'] # Private Households - Domestic Purchases at Agents' Prices
impCons_Households_aPr = input_data['VIPA'] # Private Households - Imports at Agents' Prices
dom_CI_Firms_aPr = input_data['VDFA'] # Intermediate- Firms' Domestic Purchases at Agents' Prices
imp_CI_Firms_aPr = input_data['VIFA'] # Intermediate- Firms' Imports at Agents' Prices
dom_CI_Firms_mPr = input_data['VDFM'] # Intermediate- Firms' Domestic Purchases at Market Price
imp_CI_Firms_mPr = input_data['VIFM'] # Intermediate- Firms' Imports at Market Price
firms_Endowments_mPr = input_data['VFM'] # Endowments-Firm's Purchases at Market Prices
export_Transportation_mPr  = input_data['VST'] # Trade-Exports for International Transportation at Market Prices

domCons_PublicAdmi_mPr = input_data['VDGM'] # Government Domestic Purchases at market Prices
impCons_PublicAdmi_mPr = input_data['VIGM'] # Governments Imports at market Prices
domCons_Households_mPr = input_data['VDPM'] # Private Households - Domestic Purchases at market Prices
impCons_Households_mPr = input_data['VIPM'] # Private Households - Imports at market Prices

Exports_BT_wPr = input_data['VXWD'] #Bilateral Exports at World Prices
Imports_BT_mPr = input_data['VIMS'] #Bilateral Imports at Market Prices

FactBasedSubsidies = input_data['FBEP'] #Protection - Factor-Based Subsidies
OrdOutputSubsidies = input_data['OSEP'] # Ordinary Output Subsidies
InterInputSubsidies = input_data['ISEP'] #Protection - Intermediate Input Subsidies
Taxes_factorEmplTaxRev  = input_data['FTRV'] #Taxes - Factor Employment Tax Revenue

# baseview results
outputValue = input_data['CM04'] # Value of output
cons_CostStruct = input_data['SF02'] # Cost structure of consumption
gov_CostStruct = input_data['SF03'] # Cost structure of government
firm_CostStruct = input_data['SF01'] # Cost structure of firms
tradeExp = input_data['BI01']
tradeImp = input_data['BI02']
tradeCIFdecomposition = input_data['BI03']

if 'EDF' in input_data:
    Energy_UsagFirm_CGDS = input_data['EDF'] #usage of domestic product by firms, Mtoe
    Energy_UsagFirm = Energy_UsagFirm_CGDS[:,0:(len(sector_Cgds_list)-1),:]

if 'MDF' in input_data:
    Emiss_DomProd_CGDS = input_data['MDF'] #emissions from domestic product in current production, Mt CO2
    Emiss_DomProd = Emiss_DomProd_CGDS[:,0:(len(sector_Cgds_list)-1),:]

# Variables of the SAM
# Resources :
CI_imp = imp_CI_Firms_mPr[:,0:(len(sector_Cgds_list)-1),:] 
CI_dom = dom_CI_Firms_mPr[:,0:(len(sector_Cgds_list)-1),:]
C_hsld_dom = domCons_Households_aPr
C_hsld_imp = impCons_Households_aPr
C_AP_dom = domCons_PublicAdmi_aPr
C_AP_imp = impCons_PublicAdmi_aPr
FBCF_dom = dom_CI_Firms_aPr[:,(len(sector_Cgds_list)-1),:]
FBCF_imp = imp_CI_Firms_aPr[:,(len(sector_Cgds_list)-1),:]
AddedValue = firms_Endowments_mPr[:,0:(len(sector_Cgds_list)-1),:]
Exp_trans_only = export_Transportation_mPr
# same as Exp_trans_only but with 0 for other sectors
Exp_trans = np.zeros([len(sector_list), export_Transportation_mPr.shape[1]], dtype=np.float)
Exp_trans[transports_indices,:] = export_Transportation_mPr
Exp_bil = tradeExp[:,:,:,0] + tradeExp[:,:,:,1]
Exp = Exp_bil.sum(axis=2)
Prod = outputValue[:,:,0]

# Uses :
#CI_imp, CI_dom
T_Exp_bil = tradeExp[:,:,:,1]
T_Exp =T_Exp_bil.sum(axis=2)
Imp_bil = tradeCIFdecomposition[:,:,:,0]
Imp = Imp_bil.sum(axis=1)
Imp_trans_bil = tradeCIFdecomposition[:,:,:,1]
Imp_trans = Imp_trans_bil.sum(axis=1)
T_Imp_bil = tradeImp[:,:,:,1]
T_Imp = T_Imp_bil.sum(axis=1)
T_prod = outputValue[:,:,1]
T_AddedValue = firm_CostStruct[0:(len(endowments_list)),0:(len(sector_Cgds_list)-1),:,0,1]
T_CI_dom = firm_CostStruct[(len(endowments_list)):(len(endowments_list)+len(sector_list)),0:(len(sector_Cgds_list)-1),:,0,1]
T_CI_imp = firm_CostStruct[(len(endowments_list)):(len(endowments_list)+len(sector_list)),0:(len(sector_Cgds_list)-1),:,1,1]
T_FBCF_imp = imp_CI_Firms_aPr[:,(len(sector_Cgds_list)-1),:] - imp_CI_Firms_mPr[:,(len(sector_Cgds_list)-1),:]
T_FBCF_dom = dom_CI_Firms_aPr[:,(len(sector_Cgds_list)-1),:] - dom_CI_Firms_mPr[:,(len(sector_Cgds_list)-1),:]
T_Hsld_dom = domCons_Households_aPr - domCons_Households_mPr
T_Hsld_imp = impCons_Households_aPr - impCons_Households_mPr
T_AP_dom = domCons_PublicAdmi_aPr - domCons_PublicAdmi_mPr
T_AP_imp = impCons_PublicAdmi_aPr - impCons_PublicAdmi_mPr

#----------------------------------------------------------------------------------
Auto_Import_trans = np.diagonal(Imp_trans_bil,axis1=1,axis2=2)
Auto_Texp = np.diagonal(T_Exp_bil,axis1=1,axis2=2)
Auto_Timp = np.diagonal(T_Imp_bil,axis1=1,axis2=2)
Auto_TMX = Auto_Texp + Auto_Timp

added_value_endowments_list = ['AddedValue', 'T_AddedValue']
# check and output balance
dict_SAM_var = {}
for elt in SAM_exported_variables_list + prod_variables_list + added_value_endowments_list:
    if elt not in dict_SAM_var:
        exec('SAM_var_matrix = ' + elt)
        dict_SAM_var[elt] = SAM_var_matrix

Resources, Uses, Balance, Balance_Imp, Balance_Dom = aggregation_GTAP.CheckSAMBalance(dict_SAM_var, Auto_TMX=0)

#----------------------------------------------------------------------------------

energy_balance_variables_list = ['EDF', 'EDG', 'EDP', 'EIF', 'EIG', 'EIP', 'EXI']
if 'ERG_COMM' in input_dimensions_values:
    do_energy_balance = True
    for energy_balance_variable in energy_balance_variables_list:
        if energy_balance_variable not in input_data:
            do_energy_balance = False
            break
    if do_energy_balance:
        print('\n//////////////////////////////////////')
        print('Check the equilibrium of energy balance:')
        print('//////////////////////////////////////\n')
        #written for compatibility with GTAP10

        domEVol_Cons_Firms = input_data['EDF'] #usage of domestic product by firms, Mtoe
        domEVol_Cons_PublicAdmi = input_data['EDG'] #government consumption of domestic product, Mtoe
        domEVol_Cons_Households = input_data['EDP'] #private consumption of domestic product, Mtoe

        impEVol_Cons_Firms = input_data['EIF'] #usage of imports by firms, Mtoe
        impEVol_Cons_PublicAdmi = input_data['EIG'] #government consumption of imports, Mtoe
        impEVol_Cons_Households = input_data['EIP'] #private consumption of imports, Mtoe

        tradeEVol = input_data['EXI'] #volume of trade, Mtoe

        nb_energies = len(input_dimensions_values['ERG_COMM'])
        TPES = np.zeros(nb_energies)
        for k in range(nb_energies):
            TPES[k] = np.sum(domEVol_Cons_PublicAdmi[k,:]+impEVol_Cons_PublicAdmi[k,:]+domEVol_Cons_Households[k,:]+impEVol_Cons_Households[k,:])+np.sum(domEVol_Cons_Firms[k,:,:])+np.sum(impEVol_Cons_Firms[k,:,:])

        print(TPES)

#----------------------------------------------------------------------------------
print('\n//////////////////////////////////////')
print('Export results:')
print('//////////////////////////////////////\n')

print('...exporting the SAM aggregated datas into csv')

print(' Info : CI, and T_CI, by region will have dimenssions (input sector, output sector) in 2D outputs files')
print(' Info : Imp, Exp, T_imp and T_Exp, is originally (sector, export region, import region)')
print(' Bilateral variables Imp_bil_cor, Exp_bil_cor, T_Imp_bil_cor, T_Exp_bil_cor, will will have outputs by exporting region with dimenssions (import country, output sector) in 2D outputs files')

dict_export_var = {}
dict_results_endowments = aggregation_GTAP.ExtractEndowmentTables(endowments_list, AddedValue, T_AddedValue)
for variable_name in dict_results_endowments:
    dict_export_var[variable_name] = dict_results_endowments[variable_name]

listExportVarNames = prod_variables_list # Prod can be computed within common_code/bin/aggregate_GTAP_table_file.py if not here

listExportEmisNames = []

listExportVarNames += sorted(dict_results_endowments)
listExportVarNames += SAM_exported_variables_list

# we export both the endowments per factor and with all
# the factors.  Endowments per factors variables
# are exported as individual tables, added_value_endowments_list
# variables can be used more easily in downstream codes
listExportVarNames += added_value_endowments_list

if 'EDF' in input_data:
    listExportVarNames.append('Energy_UsagFirm')

if 'MDF' in input_data:
    listExportEmisNames.append('Emiss_DomProd')

listExportVarNames += bilateral_list

for elt in listExportVarNames + listExportEmisNames:
    if elt not in dict_export_var:
        exec('exported_var_matrix = ' + elt)
        dict_export_var[elt] = exported_var_matrix

# also export primary variables related to emissions
primary_emissions_variables_list = ['MDG', 'MDP', 'MIF', 'MIG', 'MIP'] 
for variable_name in primary_emissions_variables_list:
    if variable_name in input_data:
        listExportEmisNames.append(variable_name)
        dict_export_var[variable_name] = input_data[variable_name]

SAM_dimension_map = {
  'SEC': 'TRAD_COMM',
  'ENDO': 'ENDW_COMM',
  'TRANSP': 'MARG_COMM',
  'FUEL': 'FUEL_COMM',
  'ENER': 'ERG_COMM',
}

SAM_dimension_values = copy.deepcopy(input_dimensions_values)

for SAM_dimension in SAM_dimension_map:
    if SAM_dimension_map[SAM_dimension] in input_dimensions_values:
        SAM_dimension_values[SAM_dimension] = input_dimensions_values[SAM_dimension_map[SAM_dimension]]

SAM_variables_dimensions_info = {}
for variable_name in input_data_dimensions:
    SAM_variables_dimensions_info[variable_name] = '*'.join(input_data_dimensions[variable_name])

for variable_name in CI_variables_list:
    SAM_variables_dimensions_info[variable_name] = 'SEC*SEC*REG'

for variable_name in bilateral_list:
    SAM_variables_dimensions_info[variable_name] = 'SEC*REG*REG'

for variable_name in fuel_sector_variable_list:
    SAM_variables_dimensions_info[variable_name] = 'FUEL*SEC*REG'

for variable_name in energy_sector_variable_list:
    SAM_variables_dimensions_info[variable_name] = 'ENER*SEC*REG'

for variable_name in added_value_endowments_list:
    SAM_variables_dimensions_info[variable_name] = 'ENDO*SEC*REG'

for variable_name in ['Exp_trans_only']:
    SAM_variables_dimensions_info[variable_name] = 'TRANSP*REG'

for variable_name in set(listExportVarNames) - set(SAM_variables_dimensions_info):
    SAM_variables_dimensions_info[variable_name] = 'SEC*REG'

SAM_input_dimensions_values = aggregation_GTAP.filter_dimensions_and_export_dimensions_tables(outputdir + 'SAMs.csv', SAM_dimension_values, dict_export_var, SAM_variables_dimensions_info, var_list=listExportVarNames)

print(" nr of emission variables: "+str(len(listExportEmisNames)))
if len(listExportEmisNames) != 0:
    emissions_input_dimensions_values = aggregation_GTAP.filter_dimensions_and_export_dimensions_tables(outputdir + 'Emissions.csv', SAM_dimension_values, dict_export_var, SAM_variables_dimensions_info, var_list=listExportEmisNames)


#----------------------------------------------------------------------------------
print('\n\n         ***** THE END OF EVERYTHING ******:')

