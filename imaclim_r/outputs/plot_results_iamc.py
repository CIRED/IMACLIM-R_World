# -*- coding: utf-8 -*-

import copy
import os

# this files enables to plots results from Imaclim runs
# be carefull, at this time, this is working only in the case that combi are smartly ordered and named... and existing just once in the result folder (and here with the corresponding climate scenario names combi+'100')
# default : this is working for 4 scenarios (plus climate variants) (see defaults settings for style_line, colours, etc)
# default : this is working for runs with 100 time steps (see defaults settings)

#########################################################################################################
# Main code #
#########################################################################################################


first_time = 2010
first_time = 2001
time_horizon = 2100
time_lenght = time_horizon - first_time + 1

tptScale = list()
for timy in range(time_horizon - first_time +1):
	tptScale.append(timy + first_time - int(dimYEAR[0]))

combi_baseline_str = ['991', '992', '993']
combi_climat_str = ['3991', '3992']
#combi_climat_str = ['3991', '3992']
combi_baseline_str = ['991', '992']
#combi_climat_str = ['3991', '3992','3994','3995']
combi_baseline_str = ['991', '992','994','995']
#combi_baseline_str = ['991', '992','993','994','995','996']
clim2exclude = ['3991', '3992', '3993', '3994', '3995', '3996','2991', '2992', '2993', '4991', '4992', '4993']
sc2exclude = ['3993','13991','13992','13993']

style_line_bas = list()
style_line_clim = list()
style_line_all = list()
for elt in combi_baseline_str:
    style_line_bas.append('-')
    style_line_all.append('-')
for elt in combi_climat_str:    
    style_line_clim.append('-')
    style_line_all.append('--')

colours_many = [ [00.0,00.0,00.0], [100.0,149.0,237.0], [46.0,139.0,87.0], [255.0,215.0,00.0], [178.0,34.0,34.0], [190.0,190.0,190.0], [255.0,165.0,00.0], [199.0,21.0,133.0], [34.0,139.0,34.0], [00.0,00.0,255.0], [139.0,69.0,19.0], [138.0,43.0,226.0] ]

plot_nb_line=2

colour_bas = list()
colour_clim = list()
colour_all = list()
for ii in range(len(combi_baseline_str)):
    colour_bas.append( colours_many[ii+1])
    colour_all.append( colours_many[ii+1])
for ii in range(len(combi_climat_str)):
    colour_clim.append( colours_many[ii+1])
    colour_all.append( colours_many[ii+1+len(combi_baseline_str)])

#colours = [  [21.0,95.0,167.0], [194.0,207.0,0.0], [21.0,95.0,167.0], [194.0,207.0,0.0]]
# default globis combi legend (first use for this code


combi_climat = list()
combi_baseline = list()
combi_all = list()
combi_all_str = list()
for elt in combi_baseline_str:
        combi_all_str.append(elt)
	combi_baseline.append(dimCOMBI.index(elt))
	combi_all.append(dimCOMBI.index(elt))
for elt in combi_climat_str:
        combi_all_str.append(elt)
	combi_all.append(dimCOMBI.index(elt))
	combi_climat.append(dimCOMBI.index(elt))

combi_Legend = copy.deepcopy(combi_baseline_str)
combi_Legend_clim = copy.deepcopy(combi_climat_str)
combi_Legend_all = copy.deepcopy(combi_all_str)

combi_all_str = ['991','994','3991','992','995','3992']
combi_all = list()
for elt in combi_all_str:
    combi_all.append( dimCOMBI.index(elt))
combi_Legend_all = ['Medium food - base', 'Medium food - less cars', 'Medium food - clim', 'Low food - base', 'Low food - less cars', 'Low food - clim']
colour_all = [ [100.0,149.0,237.0], [46.0,139.0,87.0], [178.0,34.0,34.0], [100.0,149.0,237.0], [46.0,139.0,87.0], [178.0,34.0,34.0] ] 
style_line_all = [ '-', '-', '-', '--', '--', '--']

if not ('combi_benchmark' in globals()):
	combi_benchmark = combi_baseline[0]
if not ('combi_benchmark_climat' in globals()):
	combi_benchmark_climat = combi_climat[0]

###############################
###############################
# outputs paths
###############################
###############################
if not ('outputDirs' in globals()):
	outputDirs = './'
outdir= outputDirs + 'plots_iamc/'
# create output dir if not existing
try:
	   os.stat(outdir)
except:
	   os.mkdir(outdir)

