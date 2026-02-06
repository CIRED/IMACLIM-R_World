// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//Summary

//1. Markup_wind
//2. Markup_pv
//3. find_weights_ENR
//4 find_net_LCOE_VRE
//5. RLDC_peak
//6. curtailment_share_d
//7. weights_wind_curt
//8. weights_pv_curt
//9. storage_share_peak
//10. WACC convergence
//11. peak coverage constraint
//12. load Cap Hydro data
//13. compute_baseload
//14. compute_inner_band_height
//15. compute_load_bands
//16. test_null_load_bands
//17. test_sum_load_bands
//18. test_area_under_RLDC
//19. compute_load_band_shares
//20. marketShareSystem
//21. converge_IC
//22. find_first_positive_band
//23. compute_representative_MSH
//24. inertia_LCC
//25. jnet_VRE_share



//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

//SIC Markups for wind and solar pv
function [z] = Markup_wind(x,y)
    z = param_SIC*(x+param_SIC_wind*y)
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function [z] = Markup_pv(x,y)
    z = param_SIC*(param_SIC_pv*x+y)
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function LCOE_VRE = compute_LCOE(CINV,int_cost_ann,OM_cost_fixed_nexus,TD_cost_ann,Load_factor_ENR,avg_deg_rate,prof_gross_VRE_kwh,stor_gross_VRE_kwh,OM_cost_var_nexus,Bal_cost,crt_gross_VRE)
    //param
    //CINV (reg x ntechno_elec_total): ann investment cost
    //int_cost_ann (reg x ntechno_elec_total): ann interest cost
    //OM_cost_fixed_nexus (reg x ntechno_elec_total): fixed O&M cost
    //TD_cost_ann (reg x ntechno_elec_total): ann T&D cost
    //Load_factor_ENR (reg x ntechno_elec_total): load factor
    //avg_deg_rate (reg x ntechno_elec_total): average degradation rate
    //prof_gross_VRE_kwh (reg x ntechno_elec_total): gross profile costs
    //stor_gross_VRE_kwh (reg x ntechno_elec_total): gross storage cost
    //OM_cost_var_nexus (reg x ntechno_elec_total): variable O&M cost
    //Bal_cost (reg xntechno_elec_total): balancing cost
    //crt_gross_VRE (reg x ntechno_elec_total): gross curtailment rate
    //return
    //LCOE_VRE (reg x nTechno_VRE): levelized cost of electricity for VRE technologies

    LCOE_VRE=((CINV(:,techno_VRE)+int_cost_ann(:,techno_VRE)+OM_cost_fixed_nexus(:,techno_VRE)+TD_cost_ann(:,techno_VRE))./((Load_factor_ENR(:,techno_VRE_absolute).*(1-avg_deg_rate(:,techno_VRE))*th_to_h+%eps)) + prof_gross_VRE_kwh  + stor_gross_VRE_kwh + OM_cost_var_nexus(:,techno_VRE) + Bal_cost)./(1-crt_gross_VRE); 
endfunction


//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function [y] = find_weights_ENR(xloc) //this function finds the weight share of the modified logit such that when running the nexus at t=1 the optimal share of VRE in 2018 matches the observed value
    weights = [1,xloc(1),xloc(2),xloc(3),xloc(4)];
    sum_weighted_LCC = zeros(1);
		
    for i = 1:nTechno_VRE
        sum_weighted_LCC = sum_weighted_LCC + weights(i+1)*(LCC_ENR(k,i).^(-gamma_FF_ENR));
    end
    sum_weighted_LCC =sum_weighted_LCC+ LCC_FF(k).^(-gamma_FF_ENR);
    for j=1:nTechno_VRE
        Z(k,j) = max((target_prod(k,j) - (1-target_year/(current_time_im+nb_year_expect_futur))*(Load_factor_ENR(k,j)*1000).*Cap_elec_MWref(k,indice_WND-1+j)./(Qref(k,indice_elec)*(mtoe2mwh)))/(target_year/(current_time_im+nb_year_expect_futur)),(Load_factor_ENR(k,j)*1000).*Cap_elec_MWref(k,indice_WND-1+j)./(Qref(k,indice_elec)*(mtoe2mwh)));
        //year 0 is 2014 and year 10 is 2025, so there are current_time_im+nb_year_expect_futur in between. The target year 2014 correspond to target_year=4
        weights(j+1) = Z(k,j)*(sum_weighted_LCC)/(LCC_ENR(k,j).^(-gamma_FF_ENR));
            
    end
    y = [xloc - weights(2:nbTechFFENR)]
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function [y] = find_weights_VRE_nest(xloc) 
    weights = xloc;
    S_obs =target_prod(k,:);
    sum_weighted_LCC=0;
    //normalizing
    weights(1) = 1;
    for i = 1:nTechno_VRE
        sum_weighted_LCC = sum_weighted_LCC + weights(i)*(LCC_ENR(k,i).^(-gamma_VRE));
    end

    for i = 1:nTechno_VRE
        weights(i) = S_obs(i)*sum_weighted_LCC/(LCC_ENR(k,i).^(-gamma_VRE));
    end
      
    y = [xloc - weights]
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function [y] = find_weights_VRE_FF(xloc) 
    weights = xloc;
    S_obs =[target_prod_FF(k),target_prod_VRE(k)];
    choice_ind = [LCC_FF(k),choice_ind_VRE(k)];
    sum_weighted_LCC=0;
    //normalizing
    weights(1) = 1;
    for i = 1:length(S_obs)
        sum_weighted_LCC = sum_weighted_LCC + weights(i)*(choice_ind(i).^(-gamma_FF_ENR));
    end

    for i = 1:length(S_obs)
        weights(i) = S_obs(i)*sum_weighted_LCC/(choice_ind(i).^(-gamma_FF_ENR));
    end
      
    y = [xloc - weights]
