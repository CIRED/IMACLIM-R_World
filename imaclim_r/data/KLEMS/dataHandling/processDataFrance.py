# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import csv
import sys, os, copy
import subprocess

def createEmptyMatrix(n,m):
    emptyData=[]
    emptyRow=[None]*(m)
    for e in range(n):
        emptyData.append(list(emptyRow))
    return emptyData

AggDir=os.path.realpath('..')+'/aggregation'
#AggDir=os.environ['AggFolder']

dirIn  = sys.argv[1]
country = sys.argv[2]
outFile = sys.argv[3]
operation = "doing "+sys.argv[0]+" on all files in "+dirIn+" for "+country+" into aggregation/input/"+country+"/"+outFile


if len(sys.argv)>4:
    print('---------------------------------------------')
    print('---------------------------------------------') 
    print("problem with "+ operation)
else:
    print('---------------------------------------------')
    print('---------------------------------------------')
    print(operation)

#with open(dirIn+f, 'r') as fo:
#    reader = csv.reader(fo,delimiter=',')
#    AllData = list(reader)



with open(AggDir+'/input/VariableIndex.csv', 'r') as f:
    reader = csv.reader(f,delimiter='|')
    VariableIndex = list(reader)
Years=VariableIndex[0][1:]
Vars=VariableIndex[2][1:]
Products=VariableIndex[3][1:]
IndustriesISIC3=VariableIndex[4][1:]
print('---------------------------------------------')
print('---------------------------------------------')

numberofVars=len(Vars) # number of Variables
numberofProducts=len(Products) # number of Products
nVars=numberofVars
nProd=numberofProducts

IndustriesISIC4=[]
ProductsFrance=['Products'+country]

fileExtension = '.csv'
Country='FRA'

AllDataISIC4=[]
nDataISIC4=0

#------------------------------------------------------- get structure of filenames and list available data 

filenames=[]
for file in os.listdir(dirIn):
    if file.endswith('{0}'.format(fileExtension)):
        filenames.append(file)
filenamesReversed = [file[::-1] for file in filenames]

commonprefix = os.path.commonprefix(filenames)
commonsuffix = os.path.commonprefix(filenamesReversed)[::-1]

log1='commonsuffix: '+ commonsuffix, '+ commonprefix: '+ commonprefix + '\n'
#print(log1


#check for missing data, variables, product-levels.

CoveredData=[file.strip(commonprefix) for file in filenames]
CoveredData=[file.strip(commonsuffix) for file in CoveredData]
#CoveredData=[file.split('_') for file in CoveredData]

missingData=[]

#------------------------------------------------------- construct list of wanted filenames, on the basis of variableIndex (vars and products) and suffix and prefix.

TestDataConsistency=[]

filestoImport=[]
for var in VariableIndex[2][1:len(VariableIndex[2])]:
    Auxiliary=[]
    Auxiliary=[commonprefix + var + '_' + prod + commonsuffix for prod in VariableIndex[3][1:]]
    filestoImport.extend(Auxiliary)


for file in filestoImport[:1]: # get list of industry-levels 
    with open(dirIn+'/{0}'.format(file), 'r') as f:
        reader=csv.reader(f,delimiter='|')
        Data = list(reader)
        for row in range(1,len(Data)):
            IndustriesISIC4.append(Data[row][1])
        AllDataISIC4.append(Data[0]) # attach header to AllData

AllDataISIC4[0].insert(0,'country')
AllDataISIC4[0][1] = 'var_product'
AllDataISIC4[0][2] = 'industryISIC4'

#print('***************\n*******\nIndustriesISIC4', IndustriesISIC4)

numberofIndustriesISIC4=len(IndustriesISIC4)
nIndustriesISIC4=numberofIndustriesISIC4

