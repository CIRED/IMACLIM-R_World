// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////calibration of nexus.electricity //////////////////////////////
///////////////////////////////////////////////////////////////////////////////////

// COMMENT
// the previous calibration was done in seperate files. See revision 29328 or before

//=======================================================//
//=======================================================//
// GENERAL PATTERN FOR TECHNO PARAMETERS CALIBRATION
//1st step : get the old POLES data 
//2st step : convert to 2014USD when necessary
//3rd step : overide POLES data with newer datasets (IRENA,IEA) when available 

//intermediary step for renewables : load technology-specific data

//=======================================================//
//=======================================================//

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   INDEXES and DIMENSIONS   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////

exec(MODEL+'indexes.electricity.sce');

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION with no sources   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

// LDC and RLDC design
// TB: some of thesse parameters will be either renamed or deleted (depreciated) when the new RLDC functions will be fully implemented (nb_tranches_elec and tranches_elec)
full_load_hours = 8760;
tranches_elec=["8760","8030","6570","5110","3650","2190","730"]; 
tranches_wo_base=tranches_elec(2:7);
time_slices_n_base_flip = flipdim(strtod(tranches_elec),2);
n_inner_bands = 5;
n_load_bands = n_inner_bands + 2;
//duration of load bands
peak_duration = 730;
length_inner_load = (full_load_hours-2*peak_duration)/n_inner_bands;
nb_tranches_elec=size (tranches_elec,"c");

// market share of CCS tech. in elec. are zeros if the tax is inferio to:
starting_taxCO2_ccs_elec = 25*1e-6; // in 1e-6 $/tCO2

nb_year_expect=10; // number of expected year considered in calibration
nb_year_expect_futur=10; // construction horizon. different from the planning horizon in life cycle assessments (nb_year_expect_LCC)
// sequential investment decisionmaking
if ~isdef("dur_seq_inv_elec")
    dur_seq_inv_elec = 5; // investment decision making is reassessed every dur_seq_inv_elec years. Typical value in the litterature is ~5 years (see http://dx.doi.org/10.1016/j.esr.2017.06.001)
end

if (auto_calibration_txCap<>"None")
    nb_year_expect_futur=1;
    dur_seq_inv_elec=1;
end


//logit exponent for the dispatchable logit nodes :
// sharper exponent for dispatchable technologies. Since the logit node is applied to each load band, the investment decision gets closer to a "winner takes all" on each load band vs a broader choice of dispatchable vs VRE in the upper logit node. GCAM uses a value of 10 for choices between technologies within a type (ex: critical coal vs IGCC). 6 is a middle ground between 3 and 10 (3 was the value used in the previous modelling framework of IMACLIM-R)

//between technology types
if ~isdef("gamma_FF_type")
    gamma_FF_type = 6;
end
//within types
if ~isdef("gamma_FF")
    gamma_FF = 10;
end

//VRE nest
if ~isdef("gamma_VRE")
    gamma_VRE=3;
end


// maximum production of biomass energy per year
//This is v1 value with no source (75 EJ). The switch and the value are kept, but not used by defaut
if ~isdef("exogenousBiomassMaxQ")
    exogenousBiomassMaxQ = 75; // EJ/yr
end

// correction to data on investment cost for wind turbine offshore
corr_CINV_windoffshore = 1.961;

// assumed growth rate of capacities to contruct an history of past capacity vintage
txCap_MW=0.03*ones(nb_regions,techno_elec);
// number of LifetimeMax time we look into the past to construc and historic of capacity vintage
// this parameter serve to calibration and do not need to be greater
nb_time_lifetime = 5;

//Markup SIC
//SIC functions parameters
//Low-flexibility markup calibrated on  NEA/OECD (2019) "The Costs of Decarbonization: System Costs with Higher Shares of Nuclear and Renewable"
// No cue in the doc so assumed 2018 USD, need to convert the markup from 2018 USD to 2014 USD
param_SIC = cor_param_SIC_lowflex_st*0.05 * CPI_2018_to_2014; //PING_FL

// temporary fix: curtailment and storage costs are now included in the cost markup
// this is an a rough estimate: storage costs range from 2 to 5 $/MWh (average, not marginal)
param_SIC = param_SIC * 2 / 3;

//these are supposed to remain fixed
param_SIC_pv = 3;
param_SIC_wind = 1.4;

//Modified logit parameter
if (~isdef("gamma_FF_ENR"))
    gamma_FF_ENR = 3;
end


//thousand hours to hours (for Load_Factor_ENR)
th_to_h = 1000;


//Initiating variables for the elec nexus


CINV_MW_nexus=zeros(reg,techno_elec); //capital costs
OM_cost_var_nexus  =zeros(reg,techno_elec); //variable O&M costs
OM_cost_fixed_nexus=zeros(reg,techno_elec);//fixed
rho_elec_nexus=zeros(reg,techno_elec);//rho parameter for efficiency

init_ITC_elec=zeros(1,techno_elec); //starting year for learning
sum_Inv_MW=zeros(1,techno_elec);//sum of investments in technos
Inv_MW=zeros(1,techno_elec);//Investment levels


curt_VRE = zeros(reg,length(techno_VRE_absolute));//Initializing curtailment parameter, in % of solar/wind generation
curt_VRE_gross=zeros(reg,2); //total curtailment as a share of demand
Q_elec_anticip_tot_prev=zeros(reg,1); //previous dynamic period, electricity demand expectation at t+nb_year_expect_futur 
Q_elec_anticip_tot_1_p=zeros(reg,1); //previous dynamic period, electricity demand expectation at t+1

// case ind_lim_nuke=1,  No new Nuclear construciton after 2030
year_stop_nuclear = 2030;
// time frame to make a smooth convergence of the nuclear technology LCC towards the second least costs controllable technology
// This avoid non linearity in tje remove_saturated_techno function
time_toremove_NUC = 6;
time_toremove_NUC_2 = 10;

// maximum yearly injection rate of CCS (all sectors, but in practice it is reserved for BECCS)
// of 2GtCO2 / yr
if isdef("exo_max_CCS_injection")
    max_CCS_injection = exo_max_CCS_injection * giga2unity;
else
    max_CCS_injection = 2 * giga2unity;
end

// year after wich we stop the constraint on CCS injection
// in order to avoid a decrease in BECCS emissions for certain scenarios
if ETUDE=='base' & combi == 6301
    year_stop_CCS_constraint=2093;
elseif ETUDE=='base' & combi == 6302
    year_stop_CCS_constraint=2091;
else
    year_stop_CCS_constraint=2100;
end

// correction factor when correcting expected BECCS market share
// purely by experience, correction in order to reach the target
// likely capturing a differences bewteen expectations and actual production (rather than a computation mistake)
MSH_BIGCCS_cor_factor = 2 / 1.2 / 4;


/////////////////////////////////////////////////////////////////////////////////////////////
//    ---*---   TECHNO-SPECIFIC CALIBRATION   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////

//===================================//
//CCS Calibration
//===================================//

if ind_seq_opt==0
    for tranche=tranches_elec
        for j=[indice_PSS,indice_CGS,indice_GGS]
            execstr('MSHmax_'+tranche+'_elec(:,'+j+') =zeros('+nb_regions+',1);');
            execstr("MSH_"+tranche+"_elec_sup(:,"+j+")=0;"); //If ind_seq_opt == 0, no CCS
        end
    end
end

if ind_seq_beccs_opt==0
    for tranche=tranches_elec
        for j=[indice_BIS]
            execstr('MSHmax_'+tranche+'_elec(:,'+j+') =zeros('+nb_regions+',1);');
            execstr("MSH_"+tranche+"_elec_sup(:,"+j+")=0;"); //If ind_seq_opt == 0, no CCS
        end
    end
end



//Limiting CCS deployment
//Theses parameters are initialized in study_frames/default_parameters.sce and study_frames/study
for tranche=tranches_elec
    execstr ("Tgrowth_CCS_"+tranche+" = tGrowthCCS * ones(nb_regions,1);");
    execstr ("Tmature_CCS_"+tranche+" = tMatureCCS * ones(nb_regions,1);");
    execstr ("Tstart_CCS_" + tranche +     " = tStartCCS * ones(nb_regions,1);");
    execstr ("Tniche_CCS_" + tranche +     " = tNicheCCS * ones(nb_regions,1);");
    execstr ("MSHmax_"     + tranche +"_elec = mshMaxCCS * ones(nb_regions,1);");
end

CCS_efficiency = 0.9;
//===================================//
//Biomass Calibration
//===================================//


[elecBiomassResource,elecBiomassResourceDescr] = csvRead(path_elec_biomass+'elecBiomassResource.csv',';',[],[],[],'/\/\//');
//Convert old supply curve in $2014. Guessing from the ref that the values are USD2000
elecBiomassResource(:,1:$) = elecBiomassResource(:,1:$)*CPI_2000_to_2014;

if ind_NLU > 0 // using the Nexus Land-Use supply curves implies a regional supply curves computation
    elecBiomassInitial.supplyCurve  = [elecBiomassResource(:,1),elecBiomassResource(:,2:$)* exa2giga] ;
    select ind_exogenousBiomassMax
    case 0
        elecBiomassInitial.exogenousBiomassMaxQ = %inf *ones(nb_regions,1) ;
    case 1
        elecBiomassInitial.exogenousBiomassMaxQ = exogenousBiomassMaxQ * elecBiomassResource($,2:$)./sum(elecBiomassResource($,2:$)) *exa2giga;
    else
        error("exogenousBiomassMaxQ is ill-defined");
    end
    elecBiomassInitial.priceCap                = elecBiomassResource($,1)*ones(nb_regions,1); // $/GJ  
    elecBiomassInitial.processCost             =   1.7*ones(nb_regions,1)*CPI_2001_to_2014; // USD2001/GJinput
else // delete this is the standalone version of Imaclim (without the Nexus Land-Use) also works with regional supply curves
    elecBiomassInitial.supplyCurve  = [elecBiomassResource(:,1),sum(elecBiomassResource(:,2:$),2)* exa2giga] ;
    select ind_exogenousBiomassMax
    case 0
        elecBiomassInitial.exogenousBiomassMaxQ = %inf ;
    case 1
        elecBiomassInitial.exogenousBiomassMaxQ = exogenousBiomassMaxQ * exa2giga;
    else
        error("exogenousBiomassMaxQ is ill-defined");
    end

    elecBiomassInitial.priceCap                = elecBiomassResource($,1); // $/GJ  
    elecBiomassInitial.processCost             =   1.7*CPI_2001_to_2014; // USD2001/GJinput
    // No source?? Added to the cost of Biomass (per thermal units of inputs), this must yield consistent fuel cosss. To be compared to Levelized Cost of Electricity- Renewable Energy Technologies (Fraunhofer ISE, 2021), table 5: substrate solid biomass a bit costlier than hard coal.
end


//Process costs are added to the cost of producing the raw biomass from (Hoogwijk et al). This variable pretty much corrects the fuel costs to get consistent fuel cost estimates. As a rule of thumb from (Levelized Cost of Electricity- Renewable Energy Technologies (Fraunhofer ISE, 2021): Substrate solid biomass is costlier than hard coal (0.05-0.07$/kWh) and substrate biogas is 2-3 times costlier than solid biomass.
// In terms of LCOE, with a moderate carbon tax ~ 30$ per tCO2, CCGT is cheaper than solid biomass and biogas, solid biomass is even with coal.
// + IRENA (2012) Biomass for Power Generation gives orders of magnitude for the share of fuel costs (CFuel) in the LCOE, ~40%-60% for biomass. With these corrections we are at ~40 45% for solid biomass and 60% for biogas


