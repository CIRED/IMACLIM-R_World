// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//nexus residentiel, 7 uses:
// 1  Space heating
// 2  Space cooling
// 3  Fridges
// 4  Electric appliances
// 5  Lighting
// 6  Cooking
// 7  Water heating

////on divise la chine en plusieurs regions (selon climat et urbain/rural)


//////////////////////////
///// coefficient de Gini
////////////////////////

////Gini:on fait une hypothese sur l'evolution des inegalites de richesse (ici, diminution de 0.1% par an) Gini=(Res_alpha_exo-1)/(Res_alpha_exo+1)

Res_alpha_exo=[2.7	2.6973	2.6946027	2.691908097	2.689216189	2.686526973	2.683840446	2.681156606	2.678475449	2.675796974	2.673121177	2.670448055	2.667777607	2.66510983	2.66244472	2.659782275	2.657122493	2.65446537	2.651810905	2.649159094	2.646509935	2.643863425	2.641219562	2.638578342	2.635939764	2.633303824	2.63067052	2.62803985	2.62541181	2.622786398	2.620163612	2.617543448	2.614925905	2.612310979	2.609698668	2.607088969	2.60448188	2.601877398	2.599275521	2.596676245	2.594079569	2.591485489	2.588894004	2.58630511	2.583718805	2.581135086	2.578553951	2.575975397	2.573399422
2	1.998	1.996002	1.994005998	1.992011992	1.99001998	1.98802996	1.98604193	1.984055888	1.982071832	1.98008976	1.978109671	1.976131561	1.974155429	1.972181274	1.970209093	1.968238884	1.966270645	1.964304374	1.96234007	1.96037773	1.958417352	1.956458935	1.954502476	1.952547973	1.950595425	1.94864483	1.946696185	1.944749489	1.942804739	1.940861935	1.938921073	1.936982152	1.935045169	1.933110124	1.931177014	1.929245837	1.927316591	1.925389275	1.923463885	1.921540421	1.919618881	1.917699262	1.915781563	1.913865781	1.911951916	1.910039964	1.908129924	1.906221794
2	1.998	1.996002	1.994005998	1.992011992	1.99001998	1.98802996	1.98604193	1.984055888	1.982071832	1.98008976	1.978109671	1.976131561	1.974155429	1.972181274	1.970209093	1.968238884	1.966270645	1.964304374	1.96234007	1.96037773	1.958417352	1.956458935	1.954502476	1.952547973	1.950595425	1.94864483	1.946696185	1.944749489	1.942804739	1.940861935	1.938921073	1.936982152	1.935045169	1.933110124	1.931177014	1.929245837	1.927316591	1.925389275	1.923463885	1.921540421	1.919618881	1.917699262	1.915781563	1.913865781	1.911951916	1.910039964	1.908129924	1.906221794
1.7	1.6983	1.6966017	1.694905098	1.693210193	1.691516983	1.689825466	1.688135641	1.686447505	1.684761057	1.683076296	1.68139322	1.679711827	1.678032115	1.676354083	1.674677729	1.673003051	1.671330048	1.669658718	1.667989059	1.66632107	1.664654749	1.662990094	1.661327104	1.659665777	1.658006111	1.656348105	1.654691757	1.653037065	1.651384028	1.649732644	1.648082912	1.646434829	1.644788394	1.643143606	1.641500462	1.639858962	1.638219103	1.636580883	1.634944303	1.633309358	1.631676049	1.630044373	1.628414328	1.626785914	1.625159128	1.623533969	1.621910435	1.620288525
2	1.998	1.996002	1.994005998	1.992011992	1.99001998	1.98802996	1.98604193	1.984055888	1.982071832	1.98008976	1.978109671	1.976131561	1.974155429	1.972181274	1.970209093	1.968238884	1.966270645	1.964304374	1.96234007	1.96037773	1.958417352	1.956458935	1.954502476	1.952547973	1.950595425	1.94864483	1.946696185	1.944749489	1.942804739	1.940861935	1.938921073	1.936982152	1.935045169	1.933110124	1.931177014	1.929245837	1.927316591	1.925389275	1.923463885	1.921540421	1.919618881	1.917699262	1.915781563	1.913865781	1.911951916	1.910039964	1.908129924	1.906221794
2.6	2.5974	2.5948026	2.592207797	2.58961559	2.587025974	2.584438948	2.581854509	2.579272655	2.576693382	2.574116689	2.571542572	2.568971029	2.566402058	2.563835656	2.561271821	2.558710549	2.556151838	2.553595686	2.551042091	2.548491049	2.545942558	2.543396615	2.540853218	2.538312365	2.535774053	2.533238279	2.53070504	2.528174335	2.525646161	2.523120515	2.520597394	2.518076797	2.51555872	2.513043161	2.510530118	2.508019588	2.505511569	2.503006057	2.500503051	2.498002548	2.495504545	2.493009041	2.490516032	2.488025516	2.48553749	2.483051953	2.480568901	2.478088332
2	1.998	1.996002	1.994005998	1.992011992	1.99001998	1.98802996	1.98604193	1.984055888	1.982071832	1.98008976	1.978109671	1.976131561	1.974155429	1.972181274	1.970209093	1.968238884	1.966270645	1.964304374	1.96234007	1.96037773	1.958417352	1.956458935	1.954502476	1.952547973	1.950595425	1.94864483	1.946696185	1.944749489	1.942804739	1.940861935	1.938921073	1.936982152	1.935045169	1.933110124	1.931177014	1.929245837	1.927316591	1.925389275	1.923463885	1.921540421	1.919618881	1.917699262	1.915781563	1.913865781	1.911951916	1.910039964	1.908129924	1.906221794
3.9	3.8961	3.8922039	3.888311696	3.884423384	3.880538961	3.876658422	3.872781764	3.868908982	3.865040073	3.861175033	3.857313858	3.853456544	3.849603087	3.845753484	3.841907731	3.838065823	3.834227757	3.83039353	3.826563136	3.822736573	3.818913836	3.815094922	3.811279828	3.807468548	3.803661079	3.799857418	3.796057561	3.792261503	3.788469242	3.784680772	3.780896092	3.777115195	3.77333808	3.769564742	3.765795177	3.762029382	3.758267353	3.754509086	3.750754576	3.747003822	3.743256818	3.739513561	3.735774048	3.732038274	3.728306235	3.724577929	3.720853351	3.717132498
4	3.996	3.992004	3.988011996	3.984023984	3.98003996	3.97605992	3.97208386	3.968111776	3.964143665	3.960179521	3.956219341	3.952263122	3.948310859	3.944362548	3.940418185	3.936477767	3.932541289	3.928608748	3.924680139	3.920755459	3.916834704	3.912917869	3.909004951	3.905095946	3.90119085	3.89728966	3.89339237	3.889498978	3.885609479	3.881723869	3.877842145	3.873964303	3.870090339	3.866220248	3.862354028	3.858491674	3.854633182	3.850778549	3.846927771	3.843080843	3.839237762	3.835398524	3.831563126	3.827731563	3.823903831	3.820079927	3.816259847	3.812443588
2.7	2.6973	2.6946027	2.691908097	2.689216189	2.686526973	2.683840446	2.681156606	2.678475449	2.675796974	2.673121177	2.670448055	2.667777607	2.66510983	2.66244472	2.659782275	2.657122493	2.65446537	2.651810905	2.649159094	2.646509935	2.643863425	2.641219562	2.638578342	2.635939764	2.633303824	2.63067052	2.62803985	2.62541181	2.622786398	2.620163612	2.617543448	2.614925905	2.612310979	2.609698668	2.607088969	2.60448188	2.601877398	2.599275521	2.596676245	2.594079569	2.591485489	2.588894004	2.58630511	2.583718805	2.581135086	2.578553951	2.575975397	2.573399422
2.1	2.0979	2.0958021	2.093706298	2.091612592	2.089520979	2.087431458	2.085344027	2.083258683	2.081175424	2.079094248	2.077015154	2.074938139	2.072863201	2.070790338	2.068719547	2.066650828	2.064584177	2.062519593	2.060457073	2.058396616	2.05633822	2.054281881	2.052227599	2.050175372	2.048125196	2.046077071	2.044030994	2.041986963	2.039944976	2.037905031	2.035867126	2.033831259	2.031797428	2.02976563	2.027735865	2.025708129	2.023682421	2.021658738	2.01963708	2.017617443	2.015599825	2.013584225	2.011570641	2.00955907	2.007549511	2.005541962	2.00353642	2.001532883
3	2.997	2.994003	2.991008997	2.988017988	2.98502997	2.98204494	2.979062895	2.976083832	2.973107748	2.970134641	2.967164506	2.964197341	2.961233144	2.958271911	2.955313639	2.952358325	2.949405967	2.946456561	2.943510105	2.940566594	2.937626028	2.934688402	2.931753713	2.92882196	2.925893138	2.922967245	2.920044277	2.917124233	2.914207109	2.911292902	2.908381609	2.905473227	2.902567754	2.899665186	2.896765521	2.893868756	2.890974887	2.888083912	2.885195828	2.882310632	2.879428322	2.876548893	2.873672344	2.870798672	2.867927873	2.865059945	2.862194886	2.859332691
];

