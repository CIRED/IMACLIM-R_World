// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thomas Le Gallic, Céline Guivarch
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///////////////////////////////////////////////////////////////////////////////////
////////////////////////// Calibration of nexus.transport /////////////////////////
///////////////////////////////////////////////////////////////////////////////////

// ----  Foreword and general comments on the nexus ---- //

// "Transport" covers a wide range of activities: 
// - the displacement of passengers or goods ;
// - journeys made by individuals on a personal or professional basis;
// - regular, everyday journeys (e.g. home-work journeys), or exceptional journeys (e.g. long-distance tourist trips), with specific motivations and constraints;
// - journeys made using different modes of transport: car, plane, boat, foot, train, underground, bus, etc.
// The diversity of these activities raises issues of scope, accounting and disaggregation in terms of the data used to calibrate the model, and then in the way in which the dynamics of change are represented. Some sources are based on monetary flows (expenditure on fuel, transport services), which distinguish between the different types of agent, but may not distinguish between all modes of transport, or the purpose of the transport (passenger or goods); others are based on traffic data, which may be precise in terms of vehicle types, but do not distinguish between the type of agent initiating the journey). The resulting data issues require modelling choices to be made, and estimates to be made in order to achieve the desired disaggregation.
//
// In the current version of the Imaclim-R world model :
// - 3 sectors are distinguished in the Input-Output matrix, corresponding to three types of transport services: maritime, land and air transport services, which include both passenger transport (modest for maritime transport, and considered to be zero) and freight transport. Based on data for the calibration year, estimates of the passenger/freight split are produced and used;
// - 4 modes are initially considered in the reconstruction of household (personal) travel demand from the utility function: car, air, non-motorised and other land transport (which mainly includes bus and rail). The resulting modal shares are used to estimate changes in demand for passenger mobility by other economic agents (particularly for passenger car mobility);
// - 4 modalities are distinguished for the "Other Terrestrial Transport" sector: rail freight, rail passenger, road freight, and road passenger. The purpose of this desaggregation effort is to better assess the decarbonisation capacities and modal shift efforts made in the field of inland freight transport and collective mobility. 
//
// 
// The purpose of the transport nexus (and the associated "cars" nexus) is (1) to make the estimates needed for these disaggregations in the calibration year (note that some estimates are also made within the preparation of calibration data process); (2) to model the dynamics of change in the various modes of transport, which mainly includes changes in energy efficiency and energy carriers specific to each mode (depending on energy prices, learning dynamics, policies, etc.), but also modal shifts or the parameters that determine them. 

// Two articles from Imaclim team have focused on the transport sector. Refer to them for data sources and descriptions
// Waisman, H. D., C. Guivarch, and F. Lecocq. 2013. “The Transportation Sector and Low-Carbon Growth Pathways: Modelling Urban, Infrastructure, and Spatial Determinants of Mobility.” Climate Policy 13 (sup01): 106–29. https://doi.org/10.1080/14693062.2012.735916
// Fisch-Romito, Vivien, and Céline Guivarch. 2019. “Transportation Infrastructures in a Low Carbon World: An Evaluation of Investment Needs and Their Determinants.” Transportation Research Part D: Transport and Environment 72 (July): 203–19. https://doi.org/10.1016/j.trd.2019.04.014.
 

// The code is currently organised by mode:
// 0.	Initialization of cross-mode parameters
// I. 	Cars / Light-Duty Vehicles (LDV)
// II. 	Other terrestrial transport (rail freight, rail passenger, road freight, road passenger)
// III.	Aviation
// IV. 	Shipping
// V. 	Transportation infrastructures and speed of modes



//--------------------------------------------------------------------//
// Preliminary Section: Initialization of cross-mode parameters       //
//--------------------------------------------------------------------//

// Number of modes of transport for household mobility, and definition of indexes for each mode
nb_trans_mode_hsld = 4;
ind_hsld_transpAir = 1; 
ind_hsld_transpOT = 2; // "Other terrestrial motorized transport", this includes both rail and road passenger transportation
ind_hsld_transpCar = 3;
ind_hsld_transpNM = 4; // Non-mothorized, which is accounted for in the utility function

// Parameters of the 'transport' part of households utility fonction
sigmatrans 	= -0.7 * ones(nb_regions,1); // elasticity of substitution between transport modes
betatrans	= 1/(nb_trans_mode_hsld)*ones(nb_regions,nb_trans_mode_hsld); 

// Number of hours travelled per day:
nb_hour_travelled = 1.1; // Initialisation of the travel time considered (in hour/day), constant by default
nb_days_peryear = 365;
Tdisp = Ltot.*( nb_hour_travelled * ones(nb_regions,1)) * nb_days_peryear; // Total travel time
// Note for the reader: to anticipate changes in personal mobility demand (distances per mode), a time constraint is considered in addition to the utility function. This is based on the results of empirical work showing a certain stability in the average time spent on mobility at an aggregate level in several regions of the world. 
// references: Zahavi, Y. and Talvitie, A. 1980. Regularities in travel time and money expenditures. Transportation Research Record, 750: 13–19.
// Schäfer, A. (2012). Introducing behavioral change in transportation into energy/economy/environment models. Draft Report for ‘Green Development’ Knowledge Assessment of the World Bank.
// Schäfer, A., Heywood, J. B., Jacoby, H. D. and Waitz, I. A. 2009. Transportation in a climate-constrained world, Cambridge, MA: MIT Press
// Metz, D. 2008. The myth of travel time saving. Transport Reviews, 28(3): 321–336. doi:10.1080/01441640701642348

// Basic needs for transport modes
bnNM = zeros(nb_regions,1); // default assumption: set to zero for all regions
bnOT_share_Cons = zeros(nb_regions,1); // default assumption: set to zero for all regions
bnair_share_Cons = zeros(nb_regions,1); // default assumption: set to zero for all regions
// Pour la voiture,  des essais liés au problème de forte baisse de la demande de mobilité dans les régions à plus bas revenu sur les premières décennies ; à retirer une fois le problème réglé
ind_newBN = 0;
if ind_newBN == 0 | current_time_im == 2017 - base_year_simulation // NB : ce code n'est a priori exécuté qu'en 2014, donc la deuxième condition n'a pas d'utilité ici
    bnautomobileref=50*ones(nb_regions,1); // Default assumption for cars, 50% of pkm by cars at calibration date
else // Essais liés au problème de demande de mobilité dans les régions à plus bas revenu ; il me semble que ça n'est plus utile (Thomas); à retirer une fois le problème réglé
    bnautomobileref = [50;50;50;50;50;0;0;0;0;0;0;0]; 
    bnautomobileref = [50;50;50;50;50;70;70;70;70;70;70;70];
    bnautomobileref = [50;50;50;50;50;80;80;80;80;80;80;80];
end
bnautomobile = bnautomobileref;

