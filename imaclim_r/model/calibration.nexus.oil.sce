// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Julien Lefèvre, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

///////////////////////////////////////////////////////////
///////////Calibration Nexus Oil///////////////////////////
///////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   INDEXES and DIMENSSIONS   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////

//Region considered as fatal producers
fatal_producer=[ind_usa,ind_can,ind_eur,ind_jan,ind_cis,ind_chn,ind_ind,ind_bra,ind_afr,ind_ras,ind_ral];

nb_cat_oil=7;
////////categories of reserves
nb_cat_heavy=7;

nb_cat_shale=5;

no_shale_oil=%t; // We do not consider oil shale

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION with no source   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

/////////////////definition of the curve mult_oil
a4_mult_oil=  0*ones(nb_regions,1);
a3_mult_oil=  0*ones(nb_regions,1);
a2_mult_oil=  0*ones(nb_regions,1);
a1_mult_oil=-20*ones(nb_regions,1);
a0_mult_oil= 20*ones(nb_regions,1);

//parameter to calibrate Hubbert Curves
hs_oil=0.05;
hs_heavy=0.05;
hs_shale=0.05;

//share of ultimate resources from which we consired the resource exhausted
fract_exhausted=0.2;

Q_cum_oil_MO=0;
half_extraction_MO=0;

test_100 = 0;

// share of ressources considered in Hubbert curves computation
share_ress_HubbertCurves =  0.95;

// maximum decrease of Middle East capacities
max_decrease_MO_cap = 0.94;

/////////////////////////////////////////////////////////////////////////////////////////////
//    ---*---   CALIBRATION   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////

////Load supply curves
///////////////////////////////////////////////////////////

// Supply curves are in the format: first column is costs ($/GJ), second column is quantities (EJ = 10^9 GJ); heades are commented with '//'
// one file per region / oil category
list_oil_ress = ["Conventional", "Extra_Heavy", "Shale", "Tar_sands"];
nb_oil_cat = zeros( list_oil_ress);
i_res=0;
for resource_type=list_oil_ress
    i_res=i_res+1;
    ireg=0;
    mat_res.quant = zeros(nb_regions, 1);
    mat_res.costs = zeros(nb_regions, 1);
    for regn=regnames'
        ireg = ireg+1;
        filename = path_fossil_SC + "oil_"+resource_type+"_"+regn+".csv";
        if size( mgetl(filename),"r") <>1 // avoid regions with no or zero data
            mat_sc = csvRead( path_fossil_SC + "oil_"+resource_type+"_"+regn+".csv", "|",[],[],[],'/\/\//');
            //mat_sc = mat_sc(2:$,:); // to be repalced by a comment for the header in data
            mat_res.costs(ireg, 1:size(mat_sc,"r")) = mat_sc(:,1)';
            mat_res.quant(ireg, 1:size(mat_sc,"r")) = mat_sc(:,2)';
        end
    end
    nb_oil_cat(i_res) = size( mat_res.costs, "c");
    if i_res==1
        supply_curves.oil.costs = mat_res.costs;
        supply_curves.oil.quantities = mat_res.quant;
    else
        supply_curves.oil.costs = [supply_curves.oil.costs mat_res.costs];
        supply_curves.oil.quantities = [supply_curves.oil.quantities mat_res.quant];
    end
end


// Conversions of supply curves to $/barrel and Mtoe
oilbarrels2GJ = 5.86152;

supply_curves.oil.costs = supply_curves.oil.costs*oilbarrels2GJ;  // conversion to $/barrel
supply_curves.oil.quantities = supply_curves.oil.quantities/oilbarrels2GJ/tep2oilbarrels*1000; // conversion to Mtoe