// This is manually
elecBiomassInitial.processCost.SBI = 0.006; // $ / kWh of thermal input
elecBiomassInitial.processCost.BIG = elecBiomassInitial.processCost.SBI*4; // $ / kWh of thermal input 
elecBiomassInitial.processCost.BIS = elecBiomassInitial.processCost.SBI*4; // $ / kWh of thermal input 
// based on footnote 7 of IEA (2023), Global Energy and Climate Model, IEA, Paris https://www.iea.org/reports/global-energy-and-climate-model, Licence: CC BY 4.0
// We make the following assumption: "Bioenergy - Large scale unit" is Solid biomass. 

//Hyp: CAN = USA, OECD PAC = JAP,CEI = RUS, REST ASIA = CHI, REST LAT = BRA
elecBiomassInitial.invCost.SBI =  [2500,2500,2400,2350,2250,1600,2150,2200,2300,2150,1600,2200]'*CPI_2019_to_2014; //WEO Power generation technology costs and assumptions in the WEO-2021 (IEA,2021)
//additionnal assumption: since there is no biogas assumption in the WEO we use a ratio of CAPEX from Levelized Cost of Electricity- Renewable Energy Technologies (Fraunhofer ISE, 2021): 2500/3000
elecBiomassInitial.invCostratio = 2500/3000;
elecBiomassInitial.invCost.BIG = elecBiomassInitial.invCost.SBI * elecBiomassInitial.invCostratio;
elecBiomassInitial.invCost.BIS = [5850,5850,5750,5700,5200,4150,4700,4550,5150,4900,4150,4550]'*CPI_2019_to_2014 * elecBiomassInitial.invCostratio;

//same applies for asymptotic costs : NZ2050 costs from Power generation technology costs and assumptions in the WEO-2021 (IEA,2021)

elecBiomassInitial.investmentCostAsymptote.SBI =  [2200,2200,2100,2050,2100,1050,2000,2000,2050,1900,1050,2000]'*CPI_2019_to_2014; //WEO Power generation technology costs and assumptions in the WEO-2021 (IEA,2021)
elecBiomassInitial.investmentCostAsymptote.BIG = elecBiomassInitial.investmentCostAsymptote.SBI * elecBiomassInitial.invCostratio;
elecBiomassInitial.investmentCostAsymptote.BIS = [3600,3600,3550,3500,3250,2150,3050,3000,3300,3100,2150,3000]'*CPI_2019_to_2014 * elecBiomassInitial.invCostratio;
// in  Levelized Cost of Electricity- Renewable Energy Technologies (Fraunhofer ISE, 2021), var and fixed OPEX are the same for the two technos
//Bioenergy - large scale unit
elecBiomassInitial.OMCostFixed        =  [85,85,85,85,80,55,75,75,80,75,55,75]'*CPI_2019_to_2014; //WEO Power generation technology costs and assumptions in the WEO-2021 (IEA,2021)
elecBiomassInitial.OMCostFixedCCS       =  [200,200,200,200,180,145,165,160,180,170,145,160]'*CPI_2019_to_2014;

elecBiomassInitial.OMCostVar                =  4/1000 * CPI_2020_to_2014 * EUR_to_USD; // Levelized Cost of Electricity- Renewable Energy Technologies (Fraunhofer ISE, 2021)

// Efficiency rate: Levelized Cost of Electricity- Renewable Energy Technologies (Fraunhofer ISE, 2021)
elecBiomassInitial.efficiency.BIG         =   0.4; 
elecBiomassInitial.efficiency.BIS        =   0.4;
elecBiomassInitial.efficiency.SBI         =   0.25; 
elecBiomassInitial.lifetime                =    25; // years

elecBiomassInitial.lr                 =   0.1; // WEO (2021) Power generation technology costs and assumptions in the WEO-2021 Stated Policies and Net Zero Emissions by 2050 scenarios
elecBiomassInitial.lrCCS                 =   0.1; // WEO (2021) Power generation technology costs and assumptions in the WEO-2021 Stated Policies and Net Zero Emissions by 2050 scenarios

elecBiomassInitial.startLearningDateBIGCC  =     1; // We start at year 2014
elecBiomassInitial.startLearningDateBIGCCS =     startLearningDateBIGCCS;// Learning on Biomass with CCS start later (in 2025)


// Biomass capacity from IRENA (2020), same source as PV and wind. 

[elecBiomassInitial.cap.BIG,elecENRInitial.descrip.cap.BIG]                  =    csvread(path_elec_cap+'Cap_2014_BIG.csv');
[elecBiomassInitial.cap.SBI,elecENRInitial.descrip.cap.SBI]                  =    csvread(path_elec_cap+'Cap_2014_SBI.csv');

if ind_beccs == 2 //a combi parameter that determines beccs development. Is 1 most of the time.
    elecBiomassInitial.invCost     = elecBiomassInitial.invCost * 2;
    elecBiomassInitial.OMCostFixed = elecBiomassInitial.OMCostFixed * 2;
    elecBiomassInitial.OMCostVar   = elecBiomassInitial.OMCostVar * 2;
end

//source
elecBiomassInitial.emissions               = 0.094; // tCO2/GJinput
elecBiomassInitial.emissionsCCS            = 0.009; // tCO2/GJinput


if ind_redistrNegativeEmiss == 1
    // Emissions are accounted for (whether negative or null) wholly in the electric sector (no relation whatsoever with agricultural emissions)
    elecBiomassInitial.emissionsCCS = elecBiomassInitial.emissionsCCS - elecBiomassInitial.emissions;
    elecBiomassInitial.emissions    = 0;
end

elecBiomassInitial.emissionsCCS = elecBiomassInitial.emissionsCCS / gj2tep * 1e6; // tCO2/Mtep
elecBiomassInitial.emissions    = elecBiomassInitial.emissions    / gj2tep * 1e6; // tCO2/Mtep

sh_bio_prod_elec = zeros(nb_regions,1);
sh_bio_prod_elec_ref = zeros(nb_regions,1);


//===================================//
//VRE Calibration
//===================================//


//Investment costs - Source  IRENA (2020) Renewable Power Generation Costs _ IEA (2020) "Power generation assumptions in the Stated Policies and SDS Scenarios in the World Energy Outlook 2020"
//backward computation 2019 -> 2014 on IEA's data using learning curves when 2014 IRENA's data not available
[elecENRInitial.invCost.WND,elecENRInitial.descrip.invCost.WND]                  =    csvRead(path_elec_CINV+'CINV_2014_WND.csv',';',[],[],[],'/\/\//');
[elecENRInitial.invCost.WNO,elecENRInitial.descrip.invCost.WNO]                  =    csvRead(path_elec_CINV+'CINV_2014_WNO.csv',';',[],[],[],'/\/\//');
[elecENRInitial.invCost.CSP,elecENRInitial.descrip.invCost.CSP]                  =    csvRead(path_elec_CINV+'CINV_2014_CSP.csv',';',[],[],[],'/\/\//');
[elecENRInitial.invCost.CPV,elecENRInitial.descrip.invCost.CPV]                  =    csvRead(path_elec_CINV+'CINV_2014_CPV.csv',';',[],[],[],'/\/\//');
[elecENRInitial.invCost.RPV,elecENRInitial.descrip.invCost.RPV]                  =    csvRead(path_elec_CINV+'CINV_2014_RPV.csv',';',[],[],[],'/\/\//');

for techno = techno_RE_names
    execstr("elecENRInitial.invCost."+techno+"=elecENRInitial.invCost."+techno+"*CPI_2019_to_2014"); //PING_FL
end

//PING_FL ###################
//Fixed O&M. Source: IEA (2020) "Power generation assumptions in the Stated Policies and SDS Scenarios in the World Energy Outlook 2020"
//Hyp: CAN = USA, OECD PAC = JAP,CEI = RUS, REST ASIA = CHI, REST LAT = BRAZ
elecENRInitial.OMCostFixed.WND                =    [38,38,40,56,40,30,26,38,46,48,30,38]'*CPI_2019_to_2014; 
elecENRInitial.OMCostFixed.WNO                =    [130,130,75,80,120,75,65,115,115,110,75,115]'*CPI_2019_to_2014; 
elecENRInitial.OMCostFixed.CPV                =    [18,18,12,32,32,12,12,18,14,24,12,18]'*CPI_2019_to_2014; 
//If RPV = Solar - Building in IEA (2020)
elecENRInitial.OMCostFixed.RPV                =    [52,52,18,30,42,14,12,18,24,32,14,18]'*CPI_2019_to_2014; 
//Missing Japan and Russia in this dataset : OECD PACIFIC = USA, CEI = EUROPE
elecENRInitial.OMCostFixed.CSP             =    [260,260,230,260,230,200,230,210,210,200,200,210]'*CPI_2019_to_2014; 
//#######################

//Setting variable O&M cost to zero for VRE
for techno = techno_RE_names
    execstr("elecENRInitial.OMCostVar."+techno+"= zeros(reg,1)");
end

//CINV 2019 checkpoint from IEA (2020) "Power generation assumptions in the Stated Policies and SDS Scenarios in the World Energy Outlook 2020"
//The learning curves apply endogeneously only from 2019. Before that, CINV_MW _nexus linearly converges to 2019 costs for VRE
//hyp : CAN = USA, OECD PAC = JAP , REST ASIA = CHI, REST LAT = BRAZ, CEI = RUS
//TB: chech OECD PAC = JAP hypothesis
CINV_MW_2019 = zeros(reg,techno_elec);

[elecENRInitial.invCost2019.WND,elecENRInitial.descrip.invCost2019.WND]                  =    csvRead(path_elec_CINV+'CINV_2019_WND.csv',';',[],[],[],'/\/\//');
[elecENRInitial.invCost2019.WNO,elecENRInitial.descrip.invCost2019.WNO]                  =    csvRead(path_elec_CINV+'CINV_2019_WNO.csv',';',[],[],[],'/\/\//');
[elecENRInitial.invCost2019.CSP,elecENRInitial.descrip.invCost2019.CSP]                  =    csvRead(path_elec_CINV+'CINV_2019_CSP.csv',';',[],[],[],'/\/\//');
[elecENRInitial.invCost2019.CPV,elecENRInitial.descrip.invCost2019.CPV]                  =    csvRead(path_elec_CINV+'CINV_2019_CPV.csv',';',[],[],[],'/\/\//');
[elecENRInitial.invCost2019.RPV,elecENRInitial.descrip.invCost2019.RPV]                  =    csvRead(path_elec_CINV+'CINV_2019_RPV.csv',';',[],[],[],'/\/\//');

//Convert 2019 USD to base year USD
for techno = techno_RE_names
    execstr("elecENRInitial.invCost2019."+techno+"=elecENRInitial.invCost2019."+techno+"*CPI_2019_to_2014"); //PING_FL
end

for techno = techno_RE_names
    execstr("CINV_MW_2019(:,indice_"+techno+") = elecENRInitial.invCost2019."+techno+"");
end

//Load factor. Source: IEA (2020) "Power generation assumptions in the Stated Policies and SDS Scenarios in the World Energy Outlook 2020"
//Assumed that 2019 load factor stands for 2014 and stay still till 2100

