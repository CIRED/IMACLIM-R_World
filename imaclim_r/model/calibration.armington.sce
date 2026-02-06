// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION with no source   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

// trade elasticities for energy sectors
alpha_partDX_coal=-7;

alpha_partDF=-7*ones(reg,nbsecteurenergie);
alpha_partDF(:,indice_Et)=-7*ones(reg,1);
alpha_partDF(:,indice_elec)=-1*ones(reg,1);
alpha_partDF(:,indice_coal)=alpha_partDX_coal*ones(reg,1);

alpha_partDG=-7*ones(reg,nbsecteurenergie);
alpha_partDG(:,indice_Et)=-7*ones(reg,1);
alpha_partDG(:,indice_elec)=-1*ones(reg,1);
alpha_partDG(:,indice_coal)=alpha_partDX_coal*ones(reg,1);

alpha_partDI=-7*ones(reg,nbsecteurenergie);
alpha_partDI(:,indice_Et)=-7*ones(reg,1);
alpha_partDI(:,indice_elec)=-1*ones(reg,1);
alpha_partDI(:,indice_coal)=alpha_partDX_coal*ones(reg,1);

alpha_partCI=-7*ones(nbsecteurenergie,sec,reg);
for k=1:reg,
    alpha_partCI(indice_Et,:,k)=-7*ones(1,sec);
    alpha_partCI(indice_elec,:,k)=-1*ones(1,sec);
    alpha_partCI(indice_coal,:,k)=alpha_partDX_coal*ones(1,sec);
end

/////////////////////////////////////////////////////////////////////////////////////////////
//    ---*---   CALIBRATION   ---*---    
////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
//                8. Armington parts 			                    //
//////////////////////////////////////////////////////////////////////////////
for k=1:reg
    for j=1:sec
        if DGref(k,j)==0 then DGref(k,j)=0.00000000001; end 
        if DIref(k,j)==0 then DIref(k,j)=0.00000000001; end
        if DFref(k,j)==0 then DFref(k,j)=0.00000000001; end
    end
end

for k=1:reg,
    for k1=1:sec,
        for k2=1:sec,
            if CIref(k1,k2,k)==0 then CIref(k1,k2,k)=0.00000000001; end
        end
    end
end


partDomDFref=DFdomref./DFref;
partImpDFref=DFimpref./DFref;
partDomDGref=DGdomref./DGref;
partImpDGref=DGimpref./DGref;
partDomDIref=DIdomref./DIref;
partImpDIref=DIimpref./DIref;
partDomCIref=ones(sec,sec,reg);
partImpCIref=ones(sec,sec,reg);
for k=1:reg,
    partDomCIref(:,:,k)=CIdomref(:,:,k)./(CItotref(:,:,k)+1e-15*ones(sec,sec));
    partImpCIref(:,:,k)=CIimpref(:,:,k)./(CItotref(:,:,k)+1e-15*ones(sec,sec));
end


for k=1:reg,
    for k1=1:sec,
        for k2=1:sec,
            if CIref(k1,k2,k)==0.00000000001 then CIref(k1,k2,k)=0; partDomCIref(k1,k2,k)=1; partImpCIref(k1,k2,k)=0; end
        end
    end
end
for k=1:reg
    for j=1:sec
        if DGref(k,j)==0.00000000001 then DGref(k,j)=0; partDomDGref(k,j)=1; partImpDGref(k,j)=0; end 
        if DIref(k,j)==0.00000000001 then DIref(k,j)=0;  partImpDIref(k,j)=0; partDomDIref(k,j)=1;  end
        if DFref(k,j)==0.00000000001 then DFref(k,j)=0;  partImpDFref(k,j)=0; partDomDFref(k,j)=1;  end

    end
end


// energy sectors

wpEnerref=wpref(1:nbsecteurenergie);

