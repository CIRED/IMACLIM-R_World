# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import csv, os, sys


dirInput = sys.argv[1]
dirIntermediate = sys.argv[2]
dirOut = sys.argv[3]
dirIOTables = sys.argv[4]
IOyears = sys.argv[5]
#AllDataNarrowIO = sys.argv[5]

operation = "doing "+sys.argv[0]+" on "+ dirOut+'IOTablewithValues_countries.csv to '+ dirIOTables + ' for ' + IOyears 
if len(sys.argv)>6:
    print('---------------------------------------------')
    print('---------------------------------------------') 
    print("problem with "+ operation)
else:
    print('---------------------------------------------')
    print('---------------------------------------------')
    print(operation)


with open(dirOut+'IOTablewithValues_countries-'+IOyears+'.csv', 'r') as f: #Aggregated Capital input data in narrow format
    reader = csv.reader(f,delimiter='|')
    KLEMSData = list(reader)

with open(dirIntermediate+'VariableIndex.csv', 'r') as f: #KLEMS variable index, created previously
    reader = csv.reader(f,delimiter='|')
    VariableIndex = list(reader)

with open(dirInput+'KLEMStoIMACLIM_industries.csv', 'r') as f: #this file specifies how to aggregate the industries of KLEMS data to 12 sector IMACLIM format
    reader = csv.reader(f,delimiter='|')
    KLEMStoIMACLIM_Ind = list(reader)

#---------------------------------------------------------- file import ends here

#for e in range(len(VariableIndex)):
#    print(VariableIndex[e])

#----------------------------------------------------------

IndustriesIMACLIM=[]
for e in range(len(KLEMStoIMACLIM_Ind)):
    IndustriesIMACLIM.append(KLEMStoIMACLIM_Ind[e][0])


#----------------------------------------------------------

#VariableIndex.append(list(IndustriesIMACLIM))
#VariableIndex[len(VariableIndex)-1].insert(0,'industriesIMACLIM')

#for e in range(len(VariableIndex)):
#    print(VariableIndex[e])

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

#print(Years)
#print(Countries)

#----------------------------------------------------------
# create tables per year, per var, per country of the form 
#yr,country,var | Coal|Oil|...
#Coal|
#Oil|
#...

# Create empty table of the right size. 
# Loop : fill in values. write csv.

writeOut=[]
writeOut.append(list(IndustriesIMACLIM))
writeOut[0].insert(0,'')

def createEmptyMatrix(n,m):
    emptyAllData=[]
    emptyRow=[None]*(m)
    for e in range(n):
        emptyAllData.append(list(emptyRow))
    return emptyAllData

writeOut.extend(createEmptyMatrix(len(IndustriesIMACLIM),len(IndustriesIMACLIM)+1))

#print('writeOut')
#print(writeOut)
#print('IndustriesIMACLIM')
#print(IndustriesIMACLIM)

for e in range(len(IndustriesIMACLIM)):
    writeOut[e+1][0]=IndustriesIMACLIM[e]

#for e in range(len(writeOut)):
#    print(writeOut[e])

#----------------------------------------------------------

#print("KLEMSData")

#for e in range(5):
#    print(KLEMSData[e])

#----------------------------------------------------------

#print(VariableIndex)

if not os.path.exists(dirOut+dirIOTables):
    os.makedirs(dirOut+dirIOTables)

for i in range(Years.index(IOyears),Years.index(IOyears)+1):
#for i in range(1):
    
    for j in range(len(Countries)):
#    for j in range(1):

        for l in range(len(Vars)): #variables
        #for l in range(1): #variables

            writeOut[0][0]=Years[i]+'_'+Countries[j]+'_'+Vars[l]
            
            for n in range(nProdIMACLIM): 
                for o in range(nIndIMACLIM):

                    writeOut[n+1][o+1]= KLEMSData[(i*nC*nVars*nProdIMACLIM*nIndIMACLIM)+(j*nVars*nProdIMACLIM*nIndIMACLIM)+(l*nProdIMACLIM*nIndIMACLIM)+(n*nIndIMACLIM)+o+1][5]

                    with open(dirOut+dirIOTables+'/{0}.csv'.format(writeOut[0][0]), 'w') as output:
                        output.write('//Capital input data from KLEMS EU 2009 version. Use table format converted to symmetric IO format \n')
                        writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
                        writer.writerows(writeOut)

