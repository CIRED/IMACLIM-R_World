// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thomas Le-Gallic, Aurélie Méjean, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION with no source   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

// correction for Europe of Other transport calibration price
pOTcal_corr = [1;1;0.9;1;1;1;1;1;1;1;1;1];
nb_vintage_hist_comp=10;
nb_vintage_hist_agri=10;
nb_vintage_hist_indu=15;


// share of financial capital exported
// add-hoc values based on the 2001 calibration, adjusted so that the model runs
//partExpK=[0.05;0.2;0.1;0.3;0.29;0.22;0.1;0.01;0.12;0.1;0.23;0.1]; //NB: should be removed, shouldn't be?
partExpK=[0.05;0.2;0.1;0.3;0.29;0.22;0.1;0.1;0.12;0.1;0.23;0.1]; 

// logit elasticity - Obsolete ? only serve for first extraction
etaImpK=3;
// logit elasticity - Obsolete ? only serve for first extraction
etaInvFin=2*ones(reg,1);


//////////////////////////////////////////////////////////////////////////////
//            costs structures of productive sectors                        // 
//////////////////////////////////////////////////////////////////////////////
IR=zeros(reg,1);

SALNET=zeros(reg,sec);
TAXSAL=zeros(reg,sec);

//for k=1:reg,
//  SALNET(k,:)=CFact_Agg(k)(2,:)+CFact_Agg(k)(3,:);
//  TAXSAL(k,:)=T_ConsFact_Agg(k)(2,:)+T_ConsFact_Agg(k)(3,:);
//end
//Replaced in V2.0 by: aggregation of salaries (GTAP's dataset includes 5 types of employees, 1 in Imaclim-R)
SALNET = off_mgr_pros_Im + clerks_Im + service_shop_Im + ag_othlowsk_Im + tech_aspros_Im;
SALNET = SALNET;
TAXSAL = T_off_mgr_pros_Im + T_clerks_Im + T_service_shop_Im + T_ag_othlowsk_Im + T_tech_aspros_Im;
sigma=TAXSAL./SALNET;

sigma=TAXSAL./SALNET;

QTAX=zeros(reg,sec);
TAXCI=zeros(reg,sec);
MTAXCI=zeros(reg,sec);
TranspCI=zeros(reg,sec);
EBEref=zeros(reg,sec);
TAXDF=zeros(reg,sec);
TAXDG=zeros(reg,sec);
TAXDI=zeros(reg,sec);
XTAX=zeros(reg,sec);
TTAX=zeros(reg,sec);

for k=1:reg,
  QTAX(k,:)=pref(k,:).*Qref(k,:).*qtax(k,:)./(1+qtax(k,:));
    TAXCI(k,:)= sum( matrix(T_CI_dom_Im(k,:,:)+T_CI_imp_Im(k,:,:),nb_sectors,nb_sectors),'r');
