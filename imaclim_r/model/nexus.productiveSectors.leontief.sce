// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Thomas Le Gallic, Ruben Bibas, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///////////////////////////////////////////////////////////////////////////////////////////
//Update unitary Intermediate Consumption of agricultural, industrial and composite sectors
///////////////////////////////////////////////////////////////////////////////////////////
//to be executed after nexus.capital.sce (because of CapvintageXXX)
//to be executed before nexus.transport.sce (because of .... )


if ind_electrification_indu>=1 & current_time_im >=start_year_strong_policy-base_year_simulation
    
    elast_gaz_ind=-0.8*ones(nb_regions,nb_sectors_industry); //DESAG_INDUSTRY: dimensions inversed?
    elast_Et_ind=-0.8*ones(nb_regions,nb_sectors_industry);
    elast_coal_ind=-0.6*ones(nb_regions,nb_sectors_industry);
    //var_hom_industrie=9*ones(nb_regions,1);
end

// Updating of the share of non substitutable energy in the service sector in the variant that boosts electrification in buildings
if indice_building_electri==1 & current_time_im >= start_year_strong_policy-base_year_simulation 
    shCIspec_comp(indice_Et,:)=0.05*ones(1,nb_regions); //Optimistic assumption: allows a higher electrification rate in the commercial sector
    shCIspec_comp(indice_gas,:)=0.05*ones(1,nb_regions); // Optimistic assumption: allows a higher electrification rate in the commercial sector
    shCIsubs_comp=ones(nbsecteurenergie,nb_regions)-shCIspec_comp;
    for k=1:reg
        CIcompositeSpecref(1:nbsecteurenergie,indice_composite,k) = shCIspec_comp(1:nbsecteurenergie,k).*CIref(1:nbsecteurenergie,indice_composite,k);	
        CIcompositeSubsref(1:nbsecteurenergie,indice_composite,k) = shCIsubs_comp(1:nbsecteurenergie,k).*CIref(1:nbsecteurenergie,indice_composite,k);	
    end
end	

//#############################################################################################
//#############################################################################################
//### STEP 1 : CIdeltacompositeSpec & CIdeltacompositeSubs from anticipated armington prices
//#############################################################################################
//#############################################################################################

//////////////////////////////////////////////For the composite sector///////////////
if current_time_im==1
    CIdeltacomposite=zeros(sec,sec,reg);
    CIdeltacompositeSpec=zeros(sec,sec,reg);
    CIdeltacompositeSubs=zeros(sec,sec,reg);
end

// In this variant, we add an optimistic assumption of reduction of cost of capital in the composite sector to stimulate substitution towards electricity
if indice_building_electri==1 & current_time_im >= start_year_strong_policy-base_year_simulation 
    if current_time_im == start_year_strong_policy-base_year_simulation 
        for pays=1:reg
            K_cost_composite(pays,4) = K_cost_composite(pays,4).*K_cost_comp_reduc_ini;
        end
    else		
        for pays=1:reg
            K_cost_composite(pays,4) = K_cost_composite(pays,4).*(1-K_cost_comp_reduc);
        end
    end
end

// Here the new market shares in the composite sectors are computed, taking into account the (fixed and initially calibrated) costs of capital and energy price for each energy.
SH_ener_calib = zeros(1:4);
if current_time_im>1
    CI;CIdeltacomposite;
end
for pays=1:reg
    CIdeltacomposite(:,indice_composite,pays)=CI(:,indice_composite,pays);
    p_ener_composite=[pArmCI_nexus(indice_coal,indice_composite,pays);pArmCI_nexus(indice_Et,indice_composite,pays);pArmCI_nexus(indice_gas,indice_composite,pays);pArmCI_nexus(indice_elec,indice_composite,pays)];
    p_ener_composite(indice_coal) = p_ener_composite(indice_coal) * dynForc_pcoal2;
    p_ener_composite(indice_Et) = p_ener_composite(indice_Et) * dynForc_pEt_comp;
    LCC_composite=K_cost_composite(pays,:)'.*CRF_composite+p_ener_composite./rhocomposite_dyn;
    SH_ener_calib=zeros(4,1);
    for j=1:4
        SH_ener_calib(j)=(LCC_composite(j)).^(-var_hom_composite(pays))./sum((((LCC_composite)).^(-var_hom_composite(pays)*ones(4,1))));
    end
    Pcoal_delta_comp(pays)=SH_ener_calib(1);
    Poil_delta_comp(pays)=SH_ener_calib(2);
    Pgaz_delta_comp(pays)=SH_ener_calib(3);
    Pelec_delta_comp(pays)=SH_ener_calib(4);
end

// These shares are used to define a ratio to compute later the new CI_subs
Pcoal_comp_Edelta=Pcoal_delta_comp;
fmultPcoal_comp_Edelta=Pcoal_comp_Edelta./(Pcoal_comp_Edeltaref+0.000000000000000000001);

PEt_comp_Edelta=Poil_delta_comp;
fmultPEt_comp_Edelta=PEt_comp_Edelta./(PEt_comp_Edeltaref+0.000000000000000000001);

Pgaz_comp_Edelta=Pgaz_delta_comp;
fmultPgaz_comp_Edelta=Pgaz_comp_Edelta./(Pgaz_comp_Edeltaref+0.000000000000000000001);

Pelec_comp_Edelta=Pelec_delta_comp;
fmultPelec_comp_Edelta=Pelec_comp_Edelta./(Pelec_comp_Edeltaref+0.000000000000000000001);

if current_time_im==1
    E_enerdelta_ser_elec=ones(reg,1);
    E_enerdelta_ser_elec_BAU=ones(reg,1);
    CIdeltacompositecoalprev=zeros(reg,1); // Renamed as it was confusing not to specify that it was only for the coal sector.
    CIdeltacompCoalToGaz=zeros(reg,1);
end

// These are the cumulated energy efficiency improvements from nexus.productiveSectors.eei.sce, use to compute the new CI
E_enerdelta_ser_elec     = E_enerdelta(:,indice_composite    ,current_time_im);
E_enerdelta_ser_elec_BAU = E_enerdeltaFree(:,indice_composite,current_time_im);

// Market shares are calculated on the basis of final energy (since this is purchased energy); substitutions, on the other hand, must be calculated on the basis of useful energy. Substitutions towards electricity therefore lead to energy savings in terms of final energy. Note that before this change in the code, useful energy was used to compute the market share above, but not applied to the CI computation below.
// The useful energy values defined in calibration.industry are used here (the same for industry, services and agriculture). To be more accurate, they should be refined by sector, and possibly be subject to assumptions about changes over time as a function of changes in the main energy uses, and structural change within each macrosector.

