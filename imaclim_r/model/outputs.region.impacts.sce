// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

counterLine=1;
//1	Population															million
outputs_temp(nbLines*(k-1)+counterLine,i)=Ltot(k)/1e6;
counterLine=counterLine+1;
//2	GDP|MER																billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= GDP_MER_real(k)/ 1e3*usd2001_2005;
counterLine=counterLine+1;
//3	GDP|PPP	 															billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=GDP_PPP_real(k)/ 1e3*usd2001_2005;
counterLine=counterLine+1;
//4	Primary Energy															EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=(sum(energy_balance(tpes_eb,primary_eb,k)))*Mtoe_EJ;
counterLine=counterLine+1;
//5	Primary Energy|Fossil|													EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=(sum(energy_balance(tpes_eb,fossil_primary_eb,k)))*Mtoe_EJ;
counterLine=counterLine+1;
//6	Primary Energy|Fossil|w/ CCS												EJ/yr 
outputs_temp(nbLines*(k-1)+counterLine,i) = Mtoe_EJ * (..
    - energy_balance(losses_eb,coal_eb,k) * share_CCS_CTL(k)    .. // autoconsommation de charbon dans la production de charbon pour le CTL
    - energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k)    .. // raffineries (ctl)
    - energy_balance(pwplant_eb,coal_eb,k) * sh_CCS_col_Q_col(k) .. // coal to elec
    - energy_balance(pwplant_eb,gas_eb,k) * sh_CCS_gaz_Q_gaz(k) .. // gaz to elec
);
counterLine=counterLine+1;
//7	Primary Energy|Fossil|w/o CCS												EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= Mtoe_EJ * (..
    sum(energy_balance(tpes_eb,fossil_primary_eb,k)) ..
    - (..
    - energy_balance(losses_eb,coal_eb,k) * share_CCS_CTL(k)    .. // autoconsommation de charbon dans la production de charbon pour le CTL
    - energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k)    .. // raffineries (ctl)
    - energy_balance(pwplant_eb,coal_eb,k) * sh_CCS_col_Q_col(k) .. // coal to elec
    - energy_balance(pwplant_eb,gas_eb,k) * sh_CCS_gaz_Q_gaz(k) ..  // gaz to elec
    )..
);
counterLine=counterLine+1;
//8	Primary Energy|Coal|													EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=energy_balance(tpes_eb,coal_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//9	Primary Energy|Coal|w/ CCS												EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = (..
    - energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k) .. // raffineries (ctl)
    - energy_balance(losses_eb,coal_eb,k) * share_CCS_CTL(k) .. // autoconsommation de charbon dans la production de charbon pour le CTL
    - energy_balance(pwplant_eb,coal_eb,k) * sh_CCS_col_Q_col(k) .. // coal to elec
)*Mtoe_EJ;
counterLine=counterLine+1;
//10	Primary Energy|Coal|w/o CCS												EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = (..
    energy_balance(tpes_eb,coal_eb,k) ..
    - (..
    - energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k) .. // raffineries (ctl)
    - energy_balance(losses_eb,coal_eb,k) * share_CCS_CTL(k) .. // autoconsommation de charbon dans la production de charbon pour le CTL
    - energy_balance(pwplant_eb,coal_eb,k) * sh_CCS_col_Q_col(k) .. // coal to elec
    )..
)*Mtoe_EJ;
counterLine=counterLine+1;
//11	Primary Energy|Oil														EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=energy_balance(tpes_eb,oil_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//12	Primary Energy|Oil|w/ CCS												EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//13	Primary Energy|Oil|w/o CCS												EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = energy_balance(tpes_eb,oil_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//14	Primary Energy|Gas| 													EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(tpes_eb,gas_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//15	Primary Energy|Gas|w/ CCS												EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= - energy_balance(pwplant_eb,gas_eb) * sh_CCS_gaz_Q_gaz(k) * Mtoe_EJ;
counterLine=counterLine+1;
//16	Primary Energy|Gas|w/o CCS												EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=(..
    energy_balance(tpes_eb,gas_eb,k) ..
    - ( - energy_balance(pwplant_eb,gas_eb)) * sh_CCS_gaz_Q_gaz(k) ..
)*Mtoe_EJ;
counterLine=counterLine+1;
//17	Primary Energy|Biomass													EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = - energy_balance(refi_eb,enr_eb,k) * Mtoe_EJ + sum(qBiomExaJ(k,:));
counterLine=counterLine+1;
//18	Primary Energy|Biomass|w/ CCS												EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = qBiomExaJ(k,2);
counterLine=counterLine+1;
//19	Primary Energy|Biomass|w/o CCS											EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = - energy_balance(refi_eb,enr_eb,k) * Mtoe_EJ + qBiomExaJ(k,1);
counterLine=counterLine+1;
//20 Primary Energy|Biomass|Modern        										EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = - energy_balance(refi_eb,enr_eb,k) * Mtoe_EJ + sum(qBiomExaJ(k,:));
counterLine=counterLine+1;
//21 Primary Energy|Biomass|Traditional   										EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//22	Primary Energy|Nuclear													EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = energy_balance(tpes_eb,nuc_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//23	Primary Energy|Non-Biomass Renewables (including hydro)						EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(msh_elec_techno(k,technoNonBiomassRen)./[1 1 1 1 1 1 1]) * Q(k,elec)*Mtoe_EJ;
counterLine=counterLine+1;
//24	Primary Energy|Hydro													EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(msh_elec_techno(k,technoElecHydro)./[1 1]) * Q(k,elec)*Mtoe_EJ;
counterLine=counterLine+1;
//25	Primary Energy|Wind														EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(msh_elec_techno(k,technoWind)./[1 1]) * Q(k,elec)*Mtoe_EJ;
counterLine=counterLine+1;
//26	Primary Energy|Solar													EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(msh_elec_techno(k,technoSolar)./[1 1 1]) * Q(k,elec)*Mtoe_EJ;
counterLine=counterLine+1;
//27	Primary Energy|Geothermal												EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//28	Primary Energy|Ocean													EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//29	Primary Energy|Secondary Energy Trade (Imports-Exports)|Total					EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= ..
    -(energy_balance(imp_eb,et_eb,k)   + energy_balance(exp_eb,et_eb,k))*Mtoe_EJ ..
