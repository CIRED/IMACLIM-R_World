// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thomas Le-Gallic, Nicolas Graves, Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////Calibration of nexus.buildings //////////////////////////////
///////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////
// Rationale of the nexus building and content of the calibration file

// This nexus mainly consists in defining (1) changes in the residential floor space demand ; (2) changes in the share of each type of building (three types of buildings: BAU (business as usal), SLE (standard low energy), VLE (very low energy)); (3) implementing to additional "modules" to faster decarbonize the building stock.

// This calibration file is structured as follows:
// I. 	Initialisation of the variables and parameters related to changes in the housing stock
// II. 	Initialisation of the variables and parameters quantifying the energy efficiency of each type of building (by source)
// III. Initialisation of the variables and parameters related to changes in the composition of the housing stock
// IV. 	Initialisation of the variables and parameter related to the two additional modules.

/////////////////////////////////////////////////////////////////////////////////////////////
// I.  	PARAMETERS related to changes in the size of the housing stock
/////////////////////////////////////////////////////////////////////////////////////////////

// I.1. Initialisation of the residential floor area per region. Estimates are computed from Deetman et al, 2020 and the Energy Efficiency Indicators database (IEA, 2021). 
stockbatimentref=10^6*csvRead(path_buildings_stock+"building_stock.csv",'|',[],[],[],'',[1 2 12 2]);
surface_pc=ones(reg,1);

// I.2. Initialisation of the indexes for the three types of buildings
ind_build_BAU = 1;
ind_build_SLE = 2;
ind_build_VLE = 3;
ind_building_type = [ind_build_BAU, ind_build_SLE, ind_build_VLE];
nb_type_buildings = size(ind_building_type,"c");
ind_build_coal = 1;
ind_build_et = 2;
ind_build_gas = 3;
ind_build_elec = 4;
ind_build_ener = [ind_build_coal, ind_build_et, ind_build_gas, ind_build_elec];
nb_building_ener = size(ind_build_ener,"c");



// I.3. Definition of the parameters framing the pace and range of growth of the housing stock size, per region

// Trend-based variant, based on data analysis (data from IEA - Energy Efficiency Indicators) - it led with V1 to [78;71;46;43;45;49;32;40;32;36;39;43] in 2100 when testing with a standard baseline (productivity growth consistent with SSP2). In 2050: [73;;64;42;39;35;43;23;33;26;24;31;31]
if style_dev_res == 0 
    asymptote_surface_pc=[80;75;50;50;50;50;35;50;50;40;40;50]; // = asymptote (m²/cap)
	mult_surface_pc_ini=[2;2;1;0.6;2;0.4;0.6;1;0.3;1.2;0.7;1.4]; // = some kind of income elasticities, indicating how sentitive the need for new building area is to income growth.

// "Increasing inequalities" variant (between countries) - with the same test, it led to [90;87;61;48;66;69;19;42;43;12;22;25] in 2100, with slow increase in developing countries. In 2050: [86;77;50;41;51;59;14;35;31;10;;15;20].
elseif style_dev_res == 1 
    asymptote_surface_pc=[90;90;70;70;70;70;35;50;70;35;35;50];
	mult_surface_pc_ini=[4.1;2.7;1.2;0.2;3.0;0.5;0.2;1.2;0.4;0.2;0.2;0.4];

// "Rebalancing and convergence" variant (between countries) - with the same test, it led to [70;59;42;45;33;45;44;41;43;43;45;41] in 2100, including quite optimistic assumptions regarding the construction pace in developing countries. In 2050: [66;55;40;44;27;45;36;35;37;30;41;31].
elseif style_dev_res == 2	 
    asymptote_surface_pc=[75;65;45;45;45;45;45;45;45;45;45;45];
	mult_surface_pc_ini=[1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.5;1.0;1.5;1.5;1.5];
end

//These two lines are useless, but kept as a comment if someone is looking for these variables with the old name.
//asymptote_surface_pc=asp_cff; 
//mult_surface_pc_ini=msp_cff;

// I.4. Depreciation of the housing stock
// Each year, a small share of the stock is demolish (and will be replaced by new construction), and another share has to be refurbish. NB: eventually, the two operations have the same consequences in our modelling framework.
depreciationm2_demolish=[1/150; 1/150; 1/150; 1/150; 1/100; 1/100; 1/100; 1/100; 1/100; 1/100; 1/100; 1/100];
depreciationm2_refurbish = 1/40*ones(nb_regions,1);

