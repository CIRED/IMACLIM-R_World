#! /usr/bin/env python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Patrice Dumas, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


# This file is designed to support the diagnosis of GTAP treatment of IEA data.
# Results and corresponding paragraphs are compiled in the file of the same name on the Google Drive folder ImaclimV2.
# A large part of the file is just a copy of the file comparaison_GTAP_AIE_Enerdata.py, which targets were broader originally.

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
import collections
from IPython.display import display
import argparse

########################
df_2014=pd.read_csv('results_2014/Imaclim_final_saved.csv',delimiter='|',header=3)
df_2011=pd.read_csv('results_2011/Imaclim_final_saved.csv',delimiter='|',header=3)
df_2001=pd.read_csv('results_2001/Imaclim_final_saved.csv',delimiter='|',header=3)

prod_2014 = df_2014[ df_2014['Flow']=="Production_recomposed"][ ["coa","oil","gas_gdt","p_c","ely"]]
prod_2011 = df_2011[ df_2011['Flow']=="Production_recomposed"][ ["coa","oil","gas_gdt","p_c","ely"]]
prod_2001 = df_2001[ df_2001['Flow']=="Production_recomposed"][ ["coa","oil","gas_gdt","p_c","ely"]]

outputpath="txCaptemp_Ener/"
os.system("mkdir -p "+outputpath)

with open(outputpath+'txCaptemp_Ener_2011_2014.csv','w') as file:
    file.write('//Production increase for the 5 energy sector, 12 Imaclim regions, from 2011 to 2014 from IEA statistics')
    txcap=prod_2014 / prod_2011-1
    txcap.to_csv(file,sep= '|',index=False)

outputpath="prod_Ener/"
os.system("mkdir -p "+outputpath)

for year in [2001,2011,2014]:
    with open(outputpath+'prod_Ener_'+str(year)+'.csv','w') as file:
        file.write('//Production for the 5 energy sector, 12 Imaclim regions, year '+str(year)+', from IEA statistics')
        exec('varout = prod_'+str(year))
        varout.to_csv(file,sep= '|',index=False)

