// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thomas Le Gallic
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

////////////////////////-----------------------------------------------////////////////
//////////////////////// Evolution of household budget - xsi and xsiT  ////////////////
////////////////////////-----------------------------------------------////////////////

// Evolution xsiT  
if current_time_im >= start_year_strong_policy-base_year_simulation  & current_time_im < 2050 - base_year_simulation
	
    //We increase xsiT in global South in order to reach more plausible demand in car pkm.
    xsiT(ind_chn)=1.004*xsiT(ind_chn);	
    xsiT(ind_ind)=1.000*xsiT(ind_ind);
    xsiT(ind_bra)=1.002*xsiT(ind_bra);
    xsiT(ind_mde)=1.000*xsiT(ind_mde); // or 1.002 ?
    xsiT(ind_afr)=1.010*xsiT(ind_afr);	
    xsiT(ind_ras)=1.006*xsiT(ind_ras);
    xsiT(ind_ral)=1.004*xsiT(ind_ral);
		
    // Variant implemented in Fisch-Romito & Guivarch, 2019 and reused (and adapted) here for task 3.5 NAVIGATE. This variant lower the share of budget dedicated to transport. It has effects on modal share (more non-motorized and public transport, less car) and on total distance travelled per year by households (passenger kilometers, pkm).
    if ind_transportsufficiency == 1 
        xsiTprev = xsiT;
        xsiT(ind_global_north)=0.992*xsiT(ind_global_north);	 // or 0.990 ?	 
    elseif ind_transportsufficiency >= 2
        xsiTprev = xsiT;
        xsiT(ind_global_north)=0.975*xsiT(ind_global_north);	 
    end
end
	
if current_time_im >= start_year_strong_policy-base_year_simulation  & current_time_im >= 2050 - base_year_simulation
    if ind_transportsufficiency == 1 & current_time_im >= 2050 - base_year_simulation // We lower the decrease pace after 2050 and apply it to all regions
        xsiT(ind_global_north)=0.998*xsiT(ind_global_north);
        xsiT(ind_chn)=0.998*xsiT(ind_chn);
        xsiT(ind_bra)=0.998*xsiT(ind_bra);
        xsiT(ind_mde)=0.998*xsiT(ind_mde);
        xsiT(ind_ral)=0.998*xsiT(ind_ral);
    elseif ind_transportsufficiency == 2 & current_time_im >= 2050 - base_year_simulation // We lower the decrease pace after 2050 and apply it to all regions
        xsiTprev = xsiT;
        xsiT(ind_global_north)=0.985*xsiT(ind_global_north);
        xsiT(ind_usa)=0.995*xsiT(ind_usa); 
        xsiT(ind_chn)=0.98*xsiT(ind_chn);
        xsiT(ind_ind)=0.98*xsiT(ind_ind);
        xsiT(ind_bra)=0.98*xsiT(ind_bra);
        xsiT(ind_mde)=0.99*xsiT(ind_mde);
        xsiT(ind_ral)=0.97*xsiT(ind_ral);
    end
end

if current_time_im >= start_year_strong_policy-base_year_simulation
    if ind_transportsufficiency >= 1 // Changes in xsiT are passed to xsi_composite
        for k=1:reg
            xsi(k,indice_composite-nbsecteurenergie)=xsi(k,indice_composite-nbsecteurenergie) + (xsiTprev(k)-xsiT(k));
        end
    else 	// Evolution of xsiT are passed proportionaly to other sectors so that xsiT + sum xsi =1
        for k=1:reg
            xsi(k,:)=xsi(k,:).*(1-xsiT(k))./sum(xsi(k,:));
        end	
    end
end

if ind_sufficiency_indus == 1 & current_time_im >= start_year_strong_policy-base_year_simulation 
    DF_indus_percap=DF(:,indice_industries)./repmat(Ltot_prev,1,nb_sectors_industry);
    for k=1:reg
        if  (DF_indus_percap (k)-hdf_cff_lds(k))/DF_indus_percap(k) > 0.1 & current_time_im <= 2050-base_year_simulation 
            hdf_cff_lds(k) = 0.99 * hdf_cff_lds(k);
        elseif (DF_indus_percap (k)-hdf_cff_lds(k))/DF_indus_percap(k) > 0.1 & current_time_im > 2050-base_year_simulation
            hdf_cff_lds(k) = 0.998 * hdf_cff_lds(k);
        end
    end
end
//////// Update the xsi according the the Rdisp / Ltot variation (in order to avoid the demand for agriculture good to grow fast)
xsi = update_xsi(Rdisp,Ltot_prev,DF,pArmDF,xsi,hdf_cff_lds);
