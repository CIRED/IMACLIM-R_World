// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thibault Briera, Ruben Bibas, Thomas Le-Gallic, Adrien Vogt-Schilb, Nicolas Graves, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

////////////////////////-----------------------------------------------////////////////
////////////////////////    dynamic evolution of Imaclim sectors       ////////////////
////////////////////////-----------------------------------------------////////////////



emi_evitee = zeros(nb_regions,1);

exec(MODEL+"exogenous.shock.end.sce");

//# past variables memorization for dynamic resolutions
Ltot_prev            = Ltot;
stockautomobile_prev = stockautomobile;
//a faire: utiliser plutot save_generic. Mimer ce qu'on fait avec taux_Q_nexus

//# past variables used in the static equilibrium for the weights of the logit for energy exports

p_stock = p(:,1:5);
wpEner_prev = wpEner;
mtax_prev1 = mtax(:,1:5);
wpTIagg_prev = wpTIagg;
partDomDF_stock = partDomDF(:,1:5);
partDomDI_stock = partDomDI(:,1:5);
partDomDG_stock=partDomDG(:,1:5);
partDomCI_stock=partDomCI(1:5,:,:);
bmarketshareener=marketshare(:,1:5); // bmarketshareener in equivalent to marketshare_prev, use in the static equilibirum

//# Taxes adjustment
exec (MODEL+"ajustement.taxes.sce");

//# add variables to list..
if current_time_im==1
    sg_add(["partInvFin" "K_expected" "energyInvestment" "partInvestFirms" "partInvestHH"]);
end

//# Demographic evolution
L=L.*(1+txLact(:,current_time_im));
Ltot=Ltot_trajectory(:,current_time_im+1);
labor_ILO = labor_ILO0 ./ (Qref.*lref) .* (Q.*l);



//# Savings rate and investment rate, central scenario is SSP2
ptc=ptc.*(1-saving_obj_exo_1(:,current_time_im+1))./(1-saving_obj_exo_1(:,current_time_im));
div=div.*(1-auto_invest_obj_exo_1(:,current_time_im+1))./(1-auto_invest_obj_exo_1(:,current_time_im));

// Climate - TCRE & impacts
exec(MODEL+"nexus.climate.impact.sce");

//# Labor productivity
exec(MODEL+"nexus.laborProductivity.sce");

//# Expectations formation
exec(MODEL+"nexus.expectations.quantities.sce");
exec(MODEL+"nexus.expectations.carbonTax.sce");
exec(MODEL+"nexus.expectations.sequestration.sce");
exec(MODEL+"nexus.expectations.prices.sce");

// Change in the size and composition of the housing stock (between standard buildings, low energy and very low energy buildings), and computation of the energy efficiency expenditures 
exec(MODEL+"nexus.buildings.sce");

// Update of the government expenditures and carbon tax recycling by reducing labour costs
exec(MODEL+"nexus.climatePolicy1.sce");

CI;
markup;
Beta;

//# Labor costs
if current_time_im==1
    sal_cost_coal_ref=w(:,indice_coal).*l(:,indice_coal).*FCC(:,indice_coal);
    sal_cost_gaz_ref=w(:,indice_gaz).*l(:,indice_gaz).*FCC(:,indice_gaz);
    //	sal_cost_oil_ref=w(:,indice_oil).*l(:,indice_oil).*FCC(:,indice_oil);
end
// w_temp=(pind*ones(1,sec)).*wref.*((aw+bw.*tanh(cw.*Z))*ones(1,sec))./((pindref*ones(1,sec)));
w_temp=(pind*ones(1,sec)).*wref.*((aw+bw.*tanh(cw.*Z))*ones(1,sec));
//w(:,indice_coal).*l(:,indice_coal).*FCC(:,indice_coal)=sal_cost_coal_ref
//sal_cost_gaz_ref=w(:,indice_gaz).*l(:,indice_gaz).*FCC(:,indice_gaz)
l(:,indice_coal)=sal_cost_coal_ref./(w_temp(:,indice_coal).*FCC(:,indice_coal));
l(:,indice_gaz)=sal_cost_gaz_ref./(w_temp(:,indice_gaz).*FCC(:,indice_gaz));
//l(:,indice_oil)=sal_cost_oil_ref./(w_temp(:,indice_oil).*FCC(:,indice_oil));
l(:,indice_coal)=1/2*l(:,indice_coal)+1/2*l_prev(:,indice_coal);
l(:,indice_gaz)=1/2*l(:,indice_gaz)+1/2*l_prev(:,indice_gaz);
l(:,indice_coal)=min(max(l(:,indice_coal),l_prev(:,indice_coal)*0.9),l_prev(:,indice_coal)*1.1);
l(:,indice_gaz)=min(max(l(:,indice_gaz),l_prev(:,indice_gaz)*0.9),l_prev(:,indice_gaz)*1.1);
//l(:,indice_oil)=min(max(l(:,indice_oil),l_prev(:,indice_oil)*0.9),l_prev(:,indice_oil)*1.1);

