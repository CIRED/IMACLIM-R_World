// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thomas Le Gallic, Thibault Briera, Yann Gaucher, Ruben Bibas, Céline Guivarch
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//Sommaire
//Tous les fichiers qui s'occupent de faire du combi->parametre ont étés regroupés ici.
//Cette feuille est divisée en quatre chapitres
// PARAMETRES d'IMACLIM-R                       (parametres indépendants de combi)
// COMBI TO BIG PARAMETERS PART                 (eg, combi donne ind_techno donne ind_car_opt)
// BIG PARAMETERS TO SMALL PARAMETERS PART      (eg, ind_car_opt donne des valeurs numériques a des parametres)
// EXOGENOUS EMISSIONS PART                     (for emission constrained scenarios)

exec(STUDY+"default_parameters.sce");

/////////////////////////////////////////////////////////////////////////////
//	Paramètres d'IMACLIM-R
/////////////////////////////////////////////////////////////////////////////

i_year_strong_policy = start_year_strong_policy - base_year_simulation +1;
start_year_policy=2020; 
ind_inequality = 1;
ind_navigateWP3 = 0; // Here is a switch to reproduce the scenarios submitted for the NAVIGATE task 3.5 MIP. Must be 1 to reproduce this result. The only change is in calibration.growthdrivers.sce (we have targeted lower GDP growth to align with the trajectories of our partners). 
begin_rebalance_K=start_year_policy+1 -base_year_simulation;

//begin_rebalance_K = 1; // start date to re-balance local capital markets
ind_NLU_sensit = 0;
ind_NLU = 0;
do_calibrateNoutput_NLU = %f;
ind_hydrogen = 0;
ind_beccs = 1;
k_expt=[3];

new_Et_msh_computation = 0; // account for CO2 content for liquids market share attribution in the static equilibrium

// Tax_max et taxmin dans res_dyn_loop: limitent les variations de la taxe d'une année à l'autre
cff_taxmax = 0.2;
cff_taxmin = 0.8;
taxmax_val = 80;

scenario_BAU = 1;
scenario_REF = 1;
recyclage_sigma = 0;
sigmaMin = -0.9;
ind_zeroBN = 0;

///////définition des Nexus
NEXUS_indus = 0;
NEXUS_automobile_elast = 0;
NEXUS_automobile_techno = 1;
NEXUS_resid_endogene = 0;

if NEXUS_automobile_elast==1&NEXUS_automobile_techno==1
    disp("problem NEXUS automobile");
    pause;
end

///////Spécificités 'contenu de la croissance en transport'
cont_trans_fixed=1;
cont_trans_AEEI=0;
contTransCstCostsShare=0;

///////Spécificités progres technique dans le secteur electrique
TC_elec_endo=1;
TC_elec_ATC_pol=0;
///////Spécificités progres technique pour l'EEI sectorielle induite par la taxe
TC_EEI_decarb_endo=1;

///////Spécificités progres technique pour les batiments TBE
TC_TBE_endo=1;

/////Variantes ONERC
indice_E=1;
indice_A=0;
indice_B1=0;

//IEW
//optimisme technologique
indice_tech_cars=0;
indice_tech_OT=0;
indice_tech_AEEI=0;
indice_tech_resid=0;
//style de developpement sobre
indice_dvpt_DFindus=0;
indice_dvpt_OT=0;
if indice_dvpt_OT==1
    cont_trans_fixed=0;
    cont_trans_AEEI=1;
    contTransCstCostsShare=0;
end
indice_dvpt_cars=0;

////EDF
scenario_DETENTE=0;

// Nexus Elec)
ind_redistrNegativeEmiss    = 1; // 0 means that negative emissions are attributed to the agriculture sector & 1 to electric sector
ind_exogenousBiomassMax     = 0; // by default, no limit to Qbiomass
ind_MSHBioSup               = 0;
ind_CIimpRefAgriElecNul     = 1; // 0 means original hybridation values, 1 means CIdomref = CIdomref + CIimpref & CIimpref = 0;
ind_elecItgCstDecrease      = 1; // 0 means constant intangible costs, 1 means decreasing by elecItgCstDecreaseRate per year
elecItgCstDecreaseRate      = 0.1;
shareBiomassTaxElec         = 0.2;

