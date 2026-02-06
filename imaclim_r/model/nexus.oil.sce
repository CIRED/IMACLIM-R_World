// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Ruben Bibas, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// Goods requirement for capital formation
// follows rise of markup (to ensure that new capital becomes more expensive as resources get exhausted)
//txmarkup(:,indice_oil) = markup(:,indice_oil) ./ markup_prev(:,indice_oil) - 1;
// for k=1:reg
//   for j=1:sec
// //	  Beta(j,indice_oil,k)=Beta(j,indice_oil,k) * (1+txmarkup(k,indice_oil));
//   end
// end


wp_oil = wp(oil) / tep2oilbarrels ;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// preliminary data
// production capacities per cost category
Cap_util_oil_prev=Cap_util_oil;
Cap_util_heavy_prev=Cap_util_heavy;
Cap_util_shale_prev=Cap_util_shale;

//remaining oil in each regon and category
// production per cost category
Q_oil_parcategorie=zeros(reg,nb_cat_oil);
Q_heavy_parcategorie=zeros(reg,nb_cat_heavy);
Q_shale_parcategorie=zeros(reg,nb_cat_shale);

for k=1:reg
    for j=1:nb_cat_oil
        Q_oil_parcategorie(k,j)=charge(k,indice_oil)*Cap_util_oil_prev(k,j);
    end
end

for k=1:reg
    for j=1:nb_cat_heavy
        Q_heavy_parcategorie(k,j)=charge(k,indice_oil)*Cap_util_heavy_prev(k,j);
    end
end

for k=1:reg
    for j=1:nb_cat_shale
        Q_shale_parcategorie(k,j)=charge(k,indice_oil)*Cap_util_shale_prev(k,j);
    end
end

//remaining oil in each regon and category
//cumulative oil extracted by cost category
Q_cum_oil=Q_cum_oil+Q_oil_parcategorie;
Q_cum_heavy=Q_cum_heavy+Q_heavy_parcategorie;
Q_cum_shale=Q_cum_shale+Q_shale_parcategorie;

//removing from resource
Ress_oil=Ress_0_oil-Q_cum_oil;
Ress_oil=max(Ress_oil,0);

Ress_heavy=Ress_0_heavy-Q_cum_heavy;
Ress_heavy=max(Ress_heavy,0);

Ress_shale=Ress_0_shale-Q_cum_shale;
Ress_shale=max(Ress_shale,0);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// conventionnal oil
test_premexploit_oil;
// test for production ignition
testPremExploitOilprev=test_premexploit_oil;

for k=fatal_producer,
    for j=1:nb_cat_oil,
        if ((test_premexploit_oil(k,j)==0)&((wp(indice_oil))>wp_lim(j)*tep2oilbarrels))
            test_premexploit_oil(k,j)=1;
        end
    end
end

// decision to exploite an oil well
for k=fatal_producer,
    for j=1:nb_cat_oil,
        if ((wp(indice_oil))>wp_lim(j)*tep2oilbarrels)
            test_exploit_oil(k,j)=1;
        else
            test_exploit_oil(k,j)=0;
        end
    end
end

/////////////////// Hubbert curve calibration for first production
if current_time_im>1
    pente_hubbert;
    Cap_0;
end
for k=fatal_producer,
    for j=1:nb_cat_oil,
        if (test_premexploit_oil(k,j)==1)&(testPremExploitOilprev(k,j)==0)
            if Ress_infini_oil(k,j)<>0
                // For non-zero reserve we compute the Hubbert curve parameters
                id_oil(k,j)=current_time_im;
                pente_hubbert(k,j)=pente_conv;
                Cap_0(k,j)= Ress_infini_oil(k,j)/base_charge_noFCC(indice_oil);
                Ress_0_oil(k,j) = share_ress_HubbertCurves * Ress_infini_oil(k,j);
                exp_temp(k,j)=(Ress_0_oil(k,j)/Ress_infini_oil(k,j))/(1-Ress_0_oil(k,j)/Ress_infini_oil(k,j));
                //Production peak date
                i_hubbert(k,j)=log(exp_temp(k,j))/pente_hubbert(k,j)+current_time_im;


                Cap_hubbert_suivant(k,j)=hs_oil*Cap_0(k,j)*pente_hubbert(k,j)/4;
            else
                //For zero reserve, no Hubbert curves
                id_oil(k,j)=current_time_im;
                pente_hubbert(k,j)=pente_conv;
                Cap_0(k,j)= Ress_infini_oil(k,j)/base_charge_noFCC(indice_oil);
                Ress_0_oil(k,j)=1;
                exp_temp(k,j)=2;
                //Production peak date
                i_hubbert(k,j)=log(exp_temp(k,j))/pente_hubbert(k,j)+current_time_im;
                Cap_hubbert_suivant(k,j)=hs_oil*Cap_0(k,j)*pente_hubbert(k,j)/4;
            end
        end
    end
end

//Hubebrt curve calibration for category already in production
half_extraction_prev=half_extraction;

