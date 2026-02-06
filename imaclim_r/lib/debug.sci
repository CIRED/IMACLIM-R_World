// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function intelec
    plotreg(sgv("E_reg_use",:,iu_elec)./(sgv("Q",:,elec)+%eps))
endfunction

function tax
    plot(sgv("taxMKT")'*1e6,"+-");
    xgrid();
endfunction

function emiPlusTax
    subplot(1,2,1);
    tax;
    subplot(1,2,2);
    emis;
endfunction

function chargoil
    plot(sgv("charge",ind_mde,oil),"+-")
    plot(ones(sgv("charge",ind_mde,oil))*0.95,"k")
    if or(sgv("charge")>0.98)
        warning ("or(sgv(charge)>0.98)")
    end
    
endfunction

function ctl
    plot(sum(sgv("Q_CTL_anticip"),"r"),"-+")
    title("sum Q_CTL_anticip")
endfunction


function charges(r)
    plot(sgv("charge",r,:)','-+')
    plot(ones(sgv("charge",ind_mde,oil))*0.95,"k")
    legend(secnames)
    title(regnames(r))
endfunction



function basics(r)
    plot((sgv("Conso",r)./(sgv("bn",r,6:12)+%eps))'-1)
    legend(secnames(6:12),4)
    plot(zeros(1:TimeHorizon+1),'k')
endfunction


function bascars()
    hop=sgv("bnautomobile")
    hop(4:12,1:2) = 1;
    plot((sgv("Tautomobile")./(hop+%eps))'-1) //TODO
    legend(regnames,4)
    plot(zeros(1:TimeHorizon+1),'k')
endfunction

function emis
    plot(mktaggru(sgv("E_reg_use"))'/1e9)
    plot(sgv("CO2_obj_MKTparam")'/1e9,"--")
    title("GtCO2        --:objectif           plein:emissions réelles")
    xgrid();
endfunction

function explain_v
    "Utility"
    "Household_budget"
    "Time_budget"  
    "Sector_budge" 
    "Market_clear"
    "Wages"    
    "State_budget" 
    "wpEner"   
endfunction
