// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//NOTE : Meant to be executed before calibration.nexus.productiveSectors.sce, calibration.industry.sce, calibration.eei.sce

//Convention : 
//- agri or agriculture appoint for the aggragated sector, agriculture production and food processing
//- agriRawProd appoint for the agricultural raw production sectors (crop, vegetables and cattle, etc..) without food processing
//- agriFoodProcess appoint for food processing sectors
// agggregation : agri = agriculture = agriRawProd + agriFoodProcess

stacksize(2.5e8); // increase stacksize for the linkage with NLU

// Paths 
exec(MODEL+"pathsNLU.sce");

////////////////////////////////////////////////////
///////////////////////
//Nexus Land Use side
///////////////////////
////////////////////////////////////////////////////

// Initialisation of the nexus land use

//Initialisation + calibration
//set the right directories

biomass_transfo_margin = 1.3;
verbose = 1; // 1 for debugging/coding/coupling with NLU
time_horizon_length=TimeHorizon;

exec(common_codes_dir+"read_csv-5.3.3.sci");
read_csv_file = read_csv_533; // solve a bug occuring with the nexus land-use using read_csv of scilab-5.4.1

exec(codes_dir+"header.sce");

exec(codes_dir+"default_parameter_values.sce");
max_taux_inacc2acc = 0.05;

if isdef("extern_azote_content")
  N_content_pasture=extern_azote_content;
end

if isdef("sensit_bouwmanFalse")
  is_bouwman_evolving = %F;
else
  is_bouwman_evolving = %T;
end

pchi_scenario="Compute";
bioener_scenario="NoScenario";
energy_price_scenario = "NoScenario";
CF_scenario = "NoScenario"; 
if is_bau
    imaclim_scenario = "Baseline";
else
    imaclim_scenario = "450ppm";
end
pop_scenario = "NoScenario";
ethanol_transf_cost_scen = "LinearIncrease" ;
biofuel_scenario="FAO";
ethan2G_transf_cost_scen = "LinearDecrease" ;  // "Constant", "LinearDecrease"
if isdef("agriculture_land_rate")
  forest_scenario="AgriculturalLandIncrease";
else if ind_aff > 0
  forest_scenario="Historical";
else
  forest_scenario="NoScenario";
end

if ind_aff > 0
  land_use_source = "Hurtt";
end

nonDyn_scenario="FAO";
do_force_jint2jint_clb = %F;
do_simultane = %T; 
scenario_taxeC = "NoScenario";
do_bioelec_regional = %T;
bioelec_scenario="NoScenario";

min_crops_prod_ratio = 0.01;

// Hoowijk 2009 table 4
Hoowijk_2000_efficiency = 0.4;
Hoowijk_2000_load = 0.8;
Hoowijk_inv_2000 = 1630; //($2000/kW)
Hoowijk_inv_2050high = 1380; //($2050/kW)
Hoowijk_inv_2050low = 1180; //($2050/kW)
Hoowijk_inv_2050 = (Hoowijk_inv_2050high+Hoowijk_inv_2050low)/2; //($2050/kW)
Hoowijk_2000_OM_percent = 0.04; // OM costs as a per cent of inv costs ($2000/kW)
Hoowijk_2000_lifetime = 20;
kW2gj = 31.556926;
//ethan2G_transfocost_2000 = ( 1 / Hoowijk_2000_efficiency / Hoowijk_2000_load * (Hoowijk_2000_inv / Hoowijk_2000_lifetime + Hoowijk_2000_OM) / kW2gj * tep2gj ; // $/tep
//ethan2G_transfocost_2000 = 14.52 * tep2gj ; // $/tep
//ethan2G_transfocost_2050 = 8.29 * tep2gj ; // $/tep

ethan2G_inv = Hoowijk_inv_2000;
if ~isdef("efficiency_2G_ext")
  ethan2G_efficiency = Hoowijk_2000_efficiency;
else
  ethan2G_efficiency =  efficiency_2G_ext;
end
gj2G_2_gjbiom = 1./ ethan2G_efficiency ;
ethan2G_transfo_cost =  1 / ethan2G_efficiency / Hoowijk_2000_load * ( ethan2G_inv / Hoowijk_2000_lifetime + Hoowijk_2000_OM_percent * ethan2G_inv) / kW2gj * tep2gj ; // $/tep

gjbioelec_2_gjbiom = 1./ 0.4 ;
wp_et_biom_forsight = "forwardlooking" ; // "forwardlooking" | "myopic"
biofuel_costs_NLU = zeros(nb_regions,1);
emi_evitee_hdr = zeros(nb_regions,1);
bioener_costs_Del = zeros(nb_regions,1);
bioener_costs_Farmgate = zeros(nb_regions,1);

// hydrogen transformation by gaseification :   Tock and Marecha 2012
gjh2_2_gjbiom = 1 ./ 0.433;
h2_gaseif_annualInv = 8.3 / usd2001_2005 ; // $2001 / gj H2
h2_gaseif_maintenance = 8.2 / usd2001_2005 ;  // $2001 / gj H2
h2_gaseif_captureCosts = 142.0 / usd2001_2005 ; // $2001 / tCO2 avoided
h2_gaseif_emission = -0.149 ; // tC02 / GJ H2
h2_gaseif_costs = (h2_gaseif_annualInv + h2_gaseif_maintenance) * tep2gj ; // $2001 / tep H2