// We compute the change in final energy due to substitution, considering a constant useful energy:
for pays = 1:reg
    fmult_savingfuelswit_ser(pays) = sum(rhocoal_comp*Pcoal_comp_Edeltaref(pays)+rhogaz_comp*Pgaz_comp_Edeltaref(pays)+rhoEt_comp*PEt_comp_Edeltaref(pays)+rhoelec_comp*Pelec_comp_Edeltaref(pays))/sum(rhocoal_comp*Pcoal_comp_Edelta(pays)+rhogaz_comp*Pgaz_comp_Edelta(pays)+rhoEt_comp*PEt_comp_Edelta(pays)+rhoelec_comp*Pelec_comp_Edelta(pays)); // Should be re-written if the rhos become variable.
end

/// Computation of the new substitutable CI (new capacities)
//The two following lines are usefull when calling from a 'pause'. See http://wiki.scilab.org/howto/global_and_local_variables
CIdeltacompositeSubs;
CIdeltacompositeSpec;

for k=1:reg
    CIdeltacompositeSubs(indice_coal,indice_composite,k)=E_enerdelta_ser(k)*CIcompositeSubsref(indice_coal,indice_composite,k)*fmultPcoal_comp_Edelta(k)*fmult_savingfuelswit_ser(k);
    CIdeltacompositeSubs(indice_gas,indice_composite,k)=E_enerdelta_ser(k)*CIcompositeSubsref(indice_gas,indice_composite,k)*fmultPgaz_comp_Edelta(k)*fmult_savingfuelswit_ser(k);
    CIdeltacompositeSubs(indice_Et,indice_composite,k)=E_enerdelta_ser(k)*CIcompositeSubsref(indice_Et,indice_composite,k)*fmultPEt_comp_Edelta(k)*fmult_savingfuelswit_ser(k);
    CIdeltacompositeSubs(indice_elec,indice_composite,k)=E_enerdelta_ser_elec(k)*(CIcompositeSubsref(indice_elec,indice_composite,k))*fmultPelec_comp_Edelta(k)*fmult_savingfuelswit_ser(k);
end

/// The new specific CI are computed using only cumulated energy efficiency improvements and elasticities (which represents additionnal energy saving behaviours with price increase), except for coal ...
for k=1:reg
    CIdeltacompositeSpec(indice_gas,indice_composite,k)=min(E_enerdelta_ser(k)*CIcompositeSpecref(indice_gas,indice_composite,k),...
    E_enerdelta_ser(k)*CIcompositeSpecref(indice_gas,indice_composite,k)*(pArmCI_nexus(indice_gas,indice_composite,k)/pArmCIref(indice_gas,indice_composite,k))^elast_gaz_comp(k));

    CIdeltacompositeSpec(indice_Et,indice_composite,k)=min(E_enerdelta_ser(k)*CIcompositeSpecref(indice_Et,indice_composite,k),...
    E_enerdelta_ser(k)*CIcompositeSpecref(indice_Et,indice_composite,k)*(pArmCI_nexus(indice_Et,indice_composite,k)/pArmCIref(indice_Et,indice_composite,k))^elast_Et_comp(k));

    CIdeltacompositeSpec(indice_elec,indice_composite,k)=min(E_enerdelta_ser_elec(k)*CIcompositeSpecref(indice_elec,indice_composite,k),...
    E_enerdelta_ser_elec(k)*CIcompositeSpecref(indice_elec,indice_composite,k)*(pArmCI_nexus(indice_elec,indice_composite,k)/pArmCIref(indice_elec,indice_composite,k))^elast_elec_comp(k)); // To give an idea: +5% in energy price => -1 to -1,5% in consumption (depending on the assumption, defined in calibration.nexus.productiveSectors.sce

    /// ... for which an exogenous substitution trend is implemented; NB 18/07/2023: this occurs in 20 years. This assumption is hard-coded and should be moved to calibration.fuel substitution (or another calibration file). Note also that the substitution is towards gaz, or towards electricity if indice_building_electri == 1 & current_time_im >= start_year_strong_policy-base_year_simulation (cf. computation of new capacities below)

    if current_time_im==1
        CIdeltacompositeSpec(indice_coal,indice_composite,k)=E_enerdelta_ser(k)*CIcompositeSpecref(indice_coal,indice_composite,k).*max(0,interpln([1,20;1,0],current_time_im)); // 
    else
        CIdeltacompositecoalprev(k)=CIdeltacompositeSpec(indice_coal,indice_composite,k);
        CIdeltacompositeSpec(indice_coal,indice_composite,k)=E_enerdelta_ser(k)*CIcompositeSpecref(indice_coal,indice_composite,k).*max(0,interpln([1,20;1,0],current_time_im));
        if CIdeltacompositecoalprev(k)>=CIdeltacompositeSpec(indice_coal,indice_composite,k)
            CIdeltacompCoalToGaz(k)=rhocoal_comp/rhogaz_comp*(CIdeltacompositecoalprev(k)-CIdeltacompositeSpec(indice_coal,indice_composite,k)); // Here a "0.5" coefficient was used. We could think that it was both used to take into account the saving (in final energy) due to difference in the conversion from final energy to useful energy between coal and gas AND to consider an exogenous efficiency improvement due to this switch (otherwise, it could be a mistake). We only keep the first driver (as there are already other explicit mechanisms to represent energy efficiency improvement), and explicit it with the rhos (rhocoal = 0.5 ; rhogas = 0.8).
        else
            CIdeltacompCoalToGaz(k)=0;
            disp ( 'Warning! CIdeltacompCoalToGaz('+k+') was negative and is now 0(this means that something''s wrong...)');
        end
    end
	
end

/// total CI of new capacities
for k=1:reg
    CIdeltacomposite(indice_coal,indice_composite,k)=CIdeltacompositeSubs(indice_coal,indice_composite,k)+CIdeltacompositeSpec(indice_coal,indice_composite,k);
    CIdeltacomposite(indice_oil,indice_composite,k)=CI(indice_oil,indice_composite,k);
    CIdeltacomposite(indice_Et,indice_composite,k)=CIdeltacompositeSubs(indice_Et,indice_composite,k)+CIdeltacompositeSpec(indice_Et,indice_composite,k);
    if indice_building_electri==1 & current_time_im >= start_year_strong_policy-base_year_simulation // To re-inforce the electrification process in the composite sector, the exogenous substition in the specific capacities will be towards electricity from start_year_strong_policy onwards.
        CIdeltacomposite(indice_gas,indice_composite,k)=CIdeltacompositeSubs(indice_gas,indice_composite,k)+CIdeltacompositeSpec(indice_gas,indice_composite,k); 
        CIdeltacomposite(indice_elec,indice_composite,k)=CIdeltacompositeSubs(indice_elec,indice_composite,k)+CIdeltacompositeSpec(indice_elec,indice_composite,k)+CIdeltacompCoalToGaz(k)*rhogaz_comp/rhoelec_comp; 
    else
        CIdeltacomposite(indice_gas,indice_composite,k)=CIdeltacompositeSubs(indice_gas,indice_composite,k)+CIdeltacompositeSpec(indice_gas,indice_composite,k)+CIdeltacompCoalToGaz(k);
																																						 
        CIdeltacomposite(indice_elec,indice_composite,k)=CIdeltacompositeSubs(indice_elec,indice_composite,k)+CIdeltacompositeSpec(indice_elec,indice_composite,k);
    end
