// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function []=pass_3d_matrix(name,len)
    temp_hypermat = eval(name);
    for k=1:len,
      the_2d_matrix = temp_hypermat(:,:,k);
      [nr,nc] = size(the_2d_matrix);
    //  disp (k,nr,nc,the_2d_matrix)
      call ('fill_2d_matrix',k,1,'i',nr,2,'i',nc,3,'i',the_2d_matrix,4,'d',...
      name,5,'c','out',[1,1],6,'i');
    end
    //call ('fill_2d_matrix',nr,1,'i',nc,2,'i',the_2d_matrix,3,'d',...
    //  set_2d_matrix_name,4,'c','out',[1,1],1,'i')
endfunction


function updateCparams

    for mat=hyp_params'
        pass_3d_matrix(mat,reg);
    end

    fort(set_function);
    
endfunction


function unlink(call_table)

    if ~isdef("call_table")
        call_table = ["allocate_matrix","set_param","set_paramX","economyC","economyXC","fill_2d_matrix"];
    end

    for fun_name = call_table
        [bool id_truc] = c_link(fun_name);
         if bool
            ulink (id_truc);
        end
    end
    
    clear bool id_truc
   
endfunction





