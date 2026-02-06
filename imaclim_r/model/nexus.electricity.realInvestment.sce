// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thibault Briera, Ruben Bibas, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================



//--------------------------------------------------------------------//
//--------------------------------------------------------------------//
//------ ---------------POWER SECTOR NEXUS ---------------------------//
//- Part II: investment, dispatch and costs of generating electricity-//
//--------------------------------------------------------------------//
//--------------------------------------------------------------------//

//Table of contents

//0. Init

//1. Investment and updated capital characteristics

//2. Residual load duration curve

//3. Fuel costs, merit order and dispatch 

//4. VRE production

//5. Cost of electricity generation and electricy IC update


//--------------------------------------------------------------------//
//----------------------------- Investment ---------------------------//
//--------------------------------------------------------------------//

// Chunk of code to minimize the distance between ideal and effective investment
if calib_profile_cost == 1
    Inv_val_sec(:,indice_elec)= %inf*ones(reg,1); // allowing full investment if calibrating profile costs
end

Inv_val_elec=Inv_val_sec(:,indice_elec);

Inv_MW_hydro=zeros(reg,1);
//Hydro investment
for k=1:reg
    Inv_MW_hydro(k)=Cap_hydro(k,current_time_im+1)-Cap_elec_MW_dep(k,indice_HYD);
end

//Hydro is prioritised
Inv_MW_hydro=min(Inv_val_elec./(CINV_MW_nexus(:,indice_HYD)/10^3),max(Inv_MW_hydro,0));

//Investment value to hydro
Inv_val_Hydro=Inv_MW_hydro.*CINV_MW_nexus(:,indice_HYD)/10^3;

//Same for VRE + biomass&CCS (which is j=8 in relative indices) + storage
Inv_val_BioCCS = zeros(reg,1);
for j=techno_VRE_absolute
    tech=techno_VRE(j);
    for k=1:reg
        Inv_val_ENR(k,j)=Inv_MW_techno_ENR(k,j)*CINV_MW_nexus(k,tech)/10^3;
    end
end

Inv_val_Stor = Inv_MW(:,indice_STR).* CINV_MW_nexus(:,indice_STR) / 10^3;
Inv_MW_Stor = Inv_MW(:,indice_STR);
Inv_MW_BioCCS = Inv_MW(:,indice_BIS);
Inv_val_BioCCS=Inv_MW_BioCCS.*CINV_MW_nexus(:,indice_BIS)/10^3;

//After hydro comes VRE invesments in order of priority
for k=1:reg
    if (sum(Inv_val_ENR(k,:))+Inv_val_BioCCS(k)+ Inv_val_Stor(k))>(Inv_val_elec(k)-Inv_val_Hydro(k))
        disp("shortage invest ENR in region "+k);

        if sum(Inv_val_ENR(k,:))>0
            Inv_MW_techno_ENR(k,:)=Inv_MW_techno_ENR(k,:)*(Inv_val_elec(k)-Inv_val_Hydro(k))/(sum(Inv_val_ENR(k,:)+Inv_val_BioCCS(k)));
            Inv_MW_BioCCS(k) = Inv_MW_BioCCS(k)*(Inv_val_elec(k)-Inv_val_Hydro(k))/(sum(Inv_val_ENR(k,:)+Inv_val_BioCCS(k)));
            Inv_MW_Stor(k) = Inv_MW_Stor(k)*(Inv_val_elec(k)-Inv_val_Hydro(k))/(sum(Inv_val_ENR(k,:)+Inv_val_BioCCS(k) + Inv_val_Stor(k)));
        else
            Inv_MW_techno_ENR(k,:)=0*Inv_MW_techno_ENR(k,:);
        end
        for j=techno_VRE_absolute
            tech=techno_VRE(j);
            Inv_val_ENR(k,j)=Inv_MW_techno_ENR(k,j)*CINV_MW_nexus(k,tech)/10^3;
        end
        Inv_val_BioCCS(k)=Inv_MW_BioCCS(k).*CINV_MW_nexus(k,indice_BIS)/10^3;
    end
end

//Cash left after hydro and VRE inv
Inv_val_elec_res=Inv_val_elec-Inv_val_Hydro-sum(Inv_val_ENR,"c") - Inv_val_BioCCS - Inv_val_Stor;
Inv_MW=zeros(reg,techno_elec);
Inv_cost_elec=zeros(reg,1);
masc_elec=ones(reg,techno_elec);

//removing BIGCCS from the list of technologies to invest in (since it has been prioritized and remove from the loop)
delta_Cap_elec_MW_1(:,indice_BIS)=0;
//the remaining capital is used to fulfill inv in conventionnal power

