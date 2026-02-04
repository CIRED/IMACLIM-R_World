///////////////////////////////////////////////////////////////
/////////// Nexus residential buildings ///////////////////////
///////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////
// Rationale of the nexus building and content of the calibration file

// This nexus mainly consists in defining (1) changes in the residential floor space demand ; (2) changes in the energy consumption by source by type of buildings; (3) changes in the share of each type of building (three types of buildings: BAU (business as usal), SLE (standard low energy), VLE (very low energy)). It includes the implementation of the two additional "modules" to faster decarbonize the building stock.

// This file is structured as follows:
// I. 	Residential floor space demand
// II. 	Changes in energy consumption by source by type of building
// III. Change in the composition of the building stock


///////////////////////////////////////////
//I. Residential floor space demand
///////////////////////////////////////////

//This demand is driven by population growth and changes in per capita floor space, which is shaped by exogenous parameters (asymptote and some kind of income elasticity) and income growth.

////////////////////////////////////////
//I.1. Change in per capita floor space

// Initialisation of the income variable used
if current_time_im==1
    Rdisp_real_prev=Rdispref./(price_index);
end


if ind_buildingsufficiency == 1	& current_time_im >= start_year_strong_policy-base_year_simulation // NAVIGATE task 3.5 variant: cap for the North, and avoid a quicker catch up from the South. This starts in 2020.
    asymptote_surface_pc=[40;40;40;40;40;40;35;40;40;40;40;40];
	mult_surface_pc_ini=[1.0;1.0;1.0;0.6;1.0;0.4;0.6;1;0.3;1.2;0.7;1.4];
end

if ind_buildingefficiency == 1 & current_time_im == start_year_strong_policy-base_year_simulation
CINV_res_nexus_ref(:,ind_build_VLE) = 	0.00065 * ones(nb_regions,1); // Variant to meet the task 3.5 NAVIGATE objective, where we need to reach 40% of energy saving by 2030 through renovation (!) and very low NZEB level for insulation in new construction (0.3 W/m2K). This lower investment costs could be reached thanks to massive subsidies for very high efficient buildings.
max_extra_renov_rate = 0.02*3; // We accelerate the renovation rate until 2035 ...
end

if ind_buildingefficiency == 1 & current_time_im >= 2035-base_year_simulation
max_extra_renov_rate = 0.02; // ... and slow it again to 2% after 2035
end

// Initialisation and update of the building stock variable
if current_time_im==1
    stockbatiment_vise_prev=stockbatimentref;
else
    stockbatiment_vise_prev=stockbatiment_vise;
end

// Computing of the new floor space per capita required, which will drive the demand for new residential floor space
mult_surface_pc=mult_surface_pc_ini; 
for k=1:nb_regions,
    mult_surface_pc(k)=min(mult_surface_pc_ini(k),mult_surface_pc_ini(k)*(1-stockbatiment_prev(k)/Ltot_prev(k)/asymptote_surface_pc(k))); // Computing the multiplying factor (the higher the value, the faster the asymptote will be reached), which is a function of the initial multiplyer and the distance from the asymptote
    mult_surface_pc(k)=max(mult_surface_pc(k),0);

    surface_pc(k)=min(asymptote_surface_pc(k),stockbatiment_vise_prev(k)/Ltot_prev(k)*(1+mult_surface_pc(k).*max(0,(Rdisp(k)/(Ltot_prev(k)*price_index(k))/(Rdisp_real_prev(k)/Ltot_prev_stock(k)))-1))); // The income growth 'moderates' the increase pace of floor space per capita
end

//////////////////////////////////////////////////
//I.2. Applying this change to the whole building stock

stockbatiment_vise	= surface_pc .* Ltot;
deltastockbatiment	= max(-stockbatiment_prev .* depreciationm2_demolish, stockbatiment_vise - stockbatiment_prev); // in case surface_pc.*Ltot < ou = stockbatiment_prev, the building stock can not decrease except through depreciation
stockbatiment 			= stockbatiment_prev + deltastockbatiment;




////////////////////////////////////////////////////////
// II. Energy consumption by source by type of building
////////////////////////////////////////////////////////

//There are three types of residential buildings:
// - BAU (business as usal): whose energy consumption by source is defined exogenously (pathways provided by POLES - quite stable at total from 2030, slow increase in the share of gas and electrity instead of coal and ET)
// - SLE (standard low energy): whose energy consumption is 50 kWh/m² (80% elec, 20% gaz)
// - VLE (very low energy): whose energy consumption is 15 kWh/m² (100% elec)

