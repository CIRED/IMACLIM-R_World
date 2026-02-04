// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

exec("preamble.sce");
wasdone = check_wasdone(liste_savedir);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//on récupère des vecteurs avec les valeurs des indices pour chaque scenario
nCombis = size(matrice_indices,1);
[ind_climat,ind_EEI,ind_CCS,ind_NUC,ind_ENR,ind_bioEnergy,ind_recycling,ind_infra,ind_traj] = combi2indices((1:size(matrice_indices,1))',matrice_indices);
numIndClimat = 1;
m_combi = 1:nCombis;
combiDirs = get_dirlist();
tVec = 1:TimeHorizon+1;
timeLine = tVec + 2000;

finishDate   = (TimeHorizon+1) * (ind_climat==0);
nanification = ones(nCombis,TimeHorizon+1);
for combi = m_combi(ind_climat~=0)
    if wasdone(combi)
        finishDate(combi) = TimeHorizon+1;
    else
        ldsav("wp_oil_sav","",combiDirs(combi));
        finishDate(combi) = find(wp_oil_sav==0,1) - 2;
    end
    nanification(combi,(1:TimeHorizon+1) > finishDate(combi)) = %nan;
end

carbonTax = zeros(nCombis,TimeHorizon+1);
for combi = m_combi
    ldsav("taxMKT_sav","",combiDirs(combi));
    carbonTax(combi,:) = taxMKT_sav;
end
carbonTax = (carbonTax * 1e6) .* nanification;

avoidedEmis = zeros(nCombis,TimeHorizon+1);
for combi = m_combi
    ldsav("emi_evitee_sav","",combiDirs(combi));
    avoidedEmis(combi,:) = sum(emi_evitee_sav,1);
end
avoidedEmis = (avoidedEmis / 1e3) .* nanification;

emis = zeros(nCombis,TimeHorizon+1);
for combi = m_combi
    clear E_reg_use_sav
    ldsav("E_reg_use_sav.sav","",combiDirs(combi));
    emis(combi,:) = sum(E_reg_use_sav,1);
end
emis = (emis / 1e3) .* nanification;
emis(ind_climat == 0,:)=%nan;

GDP_MER_real = zeros(nCombis,TimeHorizon+1);
for combi = m_combi
    ldsav("GDP_MER_real_sav","",combiDirs(combi));
    GDP_MER_real(combi,:) = sum(GDP_MER_real_sav,1);
end
GDP_MER_real = (GDP_MER_real / 1e3) .* nanification;
if %f
costs_GDP_MER_real = zeros(nCombis,TimeHorizon+1);
costs_GDP_MER_real(49:$,:) = GDP_MER_real(49:$,:) -  GDP_MER_real(1:48,:);

clf();
subplot(221);
plot(timeLine,carbonTax(ind_traj==0,tVec),"r","linewidth",2);
plot(timeLine,carbonTax(ind_traj==1,tVec),"g","linewidth",2);
subplot(222);
plot(timeLine,avoidedEmis(ind_traj==0,tVec),"r","linewidth",2);
plot(timeLine,avoidedEmis(ind_traj==1,tVec),"g","linewidth",2);
subplot(223);
plot(timeLine,emis(ind_traj==0,tVec),"r","linewidth",2);
plot(timeLine,emis(ind_traj==1,tVec),"g","linewidth",2);
subplot(224);
plot(timeLine,GDP_MER_real(ind_traj==0,tVec),"r","linewidth",2);
plot(timeLine,GDP_MER_real(ind_traj==1,tVec),"g","linewidth",2);


for combi = 1:2:47
    yesorno = and(wasdone([combi,combi+1,48+combi,48+combi+1]));
    wasdone([combi,combi+1,48+combi,48+combi+1])=yesorno;
end

GDP_losses_traj0 = mean(GDP_MER_real(wasdone&ind_traj==0&ind_climat~=0,:),1) ./ mean(GDP_MER_real(wasdone&ind_traj==0&ind_climat==0,:),1) - 1;
GDP_losses_traj1 = mean(GDP_MER_real(wasdone&ind_traj==1&ind_climat~=0,:),1) ./ mean(GDP_MER_real(wasdone&ind_traj==1&ind_climat==0,:),1) - 1;

figure();
clf();
plot(timeLine,GDP_losses_traj0,"r","linewidth",2);
plot(timeLine,GDP_losses_traj1,"g","linewidth",2);

GDP_losses_traj0 = mean(GDP_MER_real(ind_traj==0&ind_climat~=0,:),1) ./ mean(GDP_MER_real(ind_traj==0&ind_climat==0,:),1) - 1;
GDP_losses_traj1 = mean(GDP_MER_real(ind_traj==1&ind_climat~=0,:),1) ./ mean(GDP_MER_real(ind_traj==1&ind_climat==0,:),1) - 1;

figure();
clf();
plot(timeLine,GDP_losses_traj0,"r","linewidth",2);
plot(timeLine,GDP_losses_traj1,"g","linewidth",2);
end
