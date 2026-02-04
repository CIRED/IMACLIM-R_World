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

e=1
while e < len(KLEMSData):
    if KLEMSData[e][5]=='NA':
        e=e+1
    else:
        KLEMSData[e][5]=float(KLEMSData[e][5])
        e=e+1

#----------------------------------------------------------
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
#If industriesIMACLIM is added to VariableIndex, some param need to be adapted accordingly below
#VariableIndex.append(IndustriesIMACLIM)

#VariableIndex[len(VariableIndex)-1].insert(0,'industriesIMACLIM')

#with open("VariableIndex.csv", 'w') as output:
#    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
#    writer.writerows(VariableIndex)
#----------------------------------------------------------

def removeEmptyListItems(Matrix):
    for e in range(len(Matrix)):
        Matrix[e] = filter(None, Matrix[e])
    return Matrix

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

removeEmptyListItems(KLEMStoIMACLIM_Ind)

#for e in range(len(KLEMStoIMACLIM_Ind)):
#    print KLEMStoIMACLIM_Ind[e]

#this table is to be split in two parts, one with the indices and one with the weights

#----------------------------------------------------------

# create an empty matrix with as industries the target IMACLIM industries
for e in range(len(VariableIndex)):
    print VariableIndex[e]

Variables=[]

for e in range(len(VariableIndex)):
    Variables.append(VariableIndex[e][0])
Variables.append('value')

Years=VariableIndex[0][1:len(VariableIndex[0])] 
Countries=VariableIndex[1][1:len(VariableIndex[1])]
Vars=VariableIndex[2][1:len(VariableIndex[2])]
Products=VariableIndex[3][1:len(VariableIndex[3])]
IndustriesKLEMS=VariableIndex[4][1:len(VariableIndex[4])]

numberofYears=len(Years)
numberofCountries=len(Countries)
numberofVars=len(Vars) 
numberofProducts=len(Products) 
numberofIndustriesKLEMS=len(IndustriesKLEMS)
numberofIndustriesIMACLIM=len(IndustriesIMACLIM) 

nY=numberofYears
nC=numberofCountries
nVars=numberofVars
nProd=numberofProducts
nIndKLEMS=numberofIndustriesKLEMS
nIndIMACLIM=numberofIndustriesIMACLIM
nProdIMACLIM=numberofIndustriesIMACLIM

IOTableIndustries=[]

IOTableIndustries.append(Variables)

def createEmptyMatrix(n,m):
    emptyAllData=[]
    emptyRow=[None]*(m)
    for e in range(n):
        emptyAllData.append(list(emptyRow))
    return emptyAllData

#numberofRows = nY*nC*nVars*nProd*nIndIMACLIM

print("creating empty datamatrix to aggreagate industries")
IOTableIndustries.extend(createEmptyMatrix(nY*nC*nVars*nProd*nIndIMACLIM,len(Variables)))

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

#filling the first 5 columns of the table is same as before. to fill the last column... Agregation rules are given by KLEMStoIMACLIM
#Auxiliaryrow=[]

print("completing empty table with values, aggregated over industries")
for i in range(nY):
#for i in range(1):
    for e in range(nC*nVars*nProd*nIndIMACLIM):
        IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+e+1][0]=Years[i]

    for j in range(nC): #add Country values
        for k in range(nVars*nProd*nIndIMACLIM):
            IOTableIndustries[i*nC*nVars*nProd*nIndIMACLIM+(j*nVars*nProd*nIndIMACLIM+k+1)][1]=Countries[j]

        for l in range(nVars): #add Var values
            for m in range(nProd*nIndIMACLIM):

                IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+(j*nVars*nProd*nIndIMACLIM)+((l*nProd*nIndIMACLIM)+m+1)][2]=Vars[l]

            for n in range(nProd): #add Product values
                for o in range(nIndIMACLIM):

                    IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+(j*nVars*nProd*nIndIMACLIM)+(l*nProd*nIndIMACLIM)+((n*nIndIMACLIM)+o+1)][3]=Products[n]

                    IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+(j*nVars*nProd*nIndIMACLIM)+(l*nProd*nIndIMACLIM)+(n*nIndIMACLIM)+o+1][4]=IndustriesIMACLIM[o]
                    Auxiliaryrow=[]
                    for p in KLEMStoIMAIndices[o]: #add Industry values
                        Auxiliaryrow.append(KLEMSData[(i*nC*nVars*nProd*nIndKLEMS)+(j*nVars*nProd*nIndKLEMS)+(l*nProd*nIndKLEMS)+(n*nIndKLEMS)+p+1][5])
                    if 'NA' in Auxiliaryrow:
                        IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+(j*nVars*nProd*nIndIMACLIM)+(l*nProd*nIndIMACLIM)+(n*nIndIMACLIM)+o+1][5]='NA'
                        Auxiliaryrow=[]
                    else:
                        for q in range(len(Auxiliaryrow)):
                            Auxiliaryrow[q]=Auxiliaryrow[q] * KLEMStoIMAWeights[o][q+1]

                        IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+(j*nVars*nProd*nIndIMACLIM)+(l*nProd*nIndIMACLIM)+(n*nIndIMACLIM)+o+1][5]=sum(Auxiliaryrow)
                        Auxiliaryrow=[]

                    #print(IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+(j*nVars*nProd*nIndIMACLIM)+(l*nProd*nIndIMACLIM)+(n*nIndIMACLIM)+o+1])