//NB: All types of buildings have their energy consumption by source defined exogenously (and constant exogenously). Changes in efficiency will thus result mainly from changes in the composition of the building stock (see III).


//////////////////////////////////////////////////////////////
//II.1. 	Changes in the energy consumption of BAU buildings
    
// It is first exogenously defined from POLES pathways	
    alphaelecm2_BAU=alphaelecm2_IEA(:,min(current_time_im,size_alphaelecm2_IEA(2))).*alphaelecm2ref;
    alphaEtm2_BAU=  alphaEtm2_IEA(:,min(current_time_im,size_alphaelecm2_IEA(2))).*alphaEtm2ref;
    alphaCoalm2_BAU=alphaCoalm2_IEA(:,min(current_time_im,size_alphaelecm2_IEA(2))).*alphaCoalm2ref;
    alphaGazm2_BAU= alphaGazm2_IEA(:,min(current_time_im,size_alphaelecm2_IEA(2))).*alphaGazm2ref;


// There is an additional "fuel switching" module to move away from liquid fossil fuels if very high prices are reached // TODO: to be checked - especially the specific variables defined and calibrated
// Two variants are defined: in the standard one, the switch is triggered by a pArmDF_nexus(ET) of 1500$/toe (including taxes), and we move away from fossil fuels in 20 years (see calibration.nexus.building file). The triggering price is lower and the switching period shorter in the other variant.
//NB: these are ad hoc assumptions, not supported by data or previous studies. I guess it has been useful in some decarbonisation scenarios (history: comes from "scenar_Total_12"), but maybe it would be better to avoid its use as the logit function made the dynamic already sensitive to energy prices, or to support its use by a narrative where we consider policies implementing new norms (obligation to replace oil boilers), instead of supporting it by some technological optimism. In that case, these assumptions could be replaced by a year of start of this policy.

    if current_time_im>1 // Initialisation of the test variable
        test_Et_resid;
        pArmDF_nexus;
        p_decoupl_oil_res;
    elseif current_time_im==1
        test_Et_resid=zeros(nb_regions,1);
        i_Et_resid=zeros(nb_regions,1);
    end

// If the fossil fuel price reach 1000$/Mtep=0.8$/lge or more, the consumption of liquid fossil fuel switches towards elec (with an efficiency improvement of 50%) and gas (efficiency improvement of 30%) within 10 years
if current_time_im >= start_year_strong_policy-base_year_simulation // This change is not absolutely neutral compared to the trunk (as this module used to start very early, and before 2020), has to be tested.

    for k=1:nb_regions
        if (test_Et_resid(k)==0)&(pArmDF_nexus(k,indice_Et)>p_decoupl_oil_res)
            test_Et_resid(k)=1;
            i_Et_resid(k)=current_time_im;
        end
        if test_Et_resid(k)==1
            fact_decoupl_oil_res=max((0-1)/(i_Et_resid(k)+i_decoupl_oil_res-i_Et_resid(k))*(current_time_im-i_Et_resid(k))+1,0);
            alphaelecm2_BAU(k)=alphaelecm2_BAU(k) + share_elec_subsituted_m2 * (1-efficiencyGain_elec_m2) / coef_primary2final_build * (1-fact_decoupl_oil_res)*alphaEtm2_BAU(k);
            alphaGazm2_BAU(k)=alphaGazm2_BAU(k) + (1-share_elec_subsituted_m2) * (1-efficiencyGain_gas_m2) * (1-fact_decoupl_oil_res)*alphaEtm2_BAU(k);
            alphaEtm2_BAU(k)=alphaEtm2_BAU(k)*fact_decoupl_oil_res; // 0 after 10 years
        end
    end
end


// Here we add an extra electrification trend in BAU buildings to reach the electrification target
if  indice_building_electri == 1 & current_time_im >= start_year_strong_policy-base_year_simulation // 
    if ~isdef("alphaGazm2_BAU_ini")
			alphaGazm2_BAU_ini = alphaGazm2_BAU;
	end
	for k=1:nb_regions	
			alphaGazm2_BAU_prev(k) = alphaGazm2_BAU(k);
			alphaGazm2_BAU(k)= max((1-r_decoupl_gas_res*(current_time_im+base_year_simulation-start_year_strong_policy)),0)*alphaGazm2_BAU_ini(k);
            alphaelecm2_BAU(k)=alphaelecm2_BAU(k) + (1-efficiencyGain_elec_m2+efficiencyGain_gas_m2) * (alphaGazm2_BAU_prev(k) - alphaGazm2_BAU(k)) / coef_primary2final_build;
	end
