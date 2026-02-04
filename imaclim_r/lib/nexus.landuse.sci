// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Nicolas Graves, Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// ##############################################
// Calibration.nexus.landuse.sce functions
// ##############################################

// reaggregates the GTAP aggregation made for the agri sector (while coupling with nexus land-use) (it deals with every agri sectors + chemestry)
function matOut = reaggGTAP_NLU(matIn)
	matOut = matIn;
	matOut(:,indus) = matIn(:,indus_IndNLU) + matIn(:,chemi_IndNLU );
	matOut(:,agri) = sum(matIn(:,listAgriSectors_Ind),'c');
	indices2remove = listAgriSectors_Ind;
	indices2remove($+1) = chemi_IndNLU;
	indxTmp = 1
	for indx=1:size(indices2remove,'r')
		if (indices2remove(indxTmp)==agri | indices2remove(indxTmp)==indus)
			indices2remove(indxTmp)=[];
		else indxTmp = indxTmp+1;
		end
	end
	for indx=(nb_sectors+1):size(matIn,'c')
		indices2remove($+1) = indx;
	end
	matOut(:,indices2remove)=[];
endfunction

// ##############################################
// nexus.landuse.sce functions
// ##############################################

function [x,y] = add_to_supplycurve(xin, yin, xnew, ynew)
           
        // function that add a new vector xnew ynew of n dimenssion to a matrix (n,m), sorted by column in term of increasing values of x
        i_elt = size(xin,1);
        j_elt = size(xin,2);

        [wheretox, wheretoy] = find( xin<= xnew * ones(1,size(xin,"c")));
        //wheretostore = matrix( wheretostore, i_elt, size(wheretostore,"c") / i_elt);
        //for ii=1:size(wheretostore,"c")
        //  wheretostore(:,ii) = (wheretostore(:,ii) - 1 - modulo( wheretostore(:,ii)-1, ii*12)) ./ (ii*12) +1;
        //end
        //wheretostore = max(wheretostore, "c");

        x = [xin xnew];
        y = [yin ynew];
    
        for ii=1:i_elt
          whereto = max( wheretoy(find( wheretox == i_elt)) );
          //x( ii, (wheretostore(ii) + 2):(j_elt+1)) = x( ii, (wheretostore(ii) + 1):j_elt);
          //x( ii, (wheretostore(ii) + 1)) = xnew(ii) ;
          //y( ii, (wheretostore(ii) + 2):(j_elt+1)) = y( ii, (wheretostore(ii) + 1):j_elt);
          //y( ii, (wheretostore(ii) + 1)) = ynew(ii) ;
          x( ii, (whereto + 2):(j_elt+1)) = x( ii, (whereto + 1):j_elt);
          x( ii, (whereto + 1)) = xnew(ii) ;
          y( ii, (whereto + 2):(j_elt+1)) = y( ii, (whereto + 1):j_elt);
          y( ii, (whereto + 1)) = ynew(ii) ;
        end    
endfunction

function elast_biofuel = build_SC2G_elast( biomass_demand_cost, biomass_demand_quant, x_vect)
    elast_biofuel = zeros( nb_regions, size(x_vect,"c"));
    nb_elt_sc = size(biomass_demand_cost,"c");
    for kk=1:nb_regions
      for ii=1:size(x_vect,"c")
        whereto = find( biomass_demand_cost(kk,:) < x_vect(ii));
        whereto = max(whereto, "c");
        if whereto == nb_elt_sc; // for last point available in supply curve
          whereto = whereto-1;   
          //disp(whereto)
        end
        if whereto == []
          whereto = 1;
        end
        if biomass_demand_cost(kk,whereto) == 0
          xcost=biomass_demand_cost(kk,whereto+1);
        else
          xcost=biomass_demand_cost(kk,whereto)
        end
        if biomass_demand_quant(kk,whereto) == 0
          ycost=biomass_demand_quant(kk,whereto+1);
        else
          ycost=biomass_demand_quant(kk,whereto)
        end
        elast_biofuel(kk,ii) = divide( log( divide(xcost, biomass_demand_cost(kk,whereto+1),1) ), log( divide(ycost, biomass_demand_quant(kk,whereto+1),1) ), 0);
      end
    end
endfunction

function zeros = fixedpoint_keyBiofuel(xloc_key)
        glob_in_bioelec_Et = glob_in_bioelec_Et + step_increase2G;
        //glob_in_bioelec_Et_reg = glob_in_bioelec_Et_reg + key_repart_Qbiofuel' .*step_increase2G;
        Qbiofuel_NLU = ( prod_agrofuel + (glob_in_bioelec_Et_reg_0 + xloc_key' .*glob_increase2G) / gj2G_2_gjbiom)' / mtoe2ej / Exajoule2Mkcal;
        Tot_bioelec_cost_del = zeros(nb_regions, 1);
        for kk=1:nb_regions
          Tot_bioelec_cost_del(kk) = interpln([biomass_demand_quant(kk,:);biomass_demand_cost(kk,:)],Qbiofuel_NLU(kk));
        end     
        bioener_costs_NLU = pind .* ethan2G_transfo_cost + Tot_bioelec_cost_del .* tep2gj .* gj2G_2_gjbiom;
        biofuel1G_costs_NLU  = bioener_costs_NLU;
        share1G = divide(prod_agrofuel' , Qbiofuel_NLU * mtoe2ej * Exajoule2Mkcal , 1  );
        share2G = 1 - share1G ;
        biofuel_costs_NLU = share1G .* biofuel1G_costs_NLU + share2G .* bioener_costs_NLU ;
        bioener_costs_NLU_diff = profitable_2G .*(p(:,et)+(coef_Q_CO2_ref(:,indice_Et)-coef_Q_CO2_ethan).* expectedTaxEtDF - biofuel_costs_NLU );
        key_repart_Qbiofuel= divide( bioener_costs_NLU_diff, sum(bioener_costs_NLU_diff), 0);
        zeros = xloc_key - key_repart_Qbiofuel;
endfunction

function zeros = fixedpoint_glob_2G(xloc_glob_increase2G)
    glob_in_bioelec_Et_reg = glob_in_bioelec_Et_reg_0 + key_repart_Qbiofuel' .* xloc_glob_increase2G;
    Qbiofuel_NLU = ( prod_agrofuel + glob_in_bioelec_Et_reg / gj2G_2_gjbiom)' / mtoe2ej / Exajoule2Mkcal;
    exec(MODEL+"nexus.Et.coststruct.sce");
    //Cap_Et_NLU = max( Q_Et_anticip/0.8 , 0 ) ; 
    if wp_et_biom_forsight == "forwardlooking"
        wp_lightoil_target =  compute_wp_Et();
    else
        wp_lightoil_target =  wp_et_exp_anticip_nlu; //wp(indice_Et);
    end
    Tot_bioelec_cost_del = zeros(nb_regions, 1);
    for kk=1:nb_regions
      Tot_bioelec_cost_del(kk) = interpln([biomass_demand_quant(kk,:);biomass_demand_cost(kk,:)],Qbiofuel_NLU(kk));
    end
    bioener_costs_NLU = pind .* ethan2G_transfo_cost + Tot_bioelec_cost_del .* tep2gj * gj2G_2_gjbiom;
    wp_lightoil_comp = sum( bioener_costs_NLU .* Q(:,et) ) ./ sum( Q(:,et)) ;
    zeros = wp_lightoil_comp - wp_lightoil_target;
endfunction
