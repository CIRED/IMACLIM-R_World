// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Aurélie Méjean, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


counterLine = 0 ;

//Consumption|Dx % share of  total consumption accruing to each Decile
varname = 'Consumption|D1'; // Share of  total consumption accruing to decile 1
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,1)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D1'; // Share of  total income accruing to decile 1
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,1)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D1'; // Share of food consumption accruing to decile 1
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D1'; // Share of consumption for transportation accruing to decile 1
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D1'; // Share of consumption for energy use in buildings accruing to decile 1
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Inequality index|Gini index'; // Gini index
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = gini_income(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "";end;//

varname = 'Inequality index|Absolute Poverty index'; // Absolute Povert Rate (1.9$ threshold)
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = poverty_rate(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D2'; // Share of  total consumption accruing to decile 2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,2)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D2'; // Share of  total income accruing to decile 2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,2)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D2'; // Share of food consumption accruing to decile 2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D2'; // Share of consumption for transportation accruing to decile 2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D2'; // Share of consumption for energy use in buildings accruing to decile 2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D3'; // Share of  total consumption accruing to decile 3
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,3)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D3'; // Share of  total income accruing to decile 3
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,3)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D3'; // Share of food consumption accruing to decile 3
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D3'; // Share of consumption for transportation accruing to decile 3
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D3'; // Share of consumption for energy use in buildings accruing to decile 3
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D4'; // Share of  total consumption accruing to decile 4
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,4)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D4'; // Share of  total income accruing to decile 4
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,4)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D4'; // Share of food consumption accruing to decile 4
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D4'; // Share of consumption for transportation accruing to decile 4
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D4'; // Share of consumption for energy use in buildings accruing to decile 4
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D5'; // Share of  total consumption accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,5)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D5'; // Share of  total income accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,5)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D5'; // Share of food consumption accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D5'; // Share of consumption for transportation accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D5'; // Share of consumption for energy use in buildings accruing to decile 5
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D6'; // Share of  total consumption accruing to decile 6
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,6)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D6'; // Share of  total income accruing to decile 6
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,6)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D6'; // Share of food consumption accruing to decile 6
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D6'; // Share of consumption for transportation accruing to decile 6
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D6'; // Share of consumption for energy use in buildings accruing to decile 6
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D7'; // Share of  total consumption accruing to decile 7
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,7)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D7'; // Share of  total income accruing to decile 7
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,7)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D7'; // Share of food consumption accruing to decile 7
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D7'; // Share of consumption for transportation accruing to decile 7
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D7'; // Share of consumption for energy use in buildings accruing to decile 7
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D8'; // Share of  total consumption accruing to decile 8
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,8)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D8'; // Share of  total income accruing to decile 8
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,8)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D8'; // Share of food consumption accruing to decile 8
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D8'; // Share of consumption for transportation accruing to decile 8
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D8'; // Share of consumption for energy use in buildings accruing to decile 8
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D9'; // Share of  total consumption accruing to decile 9
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,9)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D9'; // Share of  total income accruing to decile 9
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,9)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D9'; // Share of food consumption accruing to decile 9
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D9'; // Share of consumption for transportation accruing to decile 9
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D9'; // Share of consumption for energy use in buildings accruing to decile 9
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption|D10'; // Share of  total consumption accruing to decile 10
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = consumption_quantiles(k,10)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Income|D10'; // Share of  total income accruing to decile 10
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = income_quantiles(k,10)*100;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Food|D10'; // Share of food consumption accruing to decile 10
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Transportation|D10'; // Share of consumption for transportation accruing to decile 10
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Consumption share|Energy|Buildings|D10'; // Share of consumption for energy use in buildings accruing to decile 10
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "%";end;//

varname = 'Population'; //million
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Ltot(k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "million";end;//

varname = 'GDP|MER'; //billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = GDP_MER_real(k)/ 1e3*usd2001_2005 *usd2005to2010;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;//

varname = 'GDP|PPP'; //billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = GDP_PPP_constant(k)/ 1e3*usd2001_2005*usd2005to2010;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;//

varname = 'Emissions|CO2|AFOLU'; //Mt CO2/yr	
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = E_AFOLU(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";end;//

varname = 'Emissions|CO2|Energy and Industrial Processes'; //Mt CO2/yr	
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(E_reg_use(k,:)) + emi_evitee(k))/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";end;//

varname = 'Emissions|CO2'; //Mt CO2/yr	(total, including AFOLU)
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(E_reg_use(k,:)) + emi_evitee(k))/1e6 + E_AFOLU(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";end;//

varname = 'Emissions|CO2|Energy'; //	Mt CO2/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= sum(E_reg_use(k,:))/1e6 + emi_evitee(k)/1e6;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;

varname = 'Investment|All'; //billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(pK(k,:).*DeltaK(k,:))*usd2001_2005/1000*usd2005to2010;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;//


varname = 'Consumption'; // billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (sum(DF(k,:).*pArmDF(k,:)))/1e3*usd_year1_year2;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;

if ind_climat > 2 & ind_climat <>99

    varname = 'Policy Cost|Default for CAV';
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
    if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = - ( sum(DF(k,:).*pArmDF(k,:)) - sum(base_DF(k,:,current_time_im+1) .* base_pArmDF(k,:,current_time_im+1)))/1e3*usd_year1_year2;

    varname = 'Policy Cost|GDP Loss';
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
    if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
    if current_time_im==yr_start & k==1;list_output_comments(counterLine)="GDP MER";end;
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (GDP_MER_real(k) - GDP_base_MER_real(k,current_time_im+1)) / 1e3*usd_year1_year2; // negative numbers requested by EMF

    varname = 'Policy Cost|Consumption Loss';
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
    if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = ( sum(DF(k,:).*pArmDF(k,:)) - sum(base_DF(k,:,current_time_im+1) .* base_pArmDF(k,:,current_time_im+1)))/1e3*usd_year1_year2;

    varname = 'Policy Cost|Additional Total Energy System Cost';
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
    if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = (energyInvestment(k) - energyInvestment_base(k,current_time_im+1)) / 1e3 * usd_year1_year2;

else
    varname_temp = 'Policy Cost|Default for CAV';
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

    varname_temp = 'Policy Cost|Additional Total Energy System Cost';
    counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname_temp; end;
    if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2010/yr";end;
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = %nan;

end

varname = 'Price|Carbon'; //    US$2010/t CO2
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
if no_output_price_carbon==%t & current_time_im < 19
    //do not output taxes corresponding to the weak policy period in budget scenarios
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = 0;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = taxCO2_DF(k)*1e6*usd_year1_year2;
end
if current_time_im==yr_start & k==1; list_output_unit($+1) = "US$2010/t CO2";
end;

varname = 'Carbon Sequestration|CCS|Biomass|Energy|Supply';
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= - emi_evitee(k)/1e6 ;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mt CO2/yr";
end;
