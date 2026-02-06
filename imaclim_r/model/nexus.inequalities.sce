// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Aurélie Méjean
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

usd2001_2005 = 1/0.907;
poverty_line = 1.9*365; // USD per year (poverty line is defined as 1.9 USD per day)
labour_share_elas = 0.58; // high variant: 0.58; medium variant: 0.26; low variant: 0.16	
labour_share_switch = 0; // If labour_share_switch = 1, we account for the impact of the share of labour revenues in total revenues on the income gini

labour_share = sum(FCC.*w.*l.*(1+sigma).*Q,2)./sum(FCC.*w.*l.*(1+sigma).*Q + p.*Q.*markup.*(FCC.*energ_sec+non_energ_sec),2); // Labour share of revenues in total revenue, by region

if ~is_bau
    ldsav("sigma_sav","",baseline_combi);
    sigma_base = sigma_sav;
    ldsav("labour_share_sav","",baseline_combi);
    labour_share_base = labour_share_sav;
    labour_share_base(:,2) = labour_share_base(:,3); // To avoid division by zero TO BE FIXED
end;

// Carbon budget computation to match constraint imposed by WP4 ICMP Global cumulative CO2 emissions
if ind_climat == 0 | ind_climat == 1 | ind_climat == 2 // baseline scenarios
    // Initial year when quantiles are computed is 2014
    gini_consumption = consumption_gini_calib(:,current_time_im+1);
    gini_income = income_gini_calib(:,current_time_im+1);
    income_quantiles = inc_quantiles_reg(:,:,current_time_im+1,2);
    consumption_quantiles = cons_quantiles_reg(:,:,current_time_im+1,2);
    // Recovering parameters (mu, sigma) of the log-normal distribution associated with gini
    // Computing sigma parameter of the log-normal distribution
    // Using the inverse CDF function of the standard normal distribution (mean=0,std_dev=1). We are looking for "X", which is the upper limit of integration of the normal-density
    sigma_consumption = sqrt(2)*cdfnor("X",zeros(reg,1),ones(reg,1),(gini_consumption + 1)/2,1-(gini_consumption + 1)/2);
    sigma_income = sqrt(2)*cdfnor("X",zeros(reg,1),ones(reg,1),(gini_income + 1)/2,1-(gini_income + 1)/2);

    // Computing average income per capita and average consumption per capita
    average_income = Rdisp./Ltot*1e6*usd2001_2005./GDP_MER_nominal.*GDP_MER_real; // Unit: US$2005 per capita 
    hh_consumption = sum(DF.*pArmDF,2)*1e6*usd2001_2005./GDP_MER_nominal.*GDP_MER_real; // Household consumption by region (sum across sectors), in US$2005
    average_consumption = hh_consumption./Ltot; // Unit: US$2005 per capita

    // Computing mu parameter of the log-normal distribution
    mu_consumption = log(average_consumption) - (sigma_consumption.^2)/2;
    mu_income = log(average_income) - (sigma_income.^2)/2;

    // Poverty rate, i.e., share of people below the poverty level: this is the integral of the lognormal function between -infty and the poverty line, which is also Psi(log(poverty_line)), as we assume that
    // Income has a lognormal distribution, i.e., that log(income) has a normal distribution defined by parameters mu_income and sigma_income
    [poverty_rate,Q1] = cdfnor("PQ", repmat(log(poverty_line),reg,1),mu_income,sigma_income);
    // Absolute poverty rate in India gives absurd numbers (60% in 2020, should be 22.5% in 2011 according to World Bank data), which is probably due to a mis-calibration of Indian income and GDP. This is corrected here with a rustine, to be deleted after model calibration is complete.
    // poverty_rate(ind_ind) = poverty_rate(ind_ind)/2.5; //We comment this to check if this is fixed with v2 calibration
end;

