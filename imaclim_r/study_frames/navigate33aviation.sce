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
if run_ImaclimR_v1_2001
    base_year_simulation = 2001;
else
    base_year_simulation = 2014;
end
final_year_simulation=2100;
if ~isdef('TimeHorizon')
    TimeHorizon=final_year_simulation-base_year_simulation; // warning : the default time horizon is 99 but could be overwritten in STUDY.sce
end

i_year_strong_policy = start_year_strong_policy - base_year_simulation +1;

ind_inequality = 1;

begin_rebalance_K = 1; // start date to re-balance local capital markets
ind_NLU_sensit = 0;
ind_NLU = 0;
do_calibrateNoutput_NLU = %f;
ind_hydrogen = 0;
ind_beccs = 1;
k_expt=[3];

new_Et_msh_computation = 0; // account for CO2 content for liquids market share attribution in the static equilibrium

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

//Simulation d'une excise type TIPP dans les taxes là où les données étaient disponibles
//ajustement_taxes.sce dans WORKDIR joue avec ça (recomended value is %t)
imaNewTaxes = %t;

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//               COMBI TO BIG PARAMETERS PART
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

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

// a business as usual scenario is defined in IMACLIm as a scenario that can run by its own, without an associated baseline
// This concerne the reference scenario without policy (ind_climat==0), the NPi policies (ind_climat==1) and the NDC policies (ind_climat==2)
is_bau = (ind_climat==0) | (ind_climat==1) | (ind_climat==2);

baseline_combi = switch_indice_in_combi(combi,[ 1 7 8 9 10] ,[ ind_clim_refForBau 0 1 0 0]); //1: first indice is ind_climat, ind_clim_refForBau is it's baseline value

myopicCombi    = switch_indice_in_combi(combi,   [ 7 10]   , [ 0 0] );
if ind_climat > 550
    myopicCombi = switch_indice_in_combi(myopicCombi,1,550);
elseif (ind_climat < 550)&(ind_climat > 450);
    myopicCombi = switch_indice_in_combi(myopicCombi,1,450);
end

//autres indices, valeurs forcees
ind_CCS=0;
ind_oilandMO = 1;
ind_charbo = 1;
ind_altern = 1;
ind_develo = 1;
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
ind_seq_beccs_opt = 1; // always limit the market share of bioenergy with CCS, but with different rates:
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

//From demand-side macro-variants to options(NAVIGATE)

if ind_sufficiency == 1 // Variant monitoring the options regarding sufficiency: 0 = default (initially in the trunk); 1 = sufficient variant; 2 = BAU or non-sufficient variant

ind_shipFret_A = 1; // reduce speed in shipping (A for Activity) // NAVIGATE - task 3.5
ind_roadFret_A = 1; // reduce terrestrial fret transport in climate policy scenarios only (A for Activity) // NAVIGATE - task 3.5
ind_buildingsufficiency = 1; // Cap of the size of dwelling, especially in global North
ind_transportsufficiency = 1; //  Decreases the share of expenditure dedicated to transport (-0.8%/yr) & increase the occupancy rate in cars (+1%/yr)// NAVIGATE - task 3.5
//ind_polInfra = 1; //  Implement a set of change in transport infrastructures policies, notably in favor of public transport (but not only) // Removed from here as it is defined in standard combi

end

if ind_efficiency == 1 // Variant monitoring the options regarding efficiency: 0 = default; 1 = efficient variant. Note that some default assumptions have been changed (slower energy efficiency improvements in aviation and cars, lower max extra renovation rate in the residential sector) since the first runs of NAVIGATE.

ind_buildingefficiency = 1; //  speeds up energy efficiency improvements in dwellings // NAVIGATE - task 3.5
ind_transportefficiency = 1; //  speeds up energy efficiency improvements in aviation and cars (ICE & BEV) sectors // NAVIGATE - task 3.5
ind_shipFret_I = 1; // improve energy efficiency of ships (I for Improve) // NAVIGATE - task 3.5
ind_roadFret_I = 1; // improve energy efficiency for trucks (I for Improve) // NAVIGATE - task 3.5

