// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


/////////////////////////////////////////////////////////////////////////////////////////////////
//	TES_Sortie.sce 									       //
// 											       //
//Ce fichier est destiné à la construction de TES sous excel a partir des sorties de ImaclimR  //
//											       //
////////////////////////////////////////////////////////////////////////////////////////////////



//MODEL='C:\Documents and Settings\Admin\Bureau\Imaclim_TES\Baseline Macro envoyée à Poles 16_09 nouvelles parts nexus industrie_temp_FF_ndatapoles_AEEI_resid';

//exec(MODEL + '\Model6-0.sce');
////////////épargne

Epargne_Agg=(1-ptc).*Rdisp/p(1,7);
//==============================================================
//Reconstitution du TES...qui I hope sera equilibré....!!!!
//==============================================================
KK=5;
P=sec;
N=reg;
WPTI = [ones(1,7),wpTI];
wpTIagg;
//==============
//Coté Emplois:
//==============
//----------------------
//La conso des Menages:
//----------------------
for k=1:reg
    for j=1:sec
        C_Hsld_dom_corr(k)(j)= DF(k,j)*partDomDF(k,j)*p(k,j)*(1+taxDFdom(k,j))/p(1,7);
        C_Hsld_imp_corr(k)(j)= DF(k,j)*partImpDF(k,j)*(1+taxDFimp(k,j))*(wp(j)*(1+mtax(k,j))+nit(k,j)*wpTIagg)/p(1,7);
    end
end

//---------------------------------------
//La Conso des Administrations Publiques:
//---------------------------------------
for k=1:reg
    for j=1:sec
        C_G_dom_corr(k)(j)= DG(k,j)*partDomDG(k,j)*p(k,j)*(1+taxDGdom(k,j))/p(1,7);
        C_G_imp_corr(k)(j)= DG(k,j)*partImpDG(k,j)*(1+taxDGimp(k,j))*(wp(j)*(1+mtax(k,j))+nit(k,j)*wpTIagg)/p(1,7);
    end
end
//--------------------
//Les Investissements:
//--------------------
for k=1:reg
    for j=1:sec
        C_FBCF_dom_corr(k)(j)= DI(k,j)*partDomDI(k,j)*p(k,j)*(1+taxDIdom(k,j))/p(1,7);
        C_FBCF_imp_corr(k)(j)= DI(k,j)*partImpDI(k,j)*(1+taxDIimp(k,j))*(wp(j)*(1+mtax(k,j))+nit(k,j)*wpTIagg)/p(1,7);
    end
end
//-----------------
//Les Exportations:
//-----------------
for k=1:reg
    x_corr(k) =  ((Exp(k,:).*p(k,:)).*(1 + xtax(k,:)))'/p(1,7);
    //X_Trans_corr(k) =   (ExpTI(k,:)*p(k,indice_transport))'/p(1,7);
    X_Trans_corr(k) =  (ExpTI(k,:).*p(k,:))'/p(1,7); // ça sert a rien de definir les 3 indices transports, puisque de ttes les façons ExpTI=0 pr sec non transp
end
//--------
//Les CI:
//--------
for k=1:reg
    for ii=1:sec
        for j=1:sec
            CI_dom_Agg_corr_Trans(k)(ii,j) = partDomCI(ii,j,k)*CI(ii,j,k)*Q(k,j)*p(k,ii)/p(1,7);
            CI_imp_Agg_corr(k)(ii,j) =  partImpCI(ii,j,k)*CI(ii,j,k)*Q(k,j)*(wp(ii)*(1+mtax(k,ii))+nit(k,ii)*wpTIagg)/p(1,7);
        end
    end
end

