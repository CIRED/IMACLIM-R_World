// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//////////////////////////////
// LED calibration - 2020 - 2050
// printing value and the ratio with the targeted values to reproduce the Grubler LED scenario

pkm_car = Tautomobile .* pkmautomobileref / 100  *1e-9;
pkm_ot = pkmautomobileref / 100 .* alphaOT .* DF(:,indice_OT) *1e-9;
pkm_air = pkmautomobileref / 100 .* alphaair .* DF(:,indice_air)*1e-9;


pkm_ot_n = sum(pkm_ot(ind_global_north)) ./ sum( Ltot(ind_global_north));
pkm_air_n = sum(pkm_air(ind_global_north))./ sum( Ltot(ind_global_north));
pkm_car_n = sum(pkm_car(ind_global_north))./ sum( Ltot(ind_global_north));
pkm_ot_s = sum(pkm_ot(ind_global_south))./ sum( Ltot(ind_global_south));
pkm_air_s = sum(pkm_air(ind_global_south))./ sum( Ltot(ind_global_south));
pkm_car_s = sum(pkm_car(ind_global_south))./ sum( Ltot(ind_global_south));
pkm_ot_n = sum(pkm_ot(ind_global_north)) ;
pkm_air_n = sum(pkm_air(ind_global_north));
pkm_car_n = sum(pkm_car(ind_global_north));
pkm_ot_s = sum(pkm_ot(ind_global_south));
pkm_air_s = sum(pkm_air(ind_global_south));
pkm_car_s = sum(pkm_car(ind_global_south));

ener_pkm_car = (alphaelecauto + alphaEtauto) .* Tautomobile .* pkmautomobileref ./100 *mtoe2ej;
ener_pkm_air = DF(:,indice_air) .* matrix(sum(CI(energyIndexes,indice_air,:) ,1), nb_regions,1)*mtoe2ej;
ener_pkm_ot = DF(:,indice_OT) .* matrix(sum(CI(energyIndexes,indice_OT,:) ,1), nb_regions,1)*mtoe2ej;
ener_tot_air = Q(:,indice_air) .* matrix(sum(CI(energyIndexes,indice_air,:) ,1), nb_regions,1)*mtoe2ej;
ener_tot_ot = Q(:,indice_OT) .* matrix(sum(CI(energyIndexes,indice_OT,:) ,1), nb_regions,1)*mtoe2ej;
ener_fret_air = ener_tot_air - ener_pkm_air;
ener_fret_air_int = ExpTI(:,indice_air) .* matrix(sum(CI(energyIndexes,indice_air,:) ,1), nb_regions,1)*mtoe2ej;
ener_fret_ot = ener_tot_ot - ener_pkm_ot;

ener_indus = Q(:,indus) .* matrix(sum(CI(energyIndexes,indus,:) ,1), nb_regions,1) *mtoe2ej;
for kk=1:12
    ener_indus(kk) = ener_indus(kk) + sum(energy_balance(conso_agri_eb,:,kk)) * 0.36273879204991316 * mtoe2ej + (sum(energy_balance(conso_btp_eb,:,kk)))* mtoe2ej;
end

ener_indus_n_2050 = sum( ener_indus(ind_global_north)); 
ener_indus_s_2050 = sum( ener_indus(ind_global_south)); 

m2batiment_n = sum( stockbatiment(ind_global_north)) / 1e9;
m2batiment_s = sum( stockbatiment(ind_global_south)) / 1e9;
m2batiment = stockbatiment / 1e9;
ener_resid = stockbatiment.*(alphaCoalm2+alphaEtm2+alphaGazm2+alphaelecm2) + DF(:,indice_oil);
ener_resid_n = sum( ener_resid(ind_global_north))*mtoe2ej;
ener_resid_s = sum( ener_resid(ind_global_south))*mtoe2ej;

fe=  (sum(energy_balance(conso_tot_eb,:,:)) -sum(energy_balance(marbunk_eb,:,:))  )*mtoe2ej;
emi = (sum(E_reg_use(:,:)) + emi_evitee(:))/1e6;

emi_elec = sum(E_reg_use(:,iu_elec)/1e6 + emi_evitee(:)/1e6);
emi_supp = sum(E_reg_use(:,iu_ener))/1e6 + sum(emi_evitee(:)/1e6);
emi_indus = sum( E_reg_use(:,iu_indu)/1e6);
emi_residcom = 0;
emi_resid = 0;
emi_com = 0;
emi_trans = 0;

fe_et_resid=0;
fe_trans=0;
fe_indu=0;
fe_indu_n=0;
fe_indu_s=0;
fe_comp=0;
fe_comp_n=0;
fe_comp_s=0;

fe_ship_n=0;
fe_ship_s=0;

fe_detail = zeros( 15,1);
fe_detail_s = zeros( 15,1);
fe_detail_n = zeros( 15,1);
for kk=1:reg
    fe_et_resid = fe_et_resid + energy_balance(conso_resid_eb,et_eb,kk) * mtoe2ej;
    fe_trans = fe_trans + sum(energy_balance(conso_transport_eb,:,kk)) * mtoe2ej;
    fe_indu = fe_indu + (sum(energy_balance(conso_indu_eb,:,kk))+sum(energy_balance(conso_agri_eb,:,kk))+sum(energy_balance(conso_btp_eb,:,kk)))* mtoe2ej;
    fe_comp = fe_comp + (sum(energy_balance(conso_comp_eb,:,kk)))* mtoe2ej;
    fe_detail( conso_comp_eb-9) = fe_detail( conso_comp_eb-9) + (sum(energy_balance(conso_comp_eb,:,kk)))* mtoe2ej;
    fe_detail( conso_agri_eb-9) = fe_detail( conso_agri_eb-9) + (sum(energy_balance(conso_agri_eb,:,kk)))* mtoe2ej;
    fe_detail( conso_indu_eb-9) = fe_detail( conso_indu_eb-9) + (sum(energy_balance(conso_indu_eb,:,kk)))* mtoe2ej;
    fe_detail( conso_air_eb-9) = fe_detail( conso_air_eb-9) + (sum(energy_balance(conso_air_eb,:,kk)))* mtoe2ej;
    fe_detail( conso_ot_eb-9) = fe_detail( conso_ot_eb-9) + (sum(energy_balance(conso_ot_eb,:,kk)))* mtoe2ej;
    fe_detail( conso_car_eb-9) = fe_detail( conso_car_eb-9) + (sum(energy_balance(conso_car_eb,:,kk)))* mtoe2ej;
    fe_detail( conso_resid_eb-9) = fe_detail( conso_resid_eb-9) + (sum(energy_balance(conso_resid_eb,:,kk)))* mtoe2ej;
    fe_detail( conso_btp_eb-9) = fe_detail( conso_btp_eb-9) + (sum(energy_balance(conso_btp_eb,:,kk)))* mtoe2ej;
    fe_detail( 9) = fe_detail( 9) - (sum(energy_balance(marbunk_eb,:,kk)))* mtoe2ej;
    fe_detail( 10) = fe_detail( 10) + (sum(energy_balance(conso_tot_eb,:,kk))-sum(energy_balance(marbunk_eb,:,kk)))* mtoe2ej;
    fe_detail( 12) = sum(ener_pkm_air);
    fe_detail( 13) = sum(ener_fret_air);
    fe_detail( 16) = sum(ener_pkm_ot);
    fe_detail( 15) = sum(ener_fret_ot);
    fe_detail( 14) = sum(ener_fret_air_int);
end

for kk=ind_global_north
    fe_et_resid = fe_et_resid + energy_balance(conso_resid_eb,et_eb,kk) * mtoe2ej;
    fe_trans = fe_trans + sum(energy_balance(conso_transport_eb,:,kk)) * mtoe2ej;
    fe_indu = fe_indu + (sum(energy_balance(conso_indu_eb,:,kk))+sum(energy_balance(conso_agri_eb,:,kk))+sum(energy_balance(conso_btp_eb,:,kk)))* mtoe2ej;
    fe_comp = fe_comp + (sum(energy_balance(conso_comp_eb,:,kk)))* mtoe2ej;
    fe_detail_n( conso_comp_eb-9) = fe_detail_n( conso_comp_eb-9) + (sum(energy_balance(conso_comp_eb,:,kk)))* mtoe2ej;
    fe_detail_n( conso_agri_eb-9) = fe_detail_n( conso_agri_eb-9) + (sum(energy_balance(conso_agri_eb,:,kk)))* mtoe2ej;
    fe_detail_n( conso_indu_eb-9) = fe_detail_n( conso_indu_eb-9) + (sum(energy_balance(conso_indu_eb,:,kk)))* mtoe2ej;
    fe_detail_n( conso_air_eb-9) = fe_detail_n( conso_air_eb-9) + (sum(energy_balance(conso_air_eb,:,kk)))* mtoe2ej;
    fe_detail_n( conso_ot_eb-9) = fe_detail_n( conso_ot_eb-9) + (sum(energy_balance(conso_ot_eb,:,kk)))* mtoe2ej;
    fe_detail_n( conso_car_eb-9) = fe_detail_n( conso_car_eb-9) + (sum(energy_balance(conso_car_eb,:,kk)))* mtoe2ej;
    fe_detail_n( conso_resid_eb-9) = fe_detail_n( conso_resid_eb-9) + (sum(energy_balance(conso_resid_eb,:,kk)))* mtoe2ej;
    fe_detail_n( conso_btp_eb-9) = fe_detail_n( conso_btp_eb-9) + (sum(energy_balance(conso_btp_eb,:,kk)))* mtoe2ej;
    fe_detail_n( 9) = fe_detail_n( 9) - (sum(energy_balance(marbunk_eb,:,kk)))* mtoe2ej;
    fe_detail_n( 10) = fe_detail_n( 10) + (sum(energy_balance(conso_tot_eb,:,kk))-sum(energy_balance(marbunk_eb,:,kk)))* mtoe2ej;
    fe_detail_n( 12) = sum(ener_pkm_air);
    fe_detail_n( 13) = sum(ener_fret_air);
    fe_detail_n( 16) = sum(ener_pkm_ot);
    fe_detail_n( 15) = sum(ener_fret_ot);
    fe_detail_n( 14) = sum(ener_fret_air_int);
end

