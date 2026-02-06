// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


//acd '../model';
//exec("preamble.sce");
year_begin = 2014;

nb_sectors_industry=1;
nb_sectors_services=1;
PARENT  = pwd();
cd( "../");
exec("model/indexes.sce");
cd(PARENT);

output_ = "./4006_base.tax201970.taxbreak_11000.tax21001500.18_2024_06_30_14h05min34s/"
output_dir = output_ + "/save/"
output_folder = output_ + "/csv/";
mkdir(output_folder);

// NOTE : same name
//#Variables present in folder: ['A', 'CI', 'Cap', 'Captransport', 'DF', 'DG', 'DI', 'DIinfra', 'Exp', 'ExpTI', 'GRB', 'IR', 'Imp', 'L', 'NRB', 'QuotasRevenue', 'Rdisp', 'TNM', 'Tautomobile', 'Tdisp', 'Ttax', 'aRD', 'alphaCoalm2', 'alphaCompositeauto', 'alphaEtauto', 'alphaEtm2', 'alphaGazm2', 'alphaOT', 'alpha_partCI', 'alphaair', 'alphaelecauto', 'alphaelecm2', 'atrans', 'aw', 'bCI', 'bRD', 'bmarketshareener', 'bn', 'btrans', 'bw', 'cRD', 'coef_Q_CO2_CI', 'coef_Q_CO2_DF', 'cw', 'energ_sec', 'eta', 'etaCI', 'etaTI', 'etamarketshareener', 'inertia_share', 'itgbl_cost_CIdom', 'itgbl_cost_CIimp', 'lambda', 'marketshare', 'markup', 'markup_lim_oil', 'mtax', 'mu', 'nit', 'non_energ_sec', 'p', 'pArmCI', 'pArmDF', 'pArmDG', 'pArmDI', 'p_stock', 'partDomCI', 'partDomCI_stock', 'partDomCIref', 'partDomDF', 'partDomDG', 'partDomDI', 'partExpK', 'partImpCI', 'partImpDF', 'partImpDG', 'partImpDI', 'partImpK', 'pind', 'ptc', 'qtax', 'sigma', 'sigmatrans', 'stockbatiment', 'taxCIdom', 'taxCIimp', 'taxCO2_CI', 'taxCO2_DF', 'taxDFdom', 'taxDFimp', 'taxDGdom', 'taxDGimp', 'taxDIdom', 'taxDIimp', 'toNM', 'toOT', 'toair', 'toautomobile', 'w', 'weight', 'weightTI', 'wp', 'wpEner', 'wpTI', 'wpTIagg', 'xsi', 'xsiT', 'xtax']
// marketshareTI/

// NOTE : compute with reference year
// 'DFref', 'DIref', 'markupref', 'pArmDFref', 'partDomref', 'partTIref', 'pindref', 'pkmautomobileref', 'pref', 'wpEnerref', 'wref', 'xtaxref', p_stock, partDom_stock partDomCI_stock
// partDomCIref

// NOTE : not same name
// itgbl_cost_dom + itgbl_cost_imp : itgbl_cost_DF & co
// coef_Q_CO2 	: coef_Q_CO2_DF & co
// lll : l
// divi : div
// taxCO2 : taxCO2_DF 
// partImp partDom, partDom_stock : partDomDF, partDomDG, partDomDI
// pArm :  'pArmCI', 'pArmDF', 'pArmDG', 'pArmDI',
// taxCI : taxCIdom taxCIimp
// z_unemploy : Z
// wpTIagg_sav.sav 
// alphaTrans : alphaair_sav.sav  alphaOT_sav.sav
//alpha_part : alpha_partDF_sav.sav alpha_partDF_sav.sav alpha_partDF_sav.sav
// etaA	 etaDF_sav.sav etaDF_sav.sav etaDF_sav.sav 
// bA bDF_sav.sav bDF_sav.sav bDF_sav.sav bDF_sav.sav 
//  : toair_sav.sav TNM_sav.sav toautomobile_sav.sav toNM_sav.sav toOT_sav.sav TOT_sav.sav, toNM

