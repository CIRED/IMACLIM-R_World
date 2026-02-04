
verbose = 1; // 1 for debugging/coding/coupling with NLU
current_time_prev = current_time_im ;
// executed in nexus.landuse.sce
// executed one last time in terminate.sce
// Evolution de coutfixeint for the Nexus Land-Use
va_agri_prev = va_agri;
va_agri = (Q(:,agri).*... // non unitary expression
(A(:,agri).*w(:,agri).*l(:,agri).*(energ_sec(:,agri) + FCC(:,agri).*non_energ_sec(:,agri)) + p(:,agri).*markup(:,agri).*FCCmarkup_oil(:,agri).* (FCC(:,agri).* energ_sec(:,agri) + non_energ_sec(:,agri))))';
va_agri = va_agri ./ ( p(:,agri) .*Q(:,agri) ./ (1+ qtax(:,agri)) )'; // by unit of production

if ind_NLU_CF == 1
    coutfixeint_prev = coutfixeint;
    coutfixeint  = coutfixeint .* va_agri./va_agri_prev;
    increase_CF = coutfixeint ./ coutfixeint_prev;
    increase_CF_cellul_trspt = increase_CF;
    increase_CF_for_trspt = increase_CF;
    increase_CF_for_harv = increase_CF;
    increase_CF_cellul = increase_CF;
end

//Imaclim-R gives the proper variables to the Nexus Land-Use
p_et_temp = matrix( pArmCI(indice_Et,indice_agriculture,:), nb_regions,1);
p_gaz_temp = matrix( pArmCI(indice_gaz,indice_industrie,:), nb_regions,1);
q_et_temp = matrix( energy_balance(refi_eb,et_eb,:), nb_regions,1);
q_gaz_temp = matrix( (energy_balance(tpes_eb,gaz_eb,:) + energy_balance(pwplant_eb,gaz_eb,:) + energy_balance(losses_eb,gaz_eb,:)), nb_regions,1);
wnatgas_price = sum(q_gaz_temp .* p_gaz_temp) / sum(q_gaz_temp);
wlightoil_price = sum(q_et_temp .* p_et_temp) / sum(q_et_temp);
wnatgas_price =  wp_gaz_anticip_nlu;

for regy=1:nb_regions
    reg_taxeC(regy) = taxMKT( whichMKT_reg_use(regy)) * 1e6 ; // ($/tCO2eq)
end
      printf("(\n      -------  Exec real past NLU for year " + (2000+current_time_im) + " with Imaclim equilibrium values \n");

