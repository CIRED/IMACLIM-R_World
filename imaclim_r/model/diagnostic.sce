// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thomas Le-Gallic
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// IPCC AR6 vettings
// from Annex II of the AR6 WG III report, Table II.4, page 71 


//-----------------------------------------------------------------------------------------------
// Various values - IPCC vettings definition
//-----------------------------------------------------------------------------------------------

// Note for NDC/NPI diagnostic
// The CO2 emission trajectory (Emissions|CO2|Energy) from 4 IAM (MESSAGE/REMIND/WITCH/IMAGE) and 2 scenarios ("CurPol" and "NDCPlus") is extracted from the AR6 database.
// It covers 8 regions (USA, OECD except USA, China, India, Rest of Asia, FSU, Latin America, Middle East and Africa)
// After comparing IMACLIM-R - No Policy with the models' range of emissions, only 2 regions needed a carbon tax to match the NDC emission trajectory: USA and OECD except USA
// Hence the 3 markets
// The vettings for USA and OECD are given by the upper bound of the models' range of CO2 emissions in 2020, 2025 and 2030, with a 5% tolerance (x1.05)
// After 2030 the "continuation of efforts" is interpretated as a constant carbon price
// This shall be coded properly after the NAVIGATE deadline

// IPCC vettings definition
if current_time_im==1
    // value are reported first as vectors: [Reference; lower tolerance; upper tolerance], when applicable
    // historical emissions vettings:
    // _IP suffix means the vettings for illustrative pathways

    // CO2 total (EIP + AFOLU) emissions | MtCO2/yr 
    vet_co2_all = [44251, -0.4, +0.4];
    vet_co2_all_IP = [44251, -0.2, +0.2];
    // CO2 EIP emissions | MtCO2/yr 
    vet_co2_EIP = [37646, -0.2, +0.2];
    vet_co2_EIP_IP = [37646, -0.1, +0.1];
    // CH4 emissions | MtCH4/yr 
    vet_ch4 = [379, -0.2, +0.2];
    // CO2 emissions EIP 2010-2020 % change
    vet_CO2_2010_2020 = [0, 0.5]; // from +0 to +50%

    // historical energy vettings

    // Primary Energy (2020, IEA) | EJ
    vet_primary_energy = [578, -0.2, +0.2];
    vet_primary_energy_IP = [578, -0.1, +0.1];
    // Electricity Nuclear (2020, IEA)  | EJ
    vet_elec_nuke = [9.77, -0.3, +0.3];
    vet_elec_nuke_IP = [9.77, -0.2, +0.2];
    // Electricity Solar & Wind (2020.IEA, IRENA, BP, EMBERS). | EJ
    vet_elec_solarwind = [8.51 -0.5, +0.5];
    vet_elec_solarwind_IP = [8.51 -0.25, +0.25];

    // Future criteria

    //No net negative CO2 emissions before 2030 
    // CO2 total in 2030 >0 
    vet_max_NegEmi_2030 = 0;
    // CCS from Energy in 2030 < 2000 Mt CO2/yr
    vet_max_CCS_energy_2030 = 2000;

    //Electricity from Nuclear in 2030 < 20 EJ/yr  
    vet_max_elec_Nuke_2030 = 20;

    // CH4 emissions in 2040 | MtCH4/yr
    vet_min_ch4_2040 = 100;
    vet_max_ch4_2040 = 1000;
end

// NPi of COMMIT project - vettings
// https://doi.org/10.1038/s41467-021-26595-z
if current_time_im==1
   max_kyotogases_1530 = 0.212; // global
   max_kyotogases_1530_mili = -0.15; // low income
   max_kyotogases_1530_hi = 0.367; // high income
end

//-----------------------------------------------------------------------------------------------
// catching scenario values
//-----------------------------------------------------------------------------------------------

// Peak budget
if ~isdef("peak_CO2_budget")
    peak_CO2_budget=0;
    year_peak_CO2_budget=base_year_simulation;
end
if current_time_im>=2020-base_year_simulation
    global E_reg_use_sav
    global emi_evitee_sav
    worldBudget_2020 = round(sum(E_reg_use_sav(:,7:$))/1e9) ;
    emiEv_2020 = round(sum(emi_evitee_sav(:,7:$))/1e9);
    worldBudgetTot_2020 = worldBudget_2020 + emiEv_2020;
    if worldBudgetTot_2020 > peak_CO2_budget
        peak_CO2_budget = worldBudgetTot_2020;
	year_peak_CO2_budget=base_year_simulation+current_time_im;
    end
    //NPi & NDC testing
    if ind_npi_ndc~=0
        var_observed=sum(E_reg_use(ind_usa,:))/1e6 + sum(emi_evitee(ind_usa,:))/1e6; 
        select ind_npi_ndc
        case 1 // NPi case
        var_test = 5863; // MESSAGE
        case 2 // NDC case
        var_test = 5863;
        end
        test_string="NPi/NDC - USA CO2 emissions";
    
        if var_observed<var_test*1.05
            printf("Vetting "+test_string+" passed.");
        else
            printf("Vetting "+test_string+" failed");
        end

        var_observed=sum(E_reg_use(mk_2,:))/1e6 + sum(emi_evitee(mk_2,:))/1e6; 
        select ind_npi_ndc
        case 1 // NPi case
        var_test = 6823; //REMIND
        case 2 // NDC case
        var_test = 6823;
        end
        test_string="NPi/NDC - OECD exept USA CO2 emissions";
    
        if var_observed<var_test*1.05
        printf("Vetting "+test_string+" passed.");
        else
        printf("Vetting "+test_string+" failed");
        end
    end
end


//emi_CO2_EIP_2015
if current_time_im==2015-base_year_simulation
    emi_CO2_EIP_2015 = sum(E_reg_use)/1e6 + sum(emi_evitee)/1e6;
    emi_CO2_EIP_2015_mili = sum( E_reg_use .* (reg_li*ones(1,nb_use)))/1e6 + sum(emi_evitee.*reg_li)/1e6 + sum( E_reg_use .* (reg_mi*ones(1,nb_use)))/1e6 + sum(emi_evitee.*reg_mi)/1e6;
    emi_CO2_EIP_2015_hi = sum( E_reg_use .* (reg_hi*ones(1,nb_use)))/1e6 + sum(emi_evitee.*reg_hi)/1e6;
