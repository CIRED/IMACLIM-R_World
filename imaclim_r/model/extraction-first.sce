// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

[Conso ,Tautomobile ,lambda ,mu ,p ,w ,Q ,Rdisp ,TNM ,wpEner] = expand_equilibrium(equilibrium);
taxCO2_CI_prev          =taxCO2_CI;
taxCO2_DF_prev          =taxCO2_DF;
taxCO2_DG_prev          =taxCO2_DG;
[taxCO2_DF, taxCO2_DG, taxCO2_DI, taxCO2_CI, taxMKT]=expand_tax(equilibrium,taxCO2_DF, taxCO2_DG, taxCO2_DI, taxCO2_CI, taxMKT, weight_regional_tax);

sg_add(["Conso"
"Tautomobile"
"lambda"
"mu "
"p "
"w "
"Q "
"Rdisp "
"TNM "
"wpEner"
"taxCO2_CI"
"taxCO2_DF"
"taxCO2_DG"
"taxCO2_DI"
"taxMKT"])

//normalisation by the numeraire
num=p(1,indice_composite);
p=p./num;
w=w./num;
Rdisp=Rdisp./num;
wpEner=wpEner./num;

Q_biofuel=zeros ( reg,TimeHorizon+1);
share_NC_sav=zeros(1,TimeHorizon+1);

Code_Regions  = [ 1:reg]';

Code_Regions_oil=[ ];
for ii=1:nb_cat_oil
    Code_Regions_oil=[ Code_Regions_oil;
    Code_Regions];
end

Code_Regions_heavy=[ ];
for ii=1:nb_cat_heavy
    Code_Regions_heavy=[ Code_Regions_heavy;
    Code_Regions];
end

output_oil_Total = [ 0;
Code_Regions_oil;
9;
Code_Regions_heavy;
Code_Regions;
0;
];
/////////////////////////////////////////////////////
////////////////////////////////////////////////////

num=p(1,indice_composite)*ones(reg,sec);
//num = p(:,indice_composite)*ones(1,sec);

DF = DFinduite(Conso,Tautomobile);

charge =   A.*Q./Cap; 

FCC = aRD+bRD.*tanh(cRD.*(A.*Q./Cap-1));
FCCmarkup = ((1/0.8).*(A.*Q./Cap));
FCCmarkup=((markup_lim_oil-markupref)/(1-0.8).*(A.*Q./Cap-0.8*ones(reg,sec))+markupref)./markup;

//////////// non energy sectors ////////////////
wp = zeros(1,sec);
wp(:,sec-nb_secteur_conso+1:sec) = sum((weight.^(ones(reg,1)*eta)).*((p(:,sec-nb_secteur_conso+1:sec).*(1+xtax(:,sec-nb_secteur_conso+1:sec))).^(1-ones(reg,1)*eta)),"r").^(ones(1,nb_secteur_conso)./(1-eta));
wpTI = zeros(1,nb_trans);
wpTI = sum((weightTI.^(ones(reg,nb_trans)*etaTI).*(p(:,indice_transport_1:indice_transport_2).^(1-ones(reg,nb_trans)*etaTI))),'r').^(1 ./(1-etaTI));
wpTIagg = sum(wpTI.*partTIref);

pArmDF(:,sec-nb_secteur_conso+1:sec) = ((bDF.^etaDF).*((p(:,sec-nb_secteur_conso+1:sec).*(1+taxDFdom(:,sec-nb_secteur_conso+1:sec))).^(1-etaDF))+((1-bDF).^etaDF).*((((ones(reg,1)*wp(sec-nb_secteur_conso+1:sec)).*(1+mtax(:,sec-nb_secteur_conso+1:sec))+(ones(reg,nb_secteur_conso)*wpTIagg).*nit(:,sec-nb_secteur_conso+1:sec)).*(1+taxDFimp(:,sec-nb_secteur_conso+1:sec))).^(1-etaDF))).^(ones(reg,nb_secteur_conso)./(1-etaDF));
pArmDG(:,sec-nb_secteur_conso+1:sec) = ((bDG.^etaDG).*((p(:,sec-nb_secteur_conso+1:sec).*(1+taxDGdom(:,sec-nb_secteur_conso+1:sec))).^(1-etaDG))+((1-bDG).^etaDG).*((((ones(reg,1)*wp(sec-nb_secteur_conso+1:sec)).*(1+mtax(:,sec-nb_secteur_conso+1:sec))+(ones(reg,nb_secteur_conso)*wpTIagg).*nit(:,sec-nb_secteur_conso+1:sec)).*(1+taxDGimp(:,sec-nb_secteur_conso+1:sec))).^(1-etaDG))).^(ones(reg,nb_secteur_conso)./(1-etaDG));
pArmDI(:,sec-nb_secteur_conso+1:sec) = ((bDI.^etaDI).*((p(:,sec-nb_secteur_conso+1:sec).*(1+taxDIdom(:,sec-nb_secteur_conso+1:sec))).^(1-etaDI))+((1-bDI).^etaDI).*((((ones(reg,1)*wp(sec-nb_secteur_conso+1:sec)).*(1+mtax(:,sec-nb_secteur_conso+1:sec))+(ones(reg,nb_secteur_conso)*wpTIagg).*nit(:,sec-nb_secteur_conso+1:sec)).*(1+taxDIimp(:,sec-nb_secteur_conso+1:sec))).^(1-etaDI))).^(ones(reg,nb_secteur_conso)./(1-etaDI));
partDomDF(:,sec-nb_secteur_conso+1:sec) = (bDF.^etaDF).*((pArmDF(:,sec-nb_secteur_conso+1:sec)./(p(:,sec-nb_secteur_conso+1:sec).*(1+taxDFdom(:,sec-nb_secteur_conso+1:sec)))).^etaDF);
partImpDF(:,sec-nb_secteur_conso+1:sec) = ((1-bDF).^etaDF).*((pArmDF(:,sec-nb_secteur_conso+1:sec)./(((ones(reg,1)*wp(sec-nb_secteur_conso+1:sec)).*(1+mtax(:,sec-nb_secteur_conso+1:sec))+(ones(reg,nb_secteur_conso)*wpTIagg).*nit(:,sec-nb_secteur_conso+1:sec)).*(1+taxDFimp(:,sec-nb_secteur_conso+1:sec)))).^etaDF);
partDomDG(:,sec-nb_secteur_conso+1:sec) = (bDG.^etaDG).*((pArmDG(:,sec-nb_secteur_conso+1:sec)./(p(:,sec-nb_secteur_conso+1:sec).*(1+taxDGdom(:,sec-nb_secteur_conso+1:sec)))).^etaDG);
partImpDG(:,sec-nb_secteur_conso+1:sec) = ((1-bDG).^etaDG).*((pArmDG(:,sec-nb_secteur_conso+1:sec)./(((ones(reg,1)*wp(sec-nb_secteur_conso+1:sec)).*(1+mtax(:,sec-nb_secteur_conso+1:sec))+(ones(reg,nb_secteur_conso)*wpTIagg).*nit(:,sec-nb_secteur_conso+1:sec)).*(1+taxDGimp(:,sec-nb_secteur_conso+1:sec)))).^etaDG);
partDomDI(:,sec-nb_secteur_conso+1:sec) = (bDI.^etaDI).*((pArmDI(:,sec-nb_secteur_conso+1:sec)./(p(:,sec-nb_secteur_conso+1:sec).*(1+taxDIdom(:,sec-nb_secteur_conso+1:sec)))).^etaDI);
partImpDI(:,sec-nb_secteur_conso+1:sec) = ((1-bDI).^etaDI).*((pArmDI(:,sec-nb_secteur_conso+1:sec)./(((ones(reg,1)*wp(sec-nb_secteur_conso+1:sec)).*(1+mtax(:,sec-nb_secteur_conso+1:sec))+(ones(reg,nb_secteur_conso)*wpTIagg).*nit(:,sec-nb_secteur_conso+1:sec)).*(1+taxDIimp(:,sec-nb_secteur_conso+1:sec)))).^etaDI);

