// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///////////////////////////////////////////////////////////////////////////
//Update fret needs (unitary Intermediate Consumption : air, sea, terrestrial) of sectors


//initialization of parametesr used to follow evolution over time of freight use by productive sectors in production process (intermediate consumption) 
if current_time_im==1 
    int_trans_mer=ones(reg,sec);
    int_trans_OTT=ones(reg,sec);
    int_trans_air=ones(reg,sec);
    int_trans_mer_ETC=ones(reg,sec);
    int_trans_OTT_ETC=ones(reg,sec);
    int_trans_air_ETC=ones(reg,sec);
    int_trans_mer_prev=ones(reg,sec);
    int_trans_OTT_prev=ones(reg,sec);
    int_trans_air_prev=ones(reg,sec);
end

////////////////////////////////////////////////////
//////Evolution over time
//////Two cases depending on assumption on "infrastructure policy" scenario (either no specific policy, so following trends; or action to reduce length of supply chains)

if ETC_infra_fret==0
    int_trans_mer_prev=int_trans_mer;
    int_trans_OTT_prev=int_trans_OTT;
    int_trans_air_prev=int_trans_air;
    //composite good use of land freight transport is improved at the same rate as labour productivity
    int_trans_OTT(:,indice_composite)=int_trans_OTT(:,indice_composite).*(ones(reg,1)-coef_wz_TC_l);
    if cont_trans_AEEI==0
        if indice_tech_AEEI==1
            //For India and China, industry reduces land transport use faster than energy efficiency
            int_trans_OTT(6,indice_industries)=int_trans_OTT(6,indice_industries).*(1+EEI_newVintage(6,indice_industries,current_time_im)/1.5);
            int_trans_OTT(7,indice_industries)=int_trans_OTT(7,indice_industries).*(1+EEI_newVintage(7,indice_industries,current_time_im)/1.5);
            //Maritime freight use reduced faster than energy efficiency in industry; in the MULTISECTOR version, we consider the equipment industry sector as a reference
            int_trans_mer=int_trans_mer.*(ones(reg,sec)+1/1.5*EEI_newVintage(:,indice_industries($),current_time_im)*ones(1,sec));
        else
            //For India and China, industry reduces land transport use as fast as energy efficiency
            int_trans_OTT(6,indice_industries)=int_trans_OTT(6,indice_industries).*(1+EEI_newVintage(6,indice_industries,current_time_im));
            int_trans_OTT(7,indice_industries)=int_trans_OTT(7,indice_industries).*(1+EEI_newVintage(7,indice_industries,current_time_im));
            //Maritime freight use reduced as fast as energy efficiency in industry; DESAG_INDUSTRY: in the MULTISECTOR version, we consider the equipment industry sector as a reference
            int_trans_mer=int_trans_mer.*(ones(reg,sec)+EEI_newVintage(:,indice_industries($),current_time_im)*ones(1,sec));
        end
    end
    if cont_trans_AEEI==1
        if indice_tech_AEEI==1
            //For all regions, industry reduces land transport use faster than energy efficiency
            int_trans_OTT(:,indice_industries)=int_trans_OTT(:,indice_industries).*(1+EEI_newVintage(:,indice_industries,current_time_im)/1.5);
            //Maritime freight use reduced faster than energy efficiency in industry
            int_trans_mer=int_trans_mer.*(ones(reg,sec)+1/1.5*EEI_newVintage(:,indice_industries($),current_time_im)*ones(1,sec));
        else
            //For all regions, industry reduces land transport use as fast as energy efficiency
            int_trans_OTT(:,indice_industries)=int_trans_OTT(:,indice_industries).*(1+EEI_newVintage(:,indice_industries,current_time_im));
            //Maritime freight use reduced as fast as energy efficiency in industry
            int_trans_mer=int_trans_mer.*(ones(reg,sec)+EEI_newVintage(:,indice_industries($),current_time_im)*ones(1,sec));
        end
    end
    //use of air freight transport is improved at the same rate as labour productivity
    int_trans_air=int_trans_air.*(ones(reg,sec)-coef_wz_TC_l*ones(1,sec));
    int_trans_OTT_ETC=int_trans_OTT;
    int_trans_mer_ETC=int_trans_mer;
    int_trans_air_ETC=int_trans_air;
    rate_int_trans_mer=int_trans_mer./int_trans_mer_prev-1;
    rate_int_trans_OTT=int_trans_OTT./int_trans_OTT_prev-1;
    rate_int_trans_air=int_trans_air./int_trans_air_prev-1;

