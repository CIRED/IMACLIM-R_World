# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Nicolas Graves
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import sys
import os
import argparse
import copy
import numpy as np
import common_cired
import aggregation_GTAP


dataPath = '/data/shared/GTAP/results/extracted_GTAP10_2011/GTAP_tables.csv'


input_data, input_dimensions_values, input_data_dimensions = aggregation_GTAP.read_dimensions_tables_file(dataPath)



domEVol_Cons_Firms = input_data['EDF'] #usage of domestic product by firms, Mtoe
domEVol_Cons_PublicAdmi = input_data['EDG'] #government consumption of domestic product, Mtoe
domEVol_Cons_Households = input_data['EDP'] #private consumption of domestic product, Mtoe

impEVol_Cons_Firms = input_data['EIF'] #usage of imports by firms, Mtoe
impEVol_Cons_PublicAdmi = input_data['EIG'] #government consumption of imports, Mtoe
impEVol_Cons_Households = input_data['EIP'] #private consumption of imports, Mtoe

tradeEVol = input_data['EXI'] #volume of trade, Mtoe

nb_energies = len(input_dimensions_values['ERG_COMM'])
TPES = np.zeros(nb_energies)
for k in range(nb_energies):
    TPES[k] = np.sum(domEVol_Cons_PublicAdmi[k,:]+impEVol_Cons_PublicAdmi[k,:]+domEVol_Cons_Households[k,:]+impEVol_Cons_Households[k,:])+np.sum(domEVol_Cons_Firms[k,:,:])+np.sum(impEVol_Cons_Firms[k,:,:]) 


print(TPES)
