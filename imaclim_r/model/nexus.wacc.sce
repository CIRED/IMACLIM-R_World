// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//Discount Rate - Weighted-Average Cost of Capital Nexus......//
//____________________________________________//

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   New values for the electricity sector, proxy = WACC
/////////////////////////////////////////////////////////////////////////////////////////////

//discount rates for wind/pv/non-renewable from TB modelling project
//Current Cap_limit_sup : 250GW. Pour le calibrer, comparer modèle de WACC à valeurs observées?
//Computing technology risk premium
if ind_global_wacc == 0
    if ind_uniform_DR == %f
        //updating the risk_free rate

        if ind_new_calib_wacc == %f // using 2015-2022 averages in the new calibration
            if current_time_im <=2022-base_year_simulation //after 2022 the risk_free stays the same
                Risk_f_RR_debt = Risk_f_RR_debt_hist(:,current_time_im);
            end
        end
        if current_time_im == 1 
            Cap_WND = Cap_elec_MWref(:,indice_WND);
            Cap_WNO = Cap_elec_MWref(:,indice_WNO);
            Cap_CPV = Cap_elec_MWref(:,indice_CPV); //we might apply the same CINV learning
            Cap_RPV = Cap_elec_MWref(:,indice_RPV); //but different financial learning do the very distinct nature of the two inv
            Cap_CSP = Cap_elec_MWref(:,indice_CSP);
        end
        if current_time_im > 1
            Cap_WND = Cap_elec_MW(:,indice_WND);
            Cap_WNO = Cap_elec_MW(:,indice_WNO);
            Cap_CPV = Cap_elec_MW(:,indice_CPV);
            Cap_RPV = Cap_elec_MW(:,indice_RPV);
            Cap_CSP = Cap_elec_MW(:,indice_CSP);
        end
        for techno = techno_RE_names
            execstr("maturity_ind_"+techno+" = min(1,Cap_"+techno+"/Cap_limit_sup);")
            execstr("Risk_premium_"+techno+" = maturity_ind_"+techno+"*Risk_premium_min + (1-maturity_ind_"+techno+")*Risk_premium_max;")
            execstr("WACC_"+techno+" = Debt_share_"+techno+".*(Risk_f_RR_debt+Country_premium+ Risk_premium_"+techno+").*(1-Corporate_tax)+(1-Debt_share_"+techno+").*(Risk_f_RR_debt +levered_beta_ENR.*(Risk_f_RR_equity +Country_premium_adj))")
        end                                                                                                                                                                                                                                 
        // adding debt margin to the WACC (0% if new_calib_wacc = 0)
        WACC_FF = Debt_share_FF.*(Risk_f_RR_debt+Country_premium+debt_margin).*(1-Corporate_tax) + (1-Debt_share_FF).*(Risk_f_RR_debt+levered_beta_FF.*(Risk_f_RR_equity + Country_premium_adj));
    end
    //////////////////////////////////
    ////Climate finance scenarios/////
    //////////////////////////////////


    if ind_climfin>0
        if climfin_port(current_time_im)>0
            if ind_first_run_elec

                for techno = techno_RE_names
                    if techno == "CSP" 
                        cumul_climfin_CSP=  cumul_climfin_CSP + climfin_loan.*inv_share_total_CSP;
                    end

        
                    if techno=="CPV"|techno=="RPV"
                        execstr(" cumul_climfin_"+techno+"=  cumul_climfin_"+techno+" + climfin_loan.*inv_share_total_RPV + climfin_loan.*inv_share_total_CPV")
                    end
        
                    if techno=="WNO"
                        execstr(" cumul_climfin_"+techno+"=  cumul_climfin_"+techno+"+ climfin_loan.*inv_share_total_WNO")
                    end
                    if techno=="WND"
                        execstr(" cumul_climfin_"+techno+"=  cumul_climfin_"+techno+" + climfin_loan.*inv_share_total_WND")
                    end
                    
                    execstr("mobil_index_"+techno+" =  min(cumul_climfin_"+techno+"/max_climfin,1)");

                    execstr("Debt_share_"+techno+"(emerging_reg) =  mobil_index_"+techno+" * (Debt_share_ENR_dev-delta_debt_share) + (1-mobil_index_"+techno+")*Debt_share_ENR_emer");
                        
                    execstr("Risk_premium_"+techno+"_climfin = Risk_premium_"+techno+""); //By default, setting the risk premium with clim fin to its unsupported value, only for ex-post computation purposes
                    for k=emerging_reg
                        row = find(k == emerging_reg);
                        if (total_portfolio(row,current_time_im)>0)
                            execstr("Risk_premium_"+techno+"_climfin(k) = max(red_max_spread,Risk_premium_"+techno+"(k)-mobilisation_debt)"); //for the first iteration we compute the technology risk premium of renewable projects, with a 2% pt reduction of the risk premium in case of co-financing
                        else 
                            execstr("Risk_premium_"+techno+"_climfin(k) = Risk_premium_"+techno+"(k)")
                        end
                    end
                end
            end // end of ind_first_run_elec: next lines of code will be executed at every iteration
            
            for techno = techno_RE_names
                execstr("WACC_"+techno+"_unrisked = Debt_share_"+techno+".*(Risk_f_RR_debt+Country_premium+ Risk_premium_"+techno+").*(1-Corporate_tax)+(1-Debt_share_"+techno+").*(Risk_f_RR_debt +levered_beta_ENR.*(Risk_f_RR_equity +Country_premium_adj))") //This is the CoC 
                for k=emerging_reg   
                    row = find(k == emerging_reg);
                    execstr("WACC_"+techno+"_climfin(k) = Debt_share_"+techno+"(k)*((1-share_climfin_debt)*(Risk_f_RR_debt(k)+Country_premium(k)+ Risk_premium_"+techno+"_climfin(k))+(share_climfin_debt*rate_climfin))*(1-Corporate_tax(k))+(1-Debt_share_"+techno+"(k))*(Risk_f_RR_debt(k) +levered_beta_ENR(k)*(Risk_f_RR_equity +Country_premium_adj(k)))")
                    execstr("WACC_"+techno+"(k) = share_climfin_Inv(row)*WACC_"+techno+"_climfin(k)+(1-share_climfin_Inv(row))*WACC_"+techno+"_unrisked(k)")
                end
            end
            
            //Some precision: presented as above we act like some project were totally financed throughout public loans and other throughout private debt
            // instead of having only one CoC for co-financed project and a level of co-financing for the debt side.
            // this is equivalent if the cost of private debt in the two formulas is the same i.e. if Risk_premium_techno_climfin is affected by mobilisation_debt in the WACC_techno_unrisked computation
            //EDIT : we do not do this anymore, the new version includes share_climfin_debt

            //For the convergence scenarios: if the climfin value is lower, use it instead of the convergence WACC
            if ind_climfin == 4
                if current_time_im == conv_start
                
                    for techno = techno_RE_names
                        execstr("WACC_"+techno+"_start = WACC_"+techno+"");
                        execstr("WACC_"+techno+"_end = Debt_share_"+techno+".*(Risk_f_RR_debt+Country_premium+debt_margin).*(1-Corporate_tax)+(1-Debt_share_"+techno+").*(Risk_f_RR_debt +levered_beta_ENR.*(Risk_f_RR_equity +Country_premium_adj))");//the WACC_techno_end = removed technology risk premium
                        execstr("WACC_"+techno+"_end(emerging_reg) = min(WACC_"+techno+"_end(ind_eur,ind_usa))");
                    end
                end
                if current_time_im>=conv_start & current_time_im<=conv_end
                    weight_conv = (conv_end - current_time_im)/(conv_end-conv_start) // weight for the 2020 value
                    for techno = techno_RE_names
                        for k=emerging_reg 
                            execstr("WACC_"+techno+"(k) = min(WACC_"+techno+"_sup(k,current_time_im+1), weight_conv*WACC_"+techno+"_start(k)+(1-weight_conv)*WACC_"+techno+"_end(k))") //current_time_im-1 because we want to use the value calculated at the end of the previous year
                            // execstr("WACC_"+techno+"(k) =  weight_conv*WACC_"+techno+"_start(k)+(1-weight_conv)*WACC_"+techno+"_end(k)") // without WACC climfin as a upper bound

                        end
                    end
                end
                if current_time_im>conv_end
                    for techno = techno_RE_names
                        for k=emerging_reg 
                            execstr("WACC_"+techno+"(k) = WACC_"+techno+"_end(k)")
                        end
                    end
                end
            end
        end    
        
    end //end of if climfin>0
    //updating the discount rate
    //starting by good old assumption : 10% everywhere
    //then updated FF : this might change as we integrate the ETH assumptions, including for biomass & nuke technos
    //finishing with renew techno
    for i =1:TimeHorizon
        for techno = 1:techno_elec
            execstr("disc_rate_elec(:,"+techno+",i+current_time_im-1) = 0.1;")
        end
        for techno = technoFossil
            execstr("disc_rate_elec(:,"+techno+",i+current_time_im-1) = WACC_FF;")
        end
        for techno = techno_RE_names
            execstr("disc_rate_elec(:,indice_"+techno+",i+current_time_im-1) = WACC_"+techno+";")
        end

    end


    //Case of uniform df : 8% for all according to the Global WACC paper settings
    if ind_uniform_DR == %t
        if current_time_im ==1 then
            for i=1:TimeHorizon
                disc_rate_elec(developed_reg,:,i) = 0.08;
                disc_rate_elec(emerging_reg,:,i) = 0.08;
            end
        end
    end
