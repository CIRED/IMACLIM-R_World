///////////////////////////////////////////////////////////////////////////////
//Note of priority, elements to check or to change in future version of the nexus
//1.check if the lines that prevent prices and quantities of biofuels to decrease are necessary
//2.revise the way biofuel production is allocated to regions
///////////////////////////////////////////////////////////////////////////////


//anticipation of global fuel demand
Q_Et_anticip            = Q(:,indice_Et) .* taux_Q_nexus(:,indice_Et);
Q_Et_anticip_world      = sum(Q_Et_anticip);

//////////////////////////////////////biofuels///////////////////////////////////////////////////////////

//Quantity of ethanol available at the anticipated price of liquid fuels
if pEtOilExpWldTxEthan<max(p_Et_lge_ethan)  
    Q_ethan_anticip_world=interp1(p_Et_lge_ethan,supply__ethan(current_time_im,:)*sbc_cff,pEtOilExpWldTxEthan,"nearest");
    p_ethan_mtep_prev=p_ethan_mtep;
    p_ethan_mtep=pEtOilExpWldTxEthan/(lge2Mtoe*10^6);
else
    Q_ethan_anticip_world=max(supply__ethan(current_time_im,:)*sbc_cff);
    p_ethan_mtep_prev=p_ethan_mtep;
    p_ethan_mtep=max(p_Et_lge_ethan)/(lge2Mtoe*10^6);
end
//only increasing price (?)
p_ethan_mtep=max(p_ethan_mtep_prev,p_ethan_mtep);

//Quantity of biodiesel available at the anticipated price of liquid fuels
if pEtOilExpWldTxBiodies<max(p_Et_lge_biodies)
    Q_biodies_anticip_world=interp1(p_Et_lge_biodies,supply__biodies(current_time_im,:)*sbc_cff,pEtOilExpWldTxBiodies,"nearest");
    p_biodies_mtep_prev=p_biodies_mtep;
    p_biodies_mtep=pEtOilExpWldTxBiodies/(lge2Mtoe*10^6);
else
    p_biodies_mtep_prev=p_biodies_mtep;
    Q_biodies_anticip_world=max(supply__biodies(current_time_im,:)*sbc_cff);
    p_biodies_mtep=max(p_Et_lge_biodies)/(lge2Mtoe*10^6);
end
//only increasing price (?)
p_biodies_mtep=max(p_biodies_mtep_prev,p_biodies_mtep);

//Allocation of biofuel production per regions
//We assume that regional production is proportionnal to its production of liquid fuels (revising this assumption would be good to reflect more biofuel production potentials by regions)
if current_time_im==1 
    Q_ethan_anticip=zeros(reg,1);
    Q_biodies_anticip=zeros(reg,1);
end
Q_ethan_anticip_prev=Q_ethan_anticip;
Q_biodies_anticip_prev=Q_biodies_anticip;

Q_ethan_anticip=Q_ethan_anticip_world*Q(:,indice_Et)./sum(Q(:,indice_Et));
Q_biodies_anticip=Q_biodies_anticip_world*Q(:,indice_Et)./sum(Q(:,indice_Et));
//Quantities anticipated are always increasing (?)
Q_ethan_anticip=max(Q_ethan_anticip_prev,Q_ethan_anticip);
Q_biodies_anticip=max(Q_biodies_anticip_prev,Q_biodies_anticip);

//Some inertia on changing quantities produced
for k=1:reg
    Q_ethan_anticip(k)=inert_biofuel*Q_ethan_anticip_prev(k)+(1-inert_biofuel)*Q_ethan_anticip(k);
    Q_biodies_anticip(k)=inert_biofuel*Q_biodies_anticip_prev(k)+(1-inert_biofuel)*Q_biodies_anticip(k);
end

//Total quantity of biofuels (sum of ethanol and biodiesel
Q_biofuel_anticip=Q_biodies_anticip+Q_ethan_anticip;


// Variant in which we use nexus land use biofuel production computation
if ind_NLU_bioener == 1
    Q_biofuel_anticip = Qbiofuel_NLU ;
end

