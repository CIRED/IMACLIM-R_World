// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Nicolas Graves, Adrien Vogt-Schilb, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////
// Save_generic Functions
// This remplaces good'old save_generic.sce in a clean way.
// Full understanding of this file should finally teach you what is "global" "nolocal" and "local" in Scilab
// This can help: http://wiki.scilab.org/howto/global_and_local_variables
// La derniere fonction est laissée en exercice ! :-P
//
//INDEX
// sg_make_list
// sg_add
// sg_init
// sg_update
// sg_save
// sg_reload
//sg_clear
// sg_plot_vars(howlong)
// sg_get_var
// sg_get_hyp
// sghf
// sg_plot_sum
// sg_mean
// sg_magic_report

function sg_make_list()
    global sg_varnams_list

    //sg_varnams_list :a string column (n by 1 matrix) (pollite people sort by name, caramba).
    //List of names of imaclim matrixes (hypermatrixes won't work). 
    //Each variable is supposed to vary each year.
    //Variable names should strictly be less than 22 characters
    sg_varnams_list=[
    "alphaCoalm2"
    "alphaCompositeauto"
    "alphaelecauto"
    "alphaelecm2"
    "alphaEtauto"
    "alphaHYDauto"
    "alphaEtm2"
    "alphaGazm2"
    "aw"
    "Beta"
    "bmarketshareener"
    "bnautomobile"
    "bw"
    "Cap"
    "Captransport"
    "Cap_elec_MW"
    "Cap_elec_MW_dep"
    "Cap_elec_MW_exp_inst"
    "CC_elec_i_1"
    "CFuel_cars"
    "CFuel_i_1"
    "CFuel_moy"
    "charge"
    "CI"
    "CINV_cars_nexus"
    "CINV_cars_temp"
    "CINV_MW_nexus"
    "CO2_indus_process"
    "coef_Q_CO2_CI"
    "coef_Q_CO2_CI_wo_CCS"
    "coef_Q_CO2_DF"
    "coef_Q_CO2_DG"
    "coef_Q_CO2_DI"
    "DeltaK"
    "DF"
    "DG"
    "DI"
    "DIinfra"
    "div"
    "emi_evitee"
    "emi_evitee_elec"
    "energy_balance_stock"
    "Ener_reg_use"
    "Exp"
    "ExpTI"
    "E_CO2_wo_CCS"
    "E_reg_use"
    "equilibrium"
    "GDP"
    "GDP_MER_nominal"
    "GDP_MER_real"
    "GDP_PPP_constant"
    "GDP_secMER_real"
    "GDP_secPPP_constant"
    "GRB"
    "IC_2190"
    "IC_3650"
    "IC_5110"
    "IC_6570"
    "IC_730"
    "IC_8030"
    "IC_8760"
    "Imp"
    "InvDem"
    "Inv_MW"
    "Inv_val"
    "Inv_val_sec"
    "K"
    "K_depreciated"
    "K_cost_ser_TAX"
    "K_cost_ind_TAX"
    "K_cost_agr_TAX"
    "K_cost_btp_TAX"
    "L"
    "Lact"
    "l"
    "LCC_2190"
    "LCC_3650"
    "LCC_5110"
    "LCC_6570"
    "LCC_730"
    "LCC_8030"
    "LCC_8760"
    "LCC_cars"
    "Ltot"
    "marketshare"
    "marketshareTI"
    "markup"
    "markup_stock"
    "MSH_2190_elec"
    "MSH_3650_elec"
    "MSH_5110_elec"
    "MSH_6570_elec"
    "MSH_730_elec"
    "MSH_8030_elec"
    "MSH_8760_elec"
    "mtax"
    "NRB"
    "p_stock"
    "pArmCI"
    "pArmDG"
    "pArmDF"
    "pArmDI"
    "partDomCI"
    "partDomDF"
    "partDomDG"
    "partDomDI"
    "partExpK"
    "partImpCI"
    "partImpDF"
    "partImpDG"
    "partImpDI"
    "partImpK"
    "partInvFin"
    "partTIref"
    "pind"
    "pIndEner"
    "pind_prod"
    "pK"
    "progestechl"
    "ptc"
    "Q_biofuel_anticip"
    "Q_cum_coal"
    "Q_cum_gaz"
    "Q_elec_anticip"
    "Q_elec_anticip_tot"
    "QCdom"
    "Ress_coal"
    "Ress_gaz"
    "rhoeleccoal"
    "rhoelecEt"
    "rhoelecgaz"
    "rho_elec_moyen"
    "share_CCS_CTL"
    "share_NC"
    "share_biofuel"
    "share_CTL"
    "sh_CCS_col_Q_col"
    "sh_CCS_gaz_Q_gaz"
    "stockautomobile"
    "stockbatiment"
    "stockbatiment_BAU"
    "stockbatiment_SLE"
    "stockbatiment_VLE"
    "sumInvDem"
    "Tair"
    "Tautomobile"
    "TOT"
    "taxCIdom"
    "taxCIimp"
    "taxDFdom"
    "taxDFimp"
    "Tdisp"
    "TFC"
    "TNM"
    "TOT"
    "TPES"
    "tx_Q"
    "VA"
    "w"
    "wp"
    "wpTI"
    "wpTIagg"
    "wp_oil"
    "xsi"
    "xsiT"
    "Z"
    "emi_evitee_hdr" // variable only with NLU linkage
    "Q_biofuel_real" // variable only with NLU linkage
    ];