//  MTAXCI(k,:)=sum(CI_imp_Im(k).*((wpref.*mtax(k,:))'*ones(1,sec))./((wpref.*(1+mtax(k,:))+nit(k,:)*wpTIagg)'*ones(1,sec)),'r');
  MTAXCI(k,:)=sum(CIimpref(:,:,k).*((wpref.*mtax(k,:))'*ones(1,sec)),'r');
//  TranspCI(k,:)=sum(CI_imp_Im(k).*((nit(k,:)*wpTIagg)'*ones(1,sec))./((wpref.*(1+mtax(k,:))+nit(k,:)*wpTIagg)'*ones(1,sec)),'r');
  TranspCI(k,:)=sum(CIimpref(:,:,k).*((nit(k,:)*wpTIagg)'*ones(1,sec)),'r');
  EBEref(k,:)=pref(k,:).*Qref(k,:)-(QTAX(k,:)+sum(CIdomref(:,:,k).*(pref(k,:)'*ones(1,sec))+CIimpref(:,:,k).*(wpref'*ones(1,sec)),'r')+TAXCI(k,:)+MTAXCI(k,:)+TranspCI(k,:)+SALNET(k,:)+TAXSAL(k,:));
  TAXDF(k,:)=T_Hsld_dom_Im(k,:)+T_Hsld_imp_Im(k,:)+DFimpref(k,:).*wpref.*mtax(k,:);
  TAXDG(k,:)=T_AP_dom_Im(k,:)+T_AP_imp_Im(k,:)+DGimpref(k,:).*wpref.*mtax(k,:);
  TAXDI(k,:)=T_FBCF_dom_Im(k,:)+T_FBCF_imp_Im(k,:)+DIimpref(k,:).*wpref.*mtax(k,:);
  XTAX(k,:)=T_Exp_Im(k,:);
end


//TTAX=(Ttax./(1+Ttax)).*pArmDFref.*DFref;

// attention le calibrage conjoint du budget de l'etat et des menages se fait sur le taux de reversement des dividendes. L'equation de calibrage condense les deux equations de budgets :
// Menages :
// c*((SALNET+div*EBE)*(1-IR)+transferts) = DFref+TAXDF+transpDF
// Etats :
// sigma*SALNET+(SALNET+div*EBE)*IR+TAXCI+MTAXCI+TAXDF+TAXDG+TAXDI+QTAX+XTAX = DG+TAXDG+transpDG+transferts


//epargne tirée de GTAP
Sref=SAVE_Im;Sref=Sref';

transpDF=wpTIagg*nit.*DFimpref;
transpDG=wpTIagg*nit.*DGimpref;
transpDI=wpTIagg*nit.*DIimpref;




tairrefinfini=(alphaair.^(-sigmatrans).*(Consoref(:,indice_air-nbsecteurenergie)-bnair).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*toNM.*betatrans(:,1))./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*alphaair);
tOTrefinfini=(betatrans(:,2).*alphaOT.^(-sigmatrans).*(Consoref(:,indice_OT-nbsecteurenergie)-bnOT).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*toNM)./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*alphaOT);
tautomobilerefinfini=(betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans-ones(reg,1)).*toNM)./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)));

//
//////////////////////////////////////////////////////////
pArmDFreftaxe=zeros(reg,sec);
fauto=(tautomobilerefinfini-tautorefo)./(tOTrefinfini-tOTrefo);
fair=(tairrefinfini-tairrefo)./(tOTrefinfini-tOTrefo)-fauto;
//pOTcal=pArmDFref(:,indice_OT)./(alphaOT.*pkmautomobileref/100);
pautocal=alphaEtauto.*pArmDFref(:,indice_Et)+alphaCompositeauto.*pArmDFref(:,indice_composite);
paircal=pArmDFref(:,indice_air)./(alphaair.*pkmautomobileref/100);

//pOTcal=paircal./(fauto+fair);
pOTcal=pautocal./(fauto).* pOTcal_corr;
pArmDFreftaxe(:,indice_OT)=(alphaOT.*pkmautomobileref/100).*pOTcal;
pArmDFreftaxe(:,indice_Et)=(-alphaCompositeauto.*pArmDFref(:,indice_composite)+100*pArmDFreftaxe(:,indice_OT)./(pkmautomobileref.*alphaOT).*fauto)./alphaEtauto;
pArmDFreftaxe(:,indice_air)=(alphaair.*pkmautomobileref/100).*pOTcal.*(fauto+fair);
tau=(tOTrefinfini-tOTrefo)./(pOTcal);
//Ttax1=pArmDFreftaxe-pArmDFref;

//alphaEtauto.*pArmDFreftaxe(:,indice_Et)=-alphaCompositeauto.*pArmDFref(:,indice_composite)+100*pArmDFref(:,indice_OT)./(pkmautomobileref.*alphaOT).*fauto



//100*pArmDFref(:,indice_OT)./(pkmautomobileref.*alphaOT).*(fauto+fair)
//pArmDFref(:,indice_air)./(alphaair.*pkmautomobileref/100)
//pArmDFref(:,indice_OT)./(alphaOT.*pkmautomobileref/100)
//alphaEtauto.*pArmDFref(:,indice_Et)+alphaCompositeauto.*pArmDFref(:,indice_composite) 


////////////////////////////////////////////////////////////////////////////////////


