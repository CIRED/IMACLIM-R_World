///calcul des transferts dus au marché du carbone
//allocations selon la règle contraction convergence
if ind_quota==1 
    if max(TAXVAL)>0  
        if ~isdef('sh_CO2_CC_ref')
            sh_CO2_CC_ref=sum(E_CO2,'c')./sum(E_CO2);

            Ltot_2100=csvRead(path_climatePolicy_Ltot+'Ltot_2100.csv','|',[],[],[],'/\/\//');

            sh_CO2_CC_2100=Ltot_2100/sum(Ltot_2100);
            i_start_CC_CO2=current_time_im;
            sh_CO2_CC=zeros(nb_regions,1);
        end
        for k=1:nb_regions
            sh_CO2_CC(k)=interpln([[i_start_CC_CO2,99];[sh_CO2_CC_ref(k),sh_CO2_CC_2100(k)]],current_time_im);
        end
        //resizing
        E_CO2_CC=sh_CO2_CC.*sum(E_CO2);
    end
end
//allocation selon le PIBréel/capita
if ind_quota==2 
    realGDPpc = GDP_MER_real./Ltot_prev;
    E_CO2_CC=sum(E_CO2)*realGDPpc/sum(realGDPpc);
end

if current_time_im==1
    quotas=zeros(nb_regions,TimeHorizon+1);
    CO2_transfers_t=zeros(nb_regions,TimeHorizon+1);
end

if ind_quota<>0 

    error ("CO2_transfers are not suported yet. Code something consistent")

    if max(taxCO2_DF)>0 | max(taxCO2_CI)>0
        //calcul des transfers de CO2 (négatif si déficitaire ie si doit acheter des quotas) (unité 10^6$)
        CO2_transfers=(E_CO2_CC-sum(E_CO2,'c')).*TAXVAL_Poles(:,current_time_im)*1e-6;
        QuotasRevenue=CO2_transfers;
        // 	///////modification des partExpK
        // partExpK_CO2=max(-CO2_transfers./(GRB/p(1,7)),0);
        // 
        // 	///////modification des partImK
        // //calcul de la taille du pool sans transfers
        // pool=sum((partExpK).*(GRB/p(1,7)))
        // //calcul de la taille du nouveau pool:
        // pool_n=sum((partExpK+partExpK_CO2).*(GRB/p(1,7)))
        // //calcul de la perturbation des parImpK par les flux du marché du CO2
        // partImpK_CO2=zeros(nb_regions,1);
        // for k=1:nb_regions
        // 	if CO2_transfers(k)<0
        // 		partImpK_CO2(k)=partImpK(k)*pool/pool_n-partImpK(k); 
        // 	end
        // 	if CO2_transfers(k)>0
        // 		partImpK_CO2(k)=(partImpK(k)*pool+CO2_transfers(k))/pool_n-partImpK(k); 
        // 	end
        // end
        // partImpK=partImpK+partImpK_CO2;	
        // partExpK=partExpK+partExpK_CO2;	
        quotas(:,current_time_im+1)=E_CO2_CC;
        CO2_transfers_t(:,current_time_im+1)=CO2_transfers;
    end
end


