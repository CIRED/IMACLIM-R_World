// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


// load usefull variables
for var=["Inv_val_sav.sav","Inv_val_sec_sav.sav","Inv_val_sav.sav", "InvDem_sav.sav", "ptc_sav.sav", "div_sav.sav", "partExpK_sav.sav", "partImpK_sav.sav", "NRB_sav.sav", "p_sav.sav", "Cap_sav.sav", "Q_sav.sav", "pK_sav.sav", "w_sav.sav", "sigma_sav.sav", "aRD_sav.sav", "bRD_sav.sav", "cRD_sav.sav", "Rdisp_sav.sav","IR_sav.sav","markup_sav.sav", "GRB_sav.sav",]
    load(SAVEDIR+"save"+sep+var);
end

charge = divide(Q_sav, Cap_sav, 0);
FCC = aRD_sav + bRD_sav .* tanh( charge)
wage_cost = (1+sigma_sav) .* w_sav .* FCC;
EBE = p_sav.*Q_sav.*markup_sav;// FCCmarkup missing
poolK = sum(GRB_sav.*partExpK_sav,'r');

change_GRB_s_pc = Rdisp_sav.*(1-IR_sav).*(1-ptc_sav) * 0.01;
change_NRB_s_pc = change_GRB_s_pc.*(1-partExpK_sav);

Inv_missing = InvDem_sav-Inv_val_sec_sav;

inertia_change = 1;
// compute the change in capital availability for a 1% change in some parameters
for k=ind_afr
    ind_secs = linspace(k,k+12*11,12);
    charge_reg = charge( ind_secs,:)
    charge_indu = charge_reg(indus,:);
    charge_comp = charge_reg(compo,:);
    // compute changes by savings (pc= 1 per cent)
    //change_NRB_s_pc_reg = change_NRB_s_pc(ind_afr,:);
    Inv_missing_reg = sum(Inv_missing(ind_secs,:),"r");
    //change_s = divide(Inv_missing_reg, change_NRB_s_pc_reg, 0);

    // compute changes by div (pc= 1 per cent)
    filename = path_autocal_K+"change_div_"+string(k)+".csv";
    filename_invval = path_autocal_K+"Inv_val_previous_"+string(k)+".csv";
    filename_change_div = path_autocal_K+"change_div_previous_"+string(k)+".csv";
    if ~isfile(filename)
        // if first run, try to guess the Inv_val variation to 1 percent change in div
        ebe_reg = sum(EBE(ind_secs,:),"r");
        //change_GRB_div_pc_reg = (1-div_sav(ind_afr,:) * 0.01) .* ebe_reg;
        change_GRB_div_pc_reg = (-div_sav(ind_afr,:) * 0.01) .* ebe_reg;
        change_NRB_div_pc_reg = change_GRB_div_pc_reg.*(1-partExpK_sav(ind_afr,:));
        change_div = [divide(Inv_missing_reg(2:$), change_NRB_div_pc_reg(1:$-1), 0), 0];
        change_div = 1+ inertia_change*change_div*0.01;
        change_div = change_div .* ( [Inv_missing_reg(2:$),0] > 0) + 1 .*( [Inv_missing_reg(2:$),0] <= 0);
        change_div_new = change_div(1:$-1);
    else // use previous run to guess how much di should vary for Inv_val to vary
        change_div_previous = csvRead(filename_change_div);
        Inv_val_previous = csvRead(filename_invval);
        //change_div = change_div_previous.*change_div;
        change_div_new = divide(change_div_previous(1:$-1), ( divide(Inv_val_sav(k,2:$), Inv_val_previous(2:$), 1) ), 1) .* divide( Inv_missing_reg(2:$)+Inv_val_sav(k,2:$), Inv_val_sav(k,2:$), 1);
        change_div_new = (change_div_new -1)*inertia_change +1;
        change_div_new = change_div_new .* ( Inv_missing_reg(2:$) > 0) + 1 .*( Inv_missing_reg(2:$) <= 0)
        change_div = change_div_previous .* [change_div_new, 1];
    end
    csvWrite( change_div, filename);
    csvWrite( [change_div_new, 1], filename_change_div);
    csvWrite( Inv_val_sav(k,:), filename_invval);

    // compute changes for partImpK
    //change_NRB_pIK_pc = 0.01 * partImpK_sav(ind_afr,:) .* poolK;
    //change_pIK = divide(Inv_missing_reg, change_NRB_pIK_pc, 0);

end


