// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Florian Leblanc, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// Capacity expansion expectations
if current_time_im==1 //specific case for the first year
    tx_Q_prev=1+txCap-delta;
    tx_Q=1+txCap; // should also be 1+txCap-delta, but make the capital dynamic calibration difficult
else  // rest of the period
    tx_Q_prev=tx_Q;
    tx_Q=Q_noDI./Q_noDI_prev;
end

if %f //Case in which we extrapolate the current tendancy
    taux_Q_nexus = tx_Q;
else // Expectation on the mean term (3 eyar average)
    taux_Q_nexus =  sg_mean("tx_Q",3);
end

// for the first try of txCaptemp calibration, we fix expectation to the natural growth rate defined in txCapref
if auto_calibration_txCap<>"None" & first_try_autocalib==%t
    taux_Q_nexus = 1+txCapref-delta;
end
