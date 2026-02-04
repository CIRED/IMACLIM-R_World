// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION with no source   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

// increase armington elasticty for the industrial sector compare to others
factor_increase_ETA_indu = 2; // DESAG_INDUSTRY: same for all industrial sectors in the first version (see line 130)

/////////////////////////////////////////////////////////////////////////////////////////////
//    ---*---   CALIBRATION   ---*---    
////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
//                7. National taxes and Physical quantities                 //
//////////////////////////////////////////////////////////////////////////////


// real quantities have to be computed with the real prices and taxes

for k = 1:reg,
    for j = 1:sec,

        //tax for Households//

        if (C_hsld_dom_Im(k,j)-T_Hsld_dom_Im(k,j)==0) then taxDFdom(k,j) = 0; 
        else taxDFdom(k,j) = (T_Hsld_dom_Im(k,j)/(C_hsld_dom_Im(k,j)-T_Hsld_dom_Im(k,j))); 
        end
        if (C_hsld_imp_Im(k,j)-T_Hsld_imp_Im(k,j)==0) then taxDFimp(k,j) = 0; 
        else taxDFimp(k,j) = (T_Hsld_imp_Im(k,j)/(C_hsld_imp_Im(k,j)-T_Hsld_imp_Im(k,j))); 
        end

        // tax for Public administrations //

        if (C_AP_dom_Im(k,j)-T_AP_dom_Im(k,j)==0) then taxDGdom(k,j)=0; 
        else taxDGdom(k,j)=T_AP_dom_Im(k,j)./(C_AP_dom_Im(k,j)-T_AP_dom_Im(k,j));
        end
        if (C_AP_imp_Im(k,j)-T_AP_imp_Im(k,j)==0) then taxDGimp(k,j)=0; 
        else taxDGimp(k,j)=T_AP_imp_Im(k,j)./(C_AP_imp_Im(k,j)-T_AP_imp_Im(k,j));
        end

        // tax for Investors ///

        if (FBCF_dom_Im(k,j)-T_FBCF_dom_Im(k,j)==0) then taxDIdom(k,j)=0; 
        else taxDIdom(k,j)=T_FBCF_dom_Im(k,j)./(FBCF_dom_Im(k,j)-T_FBCF_dom_Im(k,j));
        end
        if (FBCF_imp_Im(k,j)-T_FBCF_imp_Im(k,j)==0) then taxDIimp(k,j)=0; 
        else taxDIimp(k,j)=T_FBCF_imp_Im(k,j)./(FBCF_imp_Im(k,j)-T_FBCF_imp_Im(k,j));
        end

        if (abs(taxDFdom(k,j))<=1e-8) then taxDFdom(k,j)=0; end
        if (abs(taxDFimp(k,j))<=1e-8) then taxDFimp(k,j)=0; end
        if (abs(taxDGdom(k,j))<=1e-8) then taxDGdom(k,j)=0; end
        if (abs(taxDGimp(k,j))<=1e-8) then taxDGimp(k,j)=0; end
        if (abs(taxDIdom(k,j))<=1e-8) then taxDIdom(k,j)=0; end
        if (abs(taxDIimp(k,j))<=1e-8) then taxDIimp(k,j)=0; end

        // Physical demands ///

        DFdomref(k,j)=divide(C_hsld_dom_Im(k,j),(pref(k,j)*(1+taxDFdom(k,j))),0);
        DFimpref(k,j)=divide(C_hsld_imp_Im(k,j),((1+taxDFimp(k,j))*(wpref(j)*(1+mtax(k,j))+nit(k,j)*wpTIagg)),0);
        DGdomref(k,j)=C_AP_dom_Im(k,j)/(pref(k,j)*(1+taxDGdom(k,j)));
        DGimpref(k,j)=C_AP_imp_Im(k,j)/((1+taxDGimp(k,j))*(wpref(j)*(1+mtax(k,j))+nit(k,j)*wpTIagg));
        DIdomref(k,j)=FBCF_dom_Im(k,j)/(pref(k,j)*(1+taxDIdom(k,j)));
        DIimpref(k,j)=FBCF_imp_Im(k,j)/((1+taxDIimp(k,j))*(wpref(j)*(1+mtax(k,j))+nit(k,j)*wpTIagg));

        // tax for Intermediate Consumptions ///

   for ii=1:sec,
      if (CI_dom_Im(k,ii,j)==0) then taxCIdom(ii,j,k)=0;
						else taxCIdom(ii,j,k)=T_CI_dom_Im(k,ii,j)/CI_dom_Im(k,ii,j);
            end
      if (abs(taxCIdom(ii,j,k))<=1e-7) then taxCIdom(ii,j,k)=0;
            end

      CIdomref(ii,j,k)=CI_dom_Im(k,ii,j)/pref(k,ii);

      if (CI_imp_Im(k,ii,j)==0) then taxCIimp(ii,j,k)=0;
				      else taxCIimp(ii,j,k)=T_CI_imp_Im(k,ii,j)/CI_imp_Im(k,ii,j);
            end
      if (abs(taxCIimp(ii,j,k))<=1e-8) then taxCIimp(ii,j,k)=0;
            end

      CIimpref(ii,j,k)=CI_imp_Im(k,ii,j)./(wpref(ii)*(1+mtax(k,ii))+nit(k,ii)*wpTIagg);
      end
    end