//actualisation du coeficent de Gini
Res_alpha=Res_alpha_exo(:,current_time_im);


//////////////////////
//////depreciation
/////////////////////

//taux de depreciation des equipements (par region, par energie et par usage)
Res_delta_coal=0.1*ones(reg,1,nb_usage_res);
Res_delta_gas=0.1*ones(reg,1,nb_usage_res);
Res_delta_oil=0.1*ones(reg,1,nb_usage_res);
Res_delta_elec=0.1*ones(reg,1,nb_usage_res);
//taux de depreciation plus fort pour "autres equipements electromenagers" et eclairage
for k=1:reg,
    Res_delta_coal(k,1,indice_electromenager)=0.2;
    Res_delta_gas(k,1,indice_electromenager)=0.2;
    Res_delta_oil(k,1,indice_electromenager)=0.2;
    Res_delta_elec(k,1,indice_electromenager)=0.2;
    Res_delta_coal(k,1,indice_eclairage)=0.33;
    Res_delta_gas(k,1,indice_eclairage)=0.33;
    Res_delta_oil(k,1,indice_eclairage)=0.33;
    Res_delta_elec(k,1,indice_eclairage)=0.33;
end	


///////////////////////////////
////// anticipation des prix
//////////////////////////////

//definition des variables de prix anticipe et precedent: pour l'instant, p_ant est le prix courant et p_stock est le prix de l'annee d'avant (on fonctionne en prix reels)
//(en fait ce serait mieux de faire p_ant vraiment anticipe et p_stock prix courant...
p_coal_ant=zeros(reg,1,nb_usage_res);
p_coal_prev=zeros(reg,1,nb_usage_res);

for j=1:nb_usage_res,
    p_coal_ant(:,:,j)=pArmDF(:,indice_coal)./price_index;
    p_coal_prev(:,:,j)=p_prev_resid(:,indice_coal);
end

p_gas_ant=zeros(reg,1,nb_usage_res);
p_gas_prev=zeros(reg,1,nb_usage_res);

for j=1:nb_usage_res,
    p_gas_ant(:,:,j)=pArmDF(:,indice_gas)./price_index;
    p_gas_prev(:,:,j)=p_prev_resid(:,indice_gas);
end

p_oil_ant=zeros(reg,1,nb_usage_res);
p_oil_prev=zeros(reg,1,nb_usage_res);

for j=1:nb_usage_res,
    p_oil_ant(:,:,j)=pArmDF(:,indice_Et)./price_index;
    p_oil_prev(:,:,j)=p_prev_resid(:,indice_Et);
end

p_elec_ant=zeros(reg,1,nb_usage_res);
p_elec_prev=zeros(reg,1,nb_usage_res);

for j=1:nb_usage_res,
    p_elec_ant(:,:,j)=pArmDF(:,indice_elec)./price_index;
    p_elec_prev(:,:,j)=p_prev_resid(:,indice_elec);
end


///////////////////////////////////////////////////
////evolution des rendements des equipements neufs
///////////////////////////////////////////////////

Res_rho_coal_exo_prev=Res_rho_coal_exo;
Res_rho_gas_exo_prev=Res_rho_gas_exo;
Res_rho_oil_exo_prev=Res_rho_oil_exo;
Res_rho_elec_exo_prev=Res_rho_elec_exo;

// //amelioration de 0.5% pour chacune des 4 energies commerciales
// res_progres_efficacite=1.005*ones(reg,4);

// //on considere borne normalement atteinte en 2050 et evolution lineaire
// for k=1:reg,
// 	for j=1:nb_usage_res,
// 	res_progres_efficacite(k,1,j)=1/50*(res_efficacite_max(k,j,1)-Res_rho_coalref(k,1,j));
// 	res_progres_efficacite(k,2,j)=1/50*(res_efficacite_max(k,j,2)-Res_rho_gasref(k,1,j));
// 	res_progres_efficacite(k,3,j)=1/50*(res_efficacite_max(k,j,3)-Res_rho_oilref(k,1,j));
// 	res_progres_efficacite(k,4,j)=1/50*(res_efficacite_max(k,j,4)-Res_rho_elecref(k,1,j));
// 	end
// end