Ttax=zeros(reg,sec);
Ttax(:,indice_Et)=(pArmDFreftaxe(:,indice_Et))./(pArmDFref(:,indice_Et))-ones(reg,1);
Ttax(:,indice_air)=(pArmDFreftaxe(:,indice_air))./(pArmDFref(:,indice_air))-ones(reg,1);
Ttax(:,indice_OT)=(pArmDFreftaxe(:,indice_OT))./(pArmDFref(:,indice_OT))-ones(reg,1);

/// prise en compte de Ttax dans pArmDF ////
pArmDFref=pArmDFref.*(1+Ttax);

/////////////////modif Ttax
TTAX=(Ttax./(1+Ttax)).*pArmDFref.*DFref;

//Ttax1=pArmDFref-(ones(reg,sec)./(1+Ttax)).*pArmDFref


////////////////////////Prix au passager.km
//pArmDFref(:,indice_air)./(alphaair.*pkmautomobileref/100)
//pArmDFref(:,indice_OT)./(alphaOT.*pkmautomobileref/100)
//alphaEtauto.*pArmDFref(:,indice_Et)+alphaCompositeauto.*pArmDFref(:,indice_composite) 

/////////////////////////////////////

div=ones(reg,1);
div=((sum(DFref.*pArmDFref,'c')+Sref)+sum(DGref.*pArmDGref,'c')-sum(SALNET+TAXSAL,'c')-sum(QTAX+TAXCI+MTAXCI+TAXDF+TAXDG+TAXDI+XTAX+TTAX,'c'))./sum(EBEref,'c');
transfersref=ones(reg,1);
transfersref=sum(QTAX+TAXCI+MTAXCI+TAXDF+TAXDG+TAXDI+XTAX+TTAX,'c')+sum(TAXSAL,'c')+IR.*sum(SALNET+(div*ones(1,sec)).*EBEref,'c')-sum(DGref.*pArmDGref,'c');
Rdispref=ones(reg,1);
Rdispref=sum(SALNET,'c')+div.*sum(EBEref,'c')+transfersref;
ptc=1-Sref./Rdispref;
divref=div;
ptcref=ptc;

GRBref=ones(reg,1);
GRBref=(1-ptc).*((1-IR).*(sum(SALNET,'c')+div.*sum(EBEref,'c'))+transfersref)+(1-div).*sum(EBEref,'c');
NRBref=sum(pArmDIref.*DIref,'c');

// K account ////


UR=0.8*ones(reg,sec);
Cap=Qref./UR;
K=Cap;
betaK=ones(reg,sec);
alphaK=Cap./(K.^betaK);



//////////////////////////////////////////// pour l'élec le txCap est tiré du résultat du premier Nexus elec txCap=sum(Cap_elec_MW_dep+delta_Cap_elec_MW_1,'c')./sum(Cap_elec_MWref,'c') il existe aussi un //txCap de l'elec dans capcites elec Poles par techno 12 reg.xls feuille TauxCap

// DESAG_INDUSTRY: Temporarily, I used the same delta, txCap & txCapelec values as the aggregated industrial sector for all industrial sectors. To be updated. If two distinguished files are needed, this lines have also to be updated to read the right csv.
delta=csvRead(path_capital_delta+'delta_capital.csv','|',[],[],[],'/\/\//',[1 1 reg nb_sectors]); 
if nb_sectors_industry > 1
    for j=1:(nb_sectors_industry-1)
        delta(:,$+1)=delta(:,$);
    end
end

//txCap=zeros(reg,sec); //DESAG_INDUSTRY: not in use

if auto_calibration_txCap<>"None" & first_try_autocalib==%t
    txCap_history_ener=%f;
    txCap_naturalgrowth=%t;
else
    txCap_history_ener=%f;
    txCap_naturalgrowth=%f;
end
txCap_history=%f;

// auto-calibrated txCaptemp for productive sectors
txCap=csvRead( path_autocalibration+'/txCaptemp_'+string(nb_sectors)+'.csv',',');

if first_try_autocalib==%f
    txCap_elec=csvRead( path_autocalibration+'elec/txCaptemp_elec_'+string(nb_sectors)+'.csv',',');
    txCap(:,indice_elec) = txCap_elec;
    txCap( txCap<0) = 0;
end

txCapNet_ener_3years=csvRead( path_txcapener+'/txCaptemp_Ener_2011_2014.csv','|',[],[],[],'/\/\//');
txCapBrut_ener = ((1+txCapNet_ener_3years) ./ ((1-delta(:,1:5)).^3)) .^(1/3) -1;

