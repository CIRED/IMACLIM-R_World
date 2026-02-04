// This script send the information on emission to the Oscar model

// Oscar work with the Nexus Land-Use model
// Handle when Nexus Land-use failed to solve equilibrium
if real_failed
    surfcrop_total = surfcrop_total_prev;
    surfforest = surfforest_prev;
    surf_bioener = surf_bioener_prev;
    NO2_tot = NO2_totp;
    CH4_tot = CH4_totp;
end

// for log
disp("DOING NEXUS OSCAR")

if current_time_im>=10 // means 2010 is done and we are at the beginning of 2011
  // 9 is 2010 for Imaclim, so Oscar should have run the 2009
  emi_tot = ( sum(E_reg_use,"c") + emi_eviteeLast)' / 1e9 *12 ./44;
  csvWrite(emi_tot,path_dialog_withOscar+'/imaclim_EFF'+string(2000+current_time_im),'|');
  if ind_NLU>0
      d_surf_c = (surfcrop_total-surfcrop_total_prev).*ha2Mha;
      d_surf_f = (surfforest-surfforest_prev).*ha2Mha;
      d_surf_b = (surf_bioener - surf_bioener_prev).*ha2Mha;
      csvWrite( d_surf_b .* (d_surf_b>0) + d_surf_c .* (d_surf_c>0) , path_dialog_withOscar+'/imaclim_LUC_gra2cro'+string(2000+current_time_im),'|');
      csvWrite( d_surf_b .* (d_surf_b<0) + d_surf_c .* (d_surf_c<0) , path_dialog_withOscar+'/imaclim_LUC_cro2gra'+string(2000+current_time_im),'|');
      csvWrite( d_surf_f .* (d_surf_f<0) , path_dialog_withOscar+'/imaclim_LUC_for2gra'+string(2000+current_time_im),'|');
      csvWrite( d_surf_f .* (d_surf_f>0) , path_dialog_withOscar+'/imaclim_LUC_gra2for'+string(2000+current_time_im),'|');
      // harvest is zero from now
      csvWrite(zeros(nb_regions,1),path_dialog_withOscar+'/imaclim_LUC_harv'+string(2000+current_time_im),'|');
      // CH4 and N20
      csvWrite( NO2_tot / N_2_N2O / 1e3, path_dialog_withOscar+'/imaclim_n2o'+string(2000+current_time_im),'|');
      csvWrite( CH4_tot / C_2_CH4, path_dialog_withOscar+'/imaclim_ch4'+string(2000+current_time_im),'|');
  else // dealing with missing file for Oscar
    csvWrite(zeros(nb_regions,1),path_dialog_withOscar+'/imaclim_LUC_harv'+string(2000+current_time_im),'|');
  end
  // then we send a signal to oscar so that it can run the next timestep
  csvWrite(0,path_dialog_withOscar+'/imaclim'+string(2000+current_time_im));

  // before continuing the Imaclim script, we wait for Oscar to have completed the current year
  oscar_ready=%f;
  while ~oscar_ready
    disp("waiting for oscar")
    sleep( 2000);
    if isfile(path_dialog_withOscar+'/oscar'+string(2000+current_time_im) )
      oscar_ready=%t // oscar has runned one more year
    end
  end
end
