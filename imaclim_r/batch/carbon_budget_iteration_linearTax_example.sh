# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Florian Leblanc, Thibault Briera
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

# Baseline
for i in  1
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

# 1146 GtCO2 (-164 NE)
for i in  4001
do
  for tax2019 in 50
  do
      for taxbreak_1 in 1050
      do
      for tax2100 in 2050 
      do
 
      for mshbio in 20 
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

#700 GtCO2 (-345 NE) 
for i in  4001
do
  for tax2019 in 75
  do
      for taxbreak_1 in 1600
      do
      for tax2100 in 3200
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

# 396 GtCO2 (-471 NE)
for i in  4001
do
  for tax2019 in 75   
  do
      for taxbreak_1 in 2400
      do
      for tax2100 in 3500
      do
 
      for mshbio in 42
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

# 397 GtCO2 (-459 NE)
for i in  4001
do
  for tax2019 in 75   
  do
      for taxbreak_1 in 2500
      do
      for tax2100 in 3300
      do
 
      for mshbio in 40
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

) > all_run_names.txt
xargs -n1 -P32 "./run_scenario.sh" < all_run_names.txt