//Hyp: CAN = USA, OECD PAC = mean(JAP,AUS),CEI = RUS, REST ASIA = CHI, REST LAT = BRAZ. Australia values from IEA/NEA (2020) Projected Cost of Generating Electricity when available (WND,WNO,CPV,CSP)
elecENRInitial.loadFactor.WND               =    [0.42,0.42,0.28,mean([0.25,0.42]),0.25,0.25,0.26,0.44,0.30,0.26,0.25,0.44];
elecENRInitial.loadFactor.WNO               =    [0.41,0.41,0.49,mean([0.39,0.51]),0.37,0.32,0.29,0.46,0.32,0.37,0.32,0.46];
// The CAN = USA assumption might be irrelevant for PV, chose CAN = EUR for solar load factor
elecENRInitial.loadFactor.CPV               =    [0.21,0.13,0.13,mean([0.13,0.28]),0.12,0.17,0.20,0.20,0.21,0.21,0.17,0.20];
//If RPV = Solar Building in IEA (2020). No data for RPV for AUS, assumed that AUS =USA
elecENRInitial.loadFactor.RPV               =    [0.16,0.11,0.11,mean([0.12,0.16]),0.09,0.13,0.15,0.16,0.17,0.17,0.13,0.16];
//Missing Japan and Russia in this dataset : JAP = CHI, CEI = EUROPE
elecENRInitial.loadFactor.CSP               =    [0.28,0.30,0.30,mean([0.28,0.47]),0.30,0.28,0.26,0.28,0.30,0.30,0.28,0.28];

//Can use 2040 capacity factor estimates from IEA. Would increase CSP competitivity as well as offshore's
//For AUS, kept values from IRENA when available
elecENRInitial.loadFactor2040.WND           =    [0.44,0.44,0.31,mean([0.30,0.42]),0.31,0.27,0.29,0.44,0.31,0.30,0.27,0.44];
elecENRInitial.loadFactor2040.WNO           =    [0.48,0.48,0.59,mean([0.46,0.51]),0.44,0.44,0.38,0.55,0.38,0.44,0.44,0.55];
elecENRInitial.loadFactor2040.CSP           =    [0.38,0.38,0.40,mean([0.38,0.47]),0.40,0.38,0.36,0.38,0.40,0.40,0.38,0.38];
elecENRInitial.loadFactor2040.CPV           =    [0.23,0.23,0.14,mean([0.13,0.28]),0.13,0.19,0.21,0.21,0.23,0.24,0.19,0.21];
elecENRInitial.loadFactor2040.RPV           =    [0.17,0.17,0.12,mean([0.12,0.17]),0.11,0.15,0.18,0.17,0.19,0.19,0.15,0.17];
// the variable Load_factor_ENR is in thousand hours of functionning
for techno = techno_RE_names
    execstr("elecENRInitial.loadFactor."+techno+"=elecENRInitial.loadFactor."+techno+"*full_load_hours/th_to_h");
end

//Lifetimes
//Source : IEA (2020) Projected Cost of Generating Electricity p; 36
elecENRInitial.lifetime.WND                 =    25;
elecENRInitial.lifetime.WNO                 =    25; 
elecENRInitial.lifetime.CPV                 =    25; 
elecENRInitial.lifetime.RPV                 =    25; 
// Source:Bogdanov et al.(2015) Low-cost renewable electricity as the key driver of the global energy transition towards sustainability p. 19
elecENRInitial.lifetime.CSP                 =    25; 
//PING_FL####################################
//Cost asymptote: various estimations, for scenarios
IEA_Cost_Asym.WND                           = [1300,940]*CPI_2019_to_2014;
IEA_Cost_Asym.WNO                           = [1420,1000]*CPI_2019_to_2014;
IEA_Cost_Asym.CPV                           = [340,220]*CPI_2019_to_2014;

//RTE (2021) "Bilan prévisionnel long terme  «Futurs énergétiques 2050" p. 83 in 2018€/kW
RTE_Cost_Asym.WND.low                       = 530*CPI_2018_to_2014 *EUR_to_USD;
RTE_Cost_Asym.WND.ref                       = 900*CPI_2018_to_2014 *EUR_to_USD;
RTE_Cost_Asym.WND.high                      = 1300*CPI_2018_to_2014 *EUR_to_USD;

RTE_Cost_Asym.WNO.low                       = 700*CPI_2018_to_2014 *EUR_to_USD;
RTE_Cost_Asym.WNO.ref                       = 1300*CPI_2018_to_2014 *EUR_to_USD;
RTE_Cost_Asym.WNO.high                      = 1900*CPI_2018_to_2014 *EUR_to_USD;

//adding a very low cost asymptotes because otherwise floor cost is reached everywhere between 2030 and 2040
Cost_asym_CPV_verylow                       = 300;
RTE_Cost_Asym.CPV.low                       = 430*CPI_2018_to_2014 *EUR_to_USD;
RTE_Cost_Asym.CPV.ref                       = 480*CPI_2018_to_2014 *EUR_to_USD;
RTE_Cost_Asym.CPV.high                      = 530*CPI_2018_to_2014 *EUR_to_USD;
//"PV grande toiture" for RPV in RTE
RTE_Cost_Asym.RPV.low                       = 600*CPI_2018_to_2014 *EUR_to_USD;
RTE_Cost_Asym.RPV.ref                       = 680*CPI_2018_to_2014 *EUR_to_USD;
RTE_Cost_Asym.RPV.high                      = 770*CPI_2018_to_2014 *EUR_to_USD;
//PING_FL########################################

//For CSP and RPV, values from Bogdanov et al.(2015)
//TB: A very optimistic hypothesis for RPV, need to find other estimated for scenarios
elecENRInitial.investmentCostAsymptote.WND  =    RTE_Cost_Asym.WND.ref;
elecENRInitial.investmentCostAsymptote.WNO  =    RTE_Cost_Asym.WNO.ref; 
elecENRInitial.investmentCostAsymptote.CSP  =    2000*CPI_2015_to_2014*EUR_to_USD;  //600 from Bogdanov appears to be wait to low. //PING_FL
//Need to keep in mind the role of CSP and how it is managed, this will be discussed soon
elecENRInitial.investmentCostAsymptote.CPV  =    Cost_asym_CPV_verylow; 
elecENRInitial.investmentCostAsymptote.RPV  =    RTE_Cost_Asym.RPV.ref; 



//Learning rate. Source: IAE (2020) "Power generation assumptions in the Stated Policies and SDS Scenarios in the World Energy Outlook 2020"
//TB: might be too optimistic, scenario here?
elecENRInitial.lrCons.WND                   =    0.05;
elecENRInitial.lrCons.WNO                   =    0.15;
elecENRInitial.lrCons.CSP                   =    0.1; 
elecENRInitial.lrCons.CPV                   =    0.2;
elecENRInitial.lrCons.RPV                   =    0.2; 

//Installed cap
//R Script here. Assumption offgrid = rooftop PV might be irrelevant, better assume a given share? Minor when RPV and CPV share the shame PR
[elecENRInitial.cap.WND,elecENRInitial.descrip.cap.WND]                  =    csvRead(path_elec_cap+'Cap_2014_WND.csv',';',[],[],[],'/\/\//');
[elecENRInitial.cap.WNO,elecENRInitial.descrip.cap.WNO]                  =    csvRead(path_elec_cap+'Cap_2014_WNO.csv',';',[],[],[],'/\/\//');
[elecENRInitial.cap.CSP,elecENRInitial.descrip.cap.CSP]                  =    csvRead(path_elec_cap+'Cap_2014_CSP.csv',';',[],[],[],'/\/\//');
[elecENRInitial.cap.CPV,elecENRInitial.descrip.cap.CPV]                  =    csvRead(path_elec_cap+'Cap_2014_CPV.csv',';',[],[],[],'/\/\//');
[elecENRInitial.cap.RPV,elecENRInitial.descrip.cap.RPV]                  =    csvRead(path_elec_cap+'Cap_2014_RPV.csv',';',[],[],[],'/\/\//');

//must be discussed: assumed that no VRE capital was retired yet in 2014, meaning that the existing capital = cumulated investment.
for techno = techno_RE_names
    execstr("elecENRInitial.cumulatedInvRef."+techno+"=elecENRInitial.cap."+techno);
end


//===================================//
//Storage Calibration
//===================================//

//Storage cost assumptions: exogenous capacity given as a share of solar + wind power
/// representative technology: Battery cost projections for 4-hour lithium-ion (Cost Projections for Utility-Scale Battery Storage: 2021 Update)

//storage cost in 2020$/kWh
CINV_storage_2020 = 350 * CPI_2020_to_2014 * 4; // 4 hours of storage
// assumption for 2015: same slope as 2020-2025 in the "Low" scenario = - 100$/kWh in five years
CINV_storage_2015 = 450 * CPI_2020_to_2014 * 4; // 

// assuming a linear cost decrease between 2020 and 2050, depending on the assumption

CINV_storage_2050.high = 250 * CPI_2020_to_2014 * 4; 
CINV_storage_2050.mid = 150 * CPI_2020_to_2014 * 4;
CINV_storage_2050.low = 100 * CPI_2020_to_2014 * 4;

CINV_storage_2050 = CINV_storage_2050.mid;

CINV_storage_nexus = zeros(reg,TimeHorizon+1);

CINV_storage_nexus(:,1:2020-base_year_simulation) = repmat(linspace(CINV_storage_2015,CINV_storage_2020,2020-base_year_simulation),reg,1);
CINV_storage_nexus(:, (2020-base_year_simulation) : (2050 - base_year_simulation) ) = repmat(linspace(CINV_storage_2020,CINV_storage_2050,2050-2020+1),reg,1);
CINV_storage_nexus(:,(2050 - base_year_simulation):$ ) = CINV_storage_2050;

// Annualized cost of storage

//Assuming a 15 years lifetime for storage
Lifetime_storage = 15; //15 years for storage, NREL

//--------------------------------------------------------------------//
//---------------------- PV annual degradation ------------------------//
//--------------------------------------------------------------------//
//need to find a source
deg_rate_pv = 0.5/100; 

avg_deg_rate = zeros(reg, ntechno_elec_total);



/////////////////////////////////////////////////////////////////////////////////////////////
//    ---*---   GENERAL CALIBRATION   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////

//===================================//
//Initial elec demand
//===================================//

Q_elec_init = Qref(:,indice_elec)*mtoe2mwh;

if calib_profile_cost==1
    // long-term utilization integration costs: project in a world with x 4 2015 electric demand 
    Q_elec_init = Q_elec_init*4;
end
//===================================//
//Lifetimes
//===================================//

Life_time=10*ones(nb_regions,techno_elec); //to avoid zero division for unused elec technos


//p.36 Projected Cost of Generating Electricity 2020 IEA 
Life_time(:,technoElecCoal) = 40;
Life_time(:,technoElecGas) = 30;
Life_time(:,technoOil) = 20; //Lazard (2014) Lazard's Levelized Cost of Energy Analysis v.8.0

Life_time(:,indice_HYD)= 80;
Life_time(:,indice_NUC)= 60;
Life_time(:,indice_CHP)= 15; //old POLES value
Life_time(:,indice_SHY)= 30; //old POLES value
Life_time(:,technoBiomass) = elecBiomassInitial.lifetime;
Life_time(:,indice_STR)= Lifetime_storage; //old POLES value
for techno = techno_RE_names
    execstr("Life_time(:,indice_"+techno+")=elecENRInitial.lifetime."+techno);
end

//Initializing variables
//Lifetime of technologies

Life_time_max=max(Life_time);
Life_time_max_FF = max(Life_time(:,[technoFossil,technoBiomass]));

//--- Life-time adjustement for truncaded LCC computation
// to get a proper short term horizon for investment, we assume that the lifetime of the techno is the same as the time horizon of the model, to compute truncated LCC.
if ind_short_term_hor == 1
    Life_time_LCC = min(Life_time, nb_year_expect_LCC); // Life_time_LCC replaces Life_time when computing truncated LCC components
else
    Life_time_LCC = Life_time;
end


