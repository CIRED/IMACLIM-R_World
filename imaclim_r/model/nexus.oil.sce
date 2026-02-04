// Goods requirement for capital formation
// follows rise of markup (to ensure that new capital becomes more expensive as resources get exhausted)
//txmarkup(:,indice_oil) = markup(:,indice_oil) ./ markup_prev(:,indice_oil) - 1;
// for k=1:reg
//   for j=1:sec
// //	  Beta(j,indice_oil,k)=Beta(j,indice_oil,k) * (1+txmarkup(k,indice_oil));
//   end
// end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////courbe de hubbert:cas particulier de l'oil/////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


wp_oil = wp(oil) / tep2oilbarrels ;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////données préliminaires qui seront nécessaires
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//capacite de production par  categorie de couts
Cap_util_oil_prev=Cap_util_oil;
Cap_util_heavy_prev=Cap_util_heavy;
Cap_util_shale_prev=Cap_util_shale;

//on va avoir besoin des quantités d'oil restantes pour chaque région et chaque catégorie
//quantité de petrole produite par catégorie de cout.

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

//on va avoir besoin des quantités d'oil restantes pour chaque région et chaque catégorie
//quantite cummulee de petrole extraite par categorie de cout
Q_cum_oil=Q_cum_oil+Q_oil_parcategorie;
Q_cum_heavy=Q_cum_heavy+Q_heavy_parcategorie;
Q_cum_shale=Q_cum_shale+Q_shale_parcategorie;

//on retranche ce qui a ete exploite des reserves
Ress_oil=Ress_0_oil-Q_cum_oil;
Ress_oil=max(Ress_oil,0);

Ress_heavy=Ress_0_heavy-Q_cum_heavy;
Ress_heavy=max(Ress_heavy,0);

Ress_shale=Ress_0_shale-Q_cum_shale;
Ress_shale=max(Ress_shale,0);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////petrole conventionnel
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////décisions de mise en exploitation
test_premexploit_oil;
//décision de première mise en exploitation des puits
testPremExploitOilprev=test_premexploit_oil;

//boucle pour actualiser la variable booleene de premiere mise en exploitation
for k=fatal_producer,
    for j=1:nb_cat_oil,
        if ((test_premexploit_oil(k,j)==0)&((wp(indice_oil))>wp_lim(j)*tep2oilbarrels))
            test_premexploit_oil(k,j)=1;
        end
    end
end

//décision de mise en exploitation des puits
for k=fatal_producer,
    for j=1:nb_cat_oil,
        if ((wp(indice_oil))>wp_lim(j)*tep2oilbarrels)
            test_exploit_oil(k,j)=1;
        else
            test_exploit_oil(k,j)=0;
        end
    end
end


///////////////////calibration des courbes
//calibration des courbes de hubbert pour la première mise en exploitation
if current_time_im>1
    pente_hubbert;
    Cap_0;
end
for k=fatal_producer,
    for j=1:nb_cat_oil,
        if (test_premexploit_oil(k,j)==1)&(testPremExploitOilprev(k,j)==0)
            if Ress_infini_oil(k,j)<>0
                //Si la reserve est non nulle, on calcule les parametres de la courbe de hubbert
                id_oil(k,j)=current_time_im;
                pente_hubbert(k,j)=pente_conv;
                Cap_0(k,j)= Ress_infini_oil(k,j)/base_charge_noFCC(indice_oil);
                Ress_0_oil(k,j) = share_ress_HubbertCurves * Ress_infini_oil(k,j);
                exp_temp(k,j)=(Ress_0_oil(k,j)/Ress_infini_oil(k,j))/(1-Ress_0_oil(k,j)/Ress_infini_oil(k,j));
                //date du pic pour la categorie consideree
                i_hubbert(k,j)=log(exp_temp(k,j))/pente_hubbert(k,j)+current_time_im;


                Cap_hubbert_suivant(k,j)=hs_oil*Cap_0(k,j)*pente_hubbert(k,j)/4;
            else
                //S'il la reserve est nulle, la courbe de hubbert est nulle
                id_oil(k,j)=current_time_im;
                pente_hubbert(k,j)=pente_conv;
                Cap_0(k,j)= Ress_infini_oil(k,j)/base_charge_noFCC(indice_oil);
                Ress_0_oil(k,j)=1;
                exp_temp(k,j)=2;
                //date du pic pour la categorie consideree
                i_hubbert(k,j)=log(exp_temp(k,j))/pente_hubbert(k,j)+current_time_im;

                Cap_hubbert_suivant(k,j)=hs_oil*Cap_0(k,j)*pente_hubbert(k,j)/4;
            end
        end
    end