for k=fatal_producer,
    for j=1:nb_cat_oil

        ////////first case: we cant to exploite the category
        if (test_exploit_oil(k,j)==1)
            ////passing half of the ressource, we recalibrate the Hubbert curves parameters for the degrowth phase
            if (Ress_oil(k,j)<0.5*Ress_infini_oil(k,j))&(half_extraction(k,j)==0)
                i_hubbert(k,j)=current_time_im;
                half_extraction(k,j)=1;
                Cap_max_hubbert(k,j)=Cap_util_oil_prev(k,j);
                pente_hubbert(k,j)=pente_conv;
                Cap_0(k,j)=Cap_max_hubbert(k,j)*4/pente_hubbert(k,j);
            end

            //recomputing the Hubbert slope for degrowth
            if (half_extraction(k,j)==1)&(current_time_im>i_hubbert(k,j)+1)&Ress_oil(k,j)>0
                pente_hubbert(k,j)=fsolve(pente_hubbert(k,j),hubbert_slope);
                exp_temp=max(exp(-(pente_hubbert(k,j)*(current_time_im-i_hubbert(k,j)))),%eps);
                Cap_0(k,j)=Ress_oil(k,j)/0.9*1/(1-1/(1+exp_temp));
            end

            Cap_hubbert_suivant(k,j)=Cap_0(k,j)*pente_hubbert(k,j)*exp(-(pente_hubbert(k,j)*(current_time_im+1-i_hubbert(k,j))))/(1+exp(-(pente_hubbert(k,j)*(current_time_im+1-i_hubbert(k,j)))))^2;

            ////If the category has been exploited less quickly than expected, we have a 'plateau' before degrowth

            if (Ress_oil(k,j)>0.5*Ress_infini_oil(k,j))&(current_time_im>i_hubbert(k,j))
                Cap_hubbert_suivant(k,j)=Cap_util_oil_prev(k,j);
            end
            // smoothing production ignition
            if (j>3)&(current_time_im>id_oil(k,j)-1)&(current_time_im<id_oil(k,j)+5)
                Cap_hubbert_suivant(k,j)=(current_time_im-id_oil(k,j))/4*Cap_0(k,j)*pente_hubbert(k,j)*exp(-(pente_hubbert(k,j)*(id_oil(k,j)+4-i_hubbert(k,j))))/(1+exp(-(pente_hubbert(k,j)*(id_oil(k,j)+4-i_hubbert(k,j)))))^2;
            end
        end


        ////////second case: we do not want to exploite the category
        if (test_exploit_oil(k,j)==0)
            // without depletion constriant, we keep the same capacity level

            if (Ress_oil(k,j)>0.5*Ress_infini_oil(k,j))
                Cap_hubbert_suivant(k,j)=Cap_util_oil_prev(k,j);
            end

            //...else we go to degrowth

            if (Ress_oil(k,j)<0.5*Ress_infini_oil(k,j))
                if (half_extraction(k,j)==0)
                    i_hubbert(k,j)=current_time_im;
                    half_extraction(k,j)=1;
                    Cap_max_hubbert(k,j)=Cap_util_oil_prev(k,j);
                    pente_hubbert(k,j)=pente_conv;
                    Cap_0(k,j)=Cap_max_hubbert(k,j)*4/pente_hubbert(k,j);
                    Cap_hubbert_suivant(k,j)=Cap_util_oil_prev(k,j);

                else
                    Cap_hubbert_suivant(k,j)=Cap_0(k,j)*pente_hubbert(k,j)*exp(-(pente_hubbert(k,j)*(current_time_im+1-i_hubbert(k,j))))/(1+exp(-(pente_hubbert(k,j)*(current_time_im+1-i_hubbert(k,j)))))^2;
                end
            end
        end
    end
end
//capacity exploited by "fatal producers"

Cap_util_oil=Cap_hubbert_suivant;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//non conventional oil
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

taxval_nex_oil = max(taxCO2_CI(:,indice_oil,:))*1e6; //taxval_nex_oil in $/t, taxCO2_CI in M$/t

if current_time_im==2 & verbose>=1
    warning("taxval is is set to max(taxCO2_CI(:,indice_oil,:))*1e6 in nexus.oil")
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//HEAVY OIL
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
price_lag_heavy=1;
//bearkeven price
wp_lim_heavy=(prodcost_heavy+min(taxval_nex_oil,40)*emission_heavy)*price_lag_heavy;
//wp_lim_heavy=(prodcost_heavy+0*TAXVAL_Poles(1,min(current_time_im,size_TAXVAL(2)))*emission_heavy)*price_lag_heavy;

//////////////////exploitation decision
//decision for the first category exploitation
test_heavy_prev=test_heavy;
test_prem_heavy_prev=test_prem_heavy;

//keep track of the first exploitation
for k=1:reg,
    for j=1:nb_cat_heavy,
        if ((test_prem_heavy(k,j)==0)&(wp(indice_oil))>wp_lim_heavy(j)*tep2oilbarrels)
            test_prem_heavy(k,j)=1;
        end
    end
end

for k=1:reg,
    for j=1:nb_cat_heavy,
        if ((test_prem_heavy(k,j)==1)&((wp(indice_oil))>wp_lim_heavy(j)*tep2oilbarrels))
            test_heavy(k,j)=1;
        else
            test_heavy(k,j)=0;
        end
    end
end

