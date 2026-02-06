// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thomas Le Gallic, Thibault Briera, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// geographic regions (12)
// 1  USA 	USA
// 2  CAN	Canada
// 3  EUR	EU-25 + turkey
// 4  JAN	Japan Australia New Zealand Corea
// 5  CIS	Former Soviet Union
// 6  CHN	China
// 7  IND	India   
// 8  BRA	Brazil
// 9  MDE	Middle East
// 10 AFR	Africa
// 11 RAS	Rest of Asia
// 12 RAL	Rest of Latin America

regnames = read_csv('./data/order_regions.csv');

nb_regions = max(size(regnames,'r'),size(regnames,'c'));
reg = nb_regions;

for ireg = 1:nb_regions
    execstr('ind_'+convstr(regnames(ireg))+'=ireg;')
end

ind_global_north = [ind_usa, ind_can, ind_eur, ind_jan, ind_cis];
ind_global_south = [ind_chn, ind_ind, ind_bra, ind_mde, ind_afr, ind_ras, ind_ral];

// indicators according to World bank classification
ind_high_income = [ind_usa, ind_can, ind_eur, ind_jan];
ind_middle_income = [ind_cis, ind_chn, ind_bra];
ind_low_income = [ind_ind, ind_mde, ind_afr, ind_ras, ind_ral];

//for WACC model, distinction between emerging and developed for debt shares
emerging_reg = [ind_cis,ind_ind, ind_mde, ind_afr, ind_ras, ind_ral];
developed_reg = [ind_usa, ind_can, ind_eur, ind_jan,ind_chn,ind_bra]; //brazil is excluded from de-risking since it has mostly hydropower

indice_transport_1 = 8;
indice_transport_2 = 10;
nb_trans = indice_transport_2 - indice_transport_1 + 1;

// indices definition fore the househodls consumption dimenssion
indice_coal 	= 1;
indice_oil  	= 2;
indice_gas  	= 3;
indice_Et   	= 4;
indice_elec 	= 5;
indice_construction	= 6;
indice_composite    	= 7; // ~ services sector
indice_air  	= 8;
indice_mer  	= 9;
indice_OT   	= 10;
indice_agriculture	= 11;
indice_industries 	= [12 : (12 + nb_sectors_industry - 1)]; 

if nb_sectors_industry ==8
    indice_ind_agro  = 12;
    indice_ind_heavy = 13; 
    indice_ind_steel = 14; 
    indice_ind_nomin = 15;
    indice_ind_chem  = 16;
    indice_ind_lght  = 17;
    indice_ind_vhcl  = 18;
    indice_ind_equip = 19;
end

coal = 1;
oil  = 2;
gaz  = 3;
et   = 4;
elec = 5;
btp  = 6;
compo= 7;
air  = 8;
mer  = 9;
ot   = 10;
agri = 11;
indus= indice_industries; // DESAG_INDUSTRY, TOCHECKAGAIN: probably won't work for some files (indexes used in extraction files + Nexus land use)

transportIndexes = [ air mer ot ];
energyIndexes = [ coal oil gaz et elec ];
indice_FF_Et = [ coal oil gaz et];
nonEnergyIndexes = [ btp compo agri indus ];
nonEnergySectors = [ btp compo air mer ot agri indus];
indice_all_services = [transportIndexes indice_composite];

// if ~isdef('nb_sectors') ; DESAG_INDUSTRY: "if" removed. Why was it necessary? Where could it be defined before?
nb_sectors = 12 + (nb_sectors_industry - 1) + (nb_sectors_services - 1) ;	// nb_sectors_services is an anticipation for future desaggregation, not in use
//end
sec = nb_sectors;

if nb_sectors_industry == 1
    secnames = [
    "coal"
    "oil"
    "gaz"
    "Et"
    "elec"
    "cons"
    "comp"
    "air"
    "mer"
    "OT"
    "agri"
    "indu"
    ];
elseif nb_sectors_industry == 8 // TOCHECKAGAIN: need to prefer composed name with numbers (indus_1, etc.)? If not, probably better for users to have these explicit names.
    // EDIT: finally these short name are almost not in use (just a few exceptions for which an update will be require if we change these names). At the moment: nexus.CTL.sci and nexus.laborProductivity.sce
    secnames = [
    "coal"
    "oil"
    "gaz"
    "Et"
    "elec"
    "cons"
    "comp"
    "air"
    "mer"
    "OT"
    "agri"
    "indu_agro"
    "indu_heavy"
    "indu_ironsteel"
    "indu_nonmineral"
    "indu_chemical"
    "indu_light"
    "indu_vehicles"
    "indu_equipment"
    ];
end
	

//number of sector that enter the utility function, transport excluded
nb_secteur_conso = 7 + (nb_sectors_industry - 1); // DESAG_INDUSTRY: is it still in use?

//composite (services) sector disagregation
nbsecteurcomposite= 3 + (nb_sectors_industry - 1) + (nb_sectors_services - 1) ;

//number of sector that enter the utility function, transport excluded
nb_secteur_utile = 3 + (nb_sectors_industry - 1) + (nb_sectors_services - 1) ;
ind_sector_util = [ btp compo mer agri indus];


