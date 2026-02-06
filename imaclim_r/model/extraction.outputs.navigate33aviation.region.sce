// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


counterLine = 0 ;


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

varname = 'Final Energy|Gases'; //EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(conso_tot_eb,gas_eb,k)*Mtoe_EJ ;
//todo: needs to be updated with H?
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Industry'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_indu_eb,:,k))+sum(energy_balance(conso_agri_eb,:,k))+sum(energy_balance(conso_btp_eb,:,k)))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Final Energy|Liquids'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(conso_tot_eb,et_eb,k)*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Solar'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; // this is heat produced by solar. We don't have it.
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,:,k))+sum(energy_balance(conso_comp_eb,:,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_transport_eb,:,k)))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other Sector'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Final Energy|Non-Energy Use'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Hydrogen'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Hydrogen'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Price|Primary Energy|Biomass'; //   US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_NLU >0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = bioener_costs_Farmgate(k) * usd_year1_year2; //todo
else
    if sum(prod_elec_techno(k,technoBiomass)) + prod_BFU(k)==0
        outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
    else
        qBiom = sum((msh_elec_techno(k,technoBiomassWOCCS) ./ rho_elec_nexus(k,technoBiomassWOCCS)) ..
            + msh_elec_techno(k,indice_BIS) / rho_elec_nexus(k,indice_BIS))..
        * energy_balance(pwplant_eb,8,k);
        outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=(prod_BFU(k) *  p(k,et) + costBIGCC_noTax(k) * qBiom) * usd_year1_year2 / tep2gj ..
        /(qBiom + prod_BFU(k));
    end
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";end;

varname = 'Price|Primary Energy|Oil'; //    US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = p(k,indice_oil)*usd_year1_year2/tep2gj;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";
end;

varname = 'Price|Secondary Energy|Electricity'; //  US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = pArmCI(indice_elec,indice_industries,k)*usd_year1_year2/tep2gj;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";
end;

varname = 'Price|Secondary Energy|Hydrogen'; //  US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = pArmCI(indice_elec,indice_industries,k)*usd_year1_year2/tep2gj;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";
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
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

//from doi:10.1016/j.biombioe.2008.04.005
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

if ind_NLU ==0
    varname = 'Primary Energy'; //  EJ/yr
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(tpes_eb,primary_eb,k)))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;
end

if ind_climat > 2 & ind_climat <>99

    varname = 'Policy Cost|Area under MAC Curve';
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;

varname = 'Policy Cost|Consumption Loss';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ( sum(DF(k,:).*pArmDF(k,:)) - sum(base_DF(k,:,current_time_im+1) .* base_pArmDF(k,:,current_time_im+1)))/1e3*usd_year1_year2;

varname = 'Policy Cost|Additional Total Energy System Cost';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energyInvestment(k) - energyInvestment_base(k,current_time_im+1)) / 1e3 * usd_year1_year2;

else

    varname_temp = 'Policy Cost|Area under MAC Curve';
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;

varname_temp = 'Policy Cost|Consumption Loss';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;

varname_temp = 'Policy Cost|Additional Total Energy System Cost';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;

end


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

varname = 'Emissions|CO2|Energy'; //	Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,:))/1e6 + emi_evitee(k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";end;

varname = 'Emissions|CO2|Industrial Processes'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Supply'; // Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,iu_ener))/1e6 + emi_evitee(k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Supply|Electricity'; // Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= E_reg_use(k,iu_elec)/1e6 + emi_evitee(k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Demand'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,iu_non_ener))/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Demand|Industry'; //
//Includes Agriculture
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (E_reg_use(k,iu_indu) + E_reg_use(k,iu_agri)+E_reg_use(k,iu_cons))/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;


varname = 'Emissions|CO2|Energy|Demand|Residential and Commercial'; //
//We do not use E_reg_use(iu_DF) because DF includes cars and residential
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + coef_Q_CO2_DF(k,coal)       .* energy_balance(conso_resid_eb,coal_eb,k) ..
    + coef_Q_CO2_DF(k,oil)        .* energy_balance(conso_resid_eb,oil_eb,k)  ..
    + coef_Q_CO2_DF(k,gaz)        .* energy_balance(conso_resid_eb,gas_eb,k)  ..
    + coef_Q_CO2_DF(k,et)         .* energy_balance(conso_resid_eb,et_eb,k)   ..
    + coef_Q_CO2_CI(coal,compo,k) .* energy_balance(conso_comp_eb, coal_eb,k) ..
    + coef_Q_CO2_CI(oil,compo,k)  .* energy_balance(conso_comp_eb, oil_eb,k) ..
    + coef_Q_CO2_CI(gaz,compo,k)  .* energy_balance(conso_comp_eb, gas_eb,k)  ..
    + coef_Q_CO2_CI(et,compo,k)   .* energy_balance(conso_comp_eb, et_eb,k)   ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Demand|Transportation'; //
