// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function numberofpattern = count_str_pattern(filepath, pattern)
    numberofpattern = 0;
    txt = mgetl( filepath);
    for ii=1:size(txt,"r")
        if strindex( txt(ii), pattern) <> [];
            numberofpattern = numberofpattern+1;
        end
    end

endfunction

