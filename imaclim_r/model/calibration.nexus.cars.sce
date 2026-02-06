// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Thomas Le Gallic, Aurélie Méjean, Céline Guivarch
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////calibration of nexus.cars //////////////////////////////
///////////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   INDEXES and DIMENSIONS   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////
DATA_CARS    = DATA + "carsnexusdata"  + sep ;


//number of technologies for cars
nb_techno_cars=3;

//technology definition
indice_CAR_ICE=1;  	   //ICE technology
indice_CAR_BEV=2;      //Battery electric vehicle 
indice_CAR_HYD=3;      //Fuel cell powered car, using hydrogen 
carsWithoutHydr = [indice_CAR_ICE indice_CAR_BEV]; //All technologies except fuel cell powered cars

carnames = ["ICE","BEV","HYDROGEN"];

//Use only 2 technologies in the default setting, 3 including fuel cells if the Land-Use nexus (NLU) is linked to IMACLIM 
if (ind_NLU == 1 & ind_hydrogen == 1)
    indice_cars2consider = [carsWithoutHydr indice_CAR_HYD];
else
    indice_cars2consider = carsWithoutHydr;
end

//conversion factors
//liter of gasoline to Mtoe
L_to_Mtoe=9.55E-10;
L_to_toe=9.55E-4;

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION  ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

///Lifetime of vehicles 
//references: Bento, Antonio, Kevin Roth, and Yiou Zuo. 2018. “Vehicle Lifetime Trends and Scrappage Behavior in the U.S. Used Car Market.” The Energy Journal 39 (1). https://doi.org/10.5547/01956574.39.1.aben.
//Hao, Han, HeWu Wang, MingGao Ouyang, and Fei Cheng. 2011. “Vehicle Survival Patterns in China.” Science China Technological Sciences 54 (3): 625–29. https://doi.org/10.1007/s11431-010-4256-1.
//Held, Maximilian, Nicolas Rosat, Gil Georges, Hermann Pengg, and Konstantinos Boulouchos. 2021. “Lifespans of Passenger Cars in Europe: Empirical Modelling of Fleet Turnover Dynamics.” European Transport Research Review 13 (1): 9. https://doi.org/10.1186/s12544-020-00464-0.)
lifetime_cars = 15; // lifetime common to all cars, including existing park at calibration year

// Life_time_LCC replaces Life_time when computing truncated LCC components
if ind_short_term_hor== 1
    Life_time_cars_LCC = min(lifetime_cars, nb_year_expect_LCC); 
else
    Life_time_cars_LCC = lifetime_cars;
end

LIFE_time_cars= lifetime_cars*ones(nb_regions,nb_techno_cars);

//Heterogeneity parameter used in the logit function of technology choices 
//(a high value means low heterogeneity, i.e., cheaper technologies take most of the market share; a low value means faster diffusion of BEV, but a lower maximum share of BEV)
var_hom_cars=8*ones(nb_regions,1); //As of 2021, other models had values in the range 5-10

//Average use of vehicles (km per year), set to the same value for all technologies
average_km_per_year=15000;

///Learning rates
//Reference: Grubb, M., Drummond, P., Poncia, A., McDowall, W., Popp, D., Samadi, S., Peñasco, C.,  et al. 2021. “Induced Innovation in Energy Technologies and Systems: A Review of Evidence and Potential Implications for CO2 Mitigation.” Environmental Research Letters. https://doi.org/10.1088/1748-9326/abde07. 
//gives values for electric and hybrid between 9% and 16%, and between 20% and 30% for fuel cells.

//Default learning rates
LR_ITC_cars=0.05*ones(1,nb_techno_cars); //Note that learning rates for ICE technologies do not matter much as those technologies are mature at calibration date
LR_ITC_cars(indice_CAR_BEV)=0.09; // NB: in a previous (removed) optimistic alternative variant, we used: LR_ITC_cars(indice_CAR_BEV)=0.16; it has been removed as it was redundant with another variant.
LR_ITC_cars(indice_CAR_HYD)=0.2; // NB: in a previous (removed) optimistic alternative variant, we used: LR_ITC_cars(indice_CAR_HYD)=0.3.