end

if ind_fuelswitching == 1 // Variant monitoring the options regarding fuel switching: 0 = default; 1 = efficient variant. Note that a default assumption have been changed (more pessimistic electrification of low energy standards in buildings) since the first runs of NAVIGATE.

ind_OT_electrification = 1; // electrification of other transport
ind_shipping_air_electri = 1; // electrification of air and shipping sectors
indice_building_electri = 1; // electrification of the building sector

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

if ~isdef("ind_ssp")
    ind_ssp=2;//by default we assume ssp2 like trajectories
	ind_pop=2;
	ind_productivity=2;//medium growth for high income countries
	ind_productivity_st=1;//medium growth in the short term
	ind_catchup=2;//medium speed of catch up
else
    // labor productivity growth and population growth of ssp
    if ind_ssp==1
        ind_pop=1;
		ind_productivity=2;//medium growth for high income countries
		ind_productivity_st=1;//medium growth in the short term
		ind_catchup=1;//fast speed of catch up
    elseif ind_ssp==2
        ind_pop=2;
		ind_productivity=2;//medium growth for high income countries
		ind_productivity_st=1;//medium growth in the short term
		ind_catchup=2;//medium speed of catch up
    elseif ind_ssp==3
        ind_pop=3;
		ind_productivity=3;//slow growth for high income countries
		ind_productivity_st=2;//slow growth in the short term
		ind_catchup=3;//slow speed of catch up		
    elseif ind_ssp==4
        ind_pop=4;
		ind_productivity=2;//medium growth for high income countries
		ind_productivity_st=1;//medium growth in the short term
		ind_catchup=3;//slow speed of catch up
    elseif ind_ssp==5
        ind_pop=5;
		ind_productivity=1;//fast growth for high income countries
		ind_productivity_st=0;//fast growth in the short term
		ind_catchup=1;//fast speed of catch up		
    end
end

ind_productivity_leader=ind_productivity;//exogenous trend over time of labor productivity growth in leading country (USA)
ind_productivity_li=ind_catchup;
ind_productivity_mi=ind_catchup;
ind_productivity_hi=ind_productivity;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////****************         Marche des capitaux     *******************/////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
if isdef("ind_K")
    ind_partExpK = ind_K; // trade balance evolution
else
    ind_partExpK = 0;
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
    pente_gaz_1 = 1; //elasticité de la croissance du prix à la croissance de la prod si sous point_equilibre_gaz
    pente_gaz_2 = 1.5;
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

// High or Low variable renewable share
// driven by the markup costs
// short-terme parameter and long-terem/ policy parameter
cor_param_SIC_lowflex_st = 0.993;
cor_param_SIC_lowflex_po = 0.75; // parameters for ind_high_VRE==1 adter start_year_strong_policy

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

if isdef("exo_maxmshbiom")
    elecBiomassInitial.MSHBioSup = exo_maxmshbiom;
else
    select ind_MSHBioSup
    case 0
        elecBiomassInitial.MSHBioSup = 0.8;
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

select ind_EEI
case 1
    cff_lea  = 0.98; //(1-cff_lea) = exogenous EEI rate of the leader at fixed energy prices
    max_eei  = 1.5;
    max_aeei = 1.5;
    cff_y    = 0.01; //Level of EEI gained by the laggards in XRef years (defines speed of convergence)
    fin_lev  = 0.99; //Final level (share of the leader's EEI) targeted by laggards
case 0
    cff_lea  = 0.9971; //(1-cff_lea) = exogenous EEI rate of the leader at fixed energy prices
    max_eei  = 1;
    max_aeei = 1;
    cff_y    = 0.5;
    fin_lev  = 0.85;
else
    error("ind_EEI is ill-defined");
end;

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

if ind_hdf_opt==1
    hdf_cff = [ 1.2;1.2;1.2;1.2;2;2;2;2;2;2;2;2];
