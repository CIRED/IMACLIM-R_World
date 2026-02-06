// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Ruben Bibas, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


[Conso ,Tautomobile ,lambda ,mu ,p ,w ,Q ,Rdisp ,TNM ,wpEner] = expand_equilibrium(equilibrium);
// say "taxCO2_DF"
taxCO2_CI_prev  =taxCO2_CI;
taxCO2_DF_prev  =taxCO2_DF;
taxCO2_DG_prev  =taxCO2_DG;
taxCO2_DI_prev  =taxCO2_DI;

[taxCO2_DF, taxCO2_DG, taxCO2_DI, taxCO2_CI, taxMKT]=expand_tax(equilibrium,taxCO2_DF, taxCO2_DG, taxCO2_DI, taxCO2_CI, taxMKT, weight_regional_tax);

//normalisation by the numeraire
num0=p(1,indice_composite)*ones(reg,sec);
num=p(1,indice_composite);
p=p./num;
w=w./num;
Rdisp=Rdisp./num;
wpEner=wpEner./num;

/////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

for k = 1:reg,
    if (Rdisp(k)<=0) then Rdisp(k) = 0.00001; end
    if (Tautomobile(k)<=bnautomobile(k)) then Tautomobile(k) = bnautomobile(k)+0.0000001; end
    if (TNM(k)<=bnNM(k)) then TNM(k) = bnNM(k)+0.0000001; end
    for j = 1:sec,
        if (Q(k,j)<=0) then Q(k,j) = 0.00001; end
        if (w(k,j)<=0) then  w(k,j) = 0.0000001; end  
        if (p(k,j)<=0) then  p(k,j) = 0.0000001; end
    end
    //sectors but transport
    for j = [1,2,6,7]
        if (Conso(k,j)<=bn(k,j+5)) then Conso(k,j) = bn(k,j+5)+0.00001;end
    end
    //air transport
    if (Conso(k,indice_air-5)<=0) then Conso(k,indice_air-5) = 0+0.00001; end
    //sea transport
    if (Conso(k,indice_mer-5)<=0) then Conso(k,indice_mer-5) = bn(k,indice_mer)+0.00001; end
    //Other transport
    if (Conso(k,indice_OT-5)<=0) then Conso(k,indice_OT-5) = bnOT(k)+0.00001; end
end

// world energy prices
for j = 1:5,
    if (wpEner(j)<=0) then  wpEner(j) = 0.000001;  end
end
//

DF = DFinduite(Conso,Tautomobile);
Z=ones(reg,1);
Z = 1-sum(A.*l.*Q,'c')./L;
num=p(1,indice_composite)*ones(reg,sec);
//num = p(:,indice_composite)*ones(1,sec);
wp=zeros(1,sec);

charge =   A.*Q./Cap; 

FCC = aRD+bRD.*tanh(cRD.*(A.*Q./Cap-1));
FCCmarkup = ((1/0.8).*(A.*Q./Cap)); 
FCCmarkup=((markup_lim_oil-markupref)/(1-0.8).*(A.*Q./Cap-0.8*ones(reg,sec))+markupref)./markup;

FCCmarkup_oil=ones(reg,sec);
FCCmarkup_oil(:,2)=FCCmarkup(:,2);
//////////// non energy sectors

wp(:,sec-nb_secteur_conso+1:sec) = sum((weight.^(ones(reg,1)*eta)).*((p(:,sec-nb_secteur_conso+1:sec).*(1+xtax(:,sec-nb_secteur_conso+1:sec))).^(1-ones(reg,1)*eta)),"r").^(ones(1,nb_secteur_conso)./(1-eta));
wpTI = sum((weightTI.^(ones(reg,nb_trans)*etaTI).*(p(:,indice_transport_1:indice_transport_2).^(1-ones(reg,nb_trans)*etaTI))),'r').^(1 ./(1-etaTI));
wpTIagg = sum(wpTI.*partTIref);

//this column is usefull when calling from a puase. See http://wiki.scilab.org/howto/global_and_local_variables
pArmDF   ;
pArmDG   ;
pArmDI   ;
partDomDF;
partImpDF;
partDomDG;
partImpDG;
partDomDI;
partImpDI;


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

marketshare;//this is usefull when calling from a pause. See http://wiki.scilab.org/howto/global_and_local_variables

marketshare(:,sec-nb_secteur_conso+1:sec) = (weight.^(ones(reg,1)*eta)).*(((p(:,sec-nb_secteur_conso+1:sec).*(1+xtax(:,sec-nb_secteur_conso+1:sec))).^(ones(reg,1)*(1-eta)))./(ones(reg,1)*sum((weight.^(ones(reg,1)*eta)).*((p(:,sec-nb_secteur_conso+1:sec).*(1+xtax(:,sec-nb_secteur_conso+1:sec))).^(1-ones(reg,1)*eta)),"r"))).^(ones(reg,1)*(eta./(eta-1)));
marketshareTI = (weightTI.^(ones(reg,nb_trans)*etaTI)).*((p(:,indice_transport_1:indice_transport_2).^(1-ones(reg,nb_trans)*etaTI))./(ones(reg,1)*sum((weightTI.^(ones(reg,nb_trans)*etaTI)).*(p(:,indice_transport_1:indice_transport_2).^(1-ones(reg,nb_trans)*etaTI)),"r"))).^(ones(reg,nb_trans)*(etaTI./(etaTI-1)));

//////////// energy sectors

