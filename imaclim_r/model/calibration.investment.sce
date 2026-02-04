// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

investment = struct();
investment.invAllocated = zeros(reg,sec,TimeHorizon);
investment.partInvFin   = zeros(reg,sec,TimeHorizon);
investment.sumInvDem    = zeros(reg,TimeHorizon);
investment.sumInvAll    = zeros(reg,TimeHorizon);
investment.invDem       = zeros(reg,sec,TimeHorizon);
