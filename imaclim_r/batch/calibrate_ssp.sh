# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Florian Leblanc
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

echo '#! /bin/sh
sh run.batchCmd$1
' > run_scenario.sh
chmod a+x run_scenario.sh

#ssp1 100 102
#ssp2 84

(
for i in 1
do
    for ssp in 1
    do 
        for cor_prod_lead in `seq 1006 1 1014` #100
        do

            runname="$i-$ssp-$cor_prod_lead"
	    echo "cor_prod_leadder_calib=$cor_prod_lead/1000;ind_ssp=$ssp;suffix2combiName='.ssp${ssp}.corLead${cor_prod_lead}';"  > run.cmdFile$runname.sce
	    echo "ETUDEOUTPUT='diagnostic';combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
	    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
            echo $runname
        done
    done
done

for i in 1
do
    for ssp in 2
    do 
        for cor_prod_lead in `seq 841 1 849` #100
        do

            runname="$i-$ssp-$cor_prod_lead"
            echo "cor_prod_leadder_calib=$cor_prod_lead/1000;ind_ssp=$ssp;suffix2combiName='.ssp${ssp}.corLead${cor_prod_lead}';"  > run.cmdFile$runname.sce
            echo "ETUDEOUTPUT='diagnostic';combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
            echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
            echo $runname
        done
    done
done

for i in 1
do
    for ssp in 3
    do 
        for cor_prod_lead in `seq 1 1 10` #100
        do

            runname="$i-$ssp-$cor_prod_lead"
            echo "cor_prod_leadder_calib=$cor_prod_lead/100;ind_ssp=$ssp;suffix2combiName='.ssp${ssp}.corLead${cor_prod_lead}';"  > run.cmdFile$runname.sce
            echo "ETUDEOUTPUT='diagnostic';combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
            echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
            echo $runname
        done
    done
done

) > all_run_names.txt
xargs -n1 -P32 "./run_scenario.sh" < all_run_names.txt

