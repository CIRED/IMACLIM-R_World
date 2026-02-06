// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// put and execute this file from a run output folder

load('save/GDP_PPP_constant_sav.dat')
load('save/L_sav.dat')
load('save/l_sav.dat')
load('save/charge_sav.dat')
load('save/VA_sav.dat')
load('save/Q_sav.dat')
load('save/GDP_sav.dat')
load('save/TC_l_sav.dat')

nb_year=87;
global_charge = sum(charge_sav.*VA_sav,'r') ./ sum(VA_sav,'r');

tx_Ltot = (L_sav(:,2:$)-L_sav(:,1:$-1)) ./ L_sav(:,1:$-1);
tx_Ltot = [tx_Ltot(:,1) tx_Ltot];

natural_growth_reg =  tx_Ltot + TC_l_sav;
natural_growth = sum(natural_growth_reg.*GDP_sav,'r') ./ sum(GDP_sav,'r') ;

gdp_global = sum(GDP_PPP_constant_sav,'r');

chomage = 1- sum(l_sav.*Q_sav,'r') ./ sum(L_sav,'r');

output = [gdp_global;natural_growth;global_charge;chomage];

csvWrite( output, 'output_txcaptemp_analysis.csv')

