// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//--------------------------------------------------------------------//
//--------------------------------------------------------------------//
//------ ---------------POWER SECTOR NEXUS ---------------------------//
//-------------Part I: computing expected ideal park -----------------//
//--------------------------------------------------------------------//
//--------------------------------------------------------------------//

//files related the power sector nexus:
//indexes.electricity.sce
//nexus.electricity.idealPark.sce
//nexus.electricity.realInvestment.sce
//nexus.wacc.sce

//Table of contents

//0. Scenario parameters change

//1. Life-cycle cost of renewable and non-renewable technos

//2. Demand and fossil fuel prices expectations

//3. Market shares for dispatchable technos

//4. Market shares for non-dispatchable technos

//5. Residual load curve

//6. Ideal installed park from optimal market shares

//7. Final investment for period t 

//--------------------------------------------------------------------//
//------ Scenario parameters change ----------------------------------//
//--------------------------------------------------------------------//
if ind_high_VRE==1 & current_time_im>=i_year_strong_policy
    param_SIC = cor_param_SIC_lowflex_po*0.05 * CPI_2018_to_2014; 
end


//--------------------------------------------------------------------//
//------ Life-cycle cost of renewable and non-renewable technos ------//
//--------------------------------------------------------------------//

//Actualizing cumulated investment
//This changes the capital cost (learning curve) and the discount factor (cost of capital)
//learning starts at different periods of the model
if  ind_first_run_elec==1 //dummy for climate finance loop. ==1 by default (set in dynamic.sce)
    for j=1:techno_elec
        if current_time_im>init_ITC_elec(j)
            Cum_Inv_MW_elec(j)=Cum_Inv_MW_elec(j)+sum(Inv_MW(:,j),"r");
            sum_Inv_MW(j)=sum(Inv_MW(:,j),"r");
        end
    end
end

//discount rates for wind/pv/non-renewable from TB modelling project
exec(MODEL+"nexus.wacc.sce");

//Capacity Recovery Factor. Converts lifetime annual payment into single present value payment.
CRF=disc_rate_elec(:,:,current_time_im)./(1-(1+disc_rate_elec(:,:,current_time_im)).^(-Life_time_LCC));

for k=1:reg
    for j=1:techno_elec
        //CINV_MW_nexus(k,j)=(CINV_MW_ITC_ref(j)-A_CINV_MW_ITC_ref(j))*(1-LR_ITC_elec(j))^(log(Cum_Inv_MW_elec(j)/Cum_Inv_MW_elec_ref(j))/log(2))+A_CINV_MW_ITC_ref(j);
        CINV_MW_nexus(k,j)=max((CINV_MW_ITC_ref(k,j))*(1-LR_ITC_elec(j))^(log(Cum_Inv_MW_elec(j)/Cum_Inv_MW_elec_ref(j))/log(2)),A_CINV_MW_ITC_ref(k,j));
    end
    for j=technoPV //TB: merging CPV and RPV invesments when computing learning
        CINV_MW_nexus(k,j)=max(CINV_MW_ITC_ref(k,j)*(1-LR_ITC_elec(j))^(log((Cum_Inv_MW_elec(indice_CPV)+Cum_Inv_MW_elec(indice_RPV))/(Cum_Inv_MW_elec_ref(indice_CPV)+Cum_Inv_MW_elec_ref(indice_RPV)))/log(2)),A_CINV_MW_ITC_ref(k,j));
    end
end

if  current_time_im<5 //2019
    for k=1:reg
        for j = techno_VRE //loop for years between 2014 and 2019, make 2014 costs linearly converges to 2019 costs from IEA
            CINV_MW_nexus(k,j) = min(CINV_MW_ref(k,j),CINV_MW_ref(k,j) - current_time_im/5*(CINV_MW_ref(k,j)-CINV_MW_2019(k,j)));
            CINV_MW_ITC_ref(k,j) = CINV_MW_nexus(k,j); //TB: so the learning applies to the 2019 costs starting from 2019
            Cum_Inv_MW_elec_ref(j) = Cum_Inv_MW_elec(j); //And take into account the added inv between 2014 and 2019
        end
    end
end
CINV_MW_nexus(:,indice_STR) = CINV_storage_nexus(:,current_time_im);
    
// Applying learning on O&M for FF seems to be good proxy for cost decreases according to WEO assumption
OM_cost_var_nexus=OM_cost_var_ref.*CINV_MW_nexus./CINV_MW_ITC_ref;
OM_cost_fixed_nexus=OM_cost_fixed_ref.*CINV_MW_nexus./CINV_MW_ITC_ref;
//rho_elec_nexus(k,j)=interpln([[CINV_MW_ITC_ref(j),A_CINV_MW_ITC_ref(j)];[rho_elec(k,j,1),rho_elec(k,j,$)]],CINV_MW_nexus(k,j));

rho_elec_nexus = rho_elec(:,:,1); //No more learning on rho

rho_elec_vintage(:,:,current_time_im+Life_time_max_FF)=rho_elec_nexus;

CINV=CRF.*CINV_MW_nexus(:,:);

//--------------------------------------------------------------------//
//------------- Demand and fossil fuel prices expectations -----------//
//--------------------------------------------------------------------//

