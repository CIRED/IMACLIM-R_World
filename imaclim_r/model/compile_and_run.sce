// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

exec link_C.sce;
//Allocates memory for the paramters of economyC. This includes defining nbcstrMKT 
call("allocate_matrix");

//passes the hypermatricial parameters to economyC
for mat=["bCI","CI","etaCI","intangible_cost_CIdom","intangible_cost_CIimp","partDomCIref","partDomCI_prev",..
  "taxCIdom","taxCIimp","alpha_partCI","taxCO2_CI","coef_Q_CO2_CI"]
  pass_3d_matrix(mat,reg);
end

call("set_paramX")
norm(fort("economyXC",size(x0,'r'),1,'current_time_im',x0,2,'d','out',[1,size(x0,'r')],3,'d'))
