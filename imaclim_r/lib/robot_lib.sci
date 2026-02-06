// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Julie Rozenberg, Adrien Vogt-Schilb, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//SUMMARY
//
//exec_imaclim
//diff_output


function [wasError,wastooManysubs,SAVEDIR]=exec_imaclim(combi,liste_savedir,tooManySubs,ignoreOldTries);
    //Executes Imaclim, with no need of clearing, as variables in the function disappear when the function terminates
    //This to be used for all types of combis, except for emissions-prescripted runs.
    //Emissions-prescripted runs are done with exec_stab_imaclim
    // INPUTS
    //      combi : provide this INTEGER compatible with level_0 ETUDE variable defined in preamble
    //      ignoreOldTries : Boolean. OPTIONAL. If %t, liste_savedir and tooManySubs are ignored.
    //                  Default is %f;
    //                  Can be useful e.g provided as 'or(combi==[1 4 12])'
    //      liste_savedir : if provided, checks if run relative to combi already exists in liste_savedir. 
    //                      if so, nothing is runed and returns [%f,%f,SAVEDIR]
    //      tooManySubs : if provided, checks if run relative to combi already exists in tooManySubs. 
    //                      if so, nothing is runed and returns  [%t,%f,SAVEDIR]
    //                      This is to be changed to [%t,%t,SAVEDIR] when make_savedir will be really toomanysubs-friendly
    // OUTPUTS
    //      wasError :      Boolean. True if execution was not done
    //      wastooManysubs :Boolean. True if res_dyn_loop broke and said too Many Subdivionss 
    //      SAVEDIR :       String. The savedir

    //DEFAULT VALUES
    if argn(2)<4
        ignoreOldTries = %f
    end

    //ALLREADY RUN CHECKS
    if ~ignoreOldTries
        if argn(2)>1
            if isdir(liste_savedir(combi))
                wasError=%f; wastooManysubs=%f; SAVEDIR=liste_savedir(combi);
                disp( '!!exec_imaclim ignores combi '+combi+' present in liste_savedir. more info? copypaste next line.')
                disp( 'head_comments exec_imaclim') 
                return
            end
        end
        if argn(2)>2
            if isdir(tooManySubs(combi))
                wasError=%t; wastooManysubs=%f; SAVEDIR=tooManySubs(combi);
                disp( '!!exec_imaclim ignores combi '+combi+' present in tooManySubs. more info? copypaste next line.')
                disp( 'head_comments exec_imaclim') 
                return
            end
        end
    end
    
    ebi_prev_dir = pwd(); //remembers curent dir (be carrefull: do not use a variable name used by imaclim
    
    //ACTUAL WORK
    metaBeepOn =%f;
    chdir (MODEL);
    
    if exec('imaclimr.sce','errcatch');
        wasError = %t; //wasError can also be switch true by imaclim itself
        if ~isdef('wastooManysubs') //in case an error occurs in imaclimr.sce before defining wastooManysubs
            wastooManysubs = %f;
        end
    end
    
    //here we define output in care of an error 
    if wastooManysubs | wasError
        if ~isdef('SAVEDIR')
            SAVEDIR = 'ERROR-NOTADIR';
        end
    end
    chdir (ebi_prev_dir)
endfunction

function y=diff_output (c1,c2,sens)
    //diff_output(1,2)  build the output by comparing combi 1 to combi 2

    if argn(2)<3
        sens = 1d-4;
    end

    ldcsv ("output",liste_savedir(c1))
    o1 = output;
    ldcsv ("output",liste_savedir(c2))
    o2 = output;

    outname = "out"+c1+"vs"+c2

    execstr ( outname+" = clean( o1./( %eps + o2) - 1, sens);");
    execstr (outname+"(o1==0)=0")

    mkcsv(outname,OUTPUT,"nocombi")
    y = evstr(outname)
endfunction