for k=1:reg
    for j=1:nbsecteurenergie
        if partImpDFref(k,j)==0 then partImpDFref(k,j)=0.00000001; end 
        if partImpDGref(k,j)==0 then partImpDGref(k,j)=0.00000001; end
        if partImpDIref(k,j)==0 then partImpDIref(k,j)=0.00000001; end
        if partDomDFref(k,j)==1 then partDomDFref(k,j)=0.99999999; end
        if partDomDIref(k,j)==1 then partDomDIref(k,j)=0.99999999; end
        if partDomDGref(k,j)==1 then partDomDGref(k,j)=0.99999999; end
    end
end

for k=1:reg,
    for k1=1:nbsecteurenergie,
        for k2=1:sec,
            if partImpCIref(k1,k2,k)==0 then partImpCIref(k1,k2,k)=0.00000001; end
            if partDomCIref(k1,k2,k)==1 then partDomCIref(k1,k2,k)=0.99999999; end
        end
    end
end


// itgbl_cost_DF=(partDomDFref(:,1:nbsecteurenergie).*(((ones(reg,1)*wpEnerref).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDFimp(:,1:nbsecteurenergie))).^alpha_partDF./partImpDFref(:,1:nbsecteurenergie)).^(ones(reg,nbsecteurenergie)./alpha_partDF)-(pref(:,1:nbsecteurenergie).*(1+taxDFdom(:,1:nbsecteurenergie)));
// itgbl_cost_DG=(partDomDGref(:,1:nbsecteurenergie).*(((ones(reg,1)*wpEnerref).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDGimp(:,1:nbsecteurenergie))).^alpha_partDG./partImpDGref(:,1:nbsecteurenergie)).^(ones(reg,nbsecteurenergie)./alpha_partDG)-(pref(:,1:nbsecteurenergie).*(1+taxDGdom(:,1:nbsecteurenergie)));
// itgbl_cost_DI=(partDomDIref(:,1:nbsecteurenergie).*(((ones(reg,1)*wpEnerref).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDIimp(:,1:nbsecteurenergie))).^alpha_partDI./partImpDIref(:,1:nbsecteurenergie)).^(ones(reg,nbsecteurenergie)./alpha_partDI)-(pref(:,1:nbsecteurenergie).*(1+taxDIdom(:,1:nbsecteurenergie)));
itgbl_cost_DFdom=zeros(reg,nbsecteurenergie);
itgbl_cost_DFimp=zeros(reg,nbsecteurenergie);
for k=1:reg,
    for j=1:nbsecteurenergie,
        int_cost_DFtemp=IC_calibration([partDomDFref(k,j),partImpDFref(k,j)],[pref(k,j)*(1+taxDFdom(k,j)),(wpEnerref(1,j)*(1+mtax(k,j))+wpTIagg*nit(k,j))*(1+taxDFimp(k,j))],1,-alpha_partDF(k,j));
        if min(int_cost_DFtemp(1),int_cost_DFtemp(2))<-0.01 then int_cost_DFtemp=IC_calibration([partDomDFref(k,j),partImpDFref(k,j)],[pref(k,j)*(1+taxDFdom(k,j)),(wpEnerref(1,j)*(1+mtax(k,j))+wpTIagg*nit(k,j))*(1+taxDFimp(k,j))],2,-alpha_partDF(k,j));
        end
        itgbl_cost_DFdom(k,j)=int_cost_DFtemp(1);
        itgbl_cost_DFimp(k,j)=int_cost_DFtemp(2);
    end
end

itgbl_cost_DGdom=zeros(reg,nbsecteurenergie);
itgbl_cost_DGimp=zeros(reg,nbsecteurenergie);
for k=1:reg,
    for j=1:nbsecteurenergie,
        int_cost_DGtemp=IC_calibration([partDomDGref(k,j),partImpDGref(k,j)],[pref(k,j)*(1+taxDGdom(k,j)),(wpEnerref(1,j)*(1+mtax(k,j))+wpTIagg*nit(k,j))*(1+taxDGimp(k,j))],1,-alpha_partDG(k,j));
        if min(int_cost_DGtemp(1),int_cost_DGtemp(2))<-0.01 then int_cost_DGtemp=IC_calibration([partDomDGref(k,j),partImpDGref(k,j)],[pref(k,j)*(1+taxDGdom(k,j)),(wpEnerref(1,j)*(1+mtax(k,j))+wpTIagg*nit(k,j))*(1+taxDGimp(k,j))],2,-alpha_partDG(k,j));
        end
        itgbl_cost_DGdom(k,j)=int_cost_DGtemp(1);
        itgbl_cost_DGimp(k,j)=int_cost_DGtemp(2);
    end
