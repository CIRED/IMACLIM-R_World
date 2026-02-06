// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


counterLine = 0 ;

varname = 'GDP|PPP'; // billion billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=GDP_PPP_constant(k)/ 1e3*usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;


if ind_climat > 2
    varname = 'Policy Cost|GDP Loss';
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="GDP MER";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (GDP_MER_real(k) - GDP_base_MER_real(k,current_time_im+1)) / 1e3*usd_year1_year2; // negative numbers requested by EM
else
    varname_temp = 'Policy Cost|GDP Loss';
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
end

varname = 'Final Energy'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = (sum(energy_balance(conso_tot_eb,:,k)))*Mtoe_EJ;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Electricity'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(conso_tot_eb,elec_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|w/o CCS'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = - energy_balance(refi_eb,enr_eb,k) * Mtoe_EJ / hoogwick_bioEt_efficienc(current_time_im) + sum(qBiomExaJ(k,1));
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|w/ CCS'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = sum(qBiomExaJ(k,2));
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = sum(qBiomExaJ(k,2)) - energy_balance(refi_eb,enr_eb,k) * Mtoe_EJ / hoogwick_bioEt_efficienc(current_time_im) + sum(qBiomExaJ(k,1));
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Coal'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(tpes_eb,coal_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Coal|w/ CCS'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    - energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k) .. // raffineries (ctl)
    - energy_balance(losses_eb,coal_eb,k) * share_CCS_CTL(k) .. //autoconsommation de charbon dans la production de charbon pour le CTL
    - energy_balance(pwplant_eb,coal_eb,k) * sh_CCS_col_Q_col(k) .. //coal to elec
)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Primary Energy|Coal|w/o CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;

outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    energy_balance(tpes_eb,coal_eb,k) ..
    - (..
    - energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k) .. // affineries (ctl)
    - energy_balance(losses_eb,coal_eb,k) * share_CCS_CTL(k) .. // autoconsommation de charbon dans la production de charbon pour le CTL
    - energy_balance(pwplant_eb,coal_eb,k) * sh_CCS_col_Q_col(k) .. //coal to elec
    )..
)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Primary Energy|Gas'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(tpes_eb,gas_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Gas|w/ CCS'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = - energy_balance(pwplant_eb,gas_eb,k) * sh_CCS_gaz_Q_gaz(k) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Gas|w/o CCS'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=(..
    energy_balance(tpes_eb,gas_eb,k) ..
    - ( - energy_balance(pwplant_eb,gas_eb,k)) * sh_CCS_gaz_Q_gaz(k) ..
)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Geothermal'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Hydro'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(msh_elec_techno(k,technoElecHydro)./[1 1]) * Q(k,elec)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Non-Biomass Renewables'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(msh_elec_techno(k,technoNonBiomassRen)./[1 1 1 1 1 1 1]) * Q(k,elec)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Nuclear'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(tpes_eb,nuc_eb,k)*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Ocean'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Oil'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(tpes_eb,oil_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Oil|w/ CCS'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Oil|w/o CCS'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(tpes_eb,oil_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Other'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Solar'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(msh_elec_techno(k,technoSolar)./[1 1 1]) * Q(k,elec)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Wind'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(msh_elec_techno(k,technoWind)./[1 1]) * Q(k,elec)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


if ind_NLU ==0
    varname = 'Primary Energy'; //  EJ/yr
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
for var=['Non-Biomass Renewables','Biomass','Nuclear','Coal','Gas','Oil']
    lineVAR = find_index_list( list_output_str, 'Primary Energy|'+var);
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
end
end

varname = 'Resource|Extraction|Coal'; // EJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_coal)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Resource|Extraction|Gas'; //  EJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) =  Q(k,indice_gas)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Emissions|CO2'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,:))/1e6 + emi_evitee(k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|AFOLU'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|N2O'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "kt N2O/yr";
end;

varname = 'Emissions|N2O|Energy'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "kt N2O/yr";
end;

varname = 'Emissions|N2O|AFOLU'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "kt N2O/yr";
end;

varname = 'Emissions|CH4'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CH4/yr";
end;

varname = 'Emissions|CH4|Energy'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CH4/yr";
end;

varname = 'Emissions|CH4|AFOLU'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CH4/yr";
end;

varname = 'Emissions|CO2|Energy and Industrial Processes'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,:))/1e6 + emi_evitee(k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy'; //	Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,:))/1e6 + emi_evitee(k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";end;

varname = 'Emissions|CO2|Industrial Processes'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|Kyoto Gases';// |Total'; //        Mt CO2-equiv/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2-equiv/yr";
end;


varname = 'Carbon Sequestration|CCS|Fossil';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= ( ..
    + coef_Q_CO2_ref(k,coal) * (..
    - energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k) ..
    + energy_balance(pwplant_eb,elec_eb,k)* sum(msh_elec_techno(k,[indice_PSS indice_CGS])) ..
    - energy_balance(losses_eb,coal_eb,k)* share_CCS_CTL(k)..
    ) ..
    - coef_Q_CO2_ref(k,et)  * energy_balance(losses_eb,et_eb,k) * share_CCS_CTL(k) ..
    - coef_Q_CO2_ref(k,oil) * energy_balance(losses_eb,oil_eb,k) * share_CCS_CTL(k) ..
    + coef_Q_CO2_ref(k,gaz) * (..
    - energy_balance(refi_eb,   gas_eb,k) * share_CCS_CTL(k) ..
    - energy_balance(losses_eb, gas_eb,k) * share_CCS_CTL(k) ..
    + energy_balance(pwplant_eb,elec_eb,k)  * sum(msh_elec_techno(k,[indice_GGS])) ..
    ) ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS'; //   EJ/yr
lineVAR = find_index_list( list_output_str, 'Carbon Sequestration|CCS|Fossil');
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time_im+1) - emi_evitee(k,:)/1e6 ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";end;