end

//calibration des courbes de Hubbert pour les nappes déjà en exploitation
half_extraction_prev=half_extraction;

for k=fatal_producer,
    for j=1:nb_cat_oil

        ////////1er cas: on a envie de mettre les puits en exploitation
        if (test_exploit_oil(k,j)==1)
            ////quand on vient d'exploiter la moitié des ressources, on recalibre les paramètres des courbes de Hubbert pour la décroissance ...
            if (Ress_oil(k,j)<0.5*Ress_infini_oil(k,j))&(half_extraction(k,j)==0)
                i_hubbert(k,j)=current_time_im;
                half_extraction(k,j)=1;
                Cap_max_hubbert(k,j)=Cap_util_oil_prev(k,j);
                pente_hubbert(k,j)=pente_conv;
                Cap_0(k,j)=Cap_max_hubbert(k,j)*4/pente_hubbert(k,j);
            end

            //recalcul de la pente à la décroissance
            if (half_extraction(k,j)==1)&(current_time_im>i_hubbert(k,j)+1)&Ress_oil(k,j)>0
                pente_hubbert(k,j)=fsolve(pente_hubbert(k,j),hubbert_slope);
                exp_temp=max(exp(-(pente_hubbert(k,j)*(current_time_im-i_hubbert(k,j)))),%eps);
                Cap_0(k,j)=Ress_oil(k,j)/0.9*1/(1-1/(1+exp_temp));
            end

            Cap_hubbert_suivant(k,j)=Cap_0(k,j)*pente_hubbert(k,j)*exp(-(pente_hubbert(k,j)*(current_time_im+1-i_hubbert(k,j))))/(1+exp(-(pente_hubbert(k,j)*(current_time_im+1-i_hubbert(k,j)))))^2;

            ////si on a exploité les ressources moins vite que "prévu", on a un plateau avant la décroissance

            if (Ress_oil(k,j)>0.5*Ress_infini_oil(k,j))&(current_time_im>i_hubbert(k,j))
                Cap_hubbert_suivant(k,j)=Cap_util_oil_prev(k,j);
            end
            //on lisse les mises en services de capacites
            if (j>3)&(current_time_im>id_oil(k,j)-1)&(current_time_im<id_oil(k,j)+5)
                Cap_hubbert_suivant(k,j)=(current_time_im-id_oil(k,j))/4*Cap_0(k,j)*pente_hubbert(k,j)*exp(-(pente_hubbert(k,j)*(id_oil(k,j)+4-i_hubbert(k,j))))/(1+exp(-(pente_hubbert(k,j)*(id_oil(k,j)+4-i_hubbert(k,j)))))^2;
            end
        end


        ////////2eme cas: on n'a pas envie de mettre les puits en exploitation
        if (test_exploit_oil(k,j)==0)
            // si on n'est pas contraint par la déplétion, on garde le même niveau de capacités...

            if (Ress_oil(k,j)>0.5*Ress_infini_oil(k,j))
                Cap_hubbert_suivant(k,j)=Cap_util_oil_prev(k,j);
            end

            //...sinon on est forcé de suivre la décroissance

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
//capacités mises en service par les "fatal producers":courbes de hubbert