-(energy_balance(imp_eb,elec_eb,k) + energy_balance(exp_eb,elec_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//30	Primary Energy|Other													EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//31 Secondary Energy 														EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(pwplant_eb,elec_eb,k)+ energy_balance(refi_eb,et_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//32	Secondary Energy|Electricity												EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=energy_balance(pwplant_eb,elec_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//33	Secondary Energy|Electricity|Coal 											EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoElecCoal))*Mtoe_EJ;
counterLine=counterLine+1;
//34	Secondary Energy|Electricity|Coal|w/ CCS									EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoCoalWCCS)) *  Mtoe_EJ;
counterLine=counterLine+1;
//35	Secondary Energy|Electricity|Coal|w/o CCS									EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoCoalWOCCS)) * Mtoe_EJ;
counterLine=counterLine+1;
//36	Secondary Energy|Electricity|Oil											EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoOil))*Mtoe_EJ;
counterLine=counterLine+1;
//37	Secondary Energy|Electricity|Oil|w/ CCS										EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=%nan;
counterLine=counterLine+1;
//38	Secondary Energy|Electricity|Oil|w/o CCS									EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoOil))*Mtoe_EJ;
counterLine=counterLine+1;
//39	Secondary Energy|Electricity|Gas											EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoElecGas))*Mtoe_EJ;
counterLine=counterLine+1;
//40	Secondary Energy|Electricity|Gas|w/ CCS										EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoGasWCCS))*Mtoe_EJ;
counterLine=counterLine+1;
//41	Secondary Energy|Electricity|Gas|w/o CCS									EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoGasWOCCS))*Mtoe_EJ;
counterLine=counterLine+1;
//42	Secondary Energy|Electricity|Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoBiomass))*Mtoe_EJ;
counterLine=counterLine+1;
//43	Secondary Energy|Electricity|Biomass|w/ CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,indice_BIS))*Mtoe_EJ; 
counterLine=counterLine+1;
//44	Secondary Energy|Electricity|Biomass|w/o CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoBiomassWOCCS))*Mtoe_EJ;
counterLine=counterLine+1;
//45	Secondary Energy|Electricity|Nuclear	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoNuke))*Mtoe_EJ;
counterLine=counterLine+1;
//46	Secondary Energy|Electricity|Non-Biomass Renewables	(including hydro) EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoNonBiomassRen))*Mtoe_EJ;
counterLine=counterLine+1;
//47	Secondary Energy|Electricity|Hydro	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoElecHydro))*Mtoe_EJ;
counterLine=counterLine+1;
//48	Secondary Energy|Electricity|Solar	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoSolar))*Mtoe_EJ;
counterLine=counterLine+1;
//49  Secondary Energy|Electricity|Solar|PV   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoPV))*Mtoe_EJ;
counterLine=counterLine+1;
//50  Secondary Energy|Electricity|Solar|CSP  EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * msh_elec_techno(k,indice_CSP)*Mtoe_EJ;
counterLine=counterLine+1;
//51	Secondary Energy|Electricity|Wind	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoWind))*Mtoe_EJ;
counterLine=counterLine+1;
//52 Secondary Energy|Electricity|Wind|Onshore	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,[indice_WND]))*Mtoe_EJ;
counterLine=counterLine+1;
//53	Secondary Energy|Electricity|Geothermal	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//54	Secondary Energy|Electricity|Ocean	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//55	Secondary Energy|Electricity|Other	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//56 Secondary Energy|Hydrogen
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//57	Secondary Energy|Liquids    EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//58	Secondary Energy|Liquids|Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=share_biofuel(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//59 Secondary Energy|Electricity|Wind|Offshore	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,[indice_WNO]))*Mtoe_EJ;
counterLine=counterLine+1;
//60	Secondary Energy|Liquids|Biomass|w/ CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//61	Secondary Energy|Liquids|Biomass|w/o CCS	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=share_biofuel(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//62	Secondary Energy|Liquids|Coal	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=share_CTL(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//63 Secondary Energy|Liquids|Coal|w/ CCS
outputs_temp(nbLines*(k-1)+counterLine,i)=share_CTL(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//64 Secondary Energy|Liquids|Coal|w/o CCS
outputs_temp(nbLines*(k-1)+counterLine,i)=share_CTL(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//65 Secondary Energy|Liquids|Gas	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//66 Secondary Energy|Liquids|Gas|w/ CCS
outputs_temp(nbLines*(k-1)+counterLine,i)=share_CTL(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//67 Secondary Energy|Liquids|Gas|w/o CCS
outputs_temp(nbLines*(k-1)+counterLine,i)=share_CTL(k)*energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//68 Secondary Energy|Liquids|Oil	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = share_oil_refin(k) * energy_balance(refi_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//69 Secondary Energy|Liquids|Other	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//70 Secondary Energy|Gases	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=(energy_balance(tpes_eb,gas_eb,k) + energy_balance(losses_eb,gas_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//71 Secondary Energy|Gases|Natural gas	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=(energy_balance(tpes_eb,gas_eb,k) + energy_balance(pwplant_eb,gas_eb,k) + energy_balance(losses_eb,gas_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//72 Secondary Energy|Gases|Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//73 Secondary Energy|Gases|Coal
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//74 Secondary Energy|Gases|Other
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//75 Secondary Energy|Solids
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//76 Secondary Energy|Solids|Coal
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//77 Secondary Energy|Solids|Biomass
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//78 Secondary Energy|Heat
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//79 Secondary Energy|Other Carrier
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//80	Final Energy	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=(sum(energy_balance(conso_tot_eb,:,k)))*Mtoe_EJ;
counterLine=counterLine+1;
//81	Final Energy|Industry	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=(sum(energy_balance(conso_indu_eb,:,k))+sum(energy_balance(conso_agri_eb,:,k))+sum(energy_balance(conso_btp_eb,:,k)))*Mtoe_EJ;
counterLine=counterLine+1;
//82 Final Energy|Industry|Energy Intensive	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//83 Final Energy|Industry|Iron and Steel	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//84 Final Energy|Industry|Pulp and Paper	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//85 Final Energy|Industry|Chemicals and Petrochemicals	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//86 Final Energy|Industry|Non ferrous metals	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//87 Final Energy|Industry|Non metallic minerals	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//88 Final Energy|Industry|Other	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//89 Final Energy|Residential and Commercial and AFOFI	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//90	Final Energy|Residential and Commercial	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=(sum(energy_balance(conso_comp_eb,:,k))+sum(energy_balance(conso_resid_eb,:,k)))*Mtoe_EJ;
counterLine=counterLine+1;
//91 Final Energy|Residential and Commercial|Heat	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//92 Final Energy|Residential and Commercial|Lighting	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//93 Final Energy|Residential and Commercial|Heating	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//94 Final Energy|Residential and Commercial|Cooling	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//95 Final Energy|Residential and Commercial|Appliances	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//96 Final Energy|Residential and Commercial|Other	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//97 Final Energy|Residential	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//98 Final Energy|Commercial	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//99 Final Energy|AFOFI	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//100	Final Energy|Transportation	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=(sum(energy_balance(conso_transport_eb,:,k)))*Mtoe_EJ;
counterLine=counterLine+1;
//101 Final Energy|Transportation|Aviation	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//102 Final Energy|Transportation|Aviation|International	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//103 Final Energy|Transportation|Aviation|Domestic	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//104 Final Energy|Transportation|Road	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//105 Final Energy|Transportation|Road|Passenger	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//106 Final Energy|Transportation|Road|Freight	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//107 Final Energy|Transportation|Road|Passenger|LDV	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//108 Final Energy|Transportation|Rail	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//109 Final Energy|Transportation|Shipping	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//110 Final Energy|Transportation|Shipping|International	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//111 Final Energy|Transportation|Shipping|Domestic	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//112 Final Energy|Transportation|Other Sector	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//113 Final Energy|Transportation|Liquids|Oil	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//114 Final Energy|Transportation|Liquids|Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//115 Final Energy|Transportation|Gases|Natural Gas	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//116 Final Energy|Transportation|Electricity	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//117 Final Energy|Transportation|Hydrogen	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//118 Final Energy|Other Sector
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(energy_balance(conso_btp_eb,:,k))*Mtoe_EJ;
counterLine=counterLine+1;
//119	Final Energy|Solids EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=energy_balance(conso_tot_eb,coal_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//120	Final Energy|Solids|Coal	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=energy_balance(conso_tot_eb,coal_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//121	Final Energy|Solids|Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= %nan;
counterLine=counterLine+1;
//122	Final Energy|Solids|Traditional Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//123	Final Energy|Liquids	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=energy_balance(conso_tot_eb,et_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//124 Final Energy|Other Sector|Liquids|Oil	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//125 Final Energy|Other Sector|Liquids|Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//126	Final Energy|Gases	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=energy_balance(conso_tot_eb,gas_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//127	Final Energy|Electricity	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=energy_balance(conso_tot_eb,elec_eb,k)*Mtoe_EJ;
counterLine=counterLine+1;
//128	Final Energy|Hydrogen	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//129	Final Energy|Heat	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//130 Final Energy|Geothermal
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//131 Final Energy|Solar
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//132 Final Energy|Other
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//133 Emissions|CO2	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= (sum(E_reg_use(k,:)) + emi_evitee(k))/1e6;
counterLine=counterLine+1;
//134 Emissions|CO2|Energy and Industrial Processes	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//135 Emissions|CO2|AFOLU	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//136 Emissions|CO2|Energy|Supply	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(E_reg_use(k,iu_ener))/1e6 + emi_evitee(k)/1e6;
counterLine=counterLine+1;
//137 Emissions|CO2|Energy|Supply|Combustion	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//138 Emissions|CO2|Energy|Supply|Fugitive	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//139 Emissions|CO2|Energy|Supply|Electricity	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= E_reg_use(k,iu_elec)/1e6 + emi_evitee(k)/1e6;
counterLine=counterLine+1;
//140 Emissions|CO2|Energy|Supply|Heat	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//141 Emissions|CO2|Energy|Supply|Electricity and Heat	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//142 Emissions|CO2|Energy|Supply|Liquids	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//143 Emissions|CO2|Energy|Supply|Solids	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//144 Emissions|CO2|Energy|Supply|Gases	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//145 Emissions|CO2|Energy|Supply|Other Sector	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//146 Emissions|CO2|Industrial Processes	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//147 Emissions|CO2|Energy|Demand	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(E_reg_use(k,iu_non_ener))/1e6;;
counterLine=counterLine+1;
//148 Emissions|CO2|Energy|Demand|Industry	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = E_reg_use(k,iu_indu)/1e6;
counterLine=counterLine+1;
//149 Emissions|CO2|Energy|Demand|Industry|Energy Intensive	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//150 Emissions|CO2|Energy Demand|Industry|Iron and Steel	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//151 Emissions|CO2|Energy Demand|Industry|Pulp and Paper	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//152 Emissions|CO2|Energy Demand|Industry|Chemicals and Petrochemicals	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//153 Emissions|CO2|Energy Demand|Industry|Non ferrous metals	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//154 Emissions|CO2|Energy Demand|Industry|Non metallic minerals	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//155 Emissions|CO2|Energy Demand|Industry|Others	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//156 Emissions|CO2|Energy|Demand|Residential and Commercial and AFOFI	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//157 Emissions|CO2|Energy|Demand|Residential and Commercial	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= (..
    + coef_Q_CO2_DF(k,coal)       .* energy_balance(conso_resid_eb,coal_eb,k) ..
    + coef_Q_CO2_DF(k,oil)        .* energy_balance(conso_resid_eb,oil_eb,k)  ..
    + coef_Q_CO2_DF(k,gaz)        .* energy_balance(conso_resid_eb,gas_eb,k)  ..
    + coef_Q_CO2_DF(k,et)         .* energy_balance(conso_resid_eb,et_eb,k)   ..
    + coef_Q_CO2_CI(coal,compo,k) .* energy_balance(conso_comp_eb, coal_eb,k) ..
    + coef_Q_CO2_CI(oil,compo,k)  .* energy_balance(conso_comp_eb, oil_eb,k) ..
    + coef_Q_CO2_CI(gaz,compo,k)  .* energy_balance(conso_comp_eb, gas_eb,k)  ..
    + coef_Q_CO2_CI(et,compo,k)   .* energy_balance(conso_comp_eb, et_eb,k)   ..
)/1e6;
counterLine=counterLine+1;
//158 Emissions|CO2|Energy|Demand|Residential	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= (..
    + coef_Q_CO2_DF(k,coal)       .* energy_balance(conso_resid_eb,coal_eb,k) ..
    + coef_Q_CO2_DF(k,oil)        .* energy_balance(conso_resid_eb,oil_eb,k)  ..
    + coef_Q_CO2_DF(k,gaz)        .* energy_balance(conso_resid_eb,gas_eb,k)  ..
    + coef_Q_CO2_DF(k,et)         .* energy_balance(conso_resid_eb,et_eb,k)   ..
)/1e6;
counterLine=counterLine+1;
//159 Emissions|CO2|Energy|Demand|Residential|Heating	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//160 Emissions|CO2|Energy|Demand|Residential|Lighting	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//161 Emissions|CO2|Energy|Demand|Residential|Cooling	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//162 Emissions|CO2|Energy|Demand|Residential|Appliances	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//163 Emissions|CO2|Energy|Demand|Residential|Other	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//164 Emissions|CO2|Energy|Demand|Commercial	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= (..
    + coef_Q_CO2_CI(coal,compo,k) .* energy_balance(conso_comp_eb, coal_eb,k) ..
    + coef_Q_CO2_CI(oil,compo,k)  .* energy_balance(conso_comp_eb, oil_eb,k) ..
    + coef_Q_CO2_CI(gaz,compo,k)  .* energy_balance(conso_comp_eb, gas_eb,k)  ..
    + coef_Q_CO2_CI(et,compo,k)   .* energy_balance(conso_comp_eb, et_eb,k)   ..
)/1e6;
counterLine=counterLine+1;
//165 Emissions|CO2|Energy|Demand|AFOFI	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//166 Emissions|CO2|Energy|Demand|Transportation	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= (..
    + coef_Q_CO2_DF(k,coal).* energy_balance(conso_car_eb,coal_eb,k) ..
    + coef_Q_CO2_DF(k,oil) .* energy_balance(conso_car_eb,oil_eb,k)  ..
    + coef_Q_CO2_DF(k,gaz) .* energy_balance(conso_car_eb,gas_eb,k)  ..
    + coef_Q_CO2_DF(k,et)  .* energy_balance(conso_car_eb,et_eb,k)   ..
    + E_reg_use(k,iu_air) ..
    + E_reg_use(k,iu_mer) ..
    + E_reg_use(k,iu_OT)  ..
)/1e6;
counterLine=counterLine+1;
//167 Emissions|CO2|Energy|Demand|Transportation|Aviation	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) =  E_reg_use(k,iu_air)/1e6;
counterLine=counterLine+1;
//168 Emissions|CO2|Energy|Demand|Transportation|Aviation|International	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//169 Emissions|CO2|Energy|Demand|Transportation|Aviation|Domestic	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//170 Emissions|CO2|Energy|Demand|Transportation|Road, Rail and Domestic Shipping	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= (..
    + coef_Q_CO2_DF(k,coal).* energy_balance(conso_car_eb,coal_eb,k) ..
    + coef_Q_CO2_DF(k,oil) .* energy_balance(conso_car_eb,oil_eb,k)  ..
    + coef_Q_CO2_DF(k,gaz) .* energy_balance(conso_car_eb,gas_eb,k)  ..
    + coef_Q_CO2_DF(k,et)  .* energy_balance(conso_car_eb,et_eb,k)   ..
    + E_reg_use(k,iu_mer) ..
    + E_reg_use(k,iu_OT)  ..
)/1e6;
counterLine=counterLine+1;
//171 Emissions|CO2|Energy|Demand|Transportation|Road	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= (..
    + coef_Q_CO2_DF(k,coal).* energy_balance(conso_car_eb,coal_eb,k) ..
    + coef_Q_CO2_DF(k,oil) .* energy_balance(conso_car_eb,oil_eb,k)  ..
    + coef_Q_CO2_DF(k,gaz) .* energy_balance(conso_car_eb,gas_eb,k)  ..
    + coef_Q_CO2_DF(k,et)  .* energy_balance(conso_car_eb,et_eb,k)   ..
    + E_reg_use(k,iu_OT)  ..
)/1e6;
counterLine=counterLine+1;
//172 Emissions|CO2|Energy|Demand|Transportation|Passenger|Road	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= (..
    + coef_Q_CO2_DF(k,coal).* energy_balance(conso_car_eb,coal_eb,k) ..
    + coef_Q_CO2_DF(k,oil) .* energy_balance(conso_car_eb,oil_eb,k)  ..
    + coef_Q_CO2_DF(k,gaz) .* energy_balance(conso_car_eb,gas_eb,k)  ..
    + coef_Q_CO2_DF(k,et)  .* energy_balance(conso_car_eb,et_eb,k)   ..
    + E_reg_use(k,iu_OT)*DF(k,indice_OT )/(Q(k,indice_OT )-Exp(k,indice_OT )+Imp(k,indice_OT ))  ..
)/1e6;
counterLine=counterLine+1;
//173 Emissions|CO2|Energy|Demand|Transportation|Freight|Road	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = (E_reg_use(k,iu_OT)*(1-DF(k,indice_OT )/(Q(k,indice_OT )-Exp(k,indice_OT )+Imp(k,indice_OT ))))/1e6;
counterLine=counterLine+1;
//174 Emissions|CO2|Energy|Demand|Transportation|Passenger|Road|LDV	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= (..
    + coef_Q_CO2_DF(k,coal).* energy_balance(conso_car_eb,coal_eb,k) ..
    + coef_Q_CO2_DF(k,oil) .* energy_balance(conso_car_eb,oil_eb,k)  ..
    + coef_Q_CO2_DF(k,gaz) .* energy_balance(conso_car_eb,gas_eb,k)  ..
    + coef_Q_CO2_DF(k,et)  .* energy_balance(conso_car_eb,et_eb,k)   ..
)/1e6;
counterLine=counterLine+1;
//175 Emissions|CO2|Energy|Demand|Transportation|Rail	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//176 Emissions|CO2|Energy|Demand|Transportation|Shipping	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) =  E_reg_use(k,iu_mer)/1e6;
counterLine=counterLine+1;
//177 Emissions|CO2|Energy|Demand|Transportation|Shipping|International	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//178 Emissions|CO2|Energy|Demand|Transportation|Shipping|Domestic	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//179 Emissions|CO2|Energy|Demand|Transportation|Other Sector	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) =  %nan;
counterLine=counterLine+1;
//180 Emissions|CO2|Energy|Demand|Other Sector	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//181 Emissions|CO2|AFOLU|Land	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//182 Emissions|CO2|AFOLU|Agriculture	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//183 Emissions|CO2|Waste	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//184 Emissions|CO2|Other	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//185 Carbon Sequestration|CCS	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= ( ..
    + coef_Q_CO2_ref(k,coal) * (..
    - energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k) ..
    + energy_balance(pwplant_eb,elec_eb)* sum(msh_elec_techno(k,[indice_PSS indice_CGS])) ..
    - energy_balance(losses_eb,coal_eb,k)* share_CCS_CTL(k)..
    ) ..
    - coef_Q_CO2_ref(k,et)  * energy_balance(losses_eb,et_eb,k) * share_CCS_CTL(k) ..
    - coef_Q_CO2_ref(k,oil) * energy_balance(losses_eb,oil_eb,k) * share_CCS_CTL(k) ..
    + coef_Q_CO2_ref(k,gaz) * (..
    - energy_balance(refi_eb,   gas_eb,k) * share_CCS_CTL(k) ..
    - energy_balance(losses_eb, gas_eb,k) * share_CCS_CTL(k) ..
    + energy_balance(pwplant_eb,elec_eb)  * sum(msh_elec_techno(k,[indice_GGS])) ..
    ) ..
    - emi_evitee(k,:) ..
)/1e6; 
counterLine=counterLine+1;
//186 Carbon Sequestration|CCS|Biomass	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = emi_evitee(k) / 1e6;
counterLine=counterLine+1;
//187 Carbon Sequestration|CCS|Fossil	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= ( ..
    + coef_Q_CO2_ref(k,coal) * (..
    - energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k) ..
    + energy_balance(pwplant_eb,elec_eb)* sum(msh_elec_techno(k,[indice_PSS indice_CGS])) ..
    - energy_balance(losses_eb,coal_eb,k)* share_CCS_CTL(k)..
    ) ..
    - coef_Q_CO2_ref(k,et)  * energy_balance(losses_eb,et_eb,k) * share_CCS_CTL(k) ..
    - coef_Q_CO2_ref(k,oil) * energy_balance(losses_eb,oil_eb,k) * share_CCS_CTL(k) ..
    + coef_Q_CO2_ref(k,gaz) * (..
    - energy_balance(refi_eb,   gas_eb,k) * share_CCS_CTL(k) ..
    - energy_balance(losses_eb, gas_eb,k) * share_CCS_CTL(k) ..
    + energy_balance(pwplant_eb,elec_eb)  * sum(msh_elec_techno(k,[indice_GGS])) ..
) )/1e6; 
counterLine=counterLine+1;
//188 Carbon Sequestration|CCS|Industrial Processes	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//189 Carbon Sequestration|Land Use	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//190 Carbon Sequestration|CCS|Biomass|Energy|Demand|Industry	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//191 Carbon Sequestration|CCS|Biomass|Energy|Supply	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = emi_evitee(k) / 1e6;
counterLine=counterLine+1;
//192 Carbon Sequestration|CCS|Biomass|Energy|Supply|Electricity	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = emi_evitee(k) / 1e6;
counterLine=counterLine+1;
//193 Carbon Sequestration|CCS|Biomass|Energy|Supply|Gases	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//194 Carbon Sequestration|CCS|Biomass|Energy|Supply|Hydrogen	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//195 Carbon Sequestration|CCS|Biomass|Energy|Supply|Liquids	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//196 Carbon Sequestration|CCS|Biomass|Energy|Supply|Other	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//197 Carbon Sequestration|CCS|Fossil|Energy|Demand|Industry	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//198 Carbon Sequestration|CCS|Fossil|Energy|Supply	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= ( ..
    + coef_Q_CO2_ref(k,coal) * (..
    - energy_balance(refi_eb,coal_eb,k) * share_CCS_CTL(k) ..
    + energy_balance(pwplant_eb,elec_eb)* sum(msh_elec_techno(k,[indice_PSS indice_CGS])) ..
    - energy_balance(losses_eb,coal_eb,k)* share_CCS_CTL(k)..
    ) ..
    - coef_Q_CO2_ref(k,et)  * energy_balance(losses_eb,et_eb,k) * share_CCS_CTL(k) ..
    - coef_Q_CO2_ref(k,oil) * energy_balance(losses_eb,oil_eb,k) * share_CCS_CTL(k) ..
    + coef_Q_CO2_ref(k,gaz) * (..
    - energy_balance(refi_eb,   gas_eb,k) * share_CCS_CTL(k) ..
    - energy_balance(losses_eb, gas_eb,k) * share_CCS_CTL(k) ..
    + energy_balance(pwplant_eb,elec_eb)  * sum(msh_elec_techno(k,[indice_GGS])) ..
) )/1e6; 
counterLine=counterLine+1;
//199 Carbon Sequestration|CCS|Fossil|Energy|Supply|Electricity	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= ( ..
    + coef_Q_CO2_ref(k,coal) * (..
    + energy_balance(pwplant_eb,elec_eb)* sum(msh_elec_techno(k,[indice_PSS indice_CGS])) ..
    ) ..
    + coef_Q_CO2_ref(k,gaz) * (..
    + energy_balance(pwplant_eb,elec_eb)  * sum(msh_elec_techno(k,[indice_GGS])) ..
) )/1e6; 
counterLine=counterLine+1;
//200 Carbon Sequestration|CCS|Fossil|Energy|Supply|Gases	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//201 Carbon Sequestration|CCS|Fossil|Energy|Supply|Hydrogen	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//202 Carbon Sequestration|CCS|Fossil|Energy|Supply|Liquids	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//203 Carbon Sequestration|CCS|Fossil|Energy|Supply|Other	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//204 Carbon Sequestration|Other	Mt CO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//205 Emissions|N2O|Total	kt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//206 Emissions|CH4|Total	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//207 Emissions|F-gases|Total	Mt CO2-equiv/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//208 Emissions|Sulfur    Mt SO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//209 Emissions|BC    Mt BC/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//210 Emissions|OC    Mt OC/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//211 Emissions|NOx   Mt NO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//212 Emissions|CO    Mt CO/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//213 Emissions|PFC	kt CF4-equiv/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//214 Emissions|HFC	kt HFC134a-equiv/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//215 Emissions|SF6	kt SF6/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//216 Concentration|CO2	ppm
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//217 Concentration|CH4	ppb
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//218 Concentration|N2O	ppb
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//219 Forcing	W/m2
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//220 Forcing|Kyoto Gases	W/m2
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//221 Temperature|Global Mean  °C
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//222 Emissions|N2O|Energy|Demand	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//223 Emissions|N2O|Energy|Demand|Industry	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//224 Emissions|N2O|Energy|Demand|Industry|Energy Intensive	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//225 Emissions|N2O|Energy|Demand|Residential and Commercial and AFOFI	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//226 Emissions|N2O|Energy|Demand|Residential and Commercial	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//227 Emissions|N2O|Energy|Demand|Residential	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//228 Emissions|N2O|Energy|Demand|Commercial	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//229 Emissions|N2O|Energy|Demand|AFOFI	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//230 Emissions|N2O|Energy|Demand|Transportation	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//231 Emissions|N2O|Energy|Demand|Transportation|Aviation	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//232 Emissions|N2O|Energy|Demand|Transportation|Road	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//233 Emissions|N2O|Energy|Demand|Transportation|Rail	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//234 Emissions|N2O|Energy|Demand|Transportation|Shipping	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//235 Emissions|N2O|Energy|Demand|Transportation|Other Sector	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//236 Emissions|N2O|Energy|Demand|Other Sector	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//237 Emissions|N2O|Energy|Supply	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//238 Emissions|N2O|Energy|Supply|Combustion	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//239 Emissions|N2O|Energy|Supply|Fugitive	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//240 Emissions|N2O|Energy|Supply|Electricity	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//241 Emissions|N2O|Energy|Supply|Heat	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//242 Emissions|N2O|Energy|Supply|Electricity and Heat	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//243 Emissions|N2O|Energy|Supply|Liquids	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//244 Emissions|N2O|Energy|Supply|Solids	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//245 Emissions|N2O|Energy|Supply|Gases	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//246 Emissions|N2O|Industrial Processes	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//247 Emissions|N2O|Product Use	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//248 Emissions|N2O|Energy, Industrial Processes and Product Use	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//249 Emissions|N2O|AFOLU	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//250 Emissions|N2O|AFOLU|Biomass Burning	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//251 Emissions|N2O|AFOLU|Agriculture	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//252 Emissions|N2O|AFOLU|Land	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//253 Emissions|N2O|Waste	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//254 Emissions|N2O|Other	Mt N2O/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//255 Emissions|CH4|Energy Supply and Demand	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//256 Emissions|CH4|Energy|Demand	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//257 Emissions|CH4|Energy|Demand|Industry	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//258 Emissions|CH4|Energy|Demand|Industry|Energy Intensive	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//259 Emissions|CH4|Energy|Demand|Residential and Commercial and AFOFI	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//260 Emissions|CH4|Energy|Demand|Residential and Commercial	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//261 Emissions|CH4|Energy|Demand|Residential	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//262 Emissions|CH4|Energy|Demand|Commercial	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//263 Emissions|CH4|Energy|Demand|AFOFI	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//264 Emissions|CH4|Energy|Demand|Transportation	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//265 Emissions|CH4|Energy|Demand|Transportation|Aviation	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//266 Emissions|CH4|Energy|Demand|Transportation|Road	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//267 Emissions|CH4|Energy|Demand|Transportation|Rail	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//268 Emissions|CH4|Energy|Demand|Transportation|Shipping	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//269 Emissions|CH4|Energy|Demand|Transportation|Other Sector	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//270 Emissions|CH4|Energy|Demand|Other Sector	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//271 Emissions|CH4|Energy|Supply	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//272 Emissions|CH4|Energy|Supply|Combustion	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//273 Emissions|CH4|Energy|Supply|Fugitive	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//274 Emissions|CH4|Energy|Supply|Electricity	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//275 Emissions|CH4|Energy|Supply|Heat	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//276 Emissions|CH4|Energy|Supply|Electricity and Heat	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//277 Emissions|CH4|Energy|Supply|Liquids	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//278 Emissions|CH4|Energy|Supply|Solids	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//279 Emissions|CH4|Energy|Supply|Gases	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//280 Emissions|CH4|Industrial Processes	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//281 Emissions|CH4|Product Use	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//282 Emissions|CH4|Energy, Industrial Processes and Product Use	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//283 Emissions|CH4|AFOLU	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//284 Emissions|CH4|AFOLU|Biomass Burning	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//285 Emissions|CH4|AFOLU|Agriculture	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//286 Emissions|CH4|AFOLU|Land	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//287 Emissions|CH4|Waste	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//288 Emissions|CH4|Other	Mt CH4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//289 Emissions|Sulfur|Energy Supply and Demand	Mt SO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//290 Emissions|Sulfur|Land Use	Mt SO2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//291 Emissions|BC|Energy Supply and Demand	Mt BC/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//292 Emissions|BC|Land Use	Mt BC/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//293 Emissions|OC|Energy Supply and Demand	Mt OC/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//294 Emissions|OC|Land Use	Mt OC/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//295 Emissions|VOC	Mt VOC/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//296 Emissions|NH3	Mt NH3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//297 Forcing|AN3A	W/m2
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//298 Forcing|Montreal Gases	W/m2
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//299 Forcing|CO2	W/m2
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//300 Forcing|CH4	W/m2
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//301 Forcing|N2O	W/m2
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//302 Forcing|F-Gases	W/m2
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//303 Forcing|Aerosol	W/m2
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//304 Forcing|Tropospheric Ozone	W/m2
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//305 Forcing|Albedo Change and Mineral Dust	W/m2
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//306 Forcing|Other	W/m2
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//307 Consumption billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i)=(sum(DF(k,:).*pArmDF(k,:)))/1e3*usd2001_2005;
counterLine=counterLine+1;
//308 Consumption|Industry	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//309 Consumption|Industry|Energy Intensive	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//310 Consumption|Commercial	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//311 Consumption|AFOFI	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//312 Consumption|Transportation	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//313 Consumption|Other sector	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//314 Production|Industry	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//315 Production|Industry|Energy Intensive	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//316 Production|Commercial	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//317 Production|AFOFI	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//318 Production|Transportation	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//319 Production|Other sector	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//320 Value Added|Industry	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//321 Value Added|Industry|Energy Intensive	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//322 Value Added|Commercial	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//323 Value Added|AFOFI	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//324 Value Added|Transportation	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//325 Value Added|Other sector	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
if ind_climat ~= 0
    //326 Policy Cost|Default for CAV
    outputs_temp(nbLines*(k-1)+counterLine,i) = - ( sum(DF(k,:).*pArmDF(k,:)) - sum(base_DF(k,:,i+1) .* base_pArmDF(k,:,i+1)))/1e3*usd2001_2005;
    counterLine=counterLine+1;
    //327	Policy Cost|Area under MAC Curve|Total	billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
    counterLine=counterLine+1;
    //328	Policy Cost|GDP Loss|Total	billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,i) = - (GDP_MER_real(k) - GDP_base_MER_real(k,i+1)) / 1e3*usd2001_2005;
    counterLine=counterLine+1;
    //329	Policy Cost|Consumption Loss|Total	billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,i) = - ( sum(DF(k,:).*pArmDF(k,:)) - sum(base_DF(k,:,i+1) .* base_pArmDF(k,:,i+1)))/1e3*usd2001_2005;
    counterLine=counterLine+1;
    //330	Policy Cost|Equivalent Variation    billion US$2005/yr 
    outputs_temp(nbLines*(k-1)+counterLine,i) = %nan; // fixme
    counterLine=counterLine+1;
    //331	Policy Cost|Additional total energy system cost	billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,i) = (energyInvestment(k) - energyInvestment_base(k,i+1)) / 1e3 * usd2001_2005;
    counterLine=counterLine+1;
    //332	Policy Cost|Other|Total	billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
    counterLine=counterLine+1;
