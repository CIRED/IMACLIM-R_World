// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// World values : sum over all
for lineVAR =1:nbLines //[1:16 35:124 126:293 302:nbLines]
    outputs_temp(nbLines*reg+lineVAR,current_time+1) = sum(outputs_temp(nbLines*[0:11] + lineVAR,current_time+1));
end





// but with exceptions
list_techind_temp=[indice_CGS,indice_ICG,indice_PSS,indice_PFC,indice_LCT,indice_CCT,indice_GGS,indice_GGC,indice_GGT,indice_GCT,indice_NUC,indice_NND,indice_CSP,indice_CPV,indice_RPV,indice_WNO,indice_WND,indice_WNO,indice_WND,indice_BIS,indice_BIG,indice_HYD,indice_SHY];
for vary=['Capital Cost','Efficiency','OM Cost|Fixed','OM Cost|Variable']
    indy=0;
    for technoy=['Electricity|CSP','Electricity|PV','Liquids|Oil','|Electricity|Coal|w/ CCS','|Electricity|Coal|w/o CCS','|Electricity|Coal|w/ CCS|2','|Electricity|Coal|w/o CCS|2','|Electricity|Coal|w/o CCS|3','|Electricity|Coal|w/o CCS|4','|Electricity|Gas|w/ CCS','|Electricity|Gas|w/o CCS','|Electricity|Gas|w/o CCS|2','|Electricity|Gas|w/o CCS|3','|Electricity|Nuclear','|Electricity|Nuclear|2','|Electricity|Solar|CSP','|Electricity|Solar|PV','|Electricity|Solar|PV|2','|Electricity|Wind','|Electricity|Biomass|w/ CCS','|Electricity|Biomass|w/o CCS','|Electricity|Hydro','|Electricity|Hydro|2']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        indy = indy+1;
        temp_techs = list_techind_temp(indy);
        if lineVAR<>0
            temp_reg_not_nans = ~isnan(sum(prod_elec_techno(:,temp_techs),2) .* outputs_temp(nbLines*[0:11] + lineVAR,current_time+1));
            outputs_temp(nbLines*reg+lineVAR,current_time+1) = divide( sum(sum(prod_elec_techno(temp_reg_not_nans,temp_techs),2) .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,current_time+1) ) , ..
                sum(prod_elec_techno(temp_reg_not_nans,temp_techs)) , ..
            %nan);
        end
    end
end

for vary=['Capital Cost','Efficiency','OM Cost|Fixed','OM Cost|Variable']
    for technoy=['|Electricity|Geothermal','|Electricity|Transmission|AC','|Electricity|Transmission|DC','|Gases|Biomass|w/ CCS','|Gases|Biomass|w/o CCS','|Gases|Coal|w/ CCS','|Gases|Coal|w/o CCS','|Heat|Biomass|w/ CCS','|Heat|Biomass|w/o CCS','|Heat|Gas|w/ CCS','|Heat|Gas|w/o CCS','|Heat|Geothermal','|Heat|Oil','|Heat|Propane','|Heat|Solar','|Hydrogen|Biomass|w/ CCS','|Hydrogen|Biomass|w/o CCS','|Hydrogen|Coal|w/ CCS','|Hydrogen|Coal|w/o CCS','|Hydrogen|Gas|w/ CCS','|Hydrogen|Gas|w/o CCS','|Hydrogen|Electricity','|Liquids|Biomass|Biodiesel|w/ CCS','|Liquids|Biomass|Biodiesel|w/o CCS','|Liquids|Biomass|Cellulosic Nondiesel|w/ CCS','|Liquids|Biomass|Cellulosic Nondiesel|w/o CCS','|Liquids|Biomass|Conventional Ethanol|w/ CCS','|Liquids|Biomass|Conventional Ethanol|w/o CCS','|Liquids|Biomass|Other|w/ CCS','|Liquids|Biomass|Other|w/o CCS','|Liquids|Coal|w/ CCS','|Liquids|Coal|w/o CCS','|Liquids|Gas|w/ CCS','|Liquids|Gas|w/o CCS','|Liquids|Oil']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        if lineVAR
            outputs_temp(nbLines*reg+lineVAR,current_time+1) = %nan;
        end
    end
end


for vary=['Capital Cost','Efficiency','OM Cost|Fixed','OM Cost|Variable']
    for technoy=['|Liquids|Oil']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        if lineVAR<>0
            temp_reg_not_nans = ~isnan( Q(:,indice_oil) .* outputs_temp(nbLines*[0:11] + lineVAR,current_time+1));
            outputs_temp(nbLines*reg+lineVAR,current_time+1) = divide( sum( Q(:,indice_oil) .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,current_time+1) ) , ..
                sum( Q(:,indice_oil)) , ..
            %nan);
        end
    end
