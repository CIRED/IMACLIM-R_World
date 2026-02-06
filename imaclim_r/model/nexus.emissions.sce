// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Augustin Danneaux, Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


// industrial process_emissions decrease as much of direct emission in the industrial sector
if nb_sectors_industry==1
    CO2_intensity_industry = matrix(sum(coef_Q_CO2_CI(:,indus,:) .* CI(:,indus,:),1),nb_regions,1);
else
    CO2_intensity_industry = sum(Q(:,indus) .* matrix(sum(coef_Q_CO2_CI(:,indus,:) .* CI(:,indus,:),1),nb_regions,nb_sectors_industry), "c") ./ sum(Q(:,indus), "c");
end

if current_time_im<start_year_policy-base_year_simulation
    CO2_indus_process = exo_CO2_indus_process(:,current_time_im+1);
elseif current_time_im==start_year_policy-base_year_simulation
    CO2_indus_process = exo_CO2_indus_process(:,current_time_im+1);
    CO2_indus_process_ref = CO2_indus_process;
    CO2_intensity_industry_ref = CO2_intensity_industry;
else
    CO2_indus_process = CO2_indus_process_ref ./ E_reg_use_ref(:,iu_indu) .* E_reg_use(:,iu_indu);
end

//AFOLU exogenous emissions in SSP2 2.6 scenario (unit: MtCO2), excluding negative emissions from BECCS
// This include afforestation and is used if ind_exo_afforestation==1
if ind_exo_afforestation==1
    E_AFOLU = exo_CO2_AFOLU(current_time_im+1) .* sum(E_reg_use(:,:),2)./sum(E_reg_use(:,:)); // AFOLU emissions are allocated pro-rata of E_reg_use
end

// CO2 emissions that are not taxed (mostly exogenous), but which has to be taken into account in the CO2 emission trajectoiry when set as an objective
if ind_exo_afforestation==1
    CO2_untaxed = (E_AFOLU + CO2_indus_process) * 1e6;
else
    CO2_untaxed = (exo_CO2_agri_direct(:,current_time_im+1) + exo_CO2_LUCCCF(:,current_time_im+1) + CO2_indus_process) * 1e6;
end



