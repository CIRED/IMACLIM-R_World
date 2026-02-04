# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import copy
import csv
import re
import sys, os
import numpy as np

dirInput   	= sys.argv[1]
dirIntermediate = sys.argv[2]
dirOut 		= sys.argv[3]
AllDataNarrow 	= sys.argv[4]
yearShares 	= sys.argv[5]

#inFile = sys.argv[3]

operation = "doing "+sys.argv[0]+" on "+ AllDataNarrow +' into '+dirOut+'IOTablewithValues_countries.csv'
if len(sys.argv)>6:
    print('---------------------------------------------')
    print('---------------------------------------------')
    print("problem with "+ operation)
else:
    print('---------------------------------------------')
    print('---------------------------------------------') 
    print(operation)



with open(dirIntermediate+AllDataNarrow, 'r') as f: #KLEMS Data input transformed to a list with 1 value per line
    reader = csv.reader(f,delimiter='|')
    KLEMSData = list(reader)

with open(dirInput+'KLEMStoIMACLIM_industries.csv', 'r') as f: #this file specifies how to aggregate the industries of KLEMS data to 12 sector IMACLIM format
    reader = csv.reader(f,delimiter='|')
    KLEMStoIMACLIMindustries = list(reader)

with open(dirInput+'KLEMStoIMACLIM_products.csv', 'r') as f: #this file specifies how to aggregate the asset-levels of KLEMS data to 12 sector IMACLIM format
    reader = csv.reader(f,delimiter='|')
    KLEMStoIMACLIM_products = list(reader)

with open(dirInput+'dicoRegionKLEMS.csv', 'r') as f: #this file specifies the correspondance between KLEMS country codes and IMACLIM world regions
    reader = csv.reader(f,delimiter='|',quoting=csv.QUOTE_NONE)
    dicoRegion = list(reader)

with open('intermediate/RegionsCapShares-'+yearShares+'.csv', 'r') as f: #this file specifies how to aggregate the industries of KLEMS data to 12 sector IMACLIM format. it was created by 3determineShares.py
    reader = csv.reader(f,delimiter='|',quoting=csv.QUOTE_NONE)
    RegionsCapShares = list(reader)

with open(dirIntermediate+'VariableIndex.csv', 'r') as f: #KLEMS variable index, created previously
    reader = csv.reader(f,delimiter='|')
    VariableIndex = list(reader)

with open('input/Capshares.csv', 'r') as f: #KLEMS industry-levels to disaggregate according to shares issued from GTAP data
    reader = csv.reader(f,delimiter='|')
    CapShares = list(reader)

#----------------------------------------------------------

IndustriesIMACLIM=[]
for e in range(len(KLEMStoIMACLIMindustries)):
    IndustriesIMACLIM.append(KLEMStoIMACLIMindustries[e][0])

#----------------------------------------------------------


Years=VariableIndex[0][1:len(VariableIndex[0])] 
Countries=VariableIndex[1][1:len(VariableIndex[1])]
Vars=VariableIndex[2][1:len(VariableIndex[2])]
Products=VariableIndex[3][1:len(VariableIndex[3])]
IndustriesKLEMS=VariableIndex[4][1:len(VariableIndex[4])]

numberofYears=len(Years)
numberofCountries=len(Countries) # number of Countries
numberofVars=len(Vars) # number of Variables
numberofProducts=len(Products) # number of Products
numberofIndustriesKLEMS=len(IndustriesKLEMS)
numberofIndustriesIMACLIM=len(IndustriesIMACLIM) # number of Industries

nY=numberofYears
nC=numberofCountries
nVars=numberofVars
nProd=numberofProducts
nIndKLEMS=numberofIndustriesKLEMS
nIndIMACLIM=numberofIndustriesIMACLIM
nProdIMACLIM=numberofIndustriesIMACLIM

#---------------------------------------------------------- check whether all countries are in dicoRegionKLEMS.csv
missingdicoRegion=[]
AllcountriesInDico=[]

for e in range(len(dicoRegion)):
    AllcountriesInDico.extend(dicoRegion[e][1:])

for c in Countries:
    if c in AllcountriesInDico:
        pass
    else:
        missingdicoRegion.append(c)

if len(missingdicoRegion) > 0:

    print('The following countries need to be added to input/dicoRegionKLEMS.csv', missingdicoRegion)

#---------------------------------------------------------- file import ends here
def removeEmptyListItems(Matrix):
    for e in range(len(Matrix)):
        Matrix[e] = [_f for _f in Matrix[e] if _f]
    return Matrix

def createEmptyMatrix(n,m):
    emptyData=[]
    emptyRow=[None]*(m)
    for e in range(n):
        emptyData.append(list(emptyRow))
    return emptyData

removeEmptyListItems(KLEMStoIMACLIMindustries)

#----------------------------------------------------------
#convert to float
e=1
while e < len(KLEMSData):
    if KLEMSData[e][5]=='NA':
        e=e+1
    else:
        KLEMSData[e][5]=float(KLEMSData[e][5])
        e=e+1