// Identification of oil cost categories and cost limits of categories
nb_cat = [];
wp_lim = [];
size_supply_curve = size(supply_curves.oil.costs(1,:));
d =1;
while (d<=size_supply_curve(2)-1)
    while (supply_curves.oil.costs(1,d)) == 0 & (d<=size_supply_curve(2)-1)
        d = d+1;
    end
    if d<=size_supply_curve(2)-1 then
        wp_lim = [wp_lim,supply_curves.oil.costs(1,d)];
        e=1;
        while (supply_curves.oil.costs(1,d+1)>supply_curves.oil.costs(1,d))
            wp_lim = [wp_lim,supply_curves.oil.costs(1,d+1)];	
            e = e+1;	
            d = d+1;
        end
        nb_cat = [nb_cat,e];
    end
    d =d+1;
end

nb_cat(4) = 14;
wp_lim = [wp_lim(1:nb_cat(1)+nb_cat(2)+nb_cat(3)),supply_curves.oil.costs(2,nb_cat(1)+4+nb_cat(2)+nb_cat(3)+1:nb_cat(1)+4+nb_cat(2)+nb_cat(3)+nb_cat(4))];

// Computation of Ress_infini_oil matrix based on supply curves and cost limits
Ress_infini_oil = [];
Ress_infini_oil = [Ress_infini_oil,sum((supply_curves.oil.costs(:,1:nb_cat(1)+4) <= wp_lim(1)).*supply_curves.oil.quantities(:,1:nb_cat(1)+4),'c')];
for i=2:nb_cat(1)
    Ress_infini_oil = [Ress_infini_oil,sum((supply_curves.oil.costs(:,1:nb_cat(1)+4) <= wp_lim(i) & supply_curves.oil.costs(:,1:nb_cat(1)+4) > wp_lim(i-1) ).*supply_curves.oil.quantities(:,1:nb_cat(1)+4),'c')];
end
Ress_infini_oil = [Ress_infini_oil,sum((supply_curves.oil.costs(:,nb_cat(1)+4+1:nb_cat(1)+4+nb_cat(2)) <= wp_lim(nb_cat(1)+1)).*supply_curves.oil.quantities(:,nb_cat(1)+4+1:nb_cat(1)+4+nb_cat(2)),'c')];
for i=nb_cat(1)+2:nb_cat(1)+nb_cat(2)
    Ress_infini_oil = [Ress_infini_oil,sum((supply_curves.oil.costs(:,nb_cat(1)+4+1:nb_cat(1)+4+nb_cat(2)) <= wp_lim(i) & supply_curves.oil.costs(:,nb_cat(1)+4+1:nb_cat(1)+4+nb_cat(2)) > wp_lim(i-1) ).*supply_curves.oil.quantities(:,nb_cat(1)+4+1:nb_cat(1)+4+nb_cat(2)),'c')];
end
Ress_infini_oil = [Ress_infini_oil,sum((supply_curves.oil.costs(:,nb_cat(1)+4+nb_cat(2)+1:nb_cat(1)+4+nb_cat(2)+nb_cat(3)) <= wp_lim(nb_cat(1)+nb_cat(2)+1)).*supply_curves.oil.quantities(:,nb_cat(1)+4+nb_cat(2)+1:nb_cat(1)+4+nb_cat(2)+nb_cat(3)),'c')];
for i=nb_cat(1)+nb_cat(2)+2:nb_cat(1)+nb_cat(2)+nb_cat(3)
    Ress_infini_oil = [Ress_infini_oil,sum((supply_curves.oil.costs(:,nb_cat(1)+4+nb_cat(2)+1:nb_cat(1)+4+nb_cat(2)+nb_cat(3)) <= wp_lim(i) & supply_curves.oil.costs(:,nb_cat(1)+4+nb_cat(2)+1:nb_cat(1)+4+nb_cat(2)+nb_cat(3)) > wp_lim(i-1) ).*supply_curves.oil.quantities(:,nb_cat(1)+4+nb_cat(2)+1:nb_cat(1)+4+nb_cat(2)+nb_cat(3)),'c')];