share_demolition = [ones(nb_regions,1) zeros(nb_regions,2)];



/////////////////////////////////////////////////////////////////////////////////////////////
// II. 	PARAMETERS related to the energy efficiency
/////////////////////////////////////////////////////////////////////////////////////////////

//II.0 Traditional Biomass : for output only

//Traditional_biomass_EJ = [4.47200, 1.73000, 5.63900, 0, 2.75200, 7.56700, 4.00100, 3.00200, 0, 7.89875, 15.87100-7.56700-4.00100, 5.65200-3.00200];
Traditional_biomass_EJ = [0.15; 0.04; 1.44; 0.04; 0.12; 7.56700; 4.00100; 3.00200; 0; 7.89875; 15.87100-7.56700-4.00100; 5.65200-3.00200]; // Previous estimates put us well ahead of our partners for the sector as a whole (+15EJ/year). We have chosen here to retain the estimates used in IMAGE for Northern countries. In addition, we don't keep it constant on the whole period, see of nexus buildings.

//Traditional_biomass_EJ(4) = 45.00000 - sum(Traditional_biomass_EJ);

//II.1. Defining consistent values of energy efficiency of the existing residential stock at base year
// Defined as the entire direct energy consumption of households, except for ET where the specific direct energy demand for transport is deducted. All domestic usages are thus aggregated and embedded in this consumption per m².
alphaelecm2ref = DFref(:,indice_elec)./stockbatimentref;
alphaEtm2ref = (DFref(:,indice_Et)-DF_HHtransport(:,indice_Et))./stockbatimentref;
alphaCoalm2ref = DFref(:,indice_coal)./stockbatimentref;
alphaGazm2ref = DFref(:,indice_gaz)./stockbatimentref;

alphaelecm2 = alphaelecm2ref;
alphaEtm2 = alphaEtm2ref;
alphaCoalm2 = alphaCoalm2ref;
alphaGazm2 = alphaGazm2ref;

//II.2. Energy consumption by type of building
// a) Energy consumption of BAU buildings - exogenous trajectories built from IEA projections until 2030 (see also revision 29305 - F4=facteur4) TODO: could be updated
alphaelecm2_IEA=csvRead(path_buildings_cons+"alphaElecm2.2030_trend.csv",'|',[],[],[],'/\/\//');
alphaCoalm2_IEA=csvRead(path_buildings_cons+"alphaCoalm2.2030_trend.csv",'|',[],[],[],'/\/\//');
alphaEtm2_IEA=csvRead(path_buildings_cons+"alphaEtm2.2030_trend.csv",'|',[],[],[],'/\/\//');
alphaGazm2_IEA=csvRead(path_buildings_cons+"alphaGazm2.2030_trend.csv",'|',[],[],[],'/\/\//');

size_alphaelecm2_IEA=size(alphaelecm2_IEA);

// normalize to the base_year
alphaelecm2_IEA=divide(alphaelecm2_IEA, (alphaelecm2_IEA(:,base_year_simulation-2000-1)*ones(1,size(alphaelecm2_IEA,'c'))), 1);
alphaCoalm2_IEA=divide(alphaCoalm2_IEA, (alphaCoalm2_IEA(:,base_year_simulation-2000-1)*ones(1,size(alphaCoalm2_IEA,'c'))), 1);
alphaEtm2_IEA=divide(alphaEtm2_IEA, (alphaEtm2_IEA(:,base_year_simulation-2000-1)*ones(1,size(alphaEtm2_IEA,'c'))), 1);
alphaGazm2_IEA=divide(alphaGazm2_IEA, (alphaGazm2_IEA(:,base_year_simulation-2000-1)*ones(1,size(alphaGazm2_IEA,'c'))), 1);

// truncate so values correspond to 2014 baseyear
alphaelecm2_IEA=alphaelecm2_IEA(:,base_year_simulation-2000:TimeHorizon+base_year_simulation-2001);
alphaCoalm2_IEA=alphaCoalm2_IEA(:,base_year_simulation-2000:TimeHorizon+base_year_simulation-2001);
alphaEtm2_IEA=alphaEtm2_IEA(:,base_year_simulation-2000:TimeHorizon+base_year_simulation-2001);
alphaGazm2_IEA=alphaGazm2_IEA(:,base_year_simulation-2000:TimeHorizon+base_year_simulation-2001);

