// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Ruben Bibas, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//////////////////////////////////////////////////////////////////////////////////////////////////
//
//  IMACLIM-R
//  International Multisector Computable General Equilibrium Model

////////////////////-------------------------------------------------------------//////////////////
////////////////////   file including main functions of the static equilibrium   //////////////////
////////////////////-------------------------------------------------------------//////////////////


/////////////////// Households module /////////////////////////////////////////////////////////////


function [y] = Utility(Consoloc,Tautomobileloc,TNMloc,lambdaloc,muloc) ;
    // double constraint (money + time)
    //Consoloc=[DFBTP,DFcomposite,DFair,DFmer,DFOT]
    y=zeros(reg,nb_secteur_conso+2);
    y(:,indice_construction-nbsecteurenergie)=((Consoloc(:,indice_construction-nbsecteurenergie)-bn(:,indice_construction)).*lambdaloc.*pArmDF(:,indice_construction))-xsi(:,1);
    y(:,indice_composite-nbsecteurenergie)=((Consoloc(:,indice_composite-nbsecteurenergie)-bn(:,indice_composite)).*lambdaloc.*pArmDF(:,indice_composite))-xsi(:,2);
    y(:,indice_mer-nbsecteurenergie)=((Consoloc(:,indice_mer-nbsecteurenergie)-bn(:,indice_mer)).*lambdaloc.*pArmDF(:,indice_mer))-xsi(:,3);
    y(:,indice_air-nbsecteurenergie)=xsiT.*betatrans(:,1).*(alphaair).^(-sigmatrans).*((Consoloc(:,indice_air-nbsecteurenergie))-bnair).^(-sigmatrans-1)+(betatrans(:,1).*(alphaair.*(Consoloc(:,indice_air-nbsecteurenergie)-bnair)).^(-sigmatrans)+betatrans(:,2).*(alphaOT.*(Consoloc(:,indice_OT-nbsecteurenergie)-bnOT)).^(-sigmatrans)+betatrans(:,3).*(Tautomobileloc-bnautomobile).^(-sigmatrans)+betatrans(:,4).*(TNMloc-bnNM).^(-sigmatrans)).*(-lambdaloc.*pArmDF(:,indice_air)-muloc.*pkmautomobileref./(ones(reg,1)*100).*alphaair.*tair(Consoloc));
    y(:,indice_OT-nbsecteurenergie)=xsiT.*betatrans(:,2).*(alphaOT).^(-sigmatrans).*(Consoloc(:,indice_OT-nbsecteurenergie)-bnOT).^(-sigmatrans-1)+(betatrans(:,1).*(alphaair.*(Consoloc(:,indice_air-nbsecteurenergie)-bnair)).^(-sigmatrans)+betatrans(:,2).*(alphaOT.*(Consoloc(:,indice_OT-nbsecteurenergie)-bnOT)).^(-sigmatrans)+betatrans(:,3).*(Tautomobileloc-bnautomobile).^(-sigmatrans)+betatrans(:,4).*(TNMloc-bnNM).^(-sigmatrans)).*(-lambdaloc.*pArmDF(:,indice_OT)-muloc.*pkmautomobileref./(ones(reg,1)*100).*alphaOT.*tOT(Consoloc));
    y(:,indice_agriculture-nbsecteurenergie)=((Consoloc(:,indice_agriculture-nbsecteurenergie)-bn(:,indice_agriculture)).*lambdaloc.*pArmDF(:,indice_agriculture))-xsi(:,4);
    y(:,indice_industries-nbsecteurenergie)=((Consoloc(:,indice_industries-nbsecteurenergie)-bn(:,indice_industries)).*repmat(lambdaloc,1,nb_sectors_industry).*pArmDF(:,indice_industries))-xsi(:,5:4+nb_sectors_industry);
    y(:,nb_secteur_conso+1)=xsiT.*betatrans(:,3).*(Tautomobileloc-bnautomobile).^(-sigmatrans-1)+(betatrans(:,1).*(alphaair.*(Consoloc(:,indice_air-nbsecteurenergie)-bnair)).^(-sigmatrans)+betatrans(:,2).*(alphaOT.*(Consoloc(:,indice_OT-nbsecteurenergie)-bnOT)).^(-sigmatrans)+betatrans(:,3).*(Tautomobileloc-bnautomobile).^(-sigmatrans)+betatrans(:,4).*(TNMloc-bnNM).^(-sigmatrans)).*(-lambdaloc.*(alphaEtauto.*pArmDF(:,indice_Et)+alphaelecauto.*pArmDF(:,indice_elec)+alphaCompositeauto.*pArmDF(:,indice_composite)).*pkmautomobileref./(100*ones(reg,1))-muloc.*pkmautomobileref./(ones(reg,1)*100).*tautomobile(Tautomobileloc));
    y(:,nb_secteur_conso+2)=xsiT.*betatrans(:,4).*(TNMloc-bnNM).^(-sigmatrans-1)+(betatrans(:,1).*(alphaair.*(Consoloc(:,indice_air-nbsecteurenergie)-bnair)).^(-sigmatrans)+betatrans(:,2).*(alphaOT.*(Consoloc(:,indice_OT-nbsecteurenergie)-bnOT)).^(-sigmatrans)+betatrans(:,3).*(Tautomobileloc-bnautomobile).^(-sigmatrans)+betatrans(:,4).*(TNMloc-bnNM).^(-sigmatrans)).*(-muloc.*pkmautomobileref./(ones(reg,1)*100).*toNM);

    y = matrix(y,1,reg*(nb_secteur_conso+2));
endfunction


function [y1] = DFinduite(Consoloc,Tautomobileloc) ;
    //fonction qui calcule la demande finale de ménages en fonction de leur consommation, pour le moment le logement n'est pas pris en compte

    y1 = zeros(reg,sec);
    //voir les problèmes de calibration
    y1(:,indice_energiefossile1:indice_energiefossile2)=DFref(:,indice_energiefossile1:indice_energiefossile2);
    //secteur conso
    y1(:,indice_construction)=Consoloc(:,indice_construction-nbsecteurenergie);
    y1(:,indice_composite)=Consoloc(:,indice_composite-nbsecteurenergie)+Tautomobileloc.*alphaCompositeauto.*pkmautomobileref./100;
    y1(:,indice_mer)=Consoloc(:,indice_mer-nbsecteurenergie);
    y1(:,indice_air)=Consoloc(:,indice_air-nbsecteurenergie);
    y1(:,indice_OT)=Consoloc(:,indice_OT-nbsecteurenergie);
    y1(:,indice_agriculture)=Consoloc(:,indice_agriculture-nbsecteurenergie);
    y1(:,indice_industries)=Consoloc(:,indice_industries-nbsecteurenergie);
    //conso induites énergie
    y1(:,indice_Et)=Tautomobileloc.*alphaEtauto.*pkmautomobileref./100+alphaEtm2.*stockbatiment;
    y1(:,indice_elec)=alphaelecm2.*stockbatiment+Tautomobileloc.*alphaelecauto.*pkmautomobileref./100;
    y1(:,indice_coal)=alphaCoalm2.*stockbatiment;
    y1(:,indice_gaz)=alphaGazm2.*stockbatiment;

endfunction


function [y] = Household_budget(Rdisploc,Consoloc,Tautomobileloc) ;

    //DFloc=DFinduite(Consoloc,Tautomobileloc);
    // warning : Rdisp includes income taxes and pArmDF includes all taxes
    y = (ptc-sum((DFloc.*pArmDF),'c')./(Rdisploc.*(1-IR)))';
endfunction


function [y] = Time_budget(Consoloc,Tautomobileloc,TNMloc);
    //y1 = ones(reg,1)-((Tautomobileloc.*(pkmautomobileref/100).*toautomobile.*(atrans(:,3).*tanh(((pkmautomobileref./(100*ones(reg,1))).*Tautomobileloc./Captransport(:,3)-xotrans(:,3)).*gammatrans(:,3))+btrans(:,3))+(pkmautomobileref/100).*alphaair.*Consoloc(:,indice_air-nbsecteurenergie).*toair.*(atrans(:,1).*tanh(((pkmautomobileref./(100*ones(reg,1))).*alphaair.*Consoloc(:,indice_air-nbsecteurenergie)./Captransport(:,1)-xotrans(:,1)).*gammatrans(:,1))+btrans(:,1))+(pkmautomobileref/100).*alphaOT.*Consoloc(:,indice_OT-nbsecteurenergie).*toOT.*(atrans(:,2).*tanh(((pkmautomobileref./(100*ones(reg,1))).*alphaOT.*Consoloc(:,indice_OT-nbsecteurenergie)./Captransport(:,2)-xotrans(:,2)).*gammatrans(:,2))+btrans(:,2))+(pkmautomobileref/100).*TNMloc.*toNM))./Tdisp;
    y = (ones(reg,1)-((Itautomobile(Tautomobileloc)+Itair(Consoloc)+ItOT(Consoloc)+(pkmautomobileref/100).*TNMloc.*toNM))./Tdisp)';
endfunction


/////////////////// Fonctions temps de transport pour chaque mode ////////////////////////////////////////////////////////////////


function [y] = tair(Consoloc);
    y = toair.*(atrans(:,1).*((pkmautomobileref./(100*ones(reg,1))).*alphaair.*Consoloc(:,indice_air-nbsecteurenergie)./Captransport(:,1)).^ktrans(:,1)+btrans(:,1));
endfunction

function [y] = tOT(Consoloc);
    y=toOT.*(atrans(:,2).*((pkmautomobileref./(100*ones(reg,1))).*alphaOT.*Consoloc(:,indice_OT-nbsecteurenergie)./Captransport(:,2)).^ktrans(:,2)+btrans(:,2));
endfunction

function [y] = tautomobile(Tautomobileloc);
    y = toautomobile.*(atrans(:,3).*((pkmautomobileref./(100*ones(reg,1))).*Tautomobileloc./Captransport(:,3)).^ktrans(:,3)+btrans(:,3));
endfunction

/////////////////// Sectors module ////////////////////////////////////////////////////////////////

// desormais markup pour tous les secteurs, on distingue plus tard les secteurs un à un lors de l'étude des fonctions de production

function [y] = Sector_budget(ploc,wloc,Qloc);
    //
    costs_CI=zeros(reg,sec);
    for k=1:reg,
        costs_CI(k,:)=sum(pArmCI(:,:,k).*CI(:,:,k),"r");
    end
    //
    y=(A.*(costs_CI+wloc.*l.*(1+sigma).*(energ_sec+FCCtemp.*non_energ_sec))+FCCmarkup_oil.*markup.*ploc.*((energ_sec+non_energ_sec))).*(1+qtax)-ploc;
    //
    y = matrix(y,1,reg*sec);
endfunction 

function [y] = Market_clear(Qloc);
    //
    y = (QCdomtemp+Exptemp+ExpTItemp)./Qloc-1;
    y = matrix(y,1,reg*sec);
endfunction

function [y] = Wages(wloc,Qloc,pindtemp);
    //
    //y1=wloc./(pindtemp*ones(1,sec))-wref./(pindref*ones(1,sec)).*((aw+bw.*tanh(cw.*zloc))*ones(1,sec));
    // y1=1-(pindtemp*ones(1,sec)).*wref.*((aw+bw.*tanh(cw.*zloc))*ones(1,sec))./((pindref*ones(1,sec)).*wloc);
    y=1-(pindtemp*ones(1,sec)).*wref.*((aw+bw.*tanh(cw.*zloc))*ones(1,sec))./(wloc);
    y = matrix(y,1,reg*sec);
endfunction

function [y] = Energy_world_prices(wpEnerloc,ploc);
    //
    y=wpEnerloc-sum(Exptemp(:,1:nbsecteurenergie).*ploc(:,1:nbsecteurenergie).*(1+xtax(:,1:nbsecteurenergie)),'r')./sum(Imptemp(:,1:nbsecteurenergie),'r');
endfunction

///Fonction n'est plus utilisée
//function [y] = Invest_good_demand(DIloc);
//
//y1=(DIloc-[DeltaKtemp(1,:)*(Beta(:,:,1)');DeltaKtemp(2,:)*(Beta(:,:,2)');DeltaKtemp(3,:)*(Beta(:,:,3)');DeltaKtemp(4,:)*(Beta(:,:,4)');DeltaKtemp(5,:)*(Beta(:,:,5)')]-DIinfra)./DIloc;
//y=matrix(y1,1,reg*sec);
//endfunction

/////////////////// States module ////////////////////////////////////////////////////

function [y] = State_budget(Rdisploc,wloc,Qloc);
    //
    y1=(Rdisploc.*(1-IR)+sum(pArmDG.*DG,"c")-sumtaxtemp-QuotasRevenue-sum(A.*wloc.*l.*Qloc.*(energ_sec+FCCtemp.*non_energ_sec),"c")-div.*sum(ploc.*Qloc.*FCCmarkup_oil.*markup.*(FCCtemp.*energ_sec+non_energ_sec),"c"))./Rdisploc;
    //
    y=y1';
endfunction
//////////////////////////////////////////////////////////////////////////////////////

function [gap] = emissions_gap(Qloc,DFloc,DIloc,Imptemp,Exptemp,TAXVALloc)
    //constraint : objectif-emissions an fsolve will find the zeros 
    //Calcule les emissions à partir des variables Qloc DFloc  et DIloc    
    //et les compare au parametre CO2_obj_MKTparam
    //le parametre areEmiConstr desactive la contrainte sur les emissions

    E_reg_useloc = emissions_usage(CI,Qloc,DFloc,DIloc) //Emissions par usage, tC02
    E_CO2_MKT = zeros(nbMKT,1) //Emissions par marché contraint

    for m=1:nbMKT  
        E_CO2_MKT(m,:) = sum(E_reg_useloc(whichMKT_reg_use==m))
    end

    //contrainte (=0 grace au fsolve)
    gap = (E_CO2_MKT./CO2_obj_MKTparam) - 1;

    //marchés desactivés
    gap(~areEmisConstparam )=0;

    // say TAXVALloc gap areEmisConstparam