else
    //326 Policy Cost|Default for CAV
    outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
    counterLine=counterLine+1;
    //327	Policy Cost|Area under MAC Curve|Total	billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
    counterLine=counterLine+1;
    //328  Policy Cost|GDP Loss|Total  billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
    counterLine=counterLine+1;
    //329  Policy Cost|Consumption Loss|Total  billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
    counterLine=counterLine+1;
    //330	Policy Cost|Equivalent Variation    billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
    counterLine=counterLine+1;
    //331	Policy Cost|Additional Total energy System Cost	billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
    counterLine=counterLine+1;
    //332  Policy Cost|Other billion US$2005/yr
    outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
    counterLine=counterLine+1;
end
//333 Price|Carbon	US$2005/t CO2
outputs_temp(nbLines*(k-1)+counterLine,i)=taxCO2_DF(k)*1e6*usd2001_2005;
counterLine=counterLine+1;
//334 Price|Primary Energy|Oil	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i)=p(k,indice_oil)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//335 Price|Primary Energy|Natural Gas	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i)=p(k,indice_gas)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//336 Price|Primary Energy|Coal	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i)=p(k,indice_coal)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//337 Price|Primary Energy|Biomass
if sum(prod_elec_techno(k,technoBiomass)) + prod_BFU(k)==0
    outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
