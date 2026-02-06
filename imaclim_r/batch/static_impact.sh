# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Florian Leblanc, Yann Gaucher
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

#bin/bash
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
for i in 11 110
    do
    for timehor in 10 15 20 30 40 55 70 85
        do
        for ctr in 0
            do
            for sec in 0
                do 
                for dam in 1
                    do
                    echo "combi=$i;ind_static_choc=%t;nbMKT_NDC=9;impact_magnitude=$dam;impacted_sector=$sec;ETUDE='base';ind_country_choc=$ctr;suffix2combiName='$timehor-$ctr-$sec-$dam';extraction_impacts = %t;TimeHorizon=$timehor;damages_duration=$timehor;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFile$i-$timehor-$ctr-$sec-$dam.sce
                    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$i-$timehor-$ctr-$sec-$dam.sce > /dev/null 2> run.batch$i-$timehor-$ctr-$sec-$dam.err < /dev/null"            > run.batchCmd$i-$timehor-$ctr-$sec-$dam
                    echo "echo 'The job $i-$timehor-$ctr-$sec-$dam was done in `pwd`' | /bin/mail -s 'Job $i-$timehor-$ctr-$sec-$dam done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' yann.$USER@enpc.fr"                                                                                                                              >> run.batchCmd$i-$timehor-$ctr-$sec-$dam
                    sh run.batchCmd$i-$timehor-$ctr-$sec-$dam &
                    done
                done
            done
        done
    done