endfunction

function E_reg_use = emissions_usage(CI,Qloc,DFloc,DIloc)
    //Emissions par region et usage. Voir nb_use dans indexes.sce

    E_reg_use = zeros(reg,nb_use);

    for r=1:reg
        E_reg_use(r,1:sec) =sum((CI(:,:,r).*coef_Q_CO2_CI(:,:,r)),'r').*Qloc(r ,:);
    end

    //coef_Q_CO2_Et_prod    

    E_reg_use(:,iu_df)=sum(DFloc.*coef_Q_CO2_DF,2);
    E_reg_use(:,iu_dg)=sum(DG.*coef_Q_CO2_DG,2);
    E_reg_use(:,iu_di)=sum(DIloc.*coef_Q_CO2_DI,2);

endfunction

function Ener_reg_use = energie_usage(CI,Q,DF,DI,DG)
    //Consommation d'energie fossile par region et usage. Voir nb_use dans indexes.sce

    Ener_reg_use = zeros(reg,nb_use);

    for r=1:reg
        Ener_reg_use(r,1:sec) =sum(CI(1:4,:,r),1).*Q(r ,:);
        Ener_reg_use(r,indice_Et) =sum(CI(1:3,indice_Et,r),1).*Q(r,indice_Et)-Q(r,indice_Et);
    end

    Ener_reg_use(:,iu_df)=sum(DF(:,1:4),2);
    Ener_reg_use(:,iu_dg)=sum(DG(:,1:4),2);
    Ener_reg_use(:,iu_di)=sum(DI(:,1:4),2);

endfunction

