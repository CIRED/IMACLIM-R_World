// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thomas Le Gallic, Ruben Bibas, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// Calibration Functions

function [y] =  FCC_calibration(xloc)
    a=xloc(1);
    b=xloc(2);
    c=xloc(3);
    y=zeros(3,1);
    y(1)=FCC_max-(a+b.*tanh(c.*(1-1)));
    y(2)=FCC_min-(a+b.*tanh(c.*(0-1)));
    y(3)=1-(a+b.*tanh(c.*(0.8-1)));
endfunction

// CES for exports

function [y] = exportations_Cal(x1);
    pref = pref(:,nbsecteurenergie+1:sec);
    Expref = Expref(:,nbsecteurenergie+1:sec);
    xtax = xtax(:,nbsecteurenergie+1:sec);
    N= sec-nbsecteurenergie;

    y1=1-((x1.^2)./(pref.*(1+xtax))).^(ones(reg,1)*eta)   .*(ones(reg,1) * (sum((x1.^2).*(Expref.^(1-ones(reg,N)./(ones(reg,1)*eta))),"r")./sum(((x1.^2).^(ones(reg,1)*eta)).*((pref.*(1+xtax)).^(1-ones(reg,1)*eta)),"r"))).^(ones(reg,1)*(eta./(eta-1)))./Expref;
    y2=ones(1,N)-sum((x1.^2).^(ones(reg,1)*eta),"r");
    y=[y1(1:11,:);y2];
endfunction


// CES For Exports of International Transport

function [y] = exportationsTI_Cal(weightTI);
    y1=1-(((weightTI.^2)./pref(:,indice_transport_1:indice_transport_2)).^(ones(reg,nb_trans)*etaTI)).*(ones(reg,1)*(sum((weightTI.^2).*(ExpTIref(:,indice_transport_1:indice_transport_2).^((1-1/etaTI)*ones(reg,nb_trans))),"r")./sum(((weightTI.^2).^(ones(reg,nb_trans)*etaTI)).*(pref(:,indice_transport_1:indice_transport_2).^(1-ones(reg,nb_trans)*etaTI)),"r")).^(etaTI./(etaTI-1)))./ExpTIref(:,indice_transport_1:indice_transport_2);
    y2=1-sum(weightTI.^2,"r");
    y=y1;
endfunction

function [y] = exportationsTI_Cal2(weightTI);//new fsolve function with the right number of equations, no +1 degree of freedom
    weightTI=weightTI(1:reg,:);
    y1=1-(((weightTI(1:reg-1,:).^2)./pref(1:reg-1,indice_transport_1:indice_transport_2)).^(ones(reg-1,nb_trans)*etaTI)).*(ones(reg-1,1)*(sum((weightTI.^2).*(ExpTIref(:,indice_transport_1:indice_transport_2).^((1-1/etaTI)*ones(reg,nb_trans))),"r")./sum(((weightTI.^2).^(ones(reg,nb_trans)*etaTI)).*(pref(:,indice_transport_1:indice_transport_2).^(1-ones(reg,nb_trans)*etaTI)),"r")).^(etaTI./(etaTI-1)))./ExpTIref(1:reg-1,indice_transport_1:indice_transport_2);
    y2=ones(1,nb_trans)-sum((weightTI.^2).^(ones(reg,nb_trans)*etaTI),"r");
    y=[y1(1:11,:);y2];
endfunction

// Transport prices

function [y] = transportprice_Cal(pOTloc);
    parttransport=zeros(reg,1);
    pairloc=factmultpair.*pOTloc;
    pautomobileloc=factmultpautomobile.*pOTloc;
    Ttaxloc=zeros(reg,sec);
    /////////calibration prices
    Ttaxloc(:,indice_Et)=(pautomobileloc)./(pArmDFref(:,indice_Et))-ones(reg,1);
    Ttaxloc(:,indice_air)=(pairloc)./(pArmDFref(:,indice_air))-ones(reg,1);
    Ttaxloc(:,indice_OT)=(pOTloc)./(pArmDFref(:,indice_OT))-ones(reg,1);
    /// accounting for Ttax in pArmDF ////
    pArmDFrefloc=pArmDFref.*(1+Ttaxloc);
    TTAXloc=(Ttaxloc./(1+Ttaxloc)).*pArmDFrefloc.*DFref;
    divloc=ones(reg,1);
    divloc=((sum(DFref.*pArmDFrefloc,'c')+Sref)+sum(DGref.*pArmDGref,'c')-sum(SALgross,'c')-sum(QTAX+TAXCI+MTAXCI+TAXDF+TAXDG+TAXDI+XTAX+TTAXloc,'c'))./sum(EBEref,'c');
    transfersrefloc=ones(reg,1);
    transfersrefloc=sum(QTAX+TAXCI+MTAXCI+TAXDF+TAXDG+TAXDI+XTAX+TTAXloc,'c')+sum(SALgross-SALNET,'c')+IR.*sum(SALNET+(divloc*ones(1,sec)).*EBEref,'c')-sum(DGref.*pArmDGref,'c');
    Rdisprefloc=ones(reg,1);
    Rdisprefloc=sum(SALNET,'c')+divloc.*sum(EBEref,'c')+transfersrefloc;
    parttransport=DFref(:,indice_air).*pArmDFrefloc(:,indice_air)+DFref(:,indice_OT).*pArmDFrefloc(:,indice_OT)+0.9*DFref(:,indice_Et).*pArmDFrefloc(:,indice_Et);

    //pause;
    //y=parttransport./Rdisprefloc-0.15*ones(reg,1);
    y=parttransport./Rdisprefloc-[0.15;0.2;0.15;0.15;0.15];
