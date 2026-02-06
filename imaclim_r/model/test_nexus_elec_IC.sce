// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

LCC_8760_2100=matrix(LCC_8760(:,$),reg,15);
matrix(MSH_8760_elec(:,$),reg,15)
IC_8760_2100=matrix(IC_8760(:,$),reg,15);
var_hom_temp=2*ones(reg,1);
mask_HYD=ones(1,indice_NND);
mask_HYD(indice_HYD)=0;


for k=1:reg
    for j=1:indice_NND
        if j<>indice_HYD then MSH_8760_elec_temp(k,j)=(LCC_8760_2100(k,j)+IC_8760_2100(k,j)).^(-var_hom_temp(k))./sum((((LCC_8760_2100(k,1:indice_NND)+IC_8760_2100(k,:))).^(-var_hom_temp(k)*ones(1,indice_NND))).*mask_HYD); end
    end
end

var_hom_temp=4*ones(reg,1);
mask_HYD=ones(1,indice_NND);
mask_HYD(indice_HYD)=0;


for k=1:reg
    for j=1:indice_NND
        if j<>indice_HYD then MSH_8760_elec_temp(k,j)=(LCC_8760_2100(k,j)+IC_8760_2100(k,j)).^(-var_hom_temp(k))./sum((((LCC_8760_2100(k,1:indice_NND)+IC_8760_2100(k,:))).^(-var_hom_temp(k)*ones(1,indice_NND))).*mask_HYD); end
    end
end

var_hom_temp=5*ones(reg,1);
mask_HYD=ones(1,indice_NND);
mask_HYD(indice_HYD)=0;


for k=1:reg
    for j=1:indice_NND
        if j<>indice_HYD then MSH_8760_elec_temp(k,j)=(LCC_8760_2100(k,j)+IC_8760_2100(k,j)).^(-var_hom_temp(k))./sum((((LCC_8760_2100(k,1:indice_NND)+IC_8760_2100(k,:))).^(-var_hom_temp(k)*ones(1,indice_NND))).*mask_HYD); end
    end
end

var_hom_temp=10*ones(reg,1);
mask_HYD=ones(1,indice_NND);
mask_HYD(indice_HYD)=0;


for k=1:reg
    for j=1:indice_NND
        if j<>indice_HYD then MSH_8760_elec_temp(k,j)=(LCC_8760_2100(k,j)+IC_8760_2100(k,j)).^(-var_hom_temp(k))./sum((((LCC_8760_2100(k,1:indice_NND)+IC_8760_2100(k,:))).^(-var_hom_temp(k)*ones(1,indice_NND))).*mask_HYD); end
    end
end

LCC_6570_2100=matrix(LCC_6570(:,$),reg,15);
matrix(MSH_6570_elec(:,$),reg,15)
IC_6570_2100=matrix(IC_6570(:,$),reg,15);
var_hom_temp=10*ones(reg,1);
mask_HYD=ones(1,indice_NND);
mask_HYD(indice_HYD)=0;

for k=1:reg
    for j=1:indice_NND
        if j<>indice_HYD then MSH_6570_elec_temp(k,j)=(LCC_6570_2100(k,j)+IC_6570_2100(k,j)).^(-var_hom_temp(k))./sum((((LCC_6570_2100(k,1:indice_NND)+IC_6570_2100(k,:))).^(-var_hom_temp(k)*ones(1,indice_NND))).*mask_HYD); end
    end
end



LCC_3650_2100=matrix(LCC_3650(:,$),reg,15);
matrix(MSH_3650_elec(:,$),reg,15)
IC_3650_2100=matrix(IC_3650(:,$),reg,15);
var_hom_temp=10*ones(reg,1);
mask_HYD=ones(1,indice_NND);
mask_HYD(indice_HYD)=0;

for k=1:reg
    for j=1:indice_NND
        if j<>indice_HYD then MSH_3650_elec_temp(k,j)=(LCC_3650_2100(k,j)+IC_3650_2100(k,j)).^(-var_hom_temp(k))./sum((((LCC_3650_2100(k,1:indice_NND)+IC_3650_2100(k,:))).^(-var_hom_temp(k)*ones(1,indice_NND))).*mask_HYD); end
    end
end

sum(Cap_elec_MW_dep,'c')
sum(delta_Cap_elec_MW_1,'c')
sum(Cap_elec_MW_exp_inst,'c')

sum(Cap_elec_MW_dep(:,1:indice_NND).*(ones(reg,1)*mask_HYD),'c')+sum(delta_Cap_elec_MW_1(:,1:indice_NND).*(ones(reg,1)*mask_HYD),'c')
sum(Cap_elec_MW(:,1:indice_NND).*(ones(reg,1)*mask_HYD),'c')+(sum(Cap_elec_MW_exp_inst(:,1:indice_NND).*(ones(reg,1)*mask_HYD),'c')-sum(Cap_elec_MW(:,1:indice_NND).*(ones(reg,1)*mask_HYD),'c'))/nb_year_expect_futur

j=29
CRF=disc_rate_elec(:,:,j)./(1-(1+disc_rate_elec(:,:,j)).^(-Life_time(:,:,j)));
CINV=CRF.*CINV_MW(:,:,j);
LCC_ENR=(CINV(:,indice_NND+1:$)+OM_cost_fixed(:,indice_NND+1:$,j))./(Load_factor_ENR*1000+0.000000001)+OM_cost_var(:,indice_NND+1:$,j)
matrix(LCC_8760(:,j),reg,15)

j=50
CRF=disc_rate_elec(:,:,j)./(1-(1+disc_rate_elec(:,:,j)).^(-Life_time(:,:,j)));
CINV=CRF.*CINV_MW(:,:,j);
LCC_ENR=(CINV(:,indice_NND+1:$)+OM_cost_fixed(:,indice_NND+1:$,j))./(Load_factor_ENR*1000+0.000000001)+OM_cost_var(:,indice_NND+1:$,j);
LCC_ENR(:,3:4)
matrix(LCC_8760(1:120,j),reg,10)
matrix(LCC_6570(1:120,j),reg,10)
