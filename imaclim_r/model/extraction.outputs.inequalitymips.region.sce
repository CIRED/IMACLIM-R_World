// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Aurélie Méjean
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

varname = 'Unemployment rate'; //   Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Z(k)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Value Added|Labor Compensation|Gross'; // billion billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=Labor_compensation_gross(k) / 1e3 * usd_year1_year2 /GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'Value Added|Labor Compensation|Net'; // billion billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=Labor_compensation_gross(k) / 1e3 * usd_year1_year2 /GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'Value Added|Gross Operating Surplus'; // billion billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=sum(EBE(k,:)) / 1e3 * usd_year1_year2 /GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";
end;

varname = 'GDP|Wage share - scilab nexus definition'; // billion billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=labour_share(k)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'GDP|Wage share'; // billion billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=Labor_compensation_gross(k) * usd_year1_year2 /GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Value Added|Labor Compensation|Net'; // billion billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=Labor_compensation_gross(k) * usd_year1_year2 /GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Value Added|Gross Operating Surplus'; // billion billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=sum(EBE(k,:)) * usd_year1_year2 /GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";
end;

varname = 'Employment'; //   Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(labor_ILO(k,:))/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";
end;

varname = 'Inequality index|Gini index'; // Gini index
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = gini_income(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;//

varname = 'Income|D1'; // Share of  total income accruing to decile 1
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,1)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

if k==1
    disp(" income_quantiles(k,1)*100")
    disp(income_quantiles(k,1)*100)
end

varname = 'Income|D2'; // Share of  total income accruing to decile 2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,2)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//
varname = 'Income|D3'; // Share of  total income accruing to decile 3
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,3)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//


varname = 'Income|D4'; // Share of  total income accruing to decile 4
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,4)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//


varname = 'Income|D5'; // Share of  total income accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,5)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//


varname = 'Income|D6'; // Share of  total income accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,6)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D7'; // Share of  total income accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,7)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D8'; // Share of  total income accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,8)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D9'; // Share of  total income accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,9)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D10'; // Share of  total income accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,10)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