end

//emi_CO2_EIP_2030
if current_time_im==2030-base_year_simulation
    emi_CO2_EIP_2030 = sum(E_reg_use)/1e6 + sum(emi_evitee)/1e6;
    emi_CO2_EIP_2030_mili = sum( E_reg_use .* (reg_li*ones(1,nb_use)))/1e6 + sum(emi_evitee.*reg_li)/1e6 + sum( E_reg_use .* (reg_mi*ones(1,nb_use)))/1e6 + sum(emi_evitee.*reg_mi)/1e6;
    emi_CO2_EIP_2030_hi = sum( E_reg_use .* (reg_hi*ones(1,nb_use)))/1e6 + sum(emi_evitee.*reg_hi)/1e6;
end

//emi_CO2_EIP_2020
if current_time_im==2020-base_year_simulation
    emi_CO2_EIP_2020 = sum(E_reg_use)/1e6 + sum(emi_evitee)/1e6;
    emi_CO2_all_2020 = sum(E_reg_use)/1e6 + sum(emi_evitee)/1e6 + sum(exo_CO2_agri_direct) + sum(CO2_indus_process) + sum(exo_CO2_LUCCCF(:,current_time_im+1));
    PE_2020 = (sum(energy_balance(tpes_eb,primary_eb,:)))*Mtoe_EJ;
    Elec_Nuke_2020 = 0;
    Elec_solarwind_2020 = 0;
    Emi_CCS_2020 = 0;
    for k=1:nb_regions
	Elec_Nuke_2020 = Elec_Nuke_2020 + energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoElecNuke))*Mtoe_EJ;
        Elec_solarwind_2020 = Elec_solarwind_2020 + energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoSolar))*Mtoe_EJ + energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoWind))*Mtoe_EJ;
    end
    Emi_CCS_2020 = compute_emi_ccs(energy_balance,msh_elec_techno,coef_Q_CO2_ref,share_CCS_CTL);
end

if current_time_im==2025-base_year_simulation
    if ind_npi_ndc~=0

        var_observed=sum(E_reg_use(mk_2,:))/1e6 + sum(emi_evitee(mk_2,:))/1e6; 
        select ind_npi_ndc
        case 1 // NPi case
        var_test = 6282; //REMIND
        case 2 // NDC case
        var_test = 6601;
        end
        test_string="NPi/NDC - OECD exept USA CO2 emissions";

        if var_observed<var_test*1.05
        printf("Vetting "+test_string+" passed.");
        else
        printf("Vetting "+test_string+" failed");
        end
    end
end

if current_time_im==2019-base_year_simulation
    exo_CO2_agri_direct_nonan = exo_CO2_agri_direct;
    exo_CO2_agri_direct_nonan( exo_CO2_agri_direct_nonan<>exo_CO2_agri_direct_nonan)=0;
    exo_CO2_LUCCCF_nonan = exo_CO2_LUCCCF;
    exo_CO2_LUCCCF_nonan( exo_CO2_LUCCCF_nonan<>exo_CO2_LUCCCF_nonan) =0;
    emi_CO2_ener_2019 = sum(emi_evitee)/1e6+sum(E_reg_use)/1e6 ;
    emi_CO2_tot_2019 = sum(emi_evitee)/1e6+sum(E_reg_use)/1e6 +  sum(CO2_indus_process + exo_CO2_agri_direct_nonan(:,current_time_im+1)+exo_CO2_LUCCCF_nonan(:,current_time_im+1)) ;
end
if current_time_im==2025-base_year_simulation
    emi_CO2_ener_2025 = sum(emi_evitee)/1e6+sum(E_reg_use)/1e6 ;
    emi_CO2_tot_2025 = sum(emi_evitee)/1e6+sum(E_reg_use)/1e6 +  sum(CO2_indus_process + exo_CO2_agri_direct_nonan(:,current_time_im+1)+exo_CO2_LUCCCF_nonan(:,current_time_im+1)) ;
    disp("Total CO2 Emissions ratio 2025 / 2019 - (Energy, CO2 LUC and CO2 from industrial process")
    disp( [emi_CO2_ener_2025./emi_CO2_ener_2019, emi_CO2_tot_2025./emi_CO2_tot_2019]);
end

if current_time_im==2030-base_year_simulation
    emi_evitee_2030=sum(emi_evitee)/1e6;
    Elec_Nuke_2030 = 0;
    Emi_CCS_2030 = 0;
    for k=1:nb_regions
        Elec_Nuke_2030 = Elec_Nuke_2030 + energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoElecNuke))*Mtoe_EJ;
    end 
    Emi_CCS_2030 = compute_emi_ccs(energy_balance,msh_elec_techno,coef_Q_CO2_ref,share_CCS_CTL);
   
    if ind_npi_ndc~=0
        var_observed=sum(E_reg_use(ind_usa,:))/1e6 + sum(emi_evitee(ind_usa,:))/1e6; 
        select ind_npi_ndc
        case 1 // NPi case
        var_test = 5534; // MESSAGE
        case 2 // NPi case
        var_test = 4218;
        end
        test_string="NPi/NDC - USA CO2 emissions";
    
        if var_observed<var_test*1.05
            printf("Vetting "+test_string+" passed.");
        else
            printf("Vetting "+test_string+" failed");
        end

        var_observed=sum(E_reg_use(mk_2,:))/1e6 + sum(emi_evitee(mk_2,:))/1e6; 
        select ind_npi_ndc
        case 1 // NPi case
        var_test = 6640; //REMIND
        case 2 // NDC case
        var_test = 5787;
        end
        test_string="NDC/NPi - OECD exept USA CO2 emissions";
    
        if var_observed<var_test*1.05
        printf("Vetting "+test_string+" passed.");
        else
        printf("Vetting "+test_string+" failed");
        end
    end
end

