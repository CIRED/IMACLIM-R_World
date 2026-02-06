// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thibault Briera, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////
//------------------------NEXUS_GAS------------------------//
/////////////////////////////////////////////////////////////



//--------------------------------------------------------------------//
//----------- Gas price setting : link with oil prices  --------------//
//--------------------------------------------------------------------//

// forcing xtax -> 0 for Russia as it messes up everything in armington gas prices
if ind_new_calib_gas 
    if current_time_im>start_decr_xtax
        xtax(ind_cis,indice_gas) = max(0, (decr_xtax-current_time_im)/decr_xtax) * xtaxref(ind_cis,indice_gas);
    end


    if current_time_im>1
        coef_gaz_prev = coef_gaz;
    end

    if ind_gaz_opt==1  // gas prices are indexed on oil prices until a threshold limit_gasPriceIndexation in $/barrel
        if wp(indice_oil)/tep2oilbarrels < limit_gasPriceIndexation
            coef_gaz=1 + elast_gas2oil_price*((wp(indice_oil)* (1-inertia_wp_oilForGas) + wp_oil_prev*inertia_wp_oilForGas)/wpref(indice_oil)-1);
        else
            taux_gaz_temp=interpln([[-1 0 1];[-slope_gas_1 0 slope_gas_2]],sum(Q(:,indice_gas))/sum(Q_prev(:,indice_gas))-1-point_equilibre_gaz);
            // limit in order not to go under a threshold price
            if ~isdef('taux_gaz_prix_prev')
                taux_gaz_prix_prev = taux_gaz_prix;
            end
            coef_gaz=taux_gaz_prix_prev*(1+taux_gaz_temp);
        end
    else // gas price is indexed on the oil price
        coef_gaz=1+ elast_gas2oil_price *((wp(indice_oil)*(1-inertia_wp_oilForGas) + wp_oil_prev*inertia_wp_oilForGas)/wpref(indice_oil)-1);
    end
    // depletion treatment
    if (sum(Ress_gaz)/sum(Q(:,indice_gas))< RP_ratio_depletion)&deplet_gaz==0   // Com_FL update ress_gaz here ?
        deplet_gaz=1;
    end
    if deplet_gaz==1
        coef_gaz=coef_gaz_prev* inc_price_gaz_depletion;
    end
    taux_gaz_prix = coef_gaz;
else
    if current_time_im< year1_gaz
        taux_gaz_prix=wp_gas_tension(current_time_im)*corr_gaz_1(current_time_im)*corr_gaz_2(current_time_im)*ones(nb_regions,1);
    end
    
    if current_time_im==year2_gaz
        coef_gaz=taux_gaz_prix(1);
    end
    
    if ind_gaz_opt<>2
        if current_time_im> year3_gaz
            if current_time_im> year4_gaz
                taux_gaz_prix_prev=taux_gaz_prix;
            end
            coef_gaz_prev = coef_gaz;
    
            if ind_gaz_opt==1  // gas price is indexed on the oil price
                if wp(indice_oil)/tep2oilbarrels < limit_gasPriceIndexation
                    coef_gaz=1 + elast_gas2oil_price*((wp(indice_oil)* (1-inertia_wp_oilForGas) + wp_oil_prev*inertia_wp_oilForGas)/wpref(indice_oil)-1);
                else
                    taux_gaz_temp=interpln([[-1 0 1];[-slope_gas_1 0 slope_gas_2]],sum(Q(:,indice_gas))/sum(Q_prev(:,indice_gas))-1-point_equilibre_gaz);
                    // limit not to go under a certain threshold
                    taux_gaz_temp=interpln([[ wpmin_gas_interpln wpref(indice_gas) wpref(indice_gas)*wpgas_minPrice_interpl wpref(indice_gas)*wpmax_gas_inc_interpln];[0 0 1 1]],wp(indice_gas)/p(1,compo))*taux_gaz_temp;
                    if ~isdef('taux_gaz_prix_prev')
                        taux_gaz_prix_prev = taux_gaz_prix;
                    end
                    coef_gaz=taux_gaz_prix_prev*(1+taux_gaz_temp);
                end
            else // gas price is indexed on the oil price
                coef_gaz=1+ elast_gas2oil_price *((wp(indice_oil)*(1-inertia_wp_oilForGas) + wp_oil_prev*inertia_wp_oilForGas)/wpref(indice_oil)-1);
            end
        end
        // depletion
        if (sum(Ress_gaz)/sum(Q(:,indice_gas))< RP_ratio_depletion)&deplet_gaz==0   // Com_FL update ress_gaz here ?
            deplet_gaz=1;
        end
        if deplet_gaz==1
            coef_gaz=coef_gaz_prev* inc_price_gaz_depletion;
        end

        taux_gaz_prix = coef_gaz;
    end
end





//computation of markup base on the expected price - adding inertia
markup(:,indice_gas) = calib_markup_gaz();
markup(:,indice_gas)= (1-inertia_markup_gas) * markup(:,indice_gas) + inertia_markup_gas * markup_prev(:,indice_gas);
markup(:,indice_gas)=max(min(markup(:,indice_gas),markup_prev(:,indice_gas) + max_evol_markup_gas), markup_prev(:,indice_gas) + min_evol_markup_gas);

//COM_TB : what do we do with this?

// Goods requirement for capital formation
// follows rise of markup (to ensure that new capital becomes more expensive as resources get exhausted)
//txmarkup(:,indice_gas) = markup(:,indice_gas) ./ markup_prev(:,indice_gas) - 1;
// for k=1:reg
//   for j=1:sec
// //	  Beta(j,indice_gas,k)=Beta(j,indice_gas,k) * (1+txmarkup(k,indice_gas));
//   end
// end

//--------------------------------------------------------------------//
//------------------ Capital and production  -------------------------//
//--------------------------------------------------------------------//

// new gas reserves
Ress_gaz=max(Ress_gaz-Q(:,indice_gas),0);
// expected production by regions
Q_gaz_anticip=Q(:,indice_gas).*taux_Q_nexus(:,indice_gas);
Q_gaz_anticip_world=sum(Q_gaz_anticip);
// cumulative production
Q_cum_gaz=Q_cum_gaz+Q(:,indice_gas);
// expected worlkd production capacities
K_expected_gaz_world=Q_gaz_anticip_world/obj_charge_gaz;
// New capacities are invested as an increasing function of ressources and charge (logit)
K_expected(:,gaz) = Ress_gaz.^gamma_ress_gaz .* (charge(:,gaz).^gamma_charge_gaz) ..
    ./ sum(Ress_gaz.^gamma_ress_gaz .* (charge(:,gaz).^gamma_charge_gaz))..
.* K_expected_gaz_world;
// inertia
//K_expected(:,indice_gas)=1/4*Cap_prev(:,indice_gas)+3/4*K_expected(:,indice_gas);

Q_cum_gaz_global  = Q_cum_gaz_global + sum(Q(:,indice_gas));
