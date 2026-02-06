// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

if ~isdef("SAVEDIR")
    exec (".."+filesep()+"preamble.sce");
    SAVEDIR = uigetdir(OUTPUT,"SAVEDIR please") 
end

//exec(MODEL + "make_calib.sav.sce");

combi = run_name2combi(SAVEDIR);
[ind_climat,ind_EEI,ind_CCS,ind_NUC,ind_ENR,ind_bioEnergy]=combi2indices(combi);

wasdone = isfile(SAVEDIR+"\save\IamDoneFolks.sav")

//////////////////////////////////////////// carbon tax
nbMKT = get_nbMKT(combi);

carbonTax = zeros(nbMKT,TimeHorizon+1);
if ind_climat
    // out=sg_get_var(matname,[which_lines,[which_columns,[nb_lines,[should_revert,[which_years]]]]])
    carbonTax = sg_get_var("taxMKT");
end
mksav 'carbonTax'

///////////////////////////////////////////////////Total CO2 emission in ton

//world emissions
ECO2W = sum(sg_get_var("E_reg_use",:),"r");
mksav 'ECO2W'

//emissions per region
for k=1:reg
    ECO2reg(k,:) = sum(sg_get_var("E_reg_use",k),"r");
end

//emissions before sequestration
ECO2woCCSw=sum(sg_get_var("E_CO2_wo_CCS",:),"r");
mksav 'ECO2woCCSw'


//emissions per usage
for u=1:nb_use
    ECO2W_use(u,:) = sum(sg_get_var("E_reg_use",:,u),"r");
end

emi_usage = [usenames, ECO2W_use];
mkcsv emi_usage

///////////////////////////////////////////////////////////// mobility
//cars
//cars_out = [ strcomb(regnames(1:4), carnames) sg_get_var("MSH_cars",1:4)];
//mkcsv cars_out

//pkmAir=sg_get_var("Tair").*sg_get_var("alphaair").*(pkmautomobileref*ones(1,TimeHorizon+1))/100;
//pkmAuto=(sg_get_var("Tautomobile").*(pkmautomobileref*ones(1,TimeHorizon+1)/100));
//pkmOT=sg_get_var("TOT").*sg_get_var("alphaOT").*(pkmautomobileref*ones(1,TimeHorizon+1))/100;
//pkmNM=sg_get_var("TNM").*(pkmautomobileref*ones(1,TimeHorizon+1))/100;


///////////////////////////////////////////////// energies fossiles
wp_coal=sg_get_var("wp",:,indice_coal,1);
wp_oil=sg_get_var("wp",:,indice_oil,1)/ 7.33;
wp_gas=sg_get_var("wp",:,indice_gas,1);

mksav("wp_coal");
mksav("wp_oil");
mksav("wp_gas");

pIndEner=sg_get_var("pIndEner");

Qcoal = sg_get_var("Q",:,indice_coal);
Qgas = sg_get_var("Q",:,indice_gas);
Qoil = sg_get_var("Q",:,indice_oil)*7.33/365;
charge_oil = sg_get_var("charge",:,indice_oil);

if wasdone
    Cap_oil=Qoil./charge_oil;
end

Qcoalw=sum (Qcoal,"r");
Qgasw=sum (Qgas,"r");
Qoilw=sum (Qoil,"r");

mksav 'Qcoalw'
mksav 'Qgasw'
mksav 'Qoilw'

QCTLw=sum(sg_get_var("Q_CTL_anticip_sav",:),"r");
mksav 'QCTLw'

p_CTL=sg_get_var("p_CTL_mtep");
wp_Et=sg_get_var("wp",:,indice_Et,1);

mksav wp_Et

Qbiofuelsw=sum(sg_get_var("Q_biofuel_anticip",:),"r");
mksav 'Qbiofuelsw'

///////////////////////////////////////////////////////////energie perr usage

//energie per usage
for u=1:nb_use
    EnerW_use(u,:) = sum(sg_get_var("Ener_reg_use",:,u),"r");
end

ener_usage = [usenames, EnerW_use];
mkcsv ener_usage

///////////////////////////////////////////////////////////// TPES & TFC
TPESw=sum(sg_get_var("TPES"),"r");
mksav TPESw

TPESocde=sum(sg_get_var("TPES",1:4),"r");
mksav TPESocde

TPESrow=sum(sg_get_var("TPES",5:12),"r");
mksav TPESrow

TFCw=sum(sg_get_var("TFC"),"r");
mksav TFCw

TFCocde=sum(sg_get_var("TFC",1:4),"r");
mksav TFCocde

TFCrow=sum(sg_get_var("TFC",5:12),"r");
mksav TFCrow

//////////////////////////////////////////////////////macro

GDP     = sgv("GDP");
GDP_MER_nominal = sgv("GDP_MER_nominal");
GDP_MER_real    = sgv("GDP_MER_real");
GDP_PPP_constant   = sgv("GDP_PPP_constant");

////////////////////////////////////////////////energy intensity
//if wasdone
//    IEw=TFCw./realGDPw;
//    IEocde=TFCocde./realGDPocde;
//    IErow=TFCrow./realGDProw;
//else
//    IEw=zeros(1,TimeHorizon+1);
//    IEocde=zeros(1,TimeHorizon+1);
//    IErow=zeros(1,TimeHorizon+1);
//end
//
//mksav IEw
//mksav IEocde
//mksav IErow

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Hosehold utility

