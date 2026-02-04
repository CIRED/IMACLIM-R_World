// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//  chdir(MODEL+'\GTAP_Meriem');
//  Aggregations = input("Entrez le nom du fichier des aggregations: ","s");
  Aggregations = "gtp12_12.agg";
  Txt = read(Aggregations,-1,1,'(a)');
	
  Section = grep(Txt,'=');

  P = Section(3)-Section(2)-1; // le nouveau nombre de Biens 
  N = Section(7)-Section(6)-1; // le nouveau nombre de Régions
  K = Section(11)-Section(10)-1; // le nouveau nombre de Facteurs

  Masc1 = zeros(87,N);
  Masc2 = zeros(P,57);

//Matrices Textes des nouveaux Biens/Régions/Facteurs
  B = part(Txt(Section(2)+1:Section(3)-1),[1:13]);
  R = part(Txt(Section(6)+1:Section(7)-1),[1:13]);
  Fact = part(Txt(Section(10)+1:Section(11)-1),[1:13]);

//Matrices Textes des enciens  Biens/Régions/Facteurs
  b = part(Txt(Section(4)+1:Section(5)-1),[50:62]);
  r = part(Txt(Section(8)+1:Section(9)-1),[50:62]);
  f = part(Txt(Section(12)+1:Section(13)-1),[50:62]);

KK=5;
 
                  //Construction des TES//


// chdir('E:\IMACLIMR\Bresil'); //La ou se trouvent les fichiers Excel
//chdir('C:\Documents and Settings\Admin\Bureau\TESentropik'); //La ou se trouvent les fichiers Excel
//chdir('C:\Documents and Settings\Admin\Bureau\TES_Sortie_ImaclimR');

 Vide1=[]; for ii=1:((2*P)+4), Vide1(ii)=' '; end Vide1=(Vide1)';//vect ligne 
 Vide2=[]; for ii=1:(3*P+2*KK+32), for j=1:(P+16), Vide2(ii,j)=' ';end end

//Coté Emplois
  Titre1 = [' ',' ',B','Tot',B','Tot',' ','1','1',' ','1','1',' ','FBCF','FBCF',' ','1','1',' ',' '];
  Titre2 = [' ',' ','Imp',Vide1(1:P),'Dom',Vide1(1:P),'Tot CI','Imp','Dom','Tot Hsld','Imp','Dom','Tot G','Imp','Dom','Tot FBCF','X','Transport','Tot X','Tot Emplois'];
  Titre3 = ['CI',Vide1,'C_Hsld',Vide1(1:2),'C_AP',Vide1(1:2),'FBCF',Vide1(1:2),'X',Vide1(1:3)];
  Titre_Emplois = [Titre3;Titre2;Titre1 ];

//Coté Ressources
  //Pour TES entier:
  Tr1 = [B;'Tot';'Tot CI';'Cons Fact';Fact;'Tot VA';'M_FOB';'Transport';'Tot';'T_Prod';'T_Fact';Fact;'Tot';'T_CI';B;'Tot';B;'Tot';'Tot TCI';'T_FBCF';'dom';'imp';'Tot';'T_CHsld';'dom';'imp';'Tot';'T_CAP';'dom';'imp';'Tot';'Mtax';'Xtax';'T_Auto_MX';'Tot Taxes';''];

