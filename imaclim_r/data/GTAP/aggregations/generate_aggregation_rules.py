#! /usr/bin/env python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


import csv
import sys

nb_sector=sys.argv[1]

exclude_list=['','xxx'] # exclude non existing sector, and the xxx sector created fro hybridation

with open('aggregation_Imaclim_GTAP10_sector__before_hybridation.csv', mode='r') as infile:
    reader = csv.reader(infile, delimiter='|')
    before = {rows[0]:[elt for elt in rows[1:] if elt not in exclude_list] for rows in reader}

with open("aggregation_Imaclim_GTAP10_sector"+str(nb_sector)+"__after_hybridation.csv", mode='r') as infile:
    reader = csv.reader(infile, delimiter='|')
    after = {rows[0]:[elt for elt in rows[1:] if elt not in exclude_list] for rows in reader}

no_hybridation={}
for key, value_after in after.items():
    no_hybridation[key] = list()
    for sec_after in value_after:
        if not sec_after in before.keys(): #automatic completion for one to one corresponding sectors
            no_hybridation[key].append(sec_after)
        else:
            for sec_before in before[sec_after]:
                no_hybridation[key].append(sec_before)

with open("aggregation_Imaclim_GTAP10_sector"+str(nb_sector)+"__no_hybridation.csv", mode='w') as outfile:
    writer = csv.writer(outfile, delimiter='|')
    for key, value in no_hybridation.items(): 
        writer.writerow( [key] + value)

