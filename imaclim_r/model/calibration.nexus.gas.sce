// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////
//-------------  CALIBRATION NEXUS_GAS  -------------------//
/////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION with no source   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

//pace of xtax decrease : set the year when xtax(ind_cis,indice_gas) reaches 0 after start_decr_xtax years have passed
//CAREFUL : this can introduce huge issues ~ 2016, so it can be increased if the model stops running
// by the way, this changes the resolution of the macro equilibrium, but does not modify the electricity nexus in the first ~ ten years
//so lets be nice with the macro
decr_xtax = 3;
start_decr_xtax = 5;
//definition of the curve mult_gaz 

a4_mult_gaz= 1862.5*ones(nb_regions,1);
a3_mult_gaz=-6457.5*ones(nb_regions,1);
a2_mult_gaz= 8346*ones(nb_regions,1);
a1_mult_gaz=-4769.6*ones(nb_regions,1);
a0_mult_gaz= 1018.6*ones(nb_regions,1);

if ind_new_calib_gas == %f
    // paramters of interpolation curve, in order not to drop under a certian price
    wpmin_gas_interpln = -10;
    wpgas_minPrice_interpl = 1.05;
    wpmax_gas_inc_interpln = 1000;
    // different years with different rules for prices dynamic
    year1_gaz = 31;
    year2_gaz = 8;
    year3_gaz = 8;
    year4_gaz = 9;

    wp_gas_tension=csvRead(path_gas_pscenario+'wp_gaz_tension.csv','|',[],[],[],'/\/\//');
    corr_gaz_1=csvRead(path_gas_corr+'corr_gaz_1.csv','|',[],[],[],'/\/\//');
    corr_gaz_2=csvRead(path_gas_corr+'corr_gaz_2.csv','|',[],[],[],'/\/\//');
else
    taux_gaz_prix=ones(nb_regions,1);
end

// conventionnal gas to oil price elasticity
elast_gas2oil_price = 0.68;
limit_gasPriceIndexation = 100; // $/barrel
// extra price increase at depletion
inc_price_gaz_depletion = 1.05;
// ressource to production ratio bellow which depletion starts
RP_ratio_depletion = 15;


/////////////////////////////////////////////////////////////////////////////////////////////
//    ---*---   CALIBRATION   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////


coef_gaz=ones(nb_regions,1);//initialisation


// reserve & ressource definitions
Ress_gaz_ref=csvRead(path_gas_ress + 'gasReserves.csv','|',[],[],[],'/\/\//');;
Ress_gaz  = Ress_gaz_ref;
Q_cum_gaz = Qref(:,gaz);
//Q_cum_gaz = Qref(:,gaz)*10;

Q_ref_2001=2078;
Q_ref_2014=2900;
Q_cum_gaz_global = cumulative_prod_linear(Q_ref_2014,Q_ref_2001,2014,2001);
Q_cum_gaz_global_ref = Q_cum_gaz_global;
deplet_gaz=0;


//Gas extraction costs, not needed for gas price setting for now.
//Still keeping it if we want to do change the price setting rule for gas (=> same as coal)


/////// Supply Curves
// Supply curves are in the format: first column is costs ($/GJ), second column is quantities (EJ = 10^9 GJ); heades are commented with '//'
// one file per region / oil category

//[supply_curves.gas.costs, supply_curves.gas.quantities, nb_gas_cat] = load_FF_supply_curves(["Gas_agg"], 'gas');

//cumulative availability curves in mtoe
//cum_quant_temp = supply_curves.gas.quantities(:,1);
//for c=1:size(supply_curves.gas.quantities,'c')-1
//    cum_quant_temp = [cum_quant_temp cum_quant_temp(:,$)+supply_curves.gas.quantities(:,c+1)];
//end
//cum_quant_temp = cum_quant_temp /mtoe2ej;
// smoothing the supply curves
//supply_curves.gas.costs_CACC = ones(nb_regions,1) * linspace(min(supply_curves.gas.costs( supply_curves.gas.costs<>0)), max(supply_curves.gas.costs), int(max(supply_curves.gas.costs)/0.01) );
//supply_curves.gas.quant_CACC = [];
//for r=1:nb_regions
//    supply_curves.gas.quant_CACC= [supply_curves.gas.quant_CACC; interpln( [ supply_curves.gas.costs(r,supply_curves.gas.costs(r,:)<>0); cum_quant_temp(r,supply_curves.gas.costs(r,:)<>0)], supply_curves.gas.costs_CACC(r,:)) ];
//end

// Global cumulative availability curve
//[supply_curves.gas.global_cost_CACC, supply_curves.gas.global_quant_CACC] = from_supplycurve_2_CACC( supply_curves.gas.costs, supply_curves.gas.quantities);


//cost_temp = supply_curves.gas.costs_CACC;
//for r=1:nb_regions
//    tt=min(find(supply_curves.gas.quant_CACC(r,:) >Q_cum_gaz(r)));
//    cost_temp(r,:) = supply_curves.gas.costs_CACC(r,:) / supply_curves.gas.costs_CACC(r, max(find(supply_curves.gas.quant_CACC(r,:) <Q_cum_gaz(r))));
//end
//supply_curves.gas.costs_CACC=null();
//supply_curves.gas.costs_CACC=cost_temp;