emi_evitee_hdr_Tauto = alphaHYDauto.*(pkmautomobileref./100) .* mtoe2gj .* h2_gaseif_emission / 1e6;

if ind_NLU_fertiFAO ==1
	use_CI_chi_from_FAO=%T;
else
	use_CI_chi_from_FAO=%F;
end

food_scenario = food_scenario_Im ;
//if ind_NLU_bioener == 1
//	agrofuel_price_scenario = "BiomassTransformation";
//else 
//	agrofuel_price_scenario = "NoScenario";
//end

exec(codes_dir+"complete_input.sce");
exec(codes_dir+"show_header.sce");

//Close all plot windows
if kill_windows then
  kill_all_windows();
end

// Parametrage
printf("_______________ Parameters _________________\n");
exec(codes_dir+"input_data.sce");
GWP_NO2_100=265; // waiting for nlu to set it in defaults instead 
GWP_CH4_100=28; // waiting for nlu to set it in defaults instead


//pcal_eq_agrofuel=pArmDFref(:,indice_Et)' ./ (tep2gj/exa2giga .* Exajoule2Mkcal) ./ biomass_transfo_margin;// test here
if base_year <> 2001
	error("check the nexus land-use code to fix that");
end

////////////////////////////////
///      Calibration         ///
////////////////////////////////
printf("______________ Calibration NLU _________________\n");
exec(codes_dir+"calibration_density.sce");
exec(codes_dir+"calibration_cost.sce");

// output calibration in run_output_dir
exec(codes_dir+"output_calibration.sce");

// initialization of the simulation

exec(codes_dir+"initialization.sce");

///////////////////////
// check calibration
///////////////////////
res_solve_all_result = list();
global res_solve_all_result
exec(codes_dir+"verify_calibration.sce");

//Optionnel si vous voulez creer les memes resultats que l'equipe Nexus
results=[]; //For function create_results
global results results_names results_last_row
global global_results global_results_names





////////////////////////////////////////////////////
///////////////////////
//Nexus Land Use first time step, consistant with Imaclim prices
///////////////////////
////////////////////////////////////////////////////

//Imaclim-R gives the proper variables to the Nexus Land-Use
wnatgas_price =  wpEnerref(indice_gaz);
wlightoil_price = wpEnerref(indice_Et);
reg_taxeC = zeros(1,nb_regions); // ($/tCO2eq)
current_time =0;
previous_time=current_time;
pop = Ltot'; 

// ancitipated production
//prod_cellul_bioener = zeros(nb_regions,1);
//prod_agrofuel = zeros(1,nb_regions);
glob_in_bioelec = 0;
reg_in_bioelec = zeros(nb_regions, 1);
overshoot_wplightoil_ant = 1;
biofeulProdExp_improved = %f;
bioelec_costs_NLU = 1e15* ones(nb_regions,1);
bioelec_costs_NLU_p = bioelec_costs_NLU;
growth_bioelec_costs_p = ones(nb_regions,1);

export_liquids_biomass = ones(nb_regions,1);
import_liquids_biomass = ones(nb_regions,1);
 
profitable_2G =%t;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//First Timestep of Nexus Land-Use///
///////////////////////////////
break_loop = %F; // not realy usefull for Imaclim, just an iniisalization required by NLU
real_failed=%f;
fixed_nlu_startpoint = %f; // if NLU crash, do not change the start point after
limit_on_2G = %f;
limit_on_bioelec = %t;
exportsveg=exportsveg_clb;
exportsrumi=exportsrumi_clb;
importsrumi=importsrumi_clb;
importsveg=importsveg_clb;
if ind_NLU_bioener == 1
    producer_lightoil_price = pref(:,indice_Et) ./ (tep2gj) ;
    //pcal_eq_agrofuel = (pref(:,indice_Et)' ./ (tep2gj) ./ (G2M .* Megajoule2Mkcal) - ethanol_transfo_cost ./ (density_ethanol .* LHV_ethanol .* Megajoule2Mkcal))  ./ (LHV_sugar ./ (LHV_ethanol .* stechiom_ferment_sugar));
     //[dsurfagri_s,importsveg_s, importsrumi_s, density_Dyn_new_s, prod_agrofuel_s, prod_agrofuel_max_s, loc_other_agrof_prod_s]=wdsalimener(pcal_eq_agrofuel, pchi, coutfixeint, prod_agrofuel, jint_prev, jint_smooth_from_dc, density_agri, density_veg_from_dc, density_ML_from_dc, density_P_from_dc, density_ot_in_crops_clb, exportsveg,exportsrumi, surfagri, importsrumi, importsveg, %T);
     //prod_agrofuel = prod_agrofuel_max_s;
end
  exec(codes_dir+"update_forcings.sce");
  exec(codes_dir+"demand_computation.sce");
  string_year=string(base_year+current_time);
  pcalopt_start_point=pcalveg_prev;
  if do_simultane then
    // The computation of exportsveg could be different from the actual
    // exportsveg_prev if capacities are reached.
    //exportsveg_start_point=((coeftrade_veg.*(pcalveg_prev).^(-gamma_veg))./sum((coeftrade_veg.*(pcalveg_prev).^(-gamma_veg)))).*sum(importsveg_prev);
    exportsveg_start_point = exportsveg_prev;
    exportsrumi_start_point = exportsrumi_prev;
  end

  exec(codes_dir+"equilibrium.sce");
  exec(codes_dir+"get_results.sce");