for k=1:reg

    if sum(delta_Cap_elec_MW_1(k,:))>0   //any investment need remaining?

        //monetary value of the conventionnal investment need
        Inv_cost_elec(k)=sum(delta_Cap_elec_MW_1(k,techno_dispatchable).*CINV_MW_nexus(k,techno_dispatchable)/10^3);

        Inv_val_elec_need_diff = Inv_val_elec_res(k)-Inv_cost_elec(k);
        Inv_val_elec_need_diff = round(Inv_val_elec_need_diff*1e11)*1e-11;
        Inv_val_elec_res(k) =  Inv_val_elec_need_diff + Inv_cost_elec(k);

        if Inv_val_elec_need_diff>=0 //abs(Inv_val_elec_res(k)-Inv_cost_elec(k))>=%eps
           
            //Inv_MW(k,techno_dispatchable)=delta_Cap_elec_MW_1(k,techno_dispatchable)+delta_Cap_elec_MW_1(k,techno_dispatchable)/sum(delta_Cap_elec_MW_1(k,techno_dispatchable)+3*%eps)*(Inv_val_elec_res(k)-Inv_cost_elec(k))./(CINV_MW_nexus(k,techno_dispatchable)/10^3);
            Inv_MW(k,techno_dispatchable)=delta_Cap_elec_MW_1(k,techno_dispatchable);
        elseif Inv_val_elec_res(k) < 0
            Inv_MW(k,techno_dispatchable) = 0;
        else //If not enough cash to finance the investment, the distance between the ideal and actual investment need (in MW) is minimized.
            //Inv_val_elec_res(k) = max( Inv_val_elec_res(k),500);
            //Investment allocation in M$ to minimize the distance between investment need and actual inv in MW
            //using built-in function quapro to solve (in x):  
            //min(x'*Q_elec_quapro*x+p_elec_quapro'*x) , thus min (x'*x)
            //under the constraint C_elec_quapro*x=b_elec_quapro and ci_elec_quapro<=x<=cs_elec_quapro
            //définition de la matrice diagonale Q_elec_quapro pour la forme quadratique
            //Defining the diagonal matrix Q_elec_quapro for the quadratic form
            Q_elec_quapro=eye(nTechno_dispatch,nTechno_dispatch);
            //Capital cost for each tech
            prix_elec_quapro=CINV_MW_nexus(k,techno_dispatchable)/10^3;
            //cash contraint
            Inv_elec_quapro=Inv_val_elec_res(k);
            //ideal investment 
            x0_elec_quapro=delta_Cap_elec_MW_1(k,techno_dispatchable)';
            //linear constraint in the min problem
            p_elec_quapro=zeros(nTechno_dispatch,1);
            //matrix of linear constraints
            C_elec_quapro=zeros(nTechno_dispatch,nTechno_dispatch);
            //initialization of capital costs
            C_elec_quapro(1,:)=prix_elec_quapro;
            // left hand side constraint
            b_elec_quapro=zeros(nTechno_dispatch,1);
            //Constaint on the total investment cost
            b_elec_quapro(1)=Inv_elec_quapro-prix_elec_quapro*x0_elec_quapro;
            //Lower bound on x
            ci_elec_quapro=-x0_elec_quapro;
            //Upper bound on x
            cs_elec_quapro=number_properties("huge")*ones(nTechno_dispatch,1);
            // Setting investment in hydro at 0 (exogenous invesment that is prioritary)
            // Only if the problem can be solved by reducing other investment
            if prix_elec_quapro*x0_elec_quapro - delta_Cap_elec_MW_1(k,13) * CINV_MW_nexus(k,13)/10^3 + b_elec_quapro(1)  >= 0
                ci_elec_quapro(indice_HYD)=0;
            end
            //les deux premières contraintes sont d'égalité
            me_elec_quapro=1;

            notdone_elec_quapro=%t; count_elec_quapro = 0;

            //This loop is due to some qld function error
            while notdone_elec_quapro
                try
                    x_elec_quapro=qld(Q_elec_quapro,p_elec_quapro,C_elec_quapro,b_elec_quapro,ci_elec_quapro,cs_elec_quapro,me_elec_quapro);
                    notdone_elec_quapro=%f;
                catch
                    if metaRecMessOn
                        disp("qld failed. using qpsolve"+count_elec_quapro);
                    end
                    try
                        x_elec_quapro=qpsolve(Q_elec_quapro,p_elec_quapro,C_elec_quapro,b_elec_quapro,ci_elec_quapro,cs_elec_quapro,me_elec_quapro);
                        notdone_elec_quapro = %f;
                    catch
                    end
                end
                b_elec_quapro(1) = b_elec_quapro(1) *1.1;
                count_elec_quapro = count_elec_quapro+1;
                if count_elec_quapro==30
                    disp "qpsolve failed in electricity nexus"
                    mkalert "error"
                    pause;
                end
            end
            //As we did change the base to x_elec_quapro=solution_elec_quapro-x0_elec_quapro, we change the base back
            solution_elec_quapro=max(x_elec_quapro+x0_elec_quapro,0);
            Inv_MW(k,techno_dispatchable)=solution_elec_quapro';
        end
        // If their is no need for the originaly required investment (en MW), we allocated the exces to capacity building
        // at prorata of installed capacities (using values)
    else
        Inv_MW(k,:)=Inv_val_elec_res(k)*(Cap_elec_MW_dep(k,:)/sum(Cap_elec_MW_dep(k,:)))./(CINV_MW_nexus(k,:)/10^3);
    end
end

Inv_MW(:,indice_HYD) = Inv_MW_hydro;
Inv_MW(:,techno_VRE)  = Inv_MW_techno_ENR;
Inv_MW(:,indice_BIS) = Inv_MW_BioCCS;
Inv_MW(:,indice_STR) = Inv_MW_Stor;

//Tracking capacity additions
for k=1:reg
    for j=1:techno_elec
        Cap_elec_MW_vintage(j,current_time_im+Life_time_max,k)=Inv_MW(k,j);
    end
end

//Updated capital in the electricity sector
Cap_elec_MW=Cap_elec_MW_dep+Inv_MW;
cumCapElec_GW = cumCapElec_GW + Cap_elec_MW / 1e3 ;

//new design for available capacities, see later in the dispatch
Cap_elec_MW_ava=Cap_elec_MW;

//Treating hydro separately due to exogenous trajectory
// Depreciated: handled with hydro availability factor now
// for k=1:reg
//     Cap_elec_MW_ava(k,indice_HYD)=Cap_elec_MW(k,indice_HYD)*AF_hydro(k,current_time_im+1); //year 1 is 2015
// end


//Updating the price (per MW) on the new capital in the electricity sector
pCap_MW_elec=sum(Inv_MW.*CINV_MW_nexus(:,:)/10^3,"c")./sum(Inv_MW,"c");

for k=1:reg
    Beta(:,indice_elec,k)=pCap_MW_elec(k)/pCap_MW_elecref(k)*Betaref(:,indice_elec,k);
end



