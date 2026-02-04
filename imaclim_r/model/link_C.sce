// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================



call_table = ["allocate_matrix","set_param","set_paramX","economyC","economyXC","fill_2d_matrix"] ;
exec(unlink);
//Links the libraries. This code works both for linux and windos
if ~isfile(SOURCE+"liballocate_matrix"+getdynlibext())
    error(SOURCE+"liballocate_matrix"+getdynlibext()+" does not exist. Try to compile again")
else
link(SOURCE + "liballocate_matrix" + getdynlibext(), call_table,"c");
clear call_table 
end

//liste des parametres du static qui sont des hypermatrices
hyp_params = [
"bCI"
"CI"
"etaCI"
"itgbl_cost_CIdom"
"itgbl_cost_CIimp"
"partDomCIref"
"partDomCI_stock"
"taxCIdom"
"taxCIimp"
"alpha_partCI"
"taxCO2_CI"
"coef_Q_CO2_CI"
];

//liste des parametres du static qui sont des matrices et qui sont des variables du dynamique et qui sont interessants a regarder
meaningfull_params=[
"alphaCoalm2"
"alphaCompositeauto"
"alphaelecauto"
"alphaelecm2"
"alphaEtauto"
"alphaEtm2"
"alphaGazm2"
"bn"
"bnair"
"bnautomobile"
"bnNM"
"bnOT"
"Cap"
"Captransport"
"coef_Q_CO2_DF"
"Conso"
"DG"
"DIinfra"
"div"
"l"
"markup"
"markup_lim_oil"
"mtax"
"qtax"
"QuotasRevenue"
"Rdisp"
"sigma"
"stockbatiment"
"Tautomobile"
"taxCO2_DF"
"taxCO2_DG"
"taxCO2_DI"
"taxDFdom"
"taxDFimp"
"taxDGdom"
"taxDGimp"
"taxDIdom"
"taxDIimp"
"taxMKT"
"Ttax"
"xsi"
"xsiT"
"xtax"
];

//liste des parametres du static qui sont des matrices et qui sont des variables du dynamique, y compris ceux sans interet
mat_params = [
meaningfull_params;
"A"
"a0_mult_coal"
"a0_mult_gaz"
"a0_mult_oil"
"a1_mult_coal"
"a1_mult_gaz"
"a1_mult_oil"
"a2_mult_coal"
"a2_mult_gaz"
"a2_mult_oil"
"a3_mult_coal"
"a3_mult_gaz"
"a3_mult_oil"
"a4_mult_coal"
"a4_mult_gaz"
"a4_mult_oil"
"alphaair"
"alphaOT"
"alpha_partDF"
"alpha_partDG"
"alpha_partDI"
"aRD"
"atrans"
"aw"
"bDF"
"bDI"
"bDG"
"betatrans"
"bmarketshareener"
"bRD"
"btrans"
"bw"
"coef_Q_CO2_DG"
"coef_Q_CO2_DI"
"CO2_obj_MKTparam"
"cRD"
"cw"
"energ_sec"
"itgbl_cost_DFdom"
"itgbl_cost_DFimp"
"itgbl_cost_DGdom"
"itgbl_cost_DGimp"
"itgbl_cost_DIdom"
"itgbl_cost_DIimp"
"inertia_share"
"ktrans"
"eta"
"etaDF"
"etaDG"
"etaDI"
"etamarketshareener"
"etaTI"
"IR"
"L"
"nit"
"non_energ_sec"
"partDomDFref"
"partDomDF_stock"
"partDomDGref"
"partDomDG_stock"
"partDomDIref"
"partDomDI_stock"
"partExpK"
"partImpK"
"ptc"
"p_stock"
"sigmatrans"
"toair"
"toautomobile"
"toNM"
"toOT"
"Tdisp"
"weight"
"weightTI"
//"tax_max"
//"tax_min"
];

//adds all the parameters to the save_generic list
sg_add(hyp_params);
sg_add(mat_params);
sg_add("CO2_obj_MKTparam");