// in case we want to increase low carbon fuels in aviation compare to a reference scenario, 
// part of Q_biofuel_anticip becomes exogene
if ind_aviation_LCF>=1
    inc_Q_biofuel_aviation = (exo_share_biofuel_aviat(1,current_time_im)-sum(Q_biofuel_anticip)./sum(Q_Et_anticip)).* sum(Q_Et_anticip);
    Q_biofuel_anticip = Q_biofuel_anticip + inc_Q_biofuel_aviation .* Q_biofuel_anticip ./ sum(Q_biofuel_anticip);

    share_biodies_temp = Q_biodies_anticip ./ (Q_biodies_anticip+Q_ethan_anticip);
    Q_biodies_anticip = share_biodies_temp .* Q_biofuel_anticip;
    Q_ethan_anticip = (1-share_biodies_temp) .* Q_biofuel_anticip;

    p_ethan_temp = interp1(supply__ethan(current_time_im,:)*sbc_cff,p_Et_lge_ethan,sum(Q_ethan_anticip),"nearest");
    p_ethan_mtep = min(p_ethan_temp, max(p_Et_lge_ethan)) /(lge2Mtoe*10^6);

    p_biodies_temp = interp1(supply__biodies(current_time_im,:)*sbc_cff,p_Et_lge_biodies, sum(Q_biodies_anticip),"nearest");
    p_biodies_mtep = min(p_biodies_temp, max(p_Et_lge_biodies)) /(lge2Mtoe*10^6);
end


//Computing the cost structure for biofuels
//Assuming all input is bought from agriculture, and the margin ratio is the same as for liquid fuels from fossil
Cost_struc_biofuel=zeros(reg,sec+2);


// Variant in which we use nexus land use biofuel production computation
if ind_NLU_bioener == 1 // with NLU linkage
    Q_biofuel_anticip = Qbiofuel_NLU ;
  // same cost structure as liquid fuels from fossil, except for CI oil and ET
  if alternCostStructBiofuels
      Cost_struc_biofuel = Cost_struc_oil_refin_ref;
      Cost_struc_biofuel(:,[ oil et ]) = 0;
  end

  for k=1:reg
      if Q_biofuel_anticip(k)>0
          if ~build_et_curve_NLU
              Cost_struc_biofuel(k,sec+2)= ( pind(k) .* ethan2G_transfo_cost ) ./ ( p(k,et) ) *(1/(1+qtax(k,indice_Et))) ;
              Cost_struc_biofuel(k,indice_agriculture) = (( Tot_bioelec_cost_del(k)) .* tep2gj )*(1/(1+qtax(k,indice_Et)))/pArmCI(indice_agriculture,indice_Et,k);
          end
      end
  end
else // with IEA supply curves
   
  for k=1:reg
    if Q_biofuel_anticip(k)>0 
        Cost_struc_biofuel(k,sec+2)=Cost_struc_oil_refin_ref(k,sec+2);
        Cost_struc_biofuel(k,indice_agriculture) = ((Q_biodies_anticip(k)*p_biodies_mtep+Q_ethan_anticip(k)*p_ethan_mtep)/Q_biofuel_anticip(k))*(1/(1+qtax(k,indice_Et))-Cost_struc_biofuel(k,sec+2))/pArmCI(indice_agriculture,indice_Et,k);
    end
  end

end



////////////////////////////////////////////////// Synfuels CTL///////////////////////////////////////////////////////////////
[Q_CTL_anticip,p_CTL_mtep,price_CTL,Cost_struc_CTL]=nexusCTL(ctl_inert_lag);

//Variant of the model without synfuel CTL
if ind_NO_CTL==1 | current_time_im<start_year_strong_policy-base_year_simulation 
	Q_CTL_anticip=zeros(nb_regions,1);
end;

//recomputing the shares for each types of liquid fuels
//quantity from fossil
Q_oil_refin_anticip = max( Q_Et_anticip - Q_biofuel_anticip - Q_CTL_anticip , 0);
max_biofuel=( Q_Et_anticip - Q_CTL_anticip  > Q_biofuel_anticip );

if ind_NLU_bioener ==1
  // not allowing the share of liquid fuels from oil to go to exactly zero, minimum bound set at 0.0001
  if current_time_im>1
      for k=1:reg
          if Q_oil_refin_anticip(k) == 0
              share_oil_refin(k) = min_share_oil_refined;
              Q_oil_refin_anticip(k) = ( Q_biofuel_anticip(k) + Q_CTL_anticip(k)) * share_oil_refin(k) / ( 1- share_oil_refin(k) ) ;
          end
       end
  end 

  Q_Et_anticip = Q_oil_refin_anticip + Q_biofuel_anticip + Q_CTL_anticip;

  share_biofuel=divide(Q_biofuel_anticip,Q_Et_anticip,0);
  share_biofuel= Q_biofuel_anticip ./ Q_Et_anticip;
  share_oil_refin=divide(Q_oil_refin_anticip,Q_Et_anticip,0);
  share_CTL=divide(Q_CTL_anticip,Q_Et_anticip,0);
