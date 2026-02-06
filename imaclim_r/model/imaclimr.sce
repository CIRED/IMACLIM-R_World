// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Adrien Vogt-Schilb, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

////////////////////----------------------------------------------------/////////////////////
////////////////////           main executable file                     /////////////////////
////////////////////----------------------------------------------------/////////////////////

message(" ");
message(" ");
message(" ");
message(" _____ __  __          _____ _      _____ __  __        _____   __          __        _     _  ");
message(" |_   _|  \/  |   /\   / ____| |    |_   _|  \/  |      |  __ \  \ \        / /       | |   | | ");
message("   | | | \  / |  /  \ | |    | |      | | | \  / |______| |__) |  \ \  /\  / /__  _ __| | __| | ");
message("   | | | |\/| | / /\ \| |    | |      | | | |\/| |______|  _  /    \ \/  \/ / _ \| ''__| |/ _` | ");
message("  _| |_| |  | |/ ____ \ |____| |____ _| |_| |  | |      | | \ \     \  /\  / (_) | |  | | (_| | ");
message(" |_____|_|  |_/_/    \_\_____|______|_____|_|  |_|      |_|  \_\     \/  \/ \___/|_|  |_|\__,_| ");
message(" "); 
message(" ");
message(" IMACLIM-R World 2.0");
message(" IMpact Assessment of CLIMate policies");
message(" ");
message(" Authors: Ruben Bibas, Thibault Briera, Renaud Crassous, Gabriele Dabbaghian, Augustin Danneaux,");
message("          Liesbeth Defosse, Patrice Dumas, Vivien Fisch-Romito, Yann Gaucher, Nicolas Graves,");
message("          Céline Guivarch, Meriem Hamdi-Cherif, Thomas Le Gallic, Florian Leblanc, Julien Lefèvre,");
message("          Aurélie Méjean, Eoin Ó Broin, Julie Rozenberg, Olivier Sassi, Adrien Vogt-Schilb,");
message("          Henri Waisman, Séverine Wiltgen");
message(" ");
message(" ");
message(" ");

tic
//PREAMBLE
exec("preamble.sce");
if ~isdef("scenario_commentary")
    scenario_commentary = mgetl(PARENT + 'text_for_scenarios.txt',1);
end
message(scenario_commentary);

//DEFAULT VALUES
if ~isdef ("metaBeepOn")
    metaBeepOn = %t;        //CPU beps activation
end
if ~isdef ("loadingResults")
    loadingResults=%f;     //True is IMACLIM-R is launched from load_results (only the begining of the model is run)
end
if ~isdef ("combi")
    combi = 1;           //Default scenario combination
end


//////////////////////////////////////////////////////////
//    SAVE GENERIC INITIALISATION

sg_make_list();

////////////////////////////////////////////////////////////
// RUN NAME
////////////////////////////////////////////////////////////
run_name=combi2run_name(combi)
if loadingResults  // Rare case we launch IMACLIM-R by giving a "SAVEDIR", an already existing run
    un_id = svdr2rid(SAVEDIR);
    combi = run_name2combi(run_id);
    say("combi","run_id","SAVEDIR");
else // Most common usage
    //Create a run_date with the format 2009-02-04 10h04
    run_date = mydate();
    if ~isdef('suffix2combiName')
        suffix2combiName='';
    end
    run_id = run_name+suffix2combiName + "_" +run_date ;
    printf('\n');
    message("The run Idendifier is: "+run_id);
    SAVEDIR = OUTPUT+run_id+sep;
    mkdir ( SAVEDIR);
    dir_hide(SAVEDIR);//Hide the run output folder. Windows only
    LOGDIR = SAVEDIR + "log" + sep;
    mkdir(LOGDIR);
end
mkdir(SAVEDIR,"save");

diary(LOGDIR+"summary.log");

step_model = 0;

//////////////////////////////////////////////////////////////////////////////
//    PARAMETERS OF THE STUDY - STEP 1 - Prime parameters (specific)
step_model = step_model + 1;

printf('\n');
message("STEP " + string(step_model)+": DEFINE PARAMETERS OF THE STUDY (1)");

exec(STUDY+ETUDE+".sce");

// metadata for the diagnostic of scenarios
combi2outputname_path = STUDY+ETUDE+'_combi2outputname.csv';
if isfile(combi2outputname_path)
    combi2outputname = csvRead(combi2outputname_path, '|',  '.','string');
    outputrunname = combi2outputname( find( combi2outputname(:,1)==string(combi)) ,2);
else
    outputrunname = "";
end
if getos()=="Linux" & tool_output_diagnostic
    create_metadata_diagnos(SAVEDIR + "metadata_diagnostic.csv",combi,outputrunname, ind_sc_names, ind_sc_values, suffix2combiName, run_date, scenario_commentary);
    diagnotic_list = [];
end

/////////////////////////////////////////////////////////////////////////
//	DATA
/////////////////////////////////////////////////////////////////////////

// source of data, once study parameters are set
exec(MODEL + 'sources.sce');

step_model = step_model + 1;
printf('\n');
message("STEP " + string(step_model)+": DEFINE DATA SOURCES & PATH");

