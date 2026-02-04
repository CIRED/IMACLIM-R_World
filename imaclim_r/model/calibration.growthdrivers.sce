// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thomas Le-Gallic, Nicolas Graves, Céline Guivarch, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////POPULATION////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////
/// Total population growth
//////////////////////////////////////////////////////

// Total population trajectory
Ltot_trajectory = csvRead(path_growthdrivers_Ltot+'total_population_trajectory_' + 'SSP' + ind_pop + '.csv','|',[],[],[],'/\/\//');
Ltot_header = Ltot_trajectory(1,:);
ind_first_year = find(Ltot_header == base_year_simulation);
//Ltot_prev = 1000*Ltot_trajectory(2:$, ind_first_year-1);
Ltot_trajectory = 1000*Ltot_trajectory(2:$, ind_first_year:$);
// Initialisation of total population variable
Ltot0 = Ltot_trajectory(:,1);
Ltot = Ltot0;

///////////////////////////////////////////////////////
/// Active population growth
//////////////////////////////////////////////////////

// Active population in 2001 (source: calculated from UNO world population prospects 2019, unit: thousands)
Lact0 = 1000 * csvRead(path_growthdrivers_Ltot + 'active_population_' + string(base_year_simulation) + '.csv','|',[],[],[],'/\/\//');

// Active population growth rate
// We use the old SSP data, active population to total population ratio 
// active population fromm SSP update provided by Kolch and Leimbach could be computed from sources:
//Wittgenstein Center ("K. C., S, 2020. Updated demographic SSP4 and SSP5 scenarios complementing the SSP1–3 scenarios published in 2018 [WWW Document] doi:10/1/WP-20-016.pdf" and "Lutz, W., Goujon, A., KC, S, Stonawski, M., Stilianakis, N., 2018. Demographic and Human Capital Scenarios for the 21st Century: 2018 Asses")
// From the SSP corresponding to the scenario
txLact = csvRead(path_growthdrivers_Lact+'SSP' + ind_pop + '_ActivePop.tsv','\t',[],[],[],'/\/\//');
//SSP trajectories are starting from 2001, so we keep only the growth rates starting from starting year of simulation
txLact=txLact(:,base_year_simulation-2000:TimeHorizon+base_year_simulation-2001);

txLtot_oldSSP = csvRead(path_growthdrivers_Ltot_old+'SSP' + ind_pop +'_v9_TotalPOP.tsv','\t',[],[],[],'/\/\//');
//SSP trajectories are starting from 2001, so we keep only the growth rates starting from starting year of simulation
txLtot_oldSSP = txLtot_oldSSP(:,base_year_simulation-2000:TimeHorizon+base_year_simulation-2001);
txLtot = Ltot_trajectory(:,2:$) ./ Ltot_trajectory(:,1:$-1)-1;
txLact = (1+txLact) ./ (1+txLtot_oldSSP) .* (1+txLtot) - 1 ;

// Initialization of active population variable
L = Lact0;


///////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////LABOR PRODUCTIVITY/////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////
/// computing labor productivity growth rates with a convergence formula
/// defining the parameters of the convergence
//////////////////////////////////////////////////////////////////////

//grouping regions in three income groups: low income (li), middle income (mi) et high income (hi)
reg_li=zeros(nb_regions,1);
reg_mi=zeros(nb_regions,1);
reg_hi=zeros(nb_regions,1);

reg_hi(1:ind_cis)=ones(5,1);
reg_mi(ind_chn)=1;
reg_li(ind_ind)=1;
reg_mi(ind_bra)=1;
reg_li(ind_mde:$)=ones(nb_regions-ind_mde+1,1);

//short-term parameter
//by default, no variant on that parameter, same for all regions and all scenarios
tau_l_1=zeros(nb_regions,1);
tau_l_1_li=30;
tau_l_1_mi=30;
tau_l_1_hi=30;

tau_l_1=tau_l_1_li*reg_li+tau_l_1_mi*reg_mi+tau_l_1_hi*reg_hi;