// Computing the impact of a carbon tax on consumption distribution across deciles
// We use the consumption elasticity of the initial tax burden, where an elasticity of x means that if consumption increases by 1%, the initial burden increases by x%
// We use the data presented in (Budolfson et al., 2021, 10.1038/s41558-021-01217-0), available here: https://github.com/Environment-Research/revenue_recycling/blob/master/data/elasticity_study_data.csv 
// The initial burden of a carbon tax (i.e., the distribution of tax payments and mitigation costs prior to any revenue redistribution) is found to be progressive in poorer countries and regressive in richer countries
// The regression gives the consumption elasticity as a function of GDP per capita: consumption_elasticity = elas_intercept + elas_slope*log(GDPpc) (GDPpc is in 2005 USD)
elas_intercept = 3.22;
elas_slope = -0.22;
GDPpc_MER_real = GDP_MER_real*1e6*usd2001_2005./Ltot; // GDP MER real per capital in 2005 USD per capita
// We add boundaries in case GDPpc_MER_real exceeds the boundaries of observed GDP per capita in the collected studies
GDPpc_sup = 89000; // (Luxembourg in 2010)
GDPpc_inf = 645; // (Ethiopia in 2004)
GDPpc_MER_real_bounded = max(GDPpc_inf,min(GDPpc_MER_real,GDPpc_sup));

is_this_a_mistake = %t;
if ~is_this_a_mistake
    GDPpc_MER_real_bounded = max(GDPpc_inf,GDPpc_MER_real);
end

consumption_elasticity = elas_intercept + elas_slope*log(GDPpc_MER_real_bounded);
	
