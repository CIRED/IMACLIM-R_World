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


for i in 110 11 310 113 213 313 #110 11 310 112 212 312
    do
    for nM in 9
        do
        for effort in 0
        do
            echo "combi=$i;ETUDE='base';nbMKT_NDC=$nM;ind_npi_ndc_effort=$effort;suffix2combiName='LabDam';extraction_impacts = %t;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFilestep$i-LabDam.sce
            echo "nohup nice $scilabExe -nb -nwni -f run.cmdFilestep$i-LabDam.sce > /dev/null 2> run.batch$i-LabDam.err < /dev/null"            > run.batchCmdstep$i-LabDam
            echo "echo 'The job $i-LabDam was done in `pwd`' | /bin/mail -s 'Job $i-LabDam done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' yann.$USER@enpc.fr"                                                                                                                              >> run.batchCmdstep$i-LabDam
            sh run.batchCmdstep$i-LabDam &
        done
    done
done


#for i in 110 11 310 112 212 312
#    do
#    for nM in 9
#        do
#        for effort in 0
#        do
#            echo "combi=$i;ETUDE='base';ind_large_capital_access=%t;impacted_sector=0;ramp=%f;nbMKT_NDC=$nM;ind_npi_ndc_effort=$effort;suffix2combiName='LabDam-FC';extraction_impacts = %t;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  > run.cmdFilestep$i-LabDam-FC.sce
#            echo "nohup nice $scilabExe -nb -nwni -f run.cmdFilestep$i-LabDam-FC.sce > /dev/null 2> run.batch$i-LabDam-FC.err < /dev/null"            > run.batchCmdstep$i-LabDam-FC
#            echo "echo 'The job $i-LabDam-FC was done in `pwd`' | /bin/mail -s 'Job $i-LabDam-FC done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' yann.$USER@enpc.fr"                                                                                                                              >> run.batchCmdstep$i-LabDam-FC
#            #sh run.batchCmdstep$i-LabDam-FC &
#        done
#    done
#done
