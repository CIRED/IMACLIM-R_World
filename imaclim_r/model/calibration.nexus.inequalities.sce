// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Aurélie Méjean
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


nb_quantiles = 10;
nb_steps_ineq = TimeHorizon+1;
gini_labour = ones(reg, nb_steps_ineq);

//path_data_inequalities

sg_add(["Rdisp"]); // Net income (income net of taxes and transfers: money available to households to spend on goods and services)
labour_share_ref = zeros(reg,1);
labour_share = labour_share_ref;
sg_add(["labour_share"]); // Share of labour income in total income

// load data for nexus

income_gini_calib = csvRead(path_data_inequalities + 'income_gini_calib.csv', '|',[],[],[],'/\/\//');
consumption_gini_calib = csvRead(path_data_inequalities + 'consumption_gini_calib.csv', '|',[],[],[],'/\/\//');
inc2cons_quantiles = csvRead(path_data_inequalities+".."+sep+"income_to_consumption_deciles.csv",'|',[],[],[],'/\/\//'); //vector that transforms income deciles into consumption deciles

inc_quantiles_reg =zeros(reg,nb_quantiles,nb_steps_ineq,2); //final income quantiles for imaclim regions over time
cons_quantiles_reg = zeros(reg,nb_quantiles,nb_steps_ineq,2); //final consumption quantiles for imaclim regions over time
for i=1:nb_quantiles
    for j=1:2 
        inc_quantiles_reg_full = csvRead( path_data_inequalities  + 'inc_quantiles_reg_quantile'+string(i)+'_popORgdpShare'+string(j)+'.csv', '|',[],[],[],'/\/\//');
        cons_quantiles_reg_full = csvRead( path_data_inequalities + 'cons_quantiles_reg_quantile'+string(i)+'_popORgdpShare'+string(j)+'.csv', '|',[],[],[],'/\/\//');
        inc_quantiles_reg(:,i,:,j) = inc_quantiles_reg_full(:,1:TimeHorizon+1);
        cons_quantiles_reg(:,i,:,j) = cons_quantiles_reg_full(:,1:TimeHorizon+1);
    end
end

income_gini_labour = zeros(reg, nb_steps_ineq);
cons_gini_labour = zeros(reg, nb_steps_ineq);