endfunction


function [y] = factmultprixtransCal(floc);
    factmultpairloc=floc(1:reg);
    factmultpautomobileloc=floc(reg+1:2*reg);
    tauloc=floc(2*reg+1:3*reg);
    factmultpair=factmultpairloc;
    factmultpautomobile=factmultpautomobileloc;
    [pOT,v,info]=fsolve(ones(reg,1),transportprice_Cal)
    pair=factmultpair.*pOT;
    pautomobile=factmultpautomobile.*pOT;
    Ttax=zeros(reg,sec);
    Ttax(:,indice_Et)=(pautomobile)./(pArmDFref(:,indice_Et))-ones(reg,1);
    Ttax(:,indice_air)=(pair)./(pArmDFref(:,indice_air))-ones(reg,1);
    Ttax(:,indice_OT)=(pOT)./(pArmDFref(:,indice_OT))-ones(reg,1);
    pArmDFrefloc=pArmDFref.*(1+Ttax);
    tairrefloc=(alphaair.^(-sigmatrans).*(Consoref(:,indice_air-nbsecteurenergie)-bnair).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*toNM.*betatrans(:,1)-100*tauloc.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pArmDFrefloc(:,indice_air))./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*alphaair)
    tOTrefloc=(betatrans(:,2).*alphaOT.^(-sigmatrans).*(Consoref(:,indice_OT-nbsecteurenergie)-bnOT).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*toNM-100*tauloc.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pArmDFrefloc(:,indice_OT))./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*alphaOT)
    tautomobilerefloc=(betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans-ones(reg,1)).*toNM-tauloc.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*(alphaEtauto.*pArmDFrefloc(:,indice_Et)+alphaCompositeauto.*pArmDFref(:,indice_composite)))./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)))
    y=[tairrefloc-tairrefo;tOTrefloc-tOTrefo;tautomobilerefloc-tautorefo];
endfunction

function y = normfactmultprixtransCal(x) ;
    y=norm(factmultprixtransCal(x)).^2;
endfunction

function [f,g,ind] = costfactmultprixtransCal(x,ind) ;
    [f,g,ind]=NDcost(x,ind,normfactmultprixtransCal);
endfunction

function [y] = paystransportprice_Cal(pOTloc1);
    pOTloc=pOTloc1*ones(reg,1)
    parttransport=zeros(reg,1);
    pairloc=factmultpair.*pOTloc;
    pautomobileloc=factmultpautomobile.*pOTloc;
    Ttaxloc=zeros(reg,sec);
    /////////calibrating prices
    Ttaxloc(:,indice_Et)=(pautomobileloc)./(pArmDFref(:,indice_Et))-ones(reg,1);
    Ttaxloc(:,indice_air)=(pairloc)./(pArmDFref(:,indice_air))-ones(reg,1);
    Ttaxloc(:,indice_OT)=(pOTloc)./(pArmDFref(:,indice_OT))-ones(reg,1);
    /// accounting for Ttax in pArmDF ////
    pArmDFrefloc=pArmDFref.*(1+Ttaxloc);
    TTAXloc=(Ttaxloc./(1+Ttaxloc)).*pArmDFrefloc.*DFref;
    divloc=ones(reg,1);
    divloc=((sum(DFref.*pArmDFrefloc,'c')+Sref)+sum(DGref.*pArmDGref,'c')-sum(SALgross,'c')-sum(QTAX+TAXCI+MTAXCI+TAXDF+TAXDG+TAXDI+XTAX+TTAXloc,'c'))./sum(EBEref,'c');
    transfersrefloc=ones(reg,1);
    transfersrefloc=sum(QTAX+TAXCI+MTAXCI+TAXDF+TAXDG+TAXDI+XTAX+TTAXloc,'c')+sum(SALgross-SALNET,'c')+IR.*sum(SALNET+(divloc*ones(1,sec)).*EBEref,'c')-sum(DGref.*pArmDGref,'c');
    Rdisprefloc=ones(reg,1);
    Rdisprefloc=sum(SALNET,'c')+divloc.*sum(EBEref,'c')+transfersrefloc;
    parttransport=DFref(:,indice_air).*pArmDFrefloc(:,indice_air)+DFref(:,indice_OT).*pArmDFrefloc(:,indice_OT)+0.9*DFref(:,indice_Et).*pArmDFrefloc(:,indice_Et);
    //y1=parttransport./Rdisprefloc-0.15*ones(reg,1);
    y1=parttransport./Rdisprefloc-[0.15;0.2;0.15;0.15;0.15];
    y=y1(pays);