Tot_bioelec_cost_del_pre = Tot_bioelec_cost_del;

//Optionnel timestep
  exec(codes_dir+"verify_equilibrium.sce");
  exec(codes_dir+"create_results.sce");
  if do_write_density_yearly then
    fprintfMat(cur_run_out4density_dir+"density_crop_"+string_year+".csv",density_Dyn_new,'%1.9g;');
    fprintfMat(cur_run_out4density_dir+"density_ML_"+string_year+".csv",density_ML_new,'%1.9g;');
    fprintfMat(cur_run_out4density_dir+"density_P_"+string_year+".csv",density_P_new,'%1.9g;');
    fprintfMat(cur_run_out4density_dir+"density_forest_"+string_year+".csv",density_forest,'%1.9g;');
    fprintfMat(cur_run_out4density_dir+"density_otCrop_"+string_year+".csv",density_otCrops_new,'%1.9g;');
    fprintfMat(cur_run_out4density_dir+"density_remain_"+string_year+".csv",c_density_remain,'%1.9g;');
  end

//timestep, fin
  exec(codes_dir+"end_time_step.sce");

// variables from nexus land-use for the calibration of Imaclim
// the outputs 'Ouput_NLU0' is calculated below, witha correction for process food with the help of GTAP. the following varaibles are given by the nexus land use : pcalveg ,dfoodveg , dotherveg , prod_agrofuel_Dyn, pcalmono, dfoodmonog , pcalrumi , dfoodrumi, exportsveg, wpveg ,  exportsrumi_raw , wprumi, exportsmono_raw, wpcalmono;

LandRent_NLU0 = total_profit'; // land rent
surface_NLU0 = sum(density_Dyn_new, 'c')' .* dsurfagri; // surface used for the agricultural Raw Production sector (ha)
FixCost_NLU0 = surface_NLU0 .* coutfixeint; //fixed cost in the nexus land-use

// fertilizers production
// while waiting for an update (from r 16302)
if ind_NLU_ferti ==1
  if use_CI_chi_from_FAO then
    Q_ferti_NLU0 = consNPK_volume_total'; // variable deleted in the nexus land-use
  else
    Q_ferti_NLU0 = consCI_vol_tot';
  end
end
p_ferti_NLU = pchi';
share_exp_mono_clb=exportsmono_clb./sum(exportsmono_clb);
wpcalmono=pcalmono*share_exp_mono_clb';

//other
verbose = 0;// back to zero (for debugging/coding/coupling with NLU);

////////////////////////////////////////////////////
///////////////////////
//Imaclim side
///////////////////////
////////////////////////////////////////////////////

// Added Value of the agri sector, by unit of production
va_agri = ( EBEref(:,agri)+SALNET(:,agri)+TAXSAL(:,agri) )' ./ (pref(:,agri).*Qref(:,agri)-QTAX(:,agri))';
va_agri_prev = va_agri;

// Loading GTAP datas
gtapDataPathTemp = DATA + 'GTAP/GTAP_land-use/outputs_GTAP/';
sufixGTAP = '_NLUim';
listSector_NLUaggreg = read_csv(gtapDataPathTemp+'Sector.csv','|');
listRegion_NLUaggreg = read_csv(gtapDataPathTemp+'Region.csv','|');
exec(common_codes_dir+"readGtapData.sci");

// list of indices :
listAgriSectors_Ind= [];
agriRawProd_Ind=[];
agriFoodProcess_Ind=[];
for secTemp=['AgriNLU','MonogAnim','RumiAnim','TransImaclim']
	listAgriSectors_Ind($+1) = find(listSector_NLUaggreg==secTemp);
end
for secTemp=['AgriNLU','MonogAnim','RumiAnim']
	agriRawProd_Ind($+1) = find(listSector_NLUaggreg==secTemp);
end
for secTemp=['TransMeat','TransVeg','OtherAgriForest']
	agriFoodProcess_Ind($+1) = find(listSector_NLUaggreg==secTemp);
end
gas_IndNLU = find(listSector_NLUaggreg=='Gas');
coal_IndNLU = find(listSector_NLUaggreg=='Coal');
indus_IndNLU = find(listSector_NLUaggreg=='Indmat');
chemi_IndNLU = find(listSector_NLUaggreg=='Chemistry');
foodveg_raw_Ind = find(listSector_NLUaggreg=='AgriNLU');
foodmonog_raw_Ind = find(listSector_NLUaggreg=='MonogAnim');
foodrumi_raw_Ind = find(listSector_NLUaggreg=='RumiAnim');
transMeat_Ind = find(listSector_NLUaggreg=='TransMeat');
transVeg_Ind = find(listSector_NLUaggreg=='TransVeg');

