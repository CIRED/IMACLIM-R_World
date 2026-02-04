// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function formattedVar = rgv(inputVar,T,dim1,dim2,dim3)
    if argn(2) == 4
        formattedVar = zeros(dim1,dim2,T);
        for i = 1:TimeHorizon
            formattedVar(:,:,i) = matrix(inputVar(:,i),dim1,dim2);
        end
    elseif argn(2) == 5
        formattedVar = zeros(dim1,dim2,dim3,T);
        for i = 1:T
            formattedVar(:,:,:,i) = matrix(inputVar(:,i),dim1,dim2,dim3);
        end
    end
endfunction

function out = divide(numerator,denominator,replacement)
    out = numerator ./ (denominator + %eps);
    out(denominator==0) = replacement;
endfunction
