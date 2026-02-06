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

# First round of submission @r31299

(

# REF scenario
for i in  1
do
  for taxinc in 0 
  do
      for maxmshbiom in 0
      do
      runname="$i-$taxinc-$maxmshbiom"
      echo "ETUDE='navigate33aviation';ETUDEOUTPUT='navigate33aviation';pkmair_inertia_lag=2/3;record_vett_carbonbudget=%t;exo_tax_increase=$taxinc/1000;exo_maxmshbiom=$maxmshbiom/10000;ind_debug_SC_nlu=%t;suffix2combiName='.taxinc${taxinc}.maxmshbiom${maxmshbiom}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      echo $runname
      done
  done
done

# 1.5C scenario
# 695 GtCO2
for i in  12
do
  for taxinc in 800
  do
      for maxmshbiom in 384
      do
      runname="$i-$taxinc-$maxmshbiom"
      echo "ETUDE='navigate33aviation';ETUDEOUTPUT='navigate33aviation';record_vett_carbonbudget=%t;exo_tax_increase=$taxinc/1000;exo_maxmshbiom=$maxmshbiom/10000;ind_debug_SC_nlu=%t;suffix2combiName='.taxinc${taxinc}.maxmshbiom${maxmshbiom}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      echo $runname
      done
  done
done

# 1.5C_HD scenario
# 700 GtCO2
for i in  11
do
  for taxinc in 815 
  do
      for maxmshbiom in 44
      do
      runname="$i-$taxinc-$maxmshbiom"
      echo "ETUDE='navigate33aviation';ETUDEOUTPUT='navigate33aviation';record_vett_carbonbudget=%t;exo_tax_increase=$taxinc/1000;exo_maxmshbiom=$maxmshbiom/1000;ind_debug_SC_nlu=%t;suffix2combiName='.taxinc${taxinc}.maxmshbiom${maxmshbiom}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      echo $runname
      done
  done
done

# 1.5C_LD scenario
# 694 GtCO2
for i in  13
do
  for taxinc in 711
  do
      for maxmshbiom in 36
      do
      runname="$i-$taxinc-$maxmshbiom"
      echo "ETUDE='navigate33aviation';ETUDEOUTPUT='navigate33aviation';record_vett_carbonbudget=%t;exo_tax_increase=$taxinc/1000;exo_maxmshbiom=$maxmshbiom/1000;ind_debug_SC_nlu=%t;suffix2combiName='.taxinc${taxinc}.maxmshbiom${maxmshbiom}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
  done
done

# 1.5C_LCF scenario
# 704 GtCO2
for i in  22
do
  for taxinc in 7089
  do
      for maxmshbiom in 384
      do
      runname="$i-$taxinc-$maxmshbiom"
      echo "ETUDE='navigate33aviation';ETUDEOUTPUT='navigate33aviation';record_vett_carbonbudget=%t;exo_tax_increase=$taxinc/10000;exo_maxmshbiom=$maxmshbiom/10000;ind_debug_SC_nlu=%t;suffix2combiName='.taxinc${taxinc}.maxmshbiom${maxmshbiom}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      echo $runname
      done
  done
done

# 1.5C_LDLCF scenario
# 700 GtCO2
for i in  23
do
  for taxinc in 678
  do
      for maxmshbiom in 36
      do
      runname="$i-$taxinc-$maxmshbiom"
      echo "ETUDE='navigate33aviation';ETUDEOUTPUT='navigate33aviation';record_vett_carbonbudget=%t;exo_tax_increase=$taxinc/1000;exo_maxmshbiom=$maxmshbiom/1000;ind_debug_SC_nlu=%t;suffix2combiName='.taxinc${taxinc}.maxmshbiom${maxmshbiom}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
  done
done

) > all_run_names.txt
xargs -n1 -P32 "./run_scenario.sh" < all_run_names.txt