//------------------------------------------
//Concatenation des Matrices coté Emplois:
//------------------------------------------
C_Hsld=list();
C_G=list();
C_FBCF=list();
C_Hsld_Tot=list();
C_G_Tot=list();
C_G_Tot=list();
C_FBCF_Tot=list();
X_Tot=list();
CI_imp_Tot=list();
CI_dom_Tot=list();
CI_emplois=list();
ci_tot_emp=list();
CI_Tot_emplois=list();
T_Prod=list();
T_C_Fact=list();
TCI_dom=list();
TCI_imp=list();
TCI=list();
T_FBCF=list();
T_Hsld_dom=list();
T_Hsld_imp=list();
T_Hsld=list();
T_AP_dom=list();
T_AP_imp=list();
T_AP=list();
T_M=list();
T_X=list();
T_Auto_MX=list();
Tot_Taxes=list();
Taxes=list();
X=list();
CI_ressources=list();
ci_tot_ress=list();
CI_Tot_ressources=list();
C_Fact_Tot=list();
M=list();
M_Tot=list();
Total_Emplois=list();
Emplois=list();
Total_Ressources=list();
Ressources=list();
Erreur=list();
for k=1:reg
    ///Concaténation des Matrices ( Produits Imp avec Produits Dom et X avec X-Transport)(matrices P*2)
    C_Hsld(k) = [ C_Hsld_imp_corr(k,:)', C_Hsld_dom_corr(k,:)'];
    C_G(k)    = [ C_G_imp_corr(k,:)'   , C_G_dom_corr(k,:)'   ];
    C_FBCF(k) = [ C_FBCF_imp_corr(k,:)', C_FBCF_dom_corr(k,:)'];
    X(k)      = [ x_corr(k)           X_Trans_corr(k)];
    ///Les meme données concaténées avec les totaux "correspondants" ( matrices (P+1)*3 )
    C_Hsld_Tot(k) = [ C_Hsld(k)  sum(C_Hsld(k),'c') ; sum(C_Hsld(k),'r')  sum(C_Hsld(k))];
    C_G_Tot(k)    = [ C_G(k)  sum(C_G(k),'c') ; sum(C_G(k),'r')  sum(C_G(k))];
    C_FBCF_Tot(k) = [ C_FBCF(k)  sum(C_FBCF(k),'c') ; sum(C_FBCF(k),'r')  sum(C_FBCF(k))];
    X_Tot(k)      = [ X(k)  sum(X(k),'c') ; sum(X(k),'r')  sum(X(k))];
    ///De meme pour les Consommations Intermédiaires ( Totaux pour matrice Imp, Totaux pour matrice Dom, Concaténation des 2 matries (P+1)*(P+1) --->> 1 matrice (P+1)*(2P+2)--->>Puis concaténation avec le vect TotalCI(P+1)--->> 1 matrice (P+1)*(2P+3)
    CI_imp_Tot(k) = [ CI_imp_Agg_corr(k) sum(CI_imp_Agg_corr(k),'c') ; sum(CI_imp_Agg_corr(k),'r') sum(CI_imp_Agg_corr(k))]; //(P+1)*(P+1)
    CI_dom_Tot(k) = [ CI_dom_Agg_corr_Trans(k) sum(CI_dom_Agg_corr_Trans(k),'c') ; sum(CI_dom_Agg_corr_Trans(k),'r') sum(CI_dom_Agg_corr_Trans(k))];

    CI_emplois(k) = [ CI_imp_Tot(k) CI_dom_Tot(k) ]; //(P+1)*(2P+2)
    ci_tot_emp(k) = CI_emplois(k)(:,P+1)+ CI_emplois(k)(:,2*P+2); //vect(P+1)
    CI_Tot_emplois(k) = [ CI_emplois(k) ci_tot_emp(k) ]; // (P+1)*(2P+3)
end


//==================
//Coté Ressources:
//==================

//-----------------
//Conso de facteurs:
//-----------------
//attention, on va aggréger les lignes conso de main d'oeuvre qualifiée et non qualifiée, mais pour garder la meme structure de tableau (TES) sans se prendre la tete , je vais mettre la conso de main d'eoua=vre qualifié à zero....!!!!et toc.....!
// Tout sa parceque dans le fichier calibration.sce on a: SALgross(k,:)=CFact_Agg(k)(2,:)+CFact_Agg(k)(3,:);
// et donc il est immpossible de dissocier les deux....!!! et tac....!!!
SALNET =  w.*l.*Q.*FCC/p(1,7) ;
Profit =  markup.*p.*Q/p(1,7);
//SALgross = SALNET.*(1+sigma).*FCC/p(1,7) ;
//SALgross = SALNET.*(1+sigma).*FCC;
for k=1:reg,
    CFact_Agg(k)(2,:) = SALNET(k,:);
    CFact_Agg(k)(3,:) = zeros(1,sec);
    CFact_Agg(k)(1,:) = zeros(1,sec);
    CFact_Agg(k)(4,:) = Profit(k,:);
    CFact_Agg(k)(5,:) = zeros(1,sec);
