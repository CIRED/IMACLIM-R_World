// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


//////////////////////////////////
// Extensive values
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

// set some intensive world variables to nan to avoid the previous sum

//  World values : exceptions for intensive variables

lineVAR = find_index_list( list_output_str, "Price|Carbon"); // 
weightLine = find_index_list( list_output_str, "Emissions|CO2|Energy");
outputs_temp(nbLines*reg+lineVAR,ind_time) = divide( sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time) .* outputs_temp(nbLines*[0:11] + lineVAR,ind_time)), sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time)), 0);

// =============================================== //

execstr(" outputs_"+ETUDE+" = outputs_temp;");
mkcsv( 'outputs_'+ETUDE );


//check lentght of list
//and output headers corresponding to the outputs*.tsv file
if current_time_im==1
    if ind_NLU > 0
        nb_compare = size(list_output_str) - nbvar_NLU_driver;
    else
        nb_compare = size(list_output_str);
    end
    if nbLines <> nb_compare
        disp("Size of outputs mismatch")
        disp(nbLines)
        disp(size(list_output_str))
    else
        fileout = mopen(OUTPUT+'/list_outputs_str.csv', "w");
        for ii=1:(nb_regions+1)
            for elt=1:nbLines
                mfprintf(fileout,"%s\n", list_output_str(elt))
            end
        end
        mclose(fileout);
        //
        fileout = mopen(OUTPUT+'/list_outputs_units.csv', "w");
        for ii=1:(nb_regions+1)
            for elt=1:nbLines
                mfprintf(fileout,"%s\n", list_output_unit(elt))
            end
        end
        mclose(fileout);

        //
        fileout = mopen(OUTPUT+'/list_template_region.csv', "w");
        list_region_tpt=["USA","CAN","EUR","JAN","CIS","CHN","IND","BRA","MDE","AFR","RAS","RAL","World"];
        for ii=1:(nb_regions+1)
            for elt=1:nbLines
                mfprintf(fileout,"%s\n", list_region_tpt(ii))
            end
        end
        mclose(fileout);
        fileout = mopen(OUTPUT+'/list_template_comments.csv', "w");
        for ii=1:size(list_output_comments)
            if isempty(list_output_comments(ii))
                elt="";
            else
                elt=list_output_comments(ii);
            end
            mfprintf(fileout,"%s\n", elt)
        end
        mclose(fileout);
    end
end
