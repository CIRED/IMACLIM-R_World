//Sommaire
//Tous les fichiers qui s'occupent de faire du combi->parametre ont étés regroupés ici.
//Cette feuille est divisée en quatre chapitres
// PARAMETRES d'IMACLIM-R                       (parametres indépendants de combi)
// COMBI TO BIG PARAMETERS PART                 (eg, combi donne ind_techno donne ind_car_opt)
// BIG PARAMETERS TO SMALL PARAMETERS PART      (eg, ind_car_opt donne des valeurs numériques a des parametres)
// EXOGENOUS EMISSIONS PART                     (for emission constrained scenarios)


/////////////////////////////////////////////////////////////////////////////
//	Paramètres d'IMACLIM-R
/////////////////////////////////////////////////////////////////////////////
if ~isdef('TimeHorizon')
    TimeHorizon=99; // warning : the default time horizon is 99 but could be overwritten in STUDY.sce
end
if ~isdef('TimeHorizon')
    TimeHorizon=99; // warning : the default time horizon is 99 but could be overwritten in STUDY.sce
end

new_Et_msh_computation = 1; // account for CO2 content for liquids market share attribution in the static equilibrium
accountforCO2InMarketsha = 1; // account for CO2 content for liquids market share attribution in the static equilibrium
output_specific_ar6=%f;

usd2001_2005=1/0.907;

ind_inequality = 0;

ind_AMPERE_harm = 0;
// Indice utilisé quand on veut harmoniser les PIB pour le projet AMPERE
// Cet indice a pour effet de :
// - Harmoniser les populations totales (calibration.growthdrivers.sce)
// - Harmoniser les taux de croisssance de la population active (calibration.growthdrivers.sce)
// - Prendre les taux de croissance de la productivité du travail (TC_l) qui font coller les PIB réels PPP (calibration.growthdrivers.sce)
// - Diminuer les prix du charbon à court terme (Dynamic.sce)

ind_harm_FE = 0;
// ind_harm_FE = 0: pas d'harmonisation de l'energie finale (cas de WP3 d'AMPERE)
// ind_harm_FE = 1: harmonisation de l'energie finale sur le cas REF (AMPERE)
// ind_harm_FE = 2: harmonisation de l'energie finale sur le cas LOW (AMPERE)

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
cont_trans_AEEI=0;

///////Spécificités progres technique dans le secteur electrique
k_expt=[1:12];
TC_elec_fixed=0;
TC_elec_endo=1;
TC_elec_ATC_pol=0;

///////Spécificités progres technique pour l'EEI sectorielle induite par la taxe
TC_EEI_decarb_endo=1;

///////Spécificités progres technique pour les batiments TBE
TC_TBE_endo=1;

///////Spécificités croissance endogène avec politique
indice_TC_l_endo=0;
indice_ATC_calib_REF=1;
if indice_TC_l_endo==1&indice_ATC_calib_REF==1
    pause;
end

//boucles de test

if TC_elec_ATC_pol==1&TC_elec_endo==1
    pause;
end

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
indice_dvpt_cars=0;
indice_dvpt_OT=0;
if indice_dvpt_OT==1
    cont_trans_AEEI=1;
    contTransCstCostsShare=0;
end

////EDF
scenario_DETENTE=0;

// Nexus Elec
indice_calib_CINV_elec      = 0; // Calibration du progrès technique endogène
ind_recalib_IC              = 0; //recalibartion des couts intangibles (nexus elec)
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

//Simulation d'une excise type TIPP dans les taxes là où les données étaient disponibles
//ajustement_taxes.sce dans WORKDIR joue avec ça (recomended value is %t)
imaNewTaxes = %t;

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//               COMBI TO BIG PARAMETERS PART
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

// * default values
ind_polInfra = 0;

// Get scenario indices values from 'combi'
ind_sc_values = combi2indices(combi);
// Get scenario indices names
ind_sc_names = mgetl(STUDY+"matrice_"+ETUDE+".csv",1);
ind_sc_names = strsubst(ind_sc_names,"//","");
ind_sc_names = strsplit(ind_sc_names,";");
// Assign value for each scenario names
for i=1:size(ind_sc_values,"c")
    execstr(ind_sc_names(i+1) + "=ind_sc_values(i)"); 
end

if (combi==13991) | (combi == 13992)
    ind_cellulosicFuels=0
end

// for ind_beccs , ind_cellulosicFuels , ind_hydrogen
// 1 = yes 0 = no  2 = With 100% higher cost   3 = not before 2050

// for ind_bioenerLimit
// 1 = yes 0 = no

is_bau = (ind_climat==0);
baseline_combi = switch_indice_in_combi(combi,[ 1 9 10 12 13 14 15 16 18 19] ,[0 0 0 0 1 1 1 0 0 0]); //1: first indice is ind_climat, 0 is it's baseline value

if ind_oscar >=2
  ind_aff=ind_oscar-1;
else
  ind_aff=0;
end


myopicCombi    = switch_indice_in_combi(combi,   [ 7 8 9 ]   , [ 0 0 0 ] );
if ind_climat > 550
    myopicCombi = switch_indice_in_combi(myopicCombi,1,550);
elseif (ind_climat < 550)&(ind_climat > 450);
    myopicCombi = switch_indice_in_combi(myopicCombi,1,450);
end

// ind_behavior : define behavioral, comportment style.. 1 is the baseline, 2 is the case of laxist behabior taken in the branches/ssp_2 scenarios, 0 for soberty
if ~isdef("ind_behavior")
	ind_behavior = 1;
end 

//autres indices, valeurs forcees
ind_oilandMO = 1;
ind_charbo = 1;
ind_altern = 1;
if ind_behavior==0
	ind_develo = ind_behavior;
else 
	ind_develo=1;
end
ind_VE = 1;
ind_techno = 1;

//RUN_NAME
run_name=combi2run_name(combi);

//regroupement des indices
ind_fossil = ind_oilandMO;
if ind_oilandMO == 2
    ind_straMO = 1;
else
    ind_straMO = 0;
end


// marchés des autres énergies fossiles
ind_gaz_opt = ind_fossil;
ind_gax_opt = ind_fossil;
ind_coa_opt = ind_charbo;
ind_cox_opt = ind_fossil;
ind_oil_opt = ind_fossil;
ind_vdv_opt = ind_fossil;
ind_dmo_opt = ind_fossil;

//Décarbonisation de l'élec
ind_nuc_opt = ind_NUC;
ind_enr_opt = ind_ENR;
ind_lre_opt = ind_ENR;
ind_cst_opt = ind_ENR;
ind_cen_opt = ind_ENR;
ind_seq_opt = ind_CCS;
ind_exogenousBiomassMax = 1-ind_bioEnergy;
ind_MSHBioSup           = 1-ind_bioEnergy;

//Offre de carburants alternatifs
ind_biofuel = ind_bioEnergy;
ind_bio_opt = ind_biofuel;
ind_sbc_opt = ind_biofuel;
ind_ctl_opt = ind_altern;

//Evolution des technologies
ind_lrc_opt = ind_techno;//inutilise?
ind_frt_opt = ind_techno;
ind_pch_opt = ind_techno;//inutilise?
ind_aee_opt = ind_techno;//inutilise?
ind_itx_opt = ind_techno;//inutilise?
ind_lrt_opt = ind_techno;
ind_bau_opt = ind_techno;
ind_ela_opt = ind_techno; // reféfinit indice_tech_OT
ind_car_opt = ind_VE;
ind_lifeind = ind_techno; //duree vie capital dans industrie

