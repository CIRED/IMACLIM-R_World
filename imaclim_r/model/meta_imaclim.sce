/////////////////////////////////////////////////////////////////////////////////////
////								META-IMACLIM-R								/////
////  Permet d'exécuter plusieurs fois imaclim-r en fonction 					/////
////					des *combis* pertinentes dans le cadre d'une *ETUDE*	/////
/////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////
//		PREAMBULE
///////////////////////////////////////////////////////////////////////////////////////

disp "======META_IMACLIM======"

exec("preamble.sce");

//////////////////////////////
// **USER CHOICE** : combis to run with or without climate policies

combinaisons = [ 227, 228, 229] ; 
/////////////////////////////////////////////////////
//		Execution des scenarios à la suite

if size(combinaisons,"*")>0 
    disp("Starting runs");
    disp(mydate()) //displays user friendly date
    for combi=combinaisons
        [wasError,wastooManysubs,SAVEDIR]=exec_imaclim(combi,liste_savedir,tooManySubs,%t); 
        if ~wasError
            liste_savedir(combi) = SAVEDIR;
        elseif wastooManysubs
            tooManySubs(combi)   = SAVEDIR;
        end
    end 

end

/////////////////////////////////////////////
//		Calcul de CVI
////////////////////////////////////////////////////
compute_cvi(liste_savedir(1),liste_savedir(1),3,%t);

disp("nu meta_imalcim is done")
say("OUTPUT")
disp("winopen(OUTPUT)") 
mkalert("done")