end

if ETC_infra_fret==1
    int_trans_mer_prev=int_trans_mer;
    int_trans_OTT_prev=int_trans_OTT;
    int_trans_air_prev=int_trans_air;

    //composite good use of land freight transport is improved at the same rate as labour productivity
    int_trans_OTT(:,indice_composite)=int_trans_OTT(:,indice_composite).*(ones(reg,1)-coef_wz_TC_l);
    //For India and China, industry reduces land transport use as fast as energy efficiency
    int_trans_OTT(6,indice_industries)=int_trans_OTT(6,indice_industries).*(1+EEI_newVintage(6,indice_industries,current_time_im));
    int_trans_OTT(7,indice_industries)=int_trans_OTT(7,indice_industries).*(1+EEI_newVintage(7,indice_industries,current_time_im));

    //Maritime freight use reduced as fast as energy efficiency in industry
    int_trans_mer=int_trans_mer.*(ones(reg,sec)+EEI_newVintage(:,indice_industries($),current_time_im)*ones(1,sec)); // DESAG_INDUSTRY: in the MULTISECTOR version, we consider the equipment industry sector as a reference
    //use of air freight transport is improved at the same rate as labour productivity
    int_trans_air=int_trans_air.*(ones(reg,sec)-coef_wz_TC_l*ones(1,sec));


    rate_int_trans_mer=int_trans_mer./int_trans_mer_prev-1;
    rate_int_trans_OTT=int_trans_OTT./int_trans_OTT_prev-1;
    rate_int_trans_air=int_trans_air./int_trans_air_prev-1;

    if current_time_im<year_ETC_infra_fret+1
        int_trans_OTT_ETC=int_trans_OTT;
        int_trans_mer_ETC=int_trans_mer;
        int_trans_air_ETC=int_trans_air;
    end

    if current_time_im>year_ETC_infra_fret
        //Adding a decoupling factors to the evolutions
        int_trans_OTT_ETC(:,indice_composite)=int_trans_OTT_ETC(:,indice_composite).*(ones(reg,1)-coef_wz_TC_l+rate_decoupl_OTT_ETC(:,indice_composite));
        int_trans_OTT_ETC(6,indice_industries)=int_trans_OTT_ETC(6,indice_industries).*(1+EEI_newVintage(6,indice_industries,current_time_im)+rate_decoupl_OTT_ETC(6,indice_industries));
        int_trans_OTT_ETC(7,indice_industries)=int_trans_OTT_ETC(7,indice_industries).*(1+EEI_newVintage(7,indice_industries,current_time_im)+rate_decoupl_OTT_ETC(7,indice_industries));
        int_trans_OTT_ETC(1:5  ,indice_industries)=int_trans_OTT_ETC(1:5  ,indice_industries).*(1+rate_decoupl_OTT_ETC(1:5  ,indice_industries));
        int_trans_OTT_ETC(8:reg,indice_industries)=int_trans_OTT_ETC(8:reg,indice_industries).*(1+rate_decoupl_OTT_ETC(8:reg,indice_industries));
        int_trans_OTT_ETC(:,indice_construction)=int_trans_OTT_ETC(:,indice_construction).*(ones(reg,1)+rate_decoupl_OTT_ETC(:,indice_construction));
        int_trans_OTT_ETC(:,indice_coal)=int_trans_OTT_ETC(:,indice_coal).*(ones(reg,1)+rate_decoupl_OTT_ETC(:,indice_coal));
        int_trans_OTT_ETC(:,indice_oil)=int_trans_OTT_ETC(:,indice_oil).*(ones(reg,1)+rate_decoupl_OTT_ETC(:,indice_oil));
        int_trans_OTT_ETC(:,indice_gas)=int_trans_OTT_ETC(:,indice_gas).*(ones(reg,1)+rate_decoupl_OTT_ETC(:,indice_gas));
        int_trans_OTT_ETC(:,indice_Et)=int_trans_OTT_ETC(:,indice_Et).*(ones(reg,1)+rate_decoupl_OTT_ETC(:,indice_Et));
        int_trans_OTT_ETC(:,indice_elec)=int_trans_OTT_ETC(:,indice_elec).*(ones(reg,1)+rate_decoupl_OTT_ETC(:,indice_elec));
        int_trans_OTT_ETC(:,indice_agriculture)=int_trans_OTT_ETC(:,indice_agriculture).*(ones(reg,1)+rate_decoupl_OTT_ETC(:,indice_agriculture));
        int_trans_mer_ETC=int_trans_mer_ETC.*(ones(reg,sec)+EEI_newVintage(:,indice_industries($),current_time_im)*ones(1,sec)+rate_decoupl_OTT_ETC(:,indice_mer)*ones(1,sec));

    end

