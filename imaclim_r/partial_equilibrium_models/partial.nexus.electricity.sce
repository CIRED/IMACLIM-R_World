// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thibault Briera
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

combi=1;
exec("../model/preamble.sce");
// source of data, once study parameters are set
auto_calibration_txCap = "None"
ssp_fossil=2;
exec(MODEL + 'sources.sce');
exec(STUDY+ETUDE+".sce");
SAVEDIR='';
baseyear = 2015;


    
run_partial_eq_elec = %t; //TB: add-hoc to set in USD2014 LCOE of fossil fuels when we run the nexus from 2014
// When costs are all in USD2014, this will become redundant

TimeHorizonPartialEq = 80-(baseyear-2001)-20; //since year 1 is 2001/2014  

if  run_calib_weights == %t
    TimeHorizonPartialEq = 1;
end


//TB: For now, the model starts in 2014 and ends in 2113, but years after 2080 will be useless since exogenous price trajectories stop in 2080.
//So also stops the run in 2080 anyway

//////////////REDUNDANT WITH CALIBRATION.NEXUS.ELECTRICITY.SCE//////////////////
// CPI - SOurce https://www.inflationtool.com/us-dollar, starts in 2014
CPI_2010_to_2014 = 869.59/805.78; //PING_FL
calib_price_2014 = usd2001_2010*CPI_2010_to_2014;



run_name_csv = 'IPCC_AR6_outputs_ADVANCE_Reference_WP6.csv'; //be careful: this is not necessarely coherent with combi

data_run_temp = csvRead( path_old_run_Imaclim_v11 + run_name_csv, ';');
year_run = data_run_temp(1,6:$);
data_num = data_run_temp(2:$,6:$);
limit_year = max(year_run);
//IMACLIM 1.1;peak2020_DemandLow_FossilLow_TechHigh;USA;Price|Primary Energy|Oil;US$2010/GJ;7.652;10.63;12.35;12.83;12.2;11.27;9.294;6.118;3.753;2.471
ind_toadd_region = [0];
for i=1:(nb_regions-1)
    ind_toadd_region = [ind_toadd_region ind_toadd_region($)+351];
end

ind_line = 223;
vect_run = data_num( ind_line+ind_toadd_region ,:);
vect_run_full = [];
for i=1:size(vect_run,"r")
    vect_run_full = [vect_run_full; interpln([year_run;vect_run(i,:)], linspace(baseyear,limit_year,limit_year-baseyear+1)) ];
end
for j = (limit_year-baseyear+1):TimeHorizon+1//TB: added this because IMACLIM run data stop in 2050 but interpln continues to 2100.
    for i=1:reg
        hist_rate = ((vect_run_full(i,limit_year-baseyear)/vect_run_full(i,limit_year-baseyear-30))^(1/30) - 1);
        vect_run_full(i,j) = vect_run_full(i,j-1)*(1+hist_rate);
    end
end
if baseyear == 2001 //Depending on the base year, USD2001 or USD2014
    Q_elec_run = vect_run_full / mtoe2ej; 
elseif baseyear == 2015
    Q_elec_run = vect_run_full / mtoe2ej; 
end


ind_line = 339;
vect_run = data_num( ind_line+ind_toadd_region ,:);
vect_run_full = [];
for i=1:size(vect_run,"r")
    vect_run_full = [vect_run_full; interpln([year_run;vect_run(i,:)], linspace(baseyear,limit_year,limit_year-baseyear+1)) ];
end
for j = (limit_year-baseyear+1):TimeHorizon+1//TB: added this because IMACLIM run data stop in 2050 but interpln continues to 2100.
    for i=1:reg
        //for carbox tax and FF, we assume it does not decrease after 2050
        vect_run_full(i,j) = vect_run_full(i,(limit_year-baseyear+1)) ;
    end
end
if baseyear == 2001 
    p_biomass_run = vect_run_full / gj2tep/ usd2001_2010; //PING_FL
elseif baseyear == 2015
    p_biomass_run = vect_run_full / gj2tep *CPI_2010_to_2014;  //PING_FL
end


ind_line = 340;
vect_run = data_num( ind_line+ind_toadd_region ,:);
vect_run_full = [];
for i=1:size(vect_run,"r")
    vect_run_full = [vect_run_full; interpln([year_run;vect_run(i,:)], linspace(baseyear,limit_year,limit_year-baseyear+1)) ];
end
for j = (limit_year-baseyear+1):TimeHorizon+1//TB: added this because IMACLIM run data stop in 2050 but interpln continues to 2100.
    for i=1:reg
        //for carbox tax and FF, we assume it does not decrease after 2050
        vect_run_full(i,j) = vect_run_full(i,(limit_year-baseyear+1)) ;
    end
