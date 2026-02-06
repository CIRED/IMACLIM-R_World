// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// author: taconnet, leblanc
// To be executed at the end of each run

CSVDIR = SAVEDIR+sep+ind_impacts+"_"+damages_duration+"_"+impacted_sector+"csv"+sep;
mkdir(CSVDIR);

ldsav("last_done_year.dat");

startYear = 2014;
endYear   = startYear-1+last_done_year;
clear offset;

//Sectoral GDP, FE and EE
wGDP_sect = zeros(sec,TimeHorizon+1);

ldsav("aRD_sav");
ldsav("bRD_sav");
ldsav("cRD_sav");
ldsav("charge_sav");
ldsav("l_sav");
ldsav("Q_sav");
ldsav("CI_sav");
ldsav("pArmCI_sav");
ldsav("p_sav");
ldsav("wp_sav");
ldsav("w_sav");
ldsav("sigma_sav");
ldsav("taxCIdom_sav");
ldsav("partDomCI_sav");
ldsav("A_sav");
ldsav("mtax_sav");
ldsav("nit_sav");
ldsav("wpTIagg_sav");
ldsav("taxCIimp_sav");
ldsav("partImpCI_sav");
ldsav("taxCO2_CI_sav");
ldsav("coef_Q_CO2_CI_sav");
ldsav("DF_sav");
ldsav("partDomDF_sav"    );
ldsav("partImpDF_sav"    );
ldsav("taxCO2_DF_sav"    );
ldsav("coef_Q_CO2_DF_sav");
ldsav("DG_sav"           );
ldsav("partDomDG_sav"    );
ldsav("partImpDG_sav"    );
ldsav("taxCO2_DG_sav"    );
ldsav("coef_Q_CO2_DG_sav");
ldsav("DI_sav"           );
ldsav("partDomDI_sav"    );
ldsav("partImpDI_sav"    );
ldsav("taxCO2_DI_sav"    );
ldsav("coef_Q_CO2_DI_sav");
ldsav("Exp_sav");
ldsav("Imp_sav");
ldsav("xtax_sav");
ldsav("qtax_sav");
ldsav("Ttax_sav");
ldsav("taxDFdom_sav");
ldsav("taxDIdom_sav");
ldsav("taxDGdom_sav");
ldsav("taxDFimp_sav");
ldsav("taxDIimp_sav");
ldsav("taxDGimp_sav");
ldsav("markup_lim_oil_sav");
ldsav("Cap_sav");
ldsav("Rdisp_sav");
ldsav("IR_sav");
ldsav("ptc_sav");
ldsav("div_sav");
ldsav("partImpK_sav");
ldsav("partExpK_sav");
ldsav("pArmDF_sav");
ldsav("markup_sav");

aRD = aRD_sav;
bRD = bRD_sav;
cRD = cRD_sav;
charge = charge_sav;
l = l_sav;
Q = Q_sav;
pArmCI = pArmCI_sav;
pArmDF = pArmDF_sav;
p = p_sav;
w = w_sav;
wp = wp_sav;
sigma = sigma_sav;
taxCIdom = taxCIdom_sav;
partDomCI = partDomCI_sav;
CI = CI_sav;
A = A_sav;
mtax = mtax_sav;
nit = nit_sav;
wpTIagg = wpTIagg_sav;
taxCIimp = taxCIimp_sav;
partImpCI = partImpCI_sav;
taxCO2_CI = taxCO2_CI_sav;
coef_Q_CO2_CI = coef_Q_CO2_CI_sav;
DF=DF_sav;
partDomDF     = partDomDF_sav    ;
partImpDF     = partImpDF_sav    ;
taxCO2_DF     = taxCO2_DF_sav    ;
coef_Q_CO2_DF = coef_Q_CO2_DF_sav;
DG            = DG_sav           ;
partDomDG     = partDomDG_sav    ;
partImpDG     = partImpDG_sav    ;
taxCO2_DG     = taxCO2_DG_sav    ;
coef_Q_CO2_DG = coef_Q_CO2_DG_sav;
DI            = DI_sav           ;
partDomDI     = partDomDI_sav    ;
partImpDI     = partImpDI_sav    ;
taxCO2_DI     = taxCO2_DI_sav    ;
coef_Q_CO2_DI = coef_Q_CO2_DI_sav;
Exp = Exp_sav;
Imp = Imp_sav;
xtax = xtax_sav;
qtax = qtax_sav;
Ttax = Ttax_sav;
taxDFdom = taxDFdom_sav;
taxDIdom = taxDIdom_sav;
taxDGdom = taxDGdom_sav;
taxDFimp = taxDFimp_sav;
taxDIimp = taxDIimp_sav;
taxDGimp = taxDGimp_sav;
markup = markup_sav;
markupref = markup(:,1);
markup_lim_oil = markup_lim_oil_sav;
Cap = Cap_sav;