Cap_util_oil=Cap_hubbert_suivant;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//pétrole non conventionnel
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Ceci est completement arbitraire et devrait etre corrigé
taxval_nex_oil = max(taxCO2_CI(:,indice_oil,:))*1e6; //taxval_nex_oil en $/t, taxCO2_CI en M$/t

if current_time_im==2
    warning("taxval is is set to max(taxCO2_CI(:,indice_oil,:))*1e6 in nexus.oil")
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//HEAVY OIL
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
price_lag_heavy=1;
//valeurs limites de rentabilité des catégories
wp_lim_heavy=(prodcost_heavy+min(taxval_nex_oil,40)*emission_heavy)*price_lag_heavy;
//wp_lim_heavy=(prodcost_heavy+0*TAXVAL_Poles(1,min(current_time_im,size_TAXVAL(2)))*emission_heavy)*price_lag_heavy;

//////////////////décisions de mise en exploitation
//décision de première mise en exploitation des puits
test_heavy_prev=test_heavy;
test_prem_heavy_prev=test_prem_heavy;

//boucle pour actualiser la variable booleene de première mise en exploitation
for k=1:reg,
    for j=1:nb_cat_heavy,
        if ((test_prem_heavy(k,j)==0)&(wp(indice_oil))>wp_lim_heavy(j)*tep2oilbarrels)
            test_prem_heavy(k,j)=1;
        end
    end
end

//boucle pour actualiser la variable booleene de mise en exploitation
for k=1:reg,
    for j=1:nb_cat_heavy,
        if ((test_prem_heavy(k,j)==1)&((wp(indice_oil))>wp_lim_heavy(j)*tep2oilbarrels))
            test_heavy(k,j)=1;
        else
            test_heavy(k,j)=0;
        end
    end
end



//boucle pour actualiser la variable booleene de redemarrage de la mise en exploitation en phase de croissance
for k=1:reg,
    for j=1:nb_cat_heavy,
        if (test_prem_heavy_prev(k,j)==1)&(test_heavy_prev(k,j)==0)&(test_heavy(k,j)==1)&(half_heavy(k,j)==0)
            test_redem_heavy(k,j)=1;
        else
            test_redem_heavy(k,j)=0;
        end
    end
end
//////////calibration des courbes de Hubbert pour la première mise en exploitation

for k=1:reg,
    for j=1:nb_cat_heavy,
        if (test_prem_heavy(k,j)==1)&(test_prem_heavy_prev(k,j)==0)
            if Ress_infini_heavy(k,j)<>0
                //Si la reserve est non nulle, on calcule les parametres de la courbe de hubbert
                id_heavy(k,j)=current_time_im;
                pente_heavy(k,j)=pente_unconv;
                Cap_heavy_0(k,j)= Ress_infini_heavy(k,j)/base_charge_noFCC(indice_oil);
                // exp_temp(k,j)=(2/hs_heavy-1)+2/hs_heavy*(1-hs_heavy)^0.5;
                // Ress_0_heavy(k,j)=exp_temp(k,j)/(1+exp_temp(k,j))*Ress_infini_heavy(k,j);
                Ress_0_heavy(k,j)= share_ress_HubbertCurves *Ress_infini_heavy(k,j);
                exp_temp(k,j)=(Ress_0_heavy(k,j)/Ress_infini_heavy(k,j))/(1-Ress_0_heavy(k,j)/Ress_infini_heavy(k,j));
                //date du pic pour la categorie consideree
                i_heavy(k,j)=log(exp_temp(k,j))/pente_heavy(k,j)+current_time_im;


                Cap_heavy_suivant(k,j)=hs_heavy*Cap_heavy_0(k,j)*pente_heavy(k,j)/4;
            else
                //S'il la reserve est nulle, la courbe de hubbert est nulle
                id_heavy(k,j)=current_time_im;
                pente_heavy(k,j)=pente_unconv;
                Cap_heavy_0(k,j)= 0;
                Ress_0_heavy(k,j)=1;
                exp_temp(k,j)=2;
                //date du pic pour la categorie consideree
                i_heavy(k,j)=log(exp_temp(k,j))/pente_heavy(k,j)+current_time_im;

                Cap_heavy_suivant(k,j)=hs_heavy*Cap_heavy_0(k,j)*pente_heavy(k,j)/4;
            end
        end
    end
