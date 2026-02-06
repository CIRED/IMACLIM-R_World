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

varname = 'Capacity|Electricity|Coal'; // GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoElecCoal))/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Gas'; //GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Cap_elec_MW(k,technoElecGas))/1000;
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

varname = 'Capacity|Electricity|Wind|Offshore'; //GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //Cap_elec_MW(k,indice_WNO)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

varname = 'Capacity|Electricity|Wind|Onshore'; // GW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; Cap_elec_MW(k,indice_WND)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "GW";end;

// CAPITAL COSTS ELECTRICITY
varname = 'Capital Cost|Electricity|Coal|w/ CCS'; // $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_CGS) * usd2001_2005 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Integrated Coal Gasification with Combined Cycle with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_ICG) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Integrated Coal Gasification with Combined Cycle";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Coal|w/ CCS|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_PSS) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Super Critical pulverised coal with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Coal|w/o CCS|2'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_PFC) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Super Critical pulverised coal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Coal|w/o CCS|3'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_LCT) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Lignite-powered Conventional Thermal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Coal|w/o CCS|4'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_CCT) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Coal-powered Conventional Thermal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;
varname = 'Capital Cost|Electricity|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_GGS) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine in Combined Cycle with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_GGC) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine in Combined Cycle";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Gas|w/o CCS|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_GGT) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine TAC";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Gas|w/o CCS|3'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_GCT) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Conventional Thermal TAV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Geothermal'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Nuclear'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_NUC) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Conventional Light-Water nuclear Reactor";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Nuclear|2'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_NND) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="New Nuclear Design";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Solar|CSP'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_CSP)  * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Concentrated solar power";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Solar|PV'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_CPV)  * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Central PV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Solar|PV|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_RPV)  * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Rooftop PV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Transmission|AC'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Transmission|DC'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Wind'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_WNO) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Offshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Wind|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //CINV_MW_nexus(k,indice_WND) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Onshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Wind|Offshore'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //CINV_MW_nexus(k,indice_WNO) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Offshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Wind|Onshore'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //CINV_MW_nexus(k,indice_WND) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Onshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_BIS) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants with CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_BIG) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants without CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Hydro'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_HYD) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Conventional, large-size hydroelectricity";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;

varname = 'Capital Cost|Electricity|Hydro|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = CINV_MW_nexus(k,indice_SHY) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Small Hydroelectricity";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";end;



// Efficiency ELECTRICITY
varname = 'Efficiency|Electricity|Coal|w/ CCS'; // $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_CGS) * usd2001_2005 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Integrated Coal Gasification with Combined Cycle with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Efficiency|Electricity|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_ICG) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Integrated Coal Gasification with Combined Cycle";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Efficiency|Electricity|Coal|w/ CCS|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_PSS) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Super Critical pulverised coal with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Efficiency|Electricity|Coal|w/o CCS|2'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_PFC) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Super Critical pulverised coal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Efficiency|Electricity|Coal|w/o CCS|3'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_LCT) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Lignite-powered Conventional Thermal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Efficiency|Electricity|Coal|w/o CCS|4'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_CCT) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Coal-powered Conventional Thermal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Efficiency|Electricity|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_GGS) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine in Combined Cycle with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Efficiency|Electricity|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_GGC) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine in Combined Cycle";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;

varname = 'Efficiency|Electricity|Gas|w/o CCS|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_GGT) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine TAC";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Electricity|Gas|w/o CCS|3'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_GCT) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Conventional Thermal TAV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;


varname = 'Efficiency|Electricity|Nuclear'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_NUC) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Conventional Light-Water nuclear Reactor";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Electricity|Nuclear|2'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_NND) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="New Nuclear Design";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;


varname = 'Efficiency|Electricity|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_BIS) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants with CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Electricity|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = rho_elec_nexus(k,indice_BIG) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants without CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;


