// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Ruben Bibas, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

////////////////////////////////////////////////////////////////////////
////////////////Calibration Nexus Liquid Fuels////////////////////////////
////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   INDEXES and DIMENSSIONS   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////
//   ---*---   PARAMETERS / INITIALISATION with no source   ---*---   
/////////////////////////////////////////////////////////////////////////////////////////////

//For biofuels, we assume their carbon content is equal to 10% or 20% the one from fuels from oil products
//order of magnitude from IEA "biofuel for transport" p63 and p65
carbon_oilfuel2biodiesel = 0.1;
carbon_oilfuel2ethanol = 0.2;
coef_Q_CO2_biodiesel = carbon_oilfuel2biodiesel * coef_Q_CO2_ref(:,indice_Et);
coef_Q_CO2_ethan = carbon_oilfuel2ethanol * coef_Q_CO2_ref(:,indice_Et);

//efficiency of synfuel (coal-to-liquids) transformation
yield_CTL=0.5;

// time length to get to one the weightEt for new market share computation
// the name of the variable - with zeroing - is quite misleading, but the idea is indeed to make this weight go to one
time_zeroing_weightEt_new = 10;

// tax levels to launch Coal-to-Liquids with CCS
start_tax_CCS_CTL = 25; // $/tCO2
tax_min_CCS_CTL=50*ones(reg,1);
tax_max_CCS_CTL=100*ones(reg,1);

// maximum share of Coal-to-Liquids with CCS in the liquids market
max_share_CCS_CTL = 0.9;

// minimum market share of refined oil; only with linkage with NexusLandUse (ind_NLU>1)
min_share_oil_refined = 0.0001;

/////////////////////////////////////////////////////////////////////////////////////////////
//    ---*---   CALIBRATION   ---*---    
/////////////////////////////////////////////////////////////////////////////////////////////

