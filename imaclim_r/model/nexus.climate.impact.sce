/////// FROM EMISSIONS TO TEMPERATURE CHANGES ///////

if current_time_im ==1 
    sg_add(["Temp_change" "E_cum" "PtyLoss"]); 
    // AFOLU exogenous emissions
    E_AFOLU = csvread(path_climate_impact+"Emissions_AFOLU_SSP1.csv"); // IIASA SSP Public database: SSP1 Baseline|Emissions (unharmonized)|CO2|Land Use
    E_AFOLU = E_AFOLU*10^6;
//    if ind_pop==3
//        E_AFOLU = csvread(path_climate_impact+"Emissions_AFOLU_SSP3.csv"); // IIASA SSP Public database: SSP3 Baseline|Emissions (harmonized)|CO2|Land Use
//        E_AFOLU = E_AFOLU*10^6; // convert megatonnes CO2 into tonnes CO2
//    elseif ind_pop==1
//        E_AFOLU = csvread(path_climate_impact+"Emissions_AFOLU_SSP1.csv"); // IIASA SSP Public database: SSP1 Baseline|Emissions (unharmonized)|CO2|Land Use
//        E_AFOLU = E_AFOLU*10^6; // convert megatonnes CO2 into tonnes CO2
//    end
    //TCRE is regional Transient Climate Response to Emissions: mean surface temperature increase in °C per Tera tonne of carbon (not CO2!) emitted to the atmosphere
    TCRE_mean = csvread(path_climate_impact+"TCRE_mean.csv");
    TCRE_uncertainty = csvread(path_climate_impact+"TCRE_uncertainty.csv");
    if ind_clim_sensi == 0
        TCRE = TCRE_mean - TCRE_uncertainty; 
    elseif ind_clim_sensi == 1
        TCRE = TCRE_mean;
    elseif ind_clim_sensi == 2
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
	Temp_change_init = zeros(reg,TimeHorizon);
end

// 1 tera tonne of carbon equals 3.67*10^12 tonnes of CO2
TeraTonneCarbon_to_CO2 = 3.67*10^12; 

/// initialise cumulative emissions
if current_time_im==1 // year 2015
    E_cum = zeros(1,TimeHorizon); // global cumulative CO2 emissions
    // TODO, add sum(CO2_indus_process) which follows the emission intensity of the industrial sector from FF combustion?
    E_cum_2014 = 2.24396160*10^12;
	E_cum(1,1) = E_cum_2014 + sum(E_reg_use(:,:)) + E_AFOLU(1,current_time_im+1+13) + sum(emi_evitee);   // global cumulative CO2 emissions between 1751 and 2015 (both years included)
	E_cum_2002 = 1.79738230*10^12;
end

Temp_change_preindus(:,1) = TCRE.*E_cum_2002./TeraTonneCarbon_to_CO2; // °C of regional warming between 1751 and 2002    
if ind_impacts == 1 // scenario with climate change impacts
    // get temp change between 2002 and 2014 in order to deal with the loss of pty already observed for that period
    Temp_change_init(:,1) = TCRE.*E_cum_2014/TeraTonneCarbon_to_CO2 - Temp_change_preindus(:,1);
    // calculate productivity losses associated with a given temperature change
    for j=1:reg 
        if     Temp_change_init(j,current_time_im) <=1                   then PtyLoss_init(j,:) = (Temp_change_init(j,current_time_im) - floor(Temp_change_init(j,current_time_im))).*PtyLoss_coeff01(j,:); 
        elseif Temp_change_init(j,current_time_im)>1&Temp_change_init(j,current_time_im)<=2 then PtyLoss_init(j,:) = (Temp_change_init(j,current_time_im) - floor(Temp_change_init(j,current_time_im))).*PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        elseif Temp_change_init(j,current_time_im)>2&Temp_change_init(j,current_time_im)<=3 then PtyLoss_init(j,:) = (Temp_change_init(j,current_time_im) - floor(Temp_change_init(j,current_time_im))).*PtyLoss_coeff23(j,:) + PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        elseif Temp_change_init(j,current_time_im)>3&Temp_change_init(j,current_time_im)<=4 then PtyLoss_init(j,:) = (Temp_change_init(j,current_time_im) - floor(Temp_change_init(j,current_time_im))).*PtyLoss_coeff34(j,:) + PtyLoss_coeff23(j,:) + PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        elseif Temp_change_init(j,current_time_im)>4                     then PtyLoss_init(j,:) = (Temp_change_init(j,current_time_im) - floor(Temp_change_init(j,current_time_im))).*PtyLoss_coeff45(j,:) + PtyLoss_coeff34(j,:) + PtyLoss_coeff23(j,:) + PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        end
    end