// OM Cost|Fixed ELECTRICITY
varname = 'OM Cost|Fixed|Electricity|Coal|w/ CCS'; // $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_CGS) * usd2001_2005 ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Integrated Coal Gasification with Combined Cycle with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_ICG) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Integrated Coal Gasification with Combined Cycle";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Coal|w/ CCS|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_PSS) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Super Critical pulverised coal with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Coal|w/o CCS|2'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_PFC) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Super Critical pulverised coal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Coal|w/o CCS|3'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_LCT) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Lignite-powered Conventional Thermal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Coal|w/o CCS|4'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_CCT) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Coal-powered Conventional Thermal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_GGS) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine in Combined Cycle with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_GGC) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine in Combined Cycle";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Gas|w/o CCS|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_GGT) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine TAC";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Gas|w/o CCS|3'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_GCT) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Conventional Thermal TAV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Geothermal'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Nuclear'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_NUC) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Conventional Light-Water nuclear Reactor";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Nuclear|2'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_NND) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="New Nuclear Design";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Solar|CSP'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_CSP)  * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Concentrated solar power";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;
varname = 'OM Cost|Variable|Electricity|CSP'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Concentrated solar power";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Fixed|Electricity|Solar|PV'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_CPV)  * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Central PV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;
varname = 'OM Cost|Variable|Electricity|PV'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Central PV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;


varname = 'OM Cost|Fixed|Electricity|Solar|PV|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_RPV)  * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Rooftop PV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Wind'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_WNO) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Offshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Wind|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan ;OM_cost_fixed_nexus(k,indice_WND) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Onshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Wind|Offshore'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan ;//OM_cost_fixed_nexus(k,indice_WNO) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Offshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Wind|Onshore'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //OM_cost_fixed_nexus(k,indice_WND) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Onshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_BIS) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants with CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_BIG) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants without CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Hydro'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_HYD) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Conventional, large-size hydroelectricity";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Electricity|Hydro|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_fixed_nexus(k,indice_SHY) * usd2001_2005;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Small Hydroelectricity";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

// OM Cost|Variable ELECTRICITY
varname = 'OM Cost|Variable|Electricity|Coal|w/ CCS'; // $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_CGS) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Integrated Coal Gasification with Combined Cycle with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_ICG) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Integrated Coal Gasification with Combined Cycle";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Coal|w/ CCS|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_PSS) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Super Critical pulverised coal with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Coal|w/o CCS|2'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_PFC) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Super Critical pulverised coal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Coal|w/o CCS|3'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_LCT) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Lignite-powered Conventional Thermal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Coal|w/o CCS|4'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_CCT) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Coal-powered Conventional Thermal";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_GGS) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine in Combined Cycle with sequestration";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_GGC) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine in Combined Cycle";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Gas|w/o CCS|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_GGT) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Gas Turbine TAC";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Gas|w/o CCS|3'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_GCT) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Gas-powered Conventional Thermal TAV";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Geothermal'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Nuclear'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_NUC) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Conventional Light-Water nuclear Reactor";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Nuclear|2'; //  $/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_NND) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="New Nuclear Design";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Wind'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_WNO) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Offshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Wind|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan ;//OM_cost_var_nexus(k,indice_WND) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Onshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Wind|Offshore'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //OM_cost_var_nexus(k,indice_WNO) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Offshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Wind|Onshore'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //OM_cost_var_nexus(k,indice_WND) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Wind turbines Onshore";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_BIS) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants with CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_BIG) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Biomass power plants without CCS";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Hydro'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_HYD) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Conventional, large-size hydroelectricity";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Electricity|Hydro|2'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = OM_cost_var_nexus(k,indice_SHY) * usd2001_2005 / kwh2gj;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Small Hydroelectricity";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'Capital Cost|Gases|Transmission'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Gases|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Gases|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Gases|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Gases|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Heat|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Heat|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Heat|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Heat|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Heat|Geothermal'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Heat|Oil'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Heat|Propane'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Heat|Solar'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Hydrogen|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Hydrogen|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Hydrogen|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Hydrogen|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Hydrogen|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Hydrogen|Electricity'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Liquids|Biomass|Biodiesel|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Liquids|Biomass|Biodiesel|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Liquids|Biomass|Cellulosic Nondiesel|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Liquids|Biomass|Conventional Ethanol|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Liquids|Biomass|Conventional Ethanol|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Liquids|Biomass|Other|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Liquids|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Liquids|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Liquids|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Liquids|Oil'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = pK(k,indice_Et) *8760* usd2001_2005 / tep2gj * kwh2gj;; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;

varname = 'Capital Cost|Liquids|Biomass|Cellulosic Nondiesel|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ethan2G_inv *usd2001_2005;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;
varname = 'Efficiency|Liquids|Biomass|Cellulosic Nondiesel|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Hoowijk_2000_efficiency; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;
varname = 'OM Cost|Fixed|Liquids|Biomass|Cellulosic Nondiesel|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Hoowijk_2000_OM_percent * ethan2G_inv * usd2001_2005; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;
varname = 'OM Cost|Variable|Liquids|Biomass|Cellulosic Nondiesel|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'Capital Cost|Liquids|Biomass|Other|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ethan2G_inv *usd2001_2005;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;
varname = 'Efficiency|Liquids|Biomass|Other|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Hoowijk_2000_efficiency; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;
varname = 'OM Cost|Fixed|Liquids|Biomass|Other|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Hoowijk_2000_OM_percent * ethan2G_inv*usd2001_2005; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;
varname = 'OM Cost|Variable|Liquids|Biomass|Other|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;


