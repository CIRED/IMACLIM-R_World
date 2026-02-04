# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import copy
import csv

with open('input/Capital.csv', 'r') as f: #Aggregated Capital GTAP data
    reader = csv.reader(f,delimiter='|')
    Capital = list(reader)

with open('input/Capshares.csv', 'r') as f: #Aggregated Capital GTAP data
    reader = csv.reader(f,delimiter='|')
    CapShares = list(reader)

#------------------------------------------------------

#what output to produce ?

# Convert CapShares in the numerical equivalent, CapShares with the double amount of rows, vars, numbers.

# From CapShares, add lines with shares to KLEMStoIMACLIM_industries.

#------------------------------------------------------

def createEmptyMatrix(n,m):
    emptyAllData=[]
    emptyRow=[None]*(m)
    for e in range(n):
        emptyAllData.append(list(emptyRow))
    return emptyAllData

#print float(Capital[1][Capital[0].index(CapSharesVar[0][1])])

Regions=[]

for e in range(1,len(Capital)):
    Regions.append(Capital[e][0])

print Regions

RegionsCapShares=[None]*len(Regions)

for e in range(len(CapShares)):

    CapShares.insert(e*2+1,[None]*len(CapShares[e*2]))
    CapShares[e*2+1][0]=CapShares[e*2][0]

for e in range(len(RegionsCapShares)):
    RegionsCapShares[e]=copy.deepcopy(CapShares)


for e in range(len(Regions)):
#for e in range(2):
    
    for g in range(len(CapShares)/2): 
        Auxiliary=[]
        for f in range(1,len(CapShares[2*g+1])):
            Auxiliary.append(float(Capital[e+1][Capital[0].index(RegionsCapShares[e][2*g][f])]))
            RegionsCapShares[e][2*g+1][f]=float(Capital[e+1][Capital[0].index(RegionsCapShares[e][2*g][f])])

        RegionsCapShares[e][2*g+1][1:]=[RegionsCapShares[e][2*g+1][i]/sum(Auxiliary) for i in range(1,len(CapShares[2*g+1]))]
#RegionsCapShares[e][2*g+1]=RegionsCapShares[e][2*g+1]/sum(Auxiliary)
        

#RegionsCapShares[1][1][1] = Capital[2][Capital[1].index(RegionsCapShares[e][2*g][f])]

#insert RegionNames ?

RegionsCapShares.insert(0,list(Regions))

#---------------------------------------------------------------------------------

print('-----------')

for g in range(len(RegionsCapShares)):
    for e in range(len(RegionsCapShares[g])):
        print RegionsCapShares[g][e]
    print '------------'


#for e in range(1,len(RegionsCapShares)):
#    for h in range(len(RegionsCapShares[e])/2):
#        print sum(RegionsCapShares[e][h*2+1][1:])

#---------------------------------------------------------------------------------

with open("RegionsCapShares.csv", 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    writer.writerow(RegionsCapShares[0])
    for e in range(1,len(RegionsCapShares)):
        writer.writerows(RegionsCapShares[e])