if txCap_naturalgrowth==%t
    txCap = (delta + (TC_l_ref+txLact(:,1))*ones(1,nb_sectors));
end

if txCap_history_ener==%t
    txCap(:,indice_coal:indice_elec)= max(txCapBrut_ener,0);
end

Cap_elec_hist=[];
for year=2014:2017
	Cap_elec_tpt=csvRead( path_elec_Cap_MW+'/Cap_'+string(year)+'_MW.csv',';');
	Cap_elec_hist=[Cap_elec_hist sum(Cap_elec_tpt,'c')];
end

if txCap_history_ener==%t
    txCap(:,indice_elec)=Cap_elec_hist(:,2)./Cap_elec_hist(:,1)-1+delta(:,indice_elec);
end

year_gtap_available=[2004,2007,2011,2014];
Cap_nonenerSec=zeros(reg,sec,size(year_gtap_available,'c'));
for i=1:4
    mattemp=csvRead( strsubst(GTAP_nohybrid,'YEAR',string(year_gtap_available(i)))+'Prod.csv','|');
    Cap_nonenerSec(:,:,i)=mattemp(2:$,2:$);
end

txCapNet_2011_2014 = Cap_nonenerSec(:,nbsecteurenergie+1:$,find(year_gtap_available==2014)) ./ Cap_nonenerSec(:,nbsecteurenergie+1:$,find(year_gtap_available==2011))-1;
txCapBrut = ((1+txCapNet_2011_2014 ./ ((1-delta(:,nbsecteurenergie+1:$))).^3)) .^(1/3) -1;

if txCap_history==%t
    txCap(:,nbsecteurenergie+1:$) = max(txCapBrut,0);
end



/////////////////////////////calibration progres technique sur le travail
// al=[-0.8;-0.8;-0.8;-0.8;-0.8];
// bl=[1;1;1;1;1];
// // gammal=[0.02;0.05;0.005;0.005;0.005];

deltaCap=txCap.*Cap;
deltaKnet=((Cap+deltaCap).^(ones(reg,sec)./betaK)./alphaK)-K;

////////////////////////////////suivi des generations de capital
dureedevie=ones(reg,sec)./delta;
/////////////elec


/////////////composite

dureedeviecomposite=floor(dureedevie(1,indice_composite));
Capvintagecomposite=zeros(reg,TimeHorizon+1+dureedeviecomposite);
CIvintagecomposite=zeros(sec,reg,TimeHorizon+1+dureedeviecomposite);

Cap0composite=Cap(:,indice_composite)./(ones(reg,1)+txCap(:,indice_composite)).^(nb_vintage_hist_comp*dureedeviecomposite*ones(reg,1));
Caphistcomposite=zeros(reg,nb_vintage_hist_comp*dureedeviecomposite+1);
construitcomposite=zeros(reg,nb_vintage_hist_comp*dureedeviecomposite);
for k=0:(nb_vintage_hist_comp*dureedeviecomposite)
	Caphistcomposite(:,k+1)=Cap0composite.*(ones(reg,1)+txCap(:,indice_composite)).^(ones(reg,1)*k);
end
for k=1:dureedeviecomposite
	construitcomposite(:,k)=(Caphistcomposite(:,k+1)-Caphistcomposite(:,k))+Caphistcomposite(:,k).*delta(:,indice_composite);
end
for k=(dureedeviecomposite+1):nb_vintage_hist_comp*dureedeviecomposite
	construitcomposite(:,k)=Caphistcomposite(:,k+1)-Caphistcomposite(:,k)+construitcomposite(:,k-dureedeviecomposite);
end

for k=1:dureedeviecomposite
	Capvintagecomposite(:,k)=construitcomposite(:,k+(nb_vintage_hist_comp-1)*dureedeviecomposite);
	for j=1:reg
		CIvintagecomposite(:,j,k)=CI(:,indice_composite,j);
	end
end
//sum(Capvintagecomposite(:,1:dureedeviecomposite),'c')./Cap(:,indice_composite)



