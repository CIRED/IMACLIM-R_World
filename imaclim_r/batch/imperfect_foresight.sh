# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Thibault Briera
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

    ###################################################
########                                           #######
########        Climate policy uncertainty WP         #######
########                                           #######
    ####################################################    


#Resume of the scenario: 1440 NZ, 1441 NZ + ambition uncertainty, 1442 NZD, 1443 NZD + ambition uncertainty

year_nz=2060 # year of NZ. Assumed to be after 2050 as major emittors (China, India) have pledge to go carbon neutral by 2060 (China) or 2070 (India)
start_year=2022 #starting strong decarb policies
dur_smooth_tax=6 #smoothing tax until 2025: since the tax profile is much less agressive, smoothing is not required 
dur_smooth_tax_early=10
dur_seq_inv_elec=5
# Resume of biomass and CCS availability: 
#10GT CCS max > 15
#4GT CCS max > 8
#8GT CCS max > 12 (carbon sequestration - CCS)
#7GT CCS max > 10 (carbon sequestration - CCS)
# compare biomass shares from Figure 28 - NGFS - Climate Scenarios Technical Documentation

# additional benchmark : combi=14
for i in 14
do
    for max_CCS_injection in 7000
        do
        for horizon_CT in 50 1 
            do
            for nb_year_expect_LCC in 50
                do
                if [ $horizon_CT -lt $nb_year_expect_LCC ] || [ $horizon_CT = $nb_year_expect_LCC ]; then
                    runname="$i-$horizon_CT-$nb_year_expect_LCC"
                    echo "exo_max_CCS_injection=$max_CCS_injection/1000;ind_climpol_uncer=1;ind_short_term_hor=1;start_year_strong_policy=$start_year;dur_smooth_tax=$dur_smooth_tax;horizon_CT=$horizon_CT;nb_year_expect_LCC=$nb_year_expect_LCC;year_nz=$year_nz;ind_wait_n_see=0;ind_CCS=3;ind_seq_beccs_opt=2;ind_nz=1;ind_force_export=1;ind_biofuel=0;dur_seq_inv_elec=$dur_seq_inv_elec;nbMKT_NDC=9;nbMKT_NDC=9;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$runname.sce
                    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
                    #echo "echo '   The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
                    sh run.batchCmd$runname &
                    echo $runname
                    sleep 3
                fi
            done
        done
    done
done

# # # #     ###################################################
# # # # ########                                           #######
# # # # ########        Policy Clustered scenarios         #######
# # # # ########                                           #######
# # # #     ####################################################    

# Early Action 
for i in 1440
    do
    for tax2020 in 20
        do
        for taxbreak_1 in 80
            do 
            for taxbreak_2 in 800
                do
                for tax2100 in 1000
                    do
                    for max_CCS_injection in 15000 
                        do
                        for horizon_CT in 50 1
                            do
                            for nb_year_expect_LCC in 50 
                                do
                                if [ $horizon_CT -lt $nb_year_expect_LCC ] || [ $horizon_CT = $nb_year_expect_LCC ]; then
                                runname="$i-$horizon_CT-$nb_year_expect_LCC"
                                echo "exo_maxmshbiom=100/1000;exo_max_CCS_injection=$max_CCS_injection/1000;ind_climpol_uncer=1;ind_short_term_hor=1;start_year_strong_policy=$start_year;dur_smooth_tax=$dur_smooth_tax_early;tax2020=$tax2020;taxbreak_1=$taxbreak_1;taxbreak_2=$taxbreak_2;tax2100=$tax2100;horizon_CT=$horizon_CT;nb_year_expect_LCC=$nb_year_expect_LCC;year_nz=$year_nz;break_year_tax_1=2030;break_year_tax_2=2050;ind_wait_n_see=0;ind_seq_beccs_opt=2;ind_CCS=3;ind_nz=1;ind_force_export=1;ind_biofuel=0;nbMKT_NDC=9;nbMKT=9;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$runname.sce
                                echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
                                #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
                                sh run.batchCmd$runname &
                                echo $runname
                                sleep 3
                                fi
                            done
                        done
                    done
                done
            done
        done
    done