varname = 'Capital Cost|Hydrogen|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = h2_gaseif_annualInv * kwh2gj * 8760 *usd2001_2005;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;
varname = 'Efficiency|Hydrogen|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 1 ./ gjh2_2_gjbiom; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;
varname = 'OM Cost|Fixed|Hydrogen|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (h2_gaseif_maintenance-h2_gaseif_emission*h2_gaseif_captureCosts)*kwh2gj * 8760 *usd2001_2005; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;
varname = 'OM Cost|Variable|Hydrogen|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

cost_CTL_OM=cost_CTL_OMref*(sum(Cost_struc_oil_refin_ref(k,elec:sec).*(pArmCI(elec:sec,indice_Et,k)')))./(sum(Cost_struc_oil_refin_ref(k,elec:sec).*(pArmCIref(elec:sec,indice_Et,k)')));
cost_CTL_capital=cost_CTL_capitalref*pK(k,et)./pKref(k,et);
varname = 'Capital Cost|Liquids|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = cost_CTL_capital*8760/tep2kwh*usd2001_2005;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW";
end;
varname = 'Efficiency|Liquids|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = yield_CTL; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;
varname = 'OM Cost|Fixed|Liquids|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = cost_CTL_OM*8760/tep2kwh*usd2001_2005; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;
varname = 'OM Cost|Variable|Liquids|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
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

varname = 'Efficiency|Heat|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Heat|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Heat|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Heat|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Heat|Geothermal'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Heat|Oil'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Heat|Propane'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Heat|Solar'; //$/kW
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

varname = 'Efficiency|Liquids|Biomass|Biodiesel|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Liquids|Biomass|Biodiesel|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Liquids|Biomass|Cellulosic Nondiesel|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;


varname = 'Efficiency|Liquids|Biomass|Conventional Ethanol|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Liquids|Biomass|Conventional Ethanol|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";
end;

varname = 'Efficiency|Liquids|Biomass|Other|w/ CCS'; //$/kW
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
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Gases|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Gases|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Gases|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Heat|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Heat|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Heat|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Heat|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Heat|Geothermal'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Heat|Oil'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Heat|Propane'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Heat|Solar'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;


varname = 'OM Cost|Fixed|Hydrogen|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Hydrogen|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Hydrogen|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Hydrogen|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Hydrogen|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Hydrogen|Electricity'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Liquids|Biomass|Biodiesel|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Liquids|Biomass|Biodiesel|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Liquids|Biomass|Cellulosic Nondiesel|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Liquids|Biomass|Conventional Ethanol|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Liquids|Biomass|Conventional Ethanol|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Liquids|Biomass|Other|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Liquids|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Liquids|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

varname = 'OM Cost|Fixed|Liquids|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
end;

//7 OM cost variables other
varname = 'OM Cost|Variable|Gases|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Gases|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Gases|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Gases|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Heat|Biomass|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Heat|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Heat|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Heat|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Heat|Geothermal'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Heat|Oil'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Heat|Propane'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Heat|Solar'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Hydrogen|Biomass|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Hydrogen|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Hydrogen|Coal|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Hydrogen|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Hydrogen|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Hydrogen|Electricity'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Liquids|Biomass|Biodiesel|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Liquids|Biomass|Biodiesel|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Liquids|Biomass|Cellulosic Nondiesel|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Liquids|Biomass|Conventional Ethanol|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Liquids|Biomass|Conventional Ethanol|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Liquids|Biomass|Other|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Liquids|Coal|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Liquids|Gas|w/ CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Liquids|Gas|w/o CCS'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'OM Cost|Variable|Liquids|Oil'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ( sum((Cost_struc_oil_refin_ref(k,6:sec) .* p(k,6:12))) + Cost_struc_oil_refin_ref(k,sec+1) .* w(k,indice_Et).*(1+sigma(k,indice_Et)).*(energ_sec(k,indice_Et)+FCC(k,indice_Et).*non_energ_sec(k,indice_Et)) ) / tep2gj  ; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;
varname = 'OM Cost|Fixed|Liquids|Oil'; //$/kW
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/kW/yr";
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Industry|Hydrogen'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Industry|Liquids'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_indu_eb,oil_eb,k)+energy_balance(conso_indu_eb,et_eb,k) ..
    + energy_balance(conso_agri_eb,oil_eb,k) + energy_balance(conso_agri_eb,et_eb,k) ..
