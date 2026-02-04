// here we assume that there is no supply curve tryial if real failed
// we also assume it is better to use the prev start_point for the real point
// but we would like to save it along the supply curve

if fixed_nlu_startpoint
    fixed_nlu_startpoint=%f;
    if build_et_curve_NLU
      pcalveg_past = sav_pcalopt_start_point;
      exportsveg_past = sav_exportsveg_stpoint;
      exportsrumi_past = sav_exportsrumi_stpoint;
    else
      pcalveg_past=pcalveg_prev;
      exportsveg_past=exportsveg_prev;
      exportsrumi_past=exportsrumi_prev;
    end
else

  if build_et_curve_NLU // building cost curve
    pcalveg_past = pcalveg;
    exportsveg_past=exportsveg;
    exportsrumi_past=exportsrumi;
  else
    pcalveg_past=pcalveg_prev;
    exportsveg_past=exportsveg_prev;
    exportsrumi_past=exportsrumi_prev;
  end
  sav_pcalopt_start_point=pcalveg_past;
  sav_exportsveg_stpoint=exportsveg_past;
  sav_exportsrumi_stpoint=exportsrumi_past;

end

  pcalopt_start_point=pcalveg_past;
  exportsveg_start_point = exportsveg_past;
  exportsveg_start_point=exportsveg_past;//.* coeftrade_veg_emis./(pcalopt_start_point./pcalveg_past);
  exportsrumi_start_point=exportsrumi_past;//.* coeftrade_rumi_emis./(pcalrumiopt_start_point./pcalrumi_prev);
  exportsrumi_start_point = exportsrumi_past;
  exportsveg_start_point(exportsveg_start_point<0)=0;
  exportsrumi_start_point(exportsrumi_start_point<0)=0;
