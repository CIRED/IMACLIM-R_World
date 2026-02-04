

//meant to be executed after nexus.electricity.idealPark.sce and before nexus.electricity.realInvestment.sce and nexus.et.sce

if %f //current_time >= 84
   do_try_random=%f;
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Compute the real timestep of last NLU with updated value from the Imaclim static
///////////////////////////////////////
verbose = 1; // 1 for debugging/coding/coupling with NLU


share_biofuel_prev = share_biofuel;

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Compute anticipation for the next timestep
///////////////////////////////////////
current_time = current_time_im ;
pop = Ltot';  
exec(codes_dir+"update_forcings.sce");
i = current_time; 
build_et_curve_NLU = %t ;

// Linear Expectations on carbon tax increase
txp = taxCO2_CI_prev(1,1,:);
txn = taxCO2_CI(1,1,:);
txp = taxCO2_DF_prev(:,indice_gaz);
txn = taxCO2_DF(:,indice_gaz);

for regy=1:nb_regions
    reg_taxeC(regy) = max( 2*txn(regy) -txp(regy),txp(regy)) * 1e6 ; // ($/tCO2eq)
end

// Afforestation module
if ind_aff >= 1 & ind_NLU_sensit==0
  exec(MODEL+"nexus.afforestation.sce");
end


// ancitipated productionqBiomExaJ
if ~isdef('qBiomExaJ')
	qBiomExaJ = zeros(nb_regions,1);
end
if ~isdef('Q_biofuel_anticip')
	Q_biofuel_anticip = zeros(nb_regions,1);
end
//prod_cellul_bioener = sum(qBiomExaJ,"c").*Exajoule2Mkcal; 


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Timestep of Nexus Land-Use///
///////////////////////////////
if ind_NLU_bioener == 0   // imaclim gives biofuel production to NLU exogeneously
     printf("We use " + biofuel_scenario + " exo. scenario");
//    prod_agrofuel = Q_biofuel_anticip' * mtoe2ej * Exajoule2Mkcal;
//    prod_agrofuel = zeros(1,nb_regions);
else // nlu calculate biofuel production for imaclim
     printf("We use " + biofuel_scenario + " exo. scenario");
//    producer_lightoil_price = p_Et_oil_exp_tax_ethan ./ (tep2gj) ;
    //pcal_eq_agrofuel = (producer_lightoil_price' ./ (G2M .* Megajoule2Mkcal) - ethanol_transfo_cost ./ (density_ethanol .* LHV_ethanol .* Megajoule2Mkcal))  ./ (LHV_sugar ./ (LHV_ethanol .* stechiom_ferment_sugar));
     //[dsurfagri_s,importsveg_s, importsrumi_s, density_Dyn_new_s, prod_agrofuel_s, prod_agrofuel_max_s, loc_other_agrof_prod_s]=wdsalimener(pcal_eq_agrofuel, pchi, coutfixeint, prod_agrofuel, jint_prev, jint_smooth_from_dc, density_agri, density_veg_from_dc, density_ML_from_dc, density_P_from_dc, density_ot_in_crops_clb, exportsveg,exportsrumi, surfagri, importsrumi, importsveg, %T);
     //prod_agrofuel = prod_agrofuel_max_s;
end


//va_costs = w .* l .* (1+ sigma) .* (energ_sec + FCC .*non_energ_sec) + markup.*FCCmarkup_oil.*p.*(energ_sec + non_energ_sec) ;
//va_costs_et = va_costs(:,et) ;


select ethan2G_transf_cost_scen
case "LinearDecrease"
    //ethan2G_transfo_cost = ethan2G_transfocost_2000 - (current_time+1) /  51 * (ethan2G_transfocost_2000 - ethan2G_transfocost_2050) ;
    //ethan2G_transfo_cost = max( ethan2G_transfo_cost, ethan2G_transfocost_2050) ;
    ethan2G_inv = Hoowijk_inv_2000 - (current_time+1) /  51 * ( Hoowijk_inv_2000 - Hoowijk_inv_2050);
    ethan2G_inv = max( ethan2G_inv, Hoowijk_inv_2050);
case "Constant"
    //ethan2G_transfo_cost = ethan2G_transfocost_2000;
    ethan2G_inv = Hoowijk_inv_2000;
