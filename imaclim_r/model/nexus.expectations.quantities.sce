//Anticipations des capacités
if current_time_im==1 //cas specifique la premiere annee
    tx_Q_prev=1+txCap;
    tx_Q=1+txCap;
else  //cas generique
    tx_Q_prev=tx_Q;
    tx_Q=Q_noDI./Q_noDI_prev;
end

if %f //cas d'anticpation prolongeant la tendance actuelle
    taux_Q_nexus = tx_Q;
else //anticipation sur un trend moyen
    taux_Q_nexus =  sg_mean("tx_Q",3);
end
