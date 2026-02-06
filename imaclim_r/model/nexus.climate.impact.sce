// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////// FROM EMISSIONS TO TEMPERATURE CHANGES ///////
if ind_impacts == 1 // scenario with climate change impacts
    // get temp change between 2002 and 2014 in order to deal with the loss of pty already observed for that period
    // calculate productivity losses associated with a given temperature change
    for j=1:reg 
        if Temp_change_init(j,current_time_im) <=1
            PtyLoss_init(j,:) = (Temp_change_init(j,current_time_im) - floor(Temp_change_init(j,current_time_im))).*PtyLoss_coeff01(j,:); 
        elseif Temp_change_init(j,current_time_im) > 1 & Temp_change_init(j,current_time_im) <= 2
            PtyLoss_init(j,:) = (Temp_change_init(j,current_time_im) - floor(Temp_change_init(j,current_time_im))).*PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        elseif Temp_change_init(j,current_time_im) > 2 & Temp_change_init(j,current_time_im) <= 3
            PtyLoss_init(j,:) = (Temp_change_init(j,current_time_im) - floor(Temp_change_init(j,current_time_im))).*PtyLoss_coeff23(j,:) + PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        elseif Temp_change_init(j,current_time_im) > 3 & Temp_change_init(j,current_time_im) <= 4
            PtyLoss_init(j,:) = (Temp_change_init(j,current_time_im) - floor(Temp_change_init(j,current_time_im))).*PtyLoss_coeff34(j,:) + PtyLoss_coeff23(j,:) + PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        elseif Temp_change_init(j,current_time_im) > 4
            then PtyLoss_init(j,:) = (Temp_change_init(j,current_time_im) - floor(Temp_change_init(j,current_time_im))).*PtyLoss_coeff45(j,:) + PtyLoss_coeff34(j,:) + PtyLoss_coeff23(j,:) + PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        end
    end
end
	

/// keep track of cumulative emissions and calculate temperature changes
if current_time_im>1  // year 2016
    E_annual=sum(E_reg_use(:,:)) + E_AFOLU_impact(current_time_im+1+13) + sum(emi_evitee)+sum(CO2_indus_process)*10^6;
    E_cum(1,current_time_im) =  E_cum(1,current_time_im-1)+ E_annual; // global cumulative CO2 emissions in year i is: stock of cumulative CO2 emissions from previous year + CO2 emissions in current year 
    E_annual_GtC=E_annual/(10^9)*12/44;
    if ClimateModel=='TCRE'
        Temp_change(:,current_time_im) = TCRE.*E_cum(1,current_time_im)/TeraTonneCarbon_to_CO2 - Temp_change_preindus(:,1); // °C of warming due to climate change from year 2000 onwards. Global cumulative CO2 emissions in year i are converted to carbon equivalents and multiplied by the TCRE to find the increase in global mean temperature in °C in year i compared to 1751. This number is subtracted by the °C of warming between 1751 and 2001. 
    elseif ClimateModel=='FAIRv1.6.3'
        other_rf=RadForcingData(current_time_im);
        // Update temperature and get new restart values
        [Temp_global(current_time_im), restart_out_val] = update_temp(E_annual_GtC, other_rf, restart_out_val);
        Temp_change(:,current_time_im)=TCRE.*Temp_global(current_time_im)/TCRE_Global;
    end
end
Temp_current=Temp_global(current_time_im);
/////// FROM TEMPERATURE CHANGES TO PRODUCTIVITY LOSSES ///////

/// No labour productivity losses in a scenario without climate change impacts
if ind_impacts <>1  // scenario without climate change impacts on labor productivity
    PtyLoss = zeros(reg,sec); // zero % of working hours lost due to increase in regional temperatures, by region and by sector 
end

/// Calculate labour productivity losses if climate change affects labor productivity 
if ind_impacts ==1 // scenario with climate change impacts on labor productivity
    // calculate labour productivity losses associated with a given temperature change
    for j=1:reg 
        if Temp_change(j,current_time_im) <=1
            PtyLoss(j,:) = (Temp_change(j,current_time_im) - floor(Temp_change(j,current_time_im))).*PtyLoss_coeff01(j,:); 
        elseif Temp_change(j,current_time_im) > 1 & Temp_change(j,current_time_im) <= 2
            PtyLoss(j,:) = (Temp_change(j,current_time_im) - floor(Temp_change(j,current_time_im))).*PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        elseif Temp_change(j,current_time_im) > 2 & Temp_change(j,current_time_im) <= 3
            PtyLoss(j,:) = (Temp_change(j,current_time_im) - floor(Temp_change(j,current_time_im))).*PtyLoss_coeff23(j,:) + PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        elseif Temp_change(j,current_time_im) > 3  & Temp_change(j,current_time_im) <= 4
            PtyLoss(j,:) = (Temp_change(j,current_time_im) - floor(Temp_change(j,current_time_im))).*PtyLoss_coeff34(j,:) + PtyLoss_coeff23(j,:) + PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        elseif Temp_change(j,current_time_im) > 4
            PtyLoss(j,:) = (Temp_change(j,current_time_im) - floor(Temp_change(j,current_time_im))).*PtyLoss_coeff45(j,:) + PtyLoss_coeff34(j,:) + PtyLoss_coeff23(j,:) + PtyLoss_coeff12(j,:) + PtyLoss_coeff01(j,:); 
        end
        PtyLoss(j,:) = PtyLoss(j,:) - PtyLoss_init(j,:);	
    end    
    // ensure that PtyLoss is not > 1. 
    for j=1:reg
        for k=1:sec
            if PtyLoss(j,k)>1
                PtyLoss(j,k)=1;
            else
                PtyLoss(j,k)=PtyLoss(j,k) ;
            end
        end
    end
end

////// MACRO-ECONOMIC IMPACT - PRODUCTIVITY CHANNEL /////
// "A" is considered equivalent to TFP in Solow growth models - but the larger A, the lower the productivity.

damageLevel=zeros(reg,sec);
if current_time_im > start_year_policy-base_year_simulation
    if ind_impacts ==2 // COACCH damage function ()
        damageLevel=COACCH_R(coacchb1,coacchb2,Temp_current)-COACCH_R(coacchb1,coacchb2,Temp_global(start_year_policy-base_year_simulation));
        A=ones(reg,sec)+damageLevel.*(scaleShock_ref*ones(1,sec)); //Reduce productivity = Increase A !
        A_CI=A;
        if verbose>=1;disp("targeted damages = "+ damageLevel(:,indice_industries($)));end;
        if verbose>=1;disp("applied shock dA= "+damageLevel(:,indice_industries($)).*scaleShock_ref);end;//We display one sector only because the damages are uniform on non-energy sectors
    elseif ind_impacts ==3 // S.Dasgupta damage function on labour productivity
        prod_loss=Damage_Dasg(HE_damage_coeffs,LE_damage_coeffs,Temp_change(:,current_time_im)) ; //Initial_temp not needed ?
        prod_loss_ref=Damage_Dasg(HE_damage_coeffs,LE_damage_coeffs,Temp_change(:,start_year_policy-base_year_simulation)) ;
        PtyLoss=1-(1+prod_loss_ref)./(1+prod_loss); // In order to have: l = l_exo * (1+f(T))/(1+f(T0))
        if verbose>=1;disp('PtyLoss (industry)= '+PtyLoss(:,12));end;
    end
end
      
 
