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
inFile = sys.argv[3]
AllDataNarrow = sys.argv[4]
operation = "doing "+sys.argv[0]+" on "+dirInput+inFile+" into "+dirIntermediate+AllDataNarrow
if len(sys.argv)>5:
    print('---------------------------------------------') 
    print('---------------------------------------------') 
    print("problem with "+ operation)
else:
    print('---------------------------------------------')
    print('---------------------------------------------')
    print(operation)


with open(dirInput+inFile, 'r') as f:
    reader = csv.reader(f,delimiter='|')
    AllData = list(reader)

with open(dirIntermediate+'VariableIndex.csv', 'r') as f:
    reader = csv.reader(f,delimiter='|')
    VariableIndex = list(reader)

#---------------------------------------------------------- file import ends here

Variables=[]

for e in range(len(VariableIndex)):
    Variables.append(VariableIndex[e][0])
Variables.append('value')

#---------------------------------------------------------- 

def createEmptyMatrix(n,m):
    emptyAllData=[]
    emptyRow=[None]*(m)
    for e in range(n):
        emptyAllData.append(list(emptyRow))
    return emptyAllData


numberofRows=1
numberofVar=[]
for e in range(len(VariableIndex)):
    nAux = len(VariableIndex[e][1:])
    numberofVar.append(nAux)
    numberofRows = numberofRows * len(VariableIndex[e][1:])

#print('numberofVar', numberofVar)
#print('numberofRows', numberofRows)

print("creating empty datamatrix of the right size")
AllDataRearranged=[]
AllDataRearranged.append(Variables)
AllDataRearranged.extend(createEmptyMatrix(numberofRows,len(Variables))) # we now have an empty matrix with on row0 the variable names and the right amount of empty rows


#----------------------------------------------------------

print('--------------------')
if "year" in Variables:
    Years=VariableIndex[Variables.index("year")][1:len(VariableIndex[Variables.index("year")])]
    numberofYears=len(Years)
    #print('Years', Years)
    #print('numberofYears', numberofYears)

if "country" in Variables:
    Countries=VariableIndex[Variables.index("country")][1:len(VariableIndex[Variables.index("country")])]
    numberofCountries=len(Countries)
    #print('Countries', Countries)
    #print('numberofCountries', numberofCountries)

if "var" in Variables:
    Vars=VariableIndex[Variables.index("var")][1:len(VariableIndex[Variables.index("var")])]
    numberofVars=len(Vars)
    #print('Vars', Vars)
    #print('numberofVars', numberofVars)

if "product" in Variables:
    Products=VariableIndex[Variables.index("product")][1:len(VariableIndex[Variables.index("product")])]
    numberofProducts=len(Products)
    #print('Products', Products)
    #print('numberofProducts', numberofProducts)
else:
    numberofProducts=1

if ("industry" in Variables):
    Industries=VariableIndex[Variables.index("industry")][1:len(VariableIndex[Variables.index("industry")])]
    numberofIndustries=len(Industries)
    #print('Industries', Industries)
    #print('numberofIndustries', numberofIndustries)
else:
    if ("industryISIC4" in Variables):
        Industries=VariableIndex[Variables.index("industryISIC4")][1:len(VariableIndex[Variables.index("industryISIC4")])]
        numberofIndustries=len(Industries)
        #print('Industries', Industries)
        #print('numberofIndustries', numberofIndustries)


#print('--------------------') 

lengthEmptyTarget=((len(AllDataRearranged)-1)/len(VariableIndex[Variables.index("year")][1:len(VariableIndex[Variables.index("year")])]))
lengthOriginalData=len(AllData)-1
print('Check on inputData homogenity: lengthOriginalData = ', lengthOriginalData, 'and lengthEmptyTarget = ', lengthEmptyTarget) 

#----------------------------------------------------------

DataNarrowVarsnoValues=[]

print("filling in the values")
for i in range(numberofYears):
#for i in range(1):
    for e in range(numberofCountries*numberofVars*numberofProducts*numberofIndustries):
        AllDataRearranged[(i*numberofCountries*numberofVars*numberofProducts*numberofIndustries)+e+1][0]=Years[i]

    for j in range(numberofCountries): #add Country values
#    for j in range(1): #add Country values
        for k in range(numberofVars*numberofProducts*numberofIndustries):
            AllDataRearranged[i*numberofCountries*numberofVars*numberofProducts*numberofIndustries+(j*numberofVars*numberofProducts*numberofIndustries+k+1)][1]=Countries[j] #emplacement [1] a modifier


        for l in range(numberofVars): #add Var values
#        for l in range(1): #add Var values
            for m in range(numberofProducts*numberofIndustries):

                AllDataRearranged[(i*numberofCountries*numberofVars*numberofProducts*numberofIndustries)+(j*numberofVars*numberofProducts*numberofIndustries)+((l*numberofProducts*numberofIndustries)+m+1)][2]=Vars[l]

            if "product" in Variables:

                for n in range(numberofProducts): #add Product values
#                for n in range(2): #add Product values
                    for o in range(numberofIndustries):

                        AllDataRearranged[(i*numberofCountries*numberofVars*numberofProducts*numberofIndustries)+(j*numberofVars*numberofProducts*numberofIndustries)+(l*numberofProducts*numberofIndustries)+((n*numberofIndustries)+o+1)][3]=Products[n]

                        AllDataRearranged[(i*numberofCountries*numberofVars*numberofProducts*numberofIndustries)+(j*numberofVars*numberofProducts*numberofIndustries)+(l*numberofProducts*numberofIndustries)+(n*numberofIndustries)+o+1][4]=Industries[o]

                        AllDataRearranged[(i*numberofCountries*numberofVars*numberofProducts*numberofIndustries)+(j*numberofVars*numberofProducts*numberofIndustries)+(l*numberofProducts*numberofIndustries)+(n*numberofIndustries)+o+1][5]=AllData[(j*numberofVars*numberofProducts*numberofIndustries)+(l*numberofProducts*numberofIndustries)+(n*numberofIndustries)+o+1][i+4]
 
            else:
                n=0
                for o in range(numberofIndustries):

                    AllDataRearranged[(i*numberofCountries*numberofVars*numberofProducts*numberofIndustries)+(j*numberofVars*numberofProducts*numberofIndustries)+(l*numberofProducts*numberofIndustries)+(n*numberofIndustries)+o+1][3]=Industries[o]

                    AllDataRearranged[(i*numberofCountries*numberofVars*numberofProducts*numberofIndustries)+(j*numberofVars*numberofProducts*numberofIndustries)+(l*numberofProducts*numberofIndustries)+(n*numberofIndustries)+o+1][4] = AllData[(j*numberofVars*numberofProducts*numberofIndustries)+(l*numberofProducts*numberofIndustries)+(n*numberofIndustries)+o+1][i+3] 
                


#----------------------------------------------------------


with open(dirIntermediate+AllDataNarrow, 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    writer.writerows(AllDataRearranged)












    