end

//////////////////////////////////////////////For the agriculture sector///////////////

for pays=1:reg
    if ind_NLU_CI ==1
        CIdeltacomposite(:,indice_agriculture,pays)=alphaIC_agriFoodProcess(:,pays);// coupling with the nexus land-use, only the disaggregated agriFoodProcess sector is considered
    else
        CIdeltacomposite(:,indice_agriculture,pays)=CI(:,indice_agriculture,pays);
    end
    p_ener_agriculture=[pArmCI_nexus(indice_coal,indice_agriculture,pays);pArmCI_nexus(indice_Et,indice_agriculture,pays);pArmCI_nexus(indice_gas,indice_agriculture,pays);pArmCI_nexus(indice_elec,indice_agriculture,pays)];
    p_ener_agriculture(indice_coal) = p_ener_agriculture(indice_coal) * dynForc_pcoal2;
    LCC_agriculture=K_cost_agriculture(pays,:)'.*CRF_agriculture+p_ener_agriculture./rhoagriculture_dyn;
    SH_ener_calib=zeros(4,1);
    for j=1:4
        SH_ener_calib(j)=(LCC_agriculture(j)).^(-var_hom_agriculture(pays))./sum((((LCC_agriculture)).^(-var_hom_agriculture(pays)*ones(4,1))));
    end
    Pcoal_delta_agric(pays)=SH_ener_calib(1);
    Poil_delta_agric(pays)=SH_ener_calib(2);
    Pgaz_delta_agric(pays)=SH_ener_calib(3);
    Pelec_delta_agric(pays)=SH_ener_calib(4);
end

Pcoal_agric_Edelta=Pcoal_delta_agric;
fmultPcoal_agric_Edelta=Pcoal_agric_Edelta./(Pcoal_agric_Edeltaref+0.000000000000000000001);

PEt_agric_Edelta=Poil_delta_agric;
fmultPEt_agric_Edelta=PEt_agric_Edelta./(PEt_agric_Edeltaref+0.000000000000000000001);

Pgaz_agric_Edelta=Pgaz_delta_agric;
fmultPgaz_agric_Edelta=Pgaz_agric_Edelta./(Pgaz_agric_Edeltaref+0.000000000000000000001);

Pelec_agric_Edelta=Pelec_delta_agric;
fmultPelec_agric_Edelta=Pelec_agric_Edelta./(Pelec_agric_Edeltaref+0.000000000000000000001);

if current_time_im==1
    E_enerdelta_agr_elec=ones(reg,1);
    E_enerdelta_agr_elec_BAU=ones(reg,1);
    CIdeltaagricultureprev= zeros (reg,1);
    CIdeltaagriCoalToGaz= zeros (reg,1);
end

E_enerdelta_agr_elec     = E_enerdelta    (:,indice_agriculture,current_time_im);
E_enerdelta_agr_elec_BAU = E_enerdeltaFree(:,indice_agriculture,current_time_im);


///Substituable CI for new capacities
for k=1:reg
    CIdeltacompositeSubs(indice_coal,indice_agriculture,k)=E_enerdelta_agr(k)*CIagricSubsref(indice_coal,indice_agriculture,k)*fmultPcoal_agric_Edelta(k);
    CIdeltacompositeSubs(indice_gas,indice_agriculture,k)=E_enerdelta_agr(k)*CIagricSubsref(indice_gas,indice_agriculture,k)*fmultPgaz_agric_Edelta(k);
    CIdeltacompositeSubs(indice_Et,indice_agriculture,k)=E_enerdelta_agr(k)*CIagricSubsref(indice_Et,indice_agriculture,k)*fmultPEt_agric_Edelta(k);
    CIdeltacompositeSubs(indice_elec,indice_agriculture,k)=E_enerdelta_agr_elec(k)*(CIagricSubsref(indice_elec,indice_agriculture,k))*fmultPelec_agric_Edelta(k);
end

///Specific CI for new capacities
for k=1:reg

    // For gas, CIspec is reduced after 2030
    CIdeltacompositeSpec(indice_gas,indice_agriculture,k)=min(E_enerdelta_agr(k)*CIagricSpecref(indice_gas,indice_agriculture,k),...
    E_enerdelta_agr(k)*CIagricSpecref(indice_gas,indice_agriculture,k)*(pArmCI_nexus(indice_gas,indice_agriculture,k)/pArmCIref(indice_gas,indice_agriculture,k))^elast_gaz_agr(k)) ;

    // For Et, specific CI evolved like CI_delta_Et_OT with EEI on, top of it
    if current_time_im>2
        CIdeltacompositeSpec(indice_Et,indice_agriculture,k)=min(E_enerdelta_agr(k)*CIagricSpecref(indice_Et,indice_agriculture,k),...
        (E_enerdelta_agr(k)*CI_delta_Et_OT(k)/CIref(indice_Et, indice_OT,k))*CIagricSpecref(indice_Et,indice_agriculture,k)); 
    else
        CIdeltacompositeSpec(indice_Et,indice_agriculture,k)=E_enerdelta_agr(k)*CIagricSpecref(indice_Et,indice_agriculture,k);
    end

    CIdeltacompositeSpec(indice_elec,indice_agriculture,k)=min(E_enerdelta_agr_elec(k)*(CIagricSpecref(indice_elec,indice_agriculture,k)),...
    E_enerdelta_agr_elec(k)*(CIagricSpecref(indice_elec,indice_agriculture,k))*(pArmCI_nexus(indice_elec,indice_agriculture,k)/pArmCIref(indice_elec,indice_agriculture,k))^elast_elec_agr(k));


    // Autonomous substitution from coal to gas
    if current_time_im==1
        CIdeltacompositeSpec(indice_coal,indice_agriculture,k)=E_enerdelta_agr(k)*CIagricSpecref(indice_coal,indice_agriculture,k)*max(0,interpln([1,30;1,0],current_time_im));
    else
        CIdeltaagricultureprev(k)=CIdeltacompositeSpec(indice_coal,indice_agriculture,k);
        CIdeltacompositeSpec(indice_coal,indice_agriculture,k)=E_enerdelta_agr(k)*CIagricSpecref(indice_coal,indice_agriculture,k)*max(0,interpln([1,30;1,0],current_time_im));
        if CIdeltaagricultureprev(k)>=CIdeltacompositeSpec(indice_coal,indice_agriculture,k)
            CIdeltaagriCoalToGaz(k)=0.5*(CIdeltaagricultureprev(k)-CIdeltacompositeSpec(indice_coal,indice_agriculture,k));
        else
            CIdeltaagriCoalToGaz(k)=0;
            disp ( 'Warning! CIdeltaagriCoalToGaz('+k+') was negative and is now 0 (this means that something''s wrong...)');
        end
    end
