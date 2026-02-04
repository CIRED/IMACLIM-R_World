/////////////////////////////////////////////////////////////
//------------------------NEXUS_GAS------------------------//
/////////////////////////////////////////////////////////////



//--------------------------------------------------------------------//
//----------- Gas price setting : link with oil prices  --------------//
//--------------------------------------------------------------------//

// forcing xtax -> 0 for Russia as it messes up everything in armington gas prices
if ind_new_calib_gas //gas et charbon diff
    if current_time_im>start_decr_xtax
    xtax(ind_cis,indice_gaz) = max(0, (decr_xtax-current_time_im)/decr_xtax) * xtaxref(ind_cis,indice_gaz);
    end


    if current_time_im>1
        coef_gaz_prev = coef_gaz;
    end

    if ind_gaz_opt==1  //le gaz est indexé sur le pétrole jusqu'à limit_gasPriceIndexation $/barrel
        if wp(indice_oil)/tep2oilbarrels < limit_gasPriceIndexation
            coef_gaz=1 + elast_gas2oil_price*((wp(indice_oil)* (1-inertia_wp_oilForGas) + wp_oil_prev*inertia_wp_oilForGas)/wpref(indice_oil)-1);
        else
            taux_gaz_temp=interpln([[-1 0 1];[-pente_gaz_1 0 pente_gaz_2]],sum(Q(:,indice_gaz))/sum(Q_prev(:,indice_gaz))-1-point_equilibre_gaz);
                //limite pour ne pas passer en dessous d'un prix plancher
	        if ~isdef('taux_gaz_prix_prev')
			    taux_gaz_prix_prev = taux_gaz_prix;
		    end
            coef_gaz=taux_gaz_prix_prev*(1+taux_gaz_temp);
        end
    else //le gaz est indexé sur le pétrole
        coef_gaz=1+ elast_gas2oil_price *((wp(indice_oil)*(1-inertia_wp_oilForGas) + wp_oil_prev*inertia_wp_oilForGas)/wpref(indice_oil)-1);
    end
            //on traite la déplétion
    if (sum(Ress_gaz)/sum(Q(:,indice_gaz))< RP_ratio_depletion)&deplet_gaz==0   // Com_FL update ress_gaz here ?
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
    
            if ind_gaz_opt==1  //le gaz est indexé sur le pétrole jusqu'à limit_gasPriceIndexation $/barrel
                if wp(indice_oil)/tep2oilbarrels < limit_gasPriceIndexation
                    coef_gaz=1 + elast_gas2oil_price*((wp(indice_oil)* (1-inertia_wp_oilForGas) + wp_oil_prev*inertia_wp_oilForGas)/wpref(indice_oil)-1);
                else
                    taux_gaz_temp=interpln([[-1 0 1];[-pente_gaz_1 0 pente_gaz_2]],sum(Q(:,indice_gaz))/sum(Q_prev(:,indice_gaz))-1-point_equilibre_gaz);
                    //limite pour ne pas passer en dessous d'un prix plancher
                    taux_gaz_temp=interpln([[ wpmin_gas_interpln wpref(indice_gaz) wpref(indice_gaz)*wpgas_minPrice_interpl wpref(indice_gaz)*wpmax_gas_inc_interpln];[0 0 1 1]],wp(indice_gaz)/p(1,compo))*taux_gaz_temp;
            if ~isdef('taux_gaz_prix_prev')
                taux_gaz_prix_prev = taux_gaz_prix;
            end
                    coef_gaz=taux_gaz_prix_prev*(1+taux_gaz_temp);
                end
            else //le gaz est indexé sur le pétrole
                coef_gaz=1+ elast_gas2oil_price *((wp(indice_oil)*(1-inertia_wp_oilForGas) + wp_oil_prev*inertia_wp_oilForGas)/wpref(indice_oil)-1);
            end
        end
                //on traite la déplétion
        if (sum(Ress_gaz)/sum(Q(:,indice_gaz))< RP_ratio_depletion)&deplet_gaz==0   // Com_FL update ress_gaz here ?
            deplet_gaz=1;
        end
        if deplet_gaz==1
            coef_gaz=coef_gaz_prev* inc_price_gaz_depletion;
        end

        taux_gaz_prix = coef_gaz;
    end
end





//calcul exact du markup en utilisant un fsolve pour le gaz
ii=0;
info=4;
while (ii < 100 & info ==4)
    [markup(:,indice_gaz),v,info]=fsolve(markup(:,indice_gaz),calib_markup_gaz);
    ii = ii+1;
end
if info~=1
    error("[markup(:,indice_gaz),v,info]=fsolve(markup(:,indice_gaz),calib_markup_gaz);");
end

markup(:,indice_gaz)= (1-inertia_markup_gas) * markup(:,indice_gaz) + inertia_markup_gas * markup_prev(:,indice_gaz);
markup(:,indice_gaz)=max(min(markup(:,indice_gaz),markup_prev(:,indice_gaz) + max_evol_markup_gas), markup_prev(:,indice_gaz) + min_evol_markup_gas);

//COM_TB : what do we do with this?

// Goods requirement for capital formation
// follows rise of markup (to ensure that new capital becomes more expensive as resources get exhausted)
//txmarkup(:,indice_gaz) = markup(:,indice_gaz) ./ markup_prev(:,indice_gaz) - 1;
// for k=1:reg
//   for j=1:sec
// //	  Beta(j,indice_gaz,k)=Beta(j,indice_gaz,k) * (1+txmarkup(k,indice_gaz));
//   end
// end

//--------------------------------------------------------------------//
//------------------ Capital and production  -------------------------//
//--------------------------------------------------------------------//

//calcul des nouvelles réserves de gaz disponibles
Ress_gaz=max(Ress_gaz-Q(:,indice_gaz),0);
//on anticipe la production de gaz par région
Q_gaz_anticip=Q(:,indice_gaz).*taux_Q_nexus(:,indice_gaz);
Q_gaz_anticip_world=sum(Q_gaz_anticip);
//Production cumulée de gaz
Q_cum_gaz=Q_cum_gaz+Q(:,indice_gaz);
//on anticipe les capacités de production necessaires au niveau mondial
K_expected_gaz_world=Q_gaz_anticip_world/obj_charge_gaz;
// New capacities are invested as an increasing function of ressources and charge (logit)
K_expected(:,gaz) = Ress_gaz.^gamma_ress_gaz .* (charge(:,gaz).^gamma_charge_gaz) ..
./ sum(Ress_gaz.^gamma_ress_gaz .* (charge(:,gaz).^gamma_charge_gaz))..
.* K_expected_gaz_world;
//on met de l'inertie
//K_expected(:,indice_gaz)=1/4*Cap_prev(:,indice_gaz)+3/4*K_expected(:,indice_gaz);
//On coupe les modifs apres 2070 pour ne pas traiter la déplétion
// if current_time_im>70
// 	K_expected(:,indice_gaz)=Cap_prev(:,indice_gaz);
// end


Q_cum_gaz_global  = Q_cum_gaz_global + sum(Q(:,indice_gaz));