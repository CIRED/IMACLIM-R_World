// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION with no source   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

// elasticity international fret services
etaTI = 0.5;

// trade elasticity for fuel - alternative computation in thez static equlibrium
etaEtnew=[-2.63]; // -2.63 is the value that minimise the weights weightEt_new// -3 works fine for the baseline with the nexus land-use

// trade elasticity for productive sectors, exluding services, industrry, and agriculture.
// for those 3 sectors, check etaArmington
eta_calib = 0.9;

/////////////////////////////////////////////////////////////////////////////////////////////
//    ---*---   CALIBRATION   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//           reference prices                                              //
//////////////////////////////////////////////////////////////////////////////

// declaration of variables
Expref=zeros(nb_regions,nb_sectors);		        // exportations volumes
ExpTIref=zeros(nb_regions,nb_sectors);		// exportations of transport for international transport (quantities)
DFdomref=zeros(nb_regions,nb_sectors);		// domestic final demand from households
DGdomref=zeros(nb_regions,nb_sectors);		// domestic final demand from public admin
DIdomref=zeros(nb_regions,nb_sectors);		// domestic final demand from investors
CIdomref=zeros(nb_sectors,nb_sectors,nb_regions);		// domestic intermediate consumption
CIdomtot=zeros(nb_regions,nb_sectors);		// domestic total (each good all sectors) intermediate consumption
DFdomref=zeros(nb_regions,nb_sectors);		// imported final demand from households
DGdomref=zeros(nb_regions,nb_sectors);		// imported final demand from public admin
DIdomref=zeros(nb_regions,nb_sectors);		// imported final demand from investors
CIdomref=zeros(nb_sectors,nb_sectors,nb_regions);		// imported intermediate consumption
pref=ones(nb_regions,nb_sectors);			// reference prices

// extraction from GTAP aggregated variables

for k = 1:nb_regions,
    Expref(k,:) = (Exp_Im(k,:)-T_Exp_Im(k,:));
    ExpTIref(k,:) = Exp_trans_Im(k,:);  
    for j = 1:nb_sectors,
        if (C_hsld_dom_Im(k,j)-T_Hsld_dom_Im(k,j))==0 then DFdomref(k,j)=0;  
        else DFdomref(k,j)=C_hsld_dom_Im(k,j)-T_Hsld_dom_Im(k,j);
        end
        if (C_AP_dom_Im(k,j)-T_AP_dom_Im(k,j))==0 then DGdomref(k,j)=0;  
        else DGdomref(k,j)=C_AP_dom_Im(k,j)-T_AP_dom_Im(k,j);
        end
        if (FBCF_dom_Im(k,j)-T_FBCF_dom_Im(k,j))==0 then DIdomref(k,j)=0;  
        else DIdomref(k,j)=FBCF_dom_Im(k,j)-T_FBCF_dom_Im(k,j);
        end
        for ii=1:nb_sectors, 
            CIdomref(ii,j,k) = CI_dom_Im(k,ii,j);
        end

    end
    CIdomtot(k,:) = sum(CIdomref(:,:,k),'c')';
end

QCdomref = CIdomtot+DFdomref+DGdomref+DIdomref;
QGTAPref = QCdomref+Expref+ExpTIref;

// prices of energy corresponding to physical values

pref=ones(nb_regions,nb_sectors);
pref(:,1:nbsecteurenergie) = QGTAPref(:,1:nbsecteurenergie)./Ener_Prod_Im(:,1:nbsecteurenergie);

rand("seed",0); // set the seed to 0 for reproductibility of the random 
pref(:,[nonEnergyIndexes transportIndexes]) = pref(:,[nonEnergyIndexes transportIndexes]) + (rand( pref(:,[nonEnergyIndexes transportIndexes]),"uniform")/5/1e15)-0.1/1e15;

//////////////////////////////////////////////////////////////////////////////
//          Taxes, world price, calibration of CES of exports           //
//////////////////////////////////////////////////////////////////////////////

