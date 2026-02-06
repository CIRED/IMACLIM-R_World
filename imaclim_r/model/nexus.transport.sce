// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thomas Le Gallic
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////// Dynamics of the transportation nexus ///////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

// The transport nexus determines the evolution over time of the static equilibrium parameters that govern the dynamics of demand for passenger and freight transport. The changes concern the energy consumption parameters of the modes of transport by source (efficiency and fuel switching); but also non-energy parameters that will influence mobility. The latter mainly include parameters that influence the average speed of modes of transport, which will influence modal choices and total distances travelled. 

// The modes represented are:
// - for passenger transport: the car (or LDV for light-duty vehicle), collective land transport (broken down into rail and road for the evolution of the parameters and in the output variables, but not in the utility function), air transport (broken down into domestic and international in the outputs) ;
// - for freight: sea transport, air transport (decomposable into domestic and international in the outputs), road transport and rail transport. These last two modes have different dynamics in this nexus, and different outputs, but are represented by a single economic sector in the input-output matrix. This sector also includes public passenger transport.

// The representation of the processes is more or less complex depending on the mode, ranging from the very simple and exogenous (for air transport and shipping) to fairly sophisticated representations (more dependent on prices or policies).

// The code is organised by mode:
// I. 	Cars / Light-Duty Vehicles (LDV)
// II. 	Other terrestrial transport (rail freight, rail passenger, road freight, road passenger)
// III.	Aviation
// IV. 	Shipping
// V. 	Cross mode section


// Suggestions for improvement include (in subjective order of priority):
// - a recalibration of the whole dynamics driving demand for passenger transportation by mode, as we observe a decrease in cars passenger kilometers in low-income regions in the first decades, and should project more plausible trends
// - shift from exogenous trends to endogenous processes where needed (in order to avoid e.g. free energy efficiency improvements)
// - further embedding the nexus in the macroeconomic dynamics (especially: taking into account vehicle purchase?)
// - improving the link between investment in infrastructures, mobility demand, modal choices, well-being. 

// Notes from a previous version: 
// In the current version, there is energy efficiency improvement reducing liquid fuel use in OT (endogenous, induced by prices) and in air (exogenous)
// Since there is an asymptote on energy efficiency improvement, OT and air cannot be fully decarbonized (unless liquid fuel production is totally from biomass)
// There is no electrification possiblities or trends (unitary electricity use for OT and air is constant, equal to its calibration value in all region CI(elec, OT/air,:)
// A priority improvement to allow scenarios of full decarbonation could be to add electrification possibilities and/or hydrogen possibilities
// Also there is no change of energy uses from maritime transport in this file (that represents only transport modes where passengers are an important part of the sector), and apparently not elsewhere either, so CI(*energies*, indice_mer,:) is constant over time. Something to improve in next developments.




//--------------------------------------------------------------------//
// I. Cars / Light-Duty Vehicles (LDV) section                        //
//--------------------------------------------------------------------//


//_____________________________________________________________________
// I.a. Change in vehicle fleet 

// Motorization rate per capita increases proportionnally to income per capita see modele WBCSD/AIE fichier smp-model-spreadsheet_data_imaclim.xls. Taking as a basis WBCSD/AIE (see fichier smp-model-spreadsheet_data_imaclim.xls)
realGDPpc = GDP_MER_real./Ltot_prev;
deltaGDPpc = realGDPpc - GDP_MER_real_prev./Ltot_prev ;

income_growth_multiplier = interpln (inc_grwth_mult_A, realGDPpc *1d3 )';
income_growth_multiplier = income_growth_multiplier.*igm_cff;

// Updating prev values
nb_car_prev=nb_car;
nb_car_pc_prev=nb_car_pc;

// Increasing stock
nb_car_pc=nb_car_pc_prev+ income_growth_multiplier.* deltaGDPpc;
nb_car=nb_car_pc.*Ltot;
stockautomobile = nb_car./nombreautomobileref .* stockautomobileref;


//_____________________________________________________________________
// I.b. Changes in basic needs for cars 

// They follow the evolution in pkm by car (sort of lock-in or habituation). NB: by default basic needs remain equal to zero for other modes.
if ind_newBN == 0
    bnautomobile = bnauto_dependancy_trends .* Tautomobile;
else
    bnautomobile = max(bnauto_dependancy_trends .* Tautomobile,bnautomobileref);
end


//_____________________________________________________________________
// I.c. Efficiency improvement and fuel switching (including energy-service efficiency, i.e. occupancy rate)

// Energy-service efficiency improvement: variant to increase the occupancy rate (around +40% in 2050)
if ind_transportsufficiency >= 1 & current_time_im >= start_year_strong_policy-base_year_simulation 
    if current_time_im <= 2050-base_year_simulation 
        tauxderemplissageauto = 1.01 * tauxderemplissageauto;
    else
        tauxderemplissageauto = 1.002 * tauxderemplissageauto; // We lower the increase of this ratio after 2050
    end
end

// Technical efficiency and fuel switching: a specific nexus is dedicated to the changes in technical efficiency for cars (used by default)
if NEXUS_automobile_techno==1
    exec(MODEL+'nexus.cars.sce');
else
    alphaEtauto=min(alphaEtautoref.*((pArmDF_nexus(:,indice_Et))./pArmDFref(:,indice_Et)).^elast_auto_Et,alphaEtauto);
    //technical asymptote
    alphaEtauto=max(alphaEtauto,alphaEtautoref.*asympt_alphaEtauto);
    //no going back
    alphaEtauto=min(alphaEtauto,alphaEtauto_prev);
    //maximum bound on improvement rate
    alphaEtauto=max(alphaEtauto,alphaEtauto_prev*0.97);
    //inertia
    alphaEtauto=2/3*alphaEtauto+1/3*alphaEtauto_prev;
end


//_____________________________________________________________________ 
// I.d. Evolution in road transport capacities for cars: capacities follow the increase in the vehicle stock by default, as the objective is to avoid congestion (i.e. the utilization rate remains constant). 

URtransport(:,ind_hsld_transpCar) = pkmautomobileref./(100*ones(reg,1)).*Tautomobile./Captransport(:,ind_hsld_transpCar); // UR = utilization rate of transport capacities (in pkm/Capacicites)

if ETC_infra_pass == 0 // Name of the infrastructure policies option. "ETC" seems to stand for European Topic Centre, European Travel Commission or Energy Transition Commission, who led (or leads) an initiative on a transition in the transportation sector (in Europe). 
    Captransport(:,ind_hsld_transpCar) = dynForc_cap_tr_car .* Captransport(:,ind_hsld_transpCar) .* stockautomobile ./ stockautomobile_prev;