///mean efficiency of the installed power plants
//Some nice update to be done: use a rho that takes into account the prioritary use of the most efficient power plants (the newest)
//when the mean utilization rate is lower than avail factor (some cap are not used)
//This would increase the complexity of the nexus though
rho_elec_moyen=rho_elec_nexus;
for k=1:reg
    for j=1:techno_elec
        if sum(Cap_elec_MW_vintage(j,current_time_im+Life_time_max-Life_time(k,j)+1:current_time_im+Life_time_max,k))<>0
            rho_elec_moyen(k,j)=sum(Cap_elec_MW_vintage(j,current_time_im+Life_time_max-Life_time(k,j)+1:current_time_im+Life_time_max,k).*matrix(rho_elec_vintage(k,j,current_time_im+Life_time_max-Life_time(k,j)+1:current_time_im+Life_time_max),1,Life_time(k,j)))./sum(Cap_elec_MW_vintage(j,current_time_im+Life_time_max-Life_time(k,j)+1:current_time_im+Life_time_max,k));
        end
    end
end

//--------------------------------------------------------------------//
//------------------ Residual load duration curve --------------------//
//--------------------------------------------------------------------//
//Expected electricity demand for next static equilibrium
Q_elec_anticip_i_1_tot=Q(:,indice_elec).*tendance_Q_elec*(mtoe2mwh);

if calib_profile_cost == 1
    //using previously prescribed electricity demand
    Q_elec_anticip_i_1_tot = Q_elec_init;
end

//Getting back t+1 gross and net VRE shares to get RLDC at t+1. Gross shares = production of the installed capacities 
Gross_VRE_share_i_1 = (Cap_elec_MW_ava(:,techno_VRE).*Load_factor_ENR(:,techno_VRE_absolute)*10^3)./repmat((Q_elec_anticip_i_1_tot),1,4);
//Then we get curtailment using gross VRE shares
Gross_wind_share_1 = sum(Gross_VRE_share_i_1(:,technoWind_absolute),'c');
Gross_PV_share_1 = sum(Gross_VRE_share_i_1(:,technoPV_absolute),'c');

//Curtailment of VRE
curt_share = curtailment_share_d([Gross_wind_share_1 ,Gross_PV_share_1]);
curt_VRE_gross_1=att_curtailment(Gross_wind_share_1 ,Gross_PV_share_1);
curt_VRE_1 = [repmat(curt_VRE_gross_1(:,1),1,length(technoWind_absolute)),repmat(curt_VRE_gross_1(:,2),1,length(technoPV_absolute))];

share_VRE_1 = Gross_VRE_share_i_1.*(1-curt_VRE_1);
part_ENR_prod_i_1 = sum(share_VRE_1,'c');


Q_elec_anticip_i_1=Q_elec_anticip_i_1_tot.*(1-part_ENR_prod_i_1);
//sum(part_ENR_prod_i_1.*Q_elec_anticip_i_1_tot)/sum(Q_elec_anticip_i_1_tot)


//total peak and base according to classic IMACLIM step function approximation
peak_W_anticip_tot_i_1 = (Q_elec_anticip_i_1_tot)./(bp_ratio*full_load_hours + facteur_t*(1-bp_ratio) );
base_W_anticip_tot_i_1 = bp_ratio.*peak_W_anticip_tot_i_1;

//Getting the residual peak load as a function of Gross VRE shares
RLDC_peak_i_1 = find_RLDC_peak([Gross_wind_share_1,Gross_PV_share_1]);

if old_RLDC_design==1
    RLDC_peak_i_1 = (1-part_ENR_prod_i_1);
end
//peak_W_anticip_i_1=sum(Cap_elec_MW_ava(:,1:technoFF+technoNuke+1),"c");
peak_W_anticip_i_1=RLDC_peak_i_1.*peak_W_anticip_tot_i_1;

//Computing baseload thnak to the equation Q_elec_anticip = area below the RLDC
base_W_anticip_i_1 = (Q_elec_anticip_i_1 - peak_W_anticip_i_1*facteur_t)/(full_load_hours-facteur_t);

//Getting back the residual load duration curve
//as in the ideal park nexus, we account for negative initial baseload case. 
//Availability factor rather than the ava_to_inst_poles variable that was not specific to techno but to region only

for tranche = tranches_elec
    execstr("Cap_"+tranche+"_anticip_MW_i_1=zeros(reg,1);");
end

//computing residual load bands with new VRE market share
[n_inner_bands_loop_i,inner_band_height_i,baseload_i,load_bands_i] = compute_load_bands(Q_elec_anticip_i_1, peak_W_anticip_i_1);

for band= tranches_elec
    execstr("Cap_"+band+"_anticip_MW_i_1=load_bands_i.band_"+band+";");
end



Q_elec_Conv_CI = zeros (reg,1);
for tranche = tranches_elec
    execstr ("Q_elec_Conv_CI=Q_elec_Conv_CI+Cap_"+tranche+"_anticip_MW_i_1*"+tranche+";");
end

//This made no sens to force the total electricity demand to be equal the potential output of the park
Q_elec_tot_CI=Q_elec_anticip_i_1_tot;

//--------------------------------------------------------------------//
//------------- Fuel costs, merit order and dispatch -----------------//
//------------------------------------------------------------------//


CFuel_i_1=zeros(reg,techno_elec);