//===================================//
//Capital costs for all technos
//===================================//
CINV_MW_ITC_ref = ones(nb_regions,techno_elec)*10^6; // prevent division by zero, high capex for unused technos
//correction pour les autres technologies
CINV_MW_ITC_ref(:,indice_PFC) = [2100,2100,2000,2400,2000,700,1200,1600,1600,1600,700,1600]' * CPI_2019_to_2014;
CINV_MW_ITC_ref(:,indice_ICG) = [2600,2600,2500,2900,2500,1100,1600,2000,2000,2200,1100,2000]' * CPI_2019_to_2014;
CINV_MW_ITC_ref(:,indice_SUB)= [1800,1800,1700,2100,1700,600,1000,1300,1300,1300,600,1300]' * CPI_2019_to_2014;
CINV_MW_ITC_ref(:,indice_USC)= [2300,2300,2200,2600,2200,800,1400,1800,1600,1900,800,1800]'* CPI_2019_to_2014;
CINV_MW_ITC_ref(:,indice_GGT) = [500,500,500,500,450,350,400,400,450,400,350,400]'* CPI_2019_to_2014;
CINV_MW_ITC_ref(:,indice_GGC)= [1000,1000,1000,1100,800,560,700,700,800,700,560,700]'* CPI_2019_to_2014;  		// Gas-powered Gas Turbine in Combined Cycle 
//Lazard (2014) Lazard's Levelized Cost of Energy Analysis v.8.0
//Diesel Generator: previous value of 650 was overly pessimistic, need to find a better source
CINV_MW_ITC_ref(:,indice_OCT) = 300; //already in USD2014
//for combined cycle, we add the mean difference between gas CT and CC 
CINV_MW_ITC_ref(:,indice_OGC) =CINV_MW_ITC_ref(:,indice_OCT) +  mean(CINV_MW_ITC_ref(:,indice_GGC)-CINV_MW_ITC_ref(:,indice_GGT));
CINV_MW_ITC_ref(:,indice_NUC) = [5000,5000,6000,4200,3800,2600,2800,4000,3500,4000,2600,4000]'* CPI_2019_to_2014; //Nuke is more costly than expected in 2001
CINV_MW_ITC_ref(:,indice_HYD) = [2700,2700,2650,2400,2650,1600,2000,2100,2150,2100,1600,2100]'* CPI_2019_to_2014; //hydro large scale unit

// Biomass
for techno = techno_biomass_names
    execstr("CINV_MW_ITC_ref(:,indice_"+techno+")=elecBiomassInitial.invCost."+techno);
end

//RE
for techno = techno_RE_names
    execstr("CINV_MW_ITC_ref(:,indice_"+techno+")=elecENRInitial.invCost."+techno);
end

/////CC case: we define overcosts to install CCS, on top of which we will add learning by doing in $/kW
CINV_MW_ITC_CCS_PFC_ref = 3000* CPI_2019_to_2014; //central value from IEA WEO 2020 assumptions
CINV_MW_ITC_CCS_ICG_ref = 3000* CPI_2019_to_2014;//central value from IEA WEO 2020 assumptions
CINV_MW_ITC_CCS_GGS_ref = 2000* CPI_2019_to_2014;//central value from IEA WEO 2020 assumptions
CINV_MW_ITC_CCS_UCS_ref = CINV_MW_ITC_CCS_PFC_ref;
//PING_FL#################
CINV_MW_ITC_CCS_PFC = CINV_MW_ITC_CCS_PFC_ref;
CINV_MW_ITC_CCS_ICG = CINV_MW_ITC_CCS_ICG_ref;
CINV_MW_ITC_CCS_GGS = CINV_MW_ITC_CCS_GGS_ref;
CINV_MW_ITC_CCS_UCS = CINV_MW_ITC_CCS_UCS_ref;

///Base year CAPEX for CCS
CINV_MW_ITC_ref(:,indice_PSS)    = CINV_MW_ITC_ref(:,indice_PFC)   + CINV_MW_ITC_CCS_PFC_ref;
CINV_MW_ITC_ref(:,indice_CGS)    = CINV_MW_ITC_ref(:,indice_ICG)   + CINV_MW_ITC_CCS_ICG_ref;
CINV_MW_ITC_ref(:,indice_UCS)    = CINV_MW_ITC_ref(:,indice_USC)   + CINV_MW_ITC_CCS_ICG_ref;//new
CINV_MW_ITC_ref(:,indice_GGS)    = CINV_MW_ITC_ref(:,indice_GGC)   + CINV_MW_ITC_CCS_GGS_ref;               

//unused technos : set prohibitive CAPEX 
CINV_MW_ITC_ref(:,indice_CHP)=10000000;
CINV_MW_ITC_ref(:,indice_SHY)=10000000;
CINV_MW_ITC_ref(:,indice_NND)=10000000;
CINV_MW_ITC_ref(:,indice_STR)=10000000;
CINV_MW_ref=CINV_MW_ITC_ref; //in v2 CINV_MW_ref serves for linear progression of capital costs from 2014 to 2019


//=============================================//
//Asymptotic capital costs
//=============================================//

/////Asymptot definitions for capital costs
A_CINV_MW_ITC_ref=CINV_MW_ITC_ref;

//No better than IEA 2040 costs as asymptotes. Nothing displayed when no variations between 2019 and 2040 costs
A_CINV_MW_ITC_ref(:,indice_ICG)= [2400,2400,2300,2700,2300,900,1500,1900,1900,2100,900,1900]' * CPI_2019_to_2014; //

// Biomass
for techno = techno_biomass_names
    execstr("A_CINV_MW_ITC_ref(:,indice_"+techno+")=elecBiomassInitial.investmentCostAsymptote."+techno);
end

//For CSP and CPV : Bogdanov et al.(2015) Low-cost renewable electricity as the key driver of the global energy transition towards sustainability p.17
//TB: assumed 2015EUR since I did not find any clue about it
A_CINV_MW_ITC_ref(:,indice_WND) = elecENRInitial.investmentCostAsymptote.WND;
A_CINV_MW_ITC_ref(:,indice_WNO) = elecENRInitial.investmentCostAsymptote.WNO;

A_CINV_MW_ITC_ref(:,indice_CSP) = elecENRInitial.investmentCostAsymptote.CSP;
A_CINV_MW_ITC_ref(:,indice_CPV) = elecENRInitial.investmentCostAsymptote.CPV;
A_CINV_MW_ITC_ref(:,indice_RPV) = elecENRInitial.investmentCostAsymptote.RPV;

//CCS+ capital cost asymptote. Strictly no idea about it and no info about past values, scenarios here?
aCInvMW_ITC_CCS_PFCref=1000;
aCInvMW_ITC_CCS_ICGref=1000;
aCInvMW_ITC_CCS_UCSref =1000; //new

//asymptot for sequestration technologies
A_CINV_MW_ITC_ref(:,indice_PSS)    = A_CINV_MW_ITC_ref(:,indice_PFC)  + aCInvMW_ITC_CCS_PFCref;
A_CINV_MW_ITC_ref(:,indice_CGS)    = A_CINV_MW_ITC_ref(:,indice_ICG)  + aCInvMW_ITC_CCS_ICGref;
A_CINV_MW_ITC_ref(:,indice_UCS)    = A_CINV_MW_ITC_ref(:,indice_USC)  + aCInvMW_ITC_CCS_UCSref; //new
A_CINV_MW_ITC_ref(:,indice_GGS)    = A_CINV_MW_ITC_ref(:,indice_GGC)  + aCInvMW_ITC_CCS_ICGref;                                 


//===================================================//
//Fossil fuel prices
//===================================================//

priceCoalElec=zeros(nb_regions,TimeHorizon+nb_year_expect);
priceGazElec=zeros(nb_regions,TimeHorizon+nb_year_expect);
priceEtElec=zeros(nb_regions,TimeHorizon+nb_year_expect);


for k=1:nb_regions
    for j=1:nb_year_expect
        priceCoalElec(k,j)=pArmCIref(indice_coal,indice_elec,k);
        priceGazElec(k,j)=pArmCIref(indice_gas,indice_elec,k);
        priceEtElec(k,j)=pArmCIref(indice_Et,indice_elec,k);
        // Q_elec(k,j)=Qref(k,indice_elec)/(1+tx_eptop_POLES(k))^(nb_year_expect-j);
    end
end
//Nuclear Fuel costs from IEA & NEA (2020) Projected costs of generating electricity, p.39. Includes front-end + back-end use (2018 USD)
Nuc_fuel_cost_kwh=((7+2.33)/1000)*CPI_2018_to_2014;

//===================================//
//Market shares
//===================================//

//within each type of technology (sums to 1 per type, n = ntechno_elec_total)
for tranche=tranches_elec
    execstr("MSH_"+tranche+"_type_norm= zeros(reg,nTechno_dispatch);")
end

//MSH per type of technology (n = n_type_elec)
for tranche=tranches_elec
    execstr("MSH_"+tranche+"_type= zeros(reg,n_type_elec);")
end

//Transitory variable to get MSH in % of total electricity supply (n = n_type_elec)
for tranche=tranches_elec
    execstr("MSH_"+tranche+"_type_new= ones(reg,n_type_elec);")
end

//Constraint on market shares, in % of total electricity supply (n = n_type_elec)
for tranche=tranches_elec
    execstr("MSH_"+tranche+"_type_sup= ones(reg,n_type_elec);")
end

for tranche=tranches_elec
    execstr("LCC_"+tranche+"_type= zeros(reg,n_type_elec);")
end


// Maximum market share for nuclear 
j = find(techno_dispatch_type  == "Nuke");
MSH_8760_type_sup(:, j)=nuc_cff*[ 0.3,0.3,0.4,0.3,0.2,0.2,0.2,0.1,0.1,0.1,0.1,0.1]';
MSH_8030_type_sup(:, j)=nuc_cff*[ 0.3,0.3,0.4,0.3,0.2,0.2,0.2,0.1,0.1,0.1,0.1,0.1]';
MSH_6570_type_sup(:, j)=nuc_cff*[ 0.3,0.3,0.4,0.3,0.2,0.2,0.2,0.1,0.1,0.1,0.1,0.1]';
MSH_5110_type_sup(:, j)=nuc_cff*[ 0.3,0.3,0.4,0.3,0.2,0.2,0.2,0.1,0.1,0.1,0.1,0.1]';
MSH_3650_type_sup(:, j)=nuc_cff*[ 0.3,0.3,0.4,0.3,0.2,0.2,0.2,0.1,0.1,0.1,0.1,0.1]'*1/2;
MSH_2190_type_sup(:, j)=nuc_cff*[ 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]';
MSH_730_type_sup(:, j)=nuc_cff*[ 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]';

// The MSH sup for CSP is temporary so as to manage the share of CPS manually.
j = find(techno_dispatch_type  == "CSP");
MSH_8760_type_sup(:, j) = 0.05*ones(reg,1);
MSH_8030_type_sup(:, j) = 0.05*ones(reg,1);
MSH_6570_type_sup(:, j) = 0.05*ones(reg,1);
MSH_5110_type_sup(:, j) = 0.05*ones(reg,1);
MSH_3650_type_sup(:, j) = 0.02*ones(reg,1);
MSH_2190_type_sup(:, j) = 0.02*ones(reg,1);
MSH_730_type_sup(:, j) = 0.02*ones(reg,1);

// Same for Biomass without CCS. Biomass with CCS depends on the availability of feedstock supply. The profitability of biomass is very sensitive to the local context (IRENA, RENEWABLE POWER GENERATION COSTS IN 2022)
j = find(techno_dispatch_type  == "BiomassWOCCS");
MSH_8760_type_sup(:, j) = 0.1*ones(reg,1);
MSH_8030_type_sup(:, j) = 0.1*ones(reg,1);
MSH_6570_type_sup(:, j) = 0.1*ones(reg,1);
MSH_5110_type_sup(:, j) = 0.1*ones(reg,1);
MSH_3650_type_sup(:, j) = 0.1*ones(reg,1);
MSH_2190_type_sup(:, j) = 0.1*ones(reg,1);
MSH_730_type_sup(:, j) = 0.1*ones(reg,1);

