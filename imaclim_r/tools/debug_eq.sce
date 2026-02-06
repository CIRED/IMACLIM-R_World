// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Adrien Vogt-Schilb, Florian Leblanc, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// use the following line to debug the second equilibrium, after the dynamic.
// To do so 'pause' the model juste before the //loop on substep in res_dyn_loop.sce
// then start with minus_hyper=0 and minus_mat0 and increase them by dichomoty to guess
// which variable causes problem.
// then beofre finding a second variable, fix the one found like :
alphaelecm2=alphaelecm2_prev

substep=1;
execstr ( hyp_params+"=(1-substep)*"+hyp_params+"_prev+substep*"+hyp_params+"_obj")
execstr ( mat_params+"=(1-substep)*"+mat_params+"_prev+substep*"+mat_params+"_obj")

minus_hyper=12;
minus_mat=117;

for i=1:(size(hyp_params,'r')-minus_hyper)
    execstr( hyp_params(i)+" = "+hyp_params(i)+"_prev")
end
for i=1:(size(mat_params,'r')-minus_mat)
    execstr( mat_params(i)+" = "+mat_params(i)+"_prev")
end

//117-11
//partExpK=partExpK_prev;
//117-104
//Cap=Cap_prev;
//117-114
//alphaelecm2=alphaelecm2_prev;

[equilibrium_n, v, info]=solve_equilibrium(equilibrium,equi_function);
disp( [norm(v), info])

