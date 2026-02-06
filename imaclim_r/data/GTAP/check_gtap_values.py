# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


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

#list_sec_indus=['ppp', 'ome', 'i_s', 'nmm', 'nfm', 'twl', 'omn', 'lum', 'crp', 'teq', 'other_indus']
#list_post = ['CI_dom_sum', 'C_hsld_dom', 'C_AP_dom', 'FBCF_dom', 'Exp', 'Exp_trans']

path = "/data/shared/GTAP/results/extracted_GTAP10-E_2014/GTAP_tables.csv"
input_data_sam, input_dimensions_values_sam, input_data_dimensions_sam = aggregation_GTAP.read_dimensions_tables_file( path)

sec_ener = input_dimensions_values_sam['ERG_COMM']
ind_ener = [ input_dimensions_values_sam['PROD_COMM'].index( elt) for elt in sec_ener]
 
sec_serv = "wtr|trd|afs|cmn|ofi|ins|obs|rsa|ros|osg|edu|hht|dwe".split('|')
ind_serv = [ input_dimensions_values_sam['PROD_COMM'].index( elt) for elt in sec_serv]

Export_energy_Gtap = input_data_sam['EXI'].sum(axis=2) # axis 2 for exports
Prod_energy_GTAP = (input_data_sam['EDF'].sum(axis=1) + input_data_sam['EDG'] + input_data_sam['EDP']) + Export_energy_Gtap

CI_ener_serv = (input_data_sam['EDF'] + input_data_sam['EIF']).sum(axis=0)[ind_serv,:]

# for the world
for i, sec in enumerate(sec_serv):
    share = CI_ener_serv[i,:].sum() / CI_ener_serv.sum() * 100
    #print(share, sec)
    print(sec)

# for the US
ind_us = input_dimensions_values_sam['REG'].index('usa')
for i, sec in enumerate(sec_serv):
    share = CI_ener_serv[i,ind_us].sum() / CI_ener_serv[:,ind_us].sum() * 100
    #print(share, sec)
    print(share)

############### added value
for sec in sec_serv:
    i = input_dimensions_values_sam['PROD_COMM'].index(sec)
    share = input_data_sam['VFM'][:,i,:].sum() / input_data_sam['VFM'][:,ind_serv,:].sum() * 100
    #print(share, sec)
    print(share)

# US
for sec in sec_serv:
    i = input_dimensions_values_sam['PROD_COMM'].index(sec)
    share = input_data_sam['VFM'][:,i,ind_us].sum() / input_data_sam['VFM'][:,ind_serv,ind_us].sum() * 100
    #print(share, sec)
    print(share)


# countries with some sectors greater than 5%
for i, sec in enumerate(sec_serv):
    list_c = list()
    for j, reg in enumerate(input_dimensions_values_sam['REG']):
        share = CI_ener_serv[i,j].sum() / CI_ener_serv[:,j].sum() * 100
        if share > 10:
            list_c.append(reg)
    dict_gdp = {k: round(input_data_sam['VFM'][:,0:-1,input_dimensions_values_sam['REG'].index(k)].sum() / input_data_sam['VFM'][:,0:-1,:].sum() * 100, 2) for k in list_c}
    dict_gdp = {k:v for k, v in dict_gdp.items() if v > 1}
    print(sec, dict_gdp)

# Share of material good consumption directly by Households, and through the 
#Wholesale and trade sector
ind_mvh = input_dimensions_values_sam['SEC'].index('mvh')
ind_trd = input_dimensions_values_sam['SEC'].index('trd')
ind_ofd = input_dimensions_values_sam['SEC'].index('ofd')
ind_tex = input_dimensions_values_sam['SEC'].index('tex')
ind_usa = input_dimensions_values_sam['REG'].index('usa')

(input_data_sam['C_hsld_dom'] + input_data_sam['C_hsld_imp'])[ ind_mvh, ind_usa]
(input_data_sam['CI_dom'] + input_data_sam['CI_imp'])[ ind_mvh, ind_trd, ind_usa]

(input_data_sam['C_hsld_dom'] + input_data_sam['C_hsld_imp'])[ ind_ofd, ind_usa]
(input_data_sam['CI_dom'] + input_data_sam['CI_imp'])[ ind_ofd, ind_trd, ind_usa]

(input_data_sam['C_hsld_dom'] + input_data_sam['C_hsld_imp'])[ ind_tex, ind_usa]
(input_data_sam['CI_dom'] + input_data_sam['CI_imp'])[ ind_ofd, ind_tex, ind_usa]