// Share of households expenditures in composite goods spent on car maintenance (could be in section I, but needed for computation below)
// In current version it is assumed that 10% of composite good consumption by household correspond to cars operation and maintenance costs (OM costs) 
// One improvement would be to recompose it also at the calibration year with actual data of operation and maintenance costs used in calibration.nexus.cars
shCompoEntretienAuto = 0.1 * ones(nb_regions,1); // in dynamics this expenditure is recomposed with cars operation and maintenance costs

// Calibration of Consoref: concern all sectors
Consoref = zeros(nb_regions,nb_secteur_conso);
Consoref(:,indice_construction-nbsecteurenergie)	= DFref(:,indice_construction);
Consoref(:,indice_composite-nbsecteurenergie)		= DFref(:,indice_composite).*(1-shCompoEntretienAuto); // on attribue les depenses automobiles au secteur service
Consoref(:,indice_air-nbsecteurenergie)				= DFref(:,indice_air);
Consoref(:,indice_mer-nbsecteurenergie)				= DFref(:,indice_mer);
Consoref(:,indice_OT-nbsecteurenergie)				= DFref(:,indice_OT);
Consoref(:,indice_agriculture-nbsecteurenergie)		= DFref(:,indice_agriculture);
Consoref(:,indice_industries-nbsecteurenergie)		= DFref(:,indice_industries);

// Initialisation of the pkm variable
pkm_ref = zeros( nb_regions, nb_trans_mode_hsld - 1);



//--------------------------------------------------------------------//
// I. Cars / Light-Duty Vehicles (LDV) section                        //
//--------------------------------------------------------------------//

Tautomobileref = 100*ones(nb_regions,1); // Reference for pkm automobile, base 100
stockautomobileref = 100*ones(nb_regions,1); // Reference for stock of vehicles, base 100
stockinfraref = 100 * ones(nb_regions,1); // Reference for the road infrastructure stock

// Evolution parameter of basic needs over time (for private cars). Default assumption: basic needs for cars follow evolution in pkm by car (sort of lock-in or habituation)
bnauto_dependancy_trends = 0.5 * ones( nb_regions,1);

// Households energy use for private vehicles. Generate data comes from the hybridization procedure of Energy Balances and National Accounting Matrixes from GTAP and IEA, part of which comes from the IEA Energy Efficiency database
DF_HHtransport = Ener_C_hsld_road_dom_Im(:,1:5)+Ener_C_hsld_road_imp_Im(:,1:5);

// NB: within the hybridation process, we had to estimate the fuel expenditure from household (for road transport). Based on data from USA and France, we approximate it to 60% of the whole fuel expenditure for road transport with light vehicles (cars & light trucks). Commonly (IEA, IAMs), the distance travelled by cars (in pkm) include both distance travelled by households and distance travelled by the other agents (companies, public administrations). In our dynamics, we consider only the distance travelled by households, so here we apply a /0.6 ratio. And we adjusted the output in the extraction file, to avoid double counting. 
pkmAll_to_pkmHousehold = 0.6;

// Calibration of number of cars per region
nombreautomobileref = csvRead(path_transport_cars+'nombreautomobileref.csv','|',[],[],[],'/\/\//'); // data source https://www.oica.net/category/vehicles-in-use/ (all vehicles)
nb_car_pc=nombreautomobileref./Ltot0; // Note this is defined here, even though it is related to cars (and not in dedicated calibration.nexus.cars) because it is needed before calibration.nexus.cars is run

// Computing number of kilometers done with those vehicles to ensure consistency between number of vehicles and final energy use
// Average number of person per vehicle (source IEA Energy Efficiency Indicators, extrapolation for missing regions on the basis of the relation between average income per capita and average occupancy rates of cars)
tauxderemplissageauto=csvRead(path_cars_occupancy_rate+'tauxderemplissageauto.csv','|',[],[],[],'/\/\//');
// Average energy use per vehicle.kilometer over the vehicle stock, (source: derived from IEA Energy Efficiency Indicators, extrapolation for missing regions on the basis of the relation between average income per capita and average consumption per vkm (cars and motorcycles))
conso_unitaire_Mtoe_vkm=csvRead(path_transport_consocars+'conso_unitaire_Mtoe_vkm_2014.csv','|',[],[],[],'',[2 2 13 2]);
// Computing vehicle.kilometre consistent with total and average unitary energy use
vkm_ref=(DF_HHtransport(:,indice_Et))./conso_unitaire_Mtoe_vkm;
pkm_ref(:,ind_hsld_transpCar) = vkm_ref.*tauxderemplissageauto;
pkmautomobileref=pkm_ref(:,ind_hsld_transpCar);

// For the evolution of motorization rates, growth of motorization per capita as a function of income per capita growth
inc_grwth_mult_A=csvRead(path_transport_car_unit+'income_growth_multipliers_cars_A.csv','|',[],[],[],'/\/\//'); // Values from MoMo model

// Unitary (per pkm) energy use for cars. Note this is defined here, even though it is related to cars (and not in dedicated calibration.nexus.cars) because it is needed before calibration.nexus.cars is run
alphaEtautoref=DF_HHtransport(:,indice_Et)./pkmautomobileref;
alphaEtauto=alphaEtautoref;

alphaelecautoref=zeros(nb_regions,1);
alphaelecauto=alphaelecautoref;

alphaHYDautoref=zeros(nb_regions,1);
alphaHYDauto=alphaHYDautoref;


// Parameters for the variant where nexus.cars is not used and instead a very simplied representation of the car fleet evolution is made with a price elasticity. Taken from a run from POLES, see file "D:\12 secteurs 2100\Nexus automobile\couplage étape 3 VCC\Nexus automobile "
// Variants of scenarios on energy efficiency improvement assumption, speed of improvement induced by prices 1 = fast, 0 = slow 
if indice_E == 1
    elast_auto_Et = -0.55*ones(nb_regions,1); // Price elasticity
elseif indice_E == 0
    elast_auto_Et = -0.45*ones(nb_regions,1);
end

// Variants of scenarios on energy efficiency improvement assumption, technical asymptote for minimal energy use 1 = high, 0 = low 
if indice_A==1
    asympt_alphaEtauto=0.3*ones(nb_regions,1); // Technical asymptote for minimum liquid fuel use
elseif indice_A==0
    asympt_alphaEtauto=0.25*ones(nb_regions,1);
end




//--------------------------------------------------------------------//
// II. Other terrestrial transportation section                       //
//--------------------------------------------------------------------//
// This includes: rail freight, rail passenger, road freight, road passenger
// NB: must run after nexus.cars.sce has run
// On the 10/04/2024, this version includes the old version of the dynamics (first part of the code), and the new version. The old one is kept for the first years to reach the 2017 equilibrium, but should be removed. 

// Number and types of modes in Other terrestrial transport (new version)
nb_desag_OT = 4;
label_desag_OT = ["rail_freight" "rail_passenger" "road_freight" "road_passenger"]; // Warning: the order must correspond to the order in file containing data data_OT_varioussources.csv


// II.1. Old version
// ------------------

