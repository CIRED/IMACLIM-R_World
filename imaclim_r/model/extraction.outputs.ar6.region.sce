// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoBiomassWOCCS))/1000;
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

varname = 'Capacity|Electricity|Ocean'; //GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end

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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,technoBiomassWOCCS) * usd_year1_year2;
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_GGS) * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine in Combined Cycle with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Efficiency|Electricity|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_BIS) * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants with CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Electricity|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,technoBiomassWOCCS) * usd_year1_year2;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants without CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan ;//OM_cost_fixed_nexus(k,indice_WND) * usd_year1_year2;
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,technoBiomassWOCCS) * usd_year1_year2;
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = pK(k,indice_Et) *8760* usd_year1_year2 / tep2gj * kwh2gj;; //todo
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
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
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
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
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
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = yield_CTL; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
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
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Gases|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Gases|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Gases|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Hydrogen|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Hydrogen|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Hydrogen|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Hydrogen|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Hydrogen|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Hydrogen|Electricity'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Liquids|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;


varname = 'Efficiency|Liquids|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Liquids|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Liquids|Oil'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 1 ./mean(Cost_struc_oil_refin_ref( Cost_struc_oil_refin_ref( :,indice_oil)>1,indice_oil)); //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
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


varname = 'Final Energy'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(energy_balance(conso_tot_eb,:,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_indu_eb,elec_eb,k)+energy_balance(conso_agri_eb,elec_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Industry|Gases'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_indu_eb,gas_eb,k)+energy_balance(conso_agri_eb,gas_eb,k))*Mtoe_EJ;
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
+ energy_balance(conso_agri_eb,oil_eb,k) + energy_balance(conso_agri_eb,et_eb,k)  )*Mtoe_EJ;
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

varname = 'Final Energy|Industry|Solids|Coal'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_indu_eb,coal_eb,k)+energy_balance(conso_agri_eb,coal_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Liquids'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(conso_tot_eb,et_eb,k)*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Solids'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(conso_tot_eb,coal_eb,k)*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
varname = 'Final Energy|Other'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other Sector|Electricity'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_btp_eb,elec_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other Sector|Gases'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_btp_eb,gas_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other Sector|Heat'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other Sector|Hydrogen'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other Sector|Liquids'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_btp_eb,oil_eb,k)+energy_balance(conso_btp_eb,et_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other Sector|Other'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other Sector|Solids'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_btp_eb,coal_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Final Energy|Other Sector|Solids|Coal'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_btp_eb,coal_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;

varname = 'Final Energy|Buildings|Residential'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,:,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Residential|Electricity'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,elec_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Residential|Gases'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,gas_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Residential|Heat'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Residential|Hydrogen'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Residential|Liquids'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,et_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Residential|Other'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Residential|Solids'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,coal_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Residential|Solids|Biomass'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Residential|Solids|Coal'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_resid_eb,coal_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Residential|Heating|Space'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Commercial'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,:,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Commercial|Electricity'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,elec_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Commercial|Gases'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,gas_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Commercial|Heat'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Commercial|Hydrogen'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Commercial|Liquids'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,et_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Commercial|Other'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Commercial|Solids'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,coal_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Commercial|Solids|Biomass'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Commercial|Solids|Coal'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,coal_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Buildings|Commercial|Heating|Space'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Solar'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; // this is heat produced by solar. We don't have it.
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_transport_eb,:,k)))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Electricity'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_air_eb,elec_eb,k)+energy_balance(conso_ot_eb,elec_eb,k)+energy_balance(conso_car_eb,elec_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Freight'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    + energy_balance(conso_ot_eb,et_eb,k) * (1 - DF(k,indice_OT )/(Q(k,indice_OT )-Exp(k,indice_OT )+Imp(k,indice_OT )))..
    + energy_balance(conso_air_eb,et_eb,k) * (1 - DF(k,indice_air)/(Q(k,indice_air)-Exp(k,indice_air)+Imp(k,indice_air)))..
) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Gases'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_air_eb,gas_eb,k)+energy_balance(conso_ot_eb,gas_eb,k)+energy_balance(conso_car_eb,gas_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Hydrogen'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(energy_balance(conso_transport_eb,et_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids|Biomass'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_biofuel(k) .* sum(energy_balance(conso_transport_eb,et_eb,k)) *Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids|Coal'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_CTL(k) .* sum(energy_balance(conso_transport_eb,et_eb,k)) *Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids|Natural Gas'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids|Oil'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_oil_refin(k) .* sum(energy_balance(conso_transport_eb,et_eb,k)) *Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Other'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Passenger'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (..
    energy_balance(conso_car_eb,et_eb,k) ..
    + (energy_balance(conso_ot_eb,et_eb,k)*DF(k,indice_OT )/(Q(k,indice_OT )-Exp(k,indice_OT )+Imp(k,indice_OT )))..
    + (energy_balance(conso_air_eb,et_eb,k)*DF(k,indice_air)/(Q(k,indice_air)-Exp(k,indice_air)+Imp(k,indice_air)))..
    + (energy_balance(conso_air_eb,elec_eb,k)+energy_balance(conso_ot_eb,elec_eb,k)+energy_balance(conso_car_eb,elec_eb,k))..
) * Mtoe_EJ;
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(tpes_eb,primary_eb,k)))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";end;
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

varname = 'Resource|Extraction|Oil'; //  EJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_oil)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Resource|Extraction|Fossil'; //  EJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ( Q(k,indice_oil) +Q(k,indice_gas)+Q(k,indice_coal))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(delta_Cap_elec_MW_1(k,technoBiomassWOCCS).*CINV_MW_nexus(k,technoBiomassWOCCS))/10^3*usd_year1_year2/1000;
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k)*Mtoe_EJ;
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoBiomassWOCCS))*Mtoe_EJ;
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