end

///////////calibration des courbes de Hubbert pour les nappes déjà en exploitation
half_heavy_prev=half_heavy;
for k=1:reg,
    for j=1:nb_cat_heavy
        if test_prem_heavy(k,j)==1
            if (current_time_im>id_heavy(k,j)-1)&(current_time_im<id_heavy(k,j)+5)
                Cap_heavy_suivant(k,j)=(current_time_im-id_heavy(k,j)+1)/5*Cap_heavy_0(k,j)*pente_heavy(k,j)*exp(-(pente_heavy(k,j)*(id_heavy(k,j)+4-i_heavy(k,j))))/(1+exp(-(pente_heavy(k,j)*(id_heavy(k,j)+4-i_heavy(k,j)))))^2;

            elseif (current_time_im>=id_heavy(k,j)+5)

                if test_redem_heavy(k,j)==0 // pour les nappes qui n'ont pas été arretees à la période précédente

                    ////////1er cas: on a envie de mettre les puits en exploitation
                    if (test_heavy(k,j)==1)
                        ////quand on vient d'exploiter la moitié des ressources, on recalibre les paramètres des courbes de Hubbert pour la décroissance ...
                        if (Ress_heavy(k,j)<0.5*Ress_infini_heavy(k,j))&(half_heavy(k,j)==0)
                            i_heavy(k,j)=current_time_im;
                            half_heavy(k,j)=1;
                            Cap_max_heavy(k,j)=Cap_util_heavy_prev(k,j);
                            pente_heavy(k,j)=pente_unconv;
                            Cap_heavy_0(k,j)=Cap_max_heavy(k,j)*4/pente_heavy(k,j);
                        end

                        //recalcul de la pente à la décroissance
                        if (half_heavy(k,j)==1)&(current_time_im>i_heavy(k,j)+1)&Ress_heavy(k,j)>0
                            pente_heavy(k,j)=fsolve(pente_heavy(k,j),hubbert_heavy_slope);
                            exp_temp=exp(-(pente_heavy(k,j)*(current_time_im-i_heavy(k,j))));
                            Cap_heavy_0(k,j)=Ress_heavy(k,j)/0.9*1/(1-1/(1+exp_temp));
                        end
                        ////...sinon on garde les paramètres définis à la mise en service

                        Cap_heavy_suivant(k,j)=Cap_heavy_0(k,j)*pente_heavy(k,j)*exp(-(pente_heavy(k,j)*(current_time_im+1-i_heavy(k,j))))/(1+exp(-(pente_heavy(k,j)*(current_time_im+1-i_heavy(k,j)))))^2;

                        ////si on a exploité les ressources moins vite que "prévu", on a un plateau avant la décroissance

                        if (Ress_heavy(k,j)>0.5*Ress_infini_heavy(k,j))&(current_time_im>i_heavy(k,j))
                            Cap_heavy_suivant(k,j)=Cap_util_heavy_prev(k,j);
                        end

                        //on lisse la mise en service des nouvelles capacites
                        if j>2
                            if (current_time_im>id_heavy(k,j)-1)&(current_time_im<id_heavy(k,j)+5)
                                Cap_heavy_suivant(k,j)=(current_time_im-id_heavy(k,j)+1)/5*Cap_heavy_0(k,j)*pente_heavy(k,j)*exp(-(pente_heavy(k,j)*(id_heavy(k,j)+4-i_heavy(k,j))))/(1+exp(-(pente_heavy(k,j)*(id_heavy(k,j)+4-i_heavy(k,j)))))^2;
                            end
                        end
                    end

                    ////////2eme cas: on n'a pas envie de mettre les puits en exploitation
                    if (test_heavy(k,j)==0)
                        // si on n'est pas contraint par la déplétion, on garde le même niveau de capacités...

                        if (Ress_heavy(k,j)>0.5*Ress_infini_heavy(k,j))
                            Cap_heavy_suivant(k,j)=Cap_util_heavy_prev(k,j);
                        end

                        //...sinon on est forcé de suivre la décroissance

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

                ///////////calibration des courbes de Hubbert pour les nappes déjà en exploitation et qui ont été arretees à la période précédente
                //quand on est en phase de croissance, il faut redéfinir les paramètres de la courbe

                if (test_redem_heavy(k,j)==1)&(Cap_util_heavy_prev(k,j)<>0)
                    if (current_time_im>=id_heavy(k,j)+5)
                        pente_heavy(k,j)=pente_unconv;
                        //condition de continuité
                        rapport_temp=pente_heavy(k,j)*Ress_heavy(k,j)/0.9/Cap_util_heavy_prev(k,j);
                        exp_heavy_temp=rapport_temp-1;

                        //on en déduit la nouvelle valeur de i_heavy et de Cap_0
                        i_heavy(k,j)=log(exp_heavy_temp)/pente_heavy(k,j)+current_time_im;
                        Cap_heavy_0(k,j)=Ress_heavy(k,j)/0.9*(1+exp_heavy_temp)/exp_heavy_temp;
                        Cap_heavy_suivant(k,j)=Cap_heavy_0(k,j)*pente_heavy(k,j)*exp(-(pente_heavy(k,j)*(current_time_im-i_heavy(k,j))))/(1+exp(-(pente_heavy(k,j)*(current_time_im-i_heavy(k,j)))))^2;
                    end
                end
            end


            //en fin d'exploitation, la décroissance est forcée par les réserves restantes

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
//Julie : modif Total : limitation de la croissance des non conventionnels à 0.4mbd/an au Canada
//Cap_util_heavy( 2,:) = min ( Cap_heavy_suivant( 2,:), Cap_util_heavy_prev( 2,:)+0.4*365/tep2oilbarrels);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//shale OIL
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
price_lag_shale=1;