#----------------------------------------------------------

#with open("IOTableIndustrieswithValues_weights.csv", 'w') as output:
#    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
#    writer.writerows(IOTableIndustries)

#---------------------------------------------------------- aggreagate product levels

IOTable=[]

Variables_IO=Variables
#Variables_IO[3]=''

IOTable.append(Variables_IO)

print("creating empty datamatrix to aggregate products")
IOTable.extend(createEmptyMatrix(nY*nC*nVars*nIndIMACLIM*nIndIMACLIM,len(Variables_IO)))

#----------------------------------------------------------

#create a numeric version of KLEMStoIMACLIM_products with indices of the KLEMS sectors in the VariableIndex

removeEmptyListItems(KLEMStoIMACLIM_products)

KLEMStoIMAIndices_products=[]
emptyrow=[]

for i in range(len(IndustriesIMACLIM)): #get indices of the KLEMS industries in the VariableIndex
    for e in range(1,len(KLEMStoIMACLIM_products[i])):
        emptyrow.append(int(VariableIndex[3].index(KLEMStoIMACLIM_products[i][e])-1))
    KLEMStoIMAIndices_products.append(list(emptyrow))
    emptyrow=[]
    
print KLEMStoIMAIndices_products

#----------------------------------------------------------
# nProdIMACLIM = nIndIMACLIM

print("completing empty table with values, aggregated over products")
for i in range(nY):
#for i in range(1):
    for e in range(nC*nVars*nProdIMACLIM*nIndIMACLIM):
        IOTable[(i*nC*nVars*nProdIMACLIM*nIndIMACLIM)+e+1][0]=Years[i]

    for j in range(nC): #add Country values
        for k in range(nVars*nProdIMACLIM*nIndIMACLIM):
            IOTable[i*nC*nVars*nProdIMACLIM*nIndIMACLIM+(j*nVars*nProdIMACLIM*nIndIMACLIM+k+1)][1]=Countries[j]

        for l in range(nVars): #add Var values
            for m in range(nProdIMACLIM*nIndIMACLIM):

                IOTable[(i*nC*nVars*nProdIMACLIM*nIndIMACLIM)+(j*nVars*nProdIMACLIM*nIndIMACLIM)+((l*nProdIMACLIM*nIndIMACLIM)+m+1)][2]=Vars[l]

            for n in range(nProdIMACLIM): #add Product_IMACLIM values
                for o in range(nIndIMACLIM):

                    IOTable[(i*nC*nVars*nProdIMACLIM*nIndIMACLIM)+(j*nVars*nProdIMACLIM*nIndIMACLIM)+(l*nProdIMACLIM*nIndIMACLIM)+((n*nIndIMACLIM)+o+1)][3]=IndustriesIMACLIM[n]

                    IOTable[(i*nC*nVars*nProdIMACLIM*nIndIMACLIM)+(j*nVars*nProdIMACLIM*nIndIMACLIM)+(l*nProdIMACLIM*nIndIMACLIM)+(n*nIndIMACLIM)+o+1][4]=IndustriesIMACLIM[o]
                    Auxiliaryrow=[]
                    for p in KLEMStoIMAIndices_products[n]:
                        
                        Auxiliaryrow.append(IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+(j*nVars*nProd*nIndIMACLIM)+(l*nProd*nIndIMACLIM)+(p*nIndIMACLIM)+o+1][5])

                    if 'NA' in Auxiliaryrow:

                        IOTable[(i*nC*nVars*nProdIMACLIM*nIndIMACLIM)+(j*nVars*nProdIMACLIM*nIndIMACLIM)+(l*nProdIMACLIM*nIndIMACLIM)+(n*nIndIMACLIM)+o+1][5]='NA'

                        Auxiliaryrow=[]
                    else:   

                        IOTable[(i*nC*nVars*nProdIMACLIM*nIndIMACLIM)+(j*nVars*nProdIMACLIM*nIndIMACLIM)+(l*nProdIMACLIM*nIndIMACLIM)+(n*nIndIMACLIM)+o+1][5]=sum(IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+(j*nVars*nProd*nIndIMACLIM)+(l*nProd*nIndIMACLIM)+(q*nIndIMACLIM)+o+1][5] for q in KLEMStoIMAIndices_products[n])
                        Auxiliaryrow=[]
                   # print IOTable[(i*nC*nVars*nProdIMACLIM*nIndIMACLIM)+(j*nVars*nProdIMACLIM*nIndIMACLIM)+(l*nProdIMACLIM*nIndIMACLIM)+(n*nIndIMACLIM)+o+1]







#----------------------------------------------------------

with open("IOTablewithValues_weights.csv", 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    writer.writerows(IOTable)

#----------------------------------------------------------
# seperate procedure : Once newMatrix created, create the 2x2 matrices per country and year.
