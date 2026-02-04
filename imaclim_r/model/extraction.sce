// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Adrien Vogt-Schilb, Nicolas Graves, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

error("This file is outdated => check before use");
///////////////////////////////////////////////////////////////////////////////////////
exec("get_all_sg_var.sce");
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////

for current_time_im=1:TimeHorizon+1
  Tair(:,current_time_im)=alphaair(:,current_time_im).*Tair(:,current_time_im);
  TOT(:,current_time_im)=alphaOT(:,current_time_im).*TOT(:,current_time_im);
end
/////////////////////////////////////////////
// nexus électrique
///////////////////////////////////////////
 
 Cap_elec_MW_reg_tech=zeros(reg*techno_elec,TimeHorizon+1);
 for j_time=1:TimeHorizon+1
	 Cap_elec_MW_temp=matrix(Cap_elec_MW(:,j_time),reg,techno_elec);
	 Cap_elec_MW_reg_tech_tmp=zeros(techno_elec,reg);
	 for k=1:reg
	 	for j=1:techno_elec
	 		Cap_elec_MW_reg_tech_tmp(j,k)=Cap_elec_MW_temp(k,j);
	 	end
	 end
	 Cap_elec_MW_reg_tech(:,j_time)=matrix(Cap_elec_MW_reg_tech_tmp,reg*techno_elec,1);
 end
 
 
cum_INV_MW_CCS1=zeros(1,TimeHorizon+1);
cum_INV_MW_CCS2=zeros(1,TimeHorizon+1);
cum_INV_MW_CCS3=zeros(1,TimeHorizon+1);
cum_INV_MW_ENR1=zeros(1,TimeHorizon+1);
cum_INV_MW_ENR2=zeros(1,TimeHorizon+1);
 Inv_elec_MW_reg_tech=zeros(reg*techno_elec,TimeHorizon+1);
 for j_time=1:TimeHorizon+1
	 Inv_elec_MW_temp=matrix(Inv_MW(:,j_time),reg,techno_elec);
	 Inv_elec_MW_reg_tech_tmp=zeros(techno_elec,reg);
	 for k=1:reg
	 	for j=1:techno_elec
	 		Inv_elec_MW_reg_tech_tmp(j,k)=Inv_elec_MW_temp(k,j);
	 	end
	 end
	 Inv_elec_MW_reg_tech(:,j_time)=matrix(Inv_elec_MW_reg_tech_tmp,reg*techno_elec,1);
	 cum_INV_MW_CCS1(j_time)=cum_INV_MW_CCS1(max(j_time-1,1))+sum(Inv_elec_MW_temp(:,indice_PSS),"r");
     cum_INV_MW_CCS2(j_time)=cum_INV_MW_CCS2(max(j_time-1,1))+sum(Inv_elec_MW_temp(:,indice_CGS),"r");
     cum_INV_MW_CCS3(j_time)=cum_INV_MW_CCS3(max(j_time-1,1))+sum(Inv_elec_MW_temp(:,indice_GGS),"r");
     cum_INV_MW_ENR1(j_time)=cum_INV_MW_ENR1(max(j_time-1,1))+sum(Inv_elec_MW_temp(:,indice_WND),"r");
     cum_INV_MW_ENR2(j_time)=cum_INV_MW_ENR2(max(j_time-1,1))+sum(Inv_elec_MW_temp(:,indice_WNO),"r");
 end
 
mkcsv( "Cap_elec_MW_reg_tech");
mkcsv( "Inv_elec_MW_reg_tech");

ldsav("CINV_MW_nexus_sav");
CINV_MW_CCS1=zeros(1,TimeHorizon+1);
CINV_MW_CCS2=zeros(1,TimeHorizon+1);
CINV_MW_CCS3=zeros(1,TimeHorizon+1);
CINV_MW_ENR1=zeros(1,TimeHorizon+1);
CINV_MW_ENR2=zeros(1,TimeHorizon+1);

 CINV_MW_nexus_reg_tech=zeros(reg*techno_elec,TimeHorizon+1);
 for j_time=1:TimeHorizon+1
	 CINV_MW_nexus_temp=matrix(CINV_MW_nexus_sav(:,j_time),reg,techno_elec);
	 CInvMWnexusRegTechTemp=zeros(techno_elec,reg);
	 for k=1:reg
	 	for j=1:techno_elec
	 		CInvMWnexusRegTechTemp(j,k)=CINV_MW_nexus_temp(k,j);
	 	end
	 end
	 CINV_MW_nexus_reg_tech(:,j_time)=matrix(CInvMWnexusRegTechTemp,reg*techno_elec,1);
	 CINV_MW_CCS1(j_time)=CINV_MW_nexus_temp(1,indice_PSS);
     CINV_MW_CCS2(j_time)=CINV_MW_nexus_temp(1,indice_CGS);
     CINV_MW_CCS3(j_time)=CINV_MW_nexus_temp(1,indice_GGS);
     CINV_MW_ENR1(j_time)=CINV_MW_nexus_temp(1,indice_WND);
     CINV_MW_ENR2(j_time)=CINV_MW_nexus_temp(1,indice_WNO);
 end
 
mkcsv( "CINV_MW_nexus_reg_tech");

//fprintfMat(SAVEDIR+"capacites_oil.tsv",capacites_oil,format_spec);
//fprintfMat(SAVEDIR+"Cap_MO_t.tsv",Cap_MO_t,format_spec);

/////////////////////////////////////////////
// nexus automobile
///////////////////////////////////////////
ldsav(	"stockVintageAutoTechno.sav");
ldsav(  "LCC_cars_sav.sav");
ldsav("CFuel_cars_sav.sav");
ldsav("MSH_cars_sav.sav");
ldsav(  "CINV_cars_nexus_sav.sav");
ldsav(	 "stock_car_ventile");
ldsav("apprent_car");
Cum_Inv_cars_extract=zeros(nb_techno_cars,TimeHorizon+1);
stock_car_ventile_EUR=zeros(nb_techno_cars,TimeHorizon+1);
stock_v_auto_reg_tech=zeros(reg*nb_techno_cars,TimeHorizon+1);

 for j_time=1:TimeHorizon+1
 	 stock_v_auto_temp=stockVintageAutoTechno(:,:,j_time);
	 if j_time>1 then Cum_Inv_cars_extract(:,j_time)=Cum_Inv_cars_extract(:,j_time-1)+sum(stockVintageAutoTechno(:,:,j_time),"r")'; end
	 stockautotemp=zeros(nb_techno_cars,reg);
	 for k=1:reg
	 	for j=1:nb_techno_cars
	 		stockautotemp(j,k)=stock_v_auto_temp(k,j);
	 	end
	 end
	 stock_car_ventile_EUR(:,j_time)=stock_car_ventile(3,:,j_time)';
	 stock_v_auto_reg_tech(:,j_time)=matrix(stockautotemp,reg*nb_techno_cars,1);
 end
 
mkcsv( "stock_v_auto_reg_tech");




/////////////////////////////////////////////
// numéraire
///////////////////////////////////////////

mer=zeros(reg,TimeHorizon+1);
mer=p(6*reg+1:7*reg,:);
norm_mer=[mer;mer;mer;mer;mer;mer;mer;mer;mer;mer;mer;mer];
num=p(6*reg+1,:);

p_n=p./(ones(reg*sec,1)*num);
p_dom=p./norm_mer;
wp_n=wp./(ones(sec,1)*num);
wpTI_n=wpTI./(ones(3,1)*num);

///////////////////////////////////////
// Macro
///////////////////////////////////////
warning("fixme: GDPs are not using the new implementation: OBSOLETE");
/////calcul de l'indice des quantités de Lapeyres

//realGDP_lapeyres_Quant=zeros(reg,TimeHorizon+1);
xtax_all=xtax;
for k=1:TimeHorizon+1
	DF_temp=matrix(DF(:,k),reg,sec);
	DI_temp=matrix(DI(:,k),reg,sec);
	DG_temp=DGref.*((Ltot(:,k)./Ltot(:,1))*ones(1,sec));
	Exp_temp=matrix(Exp(:,k),reg,sec);
	Imp_temp=matrix(Imp(:,k),reg,sec);
    xtax = matrix(xtax_all(:,k),reg,sec)
	//realGDP_lapeyres_Quant(:,k)=(sum(pArmDFref.*DF_temp+pArmDGref.*DG_temp+pArmDIref.*DI_temp,"c")+sum(Exp_temp.*pref.*(1+xtax)+-Imp_temp.*((ones(reg,1)*wpref).*(1)),"c"))./(sum(pArmDFref.*DFref+pArmDGref.*DGref+pArmDIref.*DIref,"c")+sum(Expref.*pref.*(1+xtax)-Impref.*((ones(reg,1)*wpref).*(1)),"c")).*GDP_IMF_PPA;
end
//realGDP_lapeyres_Quant_rate=zeros(reg,TimeHorizon+1);
//realGDP_lapeyres_Quant_rate(:,2:TimeHorizon+1)=(realGDP_lapeyres_Quant(:,2:TimeHorizon+1)-realGDP_lapeyres_Quant(:,1:TimeHorizon))./realGDP_lapeyres_Quant(:,1:TimeHorizon);
// fprintfMat(SAVEDIR+"output_these\"+"realGDP_lapeyres_Quant.tsv",realGDP_lapeyres_Quant,format_spec);
// save(MODEL+"output_these\"+"realGDP_lapeyres_Quant.sav",realGDP_lapeyres_Quant);

//production price index
  pind_prod_n=(pind_prod./(ones(reg,1)*num));

// nominal GDP
//GDP_n=GDP./(ones(reg,1)*num);
//GDPrate=zeros(reg,TimeHorizon);
//GDPrate=(GDP_n(:,2:TimeHorizon+1)-GDP_n(:,1:TimeHorizon))./GDP_n(:,1:TimeHorizon);

// Price index
price_index=zeros(reg,TimeHorizon+1);
for j=1:TimeHorizon+1
	DFtemp=matrix(DF(:,j),reg,sec);
	pArmDFtemp=matrix(pArmDF(:,j),reg,sec);
	price_index(:,j)=(sum(pArmDFtemp.*DFtemp,"c")./sum(pArmDFref.*DFtemp,"c").*sum(pArmDFtemp.*DFref,"c")./sum(pArmDFref.*DFref,"c"))^(1/2);
end

norm_price_index =[price_index;price_index;price_index;price_index;price_index;price_index;price_index;price_index;price_index;price_index;price_index;price_index];

// The following code is obsolete and should be adjusted with new GDP computation
// real GDP 
//realGDP=GDP./price_index;
//realGDP=realGDP_lapeyres_Quant;
//realGDPrate=zeros(reg,TimeHorizon+1);
//realGDPrate(:,2:TimeHorizon+1)=(realGDP(:,2:TimeHorizon+1)-realGDP(:,1:TimeHorizon))./realGDP(:,1:TimeHorizon);
//realGDP_pc=realGDP./Ltot;

//GDP_IMF_base=zeros(reg,TimeHorizon+1);
//GDP_IMF_base(:,1)=GDP_IMF_PPA;
//for j=2:TimeHorizon+1
//	GDP_IMF_base(:,j)=GDP_IMF_base(:,j-1).*(1+realGDPrate(:,j));
//end
//GDP_IMF_base_world=sum(GDP_IMF_base,"r");
//(GDP_IMF_base_world($)/GDP_IMF_base_world(1))^(1/(TimeHorizon-1));
//GDP_IMF_base_pc=GDP_IMF_base./Ltot;

// VA reelle
//VA_n=VA./(ones(reg*sec,1)*num);
//VA_real=VA./norm_price_index;

// DF composite

DFcomp=DF(6*reg+1:6*reg+12,:);
DFComppc=DFcomp./Ltot;

// Capital flows
KBal_n=NRB./(ones(reg,1)*p(6*reg+1,:))-GRB./(ones(reg,1)*p(6*reg+1,:));

// exports and imports values

Exp_val_n=Exp.*p_n.*(1+xtax_all);
wp_mult_n=[ones(reg,1)*wp_n(1,:);ones(reg,1)*wp_n(2,:);ones(reg,1)*wp_n(3,:);ones(reg,1)*wp_n(4,:);ones(reg,1)*wp_n(5,:);ones(reg,1)*wp_n(6,:);ones(reg,1)*wp_n(7,:);ones(reg,1)*wp_n(8,:);ones(reg,1)*wp_n(9,:);ones(reg,1)*wp_n(10,:);ones(reg,1)*wp_n(11,:);ones(reg,1)*wp_n(12,:)];
Imp_val_n=Imp.*wp_mult_n;

// total sector investments

Invtot_n=zeros(reg*sec,TimeHorizon+1);
for current_time_im=1:TimeHorizon+1
	partInvFin_temp=matrix(partInvFin(:,current_time_im),reg,sec);
	Invtot_temp=zeros(reg,sec);
	for j=1:sec,
		for k=1:reg
		Invtot_temp(k,j)=partInvFin_temp(k,j)*(NRB(k,current_time_im)- sum(pArmDI(k,:,current_time_im).*DIinfra(k,:,current_time_im)))./(num(current_time_im));	
		end
	end
	Invtot_n(:,current_time_im)=matrix(Invtot_temp,reg*sec,1);
end

///////////////////////////////////////
// Energie
///////////////////////////////////////

Conso_sec=zeros(nbsecteurenergie*sec*reg,TimeHorizon+1);
intensite_ener_comp=zeros(reg,TimeHorizon+1);
intensite_ener_agric=zeros(reg,TimeHorizon+1);
intensite_ener_ind=zeros(reg,TimeHorizon+1);

for k=1:reg,
	for j=1:sec,
	Conso_sec(nbsecteurenergie*sec*(k-1)+nbsecteurenergie*(j-1)+1:nbsecteurenergie*sec*(k-1)+nbsecteurenergie*j,:)=CI(sec*sec*(k-1)+sec*(j-1)+1:sec*sec*(k-1)+sec*(j-1)+5,:).*(ones(nbsecteurenergie,1)*Q(k+(j-1)*reg,:));
	end	
	intensite_ener_comp(k,:)=sum(CI(sec*sec*(k-1)+sec*(indice_composite-1)+1:sec*sec*(k-1)+sec*(indice_composite-1)+5,:),"r");
	intensite_ener_agric(k,:)=sum(CI(sec*sec*(k-1)+sec*(indice_agriculture-1)+1:sec*sec*(k-1)+sec*(indice_agriculture-1)+5,:),"r");
	intensite_ener_ind(k,:)=sum(CI(sec*sec*(k-1)+sec*(indice_industrie-1)+1:sec*sec*(k-1)+sec*(indice_industrie-1)+5,:),"r");
end

alphaCoalm2=zeros(reg,TimeHorizon+1);
alphaEtm2  =zeros(reg,TimeHorizon+1);
alphaGazm2 =zeros(reg,TimeHorizon+1);
alphaelecm2=zeros(reg,TimeHorizon+1);

for j=1:TimeHorizon+1
	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
	for k=1:reg
		 conso_res_oil(k,j)=Energy_balance_temp(16,3,k);
		conso_res_coal(k,j)=Energy_balance_temp(16,1,k);
		 conso_res_gaz(k,j)=Energy_balance_temp(16,4,k);
		conso_res_elec(k,j)=Energy_balance_temp(16,8,k);
		alphaCoalm2(k,j)=Energy_balance_temp(16,1,k)/stockbatiment(k,j);
		alphaEtm2(k,j)  =Energy_balance_temp(16,3,k)/stockbatiment(k,j);
		alphaGazm2(k,j) =Energy_balance_temp(16,4,k)/stockbatiment(k,j);
		alphaelecm2(k,j)=Energy_balance_temp(16,8,k)/stockbatiment(k,j);
	end
end

///////////////Consommation d'énergie des secteurs transport:
conso_ELE_OTT=zeros(reg,TimeHorizon+1); //élec dans OT
conso_LFU_OTT=zeros(reg,TimeHorizon+1); //carburants liquides dans OT
for j=1:TimeHorizon+1
	Q_temp=matrix(Q(:,j),reg,sec);
	CI_temp=matrix(CI(:,j),sec,sec,reg);
	for k=1:reg
		conso_ELE_OTT(k,j)=CI_temp(indice_elec,indice_OT,k)*Q_temp(k,indice_OT);         //élec dans OT                        
		conso_LFU_OTT(k,j)=CI_temp(indice_Et,indice_OT,k)*Q_temp(k,indice_OT);         //carburants liquides dans OT
	end
end

// stock batiment par tête
m2batiment=stockbatiment.*((m2batimentref./stockbatimentref)*ones(1,TimeHorizon+1));

DG_ener=zeros(reg*nbsecteurenergie,TimeHorizon+1);
DG_ener=(matrix(DGref(:,1:nbsecteurenergie),reg*nbsecteurenergie,1)*ones(1,TimeHorizon+1)).*[Ltot;Ltot;Ltot;Ltot;Ltot]./([Ltot0;Ltot0;Ltot0;Ltot0;Ltot0]*ones(1,TimeHorizon+1));

///////////////////////////////
///////paramètres de la fonction d'utilité
///////////////////////////////

ldsav( "xsi_sav.sav");
Rdisp_xsi=(Rdisp./pind)./(pref(:,indice_composite)*ones(1,TimeHorizon+1));
// output_xsi=[Rdisp_xsi;
// xsi_sav];
// fprintfMat(SAVEDIR+"output_xsi.tsv",output_xsi,"%5.8e;");

//////////////////////////////////
//    conso transport
//////////////////////////////////

alphaEtauto(:,1)=alphaEtautoref;
conso_auto_oil=Tautomobile.*alphaEtauto.*((pkmautomobileref./100)*ones(1,TimeHorizon+1));
pkmAir=Tair.*(pkmautomobileref*ones(1,TimeHorizon+1))/100;
pkmAuto=(Tautomobile.*(pkmautomobileref*ones(1,TimeHorizon+1)/100));
pkmOT=TOT.*(pkmautomobileref*ones(1,TimeHorizon+1))/100;
pkmNM=TNM.*(pkmautomobileref*ones(1,TimeHorizon+1))/100;

Q_OT=zeros(reg,TimeHorizon+1);
DF_OT=zeros(reg,TimeHorizon+1);
Conso_OT=zeros(reg*sec,TimeHorizon+1);

for k=1:TimeHorizon+1
	CI_temp=matrix(CI(:,k),sec,sec,reg);
	DF_temp=matrix(DF(:,k),reg,sec);
	Q_temp=matrix(Q(:,k),reg,sec);
	Conso_OT_temp=zeros(reg,sec);
	for j=1:reg
		for kk=1:sec
			Conso_OT_temp(j,kk)=CI_temp(indice_OT,kk,j)*Q_temp(j,kk);
		end
	end
	Q_OT(:,k)=Q_temp(:,indice_OT);
	DF_OT(:,k)=DF_temp(:,indice_OT);
	Conso_OT(:,k)=matrix(Conso_OT_temp,reg*sec,1);
end
//matrix(Conso_OT(:,$),reg,sec)./(sum(matrix(Conso_OT(:,$),reg,sec),"c")*ones(1,sec))
Conso_mer=zeros(reg*sec,TimeHorizon+1);
for k=1:TimeHorizon+1
	CI_temp=matrix(CI(:,k),sec,sec,reg);
	Q_temp=matrix(Q(:,k),reg,sec);
	Conso_mer_temp=zeros(reg,sec);
	for j=1:reg
		for kk=1:sec
			Conso_mer_temp(j,kk)=CI_temp(indice_mer,kk,j)*Q_temp(j,kk);
		end
	end
	Conso_mer(:,k)=matrix(Conso_mer_temp,reg*sec,1);
end

//Energy intensity of transportation modes
EI_air=zeros(reg,TimeHorizon+1);
EI_OT = zeros(reg,TimeHorizon+1);
EI_auto=zeros(reg,TimeHorizon+1);
Conso_ener_OT=zeros(reg,TimeHorizon+1);
conso_auto_elec=zeros(reg,TimeHorizon+1);
for j=1:TimeHorizon+1
	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
	Q_temp=matrix(Q(:,j),reg,sec);
	DF_temp=matrix(DF(:,j),reg,sec);
	Exp_temp=matrix(Exp(:,j),reg,sec);
	Imp_temp=matrix(Imp(:,j),reg,sec);
	for k=1:reg
		EI_auto(k,j)=Energy_balance_temp(15,3,k)/pkmAuto(k,j);
		EI_OT(k,j)=(Energy_balance_temp(14,3,k)*DF_temp(k,indice_OT)/(Q_temp(k,indice_OT)-Exp_temp(k,indice_OT)+Imp_temp(k,indice_OT)))/pkmOT(k,j);	
		EI_air(k,j)=(Energy_balance_temp(13,3,k)*DF_temp(k,indice_air)/(Q_temp(k,indice_air)-Exp_temp(k,indice_air)+Imp_temp(k,indice_air)))/pkmAir(k,j);	
		Conso_ener_OT(k,j)=sum(Energy_balance_temp(14,1:8,k));
		conso_auto_elec(k,j)=Energy_balance_temp(15,8,k);
	end
end

EI_air_smp_mtoeperpkm=6.32942E-11;
EI_OTpass_smp_mtoeperpkm=[ 2.15064E-11
							2.15064E-11
							1.46694E-11
							1.35017E-11
							1.03057E-11
							9.27516E-12
							9.134E-12
							1.22602E-11
							1.15767E-11
							9.98473E-12
							9.76809E-12
							1.22602E-11];
EI_OT(:,1).*pkmOT(:,1)./EI_OTpass_smp_mtoeperpkm;
EI_air(:,1).*pkmAir(:,1)/EI_air_smp_mtoeperpkm;

//Prices of transportation modes
p_air=zeros(reg,TimeHorizon+1);
p_OT = zeros(reg,TimeHorizon+1);
p_auto=zeros(reg,TimeHorizon+1);
for j=1:TimeHorizon+1
	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
	pArmDF_temp=matrix(pArmDF(:,j),reg,sec)./(price_index(:,j)*ones(1,sec));
	Q_temp=matrix(Q(:,j),reg,sec);
	DF_temp=matrix(DF(:,j),reg,sec);
	Exp_temp=matrix(Exp(:,j),reg,sec);
	Imp_temp=matrix(Imp(:,j),reg,sec);
	for k=1:reg
		p_auto(k,j)=(pArmDF_temp(k,indice_Et)*Energy_balance_temp(15,3,k)+Tautomobile(k,j).*alphaCompositeauto(k).*pkmautomobileref(k)./100*pArmDF_temp(k,indice_composite))/pkmAuto(k,j)*1000000;
		p_OT(k,j)=  (pArmDF_temp(k,indice_OT)*DF_temp(k,indice_OT))/pkmOT(k,j)*1000000;	
		p_air(k,j)= (pArmDF_temp(k,indice_air)*DF_temp(k,indice_air))/pkmAir(k,j)*1000000;	
	end
end
//  EI_air(:,1)
// EI_auto(:,1)
//   EI_OT(:,1)
//  EI_air(:,$)
// EI_auto(:,$)
//   EI_OT(:,$)
//  p_air(:,1)
// p_auto(:,1)
//   p_OT(:,1)
//  p_air(:,$)
// p_auto(:,$)
//   p_OT(:,$)
// p_auto(:,1)./p_OT(:,1)
// p_air(:,1)./p_OT(:,1)
//UR transport
// [pkmAir(:,j),pkmOT(:,j),pkmAuto(:,j)]./matrix(Captransport(:,j),reg,3)
//        tair1(:,$)
//         tOT1(:,$)
// tautomobile1(:,$)
//        tair1(:,1)
//         tOT1(:,1)
// tautomobile1(:,1)
//   p_air(:,$)./p_air(:,1)
//  p_auto(:,$)./p_auto(:,1)
// //    p_OT(:,$)./p_OT(:,1)
//        ones(reg,1)./tair1(:,$)  
//         ones(reg,1)./tOT1(:,$) 
// ones(reg,1)./tautomobile1(:,$)   
//        ones(reg,1)./tairrefo
//         ones(reg,1)./tOTrefo
// ones(reg,1)./tautomobilerefo
// motorized_mobility=pkmAir+pkmAuto+pkmOT;
// total_mobility=pkmAir+pkmAuto+pkmOT+pkmNM;
////////////////////Calcul de la Total Primary Energy Supply
TPES=zeros(reg,TimeHorizon+1);
for j=1:TimeHorizon+1
	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
	for k=1:reg
		TPES(k,j)=sum(Energy_balance_temp(5,:,k));
	end
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////Liquid fuel production///////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
prod_CTL=zeros(reg,TimeHorizon+1); //CTL
prod_BFU=zeros(reg,TimeHorizon+1); //biofuels
prod_ORI=zeros(reg,TimeHorizon+1); //oil refining
prod_Et=zeros(reg,TimeHorizon+1); //liquid fuel
prod_elec=zeros(reg,TimeHorizon+1); //electricity

for j=1:TimeHorizon+1
	Q_temp=matrix(Q(:,j),reg,sec);
	CI_temp=matrix(CI(:,j),sec,sec,reg);
	prod_Et=Q_temp(:,indice_Et);
	prod_elec=Q_temp(:,indice_elec);
	for k=1:reg
		prod_CTL(k,j)=CI_temp(indice_coal,indice_Et,k)*Q_temp(k,indice_Et)*yield_CTL;                             //CTL         
		prod_ORI(k,j)=CI_temp(indice_oil,indice_Et,k)*Q_temp(k,indice_Et)/CIref(indice_oil,indice_Et,k);         //oil refining
		prod_BFU(k,j)=max(Q_temp(k,indice_Et)-prod_CTL(k,j)-prod_ORI(k,j),0);                                     //biofuels
	end
end

////////////////////////////////
//  carbon & energy intensity
/////////////////////////////////

ConsoEFtot=zeros(reg,TimeHorizon+1);
EregCO2=zeros(reg,TimeHorizon+1);
IEFreal=zeros(reg,TimeHorizon+1);
IEFnom=zeros(reg,TimeHorizon+1);
IC=zeros(reg,TimeHorizon+1);
ECO2_coal=zeros(reg,TimeHorizon+1);
ECO2_oil=zeros(reg,TimeHorizon+1);
ECO2_gaz=zeros(reg,TimeHorizon+1);
ECO2_Et=zeros(reg,TimeHorizon+1);
ECO2_Elec=zeros(reg,TimeHorizon+1);
coef_Q_CO2_Et=zeros(reg,TimeHorizon+1);

//for tt=1:TimeHorizon+1,
//	for k=1:reg,
//	ConsoEFtot(k,tt)=conso_res_oil(k,tt)+conso_res_coal(k,tt)+conso_res_gaz(k,tt)+conso_res_elec(k,tt)+conso_auto_oil(k,tt)...
//	+DG_ener(k,tt)+DG_ener(reg+k,tt)+DG_ener(2*reg+k,tt)+DG_ener(3*reg+k,tt)+DG_ener(4*reg+k,tt)...
//	+DI(k,tt)+DI(reg+k,tt)+DI(2*reg+k,tt)+DI(3*reg+k,tt)+DI(4*reg+k,tt)...
//	+sum(Conso_sec((k-1)*sec*nbsecteurenergie+nbsecteurenergie*nbsecteurenergie+1:k*sec*nbsecteurenergie,tt));
//	IEFreal(k,tt)=ConsoEFtot(k,tt)/realGDP(k,tt);
//	IEFnom(k,tt)=ConsoEFtot(k,tt)/GDP_n(k,tt);
//	end
//end

// EregCO2=zeros(reg,TimeHorizon+1);
// ECO2_coal=zeros(reg,TimeHorizon+1);
// ECO2_oil=zeros(reg,TimeHorizon+1);
// ECO2_gaz=zeros(reg,TimeHorizon+1);
// ECO2_Et=zeros(reg,TimeHorizon+1);


// coef_Q_CO2_coal_EPPA=3790424.344;
// coef_Q_CO2_Et_EPPA=2825237.298;
// coef_Q_CO2_gaz_EPPA=2068718.593;

