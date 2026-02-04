////////////////////////////////////////////////////////////////////////////
////// Reduced representation of households vehicle choices
// //This nexus makes the following parameters evolve between two static equilibria: 
// alphaCompositeauto 
// alphaEtauto 
// alphaelecauto
/////////////////////////////////////////////////////////////////////////////
// Note that there is no link made between vehicle choices and cars purshase in households budget in the static
// that means that if, based on lifecycle costs, households choose cars that are more expensive to buy but less expensive for fuel costs or O&M
// there is no forced consumption of industrial goods in the static, so that macroeconomic effect is not captured (maybe something for future development)
////////////////////////////////////////////////////////////////////////////
// Note that the option to have hydrogen cars is only available if nexus land-use is used
// For further development, representing the costs and potential of hydrogen cars without needing nexus land-use may be useful
////////////////////////////////////////////////////////////////////////////
// Some references that can be useful to compared results
// Muratori, M., Mai, T., 2021. The shape of electrified transportation. Environ. Res. Lett. 16, 011003. https://doi.org/10.1088/1748-9326/abcb38
// Gloval EV outlook from IEA
// Mai, Trieu, Paige Jadun, Jeffrey Logan, Colin McMillan, Matteo Muratori, Daniel Steinberg, Laura Vimmerstedt, Ryan Jones, Benjamin Haley, and Brent Nelson. 2018. Electrification Futures Study: Scenarios of Electric Technology Adoption and Power Consumption for the United States. Golden, CO: National Renewable Energy Laboratory. NREL/TP-6A20-71500. https://www.nrel.gov/docs/fy18osti/71500.pdf.
// Edelenbosch, O.Y., Hof, A.F., Nykvist, B., Girod, B., van Vuuren, D.P., 2018. Transport electrification: the effect of recent battery cost reduction on future emission scenarios. Climatic Change 151, 95–108. https://doi.org/10.1007/s10584-018-2250-y
///////////////////////////////////////////////////////////////////////////
// Note that a version that represents the heterogeneity of households in their vehicle choices in several classes (with respect to technology preferences and distances driven)
// was developed in the ADVANCE project
// see for details McCollum, D.L., Wilson, C., Bevione, M. et al. Interaction of consumer preferences and climate policies in the global transition to low-carbon vehicles. Nat Energy 3, 664–673 (2018). https://doi.org/10.1038/s41560-018-0195-z
// and code for Imaclim in https://inari.centre-cired.fr/cired/svn/Imaclim/ImaclimRWorld/branches/AdvanceInfrastructure_CARS
////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// Computing the total cost of ownership (or lifecycle cost) of vehicles
/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////
//////Purshase cost, with learning by doing /////////////////////

//Purshase cost by region, year and vehicle technology

CINV_cars_nexus=zeros (nb_regions,nb_techno_cars);
CINV_cars = zeros(nb_regions,nb_techno_cars);
CINV_cars_temp =zeros (1,nb_techno_cars);

// Learning rates in the optimistic scenario for BEV and HYD car technologies: the more optimistic assumption aims to represent public investment in R&D
if current_time_im >= start_year_strong_policy-base_year_simulation
	if indice_ldv_electri == 1   
	LR_ITC_cars(indice_CAR_BEV)=0.18; //0.12 ; was 0.16 in ind_VE previous version
      LR_ITC_cars(indice_CAR_HYD)=0.3;
	else
	LR_ITC_cars(indice_CAR_BEV)=0.12;
	end
end

//Cumulated sales over time
if current_time_im>1
    sum_Inv_cars=sum(stockVintageAutoTechno(:,:,current_time_im-1), "r");
    Cum_Inv_cars=Cum_Inv_cars+ sum_Inv_cars;
end



//Decrease in purshase cost with cumulated sales (learning by doing, with full spill-over: ie it is the cumulated sales at the global level that decrease costs for all regions)
for k=1:nb_regions
    CINV_cars_nexus(k,:) =CINV_cars_nexus_ref(k,:).*(1-LR_ITC_cars).^( log2 (Cum_Inv_cars./Cum_Inv_cars_ref));
end


