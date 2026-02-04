# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Nicolas Graves, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


# Ce fichier a servi à faire des tests sur les données d'Enerdata pour mieux comprendre ce qui y était calculé. Les données d'Enerdata ne devraient normalement pas servir pour la recalibration d'Iamclim. 




# -*- coding: utf-8 -*-

import copy
import numpy as np
import pandas as pd
import csv
import collections

#--------------------------------------------------------

## load data
enerdata_path = '/data/shared/enerdata/enerdata_300916/'
data_path = enerdata_path + 'enerdata_300916_filter.csv'

enerdata_data = pd.read_csv(data_path)
#--------------------------------------------------------

# creates dico
ISO2ISO_path = '/data/public_data/country-codes/data/'
ISO2ISO = pd.read_csv(ISO2ISO_path + 'country-codes.csv')

ISO3GTAP_path = '/data/shared/GTAP/'
ISO3GTAP = pd.read_csv(ISO3GTAP_path + 'ISO3166_GTAP.csv')

Imaclim2GTAP_path = '../GTAP/aggregations/aggregation_Imaclim_GTAP6_region.csv'

Imaclim2GTAP = collections.defaultdict(list)
with open(Imaclim2GTAP_path,newline='') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        hd,*tl = list(filter(None,row[0].split('|')))
        for elt in tl:
            Imaclim2GTAP[hd].append(elt)
            
GTAP2Imaclim = {GTAPreg: Imreg for Imreg in Imaclim2GTAP for GTAPreg in Imaclim2GTAP[Imreg]}

#---------------------------------------ISO3166_GTAP.csv'-----------------

# export data
list_year = np.arange(2001,2016,1)
list_data = ['gnapd','gnaxm','gnaim','gnaex','gnacp','gnaci','cmspd']
list_names = [enerdata_data.loc[enerdata_data['Item code']==elt,'Title'].iloc[0].replace(' ','_') for elt in list_data]
list_units = [enerdata_data.loc[enerdata_data['Item code']==elt,'Unit'].iloc[0] for elt in list_data]
useful_data = ['Item code','ISO code','Year','Value']

data_temp = enerdata_data.loc[(enerdata_data['Item code'].isin(list_data))&(enerdata_data['Year'].isin(list_year))][useful_data]

data_temp['Value'   ].replace('n.a.',0.,inplace=True)
data_temp['Value'   ]=data_temp['Value'].astype('float64')
data_temp['ISO code'].replace('XZ','RS',inplace=True) #Kosovo is Serbia 
data_temp['ISO code'].replace('AN','AW',inplace=True)
    
#joining enerdata and iso2 & iso3
data_temp=data_temp.merge(ISO2ISO[['ISO3166-1-Alpha-2','ISO3166-1-Alpha-3']], left_on=data_temp['ISO code'],right_on=ISO2ISO['ISO3166-1-Alpha-2'])
data_temp.loc[data_temp['ISO code']=='NA','ISO3166-1-Alpha-3']='nam'

#joining data_temp on gtap
data_temp.drop(columns=['key_0','ISO code','ISO3166-1-Alpha-2'],inplace=True)
data_temp=data_temp.merge(ISO3GTAP[['ISO','REG_V6']], left_on=data_temp['ISO3166-1-Alpha-3'].str.lower(), right_on=ISO3GTAP['ISO'])

#joining data_temp on imaclimR
data_temp['ImRegion']=data_temp['REG_V6'].map(GTAP2Imaclim)
    
aggregated_data = data_temp[['Item code','ImRegion','Year','Value']].groupby(['Item code','ImRegion','Year'],as_index=False).sum()

#outputs
for k in range(len(list_data)):  
    datafile = open('./' +list_names[k]+'.csv','w')
    datafile.write( '//Unit:' + list_units[k] + '\n'+'//')
    aggregated_data.loc[aggregated_data['Item code']==list_data[k],['ImRegion','Year','Value']].to_csv(path_or_buf='./' +list_names[k]+'.csv',sep='|',index=False)



# ./list_var_imports_enerdata.csv and ./list_var_exports_enerdata.csv missing
"""
enerdata_data.set_index(['ISO code','Item code','Year'],inplace=True)
imports_names = list(map(lambda x: x[1:-1],np.genfromtxt('./list_var_imports_enerdata.csv',delimiter='|',dtype='str')))
exports_names = list(map(lambda x: x[1:-1],np.genfromtxt('./list_var_exports_enerdata.csv',delimiter='|',dtype='str')))
enerdata_IM_EX = enerdata_data.loc[enerdata_data['Title'].isin(imports_names+exports_names)]
enerdata_IM_EX = enerdata_IM_EX.where(lambda x: x!='n.a.', np.nan).astype({'Value':float})
enerdata_IM_EX = enerdata_IM_EX.xs(2014,level='Year').reset_index(level='ISO code').sum(level='Item code').sort_index()
"""

#Au vu de cette aggrégation, il semble que l'identité somme des imports = somme des exports n'est pas vérifiée pour enerdata non plus. 
#Pour comparer rapidement avec enerdata_IM_EX : les deux dernières lettres de l'Item code indiquent si c'est un import ou un export et les 3 premières font référence au produit. 
#Autrement dit, si on avait somme des exports = somme des imports, on aurait par exemple bitex = bitim 
