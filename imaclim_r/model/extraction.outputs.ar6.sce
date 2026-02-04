// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Nicolas Graves, Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// TODO :
// Price|Secondary Energy|Liquids|Biomass


// when the NLU is executed alone with exxogenous Imacliml driver of a scenario
if ind_NLU_sensit > 0
  current_time_im=current_time_im-1;
  yr_start = 0;
else
  yr_start = 1;
end

for k=1:reg
    exec (MODEL+"extraction.outputs."+ETUDEOUTPUT+".region.sce");
end

// for the base year output here the land-use variables
if ind_NLU >0 & current_time==0
    exec (MODEL+"extraction.outputs."+ETUDEOUTPUT+".region.landuse.sce");
end

// compute the world outputs here is the Nexus Land-Use is not used
if ind_NLU ==0 
    exec(MODEL+"extraction.outputs."+ETUDEOUTPUT+".world.sce");
end