end
if baseyear == 2001 
    p_coal_run = vect_run_full / gj2tep/ usd2001_2010; //PING_FL
elseif baseyear == 2015
    p_coal_run = vect_run_full / gj2tep *CPI_2010_to_2014; //PING_FL
end

ind_line = 341;
vect_run = data_num( ind_line+ind_toadd_region ,:);
vect_run_full = [];
for i=1:size(vect_run,"r")
    vect_run_full = [vect_run_full; interpln([year_run;vect_run(i,:)], linspace(baseyear,limit_year,limit_year-baseyear+1)) ];
end
for j = (limit_year-baseyear+1):TimeHorizon+1//TB: added this because IMACLIM run data stop in 2050 but interpln continues to 2100.
    for i=1:reg
        //for carbox tax and FF, we assume it does not decrease after 2050
        vect_run_full(i,j) = vect_run_full(i,(limit_year-baseyear+1)) ;
    end
end
if baseyear == 2001 
    p_gas_run = vect_run_full / gj2tep/ usd2001_2010; 
elseif baseyear == 2015
    p_gas_run = vect_run_full / gj2tep *CPI_2010_to_2014; 
end

ind_line = 342;
vect_run = data_num( ind_line+ind_toadd_region ,:);
vect_run_full = [];
for i=1:size(vect_run,"r")
    vect_run_full = [vect_run_full; interpln([year_run;vect_run(i,:)], linspace(baseyear,limit_year,limit_year-baseyear+1)) ];
end
for j = (limit_year-baseyear+1):TimeHorizon+1//TB: added this because IMACLIM run data stop in 2050 but interpln continues to 2100.
    for i=1:reg
        //for carbox tax and FF, we assume it does not decrease after 2050
        vect_run_full(i,j) = vect_run_full(i,(limit_year-baseyear+1)) ;
    end
end
if baseyear == 2001 
    p_oil_run = vect_run_full / gj2tep / usd2001_2010;  //PING_FL
elseif baseyear == 2015
    p_oil_run = vect_run_full / gj2tep *CPI_2010_to_2014;  //PING_FL
    
end


ind_line = 344;
vect_run = data_num( ind_line+ind_toadd_region ,:);
vect_run_full = [];
for i=1:size(vect_run,"r")
    vect_run_full = [vect_run_full; interpln([year_run;vect_run(i,:)], linspace(baseyear,limit_year,limit_year-baseyear+1)) ];
end
for j = (limit_year-baseyear+1):TimeHorizon+1//TB: added this because IMACLIM run data stop in 2050 but interpln continues to 2100.
    for i=1:reg
        //for carbox tax and FF, we assume it does not decrease after 2050
        vect_run_full(i,j) = vect_run_full(i,(limit_year-baseyear+1)) ;
    end
end
if baseyear == 2002 
    p_Et_run = vect_run_full / gj2tep / usd2001_2010; 
elseif baseyear == 2015
    p_Et_run = vect_run_full / gj2tep *CPI_2010_to_2014; 
    
end


ind_line = 338;
vect_run = data_num( ind_line+ind_toadd_region ,:);
vect_run_full = [];
for i=1:size(vect_run,"r")
    vect_run_full = [vect_run_full; interpln([year_run;vect_run(i,:)], linspace(baseyear,limit_year,limit_year-baseyear+1)) ];
end
for j = (limit_year-baseyear+1):TimeHorizon+1//TB: added this because IMACLIM run data stop in 2050 but interpln continues to 2100.
    for i=1:reg
        //for carbox tax, we assume it does not decrease after 2050
        vect_run_full(i,j) = vect_run_full(i,(limit_year-baseyear+1)) ;
    end
end

//USD2010/t C02
if baseyear == 2001 
    p_carbon_run = max(vect_run_full,0) / usd2001_2010; //PING_FL
elseif baseyear == 2015
    p_carbon_run = max(vect_run_full,0) *CPI_2010_to_2014; //PING_FL
    
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// initialisation of inputs for calibration
pArmCIref = ones(nb_sectors, nb_sectors, nb_regions);
pArmCIref(indice_Et,indice_elec,:) = p_Et_run(:,1)';
pArmCIref(indice_coal,indice_elec,:) = p_coal_run(:,1)';
pArmCIref(indice_gas,indice_elec,:) = p_gas_run(:,1)';

Qref = ones(nb_regions, nb_sectors);
Qref(:,indice_elec) = Q_elec_run(:,1); 