end
Ress_infini_oil = [Ress_infini_oil,sum((supply_curves.oil.costs(:,nb_cat(1)+4+nb_cat(2)+nb_cat(3)+1:nb_cat(1)+4+nb_cat(2)+nb_cat(3)+nb_cat(4)) <= wp_lim(nb_cat(1)+nb_cat(2)+nb_cat(3)+1)).*supply_curves.oil.quantities(:,nb_cat(1)+4+nb_cat(2)+nb_cat(3)+1:nb_cat(1)+4+nb_cat(2)+nb_cat(3)+nb_cat(4)),'c')];
for i=nb_cat(1)+nb_cat(2)+nb_cat(3)+2:nb_cat(1)+nb_cat(2)+nb_cat(3)+nb_cat(4)
    Ress_infini_oil = [Ress_infini_oil,sum((supply_curves.oil.costs(:,nb_cat(1)+4+nb_cat(2)+nb_cat(3)+1:nb_cat(1)+4+nb_cat(2)+nb_cat(3)+nb_cat(4)) <= wp_lim(i) & supply_curves.oil.costs(:,nb_cat(1)+4+nb_cat(2)+nb_cat(3)+1:nb_cat(1)+4+nb_cat(2)+nb_cat(3)+nb_cat(4)) > wp_lim(i-1) ).*supply_curves.oil.quantities(:,nb_cat(1)+4+nb_cat(2)+nb_cat(3)+1:nb_cat(1)+4+nb_cat(2)+nb_cat(3)+nb_cat(4)),'c')];
end

wp_lim_v2 = wp_lim;
Ress_infini_oil_v2 = Ress_infini_oil;


////calibration for Hubbert curves
///////////////////////////////////////////////////////////

pente_conv=vdc_cff;
pente_unconv=vdv_cff;

//Data from the Lopex model
//"Exploitation IMACLIM reserves lopex couts_new.xls"
//reserves_pétrole_Total_02avril.xls

//limites des catégories
wp_lim=csvRead(path_oil_pscenario+"wp_lim.csv",'|',[],[],[],'/\/\//');

Ress_infini_oil=1000*oil_cff*csvRead(path_oil_ress+"Ress_infini_oil.csv",'|',[],[],[],'/\/\//');

Ress_infini_oil_MO=sum(Ress_infini_oil(ind_mde,:),'c');

//cumulative extraction
cumul_extra=1000*csvRead(path_oil_production+"cumul_extra.csv",'|',[],[],[],'/\/\//');

Ress_0_oil=Ress_infini_oil-cumul_extra;

Ress_oil=Ress_0_oil;

Ress_0_oil_MO=sum(Ress_0_oil(ind_mde,:),'c');


//////////////////////////////////////////////////////////////////////////////////////////////////////////
//Test to determine which resourdce is under exploitation at calibration year

test_exploit_oil=ones(nb_regions,nb_cat_oil);

for k=fatal_producer,
    for j=1:nb_cat_oil,
        if (Ress_0_oil(k,j)==Ress_infini_oil(k,j)) then test_exploit_oil(k,j)=0; end
    end
end

//boolean variable which declare a category of oil under exploitation
test_premexploit_oil=test_exploit_oil;


//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Claibration of Hubbert curves of already producing categories

pente_hubbert=pente_conv*ones(nb_regions,nb_cat_oil);
i_hubbert=zeros(nb_regions,nb_cat_oil);
Cap_0=zeros(nb_regions,nb_cat_oil);


Q_oil_parcategorie=zeros(nb_regions,nb_cat_oil);
for k=fatal_producer
    for j=1:nb_cat_oil
        Q_oil_parcategorie(k,j)=Qref(k,indice_oil)*Ress_0_oil(k,j)*test_exploit_oil(k,j)/(sum(Ress_0_oil(k,:).*test_exploit_oil(k,:),'c'));
    end
end

//Historical data are used to calibrate Hubbert curves for category already producing
//Other categories have a fixed curves

for k=fatal_producer,
    for j=1:nb_cat_oil,
        if (test_exploit_oil(k,j)==1) then      exp_temp=(Ress_0_oil(k,j)/Ress_infini_oil(k,j))/(1-Ress_0_oil(k,j)/Ress_infini_oil(k,j));
            pente_hubbert(k,j)=Q_oil_parcategorie(k,j)/Ress_infini_oil(k,j)*((1+exp_temp)^2/exp_temp);
            i_hubbert(k,j)=log(exp_temp)/pente_hubbert(k,j);
            Cap_0(k,j)=Ress_infini_oil(k,j) / base_charge_noFCC(indice_oil);end
    end
