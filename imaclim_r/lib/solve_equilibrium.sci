// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function [equilibrium,v,info] = solve_equilibrium(equilibrium,f)
    //founds equilibrium as f(equilibrium)=0
    //equilibrium is generally the previous equilibrium
    //f is the function that encapsulates all the system's equations, it can be the string 
    //'economyC' our the function economy
    // coef_Q_CO2_CI;
    // coef_Q_CO2_CI(coef_Q_CO2_CI<0)=0;

    global nb_fsolve
    
    //C parameters update
    call("import_parameters_dynamic_scilab2C");

    [equilibrium,v,info] = fsolve(equilibrium,f); 

    nb_fsolve=nb_fsolve+1;
    //[equilibrium,v,info] = fsolve(guess,economy);
    stop=0;
    max_abs_sol=max(abs(v));
    max_abs_sol_prev=max_abs_sol;

    trial =1;
    if (max(abs(v))>sensibility) then 
        //disp("solve test number "+string(trial)+ ' failed , doing another try');
        [equilibrium,v,info] = fsolve(equilibrium,f);
        max_abs_sol=max(abs(v));
        if max_abs_sol>=max_abs_sol_prev then stop=1; end
        max_abs_sol_prev=max_abs_sol;
        //[equilibrium,v,info] = fsolve(guess,economy);
        nb_fsolve=nb_fsolve+1; 
    end

    trial =2;
    if (max(abs(v))>sensibility)&(stop==0) then 
        //disp("solve test number "+string(trial)+ ' failed , doing another try');
        [equilibrium,v,info] = fsolve(equilibrium,f);
        max_abs_sol=max(abs(v));
        if max_abs_sol>=0.95*max_abs_sol_prev then stop=1; end
        max_abs_sol_prev=max_abs_sol;
        //[equilibrium,v,info] = fsolve(guess,economy);
        nb_fsolve=nb_fsolve+1; 
    end


    trial =3;
    if (max(abs(v))>sensibility)&(stop==0) then 
        //disp("solve test number "+string(trial)+ ' failed , doing another try');
        [equilibrium,v,info] = fsolve(equilibrium,f);
        max_abs_sol=max(abs(v));
        if max_abs_sol>=0.95*max_abs_sol_prev then stop=1; end
        max_abs_sol_prev=max_abs_sol;
        //[equilibrium,v,info] = fsolve(guess,economy);
        nb_fsolve=nb_fsolve+1; 
    end
    trial =4;
    if (max(abs(v))>sensibility)&(stop==0) then 
        //disp("solve test number "+string(trial)+ ' failed , doing another try');
        [equilibrium,v,info] = fsolve(equilibrium,f);
        max_abs_sol=max(abs(v));
        if (max_abs_sol<max_abs_sol_prev/2)&(max(abs(v))>sensibility) then
            [equilibrium,v,info] = fsolve(equilibrium,f);
            max_abs_sol_prev=max_abs_sol;
            max_abs_sol=max(abs(v));
        end

        if (max_abs_sol<max_abs_sol_prev/2)&(max(abs(v))>sensibility) then
            [equilibrium,v,info] = fsolve(equilibrium,f);
            max_abs_sol_prev=max_abs_sol;
            max_abs_sol=max(abs(v));
        end
        if (max_abs_sol<max_abs_sol_prev/2)&(max(abs(v))>sensibility) then
            [equilibrium,v,info] = fsolve(equilibrium,f);
            max_abs_sol_prev=max_abs_sol;
            max_abs_sol=max(abs(v));
        end
        if (max_abs_sol<max_abs_sol_prev/2)&(max(abs(v))>sensibility) then
            [equilibrium,v,info] = fsolve(equilibrium,f);
            max_abs_sol_prev=max_abs_sol;
            max_abs_sol=max(abs(v));
        end
        //[equilibrium,v,info] = fsolve(guess,economy);
        nb_fsolve=nb_fsolve+1; 
    end
endfunction
