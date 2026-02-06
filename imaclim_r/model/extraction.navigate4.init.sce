// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


// initialization of extraction for a stury

// compute the number of lines
// number of line specificatio for output files

year_to_select = [5:5:50];

if ~isdef("year_to_select")
    //year_to_select = [1 5:5:TimeHorizon+1];
    // base year all with nan's currently
    year_to_select = [5:5:TimeHorizon+1];
end
// do not smooth by default, as it modify the energy balances
// or code an exception for energy balance (and other balances)
do_smooth_outputs=%t;
if ~isdef("do_smooth_outputs")
    do_smooth_outputs = %f;
end

//conversion factors
usd2001_2005=1/0.907;
usd2001_2010= 92.0 / 74.7; // source https://data.oecd.org/price/inflation-cpi.htm 25-10-2019
usd_year1_year2 = 1/CPI_2010_to_2014;
Mtoe_EJ=0.041868;

// counting number of variable (to be multiplied by number of regions+1)
if ~isdef("nbLines")
    if ind_NLU ==0
        nbLines = count_str_pattern( 'extraction.outputs.'+ETUDEOUTPUT+'.region.sce', 'varname =') ;
    else
        nbLines = count_str_pattern( 'extraction.outputs.'+ETUDEOUTPUT+'.region.sce', 'varname =') + count_str_pattern( 'extraction.outputs.'+ETUDEOUTPUT+'.region.landuse.sce', 'varname =');
    end
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


// initiates the numerical matrice and headers of varaible name (str), comments (comments) and units (unit)
if current_time_im==0
    if ind_NLU>0
        outputs_temp=zeros(nbLines*(reg+1)+ nbLines_NLU_driver,TimeHorizon+1);
    else
        outputs_temp=zeros(nbLines*(reg+1),TimeHorizon+1);
    end
    outputs_temp(:,:) = %nan; // all to 'nan'
    list_output_str = list();
    list_output_comments = list();
    list_output_unit = list();
end

// uncomment that line when the baseline report will be ready
// exec(MODEL+"extraction.outputs."+ETUDEOUTPUT+".sce");

// outputs Imaclim drivers for NLU
// Need to be done at initialization for have the calibration year of Imaclim
// usefull to run NLU without running Imaclim
// will be only present in full output file, not in the reduced (year) or smooth one
if ind_NLU >0
    for k=1:reg
        counter_NLU = 0;
        varname_driver = 'Imaclim2NLU|Price|Carbon';
        outputs_temp(nbLines*13+counter_NLU*12+k,current_time_im+1) = reg_taxeC(k);

        counter_NLU = counter_NLU +1;
        varname_driver = 'Imaclim2NLU|Added_Value|Price|Agriculture';
        moutputs_temp(nbLines*13+counter_NLU*12+k,current_time_im+1) = va_agri(k) * usd_year1_year2;

        counter_NLU = counter_NLU +1;
        varname_driver = 'Imaclim2NLU|Population';
        outputs_temp(nbLines*13+counter_NLU*12+k,current_time_im+1) = pop(k) ;

        counter_NLU = counter_NLU +1;
        varname_driver = 'Imaclim2NLU|Primary Energy|Biomass';
        outputs_temp(nbLines*13+counter_NLU*12+k,current_time_im+1) = reg_in_bioelec(k) ;
    end;

    // outputs Imaclim drivers for NLU
    // usefull to run NLU without running Imaclim
    // will be only present in full output file.
    counter_NLU = 1;
    varname_driver = 'Imaclim2NLU|Secondary Energy|Price|Lightoil';
    outputs_temp(nbLines*13+counter_NLU+4*12,current_time_im+1) = wlightoil_price ;

    counter_NLU = counter_NLU +1;
    varname_driver = 'Imaclim2NLU|Primary Energy|Price|Gas';
    outputs_temp(nbLines*13+counter_NLU+4*12,current_time_im+1) = wnatgas_price ;

    counter_NLU = counter_NLU +1;
    varname_driver = 'Imaclim2NLU|Current time';
    outputs_temp(nbLines*13+counter_NLU+4*12,current_time_im+1) = current_time_im ;

    counter_NLU = counter_NLU +1;
    varname_driver = 'Imaclim2NLU|Current year';
    outputs_temp(nbLines*13+counter_NLU+4*12,current_time_im+1) = current_time_im + 2000;
end