//valeurs limites de rentabilité des catégories
wp_lim_shale=(prodcost_shale+0*taxval_nex_oil*emission_shale)*price_lag_shale;

//////////////////décisions de mise en exploitation
//décision de première mise en exploitation des puits
test_shale_prev=test_shale;
test_prem_shale_prev=test_prem_shale;

//boucle pour actualiser la variable booleene de première mise en exploitation
for k=1:reg,
    for j=1:nb_cat_shale,
        if ((test_prem_shale(k,j)==0)&(wp(indice_oil))>wp_lim_shale(j)*tep2oilbarrels)
            i_test_prem_shale(k,j)=current_time_im;
            test_prem_shale(k,j)=1;
        end
    end
end

//boucle pour actualiser la variable booleene de mise en exploitation
for k=1:reg,
    for j=1:nb_cat_shale,
        if ((test_prem_shale(k,j)==1)&((wp(indice_oil))>wp_lim_shale(j)*tep2oilbarrels)&(current_time_im>=i_test_prem_shale(k,j)))
            test_shale(k,j)=1;
        else
        test_shale(k,j)=0;end
    end
end



//boucle pour actualiser la variable booleene de redemarrage de la mise en exploitation en phase de croissance
for k=1:reg,
    for j=1:nb_cat_shale,
        if (test_prem_shale_prev(k,j)==1)&(test_shale_prev(k,j)==0)&(test_shale(k,j)==1)&(half_shale(k,j)==0)
            test_redem_shale(k,j)=1;
        else
            test_redem_shale(k,j)=0;
        end
    end