end

if ind_CIimpRefAgriElecNul == 1
    CIdomref(indice_agriculture, indice_elec, :) = CIdomref (indice_agriculture, indice_elec, :) + CIimpref(indice_agriculture, indice_elec, :);
    CIimpref(indice_agriculture, indice_elec, :) = 0;
end

// total intermediate consumption in each country for each aggregate good

CIdomtot=zeros(reg,sec);
for k=1:reg,
    CIdomtot(k,:)=sum(CIdomref(:,:,k),'c')';
end

QCdomref=CIdomtot+DFdomref+DGdomref+DIdomref;		// total domestic production consumed domestically
Qref=QCdomref+Expref+ExpTIref;				// total domestic production

DFref=zeros(reg,sec);					// declaration of variables
DGref=zeros(reg,sec);
DIref=zeros(reg,sec);
CItotref=zeros(sec,sec,reg);

// energy sectors : imports and domestic are additive

DFref(:,1:nbsecteurenergie)=DFdomref(:,1:nbsecteurenergie)+DFimpref(:,1:nbsecteurenergie);
DGref(:,1:nbsecteurenergie)=DGdomref(:,1:nbsecteurenergie)+DGimpref(:,1:nbsecteurenergie);
DIref(:,1:nbsecteurenergie)=DIdomref(:,1:nbsecteurenergie)+DIimpref(:,1:nbsecteurenergie);
CItotref(1:nbsecteurenergie,:,:)=CIdomref(1:nbsecteurenergie,:,:)+CIimpref(1:nbsecteurenergie,:,:);

// non energy sectors - Armington goods

// definitions of the CES weights ///

// elasticities
if ~isdef ("ETA")
    error("ETA is not defined, see STUDY.sce");
end
etaDF=ETA*ones(reg,sec-nbsecteurenergie);
etaDG=ETA*ones(reg,sec-nbsecteurenergie);
etaDI=ETA*ones(reg,sec-nbsecteurenergie);
etaCI=ETA*ones(sec-nbsecteurenergie,sec,reg);


//DESAG_INDUSTRY: here we chose to use the same etaDF, etaDG & etaDI for all industrial sectors (see the factor_increase_ETA_indu at the beginning of this script)
etaDF(:,indice_industries-nbsecteurenergie)=factor_increase_ETA_indu*etaDF(:,indice_industries-nbsecteurenergie);
etaDG(:,indice_industries-nbsecteurenergie)=factor_increase_ETA_indu*etaDG(:,indice_industries-nbsecteurenergie);
etaDI(:,indice_industries-nbsecteurenergie)=factor_increase_ETA_indu*etaDI(:,indice_industries-nbsecteurenergie);
for k=1:reg
    etaCI(indice_industries-nbsecteurenergie,:,k)=factor_increase_ETA_indu*etaCI(indice_industries-nbsecteurenergie,:,k);
end


// initialization of weights
bDF=ones(reg,sec-nbsecteurenergie);
bDG=ones(reg,sec-nbsecteurenergie);
bDI=ones(reg,sec-nbsecteurenergie);
bCI=ones(sec-nbsecteurenergie,sec,reg);

for k=1:reg					// non-zero values are required to avoid errors
    for j=1+nbsecteurenergie:sec
        if DGimpref(k,j)==0 then DGimpref(k,j)=0.00000001; end
        if DIimpref(k,j)==0 then DIimpref(k,j)=0.00000001; end 
    end
end

