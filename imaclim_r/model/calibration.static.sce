// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   CALIBRATION   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

// Loading GTAP Hybridized data - Calls the readGtapData.sci function which creates variables available for simulation from the GTAP .csv (including creation of 12*12*12 matrices from 12*12 csv per region)
gtapDataPathTemp = strsubst(GTAP_hybrid,'YEAR',string(base_year_simulation));
sufixGTAP = '_Im';
listSector_aggreg = read_csv(gtapDataPathTemp+'Sector.csv','|');
listRegion_aggreg = read_csv(gtapDataPathTemp+'Region.csv','|');
exec(common_codes_dir+"readGtapData.sci");

// Calibration of the static equlibrium :
exec(MODEL+"calibration.prices.sce");
exec(MODEL+"calibration.quantities.sce");
exec(MODEL+"calibration.armington.sce");

// A big part of those two files helps also to calibrate the dynamic process, but those dynamic process calibration are needed for the static calibration :
exec(MODEL+"calibration.nexus.transport.sce");
exec(MODEL+"calibration.capital.sce");

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION with no source   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

//définition des basic needs pour tous les biens
bn=([0.4;0.3;0.3;0.3;0.3;0.3;0.3;0.3;0.3;0.3;0.3;0.3]*ones(1,nb_sectors)).*DFref;

z=[0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2]';

FCC_max_nonener = 30; //previously FCC_max=20
FCC_min_nonener = 0.8;

FCC_max_ener = 1.05;
FCC_min_ener = 0.95;


/////////////////////////////////////////////////////////////////////////////////////////////
//    ---*---   CALIBRATION   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// REST of the static calibration, to be sorted into several files.. or not ! at your convenience.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//// Declaration des variables
xsi=zeros(nb_regions,2+nbsecteurcomposite); // TODO what does the "2" stand for ? compute it with indices instead
xsiT=zeros(nb_regions,1);

l=zeros(reg,sec);	// Besoin unitaire de travail


// informations tirees des statistiques du BIT pour 5 secteurs : FF, Elec/gaz, BTP, Composite, transport
// Repartition des masses salariales selon les secteurs pour l'énergie
partLsec0=csvRead(path_salary_mass+'Lact_sectors_2001.csv','|',[],[],[],'/\/\//'); // DESAG_INDUSTRY: should be updated with new data from BIT? Maybe possible to add some other sectors?

FCC_max = FCC_max_nonener; //previously FCC_max=20
FCC_min = FCC_min_nonener;
res_FCC_temp = fsolve(ones(3,1),FCC_calibration);
aRD = res_FCC_temp(1)*ones(reg,sec);
bRD = res_FCC_temp(2)*ones(reg,sec);
cRD = res_FCC_temp(3)*ones(reg,sec);

ind_temp_specific = [indice_coal,indice_gaz:indice_elec];
FCC_max_ener = FCC_max_ener;
FCC_min_ener = FCC_min_ener;
res_FCC_temp = fsolve(ones(3,1),FCC_calibration);
aRD(:,ind_temp_specific) = res_FCC_temp(1);
bRD(:,ind_temp_specific) = res_FCC_temp(2);
cRD(:,ind_temp_specific) = res_FCC_temp(3);

///////////////////////////////////////////

partsalFF=SALNET(:,1:3)./(sum(SALNET(:,1:3),'c')*ones(1,3));	// Repartition en % des salaires aux sein des secteurs d'extraction d'energies fossiles
partsalEG=SALNET(:,4:5)./(sum(SALNET(:,4:5),'c')*ones(1,2));	// Repartition en % des salaires dans les secteurs "energies transformées" ET et Electricité
partsalTR=SALNET(:,8:10)./(sum(SALNET(:,8:10),'c')*ones(1,3));	// Repartition en % des salaires dans les transports

////Desagregation du secteur composite en 3

