// pour faire fonctionner ce script:
// executer preamble.sce
// changer repertoire pour "model"

//list_of_combi=list(180,181,182,183,185,186,187,188,189,190,191,192,193,380,381,382,383,385,386,387,388,389,390,391,392,393);
list_of_combi=list(194,195,394,395)

for i_combi=1:length(list_of_combi)
    //exec("extraction_sectoral_GDP.sce");
    combi=list_of_combi(i_combi);
    
    SAVEDIR = liste_savedir(combi);

    exec("extraction_sectoral_GDP.sce");
end