end

if ETC_infra_pass==1 // Alternatives take capacity targets
    if current_time_im < year_ETC_infra_pass+1
        Captransport(:,ind_hsld_transpCar)=Captransport(:,ind_hsld_transpCar).*stockautomobile./stockautomobile_prev;
    end	
    if current_time_im>year_ETC_infra_pass
        Captransport_obj_LT(:,ind_hsld_transpCar)=(Ltot*Objective_CapRoadsCars)./(pkmautomobileref).*Captransportref(:,ind_hsld_transpCar);;

        gr_rate_auto=stockautomobile./stockautomobile_prev-1;		

        for k=1:reg
            Captransport(k, ind_hsld_transpCar)=min(Captransport(k, ind_hsld_transpCar).*(1+gr_rate_auto(k)),interpln([[current_time_im,current_time_im + timehorizon_LT_CapTrans];[Captransport_prev(k, ind_hsld_transpCar),Captransport_obj_LT(k, ind_hsld_transpCar)]],current_time_im+1));
        end

    end	
end

Captransport(:,ind_hsld_transpCar)= max(Captransport(:,ind_hsld_transpCar), Captransport_prev(:, ind_hsld_transpCar) * inertia_min_CapTranspCar);
 

 


//--------------------------------------------------------------------//
// II. Other terrestrial transportation section                       //
//--------------------------------------------------------------------//
// This includes: rail freight, rail passenger, road freight, road passenger
// NB: must run after nexus.cars.sce has run


//_____________________________________________________________________
// Preliminary: to maintain stability and reproductibility, we keep the old version of "Other Transport" dynamics until start_year_strong_policy
// This should be improved in order to remove these lines
keep_old_OT = 1;
if  keep_old_OT == 1
    if current_time_im < start_year_strong_policy-base_year_simulation
        // Evolution of other transport unitary use of liquid fuels
        CI_delta_Et_OT_prev = CI_delta_Et_OT;
        for k=1:reg,
            //Price elasticity
            //data from Poles file "efficacite energetique other transport.xls"
            CI_delta_Et_OT(k)=frt_cff(current_time_im)*CIref(indice_Et,indice_OT,k)*(pArmCI_nexus(indice_Et,indice_OT,k)/(pArmCIref(indice_Et,indice_OT,k)))^elast_Et_OT(k);
            //Technical asymptote
            CI_delta_Et_OT(k)=max(CI_delta_Et_OT(k),CIref(indice_Et,indice_OT,k).*asympt_CI_Et_OT(k));
            //Maximum rate of improvement
            CI_delta_Et_OT(k)=max(CI_delta_Et_OT(k),CI_delta_Et_OT_prev(k)*max_EnerEff_ET_OT);
        end

        // Accounting for vehicles stocks inertia
        for k=1:reg
            CI_ener_OT_effInfra(indice_Et,indice_OT,k)=(Cap_prev(k,indice_OT).*(1-delta_modified(k,indice_OT))*CI_ener_OT_effInfra(indice_Et,indice_OT,k)+DeltaK(k,indice_OT)*CI_delta_Et_OT(k))/K(k,indice_OT);
        end
		

        for j=energyIndexes
            for k=1:reg
                CI_ener_OT_effNoSubs(j,indice_OT,k) = CI_ener_OT_effInfra(j,indice_OT,k);
            end
        end

        for j=indice_Et// was energyIndexes
            for k=1:reg
					
                CI(j,indice_OT,k) = CI_ener_OT_effNoSubs(j,indice_OT,k); // test_new_OT ==1 ///////////////////// ATTENTION A CE CHANGEMENT ///////////////
					
            end
        end
    end

end

// This is needed in nexus.fret, so kept
road_fret_share = (Q(:,indice_OT) - DF(:,indice_OT)) ./ Q(:,indice_OT);


//_____________________________________________________________________
// II.a. Changes in energy services

// Note that we can follow and report these values before start_year_strong_policy, even if we don't apply any change to the CI accordingly. This could be improved for more consistency.

// (i) Change from road to rail within the "OT" sector

// From start_year_strong_policy, we assume a slow shift from rail to road following recent trends (see calibration nexus). So here we update the ratios of rail in freight, rail in passenger, road in freight, road in passenger
if current_time_im >= start_year_strong_policy-base_year_simulation 
    ratio_OT_fret_rail = min(rate_shifttorail_fret + ratio_OT_fret_rail,max_share_rail_fret);
    ratio_OT_pass_rail = min(rate_shifttorail_pass + ratio_OT_pass_rail,max_share_rail_pass);
    ratio_OT_fret_road = 1-ratio_OT_fret_rail;
    ratio_OT_pass_road = 1-ratio_OT_pass_rail;
end
// We compute the new ratios of rail share to road share (useful for computation)
ratio_railtoroad_pass = ratio_OT_pass_rail./ratio_OT_pass_road;
ratio_railtoroad_fret = ratio_OT_fret_rail./ratio_OT_fret_road;


//// (ii) Change from cars to rail in bus in the passenger mobility within business sectors and administrative bodies

// We assume a modal shift from Light-Duty Vehicles (LDV) to rail and bus transportation in passenger mobility across all sectors and administrative bodies, reflecting the trend of modal shift observed within households.
// First, we compute the current modal share of automobile in household mobility (its change from the calibration is the assumed proxy) 
share_auto_hsld = (Tautomobile.*pkmautomobileref) /100 ./ ((Tautomobile.*pkmautomobileref/100) + EnergyServices_road_pass * 10^9 + EnergyServices_rail_pass * 10^9);

// Second we update the distance travelled in Light-Duty Vehicles (LDV) by business and administrative bodies. We consider it as a function of the change in overall demand for transportation services, and of the change in the household modal share. 
//  Note that this should be direct energy consumed by all sectors, but it has been accounted for as part of "Other Transportation" consumption in the current version, necessitating a reallocation. We have to re-think about it from hybridization.
pkm_ldv_in_OT = pkm_ldv_in_OT_ref .* Q(:,indice_OT)./Qref(:,indice_OT) .* share_auto_hsld ./ share_auto_hsld_ref; 
// We compute the change in rail and bus pkm from sectors driven by the modal shift by households, which is deduced from the change in LDV pkm resulting from modal shift
differential_pkm_sectors	= pkm_ldv_in_OT_ref .* Q(:,indice_OT)./Qref(:,indice_OT) .* (ones(nb_regions,1) - share_auto_hsld ./ share_auto_hsld_ref) / 10^9;
rail_pkm_fromsectors 		= ratio_OT_pass_rail .* differential_pkm_sectors;
bus_pkm_fromsectors 		= ratio_OT_pass_road .* differential_pkm_sectors;