endfunction




//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//Find net VRE LCOE, including curtailment based on curtailment equation

function[y] = find_net_LCOE_VRE(xloc)
    LCOE_net = zeros(reg,length(techno_VRE_absolute));
    LCOE_net(:,techno_VRE_absolute) = xloc(:,1:length(techno_VRE));
    curt_tot_d= xloc(:,length(techno_VRE)+1); //curt_tot_d = the total of curtailed power as a share of total electricity demand
    
    curt_share_PV = zeros(reg,1);
    curt_share_Wind = zeros(reg,1); // curt_share_pv and wind = the curtailed power as a share of net VRE.

    net_share_FF_ENR = zeros(reg,nbTechFFENR);
    Gross_VRE_share = zeros(reg,nTechno_VRE);
    
    
    //Thus for a wind techno (lets say WNO) Gross_VRE_share(WNO) = net_FF_share (WNO) + curt_share_Wind * net_FF_share(WNO). The second term curt_share_Wind * net_FF_share(WNO) give the curtailed power for WNO as a share of total demand
    curt_share_total = zeros(reg,1);
    curt_share_exo = zeros(reg,length(techno_VRE_absolute));

    markup_LCOE_VRE = ones(reg,length(techno_VRE_absolute)); //starting at one is nicer than zero for convergence issues

    //Net VRE shares with current VRE LCOE

    net_share_FF_ENR = modified_logit([LCC_FF, LCOE_net(:,techno_VRE_absolute)],gamma_FF_ENR,weights_ENR);

    //Computing curtailment for different shares (of net VRE gen, of net PV gen, of net Wind gen)

    curt_tot_VRE = curt_tot_d./sum(net_share_FF_ENR(:,technoENRi_vs_FF),"c"); // total curt as a share of VRE gen

    //This is our main hypothesis for curtailment shares on wind and solar PV. We do not posses the information of how much curtailment is due to solar / wind. Curtailment for PV and wind does not happen at the same time, as marginal extra PV gen is more likely to be correlated with existing PV gen. The parameter 3-1 must be calibrated on empiracal data/ expert guess

    weights_wind_curt = weights_wind_curt(net_share_FF_ENR)
    weights_pv_curt = weights_pv_curt(net_share_FF_ENR)

    //Curtailment as a share of PV/Wind net gen. Take the curt as a share of VRE (curt_tot_VRE) then split it between PV and Wind share with the weights. Divide by the shares of PV/Wind gen to get PV/Wind curt as a share of PV/Wind gen.Every time 1kWh is produced, curt_share_pv/wind is curtailed.
    //This will be used to compute net LCOE.
    curt_share_Wind = curt_tot_VRE./(sum(net_share_FF_ENR(:,technoWind_ENR_vs_FF),"c")./sum(net_share_FF_ENR(:,technoENRi_vs_FF),"c")).*weights_wind_curt;
    curt_share_PV = curt_tot_VRE./(sum(net_share_FF_ENR(:,technoPV_ENR_vs_FF),"c")./sum(net_share_FF_ENR(:,technoENRi_vs_FF),"c")).*weights_pv_curt;
    //Multiply it by net_share_FF_ENR(:,technoWind_ENR_vs_FF) or net_share_FF_ENR(:,technoPV_ENR_vs_FF) to get the curtailment for PV/Wind as a share of demand

    //Gross VRE share as share of annual demand
    //equals the net share + the curtailment per techno (as a share of annual demand). Since curt_share is curt as a share of pv/wind gen, we multiply by the share of net pv/wind in the total demand
    Gross_VRE_share(:,technoWind_ENR_vs_FF -1) = net_share_FF_ENR(:,technoWind_ENR_vs_FF) + repmat(curt_share_Wind,1,length(technoWind_ENR_vs_FF)).* (net_share_FF_ENR(:,technoWind_ENR_vs_FF)) ; 
    Gross_VRE_share(:,technoPV_ENR_vs_FF -1) = net_share_FF_ENR(:,technoPV_ENR_vs_FF) + repmat(curt_share_PV,1,length(technoPV_ENR_vs_FF)) .* (net_share_FF_ENR(:,technoPV_ENR_vs_FF)) ;


    //Computing new gross VRE shares
    gross_wind_sh = sum(Gross_VRE_share(:,technoWind_ENR_vs_FF-1 ),"c");
    gross_pv_sh = sum(Gross_VRE_share(:,technoPV_ENR_vs_FF-1 ),"c");

    curt_share_total = curtailment_share_d([gross_wind_sh,gross_pv_sh]); // as a share of total demand

    // Computing storage costs per kWh of VRE: storage needs in kW (peak_W_anticip_tot is in MW)
    stor_total = storage_share_peak([gross_wind_sh,gross_pv_sh]).*peak_W_anticip_tot  * 10 ^3 ;

    // storage in kW per kWh of net VRE (Q_elec_anticip_tot is in MWh)
    stor_kwh = stor_total./(sum(net_share_FF_ENR(:,technoENRi_vs_FF),"c").*Q_elec_anticip_tot * 10 ^3);

    //total cost of storage in $/kWh net VRE generation, using 
    stor_cost_kwh = stor_kwh.* CINV(:,indice_STR);

    //new SIC markup computation, which is in net VRE share

    for j=technoPV_absolute
        markup_LCOE_VRE(:,j) = Markup_pv(sum(net_share_FF_ENR(:,technoPV_ENR_vs_FF),"c"),sum(net_share_FF_ENR(:,technoWind_ENR_vs_FF),"c"));
    end
    
    for j=technoWind_absolute
        markup_LCOE_VRE(:,j) = Markup_wind(sum(net_share_FF_ENR(:,technoPV_ENR_vs_FF),"c"),sum(net_share_FF_ENR(:,technoWind_ENR_vs_FF),"c"));
    end

    curt_share_exo(:,[technoWind_absolute,technoPV_absolute]) = [repmat(curt_share_Wind,1,2),repmat(curt_share_PV,1,2)];
    //Final Net LCOE. We have defined curtailment as a share of net VRE share, such that gross VRE gen = net VRE gen (1+curt). Thus, we must divide the gross load factor by 1/1+curt to have a final net produced kWh of electricity LCOE/
    LCOE_VRE=(CINV(:,techno_VRE)+ int_cost_ann(:,techno_VRE) + OM_cost_fixed_nexus(:,techno_VRE)+TD_cost(:,techno_VRE))./((Load_factor_ENR(:,techno_VRE_absolute)*th_to_h+%eps)./(1+curt_share_exo))+OM_cost_var_nexus(:,techno_VRE) + markup_LCOE_VRE + repmat(stor_cost_kwh,1,nTechno_VRE); 
    
    y = [xloc(:,technoWind_ENR_vs_FF -1) - LCOE_VRE(:,technoWind_absolute), xloc(:,technoPV_ENR_vs_FF-1 ) - LCOE_VRE(:,technoPV_absolute), xloc(:,length(techno_VRE)+1)- curt_share_total];
