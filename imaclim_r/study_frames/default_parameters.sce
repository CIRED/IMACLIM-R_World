
// Default parameters that may not be used by some STUDIES, but need to be initialized to avoid error
// This could be also BAU or mainstream parametrisation that should be used when starting a study
// every parameter is test for existence, before those could be declared previously from shell script
// for sensitivity analysis for example

ind_NLU =0;
ind_NLU_CI = 0; // nexus.leontief, nexus.capital)
ind_NLU_EI = 0; // calibration.nexus.eei.sce)
ind_NLU_CIener = 0; // calibration.nexus.productiveSectors.sce
ind_NLU_l = 0; // nexus.laborProductivity)+
ind_NLU_pi =0; //markup, in nexus.landuse.sce
ind_NLU_CF = 0 ; // =1 for coupling coutfixeint
ind_NLU_ferti = 0;
ind_NLU_bioener=0;

ind_pop=2;
ind_productivity=2;
ind_productivity_st=0;
ind_catchup=2;

//lines to uncomment to calibrate txCaptemp
//auto_calibration_txCap="";
//first_try_autocalib=%f;
// This time we used year_calib_txCaptemp=2; then 4 then 8; without DIinfra changing with GPD, then with DIinfra changing with GDP and 8;
year_calib_txCaptemp=2;
if ~isdef("auto_calibration_txCap")
   auto_calibration_txCap="None";
end

// automatic calibration of the covid shock
if ~isdef("auto_calibration_covid")
   auto_calibration_covid="None";
end

// acount for the covid crisis by defaut but when calibrating txCaptemp
if auto_calibration_txCap<>"None";
   covid_crises_shock = %f;
elseif auto_calibration_covid<>"None"
   covid_crises_shock = %t;
elseif ~isdef("covid_crises_shock")
   covid_crises_shock = %t;
end

// automatic calibration of coal price elasticity
if ~isdef("auto_calibration_coal_prices")
    auto_calibration_coal_prices="None";
end

// switch to run new calibration settings for coal price elasticity + xtax for gas
if ~isdef("ind_new_calib_coal")
    ind_new_calib_coal=%t;
end

if ~isdef("ind_new_calib_gas")
    ind_new_calib_gas=%t;
end

if ~isdef("ind_new_calib_biomass_LR")
    ind_new_calib_biomass_LR=%f;
end

// need to be set to %t for the first step of the auto_calibration_txCap automatic procedure
if ~isdef("first_try_autocalib")
   first_try_autocalib=%f;
end

// run who pass the carbon budget vetting are store in specific folder
if ~isdef("record_vett_carbonbudget")
    record_vett_carbonbudget=%f;
end

//temporary switch for VRE share weights calibration. For now, the share weights' file is generated. Shall be erased when the model will be able to be autocalibrated
if ~isdef('run_calib_weights')
    run_calib_weights =%f;
end

if ~isdef("ssp_fossil")
   ssp_fossil=2;
end

if ~isdef("output_specific_ar6")
   output_specific_ar6=%f;
end

if ~isdef("ind_oscar")
   ind_oscar = 0;
end

no_output_price_carbon=%f;

// parameters describing the evolution of the maxium market share of CS technologies
if ~isdef("tGrowthCCS")
    tGrowthCCS = 8; // number of year for the market share growth period
end
if ~isdef("tMatureCCS")
    tMatureCCS = 8; // number of year to reach maturity after the growth period
end

// limit to the yearly injection rate of CCS to 2GtCO2 / yr (if =1)
// in practice we allow only beccs
if ~isdef("ind_limCCS_InjRate")
    ind_limCCS_InjRate=0;
end


if ~isdef("scenario_oil_MSMO")
    scenario_oil_MSMO=0;
end

// BECCS technology
if ~isdef("startLearningDateBIGCC")
    startLearningDateBIGCCS = 9; //2025
end

//exo_pkmair_scenario=1;
// exogenous demand on aviation private mobility
// if true, requires to define and drive DFair_exo
if ~isdef("exo_pkmair_scenario")
    exo_pkmair_scenario = 0; // 0 for False; stricly positive value correspond to different scenarios
end

// increase low carbon fuel in the mix for aviation (>=1)
if ~isdef("ind_aviation_LCF")
    ind_aviation_LCF = 0;
end


