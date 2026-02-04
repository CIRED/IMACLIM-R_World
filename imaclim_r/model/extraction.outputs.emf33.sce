// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Nicolas Graves, Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// TODO :
// Price|Secondary Energy|Liquids|Biomass



if ind_NLU_sensit > 0
  current_time_im=current_time_im-1;
  yr_start = 0;
else
  yr_start = 1;
end


for k=1:reg
    exec (MODEL+"extraction.outputs."+ETUDEOUTPUT+".region.sce");
end


