// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Adrien Vogt-Schilb, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// allow to use extraction.sce without changing the name of existing variables

//PREAMBLE
exec (".."+filesep()+"preamble.sce");

if ~isdef("SAVEDIR")
    SAVEDIR = uigetdir(OUTPUT,"SAVEDIR please") 
end

// get variable which end by REF
exec ( MODEL +"make_calib.dat.sce");

// get variable used in Extraction.sce
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
