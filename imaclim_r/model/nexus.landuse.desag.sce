//meant to be executed after nexus.electricity.idealPark.sce and before nexus.electricity.realInvestment.sce and nexus.et.sce


//timestep, fin
  if do_specific_outputs then
     printf("Generating EMF 33 outputs...");
     exec(codes_dir+"generate_emf_outputs.sce");
     printf("Done\n");
   end

//outputs from nexus land-use

LandRent_NLU = total_profit'; // land rent
surface_NLU = sum(density_Dyn_new, 'c')' .* dsurfagri;
delta_surf_NLU = surface_NLU ./ surface_NLU0;
FixCost_NLU = surface_NLU .* coutfixeint;
delta_FixCost = FixCost_NLU ./ FixCost_NLU0;

// warning : surfcropnonDyn will be surf_other_crops at the next update
// fertilizers, while waiting for next update of land-use towards Imaclim
if ind_NLU_ferti ==1
  if use_CI_chi_from_FAO then
    Q_ferti_NLU = consNPK_volume_total';
  else
    Q_ferti_NLU = consCI_vol_tot';
  end
end
p_ferti_NLU = pchi';
wpcalmono=pcalmono*share_exp_mono_clb';

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Update Imaclim parameters////
///////////////////////////////


//##### Calculate first the Q_agriFoodProcess (expected value), production of the food processing sector (2 possible Hypothesis) 
// First steps :
// evolution of coeffs ???
coeff_vegexp=coeff_vegexp ;
coeff_meatexp=coeff_meatexp ; 
coeff_meatexp=coeff_meatexp ;
coeff_vegimp=coeff_vegimp;
coeff_meatimp=coeff_meatimp; 
//
exportsveg_raw = exportsveg .* coeff_vegexp' ;
exportsrumi_raw = exportsrumi .* coeff_meatexp' ; 
exportsmono_raw = exportsmono_clb .* coeff_meatexp' ; // exports doesn't move
importsveg_raw = importsveg .* coeff_vegimp' ;
importsrumi_raw = importsrumi .* coeff_meatimp' ;
importsmono_raw = VolImpMonoRef .* coeff_meatimp' ; // imports doesn't move

// previous period coefficient
PAY_agriFoodProcess = ( Q(:,agri).*A(:,agri).*w(:,agri).*l(:,agri).*(1+sigma(:,agri)).*(energ_sec(:,agri) + FCC(:,agri).*non_energ_sec(:,agri)) - PAY_agriRawProd0.*delta_FixCost') ./ Q_agriFoodProcess;
// expected outputs



ImpRaw_NLU = importsveg_raw.*wpveg+importsrumi_raw.*wprumi+importsmono_raw.*wpcalmono;
ExpRaw_NLU = exportsveg_raw.*wpveg +  exportsrumi_raw.*wprumi + exportsmono_raw.* wpcalmono;
Conso_NLU = pcalveg .* (dfoodveg + dotherveg + prod_agrofuel_Dyn) + pcalmono .* dfoodmonog + pcalrumi .* dfoodrumi;
Ouput_NLU = Conso_NLU + ExpRaw_NLU - ImpRaw_NLU;
impIC_raw2FoodProces_NLU =ImpRaw_NLU./(Conso_NLU  - ExpRaw_NLU) ;
IC_raw2FoodProcess_NLU = pcalveg .* (1-coeff_foodveg_raw').*dfoodveg  + pcalmono .* (1-coeff_foodmonog_raw').*dfoodmonog + pcalrumi .* (1-coeff_foodrumi_raw').*dfoodrumi + impIC_raw2FoodProces_NLU;
IC_raw2FoodProcess_Im = IC_raw2FoodProcess_Im0 .* IC_raw2FoodProcess_NLU'./ IC_raw2FoodProcess_NLU0' ;
Output_agriFoodProcess = p(:,agri) .* Q(:,agri) - Prod_agriRawProd0 .* (Ouput_NLU ./ Ouput_NLU0)'  ;  
select ind_NLUhyp
    case 0
    //Hypothesis 1 : fixed margin
        Q_agriFoodProcess =  ( Output_agriFoodProcess .* ( ones(markup_agriFoodProcess)  - markup_agriFoodProcess) - IC_raw2FoodProcess_Im )./ (sum(alphaIC_agriFoodProcess.*p,"c") + PAY_agriFoodProcess);
    case 1
    //Hypothesis 2 : fixed share of labor and profit in added value
        Q_agriFoodProcess =  ( Output_agriFoodProcess - IC_raw2FoodProcess_Im )./ (sum(alphaIC_agriFoodProcess.*p,"c") + PAY_agriFoodProcess .* valueAdded_shares_coeff);
        markup_agriFoodProcess =  divide(PAY_agriFoodProcess .* valueAdded_shares_coeff, divide( Output_agriFoodProcess, Q_agriFoodProcess,0 ), 0);////
    else
    error ("ind_NLUhyp is illed defined:")
end



// Reaggregattion of both sectors
if ind_NLU_CI == 1
for region=1:nb_regions
	CI(:,agri,region) = (IC_agriRawProd0(:,region) * delta_surf_NLU(region) + alphaIC_agriFoodProcess(:,region) .*Q_agriFoodProcess(region)) ./ Q(region,agri);
end
CI(:,agri,:) = 5/6 * CI_prev(:,agri,:) + 1/6 * CI(:,agri,:);
end

if ind_NLU_pi ==1
markup(:,agri) =  ( Output_agriFoodProcess.*markup_agriFoodProcess + Capital_agriRawProd0.*delta_FixCost' + Land_agriRawProd0.*LandRent_NLU./LandRent_NLU0 ) ./ (p(:,agri) .* Q(:,agri) );
end

//for debug
deltaRent = Land_agriRawProd0.*LandRent_NLU./LandRent_NLU0;

if ind_NLU_l ==1
l(:,agri) = ( l_agriFoodProcess .* Q_agriFoodProcess + L_agriRawProd0.*delta_surf_NLU') ./ Q(:,agri);
end

if ind_NLU_ferti ==1
        Q_ferti_Im = Q_ferti_Im0 .* Q_ferti_NLU./Q_ferti_NLU0;
	CIindus_Temp = ( alpha_gas2ferti.*Q_ferti_NLU + alpha_gas2indus0ferti.*(Q(:,indus)-Q_ferti_Im) ) ./ Q(:,indus);
	CI(gaz,indus,(linspace(1,nb_regions,nb_regions)<>ind_chn)) = CIindus_Temp((linspace(1,nb_regions,nb_regions)<>ind_chn));
	CI(coal,indus,ind_chn) = ( alpha_coal2ferti_CHN.*Q_ferti_NLU(ind_chn) + alpha_coal2ind0ferti_CHN.*(Q(ind_chn,indus)-Q_ferti_Im(ind_chn)) ) ./ Q(ind_chn,indus);
end


// for saving, name swap :
if ind_NLU_ferti ==1
  a_chn_coal2ferti=alpha_coal2ferti_CHN;
  a_chn_coal2ind0ferti=alpha_coal2ind0ferti_CHN;
  a_gas2ferti=alpha_gas2ferti;
  a_gas2indus0ferti=alpha_gas2indus0ferti;
end
alphaIC_agriFood=alphaIC_agriFoodProcess;
l_agriFood=l_agriFoodProcess;
mkp_agriFood=markup_agriFoodProcess;