// Note that the effects of change in occupancy rate is mainly in the efficiency (change in vkm, not in pkm)

// We finally update the energy services values for the four modes (in absolute pkm)
EnergyServices_rail_fret  = (Q(:,indice_OT )- DF(:,indice_OT)) 	./ convfactorOT_tkmtoDF ./ ( 1 + 1 ./ratio_railtoroad_fret ); // without Exp and Imp
EnergyServices_rail_pass  = DF(:,indice_OT) ./ convfactorOT_pkmtoDF ./ ( 1 + 1 ./ratio_railtoroad_pass ) + rail_pkm_fromsectors;
EnergyServices_road_fret  = (Q(:,indice_OT )- DF(:,indice_OT)) ./ convfactorOT_tkmtoDF ./ ( 1 + ratio_railtoroad_fret ); // without Exp and Imp
EnergyServices_road_pass  = DF(:,indice_OT) ./ convfactorOT_pkmtoDF ./ ( 1 + ratio_railtoroad_pass ) + bus_pkm_fromsectors;




//___________________________________________________________________________________________________________________
// II.b. Changes in the unitary energy consumption of each mode (i.e. energy efficiency improvement and substitution)


// NB: In this first version, we don't mind coal and gas demand (low values, but should be included in the substitution dynamics)

// The changes start after start_year_strong_policy
if current_time_im >= start_year_strong_policy-base_year_simulation  

    // i) First we are updating of the energy intensity for road and rail due to energy efficiency improvement

    if ind_roadFret_I == 1 & current_time_im <= 2050-base_year_simulation 
        // Exogenous assumption of energy efficiency improvement; homogenous accross region, modes, and type of energy. ~30% in 2100
        alpharail_freight = 0.99 * alpharail_freight;
        alpharail_passenger = 0.99 * alpharail_passenger ; 
        alpharoad_freight = 0.98 * alpharoad_freight; // Assumption in NAVIGATE = 2% / yr for trucks (!)
        alpharoad_passenger = 0.99 * alpharoad_passenger;
    else
        // Exogenous assumption of energy efficiency improvement; homogenous accross region, modes, and type of energy. ~30% in 2100
        alpharail_freight = 0.995 * alpharail_freight;
        alpharail_passenger = 0.995 * alpharail_passenger ; // ~30% in 2100
        alpharoad_freight = 0.995 * alpharoad_freight;
        alpharoad_passenger = 0.995 * alpharoad_passenger;
    end



    // ii) Second, we calibrate some electrification parameters

    // Calibration of a potential growth (S-shaped) curve to model the rate of electrification for trucks. Specifically, we are employing a curve to represent the maximum penetration rate of electric trucks and buses over time. Please note that within road freight, the category encompasses vehicles that are lighter than heavy-duty trucks. NB: initially I wanted to avoid modifying these parameters, and used only the electrif_OT_road_reg parameter. But it was not enough ambitious. Could be simplified?
    if ind_OT_electrification == 1
        electrif_max_OT_road = 1.0 ; // a bit less ambitious would be curve: 0.8 
        electrif_growth_OT_road = 0.08 ;
        t0_electrification_road = 35 ;
    else
        electrif_max_OT_road = 0.9 ; // a bit less ambitious would be curve: 0.8 
        electrif_growth_OT_road = 0.08 ;
        t0_electrification_road = 45 ; // a bit less ambitious would be curve: 50
    end
    // Such a curve envisages: ~15% in 2050; 50% in 2075, 83% in 2100, with electrif_growth_OT_road = 0.08, electrif_max_OT_road = 0.9, t0_electrification_road = 45. Note that it is less optimistic than the IEA NZE scenario.

    // We compute the current value of this max potential
    smoothing_factor = min((current_time_im+base_year_simulation-start_year_strong_policy)/10,1); // We add this smoothing factor to start from almost 0.
    OT_max_electrif_road = smoothing_factor*electrif_max_OT_road ./ (1 + exp(-electrif_growth_OT_road * ((base_year_simulation + current_time_im - start_year_strong_policy + 1) - t0_electrification_road)));

    // We define the maximum value of electrification in railways
    OT_max_electrif_rail = 1.0; // We consider that all region can reach 100% electrification in railways.

    // We consider different levels of maximum electric truck/bus penetration depending on the region and the sector assumption (scenario).
    if ind_OT_electrification == 1 & current_time_im >= start_year_strong_policy-base_year_simulation
        electrif_OT_road_reg = [0.95;0.95;1.0;1.0;0.8;1.0;0.9;0.9;0.7;0.8;1.0;0.9] ; // Percentage of maximum electrification potential achieved in each region: optimistic assumption
        electrif_OT_rail_reg = [0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01;0.01]; // Speed of increase of electrification of railways in percentage of the whole transportation per year (in energy service); optimistic assumption
    else 
        electrif_OT_road_reg = [0.8;0.8;0.8;0.8;0.6;0.8;0.8;0.7;0.6;0.7;0.8;0.7] ; // Percentage of maximum electrification potential achieved in each region: baseline assumption
        electrif_OT_rail_reg = [0.005;0.005;0.007;0.007;0.005;0.007;0.007;0.005;0.005;0.005;0.005;0.005]; // Speed of increase of electrification of railways in percentage of the whole transportation per year (in energy service)
    end

		

    // iii) Third, we are updating the energy intensities for road and rail due to substitutions, considering the different efficiency from final energy to energy services between fossil fuels and electricity
    OT_elec_share_PE_prev	= OT_elec_share_PE;
    OT_Et_share_PE_prev 	= OT_Et_share_PE;
    OT_elec_share_FE_prev = OT_elec_share_FE;
    OT_Et_share_FE_prev 	= OT_Et_share_FE;
	
    // Rail freight and passenger (exogenous change rate)
    OT_elec_share_PE (:,label_desag_OT == "rail_freight"|label_desag_OT == "rail_passenger") = min(OT_elec_share_PE_prev (:,label_desag_OT == "rail_freight"|label_desag_OT == "rail_passenger") + electrif_OT_rail_reg * ones(1,2),OT_max_electrif_rail*ones(nb_regions,2));
    // Road freight and passenger (driven by the S-shaped curve)
    OT_elec_share_FE (:,label_desag_OT == "road_freight"|label_desag_OT == "road_passenger") = electrif_OT_road_reg * OT_max_electrif_road * ones(1,2);


    OT_elec_share_FE(:,label_desag_OT == "rail_freight"|label_desag_OT == "rail_passenger") = OT_elec_share_PE(:,label_desag_OT == "rail_freight"|label_desag_OT == "rail_passenger")./(indice_FE_electoEt - (indice_FE_electoEt - 1) .* OT_elec_share_PE(:,label_desag_OT == "rail_freight"|label_desag_OT == "rail_passenger"));	 // x = y / (3 - 2 y);
		
    OT_elec_share_PE (:,label_desag_OT == "road_freight"|label_desag_OT == "road_passenger") = indice_FE_electoEt .* OT_elec_share_FE (:,label_desag_OT == "road_freight"|label_desag_OT == "road_passenger") ./ (1 + (indice_FE_electoEt - 1) .* OT_elec_share_FE (:,label_desag_OT == "road_freight"|label_desag_OT == "road_passenger")); // y = 3 x / (1 + 2 x)


    OT_Et_share_FE = OT_Et_share_FE - OT_elec_share_FE + OT_elec_share_FE_prev;
    OT_Et_share_PE = OT_Et_share_PE - OT_elec_share_PE + OT_elec_share_PE_prev;
		
		
    // We save the previous values
    alpharail_freight_prev 	= alpharail_freight;
    alpharail_passenger_prev = alpharail_passenger; 
    alpharoad_freight_prev 	= alpharoad_freight;
    alpharoad_passenger_prev = alpharoad_passenger;
	
    // We compute the new values of alphas, resulting from the previous change
    if or(OT_elec_share_FE_prev == 0) then
		
        alpharail_freight(:,indice_Et)		= max(alpharail_freight_prev(:,indice_Et)	.* (OT_Et_share_PE(:,label_desag_OT == "rail_freight")	./ OT_Et_share_PE_prev(:,label_desag_OT == "rail_freight")),zeros(nb_regions,1));
        alpharail_passenger(:,indice_Et)		= max(alpharail_passenger_prev(:,indice_Et)	.* (OT_Et_share_PE(:,label_desag_OT == "rail_passenger") 	./ OT_Et_share_PE_prev(:,label_desag_OT == "rail_passenger")),zeros(nb_regions,1));
        alpharoad_freight(:,indice_Et)		= max(alpharoad_freight_prev(:,indice_Et)	.* (OT_Et_share_PE(:,label_desag_OT == "road_freight")	./ OT_Et_share_PE_prev(:,label_desag_OT == "road_freight")),zeros(nb_regions,1));
        alpharoad_passenger(:,indice_Et)		= max(alpharoad_passenger_prev(:,indice_Et)	.* (OT_Et_share_PE(:,label_desag_OT == "road_passenger") 	./ OT_Et_share_PE_prev(:,label_desag_OT == "road_passenger")),zeros(nb_regions,1));

        alpharail_freight(:,indice_elec) 		= alpharail_freight(:,indice_Et)		.* OT_elec_share_FE(:,label_desag_OT == "rail_freight")./OT_Et_share_FE(:,label_desag_OT == "rail_freight");
        alpharail_passenger(:,indice_elec)	= alpharail_passenger(:,indice_Et)	.* OT_elec_share_FE(:,label_desag_OT == "rail_passenger")./OT_Et_share_FE(:,label_desag_OT == "rail_passenger");
        alpharoad_freight(:,indice_elec) 		= alpharoad_freight(:,indice_Et)		.* OT_elec_share_FE(:,label_desag_OT == "road_freight")./OT_Et_share_FE(:,label_desag_OT == "road_freight");
        alpharoad_passenger(:,indice_elec)	= alpharoad_passenger(:,indice_Et)	.* OT_elec_share_FE(:,label_desag_OT == "road_passenger")./OT_Et_share_FE(:,label_desag_OT == "road_passenger");

    else
	
        alpharail_freight(:,indice_elec)		= alpharail_freight_prev(:,indice_elec)		.* (OT_elec_share_PE(:,label_desag_OT == "rail_freight")	./ OT_elec_share_PE_prev(:,label_desag_OT == "rail_freight"));
        alpharail_passenger(:,indice_elec)	= alpharail_passenger_prev(:,indice_elec)	.* (OT_elec_share_PE(:,label_desag_OT == "rail_passenger") 	./ OT_elec_share_PE_prev(:,label_desag_OT == "rail_passenger"));
        alpharoad_freight(:,indice_elec)		= alpharoad_freight_prev(:,indice_elec)		.* (OT_elec_share_PE(:,label_desag_OT == "road_freight")	./ OT_elec_share_PE_prev(:,label_desag_OT == "road_freight"));
        alpharoad_passenger(:,indice_elec)	= alpharoad_passenger_prev(:,indice_elec)	.* (OT_elec_share_PE(:,label_desag_OT == "road_passenger") 	./ OT_elec_share_PE_prev(:,label_desag_OT == "road_passenger"));

        alpharail_freight(:,indice_Et) 		= max(alpharail_freight(:,indice_elec)		.* OT_Et_share_FE(:,label_desag_OT == "rail_freight")./OT_elec_share_FE(:,label_desag_OT == "rail_freight"),zeros(nb_regions,1));
        alpharail_passenger(:,indice_Et) 		= max(alpharail_passenger(:,indice_elec)		.* OT_Et_share_FE(:,label_desag_OT == "rail_passenger")./OT_elec_share_FE(:,label_desag_OT == "rail_passenger"),zeros(nb_regions,1));
        alpharoad_freight(:,indice_Et) 		= max(alpharoad_freight(:,indice_elec)		.* OT_Et_share_FE(:,label_desag_OT == "road_freight")./OT_elec_share_FE(:,label_desag_OT == "road_freight"),zeros(nb_regions,1));
        alpharoad_passenger(:,indice_Et) 		= max(alpharoad_passenger(:,indice_elec)		.* OT_Et_share_FE(:,label_desag_OT == "road_passenger")./OT_elec_share_FE(:,label_desag_OT == "road_passenger"),zeros(nb_regions,1));
			
    end


		
	
    // Finally we compute the CI resulting from the new values of alphas and energy services
    for k = 1:nb_regions
		
        // Update of the share of CI(energyIndexes,indice_OT,:) indexed to the energy intensity of automobiles
        CI_OT_ldv(indice_Et,indice_OT,k) = alphaEtauto(k) * pkm_ldv_in_OT(k) / Q(k,indice_OT); // Also equals to alphaEtauto(k) / Qref(k,indice_OT).
        CI_OT_ldv(indice_elec,indice_OT,k) = alphaelecauto(k) * pkm_ldv_in_OT(k)/ Q(k,indice_OT);
			
        // Update of the other share of CI(energyIndexes,indice_OT,:), the true direct energy consumed by the "Other Transport" sector (without the direct energy consumed by businesses and administrations to use LDV).
        for j = 1:nbsecteurenergie 
            CI_OT_serv(j,indice_OT,k) = (alpharail_freight(k,j)	*EnergyServices_rail_fret(k) ..
                + alpharail_passenger(k,j)	*EnergyServices_rail_pass(k) ..
                + alpharoad_freight(k,j)		*EnergyServices_road_fret(k) ..
                + alpharoad_passenger(k,j)	*EnergyServices_road_pass(k)) ..
            / Q(k,indice_OT);
        end
		
        //	Update of the CI(energyIndexes,indice_OT,:)
        CI(energyIndexes,indice_OT,k) = CI_OT_serv(energyIndexes,indice_OT,k) + CI_OT_ldv(energyIndexes,indice_OT,k);
		
    end 