//We limit the resizing of constraints on market shares
limit_MSH_resize=0.4;

//correction for hydro market share: this has the interest of adding hydro the dispatchable vs VRE logit node and avoid overinvesting in VRE. This makes no sense to massively investment in VRE in regions were hydro potential is important (e.g. canada & brazil)
correc_hydro = 0.6; 


//===================================//
//Installed capacities
//===================================//

//===================================//


Cap_elec_MW_temp=csvRead(path_elec_capac_MW+'capac_elec.csv','|',[],[],[],'/\/\//');

Cap_elec_MWref=matrix(Cap_elec_MW_temp,nb_regions,techno_elec);

///////Introducing new hydro from POLES. 
//A switch depending on ind_climat allows from baseline/climate scenario trajectories for hydro capacity additions
Cap_hydro_bau=load_hydro(DATA+'Enerdata\POLES_hydro\Cap_climat.csv');
Cap_hydro_clim=load_hydro(DATA+'Enerdata\POLES_hydro\Cap_baseline.csv');

Cap_hydro = Cap_hydro_bau;
if ~is_bau
    ind_temp = start_year_strong_policy-base_year_simulation+1;
    Cap_hydro(:,ind_temp-1:ind_temp-1+3) = Cap_hydro_bau(:,ind_temp-1:ind_temp-1+3) .* (ones(nb_regions,1)*linspace(1,0,4))+ Cap_hydro_clim(:,ind_temp-1:ind_temp-1+3) .* (1- ones(nb_regions,1)*linspace(1,0,4));
    Cap_hydro(:,ind_temp-1+3:$) = Cap_hydro_clim(:,ind_temp-1+3:$); 
end
Cap_elec_MWref(:,indice_HYD)=Cap_hydro(:,1); //hydro at base year

//===================================//
//New Installed capacities
//===================================//


[Cap_elec_MWref_coal.Cap,Cap_elec_MWref_coal.Descp] = csvRead(path_elec_capac_MW_new+'Cap_MW_ref_Coal.csv',',',[],[],[],'/\/\//');
[Cap_elec_MWref_gas.Cap,Cap_elec_MWref_gas.Descp] = csvRead(path_elec_capac_MW_new+'Cap_MW_ref_Gas.csv',',',[],[],[],'/\/\//');
[Cap_elec_MWref_oil.Cap,Cap_elec_MWref_oil.Descp] = csvRead(path_elec_capac_MW_new+'Cap_MW_ref_Oil.csv',',',[],[],[],'/\/\//');
Cap_elec_MWref_coal.Cap=Cap_elec_MWref_coal.Cap(:,1);//apparently, issues with decimal, this fixes everything
Cap_elec_MWref_gas.Cap=Cap_elec_MWref_gas.Cap(:,1);
Cap_elec_MWref_oil.Cap=Cap_elec_MWref_oil.Cap(:,1);

[Cap_elec_MWref_nuke.Cap,Cap_elec_MWref_nuke.Descp] = csvRead(path_elec_nuke_MW_new+'Nuke2014.csv',';',[],[],[],'/\/\//');

//Dispatching coal, gas and oil capacities between technologies

//Coal : //https://www.iea.org/reports/coal-fired-power
Cap_elec_MWref(:,indice_SUB) = 0.6* Cap_elec_MWref_coal.Cap; //4500 GW out of 7500 in 2014
Cap_elec_MWref(:,indice_PFC) = (20/75)* Cap_elec_MWref_coal.Cap; // 2000 GW out of 7500
Cap_elec_MWref(:,indice_ICG) = 0.1*(10/75)* Cap_elec_MWref_coal.Cap; // USC + ICG accounts for 1000 out of 7500. Hyp : ICG = 10%. Cannot find better support for this hyp than a rule of thumb, very scarce data, the techno seem anecdotic for now
Cap_elec_MWref(:,indice_USC) = 0.9*(10/75)* Cap_elec_MWref_coal.Cap; 

//Gas : https://www.eia.gov/todayinenergy/detail.php?id=39012 gives a picture for USA : 50% combined cycle
//Maybe differential assumption for emerging economies?
Cap_elec_MWref(:,indice_GGC) = 0.5*Cap_elec_MWref_gas.Cap;
Cap_elec_MWref(:,indice_GGT) = 0.5*Cap_elec_MWref_gas.Cap;

//Oil. For oil, really no idea. Let's say old fashion oil boilers are dominant (90% - 10%), what old POLES data suggests.

Cap_elec_MWref(:,indice_OCT) = Cap_elec_MWref_oil.Cap; //single oil peaker techno

Cap_elec_MWref(:,indice_NUC) = Cap_elec_MWref_nuke.Cap; 
Cap_elec_MWref(:,indice_NND) = 0; //zero NND installed

for techno_CCS = [indice_PSS,indice_CGS,indice_UCS, indice_GGS, indice_BIS]
    Cap_elec_MWref(:,techno_CCS)  = 0; //zero CCS installed
end

//unused technos for now. Can not set the Cap to zero, otherwise 2915 equilibrium fails
Cap_elec_MWref(:,indice_CHP)=0;
Cap_elec_MWref(:,indice_SHY)=0;
Cap_elec_MWref(:,indice_STR)=0;

for techno = techno_RE_names 
    execstr("Cap_elec_MWref(:,indice_"+techno+")=elecENRInitial.cap."+techno);
end

for techno = ["SBI","BIG"] // adding the two conventionnal biomass techno
    execstr("Cap_elec_MWref(:,indice_"+techno+")=elecBiomassInitial.cap."+techno);
end

Life_time_max=max(Life_time);
Cap_elec_MW_vintage=zeros(techno_elec,Life_time_max+TimeHorizon+1,nb_regions);

Cap0_elec_MW=zeros(nb_regions,techno_elec);

// Computing the capacity installed in the past, nb_time_lifetime * Life_time_max in the past, assuming a growth rate
// increase of txCap_MW
for j=1:techno_elec
    for k=1:nb_regions
        Cap0_elec_MW(k,j)=Cap_elec_MWref(k,j)./(1+txCap_MW(k,j)).^(( nb_time_lifetime*Life_time_max));
    end
end

Caphistelec_MW=zeros(nb_regions,techno_elec, nb_time_lifetime * Life_time_max+1);
construitelec_MW=zeros(nb_regions,techno_elec, nb_time_lifetime * Life_time_max);

for j=1:techno_elec
    for k=0:( nb_time_lifetime*Life_time_max)
        Caphistelec_MW(:,j,k+1)=Cap0_elec_MW(:,j).*(ones(nb_regions,1)+txCap_MW(:,j)).^(ones(nb_regions,1)*k);
    end
end

for j=1:techno_elec
    for k=1:Life_time_max
        construitelec_MW(:,j,k)=(Caphistelec_MW(:,j,k+1)-Caphistelec_MW(:,j,k))+Cap0_elec_MW(:,j)./Life_time_max;
    end
end

for j=1:techno_elec
    for k=(Life_time_max+1):(nb_time_lifetime*Life_time_max)
        for kk=1:nb_regions
            construitelec_MW(kk,j,k)=Caphistelec_MW(kk,j,k+1)-Caphistelec_MW(kk,j,k)+construitelec_MW(kk,j,k-Life_time(kk,j,1));
        end
    end
end

for j=1:techno_elec
    for kk=1:nb_regions
        for k=1:Life_time(kk,j,1)
            Cap_elec_MW_vintage(j,Life_time_max-Life_time(kk,j,1)+k,kk)=construitelec_MW(kk,j,nb_time_lifetime*Life_time_max-Life_time(kk,j,1)+k);
        end
    end
end

//====================================================//
//Efficiency
//====================================================//
//===================================//

rho_elec=zeros(nb_regions,techno_elec,TimeHorizon);

rho_poles_temp=csvRead(path_elec_yields+'electric_conversion_yields.csv','|',[],[],[],'/\/\//');

// expand vector until the end of the simulation Time Horizon
size_temp=size(rho_poles_temp);
for k=1:50                                                
    rho_poles_temp(:,size_temp(2)+k)=rho_poles_temp(:,size_temp(2));
end

//exogenous trajectories are starting from 2001 (calibrated for previous version of the model), so we keep only the values starting from starting year of simulation
size_temp=size(rho_poles_temp);
rho_poles_temp=rho_poles_temp(:,base_year_simulation-2000:size_temp(2));



for j=1:TimeHorizon
    for ind_technoElecIM=1:technoConvwoCSP//wo CSP
        rho_elec(1:nb_regions,ind_technoElecIM,j)=rho_poles_temp(ind_POLES(ind_technoElecIM), j+22);
    end
    for k = 1:nb_regions
        rho_elec(k,indice_BIG ,j) = elecBiomassInitial.efficiency.BIG;
        rho_elec(k,indice_BIS,j) = elecBiomassInitial.efficiency.BIS;
        rho_elec(k,indice_SBI,j) = elecBiomassInitial.efficiency.SBI;
    end
end


rho_elec_vintage=zeros(nb_regions,techno_elec,Life_time_max+TimeHorizon+1);
rho_elec_hist=rho_elec(:,:,1);
// average historical efficiency calibration, for it to be consistent with the intermediate consumption CI reconstruction
load(path_elec_hist_share+'share_OIL_EP_REF.dat');
load(path_elec_hist_share+'share_GAS_EP_REF.dat');
load(path_elec_hist_share+'share_COL_EP_REF.dat');

for k=1:nb_regions
    for j=technoOil
        rho_elec_hist(k,j)=share_OIL_EP_REF(k,1)*Qref(k,indice_elec)/(CI(indice_Et,indice_elec,k)*Qref(k,indice_elec));
    end
    for j=technoElecGas
        rho_elec_hist(k,j)=share_GAS_EP_REF(k,1)*Qref(k,indice_elec)/(CI(indice_gas,indice_elec,k)*Qref(k,indice_elec));
    end
    for j=technoElecCoal
        rho_elec_hist(k,j)=share_COL_EP_REF(k,1)*Qref(k,indice_elec)/(CI(indice_coal,indice_elec,k)*Qref(k,indice_elec));
    end
end

for j=1:Life_time_max+1
    rho_elec_vintage(:,:,j)=rho_elec_hist;
end

for j=Life_time_max+1:Life_time_max+TimeHorizon
    rho_elec_vintage(:,:,j)=rho_elec(:,:,j-Life_time_max); //replace rho_elec(:,:,j-Life_time_max) by rho_elec_hist to check that the new index system provides the same results
end


//Correcting POLES values

rho_elec(:,indice_PFC,1) = [43,43,43,43,43,41,40,43,41,39,41,43]'/100;
//rho_elec(k,indice_PFC,1)=0.45;   	// Super Critical pulverised coal
rho_elec(:,indice_PSS,1)= [36,36,36,36,36,35,31,35,35,32,35,35]'/100; //Supp hyp : BRA & MDE = CHN
//rho_elec(k,indice_PSS,1)=0.35;   	// Super Critical pulverised coal with sequestration
rho_elec(:,indice_ICG,1) = [44,44,44,44,44,43,41,44,42,40,43,44]'/100;
//rho_elec(k,indice_ICG,1)=0.42;   	// Integrated Coal Gasification with Combined Cycle