//-----------------------------------------------------------------------------------------------
// Checking IPCC vettings
//-----------------------------------------------------------------------------------------------
if current_time_im==2030-base_year_simulation
    global_vetting=%t;

    // CO2 total
    var_observed=emi_CO2_all_2020;
    vect_test=vet_co2_all;
    test_string="CO2 Total";
    if var_observed>vect_test(1)*(1+vect_test(2)) & var_observed<vect_test(1)*(1+vect_test(3))
        disp("Vetting "+test_string+" passed:")
    else
        disp("Vetting "+test_string+" failed:")
    end
        printf("Vetting "+test_string+"       value is %.20G; range is [%.20G,%.20G]\n",var_observed,vect_test(1)*(1+vect_test(2)),vect_test(1)*(1+vect_test(3)));
    string_for_diag = "IPCC vetting "+ test_string + " - 2030 ["+vect_test(1)*(1+vect_test(2))+";"+vect_test(1)*(1+vect_test(3))+"]";
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

    // CO2 total (IP)
    var_observed=emi_CO2_all_2020;
    vect_test=vet_co2_all_IP;
    test_string="CO2 Total (IP range)";
    if var_observed>vect_test(1)*(1+vect_test(2)) & var_observed<vect_test(1)*(1+vect_test(3))
        disp("Vetting "+test_string+" passed:")
    else
        disp("Vetting "+test_string+" failed:")
    end
        printf("Vetting "+test_string+"       value is %.20G; range is [%.20G,%.20G]\n",var_observed,vect_test(1)*(1+vect_test(2)),vect_test(1)*(1+vect_test(3)));
    string_for_diag = "IPCC vetting "+ test_string + " - 2030 ["+vect_test(1)*(1+vect_test(2))+";"+vect_test(1)*(1+vect_test(3))+"]";
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

    // CO2 EIP
    var_observed=emi_CO2_EIP_2020;
    vect_test=vet_co2_EIP;
    test_string="CO2 EIP";
    if var_observed>vect_test(1)*(1+vect_test(2)) & var_observed<vect_test(1)*(1+vect_test(3))
        disp("Vetting "+test_string+" passed:")
    else
        disp("Vetting "+test_string+" failed:")
    end
        printf("Vetting "+test_string+"       value is %.20G; range is [%.20G,%.20G]\n",var_observed,vect_test(1)*(1+vect_test(2)),vect_test(1)*(1+vect_test(3)));
    string_for_diag = "IPCC vetting "+ test_string + " - 2030 ["+vect_test(1)*(1+vect_test(2))+";"+vect_test(1)*(1+vect_test(3))+"]";
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

    // CO2 EIP (IP)
    var_observed=emi_CO2_EIP_2020;
    vect_test=vet_co2_EIP_IP;
    test_string="CO2 EIP (IP range)";
    if var_observed>vect_test(1)*(1+vect_test(2)) & var_observed<vect_test(1)*(1+vect_test(3))
        disp("Vetting "+test_string+" passed:")
    else
        disp("Vetting "+test_string+" failed:")
    end
        printf("Vetting "+test_string+"       value is %.20G; range is [%.20G,%.20G]\n",var_observed,vect_test(1)*(1+vect_test(2)),vect_test(1)*(1+vect_test(3)));
    string_for_diag = "IPCC vetting "+ test_string + " - 2030 ["+vect_test(1)*(1+vect_test(2))+";"+vect_test(1)*(1+vect_test(3))+"]";
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

    // primary energy
    var_observed=PE_2020;
    vect_test=vet_primary_energy;
    test_string="Primary Energy";
    if var_observed>vect_test(1)*(1+vect_test(2)) & var_observed<vect_test(1)*(1+vect_test(3))
        disp("Vetting "+test_string+" passed:")
    else
        disp("Vetting "+test_string+" failed:")
    end
        printf("Vetting "+test_string+"       value is %.20G; range is [%.20G,%.20G]\n",var_observed,vect_test(1)*(1+vect_test(2)),vect_test(1)*(1+vect_test(3)));
    string_for_diag = "IPCC vetting "+ test_string + " - 2030 ["+vect_test(1)*(1+vect_test(2))+";"+vect_test(1)*(1+vect_test(3))+"]";
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

    // primary energy (IP)
    var_observed=PE_2020;
    vect_test=vet_primary_energy_IP;
    test_string="Primary Energy (IP range)";
    if var_observed>vect_test(1)*(1+vect_test(2)) & var_observed<vect_test(1)*(1+vect_test(3))
        disp("Vetting "+test_string+" passed:")
    else
        disp("Vetting "+test_string+" failed:")
    end
        printf("Vetting "+test_string+"       value is %.20G; range is [%.20G,%.20G]\n",var_observed,vect_test(1)*(1+vect_test(2)),vect_test(1)*(1+vect_test(3)));
    string_for_diag = "IPCC vetting "+ test_string + " - 2030 ["+vect_test(1)*(1+vect_test(2))+";"+vect_test(1)*(1+vect_test(3))+"]";
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

    // primary energy nuclear
    var_observed=Elec_Nuke_2020;
    vect_test=vet_elec_nuke;
    test_string="Electricity Nuclear";
    if var_observed>vect_test(1)*(1+vect_test(2)) & var_observed<vect_test(1)*(1+vect_test(3))
        disp("Vetting "+test_string+" passed:")
    else
        disp("Vetting "+test_string+" failed:")
    end
        printf("Vetting "+test_string+"         value %.20G; range is [%.20G,%.20G]\n",var_observed,vect_test(1)*(1+vect_test(2)),vect_test(1)*(1+vect_test(3)));
    string_for_diag = "IPCC vetting "+ test_string + " - 2030 ["+vect_test(1)*(1+vect_test(2))+";"+vect_test(1)*(1+vect_test(3))+"]";
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

    // primary energy nuclear (IP)
    var_observed=Elec_Nuke_2020;
    vect_test=vet_elec_nuke_IP;
    test_string="Electricity Nuclear (IP range)";
    if var_observed>vect_test(1)*(1+vect_test(2)) & var_observed<vect_test(1)*(1+vect_test(3))
        disp("Vetting "+test_string+" passed:")
    else
        disp("Vetting "+test_string+" failed:")
    end
        printf("Vetting "+test_string+"         value %.20G; range is [%.20G,%.20G]\n",var_observed,vect_test(1)*(1+vect_test(2)),vect_test(1)*(1+vect_test(3)));
    string_for_diag = "IPCC vetting "+ test_string + " - 2030 ["+vect_test(1)*(1+vect_test(2))+";"+vect_test(1)*(1+vect_test(3))+"]";
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

    // primary energy wind and solar
    var_observed=Elec_solarwind_2020;
    vect_test=vet_elec_solarwind;
    test_string="Electricity Solar & Wind";
    if var_observed>vect_test(1)*(1+vect_test(2)) & var_observed<vect_test(1)*(1+vect_test(3))
        disp("Vetting "+test_string+" passed:")
    else
        disp("Vetting "+test_string+" failed:")
    end
        printf("Vetting "+test_string+"       value is %.20G; range is [%.20G,%.20G]\n",var_observed,vect_test(1)*(1+vect_test(2)),vect_test(1)*(1+vect_test(3)));
    string_for_diag = "IPCC vetting "+ test_string + " - 2030 ["+vect_test(1)*(1+vect_test(2))+";"+vect_test(1)*(1+vect_test(3))+"]";
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

    // primary energy wind and solar (IP)
    var_observed=Elec_solarwind_2020;
    vect_test=vet_elec_solarwind_IP;
    test_string="Electricity Solar & Wind (IP)";
    if var_observed>vect_test(1)*(1+vect_test(2)) & var_observed<vect_test(1)*(1+vect_test(3))
        disp("Vetting "+test_string+" passed:")
    else
        disp("Vetting "+test_string+" failed:")
    end
        printf("Vetting "+test_string+"       value is %.20G; range is [%.20G,%.20G]\n",var_observed,vect_test(1)*(1+vect_test(2)),vect_test(1)*(1+vect_test(3)));
    string_for_diag = "IPCC vetting "+ test_string + " - 2030 ["+vect_test(1)*(1+vect_test(2))+";"+vect_test(1)*(1+vect_test(3))+"]";
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

    // CCS in energy from 2020
    if Emi_CCS_2020 < 250
        disp("Soft Vetting CCS 2020 passed:")
    else
        disp("Soft Vetting CCS 2020 failed:")
    end
        printf("    Vetting CCS 2020        value is %.20G; range is [%.20G,%.20G]\n",Emi_CCS_2030, 0, 200);

    // CCS in energy from 2020 (IP range)
    if Emi_CCS_2020 < 100
        disp("Soft Vetting CCS 2020 passed:")
    else
        disp("Soft Vetting CCS 2020 failed:")
    end
        printf("    Vetting CCS 2020        value is %.20G; range is [%.20G,%.20G]\n",Emi_CCS_2030, 0, 100);

    // CCS in energy from 2030
    if Emi_CCS_2030 < 2000
        disp("Soft Vetting CCS 2030 passed:")
    else
        disp("Soft Vetting CCS 2030 failed:")
    end
        printf("     Vetting CCS 2030        value is %.20G; range is [%.20G,%.20G]\n",Emi_CCS_2030, 0, 2000);

    //vet_max_NegEmi_2030
    if emi_evitee_2030 <= vet_max_NegEmi_2030
        disp("Soft Vetting Emi Negative 2030 passed:")
    else
        disp("Soft Vetting Emi Negative 2030 failed:")
    end
        printf("    Vetting Emi Negative         value is %.20G; range is [%.20G,%.20G]\n",emi_evitee_2030, 0, 0);

    //vet_max_elec_Nuke_2030
    if Elec_Nuke_2030 <= 20
        disp("Soft Vetting Emi Negative 2030 passed:")
    else
        disp("Soft Vetting Emi Negative 2030 failed:")
    end
        printf("    Vetting Emi Negative         value is %.20G; range is [%.20G,%.20G]\n",Elec_Nuke_2030, 0, 20);

    // NPi	
    var_observed=emi_CO2_EIP_2030 ./ emi_CO2_EIP_2015-1;
    var_test=max_kyotogases_1530;
    test_string="NPi - global CO2 emissions";
    if var_observed<var_test
        printf("Vetting "+test_string+" passed. Emissions from 2015 to 2030 varied by: %.20G (<%.20G)\n",var_observed,var_test);
    else
        printf("Vetting "+test_string+" failed. Emissions from 2015 to 2030 varied by: %.20G (>%.20G)\n",var_observed,var_test);
    end

    var_observed=emi_CO2_EIP_2030_hi ./ emi_CO2_EIP_2015_hi-1;
    var_test=max_kyotogases_1530_hi;
    test_string="NPi - high income CO2 emissions";
    if var_observed<var_test 
        printf("Vetting "+test_string+" passed. Emissions from 2015 to 2030 varied by: %.20G (<%.20G)\n",var_observed,var_test);
    else
        printf("Vetting "+test_string+" failed. Emissions from 2015 to 2030 varied by: %.20G (>%.20G)\n",var_observed,var_test);
    end

    var_observed=emi_CO2_EIP_2030_mili ./ emi_CO2_EIP_2015_mili-1;
    var_test=max_kyotogases_1530_mili;
    test_string="NPi - middle/low income CO2 emissions";
    if var_observed<var_test 
        printf("Vetting "+test_string+" passed. Emissions from 2015 to 2030 varied by: %.20G (<%.20G)\n",var_observed,var_test);
    else
        printf("Vetting "+test_string+" failed. Emissions from 2015 to 2030 varied by: %.20G (>%.20G)\n",var_observed,var_test);
    end

