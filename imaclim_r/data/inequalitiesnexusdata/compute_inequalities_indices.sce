// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Aurélie Méjean
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


ORIGINAL_DIR = pwd() + filesep();
cd '../../model'
exec('preamble.sce')

nb_quantiles = 10; 
nb_countries = 181;
nb_steps_ineq = 2100-2014 +1;
country_US = 1;
country_CAN = 2;
country_EUR = linspace(3,39,39-3+1);
country_JANZ = linspace(40,43,43-40+1);
country_FSU = linspace(44,55,55-44+1);
country_CHI = 56;
country_IND = 57;
country_BRA = 58;
country_MDE = linspace(59,72,72-59+1);
country_AFR = linspace(73,124,124-73+1);
country_RAS = linspace(125,151,151-125+1);
country_RAL = linspace(152,181,181-152+1);
country_def =list(country_US, country_CAN, country_EUR, country_JANZ,country_FSU, country_CHI, country_IND, country_BRA,country_MDE,country_AFR, country_RAS,country_RAL);

// special case of country regions
country_regions = list(country_US,country_CAN,country_CHI,country_IND,country_BRA);
region2country_reg = zeros(reg);
region2country_reg(ind_usa)=country_US;
region2country_reg(ind_can)=country_CAN;
region2country_reg(ind_chn)=country_CHI;
region2country_reg(ind_ind)=country_IND;
region2country_reg(ind_bra)=country_BRA;

country_gdp_pop_2014 =csvRead(ORIGINAL_DIR+"country_gdp_pop_2014.csv",';',[],[],[],'/\/\//'); // GDP and Population for 182 countries in 2014
income_gini_country =csvRead(ORIGINAL_DIR+"income_gini_country.csv",';',[],[],[],'/\/\//')/100; // Income Gini for 182 countries (2014-2100)
inc2cons_quantiles = csvRead(ORIGINAL_DIR+"income_to_consumption_deciles.csv",'|',[],[],[],'/\/\//'); //vector that transforms income deciles into consumption deciles
gdp_country_2014 = country_gdp_pop_2014(:,3);
pop_country_2014 = country_gdp_pop_2014(:,4);

//computing parameters of the lognormal distributions for each country at each timestep
sigma_income_country = sqrt(2)*cdfnor("X",zeros(nb_countries,nb_steps_ineq),ones(nb_countries,nb_steps_ineq),(income_gini_country(:,3:$) + 1)/2,1-(income_gini_country(:,3:$) + 1)/2);

//computing income quantiles for each country at each timestep
nb_quantiles_Lorenz = 100;
def_quantiles_Lorenz = linspace(1,nb_quantiles_Lorenz,nb_quantiles_Lorenz)/nb_quantiles_Lorenz;
def_quantiles_Lorenz($) = 0.99999; //this is added to avoid error when computing the inverse of the cumulative distribution function (CDF) of the standard normal distribution below (cdfnor)

matrix_quantiles = zeros(nb_countries,nb_quantiles_Lorenz,nb_steps_ineq);
gdp_quantiles = zeros(nb_countries,nb_quantiles_Lorenz,nb_steps_ineq);
pop_quantiles = zeros(nb_countries,nb_quantiles_Lorenz,nb_steps_ineq);

quantiles_cum_reg =zeros(reg,nb_quantiles,nb_steps_ineq,2); //"2" dimension is 1 for cumulative population share, 2 for cumulative gdp share
inc_quantiles_reg =zeros(reg,nb_quantiles,nb_steps_ineq,2); //final income quantiles for imaclim regions over time
cons_quantiles_reg = zeros(reg,nb_quantiles,nb_steps_ineq,2); //final consumption quantiles for imaclim regions over time
income_gini_reg = zeros(reg,nb_steps_ineq);
cons_gini_reg = zeros(reg,nb_steps_ineq);
income_gini_reg_check = zeros(reg,nb_steps_ineq);

