# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import pandas as pd
import os

output_path='results/'
input_path='manual_download/'
file_in='List_of_ISO_3166_country_codes_1.csv'

string_extension = "_cleaned"
# Split the file name into the base name and extension
base_name, extension = os.path.splitext(file_in)
# Add the string extension before the existing extension
file_out = f"{base_name}{string_extension}{extension}"


output_path
if not os.path.exists(output_path):
    # If it doesn't exist, create it
    os.makedirs(output_path)


df = pd.read_csv(input_path+file_in,skiprows=1)
df = df[df['Alpha-3 code'].str.len() == 3]
df.to_csv(output_path+file_out,index=False)