// NOTE : to compute inside gamspy
// 'FCC', 'FCCmarkup_oil', partImp, taxdom taximp taxCI, pImp, pArmTrans,  'Utility', 'UtilityTrans', 'UtilityTrans_temp'
// 'TAXCO2', 'TAXCO2_dom', 'TAXCO2_imp', 'TAXTCO2',  mult, nbsecteurenergie, shareBiomassTaxElec, ConsoTrans, Conso, Cons_transport,  ItTrans, sumtax


//###################################
// OUTPUT VAR

// reg, sec 
varnames_normal = ['Q_sav','Cap_sav', 'A_sav', 'DF_sav', 'DG_sav', 'DI_sav', 'DIinfra_sav', 'Exp_sav', 'ExpTI_sav', 'Imp_sav', 'Ttax_sav', 'aRD_sav', 'cRD_sav', 'bRD_sav', 'bn_sav', 'coef_Q_CO2_DF_sav', 'coef_Q_CO2_DI_sav', 'coef_Q_CO2_DG_sav', 'marketshare_sav', 'markup_sav', 'markup_lim_oil_sav', 'mtax_sav', 'nit_sav', 'p_sav', 'pArmDF_sav', 'pArmDG_sav', 'pArmDI_sav', 'partDomDF_sav', 'partDomDG_sav', 'partDomDI_sav', 'partImpDF_sav', 'partImpDG_sav', 'partImpDI_sav', 'qtax_sav', 'sigma_sav', 'taxCO2_DF_sav', 'taxDFdom_sav', 'taxDFimp_sav', 'taxDGdom_sav', 'taxDGimp_sav', 'taxDIdom_sav', 'taxDIimp_sav', 'w_sav', 'xtax_sav', 'l_sav', 'taxCO2_DF_sav', 'taxCO2_DG_sav', 'taxCO2_DI_sav']
for varname = varnames_normal

    fileout = mopen(output_folder+varname+'.csv', "w");
    load(output_dir+varname+".sav");
    execstr("var="+varname+";");
    nb_year = size(var,"c");

    mfprintf(fileout, "year|region|sector|level" );
    mfprintf(fileout, "\n");
    for isec = 1:nb_sectors
        for ireg = 1:nb_regions
            for iyear = 1:nb_year
                year = year_begin + iyear -1;
                str_to_exec = "value = "+varname+"("+msprintf("%d, %d", (isec-1)*nb_regions+ireg, iyear)+")";
                execstr(str_to_exec);
                mfprintf(fileout, "%.20G|%s|%s|%.20G", year, regnames(ireg), secnames(isec), value );
                mfprintf(fileout, "\n");
            end
        end
    end
    mclose(fileout);
end

// reg, nbsecteurenergie
varnames_normal = ['bmarketshareener_sav', 'itgbl_cost_DFdom_sav', 'itgbl_cost_DFimp_sav', 'itgbl_cost_DGdom_sav', 'itgbl_cost_DGimp_sav', 'itgbl_cost_DIdom_sav', 'itgbl_cost_DIimp_sav', 'alpha_partDF_sav', 'alpha_partDG_sav', 'alpha_partDI_sav'];
for varname = varnames_normal

    fileout = mopen(output_folder+varname+'.csv', "w");
    load(output_dir+varname+".sav");
    execstr("var="+varname+";");
    nb_year = size(var,"c");

    mfprintf(fileout, "year|region|sector|level" );
    mfprintf(fileout, "\n");
    for isec = 1:nbsecteurenergie
        for ireg = 1:nb_regions
            for iyear = 1:nb_year
                year = year_begin + iyear -1;
                str_to_exec = "value = "+varname+"("+msprintf("%d, %d", (isec-1)*nb_regions+ireg, iyear)+")";
                execstr(str_to_exec);
                mfprintf(fileout, "%.20G|%s|%s|%.20G", year, regnames(ireg), secnames(isec), value );
                mfprintf(fileout, "\n");
            end
        end
    end
    mclose(fileout);
end

