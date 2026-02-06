// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


call_table = ["imaclim_static_cge","import_parameters_fixed_scilab2C","import_parameters_dynamic_scilab2C","economyC","economyXC"]; // functions to be added to the call table 
unlink(call_table);
//Links the libraries. This code works both for linux and windos
if ~isfile(SOURCE+"libimaclim_static_cge"+getdynlibext())
    error(SOURCE+"libimaclim_static_cge"+getdynlibext()+" does not exist. Try to compile again")
else
    link(SOURCE + "libimaclim_static_cge" + getdynlibext(), call_table,"c");
    clear call_table 
end

//list of parameters of the C static equilibrium that have more than 2 dimenssions (hypermatrix)
hyp_params = [
"bCI"
"CI"
"etaCI"
"itgbl_cost_CIdom"
"itgbl_cost_CIimp"
"partDomCIref"
"partDomCI_stock"
"partDomCI_min"
"taxCIdom"
"taxCIimp"
"alpha_partCI"
"taxCO2_CI"
"coef_Q_CO2_CI"
];

//list of parameters of the C static equilibrium  that are variables from the dynamic modules
mat_params = ["partTIref","DIprod","pindref","etaTI","etaEtnew","inertia_share","A","aRD","bRD","cRD","DG","DIinfra","bn","Cap","coef_Q_CO2_DF","coef_Q_CO2_DG","coef_Q_CO2_DI","Ttax","xtax","l","markup","partDomDGref","partDomDIref","partDomDFref","markup_lim_oil","mtax","energ_sec","nit","non_energ_sec","partDomDF_stock","partDomDG_stock","partDomDI_stock","qtax","sigma","taxCO2_DF","taxDFdom","taxDFimp","taxDGdom","taxDGimp","taxDIdom","taxDIimp","alphaCompositeauto","weight_regional_tax","alphaEtauto","alphaelecauto","alphaEtm2","stockbatiment","alphaelecm2","alphaCoalm2","alphaGazm2","L","coef_Q_CO2_Et_prod","QuotasRevenue","alphaair","ptc","a4_mult_oil","a3_mult_oil","a2_mult_oil","a1_mult_oil","a0_mult_oil","a4_mult_gaz","a3_mult_gaz","a2_mult_gaz","a1_mult_gaz","a0_mult_gaz","a4_mult_coal","a3_mult_coal","a2_mult_coal","a1_mult_coal","a0_mult_coal","alphaOT","Rdisp","bnair","bnautomobile","bnNM","bnOT","Tautomobile","Tdisp","toair","DFair_exo","toautomobile","toNM","toOT","eta","etamarketshareener","aw","bw","cw","div","partExpK","partImpK","IR","sigmatrans","xsiT","weightEt_new","alpha_partDF","alpha_partDG","alpha_partDI","itgbl_cost_DFdom","itgbl_cost_DGdom","itgbl_cost_DIdom","itgbl_cost_DFimp","itgbl_cost_DGimp","itgbl_cost_DIimp","p_stock","bmarketshareener","atrans","btrans","Captransport","ktrans","weightTI","xsi","weight","bDF","bDG","bDI","etaDF","etaDG","etaDI","betatrans","Conso","partDomCI_min","partDomDF_min"]';

//adds all the parameters to the save_generic list
sg_add(hyp_params);
sg_add(mat_params);
sg_add("CO2_obj_MKTparam");