end



//////////////////////////////////////////////////////////////////////
//II.2. 	Changes in the energy consumption of SLE and VLE buildings

// In the current version, we assume fixed energy consumptions for these two types of buildings.



// ... except that we add a pessimistic variant on electrification useful for NAVIGATE task 3.5 to create contrast. This pessimistic assumption became the default one.
if indice_building_electri == 0 & current_time_im >= start_year_strong_policy-base_year_simulation // Could be improved by harmonizing the values before 2020.
    alphaelecm2_SLE_sh_init = alphaelecm2_SLE_sh_min;
    alphaelecm2_SLE_sh = alphaelecm2_SLE_sh_init;
    alphaelecm2_VLE_sh_init = alphaelecm2_VLE_sh_min;
    alphaelecm2_VLE_sh = alphaelecm2_VLE_sh_init;
end




///////////////////////////////////////////
// III. Changes in the composition of the building stock
///////////////////////////////////////////

// This part consists in:
//(1) computing investment costs of construction/renovation for each type of building
//(2) computing fuel costs for each type of building
//(3) computing the resulting relative shares of each type of building in construction/renovation
//(4) defining which type of building are considered by 'natural' demolition/refurbishment operations
//(5) applying the changes to the building stock and the final energy consumption per m² of the whole building stock (per source)


////////////////////////////////////////////////////////////////////////////
//III.1. Computing purchase / investment costs of construction / renovation

// Initialisation of the variable by region and type of building // TODO: should be moved to calibration file?
CINV_res_nexus		= zeros (nb_regions,nb_type_buildings);
CINV_res			= zeros (nb_regions,nb_type_buildings); 

// Changes in investment costs are driven by cumulated sales (learning by doing, with full spill-over: ie it is the cumulated sales at the global level that decrease costs for all regions)
	    
//We thus first compute the cumulated sales for each type of building, and then compute the resulting investment costs for each type of building
	Cum_BAU = Cum_BAU + stockbatiment_BAU;
    CINV_res_nexus(:,ind_build_BAU) = max((CINV_res_nexus_ref(:,ind_build_BAU)).*(1-LR_ITC_res(ind_build_BAU)).^(log(Cum_BAU./Cum_BAU_ref)/log(2)),A_CINV_res_ITC_ref(ind_build_BAU));//Minimum bound on purshase cost (representing a technical asymptote)
				
	Cum_SLE = Cum_SLE + stockbatiment_SLE;
    CINV_res_nexus(:,ind_build_SLE) = max((CINV_res_nexus_ref(:,ind_build_SLE)).*(1-LR_ITC_res(ind_build_SLE)).^(log(Cum_SLE./Cum_SLE_ref)/log(2)),A_CINV_res_ITC_ref(ind_build_SLE));
		
	Cum_VLE = Cum_VLE + stockbatiment_VLE;
    CINV_res_nexus(:,ind_build_VLE) = max((CINV_res_nexus_ref(:,ind_build_VLE)).*(1-LR_ITC_res(ind_build_VLE)).^(log(Cum_VLE./Cum_VLE_ref)/log(2)),A_CINV_res_ITC_ref(ind_build_VLE));


// Equivalent in annual terms, to compute annual total cost of construction/renovation

	CRF_res=disc_res./(1-(1+disc_res).^(-Life_time_res));
	CINV_res = CRF_res.*CINV_res_nexus;  

// All these parameters are important and defined in calibration.nexus.buildings. Some are mostly exogenous and ad hoc assumptions, some others could be the first targets of policies to encourage efficiency in buildings (e.g. subsidies that decrease investment costs).


//////////////////////////////////////////////////////////////////
//III.2. Computing average fuel costs (anticipated) over life time

// We use anticipated energy prices to compute these fuel costs

    p_coal_res_anticip = squeeze(expected.pArmDF(: , coal , 1:Life_time_res));
    p_gaz_res_anticip  = squeeze(expected.pArmDF(: , gaz  , 1:Life_time_res));
    p_et_res_anticip   = squeeze(expected.pArmDF(: , et   , 1:Life_time_res));
    p_elec_res_anticip = squeeze(expected.pArmDF(: , elec , 1:Life_time_res));

