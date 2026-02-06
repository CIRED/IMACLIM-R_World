// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Thibault Briera, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//--------------------------------------------------------------------//
//-------------------- PRICE EXPECTATIONS----------------------------//
//--------------------------------------------------------------------//

pArmCI_no_taxCO2=zeros(sec,sec,reg);
pArmCI_w_CCS_indus=zeros(sec,sec,reg);
pArmCI_wo_CCS_indu=zeros(sec,sec,reg);


for k=1:reg
    pArmCI_no_taxCO2(1:nbsecteurenergie,:,k)=(pArmCI(1:nbsecteurenergie,:,k)-(taxCO2_CI_prev(1:nbsecteurenergie,:,k).*coef_Q_CO2_CI_prev(1:nbsecteurenergie,:,k)).*(num(k,1:nbsecteurenergie)'*ones(1,sec)));
    pArmCI_w_CCS_indus(1:nbsecteurenergie,:,k)=(pArmCI(1:nbsecteurenergie,:,k)-(taxCO2_CI_prev(1:nbsecteurenergie,:,k).* (coef_Q_CO2_CI_prev(1:nbsecteurenergie,:,k)-(1-CCS_efficiency_industry) * coef_Q_CO2_CI_wo_CCS(1:nbsecteurenergie,:,k))).*(num(k,1:nbsecteurenergie)'*ones(1,sec)));
    pArmCI_wo_CCS_indu(1:nbsecteurenergie,:,k)=(pArmCI(1:nbsecteurenergie,:,k)-(taxCO2_CI_prev(1:nbsecteurenergie,:,k).* (coef_Q_CO2_CI_prev(1:nbsecteurenergie,:,k)- coef_Q_CO2_CI_wo_CCS(1:nbsecteurenergie,:,k))).*(num(k,1:nbsecteurenergie)'*ones(1,sec)));
end

//saving expected prices
pArmCIantTxCO2_temp = zeros(sec,sec,reg);

pArmCI_anticip_taxCO2=zeros(sec*sec*reg,Life_time_max+1);

//T.B. This looks incredibly complicated just apply some inertia on pArmCI
// getting pArmCIantTxCO2_temp into a strange matrix form, then using only one column (pArmCI_anticip_taxCO2(:,10)) later on
for j=1:Life_time_max
    for k=1:reg
        pArmCIantTxCO2_temp(1:nbsecteurenergie,:,k)=pArmCI(1:nbsecteurenergie,:,k)-(taxCO2_CI_prev(1:nbsecteurenergie,:,k).*coef_Q_CO2_CI_prev(1:nbsecteurenergie,:,k))+(croyance_taxe(k)*(taxCO2_CI_ant(1:nbsecteurenergie,:,k)).*coef_Q_CO2_CI_noCCS(1:nbsecteurenergie,:,k));
    end
    pArmCI_anticip_taxCO2(:,j)=matrix(pArmCIantTxCO2_temp,sec*sec*reg,1);
end

pArmCI_nexus = (pArmCI+pArmCI_prev+pArmCI_prev_prev+pArmCI_prev_prev_prev)*1/4;
pArmCI_nexus = pArmCI_nexus*(1-min(interpln([[0,9,20];[0,0,1]],current_time_im),1))+matrix(pArmCI_anticip_taxCO2(:,10),sec,sec,reg)*min(interpln([[0,9,20];[0,0,1]],current_time_im),1);
pArmDF_nexus = (pArmDF+pArmDF_prev+pArmDF_prev_prev+pArmDF_prev_prev_prev)*1/4;

pArmCI_w_CCS_nexus = (pArmCI_w_CCS_indus+pArmCI_w_CCS_indus_p+pArmCI_w_CCS_indus_p_p+pArmCI_w_CCS_indus_p_p_p)*1/4;
pArmCI_w_CCS_nexus = pArmCI_w_CCS_nexus*(1-min(interpln([[0,9,20];[0,0,1]],current_time_im),1))+pArmCI_w_CCS_indus*min(interpln([[0,9,20];[0,0,1]],current_time_im),1);
pArmCI_wo_CCS_nexus = (pArmCI_wo_CCS_indu+pArmCI_wo_CCS_indu_p+pArmCI_wo_CCS_indu_p_p+pArmCI_wo_CCS_indu_p_p_p)*1/4;
pArmCI_wo_CCS_nexus = pArmCI_wo_CCS_nexus*(1-min(interpln([[0,9,20];[0,0,1]],current_time_im),1))+pArmCI_wo_CCS_indu*min(interpln([[0,9,20];[0,0,1]],current_time_im),1);

for expectedYear = 1:expectations.duration
    expected.pArmCI(:,:,:,expectedYear) = pArmCI - taxCO2_CI_prev .* coef_Q_CO2_CI_prev + croyanceTaxMat .* expected.taxCO2_CI(:,:,:,expectedYear) .* coef_Q_CO2_CI_noCCS ;
    expected.pArmCI_noCTax(:,:,:,expectedYear) = pArmCI - taxCO2_CI_prev .* coef_Q_CO2_CI_prev ;
    expected.pArmDF(:,:,expectedYear) = pArmDF - taxCO2_DF_prev .* coef_Q_CO2_DF_prev + (croyance_taxe * ones(1,sec) ) .* expected.taxCO2_DF(:,:,expectedYear) .* coef_Q_CO2_DF ;
end


////Fuel price expectations
//myopic expectation for FF prices
p_Et_oil_anticip = p(:,et);
p_gaz_anticip = p(:,gaz);

//expected tax on fuels
//T.B. : why would we use an average of current + expected (t+10)?
expectedTaxEtDF = zeros(reg,1);
expectedTaxGazDF = zeros(reg,1);
expectedTaxEtCI = zeros(reg,1,sec);
expectedTaxGazCI = zeros(reg,1,sec);

disc_rate_et = 0.1*ones(reg,1);

if test_expect_prices == 1
    for k=1:reg //
        expectedTaxEtDF(k) = sum([taxCO2_DF(k,indice_Et);squeeze(expected.taxCO2_DF(k,et,1:expectations.horizon.et))]'./ (1+disc_rate_et (k))^(1:(expectations.horizon.et+1)))/sum((1+disc_rate_et(k))^(1:(expectations.horizon.et+1)));
        expectedTaxGazDF(k) = sum([taxCO2_DF(k,indice_gas);squeeze(expected.taxCO2_DF(k,gaz,1:expectations.horizon.et)) ]'./ (1+disc_rate_et(k))^(1:(expectations.horizon.et+1)))/sum((1+disc_rate_et(k))^(1:(expectations.horizon.et+1)));
        for j=1:sec
            expectedTaxEtCI(k,:,j) = sum([taxCO2_CI(k,indice_Et,j); squeeze(expected.taxCO2_CI(k,et,j,1:expectations.horizon.et))]'./ (1+disc_rate_et(k))^(1:(expectations.horizon.et+1)))/sum((1+disc_rate_et(k))^(1:(expectations.horizon.et+1)))   ;
            expectedTaxGazCI(k,:,j)= sum([taxCO2_CI(k,indice_gas,j); squeeze(expected.taxCO2_CI(k,gaz,j,1:expectations.horizon.et))]'./ (1+disc_rate_et(k))^(1:(expectations.horizon.et+1)))/sum((1+disc_rate_et(k))^(1:(expectations.horizon.et+1)))  ;
        end
    end
else
    expectedTaxEtDF = ( taxCO2_DF(:,indice_Et) + expected.taxCO2_DF(:,et,expectations.horizon.et) ) / 2 ;
    expectedTaxGazDF = ( taxCO2_DF(:,indice_gas) + expected.taxCO2_DF(:,gaz,expectations.horizon.et) ) / 2 ;
    expectedTaxEtCI = ( taxCO2_CI(:,indice_Et,:) + expected.taxCO2_CI(:,et,:,expectations.horizon.et) ) / 2 ;
    expectedTaxGazCI = ( taxCO2_CI(:,indice_gas,:) + expected.taxCO2_CI(:,gaz,:,expectations.horizon.et) ) / 2 ;
end



//regional prices
p_Et_oil_exp_tax_ethan=p_Et_oil_anticip+(coef_Q_CO2_ref(:,indice_Et)-coef_Q_CO2_ethan).* expectedTaxEtDF ;
pEtOilExpTxBiodies=p_Et_oil_anticip+(coef_Q_CO2_ref(:,indice_Et)-coef_Q_CO2_biodiesel).* expectedTaxEtDF ;

//prices: world aggregates
pEtOilExpWldTxEthan=sum(p_Et_oil_exp_tax_ethan.*Q(:,indice_Et))./sum(Q(:,indice_Et))*lge2Mtoe*10^6;
pEtOilExpWldTxBiodies=sum(pEtOilExpTxBiodies.*Q(:,indice_Et))./sum(Q(:,indice_Et))*lge2Mtoe*10^6;
p_Et_oil_anticip_world=sum(p_Et_oil_anticip.*Q(:,indice_Et))./sum(Q(:,indice_Et))*lge2Mtoe*10^6;

p_et_anticip_reg = p_Et_oil_anticip+(coef_Q_CO2_ref(:,indice_Et)).* expectedTaxEtDF;
p_gaz_anticip_reg = p_gaz_anticip+(coef_Q_CO2_ref(:,indice_gas)).* expectedTaxGazDF;
wp_et_anticip_nlu = sum(p_et_anticip_reg.*Q(:,indice_Et))./sum(Q(:,indice_Et));
wp_et_exp_anticip_nlu = sum(p_et_anticip_reg.*Exp(:,indice_Et))./sum(Exp(:,indice_Et));
wp_gaz_anticip_nlu = sum(p_gaz_anticip_reg.*Q(:,indice_gas))./sum(Q(:,indice_gas));