else 
  Q_Et_anticip = Q_oil_refin_anticip + Q_biofuel_anticip + Q_CTL_anticip;
  //avoiding share_oil_refin to go to 0, adding a non-zero minimum bound
  if current_time_im>1
    share_oil_refin_prev=share_oil_refin;
    share_biofuel_prev=share_biofuel;
    share_CTL_prev=share_CTL;
  end

  share_biofuel=Q_biofuel_anticip./Q_Et_anticip;
  share_oil_refin=Q_oil_refin_anticip./Q_Et_anticip;
  share_CTL=Q_CTL_anticip./Q_Et_anticip;

  if current_time_im>1
    for k=1:reg
        if share_oil_refin_prev(k)==(1-0.999) 
            share_oil_refin(k)=share_oil_refin_prev(k);
            share_biofuel(k)=share_biofuel_prev(k);
            share_CTL(k)=share_CTL_prev(k);
        end
    end
  end
end

//Recomputing the average cost structure for all liquid fuels
if build_et_curve_NLU
    CI_temp_NLU = CI;
    l_temp_NLU = l;
    markup_temp_NLU = markup;
    for k=1:reg
        CI_temp_NLU(:,indice_Et,k)=Cost_struc_biofuel(k,1:sec)'*share_biofuel(k)+Cost_struc_oil_refin_ref(k,1:sec)'*share_oil_refin(k)+Cost_struc_CTL(k,1:sec)'*share_CTL(k);
        l_temp_NLU(k,indice_Et)=Cost_struc_biofuel(k,sec+1)'*share_biofuel(k)+Cost_struc_oil_refin_ref(k,sec+1)'*share_oil_refin(k)+Cost_struc_CTL(k,sec+1)'*share_CTL(k);
        markup_temp_NLU(k,indice_Et)=Cost_struc_biofuel(k,sec+2)'*share_biofuel(k)+Cost_struc_oil_refin_ref(k,sec+2)'*share_oil_refin(k)+Cost_struc_CTL(k,sec+2)'*share_CTL(k);
    end
else
    for k=1:reg
        CI(:,indice_Et,k)=Cost_struc_biofuel(k,1:sec)'*share_biofuel(k)+Cost_struc_oil_refin_ref(k,1:sec)'*share_oil_refin(k)+Cost_struc_CTL(k,1:sec)'*share_CTL(k);
        l(k,indice_Et)=Cost_struc_biofuel(k,sec+1)'*share_biofuel(k)+Cost_struc_oil_refin_ref(k,sec+1)'*share_oil_refin(k)+Cost_struc_CTL(k,sec+1)'*share_CTL(k);
        markup(k,indice_Et)=Cost_struc_biofuel(k,sec+2)'*share_biofuel(k)+Cost_struc_oil_refin_ref(k,sec+2)'*share_oil_refin(k)+Cost_struc_CTL(k,sec+2)'*share_CTL(k);
      if ind_NLU_bioener == 1
        CI(:,et,k) = inertiaShareEt * CI_prev(:,et,k) + ( 1 - inertiaShareEt) * CI(:,et,k) ;
        if ~toomuch_bioener & share_biofuel_real(k) > share_biofuel(k)
            share_biofuel(k) = share_biofuel_real(k);
        else
            share_biofuel_real(k) = share_biofuel(k);
        end
        share_biofuel(k) = 1- divide(CI(indice_coal,indice_Et,k),Cost_struc_CTL(k,indice_coal),0)-CI(indice_oil,indice_Et,k)/CIref(indice_oil,indice_Et,k) ;
        markup(k,indice_Et) = inertiaShareEt *  markup_prev(k,indice_Et) + ( 1 - inertiaShareEt) *markup(k,indice_Et) ;
        l(k,indice_Et) = inertiaShareEt *  l_prev(k,indice_Et) + ( 1 - inertiaShareEt) * l(k,indice_Et) ;
      end
    end
end

