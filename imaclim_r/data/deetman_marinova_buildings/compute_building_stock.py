#! /usr/bin/env python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Nicolas Graves
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


import sys
import pandas as pd

input_file = sys.argv[1]

## %run ./compute_buildings_stock.py $buildings_data/extracted/buildings_area_and_resource_cons-sqmeters_output-normalized.csv

data = pd.read_csv(input_file,sep='|')
building_stock_residential = data.loc[(data['type'].isin(['detached','semi-detached','appartments','high-rise']))&(data['flow']=='stock')]

rbs_agg = building_stock_residential.groupby('Region').sum()[['2004','2007','2011','2014']]

#Splitting Republic of Korea (KOR in SSP-iiasa) and Democratic People's Republic of Korea (PRK in SSP-iiasa) according to population
data_pop = pd.read_csv('/data/public_data/SSP_iiasa/extracted/SspDb_country_data_2013-06-12.csv')

pop_korea = data_pop.loc[(data_pop['REGION'].isin(['KOR','PRK']))&(data_pop['SCENARIO']=='SSP3_v9_130115')&(data_pop['MODEL']=='IIASA-WiC POP')&(data_pop['VARIABLE']=='Population')]

pop_KOR = (pop_korea.loc[pop_korea['REGION']=='KOR']['2010']).to_numpy()[0]
pop_PRK = (pop_korea.loc[pop_korea['REGION']=='PRK']['2010']).to_numpy()[0]

 #creating new regions in Image for the split before ImaclimR aggregation
 #19 is the index of the Korean Peninsula in Image region classification
rbs_agg.loc['KOR',:] = pop_KOR/(pop_KOR+pop_PRK)*rbs_agg.loc[19,:]
rbs_agg.loc['PRK',:] = pop_PRK/(pop_KOR+pop_PRK)*rbs_agg.loc[19,:]


#Splitting the China Image into China, Hong-Kong and Macao (Imaclim) and rest of Southern Asia according to population 
pop_china_region = data_pop.loc[(data_pop['REGION'].isin(['CHN','HKG','MAC','MNG','TWN']))&(data_pop['SCENARIO']=='SSP3_v9_130115')&(data_pop['MODEL']=='IIASA-WiC POP')&(data_pop['VARIABLE']=='Population')]


pop_CHN = (pop_china_region.loc[pop_china_region['REGION'].isin(['CHN','HKG','MAC'])]['2010']).to_numpy()[0]
pop_RAS = (pop_china_region.loc[pop_china_region['REGION'].isin(['MNG','TWN'])]['2010']).to_numpy()[0]

 #creating new regions in Image for the split before ImaclimR aggregation
 #20 is the index of the China Region in Image region classification
rbs_agg.loc['CHN',:] = pop_CHN/(pop_CHN+pop_RAS)*rbs_agg.loc[20,:]
rbs_agg.loc['RAS',:] = pop_RAS/(pop_CHN+pop_RAS)*rbs_agg.loc[20,:]

rbs_agg.drop([19,20],inplace=True) #old China and Korea regions

rbs_agg.to_csv('./residential_building_stock.csv',sep='|')