indice_energiefossile1 = 1;
indice_energiefossile2 = 3;

nbsecteurenergie = 5;

energ_sec = zeros(reg,sec);
//number of line in the energy balance matrix
indice_matEner=17; // DESAG_INDUSTRY: in this first version, we didn't desaggregate it

prod_eb        = 1;  // Production 
imp_eb         = 2;  // Import
exp_eb         = 3;  // Export
marbunk_eb     = 4;  // Marine bunker
tpes_eb        = 5;  // Primary Supply TPES 
refi_eb        = 6;  // Refineries
pwplant_eb     = 7;  // Power plants
losses_eb      = 8;  // Own use/losses 
conso_tot_eb   = 9;  // Total Final consumption
conso_comp_eb  = 10; // Consumption by composite sector
conso_agri_eb  = 11; // Consumption by agriculture sector 
conso_indu_eb  = 12; // Consumption by industry sector ; if the industrial sector is disagregated into several subsectors, this is the sum of these subsectors (including agro-industry)
conso_air_eb   = 13; // Consumption by Air transportation 
conso_ot_eb    = 14; // Consumption by Other transport 
conso_car_eb   = 15; // Consumption by Private Automobile 
conso_resid_eb = 16; // Consumption by Résidential sector 
conso_btp_eb   = 17; // Consumption by Building sector   

conso_transport_eb = [conso_air_eb conso_ot_eb conso_car_eb];

// names of energy matrice
matEner_names_cons = [
"Production"
"Import"
"Export"
"Marine_bunker"
"Primary_Supply_TPES "
"Refineries"
"Power_plants"
"Own_use/losses"
"Final_consumption"
"Cons_composite"
"Cons_agriculture"
"Cons_industry"
"Cons_Air_trans"
"Cons_Other_trans"
"Cons_Private_Automobile"
"Cons_Residential"
"Cons_Building"
];
matEner_names = ['Coal','Oil','Et','Gaz','Hydro','Nuke','ENR','Elec'];
WEner_names = ['Coal','Oil','Gaz','Et','Elec'];

// column indices of the energy balance matrix
coal_eb     = 1; //Coal
oil_eb      = 2; //Oil
et_eb       = 3; //Et
gas_eb      = 4; //Gaz
hyd_eb      = 5; //Hydro
nuc_eb      = 6; //Nuc
enr_eb      = 7; //ENR
elec_eb     = 8; //Elec

primary_eb = [coal_eb oil_eb gas_eb hyd_eb nuc_eb enr_eb];
secondary_eb = [et_eb elec_eb];
fossil_primary_eb = [coal_eb oil_eb gas_eb];
all_eb = [primary_eb secondary_eb];
nb_ener_eb = length(all_eb);

non_energ_sec = ones(reg,sec);
//number of usage in the emission_usage variable
nb_use = 14+nb_sectors_industry; // DESAG_INDUSTRy: should be checked again, I am not sure to have adapted the computation of emissions

//usages en question
iu_coal   = 1; //unused ? 
iu_oil    = 2; //unused ? 
iu_gaz    = 3; //unused ?   //gas
iu_Et     = 4; //unused ?    
iu_elec   = 5; 
iu_cons   = 6;  
iu_comp   = 7; 
iu_air    = 8;   
iu_mer    = 9;         
iu_OT     = 10;    
iu_agri   = 11;      
iu_indu   = 12:(11+nb_sectors_industry);// DESAG_INDUSTRy: should be checked again, I am not sure to have adapted the computation of emissions
iu_df     = 12+nb_sectors_industry;    
iu_di     = 13+nb_sectors_industry;  
iu_dg     = 14+nb_sectors_industry; 

usenames=[secnames;"df"; "di"; "dg"];
iu_ener = [iu_coal:iu_elec];
iu_non_ener = [iu_cons:iu_dg];

whichuse =zeros(1,sec);
whichuse = 1:sec; //this might look stupid, but it gives compatibility with IMACLIM-R France


techno_elec=26;

indAggElec.coalWoCcs = 1;
indAggElec.coalWCcs  = 2;
indAggElec.gasWoCcs  = 3;
indAggElec.gasWCcs   = 4;
indAggElec.oil       = 5;
indAggElec.nuke      = 6;
indAggElec.hydro     = 7;
indAggElec.wind      = 8;
indAggElec.becc      = 9;
indAggElec.beccs     = 10;
indAggElec.solar     = 11;
indAggElec.unused    = 12;

indAggTPES.coal = 1;
indAggTPES.oil  = 2;
indAggTPES.gas  = 3;
indAggTPES.hyd  = 4;
indAggTPES.nuc  = 5;
indAggTPES.enr  = 6;

indAggUse.compo  = 1; // Consumption by composite sector
indAggUse.agri  = 2; // Consumption by agriculture sector 
indAggUse.indu  = 3; // Consumption by industry sector 
indAggUse.transp = 4; // Consumption by transportation  
indAggUse.resid = 5; // Consumption by Résidential sector 
indAggUse.btp   = 6; // Consumption by Building sector   

tpt.nb   = 5;
tpt.auto = 1;
tpt.air  = 2;
tpt.nm   = 3;
tpt.ot   = 4;
tpt.mer  = 5;