// Nexus Gaz
gamma_charge_gaz = 0.3;
gamma_ress_gaz = 2;
obj_charge_gaz = 0.8;

// Nexus Coal
gamma_charge_coal = 0.3;
gamma_ress_coal = 2;
obj_charge_coal = 0.8;
ind_coal_ress = 0; //ind_coal_ress = 0 means pessimistic case ("low" resources, used in EMF24 2nd round study), ind_coal_ress = 1 means optimistic case (higher resources)

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//               COMBI TO BIG PARAMETERS PART
//
////////////////////////////////////////////////////////////////////////////////////////////////////////


// Get scenario indices values from 'combi'
ind_sc_values = combi2indices(combi);
//Here we have: ssp _ (column of modified parameter) _ (IF param != savings: total effect (1) or individual effect (0) OR if param==savings: ind_savings)_ (w/(2) or w/o (0) damages) 


// Get scenario indices names
ind_sc_names = mgetl(STUDY+"matrice_"+ETUDE+".csv",1);
ind_sc_names = strsubst(ind_sc_names,"//","");
ind_sc_names = strsplit(ind_sc_names,";");
// Assign value for each scenario names
for i=1:size(ind_sc_values,"c")
    execstr(ind_sc_names(i+1) + "=ind_sc_values(i)"); 
end 

ind_climat = 0;
ind_clim_refForBau= 1;
ind_ENR=1;
ind_expectations=0;
pol_infra=0;//inutile ?
ind_recycl=0;
ind_lindhal=0;
ind_lim_nuke=0;
ind_limCCS_InjRate=0;
ind_high_VRE=0;
indice_LED=0;

// a business as usual scenario is defined in IMACLIm as a scenario that can run by its own, without an associated baseline
// This concerne the reference scenario without policy (ind_climat==0), the NPi policies (ind_climat==1) and the NDC policies (ind_climat==2)
is_bau = (ind_climat==0) | (ind_climat==1) | (ind_climat==2);

baseline_combi = switch_indice_in_combi(combi,[ 1 7 9 13 14 15 16 17 18] ,[ ind_clim_refForBau 0 0 0 0 0 0 0 0]); //1: first indice is ind_climat, ind_clim_refForBau is it's baseline value

myopicCombi    = switch_indice_in_combi(combi,   [ 7 9 ]   , [ 0 0 ] );
if ind_climat > 550
    myopicCombi = switch_indice_in_combi(myopicCombi,1,550);
elseif (ind_climat < 550)&(ind_climat > 450);
    myopicCombi = switch_indice_in_combi(myopicCombi,1,450);
end

//autres indices, valeurs forcees
if ~isdef("ind_CCS")
    ind_CCS=0; // dummy for CCS market share development options
end

if ~isdef('ind_oilandMO')
    ind_oilandMO = 1;
end

if ~isdef('ind_charbo')
    ind_charbo = 1;
end

if ~isdef('ind_NUC')
    ind_NUC=1;
end

if ~isdef('ind_bioEnergy')
    ind_bioEnergy=1;
end
if ~isdef('ind_develo')
    ind_develo=1;
end
ind_altern = 1;

ind_techno = 1;

//RUN_NAME
run_name=combi2run_name(combi);
ind_fossil = ind_oilandMO;

if ~isdef('ind_gaz_opt')
    ind_gaz_opt=ind_fossil;
end

if ~isdef('ind_oil_opt')
    ind_oil_opt=ind_fossil;
end
if ~isdef('ind_vdv_opt')
    ind_vdv_opt=ind_fossil;
end

if ~isdef('ind_dmo_opt')
    ind_dmo_opt=ind_fossil;
end
 
if ~isdef('ind_coa_opt')
    ind_coa_opt=ind_charbo;
end
if ~isdef('ind_straMO')
    if ind_oilandMO == 2
        ind_straMO = 1;
    else
        ind_straMO = 0;
    end
end