FCC = aRD + bRD.*tanh(cRD.*(divide(A.*Q,Cap,0)-1));
lab = FCC.*w.*l.*(1+sigma).*Q;
//FCC = aRD+bRD.*tanh(cRD.*(Q./Cap-1));

// NTN

csvWrite(Imp,CSVDIR+"Imp.csv");
csvWrite(Exp,CSVDIR+"Exp.csv");
csvWrite(Q,CSVDIR+"Q.csv");
csvWrite(DF,CSVDIR+"DF.csv");
csvWrite(wp,CSVDIR+"wp.csv");



paiement_balance = zeros(5,sec,TimeHorizon+1) ;

for i = 1:TimeHorizon+1
    aRD_temp=matrix(aRD(:,i),reg,sec);
    bRD_temp=matrix(bRD(:,i),reg,sec);
    cRD_temp=matrix(cRD(:,i),reg,sec);
    charge_temp=matrix(charge(:,i),reg,sec);
    l_temp=matrix(l(:,i),reg,sec);
    Q_temp=matrix(Q(:,i),reg,sec);
    pArmCI_temp=matrix(pArmCI(:,i),sec,sec,reg);
    pArmDF_temp=matrix(pArmDF(:,i),sec,reg);
    p_temp=matrix(p(:,i),reg,sec);
    w_temp=matrix(w(:,i),reg,sec);
    sigma_temp=matrix(sigma(:,i),reg,sec);
    taxCIdom_temp=matrix(taxCIdom(:,i),sec,sec,reg);
    partDomCI_temp=matrix(partDomCI(:,i),sec,sec,reg);
    CI_temp=matrix(CI(:,i),sec,sec,reg);
    A_temp=matrix(A(:,i),reg,sec);
    wp_temp=wp(:,i)';
    mtax_temp=matrix(mtax(:,i),reg,sec);
    nit_temp=matrix(nit(:,i),reg,sec);
    wpTIagg_temp = wpTIagg(i);
    taxCIimp_temp=matrix(taxCIimp(:,i),sec,sec,reg);
    partImpCI_temp=matrix(partImpCI(:,i),sec,sec,reg);
    taxCO2_CI_temp=matrix(taxCO2_CI(:,i),sec,sec,reg);
    coef_Q_CO2_CI_temp=matrix(coef_Q_CO2_CI(:,i),sec,sec,reg);
    num_temp=p_temp(ind_usa,indice_composite)*ones(reg,sec);
    DF_temp=matrix(DF(:,i),reg,sec);
    taxCO2_DF_temp    =matrix(taxCO2_DF(:,i),sec,reg);
    coef_Q_CO2_DF_temp=matrix(coef_Q_CO2_DF(:,i),sec,reg);
    DG_temp           =matrix(DG(:,i),sec,reg);
    taxCO2_DG_temp    =matrix(taxCO2_DG(:,i),sec,reg);
    coef_Q_CO2_DG_temp=matrix(coef_Q_CO2_DG(:,i),sec,reg);
    DI_temp           =matrix(DI(:,i),sec,reg);
    taxCO2_DI_temp    =matrix(taxCO2_DI(:,i),sec,reg);
    coef_Q_CO2_DI_temp=matrix(coef_Q_CO2_DI(:,i),sec,reg);
    Exp_temp=matrix(Exp(:,i),sec,reg);
    Imp_temp=matrix(Imp(:,i),sec,reg);
    xtax_temp=matrix(xtax(:,i),sec,reg);
    qtax_temp=matrix(qtax(:,i),sec,reg);
    FCC_temp=matrix(FCC(:,i),sec,reg);
    markup_temp = matrix(markup(:,i),sec,reg);
    markup_lim_oil_temp = matrix(markup_lim_oil(:,i),sec,reg);
    markupref_temp = matrix(markupref,sec,reg);
    Cap_temp = matrix(Cap(:,i),sec,reg);

    FCCmarkup_temp=ones(reg,sec);
    FCCmarkup_temp=divide((markup_lim_oil_temp-markupref_temp)/(1-0.8).*(divide(Q_temp,Cap_temp,0)-0.8*ones(reg,sec))+markupref_temp,markup_temp,0);
    FCCmarkup_oil_temp=ones(reg,sec);
    FCCmarkup_oil_temp(:,2)=FCCmarkup_temp(:,2);

    EBE_temp = p_temp.*Q_temp.*markup_temp.*FCCmarkup_oil_temp.*(FCC_temp.*energ_sec+non_energ_sec);
    //EBE = p.*Q.*markup.*FCCmarkup_oil.*(FCC.*energ_sec+non_energ_sec);
    EBE_sect(:,:,i) = EBE_temp;
    wEBE_sect(:,i) = sum(EBE_temp,1)';

    VA_temp=A_temp.*w_temp.*l_temp.*Q_temp.*(1).*(energ_sec+FCC_temp.*non_energ_sec)+EBE_temp;
    //VA=A.*w.*l.*Q.*(1).*(energ_sec+FCC.*non_energ_sec)+EBE;


    CI_ener_temp     = (squeeze(sum(CI_temp(1:nbsecteurenergie     ,:,:).*pArmCI_temp(1:nbsecteurenergie     ,:,:),1))').*(Q_temp);
    CI_non_ener_temp = (squeeze(sum(CI_temp(nbsecteurenergie+1:sec ,:,:).*pArmCI_temp(nbsecteurenergie+1:sec ,:,:),1))').*(Q_temp);

    wpQ(:,i) = sum(p_temp.*Q_temp,1)';

    wCI_ener_sect(:,i)    = squeeze(sum(CI_ener_temp    ,1))';
    wCI_non_ener_sect(:,i)= squeeze(sum(CI_non_ener_temp,1))';

    wlab_sect(:,i) = sum(matrix(lab(:,i),reg,sec),1)';

    wQ_temp = (sum(Q_temp,1))';

    wqtax_sect(:,i) = sum(p_temp.*Q_temp.*qtax_temp./(1+qtax_temp),1)';

    wCI_enerU(:,i)= divide(wCI_ener_sect(:,i),wQ_temp,0);
    wCI_nonEnerU(:,i) = divide(wCI_non_ener_sect(:,i),wQ_temp,0);
    wEBEU(:,i)=divide(wEBE_sect(:,i),wQ_temp,0);
    wlabU(:,i)= divide(wlab_sect(:,i),wQ_temp,0);
    wqtaxU(:,i)= divide(wqtax_sect(:,i),wQ_temp,0);

    // computing balance of payments (-Imp,+Exp,-ImpK,+ExpK):
    paiement_balance(1,:,i) = - sum( (wpTIagg_temp * nit_temp + ones(reg,1)*wp_temp) .* Imp_temp, 'c') ;
    paiement_balance(2,:,i) = sum( (1+xtax_temp).* p_temp .*Exp_temp, 'c') ;
    GRB_temp = Rdisp_sav(:,i) .* ( 1-IR_sav(:,i)) .* (1- ptc_sav(:,i)) + (1-div_sav(:,i)) .* sum(EBE_temp,'c') ;
    paiement_balance(3,:,i) = - ( sum(GRB_temp.*partExpK_sav(:,i)) * ones(1,reg) ) .* partImpK_sav(:,i)' ;
    paiement_balance(4,:,i) = GRB_temp .* partExpK_sav(:,i) ;
    paiement_balance(5,:,i) = sum( paiement_balance(:,:,i), 1 );
    for regy=1:reg
        paiement_balance(:,regy,i) = 100* divide( paiement_balance(:,regy,i), sum(abs(paiement_balance(1:4,regy,i))) , 0) ;
    end

    // end of loop on t=1:TimeHorizon
end

// balance of payments csv :
for regy=1:reg
    csvWrite( matrix(paiement_balance(:,regy,:),5,1+TimeHorizon) ,CSVDIR+"paiement_balance_"+regnames(regy)+".csv");
end

ldsav("GDP_secPPP_constant_sav");

GDP_sect = zeros(reg,sec,TimeHorizon+1);
for i=1:TimeHorizon+1
    GDP_sect(:,:,i) = matrix(GDP_secPPP_constant_sav(:,i),sec,reg);
end

// sectoral GDP csv :
for regy=1:reg
    csvWrite( matrix(GDP_sect(regy,:,:),sec,1+TimeHorizon) ,CSVDIR+"GDP_sect_"+regnames(regy)+".csv");
end

ldsav("l_exo_sav");
l_exo = l_exo_sav; 
l = l_sav; 
csvWrite(l, CSVDIR+"l.csv");
csvWrite(l_exo, CSVDIR+"l_exo.csv");

// labour cost as share of price
ldsav("aRD_sav");
aRD = aRD_sav;
ldsav("bRD_sav");
bRD = bRD_sav;
ldsav("cRD_sav");
cRD = cRD_sav;
ldsav("charge_sav");
charge = charge_sav;
ldsav("CI_sav");
ldsav("pArmCI_sav");
pArmCI = pArmCI_sav;
ldsav("p_sav");
p = p_sav;
ldsav("w_sav");
w = w_sav;
ldsav("sigma_sav");
sigma = sigma_sav;

FCC = aRD+bRD.*tanh(cRD.*(charge-1));
lab_cost = FCC.*w.*l.*(1+sigma);
lab_cost_exo = FCC.*w.*l_exo.*(1+sigma);
all_cost = pArmCI.*CI_sav;

csvWrite(lab_cost, CSVDIR+"lab_cost.csv"); 
csvWrite(lab_cost_exo, CSVDIR+"lab_cost_exo.csv"); 
csvWrite(all_cost, CSVDIR+"all_cost.csv"); 
csvWrite(DF_sav,CSVDIR+"DF.csv");
csvWrite(charge,CSVDIR+"charge.csv");
csvWrite(FCC,CSVDIR+"FCC.csv");
csvWrite(Cap_sav,CSVDIR+"Cap.csv");
ldsav("PtyLoss_sav");
PtyLoss=PtyLoss_sav;
csvWrite(PtyLoss,CSVDIR+"PtyLoss.csv");

ldsav("GDP_PPP_constant_sav");
//GDP_PPP_real = GDP_PPP_real_sav
csvWrite(GDP_PPP_constant_sav,CSVDIR+"GDP_PPP_constant.csv");

ldsav("Temp_change_sav");
csvWrite(Temp_change_sav,CSVDIR+"Temp_change.csv");

ldsav("E_cum_sav");
csvWrite(E_cum_sav,CSVDIR+"E_cum.csv");
ldsav("Inv_val_sav");
csvWrite(Inv_val_sav,CSVDIR+"Inv_val.csv");



//csvWrite(E_cum_sav,"THIS_IS_AN_ESSAY");


