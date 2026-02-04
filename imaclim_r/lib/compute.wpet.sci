// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================



function [y] =  compute_wp_Et( )
    
    // CI, l, markup are modified by : "nexus.Et.coststruct.sce"

    Cap_temp = Cap ;
    CI_temp = CI_temp_NLU ;
    l_temp = l_temp_NLU;
    markup_temp = markup_temp_NLU;
    marketshare_temp = marketshare;
    // compute oil production
    QCdom = [];
    for k=1:reg
   	QCdom=[QCdom ; (A(k,:).*Q(k,:))*((CI_temp(:,:,k).*partDomCI(:,:,k))') ];
    end
    QCdom=QCdom +DF.*partDomDF+DG.*partDomDG+DI.*partDomDI;
    Imp = [];
    for k=1:reg
  	Imp=[Imp ; (A(k,:).*Q(k,:))*((CI_temp(:,:,k).*partImpCI(:,:,k))') ];
    end
    Imp=Imp +DF.*(partImpDF)+DG.*(partImpDG)+DI.*(partImpDI);
    Exp = marketshare.*(ones(reg,1)*sum(Imp,"r"));
    ExpTI = zeros(reg,sec);
    Q_temp = QCdom+Exp+ExpTI;

    // compute the corresponding oil price
    charge_temp= Q_temp / Cap_temp ;
    FCCtemp=aRD+bRD.*tanh(cRD.*(charge_temp-1));
    FCCmarkup=ones(reg,sec);
    FCCmarkup=((ones(reg,sec)-markupref)/(1-0.8).*charge_temp+(markupref-0.8*ones(reg,sec))/(1-0.8))./markup_temp;
    FCCmarkup=((markup_lim_oil-markupref)/(1-0.8).*( charge_temp-0.8*ones(reg,sec))+markupref)./markup_temp;
    FCCmarkup_oil=ones(reg,sec);
    FCCmarkup_oil(:,indice_oil)=FCCmarkup(:,indice_oil);

    costs_CI=zeros(reg,sec);
    ploc=p;
    wpEnerloc=wpEner;
    wpTIaggloc=wpTIagg;
    numloc=num;

    pArmCItemp=pArmCI;
    for k=1:reg,
        pArmCItemp(1:nbsecteurenergie,:,k)=((ploc(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k))).*(1-partImpCI(1:nbsecteurenergie,:,k))+(((wpEnerloc.*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIaggloc)'*ones(1,sec)).*(1+taxCIimp(1:nbsecteurenergie,:,k))).*partImpCI(1:nbsecteurenergie,:,k)+(taxCO2_CI(1:nbsecteurenergie,:,k).*coef_Q_CO2_CI(1:nbsecteurenergie,:,k)).*(numloc(k,1:nbsecteurenergie)'*ones(1,sec));
    end
    costs_CI=zeros(reg,sec);
    for k=1:reg,
        costs_CI(k,:)=sum(pArmCI(:,:,k).*CI_temp(:,:,k),"r");
    end
    p_temp=(A.*(costs_CI+w.*l_temp.*(1+sigma).*(energ_sec+FCCtemp.*non_energ_sec))+FCCmarkup_oil.*markup_temp.*ploc.*((energ_sec+non_energ_sec))).*(1+qtax);
    wp_temp = sum( Exp .* p_temp .* (1+xtax), "r" ) ./ sum( Exp , "r" ) ;

    // compute corresponding  wp et
    for k=1:reg,
        pArmCItemp(1:nbsecteurenergie,:,k)=((ploc(k,1:nbsecteurenergie)'*ones(1,sec)).*(1+taxCIdom(1:nbsecteurenergie,:,k))).*(1-partImpCI(1:nbsecteurenergie,:,k))+((( wp_temp(1:nbsecteurenergie).*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIaggloc)'*ones(1,sec)).*(1+taxCIimp(1:nbsecteurenergie,:,k))).*partImpCI(1:nbsecteurenergie,:,k)+(taxCO2_CI(1:nbsecteurenergie,:,k).*coef_Q_CO2_CI(1:nbsecteurenergie,:,k)).*(numloc(k,1:nbsecteurenergie)'*ones(1,sec));
    end
        costs_CI=zeros(reg,sec);
    for k=1:reg,
        costs_CI(k,:)=sum(pArmCI(:,:,k).*CI_temp(:,:,k),"r");
    end
    // coeff CO2 due to biofuels
    if 2  < current_time_im 
        coef_Q_CO2_Et_prod_old = coef_Q_CO2_Et_prod;
        coef_Q_CO2_Et_prod=share_biofuel.*coef_Q_CO2_biofuels+share_CTL.*coef_Q_CO2_CTL+share_oil_refin.*coef_Q_CO2_ref(:,indice_Et);
    else
        coef_Q_CO2_Et_prod = coef_Q_CO2_ref(:,indice_Et);
        coef_Q_CO2_Et_prod_old = coef_Q_CO2_ref(:,indice_Et);
    end

    // price of liquids
    p_temp=(A.*(costs_CI+w.*l_temp.*(1+sigma).*(energ_sec+FCCtemp.*non_energ_sec))+FCCmarkup_oil.*markup_temp.*ploc.*((energ_sec+non_energ_sec))).*(1+qtax);
    p_Et_oil_exp_tax_ethan= p_temp(:,indice_Et) + ( coef_Q_CO2_Et_prod).* taxCO2_DF(:,indice_Et) ;
    p_Et_oil_exp_tax_ethan_o= p(:,indice_Et) + ( coef_Q_CO2_Et_prod_old).* taxCO2_DF(:,indice_Et) ;

    // marketshare movements due to price movements :
    marketshare_temp(:,indice_Et) = bmarketshareener(:,indice_Et).*(( ( coef_Q_CO2_Et_prod_old).* taxCO2_DF(:,indice_Et)+p_temp(:,indice_Et) .*(1+xtax(:,indice_Et))./(p_stock(:,indice_Et).*(1+xtaxref(:,indice_Et)))).^(ones(reg,1)*etamarketshareener(indice_Et)))./(ones(reg,1)*sum(bmarketshareener(:,indice_Et).*(( ( coef_Q_CO2_Et_prod_old).* taxCO2_DF(:,indice_Et)+p_temp(:,indice_Et).*(1+xtax(:,indice_Et))./(p_stock(:,indice_Et).*(1+xtaxref(:,indice_Et)))).^(ones(reg,1)*etamarketshareener(indice_Et))),'r'));
    //marketshare_temp(:,indice_Et) = weightEt_new .* (( ( coef_Q_CO2_Et_prod_old).* taxCO2_DF(:,indice_Et) + p_temp(:,indice_Et).*(1+xtax(:,indice_Et)) ) .^ etaEtnew) ./ sum( weightEt_new .* (( ( coef_Q_CO2_Et_prod_old).* taxCO2_DF(:,indice_Et) + p_temp(:,indice_Et).*(1+xtax(:,indice_Et))) .^ etaEtnew));


    Exp = marketshare_temp.*(ones(reg,1)*sum(Imp,"r"));
    Q_temp = QCdom+Exp+ExpTI;
    
    if glob_in_bioelec_Et < 1e10
        p_Et_oil_exp_tax_ethan_n = (( Q_temp(:,indice_Et)- Q(:,indice_Et)) .* p_Et_oil_exp_tax_ethan + Q(:,indice_Et).*p_Et_oil_exp_tax_ethan_o ) ./  Q_temp(:,indice_Et) ;
    else
        p_Et_oil_exp_tax_ethan_n = p_Et_oil_exp_tax_ethan;
    end

    //wp_temp = sum( Exp .* p_temp .* (1+xtax), "r" ) ./ sum( Exp , "r" ) ;
    //wp_temp_et = sum( Exp(:,indice_Et) .* p_Et_oil_exp_tax_ethan .* (1+xtax(:,indice_Et)), "r" ) ./ sum( Exp(:,indice_Et) , "r" ) ;
    wp_temp_et = sum( Q_temp(:,indice_Et) .* p_Et_oil_exp_tax_ethan_n ) ./ sum( Q_temp(:,indice_Et) , "r" ) ;
   
    y = wp_temp(indice_Et) * overshoot_wplightoil_ant ;
    y = wp_temp_et * overshoot_wplightoil_ant ;

endfunction

