#!/bin/python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Nicolas Graves, Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


# Be careful modifying this script.
# It is called at least by imaclimr world in trunk_v2.0/data/IEA/hybridization/GTAP_IEA_hybridization.py
# But may be used independently. 

# The script results in the DataFrame named web, including all IEA countries energy balances for 2014. 

#libraries
import pandas as pd
import numpy as np
import os

#variables 
list_years = [year] #['2014']
ieaPath = '/data/shared/iea-energyBalancesAndPrices/'
iea_dataPath = input_file #'./IEA_2017/rawData/wbig/'
iso3_codes_path = '/data/public_data/country-codes/data/country-codes.csv'

current_working_directory = os.getcwd()
os.chdir(ieaPath)

#loading filenames
country_codes = ['WLD']+pd.read_csv(iso3_codes_path)['ISO3166-1-Alpha-3'].to_list()
_,_,filenames = next(os.walk(iea_dataPath), (None, None, []))
#There are also region sets, here we only extract world and iso3 countries
#only keeps regions with 3 digits i.e. iso3 alpha3 codes
set_regions = set(map(lambda x:x.split('_')[2][:-4],filenames)).intersection(country_codes)

#For other regions non-specified in IEA
set_regions.add('OTHER_AFRICA')
set_regions.add('OTHER_NON_OECD_AMERICAS')
set_regions.add('OTHER_NON_OECD_ASIA')


web = pd.DataFrame()
for region in set_regions:
    web_temp = pd.DataFrame()
    for year in list_years:
        df_temp = pd.read_csv(iea_dataPath + 'wbig_'+year+'_'+region+'.csv', sep=';',index_col=0)
        df_temp['Year']=year
        web_temp = pd.concat( [web_temp,df_temp])

    web_temp['Region']=region
    web_temp.set_index(['Year','Region'],append=True,inplace=True)
    web = pd.concat( [web_temp, web])

web.replace(['x','..','c'],np.nan,inplace=True)
web.replace('x',np.nan,inplace=True)
web = web.astype('float64',errors='raise',copy=False)
web.index.rename(['Flow','Year','Region'],inplace=True)
web = web.swaplevel(0,2)

web = web.sort_index()

os.chdir(current_working_directory)