// real biofuel production
Q_biofuel_real = share_biofuel .* Q(:,indice_Et);
share1G = min(divide(prod_agrofuel' , Q_biofuel_real * mtoe2ej * Exajoule2Mkcal , 1  ),1);
share2G = 1 - share1G ;

conso_auto_hyd=Tautomobile.*alphaHYDauto.*(pkmautomobileref./100);
glob_in_bioelec_Hyd_reg = conso_auto_hyd * mtoe2gj * gjh2_2_gjbiom / Exajoule2Gigajoule * Exajoule2Mkcal;
glob_in_bioelec_Hyd = sum(glob_in_bioelec_Hyd_reg);


glob_in_bioelec_Et_reg = max( Q_biofuel_real' * mtoe2ej * Exajoule2Mkcal  - prod_agrofuel, 0) * gj2G_2_gjbiom;
glob_in_bioelec_Et=sum( glob_in_bioelec_Et_reg);
glob_in_bioelec = glob_in_bioelec_Elec + sum( glob_in_bioelec_Et_reg) + glob_in_bioelec_Hyd;
reg_in_bioelec = glob_in_bioelec_Et_reg' + glob_in_bioelec_Hyd_reg + glob_in_bioelec_Elec_reg; 

if ind_debug_SC_nlu
    fileout = mopen(cur_run_output_dir+'ImaclimDrivers_'+string(current_time+1)+'.csv', "w");
    mfprintf(fileout, "wnatgas_price|%.20G",wnatgas_price);
    mfprintf(fileout, "\n");
    mfprintf(fileout, "wlightoil_price|%.20G",wlightoil_price);
    mfprintf(fileout, "\n");
    for ireg = 1:nb_regions
        mfprintf(fileout,"reg_taxeC|%s|%.20G",regnames(ireg),reg_taxeC(ireg));
        mfprintf(fileout, "\n");
    end
    for ireg = 1:nb_regions
        mfprintf(fileout,"pop|%s|%.20G",regnames(ireg),pop(ireg));
        mfprintf(fileout, "\n");
    end
    for ireg = 1:nb_regions
        mfprintf(fileout,"glob_in_bioelec_Et_reg|%s|%.20G",regnames(ireg),glob_in_bioelec_Et_reg(ireg));
        mfprintf(fileout, "\n");
    end
    mfprintf(fileout, "sum( glob_in_bioelec_Et_reg)|%.20G",sum( glob_in_bioelec_Et_reg));
    mfprintf(fileout, "\n");
    mfprintf(fileout, "glob_in_bioelec|%.20G",glob_in_bioelec);
    mfprintf(fileout, "\n");
    mclose(fileout);
end

decrease_biofuel = %t;
reduced_all2G = %f;
toomuch_bioener=%f;
real_failed=%f;

while (decrease_biofuel & ~reduced_all2G ) 
    glob_in_bioelec = glob_in_bioelec_Elec + sum( glob_in_bioelec_Et_reg) + glob_in_bioelec_Hyd;
    reg_in_bioelec = glob_in_bioelec_Et_reg' + glob_in_bioelec_Hyd_reg + glob_in_bioelec_Elec_reg; 
    try
        exec(MODEL+"landuse.iter.sce");
        //if ~isdef("Tot_bioelec_cost_del_pre")
        //    Tot_bioelec_cost_del_pre = Tot_bioelec_cost_del;
        //end
        //find_high_bioeleccosts = find( Tot_bioelec_cost_del > 5 .* Tot_bioelec_cost_del_pre);
        //if (find_high_bioeleccosts <> [] & current_time >= 89)
        //    printf("WARNING: reseting to previous value for regions with price mutliply by 5 ! \n")
        //    break_loop = %T;
        //    Tot_bioelec_cost_del( find_high_bioeleccosts) = Tot_bioelec_cost_del_pre( find_high_bioeleccosts);
        //end
    catch
        break_loop = %T;
    end
  if break_loop == %T
      real_failed=%t;
      //printf('\n      -------  NLU crashed : reducing biofuels 2G requirements \n');
      printf('\n      ------->>>>  Break loop on : real execution failed \n')
      //do_try_random=%f;
      break_loop = %F;
      fixed_nlu_startpoint = %t;
      toomuch_bioener=%t;
      if step_increase2G < sum(glob_in_bioelec_Et_reg)
          glob_in_bioelec_Et_reg = glob_in_bioelec_Et_reg - step_increase2G * divide( glob_in_bioelec_Et_reg, sum(glob_in_bioelec_Et_reg), 0) ;
      else
          glob_in_bioelec_Et_reg = zeros(1,nb_regions);
          reduced_all2G = %t;
      end
      // No reduction yet
      decrease_biofuel=%f;
  else
      decrease_biofuel=%f;
  end
end
do_try_random=%t;

if ( reduced_all2G & sum(glob_in_bioelec_Et_reg)==0)
    printf('\n          !!!!---  Reduced all 2G that was produced : Now set limits on bioelec \n');
end

// Run Oscar here, before end_time_step.sce
if ind_oscar>=1
    exec(MODEL+"nexus.oscar.sce");
end


if ~real_failed
   Tot_bioelec_cost_del_pre = Tot_bioelec_cost_del;
   exec(codes_dir+"end_time_step.sce");
   exec(MODEL+"nexus.landuse.desag.sce");
   execstr ( list_nlu_prev+"p=" + list_nlu_prev + ";");
else
   execstr ( list_nlu_prev+"=" + list_nlu_prev + "p;");
end

// create nexus land-use outputs
if (floor((current_time_im+1)/10) == ((current_time_im+1)/10)) | combi == 13
    time=timer();
    results(find(isnan(results)))=-9.9;
    global_results(find(isnan(global_results)))=-9.9;
    write_results(results,results_names,cur_run_output_dir,"simulation_result-ny"+string(current_time+1)+str_val,reg);
    write_results(global_results,global_results_names,cur_run_output_dir,"simulation_global_results",1);
    printf("\n Intermediate Number of simulation years: %current_time_im\n",current_time+1);
    printf("Results stored in: "+cur_run_output_dir+"\n");
else
    if ind_debug_SC_nlu
        suffix_type = "real";
        exec(MODEL+"nexus.landuse.writeALLresultsDEBUG.sce");
    end
end
exec(MODEL+"extraction.outputs."+ETUDEOUTPUT+".landuse.sce");

bioelec_costs_NLU_p = bioelec_costs_NLU;
bioelec_costs_NLU = Tot_bioelec_cost_del .* tep2gj;

i = current_time_prev;
verbose = 0; // 1 for debugging/coding/coupling with NLU