// ////après 2010, on reexporte les capitaux que l'on a en trop et on les répartit au pro rata des demandes non satisfaites
// if (current_time_im>9)&(current_time_im<80) 
// 	//on regarde l'évolution de l'indice des prix à la production
// 	mer_ratio=(pind_prod);
// 	Imp_K=zeros(nb_regions,1);
// 	K_exces=zeros(nb_regions,1);
// 	share_Imp_K_GDP=zeros(nb_regions,1);
// 	for k=1:nb_regions
// 	//si l'indice des prix à la production dérive trop à la baisse, la région importe des capitaux
// 		if mer_ratio(k)<1  
// 			share_Imp_K_GDP(k)=(0.2-0)/(0-1)*(mer_ratio(k)-1); 
// 			Imp_K(k)=share_Imp_K_GDP(k)*GDP(k);
// 			partExpK(k)=4/5*partExpK(k);
// 		end
// 	end
// 	//demande totale de capitaux pour l'exportation
// 	sum_Imp_K=sum(Imp_K);
// 	//on détermine l'évolution des partImpK.
// 	if sum_Imp_K<>0  
// 		partImpK=Imp_K./sum_Imp_K; 
// 	else
// 		partExpK=4/5*partExpK;
// 	end
// 	//les pays qui exportent sont ceux qui ont des indices de prix à la production qui dérivent à la hausse
// 	//les exportations sont réparties au pro rata de l'excès de capital dans ces régions
// 	InvDem_tot=sum(InvDem,'c');
// 	Cap_shortage=zeros(nb_regions,1);
// 	
// 	for k=1:nb_regions
// 		if mer_ratio(k)>1
// 			//on exporte les capitaux que l'on a en trop
// 			if Inv_val(k)>InvDem_tot(k)*1.05
// 				K_exces(k)=Inv_val(k)-InvDem_tot(k)*1.05;
// 			end
// 		end
// 	end
// 	//calcul des capitaux exportés
// 	Exp_Cap=K_exces./sum(K_exces)*sum_Imp_K;
// 	for k=1:nb_regions
// 		if mer_ratio(k)>1
// 			partExpK(k)=Exp_Cap(k)./(GRB(k));
// 		else
// 			partExpK(k)=4/5*partExpK(k);
// 		end
// 	end
// 	partExpK=1/3*partExpK+2/3*partExpK_prev;
// 	partImpK=1/3*partImpK+2/3*partImpK_prev;
// end

// for k=1:nb_regions
// 	if charge(k,indice_composite)>0.80|charge(k,indice_agriculture)>0.85|charge(k,indice_industrie)>0.85 then partExpK(k)=1/2*partExpK_prev(k); end
// end



////////////////////////////////////////////////////////::
///////////////sauvegarde des parmètres de progrès technique en baseline pour utilisation politique + ATC

if indice_ATC_calib_REF 
    if current_time_im==1  	
        l_sav_REF=zeros(nb_regions*nb_sectors,TimeHorizon+1);
        CINV_MW_nexus_sav_REF=zeros(nb_regions*techno_elec,TimeHorizon+1);
        CINV_cars_nexus_sav_REF=zeros(nb_regions*nb_techno_cars,TimeHorizon+1);
        l_sav_REF(:,1)=matrix(l_prev,nb_regions*nb_sectors,1);
        //Capacités cummulées construites par secteur
        cum_Cap_sect_REF=zeros(nb_regions*nb_sectors,TimeHorizon+1);
        //investissement cummulé par secteur
        cum_Inv_sect_REF=zeros(nb_regions*nb_sectors,TimeHorizon+1);
    end
    l_sav_REF(:,current_time_im+1)=matrix(l_prev,nb_regions*nb_sectors,1);
    cum_Cap_sect_REF(:,current_time_im+1)=cum_Cap_sect_REF(:,current_time_im)+matrix(DeltaK,nb_regions*nb_sectors,1);
    cum_Inv_sect_REF(:,current_time_im+1)=cum_Inv_sect_REF(:,current_time_im)+matrix(Inv_val_sec,nb_regions*nb_sectors,1);

    CINV_MW_nexus_sav_REF(:,current_time_im)=matrix(CINV_MW_nexus,nb_regions*techno_elec,1);
    CINV_cars_nexus_sav_REF(:,current_time_im)=matrix(CINV_cars_nexus,nb_regions*nb_techno_cars,1);
    OMcostVarNexusSavREF(:,current_time_im)=matrix(OM_cost_var_nexus,nb_regions*techno_elec,1);
    OMcostFixedNexusSavREF(:,current_time_im)=matrix(OM_cost_fixed_nexus,nb_regions*techno_elec,1);
    rho_elec_nexus_sav_REF(:,current_time_im)=matrix(rho_elec_nexus,nb_regions*techno_elec,1);

end

////////////////////real lump sum recycling of carbon tax