// explicit expression for Armington weights
bDF=((pref(:,nbsecteurenergie+1:sec).*(1+taxDFdom(:,nbsecteurenergie+1:sec)))./(((ones(reg,1)*wpref(:,nbsecteurenergie+1:sec)).*(1+mtax(:,nbsecteurenergie+1:sec))+(ones(reg,sec-nbsecteurenergie)*wpTIagg).*nit(:,nbsecteurenergie+1:sec)).*(1+taxDFimp(:,nbsecteurenergie+1:sec))).*((DFdomref(:,nbsecteurenergie+1:sec)./DFimpref(:,nbsecteurenergie+1:sec)).^(ones(reg,sec-nbsecteurenergie)./etaDF)))./(1+((pref(:,nbsecteurenergie+1:sec).*(1+taxDFdom(:,nbsecteurenergie+1:sec)))./(((ones(reg,1)*wpref(:,nbsecteurenergie+1:sec)).*(1+mtax(:,nbsecteurenergie+1:sec))+(ones(reg,sec-nbsecteurenergie)*wpTIagg).*nit(:,nbsecteurenergie+1:sec)).*(1+taxDFimp(:,nbsecteurenergie+1:sec)))).*((DFdomref(:,nbsecteurenergie+1:sec)./DFimpref(:,nbsecteurenergie+1:sec)).^(ones(reg,sec-nbsecteurenergie)./etaDF)));
bDG=((pref(:,nbsecteurenergie+1:sec).*(1+taxDGdom(:,nbsecteurenergie+1:sec)))./(((ones(reg,1)*wpref(:,nbsecteurenergie+1:sec)).*(1+mtax(:,nbsecteurenergie+1:sec))+(ones(reg,sec-nbsecteurenergie)*wpTIagg).*nit(:,nbsecteurenergie+1:sec)).*(1+taxDGimp(:,nbsecteurenergie+1:sec))).*((DGdomref(:,nbsecteurenergie+1:sec)./DGimpref(:,nbsecteurenergie+1:sec)).^(ones(reg,sec-nbsecteurenergie)./etaDG)))./(1+((pref(:,nbsecteurenergie+1:sec).*(1+taxDGdom(:,nbsecteurenergie+1:sec)))./(((ones(reg,1)*wpref(:,nbsecteurenergie+1:sec)).*(1+mtax(:,nbsecteurenergie+1:sec))+(ones(reg,sec-nbsecteurenergie)*wpTIagg).*nit(:,nbsecteurenergie+1:sec)).*(1+taxDGimp(:,nbsecteurenergie+1:sec)))).*((DGdomref(:,nbsecteurenergie+1:sec)./DGimpref(:,nbsecteurenergie+1:sec)).^(ones(reg,sec-nbsecteurenergie)./etaDG)));
bDI=((pref(:,nbsecteurenergie+1:sec).*(1+taxDIdom(:,nbsecteurenergie+1:sec)))./(((ones(reg,1)*wpref(:,nbsecteurenergie+1:sec)).*(1+mtax(:,nbsecteurenergie+1:sec))+(ones(reg,sec-nbsecteurenergie)*wpTIagg).*nit(:,nbsecteurenergie+1:sec)).*(1+taxDIimp(:,nbsecteurenergie+1:sec))).*((DIdomref(:,nbsecteurenergie+1:sec)./DIimpref(:,nbsecteurenergie+1:sec)).^(ones(reg,sec-nbsecteurenergie)./etaDI)))./(1+((pref(:,nbsecteurenergie+1:sec).*(1+taxDIdom(:,nbsecteurenergie+1:sec)))./(((ones(reg,1)*wpref(:,nbsecteurenergie+1:sec)).*(1+mtax(:,nbsecteurenergie+1:sec))+(ones(reg,sec-nbsecteurenergie)*wpTIagg).*nit(:,nbsecteurenergie+1:sec)).*(1+taxDIimp(:,nbsecteurenergie+1:sec)))).*((DIdomref(:,nbsecteurenergie+1:sec)./DIimpref(:,nbsecteurenergie+1:sec)).^(ones(reg,sec-nbsecteurenergie)./etaDI)));

for k=1:reg					// back to original zero-values when necessary
    for j=1+nbsecteurenergie:sec
        if DIimpref(k,j)==0.00000001 then DIimpref(k,j)=0; bDI(k,j-nbsecteurenergie)=1; end
        if DGimpref(k,j)==0.00000001 then DGimpref(k,j)=0; bDG(k,j-nbsecteurenergie)=1; end
    end
