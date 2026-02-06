# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

# -*- coding: utf-8 -*-

import copy

# this files enables to plots results from Imaclim runs
# be carefull, at this time, this is working only in the case that combi are smartly ordered and named... and existing just once in the result folder (and here with the corresponding climate scenario names combi+'100')
# default : this is working for 4 scenarios (plus climate variants) (see defaults settings for style_line, colours, etc)
# default : this is working for runs with 100 time steps (see defaults settings)

#########################################################################################################
# Main code #
#########################################################################################################


###############################
###############################
# default plots options
###############################
###############################
# default first time to be shown on plots
if not ('first_time' in globals()):
	first_time = int(dimYEAR[0])
# default first time to be shown on plots
if not ('time_horizon' in globals()):
	time_horizon = int(dimYEAR[-1])
tptScale = list()
for timy in range(time_horizon - first_time +1):
	tptScale.append(timy + first_time - int(dimYEAR[0]))

if not ('style_line' in globals()):
	style_line = ['-','-','--','--']
if not ('colours' in globals()):
	colours = [  [21.0,95.0,167.0], [194.0,207.0,0.0], [21.0,95.0,167.0], [194.0,207.0,0.0]]
# default globis combi legend (first use for this code
if not ('combi_Legend' in globals()):
	combi_Legend = ['G1 (Glob_HighCons)','G2 (Glob_LowCons)','G3 (Frag_HighCons)','G4 (Frag_LowCons)']
if not ('combi_Legend_clim' in globals()):
	combi_Legend_clim = ['G1 (Glob_HighCons_Clim)','G2 (Glob_LowCons_Clim)','G3 (Frag_HighCons_Clim)','G4 (Frag_LowCons_Clim)']
# headers for tables : possibility to have smaller legen in tables
if not ('combi_header_tab' in globals()):
	combi_header_tab = ['G1 (Glob\_HighCons)','G2 (Glob\_LowCons)','G3 (Frag\_HighCons)','G4 (Frag\_LowCons)']
if not ('combi_header_tab_clim' in globals()):
	combi_header_tab_clim = ['G1 (Glob\_HighCons\_Clim)','G2 (Glob\_LowCons\_Clim)','G3 (Frag\_HighCons\_Clim)','G4 (Frag\_LowCons\_Clim)']


# combi to look after (for globis right now.. code something more general later)
# and corresponding indices
# default combi :
if not ('combi_baseline_str' in globals()):
	combi_baseline_str = ['5','6','7','8']
if not ('combi_climat_str' in globals()):
	combi_climat_str = ['105','106','107','108'] # 4 scenarios by default

combi_climat = list()
for elt in combi_climat_str:
	combi_climat.append(dimCOMBI.index(elt))
combi_baseline = list()
for elt in combi_baseline_str:
	combi_baseline.append(dimCOMBI.index(elt))
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
outdir= outputDirs + 'plots' + combi_baseline_str[0] + '/'
outdirAnalysis = outdir + 'analysePlots/'
# create output dir if not existing
try:
	   os.stat(outdir)
except:
	   os.mkdir(outdir)
try:
	   os.stat(outdirAnalysis)
except:
	   os.mkdir(outdirAnalysis) 

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
# plots to analyse
################################################
################################################

