// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Thomas Le Gallic, Ruben Bibas, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// pK = capital price
for k=1:nb_regions,
    //pArmDI vecteur prix d'armington for investments demand
    pK(k,:) = pArmDI(k,:)*Beta(:,:,k);
end

if current_time_im==(2020-base_year_simulation) & covid_crises_shock==%t
    pK_covidschock_1 = pK;
end
if current_time_im==(2021-base_year_simulation) & covid_crises_shock==%t
    pK_covidschock_2 = pK;
    pK = pK_covidschock_1;
end

// investment demand expressed by sector, with inertia
for j=1:nb_sectors
    if NEXUS_indus==0
        //	if j<>indice_industrie
        InvDem(:,j)=max((K_expected(:,j)-K_depreciated(:,j)).*pK(:,j),0);
        //	end
    end
    if NEXUS_indus==1
        if length(find(j==indice_industries))==0 // DESAG_INDUSTRY: this is an adaptation of if j<>indice_industrie; I hope this option was correctly written.
            InvDem(:,j)=max((K_expected(:,j)-K_depreciated(:,j)).*pK(:,j),0);
        end
    end
end

if NEXUS_indus==1
    exec(MODEL+"Dynamic.industry(1)"+".sce");
    InvDem(:,indice_industrie)=InvDem_tot_indus;
end

//no inertia on investment demand from oil, coal and gas
InvDem(:,indice_oil)=max((K_expected(:,indice_oil)-K_depreciated(:,indice_oil)).*pK(:,indice_oil),0);
InvDem(:,indice_gas)=max((K_expected(:,indice_gas)-K_depreciated(:,indice_gas)).*pK(:,indice_gas),0);
InvDem(:,indice_coal)=max((K_expected(:,indice_coal)-K_depreciated(:,indice_coal)).*pK(:,indice_coal),0);

//investment required by the electricity sector
InvDem(:,indice_elec)=sum(Inv_MW.*CINV_MW_nexus(:,:)/10^3,"c");
//test: limiting the variation of investment in the power sector
//InvDem(:,indice_elec)=(InvDem_prev(:,indice_elec)*2/3+InvDem(:,indice_elec)*1/3);
InvDem_prev=InvDem;

// Available investment for productive capital
Inv_val = NRB - sum(pArmDI.*DIinfra,"c");

sumInvDem=sum(InvDem,"c");
if ind_large_capital_access // To assess the role of capital shortage in climate damage amplification
    Inv_val=sumInvDem*10;
end
investment.sumInvDem(:,current_time_im) = sumInvDem;
investment.sumInvAll(:,current_time_im) = Inv_val;
investment.invDem(:,:,current_time_im)  = InvDem;

// In the case of investment shortage, we give the electricity sector first what it needs, and cut on other sectors needs
for k=1:nb_regions
    if sumInvDem(k)>=Inv_val(k)
        if verbose >= 1
            warning((base_year_simulation+current_time_im)+" - Shortage investment in region: "+regnames(k)+" - Excess demanded investment is : "+string(sumInvDem(k)-Inv_val(k)) + " (" +string( (sumInvDem(k)-Inv_val(k))/Inv_val(k)*100)+" %)");
        end
        if ( sum(InvDem(k, [elec coal oil gaz])) >Inv_val(k)) 
            if  InvDem(k,elec) > Inv_val(k)
                partInvFin(k,elec) = 1;
                partInvFin(k,oil)  = 0;
                partInvFin(k,gaz)  = 0;
                partInvFin(k,coal) = 0;
                partInvFin(k,[et nonEnergSectors]) = 0*partInvFin(k,[et nonEnergSectors]);
            else
                partInvFin(k,elec) = InvDem(k,elec)./ Inv_val(k);
                partInvFin(k,coal) = (1-partInvFin(k,elec)) * InvDem(k,coal)./ sum(InvDem(k, [coal oil gaz]));
                partInvFin(k,oil)  = (1-partInvFin(k,elec)) * InvDem(k,oil )./sum(InvDem(k, [coal oil gaz]));
                partInvFin(k,gaz)  = (1-partInvFin(k,elec)) * InvDem(k,gaz )./sum(InvDem(k, [coal oil gaz]));
                partInvFin(k,[et nonEnergSectors]) = 0*partInvFin(k,[et nonEnergSectors]);
            end
        else    
            partInvFin(k,elec) = InvDem(k,elec)./Inv_val(k);
            partInvFin(k,coal) = InvDem(k,coal)./Inv_val(k);
            partInvFin(k,oil)  = InvDem(k,oil )./Inv_val(k);
            partInvFin(k,gaz)  = InvDem(k,gaz )./Inv_val(k);
            InvDem_temp=InvDem(k,:);
            InvDem_temp(elec) = 0;
            InvDem_temp(oil)  = 0;
            InvDem_temp(gaz)  = 0;
            InvDem_temp(coal) = 0;
            InvDem_temp = InvDem_temp *( Inv_val(k)-sum(InvDem(k,[coal oil gaz elec])))  /sum(InvDem_temp);
            partInvFin(k,[et nonEnergSectors]) = InvDem_temp([et nonEnergSectors]) / Inv_val(k);
        end
    end
