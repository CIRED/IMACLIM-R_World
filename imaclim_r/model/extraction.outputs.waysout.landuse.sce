// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


//annees 2001-2005-2010-2020 etc

if ind_NLU_sensit > 0
    yr_start = 0;
else
    yr_start = 1;
end
  
  
counterLine_sav = counterLine;
for k=1:reg
    exec (MODEL+"extraction.outputs."+ETUDEOUTPUT+".region.landuse.sce");
end
  
  
exec(MODEL+"extraction.outputs."+ETUDEOUTPUT+".world.sce");
  
// =============================================== //
  
  