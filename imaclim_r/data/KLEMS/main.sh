#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


CWD=`pwd`

echo "* Handle data"
cd dataHandling
. ./main.sh
cd $CWD

echo "* Aggregate data"
cd aggregation
. ./aggregation-country.sh
rm -r input intermediate
cd $CWD

rm -r dataHandling/transformed/


echo "* Analyze data"
cd analysis
#R --vanilla <main.R >test.out
cd $CWD