end
//////////calibration des courbes de Hubbert pour la première mise en exploitation
Cap_shale_suivant;
for k=1:reg,
    for j=1:nb_cat_shale,
        if (test_prem_shale(k,j)==1)&(test_prem_shale_prev(k,j)==0)
            if Ress_infini_shale(k,j)<>0
                //Si la reserve est non nulle, on calcule les parametres de la courbe de hubbert
                id_shale(k,j)=current_time_im;
                pente_shale(k,j)=pente_unconv;
                Cap_shale_0(k,j)= Ress_infini_shale(k,j)/base_charge_noFCC(indice_oil);
                exp_temp(k,j)=(2/hs_shale-1)+2/hs_shale*(1-hs_shale)^0.5;
                Ress_0_shale(k,j)=exp_temp(k,j)/(1+exp_temp(k,j))*Ress_infini_shale(k,j);
                //date du pic pour la categorie consideree
                i_shale(k,j)=log(exp_temp(k,j))/pente_shale(k,j)+current_time_im;


                Cap_shale_suivant(k,j)=hs_shale*Cap_shale_0(k,j)*pente_shale(k,j)/4;
            else
                //S'il la reserve est nulle, la courbe de hubbert est nulle
                id_shale(k,j)=current_time_im;
                pente_shale(k,j)=pente_unconv;
                Cap_shale_0(k,j)= 0;
                Ress_0_shale(k,j)=1;
                exp_temp(k,j)=2;
                //date du pic pour la categorie consideree
                i_shale(k,j)=log(exp_temp(k,j))/pente_shale(k,j)+current_time_im;

                Cap_shale_suivant(k,j)=hs_shale*Cap_shale_0(k,j)*pente_shale(k,j)/4;
            end
        end
    end
end

///////////calibration des courbes de Hubbert pour les nappes déjà en exploitation et qui n'ont pas été arretees à la période précédente
half_shale_prev=half_shale;
for k=1:reg,
    for j=1:nb_cat_shale
        if test_redem_shale(k,j)==0
            ////////1er cas: on a envie de mettre les puits en exploitation
            if (test_shale(k,j)==1)
                ////quand on vient d'exploiter la moitié des ressources, on recalibre les paramètres des courbes de Hubbert pour la décroissance ...
                if (Ress_shale(k,j)<0.5*Ress_infini_shale(k,j))&(half_shale(k,j)==0)
                    i_shale(k,j)=current_time_im;
                    half_shale(k,j)=1;
                    Cap_max_shale(k,j)=Cap_util_shale_prev(k,j);
                    pente_shale(k,j)=pente_unconv;
                    Cap_shale_0(k,j)=Cap_max_shale(k,j)*4/pente_shale(k,j);
                end
                //recalcul de la pente à la décroissance
                if (half_shale(k,j)==1)&(current_time_im>i_shale(k,j)+1)&Ress_shale(k,j)>0
                    pente_shale(k,j)=fsolve(pente_shale(k,j),hubbert_shale_slope);
                    exp_temp=exp(-(pente_shale(k,j)*(current_time_im-i_shale(k,j))));
                    Cap_shale_0(k,j)=Ress_shale(k,j)/0.9*1/(1-1/(1+exp_temp));
                end
                ////...sinon on garde les paramètres définis à la mise en service

                Cap_shale_suivant(k,j)=Cap_shale_0(k,j)*pente_shale(k,j)*exp(-(pente_shale(k,j)*(current_time_im+1-i_shale(k,j))))/(1+exp(-(pente_shale(k,j)*(current_time_im+1-i_shale(k,j)))))^2;

                ////si on a exploité les ressources moins vite que "prévu", on a un plateau avant la décroissance

                if (Ress_shale(k,j)>0.5*Ress_infini_shale(k,j))&(current_time_im>i_shale(k,j))
                    Cap_shale_suivant(k,j)=Cap_util_shale_prev(k,j);
                end

                //on lisse la mise en service des nouvelles capacites

                if (current_time_im>id_shale(k,j)-1)&(current_time_im<id_shale(k,j)+5)
                    Cap_shale_suivant(k,j)=(current_time_im-id_shale(k,j))/4*Cap_shale_0(k,j)*pente_shale(k,j)*exp(-(pente_shale(k,j)*(id_shale(k,j)+4-i_shale(k,j))))/(1+exp(-(pente_shale(k,j)*(id_shale(k,j)+4-i_shale(k,j)))))^2;
                end
            end
            ////////2eme cas: on n'a pas envie de mettre les puits en exploitation
            if (test_shale(k,j)==0)
                if (current_time_im>id_shale(k,j)-1)&(current_time_im>id_shale(k,j)+5)
                    // si on n'est pas contraint par la déplétion, on garde le même niveau de capacités...

                    if (Ress_shale(k,j)>0.5*Ress_infini_shale(k,j))
                        Cap_shale_suivant(k,j)=Cap_util_shale_prev(k,j);
                    end

                    //...sinon on est forcé de suivre la décroissance

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
///////////calibration des courbes de Hubbert pour les nappes déjà en exploitation et qui ont été arretees à la période précédente
//quand on est en phase de croissance, il faut redéfinir les paramètres de la courbe
for k=1:reg,
    for j=1:nb_cat_shale
        if (current_time_im>id_shale(k,j)-1)&(current_time_im>id_shale(k,j)+5)
            if (test_redem_shale(k,j)==1)&(Cap_util_shale_prev(k,j)<>0)

                pente_shale(k,j)=pente_unconv;
                //condition de continuité
                rapport_temp=pente_shale(k,j)*Ress_shale(k,j)/0.9/Cap_util_shale_prev(k,j);
                exp_shale_temp=rapport_temp-1;

                //on en déduit la nouvelle valeur de i_shale et de Cap_0
                i_shale(k,j)=log(exp_shale_temp)/pente_shale(k,j)+current_time_im;
                Cap_shale_0(k,j)=Ress_shale(k,j)/0.9*(1+exp_shale_temp)/exp_shale_temp;
                Cap_shale_suivant(k,j)=Cap_shale_0(k,j)*pente_shale(k,j)*exp(-(pente_shale(k,j)*(current_time_im-i_shale(k,j))))/(1+exp(-(pente_shale(k,j)*(current_time_im-i_shale(k,j)))))^2;
            end
        end
    end
