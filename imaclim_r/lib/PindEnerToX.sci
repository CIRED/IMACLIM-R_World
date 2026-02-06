// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Julie Rozenberg, Florian Leblanc, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function X = PindEnerToX(PindEner,region,sector) // Correspond à la fonction précédente mais sans les paramètres cff_[..]
    PindEnerAEEI = pIndEnerRef(region,sector) / 2;
    PindEnerMax  = pIndEnerRef(region,sector) * 6;
    X_ref  = XRef(region,sector);
    X_AEEI = X_ref  * cff_X_aeei_lag;

    X_min  = X_ref * cff_X_min_lag;

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
        X = X_AEEI;
    case 2
        X = floor(X_ref + ((PindEner(region,sector) - pIndEnerRef(region,sector))/(PindEnerAEEI - pIndEnerRef(region,sector))) * (X_AEEI - X_ref));
    case 3
        X = floor(X_ref + ((PindEner(region,sector) - pIndEnerRef(region,sector))/(PindEnerMax  - pIndEnerRef(region,sector))) * (X_min  - X_ref));
    case 4
        X = X_min;
    end

endfunction;
//PindEnerRange = 0:0.1:15;
//for i = 1:length(PindEnerRange)
//    Xrange(i) = PindEnerToX(PindEnerRange(i));
//end

//plot(PindEnerRange,Xrange);