//keep track for launching back a second or more exploitation phase
for k=1:reg,
    for j=1:nb_cat_heavy,
        if (test_prem_heavy_prev(k,j)==1)&(test_heavy_prev(k,j)==0)&(test_heavy(k,j)==1)&(half_heavy(k,j)==0)
            test_redem_heavy(k,j)=1;
        else
            test_redem_heavy(k,j)=0;
        end
    end
end

//////////Hubbert curve for the first time exploitation
for k=1:reg,
    for j=1:nb_cat_heavy,
        if (test_prem_heavy(k,j)==1)&(test_prem_heavy_prev(k,j)==0)
            if Ress_infini_heavy(k,j)<>0
                //For non-zero reserves, we compute the Hubbert curve parameters
                id_heavy(k,j)=current_time_im;
                pente_heavy(k,j)=pente_unconv;
                Cap_heavy_0(k,j)= Ress_infini_heavy(k,j)/base_charge_noFCC(indice_oil);
                // exp_temp(k,j)=(2/hs_heavy-1)+2/hs_heavy*(1-hs_heavy)^0.5;
                // Ress_0_heavy(k,j)=exp_temp(k,j)/(1+exp_temp(k,j))*Ress_infini_heavy(k,j);
                Ress_0_heavy(k,j)= share_ress_HubbertCurves *Ress_infini_heavy(k,j);
                exp_temp(k,j)=(Ress_0_heavy(k,j)/Ress_infini_heavy(k,j))/(1-Ress_0_heavy(k,j)/Ress_infini_heavy(k,j));
                //production peak date
                i_heavy(k,j)=log(exp_temp(k,j))/pente_heavy(k,j)+current_time_im;


                Cap_heavy_suivant(k,j)=hs_heavy*Cap_heavy_0(k,j)*pente_heavy(k,j)/4;
            else
                //For null reserve, the Hubbert curve is zero
                id_heavy(k,j)=current_time_im;
                pente_heavy(k,j)=pente_unconv;
                Cap_heavy_0(k,j)= 0;
                Ress_0_heavy(k,j)=1;
                exp_temp(k,j)=2;
                //production peak date
                i_heavy(k,j)=log(exp_temp(k,j))/pente_heavy(k,j)+current_time_im;

                Cap_heavy_suivant(k,j)=hs_heavy*Cap_heavy_0(k,j)*pente_heavy(k,j)/4;
            end
        end
    end
end