endfunction

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//Find net VRE LCOE, including curtailment based on curtailment equation

function[y] = find_net_LCOE_VRE2(xloc)
    LCOE_net = zeros(reg,length(techno_VRE_absolute));
    LCOE_net(:,techno_VRE_absolute) = xloc(:,1:length(techno_VRE));
    crt_gross_VRE= xloc(:,(length(techno_VRE)+1):(length(techno_VRE)+2)); //curt_VRE_gross curtailement per kWh of wind/solar
    
    //VRE choice indicator
    [choice_ind_VRE, MSH_VRE] = VRE_choice_indicator(LCOE_net(:,techno_VRE_absolute), gamma_VRE,weights_VRE_nest)

    Gross_VRE_share= zeros(reg,nTechno_VRE);
    //Net VRE shares with current VRE LCOE and new logit structure
    net_share_FF_ENR = compute_1st_n_VRE_nest(choice_ind_VRE,LCC_FF,MSH_VRE, gamma_FF_ENR, weights_VRE_FF);

    //New gross VRE share using old curt values
    Gross_VRE_share(:,technoWind_absolute) = net_share_FF_ENR(:,technoWind_ENR_vs_FF)./repmat(1-crt_gross_VRE(:,1),1,length(technoWind_absolute)); 
    Gross_VRE_share(:,technoPV_absolute) = net_share_FF_ENR(:,technoPV_ENR_vs_FF)./repmat(1-crt_gross_VRE(:,2),1,length(technoPV_absolute)); 

    gross_wind_sh = sum(Gross_VRE_share(:,technoWind_absolute ),"c");
    gross_pv_sh = sum(Gross_VRE_share(:,technoPV_absolute ),"c");

    // Compute new curtailement coefficients
    crt_gross = att_curtailment(gross_wind_sh,gross_pv_sh);
    crt_gross_VRE = [repmat(crt_gross(:,1),1,length(technoWind_absolute)),repmat(crt_gross(:,2),1,length(technoPV_absolute))];

    // Computing storage costs per kWh of VRE: storage needs in kW (peak_W_anticip_tot is in MW)
    stor_gross = att_str(gross_wind_sh,gross_pv_sh,peak_W_anticip_tot,Q_elec_anticip_tot);
    stor_gross_VRE = [repmat(stor_gross(:,1),1,length(technoWind_absolute)),repmat(stor_gross(:,2),1,length(technoPV_absolute))];
    //in $/kWh of gross PV/wind gen
    stor_gross_VRE_kwh = stor_gross_VRE.* repmat(CINV(:,indice_STR),1,nTechno_VRE);

    // profile costs 
    prof_gross = att_profile_costs(gross_wind_sh,gross_pv_sh);
    prof_gross_VRE_kwh = [repmat(prof_gross(:,1),1,length(technoWind_absolute)),repmat(prof_gross(:,2),1,length(technoPV_absolute))]/10^3;

    //Final Net LCOE. We have defined curtailment as a share of net VRE share, such that gross VRE gen = net VRE gen (1+curt). Thus, we must divide the gross load factor by 1/1+curt to have a final net produced kWh of electricity LCOE/
    LCOE_VRE=compute_LCOE(CINV,int_cost_ann,OM_cost_fixed_nexus,TD_cost_ann,Load_factor_ENR,avg_deg_rate,prof_gross_VRE_kwh,stor_gross_VRE_kwh,OM_cost_var_nexus,Bal_cost,crt_gross_VRE=crt_gross_VRE)

    y = [xloc(:,technoWind_absolute) - LCOE_VRE(:,technoWind_absolute), xloc(:,technoPV_absolute) - LCOE_VRE(:,technoPV_absolute), xloc(:,(length(techno_VRE)+1):(length(techno_VRE)+2))- crt_gross];
endfunction


//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// Compute the choice indicador for VRE
function[choice_ind_VRE, MSH_VRE] = VRE_choice_indicator(LCC_VRE, gamma_VRE, weights_VRE)
    //param
    //LCC_VRE (reg x nTechno_VRE): levelized cost of electricity for VRE technologies
    //gamma_VRE (1 x nTechno_VRE): logit parameter for VRE technologies
    //weights_VRE (reg x nTechno_VRE): weights for the logit function
    //return
    //y (reg x nTechno_VRE): VRE choice indicator

    MSH_VRE = modified_logit(LCC_VRE, gamma_VRE, weights_VRE);

    choice_ind_VRE = sum(MSH_VRE.*LCC_VRE,"c");