###############################
###############################
# outputs paths
###############################
###############################
tep2oilbarrels  = 7.33 # bep / tep
year2day = 365.25
Million = 1e6



################################################
################################################
# get nlu datas
################################################
################################################

nlu_sub_dir='/NLU/Runs/Other_simulations/'
list_var_nlu=['T_world_calorie_price,$/Mkcal','C_total_emissions,tCO2eq/yr','P_Mean_Tot_yield,Mkcal/ha','E_NPKcons_perHa_Volume,kgNPK/ha/yr','P_world_yield_gap,%','P_share_extensive_in_total_rumiprod,%','E_biomass_price_delivered, $/GJ','E_scarcity_rent,$/yr','E_world_profit,$/yr','A_world_surfcrop_Dyn_nonDyn,Mha','P_world_prod_Dyn,Pkcal']

Mkcal2Exajoule=4.1868/1e9
Mkcal2Pkcal=1E-9
PkcalExajoule = 4.1868

list_nlu_dir_baseline = list()
list_nlu_dir_climat = list()
list_nlu_dir_all = list()
list_dir_tpt=os.listdir('.')

for varname in list_var_nlu:
    varname_real = varname.split(',')[0]
    str2exec = varname_real + '= np.ones( [ len(combi_all), len(dimYEAR)])'
    exec( str2exec)

# climate first
for elt in combi_climat_str:
    for diry in list_dir_tpt:
        if (elt in diry) and (not 'pdfSummary' in diry) and (not 'smoothOutputs' in diry) and ( not diry.split('_')[0] in sc2exclude):
            sub_dir_tpt = diry + nlu_sub_dir
            for suby in os.listdir( sub_dir_tpt):
                if '2016' in suby:
                    list_nlu_dir_climat.append( sub_dir_tpt + suby)
                    list_nlu_dir_all.append( sub_dir_tpt + suby)
# then baseline
for elt in combi_baseline_str:
    for diry in list_dir_tpt:
        if ((elt in diry) and (not 'pdfSummary' in diry) and (not 'smoothOutputs' in diry) and ( not diry.split('_')[0] in clim2exclude) and ( not diry.split('_')[0] in sc2exclude)):
            sub_dir_tpt = diry + nlu_sub_dir
            for suby in os.listdir( sub_dir_tpt):
                if '2016' in suby:
                    list_nlu_dir_baseline.append( sub_dir_tpt + suby)
                    list_nlu_dir_all.append( sub_dir_tpt + suby)


for diry in list_nlu_dir_all:
    scn_name = diry.split('_')[0]
    if scn_name in combi_all_str:
        scn_ind = combi_all_str.index( scn_name)
        data_path = diry + '/simulation_global_results.csv'
        data_nlu_temp = np.genfromtxt( data_path, str,delimiter=';')
        for varname in list_var_nlu:
            varname_real = varname.split(',')[0]
            ind_var =  np.where( data_nlu_temp[:, 0] == varname )
            data_tpt= data_nlu_temp[ ind_var[0]+1,:]
            len_tpt= data_tpt.shape[1]
            str2exec = varname_real + '[ scn_ind, 0:len_tpt] = np.array(data_tpt[0], dtype=float)'   
            exec( str2exec)