if isdef('ind_ssp_fossil')
    select ind_ssp_fossil
    case 1
        ind_straMO=0;
        ind_dmo_opt=0;
        ind_vdv_opt=1;
    case 2
        ind_straMO=0;
        ind_dmo_opt=1;
        ind_vdv_opt=1;
    case 3
        ind_straMO=1;
        ind_dmo_opt=1;
        ind_vdv_opt=2;
    end
end

if isdef('ind_ssp_EEI')
    select ind_ssp_EEI
    case 1
        ind_EEI=1;
    case 2
        ind_EEI=2;
    case 3
        ind_EEI=3;
    end
end

//regroupement des indices
//if ind_oilandMO == 2
//    ind_straMO = 1;
//else
//    ind_straMO = 0;
//end

// marchés des autres énergies fossiles
//ind_gaz_opt = ind_fossil;//1 ou autre
//ind_oil_opt = ind_fossil;//2 ou autre
//ind_vdv_opt = ind_fossil;//2 ou autre
//ind_dmo_opt = ind_fossil;//0 ou autre
//ind_coa_opt = ind_charbo;//0 ou 1


//ind_cox_opt = ind_fossil;//inutile
//ind_gax_opt = ind_fossil;//inutile

//Décarbonisation de l'élec
ind_nuc_opt = ind_NUC;
ind_enr_opt = ind_ENR;
ind_lre_opt = ind_ENR;
ind_cst_opt = ind_ENR;
ind_cen_opt = ind_ENR;
ind_seq_opt = ind_CCS;
if ~isdef("ind_seq_beccs_opt") // always limit the market share of bioenergy with CCS, but with different rates:
    ind_seq_beccs_opt = 1; 
end
ind_exogenousBiomassMax = 1-ind_bioEnergy;
ind_MSHBioSup           = 1-ind_bioEnergy;

//Supply of alternative biofuels
if ~isdef("ind_biofuel")
    ind_biofuel = ind_bioEnergy;
end
ind_biofuel = ind_bioEnergy;
ind_bio_opt = ind_biofuel;
ind_sbc_opt = ind_biofuel;
ind_ctl_opt = ind_altern;

//Evolution des technologies
ind_frt_opt = ind_techno;
ind_lrt_opt = ind_techno;
ind_bau_opt = ind_techno;
ind_ela_opt = ind_techno; // reféfinit indice_tech_OT
ind_lifeind = ind_techno; //duree vie capital dans industrie

//Styles de développement
ind_igm_opt = ind_develo;
ind_asp_opt = ind_develo;
ind_msp_opt = ind_develo;
ind_res_opt = ind_develo;
ind_hdf_opt = ind_develo;
// bâtiments

if ind_asp_opt==1
    asp_cff=[100;100;100;60;100;70;70;70;70;70;70;70];
else
    asp_cff=[100;100;100;60;100;80;80;80;80;80;80;80];
end; //asymptote surface rédisentielle des PVD

if ind_msp_opt==1
    msp_cff=[1;1;0.3;0.3;0.3;0.3;0.3;0.3;0.3;0.3;0.3;0.3;1];
else
    msp_cff=[1;1;0.3;0.3;0.5;0.8;1;1;1;1;0.8;1;0];
end; //élasticité revenu de la croissance du stock de bâtiments et indicatrice d'utilisation de la fonction de réaction

if ind_res_opt==1  //Rajouté à partir de scenar_Total_12 : disparition du pétrole dans le résid
    i_decoupl_oil_res=10;
    p_decoupl_oil_res=1000;
else
    i_decoupl_oil_res=20;
    p_decoupl_oil_res=1300;
end

if ind_hdf_opt==1
    hdf_cff = [ 1.2;1.2;1.2;1.2;2;2;2;2;2;2;2;2];
else
    hdf_cff = [ 1.5;1.5;1.5;1.5;3;3;3;3;3;3;3;3];
end; //niveau de saturation demande finale des ménages

//Stratégie du MO
ind_prf_opt = ind_straMO;

//From demand-side macro-variants to options(NAVIGATE)

if ind_sufficiency == 1 | indice_LED >=1 // Variant monitoring the options regarding sufficiency: 0 = default (initially in the trunk); 1 = sufficient variant; 2 = BAU or non-sufficient variant
    ind_shipFret_A = 1; // reduce speed in shipping (A for Activity) // NAVIGATE - task 3.5
