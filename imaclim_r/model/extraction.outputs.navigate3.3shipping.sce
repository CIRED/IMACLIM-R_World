// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

yr_start = 1;

for k=1:reg
    exec (MODEL+"extraction.outputs."+ETUDEOUTPUT+".region.sce");
end

// compute the world outputs here is the Nexus Land-Use is not used
exec(MODEL+"extraction.outputs."+ETUDEOUTPUT+".world.sce");
