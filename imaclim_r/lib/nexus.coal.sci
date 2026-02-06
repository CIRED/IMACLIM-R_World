// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


function [ress_CAC_out]=compute_cumulative_curve(ress_CAC_in, Q_cum_reg)
    ress_CAC_out = ress_CAC_in;
    for r=1:reg
        i=1;
        while Q_cum_reg(r) > 0 & i<= size(ress_CAC_out.quant,"c")
            ress_CAC_quant_temp = ress_CAC_out.quant(r,i);
            ress_CAC_out.quant(r,i) = max(0, ress_CAC_out.quant(r,i)-Q_cum_reg(r));
            Q_cum_reg(r) = Q_cum_reg(r) - ress_CAC_quant_temp;
            i = i + 1;
        end
        //i = min(find( ress_CAC_out.quant(r,:) <> 0));
        //ress_CAC_out.costs_current(r,1) = ress_CAC_in.costs(r,i);
    end

endfunction


function [ress_CAC_out] = shorten_CAC(ress_CAC_in, delta)
    //remove costs categories with zero reserves / resource
    ress_CAC_out = ress_CAC_in;
    list_ind_max = zeros(reg,1);
    for k=1:reg
        i = max(find(ress_CAC_in.quant(k,:) >0));
        list_ind_max(k) = i;
    end
    max_of_max = max(list_ind_max);
    ress_CAC_out.quant = ress_CAC_in.quant(:,1:max_of_max);
    ress_CAC_out.costs = ress_CAC_in.costs(:,1:max_of_max);
endfunction

function [ress_CAC_out] = expand_CAC(ress_CAC_in, delta)
    ress_CAC_out = ress_CAC_in;
    max_cost = max( ress_CAC_out.costs(:,$));
    // split costs into more categories
    new_costs = linspace(0, max_cost, delta);
    // include old costs
    for ic=1:size(ress_CAC_out.costs,'c')
        cost = ress_CAC_out.costs(1,ic);
        if find( cost==new_costs) == []
            i_insert = max(find( cost>=new_costs));
            new_costs = [new_costs(1:i_insert), cost, new_costs(i_insert+1:$)];
        end
    end
    ress_CAC_out.new_costs = ones(reg,1) * new_costs;
    // expand the cost curve
    ress_CAC_out.new_quant = zeros( ress_CAC_out.new_costs);
    for ic=1:size(ress_CAC_out.new_costs,'c')
        cost = ress_CAC_out.new_costs(1,ic);
        ind_list_cost_inf = find( ress_CAC_out.costs(1,:) < cost);
        ind_list_cost_sup = find( ress_CAC_out.costs(1,:) >= cost);
        if size(ind_list_cost_inf,'c') == 0 & ind_list_cost_sup(1) == cost
            //give all ressource to that price category
            for r=1:reg
                ress_CAC_out.new_quant(r,ic) = ress_CAC_out.new_quant(r,ind_list_cost_sup(1));
            end
        elseif size(ind_list_cost_inf,'c') >= 0
            ind_inf = find( ress_CAC_out.new_costs(1,:) == ress_CAC_out.costs(1,ind_list_cost_inf($)));
            ind_sup = find( ress_CAC_out.new_costs(1,:) == ress_CAC_out.costs(1,ind_list_cost_sup(1)));
            if ind_inf==[]
                ind_inf=0;
            end
            // split into the number os sub-categories
            nb_cat =  ind_sup - ind_inf;
            for r=1:reg
                ress_CAC_out.new_quant(r,ic) = ress_CAC_out.quant(r,ind_list_cost_sup(1)) / nb_cat;
            end
        end
    end
    ress_CAC_out.costs = ress_CAC_out.new_costs;
    ress_CAC_out.quant = ress_CAC_out.new_quant;
    ress_CAC_out.new_costs = null();
    ress_CAC_out.new_quant = null();

endfunction

function [ress_CAC_out] = compute_RP_ratio(ress_CAC_in, p, Qref)
    ress_CAC_out = ress_CAC_in;
    ress_CAC_out = compute_reserve(ress_CAC_out, p)
    ress_CAC_out.RP_ratio = ress_CAC_out.reserve ./ Qref';
    for r=1:reg
        if ress_CAC_out.RP_ratio(r) == 0
            ress_CAC_out.RP_ratio(r) = min(ress_CAC_out.RP_ratio(ress_CAC_out.RP_ratio > 0));
            ress_CAC_out.reserve(r) = ress_CAC_out.RP_ratio(r) * Qref(r);
        end
    end
    ress_CAC_out.reserve = null();

endfunction

function [ress_CAC_out] = compute_reserve(ress_CAC_in, p)
    ress_CAC_out = ress_CAC_in;
    ress_CAC_out.reserve = zeros(1,reg);
    for r=1:reg
        cost_cat = find(ress_CAC_out.costs(r,:) <= p_reserve_t0 * p(r) / pref(r));
        ress_CAC_out.reserve(1,r) = sum( ress_CAC_out.quant(r,cost_cat));
    end
endfunction

function [ress_CAC_out] = compute_costs_current(ress_CAC_in, Qref)
    ress_CAC_out = ress_CAC_in;
    ress_CAC_out.reserve_needed = ress_CAC_out.RP_ratio .* Qref';
    ress_CAC_out.costs_current = zeros(1,reg);
    for r=1:reg
        ic=1;
        while ress_CAC_out.reserve_needed(r) > 0 & ic < size(ress_CAC_out.quant,'c')
            ress_CAC_out.reserve_needed(r) = ress_CAC_out.reserve_needed(r) - ress_CAC_out.quant(r,ic);
            ic = ic + 1;
        end
        if sum(ress_CAC_out.quant(r,1:ic)) <> 0
            ress_CAC_out.costs_current(1,r) = sum(ress_CAC_out.quant(r,1:ic) .* ress_CAC_out.costs(r,1:ic)) / sum(ress_CAC_out.quant(r,1:ic));
        else
            ress_CAC_out.costs_current(1,r) = ress_CAC_out.costs_last(1,r) * 1.005;
        end
    end
    ress_CAC_out.costs_last = ress_CAC_out.costs_current;
endfunction