end

///Total CI of new capacities
for k=1:reg
    CIdeltacomposite(indice_coal,indice_agriculture,k)=CIdeltacompositeSubs(indice_coal,indice_agriculture,k)+CIdeltacompositeSpec(indice_coal,indice_agriculture,k);
    CIdeltacomposite(indice_oil,indice_agriculture,k)=CI(indice_oil,indice_agriculture,k);
    CIdeltacomposite(indice_gas,indice_agriculture,k)=CIdeltacompositeSubs(indice_gas,indice_agriculture,k)+CIdeltacompositeSpec(indice_gas,indice_agriculture,k)+CIdeltaagriCoalToGaz(k);
    CIdeltacomposite(indice_Et,indice_agriculture,k)=CIdeltacompositeSubs(indice_Et,indice_agriculture,k)+CIdeltacompositeSpec(indice_Et,indice_agriculture,k);
    CIdeltacomposite(indice_elec,indice_agriculture,k)=CIdeltacompositeSubs(indice_elec,indice_agriculture,k)+CIdeltacompositeSpec(indice_elec,indice_agriculture,k);
end

//////////////////////////////////////////////For the industry///////////////////

Pcoal_delta_ind 	= zeros(reg,nb_sectors_industry);
PEt_delta_ind		= zeros(reg,nb_sectors_industry);
Pgaz_delta_ind		= zeros(reg,nb_sectors_industry);
Pelec_delta_ind	= zeros(reg,nb_sectors_industry);


// pArmCI accounted for substitutables CI, depending on wether CCS is considered or not in the technologies
// initialized to pArmCI_nexus
pArmCI_nexus_industrie = pArmCI_nexus;

choose_CCS_industrie=(zeros(4,reg) == 1);

for i = 1:nb_sectors_industry,
    for pays=1:reg
        CIdeltacomposite(:,indice_industries(i),pays)=CI(:,indice_industries(i),pays);
        p_ener_industrie=[pArmCI_wo_CCS_nexus(indice_coal,indice_industries(i),pays);pArmCI_wo_CCS_nexus(indice_Et,indice_industries(i),pays);pArmCI_wo_CCS_nexus(indice_gas,indice_industries(i),pays);pArmCI_wo_CCS_nexus(indice_elec,indice_industries(i),pays)];		
        p_ener_industrie_CCS=[pArmCI_w_CCS_nexus(indice_coal,indice_industries(i),pays);pArmCI_w_CCS_nexus(indice_Et,indice_industries(i),pays);pArmCI_w_CCS_nexus(indice_gas,indice_industries(i),pays);pArmCI_w_CCS_nexus(indice_elec,indice_industries(i),pays)];
        p_ener_industrie(indice_coal) = p_ener_industrie(indice_coal) * dynForc_pcoal2;
        p_ener_industrie_CCS(indice_coal) = p_ener_industrie_CCS(indice_coal) * dynForc_pcoal2;
        LCC_industrie_noCCS=K_cost_industries(pays,:,i)'.*CRF_industrie+p_ener_industrie./rhoindustrie_dyn;
        LCC_industrie_CCS=K_cost_industries(pays,:,i)'.*CRF_industrie+p_ener_industrie_CCS./rhoindustrie_dyn + CCS_cost_industrie .* croyance_taxe(pays)/1e6*coef_Q_CO2_CI_prev([indice_coal,indice_Et,indice_gas,indice_elec],indice_industries(i),pays);
		
        if ind_CCS_industrie==1 & current_time_im>=start_year_strong_policy-base_year_simulation
            choose_CCS_industrie(:,pays)=LCC_industrie_CCS<LCC_industrie_noCCS;
        end
        if ind_electrification_indu<>2 & current_time_im >=start_year_strong_policy-base_year_simulation
            LCC_industrie=choose_CCS_industrie(:,pays).*LCC_industrie_CCS+(~choose_CCS_industrie(:,pays)).*LCC_industrie_noCCS;
        else
            LCC_industrie=LCC_industrie_noCCS;
        end
        SH_ener_calib=zeros(4,1);
        for j=1:4
            SH_ener_calib(j)=(LCC_industrie(j)).^(-var_hom_industrie(pays))./sum((((LCC_industrie)).^(-var_hom_industrie(pays)*ones(4,1))));
        end
        Pcoal_delta_ind(pays,i)=SH_ener_calib(1);
        Poil_delta_ind(pays,i)=SH_ener_calib(2);
        Pgaz_delta_ind(pays,i)=SH_ener_calib(3);
        Pelec_delta_ind(pays,i)=SH_ener_calib(4);
        if ind_electrification_indu<>2 & current_time_im >=start_year_strong_policy-base_year_simulation
            pArmCI_nexus_industrie([indice_coal,indice_Et,indice_gas,indice_elec],indice_industries(i),pays) = choose_CCS_industrie(:,pays).*pArmCI_wo_CCS_nexus([indice_coal,indice_Et,indice_gas,indice_elec],indice_industries(i),pays) +(~choose_CCS_industrie(:,pays)) .* pArmCI_w_CCS_nexus([indice_coal,indice_Et,indice_gas,indice_elec],indice_industries(i),pays);
        else
            pArmCI_nexus_industrie([indice_coal,indice_Et,indice_gas,indice_elec],indice_industries(i),pays) = pArmCI_wo_CCS_nexus([indice_coal,indice_Et,indice_gas,indice_elec],indice_industries(i),pays);
        end
    end

    if ind_electrification_indu>=1 & current_time_im >=start_year_strong_policy-base_year_simulation
        K_cost_industries(:,4,:) = K_cost_industries(:,4,:)*0.95;
    end

    CCS_in_industrie_vintage(:,:,i,current_time_im+dureedevieindustrie) = choose_CCS_industrie;
end



Pcoal_ind_Edelta=Pcoal_delta_ind;
fmultPcoal_ind_Edelta=Pcoal_ind_Edelta./(Pcoal_ind_Edeltaref+0.000000000000000000001); // DESAG_INDUSTRY: a few zeros in Pcoal_ind_Edeltaref, so this value was added, as for composite in the 12 sectors version (see lines 48 - ... of this file).

PEt_ind_Edelta=Poil_delta_ind;
fmultPEt_ind_Edelta=PEt_ind_Edelta./(PEt_ind_Edeltaref+0.000000000000000000001);

Pgaz_ind_Edelta=Pgaz_delta_ind;
fmultPgaz_ind_Edelta=Pgaz_ind_Edelta./(Pgaz_ind_Edeltaref+0.000000000000000000001);

