// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Julie Rozenberg
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function leaderEv = PindEner2leaderEv(PindEner,region,sector,leaderEvRef)

PindEnerAEEI = pIndEnerRef(region,sector) * cff_PiE_aeei_lea;
PindEnerMax  = pIndEnerRef(region,sector) * cff_PiE_max_lea;

leaderEv_min  = 1- (1-leaderEvRef) * cff_min_lea;
leaderEv_AEEI = 1- (1-leaderEvRef) * cff_aeei_lea;

if PindEner(region,sector) < PindEnerAEEI
    curve = 1;
else
    if PindEner(region,sector) < pIndEnerRef(region,sector)
        curve = 2;
    else
        if PindEner(region,sector) < PindEnerMax
            curve = 3;
        else
            curve = 4;
        end
    end
end

select curve
case 1
    leaderEv = leaderEv_AEEI;
case 2
    leaderEv = leaderEvRef + ((PindEner(region,sector) - pIndEnerRef(region,sector))/(PindEnerAEEI - pIndEnerRef(region,sector))) * (leaderEv_AEEI - leaderEvRef);
case 3
    leaderEv = leaderEvRef + ((PindEner(region,sector) - pIndEnerRef(region,sector))/(PindEnerMax  - pIndEnerRef(region,sector))) * (leaderEv_min  - leaderEvRef);
case 4
    leaderEv = leaderEv_min;
end

endfunction;
