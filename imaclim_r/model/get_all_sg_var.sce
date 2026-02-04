// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Adrien Vogt-Schilb
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//rustine pour pouvoir utiliser Extraction.sce sans changer le no nom des variables existantes, tout en utilisant save_generic à la place de resdyn


//PREAMBULE
exec (".."+filesep()+"preamble.sce");

if ~isdef("SAVEDIR")
    SAVEDIR = uigetdir(OUTPUT,"SAVEDIR please") 
end

//Recuperation des variables dont le nom fini par REF (en gros)
exec ( MODEL +"make_calib.sav.sce");

//Recupere la liste des variables utilisées dans Extraction.sce
sg_varnams_list=[
"alphaEtauto"
"alphaair"
"alphaOT"
"Captransport"
"Cap_elec_MW"
"Inv_MW"
"charge"
"CI"
"coef_Q_CO2_CI"
"coef_Q_CO2_DF"
"Conso"
"DeltaK"
"DF"
"DI"
"DIinfra"
"div"
"Exp"
"GDP"
"GRB"
"Imp"
"K"
"K_depreciated"
"Lact"
"lambda"
"Ltot"
"markup"
"mu"
"NRB"
"p"
"pArmCI"
"pArmDF"
"pArmDI"
"partInvFin"
"pind"
"pind_prod"
"pK"
"progestechl"
"ptc"
"Q"
"Rdisp"
"rhoeleccoal"
"rhoelecEt"
"rhoelecgaz"
"rho_elec_moyen"
"share_NC"
"stockautomobile"
"stockautomobile"
"stockbatiment"
"Tair"
"Tautomobile"
"TNM"
"TOT"
"VA"
"w"
"wp"
"wpTI"
"Z"
];


for data=sg_varnams_list'
    execstr(data+"=sg_get_var(data)");
end
