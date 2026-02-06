// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Thomas Le Gallic, Ruben Bibas, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//#############################################################################################
//#############################################################################################
//### STEP 1: new Kapital
//#############################################################################################
//#############################################################################################

//////////////////////////////////////////////////////////////////////////////
Kprev=K;
K=K.*(1-delta_modified)+DeltaK;

K(:,indice_oil)=K_expected(:,indice_oil);

Capvintagecomposite(:,current_time_im+dureedeviecomposite)=DeltaK(:,indice_composite);
sumCaptempcomposite=zeros(1,reg);
for k=1:reg,
    for j=1:dureedeviecomposite
        sumCaptempcomposite(1,k)=Capvintagecomposite(k,current_time_im+j)+sumCaptempcomposite(1,k);
    end
end
K(:,indice_composite)=sumCaptempcomposite';


if ind_NLU_CI == 1
    Capvintageagriculture(:,current_time_im+dureedevieagriculture)=DeltaK(:,indice_agriculture) .* (p_agriFoodProcess.*Q_agriFoodProcess) ./ (p(:,agri).*Q(:,agri)); // Com_FL code something better with anticipations on both sectors
else
    Capvintageagriculture(:,current_time_im+dureedevieagriculture)=DeltaK(:,indice_agriculture);
end
sumCaptempagriculture=zeros(1,reg);
for k=1:reg,
    for j=1:dureedevieagriculture
        sumCaptempagriculture(1,k)=Capvintageagriculture(k,current_time_im+j)+sumCaptempagriculture(1,k);
    end
end
K(:,indice_agriculture)=sumCaptempagriculture';


Capvintageindustries(:,:,current_time_im+dureedevieindustrie)=DeltaK(:,indice_industries);
sumCaptempindustries=zeros(reg,nb_sectors_industry);
for k=1:reg,
    for j=1:dureedevieindustrie
        sumCaptempindustries(k,:)=Capvintageindustries(k,:,current_time_im+j)+sumCaptempindustries(k,:);
    end
end
K(:,indice_industries)=sumCaptempindustries;

//taux_croiss_elec=(K(:,indice_elec)-Kprev(:,indice_elec))./Kprev(:,indice_elec);
//taux_croiss_comp=(K(:,indice_composite)-Kprev(:,indice_composite))./Kprev(:,indice_composite);
//taux_croiss_agr=(K(:,indice_agriculture)-Kprev(:,indice_agriculture))./Kprev(:,indice_agriculture);
//taux_croiss_ind=(K(:,indice_industrie)-Kprev(:,indice_industrie))./Kprev(:,indice_industrie);





//#############################################################################################
//#############################################################################################
//### STEP 2: associated productions CAPacities
//#############################################################################################
//#############################################################################################

Cap=alphaK.*(K.^betaK);
// special case for the electricity sector, in which there is no decomissioning of existing but unused capacities
Cap(:,indice_elec) = (peak_W_anticip_tot_1 ./ peak_W_anticip_tot_ref) .* Capref(:,indice_elec);
// could be peak_W_anticip_tot_i_1 as well
// this is not considering the case of investment shortage in the electricity nexus,
// actual shortage is complicated to compute because there could be an excess of capacities even with a shortage of investement

Cap(:,indice_gas)=max(Cap(:,indice_gas),0.97*Cap_prev(:,indice_gas));

// Inertia is added when their is very low level of production for oil, gas and coal
if current_time_im==1
    start_inertia=zeros(reg,1);
end

for k=1:reg,
    if k<>ind_mde
        if ~start_inertia(k)
            if (Q(k,oil)<0.3*Qref(k,oil))&(Q(k,oil)<50)
                start_inertia(k)=1;
            end
        end
        if start_inertia(k)
            Cap(k,indice_oil)=4/5*Cap_prev(k,indice_oil)+1/5*Cap(k,indice_oil);
            Cap(k,indice_oil)=min(Cap(k,indice_oil),Cap_prev(k,indice_oil));
        end
    end
end

// Inertia is added when their is very low level of production for gas
if current_time_im==1
    start_inertia_gas=zeros(reg,1);
end

for k=1:reg,    
    if ~start_inertia_gas(k)
        if (Q(k,gaz)<0.5*Qref(k,gaz))&(Q(k,gaz)<30) then
            start_inertia_gas(k)=1;
        end
    end
    if start_inertia_gas(k)
        Cap(k,gaz)=4/5*Cap_prev(k,gaz)+1/5*Cap(k,gaz);
        Cap(k,gaz)=min(Cap(k,gaz),Cap_prev(k,gaz));
    end
end

// Inertia is added when their is very low level of production for coal
if current_time_im==1
    start_inertia_coal=zeros(reg,1);
end

for k=1:reg
    if ~start_inertia_coal(k)
        if (Q(k,coal)<Qref(k,coal))&(Q(k,coal)<50)
            start_inertia_coal(k)=1;
        end
    end
    if start_inertia_coal(k)
        Cap(k,coal)=4/5*Cap_prev(k,coal)+1/5*Cap(k,coal);
        Cap(k,coal)=min(Cap(k,coal),Cap_prev(k,coal));
    end
end

//////////////////////// Production capacity variation of the electricity sector is computed
//Cap(:,indice_elec)=(sum(Cap_elec_MW_dep,'c')+sum(Inv_MW,'c'))./sum(Cap_elec_MWref,'c').*Capref(:,indice_elec);

if or(Cap<0)
    disp(Cap);
    warning("There are negative production Capacities!");
    Cap(Cap<0) = 0.001;
end