+ energy_balance(conso_btp_eb,oil_eb,k) + energy_balance(conso_btp_eb,et_eb,k) )*Mtoe_EJ;
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

varname = 'Final Energy|Transportation|Liquids|Biomass'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids|Biomass|Biodiesel'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids|Biomass|Cellulosic Nondiesel'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids|Biomass|Conventional Ethanol'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids|Biomass|Other'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Final Energy|Other'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other Sector|Electricity'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other Sector|Gases'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other Sector|Heat'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other Sector|Hydrogen'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other Sector|Liquids'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Other Sector|Other'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,:,k))+sum(energy_balance(conso_resid_eb,:,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Electricity'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,elec_eb,k))+sum(energy_balance(conso_resid_eb,elec_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Gases'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,gas_eb,k))+sum(energy_balance(conso_resid_eb,gas_eb,k)))*Mtoe_EJ ;
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,et_eb,k))+sum(energy_balance(conso_resid_eb,et_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Other'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Solids'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,coal_eb,k))+sum(energy_balance(conso_resid_eb,coal_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Solids|Biomass'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Solids|Coal'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(energy_balance(conso_comp_eb,coal_eb,k))+sum(energy_balance(conso_resid_eb,coal_eb,k)))*Mtoe_EJ ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Residential and Commercial|Space Heating'; //   EJ/yr
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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energy_balance(conso_air_eb,et_eb,k)+energy_balance(conso_ot_eb,et_eb,k)+energy_balance(conso_car_eb,et_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids|Biomass'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_biofuel(k) .* (energy_balance(conso_air_eb,et_eb,k)+energy_balance(conso_ot_eb,et_eb,k)+energy_balance(conso_car_eb,et_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids|Coal'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_CTL(k) .* (energy_balance(conso_air_eb,et_eb,k)+energy_balance(conso_ot_eb,et_eb,k)+energy_balance(conso_car_eb,et_eb,k))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids|Natural Gas'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Final Energy|Transportation|Liquids|Oil'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share_oil_refin(k) .* (energy_balance(conso_air_eb,et_eb,k)+energy_balance(conso_ot_eb,et_eb,k)+energy_balance(conso_car_eb,et_eb,k))*Mtoe_EJ;
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

varname = 'Price|Secondary Energy|Liquids|Biomass'; //  US$2005/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = bioener_costs_NLU(k) * usd2001_2005 / tep2gj;
// '(excludes tax)
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
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

varname = 'Primary Energy|Biomass|Gases|w/ CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Gases|w/o CCS'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Heat'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Heat|w/ CCS'; //  EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Primary Energy|Biomass|Heat|w/o CCS'; // EJ/yr
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

varname = 'Resource|Cumulative Extraction|Coal'; // EJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q_cum_coal(k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ";
end;

varname = 'Resource|Cumulative Extraction|Gas'; //  EJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q_cum_gaz(k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ";
end;

varname = 'Resource|Cumulative Extraction|Gas|Conventional'; // EJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ";
end;

varname = 'Resource|Cumulative Extraction|Gas|Unconventional'; //   EJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ";
end;

varname = 'Resource|Cumulative Extraction|Oil'; //  EJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (Q_cum_oil_poles(k,1) + sum(Q_cum_oil(k,:)) + sum(Q_cum_heavy(k,:)) + sum(Q_cum_shale(k,:)))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ";
end;

varname = 'Resource|Cumulative Extraction|Oil|Conventional'; // EJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (Q_cum_oil_poles(k,1) + sum(Q_cum_oil(k,:)))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ";
end;

varname = 'Resource|Cumulative Extraction|Oil|Unconventional'; //   EJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(Q_cum_heavy(k,:)) + sum(Q_cum_shale(k,:)))*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ";
end;

varname = 'Resource|Cumulative Extraction|Uranium'; //  ktU
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ";
end;

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
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share1G(k) .* share_biofuel(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|Conventional Ethanol|w/ CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
varname = 'Secondary Energy|Liquids|Biomass|Conventional Ethanol|w/o CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
varname = 'Secondary Energy|Liquids|Biomass|Biodiesel'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Secondary Energy|Liquids|Biomass|Other'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share1G(k) .* share_biofuel(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Mixed of Biodiesel and Conventional Ethanol";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|Other|w/o CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share1G(k) .* share_biofuel(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="Mixed of Biodiesel and Conventional Ethanol";end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|Biodiesel'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|Biodiesel|w/o CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|Biodiesel|w/ CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|Conventional Ethanol'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|Conventional Ethanol|w/o CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Secondary Energy|Liquids|Biomass|Conventional Ethanol|w/ CCS'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Secondary Energy|Liquids|Biomass|Energy Crops'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = share2G(k) .* share_biofuel(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
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

varname = 'Trade|Primary Energy|Coal|Value'; //   billion US$2005
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ( Exp(k,coal) .* p(k,coal).*(1+xtax(k,coal)) - Imp(k,coal) .* pImp_notax(k,coal)) * Mtoe_EJ * usd2001_2005;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Trade|Primary Energy|Gas|Volume'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = -( energy_balance(imp_eb,gas_eb,k) + energy_balance(exp_eb,gas_eb,k)) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Trade|Primary Energy|Gas|Value'; //   billion US$2005
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ( Exp(k,gaz) .* p(k,gaz) .*(1+xtax(k,gaz))- Imp(k,gaz) .* pImp_notax(k,gaz)) * Mtoe_EJ * usd2001_2005;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Trade|Primary Energy|Oil|Volume'; // EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = -( energy_balance(imp_eb,oil_eb,k) + energy_balance(exp_eb,oil_eb,k)) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;

varname = 'Trade|Primary Energy|Oil|Value'; //   billion US$2005
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ( Exp(k,oil) .* p(k,oil).*(1+xtax(k,oil)) - Imp(k,oil) .* pImp_notax(k,oil)) * Mtoe_EJ * usd2001_2005;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;


varname = 'Trade|Secondary Energy|Electricity|Volume'; //   EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = -( energy_balance(imp_eb,elec_eb,k) + energy_balance(exp_eb,elec_eb,k)) * Mtoe_EJ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
//todo

varname = 'Trade|Secondary Energy|Solids and Liquids|Biomass|Volume'; //    EJ/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "EJ/yr";
end;
//todo

varname = 'Expenditure|Transport'; //   bil. $US/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bil. $US/yr";
end;

varname = 'Expenditure|Transport|Fuel'; //  bil. $US/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bil. $US/yr";
end;

varname = 'Population'; //| million
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=Ltot(k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "million";
end;

varname = 'GDP|MER'; // billion billion US$2005/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= GDP_MER_real(k)/ 1e3*usd2001_2005;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2005/yr";
end;

varname = 'GDP|PPP'; // billion billion US$2005/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=GDP_PPP_constant(k)/ 1e3*usd2001_2005;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2005/yr";
end;

varname = 'Emissions|CO2|Fossil Fuels and Industry'; //	Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,:))/1e6 + emi_evitee(k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Fossil Fuels and Industry|Energy Supply'; // Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,iu_ener))/1e6 + emi_evitee(k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Fossil Fuels and Industry|Energy Supply|Electricity'; // Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= E_reg_use(k,iu_elec)/1e6 + emi_evitee(k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Fossil Fuels and Industry|Energy Demand'; //
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,iu_non_ener))/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Fossil Fuels and Industry|Energy Demand|Industry'; //
//Includes Agriculture
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= (E_reg_use(k,iu_indu) + E_reg_use(k,iu_agri))/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Fossil Fuels and Industry|Energy Demand|Residential and Commercial'; //
//We do not use E_reg_use(iu_DF) because DF include cars and residential
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

varname = 'Emissions|CO2|Fossil Fuels and Industry|Energy Demand|Transportation'; //
//We do not use E_reg_use(iu_DF) because DF include cars and residential
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

varname = 'Emissions|CO2|Fossil Fuels and Industry|Energy Demand|Other Sector'; //
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

varname = 'Carbon Sequestration|CCS|Fossil|Energy';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
lineVAR = find_index_list( list_output_str, 'Carbon Sequestration|CCS|Fossil');
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  outputs_temp(nbLines*(k-1)+lineVAR,current_time_im+1);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Biomass|Energy';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  - emi_evitee(k,:)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Carbon Sequestration|CCS|Biomass|Industrial Processes';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=  %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Carbon Capture and Storage';
//Captured and stored emissions (hence the - before emi_evitee)
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
    - emi_evitee(k,:) ..
)/1e6; 
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Carbon Capture and Storage|Secondary Energy|Electricity|Biomass|w/ CCS';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee_elec(k)/1e6 ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Carbon Capture and Storage|Secondary Energy|Hydrogen|Biomass|w/ CCS';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee_hdr(k)/1e6 ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Emissions|CO2|Carbon Capture and Storage|Secondary Energy|Liquids|Biomass|w/ CCS';
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

varname = 'Emissions|GHG|International Trading System';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2-equiv/yr";
end;

varname = 'Emissions|CO2|Fossil Fuels and Industry|Cumulative'; //  Mt CO2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
refLine = find_index_list( list_output_str, 'Emissions|CO2|Fossil Fuels and Industry');
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2";
end;

if current_time_im < 10
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = outputs_temp(nbLines*(k-1)+counterLine,current_time_im-1) + outputs_temp(nbLines*(k-1)+refLine,current_time_im+1);
end


varname = 'Consumption'; // billion US$2005/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(DF(k,:).*pArmDF(k,:)))/1e3*usd2001_2005;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2005/yr";end;

if ind_climat > 2 & ind_climat <>99
    varname = 'Policy Cost|Area under MAC Curve';
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2005/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;

varname = 'Policy Cost|GDP Loss';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2005/yr";end;
if current_time_im==yr_start & k==1;list_output_comments(counterLine)="GDP MER";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (GDP_MER_real(k) - GDP_base_MER_real(k,current_time_im+1)) / 1e3*usd2001_2005; // negative numbers requested by EMF

varname = 'Policy Cost|Consumption Loss';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2005/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ( sum(DF(k,:).*pArmDF(k,:)) - sum(base_DF(k,:,current_time_im+1) .* base_pArmDF(k,:,current_time_im+1)))/1e3*usd2001_2005;

varname = 'Policy Cost|Equivalent Variation';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2005/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; // fixme

varname = 'Policy Cost|Additional Total Energy System Cost';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2005/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energyInvestment(k) - energyInvestment_base(k,current_time_im+1)) / 1e3 * usd2001_2005;