//We do not use E_reg_use(iu_DF) because DF includes cars and residential
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + coef_Q_CO2_DF(k,coal).* energy_balance(conso_car_eb,coal_eb,k) ..
    + coef_Q_CO2_DF(k,oil) .* energy_balance(conso_car_eb,oil_eb,k)  ..
    + coef_Q_CO2_DF(k,gaz) .* energy_balance(conso_car_eb,gas_eb,k)  ..
    + coef_Q_CO2_DF(k,et)  .* energy_balance(conso_car_eb,et_eb,k)   ..
    + E_reg_use(k,iu_air) ..
    + E_reg_use(k,iu_mer) ..
    + E_reg_use(k,iu_OT)  ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Demand|AFOFI'; //
//Autre secteur : construction (btp)
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Demand|Other Sector'; //
//Autre secteur : construction (btp)
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
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

varname = 'Carbon Sequestration|CCS|Fossil|Supply';
lineVAR = find_index_list( list_output_str,'Carbon Sequestration|CCS|Fossil');
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";end;


varname = 'Carbon Sequestration|CCS|Fossil|Supply|Electricity';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= ( ..
    + coef_Q_CO2_ref(k,coal) * (..
    + energy_balance(pwplant_eb,elec_eb,k)* sum(msh_elec_techno(k,[indice_PSS indice_CGS])) ..
    ) ..
    + coef_Q_CO2_ref(k,gaz) * (..
    + energy_balance(pwplant_eb,elec_eb,k)  * sum(msh_elec_techno(k,[indice_GGS])) ..
    ) ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Fossil|Supply|Liquids';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= ( ..
    + coef_Q_CO2_ref(k,coal) * (..
    - energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k) ..
    - energy_balance(losses_eb,coal_eb,k)* share_CCS_CTL(k)..
    ) ..
    - coef_Q_CO2_ref(k,et)  * energy_balance(losses_eb,et_eb,k) * share_CCS_CTL(k) ..
    - coef_Q_CO2_ref(k,oil) * energy_balance(losses_eb,oil_eb,k) * share_CCS_CTL(k) ..
    + coef_Q_CO2_ref(k,gaz) * (..
    - energy_balance(refi_eb,   gas_eb,k) * share_CCS_CTL(k) ..
    - energy_balance(losses_eb, gas_eb,k) * share_CCS_CTL(k) ..
    ) ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Fossil|Energy|Supply|Gases';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Fossil|Energy|Supply|Hydrogen';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Fossil|Energy|Supply|Other';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Fossil|Energy|Demand|Industry';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=0;
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

varname = 'Carbon Sequestration|CCS|Biomass|Energy|Supply';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  - emi_evitee(k,:)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Biomass|Energy|Supply|Electricity';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  - emi_evitee(k,:)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Biomass|Energy|Supply|Gases';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Biomass|Energy|Supply|Hydrogen';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Biomass|Energy|Supply|Liquids';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Biomass|Energy|Supply|Other';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Biomass|Energy|Demand|Industry';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;


varname = 'Carbon Sequestration|CCS|Industrial Processes'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|Land Use';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|Land Use|Afforestation';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|Land Use|Biochar';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|Land Use|Soil Carbon Management';
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


varname = 'Emissions|CO2|Transportation|Aviation'; //
//We do not use E_reg_use(iu_DF) because DF includes cars and residential
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + E_reg_use(k,iu_air) ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Final Energy|Aviation|Kerosene';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= CI(indice_Et,indice_air,k)*Q(k,indice_air)*share_convEt_Air(k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Final Energy|Aviation|Biokerosen';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  CI(indice_Et,indice_air,k)*Q(k,indice_air)*share_biofuel_Air(k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Final Energy|Aviation|Synkerosene';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= CI(indice_Et,indice_air,k)*Q(k,indice_air)*share_CTL_Air(k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Final Energy|Aviation|Electricity';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;


varname = 'Price|Final Energy|Aviation|Kerosene';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";end;

varname = 'Price|Final Energy|Aviation|Bioerosene';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";end;

varname = 'Price|Final Energy|Aviation|Synkerosene';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";end;

varname = 'Price|Final Energy|Aviation|Hydrogen';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";end;

varname = 'Price|Final Energy|Aviation|Electricity';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";end;

varname = 'Investment|Transportation|Aviation';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (pK(k,indice_air).*DeltaK(k,indice_air) )*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Investment|Transportation|Aviation|Planes';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Investment|Transportation|Aviation|Planes|Hydrogen';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Investment|Transportation|Aviation|Planes|Electricity';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Energy Service|Transportation|Aviation'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = pkm_air_all_sc(k,1) * pkm_air_inc(k) / 1e9;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";end;