end //end of ind_global_wacc == 0

if ind_global_wacc > 0
    //////////////////////////////////
    /////  Global WACC MiP  //////////
    //////////////////////////////////    
    //starting the global WACC paper section
    //Global WACC techno order:
    //1: Coal fired plants
    //2: Gas plants
    //3: Nuclear plants
    //4: Hydro
    //5: Biomass
    //6: CCS
    //7: Solar PV
    //8: Onshore Wind
    //9: Offshore Wind
    if current_time_im ==1 
        for i=1:TimeHorizon
            disc_rate_elec(:,technoCoalWOCCS,i) = repmat(Global_WACC(:,1),1,length(technoCoalWOCCS));
            disc_rate_elec(:,[technoCoalWCCS,technoGasWCCS],i) = repmat(Global_WACC(:,6),1,length([technoCoalWCCS,technoGasWCCS]));
            disc_rate_elec(:,technoGasWOCCS,i) = repmat(Global_WACC(:,2),1,length(technoGasWOCCS));
            disc_rate_elec(:,technoNuke,i) = repmat(Global_WACC(:,3),1,length(technoNuke));
            disc_rate_elec(:,technoElecHydro,i) = repmat(Global_WACC(:,4),1,length(technoElecHydro));
            disc_rate_elec(:,technoSolar,i) = repmat(Global_WACC(:,7),1,length(technoSolar));
            disc_rate_elec(:,indice_WND,i) = repmat(Global_WACC(:,8),1,length(indice_WND));
            disc_rate_elec(:,indice_WNO,i) = repmat(Global_WACC(:,9),1,length(indice_WNO));
            disc_rate_elec(:,technoBiomass,i) = repmat(Global_WACC(:,5),1,length(technoBiomass));
        end
    end

