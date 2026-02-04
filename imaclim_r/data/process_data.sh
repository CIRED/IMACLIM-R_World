#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


# data paths
. ./directories_locations.txt

#python version used
export python3data_imaclim='/data/software/anaconda3/bin/python3'
export scilabdata_imaclim='/data/software/scilab-5.4.1/bin/scilab'

#Final aggregation rule, usefull for the order of regions
export HERE_DIRECTORY=$(pwd)
export Imaclim_reg_final_rule=$HERE_DIRECTORY'/GTAP/aggregations/aggregation_Imaclim_GTAP10_region__after_hybridation.csv'

#################################################################
# ISO and other correspondance
export ISO_GTAP_IMACLIM_rules=${HERE_DIRECTORY}'/ISO_rules/ISO_GTAP_IMACLIM_rules.csv'
(cd ISO_rules && $python3data_imaclim create_ISO_rules.py $ISO_wiki/List_of_ISO_3166_country_codes_1_cleaned.csv $ISO3GTAP_path/ISO3166_GTAP.csv ${Imaclim_reg_final_rule} ${ISO_GTAP_IMACLIM_rules})

#################################################################
# Data with regional / sectoral aggregation

(cd GTAP && ./do_GTAP_before_hybridation.sh)
(cd ./IEA/iea_aggregation_for_hybridation/ && ./do_iea_agregation.sh)
(cd ./GTAP_IEA_hybridation/ && ./do_GTAP_IEA_hybridation.sh)

#Final aggregation rule, usefull for the order of regions

# script with final sectoral aggregation
for nsec in 12 19
do
    export nb_sector=$nsec
    # GTAP
    (cd GTAP/aggregations/ && $python3data_imaclim generate_aggregation_rules.py $nb_sector)
    (cd GTAP && ./do_GTAP_no_hybridation.sh)
    (cd GTAP && ./do_GTAP_after_hybridation.sh)
    # Non GTAP but pre-treated at the GTAP sectoral level
    #(cd EDGAR && ./do_EDGAR_GTAP_aggregation.sh)
    (cd ILOSTAT/ && ./process_ILOSTAT.sh)
done

#     - delete intermediate files for hybridation as they are huge and not especially required for Imaclim calibration
rm -r GTAP/GTAP_Imaclim_before_hybridation/outputs_GTAP*_* GTAP_IEA_hybridation/results/

#################################################################
# Macro data - growth drivers

(cd World_Bank && $python3data_imaclim extract_world_bank_values.py $WB_data_WDI > main.log) 
(cd CEPII_EconMap && $python3data_imaclim extract_CEPII_EconMap_ImaclimR.py $Imaclim_reg_final_rule > main.log)
(cd UNO_n_SSP_population/ && ./process_population.sh)
(cd IMF/BOP/ && $python3data_imaclim process_BOP.py $WB_data > main.log)

#################################################################
# Emissions data
(cd PRIMAP-hist && $python3data_imaclim extract_PRIMAP.py $PRIMAP_data ${ISO_GTAP_IMACLIM_rules})
(cd Global_Carbon_Budget && ./extract_GCB.sh)
(cd Minx_et_al_2022 && $python3data_imaclim extract.py $Minx_et_al_2022 ${ISO_GTAP_IMACLIM_rules})
(cd NPi_NDC && ./process_NPi_NDC.sh) # NDC/NPi

#################################################################
# Sectoral data

# Fossil fuels
(cd Gas_resources && ./aggregate_gas_resources.sh)
(cd Oil_resources && ./import_oil_resources.sh)
(cd Bauer_et_al_2016_Fossil && ./process.sh)

(cd Enerdata && python3 ./enerdata_extract.py)

# Electricity generation
(cd IRENA && sh compute_N_agregate_Irena_data.sh )
(cd Damodaran/ && ./process_CP.sh)
(cd IAEA/ && ./process_IAEA.sh)
(cd Global_Power_Plant_Database && ./process_agreg_FF.sh)
(cd KPMG && ./process_agreg_CT.sh)
(cd ADVANCE && ./process_coef.sh)
(cd Enerdata/POLES_hydro && ./process_hydro.sh)

# Buildings
(cd deetman_marinova_buildings/ && ./process.sh)

# Aviation 
(cd AviationIntegratedModel_TIAM_UCL && $python3data_imaclim extract_AIM_aviation_demand.py $aviationintegratedmodel_data $Imaclim_reg_final_rule > main.log)

#################################################################
# Finance data

# WACC_ETH
(cd ./WACC_ETH && ./process_WACC.sh)

# Risk_free rates using St Louis' Fed and ECB API's
(cd ./ECB && ./process_ecb.sh)
(cd ./Fred_St_Louis && ./process_fred.sh)

# OECD DAC CRS data
(cd OECD_CRS && ./process_crs.sh)

#################################################################
# Other data

# Nexus Inequality
(cd inequalitiesnexusdata && $scilabdata_imaclim -nwni -f compute_inequalities_indices.sce)

