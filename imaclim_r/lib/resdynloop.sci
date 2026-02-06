// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//TOC
// get_taxes
// set_taxes
// cap_taxes
// choose_exotaxes
// choose_substep
// guess_next_equilibrium
// message

function tax=get_taxes(equilibrium, mkts)
    //gets the carbone value in markets mkt
    // tax = get_taxes(equilibrium,1:nbMKT)
    //
    // for m=1:nbMKT
    // tax(m) = get_taxes(equilibrium,m)
    //end

    //default values
    if argn(2) < 2
        mkts = 1:nbMKT
    end

    mkts=mkts(:) // mkts should be a column

    tax = (~is_taxexo_MKT) .* equilibrium($ + (mkts - nbMKT)) + is_taxexo_MKT .* taxMKT;

endfunction

function equilibrium=set_taxes(equilibrium, taxes, mkts)
    //gets the carbon value in markets mkt
    // tax = get_taxes(equilibrium,1:nbMKT)
    //
    // for m=1:nbMKT
    // tax(m) = get_taxes(equilibrium,m)
    //end

    if or(size(taxes) ~= size(mkts))
        error("taxes and market : sizes do no match")
    end

    taxes = taxes(:)
    mkts=mkts(:) // mkts should be a column

    equilibrium($ + (mkts - nbMKT)) = taxes

endfunction


function [equilibrium, areEmisConstparam, is_taxexo_MKTparam]=cap_taxes(equilibrium, tax_min, tax_max, areEmisConstparam, is_taxexo_MKTparam)

    for m = 1:nbMKT
        if get_taxes(equilibrium,m) < tax_min(m);            //if tax(m)>tax_floor(m)
            printf("correcting too small tax\n")
            areEmisConstparam(m)  = 0;                       //unconstrains this market
            is_taxexo_MKTparam(m) = 1;                       //tells "the static" to keep the tax
            equilibrium=set_taxes(equilibrium,tax_min(m),m); //set its tax to the floor
        end
        if get_taxes(equilibrium,m) > tax_max(m);            //if tax(m)>tax_ceiling(m)
            printf("correcting too big tax\n")
            areEmisConstparam(m) = 0;                        //unconstrains this market
            is_taxexo_MKTparam(m) = 1;                       //tells "the static" to keep the tax
            equilibrium=set_taxes(equilibrium,tax_max(m),m); //set its tax to the ceiling
        end
    end

endfunction

function exotaxes = choose_exotaxes(objLast,emiLast,tax_min,tax_max,taxLast)
    exotaxes = zeros(1:nbMKT);

    for m=1:nbMKT
        exotaxes(m)= taxLast(m)
        if emiLast >= 0
            //choose the level of exogenous taxes
            if objLast(m) > emiLast(m) * 1.02
                exotaxes(m)= tax_min(m)
            end
            if objLast(m) < emiLast(m) * 0.98
                exotaxes(m)= tax_max(m)
            end
        end
        if emiLast < 0
            if objLast(m) > emiLast(m) * 0.98
                exotaxes(m)= tax_min(m)
            end
            if objLast(m) < emiLast(m) * 1.02
                exotaxes(m)= tax_max(m)
            end
        end
    end
    say("objLast","emiLast","tax_min","tax_max","taxLast","exotaxes");
endfunction

function [next_substep, step_size, last_found_substep]=choose_substep(last_found_substep, cur_substep, step_size, flag_firsttryexo)

    if flag_firsttryexo
        last_found_substep = 0
        next_substep = 1
        step_size = 1
        return
    end

    //last substep was found
    if last_found_substep == cur_substep
        if ETUDE <> "emf27" & ETUDE <> "wp2ampere" // TODEL - for reproductibility of results
            step_size = step_size*2
        end
        next_substep = min(cur_substep + step_size, 1)// this min for fancy step sizes
        return
    end

    if last_found_substep < cur_substep; //last substep was not found
        step_size = step_size/2
        next_substep = min(last_found_substep + step_size, 1)
        return
    end

    error("this is ridiculous!")

endfunction

function [guess, flag_firsttryexo]=guess_next_equilibrium(equilibrium_lastgood, equilibrium_prev, equi_prev_prev, last_found_substep, substep, flag_firsttryexo,exotaxes,is_tryexotax_mode,is_taxexo_MKTparam,taxMKT)

    if is_tryexotax_mode
        if flag_firsttryexo; //going back to prev plus exo taxes in order to start in tryexotax mode
            guess = set_taxes(equilibrium_prev,exotaxes,1:nbMKT)
            message("    guess = equilibrium_prev")
            flag_firsttryexo = %f
            return
        else
            guess = set_taxes(equilibrium_lastgood,exotaxes,1:nbMKT)
            message("    guess = equilibrium_lastgood (exotaxes)")
            return
        end
    end

    if (last_found_substep == 0) & (substep == 1); //there are no subdvisions yet
        //guesses the new equilibrium linear-interpolating the two previous equilibriums
        guess = (1 + substep) * equilibrium_prev - substep * equi_prev_prev
        for mkts = 1:nbMKT
            if is_taxexo_MKTparam(mkts)
                guess = set_taxes(guess,taxMKT(mkts),mkts);
            end
        end
        message("        First guess = " + (1 + substep) + "*equilibrium_prev - " + substep + " * equi_prev_prev")
        return
    end

    if (last_found_substep == 0) & (substep < 1); //there are no subdvisions yet but the linear extrapolation did not work
        guess = equilibrium_prev
        for mkts = 1:nbMKT
            if is_taxexo_MKTparam(mkts)
                guess = set_taxes(guess,taxMKT(mkts),mkts);
            end
        end
        message("    guess = equilibrium_prev")
        return
    end

    if last_found_substep > 0
        //resdyn has subdivised : last equilibrium_lastgood is best guess
        guess = equilibrium_lastgood
        for mkts = 1:nbMKT
            if is_taxexo_MKTparam(mkts)
                guess = set_taxes(guess,taxMKT(mkts),mkts);
            end
        end
        message("    guess = equilibrium_lastgood")
        return
    end

    error("this is ridiculous!")

endfunction