#----------------------------------------------------------
# le KLEMStoIMACLIM_industries est a creer sur la base de KLEMStoIMACLIMv2, et les RegionsCapShar. D'abbord creer un tableau par region, ensuite sur la base du dicoRegion affecter a chaque pays les poids de la region coorespondante.
print("---------------------")

disaggInd=[]   #TODO: use RegiosnCapShares to create disaggInd
for e in range(len(CapShares)):
    disaggInd.append(CapShares[e][0])

#----------------------------------------------------------
#we need to get an aggregation rule that multiplies some industries with their share. 

# on the basis of KLEMStoIMACLIM_industries, create a table with the follofwing properties : - every row name is doubled., - the second row needs to have as many elements as the one before, and fill in 1's where there is an empty value.

for e in range(len(KLEMStoIMACLIMindustries)):
    KLEMStoIMACLIMindustries.insert(2*e+1,[None]*len(KLEMStoIMACLIMindustries[2*e]))


RegionsKLEMStoIMACLIMindustries=[None]*len(dicoRegion)
for e in range(len(dicoRegion)):
    RegionsKLEMStoIMACLIMindustries[e]=copy.deepcopy(KLEMStoIMACLIMindustries)
    RegionsKLEMStoIMACLIMindustries[e].insert(0,dicoRegion[e][0])



for c in range(len(dicoRegion)):
    for i in range( int(len(KLEMStoIMACLIMindustries)/2)):    # runs over 12 IMACLIMindustries
        RegionsKLEMStoIMACLIMindustries[c][1+2*i+1][0]=RegionsKLEMStoIMACLIMindustries[c][1+2*i][0]

        for k in range(len(KLEMStoIMACLIMindustries[i*2][1:])): # runs over 12 IMACLIMindustries
            
            if KLEMStoIMACLIMindustries[i*2][k+1] in disaggInd:

                IMAsector=re.compile(KLEMStoIMACLIMindustries[i*2][0])

                IMAsectorMatches = [string for string in RegionsCapShares[(c*6+c)+2*(1+disaggInd.index(KLEMStoIMACLIMindustries[i*2][k+1]))-1] if re.match(IMAsector, string)]

                RegionsKLEMStoIMACLIMindustries[c][1+2*i+1][k+1]=float(RegionsCapShares[(c*6+c)+2*(1+disaggInd.index(KLEMStoIMACLIMindustries[i*2][k+1]))][RegionsCapShares[(c*6+c)+2*(1+disaggInd.index(KLEMStoIMACLIMindustries[i*2][k+1]))-1].index(IMAsectorMatches[0])]) #replace 6 by 2*len(disaggInd)

            else:
                RegionsKLEMStoIMACLIMindustries[c][1+2*i+1][k+1]=1


#for c in range(7,len(dicoRegion)):
#    for e in range(len(RegionsKLEMStoIMACLIMindustries[c])):
#        print(RegionsKLEMStoIMACLIMindustries[c][e]

#----------------------------------------------------------

# create an empty matrix with as industries the target IMACLIM industries

Variables=[]

for e in range(len(VariableIndex)):
    Variables.append(VariableIndex[e][0])
Variables.append('value')

IOTableIndustries=[]

IOTableIndustries.append(Variables)

print("creating empty datamatrix to aggregate industries")
IOTableIndustries.extend(createEmptyMatrix(nY*nC*nVars*nProd*nIndIMACLIM,len(Variables)))

#----------------------------------------------------------

#create a numeric version of KLEMStoIMACLIMindustries with indices of the KLEMS sectors in the VariableIndex

KLEMStoIMAIndices=[]

for i in range(len(IndustriesIMACLIM)): #get indices of the KLEMS industries in the VariableIndex
    emptyrow=[]
    #print(KLEMStoIMACLIMindustries[i*2])
    for e in range(1,len(KLEMStoIMACLIMindustries[i*2])):
        emptyrow.append(int(VariableIndex[4].index(KLEMStoIMACLIMindustries[i*2][e])-1))
    KLEMStoIMAIndices.append(list(emptyrow))

#----------------------------------------------------------

CountryRegionIndices=[None]*nC

for e in range(len(Countries)):
    r=0
    while r < len(dicoRegion):
        if Countries[e] in dicoRegion[r]:
            CountryRegionIndices[e]=r
            #print('CountryRegionIndices ', CountryRegionIndices
            break
        else:
            r=r+1


#----------------------------------------------------------

#filling the first 5 columns of the table is same as before. to fill the last column... Agregation rules are given by RegionsKLEMStoIMACLIMindustries
#Auxiliaryrow=[]