// b) Energy consumption of SLE buildings      // NB: could be adjusted to regions?
// By convention, the energy efficiency is fixed to 50kWh/m²/year, 80% elec, 20% gas (~ corresponding to some extent to some European standards for low energy houses, BBC or Minergie-A ; even if it depends on climate and countries). It accounts for the following end-uses:  space heating and cooling, lighting and water heating
// For order of magnitude, from IEA energy efficiency indicators for 2014 (France / Germany / USA): 124/133/146kWh/m² (final energy) for space heating and cooling, lighting and water heating; 37/30/42kWh/m² for residential appliances and cooking (even if m² is not the most relevant functionnal unit for these end-use).
alphaelecm2_SLE_sh_min = 0.4;
alphaelecm2_SLE_sh_max = 1;
alphaelecm2_SLE_sh_init = 0.8;
alphaelecm2_SLE_sh = alphaelecm2_SLE_sh_init;
// NB: we add here a fixed amount of energy for appliances and cooking, reduced compared to 2014 values, to consider an efficiency improvement. The implicit assumption is that the efficiency improvement in these end-uses follows improvements in the other end-uses. //NB2: the division by 2.58 is due to the fact that for these end-uses, the norm of 50kWh/m²/year is expressed in primary energy. By convention, for electricity we use this coefficient to aknowledge the corresponding maximum amount of final energy.
build_SLE_ener_cons = (50/(11630*10^6))*ones(reg,1);
build_SLE_ener_cons_fix = (20/(11630*10^6))*ones(reg,1); 
coef_primary2final_build = 2.58;

alphaelecm2_SLE = alphaelecm2_SLE_sh .* build_SLE_ener_cons / coef_primary2final_build + build_SLE_ener_cons_fix;
alphaGazm2_SLE 	= (1-alphaelecm2_SLE_sh) .* build_SLE_ener_cons;
alphaEtm2_SLE = zeros(nb_regions,1);
alphaCoalm2_SLE	= zeros(nb_regions,1);

// c) Energy consumption of VLE buildings
// By convention, the energy efficiency is fixed to 15kWh/m²/year (corresponding to European standards for passive houses)
alphaelecm2_VLE_sh_min = 0.5;
alphaelecm2_VLE_sh_max = 1;
alphaelecm2_VLE_sh_init = alphaelecm2_VLE_sh_max;
alphaelecm2_VLE_sh = alphaelecm2_VLE_sh_init;
// NB: we add here a fixed amount of energy for appliances and cooking, reduced compared to 2014 values, to consider an efficiency improvement. The implicit assumption is that the efficiency improvement in these end-uses follows improvements in the other end-uses. //NB2: the division by 2.58 is due to the fact that for these end-uses, the norm of 15kWh/m²/year is expressed in primary energy. By convention, for electricity we use this coefficient to aknowledge the corresponding maximum amount of final energy.
build_VLE_ener_cons = (15/(11630*10^6))*ones(reg,1);
build_VLE_ener_cons_fix = (15/(11630*10^6))*ones(reg,1);

alphaelecm2_VLE = alphaelecm2_VLE_sh .* build_VLE_ener_cons / coef_primary2final_build + build_VLE_ener_cons_fix;
alphaGazm2_VLE 	= (1-alphaelecm2_VLE_sh) .* build_VLE_ener_cons;
alphaEtm2_VLE		= zeros(nb_regions,1);
alphaCoalm2_VLE	= zeros(nb_regions,1);


/////////////////////////////////////////////////////////////////////////////////////////////
// III.	PARAMETERS related to changes in the composition of the housing stock
/////////////////////////////////////////////////////////////////////////////////////////////

// III.1. Initial share and stocks by building type at the base year
share_BAU_baseyear = 1; // by convention
share_SLE_baseyear = 0;
share_VLE_baseyear = 0;

stockbatiment_BAU=stockbatimentref*share_BAU_baseyear;
stockbatiment_SLE=stockbatimentref*share_SLE_baseyear;
stockbatiment_VLE=stockbatimentref*share_VLE_baseyear;

//Initialisation of cumulative stock variables for the learning rate functions
    Cum_BAU_ref = stockbatimentref * share_BAU_baseyear; // TODO: to be symplified into one variable CUM_res?
	Cum_SLE_ref = stockbatimentref * max(share_SLE_baseyear,0.01);
	Cum_VLE_ref = stockbatimentref * max(share_VLE_baseyear,0.01);
	Cum_BAU = Cum_BAU_ref;
    Cum_SLE = Cum_SLE_ref;
	Cum_VLE = Cum_VLE_ref;

