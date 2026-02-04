// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera, Ruben Bibas, Adrien Vogt-Schilb, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


function matMKT = mktagg(matreg,usage)
//aggrege des series horizonatales avec une ligne par region en series avec une ligne par marché
//travail sur la base de whichMKT_reg_use(:,usage)

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
//Definition des objectifs d'emissions à partir des MKT_var et de la baseline

CO2_obj_MKT = %inf * ones(nbMKT,TimeHorizon+1)
CO2_base_MKT = zeros(nbMKT,TimeHorizon+1)

    //Calcul des emissions de la baseline
    for m=1:nbMKT;
        for t=1:TimeHorizon+1
            E_use_reg_temp = matrix(E_reg_use_base(:,t),nb_use,reg);
            CO2_base_MKT(m,t)   = sum(E_use_reg_temp(whichMKT_reg_use==m)) ;
        end
    end
    
    CO2_obj_MKT=traj_from_points (CO2_base_MKT)
    
endfunction


function [CO2_base_MKT]=MKT_base_emis(whichMKT_reg_use)
//Definition des emissions dans la baseline par marche

ldsav("E_reg_use_sav","",baseline_combi,suffix2combi)
T = size(E_reg_use_sav,2)-1;
CO2_base_MKT = zeros(nbMKT,TimeHorizon+1)
E_reg_use_base = E_reg_use_sav;
 
    //Calcul des emissions de la baseline
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
    title 'please check objectives and close this windows'
    plot(0) //scaling purpose
endfunction
function CO2_obj_MKT = traj_from_points (CO2_MKT,MKT_constr_years,MKT_start_year,MKT_constr_indice,MKT_nb_constr)
//Definition des objectifs a partir de la baseline, annee de depart, nombre de contraintes, annee de passage et valeur de passage
//Les contraintes sur les objectifs d emissions sont:lineaire apres MKT_start_year, puis monotone apres le premier point.
//N'utilisez pas cette fonction si vous ne recherchez aps cette forme
//CO2_MKT : emissions en baseline
//MKT_constr_years : années des points de passage
//MKT_start_year : année de départ de la taxe
//MKT_constr_indice : points de passage en indice
//MKT_nb_constr : nombre de points de passage
//Les arguments peuvent etre empilees en matrice, une ligne par marche d'emissions

    //nombre de lignes = nombre de marchés
    nb_MKT = size(MKT_constr_years,1)

    if size(MKT_constr_indice,1)~=nb_MKT | size(MKT_start_year,1)~=nb_MKT |size(MKT_constr_years,1)~=nb_MKT |size(MKT_nb_constr,1)~=nb_MKT 
        error ( 'les arguments devraient tous avoir nb_MKT lignes')
    end

    if size(CO2_MKT,1)<nb_MKT
        error ( "CO2_MKT doesn''t have enough lines")
    end
    
    CO2_obj_MKT=%inf * ones(nb_MKT,TimeHorizon+1)
    
    for m=1:nb_MKT
    
        //Definit les emisisons en niveau a partir des emissions de la baseline et de l'indice de reduction
        MKT_constr_emiss(m,:) = MKT_constr_indice(m,:).*CO2_MKT(m,1);
   
        // lineaire au debut, tendance vers une reduction anuelle constante à la fin, interdiction de croitre apres le premier point de passage
  
        //case des marches non contraints
        if MKT_nb_constr(m)==0 | ~is_quota_MKT(m)
            continue
        else //cas des marches contraints
            //premiere partie lineaire
            x=1:MKT_constr_years(m,1)
            xx = [ 1:MKT_start_year(m), MKT_constr_years(m,1) ]
            yy = [CO2_MKT(m,1:MKT_start_year(m)), MKT_constr_emiss(m,1)]
            CO2_obj_MKT(m,x)= interpln( [ xx; yy], x)

             if MKT_nb_constr(m)>1   
                //seconde partie monotone
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