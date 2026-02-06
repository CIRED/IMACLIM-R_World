// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Thomas Le Gallic, Gabriele Dabbaghian
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


counterLine = 0 ;

varname = 'Capacity|Electricity'; // GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,:))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;//1283

varname = 'Capacity|Electricity|Biomass'; // '  GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoBiomass))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Biomass|w/ CCS'; // '  GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,indice_BIS))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Biomass|w/o CCS'; // '  GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,indice_BIG))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Coal'; // GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoElecCoal))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Coal|w/ CCS'; // GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoCoalWCCS))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Coal|w/o CCS'; // GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoCoalWOCCS))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Gas'; //GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoElecGas))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Gas|w/o CCS'; //GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoGasWOCCS))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Gas|w/ CCS'; //GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoGasWCCS))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Geothermal'; //GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Hydro'; //GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoElecHydro))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Nuclear'; //  GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoNuke))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Oil'; //  GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoOil))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Other'; //GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Solar'; //GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoSolar))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Solar|CSP'; //GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Cap_elec_MW(k,indice_CSP)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Solar|PV'; // GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoPV))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Wind'; // GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoWind))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Wind|Onshore'; // GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Wind|Offshore'; //GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //Cap_elec_MW(k,indice_WNO)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

// CAPITAL COSTS ELECTRICITY

varname = 'Capital Cost|Electricity|Coal|w/ CCS'; // $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( CINV_MW_nexus(k,technoCoalWCCS) .* Inv_MW(k,technoCoalWCCS));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( CINV_MW_nexus(k,technoCoalWCCS) .* Inv_MW(k,technoCoalWCCS) .* temp_not_nans ) , sum(Inv_MW(k,technoCoalWCCS).* temp_not_nans) ,0) * usd_year1_year2 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have two technologies, we reported the average weighted by the current investment level in each: Integrated Coal Gasification with Combined Cycle with sequestration; Super Critical pulverised coal with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";end;

varname = 'Capital Cost|Electricity|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( CINV_MW_nexus(k,technoCoalWOCCS) .* Inv_MW(k,technoCoalWOCCS));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( CINV_MW_nexus(k, technoCoalWOCCS) .* Inv_MW(k,technoCoalWOCCS).* temp_not_nans ) , sum(Inv_MW(k,technoCoalWOCCS).* temp_not_nans), 0) * usd_year1_year2 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have two technologies, we reported the average weighted by the current investment level in each: Integrated Coal Gasification with Combined Cycle; Super Critical pulverised coal; Lignite-powered Conventional Thermal; Coal-powered Conventional Thermal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";end;


varname = 'Capital Cost|Electricity|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( CINV_MW_nexus(k,technoGasWOCCS) .* Inv_MW(k,technoGasWOCCS));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( CINV_MW_nexus(k, technoGasWOCCS) .* Inv_MW(k,technoGasWOCCS).* temp_not_nans ) , sum(Inv_MW(k,technoGasWOCCS).* temp_not_nans) ,0) * usd_year1_year2 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have three technologies, we reported the average weighted by the current investment level in each: Gas-powered Gas Turbine in Combined Cycle; Gas-powered Gas Turbine TAC; Gas-powered Conventional Thermal TAV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";end;

varname = 'Capital Cost|Electricity|Nuclear'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( CINV_MW_nexus(k,technoNuke) .* Inv_MW(k,technoNuke));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( CINV_MW_nexus(k,technoNuke) .* Inv_MW(k,technoNuke).* temp_not_nans ) , sum(Inv_MW(k,technoNuke).* temp_not_nans), 0) * usd_year1_year2 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have two technologies, we reported the average weighted by the current investment level in each: Conventional Light-Water nuclear Reactor; New Nuclear Design";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";end;

varname = 'Capital Cost|Electricity|Solar|PV'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( CINV_MW_nexus(k,technoPV) .* Inv_MW(k,technoPV));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( CINV_MW_nexus(k, technoPV) .* Inv_MW(k,technoPV).*temp_not_nans ) , sum(Inv_MW(k,technoPV).*temp_not_nans),0) * usd_year1_year2 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have two technologies, we reported the average weighted by the current investment level in each: Central PV; Rooftop PV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";end;

varname = 'Capital Cost|Electricity|Hydro'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( CINV_MW_nexus(k,technoElecHydro) .* Inv_MW(k,technoElecHydro));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( CINV_MW_nexus(k, technoElecHydro) .* Inv_MW(k,technoElecHydro).*temp_not_nans ) , sum(Inv_MW(k,technoElecHydro).*temp_not_nans),0) * usd_year1_year2 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have two technologies, we reported the average weighted by the current investment level in each: Conventional, large-size hydroelectricity; Small HydroelectricityGas-powered Gas Turbine in Combined Cycle; Gas-powered Gas Turbine TAC; Gas-powered Conventional Thermal TAV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";end;

varname = 'Capital Cost|Electricity|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_GGS) * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine in Combined Cycle with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";end;

varname = 'Capital Cost|Electricity|Geothermal'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";end;

varname = 'Capital Cost|Electricity|Solar|CSP'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_CSP)  * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Concentrated solar power";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";end;

varname = 'Capital Cost|Electricity|Wind|Offshore'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_WNO) * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Offshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";end;

// A problem here, check the values
varname = 'Capital Cost|Electricity|Wind|Onshore'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //CINV_MW_nexus(k,indice_WND) * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Onshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";end;

varname = 'Capital Cost|Electricity|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_BIS) * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants with CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";end;

varname = 'Capital Cost|Electricity|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_BIG) * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants without CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";end;


// Efficiency ELECTRICITY

varname = 'Efficiency|Electricity|Coal|w/ CCS'; // $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( rho_elec_nexus(k,technoCoalWCCS) .* Inv_MW(k,technoCoalWCCS));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( rho_elec_nexus(k, technoCoalWCCS) .* Inv_MW(k,technoCoalWCCS).*temp_not_nans ) , sum(Inv_MW(k,technoCoalWCCS).*temp_not_nans), 0) * 100;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have two technologies, we reported the average weighted by the current investment level in each: Integrated Coal Gasification with Combined Cycle with sequestration; Super Critical pulverised coal with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;

varname = 'Efficiency|Electricity|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( rho_elec_nexus(k,technoCoalWOCCS) .* Inv_MW(k,technoCoalWOCCS));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( rho_elec_nexus(k, technoCoalWOCCS) .* Inv_MW(k,technoCoalWOCCS).*temp_not_nans ) , sum(Inv_MW(k,technoCoalWOCCS).*temp_not_nans), 0) * 100;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have two technologies, we reported the average weighted by the current investment level in each: Integrated Coal Gasification with Combined Cycle; Super Critical pulverised coal; Lignite-powered Conventional Thermal; Coal-powered Conventional Thermal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;

varname = 'Efficiency|Electricity|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( rho_elec_nexus(k,technoGasWOCCS) .* Inv_MW(k,technoGasWOCCS));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( rho_elec_nexus(k, technoGasWOCCS) .* Inv_MW(k,technoGasWOCCS).*temp_not_nans ) , sum(Inv_MW(k,technoGasWOCCS).*temp_not_nans), 0) * 100;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have three technologies, we reported the average weighted by the current investment level in each: Gas-powered Gas Turbine in Combined Cycle; Gas-powered Gas Turbine TAC; Gas-powered Conventional Thermal TAV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;

varname = 'Efficiency|Electricity|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_GGS) * 100;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine in Combined Cycle with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;

varname = 'Efficiency|Electricity|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_BIS) * 100;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants with CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Efficiency|Electricity|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_BIG) * 100;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants without CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;


// OM Cost|Fixed ELECTRICITY
varname = 'OM Cost|Fixed|Electricity|Coal|w/ CCS'; // $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( OM_cost_fixed_nexus(k,technoCoalWCCS) .* Inv_MW(k,technoCoalWCCS));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( OM_cost_fixed_nexus(k, technoCoalWCCS) .* Inv_MW(k,technoCoalWCCS).*temp_not_nans ) , sum(Inv_MW(k,technoCoalWCCS).*temp_not_nans) ,0) * usd_year1_year2 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have two technologies, we reported the average weighted by the current investment level in each: Integrated Coal Gasification with Combined Cycle with sequestration; Super Critical pulverised coal with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";end;

varname = 'OM Cost|Fixed|Electricity|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( OM_cost_fixed_nexus(k,technoCoalWOCCS) .* Inv_MW(k,technoCoalWOCCS));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( OM_cost_fixed_nexus(k, technoCoalWOCCS) .* Inv_MW(k,technoCoalWOCCS).*temp_not_nans ) , sum(Inv_MW(k,technoCoalWOCCS).*temp_not_nans) ,0) * usd_year1_year2 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have two technologies, we reported the average weighted by the current investment level in each: Integrated Coal Gasification with Combined Cycle; Super Critical pulverised coal; Lignite-powered Conventional Thermal; Coal-powered Conventional Thermal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";end;

varname = 'OM Cost|Fixed|Electricity|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( OM_cost_fixed_nexus(k,technoGasWOCCS) .* Inv_MW(k,technoGasWOCCS));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( OM_cost_fixed_nexus(k, technoGasWOCCS) .* Inv_MW(k,technoGasWOCCS).*temp_not_nans ) , sum(Inv_MW(k,technoGasWOCCS).*temp_not_nans) ,0) * usd_year1_year2 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have three technologies, we reported the average weighted by the current investment level in each: Gas-powered Gas Turbine in Combined Cycle; Gas-powered Gas Turbine TAC; Gas-powered Conventional Thermal TAV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";end;

varname = 'OM Cost|Fixed|Electricity|Nuclear'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( OM_cost_fixed_nexus(k,technoNuke) .* Inv_MW(k,technoNuke));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( OM_cost_fixed_nexus(k, technoNuke) .* Inv_MW(k,technoNuke).*temp_not_nans ) , sum(Inv_MW(k,technoNuke).*temp_not_nans) ,0) * usd_year1_year2 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have two technologies, we reported the average weighted by the current investment level in each: Conventional Light-Water nuclear Reactor; New Nuclear Design";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";end;

varname = 'OM Cost|Fixed|Electricity|Solar|PV'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( OM_cost_fixed_nexus(k,technoPV) .* Inv_MW(k,technoPV));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( OM_cost_fixed_nexus(k, technoPV) .* Inv_MW(k,technoPV).*temp_not_nans ) , sum(Inv_MW(k,technoPV).*temp_not_nans) ,0) * usd_year1_year2 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have two technologies, we reported the average weighted by the current investment level in each: Central PV; Rooftop PV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";end;

varname = 'OM Cost|Fixed|Electricity|Hydro'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
temp_not_nans = ~isnan( OM_cost_fixed_nexus(k,technoElecHydro) .* Inv_MW(k,technoElecHydro));
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = divide( sum( OM_cost_fixed_nexus(k, technoElecHydro) .* Inv_MW(k,technoElecHydro).*temp_not_nans ) , sum(Inv_MW(k,technoElecHydro).*temp_not_nans) ,0) * usd_year1_year2 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Our model have two technologies, we reported the average weighted by the current investment level in each: Conventional, large-size hydroelectricity; Small HydroelectricityGas-powered Gas Turbine in Combined Cycle; Gas-powered Gas Turbine TAC; Gas-powered Conventional Thermal TAV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";end;

varname = 'OM Cost|Fixed|Electricity|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_GGS) * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine in Combined Cycle with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";end;


varname = 'OM Cost|Fixed|Electricity|Geothermal'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Solar|CSP'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_CSP)  * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Concentrated solar power";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Wind|Offshore'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_WNO) * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Offshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

