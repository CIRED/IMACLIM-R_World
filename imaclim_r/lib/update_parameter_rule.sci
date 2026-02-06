// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


function y = update_parameter_rule( x, goal, init, time, t, method)
    if method == "linear"
        y =  x + ((goal-init) ./ time) * (t<=time);
    elseif method == "ci" /// special case for updating CI, with 2 global parameters year_stop_dynForc_allVar & year_stop_dynForc_CI
        time_dicoth = year_stop_dynForc_allVar-(start_year_strong_policy-1);
        time_stop = year_stop_dynForc_CI-(start_year_strong_policy-1);
        y =  x + ((goal-init) ./ time_dicoth) * (t<=time_stop);
    elseif method == "exponentialdecrease"
        alpha = (exp( 1 - divide(goal, init,0)) -1) ;
        y2 = init .* (1-log(1+alpha.* min(t,time)./time));
        y = y2;
    end
endfunction

