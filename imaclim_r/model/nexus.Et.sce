// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thomas Le Gallic, Thibault Briera, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

////////////////////////////////////////////////////////////////////////
////////////////Nexus Liquid Fuels////////////////////////////
////////////////////////////////////////////////////////////////////////

// update the weight for new market share computation
// the name of the variable - with zeroing - is quite misleading, but the idea is indeed to make this weight go to one
if current_time_im >1
    if new_Et_msh_computation==1
        weightEt_new = weightEt_new - (weightEt_new-1) / time_zeroing_weightEt_new ;
    end
end

exec(MODEL+"nexus.Et.coststruct.sce");

if ind_NLU >0 
    K_expected(:,indice_Et) = max( Q_Et_anticip/ base_charge_noFCC(indice_Et) , 0 ); // added max(0,-) to prevent negative capacities
end

////////////////////////////////////////
//Recomputing emissions coefficients
////////////////////////////////////////
//For synfuel (CTL), we assume the final fuel produced is comparable in terms of emission intensity to fuel from oil

coef_Q_CO2_CTL=coef_Q_CO2_ref(:,indice_Et);
coef_Q_CO2_biofuels=zeros(reg,1);
for k=1:reg
    if Q_biofuel_anticip(k)>0
        coef_Q_CO2_biofuels(k)=coef_Q_CO2_biodiesel(k).*Q_biodies_anticip(k)./Q_biofuel_anticip(k)+coef_Q_CO2_ethan(k).*Q_ethan_anticip(k)./Q_biofuel_anticip(k);
    end
end

//we include losses in the refining process
//carbon coefficient for the production process
coef_Q_CO2_Et_prod=share_biofuel.*coef_Q_CO2_biofuels+share_CTL.*coef_Q_CO2_CTL+share_oil_refin.*coef_Q_CO2_ref(:,indice_Et);
//Average emission coefficient of the fuels exchanged on international markets
coef_Q_CO2_Et_pool=sum(coef_Q_CO2_Et_prod.*marketshare(:,indice_Et));
//Average emission coefficient for final use
coef_Q_CO2_DF(:,indice_Et)=partDomDF(:,indice_Et).*coef_Q_CO2_Et_prod+partImpDF(:,indice_Et)*coef_Q_CO2_Et_pool;
coef_Q_CO2_DG(:,indice_Et)=partDomDG(:,indice_Et).*coef_Q_CO2_Et_prod+partImpDG(:,indice_Et)*coef_Q_CO2_Et_pool;
coef_Q_CO2_DI(:,indice_Et)=partDomDI(:,indice_Et).*coef_Q_CO2_Et_prod+partImpDI(:,indice_Et)*coef_Q_CO2_Et_pool;
for k=1:reg
    // Update Et coefficient
    coef_Q_CO2_CI(indice_Et,:,k)=partDomCI(indice_Et,:,k)*coef_Q_CO2_Et_prod(k)+partImpCI(indice_Et,:,k)*coef_Q_CO2_Et_pool;
    coef_Q_CO2_CI_wo_CCS(indice_Et,:,k)=partDomCI(indice_Et,:,k)*coef_Q_CO2_Et_prod(k)+partImpCI(indice_Et,:,k)*coef_Q_CO2_Et_pool;
    // Account for CCS in industry
    sumEmi_temp = 0;
    sumCap_temp = 0;
    for i=1:nb_sectors_industry
        for j=1:dureedevieindustrie
            sumEmi_temp = sumEmi_temp + (~CCS_in_industrie_vintage(2,k,i,current_time_im+j) + (1-CCS_efficiency_industry)*CCS_in_industrie_vintage(2,k,i,current_time_im+j)) .* coef_Q_CO2_CI( indice_Et,indice_industries(i),k) .* Capvintageindustries(k,i,current_time_im+j);
            sumCap_temp = sumCap_temp + Capvintageindustries(k,i,current_time_im+j);
        end
        coef_Q_CO2_CI( indice_Et,indice_industries(i),k) = sumEmi_temp / sumCap_temp;
    end
end