for k=1:reg
    for j=technoElecCoal
        CFuel_i_1(k,j)=p_Coal_anticip(k,1)/rho_elec_moyen(k,j);
    end
    for j=technoElecGas 
        CFuel_i_1(k,j)=p_Gaz_anticip(k,1)/rho_elec_moyen(k,j);
    end
    for j=technoOil
        CFuel_i_1(k,j)=p_Et_anticip(k,1)/rho_elec_moyen(k,j);
    end
    for j=technoNuke
        CFuel_i_1(k,j)=Nuc_fuel_cost_kwh;
    end


    //CFuel_i_1(k,j)=(elecBiomassInitial.processCost+ p_biom_antcp_withTax(k,1))/rho_elec_moyen(k,j);
    //CCS is treated separetely as the fuel cost must not include the CO2 tax
    j=indice_PSS;
    CFuel_i_1(k,j)=(pArmCI_no_taxCO2(indice_coal,indice_elec,k)*1/tep2kwh)/rho_elec_moyen(k,j);
    j=indice_CGS;
    CFuel_i_1(k,j)=(pArmCI_no_taxCO2(indice_coal,indice_elec,k)*1/tep2kwh)/rho_elec_moyen(k,j);
    j=indice_UCS;
    CFuel_i_1(k,j)=(pArmCI_no_taxCO2(indice_coal,indice_elec,k)*1/tep2kwh)/rho_elec_moyen(k,j);
    j=indice_GGS;
    CFuel_i_1(k,j)=(pArmCI_no_taxCO2(indice_gas,indice_elec,k)*1/tep2kwh)/rho_elec_moyen(k,j);
    j=indice_BIG;
    CFuel_i_1(k,j)=(p_biom_antcp_withTax(k,1)+elecBiomassInitial.processCost.BIG)/rho_elec_moyen(k,j);
    j=indice_SBI;
    CFuel_i_1(k,j)=(p_biom_antcp_withTax(k,1)+elecBiomassInitial.processCost.SBI)/rho_elec_moyen(k,j);
    j=indice_BIS;
    CFuel_i_1(k,j)=(p_biom_antcp_CCS_withTax(k,1)+elecBiomassInitial.processCost.BIS)/rho_elec_moyen(k,j);

    if ind_cap_rate_CCS
        j=indice_PSS;
        CFuel_i_1(k,j)=cap_rate_CCS.*CFuel_i_1(k,j)+ (1-cap_rate_CCS).*p_Coal_anticip(k,1)/rho_elec_moyen(k,j);
        j=indice_CGS;
        CFuel_i_1(k,j)=cap_rate_CCS.*CFuel_i_1(k,j)+ (1-cap_rate_CCS).*p_Coal_anticip(k,1)/rho_elec_moyen(k,j) ;
        j=indice_UCS;
        CFuel_i_1(k,j)=cap_rate_CCS.*CFuel_i_1(k,j)+ (1-cap_rate_CCS).*p_Coal_anticip(k,1)/rho_elec_moyen(k,j);
        j=indice_GGS;
        CFuel_i_1(k,j)=cap_rate_CCS.*CFuel_i_1(k,j) + (1-cap_rate_CCS).*p_Gaz_anticip(k,1)/rho_elec_moyen(k,j);
        j=indice_BIS;
        CFuel_i_1(k,j)=cap_rate_CCS.*CFuel_i_1(k,j)+(1-cap_rate_CCS).*(p_biom_antcp_withTax(k,1)+elecBiomassInitial.processCost.BIS)/rho_elec_moyen(k,j);
    end
end

//Storing the residual load curve shape before the loop. At the beginning of the loop the Cap_"+tranche+"_anticip_MW_i_1 is loaded because 
//the inner dispatch loop erases the variables
for tranche = tranches_elec
    execstr("Cap_"+tranche+"_1=Cap_"+tranche+"_anticip_MW_i_1;");
end

//This very long while loop ensures that the utilization rate of the existing capital is consistent with its availability rate per techno
first_run_ava =%t;

nb_while_loop = 0;
// to add: first check that the existing capacity can meet the demand
while (sum(Utilrate-avail_factor > 0.00001)>1 | first_run_ava) & nb_while_loop <=20   //absolute zero yields 10^16 dec errors
    nb_while_loop = nb_while_loop + 1;
    first_run_ava=%f;

    for tranche = tranches_elec
        execstr("Cap_"+tranche+"_anticip_MW_i_1=Cap_"+tranche+"_1;");
    end
    
    //Available dispatchable capacity
    //Carefully: we are using absolute indexes (from 1 to ntechno_elec_total) in Cap_elec_MW_ava_conv while there are only techno_dispatchable. It works because the indexes are well ordered in the indexes.electricity.sce script
    Cap_elec_MW_ava_conv=Cap_elec_MW_ava(:,techno_dispatchable);

    if ind_hydro_upd ==%t
        //Update hydro availability factor
        avail_factor(:,indice_HYD) = AF_hydro(:,current_time+1);
    end
    //Preventing CCS to be dispatched if their t+10 market share does not exceed a minimum threshold. This is a rustine because
    //we must give positive initial capacities to not mess with the learning curve.
    //This is not absurd as we may consider this as a supplementary development step where projects exist
    // at the experimental stage
    for k=1:reg
        test_CCS=0;
        for tranche=tranches_elec
            for j=[find(techno_dispatch_type == ["CoalWCCS"]),find(techno_dispatch_type == ["GasWCCS"]),find(techno_dispatch_type == ["BiomassWCCS"])]
                execstr("test_CCS = test_CCS+sum(MSH_"+tranche+"_type(k,j))")
            end
        end
        if (test_CCS<min_CCS)
            Cap_elec_MW_ava_conv(k,[indice_BIS,indice_PSS,indice_CGS,indice_GGS,indice_UCS])=0;
        end
    end

    // Limit for BECSS when there is a total limit on CCS 
    if ind_limCCS_InjRate>0  & current_time_im>=start_year_strong_policy-base_year_simulation & current_time_im <= year_stop_CCS_constraint-base_year_simulation
        Cap_elec_MW_ava_conv(:,indice_BIS) = min(Cap_elec_MW_ava_conv(:,indice_BIS),Cap_elec_MW_ava_conv(:,indice_BIS) .* divide(MSH_BIGCCS_cor_factor*max_global_BIGCCS_Cap, sum(Cap_elec_MW_ava_conv(:,indice_BIS)),1) );
    end

    varCosts = zeros(reg,nTechno_dispatch); 
    varCosts  = CFuel_i_1(:,[techno_dispatchable]); // will included variable O&M in a future commit
    varCosts(:,[technoUnused,techno_VRE,technoStorage]) = %inf;

    varCosts = round(varCosts * 1e15) * 1e-15;


    for tranche = tranches_elec
        execstr ("techno_generation_"+tranche+"=zeros(reg,techno_elec);");
    end
    //Central loop for dispatching capacties according to the merit order to meet the residual load.
    for k=1:reg
        [CFuel_croiss,ordre_techno_CFuel]=gsort(varCosts(k,:),"g","i");  
        for j=1:nTechno_dispatch
            for tranche = tranches_elec
                if evstr ("Cap_"+tranche+"_anticip_MW_i_1(k)>Cap_elec_MW_ava_conv(k,ordre_techno_CFuel(j))")
                    execstr ("techno_generation_"+tranche+"(k,ordre_techno_CFuel(j))=Cap_elec_MW_ava_conv(k,ordre_techno_CFuel(j));");
                    execstr ("Cap_"+tranche+"_anticip_MW_i_1(k)=Cap_"+tranche+"_anticip_MW_i_1(k)-Cap_elec_MW_ava_conv(k,ordre_techno_CFuel(j));");
                    Cap_elec_MW_ava_conv(k,ordre_techno_CFuel(j))=0;
                end
                if evstr ("Cap_"+tranche+"_anticip_MW_i_1(k)<Cap_elec_MW_ava_conv(k,ordre_techno_CFuel(j))")
                    execstr ("techno_generation_"+tranche+"(k,ordre_techno_CFuel(j))=Cap_"+tranche+"_anticip_MW_i_1(k);");
                    execstr ("Cap_elec_MW_ava_conv(k,ordre_techno_CFuel(j))=Cap_elec_MW_ava_conv(k,ordre_techno_CFuel(j))-Cap_"+tranche+"_anticip_MW_i_1(k);");
                    execstr ("Cap_"+tranche+"_anticip_MW_i_1(k)=0;");
                end
            end
        end
    end

    prod_elec_techno = zeros (reg, techno_elec);
    for tranche = tranches_elec
        execstr ("prod_elec_techno=prod_elec_techno+techno_generation_"+tranche+"*"+tranche+";"); // prod_elec_techno : MWh
    end

    for j=techno_dispatchable
        Utilrate(:,j) = prod_elec_techno(:,j)./((Cap_elec_MW(:,j)+%eps)*full_load_hours); //Utilization rate: ratio of output on theorical maximum ouput based on nominal power
    end
    for k=1:reg
        for j=techno_dispatchable
            if  Utilrate(k,j)>avail_factor(k,j)
                Cap_elec_MW_ava(k,j) = Cap_elec_MW(k,j)*avail_factor(k,j);
            end
        end
    end