/////////// Hubbert curves calibration for category already under exploitation
half_heavy_prev=half_heavy;
for k=1:reg,
    for j=1:nb_cat_heavy
        if test_prem_heavy(k,j)==1
            if (current_time_im>id_heavy(k,j)-1)&(current_time_im<id_heavy(k,j)+5)
                Cap_heavy_suivant(k,j)=(current_time_im-id_heavy(k,j)+1)/5*Cap_heavy_0(k,j)*pente_heavy(k,j)*exp(-(pente_heavy(k,j)*(id_heavy(k,j)+4-i_heavy(k,j))))/(1+exp(-(pente_heavy(k,j)*(id_heavy(k,j)+4-i_heavy(k,j)))))^2;

            elseif (current_time_im>=id_heavy(k,j)+5)

                if test_redem_heavy(k,j)==0 // for category that were not stopped in the previous period

                    ////////First case: we want to put catergory under exploitation
                    if (test_heavy(k,j)==1)
                        //// passing hald of reserves, we recalibrate the Hubbert curve for degrowth
                        if (Ress_heavy(k,j)<0.5*Ress_infini_heavy(k,j))&(half_heavy(k,j)==0)
                            i_heavy(k,j)=current_time_im;
                            half_heavy(k,j)=1;
                            Cap_max_heavy(k,j)=Cap_util_heavy_prev(k,j);
                            pente_heavy(k,j)=pente_unconv;
                            Cap_heavy_0(k,j)=Cap_max_heavy(k,j)*4/pente_heavy(k,j);
                        end

                        //recomputing the slope for the degrowth phase
                        if (half_heavy(k,j)==1)&(current_time_im>i_heavy(k,j)+1)&Ress_heavy(k,j)>0
                            pente_heavy(k,j)=fsolve(pente_heavy(k,j),hubbert_heavy_slope);
                            exp_temp=exp(-(pente_heavy(k,j)*(current_time_im-i_heavy(k,j))));
                            Cap_heavy_0(k,j)=Ress_heavy(k,j)/0.9*1/(1-1/(1+exp_temp));
                        end
                        ////...else we keep parameters as is

                        Cap_heavy_suivant(k,j)=Cap_heavy_0(k,j)*pente_heavy(k,j)*exp(-(pente_heavy(k,j)*(current_time_im+1-i_heavy(k,j))))/(1+exp(-(pente_heavy(k,j)*(current_time_im+1-i_heavy(k,j)))))^2;

                        ////In the case we exploited the resource slowier than expected, we have a 'plateau' before degrowth
                        if (Ress_heavy(k,j)>0.5*Ress_infini_heavy(k,j))&(current_time_im>i_heavy(k,j))
                            Cap_heavy_suivant(k,j)=Cap_util_heavy_prev(k,j);
                        end

                        //smoothing the ignition of new capacities
                        if j>2
                            if (current_time_im>id_heavy(k,j)-1)&(current_time_im<id_heavy(k,j)+5)
                                Cap_heavy_suivant(k,j)=(current_time_im-id_heavy(k,j)+1)/5*Cap_heavy_0(k,j)*pente_heavy(k,j)*exp(-(pente_heavy(k,j)*(id_heavy(k,j)+4-i_heavy(k,j))))/(1+exp(-(pente_heavy(k,j)*(id_heavy(k,j)+4-i_heavy(k,j)))))^2;
                            end
                        end
                    end

                    ////////Second case: we do not want to run categories under exploitation
                    if (test_heavy(k,j)==0)
                        // In the case with no depletion constraint, we keep the same capacity level

                        if (Ress_heavy(k,j)>0.5*Ress_infini_heavy(k,j))
                            Cap_heavy_suivant(k,j)=Cap_util_heavy_prev(k,j);
                        end

                        //...else we have to go to the degrowht phase

                        if (Ress_heavy(k,j)<0.5*Ress_infini_heavy(k,j))
                            if (half_heavy(k,j)==0)
                                i_heavy(k,j)=current_time_im;
                                half_heavy(k,j)=1;
                                Cap_max_heavy(k,j)=Cap_util_heavy_prev(k,j);
                                pente_heavy(k,j)=pente_unconv;
                                Cap_heavy_0(k,j)=Cap_max_heavy(k,j)*4/pente_heavy(k,j);
                                Cap_heavy_suivant(k,j)=Cap_util_heavy_prev(k,j);

                            else
                                Cap_heavy_suivant(k,j)=Cap_heavy_0(k,j)*pente_heavy(k,j)*exp(-(pente_heavy(k,j)*(current_time_im+1-i_heavy(k,j))))/(1+exp(-(pente_heavy(k,j)*(current_time_im+1-i_heavy(k,j)))))^2;


                            end
                        end
                    end
                end

                ///////////Hubbert curves calibration for categories already under exploitation and that did not stop in the previous time step
                //During the growth phase, the Hubbert curves parameters have to be recomputed

                if (test_redem_heavy(k,j)==1)&(Cap_util_heavy_prev(k,j)<>0)
                    if (current_time_im>=id_heavy(k,j)+5)
                        pente_heavy(k,j)=pente_unconv;
                        //continuity condition
                        rapport_temp=pente_heavy(k,j)*Ress_heavy(k,j)/0.9/Cap_util_heavy_prev(k,j);
                        exp_heavy_temp=rapport_temp-1;

                        //we reduce the value of i_heavy and Cap_0
                        i_heavy(k,j)=log(exp_heavy_temp)/pente_heavy(k,j)+current_time_im;
                        Cap_heavy_0(k,j)=Ress_heavy(k,j)/0.9*(1+exp_heavy_temp)/exp_heavy_temp;
                        Cap_heavy_suivant(k,j)=Cap_heavy_0(k,j)*pente_heavy(k,j)*exp(-(pente_heavy(k,j)*(current_time_im-i_heavy(k,j))))/(1+exp(-(pente_heavy(k,j)*(current_time_im-i_heavy(k,j)))))^2;
                    end
                end
            end


            //at the end of produciton, degrowth is forced by remaining reserves

            if (Ress_heavy(k,j)<fract_exhausted*Ress_infini_heavy(k,j))
                if Cap_exhausted_heavy(k,j)==0
                    Cap_exhausted_heavy(k,j)=Cap_heavy_suivant(k,j);
                    i_exhausted_heavy(k,j)=current_time_im;
                    Ress_exhausted_heavy(k,j)=Ress_heavy(k,j);
                end
                Cap_heavy_suivant(k,j)=Cap_exhausted_heavy(k,j)*Ress_heavy(k,j)/Ress_exhausted_heavy(k,j);
            end
        end
    end
end
//disp(Cap_util_heavy,'Cap_util_heavy');

Cap_util_heavy=Cap_heavy_suivant;


// This shoulb be optionnaly done in Extraction
// if current_time_im==1 then sortie_nonconv=zeros (5*reg*nb_cat_heavy, TimeHorizon+1); end

// sortie_nonconv(:,current_time_im) = [ matrix(test_heavy,reg*nb_cat_heavy,1)
// matrix(test_redem_heavy,reg*nb_cat_heavy,1)
// matrix(i_heavy,reg*nb_cat_heavy,1)
// matrix(Cap_heavy_0,reg*nb_cat_heavy,1)
// matrix(Cap_heavy_suivant,reg*nb_cat_heavy,1)];
// if current_time_im==TimeHorizon
// mkcsv ("sortie_nonconv");
// end
// Cap_util_heavy=Cap_heavy_suivant;

////////////////////////////////////////////////////////////////////////////////////////////////
//limitation of the growth of non conventional to 0.4mbarrels/year in Canada
//Cap_util_heavy( 2,:) = min ( Cap_heavy_suivant( 2,:), Cap_util_heavy_prev( 2,:)+0.4*365/tep2oilbarrels);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//shale OIL
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
price_lag_shale=1;

//breakeven prices
wp_lim_shale=(prodcost_shale+0*taxval_nex_oil*emission_shale)*price_lag_shale;

//////////////////ddecision to run a category under exploitation
//decision for the first exploitatin
test_shale_prev=test_shale;
test_prem_shale_prev=test_prem_shale;

