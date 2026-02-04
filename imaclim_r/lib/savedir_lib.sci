// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Julie Rozenberg, Florian Leblanc, Adrien Vogt-Schilb
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///SUMARY///
//read_matrice_indices
//get_nb_combis_etude

//combi2run_name
//run_name2combi
//combi2indices
//str2combi
//switch_indice_in_combi
//svdr2rid
//select_combi_to_compare

// get_dirlist
// check_wasdone
// check_tooManySubs
// classify_dirlist
// clean_savedir
// make_savedir
// adapt_classify2etude
// isfile
// testDirList
// ordering_dates

//==============COMBIS and ETUDE management =================
//==============OUTPUT management (make_savedir and so)==

//==============COMBIS and ETUDE management =================

function [matrice_indices, noms_des_indices] = read_matrice_indices( mat_path)
    //[matrice_indices, [noms_des_indices] ]= read_matrice_indices(  [mat_path] )
    //lis la matrice_indice dont le nom est , par defaut STUDY/matrice_ETUDE.tsv

    if argn(2)<1
        mat_path = STUDY+"matrice_"+ETUDE+".csv";
    end

    [ matrice_indices , txt ] = csvread( mat_path );

endfunction

function [nbMKT] = get_nbMKT(combi)
    //dirty (but worky) way to get nbMKT as a function of combi
    exec (STUDY+ETUDE+".sce");
endfunction

function nb_combis=get_nb_combis_etude(matrice_indices)
    //gets the number of possible scenarios, in order to create the adequate liste_savedir
    // [r c] = get_nb_combis_etude()
    // r = get_nb_combis_etude(1)
    // c = get_nb_combis_etude(2)

    nb_combis=max(matrice_indices(:,1));


endfunction

function [run_name]=combi2run_name(combi, noETUDEappend, suffix2combi)
    //Adds the number of the combi (transforms 1 to 001 and 15 to 015) to the run name
    if argn(2)<2
        noETUDEappend = %f;
	suffix2combi = '';
    elseif argn(2)<3
        suffix2combi = '';
    end 

    if noETUDEappend
        ETUDE=""; //This is a local variable
    end

    run_name=fit_combi(combi) + suffix2combi + "_"+ETUDE;

endfunction

function strcombi = fit_combi(combi)
    //transforme le nombre combi en une string avec des zeros au debut: 34->"034"; 123->"123"

    tmp = "";
    if combi<10 then tmp="00"; end
    if (combi<100)&(combi>=10) then tmp="0"; end
    strcombi=tmp+combi

endfunction

function [combi]=run_name2combi(run_name)

    //prend uniquement le run_name si l'input etait un chemin complet
    run_name = svdr2rid(run_name)

    //gets the number of the combi from the run name
    combi = strtod(run_name) //fonction scilab: renvoie le nombre au debut d"une string "224godzila6'->224

endfunction

function [varargout ] = combi2indices(combi, matrice_indices)
    //from a given combi number, this function returns the corresponding values of indices

    if ~isdef("matrice_indices") 
        matrice_indices = read_matrice_indices();
    end
    for i=1:size(matrice_indices,2)-1
        for j=1:size(combi,1)
            a=matrice_indices(matrice_indices(:,1)==combi(j),i+1);
            if a==[]
                hop(j,i)=%nan
            else
                hop(j,i)=a;
            end
        end
    end

    if argn(1)==1
        varargout(1)=hop
    else	
        for i=1:argn(1)
            varargout(i)=hop(:,i)
        end
    end

    if sum(isnan(hop))>0
        warning("combi2indices returned some nans")
    end

endfunction

function combi=str2combi(str,matrice_indices)
    //returns the scenario number from the string containing the indices
    combi = zeros(str)
    if argn(2)<2
        matrice_indices = read_matrice_indices();
    end
    tmp=string (matrice_indices);
    tmp2=strcat (tmp(:,2:$),"","c");
    tmp=[tmp(:,1),tmp2];
    for j=1:size(str,"*")
        combi(j)=evstr (tmp(find(tmp(:,2)==str(j),1)));
    end
endfunction

