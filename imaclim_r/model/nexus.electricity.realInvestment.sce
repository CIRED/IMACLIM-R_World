

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
//----------------------------- Init ---------------------------------//
//--------------------------------------------------------------------//

// Outputs
if current_time_im==1
    sg_add(["qBiomExaJ" "prod_elec_techno" "deltaCIbiomassLost" "sh_bio_prod_elec" "LCOE" "lcoeNoTax" "costBIGCC_noTax" "fuelCosts"]);
end

//--------------------------------------------------------------------//
//----------------------------- Investment ---------------------------//
//--------------------------------------------------------------------//

// Chunk of code to minimize the distance between ideal and effective investment

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

//Same for VRE
for j=technoExo_absolute
    for k=1:reg
        Inv_val_ENR(k,j)=Inv_MW_techno_ENR(k,j)*CINV_MW_nexus(k,technoConv+j)/10^3;
    end
end

//After hydro comes VRE invesments in order of priority
for k=1:reg
    if sum(Inv_val_ENR(k,:))>(Inv_val_elec(k)-Inv_val_Hydro(k))
        disp("shortage invest ENR in region "+k);

        if sum(Inv_val_ENR(k,:))>0
            Inv_MW_techno_ENR(k,:)=Inv_MW_techno_ENR(k,:)*(Inv_val_elec(k)-Inv_val_Hydro(k))/sum(Inv_val_ENR(k,:));
        else
            Inv_MW_techno_ENR(k,:)=0*Inv_MW_techno_ENR(k,:);
        end
        for j=technoExo_absolute
            Inv_val_ENR(k,j)=Inv_MW_techno_ENR(k,j)*CINV_MW_nexus(k,technoConv+j)/10^3;
        end
    end
end

//Cash left after hydro and VRE inv
Inv_val_elec_res=Inv_val_elec-Inv_val_Hydro-sum(Inv_val_ENR,"c");
Inv_MW=zeros(reg,techno_elec);
Inv_cost_elec=zeros(reg,1);
masc_elec=ones(reg,techno_elec);

//the remaining capital is used to fulfill inv in conventionnal power

