#! /usr/bin/env python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Nicolas Graves
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


import pandas as pd
import csv
import sys
import collections

income_share_data = sys.argv[1]

## %run python3 ./process_income_share.py $income_share_data/EAR_4MTH_SEX_ECO_CUR_NB_A.csv

#Extracting income share data
income_share = pd.read_csv(income_share_data)

income_share.drop(columns=['indicator','note_indicator','note_source'],inplace=True)