res_progres_efficacite=0.005*ones(reg,4,nb_usage_res);


//acceleration de l'amelioration des technologies si les prix sont eleves
//si l'augmentation du prix est superieure a 4% (3% pour l'elec) pendant trois ans, on suppose que l'efficacite des technologies va deux fois plus vite
//a revoir...
for k=1:reg,
    if p_coal_ant(k,1,1)/p_coal_prev(k,1,1)>1.04 then res_prixhaut(k,1)=res_prixhaut(k,1)+1;
    else res_prixhaut(k,1)=0;
    end
    if p_gas_ant(k,1,1)/p_gas_prev(k,1,1)>1.04 then res_prixhaut(k,2)=res_prixhaut(k,2)+1;
    else res_prixhaut(k,2)=0;
    end
    if p_oil_ant(k,1,1)/p_oil_prev(k,1,1)>1.04 then res_prixhaut(k,3)=res_prixhaut(k,3)+1;
    else res_prixhaut(k,3)=0;
    end
    if p_elec_ant(k,1,1)/p_elec_prev(k,1,1)>1.03 then res_prixhaut(k,4)=res_prixhaut(k,4)+1;
    else res_prixhaut(k,4)=0;
    end
	
    if res_prixhaut(k,1)==3 then res_progres_efficacite(k,1,:)=2*res_progres_efficacite(k,1,:);
        res_prixhaut(k,1)=2;
    end	
    if res_prixhaut(k,2)==3 then res_progres_efficacite(k,2,:)=2*res_progres_efficacite(k,2,:);
        res_prixhaut(k,2)=2;
    end							
    if res_prixhaut(k,3)==3 then res_progres_efficacite(k,3,:)=2*res_progres_efficacite(k,3,:);
        res_prixhaut(k,3)=2;
    end							
    if res_prixhaut(k,4)==3 then res_progres_efficacite(k,4,:)=2*res_progres_efficacite(k,4,:);
        res_prixhaut(k,4)=2;
    end	
	
    for j=1:nb_usage_res,	
        Res_rho_coal_exo(k,1,j)=min(res_efficacite_max(k,j,1),Res_rho_coal_exo_prev(k,1,j)*(1+res_progres_efficacite(k,1,j)));
        Res_rho_gas_exo(k,1,j)=min(res_efficacite_max(k,j,2),Res_rho_gas_exo_prev(k,1,j)*(1+res_progres_efficacite(k,2,j)));
        Res_rho_oil_exo(k,1,j)=min(res_efficacite_max(k,j,3),Res_rho_oil_exo_prev(k,1,j)*(1+res_progres_efficacite(k,3,j)));
        Res_rho_elec_exo(k,1,j)=min(res_efficacite_max(k,j,4),Res_rho_elec_exo_prev(k,1,j)*(1+res_progres_efficacite(k,4,j)));		
    end										
end

//biomasse, pas d'amelioration de l'efficacite energetique de la biomasse
Res_rho_bio_exo=ones(reg,1,nb_usage_res);
Res_rho_bio_exo=Res_rho_bioref;

//actualisation des rendements anticipes=rendements exogenes
Res_rho_coal_ant=Res_rho_coal_exo(:,1,:);
Res_rho_gas_ant=Res_rho_gas_exo(:,1,:);
Res_rho_oil_ant=Res_rho_oil_exo(:,1,:);
Res_rho_elec_ant=Res_rho_elec_exo(:,1,:);
Res_rho_bio=Res_rho_bio_exo;

////////////////////////////////////////////////////////////////////////////
////evolution du SE unitaire pour les utilisateurs d'energies commerciales 
////////////////////////////////////////////////////////////////////////////

//Service energetique unitaire dimension reg*1*(nombres d'usages)  (energie utile)
Res_SE_unit_com_exo=Res_SE_unit_comref;

////hypotheses sur les USA, elasticite s'annule quand service unitaire multiplie par une certaine valeur (dependant des usages) (hypotheses) 
Res_elast=ones(1,1,nb_usage_res);

//les elasticites initiales et asymptotes sont definies dans le fichier de calibration (res_calib)
for j=1:nb_usage_res,
    Res_elast(1,1,j)=min(Res_elast_USA_ini(j),max(0,Res_elast_USA_ini(j)/(Res_indice_max_USA(j)-1)*(Res_indice_max_USA(j)-Res_SE_unit_com(1,1,j)/Res_SE_unit_comref(1,1,j))));
end

//Calcul du service energetique unitaire pour les USA
Res_SE_unit_com_exo(1,:,:)=Res_SE_unit_com(1,:,:).*(((Rdisp(1))/Ltot_prev(1))/Rdisp_real_prev(1)*Ltot_prev_stock(1)*ones(1,1,nb_usage_res)).^Res_elast;

// //on dit que l'evolution du SE des pays est gouvernee par une elasticite-richesse pour prendre en compte l'effet confort
// //la valeur de l'elasticite est liee a l'ecart entre le service unitaire de la region et celui des USA
Res_elast_tot=ones(reg,1,nb_usage_res);
Res_elast_tot(1,1,:)=Res_elast;

for k=2:reg,

    for j=1:nb_usage_res,
        //Calcul des elasticite revenu en fonction de la distance a l'asymptote, ici l'asymptote est mouvante et vaut 
        //le service energetique unitaire des USA 
        if Res_SE_unit_com(k,1,j)/Res_SE_unit_com(1,1,j)>0.8 then Res_elast_tot(k,1,j)=Res_elast_tot_ini(j)*max(0,1-Res_SE_unit_com(k,1,j)/Res_SE_unit_com(1,1,j));
        elseif Res_SE_unit_com(k,1,j)/Res_SE_unit_com(1,1,j)<0.3 then Res_elast_tot(k,1,j)=Res_elast_tot_ini(j)*1.2;
        elseif Res_SE_unit_com(k,1,j)/Res_SE_unit_com(1,1,j)<0.5 then Res_elast_tot(k,1,j)=Res_elast_tot_ini(j)*0.5;
        elseif Res_SE_unit_com(k,1,j)/Res_SE_unit_com(1,1,j)<0.8 then Res_elast_tot(k,1,j)=Res_elast_tot_ini(j)*0.3;
        end	
        //Calcul du service energetique unitaire pour les regions autres que les USA en le faisant evoluer de facon elastique au revenu disponible reel per capita
        Res_SE_unit_com_exo(k,1,j)=Res_SE_unit_com(k,1,j)*((Rdisp(k)/price_index(k))/Ltot_prev(k)/Rdisp_real_prev(k)*Ltot_prev_stock(k))^Res_elast_tot(k,1,j);
    end