// Scenario for activity reduction and energy efficiency
// optimistic assumption on road fret efficiency - if ind_roadFret_I=1
roadFret_optim_efficienc=0.02; // Assumption taken from the NAVIGATE T3.5 protocol

//50% electrification of trucks, buses  and trains by 2100 - if ind_OT_electrification==1
// based on NREL medium scenarios for the US in 2050
//https://data.nrel.gov/submissions/90
//https://www.nrel.gov/docs/fy18osti/71500.pdf
// we assume the same energy efficiency potential for eletric trucks
truck_elec_opt_potential=0.5;

CI_delta_Et_OT 		= zeros(nb_regions,1);
CI_delta_Et_OT(:)	= CI(indice_Et,indice_OT,:);

// We need to keep track of the different energy efficiency causality
CI_ener_OT_effInfra = CI; // Efficiency from infrastructure
CI_ener_OT_effNoSubs = CI; // Efficiency on road transport, excluding the substitution towards electricity

// Computation of passenger.kilometers for land transport
// We prefer to use data on energy (both total energy and unitary energy efficiency) to have correct energy values at calibration, and recompute corresponding passenger.kilometers (that can then be different from data on pkm) // TODO: should be modified?
// One issue to deal with is that land transport sector aggregates passenger and freight transport

// Sources : estimates computed from IEA Energy Efficiency Indicators (main source), WB data for income per capita (as an estimator), the Yearbook 2014 for China, ICAO data for aviation and GTAP to estimate the share of pkm travelled by household for leasures (and not for business). PKM for private modes and air transport can be considered as quite robust.
pkm_ref_calib = csvRead(path_transport_pkm2+'pkm_ref_calib_2014.csv','|',[],[],[],'',[2 2 13 4]);

pkmOTref=pkm_ref(:,ind_hsld_transpOT);

// Land transport energy use that can be attributed to passenger transport.
// Assuming it is proportional to pseudo quantities (ie final demand of household for OT sector), 
// We disregard differences between energy content of local production and importation
Conso_ener_OT_pass_ref=zeros(nb_regions,1);
for k=1:nb_regions
    Conso_ener_OT_pass_ref(k)=sum(DFref(k,indice_OT)*CI(1:nbsecteurenergie,indice_OT,k));
end

// Computing base year energy intensity for Imaclim
EI_OTpass_imaclimref=Conso_ener_OT_pass_ref./pkm_ref_calib(:,ind_hsld_transpOT);

// Correcting by the maximum/minum of the SMP model
// Average energy intensity of public transport from SMP model (minimum and maximum values from previous version of Imaclim for which we do not have access to the source anymore)
// In MJ/pkm these values are about 0.4 and 0.9. They are in the range of values for individual modes in individual countries and cities from Schäfer, Andreas W., and Sonia Yeh. 2020. “A Holistic Analysis of Passenger Travel Energy and Greenhouse Gas Intensities.” Nature Sustainability, April, 1–4. https://doi.org/10.1038/s41893-020-0514-9.
// even though they are higher values (and a few lower) in Schäfer and Yeh article, but it is probably to be expected for individual specific cases (compared to average at the regional level for us).
EI_OTpass_smp_min = 9.1E-12;
EI_OTpass_smp_max = 2.2E-11;

mask_temp_max = (EI_OTpass_imaclimref>EI_OTpass_smp_max);
mask_temp_min = (EI_OTpass_imaclimref<EI_OTpass_smp_min);
mask_corrected = mask_temp_max | mask_temp_min;

EI_OTpass_imaclimref( mask_temp_max) = EI_OTpass_smp_max;
EI_OTpass_imaclimref( mask_temp_min) = EI_OTpass_smp_min;


// For some regions we corrected the energy intensity of pkm, in consistency with energy statistics
// In that case pkm can be significantly different from data, but we need to keep energy intensity of modes correct (as in data) so that mode choice and policies make sense
pkmOTref = pkm_ref_calib(:,ind_hsld_transpOT);
pkmOTref( mask_corrected, ind_hsld_transpOT) = Conso_ener_OT_pass_ref(mask_corrected) ./ EI_OTpass_imaclimref(mask_corrected);

// Updating variable with the recomputed value
pkm_ref(:,ind_hsld_transpOT) = pkm_ref_calib(:,ind_hsld_transpOT);


///////////////////////////////////////////////////////////////////////////////////
///////////////////////////calibration of nexus.fret //////////////////////////////
///////////////////////////////////////////////////////////////////////////////////

// Note: the following assumption is not in use anymore since the nexus update. Could be re-introduced?
// road fret reduction compare to the baseline - if ind_roadFret_A=1
// 13.5% decrease assumption from Mulholland et al., 2018: https://doi.org/10.1016/j.apenergy.2018.01.058
road_fret_reduction = ones(TimeHorizon,1);
road_fret_reduction((start_year_strong_policy-base_year_simulation+1):(2050-base_year_simulation+1)) = linspace(1,1-0.135,2050-start_year_strong_policy+1)';


// II.2. New version
// ------------------
// Beginning of the new version of the calibration (12/2023)
// This new version aims to disaggregate the "Other Transportation" sector into rail freight, rail passenger, road freight, road passenger. 

// Here we create a variable to break down CI(energyIndexes,indice_OT,:) into CI_OT_serv and CI_OT_ldv, respectively the true intermediary consumption of direct energy by the "Other Transport" sector, and the part of what we count in this CI which is in fact consumed directly by all the sectors when they used LDV. This is due to the way we hybridized GTAP and IEA data.  
CI_OT_ldv = zeros(nb_sectors, nb_sectors, nb_regions);

// We know that we used a 0.6 ratio to estimate the share of ldv pkm travelled by household (and not by businesses and public administrations).
pkm_ldv_in_OT_ref = pkmautomobileref ./pkmAll_to_pkmHousehold*(1-pkmAll_to_pkmHousehold);
pkm_ldv_in_OT = pkm_ldv_in_OT_ref; 

// This share of CI(energyIndexes,indice_OT,:) will be indexed to the energy intensity of automobiles (see also nexus.transport)
for k = 1:nb_regions
    CI_OT_ldv(indice_Et,indice_OT,k) = alphaEtauto(k) * pkm_ldv_in_OT(k) / Qref(k,indice_OT); // We assume that the mean energy intensity of LDVs is the same for all LDV (households and others).
    CI_OT_ldv(indice_elec,indice_OT,k) = alphaelecauto(k) * pkm_ldv_in_OT(k)/ Qref(k,indice_OT); // Note that alphaelecauto is currently equals to zero at base year.
end

// The other share of CI(energyIndexes,indice_OT,:) has its own dynamics defined in a new version of the nexus transport (11/23)
CI_OT_serv = CIref - CI_OT_ldv;

