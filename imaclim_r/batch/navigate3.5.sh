# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Thomas Le Gallic, Thibault Briera
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

#/nc@inari batchbin/bash
# META-IMACLIM-R
# Permet d'exécuter les combis et profils de taxes de la tâche 3.5 : 5 combis (no demand-side policy, sufficiency, efficiency, electrification, all) et 3 profils de taxe (NPi, 2°C et 1.7°C). 
# Revision correspondante : r32141
# Note that there is a "switch" dedicated to the reproducibility of the scenarios submitted on the 12th of December 2023: ind_navigateWP3 in base.sce (ind_navigateWP3 = 1 should be used, 0 is the default value).

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

# Which scenarios to run?
All=1 # should be 1 if you want to run all of them
if [ $All -eq 1 ];then
baselines=1; ref_2C=1; ref_17C=1; suf_2C=1; suf_17C=1; eff_2C=1; eff_17C=1; swi_2C=1; swi_17C=1; all_2C=1; all_17C=1;
else # define which one if All = 0
baselines=1; 
ref_2C=0; 
ref_17C=0; 
suf_2C=0; 
suf_17C=0 ;
eff_2C=0 ;
eff_17C=0; 
swi_2C=0; 
swi_17C=0; 
all_2C=0; 
all_17C=0;
fi

# NAVIGATE scenarios submitted the 29-10-2023,
# run with r32141 

# Baseline
if [ $baselines -eq 1 ]; then
for i in  1011 1012 1013 1014 1015
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
fi



# Reference

if [ $ref_2C -eq 1 ]; then
for i in  4001 #2°C
do
  for tax2019 in 50
  do
      for taxbreak_1 in 600
      do
      for tax2100 in 1300
      do
 
      for mshbio in 8
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done
fi

if [ $ref_17C -eq 1 ]; then
for i in  4101 #1.7°C (650 Gt for 2020 - 2100) # A more ambitious target would exceed the cumulative negative emissions over the period (set at 500 Gt for 2020-2100) for this scenario without demand-side mitigation options.
do
  for tax2019 in 135
  do
      for taxbreak_1 in 1350
      do
	  
      for tax2100 in  1940
      do
 
      for mshbio in 18
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done
fi



# Sufficiency

if [ $suf_2C -eq 1 ]; then
for i in  4002 #2°C
do
  for tax2019 in 50
  do
      for taxbreak_1 in 650
      do
      for tax2100 in 880
      do
 
      for mshbio in 8      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done
fi

if [ $suf_17C -eq 1 ]; then
for i in  4102 #1.7°C
do
  for tax2019 in 75
  do
      for taxbreak_1 in 1350 
      do
      for tax2100 in  1700
      do
 
      for mshbio in 18
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done
fi




# Efficiency

if [ $eff_2C -eq 1 ]; then
for i in 4003 #2°C
do
  for tax2019 in 50
  do
      for taxbreak_1 in 600
      do
      for tax2100 in 765
      do
 
      for mshbio in 8
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done
fi

if [ $eff_17C -eq 1 ]; then
for i in 4103 #1.7°C
do
  for tax2019 in 75
  do
      for taxbreak_1 in 1200
      do
      for tax2100 in 1900
      do
 
      for mshbio in 18
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done
fi




# Fuel switching

if [ $swi_2C -eq 1 ]; then
for i in 4004 #2°C
do
  for tax2019 in 50
  do
      for taxbreak_1 in 400
      do
      for tax2100 in 750
      do
 
      for mshbio in 8
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done
fi

if [ $swi_17C -eq 1 ]; then
for i in 4104 #1.7°C
do
  for tax2019 in 50
  do
      for taxbreak_1 in  1100
      do
      for tax2100 in 1300 1325
      do
 
      for mshbio in 18
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done
fi




# All

if [ $all_2C -eq 1 ]; then
for i in 4005 #2°C
do
  for tax2019 in 50
  do
      for taxbreak_1 in 200
      do
      for tax2100 in 350 
      do
 
      for mshbio in 8
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done
fi

if [ $all_17C -eq 1 ]; then
for i in 4105 #1.7°C
do
  for tax2019 in 50
  do
      for taxbreak_1 in 825
      do
      for tax2100 in 1400
      do
 
      for mshbio in 18
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done
fi




) > all_run_names.txt
xargs -n1 -P32 "./run_scenario.sh" < all_run_names.txt