Pelec_ind_Edelta=Pelec_delta_ind;
fmultPelec_ind_Edelta=Pelec_ind_Edelta./(Pelec_ind_Edeltaref+0.000000000000000000001);


///Substituable CI for new capacities
for k=1:reg
    CIdeltacompositeSubs(indice_coal,indice_industries,k)	=E_enerdelta_ind(k,:).*CIindSubsref(indice_coal,indice_industries,k)	.*fmultPcoal_ind_Edelta(k,:);
    CIdeltacompositeSubs(indice_gas,indice_industries,k)	=E_enerdelta_ind(k,:).*CIindSubsref(indice_gas,indice_industries,k)	.*fmultPgaz_ind_Edelta(k,:);
    CIdeltacompositeSubs(indice_Et,indice_industries,k)		=E_enerdelta_ind(k,:).*CIindSubsref(indice_Et,indice_industries,k)		.*fmultPEt_ind_Edelta(k,:);
    CIdeltacompositeSubs(indice_elec,indice_industries,k)	=E_enerdelta_ind(k,:).*CIindSubsref(indice_elec,indice_industries,k)	.*fmultPelec_ind_Edelta(k,:);
end

///Specific CI for new capacities
for k=1:reg
    CIdeltacompositeSpec(indice_gas,indice_industries,k)=min (E_enerdelta_ind(k,:).*CIindSpecref(indice_gas,indice_industries,k),...
    E_enerdelta_ind(k,:).*CIindSpecref(indice_gas,indice_industries,k).*(pArmCI_nexus_industrie(indice_gas,indice_industries,k)./pArmCIref(indice_gas,indice_industries,k)).^elast_gaz_ind(k,:));

    CIdeltacompositeSpec(indice_Et,indice_industries,k)=min (E_enerdelta_ind(k,:).*CIindSpecref(indice_Et,indice_industries,k),...
    E_enerdelta_ind(k,:).*CIindSpecref(indice_Et,indice_industries,k).*(pArmCI_nexus_industrie(indice_Et,indice_industries,k)./pArmCIref(indice_Et,indice_industries,k)).^elast_Et_ind(k,:));

    CIdeltacompositeSpec(indice_elec,indice_industries,k)=min (E_enerdelta_ind(k,:).*CIindSpecref(indice_elec,indice_industries,k),...
    E_enerdelta_ind(k,:).*CIindSpecref(indice_elec,indice_industries,k).*(pArmCI_nexus_industrie(indice_elec,indice_industries,k)./pArmCIref(indice_elec,indice_industries,k)).^elast_elec_ind(k,:));

    CIdeltacompositeSpec(indice_coal,indice_industries,k)=min (E_enerdelta_ind(k,:).*CIindSpecref(indice_coal,indice_industries,k),...
    E_enerdelta_ind(k,:).*CIindSpecref(indice_coal,indice_industries,k).*(pArmCI_nexus_industrie(indice_coal,indice_industries,k)./pArmCIref(indice_coal,indice_industries,k)).^elast_coal_ind(k,:));

end

///CI of new capacities
for k=1:reg
    CIdeltacomposite(indice_coal,indice_industries,k)	=CIdeltacompositeSubs(indice_coal,indice_industries,k)+CIdeltacompositeSpec(indice_coal,indice_industries,k);
    CIdeltacomposite(indice_oil,indice_industries,k)	=CI(indice_oil,indice_industries,k);
    CIdeltacomposite(indice_gas,indice_industries,k)	=CIdeltacompositeSubs(indice_gas,indice_industries,k)+CIdeltacompositeSpec(indice_gas,indice_industries,k);
    CIdeltacomposite(indice_Et,indice_industries,k)		=CIdeltacompositeSubs(indice_Et,indice_industries,k)+CIdeltacompositeSpec(indice_Et,indice_industries,k);
    CIdeltacomposite(indice_elec,indice_industries,k)	=CIdeltacompositeSubs(indice_elec,indice_industries,k)+CIdeltacompositeSpec(indice_elec,indice_industries,k);
end

////////////////////////////////////////////////////////////////////////////////////////
//////// Cost of capital from energy efficiency induced by the carbon tax
//compute the technologies caracteristic of build capacities, without induced efficiency
CIdeltacomposite_BAU=zeros(sec,sec,reg);
CIdeltacompSubs_BAU=zeros(sec,sec,reg);
CIdeltacompSpec_BAU=zeros(sec,sec,reg);

for k=1:reg
    CIdeltacompSubs_BAU(indice_coal,indice_composite,k)=E_enerdelta_ser_BAU(k)* CIcompositeSubsref(indice_coal,indice_composite,k) *fmultPcoal_comp_Edelta(k);
    CIdeltacompSpec_BAU(indice_coal,indice_composite,k)=E_enerdelta_ser_BAU(k)* CIcompositeSpecref(indice_coal,indice_composite,k);
    CIdeltacomposite_BAU(indice_coal,indice_composite,k)=CIdeltacompSubs_BAU(indice_coal,indice_composite,k)+CIdeltacompSpec_BAU(indice_coal,indice_composite,k);
    CIdeltacompSubs_BAU(indice_gas,indice_composite,k)=E_enerdelta_ser_BAU(k)* CIcompositeSubsref(indice_gas, indice_composite,k) * fmultPgaz_comp_Edelta(k);
    CIdeltacompSpec_BAU(indice_gas,indice_composite,k)=E_enerdelta_ser_BAU(k)* CIcompositeSpecref(indice_gas, indice_composite,k);
    CIdeltacomposite_BAU(indice_gas,indice_composite,k)=CIdeltacompSubs_BAU(indice_gas,indice_composite,k)+CIdeltacompSpec_BAU(indice_gas,indice_composite,k);
    CIdeltacompSubs_BAU(indice_Et,indice_composite,k)=E_enerdelta_ser_BAU(k)* CIcompositeSubsref(indice_Et,  indice_composite,k) *  fmultPEt_comp_Edelta(k);
    CIdeltacompSpec_BAU(indice_Et,indice_composite,k)=E_enerdelta_ser_BAU(k)* CIcompositeSpecref(indice_Et,  indice_composite,k);
    CIdeltacomposite_BAU(indice_Et,indice_composite,k)=CIdeltacompSubs_BAU(indice_Et,indice_composite,k)+CIdeltacompSpec_BAU(indice_Et,indice_composite,k);
    CIdeltacompSubs_BAU(indice_elec,indice_composite,k)=E_enerdelta_ser_BAU(k)*(CIcompositeSubsref(indice_elec,indice_composite,k))*fmultPelec_comp_Edelta(k);
    CIdeltacompSpec_BAU(indice_elec,indice_composite,k)=E_enerdelta_ser_elec_BAU(k)*(CIcompositeSpecref(indice_elec,indice_composite,k));
    CIdeltacomposite_BAU(indice_elec,indice_composite,k)=CIdeltacompSubs_BAU(indice_elec,indice_composite,k)+CIdeltacompSpec_BAU(indice_elec,indice_composite,k);
    CIdeltacomposite_BAU(indice_oil,indice_composite,k)=                              CI(indice_oil, indice_composite,k);