///S-curves
//Specification of the S-curve for EV (BEV technology). Tstart+Tniche+Tgrowth gives the earliest date at which the technology can take up to 90% of MSHmax
Tstart_EV=zeros(nb_regions,1);		//EVs are already in the market at calibration date 
Tniche_EV=6*ones(nb_regions,1); 	//By 2020, EVs could make up to 5.5% of the market 
Tgrowth_EV=15*ones(nb_regions,1);   //By 2030, EVs could make up to 90% of the market 
Tmature_EV=15*ones(nb_regions,1);   //By 2050, EVs could make up to 100% of the market 
MSHmax_EV=ones(nb_regions,1);		//EVs could in theory take 100% of the market 

//Specification of the S-curve for fuel cell powered vehicles (HYD technology)
Tstart_HYD =(TimeHorizon+1)*ones(nb_regions,1);
Tniche_HYD=30*ones(nb_regions,1);
Tgrowth_HYD=40*ones(nb_regions,1);
Tmature_HYD=50*ones(nb_regions,1);
MSHmax_HYD =0.3*ones(nb_regions,1); //Fuel cell powered vehicles could in theory take 30% of the market 

//Specification of the S-curve in the optimistic scenario for HYD car technologies (fuel-cell powered vehicles)
if ind_cars_hyd == 1
    Tstart_HYD = 10*ones(nb_regions,1);
    Tniche_HYD = 30*ones(nb_regions,1);
end

//Initialization of upper bound of market share by technology
msh_cars_sup = zeros(nb_regions,nb_techno_cars);

/////////////////////////////////////////////////////////////////////////////////////////////
//    ---*---   CALIBRATION   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////
//////////////////////////Car types///////////////////////////////////////

///Energy intensities
//Loading data for Hydrogen technology
energyusePerKm_hyd = csvRead(path_cars_hybd+"energy_use_per_km_hybrid_cars.csv",'|',[],[],[],'/\/\//');
energyUsePerKm_hyd_ref  = energyusePerKm_hyd(1) * kgH2ToMtoe; // was 1   kgH2/100km
energyUsePerKm_hyd_2030 = energyusePerKm_hyd(2) * kgH2ToMtoe; // was 0.8 kgH2/100km
energyUsePerKm_hyd_2050 = energyusePerKm_hyd(3) * kgH2ToMtoe; // was 0.6 kgH2/100km

//Initializing energy intensity
EFF_ICE=zeros(nb_regions,TimeHorizon+1);   //Liquid Fuel Energy Intensity Mtoe/(vehicule.km)
EFF_BEV=zeros(nb_regions,TimeHorizon+1);   //Electricity Fuel Energy Intensity Mtoe/(vehicule.km)
EFF_HYD=zeros(nb_regions,TimeHorizon+1);   //Hydrogen Fuel energy Intensity Mtoe/(vehicule.km)

//Calibration of fuel efficiency

//ICE and BEV																

data_EFF_ICE_2014 = "consistent"; //EDIT Navigate 3.5: we replaced the data below by those extracted from the energy efficiency indicators dataset (IEA). Both datasets come from IEA and they are not fully consitent. We chose this one to be consistent with the computation of energy consumption from road transport, household and pkm. TO BE DISCUSSED as we could also adapt the initial values to be consistent with the other set of data.
if data_EFF_ICE_2014 == "consistent"
    EFF_ICE_2014 = conso_unitaire_Mtoe_vkm; 
else
    EFF_ICE_2014 = csvRead(DATA_CARS +"EFF_ICE.csv",'|',[],[],[],'/\/\//'); // Values estimated using data from the IEA report Fuel Economy in Major Car Markets Technology and Policy Drivers 2005-2017: https://www.iea.org/reports/fuel-economy-in-major-car-markets // Note that the use of this dataset reached to weird efficiency trajectories as they were higher than the initial values.
end
EFF_BEV_2014 = csvRead(DATA_CARS +"EFF_BEV.csv",'|',[],[],[],'/\/\//'); // PATH TO BE UPDATED: change "DATA_CARS" into "path_cars_eff"