////// DEMAND-SIDE variants

// MACRO indexes which monitor big demand-side variants

if ~isdef("ind_sufficiency")
ind_sufficiency = 0; // Variant monitoring the options regarding sufficiency: 0 = default (initially in the trunk); 1 = sufficient variant; 2 = BAU or non-sufficient variant
end

if ~isdef("ind_efficiency")
	ind_efficiency = 0; // Variant monitoring the options regarding efficiency: 0 = default (initially in the trunk); 1 = efficient variant; 2 = BAU or non-efficient variant
end

if ~isdef("ind_fuelswitching")
	ind_fuelswitching = 0; // Variant monitoring the options regarding fuel switching: 0 = default (initially in the trunk); 1 = high fuel switching ; 2 = BAU or low fuel switching
end

// SUFFICIENCY options and their use
// Cap of the size of dwelling, especially in global North (when value = 1)
if ~isdef("ind_buildingsufficiency")
    ind_buildingsufficiency = 0;
end

//  decreases the share of expenditure dedicated to transport (-0.8%/yr) & increase the occupancy rate in cars (+1%/yr)// NAVIGATE - task 3.5
if ~isdef("ind_transportsufficiency")
    ind_transportsufficiency = 0;
end

//  implementation of a set of change in transport infrastructures policies
if ~isdef("ind_polInfra")
    ind_polInfra = 0;
end

// reduces terrestrial fret transport in climate policy scenarios only (A for Activity) // NAVIGATE - task 3.5
if ~isdef("ind_roadFret_A")
    ind_roadFret_A = 0;
end

// reduces speed in shipping (A for Activity) // NAVIGATE - task 3.5
if ~isdef("ind_shipFret_A")
    ind_shipFret_A = 0;
end

//EFFICIENCY options and their use
//  speeds up energy efficiency improvements in dwellings // NAVIGATE - task 3.5
if ~isdef("ind_buildingefficiency")
    ind_buildingefficiency = 0;
end

//  speeds up (or slows down) energy efficiency improvements in transport // NAVIGATE - task 3.5
if ~isdef("ind_transportefficiency")
    ind_transportefficiency = 0;
end

// improves energy efficiency of ships (I for Improve) // NAVIGATE - task 3.5
if ~isdef("ind_shipFret_I")
    ind_shipFret_I = 0;
end

// improves energy efficiency for trucks (I for Improve) // NAVIGATE - task 3.5
if ~isdef("ind_roadFret_I")
    ind_roadFret_I = 0;
end

// FUEL SWITCHING OPTIONS and their use

// electrification of other transport
if ~isdef("ind_OT_electrification")
    ind_OT_electrification = 0;
end

// electrification of air and shipping sectors
if ~isdef("ind_shipping_air_electri")
    ind_shipping_air_electri = 0;
end

// electrification of ldv
if ~isdef("indice_ldv_electri")
indice_ldv_electri = 0
end

// electrification of the building sector
if ~isdef("indice_building_electri")
    indice_building_electri = 0;
end



/////////


// year when the climate policy starts
if ~isdef("start_year_policy")
    start_year_policy = 2020;
end
// year when the climate policy strenghten (weak policies until 2025)
if ~isdef("start_year_strong_policy")
    start_year_strong_policy = 2026;
end
// year when the climate policy starts for road fret
if ~isdef("start_year_roadFretI")
    start_year_roadFretI = start_year_strong_policy;
end
// year when the recycling of carbon revenues starts
if ~isdef("start_year_recycl2")
    start_year_recycl2 = start_year_strong_policy;
end
if ~isdef("start_year_recycl1")
    start_year_recycl1 = start_year_strong_policy;
end

// CCS in industrial sector by default
if ~isdef("ind_CCS_industrie")
    ind_CCS_industrie=1;
end

// limit on nuclear: no more than today's level + no new construction after 2030
if ~isdef("ind_lim_nuke")
    ind_lim_nuke = 0;
end

// use differentied regional carbon prices 
if ~isdef("ind_lindhal")
    ind_lindhal = 0;
end
year_convergence_reg_tax=2050; // if ind_lindhal = 1

// Nearly full electrification in industry (=2)
// more electrification (=1), according to IPCC AR6 results (Fig. 3.26 WG3 report)
// as in Imaclim v1 (=0)
if ~isdef("ind_electrification_indu")
    ind_electrification_indu=0;