for k=1:reg

    if sum(delta_Cap_elec_MW_1(k,:))>0   //any investment need remaining?

        //monetary value of the conventionnal investment need
        Inv_cost_elec(k)=sum(delta_Cap_elec_MW_1(k,technoEndo).*CINV_MW_nexus(k,technoEndo)/10^3);

        if Inv_val_elec_res(k)-Inv_cost_elec(k)>=0
           
            //Inv_MW(k,technoEndo)=delta_Cap_elec_MW_1(k,technoEndo)+delta_Cap_elec_MW_1(k,technoEndo)/sum(delta_Cap_elec_MW_1(k,technoEndo)+3*%eps)*(Inv_val_elec_res(k)-Inv_cost_elec(k))./(CINV_MW_nexus(k,technoEndo)/10^3);
            Inv_MW(k,technoEndo)=delta_Cap_elec_MW_1(k,technoEndo);
        end

        if Inv_val_elec_res(k)-Inv_cost_elec(k)<0  //If not enough cash to finance the investment, the distance between the ideal and actual investment need (in MW) is minimized.
            Inv_val_elec_res(k) = max( Inv_val_elec_res(k),500);
            //Keeping the original comment in French + adding a translation:
            //"pour répartir l'investissement (en M$) afin de minimiser la distance entre l'investissement voulu (en MW)
            // et l'investissement effecivement réalisé, on utilise la fonction quapro de scilab (voir aide scilab)
            //la fonction quapro résout ici (en x) le problème : min(x'*Q_elec_quapro*x+p_elec_quapro'*x) , ici donc min (x'*x)
            //sous contrainte C_elec_quapro*x=b_elec_quapro et ci_elec_quapro<=x<=cs_elec_quapro"
          
            //Investment allocation in M$ to minimize the distance between investment need and actual inv in MW
            //using built-in function quapro to solve (in x):  
            //min(x'*Q_elec_quapro*x+p_elec_quapro'*x) , thus min (x'*x)
            //under the constraint C_elec_quapro*x=b_elec_quapro and ci_elec_quapro<=x<=cs_elec_quapro
            //définition de la matrice diagonale Q_elec_quapro pour la forme quadratique
            //Defining the diagonal matrix Q_elec_quapro for the quadratic form
            Q_elec_quapro=eye(nTechnoEndo,nTechnoEndo);
            //cout en capital de chaque technologie
            //Capital cost for each tech
            prix_elec_quapro=CINV_MW_nexus(k,technoEndo)/10^3;
            //contrainte en investissement
            //cash contraint
            Inv_elec_quapro=Inv_val_elec_res(k);
            //investissement idéal (sans contrainte)
            //ideal investment 
            x0_elec_quapro=delta_Cap_elec_MW_1(k,technoEndo)';
            //constante linéaire dans le problème de minimisation (qui est nulle)
            //linear constraint in the min problem
            p_elec_quapro=zeros(nTechnoEndo,1);
            //matrice des contraintes linéaires
            //matrix of linear constraints
            C_elec_quapro=zeros(nTechnoEndo,nTechnoEndo);
            //initialisation des couts en capital
            //initialization of capital costs
            C_elec_quapro(1,:)=prix_elec_quapro;
            //membre de gauche de la contrainte
            // left hand side constraint
            b_elec_quapro=zeros(nTechnoEndo,1);
            //Contrainte sur le cout total de l'investissement
            //Constaint on the total investment cost
            b_elec_quapro(1)=Inv_elec_quapro-prix_elec_quapro*x0_elec_quapro;
            //borne inférieure sur les x
            //Lower bound on x
            ci_elec_quapro=-x0_elec_quapro;
            //borne supérieure sur les x (mise à l'infini)
            //Upper bound on x
            cs_elec_quapro=number_properties("huge")*ones(nTechnoEndo,1);
            //On bloque l'évolution de l'investissement en Hydro. Par rapport a la methode avec C_elec_quapro(2,indice_HYD)=1, on dirait que celle-ci ne provoque *jamais* de qld fail
            // Setting investment in hydro at 0 (exogenous invesment that is prioritary)
            ci_elec_quapro(indice_HYD)=0; cs_elec_quapro(indice_HYD)=0;
            //les deux premières contraintes sont d'égalité
            me_elec_quapro=1;

            notdone_elec_quapro=%t; count_elec_quapro = 0;

            //Cette grosse boucle est une rustine honteuse autour du dysfonctionement de qld. Je pense que avec la contrainte ci_elec_quapro(indice_HYD)=0; cs_elec_quapro(indice_HYD)=0;
            //qld marche beaucoup mieux. Apres quelques semaines, il faudrait chercher 'qld failed' dans les log et eventuellement virer cette boucle infernale
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
            //Comme on a fait un changement de base en x_elec_quapro=solution_elec_quapro-x0_elec_quapro, on se remet dans la bonne base
            solution_elec_quapro=max(x_elec_quapro+x0_elec_quapro,0);
            Inv_MW(k,technoEndo)=solution_elec_quapro';
        end
        //s'il n'existe pas de besoin d'investissement (en MW) exprimé, on alloue l'éventuel argent disponible à la construction de capacités
        // avec une répartition (en valeur) au pro rata des capacités installées
    else
        Inv_MW(k,:)=Inv_val_elec_res(k)*(Cap_elec_MW_dep(k,:)/sum(Cap_elec_MW_dep(k,:)))./(CINV_MW_nexus(k,:)/10^3);
    end
end

Inv_MW(:,indice_HYD) = Inv_MW_hydro;
Inv_MW(:,technoExo)  = Inv_MW_techno_ENR(:,technoExo_absolute);

//Tracking capacity additions
for k=1:reg
    for j=1:techno_elec
        Cap_elec_MW_vintage(j,current_time_im+Life_time_max,k)=Inv_MW(k,j);
    end
end

//Updated capital in the electricity sector
Cap_elec_MW=Cap_elec_MW_dep+Inv_MW;

cumCapElec_GW = cumCapElec_GW + Cap_elec_MW / 1e3 ;

for k=1:reg
    for j=1:techno_elec
        Cap_elec_MW_ava(k,j)=Cap_elec_MW(k,j);
        //new design for available capacities, see later in the dispatch
    end
end


//Treating hydro separately due to exogenous trajectory
for k=1:reg
    Cap_elec_MW_ava(k,indice_HYD)=Cap_elec_MW(k,indice_HYD)*AF_hydro(k,current_time_im+1); //year 1 is 2015
end


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

//Getting back t+1 gross and net VRE shares to get RLDC at t+1. Gross shares = production of the installed capacities 
Gross_VRE_share_i_1 = (Cap_elec_MW_ava(:,techno_ENRi_endo).*Load_factor_ENR(:,VarRenew_ENR)*10^3)./repmat((Q(:,indice_elec).*tendance_Q_elec*(mtoe2mwh)),1,4);
Tot_Gross_VRE_share_i_1 = sum(Gross_VRE_share_i_1,"c");
//curtailement at a share of total net demand. Gross VRE prod = net(1+curt)
total_curt_i_1= curtailment_share_d([sum(Gross_VRE_share_i_1(:,1:2),"c"),sum(Gross_VRE_share_i_1(:,3:4),"c")]);
part_ENR_prod_i_1 = Tot_Gross_VRE_share_i_1./(1+total_curt_i_1);