if sc_CO2Tax_recycl=="RealLumpSum_old" & current_time_im>=start_year_recycl1-base_year_simulation+1
    if current_time_im==start_year_recycl1-base_year_simulation+1
        sg_add(["subtaxbio"; "TAXCO2_sect_bioseqmess"]); // à initialiser avec la biomass elec, puis les balancer dans la sg_list dans save_generic.sci
        if ~isdef("qtax_BAU")
            qtax_BAU=qtaxref;
        end
    else
        //QTAX_sect=Q.*p.*qtax./(1+qtax);
        QTAX_sect_BAU=Q.*p.*qtax_BAU./(1+qtax_BAU);
        TAXCO2_sect_bioseqmess=TAXCO2_sect_imp+TAXCO2_sect_dom;
        TAXCO2_sect = TAXCO2_sect_bioseqmess;
        subtaxbio =  matrix(CI(elec,elec,:).*coef_Q_CO2_CI(elec,elec,:).*taxCO2_CI(elec,elec,:),nb_regions,1).*Q(:,elec);
        TAXCO2_sect(:,elec) = TAXCO2_sect_bioseqmess(:,elec) - subtaxbio;
        qtax=((QTAX_sect_BAU-TAXCO2_sect)./(Q.*p))./(1-(QTAX_sect_BAU-TAXCO2_sect)./(Q.*p));

        //allocation des émissions de l'élec aux consommateurs pour effectuer le rebate lumpsum
        // conso_sect_elec=zeros(nb_regions,nb_sectors);
        // TAXCO2_sect_EU=zeros(nb_regions,nb_sectors);
        // TAXCO2_sect_EU(k,:)=TAXCO2_sect(k,:);
        // for k=1:nb_regions
        // conso_sect_elec(k,:)=CI(indice_elec,:,k).*Q(k,:);
        // //répartition des pertes au pro rata des consommations d'usage final d'élec
        // pertes_elec(k)=conso_sect_elec(k,indice_elec);
        // conso_sect_elec(k,indice_elec)=0;
        // conso_sect_elec(k,indice_elec+1:nb_sectors)=conso_sect_elec(k,indice_elec+1:nb_sectors)+pertes_elec(k)*conso_sect_elec(k,indice_elec+1:nb_sectors)/(sum(conso_sect_elec(k,indice_elec+1:nb_sectors))+DF(k,indice_elec)+Exp(k,indice_elec));
        // // share_conso_sect_elec(k,:)=conso_sect_elec(k,:)/Q(k,indice_elec);
        //TAXCO2_sect_EU(k,indice_elec)=0;
        //TAXCO2_sect_EU(k,:)=TAXCO2_sect_EU(k,:)+TAXCO2_sect(k,indice_elec)*share_conso_sect_elec(k,:);
        // end

        //si echanges de quotas, on reparti les revenus des ventes de quotas ou le cout d'achat des quotas proportionnellement a ce que chacun paie de taxe
        // for k=1:nb_regions,
        // if TAXCO2(k)<>0
        // TAXCO2_sect_EU(k,:)=((TAXCO2(k)+QuotasRevenue(k))./TAXCO2(k)).*TAXCO2_sect_EU(k,:);
        // end
        // end

        //Q.*p.*qtax./(1+qtax)+TAXCO2_sect=QTAX_sect_BAU
        //qtax./(1+qtax)=(QTAX_sect_BAU-TAXCO2_sect)./(Q.*p)
        // qtax=((QTAX_sect_BAU-TAXCO2_sect_EU)./(Q.*p))./(1-(QTAX_sect_BAU-TAXCO2_sect_EU)./(Q.*p));

    end
end

if sc_CO2Tax_recycl=="ProdTaxReduction" & current_time_im>=start_year_recycl1-base_year_simulation
    QTAX_sect_BAU=Q.*p.*base_qtax(:,:,current_time_im)./(1+base_qtax(:,:,current_time_im));
    TAXCO2_recycl=sum(TAXCO2_imp+TAXCO2_dom,'c');
    // We look for alpha so as   (1+qtax_new) =alpha (1+qtax_ol)
    alpha_cor = (sum(Q.*p,'c') - ( sum(QTAX_sect_BAU,'c')-TAXCO2_recycl)) ./ sum(Q.*p ./ (1+base_qtax(:,:,current_time_im)),'c');
    qtax = (1+base_qtax(:,:,current_time_im) - alpha_cor * ones(1,nb_sectors)) ./ (alpha_cor * ones(1,nb_sectors));
    if sum(qtax<-1+1e-10) >0
        warning("qtax recycling: to avoid negative prices, some of CO2 carbon tax revenues have been send back to the Housholdes+Governement budget");
    end
    qtax = max( qtax, -1+1e-10); //no negative prices, the rest of revenues is given back to the Housholdes+Governement budget