rho_elec(:,indice_CGS,1)=0.36;   	// Integrated Coal Gasification with Combined Cycle with sequestration. No IEA value so keep existing one
//rho_elec(k,indice_LCT,1)=;              // Lignite-powered Conventional Thermal
rho_elec(:,indice_SUB,1) = [39,39,39,39,39,37,36,39,37,35,37,39]'/100;
rho_elec(:,indice_USC,1) = [45,45,45,45,45,44,40,45,43,42,44,45]'/100;
rho_elec(:,indice_UCS,1) = rho_elec(:,indice_PSS,1)+ 2/100; //assume that there is the same diff between UCS/PSS and USC/PFC, which is roughly of 2% in IEA data
//rho_elec(k,indice_CCT,1)=0.35;   	// Coal-powered Conventional Thermal
//rho_elec(k,indice_GCT,1)=0.35;   	    // Gas-powered Conventional Thermal TAV
rho_elec(:,indice_GGT,1)=[40,40,40,40,38,38,38,38,38,38,38,38]'/100;
//rho_elec(k,indice_GGT,1)=0.35;   	// Gas-powered Gas Turbine TAC
rho_elec(:,indice_GGS,1) = [51,51,51,51,49,49,48,49,49,50,49,49]'/100; //Hyp supp: BRA = CHN
//rho_elec(k,indice_GGS,1)=0.47;   	// Gas-powered Gas Turbine in Combined Cycle with sequestration       
rho_elec(:,indice_GGC,1) = [59,59,59,59,57,57,56,58,57,58,57,58]'/100;
//rho_elec(k,indice_GGC,1)=0.53;   	// Gas-powered Gas Turbine in Combined Cycle
//Lazard (2014) Lazard's Levelized Cost of Energy Analysis v.8.0
//Diesel Generator
rho_elec(:,indice_OCT,1)=kwh2btu/10000;   	// Oil-powered Conventional Thermal
rho_elec(:,indice_OGC,1)= rho_elec(:,indice_OCT,1) + mean(rho_elec(:,indice_GGS,1) - rho_elec(:,indice_GGT,1)) ;     	    // Oil-powered Gas Turbine in Combined Cycle                          


for techno = techno_biomass_names
    execstr("rho_elec(:,indice_"+techno+")=elecBiomassInitial.efficiency."+techno);
end

//the backward calibration of gas efficiency on aggr SAM data yields very low values for gas efficiency
if ind_new_rho_calib == 1 
    rho_elec_vintage = repmat(rho_elec(:,:,1),1,1,Life_time_max+TimeHorizon+1);
end

Cap_elec_MW_vintage_prev=Cap_elec_MW_vintage;

//===================================//

//Availability factor to replace ava_to_inst_poles variable
avail_factor = ones(reg,techno_elec);
Utilrate=ones(reg,techno_elec);
first_run_ava = 1;
//===================================//
//availability factor for hydro

if ind_climat==1
    AF_hydro=csvRead(DATA+'Enerdata\POLES_hydro\AF_climat.csv',';',[],[],[],'/\/\//');
else
    AF_hydro=csvRead(DATA+'Enerdata\POLES_hydro\AF_baseline.csv',';',[],[],[],'/\/\//');
end

    
nhydroyear = length(AF_hydro)/reg;

AF_hydro_process = zeros(reg,TimeHorizon+nb_year_expect_futur+1);
for i=1:reg
    bot = 1 + (i-1)*37;
    up = i*37;
    AF_hydro_process(i,1:nhydroyear) = AF_hydro(bot:up)'; //Transforming in 12x37 (for 2050) data
end
// and turning it into a TimeHorizon-long dataframe. We assume for now that there is no additionnal hydro after 2050

for k=(nhydroyear+1):TimeHorizon+nb_year_expect_futur+1
    AF_hydro_process(:,k)=AF_hydro_process(:,nhydroyear);
end
AF_hydro = AF_hydro_process;


//"NREL (2010) Cost and Performance Assumptions for Modeling Electricity Generation Technologies"
avail_factor(:,[technoCoalWOCCS,technoCoalWCCS]) = mean([85,85,80,85,80])/100; //Coal
avail_factor(:,[indice_ICG,indice_CGS]) = mean([85,81,80,85,80])/100; //IGCC
avail_factor(:,[indice_GGT,indice_OCT]) = mean([92,88,92])/100; //Combustion turbine. Removed the MiniCam value : mistake (10%)?
avail_factor(:,[indice_GGC,indice_GGS,indice_OGC]) = mean([87,85,80,87,80])/100; //Combined cycle
//LFH assumption from Levelized Cost of Electricity- Renewable Energy Technologies (Fraunhofer ISE, 2021)
avail_factor(:,[technoBiomass]) = 80/100; //Biomass
avail_factor(:,indice_HYD) = AF_hydro(:,1);
avail_factor(:,indice_CSP) = elecENRInitial.loadFactor.CSP'*1000/8760;
//IEA (2020) Projected Costs of Generating Electricity - 2020 Edition
avail_factor(:,technoNuke) = 0.85;

// the significance of the availability factor is not very clear ATM
// actually, two things must be differentiated in the AF: planned and forced outages
// planned outages are due to maintenance, and are planned in advance when the demand (and the price of electricity) is low
// => if only planned outages, the capacity credit of a plant is 100%
// meaning that planned outages are only costly for base load plants. The reason to differentiated between the two is especially meaningful for the calibration of profile costs
// indeed, with the VRE distorting the load residual curve toward more peaky shapes, it permitted to reduce extra base capacity in order to deal with planned outages.
// as explained, http://dx.doi.org/10.1016/j.eneco.2016.12.006, the AF of hydro is explained by planned outages
// and since we assume that hydro is dispatched first, this means that the capacity credit of hydro is reduced, because outages can not be planned when the demand is low
avail_factor(:,[technoElecCoal,technoElecGas,technoOil,technoNuke,technoBiomass]) = 0.95;

// forced outages will be added in a second step. This only increases by a slight margin the capacity needed to meet the demand

AF_hydro = AF_hydro(:,2:$); // so year 1 is now 2015 for the avail factor



// Maximum market share for nuclear 
//loading 2024 nuke capacities + under construction for no new nuke MSH constraint

[Cap_nuke_nonew.Cap,Cap_nuke_nonew.Descpcap] = csvread(path_elec_nuke_MW_new+'Nuke2024.csv');
[Cap_nuke_nonew.Capconst,Cap_nuke_cons_nonew.Descpconst] = csvread(path_elec_nuke_MW_new+'Nukeplanned_2024.csv');

// set to 2024 in operation + planned in baseline
j = find(techno_dispatch_type  == "Nuke");
MSH_8760_type_sup(:, j)=(Cap_nuke_nonew.Cap + Cap_nuke_nonew.Capconst) .* avail_factor(:,technoNuke) * full_load_hours ./(Q_elec_init);

// The MSH sup for CSP is temporary so as to manage the share of CPS manually.
j = find(techno_dispatch_type  == "CSP");
MSH_8760_type_sup(:, j) = 0.03*ones(reg,1);

// Same for Biomass without CCS. Biomass with CCS depends on the availability of feedstock supply. The profitability of biomass is very sensitive to the local context (IRENA, RENEWABLE POWER GENERATION COSTS IN 2022)
j = find(techno_dispatch_type  == "BiomassWOCCS");
MSH_8760_type_sup(:, j) = 0.05*ones(reg,1);

//correction for hydro market share: this has the interest of adding hydro the dispatchable vs VRE logit node and avoid overinvesting in VRE. This makes no sense to massively investment in VRE in regions were hydro potential is important (e.g. canada & brazil)
//new MSH design: see what we do with high hydro potential regions, but remove the correction for now
correc_hydro = 0; 

    

//===================================//
//load duration curve design from POLES
part_max_poles=csvRead(path_elec_loadcurve+'part_max_courbes_charge.csv','|',[],[],[],'/\/\//');
part_min_poles=csvRead(path_elec_loadcurve+'part_min_courbes_charge.csv','|',[],[],[],'/\/\//');


taux_croiss_elec=zeros(nb_regions,1);
taux_croiss_comp=zeros(nb_regions,1);

//===================================//
//Load factor in thousand hours of functionning
//===================================//

Load_factor_ENR = zeros(nb_regions,nTechno_VRE);
Load_factor_ENR(:,1) = elecENRInitial.loadFactor.WND';
Load_factor_ENR(:,2) = elecENRInitial.loadFactor.WNO';
Load_factor_ENR(:,3) = elecENRInitial.loadFactor.CPV';
Load_factor_ENR(:,4) = elecENRInitial.loadFactor.RPV';

Load_factor_CSP = elecENRInitial.loadFactor.CSP'; // CSP is a dispatchable techno


//===================================//
//Variable and fixed O&M
//===================================//

// Loaded all POLES data. Converting into 2014USD
OM_cost_var_ref=zeros(nb_regions,techno_elec);
OM_cost_fixed_ref=zeros(nb_regions,techno_elec);


//For Variable O&M : Cost and Performance Assumptions for Modeling Electricity Generation Technologies(2010) gives a rough idea, did not find any better for now. Can not differentiate CCS from conv techno. CAREFUL : 2007$ and in $/MWh so divided by 10^3
//use the mean of 4 model values
OM_cost_var_ref(:,technoElecCoal) = mean([4.58,1.77,5.02,4.59])/10^3*CPI_2007_to_2014;
OM_cost_var_ref(:,[indice_ICG,indice_CGS]) = mean([2.92,4.06,2.92])/10^3*CPI_2007_to_2014;
OM_cost_var_ref(:,indice_GGT) = mean([3.17,2.92,3.77,3.17])/10^3*CPI_2007_to_2014;
OM_cost_var_ref(:,indice_GGC) = mean([2.00,3.13,2.22,2.00])/10^3*CPI_2007_to_2014;
OM_cost_var_ref(:,indice_GGS) = OM_cost_var_ref(:,indice_GGC); // Hyp O&M CCGT + CCS = CCTG
OM_cost_var_ref(:,indice_OCT) = OM_cost_var_ref(:,indice_GGT); // Hyp O&M OCT = GGT
OM_cost_var_ref(:,indice_OGC) = OM_cost_var_ref(:,indice_GGS); //Hyp O&M OGC == GGC
OM_cost_var_ref(:,technoNuke)= mean([0.49,0.52,1.97,0.49])/10^3*CPI_2007_to_2014;    // Nuclear
// IRENA, RENEWABLE ENERGY TECHNOLOGIES: COST ANALYSIS SERIES 2012 p.30
OM_cost_var_ref(:,technoHyd) = 2 / 10^3 * CPI_2012_to_2014;
//Biomass
OM_cost_var_ref(:,[technoBiomass]) = elecBiomassInitial.OMCostVar * ones(reg,length(technoBiomass));


//For fixed O&M : IEA 2020
OM_cost_fixed_ref(:,indice_PFC) = [65,65,60,70,70,30,50,65,65,60,30,65]'*CPI_2019_to_2014;
OM_cost_fixed_ref(:,indice_PSS) = [170,170,165,175,180,140,155,140,140,175,140,140]'*CPI_2019_to_2014; //Hyp supp : BRA & MDE = CHN
OM_cost_fixed_ref(:,indice_ICG) = [90,90,90,100,90,50,70,90,90,90,50,90]'*CPI_2019_to_2014;
OM_cost_fixed_ref(:,indice_CGS) = [210,210,205,220,190,165,185,165,165,210,165,165]'*CPI_2019_to_2014; //Hyp supp : BRA & MDE = CHN
OM_cost_fixed_ref(:,indice_SUB) = [45,45,45,55,50,20,35,45,45,45,20,45]'*CPI_2019_to_2014;
OM_cost_fixed_ref(:,indice_USC) = [70,70,60,70,70,30,50,65,65,60,30,65]'*CPI_2019_to_2014;
OM_cost_fixed_ref(:,indice_UCS) = OM_cost_fixed_ref(:,indice_PSS); //assume same OM for supercritical CCS and critical CCS
OM_cost_fixed_ref(:,indice_GGT) = [20,20,20,20,25,20,20,20,25,20,20,20]'*CPI_2019_to_2014;
OM_cost_fixed_ref(:,indice_GGS) = [210,210,205,220,190,165,185,165,165,185,65,165]'*CPI_2019_to_2014; //Hyp supp : BRA & MDE = CHN
OM_cost_fixed_ref(:,indice_GGC) = [25,25,25,30,30,20,25,25,30,25,20,25]'*CPI_2019_to_2014;
OM_cost_fixed_ref(:,indice_NUC) = [175,175,160,225,160,120,140,170,160,170,120,170]'*CPI_2019_to_2014;
OM_cost_fixed_ref(:,indice_NND) = OM_cost_fixed_ref(:,indice_NUC); // Hyp : same costs for NUC & NND
OM_cost_fixed_ref(:,indice_HYD) = [65,65,60,60,50,40,50,50,55,50,40,50]'*CPI_2019_to_2014; 