end

itgbl_cost_DIdom=zeros(reg,nbsecteurenergie);
itgbl_cost_DIimp=zeros(reg,nbsecteurenergie);
for k=1:reg,
    for j=1:nbsecteurenergie,
        int_cost_DItemp=IC_calibration([partDomDIref(k,j),partImpDIref(k,j)],[pref(k,j)*(1+taxDIdom(k,j)),(wpEnerref(1,j)*(1+mtax(k,j))+wpTIagg*nit(k,j))*(1+taxDIimp(k,j))],1,-alpha_partDI(k,j));
        if min(int_cost_DItemp(1),int_cost_DItemp(2))<-0.01 then int_cost_DItemp=IC_calibration([partDomDIref(k,j),partImpDIref(k,j)],[pref(k,j)*(1+taxDIdom(k,j)),(wpEnerref(1,j)*(1+mtax(k,j))+wpTIagg*nit(k,j))*(1+taxDIimp(k,j))],2,-alpha_partDI(k,j));
        end
        itgbl_cost_DIdom(k,j)=int_cost_DItemp(1);
        itgbl_cost_DIimp(k,j)=int_cost_DItemp(2);
    end
end

// for k=1:reg
// itgbl_cost_CI(:,:,k)=(partDomCIref(1:nbsecteurenergie,:,k).*((((wpref(1:nbsecteurenergie).*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIagg)'*ones(1,sec)).*(1+taxCIimp(1:nbsecteurenergie,:,k)))).^alpha_partCI(:,:,k)./partImpCIref(1:nbsecteurenergie,:,k)).^(ones(nbsecteurenergie,sec)./alpha_partCI(:,:,k))-((pref(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k)));
// end
itgbl_cost_CIdom=zeros(nbsecteurenergie,sec,reg);
itgbl_cost_CIimp=zeros(nbsecteurenergie,sec,reg);

for k=1:reg,
    for j=1:nbsecteurenergie,
        for jj=1:sec,
            int_cost_CItemp=IC_calibration([partDomCIref(j,jj,k),partImpCIref(j,jj,k)],[pref(k,j)*(1+taxCIdom(j,jj,k)),(wpEnerref(1,j)*(1+mtax(k,j))+wpTIagg*nit(k,j))*(1+taxCIimp(j,jj,k))],1,-alpha_partCI(j,jj,k));
            if min(int_cost_CItemp(1),int_cost_CItemp(2))<-0.01 then int_cost_CItemp=IC_calibration([partDomCIref(j,jj,k),partImpCIref(j,jj,k)],[pref(k,j)*(1+taxCIdom(j,jj,k)),(wpEnerref(1,j)*(1+mtax(k,j))+wpTIagg*nit(k,j))*(1+taxCIimp(j,jj,k))],2,-alpha_partCI(j,jj,k));
            end
            itgbl_cost_CIdom(j,jj,k)=int_cost_CItemp(1);
            itgbl_cost_CIimp(j,jj,k)=int_cost_CItemp(2);
        end
    end
end



//((pref(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k)))
//((((wpref(1:nbsecteurenergie).*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIagg)'*ones(1,sec)).*(1+taxCIimp(1:nbsecteurenergie,:,k))))
for k=1:reg,
    for k1=1:nbsecteurenergie,
        for k2=1:sec,
            //      if partImpCIref(k1,k2,k)==0.000000001 then partImpCIref(k1,k2,k)=0; itgbl_cost_CI(k1,k2,k)=10^34; end
            //      if partImpCIref(k1,k2,k)>=0.9999999 then aImpCI(k1,k2,k)=0; bImpCI(k1,k2,k)=partImpCIref(k1,k2,k); end
        end
    end