//Styles de développement
ind_igm_opt = ind_develo;
ind_asp_opt = ind_develo;
ind_msp_opt = ind_develo;
ind_res_opt = ind_develo;
ind_hdf_opt = ind_develo;

//Croissance
ind_cri_opt = 0; // a un effet si indice_TC_l_endo=0

//Stratégie du MO
ind_prf_opt = ind_straMO;

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//      BIG PARAMETERS TO SMALL PARAMETERS PART
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

select ind_expectations
case 0
    typ_anticip = "cst";
case 1
    typ_anticip = "priceSignal";
else
    error("Unknown ind_expectations");
end

//politiques climatiques: objectif et recyclage
//0: on rend tout au menages. 1: on baisse Qtax pour rendre aux secteurs ce qu'ils paient. 2: on baisse les taxes sur le salaire
ind_quota  = 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////****************         Nexus Land Use     *******************/////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ind_NLU = 1 enable the coupling with the Nexus Land Use. Track ind_NLU in the Imacli-R code to see what it means


if sum(combi==[991,992,993,2991,2992,2993,3991,3992,3993,4991,4992,4993,5991,5992,5993]) >= 1
    alternCostStructBiofuels = %f;
else
    alternCostStructBiofuels = %t;
end

use_taxed_price = %t;
ind_use_CI_bug = %f;
ind_NLU = 1;
do_calibrateNoutput_NLU=%t;
if combi==7
    ind_NLU=0;
    do_calibrateNoutput_NLU=%t;
end

ind_NLU_bioener = 1;
if ~isdef("ind_debug_SC_nlu")
    ind_debug_SC_nlu=%f;
end
if ~isdef("ind_NLU")
	ind_NLU =0;
end
ind_NLU_CI = 0; // nexus.leontief, nexus.capital)
ind_NLU_EI = 0; // calibration.nexus.eei.sce)
ind_NLU_CIener = 0; // calibration.nexus.productiveSectors.sce
ind_NLU_l = 0; // nexus.laborProductivity)+
ind_NLU_pi =0; //markup, in nexus.landuse.sce
ind_NLU_CF = 1 ; // =1 for coupling coutfixeint
ind_NLUhyp = 1;
ind_NLU_fertiFAO = 1;
ind_NLU_force_AG0 = 0;
food_scenario_Im="FAO";

select ind_food
case 0
    food_scenario_Im="FAO";
case 1
    food_scenario_Im="FAO";
case 2
    food_scenario_Im="AG1";
case 3
    food_scenario_Im="AGO";
end

if ~isdef('ind_NLU_bioener')
	ind_NLU_bioener = 0;
end
if ~isdef('ind_NLUhyp')
	ind_NLUhyp = 1; // nexus.landuse, hypothesis of value added share : 0:'fixed margin' 1:'fixed share of labor and profit in added value'
end
if ~isdef('ind_NLU_ferti')
	ind_NLU_ferti = 0; // nexus.landuse, if=1: coupling on gas/coal consumtpion du to fertilizers production (CI)
end
if ~isdef('ind_NLU_fertiFAO')
	ind_NLU_fertiFAO = 0; // nexus.landuse : using in nexus land use FAO (1) or gtap (0) for fertilizer consumption
end
if ~isdef('ind_NLU_force_AG0')
	ind_NLU_force_AG0 = 0; // calibration.nexus.landuse, if =1 : food scenario AG0 instead of FAO for business as usual
end

if combi >= 13
    inertiaShareEt = 4/5;
else
    inertiaShareEt = 1/10;
    inertiaShareEt = 2/3;
end
if combi == 11
    inertiaShareEt = 4/5;
end


if combi == 13
    inertiaShareEt = 5/6;
    inertiaShareEt = 2/3;
    inertiaShareEt_p = 4/5;
    inertiaShareEt_2060 = 9/10;
end
if combi == 12
    inertiaShareEt = 1/2;
end
if combi==16
    inertiaShareEt = 5/6;
end
inertiaShareEt = 4/5;

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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////****************         Growth drivers             *******************/////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cor_2020 = 0.82;
cor_2030 = 0.87;
cor_other = 1;

cor_TCL_emf33 = [ones(9,1); cor_2020*ones(10,1); cor_2030*ones(10,1); cor_other*0.64*ones(10,1); cor_other*0.76*ones(10,1); cor_other*1.34*ones(10,1); cor_other*1.335*ones(10,1); cor_other*1.13*ones(10,1); cor_other*1.08*ones(10,1); cor_other*1.53889*ones(10,1)];
cor_TCL_emf33(20:99,1) = cor_TCL_emf33(20:99,1) * 0.99 ;

ind_ssp = 2;

ind_pop=2;
ind_productivity=2;
ind_productivity_st=0;
ind_catchup=2; 

ind_productivity_leader=ind_productivity;//exogenous trend over time of labor productivity growth in leading country (USA)
ind_productivity_li=ind_catchup;
ind_productivity_mi=ind_catchup;
ind_productivity_hi=ind_productivity;

if ~isdef("ind_ssp")
    ind_growth_drivers = ind_AMPERE_harm;
else
    ind_growth_drivers = 2;
    // labor productivity growth and population growth of ssp
    if ind_ssp==1
        //ind_productivity_leader=2;
        //ind_productivity=2;
        ind_pop=1;
    elseif ind_ssp==2
        //ind_productivity_leader=1;
        //ind_productivity=1;
        ind_pop=2;
    elseif ind_ssp==3
        //ind_productivity_leader=0;
        //ind_productivity=0;
        ind_pop=3;
    elseif ind_ssp==4
        //ind_productivity_leader=0;
        //ind_productivity=0;
        ind_pop=4;
    elseif ind_ssp==5
        //ind_productivity_leader=0;
        //ind_productivity=0;
        ind_pop=5;
    end
end


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////****************         Marche des capitaux     *******************/////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
if isdef("ind_K")
    ind_partExpK = ind_K; // trade balance evolution
else
    ind_partExpK = 0;
end
begin_rebalance_K = 1; // start date to re-balance local capital markets

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
    oil_cff = 1.3;
    heavy_cff = 3;
    vdc_cff = 0.061;
    txCapMOmax = 0.75;
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
    pente_gaz_2 = 0.3;
    pente_gaz_1 = pente_gaz_2;
else
    pente_gaz_1 = 1;
    pente_gaz_2 = 4;
end

// charbon

point_equilibre_coal=0; //tx de croissance de la prod qui annule le tx de croissance du prix

select ind_coa_opt
case 0
    pente_coal_1_sc = 1;
    pente_coal_2_sc = 4;
case 1
    pente_coal_1_sc = 1;     //elasticité de la croissance du prix à la croissance de la prod si sous cff_col_price_1
    pente_coal_2_sc = 1.5;   //elasticité de la croissance du prix à la croissance de la prod si sur cff_col_price_1
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

// ENR
if ind_enr_opt == 1
    enr_cff = 0.45;
else
    enr_cff = 0.2; // 20% max share per year (conservative case base)
end //part de marché maximum des enr , scénario pivot

