# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import csv

with open('all_capital_09I.csv', 'r') as f:
    reader = csv.reader(f,delimiter=',')#,quoting=csv.QUOTE_NONNUMERIC)
    #next(reader)
    #for row in reader:
        #print(row)
    AllData = list(reader)


i=0

while i < len(AllData):

    if AllData[i][1]=='IRR':
        del AllData[i]
        i=i
    else:
        i=i+1
        

#---------------------
import csv

with open("all_capital_09I_noIRR_nodep.csv", 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    writer.writerows(AllData)