// Here we represent public support for the purchase of electric vehicles, in order to value the least negative externalities (air pollution, noise pollution). It's indexed to public spending per person in the services sector.
if indice_ldv_electri == 1 & current_time_im >= start_year_strong_policy-base_year_simulation
	for k=1:nb_regions
    CINV_cars_nexus(k,indice_CAR_BEV) =CINV_cars_nexus_ref(k,indice_CAR_BEV)*(1-0.3*((DG(k,indice_composite)/Ltot(k))/max(DG(:,indice_composite)./Ltot(:))))*(1-LR_ITC_cars(indice_CAR_BEV))^( log2 (Cum_Inv_cars(indice_CAR_BEV)/Cum_Inv_cars_ref(indice_CAR_BEV)));
	end
end

//Minimum bound on purshase cost (representing a technical asymptote)
CINV_cars_nexus=max(CINV_cars_nexus,A_CINV_cars_ITC_ref);

//Variable for extraction, to check how cars purshase costs decrease over time
apprent_car = zeros(nb_regions,nb_techno_cars,TimeHorizon+1);
apprent_car(:,:,current_time_im+1) = (CINV_cars_nexus-CINV_cars_nexus_ref)./(A_CINV_cars_ITC_ref-CINV_cars_nexus_ref+%eps);

// Equivalent in annual terms, to compute annual total cost of ownership
CINV_cars=CRF_cars.*CINV_cars_nexus;


///////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////Anticipations of fuel costs and Operation and Maintenance costs/////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////

Life_time_max_cars=max(LIFE_time_cars);