//pénétration des ENR
Tstart_ENR = 1;
Tniche_ENR = 3;
Tgrowth_ENR = 65;
Tmature_ENR = 25; //lissage de l'asymptote
MSHmax_ENR = 0.5;
MSH_ENR_sup = 0;

if ind_enr_opt
    Tniche_ENR = 2;
    MSHmax_ENR = 0.6;
end

// Learning rate sur les coûts d'investissements des ENR
if ind_lre_opt==1
    lre_cff_wind  = [ 0.07 0.07];
else
    lre_cff_wind  = [ 0.05 0.05];
end

select ind_ENR
case 0
    windAsymptoteCoeff = 1.4;
case 1
    windAsymptoteCoeff = 1;
end

select ind_MSHBioSup
case 0
    elecBiomassInitial.MSHBioSup = 0.8;
case 1
    elecBiomassInitial.MSHBioSup = 0.3;
else
    error("MSHBioSup is ill-defined");
end

// Maximum growth rate of the market share of BIGCC/BIGCCS (electricity from biomass)
elecBiomassInitial.maxGrowthMSH =  0.5; //0.01;//0.008;

// Parameters for MSH_limit_newtechno (S-shaped curve)
Tstart_biomass  = 9;
Tniche_biomass  = 13;
Tgrowth_biomass = 75;
Tmature_biomass = 8;
MSHmax_biomass  = 1;

if ind_cst_opt==1
    cst_cff=[ 800 900];
else
    cst_cff=[ 900 1000];
end; //asymptote sur les coûts totaux d'investissements des ENR

if ind_cen_opt==1
    cen_cff=[0.7 0.8];
    cl_cff=1.4;
else
    cen_cff=[0.6 0.8];
    cl_cff=1.6;
end; //rapport des coûts complets correspondant à la part maximale des ENR dans le parc

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

if ind_sbc_opt == 1
    sbc_cff = 1;
else
    sbc_cff = 0.4;
end; //coefficient multiplicateur des courbes d'offres


//CTL
exogenous_oil_price = %f;


if ind_ctl_opt==1 // borne supérieure à la croissance de la production de CTL si ind_ctl_opt <> 1
    ctl_inert_lag=6; //temps de mise en production du CTL demandé
    margin_CTL=0.3;//marge appliquee au cout de production dans le prix de vente
    ratio_capital_coal_CTL=1;//ratio entre cout en capital et cout en charbon du CTL a l'annee de calibrage
    ratio_OM_coal_CTL=1.5;//ratio entre cout OM et cout en charbon du CTL a l'annee de calibrage
    a_CTL=50/100;
    inert_CTL_sh_d=0.95;
    inert_sh_CTL_i=1.15;
    inert_CTL=4/5;
else
    ctl_inert_lag=8;//temps de mise en production du CTL demandé
    margin_CTL=0.4;//marge appliquee au cout de production dans le prix de vente
    ratio_capital_coal_CTL=1.3;//ratio entre cout en capital et cout en charbon du CTL a l'annee de calibrage
    ratio_OM_coal_CTL=1.7;//ratio entre cout OM et cout en charbon du CTL a l'annee de calibrage
    a_CTL=20/100;
    inert_CTL_sh_d=0.95;
    inert_sh_CTL_i=1.10;
    inert_CTL=4/5;
end

// ///////////////////////////// Choix technologiques pour les usages finaux///////////////////////////////////////////////

///////////////EEI secteurs industrie, agriculture, construction et composite

select ind_EEI
case 1
    cff_lea  = 0.98; //(1-cff_lea) = exogenous EEI rate of the leader at fixed energy prices
    max_eei  = 1.5;
    max_aeei = 1.5;
    cff_y    = 0.01; //Level of EEI gained by the laggards in XRef years (defines speed of convergence)
    fin_lev  = 0.99; //Final level (share of the leader's EEI) targeted by laggards
case 0
    cff_lea  = 0.98685; //(1-cff_lea) = exogenous EEI rate of the leader at fixed energy prices
    max_eei  = 1;
    max_aeei = 1;
    cff_y    = 0.7;
    fin_lev  = 0.85;
else
    error("ind_EEI is ill-defined");
end;
cff_lea =0.98685;

// Temps de rattrapage des suiveurs par rapport au leader: plus XRef est grand, plus les suiveurs mettent du temps à rattraper (defines speed of convergence)
XRef = 100 * ones(reg,sec);
// Sensitivity of EEI to energy prices
// Check out the EEI graph to understand this: Energy Efficiency Improvement (EEI) (y-axis) vs. Energy Price Index (PIndEner) (x-axis)

// Sets the slope of EE improvement (lea = leader; lag = laggards)
cff_PiE_aeei_lea = 1/2; //bottom left point of EEI graph (default value: 1/2)
cff_PiE_max_lea  = 6; //top right point of EEI graph e.g. reducing this parameter would increase the sensitivity of EEI to prices but would mean that the maximum level is reached sooner. (default value: 6)
cff_PiE_aeei_lag = 1/2; //bottom left point of EEI graph (default value: 1/2)
cff_PiE_aeei_lag = 6; //top right point of EEI graph (default value: 6)

// Sets the initial and final level of EEI on the EEI graph (on the y-axis, high EEI corresponds to low X)
cff_aeei_lea   = 1/2; //Initial level (AEEI threshold) bottom left point of EEI graph (default value: 1/2)
cff_min_lea    = 4; //Final level (Max threshold) top right point of EEI graph (default value: 4)

///////////////////////// Usages captifs (pétrochimie et transports)

//automobiles

select ind_hydrogen
case 1
    ind_cars_hyd=1;
case 3
    ind_cars_hyd=1;
case 2
    ind_cars_hyd=1;
case 0
    ind_cars_hyd=1;
end

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

if ind_car_opt==1
    lr_car=0.15;
else
    lr_car=0.07;
end; //Learning rates techno auto


/////////////////////// Usages substituables.

//industrie, services, agriculture : Voir aussi le fichier calibration.fuel.substitution

if ind_aee_opt == 1
    aee_cff=1.25;
else
    aee_cff=1;
end; //coefficient multiplicateur de l'AEEI

if ind_itx_opt==1
    itx_cff=[ 0.08 75 0.025 1];
else
    itx_cff=[ 0.03 60 0.01 0];
end; //[taux d'apprentissage, asymptote sur la réactivité à la taxe, asymptote sur les gains d'efficacité]


//bâtiments

if ind_lrt_opt==1
    lrt_cff=[0.08 1];
else
    lrt_cff=[0.03 0];
end; //learning rate pour la pénétration des bâtiments TBE et indicatrice de la fonction de réaction utilisée

if ind_bau_opt==1
    bau_cff=ones(reg,TimeHorizon+1);
else
    bau_cff=ones(reg,1)*interpln([[1 29 TimeHorizon+1];[1 1.2 1.2]],1:TimeHorizon+1);
end; //coefficient multiplicateur pour les consommations énergétiques unitaires des bâtiments


// ///////////////////////////// Style de développement////////////////////////////////////////////////////////

//automobiles

if ind_igm_opt==1
    igm_cff=[1; 1 ;1 ;1 ;1 ;1; 1; 1; 1; 1; 1; 1]; //=ones(reg,1);