end

///////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////Updating CI

////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////Land freight transport/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

// we assume than freight by train is also reduced similarly to road
// in the way road_fret_share is computed

if ind_roadFret_A==1 & ~is_bau & current_time_im >= start_year_strong_policy-base_year_simulation
    for k=1:reg
        for j=1:sec
            CI(indice_OT,j,k) = base_CI(indice_OT,j,k,current_time_im+1) .* ( (1-road_fret_share(k)) + road_fret_share(k) * road_fret_reduction(current_time));
        end
    end
else
    for k=1:reg
        for j=1:sec
            CI(indice_OT,j,k)=(CI_prev(indice_OT,j,k)*(1+rate_int_trans_OTT(k,j))*Cap_prev(k,j)*(1-delta_modified(k,j))+CIref(indice_OT,j,k)*int_trans_OTT_ETC(k,j)*DeltaK(k,j))/(Cap_prev(k,j)*(1-delta_modified(k,j))+DeltaK(k,j));
        end
    end
end

////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////Maritime freight//////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////


for k=1:reg
    for j=1:sec
        CI(indice_mer,j,k)=(CI_prev(indice_mer,j,k)*(1+rate_int_trans_mer(k,j))*Cap_prev(k,j)*(1-delta_modified(k,j))+CIref(indice_mer,j,k)*int_trans_mer_ETC(k,j)*DeltaK(k,j))/(Cap_prev(k,j)*(1-delta_modified(k,j))+DeltaK(k,j));
    end
end

////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////Air freight////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////


for k=1:reg
    for j=1:sec
        CI(indice_air,j,k)=CIref(indice_air,j,k)*int_trans_air(k,j);
    end
end