// a problem here, check the values of OM_cost_fixed_nexus(k,indice_WND)
varname = 'OM Cost|Fixed|Electricity|Wind|Onshore'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;//OM_cost_fixed_nexus(k,indice_WND) * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Onshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_BIS) * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants with CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_BIG) * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants without CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'Capital Cost|Gases|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Capital Cost|Gases|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Capital Cost|Gases|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Capital Cost|Gases|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Capital Cost|Hydrogen|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Capital Cost|Hydrogen|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Capital Cost|Hydrogen|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Capital Cost|Hydrogen|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Capital Cost|Hydrogen|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Capital Cost|Hydrogen|Electricity'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Capital Cost|Liquids|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Capital Cost|Liquids|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Capital Cost|Liquids|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Capital Cost|Liquids|Oil'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = pK(k,indice_Et) *8760* usd_year1_year2 / tep2gj * kwh2gj; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Capital Cost|Liquids|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_NLU >0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ethan2G_inv *usd_year1_year2;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
end
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Cellulosic Nondiesel fuels";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Efficiency|Liquids|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_NLU >0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Hoowijk_2000_efficiency; //todo
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
end
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Cellulosic Nondiesel fuels";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'OM Cost|Fixed|Liquids|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_NLU >0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Hoowijk_2000_OM_percent * ethan2G_inv*usd_year1_year2; //todo
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
end
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Cellulosic Nondiesel fuels";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'Capital Cost|Liquids|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;
varname = 'Efficiency|Liquids|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;


varname = 'Capital Cost|Hydrogen|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if (ind_NLU > 0 & ind_hydrogen > 0)
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = h2_gaseif_annualInv * kwh2gj * 8760 *usd_year1_year2;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;

varname = 'Efficiency|Hydrogen|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if (ind_NLU > 0 & ind_hydrogen > 0)
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 1 ./ gjh2_2_gjbiom; //todo
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'OM Cost|Fixed|Hydrogen|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if (ind_NLU > 0 & ind_hydrogen > 0)
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (h2_gaseif_maintenance-h2_gaseif_emission*h2_gaseif_captureCosts)*kwh2gj * 8760 *usd_year1_year2; //todo
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

cost_CTL_OM=cost_CTL_OMref*(sum(Cost_struc_oil_refin_ref(k,elec:sec).*(pArmCI(elec:sec,indice_Et,k)')))./(sum(Cost_struc_oil_refin_ref(k,elec:sec).*(pArmCIref(elec:sec,indice_Et,k)')));
cost_CTL_capital=cost_CTL_capitalref*pK(k,et)./pKref(k,et);
varname = 'Capital Cost|Liquids|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = cost_CTL_capital*8760/tep2kwh*usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW";
end;
varname = 'Efficiency|Liquids|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = yield_CTL*100; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;
varname = 'OM Cost|Fixed|Liquids|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = cost_CTL_OM*8760/tep2kwh*usd_year1_year2; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;


// Efficiency Others
varname = 'Efficiency|Gases|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Efficiency|Gases|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Efficiency|Gases|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Efficiency|Gases|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Efficiency|Hydrogen|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Efficiency|Hydrogen|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Efficiency|Hydrogen|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Efficiency|Hydrogen|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Efficiency|Hydrogen|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Efficiency|Hydrogen|Electricity'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Efficiency|Liquids|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;


varname = 'Efficiency|Liquids|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Efficiency|Liquids|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Efficiency|Liquids|Oil'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 1 ./mean(Cost_struc_oil_refin_ref( Cost_struc_oil_refin_ref( :,indice_oil)>1,indice_oil)) * 100; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

// OMfixed others
varname = 'OM Cost|Fixed|Gases|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Gases|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Gases|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Gases|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Hydrogen|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Hydrogen|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Hydrogen|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Hydrogen|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Hydrogen|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Hydrogen|Electricity'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Liquids|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Liquids|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Liquids|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'OM Cost|Fixed|Liquids|Oil'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/kW/yr";
end;

varname = 'Final Energy|Electricity'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_tot_eb,elec_eb,k)*Mtoe_EJ-sum(energy_balance(marbunk_eb,elec_eb,k))*Mtoe_EJ) * (1+ratio_ener_autocons(k,indice_elec));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Gases'; //EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(conso_tot_eb,gas_eb,k)*Mtoe_EJ -sum(energy_balance(marbunk_eb,gas_eb,k))*Mtoe_EJ;
//todo: needs to be updated with H?
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Geothermal'; //EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Heat'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Industry'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_indu_eb,:,k))+sum(energy_balance(conso_agri_eb,:,k))+sum(energy_balance(conso_btp_eb,:,k)))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Industry|Electricity'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_indu_eb,elec_eb,k)+energy_balance(conso_agri_eb,elec_eb,k)+energy_balance(conso_btp_eb,elec_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Industry|Gases'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_indu_eb,gas_eb,k)+energy_balance(conso_agri_eb,gas_eb,k)+energy_balance(conso_btp_eb,gas_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Industry|Heat'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Industry|Hydrogen'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Industry|Liquids'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_indu_eb,oil_eb,k)+energy_balance(conso_indu_eb,et_eb,k) ..
+ energy_balance(conso_agri_eb,oil_eb,k) + energy_balance(conso_agri_eb,et_eb,k) + energy_balance(conso_btp_eb,oil_eb,k) + energy_balance(conso_btp_eb,et_eb,k)  )*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Industry|Other'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Industry|Solids'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_indu_eb,coal_eb,k)+energy_balance(conso_agri_eb,coal_eb,k)+energy_balance(conso_btp_eb,coal_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Industry|Solids|Biomass'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Industry|Solids|Fossil'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_indu_eb,coal_eb,k)+energy_balance(conso_agri_eb,coal_eb,k)+energy_balance(conso_btp_eb,coal_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Liquids'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_tot_eb,et_eb,k)*Mtoe_EJ + energy_balance(conso_tot_eb,oil_eb,k)*Mtoe_EJ -sum(energy_balance(marbunk_eb,[et_eb,oil_eb],k))*Mtoe_EJ) * (1+ratio_ener_autocons(k,indice_Et));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Solids'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(conso_tot_eb,coal_eb,k)*Mtoe_EJ + Traditional_biomass_EJ(k)-sum(energy_balance(marbunk_eb,coal_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial'; // EJ/yr 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,:,k)))*Mtoe_EJ + (sum(energy_balance(conso_comp_eb,:,k)))*Mtoe_EJ + Traditional_biomass_EJ(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Final Energy|Residential'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,:,k)))*Mtoe_EJ + Traditional_biomass_EJ(k) ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential|Electricity'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,elec_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential|Gases'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,gas_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential|Heat'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential|Hydrogen'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential|Liquids'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,et_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Final Energy|Residential|Liquids|Fossil'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,et_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;															 
varname = 'Final Energy|Residential|Other'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential|Solids'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,coal_eb,k)))*Mtoe_EJ + Traditional_biomass_EJ(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential|Solids|Biomass'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Traditional_biomass_EJ(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential|Solids|Biomass|Traditional'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Traditional_biomass_EJ(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential|Solids|Fossil'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,coal_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential|Heating|Space'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Commercial'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,:,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Commercial|Electricity'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,elec_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Commercial|Gases'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,gas_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Commercial|Heat'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Commercial|Hydrogen'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Commercial|Liquids'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,et_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Final Energy|Commercial|Liquids|Fossil'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,et_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;															
varname = 'Final Energy|Commercial|Other'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Commercial|Solids'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,coal_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Commercial|Solids|Biomass'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Commercial|Solids|Fossil'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,coal_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Commercial|Heating|Space'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Final Energy|Residential and Commercial|Electricity'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,elec_eb,k)))*Mtoe_EJ +(sum(energy_balance(conso_comp_eb,elec_eb,k)))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Gases'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,gas_eb,k)))*Mtoe_EJ +(sum(energy_balance(conso_comp_eb,gas_eb,k)))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Heat'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Hydrogen'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Liquids'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,et_eb,k)))*Mtoe_EJ + (sum(energy_balance(conso_comp_eb,et_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Liquids|Fossil'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,et_eb,k)))*Mtoe_EJ + (sum(energy_balance(conso_comp_eb,et_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Other'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Solids'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,coal_eb,k)))*Mtoe_EJ + (sum(energy_balance(conso_comp_eb,coal_eb,k)))*Mtoe_EJ + Traditional_biomass_EJ(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Solids|Biomass'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Traditional_biomass_EJ(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Solids|Biomass|Traditional'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Traditional_biomass_EJ(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Solids|Fossil'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,coal_eb,k)))*Mtoe_EJ  + (sum(energy_balance(conso_comp_eb,coal_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;										  
varname = 'Final Energy|Residential and Commercial|Heating|Space'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Solar'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; // this is heat produced by solar. We don't have it.
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;





// Final energy in transportation. We have a bottom-up approach, from the most detailed variables to the most aggregated, and try to use sums as often as possible

varname = 'Final Energy|Transportation|Passenger|LDV|Electricity'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    energy_balance(conso_car_eb,elec_eb,k)..
) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger|LDV|Hydrogen'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger|LDV|Liquids'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    energy_balance(conso_car_eb,et_eb,k)..
) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger|LDV'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    energy_balance(conso_car_eb,et_eb,k)+energy_balance(conso_car_eb,elec_eb,k)..
) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Final Energy|Transportation|Passenger|Rail|Electricity'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    alpharail_passenger(k,indice_elec)	*EnergyServices_rail_pass(k) ..
)* Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";list_output_comments(counterLine)="Beta version";
end;

varname = 'Final Energy|Transportation|Passenger|Rail|Gases'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    alpharail_passenger(k,indice_gas)	*EnergyServices_rail_pass(k) ..
)* Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";list_output_comments(counterLine)="Beta version";
end;

varname = 'Final Energy|Transportation|Passenger|Rail|Hydrogen'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger|Rail|Liquids'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    alpharail_passenger(k,indice_Et)	*EnergyServices_rail_pass(k) ..
)* Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";list_output_comments(counterLine)="Beta version";
end;

varname = 'Final Energy|Transportation|Passenger|Rail'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1	= find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Rail|Electricity');
lineVAR2	= find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Rail|Liquids');
lineVAR3	= find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Rail|Gases');
Other		= (alpharail_passenger(k,indice_coal) + alpharail_passenger(k,indice_oil)) * EnergyServices_rail_pass(k)* Mtoe_EJ;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR3,current_time_im+1) + Other;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";list_output_comments(counterLine)="Beta version";
end;


varname = 'Final Energy|Transportation|Passenger|Bus|Electricity'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    alpharoad_passenger(k,indice_elec)	*EnergyServices_road_pass(k) ..
)* Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";list_output_comments(counterLine)="Beta version";
end;

varname = 'Final Energy|Transportation|Passenger|Bus|Gases'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    alpharoad_passenger(k,indice_gas)	*EnergyServices_road_pass(k) ..
)* Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";list_output_comments(counterLine)="Beta version";
end;

varname = 'Final Energy|Transportation|Passenger|Bus|Hydrogen'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger|Bus|Liquids'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    alpharoad_passenger(k,indice_Et)	*EnergyServices_road_pass(k) ..
)* Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";list_output_comments(counterLine)="Beta version";
end;

varname = 'Final Energy|Transportation|Passenger|Bus'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1	= find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Bus|Electricity');
lineVAR2	= find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Bus|Liquids');
lineVAR3	= find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Bus|Gases');
Other		= (alpharoad_passenger(k,indice_coal) + alpharoad_passenger(k,indice_oil)) * EnergyServices_road_pass(k)* Mtoe_EJ;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR3,current_time_im+1) + Other;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";list_output_comments(counterLine)="Beta version";
end;


