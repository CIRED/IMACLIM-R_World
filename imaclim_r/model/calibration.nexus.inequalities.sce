// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


nb_quantiles = 10;
nb_steps = TimeHorizon+1;

//path_data_inequalities

sg_add(["Rdisp"]); // Net income (income net of taxes and transfers: money available to households to spend on goods and services)

// load data for nexus

income_gini_calib = csvRead(path_data_inequalities + 'income_gini_calib.csv', '|',[],[],[],'/\/\//');
consumption_gini_calib = csvRead(path_data_inequalities + 'consumption_gini_calib.csv', '|',[],[],[],'/\/\//');
inc2cons_quantiles = csvRead(path_data_inequalities+".."+sep+"income_to_consumption_deciles.csv",'|',[],[],[],'/\/\//'); //vector that transforms income deciles into consumption deciles

inc_quantiles_reg =zeros(reg,nb_quantiles,nb_steps,2); //final income quantiles for imaclim regions over time
cons_quantiles_reg = zeros(reg,nb_quantiles,nb_steps,2); //final consumption quantiles for imaclim regions over time
for i=1:nb_quantiles
    for j=1:2
        inc_quantiles_reg(:,i,:,j) = csvRead( path_data_inequalities  + 'inc_quantiles_reg_quantile'+string(i)+'_popORgdpShare'+string(j)+'.csv', '|',[],[],[],'/\/\//');
        cons_quantiles_reg(:,i,:,j) = csvRead( path_data_inequalities + 'cons_quantiles_reg_quantile'+string(i)+'_popORgdpShare'+string(j)+'.csv', '|',[],[],[],'/\/\//');
    end
end