end
for vary=['Capital Cost','Efficiency','OM Cost|Fixed','OM Cost|Variable']
    for technoy=['|Liquids|Coal|w/o CCS']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        if lineVAR<>0
            temp_reg_not_nans = ~isnan( Q(:,indice_coal) .* outputs_temp(nbLines*[0:11] + lineVAR,current_time+1));
            outputs_temp(nbLines*reg+lineVAR,current_time+1) = divide( sum( Q(:,indice_coal) .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,current_time+1) ) , ..
                sum( Q(:,indice_coal)) , ..
            %nan);
        end
    end
end
for vary=['Capital Cost','Efficiency','OM Cost|Fixed','OM Cost|Variable']
    for technoy=['|Hydrogen|Biomass|w/ CCS']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        if lineVAR<>0
            temp_reg_not_nans = ~isnan( glob_in_bioelec_Hyd_reg .* outputs_temp(nbLines*[0:11] + lineVAR,current_time+1));
            outputs_temp(nbLines*reg+lineVAR,current_time+1) = divide( sum( glob_in_bioelec_Hyd_reg .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,current_time+1) ) , ..
                sum( glob_in_bioelec_Hyd_reg) , ..
            %nan);
        end
    end
end
for vary=['Capital Cost','Efficiency','OM Cost|Fixed','OM Cost|Variable']
    for technoy=['|Hydrogen|Biomass|w/ CCS']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        if lineVAR<>0
            temp_reg_not_nans = ~isnan( glob_in_bioelec_Hyd_reg .* outputs_temp(nbLines*[0:11] + lineVAR,current_time+1));
            outputs_temp(nbLines*reg+lineVAR,current_time+1) = divide( sum( glob_in_bioelec_Hyd_reg .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,current_time+1) ) , ..
                sum( glob_in_bioelec_Hyd_reg) , ..
            %nan);
        end
    end
end

weight_var = share1G .* share_biofuel .* squeeze( energy_balance(refi_eb,et_eb,:));
for vary=['Capital Cost','Efficiency','OM Cost|Fixed','OM Cost|Variable']
    for technoy=['|Liquids|Biomass|Other|w/o CCS']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        if lineVAR<>0
            temp_reg_not_nans = ~isnan( weight_var .* outputs_temp(nbLines*[0:11] + lineVAR,current_time+1));
            outputs_temp(nbLines*reg+lineVAR,current_time+1) = divide( sum( weight_var .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,current_time+1) ) , ..
                sum( weight_var) , ..
            %nan);
        end
    end
end

weight_var = glob_in_bioelec_Et_reg';
for vary=['Capital Cost','Efficiency','OM Cost|Fixed','OM Cost|Variable']
    for technoy=['|Liquids|Biomass|Cellulosic Nondiesel|w/o CCS']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        if lineVAR<>0
            temp_reg_not_nans = ~isnan( weight_var .* outputs_temp(nbLines*[0:11] + lineVAR,current_time+1));
            outputs_temp(nbLines*reg+lineVAR,current_time+1) = divide( sum( weight_var .* outputs_temp(nbLines*[find(temp_reg_not_nans)-1] + lineVAR,current_time+1) ) , ..
                sum( weight_var) , ..
            %nan);
        end
    end
end

varname = 'Capital Cost|Liquids|Biomass|Cellulosic Nondiesel|w/o CCS'; //$/kW
lineVAR = find_index_list( list_output_str, varname); // $/kW
outputs_temp(nbLines*reg+lineVAR,current_time+1) = ethan2G_inv *usd2001_2005;
varname = 'Efficiency|Liquids|Biomass|Cellulosic Nondiesel|w/o CCS'; //$/kW
lineVAR = find_index_list( list_output_str, varname); // $/kW
outputs_temp(nbLines*reg+lineVAR,current_time+1) = Hoowijk_2000_efficiency; //todo
varname = 'OM Cost|Fixed|Liquids|Biomass|Cellulosic Nondiesel|w/o CCS'; //$/kW
lineVAR = find_index_list( list_output_str, varname); // $/kW
outputs_temp(nbLines*reg+lineVAR,current_time+1) = Hoowijk_2000_OM_percent * ethan2G_inv * usd2001_2005; //todo
varname = 'OM Cost|Variable|Liquids|Biomass|Cellulosic Nondiesel|w/o CCS'; //$/kW
lineVAR = find_index_list( list_output_str, varname); // $/kW
outputs_temp(nbLines*reg+lineVAR,current_time+1) = 0; //todo