end

//-----------------------------------------------------------------------------------------------
// Historical GDP vetting
//-----------------------------------------------------------------------------------------------

if current_time_im == 1
    world_bank_data=read_csv_file(path_world_bank+"world_bank_data_2020.csv",'|');
    icol_gdpmer=find(world_bank_data(1,:)=="GDP (current US$)");
    icol_gdpppp=find(world_bank_data(1,:)=="GDP, PPP (current international $)");

    GDP_PPP_WB_2020=zeros(nb_regions);
    for ireg=1:nb_regions
        GDP_PPP_WB_2020(ireg) = eval(world_bank_data( find(world_bank_data(:,1)==regnames(ireg)), icol_gdpppp)) *1e-6*CPI_2020_to_2014;
    end
end

if current_time_im == (2020-base_year_simulation) & auto_calibration_covid<>"None"
    disp([ [regnames;"WLD"], string([GDP_PPP_constant;sum(GDP_PPP_constant)]), string([GDP_PPP_WB_2020;sum(GDP_PPP_WB_2020)]), string([GDP_PPP_constant./GDP_PPP_WB_2020;sum(GDP_PPP_constant)/sum(GDP_PPP_WB_2020)]), string([GDP_PPP_constant./GDP_PPP_constant_prev;sum(GDP_PPP_constant)/sum(GDP_PPP_constant_prev)])], "GDP PPP IMACLIM, GDP PPP World Bank, ratio, GDP Imaclim ratio on previous");
    csvWrite( scale_impact_covid./(GDP_PPP_constant./GDP_PPP_WB_2020), path_autocalibration+'/scale_impact_covid.csv');
    break
