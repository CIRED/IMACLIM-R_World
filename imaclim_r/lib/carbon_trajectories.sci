// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Thibault Briera, Adrien Vogt-Schilb, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


function matMKT = mktagg(matreg,usage)
    //aggregate horizontal vlaues with one line per region in serie with one line per market
    //working using  whichMKT_reg_use(:,usage)

    if argn(2)<2
        usage =1;
    end

    for m=1:nbMKT;
        matMKT(m,:)   = sum(matreg(whichMKT_reg_use(:,usage)==m,:),"r") ;

    end
    
endfunction


function matMKT = mktaggru(matreg)

    
    for m=1:nbMKT;
        for t=1:TimeHorizon+1
            E_use_reg_temp = matrix(matreg(:,t),nb_use,reg);
            matMKT(m,t)   = sum(E_use_reg_temp(whichMKT_reg_use==m)) ;
        end
    end

endfunction

function [CO2_obj_MKT, CO2_base_MKT]=MKT_define_constraints(E_reg_use_base,whichMKT_reg_use)
    //Define emission objectiv from MKT_var and the baseline

    CO2_obj_MKT = %inf * ones(nbMKT,TimeHorizon+1)
    CO2_base_MKT = zeros(nbMKT,TimeHorizon+1)

    //Computing the emissions of the baseline
    for m=1:nbMKT;
        for t=1:TimeHorizon+1
            E_use_reg_temp = matrix(E_reg_use_base(:,t),nb_use,reg);
            CO2_base_MKT(m,t)   = sum(E_use_reg_temp(whichMKT_reg_use==m)) ;
        end
    end
    
    CO2_obj_MKT=traj_from_points (CO2_base_MKT)
    
endfunction


function [CO2_base_MKT]=MKT_base_emis(whichMKT_reg_use)
    //Define the emissin baseline by market

    ldsav("E_reg_use_sav","",baseline_combi,suffix2combi)
    T = size(E_reg_use_sav,2)-1;
    CO2_base_MKT = zeros(nbMKT,TimeHorizon+1)
    E_reg_use_base = E_reg_use_sav;
 
    //Computing the emissions of the baseline
    for m=1:nbMKT;
        for t=1:TimeHorizon+1
            E_use_reg_temp = matrix(E_reg_use_base(:,t),nb_use,reg);
            CO2_base_MKT(m,t)   = sum(E_use_reg_temp(whichMKT_reg_use==m)) ;
        end
    end
endfunction



function check_objectives()
    //plot CO2 emisisons in the baseline and objective for this scenarios by MKT
    clf
    plot(CO2_base','-.')
    legend([ 'MKT_'+(1:nbMKT)]);
    plot(CO2_obj_MKT(find(is_quota_MKT),:)')
    title('please check objectives and close this windows')
    plot(0) //scaling purpose
endfunction
function CO2_obj_MKT = traj_from_points (CO2_MKT,MKT_constr_years,MKT_start_year,MKT_constr_indice,MKT_nb_constr)
    //Define the objective for the baseline, at the base year, the number of constraints, 
    Definition des objectifs a partir de la baseline, annee de depart, nombre de contraintes, annee de passage et valeur de passage
    //The constraints on emission targets are: linear after MKT_start_year, then monotonic after the first point.
    //Do not use this function if you are not looking for this form
    //CO2_MKT: baseline emissions
    //MKT_constr_years: years of transition points
    //MKT_start_year: tax start year
    //MKT_constr_index: transition points in index
    //MKT_nb_constr: number of transition points
    //number of lines = number of markets
    nb_MKT = size(MKT_constr_years,1)

    if size(MKT_constr_indice,1)~=nb_MKT | size(MKT_start_year,1)~=nb_MKT |size(MKT_constr_years,1)~=nb_MKT |size(MKT_nb_constr,1)~=nb_MKT 
        error ( 'les arguments devraient tous avoir nb_MKT lignes')
    end

    if size(CO2_MKT,1)<nb_MKT
        error ( "CO2_MKT doesn''t have enough lines")
    end
    
    CO2_obj_MKT=%inf * ones(nb_MKT,TimeHorizon+1)
    
    for m=1:nb_MKT
    
        //Define the emission level from emission of the baseline and the reducton indices
        MKT_constr_emiss(m,:) = MKT_constr_indice(m,:).*CO2_MKT(m,1);
   
        // linear at first, tendancy towards an annual constant reduction at the end, forbidden to grow after the first crossing point
  
        //Case of non constraint market
        if MKT_nb_constr(m)==0 | ~is_quota_MKT(m)
            continue
        else //Case of constraint markets
            //first part is linear
            x=1:MKT_constr_years(m,1)
            xx = [ 1:MKT_start_year(m), MKT_constr_years(m,1) ]
            yy = [CO2_MKT(m,1:MKT_start_year(m)), MKT_constr_emiss(m,1)]
            CO2_obj_MKT(m,x)= interpln( [ xx; yy], x)

            if MKT_nb_constr(m)>1   
                //the second part is monotonous
                xx = [ 1:MKT_constr_years(m,1)  MKT_constr_years(m,2:MKT_nb_constr(m)) ]
                yy = [ CO2_obj_MKT(m,x),        MKT_constr_emiss(m,2:MKT_nb_constr(m))]
                x=1:TimeHorizon+1;
                if m<3   
                    CO2_obj_MKT(m,x)= interp(x, xx, yy, splin(xx,yy,"monotone"))
                else
                    CO2_obj_MKT(m,x)= interpln( [ xx; yy], x)
                end
            end
        end
    end    

endfunction


function [tax_profile] =  CO2_tax_lin(tax_val, time_step) 
    //this function creates any linear-wise tax profile
    //tax_val and time_step are mxn size, with m the number of markets and n the number of steps in the function +1 
    //desired_steps is meant to be a control
    tax_param = size(tax_val);
    time_param = size(time_step);
    nb_market = tax_param(1);
    
    nb_step = tax_param(2); 
    
    step_C02_v = zeros(nb_market,nb_step);
    step_C02_t = zeros(1,nb_step);
    step_C02_v= tax_val;
    step_C02_t = time_step;
    
    
    tax_profile = zeros(nb_market,2101-base_year_simulation)
    for m=1:nb_market
        tax_profile(m,:) = interpln([ step_C02_t(1:nb_step); step_C02_v(m,1:nb_step)],(1:2101-base_year_simulation))
    end
    
endfunction

//find exponential tax profile from 3 points. tax = a * (1+c)^t + b profile
function [y] = find_exp_tax_1_break(xloc)

    //xloc is the value of the parameters a, b, c
    //tax_exp the three carbon tax checkpoints and time_exp the corresponding periods of the models
    a_tax = xloc(1);
    b_tax = xloc(2);
    c_tax = xloc(3);


    a_tax = (tax_exp(2)-tax_exp(1))./((1+c_tax).^(time_exp(2))-(1+c_tax).^(time_exp(1)));
    b_tax = tax_exp(1) - a_tax.*(1+c_tax).^(time_exp(1));
    c_tax = ((tax_exp(3)-b_tax)/a_tax)^(1/time_exp(3)) - 1;

    y = [xloc - [a_tax,b_tax,c_tax]];

endfunction