end

// True real Lump sum: everyone gets back the tax he paid, even each sectors
if sc_CO2Tax_recycl=="RealLumpSum" & current_time_im>=start_year_recycl1-base_year_simulation
    QTAX_sect_BAU=Q.*p.*base_qtax(:,:,current_time_im)./(1+base_qtax(:,:,current_time_im));
    TAXCO2_recycl=TAXCO2_sect_imp+TAXCO2_sect_dom;
    qtax=((QTAX_sect_BAU-TAXCO2_recycl)./(Q.*p))./(1-(QTAX_sect_BAU-TAXCO2_sect)./(Q.*p));
    if sum(qtax<-1+1e-10) >0
        warning("qtax recycling: to avoid negative prices, some of CO2 carbon tax revenues (dedicated to sectors) have been send back to the Housholdes+Governement budget");
    end
    qtax = max( qtax, -1+1e-10); //no negative prices, the rest of revenues is given back to the Housholdes+Governement budget
end

// A more efficient RealLumpSum; not a true RealLumpSum as the revenues across sectors is not given back explicitely to who paid for it.
// More like the "ProdTaxReduction" variant
if sc_CO2Tax_recycl=="RealLumpSum More Efficient" & current_time_im>=start_year_recycl1-base_year_simulation
    QTAX_sect_BAU=Q.*p.*base_qtax(:,:,current_time_im)./(1+base_qtax(:,:,current_time_im));
    TAXCO2_recycl=sum(TAXCO2_sect_imp+TAXCO2_sect_dom,'c');
    // We look for alpha so as   (1+qtax_new) =alpha (1+qtax_ol)
    alpha_cor = (sum(Q.*p,'c') - ( sum(QTAX_sect_BAU,'c')-TAXCO2_recycl)) ./ sum(Q.*p ./ (1+base_qtax(:,:,current_time_im)),'c');
    qtax = (1+base_qtax(:,:,current_time_im) - alpha_cor * ones(1,nb_sectors)) ./ (alpha_cor * ones(1,nb_sectors));
    if sum(qtax<-1+1e-10) >0
        warning("qtax recycling: to avoid negative prices, some of CO2 carbon tax revenues (dedicated to sectors) have been send back to the Housholdes+Governement budget");
    end
    qtax = max( qtax, -1+1e-10); //no negative prices, the rest of revenues is given back to the Housholdes+Governement budget
end

