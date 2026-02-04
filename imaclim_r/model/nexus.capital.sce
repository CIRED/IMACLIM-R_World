//#############################################################################################
//#############################################################################################
//### STEP 1: new Kapital
//#############################################################################################
//#############################################################################################

//////////////////////////////////////////////////////////////////////////////
Kprev=K;
K=K.*(1-delta)+DeltaK;

K(:,indice_oil)=K_expected(:,indice_oil);
K(:,indice_elec)=(sum(Cap_elec_MW_dep,'c')+sum(Inv_MW,'c'))./sum(Cap_elec_MWref,'c').*Kref(:,indice_elec);

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

Cap(:,indice_gaz)=max(Cap(:,indice_gaz),0.97*Cap_prev(:,indice_gaz));

//rustine: on rajoute de l'inertie quand on ne produit presque plus de petrole, de gaz ou de charbon
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

//rustine: on rajoute de l'inertie quand on ne produit presque plus
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

//rustine: on rajoute de l'inertie quand on ne produit presque plus
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

////////////////////////On calcule la variation de capacité de production du secteur électrique corespondante
//Cap(:,indice_elec)=(sum(Cap_elec_MW_dep,'c')+sum(Inv_MW,'c'))./sum(Cap_elec_MWref,'c').*Capref(:,indice_elec);

if or(Cap<0)
    disp(Cap);
    warning("There are negative capacities!!!!");
    Cap(Cap<0) = 0.001;
end
