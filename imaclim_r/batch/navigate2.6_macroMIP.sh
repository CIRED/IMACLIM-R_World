# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera, Ruben Bibas, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

#/nc@inari batchbin/bash
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

# Scenarios submitted for NAVIGATE T2.6, 22-10-2023
# run with r31998
#          & svn update -r32011 model/diagnostic.sce
# 	   & svn update -r32058 lib/diagnostic.sce

(

# Baseline
for i in  11
do
  for taxinc in 0 
  do
      for maxmshbiom in 5 
      do
 
      runname="$i-$taxinc-$maxmshbiom"
      echo "ETUDEOUTPUT='macromips';record_vett_carbonbudget=%t;exo_tax_increase=$taxinc/1000;ind_debug_SC_nlu=%t;suffix2combiName='.taxinc${taxinc}.maxmshbiom${maxmshbiom}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
    done
  done
done

#1149 GtCO2 (-176.5697 NE)
for i in  4006 4023
do
  for tax2019 in 70
  do
      for taxbreak_1 in 1085
      do
      for tax2100 in 1375
      do
 
      for mshbio in 35
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "ETUDEOUTPUT='macromips';record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done

#684 GtCO2 (-397. NE)
for i in  4008 4024
do
  for tax2019 in 80
  do
      for taxbreak_1 in 1800
      do
      for tax2100 in 2900
      do
 
      for mshbio in 20
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "ETUDEOUTPUT='macromips';record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done

# 1147 GtCO2 (NE -285)
for i in  4013
do
  for tax2019 in 20
  do
      for taxbreak_1 in 825
      do
      for tax2100 in 1575
      do
 
      for mshbio in 35
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "ETUDEOUTPUT='macromips';record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done

# 705 GtCO2 (NE -399)
for i in  4022
do
  for tax2019 in 75
  do
      for taxbreak_1 in 2700
      do
      for tax2100 in 3100
      do
 
      for mshbio in 206
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "ETUDEOUTPUT='macromips';record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/10000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done

# 1146 GtCO2 (NE -222)
for i in  4021
do
  for tax2019 in 20 
  do
      for taxbreak_1 in 850
      do
      for tax2100 in 1600
      do
 
      for mshbio in 35
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

# 720 GtCO2 (NE -436)
for i in  4014
do
  for tax2019 in 135
  do
      for taxbreak_1 in 1450
      do
      for tax2100 in 4100
      do

      for mshbio in 65
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "ETUDEOUTPUT='macromips';record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/10000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done

) > all_run_names.txt
xargs -n1 -P32 "./run_scenario.sh" < all_run_names.txt

