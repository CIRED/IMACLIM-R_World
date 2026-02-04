# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import copy
import csv, sys


dirInput = sys.argv[1]
dirIntermediate = sys.argv[2]
yearShares = sys.argv[3]
IOyears = sys.argv[3]

# assumption for missing year in gtap. for the year 1970, 2004 will be taken, which is a huge assumption
yearShares = str(min( [ max( int(yearShares), int(ii)) for ii in ['2004','2001','2007']]))

operation = "doing "+sys.argv[0]+ " based on " +dirInput+ "Capital-" +yearShares+'.csv' +" and Capshares.csv to " + dirIntermediate+ " RegionsCapShares.csv"  

print('---------------------------------------------')
print('---------------------------------------------')
print(operation)


with open(dirInput+'Capital-'+yearShares+'.csv', 'r') as f: #Aggregated Capital GTAP data
    reader = csv.reader(f,delimiter='|')
    Capital = list(reader)

with open(dirInput+'Capshares.csv', 'r') as f: #Specifies the KLEMS sectors to disaggregate to their corresponding IMACLIM/GTAP sectors, specified in Capital.csv
    reader = csv.reader(f,delimiter='|')
    CapShares = list(reader)

#------------------------------------------------------

# what output to produce ?

# Convert CapShares in the numerical equivalent, CapShares with the double amount of rows, one set of rows for vars, another for numbers.

# From CapShares, add lines with shares to KLEMStoIMACLIM_industries.

#------------------------------------------------------

def createEmptyMatrix(n,m):
    emptyAllData=[]
    emptyRow=[None]*(m)
    for e in range(n):
        emptyAllData.append(list(emptyRow))
    return emptyAllData

#print(float(Capital[1][Capital[0].index(CapSharesVar[0][1])])

Regions=[]

for e in range(1,len(Capital)):
    Regions.append(Capital[e][0])

RegionsCapShares=[None]*len(Regions)


for e in range(len(CapShares)):

    CapShares.insert(e*2+1,[None]*len(CapShares[e*2]))
    CapShares[e*2+1][0]=CapShares[e*2][0]

for e in range(len(RegionsCapShares)):
    RegionsCapShares[e]=copy.deepcopy(CapShares)


for e in range(len(Regions)):
    
    for g in range(int(len(CapShares)/2)): 
        Auxiliary=[]
        for f in range(1,len(CapShares[2*g+1])):
            Auxiliary.append(float(Capital[e+1][Capital[0].index(RegionsCapShares[e][2*g][f])]))
            RegionsCapShares[e][2*g+1][f]=float(Capital[e+1][Capital[0].index(RegionsCapShares[e][2*g][f])])

        RegionsCapShares[e][2*g+1][1:]=[RegionsCapShares[e][2*g+1][i]/sum(Auxiliary) for i in range(1,len(CapShares[2*g+1]))]


#insert RegionNames ?

for c in range(len(RegionsCapShares)):
    RegionsCapShares[c].insert(0,[None])
    RegionsCapShares[c][0][0]=Regions[c]

#---------------------------------------------------------------------------------

#print('-----------')

#for g in range(len(RegionsCapShares)):
#    for e in range(len(RegionsCapShares[g])):
#        print(RegionsCapShares[g][e]
#    print('------------'

#print(len(RegionsCapShares[0])

#---------------------------------------------------------------------------------
#RegionsCapShares is a 3-dimensional table. The first index runs over countries. 
#Per country, a 2-dimensional table specifies the shares according to which to disaggregate a KLEMS industrial sector to IMACLIM sectors. 
#The shares are based on capital stock data from GTAP. 
 
#The 3-dimensional table is written to csv as a 2-dimensional table.
 
with open(dirIntermediate+'RegionsCapShares-'+IOyears+'.csv', 'w') as output:
    writer = csv.writer(output, delimiter='|', quoting=csv.QUOTE_NONE)
    for c in range(len(RegionsCapShares)):
        writer.writerows(RegionsCapShares[c])
		