end


for k=1:reg,					// non-zero values are required to avoid errors
    for k1=1+nbsecteurenergie:sec,
        for k2=1:sec,
            if CIimpref(k1,k2,k)==0 then CIimpref(k1,k2,k)=0.00000001; end
        end
    end
end

for k=1:reg,
    bCI(:,:,k)=(((pref(k,nbsecteurenergie+1:sec)'*ones(1,sec)).*(1+taxCIdom(nbsecteurenergie+1:sec,:,k)))./(((wpref(nbsecteurenergie+1:sec).*(1+mtax(k,nbsecteurenergie+1:sec))+wpTIagg*nit(k,nbsecteurenergie+1:sec))'*ones(1,sec)).*(1+taxCIimp(nbsecteurenergie+1:sec,:,k))).*((CIdomref(nbsecteurenergie+1:sec,:,k)./CIimpref(nbsecteurenergie+1:sec,:,k)).^(ones(sec-nbsecteurenergie,sec)./etaCI(:,:,k))))./(1+(((pref(k,nbsecteurenergie+1:sec)'*ones(1,sec)).*(1+taxCIdom(nbsecteurenergie+1:sec,:,k)))./(((wpref(nbsecteurenergie+1:sec).*(1+mtax(k,nbsecteurenergie+1:sec))+wpTIagg*nit(k,nbsecteurenergie+1:sec))'*ones(1,sec)).*(1+taxCIimp(nbsecteurenergie+1:sec,:,k))).*((CIdomref(nbsecteurenergie+1:sec,:,k)./CIimpref(nbsecteurenergie+1:sec,:,k)).^(ones(sec-nbsecteurenergie,sec)./etaCI(:,:,k)))));
end

for k=1:reg,					// back to original zero-values when necessary
    for k1=nbsecteurenergie+1:sec,	
        for k2=1:sec,
            if CIimpref(k1,k2,k)==0.00000001 then CIimpref(k1,k2,k)=0; bCI(k1-nbsecteurenergie,k2,k)=1; end
        end
    end
end

DFref(:,nbsecteurenergie+1:sec)=(bDF.*(DFdomref(:,nbsecteurenergie+1:sec).^(1-ones(reg,sec-nbsecteurenergie)./etaDF))+(1-bDF).*(DFimpref(:,nbsecteurenergie+1:sec).^(1-ones(reg,sec-nbsecteurenergie)./etaDF))).^(etaDF./(etaDF-1));
DGref(:,nbsecteurenergie+1:sec)=(bDG.*(DGdomref(:,nbsecteurenergie+1:sec).^(1-ones(reg,sec-nbsecteurenergie)./etaDG))+(1-bDG).*(DGimpref(:,nbsecteurenergie+1:sec).^(1-ones(reg,sec-nbsecteurenergie)./etaDG))).^(etaDG./(etaDG-1));
DIref(:,nbsecteurenergie+1:sec)=(bDI.*(DIdomref(:,nbsecteurenergie+1:sec).^(1-ones(reg,sec-nbsecteurenergie)./etaDI))+(1-bDI).*(DIimpref(:,nbsecteurenergie+1:sec).^(1-ones(reg,sec-nbsecteurenergie)./etaDI))).^(etaDI./(etaDI-1));

for k=1:reg,
    CItotref(nbsecteurenergie+1:sec,:,k)=(bCI(:,:,k).*(CIdomref(nbsecteurenergie+1:sec,:,k).^(1-ones(sec-nbsecteurenergie,sec)./etaCI(:,:,k)))+(1-bCI(:,:,k)).*(CIimpref(nbsecteurenergie+1:sec,:,k).^(1-ones(sec-nbsecteurenergie,sec)./etaCI(:,:,k)))).^(etaCI(:,:,k)./(etaCI(:,:,k)-1));
end

DG=DGref;


// output tax

for k=1:reg,
    qtax(k,:)=T_prod_Im(k,:)./(Qref(k,:).*pref(k,:)-T_prod_Im(k,:));
end
qtaxref=qtax;

// unitary intermediate consumption

CIref=zeros(sec,sec,reg);
for k=1:reg,
    CIref(:,:,k)=CItotref(:,:,k)./(ones(sec,1)*Qref(k,:));
end
CI=CIref;
 
