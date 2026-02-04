//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////secteur services
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

CRF_ser=disc_ser./(1-(1+disc_ser).^(-Life_time_ser));

p_coal_ser_anticip=zeros(nb_regions,Life_time_ser);
p_gaz_ser_anticip=zeros(nb_regions,Life_time_ser);
p_Et_ser_anticip=zeros(nb_regions,Life_time_ser);
p_elec_ser_anticip=zeros(nb_regions,Life_time_ser);
for k=1:nb_regions
    for j=1:Life_time_ser
        pArmCIantTxCO2ser_temp=matrix(pArmCI_anticip_taxCO2(:,j),nb_sectors,nb_sectors,nb_regions);
        p_coal_ser_anticip(k,j)=  pArmCIantTxCO2ser_temp(indice_coal,indice_composite,k);
        p_gaz_ser_anticip(k,j)=  pArmCIantTxCO2ser_temp(indice_gaz ,indice_composite,k);
        p_Et_ser_anticip(k,j)=  pArmCIantTxCO2ser_temp(indice_Et  ,indice_composite,k);
        p_elec_ser_anticip(k,j)=  pArmCIantTxCO2ser_temp(indice_elec,indice_composite,k);
    end
end

//calcul du cout total actualisé énergétique la duree de vie des équipements résidentiel
CFuel_ser_BAU=zeros(nb_regions,1);
CFuel_ser_TAX=zeros(nb_regions,1);
for k=1:nb_regions
    for t=1:Life_time_ser
        CFuel_ser_BAU(k)=CFuel_ser_BAU(k)+CIdeltacomposite_BAU(indice_coal,indice_composite,k)*p_coal_ser_anticip(k,j)/((1+disc_ser)^t)*CRF_ser+...
        CIdeltacomposite_BAU(indice_gaz ,indice_composite,k)* p_gaz_ser_anticip(k,j)/((1+disc_ser)^t)*CRF_ser+...
        CIdeltacomposite_BAU(indice_Et  ,indice_composite,k)*  p_Et_ser_anticip(k,j)/((1+disc_ser)^t)*CRF_ser+...
        CIdeltacomposite_BAU(indice_elec,indice_composite,k)*p_elec_ser_anticip(k,j)/((1+disc_ser)^t)*CRF_ser;

        CFuel_ser_TAX(k)=CFuel_ser_TAX(k)+CIdeltacomposite(    indice_coal,indice_composite,k)*p_coal_ser_anticip(k,j)/((1+disc_ser)^t)*CRF_ser+...
        CIdeltacomposite(    indice_gaz ,indice_composite,k)* p_gaz_ser_anticip(k,j)/((1+disc_ser)^t)*CRF_ser+...
        CIdeltacomposite(    indice_Et  ,indice_composite,k)*  p_Et_ser_anticip(k,j)/((1+disc_ser)^t)*CRF_ser+...
        CIdeltacomposite(    indice_elec,indice_composite,k)*p_elec_ser_anticip(k,j)/((1+disc_ser)^t)*CRF_ser;
    end
end

K_ser_TAX=1/CRF_ser*(CFuel_ser_BAU-CFuel_ser_TAX);

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////secteur Industrie
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

CRF_ind=disc_ind./(1-(1+disc_ind).^(-Life_time_ind)); //MULTISECTOR: we assume the same CRF for all industrial sector. This assumption should be double-checked.

