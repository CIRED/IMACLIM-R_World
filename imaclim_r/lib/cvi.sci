// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//function to compute the CVI (Compensating Variation of Income)
function [y]=HH_budget_Rcst_pays(Consoloc,Tautomobileloc)
    DFtemp=DFinduite_pays(Consoloc,Tautomobileloc)
    //DFtemp=DFtemp(pays,:);
    y = (ptc(pays) - sum((DFtemp.*pArmDF(pays,:)),'c')./(Rcst(pays).*(1-IR(pays))))'
endfunction


function [y]=CalculConsoRevenu_pays(xloc)

    Consoloc=        ( matrix(xloc(1                                     :1*nb_secteur_conso),1,nb_secteur_conso));
    Tautomobileloc= matrix(xloc(1*nb_secteur_conso+1                  :1*nb_secteur_conso+1          ),1,1);
    lambdaloc=     matrix(xloc(1*nb_secteur_conso+1+1               :1*nb_secteur_conso+2*1          ),1,1);
    muloc=         matrix(xloc(1*nb_secteur_conso+2*1+1             :1*nb_secteur_conso+3*1        ),1,1);
    TNMloc=        matrix(xloc(1*nb_secteur_conso+3*1+1   :1*nb_secteur_conso+4*1),1,1);


    // if (Rdisp(k)<=0) then Rdisp(k)=0.00001; end
    if (Tautomobileloc<=bnautomobile(pays)) then Tautomobileloc=bnautomobile(pays)+0.0000001; end
    if (TNMloc<=bnNM(pays)) then TNMloc=bnNM(pays)+0.0000001; end
    //transport sectors
    for j=[1,2,6,7]
        if (Consoloc(1,j)<=bn(pays,j+5)) then  Consoloc(1,j)=bn(pays,j+5)+0.000001; end
    end
    // air sector
    if (Consoloc(1,indice_air-5)<=0) then Consoloc(1,indice_air-5)=0+0.0000001; end
    // sea sector
    if (Consoloc(1,indice_mer-5)<=bn(pays,indice_mer)) then Consoloc(1,indice_mer-5)=bn(pays,indice_mer)+0.000001; end
    //Other Transport sector
    if (Consoloc(1,indice_OT-5)<=bnOT(pays)) then Consoloc(1,indice_OT-5)=bnOT(pays)+0.000001; end 

    // Utility_temp=matrix(Utility(Consoloc,Tautomobileloc,TNMloc,lambdaloc,muloc),reg,-1);
    // HH_budget_Rcst_temp=HH_budget_Rcst(Consoloc,Tautomobileloc);
    // Time_budget_temp=Time_budget(Consoloc,Tautomobileloc,TNMloc);

    y=real([	Utility_pays(Consoloc,Tautomobileloc,TNMloc,lambdaloc,muloc),...
        HH_budget_Rcst_pays(Consoloc,Tautomobileloc),...
    Time_budget_pays(Consoloc,Tautomobileloc,TNMloc)
    ]');

endfunction


function [y]=IndirectUtility_pays(Rcst)
    global stock_equi

    if current_time_im==1
        equilibrium=matrix([Conso(pays,:),Tautomobile(pays),lambda(pays),mu(pays),TNM(pays)],-1,1);
        //equilibrium=equilibrium+ rand(equilibrium).*equilibrium/3;
    else
        //load(TMPDIR+'/equilibrium.tmp');
        equilibrium = stock_equi;
    end

    substep=0;
    substep_prev=0;
    last_try_failed=%f;
    nb_stepp=1;
    while substep<1
        substep = substep_prev + 1/nb_stepp;
        //this is a step param
        if current_time_im>1
            execstr (varalpha+'= (1-substep)*matrix('+varalpha+'_glo(:,current_time_im-1),reg,-1) + substep*matrix('+varalpha+'_glo(:,current_time_im),reg,-1)');
        end
        equilibrium_lastgood = equilibrium;
        // disp( 'current_time_im='+current_time_im+' substep='+substep);
        [equilibrium,v,info]=fsolve(equilibrium,CalculConsoRevenu_pays);

        if ( info==4) then 
            equilibrium=equilibrium_lastgood;
            substep = substep_prev;
            nb_stepp=2*nb_stepp;
            if nb_stepp>2^15 then mkalert( 'error'); disp( 'in function IndirectUtility_pays : too many subdivisions'); y=[]; return; end
            last_try_failed=%t;
        else
            substep_prev=substep;
            if last_try_failed then 
                last_try_failed=%f;
            else
                nb_stepp=max(nb_stepp/2,1);
            end
        end	
    end		

    stock_equi = equilibrium;
    //save( TMPDIR+'/equilibrium.tmp',equilibrium);

    Conso=        	matrix(equilibrium(1                           :1*nb_secteur_conso),1,nb_secteur_conso);
    Tautomobile= 	matrix(equilibrium(1*nb_secteur_conso+1      :1*nb_secteur_conso+1          ),1,1);
    lambda=     	matrix(equilibrium(1*nb_secteur_conso+1+1  :1*nb_secteur_conso+2*1          ),1,1);
    mu=         	matrix(equilibrium(1*nb_secteur_conso+2*1+1:1*nb_secteur_conso+3*1        ),1,1);
    TNM=        	matrix(equilibrium(1*nb_secteur_conso+3*1+1:1*nb_secteur_conso+4*1),1,1);

    // if (Rdisp(k)<=0) then Rdisp(k)=0.00001; end
    if (Tautomobile<=bnautomobile(pays)) then Tautomobile=bnautomobile(pays)+0.0000001; end
    if (TNM<=bnNM(pays)) then TNM=bnNM(pays)+0.0000001; end
    //non transport sectors
    for j=[1,2,6,7]
        if (Conso(1,j)<=bn(pays,j+5)) then  Conso(1,j)=bn(pays,j+5)+0.000001; end
    end
    //air transport
    if (Conso(1,indice_air-5)<=0) then Conso(1,indice_air-5)=0+0.0000001; end
    // sea transport
    if (Conso(1,indice_mer-5)<=bn(pays,indice_mer)) then Conso(1,indice_mer-5)=bn(pays,indice_mer)+0.000001; end
    // Other Transport sector
    if (Conso(1,indice_OT-5)<=bnOT(pays)) then Conso(1,indice_OT-5)=bnOT(pays)+0.000001; end 

    DFtemp2=DFinduite_pays(Conso,Tautomobile);
    y=calcUtilityHH_pays(DFtemp2,Tautomobile,TNM);
endfunction

function y=CalculCVI_pays(CVIloc)
    Revenu=Rdisp_REF
    Revenu(pays)=Rdisp_REF(pays)+CVIloc
    UtilityCVI=IndirectUtility_pays(Revenu)
    if UtilityCVI==[]
        y=[]; 
        disp "CalculCVI_pays returns []!"
        return
    end
    y=real((UtilityCVI./Utility_REF(pays))-1);
    if norm(y)<1d-8 //
        y=0
    end
endfunction


function [y] = Utility_pays(Consoloc,Tautomobileloc,TNMloc,lambdaloc,muloc) ;
    // double constraint (money + time)
    //Consoloc=[DFBTP,DFcomposite,DFair,DFmer,DFOT]
    y1=zeros(1,nb_secteur_conso+2);
    y1(:,indice_construction-nbsecteurenergie)=((Consoloc(:,indice_construction-nbsecteurenergie)-bn(pays,indice_construction)).*lambdaloc.*pArmDF(pays,indice_construction))-xsi(pays,1);
    y1(:,indice_composite-nbsecteurenergie)=((Consoloc(:,indice_composite-nbsecteurenergie)-bn(pays,indice_composite)).*lambdaloc.*pArmDF(pays,indice_composite))-xsi(pays,2);
    y1(:,indice_mer-nbsecteurenergie)=((Consoloc(:,indice_mer-nbsecteurenergie)-bn(pays,indice_mer)).*lambdaloc.*pArmDF(pays,indice_mer))-xsi(pays,3);
    y1(:,indice_air-nbsecteurenergie)=xsiT(pays).*betatrans(pays,1).*(alphaair(pays)).^(-sigmatrans(pays)).*((Consoloc(:,indice_air-nbsecteurenergie))-bnair(pays)).^(-sigmatrans(pays)-1)+(betatrans(pays,1).*(alphaair(pays).*(Consoloc(:,indice_air-nbsecteurenergie)-bnair(pays))).^(-sigmatrans(pays))+betatrans(pays,2).*(alphaOT(pays).*(Consoloc(:,indice_OT-nbsecteurenergie)-bnOT(pays))).^(-sigmatrans(pays))+betatrans(pays,3).*(Tautomobileloc-bnautomobile(pays)).^(-sigmatrans(pays))+betatrans(pays,4).*(TNMloc-bnNM(pays)).^(-sigmatrans(pays))).*(-lambdaloc.*pArmDF(pays,indice_air)-muloc.*pkmautomobileref(pays)./(100).*alphaair(pays).*tair_pays(Consoloc));
    y1(:,indice_OT-nbsecteurenergie)=xsiT(pays).*betatrans(pays,2).*(alphaOT(pays)).^(-sigmatrans(pays)).*(Consoloc(:,indice_OT-nbsecteurenergie)-bnOT(pays)).^(-sigmatrans(pays)-1)+(betatrans(pays,1).*(alphaair(pays).*(Consoloc(:,indice_air-nbsecteurenergie)-bnair(pays))).^(-sigmatrans(pays))+betatrans(pays,2).*(alphaOT(pays).*(Consoloc(:,indice_OT-nbsecteurenergie)-bnOT(pays))).^(-sigmatrans(pays))+betatrans(pays,3).*(Tautomobileloc-bnautomobile(pays)).^(-sigmatrans(pays))+betatrans(pays,4).*(TNMloc-bnNM(pays)).^(-sigmatrans(pays))).*(-lambdaloc.*pArmDF(pays,indice_OT)-muloc.*pkmautomobileref(pays)./(100).*alphaOT(pays).*tOT_pays(Consoloc));
    y1(:,indice_agriculture-nbsecteurenergie)=((Consoloc(:,indice_agriculture-nbsecteurenergie)-bn(pays,indice_agriculture)).*lambdaloc.*pArmDF(pays,indice_agriculture))-xsi(pays,4);
    y1(:,indice_industries-nbsecteurenergie)=((Consoloc(:,indice_industries-nbsecteurenergie)-bn(pays,indice_industries)).*repmat(lambdaloc,1,nb_sectors_industry).*pArmDF(pays,indice_industries))-xsi(pays,5:(4+nb_sectors_industry));

    y1(:,nb_secteur_conso+1)=xsiT(pays).*betatrans(pays,3).*(Tautomobileloc-bnautomobile(pays)).^(-sigmatrans(pays)-1)+(betatrans(pays,1).*(alphaair(pays).*(Consoloc(:,indice_air-nbsecteurenergie)-bnair(pays))).^(-sigmatrans(pays))+betatrans(pays,2).*(alphaOT(pays).*(Consoloc(:,indice_OT-nbsecteurenergie)-bnOT(pays))).^(-sigmatrans(pays))+betatrans(pays,3).*(Tautomobileloc-bnautomobile(pays)).^(-sigmatrans(pays))+betatrans(pays,4).*(TNMloc-bnNM(pays)).^(-sigmatrans(pays))).*(-lambdaloc.*(alphaEtauto(pays).*pArmDF(pays,indice_Et)+alphaelecauto(pays).*pArmDF(pays,indice_elec)+alphaCompositeauto(pays).*pArmDF(pays,indice_composite)).*pkmautomobileref(pays)./(100)-muloc.*pkmautomobileref(pays)./(100).*tautomobile_pays(Tautomobileloc));

    y1(:,nb_secteur_conso+2)=xsiT(pays).*betatrans(pays,4).*(TNMloc-bnNM(pays)).^(-sigmatrans(pays)-1)+(betatrans(pays,1).*(alphaair(pays).*(Consoloc(:,indice_air-nbsecteurenergie)-bnair(pays))).^(-sigmatrans(pays))+betatrans(pays,2).*(alphaOT(pays).*(Consoloc(:,indice_OT-nbsecteurenergie)-bnOT(pays))).^(-sigmatrans(pays))+betatrans(pays,3).*(Tautomobileloc-bnautomobile(pays)).^(-sigmatrans(pays))+betatrans(pays,4).*(TNMloc-bnNM(pays)).^(-sigmatrans(pays))).*(-muloc.*pkmautomobileref(pays)./(100).*toNM(pays));

    y = matrix(y1,1,(nb_secteur_conso+2));
endfunction


//function that compute household final energy demand based on their consumption
// at the moment housing is not included
function [y] = DFinduite_pays(Consoloc,Tautomobileloc) ;

    y1 = zeros(1,sec);
    //see calibratin problems
    y1(:,indice_energiefossile1:indice_energiefossile2)=DFref(pays,indice_energiefossile1:indice_energiefossile2);
    //consumption sectors
    y1(:,indice_construction)=Consoloc(:,indice_construction-nbsecteurenergie);
    y1(:,indice_composite)=Consoloc(:,indice_composite-nbsecteurenergie)+Tautomobileloc.*alphaCompositeauto(pays).*pkmautomobileref(pays)./100;
    y1(:,indice_mer)=Consoloc(:,indice_mer-nbsecteurenergie);
    y1(:,indice_air)=Consoloc(:,indice_air-nbsecteurenergie);
    y1(:,indice_OT)=Consoloc(:,indice_OT-nbsecteurenergie);
    y1(:,indice_agriculture)=Consoloc(:,indice_agriculture-nbsecteurenergie);
    y1(:,indice_industries)=Consoloc(:,indice_industries-nbsecteurenergie);
    //energyh induced consumption
    y1(:,indice_Et)=Tautomobileloc.*alphaEtauto(pays).*pkmautomobileref(pays)./100+alphaEtm2(pays).*stockbatiment(pays);
    y1(:,indice_elec)=alphaelecm2(pays).*stockbatiment(pays)+Tautomobileloc.*alphaelecauto(pays).*pkmautomobileref(pays)./100;
    y1(:,indice_coal)=alphaCoalm2(pays).*stockbatiment(pays);
    y1(:,indice_gas)=alphaGazm2(pays).*stockbatiment(pays);

    y=y1;
endfunction


function [y] = Household_budget_pays(Rdisploc,Consoloc,Tautomobileloc) ;

    //DFloc=DFinduite(Consoloc,Tautomobileloc);
    // warning : Rdisp includes income taxes and pArmDF includes all taxes
    y1 = ptc(pays)-sum((DFloc.*pArmDF(pays,:)),'c')./(Rdisploc.*(1-IR(pays)));
    y=y1';
endfunction


function [y] = Time_budget_pays(Consoloc,Tautomobileloc,TNMloc);
    //y1 = ones(reg,1)-((Tautomobileloc.*(pkmautomobileref/100).*toautomobile.*(atrans(:,3).*tanh(((pkmautomobileref./(100*ones(reg,1))).*Tautomobileloc./Captransport(:,3)-xotrans(:,3)).*gammatrans(:,3))+btrans(:,3))+(pkmautomobileref/100).*alphaair.*Consoloc(:,indice_air-nbsecteurenergie).*toair.*(atrans(:,1).*tanh(((pkmautomobileref./(100*ones(reg,1))).*alphaair.*Consoloc(:,indice_air-nbsecteurenergie)./Captransport(:,1)-xotrans(:,1)).*gammatrans(:,1))+btrans(:,1))+(pkmautomobileref/100).*alphaOT.*Consoloc(:,indice_OT-nbsecteurenergie).*toOT.*(atrans(:,2).*tanh(((pkmautomobileref./(100*ones(reg,1))).*alphaOT.*Consoloc(:,indice_OT-nbsecteurenergie)./Captransport(:,2)-xotrans(:,2)).*gammatrans(:,2))+btrans(:,2))+(pkmautomobileref/100).*TNMloc.*toNM))./Tdisp;
    y1 = ones(1,1)-((Itautomobile_pays(Tautomobileloc)+Itair_pays(Consoloc)+ItOT_pays(Consoloc)+(pkmautomobileref(pays)/100).*TNMloc.*toNM(pays)))./Tdisp(pays);
    y=y1';
endfunction


function noCVIflag = compute_cvi(SAVEDIRALTER, SAVEDIRREF,listepays,forceRecalc)
    //Computes CVI between runs in SAVEDIRALTER and SAVEDIRREF. Saves in SAVEDIRALTER.
    //INPUTS
    //  SAVEDIRALTER: A savedir. Optional. Will be prompted if not provided.
    //  SAVEDIRREF  : A savedir. Optional. Will be prompted if not provided.
    //  listepays   : OPTIONAL. Default is (1:reg). An interger row. Liste of regions where CVI should be computed
    //  forceRecalc : Bolean. Default %f. Forces to compute cvi even if a CVI.dat is found in SAVEDIRALTER.
    //  OUTPUTS
    //  noCVIflag   : Boolean. %t if CVI was not calculated AND is not already present in SAVEDIRALTER

    //PREMABULE
    if argn(2)<1
        SAVEDIRALTER= uigetdir (OUTPUT,'Please choose SAVEDIRALTER. There will be saved CVI and Surplus')
    end
    if argn(2)<2
        SAVEDIRREF = uigetdir (OUTPUT,'Please choose SAVEDIRREF, which is the reference scenario. ALTER was : '+SAVEDIRALTER)
    end
    if argn(2)<3
        listepays = 1:reg;
    end
    if argn(2)<4
        forceRecalc = %f;
    end

    //remembers current workdir
    ccvi_prevdir = pwd()

    //Routine test
    SAVEDIRALTER= pathconvert (SAVEDIRALTER,%t);//scilab function that add '/' to SAVEDIR
    SAVEDIRREF  = pathconvert (SAVEDIRREF,%t);

    //default value
    noCVIflag=%t

    if ~and(check_wasdone([SAVEDIRALTER SAVEDIRREF]))
        disp( 'in compute_cvi, one of the next was not done:')
        say( 'SAVEDIRALTER','SAVEDIRREF')
        return
    end

    if isfile (SAVEDIRALTER+'save/CVI.dat') & ~forceRecalc //This happens if the file exists yet
        noCVIflag = %f
        return
    end

    if ~isfile (SAVEDIRALTER+'save/UtilityHH.dat') //This happens if the file doesn't exist
        disp( ' no UtilityHH exception. UtilityHH.dat should exist in SAVEDIRREF.')
        noCVIflag = %t
        return
    end

    //WORK

    //Gathering generic params
    //Dynamic coeffs used in the equiilibrium functions (imaclim.sci)
    varalpha=[ 'Captransport'
    'alphaEtauto'
    'alphaelecauto'
    'alphaCompositeauto'
    'bnautomobile'
    'xsi'
    'stockbatiment'
    'alphaEtm2'
    'alphaelecm2'
    'alphaCoalm2'
    'alphaGazm2'
    'ptc'
    'Tdisp'
    ];

    //technical coefficient save by save_generic
    varTmp=[ 'Conso'
    'Tautomobile'
    'TNM'
    'lambda'
    'mu'
    'Rdisp_REF'
    'Utility_REF'
    'pArmDF'
    varalpha
    ];

    load( CALIB+'calib.dat','bnNM','bn','bnair','alphaOT','bnOT','xsiT',..
        'toOT','toautomobile','toNM','IR','DFref','betatrans','alphaair',..
    'sigmatrans','pkmautomobileref','toair','atrans','btrans','ktrans','make_calib_trace_id');


    //Gathering alter scenario params
    SAVEDIR = SAVEDIRALTER
    cd(MODEL);
    exec 'get_all_sg_var.sce';
    ldsav( varalpha+'_sav');
    execstr ( varalpha+'='+varalpha+'_sav');

    //Load the REFERENCE scenario
    SAVEDIR = SAVEDIRREF
    cd(MODEL);
    exec 'get_all_sg_var.sce';

    ldsav ( 'UtilityHH','',SAVEDIRREF)
    Utility_REF	=UtilityHH;

    //Compute the CVI
    //Initialisation of CVI and the Surplus
    CVI=zeros(reg,TimeHorizon+1);
    Surplus=zeros(reg,TimeHorizon+1);

    //Compute the CVI (Compensating Variation of Income) and the Surplus
    execstr ( varTmp+'_glo = '+varTmp);
    disp( 'Compare CVI: there we go'); timer;
    winId=waitbar( 'CVI in process. ');

    for pays=listepays
        for i=1:TimeHorizon+1
            execstr (varTmp+'=matrix('+varTmp+'_glo(:,i),reg,-1);');

            CVI(pays,i)=fsolve(0,CalculCVI_pays)
            // if execstr ( 'CVI(pays,i)=fsolve(0,CalculCVI_pays);','errcatch')
            // disp( lasterror(),'! Error with the CalculCVI fsolve');
            // break //return
            // end
            Surplus(pays,i)=Rdisp(pays,i)-Rdisp_REF(pays)-CVI(pays,i);
            waitbar( ((find(pays==listepays)-1)*(TimeHorizon+1)+i)/((TimeHorizon+1)*size(listepays,2)),winId);
        end
    end


    winclose(winId);
    disp( 'COMPARE CVI WAS DONE in CPU '+int(timer())+'s');

    mksav ('CVI',SAVEDIRALTER)
    mksav ('Surplus',SAVEDIRALTER)
    mkcsv ('CVI',SAVEDIRALTER)
    mkcsv ('Surplus',SAVEDIRALTER)
    disp( 'Results from CVI were stored in ALTER: '+SAVEDIRALTER);
    noCVIflag=%f

    //TERMINATE
    cd(ccvi_prevdir)

endfunction
