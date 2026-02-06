// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


verbose = 1;

sc_ref_combi = switch_indice_in_combi(combi,[ 18] ,[ 0]); 

SAVEDIR = liste_savedir( sc_ref_combi)

strcombi = part( '00' + string(sc_ref_combi), [(length( '00' + string(sc_ref_combi))-2):length( '00' + string(sc_ref_combi))] )
driverNLU_temp = read_csv(SAVEDIR + "outputs_emf33" + strcombi + ".tsv","\t");
nb_var = size(driverNLU_temp,"r");
nb_year = size(driverNLU_temp,"c");
driverNLU = driverNLU_temp( (nb_var-51):nb_var,:);

ind_pCO2replace = [1:12];
ind_bioener2replace = [37:48];
ind_pEner2replace = [49 50];


select ind_NLU_sensit
case 1 // case we run bioenergy (6-8) scenario with prices of the no bioenergy scenario (7)
    sc_other_combi = switch_indice_in_combi(combi,[ 13 14 15 18] ,[ 0 0 0 0]);
    SAVEDIR = liste_savedir( sc_other_combi)
    strcombi = part( '00' + string(sc_other_combi), [(length( '00' + string(sc_other_combi))-2):length( '00' + string(sc_other_combi))] )
    driverNLU_temp = read_csv(SAVEDIR + "outputs_emf33" + strcombi + ".tsv","\t");
    driverNLU_temp = driverNLU_temp( (nb_var-51):nb_var,:);
    driverNLU( ind_pCO2replace,:) = driverNLU_temp( ind_pCO2replace,:);
    driverNLU( ind_pEner2replace,:) = driverNLU_temp( ind_pEner2replace,:);
case 2 // case we run the bioenergy scenario (6-8) with the qunatity of the no bioenergy scenario (7) (really low quantities)
    sc_other_combi = switch_indice_in_combi(combi,[ 13 14 15 18] ,[ 0 0 0 0]);
    SAVEDIR = liste_savedir( sc_other_combi)
    strcombi = part( '00' + string(sc_other_combi), [(length( '00' + string(sc_other_combi))-2):length( '00' + string(sc_other_combi))] )
    driverNLU_temp = read_csv(SAVEDIR + "outputs_emf33" + strcombi + ".tsv","\t");
    driverNLU_temp = driverNLU_temp( (nb_var-51):nb_var,:);
    driverNLU( ind_bioener2replace,:) = driverNLU_temp( ind_bioener2replace,:);
case 3 // case we run the nobioenergy scenario with the nofuel sc. : seems equivalent to case 1 if no other drivers
    sc_other_combi = switch_indice_in_combi(combi,[ 13 14 15 18 ] ,[ 1 0 1 0]);
    SAVEDIR = liste_savedir( sc_other_combi)
    strcombi = part( '00' + string(sc_other_combi), [(length( '00' + string(sc_other_combi))-2):length( '00' + string(sc_other_combi))] )
    driverNLU_temp = read_csv(SAVEDIR + "outputs_emf33" + strcombi + ".tsv","\t");
    driverNLU_temp = driverNLU_temp( (nb_var-51):nb_var,:);
    driverNLU( ind_bioener2replace,:) = driverNLU_temp( ind_bioener2replace,:);
end

wastooManysubs = %f;
wasError       = %f; //This one will be set to true in various error cases
//ERROR and TOOMANYSUBS MANAGEMENT IS NOT FULLY OPERATIONAL

i = 0;
current_time_im = current_time_im;
current_time = current_time_im;
//conversion factors
usd2001_2005=1/0.907;
usd2001_2010= 92.0 / 74.7; // source https://data.oecd.org/price/inflation-cpi.htm 25-10-2019
usd_year1_year2 = usd2001_2010;

Mtoe_EJ=0.041868;
nbLines = 538;
nbLines_NLU_driver = 12*4 + 4; // will be only in full outputs
nbvar_NLU_driver = 8;
//annees 2001-2005-2010-2020 etc
if current_time_im==0
    outputs_temp=zeros(nbLines*(reg+1)+ nbLines_NLU_driver,TimeHorizon+1);
    list_output_str = list();
    list_output_comments = list();
    list_output_unit = list();
end
exec(MODEL+"extraction."+ETUDEOUTPUT+".init.sce");
i = 1;
exec("store_prev.sce");
exec('dynamic.sce');
energy_balance = ones(energy_balance);


for current_time=0:(nb_year-2)
    current_time_im = current_time+1;
    printf('\n      -------  Doing year ' + string(current_time+1) + '\n')
    verbose = 1;
    if break_loop == %t;
        fixed_nlu_startpoint = %t; // if crashes, do not impulse wrong dynamic on nlu drivers
        break_loop = %f;
    end
    // force drivers
    reg_taxeC =  evstr(driverNLU( 1:12, current_time+1))' ;
    pop = evstr(driverNLU( 25:36, current_time+1))' ;
    reg_in_bioelec = evstr(driverNLU( 37:48, current_time+1)) ;
    wlightoil_price = evstr(driverNLU( 49, current_time+1)) ;
    wnatgas_price = evstr(driverNLU( 50, current_time+1)) ;
    exec(codes_dir+"update_forcings.sce");
    // execute nlu timestep
    exec(MODEL+"landuse.iter.sce");
    exec(codes_dir+"end_time_step.sce");
    // create nexus land-use outputs; each year because it bugs
    if %t // (floor((current_time+1)/10) == ((current_time+1)/10))
        time=timer();
        results(find(isnan(results)))=-9.9;
        global_results(find(isnan(global_results)))=-9.9;
        write_results(results,results_names,cur_run_output_dir,"simulation_result-ny"+string(current_time+1)+str_val,reg);
        write_results(global_results,global_results_names,cur_run_output_dir,"simulation_global_results",1);
        printf("\n Intermediate Number of simulation years: %current_time_im\n",current_time+1);
        printf("Results stored in: "+cur_run_output_dir+"\n");
    end
    // normal outputs
    current_time_im = current_time_im;
    if current_time_im>0
        bioener_costs_Farmgate = Tot_bioelec_cost;
        bioener_costs_Del = Tot_bioelec_cost_del;
        w_bioener_costs_Farmgate = W_tot_bioelec_cost ;
        w_bioener_costs_Del = W_tot_bioelec_cost_del ;
        bioener_costs_NLU = %nan * bioener_costs_NLU;
        current_time_im=current_time_im-1;
        exec('extraction.outputs.emf33.sce');
        //current_time=current_time-1;
        exec('extraction.outputs.emf33.landuse.sce');
    end
end

execstr("outputs_"+ETUDE+"=csvRead("""+SAVEDIR+"outputs_"+ETUDE+fit_combi(combi)+".csv"",""|"",[],[],[],""/\/\//"");");
yearlySmoothOutputs= customSmooth(evstr("outputs_"+ETUDE));
yearlyOutputs= evstr("outputs_"+ETUDE);

if do_smooth_outputs==%t
    execstr("sel_outputs_"+ETUDEOUTPUT+" = yearlySmoothOutputs(:, year_to_select)");
else
    execstr("sel_outputs_"+ETUDEOUTPUT+" = yearlyOutputs(1:(13*nbLines), year_to_select)");
end
mkcsv("sel_outputs_"+ETUDE);
mkcsv("sel_outputs_"+ETUDE,OUTPUT);