//xsi=sg_get_var("xsi");
//xsiT=sg_get_var("xsiT");
//bnautomobile=sg_get_var("bnautomobile");
//Tautomobile=sg_get_var("Tautomobile");
//TNM=sg_get_var("TNM");
//UtilityHH=zeros(reg,TimeHorizon+1);
//if wasdone
//    for k=1:TimeHorizon+1
//        xsi_temp=matrix(xsi(:,k),reg,(nb_secteur_conso-2));
//        bnautomobile_temp=bnautomobile(:,k);
//        Tautomobile_temp=Tautomobile(:,k);
//        TNM_temp=TNM(:,k);
//        DF_temp=matrix(DF(:,k),reg,sec);
//        Conso_temp=DF_temp(:,sec-nb_secteur_conso+1:sec);
//        UtilityHH(:,k)=log(Conso_temp(:,indice_construction-nbsecteurenergie)-bn(:,indice_construction)).*xsi_temp(:,1)+...
//                       log(Conso_temp(:,indice_composite-nbsecteurenergie)       -bn(:,indice_composite)).*xsi_temp(:,2)+...
//                       log(Conso_temp(:,indice_mer-nbsecteurenergie)             -bn(:,indice_mer)).*xsi_temp(:,3)+...
//                       log(Conso_temp(:,indice_agriculture-nbsecteurenergie)  -bn(:,indice_agriculture)).*xsi_temp(:,4)+...
//                       log(Conso_temp(:,indice_industrie-nbsecteurenergie)      -bn(:,indice_industrie)).*xsi_temp(:,5)+...
//                       -xsiT(:,k)./sigmatrans.*log(betatrans(:,1).*(alphaair.*(Conso_temp(:,indice_air-nbsecteurenergie)-bnair)).^(-sigmatrans)+betatrans(:,2).*(alphaOT.*(Conso_temp(:,indice_OT-nbsecteurenergie)-bnOT)).^(-sigmatrans)+betatrans(:,3).*(Tautomobile_temp-bnautomobile_temp).^(-sigmatrans)+betatrans(:,4).*(TNM_temp-bnNM).^(-sigmatrans));
//                       
//    end		
//end
//mksav("UtilityHH");

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////elec

Qelec=sg_get_var("Q",:,indice_elec);
Qelecw=sum(sg_get_var("Q",:,indice_elec),"r");

mksav Qelecw

Cap_elec_MW=sg_get_var("Cap_elec_MW");

titres_elec = strcomb ( regnames, elecnames);

//rapport_elec = [ ['' '' string(2000+(1:TimeHorizon+1))]; [titres_elec, string(Cap_elec_MW)]];
//
//mkcsv rapport_elec

IC_elec=[
sg_get_var("IC_2190")
sg_get_var("IC_3650")
sg_get_var("IC_5110")
sg_get_var("IC_6570")
sg_get_var("IC_730" )
sg_get_var("IC_8030")
sg_get_var("IC_8760")
];

mksav IC_elec

wp_elec=sg_get_var("wp",:,indice_elec,1);

mksav wp_elec

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////// residentiel
consoCoalm2w=sum(sg_get_var("alphaCoalm2").*sg_get_var("stockbatiment"),"r");
consoelecm2w=sum(sg_get_var("alphaelecm2").*sg_get_var("stockbatiment"),"r");
consoEtm2w  =sum(sg_get_var("alphaEtm2"  ).*sg_get_var("stockbatiment"),"r");
consoGazm2w =sum(sg_get_var("alphaGazm2" ).*sg_get_var("stockbatiment"),"r");

conso_ener_resid=consoCoalm2w+consoelecm2w+consoEtm2w+consoGazm2w;

mksav conso_ener_resid


titres_output=[
"ECO2reg"
"pkmAir"
"pkmAuto"
"pkmOT"
"pkmNM"
"wp_coal"
"p_CTL"
"wp_oil"
"wp_Et"
"wp_gas"
"wp_elec"
"pIndEner"
"Qcoalw"
"Qoilw"
"Qgasw"
"QCTLw"
"Qbiofuelsw"
"TPESocde"
"TPESrow"
"TPESw"
"TFCocde"
"TFCrow"
"TFCw"
"IEocde"
"IErow"
"IEw"
"realGDPocde"
"realGDProw"
"realGDPw"
"Qelecw"
"conso_ener_resid"
];

//output=[];
//for data=titres_output'
//    execstr ("output=[output;[data+emptystr(size("+data+",1),1),"+data+"]];");
//end
 
//execstr("output_"+ETUDE+" = [ ["""" string(2000+(1:TimeHorizon+1))]; output];")
//
//mkcsv("output_"+ETUDE);

//ldcsv("sorties_EMF24");
//smoothEMF = customSmooth(sorties_EMF24);
//smoothEMF24 = smoothEMF(:,[5 10:10:TimeHorizon+1]-1);
//mkcsv("smoothEMF24");
//mkcsv("smoothEMF24",OUTPUT);



execstr("outputs_"+ETUDE+"=csvRead("""+SAVEDIR+"outputs_"+ETUDE+fit_combi(combi)+".csv"",""|"",[],[],[],""/\/\//"");");
yearlySmoothOutputs= customSmooth(eval("outputs_"+ETUDE));
yearlyOutputs= eval("outputs_"+ETUDE);

if do_smooth_outputs==%t
    execstr("sel_outputs_"+ETUDEOUTPUT+" = yearlySmoothOutputs(:, year_to_select)");
else
    execstr("sel_outputs_"+ETUDEOUTPUT+" = yearlyOutputs(1:(13*nbLines), year_to_select)");
end
mkcsv("sel_outputs_"+ETUDEOUTPUT);
mkcsv("sel_outputs_"+ETUDEOUTPUT,OUTPUT);


