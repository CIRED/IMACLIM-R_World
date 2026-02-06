// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Adrien Vogt-Schilb
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


if ~ind_static_choc
    message("        Moving dynamic coefficients from "+(base_year_simulation+current_time_im+last_found_substep)+" to "+(base_year_simulation+current_time_im+substep) );
    execstr ( hyp_params+"=(1-substep)*"+hyp_params+"_prev+substep*"+hyp_params+"_obj")
    execstr ( mat_params+"=(1-substep)*"+mat_params+"_prev+substep*"+mat_params+"_obj")
else    // Static Shock: between TimeHorizon-1 and TimeHorizon, change any static parameters (here, we change the matrix A) while keeping everything else constant. Comparison of last & pre-last timesteps of the output thus allows to isolate the effects of any parameter of the static equilibrium.
    message("        Moving dynamic coefficients from "+(base_year_simulation+current_time_im+last_found_substep)+" to "+(base_year_simulation+current_time_im+substep) );
    execstr ( hyp_params+"=(1-substep)*"+hyp_params+"_prev+substep*"+hyp_params+"_obj")
    execstr ( mat_params+"=(1-substep)*"+mat_params+"_prev+substep*"+mat_params+"_obj")
    if current_time_im == TimeHorizon
        A = ones(reg,sec);
        A_prev=A;
        // Here, reduce sector productivity by 1% in sector "impacted sector" of region 'ind_country_choc'. If 0, all sectors or regions are impacted.
        if impacted_sector>0
            if ind_country_choc >0
                A(ind_country_choc,impacted_sector) = 1+1/100
            end
            if ind_country_choc==0
                A(:,impacted_sector) = A(:,impacted_sector).*(1+1/100*ones(reg)');
            end
        end
        if impacted_sector==0
            if ind_country_choc >0
                for j =1:sec
                    A(ind_country_choc,j) = (1+1/100);
                end
            end
            if ind_country_choc==0
                A = A*(1+1/100);
            end
        end
        A_obj=A;
        message("    Keeping dynamic coefficients constant from "+(base_year_simulation+current_time_im+last_found_substep)+" to "+(base_year_simulation+current_time_im+substep) );
        execstr ( hyp_params+"="+hyp_params+"_prev")
        execstr ( mat_params+"="+mat_params+"_prev")
        execstr ( "    A=(1-substep)*A_prev+substep*A_obj")
    end    
end
