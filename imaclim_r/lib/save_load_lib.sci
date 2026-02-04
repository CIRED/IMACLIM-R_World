// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Adrien Vogt-Schilb, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//==================SAVING AND LOADING VARIABLES ============
// mkcsv
// ldcsv
// mksav
// ldsav
// trytosave
// bigsave
// dir_unhide
// dir_hide
// bigsave_del

function mkcsv(varname,SAVEDIR,varargin)
    //Saves the variable whos name is varname (given as a string) in pseudoCSV format to SAVEDIR+varname.tsv
    //SAVEDIR is optional (level_N-1 variable SAVEDIR is used instead)

    
//Options default values
    forcem_ =%f;
    append_combi = %t;

//Lecture des options    
    if argn(2)>2
        for imk = 1:size(varargin)
            select varargin(imk)
            case "forcem"
                forcem_ = %t //oblige mkcsv a appeller m_machin plutot que machin le csv
            case "nocombi"
                append_combi = %f //ne rajoute pas le numero de combi a la fin
            end
        end
    end
    
    //attention de bien garder isdef et pas argn(2): mkcsv est appele tel quel, et on veut qu'il utilise le SAVEDIR courant
    if ~isdef("SAVEDIR")
        SAVEDIR=""
    end
    if ~isdef("combi") //pour le ca sou on appendcombi. Si savedir est vide, ça va retourner 0
        combi = run_name2combi(SAVEDIR)
    end
    
    //Correcting frequent errors
    varname= stripblanks (varname,%t); //supprime les tab et les espaces
    varname= strsubst (varname,".tsv","");
    varname= strsubst (varname,".csv","");
    if varname==[] | varname=="" then 
        return
    end
    if SAVEDIR=="", 
        disp( "i""m saving in current directory : "+pwd(),varname,"mkcsv: warning, SAVEDIR is empty! when trying to save next variable:"); 
        mkalert("error");
    end
    SAVEDIR = pathconvert(SAVEDIR,%t)
        
        //checking if the variable whos name is varname is a string
        if evstr ("type("+varname+"(1))" )==10 //it is a string
            isString = %t
        else //assume it is a number
            isString = %f
        end
        
        filename = varname;
        //vire le "m_" sur les noms des fichiers pour 
        if ~forcem_ & part(varname,1:2)=="m_"
            filename = part(varname,3:length(varname))
        end        
        //zjoute le numero de la combi au nom du tsv
        if append_combi
           filename = filename+fit_combi(combi);
        end        
                
        //standard case
        nb_iter=0;
        ier=1;
        
        while ier~=0 & nb_iter<5 do
            sleep (1+nb_iter*50); //Dans cette boucle, on laisse le temps au disque dur d'être disponible et on réessaye l'écriture
            if isString
                ier = execstr ( "write_csv("+varname+",SAVEDIR+filename+"".tsv"");","errcatch" );
            else
                ier=execstr ( "fprintfMat(SAVEDIR+filename+"".tsv"","+varname+",""%1.4g""+ascii(9));" ,"errcatch" );
            end
            nb_iter = nb_iter+1;
        end
        if ier~=0, disp("!mkcsv could  not save " + varname); mkalert("error"); disp(lasterror(%f));
            if ier==240, disp("Check attribs of SAVEDIR (look for read only)");disp("winopen(OUTPUT)"); end
        elseif nb_iter>1, disp("!mkcsv just saved us form an error: ier "+ ier+" nb_iter: "+nb_iter +"varname :"+varname); end

endfunction

function ldcsv(varname,SAVEDIR)
    //Loads the variable whos name is varname (given as a string) in CSV format from SAVEDIR+varname.tsv
    //SAVEDIR is optional (level_N-1 variable SAVEDIR used instead)
    //may correct level_N-1 variable SAVEDIR (adds / at the end) if SAVEDIR is not given as an argument

    //forcem has to be implemented

    //Correcting frequent errors
    varname= stripblanks (varname,%t);
    varname= strsubst (varname,".tsv","");
    varname= strsubst (varname,".csv","");
    if SAVEDIR=="",
        disp( "i""m saving in current directory : "+pwd(),varname,"ldcsv: warning, SAVEDIR is empty! when trying to load next variable:"); mkalert( "error")
    end
    SAVEDIR = pathconvert(SAVEDIR,%t)

    combi = run_name2combi(SAVEDIR);

    if varname==[] | varname=="" then return; end

    //tsv and csv compatibility
    ext = ".tsv"
    if ~isfile(SAVEDIR+varname+ext) & isfile(SAVEDIR+varname+".csv")
        ext = ".csv"
    end
    if ~isfile(SAVEDIR+varname+ext) & isfile (SAVEDIR+varname+fit_combi(combi)+ext)
        ext = fit_combi(combi)+ext;
    end


    //actual job
    M=fscanfMat(SAVEDIR+varname+ext)
    execstr ("["+varname+"] =return(M)");

