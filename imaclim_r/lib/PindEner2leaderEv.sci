// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Julie Rozenberg, Florian Leblanc, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function leaderEv = PindEner2leaderEv(PindEner,region,sector,leaderEvolution)

    PindEnerAEEI = pIndEnerRef(region,sector) * cff_PiE_aeei_lea;
    PindEnerMax  = pIndEnerRef(region,sector) * cff_PiE_max_lea;

    leaderEv_min  = 1- (1-leaderEvolution) * cff_min_lea;
    leaderEv_AEEI = 1- (1-leaderEvolution) * cff_aeei_lea;

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
        leaderEv = leaderEvolution + ((PindEner(region,sector) - pIndEnerRef(region,sector))/(PindEnerAEEI - pIndEnerRef(region,sector))) * (leaderEv_AEEI - leaderEvolution);
    case 3
        leaderEv = leaderEvolution + ((PindEner(region,sector) - pIndEnerRef(region,sector))/(PindEnerMax  - pIndEnerRef(region,sector))) * (leaderEv_min  - leaderEvolution);
    case 4
        leaderEv = leaderEv_min;
    end

endfunction;