end

//evolution des services energetiques unitaires en fonction des prix des energies, evolution distinguee selon l energie utilisee

//decomposition des services energetiques unitaires par energie utilisee
Res_SE_unit_com_exo_Coal=Res_SE_unit_com_exo.*Res_sh_coal;
Res_SE_unit_com_exo_Gas=Res_SE_unit_com_exo.*Res_sh_gas;
Res_SE_unit_com_exo_Oil=Res_SE_unit_com_exo.*Res_sh_oil;
Res_SE_unit_com_exo_Elec=Res_SE_unit_com_exo.*Res_sh_elec;

//Evolution de facon elastique aux prix de chaque energie, ou plus exactement au prix du service energetique (prix/rho)
//Pour l'instant l'elasticite varie uniquement selon les usages (ni selon les regions, ni selon le niveau absolu de service energetique unitaire)
//l'elasticite est definie dans le fichier de calibration du residentiel (res_calib)
for k=1:reg,
    for j=1:nb_usage_res,
        //On fait l'hypothese que les menages reagissent au prix reel (rapporte au pouvoir d'achat)
        Res_SE_unit_com_exo_Coal(k,1,j)=Res_SE_unit_com_exo_Coal(k,1,j)*(pArmDF(k,indice_coal)/price_index(k)/Res_rho_coal(k,1,j)/(p_prev_resid(k,indice_coal)/Res_rho_coal_prev(k,1,j)))^Res_elast_prix(j);
        Res_SE_unit_com_exo_Gas(k,1,j)=Res_SE_unit_com_exo_Gas(k,1,j)*(pArmDF(k,indice_gas)/price_index(k)/Res_rho_gas(k,1,j)/(p_prev_resid(k,indice_gas)/Res_rho_gas_prev(k,1,j)))^Res_elast_prix(j);
        Res_SE_unit_com_exo_Oil(k,1,j)=Res_SE_unit_com_exo_Oil(k,1,j)*(pArmDF(k,indice_Et)/price_index(k)/Res_rho_oil(k,1,j)/(p_prev_resid(k,indice_Et)/Res_rho_oil_prev(k,1,j)))^Res_elast_prix(j);
        Res_SE_unit_com_exo_Elec(k,1,j)=Res_SE_unit_com_exo_Elec(k,1,j)*(pArmDF(k,indice_elec)/price_index(k)/Res_rho_elec(k,1,j)/(p_prev_resid(k,indice_elec)/Res_rho_elec_prev(k,1,j)))^Res_elast_prix(j);
    end
end

//recomposition des services energetiques unitaires
Res_SE_unit_com_exo=Res_SE_unit_com_exo_Coal+Res_SE_unit_com_exo_Gas+Res_SE_unit_com_exo_Oil+Res_SE_unit_com_exo_Elec;

//asymptotes basses des services energetiques unitaires
for k=1:reg,
    for j=1:nb_usage_res,
        if Res_SE_unit_com_exo(k,1,j)<Res_se_unit_min(j)*Res_SE_unit_comref(k,1,j) then Res_SE_unit_com_exo(k,1,j)=Res_se_unit_min(j)*Res_SE_unit_comref(k,1,j);
        end
    end
end
	
//Actualisation du service energetique unitaire (energie utile)
Res_SE_unit_com_prev=Res_SE_unit_com;
Res_SE_unit_com=Res_SE_unit_com_exo;

////////////////////////////////////////
////////part de la biomasse
///////////////////////////////////

///////volume d'energie traditionnelle: on suppose que c'est relie a la proportion de la population ayant plus de 2$ par jour

//Calcul de la proportion de la population ayant moins de 2$ par jour. Formule tiree d'une hypothese de distribution des 
//revenus selon une courbe de Lorenz de parametre Res_alpha
Res_F2dollars=min(0.98,(2*365.*ones(reg,1)./Res_alpha./((Rdisp)./Ltot_prev.*1000000)).^(ones(reg,1)./(Res_alpha-ones(reg,1))));

//Calcul de la proportion de la population ayant recours a la biomasse
Res_part_bio_prev=Res_part_bio;
Res_part_bio=zeros(reg,1,nb_usage_res);

//seuls les usages suivants sont concernes: chauffage(1), cuisine(6) et chauffage de l'eau(7)
//seules les regions suivantes sont concernees: Chine(6), Inde(7), Bresil (8), Afrique(10), Rest of SE Asie(11), Rest of Latin America(12) 
for k=6:8,
    Res_part_bio(k,1,indice_chauffage)=Res_gamma_bioref(k).*(max(0,(Res_F2dollars(k)-Res_a_bioref(k,indice_chauffage)))).^Res_beta_bioref(k);
    Res_part_bio(k,1,indice_cuisine)=Res_gamma_bioref(k).*(max(0,(Res_F2dollars(k)-Res_a_bioref(k,indice_cuisine)))).^Res_beta_bioref(k);
    Res_part_bio(k,1,indice_chauffEau)=Res_gamma_bioref(k).*(max(0,(Res_F2dollars(k)-Res_a_bioref(k,indice_chauffEau)))).^Res_beta_bioref(k);
end
for k=10:reg,
    Res_part_bio(k,1,indice_chauffage)=Res_gamma_bioref(k).*(max(0,(Res_F2dollars(k)-Res_a_bioref(k,indice_chauffage)))).^Res_beta_bioref(k);
    Res_part_bio(k,1,indice_cuisine)=Res_gamma_bioref(k).*(max(0,(Res_F2dollars(k)-Res_a_bioref(k,indice_cuisine)))).^Res_beta_bioref(k);
    Res_part_bio(k,1,indice_chauffEau)=Res_gamma_bioref(k).*(max(0,(Res_F2dollars(k)-Res_a_bioref(k,indice_chauffEau)))).^Res_beta_bioref(k);   
end

///////////////////////////////////////////
/////// taux d'acces et taux d'equipement
///////////////////////////////////////////

//// evolution du taux d'acces (correspond a l'electrification): ne concerne que les usages specifiques a l'electricite (2:4) et les regions 6 a 12,
////dans les autres cas l'acces est de 1 des le debut

//taux d'acces au service energetique
Res_mu_prev=Res_mu;
for k=6:reg,
    //seulement usages electricite specifique (le taux d'electrification ne peut pas diminuer) elasticite du taux d'eletrification au revenu de 0.4
    for j=indice_clim:indice_electromenager,
        Res_mu(k,1,j)=min(1,Res_mu_prev(k,1,j)*(max(1,(GDP(k)/(Ltot_prev(k)*price_index(k)))/(realGDP_prev_stock(k)/Ltot_prev_stock(k))))^0.4);
    end