p_coal_ind_anticip=zeros(nb_regions,nb_sectors_industry,Life_time_ind);
p_gaz_ind_anticip=zeros(nb_regions,nb_sectors_industry,Life_time_ind);
p_Et_ind_anticip=zeros(nb_regions,nb_sectors_industry,Life_time_ind);
p_elec_ind_anticip=zeros(nb_regions,nb_sectors_industry,Life_time_ind);
for k=1:nb_regions
    for j=1:Life_time_ind
        pArmDFantTxCO2ind_temp=matrix(pArmCI_anticip_taxCO2(:,j),nb_sectors,nb_sectors,nb_regions);
        p_coal_ind_anticip(k,:,j)=  pArmDFantTxCO2ind_temp(indice_coal,indice_industries,k);
        p_gaz_ind_anticip(k,:,j)=  pArmDFantTxCO2ind_temp(indice_gaz ,indice_industries,k);
        p_Et_ind_anticip(k,:,j)=  pArmDFantTxCO2ind_temp(indice_Et  ,indice_industries,k);
        p_elec_ind_anticip(k,:,j)=  pArmDFantTxCO2ind_temp(indice_elec,indice_industries,k);
    end
end

//calcul du cout total actualisé énergétique la duree de vie des équipements industriels.
CFuel_ind_BAU=zeros(nb_regions,nb_sectors_industry);
CFuel_ind_TAX=zeros(nb_regions,nb_sectors_industry);
for k=1:nb_regions
    for t=1:Life_time_ind
		for i=1:nb_sectors_industry
			CFuel_ind_BAU(k,i)=CFuel_ind_BAU(k,i)+CIdeltacomposite_BAU(indice_coal,indice_industries(i),k)*p_coal_ind_anticip(k,i,j)/((1+disc_ind)^t)*CRF_ind+...
			CIdeltacomposite_BAU(indice_gaz ,indice_industries(i),k)* p_gaz_ind_anticip(k,i,j)/((1+disc_ind)^t)*CRF_ind+...
			CIdeltacomposite_BAU(indice_Et  ,indice_industries(i),k)*  p_Et_ind_anticip(k,i,j)/((1+disc_ind)^t)*CRF_ind+...
			CIdeltacomposite_BAU(indice_elec,indice_industries(i),k)*p_elec_ind_anticip(k,i,j)/((1+disc_ind)^t)*CRF_ind;

			CFuel_ind_TAX(k,i)=CFuel_ind_TAX(k,i)+CIdeltacomposite(indice_coal,indice_industries(i),k)*p_coal_ind_anticip(k,i,j)/((1+disc_ind)^t)*CRF_ind+...
			CIdeltacomposite(indice_gaz ,indice_industries(i),k)* p_gaz_ind_anticip(k,i,j)/((1+disc_ind)^t)*CRF_ind+...
			CIdeltacomposite(indice_Et  ,indice_industries(i),k)*  p_Et_ind_anticip(k,i,j)/((1+disc_ind)^t)*CRF_ind+...
			CIdeltacomposite(indice_elec,indice_industries(i),k)*p_elec_ind_anticip(k,i,j)/((1+disc_ind)^t)*CRF_ind;
		end
	end
end

K_ind_TAX=1/CRF_ind*(CFuel_ind_BAU-CFuel_ind_TAX);

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////secteur Agriculture
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

CRF_agr=disc_agr./(1-(1+disc_agr).^(-Life_time_agr));

p_coal_agr_anticip=zeros(nb_regions,Life_time_agr);
p_gaz_agr_anticip=zeros(nb_regions,Life_time_agr);
p_Et_agr_anticip=zeros(nb_regions,Life_time_agr);
p_elec_agr_anticip=zeros(nb_regions,Life_time_agr);
for k=1:nb_regions
    for j=1:Life_time_agr
        pArmCIantTxCO2agr_temp=matrix(pArmCI_anticip_taxCO2(:,j),nb_sectors,nb_sectors,nb_regions);
        p_coal_agr_anticip(k,j)=  pArmCIantTxCO2agr_temp(indice_coal,indice_agriculture,k);
        p_gaz_agr_anticip(k,j)=  pArmCIantTxCO2agr_temp(indice_gaz ,indice_agriculture,k);
        p_Et_agr_anticip(k,j)=  pArmCIantTxCO2agr_temp(indice_Et  ,indice_agriculture,k);
        p_elec_agr_anticip(k,j)=  pArmCIantTxCO2agr_temp(indice_elec,indice_agriculture,k);
    end