end //end of while loop: as long as the utilization rate of some capacities exceeds its availability factor, the loop keeps going.

// Must think about a way to warm if some demand is not met. This checked is roughly replaced by nb_while_loop <= 20 until then.

//--------------------------------------------------------------------//
//------------------------- VRE production ---------------------------//
//--------------------------------------------------------------------//

prod_elec_techno(:,techno_VRE) = share_VRE_1.*repmat(Q_elec_anticip_i_1_tot,1,nTechno_VRE);
prod_elec_techno(prod_elec_techno < 1e-3) = %eps; // zero aren't nice with fsolve
prod_elec_prev = prod_elec_techno(:,techno_VRE);
//Market shares and avoided emissions
msh_elec_techno = prod_elec_techno./(sum(prod_elec_techno,"c")*ones(1,techno_elec));
emi_evitee_elec(:,1) = prod_elec_techno(:,indice_BIS) / tep2MWh / 1e6 ./ rho_elec_moyen(:,indice_BIS) * elecBiomassInitial.emissionsCCS;
emi_evitee = emi_evitee + emi_evitee_elec;

if current_time_im==1
    sg_add("msh_elec_techno")
end

//--------------------------------------------------------------------//
//----- Cost of electricity generation and electricy IC update -------//
//--------------------------------------------------------------------//

for tranche = tranches_elec
    execstr ("LCC_"+tranche+"_i_1_MWh =  (CINV+int_cost_ann+OM_cost_fixed_nexus)/"+tranche+"+CFuel_i_1+OM_cost_var_nexus;");
    execstr("LCC_"+tranche+"_i_1_MWh = max(LCC_" + tranche+"_i_1_MWh,1e-10);");
end


//For Nexus land use only
[costBIGCC_withTax,costBIGCCS_withTax,costBIGCC_noTax,costBIGCCS_noTax,breakEvenTax,qBiomExaJ] = ..
    computeBiomassCost(elecBiomassInitial.supplyCurve,prod_elec_techno(:,technoBiomass),..
    rho_elec_nexus(:,technoBiomass),..
    elecBiomassInitial.emissions,elecBiomassInitial.emissionsCCS,..
    croyance_taxe,expected.taxCO2_CI(indice_agriculture,indice_elec,:,:),..
elecBiomassInitial.exogenousBiomassMaxQ,%t,elecBiomassInitial.priceCap);


// zero beccs case : make it absolute :
if (ind_beccs==0)|(ind_beccs==3&current_time_im<50)
    qBiomExaJ(:,2) = 0 * qBiomExaJ(:,2);
end


qBiomExaJ_reg = sum(qBiomExaJ,"c");
if ind_NLU == 1 & limit_on_bioelec
    //glob_in_bioelec_Elec_reg =  sum(qBiomExaJ,"c").*Exajoule2Mkcal;
    // Note : the limit is on biofuels. if bioelec and hydrogen exceed the limit
    if (combi == 9) | (combi == 16) | (combi == 23)
        qBiomExaJ_glob = max( min( sum(qBiomExaJ_reg), 100 - glob_in_bioelec_Hyd ./ Exajoule2Mkcal), 0);
        qBiomExaJ_reg = divide( qBiomExaJ_reg, sum(qBiomExaJ_reg), 0) .* qBiomExaJ_glob;
    end
end