end
	
Temp_change = zeros(reg,TimeHorizon); // °C of warming due to climate change from year 2014 onwards

/// keep track of cumulative emissions and calculate temperature changes
if current_time_im>1  // year 2016
    E_cum(1,current_time_im) = E_cum(1,current_time_im-1) + sum(E_reg_use(:,:)) + E_AFOLU(1,current_time_im+1+13) + sum(emi_evitee); // global cumulative CO2 emissions in year i is: stock of cumulative CO2 emissions from previous year + CO2 emissions in current year 
    Temp_change(:,current_time_im) = TCRE.*E_cum(1,current_time_im)/TeraTonneCarbon_to_CO2 - Temp_change_preindus(:,1); // °C of warming due to climate change from year 2000 onwards. Global cumulative CO2 emissions in year i are converted to carbon equivalents and multiplied by the TCRE to find the increase in global mean temperature in °C in year i compared to 1751. This number is subtracted by the °C of warming between 1751 and 2001. 
end

/////// FROM TEMPERATURE CHANGES TO PRODUCTIVITY LOSSES ///////

/// No labour productivity losses in a scenario without climate change impacts
if ind_impacts ==0 // scenario without climate change impacts 
   PtyLoss = zeros(reg,sec); // zero % of working hours lost due to increase in regional temperatures, by region and by sector 
end

/// Calculate labour productivity losses in a scenario with climate change impacts 
if ind_impacts ==1 // scenario with climate change impacts 
// calculate productivity losses associated with a given temperature change
    for j=1:reg 
        if     Temp_change(j,current_time_im) <=1                   then PtyLoss(j,:) = (Temp_change(j,current_time_im) - floor(Temp_change(j,current_time_im))).*PtyLoss_coeff01(j,:); 
        elseif Temp_change(j,current_time_im)>1&Temp_change(j,current_time_im)<=2 then PtyLoss(j,:) = (Temp_change(j,current_time_im) - floor(Temp_change(j,current_time_im))).*PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        elseif Temp_change(j,current_time_im)>2&Temp_change(j,current_time_im)<=3 then PtyLoss(j,:) = (Temp_change(j,current_time_im) - floor(Temp_change(j,current_time_im))).*PtyLoss_coeff23(j,:) + PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        elseif Temp_change(j,current_time_im)>3&Temp_change(j,current_time_im)<=4 then PtyLoss(j,:) = (Temp_change(j,current_time_im) - floor(Temp_change(j,current_time_im))).*PtyLoss_coeff34(j,:) + PtyLoss_coeff23(j,:) + PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        elseif Temp_change(j,current_time_im)>4                     then PtyLoss(j,:) = (Temp_change(j,current_time_im) - floor(Temp_change(j,current_time_im))).*PtyLoss_coeff45(j,:) + PtyLoss_coeff34(j,:) + PtyLoss_coeff23(j,:) + PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        end
		PtyLoss(j,:) = PtyLoss(j,:) - PtyLoss_init(j,:);	
    end    
	// ensure that PtyLoss is not > 1. 
	for j=1:reg
		for k=1:sec
			if PtyLoss(j,k)>1 then PtyLoss(j,k)=1;
			else PtyLoss(j,k)=PtyLoss(j,k) ;
			end
		end
	end
end
