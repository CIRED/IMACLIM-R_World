// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////calibration of climate finance nexus ///////////////////
///////////////////////////////////////////////////////////////////////////////////


//Initialized the dummy to loop on the nexus 
rerun_nexus_wacc = 0;
prevent_endless = 0;


inertia_climfin = 0.8; //inertia on the loop

// level of precision on the norm
norm_bound = 0.0001;
norm_bound_init = norm_bound;
//WACC parameters
share_climfin_debt = 1;
select ind_climfin

case 1
    share_climfin_debt = 1; //the share of debt covered by public co-financing, aka the average public debt commitment
case 2
    share_climfin_debt = 1; //the share of debt covered by public co-financing, aka the average public debt commitment
case 3
    if ~isdef("range_share")
        range_share=1;
    else
        run_id = run_id+"_share_"+range_share;
    end
    share_climfin_debt = 0.5*range_share; //the share of debt covered by public co-financing, aka the average public debt commitment



end

delta_debt_share = 0.1; //penalty on the maximum share of debt achievable in developing countries with public fin => max is 70%

climfin_loan = zeros(length(emerging_reg),1);
share_climfin_Inv = 0.2*ones(length(emerging_reg),1);
for techno=techno_ENR
    execstr("cumul_climfin_"+techno+"= zeros(length(emerging_reg),1);") //cumulated climate finance investments
    execstr("mobil_index_"+techno+"= zeros(length(emerging_reg),1);")
    execstr("inv_share_total_"+techno+"= ones(length(emerging_reg),1);")
end

// Range of scenario/sensibility analysis on the main parameters of the climfin
if ~isdef("range_rate")
    range_rate=1;
else
    run_id = run_id+"_rate_"+range_rate;
end
if ~isdef("range_equity")
    range_equity=1;
else
    run_id = run_id+"_eq_"+range_equity;
end
if ~isdef("range_risk")
    range_risk=1;
else
    run_id = run_id+"_risk_"+range_risk;
end
select ind_climfin
case 1 //no mobilization effect
    rate_climfin = 0.06*range_rate; //interest rate on public loans
    //adding ~isdef so these variables can be defined in the batch script
    max_climfin = 10^10*range_equity; //cumulated public investment threshold, when exceeded the share of debt in emerging economies goes to 0.8. If every high
    mobilisation_debt = 0*range_risk; // reduction of the risk premium on debt
case 2 // low mobilization effect
    rate_climfin = 0.04*range_rate; 
    max_climfin = 30*range_equity; //cumulated public investment threshold, when exceeded the share of debt in emerging economies goes to 0.8
    mobilisation_debt = 0*range_risk; // reduction of the risk premium on debt
case 3 //high mobilization effect
    rate_climfin = 0.03*range_rate; 
    max_climfin = 10*range_equity;
    mobilisation_debt = 0.02*range_risk; 
case 4 //convergence case : use the same setting as 3 to use this case as a upper bound
    rate_climfin = 0.03*range_rate; 
    max_climfin = 10*range_equity;
    mobilisation_debt = 0*range_risk;
case 5 //high mobilization effect with negative premium
    rate_climfin = 0.04*range_rate; 
    max_climfin = 20*range_equity;
    mobilisation_debt = 0.03*range_risk; 
end

// if we specify*
//only happens in the Catalyze&Blend case
red_max_spread = debt_margin/2;
// Global comment:

//climate finance annual portfolio
//these hardcoded values will come from a csv
energy_port_2020 = 15.59;
energy_port_2021 = 16.48;
energy_port_2022 = 18.16;
energy_port_2023 = 19.94;
energy_port_2024 = 21.30;
energy_port_2025 = 22.09;
energy_port = [0,0,0,0,0,energy_port_2020,energy_port_2021,energy_port_2022,energy_port_2023,energy_port_2024,energy_port_2025,energy_port_2025*ones(1,75)]; 
//starts in 2020

//for computationnal ease purposes, set to 0 after 2060, so the run are faster
energy_port((2060-base_year_simulation+1):$) = 0;

// assumption to extract the share of climate finance in the total energy public finance
// v.1 assumption: 80%. After removing some extra items as suggested by the reviewers, we get a rough average of 33% vs 74%
// anticpated share of climate finance in the total energy public finance to be 40%, as we expect MDB to green their portfolio
// indeed, if we isolate the share of FF inv, we get between 5% to 10% of the total energy public finance, which give a margin for increasing the share of renewable finance in energy finance from 35% to 40%. 
climfin_port = 0.4*energy_port;

if ind_climfin_inc //after 2025, linear increase of the renewable energy finance (xincr_ren_port in 10y)
    if ~isdef("incr_ren_port")
        incr_ren_port = 2;
    end
    climfin_port(11:21) = climfin_port(11:21).*linspace(1,incr_ren_port,11);
    climfin_port(22:$) = climfin_port(22:$).*incr_ren_port;

    run_id = run_id+"_"+incr_ren_port+"_port";
end

nb_year_climfin = length(climfin_port); 
//Geographical repartition of total annual portfolio: CIS, IND, MDE, AFR, RAS, RAL
//share_portfolio = [0.1,0.2,0.1,0.2,0.25,0.15]'; // old share from invesment demand
share_portfolio_tot = csvread(DATA+"OECD_CRS"+sep+"Share_fin.csv");
share_portfolio = strtod(share_portfolio_tot(2:$,2)) / 100;//since Brazil is excluded, this does not sum to 1

// yields the total annual portfolio per region
total_portfolio =   [repmat(climfin_port,length(emerging_reg),1).*repmat(share_portfolio,1,nb_year_climfin).*ones(length(emerging_reg),nb_year_climfin),zeros(length(share_portfolio),TimeHorizon-nb_year_climfin)];

for techno = techno_ENR
    execstr("WACC_"+techno+"_derisked = zeros(reg,1)")
    execstr("WACC_"+techno+"_unrisked = zeros(reg,1)")
end

for techno = techno_ENR
execstr("risk_sharing_pu_"+techno+" = zeros(reg,1)");
execstr("incr_leverage_"+techno+" = zeros(reg,1)");
end

if ind_climfin==4 //convergence case
    conv_start = 2020-base_year_simulation;
    conv_end = 2050-base_year_simulation;
    combi_climfin = 1103;
    ldsav("WACC_CPV_sav","",combi_climfin);
    ldsav("WACC_RPV_sav","",combi_climfin);
    ldsav("WACC_CSP_sav","",combi_climfin);
    ldsav("WACC_WND_sav","",combi_climfin);
    ldsav("WACC_WNO_sav","",combi_climfin);

    for techno = techno_ENR
        execstr("WACC_"+techno+"_sup = WACC_"+techno+"_sav");
    end
    
end

if ind_climfin == 3 //saving the WACC values for the converge case
    sg_add(["WACC_CPV","WACC_RPV","WACC_CSP","WACC_WNO","WACC_WND"])
end