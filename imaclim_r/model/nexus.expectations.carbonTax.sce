//--------------------------------------------------------------------//
//----------------- CARBON TAX EXPECTATIONS---------------------------//
//--------------------------------------------------------------------//

//T.B. : this shall be removed since unused. will require some cleaning elsewhere
croyance_taxe  = zeros(reg,1); 
croyanceTaxMat = zeros(sec,sec,reg);
for k=1:reg
    if mean(taxCO2_CI(:,:,k))>=0
        croyance_taxe(k)      = 1;
        croyanceTaxMat(:,:,k) = 1;
    end
end

if ind_climpol_uncer
    if ind_fooled & current_time_im == 2020+duration_NDC+duration_fooled-base_year_simulation
        expectations.priceSignal = taxMKTexo_NZ;
        // extrapolating again the price signal
        if typ_anticip == "priceSignal" | typ_anticip == "priceSignalonly" | typ_anticip == "priceSignal_2020"
            for s = TimeHorizon+1:TimeHorizon+1+expectations.duration
                expectations.priceSignal(:,s) = expectations.priceSignal(:,TimeHorizon+1);
            end
        end
    end
end


if ind_nz
    if round((sum(emiLast(:)) + sum(emi_eviteeLast(:)))/1e6) < nz_target // don't harcode this?
        stop_carb_incr = 1;
    else 
        stop_carb_incr = 0;
    end
end 

if ind_nz
    if stop_carb_incr
        for s = 1:expectations.duration // when reached net zero, the price signal is kept constant
            exp_priceSignal_prev = expectations.priceSignal;
            expectations.priceSignal(:,current_time_im:(current_time_im+s)) = expectations.priceSignal(:,current_time_im);
        end
        taxMKTexo(1:nbMKT,:) = expectations.priceSignal(:,1:TimeHorizon+1); //updating the tax in the static so the plateau also applies to the consumption and production decisions
    end
end

//CO2 tax expectations depending on the regime of expectations
select typ_anticip
case "cst" 
    expected.tax = expectations.alpha .* repmat( taxMKT , 1 , expectations.duration ); // the current carbon price is projected over the expectations.duration time
case "priceSignal" 
    expected.tax = expectations.priceSignal(:,current_time_im:(current_time_im+expectations.duration)); // price signal is known at period 1
case "priceSignalonly" 
    expected.tax = expectations.priceSignal(:,current_time_im:(current_time_im+expectations.duration)); // price signal is known at period 1
case "priceSignal_2020" 
    if current_time_im<start_year_policy - base_year_simulation
        expected.tax = repmat( 0 , nbMKT , expectations.duration );
    else
        expected.tax = expectations.priceSignal(:,current_time_im:(current_time_im+expectations.duration)); // price signal is known at period 1
    end

else
    error ("unknown typ_antip:"+ typ_anticip)
end

if ind_climpol_uncer
    for s=expectations.horizon.signal:expectations.duration // constant expectated carbon price after the horizon
        expected.tax(:,s) = expected.tax(:,expectations.horizon.signal);
    end
end

// _ant variables
// ind_lindhal llows for regional weighting and convergence with weight_regional_tax
if ind_lindhal >=1 // T.B. : shall this ind_lindhal be removed?
  [ taxCO2_DF_ant , taxCO2_DG_ant , taxCO2_DI_ant , taxCO2_CI_ant , taxMKT_ant ] = dispatchTax( taxCO2_DF , taxCO2_DG , taxCO2_DI , taxCO2_CI , expected.tax(:,1), weight_regional_tax_prev) ; // for backward compatibility with old myopic system
else
  [ taxCO2_DF_ant , taxCO2_DG_ant , taxCO2_DI_ant , taxCO2_CI_ant , taxMKT_ant ] = dispatchTax( taxCO2_DF , taxCO2_DG , taxCO2_DI , taxCO2_CI , expected.tax(:,1)) ; // for backward compatibility with old myopic system
end

// expected CO2 taxes for armington prices expectations
for expectedYear = 1:expectations.duration
    if ind_lindhal >=1
        [ taxCO2_DF_temp , taxCO2_DG_temp , taxCO2_DI_temp , taxCO2_CI_temp ] = dispatchTax( taxCO2_DF , taxCO2_DG , taxCO2_DI , taxCO2_CI , expected.tax(:,expectedYear), weight_regional_tax_prev) ;
    else
        [ taxCO2_DF_temp , taxCO2_DG_temp , taxCO2_DI_temp , taxCO2_CI_temp ] = dispatchTax( taxCO2_DF , taxCO2_DG , taxCO2_DI , taxCO2_CI , expected.tax(:,expectedYear)) ;
    end
    expected.taxCO2_DF(:,:,expectedYear)   = taxCO2_DF_temp; 
    expected.taxCO2_DG(:,:,expectedYear)   = taxCO2_DG_temp; 
    expected.taxCO2_DI(:,:,expectedYear)   = taxCO2_DI_temp; 
    expected.taxCO2_CI(:,:,:,expectedYear) = taxCO2_CI_temp; 
end

if ind_nz
    if stop_carb_incr
        expectations.priceSignal(:,current_time_im+1:TimeHorizon+1) = exp_priceSignal_prev(:,current_time_im:TimeHorizon); //for next period, if the price were to increase, it would not jump to the expected value but start increasing smoothly
    end
end