else
    varname_temp = 'Policy Cost|Area under MAC Curve';
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2005/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;

varname_temp = 'Policy Cost|GDP Loss';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2005/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;

varname_temp = 'Policy Cost|Consumption Loss';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2005/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;

varname_temp = 'Policy Cost|Equivalent Variation';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2005/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan; // fixme

varname_temp = 'Policy Cost|Additional Total Energy System Cost';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2005/yr";end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;

end


varname = 'Price|Carbon'; //    US$2005/t CO2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if ind_taxexo==9 & current_time_im < 19
    //do not output taxes correspoding to the weak policy period in budget scenarios
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = taxCO2_DF(k)*1e6*usd2001_2005;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/t CO2";
end;

varname = 'Price|Primary Energy|Biomass|Delivered'; //  US$2005/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = bioener_costs_Del(k) * usd2001_2005; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;
varname = 'Price|Primary Energy|Biomass|Market'; //  US$2005/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = bioener_costs_Del(k) * usd2001_2005; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'Price|Primary Energy|Biomass|Farmgate'; //   US$2005/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = bioener_costs_Farmgate(k) * usd2001_2005; //todo
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'Price|Primary Energy|Coal'; //   US$2005/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = p(k,indice_coal)*usd2001_2005/tep2gj;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'Price|Primary Energy|Gas'; //    US$2005/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = p(k,indice_gas)*usd2001_2005/tep2gj;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'Price|Primary Energy|Oil'; //    US$2005/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = p(k,indice_oil)*usd2001_2005/tep2gj;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'Price|Secondary Energy|Electricity'; //  US$2005/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = pArmCI(indice_elec,indice_industrie,k)*usd2001_2005/tep2gj;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'Price|Secondary Energy|Liquids'; //  US$2005/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = pArmCI(indice_Et,indice_industrie,k)*usd2001_2005/tep2gj;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;

varname = 'Price|Secondary Energy|Gases|Natural Gas'; //  US$2005/GJ
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2005/GJ";
end;



varname = 'Emissions|CO2|Carbon Capture and Storage|Biomass'; //    Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = - emi_evitee(k) /1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2-equiv/yr";
end;


varname = 'Energy Service|Transportation|Passenger'; //   bn pkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (Tair(k) + Tautomobile(k) + TOT(k) + TNM(k)) * pkmautomobileref(k) / 100 / 1e9;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn pkm/yr";
end;
varname = 'Energy Service|Transportation|Freight'; //   bn tkm/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "bn tkm/yr";
end;
