//--------------------------------------------------------------------//
//--------------------------------------------------------------------//
//------ ---------------POWER SECTOR NEXUS ---------------------------//
//-------------Part I: computing expected ideal park -----------------//
//--------------------------------------------------------------------//
//--------------------------------------------------------------------//

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
CRF=disc_rate_elec(:,:,current_time_im)./(1-(1+disc_rate_elec(:,:,current_time_im)).^(-Life_time));

        
    for k=1:reg
        for j=1:techno_elec
            //CINV_MW_nexus(k,j)=(CINV_MW_ITC_ref(j)-A_CINV_MW_ITC_ref(j))*(1-LR_ITC_elec(j))^(log(Cum_Inv_MW_elec(j)/Cum_Inv_MW_elec_ref(j))/log(2))+A_CINV_MW_ITC_ref(j);
            CINV_MW_nexus(k,j)=max((CINV_MW_ITC_ref(k,j))*(1-LR_ITC_elec(j))^(log(Cum_Inv_MW_elec(j)/Cum_Inv_MW_elec_ref(j))/log(2)),A_CINV_MW_ITC_ref(k,j));
            if j==indice_PFC 
                CINV_MW_nexus(k,j)=max((CINV_MW_ITC_ref(j))*(1-LR_ITC_elec(j))^(log((Cum_Inv_MW_elec(indice_PFC)+Cum_Inv_MW_elec(indice_PSS))/Cum_Inv_MW_elec_ref(j))/log(2)),A_CINV_MW_ITC_ref(j));
            end
            if j==indice_ICG 
                CINV_MW_nexus(k,j)=max((CINV_MW_ITC_ref(k,j))*(1-LR_ITC_elec(j))^(log((Cum_Inv_MW_elec(indice_ICG)+Cum_Inv_MW_elec(indice_CGS))/Cum_Inv_MW_elec_ref(j))/log(2)),A_CINV_MW_ITC_ref(k,j));
            end
            if j==indice_GGC 
                CINV_MW_nexus(k,j)=max((CINV_MW_ITC_ref(k,j))*(1-LR_ITC_elec(j))^(log((Cum_Inv_MW_elec(indice_GGC)+Cum_Inv_MW_elec(indice_GGS))/Cum_Inv_MW_elec_ref(j))/log(2)),A_CINV_MW_ITC_ref(k,j)); 
            end
            if j==indice_BIGCC 
                CINV_MW_nexus(k,j)=max((CINV_MW_ITC_ref(k,j))*(1-LR_ITC_elec(j))^(log((Cum_Inv_MW_elec(indice_BIGCC)+Cum_Inv_MW_elec(indice_BIGCCS))/Cum_Inv_MW_elec_ref(j))/log(2)),A_CINV_MW_ITC_ref(k,j)); 
            end
        end
        for j=technoPV //TB: merging CPV and RPV invesments when computing learning
            CINV_MW_nexus(k,j)=max(CINV_MW_ITC_ref(k,j)*(1-LR_ITC_elec(j))^(log((Cum_Inv_MW_elec(indice_CPV)+Cum_Inv_MW_elec(indice_RPV))/(Cum_Inv_MW_elec_ref(indice_CPV)+Cum_Inv_MW_elec_ref(indice_RPV)))/log(2)),A_CINV_MW_ITC_ref(k,j));
        end
    end

    if  current_time_im<5 //2019
        for k=1:reg
            for j = techno_ENRi_endo //loop for years between 2014 and 2019, make 2014 costs linearly converges to 2019 costs from IEA
                CINV_MW_nexus(k,j) = min(CINV_MW_ref(k,j),CINV_MW_ref(k,j) - current_time_im/5*(CINV_MW_ref(k,j)-CINV_MW_2019(k,j)));
                CINV_MW_ITC_ref(k,j) = CINV_MW_nexus(k,j); //TB: so the learning applies to the 2019 costs starting from 2019
                Cum_Inv_MW_elec_ref(j) = Cum_Inv_MW_elec(j); //And take into account the added inv between 2014 and 2019
            end
        end
    end


    //Cas de la séquestration
    CINV_MW_ITC_CCS_PFC=max(CINV_MW_ITC_CCS_PFC_ref*(1-LR_ITC_elec_CCS)^(log(Cum_Inv_MW_elec(indice_PSS)/Cum_Inv_MW_elec_ref(indice_PSS))/log(2)),aCInvMW_ITC_CCS_PFCref);
    CINV_MW_ITC_CCS_UCS=max(CINV_MW_ITC_CCS_UCS_ref*(1-LR_ITC_elec_CCS)^(log(Cum_Inv_MW_elec(indice_UCS)/Cum_Inv_MW_elec_ref(indice_UCS))/log(2)),aCInvMW_ITC_CCS_UCSref);
    CINV_MW_ITC_CCS_ICG=max(CINV_MW_ITC_CCS_ICG_ref*(1-LR_ITC_elec_CCS)^(log((Cum_Inv_MW_elec(indice_CGS)+Cum_Inv_MW_elec(indice_GGS)+Cum_Inv_MW_elec(indice_BIGCCS))/(Cum_Inv_MW_elec_ref(indice_CGS)+Cum_Inv_MW_elec_ref(indice_GGS)+Cum_Inv_MW_elec(indice_BIGCCS)))/log(2)),aCInvMW_ITC_CCS_ICGref);

    CINV_MW_nexus(:,indice_PSS)=CINV_MW_nexus(:,indice_PFC)+CINV_MW_ITC_CCS_PFC*ones(reg,1);
    CINV_MW_nexus(:,indice_UCS)=CINV_MW_nexus(:,indice_UCS)+CINV_MW_ITC_CCS_UCS*ones(reg,1);
    CINV_MW_nexus(:,indice_CGS)=CINV_MW_nexus(:,indice_ICG)+CINV_MW_ITC_CCS_ICG*ones(reg,1);
    CINV_MW_nexus(:,indice_GGS)=CINV_MW_nexus(:,indice_GGC)+CINV_MW_ITC_CCS_ICG*ones(reg,1);
    CINV_MW_nexus(:,indice_BIGCCS)  = CINV_MW_nexus(:,indice_BIGCC) +CINV_MW_ITC_CCS_ICG*ones(reg,1);
    
    for k=1:reg
        for j=1:techno_elec
            OM_cost_var_nexus(k,j)=OM_cost_var_ref(k,j)*CINV_MW_nexus(k,j)/CINV_MW_ITC_ref(j);
            OM_cost_fixed_nexus(k,j)=OM_cost_fixed_ref(k,j)*CINV_MW_nexus(k,j)/CINV_MW_ITC_ref(j);
            //rho_elec_nexus(k,j)=interpln([[CINV_MW_ITC_ref(j),A_CINV_MW_ITC_ref(j)];[rho_elec(k,j,1),rho_elec(k,j,$)]],CINV_MW_nexus(k,j));
            rho_elec_nexus(k,j) = rho_elec(k,j,1); //No more learning on rho
        end
    end



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
    Q_elec_anticip     = zeros(reg,1);

    //linear growth rather than exponential growth. Matches both real data and the model's output: the annual growth rate of electricity demand is decreasing over time

    for k=1:reg 
        if current_time_im==1 //using Qref since Q_prev is not defined yet
            Q_elec_anticip_tot(k)=max((Q(k,indice_elec)+(Q(k,indice_elec)- Qref(k,indice_elec))*nb_year_expect_futur)*(mtoe2mwh),Q_elec_anticip_tot_prev(k));
        else
        Q_elec_anticip_tot(k)=max((Q(k,indice_elec)+(Q(k,indice_elec)- Q_prev(k,indice_elec))*nb_year_expect_futur)*(mtoe2mwh),Q_elec_anticip_tot_prev(k));
        end
    end

    Q_antrec(:,current_time_im)=Q_elec_anticip_tot;
    Q_elec_anticip_tot_prev=Q_elec_anticip_tot;
    /////////////////////////Expectations on FF prices including beliefs about the C price
    ///////////////////////////prix anticipés en $/kWh
    if current_time_im==1
        prod_elec_techno(1:reg,technoBiomass) = 0;
    end


    //Biomass cost
    [costBIGCC_withTax,costBIGCCS_withTax,costBIGCC_noTax,costBIGCCS_noTax,breakEvenTax] = ..
    computeBiomassCost(elecBiomassInitial.supplyCurve,prod_elec_techno(:,technoBiomass),..
    rho_elec_nexus(:,technoBiomass),..
    elecBiomassInitial.emissions,elecBiomassInitial.emissionsCCS,..
    croyance_taxe,taxCO2_CI_ant(indice_agriculture,indice_elec,:),..
    elecBiomassInitial.exogenousBiomassMaxQ,%f,elecBiomassInitial.priceCap);

    p_Coal_anticip     = squeeze(expected.pArmCI       (coal,elec,:,1:Life_time_max_FF)) / tep2kwh ;
    p_Gaz_anticip      = squeeze(expected.pArmCI       (gaz ,elec,:,1:Life_time_max_FF)) / tep2kwh ;
    p_Et_anticip       = squeeze(expected.pArmCI       (et  ,elec,:,1:Life_time_max_FF)) / tep2kwh ;
    p_Coal_anticip_CCS = squeeze(expected.pArmCI_noCTax(coal,elec,:,1:Life_time_max_FF)) / tep2kwh ;
    p_Gaz_anticip_CCS  = squeeze(expected.pArmCI_noCTax(gaz ,elec,:,1:Life_time_max_FF)) / tep2kwh ;


    //Biomass price
    if current_time_im==1
    growth_bioelec_costs = ones(12,1);
    end
    p_biom_antcp_noTax       = costBIGCC_noTax(:,1)    * ones(1,Life_time_max_FF) / tep2kwh;
    p_biom_antcp_CCS_noTax   = costBIGCCS_noTax(:,1)   * ones(1,Life_time_max_FF) / tep2kwh;
    p_biom_antcp_withTax     = costBIGCC_withTax(:,1)  * ones(1,Life_time_max_FF) / tep2kwh;
    p_biom_antcp_CCS_withTax = costBIGCCS_withTax(:,1) * ones(1,Life_time_max_FF) / tep2kwh;


    p_biom_antcp_agg_noTax   = [ p_biom_antcp_noTax(:,1)   p_biom_antcp_CCS_noTax(:,1)   ];     // $/kWh
    p_biom_antcp_agg_withTax = [ p_biom_antcp_withTax(:,1) p_biom_antcp_CCS_withTax(:,1) ]; // $/kWh

    CFuel=zeros(reg,techno_elec);

