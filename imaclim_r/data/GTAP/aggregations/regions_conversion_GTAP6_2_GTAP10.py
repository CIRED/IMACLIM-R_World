# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Nicolas Graves
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

#

import csv
import collections
import pandas as pd

# This file is deprecated
# as regional definition have changed (EUROPE for example), there is no direct correspondance 

save_file = './aggregation_Imaclim_GTAP10_region_generated_fromGTAP6.csv'

ISO3GTAP_path = '/data/shared/GTAP/'
ISO3GTAP = pd.read_csv(ISO3GTAP_path + 'ISO3166_GTAP.csv')[['REG_V6','REG_V10']].drop_duplicates()

#There are still some inconsistancies since some regions have moved (and not only 
#added) between GTAP6 and GTAP10. For these we need to identify and extract them, and then 
#ensure that they are properly defined. 

#For this we  can run the following snippet, inspired by the source code of the function 
#pd.DataFrame.value_counts() which can't be directly used because current version of
#pandas is under 1.0.0. 
#In case it might be useful, the link of the source code is here : 
# https://github.com/pandas-dev/pandas/blob/v1.1.3/pandas/core/frame.py#L5478-L5572

#subset = 'REG_V10'
#counts = ISO3GTAP.groupby(subset).grouper.size()
#counts[counts>1].index.tolist()

#This snippet returns the names of regions that we need to redefine manually. 
#To see the different co-existing regions, you can run :

#ISO3GTAP[ISO3GTAP['REG_V10']=='fin'] #for instance


GTAP10_2_GTAP6 = ISO3GTAP.set_index('REG_V10')['REG_V6'].to_dict()

GTAP10_2_GTAP6['xer']='xer'
GTAP10_2_GTAP6['nor']='xef'
GTAP10_2_GTAP6['aus']='aus'
GTAP10_2_GTAP6['fin']='fin'
GTAP10_2_GTAP6['fra']='fra'
GTAP10_2_GTAP6['xcb']='xcb'
GTAP10_2_GTAP6['xec']='xss'
GTAP10_2_GTAP6['xnf']='xnf'
GTAP10_2_GTAP6['xoc']='xoc'
GTAP10_2_GTAP6['xsm']='xsm'

Imaclim_fr2Imaclim_en = { 'USA':'USA', 'CAN':'CAN', 'EUR':'EUR', 'JAN':'JAN', 'CEI':'CIS', 'IND':'IND', 'CHN':'CHN', 'BRE':'BRA', 'AFR':'AFR', 'MO':'MDE', 'RAS':'RAS', 'RAL':'RAL'} 


#deleting Antartica territories
del GTAP10_2_GTAP6['xtw']

Imaclim2GTAP6_path = './aggregation_Imaclim_GTAP6_region.csv'

Imaclim2GTAP6 = collections.defaultdict(list)
with open(Imaclim2GTAP6_path,newline='') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        hd,*tl = list(filter(None,row[0].split('|')))
        for elt in tl:
            if elt=="rom":
                #error in the original file ?
                elt="rou"
            Imaclim2GTAP6[Imaclim_fr2Imaclim_en[hd]].append(elt)

GTAP6_2_Imaclim = {GTAP6reg : k for k, v in Imaclim2GTAP6.items() for GTAP6reg in v}

GTAP10_2_Imaclim = {GTAP10reg : GTAP6_2_Imaclim[GTAP10_2_GTAP6[GTAP10reg]] for GTAP10reg in GTAP10_2_GTAP6.keys()}

Imaclim2GTAP10 = collections.defaultdict(list)
for GTAPreg, Imreg in GTAP10_2_Imaclim.items():
    Imaclim2GTAP10[Imreg].append(GTAPreg)


#writing the file 
with open(save_file,'w',newline='') as csvfile:
    writer = csv.writer(csvfile)
    for Imreg, GTAP_regions in Imaclim2GTAP10.items():
        string = Imreg
        for GTAPreg in GTAP_regions:
            string += '|'+GTAPreg
        writer.writerow([string])

