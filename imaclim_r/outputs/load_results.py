# -*- coding: utf-8 -*-

import sys
sys.path.append('../externals/pdfExtraction/py/')
from functions import *

execfile('../externals/common_code/python/load_normalized_imaclim.py')
execfile('../externals/common_code/python/Hodrick_Prescott_filter.py')

# data path
dataPath = './'

# load indexes
indexes = ['dimREG','dimSEC','dimYEAR','dimCOMBI','dimCONSENER','dimENER','dimWENER','dimELEC','dimUSAGE']
for elt in indexes:
	str2exec= elt + '=load_indexes_imaclim(dataPath + \''+elt+'.csv\')'
	exec(str2exec)
	exec('global ' + elt)

# load and filter datas
datasource = open(dataPath+'emf33_outputs.csv','r')
varnames_list = get_varnames_list(datasource)
for elt in varnames_list:
	str2exec = elt + '= load_results_imaclim(datasource,\'' + elt+ '\')'
	exec(str2exec)
	if elt != 'CI':
		str2exec = elt + '= hpfilter_matrix(' + elt+ ',6.25)'
		exec(str2exec)

#info
print 'CI is [combi, region, output sectors, input sectors, year]'

# other vector
timeset=[]
for elt in dimYEAR:
	timeset.append(float(elt))
timeset = np.array(timeset)

# prerequist indices
energy_firstInd = dimSEC.index('coal')
energy_lastInd  = dimSEC.index('elec') +1
transport_firstInd = dimSEC.index('air')
transport_lastInd = dimSEC.index('OT') +1
# transform variables
pkmautomobileref = np.repeat(pkmautomobileref,len(dimYEAR),axis=1)
pkmautomobileref = pkmautomobileref.reshape([len(dimCOMBI),len(dimREG),len(dimYEAR)]) #check that
pkmautomobile = Tautomobile * pkmautomobileref / 100
wp = np.repeat(wp,Imp.shape[1],axis=1)
wp = wp.reshape(Imp.shape) 
wp = np.swapaxes(wp,1,2) #because that between those two axis, the first that has been repeated
wpTIagg = np.repeat(wpTIagg,Imp.shape[2],axis=0)
wpTIagg = wpTIagg.reshape(Imp[:,0,:,:].shape)
wpTIagg = np.repeat(wpTIagg,Imp.shape[1],axis=1)
wpTIagg = wpTIagg.reshape(Imp.shape)
wpTIagg = np.swapaxes(wpTIagg,1,2)
# prerequist variables
ExpValue = Exp * p
ImpValue = Imp * ( (np.ones(Imp.shape)+mtax)*wp + nit*wpTIagg )
Investment = pK * DeltaK
charge = Q/Cap
alphaCI_FinalEnergy_fret = CI[:,:,transport_firstInd:transport_lastInd,energy_firstInd:energy_lastInd,:].sum(axis=3)
quantityCI = CI * np.repeat(Q,CI.shape[3],axis=1).reshape(CI.shape)
FinalEnergy_fret =  np.swapaxes(np.repeat(alphaCI_FinalEnergy_fret,CI.shape[2],axis=2).reshape(CI[:,:,transport_firstInd:transport_lastInd,:,:].shape),2,3)  *  quantityCI[:,:,:,transport_firstInd:transport_lastInd,:]

# on transport energy content
transport_legend = ['Fuel in personnal vehicles', 'Electricity in personnal vehicles','Air passengers', 'Public transport', 'Inland freight','Other freight']
fuel_personal_car = alphaEtauto * pkmautomobile
elec_personal_car = alphaelecauto * pkmautomobile
air_passenger_ener = DF[:,:,dimSEC.index('air'),:] * alphaCI_FinalEnergy_fret[:,:,0,:]
public_trans_ener = DF[:,:,dimSEC.index('OT'),:] * alphaCI_FinalEnergy_fret[:,:,2,:]
inland_freight_ener = Q[:,:,dimSEC.index('OT'),:] * alphaCI_FinalEnergy_fret[:,:,2,:] - public_trans_ener
other_freight_ener = Q[:,:,dimSEC.index('mer'),:] * alphaCI_FinalEnergy_fret[:,:,1,:]  + Q[:,:,dimSEC.index('air'),:] * alphaCI_FinalEnergy_fret[:,:,0,:] - air_passenger_ener
Transport_Energy = np.zeros(np.concatenate(([6],air_passenger_ener.shape)))
Transport_Energy[0] = fuel_personal_car
Transport_Energy[1] = elec_personal_car
Transport_Energy[2] = air_passenger_ener
Transport_Energy[3] = public_trans_ener
Transport_Energy[4] = inland_freight_ener
Transport_Energy[5] = other_freight_ener
# on transport emission content
alphaEmissions_FinalEnergy_fret_dim1 = (CI*coef_Q_CO2_CI)[:,:,transport_firstInd:transport_lastInd,energy_firstInd:energy_lastInd,:]
alphaEmissions_FinalEnergy_fret_dim2 = alphaEmissions_FinalEnergy_fret_dim1 * np.swapaxes( ( np.repeat((CI)[:,:,energy_firstInd:energy_lastInd,energy_firstInd:energy_lastInd,:].sum(axis=3),3,axis=2).reshape([16,12,5,3,100])
) , 2 , 3)
alphaEmissions_FinalEnergy_fret = alphaEmissions_FinalEnergy_fret_dim1.sum(axis=3) +  alphaEmissions_FinalEnergy_fret_dim2.sum(axis=3)
Transport_CO2 = np.zeros(Transport_Energy.shape)
Transport_CO2 = np.zeros(Transport_Energy.shape)
Transport_CO2[0] = fuel_personal_car * coef_Q_CO2_DF[:,:,dimSEC.index('Et'),:] + fuel_personal_car * (CI*coef_Q_CO2_CI)[:,:,dimSEC.index('Et'),energy_firstInd:energy_lastInd,:].sum(axis=2)
Transport_CO2[1] = elec_personal_car * coef_Q_CO2_DF[:,:,dimSEC.index('elec'),:] + elec_personal_car * (CI*coef_Q_CO2_CI)[:,:,dimSEC.index('elec'),energy_firstInd:energy_lastInd,:].sum(axis=2)
Transport_CO2[2] = DF[:,:,dimSEC.index('air'),:] * alphaEmissions_FinalEnergy_fret[:,:,0,:]
Transport_CO2[3] = DF[:,:,dimSEC.index('OT'),:] * alphaEmissions_FinalEnergy_fret[:,:,2,:]
Transport_CO2[4] = Q[:,:,dimSEC.index('OT'),:] * alphaEmissions_FinalEnergy_fret[:,:,2,:]  - Transport_CO2[3]
Transport_CO2[5] = Q[:,:,dimSEC.index('mer'),:] * alphaEmissions_FinalEnergy_fret[:,:,1,:] + Q[:,:,dimSEC.index('air'),:] * alphaEmissions_FinalEnergy_fret[:,:,0,:]  - Transport_CO2[2]