if  ind_first_run_elec == 1 //dummy for climate finance loop. ==1 by default (set in dynamic.sce)

    // 1 year trend for demand growth
    tendance_Q_elec = taux_Q_nexus(:,elec);

    //////////////////////Power supply at time  t+nb_year_expect_futur

    //Loop to avoid decreasing demand
    Q_elec_ENR_anticip = zeros(reg,1);
    Q_elec_anticip_tot = zeros(reg,1);
    Q_elec_anticip_tot_1 = zeros(reg,1);



    //linear growth rather than exponential growth. Matches both real data and the model's output: the annual growth rate of electricity demand is decreasing over time
    for k=1:reg 
        if ind_nexus_elec_except=="linear" & current_time_im>=start_year_policy-base_year_simulation
            Q_elec_anticip_tot(k)=max((Q(k,indice_elec)+(Q(k,indice_elec)- Q_prev(k,indice_elec))*nb_year_expect_futur)*(mtoe2mwh), Q_elec_anticip_tot_prev(k)*0.95); // still allowing for a 5% decrease in demand
            Q_elec_anticip_tot_1(k)=max((Q(k,indice_elec)+(Q(k,indice_elec)- Q_prev(k,indice_elec)))*(mtoe2mwh), Q_elec_anticip_tot_1_p(k)*0.95); // still allowing for a 5% decrease in demand
        elseif ind_nexus_elec_except=="quadratic" | (ind_nexus_elec_except=="linear" & current_time_im<start_year_policy-base_year_simulation)
            Q_elec_anticip_tot(k)= max( (Q(k,indice_elec) .* taux_Q_nexus(k,elec) .^nb_year_expect_futur) *(mtoe2mwh) , Q_elec_anticip_tot_prev(k)*0.95); // still allowing for a 5% decrease in demand
            Q_elec_anticip_tot_1(k)= max( (Q(k,indice_elec) .* taux_Q_nexus(k,elec) ) *(mtoe2mwh) , Q_elec_anticip_tot_1_p(k)*0.95);
        end
    end

    Q_antrec(:,current_time_im)=Q_elec_anticip_tot;
    Q_elec_anticip_tot_prev=Q_elec_anticip_tot;
    Q_elec_anticip_tot_1_p=Q_elec_anticip_tot_1;
   

    if calib_profile_cost == 1
        Q_elec_anticip_tot = Q_elec_init;
    end
    //expected hydro production 
    Q_hydro = Cap_hydro(:,current_time_im+nb_year_expect_futur).*AF_hydro(:,current_time_im+nb_year_expect_futur)*full_load_hours;
    // expected market share of hydro (with correction)
    share_hydro = divide(Q_hydro,Q_elec_anticip_tot,0)* (1-correc_hydro);

    //Total peak and baseload anticipation (peak_W_anticip_tot needed to compute storage requirements later)
    peak_W_anticip_tot = Q_elec_anticip_tot./(bp_ratio*full_load_hours + facteur_t*(1-bp_ratio));
    peak_W_anticip_tot_1 = Q_elec_anticip_tot_1./(bp_ratio*full_load_hours + facteur_t*(1-bp_ratio));
    base_W_anticip_tot = bp_ratio.*peak_W_anticip_tot;
    delta_W_anticip_tot = peak_W_anticip_tot-base_W_anticip_tot;

    // Deriving the expected residual load duration curve for MSH control
    // The absolute value of each load bands are not used, but only the share of each load band in the total residual load for a consistent MSH control
    // For the first year, the residual peak load and residual total load are dynamically calibrated

    //just to make sure that no silly things happen between two periods
    Q_elec_anticip = max(Q_elec_anticip,peak_W_anticip*730);
    [n_inner_bands_loop,inner_band_height,baseload,load_bands] = compute_load_bands(Q_elec_anticip, peak_W_anticip);
    //some tests to check the consistency of the load bands
    // test_sum_load_bands(peak_W_anticip, baseload, inner_band_height, n_inner_bands_loop)
    // test_area_under_RLDC(load_bands,Q_elec_anticip)
    // test_null_load_bands(load_bands)
    // create a function to compute the share of each load band in the total residual load
    // Takes load_bands as a input, and divides each load band & its lentgh by the total residual load

    //Check: load_band_shares.band_730 + load_band_shares.band_2190 + load_band_shares.band_3650 + load_band_shares.band_5110 + load_band_shares.band_6570 + load_band_shares.band_8030 + load_band_shares.band_8760
    load_band_shares = compute_load_band_shares(Q_elec_anticip, load_bands);

    /////////////////////////Expectations on FF prices including beliefs about the C price
    /////////////////////////// expected prices in $/kWh
    if current_time_im==1
        prod_elec_techno(1:reg,technoBiomass) = 0;
    end
    //Biomass cost (with expected carbon tax if forward looking expectations)

    [costBIGCC_withTax,costBIGCCS_withTax,costBIGCC_noTax,costBIGCCS_noTax,breakEvenTax] = ..
        computeBiomassCost(elecBiomassInitial.supplyCurve,prod_elec_techno(:,technoBiomass),..
        rho_elec_nexus(:,technoBiomass),..
        elecBiomassInitial.emissions,elecBiomassInitial.emissionsCCS,..
        croyance_taxe,expected.taxCO2_CI(indice_agriculture,indice_elec,:,:),..
    elecBiomassInitial.exogenousBiomassMaxQ,%f,elecBiomassInitial.priceCap);

    p_Coal_anticip     = squeeze(expected.pArmCI       (coal,elec,:,1:Life_time_max_FF)) / tep2kwh * dynForc_pcoal;
    p_Gaz_anticip      = squeeze(expected.pArmCI       (gaz ,elec,:,1:Life_time_max_FF)) / tep2kwh ;
    p_Et_anticip       = squeeze(expected.pArmCI       (et  ,elec,:,1:Life_time_max_FF)) / tep2kwh ;
    p_Coal_anticip_CCS = squeeze(expected.pArmCI_noCTax(coal,elec,:,1:Life_time_max_FF)) / tep2kwh * dynForc_pcoal;
    p_Gaz_anticip_CCS  = squeeze(expected.pArmCI_noCTax(gaz ,elec,:,1:Life_time_max_FF)) / tep2kwh ;

    // Adding a 10% capture rate 
    if ind_cap_rate_CCS
        p_Coal_anticip_CCS = (cap_rate_CCS.*squeeze(expected.pArmCI_noCTax(coal,elec,:,1:Life_time_max_FF)) / tep2kwh) + (1-cap_rate_CCS).*p_Coal_anticip;
        p_Gaz_anticip_CCS  = (cap_rate_CCS.*squeeze(expected.pArmCI_noCTax(gaz,elec,:,1:Life_time_max_FF)) / tep2kwh) + (1-cap_rate_CCS).*p_Gaz_anticip;
    end
    //Biomass price
    if current_time_im==1
        growth_bioelec_costs = ones(12,1);
    end

    p_biom_antcp_noTax       = costBIGCC_noTax / tep2kwh;
    p_biom_antcp_CCS_noTax   = costBIGCCS_noTax / tep2kwh;
    p_biom_antcp_withTax     = costBIGCC_withTax  / tep2kwh;
    p_biom_antcp_CCS_withTax = costBIGCCS_withTax / tep2kwh;

    if ind_cap_rate_CCS
        p_biom_antcp_CCS_withTax = (cap_rate_CCS.*costBIGCCS_withTax / tep2kwh) + ((1-cap_rate_CCS).*p_biom_antcp_withTax);
    end

    p_biom_antcp_agg_noTax   = [ repmat(p_biom_antcp_noTax(:,1),1,length(technoBiomassWOCCS))   p_biom_antcp_CCS_noTax(:,1)   ];     // $/kWh
    p_biom_antcp_agg_withTax = [ repmat(p_biom_antcp_withTax(:,1),1,length(technoBiomassWOCCS))  p_biom_antcp_CCS_withTax(:,1) ]; // $/kWh

    CFuel=zeros(reg,nTechno_dispatch);

    //For CFuel: fuel costs are discounted to get fuel cost present value. Then the sum is converted into an annualized constant payment with the CRF (annuity factor)
    for k=1:reg
        for j=technoElecCoal
            CFuel(k,j)=0;
            for t=1:Life_time_LCC(k,j)
                CFuel(k,j)=CFuel(k,j)+p_Coal_anticip(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
            end
        end    
        for j=technoElecGas
            CFuel(k,j)=0;
            for t=1:Life_time_LCC(k,j)
                CFuel(k,j)=CFuel(k,j)+p_Gaz_anticip(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
            end
        end

        for j=technoOil
            CFuel(k,j)=0;
            for t=1:Life_time_LCC(k,j)
                CFuel(k,j)=CFuel(k,j)+p_Et_anticip(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
            end
        end

        /////////////////////////////////////Treating CCS separately: removing the carbon price component from the FF price
        j=indice_PSS;
        CFuel(k,j)=0;
        for t=1:Life_time_LCC(k,j)
            CFuel(k,j)=CFuel(k,j)+p_Coal_anticip_CCS(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
        end

        j=indice_CGS;
        CFuel(k,j)=0;
        for t=1:Life_time_LCC(k,j)
            CFuel(k,j)=CFuel(k,j)+p_Coal_anticip_CCS(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
        end

        j=indice_GGS;
        CFuel(k,j)=0;
        for t=1:Life_time_LCC(k,j)
            CFuel(k,j)=CFuel(k,j)+p_Gaz_anticip_CCS(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
        end
        
        j=indice_UCS;
        CFuel(k,j)=0;   
        for t=1:Life_time_LCC(k,j)
            CFuel(k,j)=CFuel(k,j)+p_Gaz_anticip_CCS(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
        end

        j=technoNuke;
        CFuel(k,j)=Nuc_fuel_cost_kwh;

        //biomass
        j=indice_BIG;
        CFuel(k,j)=0;
        for t=1:Life_time_LCC(k,j)
            CFuel(k,j)=CFuel(k,j)+(p_biom_antcp_withTax(k,t)+elecBiomassInitial.processCost.BIG)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
        end
        j=indice_BIS;
        CFuel(k,j)=0;
        for t=1:Life_time_LCC(k,j)
            CFuel(k,j)=CFuel(k,j)+(p_biom_antcp_CCS_withTax(k,t)+elecBiomassInitial.processCost.BIS)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
        end

        j=indice_SBI;
        CFuel(k,j)=0;
        for t=1:Life_time_LCC(k,j)
            CFuel(k,j)=CFuel(k,j)+(p_biom_antcp_withTax(k,t)+elecBiomassInitial.processCost.SBI)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
        end

    end

    //--------------------------------------------------------------------//
    //----------------- Interest during construction ---------------------//
    //--------------------------------------------------------------------//

    // Linear cash flow 
    lin_CINV = CINV_MW_nexus ./ Constr_period;

    // total construction costs including interest during construction, in present value
    Tot_constr_cost = zeros(reg, ntechno_elec_total);
    for k = 1:reg
        for j = 1:ntechno_elec_total
            // Separate integer and fractional parts of the construction period
            int_part = floor(Constr_period(k, j));
            frac_part = Constr_period(k, j) - int_part;

            // Handle integer years
            for ll = 1:int_part
                Tot_constr_cost(k, j) = lin_CINV(k, j) * (1 + disc_rate_elec(k, j, current_time_im))^ll + Tot_constr_cost(k, j);
            end

            // Handle the fractional part of the last year (if any)
            if frac_part > 0
                Tot_constr_cost(k, j) = lin_CINV(k, j) * (1 + disc_rate_elec(k, j, current_time_im))^int_part * frac_part + Tot_constr_cost(k, j);
            end
        end
    end

    // Withdrawing overnight costs to get the interest during construction
    int_cost = Tot_constr_cost - CINV_MW_nexus;

    // Annualized interest during construction
    int_cost_ann = int_cost.*CRF;
    // int_cost_ann ./CINV // to check the order of magnitude of the "IDC multiplier"

    //--------------------------------------------------------------------//
    //----------------- Annual degradation (PV only) ---------------------//
    //--------------------------------------------------------------------//

    //computing the average degradation rate that yield the exact same electricity generation in the LCOE formulate (including discounting)
    sum_LHS = 0;
    smh_RHS = 0;
    for ll=(0:Life_time(1,indice_CPV)-1)
        sum_LHS = sum_LHS + ((1-deg_rate_pv)./(1+disc_rate_elec(:,technoPV,current_time_im))).^ll;
        smh_RHS = smh_RHS + (1 ./(1+disc_rate_elec(:,technoPV,current_time_im))).^ll;
    end
    avg_deg_rate(:,technoPV) = 1-(sum_LHS./smh_RHS);


    //when calibrating IC, IC are not expanded because the variable "LCC_"+tranche+"_type" needs to be computed without IC for calibration

    if auto_calibration_IC_elec==%t
        IC_elec_expand= zeros(reg,nTechno_dispatch);  
    end
    IC_elec_total=converge_IC(IC_elec_base, Convergence_horizon, convergence_type);
    if current_time_im<=Convergence_horizon
        IC_elec=IC_elec_total(:,:,current_time_im);
    end
    if auto_calibration_IC_elec==%f 
        for j=techno_dispatch_type
            ll=find(j == techno_dispatch_type);
            execstr("index_IC = techno"+j+"");
            IC_elec_expand(:,index_IC) = repmat(IC_elec(:,ll),1,length(index_IC));
        end
    end
    //--------------------------------------------------------------------//
    //------------- Market shares for dispatchable technos ---------------//
    //--------------------------------------------------------------------//

    // objective: compute a mean LCOE for dispatchable power plants that can compete with VRE
    // hydro inv is exogenous, but still included in the dispatchable techno to compute the mean LCOE, but with a corrected constraint

    //LCC = Levelized cost of producing 1 MW during "tranche" hours. The LCC is a LCOE since LCC = Cost of generating electricity/Electricity Generation but for varying call duration.
    //The availability factor (AF,for FF) and the capacity factor (CF,for VRE, here CSP only) must be accounted for.We assume that 1 MW of installed cap can produce during AF/CF hours in a year.If the call duration exceeds the AF/CF then extra capacity must be installed to match the 1 MW demand. We assume that outages are planned outside of called hours when the call duration is lower than full load hours.
    // The installed capacity must be able to provide 1MW of power during H hours of call duration, such that: X * AF = 1*H <=> X = H/AF
    //=> that H/AF of installed cap must be installed to provide an available 1 MW on the call duration.


    for tranche = tranches_elec
        for j=techno_dispatchable
            execstr("LCC_"+tranche+"(:,j) =  max((ones(reg,1)*"+tranche+")./(avail_factor(:,j)*full_load_hours),ones(reg,1)).*(CINV(:,j)+int_cost_ann(:,j) + OM_cost_fixed_nexus(:,j) + TD_cost_ann(:,j))./"+tranche+" +CFuel(:,j)+OM_cost_var_nexus(:,j);");
        end
        execstr("LCC_"+tranche+"(:,indice_CSP) = max((ones(reg,1)*"+tranche+")./(Load_factor_CSP*10^3),1).*((CINV(:,indice_CSP) +int_cost_ann(:,indice_CSP)+OM_cost_fixed_nexus(:,indice_CSP) + TD_cost_ann(:,indice_CSP))./"+tranche+"+CFuel(:,indice_CSP)+OM_cost_var_nexus(:,indice_CSP));") //adding this for CSP as it includes a load/capacity factor constraint. Edited : we consider the average hours of functionning throught the year for CSP: if is lower than the call duration, then 1 MW of CSP does not produce more than Load_factor_CSP*10^3 MWh. Instead, we act like that providing 1 MW during H hours required to install H/(Load_factor_CSP*10^3) MW of CSP
    
        execstr("LCC_"+tranche+" = max(LCC_" + tranche+",1e-3);"); // set a floor LCC to avoid division by zero and distorsions from biomass + CCS.
    end
    //adding intangible costs (for MSH calculation only)
    for tranche = tranches_elec
        execstr("LCC_"+tranche+" = LCC_" + tranche+" + IC_elec_expand;")
    end

    for tranche = tranches_elec
        for techno_type = techno_dispatch_type
            execstr("MSH_"+tranche+"_type_norm(:, techno"+techno_type+") = modified_logit(LCC_"+tranche+"(:,[techno"+techno_type+"]),gamma_FF,ones(reg,length([techno"+techno_type+"])))")
        end
    end

    //for each type of techno, a weighted LCOE is computed to get a global LCOE for the family

    for tranche = tranches_elec
        for techno_type = techno_dispatch_type
            j = find(techno_dispatch_type == techno_type);
            execstr("LCC_"+tranche+"_type(:,j) = sum(LCC_"+tranche+"(:,[techno"+techno_type+"]).*MSH_"+tranche+"_type_norm(:, techno"+techno_type+"),2)")
        end
    end

    //--------------------------------------------------------------------//


    //Computing the MSH for each type of techno: apply constraints on these market shares
    for tranche = tranches_elec
        execstr("MSH_"+tranche+"_type = modified_logit(LCC_"+tranche+"_type,gamma_FF_type,ones(reg,n_type_elec));")
    end
    ///// Contraints on economically optimal market share per type of techno
    //hydro: a corrected market share mimics the deployment of hydro. This includes hydro as a dispatchable technology that competes with VRE but has limited potential for growth.

    for tranche=tranches_elec
        j = find(techno_dispatch_type == "Hydro");
        execstr ("MSH_"+tranches_elec+"_type_sup(:,j) = share_hydro;");
    end

    // Limiting biomass with CCS msh growth
    if ind_seq_beccs_opt >= 1 & Tstart_biomass<=current_time_im
        for k=1:reg
            j = find(techno_dispatch_type == "BiomassWCCS"); 
            execstr("MSH_"+tranches_elec+"_type_sup(k,j) = min("..
                + "MSH_limit_newtechno(Tstart_biomass,Tniche_biomass,Tgrowth_biomass,Tmature_biomass,MSHmax_biomass,current_time_im),"..
                + "MSH_"+tranches_elec+"_type(k,j)+elecBiomassInitial.maxGrowthMSH,"..
            + "elecBiomassInitial.MSHBioSup);");
        end
    end


    if ind_nuc_opt == 0
        for tranche=tranches_elec
            for k=1:reg
                j = find(techno_dispatch_type == "Nuke");
                execstr ("MSH_"+tranches_elec+"_type_sup(k,j) = 0;");
            end
        end
    end

    // No new Nuclear construciton after 2030
    if ind_lim_nuke == 1 & current_time_im >= year_stop_nuclear-base_year_simulation
        for tranche=tranches_elec
            for k=1:reg
                j = find(techno_dispatch_type == "Nuke");
                execstr ("MSH_"+tranches_elec+"_type_sup(k,j) = max(0, MSH_"+tranches_elec+"_type_sup(k,j) * (6-current_time_im+16-1)/6  );");
            end
        end
    end

    // no new coal 2024: imposing a limit on coal market share corresponding in operation + planned construction in 2024
    // we make the assumption that nuke will only be chosen on the lower load bands so we don't have to account for msh on higher load bands, in which small total msh ->high capacity due to low utilization rates.
    // this is just for the dispatchable choice indicator, in any case capacity additions are constrainted downstream when converting msh into capacity additions
    if ind_lim_nuke == 2 
        total_msh_nonew_nuke = (Cap_nuke_nonew.Cap + Cap_nuke_nonew.Capconst) .* avail_factor(:,technoNuke) * full_load_hours./Q_elec_anticip_tot;
        j = find(techno_dispatch_type == "Nuke");
        MSH_8760_type_sup(:,j) = total_msh_nonew_nuke;
    end

    //Constraints on CCS
    //Step 1 CCS starts immediately if 1) its ideal share in the mix is not negligeable AND 2) a minimum threshold for the carbon tax is reached
    //Step 2 Applying the S curve technology deployment on each techno and tranche.
    if ind_seq_opt > 0
        for k=1:reg
            for tranche=tranches_elec
                for j= [find(techno_dispatch_type == "CoalWCCS"),find(techno_dispatch_type == "GasWCCS")];
                    //Step 1
                    if evstr ("Tstart_CCS_"+tranche+"(k)==0 & MSH_"+tranche+"_type(k,j)>0.001 & max(taxCO2_CI(:,indice_elec,k))>starting_taxCO2_ccs_elec *1e6")
                        execstr ("Tstart_CCS_"+tranche+"(k)=current_time_im;");
                    end
                    //Step 2
                    if evstr ("Tstart_CCS_"+tranche+"(k)>0")
                        execstr ("MSH_"+tranche+"_type_sup(k,j)=MSH_limit_newtechno(Tstart_CCS_"+tranche+"("+k+"),Tniche_CCS_"+tranche+"(k),Tgrowth_CCS_"+tranche+"(k),Tmature_CCS_"+tranche+"(k),mshMaxCCS,current_time_im);");
                    end
                end
            end
        end
    end

    //Step 3
    //if the carbon tax is lower than starting_taxCO2_ccs_elec  .1e6 $/tCO2, CCS market shares are null
    // => CCS deployment starts after the floor carbon price is reached

    for k=1:reg
        if (max(taxCO2_CI(:,indice_elec,k)) < starting_taxCO2_ccs_elec  | ind_CCS == 0) & ind_CCS <> 9; //include cases where CCS is not allowed
            for tranche = tranches_elec
                for j=[find(techno_dispatch_type == "CoalWCCS"),find(techno_dispatch_type == "GasWCCS")];
                    execstr ("MSH_"+tranche+"_type_sup(k,j)=0;");
                end
            end
        end
    end
    for k=1:reg
        if current_time_im <= elecBiomassInitial.startLearningDateBIGCCS
            if max(taxCO2_CI(:,indice_elec,k)) < starting_taxCO2_ccs_elec  | ind_seq_beccs_opt == 0; //include cases where CCS is not allowed
                for tranche = tranches_elec
                    for j=find(techno_dispatch_type == "BiomassWCCS")
                        execstr ("MSH_"+tranche+"_type_sup(k,j)=0;");
                    end
                end
            end
        end
    end

    //Step 4
    // if we limit the maximum yearly injection rate, we keep CCS for BECCS
    // in variant ind_limCCS_InjRate==2, only BECCS are constrained.
    if ind_limCCS_InjRate==1 & current_time_im>=start_year_strong_policy-base_year_simulation & current_time_im <= year_stop_CCS_constraint-base_year_simulation
        for k=1:reg
            for tranche = tranches_elec
                for j=[find(techno_dispatch_type == "CoalWCCS"),find(techno_dispatch_type == "GasWCCS")];
                    execstr ("MSH_"+tranche+"_type_sup(k,j)=0;");
                end
            end
        end
    end
    rate_deploy_VRE = (max(part_ENR_prod_endo(:,current_time_im+max(nb_year_expect_futur-2,1))./part_ENR_prod_endo(:,current_time_im),1).^(1/(max(nb_year_expect_futur-2,1))) -1);

    MSH_type_sup = min(divide(MSH_8760_type_sup,repmat(max((1-part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur-1).*(1+rate_deploy_VRE)),%eps),1,n_type_elec),0),1);
    // compute max MSH of BIGCCS corresponding to the maximum injection rate, if ind_limCCS_InjRate==1 or 2
    if ind_limCCS_InjRate>0 & current_time_im>=start_year_strong_policy-base_year_simulation & current_time_im <= year_stop_CCS_constraint-base_year_simulation

        Cap_BIGCCS_predicted = zeros(reg,1);
        for k=1:reg
            for tranche = tranches_elec
                j = find(techno_dispatch_type == "BiomassWCCS"); 
                execstr("Cap_BIGCCS_predicted(k) = Cap_BIGCCS_predicted(k) + min(MSH_"+tranche+"_type(k,j),MSH_"+tranche+"_type_sup(k,j)) * (Cap_"+tranche+"_anticip_MW(k))/(max("+tranche+"/avail_factor(k,technoBiomassWCCS)/full_load_hours,1));")
            end
        end

        rho_elec_moyen_BIGCCS = divide( sum(prod_elec_techno(:,technoBiomassWCCS) .* rho_elec_moyen(:,technoBiomassWCCS)) ,sum(prod_elec_techno(:,technoBiomassWCCS) ), rho_elec_moyen(1,indice_BIS));
        max_global_BIGCCS_Cap = max_CCS_injection * rho_elec_moyen_BIGCCS / (-elecBiomassInitial.emissionsCCS / gj2tep /tep2MWh / full_load_hours);
        MSH_BIGCCS_correction = max_global_BIGCCS_Cap ./ (sum(Cap_BIGCCS_predicted)+%eps); // * tep2MWh;
        for k=1:reg
            for tranche = tranches_elec
                j = find(techno_dispatch_type == "BiomassWCCS"); 
                execstr ("MSH_"+tranche+"_type_sup(k,j)= min( MSH_type_sup(k,j), MSH_"+tranche+"_type_sup(k,j) * MSH_BIGCCS_correction * MSH_BIGCCS_cor_factor);");
            end
        end
    end
    //Maximum market shares for constrained technologies are expressed in terms of non-intermittent share.
    //So market share is constrained at the level of total electricity output and not only the share provided by dispatchable technologies.
    //Otherwise it makes little sense to constraint dispatchable techno on dispatchable market share

    //The mean increase rate over the period to guess part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur) value before computing it later
    //We must anticipate the t+nb_year_expect_futur because we only know the t+nb_year_expect_futur-1 value from previous run


    //the new constraint variable (reg*n_type_elec) applies to total MSH (rather than a fuzzy per load band MSH constraint)
    // rationale of the loop:
    // 1. compute the MSH in % of dispatchable power per load band
    // 2. compare to remaining available MSH (MSH_type_sup_loop) in % of dispatchable power
    // 3. reduce the MSH for constrained technos, reallocate to non-constrained technos, to compute new per load bands
    // 4. repeat until convergence
    // 5. reduce the MSH to MSH_type_sup_loop before the next load band to reduce the available MSH
    // normalizing the absolute MSH into relative share in % of dispatchable power
    // temporary: use MSH_8760_type_sup to get the new MSH. A new variable that does not include any load band will be created

    MSH_type_sup = min(divide(MSH_8760_type_sup,repmat(max((1-part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur-1).*(1+rate_deploy_VRE)),%eps),1,n_type_elec),0),1);
    // MSH constraint as a share of dispatchable power
    MSH_type_sup_loop = MSH_type_sup;

    for k=1:reg
        for tranche=tranches_elec
            execstr ("Test_"+tranche+" = ones(1,n_type_elec)");
            execstr ("MSH_"+tranche+"_type_new = zeros(reg,n_type_elec)");
            it_elec=0;
            execstr ("test_elec = sum(Test_"+tranche+">0);")
            while  test_elec > tol_elec_msh 
                //step 1
                execstr ("MSH_"+tranche+"_type_share = MSH_"+tranche+"_type(k,:)*load_band_shares.band_"+tranche+"(k);");   
                //step 2 
                execstr ("Test_"+tranche+"=MSH_"+tranche+"_type_share-MSH_type_sup_loop(k,:);");
                //step 3
                execstr ("MSH_"+tranche+"_type_new(k,Test_"+tranche+">=0)=divide(MSH_type_sup_loop(k,Test_"+tranche+">=0),load_band_shares.band_"+tranche+"(k),0);");
                execstr ("MSH_"+tranches_elec+"_type_new(k,Test_"+tranche+"<0) =MSH_"+tranche+"_type(k,Test_"+tranche+"<0).*(1+sum(Test_"+tranche+"(Test_"+tranche+">=0),''c'')./sum((MSH_"+tranche+"_type(k,Test_"+tranche+"<0)+%eps),''c''));");

                // normalize MSH_"+tranches_elec+"_type_new to make sure it sums to 1
                execstr ("MSH_"+tranche+"_type_new(k,:)=divide(MSH_"+tranche+"_type_new(k,:),sum(MSH_"+tranche+"_type_new(k,:),''c''),0);");
                // new MSH to loop over 
                execstr ("MSH_"+tranche+"_type(k,:) = MSH_"+tranche+"_type_new(k,:);");
                //step 4
                execstr ("test_elec = sum(Test_"+tranche+">0);")
                it_elec = it_elec + 1;
                if  it_elec > max_it_elec_msh
                    //disp("Convergence failed in reg ",k)
                    execstr("undistrib_msh = sum(Test_"+tranche+"(Test_"+tranche+">0));")
                    //disp("Undistributed constrained MSH = ", undistrib_msh)
                    break
                end
            end
            //convergence achieved: reducing MSH_type_sup
            execstr ("MSH_"+tranche+"_type_share_new = MSH_"+tranche+"_type_new(k,:)*load_band_shares.band_"+tranche+"(k);"); 
            //step 5
            execstr ("MSH_type_sup_loop(k,:) = MSH_type_sup_loop(k,:)  - MSH_"+tranche+"_type_share_new;");
        end
    end
    //check that the sum of MSH x load band shares < MSH_type_sup
    sum_weighted_MSH = zeros(reg,n_type_elec);
    for tranche=tranches_elec
        for k=1:reg
            execstr ("sum_weighted_MSH(k,:) = sum_weighted_MSH(k,:) + MSH_"+tranche+"_type(k,:)*load_band_shares.band_"+tranche+"(k);");
        end
    end

    if sum((MSH_type_sup-sum_weighted_MSH)<-10^-6)>0
        disp("Warning: some MSH exceed the constraint")
    end

    //once checks done, set to 0 the negative MSH (around zero)
    for tranche=tranches_elec
        execstr ("MSH_"+tranche+"_type = max(MSH_"+tranche+"_type,0)");
    end

    //Removing the intangible costs for the LCOE: only for intra-dispatchable power calibration
    for tranche=tranches_elec
        execstr ("LCC_"+tranche+"_type_wo_IC = LCC_"+tranche+"_type - IC_elec;");
    end
    // preventing the displacing of VRE by biomass + CCS: the LCOE of BiomassWOCCS is used for BiomassWCCS if the later is lower.
    j = find(techno_dispatch_type  == "BiomassWOCCS");
    ll = find(techno_dispatch_type  == "BiomassWCCS");

    // in cases with high biomass, we allow the LCOE of BECCS to be much lower
    if ind_seq_beccs_opt >=1
        LCC_8760_type_wo_IC(:,ll) = max(LCC_8760_type_wo_IC(:,ll),LCC_8760_type_wo_IC(:,j)/3);
    else
        LCC_8760_type_wo_IC(:,ll) = max(LCC_8760_type_wo_IC(:,ll),LCC_8760_type_wo_IC(:,j));
    end

    // mean LCOE for dispatchable technologies per family, on baseload: choice indicator for the main logit node


    // To get a mean baseload LCOE, we need to find a market share that is representative of the constraints on the techno
    // we cannot simply take the MSH on Full load hours because not constraint apply at all on this load band with high VRE shares (load_band_shares.band_8760 = 0)
    // so we need to identify first i) the first positive load band, ii) select the next inner load bands (up to four inner load bands)
    // multiply baseload LCOE by this representative load band

    first_positive_band = find_first_positive_band(load_band_shares);

    if current_time_im > 2
        LCC_FF_prev_prev = LCC_FF_prev;
    end

    if current_time_im > 1
        LCC_FF_prev = LCC_FF;
    end
    


    LCC_FF = sum(LCC_8760_type_wo_IC.*compute_representative_MSH(load_band_shares),2);

    //adding inertia to the dispatchable choice indicator
    LCC_FF =  inertia_LCC(LCC_FF, LCC_FF_prev, LCC_FF_prev_prev, iner_LCC);
    //--------------------------------------------------------------------//
    //------------- Market shares for non-dispatchable technos -----------//
    //--------------------------------------------------------------------//

    //The share weights are calibrated as base year to fit actual VRE share data. We are making share weight converge to equal share to 2030, meaning that technologies only compete based
    // on their mesured LCOE. Factors outside pure costs of techno are progressively eliminated 
    //Applying the same 
    if current_time_im <= Convergence_horizon & current_time_im > target_year //corresponds to 2015 - 2030 years for which we make share weights converge to 1:1 parity
        weights_VRE_nest = weights_VRE_nest_hist + max(min(((current_time_im-target_year)/(Convergence_horizon-target_year)),1),0)*(1-weights_VRE_nest_hist);
        weights_VRE_FF = weights_VRE_FF_hist + max(min(((current_time_im-target_year)/(Convergence_horizon-target_year)),1),0)*(1-weights_VRE_FF_hist);

    end

    //------------------------------------------------------------------//
end //end of ind_first_run_elec == 1 if condition
//------------------------------------------------------------------//

//New variable renewable market shares
LCC_ENR=compute_LCOE(CINV,int_cost_ann,OM_cost_fixed_nexus,TD_cost_ann,Load_factor_ENR,avg_deg_rate,prof_gross_VRE_kwh=pc_gross_VRE_kwh,stor_gross_VRE_kwh=str_gross_VRE_kwh,OM_cost_var_nexus,Bal_cost,crt_gross_VRE=curt_VRE);


output_Net_VRE =[LCC_ENR(:,[technoWind_absolute,technoPV_absolute]),curt_VRE_gross];
info=4;
nb_try=0;
while (info<>1 & nb_try<10)
    nb_try=nb_try+1;
    [output_Net_VRE,v,info] = fsolve( output_Net_VRE,find_net_LCOE_VRE2);
end
LCC_ENR(:,techno_VRE_absolute) =output_Net_VRE(:,1:nTechno_VRE);

//getting back the choice indicator for VRE
[choice_ind_VRE, MSH_VRE] = VRE_choice_indicator(LCC_ENR, gamma_VRE,weights_VRE_nest);


share_FF_ENR_prev = max(share_FF_ENR,0);

share_FF_ENR =compute_1st_n_VRE_nest(choice_ind_VRE,LCC_FF,MSH_VRE, gamma_FF_ENR, weights_VRE_FF);
//calibration check: the VRE share in the mix must be equal to target_prod_tot_VRE
//target_prod_tot_VRE-share_FF_ENR(:,2:nbTechFFENR)>0.01;

//indicator of renewable energy share (wo biomass)
//share_FF_ENR(:,1) - share_hydro

// prevent from decreasing VRE share too fast, X% between every dur_seq_inv_elec iteration (happens with biomass + CCS)
//if current_time_im > 1
//    share_FF_ENR(:,1) = min( share_FF_ENR(:,1), share_FF_ENR_prev(:,1)*(1+max_incr_dispatch));
if current_time_im > 1
    for k=1:reg
        if share_FF_ENR(k,1)>share_FF_ENR_prev(k,1)*(1+max_incr_dispatch)
            if verbose>=1
                disp("Preventing excessive increase of dispatchable share in region "+k);
            end
            share_FF_ENR(k,1) = share_FF_ENR_prev(k,1)*(1+max_incr_dispatch);
            // make sure that the sum of shares is 1
            share_FF_ENR(k,2:nbTechFFENR) = share_FF_ENR(k,2:nbTechFFENR)* (1 - share_FF_ENR(k,1))/sum(share_FF_ENR(k,2:nbTechFFENR));
            
            if sum(share_FF_ENR(k,:)) > 1.01 | sum(share_FF_ENR(k,:)) < 0.99
                disp("Warning: wrong share_FF_ENR sum in region "+k);
            end
        end
    end
end

curt_VRE_gross=output_Net_VRE(:,nTechno_VRE+1:$);
curt_VRE = [repmat(curt_VRE_gross(:,1),1,length(technoWind_absolute)),repmat(curt_VRE_gross(:,2),1,length(technoPV_absolute))];

if force_VRE_share
    Gross_VRE_share_wind = WD_sh_target(:,current_time_im+nb_year_expect_futur);
    Gross_VRE_share_pv = Solar_sh_target(:,current_time_im+nb_year_expect_futur);
    curt_VRE_gross=att_curtailment(Gross_VRE_share_wind ,Gross_VRE_share_pv);
    curt_VRE  = [repmat(curt_VRE_gross(:,1),1,length(technoWind_absolute)),repmat(curt_VRE_gross(:,2),1,length(technoPV_absolute))];
    share_FF_ENR(:,technoWind_ENR_vs_FF) = repmat(Gross_VRE_share_wind/2,1,length(technoWind_ENR_vs_FF)).*(1-curt_VRE(:,technoWind_absolute))
    share_FF_ENR(:,technoPV_ENR_vs_FF) = repmat(Gross_VRE_share_pv/2,1,length(technoPV_ENR_vs_FF)).*(1-curt_VRE(:,technoPV_absolute))
end
//Gross and net VRE shares as a share of annual demand
Gross_VRE_share_wind_tot = share_FF_ENR(:,technoWind_ENR_vs_FF)./(1-curt_VRE(:,technoWind_absolute)); 
Gross_VRE_share_pv_tot = share_FF_ENR(:,technoPV_ENR_vs_FF)./(1-curt_VRE(:,technoPV_absolute)); 
Gross_VRE_share_wind = sum(Gross_VRE_share_wind_tot,"c");
Gross_VRE_share_pv = sum(Gross_VRE_share_pv_tot,"c");

// Computing storage costs per kWh of VRE: storage needs in kW (peak_W_anticip_tot is in MW)
str_gross = att_str(Gross_VRE_share_wind,Gross_VRE_share_pv,peak_W_anticip_tot,Q_elec_anticip_tot);
str_gross_VRE = [repmat(str_gross(:,1),1,length(technoWind_absolute)),repmat(str_gross(:,2),1,length(technoPV_absolute))];
//in $/kWh of gross PV/wind gen
str_gross_VRE_kwh = str_gross_VRE.* repmat(CINV(:,indice_STR),1,nTechno_VRE);
// profile costs (convert in $/kWh)
pc_gross = att_profile_costs(Gross_VRE_share_wind,Gross_VRE_share_pv);
pc_gross_VRE_kwh = [repmat(pc_gross(:,1),1,length(technoWind_absolute)),repmat(pc_gross(:,2),1,length(technoPV_absolute))]/10^3;
// LCC_ENR=compute_LCOE(CINV,int_cost_ann,OM_cost_fixed_nexus,TD_cost_ann,Load_factor_ENR,avg_deg_rate,prof_gross_VRE_kwh=pc_gross_VRE_kwh,stor_gross_VRE_kwh=str_gross_VRE_kwh,OM_cost_var_nexus,Bal_cost,crt_gross_VRE=curt_VRE);
//check that the newly computed LCOE = that of the fsolve
//abs(LCC_ENR - output_Net_VRE(:,1:nTechno_VRE))>0.001;

//Total net VRE share in the ideal mix
part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur) = sum(share_FF_ENR(:,technoENRi_vs_FF),"c");

if force_VRE_share==1
    part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur) = net_VRE_share;
end

//between t = 0 and t=10 the variable part_ENR_prod_endo is not computed. For t=1, we take the t+10 estimate and use a linear approximation between t = 0 (= reference year share) and t=10. There are 11 years (current_time_im+nb_year_expect_futur if current_time_im = 1) between year 0 and year 10
if current_time_im ==1
    part_ENR_prod_endo(:,current_time_im) = max((1-current_time_im/(current_time_im+nb_year_expect_futur))*sum((Load_factor_ENR(:,techno_VRE_absolute)*1000).*Cap_elec_MWref(:,techno_VRE),"c")./(Qref(:,indice_elec)*(mtoe2mwh)) + current_time_im/(current_time_im+nb_year_expect_futur) * part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur),sum((Load_factor_ENR(:,techno_VRE_absolute)*1000).*Cap_elec_MWref(:,techno_VRE)./repmat((Qref(:,indice_elec)*mtoe2mwh),1,nTechno_VRE),"c")); 
    //+ prevent from decreasing share of VRE with max. Due to the fact that Q(:,elec) does not necessarely corresponds to the electricity demand from IRENA, from which come Cap_elec_MWref
end 
for j=1:nb_year_expect_futur
    part_ENR_prod_endo(:,current_time_im+j) = part_ENR_prod_endo(:,current_time_im) + (j/nb_year_expect_futur)*(part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur) - part_ENR_prod_endo(:,current_time_im));
end


part_ENR_prod_anticip=part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur);

