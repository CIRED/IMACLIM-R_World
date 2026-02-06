// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Thomas Le Gallic, Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//#############################################################################################
//#############################################################################################
//### STEP 1: Energy efficiency of the timestep
//#############################################################################################
//#############################################################################################

expArmCI_EEI=zeros(sec,sec,reg);

disc_rate_prices_EEI = 0.1*ones(reg,1);

if test_expect_prices == 1
    for k=1:reg
        for j=1:sec
            for ll=1:sec
                expArmCI_EEI(j,ll,k) = sum([pArmCI(j,ll,k); squeeze(expected.pArmCI(j,ll,k,1:expectations.horizon.eei))]'./(1+disc_rate_EEI(k))^(1:(expectations.horizon.eei+1)))/sum((1+disc_rate_EEI(k))^(1:(expectations.horizon.eei+1))) ;
            end
        end
    end
    expected.pArmCI_EEI = expArmCI_EEI;
else
    expected.pArmCI_EEI = ( pArmCI + expected.pArmCI(:,:,:,expectations.horizon.eei) ) / 2 ;
end

pIndEner = compPIndEner(expected.pArmCI_EEI,pArmCIref,CI,CIref);

if ind_exogenous_forcings & current_time_im>i_year_strong_policy-1 // for the LED scenario, we want to force the EEI trajectory, without any feedback via energy price and the carbon price !
    EI = dynamicEI (current_time_im, TimeHorizon, nonEnergSectors, reg, EI, matrix(pIndEner_refLED(:,i+1),nb_regions,nb_sectors) );
    EI(ind_global_north, indice_industries, current_time_im) = EI(ind_global_north, indice_industries, current_time_im) .* dynForc_EI_indus(ind_global_north);
    EI(ind_global_south, indice_industries, current_time_im) = EI(ind_global_south, indice_industries, current_time_im) .* dynForc_EI_indus(ind_global_south);
    if same_EEI_agroCons_as_ind
        EI(ind_global_north, indice_agriculture, current_time_im) = EI(ind_global_north, indice_agriculture, current_time_im) .* dynForc_EI_indus(ind_global_north);
        EI(ind_global_south, indice_agriculture, current_time_im) = EI(ind_global_south, indice_agriculture, current_time_im) .* dynForc_EI_indus(ind_global_south);
    end
    EI(ind_global_north, indice_composite, current_time_im) = EI(ind_global_north, indice_composite, current_time_im) .* dynForc_EI_comp(ind_global_north);
    EI(ind_global_south, indice_composite, current_time_im) = EI(ind_global_south, indice_composite, current_time_im) .* dynForc_EI_comp(ind_global_south);
else
    EI = dynamicEI (current_time_im, TimeHorizon, nonEnergSectors, reg, EI, pIndEner);
end

if current_time_im>1
    // EEI  is the costly energy efficiency aprt
    // AEEI is autonomous (free) energy efficiency
    // _newVintage are new build capacities
    // _allVintage are previous capacities
    EEI_newVintage  (:,:,current_time_im) = (EI(:,:,current_time_im) ./ EI(:,:,current_time_im-1)) - 1;
    for k=1:nb_regions,
        for j=1:nb_sectors,
            if k<6
			
                if j==indice_composite & (ind_buildingefficiency | indice_LED ==4 | indice_LED ==8 | indice_LED ==9) == 1 & current_time_im >= start_year_strong_policy-base_year_simulation & ind_ssp_assymp_EEIComp==%f
                    EEI_newVintage(k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1))^EI_comp_boost - 1),-0.03*EI_comp_boost);// We introduce a higher maximum rate for services in this variant
                elseif ind_ssp_assymp_EEIComp==%t
                    EEI_newVintage(k,j,current_time_im) = (EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1)) - 1;
                else 
                    EEI_newVintage(k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1)) - 1),-0.03);
                end
            end
            if k>=6
                if j==indice_composite & (ind_buildingefficiency | indice_LED ==4 | indice_LED ==8 | indice_LED ==9) & current_time_im >= start_year_strong_policy-base_year_simulation & ind_ssp_assymp_EEIComp==%f
                    EEI_newVintage(k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1))^EI_comp_boost - 1),-0.045*max_eei*EI_comp_boost);// We introduce a higher maximum rate for services in this variant
                elseif ind_ssp_assymp_EEIComp==%t
                    EEI_newVintage(k,j,current_time_im) = (EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1)) - 1;
                else
                    EEI_newVintage(k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1)) - 1),-0.045*max_eei);			
                end
            end
        end
    end

    // AEEI_allVintages(:,:,current_time_im) = ((EI(:,:,current_time_im) ./ EI(:,:,current_time_im-1)) - 1)/2;
    // AEEI_newVintage (:,:,current_time_im) = ((EI(:,:,current_time_im) ./ EI(:,:,current_time_im-1)) - 1)/2;
    for k=1:nb_regions,
        for j=1:nb_sectors,
            if k<6
                if j==indice_composite & (ind_buildingefficiency | indice_LED ==4 | indice_LED ==8 | indice_LED ==9) & current_time_im >= start_year_strong_policy-base_year_simulation
                    AEEI_allVintages(k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1))^EI_comp_boost - 1)/2,-0.01*EI_comp_boost);// We introduce a higher maximum rate for services in this variant
                    AEEI_newVintage (k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1))^EI_comp_boost - 1)/2,-0.01*EI_comp_boost);// We introduce a higher maximum rate for services in this variant
                    AEEI_newVintage (k,j,current_time_im) = (EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1)) - 1;
                else
                    AEEI_allVintages(k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1)) - 1)/2,-0.01);
                    AEEI_newVintage (k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1)) - 1)/2,-0.01);				
                end
            end
            if k>=6
                if j==indice_composite & (ind_buildingefficiency | indice_LED ==4 | indice_LED ==8 | indice_LED ==9) & current_time_im >= start_year_strong_policy-base_year_simulation
                    AEEI_allVintages(k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1))^EI_comp_boost - 1)/2,-0.015*max_aeei*EI_comp_boost);// We introduce a higher maximum rate for services in this variant
                    AEEI_newVintage (k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1))^EI_comp_boost - 1)/2,-0.015*max_aeei*EI_comp_boost);// We introduce a higher maximum rate for services in this variant
                    AEEI_newVintage (k,j,current_time_im) = (EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1)) - 1;
                else
                    AEEI_allVintages(k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1)) - 1)/2,-0.015*max_aeei);
                    AEEI_newVintage (k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1)) - 1)/2,-0.015*max_aeei);
				
                end
            end
        end
    end
