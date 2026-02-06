// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


function cum_prod=cumulative_prod_linear(y2,y1,x2,x1)
    // provide two points of yearly production, and assumes a linear decrease back
    // in time to compute cumulative production
    a=(y2-y1)/(x2-x1);
    b=y2-a*x2;
    x0=-b/a;
    cum_prod=y2*(x2-x0)/2;
endfunction

// convert regional supply curves to global Cumulative Availability Curves
function [global_cost_CACC,global_quant_CACC] = from_supplycurve_2_CACC( costs, quantities)
    global_cost_CACC = [];
    global_quant_CACC = [];
    all_cost_temp=flipdim(gsort(unique(costs(1:$)),'lr'),1);
    for cost=1:size(all_cost_temp,'r')-1
        if cost==1
            global_quant_CACC(cost) = 0;
        else
            global_quant_CACC(cost) = global_quant_CACC(cost-1);
        end
        global_cost_CACC = [global_cost_CACC all_cost_temp(cost+1)];
        for reg=1:nb_regions
            if find(costs(reg,:)==all_cost_temp(cost+1)) <> []
                global_quant_CACC(cost) = global_quant_CACC(cost) + quantities(reg, find(costs(reg,:)==all_cost_temp(cost+1)))/mtoe2ej;
            end
        end
    end
endfunction

// load fossil fuels supply curves
function [costs, quantities, nb_FF_cat] = load_FF_supply_curves(list_FF_ress, resource_name)
    nb_FF_cat = zeros( list_FF_ress);
    i_res=0;
    for resource_type=list_FF_ress
        i_res=i_res+1;
        ireg=0;
        mat_res.quant = zeros(nb_regions, 1);
        mat_res.costs = zeros(nb_regions, 1);
        for regn=regnames'
            ireg = ireg+1;
            filename = path_fossil_SC + resource_name+"_"+resource_type+"_"+regn+".csv";
            if size( mgetl(filename),"r") <>1 // avoid regions with no or zero data
                mat_sc = csvRead( path_fossil_SC + resource_name+"_"+resource_type+"_"+regn+".csv", "|",[],[],[],'/\/\//');
                //mat_sc = mat_sc(2:$,:); // to be repalced by a comment for the header in data
                mat_res.costs(ireg, 1:size(mat_sc,"r")) = mat_sc(:,1)';
                mat_res.quant(ireg, 1:size(mat_sc,"r")) = mat_sc(:,2)';
            end
        end
        nb_FF_cat(i_res) = size( mat_res.costs, "c");
        if i_res==1
            costs = mat_res.costs;
            quantities = mat_res.quant;
        else
            costs = [costs mat_res.costs];
            quantities = [quantities mat_res.quant];
        end
    end
endfunction