partDomDF(:,1:nbsecteurenergie)=((p(:,1:nbsecteurenergie).*(1+taxDFdom(:,1:nbsecteurenergie)))+itgbl_cost_DFdom.*p(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDF./(((p(:,1:nbsecteurenergie).*(1+taxDFdom(:,1:nbsecteurenergie)))+itgbl_cost_DFdom.*p(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDF+(((ones(reg,1)*wpEner).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDFimp(:,1:nbsecteurenergie))+itgbl_cost_DFimp.*(ones(reg,1)*(wpEner./wpEnerref))).^alpha_partDF);
partDomDG(:,1:nbsecteurenergie)=((p(:,1:nbsecteurenergie).*(1+taxDGdom(:,1:nbsecteurenergie)))+itgbl_cost_DGdom.*p(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDG./(((p(:,1:nbsecteurenergie).*(1+taxDGdom(:,1:nbsecteurenergie)))+itgbl_cost_DGdom.*p(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDG+(((ones(reg,1)*wpEner).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDGimp(:,1:nbsecteurenergie))+itgbl_cost_DGimp.*(ones(reg,1)*(wpEner./wpEnerref))).^alpha_partDG);
partDomDI(:,1:nbsecteurenergie)=((p(:,1:nbsecteurenergie).*(1+taxDIdom(:,1:nbsecteurenergie)))+itgbl_cost_DIdom.*p(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDI./(((p(:,1:nbsecteurenergie).*(1+taxDIdom(:,1:nbsecteurenergie)))+itgbl_cost_DIdom.*p(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDI+(((ones(reg,1)*wpEner).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDIimp(:,1:nbsecteurenergie))+itgbl_cost_DIimp.*(ones(reg,1)*(wpEner./wpEnerref))).^alpha_partDI);
partDomDF(:,indice_elec) = partDomDFref(:,indice_elec);
partDomDG(:,indice_elec) = partDomDGref(:,indice_elec);
partDomDI(:,indice_elec) = partDomDIref(:,indice_elec);
// partDomDF(:,indice_Et)=partDomDFref(:,indice_Et);
// partDomDG(:,indice_Et)=partDomDGref(:,indice_Et);
// partDomDI(:,indice_Et)=partDomDIref(:,indice_Et);

//specific case for oil: region with high load rate do not consume their own production
mult_oil=max(0.000001,a4_mult_oil.*min(charge(:,indice_oil),0.999).^4+ a3_mult_oil.*min(charge(:,indice_oil),0.999).^3 +a2_mult_oil.*min(charge(:,indice_oil),0.999).^2+ a1_mult_oil.*min(charge(:,indice_oil),0.999)+a0_mult_oil);
// for k=1:reg
// if charge(k,indice_oil)>1 then mult_oil(k)=0; end
// end

mult_gaz=max(0.000001,a4_mult_gaz.*min(charge(:,indice_gas),0.999).^4+ a3_mult_gaz.*min(charge(:,indice_gas),0.999).^3 +a2_mult_gaz.*min(charge(:,indice_gas),0.999).^2+ a1_mult_gaz.*min(charge(:,indice_gas),0.999)+a0_mult_gaz);
// for k=1:reg
// if charge(k,indice_gas)>1 then mult_gaz(k)=0; end
// end

mult_coal=max(0.000001,a4_mult_coal.*min(charge(:,indice_coal),0.999).^4+ a3_mult_coal.*min(charge(:,indice_coal),0.999).^3 +a2_mult_coal.*min(charge(:,indice_coal),0.999).^2+ a1_mult_coal.*min(charge(:,indice_coal),0.999)+a0_mult_coal);
// for k=1:reg
// if charge(k,indice_coal)>1 then mult_coal(k)=0; end
// end

for k=1:reg
    if mult_coal(k)<1 then 
        partDomDF(k,indice_coal)=partDomDF(k,indice_coal).*mult_coal(k);
        partDomDG(k,indice_coal)=partDomDG(k,indice_coal).*mult_coal(k);
        partDomDI(k,indice_coal)=partDomDI(k,indice_coal).*mult_coal(k);
    end
end

for k=1:reg
    if mult_coal(k)<0 then 
        partDomDF(k,indice_coal)=0;
        partDomDG(k,indice_coal)=0;
        partDomDI(k,indice_coal)=0;
    end
end

for k=1:reg
    if mult_gaz(k)<1 then 
        partDomDF(k,indice_gas)=partDomDF(k,indice_gas).*mult_gaz(k);
        partDomDG(k,indice_gas)=partDomDG(k,indice_gas).*mult_gaz(k);
        partDomDI(k,indice_gas)=partDomDI(k,indice_gas).*mult_gaz(k);
    end
end

for k=1:reg
    if mult_gaz(k)<0 then 
        partDomDF(k,indice_gas)=0;
        partDomDG(k,indice_gas)=0;
        partDomDI(k,indice_gas)=0;
    end
end

for k=1:reg
    if mult_oil(k)<1 then 
        partDomDF(k,indice_oil)=partDomDF(k,indice_oil).*mult_oil(k);
        partDomDG(k,indice_oil)=partDomDG(k,indice_oil).*mult_oil(k);
        partDomDI(k,indice_oil)=partDomDI(k,indice_oil).*mult_oil(k);
    end
end

for k=1:reg
    if mult_oil(k)<0 then 
        partDomDF(k,indice_oil)=0;
        partDomDG(k,indice_oil)=0;
        partDomDI(k,indice_oil)=0;
    end
end

partDomDF(:,1:nbsecteurenergie)=partDomDF(:,1:nbsecteurenergie)*inertia_share+partDomDF_stock(:,1:nbsecteurenergie)*(1-inertia_share);
partDomDG(:,1:nbsecteurenergie)=partDomDG(:,1:nbsecteurenergie)*inertia_share+partDomDG_stock(:,1:nbsecteurenergie)*(1-inertia_share);
partDomDI(:,1:nbsecteurenergie)=partDomDI(:,1:nbsecteurenergie)*inertia_share+partDomDI_stock(:,1:nbsecteurenergie)*(1-inertia_share);

// Sovereignty policies
partDomDF(:,1:nbsecteurenergie)=max(partDomDF_min(:,1:nbsecteurenergie),partDomDF(:,1:nbsecteurenergie));
//partDomDG(:,1:nbsecteurenergie)=max(partDomDG_min(:,1:nbsecteurenergie),partDomDG(:,1:nbsecteurenergie)); inutile car = à 0
//partDomDI(:,1:nbsecteurenergie)=max(partDomDI_min(:,1:nbsecteurenergie),partDomDI(:,1:nbsecteurenergie)); inutile car = à 0
partImpDF(:,1:nbsecteurenergie) = 1-partDomDF(:,1:nbsecteurenergie);
partImpDG(:,1:nbsecteurenergie) = 1-partDomDG(:,1:nbsecteurenergie);
partImpDI(:,1:nbsecteurenergie) = 1-partDomDI(:,1:nbsecteurenergie);



for k = 1:reg,
    partDomCI(1:nbsecteurenergie,:,k)=(((p(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k)))+itgbl_cost_CIdom(:,:,k).*((p(k,1:nbsecteurenergie)./pref(k,1:nbsecteurenergie))'*ones(1,sec))).^alpha_partCI(:,:,k)./((((p(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k)))+itgbl_cost_CIdom(:,:,k).*((p(k,1:nbsecteurenergie)./pref(k,1:nbsecteurenergie))'*ones(1,sec))).^alpha_partCI(:,:,k)+((((wpEner(1:nbsecteurenergie).*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIagg)'*ones(1,sec)).*(1+taxCIimp(1:nbsecteurenergie,:,k)))+itgbl_cost_CIimp(:,:,k).*((wpEner./wpEnerref)'*ones(1,sec))).^alpha_partCI(:,:,k));
    partDomCI(indice_elec,:,k) = partDomCIref(indice_elec,:,k);
    partDomCI(indice_Et,:,k)=partDomCIref(indice_Et,:,k);

    if mult_oil(k)<1 then
        for j=1:sec
            partDomCI(indice_oil,j,k)=mult_oil(k)*partDomCI(indice_oil,j,k);
        end
    end
    if mult_oil(k)<0 then
        for j=1:sec
            partDomCI(indice_oil,j,k)=0;
        end
    end

    if mult_gaz(k)<1 then
        for j=1:sec
            partDomCI(indice_gas,j,k)=mult_gaz(k)*partDomCI(indice_gas,j,k);
        end
    end
    if mult_gaz(k)<0 then
        for j=1:sec
            partDomCI(indice_gas,j,k)=0;
        end
    end

    if mult_coal(k)<1 then
        for j=1:sec
            partDomCI(indice_coal,j,k)=mult_coal(k)*partDomCI(indice_coal,j,k);
        end
    end
    if mult_coal(k)<0 then
        for j=1:sec
            partDomCI(indice_coal,j,k)=0;
        end
    end

    partDomCI(1:nbsecteurenergie,:,k)=partDomCI(1:nbsecteurenergie,:,k)*inertia_share+partDomCI_stock(1:nbsecteurenergie,:,k)*(1-inertia_share);
    partImpCI(1:nbsecteurenergie,:,k) = 1-partDomCI(1:nbsecteurenergie,:,k);

    partDomCI(1:nbsecteurenergie,:,k)=partDomCI(1:nbsecteurenergie,:,k)*inertia_share+partDomCI_stock(1:nbsecteurenergie,:,k)*(1-inertia_share);
    // Sovereignty policies
    partDomCI(1:nbsecteurenergie,:,k) = max(partDomCI_min(1:nbsecteurenergie,:,k), partDomCI(1:nbsecteurenergie,:,k));
    partImpCI(1:nbsecteurenergie,:,k)=1-partDomCI(1:nbsecteurenergie,:,k);

end

marketshare(:,1:nbsecteurenergie) = bmarketshareener.*((p(:,1:nbsecteurenergie).*(1+xtax(:,1:nbsecteurenergie))./(p_stock(:,1:nbsecteurenergie).*(1+xtaxref(:,1:nbsecteurenergie)))).^(ones(reg,1)*etamarketshareener))./(ones(reg,1)*sum(bmarketshareener.*((p(:,1:nbsecteurenergie).*(1+xtax(:,1:nbsecteurenergie))./(p_stock(:,1:nbsecteurenergie).*(1+xtaxref(:,1:nbsecteurenergie)))).^(ones(reg,1)*etamarketshareener)),'r'));
if new_Et_msh_computation ==1
    marketshare(:,4) = weightEt_new .* (( taxCO2_DF(:,4).* new_Et_msh_computation .* coef_Q_CO2_Et_prod .* num(:,4)+ p(:,indice_Et).*(1+xtax(:,indice_Et)) ) .^ etaEtnew) ./ sum( weightEt_new .* (( taxCO2_DF(:,4).* new_Et_msh_computation .* coef_Q_CO2_Et_prod .* num(:,4)+p(:,indice_Et).*(1+xtax(:,indice_Et))) .^ etaEtnew));
end

//specific case for oil: no export with a high load rate
for k=1:reg
    if mult_gaz(k)<1 then 
        marketshare(k,indice_gas)=marketshare(k,indice_gas).*mult_gaz(k);
    end
end
for k=1:reg
    if marketshare(k,indice_gas)<0.00000001 then 
        marketshare(k,indice_gas)=0.00000001;
    end
end
marketshare(:,indice_gas)=marketshare(:,indice_gas)/(sum(marketshare(:,indice_gas),'r'));

for k=1:reg
    if mult_oil(k)<1 then 
        marketshare(k,indice_oil)=marketshare(k,indice_oil).*mult_oil(k);
    end
end
for k=1:reg
    if marketshare(k,indice_oil)<0.00000001 then 
        marketshare(k,indice_oil)=0.00000001;
    end
end
marketshare(:,indice_oil)=marketshare(:,indice_oil)/(sum(marketshare(:,indice_oil),'r'));

for k=1:reg
    if mult_coal(k)<1 then 
        marketshare(k,indice_coal)=marketshare(k,indice_coal).*mult_coal(k);
    end
end
for k=1:reg
    if marketshare(k,indice_coal)<0.00000001 then 
        marketshare(k,indice_coal)=0.00000001;
    end
end
marketshare(:,indice_coal)=marketshare(:,indice_coal)/(sum(marketshare(:,indice_coal),'r'));

wp(:,1:nbsecteurenergie) = wpEner;

pArmDF(:,1:nbsecteurenergie)=(p(:,1:nbsecteurenergie).*(1+taxDFdom(:,1:nbsecteurenergie))).*(1-partImpDF(:,1:nbsecteurenergie))+(((ones(reg,1)*wpEner).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDFimp(:,1:nbsecteurenergie))).*partImpDF(:,1:nbsecteurenergie)+taxCO2_DF(:,1:nbsecteurenergie).*coef_Q_CO2_DF(:,1:nbsecteurenergie).*num(:,1:nbsecteurenergie);
pArmDG(:,1:nbsecteurenergie)=(p(:,1:nbsecteurenergie).*(1+taxDGdom(:,1:nbsecteurenergie))).*(1-partImpDG(:,1:nbsecteurenergie))+(((ones(reg,1)*wpEner).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDGimp(:,1:nbsecteurenergie))).*partImpDG(:,1:nbsecteurenergie)+taxCO2_DG(:,1:nbsecteurenergie).*coef_Q_CO2_DG(:,1:nbsecteurenergie).*num(:,1:nbsecteurenergie);
pArmDI(:,1:nbsecteurenergie)=(p(:,1:nbsecteurenergie).*(1+taxDIdom(:,1:nbsecteurenergie))).*(1-partImpDI(:,1:nbsecteurenergie))+(((ones(reg,1)*wpEner).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDIimp(:,1:nbsecteurenergie))).*partImpDI(:,1:nbsecteurenergie)+taxCO2_DI(:,1:nbsecteurenergie).*coef_Q_CO2_DI(:,1:nbsecteurenergie).*num(:,1:nbsecteurenergie);
for k=1:reg,
    pArmCI(1:nbsecteurenergie,:,k)=((p(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k))).*(1-partImpCI(1:nbsecteurenergie,:,k))+(((wpEner.*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIagg)'*ones(1,sec)).*(1+taxCIimp(1:nbsecteurenergie,:,k))).*partImpCI(1:nbsecteurenergie,:,k)+(taxCO2_CI(1:nbsecteurenergie,:,k).*coef_Q_CO2_CI(1:nbsecteurenergie,:,k)).*(num(k,1:nbsecteurenergie)'*ones(1,sec));
end

pArmDF = pArmDF.*(1+Ttax);

/////////// consumer price index
pind=(sum(pArmDF.*DF,'c')./sum(pArmDFref.*DF,'c').*sum(pArmDF.*DFref,'c')./sum(pArmDFref.*DFref,'c')).^(1/2);
pind_prod=(sum(p.*Q,'c')./sum(pref.*Q,'c').*sum(p.*Qref,'c')./sum(pref.*Qref,'c')).^(1/2);

GRB = ones(reg,1);
GRB  =  Rdisp.*(1-IR).*(1-ptc)+(1-div).*sum(p.*Q.*markup.*FCCmarkup_oil.*(FCC.*energ_sec+non_energ_sec),'c');
NRB = ones(reg,1);
NRB = (GRB.*(1-partExpK)+partImpK.*(ones(reg,1)*sum(GRB.*partExpK)));
DI = DIinfra + DIprod.*(((NRB-sum(DIinfra.*pArmDI,'c'))./sum(DIprod.*pArmDI,'c'))*ones(1,sec));

partInvestFirms = (1-div).*sum(p.*Q.*markup.*FCCmarkup_oil.*(FCC.*energ_sec+non_energ_sec),'c') ./ GRB;
partInvestHH    = Rdisp.*(1-IR).*(1-ptc) ./ GRB;

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
ExpTI(:,indice_transport_1:indice_transport_2) = marketshareTI.*(ones(reg,1)*(sum(Imp.*nit)*partTIref));

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

EBE = p.*Q.*markup.*FCCmarkup_oil.*(FCC.*energ_sec+non_energ_sec);

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
(A_CI(12,:).*Q(12,:))*((CI(:,:,12).*partDomCI(:,:,12).*taxCO2_CI(:,:,12).*coef_Q_CO2_CI(:,:,12).*(num(12,1)*ones(sec,sec)))')]..
+DF.*partDomDF.*taxCO2_DF.*coef_Q_CO2_DF.*num+DG.*partDomDG.*taxCO2_DG.*coef_Q_CO2_DG.*num+DI.*partDomDI.*taxCO2_DI.*coef_Q_CO2_DI.*num;

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
(A_CI(12,:).*Q(12,:))*((CI(:,:,12).*partImpCI(:,:,12).*taxCO2_CI(:,:,12).*coef_Q_CO2_CI(:,:,12).*(num(12,1)*ones(sec,sec)))')]..
+DF.*partImpDF.*taxCO2_DF.*coef_Q_CO2_DF.*num+DG.*partImpDG.*taxCO2_DG.*coef_Q_CO2_DG.*num+DI.*partImpDI.*taxCO2_DI.*coef_Q_CO2_DI.*num;

TAXCO2_hsld = sum( DF.*partDomDF.*taxCO2_DF.*coef_Q_CO2_DF.*num + DF.*partImpDF.*taxCO2_DF.*coef_Q_CO2_DF.*num, "c");

TAXCO2_sect_dom=zeros(reg,sec);
TAXCO2_sect_imp=zeros(reg,sec);
for k=1:reg		
    for j=1:sec
        TAXCO2_sect_dom(k,j)=sum(((CI(:,j,k).*partDomCI(:,j,k).*taxCO2_CI(:,j,k).*coef_Q_CO2_CI(:,j,k)))*Q(k,j));
        TAXCO2_sect_imp(k,j)=sum(((CI(:,j,k).*partImpCI(:,j,k).*taxCO2_CI(:,j,k).*coef_Q_CO2_CI(:,j,k)))*Q(k,j));
    end
end

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

E_CO2 = [   
(A_CI(1,:).*Q(1,:))*((CI(:,:,1).*      (coef_Q_CO2_CI(:,:,1)))');
(A_CI(2,:).*Q(2,:))*((CI(:,:,2).*      (coef_Q_CO2_CI(:,:,2)))');
(A_CI(3,:).*Q(3,:))*((CI(:,:,3).*      (coef_Q_CO2_CI(:,:,3)))');
(A_CI(4,:).*Q(4,:))*((CI(:,:,4).*      (coef_Q_CO2_CI(:,:,4)))');
(A_CI(5,:).*Q(5,:))*((CI(:,:,5).*      (coef_Q_CO2_CI(:,:,5)))');
(A_CI(6,:).*Q(6,:))*((CI(:,:,6).*      (coef_Q_CO2_CI(:,:,6)))');
(A_CI(7,:).*Q(7,:))*((CI(:,:,7).*      (coef_Q_CO2_CI(:,:,7)))');
(A_CI(8,:).*Q(8,:))*((CI(:,:,8).*      (coef_Q_CO2_CI(:,:,8)))');
(A_CI(9,:).*Q(9,:))*((CI(:,:,9).*      (coef_Q_CO2_CI(:,:,9)))');
(A_CI(10,:).*Q(10,:))*((CI(:,:,10).*   (coef_Q_CO2_CI(:,:,10)))');
(A_CI(11,:).*Q(11,:))*((CI(:,:,11).*   (coef_Q_CO2_CI(:,:,11)))');
(A_CI(12,:).*Q(12,:))*((CI(:,:,12).*   (coef_Q_CO2_CI(:,:,12)))')]..
+DF.*coef_Q_CO2_DF+ DG.*coef_Q_CO2_DG+  DI.*coef_Q_CO2_DI;

//E_CO2 = (QCdom+Imp).*coef_Q_CO2;
E_CO2_tot = sum(E_CO2);
E_C_tot = E_CO2_tot*12/44;

///////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////// CO2 emissions before sequestration
///////////////////////////////////////////////////////////////////////////////////////////////////////////
E_CO2_dom_wo_CCS = [(A_CI(1,:).*Q(1,:))*((CI(:,:,1).*partDomCI(:,:,1).*coef_Q_CO2_CI_wo_CCS(:,:,1))');
(A_CI(2,:).*Q(2,:))*((CI(:,:,2).*partDomCI(:,:,2).*coef_Q_CO2_CI_wo_CCS(:,:,2))');
(A_CI(3,:).*Q(3,:))*((CI(:,:,3).*partDomCI(:,:,3).*coef_Q_CO2_CI_wo_CCS(:,:,3))');
(A_CI(4,:).*Q(4,:))*((CI(:,:,4).*partDomCI(:,:,4).*coef_Q_CO2_CI_wo_CCS(:,:,4))');
(A_CI(5,:).*Q(5,:))*((CI(:,:,5).*partDomCI(:,:,5).*coef_Q_CO2_CI_wo_CCS(:,:,5))');
(A_CI(6,:).*Q(6,:))*((CI(:,:,6).*partDomCI(:,:,6).*coef_Q_CO2_CI_wo_CCS(:,:,6))');
(A_CI(7,:).*Q(7,:))*((CI(:,:,7).*partDomCI(:,:,7).*coef_Q_CO2_CI_wo_CCS(:,:,7))');
(A_CI(8,:).*Q(8,:))*((CI(:,:,8).*partDomCI(:,:,8).*coef_Q_CO2_CI_wo_CCS(:,:,8))');
(A_CI(9,:).*Q(9,:))*((CI(:,:,9).*partDomCI(:,:,9).*coef_Q_CO2_CI_wo_CCS(:,:,9))');
(A_CI(10,:).*Q(10,:))*((CI(:,:,10).*partDomCI(:,:,10).*coef_Q_CO2_CI_wo_CCS(:,:,10))');
(A_CI(11,:).*Q(11,:))*((CI(:,:,11).*partDomCI(:,:,11).*coef_Q_CO2_CI_wo_CCS(:,:,11))');
(A_CI(12,:).*Q(12,:))*((CI(:,:,12).*partDomCI(:,:,12).*coef_Q_CO2_CI_wo_CCS(:,:,12))')]+DF.*partDomDF.*coef_Q_CO2_DF+DG.*partDomDG.*coef_Q_CO2_DG+DI.*partDomDI.*coef_Q_CO2_DI;

E_CO2_imp_wo_CCS = [(A_CI(1,:).*Q(1,:))*((CI(:,:,1).*(partImpCI(:,:,1).*coef_Q_CO2_CI_wo_CCS(:,:,1)))');
(A_CI(2,:).*Q(2,:))*((CI(:,:,2).*(partImpCI(:,:,2).*coef_Q_CO2_CI_wo_CCS(:,:,2)))');
(A_CI(3,:).*Q(3,:))*((CI(:,:,3).*(partImpCI(:,:,3).*coef_Q_CO2_CI_wo_CCS(:,:,3)))');
(A_CI(4,:).*Q(4,:))*((CI(:,:,4).*(partImpCI(:,:,4).*coef_Q_CO2_CI_wo_CCS(:,:,4)))');
(A_CI(5,:).*Q(5,:))*((CI(:,:,5).*(partImpCI(:,:,5).*coef_Q_CO2_CI_wo_CCS(:,:,5)))');
(A_CI(6,:).*Q(6,:))*((CI(:,:,6).*(partImpCI(:,:,6).*coef_Q_CO2_CI_wo_CCS(:,:,6)))');
(A_CI(7,:).*Q(7,:))*((CI(:,:,7).*(partImpCI(:,:,7).*coef_Q_CO2_CI_wo_CCS(:,:,7)))');
(A_CI(8,:).*Q(8,:))*((CI(:,:,8).*(partImpCI(:,:,8).*coef_Q_CO2_CI_wo_CCS(:,:,8)))');
(A_CI(9,:).*Q(9,:))*((CI(:,:,9).*(partImpCI(:,:,9).*coef_Q_CO2_CI_wo_CCS(:,:,9)))');
(A_CI(10,:).*Q(10,:))*((CI(:,:,10).*(partImpCI(:,:,10)).*coef_Q_CO2_CI_wo_CCS(:,:,10))');
(A_CI(11,:).*Q(11,:))*((CI(:,:,11).*(partImpCI(:,:,11)).*coef_Q_CO2_CI_wo_CCS(:,:,11))');
(A_CI(12,:).*Q(12,:))*((CI(:,:,12).*(partImpCI(:,:,12)).*coef_Q_CO2_CI_wo_CCS(:,:,12))')]+DF.*(partImpDF).*coef_Q_CO2_DF+DG.*(partImpDG).*coef_Q_CO2_DG+DI.*(partImpDI).*coef_Q_CO2_DI;


E_CO2_wo_CCS = E_CO2_dom_wo_CCS+E_CO2_imp_wo_CCS;

///////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////

Z = 1-sum(A.*l.*Q,'c')./L;
VA=A.*w.*l.*Q.*(1).*(energ_sec+FCC.*non_energ_sec)+EBE;

// === GDP computation === //

// There are 2 GDP bases:
// - model own calibration GDP: which stems from the monetary values for hybridization
//       * GDP               (base: GDP_ref)    which is nominal MER
//       * GDP_MER_real      which is real    MER
// - exogenous reference   GDP: to abide by a prescribed reference GDP (in calibration.gdp.sce)
//       * GDP_MER_nominal   (base: referenceExoGDP_MER)
//       * GDP_MER_real      (base: referenceExoGDP_MER)
//       * GDP_PPP_constant  (base: referenceExoGDP_PPP)

GDP = sum(VA,"c")+sumtax-sum(DF.*pArmDF.*Ttax./(1+Ttax),'c'); // From model own calibration GDP
GDP_sect = VA + TAX_sect - DF.*pArmDF.*Ttax./(1+Ttax);
GrowthNominalMER = GDP ./ GDP_ref; // Growth multiplier nominal GDP MER

Labor_compensation_gross = sum(A.*w.*l.*Q.*(1+sigma).*(energ_sec+FCC.*non_energ_sec),"c");
Labor_compensation_net = sum(A.*w.*l.*Q.*(energ_sec+FCC.*non_energ_sec),"c");

// Approximation of sectoral GDP - tax by sector are missing
GDP_sect = VA + TAX_sect - DF.*pArmDF.*Ttax./(1+Ttax);
GDP_sect_wo_tax = A.*Q.*w.*l.*sigma.*(energ_sec+FCC.*non_energ_sec) + VA;

fisherQuantityIndex = ((sum(pArmDF_prev.*DF+pArmDG_prev.*DG+pArmDI_prev.*DI,'c')+sum(Exp.*p_prev.*(1+xtax)-Imp.*((ones(reg,1)*wp_prev).*(1)),'c'))./(sum(pArmDF_prev.*DF_prev+pArmDG_prev.*DG_prev+pArmDI_prev.*DI_prev,'c')+sum(Exp_prev.*p_prev.*(1+xtax)-Imp_prev.*((ones(reg,1)*wp_prev).*(1)),'c')).*(sum(pArmDF.*DF+pArmDG.*DG+pArmDI.*DI,'c')+sum(Exp.*p.*(1+xtax)-Imp.*((ones(reg,1)*wp).*(1)),'c'))./(sum(pArmDF.*DF_prev+pArmDG.*DG_prev+pArmDI.*DI_prev,'c')+sum(Exp_prev.*p.*(1+xtax)-Imp_prev.*((ones(reg,1)*wp).*(1)),'c'))).^(1/2); //Fischer Quantity Index
chainedFisherQIndex = chainedFisherQIndex_prev .* fisherQuantityIndex; // Chained Fisher Quantity Index
GrowthRealMER = chainedFisherQIndex; //  Growth multiplier real GDP MER

GDP_MER_nominal = GrowthNominalMER.*GDP_ref; // From calibration.gdp.sce base GDP (exogenous)
GDP_MER_real = GrowthRealMER.*GDP_ref;       // From calibration.gdp.sce base GDP (exogenous)
GDP_PPP_constant_prev=GDP_PPP_constant;
GDP_PPP_constant = GDP_MER_real     ./ PPP_factors; 
GPP_secMER_real = (GDP_MER_real*ones(1,sec)) .* ( GDP_sect ./ (sum(GDP_sect, "c")*ones(1,sec)));
GDP_secPPP_constant = (GDP_PPP_constant*ones(1,sec)) .* ( GDP_sect ./ (sum(GDP_sect, "c")*ones(1,sec)));

//residentiel //TODO: check again if the line below can indeed be removed
//deltastockbatiment = deltastockbatimentref.*(QCdom(:,indice_construction)./QCdomref(:,indice_construction));

//transport
//deltastockautomobile = deltastockautomobileref.*(DF(:,indice_composite)./DFref(:,indice_composite));
//infrastructures
//deltastockinfra = stockinfra.*depreciationinfra+1.01*stockinfra;
//deltastockinfra = deltastockinfraref.*sum(DIinfra,'c')./sum(DIinfraref,'c');

if max(abs((QCdom+Exp+ExpTI)./Q-1))>10*sensibility then 
    warning	( 'in Extraction generic:')
    say " max(abs((QCdom+Exp+ExpTI)./Q-1))"
    warning("This mean there is an inconsistency between the static code (C) and the scilab extraction code. Please check equations");
end


////////////////////Calcul des matrices énergétiques
energy_balance = zeros(indice_matEner,8,reg);
for k = 1:reg
    energy_balance(:,:,k) = matrix(bilan_energetique(CI,Q,DF,Imp,Exp,k),indice_matEner,8);
    TPES(k)=sum(energy_balance(5,:,k));
    TFC(k) =sum(energy_balance(9,:,k));
end
energy_balance_stock = matrix(energy_balance,reg*indice_matEner*8,1);


E_reg_use=emissions_usage(CI,Q,DF,DI);
Ener_reg_use = energie_usage(CI,Q,DF,DI,DG);
TAXCO2_2report = (sum(E_reg_use,2)+emi_evitee)/1e6.*taxCO2_DF(:,1)*1e6;

Tair=tair(Conso);
TOT=tOT(Conso);

markup_stock=markup.*FCCmarkup_oil;

progestechl=l./lref;
Lact=L;

prod_CTL  = zeros(reg,1); //CTL
prod_BFU  = zeros(reg,1); //biofuels
prod_ORI  = zeros(reg,1); //oil refining
prod_Et   = Q(:,indice_Et);
prod_elec = Q(:,indice_elec);


for k=1:reg
    prod_CTL(k)=CI(indice_coal,indice_Et,k)*Q(k,indice_Et)*yield_CTL;                     //CTL         
    prod_ORI(k)=CI(indice_oil,indice_Et,k)*Q(k,indice_Et)/CIref(indice_oil,indice_Et,k); //oil refining 
    prod_BFU(k)=max(Q(k,indice_Et)-prod_CTL(k)-prod_ORI(k),0);                            //biofuels    
end

// Auto-calibration of txCaptemp: gross rate of productive capacities
inert_temp=1;
if auto_calibration_txCap<>"None" & current_time_im==year_calib_txCaptemp
    txCaptemp=max( (Q./Qref) .^ (1. /year_calib_txCaptemp) -1,0);
    txCaptemp2sav = inert_temp*txCaptemp + (1-inert_temp)*txCap;
    error=divide(txCaptemp,txCap,1);
    abs_error= abs(error(:,6:$)-1);
    disp( "txCaptemp", txCaptemp);
    disp( [max( abs_error(abs_error<1)), mean(abs_error(abs_error<1))], "max, mean");
    csvWrite( txCaptemp2sav, path_autocal_txCap+'/txCaptemp_'+string(nb_sectors)+'.csv');
    abort;
end

if ind_NLU >=1
    Q_biofuel_real = share_biofuel .* Q(:,indice_Et);
    export_liquids_biomass = share_biofuel .* Exp(:,indice_Et);
    pool_liquids_biomass = sum(export_liquids_biomass) ./ sum(Exp(:,indice_Et)) .* ones(Exp(:,indice_Et));
    import_liquids_biomass = pool_liquids_biomass .* Imp(:,indice_Et);
    Net_exp_se_biom_liquids = (export_liquids_biomass - import_liquids_biomass) * mtoe2ej / 0.4;
end

pImp = (ones(reg,1)*wp).*(1+mtax)+(ones(reg,sec)*wpTIagg).*nit;
pImp_notax = (ones(reg,1)*wp)+(ones(reg,sec)*wpTIagg).*nit;

if exo_pkmair_scenario >0
    CI_air = zeros(nb_regions,1);
    for ii=1:nb_sectors
        CI_air = CI_air + Q(:,ii).*matrix(CI(indice_air,ii,:),nb_regions,1);
    end
    pkm_air_inc = ( Conso(:,indice_air-nbsecteurenergie) + DG(:,indice_air) + DI(:,indice_air) + sum( Imp .* nit,"c") .*partTIref(1)+CI_air) ./ ( Consoref(:,indice_air-nbsecteurenergie) + DGref(:,indice_air) + DIref(:,indice_air) + ImpTIref+CI_air_ref);
end

if ind_climat == 99 & current_time_im == start_tax+duration_NDC
    // trick to force the sav files to be recognized
    // This shall only be used for calibration runs!
    IamDoneFolks=1;
    mksav("IamDoneFolks");
    sg_save()
    exec(MODEL+ "terminate.sce")
    abort;
end

// Climate policy uncertainty and credibility scenario filter
if ind_climpol_uncer>0 
    if current_time_im == 1
        WCB_2020_total = zeros(reg, TimeHorizon)
    end
    //Emissions|CO2|Energy in GT
    ECO2ener(:,current_time_im) = sum(E_reg_use(:,:),"c")/1e9 + emi_evitee/1e9;
    //Emissions|CO2|Industrial Processes in GT
    ECO2indus(:,current_time_im) = CO2_indus_process/1e3;
    //Emissions|CO2|AFOLU in GT. These emi stop in 2020, so we do not include them in the CB
    ECO2AFOLU(:, current_time_im) = (exo_CO2_LUCCCF(:,current_time_im+1) + exo_CO2_agri_direct(:,current_time_im+1))/1e3;

    //total emi
    ECO2(:,current_time_im) = ECO2ener(:,current_time_im) + ECO2indus(:,current_time_im);

    //CB
    if current_time_im>=2020-base_year_simulation
        WCB_2020_total(:,current_time_im) = sum(ECO2(:,(2020-base_year_simulation):$),"c");
        disp("Total 2020 CB: " + sum(WCB_2020_total(:,current_time_im))+" GtCO2") 
    end

    if current_time_im == year_nz - base_year_simulation // time to reach NZ or respect a CB
        if ~isdef("nz_emi")
            nz_emi = 1000;
        end
        emi_NZ = sum(ECO2(:,current_time_im));
        global CO2_indus_process_sav
        CB_NZ = sum(WCB_2020_total(:,current_time_im));
        //exporting the yearly CT profile
        if nbMKT == 1
            csvWrite( [["Year","Price|Carbon"];[base_year_simulation:(base_year_simulation +TimeHorizon);taxMKTexo * 10^6]'],OUTPUT+run_id+"/carbon_price_"+run_id + ".csv", "," )
        end
        if nbMKT == 9
            csvWrite( [["Year","Price|Carbon|MK1","Price|Carbon|MK2","Price|Carbon|MK3","Price|Carbon|MK4","Price|Carbon|MK5","Price|Carbon|MK6","Price|Carbon|MK7","Price|Carbon|MK8","Price|Carbon|MK9"];[base_year_simulation:(base_year_simulation +TimeHorizon);taxMKTexo * 10^6]'],OUTPUT+run_id+"/carbon_price_"+run_id + ".csv", "," )
        end
        if ind_nz & ind_force_export==1
            mkdir(OUTPUT + 'NZ_'+year_nz+'/')
            csvWrite( ["Truncated_Horizon","Planning_Horizon","Wait_See","Max_Inj_Rate","CB_NZ","NZ_emi"; 
            horizon_CT,nb_year_expect_LCC,ind_wait_n_see,max_CCS_injection/giga2unity,CB_NZ,emi_NZ], OUTPUT + 'NZ_'+year_nz+'/' + run_id + '.csv', '|');
        end
        if ind_nz & ind_force_export==0
            if  sum(emi_NZ) < nz_emi 
                mkdir(OUTPUT + 'NZ_'+year_nz+'/')
                csvWrite( ["Truncated_Horizon","Planning_Horizon","Wait_See","Max_Inj_Rate","CB_NZ","NZ_emi"; 
                horizon_CT,nb_year_expect_LCC,ind_wait_n_see,max_CCS_injection/giga2unity,CB_NZ,sum(emi_NZ)], OUTPUT + 'NZ_'+year_nz+'/' + run_id + '.csv', '|');
            end
        end
    end
end

final_energy_freight = zeros(nb_regions,1);
for k=1:nb_regions
    final_energy_freight(k,1) = (..
        (sum(energy_balance(conso_transport_eb,[elec_eb,gas_eb,et_eb,coal_eb],k))) ..
        - sum(energy_balance(conso_car_eb,[elec_eb,gas_eb,et_eb,coal_eb],k)).. // passenger cars
        - (alpharail_passenger(k,indice_coal) + alpharail_passenger(k,indice_oil)) * EnergyServices_road_pass(k)..
        - (alpharoad_passenger(k,indice_coal) + alpharoad_passenger(k,indice_oil)) * EnergyServices_road_pass(k)..
        - sum(alpharail_passenger(k,[indice_elec,indice_Et,indice_gas])) * EnergyServices_rail_pass(k) - sum(alpharoad_passenger(k,[indice_elec,indice_Et,indice_gas]))      *EnergyServices_road_pass(k)..
        - sum(energy_balance(conso_air_eb,[elec_eb,gas_eb,et_eb,coal_eb],k))*DF(k,indice_air)/(Q(k,indice_air))* ShareDomAviation_2014(k)..//passenger domestic aviation
        - sum(energy_balance(conso_air_eb,[elec_eb,gas_eb,et_eb,coal_eb],k))* (1-ShareDomAviation_2014(k)).. //international aviation
    ) * Mtoe_EJ;
end

