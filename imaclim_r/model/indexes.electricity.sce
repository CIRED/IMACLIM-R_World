// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera, Ruben Bibas, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///////////////////////////indexes for the electricity sector


technoCoal=7;
technoGas=3;
technoEt=2;
technoHydro=1;
technoCSP=1;
technoENR=10;
technoNuke=2;
nb_tranche=7;
technoConvwoCSP=technoCoal+technoGas+technoEt+technoHydro+technoNuke;
technoConv=technoCoal+technoGas+technoEt+technoHydro+technoNuke+technoCSP;
techno_elec=technoCoal+technoGas+technoEt+technoHydro+technoENR+technoNuke + technoCSP;
technoFF=technoCoal+technoGas+technoEt;



//production elec

indice_PFC=1;           //Super Critical pulverised coal
indice_PSS=2;           //Super Critical pulverised coal with sequestration
indice_ICG=3;           //Integrated Coal Gasification with Combined Cycle
indice_CGS=4;           //Integrated Coal Gasification with Combined Cycle with sequestration
//indice_LCT=5;           //Lignite-powered Conventional Thermal
indice_SUB=5;             //Subcritical Coal
//indice_CCT=6;           //Coal-powered Conventional Thermal
//indice_GCT=7;           //Gas-powered Conventional Thermal TAV
indice_USC=6;           //Ultra-Supercritical coal
indice_UCS=7;           //Ultra-Supercritical coal with sequestration
indice_GGT=8;           //Gas-powered Gas Turbine TAC           
indice_GGS=9;           //Gas-powered Gas Turbine in Combined Cycle with sequestration
indice_GGC=10;          //Gas-powered Gas Turbine in Combined Cycle
indice_OCT=11;          //Oil-powered Conventional Thermal
indice_OGC=12;          //Oil-powered Gas Turbine in Combined Cycle
indice_HYD=13;          //Conventional, large-size hydroelectricity
indice_NUC=14;          //Conventional Light-Water nuclear Reactor
indice_NND=15;          //New Nuclear Design
indice_CSP=16;          //Concentrated solar power => dispatchable 
indice_CHP=17;          //Combined Heat and Power (small to medium-size cogeneration in industry)
indice_SHY=18;          //Small Hydro
indice_WND=19;          //Wind turbines
indice_WNO=20;          //Wind turbines offshore
indice_CPV=21;          //Central PV
indice_RPV=22;          //Rooftop PV
indice_BF2=23;          //Biofuels, conventional technologies (woodfuels, elec. from wastes, biofuels)
indice_BGT=24;          //Biomass gasification for electricity production in GT
indice_GFC=25;          //Natural gas Fuel-Cells for stationary uses
indice_HFC=26;          //Hydrogen Fuel-Cells for stationary uses

indice_BIGCC=23;
indice_BIGCCS=24;

technoBiomass = [indice_BIGCC indice_BIGCCS];
nTechnoBiomass = length(technoBiomass);
technoENRwoBiomass = [indice_CHP:indice_RPV indice_GFC indice_HFC];
technoEndo = [1:indice_CSP indice_BIGCC indice_BIGCCS];
technoExo  = [indice_CSP+1:indice_BIGCC-1 indice_BIGCCS+1:techno_elec];
nTechnoEndo = indice_CSP+2;
indice_lastTechnoEndo = indice_BIGCCS;
technoExo_absolute = [1:6 9 10];
VarRenew_ENR = [3,4,5,6]; // Used renewable technologies, but outside the electricity sector optimization, in absolute indexes (not 26). old technoExoAbsoluteUsed
nbTechExoAbsUsed = length(VarRenew_ENR);
technoCoalWOCCS = [ indice_PFC indice_ICG indice_SUB indice_USC];
technoCoalWCCS  = [ indice_PSS indice_CGS indice_UCS];
technoGasWOCCS  = [  indice_GGT indice_GGC ];
technoGasWCCS   = indice_GGS;
technoOil  = [ indice_OCT indice_OGC];
technoElecCoal = [technoCoalWOCCS technoCoalWCCS];
technoElecGas = [technoGasWOCCS technoGasWCCS];
technoElecNuke      = [indice_NUC indice_NND];
technoWind = [ indice_WND indice_WNO];
technoElecHydro = [ indice_HYD indice_SHY ];
technoFossil = [technoOil technoElecCoal technoElecGas]; // index for total fossil
technoFossilWOCCS = [ indice_PFC indice_ICG indice_SUB indice_USC indice_UCS indice_GGT indice_GGC indice_OCT indice_OGC ];
technoUnused  = [ indice_CHP indice_GFC indice_HFC];
technoWCCS = [ technoCoalWCCS technoGasWCCS indice_BIGCCS];
technoSolar = [ indice_CSP indice_CPV indice_RPV];
technoPV =[indice_CPV indice_RPV];
technoNonBiomassRen = [ technoWind technoSolar technoElecHydro ]; // attention: includes hydro
technoNonFossil  = [technoBiomass technoNonBiomassRen technoElecNuke];
techno_ENR = ["WND","WNO","CSP","CPV","RPV"]; //for execstr
techno_ENRi = ["WND","WNO","CPV","RPV"]; //for execstr
techno_ENRi_endo =[technoWind,technoPV];


// indices for SIC markup computation and Load_factor_ENR
technoPVAbsolute = technoPV - technoConv ;
technoWindAbsolute = technoWind -technoConv ;
technoWind_ENR_vs_FF = technoWind - technoConv - 1;
technoPV_ENR_vs_FF = technoPV - technoConv - 1;
technoENRi_vs_FF = [technoWind_ENR_vs_FF,technoPV_ENR_vs_FF];
nbTechFFENR = length(technoENRi_vs_FF)+1;

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


nb_techno_elec_POLES=15;
ind_POLES=[
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

//technoElec.PFC.indIM
//technoElec.PFC.indRhoPoles
//technoElec.PFC.indMSH

ind_tranche_730=1;
ind_tranche_2190=2;
ind_tranche_3650=3;
ind_tranche_5110=4;
ind_tranche_6570=5;
ind_tranche_8030=6;
ind_tranche_8760=7;
