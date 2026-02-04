// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera, Florian Leblanc, Ruben Bibas, Nicolas Graves, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
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
//   ---*---   INDEXES and DIMENSSIONS   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////

exec(MODEL+'indexes.electricity.sce');
tranches_elec=["8760","8030","6570","5110","3650","2190","730"];
nb_tranches_elec=size (tranches_elec,"c");

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION with no sources   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

// market share of CCS tech. in elec. are zeros if the tax is inferio to:
starting_taxCO2_ccs_elec = 25*1e-6; // in 1e-6 $/tCO2

nb_year_expect=10; // number of expected year considered in calibration
nb_year_expect_futur=10; // number of expected year considered when projecting in nexus.

// sequential investment decisionmaking
if ~isdef("dur_seq_inv_elec")
    dur_seq_inv_elec = 1; // investment decision making is reassessed every dur_seq_inv_elec years. Typical value in the litterature is ~5 years (see http://dx.doi.org/10.1016/j.esr.2017.06.001)
end

// puissance de la logit dans la calibration des coûts intangibles
gamma_FF = 3; // is there any reason to have a different gamma for the modified logit of FF? Maybe sharper for FF?


// maximum production of biomass energy per year
//This is v1 value with no source (75 EJ). The switch and the value are kept, but not used by defaut
exogenousBiomassMaxQ = 75; // EJ/yr

// correction to data on investment cost for wind turbine offshore
corr_CINV_windoffshore = 1.961;

// parts de marchés maximum pour certaines technos, par tranche horaire
MSH_elec_PFC_max=0.01;
MSH_elec_ICG_max=0.005;

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

//these are supposed to remain fixed
param_SIC_pv = 3;
param_SIC_wind = 1.4;

//Modified logit parameter
if (~isdef("gamma_FF_ENR"))
    gamma_FF_ENR = 3;
end


//thousand hours to hours (for Load_Factor_ENR)
th_to_h = 1000;
full_load_hours = 8760;

//Initiating variables for the elec nexus


CINV_MW_nexus=zeros(reg,techno_elec); //capital costs
OM_cost_var_nexus  =zeros(reg,techno_elec); //variable O&M costs
OM_cost_fixed_nexus=zeros(reg,techno_elec);//fixed
rho_elec_nexus=zeros(reg,techno_elec);//rho parameter for efficiency

init_ITC_elec=zeros(1,techno_elec); //starting year for learning
sum_Inv_MW=zeros(1,techno_elec);//sum of investments in technos
Inv_MW=zeros(1,techno_elec);//Investment levels

//Excluding saturated technologies from the multinomial logit
    techno_FF_min = [1:indice_OGC,indice_NUC,indice_NND,indice_CSP,indice_BIGCCS];
    techno_FF_min_reg = list();
    for k = 1:reg
        techno_FF_min_reg(k) = techno_FF_min;
    end

//Logit share weights
ldcsv("weights_ENR.tsv",path_elec_weights)//if first iteration this should be executed because the file does not exist yet
if ind_logit_sensib_VRE
    ldcsv("weights_ENR"+"_"+gamma_FF_ENR+".tsv",path_elec_weights)
    execstr("weights_ENR = weights_ENR_"+gamma_FF_ENR+"")
end
weights_ENR_hist = weights_ENR;

if (ind_new_calib_gas & ind_new_calib_coal)
    ldcsv("weights_ENR_new_calib_FF.tsv",path_elec_weights)
    weights_ENR_hist = weights_ENR_new_calib_FF;
end

curt_VRE = zeros(reg,length(technoExo_absolute));//Initializing curtailment parameter, in % of solar/wind generation
Markup_LCC_SIC = zeros(reg,length(technoExo_absolute));//VRE markup
total_curt=zeros(reg,1); //total curtailment as a share of demand

Q_elec_anticip_tot_prev=zeros(reg,1); //t-1 electricity demand

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
        for j=[indice_BIGCCS]
            execstr('MSHmax_'+tranche+'_elec(:,'+j+') =zeros('+nb_regions+',1);');
            execstr("MSH_"+tranche+"_elec_sup(:,"+j+")=0;"); //If ind_seq_opt == 0, no CCS
        end
    end
end



//Limiting CCS deployment
//Theses parameters are initialized in study_frames/default_parameters.sce and study_frames/study
for tranche=tranches_elec
    execstr ("Tgrowth_CCS_"+tranche+" = tGrowthCCS * ones(nb_regions,"+techno_elec+");");
    execstr ("Tmature_CCS_"+tranche+" = tMatureCCS * ones(nb_regions,"+techno_elec+");");
    execstr ("Tstart_CCS_" + tranche +     " = tStartCCS * ones(nb_regions,"+techno_elec+");");
    execstr ("Tniche_CCS_" + tranche +     " = tNicheCCS * ones(nb_regions,"+techno_elec+");");
    execstr ("MSHmax_"     + tranche +"_elec = mshMaxCCS * ones(nb_regions,"+techno_elec+");");
end

CCS_efficiency = 0.9;
//===================================//
//Biomass Calibration
//===================================//


[elecBiomassResource,elecBiomassResourceDescr] = csvread(path_elec_biomass+'elecBiomassResource.csv');
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
end

//Compararing old inputs with some current assumptions in other IAM.
//WITCH: $2005 O&M var: 10.33$/MWh, floor cost 2000 $/kW, investment costs 3693$/kW

