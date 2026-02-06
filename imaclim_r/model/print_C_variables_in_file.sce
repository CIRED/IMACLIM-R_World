// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Adrien Vogt-Schilb, Florian Leblanc, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


substep = 1
execstr ( hyp_params+"=(1-substep)*"+hyp_params+"_prev+substep*"+hyp_params+"_obj")
execstr ( mat_params+"=(1-substep)*"+mat_params+"_prev+substep*"+mat_params+"_obj")

//Allocates memory for the paramters of economyC and export them to the C. This includes defining nbMKT 
verbose = 1;
call("import_parameters_fixed_scilab2C");
call("import_parameters_dynamic_scilab2C");

//res_eco = call('economyC',size(equilibrium_prev,'r'),1,'i',equilibrium_prev,2,'d','out',[1,size(equilibrium_prev,'r')],3,'d')
res_eco = call('economyC',size(x0,'r'),1,'i',x0,2,'d','out',[1,size(x0,'r')],3,'d')
verbose = 1;

pause