//--------------------------------------------------------------------//
//------------- Residual load curve ----------------------------------//
//--------------------------------------------------------------------//


//Expected residual electricity demand in the next t+nb_year_expect_futur.
Q_elec_anticip=Q_elec_anticip_tot.*(1-part_ENR_prod_anticip);

//Resdiual Load Duration Curve design
// Inspired from ADVANCE project, using ADVANCE outputs (DIMES BU model)
//From DIMES outputs, we extract a relationship between (gross) solar/wind shares and residual peak load
//We perform polynomial fit (3rd order polynom) to get the best estimate of the residual peakload based on solar PV & wind (offshore + onshore) 
//See 10.1016/j.eneco.2016.05.012 for method
RLDC_peak_ant = find_RLDC_peak([sum(Gross_VRE_share_wind,"c"),sum(Gross_VRE_share_pv,"c")]);
if old_RLDC_design == 1
    RLDC_peak_ant = (1-part_ENR_prod_anticip);
end

peak_W_anticip = RLDC_peak_ant.*peak_W_anticip_tot;
RLDC_peak(:,current_time_im+nb_year_expect_futur)=RLDC_peak_ant;



for j=1:nb_year_expect_futur
    RLDC_peak(:,current_time_im+j) = RLDC_peak(:,current_time_im) + (j/nb_year_expect_futur)*(RLDC_peak(:,current_time_im+nb_year_expect_futur) - RLDC_peak(:,current_time_im));
    //With max we forbid an increase in the residual peak(mean that in t+10 there is less renewable than in t, which is not likely at all). Mostly due to incomplete calibration of the model