// Copy paste from base year
CI = ones(nb_sectors, nb_sectors, nb_regions);
if  baseyear == 2002
    CI(indice_gas,indice_elec,:) =  [0.4171839, 0.1544484, 0.3478323, 0.4332054, 1.6360584, 0.0120240, 0.1976473, 0.0761202, 1.3640691, 0.7051759, 0.8160100, 0.6049082];
    CI(indice_coal,indice_elec,:) = [1.4625516, 0.5070523, 0.8695808, 0.8923957, 0.8556397, 2.5430234, 2.7106604, 0.1283777, 0.1705086, 1.437474, 0.8607090, 0.1451327];
    CI(indice_Et,indice_elec,:) = [0.0872931, 0.0755064, 0.1438153, 0.1794771, 0.1598448, 0.0989114, 0.1432742, 0.1587096, 0.7794680, 0.2983437, 0.4176323, 0.7345948];
elseif baseyear == 2015
    CI(indice_gas,indice_elec,:) = [0.60927254, 0.42321913, 0.26938816, 0.79807711, 1.65894085, 0.049913, 0.13674186, 0.38373766, 1.43648618, 1.00276188, 1.04627473, 0.89358858]  ;
    CI(indice_coal,indice_elec,:) = [1.21786153, 0.32545178, 0.79736349, 1.18734501, 0.74067911, 2.17330395,3.19366854, 0.11206405, 0.26777333, 1.33100083, 1.01632378, 0.27781378];
    CI(indice_Et,indice_elec,:) = [0.02162554, 0.01616363, 0.04265215, 0.10421275, 0.02320932, 0.00168731,0.01496963, 0.16940109, 0.66739427, 0.3724589,  0.2632027,  0.42446871];
end
CIref = CI;
CI_prev = CI;
ldsav('Cum_Inv_MW_elec_ref_temp','calib'); //TB: do not find the source ofd Cum_Inv_MW_elec_ref_temp. for certian technologies, replace Cum_Inv_MW_elec_ref if greater (l.1202 calib)
// has an effet is indice_calib_CINV_elec = 0

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// calibration
exec(MODEL+'calibration.growthdrivers.sce');
exec(MODEL+"calibration.static.sce");
exec(MODEL+"calibration.emissions.sce");
exec(MODEL+"calibration.crosssectoral.parameters.sce");
exec(MODEL+'calibration.nexus.electricity.sce');
exec(MODEL+'calibration.nexus.wacc.sce');

Cap_elec_MW=Cap_elec_MWref;
pCap_MW_elecref=csvRead(path_capital_elec+'pCap_MW_elecref.csv','|',[],[],[],'/\/\//');
cumCapElec_GW = zeros( Cap_elec_MW );

// initialisation of inputs for nexus
//Q(k,indice_elec)/0.8-Cap(k,indice_elec)
expected.pArmCI = 1;
expected.pArmCI_noCTax = 1;
expected.pArmCI = ones(nb_sectors, nb_sectors, nb_regions, Life_time_max);
expected.pArmCI_noCTax = ones(nb_sectors, nb_sectors, nb_regions, Life_time_max);
pArmCI_no_taxCO2 = ones(nb_sectors, nb_sectors, nb_regions);
pArmCI = ones(nb_sectors, nb_sectors, nb_regions);

taux_Q_nexus = ones(nb_regions, nb_sectors);
croyance_taxe  = zeros(reg,1);

taxCO2_CI_ant = ones(nb_sectors, nb_sectors, nb_regions);

Imp = zeros(nb_regions, nb_sectors); // serve for ENR penetration; zero means no constraint
charge = 0.8 * ones(nb_regions, nb_sectors);

Inv_val_sec = 10^8*ones(reg,nb_sectors);

Beta = ones(nb_sectors, nb_sectors, nb_regions); // Beta not needed in partial equilibrium
Betaref = Beta;

emi_evitee = 0;

// add-hoc init: lead to a wrong calculation of the markup
markup = ones(nb_regions, nb_sectors);
markup_prev = markup;
p = ones(nb_regions, nb_sectors); 
pref=p;
wpEner = wpEnerref;
num=ones(nb_regions, nb_sectors);
partImpCI = partImpCIref;
wp=wpref;
FCC=ones(nb_regions, nb_sectors);
A=ones(nb_regions, nb_sectors);
w=wref;
ind_first_run_elec=1;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// temporal loop on nexus in partial equilibrium
//TB: Care with FF prices, they are not Armington prices but production prices. After a check it seems that the gap is not that significant
// According to Sassi (2006), for energetic goods, perfect subsituability is assumed between domestic and imported goods. The price for imported energetic good = world price + taxes or subisdies + transport costs
// In general equilibrium, the regional share of exporters for energetic goods must be scrutinized.
//Carbon tax
taxCO2_CI_hist = zeros(sec,sec,reg,TimeHorizon+Life_time_max);