varname = 'Final Energy|Bunkers|Passenger|International Aviation|Electricity'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    (energy_balance(conso_air_eb,elec_eb,k))..
    * DF(k,indice_air )/(Q(k,indice_air )) * (1-ShareDomAviation_2014(k)).. // to have the share of passenger air transportation... but this estimate is not necessarily consistent with ShareDomesticAviation.
)* Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Bunkers|Passenger|International Aviation|Hydrogen'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Bunkers|Passenger|International Aviation'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    (energy_balance(conso_air_eb,et_eb,k)+ (energy_balance(conso_air_eb,elec_eb,k)))..
    * DF(k,indice_air )/(Q(k,indice_air )) * (1-ShareDomAviation_2014(k)).. // to have the share of passenger air transportation... but this estimate is not necessarily consistent with ShareDomesticAviation.
)* Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Final Energy|Transportation|Passenger|Domestic Aviation|Electricity'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    (energy_balance(conso_air_eb,elec_eb,k))..
    * DF(k,indice_air )/(Q(k,indice_air )) * ShareDomAviation_2014(k).. // to have the share of passenger air transportation... but this estimate is not necessarily consistent with ShareDomesticAviation.
)* Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger|Domestic Aviation|Gases'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    (energy_balance(conso_air_eb,gas_eb,k))..
    * DF(k,indice_air )/(Q(k,indice_air )) * ShareDomAviation_2014(k).. // to have the share of passenger air transportation... but this estimate is not necessarily consistent with ShareDomesticAviation.
)* Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger|Domestic Aviation|Hydrogen'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger|Domestic Aviation|Liquids'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    (energy_balance(conso_air_eb,et_eb,k))..
    * DF(k,indice_air )/(Q(k,indice_air )) * ShareDomAviation_2014(k).. // to have the share of passenger air transportation... but this estimate is not necessarily consistent with ShareDomesticAviation.
)* Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger|Domestic Aviation'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    (energy_balance(conso_air_eb,et_eb,k)+ (energy_balance(conso_air_eb,elec_eb,k)))..
    * DF(k,indice_air )/(Q(k,indice_air )) * ShareDomAviation_2014(k).. // to have the share of passenger air transportation... but this estimate is not necessarily consistent with ShareDomesticAviation.
)* Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Final Energy|Transportation|Passenger|Electricity'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|LDV|Electricity');
lineVAR2 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Domestic Aviation|Electricity');
lineVAR3 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Bus|Electricity');
lineVAR4 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Rail|Electricity');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR3,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR4,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger|Gases'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
//lineVAR1 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|LDV|Gases');
lineVAR2 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Domestic Aviation|Gases');
lineVAR3 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Bus|Gases');
lineVAR4 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Rail|Gases');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR3,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR4,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger|Hydrogen'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger|Liquids'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|LDV|Liquids');
lineVAR2 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Domestic Aviation|Liquids');
lineVAR3 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Bus|Liquids');
lineVAR4 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Rail|Liquids');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR3,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR4,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger|Liquids|Fossil'; //   EJ/yr
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Bus|Liquids');
lineVAR2 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Rail|Liquids');
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    energy_balance(conso_car_eb,et_eb,k) * (1-share_biofuel_all(k))..
    + (outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1)) / Mtoe_EJ * (1-share_biofuel_ot(k)).. // other terrestrial transport
    + ((energy_balance(conso_air_eb,et_eb,k))*DF(k,indice_air)/(Q(k,indice_air))* ShareDomAviation_2014(k)) * (1-share_biofuel_Air(k))..//passenger domestic aviation; we don't count for passenger international aviation - to be checked with partners
) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger|Liquids|Biomass'; //   EJ/yr
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Bus|Liquids');
lineVAR2 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Rail|Liquids');
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    energy_balance(conso_car_eb,et_eb,k) * share_biofuel_all(k) ..
    + (outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1)) / Mtoe_EJ *share_biofuel_ot(k)..// other terrestrial transport
    + ((energy_balance(conso_air_eb,et_eb,k))*DF(k,indice_air)/(Q(k,indice_air))* ShareDomAviation_2014(k))*share_biofuel_Air(k)..//passenger domestic aviation; we don't count for passenger international aviation - to be checked with partners
) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


//NOTES gases is not reported but we have some, a small amount in aviation and some in OT, which creates aggregated imbalances
varname = 'Final Energy|Transportation|Passenger'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|LDV');
lineVAR2 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Domestic Aviation');
lineVAR3 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Bus');
lineVAR4 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Rail');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR3,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR4,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;



varname = 'Final Energy|Transportation|Freight|Electricity'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Bus|Electricity');
lineVAR2 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Rail|Electricity');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    (sum(energy_balance(conso_transport_eb,elec_eb,k))) ..
    - (energy_balance(conso_car_eb,elec_eb,k)).. // passenger cars
    - (outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1))/Mtoe_EJ ..// passenger other terrestrial transportation
    - (energy_balance(conso_air_eb,elec_eb,k))*DF(k,indice_air)/(Q(k,indice_air))* ShareDomAviation_2014(k)..//passenger domestic aviation
    - (energy_balance(conso_air_eb,elec_eb,k))* (1-ShareDomAviation_2014(k)).. //international aviation
) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Freight|Gases'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Bus|Gases');
lineVAR2 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Rail|Gases');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    (sum(energy_balance(conso_transport_eb,gas_eb,k))) ..
    - (energy_balance(conso_car_eb,gas_eb,k)).. // passenger cars
    - (outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1))/Mtoe_EJ ..// passenger other terrestrial transportation
    - (energy_balance(conso_air_eb,gas_eb,k))*DF(k,indice_air)/(Q(k,indice_air))* ShareDomAviation_2014(k)..//passenger domestic aviation
    - (energy_balance(conso_air_eb,gas_eb,k))* (1-ShareDomAviation_2014(k)).. //international aviation
) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Freight|Liquids'; // EJ/yr
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Bus|Liquids');
lineVAR2 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Rail|Liquids');
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    (sum(energy_balance(conso_transport_eb,et_eb,k))) ..
    - (energy_balance(conso_car_eb,et_eb,k)).. // passenger cars
    - (outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1))/Mtoe_EJ ..// passenger other terrestrial transportation
    - (energy_balance(conso_air_eb,et_eb,k))*DF(k,indice_air)/(Q(k,indice_air))* ShareDomAviation_2014(k)..//passenger domestic aviation
    - (energy_balance(conso_air_eb,et_eb,k))* (1-ShareDomAviation_2014(k)).. //international aviation
) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

// To be UPDATED
varname = 'Final Energy|Transportation|Freight|Liquids|Fossil'; // EJ/yr
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Bus|Liquids');
lineVAR2 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Rail|Liquids');
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    (sum(energy_balance(conso_transport_eb,et_eb,k)))*(1-share_biofuel_all(k)) ..
    - (energy_balance(conso_car_eb,et_eb,k))*(1-share_biofuel_car(k)).. // passenger cars
    - (outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1))/Mtoe_EJ*(1-share_biofuel_ot(k))..// passenger other terrestrial transportation
    - (energy_balance(conso_air_eb,et_eb,k))*DF(k,indice_air)/(Q(k,indice_air))* ShareDomAviation_2014(k)*(1-share_biofuel_Air(k))..//passenger domestic aviation
    - (energy_balance(conso_air_eb,et_eb,k))* (1-ShareDomAviation_2014(k))*(1-share_biofuel_Air(k)).. //international aviation
) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

// To be UPDATED
varname = 'Final Energy|Transportation|Freight|Liquids|Biomass'; // EJ/yr
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Bus|Liquids');
lineVAR2 = find_index_list( list_output_str, 'Final Energy|Transportation|Passenger|Rail|Liquids');
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    (sum(energy_balance(conso_transport_eb,et_eb,k)))*share_biofuel_all(k) ..
    - (energy_balance(conso_car_eb,et_eb,k)*share_biofuel_car(k)).. // passenger cars
    - (outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1))/Mtoe_EJ*share_biofuel_ot(k)..// passenger other terrestrial transportation
    - (energy_balance(conso_air_eb,et_eb,k))*DF(k,indice_air)/(Q(k,indice_air))* ShareDomAviation_2014(k)*share_biofuel_Air(k)..//passenger domestic aviation
    - (energy_balance(conso_air_eb,et_eb,k))* (1-ShareDomAviation_2014(k))*share_biofuel_Air(k).. //international aviation
) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Freight|Other'; // EJ/yr
RailPass_coaloil_Mtoe	= (alpharail_passenger(k,indice_coal) + alpharail_passenger(k,indice_oil)) * EnergyServices_road_pass(k);
BusPass_coaloil_Mtoe	= (alpharoad_passenger(k,indice_coal) + alpharoad_passenger(k,indice_oil)) * EnergyServices_road_pass(k);
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    sum(energy_balance(conso_transport_eb,coal_eb,k)) ..
    + sum(energy_balance(conso_transport_eb,oil_eb,k)) ..
    - RailPass_coaloil_Mtoe - BusPass_coaloil_Mtoe ..// passenger other terrestrial transportation
    - sum(energy_balance(conso_air_eb,coal_eb:oil_eb,k))*DF(k,indice_air)/(Q(k,indice_air))* ShareDomAviation_2014(k)..//passenger domestic aviation
    - sum(energy_balance(conso_air_eb,coal_eb:oil_eb,k))* (1-ShareDomAviation_2014(k)).. //international aviation
) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

// Note: Coal is not reported but we have some in IMACLIM
varname = 'Final Energy|Transportation|Freight'; // EJ/yr
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Transportation|Freight|Electricity');
lineVAR2 = find_index_list( list_output_str, 'Final Energy|Transportation|Freight|Liquids');
lineVAR3 = find_index_list( list_output_str, 'Final Energy|Transportation|Freight|Gases');
lineVAR4 = find_index_list( list_output_str, 'Final Energy|Transportation|Freight|Other');
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR3,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR4,current_time_im+1);
final_energy_freight(k,1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR3,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR4,current_time_im+1); // We save this value
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;




varname = 'Final Energy|Transportation|Electricity'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    sum(energy_balance(conso_transport_eb,elec_eb,k))..
    - energy_balance(conso_air_eb,elec_eb,k)*(1-ShareDomAviation_2014(k)).. // By convention, international aviation is accounted in the "bunkers" sector, and not in  transportation
)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Gases'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    sum(energy_balance(conso_transport_eb,gas_eb,k))..
    - energy_balance(conso_air_eb,gas_eb,k)*(1-ShareDomAviation_2014(k)).. // By convention, international aviation is accounted in the "bunkers" sector, and not in  transportation
)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    sum(energy_balance(conso_transport_eb,et_eb,k))..
    - energy_balance(conso_air_eb,et_eb,k)*(1-ShareDomAviation_2014(k)).. // By convention, international aviation is accounted in the "bunkers" sector, and not in  transportation
)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids|Fossil'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    sum(energy_balance(conso_transport_eb,et_eb,k))*(1-share_biofuel_all(k))..
    - energy_balance(conso_air_eb,et_eb,k)*(1-ShareDomAviation_2014(k))*(1-share_biofuel_Air(k)).. // By convention, international aviation is accounted in the "bunkers" sector, and not in  transportation
)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids|Biomass'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    sum(energy_balance(conso_transport_eb,et_eb,k)) * share_biofuel_all(k)..
    - energy_balance(conso_air_eb,et_eb,k)*(1-ShareDomAviation_2014(k))* share_biofuel_Air(k).. // By convention, international aviation is accounted in the "bunkers" sector, and not in  transportation
)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Hydrogen'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;	  
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Other'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;	  
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;




varname = 'Final Energy|Transportation'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    sum(energy_balance(conso_transport_eb,:,k))..
    - ((energy_balance(conso_air_eb,et_eb,k)+energy_balance(conso_air_eb,elec_eb,k))*(1-ShareDomAviation_2014(k))).. // By convention, international aviation is accounted in the "bunkers" sector, and not in  transportation
)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Final Energy|Bunkers|Passenger'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    (energy_balance(conso_air_eb,et_eb,k)+ (energy_balance(conso_air_eb,elec_eb,k)))..
    * DF(k,indice_air )/(Q(k,indice_air )) * (1-ShareDomAviation_2014(k)).. // to have the share of passenger air transportation... but this estimate is not necessarily consistent with ShareDomesticAviation.
)* Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;



varname = 'Final Energy|Bunkers|Passenger|International Shipping'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