endfunction


function [y] = paysfactmultprixtransCal(floc);
    //pays=1;
    factmultpairloc=floc(1);
    factmultpautomobileloc=floc(2);
    tauloc=floc(3);
    factmultpair=factmultpairloc;
    factmultpautomobile=factmultpautomobileloc;
    [pOT,v,info]=fsolve(1,paystransportprice_Cal)
    pair=factmultpair.*pOT;
    pautomobile=factmultpautomobile.*pOT;
    //pOT
    //pair
    //pautomobile
    Ttax=zeros(reg,sec);

    Ttax(:,indice_Et)=(pautomobile)./(pArmDFref(:,indice_Et))-ones(reg,1);
    Ttax(:,indice_air)=(pair)./(pArmDFref(:,indice_air))-ones(reg,1);
    Ttax(:,indice_OT)=(pOT)./(pArmDFref(:,indice_OT))-ones(reg,1);
    pArmDFrefloc=pArmDFref.*(1+Ttax);
    tairrefloc=(alphaair.^(-sigmatrans).*(Consoref(:,indice_air-nbsecteurenergie)-bnair).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*toNM.*betatrans(:,1)-100*tauloc.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pArmDFrefloc(:,indice_air))./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*alphaair)
    tOTrefloc=(betatrans(:,2).*alphaOT.^(-sigmatrans).*(Consoref(:,indice_OT-nbsecteurenergie)-bnOT).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*toNM-100*tauloc.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pArmDFrefloc(:,indice_OT))./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*alphaOT)
    tautomobilerefloc=(betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans-ones(reg,1)).*toNM-tauloc.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*(alphaEtauto.*pArmDFrefloc(:,indice_Et)+alphaCompositeauto.*pArmDFref(:,indice_composite)))./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)))
    y1=[tairrefloc-tairrefo;tOTrefloc-tOTrefo;tautomobilerefloc-tautorefo];

    y=[y1(pays);y1(pays+reg);y1(pays+2*reg)]
endfunction

function y = paysNfactMultpTransCal(x) ;
    y=norm(paysfactmultprixtransCal(x)).^2;
endfunction

function [f,g,ind] = paysCfactMultpTransCal(x,ind) ;
    [f,g,ind]=NDcost(x,ind,paysNfactMultpTransCal);
endfunction

/////////////////////////////////////////////////

function [y] = paystransportprice_Cal1(pOTloc1);
    pOTloc=pOTloc1*ones(reg,1)
    parttransport=zeros(reg,1);
    pautomobileloc=factmultpautomobile.*pOTloc;
    pairloc=(factmultpair+factmultpautomobile).*pOTloc;

    Ttaxloc=zeros(reg,sec);
    /////////calibrated prices
    Ttaxloc(:,indice_Et)=(pautomobileloc)./(pArmDFref(:,indice_Et))-ones(reg,1);
    Ttaxloc(:,indice_air)=(pairloc)./(pArmDFref(:,indice_air))-ones(reg,1);
    Ttaxloc(:,indice_OT)=(pOTloc)./(pArmDFref(:,indice_OT))-ones(reg,1);
    /// accounting for Ttax in pArmDF ////
    pArmDFrefloc=pArmDFref.*(1+Ttaxloc);
    TTAXloc=(Ttaxloc./(1+Ttaxloc)).*pArmDFrefloc.*DFref;
    divloc=ones(reg,1);
    divloc=((sum(DFref.*pArmDFrefloc,'c')+Sref)+sum(DGref.*pArmDGref,'c')-sum(SALgross,'c')-sum(QTAX+TAXCI+MTAXCI+TAXDF+TAXDG+TAXDI+XTAX+TTAXloc,'c'))./sum(EBEref,'c');
    transfersrefloc=ones(reg,1);
    transfersrefloc=sum(QTAX+TAXCI+MTAXCI+TAXDF+TAXDG+TAXDI+XTAX+TTAXloc,'c')+sum(SALgross-SALNET,'c')+IR.*sum(SALNET+(divloc*ones(1,sec)).*EBEref,'c')-sum(DGref.*pArmDGref,'c');
    Rdisprefloc=ones(reg,1);
    Rdisprefloc=sum(SALNET,'c')+divloc.*sum(EBEref,'c')+transfersrefloc;
    parttransport=DFref(:,indice_air).*pArmDFrefloc(:,indice_air)+DFref(:,indice_OT).*pArmDFrefloc(:,indice_OT)+0.9*DFref(:,indice_Et).*pArmDFrefloc(:,indice_Et);
    //y1=parttransport./Rdisprefloc-0.15*ones(reg,1);
    y1=parttransport./Rdisprefloc-[0.15;0.2;0.15;0.15;0.15];
    y=y1(pays);