// reg, (sec-nbsecteurenergie)
varnames_normal  = ['weight_sav', 'etaDF_sav', 'etaDI_sav', 'etaDG_sav', 'bDF_sav', 'bDG_sav', 'bDI_sav'];
for varname = varnames_normal

    fileout = mopen(output_folder+varname+'.csv', "w");
    load(output_dir+varname+".sav");
    execstr("var="+varname+";");
    nb_year = size(var,"c");

    mfprintf(fileout, "year|region|sector|level" );
    mfprintf(fileout, "\n");
    for isec = 1:(nb_sectors-nbsecteurenergie)
        for ireg = 1:nb_regions
            for iyear = 1:nb_year
                year = year_begin + iyear -1;
                str_to_exec = "value = "+varname+"("+msprintf("%d, %d", (isec-1)*nb_regions+ireg, iyear)+")";
                execstr(str_to_exec);
                mfprintf(fileout, "%.20G|%s|%s|%.20G", year, regnames(ireg), secnames(nbsecteurenergie+isec), value );
                mfprintf(fileout, "\n");
            end
        end
    end
    mclose(fileout);
end

//reg,nb_trans
varnames_normal = ['Captransport_sav', 'atrans_sav', 'btrans_sav', 'ktrans_sav', 'weightTI_sav', 'marketshareTI_sav'];
for varname = varnames_normal

    fileout = mopen(output_folder+varname+'.csv', "w");
    load(output_dir+varname+".sav");
    execstr("var="+varname+";");
    nb_year = size(var,"c");

    mfprintf(fileout, "year|region|sector|level" );
    mfprintf(fileout, "\n");
    for isec = 1:nb_trans
        for ireg = 1:nb_regions
            for iyear = 1:nb_year
                year = year_begin + iyear -1;
                str_to_exec = "value = "+varname+"("+msprintf("%d, %d", (isec-1)*nb_regions+ireg, iyear)+")";
                execstr(str_to_exec);
                mfprintf(fileout, "%.20G|%s|%s|%.20G", year, regnames(ireg), secnames(indice_transport_1-1+isec), value );
                mfprintf(fileout, "\n");
            end
        end
    end
    mclose(fileout);
end

//"xsi",xsi,reg,sec-nbsecteurenergie-nb_trans+1);
for varname = ['xsi_sav']

    fileout = mopen(output_folder+varname+'.csv', "w");
    load(output_dir+varname+".sav");
    execstr("var="+varname+";");
    nb_year = size(var,"c");

    mfprintf(fileout, "year|region|sector|level" );
    mfprintf(fileout, "\n");
    for isec = 1:(nb_sectors-nbsecteurenergie-nb_trans+1)
        for ireg = 1:nb_regions
            for iyear = 1:nb_year
                year = year_begin + iyear -1;
                str_to_exec = "value = "+varname+"("+msprintf("%d, %d", (isec-1)*nb_regions+ireg, iyear)+")";
                execstr(str_to_exec);
                mfprintf(fileout, "%.20G|%s|%s|%.20G", year, regnames(ireg), secnames(ind_sector_util(isec)), value );
                mfprintf(fileout, "\n");
            end
        end
    end
    mclose(fileout);
end

// CI dim
varnames_normal = ['CI_sav','coef_Q_CO2_CI_sav', 'pArmCI_sav', 'partDomCI_sav', 'partImpCI_sav', 'taxCIdom_sav', 'taxCIimp_sav', 'taxCO2_CI_sav'];
for varname = varnames_normal

    fileout = mopen(output_folder+varname+'.csv', "w");
    load(output_dir+varname+".sav");
    execstr("var="+varname+";");
    nb_year = size(var,"c");

    mfprintf(fileout, "year|region|sector_out|sector_in|level" );
    mfprintf(fileout, "\n");
    for isec_out = 1:nb_sectors
        for jsec_in = 1:nb_sectors
            for ireg = 1:nb_regions
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    str_to_exec = "value = "+varname+"("+msprintf("%d, %d",  (ireg-1)*nb_sectors*nb_sectors + (isec_out-1)*nb_sectors  + jsec_in,iyear)+")"; //check here the order
                    execstr(str_to_exec);
                    mfprintf(fileout, "%.20G|%s|%s|%s|%.20G", year, regnames(ireg), secnames(isec_out), secnames(jsec_in), value );
                    mfprintf(fileout, "\n");
                end
            end
        end
    end
    mclose(fileout);