// average share of biofuel and CTL in the pool and local consumption
share_biofuel_pool = sum(share_biofuel.*Exp(:,indice_Et)) ./ sum( Exp(:,indice_Et));
share_CTL_pool = sum(share_CTL.*Exp(:,indice_Et)) ./ sum( Exp(:,indice_Et));
share_convEt_pool = 1-share_CTL_pool-share_biofuel_pool;
share_biofuel_Mer = matrix(partDomCI(indice_Et,indice_mer,:),nb_regions,1) .* share_biofuel + matrix(partImpCI(indice_Et,indice_mer,:),nb_regions,1) * share_biofuel_pool; 
share_CTL_Mer = matrix(partDomCI(indice_Et,indice_mer,:),nb_regions,1) .* share_CTL + matrix(partImpCI(indice_Et,indice_mer,:),nb_regions,1) * share_CTL_pool; 
share_convEt_Mer = 1-share_biofuel_Mer-share_CTL_Mer;
share_biofuel_Air = matrix(partDomCI(indice_Et,indice_air,:),nb_regions,1) .* share_biofuel + matrix(partImpCI(indice_Et,indice_air,:),nb_regions,1) * share_biofuel_pool; 
share_CTL_Air = matrix(partDomCI(indice_Et,indice_air,:),nb_regions,1) .* share_CTL + matrix(partImpCI(indice_Et,indice_air,:),nb_regions,1) * share_CTL_pool; 
share_convEt_Air = 1-share_biofuel_Air-share_CTL_Air;