elecBiomassInitial.invCost                 =  3100*CPI_2015_to_2014; // JRC Technical Reports (2018) "Cost development of low carbon energy technologies"
//Bioenergy - large scale unit
elecBiomassInitial.OMCostFixedBIGCC        =  [85,85,85,85,80,55,75,75,80,75,55,75]*CPI_2020_to_2014; //WEO Power generation technology costs and assumptions in the WEO-2021 (IEA,2021)
elecBiomassInitial.OMCostFixedBIGCCS       =  [200,200,200,200,180,145,165,160,180,170,145,160]*CPI_2020_to_2014;

elecBiomassInitial.OMCostVar               =  15/1e3; //Lazard (2014) Lazard's Levelized Cost of Energy Analysis v.8.0
elecBiomassInitial.efficiencyBIGCC         =   0.4; // Efficiency rate
elecBiomassInitial.efficiencyBIGCCS        =   0.3; // Efficiency rate
elecBiomassInitial.emissions               = 0.094; // tCO2/GJinput
elecBiomassInitial.emissionsCCS            = 0.009; // tCO2/GJinput
elecBiomassInitial.lifetime                =    50; // years

if ind_new_calib_biomass_LR //new value from WEO : 5%
    elecBiomassInitial.lrBIGCC                 =   0.05; // WEO (2021) Power generation technology costs and assumptions in the WEO-2021 Stated Policies and Net Zero Emissions by 2050 scenarios
else //Keeping previous value for elecBiomassInitial.lrBIGCC
    elecBiomassInitial.lrBIGCC                 =   0.1; 
end 
elecBiomassInitial.investmentCostAsymptote =  1100; // corresponds to IGCC
elecBiomassInitial.cumulatedInvRefBIGCC    =  1000; // value consistent with coal ICG
elecBiomassInitial.cumulatedInvRefBIGCCS   = 10; // value consistent with coal IGCCS
elecBiomassInitial.startLearningDateBIGCC  =     1; // We start at year 2014
elecBiomassInitial.startLearningDateBIGCCS =     startLearningDateBIGCCS;// BIGCCS start later (in 2025)
//elecBiomassInitial.maxGrowthMSH            =  0.012;

// Biomass capacity from IRENA (2020), same source as PV and wind. 
[elecBiomassInitial.cap.Cap,elecBiomassInitial.cap.desc]                  =    csvread(path_elec_cap+'Cap_2014_BIO.csv');

if ind_beccs == 2 //a combi parameter that determines beccs development. Is 1 most of the time.
    elecBiomassInitial.invCost     = elecBiomassInitial.invCost * 2;
    elecBiomassInitial.OMCostFixed = elecBiomassInitial.OMCostFixed * 2;
    elecBiomassInitial.OMCostVar   = elecBiomassInitial.OMCostVar * 2;
end

elecBiomassInitial.processCost = elecBiomassInitial.processCost / gj2tep / tep2kwh; // $ / kWh

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
[elecENRInitial.invCost.WND,elecENRInitial.descrip.invCost.WND]                  =    csvread(path_elec_CINV+'CINV_2014_WND.csv');
[elecENRInitial.invCost.WNO,elecENRInitial.descrip.invCost.WNO]                  =    csvread(path_elec_CINV+'CINV_2014_WNO.csv');
[elecENRInitial.invCost.CSP,elecENRInitial.descrip.invCost.CSP]                  =    csvread(path_elec_CINV+'CINV_2014_CSP.csv');
[elecENRInitial.invCost.CPV,elecENRInitial.descrip.invCost.CPV]                  =    csvread(path_elec_CINV+'CINV_2014_CPV.csv');
[elecENRInitial.invCost.RPV,elecENRInitial.descrip.invCost.RPV]                  =    csvread(path_elec_CINV+'CINV_2014_RPV.csv');

for techno = techno_ENR
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
for techno = techno_ENR
    execstr("elecENRInitial.OMCostVar."+techno+"= zeros(reg,1)");
end

//CINV 2019 checkpoint from IEA (2020) "Power generation assumptions in the Stated Policies and SDS Scenarios in the World Energy Outlook 2020"
//The learning curves apply endogeneously only from 2019. Before that, CINV_MW _nexus linearly converges to 2019 costs for VRE
//hyp : CAN = USA, OECD PAC = JAP , REST ASIA = CHI, REST LAT = BRAZ, CEI = RUS
//TB: chech OECD PAC = JAP hypothesis
CINV_MW_2019 = zeros(reg,techno_elec);

[elecENRInitial.invCost2019.WND,elecENRInitial.descrip.invCost2019.WND]                  =    csvread(path_elec_CINV+'CINV_2019_WND.csv');
[elecENRInitial.invCost2019.WNO,elecENRInitial.descrip.invCost2019.WNO]                  =    csvread(path_elec_CINV+'CINV_2019_WNO.csv');
[elecENRInitial.invCost2019.CSP,elecENRInitial.descrip.invCost2019.CSP]                  =    csvread(path_elec_CINV+'CINV_2019_CSP.csv');
[elecENRInitial.invCost2019.CPV,elecENRInitial.descrip.invCost2019.CPV]                  =    csvread(path_elec_CINV+'CINV_2019_CPV.csv');
[elecENRInitial.invCost2019.RPV,elecENRInitial.descrip.invCost2019.RPV]                  =    csvread(path_elec_CINV+'CINV_2019_RPV.csv');

//Convert 2019 USD to base year USD
for techno = techno_ENR
    execstr("elecENRInitial.invCost2019."+techno+"=elecENRInitial.invCost2019."+techno+"*CPI_2019_to_2014"); //PING_FL
end

