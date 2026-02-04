//#############################################################################################
//#############################################################################################
//### STEP 1: Energy efficiency of the timestep
//#############################################################################################
//#############################################################################################



expected.pArmCI_EEI = ( pArmCI + expected.pArmCI(:,:,:,expectations.horizon.eei) ) / 2 ;

pIndEner = compPIndEner(expected.pArmCI_EEI,pArmCIref,CI,CIref);
EI = dynamicEI (current_time_im, TimeHorizon, nonEnergSectors, energSectors, nb_regions, EI);

if current_time_im>1
    // EEI  est la partie payante  des améliorations
    // AEEI est la partie gratuite des améliorations
    // _newVintage correspond à la construction de nouvelles capacités
    // _allVintage correspond à l'amélioration d'anciennes capacités

    EEI_newVintage  (:,:,current_time_im) = (EI(:,:,current_time_im) ./ EI(:,:,current_time_im-1)) - 1;
    for k=1:nb_regions,
        for j=1:nb_sectors,
            if k<6
			
			if j==indice_composite & ind_buildingefficiency == 1 & current_time_im >= start_year_strong_policy-base_year_simulation
				EEI_newVintage(k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1))^EI_comp_boost - 1),-0.03*EI_comp_boost);// We introduce a higher maximum rate for services in this variant
			else
				EEI_newVintage(k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1)) - 1),-0.03);
			end
            end
            if k>=6
			if j==indice_composite & ind_buildingefficiency == 1 & current_time_im >= start_year_strong_policy-base_year_simulation
				EEI_newVintage(k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1))^EI_comp_boost - 1),-0.045*max_eei*EI_comp_boost);// We introduce a higher maximum rate for services in this variant
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
				if j==indice_composite & ind_buildingefficiency == 1 & current_time_im >= start_year_strong_policy-base_year_simulation
					AEEI_allVintages(k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1))^EI_comp_boost - 1)/2,-0.01*EI_comp_boost);// We introduce a higher maximum rate for services in this variant
					AEEI_newVintage (k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1))^EI_comp_boost - 1)/2,-0.01*EI_comp_boost);// We introduce a higher maximum rate for services in this variant
				else
					AEEI_allVintages(k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1)) - 1)/2,-0.01);
					AEEI_newVintage (k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1)) - 1)/2,-0.01);				
				end
            end
            if k>=6
				if j==indice_composite & ind_buildingefficiency == 1 & current_time_im >= start_year_strong_policy-base_year_simulation
					AEEI_allVintages(k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1))^EI_comp_boost - 1)/2,-0.015*max_aeei*EI_comp_boost);// We introduce a higher maximum rate for services in this variant
					AEEI_newVintage (k,j,current_time_im) = max(((EI(k,j,current_time_im) ./ EI(k,j,current_time_im-1))^EI_comp_boost - 1)/2,-0.015*max_aeei*EI_comp_boost);// We introduce a higher maximum rate for services in this variant
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


if (indice_tech_AEEI==1) // Variante où intensité transport de la croissance évolue comme l'AEEI du secteur industriel / 1.5 : Cas Pessimiste
    E_enerdelta_trans=E_enerdelta_trans.*(ones(nb_regions,1)+AEEI_newVintage(:,indice_industries($),current_time_im)/1.5); //MULTISECTOR variant, NB: we assume equipment indusry as reference sector.
    progres_AEEI_trans=E_enerdelta_trans;
else                      // Variante où intensité transport de la croissance évolue comme l'AEEI du secteur industriel       : Cas optimiste
    E_enerdelta_trans=E_enerdelta_trans.*(ones(nb_regions,1)+AEEI_newVintage(:,indice_industries($),current_time_im)); //MULTISECTOR variant, NB: we assume equipment indusry as reference sector.
    progres_AEEI_trans=E_enerdelta_trans;
end

E_enerdelta_ser   = E_enerdelta(:,indice_composite  ,current_time_im);
E_enerdelta_agr   = E_enerdelta(:,indice_agriculture,current_time_im);
E_enerdelta_ind   = E_enerdelta(:,indice_industries  ,current_time_im);

//intensité énergétique sans EEI induit par les politiques
E_enerdelta_ser_BAU   = E_enerdeltaFree(:,indice_composite  ,current_time_im);
E_enerdelta_agr_BAU   = E_enerdeltaFree(:,indice_agriculture,current_time_im);
E_enerdelta_ind_BAU   = E_enerdeltaFree(:,indice_industries  ,current_time_im);
