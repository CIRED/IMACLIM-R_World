// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Adrien Vogt-Schilb, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//tax on markets
taxMKT = zeros(nbMKT,1);

areEmisConstparam= zeros (nbMKT,1);
//objective indeed present in the equations from static
if is_bau & ind_climat <> 1 & ind_climat <> 2
    CO2_obj_MKTparam = %inf * ones (nbMKT,1)';
    CO2_obj_MKT =  %inf * ones(nbMKT,TimeHorizon+1);
else
    CO2_obj_MKTparam = CO2_obj_MKT(:,1);
    for hop=1:size(is_quota_MKT,"*")  //do NOT try to rewrite this loop
        areEmisConstparam(hop) = bool2s (is_quota_MKT(hop) &  1>=MKT_start_year(hop));
    end
end

is_taxexo_MKTparam=bool2s(is_taxexo_MKT);

// are_emis_decreasing = falses(CO2_obj_MKTparam);


////////////////////////////////////////////Taxe
taxCO2=zeros(nb_regions,nb_sectors);
taxCO2_DF=zeros(nb_regions,nb_sectors);
taxCO2_DG=zeros(nb_regions,nb_sectors);
taxCO2_DI=zeros(nb_regions,nb_sectors);
taxCO2_CI=zeros(nb_sectors,nb_sectors,nb_regions);

weight_regional_tax=ones(reg,1);
weight_ragional_tax_prev = weight_regional_tax;

// IPCC AR6 emission factors for coal, gas and refined oil - MtCO2 / toe
// Eggleston, H.S., Intergovernmental Panel on Climate Change, National Greenhouse Gas Inventories Programme, Chikyū Kankyō Senryaku Kenkyū Kikan, 2006. 2006 IPCC guidelines for national greenhouse gas inventories. // Table 2.2
coef_Q_CO2=[4114346.4999999995*ones(nb_regions,1),zeros(nb_regions,1),2348065.5*ones(nb_regions,1),2900551.5*ones(nb_regions,1),zeros(nb_regions,nb_sectors-4)];
coef_Q_CO2_ref=coef_Q_CO2;
coef_Q_CO2_DF=coef_Q_CO2;
coef_Q_CO2_DG=coef_Q_CO2;
coef_Q_CO2_DI=coef_Q_CO2;
coef_Q_CO2_CI=zeros(nb_sectors,nb_sectors,nb_regions);
for k=1:nb_regions
    coef_Q_CO2_CI(1:nbsecteurenergie,:,k)=coef_Q_CO2(k,1:nbsecteurenergie)'*ones(1,nb_sectors);
    coef_Q_CO2_CI(indice_oil,indice_oil,k)=coef_Q_CO2(1,indice_Et);
    coef_Q_CO2_CI(indice_oil,indice_elec,k)=coef_Q_CO2(1,indice_Et);
end

coef_Q_CO2_DFref=coef_Q_CO2;
coef_Q_CO2_DGref=coef_Q_CO2;
coef_Q_CO2_DIref=coef_Q_CO2;
coef_Q_CO2_CIref=zeros(nb_sectors,nb_sectors,nb_regions);
for k=1:nb_regions
    coef_Q_CO2_CIref(1:nbsecteurenergie,:,k)=coef_Q_CO2(k,1:nbsecteurenergie)'*ones(1,nb_sectors);
    coef_Q_CO2_CIref(indice_oil,indice_oil,k)=coef_Q_CO2(1,indice_Et);
    coef_Q_CO2_CIref(indice_oil,indice_elec,k)=coef_Q_CO2(1,indice_Et);
end

CCS_efficiency_industry = 1;//0.9;
coef_Q_CO2_Et_prod = coef_Q_CO2(:,indice_Et);
coef_Q_CO2_CI_wo_CCS=coef_Q_CO2_CIref;
coef_Q_CO2_CI_w_CCS= (1-CCS_efficiency_industry) * coef_Q_CO2_CIref;

emi_evitee = zeros(nb_regions,1);
emi_evitee_elec = zeros(nb_regions,1);