else //igm_cff=[1; 1 ;1 ;1 ;1 ;1.5; 1.5; 1.5; 1.5; 1.5; 1.5; 1.5];
    igm_cff=[1; 1 ;1 ;1 ;1 ;1; 1; 1; 1; 1; 1; 1];
end; //coefficient multiplicateur de l'income growth multiplier des PVD

if isdef("ind_develo_car")
    select ind_develo_car
    case 0
    igm_cff=[1; 1 ;1 ;1 ;1 ;1; 1; 1; 1; 1; 1; 1]; //=ones(reg,1);
    case 1
    igm_cff=0.9*[1; 1 ;1 ;1 ;1 ;1; 1; 1; 1; 1; 1; 1]; //=ones(reg,1);
    case 2
    igm_cff=0.8*[1; 1 ;1 ;1 ;1 ;1; 1; 1; 1; 1; 1; 1]; //=ones(reg,1);
    case 3
    igm_cff=0.7*[1; 1 ;1 ;1 ;1 ;1; 1; 1; 1; 1; 1; 1]; //=ones(reg,1);
    case 4
    igm_cff=0.6*[1; 1 ;1 ;1 ;1 ;1; 1; 1; 1; 1; 1; 1]; //=ones(reg,1);
    end
end


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

////////////////////////Croissance économique

// Crise courte croissance forte VS crise longue croissance molle  ************ATTENTION CHANGEMENT CRISE PLUS FORTE***************
crise = ones(1,TimeHorizon);

if ind_AMPERE_harm == 0 // Les TC_l sont directement modifiés dans AMPERE pour décrire la crise
    if ind_cri_opt == 1 then
        for tt=7:9
            crise(tt) = 0; // la crise dure 2 ans
        end
    else
        for tt=7:12
            crise(tt) = 0; // la crise dure 5 ans
        end
    end
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
    year_ETC_infra_pass=9;
    year_ETC_infra_fret=9;
    rate_decoupl_OTT_ETC = - 0.006 * ones(reg,sec);
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
    sc_CO2Tax_recycl="RealLumpSum";
case 7
    sc_CO2Tax_recycl="RealLumpSum More Efficient";
end

//////////////////////////////////////////////////////////////////////////////
//
//              EXOGENOUS EMISSIONS PART
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// CO2 market parameter NOT TO BE CHANGED

//emission de CO2 en 2001 (tCO2)
//(reg,1). This helps to define objective in "facteur" terms


//////////////////////////////////////////////////////////////////////////////
//  *USER CHOICE* CO2 market OPTIONS
//  USER, READ THIS
//
// *Pleas fill the MKT_ variables as a function of combi
// (in our case, ind_climat is a function of combi, see first line of this sheet,
// you probably want to act similarly. Find out in savedir_lib how, looking for combi2indices)
// *Note that MKT_ variables are used as paremeters of the new_lin_dlog function
// new_lin_dlog function is nicelly DOCUMENTED in ANALYSIS_FUNCTION.sci
// *Never forget other ways of defining an emissions' objective are possible
//////////////////////////////////////////////////////////////////////////////

//nb de "marches" carbonne differents
nbMKT=1;

//In which market is each (region,sector)
whichMKT_reg_use = ones(reg,nb_use); //here everything is in the market 1. Use this to control global emissions.

// for each MKT, is it emissions-constrained?
is_quota_MKT = zeros(1,nbMKT);
// for ech MKT, is its carbon price constrained?
is_taxexo_MKT = zeros(is_quota_MKT);

MKT_start_year = %nan * zeros(is_quota_MKT);

startExo = 10;
ind_taxFinalLevel = 0; // default
select ind_taxFinalLevel
case 0
    taxParams.finalLevel     =    0 * ones(nbMKT,1) * 1e-6 ;
case 1
    taxParams.finalLevel     = 1000 * ones(nbMKT,1) * 1e-6 ;
case 2
    taxParams.finalLevel     = 2000 * ones(nbMKT,1) * 1e-6 ;
case 3
    taxParams.finalLevel     = 300 * ones(nbMKT,1) * 1e-6 ;
case 4
    taxParams.finalLevel     = 100 * ones(nbMKT,1) * 1e-6 ;
else
    error("ind_taxFinalLevel is ill-defined");
end
taxParams.slopeParameter = 20;
taxParams.duration       = 50;
taxParams.endTime        = TimeHorizon+1+taxParams.duration;
taxParams.priceSignal    = zeros(nbMKT,taxParams.endTime);
// exponential profile
taxParams.priceSignal(:,startExo:taxParams.endTime) = ..
(ones(nbMKT,1) * exp( (startExo:taxParams.endTime) ./ taxParams.slopeParameter )) ..
./ exp( (taxParams.endTime) ./ taxParams.slopeParameter ) ..
.* ( taxParams.finalLevel * ones(1,taxParams.endTime - startExo + 1));
// tanh profile
taxParams.priceSignal(:,startExo:taxParams.endTime) = ..
taxParams.finalLevel / 2 ..
.* ( ones(nbMKT,1) * tanh(((1:taxParams.endTime-startExo+1)-50)/35) ) ..
+ taxParams.finalLevel / 2 * ( 1 - tanh((1-50)/35) - 1) ;

if ind_climat~=0 & ind_climat~=2 & ind_expectations == 1
    ldsav("taxMKT_sav","",myopicCombi);
    myopicTax = taxMKT_sav;
    taxParams.priceSignal(:,1:TimeHorizon+1) = myopicTax;
    taxParams.priceSignal(:,TimeHorizon+2:taxParams.endTime) = myopicTax(:,$) * cumprod( 1.08 * ones(1,taxParams.duration) ) ;
end

no_output_price_carbon=%t;

