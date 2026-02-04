// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================



function [ind_out] =  find_index_list( listy, elt2find)
    ind_out=0;
    ind = 0;
    for elt=listy
        ind = ind + 1;
        if elt==elt2find
            ind_out=ind;
        end
    end 
endfunction