//NOTES with have small amounts of coal and gas that we do not report here, but in Final Energ|{Gases,Solids}, which creates imbalances
varname = 'Final Energy|Bunkers|Freight|International Aviation'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    (energy_balance(conso_air_eb,et_eb,k)+ (energy_balance(conso_air_eb,elec_eb,k)))..
    * (1-DF(k,indice_air )/(Q(k,indice_air ))) * (1-ShareDomAviation_2014(k)).. // to have the share of passenger air transportation... but this estimate is not necessarily consistent with ShareDomesticAviation.
)* Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Bunkers|Freight|International Shipping'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = -sum(energy_balance(marbunk_eb,:,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Bunkers|International Shipping'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Bunkers|Freight|International Shipping');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Bunkers|International Shipping|Electricity'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = -sum(energy_balance(marbunk_eb,elec_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Bunkers|International Shipping|Gases'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = -sum(energy_balance(marbunk_eb,gas_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Bunkers|International Shipping|Gases|Fossil'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = -sum(energy_balance(marbunk_eb,gas_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Bunkers|International Shipping|Liquids'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = -sum(energy_balance(marbunk_eb,et_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Bunkers|Freight'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Bunkers|Freight|International Shipping');
lineVAR2 = find_index_list( list_output_str, 'Final Energy|Bunkers|Freight|International Aviation');
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Bunkers'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Bunkers|Freight');
lineVAR2 = find_index_list( list_output_str, 'Final Energy|Bunkers|Passenger|International Aviation');
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Final Energy|Bunkers|International Aviation|Hydrogen'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Final Energy|Transportation|Domestic Aviation|Hydrogen'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;																		
// The use of Traditionnal Biomass is excluded from Secondary and Final energy balances, but should be included
varname = 'Final Energy'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(energy_balance(conso_tot_eb,:,k)-energy_balance(marbunk_eb,:,k))*Mtoe_EJ + Traditional_biomass_EJ(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

// The use of Traditionnal Biomass is excluded from Secondary balances, but should be included
varname = 'Final Energy (w/o bunkers)'; //  EJ/yr
lineVAR1 = find_index_list( list_output_str, 'Final Energy|Bunkers');
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(energy_balance(conso_tot_eb,:,k) -energy_balance(marbunk_eb,:,k))*Mtoe_EJ + Traditional_biomass_EJ(k) - outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
													
varname = 'Price|Secondary Energy|Liquids|Biomass'; //  US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_NLU>0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = bioener_costs_NLU(k) * usd_year1_year2 / tep2gj;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
end
// '(excludes tax)
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";
end;

varname = 'Primary Energy|Biomass|Electricity'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(qBiomExaJ(k,:));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Electricity|w/ CCS'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = qBiomExaJ(k,2) ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Electricity|w/o CCS'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = qBiomExaJ(k,1) ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Gases'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Liquids'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = - energy_balance(refi_eb,enr_eb,k) * Mtoe_EJ / hoogwick_bioEt_efficienc(current_time_im);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

if ind_NLU ==0
    varname = 'Primary Energy|Biomass|Traditional'; //    EJ/yr
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Traditional_biomass_EJ(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
end

//from doi:10.1016/j.biombioe.2008.04.005
varname = 'Primary Energy|Biomass|w/o CCS'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR = find_index_list( list_output_str, 'Primary Energy|Biomass|Traditional');
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = - energy_balance(refi_eb,enr_eb,k) * Mtoe_EJ / hoogwick_bioEt_efficienc(current_time_im) + sum(qBiomExaJ(k,1)) +  outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|w/ CCS'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = sum(qBiomExaJ(k,2));
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass'; //  EJ/yr
counterLine =counterLine+ 1; if current_time==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR = find_index_list( list_output_str, 'Primary Energy|Biomass|Traditional');
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = sum(qBiomExaJ(k,2)) - energy_balance(refi_eb,enr_eb,k) * Mtoe_EJ / hoogwick_bioEt_efficienc(current_time_im) + sum(qBiomExaJ(k,1)) + outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
if current_time==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Coal'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(tpes_eb,coal_eb,k)*Mtoe_EJ* (1+ratio_ener_autocons(k,indice_coal));
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

varname = 'Primary Energy|Fossil'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(tpes_eb,fossil_primary_eb,k)))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Fossil|w/ CCS'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Mtoe_EJ * (..
    - energy_balance(losses_eb,coal_eb,k) * share_CCS_CTL(k)    .. //autoconsommation de charbon dans la production de charbon pour le CTL
    - energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k)    .. //raffineries (ctl)
    - energy_balance(pwplant_eb,coal_eb,k) * sh_CCS_col_Q_col(k) .. //coal to elec
    - energy_balance(pwplant_eb,gas_eb,k) * sh_CCS_gaz_Q_gaz(k) ..//gaz to elec
);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Fossil|w/o CCS'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= Mtoe_EJ * (..
    sum(energy_balance(tpes_eb,fossil_primary_eb,k)) ..
    - (..
    - energy_balance(losses_eb,coal_eb,k) * share_CCS_CTL(k)    .. //autoconsommation de charbon dans la production de charbon pour le CTL
    - energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k)    .. //raffineries (ctl)
    - energy_balance(pwplant_eb,coal_eb,k) * sh_CCS_col_Q_col(k) .. //coal to elec
    - energy_balance(pwplant_eb,gas_eb,k) * sh_CCS_gaz_Q_gaz(k) ..  //gaz to elec
    )..
);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Gas'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(tpes_eb,gas_eb,k)*Mtoe_EJ* (1+ratio_ener_autocons(k,indice_gas));
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(tpes_eb,oil_eb,k)*Mtoe_EJ* (1+ratio_ener_autocons(k,indice_oil));
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

varname = 'Primary Energy|Secondary Energy Trade'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= ..
    -(energy_balance(imp_eb,et_eb,k)   + energy_balance(exp_eb,et_eb,k))*Mtoe_EJ ..
-(energy_balance(imp_eb,elec_eb,k) + energy_balance(exp_eb,elec_eb,k))*Mtoe_EJ;
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
for var=['Non-Biomass Renewables','Biomass','Nuclear','Fossil']
    lineVAR = find_index_list( list_output_str, 'Primary Energy|'+var);
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
end
end

varname = 'Investment';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(pK(k,:).*DeltaK(k,:)) *usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Investment|Energy Supply';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (pK(k,coal).*DeltaK(k,coal) + pK(k,oil).*DeltaK(k,oil)..
+ pK(k,gaz).*DeltaK(k,gaz) + pK(k,et).*DeltaK(k,et) + pK(k,elec).*DeltaK(k,elec))*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Investment|Energy Supply|Electricity';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (pK(k,elec).*DeltaK(k,elec))*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
  
varname = 'Investment|Energy Supply|Electricity|Coal|w/ CCS';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,technoCoalWCCS).*CINV_MW_nexus(k,technoCoalWCCS))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
  
varname = 'Investment|Energy Supply|Electricity|Coal|w/o CCS';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,technoCoalWOCCS).*CINV_MW_nexus(k,technoCoalWOCCS))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
  
varname = 'Investment|Energy Supply|Electricity|Coal';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ( sum(delta_Cap_elec_MW_1(k,technoCoalWCCS).*CINV_MW_nexus(k,technoCoalWCCS))+  +sum(delta_Cap_elec_MW_1(k,technoCoalWOCCS).*CINV_MW_nexus(k,technoCoalWOCCS)))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
  
varname = 'Investment|Energy Supply|Electricity|Gas|w/ CCS';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,indice_GGS).*CINV_MW_nexus(k,indice_GGS))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
  
varname = 'Investment|Energy Supply|Electricity|Gas|w/o CCS';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,technoGasWOCCS).*CINV_MW_nexus(k,technoGasWOCCS))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
  
varname = 'Investment|Energy Supply|Electricity|Gas';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ( sum(delta_Cap_elec_MW_1(k,indice_GGS).*CINV_MW_nexus(k,indice_GGS))+sum(delta_Cap_elec_MW_1(k,technoGasWOCCS).*CINV_MW_nexus(k,technoGasWOCCS)))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
  
varname = 'Investment|Energy Supply|Electricity|Nuclear';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,technoNuke).*CINV_MW_nexus(k,technoNuke))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
  
varname = 'Investment|Energy Supply|Electricity|Oil';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,technoOil).*CINV_MW_nexus(k,technoOil))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
  
varname = 'Investment|Energy Supply|Electricity|Oil|w/o CCS';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,technoOil).*CINV_MW_nexus(k,technoOil))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
  
varname = 'Investment|Energy Supply|Electricity|Oil|w/ CCS';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
  
varname = 'Investment|Energy Supply|Electricity|Biomass';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,technoBiomass).*CINV_MW_nexus(k,technoBiomass))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end
  
varname = 'Investment|Energy Supply|Electricity|Biomass|w/ CCS';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,indice_BIS).*CINV_MW_nexus(k,indice_BIS))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end
  
varname = 'Investment|Energy Supply|Electricity|Biomass|w/o CCS';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,indice_BIG).*CINV_MW_nexus(k,indice_BIG))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end
  
varname = 'Investment|Energy Supply|Electricity|Hydro';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,technoElecHydro).*CINV_MW_nexus(k,technoElecHydro))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end
  
varname = 'Investment|Energy Supply|Electricity|Non-Biomass Renewables';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,technoNonBiomassRen).*CINV_MW_nexus(k,technoNonBiomassRen))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end
  
varname = 'Investment|Energy Supply|Electricity|Fossil';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,technoFossil).*CINV_MW_nexus(k,technoFossil))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
  
varname = 'Investment|Energy Supply|Electricity|Non-fossil';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,technoNonFossil).*CINV_MW_nexus(k,technoNonFossil))/10^3*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
  