end

if ind_sufficiency == 1 // Variant monitoring the options regarding sufficiency: 0 = default (initially in the trunk); 1 = sufficient variant; 2 = BAU or non-sufficient variant
    ind_roadFret_A = 1; // reduce terrestrial fret transport in climate policy scenarios only (A for Activity) // NAVIGATE - task 3.5
    ind_buildingsufficiency = 1; // Cap of the size of dwelling, especially in global North
    ind_transportsufficiency = 1; //  Decreases the share of expenditure dedicated to transport (-0.8%/yr) & increase the occupancy rate in cars (+1%/yr)// NAVIGATE - task 3.5
    //ind_polInfra = 1; //  Implement a set of change in transport infrastructures policies, notably in favor of public transport (but not only) // Removed from here as it is defined in standard combi
elseif ind_sufficiency == 2 // Variant for scenarios G. Dabbaghian 
    ind_buildingsufficiency = 2; // Cap of the size of dwelling, especially in global North
    ind_transportsufficiency = 2;  // Decreases the share of expenditure dedicated to transport  & increase the occupancy rate in cars (+1%/yr)
    ind_sufficiency_indus = 1; // Decreases the share of expenditure dedicated to industrial consumption and caps it
end


if ind_efficiency == 1 | indice_LED >=1 // Variant monitoring the options regarding efficiency: 0 = default; 1 = efficient variant. Note that some default assumptions have been changed (slower energy efficiency improvements in aviation and cars, lower max extra renovation rate in the residential sector) since the first runs of NAVIGATE.
    ind_shipFret_I = 1; // improve energy efficiency of ships (I for Improve) // NAVIGATE - task 3.5
end

if ind_efficiency == 1 // Variant monitoring the options regarding efficiency: 0 = default; 1 = efficient variant. Note that some default assumptions have been changed (slower energy efficiency improvements in aviation and cars, lower max extra renovation rate in the residential sector) since the first runs of NAVIGATE.
    ind_buildingefficiency = 1; //  speeds up energy efficiency improvements in dwellings // NAVIGATE - task 3.5
    ind_transportefficiency = 1; //  speeds up energy efficiency improvements in aviation and cars (ICE & BEV) sectors // NAVIGATE - task 3.5
    ind_roadFret_I = 1; // improve energy efficiency for trucks (I for Improve) // NAVIGATE - task 3.5
end

if ind_fuelswitching == 1 // Variant monitoring the options regarding fuel switching: 0 = default; 1 = efficient variant. Note that a default assumption have been changed (more pessimistic electrification of low energy standards in buildings) since the first runs of NAVIGATE.

    ind_OT_electrification = 1; // electrification of other transport
    ind_shipping_air_electri = 1; // electrification of air and shipping sectors
    indice_building_electri = 1; // electrification of the building sector
    indice_ldv_electri = 1; // speeds up electrification of LDV (i.e. cars)

end

if indice_LED >=1
    same_EEI_agroCons_as_ind = %t;
    ind_exogenous_forcings = %t;
    // reference scenario for pIndEner
    ldsav("pIndEner_sav","",baseline_combi) ;
    pIndEner_refLED = pIndEner_sav;
else
    same_EEI_agroCons_as_ind = %f;
end

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//      BIG PARAMETERS TO SMALL PARAMETERS PART
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

// limit to the yearly injection rate of CCS to 2GtCO2 / yr (if =1)
// in practice we allow only beccs
if ind_limCCS_InjRate==1
    ind_NO_CTL=1;
    ind_CCS_industrie=0;
end

select ind_expectations
case 0 //constant carbon price projection, using current tax as the best proxy for future taxes
    typ_anticip = "cst"; 
case 1 // perfect forecast on future carbont taxes
    typ_anticip = "priceSignal";
case 2 // perfect forecast on future carbont taxes, tax applied in dynamic modules only
    typ_anticip = "priceSignalonly";
case 3 // perfect forecast on future carbont taxes starting in 2020, myopia until 2020
    typ_anticip = "priceSignal_2020";
else
    error("Unknown ind_expectations");