for kk=ind_global_south
    fe_et_resid = fe_et_resid + energy_balance(conso_resid_eb,et_eb,kk) * mtoe2ej;
    fe_trans = fe_trans + sum(energy_balance(conso_transport_eb,:,kk)) * mtoe2ej;
    fe_indu = fe_indu + (sum(energy_balance(conso_indu_eb,:,kk))+sum(energy_balance(conso_agri_eb,:,kk))+sum(energy_balance(conso_btp_eb,:,kk)))* mtoe2ej;
    fe_comp = fe_comp + (sum(energy_balance(conso_comp_eb,:,kk)))* mtoe2ej;
    fe_detail_s( conso_comp_eb-9) = fe_detail_s( conso_comp_eb-9) + (sum(energy_balance(conso_comp_eb,:,kk)))* mtoe2ej;
    fe_detail_s( conso_agri_eb-9) = fe_detail_s( conso_agri_eb-9) + (sum(energy_balance(conso_agri_eb,:,kk)))* mtoe2ej;
    fe_detail_s( conso_indu_eb-9) = fe_detail_s( conso_indu_eb-9) + (sum(energy_balance(conso_indu_eb,:,kk)))* mtoe2ej;
    fe_detail_s( conso_air_eb-9) = fe_detail_s( conso_air_eb-9) + (sum(energy_balance(conso_air_eb,:,kk)))* mtoe2ej;
    fe_detail_s( conso_ot_eb-9) = fe_detail_s( conso_ot_eb-9) + (sum(energy_balance(conso_ot_eb,:,kk)))* mtoe2ej;
    fe_detail_s( conso_car_eb-9) = fe_detail_s( conso_car_eb-9) + (sum(energy_balance(conso_car_eb,:,kk)))* mtoe2ej;
    fe_detail_s( conso_resid_eb-9) = fe_detail_s( conso_resid_eb-9) + (sum(energy_balance(conso_resid_eb,:,kk)))* mtoe2ej;
    fe_detail_s( conso_btp_eb-9) = fe_detail_s( conso_btp_eb-9) + (sum(energy_balance(conso_btp_eb,:,kk)))* mtoe2ej;
    fe_detail_s( 9) = fe_detail_s( 9) - (sum(energy_balance(marbunk_eb,:,kk)))* mtoe2ej;
    fe_detail_s( 10) = fe_detail_s( 10) + (sum(energy_balance(conso_tot_eb,:,kk))-sum(energy_balance(marbunk_eb,:,kk)))* mtoe2ej;
    fe_detail_s( 12) = sum(ener_pkm_air);
    fe_detail_s( 13) = sum(ener_fret_air);
    fe_detail_s( 16) = sum(ener_pkm_ot);
    fe_detail_s( 15) = sum(ener_fret_ot);
    fe_detail_s( 14) = sum(ener_fret_air_int);
end


// conso_ot_eb : Q*CI
// conso_air_eb : Q*CI
// marbunk_eb : Q*CI


fe_tot_n=0;
fe_tot_s=0;
for kk=ind_global_north
    fe_indu_n = fe_indu_n + (sum(energy_balance(conso_indu_eb,:,kk))+sum(energy_balance(conso_agri_eb,:,kk))+sum(energy_balance(conso_btp_eb,:,kk)))* mtoe2ej;
    fe_comp_n = fe_comp_n + (sum(energy_balance(conso_comp_eb,:,kk)))* mtoe2ej;
    fe_ship_n = fe_ship_n - (sum(energy_balance(marbunk_eb,:,kk)))* mtoe2ej;
    fe_tot_n= fe_tot_n + (sum(energy_balance(conso_comp_eb,:,kk)))* mtoe2ej + (sum(energy_balance(conso_agri_eb,:,kk)))* mtoe2ej + (sum(energy_balance(conso_indu_eb,:,kk)))* mtoe2ej + (sum(energy_balance(conso_air_eb,:,kk)))* mtoe2ej + (sum(energy_balance(conso_ot_eb,:,kk)))* mtoe2ej + (sum(energy_balance(conso_car_eb,:,kk)))* mtoe2ej + (sum(energy_balance(conso_resid_eb,:,kk)))* mtoe2ej + (sum(energy_balance(conso_btp_eb,:,kk)))* mtoe2ej - (sum(energy_balance(marbunk_eb,:,kk)))* mtoe2ej;
end
for kk=ind_global_south
    fe_indu_s = fe_indu_s + (sum(energy_balance(conso_indu_eb,:,kk))+sum(energy_balance(conso_agri_eb,:,kk))+sum(energy_balance(conso_btp_eb,:,kk)))* mtoe2ej;
    fe_comp_s = fe_comp_s + (sum(energy_balance(conso_comp_eb,:,kk)))* mtoe2ej;
    fe_ship_s = fe_ship_s - (sum(energy_balance(marbunk_eb,:,kk)))* mtoe2ej;
    fe_tot_s= fe_tot_s + (sum(energy_balance(conso_comp_eb,:,kk)))* mtoe2ej + (sum(energy_balance(conso_agri_eb,:,kk)))* mtoe2ej + (sum(energy_balance(conso_indu_eb,:,kk)))* mtoe2ej + (sum(energy_balance(conso_air_eb,:,kk)))* mtoe2ej + (sum(energy_balance(conso_ot_eb,:,kk)))* mtoe2ej + (sum(energy_balance(conso_car_eb,:,kk)))* mtoe2ej + (sum(energy_balance(conso_resid_eb,:,kk)))* mtoe2ej + (sum(energy_balance(conso_btp_eb,:,kk)))* mtoe2ej - (sum(energy_balance(marbunk_eb,:,kk)))* mtoe2ej;
end


fe_detail( 11) = sum( fe_detail(1:9));
fe_detail_percent = fe_detail / fe_detail( 11);

// names of energy matrice
fe_detail_label = [
"Services"
"Agriculture - Food industry"
"Industry"
"Air Transport"
"Terrestrial Transport"
"Private cars"
"Residential"
"Constructiob"
"Shipping"
"Total"
"Total as sum"
"Air Transport - Mobility"
"Air Transport - Freight"
"Air Transport - Freight Int."
"Terrestrial Transport - Freight"
"Terrestrial Transport - Mobility"
];

fe_detail_s( 12) = sum(ener_pkm_air);
fe_detail_s( 13) = sum(ener_fret_air);
fe_detail_s( 16) = sum(ener_pkm_ot);
fe_detail_s( 15) = sum(ener_fret_ot);
fe_detail_s( 14) = sum(ener_fret_air_int);



for k=1:reg
    emi_residcom = emi_residcom + (..
        + coef_Q_CO2_DF(k,coal)'       .* energy_balance(conso_resid_eb,coal_eb,k) ..
        + coef_Q_CO2_DF(k,oil)'        .* energy_balance(conso_resid_eb,oil_eb,k)  ..
        + coef_Q_CO2_DF(k,gaz)'        .* energy_balance(conso_resid_eb,gas_eb,k)  ..
        + coef_Q_CO2_DF(k,et)'         .* energy_balance(conso_resid_eb,et_eb,k)   ..
        + coef_Q_CO2_CI(coal,compo,k) .* energy_balance(conso_comp_eb, coal_eb,k) ..
        + coef_Q_CO2_CI(oil,compo,k)  .* energy_balance(conso_comp_eb, oil_eb,k) ..
        + coef_Q_CO2_CI(gaz,compo,k)  .* energy_balance(conso_comp_eb, gas_eb,k)  ..
        + coef_Q_CO2_CI(et,compo,k)   .* energy_balance(conso_comp_eb, et_eb,k)   ..
    )/1e6;
    emi_resid = emi_resid + (..
        + coef_Q_CO2_DF(k,coal)'       .* energy_balance(conso_resid_eb,coal_eb,k) ..
        + coef_Q_CO2_DF(k,oil)'        .* energy_balance(conso_resid_eb,oil_eb,k)  ..
        + coef_Q_CO2_DF(k,gaz)'        .* energy_balance(conso_resid_eb,gas_eb,k)  ..
        + coef_Q_CO2_DF(k,et)'         .* energy_balance(conso_resid_eb,et_eb,k)   ..
    )/1e6;
    emi_com = emi_com + (..
        + coef_Q_CO2_CI(coal,compo,k) .* energy_balance(conso_comp_eb, coal_eb,k) ..
        + coef_Q_CO2_CI(oil,compo,k)  .* energy_balance(conso_comp_eb, oil_eb,k) ..
        + coef_Q_CO2_CI(gaz,compo,k)  .* energy_balance(conso_comp_eb, gas_eb,k)  ..
        + coef_Q_CO2_CI(et,compo,k)   .* energy_balance(conso_comp_eb, et_eb,k)   ..
    )/1e6;

    emi_trans = emi_trans + (..
        + coef_Q_CO2_DF(k,coal).* energy_balance(conso_car_eb,coal_eb,k)' ..
        + coef_Q_CO2_DF(k,oil) .* energy_balance(conso_car_eb,oil_eb,k)'  ..
        + coef_Q_CO2_DF(k,gaz) .* energy_balance(conso_car_eb,gas_eb,k)'  ..
        + coef_Q_CO2_DF(k,et)  .* energy_balance(conso_car_eb,et_eb,k)'   ..
        + E_reg_use(k,iu_air) ..
        + E_reg_use(k,iu_mer) ..
        + E_reg_use(k,iu_OT)  ..
    )/1e6;
end

di_indus = sum(DI(:,indus));
df_indus = sum(DF(:,indus));
dg_indus = sum(DG(:,indus));
ci_indus = 0;
ci_indus_reg = zeros(12,1);
expti_indus = sum(ExpTI(:,indus));
for ii=1:12
    for kk=1:12
        ci_indus = ci_indus + CI(indus,ii, kk) * Q(kk,ii);
        ci_indus_reg(kk) = ci_indus_reg(kk) + CI(indus,ii,kk)*Q(kk,ii);
    end
end

q_indus = sum(Q(:,indus));
q_comp = sum(Q(:,compo));


di_indusimp_s = sum(partImpDI(ind_global_south,indus).*DI(ind_global_south,indus));
df_indusimp_s = sum(partImpDF(ind_global_south,indus).*DF(ind_global_south,indus));
dg_indusimp_s = sum(partImpDG(ind_global_south,indus).*DG(ind_global_south,indus));
ci_indusimp_s = 0;
for kk=ind_global_south
    for ii=1:12
        //for ii=nonEnergyIndexes
        ci_indusimp_s = ci_indusimp_s + partImpCI(indus,ii,kk)*CI(indus,ii, kk) * Q(kk,ii);
    end
end
di_indusimp_n = sum(partImpDI(ind_global_north,indus).*DI(ind_global_north,indus));
df_indusimp_n = sum(partImpDF(ind_global_north,indus).*DF(ind_global_north,indus));
dg_indusimp_n = sum(partImpDG(ind_global_north,indus).*DG(ind_global_north,indus));
ci_indusimp_n = 0;
for kk=ind_global_north
    for ii=1:12
        //for ii=nonEnergyIndexes
        ci_indusimp_n = ci_indusimp_n + partImpCI(indus,ii,kk)*CI(indus,ii, kk) * Q(kk,ii);
    end
end

imp_indu_n = di_indusimp_n+df_indusimp_n+ci_indusimp_n+dg_indusimp_n;
imp_indu_s = di_indusimp_s+df_indusimp_s+ci_indusimp_s+dg_indusimp_s;