else
    hdf_cff = [ 1.5;1.5;1.5;1.5;3;3;3;3;3;3;3;3];
end; //niveau de saturation demande finale des ménages

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

// increase low carbon fuel mix
select ind_aviation_LCF
case 1
     // find the reference scenario
     HCF_sc = switch_indice_in_combi(combi,[8] ,[0]); 
     ldsav("share_biofuel_sav.sav","",HCF_sc) ;
     //exo_share_biofuel_aviat = max(1,share_biofuel_sav *1.5);
     ldsav("Q_biofuel_anticip_sav.sav","",HCF_sc) ;
     Q_et = Q_biofuel_anticip_sav./share_biofuel_sav;
     exo_share_biofuel_aviat = min(1,sum(Q_et.*share_biofuel_sav,'r') ./ sum(Q_et,'r')*1.5);
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

// case ind_lindhal=1, regional carbon prices and convergence
convergence_regional_tax = ones(TimeHorizon,1);
convergence_regional_tax(start_year_policy-base_year_simulation:year_convergence_reg_tax-base_year_simulation) = linspace(0,1,year_convergence_reg_tax-start_year_policy+1)';

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

//Init carbon "market" number for defaut case : world carbon price. Overrided later depending on ind_climat
nbMKT=1;
is_quota_MKT = %f;
is_taxexo_MKT = 1;
taxMKTexo = zeros(reg,TimeHorizon+1);
whichMKT_reg_use = ones(reg,nb_use); //here everything is in the market 1. Use this to control global emissions.
MKT_start_year = 1*ones(nbMKT,1);

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

    // load reference intermediate inputs - mainly for terrestrial fret inputs to sectors:
    ldsav("CI_sav","",baseline_combi);
    base_CI = rgv(CI_sav,TimeHorizon+1,sec,sec,reg);

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

    if ~isdef("exo_tax_increase")
        exo_tax_increase=1;
    end

    select ind_climat
    case 3
                is_quota_MKT = %f;
                is_taxexo_MKT = 1;
 		temp = csvread(STUDY+"tax_trajectory_example.csv");
                taxMKTexo = temp'*1e-6/usd2001_2005*exo_tax_increase;
    case 4
                is_quota_MKT = %f;
                is_taxexo_MKT = 1;
                temp = zeros(TimeHorizon+1,1);
                if ~isdef("tax2020")
                    tax2020 = 75;
                end
                if ~isdef("tax2050")
                    tax2050 = 1600;
                end
                if ~isdef("tax2100")
                    tax2100 = 3200;
                end
                temp(6:36) = linspace(tax2020,tax2050,30+1)'*1e-6;
                temp(36:87) = linspace(tax2050,tax2100,52)'*1e-6;
                temp(6:11) = linspace(0,1,6)' .* temp(6:11); // smoothing taxe increase from 2020 to 2025
                taxMKTexo = temp'/usd2001_2005;

    case 5
                is_quota_MKT = %f;
                is_taxexo_MKT = 1;
                temp = csvread(STUDY+"tax_trajectory_example.csv");
                taxMKTexo = 1.1*temp'*1e-6/usd2001_2005*0.85;
                taxMKTexo = 1.1*temp'*1e-6/usd2001_2005*0.55;
    case 6
                is_quota_MKT = %f;
                is_taxexo_MKT = 1;
                temp = csvread(STUDY+"tax_trajectory_example.csv");
                taxMKTexo = 0.8*temp'*1e-6/usd2001_2005*0.85;
                taxMKTexo = 0.8*temp'*1e-6/usd2001_2005*0.55;
    case 7
                is_quota_MKT = %f;
                is_taxexo_MKT = 1;
                temp = csvread(STUDY+"tax_trajectory_example.csv");
                taxMKTexo = 1.2*temp'*1e-6/usd2001_2005*0.85;
                taxMKTexo = 1.2*temp'*1e-6/usd2001_2005*0.55;
    case 8
                is_quota_MKT = %f;
                is_taxexo_MKT = 1;
                temp = csvread(STUDY+"tax_trajectory_example.csv");
                taxMKTexo = 0.7*temp'*1e-6/usd2001_2005*0.85;
                taxMKTexo = 0.7*temp'*1e-6/usd2001_2005*0.55;
    case 9
                is_quota_MKT = %f;
                is_taxexo_MKT = 1;
                temp = csvread(STUDY+"tax_trajectory_example.csv");
                taxMKTexo = 1.3* temp'*1e-6/usd2001_2005*0.85;
                taxMKTexo = 1.3* temp'*1e-6/usd2001_2005*0.55;