for i_step = 1:nb_steps_ineq
    //***first method: country income gini over time -> country Lorenz curves over time -> aggregation to regional income quantiles over time (and regional consumption quantiles over time) --> regional income gini over time (and regional cosumption gini over time) 
    //special case for country regions (e.g., US) where income gini over time are given: initial consumption quantiles (WIID data) -> initial consumption gini -> consumption gini over time -> regional Lorenz curves over time -> regional quantiles
    //L(p)=psi(psi^(-1)(p)-sigma)=psi(arg_psi) : p is the cumulative proportion of households (x-axis of Lorenz curve), psi is the CDF of the standard normal distribution, L(p) is the cumulative share of consumption or income (L as in Lorenz curve)
    arg_psi_income_country = cdfnor("X",zeros(nb_countries,nb_quantiles_Lorenz),ones(nb_countries,nb_quantiles_Lorenz),repmat(def_quantiles_Lorenz,[nb_countries,1]),(1-repmat(def_quantiles_Lorenz,[nb_countries,1]))) - repmat(sigma_income_country(:,i_step),[1,nb_quantiles_Lorenz]); // added variable to break computation in two steps
    [Lorenz_inc_country,Q0] = cdfnor("PQ", arg_psi_income_country, zeros(nb_countries,nb_quantiles_Lorenz),ones(nb_countries,nb_quantiles_Lorenz)); //computes cumulative shares of income (y-axis of Lorenz curve)
    //Lorenz_inc_country(:,$)= ones(nb_countries,1); // last cumulative quantile set at 1 for all countries
    Lorenz_inc_country_s = zeros(nb_countries,nb_quantiles_Lorenz); 
    Lorenz_inc_country_s(:,2:$)=Lorenz_inc_country(:,1:$-1); //first column is made of zeros
    income_quantiles_country=Lorenz_inc_country-Lorenz_inc_country_s; //quantiles are obtained by computing the differences between cumulative quantiles from the Lorenz curve. We check that the sum of quantiles equals 1 for each country
    matrix_quantiles(:,:,i_step) = income_quantiles_country;
    gdp_quantiles(:,:,i_step)= matrix_quantiles(:,:,i_step).*repmat(gdp_country_2014,[1,nb_quantiles_Lorenz]);
    pop_quantiles(:,:,i_step)= repmat(pop_country_2014,[1,nb_quantiles_Lorenz])/nb_quantiles_Lorenz;
    gdp_quantiles_c = matrix(gdp_quantiles(:,:,i_step)',nb_countries*nb_quantiles_Lorenz,1); //column
    pop_quantiles_c = matrix(pop_quantiles(:,:,i_step)',nb_countries*nb_quantiles_Lorenz,1); //column
    all_quantiles_c = cat(2,gdp_quantiles_c,pop_quantiles_c);
    for r =1:reg
        // index to aggregate countries by region
        size_reg = size(country_def(r),2);
        start_index = country_def(r)(1)*nb_quantiles_Lorenz - nb_quantiles_Lorenz+1;
        end_index = start_index + size_reg*nb_quantiles_Lorenz -1;
        //assembling all country gdp and population quantiles by region
        all_quantiles_c_reg = all_quantiles_c(start_index:end_index,:);
        //sorting gdp quantiles in increasing order for each region
        sorted_gdp_quantiles = gsort(all_quantiles_c_reg,'lr','i');
        cum_gdp = cumsum(sorted_gdp_quantiles(:,1));
        cum_pop = cumsum(sorted_gdp_quantiles(:,2));
        cum_gdp_share = cum_gdp/cum_gdp($);
        cum_pop_share = cum_pop/cum_pop($);
        //coordinates of Lorenz curve
        all_cum_share = cat(2,cum_pop_share, cum_gdp_share);
        //interpolating data to find exact points on Lorenz curve for required quantiles
        for q = 1:nb_quantiles
            quantiles_cum_reg(r,q,i_step,1)=q/nb_quantiles; //cumulative population share
            quantiles_cum_reg(r,q,i_step,2)=interpln([all_cum_share'],q/nb_quantiles); //cumulative gdp share
        end;
        //computing income quantiles, deducing consumption quantiles from income quantiles
        quant_gdp_temp = quantiles_cum_reg(r,:,i_step,2); //gdp
        quant_gdp_temp_s = zeros(quant_gdp_temp);
        for q = 2:nb_quantiles //first element remains zero
            quant_gdp_temp_s(q) = quant_gdp_temp(q-1); //could have used circshift(quant_gdp_temp, 1) but function is unavailable in scilab 5.5.1
        end;
        quant_inc_reg_temp = quant_gdp_temp - quant_gdp_temp_s;
        quant_cons_reg_temp_raw= quant_inc_reg_temp .*inc2cons_quantiles; //deducing consumption quantiles from income quantiles
        quant_cons_reg_temp= quant_cons_reg_temp_raw./sum(quant_cons_reg_temp_raw,2); //normalizing the sum of consumption quantiles to 1
        for q = 1:nb_quantiles
            inc_quantiles_reg(r,q,i_step,1)=q/nb_quantiles; //cumulative population share
            inc_quantiles_reg(r,q,i_step,2)=quant_inc_reg_temp(q);
            cons_quantiles_reg(r,q,i_step,1)=q/nb_quantiles; //cumulative population share
            cons_quantiles_reg(r,q,i_step,2)=quant_cons_reg_temp(q);
        end;
        freqh = flipdim(cumsum(ones(nb_quantiles,1)),1);
        income_gini_reg(r,i_step) = (nb_quantiles+1-2*(sum(inc_quantiles_reg(r,:,i_step,2).*freqh')))./(nb_quantiles-1);
        cons_gini_reg(r,i_step) = (nb_quantiles+1-2*(sum(cons_quantiles_reg(r,:,i_step,2).*freqh')))./(nb_quantiles-1);
        if (r == ind_usa | r == ind_can | r == ind_chn | r == ind_ind | r == ind_bra) // to compare results for special case of country regions
            income_gini_reg_check(r,i_step) = income_gini_country(region2country_reg(r),i_step+2);
        end;
    end;
    // First method: Assumption to compute the evolution of quantiles over time: no economic convergence of countries from a given region: intra-regional inequalities are assumed to be constant between countries. It means that the order of countries in a given region remains the same over time. It allows us to use 2014 GDP to compute income deciles for all time steps. 
    //***possible alternative method: initial country consumption quantiles (but some countries missing)-> aggregation to initial regional consumption quantiles (and initial regional income quantiles)-> initial regional consumption gini (and initial income gini)-> regional consumption gini over time (and regional income gini over time) -> consumption quantiles over time (and income quantiles over time)  
end;

//Estimated ginis are biased upwards
bias_gini = mean(income_gini_reg_check(1,:)./income_gini_reg(1,:));
income_gini_calib = income_gini_reg*bias_gini;
consumption_gini_calib = cons_gini_reg*bias_gini;

// output
output_dir = ORIGINAL_DIR + 'results' + filesep();
mkdir(output_dir);

header="//<write header describing data here>";

csvWrite(income_gini_calib, output_dir + 'income_gini_calib.csv', '|', [], [], header);
csvWrite(consumption_gini_calib, output_dir + 'consumption_gini_calib.csv', '|', [], [], header);
for i=1:nb_quantiles
    for j=1:2
        csvWrite( matrix(inc_quantiles_reg(:,i,:,j),reg,nb_steps_ineq), output_dir + 'inc_quantiles_reg_quantile'+string(i)+'_popORgdpShare'+string(j)+'.csv', '|', [], [], header);
        csvWrite( matrix(cons_quantiles_reg(:,i,:,j),reg,nb_steps_ineq), output_dir + 'cons_quantiles_reg_quantile'+string(i)+'_popORgdpShare'+string(j)+'.csv', '|', [], [], header);
    end
end