else
    qBiom = (sum(msh_elec_techno(k,technoBiomassWOCCS) ./ rho_elec_nexus(k,technoBiomassWOCCS)) ..
        + msh_elec_techno(k,indice_BIS) / rho_elec_nexus(k,indice_BIS))..
    * energy_balance(pwplant_eb,8,k);
    outputs_temp(nbLines*(k-1)+counterLine,i)=(prod_BFU(k) *  p(k,et) + costBIGCC_noTax(k) * qBiom) * usd2001_2005 / tep2gj ..
    /(qBiom + prod_BFU(k));
end
counterLine=counterLine+1;
//338 Price|Secondary Energy|Electricity 
outputs_temp(nbLines*(k-1)+counterLine,i)=pArmCI(indice_elec,indice_industrie,k)*usd2001_2005/tep2gj;
counterLine=counterLine+1;
//339 Price|Secondary Energy|Liquids	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//340 Price|Secondary Energy|Solids	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//341 Price|Secondary Energy|Gases	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//342 Price|Secondary Energy|Hydrogen	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//343 Price|Final Energy|Industry|Electricity	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//344 Price|Final Energy|Industry|Gases|Natural Gas	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//345 Price|Final Energy|Industry|Liquids|Oil	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//346 Price|Final Energy|Industry|Solids|Coal	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//347 Price|Final Energy|Residential and Commercial|Electricity	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//348 Price|Final Energy|Residential and Commercial|Gases|Natural Gas	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//349 Price|Final Energy|Residential and Commercial|Liquids|Oil	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//350 Price|Final Energy|Residential and Commercial|Solids|Coal	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//351 Price|Final Energy|Transportation|Liquids|Oil	US$2005/GJ
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//352 Final Energy|Industry|Solids
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(conso_indu_eb,coal_eb,k)+energy_balance(conso_agri_eb,coal_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//353 Final Energy|Industry|Solids|Coal	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//354 Final Energy|Industry|Solids|Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//353 Final Energy|Industry|Liquids
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(conso_indu_eb,oil_eb,k)+energy_balance(conso_indu_eb,et_eb,k)+energy_balance(conso_agri_eb,oil_eb,k) + energy_balance(conso_agri_eb,et_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//354 Final Energy|Industry|Gases
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(conso_indu_eb,gas_eb,k)+energy_balance(conso_agri_eb,gas_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//355 Final Energy|Industry|Electricity
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(conso_indu_eb,elec_eb,k)+energy_balance(conso_agri_eb,elec_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//356 Final Energy|Industry|Hydrogen  EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//357 Final Energy|Industry|Heat  EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//358 Final Energy|Industry|Other
outputs_temp(nbLines*(k-1)+counterLine,i)= 0;
counterLine=counterLine+1;
//359 Final Energy|Residential and Commercial|Solids
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(conso_resid_eb,coal_eb,k)+energy_balance(conso_comp_eb,coal_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//360 Final Energy|Residential and Commercial|Solids|Coal
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(conso_resid_eb,coal_eb,k)+energy_balance(conso_comp_eb,coal_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//361 Final Energy|Residential and Commercial|Solids|Biomass
outputs_temp(nbLines*(k-1)+counterLine,i)= %nan;
counterLine=counterLine+1;
//362 Final Energy|Residential and Commercial|Liquids
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(conso_resid_eb,oil_eb,k)+energy_balance(conso_resid_eb,et_eb,k)+energy_balance(conso_comp_eb,oil_eb,k) + energy_balance(conso_comp_eb,et_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//363 Final Energy|Residential and Commercial|Gases
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(conso_resid_eb,gas_eb,k)+energy_balance(conso_comp_eb,gas_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//364 Final Energy|Residential and Commercial|Electricity
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(conso_resid_eb,elec_eb,k)+energy_balance(conso_comp_eb,elec_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//365 Final Energy|Residential and Commercial|Hydrogen   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//366 Final Energy|Residential and Commercial|Heat   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//367 Final Energy|Residential and Commercial|Other
outputs_temp(nbLines*(k-1)+counterLine,i)= 0;
counterLine=counterLine+1;
//368 Final Energy|Transportation|Liquids
outputs_temp(nbLines*(k-1)+counterLine,i) = (energy_balance(conso_air_eb,et_eb,k)+energy_balance(conso_ot_eb,et_eb,k)+energy_balance(conso_car_eb,et_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//369 Final Energy|Transportation|Liquids|Oil
outputs_temp(nbLines*(k-1)+counterLine,i)=sum(energy_balance(conso_transport_eb,et_eb,k))*(1-(share_biofuel(k)+share_CTL(k)))*Mtoe_EJ;
counterLine=counterLine+1;
//370 Final Energy|Transportation|Liquids|Biomass
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(energy_balance(conso_transport_eb,et_eb,k))*share_biofuel(k)*Mtoe_EJ;
counterLine=counterLine+1;
//371 Final Energy|Transportation|Liquids|Coal
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(energy_balance(conso_transport_eb,et_eb,k))*share_CTL(k)*Mtoe_EJ;
counterLine=counterLine+1;
//372 Final Energy|Transportation|Gases   EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = (energy_balance(conso_air_eb,gas_eb,k)+energy_balance(conso_ot_eb,gas_eb,k)+energy_balance(conso_car_eb,gas_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//373 Final Energy|Transportation|Hydrogen
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//374 Final Energy|Transportation|Electricity
outputs_temp(nbLines*(k-1)+counterLine,i) = (energy_balance(conso_air_eb,elec_eb,k)+energy_balance(conso_ot_eb,elec_eb,k)+energy_balance(conso_car_eb,elec_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//375 Final Energy|Transportation|Other
outputs_temp(nbLines*(k-1)+counterLine,i) = 0;
counterLine=counterLine+1;
//376 Final Energy|Transportation|Passenger|Road	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//377 Final Energy|Transportation|Passenger|Road|Liquids	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//378 Final Energy|Transportation|Passenger|Road|Liquids|Biomass	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//379 Final Energy|Transportation|Passenger|Road|Electricity	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//380 Final Energy|Transportation|Passenger|Road|Gases	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//381 Final Energy|Transportation|Passenger|Road|Hydrogen 	EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//382 Final Energy|Other Sector|Solids
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(conso_btp_eb,coal_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//383 Final Energy|Other Sector|Solids|Coal 
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(conso_btp_eb,coal_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//384 Final Energy|Other Sector|Solids|Biomass 
outputs_temp(nbLines*(k-1)+counterLine,i)= 0;
counterLine=counterLine+1;
//385 Final Energy|Other Sector|Liquids 
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(conso_btp_eb,oil_eb,k)+energy_balance(conso_btp_eb,et_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//386 Final Energy|Other Sector|Gases 
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(conso_btp_eb,gas_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//387 Final Energy|Other Sector|Electricity
outputs_temp(nbLines*(k-1)+counterLine,i)= (energy_balance(conso_btp_eb,elec_eb,k))*Mtoe_EJ;
counterLine=counterLine+1; 
//388 Final Energy|Other Sector|Hydrogen  EJ/yr
counterLine=counterLine+1;
//389 Final Energy|Other Sector|Heat  EJ/yr
counterLine=counterLine+1;
//390 Final Energy|Other Sector|Other //btp
outputs_temp(nbLines*(k-1)+counterLine,i)= 0;
counterLine=counterLine+1;
//391 Energy Service|Residential and Commercial|Floor Space
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//392 Energy Service|Transportation|Passenger bn pkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = (Tair(k) + Tautomobile(k) + TOT(k) + TNM(k)) * pkmautomobileref(k) / 100 / 1e9;
counterLine=counterLine+1;
//393 Energy Service|Transportation|Freight   bn tkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//394	Trade|Primary Energy|Coal|Volume (Exports-Imports) EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= -(energy_balance(imp_eb,coal_eb,k) + energy_balance(exp_eb,coal_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//395 Trade|Primary Energy|Gas|Volume	(Exports-Imports) EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= -(energy_balance(imp_eb,gas_eb,k) + energy_balance(exp_eb,gas_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//396 Trade|Primary Energy|Oil|Volume	(Exports-Imports) EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i)= -(energy_balance(imp_eb,oil_eb,k) + energy_balance(exp_eb,oil_eb,k))*Mtoe_EJ;
counterLine=counterLine+1;
//397 Trade|Primary Energy|Biomass|Volume	(Exports-Imports) EJ/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//398 Trade|Primary Energy|Coal|Value
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//399 Trade|Primary Energy|Gas|Value
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//400 Trade|Primary Energy|Oil|Value
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//401 Trade|Primary Energy|Biomass|Value
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//402 Trade|Exports|Value	billion US$2005/yr OR local currency/year
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//403 Trade|Imports|Value	billion US$2005/yr OR local currency/year
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//404 Trade|AFOFI	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//405 Trade|Industry	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//406 Trade|Industry|Energy Intensive	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//407 Trade|Transportation	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//408 Trade|Commercial	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//409 Trade|Other Sector	billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//410 Employment	million
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//411 Employment|AFOFI	million
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//412 Employment|Industry	million
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//413 Employment|Industry|Energy Intensive	million
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//414 Employment|Transportation	million
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//415 Employment|Commercial	million
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//416 Employment|Other Sector	million
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//417 Resource|Cumulative Extraction|Gas|Conventional	EJ
outputs_temp(nbLines*(k-1)+counterLine,i) = Q_cum_gaz(k)*Mtoe_EJ;
counterLine=counterLine+1;
//418 Resource|Cumulative Extraction|Gas|Unconventional	EJ
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//419 Resource|Cumulative Extraction|Oil|Conventional	EJ
outputs_temp(nbLines*(k-1)+counterLine,i) = (Q_cum_oil_poles(k,1) + sum(Q_cum_oil(k,:)))*Mtoe_EJ;
counterLine=counterLine+1;
//420 Resource|Cumulative Extraction|Oil|Unconventional	EJ
outputs_temp(nbLines*(k-1)+counterLine,i) = (sum(Q_cum_heavy(k,:)) + sum(Q_cum_shale(k,:)))*Mtoe_EJ;
counterLine=counterLine+1;
//421 Investment|Energy Supply  billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = (pK(k,coal).*DeltaK(k,coal) + pK(k,oil).*DeltaK(k,oil)..
+ pK(k,gaz).*DeltaK(k,gaz) + pK(k,et).*DeltaK(k,et) + pK(k,elec).*DeltaK(k,elec))*usd2001_2005/1000;
counterLine=counterLine+1;
//422 Investment|Energy Supply|Electricity  billion US$2005/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = (pK(k,elec).*DeltaK(k,elec))*usd2001_2005/1000;
counterLine=counterLine+1;
//423 Investment|Energy Supply|Electricity|Fossil
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(delta_Cap_elec_MW_1(k,technoFossil).*CINV_MW_nexus(k,technoFossil))/10^3*usd2001_2005/1000;
counterLine=counterLine+1;
//424 Investment|Energy Supply|Electricity|Fossil|w/ CCS
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(delta_Cap_elec_MW_1(k,technoFossilWCCS).*CINV_MW_nexus(k,technoFossilWCCS))/10^3*usd2001_2005/1000;
counterLine=counterLine+1;
//425 Investment|Energy Supply|Electricity|Fossil|w/o CCS
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(delta_Cap_elec_MW_1(k,technoFossilWOCCS).*CINV_MW_nexus(k,technoFossilWOCCS))/10^3*usd2001_2005/1000;
counterLine=counterLine+1;
//426 Investment|Energy Supply|Electricity|Non-fossil
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(delta_Cap_elec_MW_1(k,technoNonFossil).*CINV_MW_nexus(k,technoNonFossil))/10^3*usd2001_2005/1000;
counterLine=counterLine+1;
//427 Investment|Energy Supply|Electricity|Non-fossil|Biomass
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(delta_Cap_elec_MW_1(k,technoBiomass).*CINV_MW_nexus(k,technoBiomass))/10^3*usd2001_2005/1000;
counterLine=counterLine+1;
//428 Investment|Energy Supply|Electricity|Non-fossil|Nuclear
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(delta_Cap_elec_MW_1(k,technoNuke).*CINV_MW_nexus(k,technoNuke))/10^3*usd2001_2005/1000;
counterLine=counterLine+1;
//429 Investment|Energy Supply|Electricity|Non-fossil|Non-Biomass Renewables
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(delta_Cap_elec_MW_1(k,technoNonBiomassRen).*CINV_MW_nexus(k,technoNonBiomassRen))/10^3*usd2001_2005/1000;
counterLine=counterLine+1;
//430 Investment|Energy Supply|Electricity|Non-fossil|Non-Biomass Renewables|Solar
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(delta_Cap_elec_MW_1(k,technoSolar).*CINV_MW_nexus(k,technoSolar))/10^3*usd2001_2005/1000;
counterLine=counterLine+1;
//431 Investment|Energy Supply|Electricity|Non-fossil|Non-Biomass Renewables|Wind
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(delta_Cap_elec_MW_1(k,technoWind).*CINV_MW_nexus(k,technoWind))/10^3*usd2001_2005/1000;
counterLine=counterLine+1;
//432 Investment|Energy Supply|Electricity|Other
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//433 Investment|Energy Supply|Extraction|Fossil
outputs_temp(nbLines*(k-1)+counterLine,i) = (pK(k,coal).*DeltaK(k,coal) + pK(k,oil).*DeltaK(k,oil)..
+ pK(k,gaz).*DeltaK(k,gaz))*usd2001_2005/1000;
counterLine=counterLine+1;
//434 Investment|Energy Demand
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//435 Infrastructure Investment|Transportation|Road
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//436 Infrastructure Investment|Transportation|Aviation
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//437 Infrastructure Investment|Transportation|Rail
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//438 Infrastructure Investment|Transportation|Shipping|International
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//439 Land Cover  million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//440 Land Cover|Cropland million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//441 Land Cover|Pasture  million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//442 Land Cover|Forest   million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//443 Land Cover|Other Land   million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//444 Land Cover|Forest|Managed   million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//445 Land Cover|Cropland|Energy Crops    million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//446 Land Cover|Other Arable Land    million Ha/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//447 Energy Service|Residential|Floor Space	bn m2/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//448 Energy Service|Industry|Iron and Steel	mn tonnes/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//449 Energy service|Industry|Non metallic minerals	mn tonnes/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//450 Energy Service|Transportation|Passenger					billion pkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = (alphaair(k).*DF(k,indice_air) + Tautomobile(k) + alphaOT(k).*DF(k,indice_OT) + TNM(k))..
.*pkmautomobileref(k) / 100 / 1e9;
counterLine=counterLine+1;
//451 Energy Service|Transportation|Freight						billion tkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//452 Energy Service|Transportation|Road	billion 				vkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//453 Energy Service|Transportation|Passenger|Road				billion pkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = (Tautomobile(k) + alphaOT(k).*DF(k,indice_OT))* pkmautomobileref(k) / 100 / 1e9;
counterLine=counterLine+1;
//454 Energy Service|Transportation|Passenger|Road|2W and 3W		billion pkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//455 Energy Service|Transportation|Passenger|Road|LDV				billion pkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = Tautomobile(k).*pkmautomobileref(k) ./100/ 1e9;
counterLine=counterLine+1;
//456 Energy Service|Transportation|Passenger|Road|Bus				billion pkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = alphaOT(k).*DF(k,indice_OT).*pkmautomobileref(k)./100 / 1e9;
counterLine=counterLine+1;
//457 Energy Service|Transportation|Freight|Road					billion tkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//458 Energy Service|Transportation|Aviation						billion vkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//459 Energy Service|Transportation|Passenger|Aviation				billion pkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = alphaair(k).*DF(k,indice_air).*pkmautomobileref(k)./100 / 1e9;
counterLine=counterLine+1;
//460 Energy Service|Transportation|Freight|Aviation				billion tkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//461 Energy Service|Transportation|Rail						billion vkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//462 Energy Service|Transportation|Passenger|Rail				billion pkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//463 Energy Service|Transportation|Freight|Rail					billion tkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//464 Energy Service|Transportation|Shipping|International			billion vkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//465 Energy Service|Transportation|Passenger|Shipping|International	billion pkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//466 Energy Service|Transportation|Freight|Shipping|International	billion tkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//467 Energy Service|Transportation|Bicycling and Walking			billion pkm/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = TNM(k).*pkmautomobileref(k)./100 / 1e9;
counterLine=counterLine+1;
//468 Water Consumption|Electricity	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//469 Water Consumption|Electricity|Biomass	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//470 Water Consumption|Electricity|Biomass|w/ CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//471 Water Consumption|Electricity|Biomass|w/o CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//472 Water Consumption|Electricity|Coal	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//473 Water Consumption|Electricity|Coal|w/ CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//474 Water Consumption|Electricity|Coal|w/o CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//475 Water Consumption|Electricity|Cooling Pond	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//476 Water Consumption|Electricity|Dry Cooling	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//477 Water Consumption|Electricity|Fossil	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//478 Water Consumption|Electricity|Fossil|w/ CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//479 Water Consumption|Electricity|Fossil|w/o CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//480 Water Consumption|Electricity|Gas	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//481 Water Consumption|Electricity|Gas|w/ CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//482 Water Consumption|Electricity|Gas|w/o CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//483 Water Consumption|Electricity|Geothermal	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//484 Water Consumption|Electricity|Hydro	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//485 Water Consumption|Electricity|Non-Biomass Renewables	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//486 Water Consumption|Electricity|Nuclear	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//487 Water Consumption|Electricity|Ocean	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//488 Water Consumption|Electricity|Oil	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//489 Water Consumption|Electricity|Oil|w/ CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//490 Water Consumption|Electricity|Oil|w/o CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//491 Water Consumption|Electricity|Once Through	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//492 Water Consumption|Electricity|Other	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//493 Water Consumption|Electricity|Sea Cooling	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//494 Water Consumption|Electricity|Solar	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//495 Water Consumption|Electricity|Solar|CSP	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//496 Water Consumption|Electricity|Solar|PV	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//497 Water Consumption|Electricity|Wet Tower	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//498 Water Consumption|Electricity|Wind	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//499 Water Withdrawal|Electricity	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//500 Water Withdrawal|Electricity|Biomass	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//501 Water Withdrawal|Electricity|Biomass|w/ CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//502 Water Withdrawal|Electricity|Biomass|w/o CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//503 Water Withdrawal|Electricity|Coal	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//504 Water Withdrawal|Electricity|Coal|w/ CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//505 Water Withdrawal|Electricity|Coal|w/o CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//506 Water Withdrawal|Electricity|Cooling Pond	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//507 Water Withdrawal|Electricity|Dry Cooling	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//508 Water Withdrawal|Electricity|Fossil	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//509 Water Withdrawal|Electricity|Fossil|w/ CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//510 Water Withdrawal|Electricity|Fossil|w/o CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//511 Water Withdrawal|Electricity|Gas	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//512 Water Withdrawal|Electricity|Gas|w/ CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//513 Water Withdrawal|Electricity|Gas|w/o CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//514 Water Withdrawal|Electricity|Geothermal	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//515 Water Withdrawal|Electricity|Hydro	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//516 Water Withdrawal|Electricity|Non-Biomass Renewables	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//517 Water Withdrawal|Electricity|Nuclear	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//518 Water Withdrawal|Electricity|Ocean	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//519 Water Withdrawal|Electricity|Oil	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//520 Water Withdrawal|Electricity|Oil|w/ CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//521 Water Withdrawal|Electricity|Oil|w/o CCS	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//522 Water Withdrawal|Electricity|Once Through	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//523 Water Withdrawal|Electricity|Other	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//524 Water Withdrawal|Electricity|Sea Cooling	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//525 Water Withdrawal|Electricity|Solar	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//526 Water Withdrawal|Electricity|Solar|CSP	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//527 Water Withdrawal|Electricity|Solar|PV	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//528 Water Withdrawal|Electricity|Wet Tower	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//529 Water Withdrawal|Electricity|Wind	km3/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//530 Capacity|Electricity|Biomass	GW
outputs_diag(nbLines*(k-1)+counterLine,i) = sum(Cap_elec_MW(k,technoBiomass))/1000;
counterLine=counterLine+1;
//531 Capacity|Electricity|Biomass|w/ CCS	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = Cap_elec_MW(k,indice_BIS)/ 1000;
counterLine=counterLine+1;
//532 Capacity|Electricity|Biomass|w/o CCS	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(Cap_elec_MW(k,technoBiomassWOCCS))/ 1000;
counterLine=counterLine+1;
//533 Capacity|Electricity|Coal	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(Cap_elec_MW(k,technoElecCoal))/1000;
counterLine=counterLine+1;
//534 Capacity|Electricity|Coal|w/ CCS	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(Cap_elec_MW(k,technoCoalWCCS))/1000;
counterLine=counterLine+1;
//535 Capacity|Electricity|Coal|w/o CCS	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(Cap_elec_MW(k,technoCoalWOCCS))/1000;
counterLine=counterLine+1;
//536 Capacity|Electricity|Gas	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(Cap_elec_MW(k,technoGas))/1000;
counterLine=counterLine+1;
//537 Capacity|Electricity|Gas|w/ CCS	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(Cap_elec_MW(k,technoGasWCCS))/1000;
counterLine=counterLine+1;
//538 Capacity|Electricity|Gas|w/o CCS	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(Cap_elec_MW(k,technoGasWOCCS))/1000;
counterLine=counterLine+1;
//539 Capacity|Electricity|Geothermal	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//540 Capacity|Electricity|Hydro	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(Cap_elec_MW(k,technoElecHydro))/1000;
counterLine=counterLine+1;
//541 Capacity|Electricity|Nuclear	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(Cap_elec_MW(k,technoNuke))/1000;
counterLine=counterLine+1;
//542 Capacity|Electricity|Ocean	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//543 Capacity|Electricity|Oil	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(Cap_elec_MW(k,technoOil))/1000;
counterLine=counterLine+1;
//544 Capacity|Electricity|Other	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//545 Capacity|Electricity|Peak Demand	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//546 Capacity|Electricity|Solar	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(Cap_elec_MW(k,technoSolar))/1000;
counterLine=counterLine+1;
//547 Capacity|Electricity|Solar|CSP	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = Cap_elec_MW(k,indice_CSP)/1000;
counterLine=counterLine+1;
//548 Capacity|Electricity|Solar|PV	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(Cap_elec_MW(k,technoPV))/1000;
counterLine=counterLine+1;
//549 Capacity|Electricity|Storage	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//550 Capacity|Electricity|Wind	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = sum(Cap_elec_MW(k,technoWind))/1000;
counterLine=counterLine+1;
//551 Capacity|Electricity|Wind|Offshore	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = Cap_elec_MW(k,indice_WND)/ 1000;
counterLine=counterLine+1;
//552 Capacity|Electricity|Wind|Onshore	GW
outputs_temp(nbLines*(k-1)+counterLine,i) = Cap_elec_MW(k,indice_WNO)/ 1000;
counterLine=counterLine+1;
//553 Emissions|C2F6	kt C2F6/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//554 Emissions|C6F14	kt C6F14/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//555 Emissions|CF4	kt CF4/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//556 Emissions|HFC	kt HFC134a-equiv/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//557 Emissions|HFC|HFC125	kt HFC125/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//558 Emissions|HFC|HFC134a	kt HFC134a/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//559 Emissions|HFC|HFC143a	kt HFC143a/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//560 Emissions|HFC|HFC227ea	kt HFC227ea/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//561 Emissions|HFC|HFC23	kt HFC23/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//562 Emissions|HFC|HFC245fa	kt HFC245fa/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//563 Emissions|HFC|HFC32	kt HFC32/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;
//564 Emissions|HFC|HFC43-10	kt HFC43-10/yr
outputs_temp(nbLines*(k-1)+counterLine,i) = %nan;
counterLine=counterLine+1;