// Scenario where a carbon tax affects the distribution of consumption across deciles for each region. 
// In the WP4 default runs, ideally, the carbon tax revenues should not be recycled lump-sum, as the econometric relation used here assumes that no redistribution occurs (which is never the case in imaclim).
if ind_climat > 2 	//climate scenarios (bau scenarios are ind_climat == 0 | ind_climat == 1 | ind_climat == 2)
    income_gini_labour(:,current_time_im+1)= income_gini_calib(:,current_time_im+1).*((labour_share./labour_share_base(:,current_time_im+1))).^(-labour_share_elas);
    cons_gini_labour(:,current_time_im+1)= consumption_gini_calib(:,current_time_im+1).*((labour_share./labour_share_base(:,current_time_im+1))).^(-labour_share_elas);
    if taxMKTexo(current_time_im+1).*1e6 < 1e-6 // If tax is null, we follow the same steps as in the baseline: we set the ginis to the baseline numbers, which are already normalised in the calibration process
        // Accounting for the impact of the share of labour revenues in total revenues on the income gini
        gini_consumption =  consumption_gini_calib(:,current_time_im+1);
        gini_income =  income_gini_calib(:,current_time_im+1);
        income_quantiles = inc_quantiles_reg(:,:,current_time_im+1,2);
        consumption_quantiles = cons_quantiles_reg(:,:,current_time_im+1,2);
        // Recovering parameters (mu, sigma) of the log-normal distribution associated with gini
        // Computing sigma parameter of the log-normal distribution
        // Using the inverse CDF function of the standard normal distribution (mean=0,std_dev=1). We are looking for "X", which is the upper limit of integration of the normal-density
        sigma_consumption = sqrt(2)*cdfnor("X",zeros(reg,1),ones(reg,1),(gini_consumption + 1)/2,1-(gini_consumption + 1)/2);
        sigma_income = sqrt(2)*cdfnor("X",zeros(reg,1),ones(reg,1),(gini_income + 1)/2,1-(gini_income + 1)/2);
        // Computing average income per capita and average consumption per capita
        average_income = Rdisp./Ltot*1e6*usd2001_2005./GDP_MER_nominal.*GDP_MER_real; //unit: US$2005 per capita 
        hh_consumption = sum(DF.*pArmDF,2)*1e6*usd2001_2005./GDP_MER_nominal.*GDP_MER_real; //household consumption by region (sum across sectors), in 2005 USD
        average_consumption = hh_consumption./Ltot; //unit: US$2005 per capita
        // Computing mu parameter of the log-normal distribution
        mu_consumption =  log(average_consumption) - (sigma_consumption.^2)/2;
        mu_income =  log(average_income) - (sigma_income.^2)/2;
        // Poverty rate, i.e., share of people below the poverty level: this is the integral of the lognormal function between -infty and the poverty line, which is also Psi(log(poverty_line)), as we assume that
        // Income has a lognormal distribution, i.e., that log(income) has a normal distribution defined by parameters mu_income and sigma_income
        [poverty_rate,Q1] = cdfnor("PQ", repmat(log(poverty_line),reg,1),mu_income,sigma_income);
    else
        // Initial year when quantiles are computed is 2014
        hh_consumption_base = sum(base_DF(:,:,current_time_im+1).*base_pArmDF(:,:,current_time_im+1),2)*1e6*usd2001_2005./base_GDP_MER_nominal(:,current_time_im+1).*base_GDP_MER_real(:,current_time_im+1); // Unit: 2005 USD
        hh_consumption = sum(DF.*pArmDF,2)*1e6*usd2001_2005./GDP_MER_nominal.*GDP_MER_real;
        average_income = Rdisp./Ltot*1e6*usd2001_2005; //unit: US$2005 per capita 
        // Calculating mitigation cost
        hh_consumption_gross = sum(base_DF(:,:,current_time_im+1).*base_pArmDF(:,:,current_time_im+1),2)*1e6*usd2001_2005./base_GDP_MER_nominal(:,current_time_im+1).*base_GDP_MER_real(:,current_time_im+1); // Unit: 2005 USD
        hh_consumption_net = sum(DF.*pArmDF,2)*1e6*usd2001_2005./GDP_MER_nominal.*GDP_MER_real;
        mitigation_cost = max(zeros(nb_regions,1),1-hh_consumption_net./hh_consumption_gross); // lambda: mitigation cost as share of baseline consumption 
        if labour_share_switch == 1
            gini_consumption = cons_gini_labour(:,current_time_im+1);
            gini_income = income_gini_labour(:,current_time_im+1);
            // Normalization to match that of the bau in the calibration step. Was done ex-post in previous version of code, which might have been an error
            gini_income = gini_income * 0.9209640;
            sigma_consumption = sqrt(2)*cdfnor("X",zeros(reg,1),ones(reg,1),(gini_consumption + 1)/2,1-(gini_consumption + 1)/2);
            sigma_income = sqrt(2)*cdfnor("X",zeros(reg,1),ones(reg,1),(gini_income + 1)/2,1-(gini_income + 1)/2);
            // Computing average income per capita and average consumption per capita
            average_income = Rdisp./Ltot*1e6*usd2001_2005./GDP_MER_nominal.*GDP_MER_real; //unit: US$2005 per capita 
            hh_consumption = sum(DF.*pArmDF,2)*1e6*usd2001_2005./GDP_MER_nominal.*GDP_MER_real; //household consumption by region (sum across sectors), in 2005 USD
            average_consumption = hh_consumption./Ltot; //unit: US$2005 per capita
            // Computing mu parameter of the log-normal distribution
            mu_consumption = log(average_consumption) - (sigma_consumption.^2)/2;
            mu_income = log(average_income) - (sigma_income.^2)/2;
            // Computing Lorenz curve from gini indices and deriving quantiles from Lorenz curve
            def_quantiles = linspace(1,nb_quantiles,nb_quantiles)/nb_quantiles;
            def_quantiles($) = 0.99999; //this is added to avoid error when computing the inverse of the cumulative distribution function (CDF) of the standard normal distribution below (cdfnor)
            quantile_line = cdfnor("X",zeros(1,nb_quantiles),ones(1,nb_quantiles),repmat(def_quantiles,[1,1]),(1-repmat(def_quantiles,[1,1])));
            quantile_line_rep = repmat(quantile_line,[nb_regions,1]);
            arg_psi_income = quantile_line_rep - repmat(sigma_income,[1,nb_quantiles]); // Added variable to break computation in two steps
            arg_psi_consumption = quantile_line_rep - repmat(sigma_consumption,[1,nb_quantiles]); // Added variable to break computation in two steps
            //arg_psi_income = cdfnor("X",zeros(nb_regions,nb_quantiles),ones(nb_regions,nb_quantiles),repmat(def_quantiles,[nb_regions,1]),(1-repmat(def_quantiles,[nb_regions,1]))) - repmat(sigma_income,[1,nb_quantiles]); // added variable to break computation in two steps
            //arg_psi_consumption = cdfnor("X",zeros(nb_regions,nb_quantiles),ones(nb_regions,nb_quantiles),repmat(def_quantiles,[nb_regions,1]),(1-repmat(def_quantiles,[nb_regions,1]))) - repmat(sigma_consumption,[1,nb_quantiles]); // added variable to break computation in two steps
            [Lorenz_inc,Q0] = cdfnor("PQ", arg_psi_income, zeros(nb_regions,nb_quantiles),ones(nb_regions,nb_quantiles)); //computes cumulative shares of income (y-axis of Lorenz curve)
            [Lorenz_cons,Q0] = cdfnor("PQ", arg_psi_consumption, zeros(nb_regions,nb_quantiles),ones(nb_regions,nb_quantiles)); //computes cumulative shares of income (y-axis of Lorenz curve)
            Lorenz_inc_s = zeros(nb_regions,nb_quantiles); 
            Lorenz_cons_s = zeros(nb_regions,nb_quantiles); 
            Lorenz_inc_s(:,2:$)=Lorenz_inc(:,1:$-1); // First column is made of zeros
            Lorenz_cons_s(:,2:$)=Lorenz_cons(:,1:$-1); // First column is made of zeros
            income_quantiles = Lorenz_inc-Lorenz_inc_s; // Quantiles are obtained by computing the differences between cumulative quantiles from the Lorenz curve. We check that the sum of quantiles equals 1 for each country	
            income_quantiles_inter = income_quantiles;
            consumtion_quantiles = Lorenz_cons-Lorenz_cons_s; // Quantiles are obtained by computing the differences between cumulative quantiles from the Lorenz curve. We check that the sum of quantiles equals 1 for each country	
            cons_quantiles_gross = consumtion_quantiles;
        else
            gini_consumption = consumption_gini_calib(:,current_time_im+1);
            //gini_income = income_gini_calib(:,current_time_im+1);
            cons_quantiles_gross = cons_quantiles_reg(:,:,current_time_im+1,2);
        end;
        // Computes the distributional weights of the initial cost burden (following Budolfson et al., 2021)
        scaled_shares = cons_quantiles_gross .^ repmat(consumption_elasticity,1,nb_quantiles); // q^w
        cost_burden_shares = scaled_shares./repmat(sum(scaled_shares,2),1,nb_quantiles); // tau: cost burden weights, by region and decile, which will be affected to the aggregate consumption loss
        // Remaining consumption by quantile after subtracting cost burden in terms of consumption loss to the consumption of each quantile of each region
        hh_cons_by_quantile_net_of_cost = repmat(hh_consumption_gross,1,nb_quantiles).*(cons_quantiles_gross - cost_burden_shares.*repmat(mitigation_cost,1,nb_quantiles)); // cgross*(q - lambda*tau) quantile consumption net of mitigation costs
        // Tax payment
        tax_payment_regional = TAXCO2_2report.*1e6./GDP_MER_nominal.*GDP_MER_real*usd2001_2005; // E*tax USD
        tax_payment_burden_shares = cost_burden_shares; // tau
        if sc_CO2Tax_recycl=="LaborTaxReduction_old" | sc_CO2Tax_recycl=="LaborTaxReduction"
            tax_revenue_shares = zeros(tax_payment_burden_shares); // delta set equal to zero
        else
            tax_revenue_shares = ones(tax_payment_burden_shares)/nb_quantiles; // delta not set equal to zero, equal per capita recycling
        end;
        tax_payment_burden_by_quantile = tax_payment_burden_shares.*repmat(tax_payment_regional,1,nb_quantiles); //E*tax*delta
        // Consumption by quantile, net of costs, tax payments, and tax revenues
        hh_cons_by_quantile_net = hh_cons_by_quantile_net_of_cost + repmat(tax_payment_regional,1,nb_quantiles).*(tax_revenue_shares); //cnet = cgross(q-lambda*tau) + E*tax*delta
        cons_quantiles_net = hh_cons_by_quantile_net./repmat(sum(hh_cons_by_quantile_net,2),1,nb_quantiles);
        consumption_quantiles = cons_quantiles_net;
        // Income quantiles derived from consumption quantiles
        income_quantiles_temp = consumption_quantiles./repmat(inc2cons_quantiles,reg,1);
        income_quantiles = income_quantiles_temp./repmat(sum(income_quantiles_temp,2),1, nb_quantiles);
        // Gini
        freqi=repmat(flipdim(cumsum(ones(nb_quantiles,1)),1)',reg,1);
        gini_income = (nb_quantiles+1-2*(sum(income_quantiles.*freqi,2)))./(nb_quantiles-1);
        // gini_income = 1-(2/nb_quantiles*sum(income_quantiles.*(repmat(nb_quantiles*ones(1,nb_quantiles) - linspace(1,nb_quantiles,nb_quantiles),reg,1)),2)+1/nb_quantiles); 
        // Poverty rate
        sigma_income = sqrt(2)*cdfnor("X",zeros(reg,1),ones(reg,1),(gini_income + 1)/2,1-(gini_income + 1)/2);
        mu_income =  log(average_income) - (sigma_income.^2)/2;
        [poverty_rate,Q1] = cdfnor("PQ", repmat(log(poverty_line),reg,1),mu_income,sigma_income);
    end;
end;

// Old code to be scrapped when the rest of the code is stabilized
// Accounting for impact of share of labour income in total income: computing parameters of the lognormal distribution and income quantiles for each region
// sigma_income_labour_reg = sqrt(2)*cdfnor("X",zeros(nb_regions,1),ones(nb_regions,1),(gini_labour + 1)/2,1-(gini_labour + 1)/2);
// quantiles_L = linspace(1,nb_quantiles,nb_quantiles)/nb_quantiles;
// quantiles_L($) = 0.99999; // This is added to avoid error when computing the inverse of the cumulative distribution function (CDF) of the standard normal distribution below (cdfnor)
// arg_psi_income_reg = cdfnor("X",zeros(nb_regions,nb_quantiles),ones(nb_regions,nb_quantiles),repmat(quantiles_L,[nb_regions,1]),(1-repmat(quantiles_L,[nb_regions,1]))) - repmat(sigma_income_labour_reg,[1,nb_quantiles]); // added variable to break computation in two steps
// [Lorenz_inc_reg,Q0] = cdfnor("PQ", arg_psi_income_reg, zeros(nb_regions,nb_quantiles),ones(nb_regions,nb_quantiles)); //computes cumulative shares of income (y-axis of Lorenz curve)
// Lorenz_inc_reg_s = zeros(nb_regions,nb_quantiles); 
// Lorenz_inc_reg_s(:,2:$)= Lorenz_inc_reg(:,1:$-1); //first column is made of zeros
// income_quant_lab = Lorenz_inc_reg-Lorenz_inc_reg_s; //quantiles are obtained by computing the differences between cumulative quantiles from the Lorenz curve. We check that the sum of quantiles equals 1 for each region
// Computing labour share
// Labour share = sum(omega.w.l.(1+tautax_baseline).Q) / sum(omega.w.l.(1+tautax_baseline).Q + Pi.p.Q)
// EBE = p.*Q.*markup.*(FCC.*energ_sec+non_energ_sec);
// VA = A.*w.*l.*Q.*(1).*(energ_sec+FCC.*non_energ_sec)+EBE;