endfunction

function sg_add(sg_more_varnams)
    //adds a list of variables to those whou should be saved each year. Must be done before sg_init(), in imaclimR, this is before the end of Dynamic.sce with current_time_im==1.
    //
    //sg_more_varnams : a column of strings, with the names of the variables that should be saved

    //warns the user if current_time_im>1 (might be too late for initialization)     
    global is_sg_inited
    if is_sg_inited
        warning("sg_add was called after sg_init")
        disp(whereami());
        disp(sg_more_varnams);
    end

    global sg_varnams_list

    //PREPROCESSING    
    //suppression des espaces, des tabs, des "_sav" et mise en forme selon une colonne
    sg_more_varnams = stripblanks(sg_more_varnams,%t);
    sg_more_varnams = strsubst(matrix(sg_more_varnams,-1,1),"_sav","")

    //WORK     
    sg_varnams_list = unique ([sg_varnams_list; sg_more_varnams]);

endfunction


function sg_init(TimeHorizon)
    //Save_generic initialisation. Defines so-called var_savs and the sg_varnams_list
    //*INPUTS 
    //*TimeHorizon      :temporal horizon. OPTIONAL (nolocal TimeHorizon variable used instead)
    //
    //*OUTPUTS: N global variables whos name end with "_sav". 
    //          Please read Scilab help :  help global
    //          Please see sg_update below : aach year, variable is
    //          gona be writen as a row of the resulting variable_sav matrix

    global sg_varnams_list

    //La liste doit etre un vecteur colonne
    [line col] = size( sg_varnams_list ) 
    if line==1 & col >1
        sg_varnams_list = sg_varnams_list'
    end

    //Deleting from the list those variables which are not defined
    ToDeleteIndexes = [];
    for isg=1:size(sg_varnams_list,"*")
        if ~isdef(sg_varnams_list(isg));
            ToDeleteIndexes($+1)=isg;
            if verbose >=1
                warning ( "sg_init is ignoring "+sg_varnams_list(isg))
            end
        end
    end

    if size(ToDeleteIndexes,"*")>0
        if verbose >=1
            disp( "sg_ ignores thoses variables from the list"); disp(sg_varnams_list(ToDeleteIndexes))
        end
        sg_varnams_list(ToDeleteIndexes) = [];
    end

    //This declars as global each variable_sav , so modifications
    // done on them are not lose when quiting this function instance
    // for further explanations type in Scilab :   help global
    // This can help: http://wiki.scilab.org/howto/global_and_local_variables
    for var=sg_varnams_list'
        execstr ( "global "+var+"_sav")
    end

    //variable_sav initialisation 
    execstr ( sg_varnams_list+"_sav=zeros(size("+sg_varnams_list+",""*""),TimeHorizon+1);");

    for var=sg_varnams_list'
        //variable name's size chek (if variable as a too long name, 
        //"variable_sav" and "variable_ref" may both be truncated by scilab as "variable_")
        if length(var)>=22
            if verbose>=1
                disp( "!sg_init: the name "+var+" is too long. Use rustine as sh_CCS_col_Q_col");
            end
            mkalert( "error");
        end

        //the next loop will turn that true if there is a variable_ref
        first_found_flag = %f;

        //On va essayer de mettre MSH_cars_ref dans MSH_cars_sav automatiquement
        for suffixe = [ "ref" "_ref" "prev" "_prev"]
            if isdef (var+suffixe) 
                execstr( var+"_sav(:,1)=matrix("+var+suffixe+",-1,1);");
                first_found_flag = %t;
                break
            end  
        end
        //Si la variable de reference (ie photographiée en 2000) n'existe pas, 
        //on remplit avec sa valeur en 2001. On pourrait remplir avec des 0 a la place
        if ~first_found_flag
            execstr ( var+"_sav(:,1)=matrix("+var+",-1,1);");
        end

        if or(var==["CI"])
            execstr ( var+"_sav(:,1)=0");
        end

    end

    //Previent les autres fonctions que sg_init a ete execute
    global is_sg_inited
    is_sg_inited = %t;