end
for k=1:reg
    CIdeltacompSubs_BAU(indice_coal,indice_agriculture,k)=E_enerdelta_agr_BAU(k)* CIagricSubsref(indice_coal,indice_agriculture,k) *fmultPcoal_agric_Edelta(k);
    CIdeltacompSpec_BAU(indice_coal,indice_agriculture,k)=E_enerdelta_agr_BAU(k)* CIagricSpecref(indice_coal,indice_agriculture,k);
    CIdeltacomposite_BAU(indice_coal,indice_agriculture,k)=CIdeltacompSubs_BAU(indice_coal,indice_agriculture,k)+CIdeltacompSpec_BAU(indice_coal,indice_agriculture,k);
    CIdeltacompSubs_BAU(indice_gas,indice_agriculture,k)=E_enerdelta_agr_BAU(k)* CIagricSubsref(indice_gas, indice_agriculture,k) * fmultPgaz_agric_Edelta(k);
    CIdeltacompSpec_BAU(indice_gas,indice_agriculture,k)=E_enerdelta_agr_BAU(k)* CIagricSpecref(indice_gas, indice_agriculture,k);
    CIdeltacomposite_BAU(indice_gas,indice_agriculture,k)=CIdeltacompSubs_BAU(indice_gas,indice_agriculture,k)+CIdeltacompSpec_BAU(indice_gas,indice_agriculture,k);
    CIdeltacompSubs_BAU(indice_Et,indice_agriculture,k)=E_enerdelta_agr_BAU(k)* CIagricSubsref(indice_Et,  indice_agriculture,k) *  fmultPEt_agric_Edelta(k);
    CIdeltacompSpec_BAU(indice_Et,indice_agriculture,k)=E_enerdelta_agr_BAU(k)* CIagricSpecref(indice_Et,  indice_agriculture,k);
    CIdeltacomposite_BAU(indice_Et,indice_agriculture,k)=CIdeltacompSubs_BAU(indice_Et,indice_agriculture,k)+CIdeltacompSpec_BAU(indice_Et,indice_agriculture,k);
    CIdeltacompSubs_BAU(indice_elec,indice_agriculture,k)=E_enerdelta_agr_BAU(k)*(CIagricSubsref(indice_elec,indice_agriculture,k))*fmultPelec_agric_Edelta(k);
    CIdeltacompSpec_BAU(indice_elec,indice_agriculture,k)=E_enerdelta_agr_elec_BAU(k)*(CIagricSpecref(indice_elec,indice_agriculture,k));
    CIdeltacomposite_BAU(indice_elec,indice_agriculture,k)=CIdeltacompSubs_BAU(indice_elec,indice_agriculture,k)+CIdeltacompSpec_BAU(indice_elec,indice_agriculture,k);
    if ind_NLU_CI ==1
        CIdeltacomposite_BAU(indice_oil,indice_agriculture,k)=alphaIC_agriFoodProcess(indice_oil, k); // coupling with the nexus land-use, only the disaggregated agriFoodProcess sector is considered
    else
        CIdeltacomposite_BAU(indice_oil,indice_agriculture,k)=CI(indice_oil, indice_agriculture,k);
    end
end
for k=1:reg
    CIdeltacompSubs_BAU(indice_coal,indice_industries,k)=E_enerdelta_ind_BAU(k,:)	.* CIindSubsref(indice_coal,indice_industries,k) .*fmultPcoal_ind_Edelta(k,:);
    CIdeltacompSpec_BAU(indice_coal,indice_industries,k)=E_enerdelta_ind_BAU(k,:)	.* CIindSpecref(indice_coal,indice_industries,k);
    CIdeltacomposite_BAU(indice_coal,indice_industries,k)=CIdeltacompSubs_BAU(indice_coal,indice_industries,k)+CIdeltacompSpec_BAU(indice_coal,indice_industries,k);
    
    CIdeltacompSubs_BAU(indice_gas,indice_industries,k)=E_enerdelta_ind_BAU(k,:)	.* CIindSubsref(indice_gas, indice_industries,k) .* fmultPgaz_ind_Edelta(k,:);
    CIdeltacompSpec_BAU(indice_gas,indice_industries,k)=E_enerdelta_ind_BAU(k,:)	.* CIindSpecref(indice_gas, indice_industries,k);
    CIdeltacomposite_BAU(indice_gas,indice_industries,k)=CIdeltacompSubs_BAU(indice_gas,indice_industries,k)+CIdeltacompSpec_BAU(indice_gas,indice_industries,k);
    
    CIdeltacompSubs_BAU(indice_Et,indice_industries,k)=E_enerdelta_ind_BAU(k,:)	.* CIindSubsref(indice_Et,  indice_industries,k) .*  fmultPEt_ind_Edelta(k,:);
    CIdeltacompSpec_BAU(indice_Et,indice_industries,k)=E_enerdelta_ind_BAU(k,:)	.* CIindSpecref(indice_Et,  indice_industries,k);
    CIdeltacomposite_BAU(indice_Et,indice_industries,k)=CIdeltacompSubs_BAU(indice_Et,indice_industries,k)+CIdeltacompSpec_BAU(indice_Et,indice_industries,k);
    
    CIdeltacompSubs_BAU(indice_elec,indice_industries,k)=E_enerdelta_ind_BAU(k,:)	.*(CIindSubsref(indice_elec,indice_industries,k)).*fmultPelec_ind_Edelta(k,:);
    CIdeltacompSpec_BAU(indice_elec,indice_industries,k)=E_enerdelta_ind_BAU(k,:)	.*(CIindSpecref(indice_elec,indice_industries,k));
    CIdeltacomposite_BAU(indice_elec,indice_industries,k)=CIdeltacompSubs_BAU(indice_elec,indice_industries,k)+CIdeltacompSpec_BAU(indice_elec,indice_industries,k);
    
    CIdeltacomposite_BAU(indice_oil,indice_industries,k)=CI(indice_oil, indice_industries,k);
end



//#############################################################################################
//#############################################################################################
//### STEP 2 : CIvintageXXXSubs & CIvintageXXXSpec from 
//### 			CIdeltacompositeSpec & CIdeltacompositeSubs & eei
//#############################################################################################
//#############################################################################################

/////////////////// global energy efficiency improvement ////////////////////////
///////////////////Capital vintages
Conso_ener_indus=zeros(reg,nb_sectors_industry);
for k=1:reg
    Conso_ener_indus(k,:)=sum(CI(1:nbsecteurenergie,indice_industries,k)).*Q(k,indice_industries);