end
select ind_global_wacc //case 1 => ETH WACC forever
case 2 //convergence case
    if current_time_im>=wacc_conv_start & current_time_im<=wacc_conv_end
        for i = current_time_im:TimeHorizon
            weight_init = (wacc_conv_end - current_time_im)/(wacc_conv_end-wacc_conv_start);
            weight_end = (current_time_im-wacc_conv_start)/(wacc_conv_end-wacc_conv_start);
            disc_rate_elec(:,technoCoalWOCCS,i) = conv_WACC(technoCoalWOCCS,wacc_min,weight_init,weight_end,1);
            disc_rate_elec(:,[technoCoalWCCS,technoGasWCCS],i) = conv_WACC([technoCoalWCCS,technoGasWCCS],wacc_min,weight_init,weight_end,6);
            disc_rate_elec(:,technoGasWOCCS,i) = conv_WACC(technoGasWOCCS,wacc_min,weight_init,weight_end,2);
            disc_rate_elec(:,technoNuke,i) = conv_WACC(technoNuke,wacc_min,weight_init,weight_end,3);
            disc_rate_elec(:,technoElecHydro,i) = conv_WACC(technoElecHydro,wacc_min,weight_init,weight_end,4);
            disc_rate_elec(:,technoSolar,i) = conv_WACC(technoSolar,wacc_min,weight_init,weight_end,7);
            disc_rate_elec(:,indice_WND,i) = conv_WACC(indice_WND,wacc_min,weight_init,weight_end,8);
            disc_rate_elec(:,indice_WNO,i) = conv_WACC(indice_WNO,wacc_min,weight_init,weight_end,9);
            disc_rate_elec(:,technoBiomass,i) = conv_WACC(technoBiomass,wacc_min,weight_init,weight_end,5);
        end
    end


case 3 //learning case
    if current_time_im>=wacc_conv_start
        if current_time_im==wacc_conv_start
            Cum_Inv_MW_elec_ref0 = Cum_Inv_MW_elec; //The learning process starts in 2020
        end
        for i=(current_time_im):TimeHorizon
            for techno_learning = [indice_WND,indice_WNO,technoBiomass]
                disc_rate_elec(:,techno_learning,i) = max((disc_rate_elec(:,techno_learning,1)).*(1-LR_fin)^(log(Cum_Inv_MW_elec(techno_learning)/Cum_Inv_MW_elec_ref0(techno_learning))/log(2)),0);
            end
            disc_rate_elec(:,technoSolar,i) = repmat(max((disc_rate_elec(:,indice_CPV,1)).*(1-LR_fin)^(log(sum(Cum_Inv_MW_elec(technoSolar))/sum(Cum_Inv_MW_elec_ref0(technoSolar)))/log(2)),0),1,length(technoSolar)); //for solar, CPV+RPV+CSP
        end
    end
end

//Discount rate for utility scale storage
// solar PV WACC is used a proxy for utility scale storage WACC:
// https://www.iea.org/commentaries/cost-of-capital-survey-shows-investments-in-solar-pv-can-be-less-risky-than-gas-power-in-emerging-and-developing-economies-though-values-remain-high: "When comparing responses of utility-scale batteries, for projects taking FID in 2022, we found that the WACC for batteries was higher or equal to that of solar PV projects"

disc_rate_elec(:,indice_STR,:) = disc_rate_elec(:,indice_CPV,:);