# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import sys, csv, os


dirInput = sys.argv[1]
dirIntermediate = sys.argv[2]
inFile = sys.argv[3]
#maybe country = sys.argv[4]
operation = "doing "+sys.argv[0]+" on "+dirInput+inFile+" into "+dirIntermediate +"VariableIndex.csv"
#maybe operation = "doing "+sys.argv[0]+" on "+dirInput+inFile+" into "+dirIntermediate +"VariableIndex-"+country+".csv" 

if len(sys.argv)>4:
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

#print('AllData[0]' ,AllData[0]

VariableIndex=[]

#------------------------------------------------------

firstYear=None
lastYear=AllData[0].index(AllData[0][len(AllData[0])-1])

e=0
while e < len(AllData):

    if "1" in AllData[0][e]:
        firstYear=AllData[0].index(AllData[0][e])
        break
    else:
        e=e+1 

#print('firstYear = ', firstYear, 'rd position = ', AllData[0][firstYear]
#print('lastYear = ', lastYear, 'th position = ', AllData[0][lastYear]

Years=[AllData[0][e] for e in range(firstYear,lastYear+1)]

#print('Years = ', Years

VariableIndex.append(["year"]+Years)

#------------------------------------------------------

Variables=["year"]
Variables.extend(AllData[0][:firstYear])
Variables.append("value")

#print('Variables = ', Variables

#---------------------



for varHere in AllData[0][:firstYear]:

    indexVarHere=AllData[0].index(varHere)
    colToRowAllData=[AllData[e][indexVarHere] for e in range(1,len(AllData[1:]))]
    #print('colToRowAllData', varHere, set(colToRowAllData)
    uniqueItems=list(set(colToRowAllData))
    #print('uniqueItems', varHere, uniqueItems

    Auxiliary=["None"]*len(AllData)
    for valueVariable in uniqueItems:
        #print('index(valueVariable)', colToRowAllData.index(valueVariable)
        Auxiliary[colToRowAllData.index(valueVariable)]=valueVariable
    #print(Auxiliary
    while len(Auxiliary) > len(uniqueItems):
        Auxiliary.remove('None')
    #print('Auxiliary', varHere, Auxiliary
    #print("____________________________________________"

    VariableIndex.append([varHere]+Auxiliary) 


print('VariableIndex')
for e in range (len(VariableIndex)):
    print(VariableIndex[e])


#----------------------------------------------------------

if not os.path.exists(dirIntermediate):
    os.makedirs(dirIntermediate)

with open(dirIntermediate+"VariableIndex.csv", 'w') as output:
#maybe with open(dirIntermediate+"VariableIndex"+"-country+".csv", 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    writer.writerows(VariableIndex)










    
