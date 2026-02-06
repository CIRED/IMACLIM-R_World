# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Florian Leblanc, Yann Gaucher
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


for i in 1000 3000 #2000 
    do
    echo "combi=$i;ETUDE='indirectImpacts'; nbMKT_NDC=9;suffix2combiName='test';isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFilestep$i-test.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFilestep$i-test.sce > /dev/null 2> run.batch$i-test.err < /dev/null"            > run.batchCmdstep$i-test
    echo "echo 'The job $i-test was done in `pwd`' | /bin/mail -s 'Job $i-test done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' yann.$USER@enpc.fr"                                                                                                                              >> run.batchCmdstep$i-test
    sh run.batchCmdstep$i-test &
done

