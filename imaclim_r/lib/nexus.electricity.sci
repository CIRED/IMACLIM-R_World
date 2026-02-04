// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//Summary

//1. Calib_markup_ENR
//2. Markup_wind
//3. Markup_pv
//4. find_weights_ENR
//5. remove_saturated_techno
//6 find_net_LCOE_VRE
//7. RLDC_peak
//8. curtailment_share_d
//9. find_net_sh
//10. WACC convergence
//11. peak coverage constraint
//12. load Cap Hydro data

//Computes new SIC markup with projected renewable shares
function [y] = calib_markup_ENR(xloc)
    markup_SIC = xloc;
    Markup_LCC_SIC = ones(reg,length(technoExo_absolute)); //starting at one is nicer than zero for convergence issues
    
    for j=technoPVAbsolute
        Markup_LCC_SIC(:,j) = markup_SIC(:,1);
    end
    
    for j=technoWindAbsolute
        Markup_LCC_SIC(:,j) = markup_SIC(:,2);
    end
    
        //LCOE with markup from previous ideal park
    LCC_ENR=(CINV(:,technoExo)+OM_cost_fixed(:,technoExo,current_time_im))./(Load_factor_ENR(:,technoExo_absolute)*th_to_h+%eps)+OM_cost_var(:,technoExo,current_time_im) + Markup_LCC_SIC;
    
    
    //FF/Renewable shares
share_FF_ENR = modified_logit([LCC_FF_min_fct,LCC_ENR(:,VarRenew_ENR)],gamma_FF_ENR,weights_ENR);

    //wind/pv shares with previous markup
    share_Wind = sum(share_FF_ENR(:,technoWind_ENR_vs_FF),"c");
    share_PV = sum(share_FF_ENR(:,technoPV_ENR_vs_FF), "c");



	//new SIC markup computation
    for j=technoPVAbsolute
        markup_ENR(:,1) = Markup_pv(share_PV,share_Wind);
    end
    
    for j=technoWindAbsolute
        markup_ENR(:,2) = Markup_wind(share_PV,share_Wind);
    end



    y = [xloc(:,1) - markup_ENR(:,1), xloc(:,2) - markup_ENR(:,2)];

endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

//SIC Markups for wind and solar pv
function [z] = Markup_wind(x,y)
    z = param_SIC*(x+param_SIC_wind*y)
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function [z] = Markup_pv(x,y)
    z = param_SIC*(param_SIC_pv*x+y)
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function [y] = find_weights_ENR(xloc) //this function finds the weight share of the modified logit such that when running the nexus at t=1 the optimal share of VRE in 2018 matches the observed value
        weights = [1,xloc(1),xloc(2),xloc(3),xloc(4)];
        sum_weighted_LCC = zeros(1);
		
          for i = 1:nbTechExoAbsUsed
              sum_weighted_LCC = sum_weighted_LCC + weights(i+1)*(LCC_ENR(k,2+i).^(-gamma_FF_ENR));
          end
          sum_weighted_LCC =sum_weighted_LCC+ LCC_FF_min_fct(k).^(-gamma_FF_ENR);
        for j=1:nbTechExoAbsUsed
          Z(k,j) = max((target_prod(k,j) - (1-target_year/(current_time_im+nb_year_expect_futur))*(Load_factor_ENR(k,2+j)*1000).*Cap_elec_MWref(k,indice_WND-1+j)./(Qref(k,indice_elec)*(mtoe2mwh)))/(target_year/(current_time_im+nb_year_expect_futur)),(Load_factor_ENR(k,2+j)*1000).*Cap_elec_MWref(k,indice_WND-1+j)./(Qref(k,indice_elec)*(mtoe2mwh)));
//year 0 is 2014 and year 10 is 2025, so there are current_time_im+nb_year_expect_futur in between. The target year 2014 correspond to target_year=4
            weights(j+1) = Z(k,j)*(sum_weighted_LCC)/(LCC_ENR(k,2+j).^(-gamma_FF_ENR));
            
        end
         y = [xloc - weights(2:nbTechFFENR)]
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

//Find net VRE LCOE, including curtailment based on curtailment equation

