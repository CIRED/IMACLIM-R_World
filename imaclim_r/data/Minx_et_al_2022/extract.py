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

output_path='results/'
if not os.path.exists(output_path):
    # If it doesn't exist, create it
    os.makedirs(output_path)

#load data
input_file=sys.argv[1] + 'essd_ghg_data-data.csv'
iso_rules_path=sys.argv[2]
#input_file= '/data/public_data/Minx_et_al_2022/extracted/essd_ghg_data-data.csv'
#iso_rules_path = '/diskdata/cired/leblanc/Navigate/navigate2.6/trunk_v2.0_r31973/data/ISO_rules/ISO_GTAP_IMACLIM_rules__with_groups.csv'

df = pd.read_csv(input_file)

# load ISO dict
iso_rules = pd.read_csv(iso_rules_path,sep='|')

# IMACLIM order region for output and scilab load
imaclim_order_reg = [elt[0] for elt in  pd.read_csv('../order_regions.csv',header=None).values.tolist()]

# check ISO covergae
iso_Im=iso_rules['Alpha-3 code'].unique()
iso_data=df.ISO.unique()
[elt for elt in iso_data if not elt in iso_Im]
# 'AIR': Int. Aviation
# 'SEA': Int. Shipping

unit_convertion_factor = 1e-6 * 1e-3

for sec in df.sector_title.unique():
    for gas in ['CO2']:
        df_selected = df[ (df['gas']==gas) & (df['sector_title']==sec)]
        df_selected = df_selected.rename( {'ISO':'Alpha-3 code'}, axis=1)
        df_selected = pd.merge(df_selected, iso_rules[ ['Alpha-3 code','IMACLIM']], on='Alpha-3 code')
        df_out = df_selected.groupby(['year','IMACLIM']).sum().reset_index()
        df_out = df_out.set_index('IMACLIM').loc[imaclim_order_reg].reset_index()
        # pivot table with years as columns
        df_out = pd.pivot_table( df_out, values=['value'], index=['IMACLIM'], columns=['year'])
        df_out.index.name = None
        df_out = df_out.droplevel(0, axis=1)
        # concert to GtCO2
        numerical_columns = df_out.select_dtypes(include='number').columns
        df_out[numerical_columns] = df_out[numerical_columns] * unit_convertion_factor
        df_world = df_out.sum()
        #output
        output_name = "emissions_"+sec.replace(' ','').replace('(','_').replace(')','_')+"__TOTAL__"+gas
        df_out.to_csv(output_path+output_name+"_GtCO2_IMACLIM.csv",sep='|',index=True)
        df_world.to_frame().transpose().to_csv(output_path+output_name+"_GtCO2_IMACLIM__WLD.csv",sep='|',index=False)
    
        # output by sub sector if there is more than one
        if len( df_selected.subsector_title.unique()) >1:
            for subsec in df_selected.subsector_title.unique():
                df_subsec = df_selected[ df_selected['subsector_title'] == subsec]
                df_out = df_subsec.groupby(['year','IMACLIM']).sum().reset_index()
                imaclim_order_reg_temp = [elt for elt in imaclim_order_reg if elt in df_out.IMACLIM.unique()] #no values for all regions
                df_out = df_out.set_index('IMACLIM').loc[imaclim_order_reg_temp].reset_index()
                # pivot table with years as columns
                df_out = pd.pivot_table( df_out, values=['value'], index=['IMACLIM'], columns=['year'])
                df_out.index.name = None
                df_out = df_out.droplevel(0, axis=1)
                # concert to GtCO2
                numerical_columns = df_out.select_dtypes(include='number').columns
                df_out[numerical_columns] = df_out[numerical_columns] * unit_convertion_factor
                df_world = df_out.sum()
                #output
                output_name = "emissions_"+sec.replace(' ','').replace('(','_').replace(')','_')+"__"+subsec.replace(' ','').replace('(','_').replace(')','_')+"__"+gas
                df_out.to_csv(output_path+output_name+"_GtCO2_IMACLIM.csv",sep='|',index=True)
                df_world.to_frame().transpose().to_csv(output_path+output_name+"_GtCO2_IMACLIM__WLD.csv",sep='|',index=False)

# International Transport
df_IntTransp = df[ df['ISO'].isin(['AIR','SEA']) & (df['gas']=='CO2') & (df['sector_title']=='Transport')] 
df_IntTransp = pd.pivot_table( df_IntTransp, values=['value'], index=['country'], columns=['year'])
df_IntTransp.index.name = None
df_IntTransp = df_IntTransp.droplevel(0, axis=1)
df_IntTransp *= unit_convertion_factor
df_IntTransp.to_csv(output_path+"emissions_International_transport_GtCO2_IMACLIM.csv",sep='|',index=True)