// intermediate consumption of the agriRawProd sector, GTAP data, (sec,reg) matrix
ICgtap_agriRawProd = reaggGTAP_NLU(sum(CI_imp_NLUim(:,:,agriRawProd_Ind)+CI_dom_NLUim(:,:,agriRawProd_Ind),3)) ;
// intermediate consumption of the agriFoodProcess sector, GTAP data, (sec,reg) matrix
ICgtap_agriFoodProcess = reaggGTAP_NLU(sum(CI_imp_NLUim(:,:,agriFoodProcess_Ind)+CI_dom_NLUim(:,:,agriFoodProcess_Ind),3)) ;
// Aggregate sector intermediate consumption (in value)
ICgtap_agri = ICgtap_agriRawProd + ICgtap_agriFoodProcess;
// Production of the agriRawProd sector, GTAP data, (reg) line vector
Prod_GTAP_agriRawProd = sum(reaggGTAP_NLU(matrix(sum(CI_dom_NLUim(:,agriRawProd_Ind,:),2),size(listRegion_NLUaggreg,'c'),size(listSector_NLUaggreg,'c'))),2)  + sum(C_hsld_dom_NLUim(:,agriRawProd_Ind)  + C_AP_dom_NLUim(:,agriRawProd_Ind) + FBCF_dom_NLUim(:,agriRawProd_Ind) + Exp_trans_NLUim(:,agriRawProd_Ind) + Exp_cor_NLUim(:,agriRawProd_Ind)-T_prod_NLUim(:,agriRawProd_Ind),2);
// Production of the agriFoodProcess sector, GTAP data, (reg) line vector
Prod_GTAP_agriFoodProces = sum(reaggGTAP_NLU(matrix(sum(CI_dom_NLUim(:,agriFoodProcess_Ind,:),2),size(listRegion_NLUaggreg,'c'),size(listSector_NLUaggreg,'c'))),2)  + sum(C_hsld_dom_NLUim(:,agriFoodProcess_Ind)  + C_AP_dom_NLUim(:,agriFoodProcess_Ind) + FBCF_dom_NLUim(:,agriFoodProcess_Ind) + Exp_trans_NLUim(:,agriFoodProcess_Ind) + Exp_cor_NLUim(:,agriFoodProcess_Ind)-T_prod_NLUim(:,agriFoodProcess_Ind),2);
// Aggregate sector intermediate consumption (in value)
Prod_GTAP_agri = Prod_GTAP_agriRawProd  + Prod_GTAP_agriFoodProces;
// Payrol of the agriRawProd sector, GTAP data
PAYgtap_agriRawProd = sum(T_SkLab_NLUim(:,agriRawProd_Ind)+T_UnSkLab_NLUim(:,agriRawProd_Ind)+SkLab_NLUim(:,agriRawProd_Ind)+UnSkLab_NLUim(:,agriRawProd_Ind),2);
// Payrol of the agriFoodProcess sector, GTAP data 
PAYgtap_agriFoodProcess = sum(T_SkLab_NLUim(:,agriFoodProcess_Ind)+T_UnSkLab_NLUim(:,agriFoodProcess_Ind)+SkLab_NLUim(:,agriFoodProcess_Ind)+UnSkLab_NLUim(:,agriFoodProcess_Ind),2);
// aggregated sector 
PAYgtap_agri = PAYgtap_agriFoodProcess + PAYgtap_agriRawProd;
// Profit of the agriRawProd sector, GTAP data
//EBE_GTAP_agriRawProd = Prod_GTAP_agriRawProd - PAYgtap_agriRawProd - sum(ICgtap_agriRawProd,'c'); 
EBE_GTAP_agriRawProd = sum(Capital_NLUim(:,agriRawProd_Ind) + Land_NLUim(:,agriRawProd_Ind) + NatRes_NLUim(:,agriRawProd_Ind),2);
// Profit of the agriFoodProcess sector, GTAP data
//EBE_GTAP_agriFoodProcess = Prod_GTAP_agriFoodProces - PAYgtap_agriFoodProcess - sum(ICgtap_agriFoodProcess,'c');
EBE_GTAP_agriFoodProcess = sum(Capital_NLUim(:,agriFoodProcess_Ind) + Land_NLUim(:,agriFoodProcess_Ind) + NatRes_NLUim(:,agriFoodProcess_Ind),2);
// EBE of aggregated sector
EBE_GTAP_agri = EBE_GTAP_agriRawProd + EBE_GTAP_agriFoodProcess;
// Capital value and land rent of agriRawProd sector
Capitalgtap_agriRawProd = sum(Capital_NLUim(:,agriRawProd_Ind),2);
Landgtap_agriRawProd = sum(Land_NLUim(:,agriRawProd_Ind),2);
ProfitGtap_agriRawProd = Capitalgtap_agriRawProd + Landgtap_agriRawProd;

