// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// caution: expectations correspond to initial emissions coefficients
// to get actual emissions coefficients use coef_Q_CO2_CIref * sh_CCS_...
// therefore actual expected price will be sh_CCS * pArmCI_no_taxCO2 + (1-sh_CCS) * pArmCI_anticip_taxCO2

coef_Q_CO2_CI_noCCS = coef_Q_CO2_CIref;
//on traite le probleme de l'écran du à la séquestration
coef_Q_CO2_CI_noCCS(indice_coal,indice_elec,:) = coef_Q_CO2_CIref(indice_coal,indice_elec,:);
coef_Q_CO2_CI_noCCS(indice_gas ,indice_elec,:) = coef_Q_CO2_CIref(indice_gas,indice_elec,:);
