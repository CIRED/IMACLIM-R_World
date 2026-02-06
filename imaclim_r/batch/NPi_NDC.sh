#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Thibault Briera, Ruben Bibas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

# META-IMACLIM-R
# Permet d'exécuter plusieurs fois imaclim-r en fonction dess *combis* pertinentes dans le cadre d'une *ETUDE*

if [ $HOSTNAME = "poseidon.centre-cired.fr" ] || [ $HOSTNAME = "belenus.centre-cired.fr" ]
then
    scilabExe='/home/bibas/bin/scilab-5.4.1/bin/scilab'
elif [ $HOSTNAME = "inari.centre-cired.fr" ]
then
    scilabExe='/data/software/scilab-2024.1.0/bin/scilab'
else
    scilabExe='scilab'
fi


cd ../
case $1 in
    c|compile)
        cd source/
        $scilabExe -nb -nwni -e "exec ext12c.sce;quit(0);"
        cd ../
        ;;
    h|help)
        echo "Argument c or compile will recompile the static C function"
        ;;
esac

cd model
# lauch combi i and wait for the end of the execution before launching combi 9 and 19

#####################################
############# Warning : 
############# # market definition
#####################################

# number of markets: the # of markets must be consistent with nbMKT_NDC used in ETUDE.sce (forced by default if running with this shell script)
nbMKT=1

# #NoPolicy baseline
for i in 1
do
    echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    sh run.batchCmd$i &
done

wait #comment this if the baseline has already been run

##### For NPi/NDC, smooth_exo_tax_glob_1 & smooth_exo_tax_glob_2 can be modified to early tax smoothing if the model struggles to find a solution, especially after 2025
##### This happens when the emi constraint can't be met, because by default the carbon tax cannot increase by more than 80$/tCO2/yr


# Set the maximum number of parallel jobs
MAX_PARALLEL_JOBS=1

# Function to wait for jobs to finish if the maximum number of parallel jobs is reached
wait_for_jobs() {
    while (( $(jobs -r | wc -l) >= MAX_PARALLEL_JOBS )); do
        sleep 10
    done
}


# #NPi
for i in 9
do
    for run in 1 2 3 4 5 6 7 8 9 10
    do
        echo "autocalib_NPi=%t;nbMKT_NDC=$nbMKT;ind_npi_ndc=3;scen_calib='NPi';combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
        echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
        sh run.batchCmd$i &
        # Wait for jobs to finish if the maximum number of parallel jobs is reached
        wait_for_jobs
    done
done
wait 
# #NDC
for i in 9
do
    for run in 1 2 3 4 5 6 7 8 9 10
    do
        echo "autocalib_NDC=%t;nbMKT_NDC=$nbMKT;ind_npi_ndc=3;scen_calib='NDC';combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
        echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
        sh run.batchCmd$i &
        # Wait for jobs to finish if the maximum number of parallel jobs is reached
        wait_for_jobs
    done
done