endfunction

function mksav(varname,calibString,SAVEDIR)
    //Saves the variables whos name are varname(i) (given as strings) in Scilab binar format to SAVEDIRsave/varname(i).sav
    //if used with "calib", saves in CALIB instead of SAVEDIR/save
    //SAVEDIR is optional (level_N-1 variable SAVEDIR used instead)
   
    varname= stripblanks (varname,%t); 
    varname= strsubst (varname,".sav","");
    if varname==[] then return; end

    if argn(2)<2
        calibString="";
    end

    if ~isdef("SAVEDIR")
        SAVEDIR="NOTADIR"
    end

    if isdir(calibString)
        SAVEDIR = calibString
        calibString =""
    end

    //comparing sizes
    if size(varname,"*")~=size(calibString,"*")
        if size(calibString,"*")==1 
            calibString=emptystr(varname) + calibString; //on autorise mksav([var1 var2 var3],"calib")
        else
            disp("!! mksav("+varname+","+calibString+"): sizes don-t match"); mkalert("error"); return;
        end
    end

    //Correcting frequent errors
    if SAVEDIR=="" 
        if calibString~="calib"
            disp( "i""m saving in current directory : "+pwd(),"mksav: warning, SAVEDIR is empty! when trying to save next variable:");
            mkalert("error");
        end
    end
    SAVEDIR = pathconvert(SAVEDIR,%t)


    //... we manage here the disk access exceptions when a lot of imaclim are runing at the same time.
    nb_iter=0;
    ier=1;
    while ier~=0 & nb_iter<5 do
        sleep (1+nb_iter*50); //Dans cette boucle, on laisse le temps au disque dur d'être disponible et on réessaye l'écriture
        ier=trytosave()
        nb_iter = nb_iter+1
    end
    if ier~=0, disp("!mksav could  not save " + varname); mkalert("error"); disp(lasterror(%f));
        if ier==240, disp("Check attribs of SAVEDIR+""save/"" (look for read only)"); end
    elseif nb_iter>1, disp("\\o//	 mkcsv just saved us form an error "); end

endfunction