dureedevieagriculture=floor(dureedevie(1,indice_agriculture));
Capvintageagriculture=zeros(reg,TimeHorizon+1+dureedevieagriculture);
CIvintageagriculture=zeros(sec,reg,TimeHorizon+1+dureedevieagriculture);

Cap0agriculture=Cap(:,indice_agriculture)./(ones(reg,1)+txCap(:,indice_agriculture)).^(nb_vintage_hist_agri*dureedevieagriculture*ones(reg,1));
Caphistagriculture=zeros(reg,nb_vintage_hist_agri*dureedevieagriculture+1);
construitagriculture=zeros(reg,nb_vintage_hist_agri*dureedevieagriculture);
for k=0:(nb_vintage_hist_agri*dureedevieagriculture)
	Caphistagriculture(:,k+1)=Cap0agriculture.*(ones(reg,1)+txCap(:,indice_agriculture)).^(ones(reg,1)*k);
end
for k=1:dureedevieagriculture
	construitagriculture(:,k)=(Caphistagriculture(:,k+1)-Caphistagriculture(:,k))+Caphistagriculture(:,k).*delta(:,indice_agriculture);
end
for k=(dureedevieagriculture+1):nb_vintage_hist_agri*dureedevieagriculture
	construitagriculture(:,k)=Caphistagriculture(:,k+1)-Caphistagriculture(:,k)+construitagriculture(:,k-dureedevieagriculture);
end

for k=1:dureedevieagriculture
	Capvintageagriculture(:,k)=construitagriculture(:,k+(nb_vintage_hist_agri-1)*dureedevieagriculture);
	for j=1:reg
		CIvintageagriculture(:,j,k)=CI(:,indice_agriculture,j);
	end
end
//sum(Capvintageagriculture(:,1:dureedevieagriculture),'c')./Cap(:,indice_agriculture)

//Alternative Total

if ind_techno==1
	dureedevieindustrie=floor(dureedevie(1,indice_industries(1))); // DESAG_INDUSTRY: Until specific work is done on each sector, we use the first available value of lifetime of industrial capacities (as it is supposed as constant among industrial subsectors)
else
	dureedevieindustrie=floor(dureedevie(1,indice_industries(1)))+10; // DESAG_INDUSTRY: idem
end
//It underlies the following assumption: dureedevieindustrie is homogenous among all industrial sectors. It allows us to manipulate matrices for all variables used in the representation and dynamics of industrial capital. This was indeed the case with data used to develop this version. An alternative assumption would involve some adjustments in the writings of the dynamics of industrial capital below.
//That's why the lines above are outside the 'for' loop.

Capvintageindustries=zeros(reg,nb_sectors_industry,TimeHorizon+1+dureedevieindustrie);
CIvintageindustries=zeros(sec,nb_sectors_industry,reg,TimeHorizon+1+dureedevieindustrie);

for i = 1:nb_sectors_industry

Cap0industrie=Cap(:,indice_industries(i))./(ones(reg,1)+txCap(:,indice_industries(i))).^(nb_vintage_hist_indu*dureedevieindustrie*ones(reg,1));
Caphistindustrie=zeros(reg,nb_vintage_hist_indu*dureedevieindustrie+1);
construitindustrie=zeros(reg,nb_vintage_hist_indu*dureedevieindustrie);
for k=0:(nb_vintage_hist_indu*dureedevieindustrie)
	Caphistindustrie(:,k+1)=Cap0industrie.*(ones(reg,1)+txCap(:,indice_industries(i))).^(ones(reg,1)*k);
end
for k=1:dureedevieindustrie
	construitindustrie(:,k)=(Caphistindustrie(:,k+1)-Caphistindustrie(:,k))+Caphistindustrie(:,k).*delta(:,indice_industries(i));
end
for k=(dureedevieindustrie+1):nb_vintage_hist_indu*dureedevieindustrie
	construitindustrie(:,k)=Caphistindustrie(:,k+1)-Caphistindustrie(:,k)+construitindustrie(:,k-dureedevieindustrie);
end

for k=1:dureedevieindustrie
	Capvintageindustries(:,i,k)=construitindustrie(:,k+(nb_vintage_hist_indu-1)*dureedevieindustrie);
	for j=1:reg
		CIvintageindustries(:,i,j,k)=CI(:,indice_industries(i),j);
	end