di_indusdom_s = sum(partDomDI(ind_global_south,indus).*DI(ind_global_south,indus)) + sum(marketshare(ind_global_south,indus)) * di_indusimp_s;
df_indusdom_s = sum(partDomDF(ind_global_south,indus).*DF(ind_global_south,indus)) + sum(marketshare(ind_global_south,indus)) * df_indusimp_s;
dg_indusdom_s = sum(partDomDG(ind_global_south,indus).*DG(ind_global_south,indus)) + sum(marketshare(ind_global_south,indus)) * dg_indusimp_s;
exp_indu_s = sum(marketshare(ind_global_south,indus)) * ( di_indusimp_n + df_indusimp_n + dg_indusimp_n + ci_indusimp_n);
ci_indusdom_s = 0;
ci_airdom_s = 0;
//ci_indusdom_s = ci_indusdom_s + sum(marketshare(ind_global_south,indus)) * ci_indusimp_s;
for kk=ind_global_south
    for ii=1:12
        //for ii=nonEnergyIndexes
        ci_indusdom_s = ci_indusdom_s + partDomCI(indus,ii,kk)*CI(indus,ii, kk) * Q(kk,ii);
        ci_airdom_s = ci_airdom_s + partDomCI(air,ii,kk)*CI(air,ii, kk) * Q(kk,ii);
    end
end

di_indusdom_n = sum(partDomDI(ind_global_north,indus).*DI(ind_global_north,indus)) + sum(marketshare(ind_global_north,indus)) * di_indusimp_n;
df_indusdom_n = sum(partDomDF(ind_global_north,indus).*DF(ind_global_north,indus)) + sum(marketshare(ind_global_north,indus)) * df_indusimp_n;
dg_indusdom_n = sum(partDomDG(ind_global_north,indus).*DG(ind_global_north,indus)) + sum(marketshare(ind_global_north,indus)) * dg_indusimp_n;
exp_indu_n = sum(marketshare(ind_global_north,indus)) * ( di_indusimp_s + df_indusimp_s + dg_indusimp_s + ci_indusimp_s);
ci_indusdom_n = 0;
ci_indusdom_n = ci_indusdom_n+ sum(marketshare(ind_global_north,indus)) * ci_indusimp_n;
ci_airdom_n = 0;
for kk=ind_global_north
    for ii=1:12
        //for ii=nonEnergyIndexes
        ci_indusdom_n = ci_indusdom_n + partDomCI(indus,ii,kk)*CI(indus,ii, kk) * Q(kk,ii);
        ci_airdom_n = ci_airdom_n + partDomCI(air,ii,kk)*CI(air,ii, kk) * Q(kk,ii);
    end
end

ci_indus_n = ci_indusdom_n + ci_indusimp_n;
ci_indus_s = ci_indusdom_s + ci_indusimp_s;

nrb_n = sum(NRB(ind_global_north));
nrb_s = sum(NRB(ind_global_south));
ci_indus_indus_dom_n = 0;
ci_indus_indus_n = 0;
ci_indus_comp_dom_n = 0;
ci_indus_comp_n = 0;

for kk=ind_global_north
    ci_indus_indus_dom_n = ci_indus_indus_dom_n + partDomCI(indus,indus,kk)*CI(indus,indus, kk) * Q(kk,indus);
    ci_indus_indus_n = ci_indus_indus_n + CI(indus,indus, kk) * Q(kk,indus);
    ci_indus_comp_dom_n = ci_indus_comp_dom_n + partDomCI(indus,compo,kk)*CI(indus,compo, kk) * Q(kk,compo);
    ci_indus_comp_n = ci_indus_comp_dom_n + CI(indus,compo, kk) * Q(kk,compo);
end

ci_indus_indus_dom_s = 0;
ci_indus_indus_s = 0;
ci_indus_comp_dom_s = 0;
ci_indus_comp_s = 0;

for kk=ind_global_south
    ci_indus_indus_dom_s = ci_indus_indus_dom_s + partDomCI(indus,indus,kk)*CI(indus,indus, kk) * Q(kk,indus);
    ci_indus_indus_s = ci_indus_indus_s + CI(indus,indus, kk) * Q(kk,indus);
    ci_indus_comp_dom_s = ci_indus_comp_dom_s + partDomCI(indus,compo,kk)*CI(indus,compo, kk) * Q(kk,compo);
    ci_indus_comp_s = ci_indus_comp_dom_s + CI(indus,compo, kk) * Q(kk,compo);
end

ci_indus_oth_dom_s = ci_indusdom_s - ci_indus_indus_dom_s - ci_indus_comp_dom_s;
ci_indus_oth_s = ci_indus_s - ci_indus_indus_s - ci_indus_comp_s;
ci_indus_oth_dom_n = ci_indusdom_n - ci_indus_indus_dom_n - ci_indus_comp_dom_n;
ci_indus_oth_n = ci_indus_n - ci_indus_indus_n - ci_indus_comp_n;

q_indus_n = sum(Q(ind_global_north, indus));
q_indus_s = sum(Q(ind_global_south, indus));
q_comp_n = sum(Q(ind_global_north, compo));
q_comp_s = sum(Q(ind_global_south, compo));
df_indus_n = sum(DF(ind_global_north, indus));
df_indus_s = sum(DF(ind_global_south, indus));
dg_indus_n = sum(DG(ind_global_north, indus));
dg_indus_s = sum(DG(ind_global_south, indus));
di_indus_n = sum(DI(ind_global_north, indus));
di_indus_s = sum(DI(ind_global_south, indus));

// LED sc.  2020
// 35182 MtCO2/yr
// 418 EJ/yr
//112 000 billion $2010, ~ 91000 billion $2001
//disp( [ sum(NRB(ind_global_north)) / 12891231., sum(NRB(ind_global_south)) / 14336136.], "[ sum(NRB(ind_global_north)) / 12891231., sum(NRB(ind_global_south)) / 14336136.]")
//disp( [ sum(NRB(ind_global_north)), sum(NRB(ind_global_south)), mean(DIbeta( ind_global_north, indus)), mean( DIbeta( ind_global_south, indus)), mean(pArmDI( ind_global_north, indus)),  mean(pArmDI( ind_global_south, indus))  ], "NRB n s, DIbeta n s")
// GDP SSP2 2050 208354.59 $2001
// SSP2 ~ 2050
// 650 EJ
// Emi : 55000

ind_temp = [ btp  air mer ot indus];

solarwind=0;
for k=1:12
    solarwind =  solarwind + energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoSolar)) * mtoe2ej + energy_balance(pwplant_eb,elec_eb,k) * sum(msh_elec_techno(k,technoWind))* mtoe2ej;
end


if current_time_im<=2020-base_year_simulation
    //disp( "[VA_PPP_real(ind_global_south, indus), VA(ind_global_north, indus), VA(ind_global_south, indus)/ VA(ind_global_north, indus)]")
    //disp( [ sum(VA(ind_global_south, ind_temp)) ./ GDP(ind_global_south) .* GDP_PPP_real(ind_global_south)), sum(VA(ind_global_north, ind_temp) ./ GDP(ind_global_north) .* GDP_PPP_real(ind_global_north)), sum(VA(ind_global_south, ind_temp) ./ GDP(ind_global_south) .* GDP_PPP_real(ind_global_south)) ./ sum(VA(ind_global_north, ind_temp)./ GDP(ind_global_north) .* GDP_PPP_real(ind_global_north))])

    //disp("[VA as percentage of GDP]")
    //disp( [sum(VA(ind_global_south, ind_temp) ./ GDP(ind_global_south) .* GDP_PPP_real(ind_global_south)) ./ sum(GDP_PPP_real(ind_global_south)), sum(VA(ind_global_north, ind_temp) ./ GDP(ind_global_north) .* GDP_PPP_real(ind_global_north)) ./ sum(GDP_PPP_real(ind_global_north)) ])
    disp("[VA as percentage of GDP 2]")
    disp( [ sum(GDP_sect(ind_global_south, ind_temp)) ./ sum(GDP_sect(ind_global_south, :)), sum(GDP_sect(ind_global_north,ind_temp)) ./ sum(GDP_sect(ind_global_north, :)),   sum(GDP_sect(ind_global_south, ind_temp)) ./ sum(GDP_sect(ind_global_south, :)) ./ sum(GDP_sect(ind_global_north, ind_temp)) .* sum(GDP_sect(ind_global_north, :)) ])

    disp( "[VA(ind_global_south, indus), VA(ind_global_north, indus), VA(ind_global_south, indus)/ VA(ind_global_north, indus)]")
    disp( [ sum(VA(ind_global_south, ind_temp)), sum(VA(ind_global_north, ind_temp)), sum(VA(ind_global_south, ind_temp)) ./ sum(VA(ind_global_north, ind_temp))])
    disp( "[ Q(ind_global_south, indus), Q(ind_global_north, indus), Q(ind_global_south, indus)/ Q(ind_global_north, indus)]")
    disp( [ sum(Q(ind_global_south, ind_temp)), sum(Q(ind_global_north, ind_temp)), sum(Q(ind_global_south, ind_temp)) ./ sum(Q(ind_global_north, ind_temp))])
    disp( "[ p *Q(ind_global_south, indus), p*Q(ind_global_north, indus), p*Q(ind_global_south, indus)/ p*Q(ind_global_north, indus)]")
    disp( [ sum( p(ind_global_south, ind_temp).*Q(ind_global_south, ind_temp)), sum(p(ind_global_north, ind_temp).*Q(ind_global_north, ind_temp)), sum(p(ind_global_south, ind_temp).*Q(ind_global_south, ind_temp)) ./ sum(p(ind_global_north, ind_temp).*Q(ind_global_north, ind_temp))])

    disp("[fe_indu_n, fe_indu_s, fe_indu_n+fe_indu_s, fe_indu_n/fe_indu_s]")
    disp([fe_indu_n, fe_indu_s, fe_indu_n+fe_indu_s, fe_indu_n/fe_indu_s])

    disp("solarwind")
    disp(solarwind)
end

