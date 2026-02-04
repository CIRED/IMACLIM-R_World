// X * X2Y  = Y
exa2giga        =                 1e9; // G / E
tep2gj          =              41.855; // GJ/tep
mtoe2gj         =        1e6 * tep2gj; // GJ/Mtep
mtoe2ej         =  mtoe2gj / exa2giga; // EJ/Mtep
gj2tep          =            1/41.855; // tep/GJ
Mtep2ZJ         =       4.1868 * 1e-5; // Mtep/ZJ
tep2mbtu        =               39.68; // mbtu/tep
kwh2btu         =               3412;  // Btu per kWh
tep2kwh         =               11628; // kWh/tep
mtoe2mwh        =               11630000; //MWh/mtoe
// a different unit used in nexus.buildings. Kept temporarly for results reproductibility
// Units in Imaclim will need to be harmonized later
tep2kwh_buildings         =               11630; // kWh/tep
kwh2gj          =   tep2gj / tep2kwh ; // gj/kWh
tep2m3gas       =                1000; // m3gas/tep
tep2oilbarrels  =                7.33; // bep / tep
tep2uraniumGram =                 1.4; // gramme uranium / tep
Mtep2MWh        =       tep2kwh * 1e3; // MWh / Mtep
tep2MWh         =       tep2kwh / 1e3; // MWh / tep
dollar2MDollar  =                1e-6; // million dollar / dollar
usd2001to2005   =             1/0.907; // USD2005 / USD2001 (Conversion from 2001 USD into 2005 USD)
Mkcal2Exajoule  =          4.1868/1e9;
kgH2ToToe       =     33.33 / tep2kwh; // toe/kg  // todo: needs to be double-checked
kgH2ToMtoe      =    kgH2ToToe * 1e-6; // mtoe/kgH2
lge2Mtoe	=      8.00095533E-10; // mtoe/lge (liter gasoline equivalent)
Usd2001ToEur1999=               0.961; // euro1999/dollar2001
//conversion factors for outputs
usd2001_2005=1/0.907;
usd2001_2010= 92.0 / 74.7; // source https://data.oecd.org/price/inflation-cpi.htm 25-10-2019
Mtoe_EJ=0.041868;
usd2005to2010 	= 1/0.90; // USD2010 / USD2005 (Conversion from 2005 USD into 2010 USD)

// powers of 10
mega2unity	= 		  1e6; // M / unity
giga2unity = 1e9;
giga2mega = giga2unity ./ mega2unity;

// conversion in C02 emissions
factor_MJ_C=zeros(1,3);
factor_MJ_C(indice_coal)=1e-3*0.0258;
factor_MJ_C(indice_oil)=1e-3*0.02;
factor_MJ_C(indice_gaz)=1e-3*0.0153;

factor_C_CO2=44/12;
factor_CO2_C=12/44;

//PING_FL : tout doit disparaitre ici 
// le //PING_FL est encadré d'###### quand il y a du CPI sur un bloc
////////////// REQUIRED TO COMPUTE - TO FIX IF A COMMON METHOD IS CHOSED////////
// CPI - SOurce https://www.inflationtool.com/us-dollar, starts in 2001, then 2007 and 2010+
CPI = [633.48,649.25,659.33,675,687.69, 710.07, 734.33, 752.98, 783.72,784.43,805.78,817.83,842.06,856.72,869.59,876.16,882.56,900.87,919.87,937.44,952.09/940.49*937.44];

CPI_2020_to_2014 = CPI(15)/CPI(21);
CPI_2019_to_2014 = CPI(15)/CPI(20);
CPI_2018_to_2014 = CPI(15)/CPI(19);
CPI_2015_to_2014 = CPI(15)/CPI(16);
CPI_2010_to_2014 = CPI(15)/CPI(11);
CPI_2000_to_2014 = CPI(15)/CPI(1);
CPI_2001_to_2014 = CPI(15)/CPI(2);
CPI_2007_to_2014 = CPI(15)/CPI(8);
//Exchange rate - Source IEA (2020) "Power generation assumptions in the Stated Policies and SDS Scenarios in the World Energy Outlook 2020""
EUR_to_USD = 1/0.89;