/////////////////////////////////////////////////////////
// Load exogenous histocial emissions trajectories
exo_CO2_indus_process = load_emissions_traj(path_PRIMAP+"CO2_industrial_processes__GtCO2_IMACLIM.csv", base_year_simulation) * giga2mega;
exo_CO2_agri_direct = load_emissions_traj(path_PRIMAP+"CO2_agriculture__GtCO2_IMACLIM.csv", base_year_simulation) * giga2mega;
exo_CO2_LUCCCF = load_emissions_traj(path_GCB+"National_LandUseChange_Carbon_Emissions_2022v10-OSCAR-normalized___million_tonnes_of_CO2_IMACLIM.csv", base_year_simulation);
exo_CO2_Resid = load_emissions_traj(path_Minx+"emissions_Buildings__Residential__CO2_GtCO2_IMACLIM__WLD.csv", base_year_simulation) * giga2mega;
exo_CO2_nonResid = load_emissions_traj(path_Minx+"emissions_Buildings__Non-residential__CO2_GtCO2_IMACLIM__WLD.csv", base_year_simulation) * giga2mega;
exo_CO2_Elec = load_emissions_traj(path_Minx+"emissions_Energysystems__Electricity&amp;heat__CO2_GtCO2_IMACLIM__WLD.csv", base_year_simulation) * giga2mega;
exo_CO2_Et_refining = load_emissions_traj(path_Minx+"emissions_Energysystems__Petroleumrefining__CO2_GtCO2_IMACLIM__WLD.csv", base_year_simulation) * giga2mega;
exo_CO2_OtherEnergy = load_emissions_traj(path_Minx+"emissions_Energysystems__Other_energysystems___CO2_GtCO2_IMACLIM__WLD.csv", base_year_simulation) * giga2mega + load_emissions_traj(path_Minx+"emissions_Energysystems__Oilandgasfugitiveemissions__CO2_GtCO2_IMACLIM__WLD.csv", base_year_simulation) * giga2mega + load_emissions_traj(path_Minx+"emissions_Energysystems__Coalminingfugitiveemissions__CO2_GtCO2_IMACLIM__WLD.csv", base_year_simulation) * giga2mega;
exo_CO2_Industry = load_emissions_traj(path_Minx+"emissions_Industry__TOTAL__CO2_GtCO2_IMACLIM__WLD.csv", base_year_simulation) * giga2mega;
exo_CO2_Transport_Dom = load_emissions_traj(path_Minx+"emissions_Transport__TOTAL__CO2_GtCO2_IMACLIM__WLD.csv", base_year_simulation) * giga2mega;
exo_CO2_Transport_Int = load_emissions_traj(path_Minx+"emissions_International_transport_GtCO2_IMACLIM.csv", base_year_simulation) * giga2mega;
exo_CO2_Transport = sum(exo_CO2_Transport_Int,'r') + exo_CO2_Transport_Dom;
exo_CO2_AFOLU = load_emissions_traj(path_Minx+"emissions_AFOLU__TOTAL__CO2_GtCO2_IMACLIM__WLD.csv", base_year_simulation) * giga2mega;

exo_CO2_ref = exo_CO2_Resid + exo_CO2_nonResid + exo_CO2_Elec + exo_CO2_Et_refining + exo_CO2_OtherEnergy + exo_CO2_Industry + exo_CO2_Transport + exo_CO2_AFOLU + sum(exo_CO2_LUCCCF(:,1:7),'r');
// NOTE exo_CO2_agri_direct ~= exo_CO2_AFOLU

// in the Baseline we don't report future emissions
// in policy scenarios, we assume there is no deforestation, nore agriculture emissions past the polciyd starting date
nb_year_tp = size(exo_CO2_agri_direct,'c');
missing_year = TimeHorizon+1-nb_year_tp;
if ~is_bau
    exo_CO2_agri_direct(:,(nb_year_tp+1):(nb_year_tp+missing_year)) = 0;
else
    exo_CO2_agri_direct(:,(nb_year_tp+1):(nb_year_tp+missing_year)) = %nan;
end

nb_year_tp = size(exo_CO2_LUCCCF,'c');
missing_year = TimeHorizon+1-nb_year_tp;
exo_CO2_LUCCCF(:,(nb_year_tp+1):(nb_year_tp+missing_year)) = 0;
// linear decrease from historical to start_year_strong_policy
//exo_CO2_LUCCCF(:,(nb_year_tp+1):(nb_year_tp+missing_year)) =0 * (~is_bau);
i_data = find(exo_CO2_LUCCCF(1,:)==0,1)-1;
exo_CO2_LUCCCF(:,i_data:i_year_strong_policy-1) = linspace( exo_CO2_LUCCCF(:,i_data), 0.95*exo_CO2_LUCCCF(:,6) , i_year_strong_policy-1-i_data+1);
exo_CO2_LUCCCF(:,i_year_strong_policy-1:(i_year_strong_policy-1+3)) = linspace( exo_CO2_LUCCCF(:,i_year_strong_policy-1), zeros(exo_CO2_LUCCCF(:,i_year_strong_policy-1)) , 4);
if is_bau
    exo_CO2_LUCCCF(:,(nb_year_tp+1):(nb_year_tp+missing_year)) = %nan;
end

//AFOLU exogenous emissions in SSP2 2.6 scenario (unit: MtCO2), excluding negative emissions from BECCS
// This include afforestation and is used if ind_exo_afforestation==1
if ind_exo_afforestation==1
    exo_CO2_AFOLU = zeros(TimeHorizon+1,1);
    if ~is_bau
        mat = csvRead(path_data_inequalities+".."+sep+"AFOLU_2015_2100.csv",'|',[],[],[],'/\/\//'); //2.6 scenario
        exo_CO2_AFOLU(2:$) = mat;
    else
        mat=csvRead(path_data_inequalities+".."+sep+"AFOLU_BAU_2015_2100.csv",'|',[],[],[],'/\/\//'); //BAU scenario
        exo_CO2_AFOLU(2:$) = mat;
    end
    E_AFOLU = exo_CO2_AFOLU(1) .* sum(E_reg_use(:,:),2)./sum(E_reg_use(:,:)); // AFOLU emissions are allocated pro-rata of E_reg_use
end

// CO2 emissions that are not taxed (mostly exogenous), but which has to be taken into account in the CO2 emission trajectoiry when set as an objective
if ind_exo_afforestation==1
    CO2_untaxed = (exo_CO2_indus_process(:,2) + exo_CO2_AFOLU(2) .* sum(E_reg_use(:,:),2)./sum(E_reg_use(:,:))) * 1e6;
else
    CO2_untaxed = (exo_CO2_agri_direct(:,2) + exo_CO2_LUCCCF(:,2) + exo_CO2_indus_process(:,2)) * 1e6;
end