varname = 'Carbon Sequestration|CCS|Biomass';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  - emi_evitee(k,:)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|Land Use';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|Direct Air Capture';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|Enhanced Weathering';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|Other';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Price|Carbon'; //    US$2010/t CO2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if no_output_price_carbon==%t & current_time_im < 19
    //do not output taxes correspoding to the weak policy period in budget scenarios
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = taxCO2_DF(k)*1e6*usd_year1_year2;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/t CO2";
end;

varname = 'Land Cover'; // million ha
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Built-up Area'; // million ha
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Cropland'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Forest'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Pasture'; // million haEJ/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Other Arable Land'; // million haEJ/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Other Land'; // million haEJ/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Emissions|CO2|Energy|Demand|Transportation|International Transport|International Shipping'; // MtCO2/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = CI(indice_Et,indice_mer,k)*Q(k,indice_mer)*coef_Q_CO2_CI(indice_Et,indice_mer,k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";end;

varname = 'Emissions|CO2|Energy|Demand|Transportation|International Transport|International Shipping'; // MtCH4/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";end;

varname = 'Final Energy|Transportation|International Transport|International Shipping'; // EJ/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = CI(indice_Et,indice_mer,k)*Q(k,indice_mer)*Mtoe_EJ+FE_shipping_HYD(k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Final Energy|Transportation|International Transport|International Shipping|Conventional marine fuels'; // EJ/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = CI(indice_Et,indice_mer,k)*Q(k,indice_mer)*share_convEt_Mer(k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Final Energy|Transportation|International Transport|International Shipping|Oilseed-based biofuels'; // EJ/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Final Energy|Transportation|International Transport|International Shipping|Synthetic drop-in biofuels'; // EJ/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = CI(indice_Et,indice_mer,k)*Q(k,indice_mer)*share_biofuel_Mer(k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Final Energy|Transportation|International Transport|International Shipping|Other drop-in synthetic fuels'; // EJ/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = CI(indice_Et,indice_mer,k)*Q(k,indice_mer)*share_CTL_Mer(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Final Energy|Transportation|International Transport|International Shipping|Fossil alcohol and gases'; // EJ/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Final Energy|Transportation|International Transport|International Shipping|Bio-alcohols and biogases'; // EJ/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Final Energy|Transportation|International Transport|International Shipping|Synthetic alcohols and gases'; // EJ/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Final Energy|Transportation|International Transport|International Shipping|Hydrogen and ammonia'; // EJ/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = FE_shipping_HYD(k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Final Energy|Transportation|International Transport|International Shipping|Electricity'; // EJ/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Production|Transportation|International Transport|International Shipping'; // EJ/yr 
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Index (2020 = 1)";end;

