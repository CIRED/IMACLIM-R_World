// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Nicolas Graves, Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


counterLine = 0 ;

varname = 'Population'; //| million
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=Ltot(k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "million";
end;

varname = 'GDP|MER'; // billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= GDP_MER_real(k)/ 1e3 * usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'GDP|PPP'; // billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=GDP_PPP_constant(k)/ 1e3 * usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'Revenue|government|Tax|Carbon Tax'; //  billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = TAXCO2_2report(k)/GDP_MER_nominal(k)*GDP_MER_real(k) / 1e3 * usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'Revenue|government|Carbon Tax|Household'; //  billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = TAXCO2_hsld(k)/GDP_MER_nominal(k)*GDP_MER_real(k) / 1e3 * usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'Income|Household'; //   billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Rdisp(k)/GDP_MER_nominal(k)*GDP_MER_real(k) / 1e3 * usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'Expenditure|Household'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
//outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DF(k,:).*pArmDF(k,:))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000 * usd_year1_year2;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DF(k,:).*pArmDF(k,:))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000 * usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'Expenditure|Government|Transfers to Household|Carbon Tax'; //   billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = TAXCO2(k)/GDP_MER_nominal(k)*GDP_MER_real(k) /1e3 * usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'Price|Carbon'; //    US$2010/t CO2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = taxCO2_DF(k)*1e6 * usd_year1_year2 /GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/t CO2";
end;