endfunction

function[share_FF_VRE] = compute_1st_n_VRE_nest(choice_ind_VRE,LCC_FF,MSH_VRE, gamma_FF_ENR, weights_VRE)
    //param
    //LCC_VRE (reg x nTechno_VRE): levelized cost of electricity for VRE technologies
    //gamma_VRE (1 x nTechno_VRE): logit parameter for VRE technologies
    //weights_VRE (reg x nTechno_VRE): weights for the logit function
    //return
    //y (reg x nTechno_VRE): VRE choice indicator
    //seealso find_net_LCOE_VRE2

    MSH_VRE_FF = modified_logit([LCC_FF, choice_ind_VRE],gamma_FF_ENR,weights_VRE);

    MSH_VRE_D = repmat(MSH_VRE_FF(:,2),1,nTechno_VRE).* MSH_VRE;
    share_FF_VRE = [1 - sum(MSH_VRE_D,"c"), MSH_VRE_D ];
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

//RLDC peak load as a share of total peak load. Coefficients derived from ADVANCE data polynomial fit
function[y] = find_RLDC_peak(xloc)
    WD_sh = xloc(:,1);
    Solar_sh = xloc(:,2);
    y = coef_RLDC.coef(:,1) + coef_RLDC.coef(:,2).*WD_sh + coef_RLDC.coef(:,3).*Solar_sh + coef_RLDC.coef(:,4).*WD_sh.*WD_sh + coef_RLDC.coef(:,5) .*Solar_sh.*Solar_sh + coef_RLDC.coef(:,6).*WD_sh.*WD_sh.*WD_sh + coef_RLDC.coef(:,7).*Solar_sh.*Solar_sh.*Solar_sh + coef_RLDC.coef(:,8).*Solar_sh.*WD_sh + coef_RLDC.coef(:,9).*Solar_sh.*WD_sh.*WD_sh + coef_RLDC.coef(:,10).*Solar_sh.*Solar_sh.*WD_sh
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//


//Curtailment as a share of total electricity demand. 
function[y] = curtailment_share_d(xloc)
    WD_sh = xloc(:,1);
    Solar_sh = xloc(:,2);
    y = max(zeros(reg,1),coef_Curt.coef(:,1) + coef_Curt.coef(:,2).*WD_sh + coef_Curt.coef(:,3).*Solar_sh + coef_Curt.coef(:,4).*WD_sh.*WD_sh + coef_Curt.coef(:,5) .*Solar_sh.*Solar_sh + coef_Curt.coef(:,6).*WD_sh.*WD_sh.*WD_sh + coef_Curt.coef(:,7).*Solar_sh.*Solar_sh.*Solar_sh + coef_Curt.coef(:,8).*Solar_sh.*WD_sh + coef_Curt.coef(:,9).*Solar_sh.*WD_sh.*WD_sh + coef_Curt.coef(:,10).*Solar_sh.*Solar_sh.*WD_sh );
    for i=1:reg
        if Solar_sh(i)+WD_sh(i)<0.2
            y(i)=0;// a supplmentary precaution, such that for very small VRE share curtailment is slight positive, this ruins everything
        end
    end
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

//computing curtailment rates per $ of gross solar/wind gen, much more tractable this way
//Distributing curtailment between wind and solar: intersection
function intersect_curt= decompose_curtailment(WD_sh,Solar_sh)
    //param
    //WD_sh (regx1): gross wind share
    //Solar_sh (regx1): gross solar share
    //result
    //intersect_curt (regx1): intersect_curt: curtailment due to intersect of wind and solar, as a share of VRE gen
    intersect_curt = divide((curtailment_share_d([WD_sh,Solar_sh]) - curtailment_share_d([WD_sh,0*ones(reg,1)])- curtailment_share_d([0*ones(reg,1),Solar_sh])),(WD_sh+Solar_sh),0);
endfunction

//Distributing curtailment between wind and solar: cost per kWh of wind/solar
function att_curtailment= att_curtailment(WD_sh,Solar_sh)
    //param
    //WD_sh (regx1): gross wind share
    //Solar_sh (regx1): gross solar share
    //result
    //y (regx1): profile_costs
    //comment:
    //Check that the formula is consistent: att_curtailment(:,1) * WD_sh + att_curtailment(:,2) * Solar_sh = curtailment_share_d([WD_sh,Solar_sh])
    att_curtailment = zeros(reg,2);

    att_curtailment(:,1) = divide(curtailment_share_d([WD_sh,zeros(reg,1)]),WD_sh,0) + decompose_curtailment(WD_sh,Solar_sh)
    att_curtailment(:,2) = divide(curtailment_share_d([zeros(reg,1),Solar_sh]),Solar_sh,0)  + decompose_curtailment(WD_sh,Solar_sh);

    att_curtailment = max(att_curtailment,0);
endfunction


//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

//Compting solar and wind shares of curtailment
// DEPRECIATED FUNCTIONS
function[y]= weights_wind_curt(net_VRE_share)
    y = divide(beta_wd*sum(net_VRE_share(:,technoWind_ENR_vs_FF),"c"),(alpha_pv*sum(net_VRE_share(:,technoPV_ENR_vs_FF),"c")+beta_wd*sum(net_VRE_share(:,technoWind_ENR_vs_FF),"c")),0);
endfunction

function[y] = weights_pv_curt(net_VRE_share)
    y = divide(alpha_pv*sum(net_VRE_share(:,technoPV_ENR_vs_FF),"c"),(alpha_pv*sum(net_VRE_share(:,technoPV_ENR_vs_FF),"c")+beta_wd*sum(net_VRE_share(:,technoWind_ENR_vs_FF),"c")),0);
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