end




//___________________________________________________________________________________________________________________
// II.c. Changes in other terrestrial transport capacities: capacities follow the increase in the vehicle stock by default, as the objective is to avoid congestion (i.e. the utilization rate remains constant). Alternatives take capacity targets.

// Note that this is the same process for Other Transportation and Air, but we decided to separate the code to keep the organisation by mode

URtransport(:,ind_hsld_transpOT) = pkmautomobileref./(100*ones(reg,1)).*alphaOT.*Conso(:,indice_OT-nbsecteurenergie)./Captransport(:,ind_hsld_transpOT);


if ETC_infra_pass==0
    Captransport(:, ind_hsld_transpOT)=dynForc_cap_tr_ot.*Captransport(:, ind_hsld_transpOT).*DF_prev(:,indice_OT) ./DF_prev_prev(:,indice_OT);
end

if ETC_infra_pass==1
    if current_time_im<year_ETC_infra_pass+1
        Captransport(:, ind_hsld_transpOT)=dynForc_cap_tr_ot.*Captransport(:, ind_hsld_transpOT).*DF_prev(:,indice_OT) ./DF_prev_prev(:,indice_OT);
    end
    if current_time_im>year_ETC_infra_pass
        Captransport_obj_LT=zeros(reg,3);
        gr_rate_OTT=DF_prev(:,indice_OT) ./DF_prev_prev(:,indice_OT)-1;
        Captransport(:, ind_hsld_transpOT)=dynForc_cap_tr_ot.*Captransport(:, ind_hsld_transpOT).*(1+gr_rate_OTT);
    end	
