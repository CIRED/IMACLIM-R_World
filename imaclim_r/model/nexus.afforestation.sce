
// To be in NLU in update_forcing ?
surfforest_par = distrib_forest_prev .* ( distrib_forest_scaling' * ones(1,nbpar));

// affo. potential
aff_potential = (max_potential_aff - surfforest_par);
surf_past_max = density_ML_new .* ( dsurfagri' * ones(1,nbpar)) + density_P_new .* ( dsurfagri' * ones(1,nbpar));
surf_past_max( (density_ML_new+density_P_new) < 0.05 * density_agri) = 0;
aff_potential = min( surf_past_max *0.95, aff_potential);
aff_potential(aff_potential<0)=0;

// Linear Expectations on carbon tax increase
txp = taxCO2_CI_prev(1,1,:);
txn = taxCO2_CI(1,1,:);
txp = taxCO2_DF_prev(:,indice_gaz);
txn = taxCO2_DF(:,indice_gaz);
carbon_tax_aff= zeros(reg_taxeC);
for regy=1:nb_regions
    carbon_tax_aff(regy) = max( 2*txn(regy) -txp(regy),txp(regy)) * 1e6 ; // ($/tCO2eq)
end

// economic parameters
Invaff = 1600 * pind; // 2500
OMaff = 65 * (pind * ones(1,100));
act = ones(nb_regions,1);
for ii=1:100; act=[act ones(nb_regions,1) ./1.07^ii];end;
emi=linspace(0,0.17,100) /1e6 * 1e9;
hh=30;
carbon_tax_aff_horizon=( ones(hh,1) *carbon_tax_aff)';

// load emissions
oscar_ready=%f;
while ~oscar_ready
  sleep( 2000);
  if isfile(path_dialog_withOscar+'/oscarfirstIRFdone' )
      oscar_ready=%t // oscar has done the IRF for the first time
  end
end

emi=ones(nb_regions,100);
for ii=1:nb_regions
  filename=path_dialog_withOscar+'/oscar_LUC_gra_for_' + string(ii)+'_dcO2';
  c=csvRead( filename, '|') / 0.47 * 44 / 12 ;
  filename=path_dialog_withOscar+'/oscar_ref_dcO2';
  c0=csvRead( filename, '|') / 0.47 * 44 / 12 ;
  emi(ii,1)= c(1)-c0(1);
  for jj=2:hh
    emi(ii,jj) = c(jj) -c0(jj) - (c(jj-1) -c0(jj-1) );
    emi(ii,jj) = emi(ii,jj) .* albedo_aff_discrim(ii);
  end
end
emi = emi /1e6 * 1e9;

// compute net present value
NPV = (Invaff + sum( act(:,1:hh) .* (OMaff(:,1:hh) + carbon_tax_aff_horizon(:,1:hh) .* emi(:,1:hh)), 'c')) * ones(1,60);
for ii=1:nb_regions
    NPV(ii,:) = NPV(ii,:) + sum((scarcityrent_perha_allc(ii,:)' * ones(1,hh)) .* (ones(60,1)*act(ii,1:hh)),"c")';
end
NPV( scarcityrent_perha_allc==0) = 1e20;

surf_aff_considered = zeros(aff_potential);

where2aff = zeros(1,nb_regions);
for ireg=1:nb_regions
  ind_temp = max(find( -aff_potential(ireg, :) .* NPV(ireg, :) >0));
  if ind_temp == []
     where2aff(ireg) = -1;
  else
     where2aff(ireg) =ind_temp;
  end
end


surf_aff_2allocate = max_aff_peryear;
while sum(surf_aff_2allocate.*where2aff) >0
   for ireg=1:nb_regions
      if where2aff(ireg) * surf_aff_2allocate(ireg) >0
         if (aff_potential(ireg,where2aff(ireg)) > surf_aff_2allocate(ireg)) & surf_aff_2allocate(ireg) <>0
             surf_aff_considered(ireg, where2aff(ireg)) = surf_aff_2allocate(ireg);
             surf_aff_2allocate(ireg) = 0;
         else
             surf_aff_considered(ireg, where2aff(ireg)) = aff_potential(ireg, where2aff(ireg));
             surf_aff_2allocate(ireg) = surf_aff_2allocate(ireg) - aff_potential(ireg, where2aff(ireg));
             aff_potential(ireg, where2aff(ireg)) = 0;
             last_veg_class(ireg) = last_veg_class(ireg) -1 ;
         end
      end
   end
   for ireg=1:nb_regions
     ind_temp = max(find( -aff_potential(ireg, :) .* NPV(ireg, :) >0));
     if ind_temp == []
        where2aff(ireg) = -1;
     else
        where2aff(ireg) =ind_temp;
     end
   end
end

// surf_aff_considered could be temporally set to 0 for bioenergy expectations
// otherwise equal to surf_aff_2_increase
surf_aff_2_increase=surf_aff_considered;
surf_aff_cumulated = surf_aff_cumulated + sum(surf_aff_2_increase,"c");