// for j=1:TimeHorizon+1,
// 	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
// 	for k=1:reg
// 		ECO2_coal(k,j)=(Energy_balance_temp(1,1,k)+Energy_balance_temp(2,1,k)+Energy_balance_temp(3,1,k))*coef_Q_CO2_coal_EPPA;
// 		ECO2_oil(k,j)=-Energy_balance_temp(8,2,k)*coef_Q_CO2_Et_EPPA;
// 		ECO2_gaz(k,j)=(Energy_balance_temp(1,4,k)+Energy_balance_temp(2,4,k)+Energy_balance_temp(3,4,k))*coef_Q_CO2_gaz_EPPA;
// 		ECO2_Et(k,j)=(Energy_balance_temp(6,3,k)+Energy_balance_temp(2,3,k)+Energy_balance_temp(3,3,k))*coef_Q_CO2_Et_EPPA;
// 		EregCO2(k,j)=ECO2_coal(k,j)+ECO2_oil(k,j)+ECO2_gaz(k,j)+ECO2_Et(k,j);
// 		IC(k,tt)=EregCO2(k,tt)/TPES(k,tt);
// 	end
// 	
// end

//émissions régionnales de CO2 en tonnes
for k=1:reg
    EregCO2(k,:)=sum(sg_get_var("E_reg_use_sav",k),"r");
end

mksav("EregCO2");

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////emissions by sectors/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//problems to solve: share_biofuel depends only on the region, not the sector; losses in refineries not accounted for
E_CO2_OTL=zeros(reg,TimeHorizon+1);
E_CO2_rafinage=zeros(reg,TimeHorizon+1);
E_CO2_OTL_coal=zeros(reg,TimeHorizon+1);
E_CO2_OTL_oil=zeros(reg,TimeHorizon+1);
E_CO2_OTL_gas=zeros(reg,TimeHorizon+1);
E_CO2_process=zeros(reg,TimeHorizon+1);
E_CO2_elec=zeros(reg,TimeHorizon+1);
E_CO2_composite=zeros(reg,TimeHorizon+1);
E_CO2_agri=zeros(reg,TimeHorizon+1);
E_CO2_ind=zeros(reg,TimeHorizon+1);
E_CO2_airT=zeros(reg,TimeHorizon+1);
E_CO2_OT=zeros(reg,TimeHorizon+1);
E_CO2_cars=zeros(reg,TimeHorizon+1);
E_CO2_res=zeros(reg,TimeHorizon+1);
E_CO2_btp=zeros(reg,TimeHorizon+1);
E_CO2_marine=zeros(reg,TimeHorizon+1);
E_CO2_TPES=zeros(reg,TimeHorizon+1);
// E_CO2_CTL=zeros(reg,TimeHorizon+1);
// E_CO2_OTL=zeros(reg,TimeHorizon+1);

for j=1:TimeHorizon+1,
	coef_CO2_CI_temp=matrix(coef_Q_CO2_CI(:,j),sec,sec,reg);
	coef_CO2_DF_temp=matrix(coef_Q_CO2_DF(:,j),reg,sec);
	if j==1 then 
		coef_CO2_CI_temp=matrix(coef_Q_CO2_CI(:,2),sec,sec,reg);
		coef_CO2_DF_temp=matrix(coef_Q_CO2_DF(:,2),reg,sec);
	end
	CI_temp=matrix(CI(:,j),sec,sec,reg);
	Q_temp=matrix(Q(:,j),reg,sec);
	
	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
	
	E_CO2_TPES(:,j)=coef_CO2_CI_temp(1,1,:).*Energy_balance_temp(5,1,:)+coef_CO2_CI_temp(2,2,:).*Energy_balance_temp(5,2,:)+coef_CO2_CI_temp(3,3,:).*Energy_balance_temp(5,4,:);
	
	//calcul des émissions liées a l'extraction des energies primaires
	for k=1:reg,
		E_CO2_OTL_coal(k,j)=coef_CO2_CI_temp(indice_coal,indice_coal,k)*CI_temp(indice_coal,indice_coal,k)*Q_temp(k,indice_coal);
		E_CO2_OTL_oil(k,j)=coef_CO2_CI_temp(indice_oil,indice_oil,k) *CI_temp(indice_oil,indice_oil,k)*Q_temp(k,indice_oil);
		E_CO2_OTL_gas(k,j)=coef_CO2_CI_temp(indice_gaz,indice_gaz,k) *CI_temp(indice_gaz,indice_gaz,k)*Q_temp(k,indice_gaz);
	end

	//toutes les pertes, non utilisé par la suite
	E_CO2_OTL(:,j)=-coef_CO2_CI_temp(1,1,:).*Energy_balance_temp(8,1,:)-coef_CO2_CI_temp(2,2,:).*Energy_balance_temp(8,2,:)-coef_CO2_CI_temp(3,3,:).*Energy_balance_temp(8,4,:)-coef_CO2_CI_temp(4,4,:).*Energy_balance_temp(8,3,:);
	//calcul des émissions liées aux process de fabrication de Et
	
	for k=1:reg,
		E_CO2_process(k,j)=(coef_CO2_CI_temp(1,4,k)*CI_temp(1,4,k)+coef_CO2_CI_temp(4,4,k)*CI_temp(4,4,k))*Q_temp(k,4);
		E_CO2_CTL(k,j)=(coef_CO2_CI_temp(1,4,k)*CI_temp(1,4,k))*Q_temp(k,4);
	end
	E_CO2_rafinage(:,j)=-coef_CO2_CI_temp(1,4,:).*Energy_balance_temp(6,1,:)-coef_CO2_CI_temp(2,4,:).*Energy_balance_temp(6,2,:)-coef_CO2_CI_temp(4,4,:).*Energy_balance_temp(6,4,:);
	//calcul des emissions liees a la generation d'electricite
	E_CO2_elec(:,j)=-(coef_CO2_CI_temp(1,5,:).*Energy_balance_temp(7,1,:)+coef_CO2_CI_temp(2,5,:).*Energy_balance_temp(7,2,:)+coef_CO2_CI_temp(3,5,:).*Energy_balance_temp(7,4,:)+coef_CO2_CI_temp(4,5,:).*Energy_balance_temp(7,3,:));
	//calcul des emissions liees a la consommation finale
	E_CO2_composite(:,j)=coef_CO2_CI_temp(1,7,:).*Energy_balance_temp(10,1,:)+coef_CO2_CI_temp(3,7,:).*Energy_balance_temp(10,4,:)+coef_CO2_CI_temp(4,7,:).*Energy_balance_temp(10,3,:);
	E_CO2_agri(:,j)=coef_CO2_CI_temp(1,11,:).*Energy_balance_temp(11,1,:)+coef_CO2_CI_temp(3,11,:).*Energy_balance_temp(11,4,:)+coef_CO2_CI_temp(4,11,:).*Energy_balance_temp(11,3,:);
	E_CO2_ind(:,j)=coef_CO2_CI_temp(1,12,:).*Energy_balance_temp(12,1,:)+coef_CO2_CI_temp(3,12,:).*Energy_balance_temp(12,4,:)+coef_CO2_CI_temp(4,12,:).*Energy_balance_temp(12,3,:);
	E_CO2_airT(:,j)=coef_CO2_CI_temp(1,8,:).*Energy_balance_temp(13,1,:)+coef_CO2_CI_temp(3,8,:).*Energy_balance_temp(13,4,:)+coef_CO2_CI_temp(4,8,:).*Energy_balance_temp(13,3,:);
	E_CO2_OT(:,j)=coef_CO2_CI_temp(1,10,:).*Energy_balance_temp(14,1,:)+coef_CO2_CI_temp(3,10,:).*Energy_balance_temp(14,4,:)+coef_CO2_CI_temp(4,10,:).*Energy_balance_temp(14,3,:);
	E_CO2_btp(:,j)=coef_CO2_CI_temp(1,6,:).*Energy_balance_temp(17,1,:)+coef_CO2_CI_temp(3,6,:).*Energy_balance_temp(17,4,:)+coef_CO2_CI_temp(4,6,:).*Energy_balance_temp(17,3,:);
	E_CO2_marine(:,j)=-coef_CO2_CI_temp(4,9,:).*Energy_balance_temp(4,3,:);
	for k=1:reg,
		E_CO2_cars(k,j)=coef_CO2_DF_temp(k,1).*Energy_balance_temp(15,1,k)+coef_CO2_DF_temp(k,3).*Energy_balance_temp(15,4,k)+coef_CO2_DF_temp(k,4).*Energy_balance_temp(15,3,k);
		E_CO2_res(k,j)=coef_CO2_DF_temp(k,1).*Energy_balance_temp(16,1,k)+coef_CO2_DF_temp(k,3).*Energy_balance_temp(16,4,k)+coef_CO2_DF_temp(k,4).*Energy_balance_temp(16,3,k);
	end
// 	//répartition des émissions de process CTL dans les secteurs de consommation finale au prorata de la consommation finale
// 	//de carburants liquides
// 	E_CO2_composite(:,j)=E_CO2_composite(:,j)+E_CO2_CTL(:,j).*matrix(Energy_balance_temp(10,3,:)./Energy_balance_temp(9,3,:),reg,1);
// 	     E_CO2_agri(:,j)=     E_CO2_agri(:,j)+E_CO2_CTL(:,j).*matrix(Energy_balance_temp(11,3,:)./Energy_balance_temp(9,3,:),reg,1);
// 	      E_CO2_ind(:,j)=      E_CO2_ind(:,j)+E_CO2_CTL(:,j).*matrix(Energy_balance_temp(12,3,:)./Energy_balance_temp(9,3,:),reg,1);
// 	     E_CO2_airT(:,j)=     E_CO2_airT(:,j)+E_CO2_CTL(:,j).*matrix(Energy_balance_temp(13,3,:)./Energy_balance_temp(9,3,:),reg,1);
// 	       E_CO2_OT(:,j)=       E_CO2_OT(:,j)+E_CO2_CTL(:,j).*matrix(Energy_balance_temp(14,3,:)./Energy_balance_temp(9,3,:),reg,1);
// 	      E_CO2_btp(:,j)=      E_CO2_btp(:,j)+E_CO2_CTL(:,j).*matrix(Energy_balance_temp(17,3,:)./Energy_balance_temp(9,3,:),reg,1);
// 	     E_CO2_cars(:,j)=     E_CO2_cars(:,j)+E_CO2_CTL(:,j).*matrix(Energy_balance_temp(15,3,:)./Energy_balance_temp(9,3,:),reg,1);
// 	      E_CO2_res(:,j)=      E_CO2_res(:,j)+E_CO2_CTL(:,j).*matrix(Energy_balance_temp(16,3,:)./Energy_balance_temp(9,3,:),reg,1);
end

E_sectors=[ E_CO2_OTL_coal;
			E_CO2_OTL_oil;
			E_CO2_OTL_gas;
			E_CO2_process;
			E_CO2_elec;
			E_CO2_composite;
			E_CO2_agri;
			E_CO2_ind;
			E_CO2_btp;
			E_CO2_airT;
			E_CO2_OT;
			E_CO2_marine;
			E_CO2_cars;
			E_CO2_res;
			];

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////emissions by end uses sectors/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//calculs temporaires pour l'élec et le CTL/rafinage
E_EU_CO2_process=E_CO2_process;
E_EU_CO2_elec   =E_CO2_elec   ;
//usages finaux
E_EU_CO2_composite=E_CO2_composite;
E_EU_CO2_agri     =E_CO2_agri     ;
E_EU_CO2_ind      =E_CO2_ind      ;
E_EU_CO2_airT     =E_CO2_airT     ;
E_EU_CO2_OT       =E_CO2_OT       ;
E_EU_CO2_cars     =E_CO2_cars     ;
E_EU_CO2_res      =E_CO2_res      ;
E_EU_CO2_btp      =E_CO2_btp      ;
E_EU_CO2_marine   =E_CO2_marine   ;

for j=1:TimeHorizon+1,

	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
	Q_temp=matrix(Q(:,j),reg,sec);	
	//on ne répartit pas les émissions liées a l'extraction des energies primaires sinon problème...
	for k=1:reg
		// //pétrole (on ne réparti pas les pertes pétrole dans le rafinage... sinon problème)
		// E_EU_CO2_process(:,j)  =E_EU_CO2_process(:,j)  +sum(E_CO2_OTL_coal(:,j))*(-Energy_balance_temp(6 ,1,k))/sum(Q_temp(:,indice_coal));
		// E_EU_CO2_elec(:,j)     =E_EU_CO2_elec(:,j)     +sum(E_CO2_OTL_coal(:,j))*(-Energy_balance_temp(7 ,1,k))/sum(Q_temp(:,indice_coal));
		// E_EU_CO2_composite(:,j)=E_EU_CO2_composite(:,j)+sum(E_CO2_OTL_coal(:,j))*  Energy_balance_temp(10,1,k)/sum(Q_temp(:,indice_coal));
		// E_EU_CO2_agri(:,j)     =E_EU_CO2_agri(:,j)     +sum(E_CO2_OTL_coal(:,j))*  Energy_balance_temp(11,1,k)/sum(Q_temp(:,indice_coal));
		// E_EU_CO2_ind(:,j)      =E_EU_CO2_ind(:,j)      +sum(E_CO2_OTL_coal(:,j))*  Energy_balance_temp(12,1,k)/sum(Q_temp(:,indice_coal));
		// E_EU_CO2_airT(:,j)     =E_EU_CO2_airT(:,j)     +sum(E_CO2_OTL_coal(:,j))*  Energy_balance_temp(13,1,k)/sum(Q_temp(:,indice_coal));
		// E_EU_CO2_OT(:,j)       =E_EU_CO2_OT(:,j)       +sum(E_CO2_OTL_coal(:,j))*  Energy_balance_temp(14,1,k)/sum(Q_temp(:,indice_coal));
		// E_EU_CO2_cars(:,j)     =E_EU_CO2_cars(:,j)     +sum(E_CO2_OTL_coal(:,j))*  Energy_balance_temp(15,1,k)/sum(Q_temp(:,indice_coal));
		// E_EU_CO2_res(:,j)      =E_EU_CO2_res(:,j)      +sum(E_CO2_OTL_coal(:,j))*  Energy_balance_temp(16,1,k)/sum(Q_temp(:,indice_coal));
		// E_EU_CO2_btp(:,j)      =E_EU_CO2_btp(:,j)      +sum(E_CO2_OTL_coal(:,j))*  Energy_balance_temp(17,1,k)/sum(Q_temp(:,indice_coal));
		// E_EU_CO2_marine(:,j)   =E_EU_CO2_marine(:,j)   +sum(E_CO2_OTL_coal(:,j))*(-Energy_balance_temp(4 ,1,k))/sum(Q_temp(:,indice_coal));
		
		// //pétrole (on ne réparti pas les pertes pétrole dans le rafinage... sinon problème)
		// //E_EU_CO2_process(:,j)  =E_EU_CO2_process(:,j)  +sum(E_CO2_OTL_oil(:,j))*(-Energy_balance_temp(6 ,2,k))/sum(Q_temp(:,indice_oil));
		// E_EU_CO2_elec(:,j)     =E_EU_CO2_elec(:,j)     +sum(E_CO2_OTL_oil(:,j))*(-Energy_balance_temp(7 ,2,k))/sum(Q_temp(:,indice_oil));
		// E_EU_CO2_composite(:,j)=E_EU_CO2_composite(:,j)+sum(E_CO2_OTL_oil(:,j))*  Energy_balance_temp(10,2,k)/sum(Q_temp(: ,indice_oil));
		// E_EU_CO2_agri(:,j)     =E_EU_CO2_agri(:,j)     +sum(E_CO2_OTL_oil(:,j))*  Energy_balance_temp(11,2,k)/sum(Q_temp(: ,indice_oil));
		// E_EU_CO2_ind(:,j)      =E_EU_CO2_ind(:,j)      +sum(E_CO2_OTL_oil(:,j))*  Energy_balance_temp(12,2,k)/sum(Q_temp(: ,indice_oil));
		// E_EU_CO2_airT(:,j)     =E_EU_CO2_airT(:,j)     +sum(E_CO2_OTL_oil(:,j))*  Energy_balance_temp(13,2,k)/sum(Q_temp(: ,indice_oil));
		// E_EU_CO2_OT(:,j)       =E_EU_CO2_OT(:,j)       +sum(E_CO2_OTL_oil(:,j))*  Energy_balance_temp(14,2,k)/sum(Q_temp(: ,indice_oil));
		// E_EU_CO2_cars(:,j)     =E_EU_CO2_cars(:,j)     +sum(E_CO2_OTL_oil(:,j))*  Energy_balance_temp(15,2,k)/sum(Q_temp(: ,indice_oil));
		// E_EU_CO2_res(:,j)      =E_EU_CO2_res(:,j)      +sum(E_CO2_OTL_oil(:,j))*  Energy_balance_temp(16,2,k)/sum(Q_temp(: ,indice_oil));
		// E_EU_CO2_btp(:,j)      =E_EU_CO2_btp(:,j)      +sum(E_CO2_OTL_oil(:,j))*  Energy_balance_temp(17,2,k)/sum(Q_temp(: ,indice_oil));
		// E_EU_CO2_marine(:,j)   =E_EU_CO2_marine(:,j)   +sum(E_CO2_OTL_oil(:,j))*(-Energy_balance_temp(4 ,2,k))/sum(Q_temp(:,indice_oil));
		// //gaz
		// E_EU_CO2_process(:,j)  =E_EU_CO2_process(:,j)  +sum(E_CO2_OTL_gas(:,j))*(-Energy_balance_temp(6 ,4,k))/sum(Q_temp(:,indice_gaz));
		// E_EU_CO2_elec(:,j)     =E_EU_CO2_elec(:,j)     +sum(E_CO2_OTL_gas(:,j))*(-Energy_balance_temp(7 ,4,k))/sum(Q_temp(:,indice_gaz));
		// E_EU_CO2_composite(:,j)=E_EU_CO2_composite(:,j)+sum(E_CO2_OTL_gas(:,j))*  Energy_balance_temp(10,4,k)/sum(Q_temp(: ,indice_gaz));
		// E_EU_CO2_agri(:,j)     =E_EU_CO2_agri(:,j)     +sum(E_CO2_OTL_gas(:,j))*  Energy_balance_temp(11,4,k)/sum(Q_temp(: ,indice_gaz));
		// E_EU_CO2_ind(:,j)      =E_EU_CO2_ind(:,j)      +sum(E_CO2_OTL_gas(:,j))*  Energy_balance_temp(12,4,k)/sum(Q_temp(: ,indice_gaz));
		// E_EU_CO2_airT(:,j)     =E_EU_CO2_airT(:,j)     +sum(E_CO2_OTL_gas(:,j))*  Energy_balance_temp(13,4,k)/sum(Q_temp(: ,indice_gaz));
		// E_EU_CO2_OT(:,j)       =E_EU_CO2_OT(:,j)       +sum(E_CO2_OTL_gas(:,j))*  Energy_balance_temp(14,4,k)/sum(Q_temp(: ,indice_gaz));
		// E_EU_CO2_cars(:,j)     =E_EU_CO2_cars(:,j)     +sum(E_CO2_OTL_gas(:,j))*  Energy_balance_temp(15,4,k)/sum(Q_temp(: ,indice_gaz));
		// E_EU_CO2_res(:,j)      =E_EU_CO2_res(:,j)      +sum(E_CO2_OTL_gas(:,j))*  Energy_balance_temp(16,4,k)/sum(Q_temp(: ,indice_gaz));
		// E_EU_CO2_btp(:,j)      =E_EU_CO2_btp(:,j)      +sum(E_CO2_OTL_gas(:,j))*  Energy_balance_temp(17,4,k)/sum(Q_temp(: ,indice_gaz));
		// E_EU_CO2_marine(:,j)   =E_EU_CO2_marine(:,j)   +sum(E_CO2_OTL_gas(:,j))*(-Energy_balance_temp(4 ,4,k))/sum(Q_temp(:,indice_gaz));
	end
	
	//répartition des émissions liées à l'elec et process carburants liquides
	E_EU_CO2_composite(:,j)=E_EU_CO2_composite(:,j)+E_EU_CO2_process(:,j).*matrix(Energy_balance_temp(10,3,:)./Energy_balance_temp(6,3,:),reg,1);
	E_EU_CO2_agri(:,j)     =E_EU_CO2_agri(:,j)     +E_EU_CO2_process(:,j).*matrix(Energy_balance_temp(11,3,:)./Energy_balance_temp(6,3,:),reg,1);
	E_EU_CO2_ind(:,j)      =E_EU_CO2_ind(:,j)      +E_EU_CO2_process(:,j).*matrix(Energy_balance_temp(12,3,:)./Energy_balance_temp(6,3,:),reg,1);
	E_EU_CO2_airT(:,j)     =E_EU_CO2_airT(:,j)     +E_EU_CO2_process(:,j).*matrix(Energy_balance_temp(13,3,:)./Energy_balance_temp(6,3,:),reg,1);
	E_EU_CO2_OT(:,j)       =E_EU_CO2_OT(:,j)       +E_EU_CO2_process(:,j).*matrix(Energy_balance_temp(14,3,:)./Energy_balance_temp(6,3,:),reg,1);
	E_EU_CO2_btp(:,j)      =E_EU_CO2_btp(:,j)      +E_EU_CO2_process(:,j).*matrix(Energy_balance_temp(17,3,:)./Energy_balance_temp(6,3,:),reg,1);
	E_EU_CO2_cars(:,j)     =E_EU_CO2_cars(:,j)     +E_EU_CO2_process(:,j).*matrix(Energy_balance_temp(15,3,:)./Energy_balance_temp(6,3,:),reg,1);
	E_EU_CO2_res(:,j)      =E_EU_CO2_res(:,j)      +E_EU_CO2_process(:,j).*matrix(Energy_balance_temp(16,3,:)./Energy_balance_temp(6,3,:),reg,1);

	E_EU_CO2_composite(:,j)=E_EU_CO2_composite(:,j)+E_EU_CO2_elec(:,j).*matrix(Energy_balance_temp(10,8,:)./Energy_balance_temp(7,8,:),reg,1);
	E_EU_CO2_agri(:,j)     =E_EU_CO2_agri(:,j)     +E_EU_CO2_elec(:,j).*matrix(Energy_balance_temp(11,8,:)./Energy_balance_temp(7,8,:),reg,1);
	E_EU_CO2_ind(:,j)      =E_EU_CO2_ind(:,j)      +E_EU_CO2_elec(:,j).*matrix(Energy_balance_temp(12,8,:)./Energy_balance_temp(7,8,:),reg,1);
	E_EU_CO2_airT(:,j)     =E_EU_CO2_airT(:,j)     +E_EU_CO2_elec(:,j).*matrix(Energy_balance_temp(13,8,:)./Energy_balance_temp(7,8,:),reg,1);
	E_EU_CO2_OT(:,j)       =E_EU_CO2_OT(:,j)       +E_EU_CO2_elec(:,j).*matrix(Energy_balance_temp(14,8,:)./Energy_balance_temp(7,8,:),reg,1);
	E_EU_CO2_btp(:,j)      =E_EU_CO2_btp(:,j)      +E_EU_CO2_elec(:,j).*matrix(Energy_balance_temp(17,8,:)./Energy_balance_temp(7,8,:),reg,1);
	E_EU_CO2_cars(:,j)     =E_EU_CO2_cars(:,j)     +E_EU_CO2_elec(:,j).*matrix(Energy_balance_temp(15,8,:)./Energy_balance_temp(7,8,:),reg,1);
	E_EU_CO2_res(:,j)      =E_EU_CO2_res(:,j)      +E_EU_CO2_elec(:,j).*matrix(Energy_balance_temp(16,8,:)./Energy_balance_temp(7,8,:),reg,1);

end

E_EU_sectors=[
			  E_EU_CO2_composite;
			  E_EU_CO2_agri;
			  E_EU_CO2_ind;
			  E_EU_CO2_btp;
			  E_EU_CO2_airT;
			  E_EU_CO2_OT;
			  E_EU_CO2_marine;
			  E_EU_CO2_cars;
			  E_EU_CO2_res;
			];

// for j=1:TimeHorizon+1,
// 	coef_CO2_CI_temp=matrix(coef_Q_CO2_CI(:,j),sec,sec,reg);
// 	coef_CO2_DF_temp=matrix(coef_Q_CO2_DF(:,j),reg,sec);
// 	
// 	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
// 	coef_CO2_elec=-(coef_CO2_CI_temp(1,5,:).*Energy_balance_temp(7,1,:)+coef_CO2_CI_temp(2,5,:).*Energy_balance_temp(7,2,:)+coef_CO2_CI_temp(3,5,:).*Energy_balance_temp(7,4,:)+coef_CO2_CI_temp(4,5,:).*Energy_balance_temp(7,3,:))./Energy_balance_temp(7,8,:);
// 	
// 	E_CO2_composite(:,j)=coef_CO2_CI_temp(1,7,:).*Energy_balance_temp(10,1,:)+coef_CO2_CI_temp(3,7,:).*Energy_balance_temp(10,4,:)+coef_CO2_CI_temp(4,7,:).*Energy_balance_temp(10,3,:)+coef_CO2_elec(1,1,:).*Energy_balance_temp(10,8,:);
// 	E_CO2_agri(:,j)=coef_CO2_CI_temp(1,11,:).*Energy_balance_temp(11,1,:)+coef_CO2_CI_temp(3,11,:).*Energy_balance_temp(11,4,:)+coef_CO2_CI_temp(4,11,:).*Energy_balance_temp(11,3,:)+coef_CO2_elec(1,1,:).*Energy_balance_temp(11,8,:);
// 	E_CO2_ind(:,j)=coef_CO2_CI_temp(1,12,:).*Energy_balance_temp(12,1,:)+coef_CO2_CI_temp(3,12,:).*Energy_balance_temp(12,4,:)+coef_CO2_CI_temp(4,12,:).*Energy_balance_temp(12,3,:)+coef_CO2_elec(1,1,:).*Energy_balance_temp(12,8,:);
// 	E_CO2_airT(:,j)=coef_CO2_CI_temp(1,8,:).*Energy_balance_temp(13,1,:)+coef_CO2_CI_temp(3,8,:).*Energy_balance_temp(13,4,:)+coef_CO2_CI_temp(4,8,:).*Energy_balance_temp(13,3,:)+coef_CO2_elec(1,1,:).*Energy_balance_temp(13,8,:);
// 	E_CO2_OT(:,j)=coef_CO2_CI_temp(1,10,:).*Energy_balance_temp(14,1,:)+coef_CO2_CI_temp(3,10,:).*Energy_balance_temp(14,4,:)+coef_CO2_CI_temp(4,10,:).*Energy_balance_temp(14,3,:)+coef_CO2_elec(1,1,:).*Energy_balance_temp(14,8,:);
// 	E_CO2_btp(:,j)=coef_CO2_CI_temp(1,6,:).*Energy_balance_temp(17,1,:)+coef_CO2_CI_temp(3,6,:).*Energy_balance_temp(17,4,:)+coef_CO2_CI_temp(4,6,:).*Energy_balance_temp(17,3,:)+coef_CO2_elec(1,1,:).*Energy_balance_temp(17,8,:);

// 	for k=1:reg,
// 		E_CO2_cars(k,j)=coef_CO2_DF_temp(k,1).*Energy_balance_temp(15,1,k)+coef_CO2_DF_temp(k,3).*Energy_balance_temp(15,4,k)+coef_CO2_DF_temp(k,4).*Energy_balance_temp(15,3,k)+coef_CO2_elec(1,1,k).*Energy_balance_temp(15,8,k);
// 		E_CO2_res(k,j)=coef_CO2_DF_temp(k,1).*Energy_balance_temp(16,1,k)+coef_CO2_DF_temp(k,3).*Energy_balance_temp(16,4,k)+coef_CO2_DF_temp(k,4).*Energy_balance_temp(16,3,k)+coef_CO2_elec(1,1,k).*Energy_balance_temp(16,8,k);
// 	end
// end



//disp((sum(E_sectors,"r")*12/44)./sum(emissions,"r"),"(sum(E_sectors,""r"")*12/44)./sum(emissions,""r"")");
mkcsv( "E_sectors");
// save(MODEL+"output_these\"+"E_sectors.sav",E_sectors);

/////////////////////////////////////Households' budget
pArmDF_n=pArmDF./(ones(reg*sec,1)*num);
Rdisp_n=Rdisp./(ones(reg,1)*num);
pArmCI_n=pArmCI./(ones(reg*sec*sec,1)*num);

///////////////////////////////////rendement des centrales électriques thermiques
output_rho_elec=zeros(reg,TimeHorizon+1);
for j=1:reg
	output_rho_elec(j,1:TimeHorizon)=matrix(rho_elec(1,j,1:TimeHorizon),1,TimeHorizon);
end