done
# wait 
# # Early Action - ambition uncertainty
for i in 1441
    do
    for tax2020 in 20
        do
        for taxbreak_1 in 80
            do 
            for taxbreak_2 in 800
                do
                for tax2100 in 1000
                    do
                    for max_CCS_injection in 15000 
                        do
                        for horizon_CT in 5
                            do
                            for nb_year_expect_LCC in 50 
                                do
                                if [ $horizon_CT -lt $nb_year_expect_LCC ] || [ $horizon_CT = $nb_year_expect_LCC ]; then
                                runname="$i-$horizon_CT-$nb_year_expect_LCC"
                                echo "exo_maxmshbiom=100/1000;exo_max_CCS_injection=$max_CCS_injection/1000;ind_climpol_uncer=1;ind_short_term_hor=1;start_year_strong_policy=$start_year;dur_smooth_tax=$dur_smooth_tax_early;tax2020=$tax2020;taxbreak_1=$taxbreak_1;taxbreak_2=$taxbreak_2;tax2100=$tax2100;horizon_CT=$horizon_CT;nb_year_expect_LCC=$nb_year_expect_LCC;year_nz=$year_nz;break_year_tax_1=2030;break_year_tax_2=2050;ind_wait_n_see=1;ind_seq_beccs_opt=2;ind_CCS=3;ind_nz=1;ind_force_export=1;nbMKT_NDC=9;nbMKT=9;ind_dec_proba_ndc=1;proba_ndc_init=80/100;ind_biofuel=0;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$runname.sce
                                echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
                                #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
                                sh run.batchCmd$runname &
                                echo $runname
                                sleep 3
                                fi
                            done
                        done
                    done
                done
            done
        done
    done
done

# # # # # # # #Delayed Action 
for i in 1442
    do
    for tax2019 in 40
        do
        for taxbreak_1 in 800 
            do 
            for tax2100 in 1000
                do
                for max_CCS_injection in  15000 
                    do
                    for horizon_CT in 50 1
                        do
                        for nb_year_expect_LCC in 50 
                            do
                            if [ $horizon_CT -lt $nb_year_expect_LCC ] || [ $horizon_CT = $nb_year_expect_LCC ]; then
                            runname="$i-$horizon_CT-$nb_year_expect_LCC"
                            echo "exo_maxmshbiom=100/1000;exo_max_CCS_injection=$max_CCS_injection/1000;ind_climpol_uncer=1;ind_short_term_hor=1;start_year_strong_policy=$start_year;dur_smooth_tax=$dur_smooth_tax;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;horizon_CT=$horizon_CT;nb_year_expect_LCC=$nb_year_expect_LCC;year_nz=$year_nz;break_year_tax_1=2050;ind_wait_n_see=0;ind_seq_beccs_opt=2;ind_CCS=3;ind_nz=1;ind_force_export=1;nbMKT_NDC=9;nbMKT=9;ind_biofuel=0;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$runname.sce
                            echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
                            #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
                            sh run.batchCmd$runname &
                            echo $runname
                            sleep 3
                            fi
                        done
                    done
                done
            done
        done
    done
done

# # # wait
# # # # Delayed Action + ambition uncertainty
for i in 1443
    do
    for tax2019 in 40
        do
        for taxbreak_1 in 800
            do 
            for tax2100 in 1000
                do
                for max_CCS_injection in  15000 
                    do
                    for horizon_CT in 5
                        do
                        for nb_year_expect_LCC in 50 
                            do
                            if [ $horizon_CT -lt $nb_year_expect_LCC ] || [ $horizon_CT = $nb_year_expect_LCC ]; then
                            runname="$i-$horizon_CT-$nb_year_expect_LCC"
                            echo "exo_maxmshbiom=100/1000;exo_max_CCS_injection=$max_CCS_injection/1000;ind_climpol_uncer=1;ind_short_term_hor=1;start_year_strong_policy=$start_year;dur_smooth_tax=$dur_smooth_tax;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;horizon_CT=$horizon_CT;nb_year_expect_LCC=$nb_year_expect_LCC;year_nz=$year_nz;break_year_tax_1=2050;ind_wait_n_see=1;ind_seq_beccs_opt=2;ind_CCS=3;ind_nz=1;ind_force_export=1;nbMKT_NDC=9;nbMKT=9;ind_dec_proba_ndc=1;proba_ndc_init=80/100;ind_biofuel=0;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$runname.sce
                            echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
                            #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
                            sh run.batchCmd$runname &
                            echo $runname
                            sleep 3
                            fi
                        done
                    done
                done
            done
        done
    done
done