// Storage (in kW) as a share of peak demand 

function[y] = storage_share_peak(xloc)
    WD_sh = xloc(:,1);
    Solar_sh = xloc(:,2);
    y = coef_Stor.coef(:,1) + coef_Stor.coef(:,2).*WD_sh + coef_Stor.coef(:,3).*Solar_sh + coef_Stor.coef(:,4).*WD_sh.*WD_sh + coef_Stor.coef(:,5) .*Solar_sh.*Solar_sh + coef_Stor.coef(:,6).*WD_sh.*WD_sh.*WD_sh + coef_Stor.coef(:,7).*Solar_sh.*Solar_sh.*Solar_sh + coef_Stor.coef(:,8).*Solar_sh.*WD_sh + coef_Stor.coef(:,9).*Solar_sh.*WD_sh.*WD_sh + coef_Stor.coef(:,10).*Solar_sh.*Solar_sh.*WD_sh;

    y  = max(zeros(reg,1),y);
endfunction
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

//for the dispatch-side of the elec nexus: get back the correct curtailment rate that yield a coherent net/gross VRE prod
// What do we know: 1 - gross gen per techno 2 - the total curtailment as a share of demand
// We do miss the net gen per techno, which is given by the logit in the investment module
function[y] = find_net_sh(xloc)
    nbtech = length(techno_VRE);
    //arg 1 = net VRE production
    net_sh_ENRi = xloc;
    //This is known
    gross_sh_ENRi = Gross_VRE_share_i_1;
    
    tot_gross = sum(gross_sh_ENRi,"c");
    tot_net = sum(net_sh_ENRi,"c");

    //First: get back the curt rate as a share of total demand
    curt_tot = curtailment_share_d([sum(gross_sh_ENRi(:,1:length(technoWind)),"c"),sum(gross_sh_ENRi(:,(length(technoWind)+1):$),"c")])

    //Compute the weights
    weights_wind_curt = weights_wind_curt([zeros(reg,1),net_sh_ENRi]);
    weights_pv_curt = weights_pv_curt([zeros(reg,1),net_sh_ENRi]);
    
    //Then the curt rate as a share of pv/wind gen
    curt_share_Wind = divide(curt_tot,sum(net_sh_ENRi(:,1:length(technoWind)),"c"),0).*weights_wind_curt;
    curt_share_PV = divide(curt_tot,sum(net_sh_ENRi(:,(length(technoWind)+1):$),"c"),0).*weights_pv_curt;

    //we do know the gross share of wind and pv gen: so we invert the equation gross = net (1+curt) to compute a new net share
    net_sh_ENRi = divide(gross_sh_ENRi,(1+[repmat(curt_share_Wind,1,length(technoWind)),repmat(curt_share_PV,1,length(technoPV))]),0);

    y = [xloc - net_sh_ENRi]
endfunction
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function [y] = conv_WACC(tech,reg_m,weight_i,weight_e,num_CoC)
    techno = tech; //the (set of) technology(es) concerned by the same level of convergence
    reg_min = reg_m; //the regions on which the minimum CoC is looked for
    weight_init = weight_i; //the weight on initial CoC
    weight_end = weight_e; //the weight on final CoC
    num = num_CoC; //the corresponding col line in the Global_WACC dataframe

    [y] = min(weight_end*repmat(min(Global_WACC(reg_min,num)),reg,length(techno)) +weight_init*disc_rate_elec(:,techno,1),disc_rate_elec(:,techno,1))

endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function [y] =  peak_cov_calibration(xloc,xparam)
    // this function constraints the investment in conventional power capacity depending on the peak load coverage (dispatch). If for the period t the conventionnal installed capacity is covering much more than the peak load then it is not rationnal to invest in additionnal conventionnal capacity (hydro being excluded)
    x=xloc;
    min_x =xparam(1); //1.2 // lower bound for peak coverage => below min_x, the investment goes as usual
    max_x =xparam(2); //1.4 // upper bound for peak coverage => above max_x, only y_low share of the desired investment is made
    min_y =xparam(3); //1; // maximum share of desired investment
    max_y =xparam(4); //0.2; // min share of desired investment when peak load coverage is too important

    a = (max_y-min_y)/(max_x - min_x );
    b = min_y-a*min_x ;
    if x<min_x 
        y = min_y
    else
        if x>max_x 
            y=max_y
        else
            y = a*x +b
        end
    end
    [y]
endfunction
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function y = load_hydro( data_path)
    Cap_hydro=csvRead( data_path);
    Cap_hydro = Cap_hydro(2:$);//removing header text in the CSV file
    nhydroyear = length(Cap_hydro)/reg;

    Cap_hydro_MW = zeros(reg,TimeHorizon+nb_year_expect_futur+1); //+1 because we are gonna remove the year 1 (=2014) after
    for i=1:reg
        bot = 1 + (i-1)*37;
        up = i*37;
        Cap_hydro_MW(i,1:nhydroyear) = Cap_hydro(bot:up)'; //Transforming in 12x37 (for 2050) data
    end
    // and turning it into a TimeHorizon-long dataframe. We assume for now that there is no additionnal hydro after 2050
    for k=(nhydroyear+1):TimeHorizon+nb_year_expect_futur+1
        Cap_hydro_MW(:,k)=Cap_hydro_MW(:,nhydroyear);
    end
    y = Cap_hydro_MW; //use in the investment nexus
endfunction


//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