end

// Inertia on transport capacities - Other Transport
for k=ind_global_north
    Captransport(k, ind_hsld_transpOT)=min(Captransport(k,ind_hsld_transpOT),Captransport_prev(k, ind_hsld_transpOT) * inertia_max_CapOT_n);
end
if current_time_im< yr_chg_inertia_Trans_s
    for k= ind_global_south
        Captransport(k, ind_hsld_transpOT)=min(Captransport(k, ind_hsld_transpOT),Captransport_prev(k, ind_hsld_transpOT) * inertia_max_CapOT_s_01);
    end
else
    for k= ind_global_north
        Captransport(k, ind_hsld_transpOT)=min(Captransport(k, ind_hsld_transpOT),Captransport_prev(k, ind_hsld_transpOT)  * inertia_max_CapOT_s_30);
    end
end







//--------------------------------------------------------------------//
// III. Air transportation section                                    //
//--------------------------------------------------------------------//
// This includes domestic air transportation (accounted in transportation), and international air transportation (accounted in bunkers).



//_____________________________________________________________________
// III.a. Energy efficiency improvement


// We apply here exogenous energy efficiency improvement trajectories, depending on the variant
if ind_transportefficiency == 1 & current_time_im >= start_year_strong_policy-base_year_simulation 
    EEI_Et_air = 0.993; // Optimistic value
else
    EEI_Et_air = 0.998;// This default assumption used to be more optimistic, we introduced a more pessimistic assumption since NAVIGATE first runs. The divergence starts after start_year_strong_policy.
end

// For air transport 
CI(indice_Et,indice_air,:) = CI(indice_Et,indice_air,:) * EEI_Et_air;
CI(indice_elec,indice_air,:) = CI(indice_elec,indice_air,:) * EEI_Et_air;

// For air transport // Ceci est un doublon, mais je n'ai pas su déterminer lequel des deux devait être conservé ; Florian ?
CI(indice_Et,indice_air,:) = matrix(CI(indice_Et,indice_air,:),nb_regions,1) * EEI_Et_air .* dynForc_effAir ./ dynForc_effAir_prev;
CI(indice_elec,indice_air,:) = matrix(CI(indice_elec,indice_air,:),nb_regions,1) * EEI_Et_air .* dynForc_effAir ./ dynForc_effAir_prev;


//_____________________________________________________________________
// III.b. Changes in air transport capacities: capacities follow the increase in the vehicle stock by default, as the objective is to avoid congestion (i.e. the utilization rate remains constant). Alternatives take capacity targets.

// Note that this is the same process for Other Transportation and Air, but we decided to separate the code to keep the organisation by mode

URtransport(:,ind_hsld_transpAir) = pkmautomobileref./(100*ones(reg,1)).*alphaair.*Conso(:,indice_air-nbsecteurenergie)./Captransport(:,ind_hsld_transpAir);

if ETC_infra_pass==0
    Captransport(:,ind_hsld_transpAir)=dynForc_cap_tr_air.*Captransport(:,ind_hsld_transpAir).*DF_prev(:,indice_air)./DF_prev_prev(:,indice_air);
end

if ETC_infra_pass==1
    if current_time_im<year_ETC_infra_pass+1
        Captransport(:, ind_hsld_transpOT)=Captransport(:, ind_hsld_transpOT).*DF_prev(:,indice_OT) ./DF_prev_prev(:,indice_OT);
    end
    if current_time_im>year_ETC_infra_pass
        Captransport_obj_LT=zeros(reg,3);
        Captransport_obj_LT(:,1)=(Ltot*Objective_CapAir)./(pkmairref).*Captransportref(:,1);
        gr_rate_air=DF_prev(:,indice_air)./DF_prev_prev(:,indice_air)-1;

        for k=1:reg
            Captransport(k,ind_hsld_transpAir)=min(Captransport(k,ind_hsld_transpAir).*(1+gr_rate_air(k)),interpln([[current_time_im,current_time_im + timehorizon_LT_CapTrans];[Captransport_prev(k,1),Captransport_obj_LT(k,1)]],current_time_im+1));
        end
    end	
end