end

//-----------------------------------------------------------------------------------------------
// Historical emission vetting
//-----------------------------------------------------------------------------------------------

if current_time_im <= 2020 - base_year_simulation
    emi_resid = sum(( alphaCoalm2 .* coef_Q_CO2_DF(:,coal) + alphaGazm2.* coef_Q_CO2_DF(:,gaz) + alphaelecm2.* coef_Q_CO2_DF(:,elec) + alphaEtm2 .* coef_Q_CO2_DF(:,indice_Et)) .* stockbatiment ) / 1e6;
    emi_comp = sum(E_reg_use(:,iu_comp)) / 1e6;
    emi_elec = sum(E_reg_use(:,iu_elec)) / 1e6;
    emi_otherener = sum(E_reg_use(:,[iu_coal,iu_oil,iu_gaz])) / 1e6;
    emi_et = sum(E_reg_use(:,iu_Et)) / 1e6;
    emi_indus = sum(E_reg_use(:,iu_indu)) / 1e6 + sum(E_reg_use(:,iu_cons)) / 1e6 + exo_CO2_indus_process(current_time_im+1) + sum(E_reg_use(:,iu_agri)) / 1e6 - exo_CO2_agri_direct(current_time_im+1);
    emi_transport = sum(E_reg_use(:,[iu_OT,iu_air,iu_mer])) / 1e6 + sum(Tautomobile.*alphaEtauto.*pkmautomobileref/100 .* coef_Q_CO2_DF(:,indice_Et)) / 1e6;

    emi_agri = sum(exo_CO2_agri_direct(:,current_time_im+1));// + exo_CO2_LUCCCF(current_time_im+1);
    emi_tot = sum(E_reg_use) / 1e6 + exo_CO2_indus_process(current_time_im+1) + sum(exo_CO2_LUCCCF(:,current_time_im+1),'r');

    emi_sumary = [emi_resid/exo_CO2_Resid(current_time_im+1), emi_comp/exo_CO2_nonResid(current_time_im+1), emi_elec/exo_CO2_Elec(current_time_im+1), emi_otherener/exo_CO2_OtherEnergy(current_time_im+1), emi_et/exo_CO2_Et_refining(current_time_im+1), emi_indus/ exo_CO2_Industry(current_time_im+1), emi_transport/exo_CO2_Transport(current_time_im+1), emi_agri/exo_CO2_AFOLU(current_time_im+1), emi_tot/exo_CO2_ref(current_time_im+1)];

    emi_sect_imaclim = [emi_resid, emi_comp, emi_elec, emi_otherener, emi_et, emi_indus, emi_transport, emi_agri, emi_tot];
    emi_sect_reference = [exo_CO2_Resid(current_time_im+1), exo_CO2_nonResid(current_time_im+1),exo_CO2_Elec(current_time_im+1), exo_CO2_OtherEnergy(current_time_im+1), exo_CO2_Et_refining(current_time_im+1), exo_CO2_Industry(current_time_im+1), exo_CO2_Transport(current_time_im+1), exo_CO2_AFOLU(current_time_im+1), exo_CO2_ref(current_time_im+1)];

    disp( [["Resid", "Comp", "Elec", "Other Ener", "Et", "Ind", "Transport", "Agri", "Tot";emi_sumary;emi_sect_imaclim;emi_sect_reference]])
end



//-----------------------------------------------------------------------------------------------
// End of run diagnostic
//-----------------------------------------------------------------------------------------------