partsalCOMP=SALNET(:,indice_composite)	./(SALNET(:,indice_composite)+SALNET(:,indice_agriculture)+sum(SALNET(:,indice_industries),'c'));// Repartition en % des salaires dans les secteurs composites, agriculture et industries
partsalAGRI=SALNET(:,indice_agriculture)	./(SALNET(:,indice_composite)+SALNET(:,indice_agriculture)+sum(SALNET(:,indice_industries),'c'));// Repartition en % des salaires dans les secteurs composites, agriculture et industries
partsalIND=SALNET(:,indice_industries)	./repmat((SALNET(:,indice_composite)+SALNET(:,indice_agriculture)+sum(SALNET(:,indice_industries),'c')),1,nb_sectors_industry);// Repartition en % des salaires dans les secteurs composites, agriculture et industries

// repartition des salaires au sein des secteurs

tempFF=(partLsec0(:,1)*ones(1,3)).*partsalFF;
tempEG=(partLsec0(:,2)*ones(1,2)).*partsalEG;
tempTR=(partLsec0(:,5)*ones(1,3)).*partsalTR;
tempCP=partLsec0(:,4).*partsalCOMP;
tempAGRI=partLsec0(:,4).*partsalAGRI;
tempIND=repmat(partLsec0(:,4),1,nb_sectors_industry).*partsalIND;

partLsec=[tempFF,tempEG,partLsec0(:,3),tempCP,tempTR,tempAGRI,tempIND];

labor_ILO =read_csv(path_employment+'labor.csv',sep='|');
labor_ILO = eval(labor_ILO(2:$,2:$))*1e3;
labor_ILO0 = labor_ILO;

/////////////////////// l = besoin unitaire de travail
l=partLsec.*((L.*(1-z))*ones(1,sec))./Qref;	
lref = l;

wref=SALNET./(l.*Qref.*(aRD+bRD.*tanh(cRD.*(Qref./Cap-ones(reg,sec)))));	// Salaire unitaire
markup=EBEref./(Qref.*pref);
markupref=markup;
// Wage curve ///

pindref=ones(reg,1); //used in set_param


///////////////nouvelle courbe 12/05/05, les salaires peuvent descendre à 0
// aw=[10.54276846;10.54276846;202.2143973;202.2143973;202.2143973;202.2143973;202.2143973;202.2143973;202.2143973;202.2143973;202.2143973;202.2143973];
// bw=[-10.54276846;-10.54276846;-202.2143973;-202.2143973;-202.2143973;-202.2143973;-202.2143973;-202.2143973;-202.2143973;-202.2143973;-202.2143973;-202.2143973];
// cw=[15;15;15;15;15;15;15;15;15;15;15;15];

// for k=3:reg
// 	aw(k)=1.61277;
// 	bw(k)=-1.61277;
// 	cw(k)=2;
// end

// [u,v,info]=fsolve(ones(3*reg,1),calib_wage_curve1);
// aw=u(1:reg);
// bw=u(reg+1:2*reg);
// cw=u(2*reg+1:3*reg);
[u,v,info]=fsolve(ones(2*reg,1),calib_wage_curve);
aw=u(1:reg);
bw=-aw;
cw=u(reg+1:2*reg);

//graphe de la courbe salaire chomage for k=1:reg plot2d((aw(k)+bw(k).*tanh(cw(k).*([0:100]*0.01)))'); end
//graphe de l'elasticité en fonction du point plot2d((bw(1).*cw(1).*([0:100]*0.01)./((aw(1)+bw(1).*tanh(cw(1).*([0:100]*0.01))).*cosh(cw(1).*(([0:100]*0.01)))^2))')
//valeur locale de l'elasticité bw.*cw.*z./((aw+bw.*tanh(cw.*z)).*cosh(cw.*z)^2)

Capref=Cap;

// Utility calibration ///
///////////////////////////////////valeur du temps

//those 3 variables are already defined in calibration.capital (remove from here?)
//tairrefinfini=(alphaair.^(-sigmatrans).*(Consoref(:,indice_air-nbsecteurenergie)-bnair).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*toNM.*betatrans(:,1))./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*alphaair);
//tOTrefinfini=(betatrans(:,2).*alphaOT.^(-sigmatrans).*(Consoref(:,indice_OT-nbsecteurenergie)-bnOT).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*toNM)./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*alphaOT);
//tautomobilerefinfini=(betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans-ones(reg,1)).*toNM)./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)));



