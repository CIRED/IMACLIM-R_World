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
    if strindex( VARname, 'Price') == [] & strindex( VARname, 'Capital Cost') == [] & strindex( VARname, 'Efficiency') == [] & strindex( VARname, 'OM Cost|Fixed') == [] & strindex( VARname, 'Sales|Market Share') == [] & strindex( VARname, 'Capacity|Utilization rate') == []
        outputs_temp(nbLines*reg+lineVAR,ind_time) = sum(outputs_temp(nbLines*[0:11] + lineVAR,ind_time));
    end
end


//////////////////////////////////
// Intensive values
/////////////////////////////////

// set some intensivfe world variables to nan to avoid th previous sum

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

// Capital Costs & OM cost
list_var_name = ['Coal|w/ CCS', 'Coal|w/o CCS','Gas|w/o CCS', 'Nuclear','Hydro','Solar|PV'];
list_var_indexes = list(technoCoalWCCS, technoCoalWOCCS,technoGasWOCCS,technoNuke,technoElecHydro,technoPV);
for i=1:size(list_var_name,'c')
    indexes_var=list_var_indexes(i);
    // Capital Costs
    lineVAR = find_index_list( list_output_str, 'Capital Cost|Electricity|'+list_var_name(i));
    temp_not_nans = ~isnan( CINV_MW_nexus(:,indexes_var) .* Inv_MW(:,indexes_var));
    outputs_temp(nbLines*reg+lineVAR,ind_time) = divide( sum( CINV_MW_nexus(:, indexes_var) .* Inv_MW(:,indexes_var) .*temp_not_nans ) , sum(Inv_MW(:,indexes_var).*temp_not_nans ), 0) * usd_year1_year2 ;
    // OM cost
    lineVAR = find_index_list( list_output_str, 'OM Cost|Fixed|Electricity|'+list_var_name(i));
    temp_not_nans = ~isnan( OM_cost_fixed_nexus(:,indexes_var) .* Inv_MW(:,indexes_var));
    outputs_temp(nbLines*reg+lineVAR,ind_time) = divide( sum( OM_cost_fixed_nexus( :,indexes_var) .* Inv_MW(:,indexes_var).*temp_not_nans ) , sum(Inv_MW(:,indexes_var).*temp_not_nans), 0) * usd_year1_year2 ;
end

// Efficiency ELECTRICITY
list_var_name = ['Coal|w/ CCS', 'Coal|w/o CCS','Gas|w/o CCS', 'Nuclear'];
list_var_indexes = list(technoCoalWCCS, technoCoalWOCCS,technoGasWOCCS,technoNuke);
for i=1:size(list_var_name,'c')
    indexes_var=list_var_indexes(i);
    lineVAR = find_index_list( list_output_str, 'Efficiency|Electricity|'+list_var_name(i));
    temp_not_nans = ~isnan( rho_elec_nexus(:,indexes_var) .* Inv_MW(:,indexes_var));
    outputs_temp(nbLines*reg+lineVAR,ind_time) = divide( sum( CINV_MW_nexus( :,indexes_var) .* Inv_MW(:,indexes_var) .*temp_not_nans) , sum(Inv_MW(:,indexes_var).*temp_not_nans), 0) * 100;
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

for technoy=['Electricity','Liquids','Hydrogen']
    str_varname = 'Sales|Market Share|LDV|' + technoy;
    lineVAR = find_index_list( list_output_str, str_varname); // $/kW
    if lineVAR<>0
        temp_reg_not_nans = ~isnan( cars_sales .* outputs_temp(nbLines*[0:11] + lineVAR,ind_time));
        if sum(temp_reg_not_nans)<>0
            outputs_temp(nbLines*reg+lineVAR,ind_time) = divide( sum( cars_sales .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,ind_time) ) , ..
                sum( cars_sales) , ..
            %nan);
        end
        if technoy=='Electricity'
            disp( outputs_temp(nbLines*reg+lineVAR,ind_time), "world MSH elec");
        end
    end
end

lineVAR = find_index_list( list_output_str,  'Final Energy|Transportation|Passenger|LDV|Electricity'); //   EJ/yr
lineVAR2 = find_index_list( list_output_str,  'Final Energy|Transportation|Passenger|LDV'); //   EJ/yr
disp( outputs_temp(nbLines*reg+lineVAR,ind_time) / outputs_temp(nbLines*reg+lineVAR2,ind_time) * 100, "FE elec on total world")