varname = 'Investment|Energy Supply|Extraction|Fossil';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (pK(k,coal).*DeltaK(k,coal) + pK(k,oil).*DeltaK(k,oil)..
+ pK(k,gaz).*DeltaK(k,gaz))*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Investment|Energy Supply|Extraction|Coal';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (pK(k,coal).*DeltaK(k,coal) )*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Investment|Energy Supply|Extraction|Gas';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (pK(k,gaz).*DeltaK(k,gaz) )*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Investment|Energy Supply|Extraction|Oil';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (pK(k,oil).*DeltaK(k,oil) )*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Investment|Energy Supply|Liquids';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (pK(k,et).*DeltaK(k,et) )*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Secondary Energy|Electricity'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(pwplant_eb,elec_eb,k)*Mtoe_EJ) * (1+ratio_ener_autocons(k,indice_elec));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Biomass'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoBiomass))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Biomass|w/ CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,indice_BIS))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Biomass|w/o CCS'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,indice_BIG))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Coal'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoElecCoal))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Coal|w/ CCS'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoCoalWCCS)) *  Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Coal|w/o CCS'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoCoalWOCCS)) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Gas'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoElecGas))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Gas|w/ CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoGasWCCS))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Gas|w/o CCS'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoGasWOCCS))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Geothermal'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Hydro'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoElecHydro))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Non-Biomass Renewables'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoNonBiomassRen))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Nuclear'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoNuke))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Ocean'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Oil'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoOil))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Oil|w/ CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Oil|w/o CCS'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoOil))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Other'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Solar'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoSolar))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Solar|CSP'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * msh_elec_techno(k,indice_CSP)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Solar|PV'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoPV))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Wind'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoWind))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Wind|Offshore'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,[indice_WNO]))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Electricity|Wind|Onshore'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,[indice_WND]))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Gases'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(tpes_eb,gas_eb,k) + energy_balance(losses_eb,gas_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Solids'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(tpes_eb,coal_eb,k) + energy_balance(losses_eb,coal_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Gases|Biomass'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Gases|Coal'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Gases|Fossil'; //  EJ/yr (does not include Secondary Energy|Gases|Coal)
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(tpes_eb,gas_eb,k) + energy_balance(losses_eb,gas_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Gases|Other'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Heat'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Heat|Biomass'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Heat|Coal'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Heat|Gas'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Heat|Geothermal'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Heat|Nuclear'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Heat|Oil'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Heat|Other'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Heat|Solar'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Hydrogen|Coal'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Hydrogen|Coal|w/ CCS'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Hydrogen|Coal|w/o CCS'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Hydrogen|Electricity'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Hydrogen|Gas'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Hydrogen|Gas|w/ CCS'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Hydrogen|Gas|w/o CCS'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Hydrogen|Nuclear'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Hydrogen|Other'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Hydrogen|Solar'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(refi_eb,et_eb,k)*Mtoe_EJ) * (1+ratio_ener_autocons(k,indice_Et)) ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_biofuel(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|1st Generation'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_NLU >0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share1G(k) .* share_biofuel(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
end
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Mixed of Biodiesel and Conventional Ethanol";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Secondary Energy|Liquids|Biomass|Energy Crops'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_NLU >0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share2G(k) .* share_biofuel(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|Other'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|Residues'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|w/ CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|w/o CCS'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_biofuel(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Coal'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_CTL(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Coal|w/ CCS'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_CCS_CTL(k) .* share_CTL(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Coal|w/o CCS'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ( 1 - share_CCS_CTL(k) ) .* share_CTL(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Fossil'; // EJ/yr'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (share_CTL(k)+share_oil_refin(k)) * energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Fossil|w/ CCS'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_CCS_CTL(k) * share_CTL(k) * energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Fossil|w/o CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ( (1 - share_CCS_CTL(k)) * share_CTL(k)+share_oil_refin(k)) * energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Gas'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Gas|w/ CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Gas|w/o CCS'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Oil'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_oil_refin(k) * energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Other'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

if ind_NLU ==0
    varname = 'Secondary Energy'; //  EJ/yr
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
for var=['Gases','Electricity','Liquids','Solids']
    lineVAR = find_index_list( list_output_str, 'Secondary Energy|'+var);
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR,current_time+1);
end
end


varname = 'Trade|Primary Energy|Coal|Volume'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = -( energy_balance(imp_eb,coal_eb,k) + energy_balance(exp_eb,coal_eb,k)) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Trade|Primary Energy|Gas|Volume'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = -( energy_balance(imp_eb,gas_eb,k) + energy_balance(exp_eb,gas_eb,k)) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Trade|Primary Energy|Oil|Volume'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = -( energy_balance(imp_eb,oil_eb,k) + energy_balance(exp_eb,oil_eb,k)) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Trade|Secondary Energy|Electricity|Volume'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = -( energy_balance(imp_eb,elec_eb,k) + energy_balance(exp_eb,elec_eb,k)) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
//todo

varname = 'Trade|Secondary Energy|Liquids|Biomass|Volume'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
//todo

varname = 'Population'; //| million
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=Ltot(k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "million";
end;

varname = 'GDP|MER'; // billion billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= GDP_MER_real(k)/ 1e3*usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'GDP|PPP'; // billion billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=GDP_PPP_constant(k)/ 1e3*usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'Emissions|N2O'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "kt N2O/yr";
    if current_time_im==yr_start & k==1;list_output_comments(counterLine)="External. Completed from 1.5 database with the help of the Silicone https://github.com/GranthamImperial/silicone";end;
end;

varname = 'Emissions|BC'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="External. Completed from 1.5 database with the help of the Silicone https://github.com/GranthamImperial/silicone";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt BC/yr";
end;

varname = 'Emissions|CH4'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CH4/yr";
    if current_time_im==yr_start & k==1;list_output_comments(counterLine)="External. Completed from 1.5 database with the help of the Silicone https://github.com/GranthamImperial/silicone";end;
end;

varname = 'Emissions|CO2|Energy|woCCS'; //	Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,:))/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy'; //	Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,:))/1e6 + emi_evitee(k)/1e6;
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (sum(E_reg_use(k,iu_indu)) + E_reg_use(k,iu_agri))/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Demand|Industry only'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,iu_indu))/1e6;
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


varname = 'Emissions|CO2|Energy|Demand|Residential'; //
//We do not use E_reg_use(iu_DF) because DF includes cars and residential
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + coef_Q_CO2_DF(k,coal)       .* energy_balance(conso_resid_eb,coal_eb,k) ..
    + coef_Q_CO2_DF(k,oil)        .* energy_balance(conso_resid_eb,oil_eb,k)  ..
    + coef_Q_CO2_DF(k,gaz)        .* energy_balance(conso_resid_eb,gas_eb,k)  ..
    + coef_Q_CO2_DF(k,et)         .* energy_balance(conso_resid_eb,et_eb,k)   ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Demand|Commercial'; //
//On n'utilise pas E_reg_use(iu_DF) car DF inclut cars et resid 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + coef_Q_CO2_CI(coal,compo,k) .* energy_balance(conso_comp_eb, coal_eb,k) ..
    + coef_Q_CO2_CI(oil,compo,k)  .* energy_balance(conso_comp_eb, oil_eb,k) ..
    + coef_Q_CO2_CI(gaz,compo,k)  .* energy_balance(conso_comp_eb, gas_eb,k)  ..
    + coef_Q_CO2_CI(et,compo,k)   .* energy_balance(conso_comp_eb, et_eb,k)   ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;							  

varname = 'Emissions|CO2|Energy|Demand|Transportation|LDV'; //
//On n'utilise pas E_reg_use(iu_DF) pour cars car DF inclut cars et resid 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + coef_Q_CO2_DF(k,coal).* energy_balance(conso_car_eb,coal_eb,k) ..
    + coef_Q_CO2_DF(k,oil) .* energy_balance(conso_car_eb,oil_eb,k)  ..
    + coef_Q_CO2_DF(k,gaz) .* energy_balance(conso_car_eb,gas_eb,k)  ..
    + coef_Q_CO2_DF(k,et)  .* energy_balance(conso_car_eb,et_eb,k)   ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Demand|Transportation|Domestic Aviation'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + E_reg_use(k,iu_air)* ShareDomAviation_2014(k) ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Demand|Bunkers|International Aviation'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + E_reg_use(k,iu_air)* (1-ShareDomAviation_2014(k)) ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Demand|Transportation|Bus'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";list_output_comments(counterLine)="Note that Emissions|CO2|Energy|Demand|Transportation|Bus and Emissions|CO2|Energy|Demand|Transportation|Trucks is included in Emissions|CO2|Energy|Demand|Transportation|Rail as our disaggregation of the transportation sector does not distinguish rail, trucks and buses ";
end;

varname = 'Emissions|CO2|Energy|Demand|Transportation|Rail'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + E_reg_use(k,iu_OT)  ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";list_output_comments(counterLine)="Our disaggregation of the transportation sector does not distinguish rail, trucks and buses, so this output also includes passenger bus, as well as terrestrial freight (rail and trucks).";
end;

varname = 'Emissions|CO2|Energy|Demand|Bunkers|International Shipping'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + E_reg_use(k,iu_mer)  ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";list_output_comments(counterLine)="This is the sum of emissions from maritime transportation all around the world";
end;

varname = 'Emissions|CO2|Energy|Demand|Bunkers';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Emissions|CO2|Energy|Demand|Bunkers|International Shipping');
lineVAR2 = find_index_list( list_output_str, 'Emissions|CO2|Energy|Demand|Bunkers|International Aviation');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";list_output_comments(counterLine)="";
end;

varname = 'Emissions|CO2|Energy|Demand|Transportation|Passenger'; //
//On n'utilise pas E_reg_use(iu_DF) pour cars car DF inclut cars et resid 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + coef_Q_CO2_DF(k,coal).* energy_balance(conso_car_eb,coal_eb,k) ..
    + coef_Q_CO2_DF(k,oil) .* energy_balance(conso_car_eb,oil_eb,k)  ..
    + coef_Q_CO2_DF(k,gaz) .* energy_balance(conso_car_eb,gas_eb,k)  ..
    + coef_Q_CO2_DF(k,et)  .* energy_balance(conso_car_eb,et_eb,k)   ..
    + coef_Q_CO2_CI(et,indice_air,k) .* (energy_balance(conso_air_eb,et_eb,k)*DF(k,indice_air )/(Q(k,indice_air )-Exp(k,indice_air )+Imp(k,indice_air ))* ShareDomAviation_2014(k))..
    + coef_Q_CO2_CI(et,indice_OT,k) .* (energy_balance(conso_ot_eb,et_eb,k)*DF(k,indice_OT )/(Q(k,indice_OT )-Exp(k,indice_OT )+Imp(k,indice_OT )))..
    )/1e6; //+ coef_Q_CO2_CI(et,indice_air,k) .* (energy_balance(conso_air_eb,et_eb,k)*DF(k,indice_air )/(Q(k,indice_air )-Exp(k,indice_air )+Imp(k,indice_air ))* (1-ShareDomAviation_2014(k)))..
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";list_output_comments(counterLine)="This output currently includes international air transport for passengers";
end;

varname = 'Emissions|CO2|Energy|Demand|Transportation|Freight'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + E_reg_use(k,iu_air) .. //+ E_reg_use(k,iu_mer) .. // Demand for shipping, accounted in bunkers
    + E_reg_use(k,iu_OT)  ..
    - coef_Q_CO2_CI(et,indice_air,k) .* (energy_balance(conso_air_eb,et_eb,k)*DF(k,indice_air )/(Q(k,indice_air )-Exp(k,indice_air )+Imp(k,indice_air ))* ShareDomAviation_2014(k)).. //Passenger demand for domestic aviation
    - coef_Q_CO2_CI(et,indice_air,k) .* (energy_balance(conso_air_eb,et_eb,k)*DF(k,indice_air )/(Q(k,indice_air )-Exp(k,indice_air )+Imp(k,indice_air ))* (1-ShareDomAviation_2014(k))).. //Passenger demand for international aviation
    - coef_Q_CO2_CI(et,indice_air,k) .* (energy_balance(conso_air_eb,et_eb,k)*(1-DF(k,indice_air )/(Q(k,indice_air )-Exp(k,indice_air )+Imp(k,indice_air )))* (1-ShareDomAviation_2014(k))).. //Freight demand for international aviation
    - coef_Q_CO2_CI(et,indice_OT,k) .* (energy_balance(conso_ot_eb,et_eb,k)*DF(k,indice_OT )/(Q(k,indice_OT )-Exp(k,indice_OT )+Imp(k,indice_OT ))).. // Passenger demand for other terrestrial transportation
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";list_output_comments(counterLine)="This output currently does not include international air transport and all shipping for freight";
end;

varname = 'Emissions|CO2|Energy|Demand|Transportation|Passenger|LDV'; //
//On n'utilise pas E_reg_use(iu_DF) pour cars car DF inclut cars et resid 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + coef_Q_CO2_DF(k,coal).* energy_balance(conso_car_eb,coal_eb,k) ..
    + coef_Q_CO2_DF(k,oil) .* energy_balance(conso_car_eb,oil_eb,k)  ..
    + coef_Q_CO2_DF(k,gaz) .* energy_balance(conso_car_eb,gas_eb,k)  ..
    + coef_Q_CO2_DF(k,et)  .* energy_balance(conso_car_eb,et_eb,k)   ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Demand|Transportation|Passenger|Domestic Aviation'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + coef_Q_CO2_CI(et,indice_air,k) .* (energy_balance(conso_air_eb,et_eb,k)*DF(k,indice_air )/(Q(k,indice_air ))* ShareDomAviation_2014(k))..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Demand|Bunkers|Passenger|International Aviation'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + coef_Q_CO2_CI(et,indice_air,k) .* (energy_balance(conso_air_eb,et_eb,k)*DF(k,indice_air )/(Q(k,indice_air ))* (1-ShareDomAviation_2014(k)))..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Demand|Transportation|Passenger|Bus'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + coef_Q_CO2_DF(k,indice_coal)	* alpharoad_passenger(k,indice_coal)	*EnergyServices_road_pass(k) ..
    + coef_Q_CO2_DF(k,indice_gas)		* alpharoad_passenger(k,indice_gas)	*EnergyServices_road_pass(k) ..
    + coef_Q_CO2_DF(k,indice_Et)		* alpharoad_passenger(k,indice_Et)		*EnergyServices_road_pass(k) ..
    + coef_Q_CO2_DF(k,indice_oil)		* alpharoad_passenger(k,indice_oil)	*EnergyServices_road_pass(k) ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";list_output_comments(counterLine)="Beta version";
end;

varname = 'Emissions|CO2|Energy|Demand|Transportation|Passenger|Rail'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + coef_Q_CO2_DF(k,indice_coal)	* alpharail_passenger(k,indice_coal)	*EnergyServices_rail_pass(k) ..
    + coef_Q_CO2_DF(k,indice_gas)		* alpharail_passenger(k,indice_gas)	*EnergyServices_rail_pass(k) ..
    + coef_Q_CO2_DF(k,indice_Et)		* alpharail_passenger(k,indice_Et)		*EnergyServices_rail_pass(k) ..
    + coef_Q_CO2_DF(k,indice_oil)		* alpharail_passenger(k,indice_oil)	*EnergyServices_rail_pass(k) ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";list_output_comments(counterLine)="Beta version";
end;

varname = 'Emissions|CO2|Energy|Demand|Transportation|Passenger'; //
//On n'utilise pas E_reg_use(iu_DF) pour cars car DF inclut cars et resid 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Emissions|CO2|Energy|Demand|Transportation|Passenger|LDV');
lineVAR2 = find_index_list( list_output_str, 'Emissions|CO2|Energy|Demand|Transportation|Passenger|Domestic Aviation');
lineVAR3 = find_index_list( list_output_str, 'Emissions|CO2|Energy|Demand|Transportation|Passenger|Bus');
lineVAR4 = find_index_list( list_output_str, 'Emissions|CO2|Energy|Demand|Transportation|Passenger|Rail');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR3,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR4,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";list_output_comments(counterLine)="This output currently includes international air transport for passengers";
end;

varname = 'Emissions|CO2|Energy|Demand|Transportation|Freight'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR3 = find_index_list( list_output_str, 'Emissions|CO2|Energy|Demand|Transportation|Passenger|Bus');
lineVAR4 = find_index_list( list_output_str, 'Emissions|CO2|Energy|Demand|Transportation|Passenger|Rail');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (..
    + E_reg_use(k,iu_air)	.. //+ E_reg_use(k,iu_mer) .. 																		// Demand for shipping, accounted in bunkers only
    - coef_Q_CO2_CI(et,indice_air,k) .* (energy_balance(conso_air_eb,et_eb,k)*DF(k,indice_air )/(Q(k,indice_air ))* ShareDomAviation_2014(k)).. //Passenger demand for domestic aviation
    - coef_Q_CO2_CI(et,indice_air,k) .* (energy_balance(conso_air_eb,et_eb,k)*DF(k,indice_air )/(Q(k,indice_air ))* (1-ShareDomAviation_2014(k))).. //Passenger demand for international aviation
    - coef_Q_CO2_CI(et,indice_air,k) .* (energy_balance(conso_air_eb,et_eb,k)*(1-DF(k,indice_air )/(Q(k,indice_air )))* (1-ShareDomAviation_2014(k))).. //Freight demand for international aviation
    + E_reg_use(k,iu_OT))/1e6 .. 																							// Demand for other terrestrial transport ...
    - outputs_temp(nbLines*(k-1)+lineVAR3,current_time_im+1) - outputs_temp(nbLines*(k-1)+lineVAR4,current_time_im+1);// ... of which we remove Bus and Rail passenger demand
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";list_output_comments(counterLine)="This output currently does not include international air transport and all shipping for freight";
end;

varname = 'Emissions|CO2|Energy|Demand|Transportation'; //
//On n'utilise pas E_reg_use(iu_DF) pour cars car DF inclut cars et resid 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Emissions|CO2|Energy|Demand|Transportation|Passenger');
lineVAR2 = find_index_list( list_output_str, 'Emissions|CO2|Energy|Demand|Transportation|Freight');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy|Demand|Other Sector'; //
//Autre secteur : construction (btp)
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = E_reg_use(k,iu_cons)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Industrial Processes'; //	Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CO2_indus_process(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Energy and Industrial Processes'; //    Mt CO2/yr
lineVAR1 = find_index_list( list_output_str, 'Emissions|CO2|Energy');
lineVAR2 = find_index_list( list_output_str, 'Emissions|CO2|Industrial Processes');
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|AFOLU|Agriculture'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= exo_CO2_agri_direct(k,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
    if current_time_im==yr_start & k==1;list_output_comments(counterLine)="AFOLU is not modelled in IMACLIM. We assume an exogenous trend taking into acocunt historical emissions";end;
end;

varname = 'Emissions|CO2|AFOLU|Land'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= exo_CO2_LUCCCF(k,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
    if current_time_im==yr_start & k==1;list_output_comments(counterLine)="AFOLU is not modelled in IMACLIM. We assume an exogenous trend taking into acocunt historical emissions";end;
end;

varname = 'Emissions|CO2|AFOLU|Land|Positive'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= exo_CO2_LUCCCF(k,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
    if current_time_im==yr_start & k==1;list_output_comments(counterLine)="AFOLU is not modelled in IMACLIM. We assume an exogenous trend taking into acocunt historical emissions";end;
end;

varname = 'Emissions|CO2|AFOLU|Land|Negative'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
    if current_time_im==yr_start & k==1;list_output_comments(counterLine)="AFOLU is not modelled in IMACLIM. We assume an exogenous trend taking into acocunt historical emissions";end;
end;

varname = 'Emissions|CO2|AFOLU'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Emissions|CO2|AFOLU|Agriculture');
lineVAR2 = find_index_list( list_output_str, 'Emissions|CO2|AFOLU|Land');
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
    if current_time_im==yr_start & k==1;list_output_comments(counterLine)="AFOLU is not modelled in IMACLIM. We assume an exogenous trend taking into acocunt historical emissions";end;
end;

varname = 'Emissions|CO2'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Emissions|CO2|Energy and Industrial Processes');
lineVAR2 = find_index_list( list_output_str, 'Emissions|CO2|AFOLU');
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
    if current_time_im==yr_start & k==1;list_output_comments(counterLine)="";end;
end;

varname = 'Emissions|F-Gases'; // Total Mt CO2-equiv/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2-equiv/yr";
end;

varname = 'Emissions|Kyoto Gases';// |Total'; //        Mt CO2-equiv/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2-equiv/yr";
end;

varname = 'Carbon Capture|Storage|Fossil';
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

varname = 'Carbon Capture|Storage|Industrial Processes'; //  #NEWVARIABLE
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Capture|Storage';
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
)/1e6 - emi_evitee(k,:)/1e6 ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Capture|Storage|Fossil|Energy|Supply';
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

varname = 'Carbon Capture|Storage|Fossil|Energy|Supply|Electricity';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= ( ..
    + coef_Q_CO2_ref(k,coal) * (..
    + energy_balance(pwplant_eb,elec_eb)* sum(msh_elec_techno(k,[indice_PSS indice_CGS])) ..
    ) ..
    + coef_Q_CO2_ref(k,gaz) * (..
    + energy_balance(pwplant_eb,elec_eb)  * sum(msh_elec_techno(k,[indice_GGS])) ..
) )/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Capture|Storage|Biomass';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  - emi_evitee(k,:)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Capture|Storage|Biomass|Energy|Supply|Electricity';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if output_specific_ar6==%t // this is deprecated for the tunk. only usefull when copyng those file to a previous Imaclim version
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee(k)/1e6 ;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee_elec(k)/1e6 ;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Capture|Storage|Biomass|Energy|Supply|Hydrogen';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_NLU > 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee_hdr(k)/1e6 ;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan ;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Capture|Storage|Biomass|Energy|Supply|Liquids';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= 0 ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Capture|Industrial Processes'; //  #NEWVARIABLE
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Capture';
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
)/1e6 - emi_evitee(k,:)/1e6 ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Capture|Fossil|Energy|Supply';
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

varname = 'Carbon Capture|Fossil|Energy|Supply|Electricity';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= ( ..
    + coef_Q_CO2_ref(k,coal) * (..
    + energy_balance(pwplant_eb,elec_eb)* sum(msh_elec_techno(k,[indice_PSS indice_CGS])) ..
    ) ..
    + coef_Q_CO2_ref(k,gaz) * (..
    + energy_balance(pwplant_eb,elec_eb)  * sum(msh_elec_techno(k,[indice_GGS])) ..
) )/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Capture|Biomass';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  - emi_evitee(k,:)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Capture|Biomass|Energy|Supply|Electricity';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if output_specific_ar6==%t // this is deprecated for the tunk. only usefull when copyng those file to a previous Imaclim version
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee(k)/1e6 ;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee_elec(k)/1e6 ;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Capture|Biomass|Energy|Supply|Hydrogen';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_NLU > 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee_hdr(k)/1e6 ;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan ;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Capture|Biomass|Energy|Supply|Liquids';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= 0 ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Removal';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee(k,:)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Removal|Geological Storage';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee(k,:)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Removal|Enhanced Weathering';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Removal|Land Use';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Removal|Ocean';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Removal|Materials';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Gross Emissions|CO2|Industrial Processes';
lineVAR1 = find_index_list( list_output_str, 'Emissions|CO2|Industrial Processes');
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Gross Emissions|CO2|Energy';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,:))/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Gross Emissions|CO2|Energy and Industrial Processes';
lineVAR1 = find_index_list( list_output_str, 'Gross Emissions|CO2|Industrial Processes');
lineVAR2 = find_index_list( list_output_str, 'Gross Emissions|CO2|Energy');
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Gross Emissions|CO2';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Gross Emissions|CO2|Energy and Industrial Processes');
lineVAR2 = find_index_list( list_output_str, 'Emissions|CO2|AFOLU|Land|Positive');
lineVAR3 = find_index_list( list_output_str, 'Emissions|CO2|AFOLU|Agriculture');
outputs_temp(nbLines*(k-1)+counterLine,current_time+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time+1)+outputs_temp(nbLines*(k-1)+lineVAR3,current_time+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Expenditure|Government'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DG(k,:).*pArmDG(k,:))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000 * usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'Expenditure|Household'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DF(k,:).*pArmDF(k,:))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000 * usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'Expenditure|household|Energy'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DF(k,energyIndexes).*pArmDF(k,energyIndexes))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000 * usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'Expenditure|household|Food'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DF(k,indice_agriculture).*pArmDF(k,indice_agriculture))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000 * usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'Consumption'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DF(k,:).*pArmDF(k,:) + DG(k,:).*pArmDG(k,:))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000 * usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

//Consumption|Dx % share of  total consumption accruing to each Decile
varname = 'Consumption|D1'; // Share of  total consumption accruing to decile 1
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,1)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D1'; // Share of  total income accruing to decile 1
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,1)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D1'; // Share of food consumption accruing to decile 1
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D1'; // Share of consumption for transportation accruing to decile 1
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D1'; // Share of consumption for energy use in buildings accruing to decile 1
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Inequality index|Gini'; // Gini index
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = gini_income(k);
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "index";end;//

