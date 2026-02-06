// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Nicolas Graves, Thibault Briera, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//--------------------------------------------------------------------//
//--------------------------------------------------------------------//
//------ ---------------POWER SECTOR NEXUS ---------------------------//
//-------------    Technology and family indexes     -----------------//
//--------------------------------------------------------------------//
//--------------------------------------------------------------------//


//These indexes will be deleted progressively when the update of the electricity sector will be done (some indexes required to load some v.1 and POLES data)
technoCoal=7;
technoGas=3;
technoEt=2;
technoHyd=1;
//technoCSP=1; to be deleted
technoENR=10;
technoNuke=2;

technoConvwoCSP=technoCoal+technoGas+technoEt+technoHyd+technoNuke;
technoConv=technoCoal+technoGas+technoEt+technoHyd+technoNuke+1;
techno_elec=technoCoal+technoGas+technoEt+technoHyd+technoENR+technoNuke + 1;
technoFF=technoCoal+technoGas+technoEt;


//Explictly technology indexes

indice_PFC=1;           //Super Critical pulverised coal
indice_PSS=2;           //Super Critical pulverised coal with sequestration
indice_ICG=3;           //Integrated Coal Gasification with Combined Cycle
indice_CGS=4;           //Integrated Coal Gasification with Combined Cycle with sequestration
indice_SUB=5;           //Subcritical Coal
indice_USC=6;           //Ultra-Supercritical coal
indice_UCS=7;           //Ultra-Supercritical coal with sequestration
indice_GGT=8;           //Gas-powered Gas Turbine TAC           
indice_GGC=9;           //Gas-powered Gas Turbine in Combined Cycle
indice_GGS=10;          //Gas-powered Gas Turbine in Combined Cycle with sequestration
indice_OCT=11;          //Oil-powered Conventional Thermal
indice_OGC=12;          // Unused slot - depreciated (Old Oil-powered Gas Turbine in Combined Cycle) -> this techno will be deleted in a future commit
indice_HYD=13;          //Conventional, large-size hydroelectricity
indice_NUC=14;          //Conventional Light-Water nuclear Reactor
indice_NND=15;          //Unused slot - depreciated (Old New Nuclear Design)
indice_CSP=16;          //Concentrated solar power => dispatchable 
indice_CHP=17;          //Unused slot - Combined Heat and Power (small to medium-size cogeneration in industry)
indice_SHY=18;          //Unused slot - depreciated (old Small Hydro)
indice_BIG=19;          //Biogas (former BIGCC)
indice_BIS=20;          //Biogas with CCS (former BIGCCS)
indice_SBI=21;          //Solid biomass (traditional)
indice_STR=22;          //Battery storage (representative battery storage technology)
//add new dispatchable technologies here

//Variable Renewable Energy
indice_WND=23;          //Wind turbines
indice_WNO=24;          //Wind turbines offshore
indice_CPV=25;          //Central PV
indice_RPV=26;          //Rooftop PV


ntechno_elec_total=26;

//unused
technoUnused  = [indice_OGC,indice_CHP,indice_SHY, indice_NND];

//Family indexes used in the main logit nodes
// CoalWOCCS, GasWOCCS, Oil, CoalWCCS, GasCCS, Nuke, CSP, BiomassWOCCS, BiomassWCSS in the dispatchable logit node: 10 families of dispatchable technologies
techno_dispatch_type = ["CoalWOCCS","GasWOCCS","Oil","CoalWCCS","GasWCCS","Hydro","Nuke","CSP","BiomassWOCCS","BiomassWCCS"];
n_type_elec = size(techno_dispatch_type,2);
technoCoalWOCCS = [ indice_PFC indice_ICG indice_SUB indice_USC];
technoCoalWCCS  = [ indice_PSS indice_CGS indice_UCS];
technoGasWOCCS  = [  indice_GGT indice_GGC ];
technoGasWCCS   = indice_GGS;
technoOil  = [ indice_OCT];
technoHydro = [ indice_HYD];
technoCSP = [ indice_CSP];
technoNuke      = [indice_NUC]; //former technoElecNuke  
technoWind = [ indice_WND indice_WNO];
technoSolar = [ indice_CSP indice_CPV indice_RPV];
technoPV = [indice_CPV indice_RPV];
technoBiomass = [indice_BIG indice_BIS indice_SBI]; // former technoBiomass = [indice_BIGCC indice_BIGCCS];
techno_biomass_names = ["BIG","BIS","SBI"];
technoBiomassWOCCS = [indice_BIG indice_SBI];
technoBiomassWCCS = [indice_BIS];
technoStorage = [indice_STR];