///////////////////////////diminution du commerce international de carburants liquides
// partDomCIref;
// partDomDFref;
// partDomDGref;
// partDomDIref;
// partDomDFref(:,indice_Et)=partDomDFref(:,indice_Et)+0.01;
// partDomDGref(:,indice_Et)=partDomDGref(:,indice_Et)+0.01;
// partDomDIref(:,indice_Et)=partDomDIref(:,indice_Et)+0.01;

// for k=1:reg,
// for j=1:sec
// partDomCIref(indice_Et,j,k)=partDomCIref(indice_Et,j,k)+0.01;
// partDomCIref(indice_Et,j,k)=min(partDomCIref(indice_Et,j,k),0.99999);
// end
// partDomDFref(k,indice_Et)=min(partDomDFref(k,indice_Et),0.99999);
// partDomDGref(k,indice_Et)=min(partDomDGref(k,indice_Et),0.99999);
// partDomDIref(k,indice_Et)=min(partDomDIref(k,indice_Et),0.99999);
// end

//////// Nouveau calcul des Xsi pour qu'ils varient avec la variation du Rdisp/Ltot (but = empecher l'explosion de la DF agricole en chine)
xsi=update_xsi(Rdisp,Ltot_prev,DF,pArmDF,hdf_cff,xsi);

// Evolution xsiT  
if current_time_im >= start_year_strong_policy-base_year_simulation 

	if current_time_im < 2050 - base_year_simulation
	
	//We increase xsiT in global South in order to reach more plausible demand in car pkm.
	xsiT(ind_chn)=1.004*xsiT(ind_chn);	
	xsiT(ind_ind)=1.000*xsiT(ind_ind);
	xsiT(ind_bra)=1.002*xsiT(ind_bra);
	xsiT(ind_mde)=1.000*xsiT(ind_mde); // or 1.002 ?
	xsiT(ind_afr)=1.010*xsiT(ind_afr);	
	xsiT(ind_ras)=1.006*xsiT(ind_ras);
	xsiT(ind_ral)=1.004*xsiT(ind_ral);
		
		// Variant implemented in Fisch-Romito & Guivarch, 2019 and reused (and adapted) here for task 3.5 NAVIGATE. This variant lower the share of budget dedicated to transport. It has effects on modal share (more non-motorized and public transport, less car) and on total distance travelled per year by households (passenger kilometers, pkm).
		if ind_transportsufficiency == 1 
			xsiT(ind_global_north)=0.992*xsiT(ind_global_north);	 // or 0.990 ?
		end
	
	end
	
	if ind_transportsufficiency == 1 & current_time_im >= 2050 - base_year_simulation // We lower the decrease pace after 2050 and apply it to all regions
		xsiT(ind_global_north)=0.998*xsiT(ind_global_north);
		xsiT(ind_chn)=0.998*xsiT(ind_chn);
		xsiT(ind_bra)=0.998*xsiT(ind_bra);
		xsiT(ind_mde)=0.998*xsiT(ind_mde);
		xsiT(ind_ral)=0.998*xsiT(ind_ral);
	end
	
	// Evolution des xsi de manière proportionnelle pour que xsiT + sum xsi =1
	for k=1:reg
		xsi(k,:)=xsi(k,:).*(1-xsiT(k))./sum(xsi(k,:));
	end	

end


if (current_time_im> 1 & ind_NLU > 0)
    exec(MODEL+"nexus.landuse.real.sce");
