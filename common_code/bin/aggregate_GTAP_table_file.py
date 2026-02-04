#! /usr/bin/env python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


# original author: Florian Leblanc

import argparse
import os
import sys
import copy
import numpy as np
import common_cired
import aggregation_GTAP

#import time

# %run /data/public_data/common_code/bin/aggregate_GTAP_table_file.py /data/shared/GTAP/results/extracted_GTAP6/SAMs.csv ./outputs_GTAP/

parser = argparse.ArgumentParser('aggregate GTAP data')

parser.add_argument('--region-aggregation')
parser.add_argument('--sector-aggregation')
parser.add_argument('--fuels-aggregation')
parser.add_argument('--energy-aggregation')
parser.add_argument('--separate-tables-dir')
parser.add_argument('--separate-variable-dir')
parser.add_argument('--separate-variable-list')
parser.add_argument('--sam-for-excel')
parser.add_argument('--output-file')
parser.add_argument('--complete-rules', action='store_true')
parser.add_argument('--correct-self-import', action='store_true', help='correct for self-importation at the aggregate level')
parser.add_argument('input_file')

args = parser.parse_args()

# Prod can also be generated based on the other variables
production_resources_list = ['Prod']
production_uses_list = ['T_prod']
production_list = production_resources_list + production_uses_list

CI_variables_resources_list = ['CI_imp','CI_dom']
CI_variables_uses_list = ['T_CI_imp','T_CI_dom']
CI_variables_list = CI_variables_resources_list + CI_variables_uses_list

bilateral_resources_list = ['Exp_bil']
bilateral_uses_list = ['Imp_bil', 'T_Imp_bil','T_Exp_bil','Imp_trans_bil']
bilateral_list = bilateral_resources_list + bilateral_uses_list

SAM_resources_list = ['C_hsld_dom','C_AP_dom','FBCF_dom', 'C_hsld_imp','C_AP_imp','FBCF_imp', 'Exp_trans']
SAM_uses_list = ['T_FBCF_dom','T_Hsld_dom','T_AP_dom', 'T_FBCF_imp','T_Hsld_imp','T_AP_imp']
aggregated_SAM_list = ['Exp','T_Exp','Imp','Imp_trans', 'T_Imp']
computed_SAM_list = ['Auto_TMX']
generated_SAM_list = computed_SAM_list + aggregated_SAM_list

added_value_endowments_resources_list = ['AddedValue']
added_value_endowments_uses_list = ['T_AddedValue']
added_value_endowments_list = added_value_endowments_resources_list + added_value_endowments_uses_list

variable_2correct_list = CI_variables_list + SAM_resources_list + SAM_uses_list + aggregated_SAM_list

SAM_resources_variables_list = CI_variables_resources_list + bilateral_resources_list + SAM_resources_list + added_value_endowments_resources_list
SAM_uses_variables_list = production_uses_list + CI_variables_uses_list + bilateral_uses_list + SAM_uses_list + added_value_endowments_uses_list

# variables that must be found in the input data
input_SAM_variables_list = SAM_resources_variables_list + SAM_uses_variables_list

generated_SAM_variables_dimensions = ['SEC', 'REG']

generated_variables_mapping = {}
for variable_name in variable_2correct_list + bilateral_list:
    generated_variables_mapping[variable_name+'_cor'] = variable_name

variable_2correct_cor_list = [variable_name+'_cor' for variable_name in variable_2correct_list]
bilateral_cor_list = [variable_name+'_cor' for variable_name in bilateral_list]

#----------------------------------------------------------------------------------

