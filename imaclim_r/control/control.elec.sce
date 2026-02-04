// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

disp([..
["LCC";regnames],..
["730_seq"   ; string(squeeze(round( LCC_730(:,24)*1000)))],..
["2190_seq"  ; string(squeeze(round(LCC_2190(:,24)*1000)))],..
["3650_seq"  ; string(squeeze(round(LCC_3650(:,24)*1000)))],..
["5110_seq"  ; string(squeeze(round(LCC_5110(:,24)*1000)))],..
["6570_seq"  ; string(squeeze(round(LCC_6570(:,24)*1000)))],..
["8030_seq"  ; string(squeeze(round(LCC_8030(:,24)*1000)))],..
["8760_seq"  ; string(squeeze(round(LCC_8760(:,24)*1000)))],..
["CCwoBT"    ; string(squeeze(round(CC_elec_i_1WoBioTax)))],..
["CCref"    ; string(squeeze(round(CC_elec_i_1_ref)))]     ,..
["pElec"    ; string(squeeze (round(p(:,elec))))]          ..
]);
//["730 "      ; string(squeeze(round( LCC_730(:,23)*1000)))],..
//["2190"      ; string(squeeze(round(LCC_2190(:,23)*1000)))],..
//["3650"      ; string(squeeze(round(LCC_3650(:,23)*1000)))],..
//["5110"      ; string(squeeze(round(LCC_5110(:,23)*1000)))],..
//["6570"      ; string(squeeze(round(LCC_6570(:,23)*1000)))],..
//["8030"      ; string(squeeze(round(LCC_8030(:,23)*1000)))],..
//["8760"      ; string(squeeze(round(LCC_8760(:,23)*1000)))],..

// was originally at the end of model/nexus.electricity.idealPark.sce
if i == 1 | i == 9 | i == 11
    temp = [["technos","CINV","lifetime","fixedCosts","varCosts","costAsymptote","efficiency","learning (add "+LR_ITC_elec_CCS+" for CCS)"];[elecnames,CINV_MW_nexus(1,:)',Life_time(1,:,100)',OM_cost_fixed_nexus(1,:)',OM_cost_var_nexus(1,:)',A_CINV_MW_ITC_ref',rho_elec_nexus(1,:)'*100,LR_ITC_elec'*100]];
    disp(temp);
    csvWrite(temp,"/home/ruben/Desktop/testElec"+i+".csv",";",".");
end