end

// alpha_partCI,nbsecteurenergie,sec,reg
varnames_normal = ['alpha_partCI_sav', 'itgbl_cost_CIdom_sav', 'itgbl_cost_CIimp_sav'];
for varname = varnames_normal

    fileout = mopen(output_folder+varname+'.csv', "w");
    load(output_dir+varname+".sav");
    execstr("var="+varname+";");
    nb_year = size(var,"c");

    mfprintf(fileout, "year|region|sector_out|sector_in|level" );
    mfprintf(fileout, "\n");
    for isec_out = 1:nb_sectors
        for jsec_in = 1:nbsecteurenergie
            for ireg = 1:nb_regions
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    str_to_exec = "value = "+varname+"("+msprintf("%d, %d",  (ireg-1)*nb_sectors*nbsecteurenergie + (isec_out-1)*nbsecteurenergie  + jsec_in,iyear)+")"; //check here the order
                    execstr(str_to_exec);
                    mfprintf(fileout, "%.20G|%s|%s|%s|%.20G", year, regnames(ireg), secnames(isec_out), secnames(jsec_in), value );
                    mfprintf(fileout, "\n");
                end
            end
        end
    end
    mclose(fileout);
end

// bCI,sec-nbsecteurenergie,sec,reg
varnames_normal = ['bCI_sav', 'etaCI_sav'];
for varname = varnames_normal

    fileout = mopen(output_folder+varname+'.csv', "w");
    load(output_dir+varname+".sav");
    execstr("var="+varname+";");
    nb_year = size(var,"c");

    mfprintf(fileout, "year|region|sector_out|sector_in|level" );
    mfprintf(fileout, "\n");
    for isec_out = 1:nb_sectors
        for jsec_in = 1:(nb_sectors-nbsecteurenergie)
            for ireg = 1:nb_regions
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    str_to_exec = "value = "+varname+"("+msprintf("%d, %d",  (ireg-1)*nb_sectors*(nb_sectors-nbsecteurenergie) + (isec_out-1)*(nb_sectors-nbsecteurenergie) + jsec_in,iyear)+")"; //check here the order
                    execstr(str_to_exec);
                    mfprintf(fileout, "%.20G|%s|%s|%s|%.20G", year, regnames(ireg), secnames(isec_out), secnames(nbsecteurenergie+jsec_in), value );
                    mfprintf(fileout, "\n");
                end
            end
        end
    end
    mclose(fileout);
end

//reg
varnames_normal  = ['GRB_sav', 'IR_sav', 'L_sav', 'NRB_sav', 'QuotasRevenue_sav', 'Rdisp_sav', 'TNM_sav', 'Tautomobile_sav', 'Tdisp_sav', 'alphaCoalm2_sav', 'alphaCompositeauto_sav', 'alphaEtauto_sav', 'alphaEtm2_sav', 'alphaGazm2_sav', 'alphaOT_sav', 'alphaair_sav', 'alphaelecauto_sav', 'alphaelecm2_sav', 'aw_sav', 'bw_sav', 'cw_sav', 'lambda_sav', 'mu_sav', 'partExpK_sav', 'partImpK_sav', 'pind_sav', 'ptc_sav', 'sigmatrans_sav', 'stockbatiment_sav', 'toNM_sav', 'toOT_sav', 'toair_sav', 'toautomobile_sav', 'xsiT_sav', 'div_sav', 'Z_sav','pkmautomobileref']
for varname = varnames_normal

    fileout = mopen(output_folder+varname+'.csv', "w");
    load(output_dir+varname+".sav");
    execstr("var="+varname+";");
    nb_year = size(var,"c");

    mfprintf(fileout, "year|region|level" );
    mfprintf(fileout, "\n");
    for ireg = 1:nb_regions
        for iyear = 1:nb_year
            year = year_begin + iyear -1;
            str_to_exec = "value = "+varname+"("+msprintf("%d, %d", ireg, iyear)+")";
            execstr(str_to_exec);
            mfprintf(fileout, "%.20G|%s|%.20G", year, regnames(ireg), value );
            mfprintf(fileout, "\n");
        end
    end
    mclose(fileout);
