// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Thomas Le Gallic, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///////////////////////////////////////////////////////////
///////////Calibration Nexus Industry///////////////////////////
///////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   INDEXES and DIMENSSIONS   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION with no source   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

var_hom_industrie=6*ones(nb_regions,1);
var_hom_agriculture=6*ones(nb_regions,1);
var_hom_composite=6*ones(nb_regions,1);

lim_share_ser=4*ones(nb_regions,1);
//change for Africa
lim_share_ser(ind_afr)=2;


/////////////////////////////////////////////////////////////////////////////////////////////
//    ---*---   CALIBRATION   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////

// Calibration of an optimistic assumption to reduce the cost of capital in the composite sector in order to stimulate substitution towards electricity in this variant
if indice_building_electri==1
    K_cost_comp_reduc_ini = 0.5;
    K_cost_comp_reduc = 0.03;
end																																									   

taxval=factor_CO2_C*1000*ones(nb_regions,1);

taxCO2_DF=(taxval*1e-6)*ones(1,nb_sectors);
taxCO2_DG=(taxval*1e-6)*ones(1,nb_sectors);
taxCO2_DI=(taxval*1e-6)*ones(1,nb_sectors);
for k=1:nb_regions
    taxCO2_CI(:,:,k)=(taxval(k)*1e-6)*ones(nb_sectors,nb_sectors);
end

///we cut the tax on auto-consumption of fossil fuels
for k=1:nb_regions
    for j=1:nbsecteurenergie
        taxCO2_CI(j,indice_coal,k)=0;
        taxCO2_CI(j,indice_gas,k)=0;
        taxCO2_CI(j,indice_oil,k)=0;
    end
end
pArmCI_CO2=zeros(nb_sectors,nb_sectors,nb_regions);
for k = 1:nb_regions,
    pArmCI_CO2(nb_sectors-nb_secteur_conso+1:nb_sectors,:,k) = ((bCI(:,:,k).^etaCI(:,:,k)).*(((p(k,nb_sectors-nb_secteur_conso+1:nb_sectors)'*ones(1,nb_sectors)).*(1+taxCIdom(nb_sectors-nb_secteur_conso+1:nb_sectors,:,k))).^(1-etaCI(:,:,k)))+((1-bCI(:,:,k)).^etaCI(:,:,k)).*((((wp(nb_sectors-nb_secteur_conso+1:nb_sectors).*(1+mtax(k,nb_sectors-nb_secteur_conso+1:nb_sectors))+nit(k,nb_sectors-nb_secteur_conso+1:nb_sectors).*wpTIagg)'*ones(1,nb_sectors)).*(1+taxCIimp(nb_sectors-nb_secteur_conso+1:nb_sectors,:,k))).^(1-etaCI(:,:,k)))).^(ones(nb_secteur_conso,nb_sectors)./(1-etaCI(:,:,k)));
