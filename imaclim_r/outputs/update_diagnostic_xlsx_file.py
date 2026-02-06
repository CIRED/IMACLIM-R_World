# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

# -*- coding: utf-8 -*-

import csv
import argparse
import sys
import pandas as pd
import os
import shutil

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--path", type=str)

args = parser.parse_args()

path= args.path
#path="/diskdata/cired/leblanc/ImaclimR_version2.0/trunk_v2.0_outputs/outputs/001_base_2023_07_05_16h24min48s/"
#path="/diskdata/cired/leblanc/ImaclimR_version2.0/trunk_v2.0_outputs/outputs/6201_base.tax2019135.taxbreak_13000.tax21003700.20.5263_2023_07_05_17h38min14s/"

filename_data="data_diagnostic.csv"
filename_metadata="metadata_diagnostic.csv"

xlsx_filename = "imaclim_scenario_diagnostic"
xlsx_filepath = path+"../"+xlsx_filename+".xlsx"

# Tell imaclim runs the file is being updated
os.system("echo 0 > " + xlsx_filename + "_available.txt")

# Load the current scenario
data = pd.read_csv(path+filename_data,sep='|')
metadata = pd.read_csv(path+filename_metadata,sep='|')

data = pd.concat([metadata, data],  axis=1)

# Load the main file and merge if exists, otherwise create it
if os.path.isfile(xlsx_filepath):
    data_xlsx = pd.read_excel( xlsx_filepath)
    data = pd.concat([ data,data_xlsx])

# erase file
data.to_excel( xlsx_filepath, index=False)

# generate a readable copy, not to interfer with th automatic infilling methods
shutil.copyfile(xlsx_filepath, path+"../"+xlsx_filename+"_readable_copy.xlsx")

# Tell imaclim runs the file is available
os.system("echo 1 > " + path+"../"+xlsx_filename+"_available.txt")

#How to improve this file:
#- the excel could be formated to be easily read (e.g., colors)
#- the file vary if the medatada of the new file and of the old file differs term of number of column, but new column are added to the right. However, this is a good thing for reproductibility with post-treatement with excel
#- new scenario are added at the top. May be this is a good thing too. This can be changed.