else
    warning(' ethan2G_transf_cost_scen is ill-defined');
end
ethan2G_transfo_cost = 1 / ethan2G_efficiency / Hoowijk_2000_load * ( ethan2G_inv / Hoowijk_2000_lifetime + Hoowijk_2000_OM_percent * ethan2G_inv) / kW2gj * tep2gj ; // $/tep

//wp_lightoil_target = sum(p_Et_oil_exp_tax_ethan .* (1+xtax(:,et)) .* Exp(:,et) ) ./ sum( Exp(:,et)) ;
if ind_cellulosicFuels == 2
    ethan2G_transfo_cost = ethan2G_transfo_cost * 2;
end


//first run without 2G
//Cap_oil_anticip_NLU = max( Q(:,indice_oil) .* taux_Q_nexus(:,indice_oil) /0.8 , 0 ) ;
//Cap_oil_anticip_NLU = max( K_expected(:,indice_oil) , 0 ) ;

if ~isdef("glob_in_bioelec_Et")
    glob_in_bioelec_Et = 0; 
    glob_in_bioelec_Et_reg = zeros(1,nb_regions); 
    glob_in_bioelec_Et_prev = glob_in_bioelec_Et ; 
else
    glob_in_bioelec_Et = glob_in_bioelec_Et_prev;
end

// biomass requirements for hydrogen 
conso_auto_hyd=Tautomobile.*alphaHYDauto.*(pkmautomobileref./100);
if ~is_bau
    emi_evitee_hdr = conso_auto_hyd .* mtoe2gj .* h2_gaseif_emission;  // tCO2
    emi_evitee_hdr_Tauto = alphaHYDauto.*(pkmautomobileref./100) .* mtoe2gj .* h2_gaseif_emission / 1e6;
else
    emi_evitee_hdr = 0 * conso_auto_hyd ;  // tCO2
    emi_evitee_hdr_Tauto = 0 * alphaHYDauto;
end
emi_evitee = emi_evitee + emi_evitee_hdr;
glob_in_bioelec_Hydprev = glob_in_bioelec_Hyd;
glob_in_bioelec_Hyd_reg = conso_auto_hyd * mtoe2gj * gjh2_2_gjbiom / Exajoule2Gigajoule * Exajoule2Mkcal;
glob_in_bioelec_Hyd = sum(glob_in_bioelec_Hyd_reg);

// Note : Priority is given to hydrogen and bioelec

// biomass requirement for bioelec
glob_in_bioelec_Elecprev = glob_in_bioelec_Elec;
glob_in_bioelec_Elec_reg =  sum(qBiomExaJ,"c").*Exajoule2Mkcal;
glob_in_bioelec_Elec = sum( glob_in_bioelec_Elec_reg);
//glob_in_bioelec_Et_init  = sum(Q_biofuel_anticip * mtoe2ej * Exajoule2Mkcal ) - sum(prod_agrofuel );
surplus_bioelec_Elec = max( glob_in_bioelec_Elec - glob_in_bioelec_Elecprev + glob_in_bioelec_Hyd - glob_in_bioelec_Hydprev,0);

glob_in_bioelec_Et_reg = glob_in_bioelec_Et_reg - surplus_bioelec_Elec * divide( glob_in_bioelec_Et_reg, sum(glob_in_bioelec_Et_reg), 0) ;
glob_in_bioelec_Et_reg = max( glob_in_bioelec_Et_reg, 0);
glob_in_bioelec_Et = sum(glob_in_bioelec_Et_reg);
glob_in_bioelec = glob_in_bioelec_Elec + glob_in_bioelec_Et + glob_in_bioelec_Hyd;

//disp("glob_in_bioelec_Hyd")
//disp(glob_in_bioelec_Hyd)
//disp("alphaHYDauto")
//disp(alphaHYDauto)

//disp("glob_in_bioelec_Hyd/glob_in_bioelec")
//disp(divide(glob_in_bioelec_Hyd,glob_in_bioelec,0))
reg_in_bioelec = glob_in_bioelec_Et_reg' + glob_in_bioelec_Hyd_reg + glob_in_bioelec_Elec_reg; 