for techno = techno_ENR
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
for techno = techno_ENR
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
elecENRInitial.investmentCostAsymptote.CPV  =    RTE_Cost_Asym.CPV.ref; 
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
[elecENRInitial.cap.WND,elecENRInitial.descrip.cap.WND]                  =    csvread(path_elec_cap+'Cap_2014_WND.csv');
[elecENRInitial.cap.WNO,elecENRInitial.descrip.cap.WNO]                  =    csvread(path_elec_cap+'Cap_2014_WNO.csv');
[elecENRInitial.cap.CSP,elecENRInitial.descrip.cap.CSP]                  =    csvread(path_elec_cap+'Cap_2014_CSP.csv');
[elecENRInitial.cap.CPV,elecENRInitial.descrip.cap.CPV]                  =    csvread(path_elec_cap+'Cap_2014_CPV.csv');
[elecENRInitial.cap.RPV,elecENRInitial.descrip.cap.RPV]                  =    csvread(path_elec_cap+'Cap_2014_RPV.csv');

    //must be discussed: assumed that no VRE capital was retired yet in 2014, meaning that the existing capital = cumulated investment.
for techno = techno_ENR
    execstr("elecENRInitial.cumulatedInvRef."+techno+"=elecENRInitial.cap."+techno);
end

/////////////////////////////////////////////////////////////////////////////////////////////
//    ---*---   GENERAL CALIBRATION   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////



//===================================//
//Lifetimes
//===================================//

Life_time=zeros(nb_regions,techno_elec);


    //p.36 Projected Cost of Generating Electricity 2020 IEA 
    Life_time(:,technoElecCoal) = 40;
    Life_time(:,technoElecGas) = 30;
    Life_time(:,technoOil) = 20; //Lazard (2014) Lazard's Levelized Cost of Energy Analysis v.8.0

    Life_time(:,indice_HYD)= 80;
    Life_time(:,indice_NUC)= 60;
    Life_time(:,indice_NND)= 60;
    Life_time(:,indice_CHP)= 15; //old POLES value
    Life_time(:,indice_SHY)= 30; //old POLES value
    Life_time(:,indice_BIGCC) = elecBiomassInitial.lifetime;
    Life_time(:,indice_BIGCCS)= elecBiomassInitial.lifetime;
    Life_time(:,indice_GFC)= 15; //old POLES value
    Life_time(:,indice_HFC)= 15; //old POLES value
    for techno = techno_ENR
    execstr("Life_time(:,indice_"+techno+")=elecENRInitial.lifetime."+techno);
    end

//Initializing variables
//Lifetime of technologies

Life_time_max=max(Life_time);
Life_time_max_FF = max(Life_time(:,[technoFossil,technoBiomass]));



//===================================//
//Capital costs for all technos
//===================================//
CINV_MW=zeros(nb_regions,techno_elec,TimeHorizon);

//////Loading old POLES data
// couts d'investissement Non conv.xls Couts d'investissement.xls
//CINV_MW. en euro1999/kW
CINV_MW_poles_temp=csvRead(path_elec_costs+'CINV_MW_temp.csv','|',[],[],[],'/\/\//');

//passage à 2100
size_temp=size(CINV_MW_poles_temp);
for k=1:50
    CINV_MW_poles_temp(:,size_temp(2)+k)=CINV_MW_poles_temp(:,size_temp(2));
end

//exogenous trajectories are starting from 2001 (calibrated for previous version of the model), so we keep only the values starting from starting year of simulation
CINV_MW_poles_temp=CINV_MW_poles_temp(:,base_year_simulation-2000:TimeHorizon+base_year_simulation-2000);

CINV_MW_poles_temp = matrix(CINV_MW_poles_temp,nb_regions,techno_elec,TimeHorizon+1);
//Getting POLES old values. Only used for few technologies (oil powered plants)
for j=1:TimeHorizon
    for ind_technoElecIm=[indice_PFC:indice_WND,indice_GFC,indice_HFC]
      CINV_MW(:,ind_technoElecIm,j) = Usd2001ToEur1999*CINV_MW_poles_temp(:,ind_POLES(ind_technoElecIm),j);
    end
end

//Loading new VRE data
for j=1:TimeHorizon
    CINV_MW(:,indice_BIGCC,j) = elecBiomassInitial.invCost ; 
    CINV_MW(:,indice_BIGCCS,j)= elecBiomassInitial.invCost ;
end
// Loaded all POLES data. Converting into 2014USD
CINV_MW = CINV_MW * CPI_2001_to_2014;//PING_FL

// Loading new renewable data
for j=1:TimeHorizon+1
for techno = techno_ENR
    execstr("CINV_MW(:,indice_"+techno+",j)=elecENRInitial.invCost."+techno);