// the unitary use of coal/gaz/liquids per unit of electricity prod
for k=1:reg
    CIdeltaelec(:,indice_elec,k)=CI(:,indice_elec,k);
end

//CIdeltaelec is an intermediary variable for inertia
for k=1:reg
    CIdeltaelec(indice_coal,indice_elec,k)        = sum(prod_elec_techno(k,technoElecCoal)./rho_elec_moyen(k,technoElecCoal))/Q_elec_tot_CI(k);
    CIdeltaelec(indice_gas,indice_elec,k)         = sum(prod_elec_techno(k,technoElecGas)./rho_elec_moyen(k,technoElecGas))/Q_elec_tot_CI(k);
    CIdeltaelec(indice_Et,indice_elec,k)          = sum(prod_elec_techno(k,technoOil)./rho_elec_moyen(k,technoOil))/Q_elec_tot_CI(k);
    CIdeltaelec(indice_agriculture,indice_elec,k) = sum(prod_elec_techno(k,technoBiomass)./rho_elec_moyen(k,technoBiomass).*(p_biom_antcp_agg_noTax(k,:)*tep2kwh))/pArmCI(indice_agriculture,indice_elec,k)/Q_elec_tot_CI(k);
end


//Modifying IC and applying inertia
if current_time_im>1
    for k=1:reg
        CI(:,indice_elec,k) = CIdeltaelec(:,indice_elec,k) * (1-inertia_elec_CI) + CI_prev(:,indice_elec,k) * inertia_elec_CI ;
    end
end


//Modifying IC to account for T&D losses. Everybody convergence towards 9% in 2050
//TB: this correspond to T&D losses, but no reference on it
//By the way, I does not even understand what theses number refer to
if current_time_im<=2050-base_year_simulation
    for k=1:reg
        CI(indice_elec,indice_elec,k)=(0.09-CIref(indice_elec,indice_elec,k))/(2050-base_year_simulation)*(current_time_im)+CIref(indice_elec,indice_elec,k);
    end
end
// In the electricity production cost structure, we report losses costs reduction on industrial good consumption, at 90%

//remaining at constant costs. We solve the following equation in x:
//(CI(indice_elec,indice_elec,k)-CI_prev(indice_elec,indice_elec,k))*pArmCI(indice_elec,indice_elec,k)=x*pArmCI(indice_industrie,indice_elec,k)
// for k=1:reg
// 	CI(indice_industrie,indice_elec,k)=CI(indice_industrie,indice_elec,k)+0.9*(CI_prev(indice_elec,indice_elec,k)-CI(indice_elec,indice_elec,k))*pArmCI(indice_elec,indice_elec,k)/pArmCI(indice_industrie,indice_elec,k);
// end

//CCS shares in elec production per FF&biomass use: this update the carbon content of electricity production
sh_CCS_biomass_Q_biomass = zeros(reg,1);
sh_CCS_gaz_Q_gaz = zeros(reg,1);
sh_CCS_col_Q_col = zeros(reg,1);
for k=1:reg
    if sum(prod_elec_techno(k,technoElecCoal),"c")>0
        sh_CCS_col_Q_col(k)=(prod_elec_techno(k,indice_PSS)+prod_elec_techno(k,indice_CGS)+prod_elec_techno(k,indice_UCS))./sum(prod_elec_techno(k,technoElecCoal),"c");
    end
    if sum(prod_elec_techno(k,technoElecGas),"c")>0
        sh_CCS_gaz_Q_gaz(k)=prod_elec_techno(k,indice_GGS)./sum(prod_elec_techno(k,technoElecGas),"c");
    end
    if sum(prod_elec_techno(k,technoBiomass),"c")>0
        sh_CCS_biomass_Q_biomass(k)=sum(prod_elec_techno(k,indice_BIS))./sum(prod_elec_techno(k,technoBiomass));
    end
end

//Electricity prices are following the life-cycle generation costs

//Life-cycle cost of conventionnal power
CFuel_moy      = zeros(reg,techno_elec);
CFuel_moyNoTax = zeros(reg,techno_elec);

for k=1:reg
    for j=technoElecCoal
        CFuel_moy(k,j)      = p_Coal_anticip(k,1)                         / rho_elec_moyen(k,j);
        CFuel_moyNoTax(k,j) = pArmCI_no_taxCO2(indice_coal,indice_elec,k) / rho_elec_moyen(k,j) / tep2kwh;
    end
    for j=technoElecGas
        CFuel_moy(k,j)      = p_Gaz_anticip(k,1)/rho_elec_moyen(k,j);
        CFuel_moyNoTax(k,j) = pArmCI_no_taxCO2(gaz,indice_elec,k) / rho_elec_moyen(k,j) / tep2kwh;
    end
    for j=technoOil
        CFuel_moy(k,j)      = p_Et_anticip(k,1)/rho_elec_moyen(k,j);
        CFuel_moyNoTax(k,j) = pArmCI_no_taxCO2(et,indice_elec,k) / rho_elec_moyen(k,j) / tep2kwh;
    end

    for j=technoNuke
        CFuel_moy(k,j)=Nuc_fuel_cost_kwh / tep2kwh;
    end

    j=indice_BIG;
    CFuel_moy(k,j)=p_biom_antcp_withTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost.BIG;
    j=indice_SBI;
    CFuel_moy(k,j)=p_biom_antcp_withTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost.SBI;

    //CCS is treated separately to remove the CO2 tax on FF
    j=indice_PSS;
    CFuel_moy(k,j)=(pArmCI_no_taxCO2(indice_coal,indice_elec,k)/tep2kwh)/rho_elec_moyen(k,j);
    j=indice_CGS;
    CFuel_moy(k,j)=(pArmCI_no_taxCO2(indice_coal,indice_elec,k)/tep2kwh)/rho_elec_moyen(k,j);
    j=indice_UCS;
    CFuel_moy(k,j)=(pArmCI_no_taxCO2(indice_coal,indice_elec,k)/tep2kwh)/rho_elec_moyen(k,j);
    j=indice_GGS;
    CFuel_moy(k,j)=(pArmCI_no_taxCO2(indice_gas,indice_elec,k)/tep2kwh)/rho_elec_moyen(k,j);
    
    j=indice_BIS;
    CFuel_moy(k,j)=p_biom_antcp_CCS_withTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost.BIS;