varname = 'Secondary Energy|Gases|Natural Gas'; //  EJ/yr
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = energy_balance(refi_eb,et_eb,k)*Mtoe_EJ ;
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

varname = 'Emissions|CO2'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Total CO2 include FFI emissions from Imaclim and AFOLU emissions completed with Silicone https://github.com/GranthamImperial/silicone";end;

varname = 'Emissions|CO2|AFOLU'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="External. Completed from 1.5 database with the help of the Silicone https://github.com/GranthamImperial/silicone";end;

varname = 'Emissions|N2O'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "kt N2O/yr";
end;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="External. Completed from 1.5 database with the help of the Silicone https://github.com/GranthamImperial/silicone";end;

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
end;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="External. Completed from 1.5 database with the help of the Silicone https://github.com/GranthamImperial/silicone";end;


varname = 'Emissions|CO2|Energy and Industrial Processes'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,:))/1e6 + emi_evitee(k)/1e6;
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

varname = 'Emissions|CO2|Energy|Demand|Buildings|Residential and Commercial'; //
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

varname = 'Emissions|CO2|Energy|Demand|Transportation|Road';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (..
    + coef_Q_CO2_DF(k,coal).* energy_balance(conso_car_eb,coal_eb,k) ..
    + coef_Q_CO2_DF(k,oil) .* energy_balance(conso_car_eb,oil_eb,k)  ..
    + coef_Q_CO2_DF(k,gaz) .* energy_balance(conso_car_eb,gas_eb,k)  ..
    + coef_Q_CO2_DF(k,et)  .* energy_balance(conso_car_eb,et_eb,k)   ..
    + E_reg_use(k,iu_OT)  ..
)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";end;

varname = 'Emissions|CO2|Energy|Demand|Transportation|Maritime';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= E_reg_use(k,iu_mer);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";end;

varname = 'Emissions|CO2|Energy|Demand|Other Sector'; //
//Autre secteur : construction (btp)
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = E_reg_use(k,iu_cons)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Industrial Processes'; //	Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Fossil|Industrial Processes';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  %nan;
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

varname = 'Carbon Sequestration|CCS'; //   EJ/yr
lineVAR = find_index_list( list_output_str, 'Carbon Sequestration|CCS|Fossil');
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+lineVAR,current_time_im+1) - emi_evitee(k,:)/1e6 ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";end;

varname = 'Carbon Sequestration|CCS|Fossil|Energy';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR = find_index_list( list_output_str, 'Carbon Sequestration|CCS|Fossil');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  outputs_temp(nbLines*(k-1)+lineVAR,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Fossil|Energy|Supply';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR = find_index_list( list_output_str, 'Carbon Sequestration|CCS|Fossil|Energy');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  outputs_temp(nbLines*(k-1)+lineVAR,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Fossil|Energy|Supply|Electricity';
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

varname = 'Carbon Sequestration|CCS|Biomass|Energy';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  - emi_evitee(k,:)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Biomass';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  - emi_evitee(k,:)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;


varname = 'Carbon Sequestration|CCS|Biomass|Industrial Processes';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Biomass|Energy|Supply';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee(k)/1e6 ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Biomass|Energy|Supply|Electricity';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if output_specific_ar6==%t // this is deprecated for the tunk. only usefull when copyng those file to a previous Imaclim version
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee(k)/1e6 ;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee_elec(k)/1e6 ;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Biomass|Energy|Supply|Hydrogen';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_NLU > 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee_hdr(k)/1e6 ;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= %nan ;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Biomass|Energy|Supply|Liquids';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= 0 ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|F-Gases'; // Total	Mt CO2-equiv/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2-equiv/yr";
end;

varname = 'Emissions|Kyoto Gases';// |Total'; //	Mt CO2-equiv/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2-equiv/yr";
end;


varname = 'Consumption'; // billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(DF(k,:).*pArmDF(k,:)))/1e3*usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

if ind_climat > 2 & ind_climat <>99

    varname = 'Policy Cost|Default for CAV';
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
    varname_temp = 'Policy Cost|Default for CAV';
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
        qBiom = (sum(msh_elec_techno(k,technoBiomassWOCCS) ./ rho_elec_nexus(k,technoBiomassWOCCS)) ..
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
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ"; // DESAG_INDUSTRY: has been changed as the carbon tax is not included anymore in the price
end;

varname = 'Price|Secondary Energy|Liquids'; //  US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = pArmCI(indice_Et,indice_composite,k)*usd_year1_year2/tep2gj;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ"; 
end; // DESAG_INDUSTRY: has been changed as the carbon tax is not included anymore in the price

varname = 'Price|Secondary Energy|Gases|Natural Gas'; //  US$2010/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/GJ";
end;

varname = 'Energy Service|Transportation|Passenger'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (Tair(k) + Tautomobile(k) + TOT(k) + TNM(k)) * pkmautomobileref(k) / 100 / 1e9;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";end;

varname = 'Energy Service|Transportation|Passenger|Aviation'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = alphaair(k).*DF(k,indice_air).*pkmautomobileref(k)./100 / 1e9;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";end;

varname = 'Energy Service|Transportation|Passenger|Road'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (Tautomobile(k) + alphaOT(k).*DF(k,indice_OT))* pkmautomobileref(k) / 100 / 1e9;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";end;

varname = 'Energy Service|Transportation|Passenger|Road|LDV'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Tautomobile(k).*pkmautomobileref(k) ./100/ 1e9;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";end;

varname = 'Energy Service|Transportation|Passenger|Road|Bus'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = alphaOT(k).*DF(k,indice_OT).*pkmautomobileref(k)./100 / 1e9;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";end;

varname = 'Energy Service|Transportation|Freight'; //   bn tkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn tkm/yr";
end;


