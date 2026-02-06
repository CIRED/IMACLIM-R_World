// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thibault Briera, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////****************         Growth drivers             *******************/////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

select ind_ssp_prod
    // labor productivity growth and population growth of ssp
case 1
    ind_productivity=2;//medium growth for high income countries
    ind_productivity_st=1;//medium growth in the short term
    ind_catchup=1;//fast speed of catch up
case 2
    ind_productivity=2;//medium growth for high income countries
    ind_productivity_st=1;//medium growth in the short term
    ind_catchup=2;//medium speed of catch up
case 3
    ind_productivity=3;//slow growth for high income countries
    ind_productivity_st=2;//slow growth in the short term
    ind_catchup=3;//slow speed of catch up          
case 4
    ind_productivity=2;//medium growth for high income countries
    ind_productivity_st=1;//medium growth in the short term
    ind_catchup=3;//slow speed of catch up
case 5
    ind_productivity=1;//fast growth for high income countries
    ind_productivity_st=0;//fast growth in the short term
    ind_catchup=1;//fast speed of catch up          
end


ind_productivity_leader=ind_productivity;//exogenous trend over time of labor productivity growth in leading country (USA)
ind_productivity_li=ind_catchup;
ind_productivity_mi=ind_catchup;
ind_productivity_hi=ind_productivity;

ind_pop=ind_ssp_pop;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////*********************         Savings         *************************/////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

select ind_savings //here the
case 1
    SavingsShift=20; // increase saving rates in 2100 by 20% in each region        
case 2
    SavingsShift=0; // keep savings as in SSP2 (default case)
case 3
    SavingsShift=-20 // reduce saving rates by 20% in 2100
end    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////****************         Financial capital markets     *******************//////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// if ind_ssp_fin is defined, capital markets follow the ssp storyline
// Otherwise capital markets are defined by ind_K
// ind_ssp_fin should not be defined in default_parameters.sce

if isdef("ind_ssp_fin") // Internationa Financial capital market closure depending on SSP
    if ind_ssp_fin==1
        ind_partExpK=1;
        ind_IntFin=1;
    elseif ind_ssp_fin==2
        ind_partExpK=1;
        ind_IntFin=0;
    elseif ind_ssp_fin==3
        ind_IntFin=0;
        ind_partExpK=0;
        begin_rebalance_K = start_year_strong_policy - base_year_simulation;
    end
else
    ind_IntFin=0;
    ind_partExpK = ind_K; // trade balance evolution
end

// indices for dealing with capital markets (nexus.finance.sce)
begin_coop_K = start_year_strong_policy - base_year_simulation;
if ~isdef("begin_rebalance_K")
    if ind_K == 3
        begin_rebalance_K = begin_coop_K + 15 ; // start date to re-balance local capital markets
    else
        begin_rebalance_K = 1;
    end
end

//////////////////////////////////////////////////////////////////////////////
//    4/ EXOGENOUS EMISSIONS PART
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// CO2 market parameter NOT TO BE CHANGED

//////////////////////////////////////////////////////////////////////////////
//  *USER CHOICE* CO2 market OPTIONS
//  USER, READ THIS
//
// *Please fill the MKT_ variables as a function of combi
// (in our case, ind_climat is a function of combi, see first line of this sheet,
// you probably want to act similarly. Find out in savedir_lib how, looking for combi2indices)
// *Note that MKT_ variables are used as paremeters of the new_lin_dlog function
// new_lin_dlog function is nicelly DOCUMENTED in ANALYSIS_FUNCTION.sci
// *Never forget other ways of defining an emissions' objective are possible
//////////////////////////////////////////////////////////////////////////////



// case ind_lindhal=1, regional carbon prices and convergence
convergence_regional_tax = ones(TimeHorizon,1);
convergence_regional_tax(start_year_policy-base_year_simulation:year_convergence_reg_tax-base_year_simulation) = linspace(0,1,year_convergence_reg_tax-start_year_policy+1)';

/////// Market definition
// By defaut, nbMKT = 1 -> world carbon price. 

if ~isdef("nbMKT")
    nbMKT = 1; // when not using NPi/NDC
end
// New NPi/NDC design: we run the baseline scenario with the same market structure as the NPi/NDc scenarios
// Nb of markets in NPi/NDC
// if running NPi/NDC (including calibration), nbMKT_NDC is defined and nbMKT forced, such that 
if (ind_climat == 1) | (ind_climat == 2) | (ind_climat == 99)

    // available market coverage for NPi/NDC, as of 10 of October, 2023, in market order

    // 1: world
    // 4: ASIA, LAM, ROW, OECD
    // 7: OECD, REF, CHN, IND, LAM, MAF, ASIA
    // 9: USA, OECD, EUR, REF, CHN, IND, LAM, MAF, ASIA

    if ~isdef("nbMKT_NDC") //warning: must be consistent with the NPi/NDC calibration
        nbMKT_NDC = 1;
    end

    nbMKT=nbMKT_NDC;
end

