// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Augustin Danneaux, Thibault Briera, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////
//------------------------NEXUS_COAL-----------------------//
/////////////////////////////////////////////////////////////

// This nexus determines the distribution of production capacity in the world, and therefore the demand for capital in the coal sector. 

// As a baseline, this demand is a function of production costs in the different regions, which are determined in particular by cost and resource curves.
// In this nexus, we also introduce resource policy variants: an energy sovereignty variant and a "ban" variant, inspired by van Asselt et al, 2024. 
// The "sovereignty" variant may be retained as the baseline in the long run, as these are currently being implemented in certain regions of the world (e.g. India), and they are better able to reproduce short-term trajectories and short-medium-term projections.

// 
select ind_coalpolicies
case 0 // Current baseline
    ind_coal_fin = 2; // This index should be removed when the coal nexus will be fully updated
    coalsovereignty_policies = 0;
    coalban_policies = 0;
case  1 // Introduction of a coal sovereignty policy variant; this one means that CIS, India, China and RAS cover around 80% of their consumption. 
    // Note that we should probably envisage one "baseline" variant (currents sovereignty policies), and at least another one
    ind_coal_fin = 3;
    coalsovereignty_policies = 1;
    coalban_policies = 0;
case 2 // Introduction of a coal ban policy; this variant is currently being implemented by halting the addition of capital for several years in certain regions. Here we have explored a short-term ban in the USA and Europe, and a medium-term ban in China in particular. If necessary, we could also introduce a consumption ban.
    coalsovereignty_policies = 0;
    coalban_policies = 1;
    ind_coal_fin = 3;
case 3 // In this case, both the coal ban and coal sovereignty policies are implemented.
    coalsovereignty_policies = 1;
    coalban_policies = 1;
    ind_coal_fin = 3;
end

// To be commented
if ind_new_calib_coal

    if current_time_im==1
        taux_coal_temp =0;
    else
        taux_coal_temp=interpln([[-1 0 1];[-slope_coal_1 0 slope_coal_2]],sum(Q(:,indice_coal))/sum(Q_prev(:,indice_coal))-1-point_equilibre_coal);
    end
    taux_coal_prix_prev=taux_coal_prix;
    taux_coal_prix=taux_coal_prix_prev*(1+taux_coal_temp);//;1.005*taux_coal_prix_prev
end

// computation of the expected markup
if ind_coal_ress == 2 // The aim of this switch is to use the Coal extraction cost curve from the RoSE project, which can be adjusted by SSP.
    Ress_CAC_coal = compute_cumulative_curve(Ress_CAC_coal, Q(:,coal));
    Ress_CAC_coal = compute_costs_current(Ress_CAC_coal, Q(:,coal));

    markup(:,indice_coal) = markupref(:,indice_coal) ./ Ress_CAC_coal.costs_ref' .* Ress_CAC_coal.costs_current';
    if current_time_im <=8
        markup(:,coal) = markup_prev(:,coal);
    else
        markup(:,coal) = (1-inertia_markup_coal) * markup(:,coal) + inertia_markup_coal * markup_prev(:,coal);
    end
    markup(:,indice_coal)=max(min(markup(:,indice_coal),markup_prev(:,indice_coal)+ max_evol_markup_coal),markup_prev(:,indice_coal) + min_evol_markup_coal);
    markup(:,indice_coal) = min( markup(:,indice_coal), 0.99);
end

//COM_TB : what do we do with this?

// Goods requirement for capital formation
// follows rise of markup (to ensure that new capital becomes more expensive as resources get exhausted)
//txmarkup(:,indice_coal) = markup(:,indice_coal) ./ markup_prev(:,indice_coal) - 1;
// for k=1:reg
//   for j=1:sec
// //	  Beta(j,indice_coal,k)=Beta(j,indice_coal,k) * (1+txmarkup(k,indice_coal));
//   end
// end


//--------------------------------------------------------------------//
//------------------ Capital and production  -------------------------//
//--------------------------------------------------------------------//

if ind_coal_ress == 2
    Ress_coal = sum(Ress_CAC_coal.quant,'c');
else
    Ress_coal = max(Ress_coal-Q(:,coal),0);
end

// Coal production is forecast by region
Q_coal_anticip=Q(:,indice_coal).*taux_Q_nexus(:,indice_coal);
Q_coal_anticip_world=sum(Q_coal_anticip);
// Cumlated coal production
Q_cum_coal=Q_cum_coal+Q(:,indice_coal);
// We anticipate the production capacity needed worldwide
K_expected_coal_world=Q_coal_anticip_world/obj_charge_coal;

// Initialisation of these parameters, which should become useless (used to bypass the previous logit which should be permanently removed)
sh_corr_K_coal= ones(nb_regions,1);
corr_K_expected = zeros(nb_regions, 1);

// Initialisation of this vector, used to implement the coal ban variant
ind_coalprod_region2 = [ind_usa:ind_ral];
ind_coalprod_region = [ind_usa:ind_ral];


