# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

#There should be a seperate file where raw data file, country, ISIC4 or 3 etc is set.

import csv
import sys

dirIn  = sys.argv[1]
dirOut = sys.argv[2]
f      = sys.argv[3]
operation = "doing "+sys.argv[0]+" on "+f+" in "+dirIn+" into "+dirOut

if len(sys.argv)>4:
    print "problem with "+ operation
else:
    print operation

with open(dirIn+f, 'r') as fo:
    reader = csv.reader(fo,delimiter=',')
    AllData = list(reader)

Year=[]
Country=['AUS']
Var=['I']
Product=['IT']
Industry=['TOT']

for e in range(4,len(AllData[0])): #list all years
    Year.append(int(AllData[0][e]))

for e in range(1,len(AllData)): #list all countries
    if AllData[e][0] <> Country[len(Country)-1]:
        Country.append(AllData[e][0])

#---------------------
for e in range(1,len(AllData)): #list all Var (indicators)
    if AllData[e][1] <> Var[len(Var)-1]:
        Var.append(AllData[e][1])

counter=1
for e in range(len(Var)):
    if Var[0] <> Var[e+1]:
        counter=counter+1
    else:
        break

Var=Var[0:counter] #end of listing all Var

#---------------------
for e in range(1,len(AllData)): #list all Products
    if AllData[e][2] <> Product[len(Product)-1]:
        Product.append(AllData[e][2])

counter=1
for e in range(len(Product)):
    if Product[0] <> Product[e+1]:
        counter=counter+1
    else:
        break

Product=Product[0:counter] #end of listing all Products

#---------------------
for e in range(1,len(AllData)): #list all Industry
    if AllData[e][3] <> Industry[len(Industry)-1]:
        Industry.append(AllData[e][3])

counter=1
for e in range(len(Industry)):
    if Industry[0] <> Industry[e+1]:
        counter=counter+1
    else:
        break

Industry=Industry[0:counter] #end of listing all Industry


#print Year
#print Country
#print Industry

#Write a csv file with the Variable values

Variables=['year', 'country', 'var', 'product', 'industry', 'value']


VariableIndex=[Variables[:1]+Year,Variables[1:2]+Country,Variables[2:3]+Var,Variables[3:4]+Product,Variables[4:5]+Industry]

#for e in range(len(VariableIndex)):
#    print VariableIndex[e]

#---------------------

with open("intermediate/VariableIndex.csv", 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    writer.writerows(VariableIndex)