if current_time_im == TimeHorizon
    global Q_sav
    quantities = rgv(Q_sav,TimeHorizon+1,sec,reg);
    disp("For the folllowing to be true, historical extraction from 2010 to 2013 included need to be added");
    disp("Cum Gaz 2010-2100 is " + string( Mtep2ZJ * sum(squeeze(quantities(:,gaz,1:$))) ) + "   ZJ")
    disp("Cum Coal 2010-2100 is " + string( Mtep2ZJ * sum(squeeze(quantities(:,coal,1:$))) ) + "   ZJ")
    disp("Cum Oil 2010-2100 is " + string( Mtep2ZJ * sum(squeeze(quantities(:,oil,1:$))) ) + "   ZJ")

    global E_reg_use_sav
    global emi_evitee_sav
    global CO2_indus_process_sav
    // removing nan
    worldBudget_2020 = round(sum(E_reg_use_sav(:,7:$))/1e9 + (CO2_indus_process_sav(:,7:$) + exo_CO2_agri_direct_nonan(:,7:$)+exo_CO2_LUCCCF_nonan(:,7:$))/1e3) ;
    emiEv_2020 = sum(emi_evitee_sav(:,7:$))/1e9;
    emiEv_20202050 = sum(emi_evitee_sav(:,7:37))/1e9;
    CO2_ener_2020 = sum(E_reg_use_sav(:,7:$))/1e9;
    CO2_ener_20202050 = sum(E_reg_use_sav(:,7:37))/1e9;
    CO2_process_2020 = sum(CO2_indus_process_sav(:,7:$)) /1e3;
    CO2_process_20202050 = sum(CO2_indus_process_sav(:,7:37)) /1e3;
    exo_LUC_2020 = sum(exo_CO2_agri_direct_nonan(:,7:$)+exo_CO2_LUCCCF_nonan(:,7:$))/1e3;
    exo_LUC_20202050 = sum(exo_CO2_agri_direct_nonan(:,7:37)+exo_CO2_LUCCCF_nonan(:,7:37))/1e3;
    if ind_exo_afforestation==0
        worldBudgetTot_2020 = round(CO2_ener_2020 + CO2_process_2020 + emiEv_2020 + exo_LUC_2020);   
        worldBudgetTot_20202050 = round(CO2_ener_20202050 + CO2_process_20202050 + emiEv_20202050 + exo_LUC_20202050);   
    else
        LUbudget_2020 = sum(exo_CO2_AFOLU(7:$))/1e3;
        LUbudget_20202050 = sum(exo_CO2_AFOLU(7:37))/1e3;
        worldBudgetTot_2020 = round(CO2_ener_2020 +                    emiEv_2020 +              + LUbudget_2020);
        worldBudgetTot_20202050 = round(CO2_ener_20202050 +                    emiEv_20202050 +              + LUbudget_20202050);
    end
    net_negative = sum(emi_evitee_sav(:,7:$),"r")/1e9 + sum(E_reg_use_sav(:,7:$),"r")/1e9;
    net_negative( net_negative>0) = 0;
    disp("Cum CO2 Emi 2020-"+ string (base_year_simulation+TimeHorizon) + " is " + string( worldBudgetTot_2020) + "   GtCO2")
    disp("Cum CO2 Emi 2020-2050 is " + string( worldBudgetTot_20202050) + "   GtCO2")
    printf("\nPeak budget between 2020 and 2100 is "+string(peak_CO2_budget) + " GtCO2a at year "+string(year_peak_CO2_budget))
    printf("\nTotal negative emissions between 2020 and 2100 are "+string(sum(emiEv_2020) ))
    printf("\n		--- should be lower than 300 GtCO2 in NAVIGATE 2°C scenarios")
    printf("\n		--- should be lower than 500 GtCO2 in NAVIGATE 1.5°C scenarios")
    printf("\nTotal net negative emissions between 2020 and 2100 are "+string(sum(net_negative) ))
    printf("\n		--- should be lower than 100 GtCO2 in NAVIGATE 2°C scenarios")
    printf("\n		--- should be lower than 250 GtCO2 in NAVIGATE 1.5°C scenarios\n")
    //disp("Total negative emission rises to "+string(emiEv_2020) + "   GtCO2")


// Variable to be integrated to the "metadata indicators" .xls file
    // Cumulative net CO2 - 2020-2100
    var_observed=worldBudgetTot_2020;
    test_string="Cumulative net CO2 (2020-2100, Gt CO2)";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

    // Year of peak CO2 Emissions
    var_observed=year_peak_CO2_budget;
    test_string="Year of peak CO2 Emissions";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// Cumulative net CO2 (2020-2100, Gt CO2)
    var_observed=sum(net_negative);
    test_string="Cumulative net CO2 (2020-2100, Gt CO2)";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end
	
	// Cumulative negative emission (2020-2100, Gt CO2)
    var_observed=sum(emiEv_2020);
    test_string="Cumulative negative emission (2020-2100, Gt CO2)";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end
	
	// Final Energy 2100
    var_observed=sum(energy_balance(conso_tot_eb,:,:)-energy_balance(marbunk_eb,:,:))*Mtoe_EJ;
    test_string="Final Energy - 2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end











    // save vettings scenario
    if record_vett_carbonbudget==%t
        co2_budget_vett =     [1150,1050,1000,800,700,700,600,400];
        co2_budget_net_vett = [300, 400, 300, 420,420,500,500,500];
 
        for ii=1:size(co2_budget_vett,'c')
            mkdir(OUTPUT + 'YouHaveBeenVetted_'+string(co2_budget_vett(ii))+'_'+string(co2_budget_net_vett(ii))+'/')
            if worldBudgetTot_2020 <= co2_budget_vett(ii) & abs(sum(emiEv_2020)) <= co2_budget_net_vett(ii)
                csvWrite( [worldBudgetTot_2020,sum(emiEv_2020)], OUTPUT + 'YouHaveBeenVetted_'+string(co2_budget_vett(ii))+'_'+string(co2_budget_net_vett(ii))+'/' + string(combi) + suffix2combiName + '.csv', '|');
            end
        end
    end
end





if current_time_im == 2019-base_year_simulation

