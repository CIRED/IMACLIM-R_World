// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Yann Gaucher
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

////////////////////////////////////////////////////////////////////////////////////
//////////// CALIBRATION OF EXOGENOUS SHOCKS ON GDP ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

// The aim to calibrate the change in A in order to apply direct damages f(T) = (Yb-Yd)/Yb as targeted in COACCH.
// We are thus looking for a scale factor sf such that: delta_A = sf * f(T) and 1-Y(Ab+delta_A)/Y(Ab) = f(T)
// We do this by approximating the sf as (dln(Y)/dA)^-1 (Y = GDP, d = with damages at time t, b= without damages at time t).

// The scale factor sf evolves with time, firstly because of structural change, and maybe also because of the non-linearity of ln(Y) with regard to A.
// Thus, scale factor is not updated each year, this evolution of dln(Y)/dA leads to a mismatch between the direct damages applied and the damage function (D.F.).
// For the COACCH (model-based) DF, the damages are assumed to allready include structural change, thus we want to avoid this mismatch.

// We want to avoid that the calibration of delta_A is disturbed by the nonlinearity of ln(Y) with regard to A. 
// Since scale factor do not change abruptly, we use the slope between Y(Ab) and Y(Ab + sf(t_1)*f(T(t)) 
// Therefore, we would like to find sf such that: f(T) =  1-Y(Ab+sf*f(T))/Y(Ab) for Ab=1 and value of delta_A such that Ad = Ab+delta_A.
// Assumptions: dln(Y)/dA does not evolve too fast over time (we only correct the scaling factor ex-post) 

jacobian_param = 5000; 

if current_time_im==1
    scaleShock=ones(reg,1);
    sg_add("scaleShock");
    sg_add("dGDP_dA");
    sg_add("GDP_PPP_nodamages");
end
if current_time_im < start_year_policy-base_year_simulation+1
    A = ones(reg,sec);
    A_CI=A;
end
if current_time_im>start_year_policy-base_year_simulation // Calibration is neither needed nor possible for the first year.
    GDP_PPP_constant_orig=GDP_PPP_constant;
    Q_orig=Q;
    Aprev=A;
    equilibrium_orig=equilibrium;

    scaleShock_prev=scaleShock;
    // Calibration of the damage at each timestep
    //Computation of the jacobian near current value of A:
    for j = nbsecteurenergie+1:sec
        A(:,j)=A(:,j)+1/jacobian_param;        
    end

    A_CI=A;
    [equilibrium, v, info]=solve_equilibrium(equilibrium,equi_function);

    if norm(v)<3d-3
        disp( "General Equilibrium for jacobian calibration: [FOUND] "+norm(v)); 
    else
        disp( "General Equilibrium for jacobian calibration was not FOUND =("+norm(v))
        mkalert( "error")
        pause
    end

    exec(MODEL+"extraction-generic.sce");
    dGDP_dA = jacobian_param*(GDP_PPP_constant-GDP_PPP_constant_orig); //negative quantity

    // Computation of counterfactual GDP without damages:
    if ind_impacts==2
        if norm(damageLevel(:,indice_industries($)))>1.83d-3 // If damages are "significant" (maybe adjust this later), we compute counterfactual GDP
            A = ones(reg,sec);
            A_CI=A;
            [equilibrium, v, info]=solve_equilibrium(equilibrium_orig,equi_function);
            if norm(v)<3d-3
                disp( "General Equilibrium fexor no-damage GDP computation: [FOUND] "+norm(v)); 
            else
                disp( "General Equilibrium for no-damage GDP computation was not FOUND =("+norm(v));
                searching= %t;
                step_size_nodam=1;
                substep_nodam=1;
                while searching
                    //looking for intermediate equilibrium:
                    step_size_nodam=step_size_nodam/2;
                    A = Aprev+ step_size_nodam*(ones(reg,sec)-Aprev);
                    A_CI=A;
                    [equilibrium_nodam, v, info]=solve_equilibrium(equilibrium_orig,equi_function);
                    if norm(v)<3d-3
                        disp( "Intermediate Equilibrium for no-damage GDP computation: [FOUND] "+norm(v) +", step: "+step_size_nodam);
                        searching=%f;
                    elseif step_size_nodam<1/2^4
                        searching=%f;
                        error("No equilibrium found for calibration of damages. I give up !");
                    end
                end
                A = ones(reg,sec);
                A_CI=A;
                guess_equilibrium = (1-1/step_size_nodam)*equilibrium_orig + 1/step_size_nodam*equilibrium_nodam;
                [equilibrium, v, info]=solve_equilibrium(guess_equilibrium,equi_function);
                if norm(v)<3d-3
                    disp( "General Equilibrium for no-damage GDP computation: [FOUND] "+norm(v)); 
                else
                    error("No equilibrium found for calibration of damages. You must complete the search code !");
                end
            end
            exec(MODEL+"extraction-generic.sce");
            GDP_PPP_nodamages=GDP_PPP_constant;
            // solve equilibrium & compute new GDP value
            scaleShock=scaleShock_prev+(GDP_PPP_nodamages.*(1-damageLevel(:,indice_industries($)))-GDP_PPP_constant_orig)./(damageLevel(:,indice_industries($)).*dGDP_dA);
            disp("Calibration of shocks, using no-damage GDP, DONE");
        

        else // damages are too small to compute the scale factor
            GDP_PPP_nodamages=GDP_PPP_constant;
            scaleShock=-(GDP_PPP_constant./dGDP_dA); 
            disp("Calibration of shocks, using only the jacobian, DONE");
        end
    end
    if current_time_im < TimeHorizon + 1 //Check that the scale does not evolve "too slowly"
        scaleShock_ref=scaleShock; // Changed 03.03.2025: purpose is to follow more strictly the damage function
    end

    // Put things back in order:
    A =Aprev;
    A_CI=A;
    [equilibrium, v, info]=solve_equilibrium(equilibrium_orig,equi_function);
    exec(MODEL+"extraction-generic.sce");

    //GDP change is reversed:
    dGDP2=(GDP_PPP_constant_orig-GDP_PPP_constant)/GDP_PPP_constant_orig;
    equilibrium=equilibrium_orig;
end
