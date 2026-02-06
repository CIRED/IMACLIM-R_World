// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

list_var = ["reg","sec","nb_secteur_conso","indice_energiefossile1","indice_energiefossile2","indice_construction","nbsecteurenergie","indice_composite","indice_mer","indice_air","indice_OT","indice_Et","indice_elec","indice_coal","indice_oil","indice_gas","nb_trans","indice_transport_1","indice_transport_2","indice_agriculture","nb_sectors_industry","nbsecteurcomposite","nb_secteur_utile","nbMKT","nb_use","iu_df","iu_dg","iu_di","new_Et_msh_computation","exo_pkmair_scenario","DIprod","DFref","pArmDFref","xtaxref","wref","pref","markupref","indice_industries","pkmautomobileref","TNMref","wpEnerref","partTIref","pindref","partTIref","DIprod","pindref","etaTI","etaEtnew","inertia_share","A","aRD","bRD","cRD","DG","DIinfra","bn","Cap","coef_Q_CO2_DF","coef_Q_CO2_DG","coef_Q_CO2_DI","Ttax","xtax","l","markup","partDomDGref","partDomDIref","partDomDFref","markup_lim_oil","mtax","energ_sec","nit","non_energ_sec","partDomDF_stock","partDomDG_stock","partDomDI_stock","qtax","sigma","taxCO2_DF","taxCO2_DG","taxCO2_DI","taxDFdom","taxDFimp","taxDGdom","taxDGimp","taxDIdom","taxDIimp","alphaCompositeauto","weight_regional_tax","alphaEtauto","alphaelecauto","alphaEtm2","stockbatiment","alphaelecm2","alphaCoalm2","alphaGazm2","L","coef_Q_CO2_Et_prod","QuotasRevenue","alphaair","ptc","a4_mult_oil","a3_mult_oil","a2_mult_oil","a1_mult_oil","a0_mult_oil","a4_mult_gaz","a3_mult_gaz","a2_mult_gaz","a1_mult_gaz","a0_mult_gaz","a4_mult_coal","a3_mult_coal","a2_mult_coal","a1_mult_coal","a0_mult_coal","alphaOT","Rdisp","bnair","bnautomobile","bnNM","bnOT","Tautomobile","Tdisp","toair","DFair_exo","toautomobile","toNM","toOT","eta","etamarketshareener","aw","bw","cw","div","partExpK","partImpK","IR","sigmatrans","xsiT","weightEt_new","alpha_partDF","alpha_partDG","alpha_partDI","itgbl_cost_DFdom","itgbl_cost_DGdom","itgbl_cost_DIdom","itgbl_cost_DFimp","itgbl_cost_DGimp","itgbl_cost_DIimp","p_stock","bmarketshareener","atrans","btrans","Captransport","ktrans","weightTI","xsi","weight","bDF","bDG","bDI","etaDF","etaDG","etaDI","betatrans","Conso","bCI","etaCI","itgbl_cost_CIdom","itgbl_cost_CIdom","itgbl_cost_CIimp","partDomCIref","partDomCI_stock","taxCIdom","taxCIimp","alpha_partCI","taxCO2_CI","coef_Q_CO2_CI","CI","taxMKT","whichMKT_reg_use","CO2_obj_MKTparam","CO2_untaxed","areEmisConstparam","verbose","shareBiomassTaxElec","is_taxexo_MKTparam"];

fileout = mopen("output_all_C_forcings.csv", "w");

for var=list_var
    execstr("size_var = size("+var+");");
    size_size = size(size_var,'c');

    // scalar and vector
    if size_size==1
        for i=1:size_var(1)
            execstr("value="+var+"(i);");
            mfprintf(fileout,"""%s""|%.20G\n", var, value);
        end
    end

    // matrix
    if size_size==2
        for i=1:size_var(1)
            for j=1:size_var(2)
                execstr("value="+var+"(i,j);");
                mfprintf(fileout,"""%s""|%.20G\n", var, value);
            end
        end
    end

    // hypermat
    if size_size==3
        for i=1:size_var(1)
            for j=1:size_var(2)
                for k=1:size_var(3)
                    execstr("value="+var+"(i,j,k);");
                    mfprintf(fileout,"""%s""|%.20G\n", var, value);
                end
            end
        end
    end
end
mclose(fileout);




