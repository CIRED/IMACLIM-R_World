#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

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

for i in 2 3 4 5 # baseline and price scenarios
do
for taxy in  0
do
    for daty in 0
    do
    runname="$i-$taxy-$daty"
    echo "ind_debug_SC_nlu=%t;TimeHorizon=99;suffix2combiName='.date${daty}.tax${taxy}'"     > run.cmdFile$runname.sce
    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    #at -q b -m now -f "run.batchCmd$runname"
    echo $runname
    done
done
done

for i in 6 # gives 1622 GtCO2 2011-2100
do
for taxy in 31 
do
    for daty in 150
    do
    runname="$i-$taxy-$daty"
    echo "ind_debug_SC_nlu=%t;TimeHorizon=99;suffix2combiName='.date${daty}.tax${taxy}'"     > run.cmdFile$runname.sce
    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    #at -q b -m now -f "run.batchCmd$runname"
    echo $runname
    done
done
done

# 7 runs without NLU first. need then to run nlu with drivers
for i in 7 # gives 1601 GtCO2 2011-2100
do
for taxy in 323
do
    for daty in 250
    do
    runname="$i-$taxy-$daty"
    echo "ind_debug_SC_nlu=%t;TimeHorizon=99;suffix2combiName='.date${daty}.tax${taxy}'"     > run.cmdFile$runname.sce
    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy/10;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    #at -q b -m now -f "run.batchCmd$runname"
    echo $runname
    done
done
done

for i in 8 # gives 1654 GtCO2 2011-2100
do
for taxy in 38 # 39 and 40 crash
do
    for daty in 150
    do
    runname="$i-$taxy-$daty"
    echo "ind_debug_SC_nlu=%t;TimeHorizon=99;suffix2combiName='.date${daty}.tax${taxy}'"     > run.cmdFile$runname.sce
    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    #at -q b -m now -f "run.batchCmd$runname"
    echo $runname
    done
done
done

for i in 9 # gives 1605 GtCO2 2011-2100
do
for taxy in 32
do
    for daty in 150
    do
    runname="$i-$taxy-$daty"
    echo "ind_debug_SC_nlu=%t;TimeHorizon=99;suffix2combiName='.date${daty}.tax${taxy}'"     > run.cmdFile$runname.sce
    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    #at -q b -m now -f "run.batchCmd$runname"
    echo $runname
    done
done
done


for i in 10 # gives 1581 GtCO2 2011-2100
do
for taxy in 337 
do
    for daty in 150
    do
    runname="$i-$taxy-$daty"
    echo "ind_debug_SC_nlu=%t;TimeHorizon=99;suffix2combiName='.date${daty}.tax${taxy}'"     > run.cmdFile$runname.sce
    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy/10;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    #at -q b -m now -f "run.batchCmd$runname"
    echo $runname
    done
done
done

for i in 11 # gives 1629 GtCO2 2011-2100
do
for taxy in 2800 
do
    for daty in 200
    do
    runname="$i-$taxy-$daty"
    echo "ind_debug_SC_nlu=%t;TimeHorizon=99;suffix2combiName='.date${daty}.tax${taxy}'"     > run.cmdFile$runname.sce
    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy/100;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    #at -q b -m now -f "run.batchCmd$runname"
    echo $runname
    done
done
done

for i in 12 # gives 1596 GtCO2 2011-2100
do
for taxy in 3595 
do
    for daty in 150
    do
    runname="$i-$taxy-$daty"
    echo "ind_debug_SC_nlu=%t;TimeHorizon=99;suffix2combiName='.date${daty}.tax${taxy}'"     > run.cmdFile$runname.sce
    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy/100;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    #at -q b -m now -f "run.batchCmd$runname"
    echo $runname
    done
done
done

for i in 15 #14 15 18 19 13 16 # this gives 1066  GtCO2, not enough for th emaximum 1050.. but close
do
for exomsh in 50 #30 15 12 20 40 80 100 #10 #00 220 230 240 250 269 270 #50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 180
do
for taxy in 5
do
for nbitery in  1
do
for inertexo in 6 
do
for pp in  535 #1 562 563 570 564 565 566 567 568 569 
do
    for daty in 300  
    do
    runname="$i-$taxy-$daty-$pp-$inertexo-$nbitery-$exomsh"
    echo "ind_debug_SC_nlu=%t;exomsh=${exomsh}/1000;inertExo=${inertexo};maxiteryexo=${nbitery};paramy2050=${pp}/10;TimeHorizon=99;suffix2combiName='.inert${inertexo}.iter${nbitery}.firsttax${daty}.pr0f${pp}.pr1f${taxy}.exomsh${exomsh}'"     > run.cmdFile$runname.sce
    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    #at -q a -m now -f "run.batchCmd$runname"
    echo $runname
    done
done
done
done
done
done
done

