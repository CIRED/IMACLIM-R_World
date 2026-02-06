# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Thibault Briera, Ruben Bibas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

#/bin/bash
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
echo '#! /bin/sh
sh run.batchCmd$1
' > run_scenario.sh
chmod a+x run_scenario.sh


# Set the maximum number of parallel jobs
MAX_PARALLEL_JOBS=25

# Function to wait for jobs to finish if the maximum number of parallel jobs is reached
wait_for_jobs() {
    while (( $(jobs -r | wc -l) >= MAX_PARALLEL_JOBS )); do
        sleep 10
    done
}


    ###################################################
########                                           #######
######## Profile costs in the electricity sector:  #######
########           endogenous calibration          #######
########                                           #######
    ####################################################    

convg=1 #2015


for i in 12
do
    for WD_sh in 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120
    do
        for Solar_sh in 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120
        do
            for old_RLDC_design in 0 1
            do
                # Ensure variables are set and numeric
                WD_sh=${WD_sh:-0}
                Solar_Sh=${Solar_Sh:-0}
                old_RLDC_design=${old_RLDC_design:-0}

                if (( ($WD_sh + $Solar_Sh) < 121 )); then
                    runname="$i-$WD_sh-$Solar_sh-$old_RLDC_design"
                    echo "force_VRE_share=1;calib_profile_cost=1;ind_new_design_IC=1;ind_new_design_MSH=1;ind_max_growth_rate_elec=0;WD_sh_target_global=$WD_sh/100;Solar_sh_target_global=$Solar_sh/100;old_RLDC_design=$old_RLDC_design;convergence_hor_share_elec=$convg;exo_maxmshbiom=100/1000;ind_CCS=2;ind_seq_beccs_opt=2;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$runname.sce
                    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
                    #echo "echo '   The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
                    
                    # Wait for jobs to finish if the maximum number of parallel jobs is reached
                    wait_for_jobs

                    sh run.batchCmd$runname &
                    echo $runname
                    sleep 3
                fi
            done
        done
    done
done