end

if or(partInvFin>1|partInvFin<0)
    error((2000+current_time_im+1)+" - There are negative investment shares");
end

// In case of excess investment volume avaiable, we keep what the eletricity sector exact demand
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
for k=1:nb_regions
    if (sumInvDem(k)<Inv_val(k)) & (sumInvDem(k)>0)
        InvDem_Brut=InvDem(k,:);
        Inv_excess=Inv_val(k)-sumInvDem(k);

        //sum(Cap(k,nonEnergSectors).*(x).*pK(k,nonEnergSectors))=Inv_excess
        augment_Cap=Inv_excess/(sum(Cap(k,nonEnergSectors).*pK(k,nonEnergSectors)));
        InvDem_surpl=zeros(1,nb_sectors);
        InvDem_surpl(nonEnergSectors)=augment_Cap.*Cap(k,nonEnergSectors).*pK(k,nonEnergSectors);
        InvDem_temp=InvDem(k,:);
        InvDem_temp=InvDem_temp+InvDem_surpl;
        partInvFin(k,:)=InvDem_temp./sum(InvDem_temp);

        // 		partInvFin_elec=InvDem(k,indice_elec)./Inv_val(k);
        // 		partInvFin_oil=InvDem(k,indice_oil)./Inv_val(k);
        // 		partInvFin_gaz=InvDem(k,indice_gas)./Inv_val(k);
        // 		partInvFin_coal=InvDem(k,indice_coal)./Inv_val(k);
        // 		for j=1:nb_sectors
        // 			if (j<>indice_oil)&(j<>indice_elec)&(j<>indice_gas)&(j<>indice_coal) then partInvFin(k,j)=((InvDem(k,j))/(sumInvDem(k)-InvDem(k,indice_elec)-InvDem(k,indice_oil)-InvDem(k,indice_gas)-InvDem(k,indice_coal)))*(1-partInvFin_elec-partInvFin_oil-partInvFin_gaz-partInvFin_coal); end
        // 		end
        // 		partInvFin(k,indice_elec)=partInvFin_elec;
        // 		partInvFin(k,indice_oil)=partInvFin_oil;
        // 		partInvFin(k,indice_gas)=partInvFin_gaz;
        // 		partInvFin(k,indice_coal)=partInvFin_coal;

    end
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
if NEXUS_indus==1
    test_invdem_indus=(partInvFin(:,indice_industrie).*Inv_val./InvDem(:,indice_industrie)); // DESAG_INDUSTRY: Should not work with multisector version, but seems to be not in use anymore
end
//disp(test_invdem_indus,current_time_im,'ration de satisfaction de InvDem indus pour l annee ');

