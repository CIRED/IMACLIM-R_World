// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///-------------- Current Policies (NPi) - Nationnaly Determined Contributions (NDCs) --------------///
// Defining the appropriate carbon market coverage depending on the number of markets

// The functions used below depend on the choices made in the R script data/NPi_NDC/process_NPi_NDC.R
// Be careful: the market definition and order must be consistent with the data/NPi_NDC/emi_control_NDC.csv file
// The user can not change the regional coverage of the markets without changing the way emi constraints are computed




function[y] = whichMKT_NPi_NDC(nb_MKT);
    
    x_MKT = ones(reg,nb_use); // includes case nbKMT == 1
    // WARNING: the market order must be consistent with the data/NPi_NDC/emi_control_NDC.csv file
    if nb_MKT == 4
        
        x_MKT([ind_chn ind_ind ind_ras],:)=1; 
        x_MKT([ind_bra ind_ral],:)=2; 
        x_MKT([ind_eur ind_jan ind_can ind_usa],:)=3;
        x_MKT([ind_afr ind_mde ind_cis],:)=4; 
 
    end

    if nb_MKT == 7
        x_MKT([ind_ras],:)=1; 
        x_MKT([ind_chn],:)=2; 
        x_MKT([ind_ind],:)=3; 
        x_MKT([ind_bra ind_ral],:)=4; 
        x_MKT([ind_afr ind_mde],:)=5; 
        x_MKT([ind_eur ind_jan ind_can ind_usa],:)=6; 
        x_MKT([ind_cis],:)=7; 
    end

    if nb_MKT==9
        x_MKT([ind_ras],:)=1; 
        x_MKT([ind_chn],:)=2; 
        x_MKT([ind_eur],:)=3; 
        x_MKT([ind_ind],:)=4; 
        x_MKT([ind_bra ind_ral],:)=5; 
        x_MKT([ind_afr ind_mde],:)=6; 
        x_MKT([ind_jan ind_can],:)=7; 
        x_MKT([ind_cis],:)=8; 
        x_MKT([ind_usa],:)=9; 
    end
    y = x_MKT;
endfunction

function[y] = CO2_MKT_NPi_NDC(nb_MKT);
    
    x_MKT = ones(nbMKT,TimeHorizon+1);

    if nb_MKT == 1 //world market
        x_MKT(1,:) = sum(CO2_base_reg,"r");
    end

    if nb_MKT == 4
        
        x_MKT(1,:) = sum(CO2_base_reg([ind_chn ind_ind ind_ras],:),"r");
        x_MKT(2,:) = sum(CO2_base_reg([ind_bra ind_ral],:),"r");
        x_MKT(3,:) = sum(CO2_base_reg([ind_eur ind_jan ind_can ind_usa],:),"r");
        x_MKT(4,:) = sum(CO2_base_reg([ind_afr ind_mde ind_cis],:),"r");

    end

    if nb_MKT == 7
        x_MKT(1,:) = sum(CO2_base_reg([ind_ras],:),"r");
        x_MKT(2,:) = sum(CO2_base_reg([ind_chn],:),"r");
        x_MKT(3,:) = sum(CO2_base_reg([ind_ind],:),"r");
        x_MKT(4,:) = sum(CO2_base_reg([ind_bra ind_ral],:),"r");
        x_MKT(5,:) = sum(CO2_base_reg([ind_afr ind_mde],:),"r");
        x_MKT(6,:) = sum(CO2_base_reg([ind_eur ind_jan ind_can ind_usa],:),"r");
        x_MKT(7,:) = CO2_base_reg([ind_cis],:);
    end

    if nb_MKT==9
        x_MKT(1,:) = sum(CO2_base_reg([ind_ras],:),"r");
        x_MKT(2,:) = sum(CO2_base_reg([ind_chn],:),"r");
        x_MKT(3,:) = sum(CO2_base_reg([ind_eur],:),"r");
        x_MKT(4,:) = sum(CO2_base_reg([ind_ind],:),"r");
        x_MKT(5,:) = sum(CO2_base_reg([ind_bra ind_ral],:),"r");
        x_MKT(6,:) = sum(CO2_base_reg([ind_afr ind_mde],:),"r");
        x_MKT(7,:) = sum(CO2_base_reg([ind_jan ind_can],:),"r");
        x_MKT(8,:) = CO2_base_reg([ind_cis],:);
        x_MKT(9,:) = CO2_base_reg([ind_usa],:);
    end
    y = x_MKT;
endfunction
