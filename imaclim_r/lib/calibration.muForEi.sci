// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Julie Rozenberg, Florian Leblanc, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// finalLevel          = 0.9;
// leaderEvolution         = 0.98; //(équivaut à une baisse de -0.02)
// EI_ref           = 1.2;
// EI_lead_ref       = 1;
// X              = 10;
// Y              = 0.811778793;
// leadObjective  = EI_lead_ref*leaderEvolution^X;
// current_time_im = 1;

// 1. Function that from EI(t-1) givese EI(t)
function [EI_current]=fEI_next(EI_prev,t)
    EI_lead = EI_lead_ref*leaderEvolution^t; // Y.G.: -1 instead of -2 because t = 0 at calibration. 
    EI_current = EI_prev*leaderEvolution*muEi^t + EI_lead/finalLevel*(1-muEi^t);
endfunction

// 2. Recursive function that from EI_current and X gives EI_in_X_years (for a following region)
function [EI_in_1_years,X,current_time_im]=fEI_in_X_years(EI_current,X,current_time_im)
    current_time_im=current_time_im+1;
    EI_in_1_years = fEI_next(EI_current,current_time_im);
    while X>1
        current_time_im=current_time_im+1;
        X = X-1;
        EI_in_1_years = fEI_next(EI_current,current_time_im);
    end
endfunction

// 3. Function that gives the equation of muEi in the form f(muEi)=0
function [eqn]=eqnMu(muEi)
    leadObjective=EI_lead_ref*leaderEvolution^X;
    EI_t0_plus_X_years = fEI_in_X_years(EI_ref, X,current_time_im); // EI at t0 plus X years: 
    eqn = leadObjective/finalLevel-EI_t0_plus_X_years - Y*(EI_lead_ref/finalLevel-EI_ref);
endfunction

function [muEi ,v ,info] = calibreMu(finalLevel,leaderEvolution,EI_ref,EI_lead_ref,X,Y,current_time_im) 
    //                        muEi(region,sect)=calibreMu(finalLevel(sect),leaderEvolution(sect),EI_ref(region,sect)  ,EI_lead_ref(sect),X(region,sect) ,Y(region,sect) ,current_time_im);
    // Gives in X years, the difference between the energy intensity of the follower and the asymptot was multiplied by Y (<1).
    [muEi ,v ,info]=fsolve(1,eqnMu);
endfunction