end

//en fin d'exploitation, la décroissance est forcée par les réserves restantes
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

// //on met de l'inertie sur le déploiement des non Conv
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
//////////cas particulier du MO
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//données préliminaires

//on va avoir besoin de la quantité de pétrole restant à la date i
Q_cum_oil_MO=Q_cum_oil_MO+Q( ind_mde, indice_oil);
Ress_oil_MO=Ress_0_oil_MO-Q_cum_oil_MO;

//on définit la capacité maximale qui pourra être atteinte à la période suivante (contrainte de Hubbert):on définit la courbe de Hubbert qui passe par la valeur Cap_MO à la date i

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

//maintenant on décrit le comportement du MO quand il est en phase de croissance de Hubbert
Cap_MO_prev=Cap_MO;

// /////////////premiere version, le moyen orient vise une part de marché

if scenario_oil_MSMO==1
    if current_time_im>1
    Dem_oil_ant=sum(Q(:,indice_oil),"r")*(1+(sum(Q(:,indice_oil),"r")-sum(Q_prev(:,indice_oil),"r"))/sum(Q_prev(:,indice_oil),"r"));end //anticipation d'un taux de croissance constant de la demande de pétrole mondiale
    charge_ant=sum(Q(:,indice_oil).*charge(:,indice_oil),"r")/sum(Q(:,indice_oil),"r");//charge anticipée constante

    ///////////comportement du MO
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

    //////////////deuxieme version, le MO adapte sa capacite pour viser un prix mondial donne
    //on anticipe la quantité de petrole produite a l'annee suivante
    if current_time_im==1
        Cap_MO_prev=Cap( ind_mde,indice_oil);
    end

    Q_oil_anticip=Q(:,indice_oil).*taux_Q_nexus(:,indice_oil);
    Q_oil_anticip_world=sum(Q_oil_anticip);

    //on anticipe la quantité de pétrole que devra produire la moyen orient
    Q_oil_anticip_MO=Q_oil_anticip_world;
    for k=fatal_producer
        Q_oil_anticip_MO=Q_oil_anticip_MO-K_expected(k,indice_oil).*charge(k,indice_oil);
    end

    //anticipation parfaite
    if current_time_im<7
        taux_oil_prix_obj=(100/pref(ind_mde,indice_oil)*tep2oilbarrels-1)/(6-1)*(current_time_im-1)+1;
        taux_oil_prix=taux_oil_prix_obj;
    else
        taux_oil_prix_obj=prf_cff/pref(ind_mde,indice_oil)*tep2oilbarrels;
        taux_oil_prix=taux_oil_prix_obj;
        if ~is_bau & mean(taxval_nex_oil)>5 & current_time_im >= start_year_strong_policy-base_year_simulation // l'incitation par la taxe commence avec la taxe et pas 2001
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
    // 				   p(:,indice_gaz)/p(1,7);
    // 				   wp(indice_oil)/p(1,7)];
    // 	fprintfMat(SAVEDIR+"etude_oil_price_MO.csv",etude_oil_price_MO,"%5.8e");
