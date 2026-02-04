// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//////////////////////////////////////////////////////////////////////////////
//                        Load of hybrid data                               //
//////////////////////////////////////////////////////////////////////////////

listGTAPdatas = ["C_Hsld_dom_corr",..
"C_Hsld_imp_corr",..
"C_G_dom_corr",..
"C_G_imp_corr",..
"C_FBCF_dom_corr",..
"C_FBCF_imp_corr",..
"x_corr",..
"X_Trans_corr",..
"CI_dom_Agg_corr_Trans",..
"CI_imp_Agg_corr",..
"SALNET",..
"Profit",..
"sigma",..
"mm",..
"m_fob_corr",..
"M_Trans_corr",..
"Tprod",..
"T_ConsFact_Agg",..
"T_CI_dom_Agg_corr",..
"T_CI_imp_Agg_corr",..
"T_FBCF_dom_Agg_corr",..
"T_FBCF_imp_Agg_corr",..
"THsld_Dom_corr",..
"THsld_Imp_corr",..
"TG_Dom_corr",..
"TG_Imp_corr",..
"Tmtax_corr",..
"Txtax_corr",..
"Auto_TMX",..
"Q",..
"CFact_Agg",..
"Epargne_Agg"];

execstr("load ( GTAP + ''" + listGTAPdatas + ".sav'' );");