// We load energy services 2015 values for each of the four modes, in share and in absolute value (absolute values are available in the same file, columns 10-13 and 14-17).
share_OT_EnergyServi_ref = csvRead(DATA_OT+'data_OT_varioussources.csv','|',[],[],[],'',[2 2 13 5]); // Share of energy services for respectively rail_fret, rail passenger, road_fret, road_passenger in 2015; Source: mean value from scenarios submitted in AR6. NB: sources could be improved
share_OT_FinalEnergy_ref = csvRead(DATA_OT+'data_OT_varioussources.csv','|',[],[],[],'',[2 6 13 9]); // Share of final energy for respectively rail_fret, rail passenger, road_fret, road_passenger in 2015; Source: mean value from scenarios submitted in AR6. NB: sources could be improved
value_OT_EnergyServi_ref = csvRead(DATA_OT+'data_OT_varioussources.csv','|',[],[],[],'',[2 10 13 13]); // Absolute values of energy services for respectively rail_fret, rail passenger, road_fret, road_passenger in 2015; Source: mean value from scenarios submitted in AR6. NB: sources could be improved
// share_OT_FinalEnergy_ref


// Small ad-hoc correction of initial values as we had negative values for China (Et consumption in rail passenger)
share_OT_FinalEnergy_ref(ind_chn,label_desag_OT == "rail_passenger") = share_OT_FinalEnergy_ref(ind_chn,label_desag_OT == "rail_passenger") + 0.03;
share_OT_FinalEnergy_ref(ind_chn,label_desag_OT == "road_passenger") = share_OT_FinalEnergy_ref(ind_chn,label_desag_OT == "road_passenger") - 0.03;

// We also create the dynamic variable
share_OT_EnergyServi = share_OT_EnergyServi_ref;

// Baseline assumptions of modal shift from rail to road, from 2025 to 2050: annual rate and max share.
rate_shifttorail_fret = [0.05;0.05;0.05;0.05;0.05;0.1;0.1;0.1;0.1;0.2;0.2;0.1]/25; // The value in the vector is the percentage change between 2025 and 2050. It is the same from 2025 until the max share is reached.
rate_shifttorail_pass = [0.1;0.1;0.1;0.1;0.01;0.2;0.2;0.2;0.1;0.3;0.3;0.2]/25; //Proposed values for a first try
max_share_rail_fret	= [0.6;0.6;0.5;0.5;0.9;0.7;0.7;0.25;0.15;0.6;0.2;0.3]; //Proposed values for a first try
max_share_rail_pass 	= [0.2;0.2;0.6;0.7;0.6;0.6;0.4;0.15;0.1;0.3;0.2;0.15]; //Proposed values for a first try

// We compute the initial shares of rail in fret and passenger "other transport"
ratio_OT_fret_rail_ref = share_OT_EnergyServi_ref(:,label_desag_OT == "rail_freight")./(share_OT_EnergyServi_ref(:,label_desag_OT == "rail_freight")+share_OT_EnergyServi_ref(:,label_desag_OT == "road_freight"));
ratio_OT_pass_rail_ref = share_OT_EnergyServi_ref(:,label_desag_OT == "rail_passenger")./(share_OT_EnergyServi_ref(:,label_desag_OT == "rail_passenger")+share_OT_EnergyServi_ref(:,label_desag_OT == "road_passenger"));
ratio_OT_fret_road_ref = 1-ratio_OT_fret_rail_ref;
ratio_OT_pass_road_ref = 1-ratio_OT_pass_rail_ref;

ratio_OT_fret_rail = ratio_OT_fret_rail_ref;
ratio_OT_pass_rail = ratio_OT_pass_rail_ref;
ratio_OT_fret_road = ratio_OT_fret_road_ref;
ratio_OT_pass_road = ratio_OT_pass_road_ref;

// We also compute the ratios of rail share to road share (useful for computation)
ratio_railtoroad_passref = ratio_OT_pass_rail_ref./ratio_OT_pass_road_ref;
ratio_railtoroad_fretref = ratio_OT_fret_rail_ref./ratio_OT_fret_road_ref;

// Here we compute the initial conversion factor from tkm and pkm to DF unity in Other transport (~ pseudo pkm and tkm)
convfactorOT_tkmtoDF = (Qref(:,indice_OT)-DFref(:,indice_OT)) ./ (value_OT_EnergyServi_ref(:,label_desag_OT == "rail_freight") + value_OT_EnergyServi_ref(:,label_desag_OT == "road_freight")); // Should "-Exp(:,indice_OT )+Imp(:,indice_OT )" be added to Q? => a priori no
convfactorOT_pkmtoDF = DFref(:,indice_OT) ./ (value_OT_EnergyServi_ref(:,label_desag_OT == "rail_passenger") + value_OT_EnergyServi_ref(:,label_desag_OT == "road_passenger"));

// We create a specific variable to follow energy services in each mode. Note that we compute it here to check the formula which will be used in the dynamics (even if we have already loaded these values from data_OT_AR6.csv above).
EnergyServices_rail_fret  = (Qref(:,indice_OT)- DFref(:,indice_OT)) ./ convfactorOT_tkmtoDF ./ ( 1 + 1 ./ratio_railtoroad_fretref ); // without Exp and Imp
EnergyServices_rail_pass  = DFref(:,indice_OT) ./ convfactorOT_pkmtoDF ./ ( 1 + 1 ./ratio_railtoroad_passref );
EnergyServices_road_fret  = (Qref(:,indice_OT)- DFref(:,indice_OT)) ./ convfactorOT_tkmtoDF ./ ( 1 + ratio_railtoroad_fretref ); // without Exp and Imp
EnergyServices_road_pass  = DFref(:,indice_OT) ./ convfactorOT_pkmtoDF ./ ( 1 + ratio_railtoroad_passref );


// Creation of the energy intensity variables per region, per energy source; one variable per mode. The unit is Mtoe / tkm and Mtoe / pkm
alpharail_freight_ref 	= zeros(nb_regions,size(energyIndexes,2)); 	// Mtoe / tkm
alpharail_passenger_ref 	= zeros(nb_regions,size(energyIndexes,2));// Mtoe / pkm
alpharoad_freight_ref 	= zeros(nb_regions,size(energyIndexes,2));	// Mtoe / tkm
alpharoad_passenger_ref 	= zeros(nb_regions,size(energyIndexes,2));// Mtoe / pkm

