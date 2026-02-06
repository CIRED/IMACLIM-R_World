# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Augustin Danneaux
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import numpy as np 
import argparse
import sys
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument("-s", "--scy", type=str)
parser.add_argument("-f", "--filenamedata", type=str)

args = parser.parse_args()

modelname = 'IMACLIM 2.0'

scy= args.scy
filenamedata= args.filenamedata 

# data
datamain = np.genfromtxt( filenamedata, delimiter='\t')

filename='./IMACLIM_waysout_outputs_'+scy+'.csv'


outputvar = pd.read_csv('../list_outputs_str.csv',names=['Variables'])
outputreg =pd.read_csv('../list_template_region.csv', names=['Region'])
outputunit=pd.read_csv('../list_outputs_units.csv', names=['Unit'])
outputscy = pd.DataFrame([scy]*len(outputvar), columns=['Scenario'])
outputmod = pd.DataFrame([modelname]*len(outputvar), columns=['Model'])

datamain  = pd.read_csv(filenamedata,
                    sep='\t',
                    index_col=False,
                    header=None,
                    names= [str(x) for x in range(2014,2102,1)])

merged = pd.concat([outputmod, outputscy, outputreg, outputvar,  outputunit,datamain.iloc[:,1:-1]], axis=1)

merged.to_csv(filename, index=False)