end
for k=1:nb_regions,
    pArmCI_CO2(1:nbsecteurenergie,:,k)=((p(k,1:nbsecteurenergie)'*ones(1,nb_sectors)).*(1+taxCIdom(1:nbsecteurenergie,:,k))).*(1-partImpCI(1:nbsecteurenergie,:,k))+(((wpEner.*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIagg)'*ones(1,nb_sectors)).*(1+taxCIimp(1:nbsecteurenergie,:,k))).*partImpCI(1:nbsecteurenergie,:,k)+(taxCO2_CI(1:nbsecteurenergie,:,k).*coef_Q_CO2_CI(1:nbsecteurenergie,:,k)).*(num(k,1:nbsecteurenergie)'*ones(1,nb_sectors));
end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////<
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////<
//////////////////////////////////////////industry///////////////////////////////////////////////////////////////////////<
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////<
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////<



rhoindustries_dyn=rhoindustrie(1:4,:);
rhoindustries_dyn(4,:)=rhoindustrie(5,:);
cumul_calib_fail=0; //DESAG_INDUSTRY: Temporarily, to count and display the number of calibration fails


K_cost_industries=zeros(nb_regions,4,nb_sectors_industry);
for sec_indus =1:nb_sectors_industry,
    rhoindustrie_dyn=rhoindustries_dyn(:,sec_indus);
    for pays=1:nb_regions
        info=4;
        for k=0:50
            SH_ener_ind_oil_coal_lim=0.01*k;
            if info==4
                [u,v,info]=fsolve(ones(4,1),K_cal_logit_ind,0.01);
                [u,v,info]=fsolve(u,K_cal_logit_ind,0.01);
            else
                [u,v,info]=fsolve(ones(4,1),K_cal_logit_ind,0.01);
                [u,v,info]=fsolve(u,K_cal_logit_ind,0.01);
            end
            K_cost_industries(pays,:,sec_indus)=(u.^2)';
            if (info==1)&k>9 then 
                //disp(k);
                break; 
            end
            if k==50 then 
                disp('calibration failed in region '+pays+' industrial sector '+sec_indus); 
                disp('pause has been commented while waiting to debug this part of the code in the v2.0 calibration'); 
                cumul_calib_fail=1+cumul_calib_fail;
                //pause; 
            end
        end
    end
end
if verbose>=1
    disp('The K_cost_industries calibration process failed in ' + cumul_calib_fail + ' cases.'); // DESAG_INDUSTRY: will be removed when fixed
end

if nb_sectors_industry == 1
    //K_cost_industries(1,:)= K_cost_industries(2,:) ;
    K_cost_industries(1,:) = [415219.27    480436.06    299720.2     325792.52];
else
    K_cost_industries(K_cost_industries>1e7) = 1e7; // DESAG_INDUSTRY: rustine to avoid very high values (~10^20). Normal values seem to be between 10^3 & 10^7. The calibration process should be improved to avoid such high values. NB: this wasn't a problem to run the previous version, so shouldn't be the solution to bugs in 2016.
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////<
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////<
//////////////////////////////////////////agriculture///////////////////////////////////////////////////////////////////////<
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////<
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////<

//we eliminate null values in order to be able to calibrate the logit functions
Penergieutileagric=max(Penergieutileagric,0.00001);
//change for India
Penergieutileagric(7,:)=max(Penergieutileagric(7,:),0.03)./(sum(Penergieutileagric(7,:),'c'));

rhoagriculture_dyn=rhoagriculture(1:4);
rhoagriculture_dyn(4)=rhoagriculture(5);

K_cost_agriculture=zeros(nb_regions,4);
lim_share_agric=24*ones(nb_regions,1);
//change for India
lim_share_agric(7)=20;

for pays=1:nb_regions
    info=4;
    for k=0:50
        SH_ener_agr_oil_coal_lim=0.01*k;
        if info==4 then
            [u,v,info]=fsolve(ones(4,1),K_cal_logit_agr);
            [u,v,info]=fsolve(u,K_cal_logit_agr);
        else
            [u,v,info]=fsolve(u,K_cal_logit_agr);
            [u,v,info]=fsolve(u,K_cal_logit_agr);
        end
        K_cost_agriculture(pays,:)=(u.^2)';
        if (info==1)&k>lim_share_agric(pays) then 
            break; 
        end
        if k==50 then 
            disp('calibration failed'); 
            disp('pause has been commented while waiting to debug this part of the code in the v2.0 calibration'); 
            //pause; 
        end
    end
end

clear lim_share_agric

//disp('test logit agri')
//pause;
//pays=7;
//Penergieutileagric(7,:)
// SH_ener_agr_oil_coal_lim=0.01*21;
// [u,v,info]=fsolve(ones(4,1),K_cal_logit_agr);
// [u,v,info]=fsolve(u,K_cal_logit_agr);
// K_cost_agriculture(pays,:)=(u.^2)';
// info
// test_logit_agr(K_cost_agriculture,[pArmCI_nexus(indice_coal,indice_agriculture,pays);5*pArmCI_nexus(indice_Et,indice_agriculture,pays);pArmCI_nexus(indice_gas,indice_agriculture,pays);pArmCI_nexus(indice_elec,indice_agriculture,pays)],pays)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////<
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////<
//////////////////////////////////////////composite///////////////////////////////////////////////////////////////////////<
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////<
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////<




rhocomposite_dyn=rhocomposite(1:4);
rhocomposite_dyn(4)=rhocomposite(5);

K_cost_composite=zeros(nb_regions,4);


//we eliminate null values in order to be able to calibrate the logit functions
Penergieutilecomposite=max(Penergieutilecomposite,0.00001);
//changes for india
Penergieutilecomposite(7,:)=max(Penergieutilecomposite(7,:),0.03)./(sum(Penergieutilecomposite(7,:),'c'));


for pays=1:nb_regions
    info=4;
    for k=0:50
        SH_ener_ser_oil_coal_lim=0.01*k;
        if info==4
            [u,v,info]=fsolve(ones(4,1),K_cal_logit_ser);
            [u,v,info]=fsolve(u,K_cal_logit_ser);
        else
            [u,v,info]=fsolve(ones(4,1),K_cal_logit_ser);
            [u,v,info]=fsolve(u,K_cal_logit_ser);
        end
        if (info==1)&k>lim_share_ser(pays) then 
            //disp(k);
            K_cost_composite(pays,:)=(u.^2)';
            break; 
        end
        if k==50 then 
            disp('calibration failed'); 
            disp('pause has been commented while waiting to debug this part of the code in the v2.0 calibration'); 
            //pause; 
        end
    end
end

// pays=7;
// Penergieutilecomposite(7,:)
// test_logit_ser(K_cost_composite,[pArmCI_nexus(indice_coal,indice_composite,pays);5*pArmCI_nexus(indice_Et,indice_composite,pays);pArmCI_nexus(indice_gas,indice_composite,pays);pArmCI_nexus(indice_elec,indice_composite,pays)],pays)
	
taxval=zeros(nb_regions,1);

taxCO2_DF=(taxval*1e-6)*ones(1,nb_sectors);
taxCO2_DG=(taxval*1e-6)*ones(1,nb_sectors);
taxCO2_DI=(taxval*1e-6)*ones(1,nb_sectors);
for k=1:nb_regions
    taxCO2_CI(:,:,k)=(taxval(k)*1e-6)*ones(nb_sectors,nb_sectors);
end
///we cut taxes on fossil fuel auto-consumptions
for k=1:nb_regions
    for j=1:nbsecteurenergie
        taxCO2_CI(j,indice_coal,k)=0;
        taxCO2_CI(j,indice_gas,k)=0;
        taxCO2_CI(j,indice_oil,k)=0;
    end
end
pArmCI_CO2=zeros(nb_sectors,nb_sectors,nb_regions);
for k = 1:nb_regions,
    pArmCI_CO2(sec-nb_secteur_conso+1:nb_sectors,:,k) = ((bCI(:,:,k).^etaCI(:,:,k)).*(((p(k,nb_sectors-nb_secteur_conso+1:nb_sectors)'*ones(1,nb_sectors)).*(1+taxCIdom(nb_sectors-nb_secteur_conso+1:nb_sectors,:,k))).^(1-etaCI(:,:,k)))+((1-bCI(:,:,k)).^etaCI(:,:,k)).*((((wp(nb_sectors-nb_secteur_conso+1:nb_sectors).*(1+mtax(k,nb_sectors-nb_secteur_conso+1:nb_sectors))+nit(k,nb_sectors-nb_secteur_conso+1:nb_sectors).*wpTIagg)'*ones(1,nb_sectors)).*(1+taxCIimp(nb_sectors-nb_secteur_conso+1:nb_sectors,:,k))).^(1-etaCI(:,:,k)))).^(ones(nb_secteur_conso,nb_sectors)./(1-etaCI(:,:,k)));
end
for k=1:nb_regions,
    pArmCI_CO2(1:nbsecteurenergie,:,k)=((p(k,1:nbsecteurenergie)'*ones(1,nb_sectors)).*(1+taxCIdom(1:nbsecteurenergie,:,k))).*(1-partImpCI(1:nbsecteurenergie,:,k))+(((wpEner.*(1+mtax(k,1:nbsecteurenergie))+nit(k,1:nbsecteurenergie)*wpTIagg)'*ones(1,nb_sectors)).*(1+taxCIimp(1:nbsecteurenergie,:,k))).*partImpCI(1:nbsecteurenergie,:,k)+(taxCO2_CI(1:nbsecteurenergie,:,k).*coef_Q_CO2_CI(1:nbsecteurenergie,:,k)).*(num(k,1:nbsecteurenergie)'*ones(1,nb_sectors));
end


