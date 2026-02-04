// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


//////////////////////////////////
// Intensive values
/////////////////////////////////

if ind_NLU >0
  ind_time = current_time_im;;
else
  ind_time = current_time_im+1;
end

// World values : sum over alll for extensive variables
// we avoid some intensive variables
for lineVAR =1:nbLines //[1:16 35:124 126:293 302:nbLines]
   VARname = list_output_str(lineVAR);
   if strindex( VARname, 'Price') == [] & strindex( VARname, 'Capital Cost') == [] & strindex( VARname, 'Efficiency') == [] & strindex( VARname, 'OM Cost|Fixed') == []
        outputs_temp(nbLines*reg+lineVAR,ind_time) = sum(outputs_temp(nbLines*[0:11] + lineVAR,ind_time));
   end
end


//////////////////////////////////
// Extensive values
/////////////////////////////////

// None for the moment
