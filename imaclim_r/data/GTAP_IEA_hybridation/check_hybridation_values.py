# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

# checking there is no imports greater than total consumption
# this is true for some small country just after hybridation
# for Imaclim-R World, this should not be true for our aggregated regions

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

#############################################
# Checking energy ratio for industries

list_sec_indus=['ppp', 'ome', 'i_s', 'nmm', 'nfm', 'twl', 'omn', 'lum', 'crp', 'teq', 'other_indus']
list_post = ['CI_dom_sum', 'C_hsld_dom', 'C_AP_dom', 'FBCF_dom', 'Exp', 'Exp_trans']

input_data_sam, input_dimensions_values_sam, input_data_dimensions_sam = aggregation_GTAP.read_dimensions_tables_file( 'results/GTAP_IEA_hybrid_table_SecEDS_RegGTAP_2014.csv')

ind_ener = [ input_dimensions_values_sam['SEC'].index( elt) for elt in ['ely', 'gas_gdt', 'oil', 'p_c', 'coa']]

# en gros sur la production, je veux en valeur la part des exports, des CI et des postes de demande DG, DI, DF
input_data_sam['CI_dom_sum'] = input_data_sam['CI_dom'].sum(axis=1) 
input_data_sam['Ener_CI'] = input_data_sam['Ener_CI_dom'] + input_data_sam['Ener_CI_imp']

prod_all = 0
ci_ener_all = 0
for sec in list_sec_indus:
    prod_all += input_data_sam['Prod'][ input_dimensions_values_sam['SEC'].index( sec), :].sum()
    ci_ener_all += input_data_sam['Energy_UsagFirm'][:, input_dimensions_values_sam['SEC'].index(sec),: ].sum()
    print('ci_ener_all', sec, input_data_sam['Ener_CI'][:, input_dimensions_values_sam['SEC'].index(sec),: ].sum())

print('\n') 

for sec in list_sec_indus:
    ratio = input_data_sam['Prod'][ input_dimensions_values_sam['SEC'].index( sec), :].sum() / prod_all * 100
    print( sec +'|', ratio)
print('\n')

for sec in list_sec_indus:
    ratio = input_data_sam['Ener_CI'][:, input_dimensions_values_sam['SEC'].index(sec),: ].sum() / ci_ener_all * 100
    print( sec +'|', ratio)
print('\n')

for sec in list_sec_indus:
    prod_sec = 0
    str2print = 'Industrial sector|'
    for elt in list_post:
        str2print += elt + '|'
        prod_sec += input_data_sam[ elt][ input_dimensions_values_sam['SEC'].index( sec), :].sum()
    print( str2print)
    str2print = sec+ '|'
    for elt in list_post:
        ratio = input_data_sam[ elt][ input_dimensions_values_sam['SEC'].index( sec), :].sum() / prod_sec * 100
        str2print += str(ratio) + '|'
    print( str2print)
    

#############################################
# Checking countries where Export exceed Production

for ener in input_dimensions_values_sam['ENER']:
    for i_reg, reg in enumerate(input_dimensions_values_sam['REG']):
        val = input_data_sam['Ener_Prod'][input_dimensions_values_sam['SEC'].index(ener), i_reg] / input_data_sam['Ener_Exp'][input_dimensions_values_sam['SEC'].index(ener), i_reg]
        if val<1:
            print( "Exports are greater than imports for REG:", reg, "ENER:", ener, "VAL:", val) 