# Setup dimension aggregation information, a list of 
#  the aggregation dictionary itself, 
#  the name of the dictionary aggregate element in order, 
#  the reference (not aggregated element) list in order
# for dimension_name, using aggregation_dimension_file_path
# for the aggregation if not None.
def setup_dimension_aggregations_informations(aggregation_dimension_file_path, dimension_name, dimensions_values, dimensions_aggregation_informations, complete_rules):
    if dimension_name not in dimensions_values:
        return
    difference_in_coverage = False
    if not dimension_name in ['TRAD_COMM','DEMD_COMM','REG','SEC','ERG_COMM','PROD_COMM','ENER','FUEL','FUEL_COMM']: # complete_rules only for regions and sectors
        complete_rules = False
    refList = dimensions_values[dimension_name]
    if aggregation_dimension_file_path is not None:
        d_delimiter = aggregation_GTAP.detect_csv_file_delimiter(aggregation_dimension_file_path)
        aggregates_names_list = []
        aggregation_dict, unused_aggregated = common_cired.process_aggregation_file_lines(aggregation_dimension_file_path, aggregates_list=aggregates_names_list, keep_order=True, allow_empty_aggregated=False, delimiter=d_delimiter)
        if complete_rules:
            aggregation_dict, aggregates_names_list = complete_missing_aggregation_coverage(aggregation_dimension_file_path, aggregation_dict, aggregates_names_list, refList)
        difference_in_coverage = check_aggregation_and_data_coverage(aggregation_dimension_file_path, aggregation_dict, aggregates_names_list, refList, d_delimiter)
        if not difference_in_coverage:
            print('... loaded '+dimension_name+': '+aggregation_dimension_file_path+' successfully')
    else:
        aggregation_dict = None
        aggregates_names_list = refList
    aggregation_information = [aggregation_dict, aggregates_names_list, refList]
    dimensions_aggregation_informations[dimension_name] = aggregation_information

def check_aggregation_and_data_coverage(aggregation_dimension_file_path, aggregation_dict, aggregates_list, refList, d_delimiter):
    # check that there is no double in aggregates list
    if len(set(refList)) < len(refList):
        sys.stderr.write(common_cired.encode_output_string('WARNING: '+aggregation_dimension_file_path+': duplicate aggregates items\n'))
    # controls to check if dictionaries are really complete
    aggregated_items_set = set(common_cired.aggregation_reverse_map(aggregation_dict))
    difference_in_coverage = False
    items_in_refList_not_in_aggregated_items_set = set(refList) - aggregated_items_set
    if len(items_in_refList_not_in_aggregated_items_set) > 0 :
        # FIXME does not check that elements are present only once in aggregation
        sys.stderr.write(common_cired.encode_output_string('WARNING: '+aggregation_dimension_file_path+': missing in aggregation: '+d_delimiter.join(sorted(items_in_refList_not_in_aggregated_items_set))+"\n"))
        difference_in_coverage = True
    items_in_aggregated_items_set_not_in_refList = aggregated_items_set - set(refList)
    if len(items_in_aggregated_items_set_not_in_refList) > 0:
        sys.stderr.write(common_cired.encode_output_string('WARNING: '+aggregation_dimension_file_path+': in agregation not in data: '+d_delimiter.join(sorted(items_in_aggregated_items_set_not_in_refList))+"\n"))
        difference_in_coverage = True
    return difference_in_coverage

def complete_missing_aggregation_coverage(aggregation_dimension_file_path, aggregation_dict, aggregates_list, refList):
    completed_aggregation_dict = copy.deepcopy(aggregation_dict)
    completed_aggregates_list = list(aggregates_list)
    aggregated_items_set = set(common_cired.aggregation_reverse_map(aggregation_dict))
    #for elt in list(set(refList) - aggregated_items_set):
    for elt in refList:
        if elt not in aggregated_items_set:
            completed_aggregation_dict[elt] = [elt]
            completed_aggregates_list.append(elt)
    return completed_aggregation_dict, completed_aggregates_list

#----------------------------------------------------------------------------------

print('\n//////////////////////////////////////')
print('Load input data:')
print('//////////////////////////////////////\n')

input_data, input_dimensions_values, input_data_dimensions = aggregation_GTAP.read_dimensions_tables_file(args.input_file)

# complete 

generated_variables_list = generated_SAM_list

generated_variables_dimensions = {}
for variable_name in generated_variables_list:
    generated_variables_dimensions[variable_name] = generated_SAM_variables_dimensions

print('\n//////////////////////////////////////')
print('Loads aggregation dictionnaries:')
print('//////////////////////////////////////\n')