select ind_coal_fin // This index should disappear in my opinion, and we could keep only the case 3
case 1 // This case was temporarily used to forecast the expected capital from the anticipated production in India only
    
    // Fix is not applied in early years
    if current_time_im < 2016 - base_year_simulation
        ratio_prod_coal_ind = 1;
    else
        ratio_prod_coal_ind = Q(ind_ind,indice_coal)/energy_balance(tpes_eb,coal_eb,ind_ind);
    end

   
    // sh_corr_K_coal determines the share of each regime (national vs international) in determining K_expected in India
    // If sh_corr_K_coal=1 production goals are met and India invest as any other region
    // If sh_corr_K_coal=0 production is far from goal and investment is fully determined at the national level 
    sh_corr_K_coal(ind_ind) = 1/(1+exp(-a_k_coal*(ratio_prod_coal_ind-b_k_coal)));

    corr_K_expected(ind_ind)=(1-sh_corr_K_coal(ind_ind))*Q_coal_anticip(ind_ind)/obj_charge_coal;
    
    // Removing nationally determined share of expected Indian production and attributing international capital accordingly 
    Q_coal_anticip_world    = sum(Q_coal_anticip)-sum((1-sh_corr_K_coal).*Q_coal_anticip);
    K_expected_coal_world   = Q_coal_anticip_world/obj_charge_coal;