if current_time_im==2020-base_year_simulation
    disp( "[ pkm_ot_n, pkm_air_n, pkm_car_n ]");
    disp( [ [ pkm_ot_n, pkm_air_n, pkm_car_n ]; [pkm_ot_n_2020_obj, pkm_air_n_2020_obj, pkm_car_n_2020_obj]; [ pkm_ot_n/pkm_ot_n_2020_obj, pkm_air_n/pkm_air_n_2020_obj, pkm_car_n /pkm_car_n_2020_obj]]); 
    disp( "[ pkm_ot_s, pkm_air_s, pkm_car_s ]");
    disp( [ [ pkm_ot_s, pkm_air_s, pkm_car_s ]; [pkm_ot_s_2020_obj, pkm_air_s_2020_obj, pkm_car_s_2020_obj]; [ pkm_ot_s/pkm_ot_s_2020_obj, pkm_air_s/pkm_air_s_2020_obj, pkm_car_s /pkm_car_s_2020_obj]]); 
    disp( "[m2batiment_n, m2batiment_s, ener_resid_n, ener_resid_s]");
    disp( [ [m2batiment_n, m2batiment_s, ener_resid_n, ener_resid_s], [m2_resid_n_2020_obj, m2_resid_s_2020_obj, ener_resid_n_2020_obj, ener_resid_s_2020_obj], [m2batiment_n / m2_resid_n_2020_obj, m2batiment_s/m2_resid_s_2020_obj, ener_resid_n/ener_resid_n_2020_obj, ener_resid_s/ener_resid_s_2020_obj]]);
    // for industry
    disp(sum(GDP_PPP_constant), 'GDP')
    disp(fe, 'Final Energy');
    disp(emi, 'Emissions');
    disp('emi_elec', emi_elec)
    disp('emi_supp', emi_supp)
    disp('emi_indus', emi_indus)
    disp('emi_residcom', emi_residcom)
    disp('emi_com', emi_com)
    disp('emi_resid', emi_resid)
    disp('emi_trans', emi_trans)
    disp('GDP', sum(GDP_PPP_constant))
    disp(' fe_et_resid', fe_et_resid / 13.3) // 13.3 from Poles baseline - EMF33 sc.
    disp(' fe_trans', fe_trans) // 13.3 from Poles baseline - EMF33 sc.
    disp(' fe_indu', fe_indu) // 13.3 from Poles baseline - EMF33 sc.
    demand_indus_2020_n = sum(DF(ind_global_north, indus));
    demand_indus_2020_s = sum(DF(ind_global_south, indus));
    q_indus_2020_n = q_indus_n;
    q_indus_2020_s = q_indus_s;
    df_indus_2020_n = df_indus_n;
    df_indus_2020_s = df_indus_s;
    dg_indus_2020_n = dg_indus_n;
    dg_indus_2020_s = dg_indus_s;
    di_indus_2020_n = di_indus_n;
    di_indus_2020_s = di_indus_s;
    di_indusdom_n_20 = di_indusdom_n;
    df_indusdom_n_20 = df_indusdom_n;
    dg_indusdom_n_20 = dg_indusdom_n;
    exp_indu_n_20 = exp_indu_n;
    imp_indu_n_20 = imp_indu_n;
    ci_indusdom_n_20 = ci_indusdom_n;
    di_indusdom_s_20 = di_indusdom_s;
    df_indusdom_s_20 = df_indusdom_s;
    dg_indusdom_s_20 = dg_indusdom_s;
    exp_indu_s_20 = exp_indu_s;
    imp_indu_s_20 = imp_indu_s;
    ci_indusdom_s_20 = ci_indusdom_s;
    ci_indus_n_20 = ci_indus_n;
    ci_indus_s_20 = ci_indus_s;

    di_indusimp_n_20 = di_indusimp_n;
    df_indusimp_n_20 = df_indusimp_n;
    dg_indusimp_n_20 = dg_indusimp_n;
    ci_indusimp_n_20 = ci_indusimp_n;
    di_indusimp_s_20 = di_indusimp_s;
    df_indusimp_s_20 = df_indusimp_s;
    dg_indusimp_s_20 = dg_indusimp_s;
    ci_indusimp_s_20 = ci_indusimp_s;

    ci_indus_indus_dom_n_20 = ci_indus_indus_dom_n;
    ci_indus_indus_n_20 = ci_indus_indus_n;
    ci_indus_comp_dom_n_20 = ci_indus_comp_dom_n;
    ci_indus_comp_n_20 = ci_indus_comp_n;
    nrb_n_20 = nrb_n;
    nrb_s_20 = nrb_s;
    ci_indus_indus_dom_s_20 = ci_indus_indus_dom_s;
    ci_indus_indus_s_20 = ci_indus_indus_s;
    ci_indus_comp_dom_s_20 = ci_indus_comp_dom_s;
    ci_indus_comp_s_20 = ci_indus_comp_s;
    q_comp_n_20 = q_comp_n;
    q_comp_s_20 = q_comp_s;
    ci_indus_oth_dom_s_20 = ci_indus_oth_dom_s;
    ci_indus_oth_s_20 = ci_indus_oth_s;
    ci_indus_oth_dom_n_20 = ci_indus_oth_dom_n;
    ci_indus_oth_n_20 = ci_indus_oth_n;


    disp( [fe_detail, fe_detail_percent], "fe_detail")

    m2batiment_n_20=m2batiment_n;
    m2batiment_s_20=m2batiment_s;
    ener_int_m2_n_20=ener_resid_n/m2batiment_n;
    ener_int_m2_s_20=ener_resid_s/m2batiment_s;
    ener_int_m2_w_20=(ener_resid_n+ener_resid_s)/(m2batiment_n+m2batiment_s);

    pkm_ot_n_20=pkm_ot_n;
    pkm_air_n_20=pkm_air_n;
    pkm_car_n_20=pkm_car_n;
	
    pkm_ot_s_20=pkm_ot_s;
    pkm_air_s_20=pkm_air_s;
    pkm_car_s_20=pkm_car_s;
	

    ener_pkm_ot_n_20 = sum(ener_tot_ot(ind_global_north)) / pkm_ot_n;
    ener_pkm_air_n_20 = sum(ener_pkm_air(ind_global_north)) / pkm_air_n; 
    ener_pkm_car_n_20 = sum(ener_pkm_car(ind_global_north)) / pkm_car_n;
    ener_ot_tot_n_20 = sum(ener_tot_ot(ind_global_north));

    ener_pkm_ot_s_20 = sum(ener_tot_ot(ind_global_south)) / pkm_ot_s;
    ener_pkm_air_s_20 = sum(ener_pkm_air(ind_global_south)) / pkm_air_s; 
    ener_pkm_car_s_20 = sum(ener_pkm_car(ind_global_south)) / pkm_car_s;
    ener_ot_tot_s_20 = sum(ener_tot_ot(ind_global_south));

    ener_pkm_air_w_20 = (sum(ener_pkm_air(ind_global_south))+sum(ener_tot_ot(ind_global_north))) / (pkm_air_s+pkm_air_n); 
    ener_pkm_car_w_20 = ( sum(ener_pkm_car(ind_global_north)) +sum(ener_pkm_car(ind_global_south)) ) / (pkm_car_s+pkm_car_n);

    activity_ot_n_20 = sum(Q(ind_global_north,indice_OT)-DF(ind_global_north,indice_OT));
    activity_ot_s_20 = sum(Q(ind_global_south,indice_OT)-DF(ind_global_south,indice_OT));

    ener_int_ot_n_20 = ener_ot_tot_n_20 /activity_ot_n_20 ;
    ener_int_ot_s_20 = ener_ot_tot_s_20 /activity_ot_s_20 ;
    ener_int_ot_w_20 = (ener_ot_tot_s_20+ener_ot_tot_n_20) / (activity_ot_s_20+activity_ot_n_20) ;

		

    ener_indus_n_20 = sum( ener_indus(ind_global_north));
    ener_indus_s_20 = sum( ener_indus(ind_global_south));

    q_indus_n_20=q_indus_n;
    q_indus_s_20=q_indus_s;

    ener_int_indus_n_20 = q_indus_n / ener_indus_n_20; 
    ener_int_indus_s_20 = q_indus_s / ener_indus_s_20; 
    ener_int_indus_w_20 = (q_indus_s+q_indus_n) / (ener_indus_s_20+ener_indus_n_20); 

    q_comp_n_20 = sum(Q(ind_global_north,compo));
    q_comp_s_20 = sum(Q(ind_global_south,compo));

    ener_comp_n_20 = fe_comp_n;
    ener_comp_s_20 = fe_comp_s;

    ener_unit_comp_n_20 = q_comp_n_20/fe_comp_n;
    ener_unit_comp_s_20 = q_comp_s_20/fe_comp_s;
    ener_unit_comp_w_20 = (q_comp_s_20+q_comp_n_20)/(fe_comp_s+fe_comp_n);

    ener_fret_air_n_20 = sum(ener_fret_air(ind_global_north));
    ener_fret_air_s_20 = sum(ener_fret_air(ind_global_south));

    fe_ship_n_20 = fe_ship_n;
    fe_ship_s_20 = fe_ship_s;

    activity_fret_air_n_20 = sum(Q(ind_global_north,indice_air)-DF(ind_global_north,indice_air));
    activity_fret_air_s_20 = sum(Q(ind_global_south,indice_air)-DF(ind_global_south,indice_air));

    ener_f_int_air_n_20 = activity_fret_air_n_20 / ener_fret_air_n_20;
    ener_f_int_air_s_20 = activity_fret_air_s_20 / ener_fret_air_s_20;
    ener_f_int_air_w_20 = (activity_fret_air_s_20+activity_fret_air_n_20) / (ener_fret_air_s_20+ener_fret_air_n_20);

    activity_fret_mer_n_20 = sum(Q(ind_global_north,indice_mer));
    activity_fret_mer_s_20 = sum(Q(ind_global_south,indice_mer));

    ener_f_int_mer_n_20 = activity_fret_mer_n_20 / fe_ship_n_20;
    ener_f_int_mer_s_20 = activity_fret_mer_s_20 / fe_ship_s_20;
    ener_f_int_mer_w_20 = (activity_fret_mer_s_20+activity_fret_mer_n_20) / (fe_ship_s_20+fe_ship_n_20);

end

gdp_evol_n = sum(GDP_PPP_constant(ind_global_north)) ./ sum(GDP_PPP_constant_ref(ind_global_north));
gdp_evol_s = sum(GDP_PPP_constant(ind_global_south)) ./ sum(GDP_PPP_constant_ref(ind_global_south));