aggregation_dimension_file_paths = {
  'REG': args.region_aggregation,
  'SEC': args.sector_aggregation,
  'PROD_COMM': args.sector_aggregation,
  'FUEL': args.fuels_aggregation,
  'FUEL_COMM': args.fuels_aggregation,
  'ENER': args.energy_aggregation,
  'ERG_COMM': args.energy_aggregation,
  # may want to use another aggregation for that dimension
  #'TRAD_COMM': args.sector_aggregation,
  #'DEMD_COMM': both sectors and endowments
}

# The aggregation information is a list of 3 element
# for each dimension in dimensions_aggregation_informations:
#  the aggregation dictionary itself, 
#  the name of the dictionary aggregate element in order, 
#  the reference (not aggregated element) list in order

dimensions_aggregation_informations = {}

for dimension_name in input_dimensions_values:
    if dimension_name in aggregation_dimension_file_paths:
        aggregation_dimension_file_path = aggregation_dimension_file_paths[dimension_name]
    else:
        aggregation_dimension_file_path = None
    setup_dimension_aggregations_informations(aggregation_dimension_file_path, dimension_name, input_dimensions_values, dimensions_aggregation_informations, args.complete_rules)

# this dimension is dependent on the sector dimensions. 
# FIXME same for MARG_COMM
if 'TRANSP' in input_dimensions_values:
    sector_aggregation = dimensions_aggregation_informations['SEC'][0]
    if sector_aggregation is not None:
        # reset what setup_dimension_aggregations_informations set
        aggregated_sector_aggregate = common_cired.aggregation_reverse_map(sector_aggregation)
        output_transport_dimension_values = sorted(set([aggregated_sector_aggregate[transport_sector] for transport_sector in input_dimensions_values['TRANSP']]))
        sub_sector_aggregation = {}
        for output_transport_dimension_value in output_transport_dimension_values:
            sub_sector_aggregation[output_transport_dimension_value] = sector_aggregation[output_transport_dimension_value]
        dimensions_aggregation_informations['TRANSP'] = [sub_sector_aggregation, output_transport_dimension_values, input_dimensions_values['TRANSP']]


#----------------------------------------------------------------------------------

print('\n//////////////////////////////////////')
print('Aggregate Data:')
print('//////////////////////////////////////\n')


aggregate_variables_values = {}
for variable_name in set(input_data) - set([var for var in set(generated_variables_list) if not (var in aggregated_SAM_list and var in set(input_data))]):
    aggregate_variables_values[variable_name] = aggregation_GTAP.aggregate_variable_dimensions(variable_name, input_data, input_data_dimensions, dimensions_aggregation_informations)

# SAM variables computed as sums if not already present.
# resources
if 'Exp_bil' in input_data and not 'Exp' in input_data:
    aggregate_variables_values['Exp'] = aggregate_variables_values['Exp_bil'].sum(axis=2)

# uses
if 'Imp_bil' in input_data and not 'Imp' in input_data:
    aggregate_variables_values['Imp'] = aggregate_variables_values['Imp_bil'].sum(axis=1)
if 'T_Exp_bil' in input_data and not 'T_Exp' in input_data:
    aggregate_variables_values['T_Exp'] = aggregate_variables_values['T_Exp_bil'].sum(axis=2)
if 'Imp_trans_bil' in input_data and not 'Imp_trans' in input_data:
    aggregate_variables_values['Imp_trans'] = aggregate_variables_values['Imp_trans_bil'].sum(axis=1)
if 'T_Imp_bil' in input_data and not 'T_Imp' in input_data:
    aggregate_variables_values['T_Imp'] = aggregate_variables_values['T_Imp_bil'].sum(axis=1)

# production can also be computed as a sum of other variables
if 'Prod' not in input_data:
    prod_as_aggregation_aggregated_variables = ['CI_imp', 'CI_dom', 'AddedValue', 'T_AddedValue', 'T_CI_dom', 'T_CI_imp']
    if set(prod_as_aggregation_aggregated_variables) & set(aggregate_variables_values) == set(prod_as_aggregation_aggregated_variables):
        aggregate_variables_values['Prod'] = aggregate_variables_values[prod_as_aggregation_aggregated_variables[0]].sum(axis=0)
        for var_for_prod in prod_as_aggregation_aggregated_variables[1:]:
            aggregate_variables_values['Prod'] += aggregate_variables_values[var_for_prod].sum(axis=0)
        generated_variables_dimensions['Prod'] = generated_SAM_variables_dimensions

