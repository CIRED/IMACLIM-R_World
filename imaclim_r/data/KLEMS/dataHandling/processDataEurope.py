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

#AggDir=os.path.realpath('..')+'/aggregation'

dirIn  = sys.argv[1]
fileIn = sys.argv[2]
dirOut = sys.argv[3]
operation = "doing "+sys.argv[0]+" on file "+dirIn+fileIn+" into "+dirOut+fileIn


if len(sys.argv)>4:
    print('---------------------------------------------') 
    print('---------------------------------------------') 
    print("problem with "+ operation)
else:
    print('---------------------------------------------')
    print('---------------------------------------------') 
    print(operation)

#------------------------------------------------------- 

with open(dirIn+fileIn, 'r') as f:
    reader = csv.reader(f,delimiter='|')
    AllData = list(reader)

#------------------------------------------------------- 

#print('AllData[0]', AllData[0])

#------------------------------------------------------- 

lengthRows=[len(AllData[e]) for e in range(len(AllData))]

log1 = " - rowlengths take the following values: ", ', '.join(set([str(lengths) for lengths in lengthRows]))
#print(log1)

minR=min(lengthRows)
maxR=max(lengthRows)



infoMissingCol=[]
for e in range(len(AllData)):

    if len(AllData[e])==maxR-1:

        infoMissingCol.append(AllData[e][:2])

log2 = '\n - initially, for the following countries some rowlengths \n   are not consistent with rest of datafile: '
log3 = ', '.join(set([infoMissingCol[e][0] for e in range(len(infoMissingCol))]))

log4 = '\n - initially, for the following variables some rowlengths \n   are not consistent with rest of datafile: '
log5 = ', '.join(set([infoMissingCol[e][1] for e in range(len(infoMissingCol))]))

#print(set([infoMissingCol[e][1] for e in range(len(infoMissingCol))]))


short=maxR-1
#print('short', short)

#print('Initially minR = ',minR, 'maxR = ',maxR)
#print('maxR-1', maxR-1)
regionsNo2007=["JPN","POL","PRT","SVN"]

for e in range(len(AllData)):

    if AllData[e][0] in regionsNo2007:
        if lengthRows[e]==short:
            #print("lengthRows[e]", lengthRows[e])
        #if AllData[e][0] is not AllData[e-1][0]:
            #print(AllData[e][0])
            AllData[e].append("NA")


#--------------------------------------------- below check again:
lengthRows=[]

lengthRows=[len(AllData[e]) for e in range(len(AllData))]

minR=min(lengthRows)
maxR=max(lengthRows)


if minR==maxR:
    log6 = 'Yay and minR=maxR=', str(minR) 
    
else:
    log6 = 'After adding NAs: \n - minR = ',str(minR), ', maxR = ',str(maxR)
    


infoMissingCol=[]
for e in range(len(AllData)):

    if len(AllData[e])==maxR-1:

        infoMissingCol.append(AllData[e][:2])


log7 = '\n - following countries have rows of which length is not consistent: '+' ,'.join(set([infoMissingCol[e][0] for e in range(len(infoMissingCol))]))
log8 = '\n - following variables have rows of which length is not consistent: '+' ,'.join(set([infoMissingCol[e][1] for e in range(len(infoMissingCol))]))


#-------------------------------------------------------


if not os.path.exists(dirOut):
    os.makedirs(dirOut)

with open(dirOut+fileIn, 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    writer.writerows(AllData)

with open(dirOut+'processData-europe.log', 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    output.write(''.join(fileIn))
    output.write(''.join("\n\nThe script processDataEurope.py is hardwired to check and add NA's for the countries [JPN, POL, PRT, SVN] for 2007."))
    output.write(''.join('\n'))
    output.write(''.join('\n'))
    output.write(''.join("\nChecking homogeneity of row lengths and adding NA's for the reasons detailed in klems/dataHandling/main.txt\n\n"))
    output.write(''.join(log1))
 
    output.write(''.join(log2))
    output.write(''.join(log3))
    output.write(''.join(log4))
    output.write(''.join(log5))

    output.write(''.join('\n'))
    output.write(''.join('\n'))
    output.write(''.join(log6))
    output.write(''.join(log7))
    output.write(''.join(log8))
    #output.write(''.join('\n\nISIC4to3\n'))
    #writer.writerow(FirstColISIC4to3)
    #output.write(''.join('\nIndustriesISIC3\n'))
    #writer.writerow(IndustriesISIC3)