varname = 'Inequality index|Absolute Poverty'; // Absolute Povert Rate (1.9$ threshold)
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = poverty_rate(k);
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "index";end;//

varname = 'Consumption|D2'; // Share of  total consumption accruing to decile 2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,2)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D2'; // Share of  total income accruing to decile 2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,2)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D2'; // Share of food consumption accruing to decile 2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D2'; // Share of consumption for transportation accruing to decile 2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D2'; // Share of consumption for energy use in buildings accruing to decile 2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D3'; // Share of  total consumption accruing to decile 3
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,3)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D3'; // Share of  total income accruing to decile 3
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,3)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D3'; // Share of food consumption accruing to decile 3
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D3'; // Share of consumption for transportation accruing to decile 3
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D3'; // Share of consumption for energy use in buildings accruing to decile 3
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D4'; // Share of  total consumption accruing to decile 4
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,4)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D4'; // Share of  total income accruing to decile 4
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,4)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D4'; // Share of food consumption accruing to decile 4
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D4'; // Share of consumption for transportation accruing to decile 4
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D4'; // Share of consumption for energy use in buildings accruing to decile 4
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D5'; // Share of  total consumption accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,5)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D5'; // Share of  total income accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,5)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D5'; // Share of food consumption accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D5'; // Share of consumption for transportation accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D5'; // Share of consumption for energy use in buildings accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D6'; // Share of  total consumption accruing to decile 6
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,6)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D6'; // Share of  total income accruing to decile 6
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,6)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D6'; // Share of food consumption accruing to decile 6
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D6'; // Share of consumption for transportation accruing to decile 6
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D6'; // Share of consumption for energy use in buildings accruing to decile 6
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D7'; // Share of  total consumption accruing to decile 7
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,7)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D7'; // Share of  total income accruing to decile 7
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,7)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D7'; // Share of food consumption accruing to decile 7
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D7'; // Share of consumption for transportation accruing to decile 7
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D7'; // Share of consumption for energy use in buildings accruing to decile 7
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D8'; // Share of  total consumption accruing to decile 8
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,8)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D8'; // Share of  total income accruing to decile 8
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,8)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D8'; // Share of food consumption accruing to decile 8
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D8'; // Share of consumption for transportation accruing to decile 8
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D8'; // Share of consumption for energy use in buildings accruing to decile 8
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D9'; // Share of  total consumption accruing to decile 9
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,9)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D9'; // Share of  total income accruing to decile 9
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,9)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D9'; // Share of food consumption accruing to decile 9
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D9'; // Share of consumption for transportation accruing to decile 9
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D9'; // Share of consumption for energy use in buildings accruing to decile 9
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D10'; // Share of  total consumption accruing to decile 10
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,10)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D10'; // Share of  total income accruing to decile 10
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,10)*100;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D10'; // Share of food consumption accruing to decile 10
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D10'; // Share of consumption for transportation accruing to decile 10
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D10'; // Share of consumption for energy use in buildings accruing to decile 10
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_inequality == 1 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; 
end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

