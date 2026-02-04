#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Nicolas Graves, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


echo "aggregated_BGR_conventionalGas_reserves"
aggregate_csv_lines.pl < $gas_resource_data/BGR2009/BGR2009_conventional_gas_resources2007.csv BGR2009/dico_BGR2009_to_Imaclim.csv 'Reserves' Region > ./aggregated_BGR_conventionalGas_reserves.csv
echo "aggregated_BGR_conventionalGas_resources"
aggregate_csv_lines.pl < $gas_resource_data/BGR2009/BGR2009_conventional_gas_resources2007.csv BGR2009/dico_BGR2009_to_Imaclim.csv 'Resources' Region > ./aggregated_BGR_conventionalGas_resources.csv
echo "aggregated_BGR_conventionalGas_Cum_Production"
aggregate_csv_lines.pl < $gas_resource_data/BGR2009/BGR2009_conventional_gas_resources2007_zeroNan.csv BGR2009/dico_BGR2009_to_Imaclim.csv 'Cum_Production' Region > ./aggregated_BGR_conventionalGas_Qcumulated.csv

echo "aggregated_Aguilera2009_cumulative_curves_convGas"
#test the definition of scilab
if [ $HOSTNAME = "poseidon.centre-cired.fr" ] || [ $HOSTNAME = "belenus.centre-cired.fr" ]
then
    scilabExe='/home/bibas/bin/scilab-5.4.1/bin/scilab -nb'
elif [ $HOSTNAME = "inari.centre-cired.fr" ]
then
    scilabExe='/data/software/scilab-5.4.1/bin/scilab'
else
    scilabExe='scilab -nb'
fi

(cd ./Aguilera_al_2009/ && echo "Aguilera_dir='$gas_resource_data/Aguilera_al_2009/'; exec('Aguilera2009-Conventionnal_Gas_Resources_aggregation.sce'); exit;" | $scilabExe -nwni)

for dir in AEI_WorldShaleGasResource_InitialAssessment McGlade_al-2013-Energy
do
	mkdir -p $dir
	scp $gas_resource_data/$dir/*.csv $dir/
done

