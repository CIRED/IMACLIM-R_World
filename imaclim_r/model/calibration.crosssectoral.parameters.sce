// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thibault Briera, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================



/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   Discount rates
/////////////////////////////////////////////////////////////////////////////////////////////

disc_rate_elec = 0.1 * ones(nb_regions,techno_elec,TimeHorizon);

disc_rate_EEI = 0.1 * ones(reg,1);
disc_rate_et = 0.1 * ones(reg,1);
// discount rate for the cost of renovation in private buildings (paid by states through DG)
if NEXUS_resid_endogene==0
    disc_res=0.1;
end

// renovation cost of buildings in productive sectors
disc_ser = 0.1;
disc_ind = 0.1;
disc_agr = 0.1;
disc_btp = 0.1;

// nexus.cars
disc_cars = 0.13132953; // value for CRF_cars = 0.17 and lifetime=12

// Nexus industry: discount rate and lifetime are implicit
CRF_industrie=0.1*ones(4,1);
CRF_agriculture=0.1*ones(4,1);
CRF_composite=0.1*ones(4,1);


/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   Inertia shares
/////////////////////////////////////////////////////////////////////////////////////////////

//////////
// inertia in nexus.electricity
inertia_elec_CI = 2/3;

if ind_new_rho_calib==1
    inertia_elec_CI = 5/6;
    inertia_elec_CI_init = inertia_elec_CI;
    inertia_elec_CI_target = 2/3;
end
inertia_elec_markup = 3/4;

//////////
// inertia in nexus.transport
// minimum and maximum inertia coeff. are not direct inertia rules
// but rather a min/max rules, i-e actual inertia could be lower (if _min_)
// max( val, val_prev * inertia_min_val

inertia_min_CapTranspCar = 0.98;

yr_chg_inertia_Trans_s = 30; // year of for changing inertia aprameters for global south
inertia_max_CapAir = 1.06;
inertia_max_CapOT_n = 1.02;
inertia_min_CapTran_n = 0.98;
inertia_max_CapOT_s_01 = 1.06;
inertia_min_CapTran_s_01 = inertia_min_CapTran_n;
inertia_max_CapOT_s_30 = inertia_max_CapOT_n;
inertia_min_CapTran_s_30 = 0.96;

max_EnerEff_ET_OT=0.97;

//////////
// inertia in nexus.buildings
inertia_alphaEnerm2 = 4/5;

//////////
// inertia in nexus.Et
inertia_coefCO2coal_elec = 2/3;
//inertiaShareEt define wth several values in study_frames

//////////
// inertia in nexus.coal
inertia_markup_coal = 2/3;
// min and max evolution of coal markup, after inertias
max_evol_markup_coal = 0.03;
min_evol_markup_coal = -0.03;

//////////
// inertia in nexus.gas
inertia_markup_gas = 2/3;
// min and max evolution of coal markup, after inertias
max_evol_markup_gas = 0.03;
min_evol_markup_gas = -0.03;

inertia_wp_oilForGas = 2/3;

// inertia on share for energy imports/exports
// should we set to 1 for all scenarios ? this is a parameters that should be in the study frame of somewhere else.
if new_Et_msh_computation ==0
    inertia_share=1;
else
    inertia_share=4/5;
end


/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   Other
/////////////////////////////////////////////////////////////////////////////////////////////

// sectoral chartge (Q/Cap) at which there is no  marginal decreasing return (FCC=1)
base_charge_noFCC = 0.8*ones(nb_regions,1);

// minimum markup for fossil sectors
min_markup_fossil = 0.01;

if ~isdef("nb_year_expect_LCC") & ind_short_term_hor==1 // Planning horizon (elec and buildings). nb_year_expect_LCC is shorter than the technical lifetime of the technologies to reflect shorter economic planning horizons and finance constraints (e.g. loan tenure)
    nb_year_expect_LCC = 10; 
end