#Transport_Energy = [ alphaEtauto, alphaelecauto, air_passenger_ener, common_trans_ener, inland_freight_ener, other_freight_ener]
# on transport emissions

# GDP growth
growth_PPP_real = (GDP_PPP_real[:,:,1:]  -  GDP_PPP_real[:,:,0:(len(timeset)-1)]) / GDP_PPP_real[:,:,1:]
growth_PPP_real_world = (GDP_PPP_real.sum(axis=1)[:,1:]  -  GDP_PPP_real.sum(axis=1)[:,0:(len(timeset)-1)]) / GDP_PPP_real.sum(axis=1)[:,1:]
work_productivity = np.ones(l[:,:,0,:].shape) / l[:,:,0,:]
work_productivity_growth = (work_productivity[:,:,1:]  -  work_productivity[:,:,0:(len(timeset)-1)]) / work_productivity[:,:,1:]
Pop_growth = (Ltot[:,:,1:]  -  Ltot[:,:,0:(len(timeset)-1)]) / Ltot[:,:,1:]
GDP_fluid = GDP_PPP_real*np.ones(GDP_PPP_real.shape)
growth_GDP_fluid_reg = work_productivity_growth + Pop_growth
for ii in range((GDP_fluid.shape[2]-1)):
	GDP_fluid[:,:,ii+1] = GDP_fluid[:,:,ii] + GDP_fluid[:,:,ii] * growth_GDP_fluid_reg[:,:,ii]
growth_GDP_fluid_world = (GDP_fluid.sum(axis=1)[:,1:]  -  GDP_fluid.sum(axis=1)[:,0:(len(timeset)-1)]) / GDP_fluid.sum(axis=1)[:,1:]

# pArmDF_nexus
shapeTemp = list(pArmDF.shape)
shapeTemp[-1] = shapeTemp[-1] + 3
pArmDF_temp = np.zeros(shapeTemp)
pArmDF_temp[:,:,:,3:] = pArmDF
for ii in range(3): pArmDF_temp[:,:,:,ii] = pArmDF[:,:,:,0]
pArmDF_nexus = np.zeros(pArmDF.shape)
for tpt in range(pArmDF_nexus.shape[-1]):
	pArmDF_nexus[:,:,:,tpt] = pArmDF_temp[:,:,:,tpt:(tpt+3+1)].sum(axis=3) / 4

# limit on good consumption
hdf_cff_low = np.array([1.2, 1.2, 1.2, 1.2, 2, 2, 2, 2, 2, 2, 2, 2])
hdf_cff_low = np.repeat(hdf_cff_low,len(dimCOMBI),axis=0)
hdf_cff_low = hdf_cff_low.reshape([len(dimREG),len(dimCOMBI)])
hdf_cff_low = np.swapaxes(hdf_cff_low,0,1)
hdf_cff_high = np.array([1.5, 1.5, 1.5, 1.5, 3, 3, 3, 3, 3, 3, 3, 3])
hdf_cff_high = np.repeat(hdf_cff_high,len(dimCOMBI),axis=0)
hdf_cff_high = hdf_cff_high.reshape([len(dimREG),len(dimCOMBI)])
hdf_cff_high = np.swapaxes(hdf_cff_high,0,1)

indusGoods_Limit_low = DF[:,:,dimSEC.index('indu'),0] / Ltot[:,:,0] * hdf_cff_low
indusGoods_Limit_high = DF[:,:,dimSEC.index('indu'),0] / Ltot[:,:,0] * hdf_cff_high
indusGoods_Limit_low = np.repeat(indusGoods_Limit_low,len(dimYEAR),axis=1)
indusGoods_Limit_low = indusGoods_Limit_low.reshape(Ltot.shape) 
indusGoods_Limit_high = np.repeat(indusGoods_Limit_high,len(dimYEAR),axis=1)
indusGoods_Limit_high = indusGoods_Limit_high.reshape(Ltot.shape) 