//////////////////////////////////////////////////////////////////////////////
//    PARAMETERS OF THE STUDY - STEP 2 - Interpretation (common)

step_model = step_model + 1;
printf('\n');
message("STEP " + string(step_model)+": DEFINE PARAMETERS OF THE STUDY (2)");

// study parameters conversion and interpretation should be common to all studies
// this includes some of the above lines
// In the following script, we start with the definition of climate policies (carbon tax or emissions trajectories
exec(STUDY+"study_parameters_interpretation.sce");

/////////////////////////////////////////////////////////////////////////////
//      Various consitency checks
/////////////////////////////////////////////////////////////////////////////
exec(STUDY+"testStudy.sce");


/////////////////////////////////////////////////////////////////////////
//	CALIBRATION
/////////////////////////////////////////////////////////////////////////

cd(MODEL);

step_model = step_model + 1;
printf('\n');
message("STEP " + string(step_model)+": CALIBRATION");

//list of Calibration.xxx files to executelistCalib=["static",..
listCalib=["static","crosssectoral.parameters","parameters.dyncalib"];

if ind_NLU > 0 | do_calibrateNoutput_NLU
    listCalib = [listCalib,"nexus.landuse"];
end
if ind_oscar>0
    listCalib = [listCalib,"nexus.oscar"];
end

listCalib = [listCalib,...
    "emissions","nexus.productiveSectors","industry",..
    "nexus.buildings","nexus.electricity",..
    "nexus.coal","nexus.oil","nexus.Et","nexus.cars",..
"investment","nexus.expectations","nexus.gas","nexus.wacc","nexus.climate.impacts"];

if ind_inequality == 1
    listCalib = [listCalib,"nexus.inequalities"];
end

if ind_climfin >0
    listCalib = [listCalib,"nexus.climfin"];
end

current_time_im = 0;
for nexus=listCalib
    exec(MODEL+"calibration."+nexus+".sce");
end
clear listCalib nexus

if NEXUS_resid_endogene==1 then
    exec(MODEL+"res_calib.sce");
end

if loadingResults
    return 
end

/////////////////////////////////////////////////////////////////////////////////////////////
//	CHECKING BENCHMARK DATA
/////////////////////////////////////////////////////////////////////////////////////////////

step_model = step_model + 1;
printf('\n');
message("STEP " + string(step_model)+": CHECKING BENCHMARK DATA");

sensibility = 1d-5; 
exec(MODEL+"benchmark.sce");

////////////////////////////////////////////////////////////////////////////
//	FIRST EQUILIBRIUM
/////////////////////////////////////////////////////////////////////////////////////////////

step_model = step_model + 1;
printf('\n');
message("STEP " + string(step_model)+": LOOKING FOR FIRST EQUILIBRIUM...");

exec (MODEL+"link_C.sce"); // LINKING WITH C FUNCTION

equi_function = "economyXC"; // economy economyX "economyC" "economyXC"
set_function  = "set_paramX";

//Allocates memory for the paramters of economyC and export them to the C. This includes defining nbMKT 
call("import_parameters_fixed_scilab2C");
call("import_parameters_dynamic_scilab2C");

/////////////////////counting the number of fsolve
global nb_fsolve
nb_fsolve=0;

/////////////////

equilibrium = x0;
v      = ones(nb_regions*nb_secteur_conso+5*nb_regions+3*nb_regions*nb_sectors+1,1);
memory = ones(nb_regions*nb_secteur_conso+5*nb_regions+3*nb_regions*nb_sectors+1,1);

[equilibrium, v, info]=solve_equilibrium(equilibrium,equi_function);

printf('\n');
message( "    Computing the first Equilibirum:")
if norm(v)<3d-3
    message( "       -> First General Equilibrium : [FOUND] "+norm(v)); 
else
    message( "       -> First General Equilibrium was not FOUND =("+norm(v))
    mkalert( "error")
    pause
end

message("       -> Obtained precision for first equilibrium = "+max(abs(v)));

exec(MODEL+"extraction-first.sce");

printf('\n');
printf( "    Executing one more time the First Equilibrium after the first result extraction \n      in order to increase accuracy");
[equilibrium, v, info]=solve_equilibrium(equilibrium,equi_function);
message("       -> Obtained precision for first equilibrium = "+max(abs(v)));

exec(MODEL+"calibration.nexus.eei.sce");
exec(MODEL+'calibration.fuel.substitution.sce');

////////////////////////////////////////////////////////////
// 	DYNAMIC RESOLUTION
////////////////////////////////////////////////////////////

step_model = step_model + 1;
printf('\n');
message("STEP " + string(step_model)+": MODEL RESOLUTION (RECURSIVE DYNAMIC TEMPORAL LOOP)...");

is_terminate = %f;
lref = l;

if ind_NLU_sensit == 0
    // Execution of the main recursive dynamic loop
    exec(MODEL+"res_dyn_loop.sce");
    //returning to stab_imaclim when badtax or error
    if wasError
        say("wasError")
        return
    end

    // Results extraction
    exec("terminate.sce");
    printf("Elapsed time was " + toc()/3600 + " hours\n");
else
    exec('NLU_sensit.sce')
end
