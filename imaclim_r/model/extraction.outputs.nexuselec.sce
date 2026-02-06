// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


// output extraction: regional and world values
current_time_im=current_time_im-1;
yr_start = 0;

for k=1:reg
    exec(MODEL+"extraction.outputs."+ETUDEOUTPUT+".region.sce");
end
// compute the world outputs here
exec(MODEL+"extraction.outputs."+ETUDEOUTPUT+".world.sce");

