#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

pathToImg=data/results/klems/docImg
dirImg=../analysis
dirPlots=$dirImg/plots
dirDescript=$dirImg/description
dirCA=$dirImg/ca
usr=defosse


for dirHere in plotted_perCountry #plottedIndustries #plottedProducts-bar #plotted_I_K_VA 
do
scp -r  ./$dirPlots/$dirHere  $usr@poseidon.centre-cired.fr:/$pathToImg/
done


for dirHere in #summarizeYears #summarizeIndustries #summarizeData   
do
scp -r  ./$dirDescript/$dirHere  $usr@poseidon.centre-cired.fr:/$pathToImg/
done


for dirHere in  #reducedSystemProdInd #reducedSystem_Prod-Year
do
scp -r  ./$dirCA/$dirHere  $usr@poseidon.centre-cired.fr:/$pathToImg/
done 