if current_time_im==2060-base_year_simulation | current_time_im==2050-base_year_simulation
    disp( "[ pkm_ot_n, pkm_air_n, pkm_car_n ]");
    disp( [ [ pkm_ot_n, pkm_air_n, pkm_car_n ]; [pkm_ot_n_2050_obj, pkm_air_n_2050_obj, pkm_car_n_2050_obj]; [ pkm_ot_n/pkm_ot_n_2050_obj, pkm_air_n/pkm_air_n_2050_obj, pkm_car_n /pkm_car_n_2050_obj]]); 
    disp( "[ pkm_ot_s, pkm_air_s, pkm_car_s ]");
    disp( [ [ pkm_ot_s, pkm_air_s, pkm_car_s ]; [pkm_ot_s_2050_obj, pkm_air_s_2050_obj, pkm_car_s_2050_obj]; [ pkm_ot_s/pkm_ot_s_2050_obj, pkm_air_s/pkm_air_s_2050_obj, pkm_car_s /pkm_car_s_2050_obj]]); 
    disp( "[ sum(ener_tot_ot(ind_global_north)), sum(ener_pkm_air(ind_global_north)), sum(ener_pkm_car(ind_global_north))]");
    disp( [ [ sum(ener_tot_ot(ind_global_north)), sum(ener_pkm_air(ind_global_north)), sum(ener_pkm_car(ind_global_north))]; [ ener_tot_ot_n_2050_obj, ener_pkm_air_n_2050_obj, ener_pkm_car_n_2050_obj]; [ sum(ener_tot_ot(ind_global_north)) ./ ener_tot_ot_n_2050_obj, sum(ener_pkm_air(ind_global_north)) ./ ener_pkm_air_n_2050_obj, sum(ener_pkm_car(ind_global_north)) ./ ener_pkm_car_n_2050_obj ]] );
    disp( "[ sum(ener_tot_ot(ind_global_south)), sum(ener_pkm_air(ind_global_south)), sum(ener_pkm_car(ind_global_south))]");
    disp( [ [ sum(ener_tot_ot(ind_global_south)), sum(ener_pkm_air(ind_global_south)), sum(ener_pkm_car(ind_global_south))]; [ ener_tot_ot_s_2050_obj, ener_pkm_air_s_2050_obj, ener_pkm_car_s_2050_obj]; [ sum(ener_tot_ot(ind_global_south)) ./ ener_tot_ot_s_2050_obj, sum(ener_pkm_air(ind_global_south)) ./ ener_pkm_air_s_2050_obj, sum(ener_pkm_car(ind_global_south)) ./ ener_pkm_car_s_2050_obj ]] );
    // Industry
    demand_indus_2050_n = sum(DF(ind_global_north, indus));
    demand_indus_2050_s = sum(DF(ind_global_south, indus));
    demand_indus_2050_n = sum(Q(ind_global_north, indus));
    demand_indus_2050_s = sum(Q(ind_global_south, indus));
    disp("[prod_indus_n_2050, prod_indus_s_2050]");
    disp( [ [(q_indus_n-q_indus_2020_n) / q_indus_2020_n, (q_indus_s-q_indus_2020_s)/q_indus_2020_s]; [-0.378, -0.142]; [(q_indus_n-q_indus_2020_n) / q_indus_2020_n /-0.15, (q_indus_s-q_indus_2020_s)/q_indus_2020_s / -0.04] ] );
    disp( (q_indus_n-q_indus_2020_n+q_indus_s-q_indus_2020_s)/ (q_indus_2020_n+q_indus_2020_s))
    target_n = -q_indus_2020_n * 15/100;
    target_s = -q_indus_2020_s * 4/100;
    //disp( [ -15/100, (di_indusdom_n-di_indusdom_n_20)/target_n, (df_indusdom_n-df_indusdom_n_20)/target_n, (dg_indusdom_n-dg_indusdom_n_20)/target_n, (ci_indusdom_n-ci_indusdom_n_20) / target_n, (exp_indu_n-exp_indu_n_20)/target_n],"contrib n")
    //disp( [ -4/100, (di_indusdom_s-di_indusdom_s_20)/target_s, (df_indusdom_s-df_indusdom_s_20)/target_s, (dg_indusdom_s-dg_indusdom_s_20)/target_s, (ci_indusdom_s-ci_indusdom_s_20) / target_s, (exp_indu_s-exp_indu_s_20)/target_s], "contrib s")
    //disp( [ [(df_indus_n-df_indus_2020_n) / df_indus_2020_n, (df_indus_s-df_indus_2020_s)/df_indus_2020_s]; [-0.15, -0.04]; [(df_indus_n-df_indus_2020_n) / df_indus_2020_n /-0.15, (df_indus_s-df_indus_2020_s)/df_indus_2020_s / -0.04] ] );
    disp( "[DI, DF, DG, CI, exp, %, N/S") 
    di_indusdom_n_50ref = 3687847.8;4836600.7;
    di_indusdom_s_50ref = 10257253.;23883648.;
    df_indusdom_n_50ref = 3253015.8;3445365.4;
    df_indusdom_s_50ref = 4452017.6;4717802.;
    dg_indusdom_n_50ref = 364355.09;354266.03;
    dg_indusdom_s_50ref = 115984.36;119161.09;
    ci_indusdom_n_50ref = 15070163.;19259447.;
    ci_indusdom_s_50ref = 50542885.;92059723.;
    exp_indu_n_50ref = 1998046.4;2672016.3;
    exp_indu_s_50ref = 6947144.6;10238123.;

    disp( "[DI, DF, DG, CI, exp") 
    //    disp( [ [ (di_indusdom_n-di_indusdom_n_50ref)/di_indusdom_n_50ref, (di_indusdom_s-di_indusdom_s_50ref)/di_indusdom_s_50ref];
    //            [ (df_indusdom_n-df_indusdom_n_50ref)/df_indusdom_n_50ref, (df_indusdom_s-df_indusdom_s_50ref)/df_indusdom_s_50ref];
    //            [ (dg_indusdom_n-dg_indusdom_n_50ref)/dg_indusdom_n_50ref, (dg_indusdom_s-dg_indusdom_s_50ref)/dg_indusdom_s_50ref];
    //            [ (ci_indusdom_n-ci_indusdom_n_50ref)/ci_indusdom_n_50ref, (ci_indusdom_s-ci_indusdom_s_50ref)/ci_indusdom_s_50ref];
    //            [  (exp_indu_n-exp_indu_n_50ref)/exp_indu_n_50ref, (exp_indu_s-exp_indu_s_50ref)/exp_indu_s_50ref] ]);

    //    disp( [ [ (di_indusdom_n-di_indusdom_n_20)/di_indusdom_n_20, (di_indusdom_s-di_indusdom_s_20)/di_indusdom_s_20, di_indusdom_n, di_indusdom_s, (di_indusdom_n-di_indusdom_n_50ref)/di_indusdom_n_50ref, (di_indusdom_s-di_indusdom_s_50ref)/di_indusdom_s_50ref];
    //            [ (df_indusdom_n-df_indusdom_n_20)/df_indusdom_n_20, (df_indusdom_s-df_indusdom_s_20)/df_indusdom_s_20, df_indusdom_n, df_indusdom_s, (df_indusdom_n-df_indusdom_n_50ref)/df_indusdom_n_50ref, (df_indusdom_s-df_indusdom_s_50ref)/df_indusdom_s_50ref];
    //            [ (dg_indusdom_n-dg_indusdom_n_20)/dg_indusdom_n_20, (dg_indusdom_s-dg_indusdom_s_20)/dg_indusdom_s_20, dg_indusdom_n, dg_indusdom_s, (dg_indusdom_n-dg_indusdom_n_50ref)/dg_indusdom_n_50ref, (dg_indusdom_s-dg_indusdom_s_50ref)/dg_indusdom_s_50ref];
    //            [ (ci_indusdom_n-ci_indusdom_n_20)/ci_indusdom_n_20, (ci_indusdom_s-ci_indusdom_s_20)/ci_indusdom_s_20, ci_indusdom_n, ci_indusdom_s, (ci_indusdom_n-ci_indusdom_n_50ref)/ci_indusdom_n_50ref, (ci_indusdom_s-ci_indusdom_s_50ref)/ci_indusdom_s_50ref];
    //            [ (exp_indu_n-exp_indu_n_20)/exp_indu_n_20, (exp_indu_s-exp_indu_s_20)/exp_indu_s_20, exp_indu_n, exp_indu_s, (exp_indu_n-exp_indu_n_50ref)/exp_indu_n_50ref, (exp_indu_s-exp_indu_s_50ref)/exp_indu_s_50ref] ]);

    disp( [ [ (di_indusdom_n-di_indusdom_n_20)/di_indusdom_n_20, (di_indusdom_s-di_indusdom_s_20)/di_indusdom_s_20, (di_indusdom_n-di_indusdom_n_20+di_indusdom_s-di_indusdom_s_20)/(di_indusdom_n_20+di_indusdom_s_20)];
    [ (df_indusdom_n-df_indusdom_n_20)/df_indusdom_n_20, (df_indusdom_s-df_indusdom_s_20)/df_indusdom_s_20, (df_indusdom_n-df_indusdom_n_20+df_indusdom_s-df_indusdom_s_20)/(df_indusdom_n_20+df_indusdom_s_20)];
    [ (dg_indusdom_n-dg_indusdom_n_20)/dg_indusdom_n_20, (dg_indusdom_s-dg_indusdom_s_20)/dg_indusdom_s_20, (dg_indusdom_n-dg_indusdom_n_20+dg_indusdom_s-dg_indusdom_s_20)/(dg_indusdom_n_20+dg_indusdom_s_20)];
    [ (ci_indusdom_n-ci_indusdom_n_20)/ci_indusdom_n_20, (ci_indusdom_s-ci_indusdom_s_20)/ci_indusdom_s_20, (ci_indusdom_n-ci_indusdom_n_20+ci_indusdom_s-ci_indusdom_s_20)/(ci_indusdom_n_20+ci_indusdom_s_20)];
    [ (exp_indu_n-exp_indu_n_20)/exp_indu_n_20, (exp_indu_s-exp_indu_s_20)/exp_indu_s_20, (exp_indu_n-exp_indu_n_20+exp_indu_s-exp_indu_s_20)/(exp_indu_n_20+exp_indu_s_20)]  ]);
 

    disp(" DI DF DG CI, Exp, Imp, Q -> dom 2020")

    disp( [ [ di_indusdom_n_20, di_indusdom_s_20];
    [ df_indusdom_n_20, df_indusdom_s_20];
    [ dg_indusdom_n_20, dg_indusdom_s_20];
    [ ci_indusdom_n_20, ci_indusdom_s_20];
    [ exp_indu_n_20, exp_indu_s_20];
    [ imp_indu_n_20, imp_indu_s_20];
    [q_indus_n_20, q_indus_s_20] ]);

    disp(" DI DF DG CI, Exp, Imp, Q -> dom 2050")

    disp( [ [ di_indusdom_n, di_indusdom_s];
    [ df_indusdom_n, df_indusdom_s];
    [ dg_indusdom_n, dg_indusdom_s];
    [ ci_indusdom_n, ci_indusdom_s];
    [ exp_indu_n, exp_indu_s];
    [ imp_indu_n, imp_indu_s];
    [q_indus_n, q_indus_s]       ]);

    disp(" DI DF DG CI, Exp, Imp, Q -> tot 2020")


    disp( [ [ di_indus_2020_n, di_indus_2020_s];
    [ df_indus_2020_n, df_indus_2020_s];
    [ dg_indus_2020_n, dg_indus_2020_s];
    [ ci_indus_n_20, ci_indus_s_20];
    [ exp_indu_n_20, exp_indu_s_20];
    [ imp_indu_n_20, imp_indu_s_20]; 
    [q_indus_n_20, q_indus_s_20] ]);


    disp(" DI DF DG CI, Exp, Imp, Q -> tot 2050")

    disp( [ [ di_indus_n, di_indus_s];
    [ df_indus_n, df_indus_s];
    [ dg_indus_n, dg_indus_s];
    [ ci_indus_n, ci_indus_s];
    [ exp_indu_n, exp_indu_s];
    [ imp_indu_n, imp_indu_s];
    [q_indus_n, q_indus_s]       ]);

    disp("MAIN  decompos");

    disp( [ [ di_indusdom_n_20, di_indusdom_s_20, di_indusdom_n, di_indusdom_s];
    [nrb_n_20, nrb_s_20, nrb_n, nrb_s];
    [ci_indus_oth_dom_n_20, ci_indus_oth_dom_s_20, ci_indus_oth_dom_n, ci_indus_oth_dom_s];
    [ci_indus_indus_dom_n_20, ci_indus_indus_dom_s_20, ci_indus_indus_dom_n, ci_indus_indus_dom_s];
    [ci_indus_comp_dom_n_20, ci_indus_comp_dom_s_20, ci_indus_comp_dom_n, ci_indus_comp_dom_s];
    [ci_indus_oth_n_20, ci_indus_oth_s_20, ci_indus_oth_n, ci_indus_oth_s];
    [ci_indus_indus_n_20, ci_indus_indus_s_20, ci_indus_indus_n, ci_indus_indus_s];
    [ci_indus_comp_n_20, ci_indus_comp_s_20, ci_indus_comp_n, ci_indus_comp_s];
    [q_indus_n_20, q_indus_s_20, q_indus_n, q_indus_s] ;
    [q_comp_n_20, q_comp_s_20, q_comp_n, q_comp_s] ;
    [ di_indusdom_n_20, di_indusdom_s_20, di_indusdom_n, di_indusdom_s]
    [ df_indusdom_n_20, df_indusdom_s_20, df_indusdom_n, df_indusdom_s];
    [ dg_indusdom_n_20, dg_indusdom_s_20, dg_indusdom_n, dg_indusdom_s];
    [ ci_indusdom_n_20, ci_indusdom_s_20, ci_indusdom_n, ci_indusdom_s];
    [ exp_indu_n_20, exp_indu_s_20, exp_indu_n, exp_indu_s];
    [ imp_indu_n_20, imp_indu_s_20, imp_indu_n, imp_indu_s];
    [q_indus_n_20, q_indus_s_20, q_indus_n, q_indus_s] ]);


    disp("MAIN  decompos - gdp");

    disp( [ [ di_indusdom_n_20, di_indusdom_s_20, di_indusdom_n, di_indusdom_s];
    [nrb_n_20, nrb_s_20, nrb_n, nrb_s];
    [ci_indus_oth_dom_n_20, ci_indus_oth_dom_s_20, ci_indus_oth_dom_n, ci_indus_oth_dom_s];
    [ci_indus_indus_dom_n_20, ci_indus_indus_dom_s_20, ci_indus_indus_dom_n, ci_indus_indus_dom_s];
    [ci_indus_comp_dom_n_20, ci_indus_comp_dom_s_20, ci_indus_comp_dom_n, ci_indus_comp_dom_s];
    [ci_indus_oth_n_20, ci_indus_oth_s_20, ci_indus_oth_n, ci_indus_oth_s];
    [ci_indus_indus_n_20, ci_indus_indus_s_20, ci_indus_indus_n, ci_indus_indus_s];
    [ci_indus_comp_n_20, ci_indus_comp_s_20, ci_indus_comp_n, ci_indus_comp_s];
    [q_indus_n_20, q_indus_s_20, q_indus_n, q_indus_s] ;
    [q_comp_n_20, q_comp_s_20, q_comp_n, q_comp_s] ;
    [ di_indusdom_n_20, di_indusdom_s_20, di_indusdom_n, di_indusdom_s]
    [ df_indusdom_n_20, df_indusdom_s_20, df_indusdom_n, df_indusdom_s];
    [ dg_indusdom_n_20, dg_indusdom_s_20, dg_indusdom_n, dg_indusdom_s];
    [ ci_indusdom_n_20, ci_indusdom_s_20, ci_indusdom_n, ci_indusdom_s];
    [ exp_indu_n_20, exp_indu_s_20, exp_indu_n, exp_indu_s];
    [ imp_indu_n_20, imp_indu_s_20, imp_indu_n, imp_indu_s];
    [q_indus_n_20, q_indus_s_20, q_indus_n, q_indus_s];
    [gdp_evol_n, gdp_evol_s, gdp_evol_n, gdp_evol_s]]);



    disp( "Demand on CI (mistake 2050 ref): 0.3055 (too high means we reduce too much demand relatively to CI)")
    disp( [  (di_indusdom_n-di_indusdom_n_50ref+df_indusdom_n-df_indusdom_n_50ref+dg_indusdom_n-dg_indusdom_n_50ref) / (di_indusdom_n_50ref+df_indusdom_n_50ref+dg_indusdom_n_50ref) * (ci_indusdom_n_50ref) / (ci_indusdom_n-ci_indusdom_n_50ref),  (di_indusdom_s-di_indusdom_s_50ref+df_indusdom_s-df_indusdom_s_50ref+dg_indusdom_s-dg_indusdom_s_50ref) / (di_indusdom_s_50ref+df_indusdom_s_50ref+dg_indusdom_s_50ref) * ci_indusdom_s_50ref /  (ci_indusdom_s-ci_indusdom_s_50ref) ])

    disp( "Demand on CI ( / 2020): 0.3055 (too high means we reduce too much demand relatively to CI)")
    disp( [  (di_indusdom_n-di_indusdom_n_20+df_indusdom_n-df_indusdom_n_20+dg_indusdom_n-dg_indusdom_n_20) / (di_indusdom_n_20+df_indusdom_n_20+dg_indusdom_n_20) * (ci_indusdom_n_20) / (ci_indusdom_n-ci_indusdom_n_20),  (di_indusdom_s-di_indusdom_s_20+df_indusdom_s-df_indusdom_s_20+dg_indusdom_s-dg_indusdom_s_20) / (di_indusdom_s_20+df_indusdom_s_20+dg_indusdom_s_20) * ci_indusdom_s_20 /  (ci_indusdom_s-ci_indusdom_s_20) ])

    disp( "Demand with exports on CI: 0.3055 (too high means we reduce too much demand relatively to CI)")
    disp( [  (di_indusdom_n-di_indusdom_n_20+df_indusdom_n-df_indusdom_n_20+dg_indusdom_n-dg_indusdom_n_20+exp_indu_n-exp_indu_n_20) / (exp_indu_n_20+di_indusdom_n_20+df_indusdom_n_20+dg_indusdom_n_20) * (ci_indusdom_n_20) / (ci_indusdom_n-ci_indusdom_n_20),  (di_indusdom_s-di_indusdom_s_20+df_indusdom_s-df_indusdom_s_20+dg_indusdom_s-dg_indusdom_s_20+exp_indu_s-exp_indu_s_20) / (exp_indu_s_20+di_indusdom_s_20+df_indusdom_s_20+dg_indusdom_s_20) * ci_indusdom_s_20 /  (ci_indusdom_s-ci_indusdom_s_20) ])

    disp( "Demand with exports on CI, GLOBAL: 0.3055 (too high means we reduce too much demand relatively to CI)")
    //disp( [  (di_indusdom_s-di_indusdom_s_20+df_indusdom_s-df_indusdom_s_20+dg_indusdom_s-dg_indusdom_s_20+exp_indu_s-exp_indu_s_20+di_indusdom_n-di_indusdom_n_20+df_indusdom_n-df_indusdom_n_20+dg_indusdom_n-dg_indusdom_n_20+exp_indu_n-exp_indu_n_20) / (exp_indu_s_20+di_indusdom_s_20+df_indusdom_s_20+dg_indusdom_s_20+exp_indu_n_20+di_indusdom_n_20+df_indusdom_n_20+dg_indusdom_n_20) * (ci_indusdom_s_20+ci_indusdom_n_20) / (ci_indusdom_s-ci_indusdom_s_20+ci_indusdom_n-ci_indusdom_n_20) ])
    disp( [  (di_indusdom_s-di_indusdom_s_20+df_indusdom_s-df_indusdom_s_20+dg_indusdom_s-dg_indusdom_s_20+di_indusdom_n-di_indusdom_n_20+df_indusdom_n-df_indusdom_n_20+dg_indusdom_n-dg_indusdom_n_20+di_indusimp_s-di_indusimp_s_20+df_indusimp_s-df_indusimp_s_20+dg_indusimp_s-dg_indusimp_s_20+di_indusimp_n-di_indusimp_n_20+df_indusimp_n-df_indusimp_n_20+dg_indusimp_n-dg_indusimp_n_20) / (di_indusdom_s_20+df_indusdom_s_20+dg_indusdom_s_20+di_indusdom_n_20+df_indusdom_n_20+dg_indusdom_n_20 + di_indusimp_s_20+df_indusimp_s_20+dg_indusimp_s_20+di_indusimp_n_20+df_indusimp_n_20+dg_indusimp_n_20) * (ci_indusdom_s_20+ci_indusdom_n_20 + ci_indusimp_s_20+ci_indusimp_n_20) / (ci_indusdom_s-ci_indusdom_s_20+ci_indusdom_n-ci_indusdom_n_20 + ci_indusimp_s-ci_indusimp_s_20+ci_indusimp_n-ci_indusimp_n_20) ])


    disp( "Other things")

    disp( [ (exp_indu_n-exp_indu_n_20 + dg_indusdom_n-dg_indusdom_n_20 + df_indusdom_n-df_indusdom_n_20  +di_indusdom_n-di_indusdom_n_20) ./ (exp_indu_n-exp_indu_n_20 + dg_indusdom_n-dg_indusdom_n_20 + df_indusdom_n-df_indusdom_n_20  +di_indusdom_n-di_indusdom_n_20 + ci_indusdom_n-ci_indusdom_n_20),  (exp_indu_s-exp_indu_s_20 + dg_indusdom_s-dg_indusdom_s_20 + df_indusdom_s-df_indusdom_s_20  +di_indusdom_s-di_indusdom_s_20) ./ (exp_indu_s-exp_indu_s_20 + dg_indusdom_s-dg_indusdom_s_20 + df_indusdom_s-df_indusdom_s_20  +di_indusdom_s-di_indusdom_s_20 + ci_indusdom_s-ci_indusdom_s_20) ]);
    disp( [ ( dg_indusdom_n-dg_indusdom_n_20 + df_indusdom_n-df_indusdom_n_20  +di_indusdom_n-di_indusdom_n_20) ./ ( dg_indusdom_n-dg_indusdom_n_20 + df_indusdom_n-df_indusdom_n_20  +di_indusdom_n-di_indusdom_n_20 + ci_indusdom_n-ci_indusdom_n_20),  ( dg_indusdom_s-dg_indusdom_s_20 + df_indusdom_s-df_indusdom_s_20  +di_indusdom_s-di_indusdom_s_20) ./ ( dg_indusdom_s-dg_indusdom_s_20 + df_indusdom_s-df_indusdom_s_20  +di_indusdom_s-di_indusdom_s_20 + ci_indusdom_s-ci_indusdom_s_20) ]);

    disp( "[ener_indus_n_2050, ener_indus_s_2050]");
    disp( [ [ener_indus_n_2050, ener_indus_s_2050]; [ener_indus_n_2050_obj, ener_indus_s_2050_obj]; [ener_indus_n_2050/ener_indus_n_2050_obj, ener_indus_s_2050/ener_indus_s_2050_obj]]);

    disp( "[m2batiment_n, m2batiment_s, ener_resid_n, ener_resid_s]")
    disp( [ [m2batiment_n, m2batiment_s, ener_resid_n, ener_resid_s], [m2_resid_n_2050_obj, m2_resid_s_2050_obj, ener_resid_n_2050_obj, ener_resid_s_2050_obj],  [m2batiment_n / m2_resid_n_2050_obj, m2batiment_s/m2_resid_s_2050_obj, ener_resid_n/ener_resid_n_2050_obj, ener_resid_s/ener_resid_s_2050_obj]]);

    gdp_ssp2_2050 = 253137.334642 * 1e3 * CPI_2017_to_2014;
    gdp_ssp2_2060 = 311753.1826 * 1e3 * CPI_2017_to_2014;

    if current_time_im==2050-base_year_simulation
        disp( [sum(GDP_PPP_constant),gdp_ssp2_2050], 'GDP')
    end
    if current_time_im==2060-base_year_simulation
        disp( [sum(GDP_PPP_constant),gdp_ssp2_2060], 'GDP')
    end

    disp("***************************************************")
    disp("   Print for the table of the paper")

    m2batiment_n_50=m2batiment_n;
    m2batiment_s_50=m2batiment_s;
    ener_int_m2_n_50=ener_resid_n/m2batiment_n;
    ener_int_m2_s_50=ener_resid_s/m2batiment_s;
    ener_int_m2_w_50=(ener_resid_n+ener_resid_s)/(m2batiment_n+m2batiment_s);

    disp("m2batiment_n_50/m2batiment_n_20", m2batiment_n_50/m2batiment_n_20*100-100);
    disp("m2batiment_s_50/m2batiment_s_20", m2batiment_s_50/m2batiment_s_20*100-100);
    disp("m2batiment_w_50/m2batiment_w_20", (m2batiment_s_50+m2batiment_n_50)/(m2batiment_s_20+m2batiment_n_20)*100-100);

    disp("ener_int_m2_n_50/ener_int_m2_n_50", ener_int_m2_n_50/ener_int_m2_n_20*100-100)
    disp("ener_int_m2_s_50/ener_int_m2_s_50", ener_int_m2_s_50/ener_int_m2_s_20*100-100)
    disp("ener_int_m2_w_50/ener_int_m2_w_50", ener_int_m2_w_50/ener_int_m2_w_20*100-100)

    disp("m2batiment_n_50", m2batiment_n_50)
    disp("m2batiment_s_50", m2batiment_s_50)
    disp("m2batiment_w_50", m2batiment_s_50+m2batiment_n_50)

    pkm_ot_n_50=pkm_ot_n;
    pkm_air_n_50=pkm_air_n;
    pkm_car_n_50=pkm_car_n;

    pkm_ot_s_50=pkm_ot_s;
    pkm_air_s_50=pkm_air_s;
    pkm_car_s_50=pkm_car_s;

    ener_pkm_ot_n_50 = sum(ener_tot_ot(ind_global_north)) / pkm_ot_n;
    ener_pkm_air_n_50 = sum(ener_pkm_air(ind_global_north)) / pkm_air_n;
    ener_pkm_car_n_50 = sum(ener_pkm_car(ind_global_north)) / pkm_car_n;
    ener_ot_tot_n_50 = sum(ener_tot_ot(ind_global_north));

    ener_pkm_ot_s_50 = sum(ener_tot_ot(ind_global_south)) / pkm_ot_s;
    ener_pkm_air_s_50 = sum(ener_pkm_air(ind_global_south)) / pkm_air_s;
    ener_pkm_car_s_50 = sum(ener_pkm_car(ind_global_south)) / pkm_car_s;
    ener_ot_tot_s_50 = sum(ener_tot_ot(ind_global_south));

    ener_pkm_air_w_50 = (sum(ener_pkm_air(ind_global_south))+sum(ener_tot_ot(ind_global_north))) / (pkm_air_s+pkm_air_n);
    ener_pkm_car_w_50 = ( sum(ener_pkm_car(ind_global_north)) +sum(ener_pkm_car(ind_global_south)) ) / (pkm_car_s+pkm_car_n);

    disp("pkm_car_n_50/pkm_car_n_20",pkm_car_n_50/pkm_car_n_20*100-100 );
    disp("pkm_car_s_50/pkm_car_s_20",pkm_car_s_50/pkm_car_s_20*100-100 );
    disp("pkm_car_w_50/pkm_car_w_20",(pkm_car_s_50+pkm_car_n_50)/(pkm_car_n_20+pkm_car_s_20)*100-100 );

    disp("pkm_air_n_50/pkm_air_n_20",pkm_air_n_50/pkm_air_n_20 *100-100);
    disp("pkm_air_s_50/pkm_air_s_20",pkm_air_s_50/pkm_air_s_20*100-100 );
    disp("pkm_air_w_50/pkm_air_w_20",(pkm_air_s_50+pkm_air_n_50)/(pkm_air_n_20+pkm_air_s_20)*100-100 );
	
    disp("pkm_ot_n_50/pkm_ot_n_20",pkm_ot_n_50/pkm_ot_n_20 *100-100);
    disp("pkm_ot_s_50/pkm_ot_s_20",pkm_ot_s_50/pkm_ot_s_20*100-100 );
    disp("pkm_ot_w_50/pkm_ot_w_20",(pkm_ot_s_50+pkm_ot_n_50)/(pkm_ot_n_20+pkm_ot_s_20)*100-100 );

    disp("ener_pkm_car_n_50/ener_pkm_car_n_20",ener_pkm_car_n_50/ener_pkm_car_n_20*100-100);
    disp("ener_pkm_car_s_50/ener_pkm_car_s_20",ener_pkm_car_s_50/ener_pkm_car_s_20*100-100);
    disp("ener_pkm_car_w_50/ener_pkm_car_w_20",ener_pkm_car_w_50/ener_pkm_car_w_20*100-100);

    disp("ener_pkm_air_n_50/ener_pkm_air_n_20",ener_pkm_air_n_50/ener_pkm_air_n_20*100-100);
    disp("ener_pkm_air_s_50/ener_pkm_air_s_20",ener_pkm_air_s_50/ener_pkm_air_s_20*100-100);
    disp("ener_pkm_air_w_50/ener_pkm_air_w_20",ener_pkm_air_w_50/ener_pkm_air_w_20*100-100);

    disp("pkm_car_n_50", pkm_car_n_50)
    disp("pkm_car_s_50", pkm_car_s_50)
    disp("pkm_car_w_50", pkm_car_n_50+pkm_car_s_50)

    disp("pkm_air_n_50", pkm_air_n_50)
    disp("pkm_air_s_50", pkm_air_s_50)
    disp("pkm_air_w_50", pkm_air_n_50+pkm_air_s_50)

    disp("pkm_ot_n_50", pkm_ot_n_50)
    disp("pkm_ot_s_50", pkm_ot_s_50)
    disp("pkm_ot_w_50", pkm_ot_n_50+pkm_ot_s_50)

    activity_ot_n_50 = sum(Q(ind_global_north,indice_OT)-DF(ind_global_north,indice_OT));
    activity_ot_s_50 = sum(Q(ind_global_south,indice_OT)-DF(ind_global_south,indice_OT));

    ener_int_ot_n_50 = ener_ot_tot_n_50 /activity_ot_n_50 ;
    ener_int_ot_s_50 = ener_ot_tot_s_50 /activity_ot_s_50 ;
    ener_int_ot_w_50 = (ener_ot_tot_s_50+ener_ot_tot_n_50) / (activity_ot_s_50+activity_ot_n_50) ;

    disp("activity_ot_n_50/activity_ot_n_20", activity_ot_n_50/activity_ot_n_20*100-100)
    disp("activity_ot_s_50/activity_ot_s_20", activity_ot_s_50/activity_ot_s_20*100-100)
    disp("activity_ot_w_50/activity_ot_w_20", (activity_ot_n_50+activity_ot_s_50)/ (activity_ot_s_20+activity_ot_n_20)*100-100)

    disp("ener_int_ot_n_50/ener_int_ot_n_20", ener_int_ot_n_50/ener_int_ot_n_20*100-100)
    disp("ener_int_ot_s_50/ener_int_ot_s_20", ener_int_ot_s_50/ener_int_ot_s_20*100-100)
    disp("ener_int_ot_w_50/ener_int_ot_w_20", ener_int_ot_w_50/ener_int_ot_w_20*100-100)

    ener_indus_n_50 = sum( ener_indus(ind_global_north));
    ener_indus_s_50 = sum( ener_indus(ind_global_south));

    ener_int_indus_n_50 = q_indus_n / ener_indus_n_50;
    ener_int_indus_s_50 = q_indus_s / ener_indus_s_50; 
    ener_int_indus_w_50 = (q_indus_s+q_indus_n) / (ener_indus_s_50+ener_indus_n_50); 

    q_indus_n_50=q_indus_n;
    q_indus_s_50=q_indus_s;

    disp("q_indus_n_50/q_indus_n_20", q_indus_n_50/q_indus_n_20*100-100)
    disp("q_indus_s_50/q_indus_s_20", q_indus_s_50/q_indus_s_20*100-100)
    disp("q_indus_w_50/q_indus_w_20", (q_indus_n_50+q_indus_s_50)/(q_indus_n_20+q_indus_s_20)*100-100)

    disp("ener_int_indus_n_50/ener_int_indus_n_20", ener_int_indus_n_50/ener_int_indus_n_20*100-100)
    disp("ener_int_indus_s_50/ener_int_indus_s_20", ener_int_indus_s_50/ener_int_indus_s_20*100-100)
    disp("ener_int_indus_w_50/ener_int_indus_w_20", ener_int_indus_w_50/ener_int_indus_w_20*100-100)

    q_comp_n_50 = sum(Q(ind_global_north,compo));
    q_comp_s_50 = sum(Q(ind_global_south,compo));

    ener_comp_n_50 = fe_comp_n;
    ener_comp_s_50 = fe_comp_s;

    ener_unit_comp_n_50 = q_comp_n_50/fe_comp_n;
    ener_unit_comp_s_50 = q_comp_s_50/fe_comp_s;
    ener_unit_comp_w_50 = (q_comp_s_50+q_comp_n_50)/(fe_comp_s+fe_comp_n);

    disp("q_comp_n_50/q_comp_n_20", q_comp_n_50/q_comp_n_20*100-100)
    disp("q_comp_s_50/q_comp_s_20", q_comp_s_50/q_comp_s_20*100-100)
    disp("q_comp_w_50/q_comp_w_20", (q_comp_n_50+q_comp_s_50)/(q_comp_n_20+q_comp_s_20)*100-100)

    disp("ener_unit_comp_n_50/ener_unit_comp_n_20", ener_unit_comp_n_50/ener_unit_comp_n_20*100-100)
    disp("ener_unit_comp_s_50/ener_unit_comp_s_20", ener_unit_comp_s_50/ener_unit_comp_s_20*100-100)
    disp("ener_unit_comp_w_50/ener_unit_comp_w_20", ener_unit_comp_w_50/ener_unit_comp_w_20*100-100)


    ener_fret_air_n_50 = sum(ener_fret_air(ind_global_north));
    ener_fret_air_s_50 = sum(ener_fret_air(ind_global_south));

    disp("ener_fret_air_n_50",ener_fret_air_n_50)	
    disp("ener_fret_air_s_50",ener_fret_air_s_50)	

    fe_ship_n_50 = fe_ship_n;
    fe_ship_s_50 = fe_ship_s;

    fe_ship_n_50 = fe_ship_n;
    fe_ship_s_50 = fe_ship_s;

    disp("fe_ship_n_50",fe_ship_n_50)
    disp("fe_ship_s_50",fe_ship_s_50)

    activity_fret_air_n_50 = sum(Q(ind_global_north,indice_air)-DF(ind_global_north,indice_air));
    activity_fret_air_s_50 = sum(Q(ind_global_south,indice_air)-DF(ind_global_south,indice_air));

    ener_f_int_air_n_50 = activity_fret_air_n_50 / ener_fret_air_n_50;
    ener_f_int_air_s_50 = activity_fret_air_s_50 / ener_fret_air_s_50;
    ener_f_int_air_w_50 = (activity_fret_air_s_50+activity_fret_air_n_50) / (ener_fret_air_s_50+ener_fret_air_n_50);

    disp("activity_fret_air_n_50/activity_fret_air_n_20",activity_fret_air_n_50/activity_fret_air_n_20*100-100) 
    disp("activity_fret_air_s_50/activity_fret_air_s_20",activity_fret_air_s_50/activity_fret_air_s_20*100-100) 
    disp("activity_fret_air_s_50/activity_fret_air_s_20", (activity_fret_air_n_50+activity_fret_air_s_50)/(activity_fret_air_n_20+activity_fret_air_s_20)*100-100) 

    disp("ener_f_int_air_n_50/ener_f_int_air_n_20", ener_f_int_air_n_50/ener_f_int_air_n_20*100-100)
    disp("ener_f_int_air_s_50/ener_f_int_air_s_20", ener_f_int_air_s_50/ener_f_int_air_s_20*100-100)
    disp("ener_f_int_air_w_50/ener_f_int_air_w_20", ener_f_int_air_w_50/ener_f_int_air_w_20*100-100)

    activity_fret_mer_n_50 = sum(Q(ind_global_north,indice_mer));
    activity_fret_mer_s_50 = sum(Q(ind_global_south,indice_mer));

    ener_f_int_mer_n_50 = activity_fret_mer_n_50 / fe_ship_n_50;
    ener_f_int_mer_s_50 = activity_fret_mer_s_50 / fe_ship_s_50;
    ener_f_int_mer_w_50 = (activity_fret_mer_s_50+activity_fret_mer_n_50) / (fe_ship_s_50+fe_ship_n_50);

    disp("activity_fret_mer_n_50/activity_fret_mer_n_20",activity_fret_mer_n_50/activity_fret_mer_n_20*100-100)
    disp("activity_fret_mer_s_50/activity_fret_mer_s_20",activity_fret_mer_s_50/activity_fret_mer_s_20*100-100)
    disp("activity_fret_mer_s_50/activity_fret_mer_s_20", (activity_fret_mer_n_50+activity_fret_mer_s_50)/(activity_fret_mer_n_20+activity_fret_mer_s_20)*100-100)

    disp("ener_f_int_mer_n_50/ener_f_int_mer_n_20", ener_f_int_mer_n_50/ener_f_int_mer_n_20*100-100)
    disp("ener_f_int_mer_s_50/ener_f_int_mer_s_20", ener_f_int_mer_s_50/ener_f_int_mer_s_20*100-100)
    disp("ener_f_int_mer_w_50/ener_f_int_mer_w_20", ener_f_int_mer_w_50/ener_f_int_mer_w_20*100-100)

    disp("fe_tot_n", fe_tot_n)
    disp("fe_tot_s", fe_tot_s)