if ind_climat > 2 & ind_climat <>99

    varname = 'Policy Cost|Default';
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = - ( sum(DF(k,:).*pArmDF(k,:)) - sum(base_DF(k,:,current_time_im+1) .* base_pArmDF(k,:,current_time_im+1)))/1e3*usd_year1_year2;

varname = 'Policy Cost|Area under MAC Curve';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;

varname = 'Policy Cost|GDP Loss';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="GDP MER";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (GDP_MER_real(k) - GDP_base_MER_real(k,current_time_im+1)) / 1e3*usd_year1_year2; // negative numbers requested by EMF

varname = 'Policy Cost|Consumption Loss';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ( sum(DF(k,:).*pArmDF(k,:)) - sum(base_DF(k,:,current_time_im+1) .* base_pArmDF(k,:,current_time_im+1)))/1e3*usd_year1_year2;

varname = 'Policy Cost|Equivalent Variation';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; // fixme

varname = 'Policy Cost|Additional Total Energy System Cost';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energyInvestment(k) - energyInvestment_base(k,current_time_im+1)) / 1e3 * usd_year1_year2;

else
    varname_temp = 'Policy Cost|Default';
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;

varname_temp = 'Policy Cost|Area under MAC Curve';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;

varname_temp = 'Policy Cost|GDP Loss';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;

varname_temp = 'Policy Cost|Consumption Loss';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;

varname_temp = 'Policy Cost|Equivalent Variation';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; // fixme

varname_temp = 'Policy Cost|Additional Total Energy System Cost';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;

end


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

varname = 'Price|Primary Energy|Biomass'; //   US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_NLU >0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = bioener_costs_Farmgate(k) * usd_year1_year2; //todo
else
    if sum(prod_elec_techno(k,technoBiomass)) + prod_BFU(k)==0
        outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
    else
        qBiom = (msh_elec_techno(k,indice_BIG) / rho_elec_nexus(k,indice_BIG) ..
            + msh_elec_techno(k,indice_BIS) / rho_elec_nexus(k,indice_BIS))..
        * energy_balance(pwplant_eb,8,k);
        outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=(prod_BFU(k) *  p(k,et) + costBIGCC_noTax(k) * qBiom) * usd_year1_year2 / tep2gj ..
        /(qBiom + prod_BFU(k));
    end
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";end;

varname = 'Price|Primary Energy|Coal'; //   US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = p(k,indice_coal)*usd_year1_year2/tep2gj;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";
end;

varname = 'Price|Primary Energy|Gas'; //    US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = p(k,indice_gas)*usd_year1_year2/tep2gj;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";
end;

varname = 'Price|Primary Energy|Oil'; //    US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = p(k,indice_oil)*usd_year1_year2/tep2gj;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";
end;

varname = 'Price|Secondary Energy|Electricity'; //  US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = pArmCI(indice_elec,indice_composite,k)*usd_year1_year2/tep2gj;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";
end;

varname = 'Price|Secondary Energy|Liquids'; //  US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = pArmCI(indice_Et,indice_composite,k)*usd_year1_year2/tep2gj;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";
end;

varname = 'Price|Secondary Energy|Gases'; //  US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";
end;

varname = 'Price|Secondary Energy|Gases|Fossil'; //  US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";
end;