end
CFuel_moyWoBioTax = CFuel_moy;
for k=1:reg
    j=indice_BIG;
    CFuel_moyWoBioTax(k,j)=p_biom_antcp_noTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost.BIG;
    CFuel_moyNoTax(k,j)=p_biom_antcp_noTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost.BIG;
    j=indice_SBI;
    CFuel_moyWoBioTax(k,j)=p_biom_antcp_noTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost.SBI;
    CFuel_moyNoTax(k,j)=p_biom_antcp_noTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost.SBI;
    j=indice_BIS;
    CFuel_moyWoBioTax(k,j)=p_biom_antcp_CCS_noTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost.BIS;
    CFuel_moyNoTax(k,j)=p_biom_antcp_CCS_noTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost.BIS;
end

sum_LCC         = zeros (reg,techno_elec);
sumLccNoTax     = zeros (reg,techno_elec);
sum_LCCWoBioTax = zeros (reg,techno_elec);

//Life-cycle cost per load band of elec generation (careful: this is in kWh, not in Mwh as the name suggests...)
for tranche = tranches_elec
    execstr("LCC_"+tranche+"_moy_MWh         =  (CINV + int_cost_ann+OM_cost_fixed_nexus + TD_cost_ann) /" + tranche + " + CFuel_moy         + OM_cost_var_nexus;");
    execstr("LCC_"+tranche+"_moyWoBioTax_MWh =  (CINV +int_cost_ann+ OM_cost_fixed_nexus+ TD_cost_ann) /" + tranche + " + CFuel_moyWoBioTax + OM_cost_var_nexus;");
    execstr("LCC_"+tranche+"_moyNoTax_MWh    =  (CINV + int_cost_ann+OM_cost_fixed_nexus+TD_cost_ann) /" + tranche + " + CFuel_moyNoTax    + OM_cost_var_nexus;");

    execstr("LCC_"+tranche+"_moy_MWh(:,techno_VRE)         =  LCC_ENR;");
    execstr("LCC_"+tranche+"_moyWoBioTax_MWh(:,techno_VRE) =  LCC_ENR;");
    execstr("LCC_"+tranche+"_moyNoTax_MWh(:,techno_VRE)    =  LCC_ENR;");

    execstr("LCC_"+tranche+"_moy_MWh         = max(LCC_" + tranche+"_moy_MWh         ,1e-10);");
    execstr("LCC_"+tranche+"_moyWoBioTax_MWh = max(LCC_" + tranche+"_moyWoBioTax_MWh ,1e-10);");
    execstr("LCC_"+tranche+"_moyNoTax_MWh    = max(LCC_" + tranche+"_moyNoTax_MWh    ,1e-10);");

    execstr("sum_LCC         = sum_LCC         + LCC_"+tranche+"_moy_MWh         .* techno_generation_"+tranche+"*"+tranche+";");
    execstr("sum_LCCWoBioTax = sum_LCCWoBioTax + LCC_"+tranche+"_moyWoBioTax_MWh .* techno_generation_"+tranche+"*"+tranche+";");
    execstr("sumLccNoTax     = sumLccNoTax     + LCC_"+tranche+"_moyNoTax_MWh    .* techno_generation_"+tranche+"*"+tranche+";");
end

//TB: for now, the cost of electricity generation only includes operating plants. This must be reworked to perform the GSA of the electricity sector

if calib_profile_cost == 1
    //Annualized total system cost calculation: what is the cost of the whole system to produce electricity (in a greefield approach)
    // = the sum of annualized CAPEX, OPEX and fuel costs. Everything converted in $/MWh or $/MW first
    // Grid costs are now included yet because grid costs are only included in the LCOE, but not modeled explicitly as an infrastructure. This needs to be improved in the near future!
    //using a uniform 7% DR to discount the costs (instead of WACC)

    CRF_SC=disc_rate_profile*ones(CRF)./(1-(1+disc_rate_profile*ones(CRF)).^(-Life_time_LCC));

    Annual_CAPEX = Cap_elec_MW.*CRF_SC.*CINV_MW_nexus*10^3;
    Annual_Fixed_OPEX = Cap_elec_MW.*(OM_cost_fixed_nexus + int_cost_ann)*10^3; // includes IDC
    Annual_Var_OPEX = prod_elec_techno.*(CFuel_moy+OM_cost_var_nexus)*10^3;
    //Total system cost of the dispatchable capacity
    Total_Annualized_SC = sum(Annual_CAPEX(:,techno_dispatchable) + Annual_Fixed_OPEX(:,techno_dispatchable) + Annual_Var_OPEX(:,techno_dispatchable),"c");
end
stor_share_1= storage_share_peak([Gross_wind_share_1,Gross_PV_share_1]);
stor_cap_1 = stor_share_1.* peak_W_anticip_i_1;
// computing current storage costs per kWh of gross VRE gen
stor_gross_1 = att_str(Gross_wind_share_1,Gross_PV_share_1,peak_W_anticip_tot_i_1,Q_elec_anticip_i_1_tot);
stor_gross_VRE_1 = [repmat(stor_gross_1(:,1),1,length(technoWind_absolute)),repmat(stor_gross_1(:,2),1,length(technoPV_absolute))];
//in $/kWh of gross PV/wind gen
stor_gross_VRE_kwh_1= stor_gross_VRE_1.* repmat(CINV(:,indice_STR),1,nTechno_VRE);