is_quota_MKT = falses(nbMKT,1);
is_taxexo_MKT = trues(nbMKT,1);
whichMKT_reg_use = ones(reg,nb_use); //here everything is in the market 1. Use this to control global emissions.
MKT_start_year = %nan*ones(nbMKT,1);
taxMKTexo = zeros(nbMKT,TimeHorizon+1);

//NPi/NDC duration
duration_NDC = 2030 - 2020;

// a more versatile way to call either NDC/NPi to avoid copy/paste
if (ind_climat == 1 | ind_climat == 2| ind_climat == 11 |ind_climat == 12) | ind_climpol_uncer==1// ind_climat 11 & 12 require also NPi and NDC )
    

    whichMKT_reg_use = whichMKT_NPi_NDC(nbMKT);

    //prevent from running the model with a wrong market structure. This should not happen if nbMKT = nbMKT_NDC
    if max(whichMKT_reg_use) <> nbMKT
        error("whichMKT_reg_use is ill-defined due to an error in the definition of the markets");
    end

    
    is_quota_MKT = falses(nbMKT,1);
    is_taxexo_MKT = trues(nbMKT,1);


    start_tax = start_year_policy - base_year_simulation+1;

    // getting back the tax trajectories from the calibratde NDC/NPi scenarios
    // we need to run the baseline scenario with the same market structure as the NPi/NDc scenarios, to immediately get 2020 CO2 emissions.
    //warning: check this if the combis for NPi and NDC change
    select ind_climat
        // defaut combi # to load the calibrated carbon tax trajectories. This can be overrided by the user (directly in the shell script) to change some indices in the baseline run.
    case 1
        tax_NPi_NDC_path = path_autocal_tax + "NPi" + sep;
    case 2
        tax_NPi_NDC_path = path_autocal_tax + "NDC" + sep;
    case 4
        tax_NPi_NDC_path = path_autocal_tax + "NPi" + sep;
    case 7
        tax_NPi_NDC_path = path_autocal_tax + "NPi" + sep;
    case 11 
        tax_NPi_NDC_path = path_autocal_tax + "NPi" + sep;
    case 12 
        tax_NPi_NDC_path = path_autocal_tax + "NPi" + sep;

    end
    try
        load(tax_NPi_NDC_path + "taxMKT_sav.dat");
    catch 
        disp("Error: the NDC/NPi scenario has not been run yet. Please check that the calibration run is complete and correspond to the desire baseline (either NPi or NDC) or run both with the shell script.")
    end


    //Check that the NPi/NDC calibration fit the market structure given by nbMKT_NDC
    if nbMKT_NDC <> size(taxMKT_sav,1)
        error("The NPi/NDC calibration does not fit the market structure given by nbMKT_NDC. Please rerun the shell script batch/NPi_NDC.sh with a consistent nbMKT_NDC value.")
    end


    load(tax_NPi_NDC_path + "TC_l_sav.dat");
    load(tax_NPi_NDC_path + "GDP_PPP_constant_sav.dat");

    // ind_npi_ndc_effort gives the different options for defining the "continuation of effort" after 2030
    // 0. Constant tax after 2030
    // 1. COMMIT-BRIDGE: the tax grows at the natural growth rate of GDP per capita (https://doi.org/10.1038/s41467-021-26595-z)
    // incoming:
    // 2. Van de Ven et al: the tax grows to maintain the 2020-2030 rate of decrease in emission intensity of GDP (https://doi.org/10.1038/s41558-023-01661-0)

    temp = zeros(nbMKT,TimeHorizon+1);
    // Requires first to compute a weighted average of GDP growth rates per market

    for s=1:nbMKT
        temp= taxMKT_sav;
    end
    temp(:,start_tax+duration_NDC) = max(taxMKT_sav(:,start_tax+duration_NDC),1e-6); // if the tax in NDC/NPi is 0 in 2030, then set it to 1
    
    efforts_30 = zeros(nbMKT,1);
    select  ind_npi_ndc_effort
    case 0
        for s=1:nbMKT
            index_mkt = find(whichMKT_reg_use(:,1)==s);
            efforts_30(s) = 0; // constant case
        end
    case 1
        for s=1:nbMKT
            index_mkt = find(whichMKT_reg_use(:,1)==s);
            efforts_30(s) = sum(TC_l_sav(index_mkt,start_tax+duration_NDC).*GDP_PPP_constant_sav(index_mkt,start_tax+duration_NDC))/sum(GDP_PPP_constant_sav(index_mkt,start_tax+duration_NDC)); // tax growth at productivity rate case
        end
    end

    if ind_npi_ndc_effort == 0 | ind_npi_ndc_effort == 1
        for s=start_tax+duration_NDC+1:TimeHorizon+1
            temp(:,s) = temp(:,start_tax+duration_NDC).*(1+efforts_30).^(s-(start_tax+duration_NDC)); 
        end
    end
    //adding a carbon price ceiling

    if ~isdef("tax_ceiling")
        tax_ceiling = 200*10^-6;
        select ind_climat
        case 1
            tax_ceiling = 200*10^-6;
        case 2
            tax_ceiling = 400*10^-6;
        end
    end         
    taxMKTexo = min(temp,tax_ceiling);