//For CFuel: fuel costs are discounted to get fuel cost present value. Then the sum is converted into an annualized constant payment with the CRF (annuity factor)
    for k=1:reg
        for j=1:technoCoal
            CFuel(k,j)=0;
            for t=1:Life_time(k,j)
                CFuel(k,j)=CFuel(k,j)+p_Coal_anticip(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
            end
        end    
        for j=technoCoal+1:technoCoal+technoGas
            CFuel(k,j)=0;
            for t=1:Life_time(k,j)
                CFuel(k,j)=CFuel(k,j)+p_Gaz_anticip(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
            end
        end

        for j=technoCoal+technoGas+1:technoFF
            CFuel(k,j)=0;
            for t=1:Life_time(k,j)
                CFuel(k,j)=CFuel(k,j)+p_Et_anticip(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
            end
        end

        for j=technoFF+1:techno_elec
            CFuel(k,j)=0; //Q: what about nuclear power fuel cost?
        end
        /////////////////////////////////////Treating CCS separately: removing the carbon price component from the FF price
        j=indice_PSS;
        CFuel(k,j)=0;
        for t=1:Life_time(k,j)
            CFuel(k,j)=CFuel(k,j)+p_Coal_anticip_CCS(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
        end

        j=indice_CGS;
        CFuel(k,j)=0;
        for t=1:Life_time(k,j)
            CFuel(k,j)=CFuel(k,j)+p_Coal_anticip_CCS(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
        end

        j=indice_GGS;
        CFuel(k,j)=0;
        for t=1:Life_time(k,j)
            CFuel(k,j)=CFuel(k,j)+p_Gaz_anticip_CCS(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
        end
        
        j=indice_UCS;
        CFuel(k,j)=0;   
        for t=1:Life_time(k,j)
            CFuel(k,j)=CFuel(k,j)+p_Gaz_anticip_CCS(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j);
        end

        //Nuclear Fuel costs from IEA & NEA (2020) Projected costs of generating electricity, p.39. Includes front-end + back-end use (2018 USD)
        j=technoElecNuke;
        CFuel(k,j)=((7+2.33)/1000)*CPI_2018_to_2014; //PING_FL

        //biomass
        j=indice_BIGCC;
        CFuel(k,j)=0;
        for t=1:Life_time(k,j)
            CFuel(k,j)=CFuel(k,j)+p_biom_antcp_withTax(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j)+elecBiomassInitial.processCost;
        end
        j=indice_BIGCCS;
        CFuel(k,j)=0;
        for t=1:Life_time(k,j)
            CFuel(k,j)=CFuel(k,j)+p_biom_antcp_CCS_withTax(k,t)/(rho_elec_nexus(k,j)*(1+disc_rate_elec(k,j,current_time_im))^t)*CRF(k,j)+elecBiomassInitial.processCost;
        end
    end




//--------------------------------------------------------------------//
//------------- Market shares for dispatchable technos ---------------//
//--------------------------------------------------------------------//


//LCC = Levelized cost of producing 1 MW during "tranche" hours. The LCC is a LCOE since LCC = Cost of generating electricity/Electricity Generation but for varying call duration.
//The availability factor (AF,for FF) and the capacity factor (CF,for VRE, here CSP only) must be accounted for.We assume that 1 MW of installed cap can produce during AF/CF hours in a year.If the call duration exceeds the AF/CF then extra capacity must be installed to match the 1 MW demand. We assume that outages are planned outside of called hours when the call duration is lower than full load hours.
// The installed capacity must be able to provide 1MW of power during H hours of call duration, such that: X * AF = 1*H <=> X = H/AF
//=> that H/AF of installed cap must be installed to provide an available 1 MW on the call duration.
for tranche = tranches_elec
    for j=1:techno_elec
        execstr("LCC_"+tranche+"(:,j) =  max((ones(reg,1)*"+tranche+")./(avail_factor(:,j)*full_load_hours),ones(reg,1)).*(CINV(:,j)+OM_cost_fixed_nexus(:,j))./"+tranche+" +CFuel(:,j)+OM_cost_var_nexus(:,j);");
    end
    execstr("LCC_"+tranche+"(:,indice_CSP) = max((ones(reg,1)*"+tranche+")./(Load_factor_CSP*10^3),1).*((CINV(:,indice_CSP)+OM_cost_fixed_nexus(:,indice_CSP))./"+tranche+"+CFuel(:,indice_CSP)+OM_cost_var_nexus(:,indice_CSP));") //adding this for CSP as it includes a load/capacity factor constraint. Edited : we consider the average hours of functionning throught the year for CSP: if is lower than the call duration, then 1 MW of CSP does not produce more than Load_factor_CSP*10^3 MWh. Instead, we act like that providing 1 MW during H hours required to install H/(Load_factor_CSP*10^3) MW of CSP
    execstr("LCC_"+tranche+" = max(LCC_" + tranche+",1e-10);");
end


// Limiting biomass with CCS msh growth
if ind_seq_beccs_opt == 1
    for k=1:reg
        execstr ("MSH_"+tranches_elec+"_elec_sup(k,indice_BIGCCS) = min(..
        MSH_limit_newtechno(Tstart_biomass,Tniche_biomass,Tgrowth_biomass,Tmature_biomass,MSHmax_biomass,current_time_im),..
        MSH_"+tranches_elec+"_elec(k,indice_BIGCCS)+elecBiomassInitial.maxGrowthMSH,..
        elecBiomassInitial.MSHBioSup);");
    end
end

execstr ("MSH_"+tranches_elec'+"= zeros(reg,techno_elec);");
mask_HYD=ones(1,nTechnoEndo);
mask_HYD(indice_HYD) = 0;


//FF share weights: giving a weight to split the installed cap by family of technologies, so the global share of coal/gas/nuke does not
//depends onthe # of techno in each family
weights_FF = zeros(reg,techno_elec);
weights_FF(:,technoElecCoal) = 1/(length(technoElecCoal));
weights_FF(:,technoElecGas) = 1/(length(technoElecGas));
weights_FF(:,technoElecNuke) = 1/(length(technoElecNuke));
weights_FF(:,indice_CSP) = 1;
weights_FF(:,technoBiomass) = 1/(length(technoBiomass));


weights_FF(:,technoOil) = 1/(length(technoOil));


mask_hydro_ML = [[repmat([1,1,1,1,1,1,1,1,1,1,1,1,%inf,1,1,1,1,1]',1,reg)]'];

for tranche = tranches_elec
    execstr ("MSH_"+tranche+"_elec = modified_logit(LCC_"+tranche+",gamma_FF,weights_FF);")

end


//Limiting new nuclear design market share
for k=1:reg
    //Definition de MSH_NND_sup
    if Tstart_NND(k)>current_time_im & max(MSH_8760_elec(k,indice_NND),MSH_8030_elec(k,indice_NND),MSH_6570_elec(k,indice_NND),MSH_5110_elec(k,indice_NND),MSH_3650_elec(k,indice_NND),MSH_2190_elec(k,indice_NND),MSH_730_elec(k,indice_NND))>0.01
        if current_time_im>29 then Tstart_NND(k)=current_time_im; end
    end

    MSH_NND_sup(k)=MSH_limit_newtechno(Tstart_NND(k),Tniche_NND(k),Tgrowth_NND(k),Tmature_NND(k),MSHmax_NND(k),current_time_im);
end 

// Caution: the structure is different from MSH_NUC!
MSH_8760_elec_sup(:, indice_NND) = MSH_NND_sup.*[ 0.9,0.9,1,0.9,0.8,0.8,0.8,0.5,0.5,0.5,0.5,0.5]';
MSH_8030_elec_sup(:, indice_NND) = MSH_NND_sup.*[ 0.9,0.9,1,0.9,0.8,0.8,0.8,0.5,0.5,0.5,0.5,0.5]';
MSH_6570_elec_sup(:, indice_NND) = MSH_NND_sup.*[ 0.9,0.9,1,0.9,0.8,0.8,0.8,0.5,0.5,0.5,0.5,0.5]';
MSH_5110_elec_sup(:, indice_NND) = MSH_NND_sup.*[ 0.9,0.9,1,0.9,0.8,0.8,0.8,0.5,0.5,0.5,0.5,0.5]';
MSH_3650_elec_sup(:, indice_NND) = MSH_NND_sup.*[ 0.9,0.9,1,0.9,0.8,0.8,0.8,0.5,0.5,0.5,0.5,0.5]'*1/2;
MSH_2190_elec_sup(:, indice_NND) = MSH_NND_sup.*[ 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]';
MSH_730_elec_sup (:, indice_NND) = MSH_NND_sup.*[ 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]';



if ind_nuc_opt == 0
    for k=1:reg
        execstr ("MSH_"+tranches_elec+"_elec_sup(k,indice_NUC) = 0;");
        execstr ("MSH_"+tranches_elec+"_elec_sup(k,indice_NND) = 0;");
    end
end

// No new Nuclear construciton after 2030
if ind_lim_nuke == 1 & current_time_im >= year_stop_nuclear-base_year_simulation
    for k=1:reg
        execstr ("MSH_"+tranches_elec+"_elec_sup(k,indice_NUC) = max(0, MSH_"+tranches_elec+"_elec_sup(k,indice_NUC) * (6-current_time_im+16-1)/6  );");
        execstr ("MSH_"+tranches_elec+"_elec_sup(k,indice_NND) = max(0, MSH_"+tranches_elec+"_elec_sup(k,indice_NND) * (6-current_time_im+16-1)/6  );");
    end
end

for tranche=tranches_elec
    for j=[indice_PSS,indice_CGS,indice_UCS,indice_GGS]
        execstr ("MSH_"+tranche+"_elec_sup(:,j)=0;");
    end
end

//Constraints on CCS
//Step 1 CCS starts immediately if 1) its ideal share in the mix is not negligeable AND 2) a minimum threshold for the carbon tax is reached
//Step 2 Applying the S curve technology deployment on each techno and tranche.
if ind_seq_opt == 1
    for k=1:reg
        for tranche=tranches_elec
            for j=[indice_PSS,indice_CGS,indice_UCS,indice_GGS]
                //Step 1
                if evstr ("Tstart_CCS_"+tranche+"(k,j)==0 & MSH_"+tranche+"_elec(k,j)>0.001 & max(taxCO2_CI(:,indice_elec,k))>starting_taxCO2_ccs_elec *1e6")
                    execstr ("Tstart_CCS_"+tranche+"(k,j)=current_time_im;");
                end
                //Step 2
                if evstr ("Tstart_CCS_"+tranche+"(k,j)>0")
                    execstr ("MSH_"+tranche+"_elec_sup(k,j)=MSH_limit_newtechno(Tstart_CCS_"+tranche+"("+k+","+j+"),Tniche_CCS_"+tranche+"(k,j),Tgrowth_CCS_"+tranche+"(k,j),Tmature_CCS_"+tranche+"(k,j),MSHmax_"+tranche+"_elec(k,j),current_time_im);");
                end
            end
        end
    end
end

//Step 3
//if the carbon tax is lower than starting_taxCO2_ccs_elec  .1e6 $/tCO2, CCS market shares are null
// => CCS deployment starts after the floor carbon price is reached

for k=1:reg
    if max(taxCO2_CI(:,indice_elec,k)) < starting_taxCO2_ccs_elec  | ind_CCS == 0; //include cases where CCS is not allowed
        for tranche = tranches_elec
            for j=[indice_PSS,indice_CGS,indice_GGS,indice_UCS]
                execstr ("MSH_"+tranche+"_elec_sup(k,j)=0;");
            end
        end
    end
end
for k=1:reg
	if current_time_im <= elecBiomassInitial.startLearningDateBIGCCS
    	if max(taxCO2_CI(:,indice_elec,k)) < starting_taxCO2_ccs_elec  | ind_seq_beccs_opt == 0; //include cases where CCS is not allowed
        	for tranche = tranches_elec
            	for j=[indice_BIGCCS]
                	execstr ("MSH_"+tranche+"_elec_sup(k,j)=0;");
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
            for j=[indice_PSS,indice_CGS,indice_GGS,indice_UCS]
                execstr ("MSH_"+tranche+"_elec_sup(k,j)=0;");
            end
        end
    end
end

// compute max MSH of BIGCCS corresponding to the maximum injection rate, if ind_limCCS_InjRate==1 or 2
if ind_limCCS_InjRate>0 & current_time_im>=start_year_strong_policy-base_year_simulation & current_time_im <= year_stop_CCS_constraint-base_year_simulation

    Cap_BIGCCS_predicted = zeros(reg,1);
    for k=1:reg
        for tranche = tranches_elec
            execstr("Cap_BIGCCS_predicted(k) = Cap_BIGCCS_predicted(k) + MSH_"+tranche+"_elec(k,indice_BIGCCS)* (Cap_"+tranche+"_anticip_MW(k))/(max("+tranche+"/avail_factor(k,indice_BIGCCS)/full_load_hours,1));")
        end
    end
    rho_elec_moyen_BIGCCS = divide( sum(prod_elec_techno(:,indice_BIGCCS) .* rho_elec_moyen(:,indice_BIGCCS)) ,sum(prod_elec_techno(:,indice_BIGCCS) ), rho_elec_moyen(1,indice_BIGCCS));
    max_global_BIGCCS_Cap = max_CCS_injection * rho_elec_moyen_BIGCCS / (-elecBiomassInitial.emissionsCCS / gj2tep /tep2MWh / full_load_hours);
    MSH_BIGCCS_correction = max_global_BIGCCS_Cap ./ sum(Cap_BIGCCS_predicted); // * tep2MWh;
    for k=1:reg
        for tranche = tranches_elec
                execstr ("MSH_"+tranche+"_elec_sup(k,indice_BIGCCS)= min( MSH_"+tranche+"_elec_sup(k,indice_BIGCCS), MSH_"+tranche+"_elec_sup(k,indice_BIGCCS) * MSH_BIGCCS_correction * MSH_BIGCCS_cor_factor);");
        end
    end
end

//Maximum market shares for constrained technologies are expressed in terms of non-intermittent share.
//So market share is constrained at the level of total electricity output and not only the share provided by dispatchable technologies.
//Otherwise it makes little sense to constraint dispatchable techno on dispatchable market share

//The mean increase rate over the period to guess part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur) value before computing it later
//We must anticipate the t+nb_year_expect_futur because we only know the t+nb_year_expect_futur-1 value from previous run
rate_deploy_VRE = (max(part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur-2)./part_ENR_prod_endo(:,current_time_im),1).^(1/(nb_year_expect_futur-2)) -1);

for tranche=tranches_elec
    execstr("MSH_"+tranche+"_elec_sup_disp=zeros(reg,techno_elec)");
    for j=1:techno_elec
execstr("MSH_"+tranche+"_elec_sup_disp(:,j) = min(MSH_"+tranche+"_elec_sup(:,j)./((1-part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur-1)).*(1+rate_deploy_VRE)),1)")
    end
end

//Dispatching MSH to non-constrained technologies

execstr ("MSH_"+tranches_elec+"_elec_new=zeros(MSH_"+tranches_elec+"_elec);");

for k=1:reg
    execstr ("Test_"+tranches_elec+"=MSH_"+tranches_elec+"_elec(k,:)-MSH_"+tranches_elec+"_elec_sup_disp(k,:);");
    execstr ("MSH_"+tranches_elec+"_elec_new(k,Test_"+tranches_elec+">=0)=MSH_"+tranches_elec+"_elec_sup_disp(k,Test_"+tranches_elec+">=0);");
    execstr ("MSH_"+tranches_elec+"_elec_new(k,Test_"+tranches_elec+"<0) =MSH_"+tranches_elec+"_elec    (k,Test_"+tranches_elec+"<0).*(1+sum(Test_"+tranches_elec+"(Test_"+tranches_elec+">=0),"'c'')./sum(MSH_'+tranches_elec+"_elec(k,Test_"+tranches_elec+"<0),"'c''));');
end
execstr ("MSH_"+tranches_elec+"_elec = MSH_"+tranches_elec+"_elec_new;");


//--------------------------------------------------------------------//
//------------- Market shares for non-dispatchable technos -----------//
//--------------------------------------------------------------------//


//Excluding saturated technologies from the multinomial logit. This must be done at each period as some techno can become gradually available
    techno_FF_min = [1:indice_OGC,indice_NUC,indice_NND,indice_BIGCC,indice_BIGCCS]; //added BIGCC (no reason to exclude) and removed CSP (ressource constrained)
    techno_FF_min_reg = list();
    for k = 1:reg
        techno_FF_min_reg(k) = techno_FF_min;
    end



//Each period, removes the saturated technos from the FF/VRE investment decision

for k=1:reg
    for i = [1:indice_OGC,indice_NUC,indice_NND,indice_BIGCC,indice_BIGCCS] 
        //if ~( (ind_lim_nuke == 1 & current_time_im >= year_stop_nuclear-base_year_simulation & current_time_im <= year_stop_nuclear-base_year_simulation+time_toremove_NUC_2) & ((i==indice_NUC)|(i==indice_NND)))
        if ~( (ind_lim_nuke == 1 & current_time_im >= year_stop_nuclear-base_year_simulation) & ((i==indice_NUC)|(i==indice_NND)))
            if MSH_8760_elec(k,i) == MSH_8760_elec_sup_disp(k,i)
                techno_FF_min_reg(k) =  remove_saturated_techno(techno_FF_min_reg(k),[1:indice_OGC,indice_NUC,indice_NND,indice_BIGCC,indice_BIGCCS],i);
            end
        end
    end
end

if ind_lim_nuke == 1 & current_time_im >= year_stop_nuclear-base_year_simulation & current_time_im <= year_stop_nuclear-base_year_simulation+time_toremove_NUC_2
    for k=1:reg
    list_non_nuke=[];
    for i=techno_FF_min_reg(k)
        if i<>indice_NUC & i<>indice_NND
            list_non_nuke = [list_non_nuke,i];
        end
    end
    //LCC_8760(k,indice_NUC) = LCC_8760(k,indice_NUC) + ( min(LCC_8760(k,list_non_nuke)) - LCC_8760(k,indice_NUC)) * (current_time_im-year_stop_nuclear+base_year_simulation)/time_toremove_NUC_2;
    //LCC_8760(k,indice_NND) = LCC_8760(k,indice_NND) + ( min(LCC_8760(k,list_non_nuke)) - LCC_8760(k,indice_NND)) * (current_time_im-year_stop_nuclear+base_year_simulation)/time_toremove_NUC_2;
    //LCC_8760(k,indice_NUC) = LCC_8760(k,indice_NUC) + max(0,( min(LCC_8760(k,list_non_nuke)) - LCC_8760(k,indice_NUC))) * (current_time_im-year_stop_nuclear+base_year_simulation)/time_toremove_NUC;
    //LCC_8760(k,indice_NND) = LCC_8760(k,indice_NND) + max(0,( min(LCC_8760(k,list_non_nuke)) - LCC_8760(k,indice_NND))) * (current_time_im-year_stop_nuclear+base_year_simulation)/time_toremove_NUC;
    LCC_8760(k,indice_NUC) = LCC_8760(k,indice_NUC) ;//+ max(0,( min(LCC_8760(k,list_non_nuke)) - LCC_8760(k,indice_NUC))) * (current_time_im-year_stop_nuclear+base_year_simulation)/time_toremove_NUC;
    LCC_8760(k,indice_NND) = LCC_8760(k,indice_NND) ;//+ max(0,( min(LCC_8760(k,list_non_nuke)) - LCC_8760(k,indice_NND))) * (current_time_im-year_stop_nuclear+base_year_simulation)/time_toremove_NUC;
    end
end

//Computing the central logit argument for FF
//To avoid occillations when a techno is saturated from an year to an other, we add inertia(inert_LCOE). The central planner incorporates gradually (here, it takes 2 years) the constraint 
// dispatchable technologies. This also ensures that we do not jump suddenly in the multinomial logit, that's being nice with the fsolve...
for k=1:reg
    if current_time_im==1
        LCC_FF_min(k)=min(LCC_8760(k,techno_FF_min_reg(k)));
    end
    if (ind_lim_nuke==0 & current_time_im<start_year_strong_policy-base_year_simulation) | (ind_lim_nuke == 1 & current_time_im < year_stop_nuclear-base_year_simulation)
        LCC_FF_min_prev_prev = LCC_FF_min_prev;
        LCC_FF_min_prev = LCC_FF_min;
    else
        LCC_FF_min_prev_prev(k) = LCC_FF_min_prev(k);
        LCC_FF_min_prev(k) = LCC_FF_min(k);
    end    

    if current_time_im==2
        LCC_FF_min(k)=inert_LCOE*(min(LCC_8760(k,techno_FF_min_reg(k))))+(1-(inert_LCOE))*LCC_FF_min_prev(k);
    end
    if current_time_im>2
        LCC_FF_min(k)=inert_LCOE*(min(LCC_8760(k,techno_FF_min_reg(k))))+((1-inert_LCOE)/2)*LCC_FF_min_prev(k)+((1-inert_LCOE)/2)*LCC_FF_min_prev_prev(k);
    end
end

//The share weights are calibrated as base year to fit actual VRE share data. We are making share weight converge to equal share to 2030, meaning that technologies only compete based
// on their mesured LCOE. Factors outside pure costs of techno are progressively eliminated 
if current_time_im <= Convergence_horizon & current_time_im > target_year //corresponds to 2018 - 2030 years for which we make share weights converge to 1:1 parity
for k=1:reg
        weights_ENR(k,2:nbTechFFENR) = weights_ENR_hist(k,2:nbTechFFENR) + ((current_time_im-target_year)/(Convergence_horizon-target_year))*((1/nbTechExoAbsUsed)-weights_ENR_hist(k,2:nbTechFFENR));
end
end

//------------------------------------------------------------------//
end //end of ind_first_run_elec == 1 if condition
//------------------------------------------------------------------//

//New variable renewable market shares

LCC_ENR=(CINV(:,technoExo)+OM_cost_fixed(:,technoExo,current_time_im))./((Load_factor_ENR(:,technoExo_absolute)*th_to_h+%eps)./(1+curt_VRE))+OM_cost_var(:,technoExo,current_time_im) + Markup_LCC_SIC;
total_curt = zeros(reg,1); //try to reset curtailment
//Test TB

if ind_lim_nuke == 1 & current_time_im >= year_stop_nuclear-base_year_simulation
  dichot_param=20;
else
  dichot_param=1;
end

output_Net_VRE = [LCC_ENR(:,[technoWindAbsolute,technoPVAbsolute]),total_curt];
for i=linspace(0,1,dichot_param)
   LCC_FF_min_fct= i*LCC_FF_min + (1-i)*LCC_FF_min_prev;
   info=4;
   nb_try=0;
   while (info<>1 & nb_try<10)
     nb_try=nb_try+1;
     [output_Net_VRE,v,info] = fsolve( output_Net_VRE,find_net_LCOE_VRE);
   end
   if info~=1
     error("[output_Net_VRE,v,info] = fsolve([LCC_ENR(:,[technoWindAbsolute,technoPVAbsolute]),total_curt],find_net_LCOE_VRE)");
   end 
end

LCC_ENR(:,VarRenew_ENR) = output_Net_VRE(:,1:4);
share_FF_ENR = modified_logit([LCC_FF_min, LCC_ENR(:,VarRenew_ENR)],gamma_FF_ENR,weights_ENR);

total_curt=output_Net_VRE(:,5);
total_curt_VRE = total_curt./sum(share_FF_ENR(:,technoENRi_vs_FF),"c");

//This is our main hypothesis for curtailment shares on wind and solar PV. We do not posses the information of how much curtailment is due to solar / wind. If we do not use weights on PV/Wind, we assume that the curtailed share is the same for wind and PV, which is not true. These weights must be set with more care. The ratio can be calibrated using 
w_wind_curt = beta_wd*sum(share_FF_ENR(:,technoWind_ENR_vs_FF),"c")./(alpha_pv*sum(share_FF_ENR(:,technoPV_ENR_vs_FF),"c")+beta_wd*sum(share_FF_ENR(:,technoWind_ENR_vs_FF),"c"));
w_pv_curt = alpha_pv*sum(share_FF_ENR(:,technoPV_ENR_vs_FF),"c")./(alpha_pv*sum(share_FF_ENR(:,technoPV_ENR_vs_FF),"c")+beta_wd*sum(share_FF_ENR(:,technoWind_ENR_vs_FF),"c"));

curt_rate_wind = total_curt_VRE.*w_wind_curt./(sum(share_FF_ENR(:,technoWind_ENR_vs_FF),"c")./sum(share_FF_ENR(:,technoENRi_vs_FF),"c"));
curt_rate_pv = total_curt_VRE.*w_pv_curt./(sum(share_FF_ENR(:,technoPV_ENR_vs_FF),"c")./sum(share_FF_ENR(:,technoENRi_vs_FF),"c"));

//Compute the VRE markup for flexiblity
for j=technoPVAbsolute
    Markup_LCC_SIC(:,j) = Markup_pv(sum(share_FF_ENR(:,technoPV_ENR_vs_FF),"c"),sum(share_FF_ENR(:,technoWind_ENR_vs_FF),"c"));
end

for j=technoWindAbsolute
    Markup_LCC_SIC(:,j) = Markup_wind(sum(share_FF_ENR(:,technoPV_ENR_vs_FF),"c"),sum(share_FF_ENR(:,technoWind_ENR_vs_FF),"c"));
end


//We need to get back curtailment as a PV/wind share to compute Levelized Cost of net generated Electricity
curt_VRE(:,technoWindAbsolute) = repmat(curt_rate_wind,1,length(technoWindAbsolute));
curt_VRE(:,technoPVAbsolute) = repmat(curt_rate_pv,1,length(technoPVAbsolute));

LCOE_VRE_net=(CINV(:,technoExo)+OM_cost_fixed(:,technoExo,current_time_im))./((Load_factor_ENR(:,technoExo_absolute)*th_to_h+%eps)./(1+curt_VRE))+OM_cost_var(:,technoExo,current_time_im) + Markup_LCC_SIC;

 //Check LCOE_VRE_net(:,VarRenew_ENR)-LCC_ENR(:,[technoWindAbsolute,technoPVAbsolute]). Seems to work well

//Gross and net VRE shares as a share of annual demand
Gross_VRE_share_wind = share_FF_ENR(:,technoWind_ENR_vs_FF) + repmat(curt_rate_wind,1,length(technoWind_ENR_vs_FF)).* (share_FF_ENR(:,technoWind_ENR_vs_FF)) ;
Gross_VRE_share_pv = share_FF_ENR(:,technoPV_ENR_vs_FF) + repmat(curt_rate_pv,1,length(technoPV_ENR_vs_FF)).* (share_FF_ENR(:,technoPV_ENR_vs_FF)) ;

//Total net VRE share in the ideal mix
part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur) = sum(share_FF_ENR(:,technoENRi_vs_FF),"c");

//between t = 0 and t=10 the variable part_ENR_prod_endo is not computed. For t=1, we take the t+10 estimate and use a linear approximation between t = 0 (= reference year share) and t=10. There are 11 years (current_time_im+nb_year_expect_futur if current_time_im = 1) between year 0 and year 10
if current_time_im ==1
part_ENR_prod_endo(:,current_time_im) = max((1-current_time_im/(current_time_im+nb_year_expect_futur))*sum((Load_factor_ENR(:,VarRenew_ENR)*1000).*Cap_elec_MWref(:,techno_ENRi_endo),"c")./(Qref(:,indice_elec)*(mtoe2mwh)) + current_time_im/(current_time_im+nb_year_expect_futur) * part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur),sum((Load_factor_ENR(:,VarRenew_ENR)*1000).*Cap_elec_MWref(:,techno_ENRi_endo)./repmat((Qref(:,indice_elec)*mtoe2mwh),1,nbTechExoAbsUsed),"c")); 
//+ prevent from decreasing share of VRE with max. Due to the fact that Q(:,elec) does not necessarely corresponds to the electricity demand from IRENA, from which come Cap_elec_MWref
end 
for j=1:nb_year_expect_futur
    part_ENR_prod_endo(:,current_time_im+j) = part_ENR_prod_endo(:,current_time_im) + (j/nb_year_expect_futur)*(part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur) - part_ENR_prod_endo(:,current_time_im));
end


part_ENR_prod_anticip=part_ENR_prod_endo(:,current_time_im+nb_year_expect_futur);



//TB: Weights calibration. Requires an existing weights_ENR.tsv file, must be fixed to the file can be created if it does not exists yet
 if  run_calib_weights == %t
     if current_time_im ==1 


    for k = 1:reg 
        [weights_ENR(k,2:nbTechFFENR),v,info] = fsolve(weights_ENR(k,2:nbTechFFENR),find_weights_ENR);
        if info~=1
            error("[markup_SIC,v,info] = fsolve(weights_ENR(:,2:nbTechFFENR),find_weights_ENR);");
        end 
    end

    if ind_logit_sensib_VRE
        execstr("weights_ENR_"+gamma_FF_ENR+" = weights_ENR")
        mkcsv("weights_ENR"+"_"+gamma_FF_ENR,path_elec_weights,"nocombi");
    else
        mkcsv("weights_ENR",path_elec_weights,"nocombi");
    end
    pause
end
end


//--------------------------------------------------------------------//
//------------- Residual load curve ----------------------------------//
//--------------------------------------------------------------------//


//Calcul de l'anticipation de l'énergie produite à t+nb_year_expect_futur par le parc conventionel
Q_elec_anticip=Q_elec_anticip_tot.*(1-part_ENR_prod_anticip);
//Calcul de l'anticipation de l'énergie produite à t+nb_year_expect_futur par le parc ENR
Q_elec_ENR_anticip=Q_elec_anticip_tot.*(part_ENR_prod_anticip);


/////////////test modif pour prendre en compte dans la prévision la sur-utilisation des capacité
//for k=1:reg
  //  if charge(k,indice_elec)>0.8
  //      delta_Q_elec_charge=Q(k,indice_elec)/0.8-Cap(k,indice_elec);
  //      Q_elec_anticip(k)=Q_elec_anticip(k)+delta_Q_elec_charge*mtoe2mwh;
  //  end
//end


//Total peak and baseload anticipation
peak_W_anticip_tot = Q_elec_anticip_tot./(bp_ratio*full_load_hours + facteur_t*(1-bp_ratio));
base_W_anticip_tot = bp_ratio.*peak_W_anticip_tot;
delta_W_anticip_tot = peak_W_anticip_tot-base_W_anticip_tot;

//Resdiual Load Duration Curve design
// Inspired from ADVANCE project, using ADVANCE outputs (DIMES BU model)
//From DIMES outputs, we extract a relationship between (gross) solar/wind shares and residual peak load
//We perform polynomial fit (3rd order polynom) to get the best estimate of the residual peakload based on solar PV & wind (offshore + onshore) 
//See 10.1016/j.eneco.2016.05.012 for method

RLDC_peak_ant = find_RLDC_peak([Gross_VRE_share_wind,Gross_VRE_share_pv]);
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

for k=1:reg
    if base_W_anticip(k)<0
base_W_anticip_8030(k) = (Q_elec_anticip(k) - peak_W_anticip(k)*((6570+5110+3650+2190+730)/5))/(8030-(6570+5110+3650+2190+730)/5);
    end
end

//this loop does exactly was the previous code lines are doing for the remaining time slices (6570 : 730)
for k=1:reg
    tranches_elec_num=strtod(tranches_elec);
    tranches_wo_base_num=tranches_elec_num(2:7);
    tranches_wo_base=tranches_elec(2:7);
    for tranche = tranches_wo_base
        row = grep(tranches_wo_base,tranche);
        if evstr("base_W_anticip_"+tranches_wo_base(row)+"(k)<0")&row<5
        nb_tranche_wo_base = nb_tranches_elec-2-row;
        execstr("base_W_anticip_"+tranches_wo_base(row+1)+"(k) = (Q_elec_anticip(k) - peak_W_anticip(k)*(sum(tranches_wo_base_num(row+2:$))/nb_tranche_wo_base))/(tranches_wo_base_num(row+1)-(sum(tranches_wo_base_num(row+2:$)))/nb_tranche_wo_base)")
    elseif evstr("base_W_anticip_"+tranches_wo_base(row)+"(k)<0") & row==5  // In case where there is not enought residual load to derive two load bands
        //or when the RLDC function yields negative values from the peak load
        //The single load band is a peak load band 
                base_W_anticip_730(k) = 0;
                peak_W_anticip(k)= Q_elec_anticip(k)/730;
        end
    end
end



////////////////////Removing hydro production from baseload, and upper load bands if necessary

// This is always true: if base_W_anticip = 0 we set Cap_8760_anticip_MW(k) to 0

for tranche = tranches_elec
    execstr("Cap_"+tranche+"_anticip_MW = zeros(reg,1);")
end



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

///////////////////////////////Reserve margin requirement/capacity market
// This shall replace the 80% utilization rate target in the electricity sector. Talking about reserve margin or capacity markets is way more meaningful and realistic. As a first order approximation, we arbitrary increase bt reserve_margin % the anticipated residual peak load to account for electricity system contingency

//Once we have removed hydropower we add the reserve margin. 
//This way we assume hydro does not participate the capacity market due to very low variable costs
//Thus, we still may check what's happening in scenario with very high renewable shares (does the reserve margin still apply?)
//in order to not invest while there is unused capacity of dispatchable plants, we would like to make the reserve margin dependant on
// the current availability factor of conventionnal plants.


//Cap_730_anticip_MW=Cap_730_anticip_MW*(1+reserve_margin); 


//--------------------------------------------------------------------//
//-----Ideal installed park from optimal market shares ---------------//
//--------------------------------------------------------------------//

//From available to installed capacities. We assume that outages are schedule out of call periods.

//On each load band and for each techno, we compare the required availability factor tranches_elec/FLH with the actual availability factor. If a plant of 1MW is called 100% of the year with an AF of 90%, then the installed capacity must be of 1MW*100/90 = 1.111MW (with a 90% AF then 1.1111MW can provide in average a power of 1MW).
//We then assume for lower load bands that planned outages happen when demand is low => if the AF is 90% but the plant is called 50% of the time, then the AF become 1 on call duration.
Cap_elec_MW_exp_inst = zeros(reg,techno_elec);
for k=1:reg
    for j=1:techno_elec
        for tranche = tranches_elec
    execstr("Cap_elec_MW_exp_inst(k,j) = Cap_elec_MW_exp_inst(k,j) + MSH_"+tranche+"_elec(k,j)* (Cap_"+tranche+"_anticip_MW(k))/(max("+tranche+"/avail_factor(k,j)/full_load_hours,1));")
    end
    end
end



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
       Cap_depreciated_10(k,j)=sum(Cap_elec_MW_vintage(j,current_time_im+10+Life_time_max-Life_time(k,j)+1:current_time_im+Life_time_max,k));
    end
end
////////Comparing the optimal capacity with the remaining capacity at time t+10, which gives the needed investment over the the period to reach to optimal value.

delta_Cap_elec_MW=(Cap_elec_MW_exp_inst-Cap_depreciated_10);



// Introducing sequential decision making in the investment decision
// the investment decision looks at a 10y decision horizon, but is reassessed every dur_seq_inv_elec year rather than every year. This is to avoid too much volatility in the investment decision and mimic the fact that investment decisions are not taken every year in reality
// This also yields 
// the variable delta_Cap_elec_MW is rename in the inv & dispatch script into delta_Cap_elec_MW_1. delta_Cap_elec_MW_1 is the delta capacity to be installed over dur_seq_inv_elec years.

if modulo(current_time_im-1,dur_seq_inv_elec)==0 //investment decision is taken every dur_seq_inv_elec years

    //delta_Cap_elec_MW_1 is set to zero if negative investment (no early decommissining)
    delta_Cap_elec_MW=max(delta_Cap_elec_MW,0)*dur_seq_inv_elec/nb_year_expect_futur;

    //Hydro inv is exogenous
    delta_Cap_elec_MW(:,indice_HYD)=0;

    // peak load coverage: is the installed capacity sufficient to cover the peak load? and not too much?
    for k=1:reg
    delta_Cap_elec_MW(k,[technoFossilWOCCS, technoElecNuke,technoElecHydro,indice_CSP,indice_BIGCC]) = delta_Cap_elec_MW(k,[technoFossilWOCCS, technoElecNuke,technoElecHydro,indice_CSP,indice_BIGCC])* peak_cov_calibration(residual_peak_cov(k),res_param);
    end


    Cap_ENR_MW_anticip=zeros(reg,technoENR);
    Inv_MW_techno_ENR=zeros(reg,technoENR);

    //share_Cap_ENR is now computed as a share of VRE total production. Dividing the total production by VRE techno by the hours of functionning yields the needed installed cap
    Cap_ENR_MW_anticip(:,VarRenew_ENR) = repmat(Q_elec_anticip_tot,1,length(techno_ENRi_endo)).*share_FF_ENR(:,technoENRi_vs_FF)./(10^3*(Load_factor_ENR(:,VarRenew_ENR))./(1+curt_VRE(:,VarRenew_ENR)));


    for j=technoExo_absolute
        for k=1:reg
            Inv_MW_techno_ENR(k,j)=(Cap_ENR_MW_anticip(k,j)-Cap_depreciated_10(k,technoConv+j))*dur_seq_inv_elec/nb_year_expect_futur;
        end
    end
    
        Inv_MW_techno_ENR = max(Inv_MW_techno_ENR,0)/dur_seq_inv_elec; //annual investment schedule
        Inv_MW_techno_ENR_seq = Inv_MW_techno_ENR; //introducing this intermediate variable because Inv_MW_techno_ENR gets modified in the inv & dispatch script.


    //--------------------------------------------------------------------//
    //-----Final investment for period t ---------------------------------//
    //--------------------------------------------------------------------//
    delta_Cap_elec_MW_1 = delta_Cap_elec_MW/dur_seq_inv_elec; // resizing delta cap so its corresponding to the annual investment schedule

    Inv_MW=zeros(reg,techno_elec);
    Inv_MW=delta_Cap_elec_MW_1; 
    //hydro is treated separately
    Inv_MW(:,technoConv+1:techno_elec) = Inv_MW_techno_ENR_seq;
    Inv_MW(:,technoBiomass) = delta_Cap_elec_MW_1(:,technoBiomass)/dur_seq_inv_elec;

    Inv_MW_seq = Inv_MW; //introducing this intermediate variable because Inv_MW gets modified in the inv & dispatch script. Inv_MW_seq is computed only every dur_seq_inv_elec years.
end
    

//so we now have the same inv for dur_seq_inv_elec years
//some variables need to be loaded between years during which investment schedule is reassessed, because they get modified in the nexus.electricity.realInvestment.sce script
Inv_MW = Inv_MW_seq;
Inv_MW_techno_ENR = Inv_MW_techno_ENR_seq;

// and hydro inv is made on a annual basis (exogenous)
Inv_MW_hydro=zeros(reg,1);
for k=1:reg
    Inv_MW_hydro(k)=Cap_hydro(k,current_time_im+1)-Cap_elec_MW_dep(k,indice_HYD);//for hydro we already know t+1 needs since this is exogenous
end

Inv_MW_hydro=max(Inv_MW_hydro,0);
Inv_val_Hydro=Inv_MW_hydro.*CINV_MW_nexus(:,indice_HYD)/1e3;

Inv_MW(:,indice_HYD)=Inv_MW_hydro;



///////////////////////////////////////////the price of capital varies with investments
pCap_MW_elec=sum(Inv_MW.*CINV_MW_nexus(:,:)/10^3,"c")./sum(Inv_MW,"c");

for k=1:reg
    Beta(:,indice_elec,k)=pCap_MW_elec(k)/pCap_MW_elecref(k)*Betaref(:,indice_elec,k);
end

if current_time_im==year_calib_txCaptemp & auto_calibration_txCap<>"None"
    txCap_elec = (sum(Cap_elec_MW_dep+delta_Cap_elec_MW_1,'c')./sum(Cap_elec_MWref,'c')) .^ (1. /current_time_im) -1;
    inert_txCap_elec = inert_temp;
    txCaptemp_elec = inert_txCap_elec*txCap(:,indice_elec) + (1-inert_txCap_elec)*txCap_elec;
    disp(txCaptemp_elec,"txCaptemp_elec")
    csvWrite( txCap_elec, path_autocalibration+'elec/txCaptemp_elec_'+string(nb_sectors)+'.csv');
    //other
    deltaKbrut_elec = sum(delta_Cap_elec_MW_1,'c').*Capref(:,indice_elec)./sum(Cap_elec_MWref,'c');
    csvWrite( deltaKbrut_elec, path_autocalibration+'elec/deltaKbrut_elec_'+string(nb_sectors)+'.csv');
    pCap_elec = sum(delta_Cap_elec_MW_1.*CINV_MW(:,:,current_time_im)/10^3,'c')./(sum(delta_Cap_elec_MW_1,'c').*Capref(:,indice_elec)./sum(Cap_elec_MWref,'c'));
    csvWrite( pCap_elec, path_autocalibration+'elec/pCap_elec_'+string(nb_sectors)+'.csv');
    pCap_MW_elecref = sum(delta_Cap_elec_MW_1.*CINV_MW(:,:,current_time_im)/10^3,'c')./(sum(delta_Cap_elec_MW_1,'c'));
    csvWrite( pCap_MW_elecref, path_autocalibration+'elec/pCap_MW_elecref_'+string(nb_sectors)+'.csv');
end