end

//With basic RLDC design we make sure that the area below the RLDC equals the net VRE gen
// from the equation : Q_elec_anticip = base*FLH + facteur_t*(peak - base)
base_W_anticip = (Q_elec_anticip - peak_W_anticip*facteur_t)/(full_load_hours-facteur_t);

//BUT as the baseload becomes negative due to strict equality between load band heights, we must control for the negative part of the area under the residual load curve
//We still want the positive area under the RLDC to be equal to net dispatchable generation. Thus, we compute again the height of the load bands 
for tranche = tranches_elec
    execstr("base_W_anticip_"+tranche+"=zeros(reg,1)")
end



//computing residual load bands with new VRE market share
[n_inner_bands_loop,inner_band_height,baseload,load_bands] = compute_load_bands(Q_elec_anticip, peak_W_anticip);
//setting the positive load bands to 0 to match the fuzzy design of hydro removal code
//this needs a proper new function
n_bands = n_inner_bands_loop + 2;

band_ind = tranches_elec(n_load_bands + 1 - n_bands);

////Reserve margin requirement
//Adding a 20% reserve margin on the last band (20% of residual peak load)
load_bands.band_730 = load_bands.band_730 + peak_W_anticip*reserve_margin;

for k=1:reg
    band = band_ind(k);
    execstr("base_W_anticip_"+band+"(k)=load_bands.band_"+band+"(k);")
