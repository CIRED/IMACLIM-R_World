// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Julie Rozenberg, Nicolas Graves, Adrien Vogt-Schilb
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////////////////////////////////////////////
//		Preambule
/////////////////////////////////////////////////////////////////////////////////////////////////////
exec("preamble.sce");

wasdone = check_wasdone(liste_savedir);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//on récupère des vecteurs avec les valeurs des indices pour chaque scenario
[ind_climat,ind_EEI,ind_CCS,ind_NUC,ind_ENR,ind_bioEnergy]=combi2indices((1:size(matrice_indices,1))',matrice_indices);
numIndClimat = 1;
m_combi = 1:size(wasdone,1)';
m_combi = m_combi(wasdone)';

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
AR5DIR=MODEL+"matrices_ar5"+filesep();
mkdir(AR5DIR);
for savedir=liste_savedir'
    SAVEDIR=savedir;
    if check_wasdone(SAVEDIR)
        combi=run_name2combi(SAVEDIR);
        if combi < 100,blip="0";else blip="";end
        ldcsv("outputs_ar5"+blip+combi+".tsv");
        execstr("outputs_ar5 = outputs_ar5"+blip+combi);
        newT = customSmooth(outputs_ar5);
        write_csv(strsubst(string(newT(:,[5 10:10:TimeHorizon+1]-1)),'D','e'),AR5DIR+combi+"smoothOut_ar5.csv",";",".");
    end
end
