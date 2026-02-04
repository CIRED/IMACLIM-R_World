// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

disp([..
["ECO2",secnames(1:5)',"sum";..
[regnames],..
[string([round(10 * E_CO2(:,1:5)/1e6),10 * sum(E_CO2(:,1:5)/1e6,2)]/10)]..
]]);
