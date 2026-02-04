// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


counterLine = counterLine_sav;

varname = 'Final Energy|Hydrogen'; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = glob_in_bioelec_Hyd_reg(k) / Exajoule2Mkcal / gjh2_2_gjbiom;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Hydrogen'; // EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = glob_in_bioelec_Hyd_reg(k) / Exajoule2Mkcal;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Hydrogen|w/ CCS'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = 0;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Hydrogen|w/o CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = glob_in_bioelec_Hyd_reg(k) / Exajoule2Mkcal;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
//NOTE : this should be w/ CCS, regarding the technology from the litterature we use.
//But the carbon rent has not been implemented in the price of h2 fuel for cars.

varname = 'Primary Energy|Biomass|Liquids'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = glob_in_bioelec_Et_reg(k) / Exajoule2Mkcal + loc_prod_agrofuel_tot_s(k).*Mkcal2Exajoule ;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Liquids|w/ CCS'; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = 0 ;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Liquids|w/o CCS'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = glob_in_bioelec_Et_reg(k) / Exajoule2Mkcal + loc_prod_agrofuel_tot_s(k).*Mkcal2Exajoule ;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Other'; //    EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Traditional'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
//outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = (reg_wood_RW_4Wdem(k) + reg_natfor_4Wdem(k) + reg_TOF(k)) .*Mkcal2Exajoule .* woodfuel_demand(k) ./ reg_net_wood_demand(k) ;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = (reg_wood_RW_4Wdem(k) + reg_natfor_4Wdem(k) + reg_TOF(k)) .*Mkcal2Exajoule;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Solids'; //   EJ/yr
lineVAR = find_index_list( list_output_str, 'Primary Energy|Biomass|Traditional');
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
if current_time==yr_start & k==1;list_output_comments(counterLine)="The use of traditional biomass as solids is not modelled in Imaclim-R, but reported consistently according to the traditional biomass produced in the Nexus Land-Use model";end;
//we assume all tradi from NLU is used into solid biomass (construction, etc)

varname = 'Final Energy|Solids'; // EJ/yr
lineVAR = find_index_list( list_output_str, 'Primary Energy|Biomass|Traditional');
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = energy_balance(conso_tot_eb,coal_eb,k)*Mtoe_EJ+outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
if current_time==yr_start & k==1;list_output_comments(counterLine)="The use of traditional biomass as solids is not modelled in Imaclim-R, but reported consistently according to the traditional biomass produced in the Nexus Land-Use model";end;

varname = 'Final Energy|Solids|Biomass'; // EJ/yr
lineVAR = find_index_list( list_output_str, 'Primary Energy|Biomass|Traditional');
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
if current_time==yr_start & k==1;list_output_comments(counterLine)="The use of traditional biomass as solids is not modelled in Imaclim-R, but reported consistently according to the traditional biomass produced in the Nexus Land-Use model";end;

varname = 'Final Energy|Solids|Biomass|Traditional'; // EJ/yr
lineVAR = find_index_list( list_output_str, 'Primary Energy|Biomass|Traditional');
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
if current_time==yr_start & k==1;list_output_comments(counterLine)="The use of traditional biomass as solids is not modelled in Imaclim-R, but reported consistently according to the traditional biomass produced in the Nexus Land-Use model";end;

varname = 'Final Energy|Other Sector|Solids'; //    EJ/yr
lineVAR = find_index_list( list_output_str, 'Primary Energy|Biomass|Traditional');
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
if current_time==yr_start & k==1;list_output_comments(counterLine)="The use of traditional biomass as solids is not modelled in Imaclim-R, but reported consistently according to the traditional biomass produced in the Nexus Land-Use model";end;

varname = 'Final Energy|Other Sector'; //   EJ/yr
lineVAR = find_index_list( list_output_str, 'Final Energy|Other Sector|Solids');
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;
if current_time==yr_start & k==1;list_output_comments(counterLine)="The use of traditional biomass as solids is not modelled in Imaclim-R, but reported consistently according to the traditional biomass produced in the Nexus Land-Use model";end;


