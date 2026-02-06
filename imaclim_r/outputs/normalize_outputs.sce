// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// This file take all .dat outputs from a given study and create an unique .csv output
// it deals now with sensivity analysis, when a suffix is added to the combi number in the output folder name

metaRecMessOn = %t;


//TODO
//check for double outputs..

//=========PREAMBULE============
cd '../model';
exec("preamble.sce");
year_begin = 2001;
OUTPUT_FOLDER = PARENT+'outputs' + sep;

//=========FUNCTIONs============



//=========ACTUAL-JOB============

// get combi dir list


[ nam , combi, wasdone , wastooManysubs , isdoubledone ] = classify_dirlist(%t,OUTPUT_FOLDER);
nCombi = 0;
outputsDir = [];
combiMat   = [];
for index = 1:length(combi)
    //if wasdone(index)
    SAVEDIR = nam(index);
    outputsDir = [ outputsDir ; SAVEDIR ];
    combiMat = [ combiMat , combi(index) ];  
end

[temp,matString] = csvread(STUDY+"matrice_"+ETUDE+".csv");
//matString = tokens(matString)';

matriceIndices = zeros(nCombi,size(matrice_indices,2));
combiDir = [];
for indCombi = 1:nCombi
    matriceIndices(indCombi,:) = matrice_indices(matrice_indices(:,1)==combiMat(indCombi),:);
end

