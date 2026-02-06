// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thomas Le Gallic, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////////////////
/////////////// Nexus labor productivity ////////////////////////////////
/////////////////////////////////////////////////////////////////////////

if current_time_im ==1
    sg_add(["l_exo"]);
    l_exo = l; // initialise l_exogenous
end

// LDS exogeneous growth 
if indice_TC_l_exo ~= 0
    TC_l         = TC_l_exo(:,current_time_im);
    TC_l_temp    = TC_l;
    l            = l.*(1-TC_l_temp*ones(1,sec));
    ///coefficients of the wage curve
    aw           = aw./(1-TC_l_temp);
    bw           = bw./(1-TC_l_temp);
    coef_wz_TC_l = TC_l_temp;
else
    //Convergence formula: labor productivity growth rate faster if further from the leader
    //We compute the convergence on labor productivity in the industry sector
    //Note that in the model labor productivity growth is uniform accross sectors in a given region
    // TC_l as a function of exogenous labour productivity: climate change impacts on labour pty do not affect the TC_l's trajectory
    if current_time_im < start_year_policy-base_year_simulation+1 // Before start_year_policy, we keep labor productivity growth as in SSP2. 
        for j=1:reg // DESAG_INDUSTRY: In the multi industrial sectors version, we use the equipment sector as a reference (it is supposed to be the last, so we use '$', for the code to be compatible with a version with one aggregated industrial sector). 
            TC_l(j)=exp(-current_time_im/tau_l_1_ssp2(j))*TC_l_ref_ssp2(j)+(1-exp(-current_time_im/tau_l_1_ssp2(j)))/tau_l_2_ssp2(j)*(l(j,indice_industries($))/pref(j,indice_industries($))-min(l(:,indice_industries($))./pref(:,indice_industries($))))+(1-exp(-(current_time_im+1)/tau_l_1_ssp2(j)))*TC_l_max_ssp2(current_time_im);
        end
        TC_l(ind_usa)=TC_l_max_ssp2(current_time_im); //USA are labour productivity growth leaders
    else
        for j=1:reg // DESAG_INDUSTRY: In the multi industrial sectors version, we use the equipment sector as a reference (it is supposed to be the last, so we use '$', for the code to be compatible with a version with one aggregated industrial sector). 
            TC_l(j)=exp(-current_time_im/tau_l_1(j))*TC_l_ref(j)+(1-exp(-current_time_im/tau_l_1(j)))/tau_l_2(j)*(l(j,indice_industries($))/pref(j,indice_industries($))-min(l(:,indice_industries($))./pref(:,indice_industries($))))+(1-exp(-(current_time_im+1)/tau_l_1(j)))*TC_l_max(current_time_im);
        end
        TC_l(ind_usa)=TC_l_max(current_time_im); //USA are labour productivity growth leaders
    end    
    if current_time_im==1 then sg_add(["TC_l"]); end

    if indice_TC_l_endo==0
        TC_l_temp    = TC_l;
        l_exo = l_exo.*(1-TC_l_temp*ones(1,sec)); // evolution of exogenous labour pty (not affected by climate change impacts)
        l = l_exo./(1-PtyLoss); // evolution of endogenous labour pty (affected by climate change-related pty losses)
        ///coefficients of the wage curve
        aw           = aw./(1-TC_l_temp);
        bw           = bw./(1-TC_l_temp);
        coef_wz_TC_l = TC_l_temp;
    end

    if indice_TC_l_endo==1
        if current_time_im>1
            cum_Cap_sect=cum_Cap_sect+matrix(DeltaK,reg*sec,1);
            cum_Inv_sect=cum_Inv_sect+matrix(Inv_val_sec,reg*sec,1);

            for j=1:sec
                for k=1:reg
                    if cum_Cap_sect((j-1)*reg+k,1)<cum_Cap_sect_REF((j-1)*reg+k,$-2)
                        l_ITC_temp(k,j)=interpln([cum_Cap_sect_REF((j-1)*reg+k,2:$-2);l_sav_REF((j-1)*reg+k,4:$)],cum_Cap_sect((j-1)*reg+k,1));
                    else
                        l_ITC_temp(k,j)=l(k,j)*(1-TC_l(k,$));
                    end
                end
            end

            TC_l_temp=ones(reg,sec)-l_ITC_temp./l_prev;
        end


        l=l.*(ones(reg,sec)-TC_l_temp);
        if ind_NLU_l == 1
            l(:,agri) = l(:,agri)./(1-TC_l_temp);
            l_agriFoodProcess= l_agriFoodProcess .*(1-TC_l_temp);
        end
        ///coefficients of the wage curve
        coef_wz_TC_l=ones(reg,1)-sum(l.*Q,'c')./sum(l_prev.*Q,'c');
        aw=aw./(1-coef_wz_TC_l);
        bw=bw./(1-coef_wz_TC_l);
    end
end