end
end
//PING_FL##############
CINV_MW_ITC_ref = CINV_MW(:,:,1);
//correction pour les autres technologies
CINV_MW_ITC_ref(:,indice_PFC) = [2100,2100,2000,2400,2000,700,1200,1600,1600,1600,700,1600]' * CPI_2019_to_2014;
CINV_MW_ITC_ref(:,indice_ICG) = [2600,2600,2500,2900,2500,1100,1600,2000,2000,2200,1100,2000]' * CPI_2019_to_2014;
CINV_MW_ITC_ref(:,indice_SUB)= [1800,1800,1700,2100,1700,600,1000,1300,1300,1300,600,1300]' * CPI_2019_to_2014;
CINV_MW_ITC_ref(:,indice_USC)= [2300,2300,2200,2600,2200,800,1400,1800,1600,1900,800,1800]'* CPI_2019_to_2014;
CINV_MW_ITC_ref(:,indice_GGT) = [500,500,500,500,450,350,400,400,450,400,350,400]'* CPI_2019_to_2014;
CINV_MW_ITC_ref(:,indice_GGC)= [1000,1000,1000,1100,800,560,700,700,800,700,560,700]'* CPI_2019_to_2014;  		// Gas-powered Gas Turbine in Combined Cycle 
//Lazard (2014) Lazard's Levelized Cost of Energy Analysis v.8.0
//Diesel Generator
CINV_MW_ITC_ref(:,indice_OCT) = 650; //already in USD2014
//for combined cycle, we add the mean difference between gas CT and CC 
CINV_MW_ITC_ref(:,indice_OGC) =CINV_MW_ITC_ref(:,indice_OCT) +  mean(CINV_MW_ITC_ref(:,indice_GGC)-CINV_MW_ITC_ref(:,indice_GGT));
CINV_MW_ITC_ref(:,indice_NUC) = [5000,5000,6000,4200,3800,2600,2800,4000,3500,4000,2600,4000]'* CPI_2019_to_2014; //Nuke is more costly than expected in 2001
CINV_MW_ITC_ref(:,indice_NND) = 8220 * CPI_2001_to_2014; //old POLES values for now. New nuclear design is prohibitively expensive for now
CINV_MW_ITC_ref(:,indice_HYD) = [2700,2700,2650,2400,2650,1600,2000,2100,2150,2100,1600,2100]'* CPI_2019_to_2014; //hydro large scale unit
//PING_FL
CINV_MW_ITC_ref(:,indice_BIGCC) =3100* EUR_to_USD*CPI_2015_to_2014; //adjusted the cost of BIGCC so the cost of BIGCC + CCS correspond roughly to JRC Technical Reports (2018) "Cost development of low carbon energy technologies" DOI:10.2760/490059 values, p.51. 3100 correspond to 2015 anaerobic digestor inv cost(without CCS then)

/////Traitement de la CCS, on definit des surcouts pour installer de la CCS sur lesquels on va faire du learning en $/kW
CINV_MW_ITC_CCS_PFC_ref = 3000* CPI_2019_to_2014; //central value from IEA WEO 2020 assumptions
CINV_MW_ITC_CCS_ICG_ref = 3000* CPI_2019_to_2014;//central value from IEA WEO 2020 assumptions
CINV_MW_ITC_CCS_GGS_ref = 2000* CPI_2019_to_2014;//central value from IEA WEO 2020 assumptions
CINV_MW_ITC_CCS_UCS_ref = CINV_MW_ITC_CCS_PFC_ref;
//PING_FL#################
CINV_MW_ITC_CCS_PFC = CINV_MW_ITC_CCS_PFC_ref;
CINV_MW_ITC_CCS_ICG = CINV_MW_ITC_CCS_ICG_ref;
CINV_MW_ITC_CCS_GGS = CINV_MW_ITC_CCS_GGS_ref;
CINV_MW_ITC_CCS_UCS = CINV_MW_ITC_CCS_UCS_ref;

///cout d'investissement ï¿½ la rï¿½fï¿½rence pour les technologies avec sï¿½questration
CINV_MW_ITC_ref(:,indice_PSS)    = CINV_MW_ITC_ref(:,indice_PFC)   + CINV_MW_ITC_CCS_PFC_ref;
CINV_MW_ITC_ref(:,indice_CGS)    = CINV_MW_ITC_ref(:,indice_ICG)   + CINV_MW_ITC_CCS_ICG_ref;
CINV_MW_ITC_ref(:,indice_UCS)    = CINV_MW_ITC_ref(:,indice_USC)   + CINV_MW_ITC_CCS_ICG_ref;//new
CINV_MW_ITC_ref(:,indice_BIGCCS) = CINV_MW_ITC_ref(:,indice_BIGCC) + CINV_MW_ITC_CCS_ICG_ref;
CINV_MW_ITC_ref(:,indice_GGS)    = CINV_MW_ITC_ref(:,indice_GGC)   + CINV_MW_ITC_CCS_GGS_ref;               

//unused technos : set prohibitive CAPEX 
CINV_MW_ITC_ref(:,indice_CHP)=10000000;
CINV_MW_ITC_ref(:,indice_SHY)=10000000;
CINV_MW_ITC_ref(:,indice_GFC)=10000000;
CINV_MW_ITC_ref(:,indice_HFC)=10000000;

CINV_MW_ref=CINV_MW_ITC_ref; //in v2 CINV_MW_ref serves for linear progression of capital costs from 2014 to 2019


//=============================================//
//Asymptotic capital costs
//=============================================//

/////Definition des asymptotes pour les capital costs
A_CINV_MW_ITC_ref=CINV_MW_ITC_ref;

//No better than IEA 2040 costs as asymptotes. Nothing displayed when no variations between 2019 and 2040 costs
A_CINV_MW_ITC_ref(:,indice_ICG)= [2400,2400,2300,2700,2300,900,1500,1900,1900,2100,900,1900]' * CPI_2019_to_2014; //PING_FL
A_CINV_MW_ITC_ref(:,indice_BIGCC)=elecBiomassInitial.investmentCostAsymptote* CPI_2001_to_2014;

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

//asymptotes pour les technologies avec sequestration
A_CINV_MW_ITC_ref(:,indice_PSS)    = A_CINV_MW_ITC_ref(:,indice_PFC)  + aCInvMW_ITC_CCS_PFCref;
A_CINV_MW_ITC_ref(:,indice_CGS)    = A_CINV_MW_ITC_ref(:,indice_ICG)  + aCInvMW_ITC_CCS_ICGref;
A_CINV_MW_ITC_ref(:,indice_UCS)    = A_CINV_MW_ITC_ref(:,indice_USC)  + aCInvMW_ITC_CCS_UCSref; //new
A_CINV_MW_ITC_ref(:,indice_BIGCCS) = A_CINV_MW_ITC_ref(:,indice_BIGCC)+ aCInvMW_ITC_CCS_ICGref;
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
        priceGazElec(k,j)=pArmCIref(indice_gaz,indice_elec,k);
        priceEtElec(k,j)=pArmCIref(indice_Et,indice_elec,k);
        // Q_elec(k,j)=Qref(k,indice_elec)/(1+tx_eptop_POLES(k))^(nb_year_expect-j);
    end