end

for region=1:nb_regions
    for sect=nonEnergSectors
        actualEI(region,sect,current_time_im) = sum(CI(energSectors,sect,region))./p(region,sect);
        actualEI(:,:,current_time_im) = actualEI(:,:,current_time_im) + (actualEI(:,:,current_time_im) == 0) .* ones(EI_ref);
    end
end

mksav( [ 'EEI_newVintage' 'AEEI_allVintages' 'AEEI_newVintage' 'EI' 'pIndEner' 'actualEI' ] );

//[(1:current_time_im)'  squeeze(actualEI(ind_usa,indus,1:current_time_im)) squeeze(EI(ind_usa,indus,1:current_time_im)) squeeze(actualEI(ind_usa,indus,1:current_time_im))./squeeze(EI(ind_usa,indus,1:current_time_im))]



//#############################################################################################
//#############################################################################################
//### STEP 2: Cumulated energy efficiency of the timestep
//#############################################################################################
//#############################################################################################

//E_enerdelta=E_enerdelta.*(ones(nb_regions,1)+AEEI(:,current_time_im)+EEI_decarb(:,indice_composite));
//E_enerdelta_BAU=E_enerdelta_BAU.*(ones(nb_regions,1)+AEEI(:,current_time_im));

if current_time_im>1  
    E_enerdelta(:,:,current_time_im)     = E_enerdelta(:,:,current_time_im-1)     .* (1+EEI_newVintage(:,:,current_time_im));
    E_enerdeltaFree(:,:,current_time_im) = E_enerdeltaFree(:,:,current_time_im-1) .* (1+AEEI_newVintage(:,:,current_time_im));
end


if (indice_tech_AEEI==1) //Pessimistic case: variant in which the transportintensity of sector evolves following the AEEI of the industrial sector / 1.5; 
    E_enerdelta_trans=E_enerdelta_trans.*(ones(nb_regions,1)+AEEI_newVintage(:,indice_industries($),current_time_im)/1.5); //MULTISECTOR variant, NB: we assume equipment indusry as reference sector.
    progres_AEEI_trans=E_enerdelta_trans;
else                      //Optimistic case: variant in which the transportintensity of sector evolves following the AEEI of the industrial sector
    E_enerdelta_trans=E_enerdelta_trans.*(ones(nb_regions,1)+AEEI_newVintage(:,indice_industries($),current_time_im)); //MULTISECTOR variant, NB: we assume equipment indusry as reference sector.
    progres_AEEI_trans=E_enerdelta_trans;
end

E_enerdelta_ser   = E_enerdelta(:,indice_composite  ,current_time_im);
E_enerdelta_agr   = E_enerdelta(:,indice_agriculture,current_time_im);
E_enerdelta_ind   = E_enerdelta(:,indice_industries  ,current_time_im);

//energy intensity without EEI induced by policies
E_enerdelta_ser_BAU   = E_enerdeltaFree(:,indice_composite  ,current_time_im);
E_enerdelta_agr_BAU   = E_enerdeltaFree(:,indice_agriculture,current_time_im);
E_enerdelta_ind_BAU   = E_enerdeltaFree(:,indice_industries  ,current_time_im);
