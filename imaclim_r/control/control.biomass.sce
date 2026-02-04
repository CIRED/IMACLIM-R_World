// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

disp([..
["reg";regnames],..
["CI_elEl"       ; string(round(100*squeeze(CI(elec,elec,:)))/100)],..
["CI_agEl"       ; string(round(100*squeeze(CI(agri,elec,:)))/100)],..
["coefCO2_elEl"  ; string(round(100*squeeze(coef_Q_CO2_CI(elec,elec,:)))/100)],..
["pArmCIElEl"    ; string(ceil(squeeze(pArmCI(elec,elec,:))))],..
["shCCS"         ; string(ceil(sh_CCS_biomass_Q_biomass*100))],..
["pBIGCC"        ; string(p_biom_real_agg_withTax(:,1))],..
["pBIGCCS"       ; string(p_biom_real_agg_withTax(:,2))],..
["prodBIGCC"     ; string(ceil(prod_elec_techno(:,technoBiomass(1))/1e3))],..
["prodBIGCCS"    ; string(ceil(prod_elec_techno(:,technoBiomass(2))/1e3))],..
["qBiomExaJ"     ; string(qBiomExaJ(:,1))],..
["qBiomExaJS"    ; string(qBiomExaJ(:,2))],..
["CinvBIGCC"     ; string(ceil(CINV(:,technoBiomass(1))))],..
["CinvBIGCCS"    ; string(ceil(CINV(:,technoBiomass(2))))],..
["k*CFuel"       ; string(ceil(CFuel_moy(:,technoBiomass(1))*1000))],..
["k*CFuelS"      ; string(ceil(CFuel_moy(:,technoBiomass(2))*1000))]..
]);

//clf;
//if isdef("E_reg_use")
//    emTot(i) = sum(E_reg_use)/1e9;
////    subplot(1,2,1)
//    plot(sgv("taxMKT")*1e6/10,'b*-');
//    plot(emTot,'r*-');
//    legend("TAX (x10$/tCO2)","totalEmiss(GtCO2)");
//    xgrid();
//end