// Intialisation of the energy cost variables for each type of building
    CFuel_res_BAU=zeros(nb_regions,1);
    CFuel_res_SLE=zeros(nb_regions,1);
	CFuel_res_VLE=zeros(nb_regions,1);

CFuel_res = zeros(nb_regions, nb_type_buildings, nb_building_ener);
// Computing of the energy costs	
for t=1:Life_time_res
    for b_type=1:nb_type_buildings
        CFuel_res(:,b_type,:) = matrix(CFuel_res(:,b_type,:),nb_regions,nb_building_ener) + [p_coal_res_anticip(:,t), p_et_res_anticip(:,t), p_gaz_res_anticip(:,t), p_elec_res_anticip(:,t)] / ((1+disc_res)^t)*CRF_res;
    end
end


// decreasing the share of gas in SLE and VLE buildings if the relative LCC of gas to electricity is 1.5 times fold

bool_build_outofgas = CFuel_res(:,ind_build_SLE,ind_build_gas) > 1.25 * CFuel_res(:,ind_build_SLE,ind_build_elec);
alphaelecm2_SLE_sh = min( alphaelecm2_SLE_sh_max, alphaelecm2_SLE_sh + (alphaelecm2_SLE_sh_max-alphaelecm2_SLE_sh_init)/10 .*bool_build_outofgas);
bool_build_outofgas = CFuel_res(:,ind_build_VLE,ind_build_gas) > 1.25 * CFuel_res(:,ind_build_VLE,ind_build_elec);
alphaelecm2_VLE_sh = min( alphaelecm2_VLE_sh_max, alphaelecm2_VLE_sh + (alphaelecm2_VLE_sh_max-alphaelecm2_VLE_sh_init)/10 .*bool_build_outofgas);

alphaelecm2_SLE = alphaelecm2_SLE_sh .* build_SLE_ener_cons / coef_primary2final_build + build_SLE_ener_cons_fix;
alphaGazm2_SLE  = (1-alphaelecm2_SLE_sh) .* build_SLE_ener_cons;
alphaelecm2_VLE = alphaelecm2_VLE_sh .* build_VLE_ener_cons / coef_primary2final_build + build_VLE_ener_cons_fix;
alphaGazm2_VLE  = (1-alphaelecm2_VLE_sh) .* build_VLE_ener_cons;


alpha_m2_building = zeros(nb_regions, nb_type_buildings, nb_building_ener);
alpha_m2_building(:,ind_build_BAU,:) = [alphaCoalm2_BAU,alphaEtm2_BAU,alphaGazm2_BAU,alphaelecm2_BAU];
alpha_m2_building(:,ind_build_SLE,:) = [alphaCoalm2_SLE,alphaEtm2_SLE,alphaGazm2_SLE,alphaelecm2_SLE];
alpha_m2_building(:,ind_build_VLE,:) = [alphaCoalm2_VLE,alphaEtm2_VLE,alphaGazm2_BAU,alphaelecm2_VLE];


CFuel_mean_res = sum(alpha_m2_building.*CFuel_res,3);
// Total cost of renovation/construction operations (or lifecycle cost LCC) per m² per year
LCC_res =  CINV_res + CFuel_mean_res;
 
///////////////////////////////////////////////////////////////////////////////////////
// III.3. Share of each type of buildings in construction and unavoidable renovations
// 'Unavoidable' renovations are defined as renovations imposed by building stock depreciation (~1/40 each year, fixed), to be distinguished from depreciation which leads to the destruction of building stock (replaced by new construction)

////// a) Shares derived from relative investment and fuel costs

// The shares are influenced by the energy prices (so by the level of carbon tax)

//Distribution of market shares, depending on total costs of construction/renovation operations
//Represented with a logit (cheaper takes a larger market share, but not all)
for k=1:nb_regions
    for j=1:nb_type_buildings
        MSH_res(k,j)=(LCC_res(k,j)).^(-var_hom_res(k))./sum(((LCC_res(k,1:3)).^(-var_hom_res(k)*ones(1, size(1:3,'c')))));
    end
end
// We use these share as follows: (1) for new construction (even due to demolitions), we use all the shares; (2) for 'natural' renovations, we only consider the relative shares of BAU and SLE (the underlying assumption is that these renovations do not result in VLE buildings); (3) for additional renovations, we only consider the relative shares of SLE and VLE (as these renovations are supposed to be "energy oriented renovations"). See III.5 below for the application.


////// b) Additional renovations module

