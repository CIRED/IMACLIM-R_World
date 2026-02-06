// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Séverine Wiltgen
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

exec link_C.sce;
//Allocates memory for the paramters of economyC. This includes defining nbcstrMKT 
export_fixed_parameters_C();
export_dynamic_parameters_C();

call("set_paramX")
res_eco = call('economyC',size(x0,'r'),1,'i',x0,2,'d','out',[1,size(x0,'r')],3,'d');
norm(res_eco);