with open('ISIC4to3/IndustriesISIC4.csv', 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    writer.writerow(IndustriesISIC4[1:])

#---------------------------------------------

nRows=0
for file in filestoImport: 
    fileVar=file.strip(commonprefix)
    fileVar=fileVar.strip(commonsuffix)
    #print('opening file', dirIn+'/{0}'.format(file))
    try:
        with open(dirIn+'/{0}'.format(file), 'r') as f:
            reader=csv.reader(f,delimiter='|')
            Data = list(reader)
            nDataISIC4 = nDataISIC4+1
            nRows=len(Data)
            TestDataConsistency.append([fileVar,nRows])
            for row in range(nRows):
                Data[row].insert(0,Country)
                Data[row][1] = fileVar
                #Data[row].remove('')
                if Data[row][-1]=='':
                    Data[row][-1]='NA'
            AllDataISIC4.extend(Data[1:])
    except:
        missingData.append(fileVar)
        AuxiliaryMatrix = createEmptyMatrix(nRows,len(Data[0]))
        #zip(*AuxiliaryMatrix)[1]=[fileVar]*nRows
        for row in range(nRows):
            AuxiliaryMatrix[row][0] = Country
            AuxiliaryMatrix[row][1] = fileVar
            AuxiliaryMatrix[row][2] = IndustriesISIC4[row-1]
            AuxiliaryMatrix[row][3:] = ['NA']*(len(Data[0])-3)
        #print(fileVar ,'AuxiliaryMatrix[:][1]', AuxiliaryMatrix[1])
            #print('AuxiliaryMatrix', len(AuxiliaryMatrix))
        AllDataISIC4.extend(AuxiliaryMatrix[1:])


LengthsData=[TestDataConsistency[row][1] for row in range(nDataISIC4)]
 
Max = max(LengthsData)
Min = min(LengthsData)
if Max == Min:
    log3='\nAll imported files have the same number of rows, Yay.'
    #print('Length of all imported files :', TestDataConsistency, '\nAll imported files have the same number of rows, Yay.')
else:
    log3='\n! Not all imported files have the same number of rows, check!'+'\nLength of all imported files :', TestDataConsistency

#print('--------------------------------')
#print(len(AllDataISIC4))
#print('numberofROws', nRows)
#print('Number of csvs', nDataISIC4)
#print('Number of filenames', len(filenames))

if not os.path.exists('transformed/'+country+'/merged'):
    os.makedirs('transformed/'+country+'/merged')

with open('transformed/'+country+'/merged/DataFranceISIC4_8prod.csv', 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    writer.writerows(AllDataISIC4)

# Next: convert to ISIC3 and get all aggregated product-levels

#---------------------------------------
log5 = '\n\nmissingData:\n'
print(log5, missingData)
print('Check whether missingData consists of missing aggregated levels or more disrupting')

# The missingData are missing aggregated product levels and can be added by summing.
# Products aggregation rules

with open(AggDir+'/input/Products.csv', 'r') as f:
    reader = csv.reader(f,delimiter='|')
    ProductLevels = list(reader)

#for every variable in missingData, do for every missing product level: locate where in AllDataISIC4, fill in values in line for every year and industry-level, with aggregation rule from Products.csv

missingDataVar=[]


for v in Vars:

    if v in [row.split('_')[0] for row in missingData]:
        missingDataVar.append([v])
        for p in VariableIndex[3][1:]:
            vp = v + '_' + p
            if vp in missingData:
                missingDataVar[-1].append(p)


for v in range(len(missingDataVar)):
    
    missingProdLevelforVar = [VariableIndex[3][1:].index(missingProdLevel) for missingProdLevel in missingDataVar[v][1:]]
 
    for p in missingDataVar[v][1:]: # p takes values IT, CT, etc. ICT NonICT GFCF
        ProductLevelIndex = [ProductLevels[e][0] for e in range(len(ProductLevels))].index(p)
        print('p =', p, 'ProductLevelIndex', ProductLevelIndex)

        iAuxiliaryProducts=[VariableIndex[3][1:].index(prod) for prod in ProductLevels[ProductLevelIndex][1:]] 
        print('iAuxiliaryProducts', iAuxiliaryProducts)
        for i in range(len(IndustriesISIC4[1:])):

            for y in range(len(AllDataISIC4[0][3:])):

                ElstoSum=[]

                for r in iAuxiliaryProducts:
                    #AuxiliaryRow = AllDataISIC4[1+v*nProd*nIndustriesISIC4+r*nIndustriesISIC4 +i][3:-1]
                
                    ElstoSum.append(AllDataISIC4[1+v*nProd*nIndustriesISIC4+r*nIndustriesISIC4+i][y+3]) #test if there is 'NA' in the RowstoSum, in that case do nothing 'cause already NA's
                print('ElstoSum', ElstoSum)
                if 'NA' in ElstoSum:
                    AllDataISIC4[1+v*nProd*nIndustriesISIC4+Products.index(p)*nIndustriesISIC4 +i][y+3]= 'NA'
                    ElstoSum=[]
                else:
                    ElstoSum=[float(Element) for Element in ElstoSum]
         
                    AllDataISIC4[1+v*nProd*nIndustriesISIC4+Products.index(p)*nIndustriesISIC4 +i][y+3]=sum(ElstoSum)
                    ElstoSum=[]
          

#--------------------------------------------------
if not os.path.exists('transformed/'+country+'/merged'):
    os.makedirs('transformed/'+country+'/merged')


with open('transformed/'+country+'/merged/DataFranceISIC4_11prod.csv', 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    writer.writerows(AllDataISIC4)

#--------------------------------------------------
# use sh to replace "_" by "|" and then import again.

os.system('sh processDataFranceSeparator.sh')

with open('transformed/'+country+'/merged/DataFranceISIC4_11prod.csv', 'r') as input:
    reader = csv.reader(input,delimiter='|')
    AllDataISIC4 = list(reader)


#---------------------------------------------------
#
# Next : convert from ISIC4 to ISIC3
# First, create emptyMatrix of correct size.

with open('ISIC4to3/input/ISIC4to3.csv', 'r') as input:
    reader = csv.reader(input,delimiter='|')
    ISIC4to3 = list(reader)

numberofIndustriesISIC3 = len(VariableIndex[4][1:])
#print('ISIC3', VariableIndex[4][1:], 'numberofIndustriesISIC3=', numberofIndustriesISIC3))
#print('ISIC4', IndustriesISIC4, 'numberofIndustriesISIC4=', len(IndustriesISIC4), 'nIndustriesISIC4=', nIndustriesISIC4))

numberofRows = numberofVars*numberofProducts*numberofIndustriesISIC3

AllDataISIC3=createEmptyMatrix(1+numberofRows,len(AllDataISIC4[0]))
AllDataISIC3[0]=AllDataISIC4[0]
AllDataISIC3[0][3]='industry'

#fill empty datamatrix with number of lines corresponding to ISIC3 industry-levels.

#-------------------------------------------------------
# verify the first column of ISIC4to3 corresponds to the list of IndustriesISICS3
FirstColISIC4to3=[ind3Row[0] for ind3Row in ISIC4to3[1:]]


if FirstColISIC4to3 == IndustriesISIC3:
    log6 = '******* \nISIC4to3.csv is well defined:', str(FirstColISIC4to3 == IndustriesISIC3), '\n*******' 
else:
    log6 ='******* \nISIC4to3.csv is well defined:', str(FirstColISIC4to3 == IndustriesISIC3),'\nWARNING: Input file ISIC4to3 is missing 1 or more industry-levels or the ISIC3 levels are not in the same order as they appear in intermediate/VariableIndex.csv.\n*******'
    print('FirstColISIC4to3',FirstColISIC4to3)
    print('IndustriesISIC3',IndustriesISIC3)

#---------------
# create version of ISICS4to3 with indices for the ISIC4 levels
ISIC4to3Indices=copy.deepcopy(ISIC4to3)

for ind3 in range(1,len(ISIC4to3Indices)):
    for ind4 in range(1,len(ISIC4to3Indices[ind3])):
        ISIC4to3Indices[ind3][ind4]=IndustriesISIC4.index(ISIC4to3Indices[ind3][ind4])


#-------------------------------------------------------

for v in range(len(Vars)):
 
    for p in range(len(Products)):

        for ind3 in range(len(IndustriesISIC3)):
            
            AllDataISIC3[1+v*nProd*numberofIndustriesISIC3+p*numberofIndustriesISIC3+ind3][:4]=[Country, Vars[v],Products[p],IndustriesISIC3[ind3]]
            
            if len(ISIC4to3[ind3+1])==2:
                ind4=ISIC4to3Indices[ind3+1][1]
                AllDataISIC3[1+v*nProd*numberofIndustriesISIC3+p*numberofIndustriesISIC3+ind3][4:]=AllDataISIC4[1+v*nProd*numberofIndustriesISIC4+p*numberofIndustriesISIC4+ind4][4:]
            else:
                ElstoSum=[]

                for y in range(len(AllDataISIC4[0][4:])):
                    
                    for ind4toSum in ISIC4to3Indices[1+ind3][1:]:
                    
                        ElstoSum.append(AllDataISIC4[1+v*nProd*nIndustriesISIC4+p*nIndustriesISIC4+ind4toSum][4+y])
                        

                    #AuxiliaryRow = AllDataISIC4[v*nProd*nIndustriesISIC4+p*nIndustriesISIC4+ind4][4:]
                 
                    if 'NA' in ElstoSum:
                        AllDataISIC3[1+v*nProd*numberofIndustriesISIC3+p*numberofIndustriesISIC3+ind3][4+y]='NA'
                        ElstoSum=[]
                    else:
                        ElstoSum=[float(Element) for Element in ElstoSum]
                        AllDataISIC3[1+v*nProd*numberofIndustriesISIC3+p*numberofIndustriesISIC3+ind3][4+y]=sum(ElstoSum)
                        ElstoSum=[]

#-------------------------------------------------------

if not os.path.exists(AggDir+'/input/'+country):
    os.makedirs(AggDir+'/input/'+country)

with open(AggDir+'/input/'+country+'/'+outFile, 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    writer.writerows(AllDataISIC3)

with open(AggDir+'/input/'+country+'/processData-france.log', 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    output.write(''.join(log1))
    output.write('\nList of imported files:\n')
    for e in range(len(filestoImport)):
        writer.writerow([filestoImport[e]])
    output.write('\nVerification of the length of the imported files:')
    output.write(''.join(log3))
    output.write(''.join(log5))
    for e in range(len(missingData)):
        writer.writerow([missingData[e]])
    output.write(''.join('\n'))
    output.write(''.join(log6))
    output.write(''.join('\n\nISIC4to3\n'))
    writer.writerow(FirstColISIC4to3)
    output.write(''.join('\nIndustriesISIC3\n'))
    writer.writerow(IndustriesISIC3)
    