//////////////////////////////////////////////////////////////////////////////////////////////////////
// In case we want to follow approximately an exogenous path of aviation demand:
if exo_pkmair_scenario >0

    CI_air = zeros(nb_regions,1);
    for ii=1:nb_sectors
        CI_air = CI_air + Q(:,ii).*matrix(CI_prev(indice_air,ii,:),nb_regions,1);
    end
    pkm_air_inc = ( Conso(:,indice_air-nbsecteurenergie) + DG(:,indice_air) + DI(:,indice_air) + sum( Imp .* nit,"c") .*partTIref(1)+CI_air) ./ ( Consoref(:,indice_air-nbsecteurenergie) + DGref(:,indice_air) + DIref(:,indice_air) + ImpTIref+CI_air_ref);

    //disp( [pkm_air_evolution_sc(:,current_time_im), pkm_air_inc, pkm_air_inc./pkm_air_evolution_sc(:,current_time_im)], "[pkm_air_evolution_sc(:,current_time_im), pkm_air_inc, pkm_air_inc./pkm_air_evolution_sc(:,current_time_im)]")
    if current_time_im>1
        disp( sum(pkm_air_all_sc(:,1) .* pkm_air_inc) / sum( pkm_air_all_sc(:,1).*pkm_air_evolution_sc(:,current_time_im-1)), "sum(pkm_air_all_sc(:,1) .* pkm_air_inc")
        pkm_air_increase_lag = pkm_air_inc./pkm_air_evolution_sc(:,current_time_im-1); // for adaptative expectations
    end

    pkm_increase_for_sc = pkm_air_evolution_sc(:,current_time_im) ./ (pkm_air_increase_lag).^(pkmair_inertia_lag);
    DFair_exo = Consoref(:,indice_air-nbsecteurenergie) .* pkm_increase_for_sc;
    DG(:,indice_air) = DGref(:,indice_air) .* pkm_increase_for_sc;
    ////////
    // DI 
    DI_air = DIinfra(:,indice_air) + DIprod(:,indice_air);
    DI_obj = DIref(:,indice_air) .* pkm_increase_for_sc;
    correction_DI_air = DI_obj ./ DI_air;
    //DIinfra(:,indice_air) = correction_DI_air.* DIinfra(:,indice_air);
    DIprod(:,indice_air) = correction_DI_air .* DIprod(:,indice_air);
    // substitution to mer and OT
    //share_mer = (DIinfra(:,indice_mer).*pArmDI(:,indice_mer)) ./ sum( DIinfra(:,[indice_mer,indice_OT]).*pArmDI(:,[indice_mer,indice_OT]),'c');
    //DIinfra(:,indice_mer) = DIinfra(:,indice_mer) + share_mer .* ( (1-correction_DI_air)./ correction_DI_air .* DIinfra(:,indice_air).*pArmDI(:,indice_air)) ./ pArmDI(:,indice_mer);
    //DIinfra(:,indice_OT) = DIinfra(:,indice_mer) + (1-share_mer) .* ( (1-correction_DI_air)./ correction_DI_air .* DIinfra(:,indice_air).*pArmDI(:,indice_air)) ./ pArmDI(:,indice_OT);
    if sc_exo_air_demand <> "1.5C_LD_SSP2" // subsitution towards other transport mode if this is the aviation demand scenario do not results from behavioral assumptions
        share_mer = divide( (DIprod(:,indice_mer).*pArmDI(:,indice_mer)) , sum( DIprod(:,[indice_mer,indice_OT]).*pArmDI(:,[indice_mer,indice_OT]),'c'), 0);
        DIprod(:,indice_mer) = DIprod(:,indice_mer) + share_mer .* ( (1-correction_DI_air)./ correction_DI_air .* DIprod(:,indice_air).*pArmDI(:,indice_air)) ./ pArmDI(:,indice_mer);
        DIprod(:,indice_OT) = DIprod(:,indice_mer) + (1-share_mer) .* ( (1-correction_DI_air)./ correction_DI_air .* DIprod(:,indice_air).*pArmDI(:,indice_air)) ./ pArmDI(:,indice_OT);
    end
    //no negative values
    DIinfra=max(DIinfra,0);
    DIprod=max(DIprod,0);

    /////////
    // CI
    CI_air = zeros(nb_regions,1);
    for ii=1:nb_sectors
        CI_air = CI_air + Q(:,ii).*matrix(CI_prev(indice_air,ii,:),nb_regions,1);
    end
    CI_obj = CI_air_ref .* pkm_increase_for_sc;
    correction_CI_air = CI_obj ./ CI_air;
    for k=1:reg//ii=1:nb_sectors
        for ii=1:sec//k=1:nb_regions
            CI(indice_air,ii,k) = CI_prev(indice_air,ii,k) * correction_CI_air(k);
        end
    end
    // substitution to mer and OT
    // subsitution towards other transport mode if this is the aviation demand scenario do not results from behavioral assumptions
    if sc_exo_air_demand <> "1.5C_LD_SSP2"
        for k=1:reg//ii=1:nb_sectors
            for ii=1:sec//k=1:nb_regions
                share_mer = CI(indice_mer,ii,k).*pArmCI(indice_mer,ii,k) ./ (CI(indice_mer,ii,k).*pArmCI(indice_mer,ii,k) + CI(indice_OT,ii,k).*pArmCI(indice_OT,ii,k));
                CI(indice_mer,ii,k) = CI_prev(indice_mer,ii,k) + share_mer .* ( (1-correction_CI_air(k))./ correction_CI_air(k) .* CI_prev(indice_air,ii,k).*pArmCI(indice_air,ii,k)) ./ pArmCI(indice_mer,ii,k);
            end
        end 
        for k=1:reg//ii=1:nb_sectors
            for ii=1:sec//k=1:nb_regions
                share_mer = CI(indice_mer,ii,k).*pArmCI(indice_mer,ii,k) ./ (CI(indice_mer,ii,k).*pArmCI(indice_mer,ii,k) + CI(indice_OT,ii,k).*pArmCI(indice_OT,ii,k));
                CI(indice_OT,ii,k) = CI_prev(indice_OT,ii,k) + (1-share_mer) .* ( (1-correction_CI_air(k))./ correction_CI_air(k) .* CI_prev(indice_air,ii,k).*pArmCI(indice_air,ii,k)) ./ pArmCI(indice_OT,ii,k);
            end
        end
    end

    /////////
    // ImpTI
    ImpTI = sum( sum( Imp .* nit,"c") .*partTIref(1));
    ImpTI_obj = sum( ImpTIref .* pkm_increase_for_sc);
    correction_ImpTI_air = ImpTI_obj ./ ImpTI;
    partTIref(1) = partTIref(1) * correction_ImpTI_air;
    // subsitution towards other transport mode if this is the aviation demand scenario do not results from behavioral assumptions
    if sc_exo_air_demand <> "1.5C_LD_SSP2"
        partTIref(3) = max(0,(1-partTIref(1)) * partTIref(3) / (partTIref(3)+partTIref(2)));
        partTIref(2) = 1 - sum( partTIref([1,3]));
    end
end