end

//taux d'equipement:description du rattrapage de lambda (equipement effectif) sur mu (acces)
//seuls les usages specifiques a l'electricite sont concernes, pour les autres le taux d'equipement est constant et egal a 1
//evolution de l'elasticite en fonction de la distance a l'asymptote qui est ici l'acces (Res_mu)
for k=1:reg,
    for j=indice_clim:indice_electromenager,
        if Res_lambda(k,1,j)/Res_mu(k,1,j)>0.7 then elast_lambda=0.5;
        elseif Res_lambda(k,1,j)/Res_mu(k,1,j)<0.3 then elast_lambda=1.3;
        elseif Res_lambda(k,1,j)/Res_mu(k,1,j)<0.5 then elast_lambda=1;
        elseif Res_lambda(k,1,j)/Res_mu(k,1,j)<0.7 then elast_lambda=0.7;
        end
        //pour les frigos et, dans une moindre mesure les autres appareils electromenagers, le rattrapage est plus rapide
        if j==indice_frigo then elast_lambda=elast_lambda*1.5;
        elseif j==indice_electromenager then elast_lambda=elast_lambda*1.3;
        end
        //actualisation du taux d'equipement comme une elasticite revenu
        Res_lambda(k,1,j)=min(Res_mu(k,1,j),Res_lambda_prev(k,1,j)*(max(1,(Rdisp(k)/(Ltot_prev(k)*price_index(k)))/(Rdisp_real_prev(k)/Ltot_prev_stock(k))))^elast_lambda);
    end
end	
////////////////////////////
////variable de volume
/////////////////////////////

Res_M_prev=Res_M;
Res_M=zeros(reg,1,nb_usage_res);
//m2
Res_M(:,:,indice_chauffage)=m2batiment;
Res_M(:,:,indice_clim)=m2batiment;
//habitants
Res_M(:,:,indice_frigo)=Ltot;
Res_M(:,:,indice_electromenager)=Ltot;
Res_M(:,:,indice_eclairage)=Ltot;
Res_M(:,:,indice_cuisine)=Ltot;
Res_M(:,:,indice_chauffEau)=Ltot;

//corrections climat pour chauffage et climatisation
//Res_climat est defini dans le fichier de calibration res_calib

//////////////////////////////////////
//efficacité énergétique de l'habitat 
///////////////////////////////////////
//facteur d'isolation pour le chauffage et la climatisation, compris entre 0 et 1 (plus on est proche de 0, meilleure est l'isolation)
//fateur egal a 1 pour les autres usages
//le facteur d'isolation, lie a la construction et a la renovation, est calcule dans le nexus stock de logement
res_effHabitat(:,:,indice_chauffage)=res_isolation;
res_effHabitat(:,:,indice_clim)=res_isolation;
//ce facteur fait diminuer le service energetique unitaire potentiel
Res_SE_unit_com_pot=res_effHabitat.*Res_SE_unit_com;
//si le chauffage est individuel le service energetique unitaire reel est egal au service potentiel
//dans le cas du chauffage collectif, l'isolation n'a pas d'effet car il n'y a pas de regulation individuelle


////////////////////////////////////////////////////////////
///// service energetique total et demande d'energie finale
////////////////////////////////////////////////////////////

//biomasse
//service energetique fourni par la biomasse traditionnelle (energie utile)
//on fait l'hypothèse que le service energetique unitaire assure par la biomasse n'evolue pas
//si le chauffage est individuel le service energetique unitaire reel est egal au service potentiel
//dans le cas du chauffage collectif, l'isolation n'a pas d'effet car il n'y a pas de regulation individuelle
Res_SE_bio=Res_part_bio.*Res_M.*Res_lambda.*Res_climat.*((1-SE_collectif).*res_effHabitat.*Res_SE_unit_bio+SE_collectif.*Res_SE_unit_bio);
//demande finale de biomasse (energie finale) (par usage)
Res_DEF_bio=Res_SE_bio./Res_rho_bio;
//demande finale de biomasse (energie finale) (somme sur les usages)
Res_DEF_bio_tot=Res_DEF_bio(:,:,indice_chauffage)+Res_DEF_bio(:,:,indice_clim)+Res_DEF_bio(:,:,indice_frigo)+Res_DEF_bio(:,:,indice_electromenager)+Res_DEF_bio(:,:,indice_eclairage)+Res_DEF_bio(:,:,indice_cuisine)+Res_DEF_bio(:,:,indice_chauffEau);

//service energetique commercial (hors biomasse traditionnelle)
//si le chauffage est individuel le service energetique unitaire reel est egal au service potentiel
//dans le cas du chauffage collectif, l'isolation n'a pas d'effet car il n'y a pas de regulation individuelle
Res_SE_com=(1-Res_part_bio).*Res_M.*Res_lambda.*Res_climat.*((1-SE_collectif).*Res_SE_unit_com_pot+SE_collectif.*Res_SE_unit_com);

//services energetiques totaux (en energie utile)
Res_SE_tot=Res_SE_com+Res_SE_bio;

///////evolution des parts des energies commerciales par usage

//calcul des parts des energies dans la nouvelle generation d'equipements : logit sur les prix du service energetique (en energie utile)
//relie aux parts des energies dans le parc total, pour prendre en compte un effet d'habitude et d'inertie
Res_sum=Res_sh_coal.*((p_coal_ant./Res_rho_coal_ant)./(p_coal_prev./Res_rho_coal)).^(-Res_nu)+Res_sh_gas.*((p_gas_ant./Res_rho_gas_ant)./(p_gas_prev./Res_rho_gas)).^(-Res_nu)+Res_sh_oil.*((p_oil_ant./Res_rho_oil_ant)./(p_oil_prev./Res_rho_oil)).^(-Res_nu)+Res_sh_elec.*(max(ones(reg,1,nb_usage_res),(p_elec_ant./Res_rho_elec_ant)./(p_elec_prev./Res_rho_elec))).^(-Res_nu);

Res_part_coal=(Res_sh_coal.*((p_coal_ant./Res_rho_coal_ant)./(p_coal_prev./Res_rho_coal)).^(-Res_nu))./(Res_sum);
Res_part_gas=(Res_sh_gas.*((p_gas_ant./Res_rho_gas_ant)./(p_gas_prev./Res_rho_gas)).^(-Res_nu))./(Res_sum);
Res_part_oil=(Res_sh_oil.*((p_oil_ant./Res_rho_oil_ant)./(p_oil_prev./Res_rho_oil)).^(-Res_nu))./(Res_sum);
Res_part_elec=(Res_sh_elec.*(max(ones(reg,1,nb_usage_res),(p_elec_ant./Res_rho_elec_ant)./(p_elec_prev./Res_rho_elec))).^(-Res_nu))./(Res_sum);