for k = 1:reg,
    pArmCI(sec-nb_secteur_conso+1:sec,:,k) = ((bCI(:,:,k).^etaCI(:,:,k)).*(((p(k,sec-nb_secteur_conso+1:sec)'*ones(1,sec)).*(1+taxCIdom(sec-nb_secteur_conso+1:sec,:,k))).^(1-etaCI(:,:,k)))+((1-bCI(:,:,k)).^etaCI(:,:,k)).*((((wp(sec-nb_secteur_conso+1:sec).*(1+mtax(k,sec-nb_secteur_conso+1:sec))+nit(k,sec-nb_secteur_conso+1:sec).*wpTIagg)'*ones(1,sec)).*(1+taxCIimp(sec-nb_secteur_conso+1:sec,:,k))).^(1-etaCI(:,:,k)))).^(ones(nb_secteur_conso,sec)./(1-etaCI(:,:,k)));
    partDomCI(sec-nb_secteur_conso+1:sec,:,k) = (bCI(:,:,k).^etaCI(:,:,k)).*((pArmCI(sec-nb_secteur_conso+1:sec,:,k)./((p(k,sec-nb_secteur_conso+1:sec)'*ones(1,sec)).*(1+taxCIdom(sec-nb_secteur_conso+1:sec,:,k)))).^etaCI(:,:,k));
    partImpCI(sec-nb_secteur_conso+1:sec,:,k) = ((1-bCI(:,:,k)).^etaCI(:,:,k)).*((pArmCI(sec-nb_secteur_conso+1:sec,:,k)./(((wp(sec-nb_secteur_conso+1:sec).*(1+mtax(k,sec-nb_secteur_conso+1:sec))+nit(k,sec-nb_secteur_conso+1:sec).*wpTIagg)'*ones(1,sec)).*(1+taxCIimp(sec-nb_secteur_conso+1:sec,:,k)))).^etaCI(:,:,k));
end


marketshare(:,sec-nb_secteur_conso+1:sec)  =  (weight.^(ones(reg,1)*eta)).*(((p(:,sec-nb_secteur_conso+1:sec).*(1+xtax(:,sec-nb_secteur_conso+1:sec))).^(ones(reg,1)*(1-eta)))./(ones(reg,1)*sum((weight.^(ones(reg,1)*eta)).*((p(:,sec-nb_secteur_conso+1:sec).*(1+xtax(:,sec-nb_secteur_conso+1:sec))).^(1-ones(reg,1)*eta)),"r"))).^(ones(reg,1)*(eta./(eta-1)));
marketshareTI = (weightTI.^(ones(reg,nb_trans)*etaTI)).*((p(:,indice_transport_1:indice_transport_2).^(1-ones(reg,nb_trans)*etaTI))./(ones(reg,1)*sum((weightTI.^(ones(reg,nb_trans)*etaTI)).*(p(:,indice_transport_1:indice_transport_2).^(1-ones(reg,nb_trans)*etaTI)),"r"))).^(ones(reg,nb_trans)*(etaTI./(etaTI-1)));

//////////// secteurs énergétiques /////////////////////////////////////

partDomDF(:,1:nbsecteurenergie)=((p(:,1:nbsecteurenergie).*(1+taxDFdom(:,1:nbsecteurenergie)))+itgbl_cost_DFdom.*p(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDF./(((p(:,1:nbsecteurenergie).*(1+taxDFdom(:,1:nbsecteurenergie)))+itgbl_cost_DFdom.*p(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDF+(((ones(reg,1)*wpEner).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDFimp(:,1:nbsecteurenergie))+itgbl_cost_DFimp.*(ones(reg,1)*(wpEner./wpEnerref))).^alpha_partDF);
partDomDG(:,1:nbsecteurenergie)=((p(:,1:nbsecteurenergie).*(1+taxDGdom(:,1:nbsecteurenergie)))+itgbl_cost_DGdom.*p(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDG./(((p(:,1:nbsecteurenergie).*(1+taxDGdom(:,1:nbsecteurenergie)))+itgbl_cost_DGdom.*p(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDG+(((ones(reg,1)*wpEner).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDGimp(:,1:nbsecteurenergie))+itgbl_cost_DGimp.*(ones(reg,1)*(wpEner./wpEnerref))).^alpha_partDG);
partDomDI(:,1:nbsecteurenergie)=((p(:,1:nbsecteurenergie).*(1+taxDIdom(:,1:nbsecteurenergie)))+itgbl_cost_DIdom.*p(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDI./(((p(:,1:nbsecteurenergie).*(1+taxDIdom(:,1:nbsecteurenergie)))+itgbl_cost_DIdom.*p(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDI+(((ones(reg,1)*wpEner).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDIimp(:,1:nbsecteurenergie))+itgbl_cost_DIimp.*(ones(reg,1)*(wpEner./wpEnerref))).^alpha_partDI);
partDomDF(:,indice_elec) = partDomDFref(:,indice_elec);
partDomDG(:,indice_elec) = partDomDGref(:,indice_elec);
partDomDI(:,indice_elec) = partDomDIref(:,indice_elec);
// partDomDF(:,indice_Et)=partDomDFref(:,indice_Et);
// partDomDG(:,indice_Et)=partDomDGref(:,indice_Et);
// partDomDI(:,indice_Et)=partDomDIref(:,indice_Et);

//oil specific case: region with high load rate cannot consume their own pdocution
mult_oil=max(0.000001,a4_mult_oil.*min(charge(:,indice_oil),0.999).^4+ a3_mult_oil.*min(charge(:,indice_oil),0.999).^3 +a2_mult_oil.*min(charge(:,indice_oil),0.999).^2+ a1_mult_oil.*min(charge(:,indice_oil),0.999)+a0_mult_oil);

partDomDF(:,indice_oil)=min(partDomDF(:,indice_oil).*mult_oil,partDomDF(:,indice_oil));
partDomDF(:,indice_oil)=max(0,partDomDF(:,indice_oil));

partDomDG(:,indice_oil)=min(partDomDG(:,indice_oil).*mult_oil,partDomDG(:,indice_oil));
partDomDG(:,indice_oil)=max(0,partDomDG(:,indice_oil));

partDomDI(:,indice_oil)=min(partDomDI(:,indice_oil).*mult_oil,partDomDI(:,indice_oil));
partDomDI(:,indice_oil)=max(0,partDomDI(:,indice_oil));

mult_gaz=max(0.000001,a4_mult_gaz.*min(charge(:,indice_gas),0.999).^4+ a3_mult_gaz.*min(charge(:,indice_gas),0.999).^3 +a2_mult_gaz.*min(charge(:,indice_gas),0.999).^2+ a1_mult_gaz.*min(charge(:,indice_gas),0.999)+a0_mult_gaz);


partDomDF(:,indice_gas)=min(partDomDF(:,indice_gas).*mult_gaz,partDomDF(:,indice_gas));
partDomDF(:,indice_gas)=max(0,partDomDF(:,indice_gas));

partDomDG(:,indice_gas)=min(partDomDG(:,indice_gas).*mult_gaz,partDomDG(:,indice_gas));
partDomDG(:,indice_gas)=max(0,partDomDG(:,indice_gas));

partDomDI(:,indice_gas)=min(partDomDI(:,indice_gas).*mult_gaz,partDomDI(:,indice_gas));
partDomDI(:,indice_gas)=max(0,partDomDI(:,indice_gas));

partDomDF(:,1:nbsecteurenergie)=partDomDF(:,1:nbsecteurenergie)*inertia_share+partDomDF_stock(:,1:nbsecteurenergie)*(1-inertia_share);
partDomDG(:,1:nbsecteurenergie)=partDomDG(:,1:nbsecteurenergie)*inertia_share+partDomDG_stock(:,1:nbsecteurenergie)*(1-inertia_share);
partDomDI(:,1:nbsecteurenergie)=partDomDI(:,1:nbsecteurenergie)*inertia_share+partDomDI_stock(:,1:nbsecteurenergie)*(1-inertia_share);

partImpDF(:,1:nbsecteurenergie) = 1-partDomDF(:,1:nbsecteurenergie);
partImpDG(:,1:nbsecteurenergie) = 1-partDomDG(:,1:nbsecteurenergie);
partImpDI(:,1:nbsecteurenergie) = 1-partDomDI(:,1:nbsecteurenergie);

for k = 1:reg,
    partDomCI(1:nbsecteurenergie,:,k)=(((p(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k)))+itgbl_cost_CIdom(:,:,k).*((p(k,1:nbsecteurenergie)./pref(k,1:nbsecteurenergie))'*ones(1,sec))).^alpha_partCI(:,:,k)./((((p(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k)))+itgbl_cost_CIdom(:,:,k).*((p(k,1:nbsecteurenergie)./pref(k,1:nbsecteurenergie))'*ones(1,sec))).^alpha_partCI(:,:,k)+((((wpEner(1:nbsecteurenergie).*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIagg)'*ones(1,sec)).*(1+taxCIimp(1:nbsecteurenergie,:,k)))+itgbl_cost_CIimp(:,:,k).*((wpEner./wpEnerref)'*ones(1,sec))).^alpha_partCI(:,:,k));
    partDomCI(indice_elec,:,k) = partDomCIref(indice_elec,:,k);
    partDomCI(indice_Et,:,k)=partDomCIref(indice_Et,:,k);

    partDomCI(indice_oil,:,k)=min(partDomCI(indice_oil,:,k)*mult_oil(k),partDomCI(indice_oil,:,k));
    partDomCI(indice_oil,:,k)=max(0,partDomCI(indice_oil,:,k));

    partDomCI(indice_gas,:,k)=min(partDomCI(indice_gas,:,k)*mult_gaz(k),partDomCI(indice_gas,:,k));
    partDomCI(indice_gas,:,k)=max(0,partDomCI(indice_gas,:,k));

    partDomCI(1:nbsecteurenergie,:,k)=partDomCI(1:nbsecteurenergie,:,k)*inertia_share+partDomCI_stock(1:nbsecteurenergie,:,k)*(1-inertia_share);
    partImpCI(1:nbsecteurenergie,:,k) = 1-partDomCI(1:nbsecteurenergie,:,k);
end


marketshare(:,1:nbsecteurenergie) = bmarketshareener.*((p(:,1:nbsecteurenergie).*(1+xtax(:,1:nbsecteurenergie))./(p_stock(:,1:nbsecteurenergie).*(1+xtaxref(:,1:nbsecteurenergie)))).^(ones(reg,1)*etamarketshareener))./(ones(reg,1)*sum(bmarketshareener.*((p(:,1:nbsecteurenergie).*(1+xtax(:,1:nbsecteurenergie))./(p_stock(:,1:nbsecteurenergie).*(1+xtaxref(:,1:nbsecteurenergie)))).^(ones(reg,1)*etamarketshareener)),'r'));
if new_Et_msh_computation ==1
    marketshare(:,4) = weightEt_new .* (( taxCO2_DF(:,4).* new_Et_msh_computation .* coef_Q_CO2_Et_prod .* num(:,4)  + p(:,indice_Et).*(1+xtax(:,indice_Et)) ) .^ etaEtnew) ./ sum( weightEt_new .* (( taxCO2_DF(:,4).* new_Et_msh_computation .* coef_Q_CO2_Et_prod .* num(:,4) +p(:,indice_Et).*(1+xtax(:,indice_Et))) .^ etaEtnew));
end

//oil market correction: region with a high load rate do not export
marketshare(:,indice_oil)=min(marketshare(:,indice_oil).*mult_oil,marketshare(:,indice_oil));
marketshare(:,indice_oil)=max(0.00000001,marketshare(:,indice_oil));
marketshare(:,indice_oil)=marketshare(:,indice_oil)/(sum(marketshare(:,indice_oil),'r'));

marketshare(:,indice_gas)=min(marketshare(:,indice_gas).*mult_gaz,marketshare(:,indice_gas));
marketshare(:,indice_gas)=max(0.00000001,marketshare(:,indice_gas));
marketshare(:,indice_gas)=marketshare(:,indice_gas)/(sum(marketshare(:,indice_gas),'r'));

wp(:,1:nbsecteurenergie) = wpEner;

pArmDF(:,1:nbsecteurenergie)=(p(:,1:nbsecteurenergie).*(1+taxDFdom(:,1:nbsecteurenergie))).*(1-partImpDF(:,1:nbsecteurenergie))+(((ones(reg,1)*wpEner).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDFimp(:,1:nbsecteurenergie))).*partImpDF(:,1:nbsecteurenergie)+taxCO2_DF(:,1:nbsecteurenergie).*coef_Q_CO2_DF(:,1:nbsecteurenergie).*num(:,1:nbsecteurenergie);
pArmDG(:,1:nbsecteurenergie)=(p(:,1:nbsecteurenergie).*(1+taxDGdom(:,1:nbsecteurenergie))).*(1-partImpDG(:,1:nbsecteurenergie))+(((ones(reg,1)*wpEner).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDGimp(:,1:nbsecteurenergie))).*partImpDG(:,1:nbsecteurenergie)+taxCO2_DG(:,1:nbsecteurenergie).*coef_Q_CO2_DG(:,1:nbsecteurenergie).*num(:,1:nbsecteurenergie);
pArmDI(:,1:nbsecteurenergie)=(p(:,1:nbsecteurenergie).*(1+taxDIdom(:,1:nbsecteurenergie))).*(1-partImpDI(:,1:nbsecteurenergie))+(((ones(reg,1)*wpEner).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDIimp(:,1:nbsecteurenergie))).*partImpDI(:,1:nbsecteurenergie)+taxCO2_DI(:,1:nbsecteurenergie).*coef_Q_CO2_DI(:,1:nbsecteurenergie).*num(:,1:nbsecteurenergie);
for k=1:reg,
    pArmCI(1:nbsecteurenergie,:,k)=((p(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k))).*(1-partImpCI(1:nbsecteurenergie,:,k))+(((wpEner.*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIagg)'*ones(1,sec)).*(1+taxCIimp(1:nbsecteurenergie,:,k))).*partImpCI(1:nbsecteurenergie,:,k)+(taxCO2_CI(1:nbsecteurenergie,:,k).*coef_Q_CO2_CI(1:nbsecteurenergie,:,k)).*(num(k,1:nbsecteurenergie)'*ones(1,sec));
end

pArmDF = pArmDF.*(1+Ttax);
//pArmDF=pArmDF+(Ttax1);

/////////// consumption price index
//pind = sum(pArmDF.*(pArmDF.*DF./((Rdisp.*(1-IR).*ptc)*ones(1,sec))),"c");
pind=(sum(pArmDF.*DF,'c')./sum(pArmDFref.*DF,'c').*sum(pArmDF.*DFref,'c')./sum(pArmDFref.*DFref,'c')).^(1/2);
pind_prod=(sum(p.*Q,'c')./sum(pref.*Q,'c').*sum(p.*Qref,'c')./sum(pref.*Qref,'c')).^(1/2);

GRB = ones(reg,1);
GRB = Rdisp.*(1-IR).*(1-ptc)+(1-div).*sum(p.*Q.*markup.*(FCC.*energ_sec+non_energ_sec),'c');
NRB = ones(reg,1);
NRB = (GRB.*(1-partExpK)+partImpK.*(ones(reg,1)*sum(GRB.*partExpK)));
DI = DIinfra + DIprod.*(((NRB-sum(DIinfra.*pArmDI,'c'))./sum(DIprod.*pArmDI,'c'))*ones(1,sec));

/////////// exports & imports
QCdom = ones(reg,sec);
QCdom = [(A_CI(1,:).*Q(1,:))*((CI(:,:,1).*partDomCI(:,:,1))');
(A_CI(2,:).*Q(2,:))*((CI(:,:,2).*partDomCI(:,:,2))');
(A_CI(3,:).*Q(3,:))*((CI(:,:,3).*partDomCI(:,:,3))');
(A_CI(4,:).*Q(4,:))*((CI(:,:,4).*partDomCI(:,:,4))');
(A_CI(5,:).*Q(5,:))*((CI(:,:,5).*partDomCI(:,:,5))');
(A_CI(6,:).*Q(6,:))*((CI(:,:,6).*partDomCI(:,:,6))');
(A_CI(7,:).*Q(7,:))*((CI(:,:,7).*partDomCI(:,:,7))');
(A_CI(8,:).*Q(8,:))*((CI(:,:,8).*partDomCI(:,:,8))');
(A_CI(9,:).*Q(9,:))*((CI(:,:,9).*partDomCI(:,:,9))');
(A_CI(10,:).*Q(10,:))*((CI(:,:,10).*partDomCI(:,:,10))');
(A_CI(11,:).*Q(11,:))*((CI(:,:,11).*partDomCI(:,:,11))');
(A_CI(12,:).*Q(12,:))*((CI(:,:,12).*partDomCI(:,:,12))')]+DF.*partDomDF+DG.*partDomDG+DI.*partDomDI;

Imp = ones(reg,sec);
Imp = [(A_CI(1,:).*Q(1,:))*((CI(:,:,1).*(partImpCI(:,:,1)))');
(A_CI(2,:).*Q(2,:))*((CI(:,:,2).*(partImpCI(:,:,2)))');
(A_CI(3,:).*Q(3,:))*((CI(:,:,3).*(partImpCI(:,:,3)))');
(A_CI(4,:).*Q(4,:))*((CI(:,:,4).*(partImpCI(:,:,4)))');
(A_CI(5,:).*Q(5,:))*((CI(:,:,5).*(partImpCI(:,:,5)))');
(A_CI(6,:).*Q(6,:))*((CI(:,:,6).*(partImpCI(:,:,6)))');
(A_CI(7,:).*Q(7,:))*((CI(:,:,7).*(partImpCI(:,:,7)))');
(A_CI(8,:).*Q(8,:))*((CI(:,:,8).*(partImpCI(:,:,8)))');
(A_CI(9,:).*Q(9,:))*((CI(:,:,9).*(partImpCI(:,:,9)))');
(A_CI(10,:).*Q(10,:))*((CI(:,:,10).*(partImpCI(:,:,10)))');
(A_CI(11,:).*Q(11,:))*((CI(:,:,11).*(partImpCI(:,:,11)))');
(A_CI(12,:).*Q(12,:))*((CI(:,:,12).*(partImpCI(:,:,12)))')]+DF.*(partImpDF)+DG.*(partImpDG)+DI.*(partImpDI);



Exp = marketshare.*(ones(reg,1)*sum(Imp,"r"));

ExpTI = zeros(reg,sec);
ExpTI(:,indice_transport_1:indice_transport_2)=marketshareTI.*(ones(reg,1)*(sum(Imp.*nit)*partTIref));

QCdom_noDI= [(A_CI(1,:).*Q(1,:))*((CI(:,:,1).*partDomCI(:,:,1))');
(A_CI(2,:).*Q(2,:))*((CI(:,:,2).*partDomCI(:,:,2))');
(A_CI(3,:).*Q(3,:))*((CI(:,:,3).*partDomCI(:,:,3))');
(A_CI(4,:).*Q(4,:))*((CI(:,:,4).*partDomCI(:,:,4))');
(A_CI(5,:).*Q(5,:))*((CI(:,:,5).*partDomCI(:,:,5))');
(A_CI(6,:).*Q(6,:))*((CI(:,:,6).*partDomCI(:,:,6))');
(A_CI(7,:).*Q(7,:))*((CI(:,:,7).*partDomCI(:,:,7))');
(A_CI(8,:).*Q(8,:))*((CI(:,:,8).*partDomCI(:,:,8))');
(A_CI(9,:).*Q(9,:))*((CI(:,:,9).*partDomCI(:,:,9))');
(A_CI(10,:).*Q(10,:))*((CI(:,:,10).*partDomCI(:,:,10))');
(A_CI(11,:).*Q(11,:))*((CI(:,:,11).*partDomCI(:,:,11))');
(A_CI(12,:).*Q(12,:))*((CI(:,:,12).*partDomCI(:,:,12))')]+DF.*partDomDF+DG.*partDomDG;

Imp_noDI = [(A_CI(1,:).*Q(1,:))*((CI(:,:,1).*(partImpCI(:,:,1)))');
(A_CI(2,:).*Q(2,:))*((CI(:,:,2).*(partImpCI(:,:,2)))');
(A_CI(3,:).*Q(3,:))*((CI(:,:,3).*(partImpCI(:,:,3)))');
(A_CI(4,:).*Q(4,:))*((CI(:,:,4).*(partImpCI(:,:,4)))');
(A_CI(5,:).*Q(5,:))*((CI(:,:,5).*(partImpCI(:,:,5)))');
(A_CI(6,:).*Q(6,:))*((CI(:,:,6).*(partImpCI(:,:,6)))');
(A_CI(7,:).*Q(7,:))*((CI(:,:,7).*(partImpCI(:,:,7)))');
(A_CI(8,:).*Q(8,:))*((CI(:,:,8).*(partImpCI(:,:,8)))');
(A_CI(9,:).*Q(9,:))*((CI(:,:,9).*(partImpCI(:,:,9)))');
(A_CI(10,:).*Q(10,:))*((CI(:,:,10).*(partImpCI(:,:,10)))');
(A_CI(11,:).*Q(11,:))*((CI(:,:,11).*(partImpCI(:,:,11)))');
(A_CI(12,:).*Q(12,:))*((CI(:,:,12).*(partImpCI(:,:,12)))')]+DF.*(partImpDF)+DG.*(partImpDG);

Exp_noDI = marketshare.*(ones(reg,1)*sum(Imp_noDI,"r"));

Q_noDI=QCdom_noDI+Exp_noDI+ExpTI;

EBE = p.*Q.*markup.*(FCC.*energ_sec+non_energ_sec);

taxCI_dom = [
sum((p(1,:)'*ones(1,sec)).*taxCIdom(:,:,1).*partDomCI(:,:,1).*CI(:,:,1).*(ones(sec,1)*(A_CI(1,:).*Q(1,:))), 'c')';
sum((p(2,:)'*ones(1,sec)).*taxCIdom(:,:,2).*partDomCI(:,:,2).*CI(:,:,2).*(ones(sec,1)*(A_CI(2,:).*Q(2,:))), 'c')';
sum((p(3,:)'*ones(1,sec)).*taxCIdom(:,:,3).*partDomCI(:,:,3).*CI(:,:,3).*(ones(sec,1)*(A_CI(3,:).*Q(3,:))), 'c')';
sum((p(4,:)'*ones(1,sec)).*taxCIdom(:,:,4).*partDomCI(:,:,4).*CI(:,:,4).*(ones(sec,1)*(A_CI(4,:).*Q(4,:))), 'c')';
sum((p(5,:)'*ones(1,sec)).*taxCIdom(:,:,5).*partDomCI(:,:,5).*CI(:,:,5).*(ones(sec,1)*(A_CI(5,:).*Q(5,:))), 'c')';
sum((p(6,:)'*ones(1,sec)).*taxCIdom(:,:,6).*partDomCI(:,:,6).*CI(:,:,6).*(ones(sec,1)*(A_CI(6,:).*Q(6,:))), 'c')';
sum((p(7,:)'*ones(1,sec)).*taxCIdom(:,:,7).*partDomCI(:,:,7).*CI(:,:,7).*(ones(sec,1)*(A_CI(7,:).*Q(7,:))), 'c')';
sum((p(8,:)'*ones(1,sec)).*taxCIdom(:,:,8).*partDomCI(:,:,8).*CI(:,:,8).*(ones(sec,1)*(A_CI(8,:).*Q(8,:))), 'c')';
sum((p(9,:)'*ones(1,sec)).*taxCIdom(:,:,9).*partDomCI(:,:,9).*CI(:,:,9).*(ones(sec,1)*(A_CI(9,:).*Q(9,:))), 'c')';
sum((p(10,:)'*ones(1,sec)).*taxCIdom(:,:,10).*partDomCI(:,:,10).*CI(:,:,10).*(ones(sec,1)*(A_CI(10,:).*Q(10,:))), 'c')';
sum((p(11,:)'*ones(1,sec)).*taxCIdom(:,:,11).*partDomCI(:,:,11).*CI(:,:,11).*(ones(sec,1)*(A_CI(11,:).*Q(11,:))), 'c')';
sum((p(12,:)'*ones(1,sec)).*taxCIdom(:,:,12).*partDomCI(:,:,12).*CI(:,:,12).*(ones(sec,1)*(A_CI(12,:).*Q(12,:))), 'c')'];

taxCI_imp = [
sum(((wp.*(1+mtax(1,:))+nit(1,:).*wpTIagg)'*ones(1,sec)).*taxCIimp(:,:,1).*(partImpCI(:,:,1)).*CI(:,:,1).*(ones(sec,1)*(A_CI(1,:).*Q(1,:))), 'c')';
sum(((wp.*(1+mtax(2,:))+nit(2,:).*wpTIagg)'*ones(1,sec)).*taxCIimp(:,:,2).*(partImpCI(:,:,2)).*CI(:,:,2).*(ones(sec,1)*(A_CI(2,:).*Q(2,:))), 'c')';
sum(((wp.*(1+mtax(3,:))+nit(3,:).*wpTIagg)'*ones(1,sec)).*taxCIimp(:,:,3).*(partImpCI(:,:,3)).*CI(:,:,3).*(ones(sec,1)*(A_CI(3,:).*Q(3,:))), 'c')';
sum(((wp.*(1+mtax(4,:))+nit(4,:).*wpTIagg)'*ones(1,sec)).*taxCIimp(:,:,4).*(partImpCI(:,:,4)).*CI(:,:,4).*(ones(sec,1)*(A_CI(4,:).*Q(4,:))), 'c')';
sum(((wp.*(1+mtax(5,:))+nit(5,:).*wpTIagg)'*ones(1,sec)).*taxCIimp(:,:,5).*(partImpCI(:,:,5)).*CI(:,:,5).*(ones(sec,1)*(A_CI(5,:).*Q(5,:))), 'c')';
sum(((wp.*(1+mtax(6,:))+nit(6,:).*wpTIagg)'*ones(1,sec)).*taxCIimp(:,:,6).*(partImpCI(:,:,6)).*CI(:,:,6).*(ones(sec,1)*(A_CI(6,:).*Q(6,:))), 'c')';
sum(((wp.*(1+mtax(7,:))+nit(7,:).*wpTIagg)'*ones(1,sec)).*taxCIimp(:,:,7).*(partImpCI(:,:,7)).*CI(:,:,7).*(ones(sec,1)*(A_CI(7,:).*Q(7,:))), 'c')';
sum(((wp.*(1+mtax(8,:))+nit(8,:).*wpTIagg)'*ones(1,sec)).*taxCIimp(:,:,8).*(partImpCI(:,:,8)).*CI(:,:,8).*(ones(sec,1)*(A_CI(8,:).*Q(8,:))), 'c')';
sum(((wp.*(1+mtax(9,:))+nit(9,:).*wpTIagg)'*ones(1,sec)).*taxCIimp(:,:,9).*(partImpCI(:,:,9)).*CI(:,:,9).*(ones(sec,1)*(A_CI(9,:).*Q(9,:))), 'c')';
sum(((wp.*(1+mtax(10,:))+nit(10,:).*wpTIagg)'*ones(1,sec)).*taxCIimp(:,:,10).*(partImpCI(:,:,10)).*CI(:,:,10).*(ones(sec,1)*(A_CI(10,:).*Q(10,:))), 'c')';
sum(((wp.*(1+mtax(11,:))+nit(11,:).*wpTIagg)'*ones(1,sec)).*taxCIimp(:,:,11).*(partImpCI(:,:,11)).*CI(:,:,11).*(ones(sec,1)*(A_CI(11,:).*Q(11,:))), 'c')';
sum(((wp.*(1+mtax(12,:))+nit(12,:).*wpTIagg)'*ones(1,sec)).*taxCIimp(:,:,12).*(partImpCI(:,:,12)).*CI(:,:,12).*(ones(sec,1)*(A_CI(12,:).*Q(12,:))), 'c')'];

TAXCO2_dom=[(A_CI(1,:).*Q(1,:))*((CI(:,:,1).*partDomCI(:,:,1).*taxCO2_CI(:,:,1).*coef_Q_CO2_CI(:,:,1).*(num(1,1)*ones(sec,sec)))');
(A_CI(2,:).*Q(2,:))*((CI(:,:,2).*partDomCI(:,:,2).*taxCO2_CI(:,:,2).*coef_Q_CO2_CI(:,:,2).*(num(2,1)*ones(sec,sec)))');
(A_CI(3,:).*Q(3,:))*((CI(:,:,3).*partDomCI(:,:,3).*taxCO2_CI(:,:,3).*coef_Q_CO2_CI(:,:,3).*(num(3,1)*ones(sec,sec)))');
(A_CI(4,:).*Q(4,:))*((CI(:,:,4).*partDomCI(:,:,4).*taxCO2_CI(:,:,4).*coef_Q_CO2_CI(:,:,4).*(num(4,1)*ones(sec,sec)))');
(A_CI(5,:).*Q(5,:))*((CI(:,:,5).*partDomCI(:,:,5).*taxCO2_CI(:,:,5).*coef_Q_CO2_CI(:,:,5).*(num(5,1)*ones(sec,sec)))');
(A_CI(6,:).*Q(6,:))*((CI(:,:,6).*partDomCI(:,:,6).*taxCO2_CI(:,:,6).*coef_Q_CO2_CI(:,:,6).*(num(6,1)*ones(sec,sec)))');
(A_CI(7,:).*Q(7,:))*((CI(:,:,7).*partDomCI(:,:,7).*taxCO2_CI(:,:,7).*coef_Q_CO2_CI(:,:,7).*(num(7,1)*ones(sec,sec)))');
(A_CI(8,:).*Q(8,:))*((CI(:,:,8).*partDomCI(:,:,8).*taxCO2_CI(:,:,8).*coef_Q_CO2_CI(:,:,8).*(num(8,1)*ones(sec,sec)))');
(A_CI(9,:).*Q(9,:))*((CI(:,:,9).*partDomCI(:,:,9).*taxCO2_CI(:,:,9).*coef_Q_CO2_CI(:,:,9).*(num(9,1)*ones(sec,sec)))');
(A_CI(10,:).*Q(10,:))*((CI(:,:,10).*partDomCI(:,:,10).*taxCO2_CI(:,:,10).*coef_Q_CO2_CI(:,:,10).*(num(10,1)*ones(sec,sec)))');
(A_CI(11,:).*Q(11,:))*((CI(:,:,11).*partDomCI(:,:,11).*taxCO2_CI(:,:,11).*coef_Q_CO2_CI(:,:,11).*(num(11,1)*ones(sec,sec)))');
(A_CI(12,:).*Q(12,:))*((CI(:,:,12).*partDomCI(:,:,12).*taxCO2_CI(:,:,12).*coef_Q_CO2_CI(:,:,12).*(num(12,1)*ones(sec,sec)))')]+DF.*partDomDF.*taxCO2_DF.*coef_Q_CO2_DF.*num+DG.*partDomDG.*taxCO2_DG.*coef_Q_CO2_DG.*num+DI.*partDomDI.*taxCO2_DI.*coef_Q_CO2_DI.*num;

TAXCO2_imp=[(A_CI(1,:).*Q(1,:))*((CI(:,:,1).*partImpCI(:,:,1).*taxCO2_CI(:,:,1).*coef_Q_CO2_CI(:,:,1).*(num(1,1)*ones(sec,sec)))');
(A_CI(2,:).*Q(2,:))*((CI(:,:,2).*partImpCI(:,:,2).*taxCO2_CI(:,:,2).*coef_Q_CO2_CI(:,:,2).*(num(2,1)*ones(sec,sec)))');
(A_CI(3,:).*Q(3,:))*((CI(:,:,3).*partImpCI(:,:,3).*taxCO2_CI(:,:,3).*coef_Q_CO2_CI(:,:,3).*(num(3,1)*ones(sec,sec)))');
(A_CI(4,:).*Q(4,:))*((CI(:,:,4).*partImpCI(:,:,4).*taxCO2_CI(:,:,4).*coef_Q_CO2_CI(:,:,4).*(num(4,1)*ones(sec,sec)))');
(A_CI(5,:).*Q(5,:))*((CI(:,:,5).*partImpCI(:,:,5).*taxCO2_CI(:,:,5).*coef_Q_CO2_CI(:,:,5).*(num(5,1)*ones(sec,sec)))');
(A_CI(6,:).*Q(6,:))*((CI(:,:,6).*partImpCI(:,:,6).*taxCO2_CI(:,:,6).*coef_Q_CO2_CI(:,:,6).*(num(6,1)*ones(sec,sec)))');
(A_CI(7,:).*Q(7,:))*((CI(:,:,7).*partImpCI(:,:,7).*taxCO2_CI(:,:,7).*coef_Q_CO2_CI(:,:,7).*(num(7,1)*ones(sec,sec)))');
(A_CI(8,:).*Q(8,:))*((CI(:,:,8).*partImpCI(:,:,8).*taxCO2_CI(:,:,8).*coef_Q_CO2_CI(:,:,8).*(num(8,1)*ones(sec,sec)))');
(A_CI(9,:).*Q(9,:))*((CI(:,:,9).*partImpCI(:,:,9).*taxCO2_CI(:,:,9).*coef_Q_CO2_CI(:,:,9).*(num(9,1)*ones(sec,sec)))');
(A_CI(10,:).*Q(10,:))*((CI(:,:,10).*partImpCI(:,:,10).*taxCO2_CI(:,:,10).*coef_Q_CO2_CI(:,:,10).*(num(10,1)*ones(sec,sec)))');
(A_CI(11,:).*Q(11,:))*((CI(:,:,11).*partImpCI(:,:,11).*taxCO2_CI(:,:,11).*coef_Q_CO2_CI(:,:,11).*(num(11,1)*ones(sec,sec)))');
(A_CI(12,:).*Q(12,:))*((CI(:,:,12).*partImpCI(:,:,12).*taxCO2_CI(:,:,12).*coef_Q_CO2_CI(:,:,12).*(num(12,1)*ones(sec,sec)))')]+DF.*partImpDF.*taxCO2_DF.*coef_Q_CO2_DF.*num+DG.*partImpDG.*taxCO2_DG.*coef_Q_CO2_DG.*num+DI.*partImpDI.*taxCO2_DI.*coef_Q_CO2_DI.*num;

TAXCO2=sum(TAXCO2_imp+TAXCO2_dom,'c');
//TAXCO2 = sum(taxCO2.*num.*coef_Q_CO2.*(QCdom+Imp),'c');

TAX_sect = taxCI_dom + taxCI_imp + TAXCO2_imp + TAXCO2_dom + Exp.*p.*xtax+...
    (p.*taxDFdom.*partDomDF+((ones(reg,1)*wp).*(1+mtax)+(ones(reg,sec)*wpTIagg).*nit).*taxDFimp.*(partImpDF)).*DF+...
    (p.*taxDGdom.*partDomDG+((ones(reg,1)*wp).*(1+mtax)+(ones(reg,sec)*wpTIagg).*nit).*taxDGimp.*(partImpDG)).*DG+...
    (p.*taxDIdom.*partDomDI+((ones(reg,1)*wp).*(1+mtax)+(ones(reg,sec)*wpTIagg).*nit).*taxDIimp.*(partImpDI)).*DI+...
    (ones(reg,1)*wp).*mtax.*Imp+...
    DF.*pArmDF.*Ttax./(1+Ttax)+...
    Q.*p.*qtax./(1+qtax)+...
A.*Q.*w.*l.*sigma.*(energ_sec+FCC.*non_energ_sec);

sumtax = sum(TAX_sect,"c");

TAXSAL0 = sum(sigma.*A.*w.*l.*Q.*(energ_sec+FCC.*non_energ_sec),"c");

E_CO2_dom = [(A_CI(1,:).*Q(1,:))*((CI(:,:,1).*partDomCI(:,:,1).*coef_Q_CO2_CI(:,:,1))');
(A_CI(2,:).*Q(2,:))*((CI(:,:,2).*partDomCI(:,:,2).*coef_Q_CO2_CI(:,:,2))');
(A_CI(3,:).*Q(3,:))*((CI(:,:,3).*partDomCI(:,:,3).*coef_Q_CO2_CI(:,:,3))');
(A_CI(4,:).*Q(4,:))*((CI(:,:,4).*partDomCI(:,:,4).*coef_Q_CO2_CI(:,:,4))');
(A_CI(5,:).*Q(5,:))*((CI(:,:,5).*partDomCI(:,:,5).*coef_Q_CO2_CI(:,:,5))');
(A_CI(6,:).*Q(6,:))*((CI(:,:,6).*partDomCI(:,:,6).*coef_Q_CO2_CI(:,:,6))');
(A_CI(7,:).*Q(7,:))*((CI(:,:,7).*partDomCI(:,:,7).*coef_Q_CO2_CI(:,:,7))');
(A_CI(8,:).*Q(8,:))*((CI(:,:,8).*partDomCI(:,:,8).*coef_Q_CO2_CI(:,:,8))');
(A_CI(9,:).*Q(9,:))*((CI(:,:,9).*partDomCI(:,:,9).*coef_Q_CO2_CI(:,:,9))');
(A_CI(10,:).*Q(10,:))*((CI(:,:,10).*partDomCI(:,:,10).*coef_Q_CO2_CI(:,:,10))');
(A_CI(11,:).*Q(11,:))*((CI(:,:,11).*partDomCI(:,:,11).*coef_Q_CO2_CI(:,:,11))');
(A_CI(12,:).*Q(12,:))*((CI(:,:,12).*partDomCI(:,:,12).*coef_Q_CO2_CI(:,:,12))')]+DF.*partDomDF.*coef_Q_CO2_DF+DG.*partDomDG.*coef_Q_CO2_DG+DI.*partDomDI.*coef_Q_CO2_DI;

E_CO2_imp = [(A_CI(1,:).*Q(1,:))*((CI(:,:,1).*(partImpCI(:,:,1).*coef_Q_CO2_CI(:,:,1)))');
(A_CI(2,:).*Q(2,:))*((CI(:,:,2).*(partImpCI(:,:,2).*coef_Q_CO2_CI(:,:,2)))');
(A_CI(3,:).*Q(3,:))*((CI(:,:,3).*(partImpCI(:,:,3).*coef_Q_CO2_CI(:,:,3)))');
(A_CI(4,:).*Q(4,:))*((CI(:,:,4).*(partImpCI(:,:,4).*coef_Q_CO2_CI(:,:,4)))');
(A_CI(5,:).*Q(5,:))*((CI(:,:,5).*(partImpCI(:,:,5).*coef_Q_CO2_CI(:,:,5)))');
(A_CI(6,:).*Q(6,:))*((CI(:,:,6).*(partImpCI(:,:,6).*coef_Q_CO2_CI(:,:,6)))');
(A_CI(7,:).*Q(7,:))*((CI(:,:,7).*(partImpCI(:,:,7).*coef_Q_CO2_CI(:,:,7)))');
(A_CI(8,:).*Q(8,:))*((CI(:,:,8).*(partImpCI(:,:,8).*coef_Q_CO2_CI(:,:,8)))');
(A_CI(9,:).*Q(9,:))*((CI(:,:,9).*(partImpCI(:,:,9).*coef_Q_CO2_CI(:,:,9)))');
(A_CI(10,:).*Q(10,:))*((CI(:,:,10).*(partImpCI(:,:,10)).*coef_Q_CO2_CI(:,:,10))');
(A_CI(11,:).*Q(11,:))*((CI(:,:,11).*(partImpCI(:,:,11)).*coef_Q_CO2_CI(:,:,11))');
(A_CI(12,:).*Q(12,:))*((CI(:,:,12).*(partImpCI(:,:,12)).*coef_Q_CO2_CI(:,:,12))')]+DF.*(partImpDF).*coef_Q_CO2_DF+DG.*(partImpDG).*coef_Q_CO2_DG+DI.*(partImpDI).*coef_Q_CO2_DI;

E_CO2 = E_CO2_dom+E_CO2_imp;
//E_CO2 = (QCdom+Imp).*coef_Q_CO2;
E_CO2_tot = sum(E_CO2);
E_C_tot = E_CO2_tot*12/44;

E_CO2_wo_CCS=E_CO2;

Qcum_oil = zeros(reg,1);
Qcum_gas = zeros(reg,1);


/////
pK = ones(reg,sec);
for k = 1:reg,  
    pK(k,:)  =  pArmDI(k,:)*Beta(:,:,k);
end
Kval = pK.*K; // Value of installed K
rsec = (markup.*p./pK).*(charge/0.8); //Average return on capital, considering that the value of installed capital is not that of K but that of K*0.8.
rreg = sum(rsec.*EBE./(sum(EBE,'c')*ones(1,sec)),'c'); // Average regional return on capital.
rw = sum(EBE)/sum(Kval); //  Global average return on capital
partImpK = ((rreg.*bImpK).^etaImpK)./sum((rreg.*bImpK).^etaImpK); //'logit' update of partImpK to reflect the update of regional average return rates. very low impact
partInvFin = (((rsec./rsecref).*bInvFin).^(etaInvFin*ones(1,sec)))./(sum(((rsec./rsecref).*bInvFin).^(etaInvFin*ones(1,sec)),"c")*ones(1,sec));

price_index=(sum(pArmDF.*DF,'c')./sum(pArmDFref.*DF,'c').*sum(pArmDF.*DFref,'c')./sum(pArmDFref.*DFref,'c')).^(1/2);
VA=A.*w.*l.*Q.*(energ_sec+FCC.*non_energ_sec)+EBE;
Z = 1-sum(A.*l.*Q,'c')./L;



// === GDP computation === //

// There are 2 GDP bases:
// - model own calibration GDP: which stems from the monetary values for hybridization
//       * GDP               (base: GDP_ref)    which is nominal MER
// - exogenous reference   GDP: to abide by a prescribed reference GDP (in calibration.gdp.sce)
//       * GDP_MER_nominal   (base: referenceExoGDP_MER)
//       * GDP_MER_real      (base: referenceExoGDP_MER)
//       * GDP_PPP_constant  (base: referenceExoGDP_PPP)

GDP = sum(VA,"c")+sumtax-sum(DF.*pArmDF.*Ttax./(1+Ttax),'c'); // From model own calibration GDP
GDP_sect = VA + TAX_sect - DF.*pArmDF.*Ttax./(1+Ttax);
GDP_ref     = GDP;      // Because it is the reference year !         // From model own calibration GDP
GrowthNominalMER = GDP ./ GDP_ref; // Growth multiplier nominal GDP MER

PPP_factors = GDP_ref./GDP_PPP_WB; // Price level ratio of PPP conversion factor (GDP) to market exchange rate (2014)

fisherQuantityIndex = 1;
chainedFisherQIndex_prev  = 1;
chainedFisherQIndex = chainedFisherQIndex_prev .* fisherQuantityIndex;
GrowthRealMER = chainedFisherQIndex; //Growth multiplier real GDP MER

GDP_MER_nominal  = GrowthNominalMER .* GDP_ref; // From calibration.gdp.sce base GDP (exogenous)
GDP_MER_real     = GrowthRealMER    .* GDP_ref; // From calibration.gdp.sce base GDP (exogenous)
GDP_PPP_constant = GDP_MER_real     ./ PPP_factors; 
GDP_PPP_constant_ref = GDP_PPP_constant;
GPP_secMER_real = (GDP_MER_real*ones(1,sec)) .* ( GDP_sect ./ (sum(GDP_sect, "c")*ones(1,sec)));
GDP_secPPP_constant = (GDP_PPP_constant*ones(1,sec)) .* ( GDP_sect ./ (sum(GDP_sect, "c")*ones(1,sec)));

// === GDP computation end === //


//residentiel //TODO: check again if the line below can indeed be removed
//deltastockbatiment = deltastockbatimentref.*(QCdom(:,indice_construction)./QCdomref(:,indice_construction));

//transport
//deltastockautomobile = deltastockautomobileref.*(DF(:,indice_composite)./DFref(:,indice_composite));
//infrastructures
//deltastockinfra = stockinfra.*depreciationinfra+1.01*stockinfra;
//deltastockinfra = deltastockinfraref.*sum(DIinfra,'c')./sum(DIinfraref,'c');

// ////////////////////////////////////////////////////////////init values electric sector
// current_time_im=1;
// Life_time_max = max(Life_time(:,:,1));
// CRF = disc_rate_elec(:,:,1)./(1-(1+disc_rate_elec(:,:,1)).^(-Life_time(:,:,1)));
// CINV = CRF(:,:,1).*CINV_MW(:,:,1);
// for k = 1:reg
// 	priceCoalElec(k,1+nb_year_expect) = pArmCI(indice_coal,indice_elec,k);
// 	priceGazElec(k,1+nb_year_expect) = pArmCI(indice_gas,indice_elec,k);
// 	priceEtElec(k,1+nb_year_expect) = pArmCI(indice_Et,indice_elec,k);
// end

// for k = 1:reg
// 	tendance_Coal(k) = ((pArmCI(indice_coal,indice_elec,k)/priceCoalElec(k,1)).^(1/nb_year_expect))-1;
// 	tendance_Gaz(k)  = ((pArmCI(indice_gas ,indice_elec,k)/priceGazElec(k,1) ).^(1/nb_year_expect))-1;
// 	tendance_Et(k)   = ((pArmCI(indice_Et  ,indice_elec,k)/priceEtElec(k,1)  ).^(1/nb_year_expect))-1;
// end

// pArmCI_no_taxCO2=zeros(sec,sec,reg);
// for k=1:reg
// 	pArmCI_no_taxCO2(1:nbsecteurenergie,:,k)=(pArmCI(1:nbsecteurenergie,:,k)-(taxCO2_CI(1:nbsecteurenergie,:,k).*coef_Q_CO2_CI(1:nbsecteurenergie,:,k)).*(num(k,1:nbsecteurenergie)'*ones(1,sec)));
// end

// //prices are expected over the long-run (current_time_im,current_time_im+Life_time_max) and are saved in this vector
// pArmCI_anticip_taxCO2=zeros(sec*sec*reg,Life_time_max+1);
// croyance_taxe=ones(reg,1);

// for j=1:Life_time_max
// 	j_tax=min(current_time_im+j,TimeHorizon);
// 	pArmCIantTxCO2_temp=zeros(sec,sec,reg);
// 	taxVAL_temp=TAXVAL_Poles(:,j_tax);
// 	for k=1:reg
// 		taxCO2_CI_temp=(taxVAL_temp(k)*1e-6)*ones(sec,sec);
// 		coef_Q_CO2_CI_temp=coef_Q_CO2_CI(1:nbsecteurenergie,:,k);
// 		//specific traitment for sequestration
// 		coef_Q_CO2_CI_temp(indice_coal,indice_elec)=coef_Q_CO2_CIref(indice_coal,indice_elec,k);
// 		pArmCIantTxCO2_temp(1:nbsecteurenergie,:,k)=(pArmCI(1:nbsecteurenergie,:,k)+(croyance_taxe(k)*(taxCO2_CI_temp(1:nbsecteurenergie,:)-taxCO2_CI(1:nbsecteurenergie,:,k)).*coef_Q_CO2_CI_temp(1:nbsecteurenergie,:)).*(num(k,1:nbsecteurenergie)'*ones(1,sec)));
// 	end
// 	pArmCI_anticip_taxCO2(:,j)=matrix(pArmCIantTxCO2_temp,sec*sec*reg,1);
// end
// 	
// ///////////////////////// price expectations based the expected / belief in future carbon price
// p_Coal_anticip_CCS=zeros(reg,Life_time_max);
// p_Gaz_anticip_CCS=zeros(reg,Life_time_max);

// for k=1:reg
// 	for j=1:Life_time_max
// 		pArmCIantTxCO2_temp=matrix(pArmCI_anticip_taxCO2(:,j),sec,sec,reg);
// 		p_Coal_anticip(k,j)=pArmCIantTxCO2_temp(indice_coal,indice_elec,k)/11630;
// 		p_Gaz_anticip(k,j)=pArmCIantTxCO2_temp(indice_gas,indice_elec,k)/11630;
// 		p_Et_anticip(k,j)=pArmCIantTxCO2_temp(indice_Et,indice_elec,k)/11630;
// 		p_Coal_anticip_CCS(k,j)=pArmCI_no_taxCO2(indice_coal,indice_elec,k)/11630;
// 		p_Gaz_anticip_CCS(k,j)=pArmCI_no_taxCO2(indice_gas,indice_elec,k)/11630;
// 	end
// end


// for k=1:reg
// 	for j=technoElecCoal
// 		CFuel(k,j)=(sum(p_Coal_anticip(k,1:Life_time(k,j,current_time_im)))/Life_time(k,j,current_time_im))/rho_elec(k,j,current_time_im);
// 	end
// 	for j=technoElecGas 
// 		CFuel(k,j)=(sum(p_Gaz_anticip(k,1:Life_time(k,j,current_time_im)))/Life_time(k,j,current_time_im))/rho_elec(k,j,current_time_im);
// 	end
// 	for j=technoCoal+technoGas+1:technoFF
// 		CFuel(k,j)=(sum(p_Et_anticip(k,1:Life_time(k,j,current_time_im)))/Life_time(k,j,current_time_im))/rho_elec(k,j,current_time_im);
// 	end
// 	for j=technoFF+1:techno_elec
// 		CFuel(k,j)=0;
// 	end
// ///////////////////////////////////// specific case for sequestration, for which the fossil fuel price
// ///////////////////////////////////// should not face the CO2 tax
// 	j=indice_PSS;
// 	CFuel(k,j)=(sum(p_Coal_anticip_CCS(k,1:Life_time(k,j,current_time_im)))/Life_time(k,j,current_time_im))/rho_elec(k,j,current_time_im);
// 	j=indice_CGS;
// 	CFuel(k,j)=(sum(p_Coal_anticip_CCS(k,1:Life_time(k,j,current_time_im)))/Life_time(k,j,current_time_im))/rho_elec(k,j,current_time_im);
// 	j=indice_GGS;
// 	CFuel(k,j)=(sum(p_Gaz_anticip_CCS(k,1:Life_time(k,j,current_time_im)))/Life_time(k,j,current_time_im))/rho_elec(k,j,current_time_im);
// end


// LCC_730 =  (CINV+OM_cost_fixed(:,:,1))/730 +CFuel+OM_cost_var(:,:,1);
// LCC_2190 = (CINV+OM_cost_fixed(:,:,1))/2190+CFuel+OM_cost_var(:,:,1);
// LCC_3650 = (CINV+OM_cost_fixed(:,:,1))/3650+CFuel+OM_cost_var(:,:,1);
// LCC_5110 = (CINV+OM_cost_fixed(:,:,1))/5110+CFuel+OM_cost_var(:,:,1);
// LCC_6570 = (CINV+OM_cost_fixed(:,:,1))/6570+CFuel+OM_cost_var(:,:,1);
// LCC_8030 = (CINV+OM_cost_fixed(:,:,1))/8030+CFuel+OM_cost_var(:,:,1);
// LCC_8760 = (CINV+OM_cost_fixed(:,:,1))/8760+CFuel+OM_cost_var(:,:,1);


share_ENR_prod_elec = zeros(reg,1);
share_NUC_prod_elec = zeros(reg,1);
share_HYD_prod_elec = zeros(reg,1);

//////////////////// energy balances
energy_balance=zeros(indice_matEner,8,reg);
for k=1:reg
    energy_balance(:,:,k)=matrix(bilan_energetique(CI,Q,DF,Imp,Exp,k),indice_matEner,8);
    TPES(k)=sum(energy_balance(5,:,k));
    TFC(k) =sum(energy_balance(9,:,k));
end
energy_balance_stock=matrix(energy_balance,reg*indice_matEner*8,1);
Energy_balance_temp=energy_balance;

///////////////////// For nexus.cars.sce
GDP_MER_real_prev = GDP_MER_real;
Ltot_prev_stock=Ltot0;

E_reg_use_ref=emissions_usage(CI,Q,DF,DI);
E_reg_use=E_reg_use_ref;
Ener_reg_use = energie_usage(CI,Q,DF,DI,DG);
Tair=tair(Conso);
TOT=tOT(Conso);

markup_stock=markup.*FCCmarkup_oil;

progestechl=l./lref;
Lact=L;


if max(abs((QCdom+Exp+ExpTI)./Q-1))>20*sensibility then 
    warning	( "in Extraction generic: ")
    say "max(abs((QCdom+Exp+ExpTI)./Q-1))"
end

pArmCI_prev_prev_prev = pArmCI;
pArmCI_prev_prev      = pArmCI;
pArmCI_prev           = pArmCI;
pArmDF_prev_prev_prev = pArmDF;
pArmDF_prev_prev      = pArmDF;
pArmDF_prev           = pArmDF;
wp_oil_prev           = wp(oil);
DF_prev_prev          = DF;
DF_prev               = DF;
pArmDG_prev           = pArmDG;
pArmDI_prev           = pArmDI;
p_prev				  = p;
wp_prev               = wp;
DG_prev               = DG;
DI_prev               = DI;
Exp_prev              = Exp;
Imp_prev              = Imp;

pArmCI_no_taxCO2=zeros(sec,sec,reg);
pArmCI_w_CCS_indus=zeros(sec,sec,reg);
pArmCI_wo_CCS_indu=zeros(sec,sec,reg);
for k=1:reg
    pArmCI_no_taxCO2(1:nbsecteurenergie,:,k)=(pArmCI(1:nbsecteurenergie,:,k)-(taxCO2_CI(1:nbsecteurenergie,:,k).*coef_Q_CO2_CI(1:nbsecteurenergie,:,k)).*(num(k,1:nbsecteurenergie)'*ones(1,sec)));
    pArmCI_w_CCS_indus(1:nbsecteurenergie,:,k)=(pArmCI(1:nbsecteurenergie,:,k)-(taxCO2_CI(1:nbsecteurenergie,:,k).* (coef_Q_CO2_CI(1:nbsecteurenergie,:,k)+(1-CCS_efficiency_industry) * coef_Q_CO2_CI_wo_CCS(1:nbsecteurenergie,:,k))).*(num(k,1:nbsecteurenergie)'*ones(1,sec)));
    pArmCI_wo_CCS_indu(1:nbsecteurenergie,:,k)=(pArmCI(1:nbsecteurenergie,:,k)-(taxCO2_CI(1:nbsecteurenergie,:,k).* (coef_Q_CO2_CI(1:nbsecteurenergie,:,k)+ coef_Q_CO2_CI_wo_CCS(1:nbsecteurenergie,:,k))).*(num(k,1:nbsecteurenergie)'*ones(1,sec)));
end
pArmCI_w_CCS_indus_p=pArmCI_w_CCS_indus;
pArmCI_w_CCS_indus_p_p=pArmCI_w_CCS_indus;
pArmCI_w_CCS_indus_p_p_p=pArmCI_w_CCS_indus;
pArmCI_wo_CCS_indu_p=pArmCI_wo_CCS_indu;
pArmCI_wo_CCS_indu_p_p=pArmCI_wo_CCS_indu;
pArmCI_wo_CCS_indu_p_p_p=pArmCI_wo_CCS_indu;


if ind_NLU >=1
    Q_biofuel_real = share_biofuel .* Q(:,indice_Et);
end

pImp = (ones(reg,1)*wp).*(1+mtax)+(ones(reg,sec)*wpTIagg).*nit;
pImp_notax = (ones(reg,1)*wp)+(ones(reg,sec)*wpTIagg).*nit;

if ind_lindhal >=1
    weight_regional_tax_prev = weight_regional_tax;
    weight_regional_tax = (GDP_PPP_constant ./ Ltot) ;
    weight_regional_tax = weight_regional_tax ./ weight_regional_tax(ind_usa);
end
