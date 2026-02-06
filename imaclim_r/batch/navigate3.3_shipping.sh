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

# Second round of submission @ r32109

(

#NDCi_IntShip
for i in  21
do
  for taxinc in 0 
  do
      for maxmshbiom in 5 
      do
 
      runname="$i-$taxinc-$maxmshbiom"
      echo "ETUDEOUTPUT='navigate3.3shipping';record_vett_carbonbudget=%t;exo_tax_increase=$taxinc/1000;ind_debug_SC_nlu=%t;suffix2combiName='.taxinc${taxinc}.maxmshbiom${maxmshbiom}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
    done
  done
done

#NDCi_1000_IntShip & NDCi_1000f_IntShip
# 1002 GtCO2 & 1002 peak
for i in  5501
do
  for tax2020 in 80
  do
      for tax2050 in 1050 
      do
      for tax2100 in 1550 
      do
 
      for mshbio in 18
      do

      runname="$i-$tax2020-$tax2050-$tax2100-$mshbio"
      echo "ETUDEOUTPUT='navigate3.3shipping';record_vett_carbonbudget=%t;tax2020=$tax2020;tax2050=$tax2050;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;suffix2combiName='.tax2020${tax2020}.tax2050${tax2050}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done

outputs/5501_base.tax2020100.tax20501475.tax21002675.35_2023_08_04_16h50min13s/log/summary.log
#NDCi_600f_IntShip
# 598 GtCO2, 628 peak
for i in  5501
do
  for tax2020 in 100
  do
      for tax2050 in 1475 
      do
      for tax2100 in 2675
      do
 
      for mshbio in 18
      do

      runname="$i-$tax2020-$tax2050-$tax2100-$mshbio"
      echo "ETUDEOUTPUT='navigate3.3shipping';record_vett_carbonbudget=%t;tax2020=$tax2020;tax2050=$tax2050;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;suffix2combiName='.tax2020${tax2020}.tax2050${tax2050}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done

#NDCi_600_IntShip
# 589 GtCO2, 601 peak
for i in  5501
do
  for tax2020 in 100
  do
      for tax2050 in 1550 
      do
      for tax2100 in 2750
      do
 
      for mshbio in 13
      do

      runname="$i-$tax2020-$tax2050-$tax2100-$mshbio"
      echo "ETUDEOUTPUT='navigate3.3shipping';record_vett_carbonbudget=%t;tax2020=$tax2020;tax2050=$tax2050;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;suffix2combiName='.tax2020${tax2020}.tax2050${tax2050}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

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