end


// pente_hubbertref=pente_hubbert;
// i_hubbertref=i_hubbert;
// Cap_0ref=Cap_0;

//Hubbert capacity at the base year

Cap_hubbert=Cap_0.*pente_hubbert.*exp(-(pente_hubbert.*(0-i_hubbert)))./(1+exp(-(pente_hubbert.*(0-i_hubbert)))).^2;

//Used capacities

Cap_util_oil=Cap_hubbert;
// Cap_util_oilref=Cap_util_oil;

Cap_hubbert_suivant=Cap_util_oil;

//year of first usage per oil category
id_oil=zeros(nb_regions,nb_cat_oil);



/////////////////////////////////////////////////////////////////////
//non conventional oil
/////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////
//heavy oil

// exported prodcost_heavy_old.csv

//Heavy oil production costs from TOTAL data
prodcost_heavy=csvRead(path_oil_production+"prodcost_heavy_Total.csv",'|',[],[],[],'/\/\//');

//process emissions in tCO2/bbl
emission_heavy=csvRead(path_oil_production+"emission_heavy.csv",'|',[],[],[],'/\/\//');

//breakeven prices per category
//wp_lim_heavy=prodcost_heavy+TAXVAL_Poles(1,1)*emission_heavy;
wp_lim_heavy=prodcost_heavy; // + emission_heavy; //TODO : need to create an index for the tax

//////////////////////////////////////////////////////////////////////////////////////
// ultimate resource: reserves_pétrole_Total_02avril.xls data
Ress_infini_heavy=1000*heavy_cff*csvRead(path_oil_ress+"Ress_infini_heavy.csv",'|',[],[],[],'/\/\//');

Ress_0_heavy=Ress_infini_heavy;
Ress_heavy=Ress_0_heavy;
Q_cum_heavy=zeros(nb_regions,nb_cat_heavy);
Q_heavy_parcategorie=zeros(nb_regions,nb_cat_heavy);

////////tests for starting of not production in an oil category

test_heavy=zeros(nb_regions,nb_cat_heavy);
test_heavy_prev=test_heavy;

test_prem_heavy=test_heavy;


//test for oil category having a stop and go production
// equal 1 only if we stopped in the previous step and start producing again this year
test_redem_heavy=zeros(nb_regions,nb_cat_heavy);


///////initialisation of Hubbert Curves caracteristics (for not producing oil categories)

id_heavy=zeros(nb_regions,nb_cat_heavy);
Cap_heavy_0=zeros(nb_regions,nb_cat_heavy);
exp_heavy=zeros(nb_regions,nb_cat_heavy);
i_heavy=zeros(nb_regions,nb_cat_heavy);
pente_heavy=pente_unconv*ones(nb_regions,nb_cat_heavy);

Cap_util_heavy=zeros(nb_regions,nb_cat_heavy);
Cap_util_heavy_prev=Cap_util_heavy;
Cap_heavy_suivant=zeros(nb_regions,nb_cat_heavy);


half_heavy=zeros(nb_regions,nb_cat_heavy);

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//shale oil

//production cost en $/bbl
prodcost_shale=csvRead(path_oil_production+"prodcost_shale.csv",'|',[],[],[],'/\/\//');

//process emissions en tCO2/bbl
emission_shale=csvRead(path_oil_emissions+"emission_shale.csv",'|',[],[],[],'/\/\//');

////////resources

Ress_infini_shale=1000*csvRead(path_oil_ress+"Ress_infini_shale.csv",'|',[],[],[],'/\/\//');


Ress_0_shale=Ress_infini_shale;
Ress_shale=Ress_0_shale;
Q_cum_shale=zeros(nb_regions,nb_cat_shale);
Q_shale_parcategorie=zeros(nb_regions,nb_cat_shale);

////////test for starting production

test_shale=zeros(nb_regions,nb_cat_shale);
test_shale_prev=test_shale;
test_prem_shale=test_shale;