end

if ~is_bau // case 0 is the baseline

    // Emission path target
    ldsav("E_reg_use_sav","",baseline_combi) ;
    ldsav("emi_evitee_sav","",baseline_combi) ;
    CO2_base = sum(E_reg_use_sav,"r") + sum(emi_evitee_sav,"r");

    ldsav("GDP_PPP_constant_sav","",baseline_combi);
    GDP_base_PPP_constant= GDP_PPP_constant_sav;

    ldsav("GDP_MER_real_sav","",baseline_combi);
    GDP_base_MER_real= GDP_MER_real_sav;

    ldsav("energyInvestment_sav","",baseline_combi);
    energyInvestment_base= energyInvestment_sav;

    // load reference intermediate inputs - mainly for terrestrial fret inputs to sectors:
    ldsav("CI_sav","",baseline_combi);
    base_CI = rgv(CI_sav,TimeHorizon+1,sec,sec,reg);

    ldsav("GDP_MER_nominal_sav","",baseline_combi);
    ldsav("GDP_MER_real_sav","",baseline_combi);
    ldsav("DF_sav","",baseline_combi);
    ldsav("pArmDF_sav","",baseline_combi);
    ldsav("sigma_sav","",baseline_combi);
    ldsav("qtax_sav","",baseline_combi);
    ldsav("Ttax_sav","",baseline_combi);
    base_GDP_MER_nominal = zeros(reg,TimeHorizon+1);
    base_GDP_MER_real = zeros(reg,TimeHorizon+1);
    base_DF = zeros(reg,sec,TimeHorizon+1);
    base_pArmDF = zeros(reg,sec,TimeHorizon+1);
    base_sigma = zeros(reg,sec,TimeHorizon+1);
    base_qtax = zeros(reg,sec,TimeHorizon+1);
    base_Ttax = zeros(reg,sec,TimeHorizon+1);
    for year = 1:TimeHorizon+1
        base_GDP_MER_nominal(:,year) = matrix(    GDP_MER_nominal_sav(:,year),12);
        base_GDP_MER_real(:,year) = matrix(    GDP_MER_real_sav(:,year),12);
        base_DF(:,:,year) = matrix(    DF_sav(:,year),reg,sec);
        base_pArmDF(:,:,year) = matrix(pArmDF_sav(:,year),reg,sec);
        base_sigma(:,:,year) = matrix(sigma_sav(:,year),reg,sec);
        base_qtax(:,:,year) = matrix(qtax_sav(:,year),reg,sec);
        base_Ttax(:,:,year) = matrix(Ttax_sav(:,year),reg,sec);
    end

    if ~isdef("exo_tax_increase")
        exo_tax_increase=1;
    end

    if ind_wait_n_see == 1
        taxMKTexo_wait_n_see=taxMKTexo; //Npi tax if agents get fooled
        duration_wait_n_see=5;
    end
    //////////////////////////
    ////// Carbon prices (ind_climat>0)
    ////// starting with world uniform price
    // 1 & 2: NPi/NDC
    // 3 : csv-enforced profile
    // 4 : linear-wise profile with 1 break
    // 5 : exponential profile with 1 break

    select ind_climat
        
    case 3
        is_quota_MKT = %f;
        is_taxexo_MKT = 1;
        temp = csvread(STUDY+"tax_trajectory_example.csv");
        taxMKTexo = temp'*1e-6/usd2001_2005*exo_tax_increase;
    case 4 // Piece-wise linear profile, start in 2020, break in break_year_tax_1
        //start_tax : starting year of the policy
        //break_year_tax_1 : policy shift year when linear-wise & exponential profile
        // WARNING: the preserve compability with previous versions, climate policy starts virtually in 2019, but 2019's carbon tax is set to zero after when smoothing, so the policy starts in 2020 in reality. As a consequences, tax2050 (now taxbreak_1) corresponds to 2049's value
        is_quota_MKT = %f*ones(nbMKT,1);
        is_taxexo_MKT = ones(nbMKT,1);
        temp = zeros(nbMKT,TimeHorizon+1);
        start_tax = start_year_policy - base_year_simulation + 1;
        if ~isdef("break_year_tax_1")
            break_year_tax_1 = 2050;
        end
        break_year_temp_1 = break_year_tax_1 - start_year_policy;
        if ~isdef("tax2019")
            tax2019 = 75;
        end
        if ~isdef("taxbreak_1")
            taxbreak_1 = 1600;
        end
        if ~isdef("tax2100")
            tax2100 = 3200;
        end
        for m=1:nbMKT
            temp(m,start_tax:(start_tax+break_year_temp_1)) = linspace(tax2019,taxbreak_1,break_year_temp_1+1)*1e-6;
            temp(m,(start_tax+break_year_temp_1):TimeHorizon+1) = linspace(taxbreak_1,tax2100,(final_year_simulation-break_year_tax_1)+1)*1e-6; 
        end
        taxMKTexo = temp;
        taxMKTexo_NZ = temp;
        //  For cases 5 & 6, start_tax is set + 1 to account for the fact that year 1 of temp is 2014 (anticipating future curation of case 4). In these two cases, starting value (tax2020) and smoothing are good

    case 5 //exponential profile with 2020 start by default, 2100 end and checkpoint_tax checkpoint (whose value's taxcheckpoint)
        // Here taxcheckpoint is 2050's value (not 2049's)
        is_quota_MKT = %f;
        is_taxexo_MKT = 1;
        start_tax = start_year_policy - base_year_simulation + 1;
        if ~isdef("checkpoint_tax")
            checkpoint_tax = 2050;
        end
        checkpoint_tax_temp = checkpoint_tax - start_year_policy;
        temp = zeros(TimeHorizon+1,1);
        if ~isdef("tax2020")
            tax2020 = 20;
        end
        if ~isdef("taxcheckpoint")
            taxcheckpoint = 50;
        end
        if ~isdef("tax2100")
            tax2100 = 1000;
        end
        tax_exp = [tax2020,taxcheckpoint,tax2100];
        time_exp = [start_tax, start_tax + checkpoint_tax_temp, TimeHorizon+1];

        // finding the exponentiel coefficients
        [coef_tax_exp,v,info] = fsolve([1,20,0.1], find_exp_tax_1_break);
        if info~=1
            error("[coef_tax_exp,v,info] =fsolve([1,2,2], find_exp_tax_1_break);");
        end 

        for s = (start_tax:TimeHorizon+1)
            temp(s) = (coef_tax_exp(1).*(1+coef_tax_exp(3))^s + coef_tax_exp(2))*1e-6;
        end
    case 6 //exponential profile with 2020 start and constant growth rate
        start_tax = start_year_policy - base_year_simulation + 1;
        is_quota_MKT = %f;
        is_taxexo_MKT = 1;
        temp = zeros(TimeHorizon+1,1);
        if ~isdef("tax2020")
            tax2020 = 5;
        end

        if ~isdef("tax_growth_rate")
            tax_growth_rate= 0.05;
        end

        for s = (start_tax:TimeHorizon+1)
            temp(s) = (tax2020*(1+tax_growth_rate)^(s-start_tax))*1e-6;
        end
    case 7 // Piece-wise linear profile, start in 2010, break in break_year_tax_1 and break_year_tax_2
        //start_tax : starting year of the policy
        // WARNING: as for case 5 and 6, we already corrected the starting year of the policy, so start_tax is set to start_year_policy - base_year_simulation + 1
        is_quota_MKT = %f*ones(nbMKT,1);
        is_taxexo_MKT = ones(nbMKT,1);
        temp = zeros(nbMKT,TimeHorizon+1);
        start_tax = start_year_policy - base_year_simulation + 1;
        if ~isdef("break_year_tax_1")
            break_year_tax_1 = 2030;
        end
        if ~isdef("break_year_tax_2")
            break_year_tax_2 = 2050;
        end
        break_year_temp_1 = break_year_tax_1 - start_year_policy;
        break_year_temp_2 = break_year_tax_2 - start_year_policy;
        if ~isdef("tax2020")
            tax2020 = 75;
        end
        if ~isdef("taxbreak_1")
            taxbreak_1 = 500;
        end
        if ~isdef("taxbreak_2")
            taxbreak_2 = 1600;
        end
        if ~isdef("tax2100")
            tax2100 = 3200;
        end
        for m=1:nbMKT
            temp(m,start_tax:(start_tax+break_year_temp_1)) = linspace(tax2020,taxbreak_1,break_year_temp_1+1)*1e-6; //2020 to 20WX
            temp(m,(start_tax+break_year_temp_1):(start_tax+break_year_temp_2)) = linspace(taxbreak_1,taxbreak_2,(break_year_temp_2-break_year_temp_1)+1)*1e-6; //20WX to 20YZ
            temp(m,(start_tax+break_year_temp_2):TimeHorizon+1) = linspace(taxbreak_2,tax2100,(final_year_simulation-break_year_tax_2 )+1)*1e-6; //20YZ to 2100
        end
        taxMKTexo = temp;
        taxMKTexo_NZ = temp;
    case 8 // Piece-wise linear profile, start in 2010, break in break_year_tax_1 and break_year_tax_2
        //start_tax : starting year of the policy
        // WARNING: as for case 5 and 6, we already corrected the starting year of the policy, so start_tax is set to start_year_policy - base_year_simulation + 1
        is_quota_MKT = %f;
        is_taxexo_MKT = 1;
        start_tax = start_year_policy - base_year_simulation+1;


        if ~isdef("break_year_tax_1")
            break_year_tax_1 = 2050;
        end
        break_year_temp_1 = break_year_tax_1 - start_year_policy;
        temp = zeros(TimeHorizon+1,1);
        if ~isdef("tax20202025")
            if ind_lindhal==0
                tax20202025 = 33;
            elseif ind_lindhal>=1
                tax20202025 = 58;
            end
        end
        if ~isdef("taxbreak_1")
            taxbreak_1 = 1000;
        end
        if ~isdef("tax2100")
            tax2100 = 3000;
        end
        temp(start_tax:(i_year_strong_policy-1)) = tax20202025*1e-6; //2020 to 20WX
        temp(i_year_strong_policy:(i_year_strong_policy+break_year_tax_1-start_year_strong_policy)) = linspace(tax20202025,taxbreak_1,(break_year_tax_1-start_year_strong_policy)+1)'*1e-6; //20WX to 20YZ
        if isdef("taxbreak_2") &  isdef("break_year_tax_2") 
            temp((i_year_strong_policy+break_year_tax_1-start_year_strong_policy):(i_year_strong_policy+break_year_tax_2-start_year_strong_policy)) = linspace(taxbreak_1,taxbreak_2,(break_year_tax_2-break_year_tax_1)+1)'*1e-6; //20WX to 20YZ
            temp((i_year_strong_policy+break_year_tax_2-start_year_strong_policy):TimeHorizon+1) = linspace(taxbreak_2,tax2100,(final_year_simulation-break_year_tax_2 )+1)'*1e-6; //20YZ to 2100
        else
            temp((i_year_strong_policy+break_year_tax_1-start_year_strong_policy):TimeHorizon+1) = linspace(taxbreak_1,tax2100,(final_year_simulation-break_year_tax_1 )+1)'*1e-6; //20YZ to 2100
        end
        taxMKTexo = temp';

        // compute the difference between the target price
        if ind_lindhal >=2
            if ~isfile( OUTPUT+'/ind_lindhal_tax_correction_'+part(string(combi),1:4)+'.csv')
                tax_ind_lindhal_cor = ones(taxMKTexo);
            else
                tax_ind_lindhal_cor = csvRead( OUTPUT+'/ind_lindhal_tax_correction_'+part(string(combi),1:4)+'.csv',',');
            end
            taxMKTexo_origin = taxMKTexo;
            taxMKTexo = taxMKTexo .* tax_ind_lindhal_cor;
        end

    case 9
        // exogenous tax until i_year_strong_policy, then endogenous tgax and exogenous emission profile 
        //start_tax : starting year of the policy
        nbMKT=1;
        is_quota_MKT = falses(nbMKT,1); // changes in nexus.climatePolicy2.sce
        is_taxexo_MKT = trues(nbMKT,1); // changes in nexus.climatePolicy2.sce
        start_tax = start_year_policy - base_year_simulation+1;

        temp = zeros(TimeHorizon+1,1);
        if ~isdef("tax20202025")
            if ind_lindhal==0
                tax20202025 = 33;
            elseif ind_lindhal>=1
                tax20202025 = 58;
            end
        end
        temp(start_tax:(i_year_strong_policy-1)) = tax20202025*1e-6; // we do not need to define the tax later, as it become endogenous
        taxMKTexo = temp';

        // endogenous emissions trajectory
        whichMKT_reg_use = ones(reg,nb_use);
        MKT_start_year = i_year_strong_policy*ones(nbMKT,1);

        CO2_traj_temp = csvRead(STUDY+'emissions_trajectories_base.csv','|',[],[],[],'/\/\//');
        ind_sc_temp = find(CO2_traj_temp(:,1)==4)
        CO2_obj_MKT = zeros(nbMKT,TimeHorizon+1);
        for i=1:nbMKT
            CO2_obj_MKT(i,i_year_strong_policy:$) = CO2_traj_temp(ind_sc_temp,(i_year_strong_policy+1):$) * 1e6;
        end

    case 11 // NPi then exponential carbon price. 

        combi_NPi_NDC_calib = 11; // calibrated NPi
        
        try
            ldsav("taxMKT_sav","",combi_NPi_NDC_calib);
        catch 
            disp("Error: the NDC/NPi scenario has not been run yet. Please check that the calibration run is complete and correspond to the desire baseline (either NPi or NDC) or run both with the shell script.")
        
        end


        temp = zeros(nbMKT,TimeHorizon+1);
        // Requires first to compute a weighted average of GDP growth rates per market

        temp = taxMKT_sav; // getting back the calibrated NPi carbon tax developement

        is_quota_MKT = %f;
        is_taxexo_MKT = 1;
        start_tax = start_year_policy - base_year_simulation + 1 + duration_NDC;
        if ~isdef("checkpoint_tax")
            checkpoint_tax = 2050;
        end
        checkpoint_tax_temp = checkpoint_tax - start_year_policy;
        if ~isdef("tax2020")
            tax2020 = temp(:,start_tax)*1e6; //here its 2030, not 2020
        end
        if ~isdef("taxcheckpoint")
            taxcheckpoint = 50;
        end
        if ~isdef("tax2100")
            tax2100 = 1000;
        end
        tax_exp = [tax2020,taxcheckpoint,tax2100];
        time_exp = [start_tax, start_tax + checkpoint_tax_temp, TimeHorizon+1];

        // finding the exponentiel coefficients
        [coef_tax_exp,v,info] = fsolve([30,50,0.1], find_exp_tax_1_break);
        if info~=1
            error("[markup_SIC,v,info] =fsolve([30,50,2], find_exp_tax_1_break);");
        end 

        for s = (start_tax:TimeHorizon+1)
            temp(s) = (coef_tax_exp(1).*(1+coef_tax_exp(3))^s + coef_tax_exp(2))*1e-6;
        end
        taxMKTexo = temp;
        
        if ind_wait_n_see == 1
            taxMKTexo_NZ = taxMKTexo;
            taxMKTexo_wait_n_see=taxMKT_sav; //Npi tax if agents wait and see
            duration_wait_n_see = 5;
        end
    
    case 12 // NPi then linear price. 


        if ind_wait_n_see == 1
            taxMKTexo_wait_n_see=taxMKTexo; //Npi tax if agents get fooled
            duration_wait_n_see=5;
        end

        // now computing the real NZ tax trajectory
        is_quota_MKT = %f*ones(nbMKT,1);
        is_taxexo_MKT = ones(nbMKT,1);
        start_tax = start_year_policy - base_year_simulation + 1 + duration_NDC;
        if ~isdef("break_year_tax_1")
            break_year_tax_1 = 2050;
        end

        tax2019 = temp(:,start_tax)*1e6; // take 2030 as the new starting point

        if ~isdef("taxbreak_1")
            taxbreak_1 = 1600;
        end
        if ~isdef("tax2100")
            tax2100 = 3200;
        end
        break_year_temp_1 = break_year_tax_1 - start_year_policy - duration_NDC;
        // linear start startin in 2030
        for m=1:nbMKT
            temp(m,start_tax:(start_tax+break_year_temp_1)) = linspace(tax2019(m),taxbreak_1,break_year_temp_1+1)*1e-6; 
            temp(m,(start_tax+break_year_temp_1):TimeHorizon+1) = linspace(taxbreak_1,tax2100,(final_year_simulation-break_year_tax_1 )+1)*1e-6; 
        end
        // temp(start_tax:(start_tax+break_year_temp_1)) = linspace(tax2019,taxbreak_1,break_year_temp_1+1)*1e-6; 
        // temp((start_tax+break_year_temp_1):TimeHorizon+1) = linspace(taxbreak_1,tax2100,(final_year_simulation-break_year_tax_1 )+1)*1e-6; 
    
        taxMKTexo = temp;
        taxMKTexo_NZ = temp;
    case 17 //Three exogenous carbon tax from csv
        whichMKT_reg_use = ones(reg,nb_use);

        whichMKT_reg_use(ind_chn,:)=2;
        whichMKT_reg_use(ind_ind,:)=3;
        
        temp = csvread(STUDY+"exo_tax_waysout_NDC_LTT.csv");

        is_quota_MKT  = [%f;%f;%f];
        is_taxexo_MKT = [%t;%t;%t];
        
        CO2_obj_MKT = ones(nbMKT,TimeHorizon+1)*%nan;
        taxMKTexo(1,:) = temp(:,1)'*1e-6;
        taxMKTexo(2,:) = temp(:,2)'*1e-6;
        taxMKTexo(3,:) = temp(:,3)'*1e-6;


    case 18 // as of 8 but with 3 income groups each having a different tax trajectory
        disp("Case 18: 3 income groups with different tax trajectories")
        nbMKT = 3;
        MKT_start_year = %nan*ones(nbMKT,1);
        whichMKT_reg_use = ones(reg,nb_use); //here everything is in the market 1. 
        whichMKT_reg_use(ind_middle_income,:)=2; //middle income
        whichMKT_reg_use(ind_low_income,:)=3; //low income
        is_quota_MKT = falses(nbMKT,1);
        is_taxexo_MKT = trues(nbMKT,1);
        start_tax = start_year_policy - base_year_simulation+1;

        // we keep same values as world uniform price for beginning of the trajectory for consistency between scenarios
        if ~isdef("break_year_tax_1")
            break_year_tax_1 = 2050;
        end
        break_year_temp_1 = break_year_tax_1 - start_year_policy;
        temp = zeros(TimeHorizon+1,nbMKT);
        if ~isdef("tax20202025")
            if ind_lindhal==0
                tax20202025 = 33;
            elseif ind_lindhal>=1
                tax20202025 = 58;
            end
        end
        // So has to get emissions in 2025 not lower than 95% of 2019 emissions (NAVIGATE scenario constriant), we start to increase strongly the carbon tax in 2026
        for m = 1:nbMKT
            if ~isdef("tax2026_" + string(m))
                execstr("tax2026_" + string(m) + " = 250;");
            end

            if ~isdef("taxbreak_1_" + string(m))
                execstr("taxbreak_1_" + string(m) + " = 1000;");
            end

            if ~isdef("tax2100_" + string(m))
                execstr("tax2100_" + string(m) + " = 3000;");
            end

            execstr("temp(start_tax:(i_year_strong_policy-1)," + string(m) + ") = tax20202025*1e-6;");
            execstr("temp(i_year_strong_policy:(i_year_strong_policy+break_year_tax_1-start_year_strong_policy)," + string(m) + ") = linspace(tax2026_" + string(m) + ",taxbreak_1_" + string(m) + ",(break_year_tax_1-start_year_strong_policy)+1)''*1e-6;");
            
            if isdef("taxbreak_2_" + string(m)) & isdef("break_year_tax_2_" + string(m))
                execstr("temp((i_year_strong_policy+break_year_tax_1-start_year_strong_policy):(i_year_strong_policy+break_year_tax_2-start_year_strong_policy)," + string(m) + ") = linspace(taxbreak_1_" + string(m) + ",taxbreak_2_" + string(m) + ",(break_year_tax_2-break_year_tax_1)+1)''*1e-6;");
                execstr("temp((i_year_strong_policy+break_year_tax_2-start_year_strong_policy):TimeHorizon+1," + string(m) + ") = linspace(taxbreak_2_" + string(m) + ",tax2100_" + string(m) + ",(final_year_simulation-break_year_tax_2)+1)''*1e-6;");
            else
                execstr("temp((i_year_strong_policy+break_year_tax_1-start_year_strong_policy):TimeHorizon+1," + string(m) + ") = linspace(taxbreak_1_" + string(m) + ",tax2100_" + string(m) + ",(final_year_simulation-break_year_tax_1)+1)''*1e-6;");
            end
        end
        taxMKTexo = temp';
        
        // compute the difference between the target price
        if ind_lindhal == 2 | ind_lindhal == 3
            if ~isfile( OUTPUT+'/ind_lindhal_tax_correction_'+part(string(combi),1:4)+'.csv')
                tax_ind_lindhal_cor = ones(taxMKTexo);
            else
                tax_ind_lindhal_cor = csvRead( OUTPUT+'/ind_lindhal_tax_correction_'+part(string(combi),1:4)+'.csv',',');
            end
            taxMKTexo_origin = taxMKTexo;
            taxMKTexo = taxMKTexo .* tax_ind_lindhal_cor;
        end

    case 651 //650 GtCO2 recycl = 0 (lump) taxexo - WP4_650_redist
        is_quota_MKT = %f;
        is_taxexo_MKT = 1;
        temp = csvread(STUDY+"taxwp4.csv");
        taxMKTexo = temp(:,2)'*1e-6/usd2001_2005;
        tax2020 = 50;
        tax2050 = 200;
        tax2100 = 3000;
        exo_maxmshbiom = 40/1000;
        elecBiomassInitial.MSHBioSup = exo_maxmshbiom;
    case 659  //659 650 GtCO2 recycl = 1 (labor) taxexo - WP4_650
        is_quota_MKT = %f;
        is_taxexo_MKT = 1;
        temp = csvread(STUDY+"taxwp4.csv");
        taxMKTexo = temp(:,3)'*1e-6/usd2001_2005;
    case 151 //1150 GtCO2 recycl = 0 (lump) taxexo - WP4_1150_redist
        is_quota_MKT = %f;
        is_taxexo_MKT = 1;
        temp = csvread(STUDY+"taxwp4.csv");
        taxMKTexo = temp(:,4)'*1e-6/usd2001_2005;
        tax2020 = 50;
        tax2050 = 200;
        tax2100 = 3000;
        exo_maxmshbiom = 30/1000;
        elecBiomassInitial.MSHBioSup = exo_maxmshbiom;
    case 159 //1150 GtCO2 recycl = 1 (labour) taxexo - WP4_1150
        is_quota_MKT = %f;
        is_taxexo_MKT = 1;
        temp = csvread(STUDY+"taxwp4.csv");
        taxMKTexo = temp(:,5)'*1e-6/usd2001_2005;
    case 99 // Npi and NDC in endogenous taxes - calibration. Taking Post-Glasgow emi reduction, with less optimistic scenario as default for myopic NPi/NDC - vettings
        //https://doi.org/10.1038/s41558-023-01661-0

        whichMKT_reg_use = whichMKT_NPi_NDC(nbMKT);

        //defining tol threshold: 1% upper, 5% lower
        tol_down_emi = 0.03;
        tol_up_emi = 0.03;
        // quota set to false : updated in nexus.climatePolicy2.sce
        is_quota_MKT = falses(nbMKT,1);
        is_taxexo_MKT = trues(nbMKT,1);
        //when carbon tax starts
        start_tax = start_year_policy - base_year_simulation+1;

        // --  step one: regional CO2 emi reduction between 2020 and 2025/2030. Indicative reduction : 0.93 btw 2020 and 2030 in NDC
        // forcing a linear reduction starting in 2020 is not really realistic, since emi increased post covid, but the models involved does not seem to include covid shocks. So we apply the reduction in emi to the 2019 value
        start_year_reduc = 2019; 
        reduc_endo_1 = 2025 -  base_year_simulation + 1;
        reduc_endo_2 = 2030 -  base_year_simulation + 1;
        // importing CO2 emi reductions (for diagnostic)
        //precise "NPi" or "NDC" calibration
        if ~isdef("scen_calib") 
            scen_calib = "NPi"; 
        end

        //correspondance between aggregation rule in the R script and the # of markets in IMACLIM
        select nbMKT
        
        case 1
            ag_rule = 1;
        case 4
            ag_rule = 2;
        case 7
            ag_rule = 3;
        case 9
            ag_rule = 4;
        end

        CO2_reduc_MKT = csvread(DATA + "NPi_NDC/emi_control_" + scen_calib + "_"+ ag_rule +".csv");
        // modifing the raw value of Reforming economies and replacing it by the Climate Action Tracker estimate (+10%)
        CO2_reduc_MKT(find(CO2_reduc_MKT == "REF"),3) = '1.08997';
        //keep values and transforms into numeric
        reduc_25 = strtod(CO2_reduc_MKT(2:$,2));   
        reduc_30 = strtod(CO2_reduc_MKT(2:$,3));

        if length(reduc_25) <> nbMKT
            error("Error in the definition of regional coverage for exogenous emission pathways. Please check that nbMKT and ag_rule in data/NPi_NDC/process_NPi_NDC.sh correspond")
        end 

        // Post-2030 trajectory is disregarded: releasing CO2 constraint after 2030
        // NB TB: interrupting of the calibratin runs after 2030?
        // to decide when CO2 constraint starts, we look at the first year where the objective is lower than the baseline = the last year where the objective is higher than the baseline + 1
    
        //loading carbon tax profiles
        try
            tax_profile = csvRead(DATA + "NPi_NDC/tax_profile" + "_"+ + scen_calib + "_"+ ag_rule +".csv");
        catch //init the file if the csv does not exist
            tax_profile =csvRead(DATA + "NPi_NDC/emi_control" + "_"+ + scen_calib + "_"+ ag_rule +".csv")
            tax_profile(2:$,2:$) = 40;
            csvWrite(tax_profile,DATA + "NPi_NDC/tax_profile" + "_"+ + scen_calib + "_"+ ag_rule +".csv");
        end


        //keep values and transforms into numeric
        tax_25 = tax_profile(2:$,2);   
        tax_30 = tax_profile(2:$,3);

        //deriving the linear tax profiles, starting from 0 in 2020

        temp = zeros(nbMKT,TimeHorizon+1);
        for s=1:nbMKT
            temp(s, start_tax: reduc_endo_1) =tax_25(s)*ones(1,reduc_endo_1-start_tax+1)*1e-6;
            temp(s,reduc_endo_1:reduc_endo_2) = linspace(tax_25(s),tax_30(s),reduc_endo_2-reduc_endo_1+1)*1e-6;
        end

        // after 2030, the tax is set to constant
        temp(:,(reduc_endo_2+1):TimeHorizon+1) = repmat(tax_30*1e-6,1,TimeHorizon-reduc_endo_2+1);

        taxMKTexo = temp;
    end // select ind_climat
