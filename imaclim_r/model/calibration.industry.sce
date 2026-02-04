// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thomas Le-Gallic, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


//rho converts final energy into useful energy 
rhocoal=0.5;
rhooil=0.7;
rhogaz=0.8;
rhoEt=0.7;
rhoelec=1; //rhoelec accounts for electricity, biomass and heat

//composite sector
rhocoal_comp = rhocoal;
rhooil_comp = rhooil;
rhogaz_comp = rhogaz;
rhoEt_comp = rhoEt;
rhoelec_comp = rhoelec;
rhocomposite=[rhocoal_comp;rhooil_comp;rhogaz_comp;rhoEt_comp;rhoelec_comp];

//agriculture sector
rhocoal_agric = rhocoal;
rhooil_agric = rhooil;
rhogaz_agric = rhogaz;
rhoEt_agric = rhoEt;
rhoelec_agric = rhoelec;
rhoagriculture=[rhocoal_agric;rhooil_agric;rhogaz_agric;rhoEt_agric;rhoelec_agric];

//industry sector
rhocoal_ind = rhocoal;
rhooil_ind = rhooil;
rhogaz_ind = rhogaz;
rhoEt_ind = rhoEt;
rhoelec_ind = rhoelec;
rhoindustrie=repmat([rhocoal_ind;rhooil_ind;rhogaz_ind;rhoEt_ind;rhoelec_ind],1,nb_sectors_industry); // DESAG_INDUSTRY: we changed the dimension of this variable to be compatible with several industrial sectors

//Composite sector
Penergieutilecomposite=zeros(reg,4);
for k=1:reg
	Penergieutilecomposite(k,1)=shCIsubs_comp(indice_coal,k)*CItotref(indice_coal,indice_composite,k)*rhocoal/(sum(CItotref(1:5,indice_composite,k).*shCIsubs_comp(:,k).*rhocomposite));
	Penergieutilecomposite(k,2)=((shCIsubs_comp(indice_oil,k)*CItotref(indice_oil,indice_composite,k)+shCIsubs_comp(indice_Et,k)*CItotref(indice_Et,indice_composite,k))*rhooil)/(sum(CItotref(1:5,indice_composite,k).*shCIsubs_comp(:,k).*rhocomposite));
	Penergieutilecomposite(k,3)=shCIsubs_comp(indice_gaz,k)*CItotref(indice_gaz,indice_composite,k)*rhogaz/(sum(CItotref(1:5,indice_composite,k).*shCIsubs_comp(:,k).*rhocomposite));
	Penergieutilecomposite(k,4)=shCIsubs_comp(indice_elec,k)*CItotref(indice_elec,indice_composite,k)*rhoelec/(sum(CItotref(1:5,indice_composite,k).*shCIsubs_comp(:,k).*rhocomposite));
end

Pcoal_comp_Edeltaref=Penergieutilecomposite(:,1);
PEt_comp_Edeltaref=Penergieutilecomposite(:,2);
Pgaz_comp_Edeltaref=Penergieutilecomposite(:,3);
Pelec_comp_Edeltaref=Penergieutilecomposite(:,4);

//Agriculture sector

Penergieutileagric=zeros(reg,4);
for k=1:reg
	Penergieutileagric(k,1)=shCIsubs_agri(indice_coal,k)*CItotref(indice_coal,indice_agriculture,k)*rhocoal/(sum(CItotref(1:5,indice_agriculture,k).*shCIsubs_agri(:,k).*rhoagriculture));
	Penergieutileagric(k,2)=((shCIsubs_agri(indice_oil,k)*CItotref(indice_oil,indice_agriculture,k)+shCIsubs_agri(indice_Et,k)*CItotref(indice_Et,indice_agriculture,k))*rhooil)/(sum(CItotref(1:5,indice_agriculture,k).*shCIsubs_agri(:,k).*rhoagriculture));
	Penergieutileagric(k,3)=shCIsubs_agri(indice_gaz,k)*CItotref(indice_gaz,indice_agriculture,k)*rhogaz/(sum(CItotref(1:5,indice_agriculture,k).*shCIsubs_agri(:,k).*rhoagriculture));
	Penergieutileagric(k,4)=shCIsubs_agri(indice_elec,k)*CItotref(indice_elec,indice_agriculture,k)*rhoelec/(sum(CItotref(1:5,indice_agriculture,k).*shCIsubs_agri(:,k).*rhoagriculture));