//In case of excess investment volum, we give it to the composite sectors
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//for k=1:nb_regions
//	if sumInvDem(k)<Inv_val(k)
//		for j=1:nb_sectors
//			if j<>indice_composite then partInvFin(k,j)=InvDem(k,j)/Inv_val(k); end
//		end
//		partInvFin(k,indice_composite)=(InvDem(k,indice_composite)+Inv_val(k)-sumInvDem(k))/Inv_val(k);
//	end
//end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

Inv_val_sec=((Inv_val*ones(1,nb_sectors)).*partInvFin);
investment.invAllocated(:,:,current_time_im) = Inv_val_sec;
investment.partInvFin(:,:,current_time_im)   = partInvFin;

DeltaK = (((Inv_val)*ones(1,nb_sectors)).*partInvFin)./pK;

/////////////// partExpK shrink towards zero: no trade inbalance


if current_time_im==1 then partExpKref=partExpK;end
if current_time_im==1 then partImpKref=partImpK;end

// capital imbalances are kepot for a short period
// if current_time_im<12
// partExpK=partExpKref;
// partImpK=partImpKref;
// else
if ind_partExpK==1 //capital imbalances are kept
    // partExpK=partExpKref.*GRBref./GRB.*(sum(pArmDFref.*DF+pArmDGref.*DG+pArmDIref.*DI,'c')+sum(Exp.*pref.*(1+xtax)-Imp.*((ones(nb_regions,1)*wpref).*(1)),'c'))./(sum(pArmDFref.*DFref+pArmDGref.*DGref+pArmDIref.*DIref,'c')+sum(Expref.*pref.*(1+xtax)-Impref.*((ones(nb_regions,1)*wpref).*(1)),'c'));
    partExpK=partExpKref;
    partImpK=partImpKref;
elseif ind_partExpK==2 //capital imbalances between China and the US are reduced
    partExpK(ind_usa)=(4/5)^current_time_im*partExpKref(ind_usa);
    partExpK(ind_chn)=(4/5)^current_time_im*partExpKref(ind_chn);
    //partImK are reduced and reported on other regions
    partImpK_prev=partImpK;
    partImpK(ind_usa)=(4/5)^current_time_im*partImpKref(ind_usa);
    partImpK(ind_chn)=(4/5)^current_time_im*partImpKref(ind_chn);
    for nb_regions=[ind_can ind_eur ind_jan ind_cis ind_ind ind_bra ind_mde ind_afr ind_ras ind_ral]
        poids_reg=partImpK_prev(nb_regions)./sum(partImpK_prev([ind_can:ind_cis ind_ind:ind_ral]));
        partImpK(nb_regions)=partImpK_prev(nb_regions)+(partImpK_prev(ind_usa)+partImpK_prev(ind_chn)-partImpK(ind_usa)-partImpK(ind_chn)).*poids_reg;
    end
elseif ind_partExpK==3 // we reduce the capital imbalances, with slowly moving partExpK, and raising imports towards the AFR region
    if current_time_im >= begin_coop_K
        partImpK_prev=partImpK;
        for k=[ind_can ind_eur ind_jan]
            partImpK(k)=(38/40)^current_time_im*partImpKref(k);
        end
        partImpK(ind_afr)=partImpK_prev(ind_afr)+partImpK_prev(ind_can)+partImpK_prev(ind_eur)+partImpK_prev(ind_jan)-partImpK(ind_eur)-partImpK(ind_jan)-partImpK(ind_can);
    else
        partImpK=partImpKref;
    end
    if current_time_im >= begin_rebalance_K
        partExpK=(9/10)^(current_time_im-begin_rebalance_K+1)*partExpKref;
    else
        partExpK=partExpKref;
    end
elseif ind_partExpK==0 //no trade imbalance, reducing after begin_rebalance_K
    if current_time_im >= begin_rebalance_K
        partExpK=(1-1/t_partExpK)^(current_time_im-begin_rebalance_K+1)*partExpKref;
    else
        partExpK=partExpKref;
    end
end
//end


Kval=pK.*K;

energyInvestment = sum(pK(:,1:5).*DeltaK(:,1:5),2);