end

//pkm_tot = (Tair + Tautomobile + TOT + TNM) .* pkmautomobileref / 100  ;
//pkm_cap_n = sum(pkm_tot( ind_global_north)) ./ sum( Ltot(ind_global_north));
//pkm_cap_s = sum(pkm_tot( ind_global_south)) ./ sum( Ltot(ind_global_south));
//pkm_cap_g = sum(pkm_tot) ./ sum( Ltot);
//if i==19
//    disp( [ [pkm_cap_n, pkm_cap_s, pkm_cap_g]; [13605, 5348, 6937]; [pkm_cap_n/13605, pkm_cap_s/5348, pkm_cap_g/6937]]); 
//end

//aw = aw .*wref./w .*pind./pindref;
//bw = bw .*wref./w .*pind./pindref;
//aw = aw .*pind./pindref;
//bw = bw .*pind./pindref;
//wref=w;
//pindref=pind;


str_head="''model|combi|variable|region|sector|year|value''";
filename = "output_low_demand_scenarios.csv";

modelcombi = "Imaclim-R 1.1|" + string(combi)+ "|"

if current_time_im==1
    unix_s("echo " + str_head + " > " + SAVEDIR + filename)
end

// Value Added
str_val = '';
for k=1:12
    for j=1:12	
        str_val = "''" + modelcombi + "VA|" + regnames(k) + '|' + secnames(j) + '|' + string(2014+current_time_im) + '|' + GDP_sect(k,j) + "''";
        unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
    end