varname = 'Final Energy|Solids|Coal'; //    EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = energy_balance(conso_tot_eb,coal_eb,k)*Mtoe_EJ;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR = find_index_list( list_output_str, 'Final Energy|Other Sector|Solids');
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = (sum(energy_balance(conso_tot_eb,:,k)))*Mtoe_EJ + outputs_temp(nbLines*(k-1)+lineVAR,current_time+1) ;
//todo: quid de qbioej§
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Secondary Energy|Solids'; // EJ/yr
lineVAR = find_index_list( list_output_str, 'Final Energy|Solids');
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;
if current_time==yr_start & k==1;list_output_comments(counterLine)="The use of traditional biomass as solids is not modelled in Imaclim-R, but reported consistently according to the traditional biomass produced in the Nexus Land-Use model";end;

varname = 'Secondary Energy|Solids|Biomass'; // EJ/yr
lineVAR = find_index_list( list_output_str, 'Final Energy|Solids|Biomass');
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;
if current_time==yr_start & k==1;list_output_comments(counterLine)="The use of traditional biomass as solids is not modelled in Imaclim-R, but reported consistently according to the traditional biomass produced in the Nexus Land-Use model";end;

varname = 'Secondary Energy|Solids|Coal'; //    EJ/yr
lineVAR = find_index_list( list_output_str, 'Final Energy|Solids|Coal');
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Secondary Energy'; //    EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR = find_index_list( list_output_str, 'Secondary Energy|Solids');
lineVAR2 = find_index_list( list_output_str, 'Secondary Energy|Gases');
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = (energy_balance(pwplant_eb,elec_eb,k)+ energy_balance(refi_eb,et_eb,k))*Mtoe_EJ +outputs_temp(nbLines*(k-1)+lineVAR,current_time+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|w/ CCS'; //   EJ/yr
lineVAR = find_index_list( list_output_str, 'Primary Energy|Biomass|Hydrogen|w/ CCS');
lineVAR1 = find_index_list( list_output_str, 'Primary Energy|Biomass|Liquids|w/ CCS');
lineVAR2 = find_index_list( list_output_str, 'Primary Energy|Biomass|Electricity|w/ CCS');
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time+1) + outputs_temp(nbLines*(k-1)+lineVAR1,current_time+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|w/o CCS'; //  EJ/yr
lineVAR = find_index_list( list_output_str, 'Primary Energy|Biomass|Hydrogen|w/o CCS');
lineVAR1 = find_index_list( list_output_str, 'Primary Energy|Biomass|Liquids|w/o CCS');
lineVAR2 = find_index_list( list_output_str, 'Primary Energy|Biomass|Electricity|w/o CCS');
lineVAR3 = find_index_list( list_output_str, 'Primary Energy|Biomass|Solids');
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time+1) + outputs_temp(nbLines*(k-1)+lineVAR1,current_time+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time+1) + outputs_temp(nbLines*(k-1)+lineVAR3,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|1st Generation'; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = loc_prod_agrofuel_tot_s(k).*Mkcal2Exajoule;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Energy Crops'; // EJ/yr
lineVAR = find_index_list( list_output_str, 'Primary Energy|Biomass|1st Generation');
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = max( Prod_energy_crops(k) - outputs_temp(nbLines*(k-1)+lineVAR,current_time+1),0);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Modern'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = Modern_bioenergy_cons(k);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Residues'; // EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = reg_wood_RW_4Ener(k).*Mkcal2Exajoule ; //Redisu for modern
//outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+counterLine,current_time+1) + reg_wood_RW_4Wdem(k) .*Mkcal2Exajoule .* woodfuel_demand(k) ./ reg_net_wood_demand(k) ; // 'Residu for tradi
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+counterLine,current_time+1) + reg_wood_RW_4Wdem(k) .*Mkcal2Exajoule ; // 'Residu for tradi
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Hydrogen'; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = glob_in_bioelec_Hyd_reg(k) / Exajoule2Mkcal / gjh2_2_gjbiom;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Hydrogen|Biomass'; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = glob_in_bioelec_Hyd_reg(k) / Exajoule2Mkcal / gjh2_2_gjbiom;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Hydrogen|Biomass|w/ CCS'; //    EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = 0;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Hydrogen|Biomass|w/o CCS'; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = glob_in_bioelec_Hyd_reg(k) / Exajoule2Mkcal / gjh2_2_gjbiom;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
//NOTE : this should be w/ CCS, regarding the technology from the litterature we use.
//But the carbon rent has not been implemented in the price of h2 fuel for cars.