endfunction


function [y] = paysfactMultpTransCal1(floc);
    //pays=1;
    factmultpairloc=floc(1);
    factmultpautomobileloc=floc(2);
    tauloc=floc(3);
    factmultpair=factmultpairloc;
    factmultpautomobile=factmultpautomobileloc;
    [pOT,v,info]=fsolve(1,paystransportprice_Cal)

    pautomobile=factmultpautomobile.*pOT;
    pair=(factmultpair+factmultpautomobile).*pOT;

    Ttax=zeros(reg,sec);
    Ttax(:,indice_Et)=(pautomobile)./(pArmDFref(:,indice_Et))-ones(reg,1);
    Ttax(:,indice_air)=(pair)./(pArmDFref(:,indice_air))-ones(reg,1);
    Ttax(:,indice_OT)=(pOT)./(pArmDFref(:,indice_OT))-ones(reg,1);
    pArmDFrefloc=pArmDFref.*(1+Ttax);
    tairrefloc=(alphaair.^(-sigmatrans).*(Consoref(:,indice_air-nbsecteurenergie)-bnair).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*toNM.*betatrans(:,1)-100*tauloc.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pArmDFrefloc(:,indice_air))./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*alphaair)
    tOTrefloc=(betatrans(:,2).*alphaOT.^(-sigmatrans).*(Consoref(:,indice_OT-nbsecteurenergie)-bnOT).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*toNM-100*tauloc.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pArmDFrefloc(:,indice_OT))./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*pkmautomobileref.*alphaOT)
    tautomobilerefloc=(betatrans(:,3).*(Tautomobileref-bnautomobile).^(-sigmatrans-ones(reg,1)).*toNM-tauloc.*betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)).*(alphaEtauto.*pArmDFrefloc(:,indice_Et)+alphaCompositeauto.*pArmDFref(:,indice_composite)))./(betatrans(:,4).*(TNMref-bnNM).^(-sigmatrans-ones(reg,1)))
    y1=[tairrefloc-tairrefo;tOTrefloc-tOTrefo;tautomobilerefloc-tautorefo];

    y=[y1(pays);y1(pays+reg);y1(pays+2*reg)]
endfunction

function y = paysNfactMultpTransCal1(x) ;
    y=norm(paysfactmultprixtransCal(x)).^2;
endfunction

function [f,g,ind] = paysCfactMultpTransCal1(x,ind) ;
    [f,g,ind]=NDcost(x,ind,paysNfactMultpTransCal);
endfunction

/////////////////////////////////////////////////

function [y] = Itair(Consoloc);
    y=toair.*(atrans(:,1).*((pkmautomobileref./(100*ones(reg,1))).*alphaair.*Consoloc(:,indice_air-nbsecteurenergie)./Captransport(:,1)).^(ktrans(:,1)+ones(reg,1)).*Captransport(:,1)./(ktrans(:,1)+ones(reg,1))+btrans(:,1).*(pkmautomobileref./(100*ones(reg,1))).*alphaair.*Consoloc(:,indice_air-nbsecteurenergie));
endfunction

function [y] = ItOT(Consoloc);
    y1=toOT.*(atrans(:,2).*((pkmautomobileref./(100*ones(reg,1))).*alphaOT.*Consoloc(:,indice_OT-nbsecteurenergie)./Captransport(:,2)).^(ktrans(:,2)+ones(reg,1)).*Captransport(:,2)./(ktrans(:,2)+ones(reg,1))+btrans(:,2).*(pkmautomobileref./(100*ones(reg,1))).*alphaOT.*Consoloc(:,indice_OT-nbsecteurenergie));
    y=y1;
endfunction

function [y] = Itautomobile(Tautomobileloc);
    y1=toautomobile.*(atrans(:,3).*((pkmautomobileref./(100*ones(reg,1))).*Tautomobileloc./Captransport(:,3)).^(ktrans(:,3)+ones(reg,1)).*Captransport(:,3)./(ktrans(:,3)+ones(reg,1))+btrans(:,3).*(pkmautomobileref./(100*ones(reg,1))).*Tautomobileloc);
    y=y1;
