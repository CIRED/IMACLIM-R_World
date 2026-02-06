// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================



if indice_LED >= 1
    parameter_change_method = "exponentialdecrease"; // "exponentialdecrease" | "linear"

    if  current_time_im>=start_year_strong_policy-base_year_simulation+5 & current_time_im<start_year_strong_policy-base_year_simulation+5+8
        dynForc_savings(ind_global_south) = 1.024;
    else
        dynForc_savings(ind_global_south)=1;
    end

    // GDP trajectory adjustment 
    if current_time_im > i_year_strong_policy-1
        dynForc_TCl = max(dynForc_TCl_2050, 1 - (1-dynForc_TCl_2050) / 10 * (current_time_im-(i_year_strong_policy-1)));
    end

    ///////////////////////////////////////////////
    // residential
    if current_time_im > start_year_strong_policy-base_year_simulation-1
        if indice_LED >= 1
            dynForc_resid_TBE1 = dynForc_resid_TBE1_2050;
            dynForc_resid_TBE2(ind_global_north) = dynForc_resid_TBE2_2050n;
            dynForc_resid_TBE2(ind_global_south) = dynForc_resid_TBE2_2050s;
        end
    end
    asymptote_surface_pc(ind_global_north) = asymptote_surface_pc_ref(ind_global_north) .* dynForc_resid_m2(ind_global_north);
    asymptote_surface_pc(ind_global_south) = asymptote_surface_pc_ref(ind_global_south) .* dynForc_resid_m2(ind_global_south);

    // transport and FE in industry
    if  current_time_im>=start_year_strong_policy-base_year_simulation & current_time_im<start_year_strong_policy-base_year_simulation+lenght_dynForc_cap_tr
        dynForc_cap_tr_air(ind_global_north) = dynForc_cap_tr_air(ind_global_north) + (dynForc_tair_2050_n-1)/lenght_dynForc_cap_tr;
        //dynForc_cap_tr_air(ind_global_south) = dynForc_cap_tr_air(ind_global_south) + (dynForc_tair_2050_s-1)/lenght_dynForc_cap_tr;
        dynForc_cap_tr_ot(ind_global_north) = dynForc_cap_tr_ot(ind_global_north) + (dynForc_tOt_2050_n-1)/lenght_dynForc_cap_tr;
        dynForc_cap_tr_ot(ind_global_south) = dynForc_cap_tr_ot(ind_global_south) + (dynForc_tOt_2050_s-1)/lenght_dynForc_cap_tr;
        dynForc_cap_tr_car(ind_global_north) = dynForc_cap_tr_car(ind_global_north) + (dynForc_tcar_2050_n-1)/lenght_dynForc_cap_tr;
        dynForc_cap_tr_car(ind_global_south) = dynForc_cap_tr_car(ind_global_south) + (dynForc_tcar_2050_s-1)/lenght_dynForc_cap_tr;
    end
    if  current_time_im>=start_year_strong_policy-base_year_simulation & current_time_im<start_year_strong_policy-base_year_simulation+0.9
        dynForc_cap_tr_air(ind_global_south) = dynForc_cap_tr_air(ind_global_south) + (dynForc_tair_2050_s-1)/lenght_dynForc_cap_tr;
    end

    if  current_time_im>=start_year_strong_policy-base_year_simulation & current_time_im<=start_year_strong_policy-base_year_simulation+lenght_dynForc_p_ener-1
        dynForc_pcoal = dynForc_pcoal + (dynForc_pcoal_2050-1)/lenght_dynForc_p_ener;
        dynForc_pcoal2 = dynForc_pcoal2 + (dynForc_pcoal2_2050-1)/lenght_dynForc_p_ener;
        dynForc_pEt_comp = dynForc_pEt_comp + (dynForc_pEt_comp_2050 - 1)/lenght_dynForc_p_ener;
    end

    if current_time_im>=start_year_strong_policy-base_year_simulation & current_time_im<=start_year_strong_policy-base_year_simulation+lenght_dynForc_pref_tr-1
        param_trans=0.992;
        atrans(ind_global_south,1) = atrans(ind_global_south,1) ./ (param_trans .^( 8/lenght_dynForc_pref_tr));
        ktrans(ind_global_south,1) = ktrans(ind_global_south,1) ./ (param_trans .^( 8/lenght_dynForc_pref_tr));
        xsiT(ind_global_south) = xsiT(ind_global_south) / (param_trans .^( 8/lenght_dynForc_pref_tr));
    end
    if current_time_im>=start_year_strong_policy-base_year_simulation & current_time_im<=start_year_strong_policy-base_year_simulation+lenght_dynForc_m2
        dynForc_m2_ener( ind_global_north) = update_parameter_rule( dynForc_m2_ener( ind_global_north), dynForc_m2_ener_2050_n, 1, lenght_dynForc_m2,current_time_im-start_year_strong_policy+base_year_simulation, "linear");
        dynForc_m2_ener( ind_global_south) = update_parameter_rule( dynForc_m2_ener( ind_global_south), dynForc_m2_ener_2050_s, 1, lenght_dynForc_m2, current_time_im-start_year_strong_policy+base_year_simulation, "linear");
    end

    if current_time_im==i_year_strong_policy //19
        tauxderempauto_istart = tauxderemplissageauto;
        tauxderempauto_50_n = a_occ_increase_2050_n * tauxderemplissageauto(ind_global_north) + b_occ_increase_2050_n;
        tauxderempauto_50_s = a_occ_increase_2050_s * tauxderemplissageauto(ind_global_south) + b_occ_increase_2050_s;
        dynForc_effAir( ind_global_north) =  dynForc_effAir_2050_n; 
        dynForc_effAir( ind_global_south) =  dynForc_effAir_2050_s; 
        dynForc_effOT2 (ind_global_north) = dynForc_effOT_2050_n; 
        dynForc_effOT2 (ind_global_south) = dynForc_effOT_2050_s;
        DIprod_istart = DIprod;
    end
    if current_time_im==i_year_strong_policy+lenght_dynForc_eff_tr
        dynForc_effAir = dynForc_effAir_prev;
        dynForc_effOT2(:) = 1;
    end	

    // linear convergence towards target - 2020 2050
    if current_time_im>=i_year_strong_policy & current_time_im < i_year_strong_policy +lenght_dynForc_1;
        if parameter_change_method == "exponentialdecrease"
            dynForc_EI_indus( ind_global_north) = dynForc_EI_indus_50_n; // already expo
            dynForc_EI_indus( ind_global_south) = dynForc_EI_indus_50_s; // already expo
        else 
            dynForc_EI_indus( ind_global_north) = update_parameter_rule( dynForc_EI_indus( ind_global_north), dynForc_EI_indus_50_n, dynForc_EI_indus_20( ind_global_north), year_stop_dynForc_allVar-(start_year_strong_policy-1),current_time_im-i_year_strong_policy+1, parameter_change_method);
            dynForc_EI_indus( ind_global_south) = update_parameter_rule( dynForc_EI_indus( ind_global_south), dynForc_EI_indus_50_s, dynForc_EI_indus_20( ind_global_south), year_stop_dynForc_allVar-(start_year_strong_policy-1), current_time_im-i_year_strong_policy+1,parameter_change_method);
        end
        tauxderemplissageauto( ind_global_north) = update_parameter_rule( tauxderemplissageauto( ind_global_north), tauxderempauto_50_n, tauxderempauto_istart( ind_global_north), year_stop_dynForc_allVar-(start_year_strong_policy-1), current_time_im-i_year_strong_policy+1,"linear");
        tauxderemplissageauto( ind_global_south) = update_parameter_rule( tauxderemplissageauto( ind_global_south), tauxderempauto_50_s, tauxderempauto_istart( ind_global_south), year_stop_dynForc_allVar-(start_year_strong_policy-1), current_time_im-i_year_strong_policy+1,"linear");
        dynForc_effOT1( ind_global_north) =  dynForc_effOT1( ind_global_north) + ( dynForc_effOT_2050_n - ones( ind_global_north)') ./ (year_stop_dynForc_allVar-(start_year_strong_policy-1));
        dynForc_effOT1( ind_global_south) =  dynForc_effOT1( ind_global_south) + ( dynForc_effOT_2050_s - ones( ind_global_south)') ./ (year_stop_dynForc_allVar-(start_year_strong_policy-1));
        if indice_LED <> 7 
            dynForc_hdf_cff( ind_global_north)  = update_parameter_rule( dynForc_hdf_cff( ind_global_north), dynForc_hdf_2050_n, 1, year_stop_dynForc_allVar-(start_year_strong_policy-1), current_time_im-i_year_strong_policy+1,parameter_change_method);
            dynForc_hdf_cff( ind_global_south)  = update_parameter_rule( dynForc_hdf_cff( ind_global_south), dynForc_hdf_2050_s, 1, year_stop_dynForc_allVar-(start_year_strong_policy-1), current_time_im-i_year_strong_policy+1,parameter_change_method);
        end

        if indice_LED <> 8

            DIprod_p = DIprod;
            DIprod( ind_global_north, indus) = update_parameter_rule( DIprod( ind_global_north, indus), DIprod_istart( ind_global_north, indus) * dynForc_DIindu_2050_n, DIprod_istart( ind_global_north, indus), year_stop_dynForc_allVar-(start_year_strong_policy-1), current_time_im-i_year_strong_policy+1,parameter_change_method);
            DIprod( ind_global_south, indus) = update_parameter_rule( DIprod( ind_global_south, indus), DIprod_istart( ind_global_south, indus) * dynForc_DIindu_2050_s, DIprod_istart( ind_global_south, indus), year_stop_dynForc_allVar-(start_year_strong_policy-1),current_time_im-i_year_strong_policy+1, parameter_change_method);

            delta_DIprod_indus = DIprod(:,indus) ./ DIprod_p(:,indus);
            Beta_p = matrix(Beta(compo,1,:),nb_regions,1);
            for k=1:reg,
                for ii=1:sec
                    Beta(compo,ii,k) = Beta_ref(compo,ii,k) + pArmDI(k,indus)* ( Beta_ref(indus,ii,k) - Beta(indus,ii,k) * delta_DIprod_indus(k)) / pArmDI(k,compo);
                    Beta(indus,ii,k)= Beta(indus,ii,k) .* delta_DIprod_indus(k);
                end
            end
            coeff_inc_betacomp = matrix(Beta(compo,1,:),nb_regions,1) ./ Beta_p ;
            DIprod( :, compo) = DIprod( :, compo) .* coeff_inc_betacomp;
        end
	
        if indice_LED <> 6
            dynForc_CIindu_2050( ind_global_north) = dynForc_CIindu_2050_n;
            dynForc_CIindu_2050( ind_global_south) = dynForc_CIindu_2050_s;
        end
    end

    if current_time_im == i_year_strong_policy
        ETA_2020 = ETA;
        ETA_2050 = ETA * (dynForc_ETAarm_2050);
    end
    if current_time_im>=i_year_strong_policy & current_time_im <i_year_strong_policy+5
        ETA = ETA * (dynForc_ETAarm_2050)^(1/5)
        etaDF = ETA*ones(reg,sec-nbsecteurenergie);
        etaDG=ETA*ones(reg,sec-nbsecteurenergie);
        etaDI=ETA*ones(reg,sec-nbsecteurenergie);
        etaCI=ETA*ones(sec-nbsecteurenergie,sec,reg);
    end

    // EEI on composite different than on industries
    if (indice_LED == 2 | indice_LED == 5 | indice_LED == 4 | indice_LED == 1| indice_LED == 8 | indice_LED == 6 | indice_LED==9) & current_time_im>=start_year_strong_policy-base_year_simulation   
        //dynForc_EI_comp = dynForc_EI_indus2comp*  dynForc_EI_indus -1; 
        dynForc_EI_indus2comp = update_parameter_rule( dynForc_EI_indus2comp, dynForc_EI_indus2comp_obj, 1, 15, current_time_im-i_year_strong_policy+1, "linear");
        dynForc_EI_comp = (dynForc_EI_indus2comp+1) .*  dynForc_EI_indus_obj -1; 
        //dynForc_EI_comp = update_parameter_rule( dynForc_EI_comp, dynForc_DGindu_2050_n, 1, year_stop_dynForc_allVar-(start_year_strong_policy-1), current_time_im-i_year_strong_policy+1, "linear"),
    else
        dynForc_EI_comp = dynForc_EI_indus;
    end

    dynForc_DGindu(ind_global_north) = update_parameter_rule( dynForc_DGindu(ind_global_north), dynForc_DGindu_2050_n, 1, year_stop_dynForc_allVar-(start_year_strong_policy-1), current_time_im-i_year_strong_policy+1, "linear");
    dynForc_DGindu(ind_global_south) = update_parameter_rule( dynForc_DGindu(ind_global_south), dynForc_DGindu_2050_s, 1, year_stop_dynForc_allVar-(start_year_strong_policy-1), current_time_im-i_year_strong_policy+1, "linear");
end
