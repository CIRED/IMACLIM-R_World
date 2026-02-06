// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////POPULATION////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////
/// Total population growth
//////////////////////////////////////////////////////

// Year after which exogenous trends diverge according to SSPs (must be after the calibration year of txCapTemp)
// Total population trajectory
Ltot_trajectory= csvRead(path_growthdrivers_Ltot+'total_population_trajectory__ssp_2023__' + 'SSP' + ind_pop + '.csv','|',[],[],[],'/\/\//');
Ltot_header = Ltot_trajectory(1,:);
ind_first_year = find(Ltot_header == base_year_simulation);
//Ltot_prev = 1000*Ltot_trajectory(2:$, ind_first_year-1);
Ltot_trajectory = 1000*Ltot_trajectory(2:$, ind_first_year:$);

// First years until must correspond to SSP2
Ltot_trajectory_ssp2 = csvRead(path_growthdrivers_Ltot+'total_population_trajectory__ssp_2023__' + 'SSP2.csv','|',[],[],[],'/\/\//');
Ltot_trajectory(:,1:start_year_policy+1 -base_year_simulation) = 1000*Ltot_trajectory_ssp2(2:$, ind_first_year:ind_first_year+start_year_policy+1 -base_year_simulation-1);

// Initialisation of total population variable
Ltot0 = Ltot_trajectory(:,1);
Ltot = Ltot0;

///////////////////////////////////////////////////////
/// Active population growth
//////////////////////////////////////////////////////

// Active population in 2001 (source: calculated from UNO world population prospects 2019, unit: thousands)
Lact0 = 1000 * csvRead(path_growthdrivers_Ltot + 'active_population__range15-63__' + string(base_year_simulation) + '.csv','|',[],[],[],'/\/\//');

// Active population growth rate
// We use the old SSP data, active population to total population ratio 
// active population fromm SSP update provided by Kolch and Leimbach could be computed from sources:
//Wittgenstein Center ("K. C., S, 2020. Updated demographic SSP4 and SSP5 scenarios complementing the SSP1–3 scenarios published in 2018 [WWW Document] doi:10/1/WP-20-016.pdf" and "Lutz, W., Goujon, A., KC, S, Stonawski, M., Stilianakis, N., 2018. Demographic and Human Capital Scenarios for the 21st Century: 2018 Asses")
// From the SSP corresponding to the scenario
txLact = csvRead(path_growthdrivers_Lact+'active_population_growth_rate__ssp_2023__'+'SSP' + ind_pop + '__range15-63.csv','|',[],[],[],'/\/\//');
txLact_header = txLact(1,:);
ind_first_year = find(txLact_header == base_year_simulation);
txLact = txLact(2:$, (ind_first_year+1):$);
txLact_ssp2 = csvRead(path_growthdrivers_Lact+'active_population_growth_rate__ssp_2023__'+'SSP2__range15-63.csv','|',[],[],[],'/\/\//');
txLact(:,1:start_year_policy+1 -base_year_simulation)=txLact_ssp2(2:$, (ind_first_year+1):ind_first_year+start_year_policy+1 -base_year_simulation);
// Initialization of active population variable
L = Lact0;
