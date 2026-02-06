// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


dynForc_m2_ener = ones(nb_regions,1);
dynForc_resid_TBE1 = ones(nb_regions,1);
dynForc_resid_TBE2 = ones(nb_regions,1);
dynForc_resid_TBE3 = ones(nb_regions,1);
dynForc_pcoal = 1;
dynForc_pcoal2 = 1;
dynForc_EI_indus = ones(nb_regions,1);
dynForc_EI_indus_obj = ones(nb_regions,1);
dynForc_EI_comp = ones(nb_regions,1);
dynForc_EI_indus2comp = ones(nb_regions,1);
dynForc_pEt_comp = 1;
dynForc_effOT2 = ones(nb_regions,1);
dynForc_effAir = ones(nb_regions,1);
dynForc_effAir_prev = dynForc_effAir;
dynForc_CIindu_2050 = ones(nb_regions,1);
dynForc_CIindu_istart = ones(nb_regions,1);
dynForc_CIindu = ones(nb_regions,1);
dynForc_hdf_cff = ones(nb_regions, nb_sectors);
dynForc_effCar = ones(nb_regions, 1);
dynForc_cap_tr_air = ones(nb_regions,1);
dynForc_cap_tr_ot = ones(nb_regions,1);
dynForc_cap_tr_car = ones(nb_regions,1);
dynForc_effOT1 = ones(nb_regions,1);
dynForc_effOT1_prev = dynForc_effOT1;
dynForc_DGindu = ones(nb_regions,1);
dynForc_resid_m2 = ones(nb_regions,1);
dynForc_savings = ones(nb_regions,1);

lenght_dynForc_cap_tr = 6;
lenght_dynForc_eff_tr = 35;
lenght_dynForc_1 = 20;
year_stop_dynForc_allVar=start_year_strong_policy-1+lenght_dynForc_1;
year_stop_dynForc_CI = 2050;
lenght_dynForc_p_ener=10;
lenght_dynForc_pref_tr = 16;
lenght_dynForc_m2 = 35;

dynForc_effMer = 0.99;