function[y] = find_net_LCOE_VRE(xloc)
    LCOE_net = zeros(reg,length(technoExo_absolute));
    LCOE_net(:,VarRenew_ENR) = xloc(:,1:length(techno_ENRi_endo));
    curt_tot_d= xloc(:,length(techno_ENRi_endo)+1); //curt_tot_d = the total of curtailed power as a share of total electricity demand
    
    curt_share_PV = zeros(reg,1);
    curt_share_Wind = zeros(reg,1); // curt_share_pv and wind = the curtailed power as a share of net VRE.

    net_share_FF_ENR = zeros(reg,nbTechFFENR);
    Gross_VRE_share = zeros(reg,nbTechExoAbsUsed);
    
    
    //Thus for a wind techno (lets say WNO) Gross_VRE_share(WNO) = net_FF_share (WNO) + curt_share_Wind * net_FF_share(WNO). The second term curt_share_Wind * net_FF_share(WNO) give the curtailed power for WNO as a share of total demand
    curt_share_total = zeros(reg,1);
    curt_share_exo = zeros(reg,length(technoExo_absolute));

    markup_LCOE_VRE = ones(reg,length(technoExo_absolute)); //starting at one is nicer than zero for convergence issues

//Net VRE shares with current VRE LCOE

net_share_FF_ENR = modified_logit([LCC_FF_min_fct, LCOE_net(:,VarRenew_ENR)],gamma_FF_ENR,weights_ENR);

//Computing curtailment for different shares (of net VRE gen, of net PV gen, of net Wind gen)

curt_tot_VRE = curt_tot_d./sum(net_share_FF_ENR(:,technoENRi_vs_FF),"c"); // total curt as a share of VRE gen


//This is our main hypothesis for curtailment shares on wind and solar PV. We do not posses the information of how much curtailment is due to solar / wind. Curtailment for PV and wind does not happen at the same time, as marginal extra PV gen is more likely to be correlated with existing PV gen. The parameter 3-1 must be calibrated on empiracal data/ expert guess

weights_wind_curt = (beta_wd*sum(net_share_FF_ENR(:,technoWind_ENR_vs_FF),"c"))./(alpha_pv*sum(net_share_FF_ENR(:,technoPV_ENR_vs_FF),"c")+beta_wd*sum(net_share_FF_ENR(:,technoWind_ENR_vs_FF),"c"));
weights_pv_curt = alpha_pv*sum(net_share_FF_ENR(:,technoPV_ENR_vs_FF),"c")./(alpha_pv*sum(net_share_FF_ENR(:,technoPV_ENR_vs_FF),"c")+beta_wd*sum(net_share_FF_ENR(:,technoWind_ENR_vs_FF),"c"));

//Curtailment as a share of PV/Wind net gen. Take the curt as a share of VRE (curt_tot_VRE) then split it between PV and Wind share with the weights. Divide by the shares of PV/Wind gen to get PV/Wind curt as a share of PV/Wind gen.Every time 1kWh is produced, curt_share_pv/wind is curtailed.
//This will be used to compute net LCOE.
curt_share_Wind = curt_tot_VRE./(sum(net_share_FF_ENR(:,technoWind_ENR_vs_FF),"c")./sum(net_share_FF_ENR(:,technoENRi_vs_FF),"c")).*weights_wind_curt;
curt_share_PV = curt_tot_VRE./(sum(net_share_FF_ENR(:,technoPV_ENR_vs_FF),"c")./sum(net_share_FF_ENR(:,technoENRi_vs_FF),"c")).*weights_pv_curt;
//Multiply it by net_share_FF_ENR(:,technoWind_ENR_vs_FF) or net_share_FF_ENR(:,technoPV_ENR_vs_FF) to get the curtailment for PV/Wind as a share of demand

//Gross VRE share as share of annual demand
//equals the net share + the curtailment per techno (as a share of annual demand). Since curt_share is curt as a share of pv/wind gen, we multiply by the share of net pv/wind in the total demand
Gross_VRE_share(:,technoWind_ENR_vs_FF -1) = net_share_FF_ENR(:,technoWind_ENR_vs_FF) + repmat(curt_share_Wind,1,length(technoWind_ENR_vs_FF)).* (net_share_FF_ENR(:,technoWind_ENR_vs_FF)) ; 
Gross_VRE_share(:,technoPV_ENR_vs_FF -1) = net_share_FF_ENR(:,technoPV_ENR_vs_FF) + repmat(curt_share_PV,1,length(technoPV_ENR_vs_FF)) .* (net_share_FF_ENR(:,technoPV_ENR_vs_FF)) ;




//Computing new gross VRE shares
gross_wind_sh = sum(Gross_VRE_share(:,technoWind_ENR_vs_FF-1 ),"c");
gross_pv_sh = sum(Gross_VRE_share(:,technoPV_ENR_vs_FF-1 ),"c");

curt_share_total = curtailment_share_d([gross_wind_sh,gross_pv_sh]); // as a share of total demand


