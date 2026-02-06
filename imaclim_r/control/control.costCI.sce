// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

disp([..
    ["reg";regnames],..
    ["costCI"     ; string(squeeze(sum(CI(:,elec,:) .* pArmCI          (:,elec,:),1)))],..
    ["costsCI_nT" ; string(squeeze(sum(CI(:,elec,:) .* pArmCI_no_taxCO2(:,elec,:),1)))],..
]');
