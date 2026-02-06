# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera, Ruben Bibas
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

# Global WACC MiP - 8 scenarios
# Submitted the 30 - 09 - 2022
# run with r31405

for i in 5002  #NDC
do
    echo "ind_global_wacc =0;ind_uniform_DR = %t;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    sh run.batchCmd$i &
done

for i in 5003  #NDC_WACC
do
    echo "ind_global_wacc =1;ind_uniform_DR = %f;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    sh run.batchCmd$i &
done
for i in 5004  #NDC_CONV
do
    echo "ind_global_wacc =2;ind_uniform_DR = %f;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    sh run.batchCmd$i &
done
for i in 5005  #NDC_LRN
do
    echo "ind_global_wacc =3;ind_uniform_DR = %f;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    sh run.batchCmd$i &
done


for i in 5012  #1.5D
do
    echo "tax2019=60;taxbreak_1=1500;tax2100=2300;exo_maxmshbiom=18/1000;ind_global_wacc =0;ind_uniform_DR = %t;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    sh run.batchCmd$i &
done

for i in 5013  #1.5D_WACC
do
    echo "tax2019=60;taxbreak_1=1375;tax2100=2200;exo_maxmshbiom=18/1000;ind_global_wacc =1;ind_uniform_DR = %f;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    sh run.batchCmd$i &
done
for i in 5014  #1.5D_CONV
do
    echo "tax2019=60;taxbreak_1=1200;tax2100=2000;exo_maxmshbiom=18/1000;ind_global_wacc =2;ind_uniform_DR = %f;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    sh run.batchCmd$i &
done
for i in 5015  #1.5D_LNR
do
    echo "tax2019=60;taxbreak_1=1200;tax2100=2050;exo_maxmshbiom=18/1000;ind_global_wacc =3;ind_uniform_DR = %f;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    sh run.batchCmd$i &
done



