# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import csv

with open('DataMatrixwithValues.csv', 'r') as f: #KLEMS Data input transformed to a list with 1 value per line
    reader = csv.reader(f,delimiter='|')
    KLEMSData = list(reader)

with open('KLEMStoIMACLIM_weights.csv', 'r') as f: #this file specifies how to aggregate the industries of KLEMS data to 12 sector IMACLIM format
    reader = csv.reader(f,delimiter='|')
    KLEMStoIMACLIM_Ind = list(reader)

with open('KLEMStoIMACLIM_products.csv', 'r') as f: #this file specifies how to aggregate the asset-levels of KLEMS data to 12 sector IMACLIM format
    reader = csv.reader(f,delimiter='|')
    KLEMStoIMACLIM_products = list(reader)

with open('VariableIndex.csv', 'r') as f: #KLEMS variable index, created previously
    reader = csv.reader(f,delimiter='|')
    VariableIndex = list(reader)

#---------------------------------------------------------- file import ends here

#we need to get an aggregation rule that multiplies some industries with their share. 

# on the basis of KLEMStoIMACLIM_weights, create a table with the follofwing properties : - every row name is doubled., - the second row needs to have as many elements as the one before, and fill in 1's where there is an empty value.

IndustriesIMACLIM=[]
for e in range(len(KLEMStoIMACLIM_Ind)):
    IndustriesIMACLIM.append(KLEMStoIMACLIM_Ind[e][0])

e=0
while e < len(IndustriesIMACLIM)-1:
    if IndustriesIMACLIM[e]==IndustriesIMACLIM[e+1]:
        del IndustriesIMACLIM[e+1]
        e=e+1
    else:
        e=e+1

#----------------------------------------------------------
#complete KLEMStoIMACLIM_ind so when no share/weight is specified, the weight 1 is assigned
e=0
while e < len(IndustriesIMACLIM)*2:
    if KLEMStoIMACLIM_Ind[e][0]==KLEMStoIMACLIM_Ind[e+1][0]:
        for f in range(len(KLEMStoIMACLIM_Ind[e])):
            if KLEMStoIMACLIM_Ind[e][f] is not '' and KLEMStoIMACLIM_Ind[e+1][f] is '':
                KLEMStoIMACLIM_Ind[e+1][f]=1
        e=e+2
    else:
        KLEMStoIMACLIM_Ind.insert(e+1,[])
        KLEMStoIMACLIM_Ind[e+1].append(KLEMStoIMACLIM_Ind[e][0])
        for f in range(1,len(KLEMStoIMACLIM_Ind[e])):
            if KLEMStoIMACLIM_Ind[e][f] is not '':
                KLEMStoIMACLIM_Ind[e+1].append(1)
        e=e+2

#for e in range(len(KLEMStoIMACLIM_Ind)):
#    print KLEMStoIMACLIM_Ind[e]

#this table is to be split in two parts, one with the indices and one with the weights

#----------------------------------------------------------

def removeEmptyListItems(Matrix):
    for e in range(len(Matrix)):
        Matrix[e] = filter(None, Matrix[e])
    return Matrix

removeEmptyListItems(KLEMStoIMACLIM_Ind)

for e in range(len(KLEMStoIMACLIM_Ind)):
    print KLEMStoIMACLIM_Ind[e]

#----------------------------------------------------------
#create a numeric version of KLEMStoIMACLIM with indices of the KLEMS sectors in the VariableIndex

KLEMStoIMAIndices=[]

for i in range(len(IndustriesIMACLIM)): #get indices of the KLEMS industries in the VariableIndex
    emptyrow=[]
    print(KLEMStoIMACLIM_Ind[i*2])
    for e in range(1,len(KLEMStoIMACLIM_Ind[i*2])):
        emptyrow.append(int(VariableIndex[4].index(KLEMStoIMACLIM_Ind[i*2][e])-1))
    KLEMStoIMAIndices.append(list(emptyrow))

for e in range(len(KLEMStoIMAIndices)):    
    print KLEMStoIMAIndices[e]

#----------------------------------------------------------

KLEMStoIMAWeights=[]

for i in range(len(IndustriesIMACLIM)):
    KLEMStoIMAWeights.append(KLEMStoIMACLIM_Ind[i*2+1])
    
    for e in range(1,len(KLEMStoIMACLIM_Ind[i*2+1])):
        KLEMStoIMAWeights[i][e] = float(KLEMStoIMAWeights[i][e]) 

for e in range(len(KLEMStoIMAWeights)):    
    print KLEMStoIMAWeights[e]

#----------------------------------------------------------









