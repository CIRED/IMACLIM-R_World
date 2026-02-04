# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import csv

with open('VariableIndex.csv', 'r') as f:
    reader = csv.reader(f,delimiter='|')#,quoting=csv.QUOTE_NONNUMERIC)
    #next(reader)
    #for row in reader:
        #print(row)
    VariableIndex = list(reader)


Variables=[]

for e in range(len(VariableIndex)):
    Variables.append(VariableIndex[e][0])
Variables.append('value')

Years=VariableIndex[0][1:len(VariableIndex[0])] #convert to integers

Countries=VariableIndex[1][1:len(VariableIndex[1])]

Vars=VariableIndex[2][1:len(VariableIndex[2])]

Products=VariableIndex[3][1:len(VariableIndex[3])]

Industries=VariableIndex[4][1:len(VariableIndex[4])]

print Products

numberofYears=len(Years)
numberofCountries=len(Countries) # number of Countries
numberofVars=len(Vars) # number of Variables
numberofProducts=len(Products) # number of Products
numberofIndustries=len(Industries) # number of Industries