if ~is_bau // case 0 is the baseline

    //CONSTRUCTION DES TRAJECTOIRES OBJECTIF
    ldsav("E_reg_use_sav","",baseline_combi) ;
    CO2_base = sum(E_reg_use_sav,"r");

    //ldsav("realGDP_sav","",baseline_combi);
    //GDP_base= realGDP_sav;
    ldsav("GDP_PPP_constant_sav","",baseline_combi); //AMPERE
    GDP_base_PPP_constant= GDP_PPP_constant_sav; //AMPERE

    ldsav("GDP_MER_real_sav","",baseline_combi); //AMPERE
    GDP_base_MER_real= GDP_MER_real_sav; //AMPERE


    ldsav("energyInvestment_sav","",baseline_combi);
    energyInvestment_base= energyInvestment_sav;

    ldsav("DF_sav","",baseline_combi);
    ldsav("pArmDF_sav","",baseline_combi);
    ldsav("sigma_sav","",baseline_combi);
    ldsav("qtax_sav","",baseline_combi);
    ldsav("Ttax_sav","",baseline_combi);
    base_DF = zeros(reg,sec,TimeHorizon+1);
    base_pArmDF = zeros(reg,sec,TimeHorizon+1);
    base_sigma = zeros(reg,sec,TimeHorizon+1);
    base_qtax = zeros(reg,sec,TimeHorizon+1);
    base_Ttax = zeros(reg,sec,TimeHorizon+1);
    for year = 1:TimeHorizon+1
        base_DF(:,:,year) = matrix(    DF_sav(:,year),12,12);
        base_pArmDF(:,:,year) = matrix(pArmDF_sav(:,year),12,12);
        base_sigma(:,:,year) = matrix(sigma_sav(:,year),12,12);
        base_qtax(:,:,year) = matrix(qtax_sav(:,year),12,12);
        base_Ttax(:,:,year) = matrix(Ttax_sav(:,year),12,12);
    end

    select ind_climat
    case 2
        //is_quota_MKT = %f;
        //is_taxexo_MKT = 1;
        select ind_taxexo //Diagnostics d'AMPERE
        case 1
            //AM3HD1
            taxMKTexo = [interpln([ 1 9 ; 0 0],(1:9)) 11.3*(1.04^((10:TimeHorizon+1)-10))]*1e-6;
        case 2
            //AM3HD2
            taxMKTexo = interpln([ 1 9 10 TimeHorizon+1; 0 0 45.3 45.3],(1:TimeHorizon+1))*1e-6;
        case 3
            //AM3HD3
            taxMKTexo = [interpln([ 1 9 ; 0 0],(1:9)) 45.3*(1.04^((10:TimeHorizon+1)-10))]*1e-6;
        case 4
            //AM3HD4
            taxMKTexo = interpln([ 1 9 10 TimeHorizon+1; 0 0 181.3 181.3],(1:TimeHorizon+1))*1e-6;
        case 5
            //AM3HD5
            taxMKTexo = [interpln([ 1 9; 0 0],(1:9)) interpln([ 10 45; 181.3 181.3],(10:45)) 45.3*(1.04^((46:TimeHorizon+1)-10))]*1e-6;
        case 6
            //AM3HD6
            taxMKTexo = [interpln([ 1 9; 0 0],(1:9)) interpln([ 10 45; 45.3 45.3],(10:45)) 11.3*(1.04^((46:TimeHorizon+1)-10))]*1e-6;
        case 7
            //AM3HD7 (jump)
            taxMKTexo = interpln([ 1 9 10 45 46 TimeHorizon+1; 0 0 45.3 45.3 181.3 181.3],(1:TimeHorizon+1))*1e-6;
        case 8 // benchmark for exogenous taxes
            nbMKT=2;
            //In which market is each (region,sector)
            whichMKT_reg_use        = ones(reg,nb_use); //here everything is in the market 1. Use this to control global emissions.
            whichMKT_reg_use(ind_usa,:) = 2;
            nbMKT = 2;
            is_quota_MKT   = falses(nbMKT,1);
            MKT_start_year = 3 *ones(nbMKT,1);
            is_taxexo_MKT  = trues(nbMKT,1);
            taxMKTexo      = zeros(nbMKT,TimeHorizon+1);
            taxMKTexo(1,:) = linspace(0,100,TimeHorizon+1)*1e-6;
            taxMKTexo(2,:) = linspace(0,200,TimeHorizon+1)*1e-6;
        case 9
        no_output_price_carbon=%t;
        // copenhagen pledges
	nbMKT=7;
        //Definition des marches
        whichMKT_reg_use(:)=7;  //Le marché 7 est defini par exclusion: no carbon price
        whichMKT_reg_use([ind_usa],:)=1; 
		whichMKT_reg_use([ind_eur ind_jan],:)=2; 
        whichMKT_reg_use([ind_chn],:)=3; 
		whichMKT_reg_use([ind_ras],:)=4; 
		whichMKT_reg_use([ind_ral],:)=5; 
		whichMKT_reg_use([ind_can],:)=6; 
		is_quota_MKT = [%f;%f;%f;%f;%f;%f;%f];
		is_taxexo_MKT = [%t;%t;%t;%t;%t;%t;%t];
                corr_tax_2020 = 0.5;
                taxMKTexo(1,:)=interpln([ 1 4 14 19 39 TimeHorizon+1; 0 0 0 5 5 5],(1:TimeHorizon+1)) * corr_tax_2020;
                taxMKTexo(2,:)=interpln([ 1 4 14 19 34 TimeHorizon+1; 0 0 0 5 5 5],(1:TimeHorizon+1)) * corr_tax_2020;
                taxMKTexo(3,:)=interpln([ 1 9 14 19 29 49 TimeHorizon+1; 0 0 0 5 5 5 5],(1:TimeHorizon+1)) * corr_tax_2020;
                taxMKTexo(4,:)=interpln([ 1 14 19 29 49 TimeHorizon+1; 0 0 5 5 5 5],(1:TimeHorizon+1)) * corr_tax_2020;
                taxMKTexo(5,:)=interpln([ 1 14 19 29 34 TimeHorizon+1; 0 0 5 5 5 5],(1:TimeHorizon+1)) * corr_tax_2020;
                taxMKTexo(6,:)=interpln([ 1 14 19 34 TimeHorizon+1; 0 0 5 5 0],(1:TimeHorizon+1)) * corr_tax_2020;
                taxMKTexo(7,:)=interpln([ 1 14 19 TimeHorizon+1; 0 0 5 5],(1:TimeHorizon+1)) ;
		CO2_obj_MKT = ones(nbMKT,TimeHorizon+1)*%nan;
		MKT_start_year = 10*ones(nbMKT,1);	
                taxMKTexo = taxMKTexo *1e-6 / usd2001_2005;
            

            // varying tax for 2020-2100
            // logit profile calibrated on the tax rexpecting the RCP2.6 budget scenario
            // parameters may vary
            nu = 1.02702702703;
            B = 0.149246231156;
            if ~isdef("sensittax_param_date")
                sensittax_param_date = 38;
            end
            if ~isdef("sensittax_param_uplimit")
                sensittax_param_uplimit = 1300;
            end
            tt = linspace(0,99,100);
            tax_logit = sensittax_param_uplimit *1e-6 / usd2001_2005 ./ (1 + exp(-B.*(tt-sensittax_param_date))) .^(1/nu);
            tax_exo_tpt = taxMKTexo(1,:);
            tax_exo_tpt(20) = sensittax_param_date *1e-6 / usd2001_2005;
            // depend on tome horizon
            if TimeHorizon==99
                if isdef('paramy2050')
                    paramy2100 = sensittax_param_uplimit;
                    sensittax_param_uplimit = paramy2050;
                end
            end
            for ii=21:(TimeHorizon+1)
                tax_exo_tpt(ii) =  tax_exo_tpt(ii-1) * (1.0 + sensittax_param_uplimit/1000);
            end
            if TimeHorizon==99
                if isdef('paramy2050')
                for ii=51:(TimeHorizon+1)
                    tax_exo_tpt(ii) =  tax_exo_tpt(ii-1) * (1.0 + paramy2100/1000);
                end
                end
            end
            // 6 years catch up with the logit profil :
            share_tpt = [0.1, 0.3, 0.5, 0.7, 0.9];
            for m=1:nbMKT
                taxMKTexo(m,21:25) = share_tpt .* tax_exo_tpt(21:25) + (1-share_tpt).*taxMKTexo(m,21:25);
                taxMKTexo(m,26:$) = tax_exo_tpt(26:$);
            end
        case 10
            nbMKT = 1;
            is_quota_MKT   = falses(nbMKT,1);
            MKT_start_year = startExo *ones(nbMKT,1);
            is_taxexo_MKT  = trues(nbMKT,1);
            taxMKTexo = zeros( nbMKT, TimeHorizon+1);
            taxMKTexo(1,21) = 20 * 1.03 *1e-6;
            for ii=22:(TimeHorizon+1)
                taxMKTexo(1,ii) =  taxMKTexo(1,ii-1) * 1.03;
            end
            taxMKTexo = taxMKTexo / usd2001_2005;
        case 11
            nbMKT = 1;
            is_quota_MKT   = falses(nbMKT,1);
            MKT_start_year = startExo *ones(nbMKT,1);
            is_taxexo_MKT  = trues(nbMKT,1);
            taxMKTexo = zeros( nbMKT, TimeHorizon+1);
            taxMKTexo(21) = 30 * 1.05 *1e-6;
            for ii=22:(TimeHorizon+1)
                taxMKTexo(1,ii) =  taxMKTexo(1,ii-1) * 1.05;
            end
            taxMKTexo = taxMKTexo / usd2001_2005;
        case 12
        // copenhagen pledges
	nbMKT=7;
        //Definition des marches
        whichMKT_reg_use(:)=7;  //Le marché 7 est defini par exclusion: no carbon price
        whichMKT_reg_use([ind_usa],:)=1; 
		whichMKT_reg_use([ind_eur ind_jan],:)=2; 
        whichMKT_reg_use([ind_chn],:)=3; 
		whichMKT_reg_use([ind_ras],:)=4; 
		whichMKT_reg_use([ind_ral],:)=5; 
		whichMKT_reg_use([ind_can],:)=6; 
		is_quota_MKT = [%f;%f;%f;%f;%f;%f;%f];
		is_taxexo_MKT = [%t;%t;%t;%t;%t;%t;%t];
                corr_tax_2020 = 0.5;
                taxMKTexo(1,:)=interpln([ 1 4 14 19 39 TimeHorizon+1; 0 0 0 5 5 5],(1:TimeHorizon+1)) * corr_tax_2020;
                taxMKTexo(2,:)=interpln([ 1 4 14 19 34 TimeHorizon+1; 0 0 0 5 5 5],(1:TimeHorizon+1)) * corr_tax_2020;
                taxMKTexo(3,:)=interpln([ 1 9 14 19 29 49 TimeHorizon+1; 0 0 0 5 5 5 5],(1:TimeHorizon+1)) * corr_tax_2020;
                taxMKTexo(4,:)=interpln([ 1 14 19 29 49 TimeHorizon+1; 0 0 5 5 5 5],(1:TimeHorizon+1)) * corr_tax_2020;
                taxMKTexo(5,:)=interpln([ 1 14 19 29 34 TimeHorizon+1; 0 0 5 5 5 5],(1:TimeHorizon+1)) * corr_tax_2020;
                taxMKTexo(6,:)=interpln([ 1 14 19 34 TimeHorizon+1; 0 0 5 5 0],(1:TimeHorizon+1)) * corr_tax_2020;
                taxMKTexo(7,:)=interpln([ 1 14 19 TimeHorizon+1; 0 0 5 5],(1:TimeHorizon+1)) ;
		CO2_obj_MKT = ones(nbMKT,TimeHorizon+1)*%nan;
		MKT_start_year = 10*ones(nbMKT,1);	
                taxMKTexo = taxMKTexo *1e-6 / usd2001_2005;
            

            // varying tax for 2020-2100
            tax_exo_tpt = zeros(1,100);
            tax_exo_tpt(21:50) = linspace( 1, sensittax_param_date , 30) * 1e-6;
            tax_exo_tpt(21:50) = linspace( 1, sensittax_param_date , 30) * 1e-6;
            tax_exo_tpt(51:100) = linspace( sensittax_param_date, sensittax_param_uplimit , 50) * 1e-6;
            // 6 years catch up with the logit profil :
            share_tpt = [0.1, 0.3, 0.5, 0.7, 0.9];
            for m=1:nbMKT
                taxMKTexo(m,21:25) = share_tpt .* tax_exo_tpt(21:25) + (1-share_tpt).*taxMKTexo(m,21:25);
                taxMKTexo(m,26:$) = tax_exo_tpt(26:$);
            end
        end
        CO2_obj_MKT = ones(nbMKT,TimeHorizon+1)*%nan;
    case 450
        temp = csvread(STUDY+"trajectories-base.csv");
        temp = csvread(STUDY+"#DATA.EFossil_RCP.2000-2100_5reg0.rcp26_EFF.csv");
        Carbon_molar = 12.0107 ;
        Oxygen_molar = 15.9994 ;
        C_2_CO2 = (Carbon_molar + 2*Oxygen_molar) / Carbon_molar;
        CO2_obj_MKT = [CO2_base(1:9),sum(temp(10:100,:),'c')'*1e9*C_2_CO2];
        MKT_start_year = 10*ones(nbMKT,1);
        is_quota_MKT = ones(nbMKT,1);
    case 451
        temp = csvread(STUDY+"trajectories-base.csv");
        CO2_obj_MKT = [CO2_base(1:9),temp(10:100,4)'*1e9];
        MKT_start_year = 10*ones(nbMKT,1);
        is_quota_MKT = ones(nbMKT,1);
    case 452
        temp = csvread(STUDY+"trajectories-base.csv");
        CO2_obj_MKT = [CO2_base(1:9),temp(10:100,5)'*1e9];
        MKT_start_year = 10*ones(nbMKT,1);
        is_quota_MKT = ones(nbMKT,1);
    case 453
        temp = csvread(STUDY+"trajectories-base.csv");
        CO2_obj_MKT = [CO2_base(1:9),temp(10:100,9)'*1e9];
        MKT_start_year = 10*ones(nbMKT,1);
        is_quota_MKT = ones(nbMKT,1);
    case 454
        temp = csvread(STUDY+"trajectories-base.csv");
        CO2_obj_MKT = [CO2_base(1:9),temp(10:100,10)'*1e9];
        MKT_start_year = 10*ones(nbMKT,1);
        is_quota_MKT = ones(nbMKT,1);
    case 455
        temp = csvread(STUDY+"trajectories-base.csv");
        CO2_obj_MKT = [CO2_base(1:9),temp(10:100,11)'*1e9];
        MKT_start_year = 10*ones(nbMKT,1);
        is_quota_MKT = ones(nbMKT,1);
    case 456
        temp = csvread(STUDY+"trajectories-base.csv");
        CO2_obj_MKT = [CO2_base(1:9),temp(10:100,6)'*1e9];
        MKT_start_year = 10*ones(nbMKT,1);
        is_quota_MKT = ones(nbMKT,1);
    case 457
        temp = csvread(STUDY+"trajectories-base.csv");
        CO2_obj_MKT = [CO2_base(1:9),temp(10:100,13)'*1e9];
        MKT_start_year = 10*ones(nbMKT,1);
        is_quota_MKT = ones(nbMKT,1);
    case 3 // benchmark for constrained emissions
        testingExplo = ones(1,100);
        testingExplo([ 3 5 6 9 10 11 15 16 17 18]) = 0.9;
        testingExplo([ 4 7 8 12 13 14 19 20     ]) = 1.2;
        CO2_obj_MKT = CO2_base .* testingExplo;
        MKT_start_year = 10*ones(nbMKT,1);
        is_quota_MKT = ones(nbMKT,1);

    case 550
        temp = csvread(STUDY+"trajectories-base.csv");
        CO2_obj_MKT = [CO2_base(1:9),temp(10:100,3)'*1e9];
        MKT_start_year = 10*ones(nbMKT,1);
        is_quota_MKT = ones(nbMKT,1);
    case 551
        temp = csvread(STUDY+"trajectories-base.csv");
        CO2_obj_MKT = [CO2_base(1:9),temp(10:100,7)'*1e9];
        MKT_start_year = 10*ones(nbMKT,1);
        is_quota_MKT = ones(nbMKT,1);
    case 552
        temp = csvread(STUDY+"trajectories-base.csv");
        CO2_obj_MKT = [CO2_base(1:9),temp(10:100,8)'*1e9];
        MKT_start_year = 10*ones(nbMKT,1);
        is_quota_MKT = ones(nbMKT,1);
    case 553
        temp = csvread(STUDY+"trajectories-base.csv");
        CO2_obj_MKT = [CO2_base(1:9),temp(10:100,12)'*1e9];
        MKT_start_year = 10*ones(nbMKT,1);
        is_quota_MKT = ones(nbMKT,1);
    case 8
        nbMKT=3;
        //Definition des marches
        whichMKT_reg_use(:)=2;  //Le marché 2 est defini par exclusion
        whichMKT_reg_use([ind_usa ind_can ind_eur ind_jan],:)=1; //Group I: OCDE
        whichMKT_reg_use([ind_mde ind_cis],:)=3; //Group III

        //Emisisons de la baseline
        CO2_base=MKT_base_emis(whichMKT_reg_use);

        MKT_start_year = 10*ones(nbMKT,1);
        is_quota_MKT = [1;1;0];
        is_taxexo_MKT=zeros(is_quota_MKT);
        //ldsav("realGDP_sav","",baseline_combi);
        //GDP_base= realGDP_sav;
        ldsav("GDP_PPP_constant_sav","",baseline_combi);
        GDP_base_PPP_constant= GDP_PPP_constant_sav;

        CO2_base_reg=zeros(reg,TimeHorizon+1);
        for k=1:reg
            CO2_base_reg(k,:)=sum(sgv(E_reg_use_sav,k,:),"r");
        end

        //marché 3: GroupeIII--> pas contraint
        CO2_obj_MKT (3,:)=%inf.*CO2_base(3,:) ;

        //marché 1: GroupeI--> reduction de 80% par rapport à 2005 en 2050, puis -2% par an
        oecd=[1:4];
        CO2_obj_MKT (1,1:11)=CO2_base(1,1:11);
        CO2_obj_MKT (1,12:45)=interpln([12 45;  sum(CO2_base(1,11)) 0.2*0.7732194*sum(CO2_base(1,5))],(12:45));//le coeff 0.7732194 représente la croissance des émissions mondiales entre 1990 et 2005
        for j=46:TimeHorizon+1
            CO2_obj_MKT (1,j)=0.98*CO2_obj_MKT (1,j-1);
        end

        //marché 2: GroupeII--> différence pour reduction de 50% par rapport à 2005
        gpe2=[ind_chn;ind_ind;ind_bra;ind_afr;ind_ras;ind_ral];
        //pledges de copenhague: on réduit par rapport à la baseline les émissions en chn, inde et bra pour lesquels on a un obj clair
        red_intensity_2020_CHN=0.45;
        red_intensity_2020_IND=0.25;
        red_absolu_2020_BRA=0.1;

        //niveaux en 2020
        Emissions_Group2_2020=sum(CO2_base_reg([ind_afr;ind_ras;ind_ral],19),"r")+...  //baselines pour les petits pays
        (1-red_intensity_2020_CHN)*GDP_base_PPP_nominal(ind_chn,19)/GDP_base_PPP_nominal(ind_chn,4)*CO2_base_reg(ind_chn,4)+... //pledges pour les autres
        (1-red_intensity_2020_IND)*GDP_base_PPP_nominal(ind_ind,19)/GDP_base_PPP_nominal(ind_ind,4)*CO2_base_reg(ind_ind,4)+...
        (1-red_absolu_2020_BRA)* CO2_base_reg(ind_bra,19);

        //part de 0 et va au bon pourcentage en 2020
        pourcentreduc=interpln([1 11 19;  0 0 1-Emissions_Group2_2020/CO2_base(2,19)],(1:19  ));
        CO2_obj_MKT (2,1:19)=(1-pourcentreduc).*CO2_base(2,1:19);

        //objectif de 50% sur l'ensemble des groupes I et II pour la période 2020-2050

        CO2_obj_MKT_1et2= interpln([20 50; sum(CO2_obj_MKT(1:2,19)) 0.5*0.7732194*sum(CO2_base(1:2,5))],(20:50 ));
        CO2_obj_MKT(2,20:50)=CO2_obj_MKT_1et2-CO2_obj_MKT(1,20:50);

        for j=50:TimeHorizon+1
            CO2_obj_MKT(2,j)=CO2_obj_MKT(2,j-1)*0.98;
        end

    case 1 //muddling through. On fait 1 marché pour chaque région du groupe II
        nbMKT=7;
        is_quota_MKT = ones(nbMKT,1);
        is_taxexo_MKT=zeros(nbMKT,1);
        is_quota_MKT(7,1)=0;

        MKT_start_year = 10*ones(nbMKT,1);
        MKT_start_year(7) = %nan;

        whichMKT_reg_use([ind_usa ind_can ind_eur ind_jan],:)=1; //Group I
        whichMKT_reg_use([ind_chn],:)=2; //Group II
        whichMKT_reg_use([ind_ind],:)=3; //Group II
        whichMKT_reg_use([ind_bra ind_ral],:)=4; //Group II
        whichMKT_reg_use([ind_afr],:)=5; //Group II
        whichMKT_reg_use([ind_ras],:)=6; //Group II
        whichMKT_reg_use([ind_mde ind_cis],:)=7; //Group III
        CO2_base=MKT_base_emis(whichMKT_reg_use);
        CO2_base_reg=zeros(reg,TimeHorizon+1);
        for k=1:reg
            CO2_base_reg(k,:)=sum(sgv(E_reg_use_sav,k,:),"r");
        end
        //ldsav("realGDP_sav","",baseline_combi) ;
        //GDP_base= realGDP_sav;
        ldsav("GDP_PPP_constant_sav","",baseline_combi); 
        GDP_base_PPP_nominal= GDP_PPP_constant_sav;

        ldsav("GDP_MER_real_sav","",baseline_combi);
        GDP_base_MER_real= GDP_MER_real_sav;

        //marché 1: OCDE--> réduction à 50% des émissions de 2005 en 2050 puis décroissance à 2% par an
        oecd=[1:4];
        CO2_obj_MKT(1,1:11)=sum(CO2_base(1,1:11),"r");
        CO2_obj_MKT(1,12:45)=interpln([12 45;  sum(CO2_base(1,11)) 0.5*sum(CO2_base(1,5))],(12:45));
        for j=46:TimeHorizon+1
            CO2_obj_MKT (1,j)=0.98*CO2_obj_MKT (1,j-1);
        end
        //marché 2:Chine-->pledges de copenhague en intensité jusqu'en 2020 puis taux de réduction donné par MERGE par rapport à la baseline, puis 2%
        CO2_obj_MKT(2,1:11)=CO2_base_reg(ind_chn,1:11);
        red_intensity_2020_CHN=0.45;
        CO2_obj_MKT(2,12:19)=interpln([1 8;  CO2_base_reg(ind_chn,11) (1-red_intensity_2020_CHN)*GDP_base_PPP_nominal(ind_chn,19)/GDP_base_PPP_nominal(ind_chn,4)*CO2_base_reg(ind_chn,4) ],(1:8  ));
        pourcentreduc=interpln([1 11 21 31 41 51 61 71 81; 1-(1-red_intensity_2020_CHN)*GDP_base_PPP_nominal(ind_chn,20)/GDP_base_PPP_nominal(ind_chn,4)*CO2_base_reg(ind_chn,4)/CO2_base_reg(ind_chn,20) 0.24	0.32	0.38	0.44	0.47	0.51	0.51	0.51  ],(1:81  ));
        CO2_obj_MKT (2,20:TimeHorizon+1)=CO2_base_reg(ind_chn,20:TimeHorizon+1).*(1-pourcentreduc);
        for j=20:TimeHorizon+1
            if pourcentreduc (j-19) >0.5 then
                CO2_obj_MKT (2,j)=0.98*CO2_obj_MKT (2,j-1);
            end
        end

        //marché 3:Inde-->pledges de copenhague en intensité jusqu'en 2020 puis taux de réduction donné par MERGE par rapport à la baseline, puis 2%
        CO2_obj_MKT (3,1:11)=CO2_base_reg(ind_ind,1:11);
        red_intensity_2020_IND=0.25;
        CO2_obj_MKT (3,12:19)=interpln([12 19;  CO2_base_reg(ind_ind,12) (1-red_intensity_2020_IND)*GDP_base_PPP_nominal(ind_ind,19)/GDP_base_PPP_nominal(ind_ind,4)*CO2_base_reg(ind_ind,4) ],(12:19  ));
        pourcentreduc=interpln([20:10:100; 1-(1-red_intensity_2020_IND)*GDP_base_PPP_nominal(ind_ind,20)/GDP_base_PPP_nominal(ind_ind,4)*CO2_base_reg(ind_ind,4)/CO2_base_reg(ind_ind,20) 0.08	0.17	0.25	0.32	0.4	0.46	0.49	0.51  ],(20:100  ));
        CO2_obj_MKT (3,20:TimeHorizon+1)=CO2_base_reg(ind_ind,20:TimeHorizon+1).*(1-pourcentreduc);
        for j=20:TimeHorizon+1
            if pourcentreduc (j-19) >0.5 then
                CO2_obj_MKT (3,j)=0.98*CO2_obj_MKT (3,j-1);
            end
        end

        //marché 4:Bresil+RAL
        CO2_obj_MKT_marche4=zeros(2,TimeHorizon+1);//la premiere ligne c'est BResil, la deuxi譥 RAL

        //-->pour brésil:pledges de copenhague en absolu jusqu'en 2020 puis taux de réduction donné par MERGE par rapport à la baseline, puis 2%
        CO2_obj_MKT_marche4(1,1:11)=CO2_base_reg(ind_bra,1:11);
        red_absolu_2020_BRA=0.1;
        pourcentreduc=interpln([1 9 19 29 39 49 59 69 79 89; 0 red_absolu_2020_BRA  0.23	0.3	 0.37	0.44	0.51	0.51	0.51	0.51 ],(1:89  ));
        CO2_obj_MKT_marche4(1,12:TimeHorizon+1)=CO2_base_reg(ind_bra,12:TimeHorizon+1).*(1-pourcentreduc);
        for j=20:TimeHorizon+1
            if pourcentreduc (j-19) >0.5 then
                CO2_obj_MKT_marche4(1,j)=0.98*CO2_obj_MKT_marche4(1,j-1);
            end
        end

        //-->RAL:rien jusqu'en 2020 puis taux de réduction donné par MERGE par rapport à la baseline, puis 2%
        CO2_obj_MKT_marche4(2,1:19)=CO2_base_reg(ind_ral,1:19);
        pourcentreduc=interpln([1 11 21 31 41 51 61 71 81; 0   0.19	0.25	0.32	0.37	0.41	0.43	0.45	0.47 ],(1:81  ));
        CO2_obj_MKT_marche4(2,20:TimeHorizon+1)=CO2_base_reg(ind_ral,20:TimeHorizon+1).*(1-pourcentreduc);
        for j=20:TimeHorizon+1
            if pourcentreduc (j-19) >0.5 then
                CO2_obj_MKT_marche4(2,j)=0.98*CO2_obj_MKT_marche4(2,j-1);
            end
        end

        CO2_obj_MKT(4,:)=sum(CO2_obj_MKT_marche4,"r");

        //marché 5:Afrique-->rien jusqu'en 2020 puis taux de réduction donné par MERGE par rapport à la baseline, puis 2%
        CO2_obj_MKT (5,1:19)=CO2_base_reg(ind_afr,1:19);
        pourcentreduc=interpln([1 11 21 31 41 51 61 71 81; 0 0.08	0.10	0.13	0.17	0.23	0.28	0.31	0.34 ],(1:81  ));
        CO2_obj_MKT (5,20:TimeHorizon+1)=CO2_base_reg(ind_afr,20:TimeHorizon+1).*(1-pourcentreduc);


        //marché 6:RAS-->rien jusqu'en 2020 puis taux de réduction donné par MERGE par rapport à la baseline, puis 2%
        CO2_obj_MKT (6,1:19)=CO2_base_reg(ind_ras,1:19);
        pourcentreduc=interpln([1 11 21 31 41 51 61 71 81; 0   0.10	0.18	0.25	0.32	0.37	0.39	0.41	0.43 ],(1:81  ));
        CO2_obj_MKT (6,20:TimeHorizon+1)=CO2_base_reg(ind_ras,20:TimeHorizon+1).*(1-pourcentreduc);
        for j=20:TimeHorizon+1
            if pourcentreduc (j-19) >0.5 then
                CO2_obj_MKT (6,j)=0.98*CO2_obj_MKT (6,j-1);
            end
        end

        CO2_obj_MKT(7,:) = %inf;
    else
        error("ind_climat")
    end
end

//if combi == 17
//    externallyChangedVar.gamma_charge_gaz                 = 0.3;
//    externallyChangedVar.gamma_charge_coal                = 0.3;
//    externallyChangedVar.elecBiomassInitial.maxGrowthMSH  = 0.02;
//    externallyChangedVar.cff_taxmin                       = 0.78;
//    externallyChangedVar.cff_taxmax                       = 0.21;
//elseif combi == 20
//    externallyChangedVar.gamma_charge_gaz                 = 0.3;
//    externallyChangedVar.gamma_charge_coal                = 0.3;
//    externallyChangedVar.elecBiomassInitial.maxGrowthMSH  = 0.02;
//    externallyChangedVar.cff_taxmin                       = 0.79;
//    externallyChangedVar.cff_taxmax                       = 0.2;
//end

if isdef("externallyChangedVar")
    disp(externallyChangedVar);
    for names=fieldnames(externallyChangedVar)'
        if isstruct(evstr("externallyChangedVar."+names))
            disp(evstr("externallyChangedVar."+names))
            for names2=fieldnames("externallyChangedVar."+names)'
                execstr(names +"."+names2 "=externallyChangedVar."+names+"."+names2+";");
            end
        else
            execstr(names + "=externallyChangedVar."+names+";")
        end
    end
end

exec(STUDY+"testStudy.sce");