//le choix pour le chauffage de l'eau et la cuisine est lie a celui pour le chauffage
Res_part_coal(:,:,indice_cuisine)=Res_part_coal(:,:,indice_chauffage);
Res_part_gas(:,:,indice_cuisine)=Res_part_gas(:,:,indice_chauffage);
Res_part_oil(:,:,indice_cuisine)=Res_part_oil(:,:,indice_chauffage);
Res_part_elec(:,:,indice_cuisine)=Res_part_elec(:,:,indice_chauffage);
Res_part_coal(:,:,indice_chauffEau)=Res_part_coal(:,:,indice_chauffage);
Res_part_gas(:,:,indice_chauffEau)=Res_part_gas(:,:,indice_chauffage);
Res_part_oil(:,:,indice_chauffEau)=Res_part_oil(:,:,indice_chauffage);
Res_part_elec(:,:,indice_chauffEau)=Res_part_elec(:,:,indice_chauffage);

//actualisation des parts des energies dans les nouveaux investissements
Res_part_coal_prev=Res_part_coal;
Res_part_gas_prev=Res_part_gas;
Res_part_oil_prev=Res_part_oil;
Res_part_elec_prev=Res_part_elec;

////evolution du nombre de personnes qui utilisent la techno j pour l'usage i
Res_N_coal_prev=Res_N_coal;
Res_N_gas_prev=Res_N_gas;
Res_N_oil_prev=Res_N_oil;
Res_N_elec_prev=Res_N_elec;

//nombre de "gens" qui doivent se reequiper (on compense la depreciation) (calcule a partir des anciennes valeurs de Res_N_coal...)
Res_N_new=Res_delta_coal.*Res_N_coal+Res_delta_gas.*Res_N_gas+Res_delta_oil.*Res_N_oil+Res_delta_elec.*Res_N_elec;

//nombre de "gens" qui doivent choisir une nouvelle techno (depreciation + nouveaux equipes)
Res_N_new_tot=Res_N_new+(Res_lambda.*Res_M.*(1-Res_part_bio)-Res_lambda_prev.*Res_M_prev.*(1-Res_part_bio_prev));

//pour le chauffage et le chauffage de l'eau, la technologie est liee a l'habitat, le choix ne se fait qu'a la construction (ou a la renovation) du logement
Res_N_new_tot(:,:,indice_chauffage)=(res_construction+res_renovation).*(1-Res_part_bio(:,:,indice_chauffage));
Res_N_new_tot(:,:,indice_chauffEau)=Res_M(:,:,indice_chauffEau)./Res_M(:,:,indice_chauffage).*(res_construction+res_renovation).*(1-Res_part_bio(:,:,indice_chauffage));

//nouvelles valeurs du nombre de personnes utilisant chaque energie (par usage)
Res_N_coal=(1-Res_delta_coal).*Res_N_coal_prev+Res_part_coal.*(Res_N_new_tot);
Res_N_gas=(1-Res_delta_gas).*Res_N_gas_prev+Res_part_gas.*(Res_N_new_tot);
Res_N_oil=(1-Res_delta_oil).*Res_N_oil_prev+Res_part_oil.*(Res_N_new_tot);
Res_N_elec=(1-Res_delta_elec).*Res_N_elec_prev+Res_part_elec.*(Res_N_new_tot);

//correction pour le chauffage
Res_N_coal(:,:,indice_chauffage)=Res_sh_coal(:,:,indice_chauffage).*(Res_M(:,:,indice_chauffage).*(1-Res_part_bio(:,:,indice_chauffage))-Res_N_new_tot(:,:,indice_chauffage))+Res_part_coal(:,:,indice_chauffage).*(Res_N_new_tot(:,:,indice_chauffage));
Res_N_gas(:,:,indice_chauffage)=Res_sh_gas(:,:,indice_chauffage).*(Res_M(:,:,indice_chauffage).*(1-Res_part_bio(:,:,indice_chauffage))-Res_N_new_tot(:,:,indice_chauffage))+Res_part_gas(:,:,indice_chauffage).*(Res_N_new_tot(:,:,indice_chauffage));
Res_N_oil(:,:,indice_chauffage)=Res_sh_oil(:,:,indice_chauffage).*(Res_M(:,:,indice_chauffage).*(1-Res_part_bio(:,:,indice_chauffage))-Res_N_new_tot(:,:,indice_chauffage))+Res_part_oil(:,:,indice_chauffage).*(Res_N_new_tot(:,:,indice_chauffage));
Res_N_elec(:,:,indice_chauffage)=Res_sh_elec(:,:,indice_chauffage).*(Res_M(:,:,indice_chauffage).*(1-Res_part_bio(:,:,indice_chauffage))-Res_N_new_tot(:,:,indice_chauffage))+Res_part_elec(:,:,indice_chauffage).*(Res_N_new_tot(:,:,indice_chauffage));

//correction pour le chauffage de l'eau
Res_N_coal(:,:,indice_chauffEau)=Res_sh_coal(:,:,indice_chauffEau).*(Res_M(:,:,indice_chauffEau).*(1-Res_part_bio(:,:,indice_chauffEau))-Res_N_new_tot(:,:,indice_chauffEau))+Res_part_coal(:,:,indice_chauffEau).*(Res_N_new_tot(:,:,indice_chauffEau));
Res_N_gas(:,:,indice_chauffEau)=Res_sh_gas(:,:,indice_chauffEau).*(Res_M(:,:,indice_chauffEau).*(1-Res_part_bio(:,:,indice_chauffEau))-Res_N_new_tot(:,:,indice_chauffEau))+Res_part_gas(:,:,indice_chauffEau).*(Res_N_new_tot(:,:,indice_chauffEau));
Res_N_oil(:,:,indice_chauffEau)=Res_sh_oil(:,:,indice_chauffEau).*(Res_M(:,:,indice_chauffEau).*(1-Res_part_bio(:,:,indice_chauffEau))-Res_N_new_tot(:,:,indice_chauffEau))+Res_part_oil(:,:,indice_chauffEau).*(Res_N_new_tot(:,:,indice_chauffEau));
Res_N_elec(:,:,indice_chauffEau)=Res_sh_elec(:,:,indice_chauffEau).*(Res_M(:,:,indice_chauffEau).*(1-Res_part_bio(:,:,indice_chauffEau))-Res_N_new_tot(:,:,indice_chauffEau))+Res_part_elec(:,:,indice_chauffEau).*(Res_N_new_tot(:,:,indice_chauffEau));