varname = 'Energy Service|Transportation|Passenger|Domestic Aviation'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = alphaair(k).*DF(k,indice_air).*pkmautomobileref(k)./100 / 1e9 .* ShareDomAviation_2014(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";end;

varname = 'Energy Service|Bunkers|Passenger|International Aviation'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = alphaair(k).*DF(k,indice_air).*pkmautomobileref(k)./100 / 1e9 .* (1-ShareDomAviation_2014(k));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";end;

varname = 'Energy Service|Transportation|Passenger|Road|LDV'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (Tautomobile(k)*pkmautomobileref(k) /100 + pkm_ldv_in_OT(k))/ 1e9;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";end;

varname = 'Energy Service|Transportation|Passenger|Road|Bus'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = EnergyServices_road_pass(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";list_output_comments(counterLine)="Our disaggregation of the transportation sector does not distinguish rail from buses (i.e. public transport), so bus transportation is accounted with Railways .";end;

varname = 'Energy Service|Transportation|Passenger|Road'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR1 = find_index_list( list_output_str, 'Energy Service|Transportation|Passenger|Road|LDV');
lineVAR2 = find_index_list( list_output_str, 'Energy Service|Transportation|Passenger|Road|Bus');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";list_output_comments(counterLine)="Our disaggregation of the transportation sector does not distinguish rail from buses (i.e. public transport), so this output includes passenger rail.";end;

varname = 'Energy Service|Transportation|Passenger|Railways'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = EnergyServices_rail_pass(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";list_output_comments(counterLine)="Beta version";end;

varname = 'Energy Service|Transportation|Passenger|Walking'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";list_output_comments(counterLine)="Our disaggregation of the transportation sector does not distinguish actives modes, so this output is included in Cycling.";end;
	
varname = 'Energy Service|Transportation|Passenger|Cycling'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = TNM(k).*pkmautomobileref(k) ./100/ 1e9;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";list_output_comments(counterLine)="Our disaggregation of the transportation sector does not distinguish actives modes, so this output includes Walking.";end;

varname = 'Energy Service|Transportation|Passenger'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";list_output_comments(counterLine)="Note that this does not include passenger water transport.";end;
lineVAR1 = find_index_list( list_output_str, 'Energy Service|Transportation|Passenger|Road');
lineVAR2 = find_index_list( list_output_str, 'Energy Service|Transportation|Passenger|Domestic Aviation');
lineVAR4 = find_index_list( list_output_str, 'Energy Service|Transportation|Passenger|Railways');
lineVAR5 = find_index_list( list_output_str, 'Energy Service|Transportation|Passenger|Cycling');
lineVAR6 = find_index_list( list_output_str, 'Energy Service|Transportation|Passenger|Walking');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR1,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR2,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR3,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR4,current_time_im+1) + outputs_temp(nbLines*(k-1)+lineVAR5,current_time_im+1); // + outputs_temp(nbLines*(k-1)+lineVAR6,current_time_im+1);

varname = 'Energy Service|Transportation|Freight'; //   bn tkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (Q(k,indice_OT)-DF(k,indice_OT)+Q(k,indice_mer)-DF(k,indice_mer)+Q(k,indice_air)-DF(k,indice_air))/convfactorOT_tkmtoDF(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn tkm/yr";list_output_comments(counterLine)="We use pseudo-quantities as a proxy of tkm/yr, so only the variation can be analysed compared to model results in tkm/yr. We used it to calibrate the sufficiency assumption.";end;

varname = 'Energy Service|Bunkers|Freight|International Aviation'; //   bn tkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (Q(k,indice_air)-DF(k,indice_air))*(1-ShareDomAviation_2014(k))/convfactorOT_tkmtoDF(k); 
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn tkm/yr";list_output_comments(counterLine)="We use pseudo-quantities as a proxy of tkm/yr, so only the variation can be analysed compared to model results in tkm/yr. We used it to calibrate the sufficiency assumption.";end;

varname = 'Energy Service|Bunkers|Freight|International Shipping'; //   bn tkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (Q(k,indice_mer)-DF(k,indice_mer))/convfactorOT_tkmtoDF(k); 
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn tkm/yr";list_output_comments(counterLine)="We use pseudo-quantities as a proxy of tkm/yr, so only the variation can be analysed compared to model results in tkm/yr. We used it to calibrate the sufficiency assumption.";end;
  
varname = 'Energy Service|Residential|Floor Space'; //   bn m2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = stockbatiment(k)/10^9;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn m2";
end;

varname = 'Energy Service|Buildings|Residential|SpacePerCapita'; //   m²/cap
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = stockbatiment(k)/Ltot(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "m²";
end;

varname = 'Energy Service|Buildings|Residential|Space_BAU'; //   m²
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = stockbatiment_BAU(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "m²";
end;

varname = 'Energy Service|Buildings|Residential|Space_SLE'; //   m²
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = stockbatiment_SLE(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "m²";
end;

varname = 'Energy Service|Buildings|Residential|Space_VLE'; //   m²
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = stockbatiment_VLE(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "m²";
end;

varname = 'Final Energy|Buildings|Residential|ConstructionRenovation|Share_BAU'; //   %
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = MSH_res(k,1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Final Energy|Buildings|Residential|ConstructionRenovation|Share_SLE'; //   %
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = MSH_res(k,2);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Final Energy|Buildings|Residential|ConstructionRenovation|Share_VLE'; //   %
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = MSH_res(k,3);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Final Energy|Buildings|Residential|share_demolition_BAU'; //   
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_demolition(k,1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;

varname = 'Final Energy|Buildings|Residential|share_demolition_SLE'; //   %
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_demolition(k,2);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;

varname = 'Final Energy|Buildings|Residential|share_demolition_VLE'; //   %
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_demolition(k,3);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;

varname = 'Energy Service|Transportation|Number of cars'; //   base 100
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = stockautomobile(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "base 100";end;

varname = 'Energy Service|Transportation|Cars per capita'; //  to be checked
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = nb_car_pc(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "unit to be checked";end;

varname = 'Energy Service|Transportation|Occupancy rate cars'; //  to be checked
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = tauxderemplissageauto(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "unit to be checked";end;

varname = 'Energy Service|Transportation|Basic needs automobile'; //   base 100
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = bnautomobile(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "pkm (to be checked)";end;

varname = 'Energy Service|Transportation|alphaCompositeauto'; //   Composite goods consumption linked to car use (per pkm)
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = alphaCompositeauto(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "per pkm";end;


varname = 'Transportation|Capacity cars'; //   No unit
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Captransport(k,ind_hsld_transpCar);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "No unit";end;

varname = 'Transportation|Capacity air'; //   No unit
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Captransport(k,ind_hsld_transpAir);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "No unit";end;

varname = 'Transportation|Capacity OT'; //   No unit
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Captransport(k,ind_hsld_transpOT);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "No unit";end;

varname = 'Transportation|Utilisation rate cars'; //   %
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = URtransport(k,ind_hsld_transpCar);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;

varname = 'Transportation|Utilisation rate air'; //   %
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = URtransport(k,ind_hsld_transpAir);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;

varname = 'Transportation|Utilisation rate OT'; //   %
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = URtransport(k,ind_hsld_transpOT);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;

varname = 'Transportation|Investment construction transport'; //   %
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = DIinfra(k,indice_construction);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;

varname = 'Transportation|Stock infrastructure road'; //   base 100
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = stockinfra(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "base 100";end;

varname = 'Value Added|Total'; //	billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(VA(k,:))/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'Value Added|Fossil Fuels'; //	billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(VA(k,indice_coal:indice_Et))/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'Value Added|Fossil Fuels|Coal'; //	billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = VA(k,1)/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'Value Added|Fossil Fuels|Gas'; //	billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = VA(k,2)/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'Value Added|Fossil Fuels|Oil'; //	billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = VA(k,3)/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'Value Added|Fossil Fuels|ET'; //	billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = VA(k,4)/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'Value Added|Elec'; //	billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = VA(k,5)/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'Value Added|Transport'; //	billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(VA(k,indice_transport_1:indice_transport_2))/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'Value Added|Transport|Land transport'; //	billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = VA(k,10)/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'Value Added|Transport|Air transport'; //	billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = VA(k,8)/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'Value Added|Transport|Water transport'; //	billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = VA(k,9)/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'Value Added|Construction'; //	billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = VA(k,6)/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'Value Added|Agriculture'; //	billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = VA(k,11)/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'Value Added|Industry'; //	billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = VA(k,12)/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'Value Added|Composite'; //billion US$2010
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = VA(k,7)/1000*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;


varname = 'Employment'; //    			Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(labor_ILO(k,:))/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Employment|Fossil Fuels'; //    	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(labor_ILO(k,indice_coal:indice_Et))/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Employment|Fossil Fuels|Coal'; //    	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,1)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Employment|Fossil Fuels|Gas'; //    	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,2)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Employment|Fossil Fuels|Oil'; //    	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,3)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Employment|Fossil Fuels|ET'; //    	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,4)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Employment|Elec'; //    	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,5)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Employment|Transport'; //    	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(labor_ILO(k,indice_transport_1:indice_transport_2))/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Employment|Transport|Land Transport'; //    	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,10)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Employment|Transport|Air Transport'; //    	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,8)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Employment|Transport|Water transport'; //    	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,9)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Employment|Construction'; //    	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,6)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Employment|Agriculture'; //   	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,11)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Employment|Industrie'; //    	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,12)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Employment|Composite'; //    	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,7)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Unemployment'; //	    	Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 1-sum(labor_ILO(k,:))/Lact(k); // corrigé après les dernières simulations, peut-être un problème d'ordre de grandeur ?
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";end;

varname = 'Unemployment_z'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Z(k); 
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;
  
varname = 'Labor Productivity growth'; //   
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = TC_l(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Labor Productivity|Coal'; //   
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = l(k,1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Labor Productivity|Oil'; //   
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = l(k,2);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Labor Productivity|Gas'; //   
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = l(k,3);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Labor Productivity|ET'; //   
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = l(k,4);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Labor Productivity|Electricity'; //   
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = l(k,5);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Labor Productivity|Construction'; //   
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = l(k,6);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Labor Productivity|Composite'; //   
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = l(k,7);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Labor Productivity|Air transport'; //   
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = l(k,8);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Labor Productivity|Water transport'; //   
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = l(k,9);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Labor Productivity|Terrestrial transport'; //   
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = l(k,10);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Labor Productivity|Agriculture'; //   
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = l(k,11);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Labor Productivity|Industry'; //   
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = l(k,12);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'consumption|value|Total'; //   "billion US$2010"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DF(k,:).*p(k,:))/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'consumption|value|Agriculture'; //  "billion US$2010"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = DF(k,indice_agriculture).*p(k,indice_agriculture)/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'consumption|value|Construction'; //   "billion US$2010"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = DF(k,indice_construction).*p(k,indice_construction)/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'consumption|value|Services'; //   "billion US$2010"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = DF(k,indice_composite).*p(k,indice_composite)/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'consumption|value|Other industries'; //   "billion US$2010"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = DF(k,indice_industries).*p(k,indice_industries)/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'consumption|value|Fossil fuels'; //   "billion US$2010"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DF(k,indice_coal:indice_Et).*p(k,indice_coal:indice_Et))/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'consumption|value|Electricity'; //   "billion US$2010"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = DF(k,indice_elec).*p(k,indice_elec)/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'consumption|value|Transportation'; //   "billion US$2010"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DF(k,indice_transport_1:indice_transport_2).*p(k,indice_transport_1:indice_transport_2))/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010";end;

varname = 'consumption|volume|Total'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DF(k,:))/1e3;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'consumption|volume|Agriculture'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = DF(k,indice_agriculture)/1e3;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'consumption|volume|Construction'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = DF(k,indice_construction)/1e3;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'consumption|volume|Services'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = DF(k,indice_composite)/1e3;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'consumption|volume|Other industries'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = DF(k,indice_industries)/1e3;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'consumption|volume|Fossil fuels'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DF(k,indice_coal:indice_Et))/1e3;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'consumption|volume|Electricity'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = DF(k,indice_elec)/1e3;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'consumption|volume|Transportation'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DF(k,indice_transport_1:indice_transport_2))/1e3;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;
  
  
varname = 'Production|value|Total'; //   "billion US$2014/yr"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Q(k,:).*p(k,:))/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";end;

varname = 'Production|value|Agriculture'; //   "billion US$2014/yr"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_agriculture).*p(k,indice_agriculture)/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";end;

varname = 'Production|value|Construction'; //   "billion US$2014/yr"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_construction).*p(k,indice_construction)/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";end;

varname = 'Production|value|Services'; //   "billion US$2014/yr"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_composite).*p(k,indice_composite)/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";end;

varname = 'Production|value|Other industries'; //   "billion US$2014/yr"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_industries).*p(k,indice_industries)/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";end;

varname = 'Production|value|Fossil fuels'; //   "billion US$2014/yr"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Q(k,indice_coal:indice_Et).*p(k,indice_coal:indice_Et))/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";end;

varname = 'Production|value|Electricity'; //   "billion US$2014/yr"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_elec).*p(k,indice_elec)/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";end;

varname = 'Production|value|Transportation'; //   "billion US$2014/yr"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Q(k,indice_transport_1:indice_transport_2).*p(k,indice_transport_1:indice_transport_2))/1e3*usd_year1_year2/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";end;


varname = 'Production|Total'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Q(k,:));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'Production|Agriculture'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_agriculture);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'Production|Construction'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_construction);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'Production|Services'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_composite);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'Production|Other industries'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_industries);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'Production|Fossil fuels'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Q(k,indice_coal:indice_Et));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'Production|Electricity'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_elec);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'Production|Transportation'; //   "Mtoe or pseudo-quantities"
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Q(k,indice_transport_1:indice_transport_2));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";end;

varname = 'Investment|Construction';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (pK(k,indice_construction).*DeltaK(k,indice_construction) )*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Investment|Transportation';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum((pK(k,indice_transport_1:indice_transport_2).*DeltaK(k,indice_transport_1:indice_transport_2)))*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Investment|Agriculture';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (pK(k,indice_agriculture).*DeltaK(k,indice_agriculture) )*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Investment|Industry';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (pK(k,indice_industries).*DeltaK(k,indice_industries) )*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

varname = 'Investment|Composite';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (pK(k,indice_composite).*DeltaK(k,indice_composite) )*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;


varname = 'Trade|Value|Exports'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Exp(k,:).*p(k,:))/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Exports|Agriculture'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Exp(k,indice_agriculture).*p(k,indice_agriculture)/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Exports|Fossil fuels'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Exp(k,indice_coal:indice_Et).*p(k,indice_coal:indice_Et))/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Exports|Electricity'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Exp(k,indice_elec).*p(k,indice_elec)/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Exports|Industries'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Exp(k,indice_industries).*p(k,indice_industries))/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Exports|Construction'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Exp(k,indice_construction).*p(k,indice_construction)/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Exports|Services'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Exp(k,[transportIndexes indice_composite]).*p(k,[transportIndexes indice_composite]))/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;



varname = 'Trade|Value|Imports'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Imp(k,:).*wp)/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Imports|Agriculture'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Imp(k,indice_agriculture).*wp(indice_agriculture)/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Imports|Fossil fuels'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Imp(k,indice_coal:indice_Et).*wp(indice_coal:indice_Et))/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Imports|Electricity'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Imp(k,indice_elec).*wp(indice_elec)/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Imports|Industries'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Imp(k,indice_industries).*wp(indice_industries))/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Imports|Construction'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Imp(k,indice_construction).*wp(indice_construction)/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Imports|Services'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Imp(k,[transportIndexes indice_composite]).*wp([transportIndexes indice_composite]))/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Transportation|Cars|Ice|Fuel efficiency'; //  
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = EFF_ICE(k,current_time_im);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Consumption|household|xsi|industry';  // xsi indus
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = xsi(k,5);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Consumption|household|xsi|composite';  // xsi services
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = xsi(k,2);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Consumption|household|xsi|construction';  // xsi construction
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = xsi(k,1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Consumption|household|xsi|agriculture';  // xsi agri
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = xsi(k,4);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Consumption|household|xsi|mer';  // xsi mer
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = xsi(k,3);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Consumption|household|xsiT';  // xsi mer
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = xsiT(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'CI|industry|volume|total';  // total des consos intermediaires en bien industriels
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(CI(indice_industries,:,k));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'CI|industry|volume|industry';  //  autoconsos intermediaires en bien industriels
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CI(indice_industries,indice_industries,k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'CI|industry|volume|composite';  // consos intermediaires en bien industriels du secteur composite
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CI(indice_industries,indice_composite,k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'CI|industry|value|total';  // total des consos intermediaires en bien industriels
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(CI(indice_industries,:,k).*pArmCI(indice_industries,:,k));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'CI|industry|value|industry';  //  autoconsos intermediaires en bien industriels
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CI(indice_industries,indice_industries,k).*pArmCI(indice_industries,indice_industries,k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'CI|industry|value|composite';  // consos intermediaires en bien industriels du secteur composite
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CI(indice_industries,indice_composite,k).*pArmCI(indice_industries,indice_composite,k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Final Energy|Industry|only'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(energy_balance(conso_indu_eb,:,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Energy efficiency|EEI|industry';  // Cumul de toute l'efficacité energétique autonome + induite
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im > 1
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = E_enerdelta(k,indice_industries,current_time_im-1);
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 1;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Energy efficiency|AEEI|industry';  // Cumul de toute l'efficacité energétique autonome
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im > 1
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = E_enerdeltaFree(k,indice_industries,current_time_im-1);
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 1;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;


varname = 'Charge|industry'; // utilisation capacites industry
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=charge(k,indice_industries);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Charge|services'; // utilisation capacites services
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=charge(k,indice_composite);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;


varname = 'Charge|agriculture'; // utilisation capacites 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=charge(k,indice_agriculture);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Charge|elec'; // utilisation capacites 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=charge(k,indice_elec);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Charge|fossil'; // utilisation capacites 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=mean(charge(k,indice_coal:indice_Et));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Charge|transport'; // utilisation capacites 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=mean(charge(k,indice_transport_1:indice_transport_2));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Capital|industry'; // utilisation capacites industry
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=Cap(k,indice_industries);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Capital|services'; // utilisation capacites services
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=Cap(k,indice_composite);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;


varname = 'Capital|agriculture'; // utilisation capacites 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=Cap(k,indice_agriculture);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Capital|elec'; // utilisation capacites 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=Cap(k,indice_elec);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Capital|fossil'; // utilisation capacites 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=sum(Cap(k,indice_coal:indice_Et));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Capital|transport'; // utilisation capacites 
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=sum(Cap(k,indice_transport_1:indice_transport_2));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;


varname = 'Balance commerciale test'; // billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= [sum(Exp(k,:).*p(k,:).*(1 + xtax(k,:))) + sum(ExpTI(k,:).*p(k,:)) - sum(Imp(k,:).*wp) - sum(Imp(k,:).*nit(k,:).*wpTIagg)]/GDP_MER_nominal(k)*GDP_MER_real(k)*usd_year1_year2/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Capital|exports'; // billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= GRB(k).*partExpK(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;
varname = 'Capital|imports'; // billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= NRB(k) - GRB(k).*(1-partExpK(k));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;