end

// GDP deflator
str_val = '';
for k=1:12
    str_val = "''" + modelcombi + "GDP_deflator|" + regnames(k) + '|nan|' + string(2014+current_time_im) + '|' + GDP_MER_real(k)/GDP_MER_nominal(k) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end


// GDP_PPP_real
str_val = '';
for k=1:12
    str_val = "''" + modelcombi + "GDP_PPP_constant|" + regnames(k) + '|nan|' + string(2014+current_time_im) + '|' + GDP_PPP_constant(k) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end


// GDP_MER_nominal
str_val = '';
for k=1:12
    str_val = "''" + modelcombi + "GDP_MER_nominal|" + regnames(k) + '|nan|' + string(2014+current_time_im) + '|' + GDP_MER_nominal(k) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end

// Population
str_val = '';
for k=1:12
    str_val = "''" + modelcombi + "Population|" + regnames(k) + '|nan|' + string(2014+current_time_im) + '|' + Ltot(k) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end

// Q indus decomposition
str_val = '';
for k=1:12
    str_val = "''" + modelcombi + "Q industry - total|" + regnames(k) + '|nan|' + string(2014+current_time_im) + '|' + Q(k,indus) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end

str_val = '';
for k=1:12
    str_val = "''" + modelcombi + "Q industry - DFDG|" + regnames(k) + '|nan|' + string(2014+current_time_im) + '|' + string(DF(k,indus)*partDomDF(k,indus) + DG(k,indus)*partDomDG(k,indus)) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end

