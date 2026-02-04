# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import sys, csv, os


with open('input/europeD/all_countries_09I.csv', 'r') as f:
    reader = csv.reader(f,delimiter='|')
    AllData = list(reader)

#------------------------------------------------------


lengthRows=[len(AllData[e]) for e in range(len(AllData))]

minR=min(lengthRows)
maxR=max(lengthRows)

if min==max:
    print('Yay and min=max=', minR)
else:
    print('minR = ',minR, 'maxR = ',maxR)




infoMissingCol=[]
for e in range(len(AllData)):

    if len(AllData[e])==minR:

        infoMissingCol.append(AllData[e][:2])


print('infoMissingCol')
print(set([infoMissingCol[e][0] for e in range(len(infoMissingCol))]))
print(set([infoMissingCol[e][1] for e in range(len(infoMissingCol))]))


#---------------------COnclusions :

#SVN stops at 2006, missing empty cell at end of row in raw file.
#JPN idem, stops at 2006
#PRT idem, stops at 2006, all vars
#POL idem, stops at 2006

