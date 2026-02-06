// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


//conversion factors
usd2001_2005=1/0.907;
Mtoe_EJ=0.041868;


// counting number of variable (to be multiplied by number of regions+1)
if ~isdef("nbLines")
    nbLines = count_str_pattern( 'extraction.outputs.'+ETUDEOUTPUT+'.region.sce', 'varname =') + count_str_pattern( 'extraction.outputs.'+ETUDEOUTPUT+'.region.landuse.sce', 'varname =');
end

// nb lines for variables which are drivers of NLU:
// will be only in full outputs // check for the varname_driver pattern
// nb variables which are drivers of NLU
if ~isdef("nbLines_NLU_driver")
    nbLines_NLU_driver = 12 * count_str_pattern( 'extraction.outputs.'+ETUDEOUTPUT+'.region.landuse.sce', 'varname_driver =') + count_str_pattern( 'extraction.outputs.'+ETUDEOUTPUT+'.world.sce', 'varname_driver =');
end

// nb variables which are drivers of NLU
if ~isdef("nbvar_NLU_driver")
    nbvar_NLU_driver = count_str_pattern( 'extraction.outputs.'+ETUDEOUTPUT+'.region.landuse.sce', 'varname_driver =') + count_str_pattern( 'extraction.outputs.'+ETUDEOUTPUT+'.world.sce', 'varname_driver =');
end


//annees 2001-2005-2010-2020 etc
if current_time_im==0
    outputs_temp=zeros(nbLines*(reg+1)+ nbLines_NLU_driver,TimeHorizon+1);
    list_output_str = list();
    list_output_comments = list();
    list_output_unit = list();
end



for k=1:reg
    // outputs Imaclim drivers for NLU
    // usefull to run NLU without running Imaclim
    // will be only present in full output file.
    counter_NLU = 0;
    varname_driver = 'Imaclim2NLU|Price|Carbon';
    outputs_temp(nbLines*13+counter_NLU*12+k,current_time+1) = reg_taxeC(k);

    counter_NLU = counter_NLU +1;
    varname_driver = 'Imaclim2NLU|Added_Value|Price|Agriculture';
    outputs_temp(nbLines*13+counter_NLU*12+k,current_time+1) = va_agri(k) * usd2001_2005;

    counter_NLU = counter_NLU +1;
    varname_driver = 'Imaclim2NLU|Population';
    outputs_temp(nbLines*13+counter_NLU*12+k,current_time+1) = pop(k) ;

    counter_NLU = counter_NLU +1;
    varname_driver = 'Imaclim2NLU|Primary Energy|Biomass';
    outputs_temp(nbLines*13+counter_NLU*12+k,current_time+1) = reg_in_bioelec(k) ;
end;

// outputs Imaclim drivers for NLU
// usefull to run NLU without running Imaclim
// will be only present in full output file.
counter_NLU = 1;
varname_driver = 'Imaclim2NLU|Secondary Energy|Price|Lightoil';
outputs_temp(nbLines*13+counter_NLU+4*12,current_time+1) = wlightoil_price ;

counter_NLU = counter_NLU +1;
varname_driver = 'Imaclim2NLU|Primary Energy|Price|Gas';
outputs_temp(nbLines*13+counter_NLU+4*12,current_time+1) = wnatgas_price ;

counter_NLU = counter_NLU +1;
varname_driver = 'Imaclim2NLU|Current time';
outputs_temp(nbLines*13+counter_NLU+4*12,current_time+1) = current_time ;

counter_NLU = counter_NLU +1;
varname_driver = 'Imaclim2NLU|Current year';
outputs_temp(nbLines*13+counter_NLU+4*12,current_time+1) = current_time + 2000;

