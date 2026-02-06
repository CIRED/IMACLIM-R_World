// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function growth_rate = compute_growth_rate_ssp( GDP_obj_traj, GDP_obj_traj_years, year1, year2)
    ind_year1 = find(GDP_obj_traj_years==year1);
    ind_year2 = find(GDP_obj_traj_years==year2);
    growth_rate = (GDP_obj_traj(:,ind_year2) ./ GDP_obj_traj(:,ind_year1)) .^ (1/(year2-year1));
endfunction

function [GDP_] = compute_natural_growth( TC_l_max, TC_l_ref, l_indus, pref, tau_l_1, tau_l_2, cor_struct_change)
    TC_l_time = zeros(reg,TimeHorizon+1);
    TC_l_time(:,1) = TC_l_ref;
    GDP_time = zeros(reg,TimeHorizon+1);
    GDP_time(:,1) = GDP_PPP_WB
    j=ind_usa;

    for i=1:TimeHorizon
        TC_l_time(j,1+i) = TC_l_max(i); //exp(-i/tau_l_1(j))*TC_l_ref(j)+(1-exp(-(i+1)/tau_l_1(j)))*TC_l_max(i);
        l_indus(j,1+i) = l_indus(j,i) .* (1-TC_l_time(j,1+i));
        natural_growth_rate = 1 ./ (1-TC_l_time(j,1+i)) .* (1+txLact(j,i)) .* (1-0.005); // 0.005 is an approximation of the deppreciation rate
        GDP_time(j,1+i) = GDP_time(j,i) .* natural_growth_rate;
    end
    GDP_time(j,:) = GDP_time(j,:) * cor_struct_change(j); 
     
    for j=ind_can:reg
        for i=1:TimeHorizon
            TC_l_time(j,1+i) = exp(-i/tau_l_1(j))*TC_l_ref(j)+(1-exp(-(i+1)/tau_l_1(j)))*TC_l_max(i);
            TC_l_time(j,1+i) = TC_l_time(j,1+i) + (1-exp(-i/tau_l_1(j)))/tau_l_2(j)*(l_indus(j,i)/pref(j,indice_industries($))-l_indus(ind_usa,i)./pref(ind_usa,indice_industries($)));
            l_indus(j,i+1) = l_indus(j,i) .* (1-TC_l_time(j,1+i));
            natural_growth_rate = 1 ./(1-TC_l_time(j,1+i)) .* (1+txLact(j,i)) .* (1-0.005);
            GDP_time(j,i+1) = GDP_time(j,i) .* natural_growth_rate;
        end
        GDP_time(j,:) = GDP_time(j,:) * cor_struct_change(j); 
    end
    if output_full_gdp_traj
        GDP_ = GDP_time;
    else
        GDP_ = GDP_time(:,$);
    end
endfunction

function f_zeros = ssp_labor_prod_calibration(xloc)
    TC_l_ref = 0.01*ones(reg,1);
    if j_reg <> 1
        TC_l_ref(j_reg,1) = xloc;
    end

    TC_l_time = zeros(reg,TimeHorizon+1);
    TC_l_time(:,1) = TC_l_ref;
    l_indus = zeros(reg,TimeHorizon+1);
    l_indus(:,1) = lref(:,indice_industries($));
    if j_reg == 1
        TC_l_max = linspace(xloc, xloc-0.01, TimeHorizon+1);
    else
        TC_l_max = linspace(TClmax_firstyear_leader, TClmax_firstyear_leader-0.01, TimeHorizon+1);
    end

    GDP_ = compute_natural_growth( TC_l_max, TC_l_ref, l_indus, pref, tau_l_1, tau_l_2, cor_struct_change)
    f_zeros = GDP_(j_reg) - GDP_obj(j_reg);
endfunction 