//  Tr2 = ['dom';(Vide1(1:(P+1)))';'VA';(Vide1(1:(KK+1)))';'M';' ';' ';'Taxes';(Vide1(1:(KK+3)))';'dom';(Vide1(1:P))';'imp';(Vide1(1:P))';(Vide1(1:6))';(Vide1(1:6))';(Vide1(1:4))';' '; 'Tot Ressources'];

  Tr2 = ['dom';(Vide1(1:(P+1)))';'VA';(Vide1(1:(KK+1)))';'M';' ';' ';'Taxes';(Vide1(1:(KK)))';' ';' ';' ';'dom';(Vide1(1:P))';'imp';(Vide1(1:P))';(Vide1(1:6))';(Vide1(1:6))';(Vide1(1:4))';' '; 'Tot Ressources'];
  
  //Pour Tableau des Ressources seul:
  Ttr1 = [ ' ';B;'Tot';Tr1];
  Ttr2 = [ 'CI';'imp';(Vide1(1:P))';Tr2];

 

//Pour chaque région "j";on associe un Tableau "Emplois", un Tableau "Ressources" et le TES:
 
  Tab_Empl=list();
  Part= list();
  Ress1=list(); Tab_Ress1=list(); 
  Ress2=list(); Tab_Ress2=list();
  Tab_Empl_err = list();
  TES=list();

  for j=1:N
      //Emplois:
      Tab_Empl(j) = [Titre_Emplois;(Vide1(1:(P+1)))',[B;'Tot'],string(Emplois(j))];      
     // Yo=[];
      //for ii=1:size(Tab_Empl(j),'r')
          //Yo = [Yo;strcat(Tab_Empl(j)(ii,:),',')];
      //end
     //form='(a)'; 
     //write('Emplois'+string(j)+'.tsv',Yo,form); 

      form='';
      for ii=1:(size(Tab_Empl(j),'c')- 1)
          form=form + '%s,' ;
      end
      form=form+'%s\n';
      //======================================
      //Debut creation des fichier Emplpois"j"
      //======================================      
      
      //u=mopen('Emplois'+string(current_time_im)+'_'+string(j)+'.tsv' ,'w');
      //mfprintf(u,form,Tab_Empl(j));
      //mclose(u);

      //======================================
      //Fin creation des fichier Emplpois"j"
      //======================================


     //Ressources:
      Part(j) = [ Vide1(1:(P+1));string(C_Fact_Tot(j));string(M_Tot(j));string(T_Prod(j));Vide1(1:(P+1));string(T_C_Fact(j));Vide1(1:(P+1));string(TCI(j));Vide1(1:(P+1));string(T_FBCF(j));Vide1(1:(P+1));string(T_Hsld(j));Vide1(1:(P+1));string([T_AP(j); T_M(j); T_X(j);T_Auto_MX(j); Tot_Taxes(j) ]);string(Total_Ressources(j))];

      ///Pour Tableau des Ressources Seul:
        Ress1(j) = [[B','Tot'];string(CI_Tot_ressources(j));Part(j)];
        Tab_Ress1(j) = [ Ttr2,Ttr1,Ress1(j)];  
        toto=[];
        for ii=1:size(Tab_Ress1(j),'r')
            toto = [toto;strcat(Tab_Ress1(j)(ii,:),',')];
        end

      //======================================
      //Debut creation des fichier Ressouces"j"
      //======================================      
        //write('Ressources'+string(current_time_im)+'_'+string(j)+'.tsv',toto); 
      //======================================
      //Fin creation des fichier Ressouces"j"
      //======================================      



      //Pour TES entier:
      Ress2(j) = [string(CI_dom_Tot(j)); string(ci_tot_ress(j))  ;Part(j)];
      Tab_Ress2(j) = [[Tr2,Tr1,Ress2(j)];['Erreur = ','Ress-Empl',string(Erreur(j)')]];
  
      [ ' ' ; 'Erreur = Ress-Empl' ; string(Erreur(j)) ];

      Tab_Empl_err(j) = [ Tab_Empl(j),[ 'Erreur =';'Ress-Empl' ; ' ' ; string(Erreur(j)) ]];

      //les TES:
        TES(j) = [  Tab_Empl_err(j) ;  [Tab_Ress2(j) , Vide2]  ];
       // to=[];
        //for ii=1:size(TES(j),'r')
        //to= [to;strcat(TES(j)(ii,:),',')];
        //end
       // write('TES'+string(j)+'.tsv',to); 

      form='';
      for ii=1:(size(TES(j),'c')- 1)
          form=form + '%s,' ;
      end
      form=form+'%s\n';
      
      //v=mopen('TES'+string(current_time_im)+'_'+string(j)+'Hybrid'+'.tsv' ,'w');
v=mopen('TES'+'_'+string(j)+'year'+string(current_time_im+1)+'.tsv' ,'w');
      mfprintf(v,form,TES(j));

      mclose(v);
 
  end













