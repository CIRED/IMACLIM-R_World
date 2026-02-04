// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thomas Le-Gallic, Nicolas Graves, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

////////////////////////////////////////////////////////////////////////
//////////// Calibration of productiveSectors.leontief /////////////////
////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   INDEXES and DIMENSSIONS   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION with no source   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

// cost of CCS for indutrial sectors
// rough estimates from Fig. 17
// from Kearns et al. (2021) Technology readyness and cots of CCS 	
// https://www.globalccsinstitute.com/wp-content/uploads/2022/03/CCE-CCS-Technology-Readiness-and-Costs-22-1.pdf
CCS_cost_industrie = 70; // in $/tCO2
//DESAG_INDUSTRY: assumed to be the same for all industrial sectors in this first version

/////////////////////////////////////////////////////////////////////////////////////////////
//    ---*---   CALIBRATION   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////


// shCIspec et shCIsubs permettent de choisir la part de CI énergétiques spécifiques à chaque secteur, et la part de CI énergétiques substituables

shCIspec_comp=zeros(nbsecteurenergie,nb_regions);
shCIspec_agri=zeros(nbsecteurenergie,nb_regions);
shCIspec_indu=zeros(nbsecteurenergie,nb_sectors_industry,nb_regions); // DESAG_INDUSTRY: new dimension

//Modification des parts spécifiques ATTENTION ne jamais mettre TOUT Spécifique à 100% sinon division par 0 dans calibration.industry

shCIspec_comp(indice_coal,:)=0.99999999999*ones(1,nb_regions); // Evoluent séparemment et sont remplacés par du gaz.
shCIspec_comp(indice_elec,:)=0.9*ones(1,nb_regions); // Les 10% restants sont remplacés par du gaz ou Et.
shCIspec_comp(indice_Et,:)=0.2*ones(1,nb_regions);
shCIspec_comp(indice_gaz,:)=0.5*ones(1,nb_regions);

shCIspec_agri=0.999999999999999*ones(nbsecteurenergie,nb_regions);

//DESAG_INDUSTRY: Temporarily, we assumed that all the industrial sectors have the same specific shares for each energy. This could be improved by values from the literature, as some industrial sectors are known as far more dependent on some types of energy sources than other (e.g. iron & steel vs equipment). TODO: This would be a direct and efficient way to differentiate the contrasting paths that can be followed by industrial sectors.
shCIspec_indu(indice_coal,:,:)=0.3*ones(nb_sectors_industry,nb_regions);
shCIspec_indu(indice_elec,:,:)=0.3*ones(nb_sectors_industry,nb_regions);
shCIspec_indu(indice_gaz,:,:)=0.3*ones(nb_sectors_industry,nb_regions);
shCIspec_indu(indice_Et,:,:)=0.6*ones(nb_sectors_industry,nb_regions);

//Parts substituables
shCIsubs_comp=ones(nbsecteurenergie,nb_regions)-shCIspec_comp;
shCIsubs_agri=ones(nbsecteurenergie,nb_regions)-shCIspec_agri;
shCIsubs_indu=ones(nbsecteurenergie,nb_sectors_industry,nb_regions)-shCIspec_indu;

//elasticité prix des conso énergétiques spécifiques dans différents secteurs.
if ind_ela_opt==1
	elast_elec_comp=-0.3*ones(1,nb_regions);
	elast_gaz_comp=-0.4*ones(1,nb_regions);
	elast_Et_comp=-0.4*ones(1,nb_regions);
	elast_elec_agr=-0.4*ones(1,nb_regions);
	elast_gaz_agr=-0.3*ones(1,nb_regions);
	elast_elec_ind=-0.3*ones(nb_regions,nb_sectors_industry);
	elast_gaz_ind=-0.4*ones(nb_regions,nb_sectors_industry);
	elast_Et_ind=-0.4*ones(nb_regions,nb_sectors_industry);
	elast_coal_ind=-0.3*ones(nb_regions,nb_sectors_industry);