// Inherited from the V1 nexus... I found it very parametric. I propose to simplify it, by removing the trigerring mechanism (but keeping the ). I think we should adapt it to better reflect one type of policies aiming at encourage some additional renovations. TODO: to be discussed/implemented

// FYI: the triggering mechanism was based on an "Insulation norm". This parameter wass a threshold, changing with taxCO2 (the higher it is the lower the threshold, within a min-max interval) and time (decreasing with time). It triggered additional renovation.
//norme_isolation(:,current_time_im+1)=max ( min_insul_Norm_share / max_insul_Norm_share, 1 - taxCO2_DF(:,indice_Et) / (tax_threshold_insulation *1e-6) ) * norm_ins_exponential_dec ^ current_time_im * max_insul_Norm_share;

// Current definition of the additional renovation rate, which makes changes in the composition of the building stock more sensitive to the carbon tax. As said above, some improvements could be envisaged here.
if current_time_im < start_year_strong_policy-base_year_simulation
taux_renov_suppl = 0; // We start the policy only after the start year policy
else
if tax_threshold_insulation == 0 // We add the possibility to impose a rhythm of renovation even without tax, as it is expected in Navigate task 3.5
taux_renov_suppl = max_extra_renov_rate;
else
taux_renov_suppl=min(1, taxCO2_DF(:,indice_Et) / (tax_threshold_insulation *1e-6) ) * max_extra_renov_rate;
end
end	 


// TODO: write the code with one matrix for the three building stocks?
// TODO: consider the case when stockbatiment_BAU_prev = 0, so that taux_renov_suppl is applying to stockbatiment_SLE_prev.



///////////////////////////////////////////////////////////////////////////////////
// III.4. Demolition dynamics and impacts on the composition of the building stock

// By convention, we assume that demolitions and refurbishments firstly concern BAU, then SLE, then VLE... it is a first approximation. TODO: It could be improved by considering that it is driven by the age of building, and so that to represent the share of building in each generation. Nevertheless, I think the added value wouldn't be very high, notably given that the stock of existing buildings is composed of BAU buildings.

stockbatiment_BAU_prev=stockbatiment_BAU;
stockbatiment_SLE_prev=stockbatiment_SLE;
stockbatiment_VLE_prev=stockbatiment_VLE;

share_demolition = zeros(nb_regions,nb_type_buildings);
for k=1:nb_regions 
share_demolition(k,1) = max(0,min (1, stockbatiment_BAU_prev(k)/(stockbatiment_prev(k)*(depreciationm2_demolish(k)+depreciationm2_refurbish(k)))));
	if (stockbatiment_BAU_prev(k) + stockbatiment_SLE_prev(k)) >= (stockbatiment_prev(k)*(depreciationm2_demolish(k)+depreciationm2_refurbish(k)))
		share_demolition(k,2) = 1 - share_demolition(k,1);
	else
		share_demolition(k,2) = max(0,min (1, stockbatiment_SLE_prev(k)/(stockbatiment_prev(k)*(depreciationm2_demolish(k)+depreciationm2_refurbish(k)))));
	end
share_demolition(k,3) = 1 - share_demolition(k,1) - share_demolition(k,2);
end

 
 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// III.5. Applying the changes to the building stock and the final energy consumption per m² of the whole building stock (per source)


/////////// a)  Resulting changes in the composition of the building stock
 
stockbatiment_BAU= max(0, stockbatiment_BAU_prev +... // Initial stock
- stockbatiment_prev.*(depreciationm2_demolish+depreciationm2_refurbish).*share_demolition(:,1) +... 	// Building outflow from depreciation
+ (deltastockbatiment + stockbatiment_prev.*(depreciationm2_demolish)) .* MSH_res(:,1) +... 				// new BAU building from construction
+ (stockbatiment_prev.*(depreciationm2_refurbish)) .* (MSH_res(:,1)./(MSH_res(:,1)+MSH_res(:,2))) +... 	// new BAU building from 'natural' renovation
- stockbatiment_BAU_prev .* taux_renov_suppl);																	// Building outflow from additional renovations; exclusively applied to the BAU stock, these renovations lead to SLE or VLE buildings only