end

//calcul du cout total actualisé énergétique la duree de vie des équipements agricoles
CFuel_agr_BAU=zeros(nb_regions,1);
CFuel_agr_TAX=zeros(nb_regions,1);
for k=1:nb_regions
    for t=1:Life_time_agr
        CFuel_agr_BAU(k)=CFuel_agr_BAU(k)+CIdeltacomposite_BAU(indice_coal,indice_agriculture,k)*p_coal_agr_anticip(k,j)/((1+disc_agr)^t)*CRF_agr+...
        CIdeltacomposite_BAU(indice_gaz ,indice_agriculture,k)* p_gaz_agr_anticip(k,j)/((1+disc_agr)^t)*CRF_agr+...
        CIdeltacomposite_BAU(indice_Et  ,indice_agriculture,k)*  p_Et_agr_anticip(k,j)/((1+disc_agr)^t)*CRF_agr+...
        CIdeltacomposite_BAU(indice_elec,indice_agriculture,k)*p_elec_agr_anticip(k,j)/((1+disc_agr)^t)*CRF_agr;

        CFuel_agr_TAX(k)=CFuel_agr_TAX(k)+CIdeltacomposite(    indice_coal,indice_agriculture,k)*p_coal_agr_anticip(k,j)/((1+disc_agr)^t)*CRF_agr+...
        CIdeltacomposite(    indice_gaz ,indice_agriculture,k)* p_gaz_agr_anticip(k,j)/((1+disc_agr)^t)*CRF_agr+...
        CIdeltacomposite(    indice_Et  ,indice_agriculture,k)*  p_Et_agr_anticip(k,j)/((1+disc_agr)^t)*CRF_agr+...
        CIdeltacomposite(    indice_elec,indice_agriculture,k)*p_elec_agr_anticip(k,j)/((1+disc_agr)^t)*CRF_agr;
    end
end

K_agr_TAX=1/CRF_agr*(CFuel_agr_BAU-CFuel_agr_TAX);

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////secteur construction
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

CRF_btp=disc_btp./(1-(1+disc_btp).^(-Life_time_btp));

p_coal_btp_anticip=zeros(nb_regions,Life_time_btp);
p_gaz_btp_anticip=zeros(nb_regions,Life_time_btp);
p_Et_btp_anticip=zeros(nb_regions,Life_time_btp);
p_elec_btp_anticip=zeros(nb_regions,Life_time_btp);
for k=1:nb_regions
    for j=1:Life_time_btp
        pArmCIantTxCO2btp_temp=matrix(pArmCI_anticip_taxCO2(:,j),nb_sectors,nb_sectors,nb_regions);
        p_coal_btp_anticip(k,j)=  pArmCIantTxCO2btp_temp(indice_coal,indice_construction,k);
        p_gaz_btp_anticip(k,j)=  pArmCIantTxCO2btp_temp(indice_gaz ,indice_construction,k);
        p_Et_btp_anticip(k,j)=  pArmCIantTxCO2btp_temp(indice_Et  ,indice_construction,k);
        p_elec_btp_anticip(k,j)=  pArmCIantTxCO2btp_temp(indice_elec,indice_construction,k);
    end
end