//Even bigger families, mainly for extraction
technoElecCoal = [technoCoalWOCCS technoCoalWCCS];
technoElecGas = [technoGasWOCCS technoGasWCCS];
technoFossil = [technoOil technoElecCoal technoElecGas];
technoFossilWOCCS = [technoCoalWOCCS, technoGasWOCCS, indice_OCT indice_OGC]; //OGC to be removed
technoElecHydro = [ indice_HYD indice_SHY ];
technoNonBiomassRen = [ technoWind technoSolar technoElecHydro ]; // attention: includes hydro
technoNonFossil  = [technoBiomass technoNonBiomassRen technoNuke];

//more families and combinations used for computations
techno_VRE = [technoWind,technoPV]; //former techno VRE =[technoWind,technoPV];
techno_RE_names = ["WND","WNO","CSP","CPV","RPV"]; //former techno_RE_names. used in execstr loops 
ntechnoCoal = length(technoElecCoal); // former technoCoal
ntechnoGas = length(technoElecGas); // former technoGas

nTechnoBiomass = length(technoBiomass);


techno_dispatchable = setdiff(1:techno_elec,[techno_VRE,technoStorage]); // former techno_Endo. storage is not explicitly dispatched but contained in the RLDC
technoWind_absolute = technoWind - indice_WND + 1; //former technoWindAbsolute - WND is the first VRE technology in the list
technoPV_absolute = technoPV - indice_WND + 1 ;   //former technoPVAbsolute 

techno_VRE_absolute = [technoWind_absolute,technoPV_absolute];

nTechno_dispatch = length(techno_dispatchable); // former nTechnoEndo
nTechno_VRE = length(techno_VRE_absolute); // nbTechExoAbsUsed

// indices for SIC markup computation and Load_factor_ENR
//VRE in the main logit node
technoWind_ENR_vs_FF = technoWind_absolute +1;
technoPV_ENR_vs_FF = technoPV_absolute + 1;
technoENRi_vs_FF = [technoWind_ENR_vs_FF,technoPV_ENR_vs_FF];
nbTechFFENR = length(technoENRi_vs_FF)+1;

// list of all technologies' names 
elecnames = [
"PulvFCoal"
"PulvSupercritSeq"
"ICoalGazi"
"CoalGazifSeq"
"LigniConvTherm"
"CoalConvTherm"
"GazConvTherm"
"GasGasTurbine"
"GasGasSeq"
"GazCombinCycle"
"OilConvTherm"
"OilGascomCycle"
"grosHYDro"
"NUCconv"
"NuNucDsgn"
"CombHeatPow"
"SmallHYdro"
"WiND"
"WiNdOffshore"
"CSP"
"CentralPV"
"RooftopPV"
"biomassIGCC"
"biomassIGCCseq"
"GasFuelCell"
"HudroFuelCell"
];


//removed and depreciated: technoENRwoBiomass, indice_lastTechnoEndo, technoWCCS, techno_ENRi, techno_VRE (replaced by techno_VRE), technoExo_absolute (replaced by techno_VRE_absolute), VarRenew_ENR (replaced by techno_VRE_absolute), nb_techno_elec_POLES (depreciated), ind_tranche_'tranche' (depreciated), nb_tranche (unused), nTechnoEndo, nbTechExoAbsUsed. fuelCosts becomes varCosts to include variable O&M in a future commit

ind_POLES=[ // removed when the POLES depreciated data will be removed
1 // index POLES PFC = 1 
2 // index POLES PSS = 2
3 // index POLES ICG = 3
4 // index POLES CGS = 4
5 // index POLES LCT = 5
6 // index POLES CCT = 6
8 // index POLES GCT = 8
9 // index POLES GGT = 9
11// index POLES GGS = 11
12// index POLES GGC = 12
7 // index POLES OCT = 7
10// index POLES OGC = 10
13// index POLES HYD = 13
14// index POLES NUC = 14
15// index POLES NND = 15
16// index POLES CHP = 16
17// index POLES SHY = 17
18// index POLES WND = 18
19// index POLES WNO = 19
%nan
%nan
%nan
%nan
%nan
25// index POLES GFC = 25
26// index POLES HFC = 26
];