end

//////////////////////////////////////////////////////////////////////////////////////
////**Julie: pour Total, on empêche une croissance trop forte des capacités du MO**///
//////////////////////////////////////////////////////////////////////////////////////

//txCapMOmax défini dans alternatives_scenar_Total en Mdb
Cap_MO=min(Cap_MO,Cap_prev( ind_mde,indice_oil)+txCapMOmax*365/tep2oilbarrels);

//////////////////////////////////////////////////////////////////////////////////////

//on lisse la variation de Cap_MO au voisinage du pic

if half_extraction_MO==0
    if Ress_oil_MO<Ress_infini_oil_MO*(dmo_cff+0.1)
        //Cap_MO=min(Cap_MO,Cap_MO_prev*max(min(interpln([[Ress_infini_oil_MO*0.6,Ress_infini_oil_MO*0.5];[1.04,1]],Ress_oil_MO),1.1),1));
        Cap_MO=min(Cap_MO,Cap_MO_prev*max(min(interpln([[Ress_infini_oil_MO*(1-dmo_cff-0.1),Ress_infini_oil_MO*(1-dmo_cff)];[1.04,1]],Ress_oil_MO),1.1),1));
    end
end

////////////////////////////////////////////////////////////////
//Finalement, les capacités mises en service par le MO en tenant compte des contraintes de hubbert
if half_extraction_MO==1
    //Cap_MO=min(interpln([[Cap_MO,Cap_hubbert_MO_max,Cap_hubbert_MO_max];[i_hubbert_MO,i_hubbert_MO+5,TimeHorizon+1]],current_time_im),Cap_MO);
    Cap_MO=min (Cap_MO,Cap_hubbert_MO_max);
end

//si on est en fin de période, on empèche les décroissances trop brusques de la capacité MO
// modif: was after 2050, but leads to a decrease in capacity too important (todo: discuss model when Cap(MDE) << Cap(RoW) )
// if current_time_im>50
Cap_MO=max(Cap_MO,Cap_prev( ind_mde,indice_oil) * max_decrease_MO_cap);
// end


K_expected( ind_mde, indice_oil)=Cap_MO;

if no_shale_oil
    share_NC=(sum(Cap_util_heavy))/sum(K_expected(:,indice_oil),"r");
else
    share_NC=(sum(Cap_util_heavy)+sum(Cap_util_shale))/sum(K_expected(:,indice_oil),"r");
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////évolution des CI
////////////évolution des alpha_oil
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

// for k=1:reg
// 	CI(:,indice_oil,k)=(alpha_barre(k)/alpha_barre_ref(k))*CI_oil(:,k);
// //on coupe les CI d'interconsommation
// 	CI(indice_oil,indice_oil,k)=CI_oil(indice_oil,k);
// end