//calcul du cout total actualisé énergétique la duree de vie des équipements
CFuel_btp_BAU=zeros(nb_regions,1);
CFuel_btp_TAX=zeros(nb_regions,1);
for k=1:nb_regions
    for t=1:Life_time_btp
        CFuel_btp_BAU(k)=CFuel_btp_BAU(k)+CIdeltacomposite_BAU(indice_coal,indice_construction,k)*p_coal_btp_anticip(k,j)/((1+disc_btp)^t)*CRF_btp+...
        CIdeltacomposite_BAU(indice_gaz ,indice_construction,k)* p_gaz_btp_anticip(k,j)/((1+disc_btp)^t)*CRF_btp+...
        CIdeltacomposite_BAU(indice_Et  ,indice_construction,k)*  p_Et_btp_anticip(k,j)/((1+disc_btp)^t)*CRF_btp+...
        CIdeltacomposite_BAU(indice_elec,indice_construction,k)*p_elec_btp_anticip(k,j)/((1+disc_btp)^t)*CRF_btp;

        CFuel_btp_TAX(k)=CFuel_btp_TAX(k)+CIdeltacomposite(    indice_coal,indice_construction,k)*p_coal_btp_anticip(k,j)/((1+disc_btp)^t)*CRF_btp+...
        CIdeltacomposite(    indice_gaz ,indice_construction,k)* p_gaz_btp_anticip(k,j)/((1+disc_btp)^t)*CRF_btp+...
        CIdeltacomposite(    indice_Et  ,indice_construction,k)*  p_Et_btp_anticip(k,j)/((1+disc_btp)^t)*CRF_btp+...
        CIdeltacomposite(    indice_elec,indice_construction,k)*p_elec_btp_anticip(k,j)/((1+disc_btp)^t)*CRF_btp;
    end
end

K_btp_TAX=1/CRF_btp*(CFuel_btp_BAU-CFuel_btp_TAX);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////Cout en capital de l'efficacité énergétique

K_cost_ser_TAX=max(  DeltaK(:,indice_composite).*K_ser_TAX.*  charge(:,indice_composite),0);
K_cost_ind_TAX=max(  DeltaK(:,indice_industries).*K_ind_TAX.*  charge(:,indice_industries),0);
K_cost_agr_TAX=max(DeltaK(:,indice_agriculture).*K_agr_TAX.*charge(:,indice_agriculture),0);
K_cost_btp_TAX=max(DeltaK(:,indice_construction).*K_btp_TAX.*charge(:,indice_construction),0);


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////Répercussion des investissements d'efficacité énergétique dans l'equilibre général
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////
//Energy efficiency
//////////////////////////

delta_markup_EE_ser_prev=delta_markup_EE_ser;
delta_markup_EE_ind_prev=delta_markup_EE_ind;
delta_markup_EE_agr_prev=delta_markup_EE_agr;
delta_markup_EE_btp_prev=delta_markup_EE_btp;

//on répercute le cout de l'investissement sur le markup
delta_markup_EE_ser=K_cost_ser_TAX./(p(:,indice_composite).*  (Q(:,indice_composite)    .*taux_Q_nexus(:,indice_composite)  ));
delta_markup_EE_ind=K_cost_ind_TAX./(p(:,indice_industries).*  (Q(:,indice_industries)    .*taux_Q_nexus(:,indice_industries)  ));
delta_markup_EE_agr=K_cost_agr_TAX./(p(:,indice_agriculture).*(Q(:,indice_agriculture)  .*taux_Q_nexus(:,indice_agriculture)));
delta_markup_EE_btp=K_cost_btp_TAX./(p(:,indice_construction).*(Q(:,indice_construction).*taux_Q_nexus(:,indice_construction)));

//on met de l'inertie
delta_markup_EE_ser=1/3*delta_markup_EE_ser+2/3*delta_markup_EE_ser_prev;
delta_markup_EE_ind=1/3*delta_markup_EE_ind+2/3*delta_markup_EE_ind_prev;
delta_markup_EE_agr=1/3*delta_markup_EE_agr+2/3*delta_markup_EE_agr_prev;
delta_markup_EE_btp=1/3*delta_markup_EE_btp+2/3*delta_markup_EE_btp_prev;

//modification des coefficients
markup(:,indice_composite)   =markupref(:,indice_composite)  +delta_markup_EE_ser;
markup(:,indice_industries)   =markupref(:,indice_industries)  +delta_markup_EE_ind;
markup(:,indice_agriculture) =markupref(:,indice_agriculture)+delta_markup_EE_agr;
markup(:,indice_construction)=markupref(:,indice_construction)+delta_markup_EE_btp;

markup=max(markup,0.0001);
