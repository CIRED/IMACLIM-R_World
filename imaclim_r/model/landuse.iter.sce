// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// overwrite the end of update_forcings.sce for forest surfaces
if ind_aff >=1 //& current_time >= 19
  forest_change = surf_aff;
  surfforest_par = distrib_forest_prev .* (distrib_forest_scaling' * ones(1,nbpar));

  for index_region=1:reg
      distrib_forest_change(index_region,:)= surf_aff(index_region,:) ./ distrib_forest_scaling(index_region);
  end

  for index_region=1:reg
    if forest_change(index_region)<0 
      //Land-use change shared equally between P,ML and veg
      dens_LUC_share_ML(index_region,:)=ones(1,nbpar);
      dens_LUC_share_P(index_region,:)=ones(1,nbpar);
      dens_LUC_share_veg(index_region,:)=ones(1,nbpar);
      dens_LUC_share_otCrops(index_region,:)=ones(1,nbpar);
      dens_LUC_share_lcbio(index_region,:)=ones(1,nbpar);
    else
      //Land-use change shared equally between P and ML
      dens_LUC_share_veg(index_region,:)=ones(1,nbpar)./(ones(1,nbpar)+ surf_aff(index_region,:)./densityagri_scal_prev(index_region,:).*((1 ./surf_total_agri_prev(index_region)).*ones(1,nbpar)));
      dens_LUC_share_otCrops(index_region,:)=ones(1,nbpar)./(ones(1,nbpar)+surf_aff(index_region,:)./densityagri_scal_prev(index_region,:).*(( 1 ./surf_total_agri_prev(index_region)).*ones(1,nbpar)));
      dens_LUC_share_lcbio(index_region,:)=ones(1,nbpar)./(ones(1,nbpar)+surf_aff(index_region,:)./densityagri_scal_prev(index_region,:).*(( 1 ./surf_total_agri_prev(index_region)).*ones(1,nbpar)));
      dens_LUC_share_ML(index_region,:)=(ones(1,nbpar)+surf_aff(index_region,:)./distrib_past_scaling(index_region,:).*(( 1 ./surf_total_agri_prev(index_region)).*ones(1,nbpar)))./(ones(1,nbpar)+surf_aff(index_region,:)./densityagri_scal_prev(index_region,:).*(( 1 ./surf_total_agri_prev(index_region)).*ones(1,nbpar)));
      dens_LUC_share_P(index_region,:)=(ones(1,nbpar)+surf_aff(index_region,:)./distrib_past_scaling(index_region,:).*(( 1 ./surf_total_agri_prev(index_region)).*ones(1,nbpar)))./(ones(1,nbpar)+surf_aff(index_region,:)./densityagri_scal_prev(index_region,:).*(( 1 ./surf_total_agri_prev(index_region)).*ones(1,nbpar)));
    end
  end

end

exec (MODEL+"nexus.landuse.initeq.sce");


exec(codes_dir+"demand_computation.sce");
string_year=string(base_year+current_time);

exec (MODEL+"nexus.landuse.initeq.sce");

exec(codes_dir+"equilibrium.sce");
exec(codes_dir+"get_results.sce");

exec(codes_dir+"verify_equilibrium.sce");
exec(codes_dir+"create_results.sce");

if do_write_density_yearly then
    fprintfMat(cur_run_out4density_dir+"density_crop_"+string_year+".csv",density_Dyn_new,'%1.9g;');
    fprintfMat(cur_run_out4density_dir+"density_ML_"+string_year+".csv",density_ML_new,'%1.9g;');
    fprintfMat(cur_run_out4density_dir+"density_P_"+string_year+".csv",density_P_new,'%1.9g;');
    fprintfMat(cur_run_out4density_dir+"density_forest_"+string_year+".csv",density_forest,'%1.9g;');
    fprintfMat(cur_run_out4density_dir+"density_otCrop_"+string_year+".csv",density_otCrops_new,'%1.9g;');
    fprintfMat(cur_run_out4density_dir+"density_remain_"+string_year+".csv",c_density_remain,'%1.9g;');
    fprintfMat(cur_run_out4density_dir+"density_lcbio_"+string_year+".csv", density_lcbio_new,'%1.9g;');
    fprintfMat(cur_run_out4density_dir+"density_veg_"+string_year+".csv", density_veg_new,'%1.9g;');
end
i = current_time;