//Lazard (2014) Lazard's Levelized Cost of Energy Analysis v.8.0
//Diesel Generator
OM_cost_fixed_ref(:,indice_OCT) = 15 *ones(reg,1); 
OM_cost_fixed_ref(:,indice_OGC)= 15 *ones(reg,1);  

//Biomass 
OM_cost_fixed_ref(:,[technoBiomassWOCCS])  = repmat(elecBiomassInitial.OMCostFixed,1,length(technoBiomassWOCCS));
OM_cost_fixed_ref(:,[technoBiomassWCCS]) = repmat(elecBiomassInitial.OMCostFixedCCS,1,length(technoBiomassWCCS));


for techno = techno_RE_names
    execstr("OM_cost_var_ref(:,indice_"+techno+")=elecENRInitial.OMCostVar."+techno);
    execstr("OM_cost_fixed_ref(:,indice_"+techno+")=elecENRInitial.OMCostFixed."+techno);
end

//================================//
//Learning rates
//================================//

LR_ITC_elec=zeros(1,techno_elec);

//WEo (2021) Power generation technology costs and assumptions in the WEO-2021 Stated Policies and Net Zero Emissions by 2050 scenarios
LR_ITC_elec(:,[technoCoalWCCS,technoGasWCCS])=0.10;

LR_ITC_elec(:,technoBiomassWOCCS)=elecBiomassInitial.lr;
LR_ITC_elec(:,technoBiomassWCCS)=elecBiomassInitial.lrCCS;

for techno = techno_RE_names
    execstr("LR_ITC_elec(:,indice_"+techno+")=elecENRInitial.lrCons."+techno);
end 

//Need to discuss if we keep ind_lre_opt dummy scenarios on learning rate
LR_ITC_elec_CCS=lr_ccs;

//==============================//
//Cumulated investment at calibration year
//==============================//
dummy_cap = 1000; //dummy value for the cumulated investment at calibration year, to avoid very quick learning when techno appears

Cum_Inv_MW_elec_ref=dummy_cap*ones(1,techno_elec);

//For the most recent coal techno, we assume that the cumulated cap is given by existing cap (
Cum_Inv_MW_elec_ref(indice_PFC)=sum(Cap_elec_MWref(:,indice_PFC));
Cum_Inv_MW_elec_ref(indice_USC)=sum(Cap_elec_MWref(:,indice_USC));
Cum_Inv_MW_elec_ref(indice_ICG)=sum(Cap_elec_MWref(:,indice_ICG));
Cum_Inv_MW_elec_ref(indice_GGC)=sum(Cap_elec_MWref(:,indice_GGC)); //for CCGT, no clue, can be improved

Cum_Inv_MW_elec_ref(indice_BIG)  = sum(Cap_elec_MWref(:,indice_BIG));
Cum_Inv_MW_elec_ref(indice_BIS) = Cum_Inv_MW_elec_ref(indice_BIG); // apply a dummy cap for learning (not so quick!)

for techno = techno_RE_names
    execstr("Cum_Inv_MW_elec_ref(indice_"+techno+")=sum(elecENRInitial.cumulatedInvRef."+techno+")");
end

// also adding dummy capacity on offshore wind whose learning seem very quick and is acutally not totally independent from that of onshore wind, even though we assume it is after
// so we are adding 10% of the cumulated capacity of onshore wind
Cum_Inv_MW_elec_ref(indice_WNO) = Cum_Inv_MW_elec_ref(:,indice_WNO) + Cum_Inv_MW_elec_ref(indice_WND)*0.1;

// and since learning on PV is pooled, RPV and CPV should be added together
Cum_Inv_MW_elec_ref(indice_CPV) = Cum_Inv_MW_elec_ref(:,indice_CPV) + Cum_Inv_MW_elec_ref(indice_RPV);
Cum_Inv_MW_elec_ref(indice_RPV) = Cum_Inv_MW_elec_ref(indice_CPV);
Cum_Inv_MW_elec=Cum_Inv_MW_elec_ref;

//--------------------------------------------------------------------//
//----------------- Interest during construction ---------------------//
//--------------------------------------------------------------------//

// following IEA (2020) Projected Costs of Generating Electricity - 2020 Edition construction times
// + a linear cash flow model, see https://edbodmer.com/carrying-charge-2-inflation-in-carrying-charges-in-renewable-energy-prices/
// for an example. Basically assuming that money is borrowed equally over the construction period and interest (actually interest + foregone equity revenues) are paid 

//Construction periods

Constr_period=ones(reg,techno_elec);

// for WEO 2021 assumptions: 1.5 y for onshore wind and PV large scale
Constr_period(:,[indice_WNO,indice_CPV])=1.5;
//OCGT
Constr_period(:,[indice_GGT,indice_OCT])=2;
//CCGT
Constr_period(:,[indice_GGC,indice_GGS])=3;
// for WEO 2021 assumptions: 3 y for offshore wind also
Constr_period(:,[indice_WNO])=3;
//Coal and biomass  
Constr_period(:,[technoElecCoal,technoBiomass])=4;
//Hydro
Constr_period(:,indice_HYD)=5;
//Nuclear
Constr_period(:,indice_NUC)=7;

//to check that we are getting the right order of magnitude for IDC
// https://dspace.mit.edu/bitstream/handle/1721.1/119044/1059517934-MIT.pdf?sequence=1&isAllowed=y 
// finds "IDC multipliers" 1.2 and 1.37 for nuclear
// in base year, we find annualized IDC of approx 20%-40% of annualized capital costs so we are good

//===================================//
//Transmission and distribution costs
//===================================//

//T&D cost from http://dx.doi.org/10.1016/j.eneco.2016.12.006
// These are "per capacity credit adjusted", lets interpret as cost per kW installed => more VRE means more grid costs due to the lower capacity factor
//must be an error bcause the cost is absurdly low, shall be 115 instead of 1.15 (reported to be between 100€/kW and 200€/kW
TD_cost = 115  *ones(reg,ntechno_elec_total)*CPI_2007_to_2014;
dr_TD = 0.07; //discount rate for T&D costs
LF_TD = 50; // that's a guess
// this cost must be annualized using a discount rate and a lifetime

CRF_TD = dr_TD./(1-(1+dr_TD).^(-LF_TD ));
TD_cost_ann=TD_cost .* CRF_TD;

//===================================//
//Balancing costs
//===================================//

// for VRE, using temporarily balancing costs of 5€/MWh gross gen
Bal_cost = 5 * ones(reg,nTechno_VRE)*EUR_to_USD/10^3;

//==============================//
//Expansion constraints
//==============================//

// annual growth rates of net technology deployment. 15% (15%/10%/5% high/mid/low) used from http://dx.doi.org/10.1016/j.techfore.2013.08.025 
// 'Constraints on the diffusion of the low-carbon technologies are represented as fixed annual rates of growth of net technology deployment.'
// here the max growth rate is mean max min growth rate of the dur_seq_inv_elec periods.
// rationale for this design:
// for nascent tech or technologies under development, S-shaped diffusion curve determine when commercialization starts and the pace of diffusion
// not the case of variable renewable because the short term diffusion is calibrated by the logit share weights, so diffusion is taken into account at least in the short run, which is not the case for biomass, CCS, NND etc
// + the capacity expansion constraint also captures supply bottleneck constraints that are independant of technology diffusion, e.g. nuke today 
// cf diagnostic notebook, this has little influence on mitigation pathways including high carbon tax scenario. It can be used to 
// 15% is overly pessimistic compared to empirical evidence
max_growth_rate_elec=0.20; 
//5% is the threshold for the niche stage of the diffusion S-curve => when the expansion constraint starts
// alternative tresholds: 1%
//" Kramer and Haigh [61] postulated two laws for transitions in the global energy sector based on the growth of energy technologies in the twentieth century. First, when technologies are new, they go through a few decades of exponential growth with an average growth rate of 26% per annum until the technology “materializes” i.e. it becomes around 1% of world energy"
niche_elec_msh = 0.01; 
// 10000 MW minimum investment size before applying the expansion constraint, that's roughly the size of 20 nuke reactor, which is decent for regional scale. Using this threshold, the expansion constraint is barely bounding in the baseline.
min_inv_exp = 20000;


//==============================================//
//New elec nexus data (markup, share weights and WACC)
//==============================================
////FF/Renewable shares in the mix
part_ENR_prod_endo=ones(nb_regions,TimeHorizon+20)*%eps; //nicer to get ones than zeros

share_FF_ENR=zeros(reg,nbTechFFENR);//PV(RPV+CPV) and wind(WND+WNO) shares in the mix
share_PV = zeros(reg,1);
share_Wind = zeros(reg,1);
markup_SIC = zeros(reg,2); //fsolve input, contains markups from previous period
//Share weights convergence horizon
Convergence_horizon = 2030 - base_year_simulation; //2030 converge for share weights
//Renewable LCOE
LCC_ENR = zeros(reg,length(techno_VRE_absolute));

//dispatchable choice indicator in the main logit node (with previous period for inertia)
LCC_FF = zeros(reg,1);
LCC_FF_prev = zeros(reg,1);
LCC_FF_prev_prev = zeros(reg,1);

iner_LCC = 0.5;
//This parameter constraint the increase in the share of dispatchable power in the ideal mix
// This rule makes sense for several reasons
// Gov set increasing targets for VRE, and the share of dispatchable power in the mix should not increase too much
// The rationale of biomass + CCS ruling out VRE is very fragile and only due to the fact that biomass+CCS is the only negative em technology in the model
// max_incr_dispatch is proportional the duration of sequential planning (the longer the wait between to investment decisions, the more the share of dispatchable power can increase in the mix)
max_incr_dispatch = 0.005* dur_seq_inv_elec; 

// residual load curve
//// the coef are given in the following order (Intercept),Wind_share,PV_share,Wind_share_sq,PV_share_sq,Wind_share_cb,PV_share_cb,Wind_share:PV_share,PV_share:Wind_share_sq,Wind_share:PV_share_sq
coef_RLDC.coef = csvRead(path_RLDC_coef + 'coefRes_peak.csv',"|",[],[],[],'/\/\//');
coef_Curt.coef = csvRead(path_RLDC_coef + 'coefCurtailment.csv',"|",[],[],[],'/\/\//');
coef_Stor.coef = csvRead(path_RLDC_coef + 'coef_Storage.csv',"|",[],[],[],'/\/\//');
coef_Net_VRE.coef = csvRead(path_RLDC_coef + 'coef_Net_VRE.csv',"|",[],[],[],'/\/\//');
coef_profile_costs.coef = csvRead(path_RLDC_coef + 'coef_profile_costs.csv',"|",[],[],[],'/\/\//');

//Parameters needed to split curtailment between curtailed wind power and curtailed PV power. Curtailment happen for several reasons, but here we assume it is only oversupply. It means that, in average, some VRE plants with not provide electricity to the grid while they could = lost revenues.
//Theses values (3 for 1) are only a rule of thumb
// DEPRECIATED - not used anymore.
alpha_pv = 3;
beta_wd = 1;