end
base_W_anticip = base_W_anticip_8760;

////////////////////Removing hydro production from baseload, and upper load bands if necessary

// This is always true: if base_W_anticip = 0 we set Cap_8760_anticip_MW(k) to 0

for tranche = tranches_elec
    execstr("Cap_"+tranche+"_anticip_MW = zeros(reg,1);")
end

// T.B. : we can get a much more effective function to remove hydro from the RLDC
//new loop for hydro
//This is a bit more complex since this loop is a broader case of the previous one. it includes the cases when there are fewer residual load bands due to high level of VRE deployment
lower_band = zeros(reg,1);

//if baseload is positive, removing hydro goes as usual
//If baseload is neg, it is set to 0 and a new lower_band is declared
// Start_RLDC states which load band the loop is starting on. 1 corresponds to 8030h load band

for k=1:reg
    start_RLDC = 0;
    tranches_RLDC = tranches_elec(1:$);
    if base_W_anticip(k) > 0
        lower_band(k) = base_W_anticip(k) ; 
    end
    for tranche = tranches_wo_base
        row = grep(tranches_wo_base,tranche);
        if evstr("base_W_anticip_"+tranches_wo_base(row)+"(k)>0")
            execstr("lower_band(k) = base_W_anticip_"+tranches_wo_base(row)+"(k)")
            execstr("tranches_RLDC = tranches_elec(row+1:$)")
            execstr("start_RLDC = "+row+"")
        end
        nb_steps = size(tranches_RLDC,2)-1; //Number of vertical steps in the RLDC
        //Removing hydro production
    end
    if Cap_hydro(k,current_time_im+nb_year_expect_futur)*AF_hydro(k,current_time_im+nb_year_expect_futur)<lower_band(k)
        execstr("Cap_"+tranches_RLDC(1)+"_anticip_MW(k)=lower_band(k)-Cap_hydro(k,current_time_im+nb_year_expect_futur)*AF_hydro(k,current_time_im+nb_year_expect_futur);") 
    else
        execstr("Cap_"+tranches_RLDC(1)+"_anticip_MW(k)=0;")
    end
    for tranche = tranches_RLDC(1:$-1)
        row=grep(tranches_RLDC,tranche); //getting the tranche index
        
        if evstr ("Cap_"+tranche+"_anticip_MW(k)==0") 
            if Cap_hydro(k,current_time_im+nb_year_expect_futur)*AF_hydro(k,current_time_im+nb_year_expect_futur)<(lower_band(k)+row*(peak_W_anticip(k)-lower_band(k))/nb_steps)  
                execstr ("Cap_"+tranches_RLDC(row+1)+"_anticip_MW(k)=lower_band(k)-Cap_hydro(k,current_time_im+nb_year_expect_futur)*AF_hydro(k,current_time_im+nb_year_expect_futur)+row*(peak_W_anticip(k)-lower_band(k))/nb_steps;");
            else execstr ("Cap_"+tranches_RLDC(row+1)+"_anticip_MW(k)=0;"); end
        else execstr ("Cap_"+tranches_RLDC(row+1)+"_anticip_MW(k)=(peak_W_anticip(k)-lower_band(k))/nb_steps;"); end
    end
