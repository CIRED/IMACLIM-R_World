# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Ruben Bibas, Gabriele Dabbaghian
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

# GD scenarios : pg and sufficiency

(

# Baseline
for i in 2 37 33
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

wait 

for i in 802 
do
  for tax2019 in 130 
  do
      for taxbreak_1 in 1150
      do
      for tax2100 in 4600
      do
      for mshbio in 20
      do
      for max_CCS_injection in 5266
      do
        runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio-$max_CCS_injection"
        echo "ind_cor_ener_autocons=%t;record_vett_carbonbudget=%t;exo_max_CCS_injection=$max_CCS_injection/1000;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.mshbio${mshbio}.max_CCS_injection${max_CCS_injection}'"     > run.cmdFile$runname.sce

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

for i in 1102 
do
  for tax2019 in 130 
  do
      for taxbreak_1 in 4950
      do
      for tax2100 in  5200 
      do
      for mshbio in 20
      do
      for max_CCS_injection in 5266
      do
      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio-$max_CCS_injection"
      echo "ind_cor_ener_autocons=%t;record_vett_carbonbudget=%t;exo_max_CCS_injection=$max_CCS_injection/1000;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.mshbio${mshbio}.max_CCS_injection${max_CCS_injection}'"     > run.cmdFile$runname.sce

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

for i in 1837 
do
  for tax2019 in 130 
  do
      for taxbreak_1_1 in 4950
      do
      for tax2100_1 in  5200 
      do
      for taxbreak_1_2 in 4950
      do
      for tax2100_2 in  5200 
      do
      for taxbreak_1_3 in 1200
      do
      for tax2100_3 in  1800 
      do
      for mshbio in 20
      do
      for max_CCS_injection in 5266
      do
      runname="$i-$tax2019-$taxbreak_1_1-$tax2100_1-$taxbreak_1_2-$tax2100_2-$taxbreak_1_3-$tax2100_3-$mshbio-$max_CCS_injection"
      echo "ind_cor_ener_autocons=%t;record_vett_carbonbudget=%t;exo_max_CCS_injection=$max_CCS_injection/1000;tax2019=$tax2019;taxbreak_1_1=$taxbreak_1_1;tax2100_1=$tax2100_1;taxbreak_1_2=$taxbreak_1_2;tax2100_2=$tax2100_2;taxbreak_1_3=$taxbreak_1_3;tax2100_3=$tax2100_3;exo_maxmshbiom=$mshbio/1000;suffix2combiName='.tax2019${tax2019}.taxbreak_1_1${taxbreak_1_1}.tax2100_1${tax2100_1}.taxbreak_1_2${taxbreak_1_2}.tax2100_2${tax2100_2}.taxbreak_1_3${taxbreak_1_3}.tax2100_3${tax2100_3}.mshbio${mshbio}.max_CCS_injection${max_CCS_injection}'"     > run.cmdFile$runname.sce

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
      done
      done
  done
done

for i in 1833 
do
  for tax2019 in 130 
  do
      for taxbreak_1_1 in 4950
      do
      for tax2100_1 in  5200 
      do
      for taxbreak_1_2 in 4950
      do
      for tax2100_2 in  5200 
      do
      for taxbreak_1_3 in 3500
      do
      for tax2100_3 in 4500 
      do
      for mshbio in 20
      do
      for max_CCS_injection in 5266
      do
      runname="$i-$tax2019-$taxbreak_1_1-$tax2100_1-$taxbreak_1_2-$tax2100_2-$taxbreak_1_3-$tax2100_3-$mshbio-$max_CCS_injection"
      echo "ind_cor_ener_autocons=%t;record_vett_carbonbudget=%t;exo_max_CCS_injection=$max_CCS_injection/1000;tax2019=$tax2019;taxbreak_1_1=$taxbreak_1_1;tax2100_1=$tax2100_1;taxbreak_1_2=$taxbreak_1_2;tax2100_2=$tax2100_2;taxbreak_1_3=$taxbreak_1_3;tax2100_3=$tax2100_3;exo_maxmshbiom=$mshbio/1000;suffix2combiName='.tax2019${tax2019}.taxbreak_1_1${taxbreak_1_1}.tax2100_1${tax2100_1}.taxbreak_1_2${taxbreak_1_2}.tax2100_2${tax2100_2}.taxbreak_1_3${taxbreak_1_3}.tax2100_3${tax2100_3}.mshbio${mshbio}.max_CCS_injection${max_CCS_injection}'"     > run.cmdFile$runname.sce

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
      done
      done
  done
done

) > all_run_names.txt
xargs -n1 -P32 "./run_scenario.sh" < all_run_names.txt
