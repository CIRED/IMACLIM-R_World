// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Julie Rozenberg, Adrien Vogt-Schilb, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================



A = ones(reg,sec);

x0 = [..
matrix(Consoref,reg*nb_secteur_conso,1);
Tautomobileref;
lambdaref;
muref;
matrix(pref,reg*sec,1);
matrix(wref,reg*sec,1);
matrix(Qref,reg*sec,1);
Rdispref;
TNMref;
wpEnerref'
zeros(nbMKT,1) //<-carbon price
];


nb_car=nombreautomobileref;
charge = Qref./Cap;
stockbatiment = stockbatimentref;
stockautomobile = stockautomobileref;
stockinfra = stockinfraref;
Capautomobile = Captransportref(:,ind_hsld_transpCar);
DIinfra = DIinfraref;
pArmDF = pArmDFref;
pArmDG = pArmDGref;
pArmDI = pArmDIref;
pArmCI = pArmCIref;
partDomDF = partDomDFref;
partDomDG = partDomDGref;
partDomDI = partDomDIref;
partDomCI = partDomCIref;
partImpDF = partImpDFref;
partImpDG = partImpDGref;
partImpDI = partImpDIref;
partImpCI = partImpCIref;
partInvFinref = partInvFin;
marketshare = zeros(reg,sec);
partImpDF_prev = partImpDFref;
partImpDG_prev = partImpDGref;
partImpDI_prev = partImpDIref;
partImpCI_prev = partImpCIref;

partDomCI_stock = partDomCIref;
partDomDF_stock = partDomDFref;
partDomDG_stock = partDomDGref;
partDomDI_stock = partDomDIref;

Tautomobile=Tautomobileref;
p = pref;
w = wref;
Rdisp = Rdispref;
wpEner = wpEnerref;
Conso = Consoref;

progres_AEEI=ones(reg,1);
xtaxref = xtax;

p_stock = pref(:,1:nbsecteurenergie);
wpEner_prev = wpEnerref;
mtax_prev = mtax(:,1:nbsecteurenergie);
wpTIagg_prev = wpTIagg;
nit_prev = nit(:,1:nbsecteurenergie);

taxDFimp_prev = taxDFimp(:,1:nbsecteurenergie);
partImpDF_prev = partImpDFref(:,1:nbsecteurenergie);
partDomDF_stock = partDomDFref(:,1:nbsecteurenergie);
taxDFdom_prev = taxDFdom(:,1:nbsecteurenergie);

taxDIimp_prev = taxDIimp(:,1:nbsecteurenergie);
partImpDI_prev = partImpDIref(:,1:nbsecteurenergie);
partDomDI_stock = partDomDIref(:,1:nbsecteurenergie);
taxDIdom_prev = taxDIdom(:,1:nbsecteurenergie);

taxDGimp_prev = taxDGimp(:,1:nbsecteurenergie);
partImpDG_prev = partImpDGref(:,1:nbsecteurenergie);
partDomDG_stock = partDomDGref(:,1:nbsecteurenergie);
taxDGdom_prev = taxDGdom(:,1:nbsecteurenergie);

taxCIimp_prev = taxCIimp(1:nbsecteurenergie,:,:);
partImpCI_prev = partImpCIref(1:nbsecteurenergie,:,:);
partDomCI_stock = partDomCIref(1:nbsecteurenergie,:,:);
taxCIdom_prev = taxCIdom(1:nbsecteurenergie,:,:);

Cap_elec_MW=Cap_elec_MWref;
cumCapElec_GW = zeros( Cap_elec_MW );

Rdisp_prev_stock=Rdispref;
Ltot_prev_stock=Ltot0;

taxCO2_CI_nexus = taxCO2_CI;
taxCO2_DF_nexus = taxCO2_DF;
taxCO2_DG_nexus = taxCO2_DG;
taxCO2_DI_nexus = taxCO2_DI;

QuotasRevenue=zeros(reg,1);
x=x0;

disp ( 'Obtained precision for calibration point = '+ norm(economy(x0)));
