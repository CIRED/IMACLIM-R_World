/////////////////////////////////////////////////////////////
//------------------------NEXUS_COAL-----------------------//
/////////////////////////////////////////////////////////////


if ind_new_calib_coal

    if current_time_im==1
        taux_coal_temp =0;
    else
        taux_coal_temp=interpln([[-1 0 1];[-pente_coal_1 0 pente_coal_2]],sum(Q(:,indice_coal))/sum(Q_prev(:,indice_coal))-1-point_equilibre_coal);
    end
    taux_coal_prix_prev=taux_coal_prix;
    taux_coal_prix=taux_coal_prix_prev*(1+taux_coal_temp);//;1.005*taux_coal_prix_prev
else
    t_wp_coal_poles = 9;
    if current_time_im < t_wp_coal_poles //modifié pour AMPERE
        taux_coal_prix=wp_coal_default(current_time_im)*corr_coal_default_1(current_time_im)*corr_coal_default_2(current_time_im)*ones(reg,1);
    else
        //plot(-0.01:0.005:0.06,interpln([[0 cff_col_price_1 2*cff_col_price_1];[-cff_col_price_1*cff_col_price_2 0 (2*cff_col_price_1-cff_col_price_1)*cff_col_price_3]],-0.01:0.005:0.06))
        //plot(-0.01:0.005:0.06,interpln([[-10 0 cff_col_price_1 2*cff_col_price_1];[-cff_col_price_1*cff_col_price_2 -cff_col_price_1*cff_col_price_2 0 (2*cff_col_price_1-cff_col_price_1)*cff_col_price_3]],-0.01:0.005:0.06))
        //taux_coal_temp=interpln([[-10 0 cff_col_price_1 2*cff_col_price_1];[-cff_col_price_1*cff_col_price_2 -cff_col_price_1*cff_col_price_2 0 (2*cff_col_price_1-cff_col_price_1)*cff_col_price_3]],sum(Q(:,indice_coal))/sum(Q_prev(:,indice_coal))-1);
        taux_coal_temp=interpln([[-1 0 1];[-pente_coal_1 0 pente_coal_2]],sum(Q(:,indice_coal))/sum(Q_prev(:,indice_coal))-1-point_equilibre_coal);
        //limite pour ne pas passer en dessous d'un prix plancher
        taux_coal_temp=interpln([[ wpmin_coal_interpln wpref(indice_coal) wpref(indice_coal)*wpcoal_minPrice_interpl wpref(indice_coal) * wpmax_coal_inc_interpln];[0 0 1 1]],wp(indice_coal)/p(1,compo))*taux_coal_temp;
        taux_coal_prix_prev=taux_coal_prix;
        taux_coal_prix=taux_coal_prix_prev*(1+taux_coal_temp);//;1.005*taux_coal_prix_prev

        //taux_coal_prix=((wp(indice_coal)/p(1,7))/wpref(indice_coal))*(1+taux_coal_temp)*ones(reg,1);
        //inertie sur la variation de taux_coal_prix
        // if current_time_im>9
        //taux_coal_prix=taux_coal_prix*2/3+taux_coal_prix_prev*1/3;
        //end

        //taux_coal_prix=(coa_cff*(sum(Q(:,1))/sum(Q_prev(:,1))-1)+1)/(wpref(1)/(wp(1)/p(1,7)));
    end

end



//calcul exact du markup en utilisant un fsolve pour le coal
ii=0;
info=4;
while (ii < 100 & info ==4)
    [markup(:,indice_coal),v,info]=fsolve(markup(:,indice_coal),calib_markup_coal);
    ii = ii+1;
end
if info~=1
    error("[markup(:,indice_coal),v,info]=fsolve(markup(:,indice_coal),calib_markup_coal);");
end
markup(:,coal) = (1-inertia_markup_coal) * markup(:,coal) + inertia_markup_coal * markup_prev(:,coal);
markup(:,indice_coal)=max(min(markup(:,indice_coal),markup_prev(:,indice_coal)+ max_evol_markup_coal),markup_prev(:,indice_coal) + min_evol_markup_coal);

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

Ress_coal=max(Ress_coal-Q(:,coal),0);
//on anticipe la production de charbon par région
Q_coal_anticip=Q(:,indice_coal).*taux_Q_nexus(:,indice_coal);
Q_coal_anticip_world=sum(Q_coal_anticip);
//Production cumulée de charbon
Q_cum_coal=Q_cum_coal+Q(:,indice_coal);
//on anticipe les capacités de production necessaires au niveau mondial
K_expected_coal_world=Q_coal_anticip_world/obj_charge_coal;
// New capacities are invested as an increasing function of ressources and charge (logit)
K_expected(:,coal) = Ress_coal.^gamma_ress_coal .* (charge(:,coal).^gamma_charge_coal) ..
./  sum(Ress_coal.^gamma_ress_coal .* (charge(:,coal).^gamma_charge_coal))..
.* K_expected_coal_world;


Q_cum_coal_global  = Q_cum_coal_global + sum(Q(:,indice_coal));

if auto_calibration_coal_prices <>"None"
    // update    
        if current_time_im == 2050 - base_year_simulation 
    // Computing the ratio
            p_coal_end = sum(p(:,indice_coal).*Q(:,indice_coal))/sum(Q(:,indice_coal));
            Q_cum_coal_global_end = Q_cum_coal_global;
            global_cost_end = interpln([supply_curves.coal.global_quant_CACC';supply_curves.coal.global_cost_CACC],Q_cum_coal_global_end);
            p_coal_ratio = p_coal_end/p_coal_ref;
            CACC_coal_ratio = global_cost_end/global_cost_ref_coal;
    
            disp([["p_coal_ratio","CACC_coal_ratio","previous pente_coal_2"];
            p_coal_ratio, CACC_coal_ratio,pente_coal_2]);
    
            csvWrite( pente_coal_2_auto *CACC_coal_ratio/p_coal_ratio , path_autocalibration+'/pente_coal_2_auto.csv')
end
end