end

//for k=1:reg,
//  for k1=1:nbsecteurenergie,
//    if partImpDFref(k,k1)==0.000000001 then partImpDFref(k,k1)=0; itgbl_cost_DF(k,k1)=10^34; end
//    if partImpDFref(k,k1)==1 then itgbl_cost_DF(k,k1)=-(pref(k,k1).*(1+taxDFdom(k,k1))); end
//    if partImpDIref(k,k1)==0.000000001 then partImpDIref(k,k1)=0; itgbl_cost_DI(k,k1)=10^34; end
//    if partImpDIref(k,k1)==1 then aImpDI(k,k1)=0; bImpDI(k,k1)=1; end
//    if partImpDGref(k,k1)==0.000000001 then partImpDGref(k,k1)=0; itgbl_cost_DG(k,k1)=10^34; end
//    if partImpDGref(k,k1)>=0.9999999 then aImpDG(k,k1)=0; bImpDG(k,k1)=partImpDGref(k,k1); end
// end
//end








pArmDFref=zeros(reg,sec);
pArmDGref=zeros(reg,sec);
pArmDIref=zeros(reg,sec);
pArmCIref=zeros(sec,sec,reg);

pArmDFref(:,1:nbsecteurenergie)=(pref(:,1:nbsecteurenergie).*(1+taxDFdom(:,1:nbsecteurenergie))).*(1-partImpDFref(:,1:nbsecteurenergie))+(((ones(reg,1)*wpref(:,1:nbsecteurenergie)).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDFimp(:,1:nbsecteurenergie))).*partImpDFref(:,1:nbsecteurenergie);
pArmDGref(:,1:nbsecteurenergie)=(pref(:,1:nbsecteurenergie).*(1+taxDGdom(:,1:nbsecteurenergie))).*(1-partImpDGref(:,1:nbsecteurenergie))+(((ones(reg,1)*wpref(:,1:nbsecteurenergie)).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDGimp(:,1:nbsecteurenergie))).*partImpDGref(:,1:nbsecteurenergie);
pArmDIref(:,1:nbsecteurenergie)=(pref(:,1:nbsecteurenergie).*(1+taxDIdom(:,1:nbsecteurenergie))).*(1-partImpDIref(:,1:nbsecteurenergie))+(((ones(reg,1)*wpref(:,1:nbsecteurenergie)).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIagg).*nit(:,1:nbsecteurenergie)).*(1+taxDIimp(:,1:nbsecteurenergie))).*partImpDIref(:,1:nbsecteurenergie);

