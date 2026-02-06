// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Thomas Le Gallic, Yann Gaucher, Céline Guivarch
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////LABOR PRODUCTIVITY/////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////
/////GDP calibration
//////////////////////////////////////////////////////

//To remove if we decide to keep the absolute values of our GDP resulting from GTAP data and the hybridization procedure

// These lines calibrate initial GDPs (both MER and PPP)
GDP_IMF_PPA         = csvread(path_GDP_PPP1+"GDP_IMF_PPA.csv"); // in $2001

world_bank_data=csvRead(path_world_bank+"world_bank_data_"+string(base_year_simulation)+".csv",'|',[],"string",[],'/\/\//');
icol_gdpmer=find(world_bank_data(1,:)=="GDP (current US$)");
icol_gdpppp=find(world_bank_data(1,:)=="GDP, PPP (current international $)");

GDP_MER_WB=zeros(nb_regions);
GDP_PPP_WB=zeros(nb_regions);
for ireg=1:nb_regions
    GDP_MER_WB(ireg) = evstr(world_bank_data( find(world_bank_data(:,1)==regnames(ireg)), icol_gdpmer)) *1e-6;
    GDP_PPP_WB(ireg) = evstr(world_bank_data( find(world_bank_data(:,1)==regnames(ireg)), icol_gdpppp)) *1e-6;
end

//////////////////////////////////////////////////////////////////////
/// computing labor productivity growth rates with a convergence formula
/// defining the parameters of the convergence
//////////////////////////////////////////////////////////////////////

//grouping regions in three income groups: low income (li), middle income (mi) et high income (hi)
reg_li=zeros(nb_regions,1);
reg_mi=zeros(nb_regions,1);
reg_hi=zeros(nb_regions,1);

reg_hi(ind_high_income)=1;
reg_mi(ind_middle_income)=1;
reg_li(ind_low_income)=1;

select indice_TC_l_exo //Exogenous trends of labor productivity growth for Post-Growth and Convergence scenarios
case 1  
    TC_l_exo=csvRead(path_autocal_exo_prod+'prod_SSP2_2100.csv','|',[],[],[],'/\/\//');
case 3
    TC_l_exo=csvRead(path_autocal_exo_prod+'prod_convergence_2100.csv','|',[],[],[],'/\/\//');
case 7
    TC_l_exo=csvRead(path_autocal_exo_prod+'prod_PostGrowth_V2_2100.csv','|',[],[],[],'/\/\//'); 
else // indice_TC_l_exo == 0 - usual version with endogenous TC_l
    //short-term parameter
    //by default, no variant on that parameter, same for all regions and all scenarios
    tau_l_1=zeros(nb_regions,1);
    tau_l_1_li=30;
    tau_l_1_mi=30;
    tau_l_1_hi=30;
    tau_l_1=tau_l_1_li*reg_li+tau_l_1_mi*reg_mi+tau_l_1_hi*reg_hi;
    tau_l_1_ssp2 = tau_l_1;
 
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
    tau_l_2_ssp2 = 500*reg_li+300*reg_mi+200*reg_hi; //in SSP2 ind_productivity_mi,hi,& li = 2
    //exogenous trend of the leader productivity growth
    TC_l_max_ssp2=csvRead(path_growthdrivers_TC_l4+'TC_l_max.ind_prod_leader=2.csv','|',[],[],[],'/\/\//');
    TC_l_max=csvRead(path_growthdrivers_TC_l4+'TC_l_max.ind_prod_leader='+ind_productivity_leader+'.csv','|',[],[],[],'/\/\//');
    //exogenous trajectories are starting from 2001 (calibrated with previous version of the model such that resulting GDP is similar to corresponding SSP), so we keep only the growth rates starting from starting year of simulation
    TC_l_max=TC_l_max*cor_prod_leader_calib; // calibration: TC_l_max correction to reach SSPs target in 2100
    if ind_navigateWP3 == 1
        TC_l_max=[TC_l_max(:,base_year_simulation-2000:start_year_policy-2001) 0.6*TC_l_max(:,start_year_policy-2000:TimeHorizon+base_year_simulation-2001)]; //NAVIGATE task 3.5 MIP: adjustment to lower a bit the US growth (and all regional growths). Not for the first years as we meet a bug.
        TC_l_max_ssp2=[TC_l_max_ssp2(:,base_year_simulation-2000:start_year_policy-2001) 0.6*TC_l_max_ssp2(:,start_year_policy-2000:TimeHorizon+base_year_simulation-2001)]; //NAVIGATE task 3.5 MIP: adjustment to lower a bit the US growth (and all regional growths). Not for the first years as we meet a bug.

    else
        TC_l_max=TC_l_max(:,base_year_simulation-2000:TimeHorizon+base_year_simulation-2001);
        TC_l_max_ssp2=TC_l_max_ssp2(:,base_year_simulation-2000:TimeHorizon+base_year_simulation-2001);

    end	

    world_bank_data19=csvRead(path_world_bank+"world_bank_data_2019.csv",'|',[],"string",[],'/\/\//');
    world_bank_data14=csvRead(path_world_bank+"world_bank_data_2014.csv",'|',[],"string",[],'/\/\//');
    icol_gdpmer=find(world_bank_data19(1,:)=="GDP (current US$)");
    icol_gdpppp=find(world_bank_data14(1,:)=="GDP, PPP (current international $)");

    GDP_PPP_WB_2019=zeros(nb_regions);
    GDP_PPP_WB_2014=zeros(nb_regions);
    for ireg=1:nb_regions
        GDP_PPP_WB_2019(ireg) = evstr(world_bank_data19( find(world_bank_data19(:,1)==regnames(ireg)), icol_gdpppp)) *1e-6*CPI_2019_to_2014;
        GDP_PPP_WB_2014(ireg) = evstr(world_bank_data14( find(world_bank_data14(:,1)==regnames(ireg)), icol_gdpppp)) *1e-6;
    end


    //initial growth rate, that influences also growth in the short term: maybe it could be SSP2 for all SSPs to avoid "jump" in TC_l. 
    TC_l_ref=csvRead(path_growthdrivers_TC_l4+'TC_l_ref.ind_prod_st='+ind_productivity_st+'.csv','|',[],[],[],'/\/\//');//12x1
    //keep initial growth rate consistent with the txCapTemp calibration for the first years
    TC_l_ref_ssp2=csvRead(path_growthdrivers_TC_l4+'TC_l_ref.ind_prod_st=1.csv','|',[],[],[],'/\/\//');
    TC_l_ref(ind_usa)=TC_l_max(1);

end

if auto_calibration_ssp
    exec(MODEL+"calibration.ssp.laborProductivity.sce");
    break;
elseif isdef("ind_ssp_prod")
    if isfile(path_autocal_SSP + "res_all_reg_ssp"+string(ind_ssp_prod)+".csv")
        res_all_reg = csvRead(path_autocal_SSP + "res_all_reg_ssp"+string(ind_ssp_prod)+".csv",'|',[],[],[],'/\/\//')
        TC_l_ref = res_all_reg(:,1);
        tau_l_1 = res_all_reg(:,2);
        tau_l_2 = res_all_reg(:,3);
        TClmax_firstyear_leader =  csvRead(path_autocal_SSP + "TCLmax_firstyear_leader_ssp"+string(ind_ssp_prod)+".csv",'|',[],[],[],'/\/\//')
        TC_l_max = linspace(TClmax_firstyear_leader, TClmax_firstyear_leader-0.01, TimeHorizon+1);
        TC_l_ref(ind_usa)=TC_l_max(1);
    end
end    

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

