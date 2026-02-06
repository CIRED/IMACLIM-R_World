// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function [new_delta]=wear_and_tears_capital_dep(delta,  charge, charge_threshold)
    // wear and tears add-hoc function to increase capital depreciation for a low charge
    delta_increase = -3*log(charge ./ charge_threshold) + 1;
    delta_increase = max(1, delta_increase);
    new_delta = delta .* delta_increase;
endfunction