end




//--------------------------------------------------------------------//
//-----Ideal installed park from optimal market shares ---------------//
//--------------------------------------------------------------------//

//From available to installed capacities. We assume that outages are schedule out of call periods.

//On each load band and for each techno, we compare the required availability factor tranches_elec/FLH with the actual availability factor. If a plant of 1MW is called 100% of the year with an AF of 90%, then the installed capacity must be of 1MW*100/90 = 1.111MW (with a 90% AF then 1.1111MW can provide in average a power of 1MW).
//We then assume for lower load bands that planned outages happen when demand is low => if the AF is 90% but the plant is called 50% of the time, then the AF become 1 on call duration.
Cap_elec_MW_exp_inst = zeros(reg,techno_elec);
for k=1:reg
    for tranche = tranches_elec // the market share per load band is given by MSH_tranche_type(:,technotype) *MSH_tranche_ _type_norm(:,techno)
        for techno_type = techno_dispatch_type
            j = find(techno_dispatch_type == techno_type);
            execstr("Cap_elec_MW_exp_inst(k,techno"+techno_type+") = Cap_elec_MW_exp_inst(k,techno"+techno_type+") + MSH_"+tranche+"_type(k,j).*MSH_"+tranche+"_type_norm(k,techno"+techno_type+").*(repmat(Cap_"+tranche+"_anticip_MW(k),1,length(techno"+techno_type+"))).*(max(repmat("+tranche+",1,length(techno"+techno_type+"))./full_load_hours./avail_factor(k,techno"+techno_type+"),1));")
        end
    end