//Calculs sur la offre d'énergie primaire
//ordre des fuels : Coal, Oil, Gaz, Hydro, Nuc , ENR
TPES_world_Fuel=zeros(6,TimeHorizon+1);
for j=1:TimeHorizon+1,
	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
	TPES_world_Fuel(1,j)=sum(Energy_balance_temp(5,1,:));
	TPES_world_Fuel(2,j)=sum(Energy_balance_temp(5,2,:));
	TPES_world_Fuel(3,j)=sum(Energy_balance_temp(5,4,:));
	TPES_world_Fuel(4,j)=sum(Energy_balance_temp(5,5,:));
	TPES_world_Fuel(5,j)=sum(Energy_balance_temp(5,6,:));
	TPES_world_Fuel(6,j)=sum(Energy_balance_temp(5,7,:));
end

TPES_annex1_Fuel=zeros(6,TimeHorizon+1);
for j=1:TimeHorizon+1,
	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
	TPES_annex1_Fuel(1,j)=sum(Energy_balance_temp(5,1,1:5));
	TPES_annex1_Fuel(2,j)=sum(Energy_balance_temp(5,2,1:5));
	TPES_annex1_Fuel(3,j)=sum(Energy_balance_temp(5,4,1:5));
	TPES_annex1_Fuel(4,j)=sum(Energy_balance_temp(5,5,1:5));
	TPES_annex1_Fuel(5,j)=sum(Energy_balance_temp(5,6,1:5));
	TPES_annex1_Fuel(6,j)=sum(Energy_balance_temp(5,7,1:5));
end

TPES_nannex1_Fuel=zeros(6,TimeHorizon+1);
for j=1:TimeHorizon+1,
	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
	TPES_nannex1_Fuel(1,j)=sum(Energy_balance_temp(5,1,6:reg));
	TPES_nannex1_Fuel(2,j)=sum(Energy_balance_temp(5,2,6:reg));
	TPES_nannex1_Fuel(3,j)=sum(Energy_balance_temp(5,4,6:reg));
	TPES_nannex1_Fuel(4,j)=sum(Energy_balance_temp(5,5,6:reg));
	TPES_nannex1_Fuel(5,j)=sum(Energy_balance_temp(5,6,6:reg));
	TPES_nannex1_Fuel(6,j)=sum(Energy_balance_temp(5,7,6:reg));
end

E_CO2_tot=sum(E_reg_use,"r");
/////////////////////////////////
//  Ouput to Excel
/////////////////////////////////

Regions  = ["USA";"CAN";"EUR";"JAN";"CIS";"CHN";"IND";"BRA";"MO";"AFR";"RAS";"RAL"];
Secteurs = ["coal";"Oil";"Gas";"Petr. Prod.";"Elec";"Constr.";"Comp.";"Air Transp.";"Water Transp.";"Other Transp.";"Agriculture";"Industrie"];

Code_TPES=[1:6]';
Code_Regions  = [1:reg]';
Code_Regions_alpha = mstr2sci("ABCDEFGHIJKL")';
Code_Secteurs = [1:sec]';

// region codes sorted with
// regional 1-12 suite concatenated 10 times
Code_Regions_3=[];
for current_time_im=1:sec;
	Code_Regions_3=[Code_Regions_3;Code_Regions];
end

// region codes sorted with
// regional 1-12 suite concatenated 4 times
Code_Regions_7=[];
for current_time_im=1:4;
	Code_Regions_7=[Code_Regions_7;Code_Regions];
end

// region codes sorted with
// regional 1-12 suite concatenated 5 times
Code_Regions_8=[];
for current_time_im=1:5;
	Code_Regions_8=[Code_Regions_8;Code_Regions];
end

// region codes sorted by increasing index for regions
// each region repeated sec times (sec different sectors)
Code_Regions_2=[];
for current_time_im=1:reg;
	Code_Regions_2=[Code_Regions_2;ones(sec,1)*current_time_im];
end

// 12 region codes sorted by increasing index for regions
// each region repeated 5*sec times (5*sec different sectors)
Code_Regions_4=[];
for current_time_im=1:reg;
	Code_Regions_4=[Code_Regions_4;ones(5*sec,1)*current_time_im];
end

// 12 region codes sorted by increasing index for regions
// each region repeated nbsecteurenergie times (nbsecteurenergie different sectors)
Code_Regions_5=[];
for current_time_im=1:reg;
	Code_Regions_5=[Code_Regions_5;ones(nbsecteurenergie,1)*current_time_im];
end

// 12 region codes sorted by increasing index for regions
// each region repeated sec*sec times (sec*sec different sectors)
Code_Regions_6=[];
for current_time_im=1:reg;
	Code_Regions_6=[Code_Regions_6;ones(sec*sec,1)*current_time_im];
end



// variables in this matrix by (region,year)
// 999 means global (non regional) variable
// -999 means unknown value

output1=[...
		[Code_Regions,Ltot];
		[Code_Regions,realGDP];	
		[Code_Regions,realGDPrate];
		[Code_Regions,GDP_n];
		[Code_Regions,DF((indice_composite-1)*reg+1:indice_composite*reg,:)];
		[Code_Regions,DF((indice_composite-1)*reg+1:indice_composite*reg,:)./Ltot]; 
		[Code_Regions,mer./(ones(reg,1)*num)];
		[Code_Regions,KBal_n];
		[Code_Regions_3,Exp_val_n];
		[Code_Regions_3,Imp_val_n];
		[Code_Regions,ptc];
		[Code_Regions,div];
		[Code_Regions,Z];
		[Code_Regions_3,Q];
		[Code_Regions_3,charge];
		[Code_Regions_3,p_n];
		[ones(sec,1)*999,wp_n]];

text1=["hello"];
output2=[...
		[Code_Regions_4,Conso_sec];
		[Code_Regions,conso_res_coal];
		[Code_Regions,conso_res_gaz];
		[Code_Regions,conso_res_oil];
		[Code_Regions,conso_res_elec];
		[Code_Regions,conso_auto_oil];
		[Code_Regions,m2batiment./Ltot];
		[Code_Regions,(stockautomobile.*(nombreautomobileref*ones(1,TimeHorizon+1))/100)./Ltot];
		[Code_Regions_5,DG_ener];
		[Code_Regions_5,DI(1:nbsecteurenergie*reg,:)];
		[Code_Regions,IEFreal];
		[Code_Regions,IEFnom];
		[Code_Regions,IC];
		[999,E_CO2_tot];
		[Code_Regions,pkmAir];
		[Code_Regions,pkmAuto];
		[Code_Regions,pkmOT];
		[Code_Regions,pkmNM];
		[Code_Regions,pkmAir./Ltot];
		[Code_Regions,pkmAuto./Ltot];
		[Code_Regions,pkmOT./Ltot];
		[Code_Regions,pkmNM./Ltot];];

output3=[
		[Code_Regions_3,Exp];
		[Code_Regions_3,Imp];
		[Code_Regions,progestechl(6*reg+1:7*reg,:)];
		[Code_Regions_3,VA_real];
		[Code_Regions_3,Invtot_n];
		[Code_Regions_3,pArmDF_n];
		[Code_Regions_3,DF];
		[Code_Regions,Rdisp_n]];

output4=[Code_Regions_6,pArmCI_n];

output5=[[Code_Regions_6,CI];
		[Code_Regions,alphaEtauto];
		[Code_Regions,alphaCoalm2];
		[Code_Regions,alphaEtm2];
		[Code_Regions,alphaGazm2];
		[Code_Regions,alphaelecm2];
		[Code_Regions,TPES];
		[Code_Regions,Q_elec_anticip/11630000];
		[Code_Regions,GDP_IMF_base];
		[Code_Regions,GDP_IMF_base_pc];
		[Code_Regions,GDP_PPP];
		[Code_Regions,output_rho_elec];
		[Code_TPES,TPES_world_Fuel];
		[Code_TPES,TPES_annex1_Fuel];
		[Code_TPES,TPES_nannex1_Fuel];
		[Code_Regions,Lact];
		[Code_Regions,Rdisp_xsi./Ltot];
		[Code_Regions_8,xsi_sav(:,1:TimeHorizon+1)];
		[Code_Regions_3,progestechl];
		];

output=[output1;
	zeros(1,TimeHorizon+2);output2;
	zeros(1,TimeHorizon+2);output3;
	zeros(1,TimeHorizon+2);output4
	zeros(1,TimeHorizon+2);output5];

///////////////////////////////////////////////
// 	WRITE output matrix to hard-drive
////////////////////////////////////////////////

/////////////////////////
// economic and sectoral variables
mkcsv("output");


year=2;
Energy_balance_temp=matrix(energy_balance_stock(:,year),indice_matEner,8,reg);
saut_ligne_2=zeros(2,8);
for k=1:8
saut_ligne_2(:,k)=[999999;999999];
end

Energy_balance_output=[Energy_balance_temp(:,:,1);
						saut_ligne_2;
						Energy_balance_temp(:,:,2);
						saut_ligne_2;
						Energy_balance_temp(:,:,3);
						saut_ligne_2;
						Energy_balance_temp(:,:,4);
						saut_ligne_2;
						Energy_balance_temp(:,:,5);
						saut_ligne_2;
						Energy_balance_temp(:,:,6);
						saut_ligne_2;
						Energy_balance_temp(:,:,7);
						saut_ligne_2;
						Energy_balance_temp(:,:,8);
						saut_ligne_2;
						Energy_balance_temp(:,:,9);
						saut_ligne_2;
						Energy_balance_temp(:,:,10);
						saut_ligne_2;
						Energy_balance_temp(:,:,11);
						saut_ligne_2;
						Energy_balance_temp(:,:,12)];
fprintfMat(SAVEDIR+"Energy_balance_imaclim"+(year+2000)+".tsv",Energy_balance_output,"%5.3f");

year=TimeHorizon+1;
Energy_balance_temp=matrix(energy_balance_stock(:,year),indice_matEner,8,reg);
Energy_balance_output=[Energy_balance_temp(:,:,1);
saut_ligne_2;
Energy_balance_temp(:,:,2);
saut_ligne_2;
Energy_balance_temp(:,:,3);
saut_ligne_2;
Energy_balance_temp(:,:,4);
saut_ligne_2;
Energy_balance_temp(:,:,5);
saut_ligne_2;
Energy_balance_temp(:,:,6);
saut_ligne_2;
Energy_balance_temp(:,:,7);
saut_ligne_2;
Energy_balance_temp(:,:,8);
saut_ligne_2;
Energy_balance_temp(:,:,9);
saut_ligne_2;
Energy_balance_temp(:,:,10);
saut_ligne_2;
Energy_balance_temp(:,:,11);
saut_ligne_2;
Energy_balance_temp(:,:,12)];
fprintfMat(SAVEDIR+"/Energy_balance_imaclim"+(year+2000)+".tsv",Energy_balance_output,"%5.3f");

//////////////////////////////////////
//calculs et description des indicateurs
// indicators description and calculation
/////////////////////////////////////

//GDP per capita = GDPpc - US$10^3 per capita (MER 2001)
//GDPpc=realGDP./Ltot*1000;


//Total Primary Energy Supply per capita = TPESpc (tep per capita) 


TPESpc=TPES./Ltot*1000000;

//Final Consumption of Energy per capita= FCenerpc (tep per capita) 

FCenerpc=zeros(reg,TimeHorizon+1);
for j=1:TimeHorizon+1
	DFtemp=matrix(DF(:,j),reg,sec);
	FCenerpc(:,j)=sum(DFtemp(:,1:nbsecteurenergie),"c")./Ltot(:,j)*1000000;
end

//Final Consumption of Energy in physic values = FCenerphys
//to be built


//Final Consumption of Energy in moneratry values= FCenerval US$ 10^6 (2001 mer)
FCenerval=zeros(reg,TimeHorizon+1);
for j=1:TimeHorizon+1
	pArmDFtemp=matrix(pArmDF(:,j)/num(j),reg,sec);
	DFtemp=matrix(DF(:,j),reg,sec);
	FCenerval(:,j)=sum(DFtemp(:,1:nbsecteurenergie).*pArmDFtemp(:,1:nbsecteurenergie),"c");
end

// Share of energy spendings in households disposable income = ShEHI - % 
ShEHI=zeros(reg,TimeHorizon+1);
for j=1:TimeHorizon+1
	pArmDFtemp=matrix(pArmDF(:,j)/num(j),reg,sec);
	DFtemp=matrix(DF(:,j),reg,sec);
	ShEHI(:,j)=sum(DFtemp(:,1:nbsecteurenergie).*pArmDFtemp(:,1:nbsecteurenergie),"c")./(Rdisp(:,j).*ptc(:,j).*(1-IR(:,j))/num(j));
end

// Share of energy in the costs = SEIC
//to be built
	
// Final Consumption of Energy in phisic values over Value Added = FCenerphisVA
//to be built

// Final Consumption of Energy in phisic values over production in phisic values = 
//to be built

//Transport per capita (passenger kilometer per capita) = pkm_pc

pkm_pc=(pkmAir+pkmAuto+pkmOT+pkmNM)./Ltot;

//Consumption of composite goods per capita = conso_comp_pc -  per capita 

conso_comp_pc=DF((indice_composite-1)*reg+1:indice_composite*reg,:)./Ltot*1000;

//Equipement owning per capita = split in housing and car stocks

//Housing m2 per capita = stock_m2_pc

stock_m2_pc=m2batiment./Ltot;

//number of cars per capita =  nb_car_pc

nb_car_pc=(stockautomobile.*(nombreautomobileref*ones(1,TimeHorizon+1))/100)./Ltot;

//Trade Balance = TB - US$10^6 (MER 2001)

TB=zeros(reg,TimeHorizon+1);
for j=1:TimeHorizon+1
	Exp_val_n_temp=matrix(Exp_val_n(:,j),reg,sec);
	Imp_val_n_temp=matrix(Imp_val_n(:,j),reg,sec);
	TB(:,j)=sum(Exp_val_n_temp-Imp_val_n_temp,"c");
end

// Energy exports = EnerX
//to be built

// Energy imports = EnerM
//to be built

//Unemployment rate = Unemp_rate (share of L tot confirmar)

Unemp_rate=Z;

//composite production per capita = comp_prod_pc - US$10^3 per capita (MER 2001) confirmar


comp_prod_pc=Q((indice_composite-1)*reg+1:indice_composite*reg,:)./Ltot*1000;

//Energy Intensity = Total Primary Energy Supply over Real GDP = EI unity tep/US$10^3 (mer 2001) 

//EI=TPES./realGDP*1000;

//Think of building sectoral energie intensities

//Final consumption of electricity per capita = DF_elec_pc = (tep per capita)
DF_elec_pc=DF((indice_elec-1)*reg+1:indice_elec*reg,:)./Ltot*1000000;


// CO2 indicators 

// CO2 emissions per country = CO2country
//to be built

// CO2 emissions per capita = CO2pc
//to be built

// Carbonization index (confirm name) = CO2 emissions over real GDP = Cindex
//to be built

//Elements of Kaya identity
// CO2 emissions = population * GDPpc * EI * CI
//OBS make kaya with TPES and with Final energy consumption

//Carbon intensity (confirm name) = CO2 emissions over TPES = CI
// to be built

///////////////////////////////////////////////
// 	WRITE indicators to hard-drive
////////////////////////////////////////////////

/////////////////////////
// file output_indicators listing the indicators, unities and indicator numerical order (can be used as a code)
// in the following order
// GDPpc(US$1000 (MER 2001) per capita)-indicator 1
// TPESpc (tep per capita)- indicator 2
// Final Consumption of Energy per capita = FCenerpc (tep per capita)- indicator 3
// Final Consumption of Energy in moneratry values= FCenerval (US$ X (MER 2001)- indicator 4
// Share of energy in households income = ShEHI - tep/US$10^3 (mer 2001)- indicator 5
// Transport per capita  = pkm_pc = passenger kilometer per capita - indicator 6
// Consumption of composite goods per capita in physical values = conso_comp_pc - per capita - indicator 7
// Housing m2 per capita = stock_m2_pc - m2 per capita - indicator 8
// number of cars per capita =  nb_car_pc = cars per capita - indicator 9
// Trade Balance = TB - US$10^6 (MER 2001)- indicator 10
// Unemployment rate = Unemp_rate (share of L tot confirmar) - indicator 11
// composite production per capita = comp_prod_pc - US$10^3 per capita (MER 2001) confirmar - indicador 12
// Energy Intensity = Total Primary Energy Supply over Real GDP = EI unity tep/US$10^3 (mer 2001) indic 13
// Final consumption of electricity per capita = DF_elec_pc = (tep per capita) - indicator 14




output_indicator=[...
	[Code_Regions,1*ones(reg,1),GDPpc];
	[Code_Regions,2*ones(reg,1),TPESpc];	
	[Code_Regions,3*ones(reg,1),FCenerpc];
	[Code_Regions,4*ones(reg,1),FCenerval];
	[Code_Regions,5*ones(reg,1),ShEHI];
	[Code_Regions,6*ones(reg,1),pkm_pc];
	[Code_Regions,7*ones(reg,1),conso_comp_pc];
	[Code_Regions,8*ones(reg,1),stock_m2_pc];
	[Code_Regions,9*ones(reg,1),nb_car_pc];
	[Code_Regions,10*ones(reg,1),TB];
	[Code_Regions,11*ones(reg,1),Unemp_rate];
	[Code_Regions,12*ones(reg,1),comp_prod_pc];
	[Code_Regions,13*ones(reg,1),EI];
	[Code_Regions,14*ones(reg,1),DF_elec_pc]];

//fprintfMat(SAVEDIR+"output_indicator_.tsv",output_indicator,format_spec);

// sortie donne quelques donnes primaires pour comparaison avec donnes primaires bresilien peut etre efface

output_donnes_primaires=[...
[Code_Regions,1*ones(reg,1),realGDP];
[Code_Regions,2*ones(reg,1),TPES];	
[Code_Regions,10*ones(reg,1),TB]];

//fprintfMat(SAVEDIR+"output_donnes_primaires.tsv",output_donnes_primaires,format_spec);




// active population growth rate
txLact;
//Total population at the benchmark year (Capita)
Ltot0;
//Active population at the benchmark year (Capita)
Lact0;

//total and active population
total_population=zeros(reg,TimeHorizon+1);
active_population=zeros(reg,TimeHorizon+1);
total_population(:,1)=Ltot0;
active_population(:,1)=Lact0;
for k=2:TimeHorizon+1
total_population(:,k)=total_population(:,k-1).* Ltot ./ Ltot_prev;
active_population(:,k)=active_population(:,k-1).*(1+txLact(:,k-1));
end

//labor productivity growth rate
TC_l;

//Autonoçous energy efficiency gains
AEEI;

//Energy intensity of composite production
EI_composite_production=ones(reg,TimeHorizon+1);
for k=2:TimeHorizon+1
EI_composite_production(:,k)=EI_composite_production(:,k-1).*(1+AEEI(:,k-1));
end

//Cars energy intensity
				  
progresalphaEtauto=alphaEtauto./(alphaEtautoref*ones(1,TimeHorizon+1));
//Housing stock m2
//m2batiment=stockbatiment.*((m2batimentref)*ones(1,TimeHorizon+1));

Croissance_ideale=TC_l(:,1:TimeHorizon)+txLact(:,1:TimeHorizon);
//Croissance_realise=realGDPrate;

growth_analysis=zeros(2*reg,TimeHorizon+1);
for j=1:reg
	growth_analysis(2*j-1,1:TimeHorizon)=Croissance_ideale(j,1:TimeHorizon);
	growth_analysis(2*j,1:TimeHorizon)=Croissance_realise(j,1:TimeHorizon);
end


output_growth_analysis=growth_analysis;


////////////////////sorties banque mondiale
//indice pays chine
k=6;

//output_china_wb=[realGDP(k,1),realGDP(k,10),realGDP(k,20),realGDP(k,30),realGDP(k,40),realGDP(k,TimeHorizon+1)];

year=1;
Energy_balance_temp=matrix(energy_balance_stock(:,year),indice_matEner,8,reg);
Energy_balance_temp(:,:,k);

year=10;
Energy_balance_temp=matrix(energy_balance_stock(:,year),indice_matEner,8,reg);
Energy_balance_temp(:,:,k);

year=20;
Energy_balance_temp=matrix(energy_balance_stock(:,year),indice_matEner,8,reg);
Energy_balance_temp(:,:,k);

// year=30;
// Energy_balance_temp=matrix(energy_balance_stock(:,year),indice_matEner,8,reg);
// Energy_balance_temp(:,:,k);

// year=40;
// Energy_balance_temp=matrix(energy_balance_stock(:,year),indice_matEner,8,reg);
// Energy_balance_temp(:,:,k);

year=TimeHorizon+1;
Energy_balance_temp=matrix(energy_balance_stock(:,year),indice_matEner,8,reg);
Energy_balance_temp(:,:,k);

InvDem_reg=zeros(reg,TimeHorizon+1);
for k=1:TimeHorizon+1
InvDem_temp=matrix(InvDem(:,k),reg,sec)/num(k);
InvDem_reg(:,k)=sum(InvDem_temp,"c");
end


//ICOR moyen par période de 5 ans

//t=1;
//for k=0:9
//t=5*k+1;
//per=4;
//sum(NRB_n(:,t:t+per-1),"c")./(realGDP(:,t+per)-realGDP(:,t))
//end
//for k=0:9
//t=5*k+1;
//per=4;
//(sum(NRB_n(:,t:t+per),"c")./sum(GDP_n(:,t:t+per),"c"))./((realGDP(:,t+per)./realGDP(:,t)).^(1/(per+1)*ones(reg,1))-ones(reg,1))
//end
// ICOR=(NRB(:,2:TimeHorizon+1)./GDP(:,2:TimeHorizon+1))./realGDPrate(:,2:TimeHorizon+1);
// NRB_n=NRB./(ones(reg,1)*num);
// nb_periode_10_ans=(TimeHorizon+1)/10;

// ICOR_moyen=zeros(reg,nb_periode_10_ans);
// for k=0:nb_periode_10_ans-1
// per=9;
// t=(per+1)*k+1;
// ICOR_moyen(:,k+1)=(sum(NRB_n(:,t:t+per),"c")./sum(GDP_n(:,t:t+per),"c"))./((realGDP(:,t+per)./realGDP(:,t)).^(1/(per+1)*ones(reg,1))-ones(reg,1));
// end

// croissance_moyenne=zeros(reg,nb_periode_10_ans);
// for k=0:nb_periode_10_ans-1
// per=9;
// t=(per+1)*k+1;
// croissance_moyenne(:,k+1)=((realGDP(:,t+per)./realGDP(:,t)).^(1/(per+1)*ones(reg,1))-ones(reg,1));
// end

// investment_ratio_moyen=zeros(reg,nb_periode_10_ans);
// for k=0:nb_periode_10_ans-1
// per=9;
// t=(per+1)*k+1;
// investment_ratio_moyen(:,k+1)=(sum(NRB_n(:,t:t+per),"c")./sum(GDP_n(:,t:t+per),"c"));
// end

// ICOR_constant=zeros(reg,nb_periode_10_ans);
// for k=0:nb_periode_10_ans-1
// ICOR_constant(:,k+1)=ICOR_moyen(:,1);
// end

// investment_ratio_moyen_obj=ICOR_constant.*croissance_moyenne;
// var_inv_ratio_obj=max(investment_ratio_moyen_obj./(investment_ratio_moyen_obj(:,1)*ones(1,nb_periode_10_ans)),0.1);
// temps_10=[1,10,20,30,40,50,60,70,85,100];
// temps_tot=zeros(1,TimeHorizon+1);
// for k=1:TimeHorizon+1
// 	temps_tot(k)=k;
// end

// var_inv_ratio_obj_T=zeros(reg,TimeHorizon+1);
// for k=1:reg
// 	var_inv_ratio_obj_T(k,:)=interpln([temps_10;var_inv_ratio_obj(k,:)],temps_tot);
// end

// saving_obj_exo=var_inv_ratio_obj_T.*((1-ptcref)*ones(1,TimeHorizon+1));
// auto_invest_obj_exo=var_inv_ratio_obj_T.*((1-divref)*ones(1,TimeHorizon+1));
//mksav("saving_obj_exo","calib");
//mksav("auto_invest_obj_exo","calib");

// //nouveau calcul des taux d'épargne
// charge_comp=zeros(reg,TimeHorizon+1);
// for j=1:TimeHorizon+1
// 	charge_temp=matrix(charge(:,j),reg,sec);
// 	charge_comp(:,j)=charge_temp(:,indice_composite);
// end
// charge_comp_unit=charge_comp/0.8;
// saving_obj_exo=max(min(charge_comp_unit.*((1-ptcref)*ones(1,TimeHorizon+1)),0.45),0.05);
// auto_invest_obj_exo=max(min(charge_comp_unit.*((1-divref)*ones(1,TimeHorizon+1)),0.45),0.05);
//mksav("saving_obj_exo","calib");
//mksav("auto_invest_obj_exo","calib");



//Energy consumption by sectors (calcul de l'intensité énergétique par secteur (en énergie utile
ener_cons_per_sect=zeros(reg*sec,TimeHorizon+1);
ener_cons_per_sect_temp=zeros(reg,sec);
for current_time_im=1:TimeHorizon+1
	CI_temp=matrix(CI(:,current_time_im),sec,sec,reg);
	Q_temp=matrix(Q(:,current_time_im),reg,sec);
	for k=1:reg
		for j=(nbsecteurenergie+1):sec
//			ener_cons_per_sect_temp(k,j)=CI_temp(indice_coal,j,k)*Q_temp(k,j)*rhocoal+CI_temp(indice_oil,j,k)*Q_temp(k,j)*rhooil+CI_temp(indice_gaz,j,k)*Q_temp(k,j)*rhogaz+CI_temp(indice_Et,j,k)*Q(k,j)*rhooil+CI_temp(indice_elec,j,k)*Q_temp(k,j)*rhoelec;
			ener_cons_per_sect_temp(k,j)=CI_temp(indice_coal,j,k)*rhocoal+CI_temp(indice_oil,j,k)*rhooil+CI_temp(indice_gaz,j,k)*rhogaz+CI_temp(indice_Et,j,k)*rhooil+CI_temp(indice_elec,j,k)*rhoelec;
			
		end
	end
	ener_cons_per_sect(:,current_time_im)=matrix(ener_cons_per_sect_temp,reg*sec,1);
end






//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////// Sorties ONERC

//[Code_Regions,(alphaCoalm2+alphaEtm2+alphaGazm2+alphaelecm2))*11630*10^6];//en kWh par m2

//Calcul sur la consommation finale d'énergie
//odre fuel : Coal, Et, Gaz, Elec
//odre secteurs : Composite, industie, agriculture, transport, Résidentiel
FC_world_Fuel_Tot=zeros(4,TimeHorizon+1);
FC_world_tot_sectors=zeros(5,TimeHorizon+1);
FC_world_Et_sectors=zeros(5,TimeHorizon+1);
FC_world_Coal_sectors=zeros(5,TimeHorizon+1);
FC_world_Gaz_sectors=zeros(5,TimeHorizon+1);
FC_world_Elec_sectors=zeros(5,TimeHorizon+1);
FC_region_Tot_Tot=zeros(reg,TimeHorizon+1);
Code_Fuel_FC=[1;2;3;4];
Code_Sectors_FC=[1;2;3;4;5];
for j=1:TimeHorizon+1,
	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
	FC_world_Fuel_Tot(1,j)=sum(Energy_balance_temp(9,1,:));
	FC_world_Fuel_Tot(2,j)=sum(Energy_balance_temp(9,3,:));
	FC_world_Fuel_Tot(3,j)=sum(Energy_balance_temp(9,4,:));
	FC_world_Fuel_Tot(4,j)=sum(Energy_balance_temp(9,8,:));
	FC_world_tot_sectors(1,j)=sum(Energy_balance_temp(10,1:8,:));
	FC_world_tot_sectors(2,j)=sum(Energy_balance_temp(11,1:8,:));
	FC_world_tot_sectors(3,j)=sum(Energy_balance_temp(12,1:8,:));
	FC_world_tot_sectors(4,j)=sum(Energy_balance_temp(13:15,1:8,:));
	FC_world_tot_sectors(5,j)=sum(Energy_balance_temp(16,1:8,:));
	Fuel=3;
	FC_world_Et_sectors(1,j)=sum(Energy_balance_temp(10,Fuel,:));
	FC_world_Et_sectors(2,j)=sum(Energy_balance_temp(11,Fuel,:));
	FC_world_Et_sectors(3,j)=sum(Energy_balance_temp(12,Fuel,:));
	FC_world_Et_sectors(4,j)=sum(Energy_balance_temp(13:15,Fuel,:));
	FC_world_Et_sectors(5,j)=sum(Energy_balance_temp(16,Fuel,:));
	Fuel=1;
	FC_world_Coal_sectors(1,j)=sum(Energy_balance_temp(10,Fuel,:));
	FC_world_Coal_sectors(2,j)=sum(Energy_balance_temp(11,Fuel,:));
	FC_world_Coal_sectors(3,j)=sum(Energy_balance_temp(12,Fuel,:));
	FC_world_Coal_sectors(4,j)=sum(Energy_balance_temp(13:15,Fuel,:));
	FC_world_Coal_sectors(5,j)=sum(Energy_balance_temp(16,Fuel,:));
	Fuel=4;
	FC_world_Gaz_sectors(1,j)=sum(Energy_balance_temp(10,Fuel,:));
	FC_world_Gaz_sectors(2,j)=sum(Energy_balance_temp(11,Fuel,:));
	FC_world_Gaz_sectors(3,j)=sum(Energy_balance_temp(12,Fuel,:));
	FC_world_Gaz_sectors(4,j)=sum(Energy_balance_temp(13:15,Fuel,:));
	FC_world_Gaz_sectors(5,j)=sum(Energy_balance_temp(16,Fuel,:));
	Fuel=8;
	FC_world_Elec_sectors(1,j)=sum(Energy_balance_temp(10,Fuel,:));
	FC_world_Elec_sectors(2,j)=sum(Energy_balance_temp(11,Fuel,:));
	FC_world_Elec_sectors(3,j)=sum(Energy_balance_temp(12,Fuel,:));
	FC_world_Elec_sectors(4,j)=sum(Energy_balance_temp(13:15,Fuel,:));
	FC_world_Elec_sectors(5,j)=sum(Energy_balance_temp(16,Fuel,:));
	for k=1:reg
		FC_region_Tot_Tot(k,j)=sum(Energy_balance_temp(9,:,k));
	end