//Expected electricity demand for next static equilibrium
Q_elec_anticip_i_1_tot=Q(:,indice_elec).*tendance_Q_elec*(mtoe2mwh);
Q_elec_anticip_i_1=Q_elec_anticip_i_1_tot.*(1-part_ENR_prod_i_1);

Q_elec_anticip_ENR_i_1=Q_elec_anticip_i_1_tot.*(part_ENR_prod_i_1);

//total peak and base according to classic IMACLIM step function approximation
peak_W_anticip_tot_i_1 = (Q_elec_anticip_i_1_tot)./(bp_ratio*full_load_hours + facteur_t*(1-bp_ratio) );
base_W_anticip_tot_i_1 = bp_ratio.*peak_W_anticip_tot_i_1;

//Getting the residual peak load as a function of Gross VRE shares
RLDC_peak_i_1 = find_RLDC_peak([sum(Gross_VRE_share_i_1(:,1:2),"c"),sum(Gross_VRE_share_i_1(:,3:4),"c")]);
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
Cap_8760_anticip_MW_i_1=base_W_anticip_i_1;
for tranche = tranches_elec( 2:7)
 execstr ("Cap_"+tranche+"_anticip_MW_i_1=(peak_W_anticip_i_1-base_W_anticip_i_1)/6;");
end

for k=1:reg
    if  base_W_anticip_i_1(k)<0 
         Cap_8760_anticip_MW_i_1(k) = 0;
         Cap_8030_anticip_MW_i_1(k) = (Q_elec_anticip_i_1(k) - peak_W_anticip_i_1(k)*((6570+5110+3650+2190+730)/5))/(8030-(6570+5110+3650+2190+730)/5);
         for tranche = tranches_elec( 3:7)
            execstr ("Cap_"+tranche+"_anticip_MW_i_1(k)=(peak_W_anticip_i_1(k)-Cap_8030_anticip_MW_i_1(k))/5;");
         end
    end
//This shall be done with a single loop
    if Cap_8030_anticip_MW_i_1(k)<0 
        Cap_8030_anticip_MW_i_1(k) = 0;
        Cap_6570_anticip_MW_i_1(k) = (Q_elec_anticip_i_1(k) - peak_W_anticip_i_1(k)*((5110+3650+2190+730)/4))/(6570-(5110+3650+2190+730)/4);
        for tranche = tranches_elec( 4:7)
            execstr ("Cap_"+tranche+"_anticip_MW_i_1(k)=(peak_W_anticip_i_1(k)-Cap_6570_anticip_MW_i_1(k))/4;");
        end
    end

    if Cap_6570_anticip_MW_i_1(k)<0 
         Cap_6570_anticip_MW_i_1(k) = 0;
           Cap_5110_anticip_MW_i_1(k) = (Q_elec_anticip_i_1(k) - peak_W_anticip_i_1(k)*((3650+2190+730)/3))/(5110-(3650+2190+730)/3);
         for tranche = tranches_elec( 5:7)
             execstr ("Cap_"+tranche+"_anticip_MW_i_1(k)=(peak_W_anticip_i_1(k)-Cap_5110_anticip_MW_i_1(k))/3;");
         end
     end

    if Cap_5110_anticip_MW_i_1(k)<0 
        Cap_5110_anticip_MW_i_1(k) = 0;
        Cap_3650_anticip_MW_i_1(k) = (Q_elec_anticip_i_1(k) - peak_W_anticip_i_1(k)*((2190+730)/2))/(3650-(2190+730)/2);
        for tranche = tranches_elec( 6:7)
            execstr ("Cap_"+tranche+"_anticip_MW_i_1(k)=(peak_W_anticip_i_1(k)-Cap_3650_anticip_MW_i_1(k))/2;");
        end
    end

    if Cap_3650_anticip_MW_i_1(k)<0 
        Cap_3650_anticip_MW_i_1(k) = 0;
        Cap_2190_anticip_MW_i_1(k) = (Q_elec_anticip_i_1(k) - peak_W_anticip_i_1(k)*(730)/(2190-730));
        for tranche = tranches_elec( 7:7)
            execstr ("Cap_"+tranche+"_anticip_MW_i_1(k)=(peak_W_anticip_i_1(k)-Cap_2190_anticip_MW_i_1(k));");
        end
    end