end
//Storage in MW
Cap_elec_MW_exp_inst(:,technoStorage) = storage_share_peak([Gross_VRE_share_wind,Gross_VRE_share_pv]).*peak_W_anticip_tot;
//////////////Remaining capacities after decommissining
//Remark: the variable Cap_elec_MW_vintage tracks capacity additions. The addition at time t is given by the value of the variable at t+Lifetime_max.
//When summing Cap_elec_MW_vintage from time Life_time_max-Life_time(k,j)+1+current_time_im to current_time_im+Life_time_max, we cumulate new capacity additions that still can be operated at time t => this is the depreciated capacity at time t, or existing capacity before investment at time t.
//for Cap_depreciated_10, this is basically the same but we start 10 years later = what will be the remaining capacities if no investment is undeertaken
for k=1:reg
    for j=1:techno_elec
        Cap_elec_MW_dep(k,j)=sum(Cap_elec_MW_vintage(j,current_time_im+Life_time_max-Life_time(k,j)+1:current_time_im+Life_time_max,k));
    end
end

Cap_depreciated_10=zeros(reg,techno_elec);
for k=1:reg
    for j=1:techno_elec
        Cap_depreciated_10(k,j)=sum(Cap_elec_MW_vintage(j,current_time_im+nb_year_expect_futur+Life_time_max-Life_time(k,j)+1:current_time_im+Life_time_max,k));
    end
end
////////Comparing the optimal capacity with the remaining capacity at time t+10, which gives the needed investment over the the period to reach to optimal value.
// greenfield if calibrating the profile costs
if calib_profile_cost == 1
    Cap_depreciated_10=zeros(Cap_depreciated_10)
    Cap_elec_MW_dep=zeros(Cap_elec_MW_dep)
end

if ind_lim_nuke == 2
    Cap_elec_MW_exp_inst(:,indice_NUC) = min(Cap_elec_MW_exp_inst(:,indice_NUC),Cap_nuke_nonew.Cap + Cap_nuke_nonew.Capconst);
end
delta_Cap_elec_MW=(Cap_elec_MW_exp_inst-Cap_depreciated_10);

// Introducing sequential decision making in the investment decision
// the investment decision looks at a 10y decision horizon, but is reassessed every dur_seq_inv_elec year rather than every year. This is to avoid too much volatility in the investment decision and mimic the fact that investment decisions are not taken every year in reality
// This also yields 
// the variable delta_Cap_elec_MW is rename in the inv & dispatch script into delta_Cap_elec_MW_1. delta_Cap_elec_MW_1 is the delta capacity to be installed over dur_seq_inv_elec years.

if modulo(current_time_im-1,dur_seq_inv_elec)==0 //investment decision is taken every dur_seq_inv_elec years

    //delta_Cap_elec_MW_1 is set to zero if negative investment (no early decommissining)
    delta_Cap_elec_MW=max(delta_Cap_elec_MW,0)*dur_seq_inv_elec/nb_year_expect_futur;
    // peak load coverage: preventing from overinvestment in dispatchable technologies in case of fuel switching. This must be completed with early decommissing process to be fully operational
    for k=1:reg
        delta_Cap_elec_MW(k,[technoFossil, technoNuke,technoElecHydro,indice_CSP,technoBiomassWOCCS]) = delta_Cap_elec_MW(k,[technoFossil, technoNuke,technoElecHydro,indice_CSP,technoBiomassWOCCS])* peak_cov_calibration(residual_peak_cov(k),res_param);
    end

    //extra rule: investment is not performed if existing capacity was not dispatched past year
    //Why would it happen? The logit node for dispatchable technologies lead to a diversified portfolio of dispatchable technologies. Meanwhile, the dispatch is made based on the strict merit order, which is a much sharper rule than the logit. + the decisionmaking is not forward looking (on fuel prices, on future residual peak load and so on) which lead to inconsistent investment decisions, which we try to mitigate here.
    for k=1:reg
        // for j=1:setdiff(techno_elec,indice_STR) // wo storage
        //     if Cap_elec_MW_dep(k,j)>10 & Utilrate(k,j) < %eps
        //         delta_Cap_elec_MW(k,j)=0;
        //         // disp("Investment not performed for techno "+j+" in region "+k+" because of null utilization rate")
        //     end
        // end
        for j=setdiff(1:techno_elec,[indice_STR, technoOil,technoElecGas, technoHydro]) // for baseload capacity (coal, nuclear, biomass), does not invest if utilization rate is below min_util_rate
            // the (1-part_ENR_prod_anticip)/5 rule is totally ad hoc, to handle cases with very high VRE penetration 75% were we want to allow even lower utilisation rates.
            if Cap_elec_MW_dep(k,j)>10 & Utilrate(k,j) < min(min_util_rate, (1-part_ENR_prod_anticip)/5) 
                delta_Cap_elec_MW(k,j)=0;
                if verbose>=1
                    message("Investment not performed for techno "+j+" in region "+k+" because of null utilization rate")
                end
            end
        end
    end

    Cap_ENR_MW_anticip=zeros(reg,nTechno_VRE);
    Inv_MW_techno_ENR=zeros(reg,nTechno_VRE);

    //share_Cap_ENR is now computed as a share of VRE total production. Dividing the total production by VRE techno by the hours of functionning yields the needed installed cap
    Cap_ENR_MW_anticip(:,techno_VRE_absolute) = repmat(Q_elec_anticip_tot,1,length(techno_VRE)).*[Gross_VRE_share_wind_tot,Gross_VRE_share_pv_tot]./(10^3*(Load_factor_ENR(:,techno_VRE_absolute)));

    //forcing investment: for simplicity since the RLDC data only discriminate between wind and solar, we assume that wind = ofshore and solar = utility-scale PV
    if force_VRE_share==1
        Cap_ENR_MW_anticip(:,techno_VRE_absolute) = repmat(Q_elec_anticip_tot,1,length(techno_VRE)).*[sum(Gross_VRE_share_wind,"c"),zeros(reg,1),sum(Gross_VRE_share_pv,"c"),zeros(reg,1)]./(10^3*(Load_factor_ENR(:,techno_VRE_absolute)));
    end
    
    for j=techno_VRE
        tech=find(techno_VRE==j);
        for k=1:reg
            Inv_MW_techno_ENR(k,tech)=(Cap_ENR_MW_anticip(k,tech)-Cap_depreciated_10(k,j))*dur_seq_inv_elec/nb_year_expect_futur;
        end
    end
    
    Inv_MW_techno_ENR = max(Inv_MW_techno_ENR,0)/dur_seq_inv_elec; //annual investment schedule


    //--------------------------------------------------------------------//
    //-----Final investment for period t ---------------------------------//
    //--------------------------------------------------------------------//
    delta_Cap_elec_MW_1 = delta_Cap_elec_MW/dur_seq_inv_elec; // resizing delta cap so its corresponding to the annual investment schedule
    Inv_MW=zeros(reg,techno_elec);
    Inv_MW=delta_Cap_elec_MW_1; 

    Inv_MW_hydro=Inv_MW(:,indice_HYD);//for hydro we already know t+1 needs since this is 
    //hydro is treated separately
    Inv_MW(:,techno_VRE) = Inv_MW_techno_ENR;
    Inv_MW(:,technoBiomass) = delta_Cap_elec_MW_1(:,technoBiomass);


    //Apply maximum growth rate of capacity constraint (expansion constraint)
    // This primary plays for renewables in the first periods, later for biomass, so we apply it after current_time_im>1
    // because we calibrate the share weights of the logit to fit 2018 data, so we don't want to mess with that
    // +solar PV technologies are grouped -> questionning the relevance of pooling the expansion constraint on solar PV
    if current_time_im>1 & ind_max_growth_rate_elec>0
        for k=1:reg
            for j=setdiff(1:techno_elec,[technoPV,technoHydro])
                if Inv_MW(k,j)>min_inv_exp & msh_elec_techno(k,j)>niche_elec_msh 
                    if Inv_MW(k,j)>Inv_MW_seq(k,j)*(1+max_growth_rate_elec)^dur_seq_inv_elec & verbose>=1
                        message("Investment in techno "+j+" in region "+k+" is limited by max growth rate")
                    end
                    Inv_MW(k,j)=min(Inv_MW(k,j),Inv_MW_seq(k,j)*(1+max_growth_rate_elec)^dur_seq_inv_elec);
                    
                end
                
            end
            for j=technoPV
                if sum(Inv_MW(k,technoPV))>min_inv_exp & sum(msh_elec_techno(k,technoPV))>niche_elec_msh 
                    if Inv_MW(k,j)>Inv_MW_seq(k,j)*(1+max_growth_rate_elec)^dur_seq_inv_elec & verbose>=1
                        message("Investment in techno "+j+" in region "+k+" is limited by max growth rate")
                    end
                    Inv_MW(k,j)=min(Inv_MW(k,j),Inv_MW_seq(k,j)*(1+max_growth_rate_elec)^dur_seq_inv_elec);
                end
            end
           
        end
    end
    Inv_MW_seq = Inv_MW; //introducing this intermediate variable because Inv_MW gets modified in the inv & dispatch script. Inv_MW_seq is computed only every dur_seq_inv_elec years.