// agriRawProd sector production disaggregation
// this part calibrate coefficient for distinguing raw and no_raw production (means with the part of food going to the transformation/food-rpocessing sector). It serves to calculate the agriRawProd sector production in value
// coefficients of raw production under all production
coeff_foodveg_raw = sum(C_hsld_dom_NLUim(:,foodveg_raw_Ind)  + C_AP_dom_NLUim(:,foodveg_raw_Ind) + FBCF_dom_NLUim(:,foodveg_raw_Ind)) ./ (sum(C_hsld_dom_NLUim(:,foodveg_raw_Ind)  + C_AP_dom_NLUim(:,foodveg_raw_Ind) + FBCF_dom_NLUim(:,foodveg_raw_Ind))  +  sum(CI_dom_NLUim(:,foodveg_raw_Ind,agriFoodProcess_Ind),3)');
coeff_foodmonog_raw = (sum(C_hsld_dom_NLUim(:,foodmonog_raw_Ind)  + C_AP_dom_NLUim(:,foodmonog_raw_Ind) + FBCF_dom_NLUim(:,foodmonog_raw_Ind)) + sum(CI_dom_NLUim(:,foodmonog_raw_Ind,:),3)' -  sum(CI_dom_NLUim(:,foodmonog_raw_Ind,agriFoodProcess_Ind),3)') ./ (sum(C_hsld_dom_NLUim(:,foodmonog_raw_Ind)  + C_AP_dom_NLUim(:,foodmonog_raw_Ind) + FBCF_dom_NLUim(:,foodmonog_raw_Ind)) + sum(CI_dom_NLUim(:,foodmonog_raw_Ind,:),3)');
coeff_foodrumi_raw = (sum(C_hsld_dom_NLUim(:,foodrumi_raw_Ind)  + C_AP_dom_NLUim(:,foodrumi_raw_Ind) + FBCF_dom_NLUim(:,foodrumi_raw_Ind)) + sum(CI_dom_NLUim(:,foodrumi_raw_Ind,:),3)' -  sum(CI_dom_NLUim(:,foodrumi_raw_Ind,agriFoodProcess_Ind),3)') ./ (sum(C_hsld_dom_NLUim(:,foodrumi_raw_Ind)  + C_AP_dom_NLUim(:,foodrumi_raw_Ind) + FBCF_dom_NLUim(:,foodrumi_raw_Ind)) + sum(CI_dom_NLUim(:,foodrumi_raw_Ind,:),3)');
// coefficients of raw exports under all exports
coeff_meatexp = (Exp_trans_NLUim(:,foodmonog_raw_Ind) + Exp_cor_NLUim(:,foodmonog_raw_Ind) + Exp_trans_NLUim(:,foodrumi_raw_Ind) + Exp_cor_NLUim(:,foodrumi_raw_Ind) ) ./ (Exp_trans_NLUim(:,foodmonog_raw_Ind) + Exp_cor_NLUim(:,foodmonog_raw_Ind)  + Exp_trans_NLUim(:,foodrumi_raw_Ind) + Exp_cor_NLUim(:,foodrumi_raw_Ind) + Exp_trans_NLUim(:,transMeat_Ind) + Exp_cor_NLUim(:,transMeat_Ind));
coeff_vegexp = (Exp_trans_NLUim(:,foodveg_raw_Ind) + Exp_cor_NLUim(:,foodveg_raw_Ind) ) ./ (Exp_trans_NLUim(:,foodveg_raw_Ind) + Exp_cor_NLUim(:,foodveg_raw_Ind) + Exp_trans_NLUim(:,transVeg_Ind) + Exp_cor_NLUim(:,transVeg_Ind));
// coefficients of raw imports under all exports
coeff_vegimp = ( Imp_cor_NLUim(:,foodmonog_raw_Ind) + Imp_cor_NLUim(:,foodrumi_raw_Ind) ) ./ ( Imp_cor_NLUim(:,foodmonog_raw_Ind) + Imp_cor_NLUim(:,foodrumi_raw_Ind) + Imp_cor_NLUim(:,transMeat_Ind));
coeff_meatimp = (Imp_cor_NLUim(:,foodveg_raw_Ind) ) ./ ( Imp_cor_NLUim(:,foodveg_raw_Ind) + Imp_cor_NLUim(:,transVeg_Ind));

// Raw food sector expediture (of Nexus Land Use) production at the base year :
exportsveg_raw = exportsveg .* coeff_vegexp' ;
exportsrumi_raw = exportsrumi .* coeff_meatexp' ; 
exportsmono_raw = exportsmono_clb .* coeff_meatexp' ; // exports doesn't move
importsveg_raw = importsveg .* coeff_vegimp' ;
importsrumi_raw = importsrumi .* coeff_meatimp' ;
importsmono_raw = VolImpMonoRef .* coeff_meatimp' ; // imports doesn't move


ImpRaw_NLU = importsveg_raw.*wpveg+importsrumi_raw.*wprumi+importsmono_raw.*wpcalmono;
ExpRaw_NLU = exportsveg_raw.*wpveg +  exportsrumi_raw.*wprumi + exportsmono_raw.* wpcalmono;
Conso_NLU = pcalveg .* (dfoodveg + dotherveg + prod_agrofuel_Dyn) + pcalmono .* dfoodmonog + pcalrumi .* dfoodrumi;
Ouput_NLU0 = Conso_NLU  + ExpRaw_NLU - ImpRaw_NLU;
impIC_raw2FoodProces_NLU =ImpRaw_NLU./(Conso_NLU  - ExpRaw_NLU) ;
IC_raw2FoodProcess_NLU0 = pcalveg .* (1-coeff_foodveg_raw').*dfoodveg  + pcalmono .* (1-coeff_foodmonog_raw').*dfoodmonog + pcalrumi .* (1-coeff_foodrumi_raw').*dfoodrumi + impIC_raw2FoodProces_NLU;
IC_raw2FoodProcess_Im0 = sum(sum(CI_imp_NLUim(:,agriRawProd_Ind,agriFoodProcess_Ind)+CI_dom_NLUim(:,agriRawProd_Ind,agriFoodProcess_Ind),3),2) ;

// Food Processing sector production
// hypothesis : price of this sector is equal to the agri aggregated sector at the base year
Prod_agriRawProd0 = (pref(:,agri).*Qref(:,agri)) .* Prod_GTAP_agriRawProd ./ (Prod_GTAP_agri+(Prod_GTAP_agri==0)*1 );
Prod_agriFoodProces = (pref(:,agri).*Qref(:,agri)) .* Prod_GTAP_agriFoodProces ./ (Prod_GTAP_agri+(Prod_GTAP_agri==0)*1 );
p_agriFoodProcess = pref(:,agri);
Q_agriFoodProcess = Prod_agriFoodProces ./p_agriFoodProcess ;

// Intermediate Consumption disaggregation
// Intermediate Consumption (calcul of Imaclim disaggregated IC, 'in proportion to' GTAP data, because of original hydrid calibration of Imaclim)
IC_agriRawProd0 = matrix(CItotref(:,agri,:),nb_sectors,nb_regions) .* ICgtap_agriRawProd./( ICgtap_agri+(ICgtap_agri==0)*1 );
IC_agriFoodProcess0 = matrix(CItotref(:,agri,:),nb_sectors,nb_regions) .* ICgtap_agriFoodProcess./( ICgtap_agri+(ICgtap_agri==0)*1 );
// Unitary Intermediate Consumption
alphaIC_agriFoodProcess = IC_agriFoodProcess0 ./ (ones(sec,1)*Q_agriFoodProcess');

// Investment matrix disaggregation
//Like a virgin.. for the moment 

// Markup disaggregation
//(calcul of Imaclim disaggregated EBE, 'in proportion to' GTAP data, because of original hydrid calibration of Imaclim)
EBE_agriRawProd = EBEref(:,agri) .* EBE_GTAP_agriRawProd./( EBE_GTAP_agri+(EBE_GTAP_agri==0)*1 );
Capital_agriRawProd0 = EBE_agriRawProd .* Capitalgtap_agriRawProd ./ (ProfitGtap_agriRawProd+(ProfitGtap_agriRawProd==0)*1 );
Land_agriRawProd0 = EBE_agriRawProd .* Landgtap_agriRawProd ./ (ProfitGtap_agriRawProd+(ProfitGtap_agriRawProd==0)*1 );
EBE_agriFoodProcess = EBEref(:,agri) .* EBE_GTAP_agriFoodProcess./( EBE_GTAP_agri+(EBE_GTAP_agri==0)*1 );
markup_agriFoodProcess = EBE_agriFoodProcess ./ (p_agriFoodProcess.*Q_agriFoodProcess);

// labor productivity and payrol disaggregation
PAY_agriRawProd0 = (SALNET(:,agri)+TAXSAL(:,agri)) .* PAYgtap_agriRawProd ./ ( PAYgtap_agri+(PAYgtap_agri==0)*1 );
PAY_agriFoodProcess = (SALNET(:,agri)+TAXSAL(:,agri)) .* PAYgtap_agriFoodProcess ./ ( PAYgtap_agri+(PAYgtap_agri==0)*1 );
wTax_agri = wref(:,agri).*(1+sigma(:,agri)); // taxable wage of agriRawProd,agriFoodProcess and aggregated agri sector (equality hypothesis)
l_agriFoodProcess = PAY_agriFoodProcess ./ ( Q_agriFoodProcess .*wTax_agri); // inverse of labor productivity for the agriFoodProcess sector
L_agriRawProd0 = PAY_agriRawProd0 ./ wTax_agri; // Full Time Equivaent workers 

// During nexus.landuse.sce, while solving for Q_agriFoodProcess, two hypothesis can e made, each with its one constant :
//Hypothesis 1 : fixed margin : 
   //markup_agriFoodProcess is a constant
//Hypothesis 2 : fixed share of labor and profit in added value :
valueAdded_shares = markup_agriFoodProcess .* p_agriFoodProcess ./ (markup_agriFoodProcess .* p_agriFoodProcess +  PAYgtap_agriFoodProcess ./ Q_agriFoodProcess );
valueAdded_shares_coeff = valueAdded_shares ./ (1-valueAdded_shares);

if ind_NLU_ferti ==1
  // coupling on intermediate consumption of gas into the industrial sector, taking into account fertilizer production
  ICgtap_indus2agriRaw = sum(CI_dom_NLUim(:,indus_IndNLU,agriRawProd_Ind) + CI_imp_NLUim(:,indus_IndNLU,agriRawProd_Ind),3)';
  ICgtap_chemi2agriRaw = sum(CI_dom_NLUim(:,chemi_IndNLU,agriRawProd_Ind) + CI_imp_NLUim(:,chemi_IndNLU,agriRawProd_Ind),3)';
  ICgtap_chiind2agriRaw = ICgtap_indus2agriRaw + ICgtap_chemi2agriRaw;
  Q_ferti_Im0 = matrix(CI(indus,agri,:),nb_regions,1) .* ICgtap_chemi2agriRaw ./ (ICgtap_chiind2agriRaw+(ICgtap_chiind2agriRaw==0)*1 );
  gasInFerti = 28/mtoe2gj* 1e3 ; //(mtoe / Mton of amonia)
  coalInFerti = 42/mtoe2gj* 1e3 ; //(mtoe / Mton of amonia)
  // unitary intermediate consumptions :
  alpha_gas2ferti = gasInFerti*ones(nb_regions,1);
  alpha_coal2ferti_CHN = coalInFerti;
  alpha_gas2indus0ferti = (matrix(CI(gaz,indus,:),nb_regions,1) - alpha_gas2ferti.*Q_ferti_NLU0) ./ (Q(:,indus)-Q_ferti_Im0);  
  alpha_coal2ind0ferti_CHN = (CI(gaz,indus,ind_chn) - alpha_coal2ferti_CHN * Q_ferti_Im0(ind_chn)) ./ (Q(ind_chn,indus)-Q_ferti_Im0(ind_chn));
end


////////////////////////////////////////////////////
///////////////////////
//Imaclim side - re-do the calibration.nexus.capital.sce calibration
///////////////////////
////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
// STEP 1 : the aggricultural sector (food precessing side only)
////////////////////////////////////////////////////////////////

// Capital vintage generations had to be done once with the aggregated sector for the static calibration
// We now redo it to consider vintage generations and unitary CI evolution only for the agriFoodProcess sector

if ind_NLU_CI == 1

dureedevieagriculture=floor(dureedevie(1,indice_agriculture)); // same as the aggregated sector
Capvintageagriculture=zeros(reg,TimeHorizon+1+dureedevieagriculture);
CIvintageagriculture=zeros(sec,reg,TimeHorizon+1+dureedevieagriculture);
nb_vintage_hist=10; // same as the aggregated sector

Cap_agriFoodProcess=Q_agriFoodProcess./UR(:,agri);
txCap_agriFoodProcess = txCaptemp(:,agri);
K_agriFoodProcess=Cap(:,agri);
betaK_agriFoodProcess=betaK(:,agri);
alphaK_agriFoodProcess=Cap_agriFoodProcess./(K_agriFoodProcess.^betaK_agriFoodProcess);
deltaCap_agriFoodProcess =txCap_agriFoodProcess.*Cap_agriFoodProcess;
deltaKnet_agriFoodProces=((Cap_agriFoodProcess+deltaCap_agriFoodProcess).^(ones(reg,1)./betaK_agriFoodProcess)./alphaK_agriFoodProcess)-K_agriFoodProcess;

Cap0agriculture=Cap_agriFoodProcess./(ones(reg,1)+txCap_agriFoodProcess).^(nb_vintage_hist*dureedevieagriculture*ones(reg,1));
Caphistagriculture=zeros(reg,nb_vintage_hist*dureedevieagriculture+1);
construitagriculture=zeros(reg,nb_vintage_hist*dureedevieagriculture);
for k=0:(nb_vintage_hist*dureedevieagriculture)
	Caphistagriculture(:,k+1)=Cap0agriculture.*(ones(reg,1)+txCap_agriFoodProcess).^(ones(reg,1)*k);
end
for k=1:dureedevieagriculture
	construitagriculture(:,k)=(Caphistagriculture(:,k+1)-Caphistagriculture(:,k))+Caphistagriculture(:,k).*delta(:,indice_agriculture);
end
for k=(dureedevieagriculture+1):nb_vintage_hist*dureedevieagriculture
	construitagriculture(:,k)=Caphistagriculture(:,k+1)-Caphistagriculture(:,k)+construitagriculture(:,k-dureedevieagriculture);
end

for k=1:dureedevieagriculture
	Capvintageagriculture(:,k)=construitagriculture(:,k+(nb_vintage_hist-1)*dureedevieagriculture);
	for j=1:reg
		CIvintageagriculture(:,j,k)=alphaIC_agriFoodProcess(:,j); // different from the aggregated
	end
end

end // (if ind_NLU_CI ==1)

//NOTES :
//# Hypothesis : In case of coupling with the Nexus land-use (ind_NLU>0), pIndEnerRef and pIndEner of the agriFoodProcess sector is supposed to be the same as the aggregated agricultural sector (the idea here is that recalculating pArmCI, expected.pArmCI_EEI and pArmCIref for the disaggregated agriFoodProcess sector is too fastidious for the desired indicator)
//# Analogous hypothesis are taken for pArmCI_nexus
//# Energy efficiencies, even on buildings with incitation with the carbon tax, are no longer driven by Imaclim for the pure (agriRawProd) agricultural sector in case of coupling (ind_NLU >0). Energy efficiencies on the agricultural sector is supposed to be a decision rule inside the nexus land-use, independantly of Imaclim (this hypothesis is made for the sake of simplicity of coupling th enexus land-use with Imaclim).
//# In case of coupling with the nexus land-use (ind_NLU > 0), the following variables describe not anymore the agregated agricultural sector (agriculture + food processing), as in usual in Imaclim, but desribes only the food processing sector, which is then reaggregated with the agricultural sector informations coming from the nexus land-use :
//Cap0agriculture
//Caphistagriculture
//construitagriculture
//Capvintageagriculture
//CIvintageagriculture
//CIvintageagriSpec
//CIvintageagriSubs
//CI_Spec
//CI_Subs
//CIagricSpecref
//CIagricSubsref
//CIdeltacompositeSpec(:,indice_agriculture,:)
//CIdeltacompositeSubs(:,indice_agriculture,:)
//l(:,agri)
//# and may be others that are strictly dependent on those variables

// STEP 2 : the chemical consumption of the 
//# The same happen for the CI consumption of gas into the industrial sector... the fertilizer production is dealed apart from Imaclim, so that CI(gas,indus) follow the same rule as Imaclim, except that now it is CI(gas - "gas to produce fertilizers",indus)
// similar 'Notes' as previously for the agricultural sectors (regarding Cap0... CapvintageindSpec.. etc ..) stands

////////////////////////////////////////////////////////////////
// STEP 2 : Same for unitary intermediate consumption of gas (respectively coal for china) into industrial production
////////////////////////////////////////////////////////////////

if ind_NLU_ferti == 1

for k=1:dureedevieagriculture
	for j=1:reg
		if j <> ind_chn
			CIvintageindustrie(:,j,k)=alpha_gas2indus0ferti(j); // different from fertilizers // TODO: should be updated to consider the new name and dimensions of CIvintageindustrie (i.e. CIvintageindustries)
		else
			CIvintageindustrie(:,j,k)=alpha_coal2ind0ferti_CHN; // coal, and not gas for china // TODO: should be updated to consider the new name and dimensions of CIvintageindustrie (i.e. CIvintageindustries)
		end
	end
end

end // (if ind_NLU_chimy ==1)

// bioener
if ind_NLU_bioener ==1
    computeBiomassCost = computeBiomassCost_NLU
end
bioener_costs_NLU = ethan2G_transfo_cost + Tot_bioelec_cost_del .* tep2gj .* gj2G_2_gjbiom;
biofuel1G_costs_NLU  = bioener_costs_NLU;
max_biofuel = %t;

stop_increase_2G=%f;
Q_biofuel_anticip = zeros(nb_regions,1);
Q_biofuel_real = zeros(nb_regions,1);
share_biofuel = zeros(nb_regions,1);
share_biofuel_real = zeros(nb_regions,1);
share_biofuel_prev = share_biofuel;

if ind_aff >0
   step_increase2G = 10 * mtoe2ej * Exajoule2Mkcal * gj2G_2_gjbiom ;
else
   step_increase2G = 50 * mtoe2ej * Exajoule2Mkcal * gj2G_2_gjbiom ;
end

glob_in_bioelec_Elec=0;
glob_in_bioelec_Elecprev=0;
glob_in_bioelec_Hyd=0;
glob_in_bioelec_Hydprev=0;
glob_in_bioelec_Hyd_reg = zeros(nb_regions,1);
glob_in_bioelec_Et_reg  = zeros(1,nb_regions);
w_bioener_costs_Del = 0;
w_bioener_costs_Farmgate = 0;
toomuch_bioener=%f;


//////////////////////////////////////////////
// Intesresting variables to look after
//////////////////////////////////////////////

// pure NLU variables
sg_add(["Wyieldgap" "yield_on_pot_scaled"]);
if use_CI_chi_from_FAO
    sg_add("consNPK_volume");
else
    sg_add("consCI_vol");
end
// coupling variables
sg_add(["delta_surf_NLU"
"Q_agriFoodProcess"
"mkp_agriFood"
"Q_ferti_Im"
"a_gas2ferti"
"a_gas2indus0ferti"
"a_chn_coal2ferti"
"a_chn_coal2ind0ferti"
"l_agriFood"
"delta_FixCost"
"alphaIC_agriFood"
"IC_agriRawProd0"
"p_ferti_NLU"
"deltaRent"]);


list_nlu_prev = [
"unused_other_agrof_prod"
"Prod_energy_crops"
"Modern_bioenergy_cons"
"Prod_ModEnergy_other"
"Prod_ModEnergy_residues"
"reg_Tradi_ener_demand"
"CO2_total_emission"
"NO2_tot"
"CH4_tot"
"Tot_bioelec_cost_del"
"Tot_bioelec_cost"
"W_tot_bioelec_cost"
"W_tot_bioelec_cost_del"
"reg_wood_RW_4Wdem"
"reg_natfor_4Wdem"
"reg_TOF"
"woodfuel_demand"
"reg_net_wood_demand"
"reg_wood_RW_4Ener"
"reg_natfor_4Ener"
"export_ec_biom"
"import_ec_biom"
"Tot_landcover"
"surfcrop_Dyn"
"surfcropnonDyn"
"surf_bioener"
"surfforest"
"Surf_natforest_biom"
"surf_plantation"
"surfforest_prev"
"surfP"
"surfML"
"prod_rumi_ext"
"prod_rumi_ML"
"yield_Dyn"
"pcalveg"
"W_yield_Dyn"
"wpveg"
];
execstr ( list_nlu_prev+"p=" + list_nlu_prev + ";");

//// Afforestation module
surf_aff = zeros(nb_regions,1);
surf_aff_2_increase = zeros(nb_regions,1);
surf_aff_cumulated = zeros(12,1);

select ind_aff
case 1
    albedo_aff_discrim = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
case 2
    albedo_aff_discrim = [0.7, 0, 0.7, 0.3, 0, 0.3, 1, 1, 1, 1, 1, 1];
end
max_potential_aff = csvRead(DATA  + 'Land_use/forest_2012.csv', '|');
max_potential_aff = (max_potential_aff) ./ha2Mha;

if isdef('sensittax_param_uplimit')
    max_aff_peryear=( sensittax_param_uplimit./ha2Mha) * ones(1,nb_regions);//20;
else
    max_aff_peryear=( 10 ./ha2Mha) * ones(1,nb_regions);//20;
end

