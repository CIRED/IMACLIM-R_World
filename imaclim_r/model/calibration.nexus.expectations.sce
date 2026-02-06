// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////
//------------- CALIBRATION EXPECTATIONS  -----------------//
/////////////////////////////////////////////////////////////

expectations.alpha       =  1; // value between 0 and 1 corresponding to the degree of credibility of announced price signal
expectations.horizon.et  = 10; // temporal horizon for expectation in refined energy sector
expectations.horizon.eei = 10; // temporal horizon for expectation for eei computation
expectations.priceSignal = taxMKTexo(1:nbMKT,:); // remove the ununsed zeros in taxMKTexo to keep only real distinct markets
expectations.duration       = 50;

if ind_climpol_uncer>0
    expectations.horizon.signal = horizon_CT; // temporal horizon for forward looking expectations on carbon price schedule, set by scenario
    if ind_wait_n_see==1
        expectations.priceSignal = (1-proba_ndc_init)*taxMKTexo(1:nbMKT,:) + proba_ndc_init*taxMKTexo_wait_n_see //non-binary regime of beliefs pre tightening of policies
        if ~isdef("nb_year_dec_proba")
            nb_year_dec_proba = 5
        end
    end
end
// how the priceSignal is extrapolated after 2100
// v1 : cst signal after 2100
if typ_anticip == "priceSignal" | typ_anticip == "priceSignalonly" | typ_anticip == "priceSignal_2020"
    for s = TimeHorizon+1:TimeHorizon+1+expectations.duration
        expectations.priceSignal(:,s) = expectations.priceSignal(:,TimeHorizon+1);
    end
end

// in the priceSignalonly case, the carbon tax is set to zero in the economy, but still included in bottom-up investment choices (shadow price)
if typ_anticip == "priceSignalonly"
    taxMKTexo = zeros(1,1).*taxMKTexo;
end
expected = struct();
expected.taxCO2_DF = zeros(reg,sec,expectations.duration);
expected.taxCO2_DG = zeros(reg,sec,expectations.duration);
expected.taxCO2_DI = zeros(reg,sec,expectations.duration);
expected.taxCO2_CI = zeros(sec,sec,reg,expectations.duration);

expected.pArmDF        = zeros(reg,sec,    expectations.duration);
expected.pArmCI        = zeros(sec,sec,reg,expectations.duration);
expected.pArmCI_noCTax = zeros(sec,sec,reg,expectations.duration);