// We don't have the final energy for each mode at calibration year, so we reconstitute these variables from the OT final energy as follows:
for k=1 : nb_regions
    // We assume that 100% of elec consumption in OT at the calibration year is used in railways (note that in China, a significant share of buses has been electrified from 2015 to 2023)
    alpharail_freight_ref (k,indice_elec)	= Qref(k,indice_OT) .* CI_OT_serv(indice_elec,indice_OT,k) .*share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_freight")   ./(share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_passenger") + share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_freight")) ./ EnergyServices_rail_fret(k);
    alpharail_passenger_ref (k,indice_elec)	= Qref(k,indice_OT) .* CI_OT_serv(indice_elec,indice_OT,k) .*share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_passenger") ./(share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_passenger") + share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_freight")) ./ EnergyServices_rail_pass(k);

    // We assume that 100% of coal consumption in OT at the calibration year is for trains
    alpharail_freight_ref (k,indice_coal) 	= Qref(k,indice_OT) .* CI_OT_serv(indice_coal,indice_OT,k) .*share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_freight")   ./(share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_passenger") + share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_freight")) ./ EnergyServices_rail_fret(k);
    alpharail_passenger_ref (k,indice_coal)	= Qref(k,indice_OT) .* CI_OT_serv(indice_coal,indice_OT,k) .*share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_passenger") ./(share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_passenger") + share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_freight")) ./ EnergyServices_rail_pass(k);

    // We assume that 100% of gas consumption in OT is for buses
    alpharoad_passenger_ref (k,indice_gas) 	= Qref(k,indice_OT) .* CI_OT_serv(indice_gas,indice_OT,k)  ./ EnergyServices_road_pass(k); 

    // As there is an epsilon consumption in one region, we assume that 100% of oil consumption in OT is for trucks.
    alpharoad_freight_ref (k,indice_oil) 	= Qref(k,indice_OT) .* CI_OT_serv(indice_oil,indice_OT,k)  ./ EnergyServices_road_fret(k); 

    // For Et, we start from share of Final Energy (all sources) per mode in AR6 data, and we substract the final energy in elec, gas, coal and oil

    alpharail_freight_ref (k,indice_Et) 		= (sum(Qref(k,indice_OT) .* CI_OT_serv(energyIndexes,indice_OT,k) .*share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_freight")) ..  // Total final energy of this mode according to the share of FE
        - Qref(k,indice_OT) .* CI_OT_serv(indice_coal,indice_OT,k) .*share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_freight") ./(share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_passenger") + share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_freight"))  .. // - coal
        - Qref(k,indice_OT) .* CI_OT_serv(indice_elec,indice_OT,k) .*share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_freight") ./(share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_passenger") + share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_freight"))) .. // - elec
    ./ EnergyServices_rail_fret(k);
												
    alpharail_passenger_ref (k,indice_Et) 	= (sum(Qref(k,indice_OT) .* CI_OT_serv(energyIndexes,indice_OT,k) .*share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_passenger")) ..  // Total final energy of this mode according to the share of FE
        - Qref(k,indice_OT) .* CI_OT_serv(indice_coal,indice_OT,k) .*share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_passenger") ./(share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_passenger") + share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_freight"))  .. // - coal
        - Qref(k,indice_OT) .* CI_OT_serv(indice_elec,indice_OT,k) .*share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_passenger") ./(share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_passenger") + share_OT_FinalEnergy_ref(k,label_desag_OT == "rail_freight"))) .. // - elec
    ./ EnergyServices_rail_pass(k);		
												
    alpharoad_freight_ref (k,indice_Et) 		= (sum(Qref(k,indice_OT) .* CI_OT_serv(energyIndexes,indice_OT,k) .*share_OT_FinalEnergy_ref(k,label_desag_OT == "road_freight")) ..   // Total final energy of this mode according to the share of FE
        - Qref(k,indice_OT) .* CI_OT_serv(indice_oil,indice_OT,k)) .. // - oil
    ./ EnergyServices_road_fret(k);
												
    alpharoad_passenger_ref (k,indice_Et) 	= (sum(Qref(k,indice_OT) .* CI_OT_serv(energyIndexes,indice_OT,k) .*share_OT_FinalEnergy_ref(k,label_desag_OT == "road_passenger")) .. // Total final energy of this mode according to the share of FE
        - Qref(k,indice_OT) .* CI_OT_serv(indice_gas,indice_OT,k)) .. // final energy gas for this mode
    ./ EnergyServices_road_pass(k); // the alphas are intensity (Mtoe/pkm)

end

alpharail_freight = alpharail_freight_ref;
alpharail_passenger = alpharail_passenger_ref;
alpharoad_freight = alpharoad_freight_ref;
alpharoad_passenger = alpharoad_passenger_ref;

// NB: we found some very small differences between CI_OT_serv and the CI computed from the new variables (10^-19)
												


// Not in use. Initially I intended to use an asymptote to drive energy efficiency improvement, but for now it seems to be difficult: too much regional variability, a lack of data on the share of pkm, a very low electricity consumption in rail, ...
asymptote_for_energy_efficiency_improvement = 0;
if asymptote_for_energy_efficiency_improvement == 1

    // We define an asymptote for energy efficiency improvement in internal combustion engine for all "OT" modes. Assumption and dynamics inspired by output data from IMAGE 3.3 and REMIND 3.0 in the MIP 3.5 of NAVIGATE.
    asymptote_alpharail_fret = 0.9*L_to_Mtoe/ 100 * 0.8 *10^9; // Source : groupement Allianz pro Schiene, in German context
    asymptote_alpharail_pass = 1.1*L_to_Mtoe/ 100 * 0.8 *10^9; // Source : groupement Allianz pro Schiene, in German context
    asymptote_alpharoad_fret = 3.9*L_to_Mtoe/ 100 * 0.8 *10^9; // Source : groupement Allianz pro Schiene, in German context
    asymptote_alpharoad_pass = 2.5*L_to_Mtoe/ 100 * 0.8 *10^9; // Source: inspired by Schäfer et Yeh, 2020

end

// It should also be noted that we have not specified load factors for all these modes.

 
// We calibrate the initial electrification rate for each mode
indice_FE_electoEt = 3; // Electricity needs ~3 times less final energy to provide the same service.

// We use the share of each energy source in final energy...
OT_elec_share_FE_ref 	= cat(2,alpharail_freight_ref(:,indice_elec)		./ sum(alpharail_freight_ref(:,energyIndexes),'c'), ...
    alpharail_passenger_ref (:,indice_elec)	./ sum(alpharail_passenger_ref(:,energyIndexes),'c'), ...
    alpharoad_freight_ref (:,indice_elec)		./ sum(alpharoad_freight_ref(:,energyIndexes),'c'), ...
alpharoad_passenger_ref (:,indice_elec)	./ sum(alpharoad_passenger_ref(:,energyIndexes),'c'));

OT_Et_share_FE_ref 		= cat(2,alpharail_freight_ref(:,indice_Et)		./ sum(alpharail_freight_ref(:,energyIndexes),'c'), ...
    alpharail_passenger_ref (:,indice_Et)	./ sum(alpharail_passenger_ref(:,energyIndexes),'c'), ...
    alpharoad_freight_ref (:,indice_Et)		./ sum(alpharoad_freight_ref(:,energyIndexes),'c'), ...
alpharoad_passenger_ref (:,indice_Et)	./ sum(alpharoad_passenger_ref(:,energyIndexes),'c'));
								
OT_elec_share_FE 	= OT_elec_share_FE_ref;
OT_Et_share_FE 	= OT_Et_share_FE_ref;

