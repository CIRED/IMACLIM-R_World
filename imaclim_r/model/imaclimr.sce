// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Ruben Bibas, Julie Rozenberg, Adrien Vogt-Schilb, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
//  IMACLIM-R
//  International Multisector Computable General Equilibrium Model
//
////////////////////----------------------------------------------------/////////////////////
////////////////////           main executable file                     /////////////////////
////////////////////----------------------------------------------------/////////////////////
tic
//PREAMBULE
exec("preamble.sce");
if ~isdef("scenario_commentary")
    scenario_commentary = mgetl(PARENT + 'text_for_scenarios.txt',1);
end
disp(scenario_commentary);

//DEFAULT VALUES
if ~isdef("metaRecMessOn")
    metaRecMessOn = %t;     //Activer les messages d'avancement de la résolution récursive
end
if ~isdef ("metaBeepOn")
    metaBeepOn = %t;        //Activer les beeps CPU
end
if ~isdef ( "metaExtractioOn")
    metaExtractioOn=%f;     //Activer la grande extraction (gros truc d'olivier). extraction-ETUDE est exécuté quoiqu'il arrive (dans terminate)
end
if ~isdef ("loadingResults")
    loadingResults=%f;     //Vrai si imaclim est lancé par load results (only the begining of imaclim is runed)
end
if ~isdef ("combi")
    combi = 1;           //Combinaison par defaut (variantes de l'ETUDE (etude est définie dans preamble))
end


//////////////////////////////////////////////////////////
//    SAVE GENERIC INITIALISATION

sg_make_list();

////////////////////////////////////////////////////////////
// RUN NAME
////////////////////////////////////////////////////////////
run_name=combi2run_name(combi)
if loadingResults  // si On a lancé imaclim en lui donnant un SAVEDIR pour executer que le debut (asser rare)
    run_id = svdr2rid(SAVEDIR);
    combi = run_name2combi(run_id);
    say("combi","run_id","SAVEDIR");
else //cas "normal"
    //Creation d'une run_date sous la forme 2009-02-04 10h04
    run_date = mydate();
    if ~isdef('suffix2combiName')
        suffix2combiName='';
    end
    run_id = run_name+suffix2combiName + "_" +run_date ;
    say("run_id");
    SAVEDIR = OUTPUT+run_id+sep;
    mkdir ( SAVEDIR);
    dir_hide(SAVEDIR);//cache le dossier de sortie. Repparaitra à la fin.
    LOGDIR = SAVEDIR + "log" + sep;
    mkdir(LOGDIR);
end
mkdir(SAVEDIR,"save");

diary(LOGDIR+"summary.log");
say("run_id");

//////////////////////////////////////////////////////////////////////////////
//    PARAMETERS OF THE STUDY
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

//Ceci garantit la pertinence des xsi_sav_REF
if ~is_bau 
    //this....
    ldsav ("xsi_sav","",baseline_combi)
    xsi_sav_REF=xsi_sav;
    mksav("xsi_sav_REF",liste_savedir(baseline_combi));
    clear xsi_sav
    //..has to be deleted, say, in june, but do not "retro-merge" it
    indice_ATC_calib_REF=0;
    say("is_bau","indice_ATC_calib_REF");
end

/////////////////////////////////////////////////////////////////////////
//	DATA
/////////////////////////////////////////////////////////////////////////

// source of data, once study parameters are set
exec(MODEL + 'sources.sce');

disp("STEP 1: LOADING GENERAL DATA");

// Growth drivers data : population and labor productivity
exec(MODEL+'calibration.growthdrivers.sce');
cd(MODEL);

/////////////////////////////////////////////////////////////////////////
//	CALIBRATION
/////////////////////////////////////////////////////////////////////////

disp("STEP 2: CALIBRATION");

//Liste of Calibration.xxx files to executelistCalib=["static",..
listCalib=["static","crosssectoral.parameters"];

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
"investment","nexus.expectations","nexus.gas","nexus.wacc"];

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

sensibility = 1d-5; 
disp("STEP 3: CHECKING BENCHMARK DATA");
exec(MODEL+"benchmark.sce");


////////////////////////////////////////////////////////////////////////////
//	FIRST EQUILIBRIUM
/////////////////////////////////////////////////////////////////////////////////////////////

disp("STEP 4: LOOKING FOR FIRST EQUILIBRIUM...");

exec (MODEL+"link_C.sce"); // LINKING WITH C FUNCTION


equi_function = "economyXC"; // economy economyX "economyC" "economyXC"
set_function  = "set_paramX";

//Allocates memory for the paramters of economyC. This includes defining nbMKT 
call("allocate_matrix");

updateCparams();

/////////////////////comptage des fsolve
global nb_fsolve
nb_fsolve=0;

/////////////////

equilibrium = x0;
v      = ones(nb_regions*nb_secteur_conso+5*nb_regions+3*nb_regions*nb_sectors+1,1);
memory = ones(nb_regions*nb_secteur_conso+5*nb_regions+3*nb_regions*nb_sectors+1,1);

[equilibrium, v, info]=solve_equilibrium(equilibrium,equi_function);

if norm(v)<3d-3
    disp( " First General Equilibrium : [FOUND] "+norm(v)); 
else
    disp( " First General Equilibrium was not FOUND =("+norm(v))
    mkalert( "error")
    pause
end

if metaRecMessOn
    disp("Obtained precision for first equilibrium = "+max(abs(v)));
end

exec(MODEL+"extraction-first.sce");

disp( " Executing one more time the First Equilibrium after the first result extraction\nin order to increase accuracy");
[equilibrium, v, info]=solve_equilibrium(equilibrium,equi_function);
disp("Obtained precision for first equilibrium = "+max(abs(v)));

exec(MODEL+"calibration.nexus.eei.sce");
exec(MODEL+'calibration.fuel.substitution.sce');
// old calibration of nexus industry, see revision 29335

////////////////////////////////////////////////////////////
// 	DYNAMIC RESOLUTION
////////////////////////////////////////////////////////////

is_terminate = %f;
disp("STEP 5: MODEL RESOLUTION...");
lref = l;

if ind_NLU_sensit == 0
   // 3 Execution de la boucle principale
   exec(MODEL+"res_dyn_loop.sce");
   //returning to stab_imaclim when badtax or error
   if wasError
       say("wasError")
       return
   end

   // 4 extraction et affichage des resultats
   exec("terminate.sce");
   printf("Elapsed time was " + toc()/3600 + " hours\n");
else
   exec('NLU_sensit.sce')
end