// Compute the residual baseload based on the RLDC 
//given by the RLDC equations:
//Q = 730*H + (730+ength_inner_load)*H + ... + (730+length_inner_load*n_inner_bands)*H + FLH*baseload
// H = inner_band_height = (peak_W_anticip - baseload) / (n_inner_bands +1)
function baseload = compute_baseload(Q_elec_anticip, peak_W_anticip, n_inner, adjusted_full_load_hours)
    // parameters
    //Q_elec_anticip (1xreg or 1x1): net dispatchable generation 
    //peak_W_anticip (1xreg or 1x1): residual peak load 
    //n_inner (1xreg or 1x1): number of inner load bands. Equals 5 by default but can be adjusted with increasing shares of VRE, see compute_load_bands
    //adjusted_full_load_hours (1xreg or 1x1): adjusted full load hours. Equals 8760 by default but can be adjusted with increasing shares of VRE, see compute_load_bands

    //  return 
    //baseload (1xreg or 1x1): residual baseload
    load_band_factor = (peak_duration + length_inner_load *n_inner /2);
    baseload = (Q_elec_anticip- peak_W_anticip * load_band_factor) ./ (adjusted_full_load_hours - load_band_factor);
    if n_inner <= 0 // handling the case with no inner load bands / only peak load
        baseload = (Q_elec_anticip -peak_duration*peak_W_anticip)/(peak_duration + length_inner_load);
        if baseload < 0
            baseload = peak_W_anticip;
        end
    end
endfunction
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function inner_band_height = compute_inner_band_height(peak_W_anticip, baseload, n_inner)
    // parameters
    //peak_W_anticip (1xreg or 1x1): residual peak load
    //baseload (1xreg or 1x1): residual baseload
    //n_inner (1xreg or 1x1): number of inner load bands. Equals 5 by default but can be adjusted with increasing shares of VRE, see compute_load_bands

    // return
    //inner_band_height (1xreg or 1x1): height of each inner band
    inner_band_height = divide((peak_W_anticip - baseload) , (n_inner +1),0);
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function [n_inner_bands_loop,inner_band_height,baseload,load_bands] = compute_load_bands(Q_elec_anticip, peak_W_anticip)
    // parameters
    //Q_elec_anticip (1xreg): net dispatchable generation 
    //peak_W_anticip (1xreg): residual peak load 

    // return
    //n_inner_bands_loop (1xreg): number of inner load bands. Equals 5 by default but can be adjusted with increasing shares of VRE, see compute_load_bands
    //inner_band_height (1xreg): height of each inner band
    //baseload (1xreg): residual baseload
    //load_bands (struct): load bands

    n_inner_bands_loop = zeros(reg,1);
    inner_band_height= zeros(reg,1);;
    baseload= zeros(reg,1);
    load_bands = struct();

    for k=1:reg
        n_inner_bands_loop(k) = n_inner_bands 
        while n_inner_bands_loop(k) > -1
            adjusted_full_load_hours = time_slices_n_base_flip(n_inner_bands_loop(k)+2)
            baseload(k) = compute_baseload(Q_elec_anticip(k), peak_W_anticip(k), n_inner= n_inner_bands_loop(k), adjusted_full_load_hours);
            if baseload(k) >= 0 then
                break;
            end
            n_inner_bands_loop(k) = n_inner_bands_loop(k) - 1;
            baseload(k) = 0;
        end
        if baseload(k) == peak_W_anticip(k) // case with only peak load
            n_inner_bands_loop(k) = -1;
        end
        n_inner_bands_loop = max(n_inner_bands_loop,-1);
        // computing the height of each inner band
        inner_band_height(k) = compute_inner_band_height(peak_W_anticip(k), baseload(k), n_inner= n_inner_bands_loop(k));

        // storing the load bands
        for i=1:n_load_bands
            band = tranches_elec(i)
            start_baseload = n_inner_bands-n_inner_bands_loop(k) + 1;
            if i < start_baseload
                execstr("load_bands.band_"+band+"(k) = 0;")
            end
            if i == start_baseload
                execstr("load_bands.band_"+band+"(k) = baseload(k);")
            end
            if i > start_baseload
                execstr("load_bands.band_"+band+"(k) = inner_band_height(k);")
            end
        end

    end
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

// function to test that each load band is positive or null
function test_null_load_bands(load_bands)
    for k=1:reg
        for i=1:n_load_bands
            band = tranches_elec(i);
            execstr("loadband = load_bands.band_"+band+"(k);");
            if loadband  < 0
                disp("Warning: load band "+band+" is negative in region "+k);
            end
        end
    end
endfunction
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

// function to test that the sum of the load bands equals the peak load
function test_sum_load_bands(peak_W_anticip, baseload, inner_band_height, n_inner_bands_loop)
    for k =1:reg
        sum_load_bands = baseload(k);
        i=n_inner_bands_loop(k)+1; // including peak load band
        sum_load_bands = sum_load_bands + inner_band_height(k) * i;
        
        if abs(sum_load_bands - peak_W_anticip(k)) > %eps
            disp("Warning: sum of the load bands does not equal the peak load in region "+k);
            disp("Delta is "+(sum_load_bands - peak_W_anticip(k)));
        end
    end
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

// function to test that the area under the RLDC equals the net dispatchable generation
function test_area_under_RLDC(load_bands,Q_elec_anticip)
    for k=1:reg
        area_under_RLDC = 0;
        for i=1:n_load_bands
            band = tranches_elec(i);
            band_num = strtod(band);
            execstr("area_under_RLDC = area_under_RLDC + load_bands.band_"+band+"(k) * "+band_num+"");
        end
        if abs((area_under_RLDC - Q_elec_anticip(k))/Q_elec_anticip(k)) > %eps
            disp("Warning: area under the RLDC does not equal the net dispatchable generation in region "+k);
            disp("Delta is "+(area_under_RLDC - Q_elec_anticip(k))/Q_elec_anticip(k));
        end
    end
endfunction


//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//