endfunction

function [y] = bilan_energetique(CI,Q,DF,Imp,Exp,pays);

    y1=zeros(indice_matEner,8);
    //lignes consommation : Prod Import Export Marine_bunker Primary_cons Refineries Power_plants Own_use__losses Final_cons Composite(services) agriculture IGCEM Air_transp Other_trans Automobile Residential
    //colonnes énergies : Coal Oil Et Gaz Hydro Nuc ENR Elec

    y1(prod_eb,coal_eb)        = Q(pays,indice_coal);
    y1(imp_eb,coal_eb)         = Imp(pays,indice_coal);
    y1(exp_eb,coal_eb)         = -Exp(pays,indice_coal);
    y1(marbunk_eb,coal_eb)     = -CI(indice_coal,indice_mer,pays)*Q(pays,indice_mer);
    y1(tpes_eb,coal_eb)        = sum(y1(prod_eb:marbunk_eb,coal_eb));
    y1(refi_eb,coal_eb)        = -CI(indice_coal,indice_Et,pays)*Q(pays,indice_Et);
    y1(pwplant_eb,coal_eb)     = -CI(indice_coal,indice_elec,pays)*Q(pays,indice_elec);
    y1(losses_eb,coal_eb)      = -CI(indice_coal,indice_coal,pays)*Q(pays,indice_coal);
    y1(conso_comp_eb,coal_eb)  = CI(indice_coal,indice_composite,pays)*Q(pays,indice_composite);
    y1(conso_agri_eb,coal_eb)  = CI(indice_coal,indice_agriculture,pays)*Q(pays,indice_agriculture);
    y1(conso_indu_eb,coal_eb)  = sum(CI(indice_coal,indice_industries,pays).*Q(pays,indice_industries),'c');
    y1(conso_air_eb,coal_eb)   = CI(indice_coal,indice_air,pays)*Q(pays,indice_air);
    y1(conso_ot_eb,coal_eb)    = CI(indice_coal,indice_OT,pays)*Q(pays,indice_OT);
    y1(conso_car_eb,coal_eb)   = 0;
    y1(conso_resid_eb,coal_eb) = alphaCoalm2(pays).*stockbatiment(pays);
    y1(conso_btp_eb,coal_eb)   = CI(indice_coal,indice_construction,pays)*Q(pays,indice_construction);
    y1(conso_tot_eb,coal_eb)   = sum(y1(conso_comp_eb:indice_matEner,1));

    y1(prod_eb,oil_eb)         = Q(pays,indice_oil);
    y1(imp_eb,oil_eb)          = Imp(pays,indice_oil);
    y1(exp_eb,oil_eb)          = -Exp(pays,indice_oil);
    y1(marbunk_eb,oil_eb)      = -CI(indice_oil,indice_mer,pays)*Q(pays,indice_mer);
    y1(tpes_eb,oil_eb)         = sum(y1(prod_eb:marbunk_eb,oil_eb));
    y1(refi_eb,oil_eb)         = -CI(indice_oil,indice_Et,pays)*Q(pays,indice_Et);
    y1(pwplant_eb,oil_eb)      = -CI(indice_oil,indice_elec,pays)*Q(pays,indice_elec);
    y1(losses_eb,oil_eb)       = -CI(indice_oil,indice_oil,pays)*Q(pays,indice_oil);
    y1(conso_comp_eb,oil_eb)   = CI(indice_oil,indice_composite,pays)*Q(pays,indice_composite);
    y1(conso_agri_eb,oil_eb)   = CI(indice_oil,indice_agriculture,pays)*Q(pays,indice_agriculture);
    y1(conso_indu_eb,oil_eb)   = sum(CI(indice_oil,indice_industries,pays).*Q(pays,indice_industries),'c');
    y1(conso_air_eb,oil_eb)    = CI(indice_oil,indice_air,pays)*Q(pays,indice_air);
    y1(conso_ot_eb,oil_eb)     = CI(indice_oil,indice_OT,pays)*Q(pays,indice_OT);
    y1(conso_car_eb,oil_eb)    = 0;
    y1(conso_resid_eb,oil_eb)  = DF(pays,indice_oil);
    y1(conso_btp_eb,oil_eb)  = CI(indice_oil,indice_construction,pays)*Q(pays,indice_construction);
    y1(conso_tot_eb,oil_eb)    = sum(y1(conso_comp_eb:indice_matEner,2));

    y1(prod_eb,et_eb)          = 0;
    y1(imp_eb,et_eb)           = Imp(pays,indice_Et);
    y1(exp_eb,et_eb)           = -Exp(pays,indice_Et);
    y1(marbunk_eb,et_eb)       = -CI(indice_Et,indice_mer,pays)*Q(pays,indice_mer);
    y1(tpes_eb,et_eb)          = sum(y1(prod_eb:marbunk_eb,et_eb));
    y1(refi_eb,et_eb)          = Q(pays,indice_Et);
    y1(pwplant_eb,et_eb)       = -CI(indice_Et,indice_elec,pays)*Q(pays,indice_elec);
    y1(losses_eb,et_eb)        = -CI(indice_Et,indice_Et,pays)*Q(pays,indice_Et);
    y1(conso_comp_eb,et_eb)    = CI(indice_Et,indice_composite,pays)*Q(pays,indice_composite);
    y1(conso_agri_eb,et_eb)    = CI(indice_Et,indice_agriculture,pays)*Q(pays,indice_agriculture);
    y1(conso_indu_eb,et_eb)    = sum(CI(indice_Et,indice_industries,pays).*Q(pays,indice_industries),'c');
    y1(conso_air_eb,et_eb)     = CI(indice_Et,indice_air,pays)*Q(pays,indice_air);
    y1(conso_ot_eb,et_eb)      = CI(indice_Et,indice_OT,pays)*Q(pays,indice_OT)-alphaEtauto(pays) * pkm_ldv_in_OT(pays); // We remove the energy consumption of LDV used by business sectors and administration.
    y1(conso_car_eb,et_eb)     = Tautomobile(pays).*alphaEtauto(pays).*pkmautomobileref(pays)./100 + alphaEtauto(pays) * pkm_ldv_in_OT(pays); // We remove the energy consumption of LDV used by business sectors and administration.;
    y1(conso_resid_eb,et_eb)   = alphaEtm2(pays).*stockbatiment(pays);
    y1(conso_btp_eb,et_eb)   = CI(indice_Et,indice_construction,pays)*Q(pays,indice_construction);
    y1(conso_tot_eb,et_eb)     = sum(y1(conso_comp_eb:indice_matEner,et_eb));

    y1(prod_eb,gas_eb)         = Q(pays,indice_gas);
    y1(imp_eb,gas_eb)          = Imp(pays,indice_gas);
    y1(exp_eb,gas_eb)          = -Exp(pays,indice_gas);
    y1(marbunk_eb,gas_eb)      = -CI(indice_gas,indice_mer,pays)*Q(pays,indice_mer);
    y1(tpes_eb,gas_eb)         = sum(y1(prod_eb:marbunk_eb,gas_eb));
    y1(refi_eb,gas_eb)         = -CI(indice_gas,indice_Et,pays)*Q(pays,indice_Et);
    y1(pwplant_eb,gas_eb)      = -CI(indice_gas,indice_elec,pays)*Q(pays,indice_elec);
    y1(losses_eb,gas_eb)       = -CI(indice_gas,indice_gas,pays)*Q(pays,indice_gas);
    y1(conso_comp_eb,gas_eb)   = CI(indice_gas,indice_composite,pays)*Q(pays,indice_composite);
    y1(conso_agri_eb,gas_eb)   = CI(indice_gas,indice_agriculture,pays)*Q(pays,indice_agriculture);
    y1(conso_indu_eb,gas_eb)   = sum(CI(indice_gas,indice_industries,pays).*Q(pays,indice_industries),'c');
    y1(conso_air_eb,gas_eb)    = CI(indice_gas,indice_air,pays)*Q(pays,indice_air);
    y1(conso_ot_eb,gas_eb)     = CI(indice_gas,indice_OT,pays)*Q(pays,indice_OT);
    y1(conso_car_eb,gas_eb)    = 0;
    y1(conso_resid_eb,gas_eb)  = alphaGazm2(pays).*stockbatiment(pays);
    y1(conso_btp_eb,gas_eb)  = CI(indice_gas,indice_construction,pays)*Q(pays,indice_construction);
    y1(conso_tot_eb,gas_eb)    = sum(y1(conso_comp_eb:indice_matEner,gas_eb));

    if current_time_im>0 // msh_elec_techno not defined at calibration
        y1(prod_eb,hyd_eb)         = msh_elec_techno(pays,indice_HYD) *Q(pays,indice_elec);
        y1(tpes_eb,hyd_eb)         = sum(y1(prod_eb:marbunk_eb,hyd_eb));
        y1(pwplant_eb,hyd_eb)      = -msh_elec_techno(pays,indice_HYD) * Q(pays,indice_elec);

        y1(prod_eb,nuc_eb)         = (msh_elec_techno(pays,indice_NUC)+msh_elec_techno(pays,indice_NND))*Q(pays,indice_elec)/nuclPrim2Sec;
        y1(tpes_eb,nuc_eb)         = sum(y1(prod_eb:marbunk_eb,nuc_eb));
        y1(pwplant_eb,nuc_eb)      = -(msh_elec_techno(pays,indice_NUC)+msh_elec_techno(pays,indice_NND))*Q(pays,indice_elec)/nuclPrim2Sec;

        y1(prod_eb,enr_eb)         = sum(msh_elec_techno(pays,[technoWind technoSolar technoBiomass])./[1 1 1 1 1 rho_elec_nexus(pays,technoBiomass)]) * Q(pays,indice_elec)..
            + max(0,..
            (..
            Q(pays,indice_Et)..
            - CI(indice_coal,indice_Et,pays)*Q(pays,indice_Et)/2 ..
            - CI(indice_oil,indice_Et,pays)/CIref(indice_oil,indice_Et,pays)*Q(pays,indice_Et)..
        ));
        y1(tpes_eb,enr_eb)         = sum(y1(prod_eb:marbunk_eb,enr_eb));
        y1(refi_eb,enr_eb)         = -max((Q(pays,indice_Et)-CI(indice_coal,indice_Et,pays)*Q(pays,indice_Et)/2-CI(indice_oil,indice_Et,pays)/CIref(indice_oil,indice_Et,pays)*Q(pays,indice_Et)),0);
        y1(pwplant_eb,enr_eb)      = -sum(msh_elec_techno(pays,[technoWind technoSolar technoBiomass])./[1 1 1 1 1 rho_elec_nexus(pays,technoBiomass)]) * Q(pays,indice_elec);

    end

    y1(prod_eb,elec_eb)        = 0;
    y1(imp_eb,elec_eb)         = Imp(pays,indice_elec);
    y1(exp_eb,elec_eb)         = -Exp(pays,indice_elec);
    y1(marbunk_eb,elec_eb)     = -CI(indice_elec,indice_mer,pays)*Q(pays,indice_mer);
    y1(tpes_eb,elec_eb)        = sum(y1(prod_eb:marbunk_eb,elec_eb));
    y1(refi_eb,elec_eb)        = -CI(indice_elec,indice_Et,pays)*Q(pays,indice_Et);
    y1(pwplant_eb,elec_eb)     = Q(pays,indice_elec);
    y1(losses_eb,elec_eb)      = -CI(indice_elec,indice_elec,pays)*Q(pays,indice_elec);
    y1(conso_comp_eb,elec_eb)  = CI(indice_elec,indice_composite,pays)*Q(pays,indice_composite);
    y1(conso_agri_eb,elec_eb)  = CI(indice_elec,indice_agriculture,pays)*Q(pays,indice_agriculture);
    y1(conso_indu_eb,elec_eb)  = sum(CI(indice_elec,indice_industries,pays).*Q(pays,indice_industries),'c');
    y1(conso_air_eb,elec_eb)   = CI(indice_elec,indice_air,pays)*Q(pays,indice_air);
    y1(conso_ot_eb,elec_eb)    = CI(indice_elec,indice_OT,pays)*Q(pays,indice_OT) - alphaelecauto(pays) * pkm_ldv_in_OT(pays);
    y1(conso_car_eb,elec_eb)   = Tautomobile(pays).*alphaelecauto(pays).*pkmautomobileref(pays)./100 + alphaelecauto(pays) * pkm_ldv_in_OT(pays);
    y1(conso_resid_eb,elec_eb) = alphaelecm2(pays).*stockbatiment(pays); 
    y1(conso_btp_eb,elec_eb) = CI(indice_elec,indice_construction,pays)*Q(pays,indice_construction);
    y1(conso_tot_eb,elec_eb)   = sum(y1(conso_comp_eb:indice_matEner,elec_eb));

    y=matrix(y1,indice_matEner*8,1);