//Cases where there is only one load band
    if Cap_2190_anticip_MW_i_1(k)<0 |Cap_730_anticip_MW_i_1(k)<0
        Cap_2190_anticip_MW_i_1(k) = 0;
        Cap_730_anticip_MW_i_1(k) = (Q_elec_anticip_i_1(k) /(730));
         //warning("In region "+k+" the residual load curve contains only one load band: either a problem with the RLDC design or a very high VRE level")
     end

end

Q_elec_Conv_CI = zeros (reg,1);
for tranche = tranches_elec
    execstr ("Q_elec_Conv_CI=Q_elec_Conv_CI+Cap_"+tranche+"_anticip_MW_i_1*"+tranche+";");
end

Q_elec_tot_CI=Q_elec_Conv_CI./(1-part_ENR_prod_i_1);

//--------------------------------------------------------------------//
//------------- Fuel costs, merit order and dispatch -----------------//
//------------------------------------------------------------------//


CFuel_i_1=zeros(reg,techno_elec);

for k=1:reg
    for j=1:technoCoal
        CFuel_i_1(k,j)=p_Coal_anticip(k,1)/rho_elec_moyen(k,j);
    end
    for j=technoCoal+1:technoCoal+technoGas
        CFuel_i_1(k,j)=p_Gaz_anticip(k,1)/rho_elec_moyen(k,j);
    end
    for j=technoCoal+technoGas+1:technoFF
        CFuel_i_1(k,j)=p_Et_anticip(k,1)/rho_elec_moyen(k,j);
    end
    for j=technoFF+1:techno_elec
        CFuel_i_1(k,j)=0; //Q: what about nuclear Cfuel???
    end
    j=indice_BIGCC;
    CFuel_i_1(k,j)=p_biom_antcp_withTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost;

    //CCS is treated separetely as the fuel cost must not include the CO2 tax
    j=indice_PSS;
    CFuel_i_1(k,j)=(pArmCI_no_taxCO2(indice_coal,indice_elec,k)*1/tep2kwh)/rho_elec_moyen(k,j);
    j=indice_CGS;
    CFuel_i_1(k,j)=(pArmCI_no_taxCO2(indice_coal,indice_elec,k)*1/tep2kwh)/rho_elec_moyen(k,j);
    j=indice_UCS;
    CFuel_i_1(k,j)=(pArmCI_no_taxCO2(indice_coal,indice_elec,k)*1/tep2kwh)/rho_elec_moyen(k,j);
    j=indice_GGS;
    CFuel_i_1(k,j)=(pArmCI_no_taxCO2(indice_gaz,indice_elec,k)*1/tep2kwh)/rho_elec_moyen(k,j);
    j=indice_BIGCCS;
    CFuel_i_1(k,j)=p_biom_antcp_CCS_withTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost;
end

//Storing the residual load curve shape before the loop. At the beginning of the loop the Cap_"+tranche+"_anticip_MW_i_1 is loaded because 
//the inner dispatch loop erases the variables
for tranche = tranches_elec
    execstr("Cap_"+tranche+"_1=Cap_"+tranche+"_anticip_MW_i_1;");
end

//This very long while loop ensures that the utilization rate of the existing capital is consistent with its availability rate per techno
first_run_ava =%t;
while sum(Utilrate-avail_factor > 0.00001)>1 | first_run_ava   //absolute zero yields 10^16 dec errors
    first_run_ava=%f;

    for tranche = tranches_elec
        execstr("Cap_"+tranche+"_anticip_MW_i_1=Cap_"+tranche+"_1;");
    end
    
//Available capacity
    Cap_elec_MW_ava_conv=Cap_elec_MW_ava(:,1:technoConv);
    Cap_elec_MW_ava_conv(:,technoBiomass) = Cap_elec_MW_ava(:,technoBiomass);

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
         execstr("test_CCS = test_CCS+sum(MSH_"+tranche+"_elec(k,[indice_BIGCCS,indice_PSS,indice_CGS,indice_GGS,indice_UCS]))")
        end
        if (test_CCS<min_CCS)
         Cap_elec_MW_ava_conv(k,[indice_BIGCCS,indice_PSS,indice_CGS,indice_GGS,indice_UCS])=0;
        end
    end

    // Limit for BECSS when there is a total limit on CCS 
    if ind_limCCS_InjRate>0  & current_time_im>=start_year_strong_policy-base_year_simulation & current_time_im <= year_stop_CCS_constraint-base_year_simulation
        Cap_elec_MW_ava_conv(:,indice_BIGCCS) = min(Cap_elec_MW_ava_conv(:,indice_BIGCCS),Cap_elec_MW_ava_conv(:,indice_BIGCCS) .* divide(MSH_BIGCCS_cor_factor*max_global_BIGCCS_Cap, sum(Cap_elec_MW_ava_conv(:,indice_BIGCCS)),1) );
    end

    fuelCosts = zeros(reg,nTechnoEndo);
    fuelCosts(:,1:technoConvwoCSP)   = CFuel_i_1(:,1:technoConvwoCSP);
    fuelCosts(:,indice_NND+1:$) = CFuel_i_1(:,[indice_CSP,indice_BIGCC:indice_BIGCCS]);

    if ind_test_gas_price==%t