//Defining refinery cost structure from oil in each region
//order in the structure: CI(:,Et,k),l(k,Et),markup(k,Et)
Cost_struc_oil_refin_ref=zeros(nb_regions,nb_sectors+2);
for k=1:nb_regions
    Cost_struc_oil_refin_ref(k,:)=[CIref(:,indice_Et,k)',lref(k,indice_Et),markupref(k,indice_Et)];
end


p_Et_oil_anticip=zeros(nb_regions,1);
//biofuels supply curves from "biofuels supply curves iea.xls"
//vector of fuel price per liter of gasoline equivalent
p_Et_lge_biodies=csvRead(path_Et+"p_Et_lge_biodies.csv",'|',[],[],[],'/\/\//');
supply__biodies_2010=csvRead(path_Et+"supply__biodies_2010.csv",'|',[],[],[],'/\/\//');
supply__biodies_2030=csvRead(path_Et+"supply__biodies_2030.csv",'|',[],[],[],'/\/\//');
supply__biodies_2050=csvRead(path_Et+"supply__biodies_2050.csv",'|',[],[],[],'/\/\//');

///linear interpolation between the dots given for each of the three supply curves (price,Quantity) for 2010, 2030 and 2050
supplyBiodies2010_temp=supply__biodies_2010;
supplyBiodies2030_temp=supply__biodies_2030;
supplyBiodies2050_temp=supply__biodies_2050;
for k=1:29
    supply__biodies_2010(k)=interpln([[1,19,24,25,29];[supplyBiodies2010_temp(1),supplyBiodies2010_temp(19),supplyBiodies2010_temp(24),supplyBiodies2010_temp(25),supplyBiodies2010_temp(29)]],k);
    supply__biodies_2030(k)=interpln([[1, 7,14,22,29];[supplyBiodies2030_temp(1),supplyBiodies2030_temp( 7),supplyBiodies2030_temp(14),supplyBiodies2030_temp(22),supplyBiodies2030_temp(29)]],k);
    supply__biodies_2050(k)=interpln([[1, 9,14,14,29];[supplyBiodies2050_temp(1),supplyBiodies2050_temp( 9),supplyBiodies2050_temp(14),supplyBiodies2050_temp(14),supplyBiodies2050_temp(29)]],k);
end

size_p_Et_biodies=size(p_Et_lge_biodies);
supply__biodies=zeros(99,size_p_Et_biodies(2));
supply__biodies(9,:)=supply__biodies_2010;
supply__biodies(29,:)=supply__biodies_2030;
supply__biodies(49,:)=supply__biodies_2050;

//Interpolation over time of the supply curve at each date, between the three given for 2010, 2030 and 2050
//Assuming that after 2050 the supply curve does not evolve anymore
for j=10:28
    for k=1:size_p_Et_biodies(2)
        supply__biodies(j,k)=interpln([[9,29];[supply__biodies(9,k),supply__biodies(29,k)]],j);
    end
end
for j=30:48
    for k=1:size_p_Et_biodies(2)
        supply__biodies(j,k)=interpln([[30,48];[supply__biodies(29,k),supply__biodies(49,k)]],j);
    end
end
for j=50:99
    for k=1:size_p_Et_biodies(2)
        supply__biodies(j,k)=supply__biodies(49,k);
    end
end

//supply curves are calibrated for 2001-2100, we keep only the years corresponding to the run starting date and horizon
supply__biodies=supply__biodies(base_year_simulation-2000:TimeHorizon+base_year_simulation-2001,:);

p_Et_lge_ethan=csvRead(path_Et+"p_Et_lge_ethan.csv",'|',[],[],[],'/\/\//');
supply__ethan_2010=csvRead(path_Et+"supply__ethan_2010.csv",'|',[],[],[],'/\/\//');
supply__ethan_2030=csvRead(path_Et+"supply__ethan_2030.csv",'|',[],[],[],'/\/\//');
supply__ethan_2050=csvRead(path_Et+"supply__ethan_2050.csv",'|',[],[],[],'/\/\//');

///linear interpolation between the dots given for each of the three supply curves (price,Quantity) for 2010, 2030 and 2050
supply__ethan_2010_temp=supply__ethan_2010;
supply__ethan_2030_temp=supply__ethan_2030;
supply__ethan_2050_temp=supply__ethan_2050;
for k=1:50
    supply__ethan_2010(k)=interpln([[1,8, 9,10,50];[supply__ethan_2010_temp(1),supply__ethan_2010_temp(8),supply__ethan_2010_temp( 9),supply__ethan_2010_temp(10),supply__ethan_2010_temp(50)]],k);
    supply__ethan_2030(k)=interpln([[1,4,11,33,50];[supply__ethan_2030_temp(1),supply__ethan_2030_temp(4),supply__ethan_2030_temp(11),supply__ethan_2030_temp(33),supply__ethan_2030_temp(50)]],k);
    supply__ethan_2050(k)=interpln([[1,2,10,38,50];[supply__ethan_2050_temp(1),supply__ethan_2050_temp(2),supply__ethan_2050_temp(10),supply__ethan_2050_temp(38),supply__ethan_2050_temp(50)]],k);
end

size_p_Et_ethan=size(p_Et_lge_ethan);
supply__ethan=zeros(99,size_p_Et_ethan(2));
supply__ethan(9,:)=supply__ethan_2010;
supply__ethan(29,:)=supply__ethan_2030;
supply__ethan(49,:)=supply__ethan_2050;

//Interpolation over time of the supply curve at each date, between the three given for 2010, 2030 and 2050
//Assuming that after 2050 the supply curve does not evolve anymore
for j=10:28
    for k=1:size_p_Et_ethan(2)
        supply__ethan(j,k)=interpln([[9,29];[supply__ethan(9,k),supply__ethan(29,k)]],j);
    end
end
for j=30:48
    for k=1:size_p_Et_ethan(2)
        supply__ethan(j,k)=interpln([[30,48];[supply__ethan(29,k),supply__ethan(49,k)]],j);
    end
end
for j=50:99
    for k=1:size_p_Et_ethan(2)
        supply__ethan(j,k)=supply__ethan(49,k);
    end
end

//supply curves are calibrated for 2001-2100, we keep only the years corresponding to the run starting date and horizon
supply__ethan=supply__ethan(base_year_simulation-2000:TimeHorizon+base_year_simulation-2001,:);

// In order to derive the primary biomass energy in outputs,
// We assume the conversion efficiency of Hoogwick et al. 2009: 0.4 in 2001; 0.55 in 2050
// from doi:10.1016/j.biombioe.2008.04.005
coef_temp_20012050 = linspace(0.4,0.55,50);
hoogwick_bioEt_efficienc = zeros(TimeHorizon,1);
hoogwick_bioEt_efficienc(1:36)=coef_temp_20012050(1,15:50)';
hoogwick_bioEt_efficienc(37:$) = hoogwick_bioEt_efficienc(36);

// initilizing the prices on the supply curves
p_ethan_mtep=0; 
p_biodies_mtep=0;

//////////////////////////////////////////////////////
//////Synfuel technology parameters (coal-to-liquids)
//////////////////////////////////////////////////////

Cost_struc_CTL=zeros(nb_regions,nb_sectors+2);
for k=1:nb_regions
    Cost_struc_CTL(k,indice_coal)=  1 ./ yield_CTL;
end

p_CTL_mtep=1;
share_CTL_world=0;
Q_CTL_anticip_world=0;
Q_CTL_anticip=zeros(nb_regions,1);
Q_CTL_store=zeros(nb_regions,1);
Q_Et_anticip=Qref(:,indice_Et);
Q_Et_anticip_world=sum(Qref(:,indice_Et));
Q_oil_refin=Qref(:,indice_Et);


//computing CTL production cost, depending on coal price
//from http://www.iea-etsap.org/web/E-TechDS/PDF/S02-CTL&GTL-GS-gct.pdf ETSAP Energy system analysis programme - Technology brief S02 May 2010 - Liquid fuels production from coal and gas
// We know that variable costs (coal excluded) of Coal-to-Liquids are more or less equal to the cost of coal, and that capital costs are around 10 times higher for a 30 year lifetime (in term of annual levelized capital cost, this gives capital cost being 0.8 times the cost of coal)

cost_CTL_coal_w=wpref(coal)*(1/yield_CTL);
cost_CTL_OMref=ratio_OM_coal_CTL*cost_CTL_coal_w;
cost_CTL_capitalref=ratio_capital_coal_CTL*cost_CTL_coal_w;
cost_CTL_coal=zeros(nb_regions,1);
for k=1:nb_regions,
    cost_CTL_coal(k)=pArmCIref(coal,et,k);
end;

price_CTL=(cost_CTL_coal+cost_CTL_OMref+cost_CTL_capitalref).*(1+margin_CTL);

//variables added in save_generic
sg_add(["Q_CTL_anticip", "p_CTL_mtep"]);
sg_add(["price_CTL"]);