//new SIC markup computation, which is in net VRE share

    for j=technoPVAbsolute
       markup_LCOE_VRE(:,j) = Markup_pv(sum(net_share_FF_ENR(:,technoPV_ENR_vs_FF),"c"),sum(net_share_FF_ENR(:,technoWind_ENR_vs_FF),"c"));
    end
    
    for j=technoWindAbsolute
       markup_LCOE_VRE(:,j) = Markup_wind(sum(net_share_FF_ENR(:,technoPV_ENR_vs_FF),"c"),sum(net_share_FF_ENR(:,technoWind_ENR_vs_FF),"c"));
    end

curt_share_exo(:,[technoWindAbsolute,technoPVAbsolute]) = [repmat(curt_share_Wind,1,2),repmat(curt_share_PV,1,2)];
//Final Net LCOE. We have defined curtailment as a share of net VRE share, such that gross VRE gen = net VRE gen (1+curt). Thus, we must divide the gross load factor by 1/1+curt to have a final net produced kWh of electricity LCOE/
    LCOE_VRE=(CINV(:,technoExo)+OM_cost_fixed(:,technoExo,current_time_im))./((Load_factor_ENR(:,technoExo_absolute)*th_to_h+%eps)./(1+curt_share_exo))+OM_cost_var(:,technoExo,current_time_im) + markup_LCOE_VRE;
    
    
    
    y = [xloc(:,technoWind_ENR_vs_FF -1) - LCOE_VRE(:,technoWindAbsolute), xloc(:,technoPV_ENR_vs_FF-1 ) - LCOE_VRE(:,technoPVAbsolute), xloc(:,length(techno_ENRi_endo)+1)- curt_share_total];
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//


//removes techno with saturated market shares
function [y] = remove_saturated_techno(a,b,c)
    techno_FF = a;
    techno_full = b;
    saturated = c;
    
    techno_full = techno_full(techno_full~=saturated)
    y = intersect(techno_FF,techno_full)
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

//RLDC peak load as a share of total peak load. Coefficients derived from ADVANCE data polynomial fit
function[y] = find_RLDC_peak(xloc)
    WD_sh = xloc(:,1);
    Solar_sh = xloc(:,2);
     y = min(ones(reg,1),coef_RLDC.coef(:,1) + coef_RLDC.coef(:,2).*WD_sh + coef_RLDC.coef(:,3).*Solar_sh + coef_RLDC.coef(:,4).*WD_sh.*WD_sh + coef_RLDC.coef(:,5) .*Solar_sh.*Solar_sh + coef_RLDC.coef(:,6).*WD_sh.*WD_sh.*WD_sh + coef_RLDC.coef(:,7).*Solar_sh.*Solar_sh.*Solar_sh + coef_RLDC.coef(:,8).*Solar_sh.*WD_sh + coef_RLDC.coef(:,9).*Solar_sh.*WD_sh.*WD_sh + coef_RLDC.coef(:,10).*Solar_sh.*Solar_sh.*WD_sh)
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//


//Curtailment as a share of total electricity demand. Coefficient must derived from ADVANCE data polynomial fit which is NOT THE CASE 
//AT THE MOMENT
function[y] = curtailment_share_d(xloc)
    WD_sh = xloc(:,1);
    Solar_sh = xloc(:,2);
     y = max(zeros(reg,1),coef_Curt.coef(:,1) + coef_Curt.coef(:,2).*WD_sh + coef_Curt.coef(:,3).*Solar_sh + coef_Curt.coef(:,4).*WD_sh.*WD_sh + coef_Curt.coef(:,5) .*Solar_sh.*Solar_sh + coef_Curt.coef(:,6).*WD_sh.*WD_sh.*WD_sh + coef_Curt.coef(:,7).*Solar_sh.*Solar_sh.*Solar_sh + coef_Curt.coef(:,8).*Solar_sh.*WD_sh + coef_Curt.coef(:,9).*Solar_sh.*WD_sh.*WD_sh + coef_Curt.coef(:,10).*Solar_sh.*Solar_sh.*WD_sh );
     for i=1:reg
         if Solar_sh(i)+WD_sh(i)<0.2
             y(i)=0;// a supplmentary precaution, such that for very small VRE share curtailment is slight positive, this ruins everything
         end
     end
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