end

end

deltaKbrut=deltaKnet+delta.*K;
/////////////////////////////////// pour l'elec, on tire le deltaKbrut des resultats du premier NEXUS deltaKbrut=sum(delta_Cap_elec_MW_1,'c').*Capref(:,indice_elec)./sum(Cap_elec_MWref,'c')
if auto_calibration_txCap<>"None" & first_try_autocalib==%t
    deltaKbrut(:,indice_elec)=csvRead(path_capital_elec_first_try+'deltaKbrut_elec.csv','|',[],[],[],'/\/\//');
else
    deltaKbrut(:,indice_elec)=csvRead(path_capital_elec+'deltaKbrut_elec_'+string(nb_sectors)+'.csv','|',[],[],[],'/\/\//');
end

deltaKbrut(:,indice_composite)=deltaKnet(:,indice_composite)+Capvintagecomposite(:,1);
deltaKbrut(:,indice_agriculture)=deltaKnet(:,indice_agriculture)+Capvintageagriculture(:,1);
deltaKbrut(:,indice_industries)=deltaKnet(:,indice_industries)+Capvintageindustries(:,:,1);
// Beta(i,j,k) unitary requirements of goods i for formation of capital of sector j in region k
Beta=zeros(sec,sec,reg);
pK=ones(reg,sec);




//////////////////////////////////////////////////////////////////
/////////////En physique...
/////////////////////////////////////////////////////////////////
//deltaKbrut.*(pKAIE.*QCdomphysiqueref./QCdomref)./((GRBref.*(1-partExpK)+partImpK*sum(GRBref.*partExpK))*ones(1,sec))

//////////////pCapAIE world energy investment outlook (M$/Mtep) p44 et p345
// The version of WEIO used is not sure, WEIO 2003 has p44 a table of investment per toe, but calculated as Total cumulated investment in a scenario divided by increase in production. And values in the Figure are an order of magnitude below that used in the csv file.
// We need the investment divided by the new production capacities (that can be more than increase in production). With data in the text in the following page, we do find orders of magnitude closer to what is in the csv file
// Because the values see to be from a scenario, and not actual data, we decide to keep them here. Also because investment data can be quite dependent on the years, and data on new production capacities not easy to have at the global or regional level
// In further improvement of the calibration, this could be updated - with attention to be given to the depreciation rate of capital for energy sectors (delta) to jointly calibrate  
pCap=csvRead(path_capital_price+'pCap.csv','|',[],[],[],'/\/\//');

//pour elec: pK($/Mtep)=pK($/GW)*Cap(GW)/Cap(Mtep)
//Avec Cap(GW)=donnée enerdata et Cap(Mtep)=Qphysiqueref./UR
//pCapAIE(:,5)=2120*[2040;482;465;237;137;137;137;137;137;137;137;137]./Capphysique(:,5);
////////////////////Pour l'électricité, on trouve le prix du capital en M$/Mtep avec le premier NEXUS: sum(delta_Cap_elec_MW_1.*CINV_MW(:,:,current_time_im)/10^3,'c')./(sum(delta_Cap_elec_MW_1,'c').*Capref(:,indice_elec)./sum(Cap_elec_MWref,'c'))
if auto_calibration_txCap<>"None" & first_try_autocalib==%t
    pCap(:,indice_elec)=csvRead(path_capital_elec_first_try+'pCap_elec.csv','|',[],[],[],'/\/\//');
else
    pCap(:,indice_elec)=csvRead(path_capital_elec+'pCap_elec_'+string(nb_sectors)+'.csv','|',[],[],[],'/\/\//');
end

Kref=K;
////////////////////Pour l'électricité, on trouve le prix du capital en M$/MW avec le premier NEXUS: sum(delta_Cap_elec_MW_1.*CINV_MW(:,:,current_time_im)/10^3,'c')./(sum(delta_Cap_elec_MW_1,'c'))
if auto_calibration_txCap<>"None" & first_try_autocalib==%t
    pCap_MW_elecref=csvRead(path_capital_elec_first_try+'pCap_MW_elecref.csv','|',[],[],[],'/\/\//');
