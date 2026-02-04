# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Florian Leblanc
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

# NAVIGATE scenaros submitted the 16-06-2023,
# run with r31840
# with svn update -r31960 model/nexus.Et.sce model/extraction.outputs.navigate.region.sce model/extraction.outputs.navigate.world.sce
# with svn update -r31932 lib/custom.sci

(

# Baseline
for i in 11 31 41 51
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


#  927 GtCO2 (-180 NE)
for i in 6301 
do
  for tax2019 in 135 
  do
      for taxbreak_1 in 3000
      do
      for tax2100 in 3700
      do
 
      for mshbio in 20
      do
      for max_CCS_injection in 5263
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio-$max_CCS_injection"
      echo "record_vett_carbonbudget=%t;exo_max_CCS_injection=$max_CCS_injection/1000;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}.${max_CCS_injection}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
      done
    done
  done
done

#outputs/6302_base.tax2019160.taxbreak_14000.tax21007500.30.55_2023_06_15_18h31min21s/log/summary.log
# 735 GtCO2 (-169 NE)
# Note : tax2100=7600 crashes
for i in 6302 
do
  for tax2019 in 160
  do
      for taxbreak_1 in 4000 
      do
      for tax2100 in 7500
      do
 
      for mshbio in 30
      do
      for max_CCS_injection in 55
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio-$max_CCS_injection"
      echo "record_vett_carbonbudget=%t;exo_max_CCS_injection=$max_CCS_injection/10;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}.${max_CCS_injection}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
      done
    done
  done
done

# 695 GtCO2 (-372 NE)
for i in 6303 
do
  for tax2019 in 60  
  do
      for taxbreak_1 in 1245
      do
      for tax2100 in 2300
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

# 403 GtCO2 (-478 NE)
for i in 6304 
do
  for tax2019 in 90 
  do
      for taxbreak_1 in  2300
      do
      for tax2100 in 1300 
      do
 
      for mshbio in 60 
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
