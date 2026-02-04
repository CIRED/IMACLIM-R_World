counterLine=1;
//	Population|	million
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=Ltot(k)/1e6;
counterLine=counterLine+1;
//	GDP|MER	billion billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= GDP_MER_real(k)/ 1e3*usd2001_2005;
counterLine=counterLine+1;
//	GDP|PPP	billion billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=GDP_PPP_constant(k)/ 1e3*usd2001_2005;
counterLine=counterLine+1;
//	Primary Energy	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=(sum(energy_balance(tpes_eb,primary_eb,k)))*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Fossil|	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=(sum(energy_balance(tpes_eb,fossil_primary_eb,k)))*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Fossil|w/ CCS	EJ/yr 
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = Mtoe_EJ * (..
- energy_balance(losses_eb,coal_eb,k) * share_CCS_CTL(k)    .. // autoconsommation de charbon dans la production de charbon pour le CTL
- energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k)    .. // raffineries (ctl)
- energy_balance(pwplant_eb,coal_eb,k) * sh_CCS_col_Q_col(k) .. // coal to elec
- energy_balance(pwplant_eb,gaz_eb,k) * sh_CCS_gaz_Q_gaz(k) .. // gaz to elec
);
counterLine=counterLine+1;
//	Primary Energy|Fossil|w/o CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= Mtoe_EJ * (..
sum(energy_balance(tpes_eb,fossil_primary_eb,k)) ..
- (..
- energy_balance(losses_eb,coal_eb,k) * share_CCS_CTL(k)    .. // autoconsommation de charbon dans la production de charbon pour le CTL
- energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k)    .. // raffineries (ctl)
- energy_balance(pwplant_eb,coal_eb,k) * sh_CCS_col_Q_col(k) .. // coal to elec
- energy_balance(pwplant_eb,gaz_eb,k) * sh_CCS_gaz_Q_gaz(k) ..  // gaz to elec
)..
);
counterLine=counterLine+1;
//	Primary Energy|Coal|	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=energy_balance(tpes_eb,coal_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Coal|w/ CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (..
- energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k) .. // raffineries (ctl)
- energy_balance(losses_eb,coal_eb,k) * share_CCS_CTL(k) .. // autoconsommation de charbon dans la production de charbon pour le CTL
- energy_balance(pwplant_eb,coal_eb,k) * sh_CCS_col_Q_col(k) .. // coal to elec
)*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Coal|w/o CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (..
energy_balance(tpes_eb,coal_eb,k) ..
- (..
- energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k) .. // raffineries (ctl)
- energy_balance(losses_eb,coal_eb,k) * share_CCS_CTL(k) .. // autoconsommation de charbon dans la production de charbon pour le CTL
- energy_balance(pwplant_eb,coal_eb,k) * sh_CCS_col_Q_col(k) .. // coal to elec
)..
)*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Oil	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=energy_balance(tpes_eb,oil_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Oil|w/ CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Primary Energy|Oil|w/o CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = energy_balance(tpes_eb,oil_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Gas| EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(tpes_eb,gaz_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Gas|w/ CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= - energy_balance(pwplant_eb,gaz_eb) * sh_CCS_gaz_Q_gaz(k) * Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Gas|w/o CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=(..
energy_balance(tpes_eb,gaz_eb,k) ..
- ( - energy_balance(pwplant_eb,gaz_eb)) * sh_CCS_gaz_Q_gaz(k) ..
)*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = - energy_balance(refi_eb,enr_eb,k) * Mtoe_EJ + sum(qBiomExaJ(k,:));
counterLine=counterLine+1;
//	Primary Energy|Biomass|w/ CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = qBiomExaJ(k,2);
counterLine=counterLine+1;
//	Primary Energy|Biomass|w/o CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = - energy_balance(refi_eb,enr_eb,k) * Mtoe_EJ + qBiomExaJ(k,1);
counterLine=counterLine+1;
// Primary Energy|Biomass|Modern        EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = - energy_balance(refi_eb,enr_eb,k) * Mtoe_EJ + sum(qBiomExaJ(k,:));
counterLine=counterLine+1;
// Primary Energy|Biomass|Traditional   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Primary Energy|Nuclear	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = energy_balance(tpes_eb,nuc_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Non-Biomass Renewables (including hydro)	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(msh_elec_techno(k,technoNonBiomassRen)./[1 1 1 1 1 1 1]) * Q(k,elec)*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Hydro	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(msh_elec_techno(k,technoElecHydro)./[1 1]) * Q(k,elec)*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Wind	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(msh_elec_techno(k,technoWind)./[1 1]) * Q(k,elec)*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Solar	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(msh_elec_techno(k,technoSolar)./[1 1 1]) * Q(k,elec)*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Geothermal	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Primary Energy|Ocean	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Primary Energy|Secondary Energy Trade (Imports-Exports)|Total	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= ..
-(energy_balance(imp_eb,et_eb,k)   + energy_balance(exp_eb,et_eb,k))*Mtoe_EJ ..
-(energy_balance(imp_eb,elec_eb,k) + energy_balance(exp_eb,elec_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//	Primary Energy|Other	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = 0;
counterLine=counterLine+1;
//  Secondary Energy EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(pwplant_eb,elec_eb,k)+ energy_balance(refi_eb,et_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=energy_balance(pwplant_eb,elec_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Coal EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoElecCoal))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Coal|w/ CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoCoalWCCS)) *  Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Coal|w/o CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoCoalWOCCS)) * Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Oil	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoOil))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Oil|w/ CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=%nan;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Oil|w/o CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoOil))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Gas	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoElecGas))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Gas|w/ CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoGasWCCS))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Gas|w/o CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoGasWOCCS))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoBiomass))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Biomass|w/ CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,indice_BIGCCS))*Mtoe_EJ; 
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Biomass|w/o CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,indice_BIGCC))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Nuclear	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoElecNuke))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Non-Biomass Renewables	(including hydro) EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoNonBiomassRen))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Hydro	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoElecHydro))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Solar	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoSolar))*Mtoe_EJ;
counterLine=counterLine+1;
//  Secondary Energy|Electricity|Solar|PV   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoPV))*Mtoe_EJ;
counterLine=counterLine+1;
//  Secondary Energy|Electricity|Solar|CSP  EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * msh_elec_techno(k,indice_CSP)*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Wind	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoWind))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Wind|Onshore	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,[indice_WND]))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Wind|Offshore	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,[indice_WNO]))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Geothermal	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Ocean	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Secondary Energy|Electricity|Other	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = 0;
counterLine=counterLine+1;
//Secondary Energy|Hydrogen
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Secondary Energy|Liquids    EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Liquids|Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=share_biofuel(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Liquids|Biomass|w/ CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Secondary Energy|Liquids|Biomass|w/o CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=share_biofuel(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Liquids|Fossil EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (share_CTL(k)+share_oil_refin(k)) * energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Liquids|Fossil|w/ CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= share_CCS_CTL(k) * share_CTL(k) * energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Liquids|Fossil|w/o CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = ( (1 - share_CCS_CTL(k)) * share_CTL(k)+share_oil_refin(k)) * energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Liquids|Coal	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=share_CTL(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Liquids|Gas	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Secondary Energy|Liquids|Oil	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = share_oil_refin(k) * energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Liquids|Other	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Secondary Energy|Gases	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=(energy_balance(tpes_eb,gaz_eb,k) + energy_balance(losses_eb,gaz_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Gases|Natural gas	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=(energy_balance(tpes_eb,gaz_eb,k) + energy_balance(pwplant_eb,gaz_eb,k) + energy_balance(losses_eb,gaz_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//	Secondary Energy|Gases|Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Gases|Coal
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Gases|Other
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Solids
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Solids|Coal
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Solids|Biomass
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Heat
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Heat|Coal
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Heat|Oil
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Heat|Gas
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Heat|Biomass
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Heat|Solar
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Heat|Geothermal
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Heat|Nuclear
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Heat|Other
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Secondary Energy|Other Carrier
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Secondary Energy|Other Carrier|Coal
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Secondary Energy|Other Carrier|Oil
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Secondary Energy|Other Carrier|Gas
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Secondary Energy|Other Carrier|Biomass
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Secondary Energy|Other Carrier|Non-Biomass Renewables
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Secondary Energy|Other Carrier|Nuclear
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Secondary Energy|Other Carrier|Other
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Final Energy	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=(sum(energy_balance(conso_tot_eb,:,k)))*Mtoe_EJ;
counterLine=counterLine+1;
//	Final Energy|Industry	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=(sum(energy_balance(conso_indu_eb,:,k))+sum(energy_balance(conso_agri_eb,:,k))+sum(energy_balance(conso_btp_eb,:,k)))*Mtoe_EJ;
counterLine=counterLine+1;
//	Final Energy|Residential and Commercial	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=(sum(energy_balance(conso_comp_eb,:,k))+sum(energy_balance(conso_resid_eb,:,k)))*Mtoe_EJ;
counterLine=counterLine+1;
//	Final Energy|Transportation	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=(sum(energy_balance(conso_transport_eb,:,k)))*Mtoe_EJ;
counterLine=counterLine+1;
// Final Energy|Transportation|Passenger   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (..
energy_balance(conso_car_eb,et_eb,k) ..
+ (energy_balance(conso_ot_eb,et_eb,k)*DF(k,indice_OT )/(Q(k,indice_OT )-Exp(k,indice_OT )+Imp(k,indice_OT )))..
+ (energy_balance(conso_air_eb,et_eb,k)*DF(k,indice_air)/(Q(k,indice_air)-Exp(k,indice_air)+Imp(k,indice_air)))..
) * Mtoe_EJ;
counterLine=counterLine+1;
// Final Energy|Transportation|Freight EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (..
+ energy_balance(conso_ot_eb,et_eb,k) * (1 - DF(k,indice_OT )/(Q(k,indice_OT )-Exp(k,indice_OT )+Imp(k,indice_OT )))..
+ energy_balance(conso_air_eb,et_eb,k) * (1 - DF(k,indice_air)/(Q(k,indice_air)-Exp(k,indice_air)+Imp(k,indice_air)))..
) * Mtoe_EJ;
counterLine=counterLine+1;
// Final Energy|Other Sector
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(energy_balance(conso_btp_eb,:,k))*Mtoe_EJ;
counterLine=counterLine+1;
//	Final Energy|Solids EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=energy_balance(conso_tot_eb,coal_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Final Energy|Solids|Coal	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=energy_balance(conso_tot_eb,coal_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Final Energy|Solids|Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= %nan;
counterLine=counterLine+1;
//	Final Energy|Solids|Traditional Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Final Energy|Liquids	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=energy_balance(conso_tot_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Final Energy|Gases	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=energy_balance(conso_tot_eb,gaz_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Final Energy|Electricity	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=energy_balance(conso_tot_eb,elec_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//	Final Energy|Hydrogen	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Final Energy|Heat	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Final Energy|Other
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Energy Service|Transportation|Passenger bn pkm/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (Tair(k) + Tautomobile(k) + TOT(k) + TNM(k)) * pkmautomobileref(k) / 100 / 1e9;
counterLine=counterLine+1;
//Energy Service|Transportation|Freight   bn tkm/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Emissions|CO2	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (sum(E_reg_use(k,:)) + emi_evitee(k))/1e6;
counterLine=counterLine+1;
// Emissions|CO2|Fossil Fuels and Industry	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= sum(E_reg_use(k,:))/1e6 + emi_evitee(k)/1e6;
counterLine=counterLine+1;
// Emissions|CO2|Fossil Fuels and Industry|Energy Supply Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= sum(E_reg_use(k,iu_ener))/1e6 + emi_evitee(k)/1e6;
counterLine=counterLine+1;
// Emissions|CO2|Fossil Fuels and Industry|Energy Supply|Electricity Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= E_reg_use(k,iu_elec)/1e6 + emi_evitee(k)/1e6;
counterLine=counterLine+1;
//Emissions|CO2|Fossil Fuels and Industry|Energy Demand
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= sum(E_reg_use(k,iu_non_ener))/1e6;
counterLine=counterLine+1;
//Emissions|CO2|Fossil Fuels and Industry|Energy Demand|Industry
//Includes Agriculture
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (E_reg_use(k,iu_indu) + E_reg_use(k,iu_agri))/1e6;
counterLine=counterLine+1;
//Emissions|CO2|Fossil Fuels and Industry|Energy Demand|Residential and Commercial
//On n'utilise pas E_reg_use(iu_DF) car DF inclut cars et resid 
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (..
+ coef_Q_CO2_DF(k,coal)       .* energy_balance(conso_resid_eb,coal_eb,k) ..
+ coef_Q_CO2_DF(k,oil)        .* energy_balance(conso_resid_eb,oil_eb,k)  ..
+ coef_Q_CO2_DF(k,gaz)        .* energy_balance(conso_resid_eb,gaz_eb,k)  ..
+ coef_Q_CO2_DF(k,et)         .* energy_balance(conso_resid_eb,et_eb,k)   ..
+ coef_Q_CO2_CI(coal,compo,k) .* energy_balance(conso_comp_eb, coal_eb,k) ..
+ coef_Q_CO2_CI(oil,compo,k)  .* energy_balance(conso_comp_eb, oil_eb,k) ..
+ coef_Q_CO2_CI(gaz,compo,k)  .* energy_balance(conso_comp_eb, gaz_eb,k)  ..
+ coef_Q_CO2_CI(et,compo,k)   .* energy_balance(conso_comp_eb, et_eb,k)   ..
)/1e6;
counterLine=counterLine+1;
//Emissions|CO2|Fossil Fuels and Industry|Energy Demand|Transportation
//On n'utilise pas E_reg_use(iu_DF) pour cars car DF inclut cars et resid 
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (..
+ coef_Q_CO2_DF(k,coal).* energy_balance(conso_car_eb,coal_eb,k) ..
+ coef_Q_CO2_DF(k,oil) .* energy_balance(conso_car_eb,oil_eb,k)  ..
+ coef_Q_CO2_DF(k,gaz) .* energy_balance(conso_car_eb,gaz_eb,k)  ..
+ coef_Q_CO2_DF(k,et)  .* energy_balance(conso_car_eb,et_eb,k)   ..
+ E_reg_use(k,iu_air) ..
+ E_reg_use(k,iu_mer) ..
+ E_reg_use(k,iu_OT)  ..
)/1e6;
counterLine=counterLine+1;
//Emissions|CO2|Fossil Fuels and Industry|Energy Demand|Other Sector
//Autre secteur : construction (btp)
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = E_reg_use(k,iu_cons)/1e6;
counterLine=counterLine+1;
// Emissions|CO2|Land-Use	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Emissions|CO2|Carbon capture and storage
// Captured and stored emissions (hence the - before emi_evitee)
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= ( ..
+ coef_Q_CO2_ref(k,coal) * (..
- energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k) ..
+ energy_balance(pwplant_eb,elec_eb)* sum(msh_elec_techno(k,[indice_PSS indice_CGS])) ..
- energy_balance(losses_eb,coal_eb,k)* share_CCS_CTL(k)..
) ..
- coef_Q_CO2_ref(k,et)  * energy_balance(losses_eb,et_eb,k) * share_CCS_CTL(k) ..
- coef_Q_CO2_ref(k,oil) * energy_balance(losses_eb,oil_eb,k) * share_CCS_CTL(k) ..
+ coef_Q_CO2_ref(k,gaz) * (..
- energy_balance(refi_eb,   gaz_eb,k) * share_CCS_CTL(k) ..
- energy_balance(losses_eb, gaz_eb,k) * share_CCS_CTL(k) ..
+ energy_balance(pwplant_eb,elec_eb)  * sum(msh_elec_techno(k,[indice_GGS])) ..
) ..
- emi_evitee(k,:) ..
)/1e6; 
counterLine=counterLine+1;
//	Emissions|N2O|Total	kt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Emissions|CH4|Total	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Emissions|F-gases|Total	Mt CO2-equiv/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Emissions|Kyoto gases|Total	Mt CO2-equiv/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
////Emissions|GHG|International Trading System
//counterLine=counterLine+1;
//	Concentration|CO2	ppm
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Concentration|CH4	ppb
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Concentration|N2O	ppb
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Forcing	W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Forcing|AN3A	W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Forcing|Kyoto Gases	W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//	Price|Carbon	US$2005/t CO2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=taxCO2_DF(k)*1e6*usd2001_2005;
counterLine=counterLine+1;
//	Price|Primary Energy|Oil	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=p(k,indice_oil)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//	Price|Primary Energy|Natural Gas	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=p(k,indice_gaz)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//	Price|Primary Energy|Coal	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=p(k,indice_coal)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//	Price|Secondary Energy|Liquids|Oil	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=pArmCI(indice_Et,indice_industrie,k)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//	Price|Secondary Energy|Gases|Natural Gas US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=pArmCI(indice_gaz,indice_industrie,k)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//	Price|Secondary Energy|Solids|Coal US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=pArmCI(indice_coal,indice_industrie,k)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//	Price|Secondary Energy|Solids|Biomass US$2005/GJ
if sum(prod_elec_techno(k,technoBiomass)) + prod_BFU(k)==0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
else
    qBiom = (msh_elec_techno(k,indice_BIGCC) / rho_elec_nexus(k,indice_BIGCC) ..
    + msh_elec_techno(k,indice_BIGCCS) / rho_elec_nexus(k,indice_BIGCCS))..
    * energy_balance(pwplant_eb,8,k);
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=(..
    prod_BFU(k) *  pArmCI(indice_Et,indice_industrie,k) ..
    +  costBIGCC_noTax(k) * qBiom..
    ) * usd2001_2005 / tep2gj ..
    / (qBiom + prod_BFU(k));
end
counterLine=counterLine+1;
//	Price|Primary Energy|Biomass	US$2005/GJ
if sum(prod_elec_techno(k,technoBiomass)) + prod_BFU(k)==0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
else
    qBiom = (msh_elec_techno(k,indice_BIGCC) / rho_elec_nexus(k,indice_BIGCC) ..
    + msh_elec_techno(k,indice_BIGCCS) / rho_elec_nexus(k,indice_BIGCCS))..
    * energy_balance(pwplant_eb,8,k);
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=(prod_BFU(k) *  p(k,et) + costBIGCC_noTax(k) * qBiom) * usd2001_2005 / tep2gj ..
    /(qBiom + prod_BFU(k));
end
counterLine=counterLine+1;
//	Price|Secondary Energy|Electricity
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=pArmCI(indice_elec,indice_industrie,k)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//	Consumption	(households) billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=(sum(DF(k,:).*pArmDF(k,:)))/1e3*usd2001_2005;
counterLine=counterLine+1;
//LCOE|Electricity|Coal|w CCS   US$2005/MWh
if sum(msh_elec_techno(k,technoCoalWCCS)) ~=0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(lcoeNoTax(k,technoCoalWCCS).*msh_elec_techno(k,technoCoalWCCS)) ..
    ./ sum(msh_elec_techno(k,technoCoalWCCS)) ..
    * usd2001_2005 * 1e3;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
//LCOE|Electricity|Coal|w/o CCS   US$2005/MWh
if sum(msh_elec_techno(k,technoCoalWOCCS)) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(lcoeNoTax(k,technoCoalWOCCS).*msh_elec_techno(k,technoCoalWOCCS)) ..
    ./ sum(msh_elec_techno(k,technoCoalWOCCS))..
    * usd2001_2005 * 1e3;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
//LCOE|Electricity|Gas|w CCS   US$2005/MWh
if sum(msh_elec_techno(k,technoGasWCCS)) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(lcoeNoTax(k,technoGasWCCS).*msh_elec_techno(k,technoGasWCCS)) ..
    ./ sum(msh_elec_techno(k,technoGasWCCS)) ..
    * usd2001_2005 * 1e3;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
//LCOE|Electricity|Gas|w/o CCS   US$2005/MWh
if sum(msh_elec_techno(k,technoGasWOCCS)) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(lcoeNoTax(k,technoGasWOCCS).*msh_elec_techno(k,technoGasWOCCS)) ..
    ./ sum(msh_elec_techno(k,technoGasWOCCS)) ..
    * usd2001_2005 * 1e3;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
//LCOE|Electricity|Nuclear   US$2005/MWh
if sum(msh_elec_techno(k,technoElecNuke)) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(lcoeNoTax(k,technoElecNuke).*msh_elec_techno(k,technoElecNuke)) ..
    ./ sum(msh_elec_techno(k,technoElecNuke)) ..
    * usd2001_2005 * 1e3;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
//LCOE|Electricity|Non-Biomass Renewables   US$2005/MWh
if sum(msh_elec_techno(k,technoNonBiomassRen)) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(lcoeNoTax(k,technoNonBiomassRen).*msh_elec_techno(k,technoNonBiomassRen)) ..
    ./ sum(msh_elec_techno(k,technoNonBiomassRen)) ..
    * usd2001_2005 * 1e3;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
//LCOE|Electricity|Solar|Marginal   US$2005/MWh
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//LCOE|Electricity|Solar|Average   US$2005/MWh
if sum(msh_elec_techno(k,technoSolar)) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(lcoeNoTax(k,technoSolar).*msh_elec_techno(k,technoSolar)) ..
    ./ sum(msh_elec_techno(k,technoSolar)) ..
    * 1e3* usd2001_2005;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
//LCOE|Electricity|Wind|Marginal   US$2005/MWh
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//LCOE|Electricity|Wind|Average   US$2005/MWh
if sum(msh_elec_techno(k,technoWind)) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(lcoeNoTax(k,technoWind).*msh_elec_techno(k,technoWind)) ..
    ./ sum(msh_elec_techno(k,technoWind)) ..
    * usd2001_2005 * 1e3;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
//LCOE|Electricity|Biomass|w/ CCS   US$2005/MWh
if msh_elec_techno(k,indice_BIGCCS) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = lcoeNoTax(k,indice_BIGCCS) * usd2001_2005 * 1e3;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
//LCOE|Electricity|Biomass|w/o CCS   US$2005/MWh
if msh_elec_techno(k,indice_BIGCC) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = lcoeNoTax(k,indice_BIGCC) * usd2001_2005 * 1e3;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
if ind_climat ~= 0
    //	Policy Cost|Area under MAC Curve|Total	billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
    counterLine=counterLine+1;
    //	Policy Cost|GDP Loss|Total	billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = - (GDP_MER_real(k) - GDP_base_MER_real(k,current_time_im+1)) / 1e3*usd2001_2005;
    counterLine=counterLine+1;
    //	Policy Cost|Consumption Loss|Total	billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = - ( sum(DF(k,:).*pArmDF(k,:)) - sum(base_DF(k,:,current_time_im+1) .* base_pArmDF(k,:,current_time_im+1)))/1e3*usd2001_2005;
    counterLine=counterLine+1;
    //	Policy Cost|Equivalent Variation    billion US$2005/yr 
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan; // fixme
    counterLine=counterLine+1;
    //	Policy Cost|Additional total energy system cost	billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (energyInvestment(k) - energyInvestment_base(k,current_time_im+1)) / 1e3 * usd2001_2005;
    counterLine=counterLine+1;
    //	Policy Cost|Other|Total	billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
    counterLine=counterLine+1;
else
    //	Policy Cost|Area under MAC Curve|Total	billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
    counterLine=counterLine+1;
    //  Policy Cost|GDP Loss|Total  billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
    counterLine=counterLine+1;
    //  Policy Cost|Consumption Loss|Total  billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
    counterLine=counterLine+1;
    //	Policy Cost|Equivalent Variation    billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
    counterLine=counterLine+1;
    //	Policy Cost|Additional Total energy System Cost	billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
    counterLine=counterLine+1;
    //  Policy Cost|Other billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
    counterLine=counterLine+1;
end
//	Trade|Primary Energy|Coal|Volume (Exports-Imports) EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= -(energy_balance(imp_eb,coal_eb,k) + energy_balance(exp_eb,coal_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//	Trade|Primary Energy|Gas|Volume	(Exports-Imports) EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= -(energy_balance(imp_eb,gaz_eb,k) + energy_balance(exp_eb,gaz_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//	Trade|Primary Energy|Oil|Volume	(Exports-Imports) EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= -(energy_balance(imp_eb,oil_eb,k) + energy_balance(exp_eb,oil_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
// Trade|Secondary Energy|Solids and Liquids|Biomass|Volume
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= %nan;
counterLine=counterLine+1;
// Trade|SecondaryEnergy|Electricity|Volume
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= -(energy_balance(imp_eb,elec_eb,k) + energy_balance(exp_eb,elec_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
// Trade|Secondary Energy|Other|Volume
counterLine=counterLine+1;
// Capital Cost|Electricity|Coal|IGCC|w/o CCS   $/kW
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = CINV_MW_nexus(k,indice_ICG) * usd2001_2005;
counterLine=counterLine+1;
// Efficiency|Electricity|Coal|IGCC|w/o CCS| efficiency
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = rho_elec_nexus(k,indice_ICG);
counterLine=counterLine+1;
// Capital Cost|Electricity|Gas|CC|w/o CCS $/kW
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = CINV_MW_nexus(k,indice_GGC) * usd2001_2005;
counterLine=counterLine+1;
// Efficiency|Electricity|Gas|CC|w/o CCS    efficiency
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = rho_elec_nexus(k,indice_GGC);
counterLine=counterLine+1;
// Capital Cost|Electricity|Solar|PV   $/kW
if (msh_elec_techno(k,indice_CPV)+ msh_elec_techno(k,indice_RPV)) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (..
    CINV_MW_nexus(k,indice_CPV) * msh_elec_techno(k,indice_CPV)..
    + CINV_MW_nexus(k,indice_RPV) * msh_elec_techno(k,indice_RPV))..
    / (msh_elec_techno(k,indice_CPV) + msh_elec_techno(k,indice_RPV))* usd2001_2005;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end

counterLine=counterLine+1;
// Capital Cost|Electricity|Solar|CSP    $/kW
if msh_elec_techno(k,indice_CSP) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = ..
    CINV_MW_nexus(k,indice_CSP) * msh_elec_techno(k,indice_CSP)..
    / msh_elec_techno(k,indice_CSP)* usd2001_2005;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
// Capital Cost|Electricity|Nuclear $/kW
if (msh_elec_techno(k,indice_NUC) + msh_elec_techno(k,indice_NND)) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (..
    CINV_MW_nexus(k,indice_NUC) * msh_elec_techno(k,indice_NUC)..
    + CINV_MW_nexus(k,indice_NND) * msh_elec_techno(k,indice_NND)..
    ) / (msh_elec_techno(k,indice_NUC) + msh_elec_techno(k,indice_NND)) * usd2001_2005;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
//Capital Cost|Electricity|Wind|Onshore $/kW
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = CINV_MW_nexus(k,indice_WND) * usd2001_2005;
counterLine=counterLine+1;   
//Emissions|GHG|Allowance Allocation MtCO2
counterLine=counterLine+1;
//Trade|Emissions Allowances|Value billion US$2005/yr
counterLine=counterLine+1;
//Trade|Emissions Allowances|Volume EJ/yr
counterLine=counterLine+1;
// Resource|Cumulative extraction|Coal EJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = Q_cum_coal(k)*Mtoe_EJ;
counterLine=counterLine+1;
// Resource|Cumulative extraction|Gas EJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = Q_cum_gaz(k)*Mtoe_EJ;
counterLine=counterLine+1;
// Resource|Cumulative extraction|Gas|Conventional EJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = Q_cum_gaz(k)*Mtoe_EJ;
counterLine=counterLine+1;
// Resource|Cumulative extraction|Gas|Unconventional EJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Resource|Cumulative extraction|Oil EJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (Q_cum_oil_poles(k,1) + sum(Q_cum_oil(k,:)) + sum(Q_cum_heavy(k,:)) + sum(Q_cum_shale(k,:)))*Mtoe_EJ;
counterLine=counterLine+1;
// Resource|Cumulative extraction|Oil|Conventional EJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (Q_cum_oil_poles(k,1) + sum(Q_cum_oil(k,:)))*Mtoe_EJ;
counterLine=counterLine+1;
// Resource|Cumulative extraction|Oil|Unconventional EJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (sum(Q_cum_heavy(k,:)) + sum(Q_cum_shale(k,:)))*Mtoe_EJ;
counterLine=counterLine+1;
// Resource|Cumulative extraction|Uranium EJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Investment|Energy Supply  billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (pK(k,coal).*DeltaK(k,coal) + pK(k,oil).*DeltaK(k,oil)..
+ pK(k,gaz).*DeltaK(k,gaz) + pK(k,et).*DeltaK(k,et) + pK(k,elec).*DeltaK(k,elec))*usd2001_2005/1000;
counterLine=counterLine+1;
// Investment|Energy Supply|Electricity  billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (pK(k,elec).*DeltaK(k,elec))*usd2001_2005/1000;
counterLine=counterLine+1;
// Trade|All|Value   billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (sum(Exp(k,:).*p(k,:).*(1+xtax(k,:)))-sum(Imp(k,:).*wp))/1e3*usd2001_2005;
counterLine=counterLine+1;
//Emissions|Sulfur    Mt SO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|BC    Mt BC/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|OC    Mt OC/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|NOx   Mt NO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|CO    Mt CO/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|Sulfur|Energy Supply|Electricity  Mt SO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|Sulfur|Energy Supply and Demand   Mt SO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|Sulfur|Land Use   Mt SO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|BC|Energy Supply|Electricity  Mt BC/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|BC|Energy Supply and Demand   Mt BC/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|BC|Land Use   Mt BC/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|OC|Energy Supply|Electricity  Mt OC/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|OC|Energy Supply and Demand   Mt OC/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|OC|Land Use   Mt OC/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|NOx|Energy Supply|Electricity Mt NO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|NOx|Energy Supply and Demand  Mt NO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|NOx|Land Use  Mt NO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|CO|Energy Supply|Electricity  Mt CO/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|CO|Energy Supply and Demand   Mt CO/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|CO|Land Use   Mt CO/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Forcing|Montreal Gases  W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Forcing|CO2 W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Forcing|CH4 W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Forcing|N2O W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Forcing|F-Gases W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Forcing|Aerosol W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Forcing|Aerosol|Sulfate Direct  W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Forcing|Aerosol|Cloud Indirect  W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Forcing|Aerosol|BC and OC   W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Forcing|Aerosol|Other   W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Forcing|Tropospheric Ozone  W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Forcing|Other   W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Forcing|Albedo Change and Mineral Dust  W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Forcing|Aerosol|Nitrate Direct  W/m2
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Temperature|Global Mean  °C
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//LCOE|Liquids|Oil    US$2005/MWh
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//LCOE|Liquids|Biomass|w/ CCS US$2005/MWh
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//LCOE|Liquids|Biomass|w/o CCS    US$2005/MWh
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//LCOE|Liquids|Coal|w/ CCS    US$2005/MWh
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//LCOE|Liquids|Coal|w/o CCS   US$2005/MWh
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Land Cover  million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Land Cover|Cropland million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Land Cover|Pasture  million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Land Cover|Forest   million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Land Cover|Other Land   million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Land Cover|Forest|Managed   million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Land Cover|Cropland|Energy Crops    million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Land Cover|Other Arable Land    million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|CH4|Energy Supply and Demand  Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|CH4|Land Use  Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|CH4|Other  Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|N2O|Energy Supply and Demand  kt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|N2O|Land Use  kt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|N2O|Other  kt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|CO2|Land Use|Soil Carbon  Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Emissions|CO2|Carbon Capture and Storage|Biomass    Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = - emi_evitee(k) / 1e6;
counterLine=counterLine+1;
//Price|Secondary Energy|Liquids|Biomass  US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = p(k,et) * usd2001_2005 / tep2gj ;
counterLine=counterLine+1;
//Price|Agriculture|Non-Energy Crops|Index    Index (2005 = 1)
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = p(k,agri) / pref(k,agri);
counterLine=counterLine+1;
//Trade|Primary Energy|Biomass|Volume EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Primary Energy|Biomass|Energy Crops EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = - energy_balance(refi_eb,enr_eb,k) * Mtoe_EJ + sum(qBiomExaJ(k,:));
counterLine=counterLine+1;
//Primary Energy|Biomass|1st Generation   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Primary Energy|Biomass|Residues EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Primary Energy|Biomass|Other    EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Primary Energy|Biomass|Electricity  EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(qBiomExaJ(k,:));
counterLine=counterLine+1;
//Primary Energy|Biomass|Electricity|w/ CCS   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = qBiomExaJ(k,2);
counterLine=counterLine+1;
//Primary Energy|Biomass|Liquids  EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = - energy_balance(refi_eb,enr_eb,k) * Mtoe_EJ;
counterLine=counterLine+1;
//Primary Energy|Biomass|Liquids|w/ CCS   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = 0;
counterLine=counterLine+1;
//Primary Energy|Biomass|Gases    EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Primary Energy|Biomass|Hydrogen EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Primary Energy|Biomass|Hydrogen|w/ CCS  EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Liquids|Biomass|Energy Crops   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)=share_biofuel(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//Secondary Energy|Liquids|Biomass|Residues   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Liquids|Biomass|1st Generation EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Electricity|Biomass|Energy Crops   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoBiomass))*Mtoe_EJ;
counterLine=counterLine+1;
//Secondary Energy|Electricity|Biomass|Residues   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Electricity|Biomass|Other  EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Liquids|Biomass|Other  EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Primary Energy Production|Biomass|Energy Crops
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = - energy_balance(refi_eb,enr_eb,k) * Mtoe_EJ + sum(qBiomExaJ(k,:));
counterLine=counterLine+1;
// Primary Energy Production|Biomass|1st Generation
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Food Energy Demand
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Food Energy Demand|Livestock 
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Final Energy|Industry|Solids
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_indu_eb,coal_eb,k)+energy_balance(conso_agri_eb,coal_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Industry|Solids|Coal
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_indu_eb,coal_eb,k)+energy_balance(conso_agri_eb,coal_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Industry|Solids|Biomass
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= %nan;
counterLine=counterLine+1;
//Final Energy|Industry|Liquids
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_indu_eb,oil_eb,k)+energy_balance(conso_indu_eb,et_eb,k)+energy_balance(conso_agri_eb,oil_eb,k) + energy_balance(conso_agri_eb,et_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Industry|Gases
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_indu_eb,gaz_eb,k)+energy_balance(conso_agri_eb,gaz_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Industry|Electricity
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_indu_eb,elec_eb,k)+energy_balance(conso_agri_eb,elec_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Industry|Hydrogen  EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Final Energy|Industry|Heat  EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Final Energy|Industry|Other
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= 0;
counterLine=counterLine+1;
//Final Energy|Residential and Commercial|Solids
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_resid_eb,coal_eb,k)+energy_balance(conso_comp_eb,coal_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Residential and Commercial|Solids|Coal
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_resid_eb,coal_eb,k)+energy_balance(conso_comp_eb,coal_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Residential and Commercial|Solids|Biomass
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= %nan;
counterLine=counterLine+1;
//Final Energy|Residential and Commercial|Liquids
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_resid_eb,oil_eb,k)+energy_balance(conso_resid_eb,et_eb,k)+energy_balance(conso_comp_eb,oil_eb,k) + energy_balance(conso_comp_eb,et_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Residential and Commercial|Gases
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_resid_eb,gaz_eb,k)+energy_balance(conso_comp_eb,gaz_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Residential and Commercial|Electricity
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_resid_eb,elec_eb,k)+energy_balance(conso_comp_eb,elec_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
// Final Energy|Residential and Commercial|Hydrogen   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
// Final Energy|Residential and Commercial|Heat   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Final Energy|Residential and Commercial|Other
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= 0;
counterLine=counterLine+1;
//Final Energy|Transportation|Liquids
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (energy_balance(conso_air_eb,et_eb,k)+energy_balance(conso_ot_eb,et_eb,k)+energy_balance(conso_car_eb,et_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Transportation|Gases   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (energy_balance(conso_air_eb,gaz_eb,k)+energy_balance(conso_ot_eb,gaz_eb,k)+energy_balance(conso_car_eb,gaz_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Transportation|Hydrogen
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Final Energy|Transportation|Electricity
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (energy_balance(conso_air_eb,elec_eb,k)+energy_balance(conso_ot_eb,elec_eb,k)+energy_balance(conso_car_eb,elec_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Transportation|Other
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = 0;
counterLine=counterLine+1;
//Final Energy|Other Sector|Solids
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_btp_eb,coal_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Other Sector|Solids|Coal //btp
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_btp_eb,coal_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Other Sector|Solids|Biomass //btp
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= 0;
counterLine=counterLine+1;
//Final Energy|Other Sector|Liquids //btp
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_btp_eb,oil_eb,k)+energy_balance(conso_btp_eb,et_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Other Sector|Gases //btp
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_btp_eb,gaz_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//Final Energy|Other Sector|Electricity //btp
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= (energy_balance(conso_btp_eb,elec_eb,k))*Mtoe_EJ;
counterLine=counterLine+1; 
//Final Energy|Other Sector|Hydrogen  EJ/yr
counterLine=counterLine+1;
//Final Energy|Other Sector|Heat  EJ/yr
counterLine=counterLine+1;
//Final Energy|Other Sector|Other //btp
outputs_temp(nbLines*(k-1)+counterLine,current_time_im)= 0;
counterLine=counterLine+1;
//Price|Final Energy|Industry|Solids|Coal|w/ Taxes    US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = pArmCI(coal,indice_industrie,k)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//Price|Final Energy|Industry|Solids|Biomass|w/ Taxes US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Price|Final Energy|Industry|Liquids|w/ Taxes    US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = pArmCI(et,indice_industrie,k)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//Price|Final Energy|Industry|Gases|w/ Taxes  US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = pArmCI(gaz,indice_industrie,k)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//Price|Final Energy|Industry|Electricity|w/ Taxes    US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = pArmCI(elec,indice_industrie,k)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//Price|Final Energy|Industry|Hydrogen|w/ Taxes   US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Price|Final Energy|Industry|Heat|w/ Taxes   US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Price|Final Energy|Residential and Commercial|Solids|Coal|w/ Taxes  US$2005/GJ
outSec = coal;
if (DF(k,outSec) + CI(outSec,compo,k) * Q(k,compo)) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (DF(k,outSec) * pArmDF(k,outSec) + pArmCI(outSec,compo,k) * CI(outSec,compo,k) * Q(k,compo)) ..
    / (DF(k,outSec) + CI(outSec,compo,k) * Q(k,compo)) ..
    * usd2001_2005/tep2gj;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
//Price|Final Energy|Residential and Commercial|Solids|Biomass|w/ Taxes   US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Price|Final Energy|Residential and Commercial|Liquids|w/ Taxes  US$2005/GJ
outSec = et;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (DF(k,outSec) * pArmDF(k,outSec) + pArmCI(outSec,compo,k) * CI(outSec,compo,k) * Q(k,compo)) ..
/ (DF(k,outSec) + CI(outSec,compo,k) * Q(k,compo)) ..
* usd2001_2005/tep2gj;
counterLine=counterLine+1;
//Price|Final Energy|Residential and Commercial|Gases|w/ Taxes    US$2005/GJ
outSec = gaz;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (DF(k,outSec) * pArmDF(k,outSec) + pArmCI(outSec,compo,k) * CI(outSec,compo,k) * Q(k,compo)) ..
/ (DF(k,outSec) + CI(outSec,compo,k) * Q(k,compo)) ..
* usd2001_2005/tep2gj;
counterLine=counterLine+1;
//Price|Final Energy|Residential and Commercial|Electricity|w/ Taxes  US$2005/GJ
outSec = elec;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = (DF(k,outSec) * pArmDF(k,outSec) + pArmCI(outSec,compo,k) * CI(outSec,compo,k) * Q(k,compo)) ..
/ (DF(k,outSec) + CI(outSec,compo,k) * Q(k,compo)) ..
* usd2001_2005/tep2gj;
counterLine=counterLine+1;
//Price|Final Energy|Residential and Commercial|Hydrogen|w/ Taxes US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Price|Final Energy|Residential and Commercial|Heat|w/ Taxes US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Price|Final Energy|Transportation|Liquids|w/ Taxes  US$2005/GJ
outSec = et;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = ..
sum(pArmCI(outSec,transportIndexes,k) .* CI(outSec,transportIndexes,k) .* Q(k,transportIndexes)) ..
/ sum(CI(outSec,transportIndexes,k) .* Q(k,transportIndexes)) ..
* usd2001_2005/tep2gj;
counterLine=counterLine+1;
//Price|Final Energy|Transportation|Gases|w/ Taxes    US$2005/GJ
outSec = gaz;
if (CI(outSec,transportIndexes,k) .* Q(k,transportIndexes)) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = ..
    sum(pArmCI(outSec,transportIndexes,k) .* CI(outSec,transportIndexes,k) .* Q(k,transportIndexes)) ..
    / sum(CI(outSec,transportIndexes,k) .* Q(k,transportIndexes)) ..
    * usd2001_2005/tep2gj;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
//Price|Final Energy|Transportation|Hydrogen|w/ Taxes US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Price|Final Energy|Transportation|Electricity|w/ Taxes  US$2005/GJ
outSec = elec;
if (CI(outSec,transportIndexes,k) .* Q(k,transportIndexes)) ~= 0
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = ..
    sum(pArmCI(outSec,transportIndexes,k) .* CI(outSec,transportIndexes,k) .* Q(k,transportIndexes)) ..
    / sum(CI(outSec,transportIndexes,k) .* Q(k,transportIndexes)) ..
    * usd2001_2005/tep2gj;
else
    outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
end
counterLine=counterLine+1;
//Secondary Energy|Hydrogen|Coal  EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Hydrogen|Coal|w/ CCS   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Hydrogen|Coal|w/o CCS  EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Hydrogen|Gas   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Hydrogen|Gas|w/ CCS    EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Hydrogen|Gas|w/o CCS   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Hydrogen|Biomass   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Hydrogen|Biomass|w/ CCS    EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Hydrogen|Biomass|w/o CCS   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Hydrogen|Nuclear   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Hydrogen|Solar EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Hydrogen|Electricity   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Secondary Energy|Hydrogen|Other EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Final Energy|Geothermal EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Final Energy|Solar  EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = energy_balance(conso_tot_eb,elec_eb,k)*Mtoe_EJ * sum(msh_elec_techno(k,technoSolar));
counterLine=counterLine+1;
//Capacity|Electricity|Solar|CSP  GW
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = Cap_elec_MW(k,indice_CSP)/1000;
counterLine=counterLine+1;
//Capacity|Electricity|Solar|PV   GW
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(Cap_elec_MW(k,technoPV))/1000;
counterLine=counterLine+1;
// Capacity|Electricity|Wind GW
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(Cap_elec_MW(k,technoWind))/1000;
counterLine=counterLine+1;
//Capacity|Electricity|Hydro  GW
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = sum(Cap_elec_MW(k,technoElecHydro))/1000;
counterLine=counterLine+1;
//Resource|Average Extraction Cost|Coal   US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Resource|Average Extraction Cost|Oil    US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Resource|Average Extraction Cost|Gas    US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = %nan;
counterLine=counterLine+1;
//Trade|Exports|Primary Energy|Coal|Volume    EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = Exp(k,coal) * Mtoe_EJ;
counterLine=counterLine+1;
//Trade|Exports|Primary Energy|Gas|Volume EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = Exp(k,gaz) * Mtoe_EJ;
counterLine=counterLine+1;
//Trade|Exports|Primary Energy|Oil|Volume EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = Exp(k,oil) * Mtoe_EJ;
counterLine=counterLine+1;
//Trade|Exports|Secondary Energy|Solids and Liquids|Biomass|Volume    EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = share_biofuel(k) * Exp(k,et);  // we assume here solid biomass is locally produced
counterLine=counterLine+1;
//Trade|Exports|SecondaryEnergy|Electricity|Volume    EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = Exp(k,elec) * Mtoe_EJ;
counterLine=counterLine+1;
//Trade|Exports|Secondary Energy|Other|Volume EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = Exp(k,et) * (1 - share_biofuel(k)) * Mtoe_EJ;
counterLine=counterLine+1;
//Trade|Imports|Primary Energy|Coal|Volume    EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = Imp(k,coal) * Mtoe_EJ;
counterLine=counterLine+1;
//Trade|Imports|Primary Energy|Gas|Volume EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = Imp(k,gaz) * Mtoe_EJ;
counterLine=counterLine+1;
//Trade|Imports|Primary Energy|Oil|Volume EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = Imp(k,oil) * Mtoe_EJ;
counterLine=counterLine+1;
//Trade|Imports|Secondary Energy|Solids and Liquids|Biomass|Volume    EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = share_biofuel(k) * Imp(k,et);  // we assume here solid biomass is locally produced
counterLine=counterLine+1;
//Trade|Imports|SecondaryEnergy|Electricity|Volume    EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) = Imp(k,elec) * Mtoe_EJ;
counterLine=counterLine+1;
//Trade|Imports|Secondary Energy|Other|Volume EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,current_time_im) =  Imp(k,et) * (1 - share_biofuel(k))  * Mtoe_EJ;
counterLine=counterLine+1;
