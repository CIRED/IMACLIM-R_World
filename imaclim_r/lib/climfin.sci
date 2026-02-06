// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//find_climfin_share

function[y] = find_climfin_share(k)
    
    port = total_portfolio(k,current_time_im); //Regional de-risking allocation
    loan = climfin_loan(k); //Regional de-risked loan demand
    total_debt_d = total_VRE_debt_d(k)*share_climfin_debt; //total debt demand for VRE inv that can be satisfied by public debt
    share_climfin_0 = share_climfin_Inv(k); // x0
    rerun=0;
    share_climfin_1 = 0;
    if port>0
        if  loan <port & share_climfin_0>1 //case when there is not enought investment project to fill the portfolio. happen when there is high level of deriksing, or low levels of investment demand (the first years)
            share_climfin_1=1;
        else
            if norm((loan-port)/port)>norm_bound
                if share_climfin_0 == 0
                    share_climfin_0 = 0.9; // give a push in case the convergence fails and the share goes to 0
                end 
                //Case one: f(x0) is higher than port. Then we get closer to the fixed point downwards
                if loan>port //then x1 is set such that f(x1) = 1, i.e. x1 = port/total_debt_d and we keep going 
                    share_climfin_1 = port/total_debt_d;
                    rerun = 1;
                else //Case two: share_climfin_0 gives a lower loan demand that the available funds
                    share_climfin_0_5 = port/total_debt_d;
                    share_climfin_1 = (1-inertia_climfin)*share_climfin_0 + inertia_climfin*share_climfin_0_5;
                    rerun = 1;
                end
            else
                share_climfin_1 = share_climfin_0; //case norm((loan-port)/port)<norm_bound: keep the previous share_climfin value
            end
        end
    end 
    y = [share_climfin_1,rerun]
endfunction
    