# we export both the endowments per factor and with all
# the factors.  Endowments per factors variables
# are exported as individual tables, 
# variables can be used more easily in downstream codes
# Note that this rewrites the variables that were already
# determined as an aggregate of input variables if the 
# endowment variables were already in input
generated_added_value_endowments_per_factor_list = []
if set(added_value_endowments_list) & set(aggregate_variables_values) == set(added_value_endowments_list):
    dict_results_endowments = aggregation_GTAP.ExtractEndowmentTables(dimensions_aggregation_informations['ENDO'][1], aggregate_variables_values['AddedValue'], aggregate_variables_values['T_AddedValue'])
    generated_added_value_endowments_per_factor_list = sorted(dict_results_endowments)
    for endowment_variable in dict_results_endowments:
        aggregate_variables_values[endowment_variable] = dict_results_endowments[endowment_variable]
        generated_variables_dimensions[endowment_variable] = generated_SAM_variables_dimensions

# complete dimensions
output_variables_dimensions = copy.deepcopy(input_data_dimensions)
# complete for generated variables in generated_variables_mapping
for variable_name in generated_variables_dimensions:
    output_variables_dimensions[variable_name] = generated_variables_dimensions[variable_name]

# overwrite input variables dimensions for generated variables
# specified in generated_variables_mapping
for variable_name in generated_variables_mapping:
    if generated_variables_mapping[variable_name] in output_variables_dimensions:
        output_variables_dimensions[variable_name] = output_variables_dimensions[generated_variables_mapping[variable_name]]

