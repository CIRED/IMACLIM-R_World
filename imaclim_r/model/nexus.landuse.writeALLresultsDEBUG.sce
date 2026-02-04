
suffix_temp = string(current_time+1) + "-" + suffix_type + "-"+ string(round(glob_in_bioelec_Et/1e7) /1e3) + "e10mKcal";
    time=timer();
    results(find(isnan(results)))=-9.9;
    global_results(find(isnan(global_results)))=-9.9;
    write_results(results(:,$),results_names,cur_run_output_dir,"simulation_result-ny"+ suffix_temp,reg);
    write_results(global_results(:,$),global_results_names,cur_run_output_dir,"simulation_global_results"+ suffix_temp,1);