else
	elast_elec_comp=-0.2*ones(1,nb_regions);
	elast_gaz_comp=-0.3*ones(1,nb_regions);
	elast_Et_comp=-0.3*ones(1,nb_regions);
	elast_elec_agr=-0.3*ones(1,nb_regions);
	elast_gaz_agr=-0.2*ones(1,nb_regions);
	elast_elec_ind=-0.2*ones(nb_regions,nb_sectors_industry);
	elast_gaz_ind=-0.3*ones(nb_regions,nb_sectors_industry);
	elast_Et_ind=-0.3*ones(nb_regions,nb_sectors_industry);
	elast_coal_ind=-0.2*ones(nb_regions,nb_sectors_industry);
end

/// Ces CI ne sont utlisées que pour l'énergie dans composite, agriculture et industries
CI_Subs=zeros(nb_sectors,nb_sectors,nb_regions);
CI_Spec=zeros(nb_sectors,nb_sectors,nb_regions);


// Calibration industrie

CIcompositeSubsref=zeros(nb_sectors,nb_sectors,nb_regions);
CIagricSubsref=zeros(nb_sectors,nb_sectors,nb_regions);
CIindSubsref=zeros(nb_sectors,nb_sectors,nb_regions);



for k=1:nb_regions
	CI_Subs(1:nbsecteurenergie,indice_composite,k)=shCIsubs_comp(:,k).*CI(1:nbsecteurenergie,indice_composite,k);
	if ind_NLU_CIener ==1 // coupling with the nexus land-use, only the disaggregated agriFoodProcess sector
		CI_Subs(1:nbsecteurenergie,indice_agriculture,k)=shCIsubs_agri(:,k).*alphaIC_agriFoodProcess(1:nbsecteurenergie,k);
	else
		CI_Subs(1:nbsecteurenergie,indice_agriculture,k)=shCIsubs_agri(:,k).*CI(1:nbsecteurenergie,indice_agriculture,k);
	end
	CI_Subs(1:nbsecteurenergie,indice_industries,k)=shCIsubs_indu(:,:,k).*CI(1:nbsecteurenergie,indice_industries,k);
	CIcompositeSubsref(:,indice_composite,k)=CI_Subs(:,indice_composite,k);
	CIagricSubsref(:,indice_agriculture,k)=CI_Subs(:,indice_agriculture,k);
	CIindSubsref(:,indice_industries,k)=CI_Subs(:,indice_industries,k);
end

CIcompositeSpecref=zeros(nb_sectors,nb_sectors,nb_regions);
CIagricSpecref=zeros(nb_sectors,nb_sectors,nb_regions);
CIindSpecref=zeros(nb_sectors,nb_sectors,nb_regions);

for k=1:nb_regions
	CI_Spec(1:nbsecteurenergie,indice_composite,k)=shCIspec_comp(:,k).*CI(1:nbsecteurenergie,indice_composite,k);
	if ind_NLU_CIener ==1 // coupling with the nexus land-use, only the disaggregated agriFoodProcess sector
		CI_Spec(1:nbsecteurenergie,indice_agriculture,k)=shCIspec_agri(:,k).*alphaIC_agriFoodProcess(1:nbsecteurenergie,k);
	else
		CI_Spec(1:nbsecteurenergie,indice_agriculture,k)=shCIspec_agri(:,k).*CI(1:nbsecteurenergie,indice_agriculture,k);
	end
	CI_Spec(1:nbsecteurenergie,indice_industries,k)=shCIspec_indu(:,:,k).*CI(1:nbsecteurenergie,indice_industries,k);
	CIcompositeSpecref(:,indice_composite,k)=CI_Spec(:,indice_composite,k);
	CIagricSpecref(:,indice_agriculture,k)=CI_Spec(:,indice_agriculture,k);
	CIindSpecref(:,indice_industries,k)=CI_Spec(:,indice_industries,k);
end

CIdeltacomposite_BAU=zeros(sec,sec,reg);
CIdeltacomposite_BAU(:,indice_agriculture,:)=CIagricSubsref(:,indice_agriculture,:) + CIagricSpecref(:,indice_agriculture,:);
CIdeltacomposite_BAU(:,indice_composite,:)=CIagricSubsref(:,indice_composite,:) + CIagricSpecref(:,indice_composite,:);
CIdeltacomposite_BAU(:,indice_industries,:)=CIagricSubsref(:,indice_industries,:) + CIagricSpecref(:,indice_industries,:);