// ... as well as in energy service, considering that we need 3 times less electricity to provide the same level of service 
sum_alpharail_freight 	= sum(alpharail_freight_ref(:,energyIndexes),'c') + alpharail_freight_ref(:,indice_elec)*(indice_FE_electoEt-1);
sum_alpharail_passenger	= sum(alpharail_passenger_ref(:,energyIndexes),'c') + alpharail_passenger_ref(:,indice_elec)*(indice_FE_electoEt-1);
sum_alpharoad_freight 	= sum(alpharoad_freight_ref(:,energyIndexes),'c') + alpharoad_freight_ref(:,indice_elec)*(indice_FE_electoEt-1);
sum_alpharoad_passenger	= sum(alpharoad_passenger_ref(:,energyIndexes),'c') + alpharoad_passenger_ref(:,indice_elec)*(indice_FE_electoEt-1);

OT_elec_share_PE_ref 	= cat(2,alpharail_freight_ref(:,indice_elec)		./ sum_alpharail_freight, ...
    alpharail_passenger_ref (:,indice_elec)	./ sum_alpharail_passenger, ...
    alpharoad_freight_ref (:,indice_elec)		./ sum_alpharoad_freight, ...
    alpharoad_passenger_ref (:,indice_elec)	./ sum_alpharoad_passenger) ...
*indice_FE_electoEt;

OT_Et_share_PE_ref 		= cat(2,alpharail_freight_ref(:,indice_Et)		./ sum_alpharail_freight, ...
    alpharail_passenger_ref (:,indice_Et)	./ sum_alpharail_passenger, ...
    alpharoad_freight_ref (:,indice_Et)		./ sum_alpharoad_freight, ...
alpharoad_passenger_ref (:,indice_Et)	./ sum_alpharoad_passenger);

OT_elec_share_PE 	= OT_elec_share_PE_ref;
OT_Et_share_PE 	= OT_Et_share_PE_ref;


// We calibrate the initial share of LDV in household modal share
share_auto_hsld_ref = (Tautomobileref.*pkmautomobileref) /100 ./ ((Tautomobileref.*pkmautomobileref/100) + EnergyServices_road_pass * 10^9 + EnergyServices_rail_pass * 10^9);
share_auto_hsld = share_auto_hsld_ref;


/////////////////////////Energy efficiency improvement
// Note for OT and air there is a representation of energy efficiency, but no electrification represented
elast_Et_OT=-0.35*ones(nb_regions,1);//price elasticity
asympt_CI_Et_OT=0.3*ones(nb_regions,1);//technical asymptote for minimum liquid fuel use

// Variants of scenarios on energy efficiency improvement assumption, speed of improvement induced by prices 1=fast, 0=slow 
if indice_E==1
    elast_Et_OT=-0.35*ones(nb_regions,1);
elseif indice_E==0
    elast_Et_OT=-0.2*ones(nb_regions,1);
end

// Variants of scenarios on energy efficiency improvement assumption, technical asymptote for minimal energy use 1=high, 0=low 
if indice_A==1
    asympt_CI_Et_OT=0.3*ones(nb_regions,1);
elseif indice_A==0
    asympt_CI_Et_OT=0.25*ones(nb_regions,1);
end


// Variant of scenarios representing optimism on technologies
if indice_tech_OT==1
    elast_Et_OT=-0.4*ones(nb_regions,1);
    asympt_CI_Et_OT=0.2*ones(nb_regions,1);
end


// exogenous substitution rate of petroleum to electric vehicles in Other Transports - if ind_OT_electrification=1 // Semble inutilisé, je commente pour lancer un test du code sans ces lignes.
// OT_Et_elec_substitution = ones(TimeHorizon,1);
// OT_Et_elec_substitution((start_year_strong_policy-base_year_simulation):$,1) = linspace(1,1-0.5,TimeHorizon-(start_year_strong_policy-base_year_simulation)+1)';



//--------------------------------------------------------------------//
// III. Air transportation section                                    //
//--------------------------------------------------------------------//
// This includes domestic air transportation (accounted in transportation), and international air transportation (accounted in bunkers).

// Option implemented for a study dedicated to the aviation sector within NAVIGATE 
if ~isdef("pkmair_inertia_lag")
    pkmair_inertia_lag = 0;
end

// Calibration of DFair_exo, in case the model runs with exogenous pkm for air travels
DFair_exo = Consoref(:,indice_air-nbsecteurenergie);
if exo_pkmair_scenario >0
    pkm_air_all_sc = csvRead(path_AIM_air_demand_sc+'Total_RPK__imaclim_aggregated__RPK_'+sc_exo_air_demand+'.csv','|',[],"string",[],'/\/\//');
    ind_first_row=find(pkm_air_all_sc(:,1)=="USA");
    ind_first_col=find(pkm_air_all_sc(1,:)=="2014");
    pkm_air_all_sc = evstr( pkm_air_all_sc(ind_first_row:$,ind_first_col:$));
    pkm_air_evolution_sc = pkm_air_all_sc(:,2:$) ./ ( pkm_air_all_sc(:,1)*ones( pkm_air_all_sc(1,2:$)));
    CI_air = zeros(nb_regions,1);
    for ii=1:nb_sectors
        //CI_air = CI_air + Qref(:,ii).*matrix(CIref(indice_air,ii,:) .* (partDomCI(indice_air,ii,:)+partImpCI(indice_air,ii,:)),nb_regions,1);
        CI_air = CI_air + Qref(:,ii).*matrix(CIref(indice_air,ii,:),nb_regions,1);
        //CI_air = CI_air + Qref(:,ii).*matrix(CIref(ii,indice_air,:),nb_regions,1);
    end
    pkm_hsld_ref_share = Consoref(:,indice_air-nbsecteurenergie) ./ ( Consoref(:,indice_air-nbsecteurenergie) + DGref(:,indice_air) + DIref(:,indice_air) + sum( Impref .* nit,"c") .*partTIref(1)+CI_air);
    CI_air_ref = CI_air;
    ImpTIref = sum( Impref .* nit,"c") .*partTIref(1);
    pkm_air_increase_lag = ones(nb_regions,1);
end

// Computation of passenger.kilometers for air transport
// Same issue as for land transport
// In addition, we have to calibrate only the air transport that is directly paid by households, business trip do not appear here

// Air transport energy use that can be attributed to households passenger transport.
// Assuming it is proportional to pseudo quantities (ie final demand of household for OT sector), 
// We disregard differences between energy content of local production and importation
Conso_ener_air_pass_ref=zeros(nb_regions,1);
for k=1:nb_regions
    Conso_ener_air_pass_ref(k)=sum(DFref(k,indice_air)*CI(1:nbsecteurenergie,indice_air,k));
end

