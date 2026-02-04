#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

pathToImg=data/results/klems/docImg/imgWD
dirImg=/imgWD

usr=bibas


for dirHere in reducedSystem_Ind-Prod-Year-share-12x8 plotted_perCountry plotted_bars_structure method
do
scp -r  ./$dirImg/$dirHere  $usr@poseidon.centre-cired.fr:/$pathToImg/
done