##########################
# plot - nlu
##########################
data_2plot=prepareArray2plot( T_world_calorie_price[:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"T_world_calorie_price" , combi_Legend_all,"World food price ($/Mkcal)",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

data_2plot=prepareArray2plot( P_Mean_Tot_yield[:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"P_Mean_Tot_yield" , combi_Legend_all,"Intensification (Mkcal/ha)",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

data_2plot=prepareArray2plot( C_total_emissions[:,tptScale] / 1e9,timeset[tptScale])
linePlot(data_2plot,outdir+"C_total_emissions" , combi_Legend_all,"C emissions (GtCO2eq/yr)",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)
data_2plot=prepareArray2plot( E_NPKcons_perHa_Volume[:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"E_NPKcons_perHa_Volume" , combi_Legend_all,"Fertilization (kgNPK/ha/yr)",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)


data_2plot=prepareArray2plot( P_world_yield_gap[:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"P_world_yield_gap" , combi_Legend_all,"World yield gap (potential - Effective) %",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

data_2plot=prepareArray2plot( P_share_extensive_in_total_rumiprod[:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"P_share_extensive_in_total_rumiprod" , combi_Legend_all,"P_share_extensive_in_total_rumiprod,%",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

data_2plot=prepareArray2plot( E_biomass_price_delivered[:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"E_biomass_price_delivered" , combi_Legend_all,"E_biomass_price_delivered, $/GJ",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

data_2plot=prepareArray2plot( E_scarcity_rent[:,tptScale] / 1e6,timeset[tptScale])
linePlot(data_2plot,outdir+"E_scarcity_rent" , combi_Legend_all," Land Scarcity Rent (M$)",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

data_2plot=prepareArray2plot( E_world_profit[:,tptScale] / 1e6,timeset[tptScale])
linePlot(data_2plot,outdir+"E_world_profit" , combi_Legend_all," Land Rent (M$)",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

data_2plot=prepareArray2plot( A_world_surfcrop_Dyn_nonDyn[:,tptScale] / 1e6,timeset[tptScale])
linePlot(data_2plot,outdir+"A_world_surfcrop_Dyn_nonDyn" , combi_Legend_all," Surface (Mha)",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

data_2plot=prepareArray2plot( P_world_prod_Dyn[:,tptScale] *PkcalExajoule,timeset[tptScale])
linePlot(data_2plot,outdir+"P_world_prod_Dyn" , combi_Legend_all,"Total food demand (EJ)",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)


##########################
# plot - Im
##########################
Q_biofuel_anticip_reg = Q_biofuel_anticip.sum(axis=1)
# added value and sectoral GDP
markupref = np.repeat(markup[:,:,:,0], time_lenght, axis=2).reshape([len(dimCOMBI),len(dimREG),len(dimSEC),time_lenght])
FCCmarkup = ( (markup_lim_oil - markupref) / (1-0.8) * (Q/Cap - 0.8) + markupref ) / markup
FCCmarkup_oil = np.ones(FCCmarkup.shape)
FCCmarkup_oil[:,:,dimSEC.index('oil'),:] = FCCmarkup[:,:,dimSEC.index('oil'),:]
EBE = p * Q * markup * FCCmarkup_oil
oil_rent = EBE[:,:,dimSEC.index('oil'),:].sum(axis=1)
emission_reg_CO2 = (E_reg_use.sum(axis=2) + emi_evitee)/1e9
emission_CO2 = emission_reg_CO2.sum( axis=1)
GDP_PPP_real_w = GDP_PPP_real.sum(axis=1)
if len( pkmautomobileref.shape) < 3:
    pkmautomobileref = np.repeat(pkmautomobileref,time_lenght,axis=1)
    pkmautomobileref = pkmautomobileref.reshape([len(dimCOMBI),len(dimREG),time_lenght]) #check that
pkmautomobile = Tautomobile * pkmautomobileref / 100
pkmautomobile = pkmautomobile.sum(axis=1)

Q_dimCI = np.repeat(Q,CI.shape[3],axis=2).reshape(CI.shape) # quantities with CI dimenssions
quantityCI = CI * Q_dimCI

TAXCO2_dom = (quantityCI * partDomCI * taxCO2_CI * coef_Q_CO2_CI).sum(axis=3) + DF * partDomDF * taxCO2_DF * coef_Q_CO2_DF + DG * partDomDG * taxCO2_DG * coef_Q_CO2_DG + DI * partDomDI * taxCO2_DI * coef_Q_CO2_DI
TAXCO2_imp = (quantityCI * partImpCI * taxCO2_CI * coef_Q_CO2_CI).sum(axis=3) + DF * partImpDF * taxCO2_DF * coef_Q_CO2_DF + DG * partImpDG * taxCO2_DG * coef_Q_CO2_DG + DI * partImpDI * taxCO2_DI * coef_Q_CO2_DI
taxCO2 = TAXCO2_dom + TAXCO2_imp

tax_co2_liquids = taxCO2[:,:,dimSEC.index('Et'),:].sum(axis=1)

elecBiomassInitial_emissions               = 0.094 #; // tCO2/GJinput
elecBiomassInitial_emissionsCCS            = 0.009 #; // tCO2/GJinpu
ind_bioCCS = dimELEC.index('biomassIGCCseq')
tep2kwh         =               11628 #; // kWh/tep
tep2MWh         =       tep2kwh / 1e3 #; // MWh / tep
exa2giga        =                 1e9 #; // G / E
tep2gj          =              41.855 #; // GJ/tep
tep2ej          = tep2gj / exa2giga 


prod_bioCCS_tep =  prod_elec_techno / tep2MWh / 1e6 / rho_elec_moyen
prod_bioCCS_glob_tep = prod_bioCCS_tep[:,:,ind_bioCCS,:].sum(axis=1)

emi_evitee_glob = emi_evitee.sum(axis=1)

emi_evitee_glob_GtCO2_EJ = emi_evitee_glob / 1e9 /1e6 / (prod_bioCCS_glob_tep* tep2ej)
# emi_evitee(:,1) = prod_elec_techno(:,24) / tep2MWh / 1e6 ./ rho_elec_moyen(:,indice_BIGCCS) * elecBiomassInitial.emissionsCCS;

data_2plot=prepareArray2plot( Q_biofuel_anticip_reg[combi_all,:][:,tptScale] * 1e6 * tep2ej,timeset[tptScale])
linePlot(data_2plot,outdir+"Q_biofuel_anticip_reg" , combi_Legend_all,"Q biofuel (EJ)",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

data_2plot=prepareArray2plot( oil_rent[combi_all,:][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"oil_rent" , combi_Legend_all,"oil_rent (M$)",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

data_2plot=prepareArray2plot( emission_CO2[combi_all,:][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"emission_CO2" , combi_Legend_all," Fossil fuel emissions (?)",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

data_2plot=prepareArray2plot( GDP_PPP_real_w[combi_all,:][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"GDP_PPP_real_w" , combi_Legend_all," GDP PPP real",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

data_2plot=prepareArray2plot( pkmautomobile[combi_all,:][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"pkmautomobile" , combi_Legend_all," Passenger . Kilometer ",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

data_2plot=prepareArray2plot( emi_evitee_glob_GtCO2_EJ[combi_all,:][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"emi_evitee_glob_GtCO2_EJ" , combi_Legend_all," emi_evitee_glob_GtCO2_EJ ",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

##########################
# plot - Im+nlu
##########################
Oil_land_rent = E_scarcity_rent/1e6 + oil_rent[combi_all,:]
Oil_land_rent = E_world_profit/1e6 + oil_rent[combi_all,:]
emi_ff_land = C_total_emissions / 1e9 + emission_CO2[combi_all,:]

data_2plot=prepareArray2plot( Oil_land_rent[:,tptScale] / 1e6,timeset[tptScale])
linePlot(data_2plot,outdir+"Oil_land_rent" , combi_Legend_all," Oil_land_rent (M$)",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)

data_2plot=prepareArray2plot( emi_ff_land[:,tptScale] / 1e6,timeset[tptScale])
linePlot(data_2plot,outdir+"emi_ff_land" , combi_Legend_all," FF and non iLuc emissions (GtCO2/yr)",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)



combi_Legend_all = ['Medium food - clim', 'Low food - clim', 'Bioenergy for both']
colour_all = [ [178.0,34.0,34.0],[178.0,34.0,34.0], [0.0,0.0,0.0] ] 
style_line_all = [ '-', '--', '-']
calorific_demand = np.zeros( (3,100))
calorific_demand[0,:] = P_world_prod_Dyn[2,:] *PkcalExajoule #+ Q_biofuel_anticip_reg[dimCOMBI.index('3991'),:] * 1e6 * tep2ej
calorific_demand[1,:] = P_world_prod_Dyn[5,:] *PkcalExajoule #+ Q_biofuel_anticip_reg[dimCOMBI.index('3991'),:] * 1e6 * tep2ej
calorific_demand[2,:] = Q_biofuel_anticip_reg[dimCOMBI.index('3991'),:] * 1e6 * tep2ej 

data_2plot=prepareArray2plot( calorific_demand[:,tptScale] ,timeset[tptScale])
linePlot(data_2plot,outdir+"calorific_demand" , combi_Legend_all,"Total agricultural production (EJ)",colour_all,plot_nb_line,-0.50,-0.30,linestyle=style_line_all)


##########################
# plot - Im+nlu
##########################
ind_fao = combi_all_str.index('3991')
ind_ag1 = combi_all_str.index('3992')
colour_all = [ [100.0,149.0,237.0], [46.0,139.0,87.0] , [178.0,34.0,34.0] ] #, [100.0,149.0,237.0], [46.0,139.0,87.0], [178.0,34.0,34.0] ] 
style_line_all = [ '-', '-', '-']

C_tot_emission = np.zeros( (3,100))
C_total_emissions_ag0 = np.zeros( (1,100))
ii=-1
for scn_ref_nofuel in ['13991','13992','13993','3993']:
    ii +=1
    for diry in list_dir_tpt:
        scn_name = diry.split('_')[0]
        if scn_name==scn_ref_nofuel:
            sub_dir_tpt = diry + nlu_sub_dir
            for suby in os.listdir( sub_dir_tpt):
                if '2016' in suby:
                    data_path = sub_dir_tpt + suby + '/simulation_global_results.csv'
            print data_path
            data_nlu_temp = np.genfromtxt( data_path, str,delimiter=';')
            ind_var =  np.where( data_nlu_temp[:, 0] == 'C_total_emissions,tCO2eq/yr' )
            data_tpt= data_nlu_temp[ ind_var[0]+1,:]
            len_tpt= data_tpt.shape[1]
            if ii <=2:
                str2exec = 'C_tot_emission[ ii, 0:len_tpt] = np.array(data_tpt[0], dtype=float)'
                exec( str2exec)
            else:
                str2exec = 'C_total_emissions_ag0[ 0, 0:len_tpt] = np.array(data_tpt[0], dtype=float)'
                exec( str2exec)
# no ref yet
#C_tot_emission[2,:] = C_total_emissions_ag0[0,:] #C_tot_emission[0,:]

emi_of_enercrops = np.zeros( (3,100))
emi_of_enercrops[0,:] = C_total_emissions[ind_fao,:] / 1e9 - C_tot_emission[0,:] / 1e9
emi_of_enercrops[1,:] = C_total_emissions[ind_ag1,:] / 1e9 - C_tot_emission[1,:] / 1e9
emi_of_enercrops[2,:] = C_total_emissions_ag0[0,:] / 1e9 - C_tot_emission[2,:] / 1e9

ener_crop = np.zeros( (3,100))
ener_crop[0,:] = (prod_bioCCS_glob_tep + Q_biofuel_anticip_reg)[ dimCOMBI.index('3991'),:]
ener_crop[1,:] = (prod_bioCCS_glob_tep + Q_biofuel_anticip_reg)[ dimCOMBI.index('3992'),:]
ener_crop[2,:] = (prod_bioCCS_glob_tep + Q_biofuel_anticip_reg)[ dimCOMBI.index('3993'),:]

emi_of_enercrops_per_ej = emi_of_enercrops / (ener_crop * tep2ej)
emi_of_enercrops_per_ej[emi_of_enercrops_per_ej > 3000] = 3000.
emi_of_enercrops_per_ej[emi_of_enercrops_per_ej < -3000] = -3000.
emi_of_enercrops_per_ej[2,49:-1] = 0
emi_of_enercrops_per_ej [ np.isnan( emi_of_enercrops_per_ej)] = 0

data_2plot = prepareArray2plot( emi_of_enercrops[:,tptScale] / 1e6,timeset[tptScale])
linePlot( data_2plot,outdir + "emi_of_enercrops" , combi_Legend_all," exta emi enercrops (GtCO2/yr)",colour_all,2,-0.50,-0.30,linestyle=style_line_all)

data_2plot = prepareArray2plot( emi_of_enercrops_per_ej[:,tptScale] / 1e6,timeset[tptScale])
linePlot( data_2plot,outdir + "emi_of_enercrops_per_ej" , combi_Legend_all," exta emi enercrops (GtCO2/ej)",colour_all,2,-0.50,-0.30,linestyle=style_line_all)



###########################
# loop for area plot
###########################
colour_all = [ [100.0,149.0,237.0], [46.0,139.0,87.0], [178.0,34.0,34.0] ] #, [100.0,149.0,237.0], [46.0,139.0,87.0], [178.0,34.0,34.0] ] 
style_line_all = [ '-', '-', '-', '--', '--', '--']
ii = -1
for comby in combi_all:
    ii += 1
    data_temp = np.zeros( (3,100))
    data_temp[0,:] = oil_rent[comby,:]
    #data_temp[1,:] = E_scarcity_rent[ii,:]/1e6
    data_temp[1,:] = E_world_profit[ii,:]/1e6
    data_temp[2,:] = tax_co2_liquids[comby,:]
    exec('rent_' + combi_all_str[ii] + ' = copy.deepcopy(data_temp)')
    data_2plot=prepareArray2plot( data_temp[:,tptScale] / 1e6,timeset[tptScale])
    areaPlot( data_2plot, outdir + "rent_" + combi_all_str[ii], ['Oil rent', 'Land rent', 'CO2 rent (liquids)'], 'Rent transfers (M$)', colour_all, 1,-0.40,-0.30)