# We have a SAM in input.  In that case specific computations are
# done
if set(aggregate_variables_values) & set(input_SAM_variables_list) == set(input_SAM_variables_list):
    # if doing computations on the SAM, setup true variables
    for variable_name in input_SAM_variables_list + aggregated_SAM_list + ['Prod']:
        exec(variable_name + '= aggregate_variables_values[variable_name]')

    print('\n//////////////////////////////////////')
    print('Check the equilibirum of the SAM:')
    print('//////////////////////////////////////\n')
    
    SAM_dict = dict()
    for elt in input_SAM_variables_list + production_list + aggregated_SAM_list + ['Prod']:
        exec("SAM_dict[ '"+elt+"'] = "+elt)
    Resources, Uses, Balance, Balance_Imp, Balance_Dom = aggregation_GTAP.CheckSAMBalance(SAM_dict)
   
    #----------------------------------------------------------------------------------
    Auto_Import_trans = np.diagonal(Imp_trans_bil,axis1=1,axis2=2)
    Auto_Texp = np.diagonal(T_Exp_bil,axis1=1,axis2=2)
    Auto_Timp = np.diagonal(T_Imp_bil,axis1=1,axis2=2)
    Auto_TMX = Auto_Texp + Auto_Timp
    aggregate_variables_values['Auto_TMX'] = Auto_TMX

    if args.correct_self_import:
        print('\n//////////////////////////////////////')
        print('Make corrections to avoid self importations:')
        print('//////////////////////////////////////\n')
        # create corrected variable
        for elt in variable_2correct_list:
            str2exec = elt + '_cor = copy.deepcopy(' + elt + ')'
            exec(str2exec)
        # further import and export datas may not be bi-lateral anymore 
        # (there will be no sense to correct for auto-importations then) 
        # and might have a dimension less than the previous (indicated 
        # by the sufix _cor, as corrected), so 2D matrices instead of 3D
        # Correction of auto-importations values for exports and imports
        Imp_cor = Imp - np.diagonal(Imp_bil,axis1=1,axis2=2)
        Imp_trans_cor = Imp_trans - Auto_Import_trans
        T_Imp_cor = T_Imp - Auto_Timp
        Exp_cor = Exp - np.diagonal(Exp_bil,axis1=1,axis2=2)
        T_Exp_cor = T_Exp - Auto_Texp
        # Ratio auto-importations :
        AutoImport_ratio = np.diagonal(Imp_bil+Imp_trans_bil+T_Imp_bil,axis1=1,axis2=2) / ((Imp_bil+Imp_trans_bil+T_Imp_bil).sum(axis=1) + np.ones(Imp_bil.sum(axis=1).shape)*((Imp_bil+Imp_trans_bil+T_Imp_bil).sum(axis=1)==0))
        # FIXME what to do if dimensions_aggregation_informations['REG'] is None?
        # FIXME is it correct if there is no aggregation?
        numberOfRegion = len(dimensions_aggregation_informations['REG'][1])
        # Correction of auto-importations values for exports and imports in bilaterals matrix as well:
        for elt in bilateral_list:
            str2exec = elt + '_cor = copy.deepcopy(' + elt + ')'
            exec(str2exec)
            str2exec = elt + '_cor[:,range(numberOfRegion),range(numberOfRegion)] = np.zeros(' + elt + '[:,range(numberOfRegion),range(numberOfRegion)].shape)'
            exec(str2exec)
        # Move 'imports' to 'domestics' proportionally to the auto-importations ratio
        for k in range(CI_dom.shape[0]):
            CI_dom_cor[:,k,:] = CI_dom[:,k,:] + CI_imp[:,k,:] * AutoImport_ratio
            T_CI_dom_cor[:,k,:] = T_CI_dom[:,k,:] + T_CI_imp[:,k,:] * AutoImport_ratio
        C_hsld_dom_cor = C_hsld_dom + C_hsld_imp * AutoImport_ratio
        C_AP_dom_cor = C_AP_dom + C_AP_imp * AutoImport_ratio
        FBCF_dom_cor = FBCF_dom + FBCF_imp * AutoImport_ratio
        T_FBCF_dom_cor = T_FBCF_dom + T_FBCF_imp * AutoImport_ratio
        T_Hsld_dom_cor = T_Hsld_dom + T_Hsld_imp * AutoImport_ratio
        T_AP_dom_cor = T_AP_dom + T_AP_imp * AutoImport_ratio
        for k in range(CI_imp.shape[0]):
            CI_imp_cor[:,k,:] = CI_imp[:,k,:] * (1 - AutoImport_ratio)
            T_CI_imp_cor[:,k,:] = T_CI_imp[:,k,:] * (1 - AutoImport_ratio)
        C_hsld_imp_cor = C_hsld_imp * (1 - AutoImport_ratio)
        C_AP_imp_cor = C_AP_imp * (1 - AutoImport_ratio)
        FBCF_imp_cor = FBCF_imp * (1 - AutoImport_ratio)
        T_FBCF_imp_cor = T_FBCF_imp * (1 - AutoImport_ratio)
        T_Hsld_imp_cor = T_Hsld_imp * (1 - AutoImport_ratio)
        T_AP_imp_cor = T_AP_imp * (1 - AutoImport_ratio)

        # Correction of exportation of transport services 
        listTransportIndexes = [dimensions_aggregation_informations['SEC'][1].index(transports_dimension) for transports_dimension in dimensions_aggregation_informations['TRANSP'][1]]
        for reg in range(CI_imp.shape[2]):
            transport_Ratio = Exp_trans[:,reg] / (Exp_trans[:,reg].sum() + np.ones(Exp_trans[:,reg].shape)*(Exp_trans[:,reg].sum()==0) )
            for indexes in listTransportIndexes:
                CI_dom_cor[indexes,:,reg] = CI_dom_cor[indexes,:,reg] + transport_Ratio[indexes] * Auto_Import_trans[:,reg]
                Exp_trans_cor[indexes,reg] = Exp_trans[indexes,reg] - transport_Ratio[indexes] * Auto_Import_trans[:,reg].sum()
    
        # Recomputing and check the balance after correction
        SAM_dict = dict()
        for elt in input_SAM_variables_list + production_list + aggregated_SAM_list + ['Prod']:
            exec("SAM_dict[ '"+elt+"'] = "+elt)

        Resources_cor, Uses_cor, Balance_cor, Balance_Imp_cor, Balance_Dom_cor = aggregation_GTAP.CheckSAMBalance(SAM_dict, Auto_TMX=Auto_TMX, postfix='_cor')

        for variable_name in variable_2correct_cor_list + bilateral_cor_list:
            exec('aggregate_variables_values[variable_name] = '+variable_name)
    
    print('')
    print(' Info : CI, and T_CI, by region will have dimensions (input sector, output sector) in 2D outputs files')
    print(' Info : Imp, Exp, T_imp and T_Exp, is originally (sector, export region, import region)')
    print(' Bilateral variables Imp_bil_cor, Exp_bil_cor, T_Imp_bil_cor, T_Exp_bil_cor, will will have outputs by exporting region with dimensions (import country, output sector) in 2D outputs files')

    # FIXME do we need the computation below with Uses and not Uses_cor?
    #print("\nThe error between Resources and Uses corrected in the all world is : "+str((Balance_cor).sum()/Uses.sum())+' %')
    #print("Corrected SAMs are balanced with an errors of (by region): \n"+str((Balance_cor).sum(axis=0)/Uses.sum(axis=0))+' %')