end
    
//so we now have the same inv for dur_seq_inv_elec years
//some variables need to be loaded between years during which investment schedule is reassessed, because they get modified in the nexus.electricity.realInvestment.sce script
Inv_MW = Inv_MW_seq;
Inv_MW_techno_ENR(:,techno_VRE_absolute) = Inv_MW(:,techno_VRE);

Inv_MW(:,indice_HYD) = max(Cap_hydro(:,current_time_im+1)-Cap_elec_MW_dep(:,indice_HYD),0);
Inv_MW_hydro=Inv_MW(:,indice_HYD);

Inv_val_Hydro=Inv_MW_hydro.*CINV_MW_nexus(:,indice_HYD)/1e3;


///////////////////////////////////////////the price of capital varies with investments
pCap_MW_elec=divide(sum(Inv_MW.*CINV_MW_nexus(:,:)/10^3,"c"),sum(Inv_MW,"c"),1);

for k=1:reg
    Beta(:,indice_elec,k)=pCap_MW_elec(k)/pCap_MW_elecref(k)*Betaref(:,indice_elec,k);
end

if current_time_im==year_calib_txCaptemp & auto_calibration_txCap<>"None"
    txCap_elec = (peak_W_anticip_tot ./ peak_W_anticip_tot_ref) .^ (1. /current_time_im) -1;
    inert_txCap_elec = 0;//inert_temp;
    txCaptemp_elec = inert_txCap_elec*txCap(:,indice_elec) + (1-inert_txCap_elec)*txCap_elec;
    error=divide(txCaptemp_elec,txCap(:,elec),1);
    abs_error_elec= abs(error-1);
    disp( [max( abs_error_elec), mean(abs_error_elec)], "max, mean");

    disp(txCaptemp_elec,"txCaptemp_elec")
    csvWrite( txCap_elec, path_autocal_txCap+'elec/txCaptemp_elec_'+string(nb_sectors)+'.csv');
end
if current_time_im==1 & auto_calibration_txCap<>"None"
    pCap_elec_tpt = sum(delta_Cap_elec_MW_1.*CINV_MW_nexus(:,:)/10^3,'c')./(sum(delta_Cap_elec_MW_1,'c').*Capref(:,indice_elec)./sum(Cap_elec_MWref,'c'));
    pCap_elec_tpt(pCap_elec_tpt==0) = pCap_elec_ref(pCap_elec_tpt==0);
    pCap_MW_elecref_tpt = sum(delta_Cap_elec_MW_1.*CINV_MW_nexus(:,:)/10^3,'c')./(sum(delta_Cap_elec_MW_1,'c'));
    pCap_MW_elecref_tpt( pCap_MW_elecref_tpt ==0) = pCap_MW_elecref( pCap_MW_elecref_tpt ==0) ;
    csvWrite( pCap_elec_tpt, path_autocal_txCap+'elec/pCap_elec_'+string(nb_sectors)+'.csv');
    csvWrite( pCap_MW_elecref_tpt, path_autocal_txCap+'elec/pCap_MW_elecref_'+string(nb_sectors)+'.csv');
end

//--------------------------------------------------------------------//
//------------------ Calibration : logit intangible costs ------------//
//--------------------------------------------------------------------//

// Autocalibration: Intangible costs for dispatchable power
//the system (with load bands) is non-linear and computing the gradient is quite painful
// there is an infite amount of solution but we to find the one that makes sense economically i.e that maintains the LCOE of the dispatchable power plants within realist bounds to keep these IC while other decreases
// To do that, we impose some constraints on the solution and start from an other point if the solution is not satisfying
// these constaints make sure that the LCOE + IC are not too high or too low, and that the IC are not too high or too low, taking FF techno as references
if auto_calibration_IC_elec==%t  & current_time_im==1
    IC_elec = zeros(reg,n_type_elec);
    //to check that the calibration is working
    sum_test_IC =0;
    for k=1:reg
        // First initial guess for IC based on the observed market shares
        S_obs = market_share_elec(k,:);

        // Calculate the predict msh wo IC
        for band  = tranches_elec
            execstr("MSH_"+band+"_IC = modified_logit([LCC_"+band+"_type(k,:)],gamma_FF_type,ones(1,n_type_elec));")
        end
        MSH = zeros(1,n_type_elec);
        for band = tranches_elec
            execstr("MSH = MSH_"+band+"_IC.*load_band_shares.band_"+band +"(k) + MSH ;")
        end
        S_obs - MSH;
        IC0 = [zeros(1,n_type_elec)];
        // if observed MSH higher than expected, neg IC (-10$/kWh)
        IC0 (find(S_obs > MSH)) = -0.0001;
        // if observed MSH lowr than expected, pos IC (10$/kWh)
        IC0 (find(S_obs < MSH)) = 0.0001;
        // if S_obs == 0, get a very high penalty
        IC0(find(S_obs == 0)) =1;
        // if S_obs close to 0, smaller penalty
        IC0(find(S_obs < 0.01)) = 0.001;

        //if the calibration lead to an undesirable solution, for instance very high/low ICs, we try to start form elsewere 
        j = [find("CoalWOCCS" == techno_dispatch_type),find("GasWOCCS" == techno_dispatch_type),find("Oil" == techno_dispatch_type)];
        ll = [find("Oil" == techno_dispatch_type)];
        test_IC = %f


        //creating a list of IC to start from
        IC0_IC = [IC0;zeros(1,n_type_elec);ones(1,n_type_elec);init_IC *ones(1,n_type_elec);-init_IC *ones(1,n_type_elec);IC0*2;IC0*3;IC0*4;IC0*5;IC0/2;IC0/3];
        iter_IC = 0;
        while test_IC ==%f & iter_IC < size(IC0_IC,1)
            iter_IC = iter_IC + 1;
            IC0_loop = IC0_IC(iter_IC,:);
            // Solve the system, 1e-3 correspond to 1$/kwh of margin, with lower tol convergence is very hard to reach

            [IC_elec(k,:), v,info] = fsolve(IC0_loop, marketShareSystem,tol = 1e-3);
            //While these conditions are not met, continue the loop:
            //these thresholds are arbitrary but they are here to avoid the calibration to go to an extreme solution
            // the sum of FF IC's must be lower than 300$/MWh
            // the sum of LCOE+ICs must be lower than 500$/MWh
            // the sum of LCOE+ICs must be higher than 150$/MWh
            // the LCOE+IC of oil peakers must be higher than 40$/MWh
            test_IC = sum(abs(IC_elec(k,j))) < 0.3 & sum(abs(LCC_8760_type(k,j)+IC_elec(k,j)))< 0.5 & sum(abs(LCC_8760_type(k,j)+IC_elec(k,j))) > 0.15 & (LCC_8760_type(k,ll)+IC_elec(k,ll))>0.04;
            sum_test_IC = sum_test_IC +test_IC ;
        end
    end
    if sum_test_IC<reg
        disp("Calibration of IC failed")
    end
    //Validation of the calibration with processed IC: checking that the solution coincides with observed msh
    for k=1:reg
        if abs(marketShareSystem(IC_elec(k,:)))>tol_IC
            disp("Calibration of IC failed ",k)
        end
    end
    // we are looking to do as must as fine tuning as possible
    // but to ensure that the calibration still makes sense, we finally apply some upper and lower bounds on the IC
    // current calib: -30$/MWh < IC < 50$/MWh
    IC_elec = max(-0.03,min(0.05,IC_elec));
    //exporting
    csvWrite( IC_elec, path_autocal_IC_elec+'IC_elec.csv');
end

//--------------------------------------------------------------------//
//------------------ Calibration : logit share weights ---------------//
//--------------------------------------------------------------------//

//Logit calibration: VRE nest
if run_calib_weights==%t
    weights_VRE_nest = ones(reg,nTechno_VRE);
    for k=1:reg
        [weights_VRE_nest(k,:),v,info] = fsolve(ones(1,nTechno_VRE),find_weights_VRE_nest);
        if info~=1
            error("[weights_VRE_nest(k,:),v,info] = fsolve(ones(1,nTechno_VRE),find_weights_VRE);");
        end
    end
    mkcsv("weights_VRE_nest",path_elec_weights,"nocombi");
end

//computing againt with new LCOEs to get the final MSH
[choice_ind_VRE, MSH_VRE] = VRE_choice_indicator(LCC_ENR, gamma_VRE,weights_VRE_nest);

// Logit calibration: FF_vs_ENR nest
if run_calib_weights==%t
    weights_VRE_FF = ones(reg,2);
    for k=1:reg
        [weights_VRE_FF(k,:),v,info] = fsolve(ones(1,2),find_weights_VRE_FF);
        if info~=1
            error("[weights_VRE_FF(k,:),v,info] = fsolve(ones(1,2),find_weights_VRE_FF);");
        end
    end
    mkcsv("weights_VRE_FF",path_elec_weights,"nocombi");
    pause;
end