//keep track of first exploitation
for k=1:reg,
    for j=1:nb_cat_shale,
        if ((test_prem_shale(k,j)==0)&(wp(indice_oil))>wp_lim_shale(j)*tep2oilbarrels)
            i_test_prem_shale(k,j)=current_time_im;
            test_prem_shale(k,j)=1;
        end
    end
end

for k=1:reg,
    for j=1:nb_cat_shale,
        if ((test_prem_shale(k,j)==1)&((wp(indice_oil))>wp_lim_shale(j)*tep2oilbarrels)&(current_time_im>=i_test_prem_shale(k,j)))
            test_shale(k,j)=1;
        else
            test_shale(k,j)=0;end
    end
end

//keep track of runing under exploitation again a category of oil, during the growth phase
for k=1:reg,
    for j=1:nb_cat_shale,
        if (test_prem_shale_prev(k,j)==1)&(test_shale_prev(k,j)==0)&(test_shale(k,j)==1)&(half_shale(k,j)==0)
            test_redem_shale(k,j)=1;
        else
            test_redem_shale(k,j)=0;
        end
    end
end
//////////hubbert curve calibration for the first exploitation
Cap_shale_suivant;
for k=1:reg,
    for j=1:nb_cat_shale,
        if (test_prem_shale(k,j)==1)&(test_prem_shale_prev(k,j)==0)
            if Ress_infini_shale(k,j)<>0
                //For non zero reserve, we compute thje parameters of the Hubebrt curves
                id_shale(k,j)=current_time_im;
                pente_shale(k,j)=pente_unconv;
                Cap_shale_0(k,j)= Ress_infini_shale(k,j)/base_charge_noFCC(indice_oil);
                exp_temp(k,j)=(2/hs_shale-1)+2/hs_shale*(1-hs_shale)^0.5;
                Ress_0_shale(k,j)=exp_temp(k,j)/(1+exp_temp(k,j))*Ress_infini_shale(k,j);
                //production peak date
                i_shale(k,j)=log(exp_temp(k,j))/pente_shale(k,j)+current_time_im;


                Cap_shale_suivant(k,j)=hs_shale*Cap_shale_0(k,j)*pente_shale(k,j)/4;
            else
                //For null reserves, no Hubbert curves
                id_shale(k,j)=current_time_im;
                pente_shale(k,j)=pente_unconv;
                Cap_shale_0(k,j)= 0;
                Ress_0_shale(k,j)=1;
                exp_temp(k,j)=2;
                //production peak date
                i_shale(k,j)=log(exp_temp(k,j))/pente_shale(k,j)+current_time_im;

                Cap_shale_suivant(k,j)=hs_shale*Cap_shale_0(k,j)*pente_shale(k,j)/4;
            end
        end
    end
end

///////////Hubbert curves calibration for caterogy already under exploitation and that were not stopped in the previous period
half_shale_prev=half_shale;
for k=1:reg,
    for j=1:nb_cat_shale
        if test_redem_shale(k,j)==0
            ////////First case: we want to put under exploitaton the category
            if (test_shale(k,j)==1)
                ////past half of reserves, we recalibrate the Hubbert curves for degrowth
                if (Ress_shale(k,j)<0.5*Ress_infini_shale(k,j))&(half_shale(k,j)==0)
                    i_shale(k,j)=current_time_im;
                    half_shale(k,j)=1;
                    Cap_max_shale(k,j)=Cap_util_shale_prev(k,j);
                    pente_shale(k,j)=pente_unconv;
                    Cap_shale_0(k,j)=Cap_max_shale(k,j)*4/pente_shale(k,j);
                end
                //recomputing the slope for degrowth
                if (half_shale(k,j)==1)&(current_time_im>i_shale(k,j)+1)&Ress_shale(k,j)>0
                    pente_shale(k,j)=fsolve(pente_shale(k,j),hubbert_shale_slope);
                    exp_temp=exp(-(pente_shale(k,j)*(current_time_im-i_shale(k,j))));
                    Cap_shale_0(k,j)=Ress_shale(k,j)/0.9*1/(1-1/(1+exp_temp));
                end
                ////...else we keep parameters as is

                Cap_shale_suivant(k,j)=Cap_shale_0(k,j)*pente_shale(k,j)*exp(-(pente_shale(k,j)*(current_time_im+1-i_shale(k,j))))/(1+exp(-(pente_shale(k,j)*(current_time_im+1-i_shale(k,j)))))^2;

                ////In the case we exploited the ressource not as fast as expected, we have a producton 'plateau' before degrowth

                if (Ress_shale(k,j)>0.5*Ress_infini_shale(k,j))&(current_time_im>i_shale(k,j))
                    Cap_shale_suivant(k,j)=Cap_util_shale_prev(k,j);
                end

                //smoothing new capacity entrance
                if (current_time_im>id_shale(k,j)-1)&(current_time_im<id_shale(k,j)+5)
                    Cap_shale_suivant(k,j)=(current_time_im-id_shale(k,j))/4*Cap_shale_0(k,j)*pente_shale(k,j)*exp(-(pente_shale(k,j)*(id_shale(k,j)+4-i_shale(k,j))))/(1+exp(-(pente_shale(k,j)*(id_shale(k,j)+4-i_shale(k,j)))))^2;
                end
            end
            ////////Second case: we do not want to put the category under exploitation
            if (test_shale(k,j)==0)
                if (current_time_im>id_shale(k,j)-1)&(current_time_im>id_shale(k,j)+5)
                    // Without depletion constraint, we keep the same capacity level

                    if (Ress_shale(k,j)>0.5*Ress_infini_shale(k,j))
                        Cap_shale_suivant(k,j)=Cap_util_shale_prev(k,j);
                    end

                    //...else we have to degrow

                    if (Ress_shale(k,j)<0.5*Ress_infini_shale(k,j))
                        if (half_shale(k,j)==0)
                            i_shale(k,j)=current_time_im;
                            half_shale(k,j)=1;
                            Cap_max_shale(k,j)=Cap_util_shale_prev(k,j);
                            pente_shale(k,j)=pente_unconv;
                            Cap_shale_0(k,j)=Cap_max_shale(k,j)*4/pente_shale(k,j);
                            Cap_shale_suivant(k,j)=Cap_util_shale_prev(k,j);
                        else
                            Cap_shale_suivant(k,j)=Cap_shale_0(k,j)*pente_shale(k,j)*exp(-(pente_shale(k,j)*(current_time_im+1-i_shale(k,j))))/(1+exp(-(pente_shale(k,j)*(current_time_im+1-i_shale(k,j)))))^2;
                        end
                    end
                end
            end

        end
    end