list_sec_name=['Coal','Oil', 'Gas', 'Services'];
list_indices_tpt = [indice_coal, indice_oil, indice_gas, indice_composite];
for i=1:4
    secname = list_sec_name(i);
    sec_ind_tpt = list_indices_tpt(i);
    str_varname = 'Capacity|Utilization rate|'+secname;
    lineVAR = find_index_list( list_output_str, str_varname); // $/kW
    if lineVAR<>0
        temp_reg_not_nans = ~isnan( sum(Cap(:,sec_ind_tpt),'c') .* outputs_temp(nbLines*[0:11] + lineVAR,ind_time));
        if sum(temp_reg_not_nans)<>0
            outputs_temp(nbLines*reg+lineVAR,ind_time) = divide( sum( sum(Cap(:,sec_ind_tpt),'c') .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,ind_time) ), sum(Cap(:,sec_ind_tpt)), %nan);
        end
    end
end

lineVAR = find_index_list( list_output_str, 'Capacity|Utilization rate|Industry');
outputs_temp(nbLines*reg+lineVAR,ind_time) = divide( sum( sum(Cap(:,indice_industries),'c') .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,ind_time) ) , ..
    sum(Cap(:,indice_industries)),  %nan);..

lineVAR = find_index_list( list_output_str, 'Capacity|Utilization rate');
outputs_temp(nbLines*reg+lineVAR,ind_time) = divide( sum( GDP_PPP_constant .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,ind_time) ) , ..
    sum( GDP_PPP_constant) , ..
%nan);

list_sec_name=['Agriculture','Fossil fuels', 'Electricity', 'Industries', 'Construction', 'Services'];
list_indices_tpt = list(indice_agriculture, indice_FF_Et, indice_elec, indice_industries, indice_construction, indice_all_services);
for i=1:size(list_sec_name,'c')
    secname = list_sec_name(i);
    sec_ind_tpt = list_indices_tpt(i);
    str_varname = 'Value Added|'+secname+'|Share';
    lineVAR = find_index_list( list_output_str, str_varname); // $/kW
    if lineVAR<>0
        outputs_temp(nbLines*reg+lineVAR,ind_time) = sum(VA(:,sec_ind_tpt)) / sum(VA) * 100;
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

lineVAR = find_index_list( list_output_str, "Price|Carbon"); // 
weightLine = find_index_list( list_output_str, "Emissions|CO2|Energy");
outputs_temp(nbLines*reg+lineVAR,ind_time) = divide( sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time) .* outputs_temp(nbLines*[0:11] + lineVAR,ind_time)), sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time)), 0);

lineVAR = find_index_list( list_output_str, "Price|Primary Energy|Biomass"); // US$2010/GJ
if ind_NLU > 0
    outputs_temp(nbLines*reg+lineVAR,ind_time) = w_bioener_costs_Farmgate;
else
    //Eoin asks if 57 is correct ref for the third line here?
    line_BIGCCS = find_index_list( list_output_str, "Secondary Energy|Electricity|Biomass|w/ CCS");
    line_BIGCC  = find_index_list( list_output_str, "Secondary Energy|Electricity|Biomass|w/o CCS");
    line_biofuels = find_index_list( list_output_str, "Secondary Energy|Liquids");
    prodBiomassReg = outputs_temp(nbLines*[0:11]   + line_biofuels,ind_time) ..
        + outputs_temp(nbLines*[0:11] + line_BIGCCS,ind_time) ./ rho_elec_nexus(:,indice_BIS) ..
    + divide(outputs_temp(nbLines*[0:11] + line_BIGCC,ind_time),  divide(sum(rho_elec_nexus(:,technoBiomassWOCCS).*msh_elec_techno(:,technoBiomassWOCCS),"c"),sum(msh_elec_techno(:,technoBiomassWOCCS),"c"),0),0);
    indexee = outputs_temp(nbLines*[0:11] + lineVAR,ind_time);
    nanIndex = ~isnan(indexee);
    //Eoin inserted (nanIndex) in next line to avoid /0 error. This correct?
    if sum(prodBiomassReg)~= 0
        outputs_temp(nbLines*reg+lineVAR,ind_time) = sum(prodBiomassReg(nanIndex) .* indexee(nanIndex)) ./ (%eps+sum(prodBiomassReg(nanIndex)));
    else
        outputs_temp(nbLines*reg+lineVAR,ind_time) = %nan;
    end
end

if ind_NLU > 0
    lineVAR = find_index_list( list_output_str, "Yield|Cereal"); 
    outputs_temp(nbLines*reg+lineVAR,ind_time) = W_yield_Dyn * Mkcal2Gigajoule./hhv_biomass;

    lineVAR = find_index_list( list_output_str, "Price|Agriculture|Non-Energy Crops|Index"); 
    outputs_temp(nbLines*reg+lineVAR,ind_time) = wpveg;
end

lineVAR = find_index_list( list_output_str, "Price|Primary Energy|Coal"); // US$2010/GJ
weightLine = find_index_list( list_output_str, "Primary Energy|Coal"); 
outputs_temp(nbLines*reg+lineVAR,ind_time) = sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time) .* outputs_temp(nbLines*[0:11] + lineVAR,ind_time))./sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time));