if current_time_im==(2021-base_year_simulation) & covid_crises_shock==%t
    pK = pK_covidschock_2;
end
///////////////////////////////////////////////////////
//////////// INTERNATIONAL FINANCE REBALANCING ////////
///////////////////////////////////////////////////////
/// Regional capital shortage index ///

if ind_K_shortage_index==0
    K_shortage_index = sum((InvDem.*FCC),'c')./sum(InvDem,'c')-0.7; //0.1 if charge = 0. // must stay positive in order to avoid partImpK eventually beiing equal to 0.
elseif ind_K_shortage_index==1
    K_shortage_index = sum((GDP_sect.*FCC),'c')./sum(GDP_sect,'c')-0.7; //0.1 if charge = 0. // must stay positive in order to avoid partImpK eventually beiing equal to 0.
end
if ind_IntFin == 1 // Logit-based evolution of partImpK depending on global GDP share & FCC index
    alpha_FCC=ones(reg);
    if ind_K_shortage_index==0
        partImpK_weight =  ((K_shortage_index.^alpha_FCC) + partImpK_weight_prev)/2; //Smoothing the evolution of partImpK_weight to avoid drastic oscillatory behaviours.
    elseif ind_K_shortage_index==1
        partImpK_weight =  ((K_shortage_index.^alpha_FCC)); //Smoothing the evolution of partImpK_weight to avoid drastic oscillatory behaviours.
    end
    // Logit coefficient = partImpK_weight        
    partImpK_targ = (partImpK_weight./partImpK_weight_prev).*partImpK_targ./sum((partImpK_weight./partImpK_weight_prev).*partImpK_targ);    
    if current_time_im > start_year_policy-base_year_simulation
        partImpK= partImpK_targ+ exp(-(current_time_im - start_year_policy + base_year_simulation)/tau_ImpK)*(partImpKref-partImpK_targ);
        if verbose >=1; disp('Part Imp K: '+partImpK); end;
    end
end

K_shortage_index_prev=K_shortage_index;
partImpK_weight_prev=partImpK_weight;

if indice_LED == 0 & ind_SC_indus_towards_services == "full_SC"
    for k=1:reg
        for i=1:nb_sectors_industry
            Beta(indice_industries(i),indice_composite,k)=min(Beta(indice_industries(i),indice_composite,k),...
                Betaref(indice_industries(i),indice_composite,k)*deltaKbrut(k,indice_composite)/DeltaK(k,indice_composite)...
            * DF(k,indice_industries(i)) ./ DFref(k,indice_industries(i)) .* DFref(k,indice_composite) ./ DF(k,indice_composite));
        end
        //Report on services to services intermediate consumtpion in capital formation (assuming constant capital costs)
        Beta(indice_composite,indice_composite,k)=Beta_prev(indice_composite,indice_composite,k)+...
        sum((-Beta(indice_industries,indice_composite,k)+Beta_prev(indice_industries,indice_composite,k)).*pArmDI(indice_industries,k),'r')/pArmDI(indice_composite,k);
    end

    for k=1:reg
        for i=1:nb_sectors_industry
            Beta(indice_industries(i),indice_industries(i),k)=min(Beta(indice_industries(i),indice_industries(i),k),...
                Betaref(indice_industries(i),indice_industries(i),k)*deltaKbrut(k,indice_industries(i))/DeltaK(k,indice_industries(i))...
            * DF(k,indice_industries(i)) ./ DFref(k,indice_industries(i)) .* DFref(k,indice_composite) ./ DF(k,indice_composite));
        end
        //Report on services to services intermediate consumtpion in capital formation (assuming constant capital costs)
        Beta(indice_composite,indice_industries(i),k)=Beta_prev(indice_composite,indice_industries(i),k)+...
        sum((-Beta(indice_industries,indice_industries(i),k)+Beta_prev(indice_industries,indice_industries(i),k)).*pArmDI(indice_industries,k),'r')/pArmDI(indice_composite,k);
    end
end



