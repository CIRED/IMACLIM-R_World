// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function unlink(call_table)

    for fun_name = call_table
        [bool id_truc] = c_link(fun_name);
        if bool
            ulink (id_truc);
        end
    end
    
    clear bool id_truc
   
endfunction





