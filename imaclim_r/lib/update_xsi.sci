// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function newxsi=update_xsi(Rdisp,Ltot_prev,DF,pArmDF,xsi,hdf_cff_lds)
    // Xsi vary with Rdisp/Ltot

    //CALIBRATION
    //see the file "Comparaison Rdisp Xsi.xls" for parameters
    param_a=0.0241; param_b=-0.3561;
    //We normalise Rdisp to compute xsi of the agriculutral good demand
    Rdisp_xsi=Rdisp.*ones(reg,1)./pref(:,indice_composite);
    //param_xsi initialisation
    global("param_xsi")
    if current_time_im == 1 
        param_xsi = Rdisp_xsi ./ Ltot_prev .* ((param_a * ones(reg, 1) ./ xsi(:, indice_agriculture - nbsecteurenergie - 2)).^(ones(reg, 1)/param_b));
    end

    //ompute the new xsi of the agriculutral good demand
    xsi_agr = param_a .* ((Rdisp_xsi ./ Ltot_prev ./ param_xsi).^param_b);
    //modifying xsi of services so that the sum equals 1
    xsi(:,indice_composite-nbsecteurenergie)=xsi(:,indice_composite-nbsecteurenergie)+xsi(:,indice_agriculture-nbsecteurenergie-2)-xsi_agr;
    xsi(:,indice_agriculture-nbsecteurenergie-2)=xsi_agr;

    // New variant of xsi_ind. Depends on polynomial regression from data with a regional fixed effect and a long term (LT) parameter. 
    // For now : fixed effect stays for all the period. LT parameter starts after regression validity (income > max(income in data)).

    // Define parameters of regression
    A = csvRead(path_data_budget_shares+"industry3.csv",',',[],"string",[],'/\/\//');
    A = evstr(A);

    // variant no longer used to commit more properly
    // if ind_xsi_indus == 1 // ICP industry (clothing + furnitures)
    //     A = [-0.004238;0.073488;-0.226870]; 
    // elseif ind_xsi_indus == 2 // OECD industry (clothing + furnitures) 
    //     A = [-2.801e-03;2.884e-02;8.957e-02]; 
    // elseif ind_xsi_indus == 3 // OECD industry2 (Herrendorf et al. (2014) - durable, semi-durable and non durable goods minus food)
    //     A = [-0.0150766;0.2607002;-0.7530565]; 
    // else // ind_xsi_indus == 4 or more // OECD industry3 (constructed variable from ICP sub-groups to match GTAP classification)
    //     A = csvRead(path_data_budget_shares+"industry3.csv",';',[],[],[],'/\/\//');
    // end

    tau_xsi_ind_1 = 10000 // for now we keep regional fixed effect
    P = [%s^2, %s, 1]*A; // Define polynome
    Rdisp2 = Rdisp./Ltot*1e6./GDP_MER_nominal.*GDP_MER_real; //income in ppp
    global("delta_reg_xsi_ind")
    global("regional_tau_ind")
    global("DF_ind_max")
    if current_time_im == 1
        for i=1:nb_sectors_industry
            DF_ind_max = ones(reg,i); // allows for further calculation of LT effect
            regional_tau_ind = ones(reg,1); //counter for exponential decrease for smoothing
            xsi_ind0=xsi(:,indice_industries(i)-nbsecteurenergie-2); //calibration data
            xsi_ind_H0 = horner(P, log(Rdisp2)); //expected values from regression
            delta_reg_xsi_ind = xsi_ind0-xsi_ind_H0; //fixed effect from difference between regression and calibration data
        end
    end
    for i=1:nb_sectors_industry //validity with 18 sectors to check 
        for k=1:nb_regions
            DF_indus_percap(k,i)=DF(k,indice_industries)./repmat(Ltot_prev(k),1,nb_sectors_industry);
            share_indus_income(k,i)=DF_indus_percap(k,i).*pArmDF(k,indice_industries(i))./repmat(Rdisp2(k),1,nb_sectors_industry);
            if  ind_sufficiency_indus == 1 & DF_indus_percap(k,i) > hdf_cff_lds(k,i) & current_time_im >= start_year_strong_policy-base_year_simulation 
                share_indus_income_obj(k)=hdf_cff_lds(k,i).*pArmDF(k,indice_industries(i))./Rdisp2(k);
                xsi_ind(k) = xsi_prev(k,indice_industries(i)-nbsecteurenergie-2).*share_indus_income_obj(k)./share_indus_income(k,i);
            else // DF_indus_percap(k,i) < hdf_cff_lds(k,i) or  current_time_im < start_year_strong_policy-base_year_simulation
                if Rdisp2(k) > 50820 // Start of LT effect - value from OECD data regression
                    // LT effect defines a threshold of per capita consumption in volume at time of end of regression validity
                    // smoothed with exponential decrease in few years
                    if DF_ind_max(k,i) == 1 
                        DF_ind_max(k,i) = DF(k,indice_industries(i))./repmat(Ltot_prev(k),1,nb_sectors_industry);
                        regional_tau_ind(k) = current_time_im;
                    end
                    share_indus_income_obj(k)=DF_ind_max(k,i).*pArmDF(k,indice_industries(i))./Rdisp2(k);
                    xsi_ind_lt(k) = xsi_prev(k,indice_industries(i)-nbsecteurenergie-2).*share_indus_income_obj(k)./share_indus_income(k,i); 
                    xsi_ind(k) = exp(-(current_time_im-regional_tau_ind(k))/2).* (delta_reg_xsi_ind(k).*exp(-current_time_im./tau_xsi_ind_1) + horner(P, log(Rdisp2(k)))) + (1-exp(-(current_time_im-regional_tau_ind(k))/2)).* xsi_ind_lt(k) ; 
                else // within regression validity
                    xsi_ind(k) = delta_reg_xsi_ind(k).*exp(-current_time_im./tau_xsi_ind_1) + horner(P, log(Rdisp2(k))) ; // no LT effect
                end
            end
        end
        xsi(:,indice_composite-nbsecteurenergie)=xsi(:,indice_composite-nbsecteurenergie)+xsi(:,indice_industries(i)-nbsecteurenergie-2)-xsi_ind; //changes in xsi_ind go to xsi_composite
        xsi(:,indice_industries(i)-nbsecteurenergie-2)=xsi_ind;
    end

    xsi=1/3*xsi+2/3*xsi_prev;

    // Forcing the trajectory of xsi_indus
    xsi_indus = xsi(:,indice_industries-nbsecteurenergie-2);
    xsi_indus(ind_global_north,:) = xsi_indus(ind_global_north,:) .* (dynForc_hdf_cff(ind_global_north,1) * ones(1,nb_sectors_industry));
    xsi_indus(ind_global_south,:) = xsi_indus(ind_global_south,:) .* (dynForc_hdf_cff(ind_global_south,1) * ones(1,nb_sectors_industry));
    for k=1:reg
        xsi(k,indice_composite-nbsecteurenergie)=xsi(k,indice_composite-nbsecteurenergie)+sum(xsi(k,indice_industries-nbsecteurenergie-2))-sum(xsi_indus(k,:));
        xsi(k,indice_industries-nbsecteurenergie-2)=xsi_indus(k,:);
    end
    newxsi=xsi;

endfunction