EFF_ICE(:,1) = EFF_ICE_2014 ;
EFF_BEV(:,1)= repmat(EFF_BEV_2014,nb_regions,1); //same fuel efficiency in all regions for BEV

//parameters for the fuel efficiency improvement of ICE
//we assume the asymptote for ICE fuel efficiency is 2l/100km, convert to Mtoe/km
//We represent that the gap between the energy efficiency and a floor of 2L/100km for ICE is reduced as a linear function of fuel prices (the higher the price, the faster the gap is reduced)
//From Figure 3 page 16 and Table KF1 page 5 of the IEA report Fuel Economy in Major Car Markets Technology and Policy Drivers 2005-2017: https://www.iea.org/reports/fuel-economy-in-major-car-markets
//We take two points: average of countries with high fuel prices (average 1.4 USD/l) that over 2005-2017 reduced the gap to 2l/100km by 2.9%/yr on average, and average of countries with low fuel proces (average 0.8 USD/l) that reduced the gap by 2.6%/yr on average.
//Annual reduction of gap (in %)=0.5*price (in USD/l)+2.2
EFF_ICE_floor=2*L_to_Mtoe/100*ones(reg,1);
autonomous_EFF_ICE=2.2; // Value for the years before 2020 (start year policy)
price_induced_EFF_ICE=0.5;

//parameters for the fuel efficiency improvement of BEV
//Assumption the energy efficiency is improved linearly to reach its asymptote of 100 Wh/km (ie half of the calibration value) in 30 years
EFF_BEV_floor=0.5*EFF_BEV(:,1);
EFF_BEV_time=60;

//Fuel cell powered cars
EFF_HYD(:,1:15)   = energyUsePerKm_hyd_ref ;
EFF_HYD(:,15:30)  = ones(nb_regions,1) * linspace(energyUsePerKm_hyd_ref ,energyUsePerKm_hyd_2030,16) ;
EFF_HYD(:,30:50)  = ones(nb_regions,1) * linspace(energyUsePerKm_hyd_2030,energyUsePerKm_hyd_2050,21) ;
EFF_HYD(:,50:TimeHorizon+1) = energyUsePerKm_hyd_2050 ;

///Discounting factor
CRF_cars = disc_cars./(1-(1+disc_cars).^(-Life_time_cars_LCC*ones(nb_regions,nb_techno_cars))); //This value is not sourced. Alternative value could be 23% from Kalai et al. 2018. “Integration of Behavioral Effects from Vehicle Choice Models into Long-Term Energy Systems Optimization Models.” Energy Economics 74 (August): 663–76. https://doi.org/10.1016/j.eneco.2018.06.028.

///Calibration of the shares of each technology in the existing fleet at reference year
MSH_cars_ref=csvRead(DATA_CARS+"MSH_cars_ref_2014.csv",'|',[],[],[],'/\/\//'); //PATH TO BE UPDATED: change "DATA_CARS" into "path_cars_capital"
MSH_cars=MSH_cars_ref;
sg_add("MSH_cars");
	
///Fleet at year current_time_im, ventilated by region and technology
stock_car_ventile = zeros(nb_regions,nb_techno_cars,TimeHorizon+1);
stock_car_ventile(:,:,1)= MSH_cars_ref.*(nombreautomobileref*ones(1,nb_techno_cars));

//Generation of cars by region, technology and year of sale
stockVintageAutoTechno=zeros(nb_regions,nb_techno_cars,TimeHorizon+1);

///Induced technical change

// TODO change hybrid to hydrogen
cinv_ref_cars_hyd = csvRead(path_cars_hybd+"investment_cost_hybrid_cars.csv",'|',[],[],[],'/\/\//');
cinv_ref_cars_hyd_low = cinv_ref_cars_hyd(1); // low  end of range for initial investment costs
cinv_ref_cars_hyd_high= cinv_ref_cars_hyd(2); // high end of range for initial investment costs
cinv_asy_cars_hyd     = cinv_ref_cars_hyd(3);  // asymptote

