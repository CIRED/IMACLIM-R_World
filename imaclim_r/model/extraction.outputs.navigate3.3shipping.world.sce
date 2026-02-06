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

// set some intensivfe world variables to nan to avoid th previous sum
str_varname = 'Production|Transportation|International Transport|International Shipping'; // EJ/yr 
lineVAR = find_index_list( list_output_str, str_varname);
if current_time_im<=5
    outputs_temp(nbLines*reg+lineVAR,ind_time) = 0;
elseif current_time_im==6
    prod_int_shipping_2020 = sum( ExpTI(:,indice_mer));
    prod_int_shipping_2020 = sum( Q(:,indice_mer));
    outputs_temp(nbLines*reg+lineVAR,ind_time) = 1;
else
    outputs_temp(nbLines*reg+lineVAR,ind_time) = sum( Q(:,indice_mer)) / prod_int_shipping_2020;
end

//  World values : exceptions for intensive variables

// but with exceptions
list_techind_temp=[indice_CSP,indice_GGS, indice_WNO, indice_BIS, indice_BIG];
for vary=['Capital Cost','Efficiency','OM Cost|Fixed']
    indy=0;
    for technoy=['Electricity|Solar|CSP','|Electricity|Gas|w/ CCS','|Electricity|Wind|Offshore','|Electricity|Biomass|w/ CCS','|Electricity|Biomass|w/o CCS']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        indy = indy+1;
        temp_techs = list_techind_temp(indy);
        if lineVAR<>0
            temp_reg_not_nans = ~isnan(sum(prod_elec_techno(:,temp_techs),2) .* outputs_temp(nbLines*[0:11] + lineVAR,ind_time));
            if sum(temp_reg_not_nans)<>0
                outputs_temp(nbLines*reg+lineVAR,ind_time) = divide( sum(sum(prod_elec_techno(temp_reg_not_nans,temp_techs),2) .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,ind_time) ) , ..
                    sum(prod_elec_techno(temp_reg_not_nans,temp_techs)) , ..
                %nan);
            end
        end
    end
end


for vary=['Capital Cost','Efficiency','OM Cost|Fixed']
    for technoy=['|Electricity|Geothermal','|Gases|Biomass|w/ CCS','|Gases|Biomass|w/o CCS','|Gases|Coal|w/ CCS','|Gases|Coal|w/o CCS','|Hydrogen|Biomass|w/ CCS','|Hydrogen|Biomass|w/o CCS','|Hydrogen|Coal|w/ CCS','|Hydrogen|Coal|w/o CCS','|Hydrogen|Gas|w/ CCS','|Hydrogen|Gas|w/o CCS','|Hydrogen|Electricity','|Liquids|Gas|w/ CCS','|Liquids|Gas|w/o CCS']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        if lineVAR
            outputs_temp(nbLines*reg+lineVAR,ind_time) = %nan;
        end
    end
end


for vary=['Capital Cost','Efficiency','OM Cost|Fixed']
    for technoy=['|Liquids|Oil']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        if lineVAR<>0
            temp_reg_not_nans = ~isnan( Q(:,indice_oil) .* outputs_temp(nbLines*[0:11] + lineVAR,ind_time));
            if sum(temp_reg_not_nans)<>0
                outputs_temp(nbLines*reg+lineVAR,ind_time) = divide( sum( Q(:,indice_oil) .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,ind_time) ) , ..
                    sum( Q(:,indice_oil)) , ..
                %nan);
            end
        end
    end
end
for vary=['Capital Cost','Efficiency','OM Cost|Fixed']
    for technoy=['|Liquids|Coal|w/o CCS']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        if lineVAR<>0
            temp_reg_not_nans = ~isnan( Q(:,indice_coal) .* outputs_temp(nbLines*[0:11] + lineVAR,ind_time));
            if sum(temp_reg_not_nans)<>0
                outputs_temp(nbLines*reg+lineVAR,ind_time) = divide( sum( Q(:,indice_coal) .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,ind_time) ) , ..
                    sum( Q(:,indice_coal)) , ..
                %nan);
            end
        end
    end
end


if ind_NLU >0
    for vary=['Capital Cost','Efficiency','OM Cost|Fixed']
        for technoy=['|Hydrogen|Biomass|w/ CCS']
            str_varname = vary + technoy;
            lineVAR = find_index_list( list_output_str, str_varname); // $/kW
            if lineVAR<>0
                temp_reg_not_nans = ~isnan( glob_in_bioelec_Hyd_reg .* outputs_temp(nbLines*[0:11] + lineVAR,ind_time));
                if sum(temp_reg_not_nans)<>0
                    outputs_temp(nbLines*reg+lineVAR,ind_time) = divide( sum( glob_in_bioelec_Hyd_reg .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,ind_time) ) , ..
                        sum( glob_in_bioelec_Hyd_reg) , ..
                    %nan);
                end
            end
        end
    end
end

if ind_NLU >0
    varname = 'Capital Cost|Liquids|Biomass|w/o CCS'; //$/kW
    lineVAR = find_index_list( list_output_str, varname); // $/kW
    outputs_temp(nbLines*reg+lineVAR,ind_time) = ethan2G_inv *usd_year1_year2;
    varname = 'Efficiency|Liquids|Biomass|w/o CCS'; //$/kW
    lineVAR = find_index_list( list_output_str, varname); // $/kW
    outputs_temp(nbLines*reg+lineVAR,ind_time) = Hoowijk_2000_efficiency; //todo
    varname = 'OM Cost|Fixed|Liquids|Biomass|w/o CCS'; //$/kW
    lineVAR = find_index_list( list_output_str, varname); // $/kW
    outputs_temp(nbLines*reg+lineVAR,ind_time) = Hoowijk_2000_OM_percent * ethan2G_inv *usd_year1_year2; //todo
end

for vary=['Final Energy']
    for technoy=['|Transportation|Gases']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        if lineVAR
            outputs_temp(nbLines*reg+lineVAR,ind_time) = %nan;
        end
    end
end



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
