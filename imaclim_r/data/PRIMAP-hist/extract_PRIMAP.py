# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import pandas as pd
import os
import sys

#    HISTCR: In this scenario country-reported data (CRF, BUR, UNFCCC) is prioritized over third-party data (CDIAC, FAO, Andrew, EDGAR, BP).
#    HISTTP: In this scenario third-party data (CDIAC, FAO, Andrew, EDGAR, BP) is prioritized over country-reported data (CRF, BUR, UNFCCC)

output_path='results/'
if not os.path.exists(output_path):
    # If it doesn't exist, create it
    os.makedirs(output_path)

#load data
input_file=sys.argv[1]
iso_rules_path=sys.argv[2]
#input_file= '/data/public_data/PRIMAP-hist/download/Guetschow-et-al-2023-PRIMAP-hist_v2.4.1_final_no_extrap_16-Feb-2023.csv'
#iso_rules_path = '/diskdata/cired/leblanc/ImaclimR_version2.0/trunk_v2.0_GENRATE_DATA/data/ISO_rules/ISO_GTAP_IMACLIM_rules.csv'

df = pd.read_csv(input_file)

# load ISO dict
iso_rules = pd.read_csv(iso_rules_path,sep='|')

# IMACLIM order region for output and scilab load
imaclim_order_reg = [elt[0] for elt in  pd.read_csv('../order_regions.csv',header=None).values.tolist()]

# CO2 from industrial process #df_selected.sum()['2017'] #2.752 GtCO2
for key, output_name in [ ('2',"CO2_industrial_processes_"), ('M.AG',"CO2_agriculture_")]:
    df_selected = df[ (df['category (IPCC2006_PRIMAP)']==key) & (df['entity']=='CO2') & (df['scenario (PRIMAP-hist)']=='HISTTP')]
    df_selected = df_selected.rename( {'area (ISO3)':'Alpha-3 code'}, axis=1)
    df_selected = pd.merge(df_selected, iso_rules[ ['Alpha-3 code','IMACLIM']], on='Alpha-3 code')
    df_out = df_selected.groupby('IMACLIM').sum().reset_index()
    df_out = df_out.set_index('IMACLIM').loc[imaclim_order_reg].reset_index()
    # concert to GtCO2
    numerical_columns = df_out.select_dtypes(include='number').columns
    factor = 1e-6
    df_out[numerical_columns] = df_out[numerical_columns] * factor
    #output
    df_out.to_csv(output_path+output_name+"_GtCO2_IMACLIM.csv",sep='|',index=False)