function ier=trytosave
    //this is the actual save, used in mksav
    for i=1:size(varname,"*")
        if ~isdef(varname(i)) then disp("!!In mksav, unknown variable :"+varname(i)); mkalert("error"); end
        if calibString =="calib" then
            trace_id=run_id;
            ier=execstr ("save(CALIB+varname(i)+"".sav"","""+varname(i)+""",trace_id);","errcatch"); //save(CALIB/varname.sav,varname)
            disp ("!" +"Saving " + strsubst( CALIB,PARENT,"") + varname(i) +".sav" );
        else 
            ier=execstr ("save(SAVEDIR+""save/""+varname(i)+"".sav"","""+varname(i)+""");","errcatch");	//save(SAVEDIR+"save/varname.sav",varname)
        end
    end
endfunction

function ldsav(varname,calibString,SAVEDIR,suffix2combi)
    //Loads the i variables whos name are varname(i) (given as strings) from Scilab binar format SAVEDIR+save/varname(i).sav
    //if used with "calib" %t or 1, loads from CALIB instead of SAVEDIR+save
    //SAVEDIR is optional (level_N-1 variable SAVEDIR used instead)
    //may correct SAVEDIR (adds / at the end) if SAVEDIR is not given as an argument

    varname= stripblanks (varname,%t); 
    varname= strsubst (varname,".sav","");
    if varname==[] 
        return
    end

    if argn(2)<2
        calibString ="";
    end

    if argn(2)<4
        suffix2combi = "";
    end 
    foundsavedir = %t;
    //cas ou on donne une combi comme 3eme argument
    if typeof(SAVEDIR)=="constant"
        foundsavedir = %f;
        combi = SAVEDIR

        if suffix2combi <> "" // deal with suffix on combi when baseline also suffer from sentivity analysis, when run are from outside scilab
            [nam combiList wasdone wastooManysubs isdoubledone]=classify_dirlist(%t,OUTPUT);
            ind_temp = find( strsubst(nam, string(combi) + suffix2combi ,'') <> nam); // find the folder
            if (wasdone(ind_temp)) <> []
                 ind_temp = ind_temp (wasdone(ind_temp));
            end
            if ind_temp <> []
                SAVEDIR = nam(ind_temp(1));
                foundsavedir = %t
            end
    else
            if isdir(liste_savedir(combi));
                SAVEDIR = liste_savedir(combi)
                foundsavedir = %t;
            else
                if isdef("tooManySubs")
                    if isdir(tooManySubs(combi))
                        disp("ldsav will use tooManySubs("+combi+")")
                        SAVEDIR = tooManySubs(combi)
                        foundsavedir = %t;
                    end
                end
            end
        end
    end

    if ~foundsavedir
        error("ldsav 3rd argument : "+SAVEDIR+" didnt match any SAVEDIR")
    end
    
    // if size(varname,"*")~=size(calibString,"*") then
    // if size(calibString,"*")==1 
    // calibString=emptystr(varname) + calibString; //on autorise ldsav([var1 var2 var3],"calib")
    // else
    // disp("!! ldsav("+varname+","+calibString+"): sizes don-t match"); mkalert("error"); return;
    // end
    // end

    //init. the last lmilne of this function
    leftreturn ="[";
    rigtreturn ="=return(";

    //Correcting savedir
    if calibString~="calib"
        if SAVEDIR==""
            disp( varname,"ldsav: error, SAVEDIR is empty! when trying to load next variable:"); 
            mkalert("error");
        end
        SAVEDIR = pathconvert(SAVEDIR,%t)        
    end

    for i=1:size(varname,"*")
        if calibString=="calib"
            load(CALIB+varname(i)+".sav");
            if ~isdef("trace_id")
                trace_id ="unknown run";
            end
            printf("Loading " + strsubst( CALIB+ varname(i) ,PARENT,"") +" from " + trace_id + "\n");
        else 
            if calibString~=""
                disp("!!ldsav: Unknown (2,"+i+")th argument : "+string(calibString(i))+" has been ignored" );
            end
            
            if isfile (SAVEDIR+"save/"+varname(i)+".sav")
                load(SAVEDIR+"save/"+varname(i)+".sav");
            else
                warning ("inexistant file: "+ SAVEDIR+"save/"+varname(i)+".sav")
                disp(whereami())
            end
        end 
        //updating
        leftreturn = leftreturn + varname(i) +" ,";
        rigtreturn = rigtreturn + varname(i) +" ,";
    end

    //finalizing
    leftreturn = strsubst(leftreturn,varname(i) +" ,",varname(i) +" ]");
    rigtreturn = strsubst(rigtreturn,varname(i) +" ,",varname(i) +" )");

    //executing
    execstr ( leftreturn+rigtreturn ); // varG=return(varL) : local varL (exists  in this function instance only) is copied in level_N-1 varG (exists everywhere)
endfunction

function dir_hide(the_dir)
//Hides a directory if runing on MSDOS, else does nothing
// This function handles dirty paths (like c:/MYDIR\adir/
// the_dir : The dir to hide (relatevie or absolute path).
    if getos()=="Windows"

        the_dir = pathconvert(the_dir,%f) //gets the correct file separator and removes the last one. (scilab function)

        if part(the_dir,length(the_dir))==filesep();
            part(the_dir,1:length(the_dir)-1)
        end

        unix ( "attrib +h """+ the_dir+"""");//met le "hidden" du dossier de sortie.

    end
endfunction

function dir_unhide(the_dir)
    //Unhides a directory if runing on MSDOS, else does nothing
    // This function handles dirty paths (like c:/MYDIR\adir/
    // the_dir : The dir to hide (relatevie or absolute path). 

     if getos()=="Windows"

        the_dir = pathconvert(the_dir,%f) //gets the correct file separator and removes the last one. (scilab function)

        if part(the_dir,length(the_dir))==filesep();
            part(the_dir,1:length(the_dir)-1)
        end

        unix ( "attrib -h """+ the_dir+"""");//enlève le "hidden" du dossier de sortie.

    end

endfunction

function bigsave_del()
//Deletes bigsave, before making a new one,...
    //If not, variables are concatenated in bigsave.sav and various variables with the same nam appear in level_0 memory (love you, scilab team).
//...or when stabilisation is done, so SAVEDIR is a light(ko) dir
    deletefile (pathconvert(SAVEDIR,%t)+"bigsave.sav");
endfunction

function bigsave(bigs_nb_sys_var,i)
    //when variables in different namespaces (level_0, level_N-1) 
    //have the same name, this saves only once each variable, it will be the level_N version.
    //so when imaclim calls this and imaclim is called itself by some other function, say robot(), we don't care
    //if robot also uses a variable called (level_0) p. We know the saved p will be prices in imaclim (level_N p).
    //http://wiki.scilab.org/howto/global_and_local_variables

    if ~isdef("bigs_nb_sys_var")
        disp ("bigs_nb_sys_var = size( (who( ""local""),""*"")");
        error ("A  bigs_nb_sys_var should be provided. One of the firsts line of the code should be precedent disp. Ideal is first line of preamble") 
    end

    //If not, variables are concatenated in bigsave.sav and various variables with the same nam appear in level_0 memory (love you, scilab team).
    bigsave_del()

    //Reminds when this was done
    Tlastsave= i;
    //=====memory management (do not break this block)
    //getting all the variables
    bigs_vars = who("local")
    //removing the "system" variables
    bigs_vars_restr = bigs_vars(1:$-bigs_nb_sys_var);
    //we are writing here a list e.g "p, CI, reg," in a string way
    bigs_str_end ="";
    for bigs_for = bigs_vars_restr'
        bigs_str_end = bigs_str_end+bigs_for+","
    end
    //we remove the last coma
    bigs_str_end = part(bigs_str_end,1:(length(bigs_str_end)-1));
    //we execute something like save(SAVEDIR+"bigsave.sav",p,q,CI)

    //... we manage here the disk access exceptions when a lot of imaclim are runing at the same time.
    nb_iter=0;
    ier=1;
    while ier~=0 & nb_iter<5 do
        sleep (1+nb_iter*50); //Dans cette boucle, on laisse le temps au disque dur d'être disponible et on réessaye l'écriture
        ier=execstr ("save(SAVEDIR+""bigsave.sav"",bigs_str_end)","errcatch") //actual bisave
        nb_iter = nb_iter+1
    end
    if ier~=0, disp("!bigsave could  not save in bigsave.sav"); mkalert("error"); disp(lasterror(%f));
        if ier==240, disp("Check attribs of SAVEDIR+""save/"" (look for read only)"); end
    elseif nb_iter>1, disp("\\o//	 mkcsv just saved us form an error "); end

endfunction

function rldsav(varname,combi)
    //Loads the i variables whos name are varname(i) (given as strings) from Scilab binar format SAVEDIR+save/varname(i).sav
    //if used with "calib" %t or 1, loads from CALIB instead of SAVEDIR+save
    //SAVEDIR is optional (level_N-1 variable SAVEDIR used instead)
    //may correct SAVEDIR (adds / at the end) if SAVEDIR is not given as an argument

    foundsavedir = %f;
    wasTooManySubs = %f;
    if isdir(liste_savedir(combi));
        SAVEDIR = liste_savedir(combi)
        foundsavedir = %t;
    else
        if isdef("tooManySubs")
            if isdir(tooManySubs(combi))
                message("rldsav will use tooManySubs("+combi+")")
                SAVEDIR = tooManySubs(combi)
                foundsavedir = %t;
    	    wasTooManySubs = %t;
            end
        end
    end
    if ~foundsavedir
        error("rldsav 2nd argument : "+combi+" didnt match any SAVEDIR")
    end
    
    //init. the last lmilne of this function
    leftreturn ="[";
    rigtreturn ="=return(";

    for i=1:size(varname,"*")
            if isfile (SAVEDIR+"save/"+varname(i)+".sav")
                load(SAVEDIR+"save/"+varname(i)+".sav");
		if wasTooManySubs
                    load(SAVEDIR+"save/last_done_year.sav");
		    execstr(varname(i)+"(:,"+last_done_year+"+1:$)=%nan;");
		end
            else
                warning ("inexistant file: "+ SAVEDIR+"save/"+varname(i)+".sav")
                disp(whereami())
            end
        //updating
        leftreturn = leftreturn + varname(i) +" ,";
        rigtreturn = rigtreturn + varname(i) +" ,";
    end

    //finalizing
    leftreturn = strsubst(leftreturn,varname(i) +" ,",varname(i) +" ]");
    rigtreturn = strsubst(rigtreturn,varname(i) +" ,",varname(i) +" )");

    //executing
    execstr ( leftreturn+rigtreturn ); // varG=return(varL) : local varL (exists  in this function instance only) is copied in level_N-1 varG (exists everywhere)

endfunction