/////////////////////////////////////////////////////////////////////////////////
// create the vector of combi name with suffix of sensivity analysis, if any
combistr = string(combi');
for ii=1:size(combistr,'c')
    // get the suffix if any
    combi_str_tpt = combi2run_name(combi(ii));
    combi_str_tpt = strsubst(combi_str_tpt,'_'+ETUDE,'');
    str_temp = nam(ii);
    str_temp = strsplit(str_temp,'/'+combi_str_tpt);
    str_temp = str_temp(2);
    str_temp = strsplit(str_temp,ETUDE);
    str_temp = str_temp(1);
    str_temp = strsubst(str_temp,'_','');
    combistr(ii) = combistr(ii) + str_temp;
end
nCombi = size(combistr,'c');

/////////////////////////////////////////////////////////////////////////////////
//create the headers

// we suppose the time_lenght correspond to the last done year of first folder results (so that all runs have gone until the end)
ldsav('last_done_year.dat',"",outputsDir(1));
YEAR = year_begin;
nb_year = last_done_year;
for tt = 1:(last_done_year-1)
    YEAR($+1)=year_begin + tt;
end
write_csv(combistr,OUTPUT_FOLDER+'dimCOMBI.csv','|');
write_csv(YEAR',OUTPUT_FOLDER+'dimYEAR.csv','|');
write_csv(regnames',OUTPUT_FOLDER+'dimREG.csv','|');
write_csv(secnames',OUTPUT_FOLDER+'dimSEC.csv','|');

varTypeDimenssionName = ['','dimREG','dimREG*dimSEC','dimREG*dimSEC*dimSEC'];
varTypeDimenssionName = 'dimCOMBI*' + varTypeDimenssionName + '*dimYEAR';
varTypeDimenssionName = strsubst(varTypeDimenssionName,'**','*');
varTypeDimenssionSize = [''];
varTypeDimenssionSize($+1) = string(size(regnames,'r'));
varTypeDimenssionSize($+1) = string(size(regnames,'r'))+'*'+string(size(secnames,'r'));
varTypeDimenssionSize($+1) =string(size(regnames,'r'))+'*'+string(size(secnames,'r'))+'*'+string(size(secnames,'r'));
varTypeDimenssionSize = string(nCombi)+'*' + varTypeDimenssionSize + '*' + string(size(YEAR,'r'));
varTypeDimenssionSize = strsubst(varTypeDimenssionSize,'**','*');

// particular case for energy_balance
write_csv(matEner_names_cons',OUTPUT_FOLDER+'dimCONSENER.csv','|');
write_csv(matEner_names,OUTPUT_FOLDER+'dimENER.csv','|');
varTypeDimenssionName($+1)= 'dimCOMBI*dimCONSENER*dimENER*dimREG*dimYEAR';
varTypeDimenssionSize($+1)= string(nCombi)+'*' + string(size(matEner_names_cons,'r')) + '*' + string(size(matEner_names,'c')) + '*' + string(size(regnames,'r'))+ '*' + string(size(YEAR,'r'));
// particular case for wpEner
write_csv(WEner_names,OUTPUT_FOLDER+'dimWENER.csv','|');
varTypeDimenssionName($+1) = 'dimCOMBI*dimWENER*dimYEAR';
varTypeDimenssionSize($+1)= string(nCombi)+'*' + string(size(WEner_names,'c')) + '*' + string(size(YEAR,'r'));
// particular case for prod_elec_techno and rho_elec_moyen
write_csv(elecnames',OUTPUT_FOLDER+'dimELEC.csv','|');
varTypeDimenssionName($+1) = 'dimCOMBI*dimREG*dimELEC*dimYEAR';
varTypeDimenssionSize($+1)= string(nCombi)+'*' + string(size(regnames,'r'))  + '*' + string(size(elecnames,'r'))+ '*' + string(size(YEAR,'r'));
// particular case for E_reg_use : emissions by usage
write_csv(usenames',OUTPUT_FOLDER+'dimUSAGE.csv','|');
varTypeDimenssionName($+1)= 'dimCOMBI*dimREG*dimUSAGE*dimYEAR';
varTypeDimenssionSize($+1)= string(nCombi)+'*' +string(size(regnames,'r'))+ '*'+ string(size(usenames,'r')) + '*' + string(size(YEAR,'r'));
// particular case for pkmautomobileref : emissions by usage
varTypeDimenssionName($+1)= 'dimCOMBI*dimREG';
varTypeDimenssionSize($+1)= string(nCombi)+'*' +string(size(regnames,'r'));
// particular case for wp : world prices
varTypeDimenssionName($+1)= 'dimCOMBI*dimSEC*dimYEAR';
varTypeDimenssionSize($+1)= string(nCombi)+'*' +string(size(secnames,'r'))+ '*' + string(size(YEAR,'r'));
// particular case for eta: market share elasticity of non energetic goods
non_ener_secnames = secnames ( gsort([transportIndexes nonEnergyIndexes],'c','i') )';
write_csv(non_ener_secnames,OUTPUT_FOLDER+'dimNONENERSEC.csv','|');
varTypeDimenssionName($+1)= 'dimCOMBI*dimNONENERSEC*dimYEAR';
varTypeDimenssionSize($+1)= string(nCombi)+'*' +string(size(non_ener_secnames,'c'))+ '*' + string(size(YEAR,'r'));
// particular case for weight: armington weight for non energetic goods
varTypeDimenssionName($+1)= 'dimCOMBI*dimREG*dimNONENERSEC*dimYEAR';
varTypeDimenssionSize($+1)= string(nCombi)+'*' +string(size(regnames,'r'))+ '*'  +string(size(non_ener_secnames,'c'))+ '*' + string(size(YEAR,'r'));
// particular case for etamarketshareener: market share elasticity of energetic goods
ener_secnames = secnames ( energyIndexes )';
write_csv(ener_secnames,OUTPUT_FOLDER+'dimENERSEC.csv','|');
varTypeDimenssionName($+1)= 'dimCOMBI*dimENERSEC*dimYEAR';
varTypeDimenssionSize($+1)= string(nCombi)+'*' +string(size(ener_secnames,'c'))+ '*' + string(size(YEAR,'r'));
// particular case for bmarketshareener: market share elasticity of energetic goods
varTypeDimenssionName($+1)= 'dimCOMBI*dimREG*dimENERSEC*dimYEAR';
varTypeDimenssionSize($+1)= string(nCombi)+'*' + string(size(regnames,'r')) + '*' + string(size(ener_secnames,'c')) + '*' + string(size(YEAR,'r'));
// particular case for etaCI : elasticity for pArmCI
varTypeDimenssionName($+1)= 'dimCOMBI*dimREG*dimSEC*dimNONENERSEC*dimYEAR';
varTypeDimenssionSize($+1)= string(nCombi)+'*'+ string(size(regnames,'r'))+ '*' + string(size(secnames,'r')) + '*' + string(size(non_ener_secnames,'c'))+ '*' + string(size(YEAR,'r'));


////////////////////////////////////////////////////////////////////
// outputs
fileout = mopen(OUTPUT_FOLDER+ETUDE+'_outputs.csv', "w");
varnames_normal = [..
    'GDP_sav','GDP_MER_nominal_sav','GDP_MER_real_sav','GDP_PPP_nominal_sav','GDP_PPP_real_sav','VA_sav',..
    'DF_sav','DG_sav','DI_sav','DIinfra_sav','Q_sav','Cap_sav','Imp_sav','Exp_sav','ExpTI_sav','CI_sav',..
    'p_sav','pArmDF_sav','Ttax_sav','pArmDI_sav','pArmDG_sav','pArmCI_sav','w_sav','l_sav','Ltot_sav',..
    'markup_sav','markup_lim_oil_sav',..
    'taxMKT_sav','energy_balance_stock_sav','wpEner_sav',..
    'nit_sav','mtax_sav','xtax_sav','wpTIagg_sav','wp_sav',..
    'LCC_min_alltechno_sav','LCC_min_share_INV_sav','LCC_min_share_Fuel_sav',..
    'prod_elec_techno_sav','partExpK_sav','partImpK_sav','energyInvestment_sav','pK_sav','DeltaK_sav','GRB_sav',..
    'E_reg_use_sav','emi_evitee_sav',..
    'partDomCI_sav','partDomDF_sav','partDomDG_sav','partDomDI_sav','marketshare_sav',..
    'partImpCI_sav','partImpDF_sav','partImpDG_sav','partImpDI_sav',..
    'marketshare_sav','eta_sav','bmarketshareener_sav','etamarketshareener_sav','weight_sav',..
    'coef_Q_CO2_DG_sav','coef_Q_CO2_DI_sav','coef_Q_CO2_DF_sav','coef_Q_CO2_CI_sav',..
    'taxCO2_DG_sav','taxCO2_DI_sav','taxCO2_DF_sav','taxCO2_CI_sav',..
    'taxDGdom_sav','taxDGimp_sav','taxDIdom_sav','taxDIimp_sav','taxDFdom_sav','taxDFimp_sav','taxCIdom_sav','taxCIimp_sav',..
    'qtax_sav','sigma_sav',..
    'aRD_sav','bRD_sav','cRD_sav',..
    'Q_biofuel_anticip_sav','Q_CTL_anticip_sav','share_CCS_CTL_sav',..
    'Ress_coal_sav','Ress_gaz_sav',..
    'share_shaleOil_sav','share_heavyOil_sav','share_lto_sav','share_shaleGas_sav',..
    'alphaEtauto_sav','alphaelecauto_sav','pkmautomobileref','Tautomobile_sav',..
    'alphaEtm2_sav','stockbatiment_sav','alphaelecm2_sav','alphaCoalm2_sav','alphaGazm2_sav',..
    'IR_sav','Rdisp_sav','ptc_sav','div_sav',..
    'itgbl_cost_DFdom_sav','itgbl_cost_DFimp_sav','itgbl_cost_CIdom_sav','itgbl_cost_CIimp_sav','alpha_partCI_sav','alpha_partDF_sav',..
    'bDF_sav','bCI_sav','etaCI_sav','etaDF_sav','taxDFdom_sav','taxDFimp_sav','taxCIdom_sav','taxCIimp_sav',..
'Exchange_rate_sav','RealEERate_output_sav','RealEERate_employ_sav','RealEERate_sec_sav','RCA_ind_sav','RWS_ind_sav','RTB_ind_sav','ind_export_price_sav'];//varnames with dimenssions following varTypeDimenssionName and varTypeDimenssionSize, so world variable, or variable with region and sectoral dimensions
varnames_normal = ['Tautomobile_sav','pkmautomobileref','GDP_PPP_real_sav','rho_elec_moyen_sav','prod_elec_techno_sav','Q_biofuel_anticip_sav','Q_CTL_anticip_sav','Cap_sav','Q_sav','E_reg_use_sav','emi_evitee_sav','markup_sav','markup_lim_oil_sav','p_sav']
varnames_normal = [varnames_normal,'CI_sav','partDomCI_sav','taxCO2_CI_sav','coef_Q_CO2_CI_sav','DF_sav','partDomDF_sav','taxCO2_DF_sav','coef_Q_CO2_DF_sav','DG_sav','partDomDG_sav','taxCO2_DG_sav','coef_Q_CO2_DG_sav','DI_sav','partDomDI_sav','taxCO2_DI_sav','coef_Q_CO2_DI_sav','partImpCI_sav','partImpDF_sav','partImpDG_sav','partImpDI_sav'];
//add nexus land-use variables :
//varnames_normal = [varnames_normal,'Wyieldgap_sav','yield_on_pot_scaled_sav','consNPK_volume_sav'];
[x,ierr] = fileinfo(outputsDir(1) + 'save/elast_DFener_us_sav.dat')
if ierr <> -1 
    varnames_normal = [varnames_normal,'elast_DFener_us_sav','elast_Expener_us_sav']
end
////////////////////////////////////////////////////////////////////
// create the csv

// write metadatas
mfprintf(fileout, "metadatas here\n");

//write _sav.dat files datas
for varname = varnames_normal
    //disp(varname)
    //check dimenssions
    ldsav(varname,"",outputsDir(1));
    execstr("varsize = size("+varname+");")
    number_of_dimensions = size(varsize, 'c');
    //listeVarNames($+1) = strsubst(varname,'_sav','');
    //write the header
    name_out = strsubst(varname,"_sav","");

    /////////////////////////////
    // write the exceptions headers and datas
    if varname == 'energy_balance_stock_sav'
        // write infos
        mfprintf(fileout, "\n!HEADER!*%s|%s|%s\n", name_out, varTypeDimenssionName(5), varTypeDimenssionSize(5) );
        // write headers
        mfprintf(fileout,"""%s""", "varname");
        for elt=strsplit(varTypeDimenssionName(5),'*')'
            if elt <> 'dimYEAR' 
                mfprintf(fileout,"|""%s""", elt);
            else
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    mfprintf(fileout,"|""%s""", string(year) );
                end
            end
        end
        mfprintf(fileout,"\n");
        // write datas
        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));
            for iEnerCons = 1:size(matEner_names_cons,'r')
                for iEner = 1:size(matEner_names,'c')
                    for ireg = 1:nb_regions
                        mfprintf(fileout, "%s|%s|%s|%s|%s", name_out, combiname, matEner_names_cons(iEnerCons), matEner_names(iEner), regnames(ireg));
                        for iyear = 1:nb_year
                            year = year_begin + iyear -1;
                            str_to_exec = "value = "+varname+"("+msprintf("%d, %d", (ireg-1)*size(matEner_names,'c')*size(matEner_names_cons,'r') + (iEner-1)*size(matEner_names_cons,'r') + iEnerCons, iyear)+")";
                            execstr(str_to_exec);
                            mfprintf(fileout, "|%.20G", value);
                        end
                        mfprintf(fileout, "\n");
                    end
                end
            end
        end
        continue
    end
    if varname == 'wpEner_sav'
        // write infos
        mfprintf(fileout, "\n!HEADER!*%s|%s|%s\n", name_out, varTypeDimenssionName(6), varTypeDimenssionSize(6) );
        // write headers
        mfprintf(fileout,"""%s""", "varname");
        for elt=strsplit(varTypeDimenssionName(6),'*')'
            if elt <> 'dimYEAR' 
                mfprintf(fileout,"|""%s""", elt);
            else
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    mfprintf(fileout,"|""%s""", string(year) );
                end
            end
        end
        mfprintf(fileout,"\n");
        // write datas
        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));
            for iiener = 1:size(WEner_names,'c')
                mfprintf(fileout, "%s|%s|%s", name_out, combiname, WEner_names(iiener));
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    str_to_exec = "value = "+varname+"("+msprintf("%d, %d", iiener, iyear)+")";
                    execstr(str_to_exec);
                    mfprintf(fileout, "|%.20G", value);
                end
                mfprintf(fileout, "\n");
            end
        end
        continue
    end
    if sum(varname == ['rho_elec_moyen_sav','prod_elec_techno_sav','LCC_min_alltechno_sav','LCC_min_share_INV_sav','LCC_min_share_Fuel_sav']) == 1
        // write infos
        mfprintf(fileout, "\n!HEADER!*%s|%s|%s\n", name_out, varTypeDimenssionName(7), varTypeDimenssionSize(7) );
        // write headers
        mfprintf(fileout,"""%s""", "varname");
        for elt=strsplit(varTypeDimenssionName(7),'*')'
            if elt <> 'dimYEAR' 
                mfprintf(fileout,"|""%s""", elt);
            else
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    mfprintf(fileout,"|""%s""", string(year) );
                end
            end
        end
        mfprintf(fileout,"\n");
        // write datas
        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));
            for iElec = 1:size(elecnames,'r')
                for ireg = 1:nb_regions
                    mfprintf(fileout, "%s|%s|%s|%s", name_out, combiname, regnames(ireg), elecnames(iElec));
                    for iyear = 1:nb_year
                        year = year_begin + iyear -1;
                        str_to_exec = "value = "+varname+"("+msprintf("%d, %d", (iElec-1)*nb_regions  + ireg, iyear)+")";
                        execstr(str_to_exec);
                        mfprintf(fileout, "|%.20G", value);
                    end
                    mfprintf(fileout, "\n");
                end
            end
        end
        continue
    end
    if varname == 'E_reg_use_sav'
        // write infos
        mfprintf(fileout, "\n!HEADER!*%s|%s|%s\n", name_out, varTypeDimenssionName(8), varTypeDimenssionSize(8) );
        // write headers
        mfprintf(fileout,"""%s""", "varname");
        for elt=strsplit(varTypeDimenssionName(8),'*')'
            if elt <> 'dimYEAR' 
                mfprintf(fileout,"|""%s""", elt);
            else
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    mfprintf(fileout,"|""%s""", string(year) );
                end
            end
        end
        mfprintf(fileout,"\n");
        // write datas
        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));

            for ireg = 1:nb_regions
                for iUsage = 1:size(usenames,'r')
                    mfprintf(fileout, "%s|%s|%s|%s", name_out, combiname,regnames(ireg), usenames(iUsage) );
                    for iyear = 1:nb_year
                        year = year_begin + iyear -1;
                        str_to_exec = "value = "+varname+"("+msprintf("%d, %d", (iUsage-1)*nb_regions  + ireg, iyear)+")";
                        execstr(str_to_exec);
                        mfprintf(fileout, "|%.20G", value);
                    end
                    mfprintf(fileout, "\n");
                end
            end
        end
        continue
    end
    if varname == 'pkmautomobileref'
        // write infos
        mfprintf(fileout, "\n!HEADER!*%s|%s|%s\n", name_out, varTypeDimenssionName(9), varTypeDimenssionSize(9) );
        // write headers
        mfprintf(fileout,"""%s""", "varname");
        for elt=strsplit(varTypeDimenssionName(9),'*')'
            if elt <> 'dimYEAR' 
                mfprintf(fileout,"|""%s""", elt);
            else
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    mfprintf(fileout,"|""%s""", string(year) );
                end
            end
        end
        mfprintf(fileout,"\n");
        // write datas
        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));
            //write datas
            for ireg = 1:nb_regions
                str_to_exec = "value = "+varname+"("+msprintf("%d, %d", ireg, 1)+")";
                execstr(str_to_exec);
                mfprintf(fileout, "%s|%s|%s|%.20G\n", name_out, combiname, regnames(ireg), value);
            end
        end
        continue
    end
    if varname == 'wp_sav'
        // write infos
        mfprintf(fileout, "\n!HEADER!*%s|%s|%s\n", name_out, varTypeDimenssionName(10), varTypeDimenssionSize(10) );
        // write headers
        mfprintf(fileout,"""%s""", "varname");
        for elt=strsplit(varTypeDimenssionName(10),'*')'
            if elt <> 'dimYEAR' 
                mfprintf(fileout,"|""%s""", elt);
            else
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    mfprintf(fileout,"|""%s""", string(year) );
                end
            end
        end
        mfprintf(fileout,"\n");
        // write datas
        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));
            for isec = 1:nb_sectors
                mfprintf(fileout, "%s|%s|%s", name_out, combiname, secnames(isec) );
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    str_to_exec = "value = "+varname+"("+msprintf("%d, %d", isec, iyear)+")";
                    execstr(str_to_exec);
                    mfprintf(fileout, "|%.20G", value);
                end
                mfprintf(fileout, "\n");
            end
        end
        continue
    end
    if varname == 'eta_sav'
        // write infos
        mfprintf(fileout, "\n!HEADER!*%s|%s|%s\n", name_out, varTypeDimenssionName(11), varTypeDimenssionSize(11) );
        // write headers
        mfprintf(fileout,"""%s""", "varname");
        for elt=strsplit(varTypeDimenssionName(11),'*')'
            if elt <> 'dimYEAR' 
                mfprintf(fileout,"|""%s""", elt);
            else
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    mfprintf(fileout,"|""%s""", string(year) );
                end
            end
        end
        mfprintf(fileout,"\n");
        // write datas
        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));
            for isec = 1:size(non_ener_secnames,'c')
                mfprintf(fileout, "%s|%s|%s", name_out, combiname, non_ener_secnames(isec) );
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    str_to_exec = "value = "+varname+"("+msprintf("%d, %d", isec, iyear)+")";
                    execstr(str_to_exec);
                    mfprintf(fileout, "|%.20G", value);
                end
                mfprintf(fileout, "\n");
            end
        end
        continue
    end
    if sum(varname == ['weight_sav','bDF_sav','bCI_sav']) == 1 
        // write infos
        mfprintf(fileout, "\n!HEADER!*%s|%s|%s\n", name_out, varTypeDimenssionName(12), varTypeDimenssionSize(12) );
        // write headers
        mfprintf(fileout,"""%s""", "varname");
        for elt=strsplit(varTypeDimenssionName(12),'*')'
            if elt <> 'dimYEAR' 
                mfprintf(fileout,"|""%s""", elt);
            else
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    mfprintf(fileout,"|""%s""", string(year) );
                end
            end
        end
        mfprintf(fileout,"\n");
        // write datas
        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));

            for ireg = 1:nb_regions
                for isec = 1:size(non_ener_secnames,'c')
                    mfprintf(fileout, "%s|%s|%s|%s", name_out, combiname,regnames(ireg), non_ener_secnames(isec) );
                    for iyear = 1:nb_year
                        year = year_begin + iyear -1;
                        str_to_exec = "value = "+varname+"("+msprintf("%d, %d", (isec-1)*nb_regions  + ireg, iyear)+")";
                        execstr(str_to_exec);
                        mfprintf(fileout, "|%.20G", value);
                    end
                    mfprintf(fileout, "\n");
                end
            end
        end
        continue
    end
    if varname == 'etamarketshareener_sav'
        // write infos
        mfprintf(fileout, "\n!HEADER!*%s|%s|%s\n", name_out, varTypeDimenssionName(13), varTypeDimenssionSize(13) );
        // write headers
        mfprintf(fileout,"""%s""", "varname");
        for elt=strsplit(varTypeDimenssionName(13),'*')'
            if elt <> 'dimYEAR' 
                mfprintf(fileout,"|""%s""", elt);
            else
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    mfprintf(fileout,"|""%s""", string(year) );
                end
            end
        end
        mfprintf(fileout,"\n");
        // write datas
        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));
            for isec = 1:size(ener_secnames,'c')
                mfprintf(fileout, "%s|%s|%s", name_out, combiname, ener_secnames(isec) );
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    str_to_exec = "value = "+varname+"("+msprintf("%d, %d", isec, iyear)+")";
                    execstr(str_to_exec);
                    mfprintf(fileout, "|%.20G", value);
                end
                mfprintf(fileout, "\n");
            end
        end
        continue
    end

    if sum(varname == ['bmarketshareener_sav','itgbl_cost_DFdom_sav','itgbl_cost_DFimp_sav','itgbl_cost_CIdom_sav','itgbl_cost_CIimp_sav','alpha_partCI_sav','alpha_partDF_sav','etaDF_sav']) == 1
        // write infos
        mfprintf(fileout, "\n!HEADER!*%s|%s|%s\n", name_out, varTypeDimenssionName(14), varTypeDimenssionSize(14) );
        // write headers
        mfprintf(fileout,"""%s""", "varname");
        for elt=strsplit(varTypeDimenssionName(14),'*')'
            if elt <> 'dimYEAR' 
                mfprintf(fileout,"|""%s""", elt);
            else
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    mfprintf(fileout,"|""%s""", string(year) );
                end
            end
        end
        mfprintf(fileout,"\n");
        // write datas
        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));

            for ireg = 1:nb_regions
                for isec = 1:size(ener_secnames,'c')
                    mfprintf(fileout, "%s|%s|%s|%s", name_out, combiname,regnames(ireg), ener_secnames(isec) );
                    for iyear = 1:nb_year
                        year = year_begin + iyear -1;
                        str_to_exec = "value = "+varname+"("+msprintf("%d, %d", (isec-1)*nb_regions  + ireg, iyear)+")";
                        execstr(str_to_exec);
                        mfprintf(fileout, "|%.20G", value);
                    end
                    mfprintf(fileout, "\n");
                end
            end
        end
        continue
    end

    if sum( varname ==  ['etaCI_sav'] ) == 1
        // write infos
        mfprintf(fileout, "\n!HEADER!*%s|%s|%s\n", name_out, varTypeDimenssionName(15), varTypeDimenssionSize(15));
        // write headers
        mfprintf(fileout,"""%s""", "varname");
        for elt=strsplit(varTypeDimenssionName(15),'*')'
            if elt <> 'dimYEAR' 
                mfprintf(fileout,"|""%s""", elt);
            else
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    mfprintf(fileout,"|""%s""", string(year) );
                end
            end
        end
        mfprintf(fileout,"\n");
        // write datas
        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));
            for isec = 1:size(non_ener_secnames,'c')
                for jsec = 1:nb_sectors
                    for ireg = 1:nb_regions
                        mfprintf(fileout, "%s|%s|%s|%s|%s", name_out, combiname, regnames(ireg), secnames(jsec),non_ener_secnames(isec) );
                        for iyear = 1:nb_year
                            year = year_begin + iyear -1;
                            str_to_exec = "value = "+varname+"("+msprintf("%d, %d",  (ireg-1)*nb_sectors*size(non_ener_secnames,'c') + (jsec-1)*size(non_ener_secnames,'c')  + isec,iyear)+")"; //check here the order
                            execstr(str_to_exec);
                            mfprintf(fileout, "|%.20G", value); 
                        end
                        mfprintf(fileout, "\n");
                    end
                end
            end
        end
        continue
    end

    /////////////////////////////
    // variable name change
    /////////////////////////////      

    // write the common headers and datas (reg,sec dimenssions)

    // trace dimensions type
    if varsize(1) == 1
        dim_ind_temp = 1;
    elseif varsize(1) == nb_regions
        dim_ind_temp = 2;
    elseif varsize(1)/nb_regions == nb_sectors
        dim_ind_temp = 3;
    elseif varsize(1)/(nb_regions^2) == nb_sectors
        dim_ind_temp = 4;
    else
        dim_ind_temp = 0;
        printf(varname + ' doesnt have a strandart format with region/sectoral dimensions. Code a particular case');
    end

    // write infos
    mfprintf(fileout, "\n!HEADER!*%s|%s|%s\n", name_out, varTypeDimenssionName(dim_ind_temp), varTypeDimenssionSize(dim_ind_temp));

    // write headers
    mfprintf(fileout,"""%s""", "varname");
    for elt=strsplit(varTypeDimenssionName(dim_ind_temp),'*')'
        if elt <> 'dimYEAR' 
            mfprintf(fileout,"|""%s""", elt);
        else
            for iyear = 1:nb_year
                year = year_begin + iyear -1;
                mfprintf(fileout,"|""%s""", string(year) );
            end
        end
    end
    mfprintf(fileout,"\n");

    // write datas
    if varsize(1) == 1

        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));
            //write datas
            mfprintf(fileout, "%s|%s", name_out, combiname)
            for iyear = 1:nb_year
                year = year_begin + iyear -1;
                str_to_exec = "value = "+varname+"("+msprintf("%d, %d", 1, iyear)+")";
                execstr(str_to_exec);
                mfprintf(fileout, "|%.20G", value);
            end
            mfprintf(fileout, "\n");
        end

    elseif varsize(1) == nb_regions

        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));
            for ireg = 1:nb_regions
                mfprintf(fileout, "%s|%s|%s", name_out, combiname, regnames(ireg) );
                for iyear = 1:nb_year
                    year = year_begin + iyear -1;
                    str_to_exec = "value = "+varname+"("+msprintf("%d, %d", ireg, iyear)+")";
                    execstr(str_to_exec);
                    mfprintf(fileout, "|%.20G", value);
                end
                mfprintf(fileout, "\n");
            end
        end

    elseif varsize(1)/nb_regions == nb_sectors
        // works for p(reg,sec) for example
        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));
            for isec = 1:nb_sectors
                for ireg = 1:nb_regions
                    mfprintf(fileout, "%s|%s|%s|%s", name_out, combiname, regnames(ireg), secnames(isec) );
                    for iyear = 1:nb_year
                        year = year_begin + iyear -1;
                        str_to_exec = "value = "+varname+"("+msprintf("%d, %d", (isec-1)*nb_regions+ireg, iyear)+")";
                        execstr(str_to_exec);
                        mfprintf(fileout, "|%.20G", value);
                    end
                    mfprintf(fileout, "\n");
                end
            end
        end

    elseif varsize(1)/(nb_sectors^2) == nb_regions
        // works for CI(sec,sec,reg) for example
        for icombi = 1:nCombi
            combiname = combistr(icombi);
            ldsav(varname,"",outputsDir(icombi));
            for isec = 1:nb_sectors
                for jsec = 1:nb_sectors
                    for ireg = 1:nb_regions
                        mfprintf(fileout, "%s|%s|%s|%s|%s", name_out, combiname, regnames(ireg), secnames(isec),secnames(jsec) );
                        for iyear = 1:nb_year
                            year = year_begin + iyear -1;
                            str_to_exec = "value = "+varname+"("+msprintf("%d, %d",  (ireg-1)*nb_sectors*nb_sectors + (isec-1)*nb_sectors  + jsec,iyear)+")"; //check here the order
                            execstr(str_to_exec);
                            mfprintf(fileout, "|%.20G", value); 
                        end
                        mfprintf(fileout, "\n");
                    end
                end
            end
        end

    else printf(varname + ' doesnt have a strandart format with region/sectoral dimensions. Code a particular case');

    end
end

mclose(fileout);
cd '../';

//write other Imaclim outputs



////////////////////////////////////////////////////////////////////////////////////////////////
//write nexus land-use data
////////////////////////////////////////////////////////////////////////////////////////////////




//write liste varnames
//write_csv(listeVarNames,OUTPUT_FOLDER+ETUDE+'_varnames.csv','|');