mtax = zeros(nb_regions,nb_sectors);		// tax rate on imports
xtax = zeros(nb_regions,nb_sectors);		// tax rate on exports
ImpHT = zeros(nb_regions,nb_sectors);		// imports value net of taxes
nit = zeros(nb_regions,nb_sectors);		// international transport requirement of imports (Need for International Transport)
taxCIdom = zeros(nb_sectors,nb_sectors,nb_regions);	// tax on domestic intermediate consumption (households)
taxCIimp = zeros(nb_sectors,nb_sectors,nb_regions);	// tax on imported intermediate consumption (households)
taxDFdom = zeros(nb_regions,nb_sectors);	// tax on domestic final consumption (households)
taxDFimp = zeros(nb_regions,nb_sectors);	// tax on imported final consumption (households)
taxDGdom = zeros(nb_regions,nb_sectors);	// tax on domestic final consumption (public admin)
taxDGimp = zeros(nb_regions,nb_sectors);	// tax on imported final consumption (public admin)
taxDIdom = zeros(nb_regions,nb_sectors);	// tax on domestic final consumption (investment)
taxDIimp = zeros(nb_regions,nb_sectors);	// tax on imported final consumption (investment)
qtax = zeros(nb_regions,nb_sectors);		// output tax

// computation from GTAP aggregated data
for k = 1:nb_regions,
    for j = 1:nb_sectors, if Imp_Im(k,j)==0 then mtax(k,j) = 0; else  mtax(k,j) = (T_Imp_Im(k,j)/Imp_Im(k,j)); end end
ImpHT(k,:) = Imp_Im(k,:);
for j = 1:nb_sectors, if (Exp_Im(k,j)-T_Exp_Im(k,j))==0 then xtax(k,j) = 0; else  xtax(k,j) = T_Exp_Im(k,j)/(Exp_Im(k,j)-T_Exp_Im(k,j)); end end
Expref(k,:) = Exp_Im(k,:)./(pref(k,:).*(1+xtax(k,:)));
ExpTIref(k,:) = Exp_trans_Im(k,:)./pref(k,:); 
end
mtaxref=mtax;
xtaxref=xtax;
// non-energy sectors
//
// calibration of regional weights in the CES function providing the amount of 'international' goods in the internationl pool 
// calibration of world prices and amounts of international goods

weightsqrt = csvRead( GTAP_V1+"weightsqrt.csv",'|',[],[],[],'/\/\//');
weightsqrt = weightsqrt(1:12,:);


// Initially, two versions of this file had been created, but for some reason, this way of doing seems to be more robust. Nevertheless, this writing could be adapted.
if nb_sectors_industry > 1
    for j=1:(nb_sectors_industry-1)
        weightsqrt(:,$+1)=weightsqrt(:,$);
    end
end

for e=[0.5,0.6,0.7,0.8,0.85,0.9]
    eta = e*ones(1,nb_sectors-nbsecteurenergie);
    [weightsqrt,v,info] = fsolve(weightsqrt,exportations_Cal);
end

indicesEta = [indice_composite-nbsecteurenergie indice_industries-nbsecteurenergie indice_agriculture-nbsecteurenergie];

list_eta = linspace(0.9,etaArmington,20);
for e=linspace(0.9,etaArmington,20)
    eta(indicesEta) = e;
    eta(indice_agriculture-nbsecteurenergie) = min( eta(indice_agriculture-nbsecteurenergie), 1.1*ind_trade_agri + (1-ind_trade_agri) * eta(indice_agriculture-nbsecteurenergie));
    [weightsqrt,v,info] = fsolve(weightsqrt,exportations_Cal);
end

if info==4 then 
    disp('calibration armington weight failed');
    pause;
end

weight = weightsqrt(1:nb_regions,:).^2;

// calibration of weights leads to unique values of world prices and volumes of imports

wpref(nbsecteurenergie+1:nb_sectors) = sum((weight.^(ones(nb_regions,1)*eta)).*((pref(:,nbsecteurenergie+1:nb_sectors).*(1+xtax(:,nbsecteurenergie+1:nb_sectors))).^(1-ones(nb_regions,1)*eta)),"r").^(ones(1,nb_sectors-nbsecteurenergie)./(1-eta));

// energy sectors
//
// world prices are the mean values of weighted export prices
// calibration of regional weights in the logit function of exports allocation