print("completing empty table with values, aggregated over industries")
for i in range(nY):
#for i in range(1):
    for e in range(nC*nVars*nProd*nIndIMACLIM):
        IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+e+1][0]=Years[i]

    for j in range(nC): #add Country string values
        for k in range(nVars*nProd*nIndIMACLIM):
            IOTableIndustries[i*nC*nVars*nProd*nIndIMACLIM+(j*nVars*nProd*nIndIMACLIM+k+1)][1]=Countries[j]

        for l in range(nVars): #add Var string values
            for m in range(nProd*nIndIMACLIM):

                IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+(j*nVars*nProd*nIndIMACLIM)+((l*nProd*nIndIMACLIM)+m+1)][2]=Vars[l]

            for n in range(nProd): #add Product string values
                for o in range(nIndIMACLIM):

                    IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+(j*nVars*nProd*nIndIMACLIM)+(l*nProd*nIndIMACLIM)+((n*nIndIMACLIM)+o+1)][3]=Products[n]

                    IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+(j*nVars*nProd*nIndIMACLIM)+(l*nProd*nIndIMACLIM)+(n*nIndIMACLIM)+o+1][4]=IndustriesIMACLIM[o] #add Industry string values
                    Auxiliaryrow=[]
                    for p in KLEMStoIMAIndices[o]: #add Industry values
                        Auxiliaryrow.append(KLEMSData[(i*nC*nVars*nProd*nIndKLEMS)+(j*nVars*nProd*nIndKLEMS)+(l*nProd*nIndKLEMS)+(n*nIndKLEMS)+p+1][5])
                    if 'NA' in Auxiliaryrow:
                        IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+(j*nVars*nProd*nIndIMACLIM)+(l*nProd*nIndIMACLIM)+(n*nIndIMACLIM)+o+1][5]='NA'
                        Auxiliaryrow=[]
                    else:
                        for q in range(len(Auxiliaryrow)):
                            Auxiliaryrow[q]=Auxiliaryrow[q] * RegionsKLEMStoIMACLIMindustries[CountryRegionIndices[j]][1+(2*o)+1][q+1] 

                        IOTableIndustries[(i*nC*nVars*nProd*nIndIMACLIM)+(j*nVars*nProd*nIndIMACLIM)+(l*nProd*nIndIMACLIM)+(n*nIndIMACLIM)+o+1][5]=sum(Auxiliaryrow)
                        Auxiliaryrow=[]

#----------------------------------------------------------


IOTable=[]

Variables_IO=Variables

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
                   # print(IOTable[(i*nC*nVars*nProdIMACLIM*nIndIMACLIM)+(j*nVars*nProdIMACLIM*nIndIMACLIM)+(l*nProdIMACLIM*nIndIMACLIM)+(n*nIndIMACLIM)+o+1])



#----------------------------------------------------------
# Compute price indices Ip (as a weigheted average)
#----------------------------------------------------------
for i in range(nY): # years
    print(i)
    for j in range(nC): # Country 
        l_p = Vars.index('Ip')
        l_q = Vars.index('I')
        #for l in range(nVars): # Var values
        for n in range(nProdIMACLIM): #add Product_IMACLIM values
            for o in range(nIndIMACLIM):
                #print(KLEMStoIMAIndices_products[n], KLEMStoIMAIndices[o])
                indices_temp = np.array([ (ii*nIndKLEMS + jj) for ii in KLEMStoIMAIndices_products[n] for jj in KLEMStoIMAIndices[o]])
                #print('indices', indices_temp)
                if indices_temp != []:
                     prices_temp = []
                     quantity_temp = []
                     for elt in indices_temp:
                         value_p = KLEMSData[(i*nC*nVars*nProd*nIndKLEMS)+(j*nVars*nProd*nIndKLEMS)+(l_p*nProd*nIndKLEMS)+elt+1][5]
                         value_q = KLEMSData[(i*nC*nVars*nProd*nIndKLEMS)+(j*nVars*nProd*nIndKLEMS)+(l_q*nProd*nIndKLEMS)+elt+1][5]
                         if value_p == 'NA':
                             value_p = 0
                         if value_q == 'NA':
                             value_q = 0
                         prices_temp.append( value_p)
                         quantity_temp.append( value_q)
                     prices_temp = np.array( prices_temp)
                     quantity_temp = np.array( quantity_temp)
                     #print(prices_temp)
                     #print(quantity_temp)
                     if sum(quantity_temp)!=0:
                         value_temp = sum( prices_temp*quantity_temp) / sum(quantity_temp)
                     else:
                         value_temp = 0
                     value_temp = sum( prices_temp*quantity_temp) / sum(quantity_temp)
                else:
                    value_temp = 0
                    IOTable[(i*nC*nVars*nProdIMACLIM*nIndIMACLIM)+(j*nVars*nProdIMACLIM*nIndIMACLIM)+(l_p*nProdIMACLIM*nIndIMACLIM)+(n*nIndIMACLIM)+o+1][5]= value_temp
                    #print((i*nC*nVars*nProdIMACLIM*nIndIMACLIM)+(j*nVars*nProdIMACLIM*nIndIMACLIM)+(l_p*nProdIMACLIM*nIndIMACLIM)+(n*nIndIMACLIM)+o+1, nY, nC, nProdIMACLIM, nIndIMACLIM, nVars, i, (i*nC*nVars*nProdIMACLIM*nIndIMACLIM))
#----------------------------------------------------------

if not os.path.exists(dirOut):
    os.makedirs(dirOut)

with open(dirOut+'IOTablewithValues_countries-'+yearShares+'.csv', 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    writer.writerows(IOTable)

#----------------------------------------------------------
# seperate procedure : Once newMatrix created, create the 2x2 IO matrices per var, country and year.
