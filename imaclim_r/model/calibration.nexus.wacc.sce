// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thibault Briera, Patrice Dumas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////calibration of the WACC model //////////////////////////////
///////////////////////////////////////////////////////////////////////////////////

//Pushed by TB


//===========================================//
//WACC model parameters
//===========================================//

// Calibration of the VRE techno premium
//NB: Ongoing discussion to improve the calibration of the technology risk premium.
Cap_limit_inf = 0;
Cap_limit_sup = 2 *10^5;
if ind_new_calib_wacc
    //debt margin: add a margin to the risk free rate to account for the risk of the debt
    // in the CoC for FF projet, debt margin is directly added 
    debt_margin = 0.012; // From 10.1038/s41560-022-01041-6
else 
    debt_margin = 0; 
end
Risk_premium_max = 0.06; //For now, this is only rule of thumb based on DiaCore project with interviews of european investors. Risk premiums on debt at 4%-6% are mentionned many times "For offshore wind, renewable energy project spread is higher than 4%" p. 110 .https://www.isi.fraunhofer.de/content/dam/isi/dokumente/ccx/dia-core/D3-4_diacore_2016_impact_of_risk_in_res_investments.pdf. No DOI
Risk_premium_min = debt_margin;


//Debt share for elec invest
//Rather standard assumptions
if ind_new_calib_wacc
    Debt_share_ENR_emer = 0.5;
else
    Debt_share_ENR_emer = 0.6;
end
Debt_share_ENR_dev = 0.8;
for tech = techno_RE_names
    execstr("Debt_share_"+tech+"= zeros(reg,1)") 
    execstr("Debt_share_"+tech+"(emerging_reg,:) = Debt_share_ENR_emer")
    execstr("Debt_share_"+tech+"(developed_reg,:) = Debt_share_ENR_dev")
end

Debt_share_FF = zeros(reg,1); 
//Ameli et al (2017) Stylised models of relative rates of return,technology co-benefit/spillover effects,multiplier and leverage effects for key sectors
//p. 21
Debt_share_FF(emerging_reg,:) = 0.5;
Debt_share_FF(developed_reg,:) = 0.5;

//Risk free rate of debt and equity
//10Y treasury bond rate of the reference country is used as a proxy (Germany for Europe, USA for the rest of the world). Jan 2020 data
//////https://fred.stlouisfed.org/series/DGS10/
//https://sdw.ecb.europa.eu/browse.do?node=bbn4864

//mean values from daily/monthly data from ecb/Saint Louis's Fed APIs
[Risk_f_RR_debt_hist_eur]=csvRead(DATA+"ECB"+sep+"ecb_10.csv",",",[],"string",[],'/\/\//');
Risk_f_RR_debt_hist_eur=strtod(Risk_f_RR_debt_hist_eur(2:$,2));
[Risk_f_RR_debt_hist_usa]=csvRead(DATA+"Fred_St_Louis"+sep+"DGS10.csv",",",[],"string",[],'/\/\//');
Risk_f_RR_debt_hist_usa=strtod(Risk_f_RR_debt_hist_usa(2:$,2)); //keeping only values and convert into decimal numbers


//Truncating the longest series to fit in a matrix, since ECB and St Louis' Fed does not get the exact same data 
Risk_f_RR_debt_hist=repmat(Risk_f_RR_debt_hist_usa(1:min(length(Risk_f_RR_debt_hist_usa),length(Risk_f_RR_debt_hist_eur))),1,reg)';

Risk_f_RR_debt_hist(ind_eur,:) = Risk_f_RR_debt_hist_eur'; 
Risk_f_RR_debt_hist=Risk_f_RR_debt_hist/100;

// Now using a mean of 2015-2022 values
if ind_new_calib_wacc
    Risk_f_RR_debt = mean(Risk_f_RR_debt_hist,2); 
end

//////From Damodaran datasets http://pages.stern.nyu.edu/adamodar/New_Home_Page/dataarchived.html
//01/2017 5.69%
//01/2018 5.08%
//01/2019 5.96%
//01/2020 5.20%
if ind_new_calib_wacc
    Risk_f_RR_equity = (0.052+0.06+0.051+0.057)/4;//mean of 2017-2020 Damodaran https://pages.stern.nyu.edu/~adamodar/pc/archives/ctryprem19.xls. No DOI.
else
    Risk_f_RR_equity = 0.052;
end
//Country Premium
//BEFORE DATA IS PUSHED
[CP.val,CP.desc] = csvRead(path_elec_CP+'CP_export.csv',",",[],[],[],'/\/\//');//Country default Swap from Damodaran
Country_premium = CP.val*100;
//////From Damodaran datasets http://pages.stern.nyu.edu/adamodar/New_Home_Page/dataarchived.html
//01/2017 1.23
//01/2018 1.12
//01/2019 1.23
//01/2020 1.18
if ind_new_calib_wacc
    adjusted_ratio_eq = (1.18+1.23+1.12+1.23)/4; 
else
    adjusted_ratio_eq = 1.18;
end
Country_premium_adj = adjusted_ratio_eq*Country_premium;

//Corporate tax
Corporate_tax =csvRead(path_elec_CT+'CT_export.csv',[";"], [","],[], [], [], [2 2 (reg+1) 2])/100;
//Corporate_tax = csvRead(path_elec_weights+'CT.csv',",",[],[],[],'/\/\//')/100;

//Betas and levers
//////From Damodaran datasets http://pages.stern.nyu.edu/adamodar/New_Home_Page/dataarchived.html
//Beta (effective tax rate,unlevered, global)
//for Green & renewable, not that much difference between global and region values
//        Green and Renewable // Power
//01/2017 0.57      0.44
//01/2018 0.68      0.54
//01/2019 0.58      0.45
//01/2020 0.53      0.46

beta_ENR = (0.57+0.68+0.58+0.53)/4;
//Remark : the beta is eventually lower 
lever_ENR=zeros(reg,1);
levered_beta_ENR =zeros(reg,1);

lever_ENR(emerging_reg) = Debt_share_ENR_emer/(1-Debt_share_ENR_emer);
lever_ENR(developed_reg) = Debt_share_ENR_dev/(1-Debt_share_ENR_dev);

levered_beta_ENR = beta_ENR.*(1+((1-Corporate_tax).*lever_ENR)); // re-levering the unlevered beta


beta_FF = (0.44+0.54+0.45+0.46)/4;//01/2020 Damodaran
lever_FF = Debt_share_FF./(1-Debt_share_FF);
levered_beta_FF = beta_FF.*(1+((1-Corporate_tax).*lever_FF));

//Global WACC Paper
if ind_global_wacc~=0
    Global_WACC = csvRead(path_elec_WACC + sep+ "WACC_Global.csv");
    Global_WACC = Global_WACC(2:(reg+1),:)/100; // in % 
    
    LR_fin = 0.05; //learning

    wacc_conv_start = 2020-base_year_simulation;
    wacc_conv_end = 2050-base_year_simulation;
    wacc_min = [ind_eur,ind_usa];  //the region to converge to 
end