varname = 'Emissions|CO2|Land Use'; //	Mt CO2/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = CO2_total_emission(k).*ton2Mton;
if current_time==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2'; //   Mt CO2/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1)= (sum(E_reg_use(k,:)) + emi_evitee(k))/1e6 + CO2_total_emission(k).*ton2Mton;
if current_time==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CH4|Land Use'; //  Mt CH4/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = CH4_tot(k);
if current_time==yr_start & k==1; list_output_unit($+1) = "Mt CH4/yr";
end;

varname = 'Emissions|CH4|Land Use|Agriculture'; //  Mt CH4/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = CH4_tot(k);
if current_time==yr_start & k==1; list_output_unit($+1) = "Mt CH4/yr";
end;

varname = 'Emissions|N2O|Land Use'; //  kt N2O/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = NO2_tot(k);
if current_time==yr_start & k==1; list_output_unit($+1) = "kt N2O/yr";
end;

varname = 'Emissions|N2O|Land Use|Agriculture'; //  kt N2O/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = NO2_tot(k);
if current_time==yr_start & k==1; list_output_unit($+1) = "kt N2O/yr";
end;

varname = 'Primary Energy|Biomass|Liquids|Cellulosic Nondiesel'; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = glob_in_bioelec_Et_reg(k) / Exajoule2Mkcal  ;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Liquids|Cellulosic Nondiesel|w/o CCS'; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = glob_in_bioelec_Et_reg(k) / Exajoule2Mkcal  ;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Liquids|Cellulosic Nondiesel|w/ CCS'; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = 0;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Primary Energy|Biomass|Liquids|Other'; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = loc_prod_agrofuel_tot_s(k).*Mkcal2Exajoule;
if current_time==yr_start & k==1;list_output_comments(counterLine)="Mixed of Biodiesel and Conventional Ethanol";end;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Liquids|Other|w/o CCS '; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = loc_prod_agrofuel_tot_s(k).*Mkcal2Exajoule;
if current_time==yr_start & k==1;list_output_comments(counterLine)="Mixed of Biodiesel and Conventional Ethanol";end;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Liquids|Other|w/ CCS '; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = 0;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|Cellulosic Nondiesel'; // EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = glob_in_bioelec_Et_reg(k) / gj2G_2_gjbiom / Exajoule2Mkcal;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|Cellulosic Nondiesel|w/o CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = glob_in_bioelec_Et_reg(k) / gj2G_2_gjbiom / Exajoule2Mkcal;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|Cellulosic Nondiesel|w/ CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = 0;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Liquids|Biodiesel'; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Liquids|Biodiesel|w/o CCS '; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Liquids|Biodiesel|w/ CCS '; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Liquids|Conventional Ethanol'; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Liquids|Conventional Ethanol|w/o CCS '; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Liquids|Conventional Ethanol|w/ CCS '; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Emissions|CH4|Land Use'; //  Mt CH4/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = CH4_tot(k);
if current_time==yr_start & k==1; list_output_unit($+1) = "Mt CH4/yr";
end;

varname = 'Emissions|N2O'; //   kt N2O/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = NO2_tot(k);
if current_time==yr_start & k==1; list_output_unit($+1) = "kt N2O/yr";
end;


varname = 'Primary Energy|Biomass|Other Feedstock'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = reg_natfor_4Ener(k).*Mkcal2Exajoule; //Other <- Managed forest
//outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+counterLine,current_time+1) + (reg_natfor_4Wdem(k) + reg_TOF(k)) .*Mkcal2Exajoule .* woodfuel_demand(k) ./ reg_net_wood_demand(k) ; //'Other
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+counterLine,current_time+1) + (reg_natfor_4Wdem(k) + reg_TOF(k)) .*Mkcal2Exajoule ; //'Other
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;



