//--------------------------------------------------------------------//
//---- climfin loop to find the level of concessionnal loans ------//
//--------------------------------------------------------------------//

Inv_val_ENR = Inv_MW(emerging_reg,[indice_CSP,techno_ENRi_endo]).*CINV_MW_nexus(emerging_reg,[indice_CSP,techno_ENRi_endo]);
Inv_val_ENR_tot = sum(Inv_val_ENR,"c");

for techno = techno_ENR
    execstr("inv_share_total_"+techno+" = (Inv_MW(emerging_reg,[indice_"+techno+"]).*CINV_MW_nexus(emerging_reg,[indice_"+techno+"]))./Inv_val_ENR_tot") // share of each techno in total investment, used in nexus.wacc to update the cumul_climfin variable
end

//total demand for debt from renewable investment 
total_VRE_debt_d = sum(Inv_val_ENR .*[Debt_share_CSP(emerging_reg),Debt_share_WND(emerging_reg),Debt_share_WNO(emerging_reg),Debt_share_CPV(emerging_reg),Debt_share_RPV(emerging_reg)]/10^6,"c"); //thousand to bn
climfin_loan = max(share_climfin_debt*share_climfin_Inv.*total_VRE_debt_d,0); //the loan portfolio based on the electricity nexus' calculation


// Computing the new share of renewable investment benefiting from climate finance loans (share_climfin_Inv)
rerun_nexus_reg = zeros(length(emerging_reg),1);

for k =1:length(emerging_reg)
emer_k = emerging_reg(k);
[outputs_climfin] = find_climfin_share(k);
share_climfin_Inv(k) = outputs_climfin(1);
rerun_nexus_reg(k) = outputs_climfin(2);
end
rerun_nexus_wacc = sum(rerun_nexus_reg);