for vary=['Capital Cost']
    for technoy=['|Gases|Transmission|AC']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        if lineVAR
            outputs_temp(nbLines*reg+lineVAR,current_time+1) = %nan;
        end
    end
end

for vary=['Final Energy']
    for technoy=['|Transportation|Gases']
        str_varname = vary + technoy;
        lineVAR = find_index_list( list_output_str, str_varname); // $/kW
        if lineVAR
            outputs_temp(nbLines*reg+lineVAR,current_time+1) = %nan;
        end
    end
end



lineVAR = find_index_list( list_output_str, "Price|Carbon"); // 
weightLine = find_index_list( list_output_str, "Emissions|CO2|Fossil Fuels and Industry");
outputs_temp(nbLines*reg+lineVAR,current_time+1) = divide( sum(outputs_temp(nbLines*[0:11] + weightLine,current_time+1) .* outputs_temp(nbLines*[0:11] + lineVAR,current_time+1)), sum(outputs_temp(nbLines*[0:11] + weightLine,current_time+1)), 0);

lineVAR = find_index_list( list_output_str, "Price|Primary Energy|Biomass|Delivered"); // US$2005/GJ
outputs_temp(nbLines*reg+lineVAR,current_time+1) = w_bioener_costs_Del;

lineVAR = find_index_list( list_output_str, "Price|Primary Energy|Biomass|Market"); // US$2005/GJ
outputs_temp(nbLines*reg+lineVAR,current_time+1) = w_bioener_costs_Del;

lineVAR = find_index_list( list_output_str, "Price|Primary Energy|Biomass|Farmgate"); // US$2005/GJ
outputs_temp(nbLines*reg+lineVAR,current_time+1) = w_bioener_costs_Farmgate;

lineVAR = find_index_list( list_output_str, "Yield|cereal"); 
outputs_temp(nbLines*reg+lineVAR,current_time+1) = W_yield_Dyn * Mkcal2Gigajoule./hhv_biomass;

lineVAR = find_index_list( list_output_str, "Price|Agriculture|Non-Energy Crops|Index"); 
outputs_temp(nbLines*reg+lineVAR,current_time+1) = wpveg;

lineVAR = find_index_list( list_output_str, "Price|Primary Energy|Coal"); // US$2005/GJ
weightLine = find_index_list( list_output_str, "Primary Energy|Coal"); 
outputs_temp(nbLines*reg+lineVAR,current_time+1) = sum(outputs_temp(nbLines*[0:11] + weightLine,current_time+1) .* outputs_temp(nbLines*[0:11] + lineVAR,current_time+1))./sum(outputs_temp(nbLines*[0:11] + weightLine,current_time+1));

lineVAR = find_index_list( list_output_str, "Price|Primary Energy|Gas"); // US$2005/GJ
weightLine = find_index_list( list_output_str, "Primary Energy|Gas"); 
outputs_temp(nbLines*reg+lineVAR,current_time+1) = sum(outputs_temp(nbLines*[0:11] + weightLine,current_time+1) .* outputs_temp(nbLines*[0:11] + lineVAR,current_time+1))./sum(outputs_temp(nbLines*[0:11] + weightLine,current_time+1));

lineVAR = find_index_list( list_output_str, "Price|Primary Energy|Oil"); // US$2005/GJ
weightLine = find_index_list( list_output_str, "Primary Energy|Oil"); 
outputs_temp(nbLines*reg+lineVAR,current_time+1) = sum(outputs_temp(nbLines*[0:11] + weightLine,current_time+1) .* outputs_temp(nbLines*[0:11] + lineVAR,current_time+1))./sum(outputs_temp(nbLines*[0:11] + weightLine,current_time+1));

lineVAR = find_index_list( list_output_str, "Price|Secondary Energy|Electricity"); // US$2005/GJ
weightLine = find_index_list( list_output_str, "Secondary Energy|Electricity"); 
outputs_temp(nbLines*reg+lineVAR,current_time+1) = sum(outputs_temp(nbLines*[0:11] + weightLine,current_time+1) .* outputs_temp(nbLines*[0:11] + lineVAR,current_time+1))./sum(outputs_temp(nbLines*[0:11] + weightLine,current_time+1));

lineVAR = find_index_list( list_output_str, "Price|Secondary Energy|Liquids"); // US$2005/GJ
weightLine = find_index_list( list_output_str, "Secondary Energy|Liquids"); 
outputs_temp(nbLines*reg+lineVAR,current_time+1) = sum(outputs_temp(nbLines*[0:11] + weightLine,current_time+1) .* outputs_temp(nbLines*[0:11] + lineVAR,current_time+1))./sum(outputs_temp(nbLines*[0:11] + weightLine,current_time+1));