//disp("glob_in_bioelec_Hyd/glob_in_bioelec")
//disp(divide(glob_in_bioelec_Hyd_reg,reg_in_bioelec,0))


// Note : the limit is on biofuels. if bioelec and hydrogen exceed the limit
if (combi == 9) | (combi == 16) | (combi == 23) 
    // first limit biofuels
    glob_in_bioelec_Et = max( min( glob_in_bioelec_Et, 100 * Exajoule2Mkcal - glob_in_bioelec_Elec - glob_in_bioelec_Hyd), 0);
    glob_in_bioelec_Et_reg = divide( glob_in_bioelec_Et_reg, sum(glob_in_bioelec_Et_reg), 0) .* glob_in_bioelec_Et ; 
    glob_in_bioelec = glob_in_bioelec_Elec + glob_in_bioelec_Et + glob_in_bioelec_Hyd;
    reg_in_bioelec = glob_in_bioelec_Et_reg' + glob_in_bioelec_Hyd_reg + glob_in_bioelec_Elec_reg;
    if glob_in_bioelec == 100 * Exajoule2Mkcal
        limit_on_bioelec = %t;
        limit_on_2G = %t;
    end
end


if ~real_failed
printf('\n      -------  building cost curves with NLU : first try with past 2G production \n')

stop_increase_2G = %f;
try

    exec(MODEL+"landuse.iter.sce");


        //if ~isdef("Tot_bioelec_cost_del_pre")
        //    Tot_bioelec_cost_del_pre = Tot_bioelec_cost_del;
        //end
        //find_high_bioeleccosts = find( Tot_bioelec_cost_del > 5 .* Tot_bioelec_cost_del_pre);
        //if (find_high_bioeleccosts <> [] & current_time >= 89)
        //    printf("WARNING: reseting to previous value for regions with price mutliply by 5 ! \n")
        //    break_loop = %T;
        //    Tot_bioelec_cost_del_pre( find_high_bioeleccosts) = Tot_bioelec_cost_del( find_high_bioeleccosts);
        //end

        // Compute an elasticity
        Tot_bioelec_cost_delp0 = Tot_bioelec_cost_del;
        Qbiofuel_NLU_p0 = (glob_in_bioelec_Et_reg/ gj2G_2_gjbiom)' / mtoe2ej / Exajoule2Mkcal;
        biomass_demand_cost = Tot_bioelec_cost_delp0;
        biomass_demand_quant = Qbiofuel_NLU_p0;
        //
        bioener_costs_NLU_diff = profitable_2G .*(p(:,et)+(coef_Q_CO2_ref(:,indice_Et)-coef_Q_CO2_ethan).* expectedTaxEtDF - biofuel_costs_NLU );
        key_repart_Qbiofuel= divide( bioener_costs_NLU_diff, sum(bioener_costs_NLU_diff), 0);
        //glob_in_bioelec_Et = glob_in_bioelec_Et + step_increase2G;
        //glob_in_bioelec_Et_reg = glob_in_bioelec_Et_reg + key_repart_Qbiofuel' .*step_increase2G;
        Qbiofuel_NLU = ( prod_agrofuel + (glob_in_bioelec_Et_reg + key_repart_Qbiofuel' .*step_increase2G)/ gj2G_2_gjbiom)' / mtoe2ej / Exajoule2Mkcal;
        reg_in_bioelec = (glob_in_bioelec_Et_reg' + glob_in_bioelec_Hyd_reg + glob_in_bioelec_Elec_reg) +  key_repart_Qbiofuel .*step_increase2G;
        exec(MODEL+"landuse.iter.sce");
        // store results
        [biomass_demand_cost, biomass_demand_quant] = add_to_supplycurve(biomass_demand_cost, biomass_demand_quant, Tot_bioelec_cost_del, Qbiofuel_NLU);
        // compute elasticities
        if current_time >1
          elast_biofuel = build_SC2G_elast( biomass_demand_cost, biomass_demand_quant, linspace(0,100,101) /gj2G_2_gjbiom/mtoe2ej);
        end
        // restore values
        Qbiofuel_NLU = Qbiofuel_NLU_p0;
        Tot_bioelec_cost_del = Tot_bioelec_cost_delp0;

catch
    fixed_nlu_startpoint = %t;
    stop_increase_2G = %t;
    printf('\n      ------->>>>  Quantity limit reach : Nlu crashed \n')
end // try
if ind_debug_SC_nlu == %t
    suffix_type = "1stTry";
    exec(MODEL+"nexus.landuse.writeALLresultsDEBUG.sce");
end

if break_loop == %T
      printf('\n      ------->>>>  Break loop on : first try failed \n')
      break_loop = %F;
      fixed_nlu_startpoint = %t;
      stop_increase_2G = %t;
else
   bioener_costs_Farmgate = Tot_bioelec_cost;
   bioener_costs_Del = Tot_bioelec_cost_del;
   w_bioener_costs_Farmgate = W_tot_bioelec_cost ;
   w_bioener_costs_Del = W_tot_bioelec_cost_del ;
   bioener_costs_NLU = pind .* ethan2G_transfo_cost + Tot_bioelec_cost_del .* tep2gj * gj2G_2_gjbiom;
   // todo : proper value of 1G costs
   biofuel1G_costs_NLU  = bioener_costs_NLU; 
   profitable_2G = (p(:,et)+(coef_Q_CO2_ref(:,indice_Et)-coef_Q_CO2_ethan).* expectedTaxEtDF - biofuel_costs_NLU ) > 0 ;
   bioener_costs_NLU_diff = profitable_2G .*(p(:,et)+(coef_Q_CO2_ref(:,indice_Et)-coef_Q_CO2_ethan).* expectedTaxEtDF - biofuel_costs_NLU );
   key_repart_Qbiofuel= divide( bioener_costs_NLU_diff, sum(bioener_costs_NLU_diff), 0);
   Qbiofuel_NLU = ( prod_agrofuel + key_repart_Qbiofuel' .*glob_in_bioelec_Et / gj2G_2_gjbiom)' / mtoe2ej / Exajoule2Mkcal;

   share1G = divide(prod_agrofuel' , Qbiofuel_NLU * mtoe2ej * Exajoule2Mkcal , 1  );
   share2G = 1 - share1G ;
   biofuel_costs_NLU = share1G .* biofuel1G_costs_NLU + share2G .* bioener_costs_NLU ;
end
else
    stop_increase_2G = %t;
end

wp_lightoil_comp = sum( bioener_costs_NLU .* Q(:,et) ) ./ sum( Q(:,et)) ;


overshoot_wplightoil_ant = 1 ;
exec(MODEL+"nexus.Et.coststruct.sce");
//Cap_Et_NLU = max( Q_Et_anticip/0.8 , 0 ) ;
//wp_lightoil_target = compute_wp_Et( Cap_Et_NLU, Cap_oil_anticip_NLU);
wp_et_exp_anticip_nlu = sum(p_et_anticip_reg.*Exp(:,indice_Et))./sum(Exp(:,indice_Et));
if wp_et_biom_forsight == "forwardlooking"
    wp_lightoil_target =  compute_wp_Et();
else
    wp_lightoil_target =  wp_et_exp_anticip_nlu;//wp(indice_Et);
end
printf('               world price computed is : ' + string( wp_lightoil_comp) + ' $/tep   -   ref is ' + string( wp_lightoil_target) + '   -   past is ' + string( wp(indice_Et)) + '\n');

// producers take into account their wrong expectation about oil price increase due to scarcity, and correct
if biofeulProdExp_improved
   overshoot_wplightoil_ant = wp(indice_Et) ./ wp_lightoil_target; 
   overshoot_wplightoil_ant = max( overshoot_wplightoil_ant, 1);
end

// supply curve if profitable

profitable_2G = (p(:,et)+(coef_Q_CO2_ref(:,indice_Et)-coef_Q_CO2_ethan).* expectedTaxEtDF - biofuel_costs_NLU ) > 0 ;
surfacefor2G = ( max(yield_on_pot_scaled) <= 0.98) ;
surfacefor2G_glob = (surfP / (surfML+surfP) >= 0.05) ;
do_increase2G = profitable_2G  & max_biofuel;
do_increase2G_glob = ( sum( do_increase2G) * surfacefor2G_glob <> 0 ) & surfacefor2G;

do_cellulosicFuel = ~((ind_cellulosicFuels==0)|(ind_cellulosicFuels==3&current_time_im<50)|stop_increase_2G);

if combi <13
    nb_itery = -1000;
    //nb_itery = -15;
elseif combi > 6000
    nb_itery = -75;
else
    nb_itery = -5;
end

glob_in_bioelec_Et_reg_0 = glob_in_bioelec_Et_reg;
glob_increase2G = 0;
if (wp_lightoil_comp < wp_lightoil_target) & do_cellulosicFuel
    while (nb_itery<1) & (wp_lightoil_comp < wp_lightoil_target) & do_increase2G_glob & (break_loop == %F) & (~stop_increase_2G)
    nb_itery = nb_itery+1;

    try
        glob_in_bioelec_Et_reg_s = glob_in_bioelec_Et_reg;
        key_repart_Qbiofuel_sav = key_repart_Qbiofuel;
        //Qbiofuel_NLU = (prod_agrofuel + glob_in_bioelec_Et .* (bioener_costs_NLU)' / sum(bioener_costs_NLU)  )' / mtoe2ej / Exajoule2Mkcal;
        bioener_costs_NLU_diff = profitable_2G .*(p(:,et)+(coef_Q_CO2_ref(:,indice_Et)-coef_Q_CO2_ethan).* expectedTaxEtDF - biofuel_costs_NLU );
        glob_increase2G = glob_increase2G + step_increase2G;
        glob_in_bioelec_Et = glob_in_bioelec_Et + step_increase2G;
        // taking into account price elasticity to compute key_repart_Qbiofuel
        old_key = key_repart_Qbiofuel;
        [key_repart_Qbiofuel,v,info]= fsolve( key_repart_Qbiofuel,fixedpoint_keyBiofuel);
        if info~=1
           error("[key_repart_Qbiofuel,v,info]= fsolve( key_repart_Qbiofuel,fixedpoint_keyBiofuel);");
        end
        glob_in_bioelec_Et_reg = glob_in_bioelec_Et_reg_0 + key_repart_Qbiofuel' .* glob_increase2G;
        Qbiofuel_NLU = ( prod_agrofuel + glob_in_bioelec_Et_reg / gj2G_2_gjbiom)' / mtoe2ej / Exajoule2Mkcal;
        // anticipated price for refined oil
        exec(MODEL+"nexus.Et.coststruct.sce");
        //Cap_Et_NLU = max( Q_Et_anticip/0.8 , 0 ) ; 
        if wp_et_biom_forsight == "forwardlooking"
            wp_lightoil_target =  compute_wp_Et();
        else
            wp_lightoil_target =  wp_et_exp_anticip_nlu; //wp(indice_Et);
        end
        glob_in_bioelec = glob_in_bioelec_Elec + glob_in_bioelec_Et + glob_in_bioelec_Hyd;
        reg_in_bioelec = glob_in_bioelec_Et_reg' + glob_in_bioelec_Hyd_reg + glob_in_bioelec_Elec_reg; 
        printf('\n      -------  building cost curves with NLU : trying ' + string( glob_in_bioelec_Et) + ' of 2G Mkcal \n')
        exec(MODEL+"landuse.iter.sce");
        if ind_debug_SC_nlu == %t
            suffix_type = "SupplCurv";
            exec(MODEL+"nexus.landuse.writeALLresultsDEBUG.sce");
        end
        //if ~isdef("Tot_bioelec_cost_del_pre")
        //    Tot_bioelec_cost_del_pre = Tot_bioelec_cost_del;
        //end
        //find_high_bioeleccosts = find( Tot_bioelec_cost_del > 5 .* Tot_bioelec_cost_del_pre);
        //if (find_high_bioeleccosts <> [] & current_time >= 89)
        //    printf("WARNING: reseting to previous value for regions with price mutliply by 5 ! \n")
        //    break_loop = %T;
        //    Tot_bioelec_cost_del_pre( find_high_bioeleccosts) = Tot_bioelec_cost_del( find_high_bioeleccosts);
        //end
        if break_loop == %T
            printf('\n      ------->>>>  Break loop on : cost curve failed at this point \n')
            break_loop = %F;
            stop_increase_2G = %t;
            fixed_nlu_startpoint = %t;
            glob_in_bioelec_Et_reg = glob_in_bioelec_Et_reg_s;
            glob_in_bioelec_Et = sum(glob_in_bioelec_Et_reg);
            key_repart_Qbiofuel = key_repart_Qbiofuel_sav;
        else
            bioener_costs_Farmgate = Tot_bioelec_cost;
            bioener_costs_Del = Tot_bioelec_cost_del;
            w_bioener_costs_Farmgate = W_tot_bioelec_cost ;
            w_bioener_costs_Del = W_tot_bioelec_cost_del ;
            bioener_costs_NLU = pind .* ethan2G_transfo_cost + Tot_bioelec_cost_del .* tep2gj * gj2G_2_gjbiom;
            // todo : proper balue of 1G costs
            biofuel1G_costs_NLU  = bioener_costs_NLU;
            profitable_2G = (p(:,et)+(coef_Q_CO2_ref(:,indice_Et)-coef_Q_CO2_ethan).* expectedTaxEtDF - biofuel_costs_NLU ) > 0 ;
            bioener_costs_NLU_diff = profitable_2G .*(p(:,et)+(coef_Q_CO2_ref(:,indice_Et)-coef_Q_CO2_ethan).* expectedTaxEtDF - biofuel_costs_NLU );
            key_repart_Qbiofuel= divide( bioener_costs_NLU_diff, sum(bioener_costs_NLU_diff), 0);
            //Qbiofuel_NLU = ( prod_agrofuel + key_repart_Qbiofuel' .*glob_in_bioelec_Et / gj2G_2_gjbiom)' / mtoe2ej / Exajoule2Mkcal;
            share1G = divide(prod_agrofuel' , Qbiofuel_NLU * mtoe2ej * Exajoule2Mkcal , 1  );
            share2G = 1 - share1G ;
            biofuel_costs_NLU = share1G .* biofuel1G_costs_NLU + share2G .* bioener_costs_NLU ;
            // profitable 2G
            surfacefor2G = ( max(yield_on_pot_scaled) <= 0.98) ;
            surfacefor2G_glob = (surfP / (surfML+surfP) >= 0.05) ;
            [biomass_demand_cost, biomass_demand_quant] = add_to_supplycurve(biomass_demand_cost, biomass_demand_quant, Tot_bioelec_cost_del, Qbiofuel_NLU);
        end
        //Qbiofuel_NLU = ( prod_agrofuel + key_repart_Qbiofuel' .*glob_in_bioelec_Et / gj2G_2_gjbiom)' / mtoe2ej / Exajoule2Mkcal;
        share1G = divide(prod_agrofuel' , Qbiofuel_NLU * mtoe2ej * Exajoule2Mkcal , 1  );
        share2G = 1 - share1G ;
        biofuel_costs_NLU = share1G .* biofuel1G_costs_NLU + share2G .* bioener_costs_NLU ;
        // profitable 2G
        profitable_2G = (p(:,et)+(coef_Q_CO2_ref(:,indice_Et)-coef_Q_CO2_ethan).* expectedTaxEtDF - biofuel_costs_NLU ) > 0 ;
        do_increase2G = profitable_2G  & max_biofuel;
        do_increase2G_glob = ( sum( do_increase2G) * surfacefor2G_glob <> 0 ) & surfacefor2G;
        
        wp_lightoil_comp = sum( bioener_costs_NLU .* Q(:,et) ) ./ sum( Q(:,et)) ;
        printf('               world price computed is : ' + string( wp_lightoil_comp) + ' $/tep   -   ref is ' + string( wp_lightoil_target) + '   -   past is ' + string( wp(indice_Et)) + '\n');
    catch
        stop_increase_2G = %t;
        printf('\n      ------->>>>  Quantity limit reach : Nlu crashed \n')
        fixed_nlu_startpoint = %t;
    end // try
    end // while
end // if

// fixed point to be more accurate:
if (wp_lightoil_comp > wp_lightoil_target) & do_increase2G_glob & (break_loop == %F) & (~stop_increase_2G)
    [glob_increase2G,v,info]= fsolve( glob_increase2G, fixedpoint_glob_2G);
    // in fix point
    glob_in_bioelec_Et_reg = glob_in_bioelec_Et_reg_0 + key_repart_Qbiofuel' .* glob_increase2G;
    Qbiofuel_NLU = ( prod_agrofuel + glob_in_bioelec_Et_reg / gj2G_2_gjbiom)' / mtoe2ej / Exajoule2Mkcal;
    exec(MODEL+"nexus.Et.coststruct.sce");
    //Cap_Et_NLU = max( Q_Et_anticip/0.8 , 0 ) ; 
    if wp_et_biom_forsight == "forwardlooking"
        wp_lightoil_target =  compute_wp_Et();
    else
        wp_lightoil_target =  wp_et_exp_anticip_nlu; //wp(indice_Et);
    end
    printf('\n      -------  last execution of NLU for accuracy\n');
        glob_in_bioelec = glob_in_bioelec_Elec + glob_in_bioelec_Et + glob_in_bioelec_Hyd;
        reg_in_bioelec = glob_in_bioelec_Et_reg' + glob_in_bioelec_Hyd_reg + glob_in_bioelec_Elec_reg;
        exec(MODEL+"landuse.iter.sce");
        if ind_debug_SC_nlu == %t
            suffix_type = "SupplCurv";
            exec(MODEL+"nexus.landuse.writeALLresultsDEBUG.sce");
        end
        bioener_costs_Farmgate = Tot_bioelec_cost;
        bioener_costs_Del = Tot_bioelec_cost_del;
        w_bioener_costs_Farmgate = W_tot_bioelec_cost ;
        w_bioener_costs_Del = W_tot_bioelec_cost_del ;
        bioener_costs_NLU = pind .* ethan2G_transfo_cost + Tot_bioelec_cost_del .* tep2gj * gj2G_2_gjbiom;
        //biofuel1G_costs_NLU  = bioener_costs_NLU;
        //share1G = divide(prod_agrofuel' , Qbiofuel_NLU * mtoe2ej * Exajoule2Mkcal , 1  );
        //share2G = 1 - share1G ;
        //biofuel_costs_NLU = share1G .* biofuel1G_costs_NLU + share2G .* bioener_costs_NLU ;
        //Qbiofuel_NLU = ( prod_agrofuel + key_repart_Qbiofuel' .*glob_in_bioelec_Et / gj2G_2_gjbiom)' / mtoe2ej / Exajoule2Mkcal;
        //share1G = divide(prod_agrofuel' , Qbiofuel_NLU * mtoe2ej * Exajoule2Mkcal , 1  );
        //share2G = 1 - share1G ;
        //biofuel_costs_NLU = share1G .* biofuel1G_costs_NLU + share2G .* bioener_costs_NLU ;
        wp_lightoil_comp = sum( bioener_costs_NLU .* Q(:,et) ) ./ sum( Q(:,et)) ;
        printf('               world price computed is : ' + string( wp_lightoil_comp) + ' $/tep   -   ref is ' + string( wp_lightoil_target) + '   -   past is ' + string( wp(indice_Et)) + '\n');
end // fixed point to be more accurate

if (wp_lightoil_comp < wp_lightoil_target)
    printf('\n      ------->>>>  price target reached \n')
end
if sum( profitable_2G) == 0
    printf('\n      ------->>>> profitability limit reached for all regions \n')
end
if sum( surfacefor2G) == 0
    printf('\n      ------->>>> yield_on_pot_scaled limit reached for all regions \n')
end
if ~surfacefor2G_glob
    printf('\n      ------->>>> surface limit globally reached \n')
    disp( yield_on_pot_scaled, "yield_on_pot_scaled") ;
    disp( surfP / (surfML+surfP), "surfP / (surfML+surfP)");
end
share1G = divide(prod_agrofuel' , Qbiofuel_NLU * mtoe2ej * Exajoule2Mkcal , 1  );
share2G = 1 - share1G ;

glob_in_bioelec_Et_prev = glob_in_bioelec_Et ; 


// shitty endings
current_time_im = current_time; 
verbose = 0;  // back to 0 (for debugging/coding/coupling with NLU)
build_et_curve_NLU = %f ;

  if break_loop == %T
      warning('break_loop is on in nexus land-use, a problem occured');
      break_loop = %F;
  end

do_try_random=%t;

if ind_aff >=1 & ind_NLU_sensit==0
    surf_aff_considered=surf_aff_2_increase;
end