end

//===================================//
//Market shares
//===================================//

for tranche=tranches_elec
    execstr("MSH_"+tranche+"_elec = zeros(reg,techno_elec);")
end

// Maximum market share for nuclear 
execstr ( 'MSH_'+tranches_elec+'_elec_sup =ones('+nb_regions+','+techno_elec+');');
MSH_8760_elec_sup(:, indice_NUC)=nuc_cff*[ 0.3,0.3,0.4,0.3,0.2,0.2,0.2,0.1,0.1,0.1,0.1,0.1]';
MSH_8030_elec_sup(:, indice_NUC)=nuc_cff*[ 0.3,0.3,0.4,0.3,0.2,0.2,0.2,0.1,0.1,0.1,0.1,0.1]';
MSH_6570_elec_sup(:, indice_NUC)=nuc_cff*[ 0.3,0.3,0.4,0.3,0.2,0.2,0.2,0.1,0.1,0.1,0.1,0.1]';
MSH_5110_elec_sup(:, indice_NUC)=nuc_cff*[ 0.3,0.3,0.4,0.3,0.2,0.2,0.2,0.1,0.1,0.1,0.1,0.1]';
MSH_3650_elec_sup(:, indice_NUC)=nuc_cff*[ 0.3,0.3,0.4,0.3,0.2,0.2,0.2,0.1,0.1,0.1,0.1,0.1]'*1/2;
MSH_2190_elec_sup(:, indice_NUC)=nuc_cff*[ 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]';
MSH_730_elec_sup(:, indice_NUC)=nuc_cff*[ 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]';

// The MSH sup for CSP is temporary so as to manage the share of CPS manually.
MSH_8760_elec_sup(:, indice_CSP) = 0.05*ones(reg,1);
MSH_8030_elec_sup(:, indice_CSP) = 0.05*ones(reg,1);
MSH_6570_elec_sup(:, indice_CSP) = 0.05*ones(reg,1);
MSH_5110_elec_sup(:, indice_CSP) = 0.05*ones(reg,1);
MSH_3650_elec_sup(:, indice_CSP) = 0.02*ones(reg,1);
MSH_2190_elec_sup(:, indice_CSP) = 0.02*ones(reg,1);
MSH_730_elec_sup(:, indice_CSP) = 0.02*ones(reg,1);

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


[Cap_elec_MWref_coal.Cap,Cap_elec_MWref_coal.Descp] = csvread(path_elec_capac_MW_new+'Cap_MW_ref_Coal.csv');
[Cap_elec_MWref_gas.Cap,Cap_elec_MWref_gas.Descp] = csvread(path_elec_capac_MW_new+'Cap_MW_ref_Gas.csv');
[Cap_elec_MWref_oil.Cap,Cap_elec_MWref_oil.Descp] = csvread(path_elec_capac_MW_new+'Cap_MW_ref_Oil.csv');
Cap_elec_MWref_coal.Cap=Cap_elec_MWref_coal.Cap(:,1);//apparently, issues with decimal, this fixes everything
Cap_elec_MWref_gas.Cap=Cap_elec_MWref_gas.Cap(:,1);
Cap_elec_MWref_oil.Cap=Cap_elec_MWref_oil.Cap(:,1);

[Cap_elec_MWref_nuke.Cap,Cap_elec_MWref_nuke.Descp] = csvread(path_elec_nuke_MW_new+'Nuke2014.csv');

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

Cap_elec_MWref(:,indice_OCT) = 0.9*Cap_elec_MWref_oil.Cap;
Cap_elec_MWref(:,indice_OGC) = 0.1*Cap_elec_MWref_oil.Cap;

Cap_elec_MWref(:,indice_NUC) = Cap_elec_MWref_nuke.Cap; //not so far from POLES estimations
Cap_elec_MWref(:,indice_NND) = 0; //zero NND installed

for techno_CCS = [indice_PSS,indice_CGS,indice_UCS]
    Cap_elec_MWref(:,techno_CCS)  = 0; //zero CCS installed
end

//Biomass with actualized installed cap, corresponding to development stage techno.
Cap_elec_MWref(:,indice_BIGCC) = elecBiomassInitial.cap.Cap; //

Cap_elec_MWref(:,indice_BIGCCS) =0;

//unused technos for now. Can not set the Cap to zero, otherwise 2915 equilibrium fails
Cap_elec_MWref(:,indice_CHP)=0;
Cap_elec_MWref(:,indice_SHY)=0;
Cap_elec_MWref(:,indice_GFC)=0;
Cap_elec_MWref(:,indice_HFC)=0;



for techno = techno_ENR
    execstr("Cap_elec_MWref(:,indice_"+techno+")=elecENRInitial.cap."+techno);
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
//rendements: fichier rendements.xls

rho_elec=zeros(nb_regions,techno_elec,TimeHorizon);

rho_poles_temp=csvRead(path_elec_yields+'electric_conversion_yields.csv','|',[],[],[],'/\/\//');

//passage à 2100
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
        rho_elec(k,indice_BIGCC ,j) = elecBiomassInitial.efficiencyBIGCC;
        rho_elec(k,indice_BIGCCS,j) = elecBiomassInitial.efficiencyBIGCCS;
    end
end