varname = 'Primary Energy|Biomass'; //   EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR = find_index_list( list_output_str, 'Primary Energy|Biomass|w/ CCS');
lineVAR1 = find_index_list( list_output_str, 'Primary Energy|Biomass|w/o CCS');
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time+1) + outputs_temp(nbLines*(k-1)+lineVAR1,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;



varname = 'Trade|Primary Energy|Biomass|Volume'; // EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = (export_ec_biom(k) - import_ec_biom(k)) * Mkcal2Exajoule + (export_liquids_biomass(k) - import_liquids_biomass(k)) * mtoe2ej * gj2G_2_gjbiom;
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Land Cover'; // million ha
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = Tot_landcover(k);
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;


varname = 'Land Cover|Built-up Area'; // million ha
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Cropland'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = (surfcrop_Dyn(k)+surfcropnonDyn(k)+surf_bioener(k)) * ha2Mha;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Cropland|Energy Crops'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = surf_bioener(k) * ha2Mha;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Cropland|Energy Crops|Irrigated'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Cropland|Irrigated'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) =  %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Forest'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = surfforest(k) * ha2Mha;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Forest|Afforestation and Reforestation'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Forest|Forestry'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Forest|Forestry|Harvested Area'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = Surf_natforest_biom(k) ;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Forest|Natural Forest'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = surfforest(k).*ha2Mha-(Surf_natforest_biom(k)+surf_plantation.*surfforest_prev(k)./sum(surfforest_prev));
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Other Natural Land'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Pasture'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = (surfP(k)+surfML(k)) * ha2Mha;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Pasture|Extensive'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = (surfP(k)) * ha2Mha;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Land Cover|Pasture|Intensive'; // million haEJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = (surfML(k)) * ha2Mha;
if current_time==yr_start & k==1; list_output_unit($+1) = "million ha";
end;

varname = 'Price|Agriculture|Corn|Index'; // Index (2005 = 1)
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "2005=1";
end;


varname = 'Price|Agriculture|Non-Energy Crops|Index'; // Index (2005 = 1)
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = pcalveg(k);
if current_time==yr_start & k==1; list_output_unit($+1) = "2005=1";
end;

varname = 'Price|Agriculture|Soybean|Index'; // Index (2005 = 1)
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "2005=1";
end;

varname = 'Price|Agriculture|Wheat|Index'; // Index (2005 = 1)
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "2005=1";
end;


varname = 'Agricultural Production|Livestock|Extensive'; // Mt meat
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = prod_rumi_ext(k) * Mkcal2Gigajoule./hhv_biomass.*ton2Mton;
if current_time==yr_start & k==1; list_output_unit($+1) = "Mt meat";
end;

varname = 'Agricultural Production|Livestock|Extensive|Stocking Rate'; // AU/ha
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "AU/ha";
end;

varname = 'Agricultural Production|Livestock|Intensive'; // Mt meat
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = prod_rumi_ML(k) * Mkcal2Gigajoule./hhv_biomass.*ton2Mton;
if current_time==yr_start & k==1; list_output_unit($+1) = "Mt meat";
end;

varname = 'Agricultural Production|Livestock|Intensive|Stocking Rate'; // AU/ha
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "AU/ha";
end;

varname = 'Water|Withdrawal|Irrigation'; // million m3/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = %nan;
if current_time==yr_start & k==1; list_output_unit($+1) = "million m3/yr";
end;

varname = 'Yield|cereal'; // t DM/ha/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = yield_Dyn(k) * Mkcal2Gigajoule./hhv_biomass;
if current_time==yr_start & k==1; list_output_unit($+1) = "t DM/ha/yr";
end;


varname = 'Primary Energy'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = 0;
for vary = ['Coal','Oil','Gas','Hydro','Nuclear','Solar','Wind','Biomass']
    lineVAR = find_index_list( list_output_str, 'Primary Energy|' + vary);
    outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+counterLine,current_time+1) + outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
end
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