lineVAR = find_index_list( list_output_str, "Price|Primary Energy|Gas"); // US$2010/GJ
weightLine = find_index_list( list_output_str, "Primary Energy|Gas"); 
outputs_temp(nbLines*reg+lineVAR,ind_time) = sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time) .* outputs_temp(nbLines*[0:11] + lineVAR,ind_time))./sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time));

lineVAR = find_index_list( list_output_str, "Price|Primary Energy|Oil"); // US$2010/GJ
weightLine = find_index_list( list_output_str, "Primary Energy|Oil"); 
outputs_temp(nbLines*reg+lineVAR,ind_time) = sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time) .* outputs_temp(nbLines*[0:11] + lineVAR,ind_time))./sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time));

lineVAR = find_index_list( list_output_str, "Price|Secondary Energy|Electricity"); // US$2010/GJ
weightLine = find_index_list( list_output_str, "Secondary Energy|Electricity"); 
outputs_temp(nbLines*reg+lineVAR,ind_time) = sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time) .* outputs_temp(nbLines*[0:11] + lineVAR,ind_time))./sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time));

lineVAR = find_index_list( list_output_str, "Price|Secondary Energy|Liquids"); // US$2010/GJ
weightLine = find_index_list( list_output_str, "Secondary Energy|Liquids"); 
outputs_temp(nbLines*reg+lineVAR,ind_time) = sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time) .* outputs_temp(nbLines*[0:11] + lineVAR,ind_time))./sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time));

lineVAR = find_index_list( list_output_str, "Price|Secondary Energy|Liquids|Biomass"); // US$2010/GJ
weightLine = find_index_list( list_output_str, "Secondary Energy|Liquids|Biomass"); 
outputs_temp(nbLines*reg+lineVAR,ind_time) = divide(sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time) .* outputs_temp(nbLines*[0:11] + lineVAR,ind_time)), sum(outputs_temp(nbLines*[0:11] + weightLine,ind_time)),0);


lineVAR = find_index_list( list_output_str, "Price|Secondary Energy|Gases|Fossil"); // US$2010/GJ
outputs_temp(nbLines*reg+lineVAR,ind_time) = %nan;

lineVAR = find_index_list( list_output_str, "Price|Secondary Energy|Gases"); // US$2010/GJ
outputs_temp(nbLines*reg+lineVAR,ind_time) = %nan;

lineVAR = find_index_list( list_output_str, "Trade|Primary Energy|Biomass|Volume"); // US$2010/GJ
outputs_temp(nbLines*reg+lineVAR,ind_time) = %nan;

// compute indexes

if ind_NLU > 0
    if is_terminate
        lineVAR = find_index_list( list_output_str, "Price|Agriculture|Non-Energy Crops|Index"); 
        outputs_temp(nbLines*[0:12] + lineVAR,ind_time) = outputs_temp(nbLines*[0:12] + lineVAR,ind_time) ./ outputs_temp(nbLines*[0:12] + lineVAR,4);
    end
end

if ind_NLU >0
    // outputs Imaclim drivers for NLU
    // usefull to run NLU without running Imaclim
    // will be only present in full output file.
    counter_NLU = 1;
    varname_driver = 'Imaclim2NLU|Secondary Energy|Price|Lightoil';
    if current_time_im==1 ; list_output_str($+1) = varname_driver; end;
    outputs_temp(nbLines*13+counter_NLU+4*12,ind_time) = wlightoil_price ;
    if current_time_im==1 ; list_output_unit($+1) = "US$2010/tep";
    end;

    counter_NLU = counter_NLU +1;
    varname_driver = 'Imaclim2NLU|Primary Energy|Price|Gas';
    if current_time_im==1 ; list_output_str($+1) = varname_driver; end;
    outputs_temp(nbLines*13+counter_NLU+4*12,ind_time) = wnatgas_price ;
    if current_time_im==1 ; list_output_unit($+1) = "US$2010/tep";
    end;

    counter_NLU = counter_NLU +1;
    varname_driver = 'Imaclim2NLU|Current time';
    if current_time_im==1 ; list_output_str($+1) = varname_driver; end;
    outputs_temp(nbLines*13+counter_NLU+4*12,ind_time) = current_time_im +1;
    if current_time_im==1 ; list_output_unit($+1) = "";
    end;

    counter_NLU = counter_NLU +1;
    varname_driver = 'Imaclim2NLU|Current year';
    if current_time_im==1 ; list_output_str($+1) = varname_driver; end;
    outputs_temp(nbLines*13+counter_NLU+4*12,ind_time) = current_time_im +1 + 2000;
    if current_time_im==1 ; list_output_unit($+1) = "";
    end;
end



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
