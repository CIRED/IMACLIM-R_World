// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Adrien Vogt-Schilb, Ruben Bibas, Julie Rozenberg
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////////////////////////////
////																			/////
////								PREAMBULE									/////
////																			/////
////	This file get all started to scilab to begin being an IMACLIM session   /////
////           It also defines  the *USER CHOICE*  ETUDE                        /////
/////////////////////////////////////////////////////////////////////////////////////

// Display options
if ~isdef("verbose")
    verbose           = 0 ; // displays the values inside the static of last fsolve when equilibrium is not found
end
ind.monitor       = %f; // displays a lot of monitor file in res_dyn_loop (just before finding equilibrium)
nbSubdivisionsMax = 9;
nbCapTaxesMax     = 20;

//TECHNICAL PREAMBULE TO THE PREAMBULE

//Two next blocs : 
//Makes sure preamble is executed only once
if ~isdef ("IsPreambule_exec")
    IsPreambule_exec = %f;
end
if IsPreambule_exec 
    return
end

// This variable is used in bigsave function
// It remembers how many system variables exists, to not save them, so not load them, and no create an error
// (e.g. avoid 'redefining %current_time_im' error)
bigs_nb_sys_var = size(who("local"),"*")-1; //-1 stands for IsPreambule_exec

lines(0);       //No asking (continue to display) (scilab option)

///////
// MODEL FILE STRUCTURE

// '/' or '\' depending on OS
sep = filesep();
cd "..";
PARENT  = pwd()  + sep;
MODEL   = PARENT + "model"        + sep ;
DATA    = PARENT + "data"         + sep ;
CONTROL = PARENT + "control"      + sep ;
LIB     = PARENT + "lib"          + sep ;
OUTPUT  = PARENT + "outputs"      + sep ;
SOURCE  = PARENT + "source"       + sep ;
STUDY   = PARENT + "study_frames" + sep ;
EMISSIONS  = PARENT + "study_frames"+sep+"DataEmissions"+sep ;
TAXDIR  = PARENT + "study_frames"+sep+"DataTaxes"+sep ;
externals_dir = PARENT + 'externals' + sep ;
common_codes_dir = externals_dir + 'common_code_for_nlu'+sep+'scilab'+sep;
common_codes_head_dir = externals_dir + 'common_code_head'+sep+'scilab'+sep;

mkdir(OUTPUT);

//////////////////////////////////////////////////////////////////////////////
//   GETTING  FUNCTIONS and INDEXES

//Gets all the functions in LIB dir
getd(LIB);
// load graphical librairy only in graphic mode
try
    get("current_figure"); // will raise an error if not in graphical mode
    getd(LIB+"plot_lib/");
    str_temp = "Graphic window is open. Plotting librairy loaded";
catch
    str_temp = "Graphic window is not open, plotting librairy could not be loaded";
end
if verbose>=1
    warning(str_temp);
end
getd(common_codes_dir);


//TODO: Should be define in study? Defined here as in the current version, indexes.sce is executed before study.sce. For now I think we should define only 2 options: fully aggregated or fully disaggregated. The other options can easily be built from the fully disaggregated option. To be confirmed.

desag_industry	= 0;
desag_services	= 0;

if desag_industry == 0
    nb_sectors_industry = 1;
else
    nb_sectors_industry = 8;
end

if desag_services == 0 //MULTISECTOR: to be updated
    nb_sectors_services = 1;
else
    nb_sectors_services = 8; 
end
// indices, matrix sizes, units
exec(MODEL+"indexes.sce");
exec(MODEL+"units.sce");

//////////////////////////////////////////////////////////////////////////////
//    *USER CHOICE*  STUDY FRAME

if ~isdef('ETUDE')
    ETUDE ="base";
end
if ~isdef('ETUDEOUTPUT')
    ETUDEOUTPUT="navigate";
end
// indices of the different scenario in the study
matrice_indices=read_matrice_indices();

// FUNCTIONS ALIAS
hc  = head_comments; 
clg = clearglobal;  

//Getting done scenarios (liste_savedir)
[liste_savedir tooManySubs]=make_savedir();//from savedir_lib.sci

//Remembers this as been executed
IsPreambule_exec=%t;