end


//politiques climatiques: objectif et recyclage
//0: on rend tout au menages. 1: on baisse Qtax pour rendre aux secteurs ce qu'ils paient. 2: on baisse les taxes sur le salaire
ind_quota  = 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////****************         Commerce international     *******************/////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//pour après 2012: variantes sur la mondialisation
if ~isdef("ind_trade")
    ind_trade = 0;
end
select ind_trade
case 0 // forte mondialisation, baseline Imaclim
    etaArmington=3;
    ETA=3;
case 1 // faible mondialisation
    etaArmington=1.1;
    ETA=5;
else
    error("Unknown ind_trade");
end

///////////////////////////// Offre de biens énergétiques fossiles///////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////****************             Petrole                *******************/////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

if ind_oil_opt == 2
    oil_cff = 1.1;
    heavy_cff = 1.8;
    vdc_cff = 0.061;
    txCapMOmax = 0.8; //txCapMOmax=1.2;
else
    oil_cff=1.1;
    heavy_cff=2;
    vdc_cff=0.061;
    txCapMOmax=0.7;
end //coefficient multiplicateur des réserves

if ind_vdv_opt==2
    vdv_cff=0.061;
else
    vdv_cff=0.041;
end //pente de la courbe de hubbert pour les non conventionnels


if ind_dmo_opt==0
    dmo_cff = 0.5;
else
    dmo_cff = 0.25;
end  //fraction des réserves restantes à partir de laquelle se déclenche la déplétion

////////////////// Situation marchés autres FF

// gaz
// ind_gaz_opt intervient directement dans dynamic.
// pour apres la desindexation au prix du petrole, on fait comme pour le charbon:

point_equilibre_gaz = 0; //tx de croissance de la prod qui annule le tx de croissance du prix

if ind_gaz_opt == 1
    slope_gas_1 = 1; //elasticité de la croissance du prix à la croissance de la prod si sous point_equilibre_gaz
    slope_gas_2 = 1.5;
else
    slope_gas_1 = 1;
    slope_gas_2 = 4;
end

// charbon

point_equilibre_coal=0; //tx de croissance de la prod qui annule le tx de croissance du prix

select ind_coa_opt
case 0
    slope_coal_1_sc = 1;
    slope_coal_2_sc = 4;
case 1
    slope_coal_1_sc = 1;     //elasticité de la croissance du prix à la croissance de la prod si sous cff_col_price_1
    slope_coal_2_sc = 1.5;   //elasticité de la croissance du prix à la croissance de la prod si sur cff_col_price_1
else
    error("ind_coa_opt is ill-defined");
end




/////////////////////////////// Indépendance énergétique/décarbonisation aisée du secteur électrique/////////////////////////

// nucléaire

if ind_nuc_opt==1
    nuc_cff=0.5;
else
    nuc_cff=0.01;
end; //coefficient multiplicateur des parts de marché maximum de nucléaire par tranches
nuclPrim2Sec = 1; // Conventional value of nuclear yield (usually 0.33, now we take 1)
//pénétration du nucleaire nouvelle generation
Tstart_NND  = ones(reg,1);
Tniche_NND  = 15*ones(reg,1);
Tgrowth_NND = 75*ones(reg,1);
Tmature_NND = 25*ones(reg,1); //lissage de l'asymptote
MSHmax_NND  = 0.3*ones(reg,1);
MSH_NND_sup = zeros(reg,1);

if ind_nuc_opt == 0
    MSHmax_NND = 0.01*ones(reg,1);
end


// High or Low variable renewable share
// driven by the markup costs
// short-terme parameter and long-terem/ policy parameter
if ~isdef("cor_param_SIC_lowflex_st")
    cor_param_SIC_lowflex_st = 0.99286;
end
cor_param_SIC_lowflex_po = 0.75; // parameters for ind_high_VRE==1 after start_year_strong_policy


if isdef("exo_maxmshbiom")
    elecBiomassInitial.MSHBioSup = exo_maxmshbiom;
else
    select ind_MSHBioSup
    case 0
        elecBiomassInitial.MSHBioSup = 0.018;
    case 1
        elecBiomassInitial.MSHBioSup = 0.3;
    else
        error("MSHBioSup is ill-defined");
    end