endfunction


function [y] = budget_menages(pArmDF,DF,pays);
    y=(pArmDF(pays,:).*DF(pays,:))';
endfunction

function [y] = part_budget_menages(pArmDF,DF,pays);
    y=((pArmDF(pays,:).*DF(pays,:))')/(sum(pArmDF(pays,:).*DF(pays,:)));
endfunction

function [y] = repartition_inv(Inv_val,partInvFin,pays);
    y=(partInvFin(pays,:)*Inv_val(pays))';
endfunction

function [y] = IC_calibration(MS,LCC,index_ref,val_nu)
    ///MS: market share of calibration sum(MS)=1, MS(k)<>0, vector of size n (in lines)
    ///LCC: corresponding utilisation costs, vector of size n (in lines)
    ///index_ref : number of technology that will be used in the computing, integer
    /// -val_nu : power of the logit; real
    //////Marsket Share treatement fo remove null values
    MS_temp=max(MS,0.000001);
    /////the sum should be one
    sum_MS_temp=sum(MS_temp);
    MS=MS_temp/sum(MS_temp);
    size_MS=size(MS);
    size_MS_int=size_MS(2);
    itgbl_cost_sol=zeros(1,size_MS_int);
    mask_index_ref=ones(1,size_MS_int);
    mask_index_ref(index_ref)=0;
    itgbl_cost_sol(index_ref)=sum(((MS/MS(index_ref)).^(-ones(1,size_MS_int)/val_nu).*(LCC-(MS/MS(index_ref)).^(-ones(1,size_MS_int)/val_nu)*LCC(index_ref))).*mask_index_ref) / ...
    (1+sum((MS/MS(index_ref)).^(-2*ones(1,size_MS_int)/val_nu).*mask_index_ref));

    for j=1:size_MS_int
        if j<>index_ref then itgbl_cost_sol(j)=(MS(j)/MS(index_ref)).^(-1/val_nu)*(LCC(index_ref)+itgbl_cost_sol(index_ref))-LCC(j); end
    end

    IntanCostSolIndex=-999;
    for j=1:size_MS_int
        if j<>index_ref & (itgbl_cost_sol(j)<0) then 
            itgbl_cost_sol_temp=LCC(j)/(MS(j)/MS(index_ref)).^(-1/val_nu)-LCC(index_ref);
            if IntanCostSolIndex==-999 then IntanCostSolIndex=itgbl_cost_sol_temp; end
            if itgbl_cost_sol_temp>IntanCostSolIndex then
                IntanCostSolIndex=itgbl_cost_sol_temp;
            end

        end
    end

    if IntanCostSolIndex<>-999 then 
        IntanCostSolIndex=max(IntanCostSolIndex,0);
        itgbl_cost_sol=zeros(1,size_MS_int);
        itgbl_cost_sol(index_ref)=IntanCostSolIndex;
        for j=1:size_MS_int
            if j<>index_ref then itgbl_cost_sol(j)=(MS(j)/MS(index_ref)).^(-1/val_nu)*(LCC(index_ref)+itgbl_cost_sol(index_ref))-LCC(j); end
        end
    end

    y=itgbl_cost_sol;
endfunction

function [y] = IC_calibration_2(MS,LCC,index_ref,val_nu)
    ///MS: market share of calibration sum(MS)=1, MS(k)<>0, vector of size n (in lines)
    ///LCC: corresponding utilisation costs, vector of size n (in lines)
    ///index_ref : number of technology that will be used in the computing, integer
    /// -val_nu : power of the logit; real
    //////Marsket Share treatement fo remove null values

    MS_temp=max(MS,0.000001);
    /////sum should be one
    sum_MS_temp=sum(MS_temp);
    MS=MS_temp/sum(MS_temp);
    size_MS=size(MS);
    size_MS_int=size_MS(2);
    itgbl_cost_sol=zeros(1,size_MS_int);


    itgbl_cost_sol(index_ref)=1;
    for j=1:size_MS_int
        if j<>index_ref then itgbl_cost_sol(j)=(MS(j)/MS(index_ref)).^(-1/val_nu)*(LCC(index_ref)+itgbl_cost_sol(index_ref))-LCC(j); end
    end


    y=itgbl_cost_sol;
endfunction


function [y] = calib_wage_curve(xloc);
    aw=xloc(1:reg);
    bw=-aw;
    cw=xloc(reg+1:2*reg);
    //calibration value
    y(1:reg) = aw+bw.*tanh(cw.*z)-1;
    //local elasticity at the calibration value
    y(reg+1:2*reg) = bw.*cw.*z./((aw+bw.*tanh(cw.*z)).*cosh(cw.*z).^2)-(ew*ones(reg,1));
endfunction

//function [y] = calib_wage_curve1(xloc);
//    aw=xloc(1:reg);
//    bw=xloc(reg+1:2*reg);;
//    cw=xloc(2*reg+1:3*reg);
//calibration value
//    y(1:reg) = aw+bw.*tanh(cw.*z)-1;
//local elasticity at the calibration value
//    y(reg+1:2*reg) = bw.*cw.*z./((aw+bw.*tanh(cw.*z)).*cosh(cw.*z).^2)-(-0.55*ones(reg,1));
//    //value of wage for unemployment equal to 1, we do not fixe a minimal value
//    y(2*reg+1:3*reg) = aw+bw.*tanh(cw)-0;
//endfunction

// function to calibrate the weight in the logit for the liquids trade market shares (if new_Et_msh_computation==1)
function zeroys=fixpoint_mshEt(xloc)
    marketshare_new = xloc .* (pref(:,indice_Et).*(1+xtax(:,indice_Et)) .^ etaEtnew ) ./ sum( xloc .* (pref(:,indice_Et).*(1+xtax(:,indice_Et)) .^ etaEtnew));
    zeroys = marketshareenerref(:,indice_Et) - marketshare_new;
endfunction