function combi_out = switch_indice_in_combi(combi_in,index_ranks,new_index_values,matrice_indices)
    //Returns combi_out representing same scenarios than combi_in, except for that indexes corresponding to index_ranks are turned to new_index_values. 
    //Usefull for getting a baseline, for instance, switching both ind_climat and ind_infra to 0.
    //Can also be used to get the same sceneario but with the alternative assumtpion, for, say, ind_develo.
    //INPUT : 
    //  combi_in : An integer column (n x 1). Combi numbers.
    //  index_ranks: Integers row (1 x m). Ranks of switched index in matrice_indices
    //  new_index_values (OPTIONAL) : Integer row (1 x m). New values for the index_rank_th indice.
    //              DEFAULT is (1-old_index_value), usefull for binary indices
    //  matrice_indices (OPTIONAL) a read_matrice_indices-like matrix (each row is a configuration of indexes)
    //              DEFAULT is read_matrice_indices()
    //
    //OUTPUT :  
    //  combi_out (n x 1) :  An integer column. Combi numbers. Can be empty.
    //
    //EXAMPLE (works when ETUDE is defined)
    // combi2indices((12:14)')
    // switch_indice_in_combi((12:14)',2)
    // combi2indices(switch_indice_in_combi((12:14)',2))
    // switch_indice_in_combi([1100; 1200],[1 4],[0 0]) //in study whenflexi, this would turn off climat and infra

    //PREMABULE 
    if size(combi_in,2)>1
        hc switch_indice_in_combi
        error("combi_in should be a column")
    end
    if size(index_ranks,1)>1 
        hc switch_indice_in_combi
        error("index_ranks should be a row")  
    end
    if argn(2)<4
        matrice_indices = read_matrice_indices() //this last function manages error with ETUDE
    end
    old_indexes = combi2indices(combi_in,matrice_indices)
    if argn(2)<3 //default value
        new_index_values = 1-old_indexes(:,index_ranks)
    else //checks size
        if or(size(new_index_values)~= size(index_ranks))
            hc switch_indice_in_combi //displays documentation of this function
            error("switch_indice_in_combi: improper argument size. Proper usage documented supra")
        end
    end


    //WORK
    new_indexes = old_indexes
    new_indexes(:,index_ranks) = ones(combi_in)*new_index_values  //the actual switch

    combi_out = str2combi( strcat(string(new_indexes),"","c"),matrice_indices)

    if combi_out==[]
        warning("combi_out is empty")
        disp(whereami())
    end
    if size(combi_out)~=size(combi_in)
        warning("some switched combis where not found. combi_out is NOT well ordered.")
        disp(whereami())
    end

endfunction

function [run_id] = svdr2rid(savedir) 
    //From an absolute savedir, returns a run_id and the same savedir (with / and \ managment)

    //a la sortie, le savedir ne finit pas pas un /
    savedir = pathconvert(savedir,%f);
    hop = strsplit(pathconvert(savedir,%f),filesep())
    run_id = hop($);

endfunction

function indice_eq=select_combi_to_compare(indice,set_comparisons,matrice_indices)
    //enables to make comparisons between all combi with indice=0 and the corresponding ones who were done with indice=1 or 2 
    //indice: rang de l'indice a comparer (souvent 1 pour climat par exemple)
    //set_comparisons : vecter genre [0 1] pour comparer les indice=O et indice=1

    [wasdone_etude]=adapt_classify2etude(OUTPUT,ETUDE);
    indice_eq=zeros(get_nb_combis_etude(),size(set_comparisons,"*")-1)==1;
    for combi=matrice_indices(matrice_indices(:,indice+1)==set_comparisons(1),1)'
        colonne=1;
        for i=set_comparisons(2:$)
            if wasdone_etude(combi)&wasdone_etude(switch_indice_in_combi(combi,indice,i,matrice_indices))
                indice_eq(combi,colonne)=%t;
                indice_eq(switch_indice_in_combi(combi,indice,i,matrice_indices),colonne)=%t;
                colonne=colonne+1;
            end
        end
    end
endfunction

//=============== OUTPUT management (make_savedir and so)================

