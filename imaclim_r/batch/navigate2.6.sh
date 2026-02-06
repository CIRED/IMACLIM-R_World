# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Thibault Briera
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

# Scenarios submitted for NAVIGATE T2.6, 22-10-2023
# run with r31998
#          & svn update -r32011 model/diagnostic.sce
# 	   & svn update -r32058 lib/diagnostic.sce
#	   & svn update -r32090 model/extraction-first.sce model/nexus.climatePolicy2.sce study_frames/base.sce study_frames/matrice_base.csv study_frames/default_parameters.sce
#	   & svn update -r32726 lib/npi_ndc.sci lib/compute_emi_ccs.sci lib/diagnostic.sce

# data, do
#unzip -o /data/public_results/ImaclimR/input_data/input_data-Imaclim2.0-r32070.zip
#unzip -o /data/public_results/ImaclimR/input_data/input_data-Imaclim2.0-r31996.zip

# then patch
# patch -p0 -i patch/patch_navigate2.6.patch

# 401515 and 40077 needs to be run 3 times exactly to generate 
# outputs/ind_lindhal_tax_correction_4007.csv and
# outputs/ind_lindhal_tax_correction_4015.csv and
# before running 4007 and 4015

(

# Baseline
for i in  11
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

#1149 GtCO2 (-176.5697 NE)
for i in  4006 4023
do
  for tax2019 in 70
  do
      for taxbreak_1 in 1085
      do
      for tax2100 in 1375
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

# to be run 3 times before 4007
# 630/684 GtCO2
for i in  40077
do
  for tax2019 in 85
  do
      for taxbreak_1 in 1800 
      do
      for tax2100 in  3400 
      do
 
      for mshbio in 99 
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/10000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      #echo $runname
      done
      done
    done
  done
done

#684 GtCO2 (-404 NE)
for i in  4007
do
  for tax2019 in 85
  do
      for taxbreak_1 in 1800
      do
      for tax2100 in 2990
      do
 
      for mshbio in 10
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

#684 GtCO2 (-397. NE)
for i in  4008 #4024
do
  for tax2019 in 80
  do
      for taxbreak_1 in 1800
      do
      for tax2100 in 2900
      do
 
      for mshbio in 10
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

# 684 GtCO2 (-421 NE)
for i in  4011
do
  for tax2019 in 75
  do
      for taxbreak_1 in 1480
      do
      for tax2100 in 3100
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

# 1147 GtCO2 (NE -285)
for i in  4013
do
  for tax2019 in 20
  do
      for taxbreak_1 in 825 
      do
      for tax2100 in 1575 
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

# 674 GtCO2 (NE -397)
for i in  4009
do 
  for tax2019 in 70 
  do
      for taxbreak_1 in 2400
      do
      for tax2100 in 2420
      do
 
      for mshbio in 76
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/10000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done

# 877 GtCO2 (- 93 NE)
for i in  4010
do
  for tax2019 in 100
  do
      for taxbreak_1 in 2397
      do
      for tax2100 in 6000
      do
 
     for mshbio in 26
     do

     for exo_max_CCS_injection in 30
     do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio-$exo_max_CCS_injection"
      echo "exo_max_CCS_injection=$exo_max_CCS_injection/10;record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}.${exo_max_CCS_injection}'"     > run.cmdFile$runname.sce

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

# 718 GtCO2 (NE -415)
for i in  4022
do
  for tax2019 in 75
  do
      for taxbreak_1 in 2700
      do
      for tax2100 in 3100
      do
 
      for mshbio in 106
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/10000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done

# to be run 3 times before 4015
# 1133/1149
for i in  401515
do
  for tax2019 in 80 
  do
      for taxbreak_1 in 1085 
      do
      for tax2100 in  1375
      do
 
      for mshbio in 18
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      #echo $runname
      done
      done
    done
  done
done

# 1150 GtCO2 (NE -195)
for i in  4015
do
  for tax2019 in 80
  do
      for taxbreak_1 in 1085
      do
      for tax2100 in 1370
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

# 681 GtCO2 (NE -419)
for i in  4016
do
  for tax2019 in 80
  do
      for taxbreak_1 in 1400
      do
      for tax2100 in 3600
      do
 
      for mshbio in 10
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

# 1146 GtCO2 (-203 NE)
for i in 4018
do
  for tax2019 in 60 
  do
      for taxbreak_1 in 1330 
      do
      for tax2100 in 1820
      do
 
      for mshbio in 22
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"  
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/10000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce      

      echo "combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;"  >> run.cmdFile$runname.sce
      echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$i.err < /dev/null"            > run.batchCmd$runname
      #sh run.batchCmd$runname &
      echo $runname
      done
      done
    done
  done
done

# 1151 GtCO2 (-85 NE)
for i in  4019
do
  for tax2019 in 70  
  do
      for taxbreak_1 in 1300
      do
      for tax2100 in 2400
      do
 
      for mshbio in 10
      do

      for exomaxCCSinjection in 48
      do
      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio-$exomaxCCSinjection"  
      echo "exo_max_CCS_injection=$exomaxCCSinjection/10;record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/1000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}.${exomaxCCSinjection}'"     > run.cmdFile$runname.sce      
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

# 1154 GtCO2 (-155 NE)
for i in  4020
do
  for tax2019 in 60 
  do
      for taxbreak_1 in 950
      do
      for tax2100 in 1700
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

# 1149 GtCO2 (-182 NE)
for i in  4017
do
  for tax2019 in 65
  do
      for taxbreak_1 in 950
      do
      for tax2100 in 1550 
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

# 1146 GtCO2 (NE -222)
for i in  4021
do
  for tax2019 in 20 
  do
      for taxbreak_1 in 1100
      do
      for tax2100 in 1800
      do
 
      for mshbio in 25
      do
    
      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"  
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/10000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce          

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

      for mshbio in 33
      do

      runname="$i-$tax2019-$taxbreak_1-$tax2100-$mshbio"
      echo "record_vett_carbonbudget=%t;tax2019=$tax2019;taxbreak_1=$taxbreak_1;tax2100=$tax2100;exo_maxmshbiom=$mshbio/10000;ind_debug_SC_nlu=%t;suffix2combiName='.tax2019${tax2019}.taxbreak_1${taxbreak_1}.tax2100${tax2100}.${mshbio}'"     > run.cmdFile$runname.sce

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