end
///////////calibration of Hubbert curves for category under exploitatin that did not stop producing in the previous tilme step
// during the growth phase: we recomute Huibbert curves parameters
for k=1:reg,
    for j=1:nb_cat_shale
        if (current_time_im>id_shale(k,j)-1)&(current_time_im>id_shale(k,j)+5)
            if (test_redem_shale(k,j)==1)&(Cap_util_shale_prev(k,j)<>0)

                pente_shale(k,j)=pente_unconv;
                //continuity
                rapport_temp=pente_shale(k,j)*Ress_shale(k,j)/0.9/Cap_util_shale_prev(k,j);
                exp_shale_temp=rapport_temp-1;

                //implies new values for i_shale and Cap_0
                i_shale(k,j)=log(exp_shale_temp)/pente_shale(k,j)+current_time_im;
                Cap_shale_0(k,j)=Ress_shale(k,j)/0.9*(1+exp_shale_temp)/exp_shale_temp;
                Cap_shale_suivant(k,j)=Cap_shale_0(k,j)*pente_shale(k,j)*exp(-(pente_shale(k,j)*(current_time_im-i_shale(k,j))))/(1+exp(-(pente_shale(k,j)*(current_time_im-i_shale(k,j)))))^2;
            end
        end
    end
end

//at the end of exploitatin, degrowth id forced by remaining reserces
for k=1:reg,
    for j=1:nb_cat_shale

        if (Ress_shale(k,j)<fract_exhausted*Ress_infini_shale(k,j))
            if Cap_exhausted_shale(k,j)==0
                Cap_exhausted_shale(k,j)=Cap_shale_suivant(k,j);
                i_exhausted_shale(k,j)=current_time_im;
                Ress_exhausted_shale(k,j)=Ress_shale(k,j);
            end
            Cap_shale_suivant(k,j)=Cap_exhausted_shale(k,j)*Ress_shale(k,j)/Ress_exhausted_shale(k,j);
        end

    end
end
//disp(Cap_util_shale,"Cap_util_shale");

Cap_util_shale=Cap_shale_suivant;

// //Inertia on the deployment of non conventional capacities
// if current_time_im<21
// inert_cap_non_conv_ref=0.95;
// for k=1:reg
// if half_extraction(k,7)==0 then Cap_util_oil(k,7)=(1-inert_cap_non_conv_ref)*Cap_util_oil(k,7)   +inert_cap_non_conv_ref*Cap_util_oil_prev(k,7); end
// end
// for k=1:reg
// for j=1:nb_cat_heavy
// if half_heavy(k,j)==0 then Cap_util_heavy(k,j)=(1-inert_cap_non_conv_ref)*Cap_util_heavy(k,j)+inert_cap_non_conv_ref*Cap_util_heavy_prev(k,j); end
// end
// end
// end
// if current_time_im>20
// inert_cap_non_conv=max(min(interpln([[21,32];[inert_cap_non_conv_ref,0]],current_time_im),1),0);
// for k=1:reg
// if half_extraction(k,7)==0 then Cap_util_oil(k,7)=  (1-inert_cap_non_conv)*Cap_util_oil(k,7)  +inert_cap_non_conv*Cap_util_oil_prev(k,7); end
// end
// for k=1:reg
// for j=1:nb_cat_heavy
// if half_heavy(k,j)==0 then Cap_util_heavy(k,j)= (1-inert_cap_non_conv)*Cap_util_heavy(k,j)+inert_cap_non_conv*Cap_util_heavy_prev(k,j); end
// end
// end
// end

if no_shale_oil
    K_expected(:,indice_oil)=sum(Cap_util_oil,"c")+sum(Cap_util_heavy,"c");
else
    K_expected(:,indice_oil)=sum(Cap_util_oil,"c")+sum(Cap_util_heavy,"c")+sum(Cap_util_shale,"c");
end

//////////////////////////////////////////////////////////////////
////////// Specific case for Middle East
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//preliminarly data

