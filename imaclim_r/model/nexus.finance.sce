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

//expression de la demande d'investissement exprimée par les secteurs avec inertie
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

//pas d'inertie sur la demande d'investissement du secteur pétrolier
InvDem(:,indice_oil)=max((K_expected(:,indice_oil)-K_depreciated(:,indice_oil)).*pK(:,indice_oil),0);
//pas d'inertie sur la demande d'investissement du secteur gazier
InvDem(:,indice_gaz)=max((K_expected(:,indice_gaz)-K_depreciated(:,indice_gaz)).*pK(:,indice_gaz),0);
//pas d'inertie sur la demande d'investissement du secteur charbonier
InvDem(:,indice_coal)=max((K_expected(:,indice_coal)-K_depreciated(:,indice_coal)).*pK(:,indice_coal),0);

//on calcule l'investissement demandé par le secteur électrique
InvDem(:,indice_elec)=sum(Inv_MW.*CINV_MW_nexus(:,:)/10^3,"c");
//test limitation de la variation de l'investissement électrique
//InvDem(:,indice_elec)=(InvDem_prev(:,indice_elec)*2/3+InvDem(:,indice_elec)*1/3);
InvDem_prev=InvDem;

// Available investment for productive capital
Inv_val = NRB - sum(pArmDI.*DIinfra,"c");

//on limite Invdem(:,indice_elec) de telle facon que :(InvDem( :,indice_elec))./GDP<= Max_share_inv_elec_GDP
//on limite la part de l'investissement électrique dans le PIB grâce à une information exogène tirée de l'AIE, WIO (p344) sur la période 2001-2015
//if current_time_im<15
//InvDem( :,indice_elec)=min(InvDem( :,indice_elec),Max_share_inv_elec_GDP.*GDP);
//end
sumInvDem=sum(InvDem,"c");

investment.sumInvDem(:,current_time_im) = sumInvDem;
investment.sumInvAll(:,current_time_im) = Inv_val;
investment.invDem(:,:,current_time_im)  = InvDem;

//Si il y a une restriction sur l'investissement, on alloue à l'elec l'investissement qu'elle demande et on restreint uniformément les autres secteurs
for k=1:nb_regions
    if sumInvDem(k)>=Inv_val(k)
        warning((base_year_simulation+current_time_im)+" - Shortage investment in region: "+regnames(k)+" - Excess demanded investment is : "+string(sumInvDem(k)-Inv_val(k)) + " (" +string( (sumInvDem(k)-Inv_val(k))/Inv_val(k)*100)+" %)"  ) ;
        if ( sum(InvDem(k, [elec coal oil gaz])) >Inv_val(k)) 
            if  InvDem(k,elec) > Inv_val(k)
                partInvFin(k,elec) = 1;
                partInvFin(k,oil)  = 0;
                partInvFin(k,gaz)  = 0;
                partInvFin(k,coal) = 0;
                partInvFin(k,[et nonEnergSectors]) = 0*partInvFin(k,[et nonEnergSectors]);
            else
                partInvFin(k,elec) = InvDem(k,elec)./ sum(InvDem(k, [elec coal oil gaz]));
              partInvFin(k,coal) = InvDem(k,coal)./ sum(InvDem(k, [elec coal oil gaz]));
              partInvFin(k,oil)  = InvDem(k,oil )./sum(InvDem(k, [elec coal oil gaz]));
              partInvFin(k,gaz)  = InvDem(k,gaz )./sum(InvDem(k, [elec coal oil gaz]));
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