// Inertia on transport capacities - Air
Captransport(:, ind_hsld_transpAir) = min(Captransport(:, ind_hsld_transpAir), Captransport_prev(:, ind_hsld_transpAir) * inertia_max_CapAir);
for k=ind_global_north
    Captransport(k, [ind_hsld_transpAir,ind_hsld_transpOT])=max(Captransport(k, [ind_hsld_transpAir,ind_hsld_transpOT]), inertia_min_CapTran_n*Captransport_prev(k, [ind_hsld_transpAir,ind_hsld_transpOT]));
end
if current_time_im< yr_chg_inertia_Trans_s
    for k= ind_global_south
        Captransport(k, [ind_hsld_transpAir,ind_hsld_transpOT])=max(Captransport(k, [ind_hsld_transpAir,ind_hsld_transpOT]), inertia_min_CapTran_s_01 *Captransport_prev(k, [ind_hsld_transpAir,ind_hsld_transpOT]));
    end
else
    for k= ind_global_north
        Captransport(k, [ind_hsld_transpAir,ind_hsld_transpOT])=max(Captransport(k, [ind_hsld_transpAir,ind_hsld_transpOT]), inertia_min_CapTran_s_30 * Captransport_prev(k, [ind_hsld_transpAir,ind_hsld_transpOT]));
    end
end
for k=1:reg
    CI([indice_Et,indice_elec],indice_OT,k) = CI([indice_Et,indice_elec],indice_OT,k) * dynForc_effOT2(k);
end


//For air transport
CI(indice_Et,indice_air,:) = matrix(CI(indice_Et,indice_air,:),nb_regions,1) * EEI_Et_air .* dynForc_effAir ./ dynForc_effAir_prev;
CI(indice_elec,indice_air,:) = matrix(CI(indice_elec,indice_air,:),nb_regions,1) * EEI_Et_air .* dynForc_effAir ./ dynForc_effAir_prev;


//--------------------------------------------------------------------//
// IV. Shipping section                                               //
//--------------------------------------------------------------------//
// This includes only freight transportation in Imaclim-R.


// Activity reduction in shipping
if ind_shipFret_A == 1 & current_time_im>=start_year_strong_policy-base_year_simulation
    for j=energyIndexes
        for k=1:reg
            CI(j,indice_mer,k) = CI(j,indice_mer,k) * efficiency_speed_reducti(current_time_im);
        end
    end
end

// Energy efficiency in shipping
if ind_shipFret_I == 1 & current_time_im>=start_year_strong_policy-base_year_simulation
    for j=energyIndexes
        for k=1:reg
            CI(j,indice_mer,k) = CI(j,indice_mer,k) * operation_fleet_efficien; //* new_ships_efficiency; // We consider that these assumptions are redundant given our implicit representation of the fleet.
        end
    end
end

// Electrification in shipping (16% in 2050 due to "Zero emission berth in shipping (% of energy service for shipping as electricity)") and aviation (only for // IMPORTANT: we also consider a gain due the fact that electricity doesn't need to be converted (division by 3). To be consolidated!
if ind_shipping_air_electri==1 & current_time_im>=start_year_strong_policy-base_year_simulation
    for k=1:reg
        if current_time_im <= 2050-base_year_simulation
            CI(indice_elec,indice_mer,k) = CI(indice_elec,indice_mer,k) + 0.005*CI(indice_Et,indice_mer,k)/indice_FE_electoEt; // substitution from fuel to electricity
            CI(indice_Et,indice_mer,k) = CI(indice_Et,indice_mer,k)*0.995; // decrease of 0.5% / yr during 30 years = 16%
        end	
        if current_time_im > 2050-base_year_simulation // We assume the same pace of electrification of air sector beyond 2050 (only short haul planes in the NAVIGATE scenario)
            CI(indice_elec,indice_air,k) = CI(indice_elec,indice_air,k) + 0.005*CI(indice_Et,indice_air,k)/indice_FE_electoEt; // substitution from fuel to electricity
            CI(indice_Et,indice_air,k) = CI(indice_Et,indice_air,k)*0.995; // decrease of 0.5% / 
        end
    end
end


// Hydrogen technology in shipping. The ammonia vector is favoured because it is considered the most credible in the literature (rather than CH2 or LH2).
if ind_climat>2 & current_time_im >= (2025-base_year_simulation) // We consider this option after 2025

    capex_hdr_ship = capex_hdr_ship_fin + (capex_hdr_ship_ini-capex_hdr_ship_fin)*max(((2050 - (base_year_simulation+current_time_im))/25), 0)^3 ; // Degressive CAPEX, calibrated to reach 850 in 2035, following roughly (IEA, 2019)
    ratio_capital_ship = ratio_capital_ship_final + (ratio_capital_ship_ini - ratio_capital_ship_final) * max(((2050 - (base_year_simulation+current_time_im))/25), 0); // we assume a linear decreasing from 2025 to 2050;

    // Current energy cost ; NB : we don't introduce anticipation in this first version
    cost_CI_et_ship = matrix(CIref(indice_Et,indice_mer,:),nb_regions,1) .* matrix(pArmCI(indice_Et,indice_mer,:),nb_regions,1) + markup(:,indice_mer).*p(:,indice_mer);
    
	
    // By default with n_industries = 1 - single industry BUT when industry is disaggregated: should look at CI to chemical industry
    if nb_sectors_industry == 1
        p_NH3 = matrix(pArmCI(indice_elec,indice_industries,:),nb_regions,1)/conv_electoNH3 + (capex_hdr_ship*tep2kwh)/load_hdr_ship .* ones(nb_regions,1); // We compute the production price of NH3 ($/tep)
    elseif nb_sectors_industry == 8
        p_NH3 = matrix(pArmCI(indice_elec,indice_ind_chem,:),nb_regions,1)/conv_electoNH3 + (capex_hdr_ship*tep2kwh)/load_hdr_ship .* ones(nb_regions,1); // We compute the production price of NH3 ($/tep)
    end
    cost_CI_hdr_ship = p_NH3.*(1+share_capcost_ET_ship * ratio_capital_ship) .* (matrix(CIref(indice_Et,indice_mer,:),nb_regions,1)  * ratio_ener_ship) + markup(:,indice_mer).*p(:,indice_mer) * ratio_capital_ship;

    //disp([matrix(CIref(indice_Et,indice_mer,:),nb_regions,1), p_NH3], "[matrix(CIref(indice_Et,indice_mer,:),nb_regions,1), p_NH3]")

    msh_hdr_ship = (weight_logit_shipping* cost_CI_hdr_ship .^ (-elast_shipping)) ./ ( weight_logit_shipping*cost_CI_hdr_ship .^ (-elast_shipping) + cost_CI_et_ship .^ (-elast_shipping));

    new_fleet_shipping(:,ind_tech_ship_HDR) = max( K(:,indice_mer)-Kprev(:,indice_mer).*(1-delta_modified(:,indice_mer)),0).*msh_hdr_ship; // We assume that the size of the new generation increases proportionnaly to the production growth of maritime transport
    new_fleet_shipping(:,ind_tech_ship_LIQ) = max( K(:,indice_mer)-Kprev(:,indice_mer).*(1-delta_modified(:,indice_mer)),0).*(1-msh_hdr_ship);

    shipping_fleet_int = cat(3, shipping_fleet_int(:,:,2:lifetime_vessel), new_fleet_shipping);

    for k = 1:nb_regions
        shareHYD_ship(k) = sum(shipping_fleet_int(k,ind_tech_ship_HDR,:))/ sum(shipping_fleet_int(k,:,:));
        ship_sharLIQ(k) = 1-shareHYD_ship(k);
    end

    // Updating the CI
    // We take into account the demand for investment and the change in CI_ChemicalIndustry
    for k = 1:nb_regions
        CI(indice_Et,indice_mer,k) = ship_sharLIQ (k).* CIref(indice_Et,indice_mer,k); // Without any energy efficiency dynamics based on fleet turn-over, we keep it very simple.
        CI(indice_elec,indice_mer,k) = shareHYD_ship(k) .* CIref(indice_Et,indice_mer,k) / conv_electoNH3 * ratio_ener_ship;
        FE_shipping_HYD(k) = conv_electoNH3 * CI(indice_elec,indice_mer,k) .* Q(k,indice_mer); // Energie finale
    end

    ener_LIQ_ship = ship_sharLIQ.* matrix(CIref(indice_Et,indice_mer,:), nb_regions,1); // Without any energy efficiency dynamics based on fleet turn-over, we keep it very simple.
    ener_HDR_ship = shareHYD_ship .* matrix(CIref(indice_Et,indice_mer,:), nb_regions,1) / conv_electoNH3 * ratio_ener_ship;

    msh_reg = conv_electoNH3.*ener_HDR_ship ./ ( conv_electoNH3.*ener_HDR_ship + ener_LIQ_ship );
    msh_global = sum(msh_reg .* Q(:,indice_mer)) / sum( Q(:,indice_mer));

