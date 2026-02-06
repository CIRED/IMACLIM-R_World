# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Nicolas Graves
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import csv
import re
import sys
import os
import pandas as pd 

file_name=sys.argv[1]

string_extension = "_clean"

# Split the file name into the base name and extension
base_name, extension = os.path.splitext(file_name)
# Add the string extension before the existing extension
new_file_name = f"{base_name}{string_extension}{extension}"
new_file_name = new_file_name.split('/')[-1:][0]

output_path='results/'
if not os.path.exists(output_path):
    # If it doesn't exist, create it
    os.makedirs(output_path)

# Open the CSV file
with open(file_name, 'r') as csvfile:
    # Create a CSV reader object
    reader = csv.reader(csvfile, delimiter='\t')
    
    data_for_df = dict()
    list_key=list()
    # Iterate over the rows
    for i, row in enumerate(reader):
        if len(row[0].replace(' ','').replace('-',''))==0:
            continue
        if i==0:
            for elt in re.sub(r'(?<!\S) +|  +', '|', row[0]).split('|'):
                list_key.append(elt)
                data_for_df[elt] = list()   
        elif row[0][0]==' ':
            data_for_df[list_key[1]][-1] += elt
        else:
            for j, elt in enumerate( re.sub(r'(?<!\S) +|  +', '|', row[0]).split('|')):
                data_for_df[list_key[j]].append(elt) 

df = pd.DataFrame(data=data_for_df)
df.to_csv(output_path+new_file_name,index=False,sep='|')
