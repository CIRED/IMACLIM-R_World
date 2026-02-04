// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Julie Rozenberg
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// level          = 0.9;
// leadEv         = 0.98; //(équivaut à une baisse de -0.02)
// EIt0           = 1.2;
// EIleadt0       = 1;
// offset         = 0;
// X              = 10;
// Y              = 0.811778793;
// EIleadt0plusX  = EIleadt0*leadEv^X;
// iter = 1;

function [muEi ,v ,info] = calibreMu(level,leadEv,EIt0,EIleadt0,EIleadt0plusX,offset,X,Y,iter)
	// 1. Fonction qui à EIt-1 associe EIt
  function [EIt]=fEIit(EIt_1,t)
    EIleadt_1 = EIleadt0*leadEv^(t-2);
    EIt = EIt_1 * leadEv / level*(level*muEi^(t-offset)+ EIleadt_1/EIt_1 * (1-muEi^(t-offset)));
  endfunction

  // 2. Fonction qui à EIt et X associe EItplusX (pour un suiveur)
  function [EItplusX,X,iter]=fEItPlusX(EIt,X,iter)
    iter=iter+1;
    EItplus1 = fEIit(EIt,iter);
    if X==1 then
    	EItplusX = EItplus1;
    else 
    	EItplusX = fEItPlusX(EItplus1,X-1,iter);
    end
  endfunction

  // 3. Fonction qui donne l'équation en muEi sous la forme f(muEi)=0
  function [eqn]=eqnMu(muEi)
  	EIleadt0plusX=EIleadt0*leadEv^X;
    EIit0plusX = fEItPlusX(EIt0, X,iter);
	eqn = EIleadt0plusX/level-EIit0plusX - Y*(EIleadt0/level-EIt0);
  endfunction

[muEi ,v ,info]=fsolve(1,eqnMu);
endfunction


function [muEi ,v ,info] = calibreMu_n(level,leadEv,EIt0,EIleadt0,EIleadt0plusX,offset,X,Y,iter)
	// 1. Fonction qui à EIt-1 associe EIt
  function [EIt]=fEIit0plust(EIt0plust_1,t)
    EIleadt_1 = EIleadt0*leadEv^(t-1);
    EIt = EIt0plust_1 * leadEv / level*(level*muEi^(t-offset)+ EIleadt_1/EIt0plust_1 * (1-muEi^(t-offset)));
  endfunction

  // 2. Fonction qui à EIt et X associe EItplusX (pour un suiveur)
  function [EItplusX,X,t]=fEItPlusX(EIt,X,t)
    t=t+1;
    EIt0plustplus1 = fEIit0plust(EIt,t);
    if X==1 then
    	EItplusX = EIt0plustplus1;
    else 
    	EItplusX = fEItPlusX(EIt0plustplus1,X-1,t);
    end
  endfunction

  // 3. Fonction qui donne l'équation en muEi sous la forme f(muEi)=0
  function [eqn]=eqnMu(muEi)
  	EIleadt0plusX=EIleadt0*leadEv^X;
    EIit0plusX = fEItPlusX(EIt0, X,iter);
	eqn = EIleadt0plusX/level-EIit0plusX - Y*(EIleadt0/level-EIt0);
  endfunction

[muEi ,v ,info]=fsolve(1,eqnMu);
endfunction