rho_elec_vintage=zeros(nb_regions,techno_elec,Life_time_max+TimeHorizon+1);
rho_elec_hist=rho_elec(:,:,1);
//calibrage du rendement moyen historique des centrales pour retomber sur les bons chiffres pour la reconstitution des CI dans le nexus electrique
load(path_elec_hist_share+'share_OIL_EP_REF.sav');
load(path_elec_hist_share+'share_GAS_EP_REF.sav');
load(path_elec_hist_share+'share_COL_EP_REF.sav');

for k=1:nb_regions
    for j=technoCoal+technoGas+1:technoFF
        rho_elec_hist(k,j)=share_OIL_EP_REF(k,1)*Qref(k,indice_elec)/(CI(indice_Et,indice_elec,k)*Qref(k,indice_elec));
    end
    for j=technoCoal+1:technoCoal+technoGas
        rho_elec_hist(k,j)=share_GAS_EP_REF(k,1)*Qref(k,indice_elec)/(CI(indice_gaz,indice_elec,k)*Qref(k,indice_elec));
    end
    for j=1:technoCoal
        rho_elec_hist(k,j)=share_COL_EP_REF(k,1)*Qref(k,indice_elec)/(CI(indice_coal,indice_elec,k)*Qref(k,indice_elec));
    end
end

for j=1:Life_time_max+1
    rho_elec_vintage(:,:,j)=rho_elec_hist;
end

for j=Life_time_max+1:Life_time_max+TimeHorizon
    rho_elec_vintage(:,:,j)=rho_elec(:,:,j-Life_time_max);
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



Cap_elec_MW_vintage_prev=Cap_elec_MW_vintage;

//===================================//

//Availability factor to replace ava_to_inst_poles variable
avail_factor = ones(reg,techno_elec);
Utilrate=ones(reg,techno_elec);
first_run_ava = 1;
//===================================//
//availability factor for hydro

if ind_climat==1
    AF_hydro=csvRead(DATA+'Enerdata\POLES_hydro\AF_climat.csv');
    else
    AF_hydro=csvRead(DATA+'Enerdata\POLES_hydro\AF_baseline.csv');
    end

    
AF_hydro = AF_hydro(2:$);//removing header text in the CSV file
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
avail_factor(:,[indice_BIGCC,indice_BIGCCS]) = mean([83,84,80,83,85])/100; //Biomass
avail_factor(:,indice_HYD) = AF_hydro(:,1);
avail_factor(:,indice_CSP) = elecENRInitial.loadFactor.CSP'*1000/8760;
//IEA (2020) Projected Costs of Generating Electricity - 2020 Edition
avail_factor(:,technoElecNuke) = 0.85;


AF_hydro = AF_hydro(:,2:$); // so year 1 is now 2015 for the avail factor


//===================================//
//load duration curve design from POLES
part_max_poles=csvRead(path_elec_loadcurve+'part_max_courbes_charge.csv','|',[],[],[],'/\/\//');
part_min_poles=csvRead(path_elec_loadcurve+'part_min_courbes_charge.csv','|',[],[],[],'/\/\//');


taux_croiss_elec=zeros(nb_regions,1);
taux_croiss_comp=zeros(nb_regions,1);

//===================================//
//Load factor in thousand hours of functionning
//===================================//
Load_factor_ENR_temp=csvRead(path_elec_loadcurve+'Loadfactor_ENR.csv','|',[],[],[],'/\/\//');
Load_factor_ENR=matrix(Load_factor_ENR_temp,nb_regions,technoENR+1);

Load_factor_ENR(:,3) = elecENRInitial.loadFactor.WND';
Load_factor_ENR(:,4) = elecENRInitial.loadFactor.WNO';
Load_factor_ENR(:,5) = elecENRInitial.loadFactor.CSP';
Load_factor_ENR(:,6) = elecENRInitial.loadFactor.CPV';
Load_factor_ENR(:,7) = elecENRInitial.loadFactor.RPV';


Load_factor_ENR = Load_factor_ENR(:,[1:4,6:11]); //without CSP, which is counted as "conventionnal"
Load_factor_CSP = elecENRInitial.loadFactor.CSP';
//old scenario alternative for sequestration hypothesis: F4, see revision 29305 (F4=facteur4)

//===================================//
//Variable and fixed O&M
//===================================//


OM_cost_var=zeros(nb_regions,techno_elec,TimeHorizon);
OM_cost_fixed=zeros(nb_regions,techno_elec,TimeHorizon);
OM_cost_fixed_POLES=csvRead(path_elec_costs+'OM_costs_fixed.csv','|',[],[],[],'/\/\//');
OM_cost_var_POLES=csvRead(path_elec_costs+'OM_costs_var.csv','|',[],[],[],'/\/\//');

//passage à 2100
size_temp=size(OM_cost_var_POLES);
for k=1:50                                                
        OM_cost_var_POLES(:,size_temp(2)+k)=OM_cost_var_POLES(:,size_temp(2));
end
//exogenous trajectories are starting from 2001 (calibrated for previous version of the model), so we keep only the values starting from starting year of simulation
OM_cost_var_POLES=OM_cost_var_POLES(:,base_year_simulation-2000:TimeHorizon+base_year_simulation-2000);

size_temp=size(OM_cost_fixed_POLES);
for k=1:50                                                
        OM_cost_fixed_POLES(:,size_temp(2)+k)=OM_cost_fixed_POLES(:,size_temp(2));
end
//exogenous trajectories are starting from 2001 (calibrated for previous version of the model), so we keep only the values starting from starting year of simulation
OM_cost_fixed_POLES=OM_cost_fixed_POLES(:,base_year_simulation-2000:TimeHorizon+base_year_simulation-2000);


