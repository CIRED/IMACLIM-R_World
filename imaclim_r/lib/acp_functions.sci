// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function cov=covariance(A)
  // vecteur (1,p) des moyennes des colonnes (=variables)
  moyenne = mean(A,"r");			
  // nombre de lignes dans la matrice A = nbre d'individus
  n = size(A,"r")				
  // matrice recentrée 
  Acent = A - ones(n,1)*moyenne; 	
  // matrice de covariance (Remarque: on a divisé par n-1 et non par n)
  cov=(Acent'*Acent)/(n-1);			
endfunction

function c=correlation(A)
  cov=covariance(A);
  // vecteur contenant l'inverse des écarts-types
  ectinv=(1)./sqrt(diag(cov));	
  // matrice des corrélations
  c=diag(ectinv)*cov*diag(ectinv); 
endfunction


function [c]=valprop(A); 
//renvoie les valeurs propres ordonnées de manière décroissante
  [Diag,Base]=bdiag(A);	// diagonalisation	
  // classement décroissant des valeurs propres
  c=sort(diag(Diag));                		
endfunction


function c=vectprop(A); 
// renvoie les vecteurs propres de A 
// classés par valeurs propres corresp décroissantes
  [Diag,Base]=bdiag(A);
  // diagonalisation
  if Base(:,1)==-abs(Base(:,1)) then Base=-1*Base; end 
  // afin que les coef du 1er vect prop ne soient pas tous < 0.
  [Valpr,k]=sort(diag(Diag));
  // classement décroissant des valeurs propres
  c = Base(:,k);
endfunction

function c=reduire(A) 
// permet de centrer et de réduire la matrice A
  moyenne = mean(A,"r");         
  //vecteur (1,d) des moyennes des colonnes(=variables)
  cov=covariance(A);
  n = size(A,"r");             			
  //nombre de lignes dans la matrice A=nbre d'individus
  Acent = A - ones(n,1)*moyenne; 			
  // A centre
  c=Acent*(diag((1)./sqrt(diag(cov)))); 
endfunction

function c=acpindiv(A);	
//Coordonnées des projetés des individus 
// dans la base des vecteurs propres
  mat_cor=correlation(A);
  X=reduire(A);
  VectP=vectprop(mat_cor);
  // les vecteurs propres 
  c = X*VectP;
  // nouvelles coordonnees 
endfunction


function c=acpvar(A);	
//Coordonnées des variables dans le cercle des correlations
  mat_cor=correlation(A);
  X=reduire(A);
  VectP=vectprop(mat_cor); 	
  // les vecteurs propres 
  ValP=valprop(mat_cor); 		
  // les valeurs propres
  c = VectP*diag(sqrt(ValP));  		
endfunction


function nuage(Coord,i,j);								
//projection des individus dans le plan i-j
  xset("font",4,3);
  deltax=(max(Coord(:,i))-min(Coord(:,i)))/20;
  xmin=min(Coord(:,i))-deltax;
  xmax=max(Coord(:,i))+deltax;
  deltay=(max(Coord(:,j))-min(Coord(:,j)))/20;
  ymin=min(Coord(:,j))-deltay;
  ymax=max(Coord(:,j))+deltay;
  //  isoview(xmin,ymin,xmax,ymax);
  titre="Projection sur le plan "+string(i)+"-"+string(j)
  // afficher les individus
  plot2d(Coord(:,i),Coord(:,j),-3,"031",rect=[xmin,ymin,xmax,ymax]);	
  n = size(Coord,"r");  
  for l=1:n,
    xstring(Coord(l,i),Coord(l,j),string(l));
  end
  xtitle(titre);
endfunction


function cercle(Coord,i,j)
  xset("font",4,3);
  Leg=['X1','X2','X3','X4','X5','X6'];
  taille=6;
  
  V=Coord(:,[i,j]); 
  V = V'.*.[1,0]; 	                   
  // insertion de l'origine
  V = V';
  
  p=size(V,"r");
  //square(-1,-1,1,1);
  t=[0:0.05:2*%pi]';
  plot2d(cos(t),sin(t),1,"040");   
  xsegs([-1,1],[0,0]);
  xsegs([0,0],[-1,1]);
  titre="Cercle des corrélations sur le plan "+string(i)+"-"+string(j);
  plot2d(V(:,1),V(:,2),5*ones(1,p),"000");   
  for k=1:taille, xstring(V(2*k-1,1),V(2*k-1,2),Leg(k));end
endfunction


function barycentres(Coord,C,i,j);
// preparation du graphique  
  xbasc();           								
  deltax=(max(Coord(:,i))-min(Coord(:,i)))/20;
  xmin=min(Coord(:,i))-deltax;
  xmax=max(Coord(:,i))+deltax;
  deltay=(max(Coord(:,j))-min(Coord(:,j)))/20;
  ymin=min(Coord(:,j))-deltay;
  ymax=max(Coord(:,j))+deltay;
  plotframe([xmin,ymin,xmax,ymax],[2,10,2,10],[%f,%f],..
			["Projection sur le plan "+string(i)+"-"+string(j),"",""]);
  plot2d([0,0],[ymin,ymax],2,"000");
  plot2d([xmin,xmax],[0,0],2,"000");
  
  // modalités
  mod=['C','Z'];
  
  // representation des individus suivant leur modalite
  for k=mod,
	I=find(C==k);
	B=mean(Coord(I,:),"r");
	B=B'.*.[1,0];
	B=B'
	plot2d(B(:,i),B(:,j),5,"000");
	plot2d(B(:,i),B(:,j),-1,"000");
	xset("font",2,3);
	xstring(B(1,i),B(1,j),k);
	xset("font",2,1);
	for l=I,
	  xstring(Coord(l,i),Coord(l,j),k);
	end
  end
endfunction