else
    new_fleet_shipping(:,2) = 0;
    new_fleet_shipping(:,1) = K(:,indice_mer)-Kprev(:,indice_mer).*(1-delta_modified(:,indice_mer));

    shipping_fleet_int = cat(3, shipping_fleet_int(:,:,2:lifetime_vessel), new_fleet_shipping);
    FE_shipping_HYD = zeros(nb_regions,1);
end


//--------------------------------------------------------------------//
// V. Cross-mode section                                              //
//--------------------------------------------------------------------//

// Here are some changes which concern several modes: changes in transportation time, in mode speeds, in infrastructure investments


//_____________________________________________________________________
// V.a. Change in the total time allocated to transportation (driven by population growth in baseline)
Tdisp=Tdisp.*(Ltot./Ltot_prev); 




//_____________________________________________________________________
// V.b. Changes in modal preferences, driven by speed

// NB: This section was initially designed to meet the specific modal share targets for major regions, as part of a variant of the NAVIGATE task 3.5 MIP. The way in which these targets are achieved is not satisfactory here, as it involves changes in the average speeds of the various modes that are difficult to justify. This needs to be improved.

// This is a "sufficiency" variant (higher share of non-motorized modes and public transport)
if ind_transportsufficiency >= 1 & current_time_im >= start_year_strong_policy-base_year_simulation 

    if current_time_im <= 2050-base_year_simulation // Changes in speed before 2050

        // We smooth the change in preference in 7 years	
        // Target parameters
        marginal_eff_travelTimeT 		= [1/700,	1/700,	1/700	,1/700	,1/700	,	1/700	,1/700	,1/700	,1/700		,1/700	,1/700	,1/700; ...
            1/120,	1/120,	1/120 	,1/120 ,1/120 ,	1/40 	,1/40 	,1/40 	,1/40 		,1/40 	,1/30 	,1/50; ...
            1/40 ,	1/40,	1/40 	,1/40 	,1/40 	,	1/90 	,1/90 	,1/60 	,1/80 		,1/80 	,1/80 	,1/80; ...
        1/12 ,	1/8 ,	1/9 	,1/16 	,1/9 	,	1/12 	,1/9 	,1/9.5 	,1/13.5 	,1/5.2 	,1/12 	,1/9.5]';		
        // Initial values to smooth, only on on motorized modes
        marginal_eff_travelTime0 		= [1/700,	1/700,	1/700	,1/700	,1/700	,	1/700	,1/700	,1/700	,1/700		,1/700	,1/700	,1/700; ...
            1/120,	1/120,	1/120 	,1/120 ,1/120 ,	1/40 	,1/40 	,1/40 	,1/40 		,1/40 	,1/30 	,1/50; ...
            1/40 ,	1/40,	1/40 	,1/40 	,1/40 	,	1/90 	,1/90 	,1/60 	,1/80 		,1/80 	,1/80 	,1/80; ...
        1/5 ,	1/5 ,	1/5 	,1/5 	,1/5 	,	1/5 	,1/5 	,1/5 	,1/5 	,1/5 	,1/5 	,1/5]';	
			
        marginal_eff_travelTime = marginal_eff_travelTime0 + (marginal_eff_travelTimeT - marginal_eff_travelTime0).*max(0,(min(7,(current_time_im + 1 + base_year_simulation - start_year_strong_policy))/7));
			
        //Inverse of marginal speed if utilisation rate is zero ti(0)
        toair			= marginal_eff_travelTime(:,ind_hsld_transpAir);
        toOT			= marginal_eff_travelTime(:,ind_hsld_transpOT);
        toautomobile	= marginal_eff_travelTime(:,ind_hsld_transpCar);
        toNM			= marginal_eff_travelTime(:,ind_hsld_transpNM);

        tairrefo(ind_global_north)	= 1/600 * ones(length(ind_global_north),1);
        tOTrefo(ind_global_north) 	= 1/40 * ones(length(ind_global_north),1);
        tOTrefo(ind_eur:ind_jan) 		= 1/70 * ones(length(ind_eur:ind_jan),1);
        tautorefo(ind_global_north)	= 1/20 * ones(length(ind_global_north),1);

        atrans = -ones(nb_regions,nb_trans_mode_hsld - 1) + (1-decrease_ti_fullCapacity) * (1 ./marginal_eff_travelTime(:,ind_hsld_transpAir:ind_hsld_transpCar));
			
    else // Changes in speed after 2050
				
        marginal_eff_travelTime 		=[1/700,1/700,	1/700	,1/700	,1/700	,	1/700	,1/700	,1/700	,1/700		,1/700	,1/700	,1/700; ...
            1/120,	1/120,	1/120 	,1/120 ,1/120 ,	1/40 	,1/40 	,1/70 	,1/40 		,1/40 	,1/30 	,1/50; ...
            1/40 ,	1/40,	1/40 	,1/40 	,1/40 	,	1/90 	,1/90 	,1/50 	,1/80 		,1/80 	,1/80 	,1/80; ...
        1/12 ,	1/8 ,	1/9 	,1/16 	,1/9 	,	1/12 	,1/9 	,1/9.5 	,1/13.5 	,1/5.2 	,1/12 	,1/9.5]';		
					
        // Inverse of marginal speed if utilisation rate is zero ti(0)
        toair			= marginal_eff_travelTime(:,ind_hsld_transpAir);
        toOT			= marginal_eff_travelTime(:,ind_hsld_transpOT);
        toautomobile	= marginal_eff_travelTime(:,ind_hsld_transpCar);
        toNM			= marginal_eff_travelTime(:,ind_hsld_transpNM);

        tairrefo(ind_global_north) = 1/600 * ones(length(ind_global_north),1);
        tOTrefo(ind_global_north) = 1/40 * ones(length(ind_global_north),1);
        tOTrefo(ind_eur:ind_jan) = 1/70 * ones(length(ind_eur:ind_jan),1);
        tautorefo(ind_global_north)= 1/20 * ones(length(ind_global_north),1);
        tautorefo(ind_ind)= 1/30 * ones(length(ind_ind),1);
	
        tOTrefo(ind_ind) = 1/40;
        toOT(ind_ind) = 1/70;
        bnOT(ind_ind) = 0.5 .* Conso(ind_ind,indice_OT-nbsecteurenergie);

        atrans = -ones(nb_regions,nb_trans_mode_hsld - 1) + (1-decrease_ti_fullCapacity) * (1 ./marginal_eff_travelTime(:,ind_hsld_transpAir:ind_hsld_transpCar));
					
    end

    // 80% decrease of marginal efficiency if we are at full capacity (ti(1))
    decrease_ti_fullCapacity = 0.8; // = default value

    // Calibration of parameters of the function representing congestion of infrastructure (marginal speed as a function of utilization rate)
    btrans=ones(nb_regions,nb_trans_mode_hsld - 1);

    ktrans=zeros(nb_regions,nb_trans_mode_hsld - 1);
    ktrans(:,ind_hsld_transpAir)=log(( -btrans(:,ind_hsld_transpAir) + tairrefo./toair)./( atrans(:,ind_hsld_transpAir)))./log(URtransportref(:,ind_hsld_transpAir));
    ktrans(:,ind_hsld_transpOT)=log(( -btrans(:,ind_hsld_transpOT) + tOTrefo./toOT)./( atrans(:,ind_hsld_transpOT)))./log(URtransportref(:,ind_hsld_transpOT));
    ktrans(:,ind_hsld_transpCar)=log(( -btrans(:,ind_hsld_transpCar) + tautorefo./toautomobile)./( atrans(:,ind_hsld_transpCar)))./log(URtransportref(:,ind_hsld_transpCar));
		