end

// Maximum growth rate of the market share of BIGCC/BIGCCS (electricity from biomass)
elecBiomassInitial.maxGrowthMSH =  0.02; //0.01;//0.008;

// Parameters for MSH_limit_newtechno (S-shaped curve)
Tstart_biomass  = 9;
Tniche_biomass  = 13;
Tgrowth_biomass = 75;
Tmature_biomass = 8;
MSHmax_biomass  = 1;

if ind_seq_beccs_opt == 2
    Tstart_biomass  = 14;
    Tniche_biomass  = 25;
    Tgrowth_biomass = 20;
    Tmature_biomass = 5;
    MSHmax_biomass  = 0.2;
end

select ind_seq_opt
case 0
    lr_ccs    = 0.05; // learning rate CCS
    tStartCCS = %inf; // year of entry of CCS (both elec and ctl process)
    tNicheCCS = 20;   // year of start of niche phase of CCS (both elec and ctl process)
    mshMaxCCS = 0.01; // maximal market share when fully mature technology
case 1
    lr_ccs    = 0.10;  // learning rate CCS
    tStartCCS = 9;    // year of entry of CCS (both elec and ctl process)
    tNicheCCS = 13;   // year of start of niche phase of CCS (both elec and ctl process)
    mshMaxCCS = 1;    // maximal market share when fully mature technology
case 2 // intermediate case (climate policy uncertainty WP, ongoing work)
    lr_ccs    = 0.10;  // learning rate CCS
    tStartCCS = 9;    // year of entry of CCS (both elec and ctl process)
    tNicheCCS = 5;   // year of start of niche phase of CCS (both elec and ctl process)
    tGrowthCCS = 20;
    tMatureCCS = 5;
    mshMaxCCS = 0.4;    // maximal market share when fully mature technology
else
    error("ind_seq_opt is ill-defined");
end;

// ///////////////////////////// Offre carburants alternatifs ///////////////////////////////////////////////

//biocarburants

if ind_bio_opt == 1
    inert_biofuel=0.75;
else
    inert_biofuel=0.85;
end; //inertie sur les biocarburants

if ind_sbc_opt == 0
    sbc_cff = 0.7;//pessimistic on the supply potential of biofuels
elseif ind_sbc_opt == 2
    sbc_cff = 1.3;//optimistic on the supply potential of biofuels
else
    sbc_cff = 1;//default assumption for the supply curves of biofuels
end; //multiplication factor to biofuel supply curves


//Synfuel Coal-to-Liquids CTL
exogenous_oil_price = %f;


if ind_ctl_opt==1 // There is a limit to CTL production growth if ind_ctl_opt <> 1
    ctl_inert_lag=6; //time lag for CTL production
    margin_CTL=0.3;//margin on top of production cost
    ratio_capital_coal_CTL=1;//ratio between capital cost and coal input cost
    ratio_OM_coal_CTL=1.5;//ratio between O&M costs and coal input cost
    a_CTL=50/100;
    inert_CTL_sh_d=0.95;
    inert_sh_CTL_i=1.15;
    inert_CTL=4/5;
else
    ctl_inert_lag=8;//time lag for CTL production
    margin_CTL=0.4;//margin on top of production cost
    ratio_capital_coal_CTL=1.3;//ratio between capital cost and coal input cost
    ratio_OM_coal_CTL=1.7;//ratio between O&M costs and coal input cost
    a_CTL=20/100;
    inert_CTL_sh_d=0.95;
    inert_sh_CTL_i=1.10;
    inert_CTL=4/5;
end

// ///////////////////////////// Choix technologiques pour les usages finaux///////////////////////////////////////////////

///////////////EEI secteurs industrie, agriculture, construction et composite
// Temps de rattrapage des suiveurs par rapport au leader: plus XRef est grand, plus les suiveurs mettent du temps à rattraper (defines speed of convergence)
XRef = 100 * ones(reg,sec);
// Sensitivity of EEI to energy prices
// Check out the EEI graph to understand this: Energy Efficiency Improvement (EEI) (y-axis) vs. Energy Price Index (PIndEner) (x-axis)