function load_band_shares = compute_load_band_shares(Q_elec_anticip, load_bands)
    // parameters
    //Q_elec_anticip (1xreg): net dispatchable generation 

    //return
    //load_band_shares (list of 1xreg vectors, for each load band): shares of each load band as a share of the net dispatchable generation
    load_band_shares = struct();
    for i = 1:n_load_bands
        band = tranches_elec(i);
        bandstr = strtod(band);
        execstr("load_band_value = load_bands.band_"+band+" * "+bandstr+"");
        execstr("load_band_shares.band_"+band+" = load_band_value ./ Q_elec_anticip");
    end
endfunction


//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// system of equation to find intangible costs for dispatchable power plants
function y = marketShareSystem(xloc)
   
    // param 
    // xloc (1xn_type_elec): vector of market shares per region

    //return
    // y (1xn_type_elec): vector of residuals
    S_obs = market_share_elec(k,:)
    
    IC = xloc;
    // Calculate the market shares
    for band  = tranches_elec
        execstr("MSH_"+band+"_IC = modified_logit([LCC_"+band+"_type(k,:) + IC],gamma_FF_type,ones(1,n_type_elec));")
    end
    MSH = zeros(1,n_type_elec);
    for band = tranches_elec
        execstr("MSH = MSH_"+band+"_IC.*load_band_shares.band_"+band +"(k) + MSH ;")
    end

    // System of equations
    y = S_obs - MSH;
endfunction
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// function to make the IC converge (Convergence_horizon shared with VRE share weights)

function IC_converged = converge_IC(IC_elec_base, Convergence_horizon, convergence_type)
    // parameters
    // IC_elec_base (reg x n_type_elec): 1st year (2015) intangible costs
    // Convergence_horizon (1x1): Model's year when convergence is achieved
    // convergence_type (1xn_type_elec): type of convergence for each technology

    // return
    // IC_converged (reg x n_type_elec x Convergence_horizon): trajectory of intangible costs
    IC_converged = zeros(reg, n_type_elec, Convergence_horizon);

    // Initialize base year
    if current_time_im <= Convergence_horizon
        for ll = 1:Convergence_horizon
            for tech = 1:n_type_elec
                select convergence_type(tech)
                case -1
                    target_IC = IC_elec_base(:, tech); // No convergence
                case 0
                    target_IC = 0; // Converge to 0
                else
                    target_IC = IC_elec_base(:, convergence_type(tech)); // Converge to another technology's IC
                end
                // Linear convergence calculation, with min and max to prevent <0 and >1
                IC_converged(:, tech, ll) = IC_elec_base(:, tech) + (target_IC - IC_elec_base(:, tech)) * min(max((ll-1) / (Convergence_horizon-1),0),1);
            end
        end
    end
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//function to identify the first positive load band
function [first_positive_band] = find_first_positive_band(load_band_shares)
    //param load_band_shares: output of compute_load_band_shares function

    //return first_positive_band (1xreg): index of the first positive load band

    first_positive_band = zeros(1,reg);
    for k=1:reg
        i=1
        band=tranches_elec(i)
        execstr("lb=load_band_shares.band_"+band+"(k)")
        while lb<=0
            i=i+1 
            if i>n_load_bands
                break
            end
            band=tranches_elec(i)
            execstr("lb=load_band_shares.band_"+band+"(k)")
        end
        first_positive_band(k) = i;
    end
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

//function to compute the representative load band

function [representative_MSH] = compute_representative_MSH(load_band_shares)
    //param first_positive_band (1:reg): output of find_first_positive_band function

    //return representative_MSH (reg x n_type_elec): representative MSH for each techno family
    representative_MSH = zeros(reg,n_type_elec);
    for band = tranches_elec
        execstr("representative_MSH=MSH_"+band+"_type.*repmat(load_band_shares.band_"+band+",1,n_type_elec) + representative_MSH  ;")
    end

    if sum(abs(sum(representative_MSH,"c")-1)>10^-3)>0
        disp("Warning: representative MSH does not sum to 1 in all regions")
    end
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

//function to add inertia to the LCOE choice indicator

function [y] = inertia_LCC(LCC_FF, LCC_FF_prev, LCC_FF_prev_prev, iner_LCC)
    //param 
    //LCC_FF (reg x 1): choice indicator as computed at time t
    //LCC_FF_prev (reg x 1): choice indicator as computed at time t-1
    //LCC_FF_prev_prev (reg x 1): choice indicator as computed at time t-2
    //iner_LCC (1x1): inertia parameter

    //return
    //y (reg x 1): choice indicator time t with inertia

    if LCC_FF_prev < %eps
        y = LCC_FF;
    else
        if LCC_FF_prev_prev < %eps
            y = LCC_FF * iner_LCC + LCC_FF_prev * (1-iner_LCC);
        else
            y = LCC_FF * iner_LCC + (LCC_FF_prev + LCC_FF_prev_prev) * (1-iner_LCC)/2;
        end
    end


endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//net VRE given from gross solar and wind shares Coefficients derived from ADVANCE data polynomial fit
function net_VRE_share = compute_net_VRE_share(WD_sh,Solar_sh)
    //param
    //WD_sh (regx1): gross wind share
    //Solar_sh (regx1): gross solar share
    //result
    //y (regx1): net VRE share
    
    //for low shares, no curtailment: rather use gross VRE share as proxy for net VRE share, rather than risking to have negative net VRE share, which happens near the compute_net_VRE_share boundaries
    
    if Solar_sh+WD_sh<0.3
        net_VRE_share = Solar_sh + WD_sh;
    else
        net_VRE_share = coef_Net_VRE.coef(:,1) + coef_Net_VRE.coef(:,2).*WD_sh + coef_Net_VRE.coef(:,3).*Solar_sh + coef_Net_VRE.coef(:,4).*WD_sh.*WD_sh + coef_Net_VRE.coef(:,5) .*Solar_sh.*Solar_sh + coef_Net_VRE.coef(:,6).*WD_sh.*WD_sh.*WD_sh + coef_Net_VRE.coef(:,7).*Solar_sh.*Solar_sh.*Solar_sh + coef_Net_VRE.coef(:,8).*Solar_sh.*WD_sh + coef_Net_VRE.coef(:,9).*Solar_sh.*WD_sh.*WD_sh + coef_Net_VRE.coef(:,10).*Solar_sh.*Solar_sh.*WD_sh
    end