end

//sec
for varname = ['wp_sav']

    fileout = mopen(output_folder+varname+'.csv', "w");
    load(output_dir+varname+".sav");
    execstr("var="+varname+";");
    nb_year = size(var,"c");

    mfprintf(fileout, "year|sector|level" );
    mfprintf(fileout, "\n");
    for i = 1:nb_sectors
        for iyear = 1:nb_year
            year = year_begin + iyear -1;
            str_to_exec = "value = "+varname+"("+msprintf("%d, %d", i, iyear)+")";
            execstr(str_to_exec);
            mfprintf(fileout, "%.20G|%s|%.20G", year, secnames(i), value );
            mfprintf(fileout, "\n");
        end
    end
    mclose(fileout);
end

// (sec-nbsecteurenergie) 
for varname = ['eta_sav']

    fileout = mopen(output_folder+varname+'.csv', "w");
    load(output_dir+varname+".sav");
    execstr("var="+varname+";");
    nb_year = size(var,"c");

    mfprintf(fileout, "year|sector|level" );
    mfprintf(fileout, "\n");
    for i = 1:(nb_sectors-nbsecteurenergie)
        for iyear = 1:nb_year
            year = year_begin + iyear -1;
            str_to_exec = "value = "+varname+"("+msprintf("%d, %d", i, iyear)+")";
            execstr(str_to_exec);
            mfprintf(fileout, "%.20G|%s|%.20G", year, secnames(nbsecteurenergie+i), value );
            mfprintf(fileout, "\n");
        end
    end
    mclose(fileout);
end

// nbsecteurenergie
for varname = ['wpEner_sav', 'etamarketshareener_sav']

    fileout = mopen(output_folder+varname+'.csv', "w");
    load(output_dir+varname+".sav");
    execstr("var="+varname+";");
    nb_year = size(var,"c");

    mfprintf(fileout, "year|sector|level" );
    mfprintf(fileout, "\n");
    for i = 1:nbsecteurenergie
        for iyear = 1:nb_year
            year = year_begin + iyear -1;
            str_to_exec = "value = "+varname+"("+msprintf("%d, %d", i, iyear)+")";
            execstr(str_to_exec);
            mfprintf(fileout, "%.20G|%s|%.20G", year, secnames(i), value );
            mfprintf(fileout, "\n");
        end
    end
    mclose(fileout);
end

// nb_trans
for varname = ['wpTI_sav','partTIref_sav']

    fileout = mopen(output_folder+varname+'.csv', "w");
    load(output_dir+varname+".sav");
    execstr("var="+varname+";");
    nb_year = size(var,"c");

    mfprintf(fileout, "year|sector|level" );
    mfprintf(fileout, "\n");
    for i = 1:nb_trans
        for iyear = 1:nb_year
            year = year_begin + iyear -1;
            str_to_exec = "value = "+varname+"("+msprintf("%d, %d", i, iyear)+")";
            execstr(str_to_exec);
            mfprintf(fileout, "%.20G|%s|%.20G", year, secnames(indice_transport_1-1+i), value );
            mfprintf(fileout, "\n");
        end
    end
    mclose(fileout);
end

// scalar
for varname = ['etaTI_sav', 'inertia_share_sav', 'wpTIagg_sav']
    fileout = mopen(output_folder+varname+'.csv', "w");
    load(output_dir+varname+".sav");
    execstr("var="+varname+";");
    nb_year = size(var,"c")
    mfprintf(fileout, "year|level" );
    mfprintf(fileout, "\n");
    for iyear = 1:nb_year
        year = year_begin + iyear -1;
        str_to_exec = "value = "+varname+"("+msprintf("%d", iyear)+")";
        execstr(str_to_exec);
        mfprintf(fileout, "%.20G|%.20G", year, value );
        mfprintf(fileout, "\n");
    end
    mclose(fileout);
end

