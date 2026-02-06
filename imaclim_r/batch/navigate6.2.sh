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

# NAVIGATE scenaros submitted the 29-02-2024,
# run with r32203

(

# Baseline
for i in 1011 1012 1013 1014 1015 1016
do
  for taxinc in 0 
  do
      for maxmshbiom in 5 
      do
 
      runname="$i-$taxinc-$maxmshbiom"
      echo "ind_cor_ener_autocons=%t;record_vett_carbonbudget=%t;exo_tax_increase=$taxinc/1000;ind_debug_SC_nlu=%t;suffix2combiName='.taxinc${taxinc}.maxmshbiom${maxmshbiom}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      sh run.batchCmd$runname &
      #echo $runname
    done
  done
done

#   912 GtCO2 (-180.64396NE) for 6201
for i in 6201 
do
  for tax2019 in 130 
  do
      for taxbreak_1 in 2700 
      do
      for tax2100 in  5021 
      do
 
      for mshbio in 10
      do
      for max_CCS_injection in 5266
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio-$max_CCS_injection"
      echo "ind_cor_ener_autocons=%t;record_vett_carbonbudget=%t;exo_max_CCS_injection=$max_CCS_injection/1000;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.mshbio${mshbio}.max_CCS_injection${max_CCS_injection}'"     > run.cmdFile$runname.sce

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

#   798 GtCO2 (-168.6 NE) for 6202
for i in 6202 
do
  for tax2019 in 130 
  do
      for taxbreak_1 in 2700 
      do
      for tax2100 in  5021 
      do
 
      for mshbio in 10
      do
      for max_CCS_injection in 5262 #5263 5264
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio-$max_CCS_injection"
      echo "ind_cor_ener_autocons=%t;record_vett_carbonbudget=%t;exo_max_CCS_injection=$max_CCS_injection/1000;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.mshbio${mshbio}.max_CCS_injection${max_CCS_injection}'"     > run.cmdFile$runname.sce

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

#  315 GtCO2 (-484 NE)
for i in 6203
do
  for tax2019 in 130
  do
      for taxbreak_1 in 2700 #3000
      do
      for tax2100 in 5021
      do
 
      for mshbio in 18
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "ind_cor_ener_autocons=%t;record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.mshbio${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done

#   309 GtCO2 (-405 NE)
for i in 6204
do
  for tax2019 in 130
  do
      for taxbreak_1 in 2700 #3000
      do
      for tax2100 in 5021
      do
 
      for mshbio in 181 
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "ind_cor_ener_autocons=%t;record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/10000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.mshbio${mshbio}'"     > run.cmdFile$runname.sce

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
