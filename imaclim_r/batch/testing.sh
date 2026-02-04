#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

# META-IMACLIM-R
# Permet d'exécuter plusieurs fois imaclim-r en fonction dess *combis* pertinentes dans le cadre d'une *ETUDE*

if [ $HOSTNAME = "poseidon.centre-cired.fr" ] || [ $HOSTNAME = "belenus.centre-cired.fr" ]
then
    scilabExe='/home/bibas/bin/scilab-5.4.1/bin/scilab'
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
for i in 810
do
    for gamma_charge  in `seq 0.1 0.2 2.`
    do
        for mshBiomGrowth in `seq 0.05 0.1 0.2`
        do
            for taxMin        in `seq 0.6 0.05 0.95`
            do
                for taxMax        in `seq 0.1 0.05 0.6`
                do
                    name="$i-$gamma_charge-$mshBiomGrowth-$taxMin-$taxMax"
                    echo "$name"
                    echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');" >  run.cmdFile$name.sce
                    echo "externallyChangedVar.gamma_charge_gaz  = $gamma_charge;"                   >> run.cmdFile$name.sce
                    echo "externallyChangedVar.gamma_charge_coal = $gamma_charge;"                   >> run.cmdFile$name.sce
                    echo "externallyChangedVar.elecBiomassInitial.maxGrowthMSH = $mshBiomGrowth;"    >> run.cmdFile$name.sce
                    echo "externallyChangedVar.cff_taxmin = $taxMin;"                                >> run.cmdFile$name.sce
                    echo "externallyChangedVar.cff_taxmax = $taxMax;"                                >> run.cmdFile$name.sce
                    echo "exec('imaclimr.sce');exit;"                                                >> run.cmdFile$name.sce
                    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$name.sce > /dev/null 2> run.batch$name.err < /dev/null" > run.batchCmd$name
                    echo "echo 'The job $name was done in `pwd`' | /bin/mail -s 'Job $name done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr" >> run.batchCmd$name
                    at -q b -m now -f "run.batchCmd$name"
                done
            done
        done
    done
done