#----------------------------------------------------------------------------------
print('\n//////////////////////////////////////')
print('Export results:')
print('//////////////////////////////////////\n')

print('...exporting the aggregated datas into csv')

# ordered variables
export_variables_order = production_list + generated_added_value_endowments_per_factor_list + variable_2correct_list + computed_SAM_list + added_value_endowments_list + variable_2correct_cor_list + bilateral_list + bilateral_cor_list

listExportVarNames = []
for aggregate_variable_name in export_variables_order:
    if aggregate_variable_name in aggregate_variables_values:
        listExportVarNames.append(aggregate_variable_name)

# add remaining variables
listExportVarNames += sorted(set(aggregate_variables_values) - set(export_variables_order))


output_dimension_values = {}
for dimension_name in dimensions_aggregation_informations:
    output_dimension_values[dimension_name] = dimensions_aggregation_informations[dimension_name][1]

output_variables_dimensions_info = {}
for variable_name in aggregate_variables_values:
    output_variables_dimensions_info[variable_name] = '*'.join(output_variables_dimensions[variable_name])

if args.separate_tables_dir is not None:
    common_cired.mkdir_exists(args.separate_tables_dir)
    aggregation_GTAP.exportSAM(listExportVarNames, aggregate_variables_values, output_dimension_values, output_variables_dimensions_info, args.separate_tables_dir)

if args.separate_variable_dir is not None and args.separate_variable_list is not None:
    exec("test_all= ('ALL'=="+args.separate_variable_list+")")
    if test_all:
        listExportVarNames_specific_variables=list(set(input_data.keys()))     
    else:
        exec("listExportVarNames_specific_variables="+args.separate_variable_list)#.replace('[','').replace(']','').split(',')]
    aggregation_GTAP.exportSAM(listExportVarNames_specific_variables, aggregate_variables_values, output_dimension_values, output_variables_dimensions_info, args.separate_variable_dir)

if args.sam_for_excel is not None:
    common_cired.mkdir_exists(args.sam_for_excel)
    aggregation_GTAP.exportSAM_tableformat(aggregate_variables_values, output_dimension_values, output_variables_dimensions_info, dict_results_endowments.keys(), args.separate_tables_dir)


if args.output_file is not None:
    aggregation_GTAP.filter_dimensions_and_export_dimensions_tables(args.output_file, output_dimension_values, aggregate_variables_values, output_variables_dimensions_info, var_list=listExportVarNames)


#----------------------------------------------------------------------------------
print('\n\n         ***** THE END OF EVERYTHING ******:')

# Future possible development of this script : 
# - give systematically all usefull dictionary for GTAP as an argument of aggregateArray, and sort them into a aggregation_GTAP.aggregateGTAP procedure that call aggregateArray (that could be useful for aggregating otehr datas with actually missing dictionaries)
# - list all header of GTAP ('VDGA' like), associated with the related file (to aggregate all datas ?)
# - aggregate all GTAP datas with automatic names
