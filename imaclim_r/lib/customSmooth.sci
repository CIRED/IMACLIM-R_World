// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function smoothened = customSmooth(y)

    n = size(y,2);
    smoothened = zeros(y);
    for time = 1:n
        smoothened(:,time) = mean(y(:,max(1,time-5):min(n,time+5)),2);
    end

endfunction
