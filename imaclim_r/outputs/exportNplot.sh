#!/bin/bash

if [ $HOSTNAME = "poseidon.centre-cired.fr" ] || [ $HOSTNAME = "belenus.centre-cired.fr" ]
then
    scilabExe='/home/bibas/bin/scilab-5.4.1/bin/scilab'
else
    scilabExe='scilab'
fi

outputsDir=./

rm -r py_plotsOuputs_report
#export imaclim runs from scilab to .csv
$scilabExe -nb -nwni -e "exec('normalize_outputs.sce');quit(0);"
#load and plots results
firstCombi=5
echo "outputDirs='${outputsDir}/'; execfile('./load_results.py'); first_time=2010; combi_baseline_str = ['5','6','7','8']; combi_climat_str = ['105','106','107','108']; execfile('./plot_results.py')" | python > plot_results.log
firstCombi=1005
echo "outputDirs='${outputsDir}/'; execfile('./load_results.py'); first_time=2010; combi_baseline_str = ['1005','1006','1007','1008']; combi_climat_str = ['1105','1106','1107','1108']; execfile('./plot_results.py')" | python > plot_results.log
