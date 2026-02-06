// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/// Transfers due to carbon markets
// Allocation following a contraciton / convergence rule
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
// Allocation based on GDP/capita
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
        // Computing CO2 transfers (negative if buying - unit 10^6$)
        CO2_transfers=(E_CO2_CC-sum(E_CO2,'c')).*TAXVAL_Poles(:,current_time_im)*1e-6;
        QuotasRevenue=CO2_transfers;
        // 	/////// partExpK modification
        // partExpK_CO2=max(-CO2_transfers./(GRB/p(1,7)),0);
        // 
        // 	/////// partImK modification
        // // computing the size of the pool withotu transfers
        // pool=sum((partExpK).*(GRB/p(1,7)))
        // //computing the size of the new pool
        // pool_n=sum((partExpK+partExpK_CO2).*(GRB/p(1,7)))
        // //computing how partImpK are impacted by carbon transfers flux
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


// After 2010, we export again capital fund that are in excess, spread based of non-satistied demands
// if (current_time_im>9)&(current_time_im<80) 
// 	//price index evolution
// 	mer_ratio=(pind_prod);
// 	Imp_K=zeros(nb_regions,1);
// 	K_exces=zeros(nb_regions,1);
// 	share_Imp_K_GDP=zeros(nb_regions,1);
// 	for k=1:nb_regions
// 	//if the production price index is too low, the region import capital funds
// 		if mer_ratio(k)<1  
// 			share_Imp_K_GDP(k)=(0.2-0)/(0-1)*(mer_ratio(k)-1); 
// 			Imp_K(k)=share_Imp_K_GDP(k)*GDP(k);
// 			partExpK(k)=4/5*partExpK(k);
// 		end
// 	end
// 	//total demand for exporting capital funds
// 	sum_Imp_K=sum(Imp_K);
// 	// partImpK evolution
// 	if sum_Imp_K<>0  
// 		partImpK=Imp_K./sum_Imp_K; 
// 	else
// 		partExpK=4/5*partExpK;
// 	end
// 	//exporting countries are those with producton price indices that rises
// 	//exports are spread at pro rata of the excess of capital
// 	InvDem_tot=sum(InvDem,'c');
// 	Cap_shortage=zeros(nb_regions,1);
// 	
// 	for k=1:nb_regions
// 		if mer_ratio(k)>1
// 			//excess of capital funds are exported
// 			if Inv_val(k)>InvDem_tot(k)*1.05
// 				K_exces(k)=Inv_val(k)-InvDem_tot(k)*1.05;
// 			end
// 		end
// 	end
// 	//computing exported capital funds
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
/////////////// savings technical progress parameters in baseline to use it in policy runs

if current_time_im==1  	
    l_sav_REF=zeros(nb_regions*nb_sectors,TimeHorizon+1);
    CINV_MW_nexus_sav_REF=zeros(nb_regions*techno_elec,TimeHorizon+1);
    CINV_cars_nexus_sav_REF=zeros(nb_regions*nb_techno_cars,TimeHorizon+1);
    l_sav_REF(:,1)=matrix(l_prev,nb_regions*nb_sectors,1);
    //cumulative production capacities by sector
    cum_Cap_sect_REF=zeros(nb_regions*nb_sectors,TimeHorizon+1);
    //cumulative investment by sector
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

////////////////////real lump sum recycling of carbon tax

if sc_CO2Tax_recycl=="RealLumpSum_old" & current_time_im>=start_year_recycl1-base_year_simulation+1
    if current_time_im==start_year_recycl1-base_year_simulation+1
        sg_add(["subtaxbio"; "TAXCO2_sect_bioseqmess"]); //TODO to initialise with biomas power generation calibration; + add in sg_list / save_generic.sci
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

        // Allocation of emissions from the electricity sector to consumers
        // conso_sect_elec=zeros(nb_regions,nb_sectors);
        // TAXCO2_sect_EU=zeros(nb_regions,nb_sectors);
        // TAXCO2_sect_EU(k,:)=TAXCO2_sect(k,:);
        // for k=1:nb_regions
        // conso_sect_elec(k,:)=CI(indice_elec,:,k).*Q(k,:);
        // //spread of losses at pro rata des of final electricity consumption usage
        // pertes_elec(k)=conso_sect_elec(k,indice_elec);
        // conso_sect_elec(k,indice_elec)=0;
        // conso_sect_elec(k,indice_elec+1:nb_sectors)=conso_sect_elec(k,indice_elec+1:nb_sectors)+pertes_elec(k)*conso_sect_elec(k,indice_elec+1:nb_sectors)/(sum(conso_sect_elec(k,indice_elec+1:nb_sectors))+DF(k,indice_elec)+Exp(k,indice_elec));
        // // share_conso_sect_elec(k,:)=conso_sect_elec(k,:)/Q(k,indice_elec);
        //TAXCO2_sect_EU(k,indice_elec)=0;
        //TAXCO2_sect_EU(k,:)=TAXCO2_sect_EU(k,:)+TAXCO2_sect(k,indice_elec)*share_conso_sect_elec(k,:);
        // end

        // if there is quota exchange, revenues of the cost of buying are spread in proportin of how much carbon tax is paid by whome
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
    if sum(qtax<-1+1e-10) >0 & verbose >=1
        warning("qtax recycling: to avoid negative prices, some of CO2 carbon tax revenues have been send back to the Housholdes+Governement budget");
    end
    qtax = max( qtax, -1+1e-10); //no negative prices, the rest of revenues is given back to the Housholdes+Governement budget
end