else
    pCap_MW_elecref=csvRead(path_capital_elec+'pCap_MW_elecref_'+string(nb_sectors)+'.csv','|',[],[],[],'/\/\//');
end

pK(:,1:nbsecteurenergie)=pCap(:,1:nbsecteurenergie);

// attention Beta est multipliée par un facteur 1e6 pour éviter la perte de précision

// dans cette boucle i est un secteur, j est un bien
// DI(k,j) demande de bien j constitutifs du "pool" d'investissements de tous les secteurs (somme_i) dans la région k
// NB: DI(k,j) = 0 pour j=1:5 car les biens j produits par les secteurs energetiques n'entrent pas dans la composition du capital
// Beta(j,i,k) = quantité de bien j pour constituer une unité de capital pour le secteur i dans la region k
// on fait une hypothèse de colinéarité: la composition du capital (en parts de biens j constitutifs) est identique selon les secteurs i de demande
// soit Part_Compo_Cap(k,j) le vecteur de parts (somme des coord vaut 1)
// on a Beta(j,i,k) = Part_Compo_Cap(k,j) * Y(k,i) 
// ou Y(k,i) est la demande de capital "aggrégé" (au prix pK) du secteur i
// pK(k,i) prix "aggrégé" du capital à sa constitution pour le secteur i dans la region k 
// DIref(k,j) demande de bien j pour former le capital aggrégé (demandé par la somme des secteurs i de la région k)

// Beta(j,i,k) = quantité de bien j pour constituer une unité de capital pour le secteur i dans la region k

// Methode de calcul de Beta:
// -------------------------
// passage par le calcul de BETA(j,i)
// BETA(j,i) quantité de bien j pour le nouveau capital (non unitaire) pour le secteur i dans la region k
// BETA(j,i) résulte d'une "ventilation" (vers les secteurs i de demande) de la demande "aggrégée" DIref(j) en bien j
// effectuée au prorata du "poids de la demande en valeur du secteur i" dans les investissements totaux de la région
// i.e 
// BETA(j,i) = DIref(j) * V_ref(i) / Vtot_ref
// où
// Vtot_ref = sum_j(pArmDIref(j).*DIref(j)) est la valeur globale des investissements réalisés dans la région k
// V_ref(i) = pK(i) * DKbrut(i) est la valeur des investissements du secteur i dans la région k
// avec
// DKbrut(i) variation de cap à l'année de base du secteur i

// et passage au Beta (unitaire % unité de capital du secteur i)
// Beta(j,i) = BETA(j,i) / DKbrut(i)

// GTAP ne donne pas la ventilation de la demande d'investissements vers les différents secteurs i de demande
// par contre on connait DIref(k,j) en 2001 (donnée GTAP) qui donne la demande "aggrégée sur les secteurs de demande" de capital par bien j

Inv_val = NRBref - sum(pArmDIref.*DIinfraref,"c");
DIprodref = DIref - DIinfraref;
for k=1:reg,
	// boucle sur les secteurs i (de demande)
	for ii=1:nbsecteurenergie,
		Beta(:,ii,k) = ( DIprodref(k,:))' * pK(k,ii)  / Inv_val(k) ;
		partInvFin(k,ii) = deltaKbrut(k,ii) * pK(k,ii) / Inv_val(k);
	end
end

partInvFin(:,nbsecteurenergie+1:sec) = (EBEref(:,nbsecteurenergie+1:sec).*(1-div*ones(1,sec-nbsecteurenergie))./(sum(EBEref(:,nbsecteurenergie+1:sec).*(1-div*ones(1,sec-nbsecteurenergie)),'c')*ones(1,sec-nbsecteurenergie))).*(ones(reg,sec-nbsecteurenergie)-sum(partInvFin(:,1:nbsecteurenergie),'c')*ones(1,sec-nbsecteurenergie));