for k=1:reg,
    pArmCIref(1:nbsecteurenergie,:,k)=((pref(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k))).*(1-partImpCIref(1:nbsecteurenergie,:,k))+(((wpref(1:nbsecteurenergie).*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIagg)'*ones(1,sec)).*(1+taxCIimp(1:nbsecteurenergie,:,k))).*partImpCIref(1:nbsecteurenergie,:,k);
end

// non-energy sectors 

pArmDFref(:,nbsecteurenergie+1:sec)=((bDF.^etaDF).*((pref(:,nbsecteurenergie+1:sec).*(1+taxDFdom(:,nbsecteurenergie+1:sec))).^(1-etaDF))+((1-bDF).^etaDF).*((((ones(reg,1)*wpref(:,nbsecteurenergie+1:sec)).*(1+mtax(:,nbsecteurenergie+1:sec))+(ones(reg,sec-nbsecteurenergie)*wpTIagg).*nit(:,nbsecteurenergie+1:sec)).*(1+taxDFimp(:,nbsecteurenergie+1:sec))).^(1-etaDF))).^(ones(reg,sec-nbsecteurenergie)./(1-etaDF));
pArmDGref(:,nbsecteurenergie+1:sec)=((bDG.^etaDG).*((pref(:,nbsecteurenergie+1:sec).*(1+taxDGdom(:,nbsecteurenergie+1:sec))).^(1-etaDG))+((1-bDG).^etaDG).*((((ones(reg,1)*wpref(:,nbsecteurenergie+1:sec)).*(1+mtax(:,nbsecteurenergie+1:sec))+(ones(reg,sec-nbsecteurenergie)*wpTIagg).*nit(:,nbsecteurenergie+1:sec)).*(1+taxDGimp(:,nbsecteurenergie+1:sec))).^(1-etaDG))).^(ones(reg,sec-nbsecteurenergie)./(1-etaDG));
pArmDIref(:,nbsecteurenergie+1:sec)=((bDI.^etaDI).*((pref(:,nbsecteurenergie+1:sec).*(1+taxDIdom(:,nbsecteurenergie+1:sec))).^(1-etaDI))+((1-bDI).^etaDI).*((((ones(reg,1)*wpref(:,nbsecteurenergie+1:sec)).*(1+mtax(:,nbsecteurenergie+1:sec))+(ones(reg,sec-nbsecteurenergie)*wpTIagg).*nit(:,nbsecteurenergie+1:sec)).*(1+taxDIimp(:,nbsecteurenergie+1:sec))).^(1-etaDI))).^(ones(reg,sec-nbsecteurenergie)./(1-etaDI));

for k=1:reg,
    pArmCIref(nbsecteurenergie+1:sec,:,k)=((bCI(:,:,k).^etaCI(:,:,k)).*(((pref(k,nbsecteurenergie+1:sec)'*ones(1,sec)).*(1+taxCIdom(nbsecteurenergie+1:sec,:,k))).^(1-etaCI(:,:,k)))+((1-bCI(:,:,k)).^etaCI(:,:,k)).*((((wpref(nbsecteurenergie+1:sec).*(1+mtax(k,nbsecteurenergie+1:sec))+wpTIagg*nit(k,nbsecteurenergie+1:sec))'*ones(1,sec)).*(1+taxCIimp(nbsecteurenergie+1:sec,:,k))).^(1-etaCI(:,:,k)))).^(ones(sec-nbsecteurenergie,sec)./(1-etaCI(:,:,k)));
end


// check

checkDF=ones(reg,sec);
checkDG=ones(reg,sec);
checkDI=ones(reg,sec);
checkCI=ones(sec,sec,reg);

for k=1:reg,
    checkDF(k,:)=DFref(k,:).*pArmDFref(k,:)-(C_hsld_dom_Im(k,:)+C_hsld_imp_Im(k,:));
    checkDG(k,:)=DGref(k,:).*pArmDGref(k,:)-(C_AP_dom_Im(k,:)+C_AP_imp_Im(k,:));
    checkDI(k,:)=DIref(k,:).*pArmDIref(k,:)-(FBCF_dom_Im(k,:)+FBCF_imp_Im(k,:));
    checkCI(:,:,k)=CItotref(:,:,k).*pArmCIref(:,:,k)-matrix((CI_dom_Im(k,:,:)+T_CI_dom_Im(k,:,:)+CI_imp_Im(k,:,:)+T_CI_imp_Im(k,:,:)), nb_sectors, nb_sectors);
end

//disp(max(abs(checkDF./(DFref+1e-12*ones(reg,sec)))),'maximum error on DF = ');
//disp(max(abs(checkDG./(DGref+1e-12*ones(reg,sec)))),'maximum error on DG = ');
//disp(max(abs(checkDI./(DIref+1e-12*ones(reg,sec)))),'maximum error on DI = ');
for k=1:reg,
    //disp(max(abs(checkCI(:,:,k)./(CItotref(:,:,k)+1e-12*ones(sec,sec)))),'=', k, 'maximum error on CI');
end

CI0ref=CIref;