lambdaref=zeros(reg,1);
muref=zeros(reg,1);
tairref=(alphaair.^(-sigmatrans).*(Consoref(:,indice_air-nbsecteurenergie)-bnair).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*toNM.*betatrans(:,1)-100*tau.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pArmDFref(:,indice_air))./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*alphaair);
tOTref=(betatrans(:,2).*alphaOT.^(-sigmatrans).*(Consoref(:,indice_OT-nbsecteurenergie)-bnOT).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*toNM-100*tau.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pArmDFref(:,indice_OT))./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*alphaOT);
tautomobileref=(betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans-ones(reg,1)).*toNM-tau.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*(alphaEtauto.*pArmDFref(:,indice_Et)+alphaCompositeauto.*pArmDFref(:,indice_composite)))./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)));

xsi(:,1)=100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*(Consoref(:,indice_construction-nbsecteurenergie)-bn(:,indice_construction))./(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*Consoref(:,indice_construction-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*bn(:,indice_construction)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*Consoref(:,indice_composite-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*bn(:,indice_composite)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*Consoref(:,indice_agriculture-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*bn(:,indice_agriculture)+sum(repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*Consoref(:,indice_industries-nbsecteurenergie)-repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*bn(:,indice_industries),'c')+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*Consoref(:,indice_mer-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*bn(:,indice_mer)+pkmautomobileref.*toNM.*betatrans(:,1).*(-alphaair.*(-Consoref(:,indice_air-nbsecteurenergie)+bnair)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,2).*(-alphaOT.*(-Consoref(:,indice_OT-nbsecteurenergie)+bnOT)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans));

xsi(:,2)=100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*(Consoref(:,indice_composite-nbsecteurenergie)-bn(:,indice_composite))./(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*Consoref(:,indice_construction-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*bn(:,indice_construction)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*Consoref(:,indice_composite-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*bn(:,indice_composite)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*Consoref(:,indice_agriculture-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*bn(:,indice_agriculture)+sum(repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*Consoref(:,indice_industries-nbsecteurenergie)-repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*bn(:,indice_industries),'c')+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*Consoref(:,indice_mer-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*bn(:,indice_mer)+pkmautomobileref.*toNM.*betatrans(:,1).*(-alphaair.*(-Consoref(:,indice_air-nbsecteurenergie)+bnair)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,2).*(-alphaOT.*(-Consoref(:,indice_OT-nbsecteurenergie)+bnOT)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans));

xsi(:,3)=100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*(Consoref(:,indice_mer-nbsecteurenergie)-bn(:,indice_mer))./(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*Consoref(:,indice_construction-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*bn(:,indice_construction)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*Consoref(:,indice_composite-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*bn(:,indice_composite)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*Consoref(:,indice_agriculture-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*bn(:,indice_agriculture)+sum(repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*Consoref(:,indice_industries-nbsecteurenergie)-repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*bn(:,indice_industries),'c')+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*Consoref(:,indice_mer-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*bn(:,indice_mer)+pkmautomobileref.*toNM.*betatrans(:,1).*(-alphaair.*(-Consoref(:,indice_air-nbsecteurenergie)+bnair)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,2).*(-alphaOT.*(-Consoref(:,indice_OT-nbsecteurenergie)+bnOT)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans));

xsi(:,4)=100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*(Consoref(:,indice_agriculture-nbsecteurenergie)-bn(:,indice_agriculture))./(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*Consoref(:,indice_construction-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*bn(:,indice_construction)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*Consoref(:,indice_composite-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*bn(:,indice_composite)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*Consoref(:,indice_agriculture-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*bn(:,indice_agriculture)+sum(repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*Consoref(:,indice_industries-nbsecteurenergie)-repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*bn(:,indice_industries),'c')+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*Consoref(:,indice_mer-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*bn(:,indice_mer)+pkmautomobileref.*toNM.*betatrans(:,1).*(-alphaair.*(-Consoref(:,indice_air-nbsecteurenergie)+bnair)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,2).*(-alphaOT.*(-Consoref(:,indice_OT-nbsecteurenergie)+bnOT)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans));

for i = 1:nb_sectors_industry
xsi(:,4+i)=100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_industries(i)).*(Consoref(:,indice_industries(i)-nbsecteurenergie)-bn(:,indice_industries(i)))./(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*Consoref(:,indice_construction-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*bn(:,indice_construction)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*Consoref(:,indice_composite-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*bn(:,indice_composite)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*Consoref(:,indice_agriculture-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*bn(:,indice_agriculture)+sum(repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*Consoref(:,indice_industries-nbsecteurenergie)-repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*bn(:,indice_industries),'c')+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*Consoref(:,indice_mer-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*bn(:,indice_mer)+pkmautomobileref.*toNM.*betatrans(:,1).*(-alphaair.*(-Consoref(:,indice_air-nbsecteurenergie)+bnair)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,2).*(-alphaOT.*(-Consoref(:,indice_OT-nbsecteurenergie)+bnOT)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans));
end

xsiT=pkmautomobileref.*toNM.*(betatrans(:,1).*(-alphaair.*(-Consoref(:,indice_air-nbsecteurenergie)+bnair)).^(-sigmatrans)+betatrans(:,2).*(-alphaOT.*(-Consoref(:,indice_OT-nbsecteurenergie)+bnOT)).^(-sigmatrans)+betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans)+betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans))./(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*Consoref(:,indice_construction-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*bn(:,indice_construction)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*Consoref(:,indice_composite-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*bn(:,indice_composite)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*Consoref(:,indice_agriculture-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*bn(:,indice_agriculture)+sum(repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*Consoref(:,indice_industries-nbsecteurenergie)-repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*bn(:,indice_industries),'c')+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*Consoref(:,indice_mer-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*bn(:,indice_mer)+pkmautomobileref.*toNM.*betatrans(:,1).*(-alphaair.*(-Consoref(:,indice_air-nbsecteurenergie)+bnair)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,2).*(-alphaOT.*(-Consoref(:,indice_OT-nbsecteurenergie)+bnOT)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans));

lambdaref=100*tau.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1))./(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*Consoref(:,indice_construction-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*bn(:,indice_construction)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*Consoref(:,indice_composite-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*bn(:,indice_composite)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*Consoref(:,indice_agriculture-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*bn(:,indice_agriculture)+sum(repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*Consoref(:,indice_industries-nbsecteurenergie)-repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*bn(:,indice_industries),'c')+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*Consoref(:,indice_mer-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*bn(:,indice_mer)+pkmautomobileref.*toNM.*betatrans(:,1).*(-alphaair.*(-Consoref(:,indice_air-nbsecteurenergie)+bnair)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,2).*(-alphaOT.*(-Consoref(:,indice_OT-nbsecteurenergie)+bnOT)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans));

muref=100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1))./(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*Consoref(:,indice_construction-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_construction).*bn(:,indice_construction)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*Consoref(:,indice_composite-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_composite).*bn(:,indice_composite)+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*Consoref(:,indice_agriculture-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_agriculture).*bn(:,indice_agriculture)+sum(repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*Consoref(:,indice_industries-nbsecteurenergie)-repmat(100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau,1,nb_sectors_industry).*pArmDFref(:,indice_industries).*bn(:,indice_industries),'c')+100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*Consoref(:,indice_mer-nbsecteurenergie)-100*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*tau.*pArmDFref(:,indice_mer).*bn(:,indice_mer)+pkmautomobileref.*toNM.*betatrans(:,1).*(-alphaair.*(-Consoref(:,indice_air-nbsecteurenergie)+bnair)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,2).*(-alphaOT.*(-Consoref(:,indice_OT-nbsecteurenergie)+bnOT)).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans)+pkmautomobileref.*toNM.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans));
