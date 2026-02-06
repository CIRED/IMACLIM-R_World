// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////
//-------------  CALIBRATION NEXUS COAL  -------------------//
/////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION with no source   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////
if ind_new_calib_coal==%f
    // parameters of interpolation curve, in order not to drop under a certian price
    wpmin_coal_interpln = -10;
    wpcoal_minPrice_interpl = 1.05;
    wpmax_coal_inc_interpln = 1000;
    // parameters for coal price elasticity
    year_pt_eq_coal_2030 = 30;
    pt_eq_coal_2001 = 0.05;
    pt_eq_coal_2001 = 0;
    year_positiv_slope_coal = 10;

    wp_coal_default=csvRead(path_coal_pscenario+'wp_coal_default.csv','|',[],[],[],'/\/\//');
    corr_coal_default_1=csvRead(path_coal_corr+'corr_coal_default_1.csv','|',[],[],[],'/\/\//');
    corr_coal_default_2=csvRead(path_coal_corr+'corr_coal_default_2.csv','|',[],[],[],'/\/\//');
end
// cumulative coal price change wrt ref year price
taux_coal_prix=ones(reg,1);

//price elasticities
slope_coal_1 = 1; //Keeping v1 value (no source/calibration)
if ind_new_calib_coal
    slope_coal_2_auto = csvRead(path_autocal_slopecoal+'pente_coal_2_auto.csv','|',[],[],[],'/\/\//');
    slope_coal_2 = slope_coal_2_auto;
else 
    slope_coal_2 = 1.5; // Previous value
end


//definition of the curve mult_coal

a4_mult_coal= 1862.5*ones(nb_regions,1);
a3_mult_coal=-6457.5*ones(nb_regions,1);
a2_mult_coal= 8346*ones(nb_regions,1);
a1_mult_coal=-4769.6*ones(nb_regions,1);
a0_mult_coal= 1018.6*ones(nb_regions,1);

/////////////////////////////////////////////////////////////////////////////////////////////
//    ---*---   CALIBRATION   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////


/////// Supply Curves
// Supply curves are in the format: first column is costs ($/GJ), second column is quantities (EJ = 10^9 GJ); heades are commented with '//'
// one file per region / oil category
[supply_curves.coal.costs, supply_curves.coal.quantities, nb_coal_cat] = load_FF_supply_curves(["Coal_agg"], 'coal');
// Global cumulative availability curve
[supply_curves.coal.global_cost_CACC, supply_curves.coal.global_quant_CACC] = from_supplycurve_2_CACC( supply_curves.coal.costs, supply_curves.coal.quantities);


select ind_coal_ress
case 0
    Ress_coal_ref = csvRead(path_coal_ressources+'Ress_coal_low.csv','|',[],[],[],'/\/\//'); //(Mtoe), ressources now include grades A,B,C, see coalReserves.txt
    Ress_coal = Ress_coal_ref;
case 1
    Ress_coal_ref = csvRead(path_coal_ressources+'Ress_coal_high.csv','|',[],[],[],'/\/\//'); //(Mtoe), ressources now include grades A,B,C and D, see coalReserves.txt
    Ress_coal = Ress_coal_ref;
case 2
    filename = path_fossil_coal_SC + "coal_cost_curves_All_cat_SSP2.csv";
    mat_sc = csvRead( filename, "|",[],[],[],'/\/\//');
    Ress_CAC_coal.quant = zeros(nb_regions, size(mat_sc,"c")-1);
    Ress_CAC_coal.costs = zeros(nb_regions, size(mat_sc,"c")-1);
    Ress_CAC_coal.costs(:, 1:size(mat_sc,"c")-1) = ones(reg,1)*mat_sc(1,2:$) * CPI_1990_to_2014 / gj2tep ;
    Ress_CAC_coal.quant = mat_sc(2:$,2:$) / mtoe2ej;
    p_reserve_t0 = 2.5 * CPI_1990_to_2014 / gj2tep ;
    Ress_CAC_coal =  shorten_CAC(Ress_CAC_coal);
    Ress_CAC_coal =  expand_CAC(Ress_CAC_coal, 250);
    Ress_coal_ref = sum(Ress_CAC_coal.quant,'c');
    Ress_coal = Ress_coal_ref;
end

Q_cum_coal = Qref(:,coal);

Q_ref_2001=2535;
Q_ref_2014=4333;
Q_cum_coal_global = cumulative_prod_linear(Q_ref_2014,Q_ref_2001,2014,2001);
Q_cum_coal_global_ref = Q_cum_coal_global;

//load cumulative production from Shiftproject data
Q_cum_coal_reg = csvRead(path_fossil_cumulative+'cumulative_extraction_Coal_2007_' + string(base_year_simulation) + '.csv','|',[],[],[],'/\/\//'); //(Mtoe), ressources now include grades A,B,C and D, see coalReserves.txt
Q_cum_coal_reg = Q_cum_coal_reg(:,2);

// Cumulative production by region, removing it from cumulmative availability curves
if ind_coal_ress == 2
    Ress_CAC_coal.costs_ref = zeros(nb_regions, 1);
    Ress_CAC_coal.costs_current = zeros(nb_regions, 1);
    Ress_CAC_coal = compute_cumulative_curve(Ress_CAC_coal, Q_cum_coal_reg);
    Ress_CAC_coal.costs_ref = Ress_CAC_coal.costs_current;
    Ress_CAC_coal = compute_RP_ratio(Ress_CAC_coal, pref(:,coal), Qref(:,coal));
    Ress_CAC_coal = compute_costs_current(Ress_CAC_coal, Qref(:,coal));
    Ress_CAC_coal.costs_ref = Ress_CAC_coal.costs_current;
    Ress_CAC_coal.costs_last = Ress_CAC_coal.costs_current;
end

//Coal prices auto-calibration
if auto_calibration_p_coal <>"None"
    p_coal_ref = sum(pref(:,indice_coal).*Qref(:,indice_coal))/sum(Qref(:,indice_coal));

    global_cost_ref_coal = interpln([supply_curves.coal.global_quant_CACC';supply_curves.coal.global_cost_CACC],Q_cum_coal_global_ref);
end


// Defining default values of a_k_coal and b_k_coal: logistic parameters to smooth India coal pathway with respect to domestic production objectives
// stability of run can be sensitive to these values
if ~isdef("a_k_coal")
    a_k_coal = 20;  
end

if ~isdef("b_k_coal")
    b_k_coal = 0.9;
end

// Those parameters are here to drive assumptions regarding sovereignty policies
partDomDF_min = zeros(nb_regions, sec);
partDomCI_min = zeros(sec, sec, nb_regions);
