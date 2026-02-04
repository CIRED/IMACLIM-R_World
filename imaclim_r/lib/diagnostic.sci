// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

////////////////////////////////////////////////////////
///////////////Diagnostic functions ////////////////////
////////////////////////////////////////////////////////


function y=vettings_control(var,target,lower_b,upper_b,unit_var)
//the var term is the variable to be tested, between quotes
// target, lower_b and upper_b are numerical values and correspond to the central target values and the tolerance
// unit_var a string as well   
//if the vetting is one side (we want some value to be at least lower/higher than X) then introduce some %inf in the formula
    var_test = var;
    targ = target;
    l_b = lower_b;
    u_b = upper_b;
    unit = unit_var

    if evstr(var_test)>targ*(1-l_b) & evstr(var_test)<targ*(1+u_b)
        y="Vetting " + var_test+ " passed: "+ var_test + " = " + string(evstr(var_test))+" "+ unit+ " between "+string(targ*(1-l_b))+" "+ unit+ " and " + string(targ*(1+u_b)) +" "+ unit
    else
        y="!! WARNING!! Vetting " + var_test+ " failed: "+ var_test + " = "  + string(evstr(var_test))+" "+ unit  + " outside " +string(targ*(1-l_b))+" "+ unit+ " and " + string(targ*(1+u_b))+" "+ unit
    end

endfunction

function y=compute_emi_ccs(energy_balance,msh_elec_techno,coef_Q_CO2_ref,share_CCS_CTL)
    y = 0;
    for k=1:nb_regions
        y = (coef_Q_CO2_ref(k,coal) * ( - energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k) ..
        + energy_balance(pwplant_eb,elec_eb,k)* sum(msh_elec_techno(k,[indice_PSS indice_CGS])) ..
        - energy_balance(losses_eb,coal_eb,k)* share_CCS_CTL(k)..
        ) ..
        - coef_Q_CO2_ref(k,et)  * energy_balance(losses_eb,et_eb,k) * share_CCS_CTL(k) ..
        - coef_Q_CO2_ref(k,oil) * energy_balance(losses_eb,oil_eb,k) * share_CCS_CTL(k) ..
        + coef_Q_CO2_ref(k,gaz) * (..
        - energy_balance(refi_eb,   gaz_eb,k) * share_CCS_CTL(k) ..
        - energy_balance(losses_eb, gaz_eb,k) * share_CCS_CTL(k) ..
        + energy_balance(pwplant_eb,elec_eb,k)  * sum(msh_elec_techno(k,[indice_GGS])) ..
        ) )/1e6;
    end
endfunction