function [y,Qloc,DFloc,DIloc,Imptemp,Exptemp] = economy(x);
    //economy, meant to be called by fsolve
    //si fsolve appelle cette fonction, il va juste garder x
    //les sorties supplementaire speuvent eventuellement etre exploitees par d'autres fonctions

    [Consoloc,Tautomobileloc,lambdaloc,muloc,ploc,wloc,Qloc,Rdisploc,TNMloc,wpEnerloc]=expand_equilibrium(x)


    for k=1:reg,
        if (Rdisploc(k)<=0) then Rdisploc(k)=0.00001; end
        if (Tautomobileloc(k)<=bnautomobile(k)) then Tautomobileloc(k)=bnautomobile(k)+0.0000001; end
        if (TNMloc(k)<=bnNM(k)) then TNMloc(k)=bnNM(k)+0.0000001; end
        for j=1:sec,
            if (Qloc(k,j)<=0) then Qloc(k,j)=0.000001; end
            if (wloc(k,j)<=0) then  wloc(k,j)=0.0000001; end
            if (ploc(k,j)<=0) then  ploc(k,j)=0.0000001; end
        end
        //pour les secteurs non transport:
        for j=[1,2,6,7]
            if (Consoloc(k,j)<=bn(k,j+5)) then  Consoloc(k,j)=bn(k,j+5)+0.000001; end
        end
        //pour l'air
        if (Consoloc(k,indice_air-5)<=0) then Consoloc(k,indice_air-5)=0+0.0000001; end
        // pour la mer  
        if (Consoloc(k,indice_mer-5)<=bn(k,indice_mer)) then Consoloc(k,indice_mer-5)=bn(k,indice_mer)+0.000001; end
        //pour OT
        if (Consoloc(k,indice_OT-5)<=bnOT(k)) then Consoloc(k,indice_OT-5)=bnOT(k)+0.000001; end 
    end
    // prix mondiaux energie
    for j=1:nbsecteurenergie,
        if (wpEnerloc(j)<=0) then wpEnerloc(j)=0.0000001;end
    end
    //
    DFloc=DFinduite(Consoloc,Tautomobileloc);
    zloc=ones(reg,1);
    zloc=1-(sum(A.*l.*Qloc,"c")./L);
    numloc=ploc(1,indice_composite)*ones(reg,sec);
    //numloc=ploc(:,indice_composite)*ones(1,sec);
    wploc=zeros(1,sec);


    FCCtemp=aRD+bRD.*tanh(cRD.*(Qloc./Cap-1));
    FCCmarkup=ones(reg,sec);
    FCCmarkup=((markup_lim_oil-markupref)/(1-0.8).*(Qloc./Cap-0.8*ones(reg,sec))+markupref)./markup;
    FCCmarkup_oil=ones(reg,sec);
    FCCmarkup_oil(:,2)=FCCmarkup(:,2);
    charge=Qloc./Cap;
    //////////// secteurs non-energetiques ////////////////
    pArmDF
    pArmDG
    pArmDI
    pArmCI
    partDomDF
    partDomDG
    partDomDI
    partDomCI
    partImpDF
    partImpDG
    partImpDI
    partImpCI
    marketshare

    wploc(:,sec-nb_secteur_conso+1:sec)=sum((weight.^(ones(reg,1)*eta)).*((ploc(:,sec-nb_secteur_conso+1:sec).*(1+xtax(:,sec-nb_secteur_conso+1:sec))).^(1-ones(reg,1)*eta)),"r").^(ones(1,nb_secteur_conso)./(1-eta));
    wpTIloc=sum((weightTI.^(ones(reg,nb_trans)*etaTI).*(ploc(:,indice_transport_1:indice_transport_2).^(1-ones(reg,nb_trans)*etaTI))),'r').^(1 ./(1-etaTI));
    wpTIaggloc=sum(wpTIloc.*partTIref);

    pArmDF(:,sec-nb_secteur_conso+1:sec)=((bDF.^etaDF).*((ploc(:,sec-nb_secteur_conso+1:sec).*(1+taxDFdom(:,sec-nb_secteur_conso+1:sec))).^(1-etaDF))+((1-bDF).^etaDF).*((((ones(reg,1)*wploc(sec-nb_secteur_conso+1:sec)).*(1+mtax(:,sec-nb_secteur_conso+1:sec))+(ones(reg,nb_secteur_conso)*wpTIaggloc).*nit(:,sec-nb_secteur_conso+1:sec)).*(1+taxDFimp(:,sec-nb_secteur_conso+1:sec))).^(1-etaDF))).^(ones(reg,nb_secteur_conso)./(1-etaDF));
    pArmDG(:,sec-nb_secteur_conso+1:sec)=((bDG.^etaDG).*((ploc(:,sec-nb_secteur_conso+1:sec).*(1+taxDGdom(:,sec-nb_secteur_conso+1:sec))).^(1-etaDG))+((1-bDG).^etaDG).*((((ones(reg,1)*wploc(sec-nb_secteur_conso+1:sec)).*(1+mtax(:,sec-nb_secteur_conso+1:sec))+(ones(reg,nb_secteur_conso)*wpTIaggloc).*nit(:,sec-nb_secteur_conso+1:sec)).*(1+taxDGimp(:,sec-nb_secteur_conso+1:sec))).^(1-etaDG))).^(ones(reg,nb_secteur_conso)./(1-etaDG));
    pArmDI(:,sec-nb_secteur_conso+1:sec)=((bDI.^etaDI).*((ploc(:,sec-nb_secteur_conso+1:sec).*(1+taxDIdom(:,sec-nb_secteur_conso+1:sec))).^(1-etaDI))+((1-bDI).^etaDI).*((((ones(reg,1)*wploc(sec-nb_secteur_conso+1:sec)).*(1+mtax(:,sec-nb_secteur_conso+1:sec))+(ones(reg,nb_secteur_conso)*wpTIaggloc).*nit(:,sec-nb_secteur_conso+1:sec)).*(1+taxDIimp(:,sec-nb_secteur_conso+1:sec))).^(1-etaDI))).^(ones(reg,nb_secteur_conso)./(1-etaDI));
    partDomDF(:,sec-nb_secteur_conso+1:sec)=(bDF.^etaDF).*((pArmDF(:,sec-nb_secteur_conso+1:sec)./(ploc(:,sec-nb_secteur_conso+1:sec).*(1+taxDFdom(:,sec-nb_secteur_conso+1:sec)))).^etaDF);
    partImpDF(:,sec-nb_secteur_conso+1:sec)=((1-bDF).^etaDF).*((pArmDF(:,sec-nb_secteur_conso+1:sec)./(((ones(reg,1)*wploc(sec-nb_secteur_conso+1:sec)).*(1+mtax(:,sec-nb_secteur_conso+1:sec))+(ones(reg,nb_secteur_conso)*wpTIaggloc).*nit(:,sec-nb_secteur_conso+1:sec)).*(1+taxDFimp(:,sec-nb_secteur_conso+1:sec)))).^etaDF);
    partDomDG(:,sec-nb_secteur_conso+1:sec)=(bDG.^etaDG).*((pArmDG(:,sec-nb_secteur_conso+1:sec)./(ploc(:,sec-nb_secteur_conso+1:sec).*(1+taxDGdom(:,sec-nb_secteur_conso+1:sec)))).^etaDG);
    partImpDG(:,sec-nb_secteur_conso+1:sec)=((1-bDG).^etaDG).*((pArmDG(:,sec-nb_secteur_conso+1:sec)./(((ones(reg,1)*wploc(sec-nb_secteur_conso+1:sec)).*(1+mtax(:,sec-nb_secteur_conso+1:sec))+(ones(reg,nb_secteur_conso)*wpTIaggloc).*nit(:,sec-nb_secteur_conso+1:sec)).*(1+taxDGimp(:,sec-nb_secteur_conso+1:sec)))).^etaDG);
    partDomDI(:,sec-nb_secteur_conso+1:sec)=(bDI.^etaDI).*((pArmDI(:,sec-nb_secteur_conso+1:sec)./(ploc(:,sec-nb_secteur_conso+1:sec).*(1+taxDIdom(:,sec-nb_secteur_conso+1:sec)))).^etaDI);
    partImpDI(:,sec-nb_secteur_conso+1:sec)=((1-bDI).^etaDI).*((pArmDI(:,sec-nb_secteur_conso+1:sec)./(((ones(reg,1)*wploc(sec-nb_secteur_conso+1:sec)).*(1+mtax(:,sec-nb_secteur_conso+1:sec))+(ones(reg,nb_secteur_conso)*wpTIaggloc).*nit(:,sec-nb_secteur_conso+1:sec)).*(1+taxDIimp(:,sec-nb_secteur_conso+1:sec)))).^etaDI);

    for k=1:reg,
        pArmCI(sec-nb_secteur_conso+1:sec,:,k)=((bCI(:,:,k).^etaCI(:,:,k)).*(((ploc(k,sec-nb_secteur_conso+1:sec)'*ones(1,sec)).*(1+taxCIdom(sec-nb_secteur_conso+1:sec,:,k))).^(1-etaCI(:,:,k)))+((1-bCI(:,:,k)).^etaCI(:,:,k)).*((((wploc(sec-nb_secteur_conso+1:sec).*(1+mtax(k,sec-nb_secteur_conso+1:sec))+nit(k,sec-nb_secteur_conso+1:sec).*wpTIaggloc)'*ones(1,sec)).*(1+taxCIimp(sec-nb_secteur_conso+1:sec,:,k))).^(1-etaCI(:,:,k)))).^(ones(nb_secteur_conso,sec)./(1-etaCI(:,:,k)));
        partDomCI(sec-nb_secteur_conso+1:sec,:,k)=(bCI(:,:,k).^etaCI(:,:,k)).*((pArmCI(sec-nb_secteur_conso+1:sec,:,k)./((ploc(k,sec-nb_secteur_conso+1:sec)'*ones(1,sec)).*(1+taxCIdom(sec-nb_secteur_conso+1:sec,:,k)))).^etaCI(:,:,k));
        partImpCI(sec-nb_secteur_conso+1:sec,:,k)=((1-bCI(:,:,k)).^etaCI(:,:,k)).*((pArmCI(sec-nb_secteur_conso+1:sec,:,k)./(((wploc(sec-nb_secteur_conso+1:sec).*(1+mtax(k,sec-nb_secteur_conso+1:sec))+nit(k,sec-nb_secteur_conso+1:sec).*wpTIaggloc)'*ones(1,sec)).*(1+taxCIimp(sec-nb_secteur_conso+1:sec,:,k)))).^etaCI(:,:,k));
    end


    marketshare(:,sec-nb_secteur_conso+1:sec) = (weight.^(ones(reg,1)*eta)).*(((ploc(:,sec-nb_secteur_conso+1:sec).*(1+xtax(:,sec-nb_secteur_conso+1:sec))).^(ones(reg,1)*(1-eta)))./(ones(reg,1)*sum((weight.^(ones(reg,1)*eta)).*((ploc(:,sec-nb_secteur_conso+1:sec).*(1+xtax(:,sec-nb_secteur_conso+1:sec))).^(1-ones(reg,1)*eta)),"r"))).^(ones(reg,1)*(eta./(eta-1)));
    marketshareTI = (weightTI.^(ones(reg,nb_trans)*etaTI)).*((ploc(:,indice_transport_1:indice_transport_2).^(1-ones(reg,nb_trans)*etaTI))./(ones(reg,1)*sum((weightTI.^(ones(reg,nb_trans)*etaTI)).*(ploc(:,indice_transport_1:indice_transport_2).^(1-ones(reg,nb_trans)*etaTI)),"r"))).^(ones(reg,nb_trans)*(etaTI./(etaTI-1)));

    //////////// secteurs énergétiques /////////////////////////////////////

    partDomDF(:,1:nbsecteurenergie)=((ploc(:,1:nbsecteurenergie).*(1+taxDFdom(:,1:nbsecteurenergie)))+itgbl_cost_DFdom.*ploc(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDF./(((ploc(:,1:nbsecteurenergie).*(1+taxDFdom(:,1:nbsecteurenergie)))+itgbl_cost_DFdom.*ploc(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDF+(((ones(reg,1)*wpEnerloc).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIaggloc).*nit(:,1:nbsecteurenergie)).*(1+taxDFimp(:,1:nbsecteurenergie))+itgbl_cost_DFimp.*(ones(reg,1)*(wpEnerloc./wpEnerref))).^alpha_partDF);
    partDomDG(:,1:nbsecteurenergie)=((ploc(:,1:nbsecteurenergie).*(1+taxDGdom(:,1:nbsecteurenergie)))+itgbl_cost_DGdom.*ploc(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDG./(((ploc(:,1:nbsecteurenergie).*(1+taxDGdom(:,1:nbsecteurenergie)))+itgbl_cost_DGdom.*ploc(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDG+(((ones(reg,1)*wpEnerloc).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIaggloc).*nit(:,1:nbsecteurenergie)).*(1+taxDGimp(:,1:nbsecteurenergie))+itgbl_cost_DGimp.*(ones(reg,1)*(wpEnerloc./wpEnerref))).^alpha_partDG);
    partDomDI(:,1:nbsecteurenergie)=((ploc(:,1:nbsecteurenergie).*(1+taxDIdom(:,1:nbsecteurenergie)))+itgbl_cost_DIdom.*ploc(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDI./(((ploc(:,1:nbsecteurenergie).*(1+taxDIdom(:,1:nbsecteurenergie)))+itgbl_cost_DIdom.*ploc(:,1:nbsecteurenergie)./pref(:,1:nbsecteurenergie)).^alpha_partDI+(((ones(reg,1)*wpEnerloc).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIaggloc).*nit(:,1:nbsecteurenergie)).*(1+taxDIimp(:,1:nbsecteurenergie))+itgbl_cost_DIimp.*(ones(reg,1)*(wpEnerloc./wpEnerref))).^alpha_partDI);

    partDomDF(:,indice_elec)=partDomDFref(:,indice_elec);
    partDomDG(:,indice_elec)=partDomDGref(:,indice_elec);
    partDomDI(:,indice_elec)=partDomDIref(:,indice_elec);
    // partDomDF(:,indice_Et)=partDomDFref(:,indice_Et);
    // partDomDG(:,indice_Et)=partDomDGref(:,indice_Et);
    // partDomDI(:,indice_Et)=partDomDIref(:,indice_Et);

    //cas particulier de l'oil: on empeche les régions qui ont un taux de charge trop important de consommer le pétrole produit domestiquement
    mult_oil=max(0.000001,a4_mult_oil.*min(charge(:,indice_oil),0.999).^4+ a3_mult_oil.*min(charge(:,indice_oil),0.999).^3 +a2_mult_oil.*min(charge(:,indice_oil),0.999).^2+ a1_mult_oil.*min(charge(:,indice_oil),0.999)+a0_mult_oil);
    // for k=1:reg
    // if charge(k,indice_oil)>1 then mult_oil(k)=0; end
    // end

    mult_gaz=max(0.000001,a4_mult_gaz.*min(charge(:,indice_gaz),0.999).^4+ a3_mult_gaz.*min(charge(:,indice_gaz),0.999).^3 +a2_mult_gaz.*min(charge(:,indice_gaz),0.999).^2+ a1_mult_gaz.*min(charge(:,indice_gaz),0.999)+a0_mult_gaz);
    // for k=1:reg
    // if charge(k,indice_gaz)>1 then mult_gaz(k)=0; end
    // end

    mult_coal=max(0.000001,a4_mult_coal.*min(charge(:,indice_coal),0.999).^4+ a3_mult_coal.*min(charge(:,indice_coal),0.999).^3 +a2_mult_coal.*min(charge(:,indice_coal),0.999).^2+ a1_mult_coal.*min(charge(:,indice_coal),0.999)+a0_mult_coal);
    // for k=1:reg
    // if charge(k,indice_coal)>1 then mult_coal(k)=0; end
    // end

    for k=1:reg
        if mult_coal(k)<1 then 
            partDomDF(k,indice_coal)=partDomDF(k,indice_coal).*mult_coal(k);
            partDomDG(k,indice_coal)=partDomDG(k,indice_coal).*mult_coal(k);
            partDomDI(k,indice_coal)=partDomDI(k,indice_coal).*mult_coal(k);
        end
    end

    for k=1:reg
        if mult_coal(k)<0 then 
            partDomDF(k,indice_coal)=0;
            partDomDG(k,indice_coal)=0;
            partDomDI(k,indice_coal)=0;
        end
    end

    for k=1:reg
        if mult_gaz(k)<1 then 
            partDomDF(k,indice_gaz)=partDomDF(k,indice_gaz).*mult_gaz(k);
            partDomDG(k,indice_gaz)=partDomDG(k,indice_gaz).*mult_gaz(k);
            partDomDI(k,indice_gaz)=partDomDI(k,indice_gaz).*mult_gaz(k);
        end
    end

    for k=1:reg
        if mult_gaz(k)<0 then 
            partDomDF(k,indice_gaz)=0;
            partDomDG(k,indice_gaz)=0;
            partDomDI(k,indice_gaz)=0;
        end
    end

    for k=1:reg
        if mult_oil(k)<1 then 
            partDomDF(k,indice_oil)=partDomDF(k,indice_oil).*mult_oil(k);
            partDomDG(k,indice_oil)=partDomDG(k,indice_oil).*mult_oil(k);
            partDomDI(k,indice_oil)=partDomDI(k,indice_oil).*mult_oil(k);
        end
    end

    for k=1:reg
        if mult_oil(k)<0 then 
            partDomDF(k,indice_oil)=0;
            partDomDG(k,indice_oil)=0;
            partDomDI(k,indice_oil)=0;
        end
    end

    partDomDF(:,1:nbsecteurenergie)=partDomDF(:,1:nbsecteurenergie)*inertia_share+partDomDF_stock(:,1:nbsecteurenergie)*(1-inertia_share);
    partDomDG(:,1:nbsecteurenergie)=partDomDG(:,1:nbsecteurenergie)*inertia_share+partDomDG_stock(:,1:nbsecteurenergie)*(1-inertia_share);
    partDomDI(:,1:nbsecteurenergie)=partDomDI(:,1:nbsecteurenergie)*inertia_share+partDomDI_stock(:,1:nbsecteurenergie)*(1-inertia_share);

    partImpDF(:,1:nbsecteurenergie)=1-partDomDF(:,1:nbsecteurenergie);
    partImpDG(:,1:nbsecteurenergie)=1-partDomDG(:,1:nbsecteurenergie);
    partImpDI(:,1:nbsecteurenergie)=1-partDomDI(:,1:nbsecteurenergie);

    for k=1:reg,
        partDomCI(1:nbsecteurenergie,:,k)=(((ploc(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k)))+itgbl_cost_CIdom(:,:,k).*((ploc(k,1:nbsecteurenergie)./pref(k,1:nbsecteurenergie))'*ones(1,sec))).^alpha_partCI(:,:,k)./((((ploc(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k)))+itgbl_cost_CIdom(:,:,k).*((ploc(k,1:nbsecteurenergie)./pref(k,1:nbsecteurenergie))'*ones(1,sec))).^alpha_partCI(:,:,k)+((((wpEnerloc(1:nbsecteurenergie).*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIaggloc)'*ones(1,sec)).*(1+taxCIimp(1:nbsecteurenergie,:,k)))+itgbl_cost_CIimp(:,:,k).*((wpEnerloc./wpEnerref)'*ones(1,sec))).^alpha_partCI(:,:,k));
        partDomCI(indice_elec,:,k)=partDomCIref(indice_elec,:,k);
        partDomCI(indice_Et,:,k)=partDomCIref(indice_Et,:,k);

        if mult_oil(k)<1 then
            for j=1:sec
                partDomCI(indice_oil,j,k)=mult_oil(k)*partDomCI(indice_oil,j,k);
            end
        end
        if mult_oil(k)<0 then
            for j=1:sec
                partDomCI(indice_oil,j,k)=0;
            end
        end

        if mult_gaz(k)<1 then
            for j=1:sec
                partDomCI(indice_gaz,j,k)=mult_gaz(k)*partDomCI(indice_gaz,j,k);
            end
        end
        if mult_gaz(k)<0 then
            for j=1:sec
                partDomCI(indice_gaz,j,k)=0;
            end
        end

        if mult_coal(k)<1 then
            for j=1:sec
                partDomCI(indice_coal,j,k)=mult_coal(k)*partDomCI(indice_coal,j,k);
            end
        end
        if mult_coal(k)<0 then
            for j=1:sec
                partDomCI(indice_coal,j,k)=0;
            end
        end

        partDomCI(1:nbsecteurenergie,:,k)=partDomCI(1:nbsecteurenergie,:,k)*inertia_share+partDomCI_stock(1:nbsecteurenergie,:,k)*(1-inertia_share);
        partImpCI(1:nbsecteurenergie,:,k)=1-partDomCI(1:nbsecteurenergie,:,k);
    end

    marketshare(:,1:nbsecteurenergie)=bmarketshareener.*((ploc(:,1:nbsecteurenergie).*(1+xtax(:,1:nbsecteurenergie))./(p_stock(:,1:nbsecteurenergie).*(1+xtaxref(:,1:nbsecteurenergie)))).^(ones(reg,1)*etamarketshareener))./(ones(reg,1)*sum(bmarketshareener.*((ploc(:,1:nbsecteurenergie).*(1+xtax(:,1:nbsecteurenergie))./(p_stock(:,1:nbsecteurenergie).*(1+xtaxref(:,1:nbsecteurenergie)))).^(ones(reg,1)*etamarketshareener)),'r'));
    //correction pour l'oil: on empeche les pays au taux de charge important  d'exporter

    for k=1:reg
        if mult_gaz(k)<1 then 
            marketshare(k,indice_gaz)=marketshare(k,indice_gaz).*mult_gaz(k);
        end
    end
    for k=1:reg
        if marketshare(k,indice_gaz)<0.00000001 then 
            marketshare(k,indice_gaz)=0.00000001;
        end
    end
    marketshare(:,indice_gaz)=marketshare(:,indice_gaz)/(sum(marketshare(:,indice_gaz),'r'));

    for k=1:reg
        if mult_oil(k)<1 then 
            marketshare(k,indice_oil)=marketshare(k,indice_oil).*mult_oil(k);
        end
    end
    for k=1:reg
        if marketshare(k,indice_oil)<0.00000001 then 
            marketshare(k,indice_oil)=0.00000001;
        end
    end
    marketshare(:,indice_oil)=marketshare(:,indice_oil)/(sum(marketshare(:,indice_oil),'r'));

    for k=1:reg
        if mult_coal(k)<1 then 
            marketshare(k,indice_coal)=marketshare(k,indice_coal).*mult_coal(k);
        end
    end
    for k=1:reg
        if marketshare(k,indice_coal)<0.00000001 then 
            marketshare(k,indice_coal)=0.00000001;
        end
    end
    marketshare(:,indice_coal)=marketshare(:,indice_coal)/(sum(marketshare(:,indice_coal),'r'));

    wploc(:,1:nbsecteurenergie)=wpEnerloc;

    pArmDF(:,1:nbsecteurenergie)=(ploc(:,1:nbsecteurenergie).*(1+taxDFdom(:,1:nbsecteurenergie))).*(1-partImpDF(:,1:nbsecteurenergie))+(((ones(reg,1)*wpEnerloc).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIaggloc).*nit(:,1:nbsecteurenergie)).*(1+taxDFimp(:,1:nbsecteurenergie))).*partImpDF(:,1:nbsecteurenergie)+taxCO2_DF(:,1:nbsecteurenergie).*coef_Q_CO2_DF(:,1:nbsecteurenergie).*numloc(:,1:nbsecteurenergie);
    pArmDG(:,1:nbsecteurenergie)=(ploc(:,1:nbsecteurenergie).*(1+taxDGdom(:,1:nbsecteurenergie))).*(1-partImpDG(:,1:nbsecteurenergie))+(((ones(reg,1)*wpEnerloc).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIaggloc).*nit(:,1:nbsecteurenergie)).*(1+taxDGimp(:,1:nbsecteurenergie))).*partImpDG(:,1:nbsecteurenergie)+taxCO2_DG(:,1:nbsecteurenergie).*coef_Q_CO2_DG(:,1:nbsecteurenergie).*numloc(:,1:nbsecteurenergie);
    pArmDI(:,1:nbsecteurenergie)=(ploc(:,1:nbsecteurenergie).*(1+taxDIdom(:,1:nbsecteurenergie))).*(1-partImpDI(:,1:nbsecteurenergie))+(((ones(reg,1)*wpEnerloc).*(1+mtax(:,1:nbsecteurenergie))+(ones(reg,nbsecteurenergie)*wpTIaggloc).*nit(:,1:nbsecteurenergie)).*(1+taxDIimp(:,1:nbsecteurenergie))).*partImpDI(:,1:nbsecteurenergie)+taxCO2_DI(:,1:nbsecteurenergie).*coef_Q_CO2_DI(:,1:nbsecteurenergie).*numloc(:,1:nbsecteurenergie);
    for k=1:reg,
        pArmCI(1:nbsecteurenergie,:,k)=((ploc(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k))).*(1-partImpCI(1:nbsecteurenergie,:,k))+(((wpEnerloc.*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIaggloc)'*ones(1,sec)).*(1+taxCIimp(1:nbsecteurenergie,:,k))).*partImpCI(1:nbsecteurenergie,:,k)+(taxCO2_CI(1:nbsecteurenergie,:,k).*coef_Q_CO2_CI(1:nbsecteurenergie,:,k)).*(numloc(k,1:nbsecteurenergie)'*ones(1,sec));
    end

    pArmDF=pArmDF.*(1+Ttax);

    /////////// indice de prix des consommations des menages  /////////////////

    pindtemp=(sum(pArmDF.*DFloc,'c')./sum(pArmDFref.*DFloc,'c').*sum(pArmDF.*DFref,'c')./sum(pArmDFref.*DFref,'c')).^(1/2);

    GRBtemp = Rdisploc.*(1-IR).*(1-ptc)+(1-div).*sum(ploc.*Qloc.*FCCmarkup_oil.*markup.*(FCCtemp.*energ_sec+non_energ_sec),'c');
    NRBtemp=(GRBtemp.*(1-partExpK)+partImpK.*(ones(reg,1)*sum(GRBtemp.*partExpK)));
    DIloc=DIinfra+DIprodref.*(((NRBtemp-sum(DIinfra.*pArmDI,'c'))./sum(DIprodref.*pArmDI,'c'))*ones(1,sec));

    /////////// calcul intermediaire des exportations, importations ///////////
    QCdomtemp=ones(reg,sec);
    QCdomtemp=[(A(1,:).*Qloc(1,:))*((CI(:,:,1).*partDomCI(:,:,1))');
    (A(2,:).*Qloc(2,:))*((CI(:,:,2).*partDomCI(:,:,2))');
    (A(3,:).*Qloc(3,:))*((CI(:,:,3).*partDomCI(:,:,3))');
    (A(4,:).*Qloc(4,:))*((CI(:,:,4).*partDomCI(:,:,4))');
    (A(5,:).*Qloc(5,:))*((CI(:,:,5).*partDomCI(:,:,5))');
    (A(6,:).*Qloc(6,:))*((CI(:,:,6).*partDomCI(:,:,6))');
    (A(7,:).*Qloc(7,:))*((CI(:,:,7).*partDomCI(:,:,7))');
    (A(8,:).*Qloc(8,:))*((CI(:,:,8).*partDomCI(:,:,8))');
    (A(9,:).*Qloc(9,:))*((CI(:,:,9).*partDomCI(:,:,9))');
    (A(10,:).*Qloc(10,:))*((CI(:,:,10).*partDomCI(:,:,10))');
    (A(11,:).*Qloc(11,:))*((CI(:,:,11).*partDomCI(:,:,11))');
    (A(12,:).*Qloc(12,:))*((CI(:,:,12).*partDomCI(:,:,12))')]+DFloc.*partDomDF+DG.*partDomDG+DIloc.*partDomDI;

    Imptemp=ones(reg,sec);
    Imptemp=[(A(1,:).*Qloc(1,:))*((CI(:,:,1).*(partImpCI(:,:,1)))');
    (A(2,:).*Qloc(2,:))*((CI(:,:,2).*(partImpCI(:,:,2)))');
    (A(3,:).*Qloc(3,:))*((CI(:,:,3).*(partImpCI(:,:,3)))');
    (A(4,:).*Qloc(4,:))*((CI(:,:,4).*(partImpCI(:,:,4)))');
    (A(5,:).*Qloc(5,:))*((CI(:,:,5).*(partImpCI(:,:,5)))');
    (A(6,:).*Qloc(6,:))*((CI(:,:,6).*(partImpCI(:,:,6)))');
    (A(7,:).*Qloc(7,:))*((CI(:,:,7).*(partImpCI(:,:,7)))');
    (A(8,:).*Qloc(8,:))*((CI(:,:,8).*(partImpCI(:,:,8)))');
    (A(9,:).*Qloc(9,:))*((CI(:,:,9).*(partImpCI(:,:,9)))');
    (A(10,:).*Qloc(10,:))*((CI(:,:,10).*(partImpCI(:,:,10)))');
    (A(11,:).*Qloc(11,:))*((CI(:,:,11).*(partImpCI(:,:,11)))');
    (A(12,:).*Qloc(12,:))*((CI(:,:,12).*(partImpCI(:,:,12)))')]+DFloc.*(partImpDF)+DG.*(partImpDG)+DIloc.*(partImpDI);

    Exptemp=marketshare.*(ones(reg,1)*sum(Imptemp,"r"));

    ExpTItemp=zeros(reg,sec);
    ExpTItemp(:,indice_transport_1:indice_transport_2)=marketshareTI.*(ones(reg,1)*(sum(Imptemp.*nit)*partTIref));

    taxCItemp=[
    sum((ploc(1,:)'*ones(1,sec)).*taxCIdom(:,:,1).*partDomCI(:,:,1).*CI(:,:,1).*(ones(sec,1)*(Qloc(1,:).*A(1,:))))+sum(((wploc.*(1+mtax(1,:))+nit(1,:).*wpTIaggloc)'*ones(1,sec)).*taxCIimp(:,:,1).*(partImpCI(:,:,1)).*CI(:,:,1).*(ones(sec,1)*(Qloc(1,:).*A(1,:))));
    sum((ploc(2,:)'*ones(1,sec)).*taxCIdom(:,:,2).*partDomCI(:,:,2).*CI(:,:,2).*(ones(sec,1)*(Qloc(2,:).*A(2,:))))+sum(((wploc.*(1+mtax(2,:))+nit(2,:).*wpTIaggloc)'*ones(1,sec)).*taxCIimp(:,:,2).*(partImpCI(:,:,2)).*CI(:,:,2).*(ones(sec,1)*(Qloc(2,:).*A(2,:))));
    sum((ploc(3,:)'*ones(1,sec)).*taxCIdom(:,:,3).*partDomCI(:,:,3).*CI(:,:,3).*(ones(sec,1)*(Qloc(3,:).*A(3,:))))+sum(((wploc.*(1+mtax(3,:))+nit(3,:).*wpTIaggloc)'*ones(1,sec)).*taxCIimp(:,:,3).*(partImpCI(:,:,3)).*CI(:,:,3).*(ones(sec,1)*(Qloc(3,:).*A(3,:))));
    sum((ploc(4,:)'*ones(1,sec)).*taxCIdom(:,:,4).*partDomCI(:,:,4).*CI(:,:,4).*(ones(sec,1)*(Qloc(4,:).*A(4,:))))+sum(((wploc.*(1+mtax(4,:))+nit(4,:).*wpTIaggloc)'*ones(1,sec)).*taxCIimp(:,:,4).*(partImpCI(:,:,4)).*CI(:,:,4).*(ones(sec,1)*(Qloc(4,:).*A(4,:))));
    sum((ploc(5,:)'*ones(1,sec)).*taxCIdom(:,:,5).*partDomCI(:,:,5).*CI(:,:,5).*(ones(sec,1)*(Qloc(5,:).*A(5,:))))+sum(((wploc.*(1+mtax(5,:))+nit(5,:).*wpTIaggloc)'*ones(1,sec)).*taxCIimp(:,:,5).*(partImpCI(:,:,5)).*CI(:,:,5).*(ones(sec,1)*(Qloc(5,:).*A(5,:))));
    sum((ploc(6,:)'*ones(1,sec)).*taxCIdom(:,:,6).*partDomCI(:,:,6).*CI(:,:,6).*(ones(sec,1)*(Qloc(6,:).*A(6,:))))+sum(((wploc.*(1+mtax(6,:))+nit(6,:).*wpTIaggloc)'*ones(1,sec)).*taxCIimp(:,:,6).*(partImpCI(:,:,6)).*CI(:,:,6).*(ones(sec,1)*(Qloc(6,:).*A(6,:))));
    sum((ploc(7,:)'*ones(1,sec)).*taxCIdom(:,:,7).*partDomCI(:,:,7).*CI(:,:,7).*(ones(sec,1)*(Qloc(7,:).*A(7,:))))+sum(((wploc.*(1+mtax(7,:))+nit(7,:).*wpTIaggloc)'*ones(1,sec)).*taxCIimp(:,:,7).*(partImpCI(:,:,7)).*CI(:,:,7).*(ones(sec,1)*(Qloc(7,:).*A(7,:))));
    sum((ploc(8,:)'*ones(1,sec)).*taxCIdom(:,:,8).*partDomCI(:,:,8).*CI(:,:,8).*(ones(sec,1)*(Qloc(8,:).*A(8,:))))+sum(((wploc.*(1+mtax(8,:))+nit(8,:).*wpTIaggloc)'*ones(1,sec)).*taxCIimp(:,:,8).*(partImpCI(:,:,8)).*CI(:,:,8).*(ones(sec,1)*(Qloc(8,:).*A(8,:))));
    sum((ploc(9,:)'*ones(1,sec)).*taxCIdom(:,:,9).*partDomCI(:,:,9).*CI(:,:,9).*(ones(sec,1)*(Qloc(9,:).*A(9,:))))+sum(((wploc.*(1+mtax(9,:))+nit(9,:).*wpTIaggloc)'*ones(1,sec)).*taxCIimp(:,:,9).*(partImpCI(:,:,9)).*CI(:,:,9).*(ones(sec,1)*(Qloc(9,:).*A(9,:))));
    sum((ploc(10,:)'*ones(1,sec)).*taxCIdom(:,:,10).*partDomCI(:,:,10).*CI(:,:,10).*(ones(sec,1)*(Qloc(10,:).*A(10,:))))+sum(((wploc.*(1+mtax(10,:))+nit(10,:).*wpTIaggloc)'*ones(1,sec)).*taxCIimp(:,:,10).*(partImpCI(:,:,10)).*CI(:,:,10).*(ones(sec,1)*(Qloc(10,:).*A(10,:))));
    sum((ploc(11,:)'*ones(1,sec)).*taxCIdom(:,:,11).*partDomCI(:,:,11).*CI(:,:,11).*(ones(sec,1)*(Qloc(11,:).*A(11,:))))+sum(((wploc.*(1+mtax(11,:))+nit(11,:).*wpTIaggloc)'*ones(1,sec)).*taxCIimp(:,:,11).*(partImpCI(:,:,11)).*CI(:,:,11).*(ones(sec,1)*(Qloc(11,:).*A(11,:))));
    sum((ploc(12,:)'*ones(1,sec)).*taxCIdom(:,:,12).*partDomCI(:,:,12).*CI(:,:,12).*(ones(sec,1)*(Qloc(12,:).*A(12,:))))+sum(((wploc.*(1+mtax(12,:))+nit(12,:).*wpTIaggloc)'*ones(1,sec)).*taxCIimp(:,:,12).*(partImpCI(:,:,12)).*CI(:,:,12).*(ones(sec,1)*(Qloc(12,:).*A(12,:))))];

    TAXCO2temp_dom=[(A(1,:).*Qloc(1,:))*((CI(:,:,1).*partDomCI(:,:,1).*taxCO2_CI(:,:,1).*coef_Q_CO2_CI(:,:,1).*(numloc(1,1)*ones(sec,sec)))');
    (A(2,:).*Qloc(2,:))*((CI(:,:,2).*partDomCI(:,:,2).*taxCO2_CI(:,:,2).*coef_Q_CO2_CI(:,:,2).*(numloc(2,1)*ones(sec,sec)))');
    (A(3,:).*Qloc(3,:))*((CI(:,:,3).*partDomCI(:,:,3).*taxCO2_CI(:,:,3).*coef_Q_CO2_CI(:,:,3).*(numloc(3,1)*ones(sec,sec)))');
    (A(4,:).*Qloc(4,:))*((CI(:,:,4).*partDomCI(:,:,4).*taxCO2_CI(:,:,4).*coef_Q_CO2_CI(:,:,4).*(numloc(4,1)*ones(sec,sec)))');
    (A(5,:).*Qloc(5,:))*((CI(:,:,5).*partDomCI(:,:,5).*taxCO2_CI(:,:,5).*coef_Q_CO2_CI(:,:,5).*(numloc(5,1)*ones(sec,sec)))');
    (A(6,:).*Qloc(6,:))*((CI(:,:,6).*partDomCI(:,:,6).*taxCO2_CI(:,:,6).*coef_Q_CO2_CI(:,:,6).*(numloc(6,1)*ones(sec,sec)))');
    (A(7,:).*Qloc(7,:))*((CI(:,:,7).*partDomCI(:,:,7).*taxCO2_CI(:,:,7).*coef_Q_CO2_CI(:,:,7).*(numloc(7,1)*ones(sec,sec)))');
    (A(8,:).*Qloc(8,:))*((CI(:,:,8).*partDomCI(:,:,8).*taxCO2_CI(:,:,8).*coef_Q_CO2_CI(:,:,8).*(numloc(8,1)*ones(sec,sec)))');
    (A(9,:).*Qloc(9,:))*((CI(:,:,9).*partDomCI(:,:,9).*taxCO2_CI(:,:,9).*coef_Q_CO2_CI(:,:,9).*(numloc(9,1)*ones(sec,sec)))');
    (A(10,:).*Qloc(10,:))*((CI(:,:,10).*partDomCI(:,:,10).*taxCO2_CI(:,:,10).*coef_Q_CO2_CI(:,:,10).*(numloc(10,1)*ones(sec,sec)))');
    (A(11,:).*Qloc(11,:))*((CI(:,:,11).*partDomCI(:,:,11).*taxCO2_CI(:,:,11).*coef_Q_CO2_CI(:,:,11).*(numloc(11,1)*ones(sec,sec)))');
    (A(12,:).*Qloc(12,:))*((CI(:,:,12).*partDomCI(:,:,12).*taxCO2_CI(:,:,12).*coef_Q_CO2_CI(:,:,12).*(numloc(12,1)*ones(sec,sec)))')]+DFloc.*partDomDF.*taxCO2_DF.*coef_Q_CO2_DF.*numloc+DG.*partDomDG.*taxCO2_DG.*coef_Q_CO2_DG.*numloc+DIloc.*partDomDI.*taxCO2_DI.*coef_Q_CO2_DI.*numloc;

    TAXCO2temp_imp=[(A(1,:).*Qloc(1,:))*((CI(:,:,1).*partImpCI(:,:,1).*taxCO2_CI(:,:,1).*coef_Q_CO2_CI(:,:,1).*(numloc(1,1)*ones(sec,sec)))');
    (A(2,:).*Qloc(2,:))*((CI(:,:,2).*partImpCI(:,:,2).*taxCO2_CI(:,:,2).*coef_Q_CO2_CI(:,:,2).*(numloc(2,1)*ones(sec,sec)))');
    (A(3,:).*Qloc(3,:))*((CI(:,:,3).*partImpCI(:,:,3).*taxCO2_CI(:,:,3).*coef_Q_CO2_CI(:,:,3).*(numloc(3,1)*ones(sec,sec)))');
    (A(4,:).*Qloc(4,:))*((CI(:,:,4).*partImpCI(:,:,4).*taxCO2_CI(:,:,4).*coef_Q_CO2_CI(:,:,4).*(numloc(4,1)*ones(sec,sec)))');
    (A(5,:).*Qloc(5,:))*((CI(:,:,5).*partImpCI(:,:,5).*taxCO2_CI(:,:,5).*coef_Q_CO2_CI(:,:,5).*(numloc(5,1)*ones(sec,sec)))');
    (A(6,:).*Qloc(6,:))*((CI(:,:,6).*partImpCI(:,:,6).*taxCO2_CI(:,:,6).*coef_Q_CO2_CI(:,:,6).*(numloc(6,1)*ones(sec,sec)))');
    (A(7,:).*Qloc(7,:))*((CI(:,:,7).*partImpCI(:,:,7).*taxCO2_CI(:,:,7).*coef_Q_CO2_CI(:,:,7).*(numloc(7,1)*ones(sec,sec)))');
    (A(8,:).*Qloc(8,:))*((CI(:,:,8).*partImpCI(:,:,8).*taxCO2_CI(:,:,8).*coef_Q_CO2_CI(:,:,8).*(numloc(8,1)*ones(sec,sec)))');
    (A(9,:).*Qloc(9,:))*((CI(:,:,9).*partImpCI(:,:,9).*taxCO2_CI(:,:,9).*coef_Q_CO2_CI(:,:,9).*(numloc(9,1)*ones(sec,sec)))');
    (A(10,:).*Qloc(10,:))*((CI(:,:,10).*partImpCI(:,:,10).*taxCO2_CI(:,:,10).*coef_Q_CO2_CI(:,:,10).*(numloc(10,1)*ones(sec,sec)))');
    (A(11,:).*Qloc(11,:))*((CI(:,:,11).*partImpCI(:,:,11).*taxCO2_CI(:,:,11).*coef_Q_CO2_CI(:,:,11).*(numloc(11,1)*ones(sec,sec)))');
    (A(12,:).*Qloc(12,:))*((CI(:,:,12).*partImpCI(:,:,12).*taxCO2_CI(:,:,12).*coef_Q_CO2_CI(:,:,12).*(numloc(12,1)*ones(sec,sec)))')]+DFloc.*partImpDF.*taxCO2_DF.*coef_Q_CO2_DF.*numloc+DG.*partImpDG.*taxCO2_DG.*coef_Q_CO2_DG.*numloc+DIloc.*partImpDI.*taxCO2_DI.*coef_Q_CO2_DI.*numloc;

    TAXCO2temp=sum(TAXCO2temp_imp+TAXCO2temp_dom,'c');
    //TAXCO2temp=sum(taxCO2.*numloc.*coef_Q_CO2.*(QCdomtemp+Imptemp),'c');

    sumtaxtemp=taxCItemp+TAXCO2temp+sum(Exptemp.*ploc.*xtax+...
    (ploc.*taxDFdom.*partDomDF+((ones(reg,1)*wploc).*(1+mtax)+(ones(reg,sec)*wpTIaggloc).*nit).*taxDFimp.*(partImpDF)).*DFloc+...
    (ploc.*taxDGdom.*partDomDG+((ones(reg,1)*wploc).*(1+mtax)+(ones(reg,sec)*wpTIaggloc).*nit).*taxDGimp.*(partImpDG)).*DG+...
    (ploc.*taxDIdom.*partDomDI+((ones(reg,1)*wploc).*(1+mtax)+(ones(reg,sec)*wpTIaggloc).*nit).*taxDIimp.*(partImpDI)).*DIloc+...
    (ones(reg,1)*wploc).*mtax.*Imptemp+...
    Qloc.*ploc.*qtax./(1+qtax)+...
    DFloc.*pArmDF.*Ttax./(1+Ttax)+...
    A.*Qloc.*wloc.*l.*sigma.*(energ_sec+FCCtemp.*non_energ_sec),"c");

    y=[ Utility(Consoloc,Tautomobileloc,TNMloc,lambdaloc,muloc),..
    Household_budget(Rdisploc,Consoloc,Tautomobileloc),..
    Time_budget(Consoloc,Tautomobileloc,TNMloc),..
    Sector_budget(ploc,wloc,Qloc),..
    Market_clear(Qloc),..
    Wages(wloc,Qloc,pindtemp),..
    Energy_world_prices(wpEnerloc,ploc),..
    State_budget(Rdisploc,wloc,Qloc),..
    ]';

    if norm(y)<sensibility
        y=zeros(y);
    end

endfunction

function y=economyX(x)
    //contraintes classiques de economy, plus contraintes sur les marches de carbone

    [taxCO2_DF, taxCO2_DG, taxCO2_DI, taxCO2_CI, taxMKT]=expand_tax(x,taxCO2_DF, taxCO2_DG, taxCO2_DI, taxCO2_CI, taxMKT)

    [yy,Qloc,DFloc,DIloc,Imptemp,Exptemp] = economy(x);
    //dans la fonction en C il faudra s'assurer que les variables Qloc, DFloc, TAXVALloc etc. ont une portee plus lointaine que economyC
    y = [yy; emissions_gap(Qloc,DFloc,DIloc,Imptemp,Exptemp,taxMKT)]

endfunction

function [Conso , Tautomobile, lambda , mu , p , w , Q , Rdisp , TNM , wpEner ]=expand_equilibrium(x)
    //Deconcatene la variable X  passee a la fonction economy (les variables d'etat de l'equilibre) pour lui redonner tout son sens
    //Cas classique sans contrainte carbone

    Conso      =matrix(x(1:reg*nb_secteur_conso),reg,nb_secteur_conso);
    Tautomobile= matrix        (x        (reg*nb_secteur_conso+1                         :reg*nb_secteur_conso+reg          )                 ,reg,1);
    lambda     =     matrix    (x        (reg*nb_secteur_conso+reg+1                 :reg*nb_secteur_conso+2*reg          )          ,reg,1);
    mu         =         matrix(x        (reg*nb_secteur_conso+2*reg+1           :reg*nb_secteur_conso+3*reg        )        ,reg,1);
    p          =matrix(x(reg*nb_secteur_conso+3*reg+1:reg*nb_secteur_conso+3*reg+reg*sec),reg,sec);
    w          =matrix(x(reg*nb_secteur_conso+3*reg+reg*sec+1:reg*nb_secteur_conso+3*reg+2*reg*sec),reg,sec);
    Q          =matrix(x(reg*nb_secteur_conso+3*reg+2*reg*sec+1:reg*nb_secteur_conso+3*reg+3*reg*sec),reg,sec);
    Rdisp      =matrix(x(reg*nb_secteur_conso+3*reg+3*reg*sec+1:reg*nb_secteur_conso+4*reg+3*reg*sec),reg,1);
    TNM        =        matrix (x        (reg*nb_secteur_conso+4*reg+3*reg*sec+1  :reg*nb_secteur_conso+5*reg+3*reg*sec)       ,reg,1);
    wpEner     =    matrix     (x        (reg*nb_secteur_conso+5*reg+3*reg*sec+1      :reg*nb_secteur_conso+5*reg+3*reg*sec+5)         ,1  ,5);

    //Non negativite des grandeurs physiques et de conso-basic_need
    for k=1:reg,
        if (Rdisp(k)<=0) then Rdisp(k)=0.00001; end
        if (Tautomobile(k)<=bnautomobile(k)) then Tautomobile(k)=bnautomobile(k)+0.0000001; end
        if (TNM(k)<=bnNM(k)) then TNM(k)=bnNM(k)+0.0000001; end
        for j=1:sec,
            if (Q(k,j)<=0) then Q(k,j)=0.000001; end
            if (w(k,j)<=0) then  w(k,j)=0.0000001; end
            if (p(k,j)<=0) then  p(k,j)=0.0000001; end
        end
        //pour les secteurs non transport:
        for j=[1,2,6,7]
            if (Conso(k,j)<=bn(k,j+5)) then  Conso(k,j)=bn(k,j+5)+0.000001; end
        end
        //pour l'air
        if (Conso(k,indice_air-5)<=0) then Conso(k,indice_air-5)=0+0.0000001; end
        // pour la mer  
        if (Conso(k,indice_mer-5)<=bn(k,indice_mer)) then Conso(k,indice_mer-5)=bn(k,indice_mer)+0.000001; end
        //pour OT
        if (Conso(k,indice_OT-5)<=bnOT(k)) then Conso(k,indice_OT-5)=bnOT(k)+0.000001; end 
    end
    if exo_pkmair_scenario >0
        Conso(:,indice_air-5) = DFair_exo;
    end 

    // prix mondiaux energie
    for j=1:nbsecteurenergie,
        if (wpEner(j)<=0) then wpEner(j)=0.0000001;end
    end

endfunction

function [taxCO2_DF, taxCO2_DG, taxCO2_DI, taxCO2_CI, taxMKT]=expand_tax(x,taxCO2_DF, taxCO2_DG, taxCO2_DI, taxCO2_CI, taxMKTin, varargin)

    // When taxes are exogenous, last values of x (chosen by fsolve) cannot move tax

    taxMKT = taxMKTin; // exogenously-set values (when is_taxexo_MKTparam = %t or unconstrained mkts)

    //cas d'une taxe calculee dans le static
    for m = find(areEmisConstparam(:) & ~is_taxexo_MKTparam(:))
        taxMKT(m) = get_taxes(x,m);
    end

    if  argn(2) > 6
      [ taxCO2_DF , taxCO2_DG , taxCO2_DI , taxCO2_CI , taxMKT ] = dispatchTax( taxCO2_DF , taxCO2_DG , taxCO2_DI , taxCO2_CI , taxMKT, varargin(1) );
    else
      [ taxCO2_DF , taxCO2_DG , taxCO2_DI , taxCO2_CI , taxMKT ] = dispatchTax( taxCO2_DF , taxCO2_DG , taxCO2_DI , taxCO2_CI , taxMKT );
    end

endfunction

function [ taxCO2_DF , taxCO2_DG , taxCO2_DI , taxCO2_CI , taxMKT ] = dispatchTax( taxCO2_DF , taxCO2_DG , taxCO2_DI , taxCO2_CI , taxMKT, varargin )

    if argn(2) > 5
        weight_regional_tax_expand = varargin(1);
    else
        weight_regional_tax_expand = ones(12,1);
    end


    for k=1:reg

        // on verifie dans quel marché se trouve chaque secteur...
        for i1=1:sec
            taxCO2_CI(:,i1,k)= weight_regional_tax_expand(k) .* taxMKT(whichMKT_reg_use(k,i1));
        end

        // ... et dans quel marché on comptabilise DI, DF, DG
        taxCO2_DF(k,:) = weight_regional_tax_expand(k) .* taxMKT(whichMKT_reg_use(k,iu_df));
        taxCO2_DG(k,:) = weight_regional_tax_expand(k) .* taxMKT(whichMKT_reg_use(k,iu_dg));
        taxCO2_DI(k,:) = weight_regional_tax_expand(k) .* taxMKT(whichMKT_reg_use(k,iu_di));
    end

    // on coupe la taxe sur les autoconso FF
    taxCO2_CI(1:nbsecteurenergie,[indice_coal indice_gaz indice_oil],1:reg)=0;

endfunction

function v=call_eco(equilibrium)

    x0C = equilibrium

    v=clean(fort(equi_function,size(x0C,'r'),1,'i',x0C,2,'d','out',[1,size(x0C,'r')],3,'d'))

endfunction


/////////////////////fonctions de répartition de l'investissement électrique. on passe d'un problème de minimisation sous contraintes d'inégalité à un problème de minimisation pénalisée sous contraintes d'égalité avec positivté des variables
function [y] = dist(xloc);
    Inv_cost=sum(xloc(1:techno_elec).*CINV_MW(k,:,current_time_im)'/1e3)
    y=sum((xloc(1:techno_elec)-delta_Cap_elec_MW_1(k,:)').*(xloc(1:techno_elec)-delta_Cap_elec_MW_1(k,:)'))+1000*(Inv_cost-Inv_val_sec(k,indice_elec)+xloc(techno_elec+1)).^2;
endfunction

function [f,g,ind] = costdist(xloc,ind);
    [f,g,ind]=NDcost(xloc,ind,dist);
endfunction

//fonction de calcul des courbes de hubbert à la décroissance


function y = hubbert_slope(b);
    y=b-Cap_util_oil(k,j)/(Ress_oil(k,j)/0.9)*(1+exp(-b*(current_time_im-i_hubbert(k,j))));
endfunction

function y = hubbert_heavy_slope(b);
    y=b-Cap_util_heavy(k,j)/(Ress_heavy(k,j)/0.9)*(1+exp(-b*(current_time_im-i_heavy(k,j))));
endfunction

function y = hubbert_shale_slope(b);
    y=b-Cap_util_shale(k,j)/(Ress_shale(k,j)/0.9)*(1+exp(-b*(current_time_im-i_shale(k,j))));
endfunction

function y = hubbert_slope_MO(b);
    y=b-Cap(ind_mde,indice_oil)/(Ress_oil_MO/0.9)*(1+exp(-b*(current_time_im-i_hubbert_MO)));
endfunction

function [y] =  calib_markup_gaz(xloc)

    markup_temp=xloc;
    costs_CI=zeros(reg,sec);
    ploc=p;
    ploc(:,indice_gaz)=pref(:,indice_gaz).*taux_gaz_prix*p(1,indice_composite);

    pArmCItemp=pArmCI;

    pArmCItemp(1:nbsecteurenergie,indice_gaz,:)=((ploc(:,1:nbsecteurenergie)').*(1+matrix(taxCIdom(1:nbsecteurenergie,indice_gaz,:),nbsecteurenergie,reg))).*(1-matrix(partImpCI(1:nbsecteurenergie,indice_gaz,:),nbsecteurenergie,reg))+(((ones(12,1)*wpEner.*(1+mtax(:,1:nbsecteurenergie))+nit(:,1:nbsecteurenergie)*wpTIagg)').*(1+matrix(taxCIimp(1:nbsecteurenergie,indice_gaz,:),nbsecteurenergie,reg))).*matrix(partImpCI(1:nbsecteurenergie,indice_gaz,:),nbsecteurenergie,reg)+(matrix(taxCO2_CI(1:nbsecteurenergie,indice_gaz,:),nbsecteurenergie,reg).*matrix(coef_Q_CO2_CI(1:nbsecteurenergie,indice_gaz,:),nbsecteurenergie,reg)).*(num(:,1:nbsecteurenergie)');

    costs_CI(:,indice_gaz)=sum(pArmCItemp(:,indice_gaz,:).*CI(:,indice_gaz,:),"r");
    dispoRess = Ress_gaz/sum(Ress_gaz);
    FCC_ant = FCC(:,gaz) .* (1 + (dispoRess < 0.01) .* (1 ./ 0.01) .* (dispoRess - 0.01));

    y=(A(:,indice_gaz).*(costs_CI(:,indice_gaz)+w(:,indice_gaz).*l(:,indice_gaz).*(1+sigma(:,indice_gaz)).*(energ_sec(:,indice_gaz)+FCC_ant.*non_energ_sec(:,indice_gaz)))+markup_temp.*ploc(:,indice_gaz).*((energ_sec(:,indice_gaz)+non_energ_sec(:,indice_gaz)))).*(1+qtax(:,indice_gaz))-ploc(:,indice_gaz);

endfunction

function [y] =  calib_markup_coal(xloc)

    markup_temp=xloc;
    costs_CI=zeros(reg,sec);
    ploc=p;
    ploc(:,indice_coal)=pref(:,indice_coal).*taux_coal_prix*p(1,indice_composite);

    pArmCItemp=pArmCI;

    pArmCItemp(1:nbsecteurenergie,indice_coal,:)=((ploc(:,1:nbsecteurenergie)').*(1+matrix(taxCIdom(1:nbsecteurenergie,indice_coal,:),nbsecteurenergie,reg))).*(1-matrix(partImpCI(1:nbsecteurenergie,indice_coal,:),nbsecteurenergie,reg))+(((ones(12,1)*wpEner.*(1+mtax(:,1:nbsecteurenergie))+nit(:,1:nbsecteurenergie)*wpTIagg)').*(1+matrix(taxCIimp(1:nbsecteurenergie,indice_coal,:),nbsecteurenergie,reg))).*matrix(partImpCI(1:nbsecteurenergie,indice_coal,:),nbsecteurenergie,reg)+(matrix(taxCO2_CI(1:nbsecteurenergie,indice_coal,:),nbsecteurenergie,reg).*matrix(coef_Q_CO2_CI(1:nbsecteurenergie,indice_coal,:),nbsecteurenergie,reg)).*(num(:,1:nbsecteurenergie)');

    costs_CI(:,indice_coal)=sum(pArmCItemp(:,indice_coal,:).*CI(:,indice_coal,:),"r");
    dispoRess = Ress_coal/sum(Ress_coal);
    thresh_FCC_coal = 0.02; //AMPERE, was 0.01.
    FCC_ant = FCC(:,coal) .* (1 + (dispoRess < thresh_FCC_coal) .* (1 ./ thresh_FCC_coal) .* (dispoRess - thresh_FCC_coal));

    y=(A(:,indice_coal).*(costs_CI(:,indice_coal)+w(:,indice_coal).*l(:,indice_coal).*(1+sigma(:,indice_coal)).*(energ_sec(:,indice_coal)+FCC_ant.*non_energ_sec(:,indice_coal)))+markup_temp.*ploc(:,indice_coal).*((energ_sec(:,indice_coal)+non_energ_sec(:,indice_coal)))).*(1+qtax(:,indice_coal))-ploc(:,indice_coal);


endfunction

function [y] =  calib_markup_elec(xloc)

    markup_temp=markup;
    markup_temp(:,indice_elec)=xloc;
    costs_CI=zeros(reg,sec);
    biomassTaxBack = zeros(reg,1);
    ploc=p;
    ploc(:,indice_elec)=pref(:,indice_elec).*CC_elec_i_1WoBioTax./CC_elec_i_1_ref*p(1,indice_composite);
    wpEnerloc=wpEner;
    wpTIaggloc=wpTIagg;
    numloc=num;

    pArmCItemp=pArmCI;
    for k=1:reg
        pArmCItemp(1:nbsecteurenergie,:,k) = ((ploc(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k)))..
        .*(1-partImpCI(1:nbsecteurenergie,:,k))..
        +(..
        ((wpEnerloc.*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIaggloc)'*ones(1,sec))..
        .*(1+taxCIimp(1:nbsecteurenergie,:,k))..
        )..
        .*partImpCI(1:nbsecteurenergie,:,k)+..
        (taxCO2_CI(1:nbsecteurenergie,:,k).*coef_Q_CO2_CI(1:nbsecteurenergie,:,k)).*(numloc(k,1:nbsecteurenergie)'*ones(1,sec));
    end
    for k=1:reg
        costs_CI(k,:) = sum(pArmCItemp(:,:,k).*CI(:,:,k),"r");
        biomassTaxBack(k) = (1-shareBiomassTaxElec) * CI(elec,elec,k) * coef_Q_CO2_CI(elec,elec,k) * taxCO2_CI(elec,elec,k) * numloc(k,elec);
    end

    y1=(A.*(costs_CI+w.*l.*(1+sigma).*(energ_sec+FCC.*non_energ_sec))+markup_temp.*ploc.*((energ_sec+non_energ_sec)) - repmat(biomassTaxBack,1,sec)).*(1+qtaxref)-ploc; // DESAG_INDUSTRY: was previously ones(1:reg), but seemed to be a mistake as biomassTaxBack had already a region dimension (see at the beginning of this function). Is that correct?
    y=y1(:,indice_elec); 

endfunction


function [y] =  calib_UR_oil_MO(xloc)
    charge_temp=charge;
    charge_temp(9,indice_oil)=xloc;
    FCCtemp=aRD+bRD.*tanh(cRD.*(charge_temp-1));
    FCCmarkup=ones(reg,sec);
    FCCmarkup=((markup_lim_oil-markupref)/(1-0.8).*(charge_temp-0.8*ones(reg,sec))+markupref)./markup;
    FCCmarkup_oil=ones(reg,sec);
    FCCmarkup_oil(:,indice_oil)=FCCmarkup(:,indice_oil);

    costs_CI=zeros(reg,sec);
    ploc=p;
    //ploc(9,indice_oil)=pref(9,indice_oil).*taux_oil_prix*p(1,indice_composite) / overshoot_taux_oil_prix; 
    ploc(9,indice_oil)=pref(9,indice_oil).*taux_oil_prix*p(1,indice_composite) ; 
    wpEnerloc=wpEner;
    wpTIaggloc=wpTIagg;
    numloc=num;

    pArmCItemp=pArmCI;
    for k=1:reg,
        pArmCItemp(1:nbsecteurenergie,:,k)=((ploc(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k))).*(1-partImpCI(1:nbsecteurenergie,:,k))+(((wpEnerloc.*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIaggloc)'*ones(1,sec)).*(1+taxCIimp(1:nbsecteurenergie,:,k))).*partImpCI(1:nbsecteurenergie,:,k)+(taxCO2_CI(1:nbsecteurenergie,:,k).*coef_Q_CO2_CI(1:nbsecteurenergie,:,k)).*(numloc(k,1:nbsecteurenergie)'*ones(1,sec));
    end
    costs_CI=zeros(reg,sec);
    for k=1:reg,
        costs_CI(k,:)=sum(pArmCI(:,:,k).*CI(:,:,k),"r");
    end
    //
    y1=(A.*(costs_CI+w.*l.*(1+sigma).*(energ_sec+FCCtemp.*non_energ_sec))+FCCmarkup_oil.*markup.*ploc.*((energ_sec+non_energ_sec))).*(1+qtax)-ploc;

    y=y1(9,indice_oil);

endfunction



function [y] =  calib_UR_CTL(xloc)
    charge_temp=charge;
    charge_temp(:,indice_oil)=xloc;
    FCCtemp=aRD+bRD.*tanh(cRD.*(charge_temp-1));
    FCCmarkup=ones(reg,sec);
    FCCmarkup=((ones(reg,sec)-markupref)/(1-0.8).*charge_temp+(markupref-0.8*ones(reg,sec))/(1-0.8))./markup;
    FCCmarkup_oil=ones(reg,sec);
    FCCmarkup_oil(:,indice_oil)=FCCmarkup(:,indice_oil);

    costs_CI=zeros(reg,sec);
    ploc=p;
    ploc(:,indice_oil)=pref(:,indice_oil).*taux_oil_prix_CTL*p(1,indice_composite);
    wpEnerloc=wpEner;
    wpTIaggloc=wpTIagg;
    numloc=num;

    pArmCItemp=pArmCI;
    for k=1:reg,
        pArmCItemp(1:nbsecteurenergie,:,k)=((ploc(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k))).*(1-partImpCI(1:nbsecteurenergie,:,k))+(((wpEnerloc.*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIaggloc)'*ones(1,sec)).*(1+taxCIimp(1:nbsecteurenergie,:,k))).*partImpCI(1:nbsecteurenergie,:,k)+(taxCO2_CI(1:nbsecteurenergie,:,k).*coef_Q_CO2_CI(1:nbsecteurenergie,:,k)).*(numloc(k,1:nbsecteurenergie)'*ones(1,sec));
    end
    costs_CI=zeros(reg,sec);
    for k=1:reg,
        costs_CI(k,:)=sum(pArmCI(:,:,k).*CI(:,:,k),"r");
    end
    //
    y1=(A.*(costs_CI+w.*l.*(1+sigma).*(energ_sec+FCCtemp.*non_energ_sec))+FCCmarkup_oil.*markup.*ploc.*((energ_sec+non_energ_sec))).*(1+qtax)-ploc;

    y=y1(:,indice_oil);

endfunction



function [y] =  calib_markup_oil(xloc)

    markup_temp=xloc;
    costs_CI=zeros(reg,sec);
    ploc=p;
    ploc(:,indice_oil)=pref(:,indice_oil).*taux_oil_prix*p(1,indice_composite);

    pArmCItemp=pArmCI;

    pArmCItemp(1:nbsecteurenergie,indice_oil,:)=((ploc(:,1:nbsecteurenergie)').*(1+matrix(taxCIdom(1:nbsecteurenergie,indice_oil,:),nbsecteurenergie,reg))).*(1-matrix(partImpCI(1:nbsecteurenergie,indice_oil,:),nbsecteurenergie,reg))+(((ones(12,1)*wpEner.*(1+mtax(:,1:nbsecteurenergie))+nit(:,1:nbsecteurenergie)*wpTIagg)').*(1+matrix(taxCIimp(1:nbsecteurenergie,indice_oil,:),nbsecteurenergie,reg))).*matrix(partImpCI(1:nbsecteurenergie,indice_oil,:),nbsecteurenergie,reg)+(matrix(taxCO2_CI(1:nbsecteurenergie,indice_oil,:),nbsecteurenergie,reg).*matrix(coef_Q_CO2_CI(1:nbsecteurenergie,indice_oil,:),nbsecteurenergie,reg)).*(num(:,1:nbsecteurenergie)');

    y=(A(:,indice_oil).*(costs_CI(:,indice_oil)+w(:,indice_oil).*l(:,indice_oil).*(1+sigma(:,indice_oil)).*(energ_sec(:,indice_oil)+FCC_ant.*non_energ_sec(:,indice_oil)))+markup_temp.*ploc(:,indice_oil).*((energ_sec(:,indice_oil)+non_energ_sec(:,indice_oil)))).*(1+qtax(:,indice_oil))-ploc(:,indice_oil);

endfunction


function [y] =  calib_learning_curve(xloc)
    y=CINV_MW_ITC_ref(j)*lim_gain_ITC_elec_temp-(CINV_MW_ITC_ref(j)-0*A_CINV_MW_ITC_ref(j))*(1-LR_ITC_elec(j)).^( log2 ((xloc+sum_Inv_MW(j))/xloc))+0*A_CINV_MW_ITC_ref(j);
endfunction

// function [y] =  calib_learning_curve_cars(xloc)
// y=CINV_cars_ITC_ref(j)*0.99-(CINV_cars_ITC_ref(j))*(1-LR_ITC_cars(j)).^( log2 ((xloc+sum_Inv_cars(j))/xloc));
// endfunction


function [y] = K_cal_logit_ind(Kloc)
    p_ener_industrie=[pArmCI(indice_coal,indice_industries(sec_indus),pays);pArmCI(indice_Et,indice_industries(sec_indus),pays);pArmCI(indice_gaz,indice_industries(sec_indus),pays);pArmCI(indice_elec,indice_industries(sec_indus),pays)];
    LCC_calibration=(Kloc.^2).*CRF_industrie+p_ener_industrie./rhoindustrie_dyn; // dimension of Kloc to be updated
    SH_ener_calib=zeros(4,1);
    for j=1:4
        SH_ener_calib(j)=(LCC_calibration(j)).^(-var_hom_industrie(pays))./sum((((LCC_calibration)).^(-var_hom_industrie(pays)*ones(4,1))));
    end

    p_ener_industrie_CO2=[pArmCI_CO2(indice_coal,indice_industries(sec_indus),pays);pArmCI_CO2(indice_Et,indice_industries(sec_indus),pays);pArmCI_CO2(indice_gaz,indice_industries(sec_indus),pays);pArmCI_CO2(indice_elec,indice_industries(sec_indus),pays)];
    LCC_calibration_CO2=(Kloc.^2).*CRF_industrie+p_ener_industrie_CO2./rhoindustrie_dyn;
    SH_ener_calib_CO2=zeros(4,1);
    for j=1:4
        SH_ener_calib_CO2(j)=(LCC_calibration_CO2(j)).^(-var_hom_industrie(pays))./sum((((LCC_calibration_CO2)).^(-var_hom_industrie(pays)*ones(4,1))));
    end
	Penergieutileind_2d(pays,1:3)=Penergieutileind(pays,sec_indus,1:3);
    y=[SH_ener_calib(1:3)-Penergieutileind_2d(pays,1:3)';SH_ener_calib_CO2(1)+SH_ener_calib_CO2(2)-SH_ener_ind_oil_coal_lim];
endfunction

function [y] = K_cal_logit_agr(Kloc)
    p_ener_agriculture=[pArmCI(indice_coal,indice_agriculture,pays);pArmCI(indice_Et,indice_agriculture,pays);pArmCI(indice_gaz,indice_agriculture,pays);pArmCI(indice_elec,indice_agriculture,pays)];
    LCC_calibration=(Kloc.^2).*CRF_agriculture+p_ener_agriculture./rhoagriculture_dyn;
    SH_ener_calib=zeros(4,1);
    for j=1:4
        SH_ener_calib(j)=(LCC_calibration(j)).^(-var_hom_agriculture(pays))./sum((((LCC_calibration)).^(-var_hom_agriculture(pays)*ones(4,1))));
    end

    p_ener_agriculture_CO2=[pArmCI_CO2(indice_coal,indice_agriculture,pays);pArmCI_CO2(indice_Et,indice_agriculture,pays);pArmCI_CO2(indice_gaz,indice_agriculture,pays);pArmCI_CO2(indice_elec,indice_agriculture,pays)];
    LCC_calibration_CO2=(Kloc.^2).*CRF_agriculture+p_ener_agriculture_CO2./rhoagriculture_dyn;
    SH_ener_calib_CO2=zeros(4,1);
    for j=1:4
        SH_ener_calib_CO2(j)=(LCC_calibration_CO2(j)).^(-var_hom_agriculture(pays))./sum((((LCC_calibration_CO2)).^(-var_hom_agriculture(pays)*ones(4,1))));
    end
    y=[SH_ener_calib(1:3)-Penergieutileagric(pays,1:3)';SH_ener_calib_CO2(1)+SH_ener_calib_CO2(2)-SH_ener_agr_oil_coal_lim];
endfunction

function [y] = K_cal_logit_ser(Kloc)
    p_ener_composite=[pArmCI(indice_coal,indice_composite,pays);pArmCI(indice_Et,indice_composite,pays);pArmCI(indice_gaz,indice_composite,pays);pArmCI(indice_elec,indice_composite,pays)];
    LCC_calibration=(Kloc.^2).*CRF_composite+p_ener_composite./rhocomposite_dyn;
    SH_ener_calib=zeros(4,1);
    for j=1:4
        SH_ener_calib(j)=(LCC_calibration(j)).^(-var_hom_composite(pays))./sum((((LCC_calibration)).^(-var_hom_composite(pays)*ones(4,1))));
    end

    p_ener_composite_CO2=[pArmCI_CO2(indice_coal,indice_composite,pays);pArmCI_CO2(indice_Et,indice_composite,pays);pArmCI_CO2(indice_gaz,indice_composite,pays);pArmCI_CO2(indice_elec,indice_composite,pays)];
    LCC_calibration_CO2=(Kloc.^2).*CRF_composite+p_ener_composite_CO2./rhocomposite_dyn;
    SH_ener_calib_CO2=zeros(4,1);
    for j=1:4
        SH_ener_calib_CO2(j)=(LCC_calibration_CO2(j)).^(-var_hom_composite(pays))./sum((((LCC_calibration_CO2)).^(-var_hom_composite(pays)*ones(4,1))));
    end
    y=[SH_ener_calib(1:3)-Penergieutilecomposite(pays,1:3)';SH_ener_calib_CO2(1)+SH_ener_calib_CO2(2)-SH_ener_ser_oil_coal_lim];
endfunction



function [y] = calib_taxDFdom_Et(xloc)
    y=((p_temp(:,indice_Et).*(1+xloc)).*(1-partImpDF(:,indice_Et))+(((ones(reg,1)*wpEner_temp(indice_Et)).*(1+mtax(:,indice_Et))+(ones(reg,1)*wpTIagg_temp).*nit(:,indice_Et)).*(1+taxDFimp(:,indice_Et))).*partImpDF(:,indice_Et)).*(1+Ttax(:,indice_Et))./pArmDFref(:,indice_Et)-(a_tra.*ones(reg,1)*(wp(indice_oil)/p(1,indice_composite))/wpref(indice_oil)+b_tra);
endfunction
function [y] = calib_taxDGdom_Et(xloc)
    y=((p_temp(:,indice_Et).*(1+xloc)).*(1-partImpDG(:,indice_Et))+(((ones(reg,1)*wpEner_temp(indice_Et)).*(1+mtax(:,indice_Et))+(ones(reg,1)*wpTIagg_temp).*nit(:,indice_Et)).*(1+taxDGimp(:,indice_Et))).*partImpDG(:,indice_Et))./pArmDGref(:,indice_Et)-(a_tra.*ones(reg,1)*(wp(indice_oil)/p(1,indice_composite))/wpref(indice_oil)+b_tra);
endfunction
function [y] = calib_taxDIdom_Et(xloc)
    y=((p_temp(:,indice_Et).*(1+xloc)).*(1-partImpDI(:,indice_Et))+(((ones(reg,1)*wpEner_temp(indice_Et)).*(1+mtax(:,indice_Et))+(ones(reg,1)*wpTIagg_temp).*nit(:,indice_Et)).*(1+taxDIimp(:,indice_Et))).*partImpDI(:,indice_Et))./pArmDIref(:,indice_Et)-(a_tra.*ones(reg,1)*(wp(indice_oil)/p(1,indice_composite))/wpref(indice_oil)+b_tra);
endfunction

function [y] = calib_taxCIdom_Et(xloc)
    if ((j==8)|(j==9)|(j==10)) then
        y=(((p_temp(k,indice_Et)).*(1+xloc)).*(1-partImpCI(indice_Et,j,k))+(((wpEner_temp(indice_Et).*(1+mtax(k,indice_Et))+nit(k,indice_Et)*wpTIagg_temp)).*(1+taxCIimp(indice_Et,j,k))).*partImpCI(indice_Et,j,k))./pArmCIref(indice_Et,j,k)-(a_tra(k)*(wp(indice_oil)/p(1,indice_composite))/wpref(indice_oil)+b_tra(k));
    else
        y=(((p_temp(k,indice_Et)).*(1+xloc)).*(1-partImpCI(indice_Et,j,k))+(((wpEner_temp(indice_Et).*(1+mtax(k,indice_Et))+nit(k,indice_Et)*wpTIagg_temp)).*(1+taxCIimp(indice_Et,j,k))).*partImpCI(indice_Et,j,k))./pArmCIref(indice_Et,j,k)-(a_IND(k)*(wp(indice_oil)/p(1,indice_composite))/wpref(indice_oil)+b_IND(k));
    end
endfunction

function f=jacob_costIC(x)
    IC_temp=x(1:sizeIC);
    lambda_temp=x(sizeIC+1:2*sizeIC-1);
    sum_temp=sum((LCC+IC_temp).^nu)
    f=zeros(2*sizeIC-1,1);
    for kkk=1:sizeIC
        f(kkk)=2*IC_temp(kkk)
        for j=1:sizeIC-1
            f(kkk)=f(kkk)-lambda_temp(j)*(kro(kkk,j)*nu(kkk)*(LCC(kkk)+IC_temp(kkk)).^(nu(kkk)-1)*sum_temp-(LCC(j)+IC_temp(j)).^nu(kkk)*nu(kkk)*(LCC(kkk)+IC_temp(kkk)).^(nu(kkk)-1))/sum_temp.^2;
        end
    end
    f(sizeIC+1:$)=((LCC(1:sizeIC-1)+IC_temp(1:sizeIC-1)).^nu(1:sizeIC-1)/sum_temp-MS(1:sizeIC-1));
endfunction

function [y] = IC_calibration_new(MS_arg,LCC,val_nu)
    ///MS : market share de calibrage sum(MS)=1, MS(k)<>0, vecteur de taille n en colonne
    ///LCC : couts d'utilisation corespondant, vecteur de taille n en colonne
    ///index_ref : n° de la technologie qui va etre utilise pour le calcul, entier
    /// -val_nu : puissance de la logit, reel 
    //////traitement des MS pour enlever les valeurs nulles
    MS_temp=max(MS_arg,0.0001);
    //////la somme des parts doit faire 1
    sum_MS_temp=sum(MS_temp);
    MS_temp=MS_temp/sum(MS_temp);
    sizeIC=size(MS_arg,'r');
    //x_IC=[zeros(1,sizeIC),zeros(1:sizeIC-1)]';
    x_IC=[zeros(1,sizeIC),ones(1:sizeIC-1)]';
    nu=-val_nu*ones(sizeIC,1);
    sum_temp=sum((LCC).^nu);
    MS_ref=(LCC(1:sizeIC)).^nu(1:sizeIC)/sum_temp;
    MS_obj=MS_temp*4/5+1/5*MS_ref;
    MS=MS_ref;
    jacob_costIC(x_IC);
    // [u,v,info]=fsolve(x,jacob_costIC);
    // if max(abs(v))>10.^(-sens_pow) then [u,v,info]=fsolve(u,jacob_costIC); end
    u=x_IC;
    substep=0;
    substep_prev=0;
    last_try_failed=%f;
    nb_stepp=1;
    //sens_pow=5;
    sens_pow=5;
    // essais successifs
    while substep<1 do

        substep = substep_prev + 1/nb_stepp;
        MS=(1-substep)*MS_ref+MS_obj*substep;

        u_lastgood = u;
        [u,v,info]=fsolve(u,jacob_costIC);
        if max(abs(v))>10.^(-sens_pow) then [u,v,info]=fsolve(u,jacob_costIC); end
        if max(abs(v))>10.^(-sens_pow) then [u,v,info]=fsolve(u,jacob_costIC); end


        if (max(abs(v))>10.^(-sens_pow)) then 
            u=u_lastgood;
            substep = substep_prev;
            nb_stepp=2*nb_stepp;
            last_try_failed=%t;
        else
            substep_prev=substep;
            if last_try_failed then 
                last_try_failed=%f;
            else
                nb_stepp=max(nb_stepp/2,1);
            end

        end			

    end
    if max(abs(v))>10.^(-sens_pow) then pause; end
    disp(u(1:sizeIC)./LCC(1:sizeIC));
    y=u(1:sizeIC);
    pause;
endfunction
function f=kro(k,j)
    f=0;
    if k==j then f=1; end
endfunction


function [y] = IC_calibration_newPb(MS_arg,LCC,val_nu)
    ///MS : market share de calibrage sum(MS)=1, MS(k)<>0, vecteur de taille n en colonne
    ///LCC : couts d'utilisation corespondant, vecteur de taille n en colonne
    ///index_ref : n° de la technologie qui va etre utilise pour le calcul, entier
    /// -val_nu : puissance de la logit, reel 
    //////traitement des MS pour enlever les valeurs nulles

    //modification des part visées pour ne pas trop s'éloigner de la situation où on calibre
    sizeIC=size(MS_arg,'r');
    nu=-val_nu*ones(sizeIC,1);
    sum_temp=sum((LCC).^nu);
    MS_ref=(LCC(1:sizeIC)).^nu(1:sizeIC)/sum_temp;
    MS_temp=MS_arg;
    for kk=1:sizeIC
        if (MS_temp(kk)<0.005)&(MS_ref(kk)<0.005) then MS_temp(kk)=MS_ref(kk); end
        if (MS_temp(kk)>10*MS_ref(kk)) then MS_temp(kk)=5*MS_ref(kk); end
        if (MS_temp(kk)<MS_ref(kk)/10) then MS_temp(kk)=MS_ref(kk)/5; end
    end
    //////la somme des parts doit faire 1
    MS_temp=MS_temp/sum(MS_temp);

    //x_IC=[zeros(1,sizeIC),zeros(1:sizeIC-1)]';
    x_IC=[zeros(1,sizeIC),ones(1:sizeIC-1)]';
    MS_obj=MS_temp;
    //MS_obj=MS_temp*4/5+1/5*MS_ref;
    MS=MS_ref;
    jacob_costIC(x_IC);
    // [u,v,info]=fsolve(x,jacob_costIC);
    // if max(abs(v))>10.^(-sens_pow) then [u,v,info]=fsolve(u,jacob_costIC); end
    u=x_IC;
    substep=0;
    substep_prev=0;
    last_try_failed=%f;
    nb_stepp=1;
    //sens_pow=5;
    sens_pow=5;
    // essais successifs

    while substep<1 do

        substep = substep_prev + 1/nb_stepp;
        MS=(1-substep)*MS_ref+MS_obj*substep;

        u_lastgood = u;
        [u,v,info]=fsolve(u,jacob_costIC);
        if max(abs(v))>10.^(-sens_pow) then [u,v,info]=fsolve(u,jacob_costIC); end
        if max(abs(v))>10.^(-sens_pow) then [u,v,info]=fsolve(u,jacob_costIC); end


        if (max(abs(v))>10.^(-sens_pow)) then 
            u=u_lastgood;
            substep = substep_prev;
            nb_stepp=2*nb_stepp;
            last_try_failed=%t;
        else
            substep_prev=substep;
            if last_try_failed then 
                last_try_failed=%f;
            else
                nb_stepp=max(nb_stepp/2,1);
            end

        end			

    end
    if max(abs(v))>10.^(-sens_pow) then pause; end
    disp(u(1:sizeIC)./LCC(1:sizeIC));
    disp([MS_arg,MS_obj]);
    y=u(1:sizeIC);

endfunction

function [y] = IC_calibration_newGPb(MS_arg,LCC,val_nu)
    ///MS : market share de calibrage sum(MS)=1, MS(k)<>0, vecteur de taille n en colonne
    ///LCC : couts d'utilisation corespondant, vecteur de taille n en colonne
    ///index_ref : n° de la technologie qui va etre utilise pour le calcul, entier
    /// -val_nu : puissance de la logit, reel 
    //////traitement des MS pour enlever les valeurs nulles

    //modification des part visées pour ne pas trop s'éloigner de la situation où on calibre
    sizeIC=size(MS_arg,'r');
    nu=-val_nu*ones(sizeIC,1);
    sum_temp=sum((LCC).^nu);
    MS_ref=(LCC(1:sizeIC)).^nu(1:sizeIC)/sum_temp;
    MS_temp=MS_arg;
    for kk=1:sizeIC
        if (MS_temp(kk)<0.005)&(MS_ref(kk)<0.005) then MS_temp(kk)=MS_ref(kk); end
        if (MS_temp(kk)>10*MS_ref(kk)) then MS_temp(kk)=1.8*MS_ref(kk); end
        if (MS_temp(kk)<MS_ref(kk)/10) then MS_temp(kk)=MS_ref(kk)/1.8; end
    end
    //////la somme des parts doit faire 1
    MS_temp=MS_temp/sum(MS_temp);

    //x_IC=[zeros(1,sizeIC),zeros(1:sizeIC-1)]';
    x_IC=[zeros(1,sizeIC),ones(1:sizeIC-1)]';
    MS_obj=MS_temp;
    //MS_obj=MS_temp*4/5+1/5*MS_ref;
    MS=MS_ref;
    jacob_costIC(x_IC);
    // [u,v,info]=fsolve(x,jacob_costIC);
    // if max(abs(v))>10.^(-sens_pow) then [u,v,info]=fsolve(u,jacob_costIC); end
    u=x_IC;
    substep=0;
    substep_prev=0;
    last_try_failed=%f;
    nb_stepp=1;
    //sens_pow=5;
    sens_pow=5;
    // essais successifs

    while substep<1 do

        substep = substep_prev + 1/nb_stepp;
        MS=(1-substep)*MS_ref+MS_obj*substep;

        u_lastgood = u;
        [u,v,info]=fsolve(u,jacob_costIC);
        if max(abs(v))>10.^(-sens_pow) then [u,v,info]=fsolve(u,jacob_costIC); end
        if max(abs(v))>10.^(-sens_pow) then [u,v,info]=fsolve(u,jacob_costIC); end


        if (max(abs(v))>10.^(-sens_pow)) then 
            u=u_lastgood;
            substep = substep_prev;
            nb_stepp=2*nb_stepp;
            last_try_failed=%t;
        else
            substep_prev=substep;
            if last_try_failed then 
                last_try_failed=%f;
            else
                nb_stepp=max(nb_stepp/2,1);
            end

        end			

    end
    if max(abs(v))>10.^(-sens_pow) then pause; end
    disp(u(1:sizeIC)./LCC(1:sizeIC));
    disp([MS_arg,MS_obj]);
    y=u(1:sizeIC);

endfunction

function [y] = IC_calibration_newGGPb(MS_arg,LCC,val_nu)
    ///MS : market share de calibrage sum(MS)=1, MS(k)<>0, vecteur de taille n en colonne
    ///LCC : couts d'utilisation corespondant, vecteur de taille n en colonne
    ///index_ref : n° de la technologie qui va etre utilise pour le calcul, entier
    /// -val_nu : puissance de la logit, reel 
    //////traitement des MS pour enlever les valeurs nulles

    //modification des part visées pour ne pas trop s'éloigner de la situation où on calibre
    sizeIC=size(MS_arg,'r');
    nu=-val_nu*ones(sizeIC,1);
    sum_temp=sum((LCC).^nu);
    MS_ref=(LCC(1:sizeIC)).^nu(1:sizeIC)/sum_temp;
    MS_temp=MS_arg;
    for kk=1:sizeIC
        if (MS_temp(kk)<0.005)&(MS_ref(kk)<0.005) then MS_temp(kk)=MS_ref(kk); end
        if (MS_temp(kk)>5*MS_ref(kk)) then MS_temp(kk)=1.5*MS_ref(kk); end
        if (MS_temp(kk)<MS_ref(kk)/5) then MS_temp(kk)=MS_ref(kk)/1.5; end
    end
    //////la somme des parts doit faire 1
    MS_temp=MS_temp/sum(MS_temp);

    //x_IC=[zeros(1,sizeIC),zeros(1:sizeIC-1)]';
    x_IC=[zeros(1,sizeIC),ones(1:sizeIC-1)]';
    MS_obj=MS_temp;
    //MS_obj=MS_temp*4/5+1/5*MS_ref;
    MS=MS_ref;
    jacob_costIC(x_IC);
    // [u,v,info]=fsolve(x,jacob_costIC);
    // if max(abs(v))>10.^(-sens_pow) then [u,v,info]=fsolve(u,jacob_costIC); end
    u=x_IC;
    substep=0;
    substep_prev=0;
    last_try_failed=%f;
    nb_stepp=1;
    //sens_pow=5;
    sens_pow=5;
    // essais successifs

    while substep<1 do

        substep = substep_prev + 1/nb_stepp;
        MS=(1-substep)*MS_ref+MS_obj*substep;

        u_lastgood = u;
        [u,v,info]=fsolve(u,jacob_costIC);
        if max(abs(v))>10.^(-sens_pow) then [u,v,info]=fsolve(u,jacob_costIC); end
        if max(abs(v))>10.^(-sens_pow) then [u,v,info]=fsolve(u,jacob_costIC); end


        if (max(abs(v))>10.^(-sens_pow)) then 
            u=u_lastgood;
            substep = substep_prev;
            nb_stepp=2*nb_stepp;
            last_try_failed=%t;
        else
            substep_prev=substep;
            if last_try_failed then 
                last_try_failed=%f;
            else
                nb_stepp=max(nb_stepp/2,1);
            end

        end			

    end
    if max(abs(v))>10.^(-sens_pow) then pause; end
    disp(u(1:sizeIC)./LCC(1:sizeIC));
    disp([MS_arg,MS_obj]);
    y=u(1:sizeIC);

endfunction

/////////////////// Fonctions temps de transport pour chaque mode ////////////////////////////////////////////////////////////////


function [y] = tair_pays(Consoloc);
    y1 = toair(pays).*(atrans(pays,1).*((pkmautomobileref(pays)./(100)).*alphaair(pays).*Consoloc(:,indice_air-nbsecteurenergie)./Captransport(pays,1)).^ktrans(pays,1)+btrans(pays,1));
    y=y1;
endfunction

function [y] = tOT_pays(Consoloc);
    y1=toOT(pays).*(atrans(pays,2).*((pkmautomobileref(pays)./(100)).*alphaOT(pays).*Consoloc(:,indice_OT-nbsecteurenergie)./Captransport(pays,2)).^ktrans(pays,2)+btrans(pays,2));
    y=y1;
endfunction

function [y] = tautomobile_pays(Tautomobileloc);
    y1 = toautomobile(pays).*(atrans(pays,3).*((pkmautomobileref(pays)./(100)).*Tautomobileloc./Captransport(pays,3)).^ktrans(pays,3)+btrans(pays,3));
    y=y1;
endfunction

function [y] = Itair_pays(Consoloc);
    y1=toair(pays).*(atrans(pays,1).*((pkmautomobileref(pays)./(100)).*alphaair(pays).*Consoloc(:,indice_air-nbsecteurenergie)./Captransport(pays,1)).^(ktrans(pays,1)+1).*Captransport(pays,1)./(ktrans(pays,1)+1)+btrans(pays,1).*(pkmautomobileref(pays)./(100)).*alphaair(pays).*Consoloc(:,indice_air-nbsecteurenergie));
    y=y1;
endfunction

function [y] = ItOT_pays(Consoloc);
    y1=toOT(pays).*(atrans(pays,2).*((pkmautomobileref(pays)./(100)).*alphaOT(pays).*Consoloc(:,indice_OT-nbsecteurenergie)./Captransport(pays,2)).^(ktrans(pays,2)+1).*Captransport(pays,2)./(ktrans(pays,2)+1)+btrans(pays,2).*(pkmautomobileref(pays)./(100)).*alphaOT(pays).*Consoloc(:,indice_OT-nbsecteurenergie));
    y=y1;
endfunction

function [y] = Itautomobile_pays(Tautomobileloc);
    y1=toautomobile(pays).*(atrans(pays,3).*((pkmautomobileref(pays)./(100)).*Tautomobileloc./Captransport(pays,3)).^(ktrans(pays,3)+1).*Captransport(pays,3)./(ktrans(pays,3)+1)+btrans(pays,3).*(pkmautomobileref(pays)./(100)).*Tautomobileloc);
    y=y1;
endfunction

function [y] = calcUtilityHH_pays(DFloc,Tautomobileloc,TNMloc) ; // TODO: is it really still in use? The substraction seems to be inconsistent (Consoloc(:,indice_industrie-nbsecteurenergie)      -bn(pays,indice_industrie))

    // DFloc=DFtemp2;
    // Tautomobileloc=Tautomobile;
    // TNMloc = TNM;

    //double constraint (money + time)
    //Consoloc=[DFBTP,DFcomposite,DFair,DFmer,DFOT]
    Consoloc=DFloc(:,sec-nb_secteur_conso+1:sec);
    y=log(Consoloc(:,indice_construction-nbsecteurenergie)-bn(pays,indice_construction)).*xsi(pays,1)+...
    log(Consoloc(:,indice_composite-nbsecteurenergie)       -bn(pays,indice_composite)).*xsi(pays,2)+...
    log(Consoloc(:,indice_mer-nbsecteurenergie)             -bn(pays,indice_mer)).*xsi(pays,3)+...
    log(Consoloc(:,indice_agriculture-nbsecteurenergie)  -bn(pays,indice_agriculture)).*xsi(pays,4)+...
    sum(log(Consoloc(:,indice_industries_error-nbsecteurenergie)      -bn(pays,indice_industries)).*xsi(pays,5:4+nb_sectors_industry),'c')-... // I introduce here an error to check if it is used
    xsiT(pays)./sigmatrans(pays).*log(betatrans(pays,1).*(alphaair(pays).*(Consoloc(:,indice_air-nbsecteurenergie)-...
    bnair(pays))).^(-sigmatrans(pays))+betatrans(pays,2).*(alphaOT(pays).*(Consoloc(:,indice_OT-nbsecteurenergie)-bnOT(pays))).^(-sigmatrans(pays))+betatrans(pays,3).*(Tautomobileloc-bnautomobile(pays)).^(-sigmatrans(pays))+betatrans(pays,4).*(TNMloc-bnNM(pays)).^(-sigmatrans(pays)));

    //	y=log(Consoloc(:,indice_construction-nbsecteurenergie)-bn(:,indice_construction)).*xsi(:,1)+log(Consoloc(:,indice_composite-nbsecteurenergie)-bn(:,indice_composite))*xsi(:,2)+log(Consoloc(:,indice_mer-nbsecteurenergie)-bn(:,indice_mer)).*xsi(:,3)+log(Consoloc(:,indice_agriculture-nbsecteurenergie)-bn(:,indice_agriculture)).*xsi(:,4)+log(Consoloc(:,indice_industrie-nbsecteurenergie)-bn(:,indice_industrie)).*xsi(:,5)-xsiT./sigmatrans.*log(betatrans(:,1).*(alphaair.*(Consoloc(:,indice_air-nbsecteurenergie)-bnair)).^(-sigmatrans)+betatrans(:,2).*(alphaOT.*(Consoloc(:,indice_OT-nbsecteurenergie)-bnOT)).^(-sigmatrans)+betatrans(:,3).*(Tautomobileloc-bnautomobile).^(-sigmatrans)+betatrans(:,4).*(TNMloc-bnNM).^(-sigmatrans));
endfunction