for i in 13  #14 15 18 19 13 16 # this gives 1066  GtCO2, not enough for th emaximum 1050.. but close
do
for exomsh in 50 #30 15 12 20 40 80 100 #10 #00 220 230 240 250 269 270 #50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 180
do
for taxy in 5
do
for nbitery in  1
do
for inertexo in 6 
do
for pp in  490 #1 562 563 570 564 565 566 567 568 569 
do
    for daty in 300  
    do
    runname="$i-$taxy-$daty-$pp-$inertexo-$nbitery-$exomsh"
    echo "ind_debug_SC_nlu=%t;exomsh=${exomsh}/1000;inertExo=${inertexo};maxiteryexo=${nbitery};paramy2050=${pp}/10;TimeHorizon=99;suffix2combiName='.inert${inertexo}.iter${nbitery}.firsttax${daty}.pr0f${pp}.pr1f${taxy}.exomsh${exomsh}'"     > run.cmdFile$runname.sce
    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    #at -q a -m now -f "run.batchCmd$runname"
    echo $runname
    done
done
done
done
done
done
done


for i in 1 # baseline and price scenarios
do
for taxy in  0
do
    for daty in 0
    do
    runname="$i-$taxy-$daty"
    echo "ind_debug_SC_nlu=%t;TimeHorizon=99;suffix2combiName='.date${daty}.tax${taxy}'"     > run.cmdFile$runname.sce
    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
    #at -q b -m now -f "run.batchCmd$runname"
    echo $runname
    done
done
done


# sensitivity scenarios on the NLU : the NLU is driven only by quantity OR prices of the Imaclim scenrio with bioen,ergy
#for i in 204 205 207 307 407 102 103 106 108
#do
#for taxy in  0
#do
#    for daty in 0
#    do
#    runname="$i-$taxy-$daty"
#    echo "ind_debug_SC_nlu=%f;TimeHorizon=99;suffix2combiName='.date${daty}.tax${taxy}'"     > run.cmdFile$runname.sce
#    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
#    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
#    echo "nohup nice $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
#    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
#    #at -q b -m now -f "run.batchCmd$runname"
#    echo $runname
#    done
#done
#done

# sensitivity test on the azote content of bioenergy production
#for nazote in 47 77
#do
#for i in 6 # gives 1622 GtCO2 2011-2100
#do
#for taxy in 31
#do
#    for daty in 150
#    do
#    runname="$i-$taxy-$daty-$nazote"
#    echo "extern_azote_content=${nazote}/10000;ind_debug_SC_nlu=%f;TimeHorizon=99;suffix2combiName='.date${daty}.tax${taxy}.azote${nazote}'"     > run.cmdFile$runname.sce
#    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
#    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
#    echo "nohup nice -n +8 $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
#    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
#    at -q a -m now -f "run.batchCmd$runname"
#    echo $runname
#    done
#done
#done
#done

# sensitivity tests for deforested areas
#for arate in 20 #1 3 5 10 15 20
#do
#for i in 6 #8
#do
#for taxy in  31 #38
#do
#    for daty in 150
#    do
#    runname="$i-$taxy-$daty-$arate"
#    echo "agriculture_land_rate=${arate};ind_debug_SC_nlu=%f;TimeHorizon=99;suffix2combiName='.date${daty}.tax${taxy}.agrrate${arate}'"     > run.cmdFile$runname.sce
#    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
#    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
#    echo "nohup nice -n  +8 $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
#    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
#    at -q a -m now -f "run.batchCmd$runname"
#    echo $runname
#    done
#done
#done
#done

# sensitivity test on bouwman efficiency coeffcieint (livestock effciency)
#for i in 6 #8
#do
#for taxy in 31 #38
#do
#    for daty in 150
#    do
#    runname="$i-$taxy-$daty-bouwman"
#    echo "sensit_bouwmanFalse=%t;ind_debug_SC_nlu=%f;TimeHorizon=99;suffix2combiName='.date${daty}.tax${taxy}.bouwmanFalse'"     > run.cmdFile$runname.sce
#    echo "sensittax_param_date=$daty;sensittax_param_uplimit=$taxy;combi=$i;isBatch = %t;deff('clf(varargin)','');deff('plot(varargin)','');exec('imaclimr.sce');exit;" >> run.cmdFile$runname.sce
#    echo "suffix2combiName='.date${daty}.tax${taxy}'"     >> run.cmdFile$runname.sce
#    echo "nohup nice -n +8 $scilabExe -nb -nwni -f run.cmdFile$runname.sce > /dev/null 2> run.batch$runname.err < /dev/null"            > run.batchCmd$runname
#    echo "echo 'The job $runname was done in `pwd`' | /bin/mail -s 'Job $runname done on $HOSTNAME' -S from='The Master of Imaclim <un@owen>' $USER@centre-cired.fr"                                                                                                                              >> run.batchCmd$i
#    at -q a -m now -f "run.batchCmd$runname"
#    echo $runname
#    done
#done
#done



) > all_run_names.txt
xargs -n1 -P8 "./run_scenario.sh" < all_run_names.txt