function nam=get_dirlist(absOption,OUTPUT)
    //gets a list of directories in OUTPUT. If OUTPUT is not a valid path, no error and returns []
    //
    //OUTPUT: a string, path of the directory to scan. Relative path is OK. Default value is level_N-1 OUTPUT
    //[absOption]: a boolean. Default is %t. If %t nam is absolute (eg. begining with "e:/.." ) else there is only the dir name. 
    //nam: a string column: names of the directories (eventually absolute path) + /


    if argn(2)<1
        absOption=%t;
    end

    //error management
    if ~isdir(OUTPUT)
        disp( 'in get_listdir, """+OUTPUT+""" was not a dir');
        nam=[]
        return
    end

    //ACTUAL WORK

    //recuparation d'une liste de dossiers
    content = dir(OUTPUT);
    nam = content.name;
    nam = nam(content.isdir);

    //Intercepting bug when nam is empty (happens when OUTPUT is empty)
    if nam~=[] 
        nam=nam(strstr(nam,".svn")==emptystr(nam)); //keeps only the lines which do not include ".svn".
	if nam~=[] 
            nam=nam(strstr(nam,ETUDE)~=emptystr(nam)); //keeps only the lines which include the study name
            if absOption & size(nam,"*")>0
                nam = OUTPUT+nam ;
            end
        //proper writing of nam
            nam = pathconvert(nam,%t);
        end
    end
endfunction

function wasdone = check_wasdone(savedir_list)
    //Checks if a run is done (if IamDoneFolks.sav exists )
    //INPUTS
    //   savedir_list :  a string matrix. savedirs.
    //OUTPUTS: 
    //   wasdone :  a boolean matrix. for ecah savedir, %t if run was done

    wasdone = isfile(savedir_list+"save"+filesep()+"IamDoneFolks.sav")  | isfile(OUTPUT+savedir_list+"save"+filesep()+"IamDoneFolks.sav")
endfunction

function wastooManysubs = check_tooManySubs(savedir_list)
    //Checks if a run is toomanysubdivisions (if wastooManysubs.sav exists )
    //INPUTS
    //   savedir_list :  a string matrix. savedirs.
    //OUTPUTS: 
    //   wastooManysubs :  a boolean matrix. for ecah savedir, %t if run was too many subdivisions

    wastooManysubs = isfile(savedir_list+"save"+filesep()+"wastooManysubs.sav") | isfile(OUTPUT+savedir_list+"save"+filesep()+"wastooManysubs.sav")

endfunction

function [nam, combi, wasdone , wastooManysubs, isdoubledone]=classify_dirlist(absOption,OUTPUT)
    //Returns  as string matrix, sorted by combi the explixit paremeters
    //ignores .svn directory.
    //INPUTS : 
    // 
    //
    //head_comments get_dirlist

    //PREAMBLE: DEFAULT VALUES AND ERROR INTERCEPTION
    if argn(2)<1
        absOption=%t;
    end

    nam=get_dirlist(absOption,OUTPUT);

    //Case when nam is an empty dir
    if nam==[]
        combi= [];
        wasdone = [];
        wastooManysubs = [];
        isdoubledone= [];
        return
    end


    //ACTUAL WORK

    //////////////////
    //Clasification 
    wasdone = check_wasdone(nam)
    wastooManysubs = check_tooManySubs(nam)
    combi=zeros(nam);
    isdoubledone = zeros(nam)==1;

    //Getting combi
    for i=1:size(nam,"*");
        sd=nam(i);
        combi(i)=run_name2combi(svdr2rid( sd));
    end

    //Sorting everything by combi (which is probably the same than by name in get_listdir) -> it's not if combi is written in hexadecimal!!!
    [combi,k]=gsort(combi,"g","i");
    wasdone  = wasdone(k);
    nam      = nam(k);
    wastooManysubs = wastooManysubs(k);

    //Detecting isdoubledone
    for i=1:(size(isdoubledone,"*")-1)
        isdoubledone(i) = wasdone(i+1) & (combi(i)==combi(i+1));
    end

    //[nam, combi ,wasdone , isdoubledone]

    //Compatibility with a one-long lhs call
    if argn(1)==1
        title_ = [ "run_id" "combi" "double" "done" "2ManySub" ];
        nam = [title_; nam string(combi)  string(isdoubledone) string(wasdone ) string(wastooManysubs)]
    end