//remaining resource
Q_cum_oil_MO=Q_cum_oil_MO+Q( ind_mde, indice_oil);
Ress_oil_MO=Ress_0_oil_MO-Q_cum_oil_MO;

//we define the maximum capacity of production that could be reached during the next period (Hubbert constraint)
// we define the Hubbert curves that passe by the value Cap_MO at time current_time_Im
half_extraction_MO_prev=half_extraction_MO;
if Ress_oil_MO<Ress_infini_oil_MO*dmo_cff
    half_extraction_MO=1;
end

if half_extraction_MO==1 & half_extraction_MO_prev==0
    i_hubbert_MO=current_time_im;
    Cap_max_hubbert_MO=Cap(ind_mde,indice_oil);
    pente_hubbert_MO=pente_conv;
    Cap_0_MO=Cap_max_hubbert_MO*4/pente_hubbert_MO;
    Cap_hubbert_MO_max=Cap_0_MO*pente_hubbert_MO*exp(-(pente_hubbert_MO*(current_time_im+1-i_hubbert_MO)))/(1+exp(-(pente_hubbert_MO*(current_time_im+1-i_hubbert_MO))))^2;
end

if (Ress_oil_MO<5*Q(ind_mde,indice_oil))&(depletion_finale_MO==0)
    depletion_finale_MO=1;
end

if (half_extraction_MO==1)&(current_time_im>i_hubbert_MO+1)&(Ress_oil_MO>0)&(depletion_finale_MO==0)
    pente_hubbert_MO=fsolve(pente_hubbert_MO,hubbert_slope_MO);
    exp_temp=exp(-(pente_hubbert_MO*(current_time_im-i_hubbert_MO)));
    Cap_0_MO=Ress_oil_MO/0.9*1/(1-1/(1+exp_temp));
    Cap_hubbert_MO_max=Cap_0_MO*pente_hubbert_MO*exp(-(pente_hubbert_MO*(current_time_im+1-i_hubbert_MO)))/(1+exp(-(pente_hubbert_MO*(current_time_im+1-i_hubbert_MO))))^2;
end

if depletion_finale_MO==1
    Cap_hubbert_MO_max=0.95*Cap_prev(ind_mde,indice_oil);
end

//M%iddle East behavior during the growht phase along the Hubbert curve
Cap_MO_prev=Cap_MO;

///////////////First Middle East strategy: targeting a market share

if scenario_oil_MSMO==1
    if current_time_im>1
        Dem_oil_ant=sum(Q(:,indice_oil),"r")*(1+(sum(Q(:,indice_oil),"r")-sum(Q_prev(:,indice_oil),"r"))/sum(Q_prev(:,indice_oil),"r"));end // constant growth rate expectation for global oil demand
    charge_ant=sum(Q(:,indice_oil).*charge(:,indice_oil),"r")/sum(Q(:,indice_oil),"r");//charge anticipée constante

    ///////////Middle East behavior
    if current_time_im>1
    else  Cap_MO=Cap( ind_mde,indice_oil)*(1+txCap(ind_mde,indice_oil));
    end
end

if scenario_oil_MSMO==0
    if current_time_im>1
        taux_oil_prix_prev_obj=taux_oil_prix_obj;
    else
        taux_oil_prix_prev_obj=1;
    end

    overshoot_taux_oil_prix = p(ind_mde,indice_oil) / pref(ind_mde,indice_oil)./taux_oil_prix_prev_obj / p(1,indice_composite);

    //////////////Second Middle East strategy: targeting a global price by adjusting its producing capacities
    //next year oil produciton expectation
    if current_time_im==1
        Cap_MO_prev=Cap( ind_mde,indice_oil);
    end

    Q_oil_anticip=Q(:,indice_oil).*taux_Q_nexus(:,indice_oil);
    Q_oil_anticip_world=sum(Q_oil_anticip);

    //Expected oil prodcution for Middle East
    Q_oil_anticip_MO=Q_oil_anticip_world;
    for k=fatal_producer
        Q_oil_anticip_MO=Q_oil_anticip_MO-K_expected(k,indice_oil).*charge(k,indice_oil);
    end

    //Perfect expectation
    if current_time_im<7
        taux_oil_prix_obj=(100/pref(ind_mde,indice_oil)*tep2oilbarrels-1)/(6-1)*(current_time_im-1)+1;
        taux_oil_prix=taux_oil_prix_obj;
    else
        taux_oil_prix_obj=prf_cff/pref(ind_mde,indice_oil)*tep2oilbarrels;
        taux_oil_prix=taux_oil_prix_obj;
        if ~is_bau & mean(taxval_nex_oil)>5 & current_time_im >= start_year_strong_policy-base_year_simulation // The tax incentive begins after start_year_strong_policy
            if half_extraction_MO==1
                //taux_oil_prix_obj=(interpln([[i_hubbert_MO,i_hubbert_MO+35];[70,100]],current_time_im))/pref(ind_mde,indice_oil)*tep2oilbarrels;
                taux_oil_prix_obj=(interpln([[i_hubbert_MO,i_hubbert_MO+35];[80,100]],current_time_im))/pref(ind_mde,indice_oil)*tep2oilbarrels;
                taux_oil_prix=(taux_oil_prix_obj*pref(ind_mde,indice_oil)/tep2oilbarrels+max(min(interpln([[taux_oil_prix_prev_obj*pref(ind_mde,indice_oil)/tep2oilbarrels-10,taux_oil_prix_prev_obj*pref(ind_mde,indice_oil)/tep2oilbarrels+10];[40,-40]],wp_oil),40),-40))/pref(ind_mde,indice_oil)*tep2oilbarrels;
            end
            if test_100==1
                taux_oil_prix=prf_cff/pref(ind_mde,indice_oil)*tep2oilbarrels;
            end
        end
    end



    ii=0;
    info=4;
    [charge_obj_MO,v,info]=fsolve(charge( ind_mde,indice_oil),calib_UR_oil_MO);
    while (ii < 10 & info ==4)
        [charge_obj_MO,v,info]=fsolve(charge_obj_MO,calib_UR_oil_MO);
        ii = ii+1;
    end
    if info==4
        disp("pb fsolve calib_UR_oil_MO");
        pbcalib_UR_oil_MO=current_time_im;
        mksav("pbcalib_UR_oil_MO");
    end

    Cap_MO=1*Q_oil_anticip_MO/charge_obj_MO+0*Cap_MO_prev;

    // 	if current_time_im==1 then etude_oil_price_MO=zeros(5*reg+2+1,TimeHorizon+1); end
    // 	etude_oil_price_MO(:,current_time_im)=[Q_oil_anticip;
    // 				   Q_oil_anticip_MO;
    // 				   charge_obj_MO;
    // 				   Q(:,indice_oil);
    // 				   charge(:,indice_oil);
    // 				   p(:,indice_oil)/p(1,7);
    // 				   p(:,indice_gas)/p(1,7);
    // 				   wp(indice_oil)/p(1,7)];
    // 	fprintfMat(SAVEDIR+"etude_oil_price_MO.csv",etude_oil_price_MO,"%5.8e");