for i=1:TimeHorizon +1
    taxCO2_CI_hist(gaz,elec,:,i) = p_carbon_run(:,i);
    taxCO2_CI_hist(coal,elec,:,i)= p_carbon_run(:,i);
    taxCO2_CI_hist(et,elec,:,i)= p_carbon_run(:,i);
end
for i=TimeHorizon+2:TimeHorizon+Life_time_max //TB: dans les projections de taxe après 2100 on garde le niveau de taxe constant. Nécessaire pour les calculs des expected.pArmCI
    taxCO2_CI_hist(gaz,elec,:,i) = p_carbon_run(:,TimeHorizon);
    taxCO2_CI_hist(coal,elec,:,i)= p_carbon_run(:,TimeHorizon);
    taxCO2_CI_hist(et,elec,:,i)= p_carbon_run(:,TimeHorizon);
end



croyanceTaxMat = ones(sec,sec,reg); //TB: Added for carbon tax computation
for current_time_im = 1:TimeHorizonPartialEq	
    disp("Doing year "+string(baseyear+current_time_im-1));
    // initialisation of inputs for nexus
    Q(:,indice_elec) = Q_elec_run(:,current_time_im); //TB:to check, but this make more sense to me this way
    taux_Q_nexus(:,indice_elec) = (Q_elec_run(:,1+current_time_im)./ Q(:,indice_elec)); 
    
    for ii=1:Life_time_max
        //TB:with carbon tax for coal and gas. We consider that expected price as a mixed expectation: current price (myopic expectations) + forward looking expectations for carbon tax = carbon tax signal is provided, so the tax can be forecast 
        expected.pArmCI(gaz ,elec,:,ii) = p_gas_run(:,1+current_time_im)+ squeeze(croyanceTaxMat(gaz,elec,:).*taxCO2_CI_hist(gaz,elec,:,1+current_time_im+ii).*coef_Q_CO2_CI(gaz,elec,:)/mega2unity); 
        expected.pArmCI(coal ,elec,:,ii) = p_coal_run(:,1+current_time_im)+ squeeze(croyanceTaxMat(coal,elec,:).*taxCO2_CI_hist(coal,elec,:,1+current_time_im+ii).*coef_Q_CO2_CI(coal,elec,:)/mega2unity);
        expected.pArmCI(indice_Et ,elec,:,ii) = p_Et_run(:,1+current_time_im);
        //TB:Taxe en USD2001(2014)/tCO2, intensité des émissions en tCO2/Mteo donc divise par 1e6 pour avoir une taxe en USD/teo
    end
    for ii=1:Life_time_max
        expected.pArmCI_noCTax(gaz ,elec,:,ii) = p_gas_run(:,1+current_time_im); 
        expected.pArmCI_noCTax(coal ,elec,:,ii) = p_coal_run(:,1+current_time_im);
        expected.pArmCI_noCtax(indice_Et ,elec,:,ii) = p_Et_run(:,1+current_time_im)-squeeze(croyanceTaxMat(et,elec,:).*taxCO2_CI_hist(et,elec,:,1+current_time_im+ii).*coef_Q_CO2_CI(et,elec,:)/mega2unity);//removed tax on Et which is included in pArmCI. In general equilibrium the value of coef_Q_CO2_CI depends on the share of bioethanol in the mixn which may increase with the carbon tax => might explain why we get negative values of expected.pArmCI_noCtax for Et in partial equilibrium since coef_Q_CO2_CI is not updated
    end
    // actual nexus
    exec(MODEL+"nexus.wacc.sce"); 
    exec(MODEL+"nexus.electricity.idealPark.sce"); // Finds ideal electric park

    // fake investment allocation
    partInvFin = ones( nb_regions, nb_sectors); // no meaning
    NRB = sum(Inv_MW.*CINV_MW_nexus(:,:)/10^3,"c"); // no meaning

    pArmCI_no_taxCO2(indice_Et,indice_elec,:) = p_Et_run(:,1+current_time_im)-squeeze(croyanceTaxMat(et,elec,:).*taxCO2_CI_hist(et,elec,:,1+current_time_im).*coef_Q_CO2_CI(et,elec,:)/mega2unity);
    pArmCI_no_taxCO2(indice_gas,indice_elec,:) = p_gas_run(:,1+current_time_im);
    pArmCI_no_taxCO2(indice_coal,indice_elec,:) = p_coal_run(:,1+current_time_im);
    pArmCI = pArmCI_no_taxCO2; // chance this to account for the value of the taxe
    // second aprt of nexus
    exec(MODEL+"nexus.electricity.realInvestment.sce");

end