share_biofuel_all = ( ( sum( matrix(partDomCI(indice_Et,:,:).*CI(indice_Et,:,:),nb_sectors,nb_regions)',"c") + partDomDF(:,indice_Et).*DF(:,indice_Et) + partDomDG(:,indice_Et).*DG(:,indice_Et) + partDomDI(:,indice_Et).*DI(:,indice_Et)) .* share_biofuel +  ( sum( matrix(partImpCI(indice_Et,:,:).*CI(indice_Et,:,:),nb_sectors,nb_regions)',"c") + partImpDF(:,indice_Et).*DF(:,indice_Et) + partImpDG(:,indice_Et).*DG(:,indice_Et) + partImpDI(:,indice_Et).*DI(:,indice_Et)) .* share_biofuel_pool ) ./ ( sum(matrix(CI(indice_Et,:,:),nb_sectors,nb_regions)',"c") + DF(:,indice_Et) + DG(:,indice_Et) + DI(:,indice_Et));
share_biofuel_car = partDomDF(:,indice_Et) .* share_biofuel + partImpDF(:,indice_Et) .* share_biofuel_pool;
share_biofuel_ot = matrix(partDomCI(indice_Et,indice_OT,:),nb_regions,1) .* share_biofuel + matrix(partImpCI(indice_Et,indice_OT,:),nb_regions,1) * share_biofuel_pool;

//For synfuels CTL, we account for the process emissions that are generated in the transformation process
//solving for coef_Q_CO2_CI(indice_coal,indice_Et,k) the equation: 
//CI(indice_coal,indice_Et,k)*coef_Q_CO2_CI(indice_coal,indice_Et,k)*Q(k,indice_Et)=...
//CI(indice_coal,indice_Et,k)*Q(k,indice_Et)*coef_Q_CO2_ref(k,indice_coal)-CI(indice_coal,indice_Et,k)*Q(k,indice_Et)/2*coef_Q_CO2_ref(k,indice_Et)
//dividing for the inverse of the efficiency of CTL technology transformation process
for k=1:reg
    if CI(indice_coal,indice_Et,k)>0
        coef_Q_CO2_CI(indice_coal,indice_Et,k)=1/(CI(indice_coal,indice_Et,k)*Q(k,indice_Et))*(CI(indice_coal,indice_Et,k)*Q(k,indice_Et)*coef_Q_CO2_ref(k,indice_coal)-CI(indice_coal,indice_Et,k)*Q(k,indice_Et)/(1/yield_CTL)*coef_Q_CO2_ref(k,indice_Et));
    end
end

//Representing the possibility that process emissions for synfuel production are captured and stored
//Assuming a linear share of CCS depending on the carbon tax, with lower and upper bound
share_CCS_CTL=zeros(reg,1);
if ind_NO_CTL==0 & current_time_im>=start_year_strong_policy-base_year_simulation
    for k=1:reg
        if current_time_im > Tstart_CCS_8760(k,indice_PSS) & max(expectedTaxEtDF) > start_tax_CCS_CTL*1e-6
            share_CCS_CTL(k)=min(max(( max_share_CCS_CTL-0)/(tax_max_CCS_CTL(k)-tax_min_CCS_CTL(k))*(max( expectedTaxEtCI )-tax_min_CCS_CTL(k)),0), max_share_CCS_CTL);
        end
    end
end

//////////Emission coefficient before sequestration
for k=1:reg
    //for synfuel CTL
    coef_Q_CO2_CI_wo_CCS(indice_coal,indice_Et,k)=coef_Q_CO2_CI(indice_coal,indice_Et,k);
    //for all liquid fuels
    coef_Q_CO2_CI_wo_CCS(indice_Et,:,k)=coef_Q_CO2_CI(indice_Et,:,k);
end

//////////correcting emissions coefficients to account for sequestration

for k=1:reg
    coef_Q_CO2_CI(indice_coal,indice_elec,k)= coef_Q_CO2_CI(indice_coal,indice_elec,k)  * inertia_coefCO2coal_elec  ..
    + (1-inertia_coefCO2coal_elec) * (coef_Q_CO2_CIref(indice_coal,indice_elec,k)*(1-sh_CCS_col_Q_col(k)*CCS_efficiency));
    coef_Q_CO2_CI(indice_gas,indice_elec,k)= coef_Q_CO2_CI(indice_gas,indice_elec,k) * inertia_coefCO2coal_elec ..
    + (1-inertia_coefCO2coal_elec) * (       coef_Q_CO2_CIref(indice_gas,indice_elec,k)*(1-sh_CCS_gaz_Q_gaz(k)*CCS_efficiency));
    coef_Q_CO2_CI(indice_coal,indice_Et,k)=coef_Q_CO2_CI(indice_coal,indice_Et,k)*(1-share_CCS_CTL(k)*CCS_efficiency);
    coef_Q_CO2_CI(indice_coal,indice_coal,k)=(Cap_prev(k,indice_coal).*(1-delta(k,indice_coal)).*coef_Q_CO2_CI(indice_coal,indice_coal,k)+ DeltaK(k,indice_coal).*coef_Q_CO2_CIref(indice_coal,indice_coal,k)*(1-share_CCS_CTL(k)*CCS_efficiency))./(Cap_prev(k,indice_coal).*(1-delta(k,indice_coal))+DeltaK(k,indice_coal));
    coef_Q_CO2_CI(indice_oil,indice_oil,k)  =(Cap_prev(k,indice_oil).* (1-delta(k,indice_oil)).*coef_Q_CO2_CI(indice_oil,indice_oil,k) +  DeltaK(k,indice_oil) .*coef_Q_CO2_CIref(indice_oil,indice_oil,k)*(1-share_CCS_CTL(k)*CCS_efficiency)  )./(Cap_prev(k,indice_oil).*  (1-delta(k,indice_oil))+DeltaK(k,indice_oil) );
    coef_Q_CO2_CI(indice_gas,indice_gas,k)  =(Cap_prev(k,indice_gas).* (1-delta(k,indice_gas)).*coef_Q_CO2_CI(indice_gas,indice_gas,k) +  DeltaK(k,indice_gas) .*coef_Q_CO2_CIref(indice_gas,indice_gas,k)*(1-share_CCS_CTL(k)*CCS_efficiency)  )./(Cap_prev(k,indice_gas).*  (1-delta(k,indice_gas))+DeltaK(k,indice_gas) );
    coef_Q_CO2_CI(indice_Et,indice_Et,k)    =(Cap_prev(k,indice_Et).*  (1-delta(k,indice_Et)).*coef_Q_CO2_CI(indice_Et,indice_Et,k) +    DeltaK(k,indice_Et)  .*coef_Q_CO2_CIref(indice_Et,indice_Et,k)*(1-share_CCS_CTL(k)*CCS_efficiency)    )./(Cap_prev(k,indice_Et).*    (1-delta(k,indice_Et))+DeltaK(k,indice_Et)  );
end