end

CIvintagecomposite;CIvintagecompSubs;CIvintagecompSpec;CIvintageagriculture;CIvintageagriSubs;CIvintageagriSpec;CIvintageindustries;CIvintageinduSubs;CIvintageinduSpec;
for k=1:reg
    for j=1:nbsecteurenergie
        CIvintagecomposite(j,k,:)  = CIvintagecomposite(j,k,:)   *(1+AEEI_allVintages(k,indice_composite  ,current_time_im));
        CIvintagecompSubs(j,k,:)   = CIvintagecompSubs(j,k,:)    *(1+AEEI_allVintages(k,indice_composite  ,current_time_im));
        CIvintagecompSpec(j,k,:)   = CIvintagecompSpec(j,k,:)    *(1+AEEI_allVintages(k,indice_composite  ,current_time_im));
        CIvintageagriculture(j,k,:)= CIvintageagriculture(j,k,:) *(1+AEEI_allVintages(k,indice_agriculture,current_time_im));
        CIvintageagriSubs(j,k,:)   = CIvintageagriSubs(j,k,:)    *(1+AEEI_allVintages(k,indice_agriculture,current_time_im));
        CIvintageagriSpec(j,k,:)   = CIvintageagriSpec(j,k,:)    *(1+AEEI_allVintages(k,indice_agriculture,current_time_im));
        for i=1:nb_sectors_industry,
            CIvintageindustries	(j,i,k,:)	= CIvintageindustries	(j,i,k,:) * (1+AEEI_allVintages(k,indice_industries(i),current_time_im));
            CIvintageinduSubs		(j,i,k,:)	= CIvintageinduSubs	(j,i,k,:) * (1+AEEI_allVintages(k,indice_industries(i),current_time_im));
            CIvintageinduSpec		(j,i,k,:) 	= CIvintageinduSpec	(j,i,k,:) * (1+AEEI_allVintages(k,indice_industries(i),current_time_im));
        end
    end
end
//CIvintagecomposite == CIvintagecompSubs + CIvintagecompSpec ??? a verifier todo RUBEN




//#############################################################################################
//#############################################################################################
//### STEP 3 : CI from CIvintageXXX & CapvintageXXX
//#############################################################################################
//#############################################################################################

//////////////////////////initialisation of the new capital vintage for the composite sector

for k=1:reg
    CIvintagecompSubs(:,k,current_time_im+dureedeviecomposite)=CIdeltacompositeSubs(:,indice_composite,k);
    CIvintageagriSubs(:,k,current_time_im+dureedevieagriculture)=CIdeltacompositeSubs(:,indice_agriculture,k);
    if NEXUS_indus==0
        CIvintageinduSubs(:,:,k,current_time_im+dureedevieindustrie)=CIdeltacompositeSubs(:,indice_industries,k);
    end
end

for k=1:reg
    CIvintagecompSpec(:,k,current_time_im+dureedeviecomposite)=CIdeltacompositeSpec(:,indice_composite,k);
    CIvintageagriSpec(:,k,current_time_im+dureedevieagriculture)=CIdeltacompositeSpec(:,indice_agriculture,k);
    if NEXUS_indus==0
        CIvintageinduSpec(:,:,k,current_time_im+dureedevieindustrie)=CIdeltacompositeSpec(:,indice_industries,k);
    end
end

for k=1:reg
    CIvintagecomposite(:,k,current_time_im+dureedeviecomposite)=CIdeltacomposite(:,indice_composite,k);
    CIvintageagriculture(:,k,current_time_im+dureedevieagriculture)=CIdeltacomposite(:,indice_agriculture,k);
    if NEXUS_indus==0
        CIvintageindustries(:,:,k,current_time_im+dureedevieindustrie)=CIdeltacomposite(:,indice_industries,k);
    end
end

sumCItempcompSubs=zeros(sec,reg);
sumCItempagriSubs=zeros(sec,reg);
sumCItempcompSpec=zeros(sec,reg);
sumCItempagriSpec=zeros(sec,reg);
sumCItempcomposite=zeros(sec,reg);
sumCItempagriculture=zeros(sec,reg);
if NEXUS_indus==0
    sumCItempinduSubs=zeros(sec,nb_sectors_industry,reg);
    sumCItempinduSpec=zeros(sec,nb_sectors_industry,reg);
    sumCItempindustrie=zeros(sec,nb_sectors_industry,reg);
end

for k=1:reg,
    for j=1:dureedeviecomposite
        sumCItempcompSubs(:,k)=Capvintagecomposite(k,current_time_im+j)*CIvintagecompSubs(:,k,current_time_im+j)+sumCItempcompSubs(:,k);
        sumCItempcompSpec(:,k)=Capvintagecomposite(k,current_time_im+j)*CIvintagecompSpec(:,k,current_time_im+j)+sumCItempcompSpec(:,k);
        sumCItempcomposite(:,k)=Capvintagecomposite(k,current_time_im+j)*CIvintagecomposite(:,k,current_time_im+j)+sumCItempcomposite(:,k);
    end
end

for k=1:reg,
    for j=1:dureedevieagriculture
        sumCItempagriSubs(:,k)=Capvintageagriculture(k,current_time_im+j)*CIvintageagriSubs(:,k,current_time_im+j)+sumCItempagriSubs(:,k);
        sumCItempagriSpec(:,k)=Capvintageagriculture(k,current_time_im+j)*CIvintageagriSpec(:,k,current_time_im+j)+sumCItempagriSpec(:,k);
        sumCItempagriculture(:,k)=Capvintageagriculture(k,current_time_im+j)*CIvintageagriculture(:,k,current_time_im+j)+sumCItempagriculture(:,k);
    end
end

if NEXUS_indus==0
    for k=1:reg,
        for j=1:dureedevieindustrie
            for i = 1:nb_sectors_industry
                sumCItempinduSubs(:,i,k)	=Capvintageindustries(k,i,current_time_im+j)*CIvintageinduSubs(:,i,k,current_time_im+j)+sumCItempinduSubs(:,i,k);
                sumCItempinduSpec(:,i,k)	=Capvintageindustries(k,i,current_time_im+j)*CIvintageinduSpec(:,i,k,current_time_im+j)+sumCItempinduSpec(:,i,k);
                sumCItempindustrie(:,i,k)	=Capvintageindustries(k,i,current_time_im+j)*CIvintageindustries(:,i,k,current_time_im+j)+sumCItempindustrie(:,i,k);
            end
        end
    end
end