// Theses lines shall be delete once the FF nexus update done.
// If the price of gaz does not get lower after the update then this will be an issue. For now, this prevents the combi 2001 from stopping in 2024
        if ind_CCS==1 & combi == 2001 & current_time_im>5 //to not mess with first years
            fuelCosts(:,[8,10]) = fuelCosts(:,[8,10])*0.5;
        end
    end


    for tranche = tranches_elec
        execstr ("techno_generation_"+tranche+"=zeros(reg,techno_elec);");
    end
//Central loop for dispatching capacties according to the merit order to meet the residual load.
    for k=1:reg
    [CFuel_croiss,ordre_techno_CFuel]=gsort(fuelCosts(k,:),"g","i");
    ordre_techno_CFuel(ordre_techno_CFuel == technoConv+1) = indice_BIGCC; //so CSP is ell integrated as a dispatchable plant
    ordre_techno_CFuel(ordre_techno_CFuel == technoConv+2) = indice_BIGCCS;
        for j=1:nTechnoEndo
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

    for j=technoEndo
        Utilrate(:,j) = prod_elec_techno(:,j)./((Cap_elec_MW(:,j)+%eps)*full_load_hours); //Utilization rate: ratio of output on theorical maximum ouput based on nominal power
    end
    for k=1:reg
        for j=technoEndo
            if  Utilrate(k,j)>avail_factor(k,j)
                Cap_elec_MW_ava(k,j) = Cap_elec_MW(k,j)*avail_factor(k,j);
            end
        end
    end
end //end of while loop: as long as the utilization rate of some capacities exceeds its availability factor, the loop keeps going. Must think about a way to warm if some demand is not met.


//--------------------------------------------------------------------//
//------------------------- VRE production ---------------------------//
//--------------------------------------------------------------------//

share_ENR_prod_elec=Q_elec_anticip_ENR_i_1./Q_elec_tot_CI;
//Computing VRE production requires some iteration as we only know the gross VRE share
//=> to get the net VRE prod, we need the curtailment rate per techno...for which we need the net VRE share.
// so we need a loop to first compute the curtailment rate per techno, then compute the corresponding net share etc.
// hence the fsolve on the find_net_sh function


//We initialize prod_elec_techno(:,techno_ENRi_endo) with the old formula which does not take into account curtailment
prod_elec_techno(:,techno_ENRi_endo) = divide( repmat(Q_elec_tot_CI,1,length(techno_ENRi_endo)).*repmat(share_ENR_prod_elec,1,length(techno_ENRi_endo)).*(Cap_elec_MW_ava(:,techno_ENRi_endo).*Load_factor_ENR(:,VarRenew_ENR)), repmat(sum(Cap_elec_MW_ava(:,[techno_ENRi_endo]).*Load_factor_ENR(:,VarRenew_ENR),2),1,length(techno_ENRi_endo)), 0);
prod_elec_prev = prod_elec_techno(:,techno_ENRi_endo);

if current_time_im>3 //this condition is only a rustine to avoid a collapse in 2016 (in baseline only, not in climate scenarios).
    //eventually, since the two ways to compute the VRE elec prod are equivalent as long as there is no curtailment (which is the case here)
    //this does not change anything. Yet I don't understand how it messes up witht he static equilibrium.
[output_net_share,v,info] = fsolve([prod_elec_prev],find_net_sh);
    if info~=1
    error("[output_net_share,v,info] =fsolve([prod_elec_prev],find_net_sh);");
    end 
    prod_elec_techno(:,techno_ENRi_endo) = output_net_share.*repmat(Q_elec_tot_CI,1,length(techno_ENRi_endo));
end

prod_elec_techno(prod_elec_techno < 1e-3) = 0;

//Market shares and avoided emissions
msh_elec_techno = prod_elec_techno./(sum(prod_elec_techno,"c")*ones(1,techno_elec));
emi_evitee_elec(:,1) = prod_elec_techno(:,24) / tep2MWh / 1e6 ./ rho_elec_moyen(:,indice_BIGCCS) * elecBiomassInitial.emissionsCCS;
emi_evitee = emi_evitee + emi_evitee_elec;


if current_time_im==1
    sg_add("msh_elec_techno")
end

