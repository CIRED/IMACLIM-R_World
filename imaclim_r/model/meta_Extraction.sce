// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Julie Rozenberg
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// META extraction (righ clicable executable)
// Given a liste_savedir, this executes extraction for each SAVEDIR
// Aim is to update some calculus (e.g. get BRIC's emissions, beacuase that make sens for your study,
// when imaclim gave you regional emisions)

//=========PREAMBULE============
exec(".."+filesep()+"model"+filesep()+"preamble.sce");

//This function executes extraction, with no need of clearing,
// as variables in the function desapear when the function ends
function exec_extraction(SAVEDIR)
    //	exec (MODEL+"extraction."+ETUDEOUTPUT+".sce"); //Results from extraction will be stored in the hard drive
    //    sg_reload(SAVEDIR)
    metaRecMessOn = %t;
    clearglobal()
    sg_clear();
    message(SAVEDIR);
    exec(PARENT+"externals"+sep+"pdfExtraction"+sep+"extraction.pdf.sce");
endfunction

//Execution d'extraction pour chaque SAVEDIR
for SAVEDIR = get_dirlist()'
    exec_extraction();
end

exec(PARENT+"externals"+sep+"pdfExtraction"+sep+"analysis.sce");
cd(MODEL);