//parameter representing the speed of convergence towards the leader
tau_l_2=zeros(nb_regions,1);


select ind_productivity_li
case 1
    tau_l_2_li=400;
case 2
	if ind_navigateWP3 == 1
		tau_l_2_li=600; // Fine tuning to be a bit slower in the NAVIGATE task 3.5 MIP
	else
		tau_l_2_li=500;
	end	
case 3
    tau_l_2_li=800;
end

select ind_productivity_mi
case 1
    tau_l_2_mi=200;
case 2
    tau_l_2_mi=300;
case 3
    tau_l_2_mi=500;
end

select ind_productivity_hi
case 1
    tau_l_2_hi=150;
case 2
    tau_l_2_hi=200;
case 3
    tau_l_2_hi=300;
end
tau_l_2=tau_l_2_li*reg_li+tau_l_2_mi*reg_mi+tau_l_2_hi*reg_hi;


//exogenous trend of the leader productivity growth
TC_l_max=csvRead(path_growthdrivers_TC_l4+'TC_l_max.ind_prod_leader='+ind_productivity_leader+'.csv','|',[],[],[],'/\/\//');
//exogenous trajectories are starting from 2001 (calibrated with previous version of the model such that resulting GDP is similar to corresponding SSP), so we keep only the growth rates starting from starting year of simulation
if ind_navigateWP3 == 1
	TC_l_max=[TC_l_max(:,base_year_simulation-2000:start_year_policy-2001) 0.6*TC_l_max(:,start_year_policy-2000:TimeHorizon+base_year_simulation-2001)]; //NAVIGATE task 3.5 MIP: adjustment to lower a bit the US growth (and all regional growths). Not for the first years as we meet a bug.
else
	TC_l_max=TC_l_max(:,base_year_simulation-2000:TimeHorizon+base_year_simulation-2001);
end	


//initial growth rate, that influences also growth in the short term
TC_l_ref=csvRead(path_growthdrivers_TC_l4+'TC_l_ref.ind_prod_st='+ind_productivity_st+'.csv','|',[],[],[],'/\/\//');


TC_l_ref(ind_usa)=TC_l_max(ind_usa);

sg_add("TC_l");

if indice_TC_l_endo==1
    ldsav( 'cum_Cap_sect_REF.sav','calib');
    ldsav( 'cum_Inv_sect_REF.sav','calib');
    ldsav( 'l_sav_REF.sav','calib');
    cum_Cap_sect=zeros(reg*sec,1);
    cum_Inv_sect=zeros(reg*sec,1);
    TC_l_temp=TC_l(:,1)*ones(1,sec);
end


//////////////////////////////////////////////////////
/////Misc
//////////////////////////////////////////////////////

//Region areas in km2
superficie=csvRead(path_areas+"areas.csv",'|',[],[],[],'/\/\//');



//////////////////////////////////////////////////////
/////GDP calibration
//////////////////////////////////////////////////////

//To remove if we decide to keep the absolute values of our GDP resulting from GTAP data and the hybridization procedure

// These lines calibrate initial GDPs (both MER and PPP)
GDP_IMF_PPA         = csvread(path_GDP_PPP1+"GDP_IMF_PPA.csv"); // in $2001

world_bank_data=read_csv_file(path_world_bank+"world_bank_data_"+string(base_year_simulation)+".csv",'|');
icol_gdpmer=find(world_bank_data(1,:)=="GDP (current US$)");
icol_gdpppp=find(world_bank_data(1,:)=="GDP, PPP (current international $)");

GDP_MER_WB=zeros(nb_regions);
GDP_PPP_WB=zeros(nb_regions);
for ireg=1:nb_regions
    GDP_MER_WB(ireg) = eval(world_bank_data( find(world_bank_data(:,1)==regnames(ireg)), icol_gdpmer)) *1e-6;
    GDP_PPP_WB(ireg) = eval(world_bank_data( find(world_bank_data(:,1)==regnames(ireg)), icol_gdpppp)) *1e-6;
end