endfunction

function sg_update(sg_index)
    //Generical FILLING of var_savs. 
    //
    //*INPUTS : 
    //   *sg_index   :Integer. Usually current_time_im (current date)
    //   Variables given in sg_varnams_list with sg_index=4 represent values in 2004 

    //This declars as global each variable_sav , so modifications
    // done on it are not lose when quiting this function 
    // PLEASE DO type in Scilab :   help global
    // This can help: http://wiki.scilab.org/howto/global_and_local_variables
    
    global is_sg_inited
    
    if is_sg_inited 
    else //CAUTION: do NOT change this if else with a negation ~ before you understand what this line does : (if ~[])
        if verbose>=1
            disp("sg_update launches sg_init")
        end
        sg_init()
    end
    
    global sg_varnams_list
    for var=sg_varnams_list'
        execstr("global "+var+"_sav")
    end

    for var=sg_varnams_list'
        ier=execstr(var+"_sav(:,sg_index)=matrix("+var+",-1,1)","errcatch");
        if ier>0 then disp(lasterror(), "error in sg_update with "+ var), end
    end
endfunction

function sg_save()
    //Hard drive save of var_savs. 
    //
    //*INPUTS : *sg_varnams_list   :  a string column ( N x 1 matrix).
    //          List of names of imaclim matrixes (hypermatrixes won't work). 
    //          Each variable is supposed to vary each year.

    //This declars as global each variable_sav , so modifications
    // done on it are not lose when quiting this function 
    // for further explanations type in Scilab :   help global
    global sg_varnams_list
    for var=sg_varnams_list'
        global (var+"_sav")
    end
    if verbose>=1
        disp("sg_save() will save now...")
    end
    //this actually saves. for help, exec this in scilab: head_comments mksav
    mksav (sg_varnams_list+"_sav")
    if verbose>=1
        disp("...sg_save() is done.")
    end
endfunction

function sg_clear()
    //robustrly clearglobals each sg_vars
    //avoid bugs if cleargloab does not work

    global sg_varnams_list
    for var=sg_varnams_list'
        clearglobal (var+"_sav")
    end

endfunction

function sg_reload(SAVEDIR)
    //reucper les var_sav.dat du SAVEIDR/save et reconstruit la sg_varnams_list

    olddir = pwd();

    global sg_varnams_list

    //Liste des vars_sav.dat
    cd(pathconvert(SAVEDIR,%t)+"save")
    hop=dir("*_sav.dat")
    sg_varnams_list = strsubst(hop(2),"_sav.dat","") //vire le _sav.dat

    for var=sg_varnams_list'
        global(var+"_sav")
        ldsav(var+"_sav")
    end

    cd(olddir)

endfunction