CIdeltacomposite=zeros(sec,sec,reg);
for pays=1:reg
    CIdeltacomposite(:,indice_composite,pays)=CI(:,indice_composite,pays);
end

// Calibration Capital

CIvintagecompSubs=zeros(nb_sectors,nb_regions,TimeHorizon+1+dureedeviecomposite);
CIvintagecompSpec=zeros(nb_sectors,nb_regions,TimeHorizon+1+dureedeviecomposite);

for k=1:dureedeviecomposite
		for j=1:nb_regions
		CIvintagecompSubs(:,j,k)=CI_Subs(:,indice_composite,j);
		CIvintagecompSpec(:,j,k)=CI_Spec(:,indice_composite,j);
	end
end

CIvintageagriSubs=zeros(nb_sectors,nb_regions,TimeHorizon+1+dureedevieagriculture);
CIvintageagriSpec=zeros(nb_sectors,nb_regions,TimeHorizon+1+dureedevieagriculture);

for k=1:dureedevieagriculture
		for j=1:nb_regions
		CIvintageagriSubs(:,j,k)=CI_Subs(:,indice_agriculture,j);
		CIvintageagriSpec(:,j,k)=CI_Spec(:,indice_agriculture,j);
	end
end

CIvintageinduSubs=zeros(nb_sectors,nb_sectors_industry,nb_regions,TimeHorizon+1+dureedevieindustrie); //DESAG_INDUSTRY: check the order of dimensions?
CIvintageinduSpec=zeros(nb_sectors,nb_sectors_industry,nb_regions,TimeHorizon+1+dureedevieindustrie); //DESAG_INDUSTRY: check the order of dimensions?
CCS_in_industrie_vintage = (0<>zeros(4,nb_regions,nb_sectors_industry,TimeHorizon+1+dureedevieindustrie));																					  

for k=1:dureedevieindustrie
		for j=1:nb_regions
		CIvintageinduSubs(:,:,j,k)=CI_Subs(:,indice_industries,j); //DESAG_INDUSTRY: check the order of dimensions?
		CIvintageinduSpec(:,:,j,k)=CI_Spec(:,indice_industries,j); //DESAG_INDUSTRY: check the order of dimensions?
	end
end




//////////////////////////////////////////////////////////////////////////
////////////////////Calibration of EEI ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////

actualEI = ones(nb_regions,nb_sectors,TimeHorizon+1);

E_enerdelta = ones(nb_regions,nb_sectors,TimeHorizon+1);        // Cumul de toute l'efficacité energétique autonome + induite
E_enerdeltaFree = ones(nb_regions,nb_sectors,TimeHorizon+1);    // Cumul de toute l'efficacité energétique autonome => AEEI


if (indice_tech_AEEI==1) // Variante où intensité transport de la croissance évolue comme l'AEEI du secteur industriel / 1.5 : Cas Pessimiste
    E_enerdelta_trans=ones(nb_regions,1);
else                      // Variante où intensité transport de la croissance évolue comme l'AEEI du secteur industriel       : Cas optimiste
    E_enerdelta_trans=ones(nb_regions,1);
end


//old alternative for energy efficiency, see r29305

//////////////////////////////////////////////////////////////////////////
///////////////////////// Calibration of EEICosts ////////////////////////
//////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////secteur services

//durée de vie des équipements résidentiels prise en compte dans les décisions d'investissement
Life_time_ser=30;
//disc_ser=0.1;

//////////////////////////////////////////////////////secteur Industrie

//durée de vie des équipements résidentiels prise en compte dans les décisions d'investissement
Life_time_ind=30;
//disc_ind=0.1;

//////////////////////////////////////////////////////secteur Agriculture

//durée de vie des équipements résidentiels prise en compte dans les décisions d'investissement
Life_time_agr=30;
//disc_agr=0.1;

//////////////////////////////////////////////////////secteur construction

//durée de vie des équipements résidentiels prise en compte dans les décisions d'investissement
Life_time_btp=30;
//disc_btp=0.1;

//////////////////////////
//Energy efficiency
//////////////////////////
delta_markup_EE_ser=zeros(nb_regions,1);
delta_markup_EE_ind=zeros(nb_regions,nb_sectors_industry);
delta_markup_EE_agr=zeros(nb_regions,1);
delta_markup_EE_btp=zeros(nb_regions,1);


