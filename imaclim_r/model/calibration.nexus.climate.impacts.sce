// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Aurélie Méjean, Florian Leblanc, Yann Gaucher
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

sg_add(["Temp_change" "E_annual_GtC" "Temp_current" "E_cum" "PtyLoss" "damageLevel"]); 
// AFOLU exogenous emissions
E_AFOLU_impact = csvread(path_climate_impact+"Emissions_AFOLU_SSP2.csv"); // IIASA SSP Public database: SSP2 Baseline|Emissions (unharmonized)|CO2|Land Use
E_AFOLU_impact = E_AFOLU_impact*10^6;
RadForcingData = csvRead(path_climate_impact+'nonCO2forcing' + rcp + '.csv');
Temp_change = zeros(reg,TimeHorizon); // °C of warming due to climate change from year 2014 onwards
Tmp_change_init = zeros(reg,TimeHorizon);
Temp_global=zeros(TimeHorizon);
Temp_current=zeros(1);//needed for sg add

//TCRE is regional Transient Climate Response to Emissions: mean surface temperature increase in °C per Tera tonne of carbon (not CO2!) emitted to the atmosphere
TCRE_mean = csvread(path_climate_impact+"TCRE_mean.csv");
TCRE_uncertainty = csvread(path_climate_impact+"TCRE_uncertainty.csv");
if ind_clim_sensi == 0 // TODO: vérifier cohérence avec fair
    TCRE = TCRE_mean - TCRE_uncertainty; 
elseif ind_clim_sensi == 1
    TCRE = TCRE_mean;
elseif ind_clim_sensi == 2// TODO: vérifier cohérence avec fair
    TCRE = TCRE_mean + TCRE_uncertainty; 
end

if ind_impacts ==1 // scenario with climate change impacts 
    // load productivity loss per degree of warming coefficients
    PtyLoss_coeff01 = csvread(path_climate_impact+"PtyLoss_coeff01.csv"); // extract productivity loss coefficients: % of working hours lost due to 0-1°C warming in a given sector and region
    PtyLoss_coeff12 = csvread(path_climate_impact+"PtyLoss_coeff12.csv"); // same, for 1-2°C warming
    PtyLoss_coeff23 = csvread(path_climate_impact+"PtyLoss_coeff23.csv"); // same, for 2-3°C warming
    PtyLoss_coeff34 = csvread(path_climate_impact+"PtyLoss_coeff34.csv"); // same, for 3-4°C warming
    PtyLoss_coeff45 = csvread(path_climate_impact+"PtyLoss_coeff45.csv"); // same, for 4-5°C warming
end

if ClimateModel=='FAIRv1.6.3'
    TCRE_Global=1.74; //°C per TtC
    // Define the arrays for restart_in
    R_minus1 = [57.56949954, 42.20370797, 17.74611517,  3.64835215];
    T_j_minus1 = [0.10818982, 1.02005595];   
    
    C_acc_minus1 = 300.6782625897405;                            
    E_minus1 = 10.95918;                                          
    time_scale_sf = [0.50877646];                                
    // Combine into a list to represent restart_in
    restart_in = list(R_minus1, T_j_minus1, C_acc_minus1, E_minus1, time_scale_sf);
    // Initialize arrays to store outputs
    C_acc = zeros(1, TimeHorizon); // Cumulative airborne carbon anomaly
    C = zeros(1, TimeHorizon); // CO2 concentrations
    restart_out_val = restart_in; // Initial restart values
end


// 1 tera tonne of carbon equals 3.67*10^12 tonnes of CO2
TeraTonneCarbon_to_CO2 = 3.67*10^12; 

/// initialise cumulative emissions
E_cum = zeros(1,TimeHorizon); // global cumulative CO2 emissions
// TODO, add sum(CO2_indus_process) which follows the emission intensity of the industrial sector from FF combustion?
E_cum_2014 = 2.24396160*10^12;
E_cum(1,1) = E_cum_2014;   // global cumulative CO2 emissions between 1751 and 2014 (both years included)
E_annual_GtC=11.17; // fossil fuel + LUC emissions in 2015 (GCP 2024)
E_cum_2002 = 1.79738230*10^12;
if ClimateModel=='FAIRv1.6.3'
    other_rf=RadForcingData(1);
    // Update temperature and get new restart values
    [Temp_global(1), restart_out_val] = update_temp(E_annual_GtC, other_rf, restart_out_val);
    Temp_change(:,1)=TCRE.*Temp_global(1)/TCRE_Global;
    Temp_change_init(:,1)=TCRE.*Temp_global(1)/TCRE_Global;
end


if ClimateModel=='TCRE'
    Temp_change_preindus(:,1) = TCRE.*E_cum_2002./TeraTonneCarbon_to_CO2; // °C of regional warming between 1751 and 2002  
    Temp_change_init(:,1) = TCRE.*E_cum_2014/TeraTonneCarbon_to_CO2 - Temp_change_preindus(:,1);
end

if ~isdef('quantile_damage')// Can be changed for sensitivity analysis. By default, 50th percentile with SLR adaptation.
    quantile_damage=21;
end
scaleShock_ref=ones(reg,1);
fullparams=csvread(path_climate_impact+"coacch_params_R12.csv");
coacchb1=fullparams(:,quantile_damage);
coacchb2=fullparams(:,quantile_damage+1);
HE_damage_coeffs=csvread(path_climate_impact+"high_exposure_sectors.csv");
LE_damage_coeffs=csvread(path_climate_impact+"low_exposure_sectors.csv");
Temp_TCRE_data=csvread(path_climate_impact+"MeanT_TCRE_R12.csv");
Initial_Temp=Temp_TCRE_data(:,1);