//--------------------------------------------------------------------//
//----- Cost of electricity generation and electricy IC update -------//
//--------------------------------------------------------------------//

for tranche = tranches_elec
    execstr ("LCC_"+tranche+"_i_1_MWh =  (CINV+OM_cost_fixed_nexus)/"+tranche+"+CFuel_i_1+OM_cost_var_nexus;");
    execstr("LCC_"+tranche+"_i_1_MWh = max(LCC_" + tranche+"_i_1_MWh,1e-10);");
end


//Biomass: some stuff to clean soon
[costBIGCC_withTax,costBIGCCS_withTax,costBIGCC_noTax,costBIGCCS_noTax,breakEvenTax,qBiomExaJ] = ..
computeBiomassCost(elecBiomassInitial.supplyCurve,prod_elec_techno(:,technoBiomass),..
rho_elec_nexus(:,technoBiomass),..
elecBiomassInitial.emissions,elecBiomassInitial.emissionsCCS,..
croyance_taxe,taxCO2_CI(indice_agriculture,indice_elec,:),..
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

p_biom_real_noTax       = costBIGCC_noTax   (:,1)    / tep2kwh; // $/kWh
p_biom_real_CCS_noTax   = costBIGCCS_noTax  (:,1)    / tep2kwh; // $/kWh
p_biom_real_withTax     = costBIGCC_withTax (:,1)    / tep2kwh; // $/kWh
p_biom_real_CCS_withTax = costBIGCCS_withTax(:,1)    / tep2kwh; // $/kWh

p_biom_real_agg_noTax   = [p_biom_real_noTax p_biom_real_CCS_noTax]; // $/kWh
p_biom_real_agg_withTax = [p_biom_real_withTax p_biom_real_CCS_withTax]; // $/kWh

// the unitary use of coal/gaz/liquids per unit of electricity prod
for k=1:reg
    CIdeltaelec(:,indice_elec,k)=CI(:,indice_elec,k);
end

//CIdeltaelec is an intermediary variable for inertia
for k=1:reg
    CIdeltaelec(indice_coal,indice_elec,k)        = sum(prod_elec_techno(k,1:technoCoal)./rho_elec_moyen(k,1:technoCoal))/Q_elec_tot_CI(k);
    CIdeltaelec(indice_gaz,indice_elec,k)         = sum(prod_elec_techno(k,technoCoal+1:technoCoal+technoGas)./rho_elec_moyen(k,technoCoal+1:technoCoal+technoGas))/Q_elec_tot_CI(k);
    CIdeltaelec(indice_Et,indice_elec,k)          = sum(prod_elec_techno(k,technoCoal+technoGas+1:technoFF)./rho_elec_moyen(k,technoCoal+technoGas+1:technoFF))/Q_elec_tot_CI(k);
    CIdeltaelec(indice_agriculture,indice_elec,k) = sum(prod_elec_techno(k,technoBiomass)./rho_elec_moyen(k,technoBiomass).*(p_biom_antcp_agg_noTax(k,:)*tep2kwh))/pArmCI(indice_agriculture,indice_elec,k)/Q_elec_tot_CI(k);
end

if current_time_im==1
    deltaCIbiomassLost = zeros(reg,TimeHorizon+1);
end
for k= 1:reg
    deltaCIbiomassLost(k,current_time_im) = sum(..
    prod_elec_techno(k,technoBiomass)./rho_elec_moyen(k,technoBiomass).*((p_biom_real_agg_noTax(k,:)-(p_biom_real_agg_withTax(k,:)))*tep2kwh)..
    )/pArmCI(indice_agriculture,indice_elec,k);
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
//dans la structure de coût de l'électricité, on reporte la réduction des pertes sur de la connsomation d'industrie à 90% pour

//rester à coût constant. On résout l'equation en x:
//(CI(indice_elec,indice_elec,k)-CI_prev(indice_elec,indice_elec,k))*pArmCI(indice_elec,indice_elec,k)=x*pArmCI(indice_industrie,indice_elec,k)
// for k=1:reg
// 	CI(indice_industrie,indice_elec,k)=CI(indice_industrie,indice_elec,k)+0.9*(CI_prev(indice_elec,indice_elec,k)-CI(indice_elec,indice_elec,k))*pArmCI(indice_elec,indice_elec,k)/pArmCI(indice_industrie,indice_elec,k);
// end

//CCS shares in elec production per FF&biomass use: this update the carbon content of electricity production
sh_CCS_biomass_Q_biomass = zeros(reg,1);
sh_CCS_gaz_Q_gaz = zeros(reg,1);
sh_CCS_col_Q_col = zeros(reg,1);
for k=1:reg
    if sum(prod_elec_techno(k,1:technoCoal),"c")>0
        sh_CCS_col_Q_col(k)=(prod_elec_techno(k,indice_PSS)+prod_elec_techno(k,indice_CGS)+prod_elec_techno(k,indice_UCS))./sum(prod_elec_techno(k,1:technoCoal),"c");
    end
    if sum(prod_elec_techno(k,technoCoal+1:technoCoal+technoGas),"c")>0
        sh_CCS_gaz_Q_gaz(k)=prod_elec_techno(k,indice_GGS)./sum(prod_elec_techno(k,technoCoal+1:technoCoal+technoGas),"c");
    end
    if sum(prod_elec_techno(k,technoBiomass),"c")>0
        sh_CCS_biomass_Q_biomass(k)=sum(prod_elec_techno(k,indice_BIGCCS))./sum(prod_elec_techno(k,technoBiomass));
    end
end

//Electricity prices are following the life-cycle generation costs

//Life-cycle cost of conventionnal power
CFuel_moy      = zeros(reg,techno_elec);
CFuel_moyNoTax = zeros(reg,techno_elec);

for k=1:reg
    for j=1:technoCoal
        CFuel_moy(k,j)      = p_Coal_anticip(k,1)                         / rho_elec_moyen(k,j);
        CFuel_moyNoTax(k,j) = pArmCI_no_taxCO2(indice_coal,indice_elec,k) / rho_elec_moyen(k,j) / tep2kwh;
    end
    for j=technoCoal+1:technoCoal+technoGas
        CFuel_moy(k,j)      = p_Gaz_anticip(k,1)/rho_elec_moyen(k,j);
        CFuel_moyNoTax(k,j) = pArmCI_no_taxCO2(gaz,indice_elec,k) / rho_elec_moyen(k,j) / tep2kwh;
    end
    for j=technoCoal+technoGas+1:technoFF
        CFuel_moy(k,j)      = p_Et_anticip(k,1)/rho_elec_moyen(k,j);
        CFuel_moyNoTax(k,j) = pArmCI_no_taxCO2(et,indice_elec,k) / rho_elec_moyen(k,j) / tep2kwh;
    end
    for j=technoFF+1:techno_elec
        CFuel_moy(k,j)=0;
    end
    j=indice_BIGCC;
    if ETUDE == "emf33" // TODEL
      CFuel_moy(k,j)=p_biom_antcp_withTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost(k);
    else
      CFuel_moy(k,j)=p_biom_antcp_withTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost;
    end
    //CCS is treated separately to remove the CO2 tax on FF
    j=indice_PSS;
    CFuel_moy(k,j)=(pArmCI_no_taxCO2(indice_coal,indice_elec,k)/tep2kwh)/rho_elec_moyen(k,j);
    j=indice_CGS;
    CFuel_moy(k,j)=(pArmCI_no_taxCO2(indice_coal,indice_elec,k)/tep2kwh)/rho_elec_moyen(k,j);
    j=indice_UCS;
    CFuel_moy(k,j)=(pArmCI_no_taxCO2(indice_coal,indice_elec,k)/tep2kwh)/rho_elec_moyen(k,j);
    j=indice_GGS;
    CFuel_moy(k,j)=(pArmCI_no_taxCO2(indice_gaz,indice_elec,k)/tep2kwh)/rho_elec_moyen(k,j);
    
    j=indice_BIGCCS;
    if ETUDE == "emf33"  // TODEL
      CFuel_moy(k,j)=p_biom_antcp_CCS_withTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost(k);
    else
      CFuel_moy(k,j)=p_biom_antcp_CCS_withTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost;
    end
end
CFuel_moyWoBioTax = CFuel_moy;
for k=1:reg
    j=indice_BIGCC;
      CFuel_moyWoBioTax(k,j)=p_biom_antcp_noTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost;
      CFuel_moyNoTax(k,j)=p_biom_antcp_noTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost;
    j=indice_BIGCCS;
      CFuel_moyWoBioTax(k,j)=p_biom_antcp_CCS_noTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost;
      CFuel_moyNoTax(k,j)=p_biom_antcp_CCS_noTax(k,1)/rho_elec_moyen(k,j)+elecBiomassInitial.processCost;
end

sum_LCC         = zeros (reg,techno_elec);
sumLccNoTax     = zeros (reg,techno_elec);
sum_LCCWoBioTax = zeros (reg,techno_elec);

//Life-cycle cost per load band of elec generation
for tranche = tranches_elec
    execstr("LCC_"+tranche+"_moy_MWh         =  (CINV + OM_cost_fixed_nexus) /" + tranche + " + CFuel_moy         + OM_cost_var_nexus;");
    execstr("LCC_"+tranche+"_moyWoBioTax_MWh =  (CINV + OM_cost_fixed_nexus) /" + tranche + " + CFuel_moyWoBioTax + OM_cost_var_nexus;");
    execstr("LCC_"+tranche+"_moyNoTax_MWh    =  (CINV + OM_cost_fixed_nexus) /" + tranche + " + CFuel_moyNoTax    + OM_cost_var_nexus;");

    execstr("LCC_"+tranche+"_moy_MWh(:,technoExo)         =  LCC_ENR;");
    execstr("LCC_"+tranche+"_moyWoBioTax_MWh(:,technoExo) =  LCC_ENR;");
    execstr("LCC_"+tranche+"_moyNoTax_MWh(:,technoExo)    =  LCC_ENR;");

    execstr("LCC_"+tranche+"_moy_MWh         = max(LCC_" + tranche+"_moy_MWh         ,1e-10);");
    execstr("LCC_"+tranche+"_moyWoBioTax_MWh = max(LCC_" + tranche+"_moyWoBioTax_MWh ,1e-10);");
    execstr("LCC_"+tranche+"_moyNoTax_MWh    = max(LCC_" + tranche+"_moyNoTax_MWh    ,1e-10);");

    execstr("sum_LCC         = sum_LCC         + LCC_"+tranche+"_moy_MWh         .* techno_generation_"+tranche+"*"+tranche+";");
    execstr("sum_LCCWoBioTax = sum_LCCWoBioTax + LCC_"+tranche+"_moyWoBioTax_MWh .* techno_generation_"+tranche+"*"+tranche+";");
    execstr("sumLccNoTax     = sumLccNoTax     + LCC_"+tranche+"_moyNoTax_MWh    .* techno_generation_"+tranche+"*"+tranche+";");
end

//Need to compute again the LCOE for renewable by decompositing the VRE markup
LCC_ENR_real=(CINV(:,technoExo)+OM_cost_fixed(:,technoExo,current_time_im))./((Load_factor_ENR(:,technoExo_absolute)*th_to_h+%eps)./(1+curt_VRE))+OM_cost_var(:,technoExo,current_time_im) + Markup_LCC_SIC*share_real_costs;

sum_LCC(:,technoExo)         = sum_LCC(:,technoExo)         + prod_elec_techno(:,technoExo) .* LCC_ENR_real;
sum_LCCWoBioTax(:,technoExo) = sum_LCCWoBioTax(:,technoExo) + prod_elec_techno(:,technoExo) .* LCC_ENR_real;
sumLccNoTax(:,technoExo)     = sumLccNoTax(:,technoExo)     + prod_elec_techno(:,technoExo) .* LCC_ENR_real;

LCOE      = sum_LCC     ./ (prod_elec_techno + 1e-15) .* (prod_elec_techno > 0); // in $/kWh
lcoeNoTax = sumLccNoTax ./ (prod_elec_techno + 1e-15) .* (prod_elec_techno > 0); // in $/kWh
total_CC_elec=sum(sum_LCC,"c"); //total life cycle cost of electricity gen
//Life cycle cost per unit of electricity generation
CC_elec_i_1=total_CC_elec./sum(prod_elec_techno,"c")*tep2kwh;
sysLCOE(:,current_time_im) = CC_elec_i_1/tep2kwh;
if current_time_im==1
    CC_elec_i_1_ref=CC_elec_i_1;
end

total_CC_elecWoBioTax = sum(sum_LCCWoBioTax,"c");
CC_elec_i_1WoBioTax = total_CC_elecWoBioTax./sum(prod_elec_techno,"c")*tep2kwh;

//Computing markup in the electricity sector
if isdef("run_partial_eq_elec")
    else
markup(:,indice_elec)=fsolve(markup(:,indice_elec),calib_markup_elec);
if info~=1
   error("[markup(:,indice_elec),v,info]=fsolve(markup(:,indice_elec),calib_markup_elec) did not work");
end
end
//Applying inertia on the markup
if ind_in_markup_elec
    markup(:,indice_elec) = (1-inertia_elec_markup) * markup(:,indice_elec) + inertia_elec_markup * markup_prev(:,indice_elec);
    markup(:,indice_elec)=max(min(markup(:,indice_elec),markup_prev(:,indice_elec)+0.03),markup_prev(:,indice_elec)-0.03);
end
//Residual peak coverage for the next dynamic equilibrium
//CCS is counted in the coverage, but investment in CCS is not diminshed if peak> required coverage to allow full CCS deployment in climate scenarios
residual_peak_cov = (sum(Cap_elec_MW(:,technoEndo),"c"))./peak_W_anticip_i_1;
