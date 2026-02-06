// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Thibault Briera, Patrice Dumas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================




data_previous_version = "old_ImaclimR_trunkv1.1" + sep ;

GTAP_V1 = DATA + data_previous_version + "GTAP_hybrid"  + sep ;
POLES   = DATA + data_previous_version + "poles"        + sep ;
IEA     = DATA + data_previous_version + "IEA"          + sep ;
AMPERE  = DATA + data_previous_version + "ampere"       + sep ;
MISC    = DATA + data_previous_version + "misc"         + sep ; //miscanellous : unknown source or misc data...
CALIB   = DATA + data_previous_version + "calibration"  + sep ;
IRENA   = DATA +"IRENA"+ sep;
OICA    = DATA +"OICA"+ sep;
IEA_new = DATA + "IEA" + sep;
DATA_OT = DATA + "OtherTerrestrialTransport" + sep;

path_old_run_Imaclim_v11 = DATA + 'Imaclim_Run/run_v1.1/';

path_autocalibration = DATA + 'auto_calibration/';
path_autocal_txCap = path_autocalibration + "txCap" + sep;
path_autocal_tax = path_autocalibration + "tax" + sep;
path_autocal_slopecoal = path_autocalibration + "slopecoal" + sep;
path_autocal_covid = path_autocalibration + "covid" + sep;
path_autocal_exo_prod = path_autocalibration + "exogenous_productivity" + sep;
path_autocal_RLDC = path_autocalibration + "RLDC"+sep;
path_autocal_IC_elec = path_autocalibration + "IC_elec"+sep;
path_autocal_K = path_autocalibration + "calib_K" + sep;
path_autocal_SSP = path_autocalibration + "SSP_labor_productivity" + sep;

GTAP_hybrid = DATA + 'GTAP'+ sep + 'GTAP_Imaclim_after_hybridation_sector'+string(nb_sectors) + sep + 'outputs_GTAP10_YEAR' + sep ;
GTAP_nohybrid = DATA + 'GTAP'+ sep + 'GTAP_Imaclim_aggregation_no_hybridation_sector'+string(nb_sectors) + sep + 'outputs_GTAP10_YEAR' + sep ;

DATA_SAVINGS = DATA + "CEPII_EconMap"  + sep ;

path_growthdrivers_Ltot = DATA +'UNO_n_SSP_population' + sep + 'results' + sep;
path_growthdrivers_Ltot_old = DATA + "SSP" + sep;
path_growthdrivers_Lact1 = DATA + 'UNO_world_population_prospect' + sep + 'results' + sep; 
path_growthdrivers_Lact=path_growthdrivers_Ltot;
path_growthdrivers_TC_l4 = MISC;

path_employment = DATA + 'ILOSTAT/results_sector'+string(nb_sectors) + sep ;

path_world_bank = DATA + "World_Bank" + sep ;

path_areas = MISC;

path_prices = DATA + data_previous_version + "world_bank"   + sep;

path_transport_conso = POLES;
path_transport_use = MISC;
path_transport_to = DATA + data_previous_version + "schafer"  + sep ;
path_transport_pkm1 = DATA + data_previous_version + "schafer"  + sep ;
path_transport_pkm2 = IEA_new + "EnergyEfficiencyIndicators_transport"  + sep ;
path_transport_cars = OICA ;
path_cars_occupancy_rate = DATA + data_previous_version + "smp"  + sep ;
path_transport_EI1 = DATA + data_previous_version + "smp"  + sep ;
path_transport_consocars = IEA_new + "EnergyEfficiencyIndicators_transport"  + sep ;
path_transport_infra = MISC;
path_transport_car_unit = DATA + data_previous_version + "momo2007"  + sep ;
path_transport_EI2 = POLES;
path_transport_maxg = MISC;

path_AIM_air_demand_sc = DATA + "AviationIntegratedModel_TIAM_UCL" + sep ;

path_capital_caprate = CALIB;
path_capital_delta = MISC;
path_capital_deltaK = CALIB;
path_capital_price = IEA;
path_capital_elec_first_try = CALIB;
path_capital_elec = path_autocal_txCap + 'elec' + sep;
path_txcapener = IEA_new + sep + "iea_aggregation_for_hybridation" + sep + "txCaptemp_Ener" + sep;