// Average energy intensity of air transport in Mtoe per pkm
// Value from IEA for 2014 (all commercial passenger aviation) is 13.5 MJ/RTK equivalent (source: https://www.iea.org/data-and-statistics/charts/energy-intensity-of-passenger-aviation-in-the-net-zero-scenario-2000-2030)
// Convention for the conversion between RTK and pkm: RTK = revenue tonne kilometre (one RTK is generated when a metric tonne of revenue load is carried one km). RPK = revenue passenger kilometre (a passenger for whose transportation an air carrier receives commercial remuneration is called a revenue passenger; when a revenue passenger is carried one kilometre, an RPK is generated). RTK equivalent is calculated as the combination of RTK and RPK, considering 90 kg/passenger on average.
EI_air_smp_mtoeperpkm = 2.9E-11;

// Computing pkm consistent with total energy use and energy intensity data
// In that case pkm can be significantly different from data
// but we need to keep energy intensity of modes correct (as in data) so that mode choice and policies make sense
pkmAir_EIsmp=Conso_ener_air_pass_ref./EI_air_smp_mtoeperpkm;

// Updating variable with the recomputed value
pkm_ref(:,ind_hsld_transpAir)=pkmAir_EIsmp;
pkmairref=pkm_ref(:,ind_hsld_transpAir);

// Distinguishing between households pkm and business trip pkm
// exported to datas/pkmair_prive_pro.csv
pkm_ref_private = pkm_ref;

// Share of domestic aviation, derived from ICAO data (year 2014, with different regional disaggregation); only used to unperfectly compute outputs as international and domestic aviations are accounted in different variables
ShareDomAviation_2014 = [0.650104641 0.650104641 0.131217003 0.448218111 0.131217003 0.448218111 0.448218111 0.521719954 0.052078009 0.150066134 0.448218111 0.521719954]'; 

// Energy efficiency in air transport: improvement of 0.7% per year will be considered as the optimistic assumption after 2020. 0.2% the default assumption.
// If we want to change this assumption, here is a potential source: Dray, Lynnette M., Philip Krammer, Khan Doyme, Bojun Wang, Kinan Al Zayat, Aidan O’Sullivan, and Andreas W. Schäfer. 2019. “AIM2015: Validation and Initial Results from an Open-Source Aviation Systems Model.” Transport Policy 79: 93–102. https://doi.org/10.1016/j.tranpol.2019.04.013.
// Another potential source is IEA scenarios
EEI_Et_air = 0.993;



//--------------------------------------------------------------------//
// IV. Shipping section                                               //
//--------------------------------------------------------------------//
// This includes only freight transportation in Imaclim-R.


// Energy efficiency gains from speed reduction (and consequent fleet increase) for shipping - if ind_shipFret_A=1

// The treaty for speed reduction take 18 years to be put in force as described by Faber et al., 2012: https://cedelft.eu/publications/regulated-slow-steaming-in-maritime-transport/
// We assume the shift starts 9 years before. The assumption of 15% energy efficiency due to speed reduction if taken from Faber et al., 2012, consitent with Walsh et al., 2017: https://doi.org/10.1016/j.marpol.2017.04.019
// The assumption of 0.087% related increase in the fleet is also from Faber et al., 2012
efficiency_speed_reducti = ones(TimeHorizon,1);
efficiency_speed_reducti((start_year_strong_policy-base_year_simulation+10):(start_year_strong_policy-base_year_simulation+18),1) = (1-0.15)^(1/9);
// decreasing the ship fleets requires to increase the fleet size
if ind_shipFret_A == 1
    inc_shipFleet_speedRed = ones(TimeHorizon,1);
    inc_shipFleet_speedRed((start_year_strong_policy-base_year_simulation+10):(start_year_strong_policy-base_year_simulation+18),1) = linspace(1,1+0.087,9)';
    inc_shipFleet_speedRed((start_year_strong_policy-base_year_simulation+18):$,1) = inc_shipFleet_speedRed((start_year_strong_policy-base_year_simulation+18),1);
else
    inc_shipFleet_speedRed = ones(TimeHorizon,1);
end

// Energy efficiency in shipping - if ind_shipFret_I=1
// Assumption taken from the NAVIGATE T3.5 protocol
new_ships_efficiency = 0.985; // should apply to new ships only, but we currently assumes it applies to the whole fleets
operation_fleet_efficien = 0.989; // apply to the whole fleet

//////////////////////////
// Hydrogen technology in shipping. The ammonia vector is favoured because it is considered the most credible in the literature (rather than CH2 or LH2).

// Parameters assumptions (the same for all regions)
capex_hdr_ship_ini = 1400; //1400 $/KW. Cost of capital to produce H2 by electrolysis, and to convert it to NH3. This is the upper value for electrolysis in "The Future of Hydrogen" (table 3, IEA, 2019); we assume this value covers also the capital cost of ammonia production, following the note in Fig.22 ("then for ammonia production from electrolytic hydrogen, the synthesis process and the air separation unit account for less than 5% of the total CAPEX"). Note that Figure 22 also provides an alternative estimation of total capital cost for production of NH3 from electrolysis, apparently not fully consistent with our assumption. Operation costs (OPEX) seem to be much lower (Figure 22).
capex_hdr_ship_fin = 400; // medium long-term value in "The Future of Hydrogen" (IEA, 2019)
capex_hdr_ship_fin = 700; // medium long-term value in "The Future of Hydrogen" (IEA, 2019)
load_hdr_ship = 6000; //number of operating hours of capital, inspired by the same source (IEA, 2019)
conv_electoNH3 = 0.55; // energy conversion factor; inspired by figure 20 of (IEA, 2019), but also multiple sources considering a ~30% loss from elec to H2, and ~30% from H2 to NH3; we assume this value to be constant over time

ratio_ener_ship = 1.2; // ratio of energy consumption, NH3 motorisation versus fuel oil vessel; computed and derived from Kim et al, 2020 - 10.3390/jmse8030183 
ratio_capital_ship_ini = 3; // assumed equipment cost at the initial year for NH3 motorisation versus fuel oil vessel; computed and derived from Kim et al, 2020 - 10.3390/jmse8030183  ; they assume a [1.1 - 3] range for NH3 technologies)
ratio_capital_ship_final = 1.1; // see above
share_capcost_ET_ship = 0.1; // share of capital cost in cumulative cost with conventional heavy fuel oil, according to Kim et al, 2020
// Parameters of the logit function

elast_shipping=4;
weight_logit_shipping=1;

// Initialisation
// Share in the shipping fleet
lifetime_vessel = 25 ; // common value that we can find in the litterature
nb_techno_shipping = 2; // we consider liquids and hydrogen
ind_tech_ship_LIQ = 1;
ind_tech_ship_HDR = 2;
shipping_fleet_int = zeros(nb_regions, nb_techno_shipping,lifetime_vessel); // Initiatialisation of the fleet, we assume that the size of each generation is the same at the initial year (it could be easy to find data to improve this)
for i=1:nb_regions
    shipping_fleet_int(i,1,:) = Capref(i,indice_mer) / lifetime_vessel;
end
shipping_fleet_int(:,ind_tech_ship_HDR,:) = 0 ; // we initialize the share of hydrogen to 0 for the existing fleet
new_fleet_shipping = ones(nb_regions,nb_techno_shipping) ;
shareHYD_ship = zeros(nb_regions,1);
shareLIQ_ship = ones(nb_regions,1);
FE_shipping_HYD = zeros(nb_regions,1);