//computing current profile costs per kWh of gross VRE gen
pc_gross_1 = att_profile_costs(Gross_wind_share_1,Gross_PV_share_1);
pc_gross_VRE_kwh_1 = [repmat(pc_gross_1(:,1),1,length(technoWind_absolute)),repmat(pc_gross_1(:,2),1,length(technoPV_absolute))]/10^3;
//System LCOE wo the profile costs part that are attributed to VRE but actually borne by the whole system
LCC_ENR_real=compute_LCOE(CINV,int_cost_ann,OM_cost_fixed_nexus,TD_cost_ann,Load_factor_ENR,avg_deg_rate,prof_gross_VRE_kwh=zeros(pc_gross_VRE_kwh_1),stor_gross_VRE_kwh=stor_gross_VRE_kwh_1,OM_cost_var_nexus,Bal_cost = zeros(Bal_cost),crt_gross_VRE=curt_VRE_1);

SLCC_ENR_1=compute_LCOE(CINV,int_cost_ann,OM_cost_fixed_nexus,TD_cost_ann,Load_factor_ENR,avg_deg_rate,prof_gross_VRE_kwh=pc_gross_VRE_kwh_1,stor_gross_VRE_kwh=stor_gross_VRE_kwh_1,OM_cost_var_nexus,Bal_cost,crt_gross_VRE=curt_VRE_1);

LCC_ENR_1=compute_LCOE(CINV,int_cost_ann,OM_cost_fixed_nexus,TD_cost_ann,Load_factor_ENR,avg_deg_rate,prof_gross_VRE_kwh=zeros(pc_gross_VRE_kwh_1),stor_gross_VRE_kwh=zeros(stor_gross_VRE_kwh_1),OM_cost_var_nexus,Bal_cost = zeros(Bal_cost),crt_gross_VRE=zeros(curt_VRE_1));

sum_LCC(:,techno_VRE)         = sum_LCC(:,techno_VRE)         + prod_elec_techno(:,techno_VRE) .* LCC_ENR_real;
sum_LCCWoBioTax(:,techno_VRE) = sum_LCCWoBioTax(:,techno_VRE) + prod_elec_techno(:,techno_VRE) .* LCC_ENR_real;
sumLccNoTax(:,techno_VRE)     = sumLccNoTax(:,techno_VRE)     + prod_elec_techno(:,techno_VRE) .* LCC_ENR_real;

LCOE      = sum_LCC     ./ (prod_elec_techno + 1e-15) .* (prod_elec_techno > 0); // in $/kWh
lcoeNoTax = sumLccNoTax ./ (prod_elec_techno + 1e-15) .* (prod_elec_techno > 0); // in $/kWh
total_CC_elec=sum(sum_LCC,"c"); //total life cycle cost of electricity gen
//Life cycle cost per unit of electricity generation
CC_elec_i_1=total_CC_elec./sum(prod_elec_techno,"c")*tep2kwh;
sysLCOE(:,current_time_im) = CC_elec_i_1/tep2kwh;
if current_time_im==1
    CC_elec_i_1_ref=CC_elec_i_1;
end
// TB: the reserve margin does not feedback into the LCOE. As it is, the LCOE only reflect the cost of electricity generation, not the cost of the whole system.
// This must be included in the future
total_CC_elecWoBioTax = sum(sum_LCCWoBioTax,"c");
CC_elec_i_1WoBioTax = total_CC_elecWoBioTax./sum(prod_elec_techno,"c")*tep2kwh;

//Computing markup in the electricity sector
if isdef("run_partial_eq_elec")
else
    markup(:,indice_elec) = calib_markup_elec();
end
//Applying inertia on the markup
if ind_in_markup_elec
    markup(:,indice_elec) = (1-inertia_elec_markup) * markup(:,indice_elec) + inertia_elec_markup * markup_prev(:,indice_elec);
    markup(:,indice_elec)=max(min(markup(:,indice_elec),markup_prev(:,indice_elec)+0.03),markup_prev(:,indice_elec)-0.03);
end
//Residual peak coverage for the next dynamic equilibrium
//CCS is counted in the coverage, but investment in CCS is not diminshed if peak> required coverage to allow full CCS deployment in climate scenarios
//this calculus needs to be properly adjusted by capacity credit
//Coming soon
residual_peak_cov = (sum(Cap_elec_MW(:,techno_dispatchable).*avail_factor(:,techno_dispatchable),"c"))./peak_W_anticip_i_1;
res_sys_capa_factor = 100*sum(prod_elec_techno(:,techno_dispatchable),"c")./sum((Cap_elec_MW(:,techno_dispatchable)+%eps)*full_load_hours,"c");

if ind_new_rho_calib == 1 & current_time_im> (2018 - base_year_simulation)
    w_inert = min(((current_time_im) - (2018 - base_year_simulation))/5,1);
    inertia_elec_CI = w_inert * inertia_elec_CI_target + (1-w_inert) * inertia_elec_CI_init;
    inertia_elec_CI_init = 5/6;
end
// profile cost calibration output. adding convergence_hor_share_elec + nb_year_expect_futur to make sure that the desired share of VRE is indeed reached 
if calib_profile_cost == 1 & current_time_im== min(convergence_hor_share_elec, TimeHorizon)
    //storing the total system cost and total system cost as a share of net VRE gen
    TSC_D = Total_Annualized_SC./Q_elec_anticip_i_1_tot;
    TSC_Net_VRE = TSC_D./part_ENR_prod_i_1;
    // export as csv file in outputs/profile_costs
    mkdir(OUTPUT+"/profile_costs");
    csvWrite( [old_RLDC_design*ones(reg,1),...
        regnames,...
        WD_sh_target_init,...
        Solar_sh_target_init,...
        Total_Annualized_SC,...
        TSC_D,...
        part_ENR_prod_i_1,...
        Gross_VRE_share_i_1(:,1),...
    Gross_VRE_share_i_1(:,3)], OUTPUT+'/profile_costs/'+WD_sh_target_global+'_'+Solar_sh_target_global+'_'+old_RLDC_design+'.csv');
    abort
end
