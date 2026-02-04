//This files "ends" imaclim and delayed_imaclim

disp "==Terminate=="

is_terminate = %t;
// create nexus land-use outputs
if ind_NLU == 1
    exec(MODEL+"nexus.landuse.real.sce");
    time=timer();
    results(find(isnan(results)))=-9.9;
    global_results(find(isnan(global_results)))=-9.9;
    write_results(results,results_names,cur_run_output_dir,"simulation_result-ny"+string(current_time+1)+str_val,reg);
    write_results(global_results,global_results_names,cur_run_output_dir,"simulation_global_results",1);
    printf("\nNumber of simulation years: %current_time_im\n",current_time+1);
    printf("Results stored in: "+cur_run_output_dir+"\n");
    str2print="""Better is the chance to improve global food security\n";
    str2print=str2print+"by taking a dump properly\n";
    str2print=str2print+"than coding in the Nexus Land-Use""\n";
    str2print=str2print+"                  --  The wise occidental''s Firmament\n";
    str2print=str2print+"                  --  aka Thierry Brunelle\n";
    printf( str2print);
end
if ind_NLU ==0 & combi == 7
  p_et_temp = matrix( pArmCI(indice_Et,indice_agriculture,:), nb_regions,1);
  q_et_temp = matrix( energy_balance(refi_eb,et_eb,:), nb_regions,1)
  wlightoil_price = sum(q_et_temp .* p_et_temp) / sum(q_et_temp);
  wnatgas_price =  wp_gaz_anticip_nlu;
  for regy=1:nb_regions
    reg_taxeC(regy) = taxMKT( whichMKT_reg_use(regy)) * 1e6 ; // ($/tCO2eq)
  end
end
if (current_time_im> 1 & do_calibrateNoutput_NLU);
    exec(MODEL+"extraction.outputs."+ETUDEOUTPUT+".landuse.sce");
end

if do_calibrateNoutput_NLU ==%t
  if do_specific_outputs then
    printf("Writing EMF 33 outputs...");
    fprintfMat(file_EMF,results_emf);
 //   fprintfMat(file_EMF_reg,results_emf_reg);
 //   fprintfMat(file_add_var,add_variables);
 //   fprintfMat(file_add_var_reg,add_variables_reg);
    printf("Done\n");
 end
end

////////////// Dernieres sauvegardes ///////////////////
sg_save(); //sauvegarde de save_generic.sci 

//sauvegardes particulières
if indice_ATC_calib_REF
    xsi_sav_REF=sgv("xsi_sav"); //this gets xsi_sav from save_generic
	mksav("xsi_sav_REF");
end
dir_unhide(SAVEDIR);//enlève le "hidden" du dossier de sortie.

IamDoneFolks=1;
mksav("IamDoneFolks");
///////////////extraction

if metaExtractioOn  
    mkalert("error")
    disp("executing big extraction...")
    disp("pay attention to discrepancies between Tair = alphaair .*Tair and Tair used as such");
    exec ( "extraction.sce"); 
end

exec("extraction."+ETUDEOUTPUT+".sce");

if ETUDE=='impacts'
    exec(MODEL+"extraction.specific.impacts.sce");
end

// output the .xlsx diagnostic file
if getos()=="Linux" & tool_output_diagnostic
    create_data_diagnos(SAVEDIR + "data_diagnostic.csv",diagnotic_list,STUDY+ETUDE+"_list.output.diagnostic.txt");
    xlsx_diagnos_filename = "imaclim_scenario_diagnostic";
    // check if the meta .xlsx file is being created of modified by another run
    [fd,err]=mopen(xlsx_diagnos_filename+"_available.txt");
    mclose(fd);
    file_updated=%f;
    if err == 0 // check .xls file availability only if the exchange file xlsx_diagnos_filename+"_available.txt" exists
	i=0;
        while i<100 & ~file_updated
            fd=csvRead(xlsx_diagnos_filename+"_available.txt");
            if fd = 1
                file_updated=%t;
            end
            i=i+1;
            sleep(1000); // wait 1 second before trying again
        end
    else
        file_updated=%t;
    end
    if file_updated==%t
        cd(OUTPUT);
        unix_s("nohup /data/software/anaconda3/bin/python update_diagnostic_xlsx_file.py -p """+SAVEDIR+""" ");
    end
end

// output to the .xlsx IAMC file
if getos()=="Linux" 
    filenamedata = "sel_outputs_"+ETUDEOUTPUT + fit_combi(combi) + ".tsv";
    unix_s("cp "+OUTPUT+"export_imaclim_tsv_2_ar6excel.py "+SAVEDIR);
    cd(SAVEDIR);
    unix_s("nohup /data/software/python2.7.17/bin/python2.7 export_imaclim_tsv_2_ar6excel.py -s """+outputrunname+""" -f """+filenamedata+""" ");
end

// create the pdf
exec(PARENT+"externals"+sep+"pdfExtraction"+sep+"analysis.sce");
exec(PARENT+"externals"+sep+"pdfExtraction"+sep+"extraction.pdf.sce");

mkalert("done");
disp(run_id,SAVEDIR,"extraction done, results are located in:");