//--------------------------------------------------------------------//
// V. Transportation infrastructures and speed of modes               //
//--------------------------------------------------------------------//
// This calibration section is dedicated to the dynamics of change in infrastructure, influencing congestion and speed of the transportation modes (so in fine the modal share). Following the changes made to the nexus, this section would benefit from a session to check the dynamics, carry out sensitivity analyses and (if necessary) update the parameters.

// Calibration of marginal travel time curves ti(Ti), representing congestion (marginal speed is reduced when utilization rate of the infrastructure increases)

// Marginal efficiency of travelling-time (inverse of the marginal time used to travel one more km)
// No source for data. Inverse of average marginal speed if absolutely no congestion (utilisation rate of transport infrastructure=0). No actual data but assumptions.
marginal_eff_travelTime = [1/700; 1/50; 1/80; 0.2];
// 80% decrease of marginal efficiency if we are at full capacity (ti(1))
decrease_ti_fullCapacity = 0.8;


// Assumption on base year utilization rate of transport capacities (pkm/Capacicites)
URtransportref = 0.5 * ones(nb_regions, nb_trans_mode_hsld - 1);

// Inverse of marginal speed for the utilization rate at date 0 ti(Tiref/Captransportref)
// No actual data but assumptions. Note that the marginal speed at date 0 should be slower than the marginal speed for zero utilisation rate of infrastructure
tairrefo = 1/600 * ones(nb_regions,1);
tOTrefo = 1/25 * ones(nb_regions,1);
tautorefo= 1/45 * ones(nb_regions,1);

// Inverse of marginal speed if utilisation rate is zero ti(0)
toair = marginal_eff_travelTime(ind_hsld_transpAir) * ones(nb_regions,1);
toOT = marginal_eff_travelTime(ind_hsld_transpOT) * ones(nb_regions,1);
toautomobile = marginal_eff_travelTime(ind_hsld_transpCar) * ones(nb_regions,1);
toNM = marginal_eff_travelTime(ind_hsld_transpNM) * ones(nb_regions,1);

// Conversion base 100/pkm
alphaair = 100 * pkm_ref_private(:,ind_hsld_transpAir) ./ (DFref(:,indice_air).*pkmautomobileref);
alphaOT = 100 * pkm_ref_private(:,ind_hsld_transpOT) ./(DFref(:,indice_OT).*pkmautomobileref);

// Calibration of parameters of the function representing congestion of infrastructure (marginal speed as a function of utilization rate)
btrans=ones(nb_regions,nb_trans_mode_hsld - 1);
atrans = -ones(nb_regions,nb_trans_mode_hsld - 1) + (1-decrease_ti_fullCapacity) * ( ones(nb_regions,1) * (1 ./marginal_eff_travelTime(ind_hsld_transpAir:ind_hsld_transpCar)'));

ktrans=zeros(nb_regions,nb_trans_mode_hsld - 1);
ktrans(:,ind_hsld_transpAir)=log(( -btrans(:,ind_hsld_transpAir) + tairrefo./toair)./( atrans(:,ind_hsld_transpAir)))./log(URtransportref(:,ind_hsld_transpAir));
ktrans(:,ind_hsld_transpOT)=log(( -btrans(:,ind_hsld_transpOT) + tOTrefo./toOT)./( atrans(:,ind_hsld_transpOT)))./log(URtransportref(:,ind_hsld_transpOT));
ktrans(:,ind_hsld_transpCar)=log(( -btrans(:,ind_hsld_transpCar) + tautorefo./toautomobile)./( atrans(:,ind_hsld_transpCar)))./log(URtransportref(:,ind_hsld_transpCar));

// Share of contruction good in investment that correspond to public transport infrastructure
share_infra_constru_Inv = 0.2 * ones( nb_regions,1);// The average investment in public transport infrastructure corresponds to about 20% in most regions, but vary a little per region and year. We prefer to take the average value here, to avoid taking specific year data that can be not representative of the average. See for data sources: Fisch-Romito, Vivien, and Céline Guivarch. 2019. “Transportation Infrastructures in a Low Carbon World: An Evaluation of Investment Needs and Their Determinants.” Transportation Research Part D: Transport and Environment 72 (July): 203–19. https://doi.org/10.1016/j.trd.2019.04.014.

// Add-hoc maximum share of spendings in DIinfra over total NRB
max_share_DIinfra_NRB = 0.5;
// GDP / cap threshold for investment in infrastructure
max_GDPcap_DIinfra = 0.08;

// Calibration of transport infrastructures capacities at year 0
Captransport = pkm_ref_private ./ URtransportref;
Captransportref = Captransport;

// Computation of non motorized transport as the residual
// Be careful here that it doesn't become negative. As pkm of other modes are calibrated from energy and energy efficiency data, and speed are taken as average order of magnitudes, it could happen for some regions that the total time in the three motorized modes is higher than the total 1.1 hour per day calibrated.
pkmNMref=(Tdisp-(Itair(Consoref)+ItOT(Consoref)+Itautomobile(Tautomobileref)))./toNM;
// base 100
TNMref=100*pkmNMref./pkmautomobileref;

// Setting basic needs for air and other transport to the share of initial consumption
bnOT = bnOT_share_Cons .* Consoref(:,indice_OT-nbsecteurenergie);
bnair = bnair_share_Cons .* Consoref(:,indice_air-nbsecteurenergie);

// Composite goods consumption linked to car use (per pkm)
alphaCompositeautoref=shCompoEntretienAuto.*DFref(:,indice_composite)./pkmautomobileref;
alphaCompositeauto=alphaCompositeautoref;

// Investment in transport infrastructure (share of construction used for gross fixed capital formation that is not increasing productive sectors capacities)
DIinfraref=zeros(nb_regions,nb_sectors);
DIinfraref(:,indice_construction) = share_infra_constru_Inv .* DIref(:,indice_construction);


// Parameters used in the case of "transport infrastructure policies" variant
// Capacity objective for road (cars) and for airtransport (airports) when infrastructure expansion does not follow demand and is restricted
Objective_CapAir=2000; // targeted capacity for air transport (in pkm/person/year)
Objective_CapRoadsCars=7000*pkmAll_to_pkmHousehold;//targeted capacity for roads/cars (in pkm/person/year)

// Time horizon for reaching the long-term target of Car transport capacities (i-e, road)
// Parameter used in some variants representing policies targetting transport infrastructures, in which infrastructure expansion does not follow demand (eg not aiming to avoid congestion) but targets a specified capacity (defined as a number of kilometers per person per year)
timehorizon_LT_CapTrans = 40;




/////////////////////////////////////////////////////////
// Saving values of pkm as recomputed from energy data (total and unitary), to compare with actual pkm data

mksav(["pkmautomobileref" "pkmairref" "pkmOTref" "pkmNMref"]);
