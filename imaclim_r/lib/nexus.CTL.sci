// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Nicolas Graves, Thomas Le Gallic, Ruben Bibas, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function [Q_CTL_anticip,p_CTL_mtep,price_CTL,Cost_struc_CTL]=nexusCTL(ctl_inert_lag)
    //

    //PREAMBULE
    //global variables 
    global test_pci_cff_prem
    global test_pci_cff
    global i_test_pci_cff

    //initialization
    if current_time_im==1
        test_pci_cff_prem=%f;
        test_pci_cff=%f;
        i_test_pci_cff=TimeHorizon+1;
    end

    //CTL profitability test
    //calculation of CTL production costs, based on coal prices
    //according to http://www.iea-etsap.org/web/E-TechDS/PDF/S02-CTL&GTL-GS-gct.pdf ETSAP Energy system analysis programme - Technology brief S02 May 2010 - Liquid fuels production from coal and gas, we know that the variable costs (excluding coal) of CTL are roughly equal to the costs of coal and the capital costs are roughly 10 times higher for a lifespan of around 30 years (in levelised annual capital cost, this gives a capital cost roughly equal to 0.8 times the cost of coal).
    cost_CTL_OM=zeros(reg,1);
    for k=1:reg,
        cost_CTL_OM(k)=cost_CTL_OMref*(sum(Cost_struc_oil_refin_ref(k,elec:sec).*(pArmCI(elec:sec,indice_Et,k)')))./(sum(Cost_struc_oil_refin_ref(k,elec:sec).*(pArmCIref(elec:sec,indice_Et,k)')));
    end;
    cost_CTL_capital=cost_CTL_capitalref*pK(:,et)./pKref(:,et);

    cost_CTL=zeros(reg,1);
    for k=1:reg,
        cost_CTL(k)=(pArmCI(coal,et,k)*(1/yield_CTL))+cost_CTL_OM(k)+cost_CTL_capital(k);
    end;
    price_CTL=cost_CTL.*(1+margin_CTL);
    if (~test_pci_cff)
        Q_CTL_anticip_prev=zeros(reg,1);
    else
        Q_CTL_anticip_prev=sg_get_var("Q_CTL_anticip",:,:,reg,%t,current_time_im);
    end;

    if (~test_pci_cff_prem) 
        for k=1:reg,
            if p(k,et)/price_CTL(k) > 1
                i_test_pci_cff=current_time_im;
                test_pci_cff_prem=%t;
            end;
        end;
    end

    //We can add a delay for ignitiate production (ctl_inert_lag) corresponding to the time to build one production unit
    if (test_pci_cff_prem)&(current_time_im>=i_test_pci_cff+ctl_inert_lag) 
        test_pci_cff=%t;
    end

    if (test_pci_cff)&(current_time_im>=i_test_pci_cff+ctl_inert_lag)

        share_CTL_anticip=max(0,share_CTL+(p(:,et)./price_CTL-1).*a_CTL);

        //inertia on share change
        for k=1:reg,
            if Q_CTL_anticip_prev(k)<>0 then
                if sum(Q(:,oil))<0.5*sum(Qref(:,oil)) then
                    //we prevent the degrowth of share of CTL when oil production is at depletion, we also prevent strong growth rates
                    share_CTL_anticip(k)=min(max(share_CTL(k),share_CTL_anticip(k)),inert_sh_CTL_i*share_CTL_anticip(k));
                end;
            end;
        end; 

        share_CTL_anticip=inert_CTL*share_CTL+(1-inert_CTL)*share_CTL_anticip;

        Q_CTL_anticip=min(0.999*(Q_Et_anticip-Q_biofuel_anticip),share_CTL_anticip.*Q_Et_anticip);


    end

    //selling price of CTL
    if sum(Q_CTL_anticip)>0 then
        price_CTL_w=sum(price_CTL.*Q_CTL_anticip)./sum(Q_CTL_anticip);
    else
        price_CTL_w=min(price_CTL);
    end;
    p_CTL_mtep=price_CTL_w;



    // the CTL yield (yield_CTL) de xxx% is given, we consider the margin rate given by etref, we then adjust the intermediate consumption of insutrial good CI to reach the objectiv price
    Cost_struc_CTL=zeros(reg,sec+2);
    for k=1:reg
        if Q_CTL_anticip(k)>0


            Cost_struc_CTL(k,indice_coal)=1/yield_CTL;
            Cost_struc_CTL(k,sec+2)=Cost_struc_oil_refin_ref(k,sec+2);
            //for i=1:nb_sectors_industry, // EDIT: we finally chose to use the chemical sector as a proxy for this calibration (not very important). Indexation is a bit "wordy" here, but it allows the code to be compatible with the two versions (1 or 8 industrial sectors). Note also that if we change the number of sectors in the multisector version, we will have to change the number below.
            Cost_struc_CTL(k,indice_industries(max(1,(length(indice_industries)-3))))=(price_CTL(k)*(1/(1+qtax(k,indice_Et))-Cost_struc_CTL(k,sec+2))-pArmCI(coal,et,k)*(1/yield_CTL))/pArmCI(indice_industries(max(1,(length(indice_industries)-3))),et,k);


        end
    end

    Q_CTL_anticip = max(Q_CTL_anticip,0);

endfunction
