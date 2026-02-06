// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

////////////////////////////////////////////////////////////////////////////////
///////// Gas conventional - cumulative availability curves from Aguilera
////////////////////////////////////////////////////////////////////////////////

cd "../../../";
exec("externals/common_code/scilab/read_csv-5.3.3.sci");
exec('model/indexes.sce');
cd "data/Gas_resources/Aguilera_al_2009/";

// importing costs from Aguilera_al_2009 :
// supply curve from assessed region in USGS 2000
aguilera_gas_costs = read_csv_533( Aguilera_dir + '/Aguilera2009-Conventionnal_Gas_Resources.csv','|');
// unassessed region in USGS 2000 (too much aggregation here for Imaclim, so we deal with it separately)
aguilera_gas_costs_VSD = aguilera_gas_costs( (size(aguilera_gas_costs,"r")-7):size(aguilera_gas_costs,"r") ,:) ;
// truncate matrices
aguilera_gas_costs( (size(aguilera_gas_costs,"r")-7):size(aguilera_gas_costs,"r") ,:) = [] ;
aguilera_gas_costs(:,[2,5,6,7]) = [];
aguilera_gas_costs(1,:) = [];

////// dealing with "unassessed region in USGS 2000" at prorata of all basin for each region
mat_VSD_temp = [];
for ind_region = 1:size(aguilera_gas_costs_VSD(:,1) , "r")
    name_region = aguilera_gas_costs_VSD(ind_region,1) ;
    find( aguilera_gas_costs(:,1) == name_region ) ;
    mat_temp  =  aguilera_gas_costs( find( aguilera_gas_costs(:,1) == name_region ), : ) ;
    mat_temp(:,3) = string ( eval(mat_temp(:,3)) / sum( eval(mat_temp(:,3))) * eval( aguilera_gas_costs_VSD(ind_region,4) ));
    mat_temp(:,4) = string (  eval( aguilera_gas_costs_VSD(ind_region,8) ) * ones(mat_temp(:,4)) ) ;
    mat_VSD_temp = [mat_VSD_temp;mat_temp] ;
end
//aguilera_gas_costs = [aguilera_gas_costs;mat_VSD_temp] ;

// dictionary 
aguilera_dictionary = read_csv_533( './dico_aguilera2009_to_Imaclim.csv','|');

conv_gas_CC_supply = [];
conv_gas_CC_prices = [];

// data are ordered by costs in Aguilera, so we can deal with the file linearly :
for nb_basin = 1:size(aguilera_gas_costs(:,1) , "r")
    index_column= modulo( find(aguilera_dictionary == aguilera_gas_costs(nb_basin,2) )-1, nb_regions) +1;
    price_temp = eval(aguilera_gas_costs(nb_basin,4));
    supply_temp = eval(aguilera_gas_costs(nb_basin,3));
    if price_temp <> conv_gas_CC_prices($)
        conv_gas_CC_supply = [conv_gas_CC_supply zeros(nb_regions,1)] ;
        conv_gas_CC_prices = [conv_gas_CC_prices price_temp] ;
    end
    conv_gas_CC_supply(index_column,$) = conv_gas_CC_supply(index_column,$) + supply_temp ;
end


fileout = mopen('../Aguilera2009-Conventionnal_Gas_aggregated_costcurve.csv', "w");
mfprintf(fileout, "//quantities by region in BBOE|prices in 2006 US$/BOE\n");
mfprintf(fileout, "prices");
for elt = 1:size(conv_gas_CC_prices,"c")
    mfprintf(fileout, "|%.10G", conv_gas_CC_prices(elt));
end
mfprintf(fileout, "\n");
for ind_reg = 1:nb_regions
    mfprintf(fileout, "%s", regnames(ind_reg) );
    for elt = 1:size(conv_gas_CC_supply,"c")
        mfprintf(fileout, "|%.10G", conv_gas_CC_supply(ind_reg,elt));
    end
    mfprintf(fileout, "\n");
end

mclose(fileout);