#world energy prices - baseline
data_2plot=prepareArray2plot( wpEner[combi_baseline,0][:,tptScale],timeset[tptScale])
data_2plot=prepareArray2plot( wpEner[combi_baseline,1][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"world-oil-price" ,combi_Legend,"World oil prices ($2001/Mtoe)",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( wpEner[combi_baseline,2][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"world-gas-price" ,combi_Legend,"",colours,1,-0.50,-0.30)
data_2plot=prepareArray2plot( wpEner[combi_baseline,3][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"world-et-price" ,combi_Legend,"",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( wpEner[combi_baseline,4][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"world-elec-price" ,combi_Legend,"",colours,1,-0.50,-0.30,linestyle=style_line)
#world energy prices - climat
data_2plot=prepareArray2plot( wpEner[combi_climat,0][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"world-coal-price-climat" ,combi_Legend_clim,"",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( wpEner[combi_climat,1][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"world-oil-price-climat" ,combi_Legend_clim,"",colours,1,-0.50,-0.30)
data_2plot=prepareArray2plot( wpEner[combi_climat,2][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"world-gas-price-climat" ,combi_Legend_clim,"",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( wpEner[combi_climat,3][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"world-et-price-climat" ,combi_Legend_clim,"",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( wpEner[combi_climat,4][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"world-elec-price-climat" ,combi_Legend_clim,"",colours,1,-0.50,-0.30,linestyle=style_line)

#GDP MER real-baseline
data_2plot=prepareArray2plot( GDP_MER_real.sum(axis=1)[combi_baseline][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-mer-real-baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( GDP_MER_real[combi_baseline,dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-mer-real-baseline-Europe" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
#GDP MER nominal-baseline
data_2plot=prepareArray2plot( GDP_MER_nominal.sum(axis=1)[combi_baseline][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-mer-nominal-baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( GDP_MER_nominal[combi_baseline,dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-mer-nominal-baseline-Europe" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
#GDP PPP real-baseline
data_2plot=prepareArray2plot( GDP_PPP_real.sum(axis=1)[combi_baseline][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-ppp-real-baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( GDP_PPP_real[combi_baseline,dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-ppp-real-baseline-Europe" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
#GDP PPP nominal-baseline
data_2plot=prepareArray2plot( GDP_PPP_nominal.sum(axis=1)[combi_baseline][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-ppp-nominal-baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( GDP_PPP_nominal[combi_baseline,dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-ppp-nominal-baseline-Europe" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
#GDP MER real difference
data_2plot=prepareArray2plot( -GDP_MER_real.sum(axis=1)[combi_baseline][:,tptScale]+GDP_MER_real.sum(axis=1)[combi_climat][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-mer-real-diff-world" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( -GDP_MER_real[combi_baseline,dimREG.index('EUR')][:,tptScale]+GDP_MER_real[combi_climat,dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-mer-real-diff-Europe" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
#GDP PPP real difference
data_2plot=prepareArray2plot( -GDP_PPP_real.sum(axis=1)[combi_baseline][:,tptScale]+GDP_PPP_real.sum(axis=1)[combi_climat][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-ppp-real-diff-world" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( -GDP_PPP_real[combi_baseline,dimREG.index('EUR')][:,tptScale]+GDP_PPP_real[combi_climat,dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-ppp-real-diff-Europe" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
#GDP PPP real-relative-baseline
data_2plot=prepareArray2plot( GDP_PPP_real.sum(axis=1)[combi_baseline][:,tptScale] / GDP_PPP_real.sum(axis=1)[combi_benchmark][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-ppp-real-relative-baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( GDP_PPP_real[combi_baseline,dimREG.index('EUR')][:,tptScale] / GDP_PPP_real[combi_benchmark,dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-ppp-real-relative-baseline-Europe" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
#GDP PPP real-relative-climat
data_2plot=prepareArray2plot( GDP_PPP_real.sum(axis=1)[combi_climat][:,tptScale] / GDP_PPP_real.sum(axis=1)[combi_benchmark_climat][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-ppp-real-relative-climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( GDP_PPP_real[combi_climat,dimREG.index('EUR')][:,tptScale] / GDP_PPP_real[combi_benchmark_climat,dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"GDP-ppp-real-relative-climat-Europe" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
# CO2 taxes
data_2plot=prepareArray2plot( taxMKT[combi_climat][:,tptScale]*Million,timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"taxes" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
# Final Energy :
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_baseline,dimCONSENER.index('Final_consumption')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Final_energy_World_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[combi_baseline,dimCONSENER.index('Final_consumption'),dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Final_energy_Europe_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_climat,dimCONSENER.index('Final_consumption')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Final_energy_World_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[combi_climat,dimCONSENER.index('Final_consumption'),dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Final_energy_Europe_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
# Energy intensity:
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_baseline,dimCONSENER.index('Final_consumption')][:,tptScale] / GDP_PPP_real.sum(axis=1)[combi_baseline][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Energy_intensity_GDP_world_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[combi_baseline,dimCONSENER.index('Final_consumption'),dimREG.index('EUR')][:,tptScale] / GDP_PPP_real[combi_baseline,dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Energy_intensity_GDP_Europe_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_climat,dimCONSENER.index('Final_consumption')][:,tptScale] / GDP_PPP_real.sum(axis=1)[combi_climat][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Energy_intensity_GDP_world_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[combi_climat,dimCONSENER.index('Final_consumption'),dimREG.index('EUR')][:,tptScale] / GDP_PPP_real[combi_climat,dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Energy_intensity_GDP_Europe_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
# p_agri
data_2plot=prepareArray2plot( p.sum(axis=1)[combi_baseline,dimSEC.index('agri')][:,tptScale] ,timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"P_agri_world_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( p.sum(axis=1)[combi_climat,dimSEC.index('agri')][:,tptScale] ,timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"P_agri_world_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( p[combi_baseline,dimREG.index('EUR'),dimSEC.index('agri')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"P_agri_Europe_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( p[combi_climat,dimREG.index('EUR'),dimSEC.index('agri')][:,tptScale] ,timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"P_agri_Europe_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
# final energy in private automobile
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_baseline,dimCONSENER.index('Cons_Private_Automobile')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_PrivateAuto_world_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_climat,dimCONSENER.index('Cons_Private_Automobile')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_PrivateAuto_world_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[combi_baseline,dimCONSENER.index('Cons_Private_Automobile'),dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_PrivateAuto_Europe_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[combi_climat,dimCONSENER.index('Cons_Private_Automobile'),dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_PrivateAuto_Europe_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
# final energy in air transport
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_baseline,dimCONSENER.index('Cons_Air_trans')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_AirTrans_world_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_climat,dimCONSENER.index('Cons_Air_trans')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_AirTrans_world_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[combi_baseline,dimCONSENER.index('Cons_Air_trans'),dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_AirTrans_Europe_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[combi_climat,dimCONSENER.index('Cons_Air_trans'),dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_AirTrans_Europe_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
# final energy in other transport
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_baseline,dimCONSENER.index('Cons_Other_trans')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_OtherTrans_world_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_climat,dimCONSENER.index('Cons_Other_trans')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_OtherTrans_world_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[combi_baseline,dimCONSENER.index('Cons_Other_trans'),dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_OtherTrans_Europe_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[combi_climat,dimCONSENER.index('Cons_Other_trans'),dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_OtherTrans_Europe_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
# final energy in residential sector (private buildings)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_baseline,dimCONSENER.index('Cons_Residential')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_PrivateBuidling_world_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_climat,dimCONSENER.index('Cons_Residential')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_PrivateBuidling_world_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[combi_baseline,dimCONSENER.index('Cons_Residential'),dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_PrivateBuidling_Europe_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[combi_climat,dimCONSENER.index('Cons_Residential'),dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"Ener_PrivateBuidling_Europe_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
# Final energy / exports
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_baseline,dimCONSENER.index('Final_consumption')][:,tptScale]/ ExpValue.sum(axis=2).sum(axis=1)[combi_baseline ][:,tptScale],timeset[tptScale] )
linePlot(data_2plot,outdirAnalysis+"FinalEner_byExport_world_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_climat,dimCONSENER.index('Final_consumption')][:,tptScale]/ ExpValue.sum(axis=2).sum(axis=1)[combi_climat ][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"FinalEner_byExport_world_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[combi_baseline,dimCONSENER.index('Final_consumption'),dimREG.index('EUR')][:,tptScale]/ ExpValue.sum(axis=2)[combi_baseline,dimREG.index('EUR') ][:,tptScale] ,timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"FinalEner_byExport_Europe_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[combi_climat,dimCONSENER.index('Final_consumption'),dimREG.index('EUR')][:,tptScale]/ ExpValue.sum(axis=2)[combi_climat,dimREG.index('EUR') ][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdirAnalysis+"FinalEner_byExport_Europe_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
# Balance of trade
data_2plot=prepareArray2plot( ExpValue.sum(axis=2).sum(axis=1)[combi_baseline ][:,tptScale] - ImpValue.sum(axis=2).sum(axis=1)[combi_baseline ][:,tptScale],timeset[tptScale] )
linePlot(data_2plot,outdirAnalysis+"TradeBalance_world_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( ExpValue.sum(axis=2).sum(axis=1)[combi_climat ][:,tptScale] - ImpValue.sum(axis=2).sum(axis=1)[combi_climat ][:,tptScale],timeset[tptScale] )
linePlot(data_2plot,outdirAnalysis+"TradeBalance_world_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( ExpValue.sum(axis=2)[combi_baseline ,dimREG.index('EUR')][:,tptScale] - ImpValue.sum(axis=2)[combi_baseline ,dimREG.index('EUR')][:,tptScale],timeset[tptScale] )
linePlot(data_2plot,outdirAnalysis+"TradeBalance_Europe_baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( ExpValue.sum(axis=2)[combi_climat ,dimREG.index('EUR')][:,tptScale] - ImpValue.sum(axis=2)[combi_climat,dimREG.index('EUR') ][:,tptScale],timeset[tptScale] )
linePlot(data_2plot,outdirAnalysis+"TradeBalance_Europe_climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
###########
# Energy investment, Cap, Q, charge : by region
byRegionList = ['Investment','Q','Cap','charge']
for elt in byRegionList:
	exec('varTemp = ' + elt)
	try:
		   os.stat(outdirAnalysis+elt+"/")
	except:
		   os.mkdir(outdirAnalysis+elt+"/")
	for eltReg in dimREG:
		for eltSec in dimSEC:
			data_2plot=prepareArray2plot( varTemp[combi_baseline ,dimREG.index(eltReg),dimSEC.index(eltSec)][:,tptScale] / varTemp[combi_benchmark ,dimREG.index(eltReg),dimSEC.index(eltSec)][:,tptScale],timeset[tptScale] )
			linePlot(data_2plot,outdirAnalysis+elt+"/"+elt+"-relat-baseline-"+eltSec+ "-" + eltReg , combi_Legend, "", colours, 1,-0.40,-0.30,linestyle=style_line)
			data_2plot=prepareArray2plot( varTemp[combi_climat ,dimREG.index(eltReg),dimSEC.index(eltSec)][:,tptScale] / varTemp[combi_benchmark_climat ,dimREG.index(eltReg),dimSEC.index(eltSec)][:,tptScale],timeset[tptScale] )
			linePlot(data_2plot,outdirAnalysis+elt+"/"+elt+"-relat-climat-"+eltSec+ "-" + eltReg , combi_Legend_clim, "", colours, 1,-0.40,-0.30,linestyle=style_line)
# prod elec techno world:
listIndRenewable = list()
listIndRenewable.append(dimELEC.index('grosHYDro'))
for indy in range(  dimELEC.index('HudroFuelCell') +1 - dimELEC.index('CombHeatPow') ):
	listIndRenewable.append(dimELEC.index('CombHeatPow') + indy )
data_2plot=prepareArray2plot( prod_elec_techno.sum(axis=2)[combi_baseline][:,listIndRenewable,:].sum(axis=1)[:,tptScale]  / prod_elec_techno.sum(axis=2)[combi_benchmark,listIndRenewable,:].sum(axis=0)[:,tptScale]  ,timeset[tptScale] )
linePlot(data_2plot,outdirAnalysis+"Prod-elec-renewable-relat-world-baseline" ,combi_Legend,"Renewable capacity investment (GW)",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( prod_elec_techno.sum(axis=2)[combi_climat][:,listIndRenewable,:].sum(axis=1)[:,tptScale]  / prod_elec_techno.sum(axis=2)[combi_benchmark,listIndRenewable,:].sum(axis=0)[:,tptScale]  ,timeset[tptScale] )
linePlot(data_2plot,outdirAnalysis+"Prod-elec-renewable-relat-world-climat" ,combi_Legend_clim,"Renewable capacity investment (GW)",colours,1,-0.40,-0.30,linestyle=style_line)
# prod elec techno europe:
data_2plot=prepareArray2plot( prod_elec_techno[combi_baseline][:,listIndRenewable,dimREG.index('EUR'),:].sum(axis=1)[:,tptScale]  / prod_elec_techno[combi_benchmark,listIndRenewable,dimREG.index('EUR'),:].sum(axis=0)[:,tptScale]  ,timeset[tptScale] )
linePlot(data_2plot,outdirAnalysis+"Prod-elec-renewable-relat-europe-baseline" ,combi_Legend,"Renewable capacity investment (GW)",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( prod_elec_techno[combi_climat][:,listIndRenewable,dimREG.index('EUR'),:].sum(axis=1)[:,tptScale]  / prod_elec_techno[combi_benchmark,listIndRenewable,dimREG.index('EUR'),:].sum(axis=0)[:,tptScale]  ,timeset[tptScale] )
linePlot(data_2plot,outdirAnalysis+"Prod-elec-renewable-relat-europe-climat" ,combi_Legend_clim,"Renewable capacity investment (GW)",colours,1,-0.40,-0.30,linestyle=style_line)


# loop on prod elec techno : by region, by reneable techno
try:
	os.stat(outdirAnalysis+"Prod_Renewable_Elec/")
except:
	os.mkdir(outdirAnalysis+"Prod_Renewable_Elec/")
for renewTech in listIndRenewable:
	for eltReg in dimREG:
		data_2plot=prepareArray2plot( prod_elec_techno[combi_baseline,renewTech,dimREG.index(eltReg),:][:,tptScale]  / prod_elec_techno[combi_benchmark,renewTech,dimREG.index(eltReg),:][:,tptScale]  ,timeset[tptScale] )
		linePlot(data_2plot,outdirAnalysis+"Prod_Renewable_Elec/"+"Prod"+"-relat-baseline-"+eltReg+ "-" + dimELEC[renewTech] , combi_Legend, "", colours, 1,-0.40,-0.30,linestyle=style_line)
		data_2plot=prepareArray2plot( prod_elec_techno[combi_climat,renewTech,dimREG.index(eltReg),:][:,tptScale]  / prod_elec_techno[combi_benchmark,renewTech,dimREG.index(eltReg),:][:,tptScale]  ,timeset[tptScale] )
		linePlot(data_2plot,outdirAnalysis+"Prod_Renewable_Elec/"+"Prod"+"-relat-climat-"+eltReg+ "-" + dimELEC[renewTech] , combi_Legend_clim, "", colours, 1,-0.40,-0.30,linestyle=style_line)

# Wages
meanWages = (l*Q*w).sum(axis=2) / (l*Q).sum(axis=2) 
data_2plot=prepareArray2plot( meanWages[combi_baseline,dimREG.index('EUR'),:][:,tptScale]  / meanWages[combi_benchmark,dimREG.index('EUR'),:][:,tptScale]  ,timeset[tptScale] )
linePlot(data_2plot,outdirAnalysis+"Mean-wages-relat-europe-baseline" ,combi_Legend,"",colours,1,-0.40,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( meanWages[combi_climat,dimREG.index('EUR'),:][:,tptScale]  / meanWages[combi_benchmark,dimREG.index('EUR'),:][:,tptScale]  ,timeset[tptScale] )
linePlot(data_2plot,outdirAnalysis+"Mean-wages-relat-europe-climat" ,combi_Legend_clim,"",colours,1,-0.40,-0.30,linestyle=style_line)
# loop on wages
# loop on wages
try:
	os.stat(outdirAnalysis+"Wages/")
except:
	os.mkdir(outdirAnalysis+"Wages/")
for eltSec in dimSEC:
	for eltReg in dimREG:
		data_2plot=prepareArray2plot( w[combi_baseline,dimREG.index(eltReg),dimSEC.index(eltSec),:][:,tptScale]  / w[combi_benchmark,dimREG.index(eltReg),dimSEC.index(eltSec),tptScale]  ,timeset[tptScale] )
		linePlot(data_2plot,outdirAnalysis+"Wages/"+"Wages"+"-relat-baseline-"+eltReg+ "-" + eltSec , combi_Legend, "", colours, 1,-0.40,-0.30,linestyle=style_line)
		data_2plot=prepareArray2plot( w[combi_climat,dimREG.index(eltReg),dimSEC.index(eltSec),:][:,tptScale]  / w[combi_benchmark,dimREG.index(eltReg),dimSEC.index(eltSec),tptScale]  ,timeset[tptScale] )
		linePlot(data_2plot,outdirAnalysis+"Wages/"+"Wages"+"-relat-climat-"+eltReg+ "-" + eltSec , combi_Legend_clim, "", colours, 1,-0.40,-0.30,linestyle=style_line)
# loop on added value
try:
	os.stat(outdirAnalysis+"ValueAdded/")
except:
	os.mkdir(outdirAnalysis+"ValueAdded/")
for eltSec in dimSEC:
	for eltReg in dimREG:
		data_2plot=prepareArray2plot( VA[combi_baseline,dimREG.index(eltReg),dimSEC.index(eltSec),:][:,tptScale]  / VA[combi_benchmark,dimREG.index(eltReg),dimSEC.index(eltSec),tptScale]  ,timeset[tptScale] )
		linePlot(data_2plot,outdirAnalysis+"ValueAdded/"+"ValueAdded"+"-relat-baseline-"+eltReg+ "-" + eltSec , combi_Legend, "", colours, 1,-0.40,-0.30,linestyle=style_line)
		data_2plot=prepareArray2plot( VA[combi_climat,dimREG.index(eltReg),dimSEC.index(eltSec),:][:,tptScale]  / VA[combi_benchmark,dimREG.index(eltReg),dimSEC.index(eltSec),tptScale]  ,timeset[tptScale] )
		linePlot(data_2plot,outdirAnalysis+"ValueAdded/"+"ValueAdded"+"-relat-climat-"+eltReg+ "-" + eltSec , combi_Legend_clim, "", colours, 1,-0.40,-0.30,linestyle=style_line)




################################################
################################################
# cleaner plots for reports (say, with titles)
################################################
################################################
# oil production and prices
data_2plot=prepareArray2plot( Q.sum(axis=1)[combi_baseline ,dimSEC.index('oil')][:,tptScale]*tep2oilbarrels/year2day,timeset[tptScale] )
areaPlot(data_2plot[0:2],outdir+"World_oil_production-5" ,combi_Legend,"World oil production (Million b/d)",colours,1,-0.30,-0.30)
data_2plot=prepareArray2plot( wpEner[combi_baseline,dimWENER.index('Oil')][:,tptScale]/tep2oilbarrels,timeset[tptScale])
linePlot(data_2plot[0:2],outdir+"world-oil-price-5" ,combi_Legend,"World oil price $/ (Million b/d)",colours,1,-0.30,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( Q.sum(axis=1)[combi_baseline ,dimSEC.index('oil')][:,tptScale] /Q.sum(axis=1)[combi_benchmark ,dimSEC.index('oil')][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"World_oil_production-baseline-relat" ,combi_Legend,"World oil production",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( wpEner[combi_baseline,dimWENER.index('Oil')][:,tptScale] / wpEner[combi_benchmark,dimWENER.index('Oil')][:,tptScale] ,timeset[tptScale])
linePlot(data_2plot,outdir+"world-oil-price-baseline-relat" ,combi_Legend,"World oil price",colours,1,-0.50,-0.30,linestyle=style_line)
# energy intensity - relative
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[combi_baseline,dimCONSENER.index('Final_consumption')][:,tptScale] / GDP_PPP_real.sum(axis=1)[combi_baseline][:,tptScale]/energy_balance_stock.sum(axis=2).sum(axis=2)[combi_benchmark,dimCONSENER.index('Final_consumption')][:,tptScale] * GDP_PPP_real.sum(axis=1)[combi_benchmark][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"Energy_intensity_GDP_world_baseline-relat" ,combi_Legend,"Energy intensity of GDP (Mtoe/$2001)",colours,1,-0.50,-0.30,linestyle=style_line)

data_2plot=prepareArray2plot( wpEner[combi_baseline,dimWENER.index('Oil')][:,tptScale],timeset[tptScale])
linePlot(data_2plot[0:2],outdir+"world-oil-price-mtep" ,combi_Legend,"World oil price $/ (Million b/d)",colours,1,-0.30,-0.30,linestyle=style_line)
#############
# GDP ppp-mer
#GDP PPP real-relative-climat
data_2plot=prepareArray2plot( GDP_PPP_real.sum(axis=1)[combi_climat][:,tptScale] / GDP_PPP_real.sum(axis=1)[combi_benchmark][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"GDP-ppp-real-relative-climat" ,combi_Legend_clim,"World GDP (ppp-real) - climate constrained",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( GDP_PPP_real[combi_climat,dimREG.index('EUR')][:,tptScale] / GDP_PPP_real[combi_benchmark,dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"GDP-ppp-real-relative-climat-Europe" ,combi_Legend_clim,"Europe GDP (ppp-real) - climate constrained",colours,1,-0.50,-0.30,linestyle=style_line)
#GDP PPP real-relative-baseline
data_2plot=prepareArray2plot( GDP_PPP_real.sum(axis=1)[combi_baseline][:,tptScale] / GDP_PPP_real.sum(axis=1)[combi_benchmark][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"GDP-ppp-real-relative-baseline" ,combi_Legend,"World GDP (ppp-real) - baseline",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( GDP_PPP_real[combi_baseline,dimREG.index('EUR')][:,tptScale] / GDP_PPP_real[combi_benchmark,dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"GDP-ppp-real-relative-baseline-Europe" ,combi_Legend,"Europe GDP (ppp-real) - baseline",colours,1,-0.50,-0.30,linestyle=style_line)

# losses GDP PPP real / respective baseline
data_2plot=prepareArray2plot( GDP_PPP_real.sum(axis=1)[combi_climat][:,tptScale] / GDP_PPP_real.sum(axis=1)[combi_baseline][:,tptScale] -1 ,timeset[tptScale])
linePlot(data_2plot,outdir+"losses-GDP-ppp-real-world" ,combi_Legend,"World GDP losses (ppp-real, %)",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( GDP_PPP_real[combi_climat,dimREG.index('EUR')][:,tptScale] / GDP_PPP_real[combi_baseline,dimREG.index('EUR')][:,tptScale] -1 ,timeset[tptScale])
linePlot(data_2plot,outdir+"losses-GDP-ppp-real-Europe" ,combi_Legend,"Europe GDP losses  (ppp-real, %) - climate constrained",colours,1,-0.50,-0.30,linestyle=style_line)


# constraint emission trajectory
data_2plot=prepareArray2plot( E_reg_use.sum(axis=2).sum(axis=1)[ combi_climat][: ,tptScale]/1e9  + emi_evitee.sum(axis=1)[combi_climat][:,tptScale]/1e9  ,timeset[tptScale])
linePlot(data_2plot[0:2],outdir+"emissions_trajectories" ,['Climate constrained scenarios'],"Constrained emissions trajectory (Gt CO2)",colours,1,-0.20,-0.30,linestyle=style_line) 
# emissions in baseline
data_2plot=prepareArray2plot( E_reg_use.sum(axis=2).sum(axis=1)[combi_baseline][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outdir+"emissions_world_baseline" ,combi_Legend,"World baseline emissions (Gt CO2)",colours,1,-0.50,-0.30,linestyle=style_line) 
data_2plot=prepareArray2plot( E_reg_use.sum(axis=2)[combi_baseline,dimREG.index('EUR')][:,tptScale] /1e9  + emi_evitee[combi_baseline,dimREG.index('EUR')][:,tptScale]/1e9  ,timeset[tptScale])
linePlot(data_2plot,outdir+"emissions_Europe_baseline" ,combi_Legend,"Europe baseline emissions (Gt CO2)",colours,1,-0.50,-0.30,linestyle=style_line) 

# world oil production, coal, gas (baseline vs climate)
data_2plot=prepareArray2plot( Q.sum(axis=1)[ [combi_benchmark,combi_benchmark_climat] ,dimSEC.index('oil')][:,tptScale],timeset[tptScale] )
linePlot(data_2plot,outdir+"World_oil_production-benchmarkclimat" ,['G1 (Glob_HighCons)','G1 (Glob_HighCons_Clim)'],"World oil production (Mtoe)",[  [21.0,95.0,167.0], [231.0,71.0,40.0] ],1,-0.30,-0.30)
data_2plot=prepareArray2plot( Q.sum(axis=1)[ [combi_benchmark,combi_benchmark_climat] ,dimSEC.index('gaz')][:,tptScale],timeset[tptScale] )
linePlot(data_2plot,outdir+"World_gaz_production-benchmarkclimat" ,['G1 (Glob_HighCons)','G1 (Glob_HighCons_Clim)'],"World gas production (Mtoe)",[  [21.0,95.0,167.0], [231.0,71.0,40.0] ],1,-0.30,-0.30)
data_2plot=prepareArray2plot( Q.sum(axis=1)[ [combi_benchmark,combi_benchmark_climat] ,dimSEC.index('coal')][:,tptScale],timeset[tptScale] )
linePlot(data_2plot,outdir+"World_coal_production-benchmarkclimat" ,['G1 (Glob_HighCons)','G1 (Glob_HighCons_Clim)'],"World coal production (Mtoe)",[  [21.0,95.0,167.0], [231.0,71.0,40.0] ],1,-0.30,-0.30)

# Trade
data_2plot=prepareArray2plot( ExpValue.sum(axis=2).sum(axis=1)[combi_baseline ][:,tptScale] / ExpValue.sum(axis=2).sum(axis=1)[combi_benchmark][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"Export_world_baseline-relative" ,combi_Legend,"World exportations in value (baseline)",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( ExpValue.sum(axis=2).sum(axis=1)[combi_climat ][:,tptScale] / ExpValue.sum(axis=2).sum(axis=1)[combi_benchmark][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"Export_world_climat-relative" ,combi_Legend_clim,"World exportations in value (under climate constraint)",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( ExpValue.sum(axis=2)[combi_baseline ,dimREG.index('EUR')][:,tptScale] / ExpValue.sum(axis=2)[combi_benchmark,dimREG.index('EUR')][:,tptScale],timeset[tptScale] )
linePlot(data_2plot,outdir+"Export_Europe_baseline-relative" ,combi_Legend,"Europe exportations in value (baseline)",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( ExpValue.sum(axis=2)[combi_climat ,dimREG.index('EUR')][:,tptScale]  / ExpValue.sum(axis=2)[combi_benchmark,dimREG.index('EUR')][:,tptScale],timeset[tptScale] )
linePlot(data_2plot,outdir+"Export_Europe_climat-relative" ,combi_Legend_clim,"Europe exportations in value (under climate constraint)",colours,1,-0.50,-0.30,linestyle=style_line)

data_2plot=prepareArray2plot( ImpValue.sum(axis=2)[combi_baseline ,dimREG.index('EUR')][:,tptScale] / ImpValue.sum(axis=2)[combi_benchmark,dimREG.index('EUR')][:,tptScale],timeset[tptScale] )
linePlot(data_2plot,outdir+"Import_Europe_baseline-relative" ,combi_Legend,"Europe Importations in value (baseline)",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( ImpValue.sum(axis=2)[combi_climat ,dimREG.index('EUR')][:,tptScale]  / ImpValue.sum(axis=2)[combi_benchmark,dimREG.index('EUR')][:,tptScale],timeset[tptScale] )
linePlot(data_2plot,outdir+"Import_Europe_climat-relative" ,combi_Legend_clim,"Europe Importations in value (under climate constraint)",colours,1,-0.50,-0.30,linestyle=style_line)
# energy content of trade
# final energy local freight (total, world and europe)
data_2plot=prepareArray2plot( FinalEnergy_fret.sum(axis=3).sum(axis=2).sum(axis=1)[combi_baseline ][:,tptScale] / FinalEnergy_fret.sum(axis=3).sum(axis=2).sum(axis=1)[combi_benchmark ][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"FinalEnergy_fret_world_baseline-relative" ,combi_Legend,"World energy content of local fret (baseline)",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( FinalEnergy_fret.sum(axis=3).sum(axis=2).sum(axis=1)[combi_climat ][:,tptScale] / FinalEnergy_fret.sum(axis=3).sum(axis=2).sum(axis=1)[combi_benchmark ][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"FinalEnergy_fret_world_climat-relative" ,combi_Legend_clim,"World energy content of local fret (climate constraint)",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( FinalEnergy_fret.sum(axis=3).sum(axis=2)[combi_baseline, dimREG.index('EUR')][:,tptScale] / FinalEnergy_fret.sum(axis=3).sum(axis=2)[combi_benchmark,dimREG.index('EUR') ][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"FinalEnergy_fret_Europe_baseline-relative" ,combi_Legend,"Europe energy content of local fret (world - baseline)",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( FinalEnergy_fret.sum(axis=3).sum(axis=2)[combi_climat, dimREG.index('EUR') ][:,tptScale] / FinalEnergy_fret.sum(axis=3).sum(axis=2)[combi_benchmark, dimREG.index('EUR') ][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"FinalEnergy_fret_Europe_climat-relative" ,combi_Legend_clim,"Europe energy content of local fret (climate constraint)",colours,1,-0.50,-0.30,linestyle=style_line)

# final energy local freight (by mode,under climat, world and europe)
data_2plot=prepareArray2plot( FinalEnergy_fret.sum(axis=2).sum(axis=1)[combi_climat, 0 ][:,tptScale] / FinalEnergy_fret.sum(axis=2).sum(axis=1)[combi_benchmark_climat, 0 ][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"FinalEnergy_airfret_world_climat-relative" ,combi_Legend_clim,"World energy content of air fret (climate constraint)",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( FinalEnergy_fret.sum(axis=2).sum(axis=1)[combi_climat, 1 ][:,tptScale] / FinalEnergy_fret.sum(axis=2).sum(axis=1)[combi_benchmark_climat, 1 ][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"FinalEnergy_merfret_world_climat-relative" ,combi_Legend_clim,"World energy content of marine bunker fret (climate constraint)",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( FinalEnergy_fret.sum(axis=2).sum(axis=1)[combi_climat, 2 ][:,tptScale] / FinalEnergy_fret.sum(axis=2).sum(axis=1)[combi_benchmark_climat, 2 ][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"FinalEnergy_OTfret_world_climat-relative" ,combi_Legend_clim,"World energy content of terresrial fret (climate constraint)",colours,1,-0.50,-0.30,linestyle=style_line)

data_2plot=prepareArray2plot( FinalEnergy_fret.sum(axis=2)[combi_climat, dimREG.index('EUR'), 0 ][:,tptScale] / FinalEnergy_fret.sum(axis=2)[combi_benchmark_climat, dimREG.index('EUR'), 0 ][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"FinalEnergy_airfret_Europe_climat-relative" ,combi_Legend_clim,"Europe energy content of air fret (climate constraint)",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( FinalEnergy_fret.sum(axis=2)[combi_climat, dimREG.index('EUR'), 1 ][:,tptScale] / FinalEnergy_fret.sum(axis=2)[combi_benchmark_climat, dimREG.index('EUR'), 1 ][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"FinalEnergy_merfret_Europe_climat-relative" ,combi_Legend_clim,"Europe energy content of marine bunker fret (climate constraint)",colours,1,-0.50,-0.30,linestyle=style_line)
data_2plot=prepareArray2plot( FinalEnergy_fret.sum(axis=2)[combi_climat, dimREG.index('EUR'), 2 ][:,tptScale] / FinalEnergy_fret.sum(axis=2)[combi_benchmark_climat, dimREG.index('EUR'), 2 ][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"FinalEnergy_OTfret_Europe_climat-relative" ,combi_Legend_clim,"Europe energy content of terresrial fret (climate constraint)",colours,1,-0.50,-0.30,linestyle=style_line)

# Energy in transport - world
# energy content of benchmark
data_2plot=prepareArray2plot( Transport_Energy.sum(axis=2)[:,combi_benchmark,: ][:,tptScale] ,timeset[tptScale] )
areaPlot(data_2plot,outdir+"Transport_energy_world_baseline_benchmark" ,transport_legend,"Final energy of transport (Mtoe)","../externals/pdfExtraction/py/colors.csv",2,-0.40,-0.30)
# energy content of benchmark - climat
data_2plot=prepareArray2plot( Transport_Energy.sum(axis=2)[:,combi_benchmark_climat,: ][:,tptScale] ,timeset[tptScale] )
areaPlot(data_2plot,outdir+"Transport_energy_world_climat_benchmark" ,transport_legend,"Final energy of transport (Mtoe)","../externals/pdfExtraction/py/colors.csv",2,-0.40,-0.30)
# energy content by scenario - baseline
data_2plot=prepareArray2plot( Transport_Energy.sum(axis=2).sum(axis=0)[combi_baseline ][:,tptScale]  / Transport_Energy.sum(axis=2).sum(axis=0)[combi_benchmark ][:,tptScale],timeset[tptScale] )
linePlot(data_2plot,outdir+"Transport_energy_world_baseline_relative" ,combi_Legend,"Energy content",colours,1,-0.50,-0.30,linestyle=style_line)
# energy content by scenario - climat
data_2plot=prepareArray2plot( Transport_Energy.sum(axis=2).sum(axis=0)[combi_climat ][:,tptScale] / Transport_Energy.sum(axis=2).sum(axis=0)[combi_benchmark ][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"Transport_energy_world_climat_relative" ,combi_Legend_clim,"Energy content",colours,1,-0.50,-0.30,linestyle=style_line)

# Energy in transport - Europe
# energy content of benchmark
data_2plot=prepareArray2plot( Transport_Energy[:,combi_benchmark ,dimREG.index('EUR')][:,tptScale] ,timeset[tptScale] )
areaPlot(data_2plot,outdir+"Transport_energy_Europe_baseline_benchmark" ,transport_legend,"Final energy of transport (Mtoe)","../externals/pdfExtraction/py/colors.csv",2,-0.40,-0.30)
# energy content of benchmark - climat
data_2plot=prepareArray2plot( Transport_Energy[:,combi_benchmark_climat,dimREG.index('EUR') ][:,tptScale] ,timeset[tptScale] )
areaPlot(data_2plot,outdir+"Transport_energy_Europe_climat_benchmark" ,transport_legend,"Final energy of transport (Mtoe)","../externals/pdfExtraction/py/colors.csv",2,-0.40,-0.30)
# energy content by scenario - baseline
data_2plot=prepareArray2plot( Transport_Energy.sum(axis=0)[combi_baseline,dimREG.index('EUR') ][:,tptScale]  / Transport_Energy.sum(axis=0)[combi_benchmark ,dimREG.index('EUR')][:,tptScale],timeset[tptScale] )
linePlot(data_2plot,outdir+"Transport_energy_Europe_baseline_relative" ,combi_Legend,"Final energy in transports",colours,1,-0.50,-0.30,linestyle=style_line)
# energy content by scenario - climat
data_2plot=prepareArray2plot( Transport_Energy.sum(axis=0)[combi_climat,dimREG.index('EUR') ][:,tptScale] / Transport_Energy.sum(axis=0)[combi_benchmark ,dimREG.index('EUR')][:,tptScale] ,timeset[tptScale] )
linePlot(data_2plot,outdir+"Transport_energy_Europe_climat_relative" ,combi_Legend_clim,"Energy content",colours,1,-0.50,-0.30,linestyle=style_line)

# loop on final energy content of transport
try:
	os.stat(outdirAnalysis+"Transport/")
except:
	os.mkdir(outdirAnalysis+"Transport/")
for trans in transport_legend:
	data_2plot=prepareArray2plot( Transport_Energy.sum(axis=2)[transport_legend.index(trans),combi_baseline,:][:,tptScale] / Transport_Energy.sum(axis=2)[transport_legend.index(trans),combi_benchmark,tptScale] ,timeset[tptScale] )
	linePlot(data_2plot,outdirAnalysis+"Transport/"+trans+"-energy"+"-relat-baseline" , combi_Legend, "", colours, 1,-0.40,-0.30,linestyle=style_line)
	data_2plot=prepareArray2plot( Transport_Energy.sum(axis=2)[transport_legend.index(trans),combi_climat,:][:,tptScale]  / Transport_Energy.sum(axis=2)[transport_legend.index(trans),combi_benchmark,tptScale] ,timeset[tptScale] )
	linePlot(data_2plot,outdirAnalysis+"Transport/"+trans+"-energy"+"-relat-climat" , combi_Legend_clim, "", colours, 1,-0.40,-0.30,linestyle=style_line)


# Emissions in transport
# emissions content of benchmark
data_2plot=prepareArray2plot( Transport_CO2.sum(axis=2)[:,combi_benchmark ][:,tptScale] ,timeset[tptScale] )
areaPlot(data_2plot,outdir+"Transport_emissions_world_baseline_benchmark" ,transport_legend,"Emissions of transport (GtCO2)","../externals/pdfExtraction/py/colors.csv",2,-0.40,-0.30)
# emissions content of benchmark - climat
data_2plot=prepareArray2plot( Transport_CO2.sum(axis=2)[:,combi_benchmark_climat ][:,tptScale] ,timeset[tptScale] )
areaPlot(data_2plot,outdir+"Transport_emissions_world_climat_benchmark" ,transport_legend,"Emissions of transport (GtCO2)","../externals/pdfExtraction/py/colors.csv",2,-0.40,-0.30)

# Natural growth in benchmark - Europe, baseline
Growths_vector = np.zeros(np.concatenate(([4],growth_PPP_real[combi_benchmark,:,:].shape)))
Growths_vector[0] = growth_PPP_real[combi_benchmark,:,:]
Growths_vector[1] = growth_GDP_fluid_reg[combi_benchmark,:,:]
Growths_vector[2] = growth_PPP_real[combi_benchmark_climat,:,:]
Growths_vector[3] = growth_GDP_fluid_reg[combi_benchmark_climat,:,:]

data_2plot=prepareArray2plot( Growths_vector[:,dimREG.index('EUR')][:,tptScale[0:(len(tptScale)-1)]],timeset[0:(len(tptScale)-1)] )
linePlot(data_2plot,outdir+"Growths-europe-baseline" ,['Growth with friction - baseline','Theorethical fluid growth - baseline','Growth with friction - climat','Theorethical fluid growth - climat'],"Europe growths - benchmark (%)",[  [21.0,95.0,167.0], [21.0,95.0,167.0], [231.0,71.0,40.0], [231.0,71.0,40.0] ],1,-0.40,-0.30,linestyle=['-','--','-','--'])

# Natural growth in benchmark - Europe, baseline
Growths_vector = np.zeros(np.concatenate(([4],growth_PPP_real[combi_benchmark,:,:].shape)))
Growths_vector[0] = growth_PPP_real[combi_benchmark,:,:]
Growths_vector[1] = growth_GDP_fluid_reg[combi_benchmark,:,:]
Growths_vector[2] = growth_PPP_real[combi_benchmark_climat,:,:]
Growths_vector[3] = growth_GDP_fluid_reg[combi_benchmark_climat,:,:]

data_2plot=prepareArray2plot( Growths_vector[:,dimREG.index('EUR')][:,0:(len(tptScale)-1)],timeset[0:(len(tptScale)-1)] )
linePlot(data_2plot,outdir+"Growths-europe-baseline" ,['Growth with friction - baseline','Theorethical fluid growth - baseline','Growth with friction - climat','Theorethical fluid growth - climat'],"Europe growths - benchmark (%)",[  [21.0,95.0,167.0], [21.0,95.0,167.0], [231.0,71.0,40.0], [231.0,71.0,40.0] ],1,-0.40,-0.30,linestyle=['-','--','-','--'])



################################################
################################################
# Integrated scenarios - common
################################################
################################################
#energy intensity europe
benchmark_indexes=[dimCOMBI.index('6'),dimCOMBI.index('106'),dimCOMBI.index('1006'),dimCOMBI.index('1106')]
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2)[benchmark_indexes,dimCONSENER.index('Final_consumption'),dimREG.index('EUR')][:,tptScale] / GDP_PPP_real[benchmark_indexes,dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outputDirs+"Energy_intensity_GDP_europe_benchmark_noBiocar" ,['G2 (Glob_LowCons) - previous Sc. - baseline','G2 (Glob_LowCons_Clim) - previous Sc. - climat','G2 (Glob_LowCons) - no biocar. - baseline','G2 (Glob_LowCons_Clim) - no biocar. - climat'],"Energy inensity of GDP (Mtoe/$2001)",[  [21.0,95.0,167.0], [231.0,71.0,40.0], [21.0,95.0,167.0], [231.0,71.0,40.0] ],1,-0.40,-0.30,linestyle=style_line)
#energy intensity world
benchmark_indexes=[dimCOMBI.index('6'),dimCOMBI.index('106'),dimCOMBI.index('1006'),dimCOMBI.index('1106')]
data_2plot=prepareArray2plot( energy_balance_stock.sum(axis=2).sum(axis=2)[benchmark_indexes,dimCONSENER.index('Final_consumption')][:,tptScale] / GDP_PPP_real.sum(axis=1)[benchmark_indexes][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outputDirs+"Energy_intensity_GDP_world_benchmark_noBiocar" ,['G2 (Glob_LowCons) - previous Sc. - baseline','G2 (Glob_LowCons_Clim) - previous Sc. - climat','G2 (Glob_LowCons) - no biocar. - baseline','G2 (Glob_LowCons_Clim) - no biocar. - climat'],"Energy inensity of GDP (Mtoe/$2001)",[  [21.0,95.0,167.0], [231.0,71.0,40.0], [21.0,95.0,167.0], [231.0,71.0,40.0] ],1,-0.40,-0.30,linestyle=style_line)
#GDP europe
benchmark_indexes=[dimCOMBI.index('6'),dimCOMBI.index('106'),dimCOMBI.index('1006'),dimCOMBI.index('1106')]
data_2plot=prepareArray2plot( GDP_PPP_real[benchmark_indexes,dimREG.index('EUR')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outputDirs+"GDP_europe_benchmark_noBiocar" ,['G2 (Glob_LowCons) - previous Sc. - baseline','G2 (Glob_LowCons_Clim) - previous Sc. - climat','G2 (Glob_LowCons) - no biocar. - baseline','G2 (Glob_LowCons_Clim) - no biocar. - climat'],"GDP ($2001)",[  [21.0,95.0,167.0], [231.0,71.0,40.0], [21.0,95.0,167.0], [231.0,71.0,40.0] ],1,-0.40,-0.30,linestyle=style_line)
#GDP world
benchmark_indexes=[dimCOMBI.index('6'),dimCOMBI.index('106'),dimCOMBI.index('1006'),dimCOMBI.index('1106')]
data_2plot=prepareArray2plot( GDP_PPP_real.sum(axis=1)[benchmark_indexes][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outputDirs+"GDP_world_benchmark_noBiocar" ,['G2 (Glob_LowCons) - previous Sc. - baseline','G2 (Glob_LowCons_Clim) - previous Sc. - climat','G2 (Glob_LowCons) - no biocar. - baseline','G2 (Glob_LowCons_Clim) - no biocar. - climat'],"GDP ($2001)",[  [21.0,95.0,167.0], [231.0,71.0,40.0], [21.0,95.0,167.0], [231.0,71.0,40.0] ],1,-0.40,-0.30,linestyle=style_line)
#wp_et
benchmark_indexes=[dimCOMBI.index('6'),dimCOMBI.index('106'),dimCOMBI.index('1006'),dimCOMBI.index('1106')]
data_2plot=prepareArray2plot( wpEner[benchmark_indexes,dimWENER.index('Et')][:,tptScale],timeset[tptScale])
linePlot(data_2plot,outputDirs+"world_et_price__benchmark_noBiocar" ,['G2 (Glob_LowCons) - previous Sc. - baseline','G2 (Glob_LowCons_Clim) - previous Sc. - climat','G2 (Glob_LowCons) - no biocar. - baseline','G2 (Glob_LowCons_Clim) - no biocar. - climat'],"Fuel price ($/Mtoe)",[  [21.0,95.0,167.0], [231.0,71.0,40.0], [21.0,95.0,167.0], [231.0,71.0,40.0] ],1,-0.40,-0.30,linestyle=style_line)


#####################
### TABLES
#####################
# macro variables
datesRanges = [ [2010, 2100], [2010, 2040], [2040, 2080], [2080, 2100] ]
firstLine = ['\hline ']
cutPeriod = list()
for elt1 in datesRanges:
	cutPeriodElt = list()
	firstLineStr = ''
	for elt2 in elt1:
		cutPeriodElt.append(elt2 - int(dimYEAR[0]))
		firstLineStr = firstLineStr + str(elt2) + '-'
	firstLineStr = firstLineStr[:-1]
	firstLine.append(firstLineStr)
	cutPeriod.append(cutPeriodElt)
firstLine[-1] = firstLine[-1] + ' \\\\'
beginTabularTex = '\\begin{tabular}{'
beginTabularTex = beginTabularTex + ' l'
for col in range(len(datesRanges)):
	beginTabularTex = beginTabularTex + ' c'
beginTabularTex = beginTabularTex + '}'
endTabularTex = '\\end{tabular}'

# Europe GPD - baseline
fileout = open('./table_gdp_europe_baseline.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for scenar in range(len(combi_baseline)):
	listy = list()
	listy.append('\hline ' + combi_header_tab[scenar])
	for rang in range(len(cutPeriod)):
		listy.append(str(np.round(100*np.mean(growth_PPP_real[scenar,dimREG.index('EUR'),cutPeriod[rang][0]:cutPeriod[rang][1]]), decimals=2)) + '\%')
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()
# World GPD- baseline
fileout = open('./table_gdp_world_baseline.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for scenar in range(len(combi_baseline)):
	listy = list()
	listy.append('\hline ' + combi_header_tab[scenar])
	for rang in range(len(cutPeriod)):
		listy.append(str(np.round(100*np.mean(growth_PPP_real_world[scenar,cutPeriod[rang][0]:cutPeriod[rang][1]]), decimals=2)) + '\%')
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()
# Europe fluid GPD- baseline
fileout = open('./table_fluid_gdp_europe_baseline.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for scenar in range(len(combi_baseline)):
	listy = list()
	listy.append('\hline ' + combi_header_tab[scenar])
	for rang in range(len(cutPeriod)):
		if np.mean(growth_PPP_real[scenar,dimREG.index('EUR'),cutPeriod[rang][0]:cutPeriod[rang][1]]) > np.mean(growth_GDP_fluid_reg[scenar,dimREG.index('EUR'),cutPeriod[rang][0]:cutPeriod[rang][1]]):
			listy.append('$>$')
		else: listy.append('$<$')
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()
# World fluid GPD- baseline
fileout = open('./table_fluid_gdp_world_baseline.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for scenar in range(len(combi_baseline)):
	listy = list()
	listy.append('\hline ' + combi_header_tab[scenar])
	for rang in range(len(cutPeriod)):
		if np.mean(growth_PPP_real_world[scenar,cutPeriod[rang][0]:cutPeriod[rang][1]]) > np.mean(growth_GDP_fluid_reg[scenar,dimREG.index('EUR'),cutPeriod[rang][0]:cutPeriod[rang][1]]):
			listy.append('$>$')
		else: listy.append('$<$')
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()


# Europe GPD - climat
fileout = open('./table_gdp_europe_climat.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for scenar in range(len(combi_climat)):
	listy = list()
	listy.append('\hline ' + combi_header_tab_clim[scenar])
	for rang in range(len(cutPeriod)):
		listy.append(str(np.round(100*np.mean(growth_PPP_real[scenar,dimREG.index('EUR'),cutPeriod[rang][0]:cutPeriod[rang][1]]), decimals=2)) + '\%')
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()
# World GPD- climat
fileout = open('./table_gdp_world_climat.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for scenar in range(len(combi_climat)):
	listy = list()
	listy.append('\hline ' + combi_header_tab_clim[scenar])
	for rang in range(len(cutPeriod)):
		listy.append(str(np.round(100*np.mean(growth_PPP_real_world[scenar,cutPeriod[rang][0]:cutPeriod[rang][1]]), decimals=2)) + '\%')
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()
# Europe fluid GPD- climat
fileout = open('./table_fluid_gdp_europe_climat.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for scenar in range(len(combi_climat)):
	listy = list()
	listy.append('\hline ' + combi_header_tab_clim[scenar])
	for rang in range(len(cutPeriod)):
		if np.mean(growth_PPP_real[scenar,dimREG.index('EUR'),cutPeriod[rang][0]:cutPeriod[rang][1]]) > np.mean(growth_GDP_fluid_reg[scenar,dimREG.index('EUR'),cutPeriod[rang][0]:cutPeriod[rang][1]]):
			listy.append('$>$')
		else: listy.append('$<$')
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()
# World fluid GPD- climat
fileout = open('./table_fluid_gdp_world_climat.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for scenar in range(len(combi_climat)):
	listy = list()
	listy.append('\hline ' + combi_header_tab_clim[scenar])
	for rang in range(len(cutPeriod)):
		if np.mean(growth_PPP_real_world[scenar,cutPeriod[rang][0]:cutPeriod[rang][1]]) > np.mean(growth_GDP_fluid_reg[scenar,dimREG.index('EUR'),cutPeriod[rang][0]:cutPeriod[rang][1]]):
			listy.append('$>$')
		else: listy.append('$<$')
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()




# Energy intensity - baseline
gdp_EnerIntensity =  energy_balance_stock.sum(axis=2).sum(axis=2)[:,dimCONSENER.index('Final_consumption')] / GDP_PPP_real.sum(axis=1)
degrowth_GDPenergyIntensity = (gdp_EnerIntensity[:,1:]  -  gdp_EnerIntensity[:,0:(len(timeset)-1)]) / gdp_EnerIntensity[:,1:]
fileout = open('./table_GDPenergyIntensity_world_baseline.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for scenar in range(len(combi_baseline)):
	listy = list()
	listy.append('\hline ' + combi_header_tab[scenar])
	for rang in range(len(cutPeriod)):
		listy.append(str(np.round(100*np.mean(degrowth_GDPenergyIntensity[scenar,cutPeriod[rang][0]:cutPeriod[rang][1]]), decimals=2)) + '\%')
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()
# Energy intensity - climat
fileout = open('./table_GDPenergyIntensity_world_climat.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for scenar in range(len(combi_climat)):
	listy = list()
	listy.append('\hline ' + combi_header_tab_clim[scenar])
	for rang in range(len(cutPeriod)):
		listy.append(str(np.round(100*np.mean(degrowth_GDPenergyIntensity[scenar,cutPeriod[rang][0]:cutPeriod[rang][1]]), decimals=2)) + '\%')
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()

####################################
# out of fuel in residential heating

firstLine = copy.deepcopy(dimREG)
firstLine.insert(0,'\hline ')
firstLine[-1] = firstLine[-1] + ' \\\\'
beginTabularTex = '\\begin{tabular}{'
beginTabularTex = beginTabularTex + 'l'
for col in range(len(dimREG)):
	beginTabularTex = beginTabularTex + ' c'
beginTabularTex = beginTabularTex + '}'

# more than 1300 table (for baseline scenarios)
fileout = open('./table_outFromFuel_1300_residential_baseline.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for combi in range(len(combi_baseline)):
	listy = list()
	listy.append('\hline ' + combi_header_tab[combi])
	for region in range(len(dimREG)):
		listy.append(str(min(np.where(pArmDF_nexus[combi,region,dimSEC.index('Et'),:]>1300)[0]) + int(dimYEAR[0])))
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()
# more than 1000 table (for baseline scenarios)
fileout = open('./table_outFromFuel_1000_residential_baseline.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for combi in range(len(combi_baseline)):
	listy = list()
	listy.append('\hline ' + combi_header_tab[combi])
	for region in range(len(dimREG)):
		listy.append(str(min(np.where(pArmDF_nexus[combi,region,dimSEC.index('Et'),:]>1000)[0]) + int(dimYEAR[0])))
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()
# more than 1300 table (for climat scenarios)
fileout = open('./table_outFromFuel_1300_residential_climat.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for combi in range(len(combi_climat)):
	listy = list()
	listy.append('\hline ' + combi_header_tab_clim[combi])
	for region in range(len(dimREG)):
		listy.append(str(min(np.where(pArmDF_nexus[combi,region,dimSEC.index('Et'),:]>1300)[0]) + int(dimYEAR[0])))
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()
# more than 1000 table (for climat scenarios)
fileout = open('./table_outFromFuel_1000_residential_climat.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for combi in range(len(combi_climat)):
	listy = list()
	listy.append('\hline ' + combi_header_tab_clim[combi])
	for region in range(len(dimREG)):
		listy.append(str(min(np.where(pArmDF_nexus[combi,region,dimSEC.index('Et'),:]>1000)[0]) + int(dimYEAR[0])))
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()

####################################
# reaching the industrial goods limit (consumption saturation)

firstLine = copy.deepcopy(dimREG)
firstLine.insert(0,'\hline ')
firstLine[-1] = firstLine[-1] + ' \\\\'
beginTabularTex = '\\begin{tabular}{'
beginTabularTex = beginTabularTex + 'l'
for col in range(len(dimREG)):
	beginTabularTex = beginTabularTex + ' c'
beginTabularTex = beginTabularTex + '}'

# high limit in baseline
fileout = open('./table_induGoods_highLimit_baseline.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for combi in range(len(combi_baseline)):
	listy = list()
	listy.append('\hline ' + combi_header_tab[combi])
	for region in range(len(dimREG)):
		whery = np.where(DF[combi,region,dimSEC.index('indu'),:] / Ltot[combi,region,:] > indusGoods_Limit_high[combi,region,:])[0]
		try:
			listy.append(str(min(whery) + int(dimYEAR[0])))
		except: listy.append('9999')
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()
# low limit in baseline
fileout = open('./table_induGoods_lowLimit_baseline.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for combi in range(len(combi_baseline)):
	listy = list()
	listy.append('\hline ' + combi_header_tab[combi])
	for region in range(len(dimREG)):
		whery = np.where(DF[combi,region,dimSEC.index('indu'),:] / Ltot[combi,region,:] > indusGoods_Limit_low[combi,region,:])[0]
		try:
			listy.append(str(min(whery) + int(dimYEAR[0])))
		except: listy.append('9999')
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()
# high limit in climat
fileout = open('./table_induGoods_highLimit_climat.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for combi in range(len(combi_climat)):
	listy = list()
	listy.append('\hline ' + combi_header_tab_clim[combi])
	for region in range(len(dimREG)):
		whery = np.where(DF[combi,region,dimSEC.index('indu'),:] / Ltot[combi,region,:] > indusGoods_Limit_high[combi,region,:])[0]
		try:
			listy.append(str(min(whery) + int(dimYEAR[0])))
		except: listy.append('9999')
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()
# low limit in climat
fileout = open('./table_induGoods_lowLimit_climat.tex', "wb")
dataout = csv.writer(fileout,delimiter='&')
dataout.writerow([beginTabularTex])
dataout.writerow(firstLine)
for combi in range(len(combi_climat)):
	listy = list()
	listy.append('\hline ' + combi_header_tab_clim[combi])
	for region in range(len(dimREG)):
		whery = np.where(DF[combi,region,dimSEC.index('indu'),:] / Ltot[combi,region,:] > indusGoods_Limit_low[combi,region,:])[0]
		try:
			listy.append(str(min(whery) + int(dimYEAR[0])))
		except: listy.append('9999')
	listy[-1] = listy[-1] + '\\\\'
	dataout.writerow(listy)
dataout.writerow(['\hline'])
dataout.writerow([endTabularTex])
fileout.close()


print 'yeah baby'

