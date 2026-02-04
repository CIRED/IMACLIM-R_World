// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function memTxt = checkMemory()

    [ localVarNames  , localVarMem  ] = who( "local"  );
    [ globalVarNames , globalVarMem ] = who( "global" );

    sumLocal  = sum(localVarMem);
    sumGlobal = sum(globalVarMem);
    sumTotal  = sumLocal + sumGlobal;

    varNames = cat(1,localVarNames +"; local",..
    globalVarNames+";global",..
    "sumLocal;subTotal",..
    "sumGlobal;subTotal",..
    "sumTotal;total");

    varMem   = [ localVarMem ; ..
    globalVarMem ; ..
    sumLocal ; ..
    sumGlobal ; ..
    sumTotal ];

    [ sortedVarMem , sortIndex  ] = gsort( varMem * 16 / 1e6 );

    memTxt  = varNames(  sortIndex  ) + ";" + sortedVarMem;

endfunction
