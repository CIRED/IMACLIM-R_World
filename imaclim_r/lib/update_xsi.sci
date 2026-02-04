// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thomas Le-Gallic, Adrien Vogt-Schilb, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function newxsi=update_xsi(Rdisp,Ltot_prev,DF,pArmDF,hdf_cff,xsi) 
    //calcul des Xsi pour qu'ils varient avec la variation du Rdisp/Ltot

    if is_bau
        //CALIB
        //voir fichier excel "Comparaison Rdisp Xsi.xls" pour les parametres de l'equation
        param_a=0.0241; param_b=-0.3561;
        //on norme le Rdisp pour le calcul des Xsi agric en fonction de Rdisp/Ltot
        Rdisp_xsi=Rdisp.*ones(reg,1)./pref(:,indice_composite);

        //initialisation de param_xsi
        global("param_xsi")
        if current_time_im == 1 
            param_xsi = Rdisp_xsi ./ Ltot_prev .* ((param_a * ones(reg, 1) ./ xsi(:, indice_agriculture - nbsecteurenergie - 2)).^(ones(reg, 1)/param_b));
        end

        //Calcul du nouveau xsi de l'AGRICULTURE
        xsi_agr = param_a .* ((Rdisp_xsi ./ Ltot_prev ./ param_xsi).^param_b);
        //on modifie le xsi des services pour que la somme reste égale à 1
        xsi(:,indice_composite-nbsecteurenergie)=xsi(:,indice_composite-nbsecteurenergie)+xsi(:,indice_agriculture-nbsecteurenergie-2)-xsi_agr;
        xsi(:,indice_agriculture-nbsecteurenergie-2)=xsi_agr;

        //on met une asymptote sur DF(:,indice_industrie)./Ltot via les parts de budget
        //if current_time_im==1 then share_indus_income_ref=DFref(:,indice_industrie).*pArmDFref(:,indice_industrie)./Rdispref; end
        //share_indus_income_ref is never used
		
		if indice_A == 0 
            DF_indus_percap_max=DFref(:,indice_industries)./repmat(Ltot0,1,nb_sectors_industry).*repmat(hdf_cff,1,nb_sectors_industry);
        else //indice_A==1
            DF_indus_percap_max=DFref(:,indice_industries)./repmat(Ltot0,1,nb_sectors_industry).*repmat(hdf_cff,1,nb_sectors_industry)*2;
        end
		

        // if indice_dvpt_DFindus==1
        // DF_indus_percap_max=DFref(:,indice_industrie)./Ltot0.*hdf_cff;
        // end

        DF_indus_percap=DF(:,indice_industries)./repmat(Ltot_prev,1,nb_sectors_industry);
        share_indus_income=DF(:,indice_industries).*pArmDF(:,indice_industries)./repmat(Rdisp,1,nb_sectors_industry);

        for k=1:reg,
			for i=1:nb_sectors_industry,
				if DF_indus_percap(k,i)>DF_indus_percap_max(k,i) then
					share_indus_income_obj=DF_indus_percap_max(k,i)*Ltot_prev(k)*pArmDF(k,indice_industries(i))/Rdisp(k);
					xsi_ind=xsi_prev(k,indice_industries(i)-nbsecteurenergie-2)*share_indus_income_obj/share_indus_income(k,i);
					xsi(k,indice_composite-nbsecteurenergie)=xsi(k,indice_composite-nbsecteurenergie)+xsi(k,indice_industries(i)-nbsecteurenergie-2)-xsi_ind; // TOBECHECKEDAGAIN: really not confident with this change!!
					xsi(k,indice_industries(i)-nbsecteurenergie-2)=xsi_ind;
					//share_indus_income_obj/share_indus_income(k)
				end
            end
        end

        xsi=1/3*xsi+2/3*xsi_prev;

        //on coupe la MODIF DES XSI si on fait un scénario de politique
    else

        global("xsi_sav_REF")
        if isempty (xsi_sav_REF)
            ldsav("xsi_sav_REF", "",baseline_combi);
        end
        xsi=matrix(xsi_sav_REF(:,current_time_im+1),reg,-1);
    end

    newxsi=xsi;

endfunction    
