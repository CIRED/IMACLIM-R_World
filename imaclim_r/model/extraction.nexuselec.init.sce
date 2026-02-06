// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Patrice Dumas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// initialization of extraction for a study - without Land Use

// compute the number of lines
// number of line specification for output files

year_to_select = [2:5:TimeHorizon+1];
if ~isdef("year_to_select")
    //year_to_select = [1 5:5:TimeHorizon+1];
    // base year all with nan's currently
    year_to_select = [5:5:TimeHorizon+1];
end
// do not smooth by default, as it modify the energy balances
// or code an exception for energy balance (and other balances)
do_smooth_outputs=%f;
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
    nbLines = count_str_pattern( 'extraction.outputs.'+ETUDEOUTPUT+'.region.sce', 'varname =') ;
end

// initiates the numerical matrice and headers of varaible name (str), comments (comments) and units (unit)
if current_time_im==0
    outputs_temp=zeros(nbLines*(reg+1),TimeHorizon+1);
    outputs_temp(:,:) = %nan; // all to 'nan'
    list_output_str = list();
    list_output_comments = list();
    list_output_unit = list();
end

// uncomment that line when the baseline report will be ready
// exec(MODEL+"extraction.outputs."+ETUDEOUTPUT+".sce");
