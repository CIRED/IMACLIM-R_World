/////////////////////////////
///       Paths           ///
/////////////////////////////
// data dirs

//SAVEDIR = OUTPUT+'NLU_output'+sep;

//those lines are needed when datas has to be regenerate.. it shouldn't be needed when running Imaclim then.
//data_shared_dir = '/non_public/data/directory/'; // On poseidon
//base_data_dir = '/home/leblanc/dataPoseidon/';  // Locally with sshfs towards poseidon
//data_shared_dir = base_data_dir + 'shared/';
//data_public_dir = base_data_dir + 'public_data/';
//bouwman_csv_dir_old = data_shared_dir+'bouwman/results/';
//agribiom_shared_dir = data_shared_dir+'agribiom/Agribiom/';
//orchidee_dir = data_shared_dir+'ORCHIDEE/data/yields_change/';

base_dir = externals_dir + 'land-use'        + sep ;
base_dir_data = base_dir;
datas_dir = base_dir_data +'datas'+sep;
parameters_dir = base_dir+'parameters'+sep;
scenarios_dir = base_dir+'scenarios'+sep;
codes_dir = base_dir+ 'nexus_land-use'+sep+'trunk'+sep;
input_dir = base_dir_data+"input/";
data_public_dir = input_dir;
//common_codes_dir = common_codes_dir; // normally defined before in imaclim (preamble.sce)

//NLU_or_Imaclim_dir = SAVEDIR;
NLU_or_Imaclim_dir = SAVEDIR ; // SAVEDIR for imaclim, base_dir for NLU for example

SAVEDIR_NLU = NLU_or_Imaclim_dir + 'NLU' + sep ;
mkdir(SAVEDIR_NLU);
output_dir = SAVEDIR_NLU ;
yields_area_dir = base_dir_data+'output_yad'+sep+'CSV'+sep;
run_output_dir = SAVEDIR_NLU+'Runs'+sep+'Other_simulations'+sep;
ref_fertilizer_cons_dir = SAVEDIR_NLU+"Runs/sensit_energy_price/reference_nexus_NUE/";
output_calibration_dir = SAVEDIR_NLU + 'output_calibration'+sep;
cur_run_out4density_dir = SAVEDIR_NLU + 'density'+sep;

cur_run_output_dir = SAVEDIR_NLU+'Runs'+sep;

//not needed anymore
//agribiom_dir=agribiom_shared_dir;

/////////////////////////////
///       Parameters      ///
/////////////////////////////

//reg=reg; //same variable for Imaclim-R, number of regions is reg
verbose_density=%F;
verbose_imports=%F;
verbose_plot=%F;
kill_windows=%F;
//stacksize(100000000);
//stacksize is 3e7 for Imaclim.. it should be ok for nexus land use as weel
gstacksize(1e8);