for k=1:reg,
	for ii=nbsecteurenergie+1:sec,
		Beta(:,ii,k)=((DIprodref(k,:))'*partInvFin(k,ii))./(ones(sec,1)*deltaKbrut(k,ii));
	end
end

// Beta re-computation so as to normalize pK to one
// Warning: with this definition, Beta creates a relation between pArmDI (he price of units of capital goods) and pK (the price of investment in productive capacities)
// Beta can no longer be seen as a input-output relation between investmeent and the use of capital good (link between deltaKbrut and DI)
// However, in the previous version of Imaclim, the consumption of capital good DI was endogenous to the reference year one only (DIref)
for k=1:reg,
        for ii=nbsecteurenergie+1:sec,
                pK(k,ii) = pArmDIref(k,:)*Beta(:,ii,k);
		Beta(:,ii,k) = Beta(:,ii,k) ./ pK(k,ii);
                pK(k,ii) = pArmDIref(k,:)*Beta(:,ii,k);
        end
end
//for k=1:reg
//    pK(k,:) = pK(k,:) ./ sum(deltaKbrut(k,:).*pK(k,:)) .* Inv_val(k);
//end


/////on définit une valeur limite pour le ratio Investissement électrique/GDP pour la période 2001 2010. Il est tiré de l'AIE WIO p344
// Max_share_inv_elec_GDP=[0.01
// 0.01
// 0.01
// 0.01
// 0.025
// 0.03
// 0.05
// 0.015
// 0.02
// 0.02
// 0.025
// 0.015];

//old scenario alternative : F4, see revision 29305 (F4=facteur4)

pKref=pK;
Betaref=Beta;

markup=EBEref./(Qref.*pref);
rsecref=(markup.*pref./pKref);
rregref=sum(rsecref.*EBEref./(sum(EBEref,'c')*ones(1,sec)),'c');

accuinvcomp=zeros(reg,1);

partImpK=ones(reg,1);
GRBref=ones(reg,1);
GRBref=(1-ptc).*((1-IR).*(sum(SALNET,'c')+div.*sum(EBEref,'c'))+transfersref)+(1-div).*sum(EBEref,'c');
partImpK= (NRBref-(1-partExpK).*GRBref)./sum(partExpK.*GRBref);

bImpK=(partImpK.^(ones(reg,1)*(1/etaImpK)))./rregref;
partImpKref=partImpK;
BalanceK=-GRBref.*partExpK+partImpKref.*(sum(GRBref.*partExpK)*ones(reg,1));
InvDem=partInvFin.*(NRBref*ones(1,sec));
InvDemref=InvDem;
InvDem_prev=InvDem;

partExpKref=partExpK;

bInvFin=(partInvFin.^((ones(reg,1)./etaInvFin)*ones(1,sec)))./(rsecref./rsecref);

// Loading SSP savings rate and investment rates. Central scenario corresponds is aligned with SSP2
if ind_ssp == 2
	savings_rate_ssp = csvRead(DATA_SAVINGS +"savings_rate_ssp2.csv",';',[],[],[],'/\/\//'); 
	invest_rate_ssp = csvRead(DATA_SAVINGS +"invest_rate_ssp2.csv",';',[],[],[],'/\/\//'); 
elseif ind_ssp == 1	
	savings_rate_ssp = csvRead(DATA_SAVINGS +"savings_rate_ssp1.csv",';',[],[],[],'/\/\//'); 
	invest_rate_ssp = csvRead(DATA_SAVINGS +"invest_rate_ssp1.csv",';',[],[],[],'/\/\//'); 
elseif ind_ssp == 3
	savings_rate_ssp = csvRead(DATA_SAVINGS +"savings_rate_ssp3.csv",';',[],[],[],'/\/\//'); 
	invest_rate_ssp = csvRead(DATA_SAVINGS +"invest_rate_ssp3.csv",';',[],[],[],'/\/\//'); 
elseif ind_ssp == 4
	savings_rate_ssp = csvRead(DATA_SAVINGS +"savings_rate_ssp4.csv",';',[],[],[],'/\/\//'); 
	invest_rate_ssp = csvRead(DATA_SAVINGS +"invest_rate_ssp4.csv",';',[],[],[],'/\/\//'); 
elseif ind_ssp == 5
	savings_rate_ssp = csvRead(DATA_SAVINGS +"savings_rate_ssp5.csv",';',[],[],[],'/\/\//'); 
	invest_rate_ssp = csvRead(DATA_SAVINGS +"invest_rate_ssp5.csv",';',[],[],[],'/\/\//'); 
end
saving_obj_exo_1 = savings_rate_ssp;
auto_invest_obj_exo_1 = invest_rate_ssp;