//Investment costs of cars
CINV_cars_nexus_ref=zeros(nb_regions,nb_techno_cars);
//Uniform assumption for ICE vehicles (average order of magnitude) (in M$)
CINV_cars_nexus_ref(:,indice_CAR_ICE)=0.015*ones(nb_regions,1);
//Adding investment cost of hybrid cars
//low end range for USA/CAN/EUR/JAN, high end range for the rest of the world
CINV_cars_nexus_ref(ind_usa:ind_jan,indice_CAR_HYD) = cinv_ref_cars_hyd_low*ones(4);
CINV_cars_nexus_ref(ind_cis:$,indice_CAR_HYD) = cinv_ref_cars_hyd_high*ones(8);

                            
/////Definition of asymptotes for capital costs
//we assume BEV cars can reach the same cost as ICE
A_CINV_cars_ITC_ref=CINV_cars_nexus_ref(:,indice_CAR_ICE)*ones(1,nb_techno_cars);
A_CINV_cars_ITC_ref(:,indice_CAR_HYD) = cinv_asy_cars_hyd;
A_CINV_cars_ITC_ref(:,indice_CAR_BEV) = A_CINV_cars_ITC_ref(:,indice_CAR_BEV)./3; // Adjustment as we reached low max rate. This should be consolidated.

/////Cumulated investment at reference year
Cum_Inv_cars_ref= csvRead(DATA_CARS+"cum_inv_cars.2014.csv",'|',[],[],[],'/\/\//'); //PATH TO BE UPDATED: change "DATA_CARS" into "path_cars_capital"
Cum_Inv_cars=Cum_Inv_cars_ref;

//initial O&M costs
OM_cost_2014 = csvRead(DATA_CARS+"OM_cars.csv",'|',[],[],[],'/\/\//'); //PATH TO BE UPDATED: change "DATA_CARS" into "path_cars_costs"
OM_cost_var_cars = repmat(OM_cost_2014,nb_regions,1)*1e-6; // costs converted to M$

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////Calibration of EV investment costs, including intangible costs (range anxiety, etc), to reproduce first year market shares in sales
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

MSH_BEV_hist = csvRead(DATA_CARS+"EV_MSH__iea.csv",'|',[],[],[],'/\/\//'); //PATH TO BE UPDATED: change "DATA_CARS" into "path_cars_capital"
header_tpt = MSH_BEV_hist(1,:);
ind_baseyear = find(header_tpt==base_year_simulation);
MSH_BEV_hist = MSH_BEV_hist(2:$, ind_baseyear:$);

MSH_cars_year1=csvRead(DATA_CARS+"MSH_cars_ref_2015.csv",'|',[],[],[],'/\/\//'); //PATH TO BE UPDATED: change "DATA_CARS" into "path_cars_capital"
MSH_cars_year1(:,indice_CAR_BEV) = MSH_BEV_hist(:,1);
MSH_cars_year1(:,indice_CAR_ICE) = 1 - sum(MSH_cars_year1(:,[indice_CAR_BEV,indice_CAR_HYD]), 'c');

//Share of EV in sales the first year
MSH_BEV_year1=MSH_cars_year1(:,indice_CAR_BEV);
//Lifecycle cost of ICE car (per vkm)
LCC_ICE_year1=CRF_cars(:,indice_CAR_ICE).*CINV_cars_nexus_ref(:,indice_CAR_ICE)./average_km_per_year+OM_cost_var_cars(:,indice_CAR_ICE)./average_km_per_year+pArmDFref(:,indice_Et).*EFF_ICE(:,1);
CINV_BEV_year1=average_km_per_year./CRF_cars(:,indice_CAR_ICE).*((MSH_BEV_year1./(ones(nb_regions,1)-MSH_BEV_year1).*LCC_ICE_year1.^(-var_hom_cars)).^(-ones(nb_regions,1)./var_hom_cars)-OM_cost_var_cars(:,indice_CAR_BEV)./average_km_per_year-pArmDFref(:,indice_elec).*EFF_BEV(:,1));
CINV_cars_nexus_ref(:,indice_CAR_BEV)=CINV_BEV_year1;
