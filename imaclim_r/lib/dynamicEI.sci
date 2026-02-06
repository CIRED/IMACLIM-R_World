// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Julie Rozenberg, Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function EI = dynamicEI(current_time_im, TimeHorizon, nonEnergSectors, reg, EI, pIndEner)	
    muEi = zeros(reg,sec);
    regions = [1:reg];
    if current_time_im==1 then
        EI		= ones(reg,sec,TimeHorizon);
        //Energy intensity of production in all sectors
        EI(:,:,current_time_im)    = EI_ref(:,:);
    end
    // 2.2. Speed of catch up
    for region = regions
        for sect = [6,7,11,12]    
            X(region,sect) = PindEnerToX(pIndEner,region,sect);// The larger the price index, the lower X 
            //muEi determines the speed of convergence between the followers and the leader. Its value is such that after X years, the gap between the asymptote (EI_lead/final_level) and EI would be multiplied by Y (<1). 
            //X changes with the price of energy, so muEi is recalculated at each time step.
            muEi(region,sect)=calibreMu(finalLevel(sect),leaderEvolution(sect),EI_ref(region,sect)  ,EI_lead_ref(sect),X(region,sect) ,Y(region,sect) ,current_time_im); 
        end
    end
		
    if current_time_im >1 then
        for sect = nonEnergSectors
            // 1. Evolution of the leader
            EI(leader(sect),sect,current_time_im)	= EI(leader(sect), sect, current_time_im-1) * PindEner2leaderEv(pIndEner,leader(sect),sect, leaderEvolution(sect)); // The larger the price index, the lower the evolution (of EI).
            // 2. Followers catch up
            for region=regions([1:leader(sect)-1,leader(sect)+1:reg])
                EI(region, sect, current_time_im) = EI(region, sect, current_time_im-1)*leaderEvolution(sect)*muEi(region,sect)^(current_time_im)+..
                EI(leader(sect), sect, current_time_im-1)/finalLevel(sect)*leaderEvolution(sect)*(1-muEi(region,sect)^(current_time_im));
            end
        end
		
    end
endfunction;