//cas particulier de l'eclairage : tous les nouveaux electrifies utilisent l'elec pour l'eclairage, on n'a d'utilisation du kerosene pour 
//l'eclairage si on est relie au reseau electrique. (Le taux d'acces a l'electricite Res_mu n'est defini que pour les usages a electricite specifique
//c'est la raison pour laquelle on utilise un indice autre que indice_eclairage par Res_mu
Res_N_elec(:,:,indice_eclairage)=Ltot.*Res_mu(:,:,indice_clim);
Res_N_oil(:,:,indice_eclairage)=Ltot.*(1-Res_mu(:,:,indice_clim));

////Calcul des efficacites pour le parc total

//il ne faut pas que Res_N s'annule pour le calcul des efficacites
for k=1:reg
    for j=1:nb_usage_res
        if Res_N_coal(k,1,j)==0 then Res_N_coal(k,1,j)=0.0000001;end
        if Res_N_gas(k,1,j)==0 then Res_N_gas(k,1,j)=0.0000001;end
        if Res_N_oil(k,1,j)==0 then Res_N_oil(k,1,j)=0.0000001;end
        if Res_N_elec(k,1,j)==0 then Res_N_elec(k,1,j)=0.0000001;end
    end
end

//equations d'evolution de l'efficacite moyenne du parc d'equipement
Res_rho_coal_prev=Res_rho_coal;
Res_rho_gas_prev=Res_rho_gas;
Res_rho_oil_prev=Res_rho_oil;
Res_rho_elec_prev=Res_rho_elec;
//Nouvelle efficacite moyenne du parc
Res_rho_coal=(Res_rho_coal_prev.*Res_N_coal_prev.*(1-Res_delta_coal)+Res_rho_coal_ant.*(Res_N_coal-Res_N_coal_prev.*(1-Res_delta_coal)))./Res_N_coal;
Res_rho_gas=(Res_rho_gas_prev.*Res_N_gas_prev.*(1-Res_delta_gas)+Res_rho_gas_ant.*(Res_N_gas-Res_N_gas_prev.*(1-Res_delta_gas)))./Res_N_gas;
Res_rho_oil=(Res_rho_oil_prev.*Res_N_oil_prev.*(1-Res_delta_oil)+Res_rho_oil_ant.*(Res_N_oil-Res_N_oil_prev.*(1-Res_delta_oil)))./Res_N_oil;
//On redefinit l'efficacite du kerosene pour l'eclairage
Res_rho_oil(:,:,indice_eclairage)=Res_rho_oil_exo(:,1,indice_eclairage);
Res_rho_elec=(Res_rho_elec_prev.*Res_N_elec_prev.*(1-Res_delta_elec)+Res_rho_elec_ant.*(Res_N_elec-Res_N_elec_prev.*(1-Res_delta_elec)))./Res_N_elec;

//remise a 0 des valeurs de Res_N (pour celles qui etaient nulles avant la manipulation ci-dessus)
for k=1:reg
    for j=1:nb_usage_res
        if Res_N_coal(k,1,j)==0.0000001 then Res_N_coal(k,1,j)=0;end
        if Res_N_gas(k,1,j)==0.0000001 then Res_N_gas(k,1,j)=0;end
        if Res_N_oil(k,1,j)==0.0000001 then Res_N_oil(k,1,j)=0;end
        if Res_N_elec(k,1,j)==0.0000001 then Res_N_elec(k,1,j)=0;end
    end
end

////evolution des parts des energies dans le parc d'equipement total
Res_N_tot=Res_N_coal+Res_N_gas+Res_N_oil+Res_N_elec;
Res_sh_coal=Res_N_coal./(Res_N_tot);
Res_sh_gas=Res_N_gas./(Res_N_tot);
Res_sh_oil=Res_N_oil./(Res_N_tot);
Res_sh_elec=Res_N_elec./(Res_N_tot);



/////////////calcul de la demande d'energie finale
////par usage
Res_DEF_coal=Res_SE_com.*Res_sh_coal./Res_rho_coal;
Res_DEF_gas=Res_SE_com.*Res_sh_gas./Res_rho_gas;
//les personne s'eclairant au kerosene ont un service energetique unitaire (energie utile) tres faible,
// sans quoi la consommation de kerosene exploserait (du fait de la tres faible efficacite)
Res_SE_com_prev(:,:,indice_eclairage)=Res_SE_com(:,:,indice_eclairage);
Res_SE_com(:,:,indice_eclairage)=(Res_rho_oil(:,:,indice_eclairage)./Res_rho_elec(:,:,indice_eclairage)).*Res_SE_com(:,:,indice_eclairage);
Res_DEF_oil=Res_SE_com.*Res_sh_oil./Res_rho_oil;
Res_SE_com(:,:,indice_eclairage)=Res_SE_com_prev(:,:,indice_eclairage);
Res_DEF_elec=Res_SE_com.*Res_sh_elec./Res_rho_elec;

////par source d'energie (somme sur les usages)
Res_DEF_coal_tot=Res_DEF_coal(:,:,indice_chauffage)+Res_DEF_coal(:,:,indice_clim)+Res_DEF_coal(:,:,indice_frigo)+Res_DEF_coal(:,:,indice_electromenager)+Res_DEF_coal(:,:,indice_eclairage)+Res_DEF_coal(:,:,indice_cuisine)+Res_DEF_coal(:,:,indice_chauffEau);
Res_DEF_gas_tot=Res_DEF_gas(:,:,indice_chauffage)+Res_DEF_gas(:,:,indice_clim)+Res_DEF_gas(:,:,indice_frigo)+Res_DEF_gas(:,:,indice_electromenager)+Res_DEF_gas(:,:,indice_eclairage)+Res_DEF_gas(:,:,indice_cuisine)+Res_DEF_gas(:,:,indice_chauffEau);
Res_DEF_oil_tot=Res_DEF_oil(:,:,indice_chauffage)+Res_DEF_oil(:,:,indice_clim)+Res_DEF_oil(:,:,indice_frigo)+Res_DEF_oil(:,:,indice_electromenager)+Res_DEF_oil(:,:,indice_eclairage)+Res_DEF_oil(:,:,indice_cuisine)+Res_DEF_oil(:,:,indice_chauffEau);
Res_DEF_elec_tot=Res_DEF_elec(:,:,indice_chauffage)+Res_DEF_elec(:,:,indice_clim)+Res_DEF_elec(:,:,indice_frigo)+Res_DEF_elec(:,:,indice_electromenager)+Res_DEF_elec(:,:,indice_eclairage)+Res_DEF_elec(:,:,indice_cuisine)+Res_DEF_elec(:,:,indice_chauffEau);
Res_DEF_tot=Res_DEF_coal_tot+Res_DEF_gas_tot+Res_DEF_oil_tot+Res_DEF_elec_tot;