function sg_plot_vars(howlong,mylist)
    //plot les variables qui sont dans la liste de save_generic une par une
    //ceci permet de progresser lentement vers la reponse a la Question Essentielle (mais, pourquoi ca bug, heu?) en cas de toomanysubdivisions
    //ceci marche avec des variables qui sont des matrices reg*TimeHorizon+1, mias c'est tout.


    //This declars as global each variable_sav , so modifications
    // done on it are not lose when quiting this function instance
    // for further explanations type in Scilab :   help global
    global sg_varnams_list

    if argn(2)<1
        howlong = -1 //2 sec
    end

    if argn(2)<2
        mylist = meaningfull_params;
        disp("sg_plot_vars ignores the so-called boring paramters")
    end

    // for var=mylist'
    // execstr("global "+var+"_sav")
    // if evstr(var+"_sav")==[]
    // disp ("sg_ ldsaves "+var+"_sav")
    // ldsav (var+"_sav")
    // end
    // end

    for var=(matrix(mylist,1,-1))
        try
            clf;
            hop=sg_get_var(var)
            if size(hop,1)==reg
                plotreg(hop(:,1:current_time_im+1))
            else
                plot(hop(:,1:current_time_im+1)')
            end
            title(var)
            if howlong<=0
                halt("you are watching "+var+". Push the button");
            else
                sleep (howlong)
            end
        catch
            disp(var+" would not let itself be ploted:"+lasterror())
        end
    end
endfunction

function out=sg_get_var(matname,which_lines,which_columns,nb_lines,default_orient,which_years,forceColumn)
    //
    // out=sg_get_var(matname,[which_lines,[which_columns,[nb_lines,[default_orient,[which_years,[forceColumn]]]]]])
    //
    //destinee a remplacer les boucle avec les _temp pour recuperer les variables enregistree dans le format "une colonne= 1 annee"
    //
    //INPUTS
    // matname : nom de la variable (aves ou sans _sav), ou variable elle même
    // which_lines : lignes, cad souvent regions, à sortir par exemple 1:reg, ou 1:4, ou 3. Par defaut 1:reg
    // which_columns : colonnes (souvent secteurs) à sortir (par exemple [indice_coal:indice_elec]). Par defaut : (toutes le scolonnes)
    // nb_lines : nombre de lignes de la matrice originale. Par defaut, reg.
    // which_years : temps à sortir. par defaut toutes les années.
    // default_orient : transpose la matrice originale. Par defaut, %T
    // forceColumn : force la sortie a être une colonne quand which_years est un nombre. Par defaut, %F
    //
    //OUTPUTS
    // out : colonne (size(which_lines,"*") x size(which_columns,"*") ) x size(which_years)
    // si size(which_years) = 1 et ~forceColumn une seule année selectionnée, alors out est une matrice et pas :
    //                          out : matrice size(which_lines,"*") x size(which_columns,"*") 
    //EXEMPLES
    // norm(sg_get_var("E_reg_use")-E_reg_use_sav) //meme chose 
    // sg_get_var(E_reg_use_sav,ind_eur,iu_df,reg,%f,1:10) //les emissions des menages europeens les dix premieres années
    // sum(sg_get_var("E_reg_use",1:4,iu_df,reg,%f,1:10),"r") //les emissions des menages de l'ocde dans les dix premieres années
    // sgv("taxCO2_DF",:,:,reg,1,current_time_im) //récupère taxCO2_DF en entier à l'année i

    //PREPROCESS
    if typeof(matname)=="string" //user provided the name of the variable
        matname = stripblanks(matname,%t);
        matname = strsubst (matname,"_sav","")+"_sav" //we get sure to get varname_sav
        global(matname)
        mat = evstr( matname) 
        if isempty(mat) //varname was not loaded
            message("sg_get_var ldsaves "+matname)
            ldsav(matname)
            mat = evstr( matname) 
        end    
    else
        mat = matname
    end    

    //DEFAULT VALUES
    if argn(2)<7 
        forceColumn =%F;
    end    
    if argn(2)<6 
        which_years =1:TimeHorizon+1
    end    

    if argn(2)<5 
        default_orient = %t;
    end

    if argn(2)<4 
        nb_lines = reg
    end    

    if argn(2)<3 
        which_columns=:;
    end

    if argn(2)<2 
        out = mat;
        return
    end

    //WORK    
    
    
    for isg=1:size(which_years,"*")
        mattemp=matrix(mat(:,which_years(isg)),nb_lines,-1);
        if default_orient
            out(:,isg) = matrix(mattemp(which_lines,which_columns)',-1,1);
        else
            out(:,isg) = matrix(mattemp(which_lines,which_columns),-1,1);
        end    
    end

    //no column case
    if  size(which_years,"*")==1 & ~forceColumn 
        if which_lines==: & string(which_lines)~="1"
            out = matrix(out,nb_lines,-1);
        else
            out = matrix(out,size(which_lines,'*'),-1);
        end    
    end

    if isempty(out)
        warning ( whereami ()+"out is empty")
    end

endfunction
//alias au nom plus court
sgv = sg_get_var;

function out = sg_magic_report(varname,which_lines,which_columns)
    //trys to make a hulman_readable report of varname(which_lines,which_columns), assuming lines are regions and columns are sectors

    //DEFAULT VARIABLES
    //toutes les colonnes de var
    if argn(2)<3
        var = evstr(varname)
        which_columns = 1:size(var,2)
    end
    //toutes les lignes de var
    if argn(2)<2
        which_lines = 1:size(var,1)
    end

    out = [strcomb(regnames(regions),secnames(sectors)) sgv(mat,regions,sectors)]

endfunction
smr = sg_magic_report;



function out=sg_get_hyp(matname,which_lines,which_columns,thirdindexes)
    // out=sg_get_var(matname,[which_lines,[which_columns,[nb_lines,[default_orient,[which_years]]]]])
    //
    //destinee a remplacer les boucle avec les _temp pour recuperer les variables enregistree dans le format "une colonne= 1 annee"
    //
    //INPUTS
    // matname : nom de la variable (aves ou sans _sav), ou variable elle même
    // which_lines : lignes, cad souvent regions, à sortir par exemple 1:reg, ou 1:4, ou 3. Par defaut 1:reg
    // which_columns : colonnes (souvent secteurs) à sortir (par exemple [indice_coal:indice_elec]). Par defaut : (toutes le scolonnes)
    // thirdindexes : 

    //OUTPUTS
    // out : hypermatrice
    //
    //EXEMPLES
    //sgh("CI",elec,elec,eur)

    //PREPROCESS
    if typeof(matname)=="string" //user provided the name of the variable
        matname = strsubst (matname,"_sav","")+"_sav" //we get sure to get varname_sav
        global(matname)
        mat = evstr( matname) 
        if isempty(mat) //varname was loaded
            message("sg_get_hyp ldsaves "+matname)
            ldsav(matname)
            mat = evstr( matname) 
        end    
    else
        mat = matname
    end    

    which_years =1:TimeHorizon+1

    default_orient = %t;

    nb_lines = reg

    if argn(2)<4
        thirdindexes = 1:12;
    end

    if argn(2)<3 
        which_columns=:;
    end

    if argn(2)<2 
        out = mat;
        return
    end


    //WORK    
    for isg=1:size(which_years,"*")
        mattemp=matrix(mat(:,which_years(isg)),nb_lines,-1,12);
        out(:,isg) = matrix(mattemp(which_lines,which_columns,thirdindexes),-1,1);
    end

    if isempty(out)
        warning ( whereami ()+"out is empty")
    end

endfunction

sgh = sg_get_hyp;
function formattedHyp = sghf(varargin)
    unformattedHyp = varargin(1);
    select argn(2)
    case 3
        formattedHyp = zeros(varargin(2),varargin(3),100);
        for i=1:100
            formattedHyp(:,:,i) = matrix(unformattedHyp(:,i),varargin(2),varargin(3));
        end
    case 4
        formattedHyp = zeros(varargin(2),varargin(3),varargin(4),100);
        for i=1:100
            formattedHyp(:,:,:,i) = matrix(unformattedHyp(:,i),varargin(2),varargin(3),varargin(4));
        end
    else
        error("Problem with sghf");
    end

endfunction


function sg_plot_sum(varargin)
    //plot(sum(sgv(varargin),"r"))
    pause
    plot(sum(evstr(strcat(list2vec(varargin)',",")),"r"))

endfunction
sps = sg_plot_sum;

function var_prev = sg_meanmax(varname,depth,which_lines,which_columns,minormax)
    //Renvoie la valeur moyenne ou le max de varname(which_lines,which_columns) depuis depth années. 
    //Ajoute varname dans save_generic à l'année 1
    //varname est une string representant le nom d'une matrice

    //ACTUAL JOB

    //cas specifique
    if current_time_im==1 & typeof(varname)=="string"
        varname = stripblanks(varname,%t); //vire les espaces et les tab
        var_prev_all = evstr(varname);
        var_prev = var_prev_all(which_lines,which_columns);
        sg_add(varname);
        //cas generique
    else
        for j=1:size(which_columns,"*")
            column = which_columns(j);
            var_prev(:,j)= minormax(sg_get_var(varname,which_lines,column,reg,%f,max((current_time_im-depth),1):current_time_im),"c"); 
        end    
    end

endfunction

function var_prev = sg_mean(varname,depth,which_lines,which_columns)
    //Renvoie la valeur moyenne de varname(which_lines,which_columns) depuis depth années. 
    //Ajoute varname dans save_generic à l'année 1
    //varname est une string representant le nom d'une matrice

    //DEFAULT VALUE
    //toutes les colonnes de var
    if argn(2)<4
        var = evstr(varname)
        which_columns = 1:size(var,2)
    end
    //toutes les lignes de var
    if argn(2)<3
        which_lines = 1:size(var,1)
    end
    //3 ans
    if argn(2)<2
        depth = 3
    end

    //ACTUAL JOB
    var_prev = sg_meanmax(varname,depth,which_lines,which_columns,mean)

endfunction

function var_prev = sg_max(varname,depth,which_lines,which_columns)
    //Renvoie la valeur maximale de varname(which_lines,which_columns) depuis depth années. 
    //Ajoute varname dans save_generic à l'année 1
    //varname est une string representant le nom d'une matrice
    //DEFAULT VALUE
    //toutes les colonnes de var
    if argn(2)<4
        var = evstr(varname)
        which_columns = 1:size(var,2)
    end
    //toutes les lignes de var
    if argn(2)<3
        which_lines = 1:size(var,1)
    end
    //3 ans
    if argn(2)<2
        depth = 3
    end

    //ACTUAL JOB
    var_prev = sg_meanmax(varname,depth,which_lines,which_columns,max)

endfunction
