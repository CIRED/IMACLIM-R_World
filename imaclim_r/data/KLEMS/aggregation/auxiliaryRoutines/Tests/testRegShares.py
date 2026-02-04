# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import copy
import csv
import re

with open('output/DataMatrixwithValues.csv', 'r') as f: #KLEMS Data input transformed to a list with 1 value per line
    reader = csv.reader(f,delimiter='|')
    KLEMSData = list(reader)

with open('input/KLEMStoIMACLIM_industries_v2.csv', 'r') as f: #this file specifies how to aggregate the industries of KLEMS data to 12 sector IMACLIM format
    reader = csv.reader(f,delimiter='|')
    KLEMStoIMACLIMindustries = list(reader)

with open('intermediate/RegionsCapShares_v2.csv', 'r') as f: #this file specifies how to aggregate the industries of KLEMS data to 12 sector IMACLIM format
    reader = csv.reader(f,delimiter='|',quoting=csv.QUOTE_NONE)
    RegionsCapShares = list(reader)

with open('input/dicoRegionKLEMS.csv', 'r') as f: #this file specifies how to aggregate the industries of KLEMS data to 12 sector IMACLIM format
    reader = csv.reader(f,delimiter='|',quoting=csv.QUOTE_NONE)
    dicoRegion = list(reader)

with open('input/KLEMStoIMACLIM_products.csv', 'r') as f: #this file specifies how to aggregate the asset-levels of KLEMS data to 12 sector IMACLIM format
    reader = csv.reader(f,delimiter='|')
    KLEMStoIMACLIM_products = list(reader)

with open('input/VariableIndex.csv', 'r') as f: #KLEMS variable index, created previously
    reader = csv.reader(f,delimiter='|')
    VariableIndex = list(reader)

with open('input/Capshares.csv', 'r') as f: #Regions to disaggregate
    reader = csv.reader(f,delimiter='|')
    CapShares = list(reader)

#---------------------------------------------------------- file import ends here
def removeEmptyListItems(Matrix):
    for e in range(len(Matrix)):
        Matrix[e] = filter(None, Matrix[e])
    return Matrix

removeEmptyListItems(KLEMStoIMACLIMindustries)


#print(RegionsCapShares[0])

#for e in range(len(RegionsCapShares[1])):
#    print RegionsCapShares[1][e]

# le KLEMStoIMACLIM_industries est a creer sur la base de KLEMStoIMACLIMv2, et les RegionsCapShar. D'abbord creer un tableau par region, ensuite sur la base du dicoRegion affecter a chaque pays les poids de la region coorespondante.
print "---------------------"

disaggInd=[]
for e in range(len(CapShares)):
    disaggInd.append(CapShares[e][0])

for e in range(len(KLEMStoIMACLIMindustries)):
    KLEMStoIMACLIMindustries.insert(2*e+1,[None]*len(KLEMStoIMACLIMindustries[2*e]))


RegionsKLEMStoIMACLIMindustries=[None]*len(dicoRegion)
for e in range(len(dicoRegion)):
    RegionsKLEMStoIMACLIMindustries[e]=copy.deepcopy(KLEMStoIMACLIMindustries)
    RegionsKLEMStoIMACLIMindustries[e].insert(0,dicoRegion[e][0])
#for e in range(len(RegionsCapShares)):
#    print RegionsCapShares[e]
#print "---------------------------"

#for c in range(2):
#    for e in range(len(RegionsKLEMStoIMACLIMindustries[c])):
#        print RegionsKLEMStoIMACLIMindustries[c][e]

c=0 #regionsIndex
 #disaggInd
i=0 #IMACLIMindustries len(KLEMStoIMACLIMindustries)/2

#RegionsKLEMStoIMACLIMindustries[c][][]


for c in range(len(dicoRegion)):
#for c in range(2):
    for i in range(len(KLEMStoIMACLIMindustries)/2):    # runs over 12 IMACLIMindustries
        RegionsKLEMStoIMACLIMindustries[c][1+2*i+1][0]=RegionsKLEMStoIMACLIMindustries[c][1+2*i][0]

        for k in range(len(KLEMStoIMACLIMindustries[i*2][1:])): # runs over 12 IMACLIMindustries
            
            if KLEMStoIMACLIMindustries[i*2][k+1] in disaggInd:
                #print ("Yey")

                IMAsector=re.compile(KLEMStoIMACLIMindustries[i*2][0])

                IMAsectorMatches = [string for string in RegionsCapShares[(c*6+c)+2*(1+disaggInd.index(KLEMStoIMACLIMindustries[i*2][k+1]))-1] if re.match(IMAsector, string)]

                RegionsKLEMStoIMACLIMindustries[c][1+2*i+1][k+1]=RegionsCapShares[(c*6+c)+2*(1+disaggInd.index(KLEMStoIMACLIMindustries[i*2][k+1]))][RegionsCapShares[(c*6+c)+2*(1+disaggInd.index(KLEMStoIMACLIMindustries[i*2][k+1]))-1].index(IMAsectorMatches[0])] #replace 6 by 2*len(disaggInd)

            else:
                RegionsKLEMStoIMACLIMindustries[c][1+2*i+1][k+1]=1


for c in range(7,len(dicoRegion)):
    for e in range(len(RegionsKLEMStoIMACLIMindustries[c])):
        print RegionsKLEMStoIMACLIMindustries[c][e]