end
if ind_NLU ==0 & combi == 7 & current_time_im>1 &  ETUDE == "emf33" // specific run of emf33 : no bioenergy
  p_et_temp = matrix( pArmCI(indice_Et,indice_agriculture,:), nb_regions,1);
  q_et_temp = matrix( energy_balance(refi_eb,et_eb,:), nb_regions,1);
  wlightoil_price = sum(q_et_temp .* p_et_temp) / sum(q_et_temp);
  wnatgas_price =  wp_gaz_anticip_nlu;
  for regy=1:nb_regions
    reg_taxeC(regy) = taxMKT( whichMKT_reg_use(regy)) * 1e6 ; // ($/tCO2eq)
  end
end
if (current_time_im> 1 & do_calibrateNoutput_NLU & combi==7);
    exec(MODEL+"extraction.outputs."+ETUDEOUTPUT+".landuse.sce");
end

ind_first_run_elec = 1; // by default set to 1 before every iteration. 

exec(MODEL+"nexus.electricity.idealPark.sce"); // Finds ideal electric park

if ind_climfin>0 
  if climfin_port(current_time_im)>0
    exec(MODEL+"nexus.climfin.sce"); 
    //Initializing the loop:
      ind_first_run_elec = 0; //informs that some parts of the electricity nexus doest not need to be rerun (essentially learning)
      norm_bound = norm_bound_init; // set the intial norm value for the convergence
      prevent_endless = 0; // preventing the while loop to endless run. stops at an arbitrary # of iterations
    while rerun_nexus_wacc >0
      rerun_nexus_wacc = 0;
      exec(MODEL+"nexus.electricity.idealPark.sce"); //rerunning the nexus until we find a fixed point for share_climfin_Inv in each region
      exec(MODEL+"nexus.climfin.sce");
      rerun_nexus_wacc
      prevent_endless = prevent_endless + rerun_nexus_wacc
      if prevent_endless > 50
      norm_bound = norm_bound+0.01;
      warning("Lowering required precision")
      end
      if prevent_endless > 100
        norm_bound = norm_bound+0.01;
        warning("Lowering required precision")
      end
      if prevent_endless > 200
        warning("Endless loop: share_Inv_climfin does not converge")
        exit
    end

    end 
    exec(MODEL+"nexus.electricity.idealPark.sce"); //getting the right WACC once convergence is reached
  end
end

// nexus land-use
if ind_NLU > 0
	exec("nexus.landuse.sce");
else
    Qbiofuel_NLU=zeros(reg,1);
    current_time=current_time_im;
    build_et_curve_NLU = %f;
    bioener_costs_NLU  = %nan * ones(reg,1);
    unused_other_agrof_prod = zeros(reg,1);
    Prod_energy_crops       = zeros(reg,1);
    Modern_bioenergy_cons   = zeros(reg,1);
    Prod_ModEnergy_other    = zeros(reg,1);
    Prod_ModEnergy_residues = zeros(reg,1);
    reg_Tradi_ener_demand   = zeros(reg,1);
    share1G                 = zeros(reg,1);
    share2G                 = zeros(reg,1);
end


if ind_NLU ==0 & combi == 7 & ETUDE == "emf33" // specific case of emf33 - for 1st generation biofuels outputs
  pop = Ltot';
  current_time = current_time_im ;
  exec(codes_dir+"update_forcings.sce");
  
  select ethan2G_transf_cost_scen
  case "LinearDecrease"
    //ethan2G_transfo_cost = ethan2G_transfocost_2000 - (current_time+1) /  51 * (ethan2G_transfocost_2000 - ethan2G_transfocost_2050) ;
    //ethan2G_transfo_cost = max( ethan2G_transfo_cost, ethan2G_transfocost_2050) ;
    ethan2G_inv = Hoowijk_inv_2000 - (current_time+1) /  51 * ( Hoowijk_inv_2000 - Hoowijk_inv_2050);
    ethan2G_inv = max( Hoowijk_2000_inv, Hoowijk_inv_2050);
  case "Constant"
    //ethan2G_transfo_cost = ethan2G_transfocost_2000;
    ethan2G_inv = Hoowijk_inv_2000;
  else
    warning(' ethan2G_transf_cost_scen is ill-defined');
  end
  Qbiofuel_NLU = ( prod_agrofuel )' / mtoe2ej / Exajoule2Mkcal;
  current_time_im = current_time;
end

//# Depreciated capital
K_depreciated=(1-delta).*K;
K_depreciated(:,indice_mer)=K_depreciated(:,indice_mer)./inc_shipFleet_speedRed(current_time_im);
K_depreciated(:,indice_elec)=zeros(reg,1);
K_depreciated(:,indice_composite)=K(:,indice_composite)-Capvintagecomposite(:,current_time_im);
K_depreciated(:,indice_agriculture)=K(:,indice_agriculture)-Capvintageagriculture(:,current_time_im);
K_depreciated(:,indice_industries)=K(:,indice_industries)-Capvintageindustries(:,:,current_time_im);

