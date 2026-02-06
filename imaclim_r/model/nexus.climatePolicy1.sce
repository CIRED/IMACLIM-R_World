// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thomas Le Gallic, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// This nexus currently includes: 
//(1) first DG calculation as in V1(indexed on demographic change, not on wealth change); NB: this line was previously in dynamics.sce
//(2) the addition of charges from residential energy efficiency expenditures to DG as in V1; NB: previously in nexus.productiveSectors.eeiCosts
//(3) the implementation of one variant of carbon tax recycling.

// TODO: we should check whether this organisation is enough clear/obvious, and if yes probably rename this nexus.

///////////////// Update of government expenditures /////////////////

// DG is first computed from its initial value and the demographic evolution ...
DG=DGref.*((Ltot./Ltot0)*ones(1,sec)); //TODO: with this assumption, DG & DF diverge strongly at the end of the century. Is it consistent with past trend to index it only on demograhic change? 
if indice_LED >= 1 & current_time_im>=i_year_strong_policy
    DG(:,indus) = DG(:,indus) .* dynForc_DGindu;
end

// ... then residential energy efficiency investments for the year are charged to the government (DG), for now only in the composite sector (other variants to be tested soon)
renovation_expenditures = (K_cost_res_SLE+K_cost_res_VLE)./(pArmDG(:,indice_composite)); // Note that it includes all the expenditures in terms of residential energy efficiency improvement (renovation and new construction).
DG(:,indice_composite)=DG(:,indice_composite)+renovation_expenditures;


////////////////////////////////////////////////////////////////////////
// 	Carbon taxes
/////////////////////////////////////////////////////////////////////////

size_TAXVAL=[%nan TimeHorizon+1];
if current_time_im==2 & verbose >=1
    warning( "size_TAXVAL is a rustine");
end


////////////////////////////////////////// Recycling CO2 tax revenues by lowering labor taxes
if sc_CO2Tax_recycl=="LaborTaxReduction_old" & current_time_im>= start_year_recycl2-base_year_simulation+1
    if current_time_im==start_year_recycl2-base_year_simulation+1
        TAXSAL_prev=sum(A.*Q.*w.*l.*sigma.*(energ_sec+FCC.*non_energ_sec),'c');
        TAXCO2_prev=sum(taxCO2,'c');
        sigma_BAU=sigma;
        // TODO Take the sigma of the BAU scenario instead of the base year one
    end
    if current_time_im>start_year_recycl2-base_year_simulation+1
        TAXSAL_BAU=sum(A.*Q.*w.*l.*sigma_BAU.*(energ_sec+FCC.*non_energ_sec),'c');
        SALNET=sum(A.*Q.*w.*l.*(energ_sec+FCC.*non_energ_sec),'c');

        // we only recycle what sectors paid
        // TODO all the carbon tax: TAXCO2_dom &
        TAXCO2_recycl=sum(TAXCO2_sect_imp+TAXCO2_sect_dom,'c');

        // in case of quota exchange, carbon revenus from quota selling and buying are spread in proportin of what is paid by whom
        // for k=1:reg,
        // if TAXCO2(k)<>0
        // TAXCO2_recycl(k)=((TAXCO2(k)+QuotasRevenue(k))./TAXCO2(k)).*TAXCO2_recycl(k);
        //    end
        // end

        TAXTRADE_Ind_BAU=zeros(reg,1);
        TAXTRADE_Ind=zeros(reg,1);
        // if ind_rebate==1
        // TAXTRADE_Ind_BAU=Exp(:,indice_industrie).*p(:,indice_industrie).*xtaxref(:,indice_industrie)+...
        // Imp(:,indice_industrie).*wp(indice_industrie).*mtaxref(:,indice_industrie);
        // TAXTRADE_Ind=Exp(:,indice_industrie).*p(:,indice_industrie).*xtax(:,indice_industrie)+...
        // Imp(:,indice_industrie).*wp(indice_industrie).*mtax(:,indice_industrie);
        // end

        for k=1:reg
            for j=1:sec,
                if TAXSAL_BAU(k)<>0
                    //sigma(k,j)=max(sigma_BAU(k,j)*(TAXSAL_BAU(k)+TAXTRADE_Ind_BAU(k)-TAXTRADE_Ind(k)-TAXCO2_recycl(k))./(TAXSAL_BAU(k)),-1);
                    sigma(k,j)=max(sigma_BAU(k,j)*(TAXSAL_BAU(k)-TAXCO2_recycl(k))./(TAXSAL_BAU(k)),-1);
                    //TODO of lower than -1 for any sector, it is then redistributedto households instead
                else
                    sigma(k,j)=max((TAXTRADE_Ind_BAU(k)-TAXTRADE_Ind(k)-TAXCO2_recycl(k))./(SALNET(k)),sigmaMin);
                end
            end
        end

        if min(sigma)<-1 
            disp('PB sigma'); pause; 
        end
    end
end

if sc_CO2Tax_recycl=="LaborTaxReduction" & current_time_im >= start_year_recycl2-base_year_simulation
    // Equivalent revenues with the tax rate of the reference scenario
    TAXSAL_BAU_equivalent=sum(A.*Q.*w.*l.*base_sigma(:,:,current_time_im).*(energ_sec+FCC.*non_energ_sec),'c');
    // We recycle the full CO2 revenues
    TAXCO2_recycl=sum(TAXCO2_imp+TAXCO2_dom,'c');
    sigma = base_sigma(:,:,current_time_im) .* (((TAXSAL_BAU_equivalent-TAXCO2_recycl)./TAXSAL_BAU_equivalent) * ones(1,nb_sectors));
    if sum(sigma<-1) >0
        disp("Labor Tax recycling: to avoid negative labor costs, some of CO2 carbon tax revenues have been send back to the Housholdes+Governement budget");
    end 
    sigma = max( sigma, -1); //no negative labor costs, the rest of revenues is given back to the Housholdes+Governement budget
end
