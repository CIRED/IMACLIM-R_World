// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


output_full_gdp_traj = %f;

GDP_obj_traj = csvRead(path_growthdrivers_Ltot + "GDP_ssp_IMACLIM_region_OECD_ENV-Growth_2023_SSP"+string(ind_ssp) + ".csv",'|',[],[],[],'/\/\//')
GDP_obj_traj_years = GDP_obj_traj(1,:);
GDP_obj_traj = GDP_obj_traj(2:2+reg,:);

// Objective short-term, middle-term and long-term growt rates
growthrate_obj_ST = compute_growth_rate_ssp( GDP_obj_traj, GDP_obj_traj_years, 2020, 2040);
growthrate_obj_MT = compute_growth_rate_ssp( GDP_obj_traj, GDP_obj_traj_years, 2040, 2060);
growthrate_obj_LT = compute_growth_rate_ssp( GDP_obj_traj, GDP_obj_traj_years, 2060, 2080);

GDP_obj_ssp2 = [50012600;5574020;53172460;16104595;22802698;72931300;90238200;18375100;35157299;141228100.2;97740280.96;35095152.01];
GDP_obj_ssp3 = [39307700;3431680;32067055.1;8971795;13318738.8;45286200;49067000;10617200;26539309;59665357.89;50471600.33;18945241.56];
GDP_obj = GDP_obj_ssp3;

cor_struct_change=ones(reg,1);
// first run
if ~isfile(path_autocal_SSP + "TCLmax_firstyear_leader_ssp"+string(ind_ssp)+".csv")
    j_reg=1;
    [ yres,v,info]=fsolve( 0.02, ssp_labor_prod_calibration); // fsolve on ssp_labor_prod_calibration works by regon, defining j_reg 
    if info==1
        TClmax_firstyear_leader = yres;
        csvWrite(TClmax_firstyear_leader, path_autocal_SSP + "TCLmax_firstyear_leader_ssp"+string(ind_ssp)+".csv","|")
    else
        error("fsolve on ssp_labor_prod_calibration failed")
    end