end // if ~is_bau

if ~isdef("dur_smooth_tax")
    dur_smooth_tax = 5;
end

// no smoothing in credibility paper - 
if ind_climat == 4 | ind_climat == 5 | ind_climat == 6 | ind_climat == 7 & ind_climpol_uncer~=1
    temp(6:(6+dur_smooth_tax)) = linspace(0,1,(dur_smooth_tax+1))' .* temp(6:(6+dur_smooth_tax)); // smoothing taxe increase from 2019 to 2024. This set temp(6) to 0 which correspond to year 2019 in the model
    taxMKTexo = temp';
end



//options to limit the increase in carbon prices (including expectations)
if ~isdef("nz_target") & ind_nz == 1
    nz_target = 1000;  // in MT CO2: treshold in emi after which the carbon price is capped

end
if ind_climpol_uncer>0
    taxlim_2060 = 2500; // in $/tCO2: treshold in CT after which the carbon price is capped. Useful because standard CO2 price profiles are used but one may want to modify them ex post
    if cap_CO2_price == 1
        for s = (2050 - base_year_simulation):(2060 - base_year_simulation)
            if taxMKTexo(1:nbMKT,s) > taxlim_2060 / 1e6
                taxMKTexo(1:nbMKT,(s+1):(TimeHorizon+1)) = taxMKTexo(1:nbMKT,(s):(TimeHorizon)) ;
                taxMKTexo(1:nbMKT,s) = taxlim_2060 / 1e6;
            end
        end
    end
end


if ~isdef("CO2_obj_MKT") // in case more than 1 market
    CO2_obj_MKT = ones(nbMKT,TimeHorizon+1)*%nan;
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
                execstr(names +"."+names2+"=externallyChangedVar."+names+"."+names2+";");
            end
        else
            execstr(names + "=externallyChangedVar."+names+";")
        end
    end
end

/////////////////////////////////////////////////////////////////////////////
//      Various consitency checks
/////////////////////////////////////////////////////////////////////////////
exec(STUDY+"testStudy.sce");

//forcing the tax when calibrating profile costs: 
if calib_profile_cost == 1
    taxMKTexo = ones(taxMKTexo) * 150/10^6;
end