//# capital/production capacities expectations
K_expected = max(Q.*(taux_Q_nexus)/0.8 , 0 ); // added max(0,-) to prevent negative capacities
exec(MODEL + "nexus.oil.sce");
exec(MODEL + "nexus.gas.sce");
exec(MODEL + "nexus.coal.sce");

markup=max(markup, min_markup_fossil);

//# Investment allocation
exec(MODEL + "nexus.finance.sce");

//# Investment reallocation for elec sector
exec(MODEL+"nexus.electricity.realInvestment.sce");
exec(MODEL+"nexus.capital.sce"); // new capital K and production capacities Cap

//# Update CI
exec(MODEL+"nexus.productiveSectors.eei.sce"); // energy efficiency
exec(MODEL+"nexus.productiveSectors.leontief.sce"); // CI(:,[agriculture,industry,composite])
exec(MODEL+"nexus.transport.sce"); // CI(:,[air,mer,OT]) and other feature of the static
exec(MODEL+"nexus.fret.sce"); // CI([air,mer,OT],:)

exec(MODEL+"nexus.Et.sce");

////////////////////modification des CI énergétiques du BTP selon l'AEEI
// Autonomous progress 
progres_AEEI=E_enerdelta(:,indice_industries($),current_time_im); //MULTISECTOR: we use the equipment industry pattern as a reference.
for k=1:reg,
    for j=1:nbsecteurenergie
        CI(j,indice_construction,k)=CIref(j,indice_construction,k)*progres_AEEI(k);
    end
end

if NEXUS_indus==1
    exec(MODEL+"Dynamic.industry(2)"+".sce");
end

// Pour les secteurs charbon et gaz, on enlève les modifications des coefficients techniques
for k=1:reg
    CI(:,indice_coal,k)=CI_prev(:,indice_coal,k);
    CI(:,indice_gaz,k)=CI_prev(:,indice_gaz,k);
end

//# past variable memorization
Q_noDI_prev=Q_noDI;
Rdisp_real_prev=Rdisp./price_index;
Ltot_prev_stock=Ltot_prev;
Q_prev=Q;
pArmCI_prev_prev_prev=pArmCI_prev_prev;
pArmCI_prev_prev=pArmCI_prev;
pArmCI_prev=pArmCI;
pArmCI_w_CCS_indus_p_p_p=pArmCI_w_CCS_indus_p_p; // DESAG_INDUSTRY: errors expected here, I didn't change it (12/10/2022)
pArmCI_w_CCS_indus_p_p=pArmCI_w_CCS_indus_p;
pArmCI_w_CCS_indus_p=pArmCI_w_CCS_indus;
pArmCI_wo_CCS_indu_p_p_p=pArmCI_wo_CCS_indu_p_p;
pArmCI_wo_CCS_indu_p_p=pArmCI_wo_CCS_indu_p;
pArmCI_wo_CCS_indu_p=pArmCI_wo_CCS_indu;
pArmDF_prev_prev_prev=pArmDF_prev_prev;
pArmDF_prev_prev=pArmDF_prev;
pArmDF_prev=pArmDF;
DF_prev_prev=DF_prev;
DF_prev=DF;
wp_oil_prev=wp(indice_oil);
pArmDI_prev=pArmDI;
pArmDG_prev=pArmDG;
p_prev=p;
wp_prev=wp;
DG_prev=DG;
DI_prev=DI;
Exp_prev=Exp;
Imp_prev=Imp;
GDP_MER_real_prev= GDP_MER_real;

if ind_zeroBN == 1
    exec(MODEL+"zeroingBN.sce");
end

//# Energy efficiencies in residential equipments, and financing of those improvment
exec(MODEL+"nexus.productiveSectors.eeiCost.sce");
//# Climate policies
exec(MODEL+"nexus.climatePolicy2.sce");

//on empèche le markup d'aller à zéro
markup=max(markup,0.0001);

exec(MODEL+"exogenous.shock.sce");

//Inequalities module
//if ind_inequality == 1
//	exec(MODEL+"nexus.inequalities.sce");
//end

exec(MODEL+"nexus.emissions.sce");
