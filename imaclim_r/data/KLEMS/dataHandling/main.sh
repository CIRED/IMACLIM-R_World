#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


. ./usr.sh
export usr
export dataServer 
export commonCode

lineSkip="\n_______________________\n\n"

echo -e "1. Get data"
sh getData-france.sh

echo -e $lineSkip
for countries in europe france
do
    echo -e $countries
    echo -e "2. Process data"
    sh processData-$countries.sh
    echo -e $lineSkip
done