//test for oil category having a stop and go production
// equal 1 only if we stopped in the previous step and start producing again this year
test_redem_shale=zeros(nb_regions,nb_cat_shale);

///////initialisation of Hubbert Curves caracteristics (for not producing oil categories)
id_shale=zeros(nb_regions,nb_cat_shale);
Cap_shale_0=zeros(nb_regions,nb_cat_shale);
exp_shale=zeros(nb_regions,nb_cat_shale);
i_shale=zeros(nb_regions,nb_cat_shale);
pente_shale=pente_unconv*ones(nb_regions,nb_cat_shale);

Cap_util_shale=zeros(nb_regions,nb_cat_shale);
Cap_util_shale_prev=Cap_util_shale;
Cap_shale_suivant=zeros(nb_regions,nb_cat_shale);



half_shale=zeros(nb_regions,nb_cat_shale);


//////////////////////////////////////////////////////////////////////////////////////////////////////////
////specific case for Middle East

// Middle East does not FOllow Hubbert Curves

// Cap_0_MOref=Ress_infini_oil_MO/0.8;
// exp_temp_MOref=(Ress_0_oil_MO/Ress_infini_oil_MO)/(1-Ress_0_oil_MO/Ress_infini_oil_MO);
// pente_hubbert_MOref=Qref(9,2)/Ress_infini_oil_MO*((1+exp_temp_MOref)^2/exp_temp_MOref);
// i_hubbert_MOref=log(exp_temp_MOref)/pente_hubbert_MOref;

// Cap_hubbert_MOref=Cap_0_MOref*pente_hubbert_MOref*exp(-(pente_hubbert_MOref*(0-i_hubbert_MOref)))/(1+exp(-(pente_hubbert_MOref*(0-i_hubbert_MOref))))^2;

// Cap_MO=Cap_hubbert_MOref;

Cap_MO=Cap(ind_mde,indice_oil);

//////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////// intermediate consumption of the opil sector evolution
///production cost structure of oil production
CI_oil=zeros(nb_sectors,nb_regions);

for k=1:nb_regions
    CI_oil(:,k)=CItotref(:,indice_oil,k)/Qref(k,indice_oil);
end

//remaining oil quantity per oil category
Q_cum_oil=zeros(nb_regions,nb_cat_oil);

//alpha_oil calibration
alpha_oilref=zeros(nb_regions,nb_cat_oil);

for k=1:nb_regions
    for j=1:nb_cat_oil

        if (Ress_infini_oil(k,j)==0)
            alpha_oilref(k,j)=0;
        else
            alpha_oilref(k,j)=(((wp_lim(j)*tep2oilbarrels)*Ress_0_oil(k,j))+(wp_lim(j+1)*tep2oilbarrels)*(Ress_infini_oil(k,j)-Ress_0_oil(k,j)))/(Ress_infini_oil(k,j))/(sum(pArmCIref(:,indice_oil,k).*CI_oil(:,k),'r'));
        end
    end
end

alpha_oil_MOref=100*(Ress_infini_oil_MO-Ress_0_oil_MO)/(Ress_infini_oil_MO)/(sum(pArmCIref(:,indice_oil,ind_mde).*CI_oil(:,ind_mde),'r'));

alpha_barre_ref=zeros(nb_regions,1);

for k=fatal_producer
    alpha_barre_ref(k)=sum(Cap_util_oil(k,:).*alpha_oilref(k,:),'c')./sum(Cap_util_oil(k,:),'c');
end

alpha_barre_ref(ind_mde)=alpha_oil_MOref;

alpha_oil=zeros(nb_regions,nb_cat_oil);
alpha_barre=zeros(nb_regions,1);

markup_lim_oil=ones(nb_regions,nb_sectors);
markup_lim_oil(:,indice_oil)=csvRead(path_oil_production+"markup_lim_oil.csv",'|',[],[],[],'/\/\//');  


