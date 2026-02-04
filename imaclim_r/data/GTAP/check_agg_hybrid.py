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


input_data_sam, input_dimensions_values_sam, input_data_dimensions_sam = aggregation_GTAP.read_dimensions_tables_file( 'GTAP_Imaclim_after_hybridation/outputs_GTAP10_2014/GTAP_SAM__Imaclim.12reg.12sec__GTAP10_2014.csv')

Cons = 0
for domimp in ['_dom', '_imp']:
    for elt in ['Ener_C_hsld_residential' , 'Ener_C_hsld_road']:
        Cons += input_data_sam[ elt+ domimp]
        if np.where( input_data_sam[ elt+ domimp] <0)[0].shape[0] != 0:
            print("negative values in: ", elt+ domimp) 
            print( input_data_sam[ elt+ domimp][ np.where( input_data_sam[ elt+ domimp] <0)] )
            print( np.where( input_data_sam[ elt+ domimp] <0) )
    Cons += input_data_sam[ 'Ener_CI'+domimp].sum(axis=1)
    if np.where( input_data_sam[ 'Ener_CI'+domimp] <0)[0].shape[0] != 0:
        print("negative values in: ", 'Ener_CI'+domimp) 
        print( np.where( input_data_sam[ 'Ener_CI'+ domimp] <0))
        print( input_data_sam[ 'Ener_CI'+ domimp][ np.where( input_data_sam[ 'Ener_CI'+ domimp] <0)] )

Imp = input_data_sam[ 'Ener_Imp']
ratio = Imp/Cons
if np.where( ratio>0)[0].shape[0] != 0:
    print("there is imports greater than total consumption")

#pb here: Ener_CI_dom Gas|Othertransp|CAN|-436.732078139
#Ener_CI_imp Gas|Othertransp|CAN|-92.6620317843