end

//////////////////////////////////////////////////////////////////////////////////////
////Preventing for a too fast increase of Middle East capacities: txCapMOmax 
Cap_MO=min(Cap_MO,Cap_prev( ind_mde,indice_oil)+txCapMOmax*365/tep2oilbarrels);

//////////////////////////////////////////////////////////////////////////////////////

//smoothing Cap_MO variations around the production peak
if half_extraction_MO==0
    if Ress_oil_MO<Ress_infini_oil_MO*(dmo_cff+0.1)
        //Cap_MO=min(Cap_MO,Cap_MO_prev*max(min(interpln([[Ress_infini_oil_MO*0.6,Ress_infini_oil_MO*0.5];[1.04,1]],Ress_oil_MO),1.1),1));
        Cap_MO=min(Cap_MO,Cap_MO_prev*max(min(interpln([[Ress_infini_oil_MO*(1-dmo_cff-0.1),Ress_infini_oil_MO*(1-dmo_cff)];[1.04,1]],Ress_oil_MO),1.1),1));
    end
end

////////////////////////////////////////////////////////////////
// Finallky we apply Hubbert curves constraint on top on the Middle East strategy
if half_extraction_MO==1
    //Cap_MO=min(interpln([[Cap_MO,Cap_hubbert_MO_max,Cap_hubbert_MO_max];[i_hubbert_MO,i_hubbert_MO+5,TimeHorizon+1]],current_time_im),Cap_MO);
    Cap_MO=min (Cap_MO,Cap_hubbert_MO_max);
end

// We prevent for fast decreease in Middle East production capacities
Cap_MO=max(Cap_MO,Cap_prev( ind_mde,indice_oil) * max_decrease_MO_cap);

K_expected( ind_mde, indice_oil)=Cap_MO;

if no_shale_oil
    share_NC=(sum(Cap_util_heavy))/sum(K_expected(:,indice_oil),"r");
else
    share_NC=(sum(Cap_util_heavy)+sum(Cap_util_shale))/sum(K_expected(:,indice_oil),"r");
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////// intermediate consumptin CI evolution
for k=1:reg
    for j=1:nb_cat_oil

        if 		(Ress_infini_oil(k,j)==0)
            alpha_oil(k,j)=0;
        else
            alpha_oil(k,j)=(((wp_lim(j)*tep2oilbarrels)*Ress_oil(k,j))+(wp_lim(j+1)*tep2oilbarrels)*(Ress_infini_oil(k,j)-Ress_oil(k,j)))/(Ress_infini_oil(k,j))/(sum(pArmCI(:,indice_oil,k)/p(1,7).*CI_oil(:,k),"r"));
        end
    end
end
//pour MO:1 seule catégorie de pétrole
alpha_oil_MO=100*(Ress_infini_oil_MO-Ress_oil_MO)/(Ress_infini_oil_MO)/(sum(pArmCI(:,indice_oil, ind_mde)/p(1,7).*CI_oil(:, ind_mde),"r"));
for k=1:reg
    if (sum(Cap_util_oil(k,:),"c")==0)
        alpha_barre(k)=0;
    else
        alpha_barre(k)=sum(Cap_util_oil(k,:).*alpha_oil(k,:),"c")./sum(Cap_util_oil(k,:),"c");
    end
end

alpha_barre(ind_mde)=alpha_oil_MO;
//disp(alpha_barre./alpha_barre_ref,'alpha_barre./alpha_barre_ref');