stockbatiment_SLE= max(0, stockbatiment_SLE_prev +... // Initial stock
- stockbatiment_prev.*(depreciationm2_demolish+depreciationm2_refurbish).*share_demolition(:,2) +... 	// Building outflow from depreciation (only if no BAU buildings anymore)
+ (deltastockbatiment + stockbatiment_prev.*(depreciationm2_demolish)) .* MSH_res(:,2) +... 				// new SLE buildings from construction
+ (stockbatiment_prev.*(depreciationm2_refurbish)) .* (MSH_res(:,2)./(MSH_res(:,1)+MSH_res(:,2))) +...	// new SLE buildings from 'natural' renovation
+ stockbatiment_BAU_prev .* taux_renov_suppl .*(MSH_res(:,2)./(MSH_res(:,2)+MSH_res(:,3)))); 			// new SLE building from additional renovations

stockbatiment_VLE= max(0, stockbatiment_VLE_prev +... // Initial stock
- stockbatiment_prev.*(depreciationm2_demolish+depreciationm2_refurbish).*share_demolition(:,3) +... 	// Building outflow from depreciation (only if no BAU+SLE buildings anymore)
+ (deltastockbatiment + stockbatiment_prev.*(depreciationm2_demolish)) .* MSH_res(:,3) +... 				// new VLE buildings from construction
+ (stockbatiment_prev.*(depreciationm2_refurbish)) .* zeros(nb_regions,1) +...								// new VLE buildings from 'natural' renovation; set to zero as we consider that natural renovation can only lead to BAU or SLE, for technical reasons // TODO: could be an option/variant
+ stockbatiment_BAU_prev .* taux_renov_suppl .*(MSH_res(:,3)./(MSH_res(:,2)+MSH_res(:,3))));				// new VLE building from additional renovations
 
 

/////////// b) Resulting average final energy consumption of the whole building stock, by source

// Before, we compute the previous average final energy for adjusting traditional biomass
alphabuild_total_prev = alphaelecm2+alphaEtm2+alphaGazm2+alphaCoalm2;	

// Final energy consumption per m² per source	
alphaelecm2=(alphaelecm2_BAU.*stockbatiment_BAU+alphaelecm2_SLE.*stockbatiment_SLE+alphaelecm2_VLE.*stockbatiment_VLE)./stockbatiment;
alphaEtm2=(alphaEtm2_BAU.*stockbatiment_BAU+alphaEtm2_SLE.*stockbatiment_SLE+alphaEtm2_VLE.*stockbatiment_VLE)./stockbatiment;
alphaGazm2=(alphaGazm2_BAU.*stockbatiment_BAU+alphaGazm2_SLE.*stockbatiment_SLE+alphaGazm2_VLE.*stockbatiment_VLE)./stockbatiment;
alphaCoalm2=(alphaCoalm2_BAU.*stockbatiment_BAU+alphaCoalm2_SLE.*stockbatiment_SLE+alphaCoalm2_VLE.*stockbatiment_VLE)./stockbatiment;

// New final energy per m² for the four main sources, and evolution of Traditional_biomass_EJ which is used only in outputs
alphabuild_total = alphaelecm2+alphaEtm2+alphaGazm2+alphaCoalm2;

Traditional_biomass_EJ = Traditional_biomass_EJ .* alphabuild_total./alphabuild_total_prev;


/////////// c) Computing final variables

// Computing the volume of SLE and VLE buildings that have been created this year (can be different from the net variation)
deltastockbatiment_SLE=stockbatiment_SLE-stockbatiment_SLE_prev + stockbatiment_prev.*(depreciationm2_demolish).*share_demolition(:,2);
deltastockbatiment_VLE=stockbatiment_VLE-stockbatiment_VLE_prev + stockbatiment_prev.*(depreciationm2_demolish).*share_demolition(:,3);

// Estimating the whole costs of efficiency and fuel switching, which will be taken in charge by 'government' in nexus.productiveSectors.eeiCost.sce . TODO: could be improved to better represent the economic dynamics associated with changes in this sector
K_res_SLE=1/CRF_res*(CFuel_mean_res(:,ind_build_BAU)-CFuel_mean_res(:,ind_build_SLE));
K_res_VLE=1/CRF_res*(CFuel_mean_res(:,ind_build_BAU)-CFuel_mean_res(:,ind_build_VLE));
K_cost_res_SLE=max(deltastockbatiment_SLE.*K_res_SLE,0);
K_cost_res_VLE=max(deltastockbatiment_VLE.*K_res_VLE,0);

// Output variables
cum_BAU_sav(:,current_time_im)          =Cum_BAU;
cum_SLE_sav(:,current_time_im)          =Cum_SLE;
cum_VLE_sav(:,current_time_im)          =Cum_VLE;