path_salary_mass = DATA + data_previous_version + "BIT"  + sep ;


path_buildings_tert = MISC;
path_buildings_scEA = POLES;
path_buildings_stock = IEA_new + "EnergyEfficiencyIndicators_Deetman_building"  + sep ;;
path_buildings_stock_old = POLES;
path_buildings_cons = IEA;
path_buildings_opt = MISC;
path_buildings_FBCF = MISC;

path_elec_costs = POLES;
path_elec_lifetimes = MISC;
path_elec_yields = POLES;
path_elec_capac = POLES; 
path_elec_data_previous_version = DATA + data_previous_version + "old"  + sep ;
path_elec_availability1 = POLES;
path_elec_availability2 = CALIB;
path_elec_availability3 = MISC;
path_elec_loadcurve = POLES;
path_elec_biomass = DATA + data_previous_version + "hoogwijk"  + sep ;
path_elec_hist_share = CALIB;
path_elec_ENR_share1 = MISC;
path_elec_ENR_share2 = IEA;
path_elec_inv_share = MISC;
path_elec_capac_MW = MISC;
path_elec_capac_MW_new = DATA+ "Global_Power_Plant_Database" + sep;
path_elec_nuke_MW_new = DATA+ "IAEA" + sep;
path_RLDC_coef = DATA + "ADVANCE" + sep;
path_elec_CP = DATA + "Damodaran"+sep;
path_elec_CT = DATA + "KPMG"+sep;
path_elec_Cap_MW = DATA + "Cap_MW_elec"+sep;
path_elec_WACC = DATA + "WACC_ETH"; 
path_elec_calib_MSH = DATA + "IEA" + sep +"ElectricityGeneration"	+ sep;

//VRE calibration
path_elec_CINV =IRENA +"capital_costs" + sep;
path_elec_cap = IRENA +"installed_cap" + sep;
path_elec_weights = IRENA + "weights"+sep;
path_elec_prod = IRENA + "prod"+sep;

// Emissions
path_emissions_noener = MISC;
path_PRIMAP = DATA + "PRIMAP-hist/results/";
path_GCB = DATA + "Global_Carbon_Budget/results/";
path_Minx = DATA + "Minx_et_al_2022/results/";

path_Et = IEA;

path_cars_hybd = IEA;
path_cars_eff = MISC;
path_cars_costs = MISC;
path_cars_capital = DATA + "carsnexusdata" + sep;
path_cars_deflator = MISC;

path_GDP_PPP1 = DATA + data_previous_version + "IMF"  + sep ;
path_GDP_PPP2 = AMPERE;
path_GDP_MER = AMPERE;
path_GDP_conversion = CALIB;

path_gas_ress = MISC;
path_gas_corr = CALIB;
path_gas_pscenario = DATA + data_previous_version + "EDF"  + sep ;

path_coal_ressources = MISC;
path_coal_pscenario = DATA + data_previous_version + "EDF"  + sep ;
path_coal_corr = CALIB;

path_oil_ress = DATA + data_previous_version + "lopex+total"  + sep ;
path_oil_pscenario = DATA + data_previous_version + "lopex+total"  + sep ;
path_oil_production = DATA + data_previous_version + "lopex+total"  + sep ;
path_oil_emissions = DATA + data_previous_version + "lopex+total"  + sep ;

path_fossil_SC = DATA + "Bauer_et_al_2016_Fossil/aggregated_supply_curve_ssp" + string(ssp_fossil) +"/";
path_fossil_coal_SC = DATA + "RoSE_coal_supply_curves/results/";
path_fossil_cumulative = DATA + "ShiftProject_dataportal"+ sep+"results"+ sep;

path_climatePolicy_Ltot = MISC;

path_climate_impact = DATA + "nexus.climate.impact" + sep ;

path_data_inequalities    = DATA + "inequalitiesnexusdata"  + sep  + 'results' + sep;

path_data_budget_shares = DATA + "OECD_budget_shares" + sep + 'results' + sep;