for j=1:TimeHorizon
    for ind_technoElecIM=1:technoConvwoCSP
         OM_cost_fixed(:,ind_technoElecIM,j)=Usd2001ToEur1999*OM_cost_fixed_POLES(ind_POLES(ind_technoElecIM),j);
         OM_cost_var(:,ind_technoElecIM,j)=Usd2001ToEur1999*OM_cost_var_POLES(ind_POLES(ind_technoElecIM),j);
    end
end



// Loaded all POLES data. Converting into 2014USD
OM_cost_fixed = OM_cost_fixed * CPI_2001_to_2014;//PING_FL
OM_cost_var = OM_cost_var* CPI_2001_to_2014;//PING_FL

//elecBiomassInitial is already in 2014USD
OM_cost_var(:,indice_BIGCC,:)    = elecBiomassInitial.OMCostVar;
OM_cost_var(:,indice_BIGCCS,:)   = elecBiomassInitial.OMCostVar;

for j=1:TimeHorizon
for techno = techno_ENR
    execstr("OM_cost_var(:,indice_"+techno+",j)=elecENRInitial.OMCostVar."+techno);
    execstr("OM_cost_fixed(:,indice_"+techno+",j)=elecENRInitial.OMCostFixed."+techno);
end
end


part_ENR_prod_endo=ones(nb_regions,TimeHorizon+20)*%eps; //nicer to get ones than zeros

//correction des couts de maintenance
OM_cost_var_ref=  OM_cost_var(:,:,1);
OM_cost_fixed_ref=OM_cost_fixed(:,:,1);
//PING_FL############
//For Variable O&M : Cost and Performance Assumptions for Modeling Electricity Generation Technologies(2010) gives a rough idea, did not find any better for now. Can not differentiate CCS from conv techno. CAREFUL : 2007$ and in $/MWh so divided by 10^3
//use the mean of 4 model values
OM_cost_var_ref(:,technoElecCoal) = mean([4.58,1.77,5.02,4.59])/10^3*CPI_2007_to_2014;
OM_cost_var_ref(:,[indice_ICG,indice_CGS]) = mean([2.92,4.06,2.92])/10^3*CPI_2007_to_2014;
OM_cost_var_ref(:,indice_GGT) = mean([3.17,2.92,3.77,3.17])/10^3*CPI_2007_to_2014;
OM_cost_var_ref(:,indice_GGC) = mean([2.00,3.13,2.22,2.00])/10^3*CPI_2007_to_2014;
OM_cost_var_ref(:,indice_GGS) = OM_cost_var_ref(:,indice_GGC); // Hyp O&M CCGT + CCS = CCTG
OM_cost_var_ref(:,indice_OCT) = OM_cost_var_ref(:,indice_GGT); // Hyp O&M OCT = GGT
OM_cost_var_ref(:,indice_OGC) = OM_cost_var_ref(:,indice_GGS); //Hyp O&M OGC == GGC
OM_cost_var_ref(:,technoElecNuke)= mean([0.49,0.52,1.97,0.49])/10^3*CPI_2007_to_2014;    // Nuclear

//Biomass (cf supra for sources)
OM_cost_var_ref(:,indice_BIGCC)    = ones(reg,1)*elecBiomassInitial.OMCostVar;
OM_cost_var_ref(:,indice_BIGCCS)   = ones(reg,1)*elecBiomassInitial.OMCostVar;


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

//Biomass (cf supra for sources)
OM_cost_fixed_ref(:,indice_BIGCC)  = elecBiomassInitial.OMCostFixedBIGCC';
OM_cost_fixed_ref(:,indice_BIGCCS) = elecBiomassInitial.OMCostFixedBIGCCS';
//Corrections a partir des donnï¿½es de la discussion avec Franï¿½ois Synthï¿½se plant costs elec.xls
//PING_FL################

//================================//
//Learning rates
//================================//

LR_ITC_elec=zeros(1,techno_elec);

//WEo (2021) Power generation technology costs and assumptions in the WEO-2021 Stated Policies and Net Zero Emissions by 2050 scenarios
LR_ITC_elec(:,[indice_ICG,technoCoalWCCS,indice_GGS,indice_BIGCCS])=0.10;
LR_ITC_elec(:,indice_BIGCC)=elecBiomassInitial.lrBIGCC;

for techno = techno_ENR
    execstr("LR_ITC_elec(:,indice_"+techno+")=elecENRInitial.lrCons."+techno);
end 

//Need to discuss if we keep ind_lre_opt dummy scenarios on learning rate
LR_ITC_elec_CCS=lr_ccs;

//==============================//
//Cumulated investment at calibration year
//==============================//
//Encore une fois un bordel, va trouver des données la dessus

Cum_Inv_MW_elec_ref=1000*ones(1,techno_elec);
Cum_Inv_MW_elec_ref(indice_SUB)=20000;//dont care since no learning is applied on subcritical coal
//For the most recent coal techno, we assume that the cumulated cap is given by existing cap (
Cum_Inv_MW_elec_ref(indice_PFC)=sum(Cap_elec_MWref(:,indice_PFC));
Cum_Inv_MW_elec_ref(indice_USC)=sum(Cap_elec_MWref(:,indice_USC));
Cum_Inv_MW_elec_ref(indice_ICG)=sum(Cap_elec_MWref(:,indice_ICG));
Cum_Inv_MW_elec_ref(indice_GGC)=sum(Cap_elec_MWref(:,indice_GGC)); //for CCGT, no clue, can be improved
for techno_CCS = [indice_PSS,indice_CGS,indice_UCS,indice_GGS]
   Cum_Inv_MW_elec_ref(:,techno_CCS)  = 10; //starting from positive CCS cap for learning
