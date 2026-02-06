# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Augustin Danneaux, Ruben Bibas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

#/nc@inari batchbin/bash
# META-IMACLIM-R
# Permet d'exécuter plusieurs fois imaclim-r en fonction dess *combis* pertinentes dans le cadre d'une *ETUDE*


#================================================================
# Final scenarios waysout

# run wth r32645 & path:

# svn update -r32645
#patch -p0 -i patch/patch_waysout_r32645.patch
#svn update -r32817 batch/waysout_central.sh
#================================================================


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



#===================================================================================================================================================================================================
#===================================================================================================================================================================================================
#                   Waysout Central scenarios 
#===================================================================================================================================================================================================
#===================================================================================================================================================================================================


# Current Policies
for i in  112
do
    nbMKT=1

    ind_coal_fin=2
    mshbio=20
    ind_labour=0
    ind_coal_decapacity=0
    
    runname="$i-$mshbio-$ind_labour"


    echo "record_vett_carbonbudget=%t;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.Central.NPI'"       > run.cmdFile$runname.sce
    echo "ETUDEOUTPUT='waysout';ind_coal_decapacity=$ind_coal_decapacity"   >> run.cmdFile$runname.sce
    echo "combi=$i;ind_npi_ndc_effort=1;isBatch = %t;covid_crises_shock=%f;nbMKT=$nbMKT;nbMKT_NDC=$nbMKT;ind_coal_fin=$ind_coal_fin;ind_labour=$ind_labour;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
    #sh run.batchCmd$runname &
    echo $runname

done
#================================================================

# NDC Long term strategy
for i in  172
do
    for ind_CCS in 0 2
    do
        ind_coal_fin=2
        mshbio=20
        ind_labour=0
        ind_coal_decapacity=0
        
        runname="$i-$mshbio-$ind_labour-$ind_CCS"


        echo "record_vett_carbonbudget=%t;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.Central.NDC.indCCS.$ind_CCS'"     > run.cmdFile$runname.sce
        echo "ETUDEOUTPUT='waysout';ind_coal_decapacity=$ind_coal_decapacity;ind_CCS=$ind_CCS;"   >> run.cmdFile$runname.sce

        echo "combi=$i;isBatch = %t;covid_crises_shock=%f;nbMKT=3;ind_coal_fin=$ind_coal_fin;ind_labour=$ind_labour;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
        echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
        #sh run.batchCmd$runname &
        echo $runname
    done
done
#================================================================


# 1.5°C
for i in  4202
do
  for ind_CCS in 0 2
  do
    for tax2019 in 10
    do
        for taxbreak_1 in 900
        do
        for tax2100 in 3000
        do
    
        
        ind_coal_fin=2
        mshbio=50
        

        ind_labour=0
        exo_max_CCS_injection=55
        ind_coal_decapacity=0

        runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio-$ind_labour-$ind_CCS"
        echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.Central.1_5_indccs.$ind_CCS.$taxbreak_1'"     > run.cmdFile$runname.sce
        echo "ETUDEOUTPUT='waysout';ind_coal_decapacity=$ind_coal_decapacity;ind_CCS=$ind_CCS;"   >> run.cmdFile$runname.sce

        echo "combi=$i;exo_max_CCS_injection=$exo_max_CCS_injection/10;covid_crises_shock=%f;ind_coal_fin=$ind_coal_fin;ind_labour=$ind_labour;ind_wait_n_see=0;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
        echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
        #sh run.batchCmd$runname &
        echo $runname
        done
        done
    done
  done
done
#================================================================


) > all_run_names.txt
xargs -n1 -P32 "./run_scenario.sh" < all_run_names.txt