end

// In India, we have a decreasing share of OT that reaches 0 and poses problem in 2090-2100. To solve it, we apply this rustine:
if current_time_im >= 2050-base_year_simulation 
    bnOT(ind_ind) = 0.5 .* Conso(ind_ind,indice_OT-nbsecteurenergie);
    if ind_transportsufficiency == 0
        tOTrefo(ind_ind) = 1/40;
        toOT(ind_ind) = 1/70;
        atrans(ind_ind,ind_hsld_transpOT) = -1 + (1-decrease_ti_fullCapacity) * (1 ./toOT(ind_ind));
        ktrans(ind_ind,ind_hsld_transpOT)=log(( -btrans(ind_ind,ind_hsld_transpOT) + tOTrefo(ind_ind)./toOT(ind_ind))./( atrans(ind_ind,ind_hsld_transpOT)))./log(URtransportref(ind_ind,ind_hsld_transpOT));
    end
end


//_____________________________________________________________________
// V.c. Evolution in Transport Infrastructure investment

// It represents Investment in transport infrastructure (share of construction used for gross fixed capital formation that is not increasing productive sectors capacities)
// By default, it evolves as GDP
// Note that the link with actual choices in transport infrastructure expansion is not made, there is no representation of macroeconomic feedback of changes in transport infrastructure investment trends and policies
// There has been an attempt to make that link within the ADVANCE research project. See https://inari.centre-cired.fr/cired/svn/Imaclim/ImaclimRWorld/branches/AdvanceInfrastructure, and the associated publication
// Ó Broin and Guivarch. “Transport Infrastructure Costs in Low-Carbon Pathways.” Transportation Research Part D: Transport and Environment. https://doi.org/10.1016/j.trd.2016.11.002.
// It has been decided not to keep it in the trunk because it adds many (uncertain) parameters and does not have strong macroeconomic effects.
// Investments associated with transport infrastructures can be quantified ex-post following the methodology developped in Fisch-Romito, Vivien, and Céline Guivarch. 2019. “Transportation Infrastructures in a Low Carbon World: An Evaluation of Investment Needs and Their Determinants.” Transportation Research Part D: Transport and Environment 72 (July): 203–19. https://doi.org/10.1016/j.trd.2019.04.014.

DIinfra_prev=DIinfra;
if auto_calibration_txCap=="None" | year_calib_txCaptemp<>8;
    if  indice_LED<>0 & GDP_PPP_constant ./ Ltot <= max_GDPcap_DIinfra // GDP/Cap saturation level for investment in infrastructure
        // avoid DI infra to account for more than half of NRB
        DIinfra(:,indice_construction) = DIinfra_prev(:,indice_construction).*GDP_MER_real./GDP_MER_real_prev;
        test_increase_DIinfra = (sum(pArmDI.*DIinfra,"c") ./ NRB < max_share_DIinfra_NRB);
        DIinfra(:,indice_construction) = test_increase_DIinfra .* DIinfra(:,indice_construction) + (1-test_increase_DIinfra) .* max(0,(NRB .* max_share_DIinfra_NRB - sum(pArmDI.*DIinfra,'c') + pArmDI(:,indice_construction).*DIinfra(:,indice_construction)) ) ./ pArmDI(:,indice_construction);
        //DIinfra(:,indice_construction) = DIinfra_prev(:,indice_construction).*GDP_MER_real./GDP_MER_real_prev .* test_increase_DIinfra + DIinfra_prev(:,indice_construction).* (1-test_increase_DIinfra);
    end
end