// Sets the slope of EE improvement (lea = leader; lag = laggards)
cff_PiE_aeei_lea = 1/2; // bottom left point of EEI graph (default value: 1/2)
cff_PiE_max_lea  = 6; //  right point of EEI graph e.g. reducing this parameter would increase the sensitivity of EEI to prices but would mean that the maximum level is reached sooner. (default value: 6)
cff_PiE_aeei_lag = 1/2; //Defines the threshold (PindEnerKsAEEI) of PindEner  below which catchup rate is minimal. bottom left point of EEI graph (default value: 1/2)
cff_PiE_max_lag = 6; //Defines the threshold (PindEnerMax) of PindEner above which catchup rate is maximal.top right point of EEI graph (default value: 6) 

// Sets the initial and final level of EEI on the EEI graph (on the y-axis, high EEI corresponds to low X)
cff_aeei_lea   = 1/2; // min leader evolution speed compared to reference (for low prices)
cff_min_lea    = 4; //   max leader evolution speed compared to reference (for high prices)
cff_X_aeei_lag = 3;     // Change of catchup-rate between PindEner = PindEnerAEEI (where catchup rate is maximal) & PindEner = pIndEnerRef (where catchup rate is 1/Xref)
cff_X_min_lag = 1/5;    // Change of catchup-rate between PindEner = pIndEnerRef & PindEner = PindEnerMax (where catchup rate is maximal)

select ind_EEI
case 0
    cff_lea  = 0.9971; //(1-cff_lea) = exogenous EEI rate of the leader at fixed energy prices
    max_eei  = 1;
    max_aeei = 1;
    cff_y    = 0.5;
    fin_lev  = 0.85;
case 1
    cff_lea  = 0.98; //(1-cff_lea) = exogenous EEI rate of the leader at fixed energy prices
    max_eei  = 1.5;
    max_aeei = 1.5;
    cff_y    = 0.01; //The EEI gap between leader and laggards is multiplied by cff_y after X years (defines speed of convergence: the higher cff_y, the slower the convergence).
    fin_lev  = 0.99; //Final level (share of the leader's EEI) targeted by laggards
case 2
    cff_lea  =0.996;
    max_eei  =1;
    max_aeei =1;
    cff_y    =0.45;
    fin_lev  =0.9;
case 3
    cff_lea  = 1; //No energy efficiency improvement.
    max_eei  = 0.9;
    max_aeei = 0.9;
    EI_comp_boost=1;
    cff_y    = 0.6;
    fin_lev  = 0.80;
else
    error("ind_EEI is ill-defined");
end;


///////////////////////// Usages captifs (pétrochimie et transports)

//automobiles

ind_cars_hyd = 0;

//fret

if ind_frt_opt==1
    frt_cff=ones(1,TimeHorizon+1);
else
    frt_cff=[1. 1.0058757 1.011578 1.017107 1.0224625 1.0276447 1.0326534 1.0374888 1.0421508 1.0466394 1.0509546 1.0550964 1.0590649 1.0628599 1.0664816 1.0699299 1.0732048 1.0763063 1.0792344 1.0819891 1.0845704 1.0869784 1.0892129 1.0912741 1.0931619 1.0948763 1.0964173 1.0977849 1.0989792 1.1 1.1];
    for tt=31:TimeHorizon+1
        frt_cff(tt)=1.1;
    end
end //coefficient multiplicateur des consommations énergétiques du secteur OT

if ind_ela_opt==1
    indice_tech_OT=1; //coeff déjà existant qui augmente elast_Et_OT
end //elasticités prix des conso spécifiques de pétrole dans les secteurs

// ///////////////////////////// Style de développement////////////////////////////////////////////////////////

//automobiles

if ind_igm_opt==1
    igm_cff=[1; 1 ;1 ;1 ;1 ;1; 1; 1; 1; 1; 1; 1]; //=ones(reg,1);
else //igm_cff=[1; 1 ;1 ;1 ;1 ;1.5; 1.5; 1.5; 1.5; 1.5; 1.5; 1.5];
    igm_cff=[1; 1 ;1 ;1 ;1 ;1; 1; 1; 1; 1; 1; 1];