endfunction
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//profile costs per $ of gross vRE gen, curve fitting for endogenous estimates.
//Careful :
// 1) in $/MWh (easier for comparability)
// 2) polynom of order 4
function profile_costs= compute_profile_costs(WD_sh,Solar_sh)
    //param
    //WD_sh (regx1): gross wind share
    //Solar_sh (regx1): gross solar share
    //result
    //y (regx1): profile_costs
    profile_costs = coef_profile_costs.coef(:,1) + coef_profile_costs.coef(:,2).*WD_sh + coef_profile_costs.coef(:,3).*Solar_sh + coef_profile_costs.coef(:,4).*WD_sh.*WD_sh + coef_profile_costs.coef(:,5) .*Solar_sh.*Solar_sh + coef_profile_costs.coef(:,6).*WD_sh.*WD_sh.*WD_sh + coef_profile_costs.coef(:,7).*Solar_sh.*Solar_sh.*Solar_sh + coef_profile_costs.coef(:,8).*WD_sh.*WD_sh.*WD_sh.*WD_sh + coef_profile_costs.coef(:,9).*Solar_sh.*Solar_sh.*Solar_sh.*Solar_sh +  coef_profile_costs.coef(:,10).*Solar_sh.*WD_sh + coef_profile_costs.coef(:,11).*Solar_sh.*WD_sh.*WD_sh + coef_profile_costs.coef(:,12).*Solar_sh.*Solar_sh.*WD_sh + coef_profile_costs.coef(:,13).*Solar_sh.*Solar_sh.*Solar_sh.*WD_sh + coef_profile_costs.coef(:,14).*Solar_sh.*WD_sh.*WD_sh.*WD_sh + coef_profile_costs.coef(:,15).*Solar_sh.*Solar_sh.*WD_sh.*WD_sh
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function intersect_pc= decompose_profile_costs(WD_sh,Solar_sh)
    //param
    //WD_sh (regx1): gross wind share
    //Solar_sh (regx1): gross solar share
    //result
    //y (regx1): profile_costs in $/MWh of gross VRE gen
    intersect_pc = compute_profile_costs(WD_sh,Solar_sh) - divide(compute_profile_costs(WD_sh,0*ones(reg,1)).*WD_sh,(WD_sh+Solar_sh),0) - compute_profile_costs(0*ones(reg,1),Solar_sh).*divide(Solar_sh,(WD_sh+Solar_sh),0)
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
function att_profile_costs= att_profile_costs(WD_sh,Solar_sh)
    //param
    //WD_sh (regx1): gross wind share
    //Solar_sh (regx1): gross solar share
    //result
    //y (regx1): profile_costs in $/MWh of PV/Wind gen
    att_profile_costs = zeros(reg,2);

    att_profile_costs(:,1) = compute_profile_costs(WD_sh,zeros(reg,1)) + decompose_profile_costs(WD_sh,Solar_sh);
    att_profile_costs(:,2) = compute_profile_costs(zeros(reg,1),Solar_sh)  + decompose_profile_costs(WD_sh,Solar_sh);
    
    //set a treshold to avoid silly values with very high VRE shares
    att_profile_costs = max(att_profile_costs,-5);
endfunction
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function decompose_str = decompose_str(WD_sh,Solar_sh,peak_W_anticip_tot)
    //param
    //WD_sh (regx1): gross wind share
    //Solar_sh (regx1): gross solar share
    //peak_W_anticip_tot (regx1): total peak load
    //result
    //decompose_str (regx1): storage capacity in kw due to the interaction of solar and wind generation
    decompose_str = (storage_share_peak([WD_sh,Solar_sh]) - storage_share_peak([WD_sh,zeros(reg,1)]) - storage_share_peak([zeros(reg,1),Solar_sh])).*peak_W_anticip_tot  * 10 ^3 ;
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function att_str= att_str(WD_sh,Solar_sh,peak_W_anticip_tot,Q_elec_anticip_tot)
    //param
    //WD_sh (regx1): gross wind share
    //Solar_sh (regx1): gross solar share
    //peak_W_anticip_tot (regx1): total peak load
    //Q_elec_anticip_tot (regx1): total net generation (in MWh) so it needs to be converted in kwh (decompose_str is already in kW)
    //result
    //y (regx1): storage costs per kW of kWh gross solar/win gen 
    att_str = zeros(reg,2);

    att_str(:,1) = storage_share_peak([WD_sh,zeros(reg,1)]).*divide(peak_W_anticip_tot,(WD_sh.*Q_elec_anticip_tot),0) + divide(decompose_str(WD_sh,Solar_sh,peak_W_anticip_tot),((WD_sh+Solar_sh).*Q_elec_anticip_tot* 10^3),0);
    att_str(:,2) = storage_share_peak([zeros(reg,1),Solar_sh]).*divide(peak_W_anticip_tot,(Solar_sh.*Q_elec_anticip_tot),0)  + divide(decompose_str(WD_sh,Solar_sh,peak_W_anticip_tot),((WD_sh+Solar_sh).*Q_elec_anticip_tot* 10^3),0);
endfunction