end
Cum_Inv_MW_elec_ref(indice_BIGCC)  = sum(Cap_elec_MWref(:,indice_BIGCC));
Cum_Inv_MW_elec_ref(indice_BIGCCS) = elecBiomassInitial.cumulatedInvRefBIGCCS;
for techno = techno_ENR
    execstr("Cum_Inv_MW_elec_ref(indice_"+techno+")=sum(elecENRInitial.cumulatedInvRef."+techno+")");
end


Cum_Inv_MW_elec=Cum_Inv_MW_elec_ref;


//==============================================//
//New elec nexus data (markup, share weights and WACC)
//==============================================
////FF/Renewable shares in the mix
share_FF_ENR=zeros(reg,nbTechFFENR);//PV(RPV+CPV) and wind(WND+WNO) shares in the mix
share_PV = zeros(reg,1);
share_Wind = zeros(reg,1);
markup_SIC = zeros(reg,2); //fsolve input, contains markups from previous period
share_real_costs = 0.5; // the share of the integration costs that correspond to real costs supported by VRE units(excluding profile costs). Correspond to orders of magnitude given by
//NEA & OECD (2019) Figure 39. The Costs of Decarbonisation: System Costs with High Shares of Nuclear and Renewables
//Share weights convergence horizon
Convergence_horizon = 16; //2030 converge for share weights
//Renewable LCOE
LCC_ENR = zeros(reg,length(technoExo_absolute));
//Miminum FF LCOE with inertia
LCC_FF_min = zeros(reg,1);
LCC_FF_min_prev = zeros(reg,1);
LCC_FF_min_prev_prev = zeros(reg,1);
if ind_lim_nuke==0
    inert_LCOE = 0.5;
else
    inert_LCOE = 0.3;
end
// Share weights calibration
target_year = 4; //since year 1 here is 2015, and data corresponds to 2018
if  run_calib_weights == %t //TB: Weights calibration. Requires an existing weights_ENR.tsv file, must be fixed to the file can be created if it does not exists yet
        target_prod = zeros(reg,nbTechExoAbsUsed);

[target_prod(:,1),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2018_WND.csv');
[target_prod(:,2),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2018_WNO.csv');
//[target_prod(:,3),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2018_CSP.csv');
[target_prod(:,3),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2018_CPV.csv');
[target_prod(:,4),target_prod_descr]                  =    csvread(path_elec_prod+'Prod_ENR_2018_RPV.csv');
[target_prod_tot,target_prod_descr]                  =     csvread(path_elec_prod+'Prod_tot_2018_.csv');
for j = 1:nbTechExoAbsUsed
    target_prod(:,j) = target_prod(:,j)./target_prod_tot;
    for k = 1:reg
        if target_prod(k,j) < 0.0001
            target_prod(k,j) = 0.0001;
        end
    end
end
    if(ind_logit_sensib_VRE)
        ldcsv("weights_ENR"+"_"+gamma_FF_ENR+".tsv",path_elec_weights)
    else 
        ldcsv("weights_ENR.tsv",path_elec_weights)
    end

end


// residual load curve
//// the coef are given in the following order (Intercept),Wind_share,PV_share,Wind_share_sq,PV_share_sq,Wind_share_cb,PV_share_cb,Wind_share:PV_share,PV_share:Wind_share_sq,Wind_share:PV_share_sq
coef_RLDC.coef = csvRead(path_RLDC_coef + 'coefRes_peak.csv',separator = "|");
coef_Curt.coef = csvRead(path_RLDC_coef + 'coefCurtailment.csv',separator = "|");

//Parameters needed to split curtailment between curtailed wind power and curtailed PV power. Curtailment happen for several reasons, but here we assume it is only oversupply. It means that, in average, some VRE plants with not provide electricity to the grid while they could = lost revenues.
    //Theses values (3 for 1) are only a rule of thumb
alpha_pv = 3;
beta_wd = 1;


//this "facteur_t", t standing for "tranche", refers to the weighted mean of the inner load bands, excluding baseload (8760h). This constant appear during
//load duration curve approximation
facteur_t = [8030+6570+5110+3650+2190+730]/6;
//residual peak estimation.
RLDC_peak = zeros(nb_regions,TimeHorizon+20);


//Initializing solar & wind shares + RLDC

Solar_sh_ref = sum((Load_factor_ENR(:,technoPVAbsolute)*1000).*Cap_elec_MWref(:,technoPV)./repmat((Qref(:,indice_elec)*mtoe2mwh),1,length(technoPV)),"c");
WD_sh_ref = sum((Load_factor_ENR(:,technoWindAbsolute)*1000).*Cap_elec_MWref(:,technoWind)./repmat((Qref(:,indice_elec)*mtoe2mwh),1,length(technoWind)),"c");
RLDC_peak_ref = find_RLDC_peak([WD_sh_ref,Solar_sh_ref]);
RLDC_peak(:,1)=RLDC_peak_ref;

//reserve margin as a % of residual peak load

reserve_margin = 0.2;
//POLES base to peak load ratio
bp_ratio = part_min_poles./part_max_poles;

//==============================================//
//CCS constraint
//==============================================
//Development stage for CCS (>0 Cap but no elec prod under min_CCS total market shares of CCS technos)
min_CCS=0.01;

//peak load coverage : sum of conventional power capacity divided by residual peak load.
// The residual peak load coverage constraints the investment to avoid oversized capacity in the electricity sector.

res_param = [1.2,1.6,1,0.5]; //min_x, max_x,m min_y, max_y, see the function in nexus.electricity.sci

residual_peak_cov = (sum(Cap_elec_MWref(:,technoEndo),"c"))./(RLDC_peak_ref.*(Qref(:,elec)*mtoe2mwh)./(bp_ratio*full_load_hours + facteur_t*(1-bp_ratio)));