end; //coefficient multiplicateur de l'income growth multiplier des PVD

// Residential buildings 

// Residential building demand: three variants are designed, with consistent parameter assumptions

style_dev_res = 0; 
// 0 - Trend-based variant, computed from IEA data for 2010 - 2014 or Deetman et al (2020) estimates. See note / excel file for more details;
// 1 - "Increasing inequalities" variant (between countries), where the increase in developing countries is quite slow and 'saturation' level is high in developed countries;
// 2 - "Rebalancing and convergence" variant (between countries), considering quite optimistic assumptions regarding the construction pace in developing countries.

// "Fuel switching" module: this module leads to move away from liquid fossil fuels in residential if certain oil prices are reached (pdecoupl_oil_res). It occurs in 10 or 20 years (i_decoupl_oil_res)
if ind_res_opt==1  // Added from "scenar_Total_12" in Imaclim-R V1
    i_decoupl_oil_res=10;
    p_decoupl_oil_res=1300;
else
    i_decoupl_oil_res=20;
    p_decoupl_oil_res=2000;
end

if ind_sufficiency_indus == 1 // Caps industrial consumption of household in volume
    hdf_cff_lds = 0.001.*ones(reg,nb_sectors_industry); // a bit lower than median value of DF_indus_percap_max of usual scenarios (see code in update_xsi)
else
    hdf_cff_lds = zeros(reg,nb_sectors_industry); //need to define a value that will not be used for the moment because we call it in update_xsi.
end

//////////////////////// Labour market flexibility
/// wage-unemployment curve elasticity
select ind_labour
case 0
    ew = -0.55;
case 1
    ew = -1;
case 2
    ew = -2;
case 3
    ew = -0.2;
end

////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////***COMPORTEMENT DES AGENTS ET POLITIQUES CLIMATIQUES***////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

//////// Comportement de l'OPEP
if ind_prf_opt == 1
    prf_cff = 40; // prix visé par le Moyen Orient
    txCapMOmax = txCapMOmax+0.1; //On augmente la croissance des ses capacités s'il vise un prix bas.
else
    prf_cff=100;
end

///////// Politiques d'infrastructure

select ind_polInfra
case 0
    ETC_infra_fret=0;
    ETC_infra_pass=0;
    year_ETC_infra_pass=19;
    year_ETC_infra_fret=19;
    rate_decoupl_OTT_ETC = - 0.003 * ones(reg,sec); // decoupling freight and transport (-0.3% / year)
case 1
    ETC_infra_fret=1;
    ETC_infra_pass=1;
    year_ETC_infra_pass=max(9,i_year_strong_policy);
    year_ETC_infra_fret=max(9,i_year_strong_policy);
    rate_decoupl_OTT_ETC = - 0.006 * ones(reg,sec);
end

// exogenous scenario of aviation demand
if exo_pkmair_scenario>0
    select exo_pkmair_scenario
    case 1
        sc_exo_air_demand = "REF_SSP2";
    case 2
        sc_exo_air_demand = "1.5C";
    case 3
        sc_exo_air_demand = "1.5C_LD_SSP2";
    case 4
        sc_exo_air_demand = "withCOVID_REF_SSP2";
    case 5
        sc_exo_air_demand = "withCOVID_1.5C_SSP2";
    case 6
        sc_exo_air_demand = "withCOVID_1.5C_GreenPush";
    else
        error("ind_taxFinalLevel is ill-defined");
    end
end

////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////***Carbon revenue recycling***////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

select ind_recycl
case 0
    sc_CO2Tax_recycl="LumpSum";
case 1
    sc_CO2Tax_recycl="RealLumpSum_old";
case 2
    sc_CO2Tax_recycl="LaborTaxReduction_old";
case 3
    sc_CO2Tax_recycl="LaborTaxReduction";
case 4
    sc_CO2Tax_recycl="ProdTaxReduction";
case 5
    sc_CO2Tax_recycl="AdddedValueTaxReduction";
case 6
    sc_CO2Tax_recycl="RealLumpSum Efficient";
case 7
    sc_CO2Tax_recycl="RealLumpSum";
end