end



//Mix énergétique de la production d'électricité au niveau mondial
//power breakdown : Fuel shares of electricity generation [coal;Et;gaz;nuc;hydro;ENR] (electricity generated by each fuel in Mtep)
Fuel_shares_elec_gen_w=zeros(6,TimeHorizon+1);
for j=1:TimeHorizon
	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
	Cap_elec_MW_temp=matrix(Cap_elec_MW(:,j),reg,techno_elec);
	rho_elec_moyen_temp=matrix(rho_elec_moyen(:,j),reg,techno_elec);
	for country=1:reg
		if sum(Cap_elec_MW_temp(country,1:technoCoal))>0 
            Fuel_shares_elec_gen_w(1,j)=Fuel_shares_elec_gen_w(1,j)-Energy_balance_temp(7,1,country)*(sum(Cap_elec_MW_temp(country,1:technoCoal).*rho_elec_moyen_temp(country,1:technoCoal))/sum(Cap_elec_MW_temp(country,1:technoCoal)));
        end //coal 
		if sum(Cap_elec_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt))>0 
            Fuel_shares_elec_gen_w(2,j)=Fuel_shares_elec_gen_w(2,j)-Energy_balance_temp(7,3,country)*(sum(Cap_elec_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt).*rho_elec_moyen_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt))/sum(Cap_elec_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt)));
        end //Et
		if sum(Cap_elec_MW_temp(country,technoCoal+1:technoCoal+technoGas))>0 
            Fuel_shares_elec_gen_w(3,j)=Fuel_shares_elec_gen_w(3,j)-Energy_balance_temp(7,4,country)*(sum(Cap_elec_MW_temp(country,technoCoal+1:technoCoal+technoGas).*rho_elec_moyen_temp(country,technoCoal+1:technoCoal+technoGas))/sum(Cap_elec_MW_temp(country,technoCoal+1:technoCoal+technoGas)));
        end //gaz
		Fuel_shares_elec_gen_w(4,j)=Fuel_shares_elec_gen_w(4,j)-Energy_balance_temp(7,6,country)*0.33; //nuc
		Fuel_shares_elec_gen_w(5,j)=Fuel_shares_elec_gen_w(5,j)-Energy_balance_temp(7,5,country); //hydro
		Fuel_shares_elec_gen_w(6,j)=Fuel_shares_elec_gen_w(6,j)-Energy_balance_temp(7,7,country); 
	end
end

//Mix énergétique de la production d'électricité au niveau régional
//power breakdown : Fuel shares of electricity generation [coal;Et;gaz;nuc;hydro;ENR] (electricity generated by each fuel in Mtep)
Fuel_shares_elec_gen=zeros(6,TimeHorizon+1,reg);
for j=1:TimeHorizon+1
	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
	Cap_elec_MW_temp=matrix(Cap_elec_MW(:,j),reg,techno_elec);
	rho_elec_moyen_temp=matrix(rho_elec_moyen(:,j),reg,techno_elec);
	for country=1:reg
		if sum(Cap_elec_MW_temp(country,1:technoCoal))>0 
            Fuel_shares_elec_gen(1,j,country)=-Energy_balance_temp(7,1,country)*(sum(Cap_elec_MW_temp(country,1:technoCoal).*rho_elec_moyen_temp(country,1:technoCoal))/sum(Cap_elec_MW_temp(country,1:technoCoal)));
        end //coal 
		if sum(Cap_elec_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt))>0
            Fuel_shares_elec_gen(2,j,country)=-Energy_balance_temp(7,3,country)*(sum(Cap_elec_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt).*rho_elec_moyen_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt))/sum(Cap_elec_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt)));
        end //Et
		if sum(Cap_elec_MW_temp(country,technoCoal+1:technoCoal+technoGas))>0 
            Fuel_shares_elec_gen(3,j,country)=-Energy_balance_temp(7,4,country)*(sum(Cap_elec_MW_temp(country,technoCoal+1:technoCoal+technoGas).*rho_elec_moyen_temp(country,technoCoal+1:technoCoal+technoGas))/sum(Cap_elec_MW_temp(country,technoCoal+1:technoCoal+technoGas))); 
        end //gaz
		share_FF_ELE_prod=(Fuel_shares_elec_gen(1,j,country)+Fuel_shares_elec_gen(2,j,country)+Fuel_shares_elec_gen(3,j,country))/Energy_balance_temp(7,8,country);
		if j>1
			Fuel_shares_elec_gen(4,j,country)=(-Energy_balance_temp(7,6,country)*0.33)/(-Energy_balance_temp(7,6,country)*0.33-Energy_balance_temp(7,5,country)-Energy_balance_temp(7,7,country))*(1-share_FF_ELE_prod)*Energy_balance_temp(7,8,country); //nuc
			Fuel_shares_elec_gen(5,j,country)=-Energy_balance_temp(7,5,country)/(-Energy_balance_temp(7,6,country)*0.33-Energy_balance_temp(7,5,country)-Energy_balance_temp(7,7,country))*(1-share_FF_ELE_prod)*Energy_balance_temp(7,8,country); //hydro
			Fuel_shares_elec_gen(6,j,country)=-Energy_balance_temp(7,7,country)/(-Energy_balance_temp(7,6,country)*0.33-Energy_balance_temp(7,5,country)-Energy_balance_temp(7,7,country))*(1-share_FF_ELE_prod)*Energy_balance_temp(7,8,country); 
		end
	end
end
//Calculs sur la structure de la valeur ajoutée
//ordre des secteurs agriculture, industrie, reste
// VA_world_sectors=zeros(3,reg);
// for j=1:TimeHorizon+1
// VA_temp
// end
GDP_PPP_pc=GDPpc./(pref(:,indice_composite)*ones(1,TimeHorizon+1));

// output_ONERC=[...
// [Code_Regions,Ltot];
// [Code_Regions,Lact];
// [Code_Regions,GDP_PPP];
// [Code_Regions,GDP_PPP_pc];
// [Code_Regions,pkm_pc];
// [Code_Regions,nb_car_pc];
// [Code_Regions,alphaEtauto./(alphaEtautoref*ones(1,TimeHorizon+1))];
// [Code_Regions,stock_m2_pc];
// [Code_Regions,TPES./realGDP];
// [999,wp_n(indice_coal,1:TimeHorizon+1)];
// [999,wp_n(indice_oil,1:TimeHorizon+1)];
// [999,wp_n(indice_gaz,1:TimeHorizon+1)];
// [Code_Fuel_FC,FC_world_Fuel_Tot];
// [Code_Sectors_FC,FC_world_tot_sectors];
// [Code_Sectors_FC,FC_world_Et_sectors];
// [Code_Sectors_FC,FC_world_Coal_sectors];
// [Code_Sectors_FC,FC_world_Gaz_sectors];
// [Code_Sectors_FC,FC_world_Elec_sectors];
// [Code_Regions,FC_region_Tot_Tot];
// [[1;2;3;4;5;6],Fuel_shares_elec_gen_w];
// [Code_Regions,TPES]; //TPES by region
// [[1;2;3;4;5;6],TPES_world_Fuel]; //total world TPES by fuel
// [999,sum(EregCO2,"r")];
// [Code_Regions,EregCO2];
// [Code_Regions,EregCO2./Ltot]
// ];
// fprintfMat(SAVEDIR+"/output_ONERC.tsv",output_ONERC,"%5.8e;");


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////// Sorties EPE F4

mask_annex1=[[1 1 1 1 1 0 0 0 0 0 0 0];[0 0 0 0 0 1 1 1 1 1 1 1]];
E_CO2_annex1_row=zeros(2,TimeHorizon+1);
E_CO2_annex1_row=mask_annex1*EregCO2;

///////////////////////////////////Share of energy costs in sector budgets

Sh_ener_cost_sectors=zeros(reg*sec,TimeHorizon+1);
for current_time_im=1:TimeHorizon+1
	CI_temp=matrix(CI(:,current_time_im),sec,sec,reg);
	Q_temp=matrix(Q(:,current_time_im),reg,sec);
	pArmCI_temp=matrix(pArmCI(:,current_time_im),sec,sec,reg);
	p_temp=matrix(p(:,current_time_im),reg,sec);
	shenercostsectmp=zeros(reg,sec);
	for k=1:reg
		for j=1:sec
			shenercostsectmp(k,j)=sum(pArmCI_temp(1:nbsecteurenergie,j,k).*CI_temp(1:nbsecteurenergie,j,k))./(p_temp(k,j));
		end
	end
	Sh_ener_cost_sectors(:,current_time_im)=matrix(shenercostsectmp,reg*sec,1);
end
//indice des prix de l'énergie pour les secteurs
mksav("Sh_ener_cost_sectors.sav");
//pind=(sum(pArmDF.*DF,"c")./sum(pArmDFref.*DF,"c").*sum(pArmDF.*DFref,"c")./sum(pArmDFref.*DFref,"c"))^(1/2);
pind_ener_sectors=zeros(reg*sec,TimeHorizon+1);
for current_time_im=1:TimeHorizon+1
	CI_temp=matrix(CI(:,current_time_im),sec,sec,reg);
	Q_temp=matrix(Q(:,current_time_im),reg,sec);
	pArmCI_temp=matrix(pArmCI(:,current_time_im),sec,sec,reg);
	p_temp=matrix(p(:,current_time_im),reg,sec);
	pind_ener_sect_temp=zeros(reg,sec);
	for k=1:reg
		for j=1:sec
			sum1=0;
		    sum2=0;
		    sum3=0;
		    sum4=0;
			for jj=1:nbsecteurenergie	
				sum1=sum1+pArmCI_temp(jj,j,k)*CI_temp(jj,j,k)/p_temp(1,indice_composite);
				sum2=sum2+pArmCIref(jj,j,k)*CI_temp(jj,j,k);
				sum3=sum3+pArmCI_temp(jj,j,k)*CIref(jj,j,k)/p_temp(1,indice_composite);
				sum4=sum4+pArmCIref(jj,j,k)*CIref(jj,j,k);
			end
			if (sum2>0)&(sum4>0) then pind_ener_sect_temp(k,j)=(sum1./sum2.*sum3./sum4)^(1/2); end;		
		end
	end
	
	
	pind_ener_sectors(:,current_time_im)=matrix(pind_ener_sect_temp,reg*sec,1);
end
mksav("pind_ener_sectors");
//plot2d(pind_ener_sectors(reg*(indice_industrie-1)+1:reg*indice_industrie,:)');
////////////////////////////////////Share of sectors in GDP sectors taxes

Sh_sectors_GDP=zeros(reg*(sec+1),TimeHorizon+1);
for current_time_im=1:TimeHorizon+1
	VA_temp=matrix(VA(:,current_time_im),sec,reg);
	Sh_sectors_GDP_temp=zeros(reg,sec+1);
	for k=1:reg
		for j=1:sec
			Sh_sectors_GDP_temp(k,j)=VA_temp(k,j)/GDP(k,current_time_im);
		end
	end
	Sh_sectors_GDP_temp(:,sec+1)=1-sum(Sh_sectors_GDP_temp(:,1:sec),"c");
	Sh_sectors_GDP(:,current_time_im)=matrix(Sh_sectors_GDP_temp,reg*(sec+1),1);
end


//old scenario alternative : F4, see revision 29305 (F4=facteur4)



//sorties matrices energetiques AIE
Energy_output_IEA=zeros(73,TimeHorizon+1,reg);
for j=1:TimeHorizon+1
	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
	Energy_balance_temp_tot=zeros(indice_matEner,9,reg);
	for k=1:reg
		Energy_balance_temp_tot(:,1:8,k)=Energy_balance_temp(:,:,k);
		Energy_balance_temp_tot(:,9,k)=sum(Energy_balance_temp(:,:,k),"c");
	end
	Cap_elec_MW_temp=matrix(Cap_elec_MW(:,j),reg,techno_elec);
	for country=1:reg
		Energy_output_IEA(1 ,j,country)=Energy_balance_temp_tot(5,9,country);								//Total Primary Energy Supply  
		Energy_output_IEA(2 ,j,country)=Energy_balance_temp_tot(5,1,country);								//Coal  
		Energy_output_IEA(3 ,j,country)=Energy_balance_temp_tot(5,2,country);								//Oil  
		Energy_output_IEA(4 ,j,country)=Energy_balance_temp_tot(5,4,country);								//Gas  
		Energy_output_IEA(5 ,j,country)=Energy_balance_temp_tot(5,6,country);								//Nuclear  
		Energy_output_IEA(6 ,j,country)=Energy_balance_temp_tot(5,5,country);								//Hydro  
		Energy_output_IEA(7 ,j,country)=Energy_balance_temp_tot(5,7,country);								//Renewables
		Energy_output_IEA(8 ,j,country)=-Energy_balance_temp_tot(7,1,country)-Energy_balance_temp_tot(7,3,country)-Energy_balance_temp_tot(7,4,country)-Energy_balance_temp_tot(7,6,country)-Energy_balance_temp_tot(7,5,country)-Energy_balance_temp_tot(7,7,country);//Power Generation and Heat Plants  
		Energy_output_IEA(9 ,j,country)=-Energy_balance_temp_tot(7,1,country);								//Coal  
		Energy_output_IEA(10,j,country)=-Energy_balance_temp_tot(7,3,country);								//Oil  
		Energy_output_IEA(11,j,country)=-Energy_balance_temp_tot(7,4,country);								//Gas  
		Energy_output_IEA(12,j,country)=-Energy_balance_temp_tot(7,6,country);								//Nuclear  
		Energy_output_IEA(13,j,country)=-Energy_balance_temp_tot(7,5,country);								//Hydro  
		Energy_output_IEA(14,j,country)=-Energy_balance_temp_tot(7,7,country);								//Renewables  
		Energy_output_IEA(15,j,country)=-Energy_balance_temp_tot(8,1,country)-Energy_balance_temp_tot(8,2,country)-Energy_balance_temp_tot(8,3,country)-Energy_balance_temp_tot(8,4,country)-Energy_balance_temp_tot(8,8,country);////Other Transformation, Own Use and Losses  
		Energy_output_IEA(16,j,country)=-Energy_balance_temp_tot(8,8,country);								//of which electricity  
		Energy_output_IEA(17,j,country)=Energy_balance_temp_tot(9,9,country);								//Total Final Consumption  
		Energy_output_IEA(18,j,country)=Energy_balance_temp_tot(9,1,country);								//Coal  
		Energy_output_IEA(19,j,country)=Energy_balance_temp_tot(9,3,country);								//Liquid fuels  
		Energy_output_IEA(20,j,country)=Energy_balance_temp_tot(9,4,country);								//Gas  
		Energy_output_IEA(21,j,country)=Energy_balance_temp_tot(9,8,country);								//Electricity  
		Energy_output_IEA(22,j,country)=Energy_balance_temp_tot(9,7,country);								//Renewables  
		Energy_output_IEA(23,j,country)=Energy_balance_temp_tot(11,9,country);								//Agriculture
		Energy_output_IEA(24,j,country)=Energy_balance_temp_tot(11,1,country);								//Coal  
		Energy_output_IEA(25,j,country)=Energy_balance_temp_tot(11,3,country);								//Liquid fuels  
		Energy_output_IEA(26,j,country)=Energy_balance_temp_tot(11,4,country);								//Gas  
		Energy_output_IEA(27,j,country)=Energy_balance_temp_tot(11,8,country);								//Electricity
		Energy_output_IEA(28,j,country)=Energy_balance_temp_tot(11,7,country);								//Renewables
		Energy_output_IEA(29,j,country)=Energy_balance_temp_tot(12,9,country);								//Industry  
		Energy_output_IEA(30,j,country)=Energy_balance_temp_tot(12,1,country);								//Coal  
		Energy_output_IEA(31,j,country)=Energy_balance_temp_tot(12,3,country);								//Liquid fuels  
		Energy_output_IEA(32,j,country)=Energy_balance_temp_tot(12,4,country);								//Gas  
		Energy_output_IEA(33,j,country)=Energy_balance_temp_tot(12,8,country);								//Electricity  
		Energy_output_IEA(34,j,country)=Energy_balance_temp_tot(12,7,country);								//Renewables
		Energy_output_IEA(35,j,country)=Energy_balance_temp_tot(10,9,country);								//Services
		Energy_output_IEA(36,j,country)=Energy_balance_temp_tot(10,1,country);								//Coal  
		Energy_output_IEA(37,j,country)=Energy_balance_temp_tot(10,3,country);								//Liquid fuels  
		Energy_output_IEA(38,j,country)=Energy_balance_temp_tot(10,4,country);								//Gas  
		Energy_output_IEA(39,j,country)=Energy_balance_temp_tot(10,8,country);								//Electricity  
		Energy_output_IEA(40,j,country)=Energy_balance_temp_tot(10,7,country);								//Renewables
		Energy_output_IEA(41,j,country)=Energy_balance_temp_tot(17,9,country);								//Construction (BTP
		Energy_output_IEA(42,j,country)=Energy_balance_temp_tot(17,1,country);								//Coal  
		Energy_output_IEA(43,j,country)=Energy_balance_temp_tot(17,3,country);								//Liquid fuels 
		Energy_output_IEA(44,j,country)=Energy_balance_temp_tot(17,4,country);								//Gas  
		Energy_output_IEA(45,j,country)=Energy_balance_temp_tot(17,8,country);								//Electricity  
		Energy_output_IEA(46,j,country)=Energy_balance_temp_tot(17,7,country);								//Renewables
		Energy_output_IEA(47,j,country)=Energy_balance_temp_tot(13,9,country);								//Air transport (Liquid fuels)  
		Energy_output_IEA(48,j,country)=Energy_balance_temp_tot(14,9,country);								//Other transport
		Energy_output_IEA(49,j,country)=Energy_balance_temp_tot(14,3,country);								//Liquid fuels
		Energy_output_IEA(50,j,country)=Energy_balance_temp_tot(14,8,country);								//Electricity
		Energy_output_IEA(51,j,country)=Energy_balance_temp_tot(15,9,country);								//Private automobile
		Energy_output_IEA(52,j,country)=Energy_balance_temp_tot(15,3,country);								//Liquid fuels
		Energy_output_IEA(53,j,country)=Energy_balance_temp_tot(15,8,country);								//Electricity
		Energy_output_IEA(54,j,country)=Energy_balance_temp_tot(16,9,country);								//Residential
		Energy_output_IEA(55,j,country)=Energy_balance_temp_tot(16,1,country);								//Coal  
		Energy_output_IEA(56,j,country)=Energy_balance_temp_tot(16,3,country);								//Liquid fuels  
		Energy_output_IEA(57,j,country)=Energy_balance_temp_tot(16,4,country);								//Gas  
		Energy_output_IEA(58,j,country)=Energy_balance_temp_tot(16,8,country);								//Electricity  
		Energy_output_IEA(59,j,country)=Energy_balance_temp_tot(16,7,country);								//Renewables
		Energy_output_IEA(60,j,country)=Energy_balance_temp_tot(7,8,country);								//Electricity Generation (Mtep)
		Energy_output_IEA(61,j,country)=Fuel_shares_elec_gen(1,j,country);											//Coal             	
		Energy_output_IEA(62,j,country)=Fuel_shares_elec_gen(2,j,country);											//Oil              
		Energy_output_IEA(63,j,country)=Fuel_shares_elec_gen(3,j,country);											//Gas              	
		Energy_output_IEA(64,j,country)=Fuel_shares_elec_gen(4,j,country);											//Nuclear          	
		Energy_output_IEA(65,j,country)=Fuel_shares_elec_gen(5,j,country);											//Hydro            
		Energy_output_IEA(66,j,country)=Fuel_shares_elec_gen(6,j,country);											//Renewables
		Energy_output_IEA(67,j,country)=sum(Cap_elec_MW_temp(country,:));													//Total Capacity (MW)
		Energy_output_IEA(68,j,country)=sum(Cap_elec_MW_temp(country,1:technoCoal));										//Coal
		Energy_output_IEA(69,j,country)=sum(Cap_elec_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt));//Oil
		Energy_output_IEA(70,j,country)=sum(Cap_elec_MW_temp(country,technoCoal+1:technoCoal+technoGas));					//Gas
		Energy_output_IEA(71,j,country)=sum(Cap_elec_MW_temp(country,indice_NUC:indice_NND));								//Nuclear
		Energy_output_IEA(72,j,country)=Cap_elec_MW_temp(country,indice_HYD);												//Hydro
		Energy_output_IEA(73,j,country)=sum(Cap_elec_MW_temp(country,indice_CHP:indice_HFC));								//Renewables	end                   
	end
end

Energy_output_IEA_agreg=zeros(73,TimeHorizon+1,reg+3);
for k=1:reg
  Energy_output_IEA_agreg(:,:,k)=Energy_output_IEA(:,:,k);
end
for k=1:5
  Energy_output_IEA_agreg(:,:,reg+1)=Energy_output_IEA_agreg(:,:,reg+1)+Energy_output_IEA(:,:,k);
end
for k=6:reg
  Energy_output_IEA_agreg(:,:,reg+2)=Energy_output_IEA_agreg(:,:,reg+2)+Energy_output_IEA(:,:,k);
end
for k=1:reg
  Energy_output_IEA_agreg(:,:,reg+3)=Energy_output_IEA_agreg(:,:,reg+3)+Energy_output_IEA(:,:,k);
end

Output_Energy_IEA=zeros(73*(reg+3),TimeHorizon+1);
for k=1:reg+3
	Output_Energy_IEA(73*(k-1)+1:73*(k),:)=Energy_output_IEA_agreg(:,:,k);
end

mkcsv("Output_Energy_IEA.tsv");

//////////////////////////////////////////////Calculs Nexus electrique
//durée d'utilisation moyenne du parc electrique
duree_util_moy_tech_elec=zeros(reg,TimeHorizon+1);
for j=1:TimeHorizon+1
	for country=1:reg
		duree_util_moy_tech_elec(country,j)=Energy_output_IEA(63,j,country)*11630000/(Energy_output_IEA(70,j,country)+%eps);
	end
end