// Variable to be integrated to test the new OT dynamics
    // LDV share 2019
    var_observed= (sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT)) / ((sum(EnergyServices_road_pass) + sum(EnergyServices_rail_pass)).*10^9 + sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100 .* ShareDomAviation_2014) +  + sum(TNM.*pkmautomobileref./100) + sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT));
    test_string="Share_LDV_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// Public transport share 2019
    var_observed= (sum(EnergyServices_road_pass) + sum(EnergyServices_rail_pass))*10^9 / ((sum(EnergyServices_road_pass) + sum(EnergyServices_rail_pass)).*10^9 + sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100 .* ShareDomAviation_2014) + sum(TNM.*pkmautomobileref./100) + sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT));
    test_string="Share_public_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;
	
	// Active mode share 2019
	var_observed= (sum(TNM.*pkmautomobileref./100)) / ((sum(EnergyServices_road_pass) + sum(EnergyServices_rail_pass)).*10^9 + sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100 .* ShareDomAviation_2014) + sum(TNM.*pkmautomobileref./100) + sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT));
    test_string="Share_active_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// air pkm 2019
	var_observed= sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100 .* ShareDomAviation_2014);
    test_string="pkm_airdom_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// air pkm 2019
	var_observed= sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100);
    test_string="pkm_airtot_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

    // LDV pkm 2019
    var_observed=sum((Tautomobile.*pkmautomobileref /100 + pkm_ldv_in_OT)/ 1e9);
    test_string="pkm_LDV_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// tkm freight 2019
    var_observed=sum((Q(:,indice_OT)-DF(:,indice_OT)+Q(:,indice_mer)-DF(:,indice_mer)+Q(:,indice_air)-DF(:,indice_air))./convfactorOT_tkmtoDF);
	tkm_freight = sum((Q(:,indice_OT)-DF(:,indice_OT)+Q(:,indice_mer)-DF(:,indice_mer)+Q(:,indice_air)-DF(:,indice_air))./convfactorOT_tkmtoDF);
    test_string="tkm_freight_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// tkm shipping 2019
    var_observed=sum(Q(:,indice_mer)-DF(:,indice_mer)./convfactorOT_tkmtoDF);
    test_string="tkm_shipping_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// electricity in trucks and bus in 2019
    var_observed=	sum(alpharoad_passenger(:,indice_elec)		.*EnergyServices_road_pass(:) + alpharoad_freight(:,indice_elec)	.*EnergyServices_road_fret(:)) ..
	/ sum(alpharoad_passenger(:,energyIndexes)	.*(EnergyServices_road_pass(:) * ones(1,nbsecteurenergie)) + alpharoad_freight(:,energyIndexes).*(EnergyServices_road_fret(:) * ones(1,nbsecteurenergie)));
    test_string="truck_elec_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// Final Energy 2019 
    var_observed=sum(energy_balance(conso_tot_eb,:,:)-energy_balance(marbunk_eb,:,:))*Mtoe_EJ;
    test_string="Final_Energy_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Final Energy for transport 2019
    var_observed=sum(energy_balance(conso_transport_eb,:,:))*Mtoe_EJ;
    test_string="FE_trans_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// GDP MER 2019
    var_observed=sum(GDP_MER_real(:))/ 1e3*usd_year1_year2;
    test_string="gdp_mer_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Efficiency freight 2019
    var_observed=sum(final_energy_freight)/tkm_freight;
    test_string="freight_eff_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Efficiency of trucks
    var_observed=sum(sum(alpharoad_freight, "c") .* EnergyServices_road_fret) / sum(EnergyServices_road_fret);
    test_string="truck_eff_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Efficiency of cars
    var_observed=sum(sum(Tautomobile.*pkmautomobileref /100 +pkm_ldv_in_OT, "c") .* (alphaEtauto + alphaelecauto)) / (sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT));
    test_string="cars_eff_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Electrification of trucks
    var_observed=sum(alpharoad_freight(:,indice_elec) .* EnergyServices_road_fret) / sum(sum(alpharoad_freight, "c") .* EnergyServices_road_fret);
    test_string="truck_elec_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Electrification of cars
    var_observed=sum(sum(Tautomobile.*pkmautomobileref /100 + pkm_ldv_in_OT, "c") .* alphaelecauto) / sum(sum(Tautomobile.*pkmautomobileref /100 +pkm_ldv_in_OT, "c") .* (alphaEtauto + alphaelecauto));
    test_string="cars_elec_2019";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end


end

if current_time_im == 2050-base_year_simulation

// Variable to be integrated to test the new OT dynamics
    // LDV share 2050
    var_observed= (sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT)) / ((sum(EnergyServices_road_pass) + sum(EnergyServices_rail_pass)).*10^9 + sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100 .* ShareDomAviation_2014) +  + sum(TNM.*pkmautomobileref./100) + sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT));
    test_string="Share_LDV_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// Public transport share 2050
    var_observed= (sum(EnergyServices_road_pass) + sum(EnergyServices_rail_pass))*10^9 / ((sum(EnergyServices_road_pass) + sum(EnergyServices_rail_pass)).*10^9 + sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100 .* ShareDomAviation_2014) + sum(TNM.*pkmautomobileref./100) + sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT));
    test_string="Share_public_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;
	
	// Active mode share 2050
	var_observed= (sum(TNM.*pkmautomobileref./100)) / ((sum(EnergyServices_road_pass) + sum(EnergyServices_rail_pass)).*10^9 + sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100 .* ShareDomAviation_2014) + sum(TNM.*pkmautomobileref./100) + sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT));
    test_string="Share_active_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// air pkm 2050
	var_observed= sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100 .* ShareDomAviation_2014);
    test_string="pkm_airdom_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// air pkm 2050
	var_observed= sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100);
    test_string="pkm_airtot_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

    // LDV pkm 2050
    var_observed=sum((Tautomobile.*pkmautomobileref /100 + pkm_ldv_in_OT)/ 1e9);
    test_string="pkm_LDV_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// tkm freight 2050
    var_observed=sum((Q(:,indice_OT)-DF(:,indice_OT)+Q(:,indice_mer)-DF(:,indice_mer)+Q(:,indice_air)-DF(:,indice_air))./convfactorOT_tkmtoDF);
	tkm_freight = sum((Q(:,indice_OT)-DF(:,indice_OT)+Q(:,indice_mer)-DF(:,indice_mer)+Q(:,indice_air)-DF(:,indice_air))./convfactorOT_tkmtoDF);
    test_string="tkm_freight_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// tkm shipping 2050
    var_observed=sum(Q(:,indice_mer)-DF(:,indice_mer)./convfactorOT_tkmtoDF);
    test_string="tkm_shipping_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// electricity in trucks and bus in 2050
    var_observed=	sum(alpharoad_passenger(:,indice_elec)		.*EnergyServices_road_pass(:) + alpharoad_freight(:,indice_elec)	.*EnergyServices_road_fret(:)) ..
	/ sum(alpharoad_passenger(:,energyIndexes)	.*(EnergyServices_road_pass(:) * ones(1,nbsecteurenergie)) + alpharoad_freight(:,energyIndexes).*(EnergyServices_road_fret(:) * ones(1,nbsecteurenergie)));
    test_string="truck_elec_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// Final Energy 2050 
    var_observed=sum(energy_balance(conso_tot_eb,:,:)-energy_balance(marbunk_eb,:,:))*Mtoe_EJ;
    test_string="Final_Energy_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Final Energy for transport 2050
    var_observed=sum(energy_balance(conso_transport_eb,:,:))*Mtoe_EJ;
    test_string="FE_trans_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// GDP MER 2050
    var_observed=sum(GDP_MER_real(:))/ 1e3*usd_year1_year2;
    test_string="gdp_mer_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Efficiency freight 2050
    var_observed=sum(final_energy_freight)/tkm_freight;
    test_string="freight_eff_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Efficiency of trucks
    var_observed=sum(sum(alpharoad_freight, "c") .* EnergyServices_road_fret) / sum(EnergyServices_road_fret);
    test_string="truck_eff_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Efficiency of cars
    var_observed=sum(sum(Tautomobile.*pkmautomobileref /100 +pkm_ldv_in_OT, "c") .* (alphaEtauto + alphaelecauto)) / (sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT));
    test_string="cars_eff_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Electrification of trucks
    var_observed=sum(alpharoad_freight(:,indice_elec) .* EnergyServices_road_fret) / sum(sum(alpharoad_freight, "c") .* EnergyServices_road_fret);
    test_string="truck_elec_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Electrification of cars
    var_observed=sum(sum(Tautomobile.*pkmautomobileref /100 + pkm_ldv_in_OT, "c") .* alphaelecauto) / sum(sum(Tautomobile.*pkmautomobileref /100 +pkm_ldv_in_OT, "c") .* (alphaEtauto + alphaelecauto));
    test_string="cars_elec_2050";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end