// III.2. Parameters used in the logit function

var_hom_res=5*ones(nb_regions,1); //Heterogeneity parameter used in the logit function of technology choices. A high value means low heterogeneity, i.e., cheaper technologies take most of the market share; a low value means faster diffusion of new technologies, but a lower maximum share - note that for cars, other models use values in the range 5-10
Life_time_res=35; // residential depreciation period taken into account in investment decisions // Note that we could distinguish here renovation (30 years) and construction (40 years as assumed by Ürge-Vorsatz et al, 2020
disc_res=0.03; // discount rate considered for this nexus - the same as assumed by Ürge-Vorsatz et al, 2020 (fig. 8)
LR_ITC_res = [0.00 ; 0.08 ; 0.10]; // Learning rate for each type of building. The higher the value is, the faster costs will decrease. By convention, no improvement related to the cost of BAU constructions (however, the code would be sensitive to an alternative value)

// Investment costs of construction / renovation - in M$/m². Additional investment in each of the technologies compared to BAU. Data on the cost of conserved energy by retrofitting can be found in  Ürge-Vorsatz et al, 2020, fig. 8 (reproduced from Lucon et al, 2014 = IPCC report, buildings chapter). For a 80% saving, a range of costs from ~0.02 to 0.75$/kWh/year is found), showing how hard it is to find convergent values (as also found in the review, including for passive house). So it would mean from 4 to 150$/m² for SLE when reducing from 250kWh/m²/y to 50kWh/m²/y. Further research could be performed to make these parametrisation more robust (e.g. see https://www.mdpi.com/1996-1073/15/3/1009/htm)
CINV_res_nexus_ref=zeros(nb_regions,nb_type_buildings);
CINV_res_nexus_ref(:,ind_build_BAU)	=	0.0000 * ones(nb_regions,1);
CINV_res_nexus_ref(:,ind_build_SLE) = 	0.0006 * ones(nb_regions,1);
CINV_res_nexus_ref(:,ind_build_VLE) = 	0.0010 * ones(nb_regions,1);

// Min additional investment costs for each type of building
A_CINV_res_ITC_ref = ones(nb_regions,nb_type_buildings); // Sensitivity analysis could be conducted, variants could be added to the code to embed optimistic/pessimistic assumptions.
A_CINV_res_ITC_ref(:,ind_build_BAU) = 0.0000 * A_CINV_res_ITC_ref(:,ind_build_BAU);
A_CINV_res_ITC_ref(:,ind_build_SLE) = 0.0002 * A_CINV_res_ITC_ref(:,ind_build_SLE);
A_CINV_res_ITC_ref(:,ind_build_VLE) = 0.0002 * A_CINV_res_ITC_ref(:,ind_build_VLE);



/////////////////////////////////////////////////////////////////////////////////////////////
// IV.	PARAMETERS related to the two additional modules
/////////////////////////////////////////////////////////////////////////////////////////////

// IV.1. Fuel switching module
// This module leads to move away from liquid fossil fuels in residential if certain oil prices are reached

// Three variants are defined: in the standard one, the switch is triggered by a pArmDF_nexus(ET) of 1200$/toe (including taxes), and we move away from fossil fuels in 40 years. The triggering price is lower and the switching period shorter in the other variants.
//NB: these are ad hoc assumptions, not supported by data or previous studies. I guess it has been useful in some decarbonisation scenarios (history: comes from "scenar_Total_12"), but maybe it would be better to avoid its use as the logit function made the dynamic already sensitive to energy prices, or to support its use by a narrative where we consider policies implementing new norms (obligation to replace oil boilers), instead of supporting it by some technological optimism. In that case, these assumptions could be replaced by a year of start of this policy.

//EDIT 07/06/2023 - as it this assumption has a quite strong influence, we refined here its calibration (until a deeper improvement)

if indice_building_electri==1  // 
    i_decoupl_oil_res=10;// quick replacement
    p_decoupl_oil_res=1000;// NB: it is reached quite quickly in some regions (first decade(s))
	// Share sustituted from refined oil product to electricity during the fuel switching period, the other share is gas. Moved as part of the variants in V2, as it can be seen as a part of the decarbonisation package.
	share_elec_subsituted_m2 = 1; 	//In this variant, we consider this optimistic rate