Energy_output_IEA_format=zeros(110,TimeHorizon+1,reg+1);
for j=1:TimeHorizon+1
	Energy_balance_temp=matrix(energy_balance_stock(:,j),indice_matEner,8,reg);
	Energy_balance_temp_tot=zeros(indice_matEner,9,reg);
	for k=1:reg
		Energy_balance_temp_tot(:,1:8,k)=Energy_balance_temp(:,:,k);
		Energy_balance_temp_tot(:,9,k)=sum(Energy_balance_temp(:,:,k),"c");
	end
	Cap_elec_MW_temp=matrix(Cap_elec_MW(:,j),reg,techno_elec);
	for country=1:reg
		Energy_output_IEA_format(1  ,j,country)=Energy_balance_temp_tot(5,9,country);//+TFC_IND_WWF_12(country,j)+TFC_RAS_WWF_12(country,j)+TFC_TRA_WWF_12(country,j);   // Total Primary Energy Supply (Mtoe)
		Energy_output_IEA_format(2  ,j,country)=Energy_balance_temp_tot(5,1,country);   //      Coal                         
		Energy_output_IEA_format(3  ,j,country)=Energy_balance_temp_tot(5,2,country)+Energy_balance_temp_tot(5,3,country);   //      Oil                          
		Energy_output_IEA_format(4  ,j,country)=Energy_balance_temp_tot(5,4,country);   //      Gas                          
		Energy_output_IEA_format(5  ,j,country)=Energy_balance_temp_tot(5,6,country);   //      Nuclear                      
		Energy_output_IEA_format(6  ,j,country)=Energy_balance_temp_tot(5,5,country);   //      Hydro                        
		Energy_output_IEA_format(7  ,j,country)=0;//TFC_IND_WWF_12(country,j)+TFC_RAS_WWF_12(country,j)+TFC_TRA_WWF_12(country,j);                                      //      Biomass & Waste              
		Energy_output_IEA_format(8  ,j,country)=Energy_balance_temp_tot(5,7,country);   //      Other Renewables             
		Energy_output_IEA_format(9  ,j,country)=0;                                      //      Other Primary                
		Energy_output_IEA_format(10 ,j,country)=-Energy_balance_temp_tot(7,1,country)-Energy_balance_temp_tot(7,3,country)-Energy_balance_temp_tot(7,4,country)-Energy_balance_temp_tot(7,6,country)-Energy_balance_temp_tot(7,5,country)-Energy_balance_temp_tot(7,7,country);//Power Generation and Heat Plants  
		Energy_output_IEA_format(11 ,j,country)=-Energy_balance_temp_tot(7,1,country);  //      Coal                              
		Energy_output_IEA_format(12 ,j,country)=-Energy_balance_temp_tot(7,3,country)-Energy_balance_temp_tot(7,2,country);  //      Oil                               
		Energy_output_IEA_format(13 ,j,country)=-Energy_balance_temp_tot(7,4,country);  //      Gas                               
		Energy_output_IEA_format(14 ,j,country)=-Energy_balance_temp_tot(7,6,country);  //      Nuclear                           
		Energy_output_IEA_format(15 ,j,country)=-Energy_balance_temp_tot(7,5,country);  //      Hydro                             
		Energy_output_IEA_format(16 ,j,country)=0;                                      //      Biomass & Waste                   
		Energy_output_IEA_format(17 ,j,country)=-Energy_balance_temp_tot(7,7,country);  //      Other Renewables                  
		Energy_output_IEA_format(18 ,j,country)=-Energy_balance_temp_tot(8,9,country);   // Other Transformation and losses (Mtoe)            					                                                                                                                                                                                              
		Energy_output_IEA_format(19 ,j,country)=-Energy_balance_temp_tot(8,1,country);  //      Coal                              
		Energy_output_IEA_format(20 ,j,country)=-Energy_balance_temp_tot(8,2,country)-Energy_balance_temp_tot(8,3,country)-Energy_balance_temp_tot(6,2,country)-Energy_balance_temp_tot(6,3,country);  //      Oil                               
		Energy_output_IEA_format(21 ,j,country)=-Energy_balance_temp_tot(8,4,country);  //      Gas                               
		Energy_output_IEA_format(22 ,j,country)=-Energy_balance_temp_tot(8,8,country);  //      Electricity                       
		Energy_output_IEA_format(23 ,j,country)=0;                                      //      Heat                              
		Energy_output_IEA_format(24 ,j,country)=0;                                      //      Biomass & Waste                   
		Energy_output_IEA_format(25 ,j,country)=0;                                      //     Other  Renewables                  
		Energy_output_IEA_format(26 ,j,country)=Energy_balance_temp_tot(9,9,country);//+TFC_IND_HEA_12(country,j)+TFC_IND_WWF_12(country,j)+TFC_RAS_HEA_12(country,j)+TFC_RAS_WWF_12(country,j)+TFC_TRA_HEA_12(country,j)+TFC_TRA_WWF_12(country,j);   // Total Final Consumption (Mtoe)         
		Energy_output_IEA_format(27 ,j,country)=Energy_balance_temp_tot(9,1,country);   //      Coal                              
		Energy_output_IEA_format(28 ,j,country)=Energy_balance_temp_tot(9,3,country);   //      Oil                               
		Energy_output_IEA_format(29 ,j,country)=Energy_balance_temp_tot(9,4,country);   //      Gas                               
		Energy_output_IEA_format(30 ,j,country)=Energy_balance_temp_tot(9,8,country);   //      Electricity                       
		Energy_output_IEA_format(31 ,j,country)=0;//TFC_IND_HEA_12(country,j)+TFC_RAS_HEA_12(country,j)+TFC_TRA_HEA_12(country,j);//      Heat                              
		Energy_output_IEA_format(32 ,j,country)=0;//TFC_IND_WWF_12(country,j)+TFC_RAS_WWF_12(country,j)+TFC_TRA_WWF_12(country,j);//      Biomass & Waste                   
		Energy_output_IEA_format(33 ,j,country)=0;                                      //     Other  Renewables                  
		Energy_output_IEA_format(34 ,j,country)=Energy_balance_temp_tot(12,9,country)+Energy_balance_temp_tot(17,9,country);//+TFC_IND_HEA_12(country,j)+TFC_IND_WWF_12(country,j);// Industry (Mtoe) + construction                       
		Energy_output_IEA_format(35 ,j,country)=Energy_balance_temp_tot(12,1,country)+Energy_balance_temp_tot(17,1,country);// Coal                              
		Energy_output_IEA_format(36 ,j,country)=Energy_balance_temp_tot(12,3,country)+Energy_balance_temp_tot(17,3,country);// Oil                               
		Energy_output_IEA_format(37 ,j,country)=Energy_balance_temp_tot(12,4,country)+Energy_balance_temp_tot(17,4,country);// Gas                               
		Energy_output_IEA_format(38 ,j,country)=Energy_balance_temp_tot(12,8,country)+Energy_balance_temp_tot(17,8,country);// Electricity                       
		Energy_output_IEA_format(39 ,j,country)=0;//TFC_IND_HEA_12(country,j);              //      Heat                          
		Energy_output_IEA_format(40 ,j,country)=0;//TFC_IND_WWF_12(country,j);              //      Biomass & Waste               
		Energy_output_IEA_format(41 ,j,country)=Energy_balance_temp_tot(12,7,country)+Energy_balance_temp_tot(17,7,country);//Other  Renewables                  
		Energy_output_IEA_format(42 ,j,country)=sum(Energy_balance_temp_tot(13:15,9,country));//+TFC_TRA_HEA_12(country,j);//+TFC_TRA_WWF_12(country,j);// Transportation (Mtoe)                  
		Energy_output_IEA_format(43 ,j,country)=sum(Energy_balance_temp_tot(13:15,1,country));//      Coal                              
		Energy_output_IEA_format(44 ,j,country)=sum(Energy_balance_temp_tot(13:15,3,country));//      Oil                               
		Energy_output_IEA_format(45 ,j,country)=sum(Energy_balance_temp_tot(13:15,4,country));//      Gas                               
		Energy_output_IEA_format(46 ,j,country)=sum(Energy_balance_temp_tot(13:15,8,country));//      Electricity                       
		Energy_output_IEA_format(47 ,j,country)=0;//TFC_TRA_HEA_12(country,j);                    //      Heat                              
		Energy_output_IEA_format(48 ,j,country)=0;//TFC_TRA_WWF_12(country,j);                    //      Biomass & Waste                   
		Energy_output_IEA_format(49 ,j,country)=sum(Energy_balance_temp_tot(13:15,7,country));//      Other Renewables                  
		Energy_output_IEA_format(50 ,j,country)=sum(Energy_balance_temp_tot(10:11,9,country))+Energy_balance_temp_tot(16,9,country);//+TFC_RAS_HEA_12(country,j)+TFC_RAS_WWF_12(country,j);// Other Sectors (Mtoe)                   
		Energy_output_IEA_format(51 ,j,country)=sum(Energy_balance_temp_tot(10:11,1,country))+Energy_balance_temp_tot(16,1,country);//      Coal                              
		Energy_output_IEA_format(52 ,j,country)=sum(Energy_balance_temp_tot(10:11,3,country))+Energy_balance_temp_tot(16,3,country);//      Oil                               
		Energy_output_IEA_format(53 ,j,country)=sum(Energy_balance_temp_tot(10:11,4,country))+Energy_balance_temp_tot(16,4,country);//      Gas                               
		Energy_output_IEA_format(54 ,j,country)=sum(Energy_balance_temp_tot(10:11,8,country))+Energy_balance_temp_tot(16,8,country);//      Electricity                       
		Energy_output_IEA_format(55 ,j,country)=0;//TFC_RAS_HEA_12(country,j);                    //      Heat                              
		Energy_output_IEA_format(56 ,j,country)=0;//TFC_RAS_WWF_12(country,j);                    //      Biomass & Waste                   
		Energy_output_IEA_format(57 ,j,country)=sum(Energy_balance_temp_tot(10:11,7,country))+Energy_balance_temp_tot(16,7,country);//      Other Renewables                  
		Energy_output_IEA_format(58 ,j,country)=Energy_balance_temp_tot(16,9,country);//+TFC_RES_HEA_12(country,j)+TFC_RES_WWF_12(country,j);  // Residential (Mtoe)                     
		Energy_output_IEA_format(59 ,j,country)=Energy_balance_temp_tot(16,1,country);  //      Coal                              
		Energy_output_IEA_format(60 ,j,country)=Energy_balance_temp_tot(16,3,country);  //      Oil                               
		Energy_output_IEA_format(61 ,j,country)=Energy_balance_temp_tot(16,4,country);  //      Gas                               
		Energy_output_IEA_format(62 ,j,country)=Energy_balance_temp_tot(16,8,country);  //      Electricity                       
		Energy_output_IEA_format(63 ,j,country)=0;//TFC_RES_HEA_12(country,j);              //      Heat                              
		Energy_output_IEA_format(64 ,j,country)=0;//TFC_RES_WWF_12(country,j);              //      Biomass & Waste                   
		Energy_output_IEA_format(65 ,j,country)=Energy_balance_temp_tot(16,7,country);  //      Other Renewables                  
		Energy_output_IEA_format(66 ,j,country)=Energy_balance_temp_tot(10,9,country);//+TFC_SER_HEA_12(country,j)+TFC_SER_WWF_12(country,j);  // Services (Mtoe)                        
		Energy_output_IEA_format(67 ,j,country)=Energy_balance_temp_tot(10,1,country);  //      Coal                              
		Energy_output_IEA_format(68 ,j,country)=Energy_balance_temp_tot(10,3,country);  //      Oil                               
		Energy_output_IEA_format(69 ,j,country)=Energy_balance_temp_tot(10,4,country);  //      Gas                               
		Energy_output_IEA_format(70 ,j,country)=Energy_balance_temp_tot(10,8,country);  //      Electricity                       
		Energy_output_IEA_format(71 ,j,country)=0;//TFC_SER_HEA_12(country,j);              //      Heat                              
		Energy_output_IEA_format(72 ,j,country)=0;//TFC_SER_WWF_12(country,j);              //      Biomass & Waste                   
		Energy_output_IEA_format(73 ,j,country)=Energy_balance_temp_tot(10,7,country);  //      Other Renewables                  
		Energy_output_IEA_format(74 ,j,country)=Energy_balance_temp_tot(11,9,country);//+TFC_AGR_HEA_12(country,j)+TFC_AGR_WWF_12(country,j);  // Agriculture (Mtoe)                     
		Energy_output_IEA_format(75 ,j,country)=Energy_balance_temp_tot(11,1,country);  //      Coal                              
		Energy_output_IEA_format(76 ,j,country)=Energy_balance_temp_tot(11,3,country);  //      Oil                               
		Energy_output_IEA_format(77 ,j,country)=Energy_balance_temp_tot(11,4,country);  //      Gas                               
		Energy_output_IEA_format(78 ,j,country)=Energy_balance_temp_tot(11,8,country);  //      Electricity                       
		Energy_output_IEA_format(79 ,j,country)=0;//TFC_AGR_HEA_12(country,j);              //      Heat                              
		Energy_output_IEA_format(80 ,j,country)=0;//TFC_AGR_WWF_12(country,j);              //      Biomass & Waste                   
		Energy_output_IEA_format(81 ,j,country)=Energy_balance_temp_tot(11,7,country);  //      Other Renewables                  
		Energy_output_IEA_format(82 ,j,country)=0;                                      // Non Energy Use (Mtoe)                  
		Energy_output_IEA_format(83 ,j,country)=0;                                      //      Coal                              
		Energy_output_IEA_format(84 ,j,country)=0;                                      //      Oil                               
		Energy_output_IEA_format(85 ,j,country)=0;                                      //      Gas                               
		Energy_output_IEA_format(86 ,j,country)=0;                                      //      Electricity                       
		Energy_output_IEA_format(87 ,j,country)=0;                                      //      Heat                              
		Energy_output_IEA_format(88 ,j,country)=0;                                      //      Biomass & Waste                   
		Energy_output_IEA_format(89 ,j,country)=0;                                      //      Other Renewables                  
		Energy_output_IEA_format(90 ,j,country)=Energy_balance_temp_tot(7,8,country)*11630000/1000000;   // Electricity Output (TWh)               
		Energy_output_IEA_format(91 ,j,country)=Fuel_shares_elec_gen(1,j,country)*11630000/1000000;      //      Coal                              
		Energy_output_IEA_format(92 ,j,country)=Fuel_shares_elec_gen(2,j,country)*11630000/1000000;      //      Oil                               
		Energy_output_IEA_format(93 ,j,country)=Fuel_shares_elec_gen(3,j,country)*11630000/1000000;      //      Gas                               
		Energy_output_IEA_format(94 ,j,country)=Fuel_shares_elec_gen(4,j,country)*11630000/1000000;      //      Nuclear                           
		Energy_output_IEA_format(95 ,j,country)=Fuel_shares_elec_gen(5,j,country)*11630000/1000000;      //      Hydro                             
		Energy_output_IEA_format(96 ,j,country)=0;                                                       //      Biomass & Waste                   
		Energy_output_IEA_format(97 ,j,country)=Fuel_shares_elec_gen(6,j,country)*11630000/1000000;      //      Other Renewables                  
		Energy_output_IEA_format(98 ,j,country)=0;                                      //      Hydrogen                          
		Energy_output_IEA_format(99 ,j,country)=realGDP(country,j);                       // GDP                                    
		Energy_output_IEA_format(100,j,country)=Ltot(country,j);                          // Population                             
		Energy_output_IEA_format(101,j,country)=0;                                      // Energy Intensity (toe/1000$)           
		Energy_output_IEA_format(102,j,country)=0;                                      // TPES/capita                            
		Energy_output_IEA_format(103,j,country)=0;                                      // GDP/capita                             
		Energy_output_IEA_format(104,j,country)=0;                                      // Electricity Output/capita              
		Energy_output_IEA_format(105,j,country)=0;                                      // CO2 Total/capita                       
		Energy_output_IEA_format(106,j,country)=0;                                      // Energy Prices                          
		Energy_output_IEA_format(107,j,country)=(wp(indice_coal,j)/num(j))/wpref(indice_coal)*42.3;// Coal (Real  per Metric Tonne) valeur initiale tirée de Output_World IEA 2001         
		Energy_output_IEA_format(108,j,country)=(wp(indice_oil,j)/num(j))/wpref(indice_oil)*25.9;  // Oil (Real  per Barrel) valeur initiale tirée de Output_World IEA 2001                
		Energy_output_IEA_format(109,j,country)=(wp(indice_gaz,j)/num(j))/wpref(indice_gaz)*188.6; // Natural Gas (Real  per 1000 cubic feet) valeur initiale tirée de Output_World IEA 2001
		Energy_output_IEA_format(110,j,country)=Energy_balance_temp_tot(15,3,country);			//private cars, oil
	end
end
//on somme les régions pour obtenir le monde
for k=1:reg
	Energy_output_IEA_format(:,:,reg+1)=Energy_output_IEA_format(:,:,reg+1)+Energy_output_IEA_format(:,:,k);
end