/////////////////////////////////////////////////////////////////////////////////////////////
sorties_hubbert=zeros(nb_regions*nb_cat_oil+nb_regions*nb_cat_heavy+nb_regions*nb_cat_shale+1+nb_regions+1+1+1+nb_regions,TimeHorizon+1); //unused except in branch renault2010 --> TO_DEL ? 


/////////////////////////////////////////////////////////////////////////////////////////////
depletion_finale_MO=0;
profit_oil=zeros(1,TimeHorizon+1);
profit_oil_MO=zeros(1,TimeHorizon+1);
Cap_MO_t=zeros(5,TimeHorizon+1);
prix_oil=zeros(1,TimeHorizon+1);
balance_energ=zeros(nb_regions*16*8,TimeHorizon+1);
Qcum_oil_tot=zeros(nb_regions*nb_cat_oil,TimeHorizon+1);
//Hubbert properties

prop_Hubbert=zeros(3*nb_regions*nb_cat_oil,TimeHorizon+1);

heavy_oil=zeros(2*nb_regions*nb_cat_heavy,TimeHorizon+1);

shale_oil=zeros(2*nb_regions*nb_cat_shale,TimeHorizon+1);





half_extraction=zeros(nb_regions,nb_cat_oil);
for k=1:nb_regions
    for j=1:nb_cat_oil
        if (Ress_0_oil(k,j)<0.5*Ress_infini_oil(k,j)) then half_extraction(k,j)=1; end
    end
end

Cap_exhausted=zeros(nb_regions,nb_cat_oil);
i_exhausted=zeros(nb_regions,nb_cat_oil);
Ress_exhausted=zeros(nb_regions,nb_cat_oil);


Cap_exhausted_heavy=zeros(nb_regions,nb_cat_heavy);
i_exhausted_heavy=zeros(nb_regions,nb_cat_heavy);
Ress_exhausted_heavy=zeros(nb_regions,nb_cat_heavy);


Cap_exhausted_shale=zeros(nb_regions,nb_cat_shale);
i_exhausted_shale=zeros(nb_regions,nb_cat_shale);
Ress_exhausted_shale=zeros(nb_regions,nb_cat_shale);


FCCmarkup_oil=ones(nb_regions,nb_sectors);

// intialisation to zero : TODO set it to its true value
// share of non-conventionnal oil
share_NC=0;


/////////////////////couts d'extraction des FF tirÃ©s de poles fichier Courbes de couts PÃ©trole Gaz Charbon.xls
// Cumulated extracted quantity (k,t) 2001-2050 from POLES
// note : first date is repeated three times 
// Data on prices have been modified in the file "prix FF extrapolation.xls"


//Q_cum_oil_poles  = csvRead(TECH+'Q_cum_oil_poles.csv', separator='|', [], [], [], '/\/\//'); //used here through deriv_oil, which is then unused in the nexus / model --> TO_DEL ? 
//wp_oil_poles     = csvRead(TECH+'wp_oil_poles.csv', separator='|', [], [], [], '/\/\//');  //used here through deriv_oil, which is then unused in the nexus / model --> TO_DEL ? 
//etude_oil_price_MO=zeros(5*nb_regions+2+1+1,TimeHorizon+1); //unused, except for the extraction (other uses commented) --> TO_DEL ?

//first date is replaced by hybrid value
//Q_cum_oil_poles(:,1) = Qref(:,indice_oil);



////////////////Calibration
//calculating the derivative of the curve p=f(Q_cum_oil) in Q_cum_oil_max, using a linear interpolation on the last 5 points
//for k=1:nb_regions
//        deriv_oil(k)=interpln([Q_cum_oil_poles(k,$-5:$);wp_oil_poles($-5:$)],1)-interpln([Q_cum_oil_poles(k,$-5:$);wp_oil_poles($-5:$)],0); //unused --> TO_DEL ? 
//end
//calculating the mean derivative on the last points of the curves p=f(Q_cum) to extrapolate in 2100
//((wp_gaz_poles(:,$)-wp_gaz_poles(:,$-1))*ones(nb_regions,1))./(Q_cum_gaz_poles(:,$)-Q_cum_gaz_poles(:,$-1))