//for the dispatch-side of the elec nexus: get back the correct curtailment rate that yield a coherent net/gross VRE prod
// What do we know: 1 - gross gen per techno 2 - the total curtailment as a share of demand
// We do miss the net gen per techno, which is given by the logit in the investment module
function[y] = find_net_sh(xloc)
    nbtech = length(techno_ENRi_endo);
    //arg 1 = net VRE production
    net_sh_ENRi = xloc;
    //This is known
    gross_sh_ENRi = Gross_VRE_share_i_1;
    
    tot_gross = sum(gross_sh_ENRi,"c");
    tot_net = sum(net_sh_ENRi,"c");

    //First: get back the curt rate as a share of total demand
    curt_tot = curtailment_share_d([sum(gross_sh_ENRi(:,1:length(technoWind)),"c"),sum(gross_sh_ENRi(:,(length(technoWind)+1):$),"c")])

    //Compute the weights
    weights_wind_curt = beta_wd*sum(net_sh_ENRi(:,1:length(technoWind)),"c")./(alpha_pv*sum(net_sh_ENRi(:,(length(technoWind)+1):$),"c")+beta_wd*sum(net_sh_ENRi(:,1:length(technoWind)),"c"));
    weights_pv_curt = alpha_pv*sum(net_sh_ENRi(:,(length(technoWind)+1):$),"c")./(alpha_pv*sum(net_sh_ENRi(:,(length(technoWind)+1):$),"c")+beta_wd*sum(net_sh_ENRi(:,1:length(technoWind)),"c"));
    
    //Then the curt rate as a share of pv/wind gen
    curt_share_Wind = curt_tot./sum(net_sh_ENRi(:,1:length(technoWind)),"c").*weights_wind_curt;
    curt_share_PV = curt_tot./sum(net_sh_ENRi(:,(length(technoWind)+1):$),"c").*weights_pv_curt;

    //we do know the gross share of wind and pv gen: so we invert the equation gross = net (1+curt) to compute a new net share
    net_sh_ENRi = gross_sh_ENRi./(1+[repmat(curt_share_Wind,1,length(technoWind)),repmat(curt_share_PV,1,length(technoPV))]);

    y = [xloc - net_sh_ENRi]
endfunction
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function [y] = conv_WACC(tech,reg_m,weight_i,weight_e,num_CoC)
techno = tech; //the (set of) technology(es) concerned by the same level of convergence
reg_min = reg_m; //the regions on which the minimum CoC is looked for
weight_init = weight_i; //the weight on initial CoC
weight_end = weight_e; //the weight on final CoC
num = num_CoC; //the corresponding col line in the Global_WACC dataframe

[y] = min(weight_end*repmat(min(Global_WACC(reg_min,num)),reg,length(techno)) +weight_init*disc_rate_elec(:,techno,1),disc_rate_elec(:,techno,1))

endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function [y] =  peak_cov_calibration(xloc,xparam)
// this function constraints the investment in conventional power capacity depending on the peak load coverage (dispatch). If for the period t the conventionnal installed capacity is covering much more than the peak load then it is not rationnal to invest in additionnal conventionnal capacity (hydro being excluded)
    x=xloc;
    min_x =xparam(1); //1.2 // lower bound for peak coverage => below min_x, the investment goes as usual
    max_x =xparam(2); //1.8 // upper bound for peak coverage => above max_x, only y_low share of the desired investment is made
    min_y =xparam(3); //1; // maximum share of desired investment
    max_y =xparam(4); //0.6; // min share of desired investment when peak load coverage is too important

    a = (max_y-min_y)/(max_x - min_x );
    b = min_y-a*min_x ;
    if x<min_x 
    y = min_y
    else
        if x>max_x 
            y=max_y
        else
        y = a*x +b
        end
    end
    [y]
endfunction

//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

function y = load_hydro( data_path)
    Cap_hydro=csvRead( data_path);
    Cap_hydro = Cap_hydro(2:$);//removing header text in the CSV file
    nhydroyear = length(Cap_hydro)/reg;

    Cap_hydro_MW = zeros(reg,TimeHorizon+nb_year_expect_futur+1); //+1 because we are gonna remove the year 1 (=2014) after
    for i=1:reg
        bot = 1 + (i-1)*37;
        up = i*37;
        Cap_hydro_MW(i,1:nhydroyear) = Cap_hydro(bot:up)'; //Transforming in 12x37 (for 2050) data
    end
    // and turning it into a TimeHorizon-long dataframe. We assume for now that there is no additionnal hydro after 2050
    for k=(nhydroyear+1):TimeHorizon+nb_year_expect_futur+1
        Cap_hydro_MW(:,k)=Cap_hydro_MW(:,nhydroyear);
    end
    y = Cap_hydro_MW; //use in the investment nexus
endfunction

