# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


import pandas as pd
import csv

dic_gtap_im_bh = dict()
file_path = "aggregation_Imaclim_GTAP10_sector__before_hybridation.csv"
with open(file_path, mode ='r')as file:
  csvFile = csv.reader(file, delimiter='|')
  for lines in csvFile:
      lines = [e for e in lines if e != '']
      dic_gtap_im_bh[ lines[0]] = lines[1:]

dic_gtap_im_ah = dict()
file_path = "aggregation_Imaclim_GTAP10_sector12__after_hybridation.csv"
with open(file_path, mode ='r')as file:
  csvFile = csv.reader(file, delimiter='|')
  for lines in csvFile:
      lines = [e for e in lines if e != '']
      dic_gtap_im_ah[ lines[0]] = lines[1:]


Im_sec_dict = {}
for k,i in dic_gtap_im_ah.items():
    Im_sec_dict[k] = list()
    for elt in i:
        if elt in list(dic_gtap_im_bh.keys()):
            for e in dic_gtap_im_bh[elt]:
                Im_sec_dict[k].append(e)
        else:
            Im_sec_dict[k].append(elt)


#output the result
with open('imaclim_gtap_sectors.csv', 'w', newline='') as csvfile:
    fieldnames = ['IMACLIM-R Sectrors', 'GTAP10']
    writer = csv.writer(csvfile, delimiter=';')
    writer.writerow(fieldnames)
    for k,i in Im_sec_dict.items():
        for e in i:
            writer.writerow( [k,e])
