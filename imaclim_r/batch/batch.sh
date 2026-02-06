# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Ruben Bibas
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
for i in 11 4001
do
    echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$i
    #echo "echo 'The job $i was done in `pwd`' | /bin/mail -s 'Job $i done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    sh run.batchCmd$i &
done
