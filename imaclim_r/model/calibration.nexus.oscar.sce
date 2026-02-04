// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


// conversion factor
Carbon_molar = 12.0107;
Oxygen_molar = 15.9994;
Hydrogen_molar = 1.00794;
Nitrogen_molar = 14.0067;
C_2_CO2 = (Carbon_molar + 2*Oxygen_molar) / Carbon_molar;
C_2_CH4 = (Carbon_molar + 4*Hydrogen_molar) / Carbon_molar;
N_2_N2O = (2*Nitrogen_molar + Oxygen_molar) / Nitrogen_molar;

// path Oscar and script to launch it
pathoscar="../externals/OSCAR/";
pathoscar_plugins="../externals/oscar_plugins/";
pythonscript2run="launch_oscar_for_imaclim_tpt.py";

// parameter of the study
unix_s("echo ''runname="""+ run_id+"""'' > " +pathoscar+ pythonscript2run);
unix_s("echo ''execfile(""../"+pathoscar_plugins+"/dolog.py"")'' >> " +pathoscar+ pythonscript2run);
unix_s("echo ''RCPXX=""RCP2.6""'' >> " + pathoscar+pythonscript2run);
if ind_oscar >=2
    unix_s("echo ''do_IRF=True'' >> " +pathoscar+ pythonscript2run);
else
    unix_s("echo ''do_IRF=False'' >> " +pathoscar+ pythonscript2run);
end
unix_s("echo ''do_dialog_withImaclim=True'' >> " +pathoscar+ pythonscript2run);

// dialog workspace  bwtween the two models
name_folder='/ImaclimROscar_dialog/';
path_dialog_withOscar = SAVEDIR+name_folder;
mkdir( SAVEDIR+name_folder);
unix_s("echo ''path_dialog_withImaclim="""+ path_dialog_withOscar+"""'' >> " +pathoscar+ pythonscript2run);

// launch Oscar
unix_s("echo ''execfile(""OSCAR.py"")'' >> " +pathoscar+ pythonscript2run);
unix_s("echo ''oscar_results = OSCAR_lite()'' >> " +pathoscar+ pythonscript2run);

unix_s("(cd "+pathoscar_plugins+" && sh launch_oscar_for_imaclim.sh) & ");
