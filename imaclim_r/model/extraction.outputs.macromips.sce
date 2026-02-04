// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// TODO :
// Price|Secondary Energy|Liquids|Biomass


// when the NLU is executed alone with exxogenous Imacliml driver of a scenario
if ind_NLU_sensit > 0
  current_time_im=current_time_im-1;
  yr_start = 0;
else
  yr_start = 1;
end

for k=1:reg
    exec (MODEL+"extraction.outputs."+ETUDEOUTPUT+".region.sce");
end

// for the base year output here the land-use variables
if ind_NLU >0 & current_time==0
    exec (MODEL+"extraction.outputs."+ETUDEOUTPUT+".region.landuse.sce");
end

// compute the world outputs here is the Nexus Land-Use is not used
if ind_NLU ==0 
    exec(MODEL+"extraction.outputs."+ETUDEOUTPUT+".world.sce");
end

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
   if ind_NLU >0
        fileout = mopen(OUTPUT+'/list_outputs_str_withNLU.csv', "w");
        for ii=1:(nb_regions+1)
        for elt=1:nbvar_NLU_driver
            mfprintf(fileout,"%s\n", list_output_str(elt+nbLines))
        end
        end
        for elt=['Imaclim2NLU|Price|Carbon','Imaclim2NLU|Added_Value|Price|Agriculture','Imaclim2NLU|Population','Imaclim2NLU|Population','Imaclim2NLU|Primary Energy|Biomass']
        for ii=1:(nb_regions+1)
            mfprintf(fileout,"%s\n", elt)
        end
        end
        for elt=['Imaclim2NLU|Secondary Energy|Price|Lightoil', 'Imaclim2NLU|Primary Energy|Price|Gas', 'Imaclim2NLU|Current time', 'Imaclim2NLU|Current year']
            mfprintf(fileout,"%s\n", elt)
        end
        mclose(fileout);
    end
//
        fileout = mopen(OUTPUT+'/list_outputs_units.csv', "w");
        for ii=1:(nb_regions+1)
        for elt=1:nbLines
            mfprintf(fileout,"%s\n", list_output_unit(elt))
        end
        end
        mclose(fileout);
//
    if ind_NLU >0
        fileout = mopen(OUTPUT+'/list_outputs_units_withNLU.csv', "w");
        for ii=1:(nb_regions+1)
        for elt=1:nbvar_NLU_driver
            mfprintf(fileout,"%s\n", list_output_str(nbLines+elt))
        end
        end
        for elt=["$/tCO2", "billion US$2010/yr", "million", "Mkcal/yr"]
        for ii=1:(nb_regions+1)
            mfprintf(fileout,"%s\n", elt)
        end
        end
        for elt=["US$2010/tep","US$2010/tep","",""]
            mfprintf(fileout,"%s\n", elt)
        end
        mclose(fileout);
     end
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
          try
            elt=list_output_comments(ii);
          catch
            elt="";
          end
          mfprintf(fileout,"%s\n", elt)
        end
        mclose(fileout);
    end
end