p_Et_cars_anticip   = squeeze(expected.pArmDF(:,et  ,1:Life_time_max_cars));
p_elec_cars_anticip = squeeze(expected.pArmDF(:,elec,1:Life_time_max_cars));
if (ind_NLU == 1 & ind_hydrogen == 1) 
    if is_bau
        p_H2_cars_anticip = (pind .* h2_gaseif_costs + gjh2_2_gjbiom * Tot_bioelec_cost_del .* tep2gj) * ones( 1, Life_time_max_cars);
    else
        p_H2_cars_anticip = (pind .* h2_gaseif_costs + gjh2_2_gjbiom * Tot_bioelec_cost_del .* tep2gj + h2_gaseif_emission .* (reg_taxeC' - 0.0) .* tep2gj ) * ones( 1, Life_time_max_cars);
    end
else
    // cars fueled with hydrogen does not work if the nexus land-use isn't used, so we set an infinite price
    // fo have hydrogen without the NLU, one need to implement a cost of biomass
    p_H2_cars_anticip = 1e15 * ones( nb_regions, Life_time_max_cars);
end

//Autonomous energy efficiency improvement of BEV

if ind_transportefficiency == 1 & current_time_im >= start_year_strong_policy-base_year_simulation
EFF_BEV_time=60; // This drives the pace of energy efficiency improvement (-50% in 30 year with EFF_BEV_time=60 years). NB: it used to be the default value.
else
EFF_BEV_time=120; // New default value, introduced to meet the task 3.5 NAVIGATE objectives.  We add a pessimistic assumption here to introduce some contrast (we halve the speed of improvement). The divergence starts after 2020.
end

if ind_transportefficiency == 1 & current_time_im >= start_year_strong_policy-base_year_simulation
autonomous_EFF_ICE=2.2;  //NB: it used to be the default value, now it is the pessimistic assumption. The divergence starts after 2020.
else
autonomous_EFF_ICE=0; // Pessimistic assumption
end

//Assumption the energy efficiency is improved linearly to reach its asymptote of 100 Wh/km (ie half of the calibration value) in 30 years
EFF_BEV(:,current_time_im)=max(EFF_BEV_floor,(1-current_time_im/EFF_BEV_time)*EFF_BEV(:,1));

//Endogenous and price induced energy efficiency improvement of ICE
//We represent that the gap between the energy efficiency and a floor of 2L/100km for ICE is reduced as a linear function of fuel prices (the higher the price, the faster the gap is reduced)
annual_gap_reduction=autonomous_EFF_ICE+price_induced_EFF_ICE*pArmDF(:,et)*L_to_toe;
if current_time_im==1
	GAP_EFF_ICE=EFF_ICE(:,1)-EFF_ICE_floor*ones(reg,1);
else
	GAP_EFF_ICE=EFF_ICE(:,current_time_im-1)-EFF_ICE_floor*ones(reg,1);
end
EFF_ICE(:,current_time_im)=EFF_ICE_floor*ones(reg,1)+(ones(reg,1)-annual_gap_reduction/100).*GAP_EFF_ICE;


//Computing average fuel cost (anticipated) per vehicle.kilometer over the vehicle lifetime
for k=1:nb_regions
    for j=1:nb_techno_cars
        if sum(carnames(j)== ["ICE"]) == 1
            CFuel_cars(k,j)= mean (p_Et_cars_anticip  (k,1:LIFE_time_cars(k,j)))*  EFF_ICE(k,current_time_im) ;
        elseif sum(carnames(j)== ["BEV"]) == 1
            CFuel_cars(k,j) = mean (p_elec_cars_anticip(k,1:LIFE_time_cars(k,j)))*EFF_BEV(k,current_time_im);
        elseif sum(carnames(j)== ["HYDROGEN"]) == 1
            CFuel_cars(k,j)= max( mean (p_H2_cars_anticip  (k,1:LIFE_time_cars(k,j)))*  EFF_HYD(k,current_time_im), 0);
        end
    end
end


///////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////Total cost by technology type - and market shares in sales/////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////

//Total cost of ownership (or lifecycle cost LCC) per vehicle.kilometre.year M$/(vehicle.km.year)
LCC_cars =  CINV_cars./average_km_per_year+OM_cost_var_cars./average_km_per_year+CFuel_cars;


//Distribution of market shares, depending on total costs of ownership
//Represented with a logit (cheaper takes a larger market share, but not all)
for k=1:nb_regions
    for j=1:nb_techno_cars
        MSH_cars(k,j)=(LCC_cars(k,j)).^(-var_hom_cars(k))./sum(((LCC_cars(k,indice_cars2consider)).^(-var_hom_cars(k)*ones(1, size(indice_cars2consider,'c')))));
    end
end

//Adding some constraints on the market share of electric vehicles
for k=1:nb_regions
    //Maximum share following the S-curve of penetration
    msh_cars_sup(k,indice_CAR_BEV)=MSH_limit_newtechno(Tstart_EV(k),Tniche_EV(k),Tgrowth_EV(k),Tmature_EV(k),MSHmax_EV(k),current_time_im);
    //actual limitation
	delta_loc = MSH_cars(k, indice_CAR_BEV)-msh_cars_sup(k,indice_CAR_BEV);
    if delta_loc>0
        MSH_cars(k, indice_CAR_BEV) = msh_cars_sup(k,indice_CAR_BEV);
	  //rebalancing sum of markets shares to 1
      if ind_hydrogen == 0 | ind_NLU == 0 
       MSH_cars(k,indice_CAR_ICE) = MSH_cars(k,indice_CAR_ICE).*(1+(delta_loc)./sum(MSH_cars(k,indice_CAR_ICE)));
      end
    end
end

//Adding some constraints on the market share of hydrogen vehicles (in the case this option is activated)
for k=1:nb_regions
    //Maximum share following the S-curve of penetration
    msh_cars_sup(k,indice_CAR_HYD) = MSH_limit_newtechno(Tstart_HYD(k),Tniche_HYD(k),Tgrowth_HYD(k),Tmature_HYD(k),MSHmax_HYD(k),current_time_im);

    delta_loc = MSH_cars(k,indice_CAR_HYD) - msh_cars_sup(k,indice_CAR_HYD);

    if delta_loc > 0
		MSH_cars(k,indice_CAR_HYD) = msh_cars_sup(k,indice_CAR_HYD);
		MSH_cars(k,indice_CAR_HYD) = max( MSH_cars(k,indice_CAR_HYD), 1e-3);
    end
end
if ind_hydrogen == 0 | ind_NLU == 0
      MSH_cars(:,indice_CAR_HYD) = zeros(nb_regions,1);
else
  //rebalancing sum of markets shares to 1
  for k=1:nb_regions
      MSH_cars(k,indice_CAR_ICE) = MSH_cars(k,indice_CAR_ICE) ./ sum(MSH_cars(k,indice_CAR_ICE)) * ( 1 - sum(MSH_cars(k, [indice_CAR_BEV, indice_CAR_HYD] )) ) ;
  end
end


///////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////Updating technical coefficients of the vehicle fleet////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////

//Vehicles sold before calibration year remaining in the fleet (we simulate a linear depreciation of the fleet calibrated the first year, with the calibrated lifetime)
nbcar_pre_calibyear = max(nombreautomobileref*(lifetime_cars-current_time_im)/lifetime_cars,0);

//Following cars generations (vehicles sold in previous year, remaining in the fleet)
nb_car_non_new=nbcar_pre_calibyear;

for k=1:nb_regions
    for j_tech=1:nb_techno_cars
        for j_time=1:Life_time_max_cars
            if (current_time_im-j_time)>0 then
                if ((current_time_im-j_time)+LIFE_time_cars(k,j_tech))>current_time_im then	
                    nb_car_non_new(k)=nb_car_non_new(k)+stockVintageAutoTechno(k,j_tech,current_time_im-j_time); 
                end
            end
        end
    end
end

//New cars generation (vehicles sold in current year)
cars_sales=max(nb_car-nb_car_non_new, %eps );

stockVintageAutoTechno;
//New cars generation by region and technology type
for j_tech=1:nb_techno_cars
    stockVintageAutoTechno(:,j_tech,current_time_im) = MSH_cars(:,j_tech).*cars_sales;
end


//Technical characteristics of vehicles generations since calibration year
alphaEtauto_temp    =zeros(nb_regions,1);
alphaelecauto_temp  =zeros(nb_regions,1);
alphaHYDauto_temp  =zeros(nb_regions,1);
alphaCompositeauto_temp  =zeros(nb_regions,1);
test_nb_auto_vintage=zeros(nb_regions,1);
stovartemp = zeros(nb_regions, nb_techno_cars);

for k=1:nb_regions 
        for j_time=0:Life_time_max_cars
            if (current_time_im-j_time)>0 then
                if (current_time_im-j_time+LIFE_time_cars(k,j_tech))>current_time_im then	
				    alphaEtauto_temp(k)=alphaEtauto_temp(k)+stockVintageAutoTechno(k,indice_CAR_ICE,current_time_im-j_time).*(EFF_ICE(k,current_time_im-j_time)./(tauxderemplissageauto(k))); 
                    alphaelecauto_temp(k)=alphaelecauto_temp(k)+stockVintageAutoTechno(k,indice_CAR_BEV,current_time_im-j_time).*(EFF_BEV(k,current_time_im-j_time)./(tauxderemplissageauto(k)));
                    alphaHYDauto_temp(k)=alphaHYDauto_temp(k)+stockVintageAutoTechno(k,indice_CAR_HYD,current_time_im-j_time).*(EFF_HYD(k,current_time_im-j_time)./(tauxderemplissageauto(k)));
					for j_tech=1:nb_techno_cars                
					alphaCompositeauto_temp(k)=alphaCompositeauto_temp(k)+stockVintageAutoTechno(k,j_tech,current_time_im-j_time).*OM_cost_var_cars(k,j_tech)./average_km_per_year;
						test_nb_auto_vintage(k)= test_nb_auto_vintage(k)+stockVintageAutoTechno(k,j_tech,current_time_im-j_time);
						stovartemp(k,j_tech) =  stovartemp(k,j_tech) + stockVintageAutoTechno(k,j_tech,current_time_im-j_time);
					end
				end
            end
        end    
end

//Average technical characteristics of the all fleet, accounting for remaining vehicles from the calibration year (if any) and generations that have not reached the end of their lifetime
stock_car_ventile (:,:, current_time_im+1) = stovartemp + (nbcar_pre_calibyear*ones(1,nb_techno_cars)).* MSH_cars_ref;
alphaEtauto=(alphaEtauto_temp+alphaEtautoref.*nbcar_pre_calibyear)./nb_car;
alphaelecauto=(alphaelecauto_temp+alphaelecautoref.*nbcar_pre_calibyear)./nb_car;
alphaHYDauto=( alphaHYDauto_temp + alphaHYDautoref.*nbcar_pre_calibyear)./nb_car;
alphaCompositeauto=(alphaCompositeauto_temp+alphaCompositeautoref.*nbcar_pre_calibyear)./nb_car;


//Extracting and saving variables from this nexus, to check and analyze evolution in cars fleet in the runs
if current_time_im==TimeHorizon
    mksav("stock_car_ventile");
    mksav("Tstart_EV");
    mksav("stockVintageAutoTechno");
    mksav("apprent_car");
end

