// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Julie Rozenberg, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function pind_ener = compPIndEner(pArmCI,pArmCIref,CI,CI0ref)
    energSec = 1:nbsecteurenergie;
    pind_ener=zeros(reg,sec);

    for k=1:reg
        for j=1:sec
            sum1 = max(sum(pArmCI(energSec,j,k)   .*CI(energSec,j,k)    ),0); //fixme
            sum2 = max(sum(pArmCIref(energSec,j,k).*CI(energSec,j,k)    ),0); //fixme
            sum3 = max(sum(pArmCI(energSec,j,k)   .*CI0ref(energSec,j,k)),0); //fixme
            sum4 = max(sum(pArmCIref(energSec,j,k).*CI0ref(energSec,j,k)),0); //fixme
            if (sum2>0)&(sum4>0) then
                pind_ener(k,j)=(sum1./sum2.*sum3./sum4)^(1/2);
            end
        end
    end

endfunction