case 2 // This case was temporarily used to forecast the expected capital from the anticipated production in all regions (this is also the case in case 3)
    if current_time_im> 2020 - base_year_simulation

        if ~isdef("exo_corr_coal")
            exo_corr_coal=0; //By default when ind_coal_fin is 0, the logit is fully bypassed
        end
        exo_corr_coal = 1-(base_year_simulation + current_time_im - 2018) / (2025-2018);
        exo_corr_coal = min(max( exo_corr_coal, 0), 1);
	
        sh_corr_K_coal = exo_corr_coal*ones(nb_regions,1);
        corr_K_expected =(1-sh_corr_K_coal).*Q_coal_anticip./obj_charge_coal;    
    end
    // Removing nationally determined share of expected Indian production and attributing international capital accordingly 
    Q_coal_anticip_world    = sum(Q_coal_anticip)-sum((1-sh_corr_K_coal).*Q_coal_anticip);
    K_expected_coal_world   = Q_coal_anticip_world/obj_charge_coal;

    // Estimating an expected demand for coal by region
    if current_time_im == 0
        DF_expected = DF;
        DG_expected = DG; // = 0;
        DI_expected = DI; // = 0;
        Dcoal_CI_expected = sum(squeeze(CI(coal,:,:))' .* Q,'c');
    else
        ind_nonnuls = find(DF_prev(:, coal) ~= 0)    ;
        DF_expected(ind_nonnuls,coal) = DF(ind_nonnuls, coal) .* (DF(ind_nonnuls, coal) ./ DF_prev(ind_nonnuls, coal)) ; 
        //  DG_expected(:,coal) = DG(:, coal) .* (DG(:, coal) ./ DG_prev(:, coal)) ; // = 0;
        //  DI_expected(:,coal) = DI(:, coal) .* (DI(:, coal) ./ DI_prev(:, coal)) ; // = 0;
        Dcoal_CI_expected = sum(squeeze(CI(coal,:,:))' .* max(Q.*(taux_Q_nexus), 0 ),'c') ;
    end
    //Dagg_expected(:,coal) = DF_expected(:,coal) + DG_expected(:,coal) + DI_expected(:,coal) + Dcoal_CI_expected ;
    Dagg_expected(:,coal) = DF_expected(:,coal) + Dcoal_CI_expected ;
    Dagg_coal_world     = sum (Dagg_expected(:,coal));

case 3 // New way to write the case when we estimate the expected capital from the anticipated production, and introducing the coal policies

    // Estimating the expected demand for coal by region. Note: This is currently only used as an output indicator to monitor the implementation of sovereignty policies. 
    if current_time_im == 0
        DF_expected = DF;
        DG_expected = DG; // = 0;
        DI_expected = DI; // = 0;
        Dcoal_CI_expected = sum(squeeze(CI(coal,:,:))' .* Q,'c');
    else
        ind_nonnuls = find(DF_prev(:, coal) ~= 0)    ;
        DF_expected(ind_nonnuls,coal) = DF(ind_nonnuls, coal) .* (DF(ind_nonnuls, coal) ./ DF_prev(ind_nonnuls, coal)) ; 
        //  DG_expected(:,coal) = DG(:, coal) .* (DG(:, coal) ./ DG_prev(:, coal)) ; // = 0 in the current version, so commented;
        //  DI_expected(:,coal) = DI(:, coal) .* (DI(:, coal) ./ DI_prev(:, coal)) ; // = 0 in the current version, so commented;
        Dcoal_CI_expected = sum(squeeze(CI(coal,:,:))' .* max(Q.*(taux_Q_nexus), 0 ),'c') ;
    end
    //Dagg_expected(:,coal) = DF_expected(:,coal) + DG_expected(:,coal) + DI_expected(:,coal) + Dcoal_CI_expected ;
    Dagg_expected(:,coal) = DF_expected(:,coal) + Dcoal_CI_expected ;
    Dagg_coal_world     = sum (Dagg_expected(:,coal));

    if coalsovereignty_policies == 1 // First variant introducing sovereignty policies
        ind_coalprod_souv = [ind_cis ind_chn ind_ind ind_ras];
        
        if current_time_im == 2016-base_year_simulation
            //partDomDF_min(:,indice_coal) = [1;0;0;0;0.8 ; 1;1;0;0;0;0.8;0]; // Valeurs 1 pour test
            //partDomDF_min(:,indice_coal) = [0;0;0;0;0.8 ; 0.8;0.8;0;0;0;0.8;0]; // Share of domestic demand to be covered by domestic production
            //partDomDF_min = zeros(reg,sec);
            //partDomCI_min = zeros(sec,sec,reg);
            for k = ind_coalprod_souv
                partDomDF_min(k,indice_coal) = 0.8; // Minimal share of domestic demand to be covered by domestic production
                for j = 1:sec
                    if j == 14 | (sec == 12 & j == 12) // ... we have not set the same lower limit for imports for the industrial sector because of the metallurgy sector, which requires coal with a high energy content that is not widely available in certain regions (EDIT, it is currently almost the same).
                        partDomCI_min(indice_coal,j,k) = 0.75;
                    else
                        partDomCI_min(indice_coal,j,k) = 0.8;
                    end
                end
            end
        end

    end

    // Here we define the estimates of new reference capital, before constraint policies (but with sovereignty policy).
    K_expected(:,indice_coal) = Q_coal_anticip./obj_charge_coal;

    // Variant with ban constraints / policies (current assumptions are provisional)
    if coalban_policies == 1             
        if current_time_im >= 2025-base_year_simulation
            K_expected([ind_usa ind_can ind_eur])=0; // E.g. Regions where coal production is banned in 2025
            ind_coalprod_region2([ind_usa ind_can ind_eur]) = 0;
            if current_time_im >= 2035-base_year_simulation // E.g. Regions where coal production is banned in 2035
                K_expected([ind_bra ind_ral ind_mde])=0;
                ind_coalprod_region2([ind_bra ind_ral ind_mde]) = 0; // E.g. Regions where coal production is banned in 2050
                if current_time_im >= 2050-base_year_simulation
                    K_expected([ind_chn ind_afr])=0;
                    ind_coalprod_region2([ind_chn ind_afr]) = 0;
                end
            end
        end

        // We create a vector of producing regions
        ind_coalprod_region = ind_coalprod_region2(ind_coalprod_region2 <> 0);
        
        // The missing expected capital is calculated as the sum of the expected capital calculated at the beginning of the nexus minus the expected capital estimated afterwards.
        K_expected_coal_missing = max(0,K_expected_coal_world - sum(K_expected(:,indice_coal)));
        
        // The distribution of this capital is allocated according to the marketshare of the remaining exporters; it is therefore assumed that regions with low export levels would remain exporters even in a world where some regions decide to leave the coal in the ground.
        K_expected(ind_coalprod_region,indice_coal) = K_expected(ind_coalprod_region,indice_coal) + K_expected_coal_missing * (marketshare(ind_coalprod_region,indice_coal)/sum(marketshare(ind_coalprod_region,indice_coal)));

    end

end // end ind_coal_fin, that should be removed



K_expected(:,coal) = K_expected(:,coal)+corr_K_expected; // To be removed if we keep only the case 3

// Cumulated production is computed here
Q_cum_coal_global  = Q_cum_coal_global + sum(Q(:,indice_coal));



if auto_calibration_p_coal <>"None"
    // update    
    if current_time_im == 2050 - base_year_simulation 
        // Computing the ratio
        p_coal_end = sum(p(:,indice_coal).*Q(:,indice_coal))/sum(Q(:,indice_coal));
        Q_cum_coal_global_end = Q_cum_coal_global;
        global_cost_end = interpln([supply_curves.coal.global_quant_CACC';supply_curves.coal.global_cost_CACC],Q_cum_coal_global_end);
        p_coal_ratio = p_coal_end/p_coal_ref;
        CACC_coal_ratio = global_cost_end/global_cost_ref_coal;
    
        disp([["p_coal_ratio","CACC_coal_ratio","previous slope_coal_2"];
        p_coal_ratio, CACC_coal_ratio,slope_coal_2]);
    
        csvWrite( slope_coal_2_auto *CACC_coal_ratio/p_coal_ratio , path_autocal_slopecoal+'/pente_coal_2_auto.csv')
    end
end