// True real Lump sum: everyone gets back the tax he paid, even each sectors
if sc_CO2Tax_recycl=="RealLumpSum" & current_time_im>=start_year_recycl1-base_year_simulation
    QTAX_sect_BAU=Q.*p.*base_qtax(:,:,current_time_im)./(1+base_qtax(:,:,current_time_im));
    TAXCO2_recycl=TAXCO2_sect_imp+TAXCO2_sect_dom;
    qtax=((QTAX_sect_BAU-TAXCO2_recycl)./(Q.*p))./(1-(QTAX_sect_BAU-TAXCO2_sect)./(Q.*p));
    if sum(qtax<-1+1e-10) >0 & verbose >=1
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
    if sum(qtax<-1+1e-10) >0 & verbose >=1
        warning("qtax recycling: to avoid negative prices, some of CO2 carbon tax revenues (dedicated to sectors) have been send back to the Housholdes+Governement budget");
    end
    qtax = max( qtax, -1+1e-10); //no negative prices, the rest of revenues is given back to the Housholdes+Governement budget
end

// Warning: Implemented  with little effects; Ttax does not seems to represent a true Added Value tax from GTAP, and is either null or very small
if sc_CO2Tax_recycl=="AdddedValueTaxReduction" & current_time_im>=start_year_recycl1-base_year_simulation
    TAXSAL_BAU_equivalent= sum(DF.*pArmDF.*base_Ttax(:,:,current_time_im));
    TAXCO2_recycl=sum(TAXCO2_imp+TAXCO2_dom,'c');
    msh_recycl = (1+base_Ttax(:,:,current_time_im)) .*DF.*pArmDF ./ ( sum( (1+base_Ttax(:,:,current_time_im)) .*DF.*pArmDF,'c') * ones(1,nb_sectors));
    Ttax = base_Ttax(:,:,current_time_im) - msh_recycl.* (TAXCO2_recycl* ones(1,nb_sectors)) ./ (DF.*pArmDF);
    //Ttax = base_Ttax(:,:,current_time_im) .* (((TAXSAL_BAU_equivalent-TAXCO2_recycl)./TAXSAL_BAU_equivalent) * ones(1,nb_sectors));
    if sum(Ttax<1e-10) >0 & verbose >=1
        warning("Added value tax recycling: to avoid negative prices, some of CO2 carbon tax revenues have been send back to the Housholdes+Governement budget");
    end
    Ttax = max(Ttax, -1+1e-10); //no negative prices, the rest of revenues is given back to the Housholdes+Governement budget
end



// CLIMATE POLICIES


// for all scenario, moving towards endogenous taxe
for i=1:nbMKT
    if (current_time_im+1 == MKT_start_year(i))
        is_quota_MKT(i) = %t;
        is_taxexo_MKT(i) = %f;
    end
end

if current_time_im==1
    obj_offset      = zeros(nbMKT,1);
    sg_add("obj_offset");
end

// Emission objectives
if is_bau & ind_climat <> 1 & ind_climat <> 2
    CO2_obj_MKTparam = %inf * ones (1,nbMKT);
    areEmisConstparam= zeros (1,nbMKT);
else
    objprev =  CO2_obj_MKTparam;
    // 4 year averaghe of emissions, aggregated by market
    obj_offset = mktagg(emi_evitee);
    // Emission objective update
    CO2_obj_MKTparam = CO2_obj_MKT(:,current_time_im+1)-obj_offset;

    // ruben: this is suspected to create oscillation (check 318)
    // we correct the emission obvjective from the precedent emission gap
    //for m=1:nbMKT
    //    emi_m =sum(E_reg_use(whichMKT_reg_use==m));
    //    CO2_obj_MKTparam(m) = CO2_obj_MKTparam(m) - (objprev(m) - emi_m);
    //end

    // constraint market
    for hop=1:size(is_quota_MKT,'*')  //do NOT try to rewrite this loop
        areEmisConstparam(hop) = bool2s (is_quota_MKT(hop) &  (current_time_im+1)>=MKT_start_year(hop));
    end
end
// market with exogenous tax // even defined with is_bau & ind_climat <> 1 & ind_climat <> 2
if sum(is_taxexo_MKT)>0
    for i=1:nbMKT
        if is_taxexo_MKT(i) 
            taxMKT(i) = taxMKTexo(i,current_time_im+1);
        else
            taxMKT(i) = 0;
        end
    end
end


// Lindhal price (regionally differentiated)
if ind_lindhal ==4
    weight_regional_tax_prev = weight_regional_tax;
    weight_regional_tax = GDP_PPP_constant ./ Ltot;
    weight_regional_tax = weight_regional_tax ./ weight_regional_tax(ind_usa);
    // weight_regional_tax = weight_regional_tax .* (1-convergence_regional_tax(current_time_im)) + convergence_regional_tax(current_time_im);
elseif ind_lindhal >=1 & ind_lindhal <=3 
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
    disp([taxMKTexo_origin(current_time_im) / world_tax_comp, taxMKTexo(current_time_im+1), taxMKTexo_origin(current_time_im+1),world_tax_comp], "taxMKTexo(current_time_im) / world_tax_comp, taxMKT,taxMKTexo(current_time_im+1), world_tax_comp");
end

//if ind_lindhal ==2 & current_time_im == 36
if ind_lindhal ==3 & current_time_im == 2050-base_year_simulation
    csvWrite( tax_ind_lindhal_cor, OUTPUT+'/ind_lindhal_tax_correction_'+part(string(combi),1:4)+'.csv');
end
