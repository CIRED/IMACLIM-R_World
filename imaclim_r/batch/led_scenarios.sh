#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

# META-IMACLIM-R
# Permet d'exécuter plusieurs fois imaclim-r en fonction dess *combis* pertinentes dans le cadre d'une *ETUDE*

# run wth r32366 & path:

# svn update -r32366
#patch -p0 -i patch/patch_scenarioLED_r32366.patch
#svn update batch/led_scenarios.sh model/extraction.specific.led.sce

if [ $HOSTNAME = "poseidon.centre-cired.fr" ] || [ $HOSTNAME = "belenus.centre-cired.fr" ]
then
    scilabExe='/home/bibas/bin/scilab-5.4.1/bin/scilab'
elif [ $HOSTNAME = "inari.centre-cired.fr" ]
then
    scilabExe='/data/software/scilab-2024.1.0/bin/scilab'
else
    scilabExe='scilab'
fi

# Path to the CSV file
cur_path=$(pwd)
csv_file="$cur_path/sensit_param_scenario_led.csv"

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

run_base_sc=1;
run_sensit=0;

(

# Baseline
for i in 11
do
  for taxinc in 0 
  do
      for maxmshbiom in 5 
      do
 
      runname="$i-$taxinc-$maxmshbiom"
      echo "record_vett_carbonbudget=%t;exo_tax_increase=$taxinc/1000;ind_debug_SC_nlu=%t;suffix2combiName='.taxinc${taxinc}.maxmshbiom${maxmshbiom}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
    done
  done
done

# main scenarios
if [ $run_base_sc -eq 1 ]; then
for i in 1284 1214 1244 1264 1284
do
    for coeftclexo in 100 
    do
        for mshbio in 27 #8 #29
        do
            
      for taxbreak_1 in 0 #aa220 240 260 280 300 
      do
      for taxbreak_2 in 3200 #`seq 2600 100 3500` # `seq 2700 25 3500` 
      do

                if [ $i -eq 1284 ];then coefserv=95000; fi
                if [ $i -eq 1214 ];then coefserv=99000; fi
                if [ $i -eq 1264 ];then coefserv=98750; fi
                if [ $i -eq 1244 ];then coefserv=93000; fi
                if [ $i -eq 1294 ];then coefserv=81000; fi

                if [ $i -eq 1284 ];then taxbreak_1=260; fi
                if [ $i -eq 1214 ];then taxbreak_1=200; fi
                if [ $i -eq 1264 ];then taxbreak_1=280; fi
                if [ $i -eq 1244 ];then taxbreak_1=280; fi
                if [ $i -eq 1294 ];then taxbreak_1=300; fi

    runname="$i-$coefserv-$mshbio-$coeftclexo-$taxbreak_1-$taxbreak_2"
    echo "taxbreak_2=$taxbreak_2;taxbreak_1=$taxbreak_1;tax2100=$taxbreak_2;break_year_tax_2=2050;break_year_tax_1=2040;param1=0;param2=0;param3=0;coef_tcl_exo=${coeftclexo}/100;exo_maxmshbiom=$mshbio/1000;max_eei=45/1000;dynForc_EI_indus2comp_obj=${coefserv}/100000;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');suffix2combiName='.coefserv${coefserv}.mshbio${mshbio}.coeftclexo${coeftclexo}.tax$taxbreak_1.taxx$taxbreak_2';exec('imaclimr.sce');exit;"  > run.cmdFile$runname.sce
    #nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null &
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
    #sh run.batchCmd$runname &
    echo $runname

     done
     done

        done
    done
done
fi
#if [ $run_base_sc -eq 1 ]

# sensitivity scenarios
if [ $run_sensit -eq 1 ]; then

(
# Read the CSV file line by line
while IFS=',' read -r combi coefserv taxxtaxx
do
    # Skip the header line
    if [[ "$combi" == "combi" ]]; then
        continue
    fi

    coeftclexo=100
    mshbio=27
    taxbreak_1=0
    taxbreak_2=$taxxtaxx
    i=$combi

    runname="$i-$coefserv-$mshbio-$coeftclexo-$taxbreak_1-$taxbreak_2"
    echo "taxbreak_2=$taxbreak_2;taxbreak_1=$taxbreak_1;tax2100=$taxbreak_2;break_year_tax_2=2050;break_year_tax_1=2040;param1=0;param2=0;param3=0;coef_tcl_exo=${coeftclexo}/100;exo_maxmshbiom=$mshbio/1000;max_eei=45/1000;dynForc_EI_indus2comp_obj=${coefserv}/100000;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');suffix2combiName='.coefserv${coefserv}.mshbio${mshbio}.coeftclexo${coeftclexo}.tax$taxbreak_1.taxx$taxbreak_2';exec('imaclimr.sce');exit;"  > run.cmdFile$runname.sce
    #nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null &
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
    #sh run.batchCmd$runname &
    echo $runname

done < "$csv_file"
)
fi #if [ $run_sensit -eq 1 ]


) > all_run_names.txt
xargs -n1 -P30 "./run_scenario.sh" < all_run_names.txt