end

// High variable renewable share
if ~isdef("ind_high_VRE")
    ind_high_VRE = 0;
end

//index to prevent the model from using synfuel CTL coal-to-liquid
//if this index is set to one then there is no synfuel in the runs
//if not, the model uses the representation of CTL with the parameters defined in the study
if ~isdef("ind_NO_CTL")
    ind_NO_CTL=1;
end

//Rustine to run the 2001 combi (strigent climate pol): reduce gas prices
ind_test_gas_price=%f;

//Rustine to run baseline: no update on hydro avail factor
ind_hydro_upd=%f;

// NPi/INDC diagnostic

if ~isdef("ind_npi_ndc")
    ind_npi_ndc = 0; //1 for NPi, 2 for NDC
end

if ~isdef("ind_npi_ndc_effort")
    ind_npi_ndc_effort = 1; //0 = constant CO2 price after 2030, 1 for "continuation of efforts" = CO2 grow at natural GDP's rate
end

// WACC dummies for the electricity sector
//By default, discount factor are regional and techno specific 
if ~isdef('ind_uniform_DR')
    ind_uniform_DR =%f; 
end

if ~isdef("ind_global_wacc")
    ind_global_wacc = 0; //global WACC paper
    //case 0 : using IMACLIM-R own assumption about the WACC
    //case 1 for global WACC, no convergence nor learning
    //case 2 for global WACC + convergence
    //case 3 for global WACC + learning
end

// running climate finance scenarios
if ~isdef("ind_climfin")
    ind_climfin = 0;
    ind_climfin_inc = 0;
end

 // running climate policy uncertainty & credibility study scenarios and associated switches
 if ~isdef("ind_climpol_uncer")
    ind_climpol_uncer=0;
end

// looking for net zero?
if ~isdef("ind_nz")
    ind_nz =0;
end

//cap on CO2 prices, when using standardized tax profiles?
if ~isdef("cap_CO2_price")
    cap_CO2_price =0;
end

// climate impact
// climate impacts on labor productivity
if ~isdef("ind_impacts")
    ind_impacts = 0;
end
// climate sensitivity
if ~isdef("ind_clim_sensi")
    ind_clim_sensi = 1;
end

// labor market rigidity
if ~isdef("ind_labour")
    ind_labour = 0;
end

// a temporary switch to keep previous results before actknowledging new changes in the wacc module.
if ~isdef("ind_new_calib_wacc")
    ind_new_calib_wacc = %t;
end
// temporary switch to remove inertia on the markup for the electricity sector
if ~isdef("ind_in_markup_elec")
    ind_in_markup_elec=%t;
end
//sensibility analysis on the logit exponent in the main logit node of the investment module - electricity nexus. 
// some weights_ENR.tsv need to be generate first (takes 5 min to do it manually)
if ~isdef("ind_logit_sensib_VRE")
    ind_logit_sensib_VRE=%f;
end

//indice for carbon revenues recycling scheme
if ~isdef("ind_recycl")
    ind_recycl=0;
end

// exogenous afforestation scenario
if ~isdef("ind_exo_afforestation")
    ind_exo_afforestation=0;
end

// output a diagnostic .xls for scenario exploration
if ~isdef("tool_output_diagnostic")
    tool_output_diagnostic=%f;
end

// assumptions for development lifestyles
if ~isdef("ind_develo")
    ind_develo = 1;
end

// assumption for energy efficiency
if ~isdef("ind_EEI")
    ind_EEI = 0;
end

// armingont elasticities
if ~isdef("ind_trade")
    ind_trade = 0;
end

// lower trade elasticities for agriculture (if ==1)
if ~isdef("ind_trade_agri")
    ind_trade_agri = 0;
end

// assumption on coal price elasticitie
if ~isdef("ind_charbo")
    ind_charbo = 1;
end

// alternative liquid fuels but biofuels, i-e CTL
if ~isdef("ind_altern")
    ind_altern = 1;
end

// Technological evolution
if ~isdef("ind_techno") // TODO check if obsolete, and which variant is optimistic/pessimistic
    ind_techno = 1;
end

// carbon price expectations (0 = myopic, the carcon price is assumed by agent to remain constant)
if ~isdef("ind_expectations")
    ind_expectations = 0;
end
