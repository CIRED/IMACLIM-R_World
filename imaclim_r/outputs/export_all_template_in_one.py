#! /data/software/mambaforge/mambaforge//envs/MostUpdated/bin/python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Thomas Le Gallic
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


import pandas as pd
import pyam
import os
import itertools
import datetime

def list_files_in_folder(folder_path):
    file_list = []  # List to store the file paths
    # Iterate over all files and subdirectories in the given folder
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            # Print the absolute path of each file
            file_path = os.path.join(root, file)
            file_list.append(file_path)
    return file_list

def longest_common_substring(s1, s2):
   set1 = set(s1[begin:end] for (begin, end) in
              itertools.combinations(range(len(s1)+1), 2))
   set2 = set(s2[begin:end] for (begin, end) in
              itertools.combinations(range(len(s2)+1), 2))
   common = set1.intersection(set2)
   maximal = [com for com in common
              if sum((s.find(com) for s in common)) == -1 * (len(common)-1)]
   len_s = [len(s) for s in maximal]
   max_s = maximal[len_s.index(max(len_s))]
   return max_s

def longest_common_substring_list( l1):
    shortest = l1[0]
    for i in range(len(l1)-1):
        shortest = longest_common_substring( shortest, l1[i+1])
    return shortest
    

def select_files_by_creation_time(file_list, creation_time_threshold):
    selected_files = []
    for file_path in file_list:
        creation_time = os.path.getctime(file_path)
        if creation_time > creation_time_threshold.timestamp():
            selected_files.append(file_path)
    return selected_files

def select_most_recent_files(file_list):
    # Create a dictionary to store files based on their names
    files_by_name = {}
    for file_path in file_list:
        file_name = os.path.basename(file_path)
        if file_name not in files_by_name:
            files_by_name[file_name] = file_path
        else:
            existing_time = os.path.getmtime(files_by_name[file_name])
            new_time = os.path.getmtime(file_path)
            if new_time > existing_time:
                files_by_name[file_name] = file_path
    return list(files_by_name.values())
    
def select_files_by_directory_name(file_list, directory_name):
    selected_files = []
    for file_path in file_list:
        # Check if the directory name contains the specified character string
        if directory_name in os.path.dirname(file_path):
            selected_files.append(file_path)
    return selected_files    

list_xlsx_file = [elt for elt in list_files_in_folder('./') if '.xlsx' in elt and 'IMACLIM' in elt]

# File selection options: which of the xlsx file do you want to combine?
        #be careful, you need to define in line 80 (and change the lines before) which of the selection options you want to apply

# 1. Select files created after a given date and time
creation_time_threshold = datetime.datetime(2023, 7, 21, 12, 00, 00) # year, month, day, hour, minute, second
selected_files_by_time = select_files_by_creation_time(list_xlsx_file, creation_time_threshold)

# 2. Select the most recent files among those with the same name
selected_files_unique = select_most_recent_files(selected_files_by_time)
 
# 3. Select files based on the presence of a specified string in the directory name
selected_files_by_directory = select_files_by_directory_name(list_xlsx_file, 'your_directory_name_here') #here you can use, for example, a date or a prefix-combi name?
 
selected_files = selected_files_unique
 
output_excel = longest_common_substring_list(selected_files).split('/')[-1] + '.xlsx'

#output_excel = longest_common_substring_list(list_xlsx_file).split('/')[-1] + '.xlsx'    

if os.path.exists(output_excel):
    os.remove(output_excel)

data_loaded=False
if data_loaded==False:
    df=pyam.concat( [pyam.IamDataFrame(x) for x in selected_files])
    data_loaded = True

#year2select=[i for i in df.year if i<=2050]
#suceed_run = ['Lab','Lump','Prod','Default']
#suceed_run = ['Lump','Default']
#scenario2select=[sc for sc in df.scenario if any(i in sc for i in suceed_run)]
#df = df.filter(year= year2select, scenario=scenario2select)

#### UNcomment to rename
#dict_rename_sc = {"scenario": {k:k+"_NodivChange" for k in df.scenario}}
#df = df.rename(dict_rename_sc)

# Set Manuscript name and DOI
# where xxx is replaced by a shorthand like „Leblanc et al. (2025)“ and yyy is a DOI (without the https://doi.org/ part)
DOI=""
short_citation=""
df.set_meta(short_citation, "Scientific Manuscript (Citation)")
df.set_meta(DOI, "Scientific Manuscript (DOI)")

filter_common_definitions_template=False
if filter_common_definitions_template:
    df = pd.read_excel("common-definitions-template.xlsx", sheet_name='variable')
    varname_common = df['variable'].to_list()
    to_keep = [var for var in df.variables if var in varname_common]
    df = df.filter(variable = to_keep)

df.to_excel(output_excel, sheet_name='data', iamc_index=True, include_meta=True)