for k=1:reg,
    CI_Subs(:,indice_composite,k)=sumCItempcompSubs(:,k)/sumCaptempcomposite(1,k);
    CI_Spec(:,indice_composite,k)=sumCItempcompSpec(:,k)/sumCaptempcomposite(1,k);
    if indice_LED == 0
        CI(:,indice_composite,k)=sumCItempcomposite(:,k)/sumCaptempcomposite(1,k);
    else
        CI(energyIndexes,indice_composite,k)=sumCItempcomposite(energyIndexes,k)/sumCaptempcomposite(1,k);
    end
    CI_Subs(:,indice_agriculture,k)=sumCItempagriSubs(:,k)/sumCaptempagriculture(1,k);
    CI_Spec(:,indice_agriculture,k)=sumCItempagriSpec(:,k)/sumCaptempagriculture(1,k);
    if ind_NLU_CI ==1 // coupling with the nexus land-use, only the disaggregated agriFoodProcess sector is considered
        alphaIC_agriFoodProcess(:,k) = sumCItempagriculture(:,k)/sumCaptempagriculture(1,k);
    else
        if indice_LED == 0
            CI(:,indice_agriculture,k)=sumCItempagriculture(:,k)/sumCaptempagriculture(1,k);
        else
            CI(energyIndexes,indice_agriculture,k)=sumCItempagriculture(energyIndexes,k)/sumCaptempagriculture(1,k);
        end
    end
    if NEXUS_indus==0
        for i=1:nb_sectors_industry
            CI_Subs(:,indice_industries(i),k)=sumCItempinduSubs(:,i,k)		/sumCaptempindustries(k,i);
            CI_Spec(:,indice_industries(i),k)=sumCItempinduSpec(:,i,k)		/sumCaptempindustries(k,i);
            if indice_LED == 0
                CI(:,indice_industries(i),k)            =sumCItempindustrie(:,i,k)      /sumCaptempindustries(k,i);
            else
                CI(energyIndexes,indice_industries(i),k)		=sumCItempindustrie(energyIndexes,i,k)	/sumCaptempindustries(k,i);
            end
        end
        if ind_NLU_ferti == 1
            if k <> ind_chn
                alpha_gas2indus0fert(k) = sumCItempindustrie(gaz,k)/sumCaptempindustrie(1,k); //MULTISECTOR: this line has not been updated
            else
                alpha_coal2ind0ferti_CHN =  sumCItempindustrie(coal,k)/sumCaptempindustrie(1,k); //MULTISECTOR: this line has not been updated
            end
        end
    end
end





for k=1:reg
    sumEmi_temp = zeros(4,1);
    sumCap_temp = 0;
    for i=1:nb_sectors_industry
        for j=1:dureedevieindustrie
            sumEmi_temp = sumEmi_temp + (~CCS_in_industrie_vintage(:,k,i,current_time_im+j)) .* coef_Q_CO2_CI_wo_CCS( [indice_coal,indice_Et,indice_gas,indice_elec],indice_industries(i),k) .* Capvintageindustries(k,i,current_time_im+j);
            sumEmi_temp = sumEmi_temp + (CCS_in_industrie_vintage(:,k,i,current_time_im+j)) .* (1-CCS_efficiency_industry) .* coef_Q_CO2_CI_wo_CCS( [indice_coal,indice_Et,indice_gas,indice_elec],indice_industries(i),k) .* Capvintageindustries(k,i,current_time_im+j);
            sumCap_temp = sumCap_temp + Capvintageindustries(k,i,current_time_im+j);
        end
        coef_Q_CO2_CI( [indice_coal,indice_Et,indice_gas,indice_elec],indice_industries(i),k) = sumEmi_temp / sumCap_temp;
    end
end

//#############################################################################################
//#############################################################################################
//### STEP 4 : Structural change assumptions for intermediate consumption
//#############################################################################################
//#############################################################################################

//        Evolution of intermediate consumption of the composite sector, so as to reflect a stylized structural change towards less agricultural and insutrial goods prorduction
//	  As well as servitisation of industrial production
//        The intermediate consumption of the agrucultural and industrial goods consumption in the composite sector follow the evolution of the ratio of the households demand (resp. for agricultural and industry) to services consumption: for example, as the consumption share of services grows, households goes less to restaurant in proportion of total services consumption.
//        This decrease (CI (agri, industry -> composite)) is reported towards an increase use of services in the compositie sector (servitisation), so that the total cost remain unchanged"

if indice_LED == 0 & (ind_SC_indus_towards_services == "services_only" | ind_SC_indus_towards_services == "full_SC_CI" | ind_SC_indus_towards_services == "full_SC")
    for k=1:reg
        for i=1:nb_sectors_industry
            CI(indice_industries(i),indice_composite,k)=min(CI(indice_industries(i),indice_composite,k),...
                CIref(indice_industries(i),indice_composite,k)*Qref(k,indice_composite)/Q(k,indice_composite)...
            * DF(k,indice_industries(i)) ./ DFref(k,indice_industries(i)) .* DFref(k,indice_composite) ./ DF(k,indice_composite));
        end
        CI(indice_agriculture,indice_composite,k)=min(CI(indice_agriculture,indice_composite,k),...
            CIref(indice_agriculture,indice_composite,k)*Qref(k,indice_composite)/Q(k,indice_composite)...
        * DF(k,indice_agriculture) ./ DFref(k,indice_agriculture) .* DFref(k,indice_composite) ./ DF(k,indice_composite));
        //Report on services to services intermediate consumtpions (assuming constant capital costs)
        CI(indice_composite,indice_composite,k)=CI_prev(indice_composite,indice_composite,k)+... 
            sum((-CI(indice_industries,indice_composite,k)+CI_prev(indice_industries,indice_composite,k)).*pArmCI(indice_industries,indice_composite,k),'r')/pArmCI(indice_composite,indice_composite,k)+...
        (-CI(indice_agriculture,indice_composite,k)+CI_prev(indice_agriculture,indice_composite,k))*pArmCI(indice_agriculture,indice_composite,k)/pArmCI(indice_composite,indice_composite,k);
    end
end
if indice_LED == 0 & (ind_SC_indus_towards_services == "industries_only" | ind_SC_indus_towards_services == "full_SC_CI" | ind_SC_indus_towards_services == "full_SC")
    for k=1:reg
        for i=1:nb_sectors_industry
            CI(indice_industries(i),indice_industries(i),k)=min(CI(indice_industries(i),indice_industries(i),k),...
                CIref(indice_industries(i),indice_industries(i),k)*Qref(k,indice_industries(i))/Q(k,indice_industries(i))...
            * DF(k,indice_industries(i)) ./ DFref(k,indice_industries(i)) .* DFref(k,indice_composite) ./ DF(k,indice_composite));
        end
        //Report on services to services intermediate consumtpions (assuming constant capital costs)
        CI(indice_composite,indice_industries(i),k)=CI_prev(indice_composite,indice_industries(i),k)+...
        sum((-CI(indice_industries,indice_industries(i),k)+CI_prev(indice_industries,indice_industries(i),k)).*pArmCI(indice_industries,indice_industries(i),k),'r')/pArmCI(indice_composite,indice_industries(i),k);
    end
end

