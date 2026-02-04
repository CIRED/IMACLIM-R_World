// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thibault Briera, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////
//-------------  CALIBRATION NEXUS COAL  -------------------//
/////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION with no source   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

if ind_new_calib_coal==%f
    // paramters of interpolation curve, in order not to drop under a certian price
    wpmin_coal_interpln = -10;
    wpcoal_minPrice_interpl = 1.05;
    wpmax_coal_inc_interpln = 1000;
    // parameters for coal price elasticity
    year_pt_eq_coal_2030 = 30;
    pt_eq_coal_2001 = 0.05;
    pt_eq_coal_2001 = 0;
    year_positiv_pente_coal = 10;

    wp_coal_default=csvRead(path_coal_pscenario+'wp_coal_default.csv','|',[],[],[],'/\/\//');
corr_coal_default_1=csvRead(path_coal_corr+'corr_coal_default_1.csv','|',[],[],[],'/\/\//');
corr_coal_default_2=csvRead(path_coal_corr+'corr_coal_default_2.csv','|',[],[],[],'/\/\//');
end
// cumulative coal price change wrt ref year price
taux_coal_prix=ones(reg,1);

//price elasticities
pente_coal_1 = 1; //Keeping v1 value (no source/calibration)
if ind_new_calib_coal
    pente_coal_2_auto = csvRead(path_autocalibration+'pente_coal_2_auto.csv','|',[],[],[],'/\/\//');
    pente_coal_2 = pente_coal_2_auto;
else 
    pente_coal_2 = 1.5; // Previous value
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
[supply_curves.coal.costs, supply_curves.coal.quantities, nb_gas_cat] = load_FF_supply_curves(["Coal_agg"], 'coal');
// Global cumulative availability curve
[supply_curves.coal.global_cost_CACC, supply_curves.coal.global_quant_CACC] = from_supplycurve_2_CACC( supply_curves.coal.costs, supply_curves.coal.quantities);


select ind_coal_ress
case 0
    Ress_coal_ref = csvRead(path_coal_ressources+'Ress_coal_low.csv','|',[],[],[],'/\/\//'); //(Mtoe), ressources now include grades A,B,C, see coalReserves.txt
case 1
    Ress_coal_ref = csvRead(path_coal_ressources+'Ress_coal_high.csv','|',[],[],[],'/\/\//'); //(Mtoe), ressources now include grades A,B,C and D, see coalReserves.txt
end

Ress_coal = Ress_coal_ref;
Q_cum_coal = Qref(:,coal);

Q_ref_2001=2535;
Q_ref_2014=4333;
Q_cum_coal_global = cumulative_prod_linear(Q_ref_2014,Q_ref_2001,2014,2001);
Q_cum_coal_global_ref = Q_cum_coal_global;

//Coal prices auto-calibration
if auto_calibration_coal_prices <>"None"
    p_coal_ref = sum(pref(:,indice_coal).*Qref(:,indice_coal))/sum(Qref(:,indice_coal));

    global_cost_ref_coal = interpln([supply_curves.coal.global_quant_CACC';supply_curves.coal.global_cost_CACC],Q_cum_coal_global_ref);
end