//rebalancing mass flow from NLU over total primary biomass usage of Imaclim if NLU crashed
//no consistency on primary 1G but who cares..
ind_total_biom = find_index_list( list_output_str, 'Primary Energy|Biomass');
if real_failed
    // rebalancing ener usage (not other feedstock)
    tot_1gEnercropsRedisuesO = 0;
    lineVAR_otherfeed = find_index_list( list_output_str, 'Primary Energy|Biomass|Other Feedstock');
    lineVAR_resi = find_index_list( list_output_str, 'Primary Energy|Biomass|Residues');
    residu_old_temp = outputs_temp(nbLines*(k-1)+lineVAR_resi,current_time+1) ;
    for vary = ['Primary Energy|Biomass|1st Generation', 'Primary Energy|Biomass|Energy Crops', 'Primary Energy|Biomass|Residues']
        lineVAR = find_index_list( list_output_str, vary);
        tot_1gEnercropsRedisuesO = tot_1gEnercropsRedisuesO + outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
    end
    for vary = ['Primary Energy|Biomass|1st Generation', 'Primary Energy|Biomass|Energy Crops', 'Primary Energy|Biomass|Residues']
        lineVAR = find_index_list( list_output_str, vary);
        outputs_temp(nbLines*(k-1)+lineVAR,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time+1) ./ tot_1gEnercropsRedisuesO .* (outputs_temp(nbLines*(k-1)+ind_total_biom,current_time+1) - outputs_temp(nbLines*(k-1)+lineVAR_otherfeed,current_time+1) );
    end

    //remove redisue shrink from Traditional
    lineVAR_tradi = find_index_list( list_output_str, 'Primary Energy|Biomass|Traditional');
    outputs_temp(nbLines*(k-1)+lineVAR_tradi,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR_tradi,current_time+1) - residu_old_temp + outputs_temp(nbLines*(k-1)+lineVAR_resi,current_time+1);
    // remove the rest from Modern
    tot_TradModern = 0;
    for vary = ['Primary Energy|Biomass|Traditional', 'Primary Energy|Biomass|Modern']
        lineVAR = find_index_list( list_output_str, vary); 
        tot_TradModern = tot_TradModern + outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
    end
    lineVAR_modern = find_index_list( list_output_str, 'Primary Energy|Biomass|Modern');
    outputs_temp(nbLines*(k-1)+lineVAR_modern,current_time+1) = outputs_temp(nbLines*(k-1)+ind_total_biom,current_time+1) - outputs_temp(nbLines*(k-1)+lineVAR_tradi,current_time+1);

    // propagate correction
    lineVARref = find_index_list( list_output_str, 'Primary Energy|Biomass|1st Generation');
    lineVAR1 = find_index_list( list_output_str, 'Primary Energy|Biomass|Liquids|Other');
    // for some reason (scilab?) the following doesn't work, lineVAR2 is hardcoded
    lineVAR2 = find_index_list( list_output_str, 'Primary Energy|Biomass|Liquids|Other|w/o CCS');
    outputs_temp(nbLines*(k-1)+lineVAR1,current_time+1) = outputs_temp(nbLines*(k-1)+lineVARref,current_time+1);
    outputs_temp(nbLines*(k-1)+492,current_time+1) = outputs_temp(nbLines*(k-1)+lineVARref,current_time+1);
end


// outputs Imaclim drivers for NLU
// usefull to run NLU without running Imaclim
// will be only present in full output file.
counter_NLU = 0;
varname_driver = 'Imaclim2NLU|Price|Carbon';
if current_time==yr_start & k==1; list_output_str($+1) = varname_driver; end;
outputs_temp(nbLines*13+counter_NLU*12+k,current_time+1) = reg_taxeC(k);
if current_time==yr_start & k==1; list_output_unit($+1) = "$/tCO2";
end;

counter_NLU = counter_NLU +1;
varname_driver = 'Imaclim2NLU|Added_Value|Price|Agriculture';
if current_time==yr_start & k==1; list_output_str($+1) = varname_driver; end;
outputs_temp(nbLines*13+counter_NLU*12+k,current_time+1) = va_agri(k) * usd2001_2005;
if current_time==yr_start & k==1; list_output_unit($+1) = "billion US$2005/yr";
end;

counter_NLU = counter_NLU +1;
varname_driver = 'Imaclim2NLU|Population';
if current_time==yr_start & k==1; list_output_str($+1) = varname_driver; end;
outputs_temp(nbLines*13+counter_NLU*12+k,current_time+1) = pop(k) ;
if current_time==yr_start & k==1; list_output_unit($+1) = "million";
end;

counter_NLU = counter_NLU +1;
varname_driver = 'Imaclim2NLU|Primary Energy|Biomass';
if current_time==yr_start & k==1; list_output_str($+1) = varname_driver; end;
outputs_temp(nbLines*13+counter_NLU*12+k,current_time+1) = reg_in_bioelec(k) ;
if current_time==yr_start & k==1; list_output_unit($+1) = "Mkcal/yr";
end;