//répartition uniforme de l'investissement exédentaire, en allouant à l'elec juste ce qu'elle demande
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
        // 		partInvFin_gaz=InvDem(k,indice_gaz)./Inv_val(k);
        // 		partInvFin_coal=InvDem(k,indice_coal)./Inv_val(k);
        // 		for j=1:nb_sectors
        // 			if (j<>indice_oil)&(j<>indice_elec)&(j<>indice_gaz)&(j<>indice_coal) then partInvFin(k,j)=((InvDem(k,j))/(sumInvDem(k)-InvDem(k,indice_elec)-InvDem(k,indice_oil)-InvDem(k,indice_gaz)-InvDem(k,indice_coal)))*(1-partInvFin_elec-partInvFin_oil-partInvFin_gaz-partInvFin_coal); end
        // 		end
        // 		partInvFin(k,indice_elec)=partInvFin_elec;
        // 		partInvFin(k,indice_oil)=partInvFin_oil;
        // 		partInvFin(k,indice_gaz)=partInvFin_gaz;
        // 		partInvFin(k,indice_coal)=partInvFin_coal;

    end
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
if NEXUS_indus==1
    test_invdem_indus=(partInvFin(:,indice_industrie).*Inv_val./InvDem(:,indice_industrie)); // DESAG_INDUSTRY: Should not work with multisector version, but seems to be not in use anymore
end
//disp(test_invdem_indus,current_time_im,'ration de satisfaction de InvDem indus pour l annee ');

//Si l'investissement est excédentaire, on alloue l'investissement exédentaire au composite
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

///////////////on fait tendre partExpK vers 0 : no trade inbalance


if current_time_im==1 then partExpKref=partExpK;end
if current_time_im==1 then partImpKref=partImpK;end

//jusqu'en 2011 on maintient les desequilibres

// if current_time_im<12
// partExpK=partExpKref;
// partImpK=partImpKref;
// else
if ind_partExpK==1 //on maintient les desequilibres
    // partExpK=partExpKref.*GRBref./GRB.*(sum(pArmDFref.*DF+pArmDGref.*DG+pArmDIref.*DI,'c')+sum(Exp.*pref.*(1+xtax)-Imp.*((ones(nb_regions,1)*wpref).*(1)),'c'))./(sum(pArmDFref.*DFref+pArmDGref.*DGref+pArmDIref.*DIref,'c')+sum(Expref.*pref.*(1+xtax)-Impref.*((ones(nb_regions,1)*wpref).*(1)),'c'));
    partExpK=partExpKref;
    partImpK=partImpKref;
elseif ind_partExpK==2 //on reduit les imbalances entre la chine etles us
    partExpK(ind_usa)=(4/5)^current_time_im*partExpKref(ind_usa);
    partExpK(ind_chn)=(4/5)^current_time_im*partExpKref(ind_chn);
    //on reduit aussi les partImK et on reporte sur les autres regions
    partImpK_prev=partImpK;
    partImpK(ind_usa)=(4/5)^current_time_im*partImpKref(ind_usa);
    partImpK(ind_chn)=(4/5)^current_time_im*partImpKref(ind_chn);
    for nb_regions=[ind_can ind_eur ind_jan ind_cis ind_ind ind_bra ind_mde ind_afr ind_ras ind_ral]
        poids_reg=partImpK_prev(nb_regions)./sum(partImpK_prev([ind_can:ind_cis ind_ind:ind_ral]));
        partImpK(nb_regions)=partImpK_prev(nb_regions)+(partImpK_prev(ind_usa)+partImpK_prev(ind_chn)-partImpK(ind_usa)-partImpK(ind_chn)).*poids_reg;
    end
elseif ind_partExpK==0 //no trade imbalance, reducing after begin_rebalance_K
    if current_time_im >= begin_rebalance_K
        partExpK=(4/5)^(current_time_im-begin_rebalance_K+1)*partExpKref;
        partImpK=partImpKref;
    else
        partExpK=partExpKref;
        partImpK=partImpKref;
    end
end
//end

Kval=pK.*K;

energyInvestment = sum(pK(:,1:5).*DeltaK(:,1:5),2);

if current_time_im==(2021-base_year_simulation) & covid_crises_shock==%t
  pK = pK_covidschock_2;
end