end

Pcoal_agric_Edeltaref=Penergieutileagric(:,1);
PEt_agric_Edeltaref=Penergieutileagric(:,2);
Pgaz_agric_Edeltaref=Penergieutileagric(:,3);
Pelec_agric_Edeltaref=Penergieutileagric(:,4);

// Industry sector

Penergieutileind=zeros(reg,nb_sectors_industry,4);
for k=1:reg
	indice_Penergieutil_zero = sum(CItotref(1:5,indice_industries,k).*shCIsubs_indu(:,:,k).*rhoindustrie,'r')==0;
	indice_Penergieutil_temp = sum(CItotref(1:5,indice_industries,k).*shCIsubs_indu(:,:,k).*rhoindustrie,'r')<>0;
	indice_industries_zero=indice_industries(sum(CItotref(1:5,indice_industries,k).*shCIsubs_indu(:,:,k).*rhoindustrie,'r')==0);
	indice_industries_temp=indice_industries(sum(CItotref(1:5,indice_industries,k).*shCIsubs_indu(:,:,k).*rhoindustrie,'r')<>0);
	if size(indice_industries_zero,"*") <> 0 // DESAG_INDUSTRY: We assume an equal share when we can't calibrate on existing values... the problem appeared for India (at least) and would need to check the data
	Penergieutileind(k,indice_Penergieutil_zero,:)=0.25*ones(size(indice_industries_zero,"*"),4);
	end
	//we don't consider the case when indice_industries_temp is null (never happens with current data)
	
	Penergieutileind(k,indice_Penergieutil_temp,1)=shCIsubs_indu(indice_coal,indice_Penergieutil_temp,k)	.*CItotref(indice_coal,indice_industries_temp,k)*rhocoal./(sum(CItotref(1:5,indice_industries_temp,k).*shCIsubs_indu(:,indice_Penergieutil_temp,k).*rhoindustrie(:,indice_Penergieutil_temp),'r'));
	Penergieutileind(k,indice_Penergieutil_temp,2)=((shCIsubs_indu(indice_oil,indice_Penergieutil_temp,k)	.*CItotref(indice_oil,indice_industries_temp,k)+shCIsubs_indu(indice_Et,indice_Penergieutil_temp,k).*CItotref(indice_Et,indice_industries_temp,k))*rhooil)./(sum(CItotref(1:5,indice_industries_temp,k).*shCIsubs_indu(:,indice_Penergieutil_temp,k).*rhoindustrie(:,indice_Penergieutil_temp),'r'));
	Penergieutileind(k,indice_Penergieutil_temp,3)=shCIsubs_indu(indice_gaz,indice_Penergieutil_temp,k)	.*CItotref(indice_gaz,indice_industries_temp,k)*rhogaz./(sum(CItotref(1:5,indice_industries_temp,k).*shCIsubs_indu(:,indice_Penergieutil_temp,k).*rhoindustrie(:,indice_Penergieutil_temp),'r'));
	Penergieutileind(k,indice_Penergieutil_temp,4)=shCIsubs_indu(indice_elec,indice_Penergieutil_temp,k)	.*CItotref(indice_elec,indice_industries_temp,k)*rhoelec./(sum(CItotref(1:5,indice_industries_temp,k).*shCIsubs_indu(:,indice_Penergieutil_temp,k).*rhoindustrie(:,indice_Penergieutil_temp),'r'));
	
end

Pcoal_ind_Edeltaref=Penergieutileind(:,:,1);
PEt_ind_Edeltaref=Penergieutileind(:,:,2);
Pgaz_ind_Edeltaref=Penergieutileind(:,:,3);
Pelec_ind_Edeltaref=Penergieutileind(:,:,4);