if ind_exogenous_forcings & indice_LED >=1

    // indice_LED = 1: all forcings for low energy demand 
    // indice_LED = 3: 	wo change in trade elasticities 
    // indice_LED = 4:	cots reduction of material efficiency are captured throught increased value added
    // indice_LED = 6:	no material efficiency on industrial inputs for production
    // indice_LED = 7:	no reduced consumption of industrial goods by households
    // indice_LED = 8: 	no material efficiency on industrial inputs in capital formation

    dynForc_TCl_2050 = 1; // exogenous forcing on labor prodictivity until 2050, driving GDP

    // coal price_ expectation for electricity, industry and services
    dynForc_pcoal_2050 = 1; // exogenous forcing on coal price expectation by sectors, driving coal use
    dynForc_pcoal2_2050 = 1; // exogenous forcing on coal price expectation by sectors, driving coal use
    dynForc_pEt_comp_2050 = 1; // exogenous forcing on liquid fuel price expectation by the composite sector, driving LF use use

    dynForc_m2_ener_2050_n = 0.1185; // exogenous forcing on the energy intensity of private buildings, driver FE in buildings - global north
    dynForc_m2_ener_2050_s = 1.0019; // exogenous forcing on the energy intensity of private buildings, driver FE in buildings - global south

    dynForc_resid_TBE1_2050 = 1; // exogenous forcing on the share of Very Low Energy buildings

    // Scenario LED
    dynForc_resid_TBE2_2050n = 1; // exogenous forcing on the renovation rate - global north
    dynForc_resid_TBE2_2050s = 1; // exogenous forcing on the renovation rate - global south
    //dynForc_resid_TBE3 = 0.25/0.45; // exogenous forcing on the energy intensity of very low energy private buildings
    dynForc_resid_TBE2_2050s = 0.4; // exogenous forcing on the renovation rate - global south
    dynForc_resid_TBE3_n = 1.3; // exogenous forcing on the energy intensity of very low energy private buildings
    dynForc_resid_TBE3_s = 0.4; // exogenous forcing on the energy intensity of very low energy private buildings



    dynForc_tair_2050_n = 0.985; // exogenous forcing on air infrastures, driving the demand for air passenger travels - global north
    dynForc_tair_2050_s = 0.956;; // exogenous forcing on air infrastures, driving the demand for air passenger travels - global south
    dynForc_tOt_2050_n = 4; // exogenous forcing on otehr transport infrastures, driving the demand for OT passenger travels - global north
    dynForc_tOt_2050_s = 0.994; // exogenous forcing on otehr transport infrastures, driving the demand for OT passenger travels - global south
    dynForc_tcar_2050_n = 0.993; // exogenous forcing on road infrastures, driving the demand for car passenger travels - global north
    dynForc_tcar_2050_s = 0.97; // exogenous forcing on road infrastures, driving the demand for car passenger travels - global south

    coef_pref_2050_n = 0.6;
    dynForc_tairA_2050_n = coef_pref_2050_n*(9/150)^(1/20); // exogenous forcing on preferences for air travels parameters of the congestion function) in the utility function - global north
    dynForc_tairXsi_2050_n = 1.04*1/coef_pref_2050_n*1.027; // exogenous forcing on preferences for air travels parameters of the congestion function) in the utility function - global north
    dynForc_tairK_2050_n = coef_pref_2050_n*(2/150)^(1/20); // exogenous forcing on preferences for air travels parameters of the congestion function) in the utility function - global north

    dynForc_effCar_2050_n = 4; // exogenous forcing on car efficiency - global north
    dynForc_effCar_2050_s = 0.5; // exogenous forcing on car efficiency - global south
    dynForc_effCar(ind_global_north,:) = dynForc_effCar_2050_n;
    dynForc_effCar(ind_global_south,:) = dynForc_effCar_2050_s;
 
    dynForc_effOT_2050_n = 0.38; // exogenous forcing on other transport efficiency - global north
    dynForc_effOT_2050_s = 0.4; // exogenous forcing on otehr transport efficiency - global south
    dynForc_effAir_2050_n = 1; // exogenous forcing on plane efficiency - global north
    dynForc_effAir_2050_s = 0.994; // exogenous forcing on plane efficiency - global south

    dynForc_EI_indus_50_n = 1.002;; // exogenous forcing on industry energy efficiency - global north
    dynForc_EI_indus_50_s = 1.012; // exogenous forcing on industry energy efficiency - global south
    dynForc_EI_indus_obj(ind_global_north) = dynForc_EI_indus_50_n;
    dynForc_EI_indus_obj(ind_global_south) = dynForc_EI_indus_50_s;

    dynForc_hdf_2050_n = 0.71; // exogenous forcing on industrial good consumption by households - global north
    dynForc_hdf_2050_s = 0.17; // exogenous forcing on industrial good consumption by households - global south
    dynForc_DIindu_2050_n = 0.51; // exogenous forcing on material efficiency (industrial input in capital formation) - global north
    dynForc_DIindu_2050_s = 0.45; // exogenous forcing on material efficiency (industrial input in capital formationproduction) - global south
    dynForc_DGindu_2050_n = 1; // exogenous forcing on industrial good consumption by the administration - global north
    dynForc_DGindu_2050_s = 0.75; // exogenous forcing on industrial good consumption by the administration - global south
    dynForc_CIindu_2050_n = 0.4; // exogenous forcing on material efficiency (industrial input in production) - global north
    dynForc_CIindu_2050_s = 0.4; // exogenous forcing on material efficiency (industrial input in production) - global south

    if indice_LED == 4 
        dynForc_CIindu_markup = 1;
    else
        dynForc_CIindu_markup = 0;
    end

    if indice_LED == 9
        dynForc_CIindu_CIcomp = 1;
    else
        dynForc_CIindu_CIcomp = 0;
    end

    if indice_LED >=1 
        dynForc_ETAarm_2050 = 1;
        dynForc_ETAarm_2050 = 3.0;
    end

    if indice_LED == 3
        dynForc_ETAarm_2050 = 1;
    end

    if ~isdef("dynForc_EI_indus2comp_obj") // default additional energy efficiency in the composite sector compare to the industrial one
        dynForc_EI_indus2comp_obj = 0.95;
    end
end