lineVAR = find_index_list( list_output_str, "Price|Secondary Energy|Liquids|Biomass"); // US$2005/GJ
weightLine = find_index_list( list_output_str, "Secondary Energy|Liquids|Biomass"); 
outputs_temp(nbLines*reg+lineVAR,current_time+1) = sum(outputs_temp(nbLines*[0:11] + weightLine,current_time+1) .* outputs_temp(nbLines*[0:11] + lineVAR,current_time+1))./sum(outputs_temp(nbLines*[0:11] + weightLine,current_time+1));


lineVAR = find_index_list( list_output_str, "Price|Secondary Energy|Gases|Natural Gas"); // US$2005/GJ
outputs_temp(nbLines*reg+lineVAR,current_time+1) = %nan;

lineVAR = find_index_list( list_output_str, "Trade|Primary Energy|Biomass|Volume"); // US$2005/GJ
outputs_temp(nbLines*reg+lineVAR,current_time+1) = 0;

// compute indexes

if is_terminate
    lineVAR = find_index_list( list_output_str, "Price|Agriculture|Non-Energy Crops|Index"); 
    outputs_temp(nbLines*[0:12] + lineVAR,current_time+1) = outputs_temp(nbLines*[0:12] + lineVAR,current_time+1) ./ outputs_temp(nbLines*[0:12] + lineVAR,4);
end


// outputs Imaclim drivers for NLU
// usefull to run NLU without running Imaclim
// will be only present in full output file.
counter_NLU = 1;
varname_driver = 'Imaclim2NLU|Secondary Energy|Price|Lightoil';
if current_time==1 ; list_output_str($+1) = varname_driver; end;
outputs_temp(nbLines*13+counter_NLU+4*12,current_time+1) = wlightoil_price ;
if current_time_im==1 ; list_output_unit($+1) = "US$2005/tep";
end;

counter_NLU = counter_NLU +1;
varname_driver = 'Imaclim2NLU|Primary Energy|Price|Gas';
if current_time==1 ; list_output_str($+1) = varname_driver; end;
outputs_temp(nbLines*13+counter_NLU+4*12,current_time+1) = wnatgas_price ;
if current_time_im==1 ; list_output_unit($+1) = "US$2005/tep";
end;

counter_NLU = counter_NLU +1;
varname_driver = 'Imaclim2NLU|Current time';
if current_time==1 ; list_output_str($+1) = varname_driver; end;
outputs_temp(nbLines*13+counter_NLU+4*12,current_time+1) = current_time +1;
if current_time_im==1 ; list_output_unit($+1) = "";
end;

counter_NLU = counter_NLU +1;
varname_driver = 'Imaclim2NLU|Current year';
if current_time==1 ; list_output_str($+1) = varname_driver; end;
outputs_temp(nbLines*13+counter_NLU+4*12,current_time+1) = current_time +1 + 2000;
if current_time_im==1 ; list_output_unit($+1) = "";
end;




// =============================================== //

execstr(" outputs_"+ETUDE+" = outputs_temp;");
mkcsv( 'outputs_'+ETUDE );


//chekc lentght of list
if current_time==1
    if nbLines <> size(list_output_str) - nbvar_NLU_driver
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
        //
        fileout = mopen(OUTPUT+'/list_outputs_units.csv', "w");
        for ii=1:(nb_regions+1)
            for elt=1:nbLines
                mfprintf(fileout,"%s\n", list_output_unit(elt))
            end
        end
        mclose(fileout);
        //
        fileout = mopen(OUTPUT+'/list_outputs_units_withNLU.csv', "w");
        for ii=1:(nb_regions+1)
            for elt=1:nbvar_NLU_driver
                mfprintf(fileout,"%s\n", list_output_str(nbLines+elt))
            end
        end
        for elt=["$/tCO2", "billion US$2005/yr", "million", "Mkcal/yr"]
            for ii=1:(nb_regions+1)
                mfprintf(fileout,"%s\n", elt)
            end
        end
        for elt=["US$2005/tep","US$2005/tep","",""]
            mfprintf(fileout,"%s\n", elt)
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
        list_output_comments(nbLines+1)="";// usefull to be sure the list is at least as big as nbLines
        for ii=1:(nb_regions+1)
            for ii=1:nbLines
                if isempty(list_output_comments(ii))
                    elt="";
                else
                    elt=list_output_comments(ii);
                end
                mfprintf(fileout,"%s\n", elt)
            end
        end
        mclose(fileout);
    end
end