wpref(:,1:nbsecteurenergie) = sum(pref(:,1:nbsecteurenergie).*(1+xtax(:,1:nbsecteurenergie)).*Expref(:,1:nbsecteurenergie),'r')./sum(Expref(:,1:nbsecteurenergie),'r');

marketshareenerref = Expref(:,1:nbsecteurenergie)./(ones(nb_regions,1)*sum(Expref(:,1:nbsecteurenergie),'r'));
bmarketshareener = marketshareenerref;
etamarketshareener = -4*ones(1,nbsecteurenergie);

p_stock = pref;

// calib a new market share function
function zeroys=fixpoint_mshEt(xloc)
    marketshare_new = xloc .* (pref(:,indice_Et).*(1+xtax(:,indice_Et)) .^ etaEtnew ) ./ sum( xloc .* (pref(:,indice_Et).*(1+xtax(:,indice_Et)) .^ etaEtnew));
    zeroys = marketshareenerref(:,indice_Et) - marketshare_new;
endfunction
weightEt_new = ones(nb_regions,1);
[weightEt_new,v,info]  = fsolve( weightEt_new, fixpoint_mshEt);


Impref = ImpHT./(ones(nb_regions,1)*wpref);

// test of validity of physical quantities
testPM = ones(1,nb_sectors);
// non energy sectors
testPM(:,nbsecteurenergie+1:nb_sectors) = (sum(weight.*(Expref(:,nbsecteurenergie+1:nb_sectors).^(ones(nb_regions,1)*((eta-1)./eta))),"r")).^(eta./(eta-1))./sum(Impref(:,nbsecteurenergie+1:nb_sectors),"r")-1;
// energy sectors
testPM(:,1:nbsecteurenergie) = sum(Expref(:,1:nbsecteurenergie),'r')./sum(Impref(:,1:nbsecteurenergie),'r')-1;

// international transport 
weightTI0 = 0.15* ones(reg,nb_trans);

//Calibration of IT CES production function. We assume that the international transport of techno j in determined by a CES production function, in which each region can produce the service at a given price. Weights are square to keep only positive squared values. In order to get a nice fsolve the 12th region is remove, since we want a sum of weights to be equal to 1 (constant return to scale).
[weightTIsqrt,v,info] = fsolve(weightTI0,exportationsTI_Cal2);

if info==4 then 
    disp('calibration armington weightTI failed');
    pause;
end

//etaTI = 0.5;
//weightTIsqrt = (ExpTIref(:,indice_transport_1:indice_transport_2)./(ones(nb_regions,1)*sum(ExpTIref(:,indice_transport_1:indice_transport_2),"r"))).^0.5;
//[weightTIsqrt,v,info] = fsolve(weightTIsqrt,exportationsTI_Cal);
//[weightTIsqrt,v,info] = fsolve(weightTIsqrt,exportationsTI_Cal);
weightTI = (weightTIsqrt(1:nb_regions,:).^2);
wpTIref = sum((weightTI.^(ones(nb_regions,nb_trans)*etaTI).*(pref(:,indice_transport_1:indice_transport_2).^(1-ones(nb_regions,nb_trans)*etaTI))),'r').^(1 ./(1-etaTI));
PMTI = sum( weightTI.*(ExpTIref(:,indice_transport_1:indice_transport_2).^(ones(nb_regions,nb_trans)*(1-1/etaTI))) ,'r').^(ones(1,nb_trans)*(etaTI/(etaTI-1)));

// partTIref are the (remained constant) 'shares' of each transport in the total international need for transport
partTIref = PMTI./(ones(1,nb_trans)*sum(PMTI));
wpTIagg = sum(wpTIref.*partTIref);
for k = 1:nb_regions,
    for j = 1:nb_sectors, if (Imp_Im(k,j))==0 then nit(k,j) = nit(1,j); else  nit(k,j) = (Imp_trans_Im(k,j)/wpTIagg)./(Imp_Im(k,j)./wpref(j)); end end
end
pImp = (ones(nb_regions,1)*wpref).*(1+mtax)+(ones(nb_regions,nb_sectors)*wpTIagg).*nit;
pImp_notax = (ones(nb_regions,1)*wpref)+(ones(nb_regions,nb_sectors)*wpTIagg).*nit;