// Warning: Implemented  with little effects; Ttax does not seems to represent a true Added Value tax from GTAP, and is either null or very small
if sc_CO2Tax_recycl=="AdddedValueTaxReduction" & current_time_im>=start_year_recycl1-base_year_simulation
    TAXSAL_BAU_equivalent= sum(DF.*pArmDF.*base_Ttax(:,:,current_time_im);
    TAXCO2_recycl=sum(TAXCO2_imp+TAXCO2_dom,'c');
    msh_recycl = (1+base_Ttax(:,:,current_time_im)) .*DF.*pArmDF ./ ( sum( (1+base_Ttax(:,:,current_time_im)) .*DF.*pArmDF,'c') * ones(1,nb_sectors));
    Ttax = base_Ttax(:,:,current_time_im) - msh_recycl.* (TAXCO2_recycl* ones(1,nb_sectors)) ./ (DF.*pArmDF);
    //Ttax = base_Ttax(:,:,current_time_im) .* (((TAXSAL_BAU_equivalent-TAXCO2_recycl)./TAXSAL_BAU_equivalent) * ones(1,nb_sectors));
    if sum(Ttax<1e-10) >0
        warning("Added value tax recycling: to avoid negative prices, some of CO2 carbon tax revenues have been send back to the Housholdes+Governement budget");
    end
    Ttax = max(Ttax, -1+1e-10); //no negative prices, the rest of revenues is given back to the Housholdes+Governement budget
end



//POLITIQUES CLIMATIQUES

for i=1:nbMKT

    if (ind_climat == 99) //9 is NPi/NDC calibration. 
        if (current_time_im+1 == smooth_exo_tax(i)) // current_time_im+1 bcse smooth_exo_tax starts in 2014
            is_quota_MKT(i) = %f;
            is_taxexo_MKT(i) = %t;
            
        end 

        if (current_time_im+1 == MKT_start_year(i)) // starting quota mode
            is_quota_MKT(i) = %t;
            is_taxexo_MKT(i) = %f;
        end 
        if (current_time_im+1 == start_tax + duration_NDC) // going back to exogenous tax mode
            is_quota_MKT(i) = %f;
            is_taxexo_MKT(i) = %t;
        end 
    end
end
if current_time_im==1
    obj_offset      = zeros(nbMKT,1);
    sg_add("obj_offset");
end

//Objectis d'emisisons
if is_bau & ind_climat <> 1 & ind_climat <> 2
    CO2_obj_MKTparam = %inf * ones (1,nbMKT);
    areEmisConstparam= zeros (1,nbMKT);
else
    objprev =  CO2_obj_MKTparam;
    //Moyenne des emissions evitees depuis 4 ans, aggregees par marche
    obj_offset = mktagg(emi_evitee);
    //Actualisation de l'objectiv
    CO2_obj_MKTparam = CO2_obj_MKT(:,current_time_im+1)-obj_offset;

    // ruben: this is suspected to create oscillation (check 318)
    //on corrige l'objectif prochain du gap precedent
    //for m=1:nbMKT
    //    emi_m =sum(E_reg_use(whichMKT_reg_use==m));
    //    CO2_obj_MKTparam(m) = CO2_obj_MKTparam(m) - (objprev(m) - emi_m);
    //end

    //flag les marches contraints
    for hop=1:size(is_quota_MKT,'*')  //do NOT try to rewrite this loop
        areEmisConstparam(hop) = bool2s (is_quota_MKT(hop) &  (current_time_im+1)>=MKT_start_year(hop));
    end

    //marches a taxe exogene
        if sum(is_taxexo_MKT)>0
            for i=1:nbMKT
                if is_taxexo_MKT(i) 
                    taxMKT(i) = taxMKTexo(i,current_time_im+1);
                else
                    taxMKT(i) = 0;
                end
            end
            //note : ceci pourrait etre n'importe ou dans dynamique, tant que expand_tax n'est pas appellé trop tot
        end
    
end


// Lindhal price
if ind_lindhal >=1
    weight_regional_tax_prev = weight_regional_tax;
    weight_regional_tax = GDP_PPP_constant ./ Ltot;
    weight_regional_tax = weight_regional_tax ./ weight_regional_tax(ind_usa);
    weight_regional_tax = weight_regional_tax .* (1-convergence_regional_tax(current_time_im)) + convergence_regional_tax(current_time_im);
end

// compute the difference between the target price
if ind_lindhal ==3 & current_time_im +1 >= start_stronger_policy
    emi_reg = sum(E_reg_use,'c') + emi_evitee;
    world_tax_comp = sum(taxCO2_DF(:,1) .* emi_reg) ./ sum(emi_reg);
    tax_ind_lindhal_cor(current_time_im) = tax_ind_lindhal_cor(current_time_im) .* taxMKTexo_origin(current_time_im) / world_tax_comp;
    //disp([taxMKTexo_origin(current_time_im) / world_tax_comp, taxMKTexo(current_time_im+1), taxMKTexo_origin(current_time_im+1),world_tax_comp], "taxMKTexo(current_time_im) / world_tax_comp, taxMKT,taxMKTexo(current_time_im+1), world_tax_comp");
end

//if ind_lindhal ==2 & current_time_im == 36
if ind_lindhal ==3 & current_time_im == 36
    csvWrite( tax_ind_lindhal_cor, OUTPUT+'/ind_lindhal_tax_correction_'+part(string(combi),1:4)+'.csv');
end