str_val = '';
for k=1:12
    str_val = "''" + modelcombi + "Q industry - Exp|" + regnames(k) + '|nan|' + string(2014+current_time_im) + '|' + Exp(k,indus) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end

str_val = '';
for k=1:12
    str_val = "''" + modelcombi + "Q industry - Inv_val indus|" + regnames(k) + '|nan|' + string(2014+current_time_im) + '|' + Inv_val_sec(k,indus) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end

str_val = '';
for k=1:12
    str_val = "''" + modelcombi + "Q industry - Inv_val comp|" + regnames(k) + '|nan|' + string(2014+current_time_im) + '|' + Inv_val_sec(k,compo) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end


str_val = '';
for k=1:12
    str_val = "''" + modelcombi + "Q industry - Inv_val other|" + regnames(k) + '|nan|' + string(2014+current_time_im) + '|' + sum(Inv_val_sec(k,[1 2 3 4 5 6 8 9 10 11])) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end


str_val = '';
for k=1:12
    str_val = "''" + modelcombi + "Q industry - Inv_val DIinfra|" + regnames(k) + '|nan|' + string(2014+current_time_im) + '|' + sum( DI(k,:).*pArmDI(k,:)*partDomDI(k,indus)) +  "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end

str_val = '';
for k=1:12
    str_val = "''" + modelcombi + "Q industry - DI indus|" + regnames(k) + '|nan|' + string(2014+current_time_im) + '|' + string(DI(k,indus)*partDomDI(k,indus)-DIinfra(k,indus)*partDomDI(k,indus)) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end

str_val = '';
for k=1:12
    str_val = "''" + modelcombi + "Q industry - CI|" + regnames(k) + '|nan|' + string(2014+current_time_im) + '|' + ci_indus_reg(k) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end

//employ = Q .* l;
// emploie
//        str_val = '';
//        for k=1:12
//                for j=1:12
//                        str_val = "''" + modelcombi + "employ|" + regnames(k) + '|' + secnames(j) + '|' + string(2014+current_time_im) + '|' + employ(k,j) + "''";
//                        unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
//                end
//        end

// Final energy

str_val = '';
for j=1:15
    str_val = "''" + modelcombi + "Final Energy,"+ fe_detail_label(j)+'|WLD|nan|' + string(2014+current_time_im) + '|' + fe_detail(j) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end

activity_matrix = zeros(16,3);

activity_matrix(:,1:2)= [[pkm_ot_n, pkm_ot_s];
[pkm_air_n, pkm_air_s];
[pkm_car_n, pkm_car_s];
[m2batiment_n, m2batiment_s];
[q_comp_n, q_comp_s];
[sum(Q(ind_global_north, agri)), sum(Q(ind_global_south, agri))];
[sum(Q(ind_global_north, btp)), sum(Q(ind_global_south, btp))];
[q_indus_n, q_indus_s];
[di_indusdom_n, di_indusdom_s];
[df_indusdom_n, df_indusdom_s];
[dg_indusdom_n, dg_indusdom_s];
[ci_indusdom_n, ci_indusdom_s];
[exp_indu_n, exp_indu_s];
[sum(Q(ind_global_north, mer)), sum(Q(ind_global_south, mer))];
[ci_airdom_n+sum(ExpTI(ind_global_north, air)), ci_airdom_s+sum(ExpTI(ind_global_north, air))];
[sum(ExpTI(ind_global_north, air)), sum(ExpTI(ind_global_north, air))]];
activity_matrix(:,3) = sum( activity_matrix(:,1:2),'c');

activity_labels =[
"Activity - PKM - ot",
"Activity - PKM - air",
"Activity - PKM - car",
"Activity - M2",
"Activity - services",
"Activity - agri",
"Activity - construction",
"Activity - industries",
"Activity - industries - DI",
"Activity - industries - DF",
"Activity - industries - DG",
"Activity - industries - CI",
"Activity - industries - Exp",
"Activity - Shipping",
"Activity - Air- Freight",
"Activity - Air- Freight Int."];

str_val = '';
for j=1:16
    str_val = "''" + modelcombi + "Activity,"+ activity_labels(j)+'|North|nan|' + string(2014+current_time_im) + '|' + activity_matrix(j,1) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
    str_val = "''" + modelcombi + "Activity,"+ activity_labels(j)+'|South|nan|' + string(2014+current_time_im) + '|' + activity_matrix(j,2) + "''";
    unix_s("echo " + str_val + " >> " + SAVEDIR + filename)
end

// PCO2
//	str_val = '';
//	str_val = "''" + modelcombi + "Price Carbon|WLD|nan|" + string(2014+current_time_im) + '|' + taxCO2_DF(1)*1e6 + "''";
//        unix_s("echo " + str_val + " >> " + SAVEDIR + filename)