end
//-------------
//Importations:
//--------------
mm = Imp.*(ones(reg,1)*wp)/p(1,7);
for k=1:reg
    m_fob_corr(k) = (mm(k,:))';
    //    M_Trans_corr(k) = ( (m_fob_corr(k)'./wp).*nit(k,:).*wpTIagg )'/p(1,7);
    M_Trans_corr(k) = ( (m_fob_corr(k)'./wp).*nit(k,:).*wpTIagg )';
end
//-------
//Taxes:
//------------------
//Sur la Production:
//-------------------
for k=1:reg,
    Tprod(k) =   ( [qtax(k,:).*Q(k,:).*p(k,:)]./(1+qtax(k,:)))'/p(1,7);
end
//--------------------------
//Sur la Conso de facteurs:
//--------------------------


for k=1:reg
    T_ConsFact_Agg(k)=zeros(KK,sec);
    T_ConsFact_Agg(k)(2,:)=SALNET(k,:).*(sigma(k,:));
end

//-----------
//Sur les CI:
//-----------
for k=1:reg
    for ii=1:sec
        for j=1:sec
            T_CI_dom_Agg_corr(k)(ii,j) = taxCIdom(ii,j,k)*CI_dom_Agg_corr_Trans(k)(ii,j);
            T_CI_imp_Agg_corr(k)(ii,j) = taxCIimp(ii,j,k)*CI_imp_Agg_corr(k)(ii,j);
        end
    end
end
//-------------
//Sur la FBCF :
//-------------
for k=1:reg
    for j=1:sec
        T_FBCF_dom_Agg_corr(k)(j) = taxDIdom(k,j)*C_FBCF_dom_corr(k,j)/(1+taxDIdom(k,j));
        T_FBCF_imp_Agg_corr(k)(j) = taxDIimp(k,j)*C_FBCF_imp_corr(k,j)/(1+taxDIimp(k,j));
    end
end
//--------------------------
//Sur la conso des Menages :
//--------------------------
for k=1:reg
    for j=1:sec
        THsld_Dom_corr(k)(j) = taxDFdom(k,j)*C_Hsld_dom_corr(k,j)/(1+taxDFdom(k,j));
        THsld_Imp_corr(k)(j) = taxDFimp(k,j)*C_Hsld_imp_corr(k,j)/(1+taxDFimp(k,j));
    end
end
//-------------------------------------------
//Sur la conso des Administrations Publiques :
//-------------------------------------------
for k=1:reg
    for j=1:sec
        TG_Dom_corr(k)(j) = taxDGdom(k,j)*C_G_dom_corr(k,j)/(1+taxDGdom(k,j));
        TG_Imp_corr(k)(j) = taxDGimp(k,j)*C_G_imp_corr(k,j)/(1+taxDGimp(k,j));
    end
end
//---------------------------------------
//Sur les Importations et Exportattions :
//---------------------------------------
for k=1:reg
    Tmtax_corr(k) = (mtax(k,:)').*m_fob_corr(k) ;
    Txtax_corr(k) = [xtax(k,:).*(Exp(k,:).*p(k,:))]'/p(1,7);
    Auto_TMX(k) = zeros(sec,1); 
end

//--------------------------------------------
//Concatenation des Matrices coté Ressources :
//--------------------------------------------
//on procède de la meme maniere,en prenant concatenation en ligne cette fois(au lieu de colonnes)


for j=1:reg
    //Consommations Intermédiaires
    CI_ressources(j) = [ CI_imp_Tot(j) ; CI_dom_Tot(j) ]; //(2P+2)*(P+1)
    ci_tot_ress(j) =  CI_ressources(j)(P+1,:) + CI_ressources(j)(2*P+2,:); // 1*(P+1)
    CI_Tot_ressources(j) = [ CI_ressources(j ); ci_tot_ress(j) ]; //(2P+3)*(P+1)

    //De meme pour la matrice des consommations de Facteurs
    C_Fact_Tot(j) = [ CFact_Agg(j) sum(CFact_Agg(j),'c'); 
    sum(CFact_Agg(j),'r')  sum(CFact_Agg(j))]; //(KK+1)*(P+1)

    //Concaténation de M_fob avec M_Trans (en prennant en compte les corrections), puis avec leurs totaux
    M(j) = [ m_fob_corr(j)' ; M_Trans_corr(j)' ]; //2*P
    M_Tot(j) = [ M(j) sum(M(j),'c') ; sum(M(j),'r') sum(M(j)) ]; // 3*(P+1)

    // Les matrices des Taxes
    T_Prod(j) = [ Tprod(j) ; sum(Tprod(j))]'; //1*(P+1)
    T_C_Fact(j) = [T_ConsFact_Agg(j) sum(T_ConsFact_Agg(j),'c');
    sum(T_ConsFact_Agg(j),'r') sum(T_ConsFact_Agg(j))]; //(KK+1)*(P+1);

    TCI_dom(j) = [T_CI_dom_Agg_corr(j) sum(T_CI_dom_Agg_corr(j),'c');
    sum(T_CI_dom_Agg_corr(j),'r') sum(T_CI_dom_Agg_corr(j))]; //(P+1)*(P+1)

    TCI_imp(j) = [T_CI_imp_Agg_corr(j) sum(T_CI_imp_Agg_corr(j),'c'); 
    sum(T_CI_imp_Agg_corr(j),'r') sum(T_CI_imp_Agg_corr(j))];  //(P+1)*(P+1)

    TCI(j) = [ TCI_dom(j); 
    TCI_imp(j);
    TCI_dom(j)(P+1,:)+ TCI_imp(j)(P+1,:)];   //(2P+3)*(P+1)

    T_FBCF(j) = [T_FBCF_dom_Agg_corr(j)  sum(T_FBCF_dom_Agg_corr(j));
    T_FBCF_imp_Agg_corr(j)  sum(T_FBCF_imp_Agg_corr(j));
    T_FBCF_dom_Agg_corr(j)+T_FBCF_imp_Agg_corr(j)   sum(T_FBCF_dom_Agg_corr(j)+T_FBCF_imp_Agg_corr(j))];  //3*(P+1)


    T_Hsld_dom(j) = [ THsld_Dom_corr(j)'  sum(THsld_Dom_corr(j))]; //1*(P+1)
    T_Hsld_imp(j) = [ THsld_Imp_corr(j)'  sum(THsld_Imp_corr(j))]; //1*(P+1)
    T_Hsld(j) = [ T_Hsld_dom(j) ; 
    T_Hsld_imp(j); 
    T_Hsld_dom(j)+T_Hsld_imp(j) ]; //3*(P+1)

    T_AP_dom(j) = [ TG_Dom_corr(j,:),sum(TG_Dom_corr(j,:))]; //1*(P+1)
    T_AP_imp(j) = [ TG_Imp_corr(j,:),sum(TG_Imp_corr(j,:))]; //1*(P+1)
    T_AP(j) = [ T_AP_dom(j) ; T_AP_imp(j); 
    T_AP_dom(j)+T_AP_imp(j) ]; //3*(P+1)


    T_M(j) = [  Tmtax_corr(j)' sum(Tmtax_corr(j)) ]; //1*(P+1)
    T_X(j) = [  Txtax_corr(j)' sum(Txtax_corr(j)) ]; //1*(P+1) 
    T_Auto_MX(j) = [  Auto_TMX(j)' sum( Auto_TMX(j))];

    Tot_Taxes(j) = [T_Prod(j)+T_C_Fact(j)(KK+1,:)+TCI(j)(2*P+3,:)+T_FBCF(j)(3,:)+T_Hsld(j)(3,:)+ T_AP(j)(3,:)+ T_M(j)+ T_X(j) + T_Auto_MX(j)]; //1*(P+1)

    Taxes(j) = [T_Prod(j); T_C_Fact(j); TCI(j); T_FBCF(j); T_Hsld(j); T_AP(j); T_M(j); T_X(j); T_Auto_MX(j) ;  Tot_Taxes(j) ]; //(17+KK+(2*P))*(P+1)
end
//*************************************************************  
for k=1:reg
    ///Concaténation des matrices coté Emplois:
    //Calcul de la Somme des emplois:
    Total_Emplois(k) =  ci_tot_emp(k) + C_Hsld_Tot(k)(:,3) + C_G_Tot(k)(:,3) + C_FBCF_Tot(k)(:,3) + X_Tot(k)(:,3);
    Emplois(k) = [ CI_Tot_emplois(k) C_Hsld_Tot(k) C_G_Tot(k) C_FBCF_Tot(k) X_Tot(k) Total_Emplois(k) ];

    ///Concaténation des matrices coté Ressources:
    //Calcul de la Somme des Ressources:
    Total_Ressources(k) =  ci_tot_ress(k) +  C_Fact_Tot(k)(KK+1,:) + M_Tot(k)(3,:) + Tot_Taxes(k) ;
    Ressources(k) = [  CI_Tot_ressources(k);  C_Fact_Tot(k);M_Tot(k); Taxes(k);Total_Ressources(k)];

    ///Calcul de l'erreur:
    Erreur(k) = (Total_Ressources(k)'-Total_Emplois(k))./Total_Ressources(k)';

    ///Le plafond d'erreur toléré est placé à 1
    a=%T;
    if abs(Erreur(k))<=1 then aaaaaa = 12; //ça sert a rien mais tampis
    else a=%F;
        disp('Attention! Le TES_Sortie_ImaclimR  de la Région '''+string(k)+''' est déséquilibré')
        disp(Erreur(k),'Erreur_Relative = ');
    end
end

//  if a==%T then disp('Tous les TES de l''année '+string(current_time_im)+'  sont équilibrés (avec une erreur(Ress-Empl/Ress) < 1)'); end

//Transfert des Résultats vers des fichiers Excel:
//exec('C:\Documents and Settings\Admin\Bureau\My_Max_Entropie\TESreconstue_Scilab_Excel.sce');
//exec(MODEL+'TES_excel_Sortie_ImaclimR.sce');

//exec(MODEL+'TESreconstue_Scilab_Excel.sce'); 
//disp('Si tu veux voir les TES va les chercher dans TES_Sortie_ImaclimR');