// this will disappear 
facteur_t = [8030+6570+5110+3650+2190+730]/6;
//residual peak estimation.
RLDC_peak = zeros(nb_regions,TimeHorizon+20);
//Initializing solar & wind shares + RLDC

Solar_sh_ref = sum((Load_factor_ENR(:,technoPV_absolute)*1000).*Cap_elec_MWref(:,technoPV)./repmat((Q_elec_init),1,length(technoPV)),"c");
WD_sh_ref = sum((Load_factor_ENR(:,technoWind_absolute)*1000).*Cap_elec_MWref(:,technoWind)./repmat((Q_elec_init),1,length(technoWind)),"c");
RLDC_peak_ref = find_RLDC_peak([WD_sh_ref,Solar_sh_ref]);
RLDC_peak(:,1)=RLDC_peak_ref;

// storage cost per kWh of gross PV/Wind share
str_gross_VRE_kwh = zeros(reg,nTechno_VRE);
//profile costs per kWh of gross PV/Wind share
pc_gross_VRE_kwh = zeros(reg,nTechno_VRE);
// Endogenous profile costs calculation
// requires to run with forced shares of VRE
if force_VRE_share == 1
    WD_sh_target = zeros(reg,TimeHorizon+10);
    Solar_sh_target = zeros(reg,TimeHorizon+10);

    if ~isdef("WD_sh_target_global")
        WD_sh_target_global = 0.4;
    end
    if ~isdef("Solar_sh_target_global")
        Solar_sh_target_global = 0.4;
    end
    WD_sh_target_init = WD_sh_target_global*ones(reg,1);
    Solar_sh_target_init = Solar_sh_target_global*ones(reg,1);

    if ~isdef("convergence_hor_share_elec")
        convergence_hor_share_elec= 1;
    end

    //linear interpolation of the share of VRE in the mix
    WD_sh_target(:,1:convergence_hor_share_elec+1) = linspace(WD_sh_ref,WD_sh_target_init,convergence_hor_share_elec+1);
    Solar_sh_target(:,1:convergence_hor_share_elec+1)  = linspace(Solar_sh_ref,Solar_sh_target_init,convergence_hor_share_elec+1);
    //after the convergence horizon, the share of VRE in the mix is fixed
    WD_sh_target(:,convergence_hor_share_elec+2:$) = repmat(WD_sh_target_init,1,size(WD_sh_target(:,convergence_hor_share_elec+2:$),2));
    Solar_sh_target(:,convergence_hor_share_elec+2:$) =repmat(Solar_sh_target_init,1,size(Solar_sh_target(:,convergence_hor_share_elec+2:$),2));

    if convergence_hor_share_elec == 1
        WD_sh_target = WD_sh_target_global *ones(reg,convergence_hor_share_elec+1);
        Solar_sh_target = Solar_sh_target_global*ones(reg,convergence_hor_share_elec+1);
    end
end
//reserve margin as a % of residual peak load
reserve_margin = 0.2;
//minimum utilization rate to trigger investments
min_util_rate = 0.05;
//POLES base to peak load ratio
bp_ratio = part_min_poles./part_max_poles;

//==============================================//
//CCS constraint
//==============================================
//Development stage for CCS (>0 Cap but no elec prod under min_CCS total market shares of CCS technos)
min_CCS=0.01;

//peak load coverage : sum of conventional power capacity divided by residual peak load.
// The residual peak load coverage constraints the investment to avoid oversized capacity in the electricity sector.

// This is a critical constraint since it prevents the model from investing too much in dispatchable power plants if existing capacities are already sufficient to cover the peak load.
//the 20% residual peak load coverage target is a rule of thumb
// with this design, 1.15 give 120% peak load coverage, and increases investment if the peak load coverage is below 120%.
res_param = [1.15,(1+reserve_margin+0.2),1.2,0.2]; //min_x, max_x,m min_y, max_y, see the function in nexus.electricity.sci

residual_peak_cov = (sum(Cap_elec_MWref(:,techno_dispatchable).*avail_factor(:,techno_dispatchable),"c"))./(RLDC_peak_ref.*(Q_elec_init)./(bp_ratio*full_load_hours + facteur_t*(1-bp_ratio)));

//setting the residual peak coverage to 1.2 to trigger exactly the desired investments in some cases
if calib_profile_cost == 1 | auto_calibration_IC_elec==%t
    residual_peak_cov = (1+reserve_margin)*ones(reg,1);
end


// tolerance for MSH constraint
tol_elec_msh = 10^-3;

//maximum iteration for the MSH constraint
max_it_elec_msh=30;

//===================================//
//Intaglible costs for dispatchable power
//===================================//

// data from IEA (2023), Energy Statistics Data Browser, IEA, Paris https://www.iea.org/data-and-statistics/data-tools/energy-statistics-data-browser
// on electricity generation, converted in market share

// loading the csv
market_share_elec = csvRead(path_elec_calib_MSH+'ElecGen.csv',",",[],[],[],'/\/\//');
// dropping the first row
market_share_elec = market_share_elec(2:$,:);
market_share_hydro = market_share_elec(:,find(techno_dispatch_type == "Hydro"));
// converting the data to market share by normalizing to one (in the raw data, expressed a % of total MSH)
total_msh = sum(market_share_elec,2);
market_share_elec = market_share_elec./repmat(total_msh,1,n_type_elec);

tol_IC=1e-2; //tolerance for IC cost calibration: allow for a max 1% market share deviation


//loading calibrated IC
IC_elec_base = csvRead(path_autocal_IC_elec+'IC_elec.csv',",",[],[],[],'/\/\//');
//expand the type-level IC to techno level
IC_elec_expand = zeros(reg,nTechno_dispatch);

////calibration: fsolve parameters
init_IC=-0.001;
//lr and up bound of ICs
min_IC=-0.1;
max_IC=1;
// choosing the type of convergence
// see the converge_IC function in lib/nexus.electricity.sci
// FF wo CCS & Biomass wo CCS: no convergence
// FF w CCS & Biomass w CCS: convergence to wo CCS
// Hydro, CSP, Nuke: no convergence
convergence_type = [-1,-1,-1,1,2,-1,-1,-1,-1,9];
//==============================================//
//Dynamic calibration
//==============================================//

// Share weights calibration
//share weights of the VRE nest and FFvsVRE nest now calibrated at 2015
target_year=1;
if  run_calib_weights == %t //TB: Weights calibration. Requires an existing weights_ENR.tsv file, must be fixed to the file can be created if it does not exists yet
    target_prod = zeros(reg,nTechno_VRE);

    [target_prod(:,1),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2015_WND.csv');
    [target_prod(:,2),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2015_WNO.csv');
    //[target_prod(:,3),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2018_CSP.csv');
    [target_prod(:,3),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2015_CPV.csv');
    [target_prod(:,4),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2015_RPV.csv');
    [target_prod_tot,target_prod_descr]                  =     csvread(path_elec_prod+'Prod_tot_2015_.csv');
    for j = 1:nTechno_VRE
        target_prod(:,j) = target_prod(:,j)./target_prod_tot;
        for k = 1:reg
            if target_prod(k,j) < 0.0001
                target_prod(k,j) = 0.0001;
            end
        end
    end
end
//initializing the weights
ldcsv("weights_VRE_nest.tsv",path_elec_weights)
ldcsv("weights_VRE_FF.tsv",path_elec_weights)

weights_VRE_nest_hist = weights_VRE_nest;
weights_VRE_FF_hist = weights_VRE_FF;


if run_calib_weights == %t
    [target_prod(:,1),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2015_WND.csv');
    [target_prod(:,2),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2015_WNO.csv');
    //[target_prod(:,3),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2018_CSP.csv');
    [target_prod(:,3),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2015_CPV.csv');
    [target_prod(:,4),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2015_RPV.csv');
    [target_prod_tot,target_prod_descr]                  =     csvread(path_elec_prod+'Prod_tot_2015_.csv');

    target_prod_VRE = sum(target_prod,2);
    target_prod_FF =target_prod_tot-target_prod_VRE;
    target_prod_VRE = target_prod_VRE./target_prod_tot;
    target_prod_FF = target_prod_FF./target_prod_tot;

    for j = 1:nTechno_VRE
        target_prod_tot_VRE(:,j) = target_prod(:,j)./target_prod_tot;
    end
    //normalized to one
    sum_target_prod = sum(target_prod,2);
    for j = 1:nTechno_VRE
        target_prod(:,j) = target_prod(:,j)./sum_target_prod;
    end
    target_prod = max(target_prod,0.001); // to avoid messing with base calibration
end
//To get the right profile cost/IC calibration, we must force the model to invest as in 2015.
//This is done by loading loading the shape of the load duration curve in 2015 previous run
// when forcing the VRE share (e.g. for profile cost calibration), the shape of the residual load curve is also modified
// and anyways, to get the shape of the RLDC on the first period,

//computing the peak load to get the right MSHs
//if not forcing the share, using historical shares
if force_VRE_share == 0
    WD_sh_target_global = WD_sh_ref;
    Solar_sh_target_global = Solar_sh_ref;
end
//using the new definition of curtailmet to get net VRE share
curt_gross = att_curtailment(WD_sh_target_global.*ones(reg,1),Solar_sh_target_global.*ones(reg,1));

net_VRE_share = sum([WD_sh_target_global.*ones(reg,1),Solar_sh_target_global.*ones(reg,1)].*(1-curt_gross),"c");

RLDC_peak_ant = find_RLDC_peak([WD_sh_target_global.*ones(reg,1),Solar_sh_target_global.*ones(reg,1)]);

if old_RLDC_design == 1// & current_time_im>2018-base_year_simulation
    RLDC_peak_ant = (1- net_VRE_share);
end

peak_W_anticip_tot = Q_elec_init./(bp_ratio*full_load_hours + facteur_t*(1-bp_ratio));
peak_W_anticip = RLDC_peak_ant.*peak_W_anticip_tot;

peak_W_anticip_tot_ref = peak_W_anticip_tot;

Q_elec_anticip = Q_elec_init.*(1-net_VRE_share);

//if calibrating profile or IC costs, set horizon to 1 to force the model to invest as in 2015 for the next period.
if calib_profile_cost == 1 | auto_calibration_IC_elec==%t |run_calib_weights == %t
    nb_year_expect_futur = 1
end
//==============================================//
//Capture rate of CCS
//==============================================//

cap_rate_CCS=0.9;
//==============================================//
//Corrections
//==============================================//

//correcting the capacity of hydro to match baseyear market shares (important for dispatchable weighted LCOE calculation)
corr_factor_cap_hydro=market_share_hydro./(100*(Cap_hydro(:,1).*AF_hydro(:,1)*full_load_hours)./(Q_elec_init));

Cap_hydro=Cap_hydro.*repmat(corr_factor_cap_hydro,1,size(Cap_hydro,2));
Cap_elec_MWref(:,indice_HYD)=Cap_hydro(:,1); //hydro at base year
// also correcting the historical capacity of hydro
for ll=1:size(Cap_elec_MW_vintage(indice_HYD,:,:),2)
    for k=1:reg
        Cap_elec_MW_vintage(indice_HYD,ll,k) = Cap_elec_MW_vintage(indice_HYD,ll,k) .*corr_factor_cap_hydro(k);
    end
end
if calib_profile_cost == 1 
    disc_rate_profile = 0.08;
    // long term approach: dispatchable CAPEX reach their floor cost  
    CINV_MW_ITC_ref = A_CINV_MW_ITC_ref;

    // to calibrate dispatchable MSH constraints
    part_ENR_prod_endo= repmat(net_VRE_share,1,size(part_ENR_prod_endo,2));
end