endfunction  

function report=clean_savedir(delDoubles, delNotFinished, deltooManySubs, OUTPUT)
    //Removes from OUTPUT the "bad" savedirs. Asks many confirmations before actually deleting.
    //INPUTS : 
    // delDoubles : boolean. Default %t. Removes the oldest of 2 or more savedir corresponding to the same combi
    // delNotFinished: boolean. Default %t. Removes not finished runs which are not toomanysubdivision.
    // deltooManySubs: boolean. Default is %f. Removes toomanysubdivisions runs. Yopu want to
    //               use this AFTER changing Dynamic or others, so the same run will not lead to toomanysubdivision again.
    // absOption : default %f. If %t, when asking for confiramtion, savedirs paths are writen from the root. Useful when used with OUTPUT.
    // OUTPUT: Sting . default is level_N-1 OUTPUT. If a valid path is providen, dir to clean, other than OUTPUT.
    //                    (e.g. an other models OUTPUT. CAUTION: older models (than 2009-2008-23) do not have toomanysubdivision detection)

    //PREAMBLE: DEFAULT VALUES AND ERROR INTERCEPTION

    if argn(2)<3
        deltooManySubs = %f;
    end
    if argn(2)<2
        delNotFinished = %t;
    end	
    if argn(2)<1
        delDoubles = %t;
    end	

    //ACTUAL WORK
    //Remembers the current directory
    lines_rmbr=lines();//remebering current lines 
    lines(0,10000);//great display

    //Getting the savedirs in sorties/ properties
    [nam combi wasdone wastooManysubs isdoubledone]=classify_dirlist(%t,OUTPUT)

    //List of savedir to delete and motivations
    report=[]; 

    //Optional removal of the not finished runs : neither wasdonde, neither toomanysubdivisions
    if delNotFinished
        waserror = ~(wasdone | wastooManysubs);
        //Gathering and explainine the not done runs
        if sum(waserror )>0 
            report = [ ""+nam(waserror), emptystr(nam(waserror))+'Not done (error)' ];
        end
    end

    //Optional removal of the too many subdivisions
    if deltooManySubs
        //Gathering and explainine the not done runs
        if sum(wastooManysubs )>0 
            report = [ ""+nam(wastooManysubs), emptystr(nam(wastooManysubs))+"Too many subdivisions" ];
        end
    end

    //Gathering and explaining the double done runs
    if delDoubles
        for i=find (isdoubledone)
            report = [ report;
            nam(i) "More recent : "+nam(i+1) ];
        end
    end

    //Informing and getting confirmation
    if size(report,"*")>0
        report=[ "TO DELETE" "MOTIVATION"; report]

        disp(report)
        userAnsw = input( "Please double-check and then confirm you want to delete those directories by typing ""y""" ,"s")
        if userAnsw=="y"
            if input( 'If you are sure, type ""y"" again ',"s")=="y"
                //Deleting the reported list
                for sd=(report(2:$,1)')
                    rmdir(sd,"s");
                end
                report(1,1)="DELETED"
            end
        else
            report ($+1,1)="nothing has been deleted"
            disp (report ($,1))
        end
    else
        disp "Nothing to clean";
    end
    //FINAL THINGS
    //previous lines mode
    lines(lines_rmbr(2),lines_rmbr(1)) 
endfunction

function [liste_savedir, tooManySubs]= make_savedir(OUTPUT,absOption)
    //*Inputs:
    //	**OUTPUT = OPTIONAL a directory (string) where the runs are saved. Level_0 OUTPUT is used when not provided 
    //  **[absOption]: OPTIONAL a boolean. Default is %t. If %t savedirs are absolute (eg. begining with "e:/.." ) else there is only the dir name. 
    //*Outputs: liste_savedir and tooManySubs : string columns saved in VAR/liste_savedir.sav and VAR/liste_savedir
    //                                          List of succesfull runs
    //                                          List of toomanysubdivision runs

    //PREAMBLE
    //Remembers the current directory
    prev_wkdr= pwd(); 
    cd(OUTPUT);
    // DEFAULT VALUES AND ERROR INTERCEPTION
    if argn(2)<2
        absOption = %t;
    end

    //ACTUAL WORK
    tooManySubs = emptystr(get_nb_combis_etude(),1);
    liste_savedir=tooManySubs;

    //Getting the savedirs in sorties/ properties
    [nam combi wasdone wastooManysubs isdoubledone]=classify_dirlist(%t,OUTPUT);

    //tooManySubs or liste_savedir:
    for ic=find(~isdoubledone & combi>0)
        if wastooManysubs (ic) //too many subs are stored so they are not re-done
            tooManySubs  ( combi(ic) ) = nam(ic);
        elseif wasdone(ic) //successfull run
            liste_savedir( combi(ic) ) = nam(ic);
        end
    end

    //Filling the empty strings
    tooManySubs(tooManySubs=="")="NOTADIR";
    liste_savedir(liste_savedir=="")="NOTADIR";
    tooManySubs(tooManySubs==" ")="NOTADIR";
    liste_savedir(liste_savedir==" ")="NOTADIR";

    //FINAL THINGS
    cd(prev_wkdr)
endfunction

function [wasdone_etude]=adapt_classify2etude(OUTPUT,ETUDE)
    wasdone_etude=zeros(get_nb_combis_etude(1,ETUDE),3)==1;
    [nam combi wasdone isdoubledone]=classify_dirlist()
    for ic=find(combi>0)
        if wasdone(ic)
            wasdone_etude( combi(ic) ) = %t;
        end
    end
    wasdone_etude=matrix (wasdone_etude,-1,1);
endfunction

//usefulle for scilab.5.1.1
// function isit = isfile(pathes)
// isit = (zeros (pathes)==1);
// for i_isfile = 1: size(pathes, "*")
// isit(i_isfile) = fileinfo (pathes(i_isfile)) ~= []
// end   
// endfunction


function outDirList = testDirList()
    [ nam , combi, wasdone , wastooManysubs , isdoubledone ] = classify_dirlist();
    outDirList = [ combi , wasdone , wastooManysubs, isdoubledone , nam , combi * 0 ] ;

    for dim1 = 1:size(outDirList,1)
        temp = tokens(outDirList(dim1,5),sep);
        outDirList(dim1,5) = temp($);
        try
            load(nam(dim1)+"save"+sep+"last_done_year.sav");
        catch
            last_done_year = 0;
        end
        outDirList(dim1,6) = string(last_done_year);
    end

    printf("\ncombi   done    subs    double  dir                                   year\n");

    for dim1 = 1:size(outDirList,1)
        for dim2 = 1:6
            printf("%s\t",outDirList(dim1,dim2));
        end
        printf("\n");
    end

    printf("\nThe combi that have run:\n");
    for temp = unique(combi(wasdone))
        printf("%i ",temp);
    end

    printf("\n\n");

endfunction
///////////////////////////////////////////////////////////////////////////////////////////////////////
function dates =  get_numerical_dates( name_dir_list, study_name)
    // return the dates of a list of directory names
    // name_dir_list is a list of directories
    // study_name is the name of the study like appearing in the directory list name_dir_list
    subs_list = list('_', 'h', 'min', 's');
    dates = zeros( name_dir_list) ;
    for itt = 1:max(size(dates))
        daty = strsplit( name_dir_list(itt), study_name,2) ;
        for elt = subs_list
            daty = strsubst( daty($), elt, '') ;
        end
        dates(itt) = eval(daty) ;
    end
endfunction
///////////////////////////////////////////////////////////////////////////////////////////////////////
function ordered_indices = ordering_dates_indices( name_dir_list, study_name )
    // return the classified indiced of dates from the latest to the oldest
    // name_dir_list is a list of directories
    // study_name is the name of the study like appearing in the directory list name_dir_list
    dates = get_numerical_dates( name_dir_list, study_name) ;
    [dates, ordered_indices] = gsort( dates, 'g', 'd') ;
endfunction