elseif ind_buildingefficiency==1
i_decoupl_oil_res=25;// proposal, can be changed
    p_decoupl_oil_res=1100;// proposal, can be changed; NB: it is reached quite quickly in some regions (first decade(s))
	// Share sustituted from refined oil product to electricity during the fuel switching period, the other share is gas. Moved as part of the variants in V2, as it can be seen as a part of the decarbonisation package.
	share_elec_subsituted_m2 = 0.5; 	
else
    i_decoupl_oil_res=40;// proposal, can be changed // Navigate 3.5 : made less optimistic in baseline (20 to 25)
    p_decoupl_oil_res=1200;// proposal, can be changed // Navigate 3.5 : made less optimistic in baseline (1500 to 2500) // EDIT (21/09/2022): this change made the runs stop in 2017...
	// Share sustituted from refined oil product to electricity during the fuel switching period, the other share is gas
	share_elec_subsituted_m2 = 0.5; 
end

// We add an exogenous trend of conversion from gas to electricity in BAU buildings in the "fuel switching" option, as we didn't reach the electrification target (60% instead of 70%, and phase-out of non-clean fuels by 2050) in baseline (EDIT 27/06/2023)
if indice_building_electri==1  // 
    r_decoupl_gas_res=0.03; // ~ share of BAU gas building (2025 stock) converted to elec each year.
	r_decoupl_gas_com=0.015; // proxy rate of conversion to elec in commercial buildings
end	
    


// Efficiency gains assumed when substituting oil boilers by elec and gas appliances
efficiencyGain_elec_m2 = 0.2; //20% - quite optimistic value, considering well installed heat pump (previous value was 0.5, which was very optimistic, especially when this switch occur in e.g. 2050). Note we also apply a coefficient due to the fact that efficiency norms are expressed in primary energy, so we have to consider the conversion from primary sources to electricity (by convention, we use 2.58 in France for elec, 1.00 for the other fuels).
efficiencyGain_gas_m2 = 0.15; //15% - quite optimistic value, considering a change to a very efficient (e.g. gas condensing boiler) (previous value was 0.3)



// IV.2. Additional renovations module
// Inherited from the V1 nexus... I found it very parametric and simplified it a lot. I think we should adapt it to better reflect one type of policies aiming at encourage some additional renovations. TODO: to be discussed/implemented. TODO could be done for the navigate WP3 MIP.

// Previous parameters used to control the triggering of additional renovation.  
// Minimum and maximum share of insulation 
//max_insul_Norm_share = 0.7;
//min_insul_Norm_share = 0.4 * max_insul_Norm_share;
// Minimum and maximum share of insulation in renovated buildings
//min_insul_InRennov_shar = 0.2;
//max_insul_InRennov_shar = 0.7;
// Temporal exponential decrease of insulation norms. Parameter used to reflect an increasing propensity to trigger additional renovation with time.
//norm_ins_exponential_dec = 0.995;


// Tax level for maximum renovation rate. The effective rate is calculated as the ratio of the current carbon tax on this value (if additional renovation has been triggered)...

// ... multiplied by a maximum rate of supplementary revonation. This is probably the most important assumption of this module, as it drives the maximum renovation pace. //TODO: could be linked to the size/number of employees in the construction sector.
if ind_buildingefficiency == 1
tax_threshold_insulation = 0; // $/ton. For the "efficiency variant" in NAVIGATE task 3.5, we set it to zero to reach the max extra renovation rate in the "efficiency without tax" scenario. Should be adjusted afterward.
max_extra_renov_rate = 0.02; // Note that this is updated between 2020 and 2032 (in nexus.buildings) to reach the energy saving target from renovation in Navigate task 3.5
else
tax_threshold_insulation = 300; // $/ton
max_extra_renov_rate = 0.01;
end



/////////////////////////////
//Initialisation of residential renovations expenditures, which are currently charged to the governments (DG), see nexus.climatePolicy1.sce

renovation_expenditures=zeros(nb_regions,1);



//Save initialisation
//todo : this should be managed by save generic
cum_BAU_sav=zeros(nb_regions,TimeHorizon+1);
cum_SLE_sav=zeros(nb_regions,TimeHorizon+1);
cum_VLE_sav=zeros(nb_regions,TimeHorizon+1);
