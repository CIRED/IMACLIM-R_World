# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Florian Leblanc, Yann Gaucher
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

#/nc@inari batchbin/bash
# META-IMACLIM-R
# Permet d'exécuter plusieurs fois imaclim-r en fonction dess *combis* pertinentes dans le cadre d'une *ETUDE*
# à lancer avec "nohup sh *nom du script* &"
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


(


for i in 1400 1402 1410 1412 3400 3402 3410 3412 1000 1002 1610 1612 1630 1632 2000 2002 2610 2612 2630 2632 3000 3002 3610 3612 3630 3632 1100 1102 1110 1112 1200 1202 1210 1212 1300 1302 1310 1312  1500 1502 1510 1512 3100 3102 3110 3112 3200 3202 3210 3212 3300 3302 3310 3312 3400 3402 3410 3412 3500 3502 3510 3512
    do 
    runname="$i-full"
    echo "combi=$i;ETUDE='indirectImpacts'; nbMKT_NDC=9;suffix2combiName='full';isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdfile$runname.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdfile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
    echo $runname 
done

) > all_run_names.txt
xargs -n1 -P32 "./run_scenario.sh" < all_run_names.txt