end


if current_time_im == TimeHorizon 

// Variable to be integrated to test the new OT dynamics
    // LDV share 2100
    var_observed= (sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT)) / ((sum(EnergyServices_road_pass) + sum(EnergyServices_rail_pass)).*10^9 + sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100 .* ShareDomAviation_2014) +  + sum(TNM.*pkmautomobileref./100) + sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT));
    test_string="Share_LDV_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// Public transport share 2100
    var_observed= (sum(EnergyServices_road_pass) + sum(EnergyServices_rail_pass))*10^9 / ((sum(EnergyServices_road_pass) + sum(EnergyServices_rail_pass)).*10^9 + sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100 .* ShareDomAviation_2014) + sum(TNM.*pkmautomobileref./100) + sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT));
    test_string="Share_public_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;
	
	// Active mode share 2100
	var_observed= (sum(TNM.*pkmautomobileref./100)) / ((sum(EnergyServices_road_pass) + sum(EnergyServices_rail_pass)).*10^9 + sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100 .* ShareDomAviation_2014) + sum(TNM.*pkmautomobileref./100) + sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT));
    test_string="Share_active_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// air pkm 2100
	var_observed= sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100 .* ShareDomAviation_2014);
    test_string="pkm_airdom_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// air pkm 2100
	var_observed= sum(alphaair.*DF(:,indice_air).*pkmautomobileref./100);
    test_string="pkm_airtot_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

    // LDV pkm 2100
    var_observed=sum((Tautomobile.*pkmautomobileref /100 + pkm_ldv_in_OT)/ 1e9);
    test_string="pkm_LDV_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// tkm freight 2100
    var_observed=sum((Q(:,indice_OT)-DF(:,indice_OT)+Q(:,indice_mer)-DF(:,indice_mer)+Q(:,indice_air)-DF(:,indice_air))./convfactorOT_tkmtoDF);
	tkm_freight = sum((Q(:,indice_OT)-DF(:,indice_OT)+Q(:,indice_mer)-DF(:,indice_mer)+Q(:,indice_air)-DF(:,indice_air))./convfactorOT_tkmtoDF);
    test_string="tkm_freight_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// tkm shipping 2100
    var_observed=sum(Q(:,indice_mer)-DF(:,indice_mer)./convfactorOT_tkmtoDF);
    test_string="tkm_shipping_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// electricity in trucks and bus in 2100
    var_observed=	sum(alpharoad_passenger(:,indice_elec)		.*EnergyServices_road_pass(:) + alpharoad_freight(:,indice_elec)	.*EnergyServices_road_fret(:)) ..
	/ sum(alpharoad_passenger(:,energyIndexes)	.*(EnergyServices_road_pass(:) * ones(1,nbsecteurenergie)) + alpharoad_freight(:,energyIndexes).*(EnergyServices_road_fret(:) * ones(1,nbsecteurenergie)));
    test_string="truck_elec_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end;

	// Final Energy 2100 
    var_observed=sum(energy_balance(conso_tot_eb,:,:)-energy_balance(marbunk_eb,:,:))*Mtoe_EJ;
    test_string="Final_Energy_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Final Energy for transport 2100
    var_observed=sum(energy_balance(conso_transport_eb,:,:))*Mtoe_EJ;
    test_string="FE_trans_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// GDP MER 2100
    var_observed=sum(GDP_MER_real(:))/ 1e3*usd_year1_year2;
    test_string="gdp_mer_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Efficiency freight 2100
    var_observed=sum(final_energy_freight)/tkm_freight;
    test_string="freight_eff_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Efficiency of trucks
    var_observed=sum(sum(alpharoad_freight, "c") .* EnergyServices_road_fret) / sum(EnergyServices_road_fret);
    test_string="truck_eff_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Efficiency of cars
    var_observed=sum(sum(Tautomobile.*pkmautomobileref /100 +pkm_ldv_in_OT, "c") .* (alphaEtauto + alphaelecauto)) / (sum(Tautomobile.*pkmautomobileref /100) + sum(pkm_ldv_in_OT));
    test_string="cars_eff_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Electrification of trucks
    var_observed=sum(alpharoad_freight(:,indice_elec) .* EnergyServices_road_fret) / sum(sum(alpharoad_freight, "c") .* EnergyServices_road_fret);
    test_string="truck_elec_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end

	// Electrification of cars
    var_observed=sum(sum(Tautomobile.*pkmautomobileref /100 + pkm_ldv_in_OT, "c") .* alphaelecauto) / sum(sum(Tautomobile.*pkmautomobileref /100 +pkm_ldv_in_OT, "c") .* (alphaEtauto + alphaelecauto));
    test_string="cars_elec_2100";
    string_for_diag = test_string;
    if tool_output_diagnostic; diagnotic_list=[diagnotic_list;[string_for_diag,var_observed]]; end


end