////part du bio dans la demande d'energie finale
Res_part2_bio=Res_DEF_bio_tot./(Res_DEF_bio_tot+Res_DEF_coal_tot+Res_DEF_gas_tot+Res_DEF_oil_tot+Res_DEF_elec_tot);

///lambda_prev
Res_lambda_prev=Res_lambda;

////////////////////////////////
////nouvelles valeurs de alpha
////////////////////////////////////

alphaCoalm2=Res_DEF_coal_tot./stockbatiment;
alphaGazm2=Res_DEF_gas_tot./stockbatiment;
alphaEtm2=Res_DEF_oil_tot./stockbatiment;
alphaelecm2=Res_DEF_elec_tot./stockbatiment;

/////////////////////////////////
///// sorties
////////////////////////////////
res_save(:,current_time_im+1)=[alphaCoalm2;
alphaGazm2;
alphaEtm2;
alphaelecm2;
Res_DEF_coal_tot;
Res_DEF_gas_tot;
Res_DEF_oil_tot;
Res_DEF_elec_tot;
Res_DEF_tot;
Res_DEF_bio_tot;
Res_SE_unit_com(:,1,indice_chauffage);
Res_SE_unit_com(:,1,indice_clim);
Res_SE_unit_com(:,1,indice_frigo);
Res_SE_unit_com(:,1,indice_electromenager);
Res_SE_unit_com(:,1,indice_eclairage);
Res_SE_unit_com(:,1,indice_cuisine);
Res_SE_unit_com(:,1,indice_chauffEau);
Res_rho_coal(:,:,indice_chauffage);
Res_rho_coal(:,:,indice_cuisine);
Res_rho_coal(:,:,indice_chauffEau);
Res_rho_gas(:,:,indice_chauffage);
Res_rho_gas(:,:,indice_cuisine);
Res_rho_gas(:,:,indice_chauffEau);
Res_rho_oil(:,:,indice_chauffage);
Res_rho_oil(:,:,indice_eclairage);
Res_rho_oil(:,:,indice_cuisine);
Res_rho_oil(:,:,indice_chauffEau);
Res_rho_elec(:,:,indice_chauffage);
Res_rho_elec(:,:,indice_clim);
Res_rho_elec(:,:,indice_frigo);
Res_rho_elec(:,:,indice_electromenager);
Res_rho_elec(:,:,indice_eclairage);
Res_rho_elec(:,:,indice_cuisine);
Res_rho_elec(:,:,indice_chauffEau);
Res_N_coal(:,:,indice_chauffage);
Res_N_coal(:,:,indice_cuisine);
Res_N_coal(:,:,indice_chauffEau);
Res_N_gas(:,:,indice_chauffage);
Res_N_gas(:,:,indice_cuisine);
Res_N_gas(:,:,indice_chauffEau);
Res_N_oil(:,:,indice_chauffage);
Res_N_oil(:,:,indice_eclairage);
Res_N_oil(:,:,indice_cuisine);
Res_N_oil(:,:,indice_chauffEau);
Res_N_elec(:,:,indice_chauffage);
Res_N_elec(:,:,indice_clim);
Res_N_elec(:,:,indice_frigo);
Res_N_elec(:,:,indice_electromenager);
Res_N_elec(:,:,indice_eclairage);
Res_N_elec(:,:,indice_cuisine);
Res_N_elec(:,:,indice_chauffEau);
Res_part_bio(:,:,indice_chauffage);
Res_M(:,:,indice_chauffage);
Res_part_bio(:,:,indice_cuisine);
Res_M(:,:,indice_cuisine);
Res_part_bio(:,:,indice_chauffEau);
Res_M(:,:,indice_chauffEau);
];

mkcsv( 'res_save,');


res_save2(:,current_time_im+1)=[Res_N_new_tot(:,:,indice_chauffage);
Res_M(:,:,indice_chauffage);
Res_N_new_tot(:,:,indice_clim);
Res_M(:,:,indice_clim);
Res_N_new_tot(:,:,indice_frigo);
Res_M(:,:,indice_frigo);
Res_N_new_tot(:,:,indice_electromenager);
Res_M(:,:,indice_electromenager);
Res_N_new_tot(:,:,indice_eclairage);
Res_M(:,:,indice_eclairage);
Res_N_new_tot(:,:,indice_cuisine);
Res_M(:,:,indice_cuisine);
Res_N_new_tot(:,:,indice_chauffEau);
Res_M(:,:,indice_chauffEau);
Res_rho_coal_exo(:,:,indice_chauffage);
Res_rho_coal_exo(:,:,indice_cuisine);
Res_rho_coal_exo(:,:,indice_chauffEau);
Res_rho_gas_exo(:,:,indice_chauffage);
Res_rho_gas_exo(:,:,indice_cuisine);
Res_rho_gas_exo(:,:,indice_chauffEau);
Res_rho_oil_exo(:,:,indice_chauffage);
Res_rho_oil_exo(:,:,indice_eclairage);
Res_rho_oil_exo(:,:,indice_cuisine);
Res_rho_oil_exo(:,:,indice_chauffEau);
Res_rho_elec_exo(:,:,indice_chauffage);
Res_rho_elec_exo(:,:,indice_clim);
Res_rho_elec_exo(:,:,indice_frigo);
Res_rho_elec_exo(:,:,indice_electromenager);
Res_rho_elec_exo(:,:,indice_eclairage);
Res_rho_elec_exo(:,:,indice_cuisine);
Res_rho_elec_exo(:,:,indice_chauffEau);
Res_part_coal(:,:,indice_chauffage);
Res_part_coal(:,:,indice_cuisine);
Res_part_coal(:,:,indice_chauffEau);
Res_part_gas(:,:,indice_chauffage);
Res_part_gas(:,:,indice_cuisine);
Res_part_gas(:,:,indice_chauffEau);
Res_part_oil(:,:,indice_chauffage);
Res_part_oil(:,:,indice_eclairage);
Res_part_oil(:,:,indice_cuisine);
Res_part_oil(:,:,indice_chauffEau);
Res_part_elec(:,:,indice_chauffage);
Res_part_elec(:,:,indice_clim);
Res_part_elec(:,:,indice_frigo);
Res_part_elec(:,:,indice_electromenager);
Res_part_elec(:,:,indice_eclairage);
Res_part_elec(:,:,indice_cuisine);
Res_part_elec(:,:,indice_chauffEau);
];

mkcsv( 'res_save2');

