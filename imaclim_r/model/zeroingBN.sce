// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

if current_time_im==1
    printf('\n');
    warning("    Zeroing basic needs over 20 years in this simulation");
end

bn           = bn           *max(0,(20-current_time_im)/19);
bnNM         = bnNM         *max(0,(20-current_time_im)/19);
bnautomobile = bnautomobile *max(0,(20-current_time_im)/19);
bnOT         = bnOT         *max(0,(20-current_time_im)/19);
bnair        = bnair        *max(0,(20-current_time_im)/19);
