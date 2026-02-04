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
    scilabExe='/data/software/scilab-5.4.1/bin/scilab'
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

# Run to generate T.B and J.L climfin paper outputs - Energy Policy revised version (very slighly different results after 2019, due to inconsistent update of the code while producing results)
# 1. checkout revision 31842
# 2. update the following files to r 32011: 
#model/calibration.nexus.wacc.sce
#model/calibration.nexus.climfin.sce 
#model/nexus.wacc.sce
#model/nexus.climfin.sce
#study_frames/default_parameters.sce
#study_frames/matrice_base.sce

# 3. Unzip the following archives : input_data-Imaclim2.0-r31996.zip THEN input_data-Imaclim2.0-r31840.zip
# 4. calibrate the share weights (run_calib_weights=%t)

for i in 1
#no carbon price
do
    echo "ind_climfin_inc=0;ind_in_markup_elec=%f;ind_new_calib_wacc=%t;ind_climfin=0;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    sh run.batchCmd$i &
done

#wait #comment if not needed

#Provide
for i in 1101
do
    echo "ind_climfin_inc=0;ind_in_markup_elec=%f;ind_new_calib_wacc=%t;ind_climfin=1;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    sh run.batchCmd$i &
done

#Catalyze
for i in 1102
do
    echo "ind_climfin_inc=0;ind_in_markup_elec=%f;ind_new_calib_wacc=%t;ind_climfin=2;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    sh run.batchCmd$i &
done

#Catalyze&Blend


for i in 1103
do
    echo "ind_climfin_inc=0;ind_in_markup_elec=%f;ind_new_calib_wacc=%t;ind_climfin=3;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    sh run.batchCmd$i &
done

wait #because we need the Catalyze&Blend WACC development to run the Converge scenario
#Converge

for i in 1104
do
    echo "ind_climfin_inc=0;ind_in_markup_elec=%f;ind_new_calib_wacc=%t;ind_climfin=4;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    sh run.batchCmd$i &
done