chdir(TECH+"Data_iea\");

/////////////////////////////////scenario RS
//TFC
load("TFC_TOT_RS_12.sav");
	//Industry
load("TFC_INDU_COL_RS_12.sav");
load("TFC_INDU_OIL_RS_12.sav");
load("TFC_INDU_GAS_RS_12.sav");
load("TFC_INDU_ELE_RS_12.sav");
load("TFC_INDU_TOT_RS_12.sav");
	//Residential sector
load("TFC_RESI_TOT_RS_12.sav");
load("TFC_RESI_COL_RS_12.sav");
load("TFC_RESI_OIL_RS_12.sav");
load("TFC_RESI_GAS_RS_12.sav");
load("TFC_RESI_ELE_RS_12.sav");
	//Services
load("TFC_SERV_COL_RS_12.sav");
load("TFC_SERV_OIL_RS_12.sav");
load("TFC_SERV_GAS_RS_12.sav");
load("TFC_SERV_ELE_RS_12.sav");
load("TFC_SERV_TOT_RS_12.sav");
	//Agriculture
load("TFC_AGRI_COL_RS_12.sav");
load("TFC_AGRI_OIL_RS_12.sav");
load("TFC_AGRI_GAS_RS_12.sav");
load("TFC_AGRI_ELE_RS_12.sav");
load("TFC_AGRI_TOT_RS_12.sav");
	//Transportation sector
load("TFC_TROD_TOT_RS_12.sav");
load("TFC_TRANS_TOT_RS_12.sav");
load("TFC_TRANS_COL_RS_12.sav");
load("TFC_TRANS_OIL_RS_12.sav");
load("TFC_TRANS_GAS_RS_12.sav");
load("TFC_TRANS_ELE_RS_12.sav");
	//Non Energy Use
load("TFC_NENU_TOT_RS_12.sav");
//Other Energy Sectors
load("OES_TOT_RS_12.sav");
load("OES_COL_RS_12.sav");
load("OES_OIL_RS_12.sav");
load("OES_GAS_RS_12.sav");
load("OES_ELE_RS_12.sav");
//Power Generation and Heat Plant 
load("PGH_TOT_RS_12.sav");
load("PGH_IELE_COL_RS_12.sav");
load("PGH_IELE_OIL_RS_12.sav");
load("PGH_IELE_GAS_RS_12.sav");

//TPES//
load("TPES_RS_12.sav");
load("TPES_COL_RS_12.sav");
load("TPES_OIL_RS_12.sav");
load("TPES_GAS_RS_12.sav");

//GDP//
load("ACT_GENE_GDP_RS_12.sav");

//////////////////////////////////// scenario APS

//TFC
load("TFC_TOT_APS_12.sav");
	//Industry
load("TFC_INDU_COL_APS_12.sav");
load("TFC_INDU_OIL_APS_12.sav");
load("TFC_INDU_GAS_APS_12.sav");
load("TFC_INDU_ELE_APS_12.sav");
load("TFC_INDU_TOT_APS_12.sav");
	//Residential sector
load("TFC_RESI_TOT_APS_12.sav");
load("TFC_RESI_COL_APS_12.sav");
load("TFC_RESI_OIL_APS_12.sav");
load("TFC_RESI_GAS_APS_12.sav");
load("TFC_RESI_ELE_APS_12.sav");
	//Services
load("TFC_SERV_COL_APS_12.sav");
load("TFC_SERV_OIL_APS_12.sav");
load("TFC_SERV_GAS_APS_12.sav");
load("TFC_SERV_ELE_APS_12.sav");
load("TFC_SERV_TOT_APS_12.sav");
	//Agriculture
load("TFC_AGRI_COL_APS_12.sav");
load("TFC_AGRI_OIL_APS_12.sav");
load("TFC_AGRI_GAS_APS_12.sav");
load("TFC_AGRI_ELE_APS_12.sav");
load("TFC_AGRI_TOT_APS_12.sav");
	//Transportation sector
load("TFC_TROD_TOT_APS_12.sav");
load("TFC_TRANS_TOT_APS_12.sav");
load("TFC_TRANS_COL_APS_12.sav");
load("TFC_TRANS_OIL_APS_12.sav");
load("TFC_TRANS_GAS_APS_12.sav");
load("TFC_TRANS_ELE_APS_12.sav");
	//Non Energy Use
load("TFC_NENU_TOT_APS_12.sav");
//Other Energy Sectors
load("OES_TOT_APS_12.sav");
load("OES_COL_APS_12.sav");
load("OES_OIL_APS_12.sav");
load("OES_GAS_APS_12.sav");
load("OES_ELE_APS_12.sav");
//Power Generation and Heat Plant 
load("PGH_TOT_APS_12.sav");
load("PGH_IELE_COL_APS_12.sav");
load("PGH_IELE_OIL_APS_12.sav");
load("PGH_IELE_GAS_APS_12.sav");
//TPES//
load("TPES_APS_12.sav");
load("TPES_COL_APS_12.sav");
load("TPES_OIL_APS_12.sav");
load("TPES_GAS_APS_12.sav");
//GDP//
load("ACT_GENE_GDP_APS_12.sav");



chdir(MODEL);
comparaison_results_IEA=zeros(104,30,reg);

	for k=1:reg
		comparaison_results_IEA(1 ,:,k)=TPES_COL_RS_12(k,:);
		comparaison_results_IEA(2 ,:,k)=TPES_COL_APS_12(k,:);
		comparaison_results_IEA(3 ,1:30,k)=Energy_output_IEA_format(2,1:30,k);
		comparaison_results_IEA(4 ,1:30,k)=TPES_OIL_RS_12(k,:);
		comparaison_results_IEA(5 ,1:30,k)=TPES_OIL_APS_12(k,:);
		comparaison_results_IEA(6 ,1:30,k)=Energy_output_IEA_format(3,1:30,k);
		comparaison_results_IEA(7 ,1:30,k)=TPES_GAS_RS_12(k,:);
		comparaison_results_IEA(8 ,1:30,k)=TPES_GAS_APS_12(k,:);
		comparaison_results_IEA(9 ,1:30,k)=Energy_output_IEA_format(4,1:30,k);
		comparaison_results_IEA(10,1:30,k)=TFC_INDU_COL_RS_12(k,:);
		comparaison_results_IEA(11,1:30,k)=TFC_INDU_COL_APS_12(k,:);
		comparaison_results_IEA(12,1:30,k)=Energy_output_IEA_format(35,1:30,k);
		comparaison_results_IEA(13,1:30,k)=TFC_INDU_OIL_RS_12(k,:);
		comparaison_results_IEA(14,1:30,k)=TFC_INDU_OIL_APS_12(k,:);
		comparaison_results_IEA(15,1:30,k)=Energy_output_IEA_format(36,1:30,k);
		comparaison_results_IEA(16,1:30,k)=TFC_INDU_GAS_RS_12(k,:);
		comparaison_results_IEA(17,1:30,k)=TFC_INDU_GAS_APS_12(k,:);
		comparaison_results_IEA(18,1:30,k)=Energy_output_IEA_format(37,1:30,k);
		comparaison_results_IEA(19,1:30,k)=TFC_INDU_ELE_RS_12(k,:);
		comparaison_results_IEA(20,1:30,k)=TFC_INDU_ELE_APS_12(k,:);
		comparaison_results_IEA(21,1:30,k)=Energy_output_IEA_format(38,1:30,k);
		comparaison_results_IEA(22,1:30,k)=TFC_TRANS_COL_RS_12(k,:);
		comparaison_results_IEA(23,1:30,k)=TFC_TRANS_COL_APS_12(k,:);
		comparaison_results_IEA(24,1:30,k)=Energy_output_IEA_format(43,1:30,k);
		comparaison_results_IEA(25,1:30,k)=TFC_TRANS_OIL_RS_12(k,:);
		comparaison_results_IEA(26,1:30,k)=TFC_TRANS_OIL_APS_12(k,:);
		comparaison_results_IEA(27,1:30,k)=Energy_output_IEA_format(44,1:30,k);
		comparaison_results_IEA(28,1:30,k)=TFC_TRANS_GAS_RS_12(k,:);
		comparaison_results_IEA(29,1:30,k)=TFC_TRANS_GAS_APS_12(k,:);
		comparaison_results_IEA(30,1:30,k)=Energy_output_IEA_format(45,1:30,k);
		comparaison_results_IEA(31,1:30,k)=TFC_TRANS_ELE_RS_12(k,:);
		comparaison_results_IEA(32,1:30,k)=TFC_TRANS_ELE_APS_12(k,:);
		comparaison_results_IEA(33,1:30,k)=Energy_output_IEA_format(46,1:30,k);
		comparaison_results_IEA(34,1:30,k)=TFC_RESI_COL_RS_12(k,:);
		comparaison_results_IEA(35,1:30,k)=TFC_RESI_COL_APS_12(k,:);
		comparaison_results_IEA(36,1:30,k)=Energy_output_IEA_format(59,1:30,k);
		comparaison_results_IEA(37,1:30,k)=TFC_RESI_OIL_RS_12(k,:);
		comparaison_results_IEA(38,1:30,k)=TFC_RESI_OIL_APS_12(k,:);
		comparaison_results_IEA(39,1:30,k)=Energy_output_IEA_format(60,1:30,k);
		comparaison_results_IEA(40,1:30,k)=TFC_RESI_GAS_RS_12(k,:);
		comparaison_results_IEA(41,1:30,k)=TFC_RESI_GAS_APS_12(k,:);
		comparaison_results_IEA(42,1:30,k)=Energy_output_IEA_format(61,1:30,k);
		comparaison_results_IEA(43,1:30,k)=TFC_RESI_ELE_RS_12(k,:);
		comparaison_results_IEA(44,1:30,k)=TFC_RESI_ELE_APS_12(k,:);
		comparaison_results_IEA(45,1:30,k)=Energy_output_IEA_format(62,1:30,k);
		comparaison_results_IEA(46,1:30,k)=TFC_AGRI_COL_RS_12(k,:);
		comparaison_results_IEA(47,1:30,k)=TFC_AGRI_COL_APS_12(k,:);
		comparaison_results_IEA(48,1:30,k)=Energy_output_IEA_format(75,1:30,k);
		comparaison_results_IEA(49,1:30,k)=TFC_AGRI_OIL_RS_12(k,:);
		comparaison_results_IEA(50,1:30,k)=TFC_AGRI_OIL_APS_12(k,:);
		comparaison_results_IEA(51,1:30,k)=Energy_output_IEA_format(76,1:30,k);
		comparaison_results_IEA(52,1:30,k)=TFC_AGRI_GAS_RS_12(k,:);
		comparaison_results_IEA(53,1:30,k)=TFC_AGRI_GAS_APS_12(k,:);
		comparaison_results_IEA(54,1:30,k)=Energy_output_IEA_format(77,1:30,k);
		comparaison_results_IEA(55,1:30,k)=TFC_AGRI_ELE_RS_12(k,:);
		comparaison_results_IEA(56,1:30,k)=TFC_AGRI_ELE_APS_12(k,:);
		comparaison_results_IEA(57,1:30,k)=Energy_output_IEA_format(78,1:30,k);
		comparaison_results_IEA(58,1:30,k)=TFC_SERV_COL_RS_12(k,:);
		comparaison_results_IEA(59,1:30,k)=TFC_SERV_COL_APS_12(k,:);
		comparaison_results_IEA(60,1:30,k)=Energy_output_IEA_format(67,1:30,k);
		comparaison_results_IEA(61,1:30,k)=TFC_SERV_OIL_RS_12(k,:);
		comparaison_results_IEA(62,1:30,k)=TFC_SERV_OIL_APS_12(k,:);
		comparaison_results_IEA(63,1:30,k)=Energy_output_IEA_format(68,1:30,k);
		comparaison_results_IEA(64,1:30,k)=TFC_SERV_GAS_RS_12(k,:);
		comparaison_results_IEA(65,1:30,k)=TFC_SERV_GAS_APS_12(k,:);
		comparaison_results_IEA(66,1:30,k)=Energy_output_IEA_format(69,1:30,k);
		comparaison_results_IEA(67,1:30,k)=TFC_SERV_ELE_RS_12(k,:);
		comparaison_results_IEA(68,1:30,k)=TFC_SERV_ELE_APS_12(k,:);
		comparaison_results_IEA(69,1:30,k)=Energy_output_IEA_format(70,1:30,k);
		comparaison_results_IEA(70,1:30,k)=zeros(1:30);        
		comparaison_results_IEA(71,1:30,k)=zeros(1:30);       
		comparaison_results_IEA(72,1:30,k)=Energy_output_IEA_format(110,1:30,k);
		comparaison_results_IEA(73,1:30,k)=PGH_IELE_COL_RS_12(k,:);    
		comparaison_results_IEA(74,1:30,k)=PGH_IELE_COL_APS_12(k,:);     
		comparaison_results_IEA(75,1:30,k)=Energy_output_IEA_format(11,1:30,k);
		comparaison_results_IEA(76,1:30,k)=PGH_IELE_OIL_RS_12(k,:);     
		comparaison_results_IEA(77,1:30,k)=PGH_IELE_OIL_APS_12(k,:);     
		comparaison_results_IEA(78,1:30,k)=Energy_output_IEA_format(12,1:30,k);
		comparaison_results_IEA(79,1:30,k)=PGH_IELE_GAS_RS_12(k,:);     
		comparaison_results_IEA(80,1:30,k)=PGH_IELE_GAS_APS_12(k,:);     
		comparaison_results_IEA(81,1:30,k)=Energy_output_IEA_format(13,1:30,k);
	   	comparaison_results_IEA(82,1:30,k)=OES_COL_RS_12(k,:);              
		comparaison_results_IEA(83,1:30,k)=OES_COL_APS_12(k,:);              
		comparaison_results_IEA(84,1:30,k)=Energy_output_IEA_format(19,1:30,k);
		comparaison_results_IEA(85,1:30,k)=OES_OIL_RS_12(k,:);              
		comparaison_results_IEA(86,1:30,k)=OES_OIL_APS_12(k,:);              
		comparaison_results_IEA(87,1:30,k)=Energy_output_IEA_format(20,1:30,k);
		comparaison_results_IEA(88,1:30,k)=OES_GAS_RS_12(k,:);              
		comparaison_results_IEA(89,1:30,k)=OES_GAS_APS_12(k,:);              
		comparaison_results_IEA(90,1:30,k)=Energy_output_IEA_format(21,1:30,k);
		comparaison_results_IEA(91,1:30,k)=OES_ELE_RS_12(k,:);              
		comparaison_results_IEA(92,1:30,k)=OES_ELE_APS_12(k,:);              
		comparaison_results_IEA(93,1:30,k)=Energy_output_IEA_format(22,1:30,k);
		comparaison_results_IEA(94,:,k)=zeros(1:30); //PRICE_COL_unit_IEA_REF(1,:)*42.3;
		comparaison_results_IEA(95,:,k)=zeros(1:30); //PRICE_COL_unit_IEA_REF(1,:)*42.3;
		comparaison_results_IEA(96,:,k)=zeros(1:30); //Energy_output_IEA_format(107,:,k);// Coal (Real  per Metric Tonne) valeur initiale tirée de Output_World IEA 2001          
		comparaison_results_IEA(97,:,k)= zeros(1:30);//PRICE_OIL_unit_IEA_REF(1,:)*25.9;
		comparaison_results_IEA(98,:,k)= zeros(1:30);//PRICE_OIL_unit_IEA_REF(1,:)*25.9;
		comparaison_results_IEA(99,:,k)=zeros(1:30); //Energy_output_IEA_format(108,:,k);// Oil (Real  per Barrel) valeur initiale tirée de Output_World IEA 2001                 
		comparaison_results_IEA(100,:,k)= zeros(1:30);//PRICE_GAS_unit_IEA_REF(1,:)*188.6;
		comparaison_results_IEA(101,:,k)= zeros(1:30);//PRICE_GAS_unit_IEA_REF(1,:)*188.6;
		comparaison_results_IEA(102,:,k)= zeros(1:30);// Energy_output_IEA_format(109,:,k);// Natural Gas (Real  per 1000 cubic feet) valeur initiale tirée de Output_World IEA 2001
		comparaison_results_IEA(103,:,k)=ACT_GENE_GDP_RS_12(k,:);        
		comparaison_results_IEA(104,:,k)=realGDP(k,1:30);
	end


compIEAtemp=comparaison_results_IEA;
comparaison_results_IEA=zeros(104,30,reg+5);//régions imaclim plus monde, OCDE, Europe, CEI, PVD
comparaison_results_IEA(:,:,1:reg)=compIEAtemp;
for k=1:reg
	comparaison_results_IEA(:,:,reg+1)=comparaison_results_IEA(:,:,reg+1)+compIEAtemp(:,:,k);
end
//les prix ne sont pas additifs
for j=94:102,
	comparaison_results_IEA(j,:,reg+1)=comparaison_results_IEA(j,:,reg+1)*1/reg;
end

for k=1:4
	comparaison_results_IEA(:,:,reg+2)=comparaison_results_IEA(:,:,reg+2)+compIEAtemp(:,:,k);
end
//les prix ne sont pas additifs
for j=94:102,
	comparaison_results_IEA(j,:,reg+2)=comparaison_results_IEA(j,:,reg+2)*1/4;
end

comparaison_results_IEA(:,:,reg+3)=compIEAtemp(:,:,3);

comparaison_results_IEA(:,:,reg+4)=compIEAtemp(:,:,5);

for k=6:reg
	comparaison_results_IEA(:,:,reg+5)=comparaison_results_IEA(:,:,reg+5)+compIEAtemp(:,:,k);
end
//les prix ne sont pas additifs
for j=94:102,
	comparaison_results_IEA(j,:,reg+5)=comparaison_results_IEA(j,:,reg+5)*1/7;
end

out_comp_iea=zeros(104*(reg+5),30);
for k=1:reg+5
	out_comp_iea(104*(k-1)+1:104*(k),:)=comparaison_results_IEA(:,:,k);
end

fprintfMat(SAVEDIR+"/comparaison_results_IEA.tsv",out_comp_iea,"%5.8e;");

comparaison_results_IEA2=zeros(104,50,reg);

	for k=1:reg
		comparaison_results_IEA2(1 ,1:30,k)=TPES_COL_RS_12(k,:);
		comparaison_results_IEA2(2 ,1:30,k)=TPES_COL_APS_12(k,:);
		comparaison_results_IEA2(3 ,1:50,k)=Energy_output_IEA_format(2,1:50,k);
		comparaison_results_IEA2(4 ,1:30,k)=TPES_OIL_RS_12(k,:);
		comparaison_results_IEA2(5 ,1:30,k)=TPES_OIL_APS_12(k,:);
		comparaison_results_IEA2(6 ,1:50,k)=Energy_output_IEA_format(3,1:50,k);
		comparaison_results_IEA2(7 ,1:30,k)=TPES_GAS_RS_12(k,:);
		comparaison_results_IEA2(8 ,1:30,k)=TPES_GAS_APS_12(k,:);
		comparaison_results_IEA2(9 ,1:50,k)=Energy_output_IEA_format(4,1:50,k);
		comparaison_results_IEA2(10,1:30,k)=TFC_INDU_COL_RS_12(k,:);
		comparaison_results_IEA2(11,1:30,k)=TFC_INDU_COL_APS_12(k,:);
		comparaison_results_IEA2(12,1:50,k)=Energy_output_IEA_format(35,1:50,k);
		comparaison_results_IEA2(13,1:30,k)=TFC_INDU_OIL_RS_12(k,:);
		comparaison_results_IEA2(14,1:30,k)=TFC_INDU_OIL_APS_12(k,:);
		comparaison_results_IEA2(15,1:50,k)=Energy_output_IEA_format(36,1:50,k);
		comparaison_results_IEA2(16,1:30,k)=TFC_INDU_GAS_RS_12(k,:);
		comparaison_results_IEA2(17,1:30,k)=TFC_INDU_GAS_APS_12(k,:);
		comparaison_results_IEA2(18,1:50,k)=Energy_output_IEA_format(37,1:50,k);
		comparaison_results_IEA2(19,1:30,k)=TFC_INDU_ELE_RS_12(k,:);
		comparaison_results_IEA2(20,1:30,k)=TFC_INDU_ELE_APS_12(k,:);
		comparaison_results_IEA2(21,1:50,k)=Energy_output_IEA_format(38,1:50,k);
		comparaison_results_IEA2(22,1:30,k)=TFC_TRANS_COL_RS_12(k,:);
		comparaison_results_IEA2(23,1:30,k)=TFC_TRANS_COL_APS_12(k,:);
		comparaison_results_IEA2(24,1:50,k)=Energy_output_IEA_format(43,1:50,k);
		comparaison_results_IEA2(25,1:30,k)=TFC_TRANS_OIL_RS_12(k,:);
		comparaison_results_IEA2(26,1:30,k)=TFC_TRANS_OIL_APS_12(k,:);
		comparaison_results_IEA2(27,1:50,k)=Energy_output_IEA_format(44,1:50,k);
		comparaison_results_IEA2(28,1:30,k)=TFC_TRANS_GAS_RS_12(k,:);
		comparaison_results_IEA2(29,1:30,k)=TFC_TRANS_GAS_APS_12(k,:);
		comparaison_results_IEA2(30,1:50,k)=Energy_output_IEA_format(45,1:50,k);
		comparaison_results_IEA2(31,1:30,k)=TFC_TRANS_ELE_RS_12(k,:);
		comparaison_results_IEA2(32,1:30,k)=TFC_TRANS_ELE_APS_12(k,:);
		comparaison_results_IEA2(33,1:50,k)=Energy_output_IEA_format(46,1:50,k);
		comparaison_results_IEA2(34,1:30,k)=TFC_RESI_COL_RS_12(k,:);
		comparaison_results_IEA2(35,1:30,k)=TFC_RESI_COL_APS_12(k,:);
		comparaison_results_IEA2(36,1:50,k)=Energy_output_IEA_format(59,1:50,k);
		comparaison_results_IEA2(37,1:30,k)=TFC_RESI_OIL_RS_12(k,:);
		comparaison_results_IEA2(38,1:30,k)=TFC_RESI_OIL_APS_12(k,:);
		comparaison_results_IEA2(39,1:50,k)=Energy_output_IEA_format(60,1:50,k);
		comparaison_results_IEA2(40,1:30,k)=TFC_RESI_GAS_RS_12(k,:);
		comparaison_results_IEA2(41,1:30,k)=TFC_RESI_GAS_APS_12(k,:);
		comparaison_results_IEA2(42,1:50,k)=Energy_output_IEA_format(61,1:50,k);
		comparaison_results_IEA2(43,1:30,k)=TFC_RESI_ELE_RS_12(k,:);
		comparaison_results_IEA2(44,1:30,k)=TFC_RESI_ELE_APS_12(k,:);
		comparaison_results_IEA2(45,1:50,k)=Energy_output_IEA_format(62,1:50,k);
		comparaison_results_IEA2(46,1:30,k)=TFC_AGRI_COL_RS_12(k,:);
		comparaison_results_IEA2(47,1:30,k)=TFC_AGRI_COL_APS_12(k,:);
		comparaison_results_IEA2(48,1:50,k)=Energy_output_IEA_format(75,1:50,k);
		comparaison_results_IEA2(49,1:30,k)=TFC_AGRI_OIL_RS_12(k,:);
		comparaison_results_IEA2(50,1:30,k)=TFC_AGRI_OIL_APS_12(k,:);
		comparaison_results_IEA2(51,1:50,k)=Energy_output_IEA_format(76,1:50,k);
		comparaison_results_IEA2(52,1:30,k)=TFC_AGRI_GAS_RS_12(k,:);
		comparaison_results_IEA2(53,1:30,k)=TFC_AGRI_GAS_APS_12(k,:);
		comparaison_results_IEA2(54,1:50,k)=Energy_output_IEA_format(77,1:50,k);
		comparaison_results_IEA2(55,1:30,k)=TFC_AGRI_ELE_RS_12(k,:);
		comparaison_results_IEA2(56,1:30,k)=TFC_AGRI_ELE_APS_12(k,:);
		comparaison_results_IEA2(57,1:50,k)=Energy_output_IEA_format(78,1:50,k);
		comparaison_results_IEA2(58,1:30,k)=TFC_SERV_COL_RS_12(k,:);
		comparaison_results_IEA2(59,1:30,k)=TFC_SERV_COL_APS_12(k,:);
		comparaison_results_IEA2(60,1:50,k)=Energy_output_IEA_format(67,1:50,k);
		comparaison_results_IEA2(61,1:30,k)=TFC_SERV_OIL_RS_12(k,:);
		comparaison_results_IEA2(62,1:30,k)=TFC_SERV_OIL_APS_12(k,:);
		comparaison_results_IEA2(63,1:50,k)=Energy_output_IEA_format(68,1:50,k);
		comparaison_results_IEA2(64,1:30,k)=TFC_SERV_GAS_RS_12(k,:);
		comparaison_results_IEA2(65,1:30,k)=TFC_SERV_GAS_APS_12(k,:);
		comparaison_results_IEA2(66,1:50,k)=Energy_output_IEA_format(69,1:50,k);
		comparaison_results_IEA2(67,1:30,k)=TFC_SERV_ELE_RS_12(k,:);
		comparaison_results_IEA2(68,1:30,k)=TFC_SERV_ELE_APS_12(k,:);
		comparaison_results_IEA2(69,1:50,k)=Energy_output_IEA_format(70,1:50,k);
		comparaison_results_IEA2(70,1:50,k)=zeros(1:50);        
		comparaison_results_IEA2(71,1:50,k)=zeros(1:50);       
		comparaison_results_IEA2(72,1:50,k)=Energy_output_IEA_format(110,1:50,k);
		comparaison_results_IEA2(73,1:30,k)=PGH_IELE_COL_RS_12(k,:);    
		comparaison_results_IEA2(74,1:30,k)=PGH_IELE_COL_APS_12(k,:);     
		comparaison_results_IEA2(75,1:50,k)=Energy_output_IEA_format(11,1:50,k);
		comparaison_results_IEA2(76,1:30,k)=PGH_IELE_OIL_RS_12(k,:);     
		comparaison_results_IEA2(77,1:30,k)=PGH_IELE_OIL_APS_12(k,:);     
		comparaison_results_IEA2(78,1:50,k)=Energy_output_IEA_format(12,1:50,k);
		comparaison_results_IEA2(79,1:30,k)=PGH_IELE_GAS_RS_12(k,:);     
		comparaison_results_IEA2(80,1:30,k)=PGH_IELE_GAS_APS_12(k,:);     
		comparaison_results_IEA2(81,1:50,k)=Energy_output_IEA_format(13,1:50,k);
	   	comparaison_results_IEA2(82,1:30,k)=OES_COL_RS_12(k,:);              
		comparaison_results_IEA2(83,1:30,k)=OES_COL_APS_12(k,:);              
		comparaison_results_IEA2(84,1:50,k)=Energy_output_IEA_format(19,1:50,k);
		comparaison_results_IEA2(85,1:30,k)=OES_OIL_RS_12(k,:);              
		comparaison_results_IEA2(86,1:30,k)=OES_OIL_APS_12(k,:);              
		comparaison_results_IEA2(87,1:50,k)=Energy_output_IEA_format(20,1:50,k);
		comparaison_results_IEA2(88,1:30,k)=OES_GAS_RS_12(k,:);              
		comparaison_results_IEA2(89,1:30,k)=OES_GAS_APS_12(k,:);              
		comparaison_results_IEA2(90,1:50,k)=Energy_output_IEA_format(21,1:50,k);
		comparaison_results_IEA2(91,1:30,k)=OES_ELE_RS_12(k,:);              
		comparaison_results_IEA2(92,1:30,k)=OES_ELE_APS_12(k,:);              
		comparaison_results_IEA2(93,1:50,k)=Energy_output_IEA_format(22,1:50,k);
		comparaison_results_IEA2(94,:,k)=zeros(1:50); //PRICE_COL_unit_IEA_REF(1,:)*42.3;
		comparaison_results_IEA2(95,:,k)=zeros(1:50); //PRICE_COL_unit_IEA_REF(1,:)*42.3;
		comparaison_results_IEA2(96,:,k)=zeros(1:50); //Energy_output_IEA_format(107,:,k);// Coal (Real  per Metric Tonne) valeur initiale tirée de Output_World IEA2 2001          
		comparaison_results_IEA2(97,:,k)= zeros(1:50);//PRICE_OIL_unit_IEA_REF(1,:)*25.9;
		comparaison_results_IEA2(98,:,k)= zeros(1:50);//PRICE_OIL_unit_IEA_REF(1,:)*25.9;
		comparaison_results_IEA2(99,:,k)=zeros(1:50); //Energy_output_IEA_format(108,:,k);// Oil (Real  per Barrel) valeur initiale tirée de Output_World IEA 2001                 
		comparaison_results_IEA2(100,:,k)= zeros(1:50);//PRICE_GAS_unit_IEA_REF(1,:)*188.6;
		comparaison_results_IEA2(101,:,k)= zeros(1:50);//PRICE_GAS_unit_IEA_REF(1,:)*188.6;
		comparaison_results_IEA2(102,:,k)= zeros(1:50);// Energy_output_IEA_format(109,:,k);// Natural Gas (Real  per 1000 cubic feet) valeur initiale tirée de Output_World IEA2 2001
		comparaison_results_IEA2(103,1:30,k)=ACT_GENE_GDP_RS_12(k,:);        
		comparaison_results_IEA2(104,:,k)=realGDP(k,1:50);
	end


compResults_IEA2_temp=comparaison_results_IEA2;
comparaison_results_IEA2=zeros(104,50,reg+5);//régions imaclim plus monde, OCDE, Europe, CEI, PVD
comparaison_results_IEA2(:,:,1:reg)=compResults_IEA2_temp;
for k=1:reg
	comparaison_results_IEA2(:,:,reg+1)=comparaison_results_IEA2(:,:,reg+1)+compResults_IEA2_temp(:,:,k);
end
//les prix ne sont pas additifs
for j=94:102,
	comparaison_results_IEA2(j,:,reg+1)=comparaison_results_IEA2(j,:,reg+1)*1/reg;
end

for k=1:4
	comparaison_results_IEA2(:,:,reg+2)=comparaison_results_IEA2(:,:,reg+2)+compResults_IEA2_temp(:,:,k);
end
//les prix ne sont pas additifs
for j=94:102,
	comparaison_results_IEA2(j,:,reg+2)=comparaison_results_IEA2(j,:,reg+2)*1/4;
end

comparaison_results_IEA2(:,:,reg+3)=compResults_IEA2_temp(:,:,3);

comparaison_results_IEA2(:,:,reg+4)=compResults_IEA2_temp(:,:,5);

for k=6:reg
	comparaison_results_IEA2(:,:,reg+5)=comparaison_results_IEA2(:,:,reg+5)+compResults_IEA2_temp(:,:,k);
end
//les prix ne sont pas additifs
for j=94:102,
	comparaison_results_IEA2(j,:,reg+5)=comparaison_results_IEA2(j,:,reg+5)*1/7;
end

out_comp_iea2=zeros(104*(reg+5),50);
for k=1:reg+5
	out_comp_iea2(104*(k-1)+1:104*(k),:)=comparaison_results_IEA2(:,:,k);
end

fprintfMat(SAVEDIR+"/comparaison_results_IEA2.tsv",out_comp_iea2,"%5.8e;");

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////// Sorties thèse

//taux de croissance du PIB par période de 5 ans
nb_periode_5_ans=(TimeHorizon+1)/5;
croissance_moyenne=zeros(reg,nb_periode_5_ans);
for k=1:nb_periode_5_ans-1
	per=5;
	t=(per)*k;
	croissance_moyenne(:,k+1)=((realGDP(:,t+per)./realGDP(:,t)).^(1/(per)*ones(reg,1))-ones(reg,1));
end
croissance_moyenne(:,1)=((realGDP(:,4)./realGDP(:,1)).^(1/(3)*ones(reg,1))-ones(reg,1));

croissance_5_ans=zeros(reg,nb_periode_5_ans);
for k=1:nb_periode_5_ans-1
	per=5;
	t=(per)*k;
	croissance_5_ans(:,k+1)=realGDPrate(:,t);
	GDP_IMF_base_5_ans(:,k+1)=GDP_IMF_base(:,t);
end
croissance_5_ans(:,1)=realGDPrate(:,1);
GDP_IMF_base_5_ans(:,1)=GDP_IMF_base(:,1);


output_5_ans=[croissance_moyenne;
croissance_5_ans;
GDP_IMF_base_5_ans];

mkcsv("output_5_ans");

////////////////////////répartition de la production par usage
Conso_comp=zeros(reg*(sec+5),TimeHorizon+1);
Conso_indus=zeros(reg*(sec+5),TimeHorizon+1);

ldsav("partDomDF_sav.sav");
ldsav("partDomDG_sav.sav");
ldsav("partDomDI_sav.sav");
ldsav("partDomCI_sav.sav");
partDomDF_sav(:,1)=partDomDFref(:,1);
partDomDG_sav(:,1)=partDomDFref(:,1);
partDomDI_sav(:,1)=partDomDIref(:,1);
partDomCI_sav(:,1)=partDomCIref(:,1);


for k=1:TimeHorizon+1
	CI_temp=matrix(CI(:,k),sec,sec,reg);
	DF_temp=matrix(DF(:,k),reg,sec);
	DI_temp=matrix(DI(:,k),reg,sec);
	DG_temp=DGref.*((Ltot(:,k)./Ltot(:,1))*ones(1,sec));
	Exp_temp=matrix(Exp(:,k),reg,sec);
	Imp_temp=matrix(Imp(:,k),reg,sec);
	Q_temp=matrix(Q(:,k),reg,sec);
	Conso_comp_temp=zeros(reg,sec+5);
	Conso_indus_temp=zeros(reg,sec+5);
	partDomDF_temp=matrix(partDomDF_sav(:,k),reg,sec);
	partDomDG_temp=matrix(partDomDG_sav(:,k),reg,sec);
	partDomDI_temp=matrix(partDomDI_sav(:,k),reg,sec);
	partDomCI_temp=matrix(partDomCI_sav(:,k),sec,sec,reg);
	for j=1:reg
		for kk=1:sec
			Conso_comp_temp(j,kk)=CI_temp(indice_composite,kk,j)*Q_temp(j,kk)*partDomCI_temp(indice_composite,kk,j);
			Conso_indus_temp(j,kk)=CI_temp(indice_industrie,kk,j)*Q_temp(j,kk)*partDomCI_temp(indice_industrie,kk,j);;
		end
		 Conso_comp_temp(j,sec+1)=DF_temp(j,indice_composite)*partDomDF_temp(j,indice_composite);
		Conso_indus_temp(j,sec+1)=DF_temp(j,indice_industrie)*partDomDF_temp(j,indice_industrie);
		 Conso_comp_temp(j,sec+2)=DG_temp(j,indice_composite)*partDomDG_temp(j,indice_composite);
		Conso_indus_temp(j,sec+2)=DG_temp(j,indice_industrie)*partDomDG_temp(j,indice_industrie);
		 Conso_comp_temp(j,sec+3)=DI_temp(j,indice_composite)*partDomDI_temp(j,indice_composite);
		Conso_indus_temp(j,sec+3)=DI_temp(j,indice_industrie)*partDomDI_temp(j,indice_industrie);
		 Conso_comp_temp(j,sec+4)=Exp_temp(j,indice_composite);
		Conso_indus_temp(j,sec+4)=Exp_temp(j,indice_industrie);
		 Conso_comp_temp(j,sec+5)=0;//-Imp_temp(j,indice_composite);
		Conso_indus_temp(j,sec+5)=0;//-Imp_temp(j,indice_industrie);
	end
	Conso_comp(:,k)=matrix(Conso_comp_temp',reg*(sec+5),1);
	Conso_indus(:,k)=matrix(Conso_indus_temp',reg*(sec+5),1);
end

freight_activity=zeros(reg,TimeHorizon+1);
Conso_OT=zeros(reg*(sec+5),TimeHorizon+1);
for k=1:TimeHorizon+1
	CI_temp=matrix(CI(:,k),sec,sec,reg);
	DF_temp=matrix(DF(:,k),reg,sec);
	DI_temp=matrix(DI(:,k),reg,sec);
	DG_temp=DGref.*((Ltot(:,k)./Ltot(:,1))*ones(1,sec));
	Exp_temp=matrix(Exp(:,k),reg,sec);
	Imp_temp=matrix(Imp(:,k),reg,sec);
	Q_temp=matrix(Q(:,k),reg,sec);
	Conso_OT_temp=zeros(reg,sec+5);
	partDomDF_temp=matrix(partDomDF_sav(:,k),reg,sec);
	partDomDG_temp=matrix(partDomDG_sav(:,k),reg,sec);
	partDomDI_temp=matrix(partDomDI_sav(:,k),reg,sec);
	partDomCI_temp=matrix(partDomCI_sav(:,k),sec,sec,reg);
	for j=1:reg
		for kk=1:sec
			Conso_OT_temp(j,kk)=CI_temp(indice_OT,kk,j)*Q_temp(j,kk)*partDomCI_temp(indice_OT,kk,j);
		end
		Conso_OT_temp(j,sec+1)=  DF_temp(j,indice_OT)*partDomDF_temp(j,indice_OT);
		Conso_OT_temp(j,sec+2)=  DG_temp(j,indice_OT)*partDomDG_temp(j,indice_OT);
		Conso_OT_temp(j,sec+3)=  DI_temp(j,indice_OT)*partDomDI_temp(j,indice_OT);
		Conso_OT_temp(j,sec+4)= Exp_temp(j,indice_OT);
		Conso_OT_temp(j,sec+5)=0;//-Imp_temp(j,indice_OT);
		freight_activity(j,k)=Conso_OT_temp(j,sec+1)+Conso_OT_temp(j,sec+2)+Conso_OT_temp(j,sec+3)+sum(Conso_OT_temp(j,1:sec));
	end
	Conso_OT(:,k)=matrix(Conso_OT_temp',reg*(sec+5),1);
end		

		
//fprintfMat(SAVEDIR+"Conso_OT.tsv",Conso_OT,format_spec);


Conso_air=zeros(reg*(sec+5),TimeHorizon+1);
for k=1:TimeHorizon+1
	CI_temp=matrix(CI(:,k),sec,sec,reg);
	DF_temp=matrix(DF(:,k),reg,sec);
	DI_temp=matrix(DI(:,k),reg,sec);
	DG_temp=DGref.*((Ltot(:,k)./Ltot(:,1))*ones(1,sec));
	Exp_temp=matrix(Exp(:,k),reg,sec);
	Imp_temp=matrix(Imp(:,k),reg,sec);
	Q_temp=matrix(Q(:,k),reg,sec);
	Conso_air_temp=zeros(reg,sec+5);
	partDomDF_temp=matrix(partDomDF_sav(:,k),reg,sec);
	partDomDG_temp=matrix(partDomDG_sav(:,k),reg,sec);
	partDomDI_temp=matrix(partDomDI_sav(:,k),reg,sec);
	partDomCI_temp=matrix(partDomCI_sav(:,k),sec,sec,reg);
	for j=1:reg
		for kk=1:sec
			Conso_air_temp(j,kk)=CI_temp(indice_air,kk,j)*Q_temp(j,kk)*partDomCI_temp(indice_air,kk,j);
		end
		Conso_air_temp(j,sec+1)=  DF_temp(j,indice_air)*partDomDF_temp(j,indice_air);
		Conso_air_temp(j,sec+2)=  DG_temp(j,indice_air)*partDomDG_temp(j,indice_air);
		Conso_air_temp(j,sec+3)=  DI_temp(j,indice_air)*partDomDI_temp(j,indice_air);
		Conso_air_temp(j,sec+4)= Exp_temp(j,indice_air);
		Conso_air_temp(j,sec+5)=0;//-Imp_temp(j,indice_air);
	end
	Conso_air(:,k)=matrix(Conso_air_temp',reg*(sec+5),1);
end

Conso_industrie=zeros(reg*(sec+5),TimeHorizon+1);
for k=1:TimeHorizon+1
	CI_temp=matrix(CI(:,k),sec,sec,reg);
	DF_temp=matrix(DF(:,k),reg,sec);
	DI_temp=matrix(DI(:,k),reg,sec);
	DG_temp=DGref.*((Ltot(:,k)./Ltot(:,1))*ones(1,sec));
	Exp_temp=matrix(Exp(:,k),reg,sec);
	Imp_temp=matrix(Imp(:,k),reg,sec);
	Q_temp=matrix(Q(:,k),reg,sec);
	Conso_industrie_temp=zeros(reg,sec+5);
	partDomDF_temp=matrix(partDomDF_sav(:,k),reg,sec);
	partDomDG_temp=matrix(partDomDG_sav(:,k),reg,sec);
	partDomDI_temp=matrix(partDomDI_sav(:,k),reg,sec);
	partDomCI_temp=matrix(partDomCI_sav(:,k),sec,sec,reg);
	for j=1:reg
		for kk=1:sec
			Conso_industrie_temp(j,kk)=CI_temp(indice_industrie,kk,j)*Q_temp(j,kk)*partDomCI_temp(indice_industrie,kk,j);
		end
		Conso_industrie_temp(j,sec+1)=  DF_temp(j,indice_industrie)*partDomDF_temp(j,indice_industrie);
		Conso_industrie_temp(j,sec+2)=  DG_temp(j,indice_industrie)*partDomDG_temp(j,indice_industrie);
		Conso_industrie_temp(j,sec+3)=  DI_temp(j,indice_industrie)*partDomDI_temp(j,indice_industrie);
		Conso_industrie_temp(j,sec+4)= Exp_temp(j,indice_industrie);
		Conso_industrie_temp(j,sec+5)=0;//-Imp_temp(j,indice_industrie);
	end
	Conso_industrie(:,k)=matrix(Conso_industrie_temp',reg*(sec+5),1);
end	

Conso_agriculture=zeros(reg*(sec+5),TimeHorizon+1);
for k=1:TimeHorizon+1
	CI_temp=matrix(CI(:,k),sec,sec,reg);
	DF_temp=matrix(DF(:,k),reg,sec);
	DI_temp=matrix(DI(:,k),reg,sec);
	DG_temp=DGref.*((Ltot(:,k)./Ltot(:,1))*ones(1,sec));
	Exp_temp=matrix(Exp(:,k),reg,sec);
	Imp_temp=matrix(Imp(:,k),reg,sec);
	Q_temp=matrix(Q(:,k),reg,sec);
	Conso_agriculture_temp=zeros(reg,sec+5);
	partDomDF_temp=matrix(partDomDF_sav(:,k),reg,sec);
	partDomDG_temp=matrix(partDomDG_sav(:,k),reg,sec);
	partDomDI_temp=matrix(partDomDI_sav(:,k),reg,sec);
	partDomCI_temp=matrix(partDomCI_sav(:,k),sec,sec,reg);
	for j=1:reg
		for kk=1:sec
			Conso_agriculture_temp(j,kk)=CI_temp(indice_agriculture,kk,j)*Q_temp(j,kk)*partDomCI_temp(indice_agriculture,kk,j);
		end
		Conso_agriculture_temp(j,sec+1)=  DF_temp(j,indice_agriculture)*partDomDF_temp(j,indice_agriculture);
		Conso_agriculture_temp(j,sec+2)=  DG_temp(j,indice_agriculture)*partDomDG_temp(j,indice_agriculture);
		Conso_agriculture_temp(j,sec+3)=  DI_temp(j,indice_agriculture)*partDomDI_temp(j,indice_agriculture);
		Conso_agriculture_temp(j,sec+4)= Exp_temp(j,indice_agriculture);
		Conso_agriculture_temp(j,sec+5)=0;//-Imp_temp(j,indice_agriculture);
	end
	Conso_agriculture(:,k)=matrix(Conso_agriculture_temp',reg*(sec+5),1);
end		



Conso_secteurs=[
Conso_comp;
Conso_indus;
Conso_agriculture;
Conso_OT;
Conso_air];

TAXVAL = zeros (reg,TimeHorizon+1)+%nan;

mkcsv("Conso_secteurs");
//mkcsv("realGDP");
mkcsv("TAXVAL");
//Consommation mondiale d'énergie du transport aérien
Energy_output_IEA_agreg(47,:,$);
Energy_output_IEA_agreg(47,:,$)./sum(pkmAir,"r");
matrix(CIref(indice_Et,indice_air,:).*pArmCIref(indice_Et,indice_air,:),reg,1)./pref(:,indice_air);
matrix(CIref(indice_Et,indice_OT,:).*pArmCIref(indice_Et,indice_OT,:),reg,1)./pref(:,indice_OT);

//sum(ExpTI.*pref,"c")./sum(Exp_temp.*pref,"c");
//sum(Imp_temp.*(wpTIagg*nit)/num($),"c")./sum(Imp_temp.*((ones(reg,1)*wpref).*(1)),"c");

///////////////////////calcul du PIB réel chainé
//realGDP_chained=ones(reg,TimeHorizon+1);
//realGDP_chained(:,1)=GDP_IMF_PPA;
for k=1:TimeHorizon+1
    xtax = matrix(xtax_all(:,k),reg,sec)
	if k>1 then
		pArmDF_temp_prev=pArmDF_temp;
		pArmDI_temp_prev=pArmDI_temp;
		pArmDG_temp_prev=pArmDG_temp;
		    wp_temp_prev=    wp_temp;
		     p_temp_prev=     p_temp;
		    DF_temp_prev=    DF_temp;
		    DI_temp_prev=    DI_temp;
		    DG_temp_prev=    DG_temp;
		   Exp_temp_prev=   Exp_temp;
		   Imp_temp_prev=   Imp_temp;
	end
	
	pArmDF_temp=matrix(pArmDF(:,k)/num(k),reg,sec);
	pArmDI_temp=matrix(pArmDI(:,k)/num(k),reg,sec);
	pArmDG_temp=pArmDGref.*pArmDI_temp./pArmDIref;
	wp_temp=wp(:,k)'/num(k);
	p_temp=matrix(p(:,k),reg,sec)/num(k);
	DF_temp=matrix(DF(:,k),reg,sec);
	DI_temp=matrix(DI(:,k),reg,sec);
	DG_temp=DGref.*((Ltot(:,k)./Ltot(:,1))*ones(1,sec));
	Exp_temp=matrix(Exp(:,k),reg,sec);
	Imp_temp=matrix(Imp(:,k),reg,sec);
	
	if k==1 then
		pArmDF_temp_prev=pArmDF_temp;
		pArmDI_temp_prev=pArmDI_temp;
		pArmDG_temp_prev=pArmDG_temp;
		    wp_temp_prev=    wp_temp;
		     p_temp_prev=     p_temp;
		    DF_temp_prev=    DF_temp;
		    DI_temp_prev=    DI_temp;
		    DG_temp_prev=    DG_temp;
		   Exp_temp_prev=   Exp_temp;
		   Imp_temp_prev=   Imp_temp;
	end
	if k>1 then 
		realGDP_chained(:,k)=realGDP_chained(:,k-1).*(...
							  ((sum(pArmDF_temp_prev.*DF_temp     +pArmDG_temp_prev.*DG_temp     +pArmDI_temp_prev.*DI_temp     ,"c")+sum(Exp_temp     .*p_temp_prev.*(1+xtax)-Imp_temp     .*((ones(reg,1)*wp_temp_prev).*(1)),"c"))...
							 ./(sum(pArmDF_temp_prev.*DF_temp_prev+pArmDG_temp_prev.*DG_temp_prev+pArmDI_temp_prev.*DI_temp_prev,"c")+sum(Exp_temp_prev.*p_temp_prev.*(1+xtax)-Imp_temp_prev.*((ones(reg,1)*wp_temp_prev).*(1)),"c")))...
							.*((sum(pArmDF_temp.*DF_temp     +pArmDG_temp.*DG_temp     +pArmDI_temp.*DI_temp     ,"c")+sum(Exp_temp     .*p_temp.*(1+xtax)-Imp_temp     .*((ones(reg,1)*wp_temp).*(1)),"c"))...
							 ./(sum(pArmDF_temp.*DF_temp_prev+pArmDG_temp.*DG_temp_prev+pArmDI_temp.*DI_temp_prev,"c")+sum(Exp_temp_prev.*p_temp.*(1+xtax)-Imp_temp_prev.*((ones(reg,1)*wp_temp).*(1)),"c"))))^(1/2);
	end
end
//realGDP_chained_rate=zeros(reg,TimeHorizon+1);
//realGDP_chained_rate(:,2:TimeHorizon+1)=(realGDP_chained(:,2:TimeHorizon+1)-realGDP_chained(:,1:TimeHorizon))./realGDP_chained(:,1:TimeHorizon);

// fprintfMat(SAVEDIR+"output_these\"+"realGDP_chained.tsv",realGDP_chained,format_spec);
// save(MODEL+"output_these\"+"realGDP_chained.sav",realGDP_chained);
////////////////////////////////Calcul de l'utilité des ménages

ldsav("xsi_sav.sav");
ldsav("bnautomobile_sav.sav");
UtilityHH=zeros(reg,TimeHorizon+1);
bn_sav = bn;
bnair_sav = bnair;
betatrans_sav = betatrans;
bnOT_sav = bnOT;
for k=1:TimeHorizon+1
	xsi_temp=matrix(xsi_sav(:,k),reg,(nb_secteur_conso-2));
	bnautomobile_temp=bnautomobile_sav(:,k);
	Tautomobile_temp=Tautomobile(:,k);
	TNM_temp=TNM(:,k);
	DF_temp=matrix(DF(:,k),reg,sec);
	bn=matrix(bn_sav(:,k),reg,sec);
	betatrans=matrix(betatrans_sav(:,k),reg,-1);
	bnair=matrix(bnair_sav(:,k),reg,-1);
	bnOT=matrix(bnOT_sav(:,k),reg,-1);
	Conso_temp=DF_temp(:,sec-nb_secteur_conso+1:sec);
	UtilityHH(:,k)=log(Conso_temp(:,indice_construction-nbsecteurenergie)-bn(:,indice_construction)).*xsi_temp(:,1)+...
				   log(Conso_temp(:,indice_composite-nbsecteurenergie)       -bn(:,indice_composite)).*xsi_temp(:,2)+...
				   log(Conso_temp(:,indice_mer-nbsecteurenergie)             -bn(:,indice_mer)).*xsi_temp(:,3)+...
				   log(Conso_temp(:,indice_agriculture-nbsecteurenergie)  -bn(:,indice_agriculture)).*xsi_temp(:,4)+...
				   log(Conso_temp(:,indice_industrie-nbsecteurenergie)      -bn(:,indice_industrie)).*xsi_temp(:,5)+...
				   -xsiT(:,k)./sigmatrans(:,k).*log(betatrans(:,1).*(alphaair(:,k).*(Conso_temp(:,indice_air-nbsecteurenergie)-bnair)).^(-sigmatrans(:,k))..
                                                   +betatrans(:,2).*(alphaOT(:,k).*(Conso_temp(:,indice_OT-nbsecteurenergie)-bnOT)).^(-sigmatrans(:,k))..
                                                   +betatrans(:,3).*(Tautomobile_temp-bnautomobile_temp).^(-sigmatrans(:,k))..
                                                   +betatrans(:,4).*(TNM_temp-bnNM(:,k)).^(-sigmatrans(:,k)));
				   

end		

mksav("UtilityHH");

//plot2d(realGDP_chained_rate')

//Etude investissement MO
InvDem_MO=zeros(sec,TimeHorizon+1);
for current_time_im=1:TimeHorizon+1
	InvDem_temp=matrix(InvDem(:,current_time_im),reg,sec);
	for j=1:sec
		InvDem_MO(j,current_time_im)=InvDem_temp(9,j);
	end
end
for current_time_im=1:TimeHorizon+1
	partInvFin_temp=matrix(partInvFin(:,current_time_im),reg,sec);
	for j=1:sec
		partInvFin_MO(j,current_time_im)=partInvFin_temp(9,j);
	end
end
Inv_MW_MO=zeros(26,TimeHorizon+1);
for current_time_im=1:TimeHorizon+1
	Inv_MW_temp=matrix(Inv_MW(:,current_time_im),reg,26);
	for j=1:sec
		Inv_MW_MO(j,current_time_im)=Inv_MW_temp(9,j);
	end
end

for j=2:TimeHorizon
	InvDem_MO(:,j+1)./max(InvDem_MO(:,j),0.0000000001)-1;
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////Output Transust////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//aggrégats régionaux: Europe, Reste des pays industrialisés, CHine et inde, CEI+MO, Rdm
mask_reg_transust=[
[0 0 1 0 0 0 0 0 0 0 0 0]
[1 1 0 1 0 0 0 0 0 0 0 0]
[0 0 0 0 0 1 1 0 0 0 0 0]
[0 0 0 0 1 0 0 0 1 0 0 0]
[0 0 0 0 0 0 0 1 0 1 1 1]
];


pays=3;
output_transust=[
mask_reg_transust*Ltot //POP
mask_reg_transust*realGDP //PIB
mask_reg_transust*EregCO2/10^9 //émissions régionales
pkmAuto(pays,:)/tauxderemplissageauto(pays) //vkm automobile europe
freight_activity(pays,:) //quantité production other transport europe
stock_car_ventile_EUR //composition de la flotte automobile europe
mask_reg_transust*Conso_ener_OT //conso énergie fret
mask_reg_transust*(conso_auto_oil+conso_auto_elec) //+Tautomobile.*alphaelecauto.*pkmautomobileref./100 //conso énergie automobile
(conso_LFU_OTT(pays,:)+conso_auto_oil(pays,:)).*prod_ORI(pays,:)./(prod_ORI(pays,:)+prod_CTL(pays,:)+prod_BFU(pays,:)) //end use energy consumption of road transportation (europe) pétrole raffiné
(conso_LFU_OTT(pays,:)+conso_auto_oil(pays,:)).*prod_BFU(pays,:)./(prod_ORI(pays,:)+prod_CTL(pays,:)+prod_BFU(pays,:)) //end use energy consumption of road transportation (europe) biofuels
(conso_LFU_OTT(pays,:)+conso_auto_oil(pays,:)).*prod_CTL(pays,:)./(prod_ORI(pays,:)+prod_CTL(pays,:)+prod_BFU(pays,:)) //end use energy consumption of road transportation (europe) CTL
conso_ELE_OTT(pays,:)+conso_auto_elec(pays,:) //end use energy consumption of road transportation (europe) élec
(E_CO2_OT(pays,:))/10^6 //+E_CO2_CTL(pays,:).*conso_LFU_OTT(pays,:)/prod_Et(pays,:)   //emission from public terrestrial transport europe
(E_CO2_cars(pays,:))/10^6 //+E_CO2_CTL(pays,:).*conso_auto_oil(pays,:)/prod_Et(pays,:)  //emission from cars europe
(E_CO2_cars(pays,:)+E_CO2_process(pays,:).*conso_auto_oil(pays,:)/prod_Et(pays,:)+E_CO2_elec(pays,:).*conso_auto_elec(pays,:)/prod_elec(pays,:))./(conso_auto_oil(pays,:)+conso_auto_elec(pays,:)) //carbon content of cars' fuel (europe) for the kaya identity
pkmOT(pays,:) //pkm Other transport europe
pkmAuto(pays,:) //pkm automobile europe
(pkmAuto(pays,:)/tauxderemplissageauto(pays))./(stockautomobile(pays,:).*(nombreautomobileref(pays)*ones(1,TimeHorizon+1))/100) //kilométrage annuel moyen par véhicule
TAXVAL(3,:)
TAXVAL(1,:)
TAXVAL(6,:)

];

mkcsv("output_transust");


//realGDPlapeyreQPPP=realGDP_lapeyres_Quant./(realGDP_lapeyres_Quant(:,1)*ones(1,TimeHorizon+1)).*((realGDP(:,1)./pref(:,indice_composite))*ones(1,TimeHorizon+1));
//loading IEA GDP (PPP)
// load("E:\Articles\Baseline carbonee\IEW_sigma_n\Data IEA\ACT_GENE_GDP_RS_12.sav");
// decomposition de Kaya
// output_kaya=[
// [Code_Regions,Ltot];
// [Code_Regions,realGDP_lapeyres_Quant];
// [Code_Regions,TPES];
// [Code_Regions,EregCO2];
// [999,sum(Ltot,"r")];
// [999,sum(realGDP_lapeyres_Quant,"r")];
// [999,sum(TPES,"r")];
// [999,sum(EregCO2,"r")];
// [Code_Regions,Ltot];
// [Code_Regions,realGDP_lapeyres_Quant./Ltot];
// [Code_Regions,TPES./realGDP_lapeyres_Quant];
// [Code_Regions,EregCO2./TPES];
// [999,sum(Ltot,"r")];
// [999,sum(realGDP_lapeyres_Quant,"r")./sum(Ltot,"r")];
// [999,sum(TPES,"r")./sum(realGDP_lapeyres_Quant,"r")];
// [999,sum(EregCO2,"r")./sum(TPES,"r")]
// [Code_Regions,[ACT_GENE_GDP_RS_12(:,2:$),zeros(reg,TimeHorizon+1-29)]];
// [999,sum(realGDPlapeyreQPPP,"r")];
// ];

//mkcsv("output_kaya");


//exec ("E:\These\tax_sim\Taxlin\save_variables_these.sce");
//exec ("E:\These\tax_sim\Taxlin\ouput_chine.sce");
//exec ("E:\These\tax_sim\Taxlin\ouput_USA.sce");

// InvDem_brut_MO=zeros(sec,TimeHorizon+1);
// for current_time_im=1:TimeHorizon+1
// 	InvDem_brut_temp=matrix(InvDem_brut(:,current_time_im),reg,sec);
// 	for j=1:sec
// 		InvDem_brut_MO(j,current_time_im)=InvDem_brut_temp(9,j);
// 	end
// end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////// old

// GDP_IEA_REF=zeros(reg,30);
// GDP_IEA_REF(:,1)=GDP_IMF_PPA;
// for j=2:30
// 	GDP_IEA_REF(:,j)=GDP_IEA_REF(:,j-1).*(1+GDPrate_12_REF(:,j));
// end
// GDP_pc_IEA_REF=GDP_IEA_REF./Ltot(:,1:30);
// (GDP_IEA_REF./Ltot(:,1:30))./((GDP_IEA_REF(:,1)./Ltot(:,1))*ones(1,30));
// alphatotm2_kWh_IEA_REF./(alphatotm2_kWh_IEA_REF(:,1)*ones(1,30));
// m2batiment(:,1:30).*alphatotm2_IEA_REF;
// m2batiment(:,1:30).*alphatotm2_IEA_REF./Ltot(:,1:30)*11630*10^6;
// m2batiment(:,1:30)./Ltot(:,1:30)

// log_unit_TFC_RES_ELE_12_REF=log(TFC_RES_ELE_12_REF./(TFC_RES_ELE_12_REF(:,1)*ones(1,30)))
// log_unit_GDP_IEA_REF=log(GDP_IEA_REF./(GDP_IEA_REF(:,1)*ones(1,30)))
// log_unit_GDP_pc_IEA_REF=log((GDP_IEA_REF./Ltot(:,1:30))./((GDP_IEA_REF(:,1)./Ltot(:,1))*ones(1,30)))
// log_unit_TFC_RES_ELE_12_REF(:,2:$)./log_unit_GDP_IEA_REF(:,2:$)
// log_unit_TFC_RES_ELE_12_REF(:,2:$)./log_unit_GDP_pc_IEA_REF(:,2:$)
// for k=1:reg
// 	regress(log(GDP_IEA_REF(k,:)),log(TFC_RES_ELE_12_REF(k,:)))
// end

// for k=1:reg
// 	regress(log(GDP_IEA_REF(k,:)),log(TFC_RES_TOT_12_REF(k,:)))
// end

// /////////////scénarios POLES
//old scenario alternative : F4, see revision 29305 (F4=facteur4)
//  load(TECH+"OIL_M2_REF_unit.sav");
//  load(TECH+"ELE_M2_REF_unit.sav");
//  load(TECH+"GAS_M2_REF_unit.sav");
//  load(TECH+"HEA_M2_REF_unit.sav");
// load(TECH+"COAL_M2_REF_unit.sav");

// OIL_M2_REF_POLES= OIL_M2_REF_unit.*(ALPHA_OIL_M2_IEA_REF(:,1)*ones(1,50));
// ELE_M2_REF_POLES= ELE_M2_REF_unit.*(ALPHA_ELE_M2_IEA_REF(:,1)*ones(1,50));
// GAS_M2_REF_POLES= GAS_M2_REF_unit.*(ALPHA_GAS_M2_IEA_REF(:,1)*ones(1,50));
// COL_M2_REF_POLES=COAL_M2_REF_unit.*(ALPHA_COL_M2_IEA_REF(:,1)*ones(1,50));

// TOT_M2_REF_POLES_kWh=(OIL_M2_REF_POLES+ELE_M2_REF_POLES+GAS_M2_REF_POLES+COL_M2_REF_POLES)*11630*10^6;

// //////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////sorties EDF /////////////////////////////////////////
// //////////////////////////////////////////////////////////////////////////////////////////////////////////

// //extraction des données au bon format
// Sh_sectors_GDP_extr=zeros(sec*reg,TimeHorizon+1);
// charge_extr=zeros(reg*sec,TimeHorizon+1);
// Q_extr=zeros(reg*sec,TimeHorizon+1);
// EI_extr=zeros(reg*sec,TimeHorizon+1);//intensité énergétique des secteurs


// for k=1:reg
// 	for j=1:sec
// 		Sh_sectors_GDP_extr((k-1)*sec+j,:)=Sh_sectors_GDP((j-1)*reg+k,:);
// 		charge_extr((k-1)*sec+j,:)=charge((j-1)*reg+k,:);
// 		Q_extr((k-1)*sec+j,:)=Q((j-1)*reg+k,:);
// 		EI_extr((k-1)*sec+j,:)=sum(CI(144*(k-1)+(j-1)*sec+1:144*(k-1)+(j-1)*sec+5,:),"r");
// 	end
// 	//on renorme
// 	Sh_sectors_GDP_extr((k-1)*sec+1:k*sec,:)=Sh_sectors_GDP_extr((k-1)*sec+1:k*sec,:)./(ones(sec,1)*sum(Sh_sectors_GDP_extr((k-1)*sec+1:k*sec,:),"r"));
// end



// output_EDF=zeros(reg*140+27,TimeHorizon+1);

// for k=1:reg

// 	output_EDF((k-1)*140+1:k*140,:)=[
// 	Ltot(k,:);
// 	Lact(k,:);
// 	TC_l(k,1:TimeHorizon+1);
// 	realGDP(k,:);
// 	Sh_sectors_GDP_extr((k-1)*sec+1:k*sec,:);
// 	charge_extr((k-1)*sec+1:k*sec,:);
// 	Z(k,:);
// 	Rdisp(k,:).*ptc(k,:)./price_index(k,:);
// 	ShEHI(k,:);
// 	TB(k,:)./GDP_n(k,:);
// 	(p((indice_composite-1)*reg+k,:)./num)/(p((indice_composite-1)*reg+k,1)/num(1));
// 	p((indice_coal-1)*reg+k,:).*(1-markup((indice_coal-1)*reg+k,:))./price_index(k,:);
// 	markup((indice_coal-1)*reg+k,:)
// 	p((indice_oil-1)*reg+k,:).*(1-markup((indice_oil-1)*reg+k,:))./price_index(k,:);
// 	markup((indice_oil-1)*reg+k,:)
// 	p((indice_gaz-1)*reg+k,:).*(1-markup((indice_gaz-1)*reg+k,:))./price_index(k,:);
// 	markup((indice_gaz-1)*reg+k,:);
// 	Energy_output_IEA(:,:,k);
// 	Q_extr((k-1)*sec+1:k*sec,:);
// 	pkmautomobileref(k)*Tautomobile(k,:);
// 	m2batiment(k,:);
// 	EI_extr((k-1)*sec+1:k*sec,:);
// 	alphaEtauto(k,:);
// 	alphaCoalm2(k,:)+alphaEtm2(k,:)+alphaelecm2(k,:)+alphaGazm2(k,:)
// 	];

// end

// VA_world_extr=zeros(sec,TimeHorizon+1);
// mask_energie=[ones(5*reg,TimeHorizon+1);zeros(7*reg,TimeHorizon+1)];

// Q_cumule_MO=zeros(1,TimeHorizon+1);
// Q_cumule_MO(1,1)=sum(Ress_infini_oil(9,:)-Ress_0_oil(9,:),"c");

// Q_cumule_nonMO=zeros(1,TimeHorizon+1);
// Q_cumule_nonMO(1,1)=sum(Ress_infini_oil-Ress_0_oil)-Q_cumule_MO(1,1);


// for j=1:sec
// 	VA_world_extr(j,:)=sum(VA_real((j-1)*reg+1:j*reg,:),"r");
// end

// //quantité de pétrole conventionnel exploité

// for j=2:TimeHorizon+1
// 	Q_cumule_MO(1,j)=Q_cumule_MO(1,j-1)+Q(reg+9,j-1);
// 	Q_cumule_nonMO(1,j)=Q_cumule_nonMO(1,j-1)+(sum(Q(reg+1:2*reg,j-1),"r")-Q(reg+9,j-1))*(1-share_NC(1,j-1));
// end

// output_EDF(reg*140+1:reg*140+27,:)=[sum(Ltot,"r");
// sum(Lact,"r");
// sum(realGDP,"r");
// VA_world_extr./(ones(sec,1)*sum(realGDP,"r"))
// sum(Rdisp(:,:).*ptc(:,:)./price_index(:,:),"r");
// sum(pArmDF.*DF.*mask_energie./norm_price_index,"r")./sum(Rdisp./price_index,"r");
// wp_n(indice_coal:indice_gaz,:);
// share_NC.*sum(Q((indice_oil-1)*reg+1:indice_oil*reg,:),"r");
// sum(Q((indice_oil-1)*reg+1:indice_oil*reg,:),"r").*(1-share_NC)-Q((indice_oil-1)*reg+9,:);
// Q((indice_oil-1)*reg+9,:);
// Q_cumule_nonMO/(sum(Ress_infini_oil)-sum(Ress_infini_oil(9,:),"c"));
// ((sum(Ress_infini_oil)-sum(Ress_infini_oil(9,:)))*ones(1,TimeHorizon+1)-Q_cumule_nonMO)./((sum(Q(reg+1:2*reg,:),"r")-Q(reg+9,:)).*(1-share_NC(1,:)));
// Q_cumule_MO/sum(Ress_infini_oil(9,:),"c");
// (ones(1,TimeHorizon+1)*sum(Ress_infini_oil(9,:),"c")-Q_cumule_MO)./Q((indice_oil)*reg+9,:)
// ];



// fprintfMat(SAVEDIR+"/output_EDF_"+run_name+".tsv",output_EDF,"%5.8e;");


// output_elec_8760=[ResDyn_elec(2485:2484+180,:);ResDyn_elec(3745:3744+180,:);ResDyn_elec(5005:5004+180,:)];

// fprintfMat(SAVEDIR+"/output_EDF_elec8760"+run_name+".tsv",output_elec_8760,"%5.8e;");


// taux_unemploymentref=[0.048;
// 0.072;
// 0.087;
// 0.050;
// 0.094;
// 0.09;
// 0.104;
// 0.094;
// 0.104;
// 0.113;
// 0.060;
// 0.074
// ];






// output_EDF_new=zeros(108*12+20,TimeHorizon+1);


// for k=1:reg

// 	output_EDF_new((k-1)*108+1:k*108,:)=[
// 	Ltot(k,:);
// 	Lact(k,:);
// 	TC_l(k,1:TimeHorizon+1);
// 	realGDP(k,:);
// //on réagrège le PIB en 4 catégories: énergie/services/agriculture/industrie(=industrie+transports+construction)
// 	sum(Sh_sectors_GDP_extr((k-1)*sec+1:(k-1)*sec+5,:),"r");
// 	Sh_sectors_GDP_extr((k-1)*sec+6,:)+Sh_sectors_GDP_extr((k-1)*sec+8,:)+Sh_sectors_GDP_extr((k-1)*sec+9,:)+Sh_sectors_GDP_extr((k-1)*sec+10,:)+Sh_sectors_GDP_extr((k-1)*sec+7,:);
// 	Sh_sectors_GDP_extr((k-1)*sec+11,:);
// 	Sh_sectors_GDP_extr((k-1)*sec+12,:);
// 	
// 	charge_extr((k-1)*sec+1:(k-1)*sec+3,:);
// 	charge_extr((k-1)*sec+7,:);
// 	charge_extr((k-1)*sec+11,:);
// 	charge_extr((k-1)*sec+12,:);
// 	
// 	Z(k,:)/Z(k,1)*taux_unemploymentref(k);
// 	Rdisp(k,:).*ptc(k,:)./price_index(k,:);
// 	ShEHI(k,:);
// 	TB(k,:)./GDP_n(k,:);
// 	(p((indice_composite-1)*reg+k,:)./num)/(p((indice_composite-1)*reg+k,1)/num(1));
// 	p((indice_coal-1)*reg+k,:).*(1-markup((indice_coal-1)*reg+k,:))./price_index(k,:);
// 	markup((indice_coal-1)*reg+k,:)
// 	p((indice_oil-1)*reg+k,:).*(1-markup((indice_oil-1)*reg+k,:))./price_index(k,:);
// 	markup((indice_oil-1)*reg+k,:)
// 	p((indice_gaz-1)*reg+k,:).*(1-markup((indice_gaz-1)*reg+k,:))./price_index(k,:);
// 	markup((indice_gaz-1)*reg+k,:);
// 	Energy_output_IEA(:,:,k);
// 	Q_extr((k-1)*sec+7,:);
// 	Q_extr((k-1)*sec+11,:);
// 	Q_extr((k-1)*sec+12,:);
// 	pkmautomobileref(k)*Tautomobile(k,:);
// 	m2batiment(k,:);
// 	EI_extr((k-1)*sec+7,:);
// 	EI_extr((k-1)*sec+11,:);
// 	EI_extr((k-1)*sec+12,:);
// 	alphaEtauto(k,:);
// 	alphaCoalm2(k,:)+alphaEtm2(k,:)+alphaelecm2(k,:)+alphaGazm2(k,:)
// 	];

// end

// output_EDF_new(reg*108+1:reg*108+20,:)=[sum(Ltot,"r");
// sum(Lact,"r");
// sum(realGDP,"r");

// sum(VA_world_extr(1:5,:),"r")./sum(realGDP,"r");
// VA_world_extr(7,:)./sum(realGDP,"r");
// VA_world_extr(11,:)./sum(realGDP,"r");
// (VA_world_extr(6,:)+VA_world_extr(8,:)+VA_world_extr(9,:)+VA_world_extr(10,:)+VA_world_extr(12,:))./sum(realGDP,"r");


// sum(Rdisp(:,:).*ptc(:,:)./price_index(:,:),"r");
// sum(pArmDF.*DF.*mask_energie./norm_price_index,"r")./sum(Rdisp./price_index,"r");
// wp_n(indice_coal:indice_gaz,:);
// share_NC.*sum(Q((indice_oil-1)*reg+1:indice_oil*reg,:),"r");
// sum(Q((indice_oil-1)*reg+1:indice_oil*reg,:),"r").*(1-share_NC)-Q((indice_oil-1)*reg+9,:);
// Q((indice_oil-1)*reg+9,:);
// Q_cumule_nonMO/(sum(Ress_infini_oil)-sum(Ress_infini_oil(9,:),"c"));
// ((sum(Ress_infini_oil)-sum(Ress_infini_oil(9,:)))*ones(1,TimeHorizon+1)-Q_cumule_nonMO)./((sum(Q(reg+1:2*reg,:),"r")-Q(reg+9,:)).*(1-share_NC(1,:)));
// Q_cumule_MO/sum(Ress_infini_oil(9,:),"c");
// (ones(1,TimeHorizon+1)*sum(Ress_infini_oil(9,:),"c")-Q_cumule_MO)./Q((indice_oil-1)*reg+9,:);
// (sum(Ress_0_oil)+sum(Ress_0_heavy))*ones(1,TimeHorizon+1)];


// fprintfMat(SAVEDIR+"/output_EDFnew_"+run_name+".tsv",output_EDF_new,"%5.8e;");


// //fprintfMat(SAVEDIR+"p_comp2005.tsv",p(73,5),"%5.8e;");












































/////////////////////////calculs NEXUS industrie


// Conso_acier=Conso_indus(1:reg,:);
// Conso_aluminium=Conso_indus(reg+1:2*reg,:);
// Conso_ciment=Conso_indus(2*reg+1:3*reg,:);
// Conso_verre=Conso_indus(3*reg+1:4*reg,:);

// Conso_acier_pc=Conso_acier./Ltot;
// Conso_aluminium_pc=Conso_aluminium./Ltot;
// Conso_ciment_pc=Conso_ciment./Ltot;
// Conso_verre_pc=Conso_verre./Ltot;

// Conso_acier_prealGDP=Conso_acier./realGDP;
// Conso_aluminium_prealGDP=Conso_aluminium./realGDP;
// Conso_ciment_prealGDP=Conso_ciment./realGDP;
// Conso_verre_prealGDP=Conso_verre./realGDP;

// indice_acier=1;
// indice_aluminium=2;
// indice_ciment=3;
// indice_verre=4;

// nb_IA=8;
// nb_sec_indus=4;

// share_conso_mater_4reg=zeros(4*nb_IA*nb_sec_indus,TimeHorizon+1);

// for current_time_im=1:TimeHorizon+1
// share_conso_sect_temp=matrix(share_conso_mater_sector(:,current_time_im),reg,nb_IA,nb_sec_indus);

// share_conso_acier_sector_4reg=matrix((maskreg*share_conso_sect_temp(:,:,indice_acier))',4*nb_IA,1);
// share_conso_aluminium_sector_4reg=matrix((maskreg*share_conso_sect_temp(:,:,indice_aluminium))',4*nb_IA,1);
// share_conso_ciment_sector_4reg=matrix((maskreg*share_conso_sect_temp(:,:,indice_ciment))',4*nb_IA,1);
// share_conso_verre_sector_4reg=matrix((maskreg*share_conso_sect_temp(:,:,indice_verre))',4*nb_IA,1);

// share_conso_mater_4reg(:,current_time_im)=[share_conso_acier_sector_4reg;share_conso_aluminium_sector_4reg;share_conso_ciment_sector_4reg;share_conso_verre_sector_4reg];

// end



// output_indus=[r_indus(1:reg*nb_IA+2*reg*nb_sec_indus,1:TimeHorizon+1);
// Conso_acier_pc
// realGDP_pc
// Conso_aluminium_pc
// realGDP_pc
// Conso_ciment_pc
// realGDP_pc
// Conso_verre_pc
// realGDP_pc
// Conso_acier_prealGDP
// realGDP_pc
// Conso_aluminium_prealGDP
// realGDP_pc
// Conso_ciment_prealGDP
// realGDP_pc
// Conso_verre_prealGDP
// realGDP_pc
// share_conso_mater_4reg];

// filename_indus=MODEL+"output_indus.tsv";
//fprintfMat(filename_indus,output_indus,format_spec);





///sortie EPE 14/09


//fprintfMat(SAVEDIR+"output_indus_demande.tsv",ResDyn_indus_demande,format_spec);








//sortie GDP

//output_GDP=[realGDP];


//fprintfMat(SAVEDIR+"output_GDP.tsv",output_GDP,format_spec);

//sortie EPE 14/09


//fprintfMat(SAVEDIR+"output_indus_demande.tsv",ResDyn_indus_demande,format_spec);

//fprintfMat(SAVEDIR+"output_sortie_stock.tsv",sortie_stock,format_spec);


// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////nouvelles sorties worldbank CHN NDE World
// //dans l'ordre : saving ratios 
// [1-ptc(6,:);1-ptc(7,:)];
// //structural change, à voir
// //primary Energy mix [coal;oil;gaz;nuc;hydro;biomasse;ENR] 

// primary_energy_mix=zeros(7*3,TimeHorizon+1);
// for year=1:TimeHorizon+1
// Energy_balance_temp=matrix(energy_balance_stock(:,year),indice_matEner,8,reg);
// country=6; //CHN
// primary_energy_mix(1,year)=Energy_balance_temp(5,1,country); //coal
// primary_energy_mix(2,year)=Energy_balance_temp(5,2,country); //oil
// primary_energy_mix(3,year)=Energy_balance_temp(5,4,country); //gaz
// primary_energy_mix(4,year)=Energy_balance_temp(5,6,country); //nuc
// primary_energy_mix(5,year)=Energy_balance_temp(5,5,country); //hydro
// primary_energy_mix(6,year)=0;				     //biomasse
// primary_energy_mix(7,year)=Energy_balance_temp(5,7,country); //ENR

// country=7; //NDE
// primary_energy_mix(1+7,year)=Energy_balance_temp(5,1,country); //coal
// primary_energy_mix(2+7,year)=Energy_balance_temp(5,2,country); //oil
// primary_energy_mix(3+7,year)=Energy_balance_temp(5,4,country); //gaz
// primary_energy_mix(4+7,year)=Energy_balance_temp(5,6,country); //nuc
// primary_energy_mix(5+7,year)=Energy_balance_temp(5,5,country); //hydro
// primary_energy_mix(6+7,year)=0;				     //biomasse
// primary_energy_mix(7+7,year)=Energy_balance_temp(5,7,country); //ENR

//  //World
// primary_energy_mix(1+2*7,year)=sum(Energy_balance_temp(5,1,:)); //coal
// primary_energy_mix(2+2*7,year)=sum(Energy_balance_temp(5,2,:)); //oil
// primary_energy_mix(3+2*7,year)=sum(Energy_balance_temp(5,4,:)); //gaz
// primary_energy_mix(4+2*7,year)=sum(Energy_balance_temp(5,6,:)); //nuc
// primary_energy_mix(5+2*7,year)=sum(Energy_balance_temp(5,5,:)); //hydro
// primary_energy_mix(6+2*7,year)=0;				     //biomasse
// primary_energy_mix(7+2*7,year)=sum(Energy_balance_temp(5,7,:)); //ENR

// end

// //Final Consumption energy mix [coal;Et;gaz;elec;biomasse] 

// FC_energy_mix=zeros(5*3,TimeHorizon+1);
// for year=1:TimeHorizon+1
// Energy_balance_temp=matrix(energy_balance_stock(:,year),indice_matEner,8,reg);
// country=6; //CHN
// FC_energy_mix(1,year)=Energy_balance_temp(9,1,country); //coal
// FC_energy_mix(2,year)=Energy_balance_temp(9,3,country); //Et
// FC_energy_mix(3,year)=Energy_balance_temp(9,4,country); //gaz
// FC_energy_mix(4,year)=Energy_balance_temp(9,8,country); //elec
// FC_energy_mix(5,year)=0; 				//biomasse


// country=6; //CHN
// FC_energy_mix(1+5,year)=Energy_balance_temp(9,1,country); //coal
// FC_energy_mix(2+5,year)=Energy_balance_temp(9,3,country); //Et
// FC_energy_mix(3+5,year)=Energy_balance_temp(9,4,country); //gaz
// FC_energy_mix(4+5,year)=Energy_balance_temp(9,8,country); //elec
// FC_energy_mix(5+5,year)=0; 				//biomasse

// //world
// FC_energy_mix(1+2*5,year)=sum(Energy_balance_temp(9,1,:)); //coal
// FC_energy_mix(2+2*5,year)=sum(Energy_balance_temp(9,3,:)); //Et
// FC_energy_mix(3+2*5,year)=sum(Energy_balance_temp(9,4,:)); //gaz
// FC_energy_mix(4+2*5,year)=sum(Energy_balance_temp(9,8,:)); //elec
// FC_energy_mix(5+2*5,year)=0; 				//biomasse

// end

// //power breakdown : Fuel shares of electricity generation [coal;Et;gaz;nuc;hydro] (electricity generated by each fuel in Mtep)
// Fuel_shares_elec_gen=zeros(6*3,TimeHorizon+1);
// for year=1:TimeHorizon
// Energy_balance_temp=matrix(energy_balance_stock(:,year),indice_matEner,8,reg);
// Cap_elec_MW_temp=matrix(Cap_elec_MW(:,year),reg,techno_elec);
// country=6; //CHN
// Fuel_shares_elec_gen(1,year)=-Energy_balance_temp(7,1,country)*(sum(Cap_elec_MW_temp(country,1:technoCoal).*rho_elec(country,1:technoCoal,year))/sum(Cap_elec_MW_temp(country,1:technoCoal))); //coal
// Fuel_shares_elec_gen(2,year)=-Energy_balance_temp(7,3,country)*(sum(Cap_elec_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt).*rho_elec(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt,year))/sum(Cap_elec_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt))); //Et
// Fuel_shares_elec_gen(3,year)=-Energy_balance_temp(7,4,country)*(sum(Cap_elec_MW_temp(country,technoCoal+1:technoCoal+technoGas).*rho_elec(country,technoCoal+1:technoCoal+technoGas,year))/sum(Cap_elec_MW_temp(country,technoCoal+1:technoCoal+technoGas))); //gaz
// Fuel_shares_elec_gen(4,year)=-Energy_balance_temp(7,6,country); //nuc
// Fuel_shares_elec_gen(5,year)=-Energy_balance_temp(7,5,country); //hydro
// Fuel_shares_elec_gen(6,year)=-Energy_balance_temp(7,7,country); //ENR


// country=7; //NDE
// Fuel_shares_elec_gen(1+6,year)=-Energy_balance_temp(7,1,country)*(sum(Cap_elec_MW_temp(country,1:technoCoal).*rho_elec(country,1:technoCoal,year))/sum(Cap_elec_MW_temp(country,1:technoCoal))); //coal
// Fuel_shares_elec_gen(2+6,year)=-Energy_balance_temp(7,3,country)*(sum(Cap_elec_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt).*rho_elec(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt,year))/sum(Cap_elec_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt))); //Et
// Fuel_shares_elec_gen(3+6,year)=-Energy_balance_temp(7,4,country)*(sum(Cap_elec_MW_temp(country,technoCoal+1:technoCoal+technoGas).*rho_elec(country,technoCoal+1:technoCoal+technoGas,year))/sum(Cap_elec_MW_temp(country,technoCoal+1:technoCoal+technoGas))); //gaz
// Fuel_shares_elec_gen(4+6,year)=-Energy_balance_temp(7,6,country); //nuc
// Fuel_shares_elec_gen(5+6,year)=-Energy_balance_temp(7,5,country); //hydro
// Fuel_shares_elec_gen(6+6,year)=-Energy_balance_temp(7,7,country); //ENR				

// //world
// Fuel_shares_elec_gen(1+2*6,year)=-sum(Energy_balance_temp(7,1,:))*(sum(Cap_elec_MW_temp(:,1:technoCoal).*rho_elec(:,1:technoCoal,year))/sum(Cap_elec_MW_temp(:,1:technoCoal))); //coal
// Fuel_shares_elec_gen(2+2*6,year)=-sum(Energy_balance_temp(7,3,:))*(sum(Cap_elec_MW_temp(:,technoCoal+technoGas+1:technoCoal+technoGas+technoEt).*rho_elec(:,technoCoal+technoGas+1:technoCoal+technoGas+technoEt,year))/sum(Cap_elec_MW_temp(:,technoCoal+technoGas+1:technoCoal+technoGas+technoEt))); //Et
// Fuel_shares_elec_gen(3+2*6,year)=-sum(Energy_balance_temp(7,4,:))*(sum(Cap_elec_MW_temp(:,technoCoal+1:technoCoal+technoGas).*rho_elec(:,technoCoal+1:technoCoal+technoGas,year))/sum(Cap_elec_MW_temp(:,technoCoal+1:technoCoal+technoGas))); //gaz
// Fuel_shares_elec_gen(4+2*6,year)=-sum(Energy_balance_temp(7,6,:)); //nuc
// Fuel_shares_elec_gen(5+2*6,year)=-sum(Energy_balance_temp(7,5,:)); //hydro
// Fuel_shares_elec_gen(6+2*6,year)=-sum(Energy_balance_temp(7,7,:)); //ENR				
// end

// //energy prices: voir quels prix on sort? wp? pArm?

// //investment in capacity in the electric sector types de technologies:[coal;Gas;Et;Hydro;Nuc;ENR]

// Inv_elec_sector_MW=zeros(6*3,TimeHorizon+1);
// for year=1:TimeHorizon

// Inv_MW_temp=matrix(Inv_MW(:,year),reg,techno_elec);
// country=6; //CHN
// Inv_elec_sector_MW(1,year)=sum(Inv_MW_temp(country,1:technoCoal)); //coal
// Inv_elec_sector_MW(2,year)=sum(Inv_MW_temp(country,technoCoal+1:technoCoal+technoGas)); //gas
// Inv_elec_sector_MW(3,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt)); //Et
// Inv_elec_sector_MW(4,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+technoHydro+1:technoCoal+technoGas+technoEt+technoHydro+technoNuke)); //nuc
// Inv_elec_sector_MW(5,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+1:technoCoal+technoGas+technoEt+technoHydro)); //hydro
// Inv_elec_sector_MW(6,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+technoHydro+technoNuke+1:techno_elec)); //ENR


// country=7; //NDE
// Inv_elec_sector_MW(1+6,year)=sum(Inv_MW_temp(country,1:technoCoal)); //coal
// Inv_elec_sector_MW(2+6,year)=sum(Inv_MW_temp(country,technoCoal+1:technoCoal+technoGas)); //gas
// Inv_elec_sector_MW(3+6,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt)); //Et
// Inv_elec_sector_MW(4+6,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+technoHydro+1:technoCoal+technoGas+technoEt+technoHydro+technoNuke)); //nuc
// Inv_elec_sector_MW(5+6,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+1:technoCoal+technoGas+technoEt+technoHydro)); //hydro
// Inv_elec_sector_MW(6+6,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+technoHydro+technoNuke+1:techno_elec)); //ENR		

// //world
// Inv_elec_sector_MW(1+2*6,year)=sum(Inv_MW_temp(:,1:technoCoal)); //coal
// Inv_elec_sector_MW(2+2*6,year)=sum(Inv_MW_temp(:,technoCoal+1:technoCoal+technoGas)); //gas
// Inv_elec_sector_MW(3+2*6,year)=sum(Inv_MW_temp(:,technoCoal+technoGas+1:technoCoal+technoGas+technoEt)); //Et
// Inv_elec_sector_MW(4+2*6,year)=sum(Inv_MW_temp(:,technoCoal+technoGas+technoEt+technoHydro+1:technoCoal+technoGas+technoEt+technoHydro+technoNuke)); //nuc
// Inv_elec_sector_MW(5+2*6,year)=sum(Inv_MW_temp(:,technoCoal+technoGas+technoEt+1:technoCoal+technoGas+technoEt+technoHydro)); //hydro
// Inv_elec_sector_MW(6+2*6,year)=sum(Inv_MW_temp(:,technoCoal+technoGas+technoEt+technoHydro+technoNuke+1:techno_elec)); //ENR		

// end

// //unit costs of production capacity in electricity sector :[coal;Gas;Et;Hydro;Nuc;ENR]


// // Cost_MW_elec_sector=zeros(6*3,TimeHorizon+1);
// // for year=2:TimeHorizon

// // Inv_MW_temp=matrix(Inv_MW(:,year),reg,techno_elec);
// // country=6; //CHN
// // Cost_MW_elec_sector(1,year)=sum(Inv_MW_temp(country,1:technoCoal).*CINV_MW(country,1:technoCoal,year))/sum(Inv_MW_temp(country,1:technoCoal)); //coal
// // Cost_MW_elec_sector(2,year)=sum(Inv_MW_temp(country,technoCoal+1:technoCoal+technoGas).*CINV_MW(country,technoCoal+1:technoCoal+technoGas,year))/sum(Inv_MW_temp(country,technoCoal+1:technoCoal+technoGas)); //gas
// // Cost_MW_elec_sector(3,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt).*CINV_MW(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt,year))/sum(Inv_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt)); //Et
// // Cost_MW_elec_sector(4,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+technoHydro+1:technoCoal+technoGas+technoEt+technoHydro+technoNuke).*CINV_MW(country,technoCoal+technoGas+technoEt+technoHydro+1:technoCoal+technoGas+technoEt+technoHydro+technoNuke,year))/sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+technoHydro+1:technoCoal+technoGas+technoEt+technoHydro+technoNuke)); //nuc
// // Cost_MW_elec_sector(5,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+1:technoCoal+technoGas+technoEt+technoHydro).*CINV_MW(country,technoCoal+technoGas+technoEt+1:technoCoal+technoGas+technoEt+technoHydro,year))/sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+1:technoCoal+technoGas+technoEt+technoHydro)); //hydro
// // Cost_MW_elec_sector(6,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+technoHydro+technoNuke+1:techno_elec).*CINV_MW(country,technoCoal+technoGas+technoEt+technoHydro+technoNuke+1:techno_elec,year))/sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+technoHydro+technoNuke+1:techno_elec)); //ENR


// // country=7; //NDE
// // Cost_MW_elec_sector(1+6,year)=sum(Inv_MW_temp(country,1:technoCoal).*CINV_MW(country,1:technoCoal,year))/sum(Inv_MW_temp(country,1:technoCoal)); //coal
// // Cost_MW_elec_sector(2+6,year)=sum(Inv_MW_temp(country,technoCoal+1:technoCoal+technoGas).*CINV_MW(country,technoCoal+1:technoCoal+technoGas,year))/sum(Inv_MW_temp(country,technoCoal+1:technoCoal+technoGas)); //gas
// // Cost_MW_elec_sector(3+6,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt).*CINV_MW(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt,year))/sum(Inv_MW_temp(country,technoCoal+technoGas+1:technoCoal+technoGas+technoEt)); //Et
// // Cost_MW_elec_sector(4+6,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+technoHydro+1:technoCoal+technoGas+technoEt+technoHydro+technoNuke).*CINV_MW(country,technoCoal+technoGas+technoEt+technoHydro+1:technoCoal+technoGas+technoEt+technoHydro+technoNuke,year))/sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+technoHydro+1:technoCoal+technoGas+technoEt+technoHydro+technoNuke)); //nuc
// // Cost_MW_elec_sector(5+6,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+1:technoCoal+technoGas+technoEt+technoHydro).*CINV_MW(country,technoCoal+technoGas+technoEt+1:technoCoal+technoGas+technoEt+technoHydro,year))/sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+1:technoCoal+technoGas+technoEt+technoHydro)); //hydro
// // Cost_MW_elec_sector(6+6,year)=sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+technoHydro+technoNuke+1:techno_elec).*CINV_MW(country,technoCoal+technoGas+technoEt+technoHydro+technoNuke+1:techno_elec,year))/sum(Inv_MW_temp(country,technoCoal+technoGas+technoEt+technoHydro+technoNuke+1:techno_elec)); //ENR

// // //world
// // Cost_MW_elec_sector(1+2*6,year)=sum(Inv_MW_temp(:,1:technoCoal).*CINV_MW(:,1:technoCoal,year))/sum(Inv_MW_temp(:,1:technoCoal)); //coal
// // Cost_MW_elec_sector(2+2*6,year)=sum(Inv_MW_temp(:,technoCoal+1:technoCoal+technoGas).*CINV_MW(:,technoCoal+1:technoCoal+technoGas,year))/sum(Inv_MW_temp(:,technoCoal+1:technoCoal+technoGas)); //gas
// // Cost_MW_elec_sector(3+2*6,year)=sum(Inv_MW_temp(:,technoCoal+technoGas+1:technoCoal+technoGas+technoEt).*CINV_MW(:,technoCoal+technoGas+1:technoCoal+technoGas+technoEt,year))/sum(Inv_MW_temp(:,technoCoal+technoGas+1:technoCoal+technoGas+technoEt)); //Et
// // Cost_MW_elec_sector(4+2*6,year)=sum(Inv_MW_temp(:,technoCoal+technoGas+technoEt+technoHydro+1:technoCoal+technoGas+technoEt+technoHydro+technoNuke).*CINV_MW(:,technoCoal+technoGas+technoEt+technoHydro+1:technoCoal+technoGas+technoEt+technoHydro+technoNuke,year))/sum(Inv_MW_temp(:,technoCoal+technoGas+technoEt+technoHydro+1:technoCoal+technoGas+technoEt+technoHydro+technoNuke)); //nuc
// // Cost_MW_elec_sector(5+2*6,year)=sum(Inv_MW_temp(:,technoCoal+technoGas+technoEt+1:technoCoal+technoGas+technoEt+technoHydro).*CINV_MW(:,technoCoal+technoGas+technoEt+1:technoCoal+technoGas+technoEt+technoHydro,year))/sum(Inv_MW_temp(:,technoCoal+technoGas+technoEt+1:technoCoal+technoGas+technoEt+technoHydro)); //hydro
// // Cost_MW_elec_sector(6+2*6,year)=sum(Inv_MW_temp(:,technoCoal+technoGas+technoEt+technoHydro+technoNuke+1:techno_elec).*CINV_MW(:,technoCoal+technoGas+technoEt+technoHydro+technoNuke+1:techno_elec,year))/sum(Inv_MW_temp(:,technoCoal+technoGas+technoEt+technoHydro+technoNuke+1:techno_elec)); //ENR

// // end

// //// exploitation des sorties industries
// IA_res							=  r_indus(1		                                    :  reg*nb_IA                              ,1:TimeHorizon+1);
// conso_acier_poste_res			=  r_indus(1+reg*nb_IA                                  :2*reg*nb_IA                              ,1:TimeHorizon+1);
// conso_alu_poste_res			    =  r_indus(1+2*reg*nb_IA                                :3*reg*nb_IA                              ,1:TimeHorizon+1);
// conso_ciment_poste_res			=  r_indus(1+3*reg*nb_IA                                :4*reg*nb_IA                              ,1:TimeHorizon+1);
// Conso_indus_res                 =  r_indus(1+4*reg*nb_IA                                :4*reg*nb_IA+  reg*nb_sec_indus           ,1:TimeHorizon+1);
// SoldeCom_indus_res              =  r_indus(1+4*reg*nb_IA+reg*nb_sec_indus               :4*reg*nb_IA+2*reg*nb_sec_indus           ,1:TimeHorizon+1);
// Q_indus_res                     =  r_indus(1+4*reg*nb_IA+2*reg*nb_sec_indus             :4*reg*nb_IA+3*reg*nb_sec_indus           ,1:TimeHorizon+1);
// Cout_Ener_indus_res             =  r_indus(1+4*reg*nb_IA+3*reg*nb_sec_indus             :4*reg*nb_IA+4*reg*nb_sec_indus           ,1:TimeHorizon+1);
// p_indus_res                     =  r_indus(1+4*reg*nb_IA+4*reg*nb_sec_indus             :4*reg*nb_IA+5*reg*nb_sec_indus           ,1:TimeHorizon+1);
// Q_reste_indus_res               =  r_indus(1+4*reg*nb_IA+5*reg*nb_sec_indus             :4*reg*nb_IA+5*reg*nb_sec_indus+reg       ,1:TimeHorizon+1);
// IA_anticip_res                  =  r_indus(1+4*reg*nb_IA+5*reg*nb_sec_indus+reg         :5*reg*nb_IA+5*reg*nb_sec_indus+reg       ,1:TimeHorizon+1);
// Demande_indus_anticip_res       =  r_indus(1+5*reg*nb_IA+5*reg*nb_sec_indus+reg         :5*reg*nb_IA+6*reg*nb_sec_indus+reg       ,1:TimeHorizon+1);
// DeltaCap_indus_vise_res         =  r_indus(1+5*reg*nb_IA+6*reg*nb_sec_indus+reg         :5*reg*nb_IA+7*reg*nb_sec_indus+reg       ,1:TimeHorizon+1);
// DeltaK_indus_res                =  r_indus(1+5*reg*nb_IA+7*reg*nb_sec_indus+reg         :5*reg*nb_IA+8*reg*nb_sec_indus+reg       ,1:TimeHorizon+1);
// Cap_indus_res                   =  r_indus(1+5*reg*nb_IA+8*reg*nb_sec_indus+reg         :5*reg*nb_IA+9*reg*nb_sec_indus+reg       ,1:TimeHorizon+1);
// Demande_reste_anticip_res       =  r_indus(1+5*reg*nb_IA+9*reg*nb_sec_indus+reg         :5*reg*nb_IA+9*reg*nb_sec_indus+2*reg     ,1:TimeHorizon+1);
// DeltaCap_reste_vise_res         =  r_indus(1+5*reg*nb_IA+9*reg*nb_sec_indus+2*reg       :5*reg*nb_IA+9*reg*nb_sec_indus+3*reg     ,1:TimeHorizon+1);
// DeltaK_reste_res                =  r_indus(1+5*reg*nb_IA+9*reg*nb_sec_indus+3*reg       :5*reg*nb_IA+9*reg*nb_sec_indus+4*reg     ,1:TimeHorizon+1);
// Cap_reste_res                   =  r_indus(1+5*reg*nb_IA+9*reg*nb_sec_indus+4*reg       :5*reg*nb_IA+9*reg*nb_sec_indus+5*reg     ,1:TimeHorizon+1);
// Cap_industrie_res               =  r_indus(1+5*reg*nb_IA+9*reg*nb_sec_indus+5*reg       :5*reg*nb_IA+9*reg*nb_sec_indus+6*reg     ,1:TimeHorizon+1);
// Conso_coal_indus_res            =  r_indus(1+5*reg*nb_IA+9*reg*nb_sec_indus+6*reg       :5*reg*nb_IA+10*reg*nb_sec_indus+6*reg    ,1:TimeHorizon+1);
// Conso_gaz_indus_res             =  r_indus(1+5*reg*nb_IA+10*reg*nb_sec_indus+6*reg      :5*reg*nb_IA+11*reg*nb_sec_indus+6*reg    ,1:TimeHorizon+1);
// Conso_Et_indus_res              =  r_indus(1+5*reg*nb_IA+11*reg*nb_sec_indus+6*reg      :5*reg*nb_IA+12*reg*nb_sec_indus+6*reg    ,1:TimeHorizon+1);
// Conso_elec_indus_res            =  r_indus(1+5*reg*nb_IA+12*reg*nb_sec_indus+6*reg      :5*reg*nb_IA+13*reg*nb_sec_indus+6*reg    ,1:TimeHorizon+1);
// EI_reste_res                    =  r_indus(1+5*reg*nb_IA+13*reg*nb_sec_indus+6*reg      :5*reg*nb_IA+13*reg*nb_sec_indus+7*reg    ,1:TimeHorizon+1);
// Conso_coal_reste_res            =  r_indus(1+5*reg*nb_IA+13*reg*nb_sec_indus+7*reg      :5*reg*nb_IA+13*reg*nb_sec_indus+8*reg    ,1:TimeHorizon+1);
// Conso_gaz_reste_res             =  r_indus(1+5*reg*nb_IA+13*reg*nb_sec_indus+8*reg      :5*reg*nb_IA+13*reg*nb_sec_indus+9*reg    ,1:TimeHorizon+1);
// Conso_Et_reste_res              =  r_indus(1+5*reg*nb_IA+13*reg*nb_sec_indus+9*reg      :5*reg*nb_IA+13*reg*nb_sec_indus+10*reg   ,1:TimeHorizon+1);
// Conso_elec_reste_res            =  r_indus(1+5*reg*nb_IA+13*reg*nb_sec_indus+10*reg     :5*reg*nb_IA+13*reg*nb_sec_indus+11*reg   ,1:TimeHorizon+1);






// Q_oil_MO_sav=zeros(1,TimeHorizon+1);
// Q_oil_MO_sav=Q(21,:);
// save("Q_oil_MO.sav",Q_oil_MO_sav);


// Q_anticip_sav=zeros(reg*sec,TimeHorizon+1);      
// Q_anticip_sav=Q;      
// save("Q_anticip_sav.sav",  Q_anticip_sav);



// prix_energie_EDF=[etude_oil_price_MO;
// wp(1:3,:)./(ones(3,1)*p(73,:))];

// fprintfMat(SAVEDIR+"prix_energie_EDF.tsv",prix_energie_EDF,"%5.8e");


// Imp_tot_oil=zeros(1,TimeHorizon+1);

// for k=1:reg
// Imp_tot_oil=Imp_tot_oil+Imp(reg+k,:);
// end




// prix_vise_MO=[wp(2,:);
// Exp(21,:);
// Imp_tot_oil;
// xtax(9,2)*ones(1,TimeHorizon+1);
// charge(21,:)];


// fprintfMat(SAVEDIR+"prix_vise_MO.tsv",prix_vise_MO,"%5.8e");

// InvDem_86=matrix(InvDem(:,86),reg,sec);

// InvDem_85=matrix(InvDem(:,85),reg,sec);
// InvDem_84=matrix(InvDem(:,84),reg,sec);
// InvDem_87=matrix(InvDem(:,87),reg,sec);

//[InvDem_86(6,:)',InvDem_85(6,:)']     