else
    // Compute the error (structural change growth) based on the first run
    if isfile(path_autocal_SSP + "res_all_reg_ssp"+string(ind_ssp)+".csv")
        res_all_reg = csvRead(path_autocal_SSP + "res_all_reg_ssp"+string(ind_ssp)+".csv",'|',[],[],[],'/\/\//')
        TC_l_ref = res_all_reg(:,1);
        tau_l_1 = res_all_reg(:,2);
        tau_l_2 = res_all_reg(:,3);
    end

    GDP_projected = compute_natural_growth( TC_l_max, TC_l_ref, lref(:,indus), pref, tau_l_1, tau_l_2, cor_struct_change)
    for i=1:1
        if i==1;     load('../outputs/001_base.ssp3.corLead100_2025_06_30_09h25min29s/save/GDP_PPP_constant_sav.sav');end;
            //if i==2;     load('../outputs/001_base.ssp3.corLead100_2025_06_30_12h02min59s/save/GDP_PPP_constant_sav.sav');end;
            //if i==3;     load('../outputs/001_base.ssp3.corLead100_2025_06_30_16h53min01s/save/GDP_PPP_constant_sav.sav');end;
            //if i==4;     load('../outputs/001_base.ssp3.corLead100_2025_06_30_17h39min36s/save/GDP_PPP_constant_sav.sav');end;

        GDP_projected = compute_natural_growth( TC_l_max, TC_l_ref, lref(:,indus), pref, tau_l_1, tau_l_2, cor_struct_change);
        GDP_obtained = GDP_PPP_constant_sav(:,$);
        cor_struct_change_new = GDP_obtained ./ GDP_obj_ssp3;
        cor_struct_change = cor_struct_change .* cor_struct_change_new;
    end

    // find the right TCl_ref for the US
    j_reg=1;
    [ yres,v,info]=fsolve( 0.02, ssp_labor_prod_calibration); // fsolve on ssp_labor_prod_calibration works by regon, defining j_reg 
    if info==1
        TClmax_firstyear_leader = yres;
    else
        error("fsolve on ssp_labor_prod_calibration failed")
    end
    disp([j_reg, yres, info]);
    csvWrite(TClmax_firstyear_leader, path_autocal_SSP + "TCLmax_firstyear_leader_ssp"+string(ind_ssp)+".csv","|")
    TC_l_max = linspace(TClmax_firstyear_leader, TClmax_firstyear_leader-0.01, TimeHorizon+1);
    TC_l_ref(ind_usa)=TC_l_max(1);
    TC_l_ref;TC_l_ref(ind_usa,1)=TC_l_max(1)*1;

    // For a given value of tau_l_1 and tau_l_2, find the right TC_l_ref for non-us regions
    // compare to the objective growth rates
    is_made_cor = zeros(reg,1);
    res_all_reg = [TC_l_ref(j_reg), tau_l_1(j_reg), tau_l_2(j_reg)];
    for j_reg =2:12
        mat_res = [];
        mat_res = [mat_res; [TC_l_ref(j_reg), tau_l_1(j_reg), tau_l_2(j_reg), 1e6, 1e6, 1e6]];

        for tau1 = linspace(30,210,(210-30)/20+1)
            tau_l_1; tau_l_1(j_reg,1) = tau1;
            for tau2 = linspace(250,3000,(3000-250)/250+1)
                tau_l_2;tau_l_2(j_reg,1) = tau2;

                [ yres,v,info]=fsolve( 0.0001, ssp_labor_prod_calibration);
                disp( [j_reg, tau1, tau2, yres, info]);
                if info==1 & yres > -0.02
                    //new_tau_l_2(j_reg) = yres;
                    TC_l_ref;TC_l_ref(j_reg) = yres;
                    is_made_cor(j_reg) = 1;
		
                    output_full_gdp_traj = %t;
                    GDP_projected = compute_natural_growth( TC_l_max, TC_l_ref, lref(:,indus), pref, tau_l_1, tau_l_2, cor_struct_change);
                    output_full_gdp_traj = %f;
                    growth_rate_p_ST = (GDP_projected(j_reg,7+20) ./ GDP_projected(j_reg,7)) .^ (1/20); 
                    growth_rate_p_MT = (GDP_projected(j_reg,7+40) ./ GDP_projected(j_reg,7+20)) .^ (1/20); 
                    growth_rate_p_LT = (GDP_projected(j_reg,7+60) ./ GDP_projected(j_reg,7+40)) .^ (1/20); 
		    
                    mat_res = [mat_res; [TC_l_ref(j_reg), tau_l_1(j_reg), tau_l_2(j_reg), growthrate_obj_ST(j_reg) ./ growth_rate_p_ST, growthrate_obj_MT(j_reg) ./ growth_rate_p_MT, growthrate_obj_LT(j_reg) ./ growth_rate_p_LT]] ; 

                end
            end
        end
        // analysis of mat_res
        mat_res = [mat_res, abs(mat_res(:,4)-1) + abs(mat_res(:,5)-1) + abs(mat_res(:,6)-1)];
        ind_min = find(mat_res(:,$)==min(mat_res(:,$)));
        res_all_reg = [ res_all_reg; mat_res(ind_min,[1, 2, 3])];

    end
    csvWrite(res_all_reg, path_autocal_SSP + "res_all_reg_ssp"+string(ind_ssp)+".csv","|")

    is_made_cor = ones(reg,1);
    // Save the structural change error term - usefull for a full auto-calibration, not implemented yet
    if isfile(path_autocal_SSP + "cor_struct_change_ssp"+string(ind_ssp)+".csv")
        cor_struct_change_old = csvRead(path_autocal_SSP + "cor_struct_change_ssp"+string(ind_ssp)+".csv",'|',[],[],[],'/\/\//');
        cor_struct_change = (cor_struct_change .* cor_struct_change_old) .* is_made_cor + (1-is_made_cor).* cor_struct_change_old;
    else
        cor_struct_change = cor_struct_change .* is_made_cor + (1-is_made_cor);
    end
    csvWrite( cor_struct_change, path_autocal_SSP + "cor_struct_change_ssp"+string(ind_ssp)+".csv"),"|";

end