end
end

select ind_climat
// case 1 and 2 corresponding to NPi/NDC carbon tax trajectories
// see model/diagnostic.sce for details about their construction
// A 0$ carbon tax was privileged before 2020 to align with other models' practices
case 1 // NPi case 
        us_0 = 0; //2015
        us_1 = 0; //2019
        us_2 = 0;//2020
        us_3 = 0; //2025
        us_4 = 0; //2030
        us_5 = us_4;
        eu_0 = 0; //2015
        eu_1 = 0; //2019
        eu_2 = 0; //2020
        eu_3 = 0; //2025
        eu_4 = 0; //2030
        eu_5 = eu_4; //2100
        rw_0 = 0; //2015
        rw_1 = 0; //2019
        rw_2 = 0; //2020
        rw_3 = 0; //2025
        rw_4 = 0; //2030
        rw_5 = rw_4; //2100
case 2 //NDC Case
        us_0 = 0; //2015
        us_1 = 0; //2019
        us_2 = 40;//2020
        us_3 = 80; //2025
        us_4 = 100; //2030
        us_5 = us_4
        eu_0 = 0; //2015
        eu_1 = 0; //2019
        eu_2 = 10; //2020
        eu_3 = 45; //2025
        eu_4 = 50; //2030
        eu_5 = eu_4 //2100
        rw_0 = 0; //2015
        rw_1 = 0;//2019
        rw_2 = 0; //2020
        rw_3 = 0; //2025
        rw_4 = 0; //2030
        rw_5 = rw_4; //2100
        eu_0 = 0; //2015
        eu_1 = 0; //2019
        eu_2 = 10; //2020
        eu_3 = 45; //2025
        eu_4 = 50; //2030
        eu_5 = eu_4 //2100
        rw_0 = 0; //2015
        rw_1 = 0; //2019
        rw_2 = 0; //2020
        rw_3 = 0; //2025
        rw_4 = 0; //2030
        rw_5 = rw_4; //2100
end

if ind_climat==1|ind_climat==2
    nbMKT = 3;
    mk_1 = [ind_usa];
    mk_2 = [ind_can,ind_eur,ind_jan];
    mk_3 = [ind_cis,ind_chn,ind_ind,ind_bra,ind_mde,ind_afr,ind_ras,ind_ral];
    is_quota_MKT = [%f,%f,%f];
    is_taxexo_MKT = [%t,%t,%t];
    time_matrix =[1,5,6,11,16,87];
end


if ind_climat==1|ind_climat==2 //NPi/NDC
    val_matrix = [us_0,us_1,us_2,us_3,us_4,us_5;eu_0,eu_1,eu_2,eu_3,eu_4,eu_5;rw_0,rw_1,rw_2,rw_3,rw_4,rw_5;zeros(reg-nbMKT,6)];
    temp = size(time_matrix);
    taxMKTexo = CO2_tax_lin(val_matrix, time_matrix)*1e-6 ;
    whichMKT_reg_use(mk_3,:)=3;
    whichMKT_reg_use(mk_2,:)=2;
    whichMKT_reg_use(mk_1,:)=1;
    MKT_start_year = 1*ones(nbMKT,1);
    CO2_obj_MKT = ones(nbMKT,TimeHorizon+1)*%nan;
end
if ~isdef("CO2_obj_MKT") // in case more than 1 market
    CO2_obj_MKT = ones(1,TimeHorizon+1)*%nan;
end
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
